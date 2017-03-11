//
// display.qc
//
// Manage the HUD for all players
//

string display_score;
string display_teamname;
string display_time = "XX:XX                                  \n\n\n\n\n\n\n\n\n\n";
float display_ptime;

//
//  I N I T  W O R L D
//
void () display_init_world = 
{
	display_ptime = AddInt(&display_time, PSTRING_TO_PQUAKEC);
};

//
//  U P D A T E
//
//  Observer heads-up display:
//
//     <player name> [QOR] <weapon>
//     Armour: <type> <value>  Health: <value>  Ammo: <value>
//
//  Q, O, R are the quad, ring and suit flags.  The suit flag is not really
//  an R; it's some weird quake symbol.
//
//  Observer non-heads-up display:
//
//  <enemy>
//
//  <player name>           <team up by>
//
void () display_update = 
{
    local string w;
	local entity player;	// CRMOD cameras
	local string othertarget;
	local string stime;

    // self.delay = time + 0.5;
    if ((elohim_state & ELOHIM_MATCH_PAUSED) || (self.style & (ELOHIM_SETTING_OPTIONS | ELOHIM_MOTD)))
        return;

	if (!(self.style & ELOHIM_OBSERVER))
	{
		if (self.style & ELOHIM_SHOW_TIMER)
			centerprint(self, display_time);
		return;
	}

	if (self.style & ELOHIM_SHOW_TIMER)
		stime = display_time;
	else
		stime = "\n\n\n\n\n\n\n\n\n\n";

    // CRMOD account for cameras
	player = self.movetarget;
	if ((player != world) && (player.classname == "elohim_camera"))
		player = player.movetarget;
    
    if (!player)
    {
		if (elohim_state & ELOHIM_MATCH_STARTED)
			centerprint(self, stime, "\n\n               ", display_teamname, display_score);
		else
			centerprint(self, stime);
        return;
    }

	if ((self.oflags & OBSERVER_TOURNEY) && (self.crmod_othertarget != world) && (self.movetarget.classname == "player"))
		othertarget = self.crmod_othertarget.name15;
	else
		othertarget = "";

    if (self.style & ELOHIM_HEADS_UP)
    {
		local string szflags;
		local string szrest;
		local float p, p2;

		szflags = strings_get_flags(player);
        w = strings_get_weapon(player);

		szrest = "\bArmor: X XXX  Health: XXX  Ammo: XXX ";
		p = AddInt(&szrest, PSTRING_TO_PQUAKEC);

		if (player.items & IT_INVULNERABILITY)
			p2 = AddInt(&"\br: \<\6\6\6\>", PSTRING_TO_PQUAKEC);
		else if (player.armorvalue <= 0)
			p2 = AddInt(&"\br: \bNone ", PSTRING_TO_PQUAKEC);
		else
		{
			if (player.armortype > 0.7) // 0.8 or thereabouts
				p2 = &"\br: \bR XXX ";
			else if (player.armortype > 0.5) // 0.6 or thereabouts
				p2 = &"\br: \bY XXX ";
			else
				p2 = &"\br: \bG XXX ";
			p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
			(*AddInt(p2, %5))[%0] = array_ftos4[player.armorvalue * %1];
		}
		(*p)[%1] = (*p2)[%0];
		(*p)[%2] = (*p2)[%1];
		p = AddInt(p, %22);

		if (player.health >= 0)
		{
			if (player.health < 256)
				(*p)[%0] = array_ftos4[player.health * %1];
			else
				(*p)[%0] = array_ftos4[%255];
		}
		else
		{
			p2 = AddInt(&"-99 ", PSTRING_TO_PQUAKEC);
			(*p)[%0] = (*p2)[%0];
		}
		p = AddInt(p, %11);
		(*p)[%0] = array_ftos4[player.currentammo * %1];

        centerprint(self, stime, othertarget, "                        \n\n\n",
			player.name15, szflags, w, szrest);
    }
    else
		centerprint(self, stime, othertarget, "                        \n\n",
			player.name15, display_teamname, display_score);
};

//
//  U P D A T E  A L L
//
void () display_update_all = 
{
	local float p;
	

	// compute score and teamname
	if (teamplay && (elohim_state & ELOHIM_MATCH_STARTED))
	{
		display_teamname = elohim_winning_teamname;
		if (elohim_score_number > 255 || elohim_score_number < 0)
			display_score = ftos(elohim_score_number);
		else
		{
			display_score = "xxxx";
			p = AddInt(&display_score, PSTRING_TO_PQUAKEC);
			(*p)[0] = array_ftos4[elohim_score_number * %1];
		}
	}
	else
	{
		display_score = "";
		display_teamname = "                        ";
	}

	// create the current time
	if (elohim_state & ELOHIM_TIMER_STARTED)
	{
		zone_clear_string();
		if (elohim_state & ELOHIM_MATCH_STARTED)
		{
			if (elohim_match_timer.lip == -1)  // Sudden death
			{
				zone_write_string("\bSD      ");
				proquake_send_match_time(254, 254);
			}
			else
			{
				zone_write_string(ftos(elohim_match_timer.lip));
				zone_write_string(":");
				if (elohim_match_timer.count < 10)
					zone_write_string("0");
				zone_write_string(ftos(elohim_match_timer.count));
				zone_write_string("    ");
				proquake_send_match_time(elohim_match_timer.lip, elohim_match_timer.count);
				if (!elohim_match_timer.lip)
					(*zone_pstring)[0] = OrInt((*zone_pstring)[0], 0x80808080);
			}
		}
		else
		{
			zone_write_string("-0:");
			if (elohim_match_timer.count < 10)
				zone_write_string("0");
			zone_write_string(ftos(elohim_match_timer.count));
			zone_write_string("   ");
			proquake_send_match_time(0, 128 + elohim_match_timer.count);
		}
		zone_end_string();
		(*display_ptime)[0] = (*zone_pstring)[0];
		(*display_ptime)[%1] = (*zone_pstring)[%1];
	}
	else
	{
		(*display_ptime)[0] = (*display_ptime)[%1] = 0x20202020;
		if (elohim_playmode & ELOHIM_MATCH_MODE)
			proquake_send_match_time(255, 255); // disable timer
	}

	utils_do_players(display_update);
	score_update_time();
	proquake_send_ping_times();
};