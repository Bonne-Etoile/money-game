class_name PieceShapeSet
extends Resource
## Every shape a piece can take (piece_shapes.tres), shared by both prototypes.

@export var shapes: Array[PieceShape] = []


## The shapes named by `keys`, each drawn as often as the others; every shape with a weight
## when `keys` is empty.
func pick(keys: Array[String]) -> Array[PieceShape]:
	if keys.is_empty():
		return shapes
	var picked: Array[PieceShape] = []
	for key in keys:
		var shape: PieceShape = find(key).duplicate()
		shape.weight = 1
		picked.append(shape)
	return picked


## The shape named `key`, or null.
func find(key: String) -> PieceShape:
	for shape in shapes:
		if shape.key == key:
			return shape
	return null
