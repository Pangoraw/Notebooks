### A Pluto.jl notebook ###
# v0.19.6

using Markdown
using InteractiveUtils

# ╔═╡ ffe10202-04d0-41a0-8cde-dd9fe46c4e59
md"""
# Cohen's Kappa score

```math
\kappa = \frac{p_0 - p_e}{1 - p_e}
```

```math
p_e = \frac 1{N^2}\sum_k n_{k1}n_{k2}
```
"""

# ╔═╡ 1efc1b34-ebf2-11ec-04f5-315c43e9338e
function kappa_score(y1, y2, n_categories)
	@assert length(y1) == length(y2)

	n_observations = length(y1)

	pₑ = 0.
	for i in 1:n_categories
		pₑ += count(y1 .== i) * count(y2 .== i)
	end
	pₑ /= n_observations ^ 2
	pₒ = count(y1 .== y2) / n_observations 

	(pₒ - pₑ) / (1 - pₑ)
end

# ╔═╡ 50727c67-86e8-4ed6-88a5-7880b9a597d4
kappa_score(y1, y2) =
	kappa_score(y1, y2, length(unique(union(y1, y2))))

# ╔═╡ 063e664a-9b0d-4cf1-9b5f-1ec925a55353


# ╔═╡ fe3e9afa-fbc0-45db-ba0f-03f2ff6d857f
kappa_score([2, 1, 1], [2, 2, 1])

# ╔═╡ c737a28b-2d90-4298-ac8e-91390ef43478
kappa_score([2, 1], [1, 2])

# ╔═╡ 649bde36-c7d6-4f6d-ba98-44cd16419bde
md"""
### An online version 🌜
"""

# ╔═╡ 216cfb08-1159-4e69-ab34-bcfcfd7d3f6c
Base.@kwdef mutable struct KappaCoefficient
	n_classes::Int

	n_agreed::Int = 0
	n_observations::Int = 0
	preds::Matrix{Int} = zeros(Int, n_classes, 2)
end

# ╔═╡ 426b93da-bdfd-4ef7-a076-2e6ca773be00
function update!(κ::KappaCoefficient, y1, y2)
	@assert(length(y1) == length(y2))

	κ.n_observations += length(y1)
	κ.n_agreed += count(y1 .== y2)
	for cls in 1:κ.n_classes
		κ.preds[cls,:] .+= [count(y1 .== cls), count(y2 .== cls)]
	end

	return κ.n_observations
end

# ╔═╡ 8ef1af36-9d02-4c8e-9663-22517ea95718
function value(κ::KappaCoefficient)
	pₒ = κ.n_agreed / κ.n_observations
	pₑ = sum(prod, eachrow(κ.preds)) / (κ.n_observations ^ 2)

	return (pₒ - pₑ) / (1 - pₑ)
end

# ╔═╡ e4f625cd-f846-4fba-843c-3ffc4a4c563a
let
	N = 20
	y1 = rand(1:10, N)
	y2 = rand(1:10, N)

	y11, y12 = @view(y1[begin:N÷2]), @view(y1[N÷2+1:end])
	y21, y22 = @view(y2[begin:N÷2]), @view(y2[N÷2+1:end])

	κ = kappa_score(y1, y2)
	κ2 = KappaCoefficient(n_classes = 10)

	update!(κ2, y11, y21)
	update!(κ2, y12, y22)

	κ, value(κ2)
end

# ╔═╡ cd6a99f3-8676-4a8d-9575-3b3c3499dcce
let
	κ = KappaCoefficient(n_classes = 2)

	update!(κ, [2], [2])
	update!(κ, [1], [2])
	update!(κ, [1], [1])

	value(κ)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╟─ffe10202-04d0-41a0-8cde-dd9fe46c4e59
# ╠═1efc1b34-ebf2-11ec-04f5-315c43e9338e
# ╠═50727c67-86e8-4ed6-88a5-7880b9a597d4
# ╠═063e664a-9b0d-4cf1-9b5f-1ec925a55353
# ╠═fe3e9afa-fbc0-45db-ba0f-03f2ff6d857f
# ╠═c737a28b-2d90-4298-ac8e-91390ef43478
# ╠═e4f625cd-f846-4fba-843c-3ffc4a4c563a
# ╟─649bde36-c7d6-4f6d-ba98-44cd16419bde
# ╠═cd6a99f3-8676-4a8d-9575-3b3c3499dcce
# ╠═216cfb08-1159-4e69-ab34-bcfcfd7d3f6c
# ╠═426b93da-bdfd-4ef7-a076-2e6ca773be00
# ╠═8ef1af36-9d02-4c8e-9663-22517ea95718
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
