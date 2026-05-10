"""
    _categorical_terms(m::MixedModel) → (names, levels)

Return parallel vectors of categorical fixed-effect predictor names and their
level vectors (all levels, including the reference level).

Uses formula introspection: `first(m.formula.rhs)` is the `MatrixTerm` for
fixed effects; `StatsModels.terms` recursively collects leaf terms.
"""
function _categorical_terms(m::MixedModel)
    fe = first(m.formula.rhs)
    leaf = terms(fe)
    names = String[]
    lvls = Vector[]
    for term in leaf
        term isa CategoricalTerm || continue
        n = string(term.sym)
        n in names && continue
        push!(names, n)
        push!(lvls, term.contrasts.levels)
    end
    return names, lvls
end

"""
    _upset_data(m::MixedModel, data; gf::Symbol)

Build the data structures for an UpSet plot.

**Sets (columns)** are the individual levels of each categorical fixed-effect predictor
(e.g., `"spkr: new"`, `"spkr: old"`, `"prec: break"`, …).

**Rows** are the full factorial cells — all combinations of exactly one level from each
predictor (e.g., `"spkr: new & prec: break & load: no"`). Combinations of two levels
from the *same* predictor are excluded because they cannot co-occur in a single
observation.

The combination matrix is structural: entry `[i, j]` is `true` if cell `i` includes
the condition level of set `j`.

Counts are data-derived: `cell_counts[i]` is the number of grouping-factor levels that
appeared in at least one observation in cell `i`; `set_counts[j]` is the number that
appeared in at least one observation with condition level `j`.

Returns a `NamedTuple` with fields:
- `gf_levels`, `set_labels`, `cell_labels`, `combo_matrix`, `cell_counts`, `set_counts`
"""
function _upset_data(m::MixedModel, data; gf::Symbol)
    df = data isa DataFrame ? data : DataFrame(data)
    idx = findfirst(==(gf), fnames(m))
    isnothing(idx) &&
        throw(ArgumentError("$gf is not the name of a grouping variable in the model"))

    gf_levels = m.reterms[idx].levels
    pred_names, pred_levels = _categorical_terms(m)
    isempty(pred_names) &&
        throw(ArgumentError("No categorical fixed-effect predictors found in model"))

    n_gf = length(gf_levels)

    # Sets = individual condition levels, grouped by predictor (these become the columns)
    set_labels = String[string(p, ": ", lv)
                        for (p, lvs) in zip(pred_names, pred_levels) for lv in lvs]
    n_sets = length(set_labels)

    # Index: (predictor_index, level_as_string) → set column index
    set_index = Dict{Tuple{Int,String},Int}()
    k = 1
    for (pi, lvs) in enumerate(pred_levels)
        for lv in lvs
            set_index[(pi, string(lv))] = k
            k += 1
        end
    end

    # Cells = full factorial: one level per predictor (these become the rows)
    cell_labels = String[]
    cell_set_indices = Vector{Int}[]
    cell_checks = Vector{Pair{Int,String}}[]

    for combo in Iterators.product(pred_levels...)
        parts = [string(pred_names[j], ": ", combo[j]) for j in eachindex(pred_names)]
        push!(cell_labels, join(parts, " & "))
        push!(cell_set_indices, [set_index[(j, string(combo[j]))] for j in eachindex(pred_names)])
        push!(cell_checks, [j => string(combo[j]) for j in eachindex(pred_names)])
    end
    n_cells = length(cell_labels)

    # Structural combination matrix: (n_cells × n_sets)
    combo_matrix = falses(n_cells, n_sets)
    for (ci, sidxs) in enumerate(cell_set_indices)
        for si in sidxs
            combo_matrix[ci, si] = true
        end
    end

    # Subject membership per cell and per individual condition
    cell_membership = falses(n_gf, n_cells)
    set_membership = falses(n_gf, n_sets)

    gf_index = Dict(lv => i for (i, lv) in enumerate(gf_levels))
    gf_col = df[!, gf]
    pred_cols = [df[!, Symbol(p)] for p in pred_names]

    for obs_i in 1:nrow(df)
        gi = get(gf_index, gf_col[obs_i], nothing)
        isnothing(gi) && continue
        obs_vals = [string(pred_cols[j][obs_i]) for j in eachindex(pred_names)]

        for (ci, checks) in enumerate(cell_checks)
            if all(obs_vals[j] == lv for (j, lv) in checks)
                cell_membership[gi, ci] = true
            end
        end

        for j in eachindex(pred_names)
            si = get(set_index, (j, obs_vals[j]), nothing)
            isnothing(si) && continue
            set_membership[gi, si] = true
        end
    end

    cell_counts = [count(cell_membership[:, ci]) for ci in axes(cell_membership, 2)]
    set_counts = [count(set_membership[:, si]) for si in axes(set_membership, 2)]

    return (; gf_levels, set_labels, cell_labels, combo_matrix, cell_counts, set_counts)
end

"""
    upsetplot!(f::Indexable, m::MixedModel, data;
               gf::Symbol=first(fnames(m)),
               sortby::Symbol=:count,
               filled_color=:black,
               empty_color=:lightgray,
               bar_color=:steelblue,
               dot_size=12)

Add an UpSet plot to `f` showing which levels of grouping factor `gf` appear
in which categorical fixed-effect conditions.

**Layout (standard UpSet orientation):**
- top-right: intersection-size bar chart (subjects per full factorial cell)
- middle-right: combination matrix — rows are individual condition levels (sets),
  columns are full factorial cells; filled circles mark which condition levels are
  active in each cell, connected by a vertical line
- middle-left: set-size bar chart (subjects per individual condition level)

`data` must be the same data frame (or any Tables.jl-compatible table) used to
fit `m`.
"""
function upsetplot!(f::Indexable, m::MixedModel, data;
                    gf::Symbol=first(fnames(m)),
                    sortby::Symbol=:count,
                    filled_color=:black,
                    empty_color=:lightgray,
                    bar_color=:steelblue,
                    dot_size=12)
    info = _upset_data(m, data; gf)

    n_sets = length(info.set_labels)
    n_cells = length(info.cell_labels)

    perm = if sortby === :count
        sortperm(info.cell_counts; rev=true)
    elseif sortby === :degree
        axes(info.cell_counts, 1)
    else
        throw(ArgumentError("sortby must be :count or :degree, got :$sortby"))
    end
    cell_counts = info.cell_counts[perm]
    combo_matrix = info.combo_matrix[perm, :]

    ax_bar = Axis(f[1, 2]; ylabel="Intersection size")
    ax_matrix = Axis(f[2, 2])
    ax_sets = Axis(f[2, 1]; xlabel="Set size")

    hidexdecorations!(ax_bar; grid=false)
    hidexdecorations!(ax_matrix; grid=false)
    hideydecorations!(ax_sets; grid=false)
    linkxaxes!(ax_bar, ax_matrix)
    linkyaxes!(ax_sets, ax_matrix)

    barplot!(ax_bar, 1:n_cells, cell_counts; color=bar_color)

    barplot!(ax_sets, 1:n_sets, info.set_counts; direction=:x, color=bar_color)
    ax_sets.xreversed = true

    empty_xs = Float64[]
    empty_ys = Float64[]
    filled_xs = Float64[]
    filled_ys = Float64[]

    for ci in 1:n_cells
        active = findall(combo_matrix[ci, :])
        if length(active) >= 2
            lines!(ax_matrix, [ci, ci], [minimum(active), maximum(active)];
                   color=filled_color, linewidth=2)
        end
        for si in 1:n_sets
            if combo_matrix[ci, si]
                push!(filled_xs, ci)
                push!(filled_ys, si)
            else
                push!(empty_xs, ci)
                push!(empty_ys, si)
            end
        end
    end

    isempty(empty_xs) ||
        scatter!(ax_matrix, empty_xs, empty_ys; color=empty_color, markersize=dot_size)
    isempty(filled_xs) ||
        scatter!(ax_matrix, filled_xs, filled_ys; color=filled_color, markersize=dot_size)

    ax_matrix.yticks = (1:n_sets, info.set_labels)
    ax_matrix.yreversed = true
    ax_sets.yreversed = true

    return f
end

"""
    upsetplot(m::MixedModel, data;
              gf::Symbol=first(fnames(m)),
              sortby::Symbol=:count,
              kwargs...)

Return a `Figure` with an UpSet plot showing which levels of grouping factor `gf`
appear in which categorical fixed-effect conditions.

`data` must be the same data frame (or any Tables.jl-compatible table) used to
fit `m`.

`kwargs` are forwarded to [`upsetplot!`](@ref).
"""
function upsetplot(m::MixedModel, data;
                   gf::Symbol=first(fnames(m)), kwargs...)
    return upsetplot!(Figure(; size=(1000, 800)), m, data; gf, kwargs...)
end
