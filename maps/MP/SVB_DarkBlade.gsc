// SVB_DarkBlade
// Map by sKratch
// Script by sKratch

main()
{
	maps\mp\_load::main();

//	thread soundtrig();

	ambientPlay("SVB_DarkBlade");

	thread tele( "tele1", "auto1" );
	thread tele( "tele2", "auto2" );
	thread tele( "tele3", "auto3" );
	thread tele( "tele4", "auto4" );
	getEnt( "DarkBlade", "targetname" ) thread suparooms( ( -1212, 1766, 72 ), "^5DarkBlade^7" );

	
}

tele( targetname, orgname )
{
	trig = getEnt( targetname, "targetname" );
	org = getEnt( orgname, "targetname" );
	
	while( 1 )
	{
		trig waittill( "trigger", user );
		//iprintln( "triggered by " + user.name );
		user setOrigin( org.origin );
		//iprintln( "teleported to " + org.origin );
		wait 0.5;
	}
}

suparooms( origin, name )
{
	self waittill( "trigger", user );
	
	//if( user getGuid() == 1624472 || user getGuid() == 1378923 || user getGuid() == 1042067 )
		user setOrigin( origin );
	//else
	//	user iPrintLnBold( "You are not " + name + "^7!" );
	
	self thread suparooms( origin, name );
}