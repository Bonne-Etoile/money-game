extends Node
## Screenshots of the game's feedback, one situation at a time (make juice-gallery): the
## situation comes from the JUICE_SHOT environment variable (a screenshot-only fixture).
##   preview  a piece held where it would clear a row and a column (they glow)
##   place    a piece just set down (tiles landing, points rising)
##   combo    a big move late in a combo (two lines and a trio: the strongest words)
##   empty    the last tile that empties the grid
##   record   a clear that beats the record (fireworks)
##   fresh    a new game (pieces growing into the tray)

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")


func _ready() -> void:
	var shot: String = OS.get_environment("JUICE_SHOT")
	var screen: TileBlocksScreen = SCENE.instantiate()
	GameState.progress.stats.best_score = 10 if shot == "record" else 900
	add_child(screen)
	screen.start(4)
	var grid: TileGrid = screen.game.grid
	match shot:
		"preview", "combo":
			for x in 7:
				grid.set_symbol(Vector2i(x, 3), x % 2)
			for y in 8:
				if y != 3:
					grid.set_symbol(Vector2i(7, y), (y + 1) % 2)
			grid.set_symbol(Vector2i(5, 4), 2)
			grid.set_symbol(Vector2i(6, 4), 2)
			grid.set_symbol(Vector2i(1, 6), 4)
			grid.set_symbol(Vector2i(2, 6), 5)
			screen.game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([2]))
			if shot == "combo":
				screen.game.scores.combo = 5
		"place":
			for x in 3:
				grid.set_symbol(Vector2i(x, 7), x % 3)
			screen.game.hand[0] = Piece.new(
				[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)], PackedInt32Array([3, 4, 5])
			)
		"empty", "record":
			for x in 7:
				grid.set_symbol(Vector2i(x, 2), x % 2)
			screen.game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([3]))
	screen.refresh()
	if shot != "fresh":
		_play.call_deferred(screen, shot)


func _play(screen: TileBlocksScreen, shot: String) -> void:
	var tray: TrayView = screen.find_child("Tray") as TrayView
	var origin: Vector2i = Vector2i(7, 3)
	match shot:
		"place":
			origin = Vector2i(3, 5)
		"empty", "record":
			origin = Vector2i(7, 2)
	var pointer: Vector2 = screen.pointer_for(0, origin)
	tray.drag_started.emit(0, pointer)
	if shot != "preview":
		tray.drag_ended.emit(pointer)
