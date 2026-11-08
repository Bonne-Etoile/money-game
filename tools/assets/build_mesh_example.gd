extends SceneTree
## Example of a model built by code in Godot (SurfaceTool): a low poly crate, coloured by
## vertex colours, saved as a mesh resource with its levels of detail. Copy it for simple or
## procedural models; reproducible (same code, same model). Method: docs/recettes/modeles-3d.md.
## Usage: godot --headless --path . --script res://tools/assets/build_mesh_example.gd -- \
##   [--out=res://assets/models/example/crate.res]

const DEFAULT_OUT: String = "res://assets/models/example/crate.res"
## Side of the crate, in metres (Godot: y up, the front looks towards +z).
const SIZE: float = 0.6
## Width of the planks drawn on each face.
const PLANK: float = 0.08
## Colours as thought in sRGB: vertex colours are read as linear, so they are converted.
const WOOD: Color = Color(0.62, 0.42, 0.24)
const DARK_WOOD: Color = Color(0.42, 0.27, 0.15)


func _initialize() -> void:
	var out: String = DEFAULT_OUT
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			out = argument.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()))
	var mesh: ArrayMesh = _with_lods(_crate(), "crate")
	var error: Error = ResourceSaver.save(mesh, out)
	print("mesh: %s %s" % [out, "ok" if error == OK else error_string(error)])
	quit(0 if error == OK else 1)


func _crate() -> ArrayMesh:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half: float = SIZE / 2.0
	# The body, then a frame of darker planks standing slightly out of each side face.
	_box(tool, Vector3(0, half, 0), Vector3(half, half, half), WOOD)
	for side: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var across: Vector3 = side.cross(Vector3.UP)
		var face: Vector3 = side * (half + PLANK / 4.0)
		var extent: Vector3 = across.abs() * half + side.abs() * PLANK / 4.0
		for height: float in [PLANK / 2.0, SIZE - PLANK / 2.0]:
			_box(
				tool,
				face + Vector3(0, height, 0),
				extent + Vector3(0, PLANK / 2.0, 0),
				DARK_WOOD,
			)
	tool.generate_normals()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.9
	tool.set_material(material)
	return tool.commit()


## An axis-aligned box centred on `center`, `extent` from the centre to each face.
## Faces turn clockwise seen from outside (Godot's front faces): the other order is culled.
func _box(tool: SurfaceTool, center: Vector3, extent: Vector3, color: Color) -> void:
	var linear: Color = color.srgb_to_linear()
	for normal: Vector3 in [
		Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK
	]:
		var u: Vector3 = normal.cross(Vector3.UP if absf(normal.y) < 0.5 else Vector3.RIGHT)
		var v: Vector3 = normal.cross(u)
		var corners: Array[Vector3] = []
		for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			corners.append(center + (normal + u * corner.x + v * corner.y) * extent)
		for index: int in [0, 2, 1, 0, 3, 2]:
			tool.set_color(linear)
			tool.add_vertex(corners[index])


## The mesh with its levels of detail, as Godot makes them when importing a model. Each
## surface is indexed first: without indices, generate_lods makes nothing, and says nothing.
static func _with_lods(mesh: ArrayMesh, mesh_name: String) -> ArrayMesh:
	var importer: ImporterMesh = ImporterMesh.new()
	for surface in mesh.get_surface_count():
		var tool: SurfaceTool = SurfaceTool.new()
		tool.create_from(mesh, surface)
		tool.index()
		importer.add_surface(
			Mesh.PRIMITIVE_TRIANGLES,
			tool.commit_to_arrays(),
			[],
			{},
			mesh.surface_get_material(surface)
		)
	importer.generate_lods(25.0, 60.0, [])
	var result: ArrayMesh = importer.get_mesh()
	result.resource_name = mesh_name
	return result
