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
## Uses of each bonus (new pieces, mirror) given free at the start of a game: the player
## tries them, then may want them again for an ad (docs/strategies-pub.md).
@export var bonus_free_uses: int = 1
## Pieces drawn for each slot when the "new pieces" bonus is used: the one with the most room
## is given, so the bonus really helps.
@export var new_hand_candidates: int = 3
## Pieces of the hand that still fit, at most, for the player to be "in trouble": the bonus
## buttons call for attention (the moment an ad is worth the most to the player).
@export var trouble_fitting_pieces: int = 1
## The mirror's great move (MirrorChance): from this share of the grid filled (percent), when
## a piece of the hand, flipped, clears at least `mirror_chance_min_clears` lines and groups
## at once (more than unflipped), the mirror button lights up and the move shows on the grid.
## 0 clears turns it off.
@export var mirror_chance_fill_percent: int = 50
@export var mirror_chance_min_clears: int = 2
## Seconds without a move after which a placement that clears something shows as a hint on the
## grid (G15), when there is one; 0 turns hints off.
@export var hint_after_seconds: float = 10.0
## Days away after which the first continue of the day is free (the comeback gift, G14); 0
## turns it off.
@export var comeback_days: int = 2
@export var shape_set: PieceShapeSet
## Adaptive difficulty; none: every piece is drawn by pure chance.
@export var difficulty: DifficultyRules
@export var scoring: ScoreRules
## How often rewarded ads may be offered; none: the defaults of AdPacingRules.
@export var ad_pacing: AdPacingRules
