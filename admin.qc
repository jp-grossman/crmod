//
// Admin.qc
//
// Administrative functions for the Elohim server mod.
//
// Fields used:
//
// .count           - used for entering password
//
// All code by J.P. Grossman unless otherwise commented.
//

// function declarations
void () admin_cancel_kick;
void () admin_confirm_kick;
void () admin_confirm_ban_response;
void (float fDoKick) admin_confirm_kick_response;
void () admin_do_kick;
void () options_start_setting;
float () options_get_mode;
void () SUB_Freeze;
void () W_SetCurrentAmmo;

// global variables
entity kick_target;         // Player to kick

//
//  S E N D  A L I A S E S
//
//  Stuffs admin-only aliases into the administrators console.  Called
//  when a player becomes an administrator.
//
void () admin_send_aliases =
{
	stuffcmd(self, "alias qsmack impulse 37\n");
	stuffcmd(self, "alias bans impulse 197\n");
	stuffcmd(self, "alias unban impulse 198\n");
    stuffcmd(self, "alias help-admin impulse 200\n");
	stuffcmd(self, "alias autoss impulse 204\n");
	stuffcmd(self, "alias crban impulse 205\n");
	stuffcmd(self, "alias ips impulse 206\n");
	stuffcmd(self, "alias dmset impulse 207\n");
	stuffcmd(self, "alias maxteams impulse 208\n");
    stuffcmd(self, "alias ghostlist impulse 212\n");
    stuffcmd(self, "alias kick! impulse 213\n");
    stuffcmd(self, "alias skick impulse 213\n");
    stuffcmd(self, "alias crkick impulse 213\n");
    stuffcmd(self, "alias abortmatch impulse 214\n");
    stuffcmd(self, "alias safepractice impulse 224\n");
    stuffcmd(self, "alias modevote impulse 228\n");
    stuffcmd(self, "alias options impulse 229\n");

    // spawn point editing
    stuffcmd(self, "alias nextspawn impulse 246\n");
    stuffcmd(self, "alias makespawn impulse 247\n");
    stuffcmd(self, "alias nextcam impulse 248\n");
    stuffcmd(self, "alias makecam impulse 249\n");
    stuffcmd(self, "alias spot impulse 250\n");

	// TRAINING
	training_send_aliases();
};

//
//  C R E A T E
//
//  Turn 'self' into an administrator.
//
void () admin_create =
{
	local string s;
	if (self.crmod_hack_count == 10)
		s = "V";
	else
		s = ftos(self.crmod_hack_count);
    self.style = self.style | ELOHIM_ADMINISTRATOR;
//	if (!self.crmod_hack_count && ((self.style & ELOHIM_OBSERVER) || (elohim_playmode & ELOHIM_PRACTICE_MODE)))
//		self.cl[CL_PRIVILEGED] = TRUE;
    self.use = SUB_Null;
    centerprint(self, "You are now an administrator");
    announce4(self.netname, " has become an administrator (code ", s, ")");
    admin_send_aliases();
};

//
//  E N T E R  C O D E
//
//  Enter another code digit.
//  The digit being entered is stored in self.finaldest_z.
//  The digits that are entered are accumulated by self.count;
//  when self.count == elohim_password the client is made into an
//  administrator.
//
void () admin_enter_code = 
{
	local float temp;

    if (self.finaldest_z > 9)
		return;

	self.count = self.count * 10 + self.finaldest_z;
	if (self.count >= 1000)
	{
		for (temp = %0 ; temp < %10 ; temp = temp + %1)
		{
			if (self.count == array_password[temp])
			{
				self.crmod_hack_count = temp / %1;
				admin_create();
				return;
			}
		}
	}
	if (self.count >= 1000000)
	{
        sprint(self, "Invalid code\n");
        self.use = SUB_Null;
		self.crmod_hack_count = self.crmod_hack_count + 1;
		if (self.crmod_hack_count > 3)
		{
			announce2(self.netname, " kicked for admin hacking");
			elohim_kick_player(self);
		}
	}
	else
		sprint(self, "Enter the next code digit:\n");
};

//
//  S T A R T  C O D E
//
//  Initiate the admin code sequence.
//
void () admin_start_code =
{
    if (elohim_pass_max < 1000)
	{
    	sprint(self, "Administrator password disabled\n");
	    sprint(self, "Type 'exec crmod.cfg' in server\n");
    	sprint(self, "console to set password.\n");
	    return;
	}

    if (self.style & ELOHIM_ADMINISTRATOR)
    {
		sprint(self, "Your resignation has been accepted\n");
		self.style = self.style - ELOHIM_ADMINISTRATOR;
		self.cl[CL_PRIVILEGED] = FALSE;
		self.crmod_hack_count = 0;
    }
    sprint(self, "Enter the first code digit:\n");
    self.count = 0;
    self.use = admin_enter_code;
};

//
//  P R I N T  K I C K  C H O I C E
//
//  Display a choice of players to kick.
//
void () admin_print_kick_choice =
{
    local entity client;
    local float index;
    local string num;

    // Print the choice
    sprint(self, "Which player do you want to ", elohim_kick_string, "?\n");
    sprint(self, " 0  cancel\n");
	for (index = 1 ; index < 16 ; index = index + 1)
    {
        client = *array_kick[index * %1];
        if (client)
        {
            num = ftos(index);
            sprint(self, " ", num, " ", client.netname, "\n");
        }
    }
};

//
//  S T A R T  K I C K
//
//  Get a list of players and ask the admin which one to kick.
//
void (float kick_mode) admin_start_kick =
{
    if (elohim_kick_mode)
    {
        sprint(self, "There is already a kick in progress\n");
        return;
    }
	elohim_kick_string = "kick":"ban"[(kick_mode - 1) * %5];

    // Get the list of players
    local entity client;
    local float index;
    index = %1;
    client = find(world, classname, "player");
    while (client)
    {
   		if (client.style & ELOHIM_CONNECTED)
		{
			if (!(client.style & ELOHIM_ADMINISTRATOR) || (client.crmod_hack_count && !self.crmod_hack_count) || 
				((client.crmod_hack_count == 10) && (self.crmod_hack_count < 10)))
			{
				array_kick[index] = &client;
				index = index + %1;
			}
		}
        client = find(client, classname, "player");
    }
    if (index == %1)
    {
        sprint(self, "There is no-one to ", elohim_kick_string, "\n");
        return;
    }
	for ( ; index < %16 ; index = index + %1)
		array_kick[index] = %0;

    // Print the choice
    admin_print_kick_choice();

    // Set up the kick
    local entity kick_timeout;
    self.use = admin_confirm_kick;
    kick_timeout = spawn();
    kick_timeout.movetarget = self;
    kick_timeout.classname = "elohim_kick_timeout";
    kick_timeout.think = admin_cancel_kick;
    kick_timeout.nextthink = time + 10;
	elohim_kick_mode = kick_mode;
};

//
//  C O N F I R M  K I C K
//
//  Ask for confirmation to kick the selected player.  The index of
//  the player to be kicked is stored in self.finaldest_z.
//
void () admin_confirm_kick =
{
    self.use = SUB_Null;

    if (self.finaldest_z == 0)
    {
        // Cancel the kick
        local entity oself;
        oself = self;
        self = find(world, classname, "elohim_kick_timeout");
        admin_cancel_kick();
        self = oself;
        return;
    }

    kick_target = *array_kick[self.finaldest_z * %1];

    // sanity checks
    if (!kick_target)
    {
        sprint(self, "Invalid\n");
        admin_print_kick_choice();
        return;
    }
    if ((kick_target.style & ELOHIM_ADMINISTRATOR) && (!kick_target.crmod_hack_count || self.crmod_hack_count))
    {
        sprint(self, kick_target.netname, " is an administrator\n");
        admin_print_kick_choice();
        return;
    }

    // ask for confirmation
    sprint(self, elohim_kick_string, " ", kick_target.netname, "?\n");
	if (elohim_kick_mode == KICK_KICK)
		self.style = self.style | ELOHIM_KICK_CONFIRM;
	else
	{
		local float p;
		local string s;

		sprint(self, " 0 - No\n");
		sprint(self, " 1 - Yes: ban ", kick_target.netname, "\n");
		p = AddInt(AddInt(&kick_target.qs, QS_ADDRESS * 4), PQUAKEC_TO_PSTRING);
		sprint(self, " 2 - Yes: ban ", @p, "\n");
		p = GetLow(kick_target.qs[QS_IN_ADDR]) / %1;
		s = ftos(p & 255);
		sprint(self, " 3 - Yes: ban ", s, ".");
		s = ftos(floor(p / 256));
		sprint(self, s, ".xxx.xxx\n");
		self.use = admin_confirm_ban_response;
	}
};

//
//  C O N F I R M  B A N  R E S P O N S E
//
void () admin_confirm_ban_response = 
{
	self.use = SUB_Null;
	if (self.finaldest_z == 1)
		elohim_ban_mask = IP_MASK0;
	else if (self.finaldest_z == 2)
		elohim_ban_mask = IP_MASK1;
	else if (self.finaldest_z == 3)
		elohim_ban_mask = IP_MASK2;
	else
		self.finaldest_z = 0;
	admin_confirm_kick_response(self.finaldest_z);
};

//
//  C O N F I R M  K I C K  R E S P O N S E
//
//  Called when the administrator enters 'yes' or 'no' in
//  response to the confirmation request.
//  
void (float fDoKick) admin_confirm_kick_response =
{
    if (fDoKick)
        admin_do_kick();
    else
    {
        // Cancel the kick
        local entity oself;
        oself = self;
        self = find(world, classname, "elohim_kick_timeout");
        admin_cancel_kick();
        self = oself;
    }
};

//
//  D O  K I C K
//
//  Kick a player once the admin has confirmed.
//
void () admin_do_kick =
{
	local string temp;

	temp = ftos(self.crmod_hack_count);
	if (elohim_kick_mode == KICK_KICK)
	{
		bprint(kick_target.netname, " kicked by administrator\n");
		dprint(kick_target.name15text, " kicked by ", self.name15text, " (code ", temp, ")\n");
		elohim_kick_player(kick_target);
	}
	else
	{
		bprint(kick_target.netname, " banned by administrator\n");
		dprint(kick_target.name15text, " banned by ", self.name15text, " (code ", temp, ")\n");
		elohim_kick_player(kick_target);

		if (self.crmod_hack_count || !(elohim_playmode & ELOHIM_DEDICATED_SERVER))
			net_ban_temp(kick_target);
		else
			net_ban(kick_target);
	}

    // Clean up
    kick_target = find(world, classname, "elohim_kick_timeout");
    remove(kick_target);
	elohim_kick_mode = KICK_NONE;
    self.style = self.style - (self.style & ELOHIM_KICK_CONFIRM);
};

//
//  C A N C E L  K I C K
//
//  Called when the kick times out or is cancelled by the admin.
//
void () admin_cancel_kick =
{
    sprint(self.movetarget, elohim_kick_string, " cancelled\n");
	self.movetarget.use = SUB_Null;
    remove(self);
	elohim_kick_mode = KICK_NONE;
    self.movetarget.style = self.movetarget.style - (self.movetarget.style & ELOHIM_KICK_CONFIRM);
};

//
//  L I S T  G H O S T S
//
void () admin_list_ghosts =
{
    local entity e;
    e = find(world, classname, "elohim_ghost");
    if (!e)
    {
        sprint(self, "There are no ghosts\n");
        return;
    }
	if (teamplay)
		sprint(self, "     name      ücodeü   team   üfrags\n");
	else
		sprint(self, "     name      ücodeü  colour  üfrags\n");
	sprint(self, "­­­­­­­­­­­­­­­«­­­­«­­­­­­­­­­«­­­­­\n");
    while (e)
    {
        if (e.owner.owner != e)
		{
			local string num, szTeam, pad;
			local float frag;
			num = ftos(e.count);

	        sprint(self, e.name15, "ü ", num, " ü");
            frag = e.frags;
    
			szTeam = strings_get_teamname2(e.height);
			if (frag < -99)
				pad = "ü";
			else if (frag < -9)
				pad = "ü ";
			else if (frag < 0)
				pad = "ü  ";
			else if (frag < 10)
				pad = "ü   ";
			else if (frag < 100)
				pad = "ü  ";
			else
				pad = "ü ";
			num = ftos(frag);
			sprint(self, szTeam, pad, num, "\n");
		}
        e = find(e, classname, "elohim_ghost");
    }
};

//
//  S H O W  S P O T  I N F O
//
//  Display the current position and angle.
//
void () admin_show_spot_info =
{
    local string temp;

    temp = vtos(self.origin + '0 0 22');
    sprint(self, " origin: ", temp, "\n");
    temp = vtos(self.v_angle);
    sprint(self, " angle: ", temp, "\n");
};

//
//  N E X T  S P A W N  P O I N T
//
//  If the admin is in walk or fly observer mode, move him to the
//  next spawn point.
//
void () admin_next_spawn_point =
{
    if (!(self.style & ELOHIM_OBSERVER) ||
        !(self.oflags & (OBSERVER_WALK | OBSERVER_FLY)))
    {
        sprint(self, "You must be in walk or fly mode\n");
        return;
    }
    utils_do_item(match_add_spawn, "elohim_start_point");
    self.owner = find(self.owner, classname, "info_player_deathmatch");
    if (!self.owner)
    {
        self.owner = find(self.owner, classname, "info_player_deathmatch");
        if (!self.owner)
        {
            sprint(self, "No spawn points found\n");
            return;
        }
    }
    utils_do_item(match_remove_start, "info_player_deathmatch");

	// setorigin will not actually set the origin if a bad origin is given.
	// Therefore, we first set the origin manually to ensure that the spot info
	// is displayed correctly.
	//
    self.origin = self.owner.origin;
    admin_show_spot_info();
    setorigin(self, self.owner.origin + '0 0 1');
    self.angles = self.owner.angles;
	self.fixangle = TRUE;           // turn this way immediately
    self.velocity = '0 0 0';
    makevectors(self.v_angle);
    observer_spawn_tfog(self.origin + v_forward*20);
};

//
//  M A K E  S P A W N  P O I N T
//
//  If the admin is in walk observer mode, standing on the ground and
//  not underwater, then create a new deathmatch spawn point at his
//  location.
//
void () admin_make_spawn_point =
{
    if (!(self.style & ELOHIM_OBSERVER) || !(self.oflags & OBSERVER_WALK))
    {
        sprint(self, "You must be in walk mode\n");
        return;
    }
    if (!(self.flags & FL_ONGROUND))
    {
        sprint(self, "You must be on the ground\n");
        return;
    }
    if (self.waterlevel)
    {
        sprint(self, "Cannot create underwater spawn point\n");
        return;
    }
    if (elohim_num_spawns >= 20)
    {
        sprint(self, "Max. number of spawn points reached\n");
        return;
    }

    self.owner = spawn();
    self.owner.owner = world;
    self.owner.solid = SOLID_NOT;
    self.owner.movetype = MOVETYPE_NONE;
    self.owner.takedamage = DAMAGE_NO;
    self.owner.fixangle = TRUE;
    self.owner.classname = "info_player_deathmatch";
    self.angles_x = 0;
    self.angles_z = 0;
    self.fixangle = TRUE;
    self.owner.angles = self.angles;
    self.owner.origin = self.origin;
    elohim_num_spawns = elohim_num_spawns + 1;
    sprint(self, "Spawn point created\n");
    admin_show_spot_info();
};

//
//  N E X T  C A M E R A
//
//  If the admin is in fly observer mode, move him to the next camera.
//
void () admin_next_camera =
{
    if (!(self.style & ELOHIM_OBSERVER) || !(self.oflags & OBSERVER_FLY))
    {
        sprint(self, "You must be in fly mode\n");
        return;
    }
    self.owner = find(self.owner, classname, "elohim_camera");
    if (!self.owner)
    {
        self.owner = find(self.owner, classname, "elohim_camera");
        if (!self.owner)
        {
            sprint(self, "No cameras found\n");
            return;
        }
    }

	// setorigin will not actually set the origin if a bad origin is given.
	// Therefore, we first set the origin manually to ensure that the spot info
	// is displayed correctly.
	//
    self.origin = self.owner.origin - '0 0 22';
    self.angles = self.v_angle = self.owner.angles;
    admin_show_spot_info();
    setorigin(self, self.owner.origin);
	self.fixangle = TRUE;           // turn this way immediately
    self.velocity = '0 0 0';
};

//
//  M A K E  C A M E R A
//
//  If the admin is in fly observer mode, create a new camera at his
//  location.
//
void () admin_make_camera =
{
    if (!(self.style & ELOHIM_OBSERVER) || !(self.oflags & OBSERVER_FLY))
    {
        sprint(self, "You must be in fly mode\n");
        return;
    }
    if (elohim_num_cameras >= 20)
    {
        sprint(self, "Max. number of cameras reached\n");
        return;
    }

    self.owner = spawn();
    self.owner.owner = world;
    self.owner.solid = SOLID_NOT;
    self.owner.movetype = MOVETYPE_NONE;
    self.owner.takedamage = DAMAGE_NO;
    self.owner.fixangle = TRUE;
    self.owner.classname = "elohim_camera";
	self.owner.think = auto_camera_think;
	self.owner.nextthink = time + 0.2;
    self.v_angle_z = 0;
    self.angles = self.v_angle;
    self.fixangle = TRUE;
    self.owner.angles = self.v_angle;
    self.owner.origin = self.origin + '0 0 22';
	self.owner.next_camera = elohim_sentinel.next_camera;
	elohim_sentinel.next_camera = self.owner;
    elohim_num_cameras = elohim_num_cameras + 1;
    sprint(self, "Camera created\n");
    admin_show_spot_info();
};

//
//  H E L P
//
void () admin_help =
{
    sprint(self, "Admin only commands:\n");
	sprint(self, " autoss   - automatic screenshots\n");
	if (self.crmod_hack_count != 10)
		sprint(self, " maxteams - set max number of teams\n");
    sprint(self, " crkick   - kick a player\n");
	sprint(self, " crban    - ban a player\n");
	sprint(self, " bans     - see who is banned\n");
	sprint(self, " unban    - remove temporary ban\n");
    sprint(self, " modevote - enable/disable mode votes\n");
	if (self.crmod_hack_count != 10)
	{
		sprint(self, " options  - on-screen options menu\n");
		sprint(self, " dmset    - change deathmatch mode\n");
	}
	sprint(self, " ips      - view player ip addresses\n");
    sprint(self, " abortmatch - abort current match\n");
    sprint(self, " ghostlist  - view list of ghosts\n");
	if (self.crmod_hack_count != 10)
	{
		sprint(self, " spot       - show location/angles\n");
		sprint(self, " nextspawn  - go to next spawn point\n");
		sprint(self, " makespawn  - add spawn point\n");
		sprint(self, " nextcam    - go to next camera\n");
		sprint(self, " makecam    - add camera\n");
		sprint(self, " safepractice - no spam/discharging\n");
	}
};

//
//  D M S E T
//
void (float val) admin_dmset = 
{
	local string temp;

	if (val != -1)
	{
		if (val == 1 || val == 2 || val == 3)
			deathmatch = val - 1;		
		else
			deathmatch = 0;
	}
	deathmatch = deathmatch + 1;
	if (deathmatch == 4)
		deathmatch = 1;
	temp = ftos(deathmatch);
	localcmd3("deathmatch ", temp, "\n");
	announce2("deathmatch changed to ", temp);
};

//
//  S E T  M A X T E A M S
//
void (float num) admin_set_maxteams = 
{
	local string temp;

	elohim_maxteams = num;
	temp = ftos(num);
	announce2("Maximum number of teams set to ", temp);
	utils_set_cvar("scratch2", num);
};

//
//  G E T  M A X T E A M S
//
void () admin_get_maxteams = 
{
	self.use = SUB_Null;
	if (self.finaldest_z < 2 || self.finaldest_z > 8)
	{
		sprint(self, "Invalid\n");
		return;
	}
	admin_set_maxteams(self.finaldest_z);
};

//
//  C H O O S E  M A X T E A M S
//
void () admin_choose_maxteams = 
{
	sprint(self, "Enter maximum number of teams:\n");
	self.use = admin_get_maxteams;
};

//
//  D M 3  S C R E E N S H O T  C L E A N U P
//
void () admin_dm3_screenshot_cleanup = 
{
	gameover = 0;
	intermission_running = 0;
	elohim_state = elohim_state - ELOHIM_TAKING_AUTOSS;

	other = find(world, classname, "player");
	while (other != world)
	{
		if (other.style & ELOHIM_CONNECTED)
		{
			if (!(other.style & ELOHIM_OBSERVER) || (other.style & ELOHIM_ADMINISTRATOR))
			{
				other.modelindex = other.crmod_did_damage;
				if (other.style & ELOHIM_OBSERVER)
				{
					if (other.oflags & (OBSERVER_WALK || OBSERVER_FLY))
						other.view_ofs = '0 0 22';
					else
						other.view_ofs = '0 0 0';
					other.solid = SOLID_NOT;
					other.takedamage = DAMAGE_NO;
					if (other.oflags & OBSERVER_WALK)
						other.finaldest_y = other.movetype = MOVETYPE_WALK;
					else if (other.oflags & OBSERVER_CAMERA)
						other.finaldest_y = other.movetype = MOVETYPE_NONE;
					else
						other.finaldest_y = other.movetype = MOVETYPE_FLY;
				}
				else
				{
					other.view_ofs = '0 0 22';
					other.solid = SOLID_SLIDEBOX;
					other.takedamage = DAMAGE_AIM;
					other.finaldest_y = other.movetype = MOVETYPE_WALK;

					local entity oself;
					oself = self;
					self = other;
					W_SetCurrentAmmo();
					self = oself;
				}
				other.angles = other.v_angle = other.crmod_oldangle;
				other.fixangle = TRUE;		// turn this way immediately
				setorigin (other, other.crmod_old_velocity);
				setorigin (other, other.crmod_old_velocity);
			}
		}
		other = find(other, classname, "player");
	}
	remove(self);

	utils_do_item(SUB_Remove, "elohim_screenshot_entity");
};

//
//  D M 3  S C R E E N S H O T
//
void () admin_dm3_screenshot = 
{
	self.nextthink = time + 2.7;
	self.think = admin_dm3_screenshot_cleanup;
	utils_do_item(SUB_Freeze, "elohim_screenshot_entity");

	other = find(world, classname, "player");
	while (other != world)
	{
		if (other.style & ELOHIM_CONNECTED)
		{
			if (!(other.style & ELOHIM_OBSERVER) || (other.style & ELOHIM_ADMINISTRATOR))
				stuffcmd(other, "coop 0\n");
		}
		other = find(other, classname, "player");
	}
};

//
//  S C R E E N S H O T  S P A W N
//
entity (string modelname, vector position) admin_screenshot_spawn = 
{
	local entity e;
	e = spawn();
	e.classname = "elohim_screenshot_entity";
	setmodel(e, modelname);
	setorigin(e, position);
	e.angles = '0 0 0';
	e.angles_y = random() * 360;
	e.fixangle = TRUE;
	return e;
};

//
//  D M 3  S C R E E N S H O T  S E T U P
//
void () admin_dm3_screenshot_setup = 
{
	if (self != elohim_match_timer)
	{
		if (elohim_state & ELOHIM_TIMER_STARTED)
		{
			if ((elohim_state & ELOHIM_MATCH_STARTED) || (elohim_match_timer.count <= 10))
			{
				sprint(self, "autoss will be taken at end of match\n");
				elohim_state = elohim_state | ELOHIM_DELAYED_AUTOSS;
				return;
			}
		}
		if ((self.style & ELOHIM_OBSERVER ) && (self.oflags & OBSERVER_DEMO))
		{
			auto_camera_start();
			stuffcmd(self, "autoss\n");
			return;
		}
	}

	if (elohim_state & ELOHIM_TAKING_AUTOSS)
		return;

	elohim_state = elohim_state | ELOHIM_TAKING_AUTOSS;
    intermission_running = 1;
    intermission_exittime = time + 5;
	gameover = 1;
	crmod_angle = '20 -180 0';

	other = find(world, classname, "player");
	while (other != world)
	{
		if (other.style & ELOHIM_CONNECTED)
		{
			if (!(other.style & ELOHIM_OBSERVER) || (other.style & ELOHIM_ADMINISTRATOR))
			{
				other.view_ofs = '0 0 0';
				other.crmod_oldangle = other.v_angle;
				other.angles = other.v_angle = '20 -180 0';
				other.fixangle = TRUE;		// turn this way immediately
				other.nextthink = time + 3;
				other.takedamage = DAMAGE_NO;
				other.solid = SOLID_NOT;
				other.finaldest_y = other.movetype = MOVETYPE_NONE;
				other.crmod_did_damage = other.modelindex;
				other.modelindex = 0;
				other.weaponmodel = string_null;
				other.crmod_old_velocity = other.origin;
				setorigin (other, '1870 -35 30');

				stuffcmd(other, "-showscores;impulse 128;wait\n");
				if (self != elohim_match_timer)
				{
					stuffcmd(other, "echo \"\bClanring Screenshot by");
					stuffcmd(other, self.netname);
				}
				else
					stuffcmd(other, "echo \"\bAutomatic Clanring Screenshot");
				stuffcmd(other, "\"\nname\n");
			}
		}
		other = find(other, classname, "player");
	}

	// set lineup spawns
	local float cmap1, cmap2;
	local entity e;

	cmap1 = cmap2 = 0;
	e = elohim_sentinel.next_player;
	if (e)
		cmap1 = e.colormap;
	cmap2 = 0;
	while (e)
	{
		cmap2 = e.colormap;
		e = e.next_player;
	}
	
	// front row
	e = admin_screenshot_spawn("progs/armor.mdl", '1675 -235 -146');
	e.skin = 1;
	e = admin_screenshot_spawn("progs/eyes.mdl", '1675 -185 -146');
	e = admin_screenshot_spawn("progs/player.mdl", '1675 -135 -146');
	e.frame = 6;
	e.colormap = cmap1;
	e = admin_screenshot_spawn("progs/quaddama.mdl", '1675 -85 -146');
	e = admin_screenshot_spawn("progs/player.mdl", '1675 -35 -146');
	e.frame = 0;
	e.colormap = cmap2;
	e = admin_screenshot_spawn("progs/invulner.mdl", '1675 15 -146');
	e = admin_screenshot_spawn("progs/player.mdl", '1675 65 -146');
	e.frame = 12;
	e.colormap = cmap1;
	e = admin_screenshot_spawn("progs/invisibl.mdl", '1675 115 -146');
	e = admin_screenshot_spawn("progs/armor.mdl", '1675 165 -146');
	e.skin = 2;

	// second row
	e = admin_screenshot_spawn("progs/spike.mdl", '1625 -235 -146');
	e = admin_screenshot_spawn("progs/g_shot.mdl", '1625 -185 -170');
	e = admin_screenshot_spawn("progs/g_nail.mdl", '1625 -135 -170');
	e = admin_screenshot_spawn("progs/g_nail2.mdl", '1625 -85 -170');
	e = admin_screenshot_spawn("progs/backpack.mdl", '1625 -35 -146');
	e = admin_screenshot_spawn("progs/g_rock.mdl", '1625 15 -170');
	e = admin_screenshot_spawn("progs/g_rock2.mdl", '1625 65 -170');
	e = admin_screenshot_spawn("progs/g_light.mdl", '1625 115 -170');
	e = admin_screenshot_spawn("progs/s_spike.mdl", '1625 165 -146');

	// third row
	e = admin_screenshot_spawn("maps/b_bh100.bsp", '1575 -285 -146');
	e.angles_y = 0;
	e = admin_screenshot_spawn("progs/s_bubble.spr", '1575 -235 -146');
	e = admin_screenshot_spawn("progs/bolt.mdl", '1575 -135 -146');
	e.angles_y = 90;
	e = admin_screenshot_spawn("progs/bolt3.mdl", '1575 -85 -146');
	e.angles_y = 90;
	e = admin_screenshot_spawn("progs/bolt2.mdl", '1575 65 -146');
	e.angles_y = 90;
	e = admin_screenshot_spawn("progs/missile.mdl", '1575 -150 -146');
	e.movetype = MOVETYPE_FLYMISSILE;
	e.velocity = '0 1000 0';
	e.angles = '0 90 0';
	e = admin_screenshot_spawn("progs/s_explod.spr", '1575 215 -146');
	e.frame = 3;

	// fourth row
	e = admin_screenshot_spawn("progs/player.mdl", '1525 -185 -146');
	e.frame = 7;
	e.colormap = cmap2;
	e = admin_screenshot_spawn("progs/player.mdl", '1525 -135 -146');
	e.frame = 13;
	e.colormap = cmap1;
	e = admin_screenshot_spawn("progs/player.mdl", '1525 -85 -146');
	e.frame = 2;
	e.colormap = cmap2;
	e = admin_screenshot_spawn("progs/player.mdl", '1525 -35 -146');
	e.frame = 8;
	e.colormap = cmap1;
	local float temp;
	temp = 2.999 * random();
	temp = floor(temp);
	e = admin_screenshot_spawn("progs/player.mdl", '1525 15 -146');
	e.frame = 3 + temp;
	e.colormap = cmap2;
	e = admin_screenshot_spawn("progs/player.mdl", '1525 65 -146');
	e.frame = 9 + temp;
	e.colormap = cmap1;
	e = admin_screenshot_spawn("progs/player.mdl", '1525 115 -146');
	e.frame = 14 + temp;
	e.colormap = cmap2;
	e = admin_screenshot_spawn("progs/grenade.mdl", '1525 -150 -146');
	e.movetype = MOVETYPE_FLYMISSILE;
	e.velocity = '0 1000 0';
	e.angles = '0 90 0';

	// fifth row
	e = admin_screenshot_spawn("progs/player.mdl", '1525 80 -90');
	e.movetype = MOVETYPE_FLYMISSILE;
	e.velocity = '0 -1000 0';
	e.frame = 1;
	e.colormap = cmap1;

	// upper bridge
	e = admin_screenshot_spawn("maps/b_rock0.bsp", '1350 -235 -48');
	e.angles_y = 0;
	e = admin_screenshot_spawn("maps/b_rock1.bsp", '1350 -185 -48');
	e.angles_y = 0;
	e = admin_screenshot_spawn("maps/b_batt0.bsp", '1350 -135 -48');
	e.angles_y = 0;
	e = admin_screenshot_spawn("maps/b_batt1.bsp", '1350 -85 -48');
	e.angles_y = 0;
	e = admin_screenshot_spawn("maps/b_bh10.bsp", '1350 -35 -48');
	e.angles_y = 0;
	e = admin_screenshot_spawn("maps/b_bh25.bsp", '1350 15 -48');
	e.angles_y = 0;

	utils_make_scheduled_event(admin_dm3_screenshot, 0.3);	
};

//
//  A U T O  S C R E E N S H O T
//
void () admin_auto_screenshot = 
{
	local entity player;

	if ((mapname == "dm3") && (elohim_playmode & ELOHIM_MATCH_MODE))
	{
		admin_dm3_screenshot_setup();
		return;
	}

	if ((self.style & ELOHIM_OBSERVER) && (self.oflags & OBSERVER_DEMO))
	{
		// single player screenshot
		if ((elohim_state & ELOHIM_MATCH_STARTED) && (self.movetarget.style & ELOHIM_GLQUAKE))
		{
			sprint(self, self.movetarget.netname, " is using GL Quake!\n");
			sprint(self, "No autoss taken (take it after match)\n");
		}
		else
		{
			stuffcmd(self, "echo \"\bClanring Screenshot by");
			stuffcmd(self, self.netname);
			stuffcmd(self, "\"\nwait;screenshot\n");
			stuffcmd(self.movetarget, "name\n");
			stuffcmd(self.movetarget, "echo \"\bClanring Screenshot by");
			stuffcmd(self.movetarget, self.netname);
			stuffcmd(self.movetarget, "\"\nwait;coop 0\n");
		}
	}
	else if (elohim_state & ELOHIM_MATCH_STARTED)
	{
		player = find(world, classname, "player");
		while (player)
		{
			if (!(player.style & ELOHIM_OBSERVER))
			{
				if (player.style & ELOHIM_GLQUAKE)
					sprint(self, player.netname, " is using GL Quake\n");
				else
				{
					stuffcmd(player, "name\n");
					stuffcmd(player, "echo \"\bClanring Screenshot by");
					stuffcmd(player, self.netname);
					stuffcmd(player, "\"\nwait;coop 0\n");
				}
			}
			player = find(player, classname, "player");
		}
	}
	else
	{
		player = find(world, classname, "player");
		while (player)
		{
			if (!(player.style & ELOHIM_OBSERVER))
			{
				stuffcmd(player, "+showscores;\n");
				stuffcmd(player, "echo \"\bClanring Screenshot by");
				stuffcmd(player, self.netname);
				stuffcmd(player, "\"\nscr_conspeed 9999;path;name;wait;coop 0;toggleconsole;wait;coop 0;-showscores;toggleconsole\n");
			}
			player = find(player, classname, "player");
		}
	}
};

//
//  I P S
//
//  List player ip addresses
//
void () admin_ips = 
{
	local entity e;
	local float p;

	if (self.crmod_hack_count)
	{
		sprint(self, "ips: permission denied\n");
		return;
	}

	sprint(self, "      name       \b|\b       ip\n");
	sprint(self, "\b-----------------+-----------------\n");
	e = find(world, classname, "player");
	while (e)
	{
		if (e.style & ELOHIM_CONNECTED)
		{
			p = AddInt(AddInt(&e.qs, 4 * QS_ADDRESS + %32), PQUAKEC_TO_PSTRING);
			sprint(self, " ", e.name15, "\b | ", @p, "\n");
		}
		e = find(e, classname, "player");
	}
};

//
//  B A N S
//
void () admin_bans = 
{
	local float i;
	local string s;

	if (!(elohim_playmode & ELOHIM_DEDICATED_SERVER))
	{
		sprint(self, "Available on dedicated servers only\n");
		return;
	}

	if (self.crmod_hack_count)
	{
		sprint(self, "bans: permission denied\n");
		return;
	}

	zone_check_clear();

	sprint(self, "      name       \b|\b       ip\n");
	sprint(self, "\b-----------------+-----------------\n");
	for (i = 0 ; i < zone_vars[ZONE_NUM_BANS] ; i = i + %1)
	{
		if (zone_ban_mask[i])
		{
			s = net_get_ban_name(i);
			sprint(self, " ", s, " \b| ");
			net_sprint_ip(zone_ban_ip[i], zone_ban_mask[i]);
			sprint(self, "\n");
		}
	}
};

//
//  U N B A M
//
void () admin_unban = 
{
	local string s;

	localcmd("ban 0\n");
	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		if (zone_ban_mask[0])
		{
			s = net_get_ban_name(0);
			sprint(self, "unbanning ", s, " (");
			net_sprint_ip(zone_ban_ip[0], zone_ban_mask[0]);
			sprint(self, ")\n");
			zone_ban_ip[0] = IP_MASK0;
			zone_ban_mask[0] = 0;
		}
		else
			sprint(self, "No temporary ban\n");
	}
	else
		sprint(self, "Removing temporary ban\n");
};

//
//  I M P U L S E
//
//  Called by elohim_impulse in Elohim.qc
//
void () admin_impulse =
{
    // votable commands
    if (self.impulse >= 190 && self.impulse <= 196)
        votables_init_warp(self.impulse - 190);
    else if (self.impulse >= 217 && self.impulse <= 220)
        votables_request_set_mode(self.impulse - 217);
	else if (self.impulse == 209)
		votables_request_set_faststarts();
	else if (self.impulse == 210)
		votables_request_set_autopause();
	else if (self.impulse == 211)
		votables_request_set_obits();
	else if (self.impulse == 215)
		votables_select_timelimit();
	else if (self.impulse == 216)
		votables_select_overtime();
    else if (self.impulse == 221)
        votables_request_set_quad();
    else if (self.impulse == 222)
        votables_request_set_pent();
    else if (self.impulse == 223)
        votables_request_set_ring();
    else if (self.impulse >= 225 && self.impulse <= 227)
        votables_request_set_gibs(self.impulse - 225);
    else if (self.impulse >= 230 && self.impulse <= 245)
    {
        if (self.use)
        {
            self.finaldest_z = self.impulse - 230;
            self.use();
        }
    }
	else if (self.impulse == 251)
		votables_request_admin();

    if (!(self.style & ELOHIM_ADMINISTRATOR))
        return;

    // admin only commands
	if (self.impulse == 200)
		admin_help();
	else if (self.impulse == 197)
		admin_bans();
	else if (self.impulse == 198)
		admin_unban();
	else if (self.impulse >= 201 && self.impulse <= 203) // TRAINING
		training_start(self.impulse - 201);
	else if (self.impulse == 204)
		admin_auto_screenshot();
	else if (self.impulse == 205)
		admin_start_kick(KICK_BAN);
	else if (self.impulse == 206)
		admin_ips();
    else if (self.impulse == 212)
        admin_list_ghosts();
    else if (self.impulse == 213)
        admin_start_kick(KICK_KICK);
    else if (self.impulse == 214)
	{
//        dprint("match aborted\n");//Sputnik todo?
		match_end();
	}
    else if (self.impulse == 224)
		utils_toggle_sflag(ELOHIM_NO_SPOOGE, "Safe practice mode");
    else if (self.impulse == 228)
		utils_toggle_sflag(ELOHIM_MODE_VOTE, "Mode voting");

	if (self.crmod_hack_count == 10)
		return;

	// commands not available to voted admins
	if (self.impulse == 207)
		admin_dmset(-1);
	else if (self.impulse == 208)
		admin_choose_maxteams();
    else if (self.impulse == 229)
        options_start_setting();
    else if (self.impulse == 246)
        admin_next_spawn_point();
    else if (self.impulse == 247)
        admin_make_spawn_point();
    else if (self.impulse == 248)
        admin_next_camera();
    else if (self.impulse == 249)
        admin_make_camera();
    else if (self.impulse == 250)
        admin_show_spot_info();
};

//
//  D I S C O N N E C T  N O T I F Y
//
//  Remove this player from the list of kickable players.
//
void (entity player) admin_disconnect_notify = 
{
    local float index;

	for (index = %1 ; index < %16 ; index = index + %1)
	{
		if (player == *array_kick[index])
			array_kick[index] = %0;
	}
};
