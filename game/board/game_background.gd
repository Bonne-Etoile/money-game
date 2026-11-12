class_name GameBackground
extends Control
## The screen's background: a vertical gradient with soft round lights slowly drifting up, so
## that the screen never looks still. Purely for show; its own random generator.

## Radius of the lights, in pixels, and how fast they rise (pixels per second).
const LIGHT_RADIUS: Vector2 = Vector2(30.0, 110.0)
const LIGHT_SPEED: Vector2 = Vector2(6.0, 18.0)
## Size of the soft round light's texture (it is stretched to each light), in pixels.
const LIGHT_TEXTURE_SIZE: int = 64

@export var art: TileArt:
	set(value):
		art = value
		_scatter()
		queue_redraw()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## A white disc fading out to its edge, tinted by TileArt.light_color.
var _light: GradientTexture2D = _make_light()
## Each light: position (fractions of the screen), radius, speed.
var _positions: PackedVector2Array = []
var _radii: PackedFloat32Array = []
var _speeds: PackedFloat32Array = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	if size.y <= 0.0:
		return
	for index in _positions.size():
		var position_now: Vector2 = _positions[index]
		position_now.y -= _speeds[index] * delta / size.y
		if position_now.y < -0.1:
			position_now = Vector2(_rng.randf(), 1.1)
		_positions[index] = position_now
	queue_redraw()


func _draw() -> void:
	if art == null:
		return
	var colors: PackedColorArray = [
		art.background_top, art.background_top, art.background_bottom, art.background_bottom
	]
	var corners: PackedVector2Array = [
		Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)
	]
	draw_polygon(corners, colors)
	for index in _positions.size():
		var center: Vector2 = _positions[index] * size
		var half: Vector2 = Vector2.ONE * _radii[index]
		draw_texture_rect(_light, Rect2(center - half, half * 2.0), false, art.light_color)


func _scatter() -> void:
	_rng.seed = 3
	_positions.clear()
	_radii.clear()
	_speeds.clear()
	if art == null:
		return
	for _light in art.light_count:
		_positions.append(Vector2(_rng.randf(), _rng.randf()))
		_radii.append(_rng.randf_range(LIGHT_RADIUS.x, LIGHT_RADIUS.y))
		_speeds.append(_rng.randf_range(LIGHT_SPEED.x, LIGHT_SPEED.y))
	set_process(not _positions.is_empty())


static func _make_light() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(0.5, Color(1, 1, 1, 0.45))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.5, 0.0)
	texture.width = LIGHT_TEXTURE_SIZE
	texture.height = LIGHT_TEXTURE_SIZE
	return texture
