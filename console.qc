//
// Console.qc
//
// This file contains code to implement server console directives.
//
// All code by J.P. Grossman unless otherwise commented.
//

// constants
float CONSOLE_ENT_YAW = 1;
float CONSOLE_ENT_PITCH = 2;
float CONSOLE_ENT_ROLL = 4;

// global variables
vector console_origin;
float  console_byte_count;

void () console_byte_aliases;

//
//  S E T  A L I A S E S
//
//  Called once when the server is initialized.
//
void () console_set_aliases =
{
    // set local aliases (server console commands)

	// immediate mode commands
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		localcmd("alias sping temp1 1\n");
		localcmd("alias time temp1 2\n");
		localcmd("alias s temp1 3\n");
		localcmd("alias debug temp1 4\n");
		localcmd("alias score temp1 5\n");
		localcmd("alias ghostlist temp1 6\n");
		localcmd("alias killstats temp1 7\n");
		localcmd("alias efficiency temp1 8\n");
		localcmd("alias eff temp1 8\n");
		localcmd("alias stats temp1 9\n");
		localcmd("alias commands temp1 10\n");
		localcmd("alias vinfo temp1 11\n");
		localcmd("alias normal temp1 12\n");
		localcmd("alias ffa temp1 12\n");
		localcmd("alias practice temp1 13\n");
		localcmd("alias match temp1 14\n");
		localcmd("alias individual temp1 15\n");
		localcmd("alias quadstats temp1 16\n");
		localcmd("alias badstats temp1 18\n");
		localcmd("alias teamstats temp1 19\n");

		localcmd("alias admins temp1 90\n");
		localcmd("alias ips temp1 91\n");
		localcmd("alias bans temp1 92\n");
		localcmd("alias crban \"temp1 93;wait\"\n");
		localcmd("alias unban temp1 94\n");
		localcmd("alias ratings temp1 95\n");
		localcmd("alias a temp1 99\n");
	}
	localcmd("alias settings temp1 17\n");
	
	// config file commands
	localcmd("alias safepracticeon \"temp1 20;wait\"\n");
	localcmd("alias safepracticeoff \"temp1 21;wait\"\n");
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		localcmd("alias nogibs \"temp1 22;wait\"\n");
		localcmd("alias lowgibs \"temp1 23;wait\"\n");
		localcmd("alias highgibs \"temp1 24;wait\"\n");
	}
	localcmd("alias quadon \"temp1 25;wait\"\n");
	localcmd("alias quadoff \"temp1 26;wait\"\n");
	localcmd("alias penton \"temp1 27;wait\"\n");
	localcmd("alias pentoff \"temp1 28;wait\"\n");
	localcmd("alias ringon \"temp1 29;wait\"\n");
	localcmd("alias ringoff \"temp1 30;wait\"\n");
	localcmd("alias modevoteon \"temp1 31;wait\"\n");
	localcmd("alias modevoteoff \"temp1 32;wait\"\n");
	localcmd("alias obitson \"temp1 33;wait\"\n");
	localcmd("alias obitsoff \"temp1 34;wait\"\n");
	localcmd("alias setovertime \"temp1 36;wait\"\n");
	localcmd("alias maxteams \"temp1 37;wait\"\n");
	localcmd("alias faststarton \"temp1 38;wait\"\n");
	localcmd("alias faststartoff \"temp1 39;wait\"\n");
	localcmd("alias freshspawnson \"temp1 40;wait\"\n");
	localcmd("alias freshspawnsoff \"temp1 41;wait\"\n");
	localcmd("alias nopractice \"temp1 42;wait\"\n");
	localcmd("alias autopauseon \"temp1 43;wait\"\n");
	localcmd("alias autopauseoff \"temp1 44;wait\"\n");
	localcmd("alias autostatson \"temp1 45;wait\"\n");
	localcmd("alias autostatsoff \"temp1 46;wait\"\n");
	localcmd("alias setafk \"temp1 47;wait\"\n");
	localcmd("alias kickafk \"temp1 48;wait\"\n");
	localcmd("alias novoteadmin \"temp1 49;wait\"\n");

	// more config file commands
	localcmd("alias levelvoteon \"temp1 200;wait\"\n");
	localcmd("alias levelvoteoff \"temp1 201;wait\"\n");

	// entity file commands
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		localcmd("alias newspawn \"temp1 50;wait\"\n");
		localcmd("alias newstart \"temp1 51;wait\"\n");
		localcmd("alias killspawn \"temp1 52;wait\"\n");
		localcmd("alias makecam \"temp1 53;wait\"\n");
		localcmd("alias killitem \"temp1 54;wait\"\n");
		localcmd("alias makeitem \"temp1 55;wait\"\n");
		localcmd("alias changeitem \"temp1 56;wait\"\n");
	}

	// control commands
	localcmd("alias [init] \"temp1 60;wait\"\n");
	localcmd("alias [normal] \"temp1 61;wait\"\n");
	localcmd("alias [practice] \"temp1 62;wait\"\n");
	localcmd("alias [match] \"temp1 63;wait\"\n");
	localcmd("alias [individual] \"temp1 64;wait\"\n");
	localcmd("alias [all] \"temp1 65;wait\"\n");
	localcmd("alias [done] \"temp1 66;wait\"\n");

	// undocumented debug commands
    localcmd("alias debugclient temp1 70\n");
    localcmd("alias debugoff temp1 71\n");
    localcmd("alias stuffimpulse temp1 72\n");
    localcmd("alias stuffcolor temp1 73\n");
    localcmd("alias debugcflags temp1 74\n");
	localcmd("alias debugsflags temp1 75\n");
	localcmd("alias debugcinfo temp1 76\n");
	localcmd("alias debughelp temp1 77\n");

	// admin passwords
	localcmd("alias setpass \"temp1 80;wait\"\n");
	localcmd("alias setpass1 \"temp1 81;wait\"\n");
	localcmd("alias setpass2 \"temp1 82;wait\"\n");
	localcmd("alias setpass3 \"temp1 83;wait\"\n");
	localcmd("alias setpass4 \"temp1 84;wait\"\n");
	localcmd("alias setpass5 \"temp1 85;wait\"\n");
	localcmd("alias setpass6 \"temp1 86;wait\"\n");
	localcmd("alias setpass7 \"temp1 87;wait\"\n");
	localcmd("alias setpass8 \"temp1 88;wait\"\n");
	localcmd("alias setpass9 \"temp1 89;wait\"\n");

	// stat_ids : sputnik (3/15/2017 12:10PM)
	localcmd("alias setid \"temp1 2000;wait;\"\n");	

    //
    // create map aliases - used for reading levels.cfg
    //
    // e.g.:  alias start "temp1 100;wait"
    //
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		local float temp;
		local string szTemp, szName;

		for (temp = 100 ; temp < 170 ; temp = temp + 1)
		{
			szName = strings_get_mapname(temp - 100);
			if (szName != "")
			{
				szTemp = ftos(temp);
				localcmd5("alias ", szName, " \"temp1 ", szTemp, ";wait\"\n");
			}
		}

		utils_make_scheduled_event(console_byte_aliases, 0.5);
	}
};

void () console_byte_aliases = 
{
	local string szTemp;
	local float i;

	// create byte aliases - hope this doesn't crash the server!
	for (i = 1000 ; i < 1256 ; i = i + 1)
	{
		szTemp = ftos(i - 1000);
		localcmd3("alias ", szTemp, " \"temp1 ");
		szTemp = ftos(i);
		localcmd2(szTemp, ";wait\"\n");
	}
	console_byte_count = 0;

	remove(self);
};

//
//  P R I N T  P I N G
// 
void (entity player) console_print_ping =
{
	local float ping, i;
	ping = 0;
	for (i = 0 ; i < %16 ; i = i + %1)
		ping = ping + player.cl[i + CL_PING_TIMES];
	ping = floor(ping * 1000 / 16);
	if (ping < 1000)
		dprint(" ");
	if (ping < 100)
		dprint(" ");
	if (ping < 10)
		dprint(" ");
	dprint(ftos(ping));
};

//
//  P I N G
//
void () console_ping =
{
	local entity player;

	dprint("Client ping times:\n");
	player = find(world, classname, "player");
	while (player)
	{
		if (player.style & ELOHIM_CONNECTED)
		{
			console_print_ping(player);
			dprint(" ", player.name15text, "\n");
		}
		player = find(player, classname, "player");
	}
};

//
//  S H O W  T I M E
//
//  Show the elapsed time on the server console.
//
void () console_show_time = 
{
    local float h, m, s, t;

    h = floor(time / 3600);
    t = time - h * 3600;
    m = floor(t / 60);
    t = t - m * 60;
    s = rint(t);

    dprint("time = ");
    if (h > 0)
    {
        dprint(ftos(h), ":");
        if (m < 10)
            dprint("0");
    }
    dprint(ftos(m), ":");
    if (s < 10)
        dprint("0");
    dprint(ftos(s), "\n");
};

//
//  S H O W  S T A T U S
//
//  Show the elapsed time and status on the server console.
//
void () console_show_status = 
{
    local float mode;
    local string szmode;

    dprint("\n");                    
    mode = options_get_mode();
    szmode = strings_get_mode(mode);
    dprint(szmode, " mode\n");
    console_show_time();
    localcmd("status;echo\n");
};

//
//  S H O W  D E B U G  I N F O
//
//  Used for development.  Similar to elohim_debug_info, but prints to the
//  server console.
//
void () console_show_debug_info =
{
    local entity e;
	local float p;

    dprint("clients:\n");
    e = find(world, classname, "player");
    while (e)
    {
        local string temp;
        temp = ftos(e.colormap);
        if (e.style & ELOHIM_CONNECTED)
            dprint(temp, " ", e.name15text, " - Connected\n");            
        else
            dprint(temp, " ", e.name15text, " - Disconnected\n");
        e = find(e, classname, "player");
    }

	p = AddInt(&sv, 4 * SV_MODELNAME);
	p = AddInt(p, PQUAKEC_TO_PSTRING);
	dprint("modelname = ", @p, "\n");
};

//
//  S H O W  S C O R E
//
//  Print the time remaining and the score.
//
void () console_show_score =
{
    local float team1, team2;

	if (!(elohim_playmode & ELOHIM_MATCH_MODE))
	{
		dprint("Command valid in match mode only\n");
		return;
	}

 	if (!(elohim_state & (ELOHIM_MATCH_STARTED | ELOHIM_MATCH_OVER)))
	{
		if (elohim_state & ELOHIM_TIMER_STARTED)
		{
			local string s, pl;
			s = ftos(elohim_match_timer.count);
			pl = strings_szplural(elohim_match_timer.count);
			dprint("Match begins in ", s, " second", pl, "\n");
		}
		else
			dprint("Waiting for ", elohim_szteam, "s\n");
        return;
	}

    dprint("\n");
    if (elohim_state & ELOHIM_MATCH_OVER)
        dprint("Match over\n");
    else if (elohim_match_timer.lip < 0)
		dprint("Sudden death overtime\n");
	else
    {
        local string temp;
    
        temp = ftos(elohim_match_timer.lip);
        dprint("Time remaining:  ", temp, ":");
        temp = ftos(elohim_match_timer.count);
        if (elohim_match_timer.count < 10)
            dprint("0");
        dprint(temp, "\n");
    }

    local string score;
    local string temp;

	if (elohim_first_place != elohim_sentinel)
	{
		score = ftos(elohim_first_place.frags);
		temp = strings_szplural(elohim_first_place.frags);
		dprint(elohim_szthe, elohim_first_place.netname, " has ", score, " frag", temp, "\n");
	}
	if (elohim_second_place != elohim_sentinel)
	{
		score = ftos(elohim_second_place.frags);
		temp = strings_szplural(elohim_second_place.frags);
		dprint(elohim_szthe, elohim_second_place.netname, " has ", score, " frag", temp, "\n");
	}
    dprint("\n");
};

//
//  L I S T  G H O S T S
//
void () console_list_ghosts =
{
    local entity e;
    e = find(world, classname, "elohim_ghost");
    if (!e)
    {
        dprint("There are no ghosts\n");
        return;
    }
    dprint("\n");
	if (teamplay)
		dprint("      name       | code |    team    | frags \n");
	else
		dprint("      name       | code |   colour   | frags \n");
	dprint("-----------------+------+------------+-------\n");
    while (e)
    {
        if (e.owner.owner != e)
		{
			local string num, szTeam, pad;
			local float frag;
			num = ftos(e.count);

	        dprint(" ", e.name15text, " |  ", num, "  | ");
            frag = e.frags;
    
			szTeam = strings_get_teamname2(e.height);
			if (frag < -99)
				pad = " | ";
			else if (frag < -9)
				pad = " |  ";
			else if (frag < 0)
				pad = " |   ";
			else if (frag < 10)
				pad = " |    ";
			else if (frag < 100)
				pad = " |   ";
			else
				pad = " |  ";
			num = ftos(frag);
			dprint(szTeam, pad, num, "\n");
		}
        e = find(e, classname, "elohim_ghost");
    }
    dprint("\n");
};

//
//  S H O W  K I L L S T A T S
//
void () console_show_killstats =
{
    local entity player;

    dprint(" Id# |    KILLSTATS    | frags | enemies | self | teammates | killed | dmgGvn | dmgTkn \n");
    dprint("-----+-----------------+-------+---------+------+-----------+--------+--------+--------\n");

	player = elohim_sentinel.owner.next_player;
    while (player)
    {    	
    	dprint(" ");
    	utils_cprint_int3(player.elohim_player_id);
    	dprint(" |");
        dprint(" ", player.name15text, " |  ");
        utils_cprint_int3(player.frags);
        dprint("  |   ");
        utils_cprint_int3(player.frags + player.mangle_x + player.mangle_y);
        dprint("   | ");
        utils_cprint_int3(player.mangle_x);
        dprint("  |    ");
        utils_cprint_int3(player.mangle_y);
        dprint("    |   ");
        utils_cprint_int3(player.mangle_z);
		dprint("  |  ");
		utils_cprint_int5(player.dmg_given);
		dprint(" |  ");
		utils_cprint_int5(player.dmg_taken);
        dprint(" \n");                    
        player = player.next_player;
    }
    dprint("\n");                    
};

//
//  P R I N T  P E R C E N T 4
//
//  Helper function for console_show_efficiency.  Prints the percentage
//  100 * (frac / tot) as a 4 character integer, or N/A if tot = 0.
//
void (float frac, float tot) console_print_percent4 =
{
    if (tot)
    {
        local float n;

        n = floor(100 * frac / tot);
        if (n < 100)
            dprint(" ");
        if (n < 10)
            dprint(" ");
        dprint(ftos(n), "%");
    }
    else
        dprint("N/A ");
};


//
// CRMOD
//  S H O W  Q U A D S T A T S
//		by Paul Baker
//
void () console_show_quadstats =
{
	local entity player, pteam;
	local float useteams;
	local string teamname;

	if (teamplay && ((elohim_state & ELOHIM_MATCH_STARTED) || (elohim_sentinel.owner != elohim_sentinel)))
		useteams = TRUE;
	else
		useteams = FALSE;

	dprint(" Id# |    QUADSTATS    | quads | efficiency | enemy | self  | teammates \n");
	dprint("-----+-----------------+-------+------------+-------+-------+-----------\n");
	
	player = elohim_sentinel.owner.next_player;
	pteam = player.next_team;
	
    while (player)
    {
    	dprint(" ");
    	utils_cprint_int3(player.elohim_player_id);
    	dprint(" |");
        dprint(" ", player.name15text, " |  ");
        utils_cprint_int3(player.crmod_qdwep_z);
        dprint("  |    ");
        console_print_percent4(player.crmod_qdwep_x, player.crmod_qdwep_y);
        dprint("    |  ");
        utils_cprint_int3(player.crmod_qdkill_x);
        dprint("  |  ");
        utils_cprint_int3(player.crmod_qdkill_z);
        dprint("  |    ");
        utils_cprint_int3(player.crmod_qdkill_y);
        dprint("\n");
        player = player.next_player;

		if (useteams && (player.next_team != pteam))
		{
			dprint(" ", pteam.name15text, " | [");
			utils_cprint_int3(pteam.dest2_x);
			dprint("] |            |       |       |\n");
			pteam = player.next_team;
		}
    }
	dprint("\n");
};

//
//  S H O W  B A D S T A T S
//
void () console_show_badstats =
{
    local entity player;
	local float tot_enemy, tot_done;

	if (!(elohim_playmode & ELOHIM_MATCH_MODE) || !teamplay)
	{
		dprint("badstats valid in match mode only\n");
		return;
	}

    dprint(" Id# |    BADSTATS     | paks | self | team \n");
    dprint("-----+-----------------+------+------+------\n");

    player = elohim_sentinel.owner.next_player;
    while (player)
    {
        tot_enemy = player.dest2_x + player.dest2_y + player.dest2_z + player.dest_y;
		tot_done = tot_enemy + player.crmod_badstats_y + player.crmod_badstats_z;
    	dprint(" ");
    	utils_cprint_int3(player.elohim_player_id);
    	dprint(" |");
        dprint(" ", player.name15text, " |  ");
        utils_cprint_int3(player.crmod_badstats_x);
        dprint(" | ");
		console_print_percent4(player.crmod_badstats_y, tot_done);
        dprint(" | ");
		console_print_percent4(player.crmod_badstats_z, tot_done);
        dprint("\n");
        player = player.next_player;
    }
    dprint("\n");
};

//
//  S H O W  E F F I C I E N C Y
//
void () console_show_efficiency =
{
    local entity player;
    local float tot_fired, tot_done;

    dprint(" Id# |   EFFICIENCY    | bullets | nails | rockets | lightning | total \n");
    dprint("-----+-----------------+---------+-------+---------+-----------+-------\n");

    player = elohim_sentinel.owner.next_player;
    while (player)
    {
    	dprint(" ");
    	utils_cprint_int3(player.elohim_player_id);
    	dprint(" |");
 	
        dprint(" ", player.name15text, " |  ");
        console_print_percent4(player.dest2_x, player.dest1_x);
        dprint("   | ");
        console_print_percent4(player.dest2_y, player.dest1_y);
        dprint("  |  ");
        console_print_percent4(player.dest_y, player.dest_x);
        dprint("   |   ");
        console_print_percent4(player.dest2_z, player.dest1_z);
        dprint("    | ");

        tot_fired = player.dest1_x + player.dest1_y + player.dest1_z + player.dest_x;
        tot_done = player.dest2_x + player.dest2_y + player.dest2_z + player.dest_y;
        console_print_percent4(tot_done, tot_fired);
		dprint("\n");
        player = player.next_player;
    }
    dprint("\n");
};

//
//  S H O W  S T A T S
//
//  Summary: show kill and weapon efficiency for each player.
//
void () console_show_stats =
{
    local entity player;
    local float wfrac, wtot, kfrac, ktot, useteams;
    local string teamname;
	local float p;

	if ((elohim_playmode & ELOHIM_MATCH_MODE) && teamplay)
		useteams = TRUE;
	else
		useteams = FALSE;

	dprint(" Id# |   PLAYERSTATS   |");
	if (useteams)
		dprint("    team    |");
	dprint(" kill | weapon | ping | IP\n");
	dprint("-----+-----------------+");
	if (useteams)
		dprint("------------+");
	dprint("------+--------+------+----------------\n");

	player = elohim_sentinel.owner.next_player;
    while (player)
    {
    	dprint(" ");
    	utils_cprint_int3(player.elohim_player_id);
    	dprint(" |");
    	
        dprint(" ", player.name15text, " | ");
        if (useteams)
		{
			teamname = strings_get_teamname2(player.height);
            dprint(teamname, " | ");
		}
        kfrac = player.frags + player.mangle_x + player.mangle_y;
        ktot = kfrac + player.mangle_x + player.mangle_y + player.mangle_z;
        wtot = player.dest1_x + player.dest1_y + player.dest1_z + player.dest_x;
        wfrac = player.dest2_x + player.dest2_y + player.dest2_z + player.dest_y;
        console_print_percent4(kfrac, ktot);
        dprint(" |  ");
        console_print_percent4(wfrac, wtot);
		dprint("  | ");
		console_print_ping(player);
		dprint(" | ");
		p = AddInt(AddInt(&player.qs, 4 * QS_ADDRESS + %32), PQUAKEC_TO_PSTRING);
		dprint(@p, "\n");
		player = player.next_player;
    }
    dprint("\n");
};

//
//  F O R M A T  V E C T O R
//
//  prints xx:yy:zz to self
//
void (vector v) console_format_vector = 
{
	dprint("| ");
	if (v_x < 10)
		dprint(" ");
	dprint(ftos(v_x), " : ");
	if (v_y < 10)
		dprint(" ");
	dprint(ftos(v_y), " : ");
	if (v_z < 10)
		dprint(" ");
	dprint(ftos(v_z), " ");
};

//
//  S H O W  T E A M  S T A T S
//
void () console_show_teamstats = 
{
	local entity pteam;
	local string s;

	if (!(teamplay && (elohim_playmode & ELOHIM_MATCH_MODE)))
	{
		dprint("Teamstats valid in match mode only\n");
		return;
	}

	if (!elohim_sentinel.owner.next_team)
	{
		dprint("No teams\n");
		return;
	}

	dprint("   TEAMSTATS   ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		s = strings_get_teamname2(pteam.height);
		dprint("|  ", s, "  ");
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("---------------");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		dprint("+--------------");
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("Q : 666 : Ring ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		console_format_vector(pteam.dest2);		
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("RL : LG : GL   ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		console_format_vector(pteam.dest1);		
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("SNG : NG : MH  ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		console_format_vector(pteam.pos1);
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("RA : YA : GA   ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		console_format_vector(pteam.dest);		
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("+RLPak : -RLPak");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		dprint("|  ");
		s = ftos(pteam.mangle_y);
		if (pteam.mangle_y < 10)
			dprint(" ");
		dprint("+", s, "   ");
		s = ftos(pteam.mangle_z);
		if (pteam.mangle_z < 10)
			dprint(" ");
		dprint("-", s, "   ");
		pteam = pteam.next_team;
	}
	dprint("\n");
	dprint("Control        ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		local float f;
		local float control;
		control = 100 * pteam.mangle_x / elohim_sentinel.cnt;
		f = floor(control);
		s = ftos(f);
		dprint("|     %", s);
		f = floor((control - f) * 10);
		s = ftos(f);
		dprint(".", s, "    ");
		if (control < 10)
			dprint(" ");
		pteam = pteam.next_team;
	}
	dprint("\n\n");
};

//
//  A U T O D U M P
//
//  Dump statistics if server has autostats enabled.
//
void () console_autodump = 
{
	local string temp;

	if (elohim_playmode & ELOHIM_AUTOSTATS)
	{
		dprint("\n");
		dprint("- CRMod Match Statistics - \n");
		dprint("\n");
		dprint(ftos(elohim_timelimit), " minute ");
		temp = ftos(elohim_maxsize);
		dprint(temp, "v", temp, " match on ", mapname, "\n\n");
		console_show_stats();
		console_show_quadstats();
		if ((elohim_playmode & ELOHIM_MATCH_MODE) && teamplay)
			console_show_badstats();
		console_show_efficiency();
		console_show_killstats();
		console_show_teamstats();
	}
};

//
//  C O M M A N D S
//
//  Show a list of valid commands (dedicated only)
//
void () console_commands =
{
    dprint("\n");
    dprint("Clanring CRMod++ v", crmod_version_number, " console commands:\n");
    dprint("\n");
	dprint("s      - view server status             settings  - view server settings      \n");
	dprint("vinfo  - version information            ghostlist - view list of ghosts       \n");
	dprint("sping  - approximate client pings       setpass   - set password (use 'skill')\n");
	dprint("time   - time elapsed on current map    maxteams  - set maxteams (use 'skill')\n");
	dprint("score  - match score/time remaining     otset     - set overtime (use 'skill')\n");
	dprint("admins - list administrators            ips       - list player ip addresses  \n");
	dprint("setafk - set afk time (use 'skill')     kickafk   - afk kick time (use 'skill')\n");
	dprint("crban  - ban! (e.g. 24;18;2;4;crban)    unban     - unban (eg 24;18;2;4;unban)\n");
	dprint("bans   - list bans                      ratings   - show player ratings       \n");
	dprint("\n");
	dprint("stats     killstats     efficiency      quadstats     badstats     teamstats\n");
	dprint("\n");
	dprint("settings:\n");
	dprint("\n");
	dprint("normal              practice            match               individual\n");
	dprint("nopractice          highgibs            lowgibs             nogibs\n");
	dprint("quadon              quadoff             penton              pentoff\n");
	dprint("ringon              ringoff             freshspawnson       freshspawnsoff\n");
	dprint("faststarton         faststartoff        autopauseon         autopauseoff\n");
	dprint("modevoteon          modevoteoff         safepracticeon      safepracticeoff\n");
	dprint("obitson             obitsoff            autostatson         autostatsoff\n");
	dprint("levelvoteon         levelvoteoff        novoteadmin\n");
};

//
//  D E B U G  C L I E N T
//
//  Enter debug mode for the client indicated by cvar 'skill'.
//
void () console_debug_client =
{
    local float id;
    local entity client;

	if (console_byte_count != %1)
	{
		dprint("usage:  2;debugclient\n");
		console_byte_count = 0;
		return;
	}
	console_byte_count = 0;
    id = array_console_byte[0];
    client = find(world, classname, "player");
    while (client)
    {
        if (client.colormap == id)
        {
            elohim_debug_client = client;
            dprint("debugging ", client.name15text, "\n");
            return;
        }
        client = find(client, classname, "player");
    }
    dprint("client not found\n");
};

//
//  S T U F F  I M P U L S E
//
//  Stuff an impulse into the console of the debug client.
//
void () console_stuff_impulse =
{
    local float temp;
    local string s;

    if (!elohim_debug_client)
    {
		dprint("No debug client\n");
		console_byte_count = 0;
        return;
    }
	if (console_byte_count != %1)
	{
		dprint("usage:  120;stuffimpulse\n");
		console_byte_count = 0;
		return;
	}
	console_byte_count = 0;
    s = ftos(array_console_byte[0]);
    stuffcmd(elohim_debug_client, "impulse ");
    stuffcmd(elohim_debug_client, s);
    stuffcmd(elohim_debug_client, "\n");
    dprint("stuffing impulse ", s, "\n");
};

//
//  S T U F F  C O L O U R
//
//  Stuff a colour into the console of the debug client.
//
void () console_stuff_colour =
{
    local float i;
    local string s;

    if (!elohim_debug_client)
    {
        dprint("No debug client\n");
        return;
    }
	if (console_byte_count != %1 && console_byte_count != %2)
	{
		dprint("usage:  8;2;stuffcolour\n");
		console_byte_count = 0;
		return;
	}
    stuffcmd(elohim_debug_client, "color ");
    s = ftos(array_console_byte[0]);
    stuffcmd(elohim_debug_client, s);
	if (console_byte_count == %2)
	{
		s = ftos(array_console_byte[%1]);
		stuffcmd(elohim_debug_client, " ");
		stuffcmd(elohim_debug_client, s);
	}
    stuffcmd(elohim_debug_client, "\n");
    dprint("stuffing color\n");
	console_byte_count = 0;
};

//
//  D E B U G  H E L P 
//
void () console_debug_help = 
{
	dprint("\n");
	dprint("debugclient  - select client (use bytes)\n");
	dprint("debugoff     - deselect client\n");
	dprint("stuffimpulse - stuff impulse (use bytes)\n");
	dprint("stuffcolor   - stuff colour (use bytes)\n");
	dprint("debugcflags  - show client flags\n");
	dprint("debugcinfo   - show client info\n");
	dprint("debugsflags  - show server flags\n");
	dprint("\n");
};

//
//  C L I E N T  I N F O 
//
void () console_client_info = 
{
	local string temp;

    if (!elohim_debug_client)
    {
        dprint("No debug client\n");
        return;
    }
	dprint("\n");
	temp = ftos(time - elohim_debug_client.last_active);
	dprint("idle      = ", temp, "\n");
	temp = strings_function_name(&elohim_debug_client.think);
	dprint("think     = ", temp, "\n");
	temp = ftos(elohim_debug_client.nextthink);
	dprint("nextthink = ", temp, "\n");
	temp = ftos(time);
	dprint("current time = ", temp, "\n");
	dprint("\n");
};

//
//  V E R S I O N  I N F O
//
void () console_version_info =
{
    dprint("\n");
    dprint(elohim_version_info, "\n");
    dprint("\n");
};

//
//  C H E C K  L E V E L
//
//  Check to see if we've found the next level in levels.cfg
//
void (float newlevel) console_check_level =
{
	local string s;
	s = strings_get_mapname(newlevel);

	// if elohim_levelcount == -1 then this is a console command, so
	// change levels immediately.
	if (elohim_levelcount == -1)
	{
	    if (elohim_state & ELOHIM_MATCH_STARTED)
			dprint("Cannot change level while match is in progress\n");
		else
			changelevel(s);
		return;
	}

    // To choose the next level, we should set nextmap when
    // elohim_levelcount == elohim_level.  If the current level is the
    // last one in the list then this will never occur, so we should also
    // set nextmap when we see the first level in the list.
	if (elohim_levelcount == 1)
	{
		elohim_firstlevel = s;
		utils_set_cvar("scratch4", 2);
	}
    if (elohim_levelcount == elohim_level)
    {
        nextmap = s;
        utils_set_cvar("scratch4", elohim_levelcount + 1);
    }

    elohim_levelcount = elohim_levelcount + 1;
};

//
//  G E T  U S E R  N E X T L E V E L
//
//  Check for a user-defined level sequence (dedicated only).
//
void () console_get_user_nextlevel =
{
    if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
    {
        elohim_levelcount = 1;
        elohim_lastcount = 0;
		elohim_firstlevel = "";
        localcmd("exec levels.cfg\n");
		elohim_nextcheck = 0;
    }
	remove(self);
};

//
//  G E T  O R I G I N
//
//  Return the vector 'scr_ofsx scr_ofsy scr_ofsz'
//
vector () console_get_origin =
{
    local vector v;

    v_x = cvar("scr_ofsx");
    v_y = cvar("scr_ofsy");
    v_z = cvar("scr_ofsz");
    return v;
};

//
//  G E T  A N G L E S
//
//  Return the angles vector 'v_ipitch_level v_iyaw_level v_iroll_level'
//
vector () console_get_angles =
{
    local vector v;

    v_x = cvar("v_ipitch_level");
    v_y = cvar("v_iyaw_level");
    v_z = cvar("v_iroll_level");
    return v;
};

//
//  M A K E  E N T I T Y
//
//  Create a new entity using the origin and angle specified in a
//  configuration file.
//
void (string name, float angleflags) console_make_entity =
{
    local entity newent;
    local string temp;

    // create entity
    newent = spawn();
    newent.owner = world;
    newent.solid = SOLID_NOT;
    newent.movetype = MOVETYPE_NONE;
    newent.takedamage = DAMAGE_NO;
    newent.fixangle = TRUE;
    newent.classname = name;
    newent.origin = console_get_origin();
    newent.angles = console_get_angles();
	newent.style = ELOHIM_MANUAL_SPAWN;
    if (!(angleflags & CONSOLE_ENT_PITCH))
        newent.angles_x = 0;
    if (!(angleflags & CONSOLE_ENT_YAW))
        newent.angles_y = 0;
    if (!(angleflags & CONSOLE_ENT_ROLL))
        newent.angles_z = 0;

    temp = vtos(newent.origin);
    dprint(name, " created at ", temp, ", ");
    temp = vtos(newent.angles);
    dprint(temp, "\n");
    if (name == "elohim_camera")
    {
    	newent.nextthink = ELOHIM_NEGINF;
    	newent.think = auto_camera_think;
		newent.next_camera = elohim_sentinel.next_camera;
		elohim_sentinel.next_camera = newent;
    }
};

//
//  K I L L  E N T I T Y
//
//  Search for the entity of the given type at origin specified in the
//  configuration file; kill it if it exists.
//
void (string name) console_kill_entity =
{
    local vector location;
    local entity e;
    local string temp;

    location = console_get_origin();
    temp = vtos(location);

    e = find(world, classname, name);
    while (e)
    {
		if (e.style != ELOHIM_MANUAL_SPAWN)
		{
			local vector v;
			v = e.origin - location;
			if (vlen(v) < 20)
			{
				dprint("removed ", name, " at ", temp, ", ");
				temp = vtos(e.angles);
				dprint(temp, "\n");

				remove(e);
				return;            
			}
		}
        e = find(e, classname, name);
    }
    dprint("killentity: couldn't find ", name, " at ", temp, "\n");
};

//
//  K I L L  I T E M
//
//  Kill any respawnable item at the specified location.
//
void () console_kill_item = 
{
	local vector v;
	local string temp;
	local float dz;

	if (self.style == ELOHIM_MANUAL_SPAWN)
		return;

	v = self.origin - console_origin;
	dz = fabs(v_z);
	v_z = 0;
	if (vlen(v) < 20 && dz < 100)
	{
		temp = vtos(self.origin);
		dprint("removed ", self.classname, " at ", temp, "\n");		
		remove(self);
	}
};

//
//  M A K E  I T E M
//
//  Create a new item, specified by skill
//
void () console_make_item = 
{
	local float item;
	local entity oself;
    local string temp;

	item = cvar("skill");
	oself = self;

    // create entity
    self = spawn();
    self.owner = world;
    self.takedamage = DAMAGE_NO;
    self.fixangle = TRUE;
    self.origin = console_origin;
    self.angles = '0 0 0';
	self.style = ELOHIM_MANUAL_SPAWN;

	if (item < 4)
	{
		self.classname = "item_health";
		if (item == 1)
			self.spawnflags = H_ROTTEN;
		else if (item == 3)
			self.spawnflags = H_MEGA;
		item_health();
	}
	else if (item == 4)
	{
		self.classname = "item_armor1";
		item_armor1();
	}
	else if (item == 5)
	{
		self.classname = "item_armor2";
		item_armor2();
	}
	else if (item == 6)
	{
		self.classname = "item_armorInv";
		item_armorInv();
	}
	else if (item >= 7 && item <= 14)
	{
		if (!(item & 1))
			self.spawnflags = WEAPON_BIG2;
		
		if (item < 9)
		{
			self.classname = "item_shells";
			item_shells();
		}
		else if (item < 11)
		{
			self.classname = "item_spikes";
			item_spikes();
		}
		else if (item < 13)
		{
			self.classname = "item_rockets";
			item_rockets();
		}
		else
		{
			self.classname = "item_cells";
			item_cells();
		}
	}
	else if (item == 15)
	{
		self.classname = "weapon_supershotgun";
		weapon_supershotgun();
	}
	else if (item == 16)
	{
		self.classname = "weapon_nailgun";
		weapon_nailgun();
	}
	else if (item == 17)
	{
		self.classname = "weapon_supernailgun";
		weapon_supernailgun();
	}
	else if (item == 18)
	{
		self.classname = "weapon_grenadelauncher";
		weapon_grenadelauncher();
	}
	else if (item == 19)
	{
		self.classname = "weapon_rocketlauncher";
		weapon_rocketlauncher();
	}
	else if (item == 20)
	{
		self.classname = "weapon_lightning";
		weapon_lightning();
	}
	else if (item == 21)
	{
		self.classname = "item_artifact_envirosuit";
		item_artifact_envirosuit();
	}
	else if (item == 22)
	{
		self.classname = "item_artifact_super_damage";
		item_artifact_super_damage();
	}
	else if (item == 23)
	{
		self.classname = "item_artifact_invulnerability";
		item_artifact_invulnerability();
	}
	else if (item == 24)
	{
		self.classname = "item_artifact_invisibility";
		item_artifact_invisibility();
	}
	else
	{
		remove(self);
		self = oself;
		return;
	}

    temp = vtos(self.origin);
    dprint(self.classname, " created at ", temp, "\n");

	self = oself;
};

//
//  C H A N G E  I T E M
//
//  Kill any respawnable item at the specified location and make a new one
//  in its place.
//
void () console_change_item = 
{
	local vector v;
	local string temp;
	local float dz;

	if (self.style == ELOHIM_MANUAL_SPAWN)
		return;

	v = self.origin - console_origin;
	dz = fabs(v_z);
	v_z = 0;
	if (vlen(v) < 20 && dz < 100)
	{
		console_origin = self.origin;
		temp = vtos(console_origin);
		dprint("removed ", self.classname, " at ", temp, "\n");		
		remove(self);
		console_make_item();
	}
};

//
//  O N O F F
//
void (float val) console_onoff = 
{
	if (val)
		dprint("on\n");
	else
		dprint("off\n");
};

//
//  S H O W  S E T T I N G S
//
void () console_show_settings = 
{
	local float temp;
	local string sz;

	dprint("\n");

    temp = options_get_mode();
    sz = strings_get_mode(temp);
    dprint(sz, " mode\n");

	localcmd("timelimit\n");
	localcmd("fraglimit\n");
	localcmd("teamplay\n");
	localcmd("deathmatch\n");
	localcmd("pausable\n");
	localcmd("sys_ticrate\n");

	sz = ftos(elohim_set_afk);
	dprint("setafk  = ", sz, "\n");
	sz = ftos(elohim_kick_afk);
	dprint("kickafk = ", sz, "\n");

	dprint("overtime: ");
	if (elohim_overtime == -1)
		dprint("sudden death\n");
	else if (elohim_overtime == 0)
		dprint("disabled\n");
	else 
	{
		sz = ftos(elohim_overtime);
		dprint(sz);
		sz = strings_szplural(elohim_overtime);
		dprint(" minute", sz, "\n");
	}

	sz = ftos(elohim_maxteams);
	dprint("maxteams: ", sz, "\n");

	dprint("gibs: ");
	if (elohim_playmode & ELOHIM_NO_GIBS)
		dprint("off\n");
	else if (elohim_playmode & ELOHIM_LOW_GIBS)
		dprint("low\n");
	else
		dprint("high\n");

	dprint("safe practice: ");
	console_onoff(elohim_playmode & ELOHIM_NO_SPOOGE);

	dprint("quad: ");
	console_onoff(ELOHIM_NO_QUAD - (elohim_playmode & ELOHIM_NO_QUAD));
	dprint("pentagram: ");
	console_onoff(ELOHIM_NO_PENT - (elohim_playmode & ELOHIM_NO_PENT));
	dprint("ring: ");
	console_onoff(ELOHIM_NO_RING - (elohim_playmode & ELOHIM_NO_RING));

	dprint("mode voting: ");
	console_onoff(elohim_playmode & ELOHIM_MODE_VOTE);
	dprint("level voting: ");
	console_onoff(elohim_playmode & ELOHIM_LEVEL_VOTE);
	dprint("extended obituaries: ");
	console_onoff(elohim_playmode & ELOHIM_EXTENDED_OBITS);
	dprint("fast match starts: ");
	console_onoff(elohim_playmode & ELOHIM_FAST_START);
	dprint("fresh spawns: ");
	console_onoff(elohim_playmode & ELOHIM_FRESH_SPAWNS);
	dprint("autopausing: ");
	console_onoff(elohim_playmode & ELOHIM_AUTO_PAUSE);

	dprint("\n");
};

//
//  S E T  M A X  T E A M S
//
//  Set the maximum number of teams.
//
void (float maxteams) console_set_max_teams = 
{
	maxteams = floor(maxteams);
	if (maxteams >= 2 && maxteams <= 8)
		admin_set_maxteams(maxteams);
};

//
//  F R E S H  S P A W N S
//
void (float val) console_fresh_spawns = 
{
	if (val)
	{
		elohim_playmode = elohim_playmode | ELOHIM_FRESH_SPAWNS;
		dprint("Fresh spawns enabled\n");
	}
	else
	{
		elohim_playmode = elohim_playmode - (elohim_playmode & ELOHIM_FRESH_SPAWNS);
		dprint("Fresh spawns disabled\n");
	}
	utils_set_cvar("samelevel", elohim_playmode);
};

//
//  A D M I N S
//
//  List the server admins and the codes they used
//
void () console_admins = 
{
	local entity e;
	local string s;
	local float found;

	found = 0;
	e = find(world, classname, "player");
	while (e)
	{
		if (e.style & ELOHIM_CONNECTED && e.style & ELOHIM_ADMINISTRATOR)
			found = 1;
		e = find(e, classname, "player");
	}
	if (!found)
	{
		dprint("There are no administrators\n");
		return;
	}
	
	dprint("\n");
	dprint("      name       | code \n");
	dprint("-----------------+------\n");
	e = find(world, classname, "player");
	while (e)
	{
		if (e.style & ELOHIM_CONNECTED && e.style & ELOHIM_ADMINISTRATOR)
		{
			if (e.crmod_hack_count == 10)
				s = "V";
			else
				s = ftos(e.crmod_hack_count);
			dprint(" ", e.name15text, " |  ", s, "\n"); 
		}
		e = find(e, classname, "player");
	}
	dprint("\n");
};

//
//  I P S
//
//  List player ip addresses
//
void () console_ips = 
{
	local entity e;
	local float p;

	dprint("\n");
	dprint("      name       |       ip\n");
	dprint("-----------------+-----------------\n");
	e = find(world, classname, "player");
	while (e)
	{
		if (e.style & ELOHIM_CONNECTED)
		{
			p = AddInt(AddInt(&e.qs, 4 * QS_ADDRESS + %32), PQUAKEC_TO_PSTRING);
			dprint(" ", e.name15text, " | ", @p, "\n");
		}
		e = find(e, classname, "player");
	}
	dprint("\n");
};

//
//  B A N S
//
void () console_bans = 
{
	local float i;

	if (!(elohim_playmode & ELOHIM_DEDICATED_SERVER))
		return;

	zone_check_clear();

	dprint("\n");
	dprint("      name       |       ip\n");
	dprint("-----------------+-----------------\n");
	for (i = 0 ; i < zone_vars[ZONE_NUM_BANS] ; i = i + %1)
	{
		if (zone_ban_mask[i])
		{
			dprint(" ");
			dprint(net_get_ban_name_text(i), " | ");
			net_dprint_ip(zone_ban_ip[i], zone_ban_mask[i]);
			dprint("\n");
		}
	}
	dprint("\n");
};

//
//  B Y T E
//
void (float byte) console_byte = 
{
	if (console_byte_count == %4)
	{
		dprint("Invalid\n");
		console_byte_count = 0;
		return;
	}
	array_console_byte[console_byte_count] = byte;
	console_byte_count = console_byte_count + %1;
};

//
//  G E T  I P
//
float () console_get_ip = 
{
	if (console_byte_count == %4)
		elohim_ban_mask = IP_MASK0;
	else if (console_byte_count == %3)
		elohim_ban_mask = IP_MASK1;
	else if (console_byte_count == %2)
		elohim_ban_mask = IP_MASK2;
	else
	{
		console_byte_count = 0;
		return 0;
	}

	console_byte_count = 0;
	if (BIG_ENDIAN)
		return MakeInt(array_console_byte[%0], array_console_byte[%1], array_console_byte[%2], array_console_byte[%3]);
	else
		return MakeInt(array_console_byte[%3], array_console_byte[%2], array_console_byte[%1], array_console_byte[%0]);
};

//
//  B A N
//
void () console_ban = 
{
	local float ip;

	if (!(elohim_playmode & ELOHIM_DEDICATED_SERVER))
		return;

	ip = console_get_ip();

	if  (!ip)
	{
		dprint("crban: Invalid input.  To ban 24.19.3.129, type:\n");
		dprint("24;19;3;129;crban\n");
		return;
	}
	net_ban_ip(ip);
};

//
//  U N B A N 
//
void () console_unban = 
{
	local float ip;

	if (!(elohim_playmode & ELOHIM_DEDICATED_SERVER))
		return;

	ip = console_get_ip();
	if  (!ip)
	{
		dprint("unban: Invalid input.  To unban 24.19.3.129, type:\n");
		dprint("24;19;3;129;unban\n");
		return;
	}
	net_unban_ip(ip);
};

//
//  R A T I N G S
//
void () console_ratings =
{
	local entity player, e;
	local float n, r;
	local string s;

	dprint(" rank |      name     | rating | fights \n"); 
    dprint("------+---------------+--------+--------\n");
    
    RankSort();

	player = elohim_sentinel.chain;
	n = 1;
	while (player)
	{
		dprint("  ");
		if (n < 10)
			dprint(" ");
		s = ftos(n);
		dprint(s, "  |", player.name15text, "|  ");
		if (player.fights >= 10)
		{
			r = floor(player.rating);
			if (r < 100)
				dprint(" ");
			if (r < 1000)
				dprint(" ");
			s = ftos(r);
			dprint(s, "  |  ");
		}
		else
			dprint("      |  ");
		s = ftos(player.fights);
		dprint(s, "\n");

		player = player.chain;
		n = n + 1;
	}
};

//
//  T E S T C M D
//
//  Used for debugging
//
void () console_testcmd = 
{
	dprint(ftos(&colours / %1));
	dprint("\n");
};

//
//  C O M M A N D
//
//  Interpret a console command.  Called from elohim_start_frame.
//
void (float command) console_command =
{
    local string temp;
	local float arg;
	// immediate mode commands
    if (command == 1)
        console_ping();
    else if (command == 2)
        console_show_time();
    else if (command == 3)
        console_show_status();
    else if (command == 4)
        console_show_debug_info();
    else if (command == 5)
        console_show_score();
    else if (command == 6)
        console_list_ghosts();
    else if (command == 7)
        console_show_killstats();
    else if (command == 8)
        console_show_efficiency();
    else if (command == 9)
        console_show_stats();
    else if (command == 10)
        console_commands();
    else if (command == 11)
        console_version_info();
    else if (command >= 12 && command <= 15)
		votables_request_set_mode(command - 12);
	else if (command == 16)
		console_show_quadstats();
	else if (command == 17)
		console_show_settings();
	else if (command == 18)
		console_show_badstats();
	else if (command == 19)
		console_show_teamstats();

	// config file commands
	else if ((command >= 20 && command <= 49) || (command >= 80 && command <= 89) || (command >= 200 && command <= 201))
	{
		//local float arg;

		arg = cvar("skill");
		cvar_set("skill", "0");

		if (elohim_state & ELOHIM_IGNORE_CONSOLE)
			return;

		if (command == 20 && !(elohim_playmode & ELOHIM_NO_SPOOGE))
			utils_toggle_sflag(ELOHIM_NO_SPOOGE, "Safe practice mode");
		else if (command == 21 && (elohim_playmode & ELOHIM_NO_SPOOGE))
			utils_toggle_sflag(ELOHIM_NO_SPOOGE, "Safe practice mode");
		else if (command >= 22 && command <= 24)
			votables_request_set_gibs(command - 22);
		else if (command == 25 && (elohim_playmode & ELOHIM_NO_QUAD))
			votables_set_quad();
		else if (command == 26 && !(elohim_playmode & ELOHIM_NO_QUAD))
			votables_set_quad();
		else if (command == 27 && (elohim_playmode & ELOHIM_NO_PENT))
			votables_set_pent();
		else if (command == 28 && !(elohim_playmode & ELOHIM_NO_PENT))
			votables_set_pent();
		else if (command == 29 && (elohim_playmode & ELOHIM_NO_RING))
			votables_set_ring();
		else if (command == 30 && !(elohim_playmode & ELOHIM_NO_RING))
			votables_set_ring();
		else if (command == 31 && !(elohim_playmode & ELOHIM_MODE_VOTE))
			utils_toggle_sflag(ELOHIM_MODE_VOTE, "Mode voting");
		else if (command == 32 && (elohim_playmode & ELOHIM_MODE_VOTE))
			utils_toggle_sflag(ELOHIM_MODE_VOTE, "Mode voting");
		else if (command == 33 && !(elohim_playmode & ELOHIM_EXTENDED_OBITS))
			utils_toggle_sflag(ELOHIM_EXTENDED_OBITS, "Extended obituaries");
		else if (command == 34 && (elohim_playmode & ELOHIM_EXTENDED_OBITS))
			utils_toggle_sflag(ELOHIM_EXTENDED_OBITS, "Extended obituaries");
		else if (command == 36)
			votables_request_set_overtime(arg);
		else if (command == 37)
			console_set_max_teams(arg);
		else if (command == 38 && !(elohim_playmode & ELOHIM_FAST_START))
			utils_toggle_sflag(ELOHIM_FAST_START, "Fast match starts");
		else if (command == 39 && (elohim_playmode & ELOHIM_FAST_START))
			utils_toggle_sflag(ELOHIM_FAST_START, "Fast match starts");
		else if (command >= 40 && command <= 41)
			console_fresh_spawns(41 - command);
		else if (command == 42)
		{
			elohim_state = elohim_state | ELOHIM_NO_PRACTICE;
			dprint("practice mode disabled\n");
		}
		else if (command == 43 && !(elohim_playmode & ELOHIM_AUTO_PAUSE))
			utils_toggle_sflag(ELOHIM_AUTO_PAUSE, "Automatic match pausing");
		else if (command == 44 && (elohim_playmode & ELOHIM_AUTO_PAUSE))
			utils_toggle_sflag(ELOHIM_AUTO_PAUSE, "Automatic match pausing");
		else if (command == 45 && !(elohim_playmode & ELOHIM_AUTOSTATS))
			utils_toggle_sflag(ELOHIM_AUTOSTATS, "Console autostats");
		else if (command == 46 && (elohim_playmode & ELOHIM_AUTOSTATS))
			utils_toggle_sflag(ELOHIM_AUTOSTATS, "Console autostats");
		else if (command == 47)
			elohim_set_afk = arg;
		else if (command == 48)
			elohim_kick_afk = arg;
		else if (command == 49)
			elohim_playmode = elohim_playmode | ELOHIM_NO_VOTE_ADMIN;
		else if (command == 200 && !(elohim_playmode & ELOHIM_LEVEL_VOTE))
			utils_toggle_sflag(ELOHIM_LEVEL_VOTE, "Level voting");
		else if (command == 201 && (elohim_playmode & ELOHIM_LEVEL_VOTE))
			utils_toggle_sflag(ELOHIM_LEVEL_VOTE, "Level voting");
		else if (command >= 80 && command <= 89)
		{
			array_password[(command - 80) * %1] = arg;
			if (arg > elohim_pass_max)
				elohim_pass_max = arg;
			local string s;
			s = ftos(command - 80);
			dprint("password ", s, " set\n");
		}
	}
		
	// entity file commands
    else if (command == 50)
    {
        console_make_entity("info_player_deathmatch", CONSOLE_ENT_YAW);
        elohim_num_spawns = elohim_num_spawns + 1;
    }
    else if (command == 51)
    {
        console_make_entity("elohim_start_point", CONSOLE_ENT_YAW);
        elohim_num_starts = elohim_num_starts + 1;
    }
    else if (command == 52)
        console_kill_entity("info_player_deathmatch");
    else if (command == 53)
    {
        console_make_entity("elohim_camera", CONSOLE_ENT_PITCH | CONSOLE_ENT_YAW);
        elohim_num_cameras = elohim_num_cameras + 1;
    }
	else if (command >= 54 && command <= 56)
	{
		console_origin = console_get_origin();
		if (command == 54)
			utils_do_items(console_kill_item);
		else if (command == 55)
			console_make_item();
		else
			utils_do_items(console_change_item);
	}

	// control commands
	else if (command >= 60 && command <= 66)
	{
		if (elohim_state & ELOHIM_IGNORE_CONSOLE)
		{
			utils_set_cvar("deathmatch", console_deathmatch);
			utils_set_cvar("timelimit", console_timelimit);
			utils_set_cvar("fraglimit", console_fraglimit);
			utils_set_cvar("pausable", console_pausable);
			utils_set_cvar("noexit", console_noexit);
		}
		else
		{
			console_deathmatch = cvar("deathmatch");
			console_timelimit = cvar("timelimit");
			console_fraglimit = cvar("fraglimit");
			console_pausable = cvar("pausable");
			console_noexit = cvar("noexit");
		}

		if (command == 60)
		{
			if (elohim_playmode & ELOHIM_CONSOLE_INITIALIZED)
				elohim_state = elohim_state | ELOHIM_IGNORE_CONSOLE;
			else
			{
				elohim_playmode = elohim_playmode | ELOHIM_CONSOLE_INITIALIZED;
				utils_set_cvar("samelevel", elohim_playmode);
				elohim_state = elohim_state - (elohim_state & ELOHIM_IGNORE_CONSOLE);
			}
		}
		else if (command >= 61 && command <= 64)
		{
			if (command - 61 != options_get_mode())
				elohim_state = elohim_state | ELOHIM_IGNORE_CONSOLE;
			else
				elohim_state = elohim_state - (elohim_state & ELOHIM_IGNORE_CONSOLE);
		}
		else if (command == 65)
			elohim_state = elohim_state - (elohim_state & ELOHIM_IGNORE_CONSOLE);
		else if (command == 66)
		{
			elohim_state = elohim_state - (elohim_state & ELOHIM_IGNORE_CONSOLE);
			admin_dmset(console_deathmatch);
			votables_request_set_timelimit(console_timelimit);
			elohim_set_fraglimit(console_fraglimit);
			utils_set_cvar("pausable", console_pausable);
			utils_set_cvar("noexit", console_noexit);
		}
	}

	// undocumented debug commands
    else if (command == 70)
        console_debug_client();
    else if (command == 71)
    {
        dprint("debugging off\n");
        elohim_debug_client = world;
    }
    else if (command == 72)
        console_stuff_impulse();
    else if (command == 73)
        console_stuff_colour();
    else if (command == 74)
		debug_client_flags(elohim_debug_client, debug_dprint);
    else if (command == 75)
        debug_server_flags(debug_dprint);
	else if (command == 76)
		console_client_info();
	else if (command == 77)
		console_debug_help();
	else if (command == 90)
		console_admins();
	else if (command == 91)
		console_ips();
	else if (command == 92)
		console_bans();
	else if (command == 93)
		console_ban();
	else if (command == 94)
		console_unban();
	else if (command == 95)
		console_ratings();
	else if (command == 99)
		console_testcmd();

	// map aliases
    else if (command >= 100 && command < 170)
        console_check_level(command - 100);

	// byte aliases
	else if (command >= 1000 && command < 1256)
		console_byte(command - 1000);
    else
	//Sputnik: stat_ids 	
	if (command == 2000)
	{
		local float pc;
		local string s;

		arg = cvar("skill");		// ID#
		cvar_set("skill", "0");

		pc = cvar("registered");	// PASSCODE
		cvar_set("registered", "0");

		s = ftos(arg);
		dprint("Setting Player ID: ",s,"\n");

		zone_player_stat_id[arg * %1] = pc; 
	}
	else
        dprint("unknown command\n");
};

