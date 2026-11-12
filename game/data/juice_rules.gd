class_name JuiceRules
extends Resource
## Settings of the clear feedback (juice_rules.tres, G13): words of praise, cell fragments,
## board shake, sounds rising with the combo, vibration, fireworks for the record. Purely for
## show: nothing here changes the rules.

## Strength of a move (clears in it, plus the combo beyond the first move, plus
## `empty_grid_strength` when the grid ends empty) from which each word of praise shows:
## PRAISE_1 at the first threshold, PRAISE_2 at the second, and so on.
@export var praise_thresholds: Array[int] = [2, 3, 5, 7]
@export var empty_grid_strength: int = 4
## Seconds a word of praise stays on screen, rising and fading.
@export var praise_seconds: float = 0.9
@export var praise_rise_pixels: float = 90.0
## Fragments flying from each cleared cell, for how long, and how fast (pixels per second).
@export var fragments_per_cell: int = 4
@export var fragment_seconds: float = 0.6
@export var fragment_speed: float = 380.0
## Board shake: pixels per point of strength of the move (ClearPraise), up to
## `shake_max_pixels`, for how long.
@export var shake_pixels_per_clear: float = 4.0
@export var shake_max_pixels: float = 16.0
@export var shake_seconds: float = 0.25
## The clear sound climbs these steps (semitones, a major pentatonic scale: always in tune)
## at each move of the combo, and stays on the last one (ClearPraise.combo_pitch).
@export var combo_semitones: Array[int] = [0, 2, 4, 7, 9, 12, 14, 16]
## Vibration on a clear, in milliseconds, per point of strength of the move, up to
## `vibration_max_ms`.
@export var vibration_ms_per_clear: int = 25
@export var vibration_max_ms: int = 80
## Fireworks when the record is beaten: bursts, fragments in each, and seconds between bursts.
@export var firework_bursts: int = 5
@export var firework_fragments: int = 24
@export var firework_interval: float = 0.18
## Extra fragments per cleared cell for each point of strength of the move beyond the first.
@export var fragments_per_strength: int = 1
## A placed tile lands a little bigger and settles (pop), in this many seconds.
@export var pop_scale: float = 1.18
@export var pop_seconds: float = 0.2
## Light sweeping along each cleared row or column.
@export var beam_seconds: float = 0.4
## Ring spreading from the placed piece on a clear, and from the centre on an empty grid; its
## radius in cells.
@export var ring_seconds: float = 0.45
@export var ring_cells: float = 2.5
## Sparkles thrown around on a strong move: from this strength, so many per point of strength.
@export var sparkle_min_strength: int = 2
@export var sparkles_per_strength: int = 6
@export var sparkle_seconds: float = 0.8
## The points of a move rising from the placed piece.
@export var points_seconds: float = 0.8
@export var points_rise_pixels: float = 70.0
## Colour of each word of praise (PRAISE_1 first); the last ones cycle through the symbol
## colours. The words grow by `praise_size_step` per level.
@export var praise_colors: Array[Color] = []
@export var praise_size_step: int = 8
@export var rainbow_from_word: int = 4
## The score label grows this much when points come in.
@export var score_punch_scale: float = 1.25
## Seconds a new piece in the tray takes to grow in.
@export var tray_appear_seconds: float = 0.25
## Seconds the grid takes to grey out at the end of a game.
@export var game_over_fade_seconds: float = 0.6
