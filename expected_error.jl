### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 305e531d-dca2-4ba1-a1e3-25c44c93fd7f
domain_func() = throw(DomainError("Something went wrong"))

# ╔═╡ 03625ed2-17b8-428a-abc5-5f0e8dc1aac6
md"""
---
"""

# ╔═╡ ca58b6dc-a98a-445a-acc0-afc7f0d5f358
macro expect_error(code, error=:DomainError)
	quote
		try
			$(esc(code))
		catch e
			if e isa $(esc(error))
				pretty_error(e)
			else
				rethrow()
			end
		end
	end
end

# ╔═╡ 43dfd6d2-4a09-11ed-3187-fd8e22bb1706
function pretty_error(err) 
	Markdown.parse("""
	!!! danger "Expected error"
		`$(replace(sprint(showerror, err), "\n" => ""))`
	""")
end

# ╔═╡ 4d4329c5-d365-419d-bfc8-da0fc7b21b58
@expect_error domain_func()

# ╔═╡ caae85d8-f7ba-4dcb-a4ed-7fe6d30e6024
@expect_error [1,2][3] BoundsError

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═4d4329c5-d365-419d-bfc8-da0fc7b21b58
# ╠═caae85d8-f7ba-4dcb-a4ed-7fe6d30e6024
# ╠═305e531d-dca2-4ba1-a1e3-25c44c93fd7f
# ╟─03625ed2-17b8-428a-abc5-5f0e8dc1aac6
# ╠═ca58b6dc-a98a-445a-acc0-afc7f0d5f358
# ╠═43dfd6d2-4a09-11ed-3187-fd8e22bb1706
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
