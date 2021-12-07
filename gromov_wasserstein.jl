### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 557b43a4-1173-4f6a-8e9c-cd0b6735a739
using BenchmarkTools

# ╔═╡ 42a0dcee-578e-11ec-2fb4-ab782a16e058
md"""
# Gromov-Wasserstein Averaging of Kernel and Distance Matrices

> [1]G. Peyré, M. Cuturi, et J. Solomon, « Gromov-Wasserstein Averaging of Kernel and Distance Matrices », in Proceedings of The 33rd International Conference on Machine Learning, juin 2016, p. 2664‑2672. Consulté le: déc. 07, 2021. [En ligne]. Disponible sur: https://proceedings.mlr.press/v48/peyre16.html

Given two distance matrices, $C$ and $\bar C$, the Gromov-Wasserstein discrepancy between the two similarity matrices is:

```math
GW(C,\hat C, p,q) = \min_{T\in\mathcal C_{p,q}} \mathcal E_{C,\bar C}(T)
```
```math
\text{where}\quad \mathcal E_{C,\bar C}(T) = \sum_{i,j,k,l}(C_{i,k},\bar C_{j,l})T_{i,j}T_{k,l}
```

Considering the 4-dimensions tensor:

```math
\mathcal L(C,\bar C) = (L(C_{i,k},\bar C_{j,l}))_{i,j,k,l}
```

We notice that:

```math
\mathcal E_{C,\bar C}(T) = \langle\mathcal L(C,\bar C)\otimes T,T\rangle
```
If the loss can be written as:

```math
L(a,b) = f_1(a) + f_2(b) - h_1(a)h_2(b)
```
then, for any $T\in\mathcal C_{p,q}$:

```math
\mathcal L(C,\bar C)\otimes T = c_{C,\bar C} - h_1(C) T h_2(\bar C)
```

with 

```math
c_{C,\bar C} = f_1(C)p\mathbf 1_{N_2}^\top + \mathbf 1_{N_1}q^\top f_2(\bar C)^\top
```

### Demonstration
"""

# ╔═╡ c70dfd98-0077-4d2c-ba0b-5c0e750734b3
@benchmark naive_l²(X1, X2, γ)

# ╔═╡ e1d44ae2-5baa-489b-bc25-7462eaad3ee1
@benchmark LCC̄ ⊗ γ

# ╔═╡ eea63005-a223-461d-8962-00d646b6f571
begin
	n₁, d₁ = 3, 10
	n₂, d₂ = 5, 20

	X1 = rand(d₁, n₁)
	X2 = rand(d₂, n₂)
end;

# ╔═╡ 922a9737-ecc9-4d27-9ba1-658bd96f9bfe
function naive_l²(X1, X2, γ)
	l²(a, b) = (a - b)^2
	d₁, n₁ = size(X1)
	d₂, n₂ = size(X2)

	Δ = zeros(d₁, d₂, n₁, n₂)
	for i in 1:d₁,
		j in 1:d₂
		for k in 1:n₁,
			l in 1:n₂

			Δ[i,j,k,l] = l²(X1[i,k], X2[j,l]) * γ[k,l]
		end
	end

	reshape(sum(Δ; dims=(3,4)), d₁, d₂)
end

# ╔═╡ f5d2e6d1-1928-45c8-883d-18d37ba4b690
md"""
### Implementation
"""

# ╔═╡ 55118087-bfd3-4d6e-a2d6-97de71f97a02
struct PlanCache{M<:AbstractMatrix}
	c::M
	h₁C::M
	h₂C̄::M
end

# ╔═╡ 54d270da-c2fc-45c7-b9bb-44f4aea5bb75
pc::PlanCache ⊗ T::AbstractMatrix = pc.c - pc.h₁C * T * pc.h₂C̄'

# ╔═╡ f7b171be-09b8-4489-bb55-55d62d9caf51
unif(n) = ones(n) ./ n

# ╔═╡ 0c84fbcc-7032-41eb-81d6-88c7696d7709
function L²(C, C̄, v = unif(size(C, 2)), v̄ = unif(size(C̄, 2)))
	f₁(a) = a^2
	f₂(b) = b^2
	h₁(a) = a
	h₂(b) = 2b

	c = f₁.(C) * v * ones(size(C̄, 1))' +
		ones(size(C, 1)) * v̄' * f₂.(C̄)' # (d₁, d₂)
	h₁C = h₁.(C)
	h₂C̄ = h₂.(C̄)

	PlanCache(c, h₁C, h₂C̄)
end

# ╔═╡ dbc9425b-344d-48a2-8585-40f5dfbe35ac
begin
	γ = unif(n₁) * unif(n₂)'
	LCC̄ = L²(X1, X2)

	LCC̄ ⊗ γ |> size
end

# ╔═╡ c348dd48-c896-46ae-94e9-123bb9e7908b
naive_l²(X1, X2, γ) ≈ LCC̄ ⊗ γ

# ╔═╡ 4187c521-dd09-4838-a5ee-f4bc887e5f34
md"""
### Packages
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"

[compat]
BenchmarkTools = "~1.2.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "365c0ea9a8d256686e97736d6b7fb0c880261a7a"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
"""

# ╔═╡ Cell order:
# ╟─42a0dcee-578e-11ec-2fb4-ab782a16e058
# ╠═c348dd48-c896-46ae-94e9-123bb9e7908b
# ╠═c70dfd98-0077-4d2c-ba0b-5c0e750734b3
# ╠═e1d44ae2-5baa-489b-bc25-7462eaad3ee1
# ╠═eea63005-a223-461d-8962-00d646b6f571
# ╠═dbc9425b-344d-48a2-8585-40f5dfbe35ac
# ╠═922a9737-ecc9-4d27-9ba1-658bd96f9bfe
# ╟─f5d2e6d1-1928-45c8-883d-18d37ba4b690
# ╠═55118087-bfd3-4d6e-a2d6-97de71f97a02
# ╠═0c84fbcc-7032-41eb-81d6-88c7696d7709
# ╠═54d270da-c2fc-45c7-b9bb-44f4aea5bb75
# ╠═f7b171be-09b8-4489-bb55-55d62d9caf51
# ╟─4187c521-dd09-4838-a5ee-f4bc887e5f34
# ╠═557b43a4-1173-4f6a-8e9c-cd0b6735a739
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
