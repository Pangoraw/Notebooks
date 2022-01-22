### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ 841992ca-540e-44fe-86ee-f5e11413971a
using PlutoHooks: @use_state, @use_ref, @use_effect

# ╔═╡ af2e6584-8ac0-4b84-b7f1-a15ca80781af
using Observables

# ╔═╡ 94bda2ea-31d7-4e8c-89f3-8ca96583b9ff
md"""
## Pluto.jl + Observables.jl
"""

# ╔═╡ ce730525-8df5-4337-a015-86abec8c4249
"""
Returns an Observable(val) and trigger a reactive run from the cell at which it is called every time the value of the observable is set.


```julia
# Cell 1
my_observable = @observable(1)

# Cell 2
my_observable[] # 1 then 2

# Cell 3
if my_observable[] == 1
	sleep(1.)
	my_observable[] = 2
end
```
"""
macro observable(val)
	quote
		# @use_state(value) returns the reference and an update function
		_, rerun = @use_state(nothing)

		# @use_ref(value) gives a RefValue{Any}(value) persistent across
		# indirect cell re-runs
		obs = @use_ref(Observable($(esc(val))))

		# Add observer only when it is created (without @use_effect) it
		# will be added every time.
		@use_effect([]) do
			on(obs[]) do _
				@info "got new value"
				rerun(nothing)
			end

			nothing
		end

		# Unwrap the Observable object of the RefValue
		obs[]
	end
end

# ╔═╡ c7214a8f-e6d8-4d79-b8d9-2c40c1247f8d
md"""
### Example
"""

# ╔═╡ 5e929241-cbc2-4aaf-8e13-4f02d34b91f2
obs = @observable(1)

# ╔═╡ 5f46d724-58a9-4dc3-a711-2891a8db18f6
# Note that this can trigger an infinite update loop
# if there are no conditions on the value of obs[]
if obs[] == 1
	obs[] = 2
end

# ╔═╡ b45372c9-84af-4587-a5a3-bb3e21b7d2e8
obs

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Observables = "510215fc-4207-5dde-b226-833fc4488ee2"
PlutoHooks = "0ff47ea0-7a50-410d-8455-4348d5de0774"

[compat]
Observables = "~0.4.0"
PlutoHooks = "~0.0.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.PlutoHooks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "f297787f7d7507dada25f6769fe3f08f6b9b8b12"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.3"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ Cell order:
# ╟─94bda2ea-31d7-4e8c-89f3-8ca96583b9ff
# ╠═841992ca-540e-44fe-86ee-f5e11413971a
# ╠═af2e6584-8ac0-4b84-b7f1-a15ca80781af
# ╠═ce730525-8df5-4337-a015-86abec8c4249
# ╟─c7214a8f-e6d8-4d79-b8d9-2c40c1247f8d
# ╠═5e929241-cbc2-4aaf-8e13-4f02d34b91f2
# ╠═5f46d724-58a9-4dc3-a711-2891a8db18f6
# ╠═b45372c9-84af-4587-a5a3-bb3e21b7d2e8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
