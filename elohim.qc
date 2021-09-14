//
// Elohim.qc
//
// This is the main file for CRMod++.  CRMod++ was derived from the
// Elohim server, which is why everything is still called "elohim".
//
// Developed by J.P. Grossman (a.k.a. ùMephistopheles) and Paul Baker
//
// All code by J.P. Grossman unless otherwise commented.
//
// Client fields used:
//
// General:
//
// .style           - Elohim player flags
// .count           - used for entering password / ghostcode / warplevel
// .cnt             - number of suicides remaining
// .crmod_hack_count- count of admin attempts
// .wait            - time to do periodic checks
// .state           - unique player id
// .finaldest_x     - used to test for disconnected players
// .height          - used to store player team
// .colours         - used to store cl[CL_COLORS]
// .use             - pointer to function to call when a number is entered
// .finaldest_z     - the number that was entered
// .owner           - players's ghost entity
// .enemy           - stores last spawn point/camera location for admins
// .next_team		- pointer to player's team (match) or next player (individual)
// .next_player		- pointer to next player (match/individual)
// .lip             - grenade spam count for practice mode
// .delay			- touchback delay for quake tag
// .finaldest_y     - backup for movetype to make sure it doesn't change illegally
// .last_active		- used for detecting afk players
//
// Statistics:
//
// .dest1_x         - damage fired from bullets
// .dest2_x         - damage done from bullets (to enemies)
// .dest1_y         - damage fired from nails
// .dest2_y         - damage done from nails (to enemies)
// .dest1_z         - damage fired from lightning gun
// .dest2_z         - damage done from lightning gun (to enemies)
// .dest_x          - damage fired from rockets
// .dest_y          - damage done from rockets (to enemies)
// .mangle_x        - number of times killed self
// .mangle_y        - number of times killed teammate
// .mangle_z        - number of times was killed
// .crmod_qdwep_x   - damage done with quad        // CRMOD
// .crmod_qdwep_y   - damage fired with quad       // CRMOD
// .crmod_qdwep_z   - number times quad pickedup   // CRMOD
// .crmod_qdkill_x  - number of enemies killed     // CRMOD
// .crmod_qdkill_y  - number of teammates killed   // CRMOD
// .crmod_qdkill_z  - number of self kills         // CRMOD
// .crmod_badstats_x - number of RL paks lost
// .crmod_badstats_y - total damage done to self
// .crmod_badstats_z - total damage done to teammates
//
// Observer mode:
//
// .trigger_field   - closest teleport when observing, last spawn if playing
// .t_width         - activation radius for closest teleport
// .dest            - stores destination for popping forward through doors
// .dest1           - stores velocity for popping forward through doors
// .delay           - time to refresh head's up display for observing
// .speed           - z component of velocity from previous frame (for fly)
// .movetarget      - player being watched in observer mode (world if none)
// .owner           - last spawn point/camera for admins
// .lip             - time to clear display when no target is in line of sight (walk/fly)
// .attack_finished - used to delay before flying through obstacles
//
// Used for setting options:
//
// .delay     - time to update display (shared with observer.qc)
// .pos1_x    - timelimit
// .pos1_y    - fraglimit
// .pos1_z    - mode
// .pos2_x    - gibs
// .pos2_y    - teamplay
// .pos2_z    - noexit
// .worldtype - sys_ticrate
// .light_lev - deathmatch
// .aflag     - pausable/quad/pent/ring/mode vote
// .t_length  - which option is currently selected
//
// Ghost fields:
//
// .count			- ghostcode
// .height			- team
// .state			- indicates if the ghost contains copy on pause data
// ** Always copied:
// .frags
// .dest
// .dest1
// .dest2
// .mangle
// .crmod_qdwep
// .crmod_qdkill
// .style
// .crmod_hack_count
// ** Copied on pause (if not dead):
// .frame
// .effects
// .origin
// .angles
// .waterlevel
// .watertype
// .crmod_old_velocity
// .nextthink
// .think
// .health
// .items
// .armortype
// .armorvalue
// .weapon
// .weaponmodel
// .weaponframe
// .currentammo
// .ammo_shells
// .ammo_nails
// .ammo_rockets
// .ammo_cells
// .flags
// .walkframe
// .attack_finished
// .pain_finished
// .air_finished
// .invincible_finished
// .invisible_finished
// .super_damage_finished
// .radsuit_finished
// .invincible_time
// .invisible_time
// .super_time
// .rad_time
// .show_hostile
// .jump_flag
// .swim_flag
// .bubble_count
// 
// Teams:
//
// .next_player   - first player in team
// .next_team     - next team
// .frags		  - team frags
// .height		  - team pants colour
// .count		  - number of players
// .frags         - team score
// .netname       - strings_get_teamname(...)
// .mdl           - strings_get_teamname_bronze(...)
// .ammo_rockets  - number of rocket launchers team has
// .dest_x/y/z    - RA/YA/GA stats
// .dest1_x/y/z   - RL/GL/GL stats
// .dest2_x/y/z   - Q/666/ring stats
// .pos1_x/y/z    - SNG/NG/MH stats
// .mangle_x/y/z  - control/+pak/-pak stats
// .cnt           - control percentage per second constant
// .colormap	  - shirt colour of first player on team
//
// Sentinel:
//
// .next_player   - first player in list
// .next_team     - first team in list
// .next_camera   - first camera in list
// .crmod_chase_score - ELOHIM_NEGINF
// .frags         - ELOHIM_NEGINF
// .think         - score_check_sudden_death
// .nextthink     - check sudden death
// .ammo_rockets  - number of rocket launchers in play
// .movetarget    - which team has control
// .owner         - pointer for stats
// .cnt			  - number of seconds elapsed in match
//  
// Match timer:
//
// .lip		- minutes remaining
// .count	- seconds remaining
// .dest	- time intervals for countdown (fast/normal) 
// .cnt		- stores nextthing during pause
//
// Scoreboard:
//
// .timeslot  - slot used for time remaining
//
// Powerups
//
// .noise3    - console pickup message
// .noise4	  - quaketv pickup message
// .owner	  - player that picked it up
// .height    - height of player that picked it up
// .count	  - number of times in a row player picked it up
// .cnt		  - number of times in a row team picked it up
// .fly_sound - sound number for quakeTV
//
// Rockets
//
// .dmg              - did damage flag
// .state            - rocket jump flag
// .crmod_badstats_y - damage done to self
//
// Console variables used:
//
// samelevel    = elohim_playmode - server flags
// scratch4     = elohim_level    - level number in user level sequence
// scratch1     = elohim_overtime - length of overtime
// scratch2     = elohim_maxteams
// scratch3						  - used for utils_stof
// temp1                          - console commands
//

// function declarations
void () elohim_remove_start_teleport;
void () elohim_find_powerups;
void () elohim_exec_configs;
void (float vlaue) elohim_set_teamplay;
void (float vlaue) elohim_set_fraglimit;
void () stats_reset_player;
void () stats_show_quadstats;
void () stats_show_killstats;
void () stats_show_efficiency;
void () stats_show_summary;
void () stats_impulse;
void () motd_init_world;
void () motd_create;
void () score_init_world;
void () score_client_disconnect;
void (float command) console_command;
void () console_set_aliases;
void (entity client) observer_disconnect_notify;
void () votables_send_aliases;
void () admin_impulse;
void () admin_start_code;
void (float fDoKick) admin_confirm_kick_response;
void (entity player) admin_disconnect_notify;
void () observer_impulse;
void () observer_help;
void () observer_start;
void () observer_find_teleport;
void () observer_check_size;
void (float response) observer_confirm_leave_response;
void () match_show_timelimit;
void () match_impulse;
void () match_init_world;
void (entity player) match_disconnect_notify;
void () vote_impulse;
float () options_get_mode;
void () execute_changelevel;
void () NextLevel;
void (vector org, entity death_owner) spawn_tdeath;
void () player_stand1;
void () ClientDisconnect;
void (vector org) spawn_tfog;
void () console_get_user_nextlevel;
void () display_init_world;
void () display_update_all;
void () console_testcmd;

//
//  I N I T  W O R L D
//
//  Called from worldspawn in World.qc
//
void () elohim_init_world =
{
    local float mode;
    local string szmode;
    local float temp;

    elohim_version       = "\bClanRing CRMod++ V\6.\6.\2";
    elohim_version_info  = "CRMod++ V6.6.2 09/05/2021";
    crmod_version_number = "6.6.2";

    elohim_playmode = cvar("samelevel");

	// Enable dprints
	cvar_set("developer", "1");

	// Get rid of disconnected players
	cvar_set("net_messagetimeout", "60");

	// Initialize internals
	InternalInit();
	temp = cvar("ambient_fade");
	utils_set_cvar("ambient_fade", temp + 1);
	if (temp == cvar("ambient_fade"))
	{
		elohim_playmode = elohim_playmode | ELOHIM_DEDICATED_SERVER;
		zone_search_hunk();
	}
	else
	{
		utils_set_cvar("ambient_fade", temp);
		zone_init_listen();
	}

	// Initialize sentinel
	elohim_sentinel = spawn();
	elohim_sentinel.next_player = world;
	elohim_sentinel.next_camera = world;
	elohim_sentinel.crmod_chase_score = ELOHIM_NEGINF;
	elohim_sentinel.owner = elohim_sentinel;

    // Initialize user map names, MOTD, etc..
	array_init_world();
    userdefs_init_world();
    motd_init_world();
	score_init_world();
	match_init_world();
	quaketag_init_world();
	qsmack_init_world();
	display_init_world();
    
    // Hack to allow console to emulate an administrator
	world.style = ELOHIM_ADMINISTRATOR;

    // Precache sounds
    precache_sound("wizard/wsight.wav");
	precache_sound("doors/drclos4.wav");
	precache_sound("demon/sight2.wav");
	precache_sound("dog/dsight.wav");
	precache_sound("knight/ksight.wav");
	precache_sound("ogre/ogwake.wav");
	precache_sound("shambler/ssight.wav");
	precache_sound("soldier/sight1.wav");

    // Check to see if we need to initialize the server
    if (!(elohim_playmode & ELOHIM_SERVER_INITIALIZED))
    {
		// Check to see if this is a dedicated server.
		// Dedicated servers do not have an ambient_fade cvar, so the
		// value returned by cvar() will not change.
		if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
			dprint("Initializing dedicated server...\n");
		else
			dprint("Initializing listen server...\n");

		// Set aliases for console commands
		console_set_aliases();

		// Initialize global variables
		if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
			cvar_set("scratch4", "1");  // elohim_level
		cvar_set("scratch1", "0");  // elohim_overtime
		cvar_set("scratch2", "2");  // elohim_maxteams
		serverflags = 0;
		elohim_playmode = elohim_playmode | ELOHIM_SERVER_INITIALIZED;
		elohim_playmode = elohim_playmode | ELOHIM_NO_SPOOGE;
		elohim_playmode = elohim_playmode | ELOHIM_EXTENDED_OBITS;
		elohim_playmode = elohim_playmode | ELOHIM_LEVEL_VOTE;
		utils_set_cvar("samelevel", elohim_playmode);

		if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
			elohim_load_bans = 1;

		local string s;
		s = ftos(cvar("timelimit"));
		cvar_set("timelimit", s, 2); // mute
		s = ftos(cvar("fraglimit"));
		cvar_set("fraglimit", s, 2); // mute
    }

    // Get/set console variables
	teamplay = cvar("teamplay");
    elohim_set_teamplay(-1);
	if (elohim_playmode & ELOHIM_MATCH_MODE)
		cvar_set("fraglimit", "0");
	elohim_set_fraglimit(-1);
	timelimit = cvar("timelimit") * 60;

	elohim_overtime = cvar("scratch1");
	elohim_maxteams = cvar("scratch2");

    if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
    {
		elohim_level = cvar("scratch4");
		elohim_levelcount = 0;
    }
	else 
		elohim_levelcount = -1;

    // Set global variables
    //elohim_player_ids = 1; *UNUSED: Sputnik
    elohim_devparam = 0;
    elohim_nextcheck = time;
	elohim_nextcheck2 = time;
    elohim_request = world;
    elohim_lastcount = 0;
    elohim_state = 0;
    elohim_num_spawns = 0;
    elohim_num_starts = 0;
    elohim_num_cameras = 0;
    elohim_debug_client = world;
	elohim_arena_health = 0;
	crmod_best_chase_target = world;
	crmod_current_chase_target = world;
	crmod_chase_delay = 0;
	crmod_best_camera = world;
	crmod_current_camera = world;
	crmod_camera_delay = 0;
	auto_parm1 = 600; // only rocket bonus
	auto_parm2 = 1000; // pent proximity bonus
	auto_parm3 = 500; // quad proximity bonus
	auto_parm4 = 0;
	elohim_quad = elohim_pent = world;
	utils_make_scheduled_event(elohim_find_powerups, 5);
	nextmap = "";
	elohim_pass_max = 0;	// maximum password
	elohim_kick_mode = KICK_NONE;
	elohim_set_afk = 5;
	elohim_kick_afk = 30;

    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
		elohim_timelimit = cvar("timelimit");
		if (elohim_timelimit == 0)
			elohim_timelimit = 20;
		if (elohim_timelimit < 2)
			elohim_timelimit = 2;
		match_show_timelimit();
    }
    else
		elohim_timelimit = 20;

    // show mode
    mode = options_get_mode();
    szmode = strings_get_mode(mode);
    dprint(szmode, " mode\n");

    // schedule the config files for a bit later so that they don't
    // get loaded twice on startup
	utils_make_scheduled_event(elohim_exec_configs, 1);

	// fix the start teleport bug
	utils_make_scheduled_event(elohim_remove_start_teleport, 2);
};

//
// C L E A R   A F K   S T A T U S
//

void (entity client) clear_afk_status =
{
	if (time > 20)
		client.last_active = time;	
};

//
//  L O G I N  E N T E R  C O D E
//
//  Prompts the client for the 7-digit player id passcode 
//

void () elohim_login_enter_code =
{		
	if (self.finaldest_z > 9)
		return;
	
	if ((self.count == 0) && (self.finaldest_z == 0))	//Sputnik: first number can not be zero.
	{
		sprint(self, "\bZero\b can not be used as the first digit, try again:\n");
		return;
	}

	self.count = self.count * 10 + self.finaldest_z;
	self.lip = self.lip + 1;
	
	if (self.lip > 7)
	{			
		local string s;
		local float p;
		
		p = AddInt(AddInt(&self.qs, 4 * QS_ADDRESS + %32), PQUAKEC_TO_PSTRING);

		if (zone_player_stat_id[(self.state * %1)] == self.count)
		{			
			self.elohim_player_id = self.state;
			s = ftos(self.elohim_player_id);			
			sprint(self, "You are now logged in with id: ",s,"\n");
			dprint("Login: GOOD ",self.netname," (",@p,") ");//output the player's name and ip address
			dprint("id: ",s,"\n");
			name_fix();//Change the 'READY' to white when they are logged in.
		}
		else
		{
			sprint(self, "Invalid passcode.\n");
			self.elohim_player_id = 0;
			
			self.id_hack_count = self.id_hack_count + 1;	
			if (self.id_hack_count > 3)
			{
				s = ftos(self.state);
				bprint(self.netname, " kicked for login hacking\n");				
				dprint("Login: FAIL ",self.netname," (",@p,") ");				
				dprint("id: ",s," \n");
				elohim_kick_player(self);
			}
		}
		self.state = 0;
		self.count = 0;
		self.lip = 0;
		self.use = SUB_Null;
	}
	else
		sprint(self, "Enter the next passcode digit:\n");
};

//
// C H E C K  S T A T  I D 
// 
// Check if someone is already using that number
//
float (float pcode) elohim_check_stat_id =
{
	local entity p;
	
	p = find (world, classname, "player");
	
	while (p)
	{
		if (p.elohim_player_id == pcode)
		{
			sprint(self,p.netname, " \bis already using that id number.\n");
			return TRUE;
		}
		p = find(p, classname, "player");
	}
	return FALSE;	
};

//
//  L O G I N  E N T E R  I D
//
//  Prompts the client for a 3 digit player id number
//
void () elohim_login_enter_id =
{
	if (self.finaldest_z > 9)
		return;
	
	self.count = self.count * 10 + self.finaldest_z;
	self.lip = self.lip + 1;
	
	if (self.lip > 3)
	{
		if (elohim_check_stat_id(self.count)) //someone is using this code!
		{
			self.state = 0;
			self.count = 0;
			self.lip = 0;
			self.use = SUB_Null;
			sprint(self, "\b**ERROR!\n");//something generic
			return;
		}
		self.state = self.count;
		self.count = 0;
		self.lip = 1;
		self.use = elohim_login_enter_code;
		sprint(self, "\b-------------------------------\b\n");
		sprint(self, "Enter the first passcode digit:\n");
	}
	else
		sprint(self, "Enter the next id digit:\n");
};

//
//  L O G I N  S T A R T
//
void () elohim_login_start =
{
	local string s;

	if (!(elohim_playmode & ELOHIM_MATCH_MODE))
	{
		sprint(self, "Command only available in \bMatch\b mode.\n");
		return;
	}

	if ((elohim_state & ELOHIM_MATCH_STARTED) && (!(self.style & ELOHIM_OBSERVER)))
	{
		sprint(self, "You may not login after the match has started.\n");
		return;
	}

	if (self.elohim_player_id > 0)
	{
		s = ftos(self.elohim_player_id);
		sprint(self, "You are already logged in with id: ",s,"\n");
		return;
	}
	
	sprint(self, "Enter the first id digit:\n");
	self.count = 0;
	self.state = 0;
	self.lip = 1;
	self.use = elohim_login_enter_id;
};

//
//  R E M O V E  S T A R T  T E L E P O R T
//
void () elohim_remove_start_teleport = 
{
	if (mapname == "start")
	{
		other = find(world, classname, "trigger_teleport");
		while (other)
		{
			if (other.absmin_z < -600)
			{
				remove(other);
				dprint("start: bad teleport removed (this is not an error)\n");
			}
			other = find(other, classname, "trigger_teleport");
		}
	}
	remove(self);
};

//
//  F I N D  P O W E R U P S
//
void () elohim_find_powerups = 
{
	elohim_quad = find(world, classname, "item_artifact_super_damage");
	elohim_pent = find(world, classname, "item_artifact_invulnerability");
	remove(self);
};

//
//  E X E C  C O N F I G S
//
void () elohim_exec_configs = 
{
	if (cvar("deathmatch") == 0)
		utils_set_cvar("deathmatch", 1);

	console_timelimit = cvar("timelimit");
	console_deathmatch = cvar("deathmatch");
	console_fraglimit = cvar("fraglimit");
	console_pausable = cvar("pausable");
	console_noexit = cvar("noexit");

    localcmd("exec crmod.cfg;wait\n");
	localcmd("\n[all]\n");
	dprint("Searching for optional file config/", mapname, ".cfg\n");
	dprint("It is OPTIONAL - there is nothing wrong if it can't be found.\n");
	localcmd3("exec config/", mapname, ".cfg;wait\n");
	localcmd("\n[done]\n");

	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		dprint("Searching for optional file entities/", mapname, ".ent\n");
		dprint("It is OPTIONAL - there is nothing wrong if it can't be found.\n");
		localcmd3("exec entities/", mapname, ".ent;wait\n");

		dprint("Searching for optional file cameras/", mapname, ".cam\n");
		dprint("It is OPTIONAL - there is nothing wrong if it can't be found.\n");
		localcmd3("exec cameras/", mapname, ".cam;wait\n");

		utils_make_scheduled_event(console_get_user_nextlevel, 4);
	}
    remove(self);
};

//
//  S E T  T E A M P L A Y
//
//  Sets the teamplay server variable to show teamplay and "ClanRing4.0".
//  If value = -1 then the teamplay variable is preserved; otherwise it
//  is changed to 'value'.
//
void (float value) elohim_set_teamplay =
{
    local string temp;

    if (value != -1)
		teamplay = value;
    temp = ftos(teamplay);
    localcmd5("teamplay \"", temp, "?ClanRing", crmod_version_number, "\"\n");
};

//
//  S E T  F R A G L I M I T
//
//  Sets the fraglimit server variable to show fraglimit, "CRMod++",
//  and either "FFA", "Practice", "Match" or "Individual" depending on the 
//  current mode.  If value = -1 then the fraglimit variable is preserved; 
//  otherwise it is changed to 'value'.
//
void (float value) elohim_set_fraglimit =
{
    local string temp;

    if (value != -1)
		utils_set_cvar("fraglimit", value);
    fraglimit = cvar("fraglimit");
    temp = ftos(fraglimit);
    localcmd3("fraglimit \"", temp, " : CRMod++ ");
    if (elohim_playmode & ELOHIM_MATCH_MODE)
	{
		if (teamplay)
			localcmd("Match\"\n");
		else
			localcmd("Individual\"\n");
	}
    else if (elohim_playmode & ELOHIM_PRACTICE_MODE)
		localcmd("Practice\"\n");
    else
		localcmd("FFA\"\n");
};

//
//  S E T  A L I A S E S
//
//  This is scheduled using a temporary entity; the client
//  is stored in self.owner.
//
void () elohim_set_aliases =
{
    local entity temp;

    temp = self;
    self = self.owner;

	if (self.oflags & ELOHIM_SENT_BINDINGS)
	{
		self = temp;
		remove(self);
		return;
	}
    
    sprint(self, "Sending ", elohim_version, " bindings\n");

    stuffcmd(self, "alias ready impulse 120\n");
    stuffcmd(self, "alias notready impulse 121\n");
    stuffcmd(self, "alias yes impulse 115\n");
    stuffcmd(self, "alias no impulse 116\n");

	if (!(self.style & ELOHIM_FOUND_BINDINGS))
	{
		// Cheat fixes
		stuffcmd(self,"r_ambient 0\n");
		stuffcmd(self,"alias chase_active echo chase_active has been disabled on this server.\n");
		stuffcmd(self,"alias r_ambient echo r_ambient has been disabled on this server.\n");

		// Set aliases
		stuffcmd(self, "alias dbbinds impulse 58\n");   // load undocumented debug aliases
		stuffcmd(self, "alias help-server impulse 100\n");
		stuffcmd(self, "alias helpserver impulse 100\n");
		stuffcmd(self, "alias help-observer impulse 101\n");
		stuffcmd(self, "alias rules impulse 103\n");
		if ((elohim_playmode & ELOHIM_DEDICATED_SERVER) || (self.colormap != 1))
		{
			stuffcmd(self, "alias teamplay impulse 103\n");
			stuffcmd(self, "alias deathmatch impulse 103\n");
			stuffcmd(self, "alias timelimit impulse 103\n");
			stuffcmd(self, "alias fraglimit impulse 103\n");
			stuffcmd(self, "alias noexit impulse 103\n");
		}
		// 104 is unused - reserved for debugging
		stuffcmd(self, "alias help-misc impulse 105\n");
		stuffcmd(self, "alias commands impulse 106\n");
		stuffcmd(self, "alias levels impulse 107\n");
		stuffcmd(self, "alias warp impulse 107\n");
		stuffcmd(self, "alias admin impulse 108\n");
		stuffcmd(self, "alias motd impulse 109\n");
		stuffcmd(self, "alias admins impulse 110\n");
		stuffcmd(self, "alias autoweaponon 111\n");
		stuffcmd(self, "alias pq impulse 112\n");
		stuffcmd(self, "alias autoweapon impulse 114\n");
		stuffcmd(self, "alias aw impulse 114\n");
		//stuffcmd(self, "alias yes impulse 115\n");		// moved to top
		//stuffcmd(self, "alias no impulse 116\n");			// moved to top
		stuffcmd(self, "alias vinfo impulse 117\n");
		stuffcmd(self, "alias ticrate impulse 118\n");
		// 119 is 4.0-4.16 ignorethis command
		//stuffcmd(self, "alias ready impulse 120\n");		// moved to top
		//stuffcmd(self, "alias notready impulse 121\n");	// moved to top
		stuffcmd(self, "alias unlock impulse 122\n");
		stuffcmd(self, "alias ready? impulse 123\n");
		stuffcmd(self, "alias timerstop impulse 124\n");
		stuffcmd(self, "alias timerstart impulse 125\n");
		stuffcmd(self, "alias ghostcode echo You do not have a ghost\n");
		stuffcmd(self, "alias ghost impulse 127\n");
		stuffcmd(self, "alias score impulse 128\n");
		stuffcmd(self, "alias help-match impulse 129\n");
		stuffcmd(self, "alias lock impulse 130\n");
		stuffcmd(self, "alias +teamscores \"+showscores;impulse 131\"\n");
		stuffcmd(self, "alias -teamscores \"-showscores;impulse 132\"\n");
		stuffcmd(self, "alias rockets impulse 133\n");
		stuffcmd(self, "alias timer impulse 134\n");
		stuffcmd(self, "alias login impulse 135\n");
		stuffcmd(self, "alias observer impulse 140\n");
		stuffcmd(self, "alias walk impulse 141\n");
		stuffcmd(self, "alias flyme impulse 142\n");
		stuffcmd(self, "alias chase impulse 143\n");
		stuffcmd(self, "alias chasecam impulse 143\n");
		stuffcmd(self, "alias help-walk impulse 144\n");
		stuffcmd(self, "alias help-fly impulse 145\n");
		stuffcmd(self, "alias help-chase impulse 146\n");
		stuffcmd(self, "alias commentary impulse 147\n");
		stuffcmd(self, "alias headsup impulse 148\n");
		stuffcmd(self, "alias eyecam impulse 149\n");
		stuffcmd(self, "alias tourney impulse 151\n");      // CRMOD - enables tournament mode chasecam
		stuffcmd(self, "alias camera impulse 153\n");       // CRMOD - sets camera mode
		stuffcmd(self, "alias autocam impulse 154\n");      // CRMOD - autocam
		stuffcmd(self, "alias autocamera impulse 154\n");   // CRMOD - autocam
		stuffcmd(self, "alias quaketv impulse 154\n");      // CRMOD - autocam
		stuffcmd(self, "alias autochase impulse 155\n");
		stuffcmd(self, "alias help-camera impulse 156\n");
		stuffcmd(self, "alias killstats impulse 170\n");
		stuffcmd(self, "alias efficiency impulse 171\n");
		stuffcmd(self, "alias eff impulse 171\n");                  // CRMOD - so people don't have to spell out efficiency
		stuffcmd(self, "alias stats impulse 172\n");
		stuffcmd(self, "alias quadstats impulse 173\n");
		stuffcmd(self, "alias badstats impulse 174\n");
		stuffcmd(self, "alias teamstats impulse 175\n");
		stuffcmd(self, "alias autostats impulse 178\n");
		stuffcmd(self, "alias help-stats impulse 179\n");
		stuffcmd(self, "alias sm1 \"echo Smoothing ON ; cl_nolerp 1 ; alias smooth sm0\"\n");
		stuffcmd(self, "alias sm0 \"echo Smoothing OFF ; cl_nolerp 0 ; alias smooth sm1\"\n");
		stuffcmd(self, "alias smooth sm1\n");
		stuffcmd(self, "alias init echo\n");                            // CRMOD - So clients only see 'init' once
		stuffcmd(self, "alias qwsucks \"impulse 182;w5;15\"\n");
		stuffcmd(self, "alias q14ever \"impulse 182;w5;14\"\n");
		stuffcmd(self, "alias ratings impulse 183\n");
	}

    self = temp;
	self.nextthink = time + 0.5;
	self.think = votables_send_aliases;
};

//
//  P R E  S E T  A L I A S E S
//
void () elohim_pre_set_aliases = 
{
	sprint(self.owner, "Checking bindings..\n");
	sprint(self.owner, "\bUse \b-zone 512 \bif quake crashes\n");

    self.think = elohim_set_aliases;
    self.nextthink = time + 2.5;
};

//
//  S E N D  I G N O R E  T H I S
//
void () elohim_send_ignore_this = 
{
	// test for binds 
	sprint(self.owner, "stuffing ignorethis\n");
    stuffcmd(self.owner, "ignorethis;wait;wait\n");

	// also test for ghost during autopause
	local entity ghostent;
	local float temp;
	temp = 0;
	if (elohim_state & ELOHIM_MATCH_PAUSED)
	{
		ghostent = find(world, classname, "elohim_ghost");
		while (ghostent)
		{
			if (ghostent.owner.owner != ghostent)
				temp = 1;
			ghostent = find(ghostent, classname, "elohim_ghost");
		}
	}
	if (temp)
		stuffcmd(self.owner, "ghost\n");

    self.think = elohim_pre_set_aliases;
    self.nextthink = time + 0.5;
};

//
//  I N I T  T H I N K
//
//  Called 0.5 seconds after a client connects.  Plays the wizard sound
//  and checks for an illegal name.
//
void () elohim_init_think =
{
    local entity temp;
    temp = self;
    self = self.owner;
    if (!(elohim_state & ELOHIM_MATCH_STARTED))
		sound(world, CHAN_AUTO, "wizard/wsight.wav", 1, ATTN_NONE);
	if (utils_illegal_name(self.netname))
		stuffcmd(self, "name player\n");
	
	name_send_names();

    self = temp;
	remove(self);
};

//
//  S H O W  M O D E
//
//  Show mode and help info to a player after they connect.
//
void () elohim_show_mode =
{
    sprint(self.owner, elohim_version, "\n");
    if (elohim_playmode & ELOHIM_MATCH_MODE)
	{
		if (teamplay)
			sprint(self.owner, "match mode - help-match for help\n");
		else
			sprint(self.owner, "individual mode - help-match for help\n");
	}
    else if (elohim_playmode & ELOHIM_PRACTICE_MODE)
		sprint(self.owner, "practice mode\n");
    else
		sprint(self.owner, "FFA mode\n");
    remove(self);
};

//
//  S E N D  D E T E C T
//
//  Figure out if they're using DOSQuake, WINQuake or GLQuake.  Also send
//  a little gift for screenshots.
//
void () elohim_send_detect = 
{
    local entity temp;
    temp = self;
    self = self.owner;

	self.style = self.style | ELOHIM_WINQUAKE | ELOHIM_GLQUAKE;
	// prevent screen shots in demo by aliasing coop to screenshot
	stuffcmd(self, "alias coop screenshot\n");

	/* Had to get rid of vid_fullscreen because it messes with resolution
	stuffcmd(self, "alias detect impulse 61\n");
	stuffcmd(self, "alias vid_fullscreen alias detect impulse 62\n");
	stuffcmd(self, "alias gl_texturemode alias vid_fullscreen alias detect impulse 60\n");
	stuffcmd(self, "gl_texturemode\n");
	stuffcmd(self, "vid_fullscreen\n");
	stuffcmd(self, "detect\n");
	*/
	stuffcmd(self, "alias detect impulse 62\n");
	stuffcmd(self, "alias gl_texturemode alias detect impulse 60\n");
	stuffcmd(self, "gl_texturemode\n");
	stuffcmd(self, "detect\n");

	self = temp;
    remove(self);
};

//
//  P U T  P L A Y E R  I N  L I S T
//
void () elohim_put_player_in_list = 
{
	self.next_player = elohim_sentinel.next_player;
	elohim_sentinel.next_player = self;
};

//
//  R E M O V E  P L A Y E R  F R O M  L I S T
//
void () elohim_remove_player_from_list = 
{
	local entity plast;

	plast = elohim_sentinel;
	while (plast != world && plast.next_player != self)
		plast = plast.next_player;
	if (plast)
		plast.next_player = self.next_player;
};

//
//  C L I E N T  C O N N E C T
//
//  Called from ClientConnect in Client.qc when a client enters the
//  server.  This occurs when the client first connects over the network
//  and every time a new level is started.
//
void () elohim_client_connect =
{
	// get the cl and qs data structures
	self.cl = *SubInt(AddInt(PSTRING_TO_PQUAKEC, &self.netname), 4 * CL_NAME);
	self.qs = *AddInt(self.cl[CL_NETCONNECTION], PC_TO_PQUAKEC);

    if (parm10 & ELOHIM_NEW_CLIENT)
    {
		// This is a new client (just connected over the network)
		if (!net_connect())
			return;

		// Show the MOTD
		motd_create();
		utils_make_scheduled_event(elohim_init_think, 0.5);
		if (elohim_playmode & CRMOD_QSMACK_ON)
			utils_make_scheduled_event(qsmack_detect, 1.5);

		// Give the player a unique ID
		parm11 = 0; //parm11 will now carry our stat_id# (Sputnik)
/* Sputnik: this is *UNUSED*
		parm11 = elohim_player_ids;
		elohim_player_ids = elohim_player_ids + 1;
		if (elohim_player_ids > 65535)
		elohim_player_ids = 1;
*/

		// Get rid of the new client flag
		parm10 = parm10 - ELOHIM_NEW_CLIENT;

		// Set default observer flags
		parm12 = OBSERVER_TOURNEY | OBSERVER_WALK | OBSERVER_COMMENTARY;

		// reset the hack count
		parm13 = 0;

		stats_reset_player();
		proquake_client_connect();
		self.last_active = time;
    }

	// send aliases if necessary
	utils_make_scheduled_event(elohim_send_ignore_this, 1);
	utils_make_scheduled_event(elohim_send_detect, 0.8);

	// If it's match mode then they will become observers
	if (!(elohim_playmode & ELOHIM_MATCH_MODE))
		elohim_put_player_in_list();

    utils_make_scheduled_event(elohim_show_mode, 0.5);
    self.cnt = ELOHIM_MAX_SUICIDES;  // numer of suicides allowed
	self.crmod_hack_count = 0;  // count of admin code attempts
    self.owner = world;      // no ghost
    self.trigger_field = world; // last spawn point
    self.use = SUB_Null;
    self.style = 0;
	self.delayed_impulse = 0;
	self.crmod_cam_delay = 0;
	self.crmod_did_damage = time - 15;
	self.attack_finished = time - 10;
	self.finaldest_x = time; // So we don't get autokicked

	// new name stuff
	self.pname = *AddInt(&self.netname, PSTRING_TO_PQUAKEC);
	self.name15 = @AddInt(&self.netname, 4 * (CL_SPAWN_PARMS - CL_NAME));
	self.name15text = @AddInt(&self.name15, %16);
	self.name_ready = @AddInt(&self.name15, %32);
	name_fix();

	// This is to prevent a condition where one player is another player's
	// movetarget, which can confuse the auto module.
	self.movetarget = world;        
	
    parm10 = parm10 - (parm10 &
		(ELOHIM_READY | ELOHIM_KICK_CONFIRM | ELOHIM_MOTD |
		 ELOHIM_SETTING_OPTIONS | ELOHIM_SCOREBOARD |
		 CRMOD_DETECTING_QSMACK | ELOHIM_CONFIRM_LEAVE));
};

//
//  C L I E N T  D I S C O N N E C T
//
//  Called from ClientDisconnect in Client.qc when a client leaves.
//
void () elohim_client_disconnect =
{
    self.style = self.style - (self.style & ELOHIM_CONNECTED);
    self.finaldest_x = -30;     // Used to test for disconnected players
    self.crmod_chase_score = ELOHIM_NEGINF;  // CRMOD make sure they don't have some high rating that can't be beat by the other players

    // If we're in match mode, then inform match and score modules
	// Must inform score module first!  Score module checks to see if the
	// player is the first person on the team.
    if (elohim_playmode & ELOHIM_MATCH_MODE)
	{
		score_client_disconnect();
		match_disconnect_notify(self);
	}
	else
	{
		if (!(self.style & ELOHIM_OBSERVER))
			elohim_remove_player_from_list();
	}

	self.oflags = self.oflags - (self.oflags & OBSERVER_QUAKETV);	//Sputnik
    // Check to see if anyone was observing this client
	// Don't do this until the player has been removed from the list!
    observer_disconnect_notify(self);

    // Let the admin module know in case there's a kick in progress
    admin_disconnect_notify(self);

    // Check to see if we were debugging this client
    if (elohim_debug_client == self)
		elohim_debug_client = world;
	
    // CRMOD Qsmack Reset
    self.qsmack_level = 0;
    self.qsmack_trylevel = 0;
    qsmack_statusokay = 0;
    // CRMOD END
};

//
//  B F  T H I N K
//
//  Creates a background flash - used for player spawns.
//
void () elohim_bf_think =
{
    stuffcmd(self.owner, "bf\n");
    remove(self);
};

//
//  O B S E R V E R  S T A R T  T H I N K
//
//  This is a hack.. observer_start is being called a second time, 0.6
//  seconds after the first time, to cover a few details that don't make
//  it when the client first connects (such as the observer colour).
//
void () elohim_observer_start_think =
{
    local entity oself;

    oself = self;
    self = self.owner;
    observer_start();
    self = oself;
    remove(self);
};

//
//  P U T  C L I E N T  I N  S E R V E R
//
//  Called from PutClientInServer in Client.qc
//
void () elohim_put_client_in_server =
{
    utils_make_scheduled_event(elohim_bf_think, 0.1);

    if ((self.style & ELOHIM_OBSERVER) || (self.style & CRMOD_QSMACK) || (self.oflags & OBSERVER_QUAKETV) || ((elohim_playmode & ELOHIM_MATCH_MODE) && (!(self.style & ELOHIM_READY))))
    {
		observer_start();
		utils_make_scheduled_event(elohim_observer_start_think, 0.6);
    }
    else
    {
		player_stand1();
		spawn_tdeath (self.origin, self);
		makevectors(self.v_angle);
		spawn_tfog (self.origin + v_forward*20);

		if (elohim_state & ELOHIM_MATCH_PAUSED)
			self.nextthink = self.nextthink + 1000000 - (time - elohim_match_pause_time);

		// quaketag!
		if (crmod_qtag_it == self)
			self.effects = self.effects | EF_BRIGHTFIELD;	
    }

    // Prevent fire-on-respawn (in case player used attack button to respawn)
    self.style = self.style - (self.style & ELOHIM_OK_TO_SHOOT);
    self.style = self.style | ELOHIM_CONNECTED;
	self.height = self.team - 1; // to prevent colour change announcements
	self.colours = self.cl[CL_COLORS]; // ditto
    self.button0 = 1;
    self.wait = time + 2;    // for periodic checks
    self.finaldest_x = time; // used to check for disconnected clients
	self.lip = 0;            // grenade spam count
};

//
//  H E L P
//
//  Show general help commands.
//
void () elohim_help =
{
    sprint(self, elohim_version, "\n");
    sprint(self, "http://www.mpog.com/clanring/crmod\n");
    sprint(self, "\bBug reports to\b crbug@mpog.com\n");
    sprint(self, "Help commands (type in console):\n");
    sprint(self, " vinfo         - server version info\n");
    sprint(self, " help-misc     - misc commands\n");
    sprint(self, " help-observer - observer commands\n");
    sprint(self, " help-match    - match mode help\n");
	sprint(self, " help-stats    - statistics help\n");
    if (self.style & ELOHIM_ADMINISTRATOR)
		sprint(self, " help-admin    - admin commands\n");
	sprint(self, " commands - list commands/impulses\n");
};

//
//  H E L P  C H A N G E
//
//  Show help on how to change levels.
//
void () elohim_help_change =
{
    sprint(self, "\n");
	sprint(self, "\bTo change levels, enter the name of\n");
	sprint(self, "\bthe level in the console.\n");
};

//
//  H E L P  M I S C
//
//  Show misc commands.
//
void () elohim_help_misc =
{
	sprint(self, " vote-admin - nominate yourself\n");
    sprint(self, " admin    - enter admin code\n");
	sprint(self, " admins   - list server admins\n");
    sprint(self, " setquad  - enable/disable quad\n");
    sprint(self, " setpent  - enable/disable pent\n");
    sprint(self, " setring  - enable/disable ring\n");
    if (elohim_playmode & ELOHIM_MODE_VOTE)
    {
		sprint(self, " normal   - request FFA play\n");
		sprint(self, " practice - request practice mode\n");
		sprint(self, " match    - request match mode\n");
		sprint(self, " individual - request individual mode\n");
    }
    sprint(self, " nogibs   - disable gibs\n");
    sprint(self, " lowgibs  - set gibs to 'low'\n");
    sprint(self, " highgibs - set gibs to 'high'\n");
    sprint(self, " motd     - show message of the day\n");
    sprint(self, " commands - list commands/impulses\n");
    sprint(self, " observer - toggle observer mode\n");
    if (elohim_playmode & ELOHIM_LEVEL_VOTE)
	    sprint(self, " levels   - list all server levels\n");
    sprint(self, " rules    - view server rules\n");
	sprint(self, " ticrate  - view sys_ticrate\n");
	sprint(self, " pq       - toggle proquake settings\n");
	sprint(self, " ratings  - show player ratings\n");
	sprint(self, " autopause    - toggle auto pausing\n");
	sprint(self, " autoweapon   - toggle smartweapon\n");
	sprint(self, " autoweaponon - enable smartweapon\n");
};

//
//  I N F O
//
void () elohim_info =
{
    sprint(self, "\n");
    sprint(self, "\bElohim\b - Literally, the shining ones.\n");
    sprint(self, "         Used in ancient texts to\n");
    sprint(self, "         refer to angels.\n\n");
};

//
//  C O M M A N D S
//
//  List all commands and impulses.
//
void () elohim_commands =
{
    // regular user commands
    sprint(self, " vinfo®®®®®®®®®®\1\1\7 help-server®®®\1\0\0\n");
    sprint(self, " help-misc®®®®®®\1\0\5 help-match®®®®\1\2\9\n");
    sprint(self, " help-observer®®\1\0\1 help-walk®®®®®\1\4\4\n");
    sprint(self, " help-fly®®®®®®®\1\4\5 help-chase®®®®\1\4\6\n");
    sprint(self, " help-camera®®®®\1\5\6 commands®®®®®®\1\0\6\n");
	sprint(self, " levels®®®®®®®®®\1\0\7 autoweapon®®®®\1\1\4\n");
    sprint(self, " autoweaponon®®®\1\1\1 motd®®®®®®®®®®\1\0\9\n");
    sprint(self, " observer®®®®®®®\1\4\0 walk®®®®®®®®®®\1\4\1\n");
    sprint(self, " flyme®®®®®®®®®®\1\4\2 chase®®®®®®®®®\1\4\3\n");
    sprint(self, " eyecam®®®®®®®®®\1\4\9 camera®®®®®®®®\1\5\3\n");
	sprint(self, " autochase®®®®®®\1\5\5 autocam®®®®®®®\1\5\4\n");
    sprint(self, " headsup®®®®®®®®\1\4\8 smooth®®®®®®®®N/A\n");
    sprint(self, " tourney®®®®®®®®\1\5\1 yes®®®®®®®®®®®\1\1\5\n");
    sprint(self, " no®®®®®®®®®®®®®\1\1\6 ready®®®®®®®®®\1\2\0\n");
    sprint(self, " notready®®®®®®®\1\2\1 ready?®®®®®®®®\1\2\3\n");
    sprint(self, " unlock®®®®®®®®®\1\2\2 lock®®®®®®®®®®\1\3\0\n");
    sprint(self, " timerstop®®®®®®\1\2\4 timerstart®®®®\1\2\5\n");
	sprint(self, " +teamscores®®®®N/A -teamscores®®®N/A\n");
    sprint(self, " timeset®®®®®®®®\2\1\5 otset®®®®®®®®®\2\1\6\n");
    sprint(self, " ghostcode®®®®®®N/A ghost®®®®®®®®®\1\2\7\n");
    sprint(self, " score®®®®®®®®®®\1\2\8 nogibs®®®®®®®®\2\2\5\n");
    sprint(self, " lowgibs®®®®®®®®\2\2\6 highgibs®®®®®®\2\2\7\n");
    sprint(self, " setquad®®®®®®®®\2\2\1 setpent®®®®®®®\2\2\2\n");
    sprint(self, " setring®®®®®®®®\2\2\3 normal®®®®®®®®\2\1\7\n");
    sprint(self, " practice®®®®®®®\2\1\8 match®®®®®®®®®\2\1\9\n");
	sprint(self, " individual®®®®®\2\2\0 ticrate®®®®®®®\1\1\8\n");
    sprint(self, " killstats®®®®®®\1\7\0 efficiency®®®®\1\7\1\n");
    sprint(self, " stats®®®®®®®®®®\1\7\2 quadstats®®®®®\1\7\3\n");
	sprint(self, " badstats®®®®®®®\1\7\4 autostats®®®®®\1\7\8\n"); 
	sprint(self, " help-stats®®®®®\1\7\9 commentary®®®®\1\4\7\n");
	sprint(self, " obits®®®®®®®®®®\2\1\1 rules®®®®®®®®®\1\0\3\n");
	sprint(self, " rockets®®®®®®®®\1\3\3 autopause®®®®®\2\1\0\n");
	sprint(self, " admins®®®®®®®®®\1\1\0 teamstats®®®®®\1\7\5\n");
	sprint(self, " timer®®®®®®®®®®\1\3\4 pq®®®®®®®®®®®®\1\1\2\n");
	sprint(self, " faststart®®®®®®\2\0\9 admin®®®®®®®®®\1\0\8\n");
	sprint(self, " vote-admin®®®®®\2\5\1 ratings®®®®®®®\1\8\3\n");

    // admin commands
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
		sprint(self, " help-admin®®®®®\2\0\0 options®®®®®®®\2\2\9\n");
		sprint(self, " safepractice®®®\2\2\4 crkick®®®®®®®®\2\1\3\n");
		sprint(self, " abortmatch®®®®®\2\1\4 ghostlist®®®®®\2\1\2\n");
		sprint(self, " modevote®®®®®®®\2\2\8 spot®®®®®®®®®®\2\5\0\n");
		sprint(self, " nextspawn®®®®®®\2\4\6 makespawn®®®®®\2\4\7\n");
		sprint(self, " nextcam®®®®®®®®\2\4\8 makecam®®®®®®®\2\4\9\n");
		sprint(self, " dmset®®®®®®®®®®\2\0\7 qsmack®®®®®®®®\3\7\n");
		sprint(self, " maxteams®®®®®®®\2\0\8 autoss®®®®®®®®\2\0\4\n");
		sprint(self, " crban®®®®®®®®®®\2\0\5 unban®®®®®®®®®\1\9\8\n");
		sprint(self, " ips®®®®®®®®®®®®\2\0\6 bans®®®®®®®®®®\1\9\7\n");
    }
    elohim_help_change();
};

//
//  L E V E L S
//
//  List all levels recognized by the server.
//
void () elohim_levels =
{
    local float index;
    local string name;

    elohim_help_change();
    sprint(self, "\n");

    // standard levels
    sprint(self, " start, start0, start1, end\n");
    sprint(self, " e1m1-e1m8 \b(episode 1)\n");
    sprint(self, " e2m1-e2m7 \b(episode 2)\n");
    sprint(self, " e3m1-e3m7 \b(episode 3)\n");
    sprint(self, " e4m1-e4m8 \b(episode 4)\n");
    sprint(self, " dm1-dm6   \b(deathmatch)\n");

    // user defined levels
	for (index = %0 ; index < %10 ; index = index + %1)
    {
		name = @array_user_map[index];
		if (name != "")
			sprint(self, " ", name, "\n");
    }
};

//
//  B A D  I M P U L S E
//
//  Seems like some people get stuck with the old clanring bindings.
//  Let them know that something ain't right.
//
void () elohim_bad_impulse =
{
    sprint(self, "You have entered an invalid impulse.\n");
    sprint(self, "Your bindings may be incorrect - try\n");
    sprint(self, "reconnecting to the server.\n");
};

//
//  V E R S I O N  I N F O
//
void () elohim_vinfo =
{
    sprint(self, "\n", elohim_version_info, "\n\n");
    sprint(self, "Adapted from the Elohim Server\n\n");
};

//
//  T I C R A T E
//
void () elohim_ticrate = 
{
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		local float ticrate;

		ticrate = cvar("sys_ticrate");
		sprint(self, "sys_ticrate = ");
		utils_print_floatn(ticrate, 3);
	}
	else
		sprint(self, "This is not a dedicated server\n");
};

//
//  S H O W  R U L E S
//
void () elohim_show_rules =
{
	local float temp;

	if (elohim_playmode & ELOHIM_MATCH_MODE) 
	{
		if (teamplay) 
			sprint(self, "Žmatch modeŽ\n");
		else
			sprint(self, "Žindividual modeŽ\n");
	}
	else if (elohim_playmode & ELOHIM_PRACTICE_MODE)
		sprint (self,"Žpractice modeŽ\n");
	else
		sprint (self,"Žnormal modeŽ\n");

	temp = cvar ("deathmatch");
	sprint(self,"deathmatch®®®");
	utils_print_float (temp);
	temp = cvar ("teamplay");
	sprint(self,"teamplay®®®®®");
	utils_print_float (temp);
	sprint(self,"timelimit®®®®");
	if (elohim_playmode & ELOHIM_MATCH_MODE) 
	{
		utils_print_float(elohim_timelimit);
		if (elohim_overtime > 0) 
		{
			sprint (self,"overtime®®®®®");
			utils_print_float (elohim_overtime);
		}
		else if (elohim_overtime == ADMIN_NORMAL_MODE)
			sprint (self,"overtime®®®®®disabled\n");
		else
			sprint (self,"overtime®®®®®sudden death\n");
	}
	else
	{
		temp = cvar ("timelimit");
		utils_print_float (temp);
		temp = cvar ("fraglimit");
		sprint(self,"fraglimit®®®®");
		utils_print_float (temp);
		temp = cvar ("noexit");
		sprint(self,"noexit®®®®®®®");
		utils_print_float (temp);
	}
	if (elohim_playmode & (ELOHIM_NO_QUAD | ELOHIM_NO_PENT | ELOHIM_NO_RING))
	{
		if (elohim_playmode & ELOHIM_NO_QUAD)
			sprint(self, "ŽQuad is ÏÆÆ");
		if (elohim_playmode & ELOHIM_NO_PENT)
			sprint(self, "ŽPent is ÏÆÆ");
		if (elohim_playmode & ELOHIM_NO_RING)
			sprint(self, "ŽRing is ÏÆÆ");
        sprint(self, "Ž\n");
	}
};

//
//  A D M I N S
//
//  List the server admins and the codes they used
//
void () elohim_admins = 
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
		sprint(self, "There are no administrators\n");
		return;
	}
	
	sprint(self, "\n      name       ü code \n");
	sprint(self, "\b-----------------+------\n");
	e = find(world, classname, "player");
	while (e)
	{
		if (e.style & ELOHIM_CONNECTED && e.style & ELOHIM_ADMINISTRATOR)
		{
			if (e.crmod_hack_count == 10)
				s = "V";
			else
				s = ftos(e.crmod_hack_count);
			sprint(self, " ", e.name15, " ü  ", s, "\n");
		}
		e = find(e, classname, "player");
	}
};

//
//  W I N G L  D E T E C T
//
void (float quakever) elohim_wingl_detect = 
{
	if (!(self.style & ELOHIM_WINQUAKE) || !(self.style & ELOHIM_GLQUAKE))
	{
		elohim_bad_impulse();
		return;
	}

	self.style = self.style - ELOHIM_WINQUAKE - ELOHIM_GLQUAKE;
	if (quakever == 1)
		self.style = self.style | ELOHIM_WINQUAKE;
	else if (quakever == 2)
		self.style = self.style | ELOHIM_GLQUAKE;
};

//
//  I M P U L S E
//
//  Called from PlayerPreThink or observer_pre_think
//
void () elohim_impulse =
{
    if (self == elohim_debug_client)
    {
		local string temp;
		temp = ftos(self.impulse);
		dprint("elohim impulse ", temp, "\n");
    }

	// CRMOD Qsmack
	if (self.style & CRMOD_DETECTING_QSMACK)
		qsmack_detecting();
	else if (self.impulse == 39)
		self.finaldest_x = time;  // explicit ping response
	else if (self.impulse < 100)
	{
		if ((self.impulse >= 40) && (self.impulse <= 59))
			debug_impulse();
		else if (self.impulse >= 60 && self.impulse <= 62)
			elohim_wingl_detect(self.impulse - 60);
		else
			qsmack_impulse();
	}
    // CRMOD END
   	else if (self.impulse == 135)//Sputnik
	{
		elohim_login_start();
	}

    else if (self.impulse >= 190)
		admin_impulse();
    else if (self.impulse >= 120 && self.impulse <= 139)
		match_impulse();
    else if (self.impulse >= 140 && self.impulse <= 159)
		observer_impulse();
	else if (self.impulse >= 170 && self.impulse <= 179)
		stats_impulse();
    else if (self.impulse == 100)
		elohim_help();
    else if (self.impulse == 101)
		observer_help();
    else if (self.impulse == 102)
		elohim_info();
	else if (self.impulse == 103)
		elohim_show_rules();
	else if (self.impulse == 104)
		console_testcmd();
    else if (self.impulse == 105)
		elohim_help_misc();
    else if (self.impulse == 106) // list commands and impulses
		elohim_commands();
    else if (self.impulse == 107) // list valid levels
		elohim_levels();
    else if (self.impulse == 108) // start entering the admin code
		admin_start_code();
    else if (self.impulse == 109) // show the MOTD
	{
		stuffcmd(self, "toggleconsole\n");
		motd_create();
	}
	else if (self.impulse == 110)
		elohim_admins();
	else if (self.impulse == 111)
		utils_set_flag(CRMOD_SMART_WEAPON, "Smart weapon switching");
	else if (self.impulse == 112)
		utils_toggle_flag(ELOHIM_PROQUAKE, "ProQuake settings");
	else if (self.impulse == 114)
		utils_toggle_flag(CRMOD_SMART_WEAPON, "Smart weapon switching");
    else if (self.impulse == 117) // show version info
		elohim_vinfo();
	else if (self.impulse == 118)
		elohim_ticrate();
    else if (self.impulse == 119)
		sprint(self, "Found old bindings\n");
	else if (self.impulse == 181)
		self.style = self.style | ELOHIM_FOUND_BINDINGS;
	else if (self.impulse == 182)
		self.use = quaketag_init;
	else if (self.impulse == 183)
		ShowRatings();
    else if (self.impulse >= 115 && self.impulse <= 116) // yes/no
    {
		if (self.style & ELOHIM_KICK_CONFIRM)
			admin_confirm_kick_response(116 - self.impulse);
		else if (self.style & ELOHIM_CONFIRM_LEAVE)
			observer_confirm_leave_response(116 - self.impulse);
		else
			vote_impulse();
    }
    else
		sprint(self, "type 'help-server' in console for help\n");

	if (self.impulse >= 100 && self.impulse != 119 && self.impulse != 180 && self.impulse != 181)
	{
		if (time > 20)
			self.last_active = time;
	}

    self.impulse = 0;
};

//
//  K I C K  P L A Y E R
//
void (entity client) elohim_kick_player =
{
    local string temp;
	local entity oself;

    temp = ftos(client.colormap);
    localcmd3("kick # ", temp, "\n");
	oself = self;
	self = client;
	ClientDisconnect();
	self = oself;
};

//
//  C L I E N T  S U I C I D E
//
//  Called from ClientKill in Client.qc.  Checks to see if the player
//  has exceeded their suicide limit and returns either ELOHIM_SUICIDE_OK
//  or ELOHIM_TOO_MANY_SUICIDES accordingly.
//
float () elohim_client_suicide =
{
    local string temp;

    // Always OK for admins
    if (self.style & ELOHIM_ADMINISTRATOR)
		return ELOHIM_SUICIDE_OK;

    self.cnt = self.cnt - 1;
    if (self.cnt < 0)
    {
		// too many suicides
		if (self.cnt >= -1) // only want to do this stuff once
		{
			announce2(self.netname, " kicked for suiciding");
			elohim_kick_player(self);
		}
		return ELOHIM_TOO_MANY_SUICIDES;
    }
    temp = ftos(floor(self.cnt));
    sprint(self, "you have ", temp, " suicides remaining\n");
    return ELOHIM_SUICIDE_OK;
};

//
//  C L I E N T  R E A D Y
//
//  Prevent "observer spamming": rapid observer/ready in normal/practice mode
//
float () elohim_client_ready = 
{
    local string temp;

    // Always OK for admins
    if (self.style & ELOHIM_ADMINISTRATOR)
		return ELOHIM_SUICIDE_OK;

    self.cnt = self.cnt - 1;
    if (self.cnt < 0)
    {
		// too many observer/ready's
		if (self.cnt >= -1) // only want to do this stuff once
		{
			announce2(self.netname, " kicked for observer spamming");
			elohim_kick_player(self);
		}
		return ELOHIM_TOO_MANY_SUICIDES;
    }
    return ELOHIM_SUICIDE_OK;
};


entity (entity e) observer_find_target;
entity (entity e) observer_find_camera;			

//
//  P E R I O D I C  C H E C K S
//
//  Do various checks every second.  Called from PlayerPreThink in
//  Client.qc.
//
void () elohim_periodic_checks =
{
	if (!(self.style & ELOHIM_CONNECTED))
		return;

	if (self.style & CRMOD_QSMACK)
		return;

	if (utils_illegal_name(self.netname))
	{
		// Let's be fairly draconian about this
		announce("Player kicked for illegal name");
		elohim_kick_player(self);
		return;
	}

	local float idle, minutes;
	idle = time - self.last_active;
	minutes = floor(idle / 60);

	if (elohim_set_afk)
	{
		if (idle < elohim_set_afk * 60)
		{
			if (self.oflags & ELOHIM_AFK)
			{
				self.oflags = self.oflags - ELOHIM_AFK;
				name_fix();
			}
		}
		else if (!(self.oflags & ELOHIM_AFK))
		{
			self.oflags = self.oflags | ELOHIM_AFK;
			name_fix();
		}
	}

	if (elohim_kick_afk && minutes > elohim_kick_afk - 5)
	{
		if ((self.style & ELOHIM_ADMINISTRATOR) == FALSE)
		{
			if (minutes >= elohim_kick_afk)
			{
				announce2(self.netname, " kicked for being afk\n");
				elohim_kick_player(self);
				return;
			}
			if (minutes > 10 || (elohim_kick_afk - minutes == 1 && elohim_kick_afk > 1))
			{
				if (idle - (minutes * 60) < 1)
				{
					local string sz, pl;
					sz = ftos(elohim_kick_afk - minutes);
					if (elohim_kick_afk - minutes == 1)
						pl = "";
					else
						pl = "s";

					//Sputnik added client-side sound.
					stuffcmd (self, "play ");
					stuffcmd (self, "demon/idle1");
					stuffcmd (self, "\n");

					sprint(self, "\{1}AFK: you will be kicked in ", sz, " minute", pl, "\nPress jump or fire to stay connected\n");
				}
			}
		}
	}

	// Get one more suicide/(ready/notready) every 5 seconds
	if (self.cnt < ELOHIM_MAX_SUICIDES)
		self.cnt = self.cnt + 0.2;

	// Get one more greanade each second in practice mode
	if (elohim_playmode & ELOHIM_PRACTICE_MODE)
	{
		if (self.lip > 0)
			self.lip = self.lip - 1;
	}

    if (self.style & ELOHIM_OBSERVER)
    {
		// find the closest teleport
		observer_find_teleport();

		// check for 'squished'
		observer_check_size();

		if (self.oflags & OBSERVER_QUAKETV) //Sputnik: reset between map loads.
		{
			if (!(self.movetarget))
			{		        
		        self.movetarget = observer_find_camera(world);// see if we can find a camera
				if (self.movetarget)
				{
					self.oflags = self.oflags | OBSERVER_GO_AUTO;
					observer_camera_start();
				}
				else
				{
					self.movetarget = observer_find_target(world);// see if we can find a player
					if (self.movetarget)
					{
						self.oflags = self.oflags | OBSERVER_GO_AUTO;
						observer_chase_start();
					}
				}
			}
		}
    }
	else if (!self.deadflag)
		auto_compute_score();

	// Check to see if name has changed
	if ((*self.pname[%0] != *self.pname[%4]) || (*self.pname[%1] != *self.pname[%5]) ||
		(*self.pname[%2] != *self.pname[%6]) || (*self.pname[%3] != *self.pname[%7]))
		name_fix();
};

//
//  R E S T O R E  M O V E T Y P E
//
void () elohim_restore_movetype = 
{
	if (self.movetype == MOVETYPE_NOCLIP)
	{
		sprint(self, "\{1}NOCLIP is not allowed!\n");
		sprint(self, "noclip OFF\n");
	}
	else if (self.movetype == MOVETYPE_FLY)
	{
		sprint(self, "\{1}FLY is not allowed!\n");
		sprint(self, "flymode OFF\n");
	}
	else
		sprint(self, "\{1}Unknown movetype\n");
	self.movetype = self.finaldest_y;
};

//
//  E N D  F R A M E
//
//  Used to set "developer" back to 0 at the end of each frame
//
void () elohim_end_frame = 
{
	if (sv[SV_NUM_EDICTS] == self[0])
	{
		sv[SV_NUM_EDICTS] = SubInt(sv[SV_NUM_EDICTS], %1);
		cvar_set("developer", "0");
	}
	else
	{
		remove(self);

		local entity e;

		e = *(sv[SV_NUM_EDICTS] * PR_EDICT_SIZE);
		sv[SV_NUM_EDICTS] = AddInt(sv[SV_NUM_EDICTS], %1);
		e[0] = sv[SV_NUM_EDICTS];
		e.nextthink = 0.00001;
		e.think = elohim_end_frame;
	}
	utils_do_item(quaketag_penis_think, "penis");
};

//
//  S T A R T  F R A M E
//
//  Called from StartFrame in World.qc.  This routine performs periodic
//  checks in match mode and checks for server console commands.
//
void () elohim_start_frame =
{
    local float command;
	local entity e;

	cvar_set("developer", "1");
	e = *(sv[SV_NUM_EDICTS] * PR_EDICT_SIZE);
	sv[SV_NUM_EDICTS] = AddInt(sv[SV_NUM_EDICTS], %1);
	e[0] = sv[SV_NUM_EDICTS];
	e.nextthink = 0.00001;
	e.think = elohim_end_frame;

	if (!gameover)
	{    
		if (!(elohim_playmode & ELOHIM_MATCH_MODE))
		{
			if (timelimit)
			{
				if (time >= timelimit)
				{
					if (elohim_levelcount == -1)
						NextLevel ();
				}
			}
		}
		else if (crmod_qtag_it)
			quaketag_start_frame();

		// Do some maintenance
		if (time >= elohim_nextcheck)
		{
			local entity player;
			local float empty;

			// update variables
			timelimit = cvar("timelimit") * 60;
			fraglimit = cvar("fraglimit");
			teamplay = cvar("teamplay");

			empty = TRUE;
			player = find(world, classname, "player");
			while (player)
			{
				if (player.style & ELOHIM_CONNECTED)
				{
					empty = FALSE;
					if (time > player.finaldest_x + 5)
					{
						// send out ping to test for disconnected players
						msg_entity = player;
						WriteByte(MSG_ONE, SVC_STUFFCMD);
						WriteString(MSG_ONE, "impulse 39\n");
					}
					if (time > player.finaldest_x + 25)
					{
						// Automatically kick player
						announce2("No response from ", player.netname);
						elohim_kick_player(player);
					}
				}
				else
				{
					// remove clutter
					player.model = string_null;
					player.solid = SOLID_NOT;
				}

				player = find(player, classname, "player");
			}

			if (empty && (time > (6 * 3600)))
				changelevel(mapname);

			if (elohim_levelcount > 0)
			{
				// Check for end of file in levels.cfg.  We assume end of file
				// if it's been 5 seconds since the last update to levelcount.
				// When end of file is detected, levelcount is set to -1 to
				// indicate that levels.cfg is finished.
				if (elohim_levelcount == elohim_lastcount)
				{
					dprint("levels.cfg: finished\n");
					if (nextmap == "")
						nextmap = elohim_firstlevel;						
					if (nextmap == "")
						dprint("no nextmap found\n");
					else
						dprint("nextmap = ", nextmap, "\n");

					elohim_levelcount = -1;
					if (!(elohim_playmode & ELOHIM_MATCH_MODE) && (cvar("noexit") != 1))
						bprint("Exits activated\n");

					if (elohim_load_bans)
					{
						elohim_load_bans = 0;
						localcmd("exec ban.cfg\n");
					}
				}
				elohim_lastcount = elohim_levelcount;
				elohim_nextcheck = time + 0.5;
			}
			else
				elohim_nextcheck = time + 5;
		}

		if (time >= elohim_nextcheck2)
		{
			auto_schedule_cameras();
			utils_make_scheduled_event(auto_chase, 0.3);
			utils_make_scheduled_event(auto_camera, 0.6);
			if (!(elohim_state & ELOHIM_TIMER_STARTED))
				display_update_all();
			elohim_nextcheck2 = floor(time) + 1;
		}

		auto_check_current_camera();
	}

    // Check for a console command
    command = cvar("temp1");
    cvar_set("temp1", "0");
    if (command)
		console_command(command);
};
