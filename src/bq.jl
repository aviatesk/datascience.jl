using CSV

# validate query at parse time (and embedded syntax highlight)
macro bq_str(s)
    out = runbq(io->read(io,String), s, true)
    (m = match(r"(?<bytes>\d+)\sbytes", out)) === nothing && error("invalid dry run: $(out)")
    sizes = (b = parse(Int, m[:bytes])) < 10^9 ? "$(b÷10^6) MB" : "$(b÷10^9) GB"
    @info "This query will process $(sizes) when run."
    return s
end

function runbq(f, query, dry_run = false)
    exec = ["bq", "query", "--nouse_legacy_sql"]
    dry_run ? push!(exec, "--dry_run") : push!(exec, "--format=csv", "-n", string(10^8))
    push!(exec, "$(query)")
    open(f, Cmd(exec))
end
writebq(file, query) = runbq(io->write(file,read(io)), query)
writeandreadbq(file, query; kwargs...) = (writebq(file,query); CSV.read(file; kwargs...))
readbq(query; kwargs...) = writeandreadbq(tempname(), query; kwargs...)
