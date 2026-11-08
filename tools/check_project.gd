extends SceneTree
## Loads every script, scene and resource of the project and exits with 1 if one fails.
## Usage: godot --headless --path . --script res://tools/check_project.gd

const SKIPPED_DIRS: PackedStringArray = [
	"res://.godot", "res://addons", "res://build", "res://reports"
]
const CHECKED_EXTENSIONS: PackedStringArray = ["gd", "tscn", "tres"]


func _initialize() -> void:
	var paths: PackedStringArray = []
	_collect("res://", paths)
	var failures: PackedStringArray = []
	var own_script: Script = get_script()
	var own_path: String = own_script.resource_path
	for path in paths:
		# Reloading the running script with CACHE_MODE_IGNORE crashes the engine.
		if path == own_path:
			continue
		if not _loads(path):
			failures.append(path)
	for path in failures:
		printerr("check: failed to load %s" % path)
	print("check: %d files checked, %d failures" % [paths.size(), failures.size()])
	quit(1 if failures.size() > 0 else 0)


func _collect(dir_path: String, paths: PackedStringArray) -> void:
	if dir_path.trim_suffix("/") in SKIPPED_DIRS:
		return
	for sub_dir in DirAccess.get_directories_at(dir_path):
		_collect(dir_path.path_join(sub_dir), paths)
	for file in DirAccess.get_files_at(dir_path):
		if file.get_extension() in CHECKED_EXTENSIONS:
			paths.append(dir_path.path_join(file))


func _loads(path: String) -> bool:
	var missing: PackedStringArray = _missing_dependencies(path)
	for dependency in missing:
		printerr("check: %s depends on missing %s" % [path, dependency])
	if not missing.is_empty():
		return false
	var resource: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if resource == null:
		return false
	if resource is Script:
		return (resource as Script).can_instantiate()
	return true


# A scene that references a missing file still loads, so dependencies are checked explicitly.
func _missing_dependencies(path: String) -> PackedStringArray:
	var missing: PackedStringArray = []
	for dependency in ResourceLoader.get_dependencies(path):
		var dependency_path: String = dependency
		var uid_found: bool = false
		if dependency.contains("::"):
			dependency_path = dependency.get_slice("::", 2)
			var uid: int = ResourceUID.text_to_id(dependency.get_slice("::", 0))
			uid_found = uid != ResourceUID.INVALID_ID and ResourceUID.has_id(uid)
		if not uid_found and not ResourceLoader.exists(dependency_path):
			missing.append(dependency_path)
	return missing
