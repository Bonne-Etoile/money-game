class_name MainMenu
extends Control
## The start menu: one button per prototype to compare (docs/backlog.md, G1 and G2), quit.
## After a crash, it opens on the crash report, to copy and paste to Claude (Diagnostics).

const TILE_BLOCKS_SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"
const PYRAMID_SCENE: String = "res://game/proto_pyramid/pyramid.tscn"

## Whether the play buttons open their scene (tests turn it off and check `chosen_scene`).
@export var opens_game: bool = true

## The scene the last play button asked for.
var chosen_scene: String = ""

@onready var _main: Control = %Main
@onready var _play: Button = %PlayButton
@onready var _play_pyramid: Button = %PlayPyramidButton
@onready var _quit: Button = %QuitButton
@onready var _crash: Control = %Crash
@onready var _report_text: TextEdit = %ReportText
@onready var _crash_copy: Button = %CrashCopyButton
@onready var _crash_close: Button = %CrashCloseButton


func _ready() -> void:
	_play.pressed.connect(play.bind(TILE_BLOCKS_SCENE))
	_play_pyramid.pressed.connect(play.bind(PYRAMID_SCENE))
	_quit.pressed.connect(func() -> void: get_tree().quit())
	_crash_copy.pressed.connect(copy_crash_report)
	_crash_close.pressed.connect(close_crash_report)
	show_page(&"crash" if not Diagnostics.crash_report.is_empty() else &"main")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and _crash.visible:
		close_crash_report()
		get_viewport().set_input_as_handled()


## Shows one page of the menu: `main` or `crash`.
func show_page(page: StringName) -> void:
	_main.visible = page == &"main"
	_crash.visible = page == &"crash"
	if page == &"crash":
		_report_text.text = Diagnostics.crash_report
		_crash_copy.text = "CRASH_COPY"
		_crash_copy.grab_focus()
	else:
		_play.grab_focus()


## Opens a prototype (no save: each game starts afresh).
func play(scene: String) -> void:
	chosen_scene = scene
	if opens_game:
		get_tree().change_scene_to_file(scene)


func copy_crash_report() -> void:
	DisplayServer.clipboard_set(Diagnostics.crash_report)
	_crash_copy.text = "CRASH_COPIED"


func close_crash_report() -> void:
	Diagnostics.dismiss_crash_report()
	show_page(&"main")
