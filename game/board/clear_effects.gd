class_name ClearEffects
extends Control
## What makes a clear feel good (G13), drawn over the board: shards of the cleared tiles
## (ivory, jade underneath) flying out, sparkles in the symbols' inks, a beam of gold light
## sweeping along each cleared line from the placed piece, a ring, a wave of light over an
## emptied grid, the points of the move, a word of praise on its ribbon, and for a beaten
## record a banner and fireworks. Light is drawn additively on its own layer. Purely for show:
## no rule here. Its own random generator (never the global one).

## Kinds of particle: a shard of tile, a sparkle (a star of light), a firework's streak.
enum Kind { SHARD, SPARKLE, STREAK }

const DISPLAY_FONT: Font = preload("res://game/ui/display_font.tres")
const SPARKLE_GRAVITY: float = 220.0
const STREAK_GRAVITY: float = 520.0
const STREAK_WIDTH: float = 4.0
const PRAISE_FONT_SIZE: int = 60
const PRAISE_OUTLINE: int = 14
const POINTS_FONT_SIZE: int = 40
const POINTS_OUTLINE: int = 8
const BANNER_FONT_SIZE: int = 40
const BANNER_HEIGHT: float = 84.0
## Height of a word's ribbon as a multiple of its font size, and its corner radius.
const RIBBON_HEIGHT: float = 1.5
const RIBBON_RADIUS: int = 24
## The ribbon's gold edge, in pixels, and the width of the light sweeping across it.
const RIBBON_EDGE: int = 3
const SHINE_WIDTH: float = 90.0
## Side of the textures of light made at start, in pixels.
const TEXTURE_SIZE: int = 32
## Metas of what a child shows (tests read them).
const PRAISE_META: StringName = &"praise"
const POINTS_META: StringName = &"points"
const BANNER_META: StringName = &"banner"

var rules: JuiceRules
var art: TileArt
## Rings stay inside this rectangle (global coordinates; no size: the whole screen), so that
## a ring from a piece near the edge is not cut by the screen but by the grid's frame.
var ring_bounds: Rect2 = Rect2():
	set(value):
		ring_bounds = value
		_fit_rings()
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
## Light along cleared lines: rectangle (local), where the sweep starts (local), seconds left.
var _beams: Array[Rect2] = []
var _beam_origins: PackedVector2Array = []
var _beam_left: PackedFloat32Array = []
## Rings: centre (local), final radius, seconds left, in all.
var _ring_centers: PackedVector2Array = []
var _ring_radii: PackedFloat32Array = []
var _ring_left: PackedFloat32Array = []
var _ring_lifetimes: PackedFloat32Array = []
## The wave of light over an emptied grid: its rectangle (local), cells per side, seconds
## since it started (negative: none).
var _wave_rect: Rect2 = Rect2()
var _wave_cells: int = 0
var _wave_time: float = -1.0
## Bursts of fireworks to come: position (local) and seconds to wait in z.
var _pending: Array[Vector3] = []
var _pending_colors: PackedColorArray = []
## The points shown now (never two numbers at once).
var _points_label: Label = null
## Light is added to what is under it: beams, sparkles, streaks. Made in _ready (a node made
## here would be left orphaned when the scene never enters the tree).
var _glow: Control
## The rings' own layer of light, clipped to `ring_bounds`.
var _rings: Control
var _edge: StyleBoxFlat = StyleBoxFlat.new()
var _slot: StyleBoxFlat = StyleBoxFlat.new()
## A star of light with four points, and a bar of light fading out to both sides.
var _star: ImageTexture = _make_star()
var _bar: GradientTexture2D = _make_bar()


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_rng.seed = 1
	set_process(false)
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow = Control.new()
	_rings = Control.new()
	_glow.material = additive
	_glow.mouse_filter = MOUSE_FILTER_IGNORE
	_glow.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	_rings.material = additive
	_rings.mouse_filter = MOUSE_FILTER_IGNORE
	_rings.clip_contents = true
	_rings.draw.connect(_draw_rings)
	add_child(_rings)
	resized.connect(_fit_rings)
	_fit_rings()
	_edge.draw_center = false
	_slot.set_corner_radius_all(12)


## Takes everything away at once (the end panel opens, a new game starts).
func clear() -> void:
	_kinds.clear()
	_positions.clear()
	_velocities.clear()
	_angles.clear()
	_spins.clear()
	_colors.clear()
	_sizes.clear()
	_left.clear()
	_lifetimes.clear()
	_beams.clear()
	_beam_origins.clear()
	_beam_left.clear()
	_ring_centers.clear()
	_ring_radii.clear()
	_ring_left.clear()
	_ring_lifetimes.clear()
	_pending.clear()
	_pending_colors.clear()
	_wave_time = -1.0
	_points_label = null
	for child in get_children():
		if child != _glow and child != _rings:
			remove_child(child)
			child.queue_free()
	set_process(false)
	queue_redraw()
	_glow.queue_redraw()
	_rings.queue_redraw()


## The tiles cleared at `centers` (global coordinates) break up: shards of tile fly out of
## each, mostly upwards, and sparkles in its ink (`inks`, one per centre). `stones` tells
## which centres were stones (grey shards).
func shatter(centers: Array[Vector2], inks: Array[Color], stones: Array[bool]) -> void:
	if rules == null or art == null:
		return
	for index in centers.size():
		var from: Vector2 = _local(centers[index])
		for _shard in rules.fragments_per_cell:
			# Mostly upwards: within a third of a turn around straight up.
			var direction: Vector2 = Vector2.UP.rotated(_rng.randf_range(-1.0, 1.0) * PI * 0.4)
			var speed: float = _rng.randf_range(rules.shard_speed.x, rules.shard_speed.y)
			var side: float = _rng.randf_range(rules.shard_size.x, rules.shard_size.y)
			var face: Color = art.stone_face if stones[index] else art.tile_face
			_add(Kind.SHARD, from, direction * speed, face, side, rules.fragment_seconds)
		_sparkle(from, rules.sparkles_per_cell, rules.fragment_speed * 0.6, inks[index])
	set_process(true)


## Sparkles thrown out of `at` (global coordinates), in the colours of `palette` and white.
func sparkles(at: Vector2, count: int, speed: float, palette: Array[Color]) -> void:
	var from: Vector2 = _local(at)
	for index in count:
		var color: Color = Color.WHITE
		if not palette.is_empty() and index % 2 == 1:
			color = palette[_rng.randi() % palette.size()]
		_sparkle(from, 1, speed, color)
	set_process(true)


## Light along a cleared row or column, `rect` in global coordinates: it sweeps out from the
## point of the line nearest to `from` (the placed piece), then fades.
func beam(rect: Rect2, from: Vector2) -> void:
	_beams.append(Rect2(_local(rect.position), rect.size))
	_beam_origins.append(_local(from))
	_beam_left.append(rules.beam_seconds)
	set_process(true)


## A ring of gold light spreading out of `at` (global coordinates) up to `radius` pixels.
func ring(at: Vector2, radius: float, seconds: float) -> void:
	_ring_centers.append(_local(at))
	_ring_radii.append(radius)
	_ring_left.append(seconds)
	_ring_lifetimes.append(seconds)
	set_process(true)


## The grid is empty: a wave of light crosses the slots of `rect` (global, `cells` per side)
## diagonal by diagonal, and light spreads out of its frame.
func wave(rect: Rect2, cells: int) -> void:
	_wave_rect = Rect2(_local(rect.position), rect.size)
	_wave_cells = cells
	_wave_time = 0.0
	set_process(true)


## Fireworks over the top of the screen: bursts of streaks falling under their weight, in
## gold, vermilion and jade, one after the other.
func fireworks() -> void:
	if rules == null or art == null:
		return
	var palette: Array[Color] = [
		art.gold_glow, art.vermilion.lightened(0.25), art.jade.lightened(0.3)
	]
	for burst_index in rules.firework_bursts:
		_pending.append(
			Vector3(
				_rng.randf_range(0.15, 0.85) * size.x,
				_rng.randf_range(0.14, 0.4) * size.y,
				burst_index * rules.firework_interval
			)
		)
		_pending_colors.append(palette[burst_index % palette.size()])
	set_process(true)


## A word of praise popping in at `at` (global coordinates) on a ribbon `width` pixels wide,
## holding, then rising and fading out; `word` is its level (1: PRAISE_1): the ribbon's colour
## and the size grow with it, the letters stay gold.
func praise(text: String, at: Vector2, word: int, width: float) -> void:
	var font_size: int = PRAISE_FONT_SIZE + maxi(word - 1, 0) * rules.praise_size_step
	var holder: Control = Control.new()
	holder.set_meta(PRAISE_META, text)
	holder.mouse_filter = MOUSE_FILTER_IGNORE
	holder.size = Vector2(width, font_size * RIBBON_HEIGHT)
	holder.position = _local(at) - holder.size / 2.0
	holder.pivot_offset = holder.size / 2.0
	add_child(holder)
	var ribbon: Panel = Panel.new()
	ribbon.mouse_filter = MOUSE_FILTER_IGNORE
	ribbon.clip_contents = true
	ribbon.add_theme_stylebox_override("panel", _ribbon_style(word))
	ribbon.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	holder.add_child(ribbon)
	var label: Label = _label(text, font_size, PRAISE_OUTLINE, art.gold_light, art.ink)
	label.add_theme_constant_override("shadow_offset_y", 6)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	holder.add_child(label)
	label.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	holder.scale = Vector2.ONE * 0.4
	var tween: Tween = holder.create_tween()
	(
		tween
		. tween_property(holder, "scale", Vector2.ONE, rules.praise_pop)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	if word >= rules.praise_shine_from_word:
		var shine: ColorRect = ColorRect.new()
		shine.mouse_filter = MOUSE_FILTER_IGNORE
		shine.color = Color(art.gold_light, 0.35)
		shine.size = Vector2(SHINE_WIDTH, holder.size.y * 2.0)
		shine.position = Vector2(-SHINE_WIDTH * 2.0, -holder.size.y * 0.5)
		shine.rotation = 0.35
		ribbon.add_child(shine)
		tween.parallel().tween_property(shine, "position:x", width + SHINE_WIDTH, rules.praise_hold)
	tween.tween_interval(rules.praise_hold)
	tween.tween_property(
		holder, "position:y", holder.position.y - rules.praise_rise_pixels, rules.praise_fade
	)
	tween.parallel().tween_property(holder, "modulate:a", 0.0, rules.praise_fade)
	tween.tween_callback(holder.queue_free)


## The points of a move popping up at `at` (global coordinates), rising and fading out. One
## number at a time: it replaces the one still on screen.
func points(text: String, at: Vector2) -> void:
	if is_instance_valid(_points_label):
		remove_child(_points_label)
		_points_label.queue_free()
	var label: Label = _label(text, POINTS_FONT_SIZE, POINTS_OUTLINE, Color.WHITE, art.ink)
	label.add_theme_color_override("font_shadow_color", Color(art.gold, 0.9))
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.set_meta(POINTS_META, text)
	_points_label = label
	add_child(label)
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
	tween.tween_property(label, "modulate:a", 0.0, seconds * 0.3).set_delay(seconds * 0.7)
	tween.chain().tween_callback(label.queue_free)


## A gold banner across the screen sliding in from the top to `y` (local), with a crown: the
## record is beaten. It stays a moment, then slides back out.
func banner(text: String, y: float) -> void:
	var ribbon: PanelContainer = PanelContainer.new()
	ribbon.set_meta(BANNER_META, text)
	ribbon.mouse_filter = MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = art.gold
	style.border_color = art.gold_light
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 6)
	ribbon.add_theme_stylebox_override("panel", style)
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	ribbon.add_child(row)
	for side in 2:
		if side == 1:
			var label: Label = Label.new()
			label.text = text
			label.uppercase = true
			label.add_theme_font_override("font", DISPLAY_FONT)
			label.add_theme_font_size_override("font_size", BANNER_FONT_SIZE)
			label.add_theme_color_override("font_color", art.ink)
			row.add_child(label)
		var crown: Control = Control.new()
		crown.custom_minimum_size = Vector2.ONE * BANNER_HEIGHT * 0.5
		crown.size_flags_vertical = SIZE_SHRINK_CENTER
		crown.draw.connect(
			func() -> void:
				GameIcons.draw(
					crown, GameIcons.CROWN, crown.size / 2.0, crown.size.y * 0.42, art.ink
				)
		)
		row.add_child(crown)
	add_child(ribbon)
	ribbon.size = Vector2(size.x, BANNER_HEIGHT)
	ribbon.position = Vector2(0.0, -BANNER_HEIGHT * 1.5)
	var tween: Tween = ribbon.create_tween()
	(
		tween
		. tween_property(ribbon, "position:y", y, rules.banner_slide)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_interval(rules.banner_hold)
	(
		tween
		. tween_property(ribbon, "position:y", -BANNER_HEIGHT * 1.5, rules.banner_slide)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_IN)
	)
	tween.tween_callback(ribbon.queue_free)


## Shards, sparkles and streaks still flying, and fireworks still to come (tests).
func fragment_count() -> int:
	return _positions.size() + _pending.size()


## Words of praise on screen (tests).
func praise_texts() -> Array[String]:
	return _texts(PRAISE_META)


## Points on screen (tests).
func points_texts() -> Array[String]:
	return _texts(POINTS_META)


## Banners on screen (tests).
func banner_texts() -> Array[String]:
	return _texts(BANNER_META)


## Beams and rings on screen (tests).
func light_count() -> int:
	return _beams.size() + _ring_centers.size()


## Whether the wave of light of an emptied grid is passing (tests).
func has_wave() -> bool:
	return _wave_time >= 0.0


func _process(delta: float) -> void:
	_fire_pending(delta)
	var index: int = _positions.size() - 1
	while index >= 0:
		_left[index] -= delta
		if _left[index] <= 0.0:
			_remove(index)
		else:
			var kind: int = _kinds[index]
			var pull: float = rules.shard_gravity
			if kind == Kind.SPARKLE:
				pull = SPARKLE_GRAVITY
				_velocities[index] *= 1.0 - minf(3.0 * delta, 1.0)
			elif kind == Kind.STREAK:
				pull = STREAK_GRAVITY
				_velocities[index] *= 1.0 - minf(1.6 * delta, 1.0)
			_velocities[index] += Vector2.DOWN * pull * delta
			_positions[index] += _velocities[index] * delta
			_angles[index] += _spins[index] * delta
		index -= 1
	index = _beams.size() - 1
	while index >= 0:
		_beam_left[index] -= delta
		if _beam_left[index] <= 0.0:
			_beams.remove_at(index)
			_beam_origins.remove_at(index)
			_beam_left.remove_at(index)
		index -= 1
	index = _ring_centers.size() - 1
	while index >= 0:
		_ring_left[index] -= delta
		if _ring_left[index] <= 0.0:
			_ring_centers.remove_at(index)
			_ring_radii.remove_at(index)
			_ring_left.remove_at(index)
			_ring_lifetimes.remove_at(index)
		index -= 1
	if _wave_time >= 0.0:
		_wave_time += delta
		if _wave_time > _wave_seconds():
			_wave_time = -1.0
	set_process(
		(
			not _positions.is_empty()
			or not _beams.is_empty()
			or not _ring_centers.is_empty()
			or not _pending.is_empty()
			or _wave_time >= 0.0
		)
	)
	queue_redraw()
	_glow.queue_redraw()
	_rings.queue_redraw()


## Bursts whose time has come.
func _fire_pending(delta: float) -> void:
	var index: int = _pending.size() - 1
	while index >= 0:
		var burst: Vector3 = _pending[index]
		burst.z -= delta
		_pending[index] = burst
		if burst.z <= 0.0:
			var at: Vector2 = Vector2(burst.x, burst.y)
			var color: Color = _pending_colors[index]
			_pending.remove_at(index)
			_pending_colors.remove_at(index)
			for streak in rules.firework_fragments:
				var direction: Vector2 = Vector2.from_angle(
					TAU * (streak + _rng.randf() * 0.6) / rules.firework_fragments
				)
				var speed: float = rules.fragment_speed * _rng.randf_range(0.55, 1.15)
				var length: float = _rng.randf_range(
					rules.firework_streak.x, rules.firework_streak.y
				)
				_add(Kind.STREAK, at, direction * speed, color, length, rules.sparkle_seconds * 1.3)
			_sparkle(at, 4, rules.fragment_speed * 0.3, Color.WHITE)
		index -= 1


## The shards: small tiles seen from the side, ivory over jade (the tile's own colours).
func _draw() -> void:
	if art == null:
		return
	for index in _positions.size():
		if _kinds[index] != Kind.SHARD:
			continue
		var life: float = clampf(_left[index] / _lifetimes[index], 0.0, 1.0)
		# Full size, then shrinking away over the last 40 % of its life.
		var side: float = _sizes[index] * minf(life / 0.4, 1.0)
		var stone: bool = _colors[index] == art.stone_face
		draw_set_transform(_positions[index], _angles[index])
		draw_rect(
			Rect2(-side / 2.0, -side * 0.4, side, side * 0.8),
			art.stone_side if stone else art.tile_back
		)
		draw_rect(Rect2(-side / 2.0, -side * 0.4, side, side * 0.56), _colors[index])
		draw_rect(Rect2(-side / 2.0, -side * 0.4, side * 0.5, side * 0.2), Color(1, 1, 1, 0.5))
	draw_set_transform(Vector2.ZERO)


func _draw_glow() -> void:
	if art == null or rules == null:
		return
	_draw_wave()
	_draw_beams()
	for index in _positions.size():
		var kind: int = _kinds[index]
		if kind == Kind.SHARD:
			continue
		var life: float = clampf(_left[index] / _lifetimes[index], 0.0, 1.0)
		var color: Color = _colors[index]
		color.a *= minf(life * 2.0, 1.0)
		if kind == Kind.SPARKLE:
			# Twinkles: its size beats while it fades.
			var twinkle: float = 0.65 + 0.35 * absf(sin(_angles[index] * 2.0))
			var half: float = _sizes[index] * twinkle * (0.35 + 0.65 * life)
			_glow.draw_texture_rect(
				_star,
				Rect2(_positions[index] - Vector2.ONE * half, Vector2.ONE * half * 2.0),
				false,
				color
			)
		else:
			var velocity: Vector2 = _velocities[index]
			var tail: Vector2 = velocity.normalized() * _sizes[index] * (0.4 + 0.6 * life)
			_glow.draw_line(_positions[index] - tail, _positions[index], color, STREAK_WIDTH, true)


## A beam: its lit part grows from the piece to both ends of the line, then the whole fades;
## a soft halo one cell wide and a bright thin core, inside the grid.
func _draw_beams() -> void:
	for index in _beams.size():
		var progress: float = 1.0 - _beam_left[index] / rules.beam_seconds
		var sweep: float = clampf(progress / rules.beam_sweep, 0.0, 1.0)
		sweep = 1.0 - pow(1.0 - sweep, 3.0)
		var fade: float = (
			1.0 - clampf((progress - rules.beam_sweep) / (1.0 - rules.beam_sweep), 0.0, 1.0)
		)
		var rect: Rect2 = _beams[index]
		var across: bool = rect.size.x >= rect.size.y
		var from: float = _beam_origins[index].x if across else _beam_origins[index].y
		var start: float = rect.position.x if across else rect.position.y
		var end: float = rect.end.x if across else rect.end.y
		from = clampf(from, start, end)
		var low: float = lerpf(from, start, sweep)
		var high: float = lerpf(from, end, sweep)
		var middle: float = rect.get_center().y if across else rect.get_center().x
		var thickness: float = rect.size.y if across else rect.size.x
		var core: float = rules.beam_core_pixels * (0.4 + 0.6 * fade)
		var halo: Color = Color(art.gold_glow, 0.75 * fade)
		var light: Color = Color(art.gold_light, fade)
		if across:
			_glow.draw_texture_rect(
				_bar, Rect2(low, middle - thickness / 2.0, high - low, thickness), false, halo
			)
			_glow.draw_rect(Rect2(low, middle - core / 2.0, high - low, core), light)
		else:
			# A transposed texture takes its rectangle's size transposed too.
			_glow.draw_texture_rect(
				_bar, Rect2(middle - thickness / 2.0, low, high - low, thickness), false, halo, true
			)
			_glow.draw_rect(Rect2(middle - core / 2.0, low, core, high - low), light)
		# The two heads of the sweep shine while they run.
		if sweep < 1.0:
			var head: float = thickness * 0.45
			for at: float in [low, high]:
				var center: Vector2 = Vector2(at, middle) if across else Vector2(middle, at)
				_glow.draw_texture_rect(
					_star,
					Rect2(center - Vector2.ONE * head, Vector2.ONE * head * 2.0),
					false,
					light
				)


func _draw_rings() -> void:
	for index in _ring_centers.size():
		var progress: float = 1.0 - _ring_left[index] / _ring_lifetimes[index]
		var eased: float = 1.0 - (1.0 - progress) * (1.0 - progress)
		var width: float = rules.ring_width * (1.0 - progress)
		if width < 0.5:
			continue
		_rings.draw_arc(
			_ring_centers[index] - _rings.position,
			_ring_radii[index] * eased,
			0.0,
			TAU,
			64,
			Color(art.gold_glow, 1.0 - progress * 0.6),
			width,
			true
		)


## The wave over an emptied grid: each diagonal of slots flashes in turn, and a frame of light
## spreads outwards from the grid's edge.
func _draw_wave() -> void:
	if _wave_time < 0.0 or _wave_cells <= 0:
		return
	var side: float = _wave_rect.size.x / _wave_cells
	for y in _wave_cells:
		for x in _wave_cells:
			var since: float = _wave_time - (x + y) * rules.wave_step
			if since < 0.0 or since > rules.wave_flash:
				continue
			var lit: float = sin(since / rules.wave_flash * PI)
			_slot.bg_color = Color(art.gold, 0.55 * lit)
			_slot.draw(
				_glow.get_canvas_item(),
				Rect2(_wave_rect.position + Vector2(x, y) * side, Vector2.ONE * side).grow(-3.0)
			)
	var progress: float = clampf(_wave_time / _wave_seconds(), 0.0, 1.0)
	var spread: float = rules.wave_spread * (1.0 - pow(1.0 - progress, 2.0))
	_edge.border_color = Color(art.gold, 0.8 * (1.0 - progress))
	_edge.set_border_width_all(maxi(roundi(10.0 * (1.0 - progress)), 1))
	_edge.set_corner_radius_all(int(24.0 + spread))
	_edge.draw(_glow.get_canvas_item(), _wave_rect.grow(spread))


func _fit_rings() -> void:
	if _rings == null:
		return
	if ring_bounds.has_area():
		_rings.position = _local(ring_bounds.position)
		_rings.size = ring_bounds.size
	else:
		_rings.position = Vector2.ZERO
		_rings.size = size


func _wave_seconds() -> float:
	return rules.wave_step * _wave_cells * 2.0 + rules.wave_flash


func _ribbon_style(word: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var colors: Array[Color] = rules.praise_ribbons
	style.bg_color = (
		colors[clampi(word - 1, 0, colors.size() - 1)] if not colors.is_empty() else art.night
	)
	style.border_color = art.gold
	style.set_border_width_all(RIBBON_EDGE + (2 if word >= rules.praise_shine_from_word else 0))
	style.set_corner_radius_all(RIBBON_RADIUS)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 5)
	return style


func _label(text: String, font_size: int, outline: int, color: Color, edge: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_override("font", DISPLAY_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", outline)
	label.add_theme_color_override("font_outline_color", edge)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = MOUSE_FILTER_IGNORE
	return label


func _texts(meta: StringName) -> Array[String]:
	var texts: Array[String] = []
	for child in get_children():
		if child.has_meta(meta) and not child.is_queued_for_deletion():
			var text: String = child.get_meta(meta)
			texts.append(text)
	return texts


func _sparkle(from: Vector2, count: int, speed: float, color: Color) -> void:
	for _index in count:
		var direction: Vector2 = Vector2.RIGHT.rotated(_rng.randf() * TAU)
		var half: float = _rng.randf_range(rules.sparkle_size.x, rules.sparkle_size.y) / 2.0
		_add(
			Kind.SPARKLE,
			from,
			direction * speed * _rng.randf_range(0.3, 1.0),
			color,
			half,
			rules.sparkle_seconds
		)


func _add(
	kind: Kind, at: Vector2, velocity: Vector2, color: Color, size_now: float, seconds: float
) -> void:
	if _positions.size() >= rules.max_particles:
		return
	var lifetime: float = seconds * _rng.randf_range(0.8, 1.1)
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


## A four-pointed star of light with a soft heart, white on transparent.
static func _make_star() -> ImageTexture:
	var image: Image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	var half: float = TEXTURE_SIZE / 2.0
	for y in TEXTURE_SIZE:
		for x in TEXTURE_SIZE:
			var at: Vector2 = (Vector2(x, y) + Vector2.ONE * 0.5 - Vector2.ONE * half) / half
			var rays: float = clampf(
				1.0 - (pow(absf(at.x), 0.62) + pow(absf(at.y), 0.62)), 0.0, 1.0
			)
			var heart: float = clampf(1.0 - at.length() * 2.0, 0.0, 1.0)
			var light: float = clampf(rays * 3.0 + heart * heart, 0.0, 1.0)
			image.set_pixel(x, y, Color(1, 1, 1, light))
	return ImageTexture.create_from_image(image)


## Light fading out to both sides of a line (from top to bottom of the texture).
static func _make_bar() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 0))
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(0.5, Color.WHITE)
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 4
	texture.height = TEXTURE_SIZE
	return texture
