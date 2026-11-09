class_name AdMobAdsBackend
extends AdsBackend
## Rewarded ads through the poingstudios AdMob plugin (addons/admob, docs/architecture.md,
## decision 18). Used on Android only: elsewhere the plugin has no native side. Order at start,
## as AdMob requires: the consent form of the User Messaging Platform when the law asks for it
## (EEA, United Kingdom), then the SDK, then the first rewarded ad. A new one loads as soon as
## one closes, and again after `settings.retry_delay_seconds` when a load fails.

var settings: AdSettings
var _loader: RewardedAdLoader
var _ad: RewardedAd
var _earned: bool = false
var _started: bool = false


func _init(ad_settings: AdSettings) -> void:
	settings = ad_settings


func start() -> void:
	if _started:
		return
	_started = true
	var params: ConsentRequestParameters = ConsentRequestParameters.new()
	params.tag_for_under_age_of_consent = settings.tag_for_under_age_of_consent
	UserMessagingPlatform.consent_information.update(
		params, _on_consent_info_updated, func(_error: FormError) -> void: _initialize()
	)


func is_rewarded_ready() -> bool:
	return _ad != null


func show_rewarded() -> void:
	if _ad == null:
		rewarded_finished.emit(false)
		return
	_earned = false
	var listener: OnUserEarnedRewardListener = OnUserEarnedRewardListener.new()
	listener.on_user_earned_reward = func(_item: RewardedItem) -> void: _earned = true
	_ad.show(listener)


func _on_consent_info_updated() -> void:
	var consent: ConsentInformation = UserMessagingPlatform.consent_information
	var required: bool = consent.get_consent_status() == ConsentInformation.ConsentStatus.REQUIRED
	if not (required and consent.get_is_consent_form_available()):
		_initialize()
		return
	UserMessagingPlatform.load_consent_form(
		func(form: ConsentForm) -> void: form.show(func(_error: FormError) -> void: _initialize()),
		func(_error: FormError) -> void: _initialize()
	)


func _initialize() -> void:
	var listener: OnInitializationCompleteListener = OnInitializationCompleteListener.new()
	listener.on_initialization_complete = func(_status: InitializationStatus) -> void: _load()
	MobileAds.initialize(listener)


func _load() -> void:
	if _ad != null:
		return
	var callback: RewardedAdLoadCallback = RewardedAdLoadCallback.new()
	callback.on_ad_loaded = _on_loaded
	callback.on_ad_failed_to_load = _on_failed_to_load
	_loader = RewardedAdLoader.new()
	_loader.load(settings.rewarded_unit_android, AdRequest.new(), callback)


func _on_loaded(ad: RewardedAd) -> void:
	_ad = ad
	var callbacks: FullScreenContentCallback = FullScreenContentCallback.new()
	callbacks.on_ad_dismissed_full_screen_content = func() -> void: _close(_earned)
	callbacks.on_ad_failed_to_show_full_screen_content = func(_error: AdError) -> void:
		_close(false)
	_ad.full_screen_content_callback = callbacks
	rewarded_ready_changed.emit(true)


func _on_failed_to_load(error: LoadAdError) -> void:
	Diagnostics.note("Rewarded ad failed to load: %s" % error.message)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	tree.create_timer(settings.retry_delay_seconds).timeout.connect(_load)


## The ad closed (or could not show): it is freed, the result announced, the next one loaded.
func _close(rewarded: bool) -> void:
	if _ad != null:
		_ad.destroy()
		_ad = null
	rewarded_ready_changed.emit(false)
	rewarded_finished.emit(rewarded)
	_load()
