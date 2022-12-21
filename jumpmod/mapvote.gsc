init()
{
	game["mapvote"] = &"Press ^1FIRE ^7to vote                           Votes";
	game["maptimeleft"] = &"Time left: ";

	precacheShader("white");
	precacheString(game["mapvote"]);
	precacheString(game["maptimeleft"]);

	level.fmgametype = tolower(getCvar("g_gametype"));
	level.fmmapname = getCvar("mapname");
	
	level.mapvote = false;
	if(getCvar("scr_fm_mapvote") != "" && getCvarInt("scr_fm_mapvote") > 0)
		level.mapvote = true;

	if(!level.mapvote)
		return;

	level.mapvotetime = 15;
	if(getCvar("scr_fm_mapvotetime") != "" && getCvarInt("scr_fm_mapvotetime") >= 10)
		level.mapvotetime = getCvarInt("scr_fm_mapvotetime");
	
	if(level.mapvotetime > 60)
		level.mapvotetime = 60;

	level.mapvotereplay = false;
	if(getCvar("scr_fm_mapvotereplay") != "" && getCvarInt("scr_fm_mapvotereplay") > 0)
		level.mapvotereplay = true;

	level.mapvoterandom = false;
	if(getCvar("scr_fm_mapvoterandom") != "" && getCvarInt("scr_fm_mapvoterandom") > 0)
		level.mapvoterandom = true;

	level.mapvotegametype = true;
	if(getCvar("scr_fm_mapvotegametype") != "" && getCvarInt("scr_fm_mapvotegametype") == 0)
		level.mapvotegametype = false;

	level.mapvotebans = 0;
	if(getCvar("scr_fm_mapvotebans") != "" && getCvarInt("scr_fm_mapvotebans") > 0)
		level.mapvotebans = getCvarInt("scr_fm_mapvotebans");
	
	level.mapvotesound = false;
	if(getCvar("scr_fm_mapvotesound") != "" && getCvarInt("scr_fm_mapvotesound") > 0)
		level.mapvotesound = true;

	if(level.fmgametype == "jmp") {
		precacheString(&"easy");
		precacheString(&"medium");
		precacheString(&"hard");
		precacheString(&"expert");
		precacheString(&"unknown");
		precacheString(&"all difficulties");
	}
}

// init_jmp()
// { // Cheese
// 	level.mapdifficulty = getcvar( "scr_map_difficulty" );

// 	precacheString( &"easy" );
// 	precacheString( &"medium" );
// 	precacheString( &"hard" );
// 	precacheString( &"expert" );
// 	precacheString( &"unknown" );
// 	precacheString( &"all difficulties" );
// 	//precacheString( &"Map Difficulty:" );
// }

mapvote()
{
	if(!level.mapvote)
		return;

	level.mapvotehudoffset = 30;
  
	wait 0.5;
  
	createHud();
  
	thread runMapVote();
  
	level waittill("voting_complete");
  
	destroyHud();
}

createHud()
{
	level.vote_hud_bgnd = newHudElem();
	level.vote_hud_bgnd.archived = false;
	level.vote_hud_bgnd.alpha = .7;
	level.vote_hud_bgnd.x = 205;
	level.vote_hud_bgnd.y = level.mapvotehudoffset + 17;
	level.vote_hud_bgnd.sort = 9000;
	level.vote_hud_bgnd.color = (0,0,0);
	level.vote_hud_bgnd setShader("white", 260, 140);

	level.vote_header = newHudElem();
	level.vote_header.archived = false;
	level.vote_header.alpha = .3;
	level.vote_header.x = 208;
	level.vote_header.y = level.mapvotehudoffset + 19;
	level.vote_header.sort = 9001;
	level.vote_header setShader("white", 254, 21);

	level.vote_leftline = newHudElem();
	level.vote_leftline.archived = false;
	level.vote_leftline.alpha = .3;
	level.vote_leftline.x = 207;
	level.vote_leftline.y = level.mapvotehudoffset + 19;
	level.vote_leftline.sort = 9001;
	level.vote_leftline setShader("white", 1, 135);

	level.vote_rightline = newHudElem();
	level.vote_rightline.archived = false;
	level.vote_rightline.alpha = .3;
	level.vote_rightline.x = 462;
	level.vote_rightline.y = level.mapvotehudoffset + 19;
	level.vote_rightline.sort = 9001;
	level.vote_rightline setShader("white", 1, 135);

	level.vote_bottomline = newHudElem();
	level.vote_bottomline.archived = false;
	level.vote_bottomline.alpha = .3;
	level.vote_bottomline.x = 207;
	level.vote_bottomline.y = level.mapvotehudoffset + 154;
	level.vote_bottomline.sort = 9001;
	level.vote_bottomline setShader("white", 256, 1);

	level.vote_hud_timeleft = newHudElem();
	level.vote_hud_timeleft.archived = false;
	level.vote_hud_timeleft.x = 400;
	level.vote_hud_timeleft.y = level.mapvotehudoffset + 26;
	level.vote_hud_timeleft.sort = 9998;
	level.vote_hud_timeleft.fontscale = .8;
	level.vote_hud_timeleft.label = game["maptimeleft"];
	level.vote_hud_timeleft setValue(level.mapvotetime);	

	level.vote_hud_instructions = newHudElem();
	level.vote_hud_instructions.archived = false;
	level.vote_hud_instructions.x = 340;
	level.vote_hud_instructions.y = level.mapvotehudoffset + 56;
	level.vote_hud_instructions.sort = 9998;
	level.vote_hud_instructions.fontscale = 1;
	level.vote_hud_instructions.label = game["mapvote"];
	level.vote_hud_instructions.alignX = "center";
	level.vote_hud_instructions.alignY = "middle";

	level.vote_map1 = newHudElem();
	level.vote_map1.archived = false;
	level.vote_map1.x = 434;
	level.vote_map1.y = level.mapvotehudoffset + 69;
	level.vote_map1.sort = 9998;
		
	level.vote_map2 = newHudElem();
	level.vote_map2.archived = false;
	level.vote_map2.x = 434;
	level.vote_map2.y = level.mapvotehudoffset + 85;
	level.vote_map2.sort = 9998;
		
	level.vote_map3 = newHudElem();
	level.vote_map3.archived = false;
	level.vote_map3.x = 434;
	level.vote_map3.y = level.mapvotehudoffset + 101;
	level.vote_map3.sort = 9998;	

	level.vote_map4 = newHudElem();
	level.vote_map4.archived = false;
	level.vote_map4.x = 434;
	level.vote_map4.y = level.mapvotehudoffset + 117;
	level.vote_map4.sort = 9998;	

	level.vote_map5 = newHudElem();
	level.vote_map5.archived = false;
	level.vote_map5.x = 434;
	level.vote_map5.y = level.mapvotehudoffset + 133;
	level.vote_map5.sort = 9998;	 
}

destroyHud()
{
	level.vote_hud_timeleft destroy();	
	level.vote_hud_instructions destroy();
	level.vote_map1 destroy();
	level.vote_map2 destroy();
	level.vote_map3 destroy();
	level.vote_map4 destroy();
	level.vote_map5 destroy();
	level.vote_hud_bgnd destroy();
	level.vote_header destroy();
	level.vote_leftline destroy();
	level.vote_rightline destroy();
	level.vote_bottomline destroy();

	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isDefined(players[i].vote_indicator))
			players[i].vote_indicator destroy();
}

runMapVote()
{
	randomMapRotation = getRandomMapRotation();

	if(!isDefined(randomMapRotation)) {
		level notify("voting_complete");
		return;
	}
  
	for(i = 0; i < 5; i++) {
		level.mapcandidate[i]["gametype"] = level.fmgametype;

		if(level.mapvoterandom) {
			randMap = randomInt(randomMapRotation.size);
			if(randMap < 1)
				randMap = 1;

			level.mapcandidate[i]["map"] = randomMapRotation[randMap]["map"];
			level.mapcandidate[i]["mapname"] = "mystery map";
			level.mapcandidate[i]["gametype"] = randomMapRotation[randMap]["gametype"];
		} else {
			level.mapcandidate[i]["map"] = level.fmmapname;
			level.mapcandidate[i]["mapname"] = "replay this map";
		}

		level.mapcandidate[i]["votes"] = 0;
		if(level.fmgametype == "jmp") // TODO improve
			level.mapcandidate[i]["difficulty"] = "unknown";
	}
  
	for(i = 0; i < 5; i++) {
		if(!isDefined(randomMapRotation[i]))
			break;
    
		level.mapcandidate[i]["map"] = randomMapRotation[i]["map"];
		level.mapcandidate[i]["mapname"] = randomMapRotation[i]["map"];
		level.mapcandidate[i]["gametype"] = randomMapRotation[i]["gametype"];
		level.mapcandidate[i]["votes"] = 0;
		if(level.fmgametype == "jmp") // TODO improve
			level.mapcandidate[i]["difficulty"] = get_map_difficulty( randomMapRotation[ i ][ "map" ] );
			
		if((level.mapvotereplay || level.mapvoterandom) && i > 2) break;
	}
  
	thread displayMapChoices();
  
	game["menu_team"] = "";
  
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread playerVote();
    
	thread voteLogic();
  
	wait 0.1;
}

voteLogic()
{
	if(level.fmgametype == "jmp")
		thread set_map_difficulties();
	for(; level.mapvotetime >= 0; level.mapvotetime--) {
		for(x = 0; x < 10; x++) {
			for(i = 0; i < 5; i++)
				level.mapcandidate[i]["votes"] = 0;

			players = getEntArray("player", "classname");
			for(i = 0; i < players.size; i++)
				if(isDefined(players[i].votechoice))
					level.mapcandidate[players[i].votechoice]["votes"]++;

			level.vote_map1 setValue(level.mapcandidate[0]["votes"]);
			level.vote_map2 setValue(level.mapcandidate[1]["votes"]);
			level.vote_map3 setValue(level.mapcandidate[2]["votes"]);
			level.vote_map4 setValue(level.mapcandidate[3]["votes"]);
			level.vote_map5 setValue(level.mapcandidate[4]["votes"]);
		
			wait 0.1;  
		}

		level.vote_hud_timeleft setValue(level.mapvotetime);
	}
  
	wait 0.2;
  
	nextmapnum  = 0;
	topvotes = 0;
  
	for(i = 0; i < 5; i++) {
		if(level.mapcandidate[i]["votes"] > topvotes) {
			nextmapnum = i;

			topvotes = level.mapcandidate[i]["votes"];
		}
	}
  
	setMapWinner(nextmapnum);
}

setMapWinner(val)
{
	map = level.mapcandidate[val]["map"];
	mapname	= level.mapcandidate[val]["mapname"];
	gametype = level.mapcandidate[val]["gametype"];

	setCvar("sv_mapRotationCurrent", " gametype " + gametype + " map " + map);
	
	if(level.mapvotebans > 0) {
		if(level.fmmapname != map) {
			mapBanList = jumpmod\functions::strTok(getCvar("tmp_fm_mapvotebanlist"), " ");
			if(!jumpmod\functions::in_array(mapBanList, map)) {
				_tmpBanList = map;
				
				for(i = 0; i < mapBanList.size; i++) {
					if(i < level.mapvotebans - 1)
						_tmpBanList += " " + mapBanList[i];
					else
						break;
				}

				setCvar("tmp_fm_mapvotebanlist", _tmpBanList);
			}
		}
	}

	wait 0.1;

	level notify("voting_done");

	wait 0.05;

	iPrintLnBold(" ");
	iPrintLnBold(" ");
	iPrintLnBold(" ");
	iPrintLnBold("The winner is");
	iPrintLnBold("^2" + mapname);

	if(level.mapvotegametype && (mapname != "replay this map" && mapname != "mystery map"))
		iPrintLnBold("^2" + getGametypeName(gametype));
	else
		iPrintLnBold(" ");
	
	level.vote_hud_timeleft fadeOverTime(1);	
	level.vote_hud_instructions fadeOverTime(1);
	level.vote_map1 fadeOverTime(1);
	level.vote_map2 fadeOverTime(1);
	level.vote_map3 fadeOverTime(1);
	level.vote_map4 fadeOverTime(1);
	level.vote_map5 fadeOverTime(1);
	level.vote_hud_bgnd fadeOverTime(1);
	level.vote_header fadeOverTime(1);
	level.vote_leftline fadeOverTime(1);
	level.vote_rightline fadeOverTime(1);
	level.vote_bottomline fadeOverTime(1);

	level.vote_hud_timeleft.alpha = 0;	
	level.vote_hud_instructions.alpha = 0;
	level.vote_map1.alpha = 0;
	level.vote_map2.alpha = 0;
	level.vote_map3.alpha = 0;
	level.vote_map4.alpha = 0;
	level.vote_map5.alpha = 0;
	level.vote_hud_bgnd.alpha = 0;
	level.vote_header.alpha = 0;
	level.vote_leftline.alpha = 0;
	level.vote_rightline.alpha = 0;
	level.vote_bottomline.alpha = 0;
	
	level notify("voting_map_difficulty"); // tmp for Cheese's hud to also fade

	players = getEntArray("player", "classname");
	
	for(i = 0; i < players.size; i++) {
		if(isDefined(players[i].vote_indicator)) {
			players[i].vote_indicator fadeOverTime(1);
			players[i].vote_indicator.alpha = 0;
		}
	}

	wait 4;
	
	level notify("voting_complete");
}

playerVote()
{
	level endon("voting_done");
	self endon("disconnect");
  
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
  
	resettimeout();
  
	self setClientCvar("g_scriptMainMenu", "");
	self closeMenu();
	
	colors[0] = (0  ,  0,  1);
	colors[1] = (0  ,0.5,  1);
	colors[2] = (0  ,  1,  1);
	colors[3] = (0  ,  1,0.5);
	colors[4] = (0  ,  1,  0);

	self.vote_indicator = newClientHudElem( self );
	self.vote_indicator.alignY = "middle";
	self.vote_indicator.x = 208;
	self.vote_indicator.y = level.mapvotehudoffset + 75;
	self.vote_indicator.archived = false;
	self.vote_indicator.sort = 9998;
	self.vote_indicator.alpha = 0;
	self.vote_indicator.color = colors[0];
	self.vote_indicator setShader("white", 254, 17);

	hasVoted = false;
	
	for(;;) {
		wait 0.01;
	
		if(self attackButtonPressed()) {
			if(!hasVoted) {
				self.vote_indicator.alpha = 0.3;
				self.votechoice = 0;
				hasVoted = true;
			} else {
				self.votechoice++;
			}
      
			if(self.votechoice >= 5)
				self.votechoice = 0;
			
			if(level.mapvotegametype && (level.mapcandidate[self.votechoice]["mapname"] != "replay this map" && level.mapcandidate[self.votechoice]["mapname"] != "mystery map"))
				self iPrintLn("You have voted for ^2" + jumpmod\functions::strTru(level.mapcandidate[self.votechoice]["mapname"], 13) + " ^7(" + level.mapcandidate[self.votechoice]["gametype"] + ")");
			else
				self iPrintLn("You have voted for ^2" + jumpmod\functions::strTru(level.mapcandidate[self.votechoice]["mapname"], 13));
       
			self.vote_indicator.y = level.mapvotehudoffset + 77 + self.votechoice * 16;			
			self.vote_indicator.color = colors[self.votechoice];
			
			if(level.mapvotesound)
				self playLocalSound("hq_score"); // training_good_grenade_throw
		}
    
		while(self attackButtonPressed())
			wait 0.01;
      
		self.sessionstate = "spectator";
		self.spectatorclient = -1;
	}
}

displayMapChoices()
{
	level endon("voting_done");
	for(;;) {
		for(i = 0; i < 5; i++) {
			if(level.mapvotegametype && (level.mapcandidate[i]["mapname"] != "replay this map" && level.mapcandidate[i]["mapname"] != "mystery map"))
				iPrintLnBold(jumpmod\functions::strTru(level.mapcandidate[i]["mapname"], 13) + " (" + level.mapcandidate[i]["gametype"] +")");
			else
				iPrintLnBold(jumpmod\functions::strTru(level.mapcandidate[i]["mapname"], 13));
		}

		wait 7.8;
	}	
}

getRandomMapRotation()
{
	if(getCvar("sv_mapRotation") != "")
		mapRotation = jumpmod\functions::strip(getCvar("sv_mapRotation"));
	else
		return undefined;

	for(i = 1; /* /!\ */; i++) {
		if(getCvar("sv_mapRotation" + i) != "")
			mapRotation = mapRotation + " " + jumpmod\functions::strip(getCvar("sv_mapRotation" + i));
		else
			break;
	}

	mapRotation = jumpmod\functions::strTok(mapRotation, " ");

	if(!isDefined(mapRotation))
		return undefined;

	_tmp = [];
	for(i = 0; i < mapRotation.size; i++) {
		arrElem = jumpmod\functions::strip(mapRotation[i]);
		if(arrElem != "")
			_tmp[_tmp.size] = arrElem; 
	}
  
	mapRotation = _tmp;

	if(!isDefined(mapRotation))
		return undefined;

	if(jumpmod\functions::in_array(mapRotation, level.fmmapname))
		mapRotation = jumpmod\functions::array_remove(mapRotation, level.fmmapname, true);
	
	// tmp_fm_mapvotebanlist "mp_harbor mp_brecourt mp_hurtgen mp_railyard mp_ship mp_dawnville"
	if(level.mapvotebans > 0) {
		mapBanList = jumpmod\functions::strTok(getCvar("tmp_fm_mapvotebanlist"), " ");
		
		for(i = 0; i < mapBanList.size; i++) {
			if(i < level.mapvotebans)
				mapRotation = jumpmod\functions::array_remove(mapRotation, mapBanList[i], true);
			else
				break;
		}
		
	}

	_tmp = [];
	lastgt = level.fmgametype;
	for(i = 0; i < mapRotation.size;/* /!\ */) {
		switch(mapRotation[i]) {
			case "gametype":
				if((i + 1) < mapRotation.size) //if(isDefined(mapRotation[i + 1]))
					lastgt = mapRotation[i + 1];
        
				i += 2;
			break;
			case "map":
				if((i + 1) < mapRotation.size) { //if(isDefined(mapRotation[i + 1])) {
					_tmp[_tmp.size]["gametype"] = lastgt;
					_tmp[_tmp.size - 1]["map"]  = mapRotation[i + 1];
				}
        
				i += 2;
			break;
			default:
				iPrintLnBold("^1WARNING: ^7Error(s) detected in map rotation.");
				i += 1;
			break;
		}
	} 

	return jumpmod\functions::array_shuffle(_tmp);
}

getGametypeName(gt)
{
	switch(gt) {
		case "dm": gtname = "Deathmatch"; break;
		case "tdm": gtname = "Team Deathmatch"; break;
		case "sd": gtname = "Search & Destroy"; break;
		case "re": gtname = "Retrieval"; break;
		case "jmp": gtname = "Jump"; break;
		default: gtname = gt; break;
	}

	return gtname;
}

get_map_difficulty(mapname) {
	return maps\MP\gametypes\jmp::mapdifficulty(mapname);
}

// get_map_difficulty( map ) { // Cheese

// 	switch ( map ) {
// 		// easy
// 		case "cj_cow":
// 		case "cj_hallwayofdoom":
// 		case "cp_easy_jump":
// 		case "ct_aztec":
// 		case "dan_jumpv3":
// 		case "dv_mr_yoshi":
// 		case "fm_squishydeath_easy":
// 		case "jm_crispy":
// 		case "jm_destov1":
// 		case "jm_hollywood":
// 		case "jm_infiniti":
// 		case "jm_motion_light":
// 		case "jm_rikku":
// 		case "jm_tools":
// 		case "mazeofdeath_easy":
// 		case "mp_jump":
// 		case "nm_castle":
// 		case "nm_jump":
// 		case "nm_race":
// 		case "nm_tower":
// 		case "nm_toybox_easy":
// 		case "nm_treehouse":
// 		case "peds_pace":
// 		case "railyard_jump_light":
// 		case "svb_hallway":
// 		case "vik_jump":
// 		case "zaitroofs":
// 			return "easy";

// 		// medium
// 		case "ch_space":
// 		case "cj_wolfjump":
// 		case "double_vision":
// 		case "groms_skatepark":
// 		case "jm_bounce":
// 		case "jm_ghoti":
// 		case "jm_motion_pro":
// 		case "jm_skys":
// 		case "jm_speed":
// 		case "jm_towering_inferno":
// 		case "jt_dunno":
// 		case "mazeofdeath_hard":
// 		case "mp_bolonga":
// 		case "nev_jumpfacility":
// 		case "nev_namedspace":
// 		case "nm_mansion":
// 		case "nm_portal":
// 		case "nm_toybox_hard":
// 		case "nm_trap":
// 		case "peds_palace":
// 		case "peds_parkour":
// 		case "son-of-bitch":
// 		case "svb_darkblade":
// 		case "wacked":
// 		case "zaittower2":
// 		case "jm_alienattack":
// 			return "med";

// 		// hard
// 		case "bitch":
// 		case "ch_quickie":
// 		case "fm_squishydeath_hard":
// 		case "funjump":
// 		case "hardjump":
// 		case "jm_canonjump":
// 		case "jm_castle":
// 		case "jm_factory":
// 		case "jm_fear":
// 		case "jm_foundry":
// 		case "jm_gap":
// 		case "jm_lockover":
// 		case "jm_maniacmansion":
// 		case "jumping-falls":
// 		case "kn_angry":
// 		case "krime_pyramid":
// 		case "mazeofdeath_vhard":
// 		case "nev_codered":
// 		case "starship":
// 		case "svt_xmas_v2":
// 			return "hard";

// 		// expert
// 		case "cp_sirens_call":
// 		case "nev_templeofposeidonv2":
// 		case "railyard_jump_ultra":
// 			return "expert";

// 		// easy/hard
// 		case "svb_marathon":
// 			return "easy/hard";

// 		// all skill levels
// 		case "svb_rage":
// 		case "ultra_gap_training":
// 			return "all";

// 		default:
// 		break;
// 	}
    
// 	var = level.mapdifficulty;
// 	if ( var != "" ) {
// 		tmp = jumpmod\functions::strTok( var, ";" );
        
// 		for ( i = 0; i < tmp.size; i++ ) {
// 			info = jumpmod\functions::strTok( tmp[ i ], "," );
// 			if ( info.size != 2 )
// 				continue;
			
// 			name = info[ 0 ];
// 			difficulty = info[ 1 ];
		    
// 			if ( name == map )
// 				return difficulty;
// 		}
// 	}

// 	return "unknown";
// }

set_map_difficulties() { // Cheese
	/*level.map_difficulty = newHudElem();
	level.map_difficulty.archived = false;
	level.map_difficulty.x = 474;
	level.map_difficulty.y = level.mapvotehudoffset + 56;
	level.map_difficulty.sort = 9998;
	level.map_difficulty.fontscale = 1;
	level.map_difficulty setText( &"Map Difficulty:" );*/

	level.mapdifficulties = [];
    
	for ( i = 0; i < 5; i++ ) {
		tmp = newHudElem();
		tmp.archived = false;
		tmp.x = 474;
		tmp.y = level.mapvotehudoffset + 69 + ( 16 * i );
		tmp.sort = 9998;
        
		info = level.mapcandidate[ i ];
        
		text = &"unknown";
		color = ( 1, 1, 1 );
		switch ( info[ "difficulty" ] ) {
			case "easy":
				text = &"easy";
				color = ( 0.08235, 0.6902, 0.10196 );
			break;
			case "med":
			case "medium":
				text = &"medium";
				color = ( 1.0, 1.0, 0.07843 );
			break;
			case "hard":
				text = &"hard";
				color = ( 0.97647, 0.45098, 0.02353 );
			break;
			case "expert":
				text = &"expert";
				color = ( 0.89804, 0.0, 0.0 );
			break;
			case "easy/hard":
			case "all":
				text = &"all difficulties";
				color = ( 0.58431, 0.81569, 0.98824 );
			break;
		}
        
		tmp setText( text );
		tmp.color = color;
        
		level.mapdifficulties[ i ] = tmp;
	}
    
	level waittill( "voting_map_difficulty" ); // tmp
    
	wait 0.05;
    
	//level.map_difficulty fadeOverTime( 1 );
	//level.map_difficulty.alpha =0;
	for ( i = 0; i < 5; i++ ) {
		level.mapdifficulties[ i ] fadeOverTime( 1 );
		level.mapdifficulties[ i ].alpha = 0;
	}
    
	wait 1;
    
	//level.map_difficulty destroy();
	for ( i = 0; i < 5; i++ ) 
		level.mapdifficulties[ i ] destroy();
}