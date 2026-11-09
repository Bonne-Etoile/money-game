extends Node
## Screenshot of the level map (make screenshots, G17) with the first levels won.

const SCENE: PackedScene = preload("res://game/levels/level_map.tscn")


func _ready() -> void:
	GameState.progress.stats.levels_won = 4
	add_child(SCENE.instantiate())
