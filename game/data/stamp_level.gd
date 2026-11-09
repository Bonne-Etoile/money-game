class_name StampLevel
extends Resource
## A hand-made level of the "stamp" prototype (G7): how many tiles each column of the pile
## holds. Symbols are drawn with `symbol_seed`.

## One text per row of the pile, from the top; each character is a column's height (0 to 9).
@export var heights: Array[String] = []
@export var symbol_seed: int = 1
