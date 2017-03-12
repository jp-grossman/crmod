//
// Debug.qc
//
// Debugging routines
//

float () options_get_mode;

//
//  I N F O
//
//  General info - currently autochase scores
//
void () debug_info =
{
    local entity e;
	
    sprint(self, "clients:\n");
    e = find(world, classname, "player");
    while (e)
    {
		if ((e.style & ELOHIM_CONNECTED) && !(e.style & ELOHIM_OBSERVER))
		{
			local string temp;
			temp = ftos(e.colormap);
			sprint(self, temp, " ", e.netname, "   ");
			temp = ftos(e.crmod_chase_score);
			sprint(self, temp, "\n");
		}
        e = find(e, classname, "player");
    }
	sprint(self, "cameras:\n");
    e = find(world, classname, "elohim_camera");
    while (e)
    {
        local string temp;
        temp = ftos(e.crmod_chase_score);
        sprint(self, temp, " ");
        e = find(e, classname, "elohim_camera");
    }
	sprint(self, "\n");
};

//
//  S P R I N T
//
void (string s) debug_sprint = 
{
	sprint(self, s);
};

//
//  D P R I N T
//
void (string s) debug_dprint = 
{
	dprint(#);
};

//
//  F L A G S
//
//  Dump the server flags
//
void (void (string s) print) debug_server_flags =
{
	print("Server flags:\n");
    print("\n");

	// playmode flags
	if (elohim_playmode & ELOHIM_SAME_LEVEL)
		print("ELOHIM_SAME_LEVEL\n");
	if (elohim_playmode & ELOHIM_MATCH_MODE)
		print("ELOHIM_MATCH_MODE\n");
	if (elohim_playmode & ELOHIM_PRACTICE_MODE)
		print("ELOHIM_PRACTICE_MODE\n");
	if (elohim_playmode & ELOHIM_SERVER_INITIALIZED)
		print("ELOHIM_SERVER_INITIALIZED\n");
	if (elohim_playmode & ELOHIM_NO_GIBS)
		print("ELOHIM_NO_GIBS\n");
	if (elohim_playmode & ELOHIM_LOW_GIBS)
		print("ELOHIM_LOW_GIBS\n");
	if (elohim_playmode & ELOHIM_NO_QUAD)
		print("ELOHIM_NO_QUAD\n");
	if (elohim_playmode & ELOHIM_NO_PENT)
		print("ELOHIM_NO_PENT\n");
	if (elohim_playmode & ELOHIM_NO_RING)
		print("ELOHIM_NO_RING\n");
	if (elohim_playmode & ELOHIM_MODE_VOTE)
		print("ELOHIM_MODE_VOTE\n");
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
		print("ELOHIM_DEDICATED_SERVER\n");
	if (elohim_playmode & ELOHIM_NO_SPOOGE)
		print("ELOHIM_NO_SPOOGE\n");
	if (elohim_playmode & CRMOD_QSMACK_ON)
		print("CRMOD_QSMACK_ON\n");
	if (elohim_playmode & ELOHIM_EXTENDED_OBITS)
		print("ELOHIM_EXTENDED_OBITS\n");
	if (elohim_playmode & ELOHIM_CONSOLE_INITIALIZED)
		print("ELOHIM_CONSOLE_INITIALIZED\n");
	if (elohim_playmode & ELOHIM_FAST_START)
		print("ELOHIM_FAST_START\n");
	if (elohim_playmode & ELOHIM_FRESH_SPAWNS)
		print("ELOHIM_FRESH_SPAWNS\n");
	if (elohim_playmode & ELOHIM_AUTO_PAUSE)
		print("ELOHIM_AUTO_PAUSE\n");
	if (elohim_playmode & ELOHIM_AUTOSTATS)
		print("ELOHIM_AUTOSTATS\n");
	if (elohim_playmode & ELOHIM_NO_VOTE_ADMIN)
		print("ELOHIM_NO_VOTE_ADMIN\n");
	if (elohim_playmode & ELOHIM_LEVEL_VOTE)
		print("ELOHIM_LEVEL_VOTE\n");

    print("\n");

	// state flags
	if (elohim_state & ELOHIM_TIMER_STARTED)
		print("ELOHIM_TIMER_STARTED\n");
	if (elohim_state & ELOHIM_MATCH_STARTED)
		print("ELOHIM_MATCH_STARTED\n");
	if (elohim_state & ELOHIM_MATCH_PAUSED)
		print("ELOHIM_MATCH_PAUSED\n");
	if (elohim_state & ELOHIM_MATCH_OVER)
		print("ELOHIM_MATCH_OVER\n");
	if (elohim_state & ELOHIM_MATCH_WAIT)
		print("ELOHIM_MATCH_WAIT\n");
	if (elohim_state & ELOHIM_NO_PRACTICE)
		print("ELOHIM_NO_PRACTICE\n");
	if (elohim_state & ELOHIM_ELOSTART)
		print("ELOHIM_ELOSTART\n");
	if (elohim_state & ELOHIM_UNPAUSING)
		print("ELOHIM_UNPAUSING\n");
	if (elohim_state & ELOHIM_AUTO_PAUSED)
		print("ELOHIM_AUTO_PAUSED\n");
	if (elohim_state & ELOHIM_DELAYED_AUTOSS)
		print("ELOHIM_DELAYED_AUTOSS\n");
	if (elohim_state & ELOHIM_TAKING_AUTOSS)
		print("ELOHIM_TAKING_AUTOSS\n");

    print("\n");
};

//
//  V A R S
//
//  Dumps certain elohim global variables to the console.
//
//  (Do NOT dump elohim_password)
//
void () debug_vars = 
{
	// entities
	sprint(self, "elohim_num_spawns = ");
	utils_print_float(elohim_num_spawns);	
	sprint(self, "elohim_num_starts = ");
	utils_print_float(elohim_num_starts);	
	sprint(self, "elohim_num_cameras = ");
	utils_print_float(elohim_num_cameras);	
	sprint(self, "elohim_score_count = ");
	utils_print_float(elohim_score_count);	
	sprint(self, "elohim_numteams = ");
	utils_print_float(elohim_numteams);	
	sprint(self, "elohim_sentinel.ammo_rockets = ");
	utils_print_float(elohim_sentinel.ammo_rockets);
};

//
//  E N D  T H I N K
//
void () debug_end_think = 
{
    stuffcmd(self.owner, "name cr6debug\n");
    remove(self);
};

//
//  C V A R  T H I N K
//
void () debug_cvar_think = 
{
	local float f;
	local string s;

	f = cvar(self.owner.netname);
	s = ftos(f);
	sprint(self.owner, self.owner.netname, " = ", s, "\n");
    debug_end_think();
};

//
//  P A R M 1  T H I N K
//
void () debug_parm1_think = 
{
	local string s;

	s = ftos(auto_parm1);
	sprint(self.owner, "auto_parm1 changed from ", s, " to ");
	auto_parm1 = utils_stof(self.owner.netname);
	s = ftos(auto_parm1);
	sprint(self.owner, s, "\n");
    debug_end_think();
};

//
//  P A R M 2  T H I N K
//
void () debug_parm2_think = 
{
	local string s;

	s = ftos(auto_parm2);
	sprint(self.owner, "auto_parm2 changed from ", s, " to ");
	auto_parm2 = utils_stof(self.owner.netname);
	s = ftos(auto_parm2);
	sprint(self.owner, s, "\n");
    debug_end_think();
};

//
//  P A R M 3  T H I N K
//
void () debug_parm3_think = 
{
	local string s;

	s = ftos(auto_parm3);
	sprint(self.owner, "auto_parm3 changed from ", s, " to ");
	auto_parm3 = utils_stof(self.owner.netname);
	s = ftos(auto_parm3);
	sprint(self.owner, s, "\n");
    debug_end_think();
};

//
//  P A R M 4  T H I N K
//
void () debug_parm4_think = 
{
	local string s;

	s = ftos(auto_parm4);
	sprint(self.owner, "auto_parm4 changed from ", s, " to ");
	auto_parm4 = utils_stof(self.owner.netname);
	s = ftos(auto_parm4);
	sprint(self.owner, s, "\n");
    debug_end_think();
};

//
//  P A R M S
//
void () debug_parms = 
{
	sprint(self, "auto_parm1 = ");
	utils_print_float(auto_parm1);
	sprint(self, "auto_parm2 = ");
	utils_print_float(auto_parm2);
	sprint(self, "auto_parm3 = ");
	utils_print_float(auto_parm3);
	sprint(self, "auto_parm4 = ");
	utils_print_float(auto_parm4);
};

//
//  C L I E N T  F L A G S
//
//  Dumps movetarget's flags
//
void (entity e, void (string s) print) debug_client_flags = 
{
	local float nulltarget;

	nulltarget = 0;
    if (!&e)
	{
		if (print == debug_sprint)
		{
			e = self;
			nulltarget = 1;
		}
		else
		{
			dprint("No debug client\n");
			return;
		}
	}

    print("Client flags for ");
	print(e.netname);
	print(":\n");
    print("\n");
    if (e.style & ELOHIM_NEW_CLIENT)
        print("ELOHIM_NEW_CLIENT\n");
    if (e.style & ELOHIM_ADMINISTRATOR)
        print("ELOHIM_ADMINISTRATOR\n");
   	if (e.style & CRMOD_DETECTING_QSMACK)	// CRMOD was SMOOTH
		print("CRMOD_DETECTING_QSMACK\n");					// CRMOD was SMOOTH
	if (e.style & ELOHIM_POP_FORWARD)
        print("ELOHIM_POP_FORWARD\n");
    if (e.style & ELOHIM_READY)
        print("ELOHIM_READY\n");
    if (e.style & ELOHIM_YES)
        print("ELOHIM_YES\n");
    if (e.style & ELOHIM_HEADS_UP)
        print("ELOHIM_HEADS_UP\n");
    if (e.style & ELOHIM_SETTING_OPTIONS)
        print("ELOHIM_SETTING_OPTIONS\n");
    if (e.style & ELOHIM_MOTD)
        print("ELOHIM_MOTD\n");
    if (e.style & ELOHIM_OK_TO_SHOOT)
        print("ELOHIM_OK_TO_SHOOT\n");
    if (e.style & ELOHIM_KICK_CONFIRM)
        print("ELOHIM_KICK_CONFIRM\n");
    if (e.style & ELOHIM_CONFIRM_LEAVE)
        print("ELOHIM_CONFIRM_LEAVE\n");
    if (e.style & ELOHIM_CONNECTED)
        print("ELOHIM_CONNECTED\n");
    if (e.style & ELOHIM_FOUND_BINDINGS)
        print("ELOHIM_FOUND_BINDINGS\n");
	if (e.style & CRMOD_SMART_WEAPON)
		print("CRMOD_SMART_WEAPON\n");
    if (e.style & ELOHIM_OBSERVER)
        print("ELOHIM_OBSERVER\n");
    if (e.style & CRMOD_QSMACK)
        print("CRMOD_QSMACK\n");
    if (e.style & ELOHIM_SCOREBOARD)
        print("ELOHIM_SCOREBOARD\n");
    if (e.style & ELOHIM_NO_POST_THINK)
        print("ELOHIM_NO_POST_THINK\n");
    if (e.style & ELOHIM_WINQUAKE)
        print("ELOHIM_WINQUAKE\n");
    if (e.style & ELOHIM_GLQUAKE)
        print("ELOHIM_GLQUAKE\n");
    if (e.style & ELOHIM_AUTOSTATS)
        print("ELOHIM_AUTOSTATS\n");
	if (e.style & ELOHIM_SHOW_TIMER)
		print("ELOHIM_SHOW_TIMER\n");
	if (e.style & ELOHIM_PROQUAKE)
		print("ELOHIM_PROQUAKE\n");
	if (e.oflags & ELOHIM_SENT_BINDINGS)
		print("ELOHIM_SENT_BINDINGS\n");
	if (e.oflags & ELOHIM_AFK)
		print("ELOHIM_AFK\n");
    print("\n");

    if (e.oflags & OBSERVER_WALK)
        print("OBSERVER_WALK\n");
    if (e.oflags & OBSERVER_FLY)
        print("OBSERVER_FLY\n");
    if (e.oflags & OBSERVER_CHASE)
        print("OBSERVER_CHASE\n");
    if (e.oflags & OBSERVER_DEMO)
        print("OBSERVER_DEMO\n");
    if (e.oflags & OBSERVER_CAMERA)
    	print("OBSERVER_CAMERA\n");
	if (e.oflags & OBSERVER_AUTO)
		print("OBSERVER_AUTO\n");
	if (e.oflags & OBSERVER_TOURNEY)
		print("OBSERVER_TOURNEY\n");
	if (e.oflags & OBSERVER_GO_AUTO)
		print("OBSERVER_GO_AUTO\n");
	if (e.oflags & OBSERVER_COMMENTARY)
		print("OBSERVER_COMMENTARY\n");
    print("\n");

	if (nulltarget)
		self.movetarget = world;
};

//
//  G E T  M O V E T A R G E T
//
void () debug_get_movetarget = 
{
	self.use = SUB_Null;

	other = self.movetarget;
	self.movetarget = find(world, classname, "player");
	while (self.movetarget)
	{
		if (self.movetarget.colormap == self.finaldest_z)
		{
			sprint(self, "Debugging ", self.movetarget.netname, "\n");
			return;	
		}
		self.movetarget = find(self.movetarget, classname, "player");
	}
	sprint(self, "Not found\n");
	self.movetarget = other;
};

//
//  H E L P
//
//  Print out debug commands
//
void () debug_help =
{
	sprint(self, "Debug commands:\n");
	sprint(self, " dbinfo     - General info\n");
	sprint(self, " dbflags    - Server flags\n");
	sprint(self, " dbvars     - Elohim global variables\n");
	sprint(self, " dbcvar     - Console variable\n");
	sprint(self, " dbclient   - Choose movetarget\n");
	sprint(self, " dbcflags   - View movetarget flags\n");
	sprint(self, " dbparm1-4  - change auto_parm1-4\n");
	sprint(self, " dbparms    - view auto_parms\n");
	sprint(self, " dbplayers  - list players\n");
	sprint(self, " dbteams    - list teams\n");
	sprint(self, " dbsettings - list server settings\n");
    sprint(self, " dbents     - show entity information\n");
	sprint(self, " dbwingl    - who is using dos/win/gl\n");
};

//
//  P L A Y E R S
//
void () debug_players = 
{
	local entity player;

	player = elohim_sentinel.next_player;
	while (player)
	{
		sprint(self, player.netname, "\n");
		player = player.next_player;
	}
};

//
//  T E A M S
//
void () debug_teams = 
{
	local entity pteam;
	local entity player;
	local float n;

	if (!(elohim_playmode && ELOHIM_MATCH_MODE) || !teamplay)
	{
		sprint(self, "Valid in match mode only\n");
		return;
	}

	pteam = elohim_sentinel.next_team;
	while (pteam)
	{
		sprint(self, pteam.mdl, " - rockets = ");
		utils_print_float(pteam.ammo_rockets);
		n = pteam.count;
		player = pteam.next_player;
		while(n)
		{
			sprint(self, "    ", player.netname, "\n");
			player = player.next_player;
			n = n - 1;
		}
		pteam = pteam.next_team;
	}
};

//
//  O N O F F
//
void (float val) debug_onoff = 
{
	if (val)
		sprint(self, "on\n");
	else
		sprint(self, "off\n");
};

//
//  S H O W  C V A R
//
void (string varname) debug_show_cvar = 
{
	local float temp;

	temp = cvar(varname);
	sprint(self, varname, " = ");
	utils_print_float(temp);
};

//
//  S E T T I N G S
//
void () debug_settings = 
{
	local float temp;
	local string sz;

    temp = options_get_mode();
    sz = strings_get_mode(temp);
    sprint(self, sz, " mode\n");

	debug_show_cvar("timelimit");
	debug_show_cvar("fraglimit");
	debug_show_cvar("teamplay");
	debug_show_cvar("deathmatch");
	debug_show_cvar("pausable");
	temp = cvar("sys_ticrate");
	sprint(self, "sys_ticrate = ");
	utils_print_floatn(temp, 3);

	sprint(self, "overtime: ");
	if (elohim_overtime == -1)
		sprint(self, "sudden death\n");
	else if (elohim_overtime == 0)
		sprint(self, "disabled\n");
	else 
	{
		sz = ftos(elohim_overtime);
		sprint(self, sz);
		sz = strings_szplural(elohim_overtime);
		sprint(self, " minute", sz, "\n");
	}

	sz = ftos(elohim_maxteams);
	sprint(self, "maxteams: ", sz, "\n");

	sprint(self, "gibs: ");
	if (elohim_playmode & ELOHIM_NO_GIBS)
		sprint(self, "off\n");
	else if (elohim_playmode & ELOHIM_LOW_GIBS)
		sprint(self, "low\n");
	else
		sprint(self, "high\n");

	sprint(self, "safe practice: ");
	debug_onoff(elohim_playmode & ELOHIM_NO_SPOOGE);

	sprint(self, "quad: ");
	debug_onoff(ELOHIM_NO_QUAD - (elohim_playmode & ELOHIM_NO_QUAD));
	sprint(self, "pentagram: ");
	debug_onoff(ELOHIM_NO_PENT - (elohim_playmode & ELOHIM_NO_PENT));
	sprint(self, "ring: ");
	debug_onoff(ELOHIM_NO_RING - (elohim_playmode & ELOHIM_NO_RING));

	sprint(self, "mode voting: ");
	debug_onoff(elohim_playmode & ELOHIM_MODE_VOTE);
	sprint(self, "level voting: ");
	debug_onoff(elohim_playmode & ELOHIM_LEVEL_VOTE);
	sprint(self, "extended obituaries: ");
	debug_onoff(elohim_playmode & ELOHIM_EXTENDED_OBITS);
	sprint(self, "fast match starts: ");
	debug_onoff(elohim_playmode & ELOHIM_FAST_START);
	sprint(self, "fresh spawns: ");
	debug_onoff(elohim_playmode & ELOHIM_FRESH_SPAWNS);
};

//
//  E N T I T I E S
//
void () debug_entities = 
{
   local entity e;
   local float num;

   e = nextent(world);
   sprint(self,"  0 \"",e.classname,"\"\n");
   num = 1;
   while (e) 
   {
      utils_print_int3(num);
      num = num + 1;
      sprint(self," \"",e.classname,"\"\n");
      e = nextent(e);
   }
};

//
//  W I N G L
//
void () debug_wingl = 
{
	local entity e;

	sprint(self, "\b Quake Version | Name\n");
	sprint(self, "\b---------------+----------------\n");

	e = find(world, classname, "player");
	while (e)
	{
		if (e.style & ELOHIM_CONNECTED)
		{
			if (e.style & ELOHIM_WINQUAKE)
			{
				if (e.style & ELOHIM_GLQUAKE)
					sprint(self, "   ???         ü ", e.netname, "\n");
				else
					sprint(self, "   WinQuake    ü ", e.netname, "\n");
			}
			else if (e.style & ELOHIM_GLQUAKE)
				sprint(self, "   GlQuake     ü ", e.netname, "\n");
			else
				sprint(self, "   DosQuake    ü ", e.netname, "\n");
		}
		e = find(e, classname, "player");
	}
};

//
//  L O A D  A L I A S E S
//
void () debug_load_aliases = 
{
	sprint(self, "Loading debug binds...\n");

	stuffcmd(self, "alias dbbinds echo debug binds already loaded\n");
	stuffcmd(self, "alias dbinfo impulse 40\n"); 
	stuffcmd(self, "alias dbflags impulse 41\n");
	stuffcmd(self, "alias dbvars impulse 42\n"); 
	stuffcmd(self, "alias dbcvar impulse 43\n"); 
	stuffcmd(self, "alias dbclient impulse 44\n");
	stuffcmd(self, "alias dbcflags impulse 45\n");
	stuffcmd(self, "alias dbparm1 impulse 46\n");
	stuffcmd(self, "alias dbparm2 impulse 47\n");
	stuffcmd(self, "alias dbparm3 impulse 48\n");
	stuffcmd(self, "alias dbparm4 impulse 49\n");
	stuffcmd(self, "alias dbparms impulse 50\n");
	stuffcmd(self, "alias dbplayers impulse 51\n");
	stuffcmd(self, "alias dbteams impulse 52\n");
	stuffcmd(self, "alias dbsettings impulse 53\n");
    stuffcmd(self, "alias dbents impulse 54\n");
	stuffcmd(self, "alias dbwingl impulse 55\n");
	stuffcmd(self, "alias dbhelp impulse 59\n");
};

//
//  I M P U L S E
//
void () debug_impulse = 
{
    if (!(self.style & ELOHIM_ADMINISTRATOR) && (self.netname != "cr6debug"))
        return;

	if (self.impulse == 40)
		debug_info();
	else if (self.impulse == 41)
		debug_server_flags(debug_sprint);
	else if (self.impulse == 42)
		debug_vars();
	else if (self.impulse == 43)
		utils_make_scheduled_event(debug_cvar_think, 0.5);
	else if (self.impulse == 44)
	{
		sprint(self, "Enter client number:\n");
		self.use = debug_get_movetarget;
	}
	else if (self.impulse == 45)
		debug_client_flags(self.movetarget, debug_sprint);
	else if (self.impulse == 46)
		utils_make_scheduled_event(debug_parm1_think, 0.5);
	else if (self.impulse == 47)
		utils_make_scheduled_event(debug_parm2_think, 0.5);
	else if (self.impulse == 48)
		utils_make_scheduled_event(debug_parm3_think, 0.5);
	else if (self.impulse == 49)
		utils_make_scheduled_event(debug_parm4_think, 0.5);
	else if (self.impulse == 50)
		debug_parms();
	else if (self.impulse == 51)
		debug_players();
	else if (self.impulse == 52)
		debug_teams();
	else if (self.impulse == 53)
		debug_settings();
	else if (self.impulse == 54)
		debug_entities();
	else if (self.impulse == 55)
		debug_wingl();
	else if (self.impulse == 58)
		debug_load_aliases();
	else if (self.impulse == 59)
		debug_help();
};

