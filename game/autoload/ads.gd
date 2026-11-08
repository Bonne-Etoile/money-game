extends Node
## Ads for the whole game (docs/architecture.md, decision 18): scenes ask here for a rewarded
## ad and hear the result through Events. Behind it, AdMob on Android and FakeAdsBackend
## everywhere else; tests swap the backend with `use_backend`.
## Only opt-in rewarded ads, offered by a button (docs/strategies-pub.md).

const SETTINGS: AdSettings = preload("res://game/data/ad_settings.tres")

var backend: AdsBackend
## What the rewarded ad being shown is for ("" when none is shown).
var _placement: String = ""


func _ready() -> void:
	var chosen: AdsBackend = FakeAdsBackend.new()
	if OS.get_name() == "Android" and Engine.has_singleton("PoingGodotAdMob"):
		chosen = AdMobAdsBackend.new(SETTINGS)
	use_backend(chosen)


## Puts `new_backend` in place and starts it (the game at start, tests with a fake one).
func use_backend(new_backend: AdsBackend) -> void:
	backend = new_backend
	_placement = ""
	backend.rewarded_ready_changed.connect(_on_ready_changed)
	backend.rewarded_finished.connect(_on_finished)
	backend.start.call_deferred()


func is_rewarded_ready() -> bool:
	return backend.is_rewarded_ready()


## Shows a rewarded ad for `placement`; Events.rewarded_ad_finished tells how it ended.
## Ignored while another one is showing.
func show_rewarded(placement: String) -> void:
	if not _placement.is_empty():
		return
	_placement = placement
	Diagnostics.note("rewarded ad: %s" % placement)
	backend.show_rewarded()


func _on_ready_changed(ready: bool) -> void:
	Events.rewarded_ad_ready_changed.emit(ready)


func _on_finished(rewarded: bool) -> void:
	var placement: String = _placement
	_placement = ""
	Events.rewarded_ad_finished.emit(placement, rewarded)
