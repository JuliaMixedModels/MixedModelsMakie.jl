"""
    coefplot(x::Union{MixedModel,MixedModelBootstrap}; kwargs...)::Figure
    coefplot!(fig::$(Indexable), x::Union{MixedModel,MixedModelBootstrap};
              kwargs...)
    coefplot!(ax::Axis, Union{MixedModel,MixedModelBootstrap};
              conf_level=0.95, vline_at_zero=true, show_intercept=true,
              scatter_attributes=(;),
              errorbars_attributes=(;),
              attributes...)

Create a coefficient plot of the fixed-effects and associated confidence intervals.

Inestimable coefficients (coefficients removed by pivoting in the rank deficient case) are excluded.

`attributes` are passed onto both `scatter!` and `errorbars!`, while
`scatter_attributes` and `errorbars_attributes` are passed only onto `scatter!` and
`errorbars!`, respectively. (Starting with Makie 0.21, unsupported attributes for a
given plottype are no longer silently ignored, so it's necessary so separate out the
attributes that are only valid for a single plot type.)

The mutating methods return the original object.

!!! note
    Inestimable coefficients (coefficients removed by pivoting in the rank deficient case)
    are excluded.
"""
function coefplot(x::Union{MixedModel,MixedModelBootstrap}...;
                  show_intercept=true,
                  show_legend=true,
                  kwargs...)
    width = 640
    # need to guarantee a min height of 150
    height = max(150, 75 * _npreds(first(x); show_intercept))

    width += 50 * (show_legend in (:left, :right))
    height += 50 * (show_legend in (true, :top, :bottom))

    fig = Figure(; size=(width, height))
    coefplot!(fig, x...; show_intercept, show_legend, kwargs...)
    return fig
end

"""$(@doc coefplot)"""
function coefplot!(fig::Indexable, x::Union{MixedModel,MixedModelBootstrap}...; show_legend=true, legend_attributes=(;), kwargs...)
    ax = Axis(fig[1, 1])
    kwargs = _extract_title!(ax, kwargs)
    axis_legend = show_legend === :axis
    legend_attributes = merge((;merge=true,unique=true), legend_attributes)
    if axis_legend
        show_legend = false
    end
    coefplot!(ax, x...; legend_attributes, show_legend=axis_legend, kwargs...)

    if show_legend == true || show_legend === :bottom
        fig[2, 1] = Legend(fig, ax;
                            orientation=:horizontal,
                            tell_width=false,
                            tell_height=false,
                            legend_attributes...)
    elseif show_legend === :top
        fig[0, 1] = Legend(fig, ax;
                           orientation=:horizontal,
                           tell_width=false,
                           tell_height=false,
                           legend_attributes...)
    elseif show_legend === :left
        fig[1, 0] = Legend(fig, ax;
                           orientation=:vertical,
                           tell_width=false,
                           tell_height=false,
                           legend_attributes...)
    elseif show_legend === :right
        fig[1, 2] = Legend(fig, ax;
                           orientation=:vertical,
                           tell_width=false,
                           tell_height=false,
                           legend_attributes...)
    elseif show_legend == false
        # do nothing
    else
        throw(ArgumentError("Invalid legend position"))
    end
    return fig
end

"""$(@doc coefplot)"""
function coefplot!(ax::Axis, xs::Union{MixedModel,MixedModelBootstrap}...;
                   conf_level=0.95,
                   vline_at_zero=true,
                   show_intercept=true,
                   scatter_attributes=(;),
                   errorbars_attributes=(;),
                   show_legend=length(xs) > 1,
                   legend_attributes=(;),
                   labels=string.(1:length(xs)),
                   attributes...)

    x = first(xs)
    cn = _coefnames(x; show_intercept)
    nticks = _npreds(x; show_intercept)
    all(_coefnames(m; show_intercept) == cn for m in xs) ||
       throw(ArgumentError("Inputs differ in coefficient names"))

    for (x, label) in zip(xs, labels)
        ci = confint_table(x, conf_level; show_intercept)
        y = nrow(ci):-1:1
        xvals = ci.estimate
        scatter!(ax, xvals, y; attributes..., scatter_attributes..., label)
        errorbars!(ax, xvals, y, xvals .- ci.lower, ci.upper .- xvals;
                   direction=:x, attributes..., errorbars_attributes...,
                   label)
    end

    vline_at_zero && vlines!(ax, 0; color=(:black, 0.75), linestyle=:dash)

    # this is the axis method, so we only have the axislegend
    if show_legend
        legend_attributes = merge((;merge=true,unique=true), legend_attributes)
        axislegend(ax; legend_attributes...)
    end

    reset_limits!(ax)
    xlabel = @sprintf "Estimate and %g%% confidence interval" conf_level * 100
    ax.xlabel = xlabel
    ax.yticks = (nticks:-1:1, cn)
    ylims!(ax, 0, nticks + 1)
    return ax
end

# function g(; kwargs...)
#     if :a in keys(kwargs)
#         a = kwargs[:a]
#         kwargs = Base.pairs(NamedTuple((k => v for (k, v) in kwargs if k != :a)))
#     end

#     @info "" kwargs
# end
