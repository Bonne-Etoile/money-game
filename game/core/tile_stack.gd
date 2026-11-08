class_name TileStack
extends RefCounted
## The mahjong pile of prototype 2: a tile can be taken when it is "free", as in mahjong
## solitaire: no tile lies on it, and its left or its right side is open.

var tiles: Array[StackTile] = []


func _init(stack_tiles: Array[StackTile] = []) -> void:
	tiles = stack_tiles


func remaining() -> int:
	return tiles.filter(func(tile: StackTile) -> bool: return not tile.removed).size()


func is_empty() -> bool:
	return remaining() == 0


func is_free(index: int) -> bool:
	if index < 0 or index >= tiles.size() or tiles[index].removed:
		return false
	var tile: StackTile = tiles[index]
	var left_open: bool = true
	var right_open: bool = true
	for other in tiles:
		if other == tile or other.removed:
			continue
		if other.layer > tile.layer and tile.overlaps(other):
			return false
		if other.layer == tile.layer and absi(other.position.y - tile.position.y) < 2:
			var dx: int = other.position.x - tile.position.x
			if dx == -2:
				left_open = false
			elif dx == 2:
				right_open = false
	return left_open or right_open


func free_tiles() -> Array[int]:
	var indexes: Array[int] = []
	for index in tiles.size():
		if is_free(index):
			indexes.append(index)
	return indexes


## Takes a free tile out of the pile and returns its piece; null when the tile is not free.
func take(index: int) -> Piece:
	if not is_free(index):
		return null
	tiles[index].removed = true
	return tiles[index].piece
