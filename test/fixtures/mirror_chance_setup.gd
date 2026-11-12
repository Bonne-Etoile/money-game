class_name MirrorChanceSetup
extends RefCounted
## A game where only the mirror opens a great move (MirrorChance tests and scenarios).

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")
## The S shape; flipped, it is the Z shape, which no turn of the S gives.
const S_CELLS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
## Where the Z shape fits in the two bottom rows, which it then fills.
const Z_HOLE: Array[Vector2i] = [Vector2i(0, 6), Vector2i(1, 6), Vector2i(1, 7), Vector2i(2, 7)]


## The two bottom rows full but a Z-shaped hole, rows 2 to 5 full but two cells apart (no
## piece completes them), and an S in the hand: only its mirror clears, two lines at once.
static func z_hole_game() -> TileBlocksGame:
	var game: TileBlocksGame = TileBlocksGame.new(RULES, 1)
	for y in range(2, 8):
		for x in 8:
			var cell: Vector2i = Vector2i(x, y)
			if y >= 6 and not cell in Z_HOLE or y < 6 and x != 3 and x != 7:
				game.grid.set_symbol(cell, (x + y) % 2)
	var s_shape: Piece = Piece.new(S_CELLS, PackedInt32Array([2, 3, 4, 2]))
	game.hand.assign([s_shape, null, null])
	return game
