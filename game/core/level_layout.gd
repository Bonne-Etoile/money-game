class_name LevelLayout
extends RefCounted
## Reads the pile of a hand-made level (PyramidLevel.layers): one text per layer, bottom
## first; each character is a half tile, a letter marks the top-left corner of a tile and
## names its shape (PyramidRules.legend), anything else is empty. The grid may start with
## tiles on it (PyramidLevel.grid_rows, "#").

const GRID_TILE: String = "#"


static func tiles_of(level: PyramidLevel, rules: PyramidRules) -> Array[StackTile]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = level.symbol_seed
	var tiles: Array[StackTile] = []
	for layer in level.layers.size():
		var rows: PackedStringArray = level.layers[layer].split("\n", false)
		for y in rows.size():
			for x in rows[y].length():
				var letter: String = rows[y][x]
				var shape_key: String = rules.legend.get(letter, "")
				var shape: PieceShape = rules.shape_set.find(shape_key)
				if shape == null:
					continue
				var symbol: int = rng.randi_range(0, rules.symbol_count - 1)
				tiles.append(
					StackTile.new(Vector2i(x, y), layer, Piece.uniform(shape.cells, symbol))
				)
	return tiles


## Puts the level's starting tiles on the grid (symbols drawn after those of the pile).
static func fill_grid(level: PyramidLevel, rules: PyramidRules, grid: TileGrid) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = level.symbol_seed + 1
	for y in level.grid_rows.size():
		var row: String = level.grid_rows[y]
		for x in row.length():
			if row[x] == GRID_TILE:
				grid.set_symbol(Vector2i(x, y), rng.randi_range(0, rules.symbol_count - 1))
