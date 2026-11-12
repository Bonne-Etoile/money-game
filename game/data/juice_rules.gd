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
## How far a word of praise rises while it fades out, in pixels.
@export var praise_rise_pixels: float = 30.0
## Shards of tile flying from each cleared cell (ivory, jade underneath): how many, for how
## long, how fast (pixels per second, between x and y), how big (pixels), how hard they fall
## (pixels per second squared).
@export var fragments_per_cell: int = 2
@export var fragment_seconds: float = 0.5
@export var fragment_speed: float = 380.0
@export var shard_speed: Vector2 = Vector2(250.0, 420.0)
@export var shard_size: Vector2 = Vector2(18.0, 26.0)
@export var shard_gravity: float = 1400.0
## Small sparkles in the symbol's ink from each cleared cell, and their size in pixels.
@export var sparkles_per_cell: int = 3
@export var sparkle_size: Vector2 = Vector2(26.0, 46.0)
## Never more particles than this on screen (low-end phones): the extra ones are not made.
@export var max_particles: int = 150
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
## Fireworks when the record is beaten: bursts, streaks in each (their length in pixels,
## between x and y), and seconds between bursts.
@export var firework_bursts: int = 4
@export var firework_fragments: int = 24
@export var firework_interval: float = 0.18
@export var firework_streak: Vector2 = Vector2(16.0, 28.0)
## A placed tile lands a little bigger and settles (pop), in this many seconds.
@export var pop_scale: float = 1.18
@export var pop_seconds: float = 0.2
## Light along each cleared row or column: it sweeps out from the placed piece during
## `beam_sweep` of its time, then fades; the width of its bright core in pixels.
@export var beam_seconds: float = 0.3
@export var beam_sweep: float = 0.4
@export var beam_core_pixels: float = 6.0
## Ring spreading from the placed piece on a clear: its radius in cells, its width in pixels.
@export var ring_seconds: float = 0.45
@export var ring_cells: float = 1.6
@export var ring_width: float = 10.0
## Empty grid: a wave of light crosses the slots diagonal by diagonal (`wave_step` seconds
## between two diagonals, each lit for `wave_flash` seconds), while light spreads out of the
## frame by `wave_spread` pixels.
@export var wave_step: float = 0.03
@export var wave_flash: float = 0.14
@export var wave_spread: float = 36.0
## Sparkles thrown from the piece on a strong move: from this strength, so many per point of
## strength, up to `sparkles_max`.
@export var sparkle_min_strength: int = 2
@export var sparkles_per_strength: int = 4
@export var sparkles_max: int = 24
@export var sparkle_seconds: float = 0.7
## The points of a move rising from the placed piece: how far above its top edge they show
## (in cells), for how long, how high.
@export var points_seconds: float = 0.8
@export var points_rise_pixels: float = 56.0
@export var points_above_cells: float = 0.35
## Words of praise: a gold word on a dark ribbon which pops in (`praise_pop` seconds), holds
## (`praise_hold`), then rises and fades (`praise_fade`). The ribbon's colour says how strong
## the move is (one per word, PRAISE_1 first); the letters never change colour. The words
## grow by `praise_size_step` per level; from `praise_shine_from_word`, light sweeps across.
@export var praise_pop: float = 0.25
@export var praise_hold: float = 0.5
@export var praise_fade: float = 0.2
@export var praise_ribbons: Array[Color] = []
@export var praise_size_step: int = 5
@export var praise_shine_from_word: int = 4
## Width of the ribbon, as a fraction of the grid's width.
@export var praise_width: float = 0.8
## The banner of a beaten record: seconds to slide in, to stay.
@export var banner_slide: float = 0.35
@export var banner_hold: float = 1.5
## The end card: seconds to grow in, for the score to count up, between two stars.
@export var card_seconds: float = 0.3
@export var card_scale_from: float = 0.85
@export var count_up_seconds: float = 0.6
@export var star_interval: float = 0.15
## Bonus buttons calling for attention: how much they grow, how many times a second.
@export var call_scale: float = 1.06
@export var call_hertz: float = 1.2
## The score label grows this much when points come in.
@export var score_punch_scale: float = 1.25
## The combo chip grows this much at each new step of the combo.
@export var combo_punch_scale: float = 1.3
## Seconds a new piece in the tray takes to grow in.
@export var tray_appear_seconds: float = 0.25
## Seconds the grid takes to grey out at the end of a game.
@export var game_over_fade_seconds: float = 0.6
