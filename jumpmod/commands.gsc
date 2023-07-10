init()
{
    level.groups = []; // "group1;group2;group3"
    if(getCvar("scr_mm_groups") != "")
        level.groups = jumpmod\functions::strTok(getCvar("scr_mm_groups"), ";");

    if(level.groups.size < 1)
        return;

    level.users = []; // "user1:password user2:password"
    level.perms = []; // "*:<id>:<id1>-<id2>:!<id>"
    for(i = 0; i < level.groups.size; i++) {
        if(getCvar("scr_mm_users_" + level.groups[i]) != "")
            level.users[level.groups[i]] = jumpmod\functions::strTok(getCvar("scr_mm_users_" + level.groups[i]), " ");

        if(getCvar("scr_mm_perms_" + level.groups[i]) != "")
            level.perms[level.groups[i]] = jumpmod\functions::strTok(getCvar("scr_mm_perms_" + level.groups[i]), ":");
    }

    if(level.users.size < 1 || level.perms.size < 1)
        return;

    level.help = [];
    level.banactive = false; // flag for file in use, yeah I know, I'll write it better later
    level.reportactive = false; // flag for file in use, yeah I know, I'll write it better later

    level.workingdir = getCvar("fs_basepath") + "/main/";
    if(getCvar("scr_mm_cmd_path") != "")
        level.workingdir = getCvar("scr_mm_cmd_path") + "/";

    level.banfile = "miscmod_bans.dat";
    level.reportfile = "miscmod_reports.dat";

    if(!isDefined(level.perms["default"]))
        level.perms["default"] = jumpmod\functions::strTok("0-3:5-6:18:33-35:37:53-54", ":"); // pff xD

    level.prefix = "!";
    if(getCvar("scr_mm_cmd_prefix") != "")
        level.prefix = getCvar("scr_mm_cmd_prefix");

    level.nameprefix = "[MiscMod-stripped]";
    if(getCvar("scr_mm_cmd_nameprefix") != "")
        level.nameprefix = getCvar("scr_mm_cmd_nameprefix");

    level.messageburst = 3; // 3 messages - allow 3 messages in X seconds
    if(getCvar("scr_mmj_messagepenburst") != "")
        level.messageburst = getCvarInt("scr_mmj_messagepenburst");
    level.messagepentime = 2; // 2 seconds - allow X messages in 2 seconds
    if(getCvar("scr_mmj_messagepentime") != "")
        level.messagepentime = getCvarInt("scr_mmj_messagepentime");

    level.command = ::command;
    level.commands = [];

    // MiscMod commands
    commands( 0, level.prefix + "login"       , ::cmd_login        , "Login to access commands. [" + level.prefix + "login <user> <pass>]");
    commands( 1, level.prefix + "help"        , ::cmd_help         , "Display this help. [" + level.prefix + "help]");
    commands( 2, level.prefix + "version"     , ::cmd_version      , "Display version information. [" + level.prefix + "version]");
    commands( 3, level.prefix + "name"        , ::cmd_name         , "Change name. [" + level.prefix + "name <new name>]");
    commands( 4, level.prefix + "logout"      , ::cmd_logout       , "Logout. [" + level.prefix + "logout]");
    commands( 5, level.prefix + "pm"          , ::cmd_pm           , "Private message a player. [" + level.prefix + "pm <player> <message>]");
    commands( 6, level.prefix + "re"          , ::cmd_re           , "Respond to private message. [" + level.prefix + "re <message>]");
    commands( 7, level.prefix + "timelimit"   , ::cmd_timelimit    , "Change the timelimit of the map. [" + level.prefix + "timelimit <time>]");
    commands( 8, level.prefix + "endmap"      , ::cmd_endmap       , "Force the map to end. [" + level.prefix + "endmap]");
    commands( 9, level.prefix + "rename"      , ::cmd_rename       , "Change name of a player. [" + level.prefix + "rename <num> <new name>]");
    commands(10, level.prefix + "say"         , ::cmd_say          , "Say a message with group as prefix. [" + level.prefix + "say <message>]");
    commands(11, level.prefix + "saym"        , ::cmd_saym         , "Print a message in the middle of the screen. [" + level.prefix + "saym <message>]");
    commands(12, level.prefix + "sayo"        , ::cmd_sayo         , "Print a message in the obituary. [" + level.prefix + "saym <message>]");
    commands(13, level.prefix + "kick"        , ::cmd_kick         , "Kick a player. [" + level.prefix + "kick <num> <reason>]");
    commands(14, level.prefix + "reload"      , ::cmd_reload       , "Reload MiscMod commands. [" + level.prefix + "reload]");
    commands(15, level.prefix + "restart"     , ::cmd_restart      , "Restart map (soft). [" + level.prefix + "restart (*)]");
    commands(16, level.prefix + "map"         , ::cmd_map          , "Change map and gametype. [" + level.prefix + "map <map> (gametype)]");
    commands(17, level.prefix + "status"      , ::cmd_status       , "List players. [" + level.prefix + "status]");
    commands(18, level.prefix + "plist"       , ::cmd_status       , "List players and their <num> values. [" + level.prefix + "list]");
    commands(19, level.prefix + "warn"        , ::cmd_warn         , "Warn player. [" + level.prefix + "warn <num> <message>]");
    commands(20, level.prefix + "kill"        , ::cmd_kill         , "Kill a player. [" + level.prefix + "kill <num>]");
    commands(21, level.prefix + "weapon"      , ::cmd_weapon       , "Give weapon to player. [" + level.prefix + "weapon <num> <weapon>]");
    commands(22, level.prefix + "heal"        , ::cmd_heal         , "Heal player. [" + level.prefix + "heal <num>]");
    commands(23, level.prefix + "invisible"   , ::cmd_invisible    , "Become invisible. [" + level.prefix + "invisible <on|off>]");
    commands(24, level.prefix + "ban"         , ::cmd_ban          , "Ban player. [" + level.prefix + "ban <num> <reason>]");
    commands(25, level.prefix + "unban"       , ::cmd_unban        , "Unban player. [" + level.prefix + "unban <ip>]");
    commands(26, level.prefix + "report"      , ::cmd_report       , "Report a player. [" + level.prefix + "report <num> <reason>]");
    commands(27, level.prefix + "who"         , ::cmd_who          , "Display logged in users. [" + level.prefix + "who]");
    commands(28, level.prefix + "optimize"    , ::cmd_optimize     , "Set optimal connection settings for a player. [" + level.prefix + "optimize <num>]");
    commands(29, level.prefix + "pcvar"       , ::cmd_pcvar        , "Set a player CVAR (e.g fps, rate, etc). [" + level.prefix + "pcvar <num> <cvar> <value>]");
    commands(30, level.prefix + "scvar"       , ::cmd_scvar        , "Set a server CVAR. [" + level.prefix + "scvar <cvar> <value>]");
    commands(31, level.prefix + "respawn"     , ::cmd_respawn      , "Reload a player spawnpoint. [" + level.prefix + "respawn <num> <sd|dm|tdm>]");
    commands(32, level.prefix + "teleport"    , ::cmd_teleport     , "Teleport a player to a player or (x, y, z) coordinates. [" + level.prefix + "teleport <num> (<num>|<x> <y> <z>)]");
    commands(33, level.prefix + "maplist"     , ::cmd_maplist      , "Show a list of available jump maps. [" + level.prefix + "maplist]");
    commands(34, level.prefix + "vote"        , ::cmd_vote         , "Vote to change/end the map, or to extend the map timer. [" + level.prefix + "vote <endmap|extend|changemap|yes|no> (<time>|<mapname>)]");
    commands(35, level.prefix + "gps"         , ::cmd_gps          , "Toggle current coordinates. [" + level.prefix + "gps]");
    commands(36, level.prefix + "move"        , ::cmd_move         , "Move a player up, down, left, right, forward or backward by specified units. [" + level.prefix + "move <num> <up|down|left|right|forward|backward> <units>]");
    commands(37, level.prefix + "retry"       , ::cmd_retry        , "Respawn player and clear the score, saves, etc.. [" + level.prefix + "retry]");
    commands(38, level.prefix + "insult"      , ::cmd_insult       , "Insult a player. [" + level.prefix + "insult <num>]");
    // Cheese commands
    commands(39, level.prefix + "drop"        , ::cmd_drop         , "Drop a player. [" + level.prefix + "drop <num> <height>]");
    commands(40, level.prefix + "spank"       , ::cmd_spank        , "Spank a player. [" + level.prefix + "spank <num> <time>]");
    commands(41, level.prefix + "slap"        , ::cmd_slap         , "Slap a player. [" + level.prefix + "slap <num> <damage>]");
    commands(42, level.prefix + "blind"       , ::cmd_blind        , "Blind a player. [" + level.prefix + "blind <num> <time>]");
    commands(43, level.prefix + "runover"     , ::cmd_runover      , "Run over a player. [" + level.prefix + "runover <num>]");
    commands(44, level.prefix + "squash"      , ::cmd_squash       , "Squash a player. [" + level.prefix + "squash <num>]");
    commands(45, level.prefix + "rape"        , ::cmd_rape         , "Rape a player. [" + level.prefix + "rape <num>]");
    commands(46, level.prefix + "toilet"      , ::cmd_toilet       , "Turn player into a toilet. [" + level.prefix + "toilet <num>]");
    // PowerServer commands
    commands(47, level.prefix + "explode"     , ::cmd_explode      , "Explode a player. [" + level.prefix + "explode <num>]");
    commands(48, level.prefix + "mortar"      , ::cmd_mortar       , "Mortar a player. [" + level.prefix + "mortar <num>]");
    commands(49, level.prefix + "matrix"      , ::cmd_matrix       , "Matrix. [" + level.prefix + "matrix]");
    commands(50, level.prefix + "burn"        , ::cmd_burn         , "Burn a player. [" + level.prefix + "burn <num>]");
    commands(51, level.prefix + "cow"         , ::cmd_cow          , "BBQ a player. [" + level.prefix + "cow <num>]");
    commands(52, level.prefix + "disarm"      , ::cmd_disarm       , "Disarm a player. [" + level.prefix + "disarm <num>]");
    // MiscMod commands
    commands(53, level.prefix + "replay"      , ::cmd_replay       , "Replay the last jump. [" + level.prefix + "replay <time>]");
    commands(54, level.prefix + "showspeed"   , ::cmd_showspeed    , "Show current player/server speed. [" + level.prefix + "showspeed]");

    level.voteinprogress = getTime(); // !vote command
    thread _loadBans(); // reload bans from dat file every round
}

precache()
{
    /* PowerServer & Cheese commands */
    precacheShellshock("default");
    precacheShellshock("groggy");
    precacheModel("xmodel/vehicle_tank_tiger");
    precacheModel("xmodel/vehicle_russian_barge");
    precacheModel("xmodel/playerbody_russian_conscript");
    precacheModel("xmodel/toilet");
    precacheModel("xmodel/cow_dead");
    precacheModel("xmodel/cow_standing");

    level._effect["fireheavysmoke"]	= loadfx("fx/fire/fireheavysmoke.efx");
    level._effect["flameout"] = loadfx("fx/tagged/flameout.efx");
    level._effect["bombexplosion"] = loadfx("fx/explosions/pathfinder_explosion.efx");
    level._effect["mortar_explosion"][0] = loadfx("fx/impacts/newimps/minefield.efx");
    level._effect["mortar_explosion"][3] = loadfx("fx/impacts/newimps/minefield.efx");
    level._effect["mortar_explosion"][2] = loadfx("fx/impacts/dirthit_mortar.efx");
    level._effect["mortar_explosion"][1] = loadfx("fx/impacts/newimps/blast_gen3.efx");
    level._effect["mortar_explosion"][4] = loadfx("fx/impacts/newimps/dirthit_mortar2daymarked.efx");

    /* Jumpmod */
    precacheString(&"Yes");
    precacheString(&"No");
    precacheString(&"Use command");
    precacheString(&"!vote <yes|no>");
    precacheString(&"Vote ends in:");
    precacheString(&"X:");
    precacheString(&"Y:");
    precacheString(&"Z:");
    precacheString(&"A:");
    precacheString(&"REPLAY");
}

commands(id, cmd, func, desc)
{
    level.commands[cmd]["func"] = func;
    level.commands[cmd]["desc"] = desc;
    level.commands[cmd]["id"]   = id; // :)
    level.help[level.help.size]["cmd"] = cmd;
}

command(str)
{
    if(!isDefined(str)) // string index 0 out of range
        return;

    str = jumpmod\functions::strip(str);
    if(str.size < 1) { // string index 0 out of range
        creturn(); // return in codextended.so
        return;
    }

    if(!isDefined(self.pers["mm_group"]) && isDefined(self.pers["mm_chatmessages"])) {
        penaltytime = level.messagepentime;

        if(self.pers["mm_chatmessages"] > level.messageburst) // mm_chatmessages set in PlayerConnect()
            penaltytime += (self.pers["mm_chatmessages"] - level.messageburst);

        penaltytime *= 1000;
        if(getTime() - self.pers["mm_chattimer"] >= penaltytime) {
            self.pers["mm_chattimer"] = getTime(); // mm_chattimer set in PlayerConnect()
            self.pers["mm_chatmessages"] = 1;
        } else {
            self.pers["mm_chatmessages"]++;

            if(self.pers["mm_chatmessages"] > level.messageburst) {
                if(self.pers["mm_chatmessages"] > 21) // 20 seconds max wait
                    self.pers["mm_chatmessages"] = 21; // 20 seconds max wait
                
                unit = "seconds";
                if(penaltytime == 1000) // 1 second
                    unit = "second";
                message_player("You are currently muted for " + (penaltytime / 1000) + " " + unit + ".");
                creturn(); return;
            }
        }
    }

    if(str.size == 1) return; // just 1 letter, ignore
    if(str[0] != level.prefix) // string index 0 out of range (fixed above)
        return;

    creturn(); // return in codextended.so

    cmd = jumpmod\functions::strTok(str, " "); // is a command with level.prefix
    if(isDefined(level.commands[cmd[0]])) {
        perms = level.perms["default"];

        cmduser = "none";
        cmdgroup = cmduser;

        isloggedin = (bool)isDefined(self.pers["mm_group"]);
        if(isloggedin) {
            cmduser = self.pers["mm_user"];
            cmdgroup = self.pers["mm_group"];
            perms = jumpmod\functions::array_join(perms, level.perms[cmdgroup]);
        }

        command = cmd[0]; // !something
        if(command != "!login") {
            commandargs = "";
            for(i = 1; i < cmd.size; i++) {
                if(i > 1)
                    commandargs += " ";
                commandargs += cmd[i];
            }

            if(commandargs == "")
                commandargs = "none";

            jumpmod\functions::mmlog("command;" + self getip() + ";" + jumpmod\functions::namefix(self.name) + ";" + cmduser + ";" + cmdgroup + ";" + command + ";" + commandargs);
        }

        commandid = level.commands[command]["id"]; // permission id
        if(commandid == 0 || permissions(perms, commandid))
            thread [[ level.commands[command]["func"] ]](cmd);
        else if(isloggedin)
            message_player("^1ERROR: ^7Access denied.");
        else
            message_player("^1ERROR: ^7No such command. Check your spelling.");
    } else
        message_player("^1ERROR: ^7No such command. Check your spelling.");
}

permissions(perms, id) // "*:<id>:<id1>-<id2>:!<id>" :P
{
    wildcard = false;
    for(i = 0; i < perms.size; i++) {
        if(perms[i] == "*")
            wildcard = true;
        else if(perms[i] == id)
            return true;
        else if(perms[i] == ("!" + id))
            return false;
        else {
            range = jumpmod\functions::strTok(perms[i], "-");
            if(range.size == 2) {
                rangeperm = false;
                if(range[0][0] == "!") { // idk about this XD XD
                    _tmp = "";
                    for(s = 1; s < range[0].size; s++)
                        _tmp += range[0][s];

                    range[0] = _tmp;
                    rangeperm = true;
                }

                hi = (int)range[1];
                lo = (int)range[0];

                if(lo >= hi || hi < lo)
                    continue;

                if(id >= lo && id <= hi)
                    return !rangeperm;
            }
        }
    }

    return wildcard;
}

/*
c = iPrintLnBold (all)
e = iPrintLn (all)
f = iPrintLn (all)
g = iPrintLnBold (all)
h = say (all)
i = say (all)
t = open team menu
w = drop client with message
*/
message_player(msg, player)
{
    if(!isDefined(player))
        player = self;

    player sendservercommand("i \"^7^7" + level.nameprefix + ": ^7" + msg + "\""); // ^7^7 fixes spaces problem
}

message(msg)
{
    sendservercommand("i \"^7^7" + level.nameprefix + ": ^7" + msg + "\""); // ^7^7 fixes spaces problem
}

spaces(amount)
{
    spaces = "";
    for(i = 0; i < amount; i++)
        spaces += " ";

    return spaces;
}

playerByName(str)
{
    player = undefined;

    players = jumpmod\functions::getPlayersByName(str);
    if(players.size == 0)
        message_player("^1ERROR: ^7No matches.");
    else if(players.size != 1) {
        message_player("^1ERROR: ^7Too many matches.");
        message_player("-----------------------------------------------------");

        pdata = spawnStruct();
        pdata.num = 0;
        pdata.highscore = 0;
        pdata.ping = 0;

        for(i = 0; i < players.size; i++) {
            player = players[i];
            pnum = player getEntityNumber();

            if(player.score > pdata.highscore)
                pdata.highscore = player.score;

            if(pnum > pdata.num)
                pdata.num = pnum;

             ping = player getping();
            if(ping > pdata.ping)
                pdata.ping = ping;
        }

        pdata.num = pdata.num + "";
        pdata.num = pdata.num.size;

        pdata.highscore = pdata.highscore + "";
        pdata.highscore = pdata.highscore.size;

        pdata.ping = pdata.ping + "";
        pdata.ping = pdata.ping.size;

        for(i = 0; i < players.size; i++) {
            player = players[i];
            pnum = player getEntityNumber();
            pnumstr = pnum + "";
            pscorestr = player.score + "";
            pping = player getping();
            ppingstr = pping + "";
            message = "^1[^7NUM: " + pnum + spaces(pdata.num - pnumstr.size) + " ^1|^7 Score: " + player.score + spaces(pdata.highscore - pscorestr.size) + " ^1|^7 ";
            message += "Ping: " + pping + spaces(pdata.ping - ppingstr.size);
            message += "^1]^3 -->^7 " + jumpmod\functions::namefix(player.name);

            message_player(message);
        }
        return undefined; // recode sometime used to be player = undefined from start of function
    } else
        player = players[0];

    return player;
}

_checkLoggedIn() // "username|group|num;username|group|num"
{
    loggedin = getCvar("tmp_mm_loggedin");
    if(loggedin != "") {
        loggedin = jumpmod\functions::strTok(loggedin, ";");
        for(i = 0; i < loggedin.size; i++) {
            num = self getEntityNumber();
            user = jumpmod\functions::strTok(loggedin[i], "|");

            if(user[2] == num) {
                self.pers["mm_group"] = user[1];
                self.pers["mm_user"] = user[0];
            }
        }
    }
}

_removeLoggedIn(num)
{
    loggedin = getCvar("tmp_mm_loggedin");
    if(loggedin != "") {
        loggedin = jumpmod\functions::strTok(loggedin, ";");
        validuser = false;

        rSTR = "";
        for(i = 0; i < loggedin.size; i++) {
            user = jumpmod\functions::strTok(loggedin[i], "|");
            if(user[2] == num) {
                validuser = true;
                continue;
            }

            rSTR += loggedin[i];
            rSTR += ";";
        }

        if(validuser)
            setCvar("tmp_mm_loggedin", rSTR);
    }
}

_delete()
{
    num = self getEntityNumber();
    _removeLoggedIn(num);
}

_loadBans()
{
    filename = level.workingdir + level.banfile;
    if(fexists(filename)) {
        file = fopen(filename, "r");
        if(file != -1) {
            data = fread(0, file); // codextended.so bug?
            if(isDefined(data)) {
                data = jumpmod\functions::strTok(data, "\n");
                for(i = 0; i < data.size; i++) {
                    if(!isDefined(data[i])) // crashed here for some odd reason? this should never happen
                        continue; // crashed here for some odd reason? this should never happen

                    line = jumpmod\functions::strTok(data[i], "%"); // crashed here for some odd reason? this should never happen
                    if(line.size != 4) // Reported by ImNoob
                        continue;

                    banfile_error = false;
                    for(l = 0; l < line.size; l++) {
                        if(!isDefined(line[l])) {
                            banfile_error = true;
                            break;
                        }
                    }

                    if(banfile_error)
                        continue;// Reported by ImNoob

                    bannedip = line[0];
                    bannedname = jumpmod\functions::namefix(line[1]);
                    bannedreason = jumpmod\functions::namefix(line[2]);
                    bannedby = jumpmod\functions::namefix(line[3]);

                    index = level.bans.size;
                    level.bans[index]["bannedip"] = bannedip;
                    level.bans[index]["bannedname"] = bannedname;
                    level.bans[index]["bannedreason"] = bannedreason;
                    level.bans[index]["bannedby"] = bannedby;
                }
            }
        }

        fclose(file);
    }
}

// --- CMDs below ---

cmd_login(args)
{
    if(args.size != 3) {
        message_player("^1ERROR: ^7Invalid number of arguments. Use " + args[0] + " <username> <password>");
        return;
    }

    if(isDefined(self.pers["mm_group"])) {
        message_player("^5INFO: ^7You are already logged in.");
        return;
    }

    loginis = "unsuccessful";

    username = jumpmod\functions::namefix(args[1]);
    password = jumpmod\functions::namefix(args[2]);

    if(username.size < 1 || password.size < 1) {
        message_player("^1ERROR: ^7You must specify a username and a password.");
        return;
    }

    username = tolower(username);
    loggedin = getCvar("tmp_mm_loggedin");
    if(loggedin != "") {
        loggedin = jumpmod\functions::strTok(loggedin, ";");
        for(i = 0; i < loggedin.size; i++) {
            user = jumpmod\functions::strTok(loggedin[i], "|");
            if(tolower(user[0]) == username) {
                player = jumpmod\functions::playerByNum(user[2]);
                loginis = "loggedin";
                jumpmod\functions::mmlog("login;" + jumpmod\functions::namefix(self.name) + ";" + loginis + ";" + self getip() + ";" + username + ";" + password);
                message_player("^5INFO: ^7" + jumpmod\functions::namefix(self.name) + " ^7tried to login with your username.", player);
                message_player("^1ERROR: ^7You shall not pass!");
                return;
            }
        }
    }

    for(i = 0; i < level.groups.size; i++) {
        group = level.groups[i];
        if(isDefined(group) && isDefined(level.users[group])) {
            users = level.users[group];
            for(u = 0; u < users.size; u++) {
                user = jumpmod\functions::strTok(users[u], ":");
                if(user.size == 2) {
                    if(username == tolower(user[0]) && password == user[1]) {
                        message_player("You are logged in.");
                        message_player("Group: " + group);

                        loginis = "successful";
                        jumpmod\functions::mmlog("login;" + jumpmod\functions::namefix(self.name) + ";" + loginis + ";" + self getip() + ";" + username + ";" + password);

                        self.pers["mm_group"] = group;
                        self.pers["mm_user"] = user[0]; // username - as defined in config

                        rSTR = "";
                        if(getCvar("tmp_mm_loggedin") != "")
                            rSTR += getCvar("tmp_mm_loggedin");

                        rSTR += self.pers["mm_user"];
                        rSTR += "|" + self.pers["mm_group"];
                        rSTR += "|" + self getEntityNumber();
                        rSTR += ";";

                        setCvar("tmp_mm_loggedin", rSTR);
                        return;
                    }
                }
            }
        }
    }

    jumpmod\functions::mmlog("login;" + jumpmod\functions::namefix(self.name) + ";" + loginis + ";" + self getip() + ";" + username + ";" + password);
    message_player("^1ERROR: ^7You shall not pass!");
}

cmd_help(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    message_player("Here is a list of available commands.");

    isloggedin = (bool)isDefined(self.pers["mm_group"]);
    perms = level.perms["default"];
    if(isloggedin) {
        cmdgroup = self.pers["mm_group"];
        perms = jumpmod\functions::array_join(perms, level.perms[cmdgroup]);
    }

    for(i = 0; i < level.help.size; i++) {
        if((i == 0 && isloggedin) || !isDefined(level.help[i]))
            continue;

        cmd = level.help[i]["cmd"];
        spc = spaces(20 - cmd.size);
        if(permissions(perms, level.commands[cmd]["id"]))
            message_player(cmd + spc + level.commands[cmd]["desc"]);

        if((i + 1) % 15 == 0)
            wait 0.25;
    }
}

cmd_logout(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    if(isDefined(self.pers["mm_group"])) {
        self.pers["mm_group"]	= undefined;
        self.pers["mm_user"]	= undefined;
        message_player("You are logged out.");
        _removeLoggedIn(self getEntityNumber());
    }
}

cmd_version(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    message_player("This server is running jumpmod v1.9 with MiscMod-stripped.");
}

cmd_name(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // name
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(args.size > 2) {
        for(a = 2; a < args.size; a++)
            if(isDefined(args[a]))
                args1 += " " + args[a];
    }

    self setClientCvar("name", args1);
    message_player("Your name was changed to: " + args1 + "^7.");
}


cmd_pm(args)
{
    if(args.size < 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    args2 = args[2]; // message
    if(!isDefined(args1) || !isDefined(args2)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        if(args1 == self getEntityNumber()) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }

        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;

        if(player == self) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }
    }

    if(args.size > 2) {
        for(a = 3; a < args.size; a++)
            if(isDefined(args[a]))
                args2 += " " + args[a];
    }

    message_player("^2[^7PM^2]^7 " + jumpmod\functions::namefix(self.name) + "^7: " + args2, player);
    message_player("^1[^7PM^1]^7 " + jumpmod\functions::namefix(player.name) + "^7: " + args2);

    self.pers["pm"] = player getEntityNumber();
    player.pers["pm"] = self getEntityNumber();
}

cmd_re(args)
{
    if(!isDefined(self.pers["pm"])) {
        message_player("^1ERROR: ^7Player ID not found, use !pm <player> <message> first.");
        return;
    }

    player = jumpmod\functions::playerByNum(self.pers["pm"]);
    if(!isDefined(player)) {
        message_player("^1ERROR: ^7Player ID not found, use !pm <player> <message> first.");
        return;
    }

    if(args.size == 1)
        message_player("^5INFO: ^7Replies are sent to: " + jumpmod\functions::namefix(player.name) + "^7.");
    else {
        args1 = args[1];

        //pair has unmatching types 'string' and 'undefined': (file 'codam\_mm_commands.gsc', line 829)
        //  message_player("^2[^7PM^2]^7 " + jumpmod\functions::namefix(self.name) + "^7: " + args1, player);
        //                                                                              *
        if(!isDefined(args1)) // Reported by ImNoob
            return; // Attempted fix

        if(args.size > 2) {
            for(a = 2; a < args.size; a++)
                if(isDefined(args[a]))
                    args1 += " " + args[a];
        }

        message_player("^2[^7PM^2]^7 " + jumpmod\functions::namefix(self.name) + "^7: " + args1, player);
        message_player("^1[^7PM^1]^7 " + jumpmod\functions::namefix(player.name) + "^7: " + args1);

        self.pers["pm"] = player getEntityNumber();
        player.pers["pm"] = self getEntityNumber();
    }
}

cmd_timelimit(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments. (!=2)");
        return;
    }

    args1 = args[1];
    if(jumpmod\functions::validate_number(args1, true)) {
        level.starttime = getTime(); // reset starttime
        level.timelimit = (float)args1;
        timelimit = level.timelimit;
        if(isDefined(level.clock))
            level.clock setTimer(timelimit * 60);
        unit = "minutes";
        if(timelimit == 1)
            unit = "minute";
        else if(timelimit < 1) {
            timelimit *= 60;
            unit = "seconds";
        }
        message("^5INFO: ^7Timelimit changed to: " + timelimit + " " + unit + ".");
    } else
        message_player("^1ERROR: ^7Argument must be an integer or float.");
}

cmd_endmap(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments. (!=1)");
        return;
    }

    message("^5INFO: ^7Forcing the map to end.");
    wait 1;
    level notify("end_map");
}

cmd_rename(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    args2 = args[2]; // name
    if(!isDefined(args1) || !isDefined(args2)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        if(args1 == self getEntityNumber()) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }

        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;

        if(player == self) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }
    }

    if(args.size > 3) {
        for(a = 3; a < args.size; a++)
            if(isDefined(args[a]))
                args2 += " " + args[a];
    }

    message_player("^5INFO: ^7You renamed " + jumpmod\functions::namefix(player.name) + " ^7to " + args2 + "^7.");
    player setClientCvar("name", args2);
}

cmd_say(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1];
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(args.size > 2) {
        for(a = 2; a < args.size; a++)
            if(isDefined(args[a]))
                args1 += " " + args[a];
    }

    if(isDefined(self.pers["mm_group"]))
        sendservercommand("i \"^7^3[^7" + self.pers["mm_group"] + "^3] ^7" + jumpmod\functions::namefix(self.name) + "^7: " + args1 + "\"");
}

cmd_saym(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1];
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(args.size > 2) {
        for(a = 2; a < args.size; a++)
            if(isDefined(args[a]))
                args1 += " " + args[a];
    }

    iPrintLnBold(args1);
}

cmd_sayo(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1];
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(args.size > 2) {
        for(a = 2; a < args.size; a++)
            if(isDefined(args[a]))
                args1 += " " + args[a];
    }

    iPrintLn(args1);
}

cmd_kick(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        if(args1 == self getEntityNumber()) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }

        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;

        if(player == self) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }
    }

    args2 = args[2];
    if(isDefined(args2)) {
        if(args.size > 2) {
            for(a = 3; a < args.size; a++)
                if(isDefined(args[a]))
                    args2 += " " + args[a];
        }

        message("Player " + jumpmod\functions::namefix(player.name) + " ^7was kicked by " + jumpmod\functions::namefix(self.name) + " ^7with reason: " + args2  + ".");
        kickmsg = "Player Kicked: ^1" + args2; // can't be specified in dropclient cases crash ?!
        player dropclient(kickmsg);
    } else {
        message("Player " + jumpmod\functions::namefix(player.name) + " ^7was kicked by " + jumpmod\functions::namefix(self.name) + "^7.");
        player dropclient("Player Kicked.");
    }
}

cmd_reload(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    init();

    message_player("^5INFO: ^7Command system reloaded.");
}

cmd_restart(args)
{
    if(args.size > 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    restart = false;
    if(args.size == 2)
        restart = true;

    map_restart(restart);
}

cmd_map(args)
{
    if(args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    map = args[1];
    if(!isDefined(map)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    gametype = level.gametype;
    if(isDefined(args[2]))
        gametype = args[2];

    mapvar = getCvar("scr_mm_cmd_maps");
    for(i = 1;; i++) {
        tmpvar = getCvar("scr_mm_cmd_maps" + i);
        if(tmpvar != "") {
            if(mapvar != "")
                mapvar += " ";
            mapvar += tmpvar;
        } else
            break;
    }

    if(mapvar != "")
        maps = jumpmod\functions::strTok(mapvar, " ");
    else
        maps = jumpmod\functions::strTok("mp_harbor mp_brecourt mp_carentan mp_railyard mp_dawnville mp_depot mp_rocket mp_pavlov mp_powcamp mp_hurtgen mp_ship mp_chateau", " ");

    if(!jumpmod\functions::in_array(maps, map)) {
        for(i = 0; i < maps.size; i++) {
            if(jumpmod\functions::pmatch(tolower(maps[i]), tolower(map))) {
                map = maps[i];
                break;
            }
        }
    }

    if(jumpmod\functions::in_array(maps, map)) {
        setCvar("sv_mapRotationCurrent", "gametype " + gametype + " map " + map);
        message("^5INFO: ^7Map changed to " + map + " (" + gametype + ") by " + jumpmod\functions::namefix(self.name) + "^7.");

        wait 1;

        exitLevel(false);
    } else
        message_player("^1ERROR: ^7Not a valid map.");
}

cmd_status(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    pdata = spawnStruct();
    pdata.num = 0;
    pdata.highscore = 0;
    pdata.ip = 0;
    pdata.ping = 0;

    players = jumpmod\functions::getOnlinePlayers();
    for(i = 0; i < players.size; i++) {
        player = players[i];
        pnum = player getEntityNumber();

        if(player.score > pdata.highscore)
            pdata.highscore = player.score;

        if(pnum > pdata.num)
            pdata.num = pnum;

        ip = player getip();
        if(ip.size > pdata.ip)
            pdata.ip = ip.size;

         ping = player getping();
        if(ping > pdata.ping)
            pdata.ping = ping;
    }

    pdata.num = pdata.num + "";
    pdata.num = pdata.num.size;

    pdata.highscore = pdata.highscore + "";
    pdata.highscore = pdata.highscore.size;

    pdata.ping = pdata.ping + "";
    pdata.ping = pdata.ping.size;

    message_player("-----------------------------------------------------");
    for(i = 0; i < players.size; i++) {
        player = players[i];
        pnum = player getEntityNumber();
        pnumstr = pnum + "";
        pscorestr = player.score + "";
        pping = player getping();
        ppingstr = pping + "";
        message = "^1[^7NUM: " + pnum + spaces(pdata.num - pnumstr.size) + " ^1|^7 Score: " + player.score + spaces(pdata.highscore - pscorestr.size) + " ^1|^7 ";
        message += "Ping: " + pping + spaces(pdata.ping - ppingstr.size);

        if(args[0] == "!status" && getCvarInt("scr_mm_showip_status") > 0) {
            pip = player getip();
            message += " ^1|^7 IP: " + pip + spaces(pdata.ip - pip.size);
        }

        message += "^1]^3 -->^7 " + jumpmod\functions::namefix(player.name);

        message_player(message);
    }
}

cmd_warn(args)
{
    if(args.size < 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    args2 = args[2]; // message
    if(!isDefined(args1) || !isDefined(args2)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        if(args1 == self getEntityNumber()) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }

        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;

        if(player == self) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }
    }

    if(args.size > 2) {
        for(a = 3; a < args.size; a++)
            if(isDefined(args[a]))
                args2 += " " + args[a];
    }

    message_player("^5INFO: ^7Warning sent to " + jumpmod\functions::namefix(player.name) + "^7.");
    message_player("^1Warning: ^7" + args2, player);
}

cmd_kill(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        if(args1 == self getEntityNumber()) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }

        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;

        if(player == self) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }
    }

    if(isAlive(player)) {
        player suicide();
        message_player("^5INFO: ^7You killed " + jumpmod\functions::namefix(player.name) + "^7.");
        message_player("^5INFO: ^7You were killed by " + jumpmod\functions::namefix(self.name) + "^7.", player);
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_weapon(args) // without the _mp at end of filename
{ // requested by hehu
    if(args.size < 2 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(!jumpmod\functions::validate_number(args1) && args.size != 3) {
        player = self;
        weapon = args1;
    } else {
        weapon = args[2];
        if(!isDefined(weapon)) {
            message_player("^1ERROR: ^7Invalid weapon.");
            return;
        }

        if(jumpmod\functions::validate_number(args1)) {
            player = jumpmod\functions::playerByNum(args1);
            if(!isDefined(player)) {
                message_player("^1ERROR: ^7No such player.");
                return;
            }
        } else {
            player = playerByName(args1);
            if(!isDefined(player)) return;
        }
    }

    weapontypes = "primary secondary grenade";
    weapontypes = jumpmod\functions::strTok(weapontypes, " ");

    if(isAlive(player)) { // requested by hehu
        player endon("spawned");
        player endon("disconnect");
        for(i = 0; i < weapontypes.size; i++) {
            if(!isAlive(player))
                break;

            weaponlist = getCvar("scr_mm_weaponcmd_list_" + weapontypes[i]);
            if(weaponlist == "none")
                continue;

            if(weaponlist != "")
                weapons = jumpmod\functions::strTok(weaponlist, " "); // requested by hehu
            else {
                switch(weapontypes[i]) {
                    case "primary":
                        weapons = jumpmod\functions::strTok("bar bren enfield fg42 kar98k kar98k_sniper m1carbine m1garand mosin_nagant mosin_nagant_sniper mp40 mp44 panzerfaust ppsh springfield sten thompson", " ");
                    break;

                    case "secondary":
                        weapons = jumpmod\functions::strTok("colt luger", " ");
                    break;

                    case "grenade":
                        weapons = jumpmod\functions::strTok("fraggrenade mk1britishfrag rgd-33russianfrag stielhandgranate", " ");
                    break;
                }
            }

            if(!jumpmod\functions::in_array(weapons, weapon)) {
                for(w = 0; w < weapons.size; w++) {
                    if(jumpmod\functions::pmatch(tolower(weapons[w]), tolower(weapon))) {
                        weapon = weapons[w];
                        break;
                    }
                }
            }

            if(jumpmod\functions::in_array(weapons, weapon)) {
                wovel = jumpmod\functions::aAn(weapon);

                if(player != self) {
                    message_player("^5INFO: ^7You gave " + jumpmod\functions::namefix(player.name) + " ^7" + wovel + " " + weapon + "^7.");
                    message_player("You were given " + wovel + " " + weapon + " by " + jumpmod\functions::namefix(self.name) + "^7.", player);
                } else
                    message_player("^5INFO: ^7You gave yourself " + wovel + " " + weapon + "^7.");

                switch(weapontypes[i]) {
                    case "primary":
                        playerweapon = player getWeaponSlotWeapon("primaryb");
                        if(player getWeaponSlotWeapon("primary") == "none")
                            primarynone = true;
                    break;

                    case "secondary":
                        playerweapon = player getWeaponSlotWeapon("pistol");
                    break;

                    case "grenade":
                        playerweapon = player getWeaponSlotWeapon("grenade");
                    break;
                }

                if(playerweapon != "none" && !isDefined(primarynone)) {
                    player takeWeapon(playerweapon);
                    wait 0;
                }

                weapon = weapon + "_mp";

                player giveWeapon(weapon);
                player giveMaxAmmo(weapon);
                player switchToWeapon(weapon);
                break;
            } else if(i == (weapontypes.size - 1))
                message_player("^1ERROR: ^7Unable to determine weapon.");
        }
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_heal(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        player.health = player.maxhealth;
        if(player != self) {
            message_player("^5INFO: ^7You healed " + jumpmod\functions::namefix(player.name) + "^7.");
            message_player("^5INFO: ^7You were healed by " + jumpmod\functions::namefix(self.name) + "^7.", player);
        } else
            message_player("^5INFO: ^7You healed yourself.");
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_invisible(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1];
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    switch(args1) {
        case "on":
            message_player("^5INFO: ^7You are invisible.");
            self ShowToPlayer(self);
        break;
        case "off":
            message_player("^5INFO: ^7You are visible.");
            self ShowToPlayer(undefined);
        break;
        default:
            message_player("^1ERROR: ^7Invalid argument.");
        break;
    }
}

valid_ip(ip)
{
    ip = jumpmod\functions::strTok(ip, ".");
    if(ip.size != 4)
        return false;

    for(i = 0; i < ip.size; i++) {
        validip = false;

        if(!jumpmod\functions::validate_number(ip[i]))
            break;

        if((int)ip[i] >= 0 && (int)ip[i] <= 255)
            validip = true;
        else
            break;
    }

    return validip;
}

cmd_ban(args)
{
    if(args.size < 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string | IP
    args2 = args[2]; // reason

    if(!isDefined(args1) || !isDefined(args2)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    validip = false;
    if(isDefined(args[3]))
        validip = valid_ip(args1);

    if(!validip) {
        if(jumpmod\functions::validate_number(args1)) {
            if(args1 == self getEntityNumber()) {
                message_player("^1ERROR: ^7You can't use this command on yourself.");
                return;
            }

            player = jumpmod\functions::playerByNum(args1);
            if(!isDefined(player)) {
                message_player("^1ERROR: ^7No such player.");
                return;
            }
        } else {
            player = playerByName(args1);
            if(!isDefined(player)) return;

            if(player == self) {
                message_player("^1ERROR: ^7You can't use this command on yourself.");
                return;
            }
        }
    }

    if(level.banactive) {
        message_player("^1ERROR: ^7Database is already in use. Try again.");
        return;
    }

    bannedreason = jumpmod\functions::namefix(args2); // To prevent malicious input

    level.banactive = true;
    filename = level.workingdir + level.banfile;
    if(fexists(filename)) {
        if(validip) {
            bannedip = args1;
            bannedname = "^7An IP address";
        } else {
            bannedip = player getip();
            bannedname = jumpmod\functions::namefix(player.name);
            kickmsg = "Player Banned: ^1" + bannedreason;
            player dropclient(kickmsg);
        }

        bannedby = jumpmod\functions::namefix(self.pers["mm_user"]);

        file = fopen(filename, "a"); // append
        if(file != -1) {
            line = "";
            line += bannedip;
            line += "%%" + bannedname;
            line += "%%" + bannedreason;
            line += "%%" + bannedby;
            line += "\n";
            fwrite(line, file);
        }

        fclose(file);

        message_player("^5INFO: ^7You banned IP: " + bannedip);
        message(bannedname + " ^7was banned by " + jumpmod\functions::namefix(self.name) + " ^7for reason: " + bannedreason + ".");

        index = level.bans.size;
        level.bans[index]["bannedip"] = bannedip;
        level.bans[index]["bannedname"] = bannedname;
        level.bans[index]["bannedreason"] = bannedreason;
        level.bans[index]["bannedby"] = bannedby;
    } else
        message_player("^1ERROR: ^7Ban database file doesn't exist.");

    level.banactive = false;
}

isbanned(bannedip)
{
    for(b = 0; b < level.bans.size; b++) {
        if(isDefined(level.bans[b]) && level.bans[b]["bannedip"] == bannedip)
            return b;
    }

    return -1;
}

cmd_unban(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    if(level.banactive) {
        message_player("^1ERROR: ^7Database is already in use. Try again.");
        return;
    }

    bannedip = args[1]; // IP
    if(!isDefined(bannedip)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(!valid_ip(bannedip)) {
        message_player("^1ERROR: ^7Invalid IP address.");
        return;
    }

    banindex = isbanned(bannedip);
    if(banindex != -1) {
        message_player("^5INFO: ^7You unbanned IP: " + bannedip);
        message(level.bans[banindex]["bannedname"] + " ^7got unbanned by " + jumpmod\functions::namefix(self.name) + "^7.");
        jumpmod\functions::mmlog("unban;" + bannedip + ";" + level.bans[banindex]["bannedname"] + ";" + level.bans[banindex]["bannedreason"] + ";" + level.bans[banindex]["bannedby"] + ";" + jumpmod\functions::namefix(self.name));
        level.bans[banindex] = undefined;

        level.banactive = true;
        filename = level.workingdir + level.banfile;
        if(fexists(filename)) { // may not be needed as "w" created a new file
            file = fopen(filename, "w");
            if(file != -1) {
                for(i = 0; i < level.bans.size; i++) {
                    if(!isDefined(level.bans[i])) // if(i == banindex)
                        continue;

                    line = "";
                    line += level.bans[i]["bannedip"];
                    line += "%%" + level.bans[i]["bannedname"];
                    line += "%%" + level.bans[i]["bannedreason"];
                    line += "%%" + level.bans[i]["bannedby"];
                    line += "\n";
                    fwrite(line, file);
                }
            }
            fclose(file);
        } else
            message_player("^1ERROR: ^7Ban database file doesn't exist.");

        level.banactive = false;
    } else
        message_player("^1ERROR: ^7IP not found in loaded banlist.");
}

cmd_report(args)
{
    if(args.size < 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    args2 = args[2]; // reason

    if(!isDefined(args1) || !isDefined(args2)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        if(args1 == self getEntityNumber()) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }

        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;

        if(player == self) {
            message_player("^1ERROR: ^7You can't use this command on yourself.");
            return;
        }
    }

    if(level.reportactive) {
        message_player("^1ERROR: ^7Database is already in use. Try again.");
        return;
    }

    reportreason = jumpmod\functions::namefix(args2); // To prevent malicious input

    level.reportactive = true;
    filename = level.workingdir + level.reportfile;
    if(fexists(filename)) {
        file = fopen(filename, "a"); // append
        if(file != -1) {
            line = "";
            line += jumpmod\functions::namefix(self.name);
            line += "%%" + self getip();
            line += "%%" + jumpmod\functions::namefix(player.name);
            line += "%%" + player getip();
            line += "%%" + reportreason;
            line += "\n";
            fwrite(line, file);
        }

        fclose(file);

        message_player("^5INFO: ^7You reported " + jumpmod\functions::namefix(player.name) + "^7 with reason: " + reportreason);
    } else
        message_player("^1ERROR: ^7Report database file doesn't exist.");

    level.reportactive = false;
}

cmd_who(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments. (!=1)");
        return;
    }

    pdata = spawnStruct();
    pdata.num = 0;
    pdata.highscore = 0;
    pdata.ping = 0;
    pdata.user = 0;

    players = jumpmod\functions::getOnlinePlayers();
    playersloggedin = [];
    for(i = 0; i < players.size; i++) {
        player = players[i];

        if(!isDefined(player.pers["mm_group"]))
            continue;

        playersloggedin[playersloggedin.size] = player;

        pnum = player getEntityNumber();

        if(player.score > pdata.highscore)
            pdata.highscore = player.score;

        if(pnum > pdata.num)
            pdata.num = pnum;

         ping = player getping();
        if(ping > pdata.ping)
            pdata.ping = ping;

        puser = player.pers["mm_user"] + " (" + player.pers["mm_group"] + "^7)";
        if(puser.size > pdata.user)
            pdata.user = puser.size;
    }

    pdata.num = pdata.num + "";
    pdata.num = pdata.num.size;

    pdata.highscore = pdata.highscore + "";
    pdata.highscore = pdata.highscore.size;

    pdata.ping = pdata.ping + "";
    pdata.ping = pdata.ping.size;

    message_player("-----------------------------------------------------");
    for(i = 0; i < playersloggedin.size; i++) {
        player = playersloggedin[i];
        pnum = player getEntityNumber();
        pnumstr = pnum + "";
        pscorestr = player.score + "";
        pping = player getping();
        ppingstr = pping + "";
        puser = player.pers["mm_user"] + " (" + player.pers["mm_group"] + "^7)";
        message = "^1[^7NUM: " + pnum + spaces(pdata.num - pnumstr.size) + " ^1|^7 Score: " + player.score + spaces(pdata.highscore - pscorestr.size) + " ^1|^7 ";
        message += "Ping: " + pping + spaces(pdata.ping - ppingstr.size) + " ^1|^7 ";
        message += "User: " + puser + spaces(pdata.user - puser.size);
        message += "^1]^3 -->^7 " + jumpmod\functions::namefix(player.name);

        message_player(message);
    }
}

cmd_optimize(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    player setClientCvar("rate", 25000);
    wait 0.05;
    player setClientCvar("cl_maxpackets", 100);
    wait 0.05;
    player setClientCvar("snaps", 40);

    message_player("^5INFO: ^7Player " + jumpmod\functions::namefix(player.name) + " ^7connection settings optimized.");
    message_player("^5INFO: ^7" + jumpmod\functions::namefix(self.name) + " ^7modifed your 'rate', 'snaps' and 'cl_maxpackets' to optimal values.", player);
}

cmd_pcvar(args)
{
    if(args.size != 4) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string

    cvar = args[2];
    cval = args[3];

    if(!isDefined(args1) || !isDefined(cvar) || !isDefined(cval)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    switch(cvar) {
        case "dfps":
        case "drawfps":
            cvar = "cg_drawfps";
            break;
        case "lago":
        case "lagometer":
            cvar = "cg_lagometer";
            break;
        case "fps":
        case "maxfps":
            cvar = "com_maxfps";
            break;
        case "fov":
            cvar = "cg_fov";
            break;
        case "maxpackets":
            cvar = "cl_maxpackets";
            break;
        case "smc":
            cvar = "r_smc_enable";
            break;
        case "packetdup":
            cvar = "cl_packetdup";
            break;
        case "shadows":
            cvar = "cg_shadows";
            break;
        case "brass":
            cvar = "cg_brass";
            break;
        case "mouseaccel":
            cvar = "cl_mouseaccel";
            break;
        case "vsync":
            cvar = "r_swapinterval";
            break;
        case "blood":
            cvar = "cg_blood";
            break;
        case "hunk":
        case "hunkmegs":
            cvar = "com_hunkmegs";
            break;
        case "sun":
        case "drawsun":
            cvar = "r_drawsun";
            break;
        case "fastsky":
            cvar = "r_fastsky";
            break;
        case "marks":
            cvar = "cg_marks";
            break;
        case "third":
            cvar = "cg_thirdperson";
            break;
    }

    player setClientCvar(cvar, cval);

    message_player("^5INFO: ^7" + cvar + " set with value " + cval + " on player " + jumpmod\functions::namefix(player.name) + "^7.");
    message_player("^5INFO: ^7" + jumpmod\functions::namefix(self.name) + " ^7changed your client cvar " + cvar + " to " + cval + ".", player);
}

cmd_scvar(args)
{
    if(args.size == 1 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    bannedcvars[0] = "rconpassword";
    bannedcvars[1] = "cl_allowdownload";
    bannedcvars[2] = "sv_hostname";

    cvar = jumpmod\functions::namefix(args[1]);
    if(!jumpmod\functions::in_array(bannedcvars, tolower(cvar))) {
        if(args.size == 2 || args[2] == "none")
            cval = "";
        else
            cval = jumpmod\functions::namefix(args[2]);

        setCvar(cvar, cval);

        if(cval == "" || cval == "none")
            cval = "empty";
        message_player("^5INFO: ^7Server CVAR " + cvar + " set to " + cval + ".");
    } else
        message_player("^1ERROR: ^7This CVAR is not allowed to change.");
}

cmd_respawn(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    g_gametype[0] = "sd";
    g_gametype[1] = "dm";
    g_gametype[2] = "tdm";

    args1 = args[1]; // num | string

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(!isAlive(player) || player.pers["team"] == "spectator") {
        message_player("^1ERROR: ^7Player must be alive and playing.");
        return;
    }

    stype = args[2]; // dm | tdm | sd
    if(!isDefined(stype))
        stype = tolower(getCvar("g_gametype"));

    if(!jumpmod\functions::in_array(g_gametype, stype)) {
        message_player("^1ERROR: ^7Unknown gametype, specify with !respawn <num> <sd|dm|tdm>.");
        return;
    }

    switch(stype) {
        case "dm":
            spawnpoints = getEntArray("mp_deathmatch_spawn", "classname");
            spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM(spawnpoints);
        break;
        case "sd":
            if(!isDefined(player.pers["team"])) { // This will never be true?
                message_player("^1ERROR: ^7Player team is not defined.");
                return;
            }

            if(player.pers["team"] == "allies")
                spawnpoints = getEntArray("mp_searchanddestroy_spawn_allied", "classname");
            else if(player.pers["team"] == "axis")
                spawnpoints = getEntArray("mp_searchanddestroy_spawn_axis", "classname");
            else {
                message_player("^1ERROR: ^7Player is not axis or allies.");
                return;
            }

            spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
        break;
        case "tdm":
            spawnpoints = getEntArray("mp_teamdeathmatch_spawn", "classname");
            spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnpoints);
        break;
    }

    if(isDefined(spawnpoint) && !positionWouldTelefrag(spawnpoint.origin)) {
        if(player != self) {
            message_player("^5INFO: ^7You respawned player " + jumpmod\functions::namefix(player.name) + "^7.");
            message_player("^5INFO: ^7You were respawned by " + jumpmod\functions::namefix(self.name) + "^7.", player);
        } else
            message_player("^5INFO: ^7You respawned yourself.");

        player setPlayerAngles(spawnpoint.angles);
        player setOrigin(spawnpoint.origin);
    }	else
        message_player("^1ERROR: ^7Problem with new spawnpoint, run command again.");
}

cmd_teleport(args)
{
    if(args.size == 1) { // from MiscMod command uuma
        self iPrintLn("^5Origin: ^1" + self.origin[0] + ", ^2" + self.origin[1] + ", ^3" + self.origin[2]);
        self iPrintLn("^6Angles: ^1" + self.angles[0] + ", ^2" + self.angles[1] + ", ^3" + self.angles[2]);
        return;
    }

    if(args.size == 2) {
        message_player("^1ERROR: ^7Invalid number of arguments, should be none, two or five.");
        return;
    }

    args1 = args[1]; // num | string
    if(jumpmod\functions::validate_number(args1)) {
        player1 = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player1)) {
            message_player("^1ERROR: ^7No such player (" +  args1 + ").");
            return;
        }
    } else {
        player1 = playerByName(args1);
        if(!isDefined(player1)) return;
    }

    if(args.size == 3) {
        args2 = args[2]; // num | string
        if(jumpmod\functions::validate_number(args2)) {
            player2 = jumpmod\functions::playerByNum(args2);
            if(!isDefined(player2)) {
                message_player("^1ERROR: ^7No such player (" +  args2 + ").");
                return;
            }
        } else {
            player2 = playerByName(args2);
            if(!isDefined(player2)) return;
        }

        self endon("spawned");
        self endon("disconnect");
        toplayerorigin = player2.origin;
        for(i = 0; i < 360; i += 36) {
            angle = (0, i, 0);

            trace = bulletTrace(toplayerorigin, toplayerorigin + maps\mp\_utility::vectorscale(anglesToForward(angle), 48), true, self);
            if(trace["fraction"] == 1 && !positionWouldTelefrag(trace["position"]) && jumpmod\functions::_canspawnat(trace["position"])) {
                player1 setPlayerAngles(self.angles);
                player1 setOrigin(trace["position"]);
                if(player1 != self) {
                    if(player2 != self)
                        message_player("^5INFO: ^7You teleported " + jumpmod\functions::namefix(player1.name) + " to player " + jumpmod\functions::namefix(player2.name) + "^7.");
                    else
                        message_player("^5INFO: ^7You teleported " + jumpmod\functions::namefix(player1.name) + " to yourself.");
                    message_player("^5INFO: ^7You were teleported to player " + jumpmod\functions::namefix(player2.name) + "^7.", player1);
                } else
                    message_player("^5INFO: ^7You teleported yourself to player " + jumpmod\functions::namefix(player2.name) + "^7.");
                return;
            }

            wait 0.05;
        }

        message_player("^1ERROR: ^7Unable to teleport to player " + jumpmod\functions::namefix(player2.name) + "^7.");
        return;
    }

    if(args.size != 5) {
        message_player("^1ERROR: ^7Invalid number of arguments, should be none, two or five.");
        return;
    }

    if(jumpmod\functions::validate_number(args[2], true)
        && jumpmod\functions::validate_number(args[3], true)
        && jumpmod\functions::validate_number(args[4], true)) {
        x = (float)args[2];
        if(x == 0)
            x = self.origin[0];

        y = (float)args[3];
        if(y == 0)
            y = self.origin[1];

        z = (float)args[4];
        if(z == 0)
            z = self.origin[2];
    } else {
        message_player("^1ERROR: ^7x, y and/or z is not a number.");
        return;
    }

    if(player1 != self) {
        message_player("^5INFO: ^7You teleported to coordinates (" + x + ", " + y + ", " + z + ") player " + jumpmod\functions::namefix(player1.name) + "^7.");
        message_player("^5INFO: ^7You were teleported to coordinates (" + x + ", " + y + ", " + z + ") by " + jumpmod\functions::namefix(self.name) + "^7.", player1);
    } else
        message_player("^5INFO: ^7You teleported yourself to coordinates (" + x + ", " + y + ", " + z + ").");

    player1 setPlayerAngles(self.angles);
    player1 setOrigin((x, y, z));
}

cmd_maplist(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments. (!=1)");
        return;
    }

    message_player("^5INFO: ^7Here is a list of jump maps:");
    message_player("[SoB]EasyJump        bitch                   ch_quickie");
    message_player("ch_secret            ch_space                cj_change");
    message_player("cj_hallwayofdoom     CJ_HORNET               cj_wolfjump");
    message_player("cp_easy_jump         cp_sirens_call          cs_smoke");
    message_player("CT_Aztec             Dan_JumpV3              ddd_easy_jump");
    message_player("double_vision        fm_squishydeath_easy    fm_squishydeath_hard");
    message_player("funjump              groms_skatepark         hardjump");
    message_player("jm_amatuer           jm_bounce               jm_canonjump");
    message_player("jm_caramba_easy      jm_caramba_hard         jm_castle");
    message_player("jm_clampdown         jm_classique            jm_crispy");
    message_player("jm_Everything        jm_factory              jm_fear");
    message_player("jm_foundry           jm_gap                  jm_ghoti");
    message_player("jm_hollywood         jm_House_of_pain        jm_Infiniti");
    message_player("Jm_Krime             jm_kubuntu              jm_learn2jump");
    message_player("jm_lockover          jm_maniacmansion        jm_mota");
    wait 0.10;
    message_player("jm_motion_light      jm_motion_pro           jm_pillz");
    message_player("jm_plazma            jm_robbery              jm_skysv4c");
    message_player("jm_speed             jm_sydneyharbour_easy   jm_sydneyharbour_hard");
    message_player("jm_tools             jm_towering_inferno     jm_uzi");
    message_player("jm_woop              jt_dunno                jump_colors");
    message_player("jumping-falls        kn_angry                krime_pyramid");
    message_player("mazeofdeath_easy     mazeofdeath_hard        mazeofdeath_vhard");
    message_player("mj_noname_hard       mp_jump                 NEV_CodeRed");
    message_player("NEV_FirstOneV2       NEV_jumpfacility        NEV_JumpFacilityV2");
    message_player("NEV_NamedSpace       NEV_TempleOfPoseidonV2  nm_castle");
    message_player("nm_jump              nm_mansion              nm_portal");
    message_player("nm_race              nm_tower                nm_toybox_easy");
    message_player("nm_toybox_hard       nm_treehouse            nm_unlocked");
    message_player("nn_lfmjumpv2         peds_f4a                peds_pace");
    message_player("peds_palace          peds_parkour            peds_puzzle");
    wait 0.10;
    message_player("race                 railyard_jump_hard      railyard_jump_light");
    message_player("railyard_jump_ultra  sKratch_Easy_v2         sKratch_Hard_v2");
    message_player("sKratch_Medium_v2    son-of-bitch            starship");
    message_player("svb_basics           SVB_DarkBlade           SVB_Hallway");
    message_player("SVB_Marathon         SVB_Sewer               svt_xmas_v2");
    message_player("vik_jump             wacked                  zaitroofs");
    message_player("zaittower2");
    message_player("^5INFO: ^7Bounce maps:");
    message_player("gg_neon              gg_neon_v2              zh_farbe");
    message_player("zh_mario_thwomp      zh_mirage               zh_unknown");
    message_player("^5INFO: ^7Duo maps:");
    message_player("duo_cool2            nm_dual_2");
    message_player("^5INFO: ^7Multiple ending maps:");
    message_player("CLS_Industries       harbor_jump             LS_Darkness");
    message_player("nm_random            SVB_Rage");
    wait 0.10;
    message_player("^5INFO: ^7Bunnyhop maps:");
    message_player("bhop                 bhop_gaps               bhop_start");
    message_player("bhop2");
    message_player("^5INFO: ^7Training maps:");
    message_player("bigstrafe            gg_shortbounce          nm_training ");
    message_player("mj_Dutchjumpers_gap  ultra_gap_training");
    message_player("^5INFO: ^7New maps:");
    message_player("bc_bocli             jm_gayfected            nm_trap");
    message_player("V_ForgottenTomb      V_Sequence              V_XmasRace");
    message_player("zozo_8thjump         zozo_6thjump            zozo_2ndjump");
}

cmd_vote(args)
{
    args1 = args[1]; // <endmap|extend|yes|no>
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid number of arguments. Use !vote <endmap|extend|changemap> (<time>|<mapname>).");
        return;
    }

    if(isDefined(level.acceptvotes)) {
        switch(args1) {
            case "y":
            case "yes":
                self.hasvotecommandvoted = "y";
                message_player("^5INFO: ^7Vote registered. Your vote is currently 'yes'.");
            break;

            case "n":
            case "no":
                self.hasvotecommandvoted = "n";
                message_player("^5INFO: ^7Vote registered. Your vote is currently 'no'.");
            break;

            default:
                message_player("^1ERROR: ^7Voting in progress use command ^1!vote <yes|no>^7 to vote.");
            break;
        }

        return;
    }

    votecommands = jumpmod\functions::strTok("endmap extend changemap map", " ");
    if(!jumpmod\functions::in_array(votecommands, args1)) {
        message_player("^1ERROR: ^7Invalid votecommand. Use !vote <endmap|extend|changemap> (<time>|<mapname>).");
        return;
    }

    timepassed = (getTime() - level.starttime) / 1000;
    timepassed = timepassed / 60.0;
    if(timepassed > (level.timelimit - 0.5)) { // 30 seconds
        message_player("^1ERROR: ^7Vote must be started with enough time left to conduct the vote.");
        return;
    }

    timepassed = (getTime() - level.voteinprogress) / 1000.0;
    votecooldown = 45; // 45 seconds
    if(timepassed < votecooldown) {
        unit = "seconds";
        timeremaining = votecooldown - timepassed;
        if(timeremaining <= 1) {
            timeremaining = 1;
            unit = "second";
        }
        message_player("^5INFO: ^7Voting is available in less than " + timeremaining + " " + unit + ".");
        return;
    }

    level.votecommandtime = 20;

    switch(args1) {
        case "endmap": // !vote endmap
            votetitle = "end the map";
        break;

        case "extend": // !vote extend (time)
            time = 10;
            if(isDefined(args[2]) && jumpmod\functions::validate_number(args[2], true)) {
                time = (float)args[2];
                if(time < 5)
                    time = 5;
                else if(time > 30)
                    time = 30;
            }

            votetitle = "extend the time by ^3" + time + "^7 minutes";
        break;

        case "map":
        case "changemap": // !vote changemap <mapname>
            if(!isDefined(args[2])) {
                message_player("^1ERROR: ^7No map specified. Use !vote changemap <mapname>");
                return;
            }

            map = args[2];
            mapvar = getCvar("scr_mm_cmd_maps");
            for(i = 1;; i++) {
                tmpvar = getCvar("scr_mm_cmd_maps" + i);
                if(tmpvar != "") {
                    if(mapvar != "")
                        mapvar += " ";
                    mapvar += tmpvar;
                } else
                    break;
            }

            if(mapvar != "")
                maps = jumpmod\functions::strTok(mapvar, " ");
            else
                maps = jumpmod\functions::strTok("mp_harbor mp_brecourt mp_carentan mp_railyard mp_dawnville mp_depot mp_rocket mp_pavlov mp_powcamp mp_hurtgen mp_ship mp_chateau", " ");

            if(!jumpmod\functions::in_array(maps, map)) {
                for(i = 0; i < maps.size; i++) {
                    if(jumpmod\functions::pmatch(tolower(maps[i]), tolower(map))) {
                        map = maps[i];
                        break;
                    }
                }
            }

            if(!jumpmod\functions::in_array(maps, map)) {
                message_player("^1ERROR: ^7Not a valid map.");
                return;
            }

            if(map == level.mapname) { // Prevent vote current map
                message_player("^1ERROR: ^7You can't vote for the current map.");
                return;
            }

            votetitle = "change the map to ^3" + map + "^7";
        break;
    }

    players = getEntArray("player", "classname");
    if(players.size > 1) {
        level.votetitle = jumpmod\functions::namefix(self.name) + " ^7started a vote to " + votetitle + "!";
        message("^5INFO: ^7" + level.votetitle);

        level.acceptvotes = true;
        self.hasvotecommandvoted = "y"; // I started the vote, so 'yes' unless I change it
        message_player("^5INFO: ^7Vote registered. Your vote is currently 'yes'.");

        cmd_vote_huds_timer(); // handle/update the huds

        totalvotes = 0;
        players = getEntArray("player", "classname");
        for(i = 0; i < players.size; i++) {
            if(isDefined(players[i].hasvotecommandvoted)) {
                switch(players[i].hasvotecommandvoted) {
                    case "y":
                        totalvotes++;
                    break;
                    case "n":
                        totalvotes--;
                    break;
                }
                players[i].hasvotecommandvoted = undefined;
            }
        }
    } else
        totalvotes = 1;

    if(totalvotes > 0) {
        message("^5INFO: ^7Vote passed!");
        switch(args1) {
            case "endmap":
                level notify("end_map");
            break;

            case "extend":
                timepassed = (getTime() - level.starttime) / 1000;
                timepassed = timepassed / 60.0;
                extendedtime = (level.timelimit - timepassed) + time;
                if(extendedtime > 30)
                    extendedtime = 30;
                targs[0] = "!timelimit";
                targs[1] = extendedtime;
                cmd_timelimit(targs);
            break;

            case "map":
            case "changemap":
                setCvar("sv_mapRotationCurrent", "gametype " + level.gametype + " map " + map);
                wait 0.05;
                exitLevel(false);
            break;
        }
    } else
        message("^5INFO: ^7Vote did not pass!");

    level.acceptvotes = undefined;
    level.voteinprogress = getTime();
}

cmd_vote_huds_timer() // not a command :P
{
    cmd_vote_huds(); // create huds

    for(i = 0; i < level.votecommandtime; i++) { // update huds
        y = 0;
        n = 0;
        players = getEntArray("player", "classname");
        for(p = 0; p < players.size; p++) {
            if(isDefined(players[p].hasvotecommandvoted)) {
                switch(players[p].hasvotecommandvoted) {
                    case "y":
                        y++;
                    break;
                    case "n":
                        n++;
                    break;
                }
            }
        }

        if(isDefined(level.voteYesValue))
            level.voteYesValue setValue(y);
        if(isDefined(level.voteNoValue))
            level.voteNoValue setValue(n);

        // if((y + n) == players.size) // all players has voted
        if(y == players.size || n == players.size) // unanimous players has voted
            break;

        wait 1;
    }

    cmd_vote_huds(); // cleanup huds
}

cmd_vote_huds() // not a command :P
{
    x = 40;
    y = 120;
    if(!isDefined(level.voteBackground)) {
        level.voteBackground = newHudElem();
        level.voteBackground.x = x;
        level.voteBackground.y = y;
        level.voteBackground.alpha = 0.2;
        level.voteBackground.alignX = "left";
        level.voteBackground.alignY = "top";
        level.voteBackground.sort = 995;
        level.voteBackground.archived = true;
        level.voteBackground setShader("black", 80, 40);
    } else
        level.voteBackground destroy();

    if(!isDefined(level.voteHorizontalLine)) {
        level.voteHorizontalLine = newHudElem();
        level.voteHorizontalLine.x = x + 40;
        level.voteHorizontalLine.y = y + 20;
        level.voteHorizontalLine.alignX = "center";
        level.voteHorizontalLine.alignY = "top";
        level.voteHorizontalLine.sort = 1000;
        level.voteHorizontalLine.archived = true;
        level.voteHorizontalLine setShader("black", 80, 1);
    } else
        level.voteHorizontalLine destroy();

    if(!isDefined(level.voteVerticalLine)) {
        level.voteVerticalLine = newHudElem();
        level.voteVerticalLine.x = x + 40;
        level.voteVerticalLine.y = y + 20;
        level.voteVerticalLine.alignX = "left";
        level.voteVerticalLine.alignY = "middle";
        level.voteVerticalLine.sort = 1000;
        level.voteVerticalLine.archived = true;
        level.voteVerticalLine setShader("black", 1, 40);
    } else
        level.voteVerticalLine destroy();

    if(!isDefined(level.voteYesText)) {
        level.voteYesText = newHudElem();
        level.voteYesText.x = x + 20;
        level.voteYesText.y = y + 10;
        level.voteYesText.alignX = "center";
        level.voteYesText.alignY = "middle";
        level.voteYesText.sort = 10000;
        level.voteYesText setText(&"Yes");
        level.voteYesText.color = (1, 0.2, 0);
    } else
        level.voteYesText destroy();

    if(!isDefined(level.voteNoText)) {
        level.voteNoText = newHudElem();
        level.voteNoText.x = x + 60;
        level.voteNoText.y = y + 10;
        level.voteNoText.alignX = "center";
        level.voteNoText.alignY = "middle";
        level.voteNoText.sort = 10000;
        level.voteNoText setText(&"No");
        level.voteNoText.color = (1, 0.2, 0);
    } else
        level.voteNoText destroy();

    if(!isDefined(level.voteYesValue)) {
        level.voteYesValue = newHudElem();
        level.voteYesValue.x = x + 20;
        level.voteYesValue.y = y + 30;
        level.voteYesValue.alignX = "center";
        level.voteYesValue.alignY = "middle";
        level.voteYesValue.sort = 10000;
        level.voteYesValue setValue(0);
        level.voteYesValue.color = (1, 0.7, 0);
    } else
        level.voteYesValue destroy();

    if(!isDefined(level.voteNoValue)) {
        level.voteNoValue = newHudElem();
        level.voteNoValue.x = x + 60;
        level.voteNoValue.y = y + 30;
        level.voteNoValue.alignX = "center";
        level.voteNoValue.alignY = "middle";
        level.voteNoValue.sort = 10000;
        level.voteNoValue setValue(0);
        level.voteNoValue.color = (1, 0.7, 0);
    } else
        level.voteNoValue destroy();

    if(!isDefined(level.voteCommandText1)) {
        level.voteCommandText1 = newHudElem();
        level.voteCommandText1.x = x;
        level.voteCommandText1.y = y + 45;
        level.voteCommandText1.alignX = "left";
        level.voteCommandText1.alignY = "middle";
        level.voteCommandText1.sort = 10000;
        level.voteCommandText1 setText(&"Use command:");
        level.voteCommandText1.color = (1, 0.2, 0);
        level.voteCommandText1.fontScale = 0.75;
    } else
        level.voteCommandText1 destroy();

    if(!isDefined(level.voteCommandText2)) {
        level.voteCommandText2 = newHudElem();
        level.voteCommandText2.x = x + 60;
        level.voteCommandText2.y = y + 45;
        level.voteCommandText2.alignX = "left";
        level.voteCommandText2.alignY = "middle";
        level.voteCommandText2.sort = 10000;
        level.voteCommandText2 setText(&"!vote <yes|no>");
        level.voteCommandText2.color = (1, 0.7, 0);
        level.voteCommandText2.fontScale = 0.75;
    } else
        level.voteCommandText2 destroy();

    if(!isDefined(level.voteCommandTimerText)) {
        level.voteCommandTimerText = newHudElem();
        level.voteCommandTimerText.x = x;
        level.voteCommandTimerText.y = y - 10;
        level.voteCommandTimerText.alignX = "left";
        level.voteCommandTimerText.alignY = "middle";
        level.voteCommandTimerText.sort = 10000;
        level.voteCommandTimerText setText(&"Vote ends in:");
        level.voteCommandTimerText.color = (1, 0.2, 0);
        level.voteCommandTimerText.fontScale = 0.75;
    } else
        level.voteCommandTimerText destroy();

    if(!isDefined(level.voteCommandTimer)) {
        level.voteCommandTimer = newHudElem();
        level.voteCommandTimer.x = x + 53;
        level.voteCommandTimer.y = y - 10;
        level.voteCommandTimer.alignX = "left";
        level.voteCommandTimer.alignY = "middle";
        level.voteCommandTimer.sort = 10000;
        level.voteCommandTimer setTenthsTimer(level.votecommandtime);
        level.voteCommandTimer.color = (1, 0.7, 0);
        level.voteCommandTimer.fontScale = 0.75;
    } else
        level.voteCommandTimer destroy();
}

cmd_gps(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments. (!=1)");
        return;
    }

    if(isDefined(self.gps)) {
        self.gps = undefined;
        self notify("endgps");
        cmd_gps_cleanup();
        message_player("^5INFO: ^7GPS turned off.");
    } else {
        self.gps = true;
        self thread cmd_gps_run(args[0]);
    }
}

cmd_gps_run(cmd) // not a command :P
{
    self endon("endgps");
    message_player("^5INFO: ^7GPS turned on. Use " + cmd + " again to turn off.");
    if(self.sessionstate != "playing")
        message_player("^5INFO: ^7The GPS will be visible when you are alive.");

    x = 550;
    y = 30;
    while(true) {
        while(self.sessionstate != "playing")
            wait 0.5;
    
        self.gpshudx = newClientHudElem(self);
        self.gpshudx.x = x;
        self.gpshudx.y = y;
        self.gpshudx.alignX = "right";
        self.gpshudx.alignY = "middle";
        self.gpshudx.sort = 10000;
        self.gpshudx setText(&"X:");
        self.gpshudx.color = (1, 0.2, 0);

        self.gpshudxval = newClientHudElem(self);
        self.gpshudxval.x = x + 5;
        self.gpshudxval.y = y;
        self.gpshudxval.alignX = "left";
        self.gpshudxval.alignY = "middle";
        self.gpshudxval.sort = 10000;
        self.gpshudxval setValue(0);
        self.gpshudxval.color = (1, 0.7, 0);

        self.gpshudy = newClientHudElem(self);
        self.gpshudy.x = x;
        self.gpshudy.y = y + 12;
        self.gpshudy.alignX = "right";
        self.gpshudy.alignY = "middle";
        self.gpshudy.sort = 10000;
        self.gpshudy setText(&"Y:");
        self.gpshudy.color = (1, 0.2, 0);

        self.gpshudyval = newClientHudElem(self);
        self.gpshudyval.x = x + 5;
        self.gpshudyval.y = y + 12;
        self.gpshudyval.alignX = "left";
        self.gpshudyval.alignY = "middle";
        self.gpshudyval.sort = 10000;
        self.gpshudyval setValue(0);
        self.gpshudyval.color = (1, 0.7, 0);

        self.gpshudz = newClientHudElem(self);
        self.gpshudz.x = x;
        self.gpshudz.y = y + 24;
        self.gpshudz.alignX = "right";
        self.gpshudz.alignY = "middle";
        self.gpshudz.sort = 10000;
        self.gpshudz setText(&"Z:");
        self.gpshudz.fontScale = 1.05; // to match other chars
        self.gpshudz.color = (1, 0.2, 0);

        self.gpshudzval = newClientHudElem(self);
        self.gpshudzval.x = x + 5;
        self.gpshudzval.y = y + 24;
        self.gpshudzval.alignX = "left";
        self.gpshudzval.alignY = "middle";
        self.gpshudzval.sort = 10000;
        self.gpshudzval setValue(0);
        self.gpshudzval.color = (1, 0.7, 0);

        self.gpshudangle = newClientHudElem(self);
        self.gpshudangle.x = x;
        self.gpshudangle.y = y + 36;
        self.gpshudangle.alignX = "right";
        self.gpshudangle.alignY = "middle";
        self.gpshudangle.sort = 10000;
        self.gpshudangle setText(&"A:");
        self.gpshudangle.color = (1, 0.2, 0);

        self.gpshudangleval = newClientHudElem(self);
        self.gpshudangleval.x = x + 5;
        self.gpshudangleval.y = y + 36;
        self.gpshudangleval.alignX = "left";
        self.gpshudangleval.alignY = "middle";
        self.gpshudangleval.sort = 10000;
        self.gpshudangleval setValue(0);
        self.gpshudangleval.color = (1, 0.7, 0);

        while(self.sessionstate == "playing") {
            if(isDefined(self.gpshudxval))
                self.gpshudxval setValue((int)self.origin[0]);
            if(isDefined(self.gpshudyval))
                self.gpshudyval setValue((int)self.origin[1]);
            if(isDefined(self.gpshudzval))
                self.gpshudzval setValue((int)self.origin[2]);
            if(isDefined(self.gpshudangleval))
                self.gpshudangleval setValue((int)self.angles[1]);
            wait 0.25;
        }

        cmd_gps_cleanup();
    }
}

cmd_gps_cleanup() // not a command :P
{
    if(isDefined(self.gpshudx))
        self.gpshudx destroy();
    if(isDefined(self.gpshudxval))
        self.gpshudxval destroy();

    if(isDefined(self.gpshudy))
        self.gpshudy destroy();
    if(isDefined(self.gpshudyval))
        self.gpshudyval destroy();

    if(isDefined(self.gpshudz))
        self.gpshudz destroy();
    if(isDefined(self.gpshudzval))
        self.gpshudzval destroy();
    
    if(isDefined(self.gpshudangle))
        self.gpshudangle destroy();
    if(isDefined(self.gpshudangleval))
        self.gpshudangleval destroy();
}

cmd_move(args) // From Heupfer jumpmod
{ // !move <num> <up|down|left|right|forward|backward> <units> -- abbreviate u d l r f b
    if(args.size != 4) {
        message_player("^1ERROR: ^7Invalid number of arguments, should be 3: !move <num> <up|down|left|right|forward|backward> <units>.");
        return;
    }

    units = args[3];
    if(!jumpmod\functions::validate_number(units)) {
        message_player("^1ERROR: ^7Invalid argument <units>. Units must be a number.");
        return;
    }
    units = (float)units;

    args1 = args[1]; // num | string
    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player (" +  args1 + ").");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        direction = args[2];
        if(direction.size == 1) {
            directions["u"] = "up";
            directions["d"] = "down";
            directions["l"] = "left";
            directions["r"] = "right";
            directions["f"] = "forward";
            directions["b"] = "backward";

            if(isDefined(directions[direction]))
                direction = directions[direction];
        }
            
        switch(direction) {
            case "up":
                dirv = (0, 0, units);
            break;

            case "down":
                dirv = (0, 0, units * -1);
            break;

            case "left":
                dirv = anglesToRight(player.angles);
                dirv = maps\mp\_utility::vectorScale(dirv, units * - 1);
            break;

            case "right":
                dirv = anglesToRight(player.angles);
                dirv = maps\mp\_utility::vectorScale(dirv, units);
            break;

            case "forward":
                dirv = anglesToForward(player.angles);
                dirv = maps\mp\_utility::vectorScale(dirv, units);
            break;

            case "backward":
                dirv = anglesToForward(player.angles);
                dirv = maps\mp\_utility::vectorScale(dirv, units * -1);
            break;

            default:
                message_player("^1ERROR: ^7Direction must be <up|down|left|right|forward|backward> or in abbreviated form <u|d|l|r|f|b>.");
            return;
        }

        // dirv = player.origin + dirv;
        // if(!positionWouldTelefrag(dirv) && jumpmod\functions::_canspawnat(dirv)) {
        // 	if(player != self) {
        // 		message_player("^5INFO: ^7Moving player " + jumpmod\functions::namefix(player.name) + "^7 " + units + " units " + direction + ".");
        // 		message_player("^5INFO: ^7You were moved by " + jumpmod\functions::namefix(self.name) + "^7 " + units + " units " + direction + ".");
        // 	} else
        // 		message_player("^5INFO: ^7You moved yourself " + units + " units " + direction + ".");

        // 	player setOrigin(dirv);
        // } else
        // 	message_player("^1ERROR: ^7Unable to move to the specified direction.");

        if(direction == "left" || direction == "right")
            direction = "to the " + direction;

        if(player != self) {
            message_player("^5INFO: ^7Moving player " + jumpmod\functions::namefix(player.name) + "^7 " + units + " units " + direction + ".");
            message_player("^5INFO: ^7You were moved by " + jumpmod\functions::namefix(self.name) + "^7 " + units + " units " + direction + ".", player);
        } else
            message_player("^5INFO: ^7You moved yourself " + units + " units " + direction + ".");

        player setOrigin(player.origin + dirv);
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_retry(args)
{
    spawnpoints = getEntArray("mp_deathmatch_spawn", "classname");
    spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM(spawnpoints);
    if(isDefined(spawnpoint)) {
        if(positionWouldTelefrag(spawnpoint.origin)) {
            for(i = 0; i < 360; i += 36) {
                angle = (0, i, 0);

                trace = bulletTrace(spawnpoint.origin, spawnpoint.origin + maps\mp\_utility::vectorscale(anglesToForward(angle), 48), true, self);
                if(trace["fraction"] == 1 && !positionWouldTelefrag(trace["position"]) && jumpmod\functions::_canspawnat(trace["position"])) {
                    cmd_retry_clear(trace["position"], self.angles);
                    break;
                }

                wait 0.05;
            }
            message_player("^1ERROR: ^7Bad spawnpoint location. Try the " + args[0] + " command again.");
        } else
            cmd_retry_clear(spawnpoint.origin, spawnpoint.angles);
    }
}

cmd_retry_clear(origin, angles) // not a cmd
{
    message_player("^5INFO: ^7Score, deaths, health and saves cleared.");

    self.score = 0;
    self.deaths = 0;

    if(isDefined(self.save_array))
        self.save_array = [];

    if(isAlive(self) && self.sessionstate == "playing") {
        self.nodamage = true;
        self setPlayerAngles(angles);
        self setOrigin(origin);

        self takeAllWeapons();
        wait 0;
        self maps\MP\gametypes\jmp::jmpWeapons(); // TODO: improve
        self.nodamage = false;
        self.health = self.maxhealth;
    }
}

cmd_insult(args)
{
    if(!isDefined(level.insults) || level.insultcount >= level.insults.size - 1) {
        level.insultcount = 0;
        insults[0]  = "^1's mom is like a hardware store... 10 cents a screw.";
        insults[1]  = "^1. I'd like to see things from your point of view but I can't seem to get my head that far up my ass.";
        insults[2]  = "^1's mom is so poor, she once fought a blind squirrel for a peanut.";
        insults[3]  = "^1 is so stupid he tried to eat a crayon because it looked fruity!";
        insults[4]  = "^1 is so stupid he tought a 'quarter back' is a refund.";
        insults[5]  = "^1 is so poor he uses an ice cube as his A/C.";
        insults[6]  = "^1. If you were any more stupid, he'd have to be watered twice a week.";
        insults[7]  = "^1. I could make a monkey out of you, but why should I take all the credit?";
        insults[8]  = "^1. I heard you got a brain transplant and the brain rejected you!";
        insults[9]  = "^1. How did you get here? Did someone leave your cage open?";
        insults[10] = "^1 got more issues than National Geographic!";
        insults[11] = "^1. If you were my dog, I'd shave your butt and teach you to walk backwards.";
        insults[12] = "^1. You're the reason God created the middle finger.";
        insults[13] = "^1. I hear that when your mother first saw you, she decided to leave you on the front steps of a police station while she turned herself in.";
        insults[14] = "^1. Your IQ involves the square root of -1.";
        insults[15] = "^1. You know you're a bad gamer when you still miss with an aimbot.";
        insults[16] = "^1. You're such a nerd that your penis plugs into a flash drive.";
        insults[17] = "^1's mom is so FAT32, she wouldn't be accepted by NTFS!";
        insults[18] = "^1. You're not important - you're just an NPC!";
        insults[19] = "^1, you're so slow, is your ping at 999?";
        insults[20] = "^1. You're not optimized for life are you?";
        insults[21] = "^1. You must have been born on a highway because that's where most accidents happen.";
        insults[22] = "^1. Why don't you slip into something more comfortable... like a coma.";
        insults[23] = "^1. I had a nightmare. I dreamt I was you.";
        insults[24] = "^1. Lets play 'house'. You be the door and I'll slam you.";
        insults[25] = "^1, I'm gonna get you a condom. That way you can have protection when you go fuck yourself.";
        insults[26] = "^1. Roses are red, violets are blue, I have 5 fingers, the 3rd ones for you.";
        insults[27] = "^1. Ever since I saw you in your family tree, I've wanted to cut it down.";
        insults[28] = "^1, your village just called. They're missing an idiot.";
        insults[29] = "^1, I can't think of an insult stupid enough for you.";
        level.insults = jumpmod\functions::array_shuffle(insults);
    }

    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    iPrintLnBold(jumpmod\functions::namefix(player.name) + level.insults[level.insultcount]);
    level.insultcount++;
}

/* Cheese commands */

cmd_drop(args)
{
    if(args.size < 2 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    height = 512;
    if(args.size == 3)
        if(jumpmod\functions::validate_number(args[2]))
            height = (int)args[2];

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");
        player.drop = spawn("script_origin", player.origin);
        player linkto(player.drop);

        player.drop movez(height, 2);
        wait 2;
        player unlink();
        player.drop delete();

        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7was dropped.");
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_spank(args)
{
    if(args.size < 2 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    time = 15;
    if(args.size == 3)
        if(jumpmod\functions::validate_number(args[2]))
            time = (int)args[2];

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");

        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7is getting spanked.");

        player shellshock("default", time / 2);

        for(i = 0; i < time; i++) {
            player playSound("melee_hit");
            player setClientCvar("cl_stance", 2);
            wait randomFloat(0.5);
        }

        player shellshock("default", 1);
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_slap(args)
{
    if(args.size < 2 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    dmg = 10;
    if(args.size == 3)
        if(jumpmod\functions::validate_number(args[2]))
            dmg = (int)args[2];

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");

        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7is getting slapped.");

        eInflictor = player;
        eAttacker = player;
        iDamage = dmg;
        iDFlags = 0;
        sMeansOfDeath = "MOD_PROJECTILE";
        sWeapon = "panzerfaust_mp";
        vPoint = player.origin + (0, 0, -1);
        vDir = vectorNormalize( player.origin - vPoint );
        sHitLoc = "none";
        psOffsetTime = 0;

        player playSound("melee_hit");
        player finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_blind(args)
{
    if(args.size < 2 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    time = 15;
    if(args.size == 3)
        if(jumpmod\functions::validate_number(args[2]))
            time = (int)args[2];

    player endon("spawned");
    player endon("disconnect");

    iPrintLn(jumpmod\functions::namefix(player.name) + " ^7was blinded for " + time + " seconds.");
    half = time / 2;

    player shellshock("default", time);
    player.blindscreen = newClientHudElem(player);
    player.blindscreen.x = 0;
    player.blindscreen.y = 0;
    player.blindscreen.alpha = 1;
    player.blindscreen setShader("white", 640, 480);
    wait half;
    player.blindscreen fadeOverTime(half);
    player.blindscreen.alpha = 0;
    wait half;
    player.blindscreen destroy();
}

cmd_runover(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");

        lol = spawn("script_origin", player getOrigin());
        player linkto(lol);
        tank = spawn("script_model", player getOrigin() + (-512, 0, -256));
        tank setmodel("xmodel/vehicle_tank_tiger");
        angles = vectortoangles(player getOrigin() - (tank.origin + (0, 0, 256 )));
        tank.angles = angles;
        tank playloopsound("Tank_stone_breakthrough"); // alternative sound as above doesn't play, verified by AJ
        tank movez(256, 1);
        wait 1;
        tank movex(1024, 5);
        wait 1.8;
        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7was run over by a tank.");
        player suicide();
        wait 3.2;
        tank movez(-256, 1);
        wait 1;
        tank stoploopsound();
        tank delete();
        lol delete();
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_squash(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");

        lol = spawn("script_model", player getOrigin());
        player linkto(lol);
        thing = spawn("script_model", player getOrigin() + (0, 0, 1024));
        thing setmodel("xmodel/vehicle_russian_barge");
        thing movez(-1024, 2);
        wait 2;
        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7was squashed with a russian barge!");
        player suicide();
        thing movez(-512, 5);
        wait 5;
        thing delete();
        lol delete();
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_rape(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        dumas = spawn("script_model", (0, 0, 0));
        dumas setmodel("xmodel/playerbody_russian_conscript");

        player thread forceprone();

        iPrintLnBold(jumpmod\functions::namefix(player.name) + "^3 is getting raped by dumas!");

        player endon("spawned");
        player endon("disconnect");
        while(isAlive(player)) {
            tracedir = anglestoforward(player getPlayerAngles());
            traceend = player.origin;
            traceend += jumpmod\functions::vectorScale(tracedir, -56);
            trace = bullettrace(player.origin, traceend, false, player);
            pos = trace["position"];

            dumas.origin = pos;
            dumas.angles = (45, player.angles[1], player.angles[2]);

            rapedir = dumas.origin - player.origin;

            dumas moveto(player.origin, 0.5);
            wait 0.3;
            dumas moveto(pos, 0.25);
            wait 0.25;
            player finishplayerdamage(player, player, 20, 0, "MOD_PROJECTILE", "panzerfaust_mp", dumas.origin, vectornormalize(dumas.origin - player.origin), "none");
        }

        dumas delete();
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

forceprone(args) {
    self endon("spawned");
    self endon("disconnect");

    while(isAlive(self)) {
        self setClientCvar("cl_stance", 2);
        wait 0.05;
    }
}

cmd_toilet(args)
{
    if(args.size < 2 || args.size > 3) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    time = 15;
    if(args.size == 3)
        if(jumpmod\functions::validate_number(args[2]))
            time = (int)args[2];

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");

        player detachall();
        player takeAllWeapons();
        player setmodel("xmodel/toilet");

        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7was turned into a toilet.");

        player setClientCvar("cg_thirdperson", "1");

        wait time;

        player setClientCvar("cg_thirdperson", "0");
        player suicide();
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

/* PowerServer commands */

cmd_explode(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        playfx(level._effect["bombexplosion"], player.origin);
        player suicide();
        iPrintLn(jumpmod\functions::namefix(player.name) + " ^7got a blowjob!");
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_mortar(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        message_player("^5INFO: ^7Dropping deadly mortars on player " + jumpmod\functions::namefix(player.name) + "^7.");
        player endon("spawned");
        player endon("disconnect");

        player playsound("generic_undersuppression_foley");
        player iPrintLn("INCOMING!!!");
        player thread jumpmod\functions::playSoundAtLocation("mortar_incoming", player.origin, 1);

        wait 1.5;

        while(player.sessionstate == "playing") {
            wait 0.5;

            playfx(level._effect["mortar_explosion"][randomInt(3)], player.origin);
            radiusDamage(player.origin, 200, 10, 10);
            thread jumpmod\functions::playSoundAtLocation("mortar_explosion", player.origin, .1);
            earthquake(0.3, 3, player.origin, 850);
        }
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_matrix(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    matrixmsg = [];
    matrixmsg[matrixmsg.size] = "You think that's air you're breathing?";
    matrixmsg[matrixmsg.size] = "Dodge this";
    matrixmsg[matrixmsg.size] = "Only human";
    matrixmsg[matrixmsg.size] = "There is no spoon";
    matrixmsg[matrixmsg.size] = "Wake up Neo";
    matrixmsg[matrixmsg.size] = "The Matrix has you";
    matrixmsg[matrixmsg.size] = "Follow the white rabbit";

    iPrintLnBold(matrixmsg[randomInt(matrixmsg.size)]);

    wait 2;

    players = getEntArray("player", "classname");

    for(i = 0; i < players.size; i++)
        players[i] shellshock("groggy", 6);

    setCvar("timescale", "0.5");
    setCvar("g_gravity", "50");

    wait 5;
    for(x = 0.5; x < 1; x = x + 0.05) {
        wait (0.1 / x);
        setCvar("timescale", x);
    }

    setCvar("timescale", "1");
    setCvar("g_gravity", "800");
}

cmd_burn(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        message_player("^5INFO: ^7Player " + jumpmod\functions::namefix(player.name) + " ^7is burned alive!");
        player endon("spawned");
        player endon("disconnect");

        burnTime = 10;
        startTime = getTime() + (burnTime * 1000);

        while(1) {
            playfx(level._effect["fireheavysmoke"], player.origin);

            if(startTime < getTime()) {
                playfx(level._effect["flameout"], player.origin);
                player suicide();
                player playsound("generic_death_russian_4");
                break;
            }

            wait 0.1;
        }
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_cow(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        player endon("spawned");
        player endon("disconnect");

        iPrintLnBold(jumpmod\functions::namefix(player.name) + " ^7has been turned into BBQ'd beef!");
        player setmodel("xmodel/cow_standing");
        player.health = 100;
        player thread cmd_cow_extra("burn");
        player thread cmd_cow_extra();
        wait 0.1;
        player notify("remove_body");
        wait 9.5;
        player setmodel("xmodel/cow_dead");
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_cow_extra(arg) // lazy to fix
{
    if(isDefined(arg) && arg == "burn") {
        self endon("spawned");
        self endon("disconnect");

        burnTime = 10;
        startTime = getTime() + (burnTime * 1000);

        while(1) {
            playfx(level._effect["fireheavysmoke"], self.origin);

            if(startTime < getTime()) {
                playfx(level._effect["flameout"], self.origin);
                self suicide();
                self playsound("generic_death_russian_4");
                break;
            }

            wait 0.1;
        }
    } else {
        grenade = self getWeaponSlotWeapon("grenade");
        pistol = self getWeaponSlotWeapon("pistol");
        primary = self getWeaponSlotWeapon("primary");
        primaryb = self getWeaponSlotWeapon("primaryb");

        if(!isDefined(grenade))
            grenade = "none";
        if(!isDefined(pistol))
            pistol = "none";
        if(!isDefined(primary))
            primary = "none";
        if(!isDefined(primaryb))
            primary = "none";

        self dropItem(grenade);
        self dropItem(pistol);
        self dropItem(primary);
        self dropItem(primaryb);
    }
}

cmd_disarm(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(jumpmod\functions::validate_number(args1)) {
        player = jumpmod\functions::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
        message_player("^5INFO: ^7Disarmed player " + jumpmod\functions::namefix(player.name) + "^7.");
        grenade = player getWeaponSlotWeapon("grenade");
        pistol = player getWeaponSlotWeapon("pistol");
        primary = player getWeaponSlotWeapon("primary");
        primaryb = player getWeaponSlotWeapon("primaryb");

        if(!isDefined(grenade))
            grenade = "none";
        if(!isDefined(pistol))
            pistol = "none";
        if(!isDefined(primary))
            primary = "none";
        if(!isDefined(primaryb))
            primary = "none";

        player dropItem(grenade);
        player dropItem(pistol);
        player dropItem(primary);
        player dropItem(primaryb);
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

cmd_replay(args)
{
    if(isDefined(self.replay)) {
        message_player("^1ERROR: ^7Replay already active.");
        return;
    }

    if(isAlive(self) && self.sessionstate == "playing") {
        self endon("spawned");
        self endon("disconnect");

        self.replay = true;

        time = args[1];
        if(isDefined(time) && jumpmod\functions::validate_number(time)) {
            time = (int)time;
            if(time < 5 || time > 15)
                time = 10;
        } else
            time = 10;

        if((bool)isDefined(args[2]))
            self setClientCvar("cg_thirdperson", "1");

        origin = self.origin;
        angles = self.angles;

        self.sessionstate = "spectator";
        self.spectatorclient = self getEntityNumber();
        self.archivetime = time;
        wait 0.05; // wait serverframe for archivetime

        if(!isDefined(self.replay_topbar)) {
            self.replay_topbar = newClientHudElem(self);
            self.replay_topbar.archived = false;
            self.replay_topbar.x = 0;
            self.replay_topbar.y = 0;
            self.replay_topbar.alpha = 0.5;
            self.replay_topbar setShader("white", 640, 112);
            self.replay_topbar.color = (0.79216, 0.60784, 0.96863); // baby purple
        }

        if(!isDefined(self.replay_bottombar)) {
            self.replay_bottombar = newClientHudElem(self);
            self.replay_bottombar.archived = false;
            self.replay_bottombar.x = 0;
            self.replay_bottombar.y = 368;
            self.replay_bottombar.alpha = 0.5;
            self.replay_bottombar setShader("white", 640, 112);
            self.replay_bottombar.color = (0.79216, 0.60784, 0.96863); // baby purple
        }

        if(!isDefined(self.replay_title)) {
            self.replay_title = newClientHudElem(self);
            self.replay_title.archived = false;
            self.replay_title.x = 320;
            self.replay_title.y = 40;
            self.replay_title.alignX = "center";
            self.replay_title.alignY = "middle";
            self.replay_title.sort = 1; // force to draw after the bars
            self.replay_title.fontScale = 3.5;
            self.replay_title.color = (0.98039, 0.99608, 0.29412); // banana yellow
            self.replay_title setText(&"REPLAY");
        }

        if(!isDefined(self.replay_timer)) {
            self.replay_timer = newClientHudElem(self);
            self.replay_timer.archived = false;
            self.replay_timer.x = 320;
            self.replay_timer.y = 428;
            self.replay_timer.alignX = "center";
            self.replay_timer.alignY = "middle";
            self.replay_timer.fontScale = 3.5;
            self.replay_timer.sort = 1;
            self.replay_timer setTenthsTimer(self.archivetime - 0.05);
        }

        wait self.archivetime - 0.05;

        wait 0.05; // wait serverframe for archivetime

        self.spectatorclient = -1;
        self.archivetime = 0;
        self.sessionstate = "playing";

        self setPlayerAngles(angles); // Update the player position
        self setOrigin(origin);

        cmd_replay_cleanup();
    } else
        message_player("^1ERROR: ^7You must be alive.");
}

cmd_replay_cleanup()
{
    self setClientCvar("cg_thirdperson", "0"); 
    if(isDefined(self.replay_topbar))
        self.replay_topbar destroy();
    if(isDefined(self.replay_bottombar))
        self.replay_bottombar destroy();
    if(isDefined(self.replay_title))
        self.replay_title destroy();
    if(isDefined(self.replay_timer))
        self.replay_timer destroy();

    self.replay = undefined;
}

cmd_showspeed(args)
{
    if(args.size != 1) {
        message_player("^1ERROR: ^7Invalid number of arguments. (!=1)");
        return;
    }

    if(isDefined(self.showspeed)) {
        self.showspeed = undefined;
        self notify("endshowspeed");
        cmd_showspeed_cleanup();
        message_player("^5INFO: ^7Speed monitor turned off.");
    } else {
        self.showspeed = true;
        self thread cmd_showspeed_run(args[0]);
    }
}

cmd_showspeed_run(cmd) // not a command :P
{ // Thanks Cheese for the !showspeed command and calculations
    self endon("endshowspeed");
    message_player("^5INFO: ^7Speed monitor turned on. Use " + cmd + " again to turn off.");
    if(self.sessionstate != "playing")
        message_player("^5INFO: ^7The speed monitor will be visible when you are alive.");

    x = 480;
    y = 30;
    while(true) {
        while(self.sessionstate != "playing")
            wait 0.5;
    
        self.speedhudx = newClientHudElem(self);
        self.speedhudx.x = x;
        self.speedhudx.y = y;
        self.speedhudx.alignX = "right";
        self.speedhudx.alignY = "middle";
        self.speedhudx.sort = 10000;
        self.speedhudx.archived = true;
        self.speedhudx setText(&"Speed (max):");
        self.speedhudx.color = (1, 0.2, 0);

        self.speedhudxval = newClientHudElem(self);
        self.speedhudxval.x = x + 5;
        self.speedhudxval.y = y;
        self.speedhudxval.alignX = "left";
        self.speedhudxval.alignY = "middle";
        self.speedhudxval.sort = 10000;
        self.speedhudxval.archived = true;
        self.speedhudxval setValue(0);
        self.speedhudxval.color = (1, 0.7, 0);

        self.speedhudy = newClientHudElem(self);
        self.speedhudy.x = x;
        self.speedhudy.y = y + 12;
        self.speedhudy.alignX = "right";
        self.speedhudy.alignY = "middle";
        self.speedhudy.sort = 10000;
        self.speedhudy.archived = true;
        self.speedhudy setText(&"Speed (2/f):");
        self.speedhudy.color = (1, 0.2, 0);

        self.speedhudyval = newClientHudElem(self);
        self.speedhudyval.x = x + 5;
        self.speedhudyval.y = y + 12;
        self.speedhudyval.alignX = "left";
        self.speedhudyval.alignY = "middle";
        self.speedhudyval.sort = 10000;
        self.speedhudyval.archived = true;
        self.speedhudyval setValue(0);
        self.speedhudyval.color = (1, 0.7, 0);

        // average speed over the last second
        average = [];
        for(i = 0; i < level.averageframes; i++)
            average[i] = 0;

        while(isAlive(self) && self.sessionstate == "playing") {
            lastPos = self.origin;
            wait level.frametime;

            for(i = level.averageframes; i > 0; i--)
                average[i] = average[i - 1];

            average[0] = distance(lastPos, self.origin) / level.frametime ;

            maxSpeed = 0;
            for(i = 0; i < level.averageframes; i++) {
                if(average[i] > maxSpeed)
                    maxSpeed = average[i];
            }

            if(isDefined(self.speedhudxval))
                self.speedhudxval setValue((int)(maxSpeed)); // // maximum speed from the last 1 seconds
            if(isDefined(self.speedhudyval))
                self.speedhudyval setValue((int)(average[0] + average[1]) / 2); // average speed over 2 frames
        }

        cmd_showspeed_cleanup();
    }
}

cmd_showspeed_cleanup() // not a command :P
{
    if(isDefined(self.speedhudx))
        self.speedhudx destroy();
    if(isDefined(self.speedhudxval))
        self.speedhudxval destroy();

    if(isDefined(self.speedhudy))
        self.speedhudy destroy();
    if(isDefined(self.speedhudyval))
        self.speedhudyval destroy();
}