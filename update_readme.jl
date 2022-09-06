const LINKS_START = "<!-- LINKS -->"
const LINKS_END = "<!-- END_LINKS -->"

function replace_content(new_lines, filepath="./README.md")
    lines = eachline(filepath; keep=false) |> collect
    start = findfirst(==(LINKS_START), lines)
    end_ = findfirst(==(LINKS_END), lines)
    @assert !isnothing(start)
    @assert !isnothing(end_)

    open(filepath, "w") do f
        write(f, join(@view(lines[begin:start]), '\n'), '\n')
        write(f, join(new_lines, '\n'), '\n')
        write(f, join(@view(lines[end_:end]), '\n'))
    end
end

function build_link_list()
    paths = filter(readdir()) do path
        endswith(path, ".jl") && basename(path) != "./update_readme.jl"
    end

    map(paths) do path
        path = replace(path, ".jl" => "")
        " - [$path](https://pangoraw.github.io/Notebooks/$(path))"
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    replace_content(build_link_list())
    @info "done"
end
