extends Node
## Screenshot of prototype 1 when the player is in trouble (make screenshots): the grid is
## almost full, a single piece still fits, the free bonuses are spent, so the bonus buttons
## offer a rewarded ad and pulse.

const SCENE: PackedScene = preload("res://game/proto_tiles/tile_blocks.tscn")


func _ready() -> void:
	var screen: TileBlocksScreen = SCENE.instantiate()
	add_child(screen)
	screen.start(1)
	var size: int = screen.game.grid.size
	# Full but a few lone holes, and a gap of four at the bottom where only the bar fits.
	for y in size:
		for x in size:
			var hole: bool = (y == size - 1 and x < 4) or (x * 5 + y * 3) % 11 == 0
			if not hole:
				screen.game.grid.set_symbol(Vector2i(x, y), (x * 3 + y * 2) % 5)
	var shapes: PieceShapeSet = screen.rules.shape_set
	var hand: Array[Piece] = []
	for key: String in ["i4h", "o2", "t4b"]:
		var cells: Array[Vector2i] = shapes.find(key).cells
		var symbols: PackedInt32Array = []
		for index in cells.size():
			symbols.append(index % 4)
		hand.append(Piece.new(cells, symbols))
	screen.game.hand.assign(hand)
	for bonus in TileBlocksGame.BONUSES:
		screen.game.bonus_charges[bonus] = 0
	screen.game.scores.score = 640
	screen.refresh()
