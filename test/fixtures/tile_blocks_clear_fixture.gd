extends Node
## Screenshot of a strong clear on prototype 1 (make screenshots, G13): a row and a trio at
## once, so the fragments fly, the board shakes and a word of praise rises.

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")


func _ready() -> void:
	var screen: TileBlocksScreen = SCENE.instantiate()
	add_child(screen)
	screen.start(2)
	for x in 6:
		screen.game.grid.set_symbol(Vector2i(x, 4), x % 2)
	screen.game.grid.set_symbol(Vector2i(6, 4), 3)
	screen.game.grid.set_symbol(Vector2i(7, 5), 3)
	for x in 5:
		screen.game.grid.set_symbol(Vector2i(x, 7), (x + 1) % 2)
	screen.game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([3]))
	screen.game.scores.combo = 2
	screen.refresh()
	_play.call_deferred(screen)


func _play(screen: TileBlocksScreen) -> void:
	var tray: TrayView = screen.find_child("Tray") as TrayView
	var pointer: Vector2 = screen.pointer_for(0, Vector2i(7, 4))
	tray.drag_started.emit(0, pointer)
	tray.drag_ended.emit(pointer)
