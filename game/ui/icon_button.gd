class_name IconButton
extends Button
## A button with a small picture drawn by code (GameIcons): alone and centred when the button
## has no text, otherwise in the left margin of the button, before its text.

## Room kept on the left of a button with text for its picture, in pixels.
const SIDE_ROOM: float = 52.0

## The picture (a GameIcons name); empty: none.
@export var glyph: StringName = &"":
	set(value):
		glyph = value
		queue_redraw()
@export var glyph_color: Color = Color.WHITE:
	set(value):
		glyph_color = value
		queue_redraw()
## Whether pressing the button plays a rewarded ad: the "an ad plays" picture takes the place
## of the button's own (its text says so too).
@export var ad: bool = false:
	set(value):
		ad = value
		queue_redraw()
## Whether the picture sits above the text (a card), not on its left.
@export var glyph_above: bool = false
## Size of the picture, from its centre to its edge, as a fraction of the button's height.
@export var glyph_scale: float = 0.24


func _draw() -> void:
	var shown: StringName = GameIcons.AD if ad else glyph
	if shown.is_empty():
		return
	var radius: float = size.y * glyph_scale
	var center: Vector2 = size / 2.0
	if glyph_above:
		center.y = size.y * 0.34
	elif not text.is_empty():
		center.x = SIDE_ROOM * 0.5 + 10.0
	var color: Color = glyph_color
	if disabled:
		color.a *= 0.4
	GameIcons.draw(self, shown, center, radius, Color.WHITE if ad and not disabled else color)
