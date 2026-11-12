class_name BoardView
extends Control
## Draws a TileGrid in its lacquered frame, the landing place of the piece being dragged (and
## the cells it would clear, their edge pulsing gold), the placed tiles landing, and the
## cleared cells flashing and shrinking away. Only draws: the rules live in game/core/.

## Part of a clear's time the cleared tiles stay lit before they shrink away.
const FLASH_LIT: float = 0.3
## Width (pixels) under which a shrinking cleared tile is no longer drawn.
const MIN_FLASH_SIZE: float = 4.0
## The edge of the cells a move would clear: its width as a fraction of a cell, how many
## times a second it pulses, and between which strengths.
const PREVIEW_EDGE: float = 0.06
const PREVIEW_HERTZ: float = 3.0
const PREVIEW_PULSE: Vector2 = Vector2(0.5, 0.95)
## How far the landing place's silhouette is inside its cell, as a fraction of the cell.
const GHOST_INSET: float = 0.04

var grid: TileGrid
var art: TileArt
## Gold and ice of a level (G17), drawn over their tiles; null in the endless game.
var layer: LevelBoard = null
## The origin the dragged piece would take, valid only while `_ghost` is set.
var ghost_origin: Vector2i = Vector2i.ZERO
var _ghost: Piece
var _ghost_valid: bool = false
## Cells the ghost would clear (their edge pulses), and the time of the pulse.
var _preview: Array[Vector2i] = []
var _glow_time: float = 0.0
## Tiles just placed, landing (JuiceRules.pop_scale, pop_seconds).
var _pop_cells: Array[Vector2i] = []
var _pop_left: float = 0.0
var _pop_seconds: float = 0.0
var _pop_scale: float = 1.0
## A placement shown to a player who hesitates (G15), drawn as faint tiles.
var _hint: Piece
var _hint_origin: Vector2i = Vector2i.ZERO
var _flash_cells: Array[Vector2i] = []
var _flash_symbols: PackedInt32Array = []
var _flash_left: float = 0.0
## Shake of the drawing (a strong clear), in pixels; the cells do not move for the rules.
var _shake: float = 0.0
var _shake_left: float = 0.0
var _shake_seconds: float = 0.0
var _shake_rng: RandomNumberGenerator = RandomNumberGenerator.new()
## The ghost and the pulsing edges, drawn over the grid: they change at each frame of a drag,
## and the tiles under them are not drawn again for that. Made in _ready (a node made here
## would be left orphaned when the scene never enters the tree).
var _overlay: Control


func _ready() -> void:
	set_process(false)
	resized.connect(queue_redraw)
	_overlay = Control.new()
	_overlay.mouse_filter = MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)


## Side of a cell, in pixels.
func cell_size() -> float:
	if grid == null or grid.size == 0:
		return 0.0
	return minf(size.x, size.y) / grid.size


func cell_rect(cell: Vector2i) -> Rect2:
	var side: float = cell_size()
	var gap: float = side * art.cell_gap / 2.0
	return Rect2(Vector2(cell) * side, Vector2.ONE * side).grow(-gap)


## The cell whose top-left corner is nearest to `global_point`.
func nearest_cell(global_point: Vector2) -> Vector2i:
	var local: Vector2 = (global_point - global_position) / cell_size()
	return Vector2i(local.round())


## Centre of `cell`, in global coordinates.
func cell_center(cell: Vector2i) -> Vector2:
	return global_position + (Vector2(cell) + Vector2.ONE / 2.0) * cell_size()


## The grid without its frame, in global coordinates (effects stay inside it).
func grid_rect() -> Rect2:
	var cells: int = grid.size if grid != null else 0
	return Rect2(global_position, Vector2.ONE * cell_size() * cells)


func set_ghost(piece: Piece, origin: Vector2i, valid: bool) -> void:
	_ghost = piece
	ghost_origin = origin
	_ghost_valid = valid
	_overlay.queue_redraw()


func clear_ghost() -> void:
	_ghost = null
	_preview.clear()
	_overlay.queue_redraw()


## Cells the ghost would clear: their edge pulses until the ghost moves or goes.
func set_preview(cells: Array[Vector2i]) -> void:
	_preview = cells.duplicate()
	set_process(true)
	_overlay.queue_redraw()


func preview_cells() -> Array[Vector2i]:
	return _preview


## The tiles of `cells` land a little bigger (`scale`) and settle within `seconds`.
func pop(cells: Array[Vector2i], scale_from: float, seconds: float) -> void:
	if seconds <= 0.0:
		return
	_pop_cells = cells.duplicate()
	_pop_left = seconds
	_pop_seconds = seconds
	_pop_scale = scale_from
	set_process(true)
	queue_redraw()


func set_hint(piece: Piece, origin: Vector2i) -> void:
	_hint = piece
	_hint_origin = origin
	queue_redraw()


func clear_hint() -> void:
	if _hint != null:
		_hint = null
		queue_redraw()


func has_hint() -> bool:
	return _hint != null


func has_ghost() -> bool:
	return _ghost != null


func ghost_valid() -> bool:
	return _ghost_valid


## Grid cells under the ghost.
func ghost_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if _ghost != null:
		for cell in _ghost.cells:
			cells.append(ghost_origin + cell)
	return cells


## Shakes the drawing `pixels` wide, fading out over `seconds`.
func shake(pixels: float, seconds: float) -> void:
	if pixels <= 0.0 or seconds <= 0.0:
		return
	_shake = pixels
	_shake_left = seconds
	_shake_seconds = seconds
	set_process(true)


func is_shaking() -> bool:
	return _shake_left > 0.0


## Shows the cells just cleared fading out.
func flash(result: MoveResult) -> void:
	_flash_cells = result.clear.cells.duplicate()
	_flash_symbols = result.cleared_symbols.duplicate()
	_flash_left = art.flash_seconds
	set_process(not _flash_cells.is_empty())
	queue_redraw()


func _process(delta: float) -> void:
	# The grid itself is drawn again only while its tiles move.
	var moving: bool = not _flash_cells.is_empty() or not _pop_cells.is_empty() or _shake > 0.0
	_flash_left -= delta
	_shake_left = maxf(_shake_left - delta, 0.0)
	_pop_left = maxf(_pop_left - delta, 0.0)
	_glow_time += delta
	if _flash_left <= 0.0:
		_flash_cells.clear()
	if _pop_left <= 0.0:
		_pop_cells.clear()
	if _shake_left <= 0.0:
		_shake = 0.0
	set_process(
		(
			not _flash_cells.is_empty()
			or _shake_left > 0.0
			or not _pop_cells.is_empty()
			or not _preview.is_empty()
		)
	)
	if moving:
		queue_redraw()
	if not _preview.is_empty():
		_overlay.queue_redraw()


func _draw() -> void:
	if grid == null or art == null:
		return
	var shift: Vector2 = Vector2.ZERO
	if _shake_left > 0.0:
		var strength: float = _shake * _shake_left / _shake_seconds
		shift = Vector2(_shake_rng.randf_range(-1, 1), _shake_rng.randf_range(-1, 1)) * strength
	draw_set_transform(shift)
	_overlay.position = shift
	_draw_frame()
	for y in grid.size:
		for x in grid.size:
			var cell: Vector2i = Vector2i(x, y)
			var symbol: int = grid.symbol_at(cell)
			var rect: Rect2 = cell_rect(cell)
			if symbol == TileGrid.EMPTY:
				_draw_slot(rect, (x + y) % 2 == 1)
			elif not _pop_cells.has(cell):
				TileDrawing.draw_tile(self, rect, symbol, art)
				_draw_layer(cell)
	_draw_pops()
	_draw_hint()
	_draw_flash()


## The lacquered box: a bronze lip, a gold bevel, the dark tray. Its corners follow the cells'
## (same centre), so that no cell pokes out of it.
func _draw_frame() -> void:
	var side: float = cell_size()
	var whole: Rect2 = Rect2(Vector2.ZERO, Vector2.ONE * side * grid.size)
	var gap: float = side * art.cell_gap / 2.0
	var cell_radius: float = side * (1.0 - art.cell_gap) * TileDrawing.CORNER
	var inset: float = art.frame_inset - gap
	var bevel: float = inset + art.frame_bevel_width
	var lip: float = bevel + art.frame_lip_width
	var radius: float = cell_radius + gap
	# A shadow under the box, then its layers from the outside in.
	TileDrawing.draw_box(
		self, whole.grow(lip).grow_side(SIDE_BOTTOM, 8.0), Color(0, 0, 0, 0.35), radius + lip
	)
	TileDrawing.draw_box(self, whole.grow(lip), art.frame_lip.darkened(0.45), radius + lip)
	TileDrawing.draw_box(
		self, whole.grow(lip).grow_side(SIDE_BOTTOM, -3.0), art.frame_lip, radius + lip
	)
	TileDrawing.draw_box(self, whole.grow(bevel), art.frame_bevel, radius + bevel)
	TileDrawing.draw_box(self, whole.grow(inset), art.grid_background, radius + inset)


## An empty slot, recessed: a dark shadow under its top edge, a light line at its bottom.
func _draw_slot(rect: Rect2, alternate: bool) -> void:
	TileDrawing.draw_box(self, rect, art.empty_cell_shadow)
	var floor_rect: Rect2 = rect.grow_side(SIDE_TOP, -rect.size.y * 0.05)
	TileDrawing.draw_box(self, floor_rect, art.empty_cell_light)
	TileDrawing.draw_box(
		self,
		floor_rect.grow_side(SIDE_BOTTOM, -1.5),
		art.empty_cell_alt if alternate else art.empty_cell
	)


func _draw_flash() -> void:
	if _flash_cells.is_empty():
		return
	# First lit up (white-hot), then shrinking away while fading.
	var elapsed: float = 1.0 - clampf(_flash_left / art.flash_seconds, 0.0, 1.0)
	var lit: float = clampf(1.0 - elapsed / FLASH_LIT, 0.0, 1.0)
	var shrink: float = clampf((elapsed - FLASH_LIT) / (1.0 - FLASH_LIT), 0.0, 1.0)
	var scale_now: float = 1.0 + 0.12 * lit - shrink
	for index in _flash_cells.size():
		var rect: Rect2 = cell_rect(_flash_cells[index])
		var grown: Rect2 = Rect2(
			rect.get_center() - rect.size * scale_now / 2.0, rect.size * scale_now
		)
		# Nearly gone: a symbol this small cannot be triangulated (errors in the log).
		if grown.size.x < MIN_FLASH_SIZE:
			continue
		var tint: Color = Color.WHITE.lerp(art.flash, 1.0 - lit)
		tint.a = 1.0 - shrink * shrink
		TileDrawing.draw_tile(self, grown, _flash_symbols[index], art, tint)
		if lit > 0.0:
			TileDrawing.draw_box(self, grown, Color(art.gold_light, lit * 0.85))


## Gold tiles get a rounded golden frame with a light line and a glint; tiles under ice a pale
## sheet with two streaks and a white rim.
func _draw_layer(cell: Vector2i) -> void:
	if layer == null:
		return
	var rect: Rect2 = cell_rect(cell)
	var side: float = rect.size.x
	if layer.is_gold(cell):
		TileDrawing.draw_outline(self, rect, art.gold_color.darkened(0.3), side * 0.085)
		TileDrawing.draw_outline(
			self, rect.grow_side(SIDE_BOTTOM, -side * 0.03), art.gold_color, side * 0.075
		)
		TileDrawing.draw_outline(
			self,
			rect.grow(-side * 0.065),
			Color(art.gold_shine, 0.9),
			side * 0.025,
			side * (TileDrawing.CORNER - 0.065)
		)
		var glint: Vector2 = rect.position + Vector2(0.2, 0.17) * side
		var arm: float = side * 0.1
		draw_line(glint - Vector2(arm, 0.0), glint + Vector2(arm, 0.0), Color.WHITE, 2.0, true)
		draw_line(glint - Vector2(0.0, arm), glint + Vector2(0.0, arm), Color.WHITE, 2.0, true)
	if layer.has_ice(cell):
		TileDrawing.draw_box(self, rect, art.ice_color)
		TileDrawing.draw_outline(self, rect, Color(1, 1, 1, 0.85), side * 0.03)
		for streak: Vector2 in [Vector2(0.2, 0.42), Vector2(0.34, 0.6)]:
			draw_line(
				rect.position + Vector2(streak.x, streak.y) * side,
				rect.position + Vector2(streak.y, streak.x) * side,
				art.ice_streak,
				side * (0.07 if streak.x < 0.3 else 0.035),
				true
			)


func _draw_hint() -> void:
	if _hint == null:
		return
	for index in _hint.cells.size():
		var rect: Rect2 = cell_rect(_hint_origin + _hint.cells[index])
		TileDrawing.draw_tile(self, rect, _hint.symbols[index], art, art.hint_tint)
		TileDrawing.draw_outline(self, rect, art.ghost_edge, rect.size.x * 0.035)


func _draw_overlay() -> void:
	if grid == null or art == null:
		return
	_draw_preview()
	_draw_ghost()


## Where the dragged piece would land: a silhouette without symbols, edged with gold (the
## piece itself floats just above it); where it does not fit, red.
func _draw_ghost() -> void:
	if _ghost == null:
		return
	for index in _ghost.cells.size():
		var target: Vector2i = ghost_origin + _ghost.cells[index]
		if not grid.has_cell(target):
			continue
		var rect: Rect2 = cell_rect(target)
		rect = rect.grow(-rect.size.x * GHOST_INSET)
		var edge: float = rect.size.x * 0.045
		if _ghost_valid:
			TileDrawing.draw_box(_overlay, rect, art.ghost_fill)
			TileDrawing.draw_outline(_overlay, rect, art.ghost_edge, edge)
		else:
			TileDrawing.draw_box(_overlay, rect, art.ghost_invalid)
			TileDrawing.draw_outline(_overlay, rect, Color(art.vermilion, 0.8), edge)


## The cells the ghost would clear keep their colours; a gold edge pulses around each.
func _draw_preview() -> void:
	if _preview.is_empty():
		return
	var beat: float = 0.5 + 0.5 * sin(_glow_time * TAU * PREVIEW_HERTZ)
	var strength: float = lerpf(PREVIEW_PULSE.x, PREVIEW_PULSE.y, beat)
	var edge: Color = Color(art.gold_glow, strength)
	var wash: Color = Color(art.gold_light, 0.08 + 0.1 * beat)
	for cell in _preview:
		var rect: Rect2 = cell_rect(cell)
		var width: float = rect.size.x * PREVIEW_EDGE
		TileDrawing.draw_box(_overlay, rect, wash)
		TileDrawing.draw_outline(_overlay, rect.grow(width * 0.4), edge, width)


## Tiles just placed: drawn bigger, settling back with a little bounce.
func _draw_pops() -> void:
	if _pop_cells.is_empty():
		return
	var progress: float = 1.0 - _pop_left / _pop_seconds
	var bounce: float = 1.0 + (_pop_scale - 1.0) * (1.0 - progress) * cos(progress * PI * 1.5)
	for cell in _pop_cells:
		var symbol: int = grid.symbol_at(cell)
		if symbol == TileGrid.EMPTY:
			continue
		var rect: Rect2 = cell_rect(cell)
		var size_now: Vector2 = rect.size * bounce
		TileDrawing.draw_tile(
			self, Rect2(rect.get_center() - size_now / 2.0, size_now), symbol, art
		)
		_draw_layer(cell)
