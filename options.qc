//
// Options.qc
//
// This is purely bells and whistles, and wouldn't even be here if I
// wan't bored one night when I was waiting for my girlfriend to call.
//
// All code by J.P. Grossman unless otherwise commented.
//
// fields used:
//
// .delay    - time to update display (shared with observer.qc)
//
// .pos1_x    - timelimit
// .pos1_y    - fraglimit/overtime
// .pos1_z    - mode
// .pos2_x    - gibs
// .pos2_y    - teamplay
// .pos2_z    - noexit
// .worldtype - sys_ticrate
// .light_lev - deathmatch
// .aflag     - pausable/quad/pent/ring/mode vote
// .t_length  - which option is currently selected
//

// constants
float OPTIONS_NO_GIBS = 0;
float OPTIONS_LOW_GIBS = 1;
float OPTIONS_HIGH_GIBS = 2;
float OPTIONS_PAUSABLE = 1;

//
//  S Z M O D E
//
//  Return the heading and mode string, e.g.
//
//  "Press jump to select,\nattack to change.\n\nMode      > Normal  \n"
//
string (float mode) options_szmode =
{
	local string s;
	local float p, p2;

	s = "\bPress jump to select,\nattack to change.\n\n  Mode      > XXXXXXXXXX\n";
	if (mode == ADMIN_NORMAL_MODE)
		p2 = &"\b  Normal    ";
	else if (mode == ADMIN_PRACTICE_MODE)
		p2 = &"\b  Practice  ";
	else if (mode == ADMIN_MATCH_MODE)
		p2 = &"\b  Match     ";
	else
		p2 = &"\b  Individual";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	p = AddInt(AddInt(&s, PSTRING_TO_PQUAKEC), %53);
	(*p)^[0] = (*p2)^[0];

	if (self.t_length == 0)
	{
		p2 = AddInt(&"   ", PSTRING_TO_PQUAKEC);
		p = AddInt(p, %-2);
		(*p)[0] = (*p2)[0];
	}
	return s;
};

//
//  S Z V A L U E
//
string (float value, string base, float on, string son, string soff) options_szvalue = 
{
	local float p, p2;

	p = AddInt(&base, PSTRING_TO_PQUAKEC);
	(*p)[%3] = AddInt(array_ftos4[value * %1], 0x80808080);
	if (self.t_length == on)
		p2 = &son;
	else
		p2 = &soff;
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%2] = (*p2)[0];
	return base;
};

//
//  S Z T I M E L I M I T
//
//  Return the timelimit string, e.g. "Timelimit > 15      \n"
//
string (float value) options_sztimelimit =
{
	return options_szvalue(#, "\bTimelimit > XX      \n", 1, "\bt  ", "\bt   ");
};

//
//  S Z F R A G L I M I T
//
//  Return the fraglimit string, e.g. "Fraglimit > 30      \n"
//
string (float value) options_szfraglimit =
{
	return options_szvalue(#, "\bFraglimit > XX      \n", 2, "\bt  ", "\bt   ");
};

//
//  S Z O V E R T I M E
//
//  Return the overtime string, e.g. "Overtime  > 5       \n"
//
string (float value) options_szovertime =
{
	local string s;
	local float p, p2;

	if (value == -1)
	{
		if (self.t_length == 2)
			return "\b    Overtime   Sudden Death\n";
		else
			return "\b    Overtime    Sudden Death\n";
	}

	s = "\bOvertime  > XX      \n";
	p = AddInt(&s, PSTRING_TO_PQUAKEC);

	if (!value)
	{
		p2 = AddInt(&"\bDisabled", PSTRING_TO_PQUAKEC);
		(*p)[%3] = (*p2)[%0];
		(*p)[%4] = (*p2)[%1];
	}
	else
	{
		p2 = AddInt(&"    ", PSTRING_TO_PQUAKEC);
		(*p)[%3] = AddInt(array_ftos4[value * %1], 0x80808080);
		(*p)[%4] = (*p2)[0];
	}

	if (self.t_length == 2)
		p2 = &"   ";
	else
		p2 = &"    ";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%2] = (*p2)[0];
	return s;
};

//
//  S Z G I B S
//
//  Return the gibs string, e.g. "Gibs      > Disabled\n"
//
string (float gibs) options_szgibs =
{
	local string s;
	local float p, p2;

	s = "\bGibs      > XXXXXXXX\n";
	p = AddInt(&s, PSTRING_TO_PQUAKEC);
	p2 = AddInt(&"\bDisabledLow     High    "[gibs * %8], PSTRING_TO_PQUAKEC);


	(*p)[%3] = (*p2)[%0];
	(*p)[%4] = (*p2)[%1];

	if (self.t_length == 3)
		p2 = &"   ";
	else
		p2 = &"    ";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%2] = (*p2)[0];
	return s;
};

//
//  S Z T E A M P L A Y
//
//  Return the teamplay string, e.g. "Teamplay  > 2       \n"
//
string (float value) options_szteamplay =
{
    if (self.pos1_z == ADMIN_INDIVIDUAL_MODE)
        return "\bTeamplay    \0       \n";

	return options_szvalue(#, "\bTeamplay  > X       \n", 4, "   ", "    ");
};

//
//  S Z N O E X I T
//
//  Return the noexit string, e.g. "Noexit    > 1       \n"
//
string (float value) options_sznoexit =
{
	return options_szvalue(#, "\bNoexit    > X       \n", 5, "   ", "    ");
};

//
//  S Z P A U S A B L E
//
//  Return the pausable/done string, e.g.
//
//  "Pausable    1       \nMore..              \n      > Done\n"
//
string (float value) options_szpausable =
{
	local string s;
	local float p, pm, pd, p2;

	s = "\bPausable  > XXX     \nMore..    >         \n      > Done";
	p = AddInt(&s, PSTRING_TO_PQUAKEC);
	pm = AddInt(p, %21);
	pd = AddInt(pm, %21);
	p2 = AddInt(&"    ", PSTRING_TO_PQUAKEC);
	(*p)[%2] = (*p2)[0];
	(*pm)[%2] = (*p2)[0];
	(*pd)[%1] = (*p2)[0];

	if (value)
		p2 = &"\bYes ";
	else
		p2 = &"\bNo  ";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%3] = (*p2)[0];

	p2 = AddInt(&"   ", PSTRING_TO_PQUAKEC);
	if (self.t_length == 6)
		(*p)[%2] = (*p2)[0];
	else if (self.t_length == 7)
		(*pm)[%2] = (*p2)[0];
	else if (self.t_length == 8)
		(*pd)[%1] = (*p2)[0];

	return s;
};

//
//  S Z D E A T H M A T C H
//
//  Return the deathmatch string, e.g.  "deathmatch> 3       \n"
//
string (float value) options_szdeathmatch =
{
	local string s;

	s = "\bDeathmatch > X       \n";
	options_szvalue(#, s[%1], 18, "\bh  ", "\bh   ");
	return s;
};

//
//  S Z T I C R A T E
//
//  Return the sys_ticrate string, e.g. "ticrate   > 0.07    \n"
//
string (float value) options_szticrate =
{
	local float p, p2;
	local string s;

	local entity vals;

	vals = *AddInt(&"\b0.050.060.070.080.090.1 ", PSTRING_TO_PQUAKEC);

	s = "\bTicrate    > XXXX    \n";
	p = AddInt(&s[%1], PSTRING_TO_PQUAKEC);
	(*p)[%3] = vals[(value - 0.05) * %100];

	if (self.t_length == 19)
		p2 = &"   ";
	else
		p2 = &"    ";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%2] = (*p2)[0];
	return s;
};

//
//  S Z E N A B L E D
//
string (float value, string base, float on) options_szenabled =
{
	local float p, p2;

	p = AddInt(&base[%1], PSTRING_TO_PQUAKEC);
	if (!value)
		p2 = &"\bEnabled ";
	else
		p2 = &"\bDisabled";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%3] = (*p2)[%0];
	(*p)[%4] = (*p2)[%1];

	if (self.t_length == on)
		p2 = &"   ";
	else
		p2 = &"    ";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[%2] = (*p2)[0];
	return base;
};

//
//  S Z Q U A D
//
//  Return the quad string, e.g. "Quad      > Enabled \n"
//
string (float value) options_szquad =
{
	return options_szenabled(#, "\bQuad       > XXXXXXXX\n", 20);
};


//
//  S Z P E N T
//
//  Return the pent string, e.g. "Pentagram > Enabled \n"
//
string (float value) options_szpent =
{
	return options_szenabled(#, "\bPentagram  > XXXXXXXX\n", 21);
};

//
//  S Z R I N G
//
//  Return the ring string, e.g. "Ring      > Enabled \n"
//
string (float value) options_szring =
{
	return options_szenabled(#, "\bRing       > XXXXXXXX\n", 22);
};

//
//  S Z M O D E  V O T E
//
//  Return the mode vote string, e.g.
//
//  "Mode Vote > Enabled \n        Back\n"
//
string (float value) options_szmode_vote =
{
	local string s;
	local float p, p2;

	s = "\bMode Vote  > XXXXXXXX\n       > Back";
	options_szenabled(!value, s, 23);

	p = AddInt(&s[%27], PSTRING_TO_PQUAKEC);
	if (self.t_length == 24)
		p2 = &"   ";
	else
		p2 = &"    ";
	p2 = AddInt(p2, PSTRING_TO_PQUAKEC);
	(*p)[0] = (*p2)[0];

	return s;
};

//
//  D I S P L A Y
//
//  Refresh the display according to the current set of options and the
//  current cursor position.
//
void () options_display =
{
    self.delay = time + 0.5;

    if ((elohim_state & ELOHIM_MATCH_PAUSED) || (self.style & ELOHIM_MOTD))
        return;

    if ((self.t_length & 127) < 10)
    {
        local string szmode, sztimelimit, szfraglimit, szovertime, szgibs;
        local string szteamplay, sznoexit, szpausable;
    
        szmode = options_szmode(self.pos1_z);
        sztimelimit = options_sztimelimit(self.pos1_x);
        szgibs = options_szgibs(self.pos2_x);
        szteamplay = options_szteamplay(self.pos2_y);
        sznoexit = options_sznoexit(self.pos2_z);
        szpausable = options_szpausable(self.aflag & OPTIONS_PAUSABLE);
    
        if (self.pos1_z >= ADMIN_MATCH_MODE)
        {
            szovertime = options_szovertime(self.pos1_y);
            centerprint(self, szmode, sztimelimit, szovertime, szgibs,
                         szteamplay, szpausable);
        }
        else
        {
            szfraglimit = options_szfraglimit(self.pos1_y);
            centerprint(self, szmode, sztimelimit, szfraglimit,
                         szgibs, szteamplay, sznoexit, szpausable);
        }
    }
    else
    {
        local string szticrate, szdeathmatch, szquad, szpent, szring, szmodevote;

        szticrate = options_szticrate(self.worldtype);
        szdeathmatch = options_szdeathmatch(self.light_lev);
        szquad = options_szquad(self.aflag & ELOHIM_NO_QUAD);
        szpent = options_szpent(self.aflag & ELOHIM_NO_PENT);
        szring = options_szring(self.aflag & ELOHIM_NO_RING);
        szmodevote = options_szmode_vote(self.aflag & ELOHIM_MODE_VOTE);
        centerprint(self, "Πςεσσ κυνπ το σεμεγτ¬\nατταγλ το γθαξηε®\n\n",
                     szdeathmatch, szticrate, szquad, szpent, szring, szmodevote);
    }

    // Hack to create flashing cursor
    self.t_length = (self.t_length + 128) & 255;
};

//
//  G E T  M O D E
//
//  Returns the current mode.
//
float () options_get_mode =
{
    if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        return ADMIN_PRACTICE_MODE;
    if (elohim_playmode & ELOHIM_MATCH_MODE)
	{
		if (teamplay)
			return ADMIN_MATCH_MODE;
		return ADMIN_INDIVIDUAL_MODE;
	}
    return ADMIN_NORMAL_MODE;
};

//
//  G E T  G I B S
//
//  Returns the current gib mode.
//
float () options_get_gibs =
{
    if (elohim_playmode & ELOHIM_NO_GIBS)
        return OPTIONS_NO_GIBS;
    if (elohim_playmode & ELOHIM_LOW_GIBS)
        return OPTIONS_LOW_GIBS;
    return OPTIONS_HIGH_GIBS;
};

//
//  S T A R T  S E T T I N G
//
//  Called from Admin.qc when the options command is entered.
//
void () options_start_setting =
{
    if (self.style & ELOHIM_SETTING_OPTIONS)
    {
        // cancel
        stuffcmd(self, "play misc/menu2.wav\n");
        self.style = self.style - ELOHIM_SETTING_OPTIONS;
        centerprint(self, " ");
        return;
    }

    // Initialize stuff
    self.t_length = 0;
    self.style = self.style | ELOHIM_SETTING_OPTIONS;

    // get values
    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        self.pos1_x = elohim_timelimit;
        self.pos1_y = elohim_overtime;
    }
    else
    {
        self.pos1_x = cvar("timelimit");
        self.pos1_y = cvar("fraglimit");
    }

    self.pos1_z = options_get_mode();
    self.pos2_x = options_get_gibs();

    self.pos2_y = teamplay;
    if (!(teamplay == 0 || teamplay == 1 || teamplay == 2))
        self.pos2_y = 0;

    self.pos2_z = cvar("noexit");
    if (!(self.pos2_z == 0 || self.pos2_z == 1 || self.pos2_z == 2))
        self.pos2_z = 0;

    if (cvar("pausable"))
        self.aflag = OPTIONS_PAUSABLE;
    else
        self.aflag = 0;
    self.aflag = self.aflag | (elohim_playmode &
        (ELOHIM_NO_QUAD | ELOHIM_NO_PENT | ELOHIM_NO_RING | ELOHIM_MODE_VOTE));

    self.light_lev = cvar("deathmatch");
    if (!(self.light_lev == 1 || self.light_lev == 2 || self.light_lev == 3))
        self.light_lev = 1;

    self.worldtype = cvar("sys_ticrate");

    // show choice
    options_display();

    // play sound
    stuffcmd(self, "play misc/menu2.wav\n");
};

//
//  C H A N G E
//
//  Called when attack is pressed for one of the options.
//
void () options_change =
{
    local float temp;

    if (self.t_length == 0)
    {
        // change mode
        if (self.pos1_z == ADMIN_NORMAL_MODE)
        {
            self.pos1_z = ADMIN_PRACTICE_MODE;
            if (elohim_playmode & ELOHIM_PRACTICE_MODE)
                self.pos1_x = cvar("timelimit");
            else
                self.pos1_x = 0;
        }
        else if (self.pos1_z == ADMIN_PRACTICE_MODE)
        {
            self.pos1_z = ADMIN_MATCH_MODE;
            self.pos1_x = elohim_timelimit;
            self.pos1_y = elohim_overtime;
			self.pos2_y = 2; // teamplay
        }
		else if (self.pos1_z == ADMIN_MATCH_MODE)
		{
			self.pos1_z = ADMIN_INDIVIDUAL_MODE;
			self.pos2_y = 0; // teamplay
		}
        else
        {
            self.pos1_z = ADMIN_NORMAL_MODE;
            if (!(elohim_playmode & (ELOHIM_PRACTICE_MODE | ELOHIM_MATCH_MODE)))
                self.pos1_x = cvar("timelimit");
            else
                self.pos1_x = 30;
            self.pos1_y = cvar("fraglimit");
        }
    }
    else if (self.t_length == 1)
    {
        // change timelimit
        if (self.pos1_z >= ADMIN_MATCH_MODE)
        {
            self.pos1_x = 5 * ceil(self.pos1_x / 5) + 5;
            if (self.pos1_x > 30)
                self.pos1_x = 5;
        }
        else
        {
            self.pos1_x = 10 * ceil(self.pos1_x / 10) + 10;
            if (self.pos1_x > 60)
                self.pos1_x = 0;
        }
    }
    else if (self.t_length == 2)
    {
        if (self.pos1_z >= ADMIN_MATCH_MODE)
        {
            // change overtime
            if (self.pos1_y == -1)
                self.pos1_y = 10;
            else if (self.pos1_y == 10)
                self.pos1_y = 5;
            else
                self.pos1_y = self.pos1_y - 1;
        }
        else
        {
            // change fraglimit
            self.pos1_y = 10 * ceil(self.pos1_y / 10);
            if (self.pos1_y > 40)
                self.pos1_y = 0;
            else
                self.pos1_y = self.pos1_y + 10;
        }
    }
    else if (self.t_length == 3)
    {
        // change gibs
        if (self.pos2_x == OPTIONS_HIGH_GIBS)
            self.pos2_x = OPTIONS_NO_GIBS;
        else
            self.pos2_x = self.pos2_x + 1;
    }
    else if (self.t_length == 4)
    {
        // change teamplay
        if (self.pos2_y == 2)
		{
			if (self.pos1_z == ADMIN_MATCH_MODE)
				self.pos2_y = 1;
			else
				self.pos2_y = 0;
		}
        else
            self.pos2_y = self.pos2_y + 1;
    }
    else if (self.t_length == 5)
    {
        // change noexit
        if (self.pos2_z == 2)
            self.pos2_z = 0;
        else
            self.pos2_z = self.pos2_z + 1;
    }
    else if (self.t_length == 6)
    {
        // change pausable
        if (self.aflag & OPTIONS_PAUSABLE)
            self.aflag = self.aflag - OPTIONS_PAUSABLE;
        else
            self.aflag = self.aflag | OPTIONS_PAUSABLE;
    }
    else if (self.t_length == 18)
    {
        // change deathmatch
        self.light_lev = self.light_lev + 1;
        if (self.light_lev == 4)
            self.light_lev = 1;
    }
    else if (self.t_length == 19)
    {
        // change ticrate
        self.worldtype = (ceil(self.worldtype * 100) + 1) / 100;
        if (self.worldtype > 0.1 || self.worldtype < 0.05)
            self.worldtype = 0.05;
    }
    else if (self.t_length == 20)
    {
        // change quad
        if (self.aflag & ELOHIM_NO_QUAD)
            self.aflag = self.aflag - ELOHIM_NO_QUAD;
        else
            self.aflag = self.aflag | ELOHIM_NO_QUAD;
    }
    else if (self.t_length == 21)
    {
        // change pent
        if (self.aflag & ELOHIM_NO_PENT)
            self.aflag = self.aflag - ELOHIM_NO_PENT;
        else
            self.aflag = self.aflag | ELOHIM_NO_PENT;
    }
    else if (self.t_length == 22)
    {
        // change ring
        if (self.aflag & ELOHIM_NO_RING)
            self.aflag = self.aflag - ELOHIM_NO_RING;
        else
            self.aflag = self.aflag | ELOHIM_NO_RING;
    }
    else if (self.t_length == 23)
    {
        // change mode vote
        if (self.aflag & ELOHIM_MODE_VOTE)
            self.aflag = self.aflag - ELOHIM_MODE_VOTE;
        else
            self.aflag = self.aflag | ELOHIM_MODE_VOTE;
    }

    // play sound
    stuffcmd(self, "play misc/menu3.wav\n");
};

//
//  F I N I S H  S E T T I N G
//
//  Called when 'done' is selected.
//
void () options_finish_setting =
{
	local float mode;

	// do this now so that setting teamplay doesn't confuse it
	mode = options_get_mode();

    centerprint(self, " ");

    // play sound
    stuffcmd(self, "play misc/menu2.wav\n");

    // make requested changes
    if (self.pos1_z >= ADMIN_MATCH_MODE)
    {
        // match mode
        if (self.pos1_x != elohim_timelimit)
            votables_request_set_timelimit(self.pos1_x);
        if (self.pos1_y != elohim_overtime)
            votables_request_set_overtime(self.pos1_y);
    }
    else
    {
        // normal or practice mode
        if (self.pos1_x != cvar("timelimit"))
            utils_set_cvar("timelimit", self.pos1_x);
        if (self.pos1_y != cvar("fraglimit"))
            elohim_set_fraglimit(self.pos1_y);
        if (self.pos2_z != cvar("noexit"))
            utils_set_cvar("noexit", self.pos2_z);
    }
    if (self.pos2_y != teamplay)
        elohim_set_teamplay(self.pos2_y);

    if (self.pos2_x != options_get_gibs())
    {
        // gibs has changed
        votables_request_set_gibs(self.pos2_x);
    }
    if ((self.aflag & OPTIONS_PAUSABLE) != cvar("pausable"))
    {
        // pausable has changed
        utils_set_cvar("pausable", self.aflag & OPTIONS_PAUSABLE);
		local string s;
		s = ftos(self.aflag & OPTIONS_PAUSABLE);
        announce2("pausable changed to ", s);
    }
    if (self.light_lev != cvar("deathmatch"))
		admin_dmset(self.light_lev);
    if (self.worldtype != cvar("sys_ticrate"))
    {
        // ticrate has changed
        local string newtic;
        if (self.worldtype == 0.05)
            newtic = "0.05";
        else if (self.worldtype == 0.06)
            newtic = "0.06";
        else if (self.worldtype == 0.07)
            newtic = "0.07";
        else if (self.worldtype == 0.08)
            newtic = "0.08";
        else if (self.worldtype == 0.09)
            newtic = "0.09";
        else
            newtic = "0.1";
        cvar_set("sys_ticrate", newtic);
        announce2("sys_ticrate changed to ", newtic);
    }
    if ((self.aflag & ELOHIM_NO_QUAD) != (elohim_playmode & ELOHIM_NO_QUAD))
        votables_set_quad(); // quad has changed
    if ((self.aflag & ELOHIM_NO_PENT) != (elohim_playmode & ELOHIM_NO_PENT))
        votables_set_pent(); // pent has changed
    if ((self.aflag & ELOHIM_NO_RING) != (elohim_playmode & ELOHIM_NO_RING))
        votables_set_ring(); // ring has changed
    if ((self.aflag & ELOHIM_MODE_VOTE) != (elohim_playmode & ELOHIM_MODE_VOTE))
		utils_toggle_sflag(ELOHIM_MODE_VOTE, "Mode voting"); // mode vote has changed
    if (self.pos1_z != mode)
        votables_request_set_mode(self.pos1_z);

    self.style = self.style - ELOHIM_SETTING_OPTIONS;
    self.style = self.style - (self.style & ELOHIM_OK_TO_SHOOT);
};

//
//  P R E  T H I N K
//
//  Called from Client.qc while options are being set.
//
void () options_pre_think =
{
    if (!(self.flags & FL_JUMPRELEASED))
    {
        if (time >= self.delay)
            options_display();
        if (!self.button0 && !self.button2)
            self.flags = self.flags | FL_JUMPRELEASED;
    }
    else if (self.button2)
    {
        // go to the next option
        self.flags = self.flags - FL_JUMPRELEASED;
        self.t_length = (self.t_length & 127) + 1;
        if (self.t_length == 9)
            self.t_length = 0;
        if (self.t_length == 25)
            self.t_length = 18;
		if (self.pos1_z == ADMIN_MATCH_MODE && self.t_length == 5)
			self.t_length = 6;
        else if (self.pos1_z == ADMIN_INDIVIDUAL_MODE && self.t_length == 4)
            self.t_length = 6;
        options_display();
        stuffcmd(self, "play misc/menu1.wav\n");
    }
    else if (self.button0)
    {
        // change option
        self.flags = self.flags - FL_JUMPRELEASED;
        self.t_length = self.t_length & 127;
        if (self.t_length == 8)
        {
            options_finish_setting();
            return;
        }
        else if (self.t_length == 7)
        {
            self.t_length = 18; // go to next screen
            stuffcmd(self, "play misc/menu2.wav\n");
        }
        else if (self.t_length == 24)
        {
            self.t_length = 7;  // go back to main options
            stuffcmd(self, "play misc/menu2.wav\n");
        }
        else
            options_change();
        options_display();            
    }
    else
    {
        // just check to see if we need to update the display
        if (time >= self.delay)
            options_display();
        return;
    }
};
