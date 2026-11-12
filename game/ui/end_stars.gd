class_name EndStars
extends Control
## The stars of a won level, on the end card: three places, the earned ones popping in gold
## one after the other, the others left as dark hollows.

const PLACES: int = 3
## Each star's radius as a fraction of the control's height; the middle one is bigger.
const RADIUS: float = 0.36
const MIDDLE_BONUS: float = 1.25
## How far apart the stars are, as a multiple of the control's height.
const SPACING: float = 1.05
## Seconds a star takes to pop in (it overshoots, then settles).
const POP_SECONDS: float = 0.3

@export var gold: Color = Color("e8b64c")
@export var gold_light: Color = Color("ffe7a0")
@export var hollow: Color = Color(0.227, 0.102, 0.039, 0.16)

## Stars earned (0 to 3), and seconds since they started to show.
var _earned: int = 0
var _interval: float = 0.15
var _time: float = 0.0


func _ready() -> void:
	set_process(false)


## Shows `earned` stars, popping in one after the other, `interval` seconds apart (0 or
## less: all there at once).
func show_stars(earned: int, interval: float) -> void:
	_earned = clampi(earned, 0, PLACES)
	_interval = maxf(interval, 0.0)
	_time = 0.0
	set_process(_interval > 0.0)
	queue_redraw()


func earned() -> int:
	return _earned


func _process(delta: float) -> void:
	_time += delta
	if _time > _interval * PLACES + POP_SECONDS:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	for place in PLACES:
		var middle: bool = place == PLACES / 2
		var radius: float = size.y * RADIUS * (MIDDLE_BONUS if middle else 1.0)
		var center: Vector2 = Vector2(
			size.x / 2.0 + (place - PLACES / 2) * size.y * SPACING,
			size.y * (0.5 if middle else 0.58)
		)
		GameIcons.draw(self, GameIcons.STAR, center, radius, hollow)
		if place >= _earned:
			continue
		var grown: float = 1.0
		if _interval > 0.0:
			var progress: float = clampf((_time - place * _interval) / POP_SECONDS, 0.0, 1.0)
			grown = Tween.interpolate_value(
				0.0, 1.0, progress, 1.0, Tween.TRANS_BACK, Tween.EASE_OUT
			)
		if grown <= 0.0:
			continue
		GameIcons.draw(self, GameIcons.STAR, center, radius * grown, gold.darkened(0.25))
		GameIcons.draw(
			self, GameIcons.STAR, center - Vector2(0, radius * 0.06), radius * grown * 0.9, gold
		)
		GameIcons.draw(
			self,
			GameIcons.STAR,
			center - Vector2(0, radius * 0.1),
			radius * grown * 0.5,
			gold_light
		)
