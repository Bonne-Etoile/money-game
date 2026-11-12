class_name GlyphIcon
extends Control
## A small picture drawn by code (GameIcons), filling the control.

@export var glyph: StringName = &"":
	set(value):
		glyph = value
		queue_redraw()
@export var glyph_color: Color = Color.WHITE:
	set(value):
		glyph_color = value
		queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	if not glyph.is_empty():
		GameIcons.draw(self, glyph, size / 2.0, minf(size.x, size.y) * 0.45, glyph_color)
