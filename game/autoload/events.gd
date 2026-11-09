extends Node
## Global signals: scenes announce and listen through here instead of referencing each other
## (docs/architecture.md, decision 4). Emitted by other scripts, hence the ignored warnings.
## Add one signal per game event, with a comment saying who emits it and what it carries.

## The player's money changed (GameState.earn, GameState.spend).
@warning_ignore("unused_signal")
signal money_changed(total: int)
## A new playthrough started, or a saved one was loaded (GameState).
@warning_ignore("unused_signal")
signal game_started
## A rewarded ad became ready to show, or stopped being ready (Ads).
@warning_ignore("unused_signal")
signal rewarded_ad_ready_changed(ready: bool)
## A rewarded ad asked for `placement` closed; `rewarded` is true when the player watched it
## to the end and earned the reward (Ads).
@warning_ignore("unused_signal")
signal rewarded_ad_finished(placement: String, rewarded: bool)
