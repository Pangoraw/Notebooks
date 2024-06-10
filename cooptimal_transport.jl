### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# ╔═╡ bc43ee86-2727-11ef-3067-3f78a95bf8a5
import Pkg

# ╔═╡ 38c8db2c-a9bc-4c35-9e47-e513f4276d58
# ╠═╡ show_logs = false
Pkg.activate(;temp=true); Pkg.add(url="https://github.com/pangoraw/cooptimaltransport.jl"); Pkg.add("Plots"); Pkg.add("OptimalTransport"); Pkg.add("Tulip")

# ╔═╡ 0193b615-efac-43ba-9ca4-24d082c51e23
using Plots

# ╔═╡ 3425b644-0ca5-4a75-8d1a-b14da34f7dcd
using CoOptimalTransport, OptimalTransport, Tulip

# ╔═╡ c71fe45b-e07e-422a-96c8-f0db9b0a1a9b
function draw_line!(x, y; t)
	t = -t
	plot!([x, x, y, y], [0., t, t, 0.], label=false, color=:black)
end

# ╔═╡ 481fde81-c839-4621-af55-735be7be29cc
N = 5

# ╔═╡ b61eaec5-eade-42c4-9880-b4bff85050be
X = reshape(randn(2N),2,:) .* [1., 2.3]

# ╔═╡ e5f5a07e-9e9a-4d07-97f3-ff483ba85156
Y = randn(N)

# ╔═╡ 3eff34e1-f0ff-4832-8a87-2b58a9f56b35
θ = 0 / 4

# ╔═╡ 3f4e4dba-c9e6-438f-84c9-beb0ead790db
πᵥ, πₛ = coot(X,reshape(Y,1,:); tol=0., n_iters=100, otplan=(a,b,c) -> OptimalTransport.emd(a,b,c,Tulip.Optimizer()))

# ╔═╡ 8877f68f-2786-4b5a-8b9a-994da3de4837
assign = πₛ .>= 1e-5

# ╔═╡ 9b1a3fe8-215f-4666-9a90-1a13b78a1d8f
let
	scatter(eachrow(X)...; label="X", legendfont=font(10,"Computer Modern"),
									  titlefont=font(15,"Computer Modern"),
									  legend=:topleft,
									  markersize=10, markercolor="#4063d8ff",
									  )
	title!("Co-Optimal Transport between X and Y")
	xaxis!(false)
	yaxis!(false)
	xgrid!(false)
	ygrid!(false)

	PX = reshape(πᵥ' * X, :)

	ranges = Tuple{Float64,Float64}[]
	for (i, R) in enumerate(eachrow(assign))
		a, b =  (PX[i], Y[argmax(R)])
		T = count(ranges) do (x,y)
			x, y = extrema((x,y))
			aa, bb = extrema((a,b))
			x <= aa <= y ||
			x <= bb <= y
		end + 1
		T = min(3,T)
		push!(ranges, (a, b))
		draw_line!(a, b, t=0.4T)
	end
	
	scatter!(PX, zeros(N); label="proj X", markercolor="#5f78b9ff", markersize=10)

	
	scatter!(Y * cos(θ), Y * sin(θ); label="Y",
									 markercolor="#ff8080ff",
									 markersize=10)
	quiver!(eachrow(X)...; quiver=(PX .- X[1,:], -X[2,:]), color=:black)


	savefig("cooptimal_transport.pdf")
	plot!()
end

# ╔═╡ 172ea3f2-346e-4027-be89-bf6ff7520ce9


# ╔═╡ 53542921-8f9c-4bd8-8123-cba47ba92ea4
πᵥ' * X

# ╔═╡ 9285a872-1961-4765-b03a-c7876ae6cdf1
md"""
---
"""

# ╔═╡ Cell order:
# ╠═8877f68f-2786-4b5a-8b9a-994da3de4837
# ╠═9b1a3fe8-215f-4666-9a90-1a13b78a1d8f
# ╠═0193b615-efac-43ba-9ca4-24d082c51e23
# ╠═c71fe45b-e07e-422a-96c8-f0db9b0a1a9b
# ╠═3425b644-0ca5-4a75-8d1a-b14da34f7dcd
# ╠═481fde81-c839-4621-af55-735be7be29cc
# ╠═b61eaec5-eade-42c4-9880-b4bff85050be
# ╠═e5f5a07e-9e9a-4d07-97f3-ff483ba85156
# ╠═3eff34e1-f0ff-4832-8a87-2b58a9f56b35
# ╠═3f4e4dba-c9e6-438f-84c9-beb0ead790db
# ╠═172ea3f2-346e-4027-be89-bf6ff7520ce9
# ╠═53542921-8f9c-4bd8-8123-cba47ba92ea4
# ╟─9285a872-1961-4765-b03a-c7876ae6cdf1
# ╠═bc43ee86-2727-11ef-3067-3f78a95bf8a5
# ╠═38c8db2c-a9bc-4c35-9e47-e513f4276d58
