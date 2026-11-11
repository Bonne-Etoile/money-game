extends Node
## Screenshot of a level where no piece fits any more while pieces are left (make
## screenshots): the end panel offers to go on after a rewarded ad, or to try again.

const SCENE: PackedScene = preload("res://game/levels/level.tscn")


func _ready() -> void:
	var screen: LevelScreen = SCENE.instantiate()
	screen.level_index = 0
	add_child(screen)
	var size: int = screen.game.grid.size
	for y in size:
		for x in size:
			screen.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	screen.refresh()
