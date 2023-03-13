### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 06e35174-65a7-477f-863c-beba8d5f828d
md"""
## Reading from `npy` files
"""

# ╔═╡ 567198ae-a1ab-4fac-84e0-dde1673c033e
const MAGIC_STRING = "\x93NUMPY";

# ╔═╡ 2ac682e3-55e2-45e6-a877-bcfd48eb42f3
const SUPPORTED_VERSION = [0x01, 0x00];

# ╔═╡ f3029296-8a95-43af-b806-e609ef0cba95
function asarray(io::IO)
	x = read(io, length(MAGIC_STRING))
	@assert String(x) == MAGIC_STRING "invalid npy file"
	@assert SUPPORTED_VERSION == read(io, 2)

	header_len = read(io, UInt16)
	header = read(io, header_len)
	header = Meta.parse(replace(
		String(header),
		"'" => "\"",
		"False" => "false",
		"True" => "true",
		":" => "=>",
		"}" => ")",
		"{" => "Dict(",
	)) |> eval

	shape = header["shape"]
	fortran_order = header["fortran_order"]
	dtype = Dict(
		"<i4" => Int32,
		"<f4" => Float32,
	)[header["descr"]]

	N = length(shape)
	
	sz = sizeof(dtype) * prod(shape)
	buf = read(io, sz)
	data = reinterpret(dtype, buf)

	if !fortran_order
		permutedims(reshape(data, reverse(shape)...), N:-1:1)
	else
		reshape(data, shape)
	end
end

# ╔═╡ 32d879e9-09ea-4a29-a55f-50e9b25ba838
asarray(s::AbstractString) = open(asarray, s)

# ╔═╡ cb74b773-60a9-4f5c-a8b6-724c832fd823
md"""
## Writing `.npy` files
---
"""

# ╔═╡ 525f0685-a73f-4e12-9816-f22329f9f0d6
function numpy_descr(T)
	if T == Float32
		"<f4"
	elseif T == Float64
		"<f8"
	else
		error("no numpy descr for type $T")
	end
end

# ╔═╡ e3515ab4-037f-498a-b6f0-ef4b2a33f4da
function writenpy(io::IO, array::AbstractArray{T,D}) where {T, D}
	n = write(io, MAGIC_STRING)
	n += write(io, SUPPORTED_VERSION)
	
	header = replace("""{
		'shape': $(size(array)),
		'fortran_order': True,
		'descr': '$(numpy_descr(T))',
	}""", ' ' => "", '\n' => "")
	raw_header = Vector{UInt8}(header)

	n += sizeof(UInt16) + length(raw_header)
	padding = n % 64 == 0 ? 0 : 64 - (n % 64)

	@assert (n + padding) % 64 == 0
	
	write(io, UInt16(length(raw_header) + padding))
	write(io, raw_header)
	n += write(io, fill(UInt8(' '), padding))

	data_bytes = write(io, reinterpret(UInt8, view(array, :)))
	n += data_bytes

	n
end

# ╔═╡ Cell order:
# ╟─06e35174-65a7-477f-863c-beba8d5f828d
# ╠═567198ae-a1ab-4fac-84e0-dde1673c033e
# ╠═2ac682e3-55e2-45e6-a877-bcfd48eb42f3
# ╠═f3029296-8a95-43af-b806-e609ef0cba95
# ╠═32d879e9-09ea-4a29-a55f-50e9b25ba838
# ╟─cb74b773-60a9-4f5c-a8b6-724c832fd823
# ╠═525f0685-a73f-4e12-9816-f22329f9f0d6
# ╠═e3515ab4-037f-498a-b6f0-ef4b2a33f4da
