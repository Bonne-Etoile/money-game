extends GdUnitTestSuite
## Every interface text is a key of locale/translations.csv, translated in every launch language.

const CSV_PATH: String = "res://locale/translations.csv"
const LAUNCH_LANGUAGES: PackedStringArray = ["en", "fr"]
const SCENES_DIR: String = "res://game"

var _header: PackedStringArray = []
var _rows: Array[PackedStringArray] = []


func before() -> void:
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	_header = file.get_csv_line()
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() > 1 or (row.size() == 1 and not row[0].is_empty()):
			_rows.append(row)


func test_header_has_launch_languages() -> void:
	for language in LAUNCH_LANGUAGES:
		(
			assert_bool(language in _header)
			. override_failure_message("missing column %s" % language)
			. is_true()
		)


func test_every_key_is_unique_and_translated() -> void:
	var seen: Dictionary[String, bool] = {}
	for row in _rows:
		var key: String = row[0]
		assert_str(key).is_not_empty()
		assert_bool(seen.has(key)).override_failure_message("duplicate key %s" % key).is_false()
		seen[key] = true
		for language in LAUNCH_LANGUAGES:
			var column: int = _header.find(language)
			var value: String = row[column] if column < row.size() else ""
			(
				assert_str(value)
				. override_failure_message("%s has no %s text" % [key, language])
				. is_not_empty()
			)


func test_translations_are_registered_in_project() -> void:
	var registered: PackedStringArray = ProjectSettings.get_setting(
		"internationalization/locale/translations", PackedStringArray()
	)
	for language in LAUNCH_LANGUAGES:
		var path: String = "res://locale/translations.%s.translation" % language
		(
			assert_bool(path in registered)
			. override_failure_message("%s not registered" % path)
			. is_true()
		)


func test_french_is_used_when_selected() -> void:
	var previous: String = TranslationServer.get_locale()
	TranslationServer.set_locale("fr")
	assert_str(tr("MENU_QUIT")).is_equal("Quitter")
	TranslationServer.set_locale(previous)


func test_scene_texts_are_translation_keys() -> void:
	var keys: Dictionary[String, bool] = {}
	for row in _rows:
		keys[row[0]] = true
	var text_line: RegEx = RegEx.create_from_string('(?m)^(?:text|placeholder_text) = "(.*)"$')
	for path in _scene_paths(SCENES_DIR):
		var content: String = FileAccess.get_file_as_string(path)
		for found in text_line.search_all(content):
			var text: String = found.get_string(1)
			(
				assert_bool(keys.has(text))
				. override_failure_message('%s: "%s" is not a translation key' % [path, text])
				. is_true()
			)


func _scene_paths(dir_path: String) -> PackedStringArray:
	var paths: PackedStringArray = []
	for sub_dir in DirAccess.get_directories_at(dir_path):
		paths.append_array(_scene_paths(dir_path.path_join(sub_dir)))
	for file in DirAccess.get_files_at(dir_path):
		if file.get_extension() == "tscn":
			paths.append(dir_path.path_join(file))
	return paths
