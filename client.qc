
// prototypes
void () W_WeaponFrame;
void () W_SetCurrentAmmo;
void () player_pain;
void () player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;
void (entity client, float fragval) client_frag; // ELOHIM_MOD

//float   modelindex_eyes, modelindex_player; // ELOHIM_MOD - moved to defs

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

//float	intermission_running;  // ELOHIM_MOD - moved to elodefs.qc
//float	intermission_exittime; // ELOHIM_MOD - moved to elodefs.qc

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};

void() SetNewParms2;

void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms2 ();
		return;
	}

// remove items
	self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
	
// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;

	// ELOHIM_MOD - parms10-13 contains elohim player flags
	parm10 = self.style;			// player flags
	parm11 = self.elohim_player_id;		// Sputnik: changed was self.state; // player ID
	parm12 = self.oflags;			// CRMOD observer flags
	parm13 = self.crmod_hack_count;		// hack count / admin level
	parm14 = time - self.last_active; 
	// END_MOD
    
	// ELO ratings
	parm15 = self.rating;
	parm16 = self.fights;
};

//
// ELOHIM_MOD
//
// Created SetNewParms2 and changed all SetNewParms references to
// SetNewParms2.  SetNewParms is called by Quake.exe when a client
// first connects; SetNewParms2 is called thereafter by the QuakeC
// code every time the client is reinserted into the server (respawn,
// level change, etc.)
//
// Also created SetPracticeParms which is called for practice mode
//

void() SetPracticeParms =
{
	parm1 = IT_SHOTGUN | IT_AXE | IT_ROCKET_LAUNCHER | IT_ARMOR3 | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_GRENADE_LAUNCHER | IT_LIGHTNING | IT_SUPER_NAILGUN | IT_ARMOR3;

	if (elohim_arena_health)
		parm2 = elohim_arena_health;
	else
		parm2 = 100;
	parm3 = 200;
	parm4 = 100;
	parm5 = 200;
	parm6 = 100;
	parm7 = 100;
	parm8 = 32;
	parm9 = 80.001;
};

//
//  Called by Quake server when a new client connects
//
void() SetNewParms =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
	parm10 = ELOHIM_NEW_CLIENT;	// CRMOD observer flags moved | ELOHIM_OBSERVER_WALK; // elohim player flags
	parm11 = 0;			// player ID.. will be set by elohim_client_connect
	parm12 = OBSERVER_WALK;		// CRMOD observer flags
	parm13 = 0;			// crmod_hack_count
	if (elohim_playmode & ELOHIM_PRACTICE_MODE)
	   SetPracticeParms();
	parm15 = 1000; // ELO ratings (initial rating)
	parm16 = 0;    // ELO ratings (# fights)
};

//
//  Called by QuakeC to reset a clients parameters
//
void() SetNewParms2 =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
	parm10 = self.style; // elohim player flags
	parm11 = self.elohim_player_id;	//Sputnik: changed was self.state; // player ID
	parm12 = self.oflags; // CRMOD observer flags
	parm13 = self.crmod_hack_count;
	if (elohim_playmode & ELOHIM_PRACTICE_MODE)
		SetPracticeParms();
	parm15 = self.rating; // ELO ratings (rating)
	parm16 = self.fights; // ELO ratings (# fights)
};	
// END_MOD

void() DecodeLevelParms =
{
	//
	// ELOHIM_MOD
	//
	// First restore player elohim flags *then* check to see if level = start.
	// Also, reset player status at start level even if serverflags = 0.
	// Finally, reset status if fresh spawns are on.
	// Changed SetNewParms to SetNewParms2.
	self.style		= parm10;
	self.elohim_player_id	= parm11;	//Sputnik: was self.state
	self.oflags		= parm12;	// CRMOD observer flags
	self.crmod_hack_count	= parm13;
	self.last_active	= time - parm14;
	self.rating		= parm15;	// ELO ratings (rating)
	self.fights		= parm16;	// ELO ratings (# fights)

	if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
	{
		if (world.model == "maps/start.bsp" || (elohim_playmode & ELOHIM_FRESH_SPAWNS))
			SetNewParms2 ();   // take away all stuff on starting new episode
	}
	// END_MOD
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
};


//string nextmap; // ELOHIM_MOD - moved this to elohim.qc
void() GotoNextMap =
{
    if (cvar("samelevel") & 1)  // if samelevel is set, stay on same level
		changelevel (mapname);
	else
    {
        // ELOHIM_MOD - check for start0/start1
        if (nextmap == "start0")
        {
            serverflags = 0;
            changelevel("start");
        }
        else if (nextmap == "start1")
        {
            serverflags = 15;
            changelevel("start");
        }
        else
            changelevel(nextmap);
        // END_MOD
    }
};

// ELOHIM_MOD - replaced all occurences of ExitIntermission with GotoNextMap
/*
void() ExitIntermission =
{
// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}

		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
		
	}

	GotoNextMap();
};
*/

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	// ELOHIM_MOD - hack for autoss to work
	if (!(self.style & ELOHIM_OBSERVER) || (self.style & ELOHIM_ADMINISTRATOR))
	{
		self.v_angle = self.angles = crmod_angle;
		self.fixangle = TRUE;
	}
	// END_MOD

	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button2) // CRMOD - got rid of button1
		return;

	GotoNextMap ();  // ELOHIM_MOD  ExitIntermission -> GotoNextMap
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;

// ELOHIM_MOD - deathmatch is never zero
// enforce a wait time before allowing changelevel
//	if (deathmatch)
        intermission_exittime = time + 5;
//	else
//		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();
	crmod_angle = pos.mangle;	// ELOHIM_MOD

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.finaldest_y = other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

    WriteByte (MSG_ALL, SVC_INTERMISSION);
};

// ELOHIM_MOD - added this safeguard in case levels.cfg is being used
void () pre_execute_changelevel = 
{
	if (elohim_levelcount == -1)
		execute_changelevel();
	else
		self.nextthink = time + 0.1;
};
// END_MOD

void() changelevel_touch =
{
	local entity	pos;

	// ELOHIM_MOD - do nothing in match mode
	if (elohim_playmode & ELOHIM_MATCH_MODE)
		return;
	// END_MOD

	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	// ELOHIM_MOD - make sure we're done with levels.cfg
	if (elohim_levelcount != -1)
	{
		if (self.enemy != other)
		{
			stuffcmd(other, "play misc/talk.wav\n");
			sprint(other, "Exits not yet activated\n");
		}
		self.enemy = other;
		return;
	}
	// END_MOD
    
	gameover = TRUE;  // ELOHIM_MOD - so that clients can't suicide during intermission

// ELOHIM_MOD - deathmatch is never zero; use announce instead
/*
    if (coop || deathmatch) 
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}
*/
	announce2(other.netname, " exited the level");

	if (nextmap == "")	// ELOHIM_MOD - added this check in case levels.cfg is used
		nextmap = self.map;

	SUB_UseTargets ();

/*  ELOHIM_MOD - always have intermission
	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
*/
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = pre_execute_changelevel;  // ELOHIM_MOD - changed to "pre"
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
        objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
    // ELOHIM_MOD - coop not supported
    /*
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}
	else
    */
    // END_MOD

// ELOHIM_MOD - deathmatch is never zero
//  if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);

        // ELOHIM_MOD - changed SetNewParms to SetNewParms2
		// set default spawn parms
        SetNewParms2 ();
        // END_MOD
		// respawn		
		PutClientInServer ();
	}
//	else
//	{	// restart the entire server
//		localcmd ("restart\n");
//	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
    // ELOHIM_MOD
    // if intermission, do nothing
    if (gameover)
        return;

    // observers can't suicide
    if (self.style & ELOHIM_OBSERVER)
        return;

	utils_increment_developer(); // CRMOD - for dprints

    // check for maximum number of suicides (except for arena mode)
	if (elohim_client_suicide() == ELOHIM_TOO_MANY_SUICIDES)
	{
		utils_decrement_developer(); // CRMOD - for dprints
		return;
	}
	// END_MOD

	announce2(self.netname, " suicides");  // ELOHIM_MOD - use announce instead
	//bprint (self.netname);
	//bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;

    // ELOHIM_MOD
    //
    // - use client_frag so that penalty will be added to team score
    // - changed penalty to -1
    // - no penalty during pre-match
    // - add suicide to stats
    //
    //self.frags = self.frags - 2;    // extra penalty
	if (!(elohim_playmode & ELOHIM_MATCH_MODE) || elohim_state & ELOHIM_MATCH_STARTED)
	{
		client_frag(self, -1);
		self.mangle_x = self.mangle_x + 1;
	}
    // END_MOD

	if (self.items & IT_ROCKET_LAUNCHER)  // ELOHIM_MOD - keep track of RLs
		quaketv_lost_rl(self);

	utils_decrement_developer(); // CRMOD - for dprints
	
	// ELOHIM_MOD
	// check for not-ready non-observers in match mode; also count rl's
	if (elohim_playmode & ELOHIM_MATCH_MODE)
	{
		if (!(self.style & (ELOHIM_READY | ELOHIM_OBSERVER)))
		{
			// This is a hack!
			self.style = self.style | ELOHIM_READY;
			respawn();
			self.style = self.style - ELOHIM_READY;
			return;
		}
	}
	// END_MOD

	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local	entity thing;
	local	float  pcount;

	// ELOHIM_MOD - don't want this
	/*	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	*/
	// END_MOD
		
// choose a info_player_deathmatch point
    // ELOHIM_MOD - coop not supported
    /*
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else
    */
    // END_MOD

//  if (deathmatch)  // ELOHIM_MOD - deathmatch is never zero
	{
        // ELOHIM_MOD
        //
        // replaced this whole section with code to find a random
        // spawn point. 
        //

        pcount = random() * (elohim_num_spawns - 0.001);
        pcount = floor(pcount);
        spot = find(world, classname, "info_player_deathmatch");
        while (pcount > 0)
        {
            spot = find(spot, classname, "info_player_deathmatch");
			if (spot != world)
				pcount = pcount - 1;
        }
        lastspawn = spot;
		while (1)
		{
			if (spot != world)
			{
                if (spot == self.trigger_field)
                    pcount = 1;
                else
                {
                    thing = findradius(spot.origin, 128); // ELOHIM_MOD 32 => 128
                    while(thing)
                    {
                        if ((thing.classname == "player") && (thing.style & ELOHIM_CONNECTED) && !(thing.style & ELOHIM_OBSERVER))//Sputnik: should also check for thing.health?
						{
                            pcount = 1;
							thing = world;
						}
						else
							thing = thing.chain;
                    }
                }
				if (pcount == 0)
					return spot;
				pcount = 0;
			}

			spot = find(spot, classname, "info_player_deathmatch"); 
            if (spot == lastspawn)
            {
                // Can't find a spot!
				// Check self.trigger_field one last time
				pcount = 0;
                thing = findradius(self.trigger_field.origin, 128); 
                while(thing)
                {
                    if ((thing.classname == "player") && (thing.style & ELOHIM_CONNECTED) && !(thing.style & ELOHIM_OBSERVER))
					{
                        pcount = 1;
						thing = world;
					}
					else
						thing = thing.chain;
                }
				if (pcount == 0)
					return self.trigger_field;
                return lastspawn;
            }
		}
        // END_MOD
	}

//the below will never be reached...
	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}
	
	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");
	
	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
	local	entity spot;

	utils_increment_developer(); // CRMOD - for dprints

	spot = SelectSpawnPoint ();
	
	self.trigger_field = spot;  // ELOHIM_MOD

	DecodeLevelParms ();

	if (self.style & ELOHIM_NEW_CLIENT) // the connect was not successful
		return;

	self.classname = "player";
	self.takedamage = DAMAGE_AIM;    
	self.solid = SOLID_SLIDEBOX;
	self.finaldest_y = self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;

// paustime is set by teleporters to keep the player from moving a while
//  self.pausetime = 0; // ELOHIM_MOD - unused
	
//	spot = SelectSpawnPoint ();

	setorigin(self, spot.origin + '0 0 1');//Sputnik: update our origin and relink out edict.
	self.oldorigin = self.origin;//Sputnik: update oldorigin so we dont respawn where we died.

	self.angles = self.v_angle = spot.angles; //Sputnik: update v_angle too.
	self.fixangle = TRUE;		// turn this way immediately
    self.velocity = '0 0 0'; // ELOHIM_MOD - bugfix

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

    // player_stand1 (); // ELOHIM_MOD - moved to elohim_put_client_in_server
      
    /* CRMOD jp told me too :) n (prevent observers from making fog)
    if (deathmatch || coop)
    {
        makevectors(self.v_angle);
        spawn_tfog (self.origin + v_forward*20);
    }
	*/
	
    // spawn_tdeath (self.origin, self); // ELOHIM_MOD - moved to Elohim.qc

    // ELOHIM_MOD
    // Add elohim specific stuff
    elohim_put_client_in_server();
    // END_MOD

	utils_decrement_developer(); // CRMOD - for dprints
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
    elohim_num_spawns = elohim_num_spawns + 1;  // ELOHIM_MOD
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
    remove(self);   // ELOHIM_MOD - coop not supported
};

/*
===============================================================================

RULES

===============================================================================
*/

//
// ELOHIM_MOD
//
// Fixed the bug that causes the start level to loop.  Changed the sequence
// of levels to:
//
// start->episode1->start->episode2->start->episode3->start->episode4->
// start->end->deathmatch->deathmatch->deathmatch->deathmatch->start
//
// (one big loop.. first start = last start).
// (of course, deathmatch = dm1->dm2->dm3->dm4->dm5->dm6)
//
// Included the Underearth in episode 2, but NOT Ziggurat Vertigo in e1.
//

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
            serverflags = serverflags | 8;
		}
        else
            mapname = "end";

		o = spawn();
		o.map = mapname;
	}
    else if (mapname == "end")
    {
        o = spawn();
        o.map = "dm1";
    }
    else if (mapname == "dm6")
    {
        o = spawn();
        serverflags = (serverflags & 14) / 2;
        if (serverflags > 0)
            o.map = "dm1";
        else
            o.map = "start";
    }
    else if (mapname == "e2m3")
    {
        o = spawn();
        o.map = "e2m7";
    }
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	if (nextmap == "")	// ELOHIM_MOD - added this check
		nextmap = o.map;
	gameover = TRUE;

    o.think = execute_changelevel;
    o.nextthink = time + 0.1;
};
// END_MOD

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
// ELOHIM_MOD - this function was removed for efficiency
/*
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
    if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
        NextLevel ();
		return;
	}	
};
*/

//============================================================================

void() PlayerDeathThink =
{
	local entity	old_self;
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (!self.button2)						// CRMOD - added this
			self.deadflag = DEAD_DEAD_NOJUMP;	// CRMOD - added this
		if (self.button2 || self.button0) // CRMOD - got rid of button1
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}
	else if ((self.deadflag == DEAD_DEAD_NOJUMP) && (!self.button2))	// CRMOD - added this clause
	{
		if (self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button0) // CRMOD - got rid of button1
		return;

	self.button0 = 0;
	// self.button1 = 0;  // CRMOD - not needed
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	local vector start, end;
	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
            if (random() < 0.5)
                sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
            else
                sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

    //self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	//self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	//CRMOD - this is more efficient
	self.flags = self.flags - FL_JUMPRELEASED - FL_ONGROUND;
	self.finaldest_x = time;  // CRMOD - player is alive
	
	self.button2 = 0;
// player jumping sound
    sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
//.float	dmgtime;  // CRMOD - moved to defs.qc

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	// ELOHIM_MOD - don't think these are needed
	//if (self.movetype == MOVETYPE_NOCLIP)
	//	return;
	//if (self.health < 0)
	//	return;
	// END_MOD

	// ELOHIM_MOD - if !self.waterlevel then FL_INWATER must be set
	// or this wouldn't be called.  Moved this test to the start of
	// the function.
	if (!self.waterlevel)
	{
		//if (self.flags & FL_INWATER)
		//{
            sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		//}
		return;
	}
	// END_MOD

	if ( !(self.flags & FL_INWATER) )  // ELOHIM_MOD - moved this test
	{	
// player enter water sound

        if (self.watertype == CONTENT_LAVA)
            sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
        if (self.watertype == CONTENT_WATER)
            sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
        if (self.watertype == CONTENT_SLIME)
            sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;

		// ELOHIM_MOD - added these
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	
	if (self.waterlevel != 3)
	{
        if (self.air_finished < time)
            sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
        else if (self.air_finished < time + 9)
            sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);

		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}
	
	// ELOHIM_MOD - rearranged expression for efficiency
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = (1 - 0.8*self.waterlevel*frametime)*self.velocity;
	// END_MOD

    // ELOHIM_MOD - moved here from PlayerPreThink
	if (self.waterlevel == 2)
		CheckWaterJump ();
    // END_MOD
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist

		// ELOHIM_MOD - replaced these two lines
		//start_z = start_z + self.maxs_z - 8;
		//end = start + v_forward*24;
		start_z = start_z + 24;
		end_z = end_z + 24;
		// END_MOD

		// self.movedir = trace_plane_normal * -50; // ELOHIM_MOD - unused

		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net - DON'T TOUCH!!! USED BY QUAKE.EXE
			// return; ELOHIM_MOD - unnecessary
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	// ELOHIM_MOD - unused
	//local	float	mspeed, aspeed;
	//local	float	r;
	// END_MOD

    // ELOHIM_MOD
    //
    // - moved intermission_running test inside of if (gameover)
    // - go to observer_pre_think when observing
    // - go to options_pre_think when setting options
    // - changed gameover test from (self.view_ofs == '0 0 0') to (gameover)
    // - don't call check rules
    //      - fraglimit, timelimit are set in elohim_start_frame
    //      - timelimit is checked in elohim_start_frame
    //      - fraglimit is checked in client_frag
    // - removed unnecessary makevectors
    // - put dead checks inside a single if statement
    // - removed unused pausetime check
    // - optimized ammo-out check
    // - do periodic checks
    // - moved CheckWaterJump to WaterMove

	if (self.movetype != self.finaldest_y) // dork used admin 0 noclip or fly
		elohim_restore_movetype();

    if (gameover)
    {
		self.style = self.style | ELOHIM_NO_POST_THINK;
        if (intermission_running)
        {
            // otherwise a button could be missed between the think tics
            IntermissionThink ();   
        }
		return;		// intermission or finale
    }

	if (self.colours != self.cl[CL_COLORS])
		match_verify_team();

    if (time > self.wait)
    {
        elohim_periodic_checks();
        self.wait = self.wait + 1;
    }

	if (self.style & ELOHIM_SETTING_OPTIONS)
    {
		self.style = self.style | ELOHIM_NO_POST_THINK;
        options_pre_think();
	    if (elohim_state & ELOHIM_MATCH_PAUSED)
		    self.velocity = '0 0 0';
		if (self.deadflag == DEAD_NO)
		{
			if (self.waterlevel || (self.flags & FL_INWATER))
				WaterMove ();
		}
        return;
    }

	if (self.button2)
	{
		if (time > 20)
			self.last_active = time;
	}

    if (self.style & ELOHIM_OBSERVER)
    {
        observer_pre_think();
        return;
    }

    if (self.deadflag)
    {
		self.style = self.style | ELOHIM_NO_POST_THINK;
        if (self.deadflag >= DEAD_DEAD)
            PlayerDeathThink ();
        return;
    }

    if (elohim_state & ELOHIM_MATCH_PAUSED)
    {
		self.style = self.style | ELOHIM_NO_POST_THINK;
        self.velocity = '0 0 0';
        return;
    }

	if (self.waterlevel || (self.flags & FL_INWATER))
		WaterMove ();
	
    if (self.button2)
		PlayerJump ();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

    if (!self.currentammo)
    {
        if (self.weapon != IT_AXE)
        {
            if (time > self.attack_finished)
            {
                self.weapon = W_BestWeapon ();
                W_SetCurrentAmmo ();
            }
        }
    }
    // END_MOD
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	// ELOHIM_MOD - don't think this is needed
	//if (self.health <= 0)
	//	return;
	// END_MOD

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;

			// ELOHIM_MOD - moved from below
		    self.modelindex = modelindex_player;	// don't use eyes
		}
	}
	// ELOHIM_MOD - moved this up a few lines
	//else
	//	self.modelindex = modelindex_player;	// don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
		{
			self.effects = self.effects | EF_DIMLIGHT;
			self.effects = self.effects | EF_RED;
		}
		else
			self.effects = self.effects - (self.effects & (EF_DIMLIGHT | EF_RED));
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
		{
			self.effects = self.effects | EF_DIMLIGHT;
			self.effects = self.effects | EF_BLUE;
		}
		else
			self.effects = self.effects - (self.effects & (EF_DIMLIGHT | EF_BLUE));
	}	

// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	// ELOHIM_MOD - unused
	//local	float	mspeed, aspeed;
	//local	float	r;
	// END_MOD

    // ELOHIM_MOD
    //
    // - don't do post think stuff while observing
    // - don't do post think stuff while setting options
    // - redirect impulses in [20, 250]
    // - changed gameover test from (self.view_ofs == '0 0 0') to (gameover)

	if (self.button0)
	{
		if (time > 20)
			self.last_active = time;
	}

    if (self.style & ELOHIM_OBSERVER)
    {
        observer_post_think();
        return;
    }

    if (self.impulse)
    {
		self.finaldest_x = time;  // player is alive

		// Redirect impulses 1-10 when player is entering a number
		if (self.use != SUB_Null)
		{
			if (self.impulse >= 1 && self.impulse <= 10)
			{
				if (self.impulse == 10)
					self.impulse = 230;
				else
					self.impulse = self.impulse + 230;
			}
		}
		if (self.impulse >= 20)
		{
			if (self.impulse <= 251)
				elohim_impulse ();
		}
		else
			self.delayed_impulse = self.impulse;
    }
	
	// ELOHIM_NO_POST_THINK is set for gameover, deadflag, 
	// setting options and match paused
	if (self.style & ELOHIM_NO_POST_THINK)
	{
		self.style = self.style - ELOHIM_NO_POST_THINK;
		return;
	}
    // END_MOD

// do weapon stuff

	if (time >= self.attack_finished)
		W_WeaponFrame ();

// check to see if player landed and play landing sound
    // ELOHIM_MOD - rearranged if clauses for efficiency
	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
    else if (self.jump_flag < -300)
    {
        if (self.health > 0)
        {
            if (self.watertype == CONTENT_WATER)
                sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
            else if (self.jump_flag < -650)
            {
                T_Damage (self, world, world, 5); 
                sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
                self.deathtype = "falling";
            }
            else
                sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
    
            self.jump_flag = 0;
        }
    }
    // END_MOD

	// ELOHIM_MOD - optimize the common case
	if (self.invisible_finished | self.invincible_finished | 
		self.super_damage_finished | self.radsuit_finished)
		CheckPowerups ();
	// END_MOD
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	utils_increment_developer(); // CRMOD - for dprints

	elohim_client_connect(); // ELOHIM_MOD - elohim specific stuff

	bprint (self.netname, " entered the game\n");
	
// a client connecting during an intermission can cause problems
	if (intermission_running && !(elohim_state & ELOHIM_TAKING_AUTOSS))  // ELOHIM_MOD - check for autoss
	    GotoNextMap ();  // ELOHIM_MOD  ExitIntermission -> GotoNextMap

	utils_decrement_developer(); // CRMOD - for dprints
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// ELOHIM_MOD - check to see if we've already done this
	// (can happen since elohim_kick_player calls ClientDisconnect directly
	if (!(self.style & ELOHIM_CONNECTED))
		return;
	// END_MOD

	// ELOHIM_MOD - check for null name
	if (utils_illegal_name(self.netname))
		self.netname = "player";
	// END_MOD

	utils_increment_developer(); // CRMOD - for dprints

	// let everyone else know   ELOHIM_MOD - use announce instead of bprint
	local string s;
	s = ftos(self.frags);
	announce4(self.netname, " left the game with ", s, " frags");

    // ELOHIM_MOD - play gib sound if client was kicked for suiciding
    if (self.cnt < 0)
        sound(self, CHAN_BODY, "player/gib.wav", 1, ATTN_NONE);
    else
        sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
    // END_MOD

    // ELOHIM_MOD
    elohim_client_disconnect();
    // END_MOD

	set_suicide_frame ();

	utils_decrement_developer(); // CRMOD - for dprints
};

//
// ELOHIM_MOD
//
// Added a bunch of new obituaries; got rid of "can't exist on slime alone"
// (I never much liked that one)
//
// Added a same-team check for telefragging.
//
// Added code to keep track of team scores
//
// Added code to keep track of kill stats
//
// Removed check for killed by monster
//

//
//  F R A G
//
//  Adds/substracts a frag to a client and his team in match mode.
//
void (entity client, float fragval) client_frag =
{
    
    if (elohim_playmode & ELOHIM_MATCH_MODE)
	{
		if (teamplay)
		{
		    client.frags = client.frags + fragval;
			score_frag(client.next_team, fragval);
		}
		else
			score_frag(client, fragval);
	}
	else
	{
	    client.frags = client.frags + fragval;
		if (client.frags >= fraglimit)
		{
			if (fraglimit && (elohim_levelcount == -1))
				NextLevel();
		}
	}
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum, rnum2;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player")
	{
		// ELO ratings
		ClientRate(targ, attacker);
		
		if (attacker.classname == "teledeath")
		{
			//bprint (targ.netname);
			//bprint (" was telefragged by ");
			//bprint (attacker.owner.netname);
            //bprint ("\n");
			announce3(targ.netname, " was telefragged by ", attacker.owner.netname);

            if ( (teamplay == 2) && (targ.team > 0) && (targ.team == attacker.owner.team) )
            {
                // attacker.owner killed teammate
                attacker.owner.mangle_y = attacker.owner.mangle_y + 1;
                if (attacker.super_damage_finished > time)     // CRMOD - stats
                	attacker.crmod_qdkill_y = attacker.crmod_qdkill_y + 1;
                client_frag(attacker.owner, -1);
            }
            else
            {
                // targ was killed by enemy
                targ.mangle_z = targ.mangle_z + 1;
                client_frag(attacker.owner, 1);
            }
			return;
		}

        // Never implemented
        /*
		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}
        */

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
                attacker.mangle_x = attacker.mangle_x + 1;
                if (attacker.super_damage_finished > time)     // CRMOD - stats
                	attacker.crmod_qdkill_z = attacker.crmod_qdkill_z + 1;   // CRMOD - stats
                client_frag(attacker, -1);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
                    if (rnum < 0.33 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                        deathstring = " discharges into the water";
                    else if (rnum < 0.66)
                        deathstring = " checks the batteries on his thunderbolt";
                    else
                        deathstring = " tries to heat the pool";
				}
				else if (targ.weapon == IT_GRENADE_LAUNCHER)
                {
                    if (rnum < 0.33 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                        deathstring = " tries to put the pin back in";
                    else if (rnum < 0.66)
                        deathstring = " tries to play soccer with a grenade";
                    else
                        deathstring = " forgot that grenades explode";
                }
				else
                {
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                        deathstring = " becomes bored with life";
                    else
                        deathstring = " discovers blast radius";
                }
				announce2(targ.netname, deathstring);
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
			{
                // killed teammate
                attacker.mangle_y = attacker.mangle_y + 1;
                if (attacker.super_damage_finished > time)    // CRMOD - stats
                	attacker.crmod_qdkill_y = attacker.crmod_qdkill_y + 1;  // CRMOD - stats

				local entity oteam;
				local string s;
				oteam = elohim_sentinel.next_team;
				if ((oteam != world) && (oteam == attacker.next_team))
					oteam = oteam.next_team;
				if (!oteam && rnum >= 0.75)
					rnum = (rnum - 0.75) * 2.99;
					 
				if (rnum < 0.25)
					announce4(attacker.netname, " doesn't like ", targ.netname, " anymore");
					//deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					announce3(attacker.netname, " loses his friend ", targ.netname);
					//deathstring = " loses another friend\n";
				else if (rnum < 0.75)
					announce4(attacker.netname, " wants ", targ.netname, " off his team");
					//deathstring = " gets a frag for the other team\n";
				else
				{
					s = strings_get_colour(oteam.height);
					announce5(attacker.netname, " thought ", targ.netname, " was ", s);
					//deathstring = " checks his glasses\n";
				}
				//bprint (attacker.netname);
				//bprint (deathstring);
                client_frag(attacker, -1);
				return;
			}
			else
			{
                // killed enemy
                if (attacker.super_damage_finished > time)     // CRMOD - stats
                	attacker.crmod_qdkill_x = attacker.crmod_qdkill_x + 1;   // CRMOD - stats
                targ.mangle_z = targ.mangle_z + 1;
                client_frag(attacker, 1);
				deathstring2 = "";

                if (attacker.weapon == IT_AXE)
				{
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                        deathstring = " was axe-murdered by ";
                    else
                    {
                        deathstring = " was decapitated by ";
                        deathstring2 = "'s axe";
                    }
				}
                else if (attacker.weapon == IT_SHOTGUN)
				{
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    {
                        deathstring = " chewed on ";
                        deathstring2 = "'s boomstick";
                    }
                    else
                    {
                        deathstring = " was disembowled by ";
                        deathstring2 = "'s shotgun";
                    }
				}
                else if (attacker.weapon == IT_SUPER_SHOTGUN)
				{
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    {
                        deathstring = " ate 2 loads of ";
                        deathstring2 = "'s buckshot";
                    }
					else
                    {
                        deathstring = " eats 2 scoops of ";
                        deathstring2 = "'s lead shot";
                    }
				}
                else if (attacker.weapon == IT_NAILGUN)
				{
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
						deathstring = " was nailed by ";
					else
						deathstring = " was body pierced by ";
				}
                else if (attacker.weapon == IT_SUPER_NAILGUN)
				{
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                        deathstring = " was punctured by ";
                    else
                        deathstring = " was ventilated by ";
				}
                else if (attacker.weapon == IT_GRENADE_LAUNCHER)
				{
                    deathstring2 = "'s grenade";
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was destroyed by ";
                            else
                                deathstring = " was gibbed by ";
                        }
                        else
                        {
                            deathstring = " eats ";
                            deathstring2 = "'s pineapple";
                        }
                    }
                    else
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was annihilated by ";
                            else
                                deathstring = " was blown to chunks by ";
                        }
                        else
                            deathstring = " gets intimate with ";
                    }
				}
                else if (attacker.weapon == IT_ROCKET_LAUNCHER)
				{
                    deathstring2 = "'s rocket";
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was destroyed by ";
                            else
                                deathstring = " was gibbed by ";
                        }
                        else
                            deathstring = " rides ";
                    }
                    else
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was annihilated by ";
                            else
                                deathstring = " was blown to chunks by ";
                        }
                        else
                            deathstring = " is shish-kebabed by ";
                    }
				}
                else if (attacker.weapon == IT_LIGHTNING)
				{
                    if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    {
                        deathstring = " accepts ";
                        if (attacker.waterlevel > 1)
                            deathstring2 = "'s discharge";
                        else
                            deathstring2 = "'s shaft";
                    }
                    else 
                    {
                        if (attacker.waterlevel > 1)
						{
							deathstring = " takes a bath with ";
							deathstring2 = "'s lightning gun";
						}
						else
							deathstring = " gets a warm fuzzy feeling from ";
                    }
				}
                else // This should never happen.. but does it!?!?
                    deathstring = " was massacred by ";

				announce4(targ.netname, deathstring, attacker.netname, deathstring2);
			}
			return;
		}
		else
		{
            // targ got himself killed
            targ.mangle_x = targ.mangle_x + 1;
            client_frag(targ, -1);

			// tricks and traps
			if (attacker.classname == "explo_box")
			{
                if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    deathstring = " blew up";
                else
                    deathstring = " exploded";
			}
			else if (attacker.solid == SOLID_BSP && attacker != world)
			{
                if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
	                deathstring = " was squished";
				else
					deathstring = " was flattened";
			}
			else if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
                if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    deathstring = " was spiked";
                else
                    deathstring = " was skewered";
			}
			else if (attacker.classname == "fireball")
                deathstring = " ate a lavaball";
			else if (attacker.classname == "trigger_changelevel")
				deathstring = " tried to leave";

			// in-water deaths
            else if (targ.watertype == -3)
			{
				if (!(elohim_playmode & ELOHIM_EXTENDED_OBITS))
					rnum = rnum * 0.66;
                if (rnum < 0.33)
					deathstring = " sleeps with the fishes";
                else if (rnum < 0.66)
					deathstring = " sucks it down";
                else
                    deathstring = " realizes he doesn't have gills";
			}
            else if (targ.watertype == -4)
			{
                if (rnum < 0.33 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
					deathstring = " gulped a load of slime";
                else if (rnum < 0.66)
                    deathstring = " discovers the hazards of toxic waste";
                else
                    deathstring = " picked a bad place to swim";
			}
            else if (targ.watertype == -5)
			{
				if (targ.health < -15)
					deathstring = " burst into flames";
                else if (rnum < 0.5)
					deathstring = " turned into hot slag";
				else
					deathstring = " visits the Volcano God";
			}

			// fell to their death?
			else if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
                if (rnum < 0.5 || !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
                    deathstring = " fell to his death";
                else
                    deathstring = " discovers gravity";
			}

			// hell if I know; he's just dead!!!
			else
				deathstring = " died";

			announce2(targ.netname, deathstring);
		}
	}
};

// END_MOD
