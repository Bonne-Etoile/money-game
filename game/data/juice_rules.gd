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
## The clear sound rises this much in pitch for each move of the combo, up to `max_pitch`.
@export var combo_pitch_step: float = 0.08
@export var max_pitch: float = 1.8
## Vibration on a clear, in milliseconds, per point of strength of the move, up to
## `vibration_max_ms`.
@export var vibration_ms_per_clear: int = 25
@export var vibration_max_ms: int = 80
## Fireworks when the record is beaten: bursts, fragments in each, and seconds between bursts.
@export var firework_bursts: int = 5
@export var firework_fragments: int = 24
@export var firework_interval: float = 0.18
