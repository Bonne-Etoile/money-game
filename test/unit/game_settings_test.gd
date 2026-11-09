extends GdUnitTestSuite
## The player's options (game/core/game_settings.gd).


func test_defaults() -> void:
	var settings: GameSettings = GameSettings.new()
	assert_float(settings.mouse_sensitivity).is_equal(1.0)
	assert_bool(settings.invert_y).is_false()
	assert_float(settings.field_of_view).is_equal(80.0)
	assert_bool(settings.vsync).is_true()
	assert_str(settings.language).is_empty()
	assert_bool(settings.refill_together).is_false()
	assert_bool(settings.vibration).is_true()


func test_round_trip_through_json() -> void:
	var settings: GameSettings = GameSettings.new()
	settings.set_mouse_sensitivity(1.75)
	settings.invert_y = true
	settings.set_field_of_view(95.0)
	settings.vsync = false
	settings.set_language("fr")
	settings.refill_together = true
	settings.vibration = false
	var copy: GameSettings = GameSettings.from_json(settings.to_json())
	assert_float(copy.mouse_sensitivity).is_equal(1.75)
	assert_bool(copy.invert_y).is_true()
	assert_float(copy.field_of_view).is_equal(95.0)
	assert_bool(copy.vsync).is_false()
	assert_str(copy.language).is_equal("fr")
	assert_bool(copy.refill_together).is_true()
	assert_bool(copy.vibration).is_false()


func test_values_stay_in_their_range() -> void:
	var settings: GameSettings = GameSettings.new()
	settings.set_mouse_sensitivity(50.0)
	settings.set_field_of_view(10.0)
	settings.set_language("klingon")
	assert_float(settings.mouse_sensitivity).is_equal(GameSettings.SENSITIVITY_RANGE.y)
	assert_float(settings.field_of_view).is_equal(GameSettings.FIELD_OF_VIEW_RANGE.x)
	assert_str(settings.language).is_empty()


func test_invalid_text_gives_the_defaults() -> void:
	for text: String in ["", "not json", "[1]", '{"mouse_sensitivity": 2}']:
		assert_float(GameSettings.from_json(text).mouse_sensitivity).is_equal(1.0)


func test_the_locale_follows_the_system_unless_chosen() -> void:
	var settings: GameSettings = GameSettings.new()
	assert_str(settings.locale("fr")).is_equal("fr")
	# A system language the game does not have: English.
	assert_str(settings.locale("ja")).is_equal("en")
	settings.set_language("en")
	assert_str(settings.locale("fr")).is_equal("en")
