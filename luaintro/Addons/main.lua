if addon.InGetInfo then
	return {
		name    = "Main",
		desc    = "displays a simplae loadbar",
		author  = "jK",
		date    = "2012,2013",
		license = "GPL2",
		layer   = 0,
		depend  = {"LoadProgress"},
		enabled = true,
	}
end

VFS.Include("gamedata/taptools.lua")
------------------------------------------

local showTips = true
if (Spring.GetConfigInt("LoadscreenTips",1) or 1) == 0 then
	showTips = false
end

local lastLoadMessage = ""

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
end

------------------------------------------

-- Random tips we can show
local tips = {
    "corhrk.dds ".."Some units can only be obtained by morph, like the Kern Hunchback (T4 Flak Artillery, morphed from Mortars) and the Bow Thor (T5 Thermo bot, morphed from Rogues).",
    "corshark.dds ".."Certain units are built in groups of two or more. Their description will show, ie. [x2] so you can know about it, and the cost shown is the total for all units. You retain individual control after they're built.",
    "armsolar.dds ".."You may order your builder or outpost to build structures in an array-like pattern by holding SHIFT+ALT and dragging with the left mouse button. Spread them up by hitting 'T' on keyboard while the Shift key is held. Ctrl+Shift+T brings them closer.",
    "armwin.dds ".."Wind Generators built on high ground have a bonus compared to units built closer to the sea level. Isn't nature beautiful?",
    "armfdrag.dds ".."Dragon Teeth can block low-height missiles, bullets and laser shots, like those from basic bots. Shark Teeth only block ships movement.",
    "cordrag.dds ".."Bow and Kern's Dragon Teeth (DTs) are great to surround perimeters, preventing lower-tech units movement. They also block incoming direct-fire and missiles from going through, so improve your defenses resistance by surrounding them with DTs.",
    "armdrag.dds ".."Artillery is great to break frontline stalemates, but they'll inevitably attract a 'payback wave' after they start firing. Before you start, try and wall-in your towers there and create a 'choke wall' with dragon teeth to turn the odds in your favor.",
    "armcom.dds ".."The D-Gun is the Commander's manual-fire ability and the most powerful weapon in the game, one-shotting even huge experimental T6 units. Upgrade it in the commander menu after your Tech Center is level 2, then use it with the 'D' keyboard shortcut. Level 3+ Commanders get the D-Gun by default.",
    "corcom.dds ".."The Commander explosion radius is large, but the heavy EMP aftershock radius is much larger and very long lasting. It's a valid strategy to sacrifice you commander and have an army waiting to take out the remaining enemy units.",
    "armyork.dds ".."Flak-weaponry units, like the Claw, fire scattered projectiles. Flak is excellent at taking out fighters and heavy infantry, but will barely scratch tanks and aren't very effective vs heavy air, light or support bots.",
    "armaak.dds ".."The Bow Seraph (Tech 4) and the Kern Sphinx (Tech 5) fire long range missiles. Like all AA (anti-air) missiles, it's great vs bombers but not so much against fighters.",
	"outpost.dds ".."To build unit factories you need an Outpost. Outposts can morph up to Tech 6, with increasingly better build range and LOS.",
    "armsilo.dds ".."It's not just about upgrading the Tech Center! Keep upgrading your outpost. Building structures from it is much cheaper than morphing, and it'll build exclusive structures like Obliterators, Nukes and EMP Launchers.",
    "armshltx.dds ".."To build super units like the Kern Khorvid and Bow Titan, you need a Super-unit plant, built exclusively by a Level 6 outpost",
    "corafus.dds ".."The 'AFUS' or Advanced Fusion Reactor has the best energy output in your army. You can get AFUSes by morphing a regular Fusion Plant, once you're Tech Level 4",
    "armawin.dds ".."When the wind is blowing in your favor, Advanced Wind Generators are available on Tech 4 as morphs from the regular Wind Generator.",
    "cormuskrat.dds ".."FARCs and Muskrats are units built directly by the Outpost. They're great for early scout, can build dragon eyes (stealth remote cameras) and may assist factories (faster unit production speed).",
    "outpost.dds ".."Outposts can speed up any construction, but they're less cost effective for that than FARCs (built by the outpost) and they spend energy continuously.",
	"armtech.dds ".."To tech up, build a Tech Center, then upgrade it progressively until Tech 6. This unlocks high-tech upgrades in factories and outposts as well.",
	"armtech.dds ".."When under attack, Tech Centers can become 70% more resistant if disabled (ON/OFF button or Ctrl+X shortcut)",
    "corraid.dds ".."Vehicles become progressively slower when they drop below 45% health. Use that for your advantage, to prevent them from using hit-and-run tactics effectively.",
	"corgat.dds ".."Gatlings and Flares are terrific anti-kbot vehicles, very EMP-resistant and moderately effective against lighter gunships. When facing tanks or combos of plasma and missile bots, don't expect them to last long.",
    "corlevlr.dds ".."Kern Lancers and Bow Pokers are early game assault units. One of their unique abilities is the capacity to dodge bot missiles when properly microed and kept moving at their top speed. Lancers can also transport bots, including builders",
    "corlevlr.dds ".."The Kern Lancer, besides having a weapon with good splash, is able to transport up to two light bots - including builders. Hint: even allied builders can be transported.",
    "armfav.dds ".."Bow Pokers and Kern Lancers are excellent at running over rifle bots (Uzi, Tweeny), but are not heavy enough to crush missile or plasma bots. Keep this in mind if your opponent decides to spam those cheaper units like there's no tomorrow - then make sure he's right. ;)",
	"armrl.dds ".."Missile towers can shoot at both ground and air units, but their anti-air range and damage is much higher than when firing on land units. Nevertheless, they're the best early static response to assault vehicles and tanks.",
    "armsam.dds ".."The Bow Bastion has a special ability, the Fire Rain. It's researched per-unit (requires Tech 2) and lobs multiple fire shells, damaging bots and vehicles in a wide area. Hit 'D' and left-click on target to use it.",
    "corvrad.dds ".."The Kern Sage special ability is the Neutron Strike. It's researched per-unit (requires Tech 2) and requires 400 metal to fire, but it's absolutely devastating against vehicles. Not to mention the psychological effect on the enemy.",
    "corvrad.dds ".."Kern's Sage, besides its amazing line of sight, can also resurrect units. To unlock it, simply research the Global 'resurrect' upgrade in a Tech 2 Tech Center.",
    "armpw.dds ".."The Tweeny (Bow T1 assault bot) may acquire a special ability once you get to Tech 2, the EMP grenade. It's researched per-unit and lobs a mid-range bouncing projectile, quite effective vs bots and defenses. To use it, Hit 'D' and left-click on target.",
    "armpnix.dds ".."Advanced Bombers (Tech 4+) cruise flight is higher than the Tech 1 and Tech 2 AA units and defenses ranges. You can use this to safely fly over most defenses and scout or hit deep within enemy territory.",
	"armmex.dds ".."Sprawlers can be morphed into Adv. Sprawlers at Tech 3, Moho Sprawlers at Tech 4 and Uber Sprawlers at Tech 5, yielding increasingly bigger ore chunks, which provide more resources",
	--"Have trouble finding metal spots?\nPress F4 to switch to the metal map.",
	--"Queue-up multiple consecutive unit actions by holding SHIFT.",
	--"Tweak graphic preferences in options (top right corner of the screen).\nWhen your FPS drops, switch to a lower graphic preset.",
    "corgol.dds ".."Tanks can crush lighter enemy bots, like rifle and missile bots. Tech 4 tanks can crush dragon teeth, and the Tech 5 Hercules can even crush Tech 2 Tanks.",
    "armmine3.dds ".."Pokers, Bow's basic assault vehicle, can build land mines, great vs bots, and bar mines, excellent vs vehicles.",
	"armrad.dds ".."Radars are cheap and their detection range is much larger than their vision range. In the early game, Commanders and Outposts are your best options for true vision range.",
    "corape.dds ".."The Rapier is Kern's gunship. It holds plenty of missile ammo and excels against most vehicles. Like all gunships, it's specially vulnerable to missile trucks.",
    "armbrawl.dds ".."Bow's gunship is the Bully. It fires unlimited laser rounds, making it a great anti-kbot unit. Even with its low-altitude, more vulnerable flight mode, the Bully is faster than the Kern's Rapier.",
    "armgeo.dds ".."Abandoned/Neutral Geothermals might be scattered around the map and provide plenty of energy. You can capture them with commanders or with builders, after you research the 'capture' upgrade in the Tech Center.",
    "cormort.dds ".."Powerful artillery units are available after you upgrade your Tech Center to Level 1. Kern's Mortar is built from the bot lab, Bow Ruger from the Vehicle Plant.",
    "armpship.dds ".."Position your naval units properly during engagements. Missile ships are stronger at their rear area, while other ships are stronger at the front. Submarines are up to two times stronger at the front.",
    "corbw.dds ".."Wasps and Banshees are Kern and Bow's drones respectively. They're available on Tech 1 air plants and in spite of their mobility, don't have a great line of sight and fly low, meaning they can be hit by any ground unit.",
    "cormist.dds ".."Missile Trucks (Bow Bastion & Kern Slayer) are very expensive but a) never miss, b) outrange some defenses and c) are the best early-game mobile ground counters to air units.",
    "corrad.dds ".."To know what enemy units are vulnerable to a certain unit you have, point to your unit and hold SHIFT. Colored circles will show up below units on screen. Green means vulnerable to the pointed unit, Red means resistant to it, and so on.",
    "armmark.dds ".."The highest relatively to the ground a unit is, the further it can see (LOS). The T1 Spotter is one of the best scouts in the game, besides cloaking it's able to climb steep hills and easily acquire a nice vantage point.",
    "corshad.dds ".."You can 'air freeze' your bombers if they're set to 'Fly' mode. Simply issue a move order and hit 'S' (Stop). They'll turn to that position and hover on the spot.",
	--"To see detailed info about each unit in-game switch on \"Extensive unit info\" via Options menu",
	--"In general, vehicles are a good choice for flat and open battlefields. bots are better on hills.",
	--"For wind generators to be worth building, the average wind speed should be over 7. Current, minimum, and maximum wind speeds are shown to the right of the energy bar.",
	--"If your economy is based on wind generators, always build an E storage to have a reserve for when the wind speed drops.",
	--"Commanders have a manual Dgun weapon, which can decimate every unit with one blow.\nPress D to quickly initiate aiming.",
	--"Spread buildings to prevent chain explosions.\nPress ALT+Z and ALT+X to adjust auto-spacing.",
	--"It is effective to move your units in spread formations.\nDrag your mouse while initiating a move order to draw multiple waypoints.",
    "armmart.dds ".."Some tanks and long-ranged vehicles can move in reverse if you press 'Ctrl' while issuing a move order behind it. Use this to keep firing while retreating.",
    "corshad.dds ".."Use the air freeze ability (set to 'fly', move then stop) of bombers to group them close and looking at the enemy's direction. This way they'll all hit the target at the same time, maximizing efficiency.",
	--"T2 factories are expensive. Reclaim your T1 lab for metal to fund it",
	--"Air strikes and airdrops may come at any time, always have at least one anti-air unit in your base.",
	--"With ~(tilde)+doubleclick you can place a label with text on the map.\n~(tilde)+middle mouse button for an empty label.\n~(tilde)+mouse drag to draw lines",
	--"Always check your Com-counter (next to resource bars). If you have the last Commander you better hide it quick!",
	--"Expanding territory is essential for gaining economic advantage.\nTry to secure as many metal spots and geothermal vents as you can.",
	--"Think in advance about reclaiming metal from wrecks piling up at the front.",
	--"Nano towers can be picked up by transporters. This way you can move them where you need more buildpower.",
	--"When your excessing energy... build metal makers to convert the excess to metal.",
	--"Select all units of the same type by pressing CTRL+Z.",
	--"Press CTRL+C to quickly select and center the camera on your Commander.",
	--"Think ahead and include anti-air and support units in your army.",
	--"Mastering hotkeys is the key to proficiency in TAP.\nUse Z,X,C to quickly cycle between most frequently built structures.",
	--"To share resources with teammates:\n - Double-click tank icon next to the player's name to share units\n - Click-drag metal/energy bar next to player's name to send resources.\n - Press H to share an exact amount.",
	--"It is efficient to support your lab with constructors increasing its build-power.\nRight click on the factory with a constructor selected to guard (assist) with construction",
	--"Remember to separate your highly explosive buildings (like metal makers) from the rest of your base.",
	--"Most long-ranged units are very vulnerable in close combat. Always keep a good distance from your targets.",
	--"Keep all your builders busy.\nPress CTRL+B to select and center camera on your idle constructor.",
	--"The best way to prevent air strikes is building fighters and putting them on PATROL in front of your base.",
	--"Use radar hackers to hide your units from enemy radar and hinder artillery strikes.",
	--"Cloaking your Commander drains 100E stationary and 1000E when walking (every second)",
	--"Combine CLOAK with radar jamming to completely hide your units.",
	--"Long-ranged units need scouting for accurate aiming.\nGenerate a constant stream of fast, cheap units for better vision.",
	--"You can assign units to groups by pressing CTRL+[num].\nSelect the group using numbers (1-9).",
	--"When performing a bombing run fly your fighters first to eliminate enemy's fighter-wall.\nUse FIGHT or PATROL command for more effective engagement.",
	--"You can disable enemy's anti-nukes using EMP missiles (built by Bow T2 cons)",
	--"Don't build too much stuff around Moho-geothermal powerplants or everything will go boom!",
	"Missile Towers may morph into Adv. Missile Towers, and both fire at air and ground targets. Their third morph is the anti-air-only Adv. Tower, which sport long range missiles which are limited per tower, yet able to take down most aircrafts with one shot.",
	--"Your commander's Dgun can be used to insta-kill T3 units. Don't forget to cloak it first.\nFor quickly cloaking press K.",
	--"If you are certain of losing some unit in enemy territory, self-destruct it to prevent him from getting the metal. \nPress CTRL+D to initiate the self-destruct countdown.",
	--"Mines are super-cheap and quick to build. Remember to make them away from enemy's line of sight.",
	--"Enemy's mines, radars, and hackers may be disabled using the Juno - built by both factions with T1 constructors.",
    --"Use Alt+0-9 sets the autogroup number (1 .. 9, 0) for selected unit type(s). Newly built units get automatically added to their autogroup number. Alt+Tilde (~) remove units from that autogroup.",
    "Tech 1 (basic or initial) builder units can not assist the production of factories, unlike their advanced (Tech 4) counterparts. Morph them into Adv. builders as soon as you can.",
    "Before you start building a ton of Outposts to speed up constructions, remember each outpost spends +50e per tick. Consider using assisting FARCs and applying the nano booster upgrade on the factory instead.",
	"If you stall (run out of) energy, morphs slow down much more than unit production. Try to maintain your juice flowing to keep your morphs fast.",
	"Tech Center (Global) upgrades in-progress may be cancelled by right-clicking any upgrade button",
    "There are two armor types (regular & armored) per mobile unit category (kbot, vehicle, air, ship). You may easily know what's the armor type by the unit's icon, which displays a kind of stripe at its top.",
    "As a countering general rule of thumb, light units beat support units, which beat heavy units, which beat light units. Light > Support > Heavy > Light if you will.",
}

-- Random unit descriptions we can show
local titleColor = "\255\215\255\215"
local contentColor = "\255\255\255\255"
local unit_descs = {
    "armraz.dds "..titleColor.."Experimental Assault bot: \n"..contentColor.."Beatniks are extremely mobile and the best counters to super units. Bear in mind that its rapid-fire rail weaponry doesn't make it well suited against tanks.",
    "corkarg.dds "..titleColor.."Experimental Assault bot: \n"..contentColor.."Kargeths are relatively cheap and excellent vs tanks especially if you take advantage of their range. They're very good against super units 'en masse', but don't fare well against Beatniks and Flak vehicles",
    "corkrog.dds "..titleColor.."Experimental Very Heavy bot: \n"..contentColor.."Albeit slow, the Kolossus is the largest experimental bot of all, and may win a war by itself - especially if it doesn't try to face too many experimental assault bots, that'd be a huge waste of metal.",
    "corjugg.dds "..titleColor.."Experimental Ultra Heavy bot: \n"..contentColor.."Barely mobile, the Mammoth packs the heaviest weapon of all the experimental bots, able to take out mobs of units, Titans and Kolossus with ease. Watch out for long-ranged, heavy damage weaponry, they totally ruin a Jugg's day.",
    "corjuno.dds "..titleColor.."Pro Tip: \n"..contentColor.."Junos weapon provides generous and non-counterable line of sight at the impact spot. Aim it at hill tops whenever it makes sense, for even wider line of sight. Each missile fired costs metal and energy, try using 'Set Target' if you're low on any of those.",
    "outpost.dds "..titleColor.."Pro Tip: \n"..contentColor.."Morphs in progress won't be interrupted if the Tech Center is destroyed. Start morphing a distant outpost to Tech 4 (if you didn't yet) if you feel you can't save the Tech Center at main.",
    "armtech.dds "..titleColor.."Pro Tip: \n"..contentColor.."Losing your Tech 4+ Tech Center won't throw you back to the stone age if you managed to morph at least one Outpost to Tech 4. (and keep it alive, ofc!)",
    "armack.dds "..titleColor.."Adv. Builder (BOW T4):\n"..contentColor.."Advanced Builders can assist factory production, just like outposts, commanders and FARCs. Building (or morphing) a couple beforehand might save you from total disaster if you lose your T4 Tech Center.",
    "corca.dds "..titleColor.."Construction Plane (KERN T1):\n"..contentColor.."Differently from their ground counterparts, basic Construction Planes can build both missile and laser defenses.",
	"armck.dds "..titleColor.."Builder (BOW T1)\n"..contentColor.."Slightly slower and weaker than the Dozer, this bot builder can climb steeper hills, effective for expansion especially in mountainous terrain.",
	--"armflea.dds "..titleColor.."Flea (BOW T1 bot)\n"..contentColor.."Supercheap and fast, used for scouting and raiding enemy structures in early-game stages. Avoid laser towers and destroy metal extractors to slow down your foe’s expansion!",
	"armham.dds "..titleColor.."Gavel (BOW T1 bot)\n"..contentColor.."Plasma bots are the sturdiest basic bots, extremely resistant to defenses and excellent at taking out commanders. They have a minimum attack range, but their mid-ranged arced projectiles can fly over dragon teeth.",
	--"armjeth.dds "..titleColor.."Jethro (BOW T1 Amphibious bot)\n"..contentColor.."Amphibious mobile anti-air to take down light aircraft. Always send a few with your army to protect it from EMP drones and gunships.",
	"armpw.dds "..titleColor.."Tweeny (BOW T1 bot)\n"..contentColor.."Cheap and fast moving, average-to-low health and built in groups of 3 at a time. With its good LOS, it's effective for scouting and early economy harassment. Excellent vs missile bots.",
	"armrectr.dds "..titleColor.."Vicar (BOW T1 bot)\n"..contentColor.."Fast bot which can rapidly heal units and resurrect destroyed units. Extends the lifetime and adds a snowballing effect to your attack forces",
	"armrock.dds "..titleColor.."Hunter (BOW T1 bot)\n"..contentColor.."Light rocket bot excellent vs tanks and with good damage against defenses. Mixed with plasma bots they form a great combo vs defense towers. Watch out for rifle bots (Uzi/Tweeny)",
	--"armwar.dds "..titleColor.."Trooper (BOW T1 bot)\n"..contentColor.."Durable bot armed with a rapid firing double laser. Has high health and can take down multiple light assault units. Combine with resurrection bots for quick repairing.",
	--"corak.dds "..titleColor.."Uzi (KERN T1 bot)\n"..contentColor.."Light infantry bot which is cheap and quick to build. It is armed with a light, but precise laser which outranges the Tweeny.",
	--"corcrash.dds "..titleColor.."Crasher (KERN T1 Amphibious bot)\n"..contentColor.."Amphibious mobile anti-air (AA) bot that can easily take down light aircraft. Send a few with your army to protect it from EMP drones and gunships.",
	--"corstorm.dds "..titleColor.."Blast (KERN T1 bot)\n"..contentColor.."Light rocket bot used to push the frontline towards opponent's base. Outranges light laser turrets. Slow but stronger than its BOW counterpart.",
	--"cornecro.dds "..titleColor.."Mancer (KERN T1 bot)\n"..contentColor.."Fast, light bot that can ressurect destroyed units. Also can quickly reclaim and repair units. Adds a snowballing effect to your attacks.",
	--"corthud.dds "..titleColor.."Thug ((KERN T1 bot))\n"..contentColor.."Deals significant damage with relatively low cost. Used in big numbers to destroy T1 defences. Works great for defending mountain tops, as elevation increases their range.",
	--"armfav.dds "..titleColor.."Jeffy (BOW T1 Vehicle)\n"..contentColor.."Cheap and the fastest unit in the whole game. Evade laser towers and destroy metal extractors to slow down your foe's expansion.",
	--"armflash.dds "..titleColor.."Flare (BOW T1 Vehicle)\n"..contentColor.."A light, fast tank with close combat rapid fire weapon. Slightly more powerful and faster than Tweenys and Uzis on flat terrain.",
	--"armart.dds "..titleColor.."Shellshocker (BOW T1 Vehicle)\n"..contentColor.."Artillery vehicle used to take down T1 defenses, esp. Heavy Laser Turrets. It can outrange all T1 defense towers. Always keep them protected by Stumpies/Flares.",
	--"armbeaver.dds "..titleColor.."Beaver (BOW T1 Amphibious Vehicle)\n"..contentColor.."Amphibious construction vehicle, can travel on land and underwater allowing easy expansion between islands, under rivers and across seas. Can build the amphibious factory.",
	--"armcv.dds "..titleColor.."Construction Vehicle (BOW T1)\n"..contentColor.."Able to build basic T1 defences and economy. Slightly faster and stronger than bot constructor. Each Construction vehicle increases the player's energy and metal storage capacity by 50.",
	--"armjanus.dds "..titleColor.."Janus (BOW T1 Vehicle)\n"..contentColor.."Heavy dual rocket tank. Slow speed and fire rate makes it vulnerable to fast units. Its large damage, range and AoE make it useful for destroying Commanders. Requires heavy micro and close attention.",
	--"armmlv.dds "..titleColor.."Podger (BOW T1 Vehicle)\n"..contentColor.."Stealthy mine-layer and sweeper. Use the attack command to clear mines in an area. REMEMBER that mines use energy to remain cloaked!",
	--"armpincer.dds "..titleColor.."Pincer (BOW T1 Amphibious Vehicle)\n"..contentColor.."Light amphibious tank which can travel on land and underwater. Weaker than most tanks. Avoid direct fire exchange and try to surprise enemies by destroying undefended targets near the shoreline.",
	--"armsam.dds "..titleColor.."Bastion (BOW T1 Vehicle)\n"..contentColor.."Missile truck that can target land and air units. It has a good range and line-of-sight. Good for supporting or destroying light defences.",
	--"armstump.dds "..titleColor.."Bison (BOW T1 Vehicle)\n"..contentColor.."A general purpose assault tank. Thanks to good armor, it works great as a brute-force skirmish unit.",
	--"corcv.dds "..titleColor.."Construction Vehicle (KERN T1)\n"..contentColor.."Able to build basic T1 structures. It is slightly faster and stronger than the bot constructor, but it can't climb steeper hills.",
	--"corfav.dds "..titleColor.."Weasel (KERN T1 Vehicle)\n"..contentColor.."Cheap and very fast unit used for scouting and early strikes. Evade laser towers and destroy metal extractors to slow down your foe's expansion.",
	--"corgarp.dds "..titleColor.."Garpike (KERN T1 Amphibious Vehicle)\n"..contentColor.."Light amphibious tank which can travel on land and underwater. Weaker than most tanks. Avoid direct fire exchange and try to surprise enemies by destroying undefended targets near the shoreline.",
	--"corgator.dds "..titleColor.."Instigator (KERN T1 Vehicle)\n"..contentColor.."Light, fast moving tank armed with a precise laser weapon. Slower than its BOW counterpart - Flare, but it has a greater range, so always try to keep the distance.",
	--"corlevlr.dds "..titleColor.."Lancer (KERN T1 Vehicle) \n"..contentColor.."Powerful tank armed with an impulse weapon that deals AoE damage and repels light units. It makes it highly effective against swarms of Tweenys, Flares etc.",
	--"cormist.dds "..titleColor.."Slayer (KERN T1 Vehicle)\n"..contentColor.."Long-range light missile truck. Able to outrange most T1 defensive units. They can also serve as basic anti-air defense. Very ineffective in close combat.",
	--"cormlv.dds "..titleColor.."Spoiler (KERN T1 Vehicle)\n"..contentColor.."Stealthy mine-layer and minesweeper. Use the attack command to clear mines in an area. REMEMBER that mines use energy to remain cloaked!",
	--"cormuskrat.dds "..titleColor.."Muskrat (KERN T1 Amphibious Vehicle)\n"..contentColor.."Construction vehicle, which can travel on land and underwater. Builds basic defenses and economy for both land and sea. Useful for expansion in water when you don't have ships.",
	--"corraid.dds "..titleColor.."Cougar (KERN T1 Vehicle)\n"..contentColor.."A general purpose assault tank. Thanks to good armor, it works great as a brute-force skirmish unit.",
	--"corwolv.dds "..titleColor.."Wolverine (KERN T1 Vehicle)\n"..contentColor.."The Wolverine is an artillery vehicle used to take down T1 defenses, especially Heavy Laser Turrets. Helpless in close quarters combat.",
	--"armEnvoy.dds "..titleColor.."Envoy BOW T1 Aircraft\n"..contentColor.."Transportation unit. It can pick up all T1 land based units and smaller T2 units. Cannot load units like the Ogre or Hercules. Can be used for transporting nano turrets too.",
	--"armca.dds "..titleColor.."Construction Aircraft (BOW T1)\n"..contentColor.."Can make basic T1 defences, economy structures and most importantly the T2 Aircraft Plant. Useful for building and reclaiming in remote areas.",
	--"armfig.dds "..titleColor.."Liberty Fighter (BOW T1 Aircraft)\n"..contentColor.."A fighter jet that is designed for eliminating aircraft. Always put your fighters on patrol in front of your base, so they attack any incoming aircraft.",
	--"armkam.dds "..titleColor.."Banshee (BOW T1 Aircraft)\n"..contentColor.."A light gunship that can fire at surface units. It has very weak armor, so always send them in groups and avoid anti-air (AA). It is best as a weapon of surprise.",
	--"armpeep.dds "..titleColor.."Peeker (BOW T1 Aircraft)\n"..contentColor.."A cheap and fast moving air scout. Its weapon is its huge line of sight. It is used to gain intelligence on what your enemy is planning, and where he keeps his most important units.",
	--"armthund.dds "..titleColor.."Rumbler (BOW T1 Aircraft)\n"..contentColor.."A bomber designed mainly for destroying buildings. A little bit weaker than its KERN counterpart (Shadow). It can strike every 9 seconds. Press 'A' for attack and drag your RMB to execute a carpet bombing.",
	--"corca.dds "..titleColor.."Construction Aircraft (KERN T1)\n"..contentColor.."Can make basic T1 defences, economy structures and most importantly the T2 Aircraft Plant. Useful for building and reclaiming in remote areas.",
	--"corshad.dds "..titleColor.."Shadow (KERN T1 Aircraft)\n"..contentColor.."A bomber designed mainly for destroying buildings. A little bit stronger than its BOW counterpart (Rumbler). It can strike every 9 seconds. Press 'A' for attack and drag your RMB to execute carpet bombing.",
	--"corvalk.dds "..titleColor.."Valkyrie (KERN T1 Aircraft)\n"..contentColor.."Airborne transportation unit. It can pick up all T1 land based units and smaller T2 units. Used for unexpected unit drops bypassing enemy's defense line.",
	--"corfink.dds "..titleColor.."Fink (KERN T1 Aircraft)\n"..contentColor.."A cheap and fast moving air scout. Its weapon is a huge line of sight. It is used to gain intelligence on what your enemy is planning, and where he keeps his most important units.",
	--"corbw.dds "..titleColor.."Bladewing (KERN T0 Drone)\n"..contentColor.."Small, fast drones armed with regular and EMP lasers.",
	--"corveng.dds "..titleColor.."Avenger(KERN T1 Aircraft)\n"..contentColor.."A fighter jet that is designed for eliminating aircraft. Always put your fighters on patrol in front of your base, so they attack any incoming aircraft.",
}

local quotes = {
	{"The two most powerful warriors are patience and time.", "Leo Tolstoy"},
	{"Know thy self, know thy enemy. A thousand battles, a thousand victories.", "Sun Tzu"},
	{"People never lie so much as after a hunt, during a war or before an election.", "Otto von Bismarck"},
	{"The best weapon against an enemy is another enemy.", "Friedrich Nietzsche"},
	{"Thus, what is of supreme importance in war is to attack the enemy's strategy.", "Sun Tzu"},
	{"Great is the guilt of an unnecessary war.", "John Adams"},
	{"I have never advocated war except as a means of peace.", "Ulysses S Grant"},
	{"War is not only a matter of equipment, artillery, group troops or air force; it is largely a matter of spirit, or morale.", "Chiang Kai-Shek"},
	{"In nuclear war all men are cremated equal.", "Dexter Gordon"},
	{"There are no absolute rules of conduct, either in peace or war. Everything depends on circumstances.", "Leon Trotsky"},
	{"Weapons are an important factor in war, but not the decisive one; it is man and not materials that counts.", "Mao Zedong"},
	{"To secure peace is to prepare for war.", "Carl von Clausewitz"},
	{"Quickness is the essence of the war.", "Sun Tzu"},
	{"The whole art of war consists of guessing at what is on the other side of the hill.", "Arthur Wellesley"},
	{"War is a game that is played with a smile. If you can't smile, grin. If you can't grin, keep out of the way till you can.", "Winston Churchill"},
	{"War can only be abolished through war, and in order to get rid of the gun it is necessary to take up the gun.", "Mao Zedong"},
	{"The quickest way of ending a war is to lose it.", "George Orwell"},
	{"Heaven cannot brook two suns, nor earth two masters.", "Alexander the Great"},
	{"People always make war when they say they love peace.", "D H Lawrence"},
	{"War is like love; it always finds a way.", "Bertolt Brecht"},
	{"Ten soldiers wisely led will beat a hundred without a head.", "Euripides"},
	{"In war there is no prize for runner-up.", "Lucius Annaeus Seneca"},
	{"I think there should be holy war against yoga classes.", "Werner herzog"},
	{"An army marches on its stomach.", "Napoleon Bonaparte"},
	{"It is fatal to enter any war without the will to win it.", "Douglas MacArthur"},
	{"You cannot simultaneously prevent and prepare for war.", "Albert Einstein"},
	{"Try not to become a man of success, but rather try to become a man of value.", "Albert Einstein"},
	{"Every failure is a step to success.", "William Whewell"},
	{"If everyone is moving forward together, then success takes care of itself.", "Henry Ford"},
	{"Failure is success if we learn from it.", "Malcolm Forbes"},
	{"It is no use saying, 'We are doing our best.' You have got to succeed in doing what is necessary.", "Winston Churchill"},
	{"Knowledge will give you power, but character respect.", "Bruce Lee"},
	{"In time of war the laws are silent.", "Marcus Tullius Cicero"},
	{"War is a contagion.", "Franklin D Roosevelt"},
	{"War is the unfolding of miscalculations.", "Barbara Tuchman"},
	{"Girl power is about loving yourself and having confidence and strength from within, so even if you're not wearing a sexy outfit, you feel sexy.", "Nicole Scherzinger"},
	{"The most common way people give up their power is by thinking they don't have any.", "Alice Walker"},
	{"Mastering others is strength. Mastering yourself is true power.", "Lao Tzu"},
	{"There is more power in unity than division.", "Emmanuel Cleaver"},
	{"I am not afraid of an army of lions led by a sheep; I am afraid of an army of sheep led by a lion.", "Alexander the Great"},
	{"The power of an air force is terrific when there is nothing to oppose it.", "Winston Churchill"},
	{"You must never underestimate the power of the eyebrow.", "Jack Black"},
	{"Common sense is not so common.", "Voltaire"},
	{"If everyone is thinking alike, then somebody isn't thinking.", "George S Patton"},
	{"Ignorance is bold and knowledge reserved.", "Thucydides"},
	{"Don't find fault, find a remedy.", "Henry Ford"},
	{"There is nothing impossible to him who will try.", "Alexander the Great"},
	{"Peace is produced by war", "Pierre Corneille"},
}


-- Since math.random is not random and always the same, we save a counter to a file and use that.
filename = "LuaUI/Config/randomseed.data"
k = os.time() % 1500
if VFS.FileExists(filename) then
	k = tonumber(VFS.LoadFile(filename))
	if not k then k = 0 end
end
k = k + 1
local file = assert(io.open(filename,'w'), "Unable to save latest randomseed from "..filename)
    file:write(k)
    file:close()
file = nil

local random_tip_or_desc = unit_descs[((k/2) % #unit_descs) + 1]
if k%2 == 1 then
	random_tip_or_desc = tips[((math.ceil(k/2)) % #tips) + 1]
--elseif k%3 == 2 then
--	random_tip_or_desc = quotes[((math.ceil(k/3)) % #quotes) + 1]
end

local loadedFontSize = 45 --56 --70
--gl.LoadFont( fontfile , size = 14, outlinewidth = 2, outlineweight = 15)
-- fontName, size, outwidth, outweight
local font = gl.LoadFont(FontPath, loadedFontSize, 16, 1.15) --glyphsize=70,size=22; FreeSansBold.otf, Rex-Bold.otf,WatchtowerMiddle-LM6Z.otf
local fontSizeMult = 0.7 --0.8

function DrawRectRound(px,py,sx,sy,cs)

	--local csx = cs
	--local csy = cs
	--if sx-px < (cs*2) then
	--	csx = (sx-px)/2
	--	if csx < 0 then csx = 0 end
	--end
	--if sy-py < (cs*2) then
	--	csy = (sy-py)/2
	--	if csy < 0 then csy = 0 end
	--end
	--cs = math.min(cs, csy)

	gl.TexCoord(0.8,0.8)
	gl.Vertex(px+cs, py, 0)
	gl.Vertex(sx-cs, py, 0)
	gl.Vertex(sx-cs, sy, 0)
	gl.Vertex(px+cs, sy, 0)

	gl.Vertex(px, py+cs, 0)
	gl.Vertex(px+cs, py+cs, 0)
	gl.Vertex(px+cs, sy-cs, 0)
	gl.Vertex(px, sy-cs, 0)
	
	gl.Vertex(sx, py+cs, 0)
	gl.Vertex(sx-cs, py+cs, 0)
	gl.Vertex(sx-cs, sy-cs, 0)
	gl.Vertex(sx, sy-cs, 0)
	
	local offset = 0.05		-- texture offset, because else gaps could show
	local o = offset
	
	-- top left
	--if py <= 0 or px <= 0 then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(px, py, 0)
	gl.TexCoord(o,1-o)
	gl.Vertex(px+cs, py, 0)
	gl.TexCoord(1-o,1-o)
	gl.Vertex(px+cs, py+cs, 0)
	gl.TexCoord(1-o,o)
	gl.Vertex(px, py+cs, 0)
	-- top right
	--if py <= 0 or sx >= vsx then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(sx, py, 0)
	gl.TexCoord(o,1-o)
	gl.Vertex(sx-cs, py, 0)
	gl.TexCoord(1-o,1-o)
	gl.Vertex(sx-cs, py+cs, 0)
	gl.TexCoord(1-o,o)
	gl.Vertex(sx, py+cs, 0)
	-- bottom left
	--if sy >= vsy or px <= 0 then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(px, sy, 0)
	gl.TexCoord(o,1-o)
	gl.Vertex(px+cs, sy, 0)
	gl.TexCoord(1-o,1-o)
	gl.Vertex(px+cs, sy-cs, 0)
	gl.TexCoord(1-o,o)
	gl.Vertex(px, sy-cs, 0)
	-- bottom right
	--if sy >= vsy or sx >= vsx then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(sx, sy, 0)
	gl.TexCoord(o,1-o)
	gl.Vertex(sx-cs, sy, 0)
	gl.TexCoord(1-o,1-o)
	gl.Vertex(sx-cs, sy-cs, 0)
	gl.TexCoord(1-o,o)
	gl.Vertex(sx, sy-cs, 0)
end

function RectRound(px,py,sx,sy,cs)
	--local px,py,sx,sy,cs = math.floor(px),math.floor(py),math.ceil(sx),math.ceil(sy),math.floor(cs)
	
	gl.Texture(":n:luaui/Images/bgcorner.png")
	--gl.Texture(":n:luaui/Images/bgcorner.png")
	gl.BeginEnd(GL.QUADS, DrawRectRound, px,py,sx,sy,cs)
	gl.Texture(false)
end

function gradienth(px,py,sx,sy, c1,c2)
	gl.Color(c1)
	gl.Vertex(sx, sy, 0)
	gl.Vertex(sx, py, 0)
	gl.Color(c2)
	gl.Vertex(px, py, 0)
	gl.Vertex(px, sy, 0)
end


local lastLoadMessage = ""
local lastProgress = {0, 0}

local progressByLastLine = {
	["Parsing Map Information"] = {0, 20},
	["Loading Weapon Definitions"] = {10, 50},
	["Loading LuaRules"] = {40, 80},
	["Loading LuaUI"] = {70, 95},
	["Finalizing"] = {100, 100}
}
for name,val in pairs(progressByLastLine) do
	progressByLastLine[name] = {val[1]*0.01, val[2]*0.01}
end

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
	if message:find("Path") then -- pathing has no rigid messages so cant use the table
		lastProgress = {0.8, 1.0}
	end
	lastProgress = progressByLastLine[message] or lastProgress
end

function addon.DrawLoadScreen()
	local loadProgress = SG.GetLoadProgress()
	if loadProgress == 0 then
		loadProgress = lastProgress[1]
	else
		loadProgress = math.min(math.max(loadProgress, lastProgress[1]), lastProgress[2])
	end

	local vsx, vsy = gl.GetViewSizes()

	-- draw progressbar
	local hbw = 3.5/vsx
	local vbw = 3.5/vsy
	local hsw = 0.2
	local vsw = 0.2
	local yPos =  0.125 --0.054
	local yPosTips = yPos + 0.1245
	local loadvalue = 0.2 + (math.max(0, loadProgress) * 0.6)

	if not showTips then
		yPos = 0.165
		yPosTips = yPos
	end

	--bar bg
	local paddingH = 0.004
	local paddingW = paddingH * (vsy/vsx)
	gl.Color(0.085,0.085,0.085,0.925)
	RectRound(0.2-paddingW,yPos-0.05-paddingH,0.8+paddingW,yPosTips+paddingH,0.007)

	gl.Color(0,0,0,0.75)
	RectRound(0.2-paddingW,yPos-0.05-paddingH,0.8+paddingW,yPos+paddingH,0.007)

    if loadvalue > 0.215 then
	    -- loadvalue
        gl.Color(0.4-(loadProgress/7),loadProgress*0.4,0,0.4)
        RectRound(0.2,yPos-0.05,loadvalue,yPos,0.0055)

        -- loadvalue gradient
        gl.Texture(false)
        gl.BeginEnd(GL.QUADS, gradienth, 0.2,yPos-0.05,loadvalue,yPos, {1-(loadProgress/3)+0.2,loadProgress+0.2,0+0.08,0.14}, {0,0,0,0.14})

        -- loadvalue inner glow
        gl.Color(1-(loadProgress/3.5)+0.15,loadProgress+0.15,0+0.05,0.04)
        gl.Texture(":n:luaui/Images/barglow-center.png")
        gl.TexRect(0.2,yPos-0.05,loadvalue,yPos)

        -- loadvalue glow
        local glowSize = 0.06
        gl.Color(1-(loadProgress/3)+0.15,loadProgress+0.15,0+0.05,0.1)
        gl.Texture(":n:luaui/Images/barglow-center.png")
        gl.TexRect(0.2,	yPos-0.05-glowSize,	loadvalue,	yPos+glowSize)

        gl.Texture(":n:luaui/Images/barglow-edge.png")
        gl.TexRect(0.2-(glowSize*1.3), yPos-0.05-glowSize, 0.2, yPos+glowSize)
        gl.TexRect(loadvalue+(glowSize*1.3), yPos-0.05-glowSize, loadvalue, yPos+glowSize)
    end

	-- progressbar text
	gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)
		local barTextSize = vsy * 0.026

		--font:Print(lastLoadMessage, vsx * 0.5, vsy * 0.3, 50, "sc")
		--font:Print(Game.gameName, vsx * 0.5, vsy * 0.95, vsy * 0.07, "sca")
		font:Print(lastLoadMessage, vsx * 0.21, vsy * (yPos-0.017), barTextSize * 0.67, "oa")
		if loadProgress>0 then
			font:Print(("%.0f%%"):format(loadProgress * 100), vsx * 0.5, vsy * (yPos-0.0325), barTextSize, "oc")
		else
			font:Print("Loading...", vsx * 0.5, vsy * (yPos-0.031), barTextSize, "oc")
		end
	gl.PopMatrix()


	if showTips then
		-- In this format, there can be an optional image before the tip/description.
		-- Any image ends in .dds, so if such a text piece is found, we extract that and show it as an image.
		local text_to_show = random_tip_or_desc
		yPos = yPosTips
		if random_tip_or_desc[2] then
			text_to_show = random_tip_or_desc[1]
		else
			i, j = string.find(random_tip_or_desc, ".dds")
		end
		local numLines = 1
		local image_text = nil
		local fontSize = barTextSize * fontSizeMult --0.77
		local image_size = 0.0485
		local height = 0.123

		if i ~= nil then
			text_to_show = string.sub(text_to_show, j+2)
			local maxWidth = ((0.58-image_size-0.012) * vsx) * (loadedFontSize/fontSize)
			text_to_show, numLines = font:WrapText(text_to_show, maxWidth)
		else
			local maxWidth = (0.585 * vsx) * (loadedFontSize/fontSize)
			text_to_show, numLines = font:WrapText(text_to_show, maxWidth)
		end

		-- Tip/unit description
		-- Background
		--gl.Color(1,1,1,0.033)
		--RectRound(0.2,yPos-height,0.8,yPos,0.005)

		-- Text
		gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)

		if i ~= nil then
			image_text = string.sub(random_tip_or_desc, 0, j)
			gl.Texture(":n:unitpics/" .. image_text)
			gl.Color(1.0,1.0,1.0,0.8)
			gl.TexRect(vsx * 0.21, vsy*(yPos-0.015), vsx*(0.21+image_size), (vsy*(yPos-0.015))-(vsx*image_size),false,true)
			font:Print(text_to_show, vsx * (0.21+image_size+0.012) , vsy * (yPos-0.0175), fontSize, "oa")
		else
			font:Print(text_to_show, vsx * 0.21, vsy * (yPos-0.0175), fontSize, "oa")
		end

		if random_tip_or_desc[2] then
			--font:Print(name, posX, posY, fontSize, "con")
			font:Print('\255\255\222\155'..random_tip_or_desc[2], vsx * 0.79, (vsy * ((yPos-0.0175)-height)) +(fontSize*2.66) , fontSize, "oar")
		end
		gl.PopMatrix()
	end
end


function addon.MousePress(...)
	--Spring.Echo(...)
end


function addon.Shutdown()
	gl.DeleteFont(font)
end
