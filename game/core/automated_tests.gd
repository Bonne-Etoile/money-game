class_name AutomatedTests
extends RefCounted
## Whether the game runs under the automated tests (`make test` sets GAME_TESTS=1).
## Purely visual and slow parts (decor, post-processing) may be left out then: the software
## renderer of the cloud session and of CI is slow, and the tests do not look at the image.
## Screenshots and the exported game keep everything.

const VARIABLE: String = "GAME_TESTS"


static func are_running() -> bool:
	return OS.get_environment(VARIABLE) == "1"
