### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ 77423e98-b580-11ec-3aaa-131342d1510d
md"""
# A better `@less` inside notebooks

Copy the following cell in your notebook:
"""

# ╔═╡ d1928a6f-c564-4ace-a1e0-7789d6f65e28
function InteractiveUtils.less(file::AbstractString, line::Integer)
	content = read(file, String)

	lines = split(content, '\n')[line:end]
	if endswith(file, ".jl")
	
		final_idx = findfirst(==(""), lines)
		def = join(lines[begin:final_idx], '\n')
		Markdown.MD(Markdown.Code("julia", def))
	else
		Text(join(lines, '\n'))
	end
end

# ╔═╡ 269d092d-0114-445f-8e0c-0a85ef4b5dbe
md"""
You can then use the `@less` macro to get function definitions:

```julia
@less any_function()
```

Example:
"""

# ╔═╡ baf98a10-a541-4f67-ac50-60dbf95f9927
@less first(1:10)

# ╔═╡ 674ecc1c-5999-4327-b087-4b553d98b5d9
@less map(sqrt, [1,2,3])

# ╔═╡ cce97156-3292-4d75-ae6b-3cee986cdf98
@less Base.@pure identity

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╟─77423e98-b580-11ec-3aaa-131342d1510d
# ╠═d1928a6f-c564-4ace-a1e0-7789d6f65e28
# ╟─269d092d-0114-445f-8e0c-0a85ef4b5dbe
# ╠═baf98a10-a541-4f67-ac50-60dbf95f9927
# ╠═674ecc1c-5999-4327-b087-4b553d98b5d9
# ╠═cce97156-3292-4d75-ae6b-3cee986cdf98
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
