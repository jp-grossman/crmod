//
// Training.qc
//

void(vector org) spawn_tfog;
void () player_pain;
void () PlayerDie;
void () DecodeLevelParms;
void () W_SetCurrentAmmo;
void (entity ent) CopyToBodyQue;
void (float newlimit) votables_request_set_timelimit;


float training_numplayers;
float training_same;

//
//  S E N D  A L I A S E S
//
void () training_send_aliases = 
{
	stuffcmd(self, "alias elostart impulse 201\n");
	stuffcmd(self, "alias elosame impulse 202\n");
	stuffcmd(self, "alias eloclose impulse 203\n");
};

//
//  R E S E T
//
void () training_reset = 
{
	if ((self.style & ELOHIM_OBSERVER) || (training_numplayers == 8))
	{
		self.style = self.style - (self.style & ELOHIM_READY);		
		return;
	}
	
	training_numplayers = training_numplayers + 1;

	self.items = IT_AXE | IT_SHOTGUN;
	self.health = 100;
	self.armorvalue = 0;
	self.ammo_shells = 25;
	self.ammo_nails = 0;
	self.ammo_rockets = 0;
	self.ammo_cells = 0;
	self.weapon = IT_SHOTGUN;
	self.armortype = 0;
	W_SetCurrentAmmo ();

	if (!training_same)
		self.style = self.style - (self.style & ELOHIM_READY);
};

//
//  G E T  P L A Y E R
//
entity (float i) training_get_player = 
{
	local entity player;

	player = find(world, classname, "player");
	while (1)
	{
		if (!(player.style & ELOHIM_READY) && (player.style & ELOHIM_CONNECTED) && !(player.style & ELOHIM_OBSERVER))
		{
			i = i - 1;
			if (i < 0)
			{
				player.style = player.style | ELOHIM_READY;
				return player;				
			}
		}
		player = find(player, classname, "player");
	}
};

//
//  A S S I G N  S P A W N S
//
void () training_assign_spawns = 
{
	local float numred;
	local float numblue;
	local float index;
	local entity espawn;

	numred = floor(training_numplayers / 2);
	numblue = training_numplayers - numred;

	index = 0;
	while (numred + numblue)
	{
		local float i;
		espawn = *array_training_spawn[index];
		i = random() * (numred + numblue - 0.001);
		espawn.movetarget = training_get_player(i);

		sprint(self, "assigning spawn ");
		utils_print_float(index / %1);
		utils_print_vec(espawn.origin);

		if (espawn.movetarget.team == 1 || espawn.movetarget.team == 5 || espawn.movetarget.team == 14)
		{
			if (random() * (numred + numblue) < numred)
			{
				stuffcmd(espawn.movetarget, "color 4\n");
				espawn.movetarget.team = 5;
				espawn.movetarget.height = 4;
				numred = numred - 1;
			}
			else
			{
				numblue = numblue - 1;
				stuffcmd(espawn.movetarget, "color 13\n");
				espawn.movetarget.team = 14;
				espawn.movetarget.height = 13;
			}
		}
		else if (random() * (numred + numblue) < numred)
			numred = numred - 1;
		else
			numblue = numblue - 1;
		index = index + %1;
	}
};

//
//  P I C K  C L O S E S T
//
void () training_pick_closest = 
{
	local entity e, es;
	local float i;
	local float dist, bestdist;
	local float j, bestj;

	e = find(world, classname, "info_player_deathmatch");
	while (e)
	{
		e.movetarget = world;
		e = find(e, classname, "info_player_deathmatch");
	}

	i = training_numplayers;
	e = find(world, classname, "player");
	while (i)
	{
		if ((e.style & ELOHIM_CONNECTED) && !(e.style & ELOHIM_OBSERVER))
		{
			e.style = e.style | ELOHIM_READY;
			bestdist = 9999999;
			for (j = 0 ; j < %8 ; j = j + %1)
			{
				es = *array_training_spawn[j];
				dist = vlen(e.origin - es.origin);
				if (dist < bestdist)
				{
					bestdist = dist;
					bestj = j;
				}
			}
			es = *array_training_spawn[bestj];
			es.movetarget = e;
			i = i - 1;
		}
		e = find(e, classname, "player");
	}
};

//
//  T E L L  T E A M
//
void () training_tell_team =
{
	if (self.style & ELOHIM_READY)
	{
		local string sz;
		sz = strings_get_teamname(self.team - 1);
		sprint(self, "You are on the ", sz, "\n");
	}
	else
	{
		sprint(self, "You are not on a team\n");
		if (!(self.style & ELOHIM_OBSERVER))
			observer_start();
	}
};

//
//  G E T  S P A W N  P O I N T
//
entity () training_get_spawn_point =
{
	local entity e;
	e = find(world, classname, "info_player_deathmatch");
	while (e)
	{
		if (e.movetarget == self)
			return e;
		e = find(e, classname, "info_player_deathmatch");
	}
	e = find(world, classname, "elohim_start_point");
	while (e)
	{
		if (e.movetarget == self)
			return e;
		e = find(e, classname, "elohim_start_point");
	}
	return e;
};

//
//  R E S P A W N
//
void () training_respawn = 
{
	local	entity spot;
	spot = training_get_spawn_point();
	if (!spot)
	{
		sprint(self, "No spawn point available\n");
		observer_start();
		return;
	}

	CopyToBodyQue (self);
    SetNewParms2 ();

	self.classname = "player";
	self.health = 100;
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

	DecodeLevelParms ();
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately
    self.velocity = '0 0 0'; // ELOHIM_MOD - bugfix

	setmodel (self, "progs/player.mdl");

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

    makevectors(self.v_angle);
    spawn_tfog (self.origin + v_forward*20);

    elohim_put_client_in_server();
};

//
//  G I B  P L A Y E R
//
void () training_gib_player = 
{
	if (self.style & ELOHIM_OBSERVER)
		return;

	self.health = -99;
    GibPlayer();
    self.deadflag = DEAD_DYING;
    self.think = training_respawn;
    self.nextthink = time + 1;
    self.frags = 0;
    stats_reset_player();
};

//
//  C O U N T D O W N 
//
void () training_countdown = 
{
	if (self.count > 0)
	{
		utils_bprint_float(self.count);
		self.count = self.count - 1;
		self.nextthink = time + 1;
	}
	else
	{
		// Make all items respawn
		utils_do_items(SUB_regen);

		// Make all backpacks disappear
		utils_do_item(SUB_Remove, "item_backpack");

		utils_do_players(training_gib_player);
		remove(self);

		// timer stuff
		elohim_state = elohim_state | ELOHIM_ELOSTART;
		elohim_match_pause_time = time;
	}
};

//
//  S T A R T
//
//  same = 2  means closest spawn
//
void (float same) training_start = 
{
	local entity trainent;
	local entity espawn;

	if (elohim_playmode & (ELOHIM_MATCH_MODE | ELOHIM_PRACTICE_MODE))
	{
		sprint(self, "Elohim Training commands available in normal mode only\n");
		return;
	}
	if (mapname != "dm3")
	{
		sprint(self, "Elohim Training commands available on dm3 only\n");
		return;
	}

	if (same == 1)
		training_same = 1;
	else
		training_same = 0;

	espawn = find(world, classname, "info_player_deathmatch");
	array_training_spawn[%3] = &espawn;
	espawn = find(espawn, classname, "info_player_deathmatch");
	array_training_spawn[%5] = &espawn;
	espawn = find(espawn, classname, "info_player_deathmatch");
	array_training_spawn[%0] = &espawn;
	espawn = find(espawn, classname, "info_player_deathmatch");
	array_training_spawn[%1] = &espawn;
	espawn = find(espawn, classname, "info_player_deathmatch");
	array_training_spawn[%4] = &espawn;
	espawn = find(espawn, classname, "info_player_deathmatch");
	array_training_spawn[%2] = &espawn;

	espawn = find(world, classname, "elohim_start_point");
	array_training_spawn[%6] = &espawn;
	espawn = find(espawn, classname, "elohim_start_point");
	array_training_spawn[%7] = &espawn;

	local float i;
	i = (floor(random() * 2.99) + 3) * %1;
	espawn = *array_training_spawn[%3];
	array_training_spawn[%3] = array_training_spawn[i];
	array_training_spawn[i] = &espawn;
	if (random() > 0.5)
	{
		espawn = *array_training_spawn[%4];
		array_training_spawn[%4] = array_training_spawn[%5];
		array_training_spawn[%5] = &espawn;
	}

	if (same != 1)
	{
		local float i;
		for (i = 0 ; i < %8 ; i = i + %1)
			(*array_training_spawn[i]).movetarget = world;
	}

	elohim_set_teamplay(2);
	if (timelimit)
		votables_request_set_timelimit(0);
	if (fraglimit)
		elohim_set_fraglimit(0);

	// Reset players
	training_numplayers = 0;
	utils_do_players(training_reset);

	// Assign random teams, spawns
    utils_do_item(match_add_spawn, "elohim_start_point");
	if (same == 0)
		training_assign_spawns();
	if (same == 2)
		training_pick_closest();
	utils_do_players(training_tell_team);
    utils_do_item(match_remove_start, "info_player_deathmatch");
	
	// Start timer
	trainent = utils_make_scheduled_event(training_countdown, 1);		
	trainent.count = 10;
};

//
//  S P R I N T  S T A T U S
//
void () training_sprint_status = 
{
	local float seconds;
	local float minutes;
	local string temp;

	seconds = floor(1200 - (time - elohim_match_pause_time));
	minutes = floor(seconds / 60);
	seconds = seconds - minutes * 60;
    temp = ftos(minutes);
    sprint(self, "Time remaining:  ", temp, ":");
    temp = ftos(seconds);
    if (seconds < 10)
        sprint(self, "0");
    sprint(self, temp, "\n");
};
