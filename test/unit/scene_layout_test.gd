extends GdUnitTestSuite
## Guards the layout of the scenes against a trap of the export: each Control's saved
## `anchors_preset` and grow directions must match what Godot computes from its anchors.
## Otherwise the export writes the computed values into every inherited scene, and applying
## the preset there moves the node (docs/pitfalls/godot-gdscript-et-scenes.md).

const LAYOUT_PROPERTIES: Array[StringName] = [
	&"anchors_preset", &"grow_horizontal", &"grow_vertical"
]


func test_saved_anchor_presets_match_the_anchors() -> void:
	for path in _scenes("res://game"):
		var packed: PackedScene = load(path)
		var state: SceneState = packed.get_state()
		var scene: Node = auto_free(packed.instantiate())
		for index in state.get_node_count():
			var node: Control = scene.get_node_or_null(state.get_node_path(index)) as Control
			if node == null:
				continue
			for property in state.get_node_property_count(index):
				var name: StringName = state.get_node_property_name(index, property)
				if name in LAYOUT_PROPERTIES:
					var saved: int = state.get_node_property_value(index, property)
					var computed: int = node.get(name)
					(
						assert_int(computed)
						. override_failure_message(
							(
								"%s %s: %s saved %d, computed %d"
								% [path, state.get_node_path(index), name, saved, computed]
							)
						)
						. is_equal(saved)
					)


func _scenes(folder: String) -> Array[String]:
	var found: Array[String] = []
	for file in DirAccess.get_files_at(folder):
		if file.ends_with(".tscn"):
			found.append(folder.path_join(file))
	for child in DirAccess.get_directories_at(folder):
		found.append_array(_scenes(folder.path_join(child)))
	return found
