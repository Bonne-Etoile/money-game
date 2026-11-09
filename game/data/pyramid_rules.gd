class_name PyramidRules
extends Resource
## Settings of prototype 2, "the pyramid gives the pieces" (pyramid_rules.tres).

@export var grid_size: int = 8
## Pieces taken from the pile that can wait before being placed.
@export var tray_size: int = 2
@export var symbol_count: int = 5
## Identical symbols touching each other that clear; 0: only full lines clear. A whole piece
## carries one symbol here, so groups would clear too easily: off until prototype 1 has
## shown whether the rule is liked (docs/backlog.md, G2).
@export var match_size: int = 0
## Letter of a level's layout -> key of a shape in `shape_set`.
@export var legend: Dictionary[String, String] = {}
@export var shape_set: PieceShapeSet
@export var scoring: ScoreRules
@export var levels: Array[PyramidLevel] = []
