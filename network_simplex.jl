### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ d29bbd55-4b0c-4fa0-8bd7-d9b85d7d7a10
using LinearAlgebra

# ╔═╡ c8cd4eff-8702-42a2-8b40-8a789ea4a37f
using PlutoTest, PlutoUI

# ╔═╡ 1ba4e1d2-a260-4f48-866c-821e53c30506
md"""
# The Network Simplex

This is a textbook implementation of the Network Simplex algorithm from the book "Computational Optimal Transport".
"""

# ╔═╡ 65dd721e-20aa-4a2b-abb4-46f04d922aee
md"""
## The North-West Corner rule
"""

# ╔═╡ 187de006-8830-11ec-3fb7-297fcaedd55e
"""
	north_west(μ, ν)

Finds an initial transport plan that respect the marginal constraints \$(\\mu,\\nu)\$.
"""
function north_west(μ, ν)
	P = zeros(eltype(μ), (length(μ), length(ν)))
	G = falses((length(μ), length(ν)))
	i, j = 1, 1
	r, c = μ[i], ν[j]
	while i <= length(μ) && j <= length(ν)
		P[i, j] = t = min(r, c)
		G[i, j] = t > 0
		r -= t
		c -= t
		if r == 0
			i += 1
			if i <= length(μ)
				r = μ[i]
			end
		elseif c == 0
			j += 1
			if j <= length(ν)
				c = ν[j]
			end
		end
	end
	P, G
end

# ╔═╡ 1030d263-d188-49d0-b9da-5d02810bba9b
let
	P = [
		.2 0. 0.
		.3 .1 .1
		0. 0. .3
	]
	μ, ν = [.2, .5, .3], [.5, .1, 4]
	@test north_west(μ, ν)[1] == P
end

# ╔═╡ 3e4a5f6d-d4ef-4372-9762-388b92f0755b
md"""
## Obtaining a Dual Pair Complementary to P
"""

# ╔═╡ 32b4c5a4-f5e4-457d-b09d-531215fda61b
"""
Tries to find a feasible solution \$(f, g)\$ to the dual problem given a plan \$P\$.

 - `G` (the graph associated with the transport plan) is an adjacency matrix of the bi-partite network.
 - `C` is the cost matrix
"""
function find_feasible_dual(G, C)
	f = zeros(eltype(C), size(C, 1))
	g = zeros(eltype(C), size(C, 2))

	explored = Set{Int}()

	nμ = size(C, 1)
	function dfs(i)
		i ∈ explored && return
		push!(explored, i)

		if i > nμ # i is in g
			i -= nμ
			neighbors = findall(@view G[:,i])
			for j in neighbors
				j ∈ explored && continue
				
				f[j] = C[j,i] - g[i]
				dfs(j)
			end
		else # i is in f
			neighbors = findall(@view G[i,:])
			for j in neighbors
				(j + nμ) ∈ explored && continue

				g[j] = C[i,j] - f[i] 
				dfs(j + nμ)
			end
		end
	end

	for i in 1:nμ
		dfs(i)
	end
		
	f, g
end

# ╔═╡ fff3fe40-b944-46ed-aea1-3d550ed5fbb0
"""
	find_suboptimal_edge(f, g, C)::Union{Nothing,CartesianIndex}

Returns the position of an existing suboptimal edge.
"""
function find_suboptimal_edge(f, g, C)
	for i in eachindex(f),
		j in eachindex(g)

		@inbounds if f[i] + g[j] - C[i, j] > 1e-14
			return CartesianIndex(i, j)
		end
	end
	nothing
end

# ╔═╡ 9bef5380-7275-42de-99cc-597aa72b0abc
md"""
# Graph & Cycle detection
"""

# ╔═╡ aac9efe0-d6a1-4587-99ec-46e0f1411c85
function collect_cycle(G, P, edge)
	n = size(G, 1)

	costs = Float64[]
	indices = CartesianIndex[]

	stack = Int[]
	explored = Set{Int}()
	
	function dfs(i)
		if false && i ∈ explored
			return false
		end
		if i ∈ stack
			return true
		end

		parent = isempty(stack) ? -1 : stack[end]
		push!(stack, i)

		if i > n
			for j in findall(@view G[:,i-n])
				if j == parent
					# pass
				elseif dfs(j)
					idx = CartesianIndex(j,i-n)
					push!(indices, idx)
					push!(costs, P[idx])
					return true
				end
			end
		else
			for j in findall(@view G[i,:])
				if j+n == parent
					# pass
				elseif dfs(j + n)
					idx = CartesianIndex(i,j)
					push!(indices, idx)
					push!(costs, P[idx])
					return true
				end
			end
		end

		pop!(stack)
		push!(explored, i)

		return false
	end

	if dfs(edge[1])
		indices, costs
	else
		nothing
	end
end

# ╔═╡ e7aea362-3595-45d2-bb0a-512e241c17bc
collect_cycle(
	Bool.([
		1 0 1
		0 0 0
		1 0 1
	]),
	[
		1.1 0 1.2
		0 0 0
		1 0 1
	],
	CartesianIndex(1, 1),
)

# ╔═╡ 1ee92bf4-835f-4c62-9bd5-5d96a86e9d8b
let
	na = 2
	nb = na = 3
	a = fill(1/na, na)
	b = fill(1/nb, nb)
	C = Matrix{Float64}(I, na, nb)

	P, G = north_west(a, b)
	f, g = find_feasible_dual(G, C)

	edge = find_suboptimal_edge(f, g, C)
	edge, f, g, f[edge[1]], g[edge[2]], C[edge]
end

# ╔═╡ 96ab200e-603d-4c87-9cc1-c37dbda6ace4
let
	G = Bool.([
		 0  1  1
		 1  0  1
		 1  0  1
	])
	P = [
		 0.0       0.333333  0.0
		 0.333333  0.0       0.0
		 0.0       0.0       0.333333
	]

	collect_cycle(G, P, CartesianIndex(2, 3))
end

# ╔═╡ a05afd19-3bae-4479-b8f0-86f373094113
import OptimalTransport, GLPK, BenchmarkTools

# ╔═╡ c147499e-bb03-428a-8acf-49722fd54c7e
md"""
# Putting it all together...
"""

# ╔═╡ aa5810ed-b4a0-41fa-bdfd-95df64edf677
function emd(a, b, C)
	# Initialize
	P, G = north_west(a, b)

@label dual

	# Find feasible dual pair
	f, g = find_feasible_dual(G, C)

	# Is there a sub-optimal edge ?
	edge = find_suboptimal_edge(f, g, C)

	# 3.5.2 Network Simplex update

	# We have reached the optimum
	if isnothing(edge)
		return P
	end

	# Add the violating edge
	G[edge] = true

	cycle = collect_cycle(G, P, edge)
		
	# Two cases can then arise:
	if isnothing(cycle)
		# (a) G is (still) a forest
		@goto dual
	else
		# (b) G now has a cycle
		indices, costs = cycle

		# Sub-optimal edge is either at the beginning or end of the
		# cycle.
		@assert indices[end] == edge || indices[begin] == edge

		k⃰ = if indices[end] == edge
			k = argmin(@view costs[begin:2:end])
			1 + (k - 1) * 2
		elseif indices[begin] == edge
			k = argmin(@view costs[begin+1:2:end])
			2k
		end
		θ = costs[k⃰]

		arity = k⃰ % 2
		for (i, idx) in enumerate(indices)
			if i % 2 == arity
				P[idx] -= θ
			else
				P[idx] += θ
			end
		end

		# We then close the update by removing (iₖ⭑₊₁, jₖ⭑) from G
		G[indices[k⃰]] = false
		@assert P[indices[k⃰]] == 0.

		@goto dual
	end
end

# ╔═╡ b73c42fd-7a52-45d0-b9a3-ede4dcc61e36
let
	C = [
		0 1 1
		1 0 1
		1 1 2
	]
	emd([1/4, 1/4, 1/2], [1/3, 1/3, 1/3], C)
end

# ╔═╡ 521f7c7a-823d-4873-8484-66c17825b966
md"""
## OptimalTransport.jl API
"""

# ╔═╡ 4b2c7693-7873-42b3-85d3-79712fee730d
function emd2(μ, ν, C)
	γ = emd(μ, ν, C)
	sum(γ .* C)
end

# ╔═╡ 3be07e02-b95f-44a2-9491-f39a1a1c2617
let
	na = 3
	nb = 3
		
	a = fill(1/na, na)
	b = fill(1/nb, nb)
	C = randn(na, nb)

	emd2
	b1 = @BenchmarkTools.benchmark emd2($a,$b,$C)
	b2 = @BenchmarkTools.benchmark OptimalTransport.emd2($a, $b, $C, GLPK.Optimizer())
	
	[b1,b2]
end

# ╔═╡ 616cfde6-190b-403b-8d1c-da2f4eb385ad
for _ in 1:3
	na = 20
	nb = 20
	a = fill(1/na, na)
	b = fill(1/nb, nb)
	C = randn(na, nb)

	c1 = emd2(a,b,C)
	c2 = OptimalTransport.emd2(a, b, C, GLPK.Optimizer())

	@assert c1 ≈ c2
end

# ╔═╡ cb5ecc78-6ffc-44ea-94cd-d80d8b079423
md"""
#### Packages
"""

# ╔═╡ 5584d358-eab9-48fa-a880-62080674df12
TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
GLPK = "60bf3e95-4087-53dc-ae20-288a0d20c6a6"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
OptimalTransport = "7e02d93a-ae51-4f58-b602-d97af76e3b33"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.2"
GLPK = "~1.1.0"
OptimalTransport = "~0.3.19"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "16666934c49e7d62cdc86dc4a5bb58fec909cdfa"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "9a95659c283c9018ea99e017aa9e13b7e89fadd2"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "bee795cdeabc7601776abbd6b9aac2ca62429966"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.77"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.ExactOptimalTransport]]
deps = ["Distances", "Distributions", "FillArrays", "LinearAlgebra", "MathOptInterface", "PDMats", "QuadGK", "SparseArrays", "StatsBase"]
git-tree-sha1 = "abf7262468e90e71ca51289c4fcff91e0a919db5"
uuid = "24df6009-d856-477c-ac5c-91f668376b31"
version = "0.2.3"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.GLPK]]
deps = ["GLPK_jll", "MathOptInterface"]
git-tree-sha1 = "e357b935632e89a02cf7f8f13b4f3f59cef479c8"
uuid = "60bf3e95-4087-53dc-ae20-288a0d20c6a6"
version = "1.1.0"

[[deps.GLPK_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "fe68622f32828aa92275895fdb324a85894a5b1b"
uuid = "e8aa6df9-e6ca-548a-97ff-1f85fc5b8b98"
version = "5.0.1+0"

[[deps.GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"
version = "6.2.1+2"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterativeSolvers]]
deps = ["LinearAlgebra", "Printf", "Random", "RecipesBase", "SparseArrays"]
git-tree-sha1 = "1169632f425f79429f245113b775a0e3d121457c"
uuid = "42fd0dbc-a981-5370-80f2-aaf504508153"
version = "0.9.2"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "ceed48edffe0325a6e9ea00ecf3607af5089c413"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.9.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "1d57a7dc42d563ad6b5e95d7a8aebd550e5162c0"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.0.5"

[[deps.NNlib]]
deps = ["Adapt", "ChainRulesCore", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "00bcfcea7b2063807fdcab2e0ce86ef00b8b8000"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.8.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OptimalTransport]]
deps = ["ExactOptimalTransport", "IterativeSolvers", "LinearAlgebra", "LogExpFunctions", "NNlib", "Reexport"]
git-tree-sha1 = "79ba1dab46dfc7b677278ebe892a431788da86a9"
uuid = "7e02d93a-ae51-4f58-b602-d97af76e3b33"
version = "0.3.19"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "d12e612bba40d189cead6ff857ddb67bd2e6a387"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─1ba4e1d2-a260-4f48-866c-821e53c30506
# ╟─65dd721e-20aa-4a2b-abb4-46f04d922aee
# ╠═187de006-8830-11ec-3fb7-297fcaedd55e
# ╠═1030d263-d188-49d0-b9da-5d02810bba9b
# ╟─3e4a5f6d-d4ef-4372-9762-388b92f0755b
# ╟─32b4c5a4-f5e4-457d-b09d-531215fda61b
# ╟─fff3fe40-b944-46ed-aea1-3d550ed5fbb0
# ╟─9bef5380-7275-42de-99cc-597aa72b0abc
# ╠═e7aea362-3595-45d2-bb0a-512e241c17bc
# ╠═aac9efe0-d6a1-4587-99ec-46e0f1411c85
# ╠═1ee92bf4-835f-4c62-9bd5-5d96a86e9d8b
# ╠═96ab200e-603d-4c87-9cc1-c37dbda6ace4
# ╠═a05afd19-3bae-4479-b8f0-86f373094113
# ╠═3be07e02-b95f-44a2-9491-f39a1a1c2617
# ╠═616cfde6-190b-403b-8d1c-da2f4eb385ad
# ╠═b73c42fd-7a52-45d0-b9a3-ede4dcc61e36
# ╟─c147499e-bb03-428a-8acf-49722fd54c7e
# ╠═aa5810ed-b4a0-41fa-bdfd-95df64edf677
# ╟─521f7c7a-823d-4873-8484-66c17825b966
# ╠═4b2c7693-7873-42b3-85d3-79712fee730d
# ╟─cb5ecc78-6ffc-44ea-94cd-d80d8b079423
# ╠═5584d358-eab9-48fa-a880-62080674df12
# ╠═d29bbd55-4b0c-4fa0-8bd7-d9b85d7d7a10
# ╠═c8cd4eff-8702-42a2-8b40-8a789ea4a37f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
