class_name PieceShapeSet
extends Resource
## Every shape a piece can take (piece_shapes.tres), shared by both prototypes.

@export var shapes: Array[PieceShape] = []


## The shape named `key`, or null.
func find(key: String) -> PieceShape:
	for shape in shapes:
		if shape.key == key:
			return shape
	return null
