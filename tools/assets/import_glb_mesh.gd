extends SceneTree
## Turns a model exported as glTF (Blender, an AI 3D tool) into a mesh resource of the game,
## with its levels of detail, and prints what it holds (surfaces, triangles, levels): the
## numbers to check against the budget (docs/recettes/modeles-3d.md). Materials of the glb
## are kept, except that a surface with vertex colours gets them as albedo: Godot's glTF
## import ignores them otherwise, and the model shows white.
## Usage: godot --headless --path . --script res://tools/assets/import_glb_mesh.gd -- \
##   <file.glb> <res://assets/models/.../name.res>
## A glb can also simply be dropped in assets/ and used as a scene: this tool is for meshes
## that the game instantiates by the thousand (MultiMesh, shared meshes).


func _initialize() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if arguments.size() != 2:
		printerr("usage: -- <file.glb> <res://.../name.res>")
		quit(1)
		return
	var document: GLTFDocument = GLTFDocument.new()
	var state: GLTFState = GLTFState.new()
	if document.append_from_file(arguments[0], state) != OK:
		printerr("import: cannot read %s" % arguments[0])
		quit(1)
		return
	var scene: Node = document.generate_scene(state)
	var found: Array[Node] = scene.find_children("*", "MeshInstance3D", true, false)
	if found.size() != 1:
		printerr("import: expected one mesh in %s, found %d" % [arguments[0], found.size()])
		scene.free()
		quit(1)
		return
	var source: Mesh = (found[0] as MeshInstance3D).mesh
	var importer: ImporterMesh = ImporterMesh.new()
	for surface in source.get_surface_count():
		var tool: SurfaceTool = SurfaceTool.new()
		tool.create_from(source, surface)
		tool.index()
		var arrays: Array = tool.commit_to_arrays()
		importer.add_surface(
			Mesh.PRIMITIVE_TRIANGLES,
			arrays,
			[],
			{},
			_material(source.surface_get_material(surface), arrays[Mesh.ARRAY_COLOR] != null)
		)
	importer.generate_lods(25.0, 60.0, [])
	var mesh: ArrayMesh = importer.get_mesh()
	mesh.resource_name = arguments[1].get_file().get_basename()
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(arguments[1].get_base_dir())
	)
	var error: Error = ResourceSaver.save(mesh, arguments[1])
	print("import: %s %s" % [arguments[1], "ok" if error == OK else error_string(error)])
	for surface in mesh.get_surface_count():
		var details: Dictionary = RenderingServer.mesh_get_surface(mesh.get_rid(), surface)
		var lods: Array = details.get("lods", [])
		var indices: PackedInt32Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX]
		print(
			(
				"import: surface %d, %d triangles, %d levels of detail"
				% [surface, indices.size() / 3, lods.size()]
			)
		)
	scene.free()
	quit(0 if error == OK else 1)


## The glb's material, made to show the vertex colours when the surface has some.
func _material(material: Material, has_colors: bool) -> Material:
	if not has_colors:
		return material
	var shown: StandardMaterial3D = StandardMaterial3D.new()
	if material is StandardMaterial3D:
		shown = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
	shown.vertex_color_use_as_albedo = true
	return shown
