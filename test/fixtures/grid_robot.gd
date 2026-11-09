class_name GridRobot
extends RefCounted
## How good a placement is, for the simple robots of the tests (levels that can be won) and
## of the screenshots: cells cleared first, then identical neighbours, then high and left.


## -1 when `piece` does not fit at `origin`.
static func value(grid: TileGrid, piece: Piece, origin: Vector2i, match_size: int) -> int:
	if not grid.can_place(piece, origin):
		return -1
	var copy: TileGrid = TileGrid.new(grid.size)
	for y in grid.size:
		for x in grid.size:
			copy.set_symbol(Vector2i(x, y), grid.symbol_at(Vector2i(x, y)))
	copy.place(piece, origin)
	var neighbours: int = 0
	for index in piece.cells.size():
		var cell: Vector2i = origin + piece.cells[index]
		for step in GridGroups.NEIGHBOURS:
			if grid.symbol_at(cell + step) == piece.symbols[index]:
				neighbours += 1
	var cleared: int = copy.find_clears(match_size).cells.size()
	var height: int = (grid.size - origin.y) * grid.size - origin.x
	return cleared * 10000 + neighbours * 200 + height
