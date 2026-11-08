extends GdUnitTestSuite
## The saved sound volumes (game/core/audio_settings.gd).


func test_defaults_are_full_volume() -> void:
	var settings: AudioSettings = AudioSettings.new()
	for kind in AudioSettings.KINDS:
		assert_float(settings.volume(kind)).is_equal(1.0)


func test_volumes_stay_between_zero_and_one() -> void:
	var settings: AudioSettings = AudioSettings.new()
	settings.set_volume(&"music", 1.5)
	settings.set_volume(&"effects", -0.2)
	assert_float(settings.volume(&"music")).is_equal(1.0)
	assert_float(settings.volume(&"effects")).is_equal(0.0)


func test_unknown_kinds_are_ignored() -> void:
	var settings: AudioSettings = AudioSettings.new()
	settings.set_volume(&"voices", 0.3)
	assert_float(settings.volume(&"voices")).is_equal(0.0)
	assert_bool(settings.to_dict().has("voices")).is_false()


func test_round_trip_through_json() -> void:
	var settings: AudioSettings = AudioSettings.new()
	settings.set_volume(&"master", 0.8)
	settings.set_volume(&"music", 0.25)
	settings.set_volume(&"effects", 0.0)
	var copy: AudioSettings = AudioSettings.from_json(settings.to_json())
	assert_float(copy.volume(&"master")).is_equal_approx(0.8, 0.0001)
	assert_float(copy.volume(&"music")).is_equal_approx(0.25, 0.0001)
	assert_float(copy.volume(&"effects")).is_equal(0.0)


func test_the_file_is_versioned() -> void:
	var version: int = AudioSettings.new().to_dict()["version"]
	assert_int(version).is_equal(AudioSettings.VERSION)


func test_invalid_text_gives_the_defaults() -> void:
	for text: String in ["", "not json", "[1, 2]", '{"music": 0.2}']:
		var settings: AudioSettings = AudioSettings.from_json(text)
		assert_float(settings.volume(&"music")).is_equal(1.0)


func test_wrong_values_are_ignored() -> void:
	var settings: AudioSettings = AudioSettings.from_dict(
		{"version": 1, "master": "loud", "music": 0.5, "effects": null}
	)
	assert_float(settings.volume(&"master")).is_equal(1.0)
	assert_float(settings.volume(&"music")).is_equal(0.5)
	assert_float(settings.volume(&"effects")).is_equal(1.0)
