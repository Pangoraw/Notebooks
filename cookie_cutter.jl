### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 47f40dd9-f490-447f-9c12-59f7edcb6c34
using HypertextLiteral

# ╔═╡ 2c8523ba-2e71-4ec4-89de-19551025a74b
"""
	Point{T}(x::T, y::T, z::T)

Represents a simple point in 3d space.
"""
struct Point{T}
	x::T
	y::T
	z::T
end

# ╔═╡ 02b1fdae-26db-4f0f-972c-818a09da846d
const Origin = Point(0., 0., 0.)

# ╔═╡ a2564bfc-aad6-49e9-bdaf-24f3ad47b9fc
function elevated(p::Point{T}, z) where {T}
	Point(
		p.x, p.y, T(z),
	)
end

# ╔═╡ 8f04d3e5-5062-404d-8494-7c99a55b0d2f
Base.length(::Point) = 3

# ╔═╡ a73bfbd2-bed5-46bd-a448-d3aa094a55b6
function Base.getindex(p::Point, i)
	if i == 1
		return p.x
	elseif i == 2
		return p.y
	elseif i == 3
		return p.z
	end
	throw(BoundsError(p, i))
end

# ╔═╡ 1b39ef9e-fa34-11ec-0ea1-21f472a01b4d
md"""
# Meshes

 - [https://en.wikipedia.org/wiki/STL\_(file_format)](https://en.wikipedia.org/wiki/STL_(file_format))

![](https://user-images.githubusercontent.com/9824244/177015049-4c628fef-e196-4429-9377-4479083b6d76.png)
"""

# ╔═╡ e05d5ecb-3a5f-4d3b-9386-4a77c9fdc8cf
Base.:-(p1::Point, p2::Point) = Point((p1 .- p2)...)

# ╔═╡ d061a654-3ce0-46c0-a889-754ee54723b7
function dist(p1::Point, p2::Point)
	return √(sum(
		(p1 .- p2).^2
	))
end

# ╔═╡ 75afb0f0-410f-4aeb-8bd2-6658825190de
Base.:+(p1::Point, p2::Point) = Point((p1 .+ p2)...)

# ╔═╡ 463b94f6-c31f-4f24-8b30-0cf8578377b8
function Base.iterate(p::Point, i=1)
	return i <= 3 ? (p[i], i + 1) : nothing
end

# ╔═╡ be1480d1-a10f-4234-94ac-f3146cb8ef03
function cross_product(p1::Point, p2::Point)
	Point(
		p1.y * p2.z - p1.z * p2.y,
		p1.z * p2.x - p1.x * p2.z,
		p1.x * p2.y - p1.y * p2.x,
	)
end

# ╔═╡ 2afe05b6-6800-455a-88fe-fdd91c8b8369
"""
	Triangle{T}(normal::Point{T}, vertices::NTuple{3,Point{T}})

Represents a surface of the represented volume.
"""
struct Triangle{T}
	normal::Point{T}
	vertices::Tuple{Point{T}, Point{T}, Point{T}} # of size 3, 3
end

# ╔═╡ d50e8a3f-d4b1-4957-89d5-e872db8ab01b
abstract type CircularGeometry{T} end

# ╔═╡ fbaabe78-022b-4d79-9877-a4efc5f09d6f
origin(::CircularGeometry{T}) where {T} = Point(zeros(T, 3)...)

# ╔═╡ c67d5784-25ed-4fcc-bae1-b719f41cc338
Base.@kwdef struct Circle{T} <: CircularGeometry{T}
	center::Point{T} = Point(0., 0., 0.)
	radius::T = 1.
end

# ╔═╡ 5d53cb49-0f1d-4c99-98be-a3a5b2b7d4d8
function from_angle(c::Circle, θ)::Point
	Point(c.radius * cos(θ), c.radius * sin(θ), 0.)
end

# ╔═╡ 82e845d0-771d-44e0-9a49-4fd65dd5f1f1
Base.@kwdef struct Cookie{T} <: CircularGeometry{T}
	r1::T
	r2::T
	n_circles::Int
end

# ╔═╡ df7842bd-a8a8-4e75-95de-4177a94ba10b
function from_angle(c::Cookie, θ)
	r = c.r1 + c.r2 * abs(sin(θ * c.n_circles))
	Point(r * cos(θ), r * sin(θ), 0.)
end

# ╔═╡ 0250e99f-a9e8-40bc-8b35-12141a086878
struct Elevated{T} <: CircularGeometry{T}
	geom::CircularGeometry{T}
	z::T
end

# ╔═╡ f1233251-a176-4d42-a932-2f590c576a60
origin(el::Elevated{T}) where {T} = Point(zero(T), zero(T), el.z)

# ╔═╡ 66b02238-a04f-4198-bd1d-246ec49714e4
from_angle(el::Elevated, θ) = elevated(from_angle(el.geom, θ), el.z)

# ╔═╡ c38d26d3-06a6-4a98-9dc6-9189be7a8592
function to_triangles(geom::CircularGeometry; Δ = .01)
	[
		let nθ = θ + Δ
			Triangle(
				Point(0., 0., 1.),
				(
					origin(geom),
					from_angle(geom, θ),
					from_angle(geom, nθ),
				)
			)
		end
		for θ in 0.:Δ:2π
	]
end

# ╔═╡ 2fa272d1-162f-47bb-9f4a-519bb2905d80
struct Pyramid{T}
	geom1::CircularGeometry{T}
	geom2::CircularGeometry{T}
end

# ╔═╡ 8656b479-988e-4250-8bc7-8839ad8105cd
function to_triangles(p::Pyramid{T}; Δ=0.01) where {T}
	Iterators.flatten([
		let nθ = θ + Δ
			p1, np1 = from_angle(p.geom1, θ), from_angle(p.geom1, nθ)
			p2, np2 = from_angle(p.geom2, θ), from_angle(p.geom2, nθ)
			normal1 = cross_product(
				p2 - p1,
				np1 - p1,
			)
			normal2 = cross_product(
				np2 - p2,
				np1 - np2,
			)
			
			Triangle(
				Point(zero(T), zero(T), one(T)), (origin(p.geom1), p1, np1),
			), Triangle(
				Point(zero(T), zero(T), -one(T)), (origin(p.geom2), p2, np2),
			), Triangle(
				normal1, (p1, p2, np1),	
			), Triangle(
				normal2, (np1, p2, np2),
			)
		end
		for θ in 0.:Δ:2π
	]) |> collect
end

# ╔═╡ e089f315-91b6-4be2-94f6-af5f4735e4b5
"""
	Mesh(ts::Vector{Triangle})

Simple structs to export to ASCII-STL format files.
"""
struct Mesh{T}
	triangles::Vector{Triangle{T}}
end

# ╔═╡ b51ceb5b-67bb-487d-a9cb-1deb73818eae
function Base.write(io::IO, t::Triangle)
	println(io, "facet normal ", t.normal.x, " ", t.normal.y, " ", t.normal.y)
	println(io, "    outer loop")
	for p in t.vertices
		println(io, "        vertex ", p.x, " ", p.y, " ", p.z)
	end
	println(io, "    endloop")
	println(io, "endfacet")
end

# ╔═╡ ef6a01d1-e52d-4caa-adab-43ae43e9694e
function Base.write(io::IO, m::Mesh)
	println(io, "solid Mesh")
	for t in m.triangles
		write(io, t)
	end
	println(io, "endsolid Mesh")
end

# ╔═╡ cc1f656a-afd6-43ee-b9b6-5eaac45528cd
md"""
---
"""

# ╔═╡ 2ce2332e-7603-4de4-9323-5603aabc8df2
test_file = let
	tmp_dir = mktempdir()
	joinpath(tmp_dir, "mesh.stl")
end

# ╔═╡ 0d6288e9-51e8-47fe-a301-994dbcb6372f
open(test_file, "w") do f
	# write(f, Mesh(to_triangles(
	# 	Cookie(r1 = 10. , r2 = 5., n_circles = 10)
	# )))
	# write(f, Mesh(to_triangles(
	# 	Elevated(Cookie(r1 = 3. , r2 = 1., n_circles = 10), 10.)
	# )))
	write(f, Mesh(to_triangles(
		Pyramid(
			Elevated(Circle(radius=10.), 5.),
			Cookie(r1=20., r2=5., n_circles=10)
		); Δ = .05
	)))
end

# ╔═╡ edf0e11d-a84f-4b58-89c2-24321bd993f6
function Base.show(io::IO, m::MIME"text/html", mesh::Mesh)
	buf = IOBuffer()
	write(buf, mesh)
	stl = String(take!(buf))
	c = @htl("""
	<script src="https://cdn.jsdelivr.net/gh/tonylukasavage/jsstl/three.js"></script>
	<script src="https://cdn.jsdelivr.net/gh/tonylukasavage/jsstl/detector.js"></script>
	<script>
	var stl_content = $(PlutoRunner.publish_to_js(stl))
	var camera, scene, renderer, geometry, material, mesh, light1;

	function trim (str) {
		str = str.replace(/^\\s+/, '');
		for (var i = str.length - 1; i >= 0; i--) {
			if (/\\S/.test(str.charAt(i))) {
				str = str.substring(0, i + 1);
				break;
			}
		}
		return str;
	}

	var parseStl = function(stl) {
		var state = '';
		var lines = stl.split('\\n');
		var geo = new THREE.Geometry();
		var name, parts, line, normal, done, vertices = [];
		var vCount = 0;
		stl = null;

		for (var len = lines.length, i = 0; i < len; i++) {
			if (done) {
				break;
			}
			line = trim(lines[i]);
			parts = line.split(' ');
			switch (state) {
				case '':
					if (parts[0] !== 'solid') {
						console.error(line);
						console.error('Invalid state "' + parts[0] + '", should be "solid"');
						return;
					} else {
						name = parts[1];
						state = 'solid';
					}
					break;
				case 'solid':
					if (parts[0] !== 'facet' || parts[1] !== 'normal') {
						console.error(line);
						console.error('Invalid state "' + parts[0] + '", should be "facet normal"');
						return;
					} else {
						normal = [
							parseFloat(parts[2]), 
							parseFloat(parts[3]), 
							parseFloat(parts[4])
						];
						state = 'facet normal';
					}
					break;
				case 'facet normal':
					if (parts[0] !== 'outer' || parts[1] !== 'loop') {
						console.error(line);
						console.error('Invalid state "' + parts[0] + '", should be "outer loop"');
						return;
					} else {
						state = 'vertex';
					}
					break;
				case 'vertex': 
					if (parts[0] === 'vertex') {
						geo.vertices.push(new THREE.Vector3(
							parseFloat(parts[1]),
							parseFloat(parts[2]),
							parseFloat(parts[3])
						));
					} else if (parts[0] === 'endloop') {
						geo.faces.push( new THREE.Face3( vCount*3, vCount*3+1, vCount*3+2, new THREE.Vector3(normal[0], normal[1], normal[2]) ) );
						vCount++;
						state = 'endloop';
					} else {
						console.error(line);
						console.error('Invalid state "' + parts[0] + '", should be "vertex" or "endloop"');
						return;
					}
					break;
				case 'endloop':
					if (parts[0] !== 'endfacet') {
						console.error(line);
						console.error('Invalid state "' + parts[0] + '", should be "endfacet"');
						return;
					} else {
						state = 'endfacet';
					}
					break;
				case 'endfacet':
					if (parts[0] === 'endsolid') {
						//mesh = new THREE.Mesh( geo, new THREE.MeshNormalMaterial({overdraw:true}));
						mesh = new THREE.Mesh( 
							geo, 
							new THREE.MeshLambertMaterial({
								overdraw:true,
								color: 0xaa0000,
								shading: THREE.FlatShading
							}
						));
						scene.add(mesh);
						done = true;
					} else if (parts[0] === 'facet' && parts[1] === 'normal') {
						normal = [
							parseFloat(parts[2]), 
							parseFloat(parts[3]), 
							parseFloat(parts[4])
						];
						if (vCount % 1000 === 0) {
							console.log(normal);
						}
						state = 'facet normal';
					} else {
						console.error(line);
						console.error('Invalid state "' + parts[0] + '", should be "endsolid" or "facet normal"');
						return;
					}
					break;
				default:
					console.error('Invalid state "' + state + '"');
					break;
			}
		}
	};

	init();
	animate();

	function init() {

		//Detector.addGetWebGLMessage();

		scene = new THREE.Scene();

		camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 );
		camera.position.z = 70;
		camera.position.y = 0;
		scene.add( camera );

		var directionalLight = new THREE.DirectionalLight( 0xffffff );
		directionalLight.position.x = 0; 
		directionalLight.position.y = 0; 
		directionalLight.position.z = 1; 
		directionalLight.position.normalize();
		scene.add( directionalLight );

		parseStl(stl_content);

		renderer = new THREE.WebGLRenderer(); //new THREE.CanvasRenderer();
		renderer.setSize( 200, 150);

		currentScript.parentElement.appendChild( renderer.domElement );
	}

	function animate() {

		// note: three.js includes requestAnimationFrame shim
		requestAnimationFrame( animate );
		render();

	}

	function render() {

		mesh.rotation.x += 0.01;
		if (mesh) {
			mesh.rotation.z += 0.02;
		}
		//light1.position.z -= 1;

		renderer.render( scene, camera );
	}
	</script>
	""")
	Base.show(io, m, c)
end; Base.show

# ╔═╡ 0cf431ee-5990-4ff8-9f0a-9713bb99bfd4
mesh = Mesh(to_triangles(
		Pyramid(
			Elevated(Circle(radius=10.), 5.),
			Cookie(r1=20., r2=5., n_circles=10)
		); Δ = .05
));

# ╔═╡ 5fb74f1f-ad35-4ced-840a-db673a510a4b
mesh

# ╔═╡ 0bf22528-1f22-4ad4-bb91-6e2321c5bcde
Mesh(to_triangles(
		Pyramid(
			Elevated(Circle(radius=10.), 5.),
			Circle(radius=10.),
		); Δ = .05
))

# ╔═╡ b02a5bd2-f173-4b85-9387-6456158de2b1
Mesh(to_triangles(
		Pyramid(
			Elevated(Cookie(r1=10., r2=5., n_circles=10), 10.),
			Cookie(r1=10., r2=5., n_circles=10),
		); Δ = .05
))

# ╔═╡ 1e162676-d8bd-4152-898c-c50b0423e683
# run(`f3d $test_file`)

# ╔═╡ 0d74557a-6d3d-4666-b4dd-78ddc4513889
md"""
---
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"
"""

# ╔═╡ Cell order:
# ╟─1b39ef9e-fa34-11ec-0ea1-21f472a01b4d
# ╟─5fb74f1f-ad35-4ced-840a-db673a510a4b
# ╟─2c8523ba-2e71-4ec4-89de-19551025a74b
# ╠═02b1fdae-26db-4f0f-972c-818a09da846d
# ╠═d061a654-3ce0-46c0-a889-754ee54723b7
# ╠═a2564bfc-aad6-49e9-bdaf-24f3ad47b9fc
# ╠═8f04d3e5-5062-404d-8494-7c99a55b0d2f
# ╠═a73bfbd2-bed5-46bd-a448-d3aa094a55b6
# ╠═463b94f6-c31f-4f24-8b30-0cf8578377b8
# ╠═e05d5ecb-3a5f-4d3b-9386-4a77c9fdc8cf
# ╠═75afb0f0-410f-4aeb-8bd2-6658825190de
# ╠═be1480d1-a10f-4234-94ac-f3146cb8ef03
# ╟─2afe05b6-6800-455a-88fe-fdd91c8b8369
# ╠═d50e8a3f-d4b1-4957-89d5-e872db8ab01b
# ╠═c38d26d3-06a6-4a98-9dc6-9189be7a8592
# ╠═fbaabe78-022b-4d79-9877-a4efc5f09d6f
# ╠═c67d5784-25ed-4fcc-bae1-b719f41cc338
# ╠═5d53cb49-0f1d-4c99-98be-a3a5b2b7d4d8
# ╠═82e845d0-771d-44e0-9a49-4fd65dd5f1f1
# ╠═df7842bd-a8a8-4e75-95de-4177a94ba10b
# ╠═0250e99f-a9e8-40bc-8b35-12141a086878
# ╠═f1233251-a176-4d42-a932-2f590c576a60
# ╠═66b02238-a04f-4198-bd1d-246ec49714e4
# ╠═2fa272d1-162f-47bb-9f4a-519bb2905d80
# ╠═8656b479-988e-4250-8bc7-8839ad8105cd
# ╠═e089f315-91b6-4be2-94f6-af5f4735e4b5
# ╠═b51ceb5b-67bb-487d-a9cb-1deb73818eae
# ╠═ef6a01d1-e52d-4caa-adab-43ae43e9694e
# ╟─cc1f656a-afd6-43ee-b9b6-5eaac45528cd
# ╠═2ce2332e-7603-4de4-9323-5603aabc8df2
# ╠═0d6288e9-51e8-47fe-a301-994dbcb6372f
# ╟─edf0e11d-a84f-4b58-89c2-24321bd993f6
# ╠═0cf431ee-5990-4ff8-9f0a-9713bb99bfd4
# ╟─0bf22528-1f22-4ad4-bb91-6e2321c5bcde
# ╟─b02a5bd2-f173-4b85-9387-6456158de2b1
# ╠═1e162676-d8bd-4152-898c-c50b0423e683
# ╟─0d74557a-6d3d-4666-b4dd-78ddc4513889
# ╠═47f40dd9-f490-447f-9c12-59f7edcb6c34
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
