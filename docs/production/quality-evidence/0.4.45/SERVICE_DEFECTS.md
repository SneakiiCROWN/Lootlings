# 0.4.45 live service defect correction

Confirmed against current live 0.4.44 native screenshots, not old DEBUG captures. Title nickname/profile/selector separators repaired from repeated mojibake with UTF-8 source retained. Tagline moved clear of approved wordmark. Forge rows enlarged to 84 logical pixels, captions reserve selection space, horizontal scrolling disabled, list/detail regions separated. Contracts now use approved crystal/gold frames and readable named goals, progress, reward and whole-card claim; plain beige removed. Regional bounty selections use the same existing frame system.

Dungeons/Siege and Engine explain Crownroot fragments versus the Gravebloom Staff without modifying any IDs, recipe cost, drop chance or spin economy. Engine primary actions use approved gold framing; locked dungeon routes state their unlock condition. Native combat review found enemy name/HP frames crossing raised weapons; nonboss frames moved above the action area. Existing Hub scale, portal, grounding and station routes preserved. Approved title music hash unchanged.

Functional native tests: connected_services_native_qa (actual inherited fixture now executed) passed; service_quality_045_native_qa passed phone 1080x2340, tablet 1200x1920 and desktop 1920x1080. Named-title/profile, Forge selection/last rows, Shop/Stash, Contract progress/ready/claim, Expeditions, Dungeons/Siege, earned Engine spin and return captured. Exact Contract claim +10 Gold and selection/input behavior verified with disposable saves.

Visual review: current native phone screens inspected. Tablet/desktop artistic review continues. Whole screens are NOT professionally approved. Generic item art, fuller NPC/world motion, Home furniture cohesion, remaining character/enemy/boss/companion/weapon continuity and physical device acceptance remain open. No new art contracts closed in this UI-only checkpoint.

QA runner defect repaired: inherited SceneTree fixtures are followed recursively; explicitly requested skipped fixtures now fail instead of returning an empty success.
