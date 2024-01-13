//script by megazor
//Some custom sounds, textures and models belong to Valve Software

main()
{
	if (getCvar("crossbow_speed") == "")
	{
		setCvar("crossbow_speed", 5000);	//note that when moving at speed over 5000, it is unable to kill players with 100% probability
		setCvar("crossbow_time", 2);		//reload time
		setCvar("harbor_jump_125fps", 0);	//forcing fps, 0 = off, 1 = on.
	}
	level._effect["fire"] = loadfx ("fx/harbor_jump/smallfire.efx");
	maps\mp\_fx::loopfx("fire", (-9038, -6712, 50), .6);
	maps\mp\_fx::loopfx("fire", (-9061, -6683, 50), .6);
	setCullFog (0, 6500, .8, .8, .8, 0);
	ambientPlay("ambient_mp_harbor");
	//level.allow_ppsh = 1;
	precacheItem("ppsh_mp");
	precacheShader("white");

	getEnt("crossbow_arrow", "targetname").may_spawn = 1;
	level.porntype = 1;
	level.porn = false;
	level.bunker = false;
	level.bunker_doors_moving = false;
	level.code = "";
	level.jump236done = false;
	level.jump236code = randomIntRange(-9999, 10000);
	level.x1 = randomIntRange(-1000, 1001);
	level.x2 = randomIntRange(-1000, 1001);
	level.b = (level.x1+level.x2)*(-1);
	level.c = level.x1*level.x2;
	level.code_number = 1;
	level.usedfigures = [];
	thread open_secret_net("lol");

	for (i = 1; i < 5; i++)
		for (a = 0; a < 10; a++)
			getEnt("keypad"+i+"n"+a, "targetname").origin = (-8, -8, 0);
	getEnt("keypad_minus", "targetname").origin = (-8, -8, 0);
	getEnt("bunker_doors", "targetname").origin = (0, 0, 96);
	getEnt("bunker_doors", "targetname") hide();
	getEnt("bunker_house_door", "targetname") hide();
	getEnt("bunker_windows", "targetname") hide();
	getEnt("bunker_small_windows", "targetname") hide();
	getEnt("bunker_roof", "targetname").origin = (0, 0, -80);
	getEnt("bunker_roof", "targetname") hide();
	getEnt("police_wall", "targetname").origin = (0, -.13, 0); //it narrows the passage (which is situated in the police building) so that the player can hardly get into it.

	getEnt("outmap_building_trig1", "targetname") thread outmap_building_jump();
	getEnt("outmap_building_trig2", "targetname") thread outmap_building_jump();	
	getEnt("anim_tele", "targetname") thread tele();
	getEnt("police_tele", "targetname") thread tele();
	getEnt("porn_trig", "targetname") thread porn();

	thread fps();
	thread bunker_enable();
	thread bunker();
	thread evil_water();
	thread animation();
	thread jump_building();
	thread crossbow_trig();
	thread crossbow_search(getEnt("crossbow", "targetname"), getEnt("crossbow_arrow", "targetname"));

	thread code();
	thread police_secret_room();
	thread code236();
	
	thread catch_players_for_message();

	thread escalator_stuff();
	
	thread bashnjump();
}

bashnjump()
{
	getEnt("bash&jump_trig", "targetname") waittill("trigger");
	getEnt("bash&jump_button", "targetname") moveZ(-4, 2);
	getEnt("bash&jump", "targetname") moveZ(544, 5);
	earthQuake(1, 6, (-8790, -7388, 64), 512);
	wait 5;
	iPrintLnBold("^3BASH^7&^3J^7UMP");
	wait 3;
	iPrintLnBold(";-)");
}

escalator_stuff()
{
	level.esc_time = .05;
	//setCvar("esc_time", level.esc_time);

	steps = getEntArray("step", "targetname");
	for (i = 0; i < steps.size; i++)	//26 steps
	{
		steps[i] thread steps(1);
		wait level.esc_time;
	}
	wait 1;

	level.esc_time = 1;
	level.esc_speed = 5;
	getEnt("esc_speed_"+level.esc_speed, "targetname").origin = (0, 8.01, 0);
	getEnt("esc_speed_plus", "targetname") thread esc_speed("plus");
	getEnt("esc_speed_minus", "targetname") thread esc_speed("minus");

	//thread haha();
}

esc_speed(method)
{
	self waittill("trigger", user);
	if (user.origin[1] < -8280.88)
	{
		self thread esc_speed(method);
		return;
	}

	getEnt("esc_speed_"+level.esc_speed, "targetname").origin = (0, 0, 0);

	if (method == "plus")
	{
		level.esc_speed++;
		if (level.esc_speed == 11)
			level.esc_speed = 0;	
	}

	else if (method == "minus")
	{
		level.esc_speed--;
		if (level.esc_speed == -1)
			level.esc_speed = 10;
	}

	if (level.esc_speed == 1)
		level.esc_time = 16;
	if (level.esc_speed == 2)
		level.esc_time = 8;
	if (level.esc_speed == 3)
		level.esc_time = 4;
	if (level.esc_speed == 4)
		level.esc_time = 2;
	if (level.esc_speed == 5)
		level.esc_time = 1;
	if (level.esc_speed == 6)
		level.esc_time = .8;
	if (level.esc_speed == 7)
		level.esc_time = .6;
	if (level.esc_speed == 8)
		level.esc_time = .4;
	if (level.esc_speed == 9)
		level.esc_time = .2;
	if (level.esc_speed == 10)
		level.esc_time = .1;
	
	if (isDefined(level.esc_stop))
		level.esc_stop = undefined;

	if (level.esc_speed == 0)
		level.esc_stop = 1;

	getEnt("esc_speed_"+level.esc_speed, "targetname").origin = (0, 8.01, 0);

	self thread esc_speed(method);
}

steps(flag)
{
	if (flag)
	{
		self moveTo((0, 0, -24), .05);	//moveTo is a more accurate method than setting an origin
		wait .05;
	}

	for (i = 0; i < 3; i++)
	{
		while (isDefined(level.esc_stop))	// To stop the escalator, I had to use this stupid code
		{				// I tried many different variants and only this one worked
			self moveTo(self.origin, .05);
			wait .05;
		}
		self moveY(-17, level.esc_time);
		wait level.esc_time;	//the waittill() function doesn't work properly as it causes short pauses between motions
	}

	d = -2;
	lol = .125;
	for (i = 1; i < 5; i++)
	{
		if (i > 1)
		{
			d = (i-1)*(-4);
			lol = (i-1)*.25;
		}

		while (isDefined(level.esc_stop))
		{
			self moveTo(self.origin, .05);
			wait .05;
		}
		self moveTo(self.origin+(0, lol-17, d), level.esc_time);
		wait level.esc_time;
	}

	while (isDefined(level.esc_stop))
	{
		self moveTo(self.origin, .05);
		wait .05;
	}

	self moveTo(self.origin+(0, -192, -192), level.esc_time*12);
	count = 0;
	for (i = 0; i < 12; i++)
	{
		count++;
		oldtime = level.esc_time;
		//wait level.esc_time;
		if (level.esc_time != oldtime || isDefined(level.esc_stop))
		{
			while (isDefined(level.esc_stop))
			{
				self moveTo(self.origin, .05);
				wait .05;
			}
			//self moveTo(self.origin+(0, -192+(count*16), -192+(count*16)), level.esc_time*(12-count));
		}
	}

	for (i = 4; i > 0; i--)
	{
		if (i > 1)
		{
			d = (i-1)*(-4);
			lol = (i-1)*.25;
		}
		else
		{
			d = -2;
			lol = .125;
		}

		while (isDefined(level.esc_stop))
		{
			self moveTo(self.origin, .05);
			wait .05;
		}
		self moveTo(self.origin+(0, lol-17, d), level.esc_time);
		wait level.esc_time;
	}

	for (i = 0; i < 3; i++)
	{
		while (isDefined(level.esc_stop))
		{
			self moveTo(self.origin, .05);
			wait .05;
		}
		self moveY(-17, level.esc_time);
		wait level.esc_time;
	}

	while (isDefined(level.esc_stop))
	{
		self moveTo(self.origin, .05);
		wait .05;
	}
	self.origin = (0, 0, -24);
	self thread steps(0);
}	

catch_players_for_message()
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		if (!isDefined(players[i].harbor_jump_joined))
		{
			players[i].harbor_jump_joined = 1;
			players[i] thread message_galileo();
		}
	wait 10;
	thread catch_players_for_message();
}

message_galileo()
{
	/*
	menu = "harbor_jump_non-existent_menu";
	response = "harbor_jump_non-existent_response";
	while (isPlayer(self) && menu != game["menu_quickresponses"] && response != 7)
	{
		if (!isDefined(self.firsttime_galileo))
		{
			self notify ("menuresponse", "harbor_jump_non-existent_menu", "harbor_jump_non-existent_response");
			self.firsttime_galileo = 1;
		}
	}
	*/

	//the code above was replacing 'you're nuts' quick message (v3-7) with my own message, 'galileo'
	//the code below does the same, but you will sometimes hear the original message (whereas the code above didn't have this problem)
	//but at last, I decided not to use it, cause it was a 'dirty' way

	self waittill("menuresponse", menu, response);

	if (self.sessionstate == "playing" && isDefined(self.pers["team"]) && self.pers["team"] == "allies" && menu == game["menu_quickresponses"] && response == 7 && !isDefined(self.spamdelay))
	{
		self.firsttime_galileo = 1;
		self.spamdelay = true;
		self thread message_galileo();
		if (game["allies"] == "russian")
			saytext = &"QUICKMESSAGE_YOURE_CRAZY";
		else if (game["allies"] == "british")
			saytext = &"QUICKMESSAGE_YOURE_CRAZY";
		else
		{
			temp = randomInt(3);
			if (temp == 0)
				saytext = &"QUICKMESSAGE_YOURE_CRAZY";
			else if (temp == 1)
				saytext = &"QUICKMESSAGE_YOU_OUTTA_YOUR_MIND";
			else
				saytext = &"QUICKMESSAGE_YOURE_NUTS";
		}
		self maps\mp\gametypes\_teams::saveHeadIcon();
		self thread maps\mp\gametypes\_teams::doQuickMessage("galileo", saytext);
		wait 2;
		self maps\mp\gametypes\_teams::restoreHeadIcon();
		self.spamdelay = undefined;
	}
	else
		self thread message_galileo();
}

open_secret_net(i)
{
	trig = getEnt("secret_keypad_net_trig", "targetname");
	button = getEnt("secret_keypad_net_trig_button", "targetname");
	net = getEnt("secret_keypad_net", "targetname");

	if (i == "back")
	{
		button moveZ (10, 1);
		button waittill ("movedone");
		net moveX (20, 1);
		net waittill ("movedone");
	}
	
	trig waittill ("trigger", user);
	if (user.origin[1] < -8080 && user.origin[2] > 484)	//i. e. the player has run the trigger when being on the sink
	{
		button moveZ (-10, 1);
		button waittill ("movedone");
		net moveX (-20, 1);
		net waittill ("movedone");
	}
	else	//triggered from a different place, from example from the ground
		thread open_secret_net("lol");
}

code()
{
	getEnt("code_c", "targetname") thread checkTrig("delete");
	getEnt("code_neg", "targetname") thread checkTrig("neg-pos");
	for (i = 0; i < 10; i++)
		getEnt("code_"+i, "targetname") thread checkTrig(i);
}

checkTrig(i)
{
	offset = (-8, -8, 0);	//local coordinates
	self waittill ("trigger");
	
	if (!isDefined(level.secret_door_opened))
	{
		if (i == "delete" && level.code != "")
		{
			if (level.code[0] == "-")
				getEnt("keypad_minus", "targetname").origin = offset;
			for (a = 0; a < level.usedfigures.size; a++)
				level.usedfigures[a].origin = offset;
			level.code = "";
			level.usedfigures = [];
			level.code_number = 1;
		}
		else if (i == "neg-pos" && level.code != "" && level.code[0] != 0)
		{
			if (level.code[0] != "-")
			{
				level.code = "-"+level.code;
				getEnt("keypad_minus", "targetname").origin = (2*level.code_number-8, .01, 0);
			}
			else
			{
				tempcode = "";
				for (a = 1; a < level.code.size; a++)
					tempcode += level.code[a];
				level.code = tempcode;
				getEnt("keypad_minus", "targetname").origin = offset;
			}
		}

		else if (i != "delete" && i != "neg-pos" && level.code_number <= 4)
		{
			level.code += i;
			if (level.code[0] == "-")
				getEnt("keypad_minus", "targetname").origin += (2, 0, 0);
			if (level.code_number > 1)
				for (a = 0; a < level.usedfigures.size; a++)
					level.usedfigures[a].origin += (2, 0, 0);

			figure = getEnt("keypad"+level.code_number+"n"+i, "targetname");
			figure.origin = (2*level.code_number-8, .01, 0);
			level.usedfigures[level.usedfigures.size] = figure;
			level.code_number++;
		}
	}
	self thread checkTrig(i);
}

police_secret_room()
{
	offset = (-8, -8, 0);
	trig = getEnt("police_secret_room", "targetname");
	trig waittill ("trigger", user);

	if (isDefined(level.secret_door_opened) || level.code == level.jump236code || level.code == level.x1 || level.code == level.x2)
	{
		if (!isDefined(level.secret_door_opened))
		{
			level.secret_door_opened = 1;
			level.porntype = 2;		
			if (level.code[0] == "-")
				getEnt("keypad_minus", "targetname").origin = offset;
			for (a = 0; a < level.usedfigures.size; a++)
				level.usedfigures[a].origin = offset;
			level.code = "";
			level.usedfigures = [];
			level.code_number = 1;
			thread restart_door(user);
		}
		user thread spawnme();
	}

	else
	{	
		if (level.code == "")
		{
			user iPrintLn("Solve the quadratic equation: x*x + "+level.b+"x + "+level.c+" = 0");	//haha, now people who don't know maths can't get into the secret room!
			user iPrintLn("Or just do the ^1gap jump ^7on the roof");
		}
		else
		{
			user iPrintLnBold("^1Wrong! ^7Study some maths or jump harder");
			user iPrintLn("x*x + "+level.b+"x + "+level.c+" = 0");
			if (level.code[0] == "-")
				getEnt("keypad_minus", "targetname").origin = offset;
			for (a = 0; a < level.usedfigures.size; a++)
				level.usedfigures[a].origin = offset;
			level.code = "";
			level.usedfigures = [];
			level.code_number = 1;
		}					
	}
	thread police_secret_room();
}

spawnme()
{
	self iPrintLnBold ("^2Access Granted");
	bla = spawn("script_origin", (0, 0, 0));
	vector = (-9784, -8656, 416) - self.origin;
	self linkTo(bla);
	bla moveTo(vector, 2);
	bla waittill ("movedone");
	bla delete();
	if (isDefined(level.secret_door_opened))
		level waittill ("door closed - new codes generated");
}

restart_door(firstplayer)
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		if (players[i].sessionstate == "playing" && players[i] != firstplayer && players[i] isTouching(getEnt("police_3rd_floor", "targetname")) )
			players[i] iPrintLnBold("You have got ^27 ^7seconds to enter the ^3Secret ^7Room!");
	wait 5;
	thread open_secret_net("back");
	level.porntype = 1;
	wait 2;
	level.code = "";
	level.code_number = 1;
	level.usedfigures = [];
	level.x1 = randomIntRange(-1000, 1001);
	level.x2 = randomIntRange(-1000, 1001);
	level.b = (level.x1+level.x2)*(-1);
	level.c = level.x1*level.x2;
	level.jump236done = false;
	level.jump236code = randomIntRange(-9999, 10000);
	level notify ("door closed - new codes generated");
	level.secret_door_opened = undefined;
}

porn()	//the map has the second version :-)
{
	scale = .8;
	origin = (-8840, -7664, 48);	// the center of the map
	radius = 20000;		//covers the map completely
	
	self waittill ("trigger", user);

	//if ( user getGuid() == 1039383 || user getGuid() == 1530203 )	// rgs
	if(user.name.size >= 3 && user.name[0] == "r" && user.name[1] == "g" && user.name[2] == "s")
	{
		if (!level.bunker)
		{
			level.porn = true;
			porn = getEnt("porn"+level.porntype, "targetname");
			iPrintlnBold ("The ^6Porn ^7Version of Harbor Jump is being loaded...");
			porn.origin += (0, 0, 640);
			wait 2;
			duration = 7;
			earthQuake (scale, duration, origin, radius);
			porn thread bunker_check_motion(1664, 7);
			porn moveZ (1024, 7);
			porn waittill ("movedone");
			iPrintLnBold ("Successfully loaded! Have fun or get banned!");

			self waittill ("trigger");
			iPrintlnBold ("The ^5Normal ^7Version of Harbor Jump is being loaded...");
			wait 2;
			duration = 6;
			earthQuake (scale, duration, origin, radius);
			porn thread bunker_check_motion(640, 6);
			porn moveZ (-1024, 6);
			porn waittill ("movedone");
			porn.origin += (0, 0, -640);
			iPrintLnBold ("Successfully loaded! Have fun or get banned!");
			level.porn = false;
			wait 60;
		}
		else if (!isDefined(user.mayTouchAgain))
		{
			user iPrintLnBold("Don't do it while the Bunker Mode");
			user.mayTouchAgain = false;
			user thread stopTrig(self);
		}
	}
	else
	{
		user playSound( "melee_hit" );
		user finishPlayerDamage( self, self, 10, 2, "MOD_MELEE", "panzerfaust_mp", self.origin, self.origin, "head", 0 );
	}

	self thread porn();
}

bunker_enable()
{
	trig = getEnt("bunker_enable_trigger", "targetname");
	button = getEnt("bunker_enable_button", "targetname");
	wall = getEnt("bunker_enable_wall", "targetname");
	wall.origin += (0, 0, 12);
	button.origin -=(48, 0, 0);
	trig waittill("trigger", user);
	button moveX(-4, 1, 0, .2);
	button waittill("movedone");
	wall moveZ(-12, 2, 0, .2);
	wall waittill ("movedone");
	level notify ("bunker enabled");
	iPrintLnBold("The ^1Bunker Button ^7has been ^2enabled");
	trig delete();
	button delete();
}
	

bunker()
{
	arrow = getEnt("bunker_arrow", "targetname");
	button = getEnt("bunker_button", "targetname");
	net = getEnt ("bunker_net", "targetname");
	doors = getEnt ("bunker_doors", "targetname");
	house_door = getEnt ("bunker_house_door", "targetname");
	house_door_notsolid = getEnt ("bunker_house_door_notsolid", "targetname");
	windows = getEnt ("bunker_windows", "targetname");
	small_windows = getEnt ("bunker_small_windows", "targetname");
	roof = getEnt ("bunker_roof", "targetname");
	trig = getEnt ("bunker_trig", "targetname");
	bunker = getEnt ("bunker", "targetname");
	
	if (!isDefined(level.bunker_enabled))
	{
		level.bunker_enabled = 1;
		level.bunker_new = 1;
		level waittill("bunker enabled");
	}
	
	if (isDefined(level.bunker_new))
	{
		b = spawn("script_model", (-10528, -8272, 184));	
		level.bunker_new = undefined;
		arrow rotatePitch(180, 180);
		arrow waittill("rotatedone");
		b playsound("buttonmove");
		net moveY (-50, 1);
		net waittill ("movedone");
		b playsound("buttonstop");
		wait .5;
		button moveZ (6, .5);
		button waittill ("movedone");
		b delete();
	}

	trig waittill ("trigger", user);
	if (!level.porn)
	{
		level.bunker = true;
		level.bunker_doors_moving = true;
		thread bunker_button();
		thread bunker_doors_and_roof_door_kill();
		thread bunker_sound();
		thread bunker_loopsound();	//the sound of moving doors is looping
		doors thread bunker_motion(10, -96, 20);
		windows thread bunker_motion(32, -64, .5);
		small_windows thread bunker_motion(10, -68, .5);
		roof thread bunker_motion_roof(10, 176, 20);
		house_door thread bunker_motion_roof(32, 168, .5, house_door_notsolid); 
		thread bunker_window_kill();
		thread bunker_door_glitchers_kill(1);	//this function kills players that do jump-crouch-jump glitch (which stops the doors)
		wait 37.7;

		earthquake(1, 4, (-8840, -7664, 48), 10000);

		flash = newHudElem();
		flash.archived = false;
		flash.x = 0;
		flash.y = 0;
		flash setShader("white", 640, 480);

		players = getEntArray ("player", "classname");
		for (i = 0; i < players.size; i++)	
			if (players[i].sessionstate == "playing" && !players[i] isTouching(bunker))
				players[i] suicide();
		wait .3;

		flash fadeOverTime(3);
		flash.alpha = 0;
		wait 3;

		flash destroy();
		wait 2;

		level notify ("time to play return sounds");
		doors notify ("time to return");
		windows notify ("time to return");
		small_windows notify ("time to return");
		roof notify ("time to return");
		house_door notify ("time to return");
		level.bunker_doors_moving = false;
		wait 20;
		level.bunker = false;
		level.bunker_new = 1;
	}

	else if (!isDefined(user.mayTouchAgain))
	{
		user iPrintLnBold("Don't do it while the Porn Version");
		user.mayTouchAgain = false;
		user thread stopTrig(trig);
	}
	thread bunker();
}

bunker_button()
{
	arrow = getEnt("bunker_arrow", "targetname");
	button = getEnt ("bunker_button", "targetname");
	net = getEnt ("bunker_net", "targetname");
	wait .5;
	arrow rotatePitch(-180, 1);
	button moveZ (-6, .5);
	button waittill ("movedone");
	wait .5;
	net moveY (50, 1);
	net waittill ("movedone");
	//wait 175.5;
}

bunker_sound()
{
	button = spawn("script_model", (-10528, -8272, 184));
	windows[0] = spawn("script_model", (-10416, -8264, 136));
	windows[1] = spawn("script_model", (-9480, -8696, 376));
	windows[2] = spawn("script_model", (-9480, -8168, 376));
	small_windows[0] = spawn("script_model", (-9864, -7840, 384));
	small_windows[1] = spawn("script_model", (-10096, -8088, 384));
	small_windows[2] = spawn("script_model", (-10104, -8816, 384));

	MusicPlay("siren");

	wait 1.5;
	button playsound("buttonmove");
	wait 1;
	button playsound("buttonstop");

	wait 8.3;
	for (i = 0; i < 3; i++)
		small_windows[i] playsound("windows2");

	wait 19.3;
	MusicStop();
	musicPlay("prebang");
	wait 2;
	for (i = 0; i < 3; i++)
		windows[i] playsound("windows2");
	wait 5.6;
	musicStop();
	
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		players[i] playLocalSound("bang1");	//everyone must hear that :-)
		players[i] playLocalSound("bang2");
	}
	
	level waittill ("time to play return sounds");
	for (i = 0; i < 3; i++)
	{
		windows[i] playsound("windows2");
		small_windows[i] playsound("windows2");
	}
	wait .05;
	for (i = 0; i < 3; i++)
	{
		windows[i] delete();
		small_windows[i] delete();
	}
	button delete();
}

bunker_loopsound()
{
	doors[0] = spawn ("script_model", (-9584, -7864, 56));
	doors[1] = spawn ("script_model", (-9520, -8768, 56));
	doors[2] = spawn ("script_model", (-10088, -8224, 56));

	wait 10;
	for (i = 0; i < 13; i++)
	{
		for (j = 0; j < doors.size; j++)
			doors[j] playsound("door");
		wait 1.6;
	}
	level waittill ("time to play return sounds");
	for (i = 0; i < 12; i++)
	{
		for (j = 0; j < doors.size; j++)
			doors[j] playsound("door");
		wait 1.6;
	}
	wait .05;
	for (i = 0; i < 3; i++)
		doors[i] delete();
}

bunker_motion(delay, z, time)
{
	wait delay;
	self show();
	dir = self.origin[2]+z;
	self thread bunker_check_motion(dir, time);	//if the door is not in the given point (stopped by a player, though it will happen hardly ever), it immediately spawns there.
	switch(self.targetname)
	{
		case "bunker_small_windows":
		level notify("bunker small windows going down");
		break;
		
		case "bunker_windows":
		level notify("bunker windows going down");
		break;
	
		default:
		break;
	}
	self moveZ (z, time);
	wait time;
	
	self waittill ("time to return");
	self thread bunker_check_motion(dir-z, time);
	self moveZ (z*(-1), time);
	self waittill ("movedone");
	wait .05;
	self hide();
}

bunker_motion_roof(delay, x, time, door)
{
	wait delay;
	self show();
	self thread bunker_check_motion_roof(x, time);
	self moveX (x, time);
	if (delay == 32)
	{
		wait .1;
		for (a = 0; a < 8; a++)
		{ 		
			players = getEntArray ("player", "classname");		
			for (i = 0; i < players.size; i++)
				if (players[i].sessionstate == "playing" && players[i] isTouching(door))
					players[i] suicide();
		wait .05;
		}
	}
	self waittill ("time to return");
	self thread bunker_check_motion_roof(0, time);
	self moveX (x*(-1), time);
	self waittill ("movedone");
	wait .05;
	self hide();
}

bunker_check_motion(number, time)
{
	wait time+.05;
	if (self.origin[2] != number)
	{
		self.origin = (0, 0, number);
		self notify ("movedone");
	}
}

bunker_check_motion_roof(number, time)
{
	wait time+.05;
	if (self.origin[0] != number)
	{
		self.origin = (number, 0, -80);
		self notify ("movedone");
	}
}

bunker_door_glitchers_kill(flag)
{
	if (flag)
		level waittill("bunker doors going down");

	if (!level.bunker)
		return;

	players = getEntArray ("player", "classname");		
	for (i = 0; i < players.size; i++)
	{
		if (players[i].sessionstate == "playing" && !players[i] isOnGround())
		{
			if (isDefined(players[i].bunker_door_pos) && players[i].bunker_door_pos == players[i].origin)
			{
				players[i] suicide();
				players[i].bunker_door_pos = undefined;
			}

			else if (players[i].origin[0] > -9620 && players[i].origin[0] < -9545 && players[i].origin[1] > -7885.13 && players[i].origin[1] < -7850.88 && players[i].origin[2] < 100)
				players[i].bunker_door_pos = players[i].origin;
			else if (players[i].origin[0] > -9541.13 && players[i].origin[0] < -9506.88 && players[i].origin[1] > -8814 && players[i].origin[1] < -8728 && players[i].origin[2] < 100)
				players[i].bunker_door_pos = players[i].origin;
			else if (players[i].origin[0] > -10086.1 && players[i].origin[0] < -10049.9 && players[i].origin[1] > -8316 && players[i].origin[1] < -8132 && players[i].origin[2] < 100)
				players[i].bunker_door_pos = players[i].origin;
		}
	}
	wait .05;
	thread bunker_door_glitchers_kill(0);
}

bunker_window_kill()
{
	level waittill("bunker small windows going down");

	for (x = 0; x < 10; x++)
	{
		players = getEntArray ("player", "classname");		
		for (i = 0; i < players.size; i++)
		{
			if (players[i].sessionstate != "playing")
				continue;

			org = players[i].origin;
			if (org[0] > -10032 && org[0] < -9695 && org[1] > -7886.13 && org[1] < -7848.88 && org[2] > 268 && org[2] < 514)
				players[i] suicide();
			else if (org[0] > -10087.1 && org[0] < -10048.9 && org[1] > -8898 && org[1] < -7914 && org[2] > 200 && org[2] < 514)
				players[i] suicide();
		}
	wait .05;
	}

	level waittill("bunker windows going down");

	for (x = 0; x < 10; x++)
	{
		players = getEntArray ("player", "classname");		
		for (i = 0; i < players.size; i++)
		{
			org = players[i].origin;
			if (players[i].sessionstate == "playing" && org[0] > -9542.13 && org[0] < -9505.88 && org[1] > -8924 && org[1] < -7936 && org[2] > 200 && org[2] < 514)
				players[i] suicide();
		}
	wait .05;
	}
}
				
bunker_doors_and_roof_door_kill()
{
	if (!level.bunker_doors_moving)
		return;

	roof = getEnt ("bunker_roof", "targetname");
	stones = getEnt ("bunker_roof_boom", "targetname");
	doors = getEnt ("bunker_doors", "targetname");	

	players = getEntArray ("player", "classname");		
	for (i = 0; i < players.size; i++)
		if (players[i].sessionstate == "playing")
			if ( (players[i] isOnGround() && players[i] isTouching(doors) ) || (players[i] isTouching(roof) && players[i] isTouching(stones)) )
				players[i] suicide();
	wait .05;
	thread bunker_doors_and_roof_door_kill();
}

evil_water()	//people can't swim, therefore they die after getting into the water
{
	water = getEnt ("evil_water", "targetname");
	water waittill("trigger", user);
	if (user.sessionstate == "playing" && !isDefined(user.isDrowning))
	{
		user.isDrowning = true;
		user thread drown();
	}
	thread evil_water();
}

drown()
{
	lol = spawn("script_origin", self.origin);
	self linkTo(lol);
	org = self.origin;
	wait .5;
	lol moveZ(-80, 5);

	if (isPlayer(self) && self.sessionstate == "playing")
	{
		wait .05;
		if (self.origin[0] == org[0] && self.origin[1] == org[1] && self.origin[2] <= org[2])
			self dropItem(self getCurrentWeapon());
	}
	else
	{
		if (isPlayer(self))
			self.isDrowning = undefined;
		lol delete();
		return;
	}
	x = 39;
	for (i = 0; i < 98; i++)
	{
		if (!isPlayer(self) || self.sessionstate != "playing" || (self.origin[0] != org[0] || self.origin[1] != org[1] || self.origin[2] > org[2]))
		{
			lol delete();
			correctly = 0;
			break;
		}

		x++;
		if (x == 40)
		{
			num = randomIntRange(1, 16);
			self playsound ("drown"+num);
			x = 0;
		}
		else if (self getCurrentWeapon() != "none")
			self dropItem(self getCurrentWeapon());
	wait .05;
	}

	if (isPlayer(self) && self.sessionstate == "playing" && !isDefined(correctly))
	{
		self suicide();
		iPrintLnBold("Haha, "+self.name+" ^7has just ^1drowned ^7in the ^4sea");
	}
	if (isDefined(lol))
		lol delete();
	if (isPlayer(self))
		self.isDrowning = undefined;
}

animation()	//(c) megazor, blablabla, neverlol. lol, there are no copyrights for ideas. but, anyway, (c). ok? ok. goodbye.
{
	t = getEnt("anim_play", "targetname");
	a = getEnt("animation", "targetname");
	f = 0;
	
	t waittill ("trigger");
		
	for (; f < 228; )
	{
		a.origin += (0, 110, 0);
		f++;
			
		if (f == 1) wait 4;
		else if (f == 104 || f == 222 || f == 223) wait 1;
		else if (f == 11 || f == 61) wait .8;
		else if (f == 71 || f == 128 || f == 154 || f == 159 || f == 227) wait .5;
		else if (f == 2 || f == 17 || f == 29 || f == 60 || f == 91 || f == 139 || f == 173 || f == 181 || f == 191) wait .4;
		else if (f == 16 || f == 20 || f == 72 || f == 92 || (f >= 99 && f <= 103) || f == 160 || (f >= 185 && f <= 187) || f == 190) wait .3;
		else if (f == 10 || (f >= 21 && f <= 28) || (f >= 53 && f <= 59) || (f >= 62 && f <= 65) || f == 105 || f == 140 || f == 141 || (f >= 161 && f <= 172) || (f >= 182 && f <= 184) || f == 221 || (f >= 224 && f <= 226) ) wait .2;
		else if ( (f >= 3 && f <= 9) || (f >= 12 && f <= 15) || (f >= 37 && f <= 46) || (f >= 129 && f <= 138) || (f >= 142 && f <= 153) || (f >= 188 && f <= 189) ) wait .15;
		else if (f >= 107 && f <= 127) wait .05;
		else if ( (f >= 178 && f <= 180) || (f >= 192 && f <= 220) ) wait .05;
		else if (f == 228) wait 2;	
		else wait .1;
	}
	a.origin = (0, 0, 0);
	thread animation();
}

crossbow_trig()	//crossbow functions were the most difficult to write
{	
	trig = getEnt("crossbow_trig", "targetname");
	trig waittill("trigger", user);
	saved_origin = user.origin;
	level.crossbow_InUse = true;
	level.crossbow_canshoot = undefined;
	level.crossbow_newshoot = undefined;
	gun = getEnt("crossbow", "targetname");
	arrow = getEnt("crossbow_arrow", "targetname");
	gun.origin = (0, 0, -10000);
	trig.origin = (0, 0, -10000);
	arrow.saved_origin = (0, 0, -10000);
	if (isDefined(arrow.may_spawn))
		arrow.origin = arrow.saved_origin;
	user iPrintLn("You've picked up the ^1Crossbow");
	user iPrintLn("Hold ^5Use ^7to set it");

	hold = 0;
	while (isPlayer(user) && user.sessionstate == "playing" && user useButtonPressed())
	{
		saved_origin = user.origin;
		wait .05;
	}
	while (1)	//holding Use button for 1 second?
	{
		if (!isPlayer(user) || user.sessionstate != "playing")
			break;
		if (user useButtonPressed())
			hold++;
		else
		{
			if (hold >= 20)
				break; 
			hold = 0;
		}
		saved_origin = user.origin;
	wait .05;
	}

	if (!isPlayer(user) || user.sessionstate != "playing")	//if player disconnected, was killed, joined spectators, drop crossbow at the place the player disappeared
	{
		trace = BulletTrace(saved_origin, saved_origin-(0, 0, 10000), false, undefined);	//always spawn crossbow on the ground
		saved_origin = trace["position"];

		trig.origin = saved_origin;
		gun.origin = saved_origin;
		gun.angles = (0, 0, 0);
		trig.angles = (0, 0, 0);
		arrow.saved_origin = saved_origin+(28, 0, 6.7);
		arrow.saved_angles = (0, 0, 0);
		if (isDefined(arrow.may_spawn))
		{
			arrow.origin = arrow.saved_origin;
			arrow.angles = arrow.saved_angles;
			//arrow.saved_origin = undefined;
		}
		thread crossbow_trig();
		return;
	}			
		
	if (!user isOnGround())
	{
		trace = BulletTrace(user.origin, user.origin-(0, 0, 10000), false, undefined);
		org = trace["position"];
	}
	else org = user.origin;

	trig.origin = org;
	gun.origin = org;
	gun.angles = (0, 0, 0);
	trig.angles = (0, 0, 0);

	level.crossbow_InUse = undefined;
	thread crossbow_trig();

	if (isDefined(level.crossbow_InUse))	//just in case, idk if it may happen so fast
		return;	

	if (!isDefined(arrow.may_spawn))	//dont spawn arrow while its moving
	{
		arrow.saved_origin = org+(28, 0, 6.7);
		arrow.saved_angles = (0, 0, 0);
		wait .05;
	
		while(!isDefined(arrow.may_spawn))
		{
			if (isDefined(level.crossbow_InUse))
				return;
			wait .05;
		}
	}

	else
	{
		arrow.saved_origin = undefined;
		arrow.angles = (0, 0, 0);
		arrow.origin = org+(28, 0, 6.7);
	}

	wait 1;
	if (isDefined(level.crossbow_InUse))
		return;
	level.crossbow_newshoot = 1;
	level.crossbow_canshoot = 1;
}

crossbow_search(gun, arrow)	//search for visible players; if any, choose the closest one; aim at him 
{
	if (!isDefined(level.crossbow_canshoot) || !isDefined(level.crossbow_newshoot))
	{
		wait .05;
		thread crossbow_search(gun, arrow);
		return;
	}

	visibleplayers = [];
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		if (players[i].sessionstate != "playing")
			continue;

		p1 = gun.origin;
		p2 = players[i] getBody();
		trace = BulletTrace(p1, p2, false, undefined);
		if (trace["surfacetype"] == "none" && distance(p2, gun.origin) > distance(arrow.origin, gun.origin))
		{
			visibleplayers[visibleplayers.size] = players[i];
			players[i].crossbow_point = p2;
		}
		else
		{
			points = players[i] getPlayerEdges(gun.origin);
			for (a = 0; a < points.size; a++)
			{
				trace = BulletTrace(p1, points[a], false, undefined);
				if (trace["surfacetype"] == "none" && distance(points[a], gun.origin) > distance(arrow.origin, gun.origin))
				{
					visibleplayers[visibleplayers.size] = players[i];
					players[i].crossbow_point = points[a];
					break;
				}		
			}
		}
	}

	for (i = 0; i < visibleplayers.size; i++)	//find the closest player of visible ones
	{
		if (!isDefined(d))
		{
			d = distance(gun.origin, visibleplayers[i].origin);
			player = visibleplayers[i];
			point = players[i].crossbow_point;	
		}
		else if (d > distance(gun.origin, visibleplayers[i].origin))
		{
			d = distance(gun.origin, visibleplayers[i].origin);
			player = visibleplayers[i];
			point = players[i].crossbow_point;
		}
	}	
	d = undefined;

	if (isDefined(player))	//found the closest player to shoot at
	{
		ang1 = vectorToAngles(point - gun.origin);		//some maths :-)
		ang2 = acos(6.7/distance(point, gun.origin));	//if you know an easier way to make the crossbow aim at a player, tell me it via xfire (mega9317)
		ang = ang1[0]-ang2;
		arrow.origin = gun.origin + maps\mp\_utility::vectorScale(anglesToForward((ang, ang1[1], 0)), 6.7);
		norm = maps\mp\_utility::vectorScale( (point - arrow.origin), 1.00/distance(point, arrow.origin));
		arrow.origin = arrow.origin + maps\mp\_utility::vectorScale(norm, 28);
		arrow.saved_origin = arrow.origin;
		arrow.angles = vectorToAngles(point-arrow.origin);
		arrow.saved_angles = arrow.angles;
		gun.angles = arrow.angles;
		thread shoot(arrow, point);
		player = undefined;
	}

	wait .05;
	thread crossbow_search(gun, arrow);		
}

shoot(arrow, point)
{	
	//iprintln("shoot");
	level.crossbow_newshoot = undefined;
	arrow.may_spawn = undefined;
	//wait 5;
	arrowhead = maps\mp\_utility::vectorScale(AnglesToForward(arrow.angles), 4+randomInt(15));
	trace = bulletTrace(point, point+maps\mp\_utility::vectorScale(AnglesToForward(arrow.angles), 20000), false, undefined);
	d = distance(arrow.origin, trace["position"]-arrowhead);
	if (d < 10) d = 10;

	if (getCvarFloat("crossbow_speed") < .05) setCvar("crossbow_speed", .05);
	time = (float)d/getCvarFloat("crossbow_speed");
		if (time < .05) time = .05;

	arrow.flying = 1;
	thread catch_players(arrow);
	arrow playsound("cbow_fire");
	arrow moveTo(trace["position"]-arrowhead, time);
	//arrow waittill("movedone");
	wait time;
	arrow.flying = undefined;
	arrow playsound("cbow_hit"+randomIntRange(1, 3));

	time = getCvarFloat("crossbow_time");
	if (time < .1) time = .1;
	wait time;
	if (isDefined(arrow.saved_origin))
	{
		//iprintln("shoot function, set origin");
		arrow.origin = arrow.saved_origin;
		arrow.angles = arrow.saved_angles;
	}
	arrow.may_spawn = 1;
	level.crossbow_time = time;
	wait time/2.00;
	//iprintln("new shot, shoot");
	if (isDefined(arrow.may_spawn))
		level.crossbow_newshoot = 1;
}

catch_players(arrow)
{
	if (!isDefined(arrow.flying))
		return;

	scale = getCvarInt("crossbow_speed")/25;
	if (scale <= 0) scale = 1;
	p1= arrow.origin-maps\mp\_utility::vectorScale(AnglesToForward(arrow.angles), scale*2);
	p2 = arrow.origin+maps\mp\_utility::vectorScale(AnglesToForward(arrow.angles), 19+scale);
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{	
		trace = BulletTrace(p1, p2, true, arrow);
		if (isDefined(trace["entity"]))
		{
			p1 = trace["position"];
			if (isPlayer(trace["entity"]) && trace["entity"].sessionstate == "playing")
			{
				trace["entity"] playsound("cbow_hitbody"+randomIntRange(1, 3));
				trace["entity"] suicide();
			}
		}
		else break;
	}

	wait .05;
	thread catch_players(arrow);
}

getBody()
{
	//s = self getStance();
	if (!isDefined(s)) return self.origin;
	if (s == "stand") return self.origin+(0, 0, 45);
	if (s == "crouch") return self.origin+(0, 0, 25);
	return self.origin+(0, 0, 7);
}

stopTrig(ent)
{
	if (isPlayer(self) && self isTouching(ent) && self.sessionstate == "playing")
	{
		wait .05;
		self thread stopTrig(ent);
		return;
	}
	wait .05;
	if (isPlayer(self) && (!self isTouching(ent) || self.sessionstate != "playing") )
		self.mayTouchAgain = undefined;
	else if (isPlayer(self) && self.sessionstate == "playing") self thread stopTrig(ent);
}

tele()
{
	self waittill ("trigger", user);

	if (self == getEnt("police_tele", "targetname"))
	{
		user setPlayerAngles((0, 0, 0));
		user setOrigin((-21104, -15296, 48));
	}
	else
	{
		user setPlayerAngles((0, 0, 0));
		user setOrigin((-10000, -8144, 472));
	}

	self thread tele();
}

outmap_building_jump()	//if the player jumps to the horizontal platfrom, the script kills them; however, if the player gets longer, to the slope surface, them don't get killed...
{
	self waittill("trigger", user);
	if (user.sessionstate == "playing")
	{
		if (self == getEnt("outmap_building_trig1", "targetname"))
			user.oldhealth = user.health;

		else if (isDefined(user.oldhealth) && user.health < user.oldhealth)
			user suicide();
		else
			user.oldhealth = undefined;
	}
	self thread outmap_building_jump();
}

jump_building()
{
	trig = getEnt ("jump_building_trig", "targetname");
	trig waittill("trigger", user);
	if (user.sessionstate == "playing" && !isDefined(user.jumpBuildingMessage) && !isDefined(user.saved_origin))
	{
		user.jumpBuildingMessage = true;
		user iPrintLnBold ("Wow, you're fucking good at jumping");
		players = getEntArray("player", "classname");		
		for (i = 0; i < players.size; i++)
			if (players[i] != user)
				players[i] iPrintLnBold(user.name+" ^7has climbed up the ^1Great ^8Broken ^7Building!");
	}
	thread jump_building();
}

code236()
{
	trig = getEnt("jump236_trig", "targetname");
	trig waittill("trigger", user);
	if (user.sessionstate == "playing" && !isDefined(user.MayTouchAgain))
	{
		user iPrintLnBold ("Jump Code: ^1"+level.jump236code);
		user.mayTouchAgain = false;
		user thread stopTrig(trig);
	}
	thread code236();
}

fps()	//the forcing fps function: the map is supposed to jump on with 125 fps.
{
	if (!getCvar("harbor_jump_125fps"))
	{
		wait 5;
		thread fps();
		return;
	}

	places = getEnt("125places", "targetname");
	players = getEntArray("player", "classname");		
	for (i = 0; i < players.size; i++)
		if (players[i].sessionstate == "playing" && !players[i] isOnGround() && players[i] isTouching(places))
		{
			players[i] setClientCvar("r_swapinterval", 0);
			players[i] setClientCvar("com_maxfps", 125);
		}

	wait .05;
	thread fps();
}

getPlayerEdges(startpoint)
{
	edges = [];
	//stance = self getStance();
	body = self getBody();
	angles = vectorToAngles(body - startpoint);
	angles = (0, angles[1], 0);
	if (stance == "crouch" || stance == "stand")
	{
		vector = anglesToForward(angles + (0, 90, 0));
		vector = maps\mp\_utility::vectorScale(vector, 10);
		vector = vector + body;
		edges[edges.size] = vector;
		
		vector = anglesToForward(angles - (0, 90, 0));
		vector = maps\mp\_utility::vectorScale(vector, 10);
		vector = vector + body;
		edges[edges.size] = vector;
		
		if (stance == "crouch") head = self.origin+(0, 0, 40);
		else head = self.origin+(0, 0, 60);
		edges[edges.size] = head;

		leg = anglesToForward(angles + (0, 90, 0));
		leg = maps\mp\_utility::vectorScale(leg, 10);
		leg = leg + self.origin + (0, 0, 1);
		edges[edges.size] = leg;

		leg = anglesToForward(angles - (0, 90, 0));
		leg = maps\mp\_utility::vectorScale(leg, 10);
		leg = leg + self.origin + (0, 0, 1);
		edges[edges.size] = leg;

	}
	else 
	{
		vector = anglesToForward(self.angles);

		legs = maps\mp\_utility::vectorScale(vector, -60) + self.origin + (0, 0, 3);
		edges[edges.size] = legs;

		body = maps\mp\_utility::vectorScale(vector, -30) + self.origin + (0, 0, 6);
		edges[edges.size] = body;

		head = self.origin + (0, 0, 7);
		edges[edges.size] = head;
	}
	return edges;
}