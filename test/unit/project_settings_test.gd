extends GdUnitTestSuite
## Guards the project settings that the architecture relies on (docs/architecture.md).

const ERROR_LEVEL: int = 2


func test_physics_engine_is_jolt() -> void:
	assert_str(ProjectSettings.get_setting("physics/3d/physics_engine")).is_equal("Jolt Physics")


func test_renderer_is_forward_plus() -> void:
	assert_str(ProjectSettings.get_setting("rendering/renderer/rendering_method")).is_equal(
		"forward_plus"
	)


func test_typing_warnings_are_errors() -> void:
	for warning: String in [
		"untyped_declaration",
		"unsafe_property_access",
		"unsafe_method_access",
		"unsafe_cast",
		"unsafe_call_argument",
		"unsafe_void_return",
	]:
		var level: int = ProjectSettings.get_setting("debug/gdscript/warnings/" + warning)
		assert_int(level).override_failure_message("%s must be an error" % warning).is_equal(
			ERROR_LEVEL
		)


func test_main_scene_loads() -> void:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_object(load(main_scene)).is_instanceof(PackedScene)
