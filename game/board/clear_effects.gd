class_name ClearEffects
extends Control
## What makes a clear feel good (G13), drawn over the board: fragments of the cleared tiles
## spinning out, sparkles, light sweeping along the cleared lines, rings spreading out, the
## points of a move rising from the piece, words of praise popping in, and fireworks when the
## record is beaten. Purely for show: no rule here. Its own random generator (never the global
## one).

## Kinds of particle.
enum Kind { FRAGMENT, SPARKLE }

const FRAGMENT_SIZE: float = 18.0
## Downward pull on the fragments, in pixels per second squared (sparkles fall slower).
const GRAVITY: float = 900.0
const SPARKLE_GRAVITY: float = 220.0
const SPARKLE_SIZE: float = 22.0
const PRAISE_FONT_SIZE: int = 56
const PRAISE_OUTLINE: int = 12
const POINTS_FONT_SIZE: int = 40
const POINTS_OUTLINE: int = 8
## Thickness of a ring's line, in pixels.
const RING_WIDTH: float = 10.0
## Meta set on the labels showing points (not words of praise).
const POINTS_META: StringName = &"points"

var rules: JuiceRules
## Colours the strongest words of praise cycle through (the symbols' colours).
var rainbow: Array[Color] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Each particle: kind, position, velocity, angle, spin, colour, size, seconds left, in all.
var _kinds: PackedInt32Array = []
var _positions: PackedVector2Array = []
var _velocities: PackedVector2Array = []
var _angles: PackedFloat32Array = []
var _spins: PackedFloat32Array = []
var _colors: PackedColorArray = []
var _sizes: PackedFloat32Array = []
var _left: PackedFloat32Array = []
var _lifetimes: PackedFloat32Array = []
## Light along cleared lines: rectangle (local), colour, seconds left.
var _beams: Array[Rect2] = []
var _beam_colors: PackedColorArray = []
var _beam_left: PackedFloat32Array = []
## Rings: centre (local), final radius, colour, seconds left, in all.
var _ring_centers: PackedVector2Array = []
var _ring_radii: PackedFloat32Array = []
var _ring_colors: PackedColorArray = []
var _ring_left: PackedFloat32Array = []
var _ring_lifetimes: PackedFloat32Array = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_rng.seed = 1
	set_process(false)


## Fragments spinning out of each point of `centers` (global coordinates), in its colour.
func burst(centers: Array[Vector2], colors: Array[Color], per_point: int, speed: float) -> void:
	for index in centers.size():
		var from: Vector2 = _local(centers[index])
		for _fragment in per_point:
			var direction: Vector2 = Vector2.RIGHT.rotated(_rng.randf() * TAU)
			var velocity: Vector2 = direction * speed * _rng.randf_range(0.4, 1.0)
			# A little upwards first: the pieces jump before they fall.
			velocity.y -= speed * 0.35
			var size_now: float = FRAGMENT_SIZE * _rng.randf_range(0.5, 1.2)
			_add(Kind.FRAGMENT, from, velocity, colors[index], size_now, rules.fragment_seconds)
	set_process(true)


## Sparkles (small four-pointed stars, twinkling) thrown out of `at` (global coordinates).
func sparkles(at: Vector2, count: int, speed: float, palette: Array[Color]) -> void:
	var from: Vector2 = _local(at)
	for index in count:
		var direction: Vector2 = Vector2.RIGHT.rotated(_rng.randf() * TAU)
		var color: Color = Color.WHITE
		if not palette.is_empty() and index % 2 == 1:
			color = palette[_rng.randi() % palette.size()].lightened(0.35)
		var size_now: float = SPARKLE_SIZE * _rng.randf_range(0.6, 1.4)
		_add(
			Kind.SPARKLE,
			from,
			direction * speed * _rng.randf_range(0.3, 1.0),
			color,
			size_now,
			rules.sparkle_seconds
		)
	set_process(true)


## Light sweeping along a cleared row or column, `rect` in global coordinates.
func beam(rect: Rect2, color: Color) -> void:
	_beams.append(Rect2(_local(rect.position), rect.size))
	_beam_colors.append(color)
	_beam_left.append(rules.beam_seconds)
	set_process(true)


## A ring spreading out of `at` (global coordinates) up to `radius` pixels, fading.
func ring(at: Vector2, radius: float, color: Color, seconds: float) -> void:
	_ring_centers.append(_local(at))
	_ring_radii.append(radius)
	_ring_colors.append(color)
	_ring_left.append(seconds)
	_ring_lifetimes.append(seconds)
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
		var timer: SceneTreeTimer = get_tree().create_timer(burst_index * rules.firework_interval)
		timer.timeout.connect(burst.bind(centers, colors, 1, rules.fragment_speed * 1.2))
		var one_color: Array[Color] = [color]
		var center: Vector2 = get_global_transform() * at
		timer.timeout.connect(
			sparkles.bind(center, rules.sparkles_per_strength, rules.fragment_speed, one_color)
		)


## A word of praise popping in at `at` (global coordinates), rising and fading out; `word`
## is its level (1: PRAISE_1): higher words are bigger, and the strongest cycle through colours.
func praise(text: String, at: Vector2, word: int = 1) -> void:
	var color: Color = _praise_color(word)
	var font_size: int = PRAISE_FONT_SIZE + maxi(word - 1, 0) * rules.praise_size_step
	var label: Label = _label(text, font_size, PRAISE_OUTLINE, color, Color(0.1, 0.05, 0.2, 0.85))
	label.size = Vector2(size.x, font_size * 1.5)
	label.position = Vector2(0.0, _local(at).y - label.size.y / 2.0)
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2.ONE * 0.3
	label.rotation = deg_to_rad(_rng.randf_range(-6.0, 6.0))
	var seconds: float = rules.praise_seconds
	var tween: Tween = label.create_tween().set_parallel()
	(
		tween
		. tween_property(label, "scale", Vector2.ONE, seconds * 0.35)
		. set_trans(Tween.TRANS_ELASTIC)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_property(label, "rotation", 0.0, seconds * 0.35)
	tween.tween_property(label, "position:y", label.position.y - rules.praise_rise_pixels, seconds)
	tween.tween_property(label, "modulate:a", 0.0, seconds * 0.35).set_delay(seconds * 0.65)
	if word >= rules.rainbow_from_word and not rainbow.is_empty():
		for index in rainbow.size():
			(
				tween
				. tween_property(
					label,
					"theme_override_colors/font_color",
					rainbow[index],
					seconds / rainbow.size()
				)
				. set_delay(seconds * index / rainbow.size())
			)
	tween.chain().tween_callback(label.queue_free)


## The points of a move rising from `at` (global coordinates) and fading out.
func points(text: String, at: Vector2, color: Color) -> void:
	var label: Label = _label(text, POINTS_FONT_SIZE, POINTS_OUTLINE, color, Color(0, 0, 0, 0.6))
	label.set_meta(POINTS_META, true)
	label.size = Vector2(POINTS_FONT_SIZE * 6.0, POINTS_FONT_SIZE * 1.4)
	label.position = _local(at) - label.size / 2.0
	# Kept on screen when the piece is near an edge.
	label.position.x = clampf(label.position.x, 0.0, maxf(size.x - label.size.x, 0.0))
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2.ONE * 0.5
	var seconds: float = rules.points_seconds
	var tween: Tween = label.create_tween().set_parallel()
	(
		tween
		. tween_property(label, "scale", Vector2.ONE, seconds * 0.25)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	(
		tween
		. tween_property(label, "position:y", label.position.y - rules.points_rise_pixels, seconds)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)
	tween.tween_property(label, "modulate:a", 0.0, seconds * 0.4).set_delay(seconds * 0.6)
	tween.chain().tween_callback(label.queue_free)


## Fragments and sparkles still flying (tests).
func fragment_count() -> int:
	return _positions.size()


## Words of praise on screen (tests).
func praise_texts() -> Array[String]:
	return _texts(false)


## Points rising on screen (tests).
func points_texts() -> Array[String]:
	return _texts(true)


## Beams and rings on screen (tests).
func light_count() -> int:
	return _beams.size() + _ring_centers.size()


func _process(delta: float) -> void:
	var index: int = _positions.size() - 1
	while index >= 0:
		_left[index] -= delta
		if _left[index] <= 0.0:
			_remove(index)
		else:
			var pull: float = GRAVITY if _kinds[index] == Kind.FRAGMENT else SPARKLE_GRAVITY
			_velocities[index] += Vector2.DOWN * pull * delta
			if _kinds[index] == Kind.SPARKLE:
				_velocities[index] *= 1.0 - minf(3.0 * delta, 1.0)
			_positions[index] += _velocities[index] * delta
			_angles[index] += _spins[index] * delta
		index -= 1
	index = _beams.size() - 1
	while index >= 0:
		_beam_left[index] -= delta
		if _beam_left[index] <= 0.0:
			_beams.remove_at(index)
			_beam_colors.remove_at(index)
			_beam_left.remove_at(index)
		index -= 1
	index = _ring_centers.size() - 1
	while index >= 0:
		_ring_left[index] -= delta
		if _ring_left[index] <= 0.0:
			_ring_centers.remove_at(index)
			_ring_radii.remove_at(index)
			_ring_colors.remove_at(index)
			_ring_left.remove_at(index)
			_ring_lifetimes.remove_at(index)
		index -= 1
	set_process(not _positions.is_empty() or not _beams.is_empty() or not _ring_centers.is_empty())
	queue_redraw()


func _draw() -> void:
	_draw_beams()
	_draw_rings()
	for index in _positions.size():
		var fade: float = clampf(_left[index] / _lifetimes[index], 0.0, 1.0)
		var color: Color = _colors[index]
		if _kinds[index] == Kind.SPARKLE:
			# Twinkles: its size beats while it fades.
			var twinkle: float = 0.6 + 0.4 * absf(sin(_angles[index] * 2.0))
			color.a *= fade
			draw_set_transform(Vector2.ZERO)
			_draw_star(_positions[index], _sizes[index] * twinkle * (0.4 + 0.6 * fade), color)
			continue
		var side: float = _sizes[index] * (0.4 + fade * 0.6)
		color.a *= fade
		draw_set_transform(_positions[index], _angles[index])
		draw_rect(Rect2(-Vector2.ONE * side / 2.0, Vector2.ONE * side), color)
		# A lighter corner: each fragment looks like a chip of a glossy tile.
		draw_rect(
			Rect2(-Vector2.ONE * side / 2.0, Vector2.ONE * side * 0.45), Color(1, 1, 1, 0.45 * fade)
		)
	draw_set_transform(Vector2.ZERO)


## A beam: lit up at once, it swells across the line and fades.
func _draw_beams() -> void:
	for index in _beams.size():
		var progress: float = 1.0 - _beam_left[index] / rules.beam_seconds
		var rect: Rect2 = _beams[index]
		var across: bool = rect.size.x >= rect.size.y
		var thickness: float = (rect.size.y if across else rect.size.x) * (1.0 + progress * 0.6)
		var center: Vector2 = rect.get_center()
		var shape: Vector2 = (
			Vector2(rect.size.x * (1.0 + progress * 0.15), thickness)
			if across
			else Vector2(thickness, rect.size.y * (1.0 + progress * 0.15))
		)
		var color: Color = _beam_colors[index]
		color.a *= (1.0 - progress) * 0.8
		draw_rect(Rect2(center - shape / 2.0, shape), color)
		var core: Vector2 = shape * (Vector2(1.0, 0.35) if across else Vector2(0.35, 1.0))
		draw_rect(Rect2(center - core / 2.0, core), Color(1, 1, 1, (1.0 - progress) * 0.9))


func _draw_rings() -> void:
	for index in _ring_centers.size():
		var progress: float = 1.0 - _ring_left[index] / _ring_lifetimes[index]
		var eased: float = 1.0 - pow(1.0 - progress, 3.0)
		var color: Color = _ring_colors[index]
		color.a *= 1.0 - progress
		draw_arc(
			_ring_centers[index],
			_ring_radii[index] * eased,
			0.0,
			TAU,
			48,
			color,
			RING_WIDTH * (1.0 - progress * 0.7),
			true
		)


func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var points_list: PackedVector2Array = []
	for index in 8:
		var length: float = radius if index % 2 == 0 else radius * 0.28
		points_list.append(center + Vector2.from_angle(TAU * index / 8.0) * length)
	draw_colored_polygon(points_list, color)


func _praise_color(word: int) -> Color:
	if rules.praise_colors.is_empty():
		return Color.GOLD
	return rules.praise_colors[clampi(word - 1, 0, rules.praise_colors.size() - 1)]


func _label(text: String, font_size: int, outline: int, color: Color, edge: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", outline)
	label.add_theme_color_override("font_outline_color", edge)
	label.add_theme_constant_override("shadow_offset_y", 4)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _texts(of_points: bool) -> Array[String]:
	var texts: Array[String] = []
	for child in get_children():
		if child is Label and child.has_meta(POINTS_META) == of_points:
			texts.append((child as Label).text)
	return texts


func _add(
	kind: Kind, at: Vector2, velocity: Vector2, color: Color, size_now: float, seconds: float
) -> void:
	var lifetime: float = seconds * _rng.randf_range(0.7, 1.2)
	_kinds.append(kind)
	_positions.append(at)
	_velocities.append(velocity)
	_angles.append(_rng.randf() * TAU)
	_spins.append(_rng.randf_range(-12.0, 12.0))
	_colors.append(color)
	_sizes.append(size_now)
	_left.append(lifetime)
	_lifetimes.append(lifetime)


func _remove(index: int) -> void:
	_kinds.remove_at(index)
	_positions.remove_at(index)
	_velocities.remove_at(index)
	_angles.remove_at(index)
	_spins.remove_at(index)
	_colors.remove_at(index)
	_sizes.remove_at(index)
	_left.remove_at(index)
	_lifetimes.remove_at(index)


func _local(global_point: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * global_point
