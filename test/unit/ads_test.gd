extends GdUnitTestSuite
## The Ads autoload (game/autoload/ads.gd) with the fake backend: the result of a rewarded ad
## reaches Events with what it was for, and the ready state is passed on.

var _finished: Array[Array] = []


func before_test() -> void:
	_finished.clear()
	Events.rewarded_ad_finished.connect(_on_finished)


func after_test() -> void:
	Events.rewarded_ad_finished.disconnect(_on_finished)
	Ads.use_backend(FakeAdsBackend.new())


func _on_finished(placement: String, rewarded: bool) -> void:
	_finished.append([placement, rewarded])


func test_a_watched_ad_is_announced_with_its_placement() -> void:
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	Ads.use_backend(fake)
	assert_bool(Ads.is_rewarded_ready()).is_true()
	Ads.show_rewarded("continue")
	assert_int(fake.shown).is_equal(1)
	assert_that(_finished).is_equal([["continue", true]] as Array[Array])


func test_an_ad_that_is_not_ready_ends_without_reward() -> void:
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	fake.ready = false
	Ads.use_backend(fake)
	assert_bool(Ads.is_rewarded_ready()).is_false()
	Ads.show_rewarded("continue")
	assert_int(fake.shown).is_equal(0)
	assert_that(_finished).is_equal([["continue", false]] as Array[Array])


func test_the_ready_state_reaches_events() -> void:
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	Ads.use_backend(fake)
	var monitor: GdUnitSignalAssert = assert_signal(Events)
	fake.ready = false
	await monitor.is_emitted("rewarded_ad_ready_changed", [false])


func test_the_default_backend_off_android_is_the_fake_one() -> void:
	assert_object(Ads.backend).is_instanceof(FakeAdsBackend)
