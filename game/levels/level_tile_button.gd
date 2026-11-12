class_name LevelTileButton
extends Button
## A level's button on the level map, drawn as a mahjong tile: its number engraved when it can
## be played, with a gold star once won; a padlock on a darker tile while it is locked; a gold
## edge beating around the level to play next. The button's own text is not drawn (it stays
## for screen readers and tests).

const DISPLAY_FONT: Font = preload("res://game/ui/display_font.tres")
## The number's size as a fraction of the tile's height.
const NUMBER: float = 0.46
## Tint of a locked tile.
const LOCKED_TINT: Color = Color(0.5, 0.52, 0.62)
## How far a pressed tile sinks, as a fraction of its height.
const PRESS: float = 0.05
const PULSE_HERTZ: float = 1.2

var art: TileArt
## The level's number, as shown.
var number: int = 1
var won: bool = false:
	set(value):
		won = value
		queue_redraw()
## Whether this is the level to play next (it beats).
var current: bool = false:
	set(value):
		current = value
		set_process(value)
		queue_redraw()

var _time: float = 0.0


func _ready() -> void:
	var nothing: StyleBoxEmpty = StyleBoxEmpty.new()
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, nothing)
	for state: String in [
		"font_color",
		"font_hover_color",
		"font_pressed_color",
		"font_disabled_color",
		"font_focus_color",
		"font_outline_color"
	]:
		add_theme_color_override(state, Color.TRANSPARENT)
	set_process(current)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if art == null:
		return
	var rect: Rect2 = Rect2(Vector2.ZERO, size).grow(-4.0)
	if button_pressed or is_pressed():
		rect.position.y += size.y * PRESS
	var radius: float = rect.size.x * TileDrawing.CORNER
	TileDrawing.draw_box(
		self, Rect2(rect.position + Vector2(0.0, 6.0), rect.size), Color(0, 0, 0, 0.3), radius
	)
	var face: Rect2 = TileDrawing.draw_blank(
		self, rect, art, LOCKED_TINT if disabled else Color.WHITE
	)
	if disabled:
		GameIcons.draw(
			self, GameIcons.LOCK, face.get_center(), face.size.y * 0.24, Color(art.night, 0.55)
		)
		return
	var ink: Color = art.jade.darkened(0.15) if won else art.ink
	var font_size: int = roundi(face.size.y * NUMBER)
	var ascent: float = DISPLAY_FONT.get_ascent(font_size)
	var descent: float = DISPLAY_FONT.get_descent(font_size)
	var lift: float = face.size.y * (0.1 if won else 0.0)
	var baseline: Vector2 = Vector2(
		face.position.x, face.get_center().y + (ascent - descent) / 2.0 - lift
	)
	var middle: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER
	draw_string(
		DISPLAY_FONT,
		baseline + Vector2(0.0, 2.0),
		str(number),
		middle,
		face.size.x,
		font_size,
		Color(1, 1, 1, 0.9)
	)
	draw_string(DISPLAY_FONT, baseline, str(number), middle, face.size.x, font_size, ink)
	if won:
		var star: Vector2 = Vector2(face.get_center().x, face.end.y - face.size.y * 0.2)
		GameIcons.draw(self, GameIcons.STAR, star, face.size.y * 0.13, art.gold.darkened(0.25))
		GameIcons.draw(self, GameIcons.STAR, star, face.size.y * 0.1, art.gold)
	if current:
		var beat: float = 0.5 + 0.5 * sin(_time * TAU * PULSE_HERTZ)
		TileDrawing.draw_outline(
			self,
			rect.grow(2.0 + 3.0 * beat),
			Color(art.gold_glow, 0.55 + 0.45 * beat),
			5.0,
			radius + 4.0
		)
