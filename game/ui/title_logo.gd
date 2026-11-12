class_name TitleLogo
extends Control
## The game's name spelled with mahjong tiles, one letter engraved on each, one word per row,
## gently bobbing. Drawn by code from the GAME_TITLE text.

const DISPLAY_FONT: Font = preload("res://game/ui/display_font.tres")
## Gap between two tiles, and between two rows, as fractions of a tile.
const GAP: float = 0.07
const ROW_GAP: float = 0.16
## A tile is a little taller than wide, like a real one.
const TALL: float = 1.16
## The letter's size as a fraction of the tile's width.
const LETTER: float = 0.74
## How far the tiles bob, as a fraction of a tile, and how many times a second.
const BOB: float = 0.035
const BOB_HERTZ: float = 0.45

@export var art: TileArt
## Inks of the letters, by position in `TileArt.symbol_colors`, taken in turn.
@export var inks: Array[int] = [0, 2, 1, 4, 3]

var _time: float = 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if art == null:
		return
	var words: PackedStringArray = tr("GAME_TITLE").to_upper().split(" ", false)
	var longest: int = 1
	for word in words:
		longest = maxi(longest, word.length())
	# The biggest tiles that fit both ways.
	var by_width: float = size.x / (longest + (longest - 1) * GAP)
	var rows: float = words.size() * TALL + (words.size() - 1) * ROW_GAP
	var side: float = minf(by_width, size.y / maxf(rows + BOB * 2.0, 1.0))
	var top: float = (size.y - rows * side) / 2.0
	var letter_index: int = 0
	for row in words.size():
		var word: String = words[row]
		var width: float = (word.length() + (word.length() - 1) * GAP) * side
		for index in word.length():
			var bob: float = sin((_time * BOB_HERTZ + letter_index * 0.13) * TAU) * BOB * side
			var rect: Rect2 = Rect2(
				(size.x - width) / 2.0 + index * (1.0 + GAP) * side,
				top + row * (TALL + ROW_GAP) * side + bob,
				side,
				side * TALL
			)
			var shadow: Rect2 = rect
			shadow.position += Vector2(side * 0.03, side * 0.09 - bob * 0.5)
			TileDrawing.draw_box(self, shadow, Color(0, 0, 0, 0.3), side * TileDrawing.CORNER)
			var face: Rect2 = TileDrawing.draw_blank(self, rect, art)
			var ink: Color = art.symbol_colors[
				inks[letter_index % inks.size()] % art.symbol_colors.size()
			]
			_draw_letter(word[index], face, ink, side)
			letter_index += 1


## A letter engraved in the middle of `face`: light under it, its ink over.
func _draw_letter(letter: String, face: Rect2, ink: Color, side: float) -> void:
	var font_size: int = roundi(side * LETTER)
	var ascent: float = DISPLAY_FONT.get_ascent(font_size)
	var descent: float = DISPLAY_FONT.get_descent(font_size)
	var baseline: Vector2 = Vector2(
		face.position.x, face.get_center().y + (ascent - descent) / 2.0 - side * 0.02
	)
	var middle: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER
	draw_string(
		DISPLAY_FONT,
		baseline + Vector2(0.0, side * 0.03),
		letter,
		middle,
		face.size.x,
		font_size,
		Color(1, 1, 1, 0.9)
	)
	draw_string(
		DISPLAY_FONT,
		baseline - Vector2(0.0, side * 0.018),
		letter,
		middle,
		face.size.x,
		font_size,
		ink.darkened(0.35)
	)
	draw_string(DISPLAY_FONT, baseline, letter, middle, face.size.x, font_size, ink)
