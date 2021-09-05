//
// auto.qc
//
// This is the autocam handling code for CRMod++.
//
// All code by J.P. Grossman unless otherwise commented.  :p
//
// // Global variables used:
//
// entity crmod_best_chase_target;    // best chase target in terms of score alone
// entity crmod_current_chase_target; // current chase target 
// float crmod_chase_delay;           // delay before we can switch to best chasetarget
// entity crmod_best_camera;          // best camera in terms of score alone
// entity crmod_current_camera;       // current QUAKETV camera
// float crmod_camera_delay;          // delay before we can switch to best camera
//

// // Client fields used:
//
// .attack_finished				used to tell when a person last fired a weapon
// .super_damage_finished		find person with quad
// .crmod_autotime				time change targets
//
// Prototypes:
void () observer_chase_start;
void () observer_camera_start;


// CRMOD
// A U T O  C O M P U T E  S C O R E
//
//  Renamed and revamped by J.P. Grossman
//
//  Based on specified criteria, rates the player to see if they are the best player to watch.
//  Called once every second
//
void () auto_compute_score =
{
	local float score, temp;
	
	// score starts off with health, armor, frags, last time they fired their gun, 
	// and last time they hurt someone.
	score = self.health + self.armorvalue + self.frags;
	
	temp = self.crmod_did_damage + 15 - time;
	if (temp > 0)
		score = score + temp * 40;
	temp = self.attack_finished + 10 - time;
	if (temp > 0)
		score = score + temp * 20;
	
	// weapon related stuff
	if (self.items & IT_GLRLLG)
	{
		// 200 + # of rockets if they have RL
		if (self.items & IT_ROCKET_LAUNCHER)
		{
			score = score + 200 + self.ammo_rockets;
			// bonus if it's the only one on the team
			if (teamplay && (elohim_state & ELOHIM_MATCH_STARTED))
			{
				if (self.next_team.ammo_rockets == 1)
					score = score + auto_parm1;
			}
		}
		// or just # of rockets if they have GL
		else if (self.items & IT_GRENADE_LAUNCHER)
			score = score + self.ammo_rockets;
		// and # of cells if they have LG
		if (self.items & IT_LIGHTNING)
			score = score + self.ammo_cells;
	}
	
	// powerups 300 ea. for quad or pent, 50 for eyes
	if (self.items & IT_QINVISINVUL)
	{
		if (self.items & IT_QUAD)
			score = score + 300;
		if (self.items & IT_INVULNERABILITY)
			score = score + 300;
		if (self.items & IT_INVISIBILITY)
			score = score + 50;
	}
	
	// powerup potential?
	if ((elohim_pent != world) && (time > elohim_pent.nextthink - 15))
		score = score + auto_parm2 * 300 / (vlen(self.origin - elohim_pent.origin) + 300);
	if ((elohim_quad != world) && (time > elohim_quad.nextthink - 10))
		score = score + auto_parm3 * 300 / (vlen(self.origin - elohim_quad.origin) + 300);

	// now store their score for later
	self.crmod_chase_score = score;

	if (score > crmod_best_chase_target.crmod_chase_score || crmod_best_chase_target == world)
		crmod_best_chase_target = self;

	if (score > crmod_best_camera.crmod_chase_score || crmod_best_camera == world)
		crmod_best_camera = self;
};
	
// CRMOD
// A U T O  C A M E R A  T H I N K
//
// Called once every second for cameras that can see the best chase target
//
//   JP - added self.count to compute a 'visible player' score
//	 JP - got rid of 'best'; used self.movetarget throughout
//
void () auto_camera_think =
{
	local float score, seeable, temp;
	local entity player;
		
	self.movetarget = elohim_sentinel;
	score = 0;		// JP - added this
	self.count = 0;	// JP - added this
	player = elohim_sentinel.next_player;
	while (player)
	{
		seeable = utils_new_visible(self, player);
		if (seeable)
		{
			self.count = self.count + seeable; 
			score = score + player.crmod_chase_score;

			if (seeable == 4) 
			{
				// Bonus points for proximity
				temp = 600 - vlen(self.origin - player.origin);
				if (temp > 0)
					score = score + temp / 3;
				if (player.crmod_chase_score > self.movetarget.crmod_chase_score)
					self.movetarget = player;
			}
		}
		player = player.next_player;
	}

	self.crmod_cam_delay = time + 4;

	// now store their score for later
	self.crmod_chase_score = score;

	if (self.movetarget == elohim_sentinel)
	{
		self.movetarget = world;
		if (crmod_best_camera == self)
			crmod_best_camera = crmod_best_chase_target;
		if (crmod_current_camera == self)
		{
			crmod_current_camera = crmod_best_camera;
			crmod_camera_delay = time + 4;
		}
	}
	else if (self.count >= 8)
	{
		if (self.crmod_chase_score > crmod_best_camera.crmod_chase_score || crmod_best_camera == world)
			crmod_best_camera = self;
	}
};

//
//  C H E C K  C U R R E N T  C A M E R A
//
//  Each frame, make sure that the current camera has a movetarget.
//
void () auto_check_current_camera = 
{
	local float seeable;
	local entity temp;

	if (crmod_current_camera.classname == "elohim_camera")
	{
		seeable = 0;
		if (crmod_current_camera.movetarget)			
			seeable = utils_new_visible(crmod_current_camera, crmod_current_camera.movetarget);
			
		if (seeable < 4)
		{
			temp = self;
			self = crmod_current_camera;
			self.nextthink = -1;
			auto_camera_think();
			self = temp;
		}
	}
};

//
//  S C H E D U L E  C A M E R A S
//
//  Any cameras that can see the best chase target should be allowed to think
//
void () auto_schedule_cameras = 
{
	local entity camera;

	if (!crmod_best_chase_target)
		return;

	camera = elohim_sentinel.next_camera;
	while (camera)
	{
		if (utils_visible(camera, crmod_best_chase_target))
			camera.nextthink = time + 0.1 + random();//Sput added time +
		else if (camera == crmod_current_camera)
			camera.nextthink  = time + 0.1 + random();//Sput added time +
		else
			camera.crmod_chase_score = -1;
		camera = camera.next_camera;
	}
};
	
// CRMOD
//  A U T O  C A M E R A  S T A R T
//    by Paul Baker
//
//  start autocamera from anywhere
//
void () auto_camera_start =
{
	self.oflags = self.oflags | OBSERVER_GO_AUTO;
	self.oflags = self.oflags | OBSERVER_QUAKETV;//Sputnik added OBSERVER_QUAKETV
	observer_camera_start();
};

// CRMOD
//  A U T O  C H A S E  S T A R T
//    by Paul Baker
//
//  start autochase from anywhere
void () auto_chase_start =
{
	self.oflags = self.oflags | OBSERVER_GO_AUTO;
	observer_chase_start();
};
	
// CRMOD
// A U T O  C H A S E
//
//   checks if it's time to switch to a new target.
//   scheduled from elohim_start_frame
//
void () auto_chase =
{
	local float temp1, temp2;
	local entity inflictor;

	remove(self);

	if (crmod_current_chase_target == crmod_best_chase_target)
		return;

	if (!crmod_best_chase_target)
		return;

	if (!crmod_current_chase_target)
	{
		crmod_current_chase_target = crmod_best_chase_target;
		crmod_chase_delay = time + 4;
		return;
	}

	// JP - added mandantory delays
	if (time < crmod_current_chase_target.crmod_cam_delay || time < crmod_chase_delay)
		return;

	if (time - crmod_current_chase_target.attack_finished < 2)
		return;
	inflictor = crmod_current_chase_target.dmg_inflictor;
	if (inflictor)
	{
		if ((inflictor.crmod_inflicted == crmod_current_chase_target) && (time - inflictor.crmod_did_damage < 2))
			return;
	}
	
	if (crmod_best_chase_target.crmod_chase_score - crmod_current_chase_target.crmod_chase_score < 100)
		return;

	crmod_current_chase_target = crmod_best_chase_target;
	crmod_chase_delay = time + 4;
};

// CRMOD
// A U T O  C A M E R A
//
// Runs autocam for observers
//
// Rewritten by J.P. Grossman
//
void () auto_camera =
{	
	local float temp1, temp2, temp3;
	local entity inflictor;

	remove(self);

	if (!crmod_best_camera)
		return;

	if (crmod_current_camera == crmod_best_camera)
		return;

	if (!crmod_current_camera)
	{
		crmod_current_camera = crmod_best_camera;
		crmod_camera_delay = time + 4;
		return;
	}

	if (crmod_current_camera.classname == "player") // chasecam mode
	{
		// mandantory delay
		if (time < crmod_camera_delay)
			return;

		if ((crmod_best_camera.classname != "elohim_camera") || (crmod_best_camera.movetarget != crmod_current_camera))
		{
			if (time - crmod_current_camera.attack_finished < 2)
				return;
			inflictor = crmod_current_camera.dmg_inflictor;
			if (inflictor)
			{
				if ((inflictor.crmod_inflicted == crmod_current_camera) && (time - inflictor.crmod_did_damage < 2))
					return;
			}

			if (crmod_best_camera.crmod_chase_score - crmod_current_camera.crmod_chase_score < 100)
				return;
		}
	}
	else // camera mode
	{
		local entity camera;

		camera = crmod_current_camera;

		// smaller mandantory delay
		if (time < crmod_camera_delay - 2)
			return;

		// switch if best camera has the same movetarget
		if ((crmod_best_camera.classname != "elohim_camera") || (crmod_best_camera.movetarget != camera.movetarget))
		{
			if (crmod_best_camera.crmod_chase_score - camera.crmod_chase_score < 100)
				return;
			
			if (time - camera.movetarget.attack_finished < 2)
				return;
		}
	}

	crmod_current_camera = crmod_best_camera;
	crmod_camera_delay = time + 4;
};
