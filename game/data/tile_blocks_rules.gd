class_name TileBlocksRules
extends Resource
## Settings of prototype 1, "tile blocks" (tile_blocks_rules.tres): a full row or column, or
## `match_size` identical symbols touching each other, are cleared.

@export var grid_size: int = 8
## Number of different symbols on the tiles.
@export var symbol_count: int = 5
## Pieces offered at once.
@export var hand_size: int = 3
## Whether a new piece takes the place of each placed one at once (Stelio, 2026-11-09);
## otherwise three new pieces come when all are placed.
@export var refill_each_slot: bool = true
## Shapes offered (keys of `shape_set`), all equally often; empty: every shape, by weight.
## The 7 Tetris shapes by default (Stelio, 2026-11-09), which the player can turn.
@export var shape_keys: Array[String] = []
## Whether the player can turn a piece a quarter turn by tapping it.
@export var can_rotate: bool = true
## Identical symbols touching each other (sides only) that clear; 0 turns the rule off.
@export var match_size: int = 3
## Times a lost game can go on, after a rewarded ad (TileBlocksGame.revive).
@export var revives_per_game: int = 1
## Rows and columns cleared in the middle of the grid by a revive: a cross wide enough for
## every shape of `shape_set` (the longest is 5 cells, the widest 3 x 3).
@export var revive_clear_lines: int = 3
@export var shape_set: PieceShapeSet
@export var scoring: ScoreRules
