### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ 5a1e5c3b-7c20-45f2-a1ca-a46dae655890
using PlutoTest

# ╔═╡ 1dec7ac1-9c36-469b-9ca4-ce2c26eeb186
md"""
## A Simple testset implementation
While waiting for [PlutoTest#17](https://github.com/JuliaPluto/PlutoTest.jl).
"""

# ╔═╡ cd98fda5-d809-415f-bfe0-2ec588cffed6
import Test

# ╔═╡ 80cb9f90-d447-4931-a28c-f5ef738c8009
function testset_block(name, block)
	results = []

	explore_expr(other) = other
	function explore_expr(ex::Expr)
		if !Meta.isexpr(ex, :macrocall) ||
			ex.args[1] ∉ (Symbol("@test"), Symbol("@testset"))
			
			map!(explore_expr, ex.args, ex.args)
			return ex
		end
		new_name = gensym(:result)
		intermediate_result = gensym(:intermediate)
		push!(results, new_name)
		Expr(:let, Expr(:(=), intermediate_result, ex), 
			Expr(:block, Expr(:call, :push!, new_name, intermediate_result),
			intermediate_result))
	end

	block = explore_expr(block)
	preamble = map(r -> :(local $r = []) |> esc, results)
	
	quote
		$(preamble...)
		$(esc(block))
		TestSet($(esc(name)), $(esc(Expr(:vect, results...))))
	end
end

# ╔═╡ 6a7ab98b-5fa2-46df-9da5-a67a8bdb5f16
function testset_forloop(name, ex)
	@assert Meta.isexpr(ex, :for)

	results = []

	explore_expr(other) = other
	function explore_expr(ex::Expr)
		if !Meta.isexpr(ex, :macrocall) ||
			ex.args[1] ∉ (Symbol("@test"), Symbol("@testset"))
			
			map!(explore_expr, ex.args, ex.args)
			return ex
		end
		new_name = gensym(:result)
		intermediate_result = gensym(:intermediate)
		push!(results, new_name)
		Expr(:let, Expr(:(=), intermediate_result, ex), 
			Expr(:block, Expr(:call, :push!, new_name, intermediate_result),
			intermediate_result))
	end

	
	ex.args[1] = esc(ex.args[1])
	ex.args[2] = Expr(:block,
		esc(explore_expr(ex.args[2])),
		quote
			push!(testsets, TestSet($(esc(name)), $(esc(Expr(:vect, results...)))))
		end
	)

		preamble = map(r -> :(local $r = []) |> esc, results)

	quote
		testsets = []
		$(preamble...)
		$(ex)

		TestSet("", map(a -> [a], testsets))
	end
end

# ╔═╡ c4278ff9-b8b3-41df-880c-a78b375aaa29
macro testset(name, ex)
	if !startswith(string(nameof(__module__)), "workspace#")
		return quote
			Test.@testset($name, $block)
		end
	end

	if Meta.isexpr(ex, :for)
		testset_forloop(name, ex)
	elseif Meta.isexpr(ex, :block)
		testset_block(name, ex)
	else
		error("Expected begin/end block or for loop as argument to @testset")
	end
end

# ╔═╡ 1b7aa570-5170-4ec6-a7f8-8bb3dffc4c2f
struct TestSet
	name::String
	results::Vector
end

# ╔═╡ f36ff584-1dc8-4908-b726-be9c900e44e0
function Base.show(io::IO, m::MIME"text/html", ts::TestSet)
	text = md"""
	###### $(ts.name)
	"""
	show(io, m, text)
	for results in ts.results
		write(io, "<div style=\"margin-left: 10px;\">")
		for result in results
			show(io, m, result)
		end
		write(io, "</div>")
	end
end

# ╔═╡ 50f61047-6e0c-4723-beb2-038de356802d
md"""
## Playground
"""

# ╔═╡ a54e7bb6-2475-42ca-9c09-0fc6157b693a
@testset "Test set name" begin
	@test 1 + 1 == 2

	@test cos(2π) == 1.
	@test 6.28 == 2π

end

# ╔═╡ c5c065ee-eb0b-43bc-a70f-eede89db804f
@testset "A nested testset" begin
	@testset "Sinus" begin
		@test sqrt(4.) == 2
	end

	@testset "Cosinus" begin
		@test 3rand() > 1.5
	end
end

# ╔═╡ 1490a8b0-36aa-41b7-b5d8-54b7613b8fd7
@testset "For loop" begin
	s = 0
	for i in 1:3
		@test i % 2 == 0
		s += i
	end

	@test s == 3 + 2 + 1
end

# ╔═╡ 9dec45bb-8a9e-40fe-afe8-03eaf3751621
@testset "A loopy testset" begin
	@testset "A test $value" for value in [1, 2]
		@test value == 1
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
PlutoTest = "~0.2.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ Cell order:
# ╟─1dec7ac1-9c36-469b-9ca4-ce2c26eeb186
# ╠═cd98fda5-d809-415f-bfe0-2ec588cffed6
# ╠═5a1e5c3b-7c20-45f2-a1ca-a46dae655890
# ╠═c4278ff9-b8b3-41df-880c-a78b375aaa29
# ╠═80cb9f90-d447-4931-a28c-f5ef738c8009
# ╠═6a7ab98b-5fa2-46df-9da5-a67a8bdb5f16
# ╠═1b7aa570-5170-4ec6-a7f8-8bb3dffc4c2f
# ╠═f36ff584-1dc8-4908-b726-be9c900e44e0
# ╟─50f61047-6e0c-4723-beb2-038de356802d
# ╠═a54e7bb6-2475-42ca-9c09-0fc6157b693a
# ╠═c5c065ee-eb0b-43bc-a70f-eede89db804f
# ╠═1490a8b0-36aa-41b7-b5d8-54b7613b8fd7
# ╠═9dec45bb-8a9e-40fe-afe8-03eaf3751621
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
