extends Node
## Screenshot of prototype 2 (or 3) in the middle of a level (make screenshots): a few tiles taken
## and placed by a simple robot, one waiting in the tray.

## The prototype to show: the pyramid, or its small-grid variant.
@export var scene: PackedScene = preload("res://game/proto_pyramid/pyramid.tscn")
@export var level: int = 2
@export var moves: int = 5


func _ready() -> void:
	var screen: PyramidScreen = scene.instantiate()
	add_child(screen)
	screen.start_level(level)
	for _move in moves:
		screen.take(screen.game.stack.free_tiles()[0])
		_place_first_fit(screen.game)
	screen.take(screen.game.stack.free_tiles()[0])
	screen.refresh()


static func _place_first_fit(game: PyramidGame) -> void:
	var best: int = -1
	var best_origin: Vector2i = Vector2i.ZERO
	for y in game.grid.size:
		for x in game.grid.size:
			var value: int = GridRobot.value(
				game.grid, game.tray[0], Vector2i(x, y), game.rules.match_size
			)
			if value > best:
				best = value
				best_origin = Vector2i(x, y)
	game.place(0, best_origin)
