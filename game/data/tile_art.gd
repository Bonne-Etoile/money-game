class_name TileArt
extends Resource
## Colours and proportions of the drawn tiles and grid (tile_art.tres). The prototype has no
## image: tiles are drawn by code (TileDrawing), each symbol a shape and a colour.

@export var background: Color = Color(0.11, 0.14, 0.2)
@export var grid_background: Color = Color(0.07, 0.09, 0.13)
@export var empty_cell: Color = Color(0.16, 0.2, 0.28)
@export var tile_face: Color = Color(0.96, 0.93, 0.85)
@export var tile_side: Color = Color(0.72, 0.62, 0.45)
@export var ghost_valid: Color = Color(1, 1, 1, 0.35)
@export var ghost_invalid: Color = Color(1, 0.3, 0.3, 0.35)
@export var flash: Color = Color(1, 0.95, 0.6)
## Tint of the tiles of a hint (a placement shown to a player who hesitates).
@export var hint_tint: Color = Color(1, 1, 1, 0.4)
## Stones of the level mode (G17): face and side.
@export var stone_face: Color = Color(0.5, 0.52, 0.56)
@export var stone_side: Color = Color(0.32, 0.33, 0.37)
## Frame of a gold tile, and the sheet over a tile under ice (level mode).
@export var gold_color: Color = Color(1.0, 0.8, 0.2)
@export var ice_color: Color = Color(0.7, 0.9, 1.0, 0.55)
## Symbol colours, one per symbol (a symbol is also a shape: colour is never the only cue).
@export var symbol_colors: Array[Color] = []
## Gap between cells, as a fraction of a cell.
@export var cell_gap: float = 0.06
## How far above the finger a dragged piece is drawn, in cells, so the finger does not hide it.
@export var drag_lift_cells: float = 1.2
## Size of a piece waiting in the tray, as a fraction of a grid cell.
@export var tray_scale: float = 0.55
## Seconds a cleared cell takes to fade out.
@export var flash_seconds: float = 0.35
