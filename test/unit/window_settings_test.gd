extends GdUnitTestSuite
## The saved game window (game/core/window_settings.gd).


func test_defaults_are_a_1280_by_720_window() -> void:
	var settings: WindowSettings = WindowSettings.new()
	assert_bool(settings.fullscreen).is_false()
	assert_that(settings.size).is_equal(Vector2i(1280, 720))
	assert_that(settings.position).is_null()


func test_round_trip_through_json() -> void:
	var settings: WindowSettings = WindowSettings.new()
	settings.fullscreen = true
	settings.size = Vector2i(800, 600)
	settings.position = Vector2i(1100, 40)
	var copy: WindowSettings = WindowSettings.from_json(settings.to_json())
	assert_bool(copy.fullscreen).is_true()
	assert_that(copy.size).is_equal(Vector2i(800, 600))
	assert_that(copy.position).is_equal(Vector2i(1100, 40))


func test_the_file_is_versioned() -> void:
	var version: int = WindowSettings.new().to_dict()["version"]
	assert_int(version).is_equal(WindowSettings.VERSION)


func test_invalid_text_gives_the_defaults() -> void:
	for text: String in ["", "not json", "[1, 2]", '{"width": 800, "height": 600}']:
		var settings: WindowSettings = WindowSettings.from_json(text)
		assert_that(settings.size).is_equal(Vector2i(1280, 720))


func test_wrong_values_are_ignored() -> void:
	var settings: WindowSettings = WindowSettings.from_dict(
		{"version": 1, "fullscreen": "yes", "width": "big", "height": 600, "x": 10}
	)
	assert_bool(settings.fullscreen).is_false()
	assert_that(settings.size).is_equal(Vector2i(1280, 720))
	assert_that(settings.position).is_null()


func test_a_tiny_window_is_enlarged_to_the_minimum() -> void:
	var settings: WindowSettings = WindowSettings.from_dict(
		{"version": 1, "width": 10, "height": 10}
	)
	assert_that(settings.size).is_equal(WindowSettings.MIN_SIZE)


func test_fits_on_a_screen_only_if_its_corner_is_visible() -> void:
	var screens: Array[Rect2i] = [Rect2i(0, 0, 1920, 1040)]
	var settings: WindowSettings = WindowSettings.new()
	assert_bool(settings.fits_on(screens)).is_false()
	settings.position = Vector2i(1280, 300)
	assert_bool(settings.fits_on(screens)).is_true()
	# Its screen was unplugged: the window would be out of sight.
	settings.position = Vector2i(2500, 300)
	assert_bool(settings.fits_on(screens)).is_false()
