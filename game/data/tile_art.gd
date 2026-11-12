class_name TileArt
extends Resource
## Colours and proportions of the drawn tiles, grid and interface accents (tile_art.tres): the
## game's palette, "lacquer and jade at night". Nothing is an image: tiles are drawn by code
## (TileDrawing), each symbol a shape and an ink, so that colour is never the only cue.

@export_group("Tiles")
## The ivory face of a tile, its thin lighter rim and the darker seam where it meets the back.
@export var tile_face: Color = Color("f4eedc")
@export var tile_rim: Color = Color(1, 1, 1, 0.7)
@export var tile_seam: Color = Color("d9cfb4")
## The jade back every tile shares (the visible side under the face), and its darker lip.
@export var tile_back: Color = Color("2e7d62")
@export var tile_back_lip: Color = Color("1f5a46")
## Soft light falling on the top of the face.
@export var tile_light: Color = Color(1, 1, 1, 0.3)
## Symbol inks, one per symbol (a symbol is also a shape).
@export var symbol_colors: Array[Color] = []
## Stones of the level mode: face, side and the darker speckles and crack.
@export var stone_face: Color = Color("6b6f78")
@export var stone_side: Color = Color("43464e")
@export var stone_mark: Color = Color("4f525a")
## Frame of a gold tile and its inner light line; the sheet of ice, its streaks and rim.
@export var gold_color: Color = Color("e8b64c")
@export var gold_shine: Color = Color("fff3c4")
@export var ice_color: Color = Color(0.75, 0.91, 1.0, 0.45)
@export var ice_streak: Color = Color(1, 1, 1, 0.7)

@export_group("Accents")
## Gold (highlights, frames, record), its light and glow; vermilion (main buttons, combo);
## jade; the dark ink of texts on ivory; the night colour of panels and ribbons.
@export var gold: Color = Color("e8b64c")
@export var gold_light: Color = Color("ffe7a0")
@export var gold_glow: Color = Color("ffd27a")
@export var vermilion: Color = Color("d2452f")
@export var jade: Color = Color("2f8f6a")
@export var ink: Color = Color("3a1a0a")
@export var night: Color = Color("0b1222")

@export_group("Grid")
## The lacquered box around the grid: bronze lip, gold bevel, dark tray; widths in pixels of a
## 720-wide screen. `frame_inset` is the room between the cells and the frame.
@export var frame_lip: Color = Color("8c6a2e")
@export var frame_bevel: Color = Color(0.91, 0.71, 0.3, 0.75)
@export var grid_background: Color = Color("0a1020")
@export var frame_inset: float = 9.0
@export var frame_lip_width: float = 6.0
@export var frame_bevel_width: float = 2.0
## Empty slots, recessed: two shades in a faint chequer, a dark shadow on top, a light line
## at the bottom.
@export var empty_cell: Color = Color("141c33")
@export var empty_cell_alt: Color = Color("18223d")
@export var empty_cell_shadow: Color = Color("070b16")
@export var empty_cell_light: Color = Color(0.165, 0.208, 0.345, 0.6)
## Gap between cells, as a fraction of a cell.
@export var cell_gap: float = 0.06
## Landing place of the dragged piece: a silhouette and its edge; red where it does not fit.
@export var ghost_fill: Color = Color(0.96, 0.93, 0.86, 0.28)
@export var ghost_edge: Color = Color(0.91, 0.71, 0.3, 0.8)
@export var ghost_invalid: Color = Color(0.82, 0.27, 0.18, 0.4)
## Colour the cleared tiles flash to.
@export var flash: Color = Color(1, 0.95, 0.6)
## Tint of the tiles of a hint (a placement shown to a player who hesitates).
@export var hint_tint: Color = Color(1, 1, 1, 0.4)
## Seconds a cleared cell takes to fade out.
@export var flash_seconds: float = 0.35
## Tint of the grid once the game is lost: a cool night, not a grey.
@export var game_over_tint: Color = Color(0.55, 0.6, 0.85)

@export_group("Pieces")
## How far above the finger a dragged piece is drawn, in cells, so the finger does not hide it.
@export var drag_lift_cells: float = 1.2
## The dragged piece is drawn bigger and a little higher than where it would land (in cells),
## so that its landing place shows under it; its shadow and the shadow's offset in cells.
@export var drag_scale: float = 1.08
@export var drag_raise_cells: float = 0.3
@export var drag_shadow: Color = Color(0, 0, 0, 0.35)
@export var drag_shadow_offset: Vector2 = Vector2(0.07, 0.17)
## Size of a piece waiting in the tray, as a fraction of a grid cell (smaller when the piece
## would not fit its plate).
@export var tray_scale: float = 0.72
## The plate under each piece of the tray, and its border.
@export var tray_plate: Color = Color(0.07, 0.1, 0.19, 0.8)
@export var tray_plate_border: Color = Color("2a3558")

@export_group("Background")
## Screen background: a vertical gradient, with soft lights drifting up (GameBackground).
@export var background_top: Color = Color("1b2440")
@export var background_bottom: Color = Color("0b1222")
@export var light_color: Color = Color(0.91, 0.71, 0.3, 0.06)
@export var light_count: int = 12
