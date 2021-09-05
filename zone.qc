//
// zone.qc
//
// Get at the Hunk internals - find context for our own personal use
//

//
//
//	
//	6144	zone_ban_names_text		(2048)
//	4096	zone_ban_names			(2048)
//	2048	zone_string				(2048)
//	1024	zone_ban_mask			(512)
//	512		zone_ban_ip				(512)
//	0		zone_vars				(512)
//


float ZONE_NUM_BANS =	%0;

entity zone_vars;		// zone variables
entity zone_ban_ip;		// array of banned ips
entity zone_ban_mask;	// array of banned masks
float  zone_ban_names;  // array of banned player names
float  zone_ban_names_text;
float  zone_pcstring;	// used for strcats
float  zone_pstring;	// used for strcats
string zone_string;		// used for strcats
entity zone_player_stat_id; //sput: testing

// used for writing strings
float zone_strlen;
float zone_data;
float zone_cursize;

string hunkname = "HUNKNAME";
string prevname = "PREVNAME";

//
//  C H E C K  C L E A R
//
void () zone_check_clear = 
{
	if (!(elohim_playmode & ELOHIM_DEDICATED_SERVER))
		return;
	if (*zone_vars[ZONE_NUM_BANS] == *0x20202020)
	{
		zone_vars[ZONE_NUM_BANS] = %1;
		zone_ban_ip[0] = IP_MASK0;
		zone_ban_mask[0] = 0;
	}
	if (zone_vars[ZONE_NUM_BANS] > %128)
	{
		InternalError(&zone_check_clear, "Wierd zone_num_bans");
		zone_vars[ZONE_NUM_BANS] = %1;
		zone_ban_ip[0] = IP_MASK0;
		zone_ban_mask[0] = 0;
	}
};

//
//  I N I T  W O R L D
//
void (float context) zone_init_world = 
{
	dprint("Initializing permanent storage\n");

	zone_vars = *context;
	zone_ban_ip = *AddInt(context, %512);
	zone_ban_mask = *AddInt(context, %1024);
	zone_pstring = AddInt(context, %2048);
	zone_pcstring = AddInt(zone_pstring, PQUAKEC_TO_PC);
	zone_string = @AddInt(zone_pstring, PQUAKEC_TO_PSTRING);
	zone_ban_names = AddInt(context, %4096);
	zone_ban_names_text = AddInt(context, %6144);
	zone_player_stat_id = *AddInt(context, %8196);//Sput: testing
	zone_check_clear();
};

//
//  I N I T  L I S T E N
//
void () zone_init_listen = 
{
	zone_vars = *%680;
	zone_pstring = %690;
	zone_pcstring = AddInt(zone_pstring, PQUAKEC_TO_PC);
	zone_string = @AddInt(zone_pstring, PQUAKEC_TO_PSTRING);
};

//
//  G E T  H U N K  N A M E
//
void (float h) zone_get_hunk_name = 
{
	local float p, p2;
	p = AddInt(&hunkname, PSTRING_TO_PQUAKEC);
	p2 = AddInt(&prevname, PSTRING_TO_PQUAKEC);
	(*p2)[%0] = (*p)[%0];
	(*p2)[%1] = (*p)[%1];
	(*p)[%0] = (*h)[%2];
	(*p)[%1] = (*h)[%3];
};

//
//  P R I N T  H U N K
//
void (float h) zone_print_hunk = 
{
	local float samecount;
	local float samesize;

	samecount = 0;
	samesize = 0;

	dprint("--- HUNK ---\n");

	while (1)
	{
		zone_get_hunk_name(h);

		if (hunkname == prevname && (!samecount || samesize == (*h)[%1]))
		{
			samecount = samecount + 1;
			samesize = (*h)[%1];
		}
		else
		{
			if (samecount)
			{
				dprint(ftos(samecount), " x ", prevname, " : ");
				dprint(ftos(samesize / %1), "\n");
			}
			samecount = 1;
			samesize = (*h)[%1];
		}
		if (prevname == "edicts")
			return;

		h = AddInt(h, (*h)[%1]);
	}
};

entity lasth, currh;

//
//  S E A R C H  T H I N K
//
void () zone_search_think;

//
//  S C H E D U L E  T H I N K
//
void () zone_schedule_think = 
{
	local entity e;

	e = spawn();
	while (&e < &self)
	{
		e.think = SUB_Remove;
		e.nextthink = time + 0.2;
		e = spawn();
	}
	e.think = zone_search_think;
	e.nextthink = 0.0001;
};

//
//  S E A R C H  T H I N K
//
void () zone_search_think = 
{
	local float i;

	//dprint("SearchHunk: time = ");
	//dprint(ftos(time), "\n");

	currh = *AddInt(&currh, %-131072);
	for (i = %32764 ; i >= %0 ; i = i - %4)
	{
		if (*currh[i] == *HUNK_SENTINAL)
		{
			if (currh[i + %1] == SubInt(SubInt(&lasth, &currh), 4 * i))
			{
				lasth = *AddInt(&currh, 4 * i);
				zone_get_hunk_name(&lasth);
				if (hunkname == "context")
				{
					zone_init_world(AddInt(&lasth, %16));
					//zone_print_hunk(&lasth);
					remove(self);
					return;
				}
			}
		}
	}

	zone_schedule_think();

	self.think = SUB_Remove;
	self.nextthink = 0.0001;
};

//
//  S E A R C H  H U N K
//
void () zone_search_hunk = 
{
	local entity e;

	//dprint("InitSearchHunk: time = ");
	//dprint(ftos(time), "\n");

	lasth = currh = *AddInt(&progs, %-16);
	zone_schedule_think();
};

//
//  C L E A R  S T R I N G
//
void () zone_clear_string = 
{
	zone_data = sv[SV_SIGNON_DATA];
	zone_cursize = sv[SV_SIGNON_CURSIZE];

	sv[SV_SIGNON_CURSIZE] = 0;
	sv[SV_SIGNON_DATA] = zone_pcstring;

	zone_strlen = 0;
	(*zone_pstring)[0] = 0;
};

//
//  W R I T E  S T R I N G
//
void (string s) zone_write_string = 
{
	WriteString(MSG_INIT, s);
	sv[SV_SIGNON_CURSIZE] = sv[SV_SIGNON_CURSIZE] - %1;
};

//
//  E N D  S T R I N G
//
void () zone_end_string = 
{
	sv[SV_SIGNON_DATA] = zone_data;
	sv[SV_SIGNON_CURSIZE] = zone_cursize;
};
