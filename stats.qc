//
// Stats.qc
//
// Various routines for displaying statistics.
//
// All code by J.P. Grossman unless otherwise commented.
//

//
//  P R O T O T Y P E S
//
void (float frac, float tot) stats_print_percent3;


//
//  R E S E T  P L A Y E R
//
void () stats_reset_player =
{
    self.dest1 = self.dest2 = self.dest = self.mangle = '0 0 0';
	self.crmod_qdwep = self.crmod_qdkill = self.crmod_badstats = '0 0 0';
    self.crmod_did_damage = 0; // CRMOD moved here from put_client_in_server
	self.dmg_taken	= 0;
	self.dmg_given	= 0;
};

//
//  R E S E T  T E A M
//
void (entity pteam) stats_reset_team = 
{
	pteam.dest = pteam.dest1 = pteam.dest2 = pteam.pos1 = pteam.mangle = '0 0 0';
};

//
//  S H O W  B A D S T A T S
//
void () stats_show_badstats =
{
    local entity player;
	local float tot_enemy, tot_done;

	if (!(elohim_playmode & ELOHIM_MATCH_MODE) || !teamplay)
	{
		sprint(self, "badstats valid in match mode only\n");
		return;
	}

    sprint(self, "paks - number of RL paks given away\n");
    sprint(self, "self - percent damage done to self\n");
    sprint(self, "team - percent damage done to team\n");
    sprint(self, "\n");
    sprint(self, "      name     ü paks ü self ü team \n");
    sprint(self, "­­­­­­­­­­­­­­­«­­­­­­«­­­­­­«­­­­­­\n");

    player = elohim_sentinel.owner.next_player;
    while (player)
    {
        tot_enemy = player.dest2_x + player.dest2_y + player.dest2_z + player.dest_y;
		tot_done = tot_enemy + player.crmod_badstats_y + player.crmod_badstats_z;
        sprint(self, player.name15, "ü");
        if (player == self)
        {
            sprint(self, " ");
            utils_print_int3(player.crmod_badstats_x);
            sprint(self, "‘ü ");
			stats_print_percent3(player.crmod_badstats_y, tot_done);
            sprint(self, "‘ü ");
			stats_print_percent3(player.crmod_badstats_z, tot_done);
            sprint(self, "‘");
        }
        else
        {
            sprint(self, "  ");
            utils_print_int3(player.crmod_badstats_x);
            sprint(self, " ü  ");
			stats_print_percent3(player.crmod_badstats_y, tot_done);
            sprint(self, " ü  ");
			stats_print_percent3(player.crmod_badstats_z, tot_done);
        }
		sprint(self, "\n");
        player = player.next_player;
    }
};

//
//  S H O W  Q U A D S T A T S
//
void () stats_show_quadstats =
{
    local entity player, pteam;
	local float useteams;
	local string teamname;

	if (teamplay && ((elohim_state & ELOHIM_MATCH_STARTED) || (elohim_sentinel.owner != elohim_sentinel)))
		useteams = TRUE;
	else
		useteams = FALSE;

    sprint(self, "quads - quads picked up\n");
    sprint(self, "eff   - quad weapon efficiency\n");
    sprint(self, "opp   - number of opponents killed\n");
    sprint(self, "slf   - number of times killed self\n");
    sprint(self, "tm    - number of teammates killed\n");
    sprint(self, "\n");
    sprint(self, "     name      üquadsüeffüoppüslfütm \n");
    sprint(self, "­­­­­­­­­­­­­­­«­­­­­«­­­«­­­«­­­«­­­\n");

    player = elohim_sentinel.owner.next_player;
	pteam = player.next_team;
	
    while (player)
    {
        sprint(self, player.name15, "ü");
        if (player == self)
        {
            sprint(self, "");
            utils_print_int3(player.crmod_qdwep_z);
            sprint(self, "‘ü");
        }
        else
        {
            sprint(self, " ");
            utils_print_int3(player.crmod_qdwep_z);
            sprint(self, " ü");
        }
        stats_print_percent3(player.crmod_qdwep_x, player.crmod_qdwep_y);
        sprint(self, "ü");
        utils_print_int3(player.crmod_qdkill_x);
        sprint(self, "ü");
        utils_print_int3(player.crmod_qdkill_z);
        sprint(self, "ü");
        utils_print_int3(player.crmod_qdkill_y);
        sprint(self, "\n");
        player = player.next_player;

		if (useteams && (player.next_team != pteam))
		{
			sprint(self, pteam.mdl, "ü ");
			utils_print_int3_gold(pteam.dest2_x);
			sprint(self, " ü   ü   ü   ü\n");
			pteam = player.next_team;
		}
    }
};

//
//  S H O W  K I L L S T A T S
//
void () stats_show_killstats =
{
    local entity player;

    sprint(self, "opp - number of opponents killed\n");
    sprint(self, "slf - number of times killed self\n");
    sprint(self, "tm  - number of teammates killed\n");
    sprint(self, "kld - number of times killed by enemy\n");
    sprint(self, "\n");
    sprint(self, "     name      üfragsüoppüslfütm ükld\n");
    sprint(self, "­­­­­­­­­­­­­­­«­­­­­«­­­«­­­«­­­«­­­\n");

    player = elohim_sentinel.owner.next_player;
    while (player)
    {
        sprint(self, player.name15, "ü");
        if (player == self)
        {
            sprint(self, "");
            utils_print_int3(player.frags);
            sprint(self, "‘ü");
        }
        else
        {
            sprint(self, " ");
            utils_print_int3(player.frags);
            sprint(self, " ü");
        }
        utils_print_int3(player.frags + player.mangle_x + player.mangle_y);
        sprint(self, "ü");
        utils_print_int3(player.mangle_x);
        sprint(self, "ü");
        utils_print_int3(player.mangle_y);
        sprint(self, "ü");
        utils_print_int3(player.mangle_z);
		sprint(self, "\n");
        player = player.next_player;
    }
};

//
//  P R I N T  P E R C E N T 3
//
//  Helper function for stats_show_efficiency.  Prints the percentage
//  100 * (frac / tot) as a 3 character integer, or N/A if tot = 0.
//
void (float frac, float tot) stats_print_percent3 =
{
    if (tot)
    {
        local float n;
        local string temp;

        n = floor(100 * frac / tot);
        if (n < 10)
            sprint(self, " ");
        temp = ftos(n);
        sprint(self, temp);
        if (n < 100)
            sprint(self, "%");
    }
    else
        sprint(self, "N/A");
};

//
//  S H O W  E F F I C I E N C Y
//
//  Show the weapon efficiency for each player.
//
void () stats_show_efficiency =
{
    local entity player;
    local float tot_fired, tot_done;

    sprint(self, "bul - bullet efficiency\n");
    sprint(self, "nls - nail efficiency\n");
    sprint(self, "rox - rocket efficiency\n");
    sprint(self, "lg  - lightning gun efficiency\n");
    sprint(self, "\n");
    sprint(self, "     name      übulünlsüroxülg ütotal\n");
    sprint(self, "­­­­­­­­­­­­­­­«­­­«­­­«­­­«­­­«­­­­­\n");

    player = elohim_sentinel.owner.next_player;
    while (player)
    {
        sprint(self, player.name15, "ü");
        stats_print_percent3(player.dest2_x, player.dest1_x);
        sprint(self, "ü");
        stats_print_percent3(player.dest2_y, player.dest1_y);
        sprint(self, "ü");
        stats_print_percent3(player.dest_y, player.dest_x);
        sprint(self, "ü");
        stats_print_percent3(player.dest2_z, player.dest1_z);
        sprint(self, "ü");

        tot_fired = player.dest1_x + player.dest1_y + player.dest1_z + player.dest_x;
        tot_done = player.dest2_x + player.dest2_y + player.dest2_z + player.dest_y;
        if (player == self)
        {
            sprint(self, "");
            stats_print_percent3(tot_done, tot_fired);
            sprint(self, "‘");
        }
        else
        {
            sprint(self, " ");
            stats_print_percent3(tot_done, tot_fired);
        }
		sprint(self, "\n");
        player = player.next_player;
    }
};

//
//  S H O W  S U M M A R Y
//
//  Show kill and weapon efficiency for each player.
//
void () stats_show_summary =
{
    local entity player;
    local float wfrac, wtot, kfrac, ktot, useteams;
	local string teamname;

	if ((elohim_playmode & ELOHIM_MATCH_MODE) && teamplay)
		useteams = TRUE;
	else
		useteams = FALSE;

    sprint(self, "kill  - kill efficiency\n");
    sprint(self, "weapn - weapon efficiency\n");
    sprint(self, "\n");
    if (useteams)
    {
        sprint(self, "     name      ü   team  ükill üweapn\n");
        sprint(self, "­­­­­­­­­­­­­­­«­­­­­­­­­«­­­­­«­­­­­\n");
    }
    else
    {
        sprint(self, "     name      ükill üweapn\n");
        sprint(self, "­­­­­­­­­­­­­­­«­­­­­«­­­­­\n");
    }
	player = elohim_sentinel.owner.next_player;

    while (player)
    {
        sprint(self, player.name15, "ü");
        if (useteams)
		{
			teamname = strings_get_teamname3(player.height);
            sprint(self, teamname, " ü");
		}

        kfrac = player.frags + player.mangle_x + player.mangle_y;
        ktot = kfrac + player.mangle_x + player.mangle_y + player.mangle_z;
        wtot = player.dest1_x + player.dest1_y + player.dest1_z + player.dest_x;
        wfrac = player.dest2_x + player.dest2_y + player.dest2_z + player.dest_y;
        if (player == self)
        {
            sprint(self, "");
            stats_print_percent3(kfrac, ktot);
            sprint(self, "‘ü");
            stats_print_percent3(wfrac, wtot);
            sprint(self, "‘");
        }
        else
        {
            sprint(self, " ");
            stats_print_percent3(kfrac, ktot);
            sprint(self, " ü ");
            stats_print_percent3(wfrac, wtot);
        }
        sprint(self, "\n");
		player = player.next_player;
    }
};

//
//  F O R M A T  V E C T O R
//
//  prints xx:yy:zz to self
//
void (vector v) stats_format_vector = 
{
	local string s;

	sprint(self, "ü");
	if (v_x < 10)
		sprint(self, " ");
	s = ftos(v_x);
	sprint(self, s, "");
	if (v_y < 10)
		sprint(self, " ");
	s = ftos(v_y);
	sprint(self, s, "");
	if (v_z < 10)
		sprint(self, " ");
	s = ftos(v_z);
	sprint(self, s);
};

//
//  S H O W  T E A M  S T A T S
//
void () stats_show_teamstats = 
{
	local entity pteam;
	local string s;

	if (!(teamplay && (elohim_playmode & ELOHIM_MATCH_MODE)))
	{
		sprint(self, "Teamstats valid in match mode only\n");
		return;
	}

	if (!elohim_sentinel.owner.next_team)
	{
		sprint(self, "No teams\n");
		return;
	}

	if ((elohim_state & ELOHIM_MATCH_STARTED) && !(self.style & ELOHIM_OBSERVER))
	{
		sprint(self, "Teamstats available to observers only\n");
		return;
	}

	sprint(self, "TEAM STATS");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		s = strings_get_teamname3(pteam.height);
		sprint(self, "ü", s);
		pteam = pteam.next_team;
	}
	sprint(self, "\n­­­­­­­­­­");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		sprint(self, "«­­­­­­­­");
		pteam = pteam.next_team;
	}
	sprint(self, "\nQ\b\.\6\6\6\.RING");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		stats_format_vector(pteam.dest2);		
		pteam = pteam.next_team;
	}
	sprint(self, "\n\bRL\.LG\.GL  ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		stats_format_vector(pteam.dest1);		
		pteam = pteam.next_team;
	}
	sprint(self, "\n\bSNG\.NG\.MH ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		stats_format_vector(pteam.pos1);
		pteam = pteam.next_team;
	}
	sprint(self, "\n\bRA\.YA\.GA  ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		stats_format_vector(pteam.dest);		
		pteam = pteam.next_team;
	}
	sprint(self, "\n\brlpak +/- ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		sprint(self, "ü");
		s = ftos(pteam.mangle_y);
		if (pteam.mangle_y < 10)
			sprint(self, " ");
		sprint(self, "«", s, " ");
		s = ftos(pteam.mangle_z);
		if (pteam.mangle_z < 10)
			sprint(self, " ");
		sprint(self, "­", s, " ");
		pteam = pteam.next_team;
	}
	sprint(self, "\n\bcontrol   ");
	pteam = elohim_sentinel.owner.next_team;
	while (pteam)
	{
		local float f;
		local float control;
		control = 100 * pteam.mangle_x / elohim_sentinel.cnt;
		f = floor(control);
		s = ftos(f);
		sprint(self, "ü  %", s);
		f = floor((control - f) * 10);
		s = ftos(f);
		sprint(self, ".", s, " ");
		if (control < 10)
			sprint(self, " ");
		pteam = pteam.next_team;
	}
	sprint(self, "\n");
};

//
//  A U T O D U M P
//
//  Dump statistics if player has autostats enabled.
//
void () stats_autodump = 
{
	if (self.style & ELOHIM_AUTOSTATS)
	{
		sprint(self, "\n");
		sprint(self, "\b\<crmod match statistics\>\n");
		sprint(self, "\n");
		stats_show_summary();
		sprint(self, "\n");
		stats_show_quadstats();
		sprint(self, "\n");
		if ((elohim_playmode & ELOHIM_MATCH_MODE) && teamplay)
		{
			stats_show_badstats();
			sprint(self, "\n");
		}
		stats_show_efficiency();
		sprint(self, "\n");
		stats_show_killstats();
		sprint(self, "\n");
		stats_show_teamstats();
	}
};

//
//  H E L P
//
void () stats_help = 
{
	sprint(self, "Statistics commands:\n");
    sprint(self, " stats      - summarize statistics\n");
    sprint(self, " killstats  - list player kill stats\n");
    sprint(self, " efficiency - list player efficiency\n");
	sprint(self, " quadstats  - list player quad stats\n");
	sprint(self, " badstats   - team game blunders\n");
	sprint(self, " teamstats  - various team statistics\n");
	sprint(self, " autostats  - automatically dump stats\n");
	sprint(self, "              at the end of matches\n");
};	

//
//  I M P U L S E
//
void () stats_impulse = 
{
    if (self.impulse == 170) 
		stats_show_killstats();
    else if (self.impulse == 171)
		stats_show_efficiency();
    else if (self.impulse == 172)
		stats_show_summary();
    else if (self.impulse == 173)
		stats_show_quadstats();
    else if (self.impulse == 174)
		stats_show_badstats();
	else if (self.impulse == 175)
		stats_show_teamstats();
	else if (self.impulse == 178)
		utils_toggle_flag(ELOHIM_AUTOSTATS, "Autostats");
	else if (self.impulse == 179)
		stats_help();
};

//
//  C O P Y  S T A T I S T I C S
//
//  Copy all statistics at the end of a match so that they don't go away.
//
void () stats_copy_statistics = 
{
	local entity s, p;

	s = spawn();
	s.classname = "stats_copy";
	s.next_team = elohim_sentinel.next_team;
	elohim_sentinel.owner = s;
	for (p = elohim_sentinel.next_player ; p ; p = p.next_player)
	{
		s.next_player = p.owner;
		if (!teamplay)
			s.next_team = p.owner;
		s = p.owner;
		if (teamplay)
			s.next_team = p.next_team;
		p.owner = world;

		s.height = p.height;
		s.frags = p.frags;
		s.dest1 = p.dest1;
		s.dest2 = p.dest2;
		s.dest = p.dest;
		s.mangle = p.mangle;
		s.crmod_qdwep = p.crmod_qdwep;
		s.crmod_qdkill = p.crmod_qdkill;
		s.crmod_badstats = p.crmod_badstats;
		s.name15 = @AddInt(AddInt(&s, %40), PQUAKEC_TO_PSTRING);
		strcpy(s.name15, p.name15);
		s.name15text = @AddInt(AddInt(&s, %60), PQUAKEC_TO_PSTRING);
		strcpy(s.name15text, p.name15text);
		s.classname = "stats_copy";
	}
	s.next_player = world;
	if (teamplay)
	{
		for (p = elohim_sentinel.next_team ; p ; p = p.next_team)
		{
			p.next_player = p.next_player.owner;
			p.classname = "stats_copy";
		}
	}
	elohim_sentinel.next_player = world;
	elohim_sentinel.next_team = world;
};

//
//  D E L E T E  C O P I E S
//
void () stats_delete_copies = 
{
	utils_do_item(SUB_Remove, "stats_copy");
	elohim_sentinel.owner = elohim_sentinel;
};

