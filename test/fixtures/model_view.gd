extends Node3D
## Shows models side by side under the game's light, to judge them on a screenshot of the game
## (never in the tool that made them). Used by `make model-view MODELS=res://a.res,res://b.glb`:
## the models come from the MODELS environment variable (mesh resources or scenes), spaced
## along x, the camera framing them all.

const SPACING: float = 1.0

@onready var _row: Node3D = $Row
@onready var _camera: Camera3D = $Camera


func _ready() -> void:
	var paths: PackedStringArray = OS.get_environment("MODELS").split(",", false)
	var width: float = 0.0
	var height: float = 0.5
	for path in paths:
		var node: Node3D = _instance(path.strip_edges())
		if node == null:
			push_error("model_view: cannot load %s" % path)
			continue
		_row.add_child(node)
		var bounds: AABB = _bounds(node)
		node.position.x = width - bounds.position.x
		width += bounds.size.x + SPACING
		height = maxf(height, bounds.size.y)
	width = maxf(width - SPACING, 0.5)
	var target: Vector3 = Vector3(width / 2.0, height / 2.0, 0)
	var distance: float = maxf(width, height) * 1.1 + 1.0
	var eye: Vector3 = target + Vector3(0, distance * 0.35, distance)
	_camera.transform = Transform3D(Basis.looking_at(target - eye), eye)


func _instance(path: String) -> Node3D:
	var resource: Resource = load(path)
	if resource is Mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = resource
		return mesh_instance
	if resource is PackedScene:
		return (resource as PackedScene).instantiate() as Node3D
	return null


func _bounds(node: Node3D) -> AABB:
	var bounds: AABB = AABB()
	var visuals: Array[Node] = node.find_children("*", "VisualInstance3D", true, false)
	visuals.append(node)
	for child: Node in visuals:
		var visual: VisualInstance3D = child as VisualInstance3D
		if visual != null:
			bounds = bounds.merge(visual.get_aabb())
	return bounds
