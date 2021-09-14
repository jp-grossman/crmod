//
// match.qc
//
// This file contains code for the elohim server match (tournament) mode.
//
// Fields used:
//
// .height          - used to store player team
//
// In elohim_match_timer:
//
// lip - minutes left
// count - seconds left
// dest - checkpoint times for countdown
//
// All code by J.P. Grossman unless otherwise commented.
//
// In both match modes the ready players are stored in a linked list with head
// elohim_sentinel.next_player and linked by .next_player.  
//
// In team mode, the list is orgainized by teams (i.e. all players in one team
// appear consecutively), and each team points to the first player
// in the team via pteam.next_player.  The teams are stored in a linked list
// with head elohim_sentinel.next_team and linked by .next_team.  Finally,
// each player points to his team via player.next_team.
//
// In individual mode, .next_player and .next_team are always the same.  i.e.
// each player has 2 copies of the exact same pointer, pointing to the next
// player; this is done for simplicity so that match mode and individual mode
// can use the same code.
//

// Function declarations
void () SUB_regen;
void () GibPlayer;
void () respawn;
void () match_timer_think2;
void () match_enter_ghost_code;
void () match_start_unpause_countdown;
void () match_unpause;
void (entity ghostent) match_restore_ghost;
void () votables_disable_item;
void () console_show_score;
void () console_autodump;
void () training_sprint_status; // TRAINING MOD
void () admin_dm3_screenshot_setup;

//
//  I N I T  W O R L D
//
void () match_init_world = 
{
	elohim_numteams = 0;
	elohim_sentinel.next_team = world;
	elohim_sentinel.movetarget = world;
	elohim_sentinel.frags = ELOHIM_NEGINF;

	if (cvar("teamplay"))
	{
		elohim_szthe = "The ";
		elohim_szteam = "team";
	}
	else
	{
		elohim_szthe = "";
		elohim_szteam = "player";
	}
};

//
//  S H O W  T I M E L I M I T
//
//  Set the console variable 'timelimit' to show relevant match
//  information.
//
void () match_show_timelimit =
{
	local string temp;

	localcmd("timelimit \"");
	if (!(elohim_state & ELOHIM_TIMER_STARTED))
	{
		if (elohim_state & ELOHIM_MATCH_OVER)
		{
			localcmd("Final Score is ");
			temp = ftos(elohim_first_place.frags);
			if (elohim_first_place.frags < 0)
				localcmd("<");
			localcmd(temp);
			if (elohim_first_place.frags < 0)
				localcmd(">");
			localcmd(" - ");
			if (elohim_second_place != elohim_sentinel)
			{
				temp = ftos(elohim_second_place.frags);
				if (elohim_second_place.frags < 0)
					localcmd("<");
				localcmd(temp);
				if (elohim_second_place.frags < 0)
					localcmd(">");
			}
			else
				localcmd("???");
			localcmd("\"\n");
		}
		else
		{
			temp = ftos(elohim_timelimit);
			localcmd4(temp, " : Waiting for ", elohim_szteam, "s\"\n");
		}
	}
	else if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		temp = ftos(elohim_timelimit);
		localcmd2(temp, " : Match Starting\"\n");
	}
	else if (elohim_match_timer.lip < 0)
		localcmd("Sudden death\"\n");
	else
	{
		temp = ftos(elohim_match_timer.lip);
		localcmd2(temp, "\"\n");
	}
};

//
//  I T E M  R E S E T
//
//  Prevent an item from respawning.
//
void () match_item_reset =
{
	self.nextthink = -1;
};

//
//  I N I T  P L A Y E R
//
//  Initialize a player in match mode and make him an observer.
//
void () match_init_player =
{
	self.style = self.style - (self.style & ELOHIM_READY);
	self.finaldest_x = time; // So we don't get autokickedd!!
	observer_start();
};

//
//  U N R E A D Y  P L A Y E R
//
void () match_unready_player =
{
	self.style = self.style - (self.style & ELOHIM_READY);
};

//
//  R E S E T
//
void () match_reset =
{
	elohim_state = elohim_state - (elohim_state & ELOHIM_MATCH_WAIT);

	// prevent items from respawning
	utils_do_items(match_item_reset);

	// remove all backpacks
	utils_do_item(SUB_Remove, "item_backpack");

	// unready all players
	utils_do_players(match_unready_player);

	// remove all ghosts
	utils_do_item(SUB_Remove, "elohim_ghost");

	if (teamplay)
		announce("No teams present");

	if (self.classname == "elohim_match_timer")
		remove(self);
};

//
//  G I B  P L A Y E R
//
//  Gib players; set observers to colour 0.  Called at start
//  and end of match.
//
void () match_gib_player =
{
	if (self.style & ELOHIM_OBSERVER)
		stuffcmd(self, "color 0\n");
	else if (!(self.style & ELOHIM_READY))
		observer_start();
	else
	{
		self.health = -99;
		GibPlayer();
		self.deadflag = DEAD_DYING;
		self.think = respawn;
		self.nextthink = time + 1;
		if (elohim_state & ELOHIM_MATCH_STARTED)
		{
			// start of match
			self.frags = 0;
			stats_reset_player();
			name_fix();//Sputnik: oddly, sometimes the names do not clear the 'ready' after match start...testing.
			name_broadcast(self.netname);
		}
	}
};

//
// R E P O R T  M O S T  V A L U A B L E  P L A Y E R	
// by Sputnik
//
void () match_report_mvp =
{
	local 	entity	current_player;
	local	float 	mvp, score;
	local	string	name;

	mvp = 0;
	name = "No one";

	current_player = find(world, classname, "player");//todo: Let's use the stat linked-list in case someone lagged out?

	while (current_player)
	{
		score = 0;

		if (!(current_player.style & ELOHIM_OBSERVER))
		{
			if (current_player.cl[CL_ACTIVE] == %1)
			{
				if (current_player.dmg_given + current_player.dmg_taken)
				{
					score = current_player.dmg_given * (current_player.dmg_given / (current_player.dmg_given + current_player.dmg_taken)); 
				}
				if (score > mvp)
				{
					mvp = score;
					name = current_player.netname;
				}
			}
		}
		current_player = find(current_player, classname, "player");
	}	

	announce2(name," was the match MVP.");
};

//
//  B P R I N T  S C O R E
//
void () match_bprint_score =
{
	local string score;
	local string temp;

	score = ftos(elohim_first_place.frags);
	temp = strings_szplural(elohim_first_place.frags);
	announce6(elohim_szthe, elohim_first_place.netname, " has ", score, " frag", temp);
	if (elohim_second_place != elohim_sentinel)
	{
		score = ftos(elohim_second_place.frags);
		temp = strings_szplural(elohim_second_place.frags);
		announce6(elohim_szthe, elohim_second_place.netname, " has ", score, " frag", temp);
	}
};

void () match_ffa_bprint_score = 
{
	local entity player, next, sorted_players, prev;
	local string score, srank, tie;
	local float i, rank, prev_frags;

	// Initialize the sort
	sorted_players = elohim_sentinel.next_player;
	player = sorted_players.next_player;
	sorted_players.next_player = world;

	// Sort the players
	while (player)
	{
		next = player.next_player;

		if (player.frags > sorted_players.frags)
		{
			// Insert at the start of the list
			player.next_player = sorted_players;
			sorted_players = player;
		}
		else
		{
			// Insert after some other player
			prev = sorted_players;
			while (prev.next_player != world && prev.next_player.frags >= player.frags)
				prev = prev.next_player;
			player.next_player = prev.next_player;
			prev.next_player = player;
		}

		player = next;
	}
	elohim_sentinel.next_player = sorted_players;

	// Print the scores
	i = 1;
	prev_frags = -1;
	for (player = sorted_players ; player ; player = player.next_player)
	{
		// Check for a tie
		if (player.frags == prev_frags || (player.next_player != world && player.next_player.frags == player.frags))
			tie = "\b*\] ";
		else
			tie = " \] ";

		// Update the rank
		if (player.frags != prev_frags)
			rank = i;
		prev_frags = player.frags;

		// Print the score
		score = ftos(player.frags);
		srank = strings_ftos_gold2(rank);
		announce6("\[", srank, tie, player.name15, " \b- ", score);
		i = i + 1;
	}
};

//
//  M A T C H  B P R I N T  T I M E
//
void () match_bprint_time =
{
	if (elohim_match_timer.lip < 0)
		announce("Sudden death overtime");
	else
	{
		local string temp;

		temp = ftos(elohim_match_timer.lip);
		bprint("Time remaining:  ", temp, ":");
		dprint(#, #, #);
		temp = ftos(elohim_match_timer.count);
		if (elohim_match_timer.count < 10)
		{
			bprint("0");
			dprint(#);
		}
		announce(temp);
	}
};

//
//  S P R I N T  S T A T U S
//
//  Print the time remaining and the score.
//
void () match_sprint_status =
{
	if (!(elohim_state & (ELOHIM_MATCH_STARTED | ELOHIM_MATCH_OVER)))
	{
		if (elohim_state & ELOHIM_TIMER_STARTED)
		{
			local string s, pl;
			s = ftos(elohim_match_timer.count);
			pl = strings_szplural(elohim_match_timer.count);
			sprint(self, "Match begins in ", s, " second", pl, "\n");
		}
		else
			sprint(self, "Waiting for ", elohim_szteam, "s\n");
		return;
	}

	if (elohim_state & ELOHIM_MATCH_OVER)
		sprint(self, "Match over\n");
	else if (elohim_match_timer.lip < 0)
		sprint(self, "Sudden death overtime\n");
	else
	{
		local string temp;
	
		temp = ftos(elohim_match_timer.lip);
		sprint(self, "Time remaining:  ", temp, ":");
		temp = ftos(elohim_match_timer.count);
		if (elohim_match_timer.count < 10)
			sprint(self, "0");
		sprint(self, temp, "\n");
	}

	local string score;
	local string temp;

	if (elohim_first_place != elohim_sentinel)
	{
		score = ftos(elohim_first_place.frags);
		temp = strings_szplural(elohim_first_place.frags);
		sprint(self, elohim_szthe, elohim_first_place.netname, " has ", score, " frag", temp, "\n");
	}
	if (elohim_second_place != elohim_sentinel)
	{
		score = ftos(elohim_second_place.frags);
		temp = strings_szplural(elohim_second_place.frags);
		sprint(self, elohim_szthe, elohim_second_place.netname, " has ", score, " frag", temp, "\n");
	}
};

//
//  C H E C K  A U T O S S
//
//  Check to see if there is a delayed autoss that needs to be taken.
//
void () match_check_autoss = 
{
	if (elohim_state & ELOHIM_DELAYED_AUTOSS)
	{
		admin_dm3_screenshot_setup();
		elohim_state = elohim_state - ELOHIM_DELAYED_AUTOSS;
	}

	elohim_match_timer.think = match_reset;
	elohim_match_timer.nextthink = time + 2;
};

//
//  O V E R  T I M E  T H I N K
//
void () match_overtime_think = 
{
	display_update_all();
	self.nextthink = time + 1;
};

//
//  E N D
//
//  Called to end the match when the timer runs out or an administrator
//  aborts the match.
//
void () match_end =
{
	local entity player;

	if (self.classname == "elohim_match_timer")
	{
		// Regular match end (timer ran out)
		if ((elohim_first_place.frags == elohim_second_place.frags) && elohim_overtime)
		{
			// go into overtime
			self.lip = elohim_overtime;
			self.count = 0;
			match_show_timelimit();
			if (elohim_overtime > 0)
			{
				announce("Match tied - Overtime!!");
				self.think = match_timer_think2;
				match_timer_think2();
			}
			else
			{
				announce("Match tied - Sudden Death Overtime!!");
				self.think = match_overtime_think;
				match_overtime_think();
			}
			return;
		}
	}
	else
	{
		// Administrator aborted the match
		if (!(elohim_state & ELOHIM_MATCH_STARTED))
		{
			sprint(self, "No match in progress\n");
			return;
		}
	
		match_unpause();
		elohim_numteams = 0;
	}

	elohim_state = elohim_state - ELOHIM_MATCH_STARTED;
	elohim_state = elohim_state - ELOHIM_TIMER_STARTED;
	elohim_state = elohim_state | ELOHIM_MATCH_OVER | ELOHIM_MATCH_WAIT;
	utils_do_players(match_gib_player); 
	match_show_timelimit();       
//    announce("The match is over");//Sputnik: moved below stats output
	if (teamplay)
		match_bprint_score();
	else
		match_ffa_bprint_score();

	if (elohim_first_place.frags == elohim_second_place.frags)
		announce("Tie game!");
	else
		announce3(elohim_szthe, elohim_first_place.netname, " has won");

	elohim_match_timer.think = match_check_autoss;
	elohim_match_timer.nextthink = time + 3;

	elohim_numteams = 0;
	elohim_sentinel.movetarget = world;

	display_update_all();

	// Dump statistics for anyone who has autostats set
	utils_do_players(stats_autodump);
	console_autodump();

	if (teamplay)
		match_report_mvp();//Sputnik

	//Sputnik: Moved down here so that autodemo will catch the autostats output.
	bprint("\n");
	announce("The match is over");
//	bprint("\n");
	// Backup all statistics so that they don't go away
	stats_copy_statistics();
};

string match_minutes;

//
//  P R I N T  T I M E
//
void () match_print_time = 
{
	if (!(self.style & (ELOHIM_SHOW_TIMER | ELOHIM_PROQUAKE)))
		sprint(self, "Match ends in ", match_minutes, " minutes\n");
};

//
//  T I M E R  T H I N K 2
//
//  Match timer think function.
//
//  self.count gives the number of seconds remaining in the match.
//
void () match_timer_think2 =
{
	local string temp;

	self.count = self.count - 1;
	if (self.count < 0)
	{
		self.count = 59;
		self.lip = self.lip - 1;
	}
	self.nextthink = time + 1;

	display_update_all();

	// control stats
	if (elohim_sentinel.movetarget)
		elohim_sentinel.movetarget.mangle_x = elohim_sentinel.movetarget.mangle_x + 1;
	elohim_sentinel.cnt = elohim_sentinel.cnt + 1;

	if (self.lip)
	{
		if (self.count)
			return;
		if (self.lip > 1)
		{
			match_minutes = ftos(self.lip);
			match_show_timelimit();
			dprint("Match ends in ", match_minutes, " minutes\n");
			utils_do_players(match_print_time);
			if (self.lip == 5 * floor(self.lip / 5))
				match_bprint_score();
		}
		else
		{
			match_show_timelimit();
			announce("Match ends in 1 minute");
			match_bprint_score();
		}
	}
	else if (self.count == 30)
	{
		announce("Match ends in 30 seconds");
		if (elohim_overtime > 0)
		{
			temp = ftos(elohim_overtime);
			announce2(temp, " minute overtime in case of tie");
		}
		else if (elohim_overtime < 0)
			announce("Sudden death overtime in case of tie");
	}
	else if (self.count <= 10)
	{
		local string plural;
		if (self.count == 10)
			announce("Match ends in T minus");
		local string temp;
		temp = ftos(self.count);
		plural = strings_szplural(self.count);
		announce4("  ", temp, " second", plural);
		if (self.count == 1)
			self.think = match_end;
	}
};

//
//  A D D  S P A W N
//
//  Turn this extra start point into a spawn point for the match start
//
void () match_add_spawn =
{
	self.mdl = "elohim_start_point";
	self.classname = "info_player_deathmatch";
};

//
//  R E M O V E  S T A R T
//
//  Turn this extra start point back into a start point 2 seconds into
//  the match.
//
void () match_remove_start =
{
	if (self.mdl == "elohim_start_point")
		self.classname = self.mdl;
};

//
//  R E M O V E  S T A R T S
//
//  2 seconds into the match all start points revert to start points.
//
void () match_remove_starts =
{
	utils_do_item(match_remove_start, "info_player_deathmatch");
	elohim_num_spawns = elohim_num_spawns - elohim_num_starts;
	remove(self);
};

//
//  C O U N T  P L A Y E R S
//
float () match_count_players = 
{
	local entity pteam;
	local float numplayers;

	if (!teamplay)
		return elohim_numteams;

	numplayers = 0;
	pteam = elohim_sentinel.next_team;
	while (pteam)
	{
		numplayers = numplayers + pteam.count;
		pteam = pteam.next_team;
	}
	return numplayers;
};

//
//  G E T  M A X S I Z E
//
void () match_get_maxsize = 
{
	local entity pteam;

	if (!teamplay)
		return elohim_numteams;

	elohim_maxsize = 0;
	pteam = elohim_sentinel.next_team;
	while (pteam)
	{
		elohim_maxsize = utils_max(elohim_maxsize, pteam.count);
		pteam = pteam.next_team;
	}
};

// 
//  R E S E T  O W N E R
//
void () match_reset_owner =
{
	self.owner = world;
};

//
//  C H E C K  T E A M  C O L O U R S
//
//  Check to make sure the shirt colour hasn't changed
//
void () match_check_team_colours = 
{
	local entity pteam, player;
	local float shirt;

	for (pteam = elohim_sentinel.next_team ; pteam ; pteam = pteam.next_team)
	{
		shirt = pteam.colormap;
		for (player = pteam.next_player ; player ; player = player.next_player)
		{
			pteam.colormap = floor(player.colours / %16);
			if (pteam.colormap == shirt)
				player = world;
		}
		proquake_new_team(MSG_ALL, pteam.height, pteam.colormap);
	}
};

//
//  B E G I N
//
//  Gib all players and start the match.
//
void () match_begin =
{
	local string temp;

	elohim_state = elohim_state | ELOHIM_MATCH_STARTED;

	announce("The match has begun!");//Sputnik: for cl_autodemo 2	

	utils_do_players(match_gib_player);	

	// Set the team size so that unwanted A-holes can't join in
	match_get_maxsize();
	
	temp = ftos(elohim_maxsize);

	if (teamplay)
		announce4("Match is ", temp, "v", temp);

	temp = ftos(elohim_timelimit);
	announce2(temp, " minutes remaining");

	self.think = match_timer_think2;
	self.nextthink = time + 1;
	self.lip = elohim_timelimit;
	self.count = 0;
	match_show_timelimit();
	display_update_all();

	// reset rocket launcher count and number of seconds elapsed count
	elohim_sentinel.ammo_rockets = 0;
	elohim_sentinel.cnt = 0;

	// reset quad, pent counts
	utils_do_item(match_reset_owner, "item_artifact_invulnerability");
	utils_do_item(match_reset_owner, "item_super_damage");

	// Temporarily turn the extra start points into spawn points if necessary
	if (match_count_players() > elohim_num_spawns)
	{
		utils_do_item(match_add_spawn, "elohim_start_point");
		elohim_num_spawns = elohim_num_spawns + elohim_num_starts;
		utils_make_scheduled_event(match_remove_starts, 2);
	}

	score_resend_scoreboard();

	// Initialize the score module
	score_init();

	stats_delete_copies();

	if (teamplay)
		match_check_team_colours();
};

//
//  B P R I N T  T I M E L I M I T
//
//  Print out the timelimit in bronze and gold
//
void () match_bprint_timelimit = 
{
	local string digit;
	local float temp;

	bprint("\bTimelimit is \<");
	temp = floor(elohim_timelimit / 10);
	if (temp)
	{
		digit = strings_ftos_gold(temp);
		bprint(digit);
	}
	temp = elohim_timelimit - 10 * temp;
	digit = strings_ftos_gold(temp);
	bprint(digit, "\>\n");
};

//
//  R E S E T  P O W E R U P
//
void () match_reset_powerup = 
{
	self.count = self.cnt = 0;		
	self.owner = world;				
	self.height = 0;				
};

//
//  T I M E R  T H I N K 1
//
//  Pre-match timer think function.
//
//  self.count gives the number of seconds until the match begins.
//
void () match_timer_think1 =
{
	local string temp, plural;

	self.count = self.count - 1;
	self.nextthink = time + 1;

	display_update_all();

	if (self.count == self.dest_x)
	{
		match_bprint_timelimit();
		bprint("Use '\btimeset\b' to change timelimit\n");
	}
	if (self.count == self.dest_y)
	{
		// respawn all items; reset information
		utils_do_items(SUB_regen);
		utils_do_item(match_reset_powerup, "item_artifact_invulnerability");
		utils_do_item(match_reset_powerup, "item_artifact_super_damage");

		announce("All items have respawned");
		if (elohim_playmode & (ELOHIM_NO_QUAD | ELOHIM_NO_PENT | ELOHIM_NO_RING))
			dprint("- ");
		if (elohim_playmode & ELOHIM_NO_QUAD)
		{
			bprint("ŽQuad is ÏÆÆ");
			dprint("Quad is OFF - ");
			utils_do_item(votables_disable_item, "item_artifact_super_damage");
		}
		if (elohim_playmode & ELOHIM_NO_PENT)
		{
			bprint("ŽPent is ÏÆÆ");
			dprint("Pent is OFF - ");
			utils_do_item(votables_disable_item, "item_artifact_invulnerability");
		}
		if (elohim_playmode & ELOHIM_NO_RING)
		{
			bprint("ŽRing is ÏÆÆ");
			dprint("Ring is OFF - ");
			utils_do_item(votables_disable_item, "item_artifact_invisibility");
		}
		if (elohim_playmode & (ELOHIM_NO_QUAD | ELOHIM_NO_PENT | ELOHIM_NO_RING))
		{
			bprint("Ž\n");
			dprint("\n");
		}

		if (self.count == 30)
			announce("Match begins in 30 seconds");
		match_bprint_timelimit();
	}
	else if (self.count == self.dest_z)
	{
		match_get_maxsize();
		temp = ftos(elohim_maxsize);
		if (teamplay)
			announce4("Match is currently ", temp, "v", temp);
		if (self.count == 20)
			announce("Match begins in 20 seconds");
		match_bprint_timelimit();
	}
	else if (self.count <= 10)
	{
		if (self.count == 10)
		{
			announce("Match begins in T minus");
			quaketag_clear();
		}
		temp = ftos(self.count);
		plural = strings_szplural(self.count);
		announce4("  ", temp, " second", plural);
		if (self.count == 1)
			self.think = match_begin;
		if (self.count == 5)
			match_get_maxsize();
	}
};

//
//  D E L E T E  T E A M S
//
void () match_delete_teams = 
{
	local entity pteam;

	if (teamplay) // don't remove entities in individual mode!!
	{
		while (elohim_sentinel.next_team)
		{
			pteam = elohim_sentinel.next_team;
			elohim_sentinel.next_team = pteam.next_team;
			remove(pteam);
		}
	}
	elohim_numteams = 0;
	elohim_sentinel.next_team = world;
	elohim_sentinel.next_player = world;

	proquake_send_match_reset();
};

//
//  P U T  P L A Y E R  I N  T E A M
//
//  Try to put a player into the team that he has chosen.  Called
//  when a player enters 'ready' in the console.  Returns TRUE if
//  successful, FALSE otherwise.
//
float () match_put_player_in_team =
{
	local entity pteam;

	if (self.team == 1)
	{
		sprint(self, "Invalid pants color\n");
		return FALSE;
	}

	if (elohim_state & ELOHIM_MATCH_OVER)
	{
		elohim_state = elohim_state - ELOHIM_MATCH_OVER;
		proquake_send_match_reset();
		score_resend_scoreboard();
	}

	self.height = self.team - 1;
	self.colours = self.cl[CL_COLORS];

	if (!teamplay)  // Individual mode
	{
		if (elohim_state & ELOHIM_MATCH_STARTED)		
		{
			if (elohim_numteams == elohim_maxsize)
			{
				sprint(self, "Match full.  A player must enter\n");
				sprint(self, "'unlock' in console to let you join\n");
				return FALSE;
			}

			// check to see if they're top 2
			if (0 > elohim_first_place.frags)
			{
				elohim_second_place = elohim_first_place;
				elohim_first_place = self;
			}
			else if (0 > elohim_second_place.frags)
				elohim_second_place = self;
		}

		// add the player
		self.next_player = self.next_team = elohim_sentinel.next_player;
		elohim_sentinel.next_player = elohim_sentinel.next_team = self;
		elohim_numteams = elohim_numteams + 1;
		announce2(self.netname, " has joined the match");
		if (elohim_numteams == 1)
			announce("Only one player is ready");
		return TRUE;
	}

	// find the team
	pteam = elohim_sentinel.next_team;
	while (pteam)
	{
		if (pteam.height == self.height)
		{
			// can we add to the team?
			if (pteam.count == elohim_maxsize)
			{
				if (elohim_state & ELOHIM_MATCH_STARTED)
				{
					sprint(self, "Team full.  A player must enter\n");
					sprint(self, "'unlock' in console to let you join\n");
					return FALSE;
				}
				else if ((elohim_state & ELOHIM_TIMER_STARTED) && (elohim_match_timer.count <= 5))
				{
					sprint(self, "Team locked at T-5 seconds\n");
					sprint(self, "Cannot join unless someone unreadies\n");
					return FALSE;
				}
			}

			// add to the team
			pteam.count = pteam.count + 1;
			if (pteam.count > 1)
			{
				self.next_player = pteam.next_player.next_player;
				pteam.next_player.next_player = self;
			}
			else
			{
				self.next_player = elohim_sentinel.next_player;
				elohim_sentinel.next_player = self;
				pteam.next_player = self;
			}
			self.next_team = pteam;

			announce3(self.netname, " has joined the ", pteam.netname);
			if (elohim_numteams == 1)
				announce("Only one team present");

			// check the team colours
			match_check_team_colours();

			return TRUE;
		}
		pteam = pteam.next_team;
	}

	// can we create a team?
	if (elohim_numteams >= elohim_maxteams)
	{
		local string temp;

		temp = ftos(elohim_maxteams);
		sprint(self, "There are already ", temp, " teams:\n");
		pteam = elohim_sentinel.next_team;
		while (pteam)
		{
			temp = ftos(pteam.height);
			sprint(self, pteam.netname, " (colour ", temp, ")\n");
			pteam = pteam.next_team;
		}
		return FALSE;
	}

	// create the team
	pteam = spawn();
	pteam.classname = "elohim_team";
	pteam.next_team = elohim_sentinel.next_team;
	elohim_sentinel.next_team = pteam;
	self.next_player = elohim_sentinel.next_player;
	pteam.next_player = self;
	elohim_sentinel.next_player = self;
	self.next_team = pteam;
	pteam.count = 1;
	pteam.height = self.height;
	pteam.frags = 0;
	pteam.netname = strings_get_teamname(pteam.height);
	pteam.name15text = strings_get_teamname15(pteam.height);
	pteam.mdl = strings_get_teamname_bronze(pteam.height);
	pteam.ammo_rockets = 0;
	elohim_numteams = elohim_numteams + 1;
	stats_reset_team(pteam);

	pteam.colormap = floor(self.colours / %16);
	proquake_new_team(MSG_ALL, pteam.height, pteam.colormap);

	announce2(pteam.netname, " created");
	announce3(self.netname, " has joined the ", pteam.netname);
	if (elohim_numteams == 1)
		announce("Only one team present");

	return TRUE;
};

//
//  A L L  R E A D Y
//
//  Returns TRUE if all non-observers are ready, FALSE otherwise.
//
float () match_all_ready =
{
	local entity player;

	player = find(world, classname, "player");
	while (player)
	{
		if (!(player.style & (ELOHIM_OBSERVER | ELOHIM_READY)) && (player.style & ELOHIM_CONNECTED))
			return FALSE;
		player = find(player, classname, "player");
	}
	return TRUE;
};

//
//  S T A R T  T I M E R
//
//  Starts the timer.
//
void () match_start_timer =
{
	if (elohim_state & ELOHIM_TIMER_STARTED)
		return;

	elohim_match_timer = spawn();
	elohim_match_timer.classname = "elohim_match_timer";
	elohim_match_timer.think = match_timer_think1;
	elohim_match_timer.nextthink = floor(time) + 2;

	elohim_state = elohim_state | ELOHIM_TIMER_STARTED;
	match_show_timelimit();

	if (elohim_playmode & ELOHIM_FAST_START)
	{
		elohim_match_timer.dest = '18 15 12';
		elohim_match_timer.count = 19;
		announce("Match begins in 20 seconds");
	}
	else
	{
		elohim_match_timer.dest = '55 30 20';
		elohim_match_timer.count = 59;
		announce("Match begins in 1 minute");
	}
	display_update_all();
};

//
//  F I N D  G H O S T
//
//  Finds a ghost from a ghost code; returns world if the ghost doesn't
//  exist.
//
entity (float code) match_find_ghost =
{
	local entity e;

	e = find(world, classname, "elohim_ghost");
	while ((e != world) && (e.count != code))
		e = find(e, classname, "elohim_ghost");
	return e;
};

//
//  S E N D  G H O S T  A L I A S E S
//
//  Send the ghost aliases, e.g.
//
//  alias ghostcode echo Your ghostcode is 29
//  alias ghost "impulse 127;w5;impulse 232;w5;impulse 239"
//
void () match_send_ghost_aliases = 
{
	local string temp;
	local float digit;
	temp = ftos(self.owner.count);
	stuffcmd(self, "alias ghostcode echo Your ghost code is ");
	stuffcmd(self, temp);
	stuffcmd(self, "\n");
	stuffcmd(self, "alias ghost \"impulse 127;w5;impulse ");
	digit = floor(self.owner.count / 10);
	temp = ftos(digit + 230);
	stuffcmd(self, temp);
	stuffcmd(self, ";w5;impulse ");
	digit = self.owner.count - 10 * digit;
	temp = ftos(digit + 230);
	stuffcmd(self, temp);
	stuffcmd(self, "\n");
};

//
//  M A K E  G H O S T
//
//  Create a ghost for the player (if does not already have one)
//  and tell him what his ghost code is.
//
void () match_make_ghost =
{
	// can't have two ghosts
	if (self.owner)
		remove(self.owner);

	// create ghost code
	local float ghostcode;
	ghostcode = 10 + floor(89.99 * random());
	while (match_find_ghost(ghostcode))
		ghostcode = 10 + floor(89.99 * random());

	// initialize ghost
	self.owner = spawn();
	self.owner.classname = "elohim_ghost";
	self.owner.owner = self;
	self.owner.frags = 0;
	self.owner.height = self.height;
	self.owner.count = ghostcode;
	self.owner.state = 0;
	self.owner.movetype = MOVETYPE_NONE;

	match_send_ghost_aliases();
	stuffcmd(self, "ghostcode\n");
};

//
//  R E Q U E S T  R E S T O R E  G H O S T
//
//  Request to be restored from a ghost.  The player is prompted
//  to enter his three digit ghost code.
//
void () match_request_restore_ghost =
{
	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		sprint(self, "There is no match in progress\n");
		return;
	}

	// only uncomitted players can ghost themselves
	if (self.style & ELOHIM_READY)
	{
		sprint(self, "You are already in the match\n");
		return;
	}

	sprint(self, "Enter the first ghost code digit:\n");
	self.count = 0;
	self.use = match_enter_ghost_code;
};

//
//  E N T E R  G H O S T  C O D E
//
//  Enter another ghost code digit.  The digit is stored in
//  self.finaldest_z.
//
void () match_enter_ghost_code =
{
	if (self.finaldest_z > 9)
		return;
	self.count = self.count * 10 + self.finaldest_z;
	if (!self.count)
		return;

	if (self.count < 10)
		sprint(self, "Enter the second ghost code digit:\n");
	else
	{
		// ghost code has been entered
		local entity e;

		e = match_find_ghost(self.count);
		if (!e)
			sprint(self, "Ghost not found\n");
		else
		{
			// Check to make sure the client is gone
			if (e.owner.owner == e)
				sprint(self, e.owner.netname, " owns this ghost\n");
			else
				match_restore_ghost(e);
		}
		self.use = SUB_Null;
	}
};

//
//  R E S T O R E  G H O S T
//
//  Restore a player from their ghost after they've entered their
//  ghost code.  Note that the only way for this function to be
//  called is if there is a match in progress and the player entering
//  the ghostcode is an uncommitted observer.
//
void (entity ghostent) match_restore_ghost =
{
	local string temp, plural;

	self.team = ghostent.height + 1;
	if (!match_put_player_in_team())
		return;

	self.style = self.style | ghostent.style | ELOHIM_READY;
	self.crmod_hack_count = ghostent.crmod_hack_count;

	// Must ready before observer_end, or will be made observer again
	// Must observer_end before setting frags, or frags will be set to 0
	observer_end();

	// copy always data
	self.frags = ghostent.frags;
	self.dest = ghostent.dest;
	self.dest1 = ghostent.dest1;
	self.dest2 = ghostent.dest2;
	self.mangle = ghostent.mangle;
	self.crmod_qdwep = ghostent.crmod_qdwep;
	self.crmod_qdkill = ghostent.crmod_qdkill;
	self.colours = ghostent.colours;
	self.rating = ghostent.rating;
	self.elohim_player_id = ghostent.elohim_player_id;//Sputnik
	self.dmg_taken = ghostent.dmg_taken;//Sputnik
	self.dmg_given = ghostent.dmg_given;//Sputnik
	
	// check for copy-on-pause data
	if (ghostent.state)
	{
		setorigin(self, ghostent.origin);		

		self.frame = ghostent.frame;
		self.effects = ghostent.effects;
		self.angles = ghostent.angles;
		self.waterlevel = ghostent.waterlevel;
		self.watertype = ghostent.watertype;
		self.crmod_old_velocity = ghostent.crmod_old_velocity;
		self.nextthink = ghostent.nextthink - 1000000;
		self.think = ghostent.think;
		self.health = ghostent.health;
		self.items = ghostent.items;
		self.armortype = ghostent.armortype;
		self.armorvalue = ghostent.armorvalue;
		self.weapon = ghostent.weapon;
		self.weaponmodel = ghostent.weaponmodel;
		self.weaponframe = ghostent.weaponframe;
		self.currentammo = ghostent.currentammo;
		self.ammo_shells = ghostent.ammo_shells;
		self.ammo_nails = ghostent.ammo_nails;
		self.ammo_rockets = ghostent.ammo_rockets;
		self.ammo_cells = ghostent.ammo_cells;
		self.flags = ghostent.flags;
		self.walkframe = ghostent.walkframe;
		self.attack_finished = ghostent.attack_finished;
		self.pain_finished = ghostent.pain_finished;
		self.air_finished = ghostent.air_finished;
		self.invincible_finished = ghostent.invincible_finished;
		self.invisible_finished = ghostent.invisible_finished;
		self.super_damage_finished = ghostent.super_damage_finished;
		self.radsuit_finished = ghostent.radsuit_finished;
		self.invincible_time = ghostent.invincible_time;
		self.invisible_time = ghostent.invisible_time;
		self.super_time = ghostent.super_time;
		self.rad_time = ghostent.rad_time;
		self.show_hostile = ghostent.show_hostile;
		self.jump_flag = ghostent.jump_flag;
		self.swim_flag = ghostent.swim_flag;
		self.bubble_count = ghostent.bubble_count;
		self.fixangle = 1;
		self.finaldest_y = self.movetype = MOVETYPE_FLY;
		
		// check eyes
		if (self.invisible_finished)
			self.modelindex = modelindex_eyes;

		// check mega healths
		local entity mh;
		mh = find(world, classname, "item_health");
		while (mh)
		{
			if ((mh.healtype == 2) && (mh.owner == ghostent))
				mh.owner = self;
			mh = find(mh, classname, "item_health");
		}

		// check rocket launcher
		if (self.items & IT_ROCKET_LAUNCHER)
			quaketv_obtained_rl(self);

		ghostent.state = 0;
	}

	self.owner = ghostent;
	ghostent.owner = self;
	stuffcmd(self, "color ");
	temp = ftos(floor(self.colours / %16));
	stuffcmd(self, temp);
	stuffcmd(self, " ");
	temp = ftos(self.height);
	stuffcmd(self, temp);
	stuffcmd(self, "\n");

	match_send_ghost_aliases();

	temp = ftos(self.frags);
	plural = strings_szplural(self.frags);
	announce5(self.netname, " restored from ghost\nwith ", temp, " frag", plural);

	// check to see if they're top 2
	if (!teamplay)
	{
		if (self.frags > elohim_first_place.frags)
		{
			elohim_second_place = elohim_first_place;
			elohim_first_place = self;
		}
		else if (self.frags > elohim_second_place.frags)
			elohim_second_place = self;
	}

	// check to see if we should initiate an unpause
	if ((elohim_request != world) || !(elohim_state & ELOHIM_MATCH_PAUSED) || (elohim_state & ELOHIM_UNPAUSING) || !teamplay)
		return;

	// are the teams balanced now?
	local entity pteam;
	for (pteam = elohim_sentinel.next_team ; pteam ; pteam = pteam.next_team)
	{
		if (pteam.count != self.next_team.count)
			return;
	}
	vote_init("unpause the match", "", match_start_unpause_countdown);
};

//
//  R E A D Y
//
//  Called when a player enters 'ready' in the console.
//
void () match_ready =
{
	if (elohim_state & ELOHIM_MATCH_WAIT)
	{
		sprint(self, "Try again in 5 seconds\n");
		return;
	}
	if (self.style & ELOHIM_READY)
	{
		// in case the READY didn't get propagated properly the first time
		if (!(elohim_state & ELOHIM_MATCH_STARTED))
		{
			name_broadcast(self.name_ready);
			score_name_change();
		}
		sprint(self, "You are already committed\n");
		return;
	}

	// can't commit while entering ghost code
	if (self.use == match_enter_ghost_code)
	{
		sprint(self, "Finish entering the ghost code\n");
		return;
	}

	// Try to add the player; colour him white if unsuccessful
	if (!match_put_player_in_team())
	{
		stuffcmd(self, "color 0\n");
		return;
	}

	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		name_fix();//Sputnik: had to update the name again, because when logged-in then switching modes, then back to match, it wouldn't keep the white 'READY'.
		name_broadcast(self.name_ready);
		score_name_change();
	}

	self.style = self.style | ELOHIM_READY;

	// Give the player a ghost
	match_make_ghost();

	self.oflags = self.oflags - (self.oflags & OBSERVER_QUAKETV);	//Sputnik
	observer_end();

	if (!self.elohim_player_id) //Sputnik	
		sprint(self,"You are \bnot\b logged in. Your stats will \bnot\b be recorded for this match.\n");

	// check to see if we need to start the timer
	if (elohim_numteams > 1 && !(elohim_state & ELOHIM_TIMER_STARTED) && match_all_ready())
		match_start_timer();
};

//
//  R E M O V E  P L A Y E R
//
void (entity player) match_remove_player = 
{
	local entity plast;

	// Remove from team & linked list
	plast = elohim_sentinel;
	while (plast.next_player != player) // find previous player in list
	{
		plast = plast.next_player;
		if (!plast)
			return;  // player isn't in the list
	}	
	plast.next_player = player.next_player;  // fix list

	if (teamplay)
	{
		if (player.next_team.next_player == player) // fix team player pointer if necessary
			player.next_team.next_player = player.next_player;
		player.next_team.count = player.next_team.count - 1;

		if ((player.items & IT_ROCKET_LAUNCHER) && (elohim_state & ELOHIM_MATCH_STARTED) && !player.deadflag)
			quaketv_lost_rl(player);
	}
	else
	{
		plast.next_team = player.next_team;
		elohim_numteams = elohim_numteams - 1;
	}
};

//
//  R E M O V E  T E A M
//
void (entity pteam) match_remove_team = 
{
	local entity plast;

	proquake_erase_team(pteam.height);

	plast = elohim_sentinel;
	while (plast.next_team != pteam) // find previous team in list
		plast = plast.next_team;
	plast.next_team = pteam.next_team; // fix list
	remove(pteam);
	elohim_numteams = elohim_numteams - 1;
};

//
//  N O T  R E A D Y
//
//  Called when a player enters 'notready' in the console.
//
void () match_notready =
{
	if (elohim_state & ELOHIM_MATCH_WAIT)
	{
		sprint(self, "Try again in 5 seconds\n");
		return;
	}
	if (!(self.style & ELOHIM_READY))
	{
		sprint(self, "You have not yet committed\n");
		return;
	}
	if (elohim_state & ELOHIM_MATCH_STARTED)
	{
		sprint(self, "Cannot uncommit during match\n");
		sprint(self, "Type 'observer' to leave match\n");
		return;
	}

	self.style = self.style - ELOHIM_READY;
	announce2(self.netname, " is not ready");
	name_broadcast(self.netname);
	score_name_change();

	// He was ready but the match hadn't started, so remove his ghost
	remove(self.owner);
	self.owner = world;

	stuffcmd(self, "alias ghostcode echo You do not have a ghost\n");
	stuffcmd(self, "alias ghost impulse 127\n");

	match_remove_player(self);
	if (teamplay && !self.next_team.count)
		match_remove_team(self.next_team);

	if (elohim_numteams == 1)
		announce3("Only one ", elohim_szteam, " present");
	else if (!elohim_numteams)
		announce3("No ", elohim_szteam, "s present");

	if (elohim_state & ELOHIM_TIMER_STARTED)
	{
		announce("Timer stopped");
		remove(elohim_match_timer);
		elohim_state = elohim_state - ELOHIM_TIMER_STARTED;
		match_show_timelimit();
		score_resend_scoreboard();
	}
};

//
//  U N L O C K
//
//  Allow new players to joing the match.
//
void () match_unlock =
{
	elohim_maxsize = 16;
	announce("Match has been unlocked");
	announce("New players may join at will");
};

//
//  R E Q U E S T  U N L O C K
//
//  Request to allow new players to join the match.
//
void () match_request_unlock =
{
	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		sprint(self, "No match in progress\n");
		return;
	}
	if (elohim_maxsize == 16)
	{
		sprint(self, "Match is already unlocked\n");
		return;
	}

	// Do it right away if we're an administrator, otherwise vote
	if (self.style & ELOHIM_ADMINISTRATOR)
		match_unlock();
	else
	{
		if (vote_init("allow new players to join", "", match_unlock))
			vote_yes();
	}
};

//
//  L O C K
//
//  Re-cap the team size.
//
void () match_lock =
{
	match_get_maxsize();

	announce("Match has been locked");
	local string s;
	s = ftos(elohim_maxsize);
	if (teamplay)
		announce2("Max teamsize set to ", s);
	else
		announce2("Max number of players set to ", s);
};

//
//  R E Q E S T  L O C K
//
//  Request to re-cap the team size.
//
void () match_request_lock =
{
	local float temp;

	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		sprint(self, "No match in progress\n");
		return;
	}

	temp = elohim_maxsize;
	match_get_maxsize();
	if (elohim_maxsize == temp)
	{
		sprint(self, "Match is already locked\n");
		return;
	}
	elohim_maxsize = temp;

	// Do it right away if we're an administrator, otherwise vote
	if (self.style & ELOHIM_ADMINISTRATOR)
		match_lock();
	else if (self.style & ELOHIM_READY)
	{
		if (vote_init("lock the match", "", match_lock))
			vote_yes();
	}
	else
	{
		sprint(self, "lock comand available to match\n");
		sprint(self, "participants and administrators only\n");
   }
};

//
//  H E L P
//
void () match_help =
{
	sprint(self, "Match commands (for match mode only):\n");
	sprint(self, " ready    - commit to a team\n");
	sprint(self, " notready - uncommit yourself\n");
	sprint(self, " otset    - change overtime\n");
	sprint(self, " timeset  - change timelimit\n");
	sprint(self, " ready?   - find out who is not ready\n");
	sprint(self, " unlock   - allow new players to join\n");
	sprint(self, " lock     - re-cap the team size\n");
	sprint(self, " timerstop  - pause the match\n");
	sprint(self, " timerstart - start/restart the timer\n");
	sprint(self, " ghostcode  - view your ghost code\n");
	sprint(self, " ghost - restore yourself from ghost\n");
	sprint(self, " score - show time left and score\n");
	sprint(self, " +teamscores - bind this to a key\n");
	sprint(self, " rockets  - shows who has an RL\n");
	sprint(self, " timer    - toggle on-screen timer\n");
	sprint(self, " faststart  - toggle fast match start\n");
};

//
//  S H O W  N O T  R E A D Y
//
//  Prints a list of players who are not ready.
//
void () match_show_not_ready =
{
	if (match_all_ready())
	{
		if (!elohim_numteams)
			sprint(self, "No ", elohim_szteam, "s present\n");
		else
		{
			sprint(self, "All players are ready\n");
			if (elohim_numteams == 1)
				sprint(self, "Only one ", elohim_szteam, " present\n");
		}
	}
	else
	{
		local entity player;

		sprint(self, "The following players are not ready:\n");

		player = find(world, classname, "player");
		while (player)
		{
			if (!(player.style & (ELOHIM_OBSERVER | ELOHIM_READY)) && 
				(player.style & ELOHIM_CONNECTED))
				sprint(self, " ", player.netname, "\n");
			player = find(player, classname, "player");
		}
	}
};

//
//  P A U S E  I T E M
//
void () match_pause_item =
{
	if (self.nextthink < 1)
		return;
	self.nextthink = self.nextthink + 1000000;
	self.crmod_old_velocity = self.velocity;
	self.velocity = '0 0 0';

	if (self.classname == "grenade")
		self.movetype = MOVETYPE_FLY;
};

//
//  P A U S E  P L A Y E R
//
void () match_pause_player = 
{
	if ((self.style & ELOHIM_OBSERVER) || self.deadflag)
	{
		self.crmod_old_velocity = '0 0 0';
		return;
	}

	self.finaldest_y = self.movetype = MOVETYPE_FLY;
	self.crmod_old_velocity = self.velocity;
	self.velocity = '0 0 0';
	if (self.nextthink == -1)
		return;
	self.nextthink = self.nextthink + 1000000;
};

//
//  S H O W  P A U S E
//
//  Centerprint "Paused" to all clients.
//
void () match_show_pause =
{
	WriteByte(MSG_ALL, SVC_CENTERPRINT);
	WriteString(MSG_ALL, "\{1}\{2}\{2}\{2}\{2}\{2}\{2}\{3}\n„ÐÁÕÓÅÄ†\n‡ˆˆˆˆˆˆ‰");
	elohim_match_timer.nextthink = time + 0.5;
	elohim_match_timer.think = match_show_pause;
};

//
//  P A U S E
//
//  Called after the request to pause has passed.
//
void () match_pause =
{
	if (!(elohim_state & ELOHIM_MATCH_STARTED) || (elohim_state & ELOHIM_MATCH_PAUSED))
		return;

	elohim_state = elohim_state | ELOHIM_MATCH_PAUSED;
	elohim_match_pause_time = time;
	utils_do_items(match_pause_item);
	utils_do_item(match_pause_item, "item_backpack");
	utils_do_item(match_pause_item, "plat");
	utils_do_item(match_pause_item, "train");
	utils_do_item(match_pause_item, "door");
	utils_do_item(match_pause_item, "button");
	utils_do_item(match_pause_item, "fireball");
	utils_do_item(match_pause_item, "trigger_multiple");
	utils_do_projectiles(match_pause_item);
	utils_do_players(match_pause_player);
	announce("Match paused");
	match_bprint_time();
	match_bprint_score();
	elohim_match_timer.think1 = elohim_match_timer.think;
	elohim_match_timer.cnt = elohim_match_timer.nextthink;
	match_show_pause();
};

//
//  R E Q U E S T  P A U S E
//
void () match_request_pause =
{
	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		sprint(self, "No match in progress\n");
		return;
	}
	if (elohim_state & ELOHIM_MATCH_PAUSED)
	{
		sprint(self, "Match is already paused\n");
		return;
	}

	// Do it right away if we're an administrator, otherwise vote
	if (self.style & ELOHIM_ADMINISTRATOR)
		match_pause();
	else if (vote_init("pause the match", (""), match_pause))
		vote_yes();
};

//
//  U N P A U S E  I T E M
//
void () match_unpause_item =
{
	if (self.nextthink < 1)
		return;
	self.nextthink = self.nextthink - 1000000 + elohim_match_pause_time;
	self.velocity = self.crmod_old_velocity;

	if (self.classname == "grenade")
		self.movetype = MOVETYPE_BOUNCE;
};

//
//  U N P A U S E  P L A Y E R
//
void () match_unpause_player =
{
	if (self.super_damage_finished)
		self.super_damage_finished = self.super_damage_finished + elohim_match_pause_time;
	if (self.invisible_finished)
		self.invisible_finished = self.invisible_finished + elohim_match_pause_time;
	if (self.invincible_finished)
		self.invincible_finished = self.invincible_finished + elohim_match_pause_time;
	if (self.radsuit_finished)
		self.radsuit_finished = self.radsuit_finished + elohim_match_pause_time;
	self.air_finished = self.air_finished + elohim_match_pause_time;
	self.pain_finished = self.pain_finished + elohim_match_pause_time;
	self.attack_finished = self.attack_finished + elohim_match_pause_time;

	if ((self.style & ELOHIM_OBSERVER) || self.deadflag)
		return;

	self.finaldest_y = self.movetype = MOVETYPE_WALK;
	self.velocity = self.crmod_old_velocity;
	if (self.nextthink == -1)
		return;
	self.nextthink = self.nextthink - 1000000 + elohim_match_pause_time;
};

//
//  U N P A U S E  G H O S T
//
void () match_unpause_ghost = 
{
	self.state = 0;  // clear copy-on-pause data flag
};

//
//  U N P A U S E
//
//  Called after the request to unpause has passed.
//
void () match_unpause =
{
	if (!(elohim_state & ELOHIM_MATCH_PAUSED))
		return;

	elohim_state = elohim_state - ELOHIM_MATCH_PAUSED;
	elohim_state = elohim_state - (elohim_state & ELOHIM_AUTO_PAUSED);
	elohim_match_pause_time = time - elohim_match_pause_time;
	utils_do_items(match_unpause_item);
	utils_do_item(match_unpause_item, "item_backpack");
	utils_do_item(match_unpause_item, "plat");
	utils_do_item(match_unpause_item, "train");
	utils_do_item(match_unpause_item, "door");
	utils_do_item(match_unpause_item, "button");
	utils_do_item(match_unpause_item, "fireball");
	utils_do_item(match_unpause_item, "trigger_multiple");
	utils_do_projectiles(match_unpause_item);
	utils_do_players(match_unpause_player);
	utils_do_item(match_unpause_ghost, "elohim_ghost");
	announce("Match unpaused");
	match_bprint_time();
	match_bprint_score();
	elohim_match_timer.nextthink = elohim_match_timer.cnt + elohim_match_pause_time;
	elohim_match_timer.think = elohim_match_timer.think1;
	WriteByte(MSG_ALL, SVC_CENTERPRINT);
	WriteString(MSG_ALL, " ");
};

//
//  U N P A U S E  C O U N T D O W N  T H I N K
//
void () match_unpause_countdown_think = 
{
	if (self.count > 0)
	{
		local string sz;
		sz = ftos(self.count);
		announce2(" ", sz);
		self.nextthink = time + 1;
		self.count = self.count - 1;
	}
	else
	{
		elohim_state = elohim_state - (elohim_state & ELOHIM_UNPAUSING);
		match_unpause();
		remove(self);
	}
};

//
//  S T A R T  U N P A U S E  C O U N T D O W N
//
void () match_start_unpause_countdown =
{
	local entity countdown;

	if (elohim_state & ELOHIM_UNPAUSING)
		return;

	elohim_state = elohim_state | ELOHIM_UNPAUSING;
	countdown = spawn();
	countdown.think = match_unpause_countdown_think;
	countdown.nextthink = floor(time + 1.5);
	countdown.count = 4;
	announce("Match restarts in T minus");
	announce(" 5");
};

//
//  R E Q U E S T  U N P A U S E
//
//  Request to start/restart the timer
//
void () match_request_unpause =
{
	if (elohim_state & ELOHIM_UNPAUSING)
		return;

	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		if (elohim_state & ELOHIM_TIMER_STARTED)
		{
			sprint(self, "Timer has already started\n");
			return;
		}
		if (elohim_numteams < 2)
		{
			if (!elohim_numteams)
				sprint(self, "There are no ", elohim_szteam, "s present\n");
			else
				sprint(self, "There is only one ", elohim_szteam, " present\n");
			return;
		}
		// request to force the timer to start.
		// Do it right away if we're an administrator, otherwise vote
		if (self.style & ELOHIM_ADMINISTRATOR)
			match_start_timer();
		else if (vote_init("start the timer", "", match_start_timer))
			vote_yes();
		return;
	}
	if (!(elohim_state & ELOHIM_MATCH_PAUSED))
	{
		sprint(self, "Match is not paused\n");
		return;
	}

	// Do it right away if we're an administrator, otherwise vote
	if (self.style & ELOHIM_ADMINISTRATOR)
		match_start_unpause_countdown();
	else if (vote_init("unpause the match", "", match_start_unpause_countdown))
		vote_yes();
};

//
//  S H O W  R O C K E T S
//
//  For observers, list the players that have an RL
//
void () match_show_rockets = 
{
	if (!teamplay)
	{
		sprint(self, "Command valid in match mode only\n");
		return;
	}

	if (!(self.style & ELOHIM_OBSERVER))
		return;

	if (!(elohim_state & ELOHIM_MATCH_STARTED))
	{
		sprint(self, "No match in progress\n");
		return;
	}

	if (elohim_sentinel.ammo_rockets)
	{
		local entity player;

		sprint(self, "The following players have RLs:\n");
		player = elohim_sentinel.next_player;
		while (player)
		{
			if (player.items & IT_ROCKET_LAUNCHER)
				sprint(self, player.netname, "\n");
			player = player.next_player;
		}
	}
	else
		sprint(self, "Nobody has a rocket launcher\n");
};

//
//  I M P U L S E
//
void () match_impulse =
{
	if (elohim_state & ELOHIM_TAKING_AUTOSS)
		return;

	if (self.impulse == 129)
		match_help();

	if (!(elohim_playmode & ELOHIM_MATCH_MODE))
	{
		if (self.impulse == 120)
		{
			if (self.style & ELOHIM_OBSERVER)
			{
				if (elohim_client_ready() == ELOHIM_TOO_MANY_SUICIDES)
					return;
				self.oflags = self.oflags - (self.oflags & OBSERVER_QUAKETV);	//Sputnik
				observer_end();
			}
			else
				sprint(self, "You are not an observer\n");
		}
		// TRAINING MOD
		else if ((self.impulse == 128) && (elohim_state & ELOHIM_ELOSTART))
			training_sprint_status();
		else
			sprint(self, "Command valid in match mode only\n");
		return;
	}

	if (self.impulse == 120)
		match_ready();
	else if (self.impulse == 121)
		match_notready();
	else if (self.impulse == 122)
		match_request_unlock();
	else if (self.impulse == 123)
		match_show_not_ready();
	else if (self.impulse == 124)
		match_request_pause();
	else if (self.impulse == 125)
		match_request_unpause();
	else if (self.impulse == 127)
		match_request_restore_ghost();
	else if (self.impulse == 128)
		match_sprint_status();
	else if (self.impulse == 130)
		match_request_lock();
	else if (self.impulse == 131)
		score_show_teamscores();
	else if (self.impulse == 132)
		score_restore_scoreboard();
	else if (self.impulse == 133)
		match_show_rockets();
	else if (self.impulse == 134)
		utils_toggle_flag(ELOHIM_SHOW_TIMER, "On screen timer");
};

//
//  V E R I F Y  T E A M
//
//  Called whenever self.height != self.team
//
void () match_verify_team =
{
	local string temp;

	// Allow shirt colour changes
	if (self.height == self.team - 1)
	{
		self.colours = self.cl[CL_COLORS];
		return;
	}

	if (!(elohim_playmode & ELOHIM_MATCH_MODE) || !(self.style & ELOHIM_CONNECTED))
	{
		self.height = self.team - 1;
		self.colours = self.cl[CL_COLORS];
		return;
	}

	if (!(self.style & ELOHIM_READY))
	{
		self.height = self.team - 1;
		self.colours = self.cl[CL_COLORS];
		if (self.height && (elohim_state & ELOHIM_MATCH_STARTED))
		{
			local entity e;
			for (e = elohim_sentinel.next_team ; e ; e = e.next_team)
			{
				if (self.height == e.height)
				{
					temp = strings_get_colour(self.height);
					announce3(self.netname, " has become ", temp);
				}
			}
		}
		return;
	}

	stuffcmd(self, "color ");
	temp = ftos(floor(self.colours / %16));
	stuffcmd(self, temp);
	stuffcmd(self, " ");
	temp = ftos(self.height);
	stuffcmd(self, temp);
	stuffcmd(self, "\n");
	self.team = self.height + 1;

	// THIS WAS A BUG!  (I'm leaving it in and commented so I don't do it again)
	// proquake server will not forward colour change if it thinks it's redundant.
	// self.cl[CL_COLORS] = self.colours;

	if (elohim_state & ELOHIM_MATCH_STARTED)
		announce2(self.netname, " tried to change pants");
	else
	{
		sprint(self, "You cannot change pants after\n");
		sprint(self, "you have committed\n");
	}
};

//
//  D I S C O N N E C T  N O T I F Y
//
//  Called when a player disconnects from the server or enters
//  observer mode.
//
void (entity player) match_disconnect_notify =
{
	quaketag_disconnect_notify(player);

	if (!(player.style & ELOHIM_OBSERVER))
		match_remove_player(player);

	if (!(player.style & ELOHIM_READY))
	{
		// Check to see if we need to start the timer
		if (!(elohim_state & ELOHIM_MATCH_WAIT))
		{
			if (!(elohim_state & ELOHIM_TIMER_STARTED))
			{
				if (elohim_numteams > 1)
				{
					if (match_all_ready())
						match_start_timer();
				}
			}
		}
		return;
	}

	player.style = player.style - ELOHIM_READY;
	if (player.style & ELOHIM_CONNECTED)
	{
		name_broadcast(self.netname);
		score_name_change();
	}

	// Check to see if we need to stop the match
	if (elohim_state & ELOHIM_MATCH_STARTED)
	{
		// Copy his info to his ghost
		if (!self.owner) // Sanity check added 2/6/99
			dprint("Internal error #3.  Please send mail to crbug@mpog.com\n");
		else if (!(self.style & ELOHIM_OBSERVER))
		{
			// copy always
			self.owner.frags = self.frags;
			self.owner.dest = self.dest;
			self.owner.dest1 = self.dest1;
			self.owner.dest2 = self.dest2;
			self.owner.mangle = self.mangle;
			self.owner.crmod_qdwep = self.crmod_qdwep;
			self.owner.crmod_qdkill = self.crmod_qdkill;
			self.owner.style = self.style & (ELOHIM_ADMINISTRATOR | ELOHIM_HEADS_UP | CRMOD_SMART_WEAPON | ELOHIM_AUTOSTATS);
			self.owner.crmod_hack_count = self.crmod_hack_count;
			self.owner.colours = self.colours;
			self.owner.rating = self.rating;
			self.owner.elohim_player_id = self.elohim_player_id;//Sputnik
			self.owner.dmg_given = self.dmg_given;//Sputnik
			self.owner.dmg_taken = self.dmg_taken;//Sputnik

			self.owner.name15 = @AddInt(AddInt(&(self.owner), &movedir * 4), PQUAKEC_TO_PSTRING);
			strcpy(self.owner.name15, self.name15);
			self.owner.name15text = @AddInt(AddInt(&(self.owner), &noise * 4), PQUAKEC_TO_PSTRING);
			strcpy(self.owner.name15text, self.name15text);

			// check autopause
			if (elohim_playmode & ELOHIM_AUTO_PAUSE)
			{
				match_pause();
				bprint("\bClanring Autopause Activated\n");
				dprint("Clanring autopause activated\n");
				bprint("Type 'timerstart' to restart match\n");
				elohim_state = elohim_state | ELOHIM_AUTO_PAUSED;
				match_pause_player();
			}

			// copy on pause
			if ((elohim_state & ELOHIM_MATCH_PAUSED) && (self.deadflag == DEAD_NO))
			{
				// mark data as valid
				self.owner.state = 1;

				self.owner.frame = self.frame;
				self.owner.effects = self.effects;
				self.owner.origin = self.origin;
				self.owner.angles = self.angles;
				self.owner.waterlevel = self.waterlevel;
				self.owner.watertype = self.watertype;
				self.owner.crmod_old_velocity = self.crmod_old_velocity;
				self.owner.nextthink = self.nextthink + 1000000;
				self.owner.think = self.think;
				self.owner.health = self.health;
				self.owner.items = self.items;
				self.owner.armortype = self.armortype;
				self.owner.armorvalue = self.armorvalue;
				self.owner.weapon = self.weapon;
				self.owner.weaponmodel = self.weaponmodel;
				self.owner.weaponframe = self.weaponframe;
				self.owner.currentammo = self.currentammo;
				self.owner.ammo_shells = self.ammo_shells;
				self.owner.ammo_nails = self.ammo_nails;
				self.owner.ammo_rockets = self.ammo_rockets;
				self.owner.ammo_cells = self.ammo_cells;
				self.owner.flags = self.flags;
				self.owner.walkframe = self.walkframe;
				self.owner.attack_finished = self.attack_finished;
				self.owner.pain_finished = self.pain_finished;
				self.owner.air_finished = self.air_finished;
				self.owner.invincible_finished = self.invincible_finished;
				self.owner.invisible_finished = self.invisible_finished;
				self.owner.super_damage_finished = self.super_damage_finished;
				self.owner.radsuit_finished = self.radsuit_finished;
				self.owner.invincible_time = self.invincible_time;
				self.owner.invisible_time = self.invisible_time;
				self.owner.super_time = self.super_time;
				self.owner.rad_time = self.rad_time;
				self.owner.show_hostile = self.show_hostile;
				self.owner.jump_flag = self.jump_flag;
				self.owner.swim_flag = self.swim_flag;
				self.owner.bubble_count = self.bubble_count;

				// check mega healths
				local entity mh;
				mh = find(world, classname, "item_health");
				while (mh)
				{
					if ((mh.healtype == 2) && (mh.owner == self))
						mh.owner = self.owner;
					mh = find(mh, classname, "item_health");
				}
			}
		}

		// if he's turned himself into an observer, then get rid of his ghost
		if (self.style & ELOHIM_OBSERVER)
		{
			if (self.owner)
				remove(self.owner);
			else  // Sanity check added 5/15/98
				dprint("Internal error #1.  Please send mail to crbug@mpog.com\n");

			stuffcmd(self, "alias ghostcode echo You do not have a ghost\n");
			stuffcmd(self, "alias ghost impulse 127\n");
		}
		self.owner = world;

		// check to see if he was top 2 in individual mode
		if (!teamplay && ((self == elohim_first_place) || (self == elohim_second_place)))
			score_get_top2();

		if (!match_count_players())
		{
			match_unpause();
			match_reset();
			match_delete_teams();
			announce("Match aborted");
			remove(elohim_match_timer);
			elohim_state = elohim_state - ELOHIM_TIMER_STARTED;
			elohim_state = elohim_state - ELOHIM_MATCH_STARTED;
			match_show_timelimit();
			score_resend_scoreboard();
		}
		return;
	}
	else if (teamplay > 0 && player.next_team.count == 0)
		match_remove_team(player.next_team);
	
	// JP - 5/15/98
	// Bug fix for players falling out of map.
	// For the 5 seconds after a match ends, players are "ready" but they
	// have no ghost.  So let's return before we remove world, okay? :p
	// That's what was causing it!
	if (elohim_state & ELOHIM_MATCH_WAIT)
		return;

	// He was ready but the match hadn't started, so remove his ghost
	if (self.owner)
		remove(self.owner);
	else  // Sanity check added 5/15/98
		dprint("Internal error #2.  Please send mail to crbug@mpog.com\n");
	self.owner = world;
	stuffcmd(self, "alias ghostcode echo You do not have a ghost\n");
	stuffcmd(self, "alias ghost impulse 127\n");

	// Check to see if we need to stop the timer
	if ((elohim_state & ELOHIM_TIMER_STARTED) && elohim_numteams < 2)
	{
		announce3("Only one ", elohim_szteam, " present");
		announce("Timer stopped");
		remove(elohim_match_timer);
		elohim_state = elohim_state - ELOHIM_TIMER_STARTED;
		match_show_timelimit();
	}
	
	if (!elohim_numteams)
		announce3("No ", elohim_szteam, "s present");
};
