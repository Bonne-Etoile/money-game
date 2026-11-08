class_name PieceShape
extends Resource
## The shape of a piece: the cells it covers, from its top-left corner (no rotation in play:
## each orientation is its own shape).

## Short name, used by hand-made levels to name a shape (PyramidLevel).
@export var key: String = ""
@export var cells: Array[Vector2i] = []
## How often the shape is drawn compared with the others (0: never drawn at random).
@export var weight: int = 1
