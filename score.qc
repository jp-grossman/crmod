//
// Score.qc
//
// Routines to keep track of team scores in matches.
//
// All code by J.P. Grossman unless otherwise commented
//
// Scoreboard code is incomplete; will be finished for V4.1
//

float () match_count_players;
void () match_end;
void () score_update_frags;
void () score_restore_scoreboard;

//
//  I N I T
//
//  Reset the score stuff at the start of a match
//
void () score_init = 
{
	elohim_winning_teamname = ELOHIM_STRING_TIED;
	elohim_score_number = 0;
	elohim_first_place = elohim_sentinel.next_team;
	elohim_second_place = elohim_first_place.next_team;
};

//
//  I N I T  W O R L D
//
void () score_init_world = 
{
	ELOHIM_STRING_TIED = "            Tied at ";
	elohim_score_count = 0;
};

//
//  C H E C K  S U D D E N  D E A T H
//
void () score_check_sudden_death = 
{
	self.nextthink = -1;
	if (elohim_winning_teamname != ELOHIM_STRING_TIED)
		match_end();
	else
	{
		bprint("\b\<Play On!\>\n");
		dprint("Play On!\n");
	}
};

//
//  G E T  T O P 2
//
void () score_get_top2 = 
{
	local entity pteam;

	elohim_first_place = elohim_sentinel;
	elohim_second_place = elohim_sentinel;
	pteam = elohim_sentinel.next_team;
	while (pteam)
	{
		if (pteam.frags > elohim_first_place.frags)
		{
			elohim_second_place = elohim_first_place;
			elohim_first_place = pteam;
		}
		else if (pteam.frags > elohim_second_place.frags)
			elohim_second_place = pteam;
		pteam = pteam.next_team;
	}
	if (elohim_first_place.frags > elohim_second_place.frags)
	{
		elohim_score_number = elohim_first_place.frags - elohim_second_place.frags;
		elohim_winning_teamname = strings_get_teamname_up_by(elohim_first_place.height);
	}
	else
	{
		elohim_score_number = elohim_first_place.frags;
		elohim_winning_teamname = ELOHIM_STRING_TIED;
	}
};

//
//  F R A G
//
//  Update the team frag count and the winning teamname if necessary.
//  In individual mode pteam points to a player.
//
void (entity pteam, float fragval) score_frag =
{
	local entity newent;

	// update the team score
	pteam.frags = pteam.frags + fragval;
	if (teamplay)
		proquake_send_team_frags(MSG_ALL, pteam.height, pteam.frags);

	if (fragval > 0)
	{
		if (pteam == elohim_first_place)
		{
			if (elohim_winning_teamname == ELOHIM_STRING_TIED)
			{
				elohim_score_number = 1;
				elohim_winning_teamname = strings_get_teamname_up_by(pteam.height);
			}
			else 
				elohim_score_number = elohim_score_number + 1;
		}
		else
		{
			if (pteam.frags > elohim_second_place.frags)
				elohim_second_place = pteam;

			if (pteam == elohim_second_place)
			{
				if (pteam.frags < elohim_first_place.frags)
					elohim_score_number = elohim_score_number - 1;
				else if (pteam.frags == elohim_first_place.frags) // created a tie
				{
					elohim_winning_teamname = ELOHIM_STRING_TIED;
					elohim_score_number = pteam.frags;
				}
				else // broke a tie
				{
					elohim_second_place = elohim_first_place;
					elohim_first_place = pteam;
					elohim_score_number = 1;
					elohim_winning_teamname = strings_get_teamname_up_by(pteam.height);
				}
			}
		}
	}
	else
	{
		if (pteam == elohim_first_place)
		{
			if (pteam.frags > elohim_second_place.frags)
				elohim_score_number = elohim_score_number - 1;
			else if (pteam.frags == elohim_second_place.frags) // created a tie
			{
				elohim_winning_teamname = ELOHIM_STRING_TIED;
				elohim_score_number = pteam.frags;
			}
			else // oh-oh
				score_get_top2();		
		}
		else if (pteam == elohim_second_place) // uh-oh
			score_get_top2();
	}

	if (elohim_match_timer.lip < 0) // Sudden death!
	{
		elohim_sentinel.think = score_check_sudden_death;
		elohim_sentinel.nextthink = time + 1;
	}

	if (elohim_score_count && teamplay)
	{
		newent = utils_make_scheduled_event(score_update_frags, 0.1);
		newent.next_team = pteam;
	}
};

//
//  W R I T E  N A M E
//
//  Update the given client's name to msg_entity
//
void (float client, string name) score_write_name =
{
	WriteByte(MSG_ONE, SVC_UPDATENAME);
	WriteByte(#, client);
	WriteString(#, name);
};

//
//  W R I T E  F R A G S
//
//  Update the given client's frags to msg_entity
//
void (float client, float fragval) score_write_frags =
{
	WriteByte(MSG_ONE, SVC_UPDATEFRAGS);
	WriteByte(#, client);
	WriteShort(#, fragval);
};

//
//  W R I T E  C O L O U R
//
//  Update the given client's colour to msg_entity
//
void (float client, float colour) score_write_colour =
{
	WriteByte(MSG_ONE, SVC_UPDATECOLORS);
	WriteByte(#, client);
	WriteByte(#, colour);
};

//
//  W R I T E  T I M E
//
//  Update 'time remaining" to msg_entity in the given slot
//
void (float client) score_write_time = 
{
	WriteByte(MSG_ONE, SVC_UPDATENAME);
	WriteByte(MSG_ONE, client);
	if (elohim_state & ELOHIM_MATCH_OVER)
		WriteString(MSG_ONE, "Match Over");
	else if (elohim_match_timer.lip < 0)
		WriteString(MSG_ONE, "Sudden death");
	else if (elohim_state & ELOHIM_MATCH_STARTED)
	{
        local float minutes;
        local float seconds;
		local float temp;
    
        minutes = elohim_match_timer.lip;
        seconds = elohim_match_timer.count;
		
		if (minutes > 9)
		{
			temp = floor(minutes / 10);
			minutes = minutes - temp * 10;
			WriteByte(MSG_ONE, 48 + temp);
		}
		temp = floor(seconds / 10);
		seconds = seconds - temp * 10;
		WriteByte(MSG_ONE, 48 + minutes);
		WriteByte(#, 58);
		WriteByte(#, 48 + temp);
		WriteByte(#, 48 + seconds);
		WriteString(#, " remaining");
	}
	else
	{
		zone_clear_string();
		zone_write_string("T Minus ");
		zone_write_string(ftos(elohim_match_timer.count));
		zone_end_string();
		WriteString(MSG_ONE, zone_string);
	}
};

//
//  F I X  C O N N E C T
//
//  Called when a new client connects since that will mess up the scoreboard.
//
void () score_fix_connect = 
{
	// find all players looking at scores, and fix the scoreboard
	msg_entity = find(world, classname, "player");
	while(msg_entity)
	{
		if (msg_entity.style & ELOHIM_SCOREBOARD)
		{
			if (msg_entity.style & ELOHIM_CONNECTED)
			{
				if (self.colormap == msg_entity.timeslot)
					score_write_time(msg_entity.timeslot);
				else
					score_write_name(self.colormap, "");
			}
		}
		msg_entity = find(msg_entity, classname, "player");
	}	
	remove(self);
};

//
//  N A M E  C H A N G E
//
//  If someone's looking at teamscores we might need to patch up their scoreboard
//
void () score_name_change = 
{
	if (!elohim_score_count)
		return;

	local entity e;

	e = utils_make_scheduled_event(score_fix_connect, 0.1);
	e.colormap = self.colormap - 1;
};

//
//  F I X  D I S C O N N E C T
//
//  If a player disconnects, they could mess up the scoreboard if we were
//  using their slot.
// 
void () score_fix_disconnect = 
{
	// find all players looking at scores, and fix the scoreboard
	msg_entity = find(world, classname, "player");
	while(msg_entity)
	{
		if (msg_entity.style & ELOHIM_SCOREBOARD)
		{
			if (msg_entity.style & ELOHIM_CONNECTED)
			{
				if (self.next_team != world && self.next_team.next_player != world)
				{
					score_write_name(self.next_team.next_player.colormap - 1, self.next_team.mdl);
					score_write_frags(self.next_team.next_player.colormap - 1, self.next_team.frags);
				}
				else if (self.colormap == msg_entity.timeslot)
					score_write_time(msg_entity.timeslot);
			}
		}
		msg_entity = find(msg_entity, classname, "player");
	}	
	remove(self);
};

//
//  C L I E N T  D I S C O N N E C T
//
//  If someone's looking at teamscores we might need to patch up their scoreboard.
//  Also check to see if *they* were looking at the scoreboard.
//
void () score_client_disconnect = 
{
	if (!elohim_score_count)
		return;

	local entity e;

	e = utils_make_scheduled_event(score_fix_disconnect, 0.1);
	e.colormap = self.colormap - 1;

	if (teamplay > 0 && self.next_team.next_player == self)
		e.next_team = self.next_team;
	else
		e.next_team = world;

	if (self.style & ELOHIM_SCOREBOARD)
		elohim_score_count = elohim_score_count - 1;
};

//
//  S H O W  T E A M S C O R E S
//
void () score_show_teamscores = 
{
	local entity e;

	if (self.style & ELOHIM_SCOREBOARD)
		return;

    if (!(elohim_state & (ELOHIM_TIMER_STARTED | ELOHIM_MATCH_OVER)))
		return;

	msg_entity = self;
	self.style = self.style | ELOHIM_SCOREBOARD;
	elohim_score_count = elohim_score_count + 1;

	// first erase the scoreboard and find a slot for the time remaining
	self.timeslot = -1;
	e = find(world, classname, "player");
	while(e)
	{
		if (e.style & ELOHIM_CONNECTED)
		{
			if (teamplay || (e.style & ELOHIM_OBSERVER) || !(elohim_state & (ELOHIM_MATCH_STARTED | ELOHIM_MATCH_OVER)))
				score_write_name(e.colormap - 1, "");
			if ((self.timeslot == -1) && (e.style & ELOHIM_OBSERVER))
				self.timeslot = e.colormap - 1;
		}
		else if (self.timeslot == -1)
		{
			self.timeslot = e.colormap - 1;
			score_write_colour(self.timeslot, 0);
			score_write_frags(self.timeslot, -99);
		}
		e = find(e, classname, "player");
	}

	// make sure we have a slot for time
	if (self.timeslot == -1)
	{
		if (match_count_players() < 8)
		{
			// 7 is unused - grab it
			self.timeslot = 7;
			score_write_colour(7, 0);
			score_write_frags(7, -99);
		}
		else if (teamplay > 0)
		{
			// oh well - take what we can get
			e = find(world, classname, "player");
			while (e)
			{
				local float c;

				c = e.colormap - 1;
				if (e.next_team.next_player != e)
				{
					self.timeslot = c;
					score_write_frags(c, -99);
					e = world;
				}
				else
					e = find(e, classname, "player");
			}
		}
	}

	// If we still don't have a timeslot then abort
	if (self.timeslot == -1)
	{
		score_restore_scoreboard();
		return;
	}
	
	// send the teamscores
	if (teamplay && (elohim_state & (ELOHIM_MATCH_STARTED | ELOHIM_MATCH_OVER)))
	{
		e = elohim_sentinel.next_team;
		while (e)
		{
			if (e.count)
			{
				score_write_name(e.next_player.colormap - 1, e.mdl);
				score_write_frags(e.next_player.colormap - 1, e.frags);
			}
			e = e.next_team;
		}
	}

	// now send the time
	score_write_time(self.timeslot);
};

//
//  R E S T O R E  S C O R E B O A R D
//
//  Restore a client's scoreboard after they finish looking at team scores
//
void () score_restore_scoreboard = 
{
	local entity e;

	if (!(self.style & ELOHIM_SCOREBOARD))
		return;

	msg_entity = self;
	self.style = self.style - ELOHIM_SCOREBOARD;
	elohim_score_count = elohim_score_count - 1;

	// Clear time remaining seperately since it might not be a client
	score_write_name(self.timeslot, "");

	e = find(world, classname, "player");
	while(e)
	{
		if (e.style & ELOHIM_CONNECTED)
		{
			score_write_name(e.colormap - 1, e.netname);
			score_write_frags(e.colormap - 1, e.frags);
		}
		e = find(e, classname, "player");
	}
	name_send_names();
};

//
//  U P D A T E  F R A G S
//
//  Update frags for everyone who's looking at teamscores
//
void () score_update_frags = 
{
	msg_entity = find(world, classname, "player");
	while(msg_entity)
	{
		if (msg_entity.style & ELOHIM_SCOREBOARD)
		{
			if (msg_entity.style & ELOHIM_CONNECTED)
				score_write_frags(self.next_team.next_player.colormap - 1, self.next_team.frags);
		}
		msg_entity = find(msg_entity, classname, "player");
	}	
	remove(self);
};

//
//  U P D A T E  T I M E
//
//  Update the time for everyone who's looking at teamscores
//
void () score_update_time = 
{
	if (!elohim_score_count)
		return;

	msg_entity = find(world, classname, "player");
	while(msg_entity)
	{
		if (msg_entity.style & ELOHIM_SCOREBOARD)
		{
			if (msg_entity.style & ELOHIM_CONNECTED)
				score_write_time(msg_entity.timeslot);
		}
		msg_entity = find(msg_entity, classname, "player");
	}	
};

//
//  R E S E N D  S C O R E B O A R D
//
//  Re-send the scoreboard at the start of a match.
//
void () score_resend_scoreboard = 
{
	local entity oself;

	oself = self;
	self = find(world, classname, "player");
	while (self)
	{
		if (self.style & ELOHIM_SCOREBOARD)
		{
			if (self.style & ELOHIM_CONNECTED)
			{
				score_restore_scoreboard();
				score_show_teamscores();
			}
		}
		self = find(self, classname, "player");
	}	
	self = oself;
};
