extends GdUnitTestSuite
## Guards the project settings that the architecture relies on (docs/architecture.md).

const ERROR_LEVEL: int = 2


## Compatibility (OpenGL ES 3) runs on the most Android phones (docs/architecture.md, 17).
func test_renderer_is_compatibility_on_every_platform() -> void:
	for setting: String in [
		"rendering/renderer/rendering_method", "rendering/renderer/rendering_method.mobile"
	]:
		assert_str(ProjectSettings.get_setting(setting)).is_equal("gl_compatibility")


func test_the_game_is_a_portrait_phone_screen() -> void:
	assert_int(ProjectSettings.get_setting("display/window/size/viewport_width")).is_equal(720)
	assert_int(ProjectSettings.get_setting("display/window/size/viewport_height")).is_equal(1280)
	assert_int(ProjectSettings.get_setting("display/window/handheld/orientation")).is_equal(
		DisplayServer.SCREEN_PORTRAIT
	)
	assert_str(ProjectSettings.get_setting("display/window/stretch/aspect")).is_equal("expand")


## Touch is turned into mouse events, so the `pointer` action covers both.
func test_touch_reaches_the_pointer_action() -> void:
	var emulated: bool = ProjectSettings.get_setting(
		"input_devices/pointing/emulate_mouse_from_touch"
	)
	assert_bool(emulated).is_true()
	assert_bool(InputMap.has_action("pointer")).is_true()


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
