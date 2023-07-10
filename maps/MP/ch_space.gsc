/************************************ 
 Ch_space 
 by Cheese
 
 Why are you reading the script? Trying to find 
 the secrets, eh? Well tough luck bud. Unless you
 have a real good knowledge of vectors in 3d planes,
 you ain't gonna find anything useful in here.
 
 But if you are a scripter (like me :D) then you
 might find something of value in my stuff. I don't
 comment on much of my stuff so don't be surprised.
 
 Version log:
 	v1 ~
 		Created script
 		Added gate() and start()
 		Music not working right :/
 	v1.1 ~
 		Added more crap
 		Music works, but doesn't loop :(
 	v1.2 ~
 		Added a crapload of stuff
 		Added teleporters for secrets :D
 		Came up with recursive functions for most everything
 		Finally fixed music, now it loops! woo
 	v1.3 ~
 		Added more secrets, more recursion
 		Added moving objects (cool little things)
 		Added even more secrets. Super secrets, actually.
 		Changed some stuff so it works better
 		Added more secrets. I'm obsessed with secrets. Especially ones you don't know about :D
 		Added this version log lol... dunno why
 		Added... you guessed it... more secrets. I win at that ;)
 	v1.4 ~
 		Changed the music to only play once, but added a feature
 		so that you can turn it back on in the SUPA SECRET area :D
 		Changed the seats in the secret so they work correctly
 		Fixed some other glitches with secrets :D
 		Added ability to toggle secrets on/off ;)
 		Added more teleporters :D
 	v1.5 ~
 		So much crap added.
 		Added "secret rooms" for Nevander and I
 		Other cool crap
		Added "secret room" for sKratch
		FINISHED MAP FINALLY! jeez
************************************/

main() 
{
	maps\mp\_load::main();
	
	level.green = loadFx( "fx/cheese/green.efx" );
	level.red = loadFx( "fx/cheese/red.efx" );
	level.blue = loadFx( "fx/cheese/blue.efx" );
	level.white = loadFx( "fx/cheese/white.efx" );
	level.purple = loadFx( "fx/cheese/purple.efx" );
	level.yellow = loadFx( "fx/cheese/yellow.efx" );
	
	level.superscode = "123456789";
	level.musicenabled = false;
	level.aybabtu = false;
	level.musicstoppedmanually = false;
	level.secretdisabled = false;
	level.sswallshidden = false;
	level.ssouterfloorsolid = true;

	thread gate();
	thread start();

	seats = getEntArray( "seat", "targetname" );
	for( i = 0; i < seats.size; i++ )
		seats[i] thread seat();
	
	// dirty way :D	
	for( i = 1; i < 8; i++ )
		getEnt( "mover" + i, "targetname" ) thread mover( i );	
		
	for( i = 1; i < 10; i++ )
		getEnt( "superstrig" + i, "targetname" ) thread superstrig( i );
			
	getEnt( "casetrig", "targetname" ) thread casething();
	getEnt( "strig1", "targetname" ) thread signTrigUp();
	getEnt( "strig2", "targetname" ) thread signTrigDn();
	getEnt( "stele1", "targetname" ) thread strig1();
	getEnt( "stele2", "targetname" ) thread strig2();
	getEnt( "tele1", "targetname" ) thread teleporter( ( -1216, 2688, 100 ), ( 0, 0, 0 ), false );
	getEnt( "tele2", "targetname" ) thread teleporter( ( -2240, 1280, -8 ), ( 0, 0, 0 ), false );
	getEnt( "tele3", "targetname" ) thread teleporter( ( 9792, 1920, 2008 ), ( 0, 180, 0 ), false );	
	getEnt( "tele4", "targetname" ) thread teleporter( ( 9792, 1920, 3456 ), ( 0, 180, 0 ), false );
	getEnt( "tele5", "targetname" ) thread teleporter( ( 9248, 3228, 3268 ), ( 0, 270, 0 ), false );
	getEnt( "superstriguse", "targetname" ) thread superstriguse();
	getEnt( "sstele1", "targetname" ) thread teleporter( ( -1216, 2688, 100 ), ( 0, 0, 0 ), true );
	getEnt( "sstele2", "targetname" ) thread teleporter( ( -2240, 1280, -8 ), ( 0, 0, 0 ), true );
	getEnt( "sstele3", "targetname" ) thread teleporter( ( 9792, 1920, 2008 ), ( 0, 180, 0 ), true );	
	getEnt( "sstele4", "targetname" ) thread teleporter( ( 9792, 1920, 3456 ), ( 0, 180, 0 ), true );
	getEnt( "sstele5", "targetname" ) thread teleporter( ( 7488, 3328, 2004 ), ( 0, 0, 0 ), true );
	getEnt( "sstele6", "targetname" ) thread teleporter( ( 5472, 3296, 1888 ), ( 0, 0, 0 ), true );
	getEnt( "sstele7", "targetname" ) thread teleporter( ( 1504, 988, 200 ), ( 0, 0, 0 ), true );
	getEnt( "sstele8", "targetname" ) thread teleporter( ( -128, 1280, 0 ), ( 0, 0, 0 ), true );
	getEnt( "aybabtu", "targetname" ) thread aybabtu();
	getEnt( "ssmusic", "targetname" ) thread ssmusic();
	getEnt( "ssnosecret", "targetname" ) thread ssnosecret();
	getEnt( "sswallshide", "targetname" ) thread sswallshide();
	getEnt( "ssouterwallssolid", "targetname" ) thread ssouterfloorsolid();
	getEnt( "finaldoortrig", "targetname" ) thread final();
	getEnt( "nevroom", "targetname" ) thread suparooms( ( 7424, 160, 3460 ), "^2Nevander" );
	getEnt( "cheeseroom", "targetname" ) thread suparooms( ( 10720, 160, 3460 ), "^3Cheese" );
	getEnt( "skratchroom", "targetname" ) thread suparooms( ( 7424, -932, 3460 ), "^1sKratch^7" );

}

gate() 
{
	trig = getEnt( "gatetrig1", "targetname" );
	gate = getEnt( "gate1", "targetname" );
	
	trig waittill( "trigger" );
	gate movez( 128, 13, 1, 1 );
}

start() 
{
	trig = getEnt( "cage", "targetname" );
	cage = getEnt( "lolcage", "targetname" );
	snd = getEnt( "startsnd", "targetname" );
	parts = getEntArray( "parts", "targetname" );
	
	for( i = 0; i < parts.size; i++ ) 
	{ 
		parts[i] hide(); 
		parts[i] notSolid(); 
	}
		
	trig waittill( "trigger" );
	wait 1;
	iPrintLn( "^5L^7oading... Please wait..." );
	wait 3;
	iPrintLn( "^5D^7one!" );
	wait 1;
	iPrintLnBold( "^5S^7tarting simulation..." );
	snd playSound( "simulation" );
	wait 3;
	
	for( i = 10; i > 0; i-- ) 
	{
		iprintlnbold( randomColor() + i );
		snd playSound( "count" + i );
		wait 1;
	}
	
	musicPlay( "evo" );
	level.musicenabled = true;
	//thread endmusic();
	
	// >:D
	cage delete();
	
	for( i = 0; i < parts.size; i++ ) 
	{ 
		parts[i] show(); 
		parts[i] solid();
	}
}

teleporter( origin, angles, super ) 
{
	self waittill( "trigger", user );
	
	if( !super )
		wait 2;
		
	if( !level.secretdisabled || super )
	{
		if( user isTouching( self ) )
		{
			user setOrigin( origin );
			if( isDefined( angles ) )
				user setPlayerAngles( angles );
		}
	}
	else
		wait 2;
	
	self thread teleporter( origin, angles, super );
}

signTrigUp()
{
	self waittill( "trigger" );
	sign = getEnt( "ssign", "targetname" );
	sign hide();
	sign notSolid();
	
	self thread signTrigUp();
}

signTrigDn()
{
	self waittill( "trigger" );
	sign = getEnt( "ssign", "targetname" );
	sign show();
	sign solid();
	
	self thread signTrigDn();
}

strig1()
{
	self waittill( "trigger", user );
	user.triggerd1 = true;
		
	self thread strig1();
}

strig2()
{
	self waittill( "trigger", user );
	user.triggerd2 = true;
	
	if( !level.secretdisabled && user.triggerd1 && user.triggerd2 )
		user setOrigin( ( -896, 1280, 260 ) );
		
	self thread strig2();
}

seat()
{
	if( !isDefined( self.linked ) )
		self.linked = false;
		
	lolthing = getEnt( self.target, "targetname" );
		
	self waittill( "trigger", user );
	if( self.linked )
	{
		if( user == self.linkedplayer )
		{
			self.linked = false;
			self.linkedplayer = undefined;
			user.linked = undefined;
			user unlink();
			user setClientCvar( "cg_thirdperson", 0 );
			user setOrigin( self.playerstartpos );
		}
		else
			user iPrintLnBold( "Someone is sitting there!" );
	}
	else
	{
		if( !user.linked )
		{
			self.linked = true;
			self.linkedplayer = user;
			user.linked = true;
			self.playerstartpos = user getOrigin();
			user setClientCvar( "cl_stance", 1 );
			user setClientCvar( "cg_thirdperson", 1 );
			user setOrigin( lolthing.origin + ( 0, 0, -16 ) );
			user linkTo( lolthing );
		}
	}
	self thread seat();
}

mover( i )
{
	if( i == 1 || i == 3 || i == 5 )
	{
		self movex( -256, 2 );
		wait 2;
		self movex( 256, 2 );
		wait 2;
	}
	else if( i == 2 || i == 4 || i == 6 )
	{
		self movex( 256, 2 );
		wait 2;
		self movex( -256, 2 );
		wait 2;
	}
	self thread mover( i );
}

casething()
{
	thing = getEnt( "casething", "targetname" );
	self waittill( "trigger" );
	
	wait 1;
	thing movex( -124, 2 );
	wait 7;
	thing movex( 124, 2 );
	wait 2;
	
	self thread casething();
}

superstrig( i ) 
{ 
	self waittill( "trigger", user ); 
	user checkcode(); 
	user.code += i; 
	user iPrintLn( "activated" ); 
	//user iPrintLn( user.code );
	self thread superstrig( i ); 
}

superstriguse()
{
	self waittill( "trigger", user );
	if( !level.secretdisabled && isDefined( user.code ) && user.code == 45 )
	{
		user iPrintLn( "correct code" );
		user setOrigin( ( 9408, 2688, 3472 ) );
	}
	else
	{
		user iPrintLn( "invalid code" );
		user.code = "";
	}
	self thread superstriguse();
}

aybabtu()
{
	self waittill( "trigger", user );
	if( !level.aybabtu )
	{
		if( level.musicenabled )
		{
			level.musicenabled = false;
			musicStop();
			wait 0.05;
		}
		level.aybabtu = true;
		musicPlay( "aybabtu" );
		iPrintLn( "^5A^7ll ^5Y^7our ^5B^7ase ^5A^7re ^5B^7elong ^5T^7o ^5U^7s" );
	}
	else
	{
		level.aybabtu = false;
		musicStop( 1 );
		iPrintLn( "^5W^7HAT ^5U ^5S^7AY !! " );
	}
	self thread aybabtu();
}

ssmusic()
{
	self waittill( "trigger", user );
	if( !level.musicenabled )
	{	
		if( !level.aybabtu )
		{
			level.musicenabled = true;
			musicPlay( "evo" );
			iPrintLn( "^5M^7usic enabled!" );
		}
		else
			iPrintLn( "^5Y^7OU ^5H^7AVE ^5N^7O ^5C^7HANCE ^5T^7O ^5S^7URIVE ^5M^7AKE ^5Y^7OUR ^5T^7IME" );
	}
	else
	{		
		level.musicenabled = false;
		musicStop( 1 );
		iPrintLn( "^5M^7usic disabled!" );
	}
	self thread ssmusic();
}

ssnosecret()
{
	self waittill( "trigger", user );
	if( !level.secretdisabled )
	{
		level.secretdisabled = true;
		iPrintLn( "^5S^7ecret disabled!" );
	}
	else
	{
		level.secretdisabled = false;
		iPrintLn( "^5S^7ecret enabled!" );
	}
	self thread ssnosecret();
}

sswallshide()
{
	self waittill( "trigger", user );
	if( !level.sswallshidden )
	{
		level.sswallshidden = true;
		getEnt( "sswalls", "targetname" ) hide();
		iPrintLn( "^5S^7ecret walls hidden!" );
	}
	else
	{
		level.sswallshidden = false;
		getEnt( "sswalls", "targetname") show();
		iPrintLn( "^5S^7ecret walls shown!" );
	}
	self thread sswallshide();
}

ssouterfloorsolid()
{
	self waittill( "trigger", user );
	if( !level.ssouterfloorsolid )
	{
		level.ssouterfloorsolid = true;
		getEnt( "ssouterwalls", "targetname" ) solid();
		iPrintLn( "^5S^7ecret floor solid!" );
	}
	else
	{
		level.ssouterfloorsolid = false;
		getEnt( "ssouterwalls", "targetname" ) notsolid();
		iPrintLn( "^5S^7ecret floor not solid!" );
	}
	self thread ssouterfloorsolid();
}

final()
{
	self waittill( "trigger" );
	block = getEnt( "finaldoorblock", "targetname" );
	left = getEnt( "finaldoorl", "targetname" );
	right = getEnt( "finaldoorr", "targetname" );
	
	block movex( 8, 2 );
	wait 2;
	block delete();
	left movey( 128, 10 );
	right movey( -128, 10 );
	wait 10;
	self delete();
}

suparooms( origin, name )
{
	self waittill( "trigger", user );
	
	//if( user getGuid() == 1598503 || user getGuid() == 276144 || user getGuid() == 1378923 )
		user setOrigin( origin );
	//else
	//	user iPrintLnBold( "You are not " + name + "^7!" );
	
	self thread suparooms( origin, name );
}
		
checkcode() { if( !isDefined( self.code ) ) { self.code = 0; } }
waittimer() { for( i = 0; i < 306; i++ ) { wait 1; } musicStop( 1 ); wait 1; }
randomColor() { return "^" + ( randomInt( 8 ) + 1 ); }