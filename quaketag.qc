//
// quaketag.qc
//
// This file contains code for the Quake Tag egg :)
// And the rocket egg :D
//

void () respawn;
void () GibPlayer;

entity crmod_qtag_it;

//
//  I N I T  W O R L D
//
void () quaketag_init_world =
{
	crmod_qtag_it = world;
};

//
//  I N I T
//
void () quaketag_init = 
{
	local float temp;
	local entity player;
	local entity penis;

	temp = 1;
	self.use = SUB_Null;
	if (elohim_state & ELOHIM_MATCH_STARTED)
		temp = 0;
	if (elohim_state & ELOHIM_TIMER_STARTED)
	{
		if (elohim_match_timer.count <= 10)
			temp = 0;
	}
	if (!(elohim_playmode & ELOHIM_MATCH_MODE) || !teamplay)
		temp = 0;
	if ((crmod_qtag_it != world) || (self.finaldest_z < 14) || (elohim_sentinel.next_player == world))
		temp = 0;
	if ((self.finaldest_z == 14) && (self.style & ELOHIM_OBSERVER))
		temp = 0;

	if (temp)
	{
		if (self.finaldest_z == 14)
		{
			penis = find(world, classname, "penis");
			while (penis)
			{
				if (penis.owner == self)
					return;
				penis = find(penis, classname, "penis");
			}

			penis = spawn ();
			penis.owner = self;
			penis.movetype = MOVETYPE_FLY;
			penis.solid = SOLID_BBOX;
			penis.classname = "penis";
			setmodel (penis, "progs/missile.mdl");
			setsize (penis, '0 0 0', '0 0 0');		
			penis.attack_finished = time;
			penis.count = 0;

			announce2(self.netname, " has a hard-on for quake");

			return;
		}

		if (self.style & ELOHIM_OBSERVER)
			crmod_qtag_it = elohim_sentinel.next_player;
		else
			crmod_qtag_it = self;
		bprint("\b\<Quake Tag Activated!!\>\n");
		dprint("Quake Tag Activated!\n");
		announce2(crmod_qtag_it.netname, " is it");
		crmod_qtag_it.effects = crmod_qtag_it.effects | EF_BRIGHTFIELD;
		crmod_qtag_it.items = crmod_qtag_it.items | IT_ROCKET_LAUNCHER;
		crmod_qtag_it.ammo_rockets = 10;

		local float r;
		r = random();
		if (r < 0.16)
			sound(self, CHAN_AUTO, "demon/sight2.wav", 1, ATTN_NONE);
		else if (r < 0.33)
			sound(self, CHAN_AUTO, "dog/dsight.wav", 1, ATTN_NONE);
		else if (r < 0.5)
			sound(self, CHAN_AUTO, "knight/ksight.wav", 1, ATTN_NONE);
		else if (r < 0.66)
			sound(self, CHAN_AUTO, "ogre/ogwake.wav", 1, ATTN_NONE);
		else if (r < 0.84)
			sound(self, CHAN_AUTO, "shambler/ssight.wav", 1, ATTN_NONE);
		else
			sound(self, CHAN_AUTO, "soldier/sight1.wav", 1, ATTN_NONE);

		player = find(world, classname, "player");
		while (player)
		{
			if ((player.style & ELOHIM_CONNECTED) && !(player.style & ELOHIM_OBSERVER))
				player.frags = 0;
	        player = find(player, classname, "player");
		}
	}
	else
	{
		r = random();
		if (r < 0.25)
			sprint(self, "Preach on, brother!\n");
		else if (r < 0.5)
			sprint(self, "You got that right!\n");
		else if (r < 0.75)
			sprint(self, "Amen!\n");
		else 
			sprint(self, "You listening Id!?\n");
	}
};

//
//  C L E A R
//
void () quaketag_clear = 
{
	utils_do_item(SUB_Remove, "penis");

	if (crmod_qtag_it)
	{
		crmod_qtag_it.effects = crmod_qtag_it.effects - (crmod_qtag_it.effects & EF_BRIGHTFIELD);
		crmod_qtag_it.items = crmod_qtag_it.items - (crmod_qtag_it.items & IT_ROCKET_LAUNCHER);
		crmod_qtag_it.ammo_rockets = 0;
		bprint("\bQuake Tag Over!  Play Again?  (Y/N)\n");
		dprint("Quake Tag Over!  Play Again?  (Y/N)\n");
	}
	crmod_qtag_it = world;
};

//
//  D I S C O N N E C T  N O T I F Y 
//
void (entity player) quaketag_disconnect_notify =
{
	local entity penis;

	penis = find(world, classname, "penis");
	while (penis)
	{
		if (penis.owner == player)
			remove(penis);
		penis = find(penis, classname, "penis");
	}

	if (crmod_qtag_it == player)
		quaketag_clear();
};

//
//  R E S P A W N
//
void () quaketag_respawn = 
{
	local float ready;

	ready = self.style & ELOHIM_READY;
	self.style = self.style | ELOHIM_READY;
	respawn();
	self.style = (self.style - ELOHIM_READY) | ready;
	self.effects = self.effects | EF_BRIGHTFIELD;
	self.items = self.items | IT_ROCKET_LAUNCHER;
	self.ammo_rockets = 10;
};

void() BecomeExplosion;

//
//  P E N I S  T H I N K
//
void () quaketag_penis_think = 
{
	local entity player;
	local vector tip;
	local float da;
	local float r;

	makevectors(self.owner.v_angle);
	setorigin(self, self.owner.origin);
	self.angles = vectoangles(v_forward);

	if (time >= self.attack_finished)
	{
		tip = self.owner.origin + 32 * v_forward;
		player = find(world, classname, "player");
		while (player)
		{
			if ((player != self.owner) && (vlen(tip - player.origin) < 16))
			{
				da = self.owner.v_angle_y - player.v_angle_y;
				if (da > 180)
					da = da - 360;
				if (da < -180)
					da = da + 360;
				if (da > -30 && da < 15)
				{
					r = random();
					self.count = self.count + 1;
					if (self.count == 7)
					{
						if (r < 0.33)
							sound(self, CHAN_VOICE, "player/death1.wav", 1, ATTN_NORM);
						else if (r < 0.66)
							sound(self, CHAN_VOICE, "player/death2.wav", 1, ATTN_NORM);
						else 
							sound(self, CHAN_VOICE, "player/death3.wav", 1, ATTN_NORM);
						BecomeExplosion();
						self.classname = "dead_penis";
					}
					else
					{
						if (r < 0.5)
							sound(self, CHAN_VOICE, "player/pain2.wav", 1, ATTN_NORM);
						else
							sound(self, CHAN_VOICE, "player/pain4.wav", 1, ATTN_NORM);
					}
					self.attack_finished = time + 0.4;
					return;
				}
			}
			player = find(player, classname, "player");
		}
		if (self.count)
		{
			self.count = 0;
			sound(self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		}
	}
};

//
//  S T A R T  F R A M E
//
void () quaketag_start_frame = 
{
	local entity oself;
	local entity penis;

	if (crmod_qtag_it.deadflag)
		return;

	other = find(world, classname, "player");
	while (other)
	{
		if (!(other.style & ELOHIM_OBSERVER) && (other.style & ELOHIM_CONNECTED))
		{
			if (other != crmod_qtag_it)
			{
				local vector v;
				v = other.origin - crmod_qtag_it.origin;
				if (vlen(v) < 64)
				{
					oself = self;
					self = other;
					crmod_qtag_it.effects = crmod_qtag_it.effects - (crmod_qtag_it.effects & EF_BRIGHTFIELD);
					crmod_qtag_it.items = crmod_qtag_it.items - (crmod_qtag_it.items & IT_ROCKET_LAUNCHER);
					crmod_qtag_it.ammo_rockets = 0;
					crmod_qtag_it = self;
			        self.health = -99;

					local float gibs;
					gibs = elohim_playmode & (ELOHIM_NO_GIBS | ELOHIM_LOW_GIBS);
					elohim_playmode = elohim_playmode - gibs;
					GibPlayer();
					elohim_playmode = elohim_playmode | gibs;

					penis = find(world, classname, "penis");
					while (penis)
					{
						if (penis.owner == self)
							remove(penis);
						penis = find(penis, classname, "penis");
					}

					self.deadflag = DEAD_DYING;
					self.think = quaketag_respawn;
					self.nextthink = time + 1;
					announce2(crmod_qtag_it.netname, " is it");
					crmod_qtag_it.frags = crmod_qtag_it.frags - 1;
					self = oself;
					return;
				}
			}
		}
		other = find(other, classname, "player");
	}

	if (!crmod_qtag_it.ammo_rockets)
	{
		sprint(crmod_qtag_it, "Trading 1 frag for 10 rockets\n");
		crmod_qtag_it.frags = crmod_qtag_it.frags - 1;
		crmod_qtag_it.ammo_rockets = 10;
	}
};