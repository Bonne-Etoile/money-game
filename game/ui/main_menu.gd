class_name MainMenu
extends Control
## The start menu: play (endless), the levels, the daily challenge, the options worth a button
## (how the pieces come back, vibration, music, sounds), quit.
## After a crash, it opens on the crash report, to copy and paste to Claude (Diagnostics).

const TILE_BLOCKS_SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"
const DAILY_SCENE: String = "res://game/proto_tiles/daily.tscn"
const LEVELS_SCENE: String = "res://game/levels/level_map.tscn"

## Whether the play buttons open their scene (tests turn it off and check `chosen_scene`).
@export var opens_game: bool = true

## The scene the last play button asked for.
var chosen_scene: String = ""

@onready var _main: Control = %Main
@onready var _play: Button = %PlayButton
@onready var _levels: Button = %LevelsButton
@onready var _daily: Button = %DailyButton
@onready var _refill: Button = %RefillButton
@onready var _vibration: Button = %VibrationButton
@onready var _music: Button = %MusicButton
@onready var _sounds: Button = %SoundsButton
@onready var _quit: Button = %QuitButton
@onready var _crash: Control = %Crash
@onready var _report_text: TextEdit = %ReportText
@onready var _crash_copy: Button = %CrashCopyButton
@onready var _crash_close: Button = %CrashCloseButton


func _ready() -> void:
	_play.pressed.connect(play.bind(TILE_BLOCKS_SCENE))
	_levels.pressed.connect(play.bind(LEVELS_SCENE))
	_daily.pressed.connect(play.bind(DAILY_SCENE))
	_refill.pressed.connect(toggle_refill)
	_vibration.pressed.connect(toggle_vibration)
	_music.pressed.connect(toggle_music)
	_sounds.pressed.connect(toggle_sounds)
	_quit.pressed.connect(func() -> void: get_tree().quit())
	_show_options()
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


## Opens a game scene.
func play(scene: String) -> void:
	chosen_scene = scene
	if opens_game:
		get_tree().change_scene_to_file(scene)


## Three new pieces at once when all are placed, or one new piece in each slot at once (G12).
func toggle_refill() -> void:
	Options.set_refill_together(not Options.settings.refill_together)
	_show_options()


func toggle_vibration() -> void:
	Options.set_vibration(not Options.settings.vibration)
	_show_options()


func toggle_music() -> void:
	Options.set_music(not Options.settings.music)
	_show_options()


func toggle_sounds() -> void:
	Options.set_sounds(not Options.settings.sounds)
	_show_options()


func _show_options() -> void:
	var streak: int = GameState.progress.stats.daily_streak_on(GameState.today())
	_daily.text = tr("MENU_DAILY_STREAK") % streak if streak > 0 else tr("MENU_DAILY")
	_refill.text = (
		"MENU_REFILL_TOGETHER" if Options.settings.refill_together else "MENU_REFILL_EACH"
	)
	_vibration.text = "MENU_VIBRATION_ON" if Options.settings.vibration else "MENU_VIBRATION_OFF"
	_music.text = "MENU_MUSIC_ON" if Options.settings.music else "MENU_MUSIC_OFF"
	_sounds.text = "MENU_SOUNDS_ON" if Options.settings.sounds else "MENU_SOUNDS_OFF"


func copy_crash_report() -> void:
	DisplayServer.clipboard_set(Diagnostics.crash_report)
	_crash_copy.text = "CRASH_COPIED"


func close_crash_report() -> void:
	Diagnostics.dismiss_crash_report()
	show_page(&"main")
