class_name AdSettings
extends Resource
## Ad unit identifiers (ad_settings.tres), read by the AdMob backend of the Ads autoload.
## The AdMob app identifier is a project setting of the plugin (admob/general/android/app_id).
## Until the real AdMob account exists, these are Google's test identifiers: they always serve
## test ads and can never earn or get the account banned (docs/avant-la-sortie.md).

## Rewarded ad unit on Android.
@export var rewarded_unit_android: String = ""
## Asks AdMob for an under-age-of-consent treatment (only if the game targets children).
@export var tag_for_under_age_of_consent: bool = false
## Seconds before loading again after a failed load.
@export var retry_delay_seconds: int = 30
