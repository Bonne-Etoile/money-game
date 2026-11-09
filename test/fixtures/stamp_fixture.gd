extends Node
## Screenshot of prototype 5, "stamp", in the middle of level 2 (make screenshots): a few
## shapes stamped and placed by a simple robot, then the next shape dragged over the pile.

const SCENE: PackedScene = preload("res://game/proto_stamp/stamp.tscn")
const LEVEL: int = 1
const MOVES: int = 4
const SEED: int = 2
const DRAG_OFFSET: Vector2 = Vector2(20, -20)


func _ready() -> void:
	var screen: StampScreen = SCENE.instantiate()
	add_child(screen)
	screen.shape_seed = SEED
	screen.start_level(LEVEL)
	for _move in MOVES:
		_play(screen.game)
	screen.refresh()
	_show_drag.call_deferred(screen)


static func _play(game: StampGame) -> void:
	var shape: Piece = game.current_shape()
	for y in game.pile.size:
		for x in game.pile.size:
			if game.stamp(Vector2i(x, y)) != null:
				var best: int = -1
				var best_origin: Vector2i = Vector2i.ZERO
				for gy in game.grid.size:
					for gx in game.grid.size:
						var value: int = GridRobot.value(
							game.grid, game.hand[0], Vector2i(gx, gy), game.rules.match_size
						)
						if value > best:
							best = value
							best_origin = Vector2i(gx, gy)
				game.place(0, best_origin)
				return
	push_error("stamp fixture: %s fits nowhere" % shape.cells)


func _show_drag(screen: StampScreen) -> void:
	var tray: TrayView = screen.find_child("ShapeTray") as TrayView
	tray.drag_started.emit(0, screen.pointer_for_stamp(Vector2i(2, 2)) + DRAG_OFFSET)
