extends Node
## Screenshot of the level mode (make screenshots, G17): `level` played by the robot for
## `moves` moves (gold, ice and stones on the grid, the goal and its bar), or to its end
## (`moves` < 0: the end panel).

const SCENE: PackedScene = preload("res://game/levels/level.tscn")

@export var level: int = 9
@export var moves: int = 2


func _ready() -> void:
	var screen: LevelScreen = SCENE.instantiate()
	screen.level_index = level
	add_child(screen)
	if moves < 0:
		LevelRobot.play(screen.level)
	else:
		for _move in moves:
			LevelRobot.play_one(screen.level)
	screen.refresh()
