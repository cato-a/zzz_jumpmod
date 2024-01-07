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

    level.timelimit = 30; // 30 minutes default
    level.mapname = getCvar("mapname");
    level.gametype = tolower(getCvar("g_gametype"));
    level.averageframes = GetCvarInt("sv_fps");
    level.frametime = 1.0 / (float)level.averageframes; // Cheese :)
    level.developer = (bool)GetCvarInt("developer");

    /* Here we setup the maps and start loop with fixes
        - level.timelimit overrides
        - extra spawnpoints
        - map difficulty
        - heal, grenade and panzer spots
        - checkpoints*/
    jumpmod\settings::map_setup(); // Cheese's autogenerated gsc from mapname.js0n files
    jumpmod\settings::set_level_difficulties();

    setCvar("scr_allow_vote", "0");

    if(!isDefined(game["state"]))
        game["state"] = "playing";

    level.QuickMessageToAll = true; // special
    level.mapended = false;
    level.healthqueue = [];
    level.healthqueuecurrent = 0;
    level.bans = [];
    level.maxmessages = GetCvarInt("scr_mm_chat_maxmessages");
    if(level.maxmessages > 0) {
        level.penaltytime = GetCvarInt("scr_mm_chat_penaltytime");
        if(level.penaltytime == 0)
            level.penaltytime = 2;
    }

    spawnpointname = "mp_deathmatch_spawn";
    spawnpoints = getEntArray(spawnpointname, "classname");

    if(spawnpoints.size > 0) {
        for(i = 0; i < spawnpoints.size; i++)
            spawnpoints[i] placeSpawnpoint();
    } else
        maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

    setarchive(true); // special (for killcam)
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
    // thread discord();
}

// discord()
// {
//     wait 1;

//     for(;;) {
//         message = GetCvar("discord");
//         if(message != "") {
//             message = jumpmod\functions::strTok(message, ";");
//             if(message.size == 2)
//                 sendservercommand("i \"^7^3[^7Discord^3] ^7" + jumpmod\functions::namefix(message[0]) + "^7: " + message[1] + "\"");
//             SetCvar("discord", "");
//         }

//         wait 0.05;
//     }
// }

Callback_PlayerConnect()
{
    bannedip = self getip();
    banindex = jumpmod\commands::isbanned(bannedip);
    if(banindex != -1) {
        bannedtime = level.bans[banindex]["time"];
        if(bannedtime > 0) {
            bannedsrvtime = level.bans[banindex]["srvtime"];
            remaining = bannedtime - (seconds() - bannedsrvtime);
            if(remaining > 0) {
                self.isbanned = true;
                bannedreason = "tempban remaining ";
                if(remaining >= 86400) {
                    time = remaining / 60 / 60 / 24;
                    bannedreason += time + " day";
                } else if(remaining >= 3600) {
                    time = remaining / 60 / 60;
                    bannedreason += time + " hour";
                } else if(remaining >= 60) {
                    time = remaining / 60;
                    bannedreason += time + " minute";
                } else {
                    time = remaining;
                    bannedreason += time + " second";
                }

                if(time != 1)
                    bannedreason += "s";
            }
        } else {
            self.isbanned = true;
            bannedreason = level.bans[banindex]["reason"]; // to avoid race condition
        }
    }

    if(isDefined(self.isbanned)) { // used in PlayerDisconnect
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
    self.nodamage = false;
    self.save_array = []; // Declare jumpsave array
    self.save_array_max_length = 52;
    self.load_index = 0;

    self.pers["mm_chattimer"] = 0;
    self.pers["mm_chatmessages"] = 1;

    thread jumpmod\commands::_checkLoggedIn();
    self thread mmKeys(); // after "begin"

    if(game["state"] == "intermission") {
        spawnIntermission();
        return;
    }

    level endon("intermission");

    teams[0] = "allies";
    teams[1] = "axis";

    if(level.developer && isDefined(self.isbot)) {
        self.pers["team"] = teams[randomInt(teams.size)];
        spawnPlayer(); return;
    }

    self.pers["team"] = "spectator";
    spawnSpectator();

    self setClientCvar("g_scriptMainMenu", game["menu_team"]);
    self setClientCvar("scr_showweapontab", "0");
    self openMenu(game["menu_team"]);

    self setClientCvar("cg_objectiveText", "Complete the jump map from start to end before the time runs out.\nDouble tap ^1MELEE ^7key to save position.\nDouble tap ^1USE ^7key to load saved positions.");

    if(isDefined(level.acceptvotes) && isDefined(level.votetitle))
        jumpmod\commands::message_player(level.votetitle);

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
    }
}

Callback_PlayerDisconnect()
{
    self notify("disconnect");
    thread jumpmod\commands::_delete();
    thread jumpmod\miscmod::welcome_remove();
    if(isDefined(self.isbanned))
        iPrintLn(jumpmod\functions::namefix(self.name) + " ^7Banned");
    else
        iPrintLn(jumpmod\functions::namefix(self.name) + " ^7Disconnected");
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
    if(self.sessionteam == "spectator" || self.nodamage)
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

jmpSavePosition()
{
    currentslot = jumpmod\functions::getWeaponSlot(self getCurrentWeapon());
    if((currentslot == "primary" || currentslot == "primaryb")
        || (currentslot == "none" && !(self jumpmod\functions::isOnLadder())))
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
    if(level.developer)
        thread jumpmod\functions::addBotClients();

    level.bounceon = (bool)(getCvar("x_cl_bounce") == "1");
    g_speed = 190;
    if(level.bounceon) {
        g_speed += 20; // 210

        mapspeed = GetCvar("scr_jmp_mapspeed"); // if only 220, simplify this?
        if(mapspeed != "") {
            mapspeed = jumpmod\functions::strTok(mapspeed, " ");
            mapname = tolower(level.mapname);
            for(i = 0; i < mapspeed.size; i++) {
                _mapspeed = jumpmod\functions::strTok(mapspeed[i], ":");
                if(mapname == _mapspeed[0]) {
                    g_speed = (int)_mapspeed[1];
                    break;
                }
            }
        }
    }

    setCvar("g_speed", g_speed);

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

    if(isDefined(self.replay))
        jumpmod\commands::cmd_replay_cleanup();

    spawnpointname = "mp_deathmatch_spawn";
    spawnpoints = getEntArray(spawnpointname, "classname");
    spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
    if(isDefined(spawnpoint)) {
        if(positionWouldTelefrag(spawnpoint.origin)) {
            self iPrintLn("^1ERROR:^7 Bad spawnpoint finding new, please wait.");
            spawnpoint = self jumpmod\functions::_newspawn(spawnpoint);
        }

        self spawn(spawnpoint.origin, spawnpoint.angles);
    } else
        maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

    self.statusicon = game["statusicon_" + game[self.pers["team"]]];
    self.maxhealth = 100;
    self.health = self.maxhealth;

    if(!isDefined(self.pers["savedmodel"]))
        maps\mp\gametypes\_teams::model();
    else
        maps\mp\_utility::loadModel(self.pers["savedmodel"]);

    self thread jmpAntiblock();
    self thread jmpWeapons();

    if(!isDefined(self.firstspawn)) {
        self.firstspawn = true;
        self setClientCvar("r_swapInterval", 0); // Sync Every Frame = "No"
        thread jumpmod\miscmod::welcome_display();
    }
}

spawnSpectator()
{
    self notify("spawned");

    resettimeout();

    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.archivetime = 0;

    if(isDefined(self.replay))
        jumpmod\commands::cmd_replay_cleanup();

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

    if(isDefined(self.replay))
        jumpmod\commands::cmd_replay_cleanup();

    spawnpointname = "mp_deathmatch_intermission";
    spawnpoints = getEntArray(spawnpointname, "classname");
    spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

    if(isDefined(spawnpoint))
        self spawn(spawnpoint.origin, spawnpoint.angles);
    else
        maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

mapfixes()
{
    level endon("end_map");
    healthmodel = "xmodel/health_large";
    precacheModel(healthmodel);
    grenademodel = "xmodel/ammo_stielhandgranate1"; // "xmodel/crate_misc_red1" / "xmodel/crate_misc_green1" / "xmodel/ammo_stielhandgranate1"
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

mmKeys()
{ // u = useKey, m = meleeKey and a = attackKey
    keys = "";
    timer = 0;

    for(;;) {
        wait 0.05;

        if(self.sessionstate != "playing")
            continue;

        if(self useButtonPressed()) {
            while(self useButtonPressed())
                wait 0.05;

            keys += "u";
         }

        // if(keys.size > 0 && self attackButtonPressed()) { // not in use currently
        //     while(self attackButtonPressed())
        //         wait 0.05;

        //     keys += "a";
        //  }

        if(self meleeButtonPressed()) {
            while(self meleeButtonPressed())
                wait 0.05;

            keys += "m";
         }

        if(keys.size > 0) {
            timer += 0.05;
            reset = false;
            switch(keys) { // add your custom functions here for keycombos :)
                case "mm":
                    while(!(self isOnGround()) && !(self jumpmod\functions::isOnLadder()))
                        wait 0.05; // wait till player is on ground or on a ladder when issuing this command
                    self thread jmpSavePosition();
                    reset = true;
                break;
                case "uu":
                    self thread jmpLoadPosition();
                    reset = true;
                break;
            }

            if(timer > 1 || reset) {
                timer = 0;
                keys = "";
            }
        }
    }
}