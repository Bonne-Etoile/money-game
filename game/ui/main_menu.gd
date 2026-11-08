class_name MainMenu
extends Control
## The start menu: play (continues the latest save, or starts a new one), quit. After a crash,
## it opens on the crash report, to copy and paste to Claude (Diagnostics).

const GAME_SCENE: String = "res://game/main.tscn"

## Whether "Play" opens the game scene (tests turn it off and check GameState instead).
@export var opens_game: bool = true

@onready var _main: Control = %Main
@onready var _play: Button = %PlayButton
@onready var _quit: Button = %QuitButton
@onready var _crash: Control = %Crash
@onready var _report_text: TextEdit = %ReportText
@onready var _crash_copy: Button = %CrashCopyButton
@onready var _crash_close: Button = %CrashCloseButton


func _ready() -> void:
	_play.pressed.connect(play)
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


## Continues the latest playthrough, or starts a new one.
func play() -> void:
	var latest: int = GameState.saves.latest()
	if latest < 0 or not GameState.load_game(latest):
		GameState.new_game()
	if opens_game:
		get_tree().change_scene_to_file(GAME_SCENE)


func copy_crash_report() -> void:
	DisplayServer.clipboard_set(Diagnostics.crash_report)
	_crash_copy.text = "CRASH_COPIED"


func close_crash_report() -> void:
	Diagnostics.dismiss_crash_report()
	show_page(&"main")
