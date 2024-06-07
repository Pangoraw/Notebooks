### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# ╔═╡ 43479c04-54dd-44f0-93dc-4740efa9efa9
using HypertextLiteral

# ╔═╡ 19ba12f8-226a-4eea-a45e-6b8c95ae30d2
struct Tikz
	s::String
end

# ╔═╡ a4555b43-9d5f-425e-8d1e-ea383a2a8c5a
function Base.show(io::IO, ::MIME"text/html", t::Tikz)
	write(io, raw"""
	<div>
		<script src="https://tikzjax.com/v1/tikzjax.js"></script>
		<link rel="stylesheet" type="text/css" href="https://tikzjax.com/v1/fonts.css">
		<script>
			window.onload()
		</script>
		<script type="text/tikz">""")
	write(io, t.s)
	write(io, raw"""
		</script>
	</div>""")
end

# ╔═╡ 75b5c78d-2c1b-497d-a0b3-a4ece2744e9a
macro tikz_str(s)
	Tikz(s)
end

# ╔═╡ 700d01b4-139f-4c80-a4b6-6e4da7b490c8
Tikz(raw"""
\begin{tikzpicture}
	\draw (0,0) circle (1in);
\end{tikzpicture}
""")

# ╔═╡ af50bb7d-2092-4aac-a8e6-904be6b076b3
tikz"""
\begin{tikzpicture}
	\node[circle, dashed, draw, inner sep = 0.5in] (x) at (0,0) {};
\end{tikzpicture}
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0-beta3"
manifest_format = "2.0"
project_hash = "12b2e5dab6bc229d7692234b6b2202f7e3ec539c"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"
"""

# ╔═╡ Cell order:
# ╠═43479c04-54dd-44f0-93dc-4740efa9efa9
# ╠═a4555b43-9d5f-425e-8d1e-ea383a2a8c5a
# ╠═19ba12f8-226a-4eea-a45e-6b8c95ae30d2
# ╠═75b5c78d-2c1b-497d-a0b3-a4ece2744e9a
# ╠═700d01b4-139f-4c80-a4b6-6e4da7b490c8
# ╠═af50bb7d-2092-4aac-a8e6-904be6b076b3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
