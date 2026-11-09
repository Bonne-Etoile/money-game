extends GdUnitTestSuite
## The race against the record (game/core/record_chase.gd).


func test_without_a_record_nothing_is_missing() -> void:
	var chase: RecordChase = RecordChase.new(0)
	assert_bool(chase.has_record()).is_false()
	assert_int(chase.percent(50)).is_equal(0)
	assert_int(chase.missing(50)).is_equal(0)
	assert_bool(chase.is_beaten(50)).is_false()


func test_the_bar_fills_up_to_the_record() -> void:
	var chase: RecordChase = RecordChase.new(400)
	assert_int(chase.percent(0)).is_equal(0)
	assert_int(chase.percent(100)).is_equal(25)
	assert_int(chase.percent(1000)).is_equal(100)


func test_the_points_missing_to_beat_the_record() -> void:
	var chase: RecordChase = RecordChase.new(400)
	assert_int(chase.missing(280)).is_equal(121)
	assert_int(chase.missing(400)).is_equal(1)
	assert_int(chase.missing(401)).is_equal(0)


func test_the_record_is_beaten_once() -> void:
	var chase: RecordChase = RecordChase.new(400)
	assert_bool(chase.is_beaten(400)).is_false()
	assert_bool(chase.beaten_between(390, 410)).is_true()
	assert_bool(chase.beaten_between(410, 430)).is_false()
	assert_bool(chase.beaten_between(300, 400)).is_false()
