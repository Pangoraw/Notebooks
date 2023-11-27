### A Pluto.jl notebook ###
# v0.19.32

#> [frontmatter]
#> image = "https://private-user-images.githubusercontent.com/9824244/285644696-57d42057-78e4-4821-b094-44cdd06bbaca.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE3MDA5OTU0OTYsIm5iZiI6MTcwMDk5NTE5NiwicGF0aCI6Ii85ODI0MjQ0LzI4NTY0NDY5Ni01N2Q0MjA1Ny03OGU0LTQ4MjEtYjA5NC00NGNkZDA2YmJhY2EucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMTEyNiUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzExMjZUMTAzOTU2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9NTg0ODRlYzQ2YTE4ZDZjMWMzZWRlMGIzNmU4YjIzMTkxMTMzN2I5OTMzMGYxNTM4N2RkOTBlZTQ4Y2IyZGM5MCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.P6PNFTvaOws2lFLcLj8pceWaJTinpIX_k2fcTqtVf_8"
#> title = "A macro-view of reactivity in Pluto.jl 🎈"
#> date = "2023-01-12"
#> description = "Presentation for JuliaCon Local Eindhoven 2023."
#> 
#>     [[frontmatter.author]]
#>     name = "Paul Berg"
#>     url = "https://github.com/pangoraw"

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 774a864e-f283-4e47-a86d-a64349dc658c
using ExpressionExplorer

# ╔═╡ 94bc7835-2f35-46b7-bcbd-64a8761172a4
using PlutoHooks

# ╔═╡ 134e0517-cca3-454c-ae3c-41e3acda3272
using PlutoLinks

# ╔═╡ 242a12bc-7fe0-4709-8998-11b1de027209
using PlutoUI

# ╔═╡ 676eb519-75f3-45e9-84b3-e85ff0b05f50
using HypertextLiteral

# ╔═╡ cb2c29ab-c8af-4efa-bc9a-dad95cd28fb6
 using MarkdownLiteral: @markdown

# ╔═╡ d642567e-ed4e-4815-96b1-a9f6bfd1aea3
module NotebookViewer # https://pangoraw.github.io/Notebooks/notebook_network_viewer.html
	using HypertextLiteral
	using MarkdownLiteral, Downloads
	using Pluto: Pluto, Cell
	using AbstractPlutoDingetjes: Display

	function show_network(nodes, links)
	@htl("""
	<script src="https://cdn.jsdelivr.net/npm/d3@6"></script>
	<script src="https://cdn.jsdelivr.net/npm/d3-zoom@3"></script>
	<script>
	
	const links = $( Display.published_to_js(links) )
	const nodes = $( Display.published_to_js(nodes) )
	
	// Copyright 2021 Observable, Inc.
	// Released under the ISC license.
	// https://observablehq.com/@d3/force-directed-graph
	function ForceGraph({
	  nodes, // an iterable of node objects (typically [{id}, …])
	  links // an iterable of link objects (typically [{source, target}, …])
	}, {
	  nodeId = d => d.id, // given d in nodes, returns a unique identifier (string)
	  nodeGroup, // given d in nodes, returns an (ordinal) value for color
	  nodeGroups, // an array of ordinal values representing the node groups
	  nodeTitle, // given d in nodes, a title string
	  nodeFill = "currentColor", // node stroke fill (if not using a group color encoding)
	  nodeStroke = "#fff", // node stroke color
	  nodeStrokeWidth = 1.5, // node stroke width, in pixels
	  nodeStrokeOpacity = 1, // node stroke opacity
	  nodeRadius = 5, // node radius, in pixels
	  nodeStrength,
	  linkSource = ({source}) => source, // given d in links, returns a node identifier string
	  linkTarget = ({target}) => target, // given d in links, returns a node identifier string
	  linkStroke = "#999", // link stroke color
	  linkStrokeOpacity = 0.6, // link stroke opacity
	  linkStrokeWidth = 1.5, // given d in links, returns a stroke width in pixels
	  linkStrokeLinecap = "round", // link stroke linecap
	  linkStrength,
	  colors = d3.schemeTableau10, // an array of color strings, for the node groups
	  width = 640, // outer width, in pixels
	  height = 400, // outer height, in pixels
	  invalidation // when this promise resolves, stop the simulation
	} = {}) {
	  // Compute values.
	  const N = d3.map(nodes, nodeId).map(intern);
	  const LS = d3.map(links, linkSource).map(intern);
	  const LT = d3.map(links, linkTarget).map(intern);
	  if (nodeTitle === undefined) nodeTitle = (_, i) => N[i];
	  const T = nodeTitle == null ? null : d3.map(nodes, nodeTitle);
	  const G = nodeGroup == null ? null : d3.map(nodes, nodeGroup).map(intern);
	  const W = typeof linkStrokeWidth !== "function" ? null : d3.map(links, linkStrokeWidth);
	  const L = typeof linkStroke !== "function" ? null : d3.map(links, linkStroke);
	
	  // Replace the input nodes and links with mutable objects for the simulation.
	  nodes = d3.map(nodes, (_, i) => ({id: N[i], title: T[i]}));
	  links = d3.map(links, (_, i) => ({source: LS[i], target: LT[i]}));
	
	  // Compute default domains.
	  if (G && nodeGroups === undefined) nodeGroups = d3.sort(G);
	
	  // Construct the scales.
	  const color = nodeGroup == null ? null : d3.scaleOrdinal(nodeGroups, colors);
	
	  // Construct the forces.
	  const forceNode = d3.forceManyBody();
	  const forceLink = d3.forceLink(links).id(({index: i}) => N[i]);
	  if (nodeStrength !== undefined) forceNode.strength(nodeStrength);
	  if (linkStrength !== undefined) forceLink.strength(linkStrength);
	
	  const simulation = d3.forceSimulation(nodes)
	      .force("link", forceLink)
	      .force("charge", forceNode)
	      .force("center",  d3.forceCenter())
	      .on("tick", ticked);
	  
	  const zoom = d3.zoom()
	
	  const container = d3.create("div")
	
	  const svg = container.append("svg")
	      .attr("width", width)
	      .attr("height", height)
	      .attr("viewBox", [-width / 2, -height / 2, width, height])
	      .attr("style", "max-width: 100%; height: auto; height: intrinsic;");
	
	  const defs = svg.append("svg:defs")  .selectAll("marker")
	    .data(["end", "end-active"]) // Different link/path types can be defined here
	    .enter()
	    .append("svg:marker") // This section adds in the arrows
	    .attr("id", String)
	    .attr("viewBox", "0 -5 10 10")
	    .attr("refX", 20)
	    .attr("markerWidth", 4)
	    .attr("markerHeight", 4)
	    .attr("orient", "auto")
	    .append("svg:path")
	    .attr("d", "M0,-5L10,0L0,5");
	
	  svg.call(d3.zoom()
	      .extent([[0, 0], [width, height]])
	      .scaleExtent([1, 8])
	      .on("zoom", zoomed));
	
	  function zoomed({transform}) {
	    svg.attr("transform", transform);
	  }
	
	  const link = svg.append("g")
	      .attr("stroke", typeof linkStroke !== "function" ? linkStroke : null)
	      .attr("stroke-opacity", linkStrokeOpacity)
	      .attr("stroke-width", typeof linkStrokeWidth !== "function" ? linkStrokeWidth : null)
	      .attr("stroke-linecap", linkStrokeLinecap)
	    .attr("marker-end", "url(#end)")
	    .selectAll("line")
	    .data(links)
	    .join("line");
	
	  const node = svg.append("g")
	      .attr("fill", nodeFill)
	      .attr("stroke", nodeStroke)
	      .attr("stroke-opacity", nodeStrokeOpacity)
	      .attr("stroke-width", nodeStrokeWidth)
	  .selectAll("circle")
	  .data(nodes)
	  .join("circle")
	      .attr("r", nodeRadius)
	      .call(drag(simulation));
	
	    var arrows = node.append("g")
	    .attr("viewBox", "0 -5 10 10")
	    .attr("refX", 20)
	    .attr("markerWidth", 6)
	    .attr("markerHeight", 6)
	    .attr("orient", "auto")
	    .append("svg:path")
	    .attr("d", "M0,-5L10,0L0,5");
	
	
	  var tooltip = container.append("pre")
	    .style("visibility", "hidden")
	    .style("position", "fixed")
	    .style("z-index", "1000")
	    .attr("class", "highlight-julia hljs")
	  var tooltipcode = tooltip.append("code")
	      .text("");
	  console.log(tooltip.node())
	
	  node
	    .on("mouseover", (event, d) => {
	    tooltip.style("visibility", "visible");
	    tooltipcode.text(d.title)
	  })
	    .on("mousemove", (event, d) => {
	    tooltip.style("top", (event.clientY + 20) + "px")
	      .style("left", (event.clientX - 10) + "px")
	  })
	    .on("mouseout", () => (tooltip.style("visibility", "hidden")));
	
	
	  if (W) link.attr("stroke-width", ({index: i}) => W[i]);
	  if (L) link.attr("stroke", ({index: i}) => L[i]);
	  if (G) node.attr("fill", ({index: i}) => color(G[i]));
	  //if (T) node.append("title").text(({index: i}) => T[i]);
	  if (invalidation != null) invalidation.then(() => simulation.stop());
	
	  function intern(value) {
	    return value !== null && typeof value === "object" ? value.valueOf() : value;
	  }
	
	  function ticked() {
	    link
	      .attr("x1", d => d.source.x)
	      .attr("y1", d => d.source.y)
	      .attr("x2", d => d.target.x)
	      .attr("y2", d => d.target.y);
	
	    node
	      .attr("cx", d => d.x)
	      .attr("cy", d => d.y);
	  }
	
	  function drag(simulation) {    
	    function dragstarted(event) {
	      if (!event.active) simulation.alphaTarget(0.3).restart();
	      event.subject.fx = event.subject.x;
	      event.subject.fy = event.subject.y;
	    }
	    
	    function dragged(event) {
	      event.subject.fx = event.x;
	      event.subject.fy = event.y;
	    }
	    
	    function dragended(event) {
	      if (!event.active) simulation.alphaTarget(0);
	      event.subject.fx = null;
	      event.subject.fy = null;
	    }
	
	  function mouseover(d) {}
	
	  function mouseout(d) {}
	
	    return d3.drag()
	      .on("start", dragstarted)
	      .on("drag", dragged)
	      .on("end", dragended);
	  }
	
	  return container.node()
	  return Object.assign(svg.node(), {scales: {color}});
	}
	
	const width = 100
	const height = 100
	
	var force = ForceGraph({nodes, links}, {
	  nodeTitle: node => node.title,
	})
	
	
	return force
	</script>
	""")
	end
	
	begin
	  struct NotebookAsNetwork
	    nodes
	    links
	  end
	  function NotebookAsNetwork(notebook)
	    topology = Pluto.updated_topology(notebook.topology, notebook, notebook.cells);
	    nodes = map(c -> Dict(:id => c.cell_id, :title => c.code), notebook.cells);
	    begin
	      links = []
	      for cell in notebook.cells
	        for (reason, downstream_cells) in cell.cell_dependencies.downstream_cells_map
	          for other_cell in downstream_cells
	            push!(links, Dict(
	              :source => cell.cell_id,
	              :target => other_cell.cell_id,
	              :value => reason,
	            ))
	          end
	        end
	      end
	    end
	    NotebookAsNetwork(nodes, links)
	  end
	  
	  function Base.show(io::IO, m::MIME"text/html", network::NotebookAsNetwork)
	    res = show_network(network.nodes, network.links)
	    show(io, m, res)
	  end
	
	  NotebookAsNetwork
	end
	
	load_and_show(path) = Pluto.load_notebook(path) |> NotebookAsNetwork
	
	function load_remote(url)
	  path = Downloads.download(url)
	  load_and_show(path)
	end
end

# ╔═╡ 2b472858-8ace-11ee-32b4-2ddba7820910
md"""
# A macro-view of reactivity in Pluto.jl 🎈
#### JuliaCon Local Eindhoven ⋅ 01/12/2023 ⋅ Paul Berg
"""

# ╔═╡ 6bfb7e9d-d663-4d1b-be40-d5e14ab9b0e9
html"<button style=\"margin: auto; display: block;\" onclick=present()>Present</button>"

# ╔═╡ 1fae5c09-811f-461d-a89a-050500332c3b
md"""
## What is reactivity?
"""

# ╔═╡ df528e09-be02-4946-9b3a-dcca89f59359
my_name = "Paul"

# ╔═╡ dcc713c0-12ed-4e0e-bff0-bbaa4feac845
"Hello " * my_name * "!"

# ╔═╡ f8071483-9440-4123-8d02-1585f4c80ed0
md"""
## An overview
"""

# ╔═╡ 916e7bfb-1b0b-4eee-aec1-7a4456873d5f
ex = quote
	x = 1
	y = x + z
end;

# ╔═╡ cfe39d27-4aac-44d7-8918-75fe1889382d
ExpressionExplorer.compute_reactive_node(ex)

# ╔═╡ e8d69dd1-5f30-42d9-8fd2-9c0e285d03ca
md"""
[ExpressionExplorer.jl](https://github.com/JuliaPluto/ExpressionExplorer.jl) is now a standalone package!
"""

# ╔═╡ 9b434e82-a50a-4d69-a322-f0581fe3dc2a
md"""
## A cell is a node in a reactive graph

- Edges are variables references.
- The graph is directed from definitions to references.
- Running a cell also runs its successors.
"""

# ╔═╡ 2618e467-eb22-4a20-8ff1-14b5179d0d9d
cell_1 = "hello"

# ╔═╡ ff7195c2-7875-4d15-b4a6-42147f0dd659
cell_2 = uppercase(cell_1)

# ╔═╡ 9a188c6b-d59a-404a-bf35-92460115fad4
md"""
## Example: Simple notebook
"""

# ╔═╡ ce714f47-dbbe-47d3-a47f-70179f02f71b
PlutoUI.ExperimentalLayout.hbox([
	html"<iframe style=\"width: 900px;\" src=\"https://pangoraw.github.io/Notebooks/simple_example_notebook\">",
	NotebookViewer.load_remote("https://gist.github.com/Pangoraw/90c58644efa68fc5199f73b77f089d15/raw/c6ee599ca90296fa024fc5f4381c9dd4c1025c0e/simple_example_notebook.jl")
]; style=Dict(:height => "300px"))

# ╔═╡ 6717df0a-11b9-4a88-9926-ad876c5d6f68
md"""
## Example: 'The tower of Hanoi'
"""

# ╔═╡ f7686455-b5ec-4995-8807-9ccc35f52fa6
PlutoUI.ExperimentalLayout.hbox([
	html"<iframe style=\"width: 900px;\" src=\"https://featured.plutojl.org/basic/tower%20of%20hanoi\">",
	NotebookViewer.load_remote("https://featured.plutojl.org/basic/Tower%20of%20Hanoi.jl")
]; style=Dict(:height => "300px"))

# ╔═╡ 2294b1d7-ed9b-4157-a5b1-7b76d4239195
md"""
## Example: Cycles
"""

# ╔═╡ dfa77823-13fd-4cd1-8ccd-24ab37999c9a
PlutoUI.ExperimentalLayout.hbox([
	html"<iframe style=\"width: 900px;\" src=\"https://pangoraw.github.io/Notebooks/cycle.html\">",
	NotebookViewer.load_remote("https://gist.github.com/Pangoraw/dca1001857c75a106705d3a730e0ef08/raw/2b76b8bb2a92242ec5d5488f9c82f5706b9f78ef/cycle.jl")
]; style=Dict(:height => "300px"))

# ╔═╡ e7231536-f826-4267-9cd5-8703edd864cf
md"""
> The reactive graph is effectively a Directed Acyclic Graph (DAG).
"""

# ╔═╡ 15bca6db-bf7e-4ee7-8f3b-17d2f20154bd
md"""
## Code evaluation in a new module

 - Enables struct redefinitions
 - Old constants are no longer in scope
"""

# ╔═╡ 2c88eed5-14d6-40b3-9071-6eb8529271c6
struct MyStruct
end

# ╔═╡ 88fa15e5-bea4-4cb8-8962-49ff2308ae46
MyStruct

# ╔═╡ e3bcc5c3-bd1f-4b94-ba1d-655093745fbd
const my_constant = [1,2,3]

# ╔═╡ 2d859911-1fb5-4345-a563-9147767eaae0
md"""
```diff
  struct MyStruct
+     x::Int
  end
```
"""

# ╔═╡ bbbd515e-e584-4b36-8534-f87c32b98e53
md"""
In the REPL:
```julia
julia> struct MyStruct
       end

julia> struct MyStruct
           x::Int
       end
ERROR: invalid redefinition of constant Main.MyStruct
Stacktrace:
 [1] top-level scope
   @ REPL[2]:1
```
"""

# ╔═╡ 464cda52-4f51-4e14-9cee-59d912dc6617
@__MODULE__

# ╔═╡ 05db9a59-c826-43b8-b28e-940e8557e250
md"""
##
"""

# ╔═╡ 83f87a68-2416-42df-aa3b-d8addb7d2e36
module Workspace1
	struct MyStruct
	end

	MyStruct

	const my_constant = [1,2,3]
end

# ╔═╡ fd3b2ef1-af67-481c-a847-d3dca4aa2e72
md"""
```diff
  struct MyStruct
+     x::Int
  end
```
"""

# ╔═╡ ce2cd8f5-bbd8-4e78-b62f-c1227b17ed57
module Workspace2
	import ..Workspace1: my_constant

	struct MyStruct
		x::Int
	end

	MyStruct
end

# ╔═╡ 95fbcd7b-5753-4bbb-a155-32079118dbc0
# Tries to trigger gc by setting values to `nothing`
try
	@eval Workspace1 MyStruct = nothing
catch end

# ╔═╡ bc97a180-d986-43a4-9e21-83eeaa93f3fe
md"""
## Wrapping cells in functions

Pluto [wraps the cell code in functions](https://github.com/fonsp/Pluto.jl/pull/720) if applicable.

> Similar to a REPL thunk compilation but with native code/inference caching.
>
> Much lower cost for mutable globals.
"""

# ╔═╡ 0c948331-2c0b-48a1-aee7-ffaa836776ae
# 1. Takes global references as parameters (no mutable global access)
function cell_code_function(name, uppercase)
	result = begin
		# 2. Embed cell code
		name_uppercase = uppercase(name)
		@htl "<h3>Welcome $name_uppercase</h3>"
	end

	# 3. Returns output result and each assigned variables
	(result, (name_uppercase,))
end

# ╔═╡ 81cf4d97-9e80-41c9-9bdb-a4dabab7c137
md"""
## Meta-programming
"""

# ╔═╡ e9e70cde-c9cf-47c1-9528-734dd41adba9
md"""
> Macros can have arbitrary definitions and references.
> ```julia
> using Symbolics
> 
> @variables x y z
> 
> result = x + y * z
> ```
> Pluto uses `macroexpand` to analyse the code produced by macros.
"""

# ╔═╡ 33845bd2-0517-4b16-bf1c-a880a45816e7
dump(:(@variables x y z))

# ╔═╡ d4ffa100-0805-49b5-b26b-43e9a77796c6
md"""
##
"""

# ╔═╡ 3ca6fe04-61ca-4c75-ab6c-3ad4385bec26
macro my_macro(names...)
	exprs = map(names) do name
		:($(esc(name)) = rand())
	end
	Expr(:block, exprs...)
end

# ╔═╡ cc61f6b6-f3a6-48e2-98bd-0624b1be96f5
@macroexpand @my_macro x y

# ╔═╡ 75dd17dd-4a43-4443-b9c2-b4a62223d9e0
ExpressionExplorer.compute_reactive_node(:(@my_macro x y))

# ╔═╡ 1242fd3b-92ee-48b4-90c3-a622364ce014
ExpressionExplorer.compute_reactive_node(@macroexpand @my_macro x y)

# ╔═╡ 9b70f31e-ab7a-4885-a74d-9d19514d0b51
md"""
##
"""

# ╔═╡ 454bb746-57a8-48b6-a55a-f32ed735f233
@my_macro x

# ╔═╡ 1c56e96f-856d-4cdf-b692-cdc1ed88e59b
x

# ╔═╡ 78d8db2e-b0f1-4989-85d2-e76c511ad911
@macroexpand @my_macro x

# ╔═╡ dee5994b-4e3f-49ad-b352-637870640b3b
md"""
## Cell lifecycle

> Expanded expressions are cached and reused.
> ```julia
> # 1. Macroexpand once and analyze definitions/references.
> expr = macroexpand(@__MODULE__, cell_code)
> reactive_node = ExpressionExplorer.compute_reactive_node(expr)
>
> # 2. For every run, only eval the expanded expressions.
> result = eval(@__MODULE__, expr)
> ```
>
>  - Costly expansion costs are amortized.
>  - Hypothesis: macroexpansion should be deterministic.
>  - Consistent behavior with function wrapping (macroexpansion happens when the function is defined).
"""

# ╔═╡ 232f1b0d-bcf2-4215-acf6-fdeb8777772d
md"""
Example expansion from the `HypertextLiteral.@htl` macro:
"""

# ╔═╡ 7854e856-b558-47ed-848d-da63ab030b2d
@macroexpand @htl "<h3>Welcome $name</h3>"

# ╔═╡ d342fd52-1f34-4618-b7e0-5f6fb38470a7
function cell_code_expanded(name)
	 @htl "<h3>Welcome $name</h3>"
end

# ╔═╡ a4550c48-1c45-4785-bd3e-9732ad5aeae6
md"""
## Expression cache

The cached expression is used when:

 - The cell is run because a parent cell was updated.
 - The cell is run because of a reference to a `@bind`ed value.

> This is an **implicit** run.
"""

# ╔═╡ e525054f-9d94-41dd-9bc3-20f0012ccd77
md"""
The expression cache is reset when:

 - Pressing $(html"<kbd>Shift</kbd>") + $(html"<kbd>Enter</kbd>").
 - Pressing the run button.
 - One of the called macros is redefined.

> This is an **explicit** run.
"""

# ╔═╡ b5e4b8ec-8fb4-4ff5-9430-78c853ddf368
md"""
## PlutoHooks.jl
"""

# ╔═╡ e213bf20-f7d9-4b3f-9474-cac6975628a3
md"""
A set of macros heavily inspired by React.js hooks. Which can be used to:

 - Adding state to cells.
 - Rerunning cells from Julia.
 - Handling side-effects.
"""

# ╔═╡ 63d6141e-efb1-4a81-8fa4-dc537a79dc6e
md"""
## `@use_ref(initial_value)`

Returns a `Ref` which is consistent across *implicit* re-runs. The value of the reference is reset on *explicit* runs.
"""

# ╔═╡ 5526549e-a33a-4cb0-bf54-6e2dedb0652b
macro my_use_ref(initial_value)
	ref = Ref{Any}(nothing)

	quote
		if $(ref)[] === nothing
			$(ref)[] = $(esc(initial_value))
		end
		$ref
	end
end

# ╔═╡ 20149133-2a73-4851-8774-837b0044f835
@bind value Slider(0:10, show_value=true)

# ╔═╡ 9e7f8f43-384f-4fad-bb5c-044a80d8d1e1
begin
	sum_of_all_values = @use_ref(0)
	sum_of_all_values[] += value
end

# ╔═╡ 6e02d754-e055-4c9c-9e72-20d487eb740c
sum_of_all_values

# ╔═╡ 5b755fa1-3914-419d-ad38-eca9495a12e4
md"""
## `@use_state(initial_value)`

Returns the current state value and a callback to update the value and trigger a run for the cell.
"""

# ╔═╡ ccef9e0c-4a70-4ee2-9c74-b46e6dd06051
state = let
	state, set_state = @use_state(:loading)

	if state === :loading
		@async begin
			sleep(1.)
			set_state(:done)
		end
	end

	state
end

# ╔═╡ 708c9c4d-ceed-4cfb-b7de-a16bc5296caf
state

# ╔═╡ 6175e2b3-4ce6-4994-81e2-2bd54e2629dd
md"""
!!! warning
	It is very easy to introduce infinite loops with `@use_state()` by unconditionnally calling `set_state()`.
"""

# ╔═╡ b94a1ac7-81b9-448d-938b-5c31023b637a
md"""
## `@use_effect(f, dependencies)`

Perform a computation only when values of dependencies change (`old_value != new_value`).
"""

# ╔═╡ 6661b9c8-758f-47d0-8150-9f0c8f4661da
@bind name TextField(default="Bob")

# ╔═╡ 4a1d33f2-d780-42d8-8e69-162041ccc60e
begin
	name_uppercase = uppercase(name)
	@htl "<h3>Welcome $name_uppercase</h3>"
end;

# ╔═╡ 00ce23cb-9039-4d2b-8bf6-50f652a026d7
let (result, (name_uppercase_local,)) = cell_code_function(name, uppercase)
	global name_uppercase2 = name_uppercase_local
	result
end;

# ╔═╡ d56db069-14ce-4bfd-95c4-a1bd073d5b4e
save_name_to_database!(name) = nothing; # imagine that it saves!

# ╔═╡ 6376dd09-69fc-4193-bd19-15202651e652
@use_effect([lowercase(name)]) do
	save_name_to_database!(name)

	return nothing
end

# ╔═╡ 7dab41a2-e3bb-4a1f-8fb1-83df644e2050
md"""
An empty dependency array will perform the computation only once.
"""

# ╔═╡ c2e83939-a53e-4a46-870e-ee1cb4f063d4
@use_effect([]) do
	@info "Cell was run!"
end

# ╔═╡ 005433a6-1418-47a4-b28c-1ec7bba58314
md"""
##

The return value of the effectful computation can return a cleanup callback. This callback is called when the expression cache is cleared (on *explicit* runs).
"""

# ╔═╡ d9f3742e-3c4d-4c28-aa6e-83537a9c1d51
port = 8080;

# ╔═╡ 4852e03c-6b4c-4445-a510-8d119a901afc
start_server(port) = nothing; stop(server) = nothing;

# ╔═╡ 1e2cb989-f33d-4d35-8897-df07e6c08c48
@use_effect([port]) do
	server = start_server(port)
	() -> stop(server)
end

# ╔═╡ b2a72302-c03c-48b0-ae91-afa430c78838
data = randn(1000);

# ╔═╡ 872a86f0-b54c-4c3c-a9e8-0481de575c85
λ = 1.5

# ╔═╡ fd1eeb9e-d8c8-4a31-86ca-a4b7c33fa8da
function train_model(λ, data)
	sleep(.3abs(randn())) # hehe nice ml
	Text("Model (1 000 parameters)")
end;

# ╔═╡ 86b1ce71-ca31-421a-ba40-8f5117169d16
my_model = @use_memo([λ, train_model]) do
	train_model(λ, data)
end

# ╔═╡ f817e3f3-8836-46eb-9136-db1cfff506f9
md"""
It is a combination of `@use_effect` and `@use_ref`.
"""

# ╔═╡ 4d897464-1ee0-4ee9-b52a-bb792232689f
md"""
## PlutoLinks.jl
"""

# ╔═╡ af2433b1-ed00-4c4f-b058-03ffa370a7ff
md"""
> Combining `@use_state` with `@use_effect` to trigger running cells with Julia events. 
"""

# ╔═╡ d64f3ffb-7e6d-4e39-90cc-2b35911cb586
md"""
 1. Have a state variable with `@use_state`.
 2. Use `@use_effect` to spawn task and interrupt task on explicit runs.
 3. The task calls the `set_state` callback when an event happens.
"""

# ╔═╡ 7bdcc6e2-2edf-44a8-a26e-55b68e2d0e37
md"""
##
"""

# ╔═╡ d660b53f-7298-4ee7-ba19-f29a38c2e73e
Docs.Binding(PlutoLinks, Symbol("@use_file"))

# ╔═╡ 82b1e171-41aa-4402-bf52-d2f855ac1361
md"""
##
"""

# ╔═╡ 819cf6f6-e725-4fe2-9327-a1ea2f2851e5
Docs.Binding(PlutoLinks, Symbol("@revise"))

# ╔═╡ 0a678b6f-29a2-4fe7-9a8a-611e4ad76dcd
md"""
# Thank you for listening! 🎈

 - `Pluto.jl` channel on the [JuliaLang Zulip](https://julialang.zulipchat.com).
 - Meetup tomorrow in Eindhoven.
"""

# ╔═╡ b61cc444-fabc-42e4-b2d5-5479f825d38f
md"""
##
"""

# ╔═╡ f8919c7c-e84d-4ae3-b729-b535690478b0
md"""
---
"""

# ╔═╡ 0443ec44-bebe-4da2-97e7-741d17063070
html"""
<style>
  	main, pluto-notebook {
		// width: 900px !important;
	}

	h1, h2 {
		page-break-before: always;
	}

	h1, h2, h3, h4 {
		text-align: center;
	}

	div.edit_or_run {
		display: none !important;
	}
</style>
"""

# ╔═╡ 5c2d3abe-ac1c-4a2e-83b4-1c7a629611a0
strikethrough(val) = @htl "<s>$(val)</s>"

# ╔═╡ 17b647ea-4623-43e5-9f73-aec1f31b9d19
@markdown """
## `@use_memo(f, dependencies)`

> A common way to optimize re-rendering performance is to skip unnecessary work.
> For example, you can tell $(strikethrough("React")) Pluto to reuse a cached calculation.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractPlutoDingetjes = "6e696c72-6542-2067-7265-42206c756150"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
ExpressionExplorer = "21656369-7473-754a-2065-74616d696c43"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
PlutoHooks = "0ff47ea0-7a50-410d-8455-4348d5de0774"
PlutoLinks = "0ff47ea0-7a50-410d-8455-4348d5de0420"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractPlutoDingetjes = "~1.2.2"
ExpressionExplorer = "~1.0.0"
HypertextLiteral = "~0.9.5"
MarkdownLiteral = "~0.1.1"
Pluto = "~0.19.32"
PlutoHooks = "~0.0.5"
PlutoLinks = "~0.1.6"
PlutoUI = "~0.7.54"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0-rc1"
manifest_format = "2.0"
project_hash = "8925a67413ba76ea40a753cd3321a0dd5fc3add8"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "PrecompileTools", "URIs"]
git-tree-sha1 = "532c4185d3c9037c0237546d817858b23cf9e071"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.12"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "4358750bb58a3caefd5f37a4a0c5bfdbbf075252"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.6"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.ExpressionExplorer]]
git-tree-sha1 = "bce17cd0180a75eec637d6e3f8153011b8bdb25a"
uuid = "21656369-7473-754a-2065-74616d696c43"
version = "1.0.0"

[[deps.ExproniconLite]]
git-tree-sha1 = "fbc390c2f896031db5484bc152a7e805ecdfb01f"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.5"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "c8d37d615586bea181063613dccc555499feb298"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.3"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0592b1810613d1c95eeebcd22dc11fba186c2a57"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.26"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "8f7f3cabab0fd1800699663533b6d5cb3fc0e612"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.2"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Malt]]
deps = ["Distributed", "Logging", "RelocatableFolders", "Serialization", "Sockets"]
git-tree-sha1 = "5333200b6a2c49c2de68310cede765ebafa255ea"
uuid = "36869731-bdee-424d-aa32-cab38c994e3b"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "fc8c15ca848b902015bd4a745d350f02cf791c2a"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.2.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "Downloads", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "LoggingExtras", "MIMEs", "Malt", "Markdown", "MsgPack", "Pkg", "PrecompileSignatures", "PrecompileTools", "REPL", "RegistryInstances", "RelocatableFolders", "Scratch", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "0b61bd2572c7c797a0e0c78c40b8cee740996ebb"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.19.32"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "bd7c69c7f7173097e7b5e1be07cee2b8b7447f51"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.54"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "a38e7d70267283888bc83911626961f0b8d5966f"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.9"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─2b472858-8ace-11ee-32b4-2ddba7820910
# ╟─6bfb7e9d-d663-4d1b-be40-d5e14ab9b0e9
# ╟─1fae5c09-811f-461d-a89a-050500332c3b
# ╠═df528e09-be02-4946-9b3a-dcca89f59359
# ╠═dcc713c0-12ed-4e0e-bff0-bbaa4feac845
# ╟─f8071483-9440-4123-8d02-1585f4c80ed0
# ╠═774a864e-f283-4e47-a86d-a64349dc658c
# ╠═916e7bfb-1b0b-4eee-aec1-7a4456873d5f
# ╠═cfe39d27-4aac-44d7-8918-75fe1889382d
# ╟─e8d69dd1-5f30-42d9-8fd2-9c0e285d03ca
# ╟─9b434e82-a50a-4d69-a322-f0581fe3dc2a
# ╠═2618e467-eb22-4a20-8ff1-14b5179d0d9d
# ╠═ff7195c2-7875-4d15-b4a6-42147f0dd659
# ╟─9a188c6b-d59a-404a-bf35-92460115fad4
# ╟─ce714f47-dbbe-47d3-a47f-70179f02f71b
# ╟─6717df0a-11b9-4a88-9926-ad876c5d6f68
# ╟─f7686455-b5ec-4995-8807-9ccc35f52fa6
# ╟─2294b1d7-ed9b-4157-a5b1-7b76d4239195
# ╟─dfa77823-13fd-4cd1-8ccd-24ab37999c9a
# ╟─e7231536-f826-4267-9cd5-8703edd864cf
# ╟─15bca6db-bf7e-4ee7-8f3b-17d2f20154bd
# ╠═2c88eed5-14d6-40b3-9071-6eb8529271c6
# ╠═88fa15e5-bea4-4cb8-8962-49ff2308ae46
# ╠═e3bcc5c3-bd1f-4b94-ba1d-655093745fbd
# ╟─2d859911-1fb5-4345-a563-9147767eaae0
# ╟─bbbd515e-e584-4b36-8534-f87c32b98e53
# ╠═464cda52-4f51-4e14-9cee-59d912dc6617
# ╟─05db9a59-c826-43b8-b28e-940e8557e250
# ╠═83f87a68-2416-42df-aa3b-d8addb7d2e36
# ╟─fd3b2ef1-af67-481c-a847-d3dca4aa2e72
# ╠═ce2cd8f5-bbd8-4e78-b62f-c1227b17ed57
# ╠═95fbcd7b-5753-4bbb-a155-32079118dbc0
# ╟─bc97a180-d986-43a4-9e21-83eeaa93f3fe
# ╠═4a1d33f2-d780-42d8-8e69-162041ccc60e
# ╠═0c948331-2c0b-48a1-aee7-ffaa836776ae
# ╠═00ce23cb-9039-4d2b-8bf6-50f652a026d7
# ╟─81cf4d97-9e80-41c9-9bdb-a4dabab7c137
# ╟─e9e70cde-c9cf-47c1-9528-734dd41adba9
# ╠═33845bd2-0517-4b16-bf1c-a880a45816e7
# ╟─d4ffa100-0805-49b5-b26b-43e9a77796c6
# ╠═3ca6fe04-61ca-4c75-ab6c-3ad4385bec26
# ╠═cc61f6b6-f3a6-48e2-98bd-0624b1be96f5
# ╠═75dd17dd-4a43-4443-b9c2-b4a62223d9e0
# ╠═1242fd3b-92ee-48b4-90c3-a622364ce014
# ╟─9b70f31e-ab7a-4885-a74d-9d19514d0b51
# ╠═454bb746-57a8-48b6-a55a-f32ed735f233
# ╠═1c56e96f-856d-4cdf-b692-cdc1ed88e59b
# ╠═78d8db2e-b0f1-4989-85d2-e76c511ad911
# ╟─dee5994b-4e3f-49ad-b352-637870640b3b
# ╟─232f1b0d-bcf2-4215-acf6-fdeb8777772d
# ╠═7854e856-b558-47ed-848d-da63ab030b2d
# ╠═d342fd52-1f34-4618-b7e0-5f6fb38470a7
# ╟─a4550c48-1c45-4785-bd3e-9732ad5aeae6
# ╟─e525054f-9d94-41dd-9bc3-20f0012ccd77
# ╟─b5e4b8ec-8fb4-4ff5-9430-78c853ddf368
# ╠═94bc7835-2f35-46b7-bcbd-64a8761172a4
# ╟─e213bf20-f7d9-4b3f-9474-cac6975628a3
# ╟─63d6141e-efb1-4a81-8fa4-dc537a79dc6e
# ╠═5526549e-a33a-4cb0-bf54-6e2dedb0652b
# ╠═20149133-2a73-4851-8774-837b0044f835
# ╠═9e7f8f43-384f-4fad-bb5c-044a80d8d1e1
# ╠═6e02d754-e055-4c9c-9e72-20d487eb740c
# ╟─5b755fa1-3914-419d-ad38-eca9495a12e4
# ╠═ccef9e0c-4a70-4ee2-9c74-b46e6dd06051
# ╠═708c9c4d-ceed-4cfb-b7de-a16bc5296caf
# ╟─6175e2b3-4ce6-4994-81e2-2bd54e2629dd
# ╟─b94a1ac7-81b9-448d-938b-5c31023b637a
# ╠═6661b9c8-758f-47d0-8150-9f0c8f4661da
# ╠═6376dd09-69fc-4193-bd19-15202651e652
# ╟─d56db069-14ce-4bfd-95c4-a1bd073d5b4e
# ╟─7dab41a2-e3bb-4a1f-8fb1-83df644e2050
# ╠═c2e83939-a53e-4a46-870e-ee1cb4f063d4
# ╟─005433a6-1418-47a4-b28c-1ec7bba58314
# ╠═d9f3742e-3c4d-4c28-aa6e-83537a9c1d51
# ╠═1e2cb989-f33d-4d35-8897-df07e6c08c48
# ╟─4852e03c-6b4c-4445-a510-8d119a901afc
# ╟─17b647ea-4623-43e5-9f73-aec1f31b9d19
# ╠═b2a72302-c03c-48b0-ae91-afa430c78838
# ╠═872a86f0-b54c-4c3c-a9e8-0481de575c85
# ╠═86b1ce71-ca31-421a-ba40-8f5117169d16
# ╟─fd1eeb9e-d8c8-4a31-86ca-a4b7c33fa8da
# ╟─f817e3f3-8836-46eb-9136-db1cfff506f9
# ╟─4d897464-1ee0-4ee9-b52a-bb792232689f
# ╠═134e0517-cca3-454c-ae3c-41e3acda3272
# ╟─af2433b1-ed00-4c4f-b058-03ffa370a7ff
# ╟─d64f3ffb-7e6d-4e39-90cc-2b35911cb586
# ╟─7bdcc6e2-2edf-44a8-a26e-55b68e2d0e37
# ╟─d660b53f-7298-4ee7-ba19-f29a38c2e73e
# ╟─82b1e171-41aa-4402-bf52-d2f855ac1361
# ╟─819cf6f6-e725-4fe2-9327-a1ea2f2851e5
# ╟─0a678b6f-29a2-4fe7-9a8a-611e4ad76dcd
# ╟─b61cc444-fabc-42e4-b2d5-5479f825d38f
# ╟─f8919c7c-e84d-4ae3-b729-b535690478b0
# ╠═242a12bc-7fe0-4709-8998-11b1de027209
# ╠═676eb519-75f3-45e9-84b3-e85ff0b05f50
# ╠═cb2c29ab-c8af-4efa-bc9a-dad95cd28fb6
# ╠═0443ec44-bebe-4da2-97e7-741d17063070
# ╠═5c2d3abe-ac1c-4a2e-83b4-1c7a629611a0
# ╟─d642567e-ed4e-4815-96b1-a9f6bfd1aea3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
