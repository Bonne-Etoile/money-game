class_name StackTile
extends RefCounted
## A tile of the mahjong pile (TileStack): where it lies and the piece it gives when taken.

## Top-left corner, in half tiles (a tile covers 2 x 2 half tiles, so that a tile of an upper
## layer can straddle two tiles below, as in mahjong solitaire).
var position: Vector2i = Vector2i.ZERO
var layer: int = 0
var piece: Piece
var removed: bool = false


func _init(at: Vector2i, on_layer: int, gives: Piece) -> void:
	position = at
	layer = on_layer
	piece = gives


## Whether the two tiles overlap when seen from above.
func overlaps(other: StackTile) -> bool:
	var gap: Vector2i = (other.position - position).abs()
	return gap.x < 2 and gap.y < 2
