extends GdUnitTestSuite


func test_empty_stats_are_zero() -> void:
	var stats: FrameStats = FrameStats.new()
	assert_int(stats.count()).is_equal(0)
	assert_float(stats.mean()).is_equal(0.0)
	assert_float(stats.percentile(0.95)).is_equal(0.0)
	assert_float(stats.maximum()).is_equal(0.0)


func test_mean_percentile_and_maximum() -> void:
	var stats: FrameStats = FrameStats.new()
	for value in range(1, 101):
		stats.add(float(value))
	assert_int(stats.count()).is_equal(100)
	assert_float(stats.mean()).is_equal_approx(50.5, 0.0001)
	assert_float(stats.percentile(0.95)).is_equal(95.0)
	assert_float(stats.percentile(0.5)).is_equal(50.0)
	assert_float(stats.percentile(1.0)).is_equal(100.0)
	assert_float(stats.maximum()).is_equal(100.0)


func test_percentile_ignores_the_order_of_the_samples() -> void:
	var stats: FrameStats = FrameStats.new()
	for value: float in [9.0, 1.0, 5.0, 3.0, 7.0]:
		stats.add(value)
	assert_float(stats.percentile(0.6)).is_equal(5.0)
	assert_float(stats.maximum()).is_equal(9.0)
