### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 235e2cfe-d1aa-4039-bfbb-e633228d31c3
using LinearAlgebra

# ╔═╡ dd21de35-ed04-4ab2-ae44-5c6646e663bd
Y = [1., -1.] .+ 2randn((2, 4))

# ╔═╡ 7c797ec4-6e1f-4dd9-b420-d09ab9640a22
X = [-1., 1.] .+ randn((2,4))

# ╔═╡ 0b33c6b3-bfbb-4c2e-b827-80dcf30474d7
struct Line
	offset::Float64
	grow::Float64
end

# ╔═╡ 7b35acb7-c801-404e-955b-9dfdc1a4c6f4
rad2line(θ) = Line(0., tan(θ))

# ╔═╡ 4f4c55c4-d08a-4c77-914e-7da96822600b
pθline(p, θ) = begin
	grow = tan(θ)
	offset = p[2] - grow * p[1]
	Line(offset, grow)
end

# ╔═╡ 5b880caf-41fe-4766-9d07-963fb96e7295
function intersect(l1, l2)
	b₁, a₁ = l1.offset, l1.grow
	b₂, a₂ = l2.offset, l2.grow
	x = (b₂ - b₁) / (a₁ - a₂)
	(x, a₁ * x + b₁)
end

# ╔═╡ 073d14a9-0648-421a-836a-959c8bf0e342
scale = 3.5

# ╔═╡ c40d59fc-69b6-41e3-bf01-5d190a2682ae
θ = 1π / 4

# ╔═╡ c7946725-e010-4a5f-9f25-014ed18e544b
unit = [cos(θ) sin(θ)]'

# ╔═╡ 262bca4a-8a0a-4f59-b091-fa8244eebcaf
unit .* (unit ⋅ X[:,1])

# ╔═╡ 30a37497-277c-4b0e-a05e-1cf052724da4
sX, sY = let X′ = unit' * X
	Y′ = unit' * Y
	X′ = reshape(X′, :)
	Y′ = reshape(Y′, :)

	sortperm(X′),
	sortperm(Y′)
end

# ╔═╡ dfad3359-1aec-4fdb-be0b-19cf62de2447
line = rad2line(θ)

# ╔═╡ 1c7af635-6704-4dc2-8d42-305774220004
intersect(pθline(X[:,1],θ+π/2), line)

# ╔═╡ 1bc183c2-2a44-11ef-0eac-2960f710ad55
begin

struct Tikz
	s::String
end
	function Base.show(io::IO, ::MIME"text/html", t::Tikz)
	write(io, raw"""
	<div style="margin:10px;">
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
end

# ╔═╡ e22c1538-e6be-4951-bbb8-646dd7d89367
t = Tikz("""
\\definecolor{darkblueish}{RGB}{61,97,215}
\\definecolor{blueish}{RGB}{224,218,242}
\\definecolor{yellowish}{RGB}{233,234,184}
\\definecolor{redish}{RGB}{255,128,128}
\\definecolor{OliveGreen}{RGB}{109,113,46}
\\definecolor{ForestGreen}{RGB}{34,139,34}

\\begin{tikzpicture}

	
	\\draw[-latex] ($(-scale * cos(θ)), $(-scale * sin(θ))) -- ($(scale * cos(θ)), $(scale * sin(θ)));
	\\node[] (theta) at ($(scale * cos(θ) + .2), $(scale * sin(θ))) {\$\\theta\$};

	$(join(map(((i,x),) -> begin
		l = pθline(x,θ + π/2)
		newp = intersect(l, line)
		"\\node[circle, inner sep=2,fill=darkblueish] (x$i) at ($(x[1]), $(x[2])) {}; 
		 \\node[circle, inner sep=2,fill=darkblueish] (px$i) at ($(newp[1]), $(newp[2])) {};
		 \\draw[gray] (px$i) -- (x$i);
		"
	end, enumerate(eachcol(X)))))

	$(join(map(((i,x),) -> begin
		l = pθline(x,θ + π/2)
		newp = intersect(l, line)
		"\\node[circle, inner sep=2,fill=redish] (y$i) at ($(x[1]), $(x[2])) {}; 
		 \\node[circle, inner sep=2,fill=redish] (py$i) at ($(newp[1]), $(newp[2])) {};
		 \\draw[gray] (py$i) -- (y$i);
		"
	end, enumerate(eachcol(Y)))))

	$(join(map(((i,j),) -> begin

		"\\draw[-latex] (px$i) to [bend right] (py$j);"
	
	end, zip(sX, sY))))

\\end{tikzpicture}
""");

# ╔═╡ ec1e5b56-e1fe-4e66-a0ff-6bdb6dbd5bbb
t

# ╔═╡ cc9f5dc1-6c9f-4d84-ab69-066781995657
Markdown.parse("```\n$(t.s)\n```")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "ac1187e548c6ab173ac57d4e72da1620216bce54"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"
"""

# ╔═╡ Cell order:
# ╟─ec1e5b56-e1fe-4e66-a0ff-6bdb6dbd5bbb
# ╠═dd21de35-ed04-4ab2-ae44-5c6646e663bd
# ╠═7c797ec4-6e1f-4dd9-b420-d09ab9640a22
# ╠═c7946725-e010-4a5f-9f25-014ed18e544b
# ╠═262bca4a-8a0a-4f59-b091-fa8244eebcaf
# ╠═30a37497-277c-4b0e-a05e-1cf052724da4
# ╠═235e2cfe-d1aa-4039-bfbb-e633228d31c3
# ╠═1c7af635-6704-4dc2-8d42-305774220004
# ╠═e22c1538-e6be-4951-bbb8-646dd7d89367
# ╠═cc9f5dc1-6c9f-4d84-ab69-066781995657
# ╠═dfad3359-1aec-4fdb-be0b-19cf62de2447
# ╠═0b33c6b3-bfbb-4c2e-b827-80dcf30474d7
# ╠═7b35acb7-c801-404e-955b-9dfdc1a4c6f4
# ╠═4f4c55c4-d08a-4c77-914e-7da96822600b
# ╠═5b880caf-41fe-4766-9d07-963fb96e7295
# ╠═073d14a9-0648-421a-836a-959c8bf0e342
# ╠═c40d59fc-69b6-41e3-bf01-5d190a2682ae
# ╟─1bc183c2-2a44-11ef-0eac-2960f710ad55
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
