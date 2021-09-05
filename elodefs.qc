//
// Elodefs.qc
//
// Constants and global variables used in the Elohim mod.
//
// All code by J.P. Grossman unless otherwise commented.
//
// See Elohim.qc for a list of standard fields used.
//

// constants
float ELOHIM_SUICIDE_OK = 0;
float ELOHIM_TOO_MANY_SUICIDES = 1;
float ELOHIM_NEGINF = -9999999;

// client styles
float ELOHIM_NEW_CLIENT = 1;           // set when a client first connects
float ELOHIM_ADMINISTRATOR = 2;        // set if the client is an admin
float CRMOD_DETECTING_QSMACK = 4;    // set when detecting if client is a qsmack bot
float ELOHIM_POP_FORWARD = 8;       // used to walk through doors
float ELOHIM_READY = 16;             // ready to play in match
float ELOHIM_YES = 32;               // used for voting
float ELOHIM_HEADS_UP = 64;          // enable heads up display
float ELOHIM_SETTING_OPTIONS = 128;  // set when setting options
float ELOHIM_MOTD = 256;             // showing MOTD
float ELOHIM_OK_TO_SHOOT = 512;      // don't fire after options/respawn
float ELOHIM_KICK_CONFIRM = 1024;    // used to confirm a kick
float ELOHIM_CONFIRM_LEAVE = 2048;   // confirmation for leaving match
float ELOHIM_CONNECTED = 4096;       // client has been put in server
float ELOHIM_FOUND_BINDINGS = 8192; // used to check for bindings
float CRMOD_SMART_WEAPON = 16384;    // whether or not to use `smart' weapon switching
float ELOHIM_OBSERVER = 32768;		 // set if the client is an observer
float CRMOD_QSMACK = 65536;			// set for qsmack bots
float ELOHIM_SCOREBOARD = 131072;	// player is looking at teamscores
float ELOHIM_NO_POST_THINK = 262144;// don't do post think (optimization)
float ELOHIM_WINQUAKE = 524288;     // player is using winquake
float ELOHIM_GLQUAKE = 1048576;     // player is using glquake
float ELOHIM_AUTOSTATS = 2097152;   // autostats enabled
float ELOHIM_SHOW_TIMER = 4194304;	// on screen timer
float ELOHIM_PROQUAKE = 8388608;	// client is using proquake

// observer flags  (/me kills jp)
float OBSERVER_WALK = 1;			// set in walk mode
float OBSERVER_FLY = 2;				// set in fly mode
float OBSERVER_CHASE = 4;			// set in chase mode
float OBSERVER_DEMO = 8;			// see through chasetargets eyes
float OBSERVER_CAMERA = 16;			// set to camera mode
float OBSERVER_AUTO = 32;			// view autoswitching
float OBSERVER_TOURNEY = 64;		// set tournement mode for chasecam
float OBSERVER_GO_AUTO = 128;		// player entering an auto mode
float OBSERVER_COMMENTARY = 256;	// see running commentary
float ELOHIM_SENT_BINDINGS = 512;	// ran out of room in flags
float ELOHIM_AFK = 1024;			// ran out of room in flags
float OBSERVER_QUAKETV = 2048;		// Sputnik: added this for streaming via quaketv

// CRMOD qsmack variables
.float qsmack_level;
.float qsmack_trylevel;
float qsmack_statusokay;				// True if qsmack bot just did a status

// server mode - stored in cvar 'samelevel' and preserved across levels
float ELOHIM_SAME_LEVEL = 1;
float ELOHIM_MATCH_MODE = 2;
float ELOHIM_PRACTICE_MODE = 4;
float ELOHIM_SERVER_INITIALIZED = 8;
float ELOHIM_NO_GIBS = 16;
float ELOHIM_LOW_GIBS = 32;
float ELOHIM_NO_QUAD = 64;
float ELOHIM_NO_PENT = 128;
float ELOHIM_NO_RING = 256;
float ELOHIM_MODE_VOTE = 512;
float ELOHIM_DEDICATED_SERVER = 1024; 
float ELOHIM_NO_SPOOGE = 2048;			// disable spooging in practice mode
float CRMOD_QSMACK_ON = 4096;			// CRMOD is server using Qsmack?
float ELOHIM_EXTENDED_OBITS = 8192;
float ELOHIM_CONSOLE_INITIALIZED = 16384;
float ELOHIM_FAST_START = 32768;
float ELOHIM_FRESH_SPAWNS = 65536;
float ELOHIM_AUTO_PAUSE = 131072;
//float ELOHIM_AUTOSTATS = 2097152;   // autostats enabled (used for client AND console)
float ELOHIM_NO_VOTE_ADMIN = 4194304;
float ELOHIM_LEVEL_VOTE = 8388608;

// server state - not preserved across level changes
float ELOHIM_TIMER_STARTED = 1;
float ELOHIM_MATCH_STARTED = 2;
float ELOHIM_MATCH_PAUSED = 4;
float ELOHIM_MATCH_OVER = 8;
float ELOHIM_MATCH_WAIT = 16;   // 5 second delay after match ends
//float ELOHIM_KICKING = 32;      - removed - this slot is available
float ELOHIM_IGNORE_CONSOLE = 64;
// muddle counts :)
float ELOHIM_SETQUAD_COUNT = 128;
float ELOHIM_SETPENT_COUNT = 1024;
float ELOHIM_SETRING_COUNT = 8192;
// end muddle (eats bits up to 65536)
float ELOHIM_NO_PRACTICE = 131072;
float ELOHIM_ELOSTART = 262144;
float ELOHIM_UNPAUSING = 524288;
float ELOHIM_AUTO_PAUSED = 1048576;
float ELOHIM_DELAYED_AUTOSS = 2097152;
float ELOHIM_TAKING_AUTOSS = 4194304;

// admin constants
float ADMIN_NORMAL_MODE = 0;
float ADMIN_PRACTICE_MODE = 1;
float ADMIN_MATCH_MODE = 2;
float ADMIN_INDIVIDUAL_MODE = 3;

float KICK_NONE = 0;
float KICK_KICK = 1;
float KICK_BAN = 2;

// entity constants
float ELOHIM_MANUAL_SPAWN = 1;

// elohim global variables
float elohim_player_ids;    // used for assigning unique player ID's
float elohim_devparam;      // used for development
float elohim_playmode;      // current play mode (non volatile flags)
float elohim_state;         // server state (volatile flags)
float elohim_timelimit;     // timelimit for matches (default 20 minutes)
float elohim_overtime;      // length of auto-overtime; 0 if none
float elohim_nextcheck;     // used for periodic checks
float elohim_nextcheck2;	// used for frequent periodic checks
entity elohim_request;      // used to control voting
float elohim_level;         // number of current level in user level order
float elohim_levelcount;    // used to scan through list in levels.cfg
float elohim_lastcount;     // used to detect end-of-file in levels.cfg
string elohim_firstlevel;	// used to remember the name of the first level in levels.cfg
float elohim_num_spawns;    // number of deathmatch spawn points
float elohim_num_starts;    // number of match extra start points
float elohim_num_cameras;   // number of cameras
string elohim_version;      // used for motd and help-server
string elohim_version_info; // text info including rev. and compile time
string crmod_version_number; // text info storing version number (ie "4.0")
entity elohim_debug_client; // used for debugging
float elohim_arena_health;  // used for rocket arena practice mode
entity elohim_quad;			// pointer to quad for quick reference
entity elohim_pent;			// pointer to pent for quick reference
float elohim_kick_mode;		// KICK_NONE, KICK_KICK, or KICK_BAN
string elohim_kick_string;	// "kick" or "ban"
float elohim_ban_mask;		// used for crban
float elohim_load_bans;		// indicates that ban.cfg should be loaded after levels.cfg
float elohim_set_afk;		// time in minutes before a player is marked as "afk"
float elohim_kick_afk;		// time in minutes before a player is kicked for being "afk"

// match global variables
float elohim_match_pause_time;  // records time that match was paused
float elohim_maxteams;			// maximum number of teams
float elohim_numteams;			// number of teams
float elohim_maxsize;           // maximum allowed team size
entity elohim_match_timer;      // used to time match
entity elohim_sentinel;			// head of linked lists
string elohim_szthe;			// hack - = "The " for teamplay, "" for individual
string elohim_szteam;			// hack - = "team" for teamplay, "player" for individual

// score global variables
string elohim_winning_teamname;	// name of winning team (as returned by strings_get_teamname)
float elohim_score_number;		// either difference in score or tied score
string ELOHIM_STRING_TIED;		// initialized to "   Tied at "
float elohim_score_count;		// number of clients looking at score
entity elohim_first_place;
entity elohim_second_place;

// console global variables
float console_deathmatch;
float console_timelimit;
float console_fraglimit;
float console_pausable;
float console_noexit;

// auto parameters
float auto_parm1;	// 
float auto_parm2;	// 
float auto_parm3;	// 
float auto_parm4;	// 

// other global variables
string nextmap;  // moved here from Client.qc
float timelimit; // this used to be local in CheckRules in Client.qc        
float fraglimit; // this used to be local in CheckRules in Client.qc        
float intermission_running;  // moved here from Client.qc
float intermission_exittime; // moved here from Client.qc

entity crmod_best_chase_target; // calculated every second who is the best target to chase // CRMOD - auto
entity crmod_current_chase_target;
float crmod_chase_delay;
entity crmod_best_camera;       // set after each camera's think
entity crmod_current_camera;
float crmod_camera_delay;

vector crmod_angle;	// used for both autoss and intermission

float elohim_pass_max; // used to see if there is a password set

// client variables
.vector crmod_qdwep;  // vector to keep track of quad weapon stats	// CRMOD - stats
.vector crmod_qdkill; // vector to keep track of quad kill stats	// CRMOD - stats
.vector crmod_badstats; // keep track of RL paks and damage done to team
.entity crmod_othertarget; // entity to focus on in tourneycam		// CRMOD - tourneycam
.entity crmod_inflicted;   // stores entity last attacked			// CRMOD - combat
.float crmod_chase_score;  // same as above, also used by cameras
.float crmod_did_damage;   // last time person did damage
.float oflags;				// CRMOD observer flags
.float crmod_cam_delay;    // keep autocam from overswitching
.vector crmod_oldangle;    // set by angles_fixangle
.float delayed_impulse;		// saves self.impulse so it doesn't get nuked by a ping
.float timeslot;			// records which scoreboard slot is used for time
.entity next_player;		// used to point to first/next player in team
.entity next_team;			// used to point to next team
.entity next_camera;		// used to point to next camera
.vector crmod_old_velocity; // used for pausing/unpausing
.float crmod_hack_count;	// used to count admin hacking attempts / store admin level
.entity cl;					// pointer to client_t structure
.entity qs;					// pointer to quakesocket_t structure
.entity pname;				// quakeC pointer to netname for fast name-change checks
.string name15;				// name, 15 chars long
.string name15text;			// ascii name, 15 chars long
.string name_ready;			// name with READY at the end
.float colours;				// shirt and pants colours!
.float last_active;			// used for detecting afk players

float CRMOD_ANGLE_SMOOTHING = 0.6; // CRMOD use this instead of typing the number a billion times

//-Sputnik: added new variables------------------------------------------------------------------------------------------
.float elohim_player_id;    // used for assigning unique player ID's (Sputnik: changed to .float from float)
.float id_hack_count;		// used to count how many attempts to login
.float dmg_taken;			// damage taken from opponents for stats
.float dmg_given;			// damage given to opponents for stats
float EF_BLUE = 64;			// Colored dynamic light for Quad
float EF_RED = 128;			// Colored dynamic light for Pent
void (entity client) clear_afk_status;