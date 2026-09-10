"""
    RanefInfo

Information on random effects conditional modes/means, variances, etc.

Used for creating caterpillar plots.

# Fields

$(TYPEDFIELDS)
"""
struct RanefInfo{T<:AbstractFloat}
    """Column names, i.e. predictor coefficient names"""
    cnames::Vector{String}
    """Levels of the random effect, i.e. group names"""
    levels::Vector
    """Conditional modes (or means) of the random effects"""
    ranef::Matrix{T}
    """Conditional standard deviations of the random effects"""
    stddev::Matrix{T}
end

"""
    ranefinfo(m::MixedModel)

Return a `NamedTuple{fnames(m), NTuple{k, RanefInfo}}` from model `m`
"""
function ranefinfo(m::MixedModel{T}) where {T}
    fn = fnames(m)
    val = sizehint!(RanefInfo[], length(fn))
    re = ranef(m)
    for grp in fn
        push!(val, ranefinfo(m, grp, re))
    end
    return NamedTuple{fn}((val...,))
end

"""
    ranefinfo(m::LinearMixedModel, gf::Symbol, re=ranef(m))

Return a `RanefInfo` corresponding to the grouping variable `gf` in model `m`.

The optional `re` argument is a precomputed `ranef(m)` result, used to avoid recomputation.
"""
function ranefinfo(m::LinearMixedModel, gf::Symbol, re=ranef(m))
    idx = _group_idx(m, gf)

    # XXX replace ranef(m)[idx] with ranef(m, gf) when that becomes available upstream
    re, eff, cv = m.reterms[idx], re[idx], condVar(m, gf)
    return RanefInfo(re.cnames,
                     re.levels,
                     Matrix(adjoint(eff)),
                     Matrix(adjoint(dropdims(sqrt.(mapslices(diag, cv; dims=1:2)); dims=2))))
end

function ranefinfo(m::GeneralizedLinearMixedModel, args...; kwargs...)
    return ranefinfo(m.LMM, args...; kwargs...)
end

"""
    ranefinfotable(ri::RanefInfo)
    ranefinfotable(ris::NamedTuple)
    ranefinfotable(m::MixedModel, args...; kwargs...)

Return the information in `ri` (or derived from `m`) as a column table (`NamedTuple` of `Vector`s)

The columns are

- `name`: name of the random effect
- `level`: level of the grouping factor
- `cmode`: conditional mode of the random effect
- `cstddev`: conditional standard deviation of the random effect

When called with a `NamedTuple` (as returned by [`ranefinfo(m::MixedModel)`](@ref)),
a `group` column is prepended containing the grouping factor name for each row.

The `MixedModel` method is a convenience wrapper equivalent to
`ranefinfotable(ranefinfo(m, args...; kwargs...))`.
"""
function ranefinfotable(ri::RanefInfo)
    cnames, levels = ri.cnames, ri.levels
    k = length(cnames)
    l = length(levels)
    return (;
            name=repeat(cnames; inner=l),
            level=repeat(levels; outer=k),
            cmode=vec(ri.ranef),
            cstddev=vec(ri.stddev))
end

function ranefinfotable(ris::NamedTuple)
    rowtable = mapreduce(vcat, propertynames(ris), values(ris)) do grpname, ri
        table = ranefinfotable(ri)
        table = merge((; group=fill(grpname, length(table.name))),
                      table)
        return Tables.rowtable(table)
    end

    return Tables.columntable(rowtable)
end

function ranefinfotable(m::MixedModel, args...; kwargs...)
    return ranefinfotable(ranefinfo(m, args...; kwargs...))
end

"""
    caterpillar(m::MixedModel, gf::Symbol=first(fnames(m)); kwargs...)::Figure
    caterpillar!(f::$(Indexable), m::MixedModel,
                 gf::Symbol=first(fnames(m)); kwargs...)
    caterpillar!(f::$(Indexable), r::RanefInfo;
                orderby=1, cols::Union{Nothing,AbstractVector}=nothing,
                dotcolor=(:red, 0.2), barcolor=:black,
                vline_at_zero::Bool=false)

Create a "caterpillar plot" of the random-effects conditional means and prediction intervals.

A "caterpillar plot" is a horizontal error-bar plot of conditional means and standard deviations
of the random effects.

When passing a `MixedModel`, `gf` specifies which grouping variable is displayed.
Alternatively, [`ranefinfo`](@ref) may be used to construct the [`RanefInfo`](@ref) object directly.
Constructing `RanefInfo` directly can be used to avoid re-computing the conditional variances.

The order of the levels on the vertical axes is increasing `orderby` column
of `r.ranef`, usually the `(Intercept)` random effects.
`orderby` can be an integer column index, a column name (as a `Symbol` or `String`), or `nothing` to disable sorting.
Setting `orderby=nothing` returns the levels in the order they are stored in.

The display can be restricted to a subset of random effects associated with a grouping variable by
specifying `cols`, either by indices or term names.

The mutating methods return the original object.

!!! note
    Even when not sorting the levels, they might have already been sorted during
    model matrix construction. If you want impose a particular ordering on the
    levels, then you must sort the relevant fields in the `RanefInfo` object before
    calling `caterpillar!`.

!!! note
    When `orderby` is specified as a column name (Symbol or String), it refers to a column
    within those specified by `cols`, not the full set of random effects coefficients.
"""
function caterpillar!(f::Indexable, r::RanefInfo;
                      orderby=1, cols::Union{Nothing,AbstractVector}=nothing,
                      dotcolor=(:red, 0.2), barcolor=:black,
                      vline_at_zero::Bool=false)
    cols = something(cols, axes(r.cnames, 1))
    cols = _cols_to_idx(r.cnames, cols)
    rr = view(r.ranef, :, cols)
    sd = view(r.stddev, :, cols)
    cn = view(r.cnames, cols)
    y = axes(rr, 1)
    orderby = _resolve_orderby(cn, orderby)
    ord = isnothing(orderby) ? y : sortperm(view(rr, :, orderby))
    axs = [Axis(f[1, j]) for j in axes(rr, 2)]
    linkyaxes!(axs...)
    for (j, ax) in enumerate(axs)
        xvals = view(rr, ord, j)
        scatter!(ax, xvals, y; color=dotcolor)
        errorbars!(ax, xvals, y, 1.960 * view(sd, ord, j); direction=:x, color=barcolor)
        ax.xlabel = cn[j]
        ax.yticks = y
        j > 1 && hideydecorations!(ax; grid=false)
        vline_at_zero && vlines!(ax, 0; color=(:black, 0.75), linestyle=:dash)
    end
    axs[1].yticks = (y, string.(r.levels[ord]))
    return f
end

function caterpillar!(f::Indexable, m::MixedModel,
                      gf::Symbol=first(fnames(m)); kwargs...)
    return caterpillar!(f, ranefinfo(m, gf); kwargs...)
end

"""$(@doc caterpillar!)"""
function caterpillar(m::MixedModel, gf::Symbol=first(fnames(m)); kwargs...)
    return caterpillar!(Figure(; size=(1000, 800)), m, gf; kwargs...)
end

"""
    qqcaterpillar(m::MixedModel, gf::Symbol=first(fnames(m)); kwargs...)::Figure
    qqcaterpillar!(f::$(Indexable), m::MixedModel,
                   gf::Symbol=first(fnames(m)); kwargs...)
    qqcaterpillar!(f::$(Indexable), r::RanefInfo;
                   cols::Union{Nothing,AbstractVector}=nothing,
                   dotcolor=(:red, 0.2), barcolor=:black,
                   vline_at_zero::Bool=false)

Create a caterpillar plot with the vertical axis on the Normal() quantile scale.

When passing a `MixedModel`, `gf` specifies which grouping variable is displayed.
Alternatively, [`ranefinfo`](@ref) may be used to construct the [`RanefInfo`](@ref) object directly.
Constructing `RanefInfo` directly can be used to avoid re-computing the conditional variances.

The display can be restricted to a subset of random effects associated with a grouping variable by
specifying `cols`, either by indices or term names.

The order of the levels on the vertical axes is increasing `orderby` column
of `r.ranef`, usually the `(Intercept)` random effects.
Setting `orderby=nothing` will disable sorting, i.e. return the levels in the
order they are stored in.

The mutating methods return the original object.
"""
function qqcaterpillar!(f::Indexable, r::RanefInfo;
                        cols::Union{Nothing,AbstractVector}=nothing,
                        dotcolor=(:red, 0.2), barcolor=:black,
                        vline_at_zero::Bool=false)
    cols = something(cols, axes(r.cnames, 1))
    cols = _cols_to_idx(r.cnames, cols)
    cn, rr = r.cnames, r.ranef
    y = zquantile.(ppoints(size(rr, 1)))
    axs = [Axis(f[1, j]) for j in axes(cols, 1)]
    linkyaxes!(axs...)
    for (j, k) in enumerate(cols)
        ax = axs[j]
        xvals = rr[:, k]
        ord = sortperm(xvals)
        xvals = xvals[ord]
        scatter!(ax, xvals, y; color=dotcolor)
        errorbars!(ax, xvals, y, 1.960 * view(r.stddev, ord, k); direction=:x,
                   color=barcolor)
        ax.xlabel = string(cn[k])
        j > 1 && hideydecorations!(ax; grid=false)
        vline_at_zero && vlines!(ax, 0; color=(:black, 0.75), linestyle=:dash)
    end
    return f
end

function qqcaterpillar!(f::Indexable, m::MixedModel,
                        gf::Symbol=first(fnames(m)); kwargs...)
    return qqcaterpillar!(f, ranefinfo(m, gf); kwargs...)
end

"""$(@doc qqcaterpillar!)"""
function qqcaterpillar(m::MixedModel, gf::Symbol=first(fnames(m)); kwargs...)
    return qqcaterpillar!(Figure(; size=(1000, 800)), m, gf; kwargs...)
end
