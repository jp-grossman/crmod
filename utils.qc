//
// Utils.qc
//
// This file contains a bunch of useful definitions and utilities.
//
// All code by J.P. Grossman unless otherwise commented.
//

void (string s1, string s2) localcmd2 =
{
    localcmd(s1);localcmd(s2);
};

void (string s1, string s2, string s3) localcmd3 =
{
    localcmd(s1);localcmd(s2);localcmd(s3);
};

void (string s1, string s2, string s3, string s4) localcmd4 =
{
    localcmd(s1);localcmd(s2);localcmd(s3);localcmd(s4);
};

void (string s1, string s2, string s3, string s4, string s5) localcmd5 =
{
    localcmd(s1);localcmd(s2);localcmd(s3);localcmd(s4);localcmd(s5);
};

void (string s1, string s2, string s3, string s4, string s5, string s6) localcmd6 =
{
    localcmd(s1);localcmd(s2);localcmd(s3);localcmd(s4);localcmd(s5);localcmd(s6);
};

void (string s1, string s2, string s3, string s4, string s5, string s6, string s7) localcmd7 =
{
    localcmd(s1);localcmd(s2);localcmd(s3);localcmd(s4);localcmd(s5);localcmd(s6);localcmd(s7);
};

void (string s1) announce =
{
	bprint(#, "\n");
	dprint(#, #);
};

void (string s1, string s2) announce2 =
{
	bprint(#, #, "\n");
	dprint(#, #, #);
};

void (string s1, string s2, string s3) announce3 =
{
	bprint(#, #, #, "\n");
	dprint(#, #, #, #);
};

void (string s1, string s2, string s3, string s4) announce4 =
{
	bprint(#, #, #, #, "\n");
	dprint(#, #, #, #, #);
};

void (string s1, string s2, string s3, string s4, string s5) announce5 =
{
	bprint(#, #, #, #, #, "\n");
	dprint(#, #, #, #, #, #);
};

void (string s1, string s2, string s3, string s4, string s5, string s6) announce6 =
{
	bprint(#, #, #, #, #, #, "\n");
	dprint(#, #, #, #, #, #, #);
};

void (string s1, string s2) oprint2 = 
{
	local entity o;

	o = find(world, classname, "player");
	while (o)
	{
		if ((o.style & ELOHIM_CONNECTED) && (o.style & ELOHIM_OBSERVER) && (o.oflags & OBSERVER_COMMENTARY))
			sprint(o, s1, s2);
		o = find(o, classname, "player");
	}
};

void (string s1, string s2, string s3) oprint3 = 
{
	local entity o;

	o = find(world, classname, "player");
	while (o)
	{
		if ((o.style & ELOHIM_CONNECTED) && (o.style & ELOHIM_OBSERVER) && (o.oflags & OBSERVER_COMMENTARY))
			sprint(o, s1, s2, s3);
		o = find(o, classname, "player");
	}
};

void (string s1, string s2, string s3, string s4) oprint4 = 
{
	local entity o;

	o = find(world, classname, "player");
	while (o)
	{
		if ((o.style & ELOHIM_CONNECTED) && (o.style & ELOHIM_OBSERVER) && (o.oflags & OBSERVER_COMMENTARY))
			sprint(o, s1, s2, s3, s4);
		o = find(o, classname, "player");
	}
};

void (string s1, string s2, string s3, string s4, string s5) oprint5 = 
{
	local entity o;

	o = find(world, classname, "player");
	while (o)
	{
		if ((o.style & ELOHIM_CONNECTED) && (o.style & ELOHIM_OBSERVER) && (o.oflags & OBSERVER_COMMENTARY))
			sprint(o, s1, s2, s3, s4, s5);
		o = find(o, classname, "player");
	}
};

void (string s1, string s2, string s3, string s4, string s5, string s6) oprint6 = 
{
	local entity o;

	o = find(world, classname, "player");
	while (o)
	{
		if ((o.style & ELOHIM_CONNECTED) && (o.style & ELOHIM_OBSERVER) && (o.oflags & OBSERVER_COMMENTARY))
			sprint(o, s1, s2, s3, s4, s5, s6);
		o = find(o, classname, "player");
	}
};

void (string s) changelevel =
{
	if (elohim_levelcount != -1)
	{
		dprint("changelevel: still checking levels.cfg\n");
		return;
	}

	if (s == "")
		localcmd("changelevel dm3\n");
	else
		localcmd3("changelevel ", s, "\n");
};

//
//  B P R I N T  F L O A T
//
//  Broadcasts a float followed by a CR.
//
void (float f) utils_bprint_float =
{
    bprint(ftos(#), "\n");
};

//
//  P R I N T  F L O A T
//
//  Prints a float followed by CR to 'self'.
//
void (float f) utils_print_float =
{
    local string s;

    s = ftos(#);
    sprint(self, s, "\n");
};

//
//  P R I N T  F L O A T N
//
//  Prints a float with up to n decimal digits followed by CR to self
//
void (float f, float n) utils_print_floatn = 
{
	local string s;
	local float temp;
	local float factor;

	temp = floor(#);
	if (f == temp)
	{
		utils_print_float(#);
		return;
	}
	s = ftos(temp);
	sprint(self, s, ".");
	f = f - temp;

	factor = 1;
	while (n)
	{
		factor = 10 * factor;
		n = n - 1;
	}
	f = floor(factor * f + 0.5);

	while (factor)
	{
		factor = floor(factor / 10);
		temp = floor(f / factor);
		f = f - temp * factor;
		if (!f)
			factor = 0;
		s = ftos(temp);
		sprint(self, s);
	}
	sprint(self, "\n");
};

//
//  P R I N T  I N T 3
//
//  Prints a 3 character integer to 'self'.
//
void (float f) utils_print_int3 =
{
    local float n;
    local string s;

    n = rint(#);
    if (n < 0)
    {
        if (n < -99)
            sprint(self, "-99");
        else if (n > -10)
            sprint(self, " ");
    }
    else
    {
        if (n < 100)
            sprint(self, " ");
        if (n < 10)
            sprint(self, " ");
    }
    s = ftos(n);
    sprint(self, s);
};

//
//  P R I N T  I N T 3  G O L D
//
//  Prints a gold 3 character integer to 'self'.
//
void (float f) utils_print_int3_gold = 
{
	local float n, d, temp;
	local string s;

	n = rint(#);
	temp = d = floor(n / 100);
	n = n - d * 100;
	if (d)
		s = strings_ftos_gold(d);
	else
		s = " ";
	sprint(self, s);

	d = floor(n / 10);
	n = n - d * 10;
	if (temp || d)
		s = strings_ftos_gold(d);
	else 
		s = " ";
	sprint(self, s);

	s = strings_ftos_gold(n);
	sprint(self, s);
};

//
//  C P R I N T  I N T 3
//
//  Prints a 3 character integer to the console.
//
void (float f) utils_cprint_int3 =
{
    local float n;

    n = rint(#);
    if (n < 0)
    {
        if (n < -99)
		{
            dprint("-99");
			return;
		}
        else if (n > -10)
            dprint(" ");
    }
    else
    {
        if (n < 100)
            dprint(" ");
        if (n < 10)
            dprint(" ");
    }
	dprint(ftos(n));
};

void (float f) utils_print_int5_gold =
{
   	local float n;
   	local float d;
   	local float temp;
   	local string s;

	n = rint(#);

//-- f>10000
   	d = floor(n / 10000);
   	temp = floor(n / 10000);
   	s = " ";
   	if (d) s = strings_ftos_gold(d);
        else if (f >= 10000)  s="’";
	n = n - (d * 10000);
  	sprint(self, s);

//-- f>1000
	d = floor(n / 1000);
   	temp = floor(n / 1000);
   	s = " ";
   	if (d)  s = strings_ftos_gold(d);
           else if (f >= 1000) s="’";
     	n = n - (d * 1000);
  	sprint(self, s);
  	
//-- f>100
   	d = floor(n / 100);
   	temp = floor(n / 100);
   	s = " ";
   	if (d)  s = strings_ftos_gold(d);
           else if (f >= 100)  s="’";
   	n = n - (d * 100);
  	sprint(self, s);
  	
//-- f>10
   	d = floor(n / 10);
           s = " ";
   	if (temp || d) 	s = strings_ftos_gold(d);
   	else if (f >= 10) s="’";
           n = n - (d * 10);     
   	sprint(self, s);
   	
// < 10   	
   	s = strings_ftos_gold(n);
   	sprint(self, s);
};

void (float f) utils_cprint_int5 =
{
   	local float n;
   	local float d;
   	local float temp;
   	local string s;

	n = rint(#);

//-- f>10000
   	d = floor(n / 10000);
   	temp = floor(n / 10000);
   	s = " ";
   	if (d) s = ftos(d);
        else if (f >= 10000)  s="0";
	n = n - (d * 10000);
  	dprint(s);

//-- f>1000
	d = floor(n / 1000);
   	temp = floor(n / 1000);
   	s = " ";
   	if (d) s = ftos(d);
           else if (f >= 1000) s="0";
     	n = n - (d * 1000);
  	dprint(s);
  	
//-- f>100
   	d = floor(n / 100);
   	temp = floor(n / 100);
   	s = " ";
   	if (d) s = ftos(d);
           else if (f >= 100)  s="0";
   	n = n - (d * 100);
  	dprint(s);
  	
//-- f>10
   	d = floor(n / 10);
           s = " ";
   	if (temp || d) s = ftos(d);
   	else if (f >= 10) s="0";
           n = n - (d * 10);     
  	dprint(s);
   	
// < 10   	
   	s = ftos(d);
  	dprint(s);
};

//
//  P R I N T  V E C
//
//  Prints a vector followed by CR to 'self'.
//  Used for debugging.
//
void (vector v) utils_print_vec =
{
    local string s;

    s = vtos(#);
    sprint(self, s, "\n");
};

//
//  P R I N T  B I T
//
//  Prints a single bit to 'self'.
//  Used for debugging.
//
void (float b) utils_print_bit =
{
    if (b)
        sprint(self, "1");
    else
        sprint(self, "0");
};

//
//  P R I N T  B I N
//
//  Prints a binary number followed by CR to 'self'.
//  Used for debugging.
//
void (float n) utils_print_bin =
{
    local float bit;

    if (!n)
    {
        sprint(self, "0\n");
        return;
    }

    bit = 32768 * 32768 * 2;
    while (bit > 0.5)
    {
        if (n & bit)
        {
            while (bit > 0.5)
            {
                utils_print_bit(n & bit);
                bit = bit / 2;
            }
        }
        bit = bit / 2;
    }
    sprint(self, "\n");
};

//
//  D U M P  P O S I T I O N
//
//  Dumps all 3d position information for an entity to 'self'.
//  Used for debugging.
//
void (entity e) utils_dump_position =
{
    sprint(self, "origin = ");
    utils_print_vec(e.origin);
    sprint(self, "mins = ");
    utils_print_vec(e.mins);
    sprint(self, "maxs = ");
    utils_print_vec(e.maxs);
    sprint(self, "size = ");
    utils_print_vec(e.size);
    sprint(self, "absmin = ");
    utils_print_vec(e.absmin);
    sprint(self, "absmax = ");
    utils_print_vec(e.absmax);
};

//
//  M I N
//
float (float a, float b) utils_min =
{
    if (a < b)
        return a;
    return b;
};

//
//  M A X
//
float (float a, float b) utils_max =
{
    if (a > b)
        return a;
    return b;
};

//
//  M I N 3
//
float (float a, float b, float c) utils_min3 =
{
    local float d;
    if (a < b)
        d = a;
    else
        d = b;
    if (d < c)
        return d;
    return c;
};

//
//  M A X 3
//
float (float a, float b, float c) utils_max3 =
{
    local float d;
    if (a > b)
        d = a;
    else
        d = b;
    if (d > c)
        return d;
    return c;
};

//
//  M A K E  S C H E D U L E D  E V E N T
//
//  Creates a new dynamic entity which will call the given
//  think function after the given amout of time; the entity's
//  owner is 'self'.
//
entity (void() think_function, float think_time) utils_make_scheduled_event =
{
    local entity temp;
    temp = spawn();
    temp.classname = "elohim_temp";
    temp.owner = self;
    temp.nextthink = time + think_time;
    temp.think = think_function;
    return temp;
};

//
//  S E T  C V A R
//
//  Set the console variable 'var' to 'value'.
//
void (string var, float value) utils_set_cvar =
{
    local string temp;

    temp = ftos(value);
    cvar_set(var, temp);
};

//
//  D O  I T E M
//
//  Do something to all items of the given type.  For each item,
//  'dofunc()' is called with 'self' pointing to the item.
//
void (void () dofunc, string item_name) utils_do_item =
{
    local entity oldself;

    oldself = self;
    self = find(world, classname, item_name);
    while (self)
    {
        dofunc();
        self = find(self, classname, item_name);
    }
    self = oldself;
};

//
//  D O  I T E M S
//
//  Do the same thing to all respawnable items.
//
void (void () dofunc) utils_do_items =
{
    utils_do_item(dofunc, "item_health");
    utils_do_item(dofunc, "item_armor1");
    utils_do_item(dofunc, "item_armor2");
    utils_do_item(dofunc, "item_armorInv");
    utils_do_item(dofunc, "item_shells");
    utils_do_item(dofunc, "item_spikes");
    utils_do_item(dofunc, "item_rockets");
    utils_do_item(dofunc, "item_cells");
    utils_do_item(dofunc, "weapon_nailgun");
    utils_do_item(dofunc, "weapon_supernailgun");
    utils_do_item(dofunc, "weapon_supershotgun");
    utils_do_item(dofunc, "weapon_rocketlauncher");
    utils_do_item(dofunc, "weapon_grenadelauncher");
    utils_do_item(dofunc, "weapon_lightning");
    utils_do_item(dofunc, "item_sigil");
    utils_do_item(dofunc, "item_artifact_invulnerability");
    utils_do_item(dofunc, "item_artifact_envirosuit");
    utils_do_item(dofunc, "item_artifact_invisibility");
    utils_do_item(dofunc, "item_artifact_super_damage");
};

//
//  D O  P R O J E C T I L E S
//
//  Do the same thing to all rockets, grenades and nails.
//
void (void () dofunc) utils_do_projectiles = 
{
	utils_do_item(dofunc, "missile");
	utils_do_item(dofunc, "grenade");
	utils_do_item(dofunc, "spike");
};

//
//  D O  P L A Y E R S
//
//  Do the same thing to all connected players.  For each player,
//  'dofunc()' is called with 'self' pointing to the player.
//
void (void () dofunc) utils_do_players =
{
    local entity oldself;

    oldself = self;
    self = find(world, classname, "player");
    while (self)
    {
        if (self.style & ELOHIM_CONNECTED)
            dofunc();
        self = find(self, classname, "player");
    }
    self = oldself;
};

//
//  S T O F
//
//  Convert a string to a float.
//
float (string s) utils_stof =
{
    cvar_set("scratch3", s);
    return cvar(#);
};

// CRMOD
//  V I S I B L E
//    by Paul Baker
//
//    returns 1 if the entity a can see entity b.
//
float (entity a, entity b) utils_visible =
{
	traceline (a.origin, b.origin, TRUE, a);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

//
//  N E W  V I S I B L E
//     by Paul Baker
//
//  Corrected and optimized by J.P.
//
//  Return TRUE if entity a can 'see' entity b.
//
float (entity a, entity b) utils_new_visible =
{
	local float dist;
	local float crosswater;

	// First trace as far as we can, keeping track of crosswater
	crosswater = 0;
	trace_ent = a;
	trace_fraction = 0;
	while ((trace_ent != world) && (trace_fraction < 1.0))
	{
		traceline(trace_ent.origin, b.origin, TRUE, trace_ent);
		if (trace_inopen && trace_inwater)
			crosswater = 1;
	}

	// If we can see all the way to the player, return 4 - crosswater
	if (trace_fraction == 1.0)
		return (4 - crosswater);

	// If the player is right on the other side of the wall, return 2 - crosswater
    dist = vlen(trace_endpos - b.origin);
	if (dist < 200)
		return (2 - crosswater);

	// Otherwise, player is not visible at all
	return 0;
};


// CRMOD
//  T O G G L E  O F L A G
//    by Paul Baker
//
//  Toggles the specified flag in self.oflags
//
void (float flag, string name) utils_toggle_oflag = 
{
	if (self.oflags & flag)
	{
		self.oflags = self.oflags - flag;
		sprint(self, name, " disabled\n");
	}
	else
	{
		self.oflags = self.oflags | flag;
		sprint(self, name, " enabled\n");
	}
};

//
//  T O G G L E  F L A G
//
//  Toggles the specified flag in self.style
//
void (float flag, string name) utils_toggle_flag = 
{
	if (self.style & flag)
	{
		self.style = self.style - flag;
		sprint(self, name, " disabled\n");
	}
	else
	{
		self.style = self.style | flag;
		sprint(self, name, " enabled\n");
	}
};

//
//  S E T  F L A G
//
//  Sets the specified flag in self.style if it is not already set
//
void (float flag, string name) utils_set_flag = 
{
	if (!(self.style & flag))
	{
		self.style = self.style | flag;
		sprint(self, name, " enabled\n");
	}
};

//
//  T O G G L E  S F L A G
//
//  Toggles the specified flag in elohim_playmode
//
void (float flag, string name) utils_toggle_sflag = 
{
	if (elohim_playmode & flag)
	{
		elohim_playmode = elohim_playmode - flag;
		announce2(name, " disabled");
	}
	else
	{
		elohim_playmode = elohim_playmode | flag;
		announce2(name, " enabled");
	}
    utils_set_cvar("samelevel", elohim_playmode);
};

// CRMOD
// S T U F F  T O  P L A Y E R
//      by Paul Baker
//
//   stuffcmd's a message to the player by their entity number (status number).
//   this is used primarily to tell a person they've been kicked.
//

void (float i, string txt) utils_stuff_to_player =
{
	local entity e;
	e = find(world, classname, "player");
	while (e != world)
	{
		if (e.colormap == i)
		{
			stuffcmd(e, txt);
			return;
		}
		e = find(e, classname, "player");
	}
};

//
//  G E T  B I T
//
//  Returns 1 << index
//
float (float index) utils_get_bit =
{
	local float bit;

	if (index & 8)
		bit = 256;
	else
		bit = 1;
	if (index & 4)
		bit = bit * 16;
	if (index & 2)
		bit = bit * 4;
	if (index & 1)
		bit = bit * 2;
	return bit;
};

//
//  F I N D  Z E R O
//
//  Returns the index of the first zero in a binary number
//
float (float num) utils_find_zero = 
{
	local float bit, index;

	index = 0;
	bit = 1;
	while (num & bit)
	{
		bit = bit * 2;
		index = index + 1;
	}
	return index;
};

//
//  I L L E G A L  N A M E
//
//  Returns TRUE if the client name is illegal, FALSE otherwise.
//
float (string cname) utils_illegal_name = 
{
    if (cname == "" || cname == "unconnected")
		return TRUE;
	return FALSE;
};

//
//  I N C R E M E N T  D E V E L O P E R
//
void () utils_increment_developer = 
{
	local float d;

	d = cvar("developer");
	utils_set_cvar("developer", d+1);
};

//
//  D E C R E M E N T  D E V E L O P E R
//
void () utils_decrement_developer = 
{
	local float d;

	d = cvar("developer");
	utils_set_cvar("developer", d - 1);
};

