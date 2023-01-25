main()
{
    level.callbackStartGameType = ::Callback_StartGameType;
    level.callbackPlayerConnect = ::Callback_PlayerConnect;
    level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
    level.callbackPlayerDamage = ::Callback_PlayerDamage;
    level.callbackPlayerKilled = ::Callback_PlayerKilled;

    maps\mp\gametypes\_callbacksetup::SetupCallbacks();

    allowed[0] = "dm";
    maps\mp\gametypes\_gameobjects::main(allowed);

    level.timelimit = 30; // 30 minutes
    level.mapname = getCvar("mapname");
    level.gametype = tolower(getCvar("g_gametype"));

    /* Here we setup the maps and start loop with fixes
        - level.timelimit overrides
        - extra spawnpoints
        - map difficulty
        - heal spots
        - grenade spots
        - panzer spots*/
    mapsetup();

    // level.grenademap = false;
    // grenademaps = "nm_portal;svt_xmas_v2;nev_jumpfacility;jm_hollywood;jm_canonjump;mazeofdeath_vhard";
    // if(getCvar("scr_grenademaps") != "") {
    // 	grenademaps = getCvar("scr_grenademaps"); // Get the cvar with maps and time
    // 	for(i = 2;; i++) {
    // 		if(getCvar("scr_grenademaps" + i) != "")
    // 			grenademaps += getCvar("scr_grenademaps" + i);
    // 		else
    // 			break;
    // 	}
    // }

    // grenademap = jumpmod\functions::strTok(grenademaps, ";");
    // for(i = 0; i < grenademap.size; i++) {
    // 	if(grenademap[i] == level.mapname) {
    // 		level.grenademap = true;
    // 		break;
    // 	}
    // }

    setCvar("scr_allow_vote", "0");

    if(!isDefined(game["state"]))
        game["state"] = "playing";

    level.QuickMessageToAll = true; // special
    //level.quickcommandlimit = 10;
    level.mapended = false;
    level.healthqueue = [];
    level.healthqueuecurrent = 0;
    level.bans = [];

    spawnpointname = "mp_deathmatch_spawn";
    spawnpoints = getEntArray(spawnpointname, "classname");

    if(spawnpoints.size > 0) {
        for(i = 0; i < spawnpoints.size; i++)
            spawnpoints[i] placeSpawnpoint();
    } else
        maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

    setarchive(true); // special (for killcam)

    //thread ladderjumps(); // Cheese
}

Callback_StartGameType()
{
    if(!isDefined(game["allies"]))
        game["allies"] = "american";
    if(!isDefined(game["axis"]))
        game["axis"] = "german";

    if(!isDefined(game["layoutimage"]))
        game["layoutimage"] = "default";
    layoutname = "levelshots/layouts/hud@layout_" + game["layoutimage"];
    precacheShader(layoutname);
    setCvar("scr_layoutimage", layoutname);
    makeCvarServerInfo("scr_layoutimage", "");

    game["menu_team"] = "team_" + game["allies"] + game["axis"];
    game["menu_weapon_allies"] = "weapon_" + game["allies"];
    game["menu_weapon_axis"] = "weapon_" + game["axis"];
    game["menu_viewmap"] = "viewmap";
    game["menu_callvote"] = "callvote";
    game["menu_quickcommands"] = "quickcommands";
    game["menu_quickstatements"] = "quickstatements";
    game["menu_quickresponses"] = "quickresponses";

    precacheMenu(game["menu_team"]);
    precacheMenu(game["menu_weapon_allies"]);
    precacheMenu(game["menu_weapon_axis"]);
    precacheMenu(game["menu_viewmap"]);
    precacheMenu(game["menu_callvote"]);
    precacheMenu(game["menu_quickcommands"]);
    precacheMenu(game["menu_quickstatements"]);
    precacheMenu(game["menu_quickresponses"]);

    precacheShader("black");
    precacheShader("hudScoreboard_mp");
    precacheShader("gfx/hud/hud@mpflag_none.tga");
    precacheShader("gfx/hud/hud@mpflag_spectator.tga");
    precacheStatusIcon("gfx/hud/hud@status_dead.tga");
    precacheStatusIcon("gfx/hud/hud@status_connecting.tga");
    precacheItem("item_health");

    precacheItem("fraggrenade_mp");
    precacheItem("m1carbine_mp");
    precacheItem("m1garand_mp");
    precacheItem("thompson_mp");
    precacheItem("bar_mp");
    precacheItem("springfield_mp");
    precacheItem("mk1britishfrag_mp");
    precacheItem("colt_mp");
    precacheItem("enfield_mp");
    precacheItem("sten_mp");
    precacheItem("bren_mp");
    precacheItem("rgd-33russianfrag_mp");
    precacheItem("luger_mp");
    precacheItem("mosin_nagant_mp");
    precacheItem("ppsh_mp");
    precacheItem("mosin_nagant_sniper_mp");
    precacheItem("stielhandgranate_mp");
    precacheItem("kar98k_mp");
    precacheItem("mp40_mp");
    precacheItem("mp44_mp");
    precacheItem("kar98k_sniper_mp");
    precacheItem("fg42_mp");
    precacheItem("panzerfaust_mp");

    maps\mp\gametypes\_teams::modeltype();
    maps\mp\gametypes\_teams::precache();
    maps\mp\gametypes\_teams::initGlobalCvars();
    maps\mp\gametypes\_teams::restrictPlacedWeapons();
    maps\mp\gametypes\_teams::scoreboard();

    setClientNameMode("auto_change");

    game["statusicon_american"]   = "gfx/hud/headicon@allies.tga";
    game["statusicon_british"]    = "gfx/hud/headicon@allies.tga";
    game["statusicon_german"]     = "gfx/hud/headicon@axis.tga";
    game["statusicon_russian"]    = "gfx/hud/headicon@allies.tga";

    precacheStatusIcon(game["statusicon_" + game["allies"]]);
    precacheStatusIcon(game["statusicon_" + game["axis"]]);
    precacheStatusIcon("gfx/hud/hud@objective_bel.tga");
    precacheStatusIcon("gfx/hud/headicon@re_objcarrier.tga");

    precacheHeadIcon("gfx/hud/headicon@quickmessage");
    precacheHeadIcon("gfx/hud/headicon@re_objcarrier.tga");
    precacheHeadIcon("gfx/hud/hud@health_cross.tga");

    jumpmod\mapvote::init();
    jumpmod\commands::precache();
    jumpmod\commands::init();
    thread jumpmod();
}

Callback_PlayerConnect()
{
    checkbannedip = self getip();
    banindex = jumpmod\commands::isbanned(checkbannedip);
    if(banindex != -1) {
        self.isbanned = true; // flag for PlayerDisconnect
        bannedreason = level.bans[banindex]["bannedreason"]; // to avoid race condition
        self sendservercommand("w \"Player Banned: ^1" + bannedreason + "\"");
        self waittill("begin");
        wait 0.05; // server/script crashes without it
        kickmsg = "Player Banned: ^1" + bannedreason;
        self dropclient(kickmsg);
        return;
    }

    self.statusicon = "gfx/hud/hud@status_connecting.tga";
    self waittill("begin");
    self.statusicon = "";

    iPrintLn(jumpmod\functions::namefix(self.name) + " ^7Connected");
    self.blocking = false;
    self.save_array = []; // Declare jumpsave array
    self.save_array_max_length = 22;
    self.load_index = 0;

    self.pers["mm_chattimer"] = getTime();
    self.pers["mm_chatmessages"] = 1;

    thread jumpmod\commands::_checkLoggedIn();

    if(game["state"] == "intermission") {
        spawnIntermission();
        return;
    }

    level endon("intermission");

    self.pers["team"] = "spectator";
    spawnSpectator();

    self setClientCvar("g_scriptMainMenu", game["menu_team"]);
    self setClientCvar("scr_showweapontab", "0");
    self openMenu(game["menu_team"]);

    self setClientCvar("cg_objectiveText", "Complete the jump map from start to end before the time runs out.\nDouble tap ^1MELEE ^7key to save position.\nDouble tap ^1USE ^7key to load saved positions.");

    teams[0] = "allies";
    teams[1] = "axis";

    if(isDefined(level.acceptvotes))
        if(isDefined(level.votetitle))
            jumpmod\commands::message_player(level.votetitle);

    //self.quickcommandlimit = 0;
    for(;;) {
        self waittill("menuresponse", menu, response);

        if(response == "open" || response == "close")
            continue;

        if(response == "spectator" && self.pers["team"] != "spectator") {
            self.pers["team"] = "spectator";
            self.pers["weapon"] = undefined;
            self.pers["savedmodel"] = undefined;

            self.sessionteam = "spectator";
            self setClientCvar("g_scriptMainMenu", game["menu_team"]);
            self setClientCvar("scr_showweapontab", "0");

            spawnSpectator();
        }

        switch(response) {
            case "axis":
            case "allies":
            case "autoassign":
                if(response == "autoassign")
                    self.pers["team"] = teams[randomInt(2)]; // for model() in spawnPlayer()
                else
                    self.pers["team"] = response;

                spawnPlayer();
            break;

            case "team":
                self openMenu(game["menu_team"]);
            break;

            case "viewmap":
                self openMenu(game["menu_viewmap"]);
            break;
        }

        switch(menu) {
            case "quickcommands":
                maps\mp\gametypes\_teams::quickcommands(response);
            break;

            case "quickstatements":
                maps\mp\gametypes\_teams::quickstatements(response);
            break;

            case "quickresponses":
                maps\mp\gametypes\_teams::quickresponses(response);
            break;
        }

        // if(self.quickcommandlimit < level.quickcommandlimit) {
        // 	switch(menu) {
        // 		case "quickcommands":
        // 		case "quickstatements":
        // 		case "quickresponses":
        // 			self.quickcommandlimit++;
        // 			if(self.quickcommandlimit > level.quickcommandlimit - 3) {
        // 				quicklimit = level.quickcommandlimit - self.quickcommandlimit;
        // 				unit = "command";
        // 				if(quicklimit != 1)
        // 					unit += "s";
        // 				self iPrintLn("^3WARNING: ^7You have " + quicklimit + " quick " + unit +" remaining.");
        // 			}
        // 		break;
        // 	}

        // 	switch(menu) {
        // 		case "quickcommands":
        // 			maps\mp\gametypes\_teams::quickcommands(response);
        // 		break;

        // 		case "quickstatements":
        // 			maps\mp\gametypes\_teams::quickstatements(response);
        // 		break;

        // 		case "quickresponses":
        // 			maps\mp\gametypes\_teams::quickresponses(response);
        // 		break;
        // 	}
        // } else
        // 	self iPrintLn("^3WARNING: ^7You exceeded your quick command limit for this map.");
    }
}

Callback_PlayerDisconnect()
{
    thread jumpmod\commands::_delete();
    thread jumpmod\miscmod::welcome_remove();
    if(isDefined(self.isbanned))
        iPrintLn(jumpmod\functions::namefix(self.name) + " ^7Banned");
    else
        iPrintLn(jumpmod\functions::namefix(self.name) + " ^7Disconnected");
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
    if(self.sessionteam == "spectator")
        return;

    if(level.bounceon && sMeansOfDeath == "MOD_FALLING")
        return;

    if(!isDefined(vDir))
        iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

    if(!self.blocking && isPlayer(eAttacker) && eAttacker != self)
        return;

    if(iDamage < 1)
        iDamage = 1;

    self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
    level endon("end_map");
    self endon("spawned");

    if(self.sessionteam == "spectator")
        return;

    if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
        sMeansOfDeath = "MOD_HEAD_SHOT";

    obituary(self, attacker, sWeapon, sMeansOfDeath);

    self.sessionstate = "dead";
    self.statusicon = "gfx/hud/hud@status_dead.tga";
    self.deaths++;

    wait 2;

    self thread spawnPlayer();
}

jmpAntiblock()
{
    self endon("spawned");

    blocktime = 0;
    while(self.sessionstate == "playing") {
        oldpos = self.origin;
        wait 1;

        if(distance(oldpos, self.origin) < 20) {
            blocktime++;

            if(blocktime == 45) {
                self.blocking = true;
                self iPrintLn("^1WARNING: ^3You appear to be blocking!");
            }
        } else {
            blocktime = 0;
            self.blocking = false;
        }
    }
}

jmpMeleeKey()
{
    self endon("spawned");

    for(;;) {
        if(self meleeButtonPressed()) {
            catch_next = false;

            for(i = 0; i <= 0.30; i += 0.01) {
                if(catch_next && self meleeButtonPressed()) {
                    while(!(self isOnGround())) {
                        if(self jumpmod\functions::isOnLadder())
                            break;

                        wait 0.05;
                    }

                    if(self isOnGround() || self jumpmod\functions::isOnLadder()) {
                        self thread jmpSavePosition();
                        wait 0.25;
                        break;
                    }
                }
                else if(!self meleeButtonPressed())
                    catch_next = true;

                wait 0.01;
            }
        }

        wait 0.05;
    }
}

jmpSavePosition()
{
    currentslot = jumpmod\functions::getWeaponSlot(self getCurrentWeapon());
    if(!(currentslot == "pistol" || currentslot == "grenade"))
        return;

    self.tmp_arr = []; // Temporary array
    self.score++; // Count saves on scoreboard

    for(i = 0; i < self.save_array.size; i++) { // Iterate through the array and insert the element in the original array one position forward
        if(i == (self.save_array_max_length - 1)) // If the current element is the last in the list, do not process it
            break;

        self.tmp_arr[i + 1]["angles"] = self.save_array[i]["angles"];
        self.tmp_arr[i + 1]["origin"] = self.save_array[i]["origin"];
    }

    self.save_array = self.tmp_arr; // Set the save_array to be equal to the temp array

    self.save_array[0]["origin"] = self.origin; // Insert the new save in the first position (now cleared)
    self.save_array[0]["angles"] = self.angles;

    self iPrintLn("^1Your current position is ^2saved^1.");
    self iPrintLn("^1(^7X: ^2" + (int)self.origin[0] + "^7 Y: ^2" + (int)self.origin[1] + "^7 Z: ^2" + (int)self.origin[2] + "^1)");
}

jmpUseKey()
{
    self endon("spawned");

    for(;;) {
        if(self useButtonPressed()) {
            catch_next = false;

            for(i = 0; i <= 0.30; i += 0.01) {
                if(catch_next && self useButtonPressed()) {
                    self thread jmpLoadPosition();
                    wait 0.25;
                    break;
                }
                else if(!self useButtonPressed())
                    catch_next = true;

                wait 0.01;
            }
        }

        wait 0.05;
    }
}

jmpLoadPosition()
{
    if(self.save_array.size == 0) {
        self iPrintLn("^1You don't have any saved positions.");
        return;
    } else {
        if(self.load_index == (self.save_array_max_length - 1) || self.load_index >= self.save_array.size) // Make sure the player doesn't try to load a position outside of the save_array size
            self.load_index = 0;

        if(!isDefined(self.load_old_pos)) { // Check if load hasn't been used yet
            self.load_index = 0;
        } else {
            if(distance(self.load_old_pos, self.origin) > 20) // If the player has moved more than 20 units, reset the load index back to 0
                self.load_index = 0;
        }

        if(positionWouldTelefrag(self.save_array[self.load_index]["origin"])) {
            if(distance(self.origin, self.save_array[self.load_index]["origin"]) < 33) {
                // Tillat fordi distansen mellom deg og save-posisjonen er mindre enn 33, og da
                // betyr dette med all sannsynlighet at det er deg selv som blokkerer posisjonen
                // Spilleren er 32 units bred, 72 units høy, 33 units passer da bra som distanse
            } else {
                self iPrintLn("^1A player is already on this position.");
                return;
            }
        }

        self setPlayerAngles(self.save_array[self.load_index]["angles"]); // Update the player position
        self setOrigin(self.save_array[self.load_index]["origin"]);

        self.load_old_pos = self.origin; // Update the old position

        if(self.load_index == 0)
            self iPrintLn("^1Your saved position is ^2loaded^1.");
        else
            self iPrintLn("^1Your backup position #" + self.load_index + " is ^2loaded^1.");

        self.load_index++; // Update the load_index
    }
}

jmpWeapons()
{
    // if(level.grenademap)
    // 	self thread jmpReplenishGrenade();

    self setWeaponSlotWeapon("primary", "none"); // Make sure no primary weapon is set
    self setWeaponSlotWeapon("primaryb", "mosin_nagant_mp"); // Make sure secondary weapon is mosin_nagant to kill blockers from a distance
    self setWeaponSlotAmmo("primaryb", 20);
    self setWeaponSlotClipAmmo("primaryb", 0);

    if(self.pers["team"] == "allies")
        self.pers["weapon"] = "colt_mp";
    else
        self.pers["weapon"] = "luger_mp";

    self giveWeapon(self.pers["weapon"]);

    weaponslot = jumpmod\functions::getWeaponSlot(self.pers["weapon"]);
    self setWeaponSlotClipAmmo(weaponslot, 0);
    self setWeaponSlotAmmo(weaponslot, 1);

    self setSpawnWeapon(self.pers["weapon"]);
    self switchToWeapon(self.pers["weapon"]);
}

// jmpReplenishGrenade()
// {
// 	self endon("spawned");

// 	self giveWeapon(jmpGrenade());
// 	while(self.sessionstate == "playing") {
// 		while(self getWeaponSlotClipAmmo("grenade") > 0 && self.sessionstate == "playing")
// 			wait 0.5;

// 		wait 2.5;

// 		self setWeaponSlotAmmo("grenade", 3);
// 	}
// }

jmpGrenade()
{
    if(self.pers["team"] == "allies") {
        switch(game["allies"]) {
            case "american":
                weapon = "fraggrenade_mp";
            break;

            case "british":
                weapon = "mk1britishfrag_mp";
            break;

            case "russian":
                weapon = "rgd-33russianfrag_mp";
            break;
        }
    } else if(self.pers["team"] == "axis") {
        switch(game["axis"]) {
            case "german":
                weapon = "stielhandgranate_mp";
            break;
        }
    }

    return weapon;
}

jumpmod()
{
    level notify("jumpmod");
    level.starttime = getTime();

    if(level.timelimit > 0) {
        level.clock = newHudElem();
        level.clock.x = 320;
        level.clock.y = 460;
        level.clock.alignX = "center";
        level.clock.alignY = "middle";
        level.clock.font = "bigfixed";
        level.clock setTimer(level.timelimit * 60);
    }

    thread endMap();
    thread jumpmod\miscmod::_timerStuck();
    thread jumpmod\functions::addBotClients();

    level.bounceon = (bool)(getCvar("x_cl_bounce") == "1");
    if(level.bounceon)
        setCvar("g_speed", 210);
    else
        setCvar("g_speed", 190);

    for(;;) {
        checkTimeLimit();
        wait 1;
    }
}

checkTimeLimit()
{
    if(level.timelimit <= 0)
        return;
    timepassed = (getTime() - level.starttime) / 1000;
    timepassed = timepassed / 60.0;

    if(timepassed < level.timelimit)
        return;

    if(level.mapended)
        return;
    level.mapended = true;

    iPrintLn(&"MPSCRIPT_TIME_LIMIT_REACHED");
    level notify("end_map");
}

endMap()
{
    level waittill("end_map");
    game["state"] = "intermission";
    level notify("intermission");

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++) {
        player = players[i];

        player closeMenu();
        player setClientCvar("g_scriptMainMenu", "main");
        player spawnIntermission();
    }

    wait 10;

    jumpmod\mapvote::mapvote();

    exitLevel(false);
}

spawnPlayer()
{
    self notify("spawned");

    resettimeout();

    self.sessionteam = "allies";
    self.sessionstate = "playing";
    self.spectatorclient = -1;
    self.archivetime = 0;

    spawnpointname = "mp_deathmatch_spawn";
    jumpmod\functions::_spawn(spawnpointname);

    if(isDefined(self.pers["team"]))
        self.statusicon = game["statusicon_" + game[self.pers["team"]]];
    else
        self.statusicon = "gfx/hud/hud@objective_bel.tga";

    self.maxhealth = 100;
    self.health = self.maxhealth;

    if(!isDefined(self.pers["savedmodel"]))
        maps\mp\gametypes\_teams::model();
    else
        maps\mp\_utility::loadModel(self.pers["savedmodel"]);

    self thread jmpMeleeKey();
    self thread jmpUseKey();
    self thread jmpAntiblock();
    self thread jmpWeapons();

    if(!isDefined(self.firstspawn)) {
        self.firstspawn = true;
        self setClientCvar("r_swapInterval", 0); // Sync Every Frame = "No"
        thread jumpmod\miscmod::welcome_display();
    }
}

spawnSpectator(origin, angles)
{
    self notify("spawned");

    resettimeout();

    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.archivetime = 0;

    if(self.pers["team"] == "spectator")
        self.statusicon = "gfx/hud/hud@objective_bel.tga";

    spawnpointname = "mp_deathmatch_intermission";
    spawnpoints = getEntArray(spawnpointname, "classname");
    spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

    if(isDefined(spawnpoint))
        self spawn(spawnpoint.origin, spawnpoint.angles);
    else
        maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

spawnIntermission()
{
    self notify("spawned");

    resettimeout();

    self.sessionstate = "intermission";
    self.spectatorclient = -1;
    self.archivetime = 0;

    spawnpointname = "mp_deathmatch_intermission";
    spawnpoints = getEntArray(spawnpointname, "classname");
    spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

    if(isDefined(spawnpoint))
        self spawn(spawnpoint.origin, spawnpoint.angles);
    else
        maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

mapsetup()
{
    mapname = tolower(level.mapname);
    switch(mapname) { // per map settings - case sensitive
        case "v_sequence":
        break;

        case "v_xmasrace":
        break;

        case "gg_neon_v2":
        break;

        case "v_forgottentomb":
        break;

        case "jm_gayfected":
        break;

        case "bigstrafe":
        break;

        case "zh_mario_thwomp":
        break;

        case "zozo_8thjump":
        break;

        case "zozo_6thjump":
        break;

        case "zozo_2ndjump":
        break;

        case "zh_unknown":
        break;

        case "zh_mirage":
        break;

        case "gg_shortbounce":
        break;

        case "gg_neon":
        break;

        case "zh_farbe":
        break;

        case "[sob]easyjump":
            level.timelimit = 5;
        break;

        case "bc_bocli":
            level.timelimit = 6;
        break;

        case "bitch":
            level.timelimit = 20;
        break;

        case "ch_quickie":
            level.timelimit = 20;
        break;

        case "ch_secret": // grenades?
            level.timelimit = 15;
        break;

        case "ch_space":
            level.timelimit = 20;
        break;

        case "cj_cow":
            level.timelimit = 6;
        break;

        case "cj_change":
            level.timelimit = 7;

            ladderjumps[0]["from"] = (-2356, 301, -108);
            ladderjumps[0]["to"] = (-2770, 325, -63);
            ladderjumps[0]["angles"] = (0, -90, 0);

            ladderjumps[1]["from"] = (-2356, -104, -108);
            ladderjumps[1]["to"] = (-2770, 325, -63);
            ladderjumps[1]["angles"] = (0, -90, 0);

            ladderjumps[2]["from"] = (-2356, 98, -108);
            ladderjumps[2]["to"] = (-2770, 325, -63);
            ladderjumps[2]["angles"] = (0, -90, 0);
        break;

        case "cj_hornet":
            level.timelimit = 6;
        break;

        case "cj_hallwayofdoom":
            level.timelimit = 7;
        break;

        case "cj_wolfjump":
            level.timelimit = 12;
        break;

        case "cls_industries":
            level.timelimit = 20;

            healspots[0] = (2464, 433, -967);
            healspots[1] = (592, 626, -1383);
            healspots[2] = (345, 460, -1218);

            grenadespots[0] = (2595, 402, -1014);
            grenadespots[1] = (694, 625, -1463);
        break;

        case "cp_easy_jump":
            level.timelimit = 10;
        break;

        case "cp_sirens_call":
        break;

        case "ct_aztec":
            level.timelimit = 7;
        break;

        case "cs_smoke":
            level.timelimit = 6;
        break;

        case "dan_jumpv3":
            level.timelimit = 12;
        break;

        case "ddd_easy_jump":
            level.timelimit = 7;
        break;

        case "double_vision":
            level.timelimit = 8;

            healspots[0] = (137, -1245, 215);

            grenadespots[0] = (102, -991, -18);
        break;

        case "duo_cool2":
            level.timelimit = 18;
        break;

        case "fm_squishydeath_easy":
        case "fm_squishydeath_hard":
            level.timelimit = 20;

            ladderjumps[0]["from"] = (-2110, 2480, -1534);
            ladderjumps[0]["to"] = (-2050, 1905, -1727);
            ladderjumps[0]["angles"] = (0, -90, 0);
            ladderjumps[0]["dist"] = 36;
        break;

        case "funjump":
            level.timelimit = 20;

            ladderjumps[0]["from"] = (146, 3415, -2644); // Cheese
            ladderjumps[0]["to"] = (146, 3040, -2644);
            ladderjumps[0]["angles"] = (0, -90, 0);
            ladderjumps[0]["dist"] = 24;

            ladderjumps[1]["from"] = (39, 2882, -2644); // Cheese
            ladderjumps[1]["to"] = (46, 3248, -2644);
            ladderjumps[1]["angles"] = (0, 90, 0);
            ladderjumps[1]["dist"] = 96;

            ladderjumps[2]["from"] = (978, 5782, -140); // Cheese
            ladderjumps[2]["to"] = (968, 5781, 255);
            ladderjumps[2]["angles"] = (0, 180, 0);
            ladderjumps[2]["dist"] = 36;

            // skipPoint[ skipPoint.size ] = ( 150, 3415, -2644 );
            // skipPoint[ skipPoint.size ] = ( 53, 3335, -2737 );
            // skipPoint[ skipPoint.size ] = ( 0, 90, 0 );
        break;

        case "groms_skatepark":
            level.timelimit = 12;

            ladderjumps[0]["from"] = (1366, 82, 448);
            ladderjumps[0]["to"] = (1206, -68, 664);
            ladderjumps[0]["angles"] = (0, -90, 0);
        break;

        case "harbor_jump": // grenades?
            level.timelimit = 12;
        break;

        case "hardjump":
            level.timelimit = 20;

            ladderjumps[0]["from"] = (-1903, -3787, -195 ); // Cheese
            ladderjumps[0]["to"] = (-1937, -3789, -1231);
            ladderjumps[0]["angles"] = (0, -180, 0);
            ladderjumps[0]["dist"] = 36;

            // skipPoint[ skipPoint.size ] = ( -1890, -3790, -1725 );
            // skipPoint[ skipPoint.size ] = ( -1960, -3790, -1231 );
            // skipPoint[ skipPoint.size ] = ( 0, 180, 0 );
        break;

        case "jm_amatuer": // grenades?
            level.timelimit = 15;

            ladderjumps[0]["from"] = (-991, 2808, 816);
            ladderjumps[0]["to"] = (-1103, -208, 8);
            ladderjumps[0]["angles"] = (0, -90, 0);

            ladderjumps[1]["from"] = (-2763, -1230, 0);
            ladderjumps[1]["to"] = (-2718, 2766, -1839);

            ladderjumps[2]["from"] = (1086, 842, -1879);
            ladderjumps[2]["to"] = (1130, 3315, 1152);
            ladderjumps[2]["angles"] = (0, 90, 0);
        break;

        case "jm_bounce":
            level.timelimit = 20;
        break;

        case "jm_canonjump": // grenades?
            level.timelimit = 15;

            ladderjumps[0]["from"] = (-4014, -899, -4383);
            ladderjumps[0]["to"] = (-3524, -891, -4415);
        break;

        case "jm_caramba_easy":
        case "jm_caramba_hard":
            level.timelimit = 7;
        break;

        case "jm_castle":
            level.timelimit = 20;
        break;

        case "jm_clampdown":
            level.timelimit = 8;
        break;

        case "jm_classique": // grenades?
            ladderjumps[0]["from"] = (4980, 1266, 128);
            ladderjumps[0]["to"] = (3167, -802, 2256);
            ladderjumps[0]["angles"] = (0, -90, 0);

            ladderjumps[1]["from"] = (6703, 1779, -9279);
            ladderjumps[1]["to"] = (6659, -475, -9119);
            ladderjumps[1]["angles"] = (0, 180, 0);

            ladderjumps[2]["from"] = (4700, 992, -5631);
            ladderjumps[2]["to"] = (5204, 992, -5183);
        break;

        case "jm_crispy":
            level.timelimit = 5;
        break;

        case "jm_factory":
            level.timelimit = 10;

            ladderjumps[0]["from"] = ( 554, 388, 168 ); // Cheese
            ladderjumps[0]["to"] = ( 558, 758, 256 );
            
            ladderjumps[0]["dist"] = 96;

            healspots[0] = (445, 125, 168);

            grenadespots[0] = (-227, -20, 120);
            grenadespots[1] = (-227, 220, 120);
        break;

        case "jm_everything": // grenades?
            level.timelimit = 40;
        break;

        case "jm_fear":
            level.timelimit = 15;

            ladderjumps[0]["from"] = (3884, 800, 1408); // Heupfer
            ladderjumps[0]["to"] = (3884, 1030, 800);
            ladderjumps[0]["angles"] = (0, 90, 0);
        break;

        case "jm_foundry":
            level.timelimit = 20;
        break;

        case "jm_gap":
            level.timelimit = 20;
        break;

        case "jm_ghoti":
            level.timelimit = 15;
        break;

        case "jm_hollywood": // grenades?
            level.timelimit = 7;
        break;

        case "jm_house_of_pain": // grenades?
            level.timelimit = 15;
        break;

        case "jm_infiniti":
            level.timelimit = 12;
        break;

        case "jm_krime":
            ladderjumps[0]["from"] = (3168, 1155, -3647);
            ladderjumps[0]["to"] = (3120, 1160, -1783);
            ladderjumps[0]["angles"] = (0, 90, 0);
        break;

        case "jm_kubuntu":
            level.timelimit = 10;
        break;

        case "jm_learn2jump":
            level.timelimit = 7;

            ladderjumps[0]["from"] = (2050, 208, 940);
            ladderjumps[0]["to"] = (490, 1282, 3072);
            ladderjumps[0]["angles"] = (0, 90, 0);
        break;

        case "jm_lockover": // need nadespot - runs out of nades
            level.timelimit = 20;
        break;

        case "jm_maniacmansion":
            level.timelimit = 20;

            healspots[0] = (2076, 1144, -113);

            grenadespots[0] = (1705, 1138, -113);
        break;

        case "jm_mixjump":
            ladderjumps[0]["from"] = (540, -156, 4250);
            ladderjumps[0]["to"] = (-700, -95, 6800);
            ladderjumps[0]["angles"] = (90, 180, 0);

            ladderjumps[1]["from"] = (540, -35, 4250);
            ladderjumps[1]["to"] = (-700, -95, 6800);
            ladderjumps[1]["angles"] = (90, 180, 0);

            ladderjumps[2]["from"] = (-3980, -125, -959);
            ladderjumps[2]["to"] = (-4715, -362, -959);
            ladderjumps[2]["angles"] = (0, 180, 0);

            ladderjumps[3]["from"] = (-4535, -1120, 2640);
            ladderjumps[3]["to"] = (-4110, -123, 6152);
        break;

        case "jm_mota": // grenades?
            level.timelimit = 10;
        break;

        case "jm_motion_light":
        case "jm_motion_pro":
            level.timelimit = 20;

            healspots[0] = (-221, 1644, -1414);
            healspots[1] = (-1733, 3342, -1287);
            healspots[2] = (-1182, 3452, -1006);

            grenadespots[0] = (-224, 1350, -1414);
            grenadespots[1] = (-1732, 3031, -1207);
            grenadespots[2] = (-1600, 3446, -929);
        break;

        case "jm_pillz":
            level.timelimit = 12;

            healspots[0] = (-1083, -37, -207);
            healspots[1] = (880, -1034, -195);

            grenadespots[0] = (-1084, 286, -207);

            panzerspots[0] = (983, -527, -303);
        break;

        case "jm_plazma":
            level.timelimit = 8;
        break;

        case "jm_rikku":
            level.timelimit = 5;
        break;

        case "jm_robbery":
            level.timelimit = 12;
        break;

        case "jm_skysv4c":
            level.timelimit = 12;

            ladderjumps[0]["from"] = (1488, 238, 1628); // Cheese
            ladderjumps[0]["to"] = (3357, 257, 8);
            ladderjumps[0]["dist"] = 96;
        break;

        case "jm_speed":
            level.timelimit = 15;
        break;

        case "jm_sydneyharbour_easy":
        case "jm_sydneyharbour_hard":
            level.timelimit = 15;
        break;

        case "jm_tools":
            level.timelimit = 12;
        break;

        case "jm_towering_inferno":
            level.timelimit = 15;
        break;

        case "jm_uzi":
            level.timelimit = 12;

            ladderjumps[0]["from"] = (489, -60, -481);
            ladderjumps[0]["to"] = (-22, -57, -479);
            ladderjumps[0]["angles"] = (0, 180, 0);

            healspots[0] = (2360, 2686, 1152);

            grenadespots[0] = (2901, 2683, 1152);
        break;

        case "jm_woop":
            level.timelimit = 12;

            ladderjumps[0]["from"] = (320, -3037, -14015);
            ladderjumps[0]["to"] = (112, -280, -5962);
            ladderjumps[0]["angles"] = (0, 90, 0);
        break;

        case "jt_dunno":
            level.timelimit = 12;
        break;

        case "jumpie": // grenades?
        break;

        case "jumpville": // grenades?
            level.timelimit = 7;
        break;

        case "jump_colors":
            level.timelimit = 10;

            ladderjumps[0]["from"] = (-159, 1598, -159);
            ladderjumps[0]["to"] = (-159, 1075, -319);
            ladderjumps[0]["angles"] = (0, -90, 0);
        break;

        case "jumping-falls":
            level.timelimit = 12;
        break;

        case "kn_angry":
            level.timelimit = 20;

            healspots[0] = (960, 31, 1040);

            grenadespots[0] = (966, 434, 976);
        break;

        case "krime_pyramid":
            level.timelimit = 20;
        break;

        case "ls_darkness":
            level.timelimit = 25;
        break;

        case "mazeofdeath_easy":
        case "mazeofdeath_hard":
        case "mazeofdeath_vhard":
            level.timelimit = 7;
        break;

        case "mj_dutchjumpers_gap":
            level.timelimit = 15;
        break;

        case "mj_noname_hard": // grenades?
            level.timelimit = 25;
        break;

        case "mp_jump":
            level.timelimit = 15;
        break;

        case "mp_bolonga":
            level.timelimit = 20;
        break;

        case "nev_codered":
            level.timelimit = 20;
        break;

        case "nev_firstonev2":
            level.timelimit = 20;
        break;

        case "nev_jumpfacility":
            level.timelimit = 20;

            ladderjumps[0]["from"] = (2240, 432, 2078);
            ladderjumps[0]["to"] = (2667, 417, 2256);
            ladderjumps[0]["angles"] = (0, 90, 0);

            healspots[0] = (410, -222, 1224);
            healspots[1] = (-411, -848, 1328);
            healspots[2] = (1513, 1060, 2656);

            grenadespots[0] = (276, -32, 944);
            grenadespots[1] = (326, -857, 1336);
            grenadespots[2] = (1683, 747, 2576);
        break;

        case "nev_jumpfacilityv2":
            level.timelimit = 20;
        break;

        case "nev_namedspace":
            healspots[0] = (6055, 95, 588);

            grenadespots[0] = (5805, 649, 16);
        break;

        case "nev_templeofposeidonv2":
            healspots[0] = (2406, -610, 840);

            grenadespots[0] = (120, 3296, 688);
        break;

        case "nm_castle":
            level.timelimit = 12;

            ladderjumps[0]["from"] = (33, -424, -623);
            ladderjumps[0]["to"] = (64, 1537, 960);
            ladderjumps[0]["angles"] = (0, -90, 0);
        break;

        case "nm_dual_2":
        break;

        case "nm_jump":
            level.timelimit = 6;

            ladderjumps[0]["from"] = (-1129, -548, -2455); // Cheese
            ladderjumps[0]["to"] = (-1187, 242, -2367);
            ladderjumps[0]["angles"] = (0, -180, 0);
            ladderjumps[0]["dist"] = 64;
        break;

        case "nm_mansion":
            level.timelimit = 6;
        break;

        case "nm_portal":
            level.timelimit = 15;

            healspots[0] = (2360, 2686, 1152);

            grenadespots[0] = (2901, 2683, 1152);
        break;

        case "nm_race":
            level.timelimit = 10;
        break;

        case "nm_random":
            level.timelimit = 10;
        break;

        case "nm_tower":
            level.timelimit = 7;
        break;

        case "nm_toybox_easy":
        case "nm_toybox_hard":
            level.timelimit = 12;
        break;

        case "nm_training":
            level.timelimit = 15;
        break;

        case "nm_trap":
            level.timelimit = 20;
        break;

        case "nm_treehouse":
            level.timelimit = 15;
        break;

        case "nm_unlocked":
            level.timelimit = 15;
        break;

        case "nn_lfmjumpv2":
            level.timelimit = 12;
        break;

        case "peds_pace":
            level.timelimit = 8;
        break;

        case "peds_f4a":
            level.timelimit = 6;

            ladderjumps[0]["from"] = (138, 191, -951);
            ladderjumps[0]["to"] = (-264, 191, -1071);
            ladderjumps[0]["angles"] = (0, 180, 0);
        break;

        case "peds_palace":
            level.timelimit = 12;
        break;

        case "peds_parkour":
            level.timelimit = 15;
        break;

        case "peds_puzzle":
            level.timelimit = 12;
        break;

        case "perps_world":
            level.timelimit = 12;

            ladderjumps[0]["from"] = (890, 140, 1335);
            ladderjumps[0]["to"] = (-92, 210, 2819);
            ladderjumps[0]["angles"] = (0, -90, 0);
        break;

        case "race":
            level.timelimit = 6;
        break;

        case "railyard_jump_light":
        case "railyard_jump_hard":
        case "railyard_jump_ultra":
            level.timelimit = 15;

            ladderjumps[0]["from"] = (-1879, 680, 0);
            ladderjumps[0]["to"] = (-1874, 2223, 1205);
            ladderjumps[0]["angles"] = (0, -90, 0);
        break;

        case "skratch_easy_v2": // grenades?
        case "skratch_medium_v2":
        case "skratch_hard_v2":
            level.timelimit = 15;

            ladderjumps[0]["from"] = (-762, 248, 2754);
            ladderjumps[0]["to"] = (-761, 664, 2648);
            ladderjumps[0]["angles"] = (0, 90, 0);

            ladderjumps[1]["from"] = (4590, 508, 1970);
            ladderjumps[1]["to"] = (5416, 508, 2328);
        break;

        case "sl_dam":
        break;

        case "son-of-bitch":
            level.timelimit = 12;
        break;

        case "starship":
            level.timelimit = 12;
        break;

        case "svb_darkblade":
        break;

        case "svb_basics": // grenades?
            level.timelimit = 15;

            ladderjumps[0]["from"] = (-852, -227, 1418);
            ladderjumps[0]["to"] = (-816, 220, 1510);	
        break;

        case "svb_hallway":
            level.timelimit = 15;
        break;

        case "svb_marathon":
            level.timelimit = 15;
        break;

        case "svb_rage":
        break;

        case "svb_sewer":
            level.timelimit = 15;

            ladderjumps[0]["from"] = (-5750, -356, -41); // Cheese
            ladderjumps[0]["to"] = (-4083, -359, -195);
            ladderjumps[0]["dist"] = 36;

            healspots[0] = (-2736, 15, -57);

            grenadespots[0] = (-2979, -343, -195);
            grenadespots[1] = (-2901, 9, -135);
        break;

        case "svt_xmas_v2":
            level.timelimit = 15;
        break;

        case "ultra_gap_training":
            level.timelimit = 15;
        break;

        case "vik_jump":
            level.timelimit = 15;
        break;

        case "wacked":
            level.timelimit = 10;
        break;

        case "zaitroofs":
            level.timelimit = 12;
        break;

        case "zaittower2":
            level.timelimit = 6;
        break;
    }

    // maptime = getCvar("scr_jmp_maptime"); // "<map> <time> <map> <time> ..."
    // if(maptime != "") {
    // 	for(i = 1;; i++) {
    // 		if(getCvar("scr_jmp_maptime" + i) != "")
    // 			maptime += getCvar("scr_jmp_maptime" + i);
    // 		else
    // 			break;
    // 	}

    // 	maptime = jumpmod\functions::strTok(maptime, " ");
    // 	for(i = 0; i < maptime.size; i += 2) { // Find the map in the maptime array and update timelimit
    // 		if(maptime[i] == level.mapname) {
    // 			level.timelimit = (int)maptime[i + 1];
    // 			break;
    // 		}
    // 	}
    // }

    // if(isDefined(mapdifficulty))
    // 	level.mapsettings["difficulty"] = mapdifficulty;
    // else
    // 	level.mapsettings["difficulty"] = "unknown";

    level.mapsettings = [];
    if(isDefined(ladderjumps))
        level.mapsettings["ladderjumps"] = ladderjumps;
    if(isDefined(healspots))
        level.mapsettings["healspots"] = healspots;
    if(isDefined(grenadespots))
        level.mapsettings["grenadespots"] = grenadespots;
    if(isDefined(panzerspots))
        level.mapsettings["panzerspots"] = panzerspots;

    thread mapfixes();
}

mapfixes()
{
    level endon("end_map");
    healthmodel = "xmodel/health_large";
    precacheModel(healthmodel);
    grenademodel = "xmodel/crate_misc1"; // "xmodel/crate_misc_red1" / "xmodel/crate_misc_green1" / "xmodel/ammo_stielhandgranate1"
    precacheModel(grenademodel);
    panzerfaustmodel = "xmodel/ammo_panzerfaust_box2";
    precacheModel(panzerfaustmodel);

    level waittill("jumpmod"); // wait till loaded before starting loops

    maxdistunits = 50;
    ladderjumps = level.mapsettings["ladderjumps"];

    healspots = level.mapsettings["healspots"];
    if(isDefined(healspots)) {
        for(i = 0; i < healspots.size; i++) {
            model = spawn("script_model", healspots[i]);
            model setModel(healthmodel);
        }
    }

    grenadespots = level.mapsettings["grenadespots"];
    if(isDefined(grenadespots)) {
        for(i = 0; i < grenadespots.size; i++) {
            model = spawn("script_model", grenadespots[i]);
            model setModel(grenademodel);
        }
    }

    panzerspots = level.mapsettings["panzerspots"];
    if(isDefined(panzerspots)) {
        for(i = 0; i < panzerspots.size; i++) {
            model = spawn("script_model", panzerspots[i]);
            model setModel(panzerfaustmodel);
        }
    }

    while(true) {
        players = getEntArray("player", "classname");
        for(i = 0; i < players.size; i++) {
            if(isDefined(ladderjumps)) { // Ladderjump skips
                for(l = 0; l < ladderjumps.size; l++) {
                    if(isAlive(players[i]) && players[i].sessionstate == "playing") {
                        if(!isDefined(ladderjumps[l]["dist"]))
                            ladderjumps[l]["dist"] = maxdistunits;
                        if(distance(players[i].origin, ladderjumps[l]["from"]) < ladderjumps[l]["dist"]) {
                            players[i] setOrigin(ladderjumps[l]["to"]);
                            if(isDefined(ladderjumps[l]["angles"]))
                                players[i] setPlayerAngles(ladderjumps[l]["angles"]);
                            else
                                players[i] setPlayerAngles((0, 0, 0));
                            players[i] iPrintLn("Skipping ladder jump...");
                        }
                    }
                }
            }

            if(isDefined(healspots) && players[i].health < players[i].maxhealth) { // Heal areas
                for(l = 0; l < healspots.size; l++) {
                    if(isAlive(players[i]) && players[i].sessionstate == "playing"
                    && distance(players[i].origin, healspots[l]) < maxdistunits) {
                        healthregen = 25;
                        if((players[i].health + healthregen) > players[i].maxhealth) {
                            players[i].health = players[i].maxhealth;
                            players[i] iPrintLn("You are now fully healed!");
                        } else {
                            players[i].health += healthregen;
                            players[i] iPrintLn("Healing... ^2+" + healthregen);
                        }
                    }
                }
            }

            if(isDefined(grenadespots)) { // Grenade areas
                for(l = 0; l < grenadespots.size; l++) {
                    if(isAlive(players[i]) && players[i].sessionstate == "playing"
                    && distance(players[i].origin, grenadespots[l]) < maxdistunits) {
                        if(players[i] getWeaponSlotClipAmmo("grenade") < 1) {
                            grenade = players[i] getWeaponSlotWeapon("grenade");
                            if(grenade == "none") {
                                weapon = players[i] jmpGrenade();
                                players[i] giveWeapon(weapon);
                                players[i] iPrintLn("You've been given a grenade!");
                                players[i] switchToWeapon(weapon);
                                //wait 0.05; // TODO: optimize
                            } else
                                players[i] iPrintLn("Grenade replenished!");
                            players[i] setWeaponSlotAmmo("grenade", 1); // Replenish by 1, so used up
                        }
                        // grenade = players[i] getWeaponSlotWeapon("grenade");
                        // weapon = jmpGrenade();
                        // if(!isDefined(weapon))
                        // 	continue;
                        // if(grenade == "none") {
                        // 	players[i] iPrintLn("You've been given grenades!");
                        // 	players[i] giveWeapon(weapon);
                        // 	wait 0.05; // TODO: optimize
                        // 	players[i] setWeaponSlotAmmo("grenade", 3);
                        // } else {
                        // 	if(players[i] getWeaponSlotClipAmmo("grenade") < 1) {
                        // 		players[i] iPrintLn("Grenades replenished!");
                        // 		players[i] setWeaponSlotAmmo("grenade", 3);
                        // 	}
                        // }
                    }
                }
            }

            if(isDefined(panzerspots)) { // Panzerfaust areas
                for(l = 0; l < panzerspots.size; l++) {
                    if(isAlive(players[i]) && players[i].sessionstate == "playing"
                    && distance(players[i].origin, panzerspots[l]) < maxdistunits) {
                        primary = players[i] getWeaponSlotWeapon("primary");
                        if(primary == "panzerfaust_mp") {
                            players[i] takeWeapon("primary");
                            players[i] iPrintLn("You're not suppose to have a Panzerfaust as primary weapon.");
                        }

                        primaryb = players[i] getWeaponSlotWeapon("primaryb");
                        if(primaryb == "panzerfaust_mp") {
                            if(players[i] getWeaponSlotClipAmmo("primaryb") < 1) {
                                players[i] setWeaponSlotAmmo("primaryb", 1);
                                players[i] iPrintLn("Panzerfaust replenished!");
                            }
                        } else {
                            if(primaryb != "none") {
                                players[i] takeWeapon("primaryb");
                                wait 0.05;
                            }
                            players[i] setWeaponSlotWeapon("primaryb", "panzerfaust_mp");
                            players[i] setWeaponSlotAmmo("primaryb", 1);
                            players[i] switchToWeapon("panzerfaust_mp");
                            players[i] iPrintLn("You've been given a Panzerfaust!");
                        }
                    }
                }
            }
        }

        wait 0.05;
    }
}

mapdifficulty(mapname)
{
    switch(tolower(mapname)) { 
        case "v_xmasrace":
        case "[sob]easyjump":
        case "bc_bocli":
        case "ch_secret":
        case "cj_cow":
        case "cj_change":
        case "cj_hornet":
        case "cj_hallwayofdoom":
        case "cj_wolfjump":
        case "cp_easy_jump":
        case "ct_aztec":
        case "cs_smoke":
        case "dan_jumpv3":
        case "ddd_easy_jump":
        case "double_vision":
        case "jm_caramba_easy":
        case "jm_clampdown":
        case "jm_crispy":
        case "jm_factory":
        case "jm_hollywood":
        case "jm_infiniti":
        case "jm_krime":
        case "jm_kubuntu":
        case "jm_learn2jump":
        case "jm_rikku":
        case "jm_skysv4c":
        case "jm_sydneyharbour_easy":
        case "jm_tools":
        case "jm_uzi":
        case "jumpie":
        case "jumpville":
        case "mazeofdeath_easy":
        case "mp_jump":
        case "nm_castle":
        case "nm_jump":
        case "nm_race":
        case "nm_random":
        case "nm_tower":
        case "nm_toybox_easy":
        case "nm_treehouse":
        case "nm_unlocked":
        case "peds_pace":
        case "peds_f4a":
        case "peds_palace":
        case "peds_puzzle":
        case "perps_world":
        case "race":
        case "railyard_jump_light":
        case "skratch_easy_v2":
        case "svb_hallway":
        case "vik_jump":
        case "wacked":
        case "zaitroofs":
        case "zaittower2":
        return "easy";

        case "jm_gayfected":
        case "zozo_8thjump":
        case "zozo_6thjump":
        case "zozo_2ndjump":
        case "bitch":
        case "ch_space":
        case "cls_industries":
        case "duo_cool2":
        case "fm_squishydeath_easy":
        case "funjump":
        case "groms_skatepark":
        case "harbor_jump":
        case "jm_amatuer":
        case "jm_bounce":
        case "jm_canonjump":
        case "jm_caramba_hard":
        case "jm_ghoti":
        case "jm_house_of_pain":
        case "jm_mixjump":
        case "jm_mota":
        case "jm_motion_light":
        case "jm_pillz":
        case "jm_plazma":
        case "jm_robbery":
        case "jm_speed":
        case "jm_towering_inferno":
        case "jm_woop":
        case "jt_dunno":
        case "jump_colors":
        case "ls_darkness":
        case "mazeofdeath_hard":
        case "mp_bolonga":
        case "nev_jumpfacility":
        case "nev_namedspace":
        case "nm_dual_2":
        case "nm_mansion":
        case "nm_portal":
        case "nm_toybox_hard":
        case "nm_trap":
        case "nn_lfmjumpv2":
        case "peds_parkour":
        case "skratch_medium_v2":
        case "son-of-bitch":
        case "svb_darkblade":
        case "svb_basics":
        case "svb_marathon":
        case "svb_rage":
        case "svb_sewer":
        return "medium";

        case "v_sequence":
        case "gg_neon_v2":
        case "v_forgottentomb":
        case "zh_mario_thwomp":
        case "zh_unknown":
        case "zh_mirage":
        case "gg_shortbounce":
        case "gg_neon":
        case "zh_farbe":
        case "ch_quickie":
        case "fm_squishydeath_hard":
        case "jm_castle":
        case "jm_classique":
        case "jm_fear":
        case "jm_foundry":
        case "jm_gap":
        case "jm_lockover":
        case "jm_maniacmansion":
        case "jm_motion_pro":
        case "jm_sydneyharbour_hard":
        case "jumping-falls":
        case "kn_angry":
        case "krime_pyramid":
        case "mj_noname_hard":
        case "nev_firstonev2":
        case "nev_jumpfacilityv2":
        case "railyard_jump_hard":
        case "skratch_hard_v2":
        case "starship":
        case "svt_xmas_v2":
        return "hard";

        case "cp_sirens_call":
        case "hardjump":
        case "jm_everything":
        case "mazeofdeath_vhard":
        case "nev_codered":
        case "nev_templeofposeidonv2":
        case "railyard_jump_ultra":
        case "sl_dam":
        return "expert";

        case "bigstrafe":
        case "mj_dutchjumpers_gap":
        case "nm_training":
        case "ultra_gap_training":
        return "all";
    }

    return "unknown";
}

// ladderjumps() { // Cheese
// 	switch ( level.mapname ) {
// 		case "fm_squishydeath_easy":
// 			thread ladder_trig( ( -2109, 2477, -1534 ), 36, ( -2068, 1969, -1727 ), ( 0, -90, 0 ) );
// 		break;
// 		case "fm_squishydeath_hard":
// 			thread ladder_trig( ( -2109, 2477, -1534 ), 36, ( -2056, 1922, -1727 ), ( 0, -90, 0 ) );
// 		break;
// 		case "funjump":
// 			thread ladder_trig( ( 146, 3415, -2644 ), 24, ( 146, 3040, -2644 ), ( 0, -90, 0 ) );
// 			thread ladder_trig( ( 39, 2882, -2644 ), 96, ( 46, 3248, -2644 ), ( 0, 90, 0 ) );
// 			thread ladder_trig( ( 978, 5782, -140 ), 36, ( 968, 5781, 255 ), ( 0, 180, 0 ) );
// 		break;
// 		case "hardjump":
// 			thread ladder_trig( ( -1903, -3787, -1957 ), 36, ( -1937, -3789, -1231 ), ( 0, -180, 0 ) );
// 		break;
// 		case "jm_factory":
// 			thread ladder_trig( ( 554, 388, 168 ), 96, ( 558, 758, 256 ), ( 0, 0, 0 ) );
// 		break;
// 		case "jm_fear":
// 			thread ladder_trig( ( 3888, 399, 648 ), 96, ( 3867, 1075, 800 ), ( 0, 90, 0 ), true );
// 		break;
// 		case "jm_skysv4c":
// 			thread ladder_trig( ( 1488, 238, 1628 ), 96, ( 3357, 257, 8 ), ( 0, 0, 0 ) );
// 		break;
// 		case "nm_jump":
// 			thread ladder_trig( ( -1129, -548, -2455 ), 64, ( -1187, 242, -2367 ), ( 0, -180, 0 ) );
// 		break;
// 		case "svb_sewer":
// 			thread ladder_trig( ( -5750, -356, -41 ), 36, ( -4083, -359, -195 ), ( 0, 0, 0 ) );
// 		break;
// 	}

// 	return;
// }

// ladder_trig( origin, dist, tele, angs, preventdeath ) { // Cheese
// 	level endon( "intermission" );

// 	if ( !isDefined( preventdeath ) )
// 		preventdeath = false;

// 	while ( true ) {
// 		players = getEntArray( "player", "classname" );
// 		for ( i = 0; i < players.size; i++ ) {
// 			if ( players[ i ].sessionstate == "playing" && distance( players[ i ].origin, origin ) < dist ) {
// 				if ( preventdeath && !isDefined( players[ i ].preventingdeath ) ) {
// 					players[ i ].preventingdeath = true;
// 					players[ i ] thread preventdeath();
// 				}

// 				players[ i ] setorigin( tele );
// 				players[ i ].angles = angs;
// 				players[ i ] iprintln( "Skipping ladder jumps..." );
// 			}
// 		}

// 		wait 0.05;
// 	}
// }

// preventdeath() { // Cheese
// 	orghealth = self.health;
// 	self.health = 99999;

// 	while ( !self isOnGround() ) {
// 		self.health = 99999;
// 		wait 0.05;
// 	}

// 	self.health = orghealth;
// 	self.preventingdeath = undefined;
// }
