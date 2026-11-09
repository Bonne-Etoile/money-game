class_name ClearEffects
extends Control
## What makes a clear feel good (G13), drawn over the board: fragments flying out of the cleared
## cells, words of praise rising and fading, and fireworks when the record is beaten. Purely
## for show: no rule here. Its own random generator (never the global one).

const FRAGMENT_SIZE: float = 18.0
## Downward pull on the fragments, in pixels per second squared.
const GRAVITY: float = 900.0
const PRAISE_FONT_SIZE: int = 56
const PRAISE_OUTLINE: int = 10

var rules: JuiceRules
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Each fragment: position, velocity, colour, seconds left, seconds in all.
var _positions: PackedVector2Array = []
var _velocities: PackedVector2Array = []
var _colors: PackedColorArray = []
var _left: PackedFloat32Array = []
var _lifetimes: PackedFloat32Array = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_rng.seed = 1
	set_process(false)


## Fragments flying out of each point of `centers` (global coordinates), in its colour.
func burst(centers: Array[Vector2], colors: Array[Color], per_point: int, speed: float) -> void:
	for index in centers.size():
		var from: Vector2 = _local(centers[index])
		for _fragment in per_point:
			var direction: Vector2 = Vector2.RIGHT.rotated(_rng.randf() * TAU)
			_add(from, direction * speed * _rng.randf_range(0.4, 1.0), colors[index])
	set_process(true)


## Fireworks over the top of the screen: bursts in the symbols' colours, one after the other.
func fireworks(palette: Array[Color]) -> void:
	for burst_index in rules.firework_bursts:
		var at: Vector2 = Vector2(
			_rng.randf_range(0.15, 0.85) * size.x, _rng.randf_range(0.15, 0.4) * size.y
		)
		var color: Color = (
			palette[burst_index % palette.size()] if not palette.is_empty() else Color.GOLD
		)
		var centers: Array[Vector2] = []
		var colors: Array[Color] = []
		for _fragment in rules.firework_fragments:
			centers.append(get_global_transform() * at)
			colors.append(color)
		get_tree().create_timer(burst_index * rules.firework_interval).timeout.connect(
			burst.bind(centers, colors, 1, rules.fragment_speed * 1.2)
		)


## A word of praise rising from `at` (global coordinates) and fading out.
func praise(text: String, at: Vector2, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", PRAISE_FONT_SIZE)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", PRAISE_OUTLINE)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(label)
	label.size = Vector2(size.x, PRAISE_FONT_SIZE * 1.5)
	label.position = Vector2(0.0, _local(at).y - label.size.y / 2.0)
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2.ONE * 0.6
	var tween: Tween = label.create_tween().set_parallel()
	tween.tween_property(label, "scale", Vector2.ONE, rules.praise_seconds * 0.25)
	tween.tween_property(
		label, "position:y", label.position.y - rules.praise_rise_pixels, rules.praise_seconds
	)
	tween.tween_property(label, "modulate:a", 0.0, rules.praise_seconds * 0.4).set_delay(
		rules.praise_seconds * 0.6
	)
	tween.chain().tween_callback(label.queue_free)


## Fragments still flying (tests).
func fragment_count() -> int:
	return _positions.size()


## Words of praise on screen (tests).
func praise_texts() -> Array[String]:
	var texts: Array[String] = []
	for child in get_children():
		if child is Label:
			texts.append((child as Label).text)
	return texts


func _process(delta: float) -> void:
	var index: int = _positions.size() - 1
	while index >= 0:
		_left[index] -= delta
		if _left[index] <= 0.0:
			_remove(index)
		else:
			_velocities[index] += Vector2.DOWN * GRAVITY * delta
			_positions[index] += _velocities[index] * delta
		index -= 1
	set_process(not _positions.is_empty())
	queue_redraw()


func _draw() -> void:
	for index in _positions.size():
		var fade: float = clampf(_left[index] / _lifetimes[index], 0.0, 1.0)
		var side: float = FRAGMENT_SIZE * (0.5 + fade * 0.5)
		var color: Color = _colors[index]
		color.a *= fade
		draw_rect(Rect2(_positions[index] - Vector2.ONE * side / 2.0, Vector2.ONE * side), color)


func _add(at: Vector2, velocity: Vector2, color: Color) -> void:
	var lifetime: float = rules.fragment_seconds * _rng.randf_range(0.7, 1.2)
	_positions.append(at)
	_velocities.append(velocity)
	_colors.append(color)
	_left.append(lifetime)
	_lifetimes.append(lifetime)


func _remove(index: int) -> void:
	_positions.remove_at(index)
	_velocities.remove_at(index)
	_colors.remove_at(index)
	_left.remove_at(index)
	_lifetimes.remove_at(index)


func _local(global_point: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * global_point
