# Lootlings owner test build

Install Lootlings Owner Test alongside the normal Lootlings app. They have different Android application IDs. The owner app starts with its own data and does not import the regular app save. RETURN TO NORMAL PROFILE refers to the owner app's normal profile, never transferring test data to the regular app. Owner cheats are disabled in the normal Android candidate. Both are debug-signed testing candidates, not production-store releases.

On the title screen hold two fingers in opposite upper corners for 2.5 seconds, then release both. On first use choose and repeat a 6-12 digit PIN. Future use requires that PIN. The app stores a salted hash; no common PIN is shipped. The hidden gesture is discoverability control, not security against someone modifying a debug build.

Unlocking reloads an isolated test profile. The existing F1 menu opens with Run & Combat, Gear & Loot, Progression and Diagnostics groups. Actions scroll. Use the category selector, numeric Lootcoin field or item catalog picker. Close the panel to play; a test-profile indicator remains. Desktop F1 retains the same menu and requires entering the isolated profile before using commands.

RETURN TO NORMAL PROFILE reloads normal progress without copying test items, currencies, settings or progression. Test saves persist separately for later testing. RESET LOOTLINGS TEST SAVES requires confirmation and affects only explicit sandbox files. It does not reset the owner PIN.

Keep the owner APK private. Physical S23 touch, keyboard and playback acceptance remains pending. Native tests cover three layouts and representative commands; every legacy cheat has not been individually touch-tested.
