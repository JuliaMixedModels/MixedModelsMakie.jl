"""
    _auto_label_idx(reest, n_labels)

Return the indices of (at most) `n_labels` grouping-factor levels whose shrunk (conditional mode)
estimate `reest` remains farthest from the origin.

Ranking on the *shrunk* magnitude, rather than the reference (unshrunk) magnitude, favors levels
that were extreme and resisted shrinkage over levels that were merely extreme in the noisy,
unshrunk estimate and got pulled back towards zero — the latter is the common/expected case for
regularized estimates and so is the less "interesting" of the two.
"""
function _auto_label_idx(reest, n_labels::Integer)
    n_labels = min(n_labels, size(reest, 2))
    score = [norm(view(reest, :, i)) for i in axes(reest, 2)]
    return partialsortperm(score, 1:n_labels; rev=true)
end

getellipsepoints(radius, lambda) = getellipsepoints(0, 0, radius, lambda)

function getellipsepoints(cx, cy, radius, lambda)
    t = range(0, 2π; length=100)
    ellipse_x_r = cos.(t)
    ellipse_y_r = sin.(t)
    r_ellipse = radius .* hcat(ellipse_x_r, ellipse_y_r) * lambda'
    x = @. cx + r_ellipse[:, 2]
    y = @. cy + r_ellipse[:, 1]
    return x, y
end

"""
    _ranef(m::MixedModel, θref; uscale::Bool=false)

Compute the conditional modes at θref.

!!! warn
    This function is **not** thread safe because it temporarily mutates
    the passed model before restoring its original form.
"""
function _ranef(m::LinearMixedModel, θref; uscale::Bool=false)
    vv = try
        ranef(updateL!(setθ!(m, θref)))
    catch e
        @error "Failed to compute unshrunken values with the following exception:"
        rethrow(e)
    finally
        updateL!(setθ!(m, m.optsum.final)) # restore parameter estimates and update m
    end
    return vv
end

function _ranef(m::GeneralizedLinearMixedModel, θref; uscale::Bool=false)
    fast = length(m.θ) == length(m.optsum.final)
    setpar! = fast ? MixedModels.setθ! : MixedModels.setβθ!
    vv = try
        ranef(pirls!(setpar!(m, θref), fast, false)) # not verbose
    catch e
        @error "Failed to compute unshrunken values with the following exception:"
        rethrow(e)
    finally
        pirls!(setpar!(m, m.optsum.final), fast, false) # restore parameter estimates and update m
    end

    return vv
end

function _shrinkage_panel!(ax::Axis, i::Int, j::Int, reref, reest, λ;
                           ellipse::Bool, ellipse_scale::Real, n_ellipse::Integer,
                           shrunk_dotcolor, ref_dotcolor,
                           ellipse_color, ellipse_linestyle,
                           label_idx, labelnames, labelcolor, labelsize)
    x, y = view(reref, j, :), view(reref, i, :)
    u, v = view(reest, j, :), view(reest, i, :)
    scatter!(ax, x, y; color=ref_dotcolor)   # reference points
    arrows!(ax, x, y, u .- x, v .- y)        # first so arrow heads don't obscure pts
    plt = scatter!(ax, u, v; color=shrunk_dotcolor)  # conditional means at estimates
    if !isempty(label_idx)
        text!(ax, view(x, label_idx), view(y, label_idx);
              text=labelnames, color=labelcolor, fontsize=labelsize,
              offset=(4, 4))
    end
    if ellipse
        # force computation of current limits
        autolimits!(ax)
        lims = ax.finallimits[]
        cho = λ[[i, j], [j, i]]
        rad_outer = ellipse_scale * mean(lims.widths)
        rad_inner = 0
        for radius in LinRange(rad_inner, rad_outer, n_ellipse + 1)
            ex, ey = getellipsepoints(radius, cho)
            lines!(ax, ex, ey; color=ellipse_color, linestyle=ellipse_linestyle)
        end
        # preserve the limits from before the ellipse
        limits!(ax, lims)
    end
    return plt
end

"""
    shrinkageplot(m::MixedModel, gf::Symbol=first(fnames(m)), θref, args...; kwargs...)::Figure
    shrinkageplot!(f::$(Indexable), m::MixedModel,
                   gf::Symbol=first(fnames(m)), θref;
                   ellipse=false, ellipse_scale=1, n_ellipse=5,
                   cols::Union{Nothing,AbstractVector}=nothing,
                   shrunk_dotcolor=(:blue, 0.25), ref_dotcolor=(:red, 0.25),
                   ellipse_color=:green, ellipse_linestyle=:dash,
                   labels::Union{Bool,Symbol,AbstractVector}=false,
                   labelcolor=:black, labelsize=10, n_labels::Integer=5)

Create a scatter-plot matrix of the conditional means, b, of the random effects for grouping factor `gf`.

Two sets of conditional means are plotted: those at the estimated parameter values and those at `θref`.
The default `θref` results in `Λ` being a very large multiple of the identity.  The corresponding
conditional means can be regarded as unpenalized.

The display can be restricted to a subset of random effects associated with a grouping variable by
specifying `cols`, either by indices or term names.

The reference (unshrunk) points can be labeled with the levels of `gf` by passing `labels=true`
(label every level), a vector of level names/indices (label only that subset), or `labels=:auto`
(automatically pick the `n_labels` "most interesting" levels).
`labelcolor` and `labelsize` control the appearance of the labels; `n_labels` only applies to
`labels=:auto` and defaults to a small number so the plot doesn't get overcrowded.

Correlation ellipses can be added with `ellipse=true`, with the number of ellipses controlled by
`n_ellipse`. The ellipses are equally spaced between the outer ellipse and the origin (center).
The scaling of the ellipses can be adjusted with the multiplicative `ellipse_scale`. If you are
unable to see the ellipses, try increasing `ellipse_scale`.

The mutating method returns the original object.

See also [`shrinkagedot`](@ref).

!!! note
    For degenerate (singular) models, the correlation ellipse will also be degenerate, i.e.,
    collapse to a point or line.
"""
function shrinkageplot!(f::Indexable,
                        m::MixedModel{T},
                        gf::Symbol=first(fnames(m)),
                        θref::AbstractVector{T}=_ref_theta(m);
                        ellipse::Bool=false, ellipse_scale::Real=1,
                        n_ellipse::Integer=5,
                        cols::Union{Nothing,AbstractVector}=nothing,
                        shrunk_dotcolor=(:blue, 0.25), ref_dotcolor=(:red, 0.25),
                        ellipse_color=:green, ellipse_linestyle=:dash,
                        labels::Union{Bool,Symbol,AbstractVector}=false,
                        labelcolor=:black, labelsize=10, n_labels::Integer=5) where {T}
    # TODO: could ShrinkageInfo simplify some book keeping here?
    reind = _group_idx(m, gf)
    r = m.reterms[reind]
    user_specified_single = !isnothing(cols) && length(cols) == 1
    cols = something(cols, axes(r.cnames, 1))
    cols = _cols_to_idx(r.cnames, cols)

    if length(cols) == 1
        colname = r.cnames[only(cols)]
        msg = if user_specified_single
            "You only specified a single column."
        else
            "Grouping variable (\"$(gf)\") only has a single " *
            "predictor associated with it (\"$(colname)\")."
        end
        msg *= " You need at least two."
        throw(ArgumentError(msg))
    end
    reest = ranef(m)[reind]          # random effects conditional means at estimated θ
    reref = _ranef(m, θref)[reind]   # same at θref

    # transpose is stored, so swap
    reest = view(reest, cols, :)
    reref = view(reref, cols, :)
    λ = view(r.λ, cols, cols)
    cnames = view(r.cnames, cols)

    label_idx = if labels === false
        Int[]
    elseif labels === true
        collect(axes(r.levels, 1))
    elseif labels === :auto
        _auto_label_idx(reest, n_labels)
    elseif labels isa Symbol
        throw(ArgumentError("Unsupported value for `labels`: $(labels). Use `true`, " *
                            "`false`, `:auto`, or a vector of level names/indices."))
    else
        _cols_to_idx(r.levels, labels)
    end
    labelnames = r.levels[label_idx]

    splomaxes!(f, cnames, _shrinkage_panel!,
               reref, reest, λ; ellipse, ellipse_scale, n_ellipse,
               shrunk_dotcolor, ref_dotcolor,
               ellipse_color, ellipse_linestyle,
               label_idx, labelnames, labelcolor, labelsize)

    return f
end

"""$(@doc shrinkageplot!)"""
function shrinkageplot(m::MixedModel, args...; kwargs...)
    f = Figure(; size=(1000, 1000)) # use an aspect ratio of 1 for the whole figure

    return shrinkageplot!(f, m, args...; kwargs...)
end

"""
    ShrinkageInfo

Information on random effects compared to pseudo-OLS estimates.

Used for creating shrinkage caterpillar plots.

# Fields

$(TYPEDFIELDS)

"""
struct ShrinkageInfo{T<:AbstractFloat}
    """Column names, i.e. predictor coefficient names"""
    cnames::Vector{String}
    """Levels of the random effect, i.e. group names"""
    levels::Vector
    "The conditional modes of the random effects"
    blups::Matrix{T}
    """The 'reference' mode of the random effect, 
       corresponding to the conditional mode evaluated at
       the reference value of θ. Typically, this approximates
       the value you would get without any shrinkage, e.g. from
       classical within-groups (non-mixed) regression
    """
    blimps::Matrix{T}
end

"""
    shrinkageinfo(m::MixedModel, θref::Vector{<:AbstractFloat}=_ref_theta(m))

Return a `NamedTuple{fnames(m), NTuple{k, ShrinkageInfo}}` from model `m`

The optional `θref` argument is the θ vector at which to compute the reference (unshrunken) estimates;
it defaults to `_ref_theta(m)`.
"""
function shrinkageinfo(m::MixedModel{T},
                       θref::Vector{<:AbstractFloat}=_ref_theta(m)) where {T}
    fn = fnames(m)
    val = sizehint!(ShrinkageInfo[], length(fn))
    re = ranef(m)
    re_ref = _ranef(m, θref)
    for grp in fn
        push!(val, shrinkageinfo(m, grp, re, re_ref))
    end
    return NamedTuple{fn}((val...,))
end

"""
    shrinkageinfo(m::MixedModel, gf::Symbol, θref::Vector{<:AbstractFloat}=_ref_theta(m))

Return a `ShrinkageInfo` corresponding to the grouping variable `gf` in model `m`.

The optional `θref` argument is the θ vector at which to compute the reference (unshrunken) estimates;
it defaults to `_ref_theta(m)`.
"""
function shrinkageinfo(m::MixedModel, gf::Symbol,
                       θref::Vector{<:AbstractFloat}=_ref_theta(m))
    return shrinkageinfo(m, gf, ranef(m), _ranef(m, θref))
end

function shrinkageinfo(m::MixedModel{T}, gf::Symbol,
                       re::Vector{Matrix{T}}, re_inf::Vector{Matrix{T}}) where {T}
    idx = _group_idx(m, gf)
    # XXX replace ranef(m)[idx] with ranef(m, gf) when that becomes available upstream
    re_term = m.reterms[idx]
    blups = re[idx]
    blimps = re_inf[idx]
    return ShrinkageInfo(re_term.cnames,
                         re_term.levels,
                         Matrix(adjoint(blups)),
                         Matrix(adjoint(blimps)))
end

function shrinkageinfo(m::GeneralizedLinearMixedModel, args...; kwargs...)
    return shrinkageinfo(m.LMM, args...; kwargs...)
end

"""
    shrinkageinfotable(si::ShrinkageInfo)
    shrinkageinfotable(sis::NamedTuple)
    shrinkageinfotable(m::MixedModel, args...; kwargs...)

Return the information in `si` (or derived from `m`) as a column table (`NamedTuple` of `Vector`s)

The columns are

- `name`: name of the random effect
- `level`: level of the grouping factor
- `cmode`: conditional mode of the random effect
- `rmode`: reference mode of the random effect, corresponding to the conditional mode evaluated at
           the reference value of θ. Typically, this approximates the value you would get without
           any shrinkage, e.g. from classical within-groups (non-mixed) regression

When called with a `NamedTuple` (as returned by [`shrinkageinfo(m::MixedModel)`](@ref)),
a `group` column is prepended containing the grouping factor name for each row.

The `MixedModel` method is a convenience wrapper equivalent to
`shrinkageinfotable(shrinkageinfo(m, args...; kwargs...))`.
"""
function shrinkageinfotable(si::ShrinkageInfo)
    cnames, levels = si.cnames, si.levels
    k = length(cnames)
    l = length(levels)
    return (;
            name=repeat(cnames; inner=l),
            level=repeat(levels; outer=k),
            cmode=vec(si.blups),
            rmode=vec(si.blimps))
end

function shrinkageinfotable(sis::NamedTuple)
    rowtable = mapreduce(vcat, propertynames(sis), values(sis)) do grpname, si
        table = shrinkageinfotable(si)
        table = merge((; group=fill(grpname, length(table.name))),
                      table)
        return Tables.rowtable(table)
    end

    return Tables.columntable(rowtable)
end

function shrinkageinfotable(m::MixedModel, args...; kwargs...)
    return shrinkageinfotable(shrinkageinfo(m, args...; kwargs...))
end

"""
    shrinkagedot(m::MixedModel, gf::Symbol=first(fnames(m)); kwargs...)::Figure
    shrinkagedot!(f::$(Indexable), m::MixedModel,
                  gf::Symbol=first(fnames(m)); kwargs...)
    shrinkagedot!(f::$(Indexable), r::ShrinkageInfo;
                  orderby=1, cols::Union{Nothing,AbstractVector}=nothing,
                  ordertype=:shrunk,
                  shrunk_dotcolor=(:blue, 0.25), ref_dotcolor=(:red, 0.25),
                  arrowcolor=:black,
                  vline_at_zero::Bool=false)

Create a "dot plot" of the random-effects conditional modes and corresponding unshrunken reference values.

The dot plot is similar in spirit to a one-dimensional [`shrinkageplot`](@ref) and shows the change in each
predictor more clearly.

When passing a `MixedModel`, `gf` specifies which grouping variable is displayed.
Alternatively, [`shrinkageinfo`](@ref) may be used to construct the [`ShrinkageInfo`](@ref) object directly.
Constructing `ShrinkageInfo` directly can be used to avoid re-computing the conditional variances.

The order of the levels on the vertical axes is increasing `orderby` column
of `r.blups` (shrunk effects) or `r.blimps` (reference/unshrunken effects), usually the `(Intercept)` random effects.
Which to sort by is controlled via `ordertype` (`:shrunk` or `:ref`).
Setting `orderby=nothing` will disable sorting, i.e. return the levels in the
order they are stored in.

The display can be restricted to a subset of random effects associated with a grouping variable by
specifying `cols`, either by indices or term names.

The mutating methods return the original object.

!!! note
    Even when not sorting the levels, they might have already been sorted during
    model matrix construction. If you want impose a particular ordering on the
    levels, then you must sort the relevant fields in the `ShrinkageInfo` object before
    calling `shrinkagedot!`.

!!! note
    `orderby` is the ``n``th column of the columns specified by `cols`.
"""
function shrinkagedot!(f::Indexable, r::ShrinkageInfo;
                       # TODO: allow orderby to be specified as a name
                       orderby=1, cols::Union{Nothing,AbstractVector}=nothing,
                       ordertype=:shrunk,
                       shrunk_dotcolor=(:blue, 0.25),
                       ref_dotcolor=(:red, 0.25),
                       arrowcolor=:black,
                       vline_at_zero::Bool=false)
    cols = something(cols, axes(r.cnames, 1))
    cols = _cols_to_idx(r.cnames, cols)
    blups = view(r.blups, :, cols)
    blimps = view(r.blimps, :, cols)
    cn = view(r.cnames, cols)
    y = axes(blups, 1)
    # TODO: check for invalid input 
    # we want to restrict this to :shrunk and :ref
    orderer = ordertype === :shrunk ? blups : blimps
    ord = isnothing(orderby) ? y : sortperm(view(orderer, :, orderby))
    axs = [Axis(f[1, j]) for j in axes(blups, 2)]
    linkyaxes!(axs...)
    y0 = zeros(y)
    for (j, ax) in enumerate(axs)
        x_blups = view(blups, ord, j)
        x_blimps = view(blimps, ord, j)
        # first so arrow heads don't obscure pts
        arrows!(ax, x_blimps, y, x_blups .- x_blimps, y0; color=arrowcolor)
        scatter!(ax, x_blups, y; color=shrunk_dotcolor)
        scatter!(ax, x_blimps, y; color=ref_dotcolor)
        # errorbars!(ax, xvals, y, 1.960 * view(sd, ord, j); direction=:x, color=barcolor)
        ax.xlabel = cn[j]
        ax.yticks = y
        j > 1 && hideydecorations!(ax; grid=false)
        vline_at_zero && vlines!(ax, 0; color=(:black, 0.75), linestyle=:dash)
    end
    axs[1].yticks = (y, string.(r.levels[ord]))
    return f
end

function shrinkagedot!(f::Indexable, m::MixedModel,
                       gf::Symbol=first(fnames(m)); kwargs...)
    return shrinkagedot!(f, shrinkageinfo(m, gf); kwargs...)
end

"""$(@doc shrinkagedot)"""
function shrinkagedot(m::MixedModel, gf::Symbol=first(fnames(m)); kwargs...)
    return shrinkagedot!(Figure(; size=(1000, 800)), m, gf; kwargs...)
end
