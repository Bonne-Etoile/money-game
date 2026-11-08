extends Node
## Screenshot of prototype 2 in the middle of level 3 (make screenshots): a few tiles taken
## and placed by a simple robot, one waiting in the tray.

const SCENE: PackedScene = preload("res://game/proto_pyramid/pyramid.tscn")
const LEVEL: int = 2
const MOVES: int = 5


func _ready() -> void:
	var screen: PyramidScreen = SCENE.instantiate()
	add_child(screen)
	screen.start_level(LEVEL)
	for _move in MOVES:
		screen.take(screen.game.stack.free_tiles()[0])
		_place_first_fit(screen.game)
	screen.take(screen.game.stack.free_tiles()[0])
	screen.refresh()


static func _place_first_fit(game: PyramidGame) -> void:
	for y in game.grid.size:
		for x in game.grid.size:
			if game.place(0, Vector2i(x, y)) != null:
				return
