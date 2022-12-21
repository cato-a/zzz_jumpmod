_timerStuck() // tip by Jona
{
	if(!isDefined(game["maprestarts"]))
		game["maprestarts"] = 0;

	for(;;) {
		wait 60;

		players = getEntArray("player", "classname");
		if(players.size == 0) {
			if(game["maprestarts"] > 7) {
				level notify("end_map"); // idea is to just rotate the map
				return;
			}

			game["maprestarts"]++;
			map_restart(true); // true playerinfo retained
		} else {
			if(game["maprestarts"] != 0)
				game["maprestarts"] = 0;
		}
	}
}

welcome_display()
{
	level endon("end_map");

	pID = self getEntityNumber();
	getGreets = jumpmod\functions::strTok(getCvar("tmp_mm_welcomemessages"), ";"); // get cvar to array (14;19;23;11;20...)

	if(!jumpmod\functions::in_array(getGreets, pID)) {
		addID = pID; // create a variable with all welcome message id's

		for(i = 0; i < getGreets.size; i++)
			addID += ";" + getGreets[i]; // generate the string of id's that is already greeted

		setCvar("tmp_mm_welcomemessages", addID); // add all the generated id's to a cvar for later use

		for(i = 1; /* /!\ */; i++) {
			if(getCvar("scr_mm_welcome" + i) != "") {
				if(i == 1)
					self iPrintLnBold(getCvar("scr_mm_welcome" + i) + " " + jumpmod\functions::namefix(self.name));
				else
					self iPrintLnBold(getCvar("scr_mm_welcome" + i));

				wait 6;
			} else {
				if(i > 1) // do 1 more check, just to see if the server admin want to disable the first message containing player name
					break; // end the loop
			}
		}
	}
}

welcome_remove()
{
	pID = self getEntityNumber();
	getGreets = jumpmod\functions::strTok(getCvar("tmp_mm_welcomemessages"), ";");

	if(jumpmod\functions::in_array(getGreets, pID)) {
		delWelcome = jumpmod\functions::array_remove(getGreets, pID);

		rID = "";

		for(i = 0; i < delWelcome.size; i++) {
			rID += delWelcome[i];
			rID += ";";
		}

		setCvar("tmp_mm_welcomemessages", rID);
	}
}