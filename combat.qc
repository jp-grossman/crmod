
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

// void() monster_death_use; // ELOHIM_MOD - no monsters in clan server

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;
	
	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

    // ELOHIM_MOD - no monsters
    /*
// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}
    */
    // END_MOD

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

    // monster_death_use(); // ELOHIM_MOD - no monsters in clan server
	self.th_die ();
	
	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
	local	vector	dir;
	local	entity	oldself;
	local	float	save, take, overkill;

	if (!targ.takedamage)
		return;

	if (elohim_state & ELOHIM_MATCH_PAUSED)//Sputnik: sometimes you can get stuck in a doorway/plats/train! ouch!
		return;

    // ELOHIM_MOD - stats
    if (attacker.classname == "player")
	{
		if (targ != attacker)
		{
			attacker.crmod_inflicted = targ;  // CRMOD - to see who attacker attacked
			attacker.crmod_did_damage = time;  // CRMOD keep track of last time they hurt someone
		
			if (targ.classname != "player" || attacker.team != targ.team || !teamplay)
			{
				if (inflictor == attacker)
				{
					if (attacker.weapon == IT_SHOTGUN || attacker.weapon == IT_SUPER_SHOTGUN)
					{
						if (!(elohim_playmode & ELOHIM_MATCH_MODE) || (elohim_state & ELOHIM_MATCH_STARTED))
							attacker.dest2_x = attacker.dest2_x + damage;
					}
					else if (attacker.weapon == IT_LIGHTNING)
					{
						if (attacker.waterlevel <= 1) // don't count discharges
							attacker.dest2_z = attacker.dest2_z + damage;
					}
				}
				else if (inflictor.classname == "missile" && targ.classname == "player")
				{
					attacker.dest_y = attacker.dest_y + damage;
					inflictor.dmg = TRUE; // flag missile as having done damage
				}
				else if (inflictor.classname == "spike")
					attacker.dest2_y = attacker.dest2_y + damage;
			}
			else if (attacker.team == targ.team && teamplay)
			{
				if (inflictor == attacker)
				{
					if (attacker.weapon == IT_SHOTGUN || attacker.weapon == IT_SUPER_SHOTGUN)
					{
						if (!(elohim_playmode & ELOHIM_MATCH_MODE) || (elohim_state & ELOHIM_MATCH_STARTED))
							attacker.crmod_badstats_z = attacker.crmod_badstats_z + damage;
					}
					else if (attacker.weapon == IT_LIGHTNING)
					{
						if (attacker.waterlevel <= 1) // don't count discharges
							attacker.crmod_badstats_z = attacker.crmod_badstats_z + damage;
					}
				}
				else if (inflictor.classname == "missile")
				{
					attacker.crmod_badstats_z = attacker.crmod_badstats_z + damage;
					inflictor.dmg = TRUE; // flag missile as having done damage
				}
				else if (inflictor.classname == "spike")
					attacker.crmod_badstats_z = attacker.crmod_badstats_z + damage;
			}
		}
		else
		{
			// store damage in the rocket until we know it's not a RJ
			if (inflictor.classname == "missile")
				inflictor.crmod_badstats_y = inflictor.crmod_badstats_y + damage;
		}
	}                        
    // END_MOD

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// check for quad damage powerup on the attacker
	if ((attacker.super_damage_finished > time) && (inflictor.classname != "door"))	//Sputnik: no quad power on doors
	
	// CRMOD - count damage done with quad.
	// CRMOD - stats  
	{
		damage = damage * 4;
		if (attacker.classname == "player" && targ != attacker && inflictor.classname != "grenade")
    	{
    	   	if (targ.classname != "player" || attacker.team != targ.team || !teamplay)
        		attacker.crmod_qdwep_x = attacker.crmod_qdwep_x + damage;
        }
	}
	// END_CRMOD  
		
// save damage based on the target's armor level

	save = ceil(targ.armortype*damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	
	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage-save);

	if (take >= targ.health)
	{
		overkill = (ceil(targ.health));
	}
	else
	{
		overkill = (ceil(take));
	}

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*damage*8;
	}

    // ELOHIM_MOD - print info for practice mode; check for pre-match
    if (elohim_playmode & ELOHIM_PRACTICE_MODE)
    {
        if (targ.classname == "player" && attacker.classname == "player"
            && targ != attacker)
        {
            local string temp;
            temp = ftos(damage);
            centerprint(attacker, targ.netname, ": ", temp, "\n\n\n\n\n\n\n\n");
        }
    }
    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        if (!(elohim_state & ELOHIM_MATCH_STARTED))
            return;
    }
    // END_MOD

// check for godmode or invincibility
	// ELOHIM_MOD - no god mode
	//if (targ.flags & FL_GODMODE)
	//	return;
	// END_MOD

	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
    // ELOHIM_MOD - nested the ifs
    if (teamplay == 1)
    {
        if ( (targ.team > 0)&&(targ.team == attacker.team) )
            return;
    }
    // END_MOD
		
// do the damage
	targ.health = targ.health - take;

	//Sputnik: Damage Stats
	if ((targ.classname == "player") && (attacker.classname == "player") && (targ != attacker) && ((!teamplay) || (targ.team != attacker.team)))
	{
		targ.dmg_taken = (targ.dmg_taken + (save + overkill));
		attacker.dmg_given = (attacker.dmg_given + (save + overkill));
	}

	if (targ.health <= 0)
	{
        // ELOHIM_MOD - print info for practice mode
        if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        {
            if (targ.classname == "player" && attacker.classname == "player"
                && targ != attacker)
            {
                local string temp;
                temp = ftos(attacker.health);
                centerprint(targ, "\n\n\n\n", attacker.netname, " has ", temp, " health");
                sprint(targ, "\n\n\n\n", attacker.netname, " has ", temp, " health\n");
            }
        }
        // END_MOD

		Killed (targ, attacker);
		return;
	}

// react to the damage
	oldself = self;
	self = targ;

    // ELOHIM_MOD - no monsters in server
    /*
	if ( (self.flags & FL_MONSTER) && attacker != world)
	{
	// get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy)
		{
			if ( (self.classname != attacker.classname) 
			|| (self.classname == "monster_army" ) )
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget ();
			}
		}
	}
    */
    // END_MOD

	if (self.th_pain)
	{
		self.th_pain (attacker, take);

        // ELOHIM_MOD - unused
        /*
	// nightmare mode monsters don't go into pain frames often
		if (skill == 3)
			self.pain_finished = time + 5;
        */
        // END_MOD
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
                // ELOHIM_MOD - this has been optimized
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
                if (points < damage)
                {
                    points = damage - points;
                    if (head == attacker)
                        points = points * 0.5;
					if (CanDamage (head, inflictor))
                        T_Damage (head, inflictor, attacker, points);
				}
                // END_MOD
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
// ELOHIM_MOD - unused
/*
void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
					if (head.classname == "monster_shambler")						
						T_Damage (head, attacker, attacker, points*0.5);
					else
						T_Damage (head, attacker, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};
*/
// END_MOD

