extends Node
## Screenshot of prototype 1 in the middle of a game (make screenshots): a few moves played by
## a simple robot, then a piece being dragged over the grid.

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")
const SEED: int = 3
const MOVES: int = 9
const DRAG_OFFSET: Vector2 = Vector2(30, -25)


func _ready() -> void:
	var screen: TileBlocksScreen = SCENE.instantiate()
	add_child(screen)
	screen.start(SEED)
	for _move in MOVES:
		_play_first_fit(screen.game)
	screen.refresh()
	_show_drag.call_deferred(screen)


static func _play_first_fit(game: TileBlocksGame) -> void:
	for slot in game.hand.size():
		if game.hand[slot] == null:
			continue
		for y in game.grid.size:
			for x in game.grid.size:
				if game.place(slot, Vector2i(x, y)) != null:
					return


func _show_drag(screen: TileBlocksScreen) -> void:
	var tray: TrayView = screen.find_child("Tray") as TrayView
	for slot in screen.game.hand.size():
		if screen.game.hand[slot] != null:
			# Between two cells, so that the ghost on the grid shows next to the piece.
			tray.drag_started.emit(slot, screen.pointer_for(slot, Vector2i(4, 5)) + DRAG_OFFSET)
			return
