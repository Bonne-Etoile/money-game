extends SceneTree
## Renders a scene for a few frames and saves a PNG, so that Claude can see the game.
## Needs a display (Xvfb): headless mode has no pixels. Use `make screenshot`.
##
## User arguments (after `--`):
##   --scene=res://...       scene to render (required)
##   --out=/abs/path.png     output file, absolute path (required)
##   --camera=x,y,z          adds a camera at this position (otherwise the scene's camera is used)
##   --look-at=x,y,z         point the added camera looks at (default: 0,0,0)
##   --frames=N              frames rendered before the capture (default: 10)
##   --locale=fr             interface language (default: the system language)

const DEFAULT_FRAMES: int = 10

var _frames_left: int = DEFAULT_FRAMES
var _out_path: String = ""


func _initialize() -> void:
	var options: Dictionary[String, String] = _parse_user_args()
	var scene_path: String = options.get("scene", "")
	_out_path = options.get("out", "")
	if scene_path.is_empty() or not _out_path.is_absolute_path():
		_fail("usage: -- --scene=res://... --out=/absolute/path.png [--camera=x,y,z]")
		return
	var packed: PackedScene = load(scene_path)
	if packed == null:
		_fail("cannot load %s" % scene_path)
		return
	if options.has("locale"):
		TranslationServer.set_locale(options["locale"])
	var frames: String = options.get("frames", str(DEFAULT_FRAMES))
	_frames_left = frames.to_int()
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	if options.has("camera"):
		# The tree is not running yet in _initialize: set the transform directly, not look_at().
		var position: Vector3 = _parse_vector(options["camera"])
		var look_at_text: String = options.get("look-at", "0,0,0")
		var target: Vector3 = _parse_vector(look_at_text)
		var camera: Camera3D = Camera3D.new()
		camera.transform = Transform3D(Basis.looking_at(target - position), position)
		camera.current = true
		scene.add_child(camera)


func _process(_delta: float) -> bool:
	if _out_path.is_empty():
		return true
	_frames_left -= 1
	if _frames_left > 0:
		return false
	var image: Image = root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(_out_path.get_base_dir())
	var error: Error = image.save_png(_out_path)
	if error != OK:
		_fail("cannot write %s (%s)" % [_out_path, error_string(error)])
		return true
	print("screenshot: %s (%dx%d)" % [_out_path, image.get_width(), image.get_height()])
	quit(0)
	return true


func _parse_user_args() -> Dictionary[String, String]:
	var options: Dictionary[String, String] = {}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--") and arg.contains("="):
			options[arg.substr(2).get_slice("=", 0)] = arg.get_slice("=", 1)
	return options


func _parse_vector(text: String) -> Vector3:
	var parts: PackedFloat64Array = text.split_floats(",")
	if parts.size() != 3:
		_fail("expected x,y,z but got %s" % text)
		return Vector3.ZERO
	return Vector3(parts[0], parts[1], parts[2])


func _fail(message: String) -> void:
	printerr("screenshot: " + message)
	_out_path = ""
	quit(1)
