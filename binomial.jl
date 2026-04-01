### A Pluto.jl notebook ###
# v0.20.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ f93cd710-a136-431c-8d02-ab3120e3ef39
using PlutoUI, Memoize

# ╔═╡ eb1f8efd-60a1-4c62-ad4a-d8803bde1d6d
md"""
# Binomial Checkpointing

Precomputing static checkpointing schemes
"""

# ╔═╡ 8452c3a2-3f63-42f0-af61-af149519fa6b
@bind n Slider(1:32, default=9, show_value=true)

# ╔═╡ 0d28bfb4-aee7-4065-baaf-82c4c6616a91
@bind k Slider(1:10, show_value=true)

# ╔═╡ 284b749c-9e03-4dfe-93dd-55152fda6115
cld(n, isqrt(n))

# ╔═╡ 65ee7021-1646-4113-807b-7b3d177494b5
md"""
n = $n
k = $k
"""

# ╔═╡ 60d76596-2de2-11f1-2bee-adfca4d6b4f1
@memoize function binomial_coeff(n, k)
    k < 0 || k > n && return 0
    k == 0 || k == n && return 1
    r = 1
    for i in 0:k-1
        r = r * (n - i) ÷ (i + 1)
    end
    r
end

# ╔═╡ bf89227b-dee7-43d8-8981-3be07c17fc70
abstract type Step end

# ╔═╡ d6c5d07e-9c22-4aa4-ba1b-c3cc57cda7c3
struct Forward <: Step
	lb::Int
	ub::Int
end

# ╔═╡ 09ccefaa-a0fe-4924-8536-1996e7191568
struct Store <: Step
	step::Int
end

# ╔═╡ a66497aa-d701-4243-93c7-f1e4b618daa2
struct Load <: Step
	step::Int
end

# ╔═╡ 9faf952e-5120-4c31-ae33-1bbcbfb8649c
struct Reverse <: Step
	ub::Int
	lb::Int
end

# ╔═╡ a1e5ad83-fc21-4826-9369-03178ece9e87
function constant_schedule(n, nouter; amortize=false)
	schedule = Step[]

	
	@info "const" n nouter cld(n, nouter)
	
	for i in 1:cld(n, nouter)
		step = 1+(i - 1) * nouter
		ninner = min(
			nouter,
			n+1-step,
		)
		push!(
			schedule,
			Store(step),
			Forward(step, step+ninner)
		)
	end

	for i in cld(n, nouter):-1:1
		step = 1+(i - 1) * nouter
		ninner = min(
			nouter,
			n+1-step,
		)

		if amortize
			push!(schedule, Load(step))
			for j in 0:ninner-2
				push!(schedule, Forward(step+j,step+j+1))
				if j != ninner-2
					push!(schedule, Store(step+j+1))
				end
			end
			for j in 1:ninner
				if j != 1
					push!(schedule, Load(step+ninner-j))
				end
				push!(
					schedule,
					Reverse(step+ninner-j+1, step+ninner-j)
				)
			end
		else
			for j in 1:ninner
				push!(schedule, Load(step))
				if j != ninner
					push!(schedule, Forward(step, step+ninner-j))
				end
				push!(
					schedule,
					Reverse(step+ninner-j+1, step+ninner-j),
				)
			end
		end
	end

	schedule
	
end

# ╔═╡ 19d6bb47-5a4a-4b64-941c-3e30573338dd
isqrt_schedule(n; amortize=false) = constant_schedule(n, isqrt(n); amortize)

# ╔═╡ a214396c-e8f4-4cb0-92ed-d24452a7df9c
isqrt_schedule(n)

# ╔═╡ 44e5e063-22ee-4ef9-a807-3e0e6d978c91
isqrt_schedule(n)

# ╔═╡ 606b01e8-814d-447c-8f1f-b45cc0beb12a
constant_schedule(n, isqrt(n))

# ╔═╡ e4de752e-fa8d-4776-b0c9-64e89da9746c
function recompute_ratio(schedule)
	total_fwd = sum(s.ub - s.lb for s in schedule if s isa Forward; init=0)
	min_fwd = sum(s.ub - s.lb for s in schedule if s isa Reverse; init=0)
	total_fwd / min_fwd
end

# ╔═╡ 56218c52-0a2d-449a-9657-03bfb4d8c8a3


# ╔═╡ deb7a993-9496-4ec3-a7e0-977bdbbd10a5
@memoize function max_reversals(t, k)
	(t <= 0 || k <= 0) && return 0
	t == 1 && return 1
	max_reversals(t - 1, k - 1) + max_reversals(t - 1, k)
end

# ╔═╡ dfcb3573-6277-4f0e-b9d4-1a5137cd08da
function revolve!(steps, lb, ub, n, k; first=false)
	num_steps = ub - lb

	if num_steps == 0
		return steps
	elseif num_steps == 1
		if ub == n
			push!(steps, Store(lb))
			push!(steps, Forward(lb, ub))
			push!(steps, Load(lb))
		end

		push!(steps, Reverse(ub, lb))
		return steps
	end

	if k == 1
		# Single checkpoint: store lb, forward all the way, then
		# repeatedly load, re-forward, and reverse one step
		push!(steps, Store(lb))
		push!(steps, Forward(lb, ub))
		for i in 0:num_steps-1
			push!(steps, Load(lb))
			if ub - i - 1 != lb
				push!(steps, Forward(lb, ub - i - 1))
			end
			push!(steps, Reverse(ub - i, ub - i - 1))
		end
		return steps
	end

	# Find smallest t such that max_reversals(t, k) >= num_steps
	t = 1
	while max_reversals(t, k) < num_steps
		t += 1
	end

	# Optimal split: leave max_reversals(t-1, k-1) steps for the tail
	tail = max_reversals(t - 1, k - 1)
	d = num_steps - tail

	mid = lb + d

	if isempty(steps) || steps[end] != Load(lb)
		push!(steps, Store(lb))
	end
	push!(steps, Forward(lb, mid))

	revolve!(steps, mid, ub, n, k - 1)

	push!(steps, Load(lb))
	revolve!(steps, lb, mid, n, k)

	return steps
end

# ╔═╡ f7c6c27c-c8c1-422a-95c8-4fddd9f05967
full_revolve(n, k) = revolve!(Step[], 1, n + 1, n + 1, k)

# ╔═╡ 5bfdf747-b78a-4500-8633-b63188e7a274
schedule = full_revolve(n, k)

# ╔═╡ 6e427696-df50-4557-b29b-6cfc1f702455
recompute_ratio(schedule)

# ╔═╡ b7e82b01-8088-45a1-bc38-ff845e9c7eb2
function linear_schedule(n)
	schedule = Step[]
	for i in 1:n
		push!(
			schedule,
			Store(i),
			Forward(i,i+1),
		)
	end
	for i in n:-1:1
		push!(
			schedule,
			Load(i),
			Reverse(i+1,i)
		)
	end
	
	schedule
end

# ╔═╡ ef37a437-c1aa-48f2-8261-1a3a6de97952
linear_schedule(n)

# ╔═╡ aba9e939-0c60-43f5-a3e7-9dafd905bb55
function memory_overhead(schedule)
	current = 0
	peak = 0
	for s in schedule
		if s isa Store
			current += 1
			peak = max(peak, current)
		elseif s isa Load
			current -= 1
		end
	end
	peak
end

# ╔═╡ 1b8e0479-4ab6-4e25-909d-3c2ab39cf1b4
function visualize_scheme(schedule::Vector{Step})
	max_step = 0
	for s in schedule
		if s isa Forward
			max_step = max(max_step, s.ub)
		elseif s isa Reverse
			max_step = max(max_step, s.ub)
		elseif s isa Store
			max_step = max(max_step, s.step)
		elseif s isa Load
			max_step = max(max_step, s.step)
		end
	end

	cw = 40  # cell width
	ch = 24  # cell height
	pad = 55 # left padding for labels
	top = 25 # top padding for column headers
	w = pad + max_step * cw + 10
	h = top + length(schedule) * ch + 10

	svg = """<svg width="$w" height="$h" xmlns="http://www.w3.org/2000/svg">
	<defs>
		<marker id="aF" viewBox="0 0 10 10" refX="9" refY="5"
			markerWidth="6" markerHeight="6" orient="auto">
			<path d="M0 0L10 5L0 10z" fill="#4CAF50"/>
		</marker>
		<marker id="aR" viewBox="0 0 10 10" refX="9" refY="5"
			markerWidth="6" markerHeight="6" orient="auto">
			<path d="M0 0L10 5L0 10z" fill="#E53935"/>
		</marker>
	</defs>
	<style>
		text{font-family:monospace;font-size:11px}
		.lbl{fill:#888;font-size:10px}
		.hdr{fill:#555;font-size:11px}
	</style>"""

	# Column headers
	for i in 1:max_step
		x = pad + (i - 0.5) * cw
		svg *= """<text x="$x" y="14" text-anchor="middle" class="hdr">$i</text>"""
	end

	# Grid lines
	for i in 0:max_step
		x = pad + i * cw
		svg *= """<line x1="$x" y1="$top" x2="$x" y2="$h"
			stroke="#eee" stroke-width="1"/>"""
	end

	# Red boundary before first reverse
	first_rev = findfirst(s -> s isa Load, schedule)
	if first_rev !== nothing
		by = top + (first_rev - 1) * ch
		svg *= """<line x1="$pad" y1="$by" x2="$(pad + max_step * cw)" y2="$by"
			stroke="#E53935" stroke-width="1.5" stroke-dasharray="6,3"/>"""
	end

	for (row, s) in enumerate(schedule)
		y = top + (row - 1) * ch
		cy = y + ch / 2

		# Alternating row background
		if row % 2 == 0
			svg *= """<rect x="$pad" y="$y" width="$(max_step*cw)"
				height="$ch" fill="#fafafa"/>"""
		end

		if s isa Forward
			x1 = pad + (s.lb - 0.5) * cw
			x2 = pad + (s.ub - 0.5) * cw
			svg *= """<line x1="$x1" y1="$cy" x2="$(x2-4)" y2="$cy"
				stroke="#4CAF50" stroke-width="2.5" marker-end="url(#aF)"/>"""
			svg *= """<text x="$(pad-4)" y="$(cy+4)"
				text-anchor="end" class="lbl">Fwd</text>"""
		elseif s isa Reverse
			x1 = pad + (s.ub - 0.5) * cw
			x2 = pad + (s.lb - 0.5) * cw
			svg *= """<line x1="$x1" y1="$cy" x2="$(x2+4)" y2="$cy"
				stroke="#E53935" stroke-width="2.5" marker-end="url(#aR)"/>"""
			svg *= """<text x="$(pad-4)" y="$(cy+4)"
				text-anchor="end" class="lbl">Rev</text>"""
		elseif s isa Store
			x = pad + (s.step - 0.5) * cw
			svg *= """<rect x="$(x-5)" y="$(cy-5)" width="10" height="10"
				fill="#1E88E5" rx="2"/>"""
			svg *= """<text x="$(pad-4)" y="$(cy+4)"
				text-anchor="end" class="lbl">Store</text>"""
		elseif s isa Load
			x = pad + (s.step - 0.5) * cw
			svg *= """<rect x="$(x-5)" y="$(cy-5)" width="10" height="10"
				fill="none" stroke="#1E88E5" stroke-width="2" rx="2"/>"""
			svg *= """<text x="$(pad-4)" y="$(cy+4)"
				text-anchor="end" class="lbl">Load</text>"""
		end
	end

	svg *= "</svg>"
	HTML(svg)
end

# ╔═╡ 0d943052-e850-4019-8726-5455e7d329df
let
	isq = isqrt_schedule(n)
	iam = isqrt_schedule(n; amortize=true)
	rev = full_revolve(n,k)
	lin = linear_schedule(n)

	md"""
	|Scheme | Memory Overhead | Recompute Ratio |
	|-------|-----------------|-----------------|
	| No checkpointing |$(memory_overhead(lin))| $(recompute_ratio(lin)) |
	| √ |$(memory_overhead(isq))| $(recompute_ratio(isq)) |
	| √ (amortize) |$(memory_overhead(isq))| $(recompute_ratio(isq)) |
	| Revolve | $(memory_overhead(rev)) | $(recompute_ratio(rev)) |

	### No checkpointing

	$(visualize_scheme(lin))
	
	### The SQRT scheme
	$(
	visualize_scheme(isq)
	)

	### The SQRT scheme (amortized)
	$(
	visualize_scheme(iam)
	)
	
	### The Revolve scheme

	Max number of checkpoints:

	k = $(k)
	
	$(visualize_scheme(rev))
	"""
end

# ╔═╡ 71a58daa-071d-41e8-b6fb-26259cda8287
visualize_scheme(isqrt_schedule(n))

# ╔═╡ f7ccdcf9-0922-4e99-b199-66704239ef0f
visualize_scheme(
	isqrt_schedule(n)
)

# ╔═╡ b62b51d6-15b1-4dfb-976f-207f9e5f240a
visualize_scheme(
	linear_schedule(n)
)

# ╔═╡ 4d741ebb-7094-4f5d-b729-f5eb2ef3da96
visualize_scheme(schedule)

# ╔═╡ a8d50654-fddf-47dd-b0a9-04e3b488af5c


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Memoize = "c03570c3-d221-55d1-a50c-7939bbd78826"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Memoize = "~0.4.4"
PlutoUI = "~0.7.80"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.9"
manifest_format = "2.0"
project_hash = "4b82cd01772d0d1eca4c4e6ea449a707555836e0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

    [deps.ColorTypes.weakdeps]
    StyledStrings = "f489334b-da3d-4c2e-b8f0-e476e12c162b"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "fbc875044d82c113a9dee6fc14e16cf01fd48872"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.80"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─eb1f8efd-60a1-4c62-ad4a-d8803bde1d6d
# ╟─8452c3a2-3f63-42f0-af61-af149519fa6b
# ╟─0d28bfb4-aee7-4065-baaf-82c4c6616a91
# ╟─0d943052-e850-4019-8726-5455e7d329df
# ╠═a1e5ad83-fc21-4826-9369-03178ece9e87
# ╠═284b749c-9e03-4dfe-93dd-55152fda6115
# ╠═19d6bb47-5a4a-4b64-941c-3e30573338dd
# ╠═a214396c-e8f4-4cb0-92ed-d24452a7df9c
# ╠═71a58daa-071d-41e8-b6fb-26259cda8287
# ╠═ef37a437-c1aa-48f2-8261-1a3a6de97952
# ╠═606b01e8-814d-447c-8f1f-b45cc0beb12a
# ╠═f7ccdcf9-0922-4e99-b199-66704239ef0f
# ╠═44e5e063-22ee-4ef9-a807-3e0e6d978c91
# ╠═b62b51d6-15b1-4dfb-976f-207f9e5f240a
# ╠═e4de752e-fa8d-4776-b0c9-64e89da9746c
# ╟─6e427696-df50-4557-b29b-6cfc1f702455
# ╟─65ee7021-1646-4113-807b-7b3d177494b5
# ╠═4d741ebb-7094-4f5d-b729-f5eb2ef3da96
# ╠═5bfdf747-b78a-4500-8633-b63188e7a274
# ╠═60d76596-2de2-11f1-2bee-adfca4d6b4f1
# ╠═bf89227b-dee7-43d8-8981-3be07c17fc70
# ╠═d6c5d07e-9c22-4aa4-ba1b-c3cc57cda7c3
# ╠═09ccefaa-a0fe-4924-8536-1996e7191568
# ╠═a66497aa-d701-4243-93c7-f1e4b618daa2
# ╠═9faf952e-5120-4c31-ae33-1bbcbfb8649c
# ╠═dfcb3573-6277-4f0e-b9d4-1a5137cd08da
# ╠═56218c52-0a2d-449a-9657-03bfb4d8c8a3
# ╠═f7c6c27c-c8c1-422a-95c8-4fddd9f05967
# ╠═f93cd710-a136-431c-8d02-ab3120e3ef39
# ╠═deb7a993-9496-4ec3-a7e0-977bdbbd10a5
# ╠═b7e82b01-8088-45a1-bc38-ff845e9c7eb2
# ╠═aba9e939-0c60-43f5-a3e7-9dafd905bb55
# ╠═1b8e0479-4ab6-4e25-909d-3c2ab39cf1b4
# ╠═a8d50654-fddf-47dd-b0a9-04e3b488af5c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
