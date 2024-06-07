### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# ╔═╡ 163b4bf1-e11b-49f0-9970-55a827ab74d6
md"""
## how to draw an hyperbolic geodesic

 1. Invert points with respect to the Poincaré circle.
 2. Draw the perpendicular bisector between each points and their inverse.
 3. Find the intersection between the two bisectors.
 4. Draw a circle with this point as the center. The geodesic is an arc of this circle.
"""

# ╔═╡ e69c756f-2520-4e6f-b2c2-2bdad6a698ca
md"""
---
"""

# ╔═╡ dcfa53fc-2332-11ef-35ae-b9f3a3b0b445
const Point = Tuple{Float64,Float64}

# ╔═╡ 07a4b8bd-f2fd-4ee0-9ff4-7786bc06da2e
begin
	struct Tikz s::String end
	function Base.show(io::IO, ::MIME"text/html", t::Tikz)
	write(io, raw"""
	<div style="margin: 10px;">
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

# ╔═╡ 89d3374f-ba43-45e7-a41b-a66b96bf0098
macro tikz_str(s)
	Tikz(s)
end

# ╔═╡ 565ccaf2-e5ba-4f4d-881e-bfbc1fdb2064
tikz"""
\begin{tikzpicture}
	\node[fill] (point325) at (0.0, 0.0) {};
\end{tikzpicture}
"""

# ╔═╡ ca6ad50e-e6bf-4378-ad9e-40678d7d87b5
function render_tikz((x,y)::Point)
	node = replace(string(gensym(:point)), '#' => "")
	"\\node[fill,circle] ($(node)) at ($x, $y) {};"
end

# ╔═╡ a8a605b0-bf20-4d7b-8b71-82c303ab3b0b
render_tikz((0., 0.))

# ╔═╡ 2ae0fbf4-4098-4148-b217-60d1d900039f
scale = 3

# ╔═╡ 2d417482-4785-401e-b92d-94c8f68901f0
polar((x,y)::Point) = (atan(y,x), √(x ^ 2 + y ^ 2))

# ╔═╡ 5d4c9de9-69c1-4acd-a5de-0663f1a9d1e1
function invert(p::Point)
	θ, r = polar(p)
	(
		1/r * cos(θ),
		1/r * sin(θ)
	)
end

# ╔═╡ 8480b6a1-abd5-4c78-bc28-ca7f7ef4b69b
point = (
	0.8, 0.2
)

# ╔═╡ e6b42dbe-a978-4075-9653-df1b2980a58b
point2 = (
	0.1, -0.8
)

# ╔═╡ 54ac9b6d-9dad-4521-a60a-c5984f169e8d
point2_inverse = invert(point2)

# ╔═╡ 9e863d2b-30d8-43f3-b296-1883c25bacb2
point_inverse = invert(point)

# ╔═╡ 33654f84-8bcb-425b-a6ea-d170a607a4da
struct Line
	offset::Float64
	grow::Float64
end

# ╔═╡ 135dea47-a780-45c2-8e46-994e4fd054d7
function midpoint(a,b)
	@. a + (b - a) / 2
end

# ╔═╡ bc77f629-2f6d-4aa9-a289-571b2d820da3
function bisector(a, b)
	m = midpoint(a, b)
	θₐ, _ = polar(a)
	θ = θₐ + π / 2

	other_point = (m[1] + cos(θ), m[2] + sin(θ))


end

# ╔═╡ 61abeb96-617b-476f-a226-c740d4f99801
bis2 = bisector(point2, point2_inverse)

# ╔═╡ 4f7fb8c2-5ded-438b-b1d3-cf9d35dffed3
function bisector2(a, b)
	m = midpoint(a, b)
	θₐ, _ = polar(a)
	θ = θₐ + π / 2

	other_point = (m[1] + cos(θ), m[2] + sin(θ))


	dx,dy = m .- other_point
	grow = dy/dx

	offset = m[2] - grow * m[1]
	Line(offset,grow)
end

# ╔═╡ 277b2f9b-7a38-49fa-b9b8-1fc889d5bf44
bis2_line = bisector2(point2, point2_inverse)

# ╔═╡ 4307d464-3073-4575-b0c7-6a5755c835b7
bis_line = bisector2(point, point_inverse)

# ╔═╡ ad6aa8c9-ebc7-4894-b6e3-f1ae32a92922
function intersect(l1, l2)
	b₁, a₁ = l1.offset, l1.grow
	b₂, a₂ = l2.offset, l2.grow
	x = (b₂ - b₁) / (a₁ - a₂)
	(x, a₁ * x + b₁)
end

# ╔═╡ effa6fc4-c6a2-4159-a3a8-8a850542b968
e = intersect(bis_line, bis2_line)

# ╔═╡ fb017669-85e2-463a-a393-78092610482e
dist(a, b) = sqrt(sum(abs2, a .- b))

# ╔═╡ be645560-6378-4a94-bee4-e8062a238e4a
dist(point2, e)

# ╔═╡ cc062488-a825-4c81-8b34-ead43d6800f2
dist(point, e)

# ╔═╡ e4b6214c-f905-414b-a982-bcc155e1cd9b
angle_start = 360 * polar(point .- e)[1] / (2π)

# ╔═╡ d023fa52-865f-46c6-8409-38ff40dd8d1e
angle_end = 360 * polar(point2 .- e)[1] / (2π)

# ╔═╡ 515850ac-0860-42e3-bf53-fd5c50808d8a
radius = dist(point, e)

# ╔═╡ 59191097-79b7-4549-902c-ca57ae37b2bf
struct Circle
	center::Point
	radius::Float64
end

# ╔═╡ c97e8c67-4707-402f-86fb-0750e689c388
function intersect_circles(c1, c2, sign=-1)
	x₁, y₁ = c1.center
	x₂, y₂ = c2.center
	r₁, r₂ = c1.radius, c2.radius
	R = dist(c1.center, c2.center)
	
	1/2 .* (x₁ + x₂, y₁ + y₂) .+ (r₁^2 - r₂^2) / (2R^2) .* (x₂ - x₁, y₂ - y₁) .+ sign * 1/2 * √(
		2 * (r₁^2 + r₂^2) / R^2 - (r₁^2-r₂^2)^2/(R^4) - 1
	) .* (y₂ - y₁, x₁ - x₂)

end

# ╔═╡ 60efd074-531d-43d0-8c4a-8059d764d632
function generate_geo(a, b; scale=2, draw_points = true, include_circle = false)
	a′ = invert(a)
	b′ = invert(b)

	ba = bisector2(a, a′)
	bb = bisector2(b, b′)

	e = intersect(ba, bb)
	start_angle = rad2deg( polar(a .- e)[1] )
	end_angle = rad2deg( polar(b .- e)[1])
	radius = dist(e, a)

	pos_1 = intersect_circles(Circle((0., 0.), 1.), Circle(e, radius))
	pos_2 = intersect_circles(Circle((0., 0.), 1.), Circle(e, radius), 1)
	
	res = draw_points ? """
	\\node[circle, fill] (a) at ($(scale * a[1]), $(scale * a[2])) {};
	\\node[circle, fill] (b) at ($(scale * b[1]), $(scale * b[2])) {};
	\\draw[] (a) arc[start angle =$(start_angle), end angle = $(end_angle), radius = $(scale * radius)];
	""" : "\\node[] (a) at ($(scale * a[1]), $(scale * a[2])) {}; \\draw[] (a) arc[start angle =$(start_angle), end angle = $(end_angle), radius = $(scale * radius)];"
	if include_circle
		if draw_points
			res *= """
			\\node[circle, fill] (a_ci) at ($(scale * pos_1[1]), $(scale * pos_1[2])) {};
			\\node[circle, fill] (a_ci) at ($(scale * pos_2[1]), $(scale * pos_2[2])) {};
			"""
		end

		res *=
		"""
		\\draw[dashed] (a) arc[start angle =$(start_angle), end angle = $( end_angle - 360 ), radius = $(scale * radius)];
		"""
	end
	return res
end

# ╔═╡ 2295d691-9d49-4c70-8f44-3ce117b62258
let scale = 5
	Tikz("""
	\\begin{tikzpicture}
		
		\\draw[] (0,0) circle ($scale);
	
		$(generate_geo(point, point2; scale, include_circle = true))
	
	\\end{tikzpicture}
	""")
end

# ╔═╡ 8f3e6cbe-09d0-4788-b6ae-ef5b7b9b56cf
te = intersect_circles(
	Circle((0., 0.), 1.),
	Circle(e, radius),
)

# ╔═╡ b747fb1e-8812-4e1b-836a-65af7add0dab
t = Tikz("""
\\usetikzlibrary{shapes.geometric}
\\usetikzlibrary{angles,quotes}
\\begin{tikzpicture}

	\\draw (0,0) circle ($scale);

	\\node[fill,circle,inner sep = 1] (point) at ($(scale * point[1]), $(scale * point[2])) {};

	\\node[draw,fill=white,circle,inner sep = 1] (point2) at ($(scale * point2[1]), $(scale * point2[2])) {\$y\$};

	\\node[fill,circle,inner sep = 1] (point2_inverse) at ($(scale * point2_inverse[1]), $(scale * point2_inverse[2])) {};

	\\node[fill,circle,inner sep = 1] (point2_mid) at ($(scale * midpoint(point2, point2_inverse)[1]), $(scale * midpoint(point2, point2_inverse)[2])) {};

	\\node[inner sep = 1] (bis2) at ($(scale * bis2[1]), $(scale * bis2[2])) {};

	% \\draw[] (0,$(scale * bis2_line.offset)) -- ($scale,$(scale * (bis2_line.offset +  bis2_line.grow)));

	\\node[fill,circle,inner sep = 1] (e) at ($(scale * e[1]), $(scale * e[2])) {};
	\\node[fill,circle,inner sep = 1] (te) at ($(scale * te[1]), $(scale * te[2])) {};

	\\draw[] (point) arc[start angle = $(angle_start), end angle = $(angle_end), radius = $(scale * radius)];

	\\draw[dashed] (0,0) -- (point2_inverse);
	\\draw[latex-,dashed] (bis2) -- (point2_mid);
	\\draw[fill] (0,0) circle (0.05);

\\end{tikzpicture}
""")

# ╔═╡ 5536e986-d255-4bff-af76-211232f70dcc
tikz"""
\begin{tikzpicture}
\draw[] (0,0) circle (1);
\end{tikzpicture}
"""

# ╔═╡ 0309cb88-ce8f-4f07-ad2e-fa0cf776ec2a
cartesian((θ, r)) = (r * cos(θ), r * sin(θ))

# ╔═╡ c83cbaeb-78d1-4a67-9a6f-da265e4bc316
tt = let scale = 3

	j = (-.8, .4)
	θ, r = polar(j)
	j = cartesian((θ, 1.))
	r = 1.

	Tikz("""
	\\begin{tikzpicture}
		
		\\draw[] (0,0) circle ($scale);
	
		$(join([generate_geo(j, cartesian((θ - i / 2π, r)) ; scale, draw_points = false, include_circle= true) for i in 1:10 ], "\n"))
		$(join([generate_geo(j, cartesian((θ + i / 2π, r)) ; scale, draw_points = false, include_circle = true) for i in 1:10 ], "\n"))

	\\end{tikzpicture}
	""")
end;

# ╔═╡ 58798504-29e5-4eef-97a4-5922bca50015
tt

# ╔═╡ 7ca2d308-38ac-4635-875a-7ef8223d0fb9
Markdown.parse("```tex
$(tt.s)```")

# ╔═╡ 0819ce07-5f82-4b34-8ce6-283dec7200c7
generate_geo(point, point2)

# ╔═╡ Cell order:
# ╟─163b4bf1-e11b-49f0-9970-55a827ab74d6
# ╟─2295d691-9d49-4c70-8f44-3ce117b62258
# ╠═c83cbaeb-78d1-4a67-9a6f-da265e4bc316
# ╟─58798504-29e5-4eef-97a4-5922bca50015
# ╠═7ca2d308-38ac-4635-875a-7ef8223d0fb9
# ╠═60efd074-531d-43d0-8c4a-8059d764d632
# ╟─e69c756f-2520-4e6f-b2c2-2bdad6a698ca
# ╠═dcfa53fc-2332-11ef-35ae-b9f3a3b0b445
# ╠═89d3374f-ba43-45e7-a41b-a66b96bf0098
# ╠═07a4b8bd-f2fd-4ee0-9ff4-7786bc06da2e
# ╠═565ccaf2-e5ba-4f4d-881e-bfbc1fdb2064
# ╠═ca6ad50e-e6bf-4378-ad9e-40678d7d87b5
# ╠═a8a605b0-bf20-4d7b-8b71-82c303ab3b0b
# ╠═5d4c9de9-69c1-4acd-a5de-0663f1a9d1e1
# ╠═2ae0fbf4-4098-4148-b217-60d1d900039f
# ╠═2d417482-4785-401e-b92d-94c8f68901f0
# ╠═8480b6a1-abd5-4c78-bc28-ca7f7ef4b69b
# ╠═e6b42dbe-a978-4075-9653-df1b2980a58b
# ╠═54ac9b6d-9dad-4521-a60a-c5984f169e8d
# ╠═9e863d2b-30d8-43f3-b296-1883c25bacb2
# ╠═33654f84-8bcb-425b-a6ea-d170a607a4da
# ╠═135dea47-a780-45c2-8e46-994e4fd054d7
# ╠═bc77f629-2f6d-4aa9-a289-571b2d820da3
# ╠═61abeb96-617b-476f-a226-c740d4f99801
# ╠═4f7fb8c2-5ded-438b-b1d3-cf9d35dffed3
# ╠═277b2f9b-7a38-49fa-b9b8-1fc889d5bf44
# ╠═4307d464-3073-4575-b0c7-6a5755c835b7
# ╠═ad6aa8c9-ebc7-4894-b6e3-f1ae32a92922
# ╠═effa6fc4-c6a2-4159-a3a8-8a850542b968
# ╠═fb017669-85e2-463a-a393-78092610482e
# ╠═be645560-6378-4a94-bee4-e8062a238e4a
# ╠═cc062488-a825-4c81-8b34-ead43d6800f2
# ╠═e4b6214c-f905-414b-a982-bcc155e1cd9b
# ╠═d023fa52-865f-46c6-8409-38ff40dd8d1e
# ╠═515850ac-0860-42e3-bf53-fd5c50808d8a
# ╠═59191097-79b7-4549-902c-ca57ae37b2bf
# ╠═c97e8c67-4707-402f-86fb-0750e689c388
# ╠═8f3e6cbe-09d0-4788-b6ae-ef5b7b9b56cf
# ╠═b747fb1e-8812-4e1b-836a-65af7add0dab
# ╠═5536e986-d255-4bff-af76-211232f70dcc
# ╠═0309cb88-ce8f-4f07-ad2e-fa0cf776ec2a
# ╠═0819ce07-5f82-4b34-8ce6-283dec7200c7
