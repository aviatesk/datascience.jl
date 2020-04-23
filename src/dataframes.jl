using DataFrames, DataFramesMeta, StatsPlots

# HACK:
# integrate StatsPlots.@df into @linq chain in a way data frame keeps to be passed even after plot
# but, the `names` part might be too dangerous
for n in names(StatsPlots)
    function DataFramesMeta.linq(::DataFramesMeta.SymbolParameter{n}, d, args...)
        plotcall = Expr(:call, n, args...)
        return quote let d = $d
            display(@df d $plotcall)
            d
        end end
    end
end
# TODO: deprecate the outdated original `@by` transform in DataFramesMeta package
DataFramesMeta.linq(::DataFramesMeta.SymbolParameter{:by′}, d, args...) =
    Expr(:call, :by, d, args...)
DataFramesMeta.linq(::DataFramesMeta.SymbolParameter{:select′}, d, args...) =
    Expr(:call, :select, d, args...)

# example
# -------

@linq DataFrame(name = rand('A':'Z', 1000), val = rand(1000)) |>
    by(:name, mean = mean(:val)) |>
    sort(:name) |>
    bar(:name, :mean; orientation = :horizontal) |>
    transform(meanall = fill(mean(:mean), length(:mean))) |>
    vline!(:meanall)
