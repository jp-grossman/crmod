//
// net.qc
//
// Banning and IP stuff
//

void (entity client) elohim_kick_player;

//
//  H I D E  P O R T
//
void (float p) net_hide_port = 
{
	if (BIG_ENDIAN)
		p = AddInt(p, %-3);
	&%556 = %0;
	while (1)
	{
		(*B457L463)[0] = (*p)[0];
		if (!world[%115])
			return;
		else if (world[%115] == ':')
		{
			&%556 = 0;
			(*p)[0] = (*B457L463)[0];
			return;
		}
		p = AddInt(p, %1);
	}		
};

//
//  H I D E  I P
//
void (float p) net_hide_ip = 
{
	local float dotcount, px;

	if (BIG_ENDIAN)
		p = AddInt(p, %-3);
	&%556 = %0;
	dotcount = 0;
	while (1)
	{
		(*B457L463)[0] = (*p)[0];
		if (!world[%115])
			return;
		else if (world[%115] == '.')
		{
			dotcount = dotcount + 1;
			if (dotcount == 3)
			{
				px = AddInt(&"xxx", PSTRING_TO_PQUAKEC);
				if (!BIG_ENDIAN)
					p = AddInt(p, %-3);
				(*p)[%1] = (*px)[0];
				return;
			}
		}
		p = AddInt(p, %1);
	}		
};

//
//  B A N I S H
//
void () net_banish = 
{
	if (self.count)
	{
		elohim_kick_player(self.owner);
		remove(self);
	}
	sprint(self.owner, "You are banned on this server\n");
	stuffcmd(self.owner, "disconnect\n");
	self.owner.cl[CL_SENDSIGNON] = TRUE;
	self.count = 1;
	self.nextthink = time + 0.1;
};

//
//  C O N N E C T
//
//  Returns true for a successful connect, false otherwise
//
float () net_connect = 
{
	local string ip, ip2;
	local float p;
	local float i;

	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		zone_check_clear();

		for (i = %0 ; i < zone_vars[ZONE_NUM_BANS] ; i = i + %1)
		{
			if (*AndInt(zone_ban_mask[i], self.qs[QS_IN_ADDR]) == *zone_ban_ip[i])
			{
				utils_make_scheduled_event(net_banish, 0);
				return FALSE;
			}
		}
	}

	p = AddInt(&self.qs, QS_ADDRESS * 4);
	ip = @AddInt(p, PQUAKEC_TO_PSTRING);
	ip2 = @AddInt(&ip, %32);
	dprint(self.netname, " connected from ", ip, "\n");

	strcpy(ip2, ip);

	// fix end of ip address
	net_hide_ip(p);
	net_hide_port(AddInt(p, %32));

	return TRUE;
};

//
//  G E T  B A N  N A M E
//
string (float i) net_get_ban_name = 
{
	return @AddInt(AddInt(zone_ban_names, 16 * i), PQUAKEC_TO_PSTRING);
};

//
//  G E T  B A N  N A M E  T E X T
//
string (float i) net_get_ban_name_text = 
{
	return @AddInt(AddInt(zone_ban_names_text, 16 * i), PQUAKEC_TO_PSTRING);
};

//
//  C P R I N T  I P
//
void (float ip, float mask) net_dprint_ip = 
{
	local float n;

	n = GetLow(ip) / %1;
	dprint(ftos(n & 255), ".");
	dprint(ftos(floor(n / 256)), ".");
	if (*mask == *IP_MASK2)
	{
		dprint("xxx.xxx");
		return;
	}
	n = GetHigh(ip) / %1;
	dprint(ftos(n & 255), ".");
	if (*mask == *IP_MASK1)
	{
		dprint("xxx");
		return;
	}
	dprint(ftos(floor(n / 256)));
};

//
//  S P R I N T  I P
//
void (float ip, float mask) net_sprint_ip = 
{
	local float n;
	local string s;

	n = GetLow(ip) / %1;
	s = ftos(n & 255);
	sprint(self, s, ".");
	s = ftos(floor(n / 256));
	sprint(self, s, ".");
	if (*mask == *IP_MASK2)
	{
		sprint(self, "xxx.xxx");
		return;
	}
	n = GetHigh(ip) / %1;
	s = ftos(n & 255);
	sprint(self, s, ".");
	if (*mask == *IP_MASK1)
	{
		sprint(self, "xxx");
		return;
	}
	s = ftos(floor(n / 256));
	sprint(self, s);
};

//
//  G E T  B A N  S L O T
//
float () net_get_ban_slot = 
{
	if (zone_vars[ZONE_NUM_BANS] < %128)
		return zone_vars[ZONE_NUM_BANS];

	dprint("No more ban slots available\n");
	return %127;
};

//
//  B A N  I P
//
void (float ip) net_ban_ip = 
{
	local float i;

	zone_check_clear();
	for (i = %0 ; i < zone_vars[ZONE_NUM_BANS] ; i = i + %1)
	{
		if ((*zone_ban_ip[i] == *ip) && (*zone_ban_mask[i] == *elohim_ban_mask))
			return;
	}

	i = net_get_ban_slot();
	ip = AndInt(ip, elohim_ban_mask);
	zone_ban_ip[i] = ip;
	zone_ban_mask[i] = elohim_ban_mask;
	strcpy(net_get_ban_name(i),      " console ban   ");
	strcpy(net_get_ban_name_text(i), " console ban   ");
	zone_vars[ZONE_NUM_BANS] = i + %1;

	dprint("Banning ");
	net_dprint_ip(ip, elohim_ban_mask);
	dprint("\n");
};

//
//  B A N  I N D E X
//
void (entity e, float i) net_ban_index = 
{
	local float p;

	zone_ban_ip[i] = AndInt(e.qs[QS_IN_ADDR], elohim_ban_mask);
	zone_ban_mask[i] = elohim_ban_mask;
	p = AddInt(AddInt(&e.qs, 4 * QS_ADDRESS + %32), PQUAKEC_TO_PSTRING);
	strcpy(net_get_ban_name(i), e.name15);
	strcpy(net_get_ban_name_text(i), e.name15text);

	dprint("Banning ");
	net_dprint_ip(e.qs[QS_IN_ADDR], elohim_ban_mask);
	dprint("\n");
};

//
//  B A N  T E M P
//
void (entity e) net_ban_temp = 
{
	local float p;

	if (elohim_playmode & ELOHIM_DEDICATED_SERVER)
	{
		zone_check_clear();
		net_ban_index(e, 0);
	}
	p = AddInt(AddInt(&e.qs, 4 * QS_ADDRESS + %32), PQUAKEC_TO_PSTRING);
	localcmd3("ban ", @p, "\n");
};

//
//  B A N
//
void (entity e) net_ban = 
{
	local float i;

	zone_check_clear();
	i = net_get_ban_slot();
	net_ban_index(e, i);
	zone_vars[ZONE_NUM_BANS] = i + %1;
};

//
//  U N B A N  I P
//
void (float ip) net_unban_ip = 
{
	local float i, n, p, found;

	zone_check_clear();

	found = 0;
	n = zone_vars[ZONE_NUM_BANS];
	for (i = %0 ; i < n ; i = i + %1)
	{
		if (*AndInt(zone_ban_mask[i], elohim_ban_mask) == *zone_ban_mask[i])
		{
			if (*AndInt(ip, zone_ban_mask[i]) == *zone_ban_ip[i])
			{
				// remove ban
				found = 1;
				dprint("unbanning ");
				net_dprint_ip(zone_ban_ip[i], zone_ban_mask[i]);
				dprint("\n");
				if (i)
				{
					n = n - %1;
					if (i < n)
					{
						zone_ban_ip[i] = zone_ban_ip[n];
						zone_ban_mask[i] = zone_ban_mask[n];
						p = &net_get_ban_name(n);
						strcpy(net_get_ban_name(i), @p); 
						p = &net_get_ban_name_text(n);
						strcpy(net_get_ban_name_text(i), @p); 
						i = i - %1;
					}
				}
				else
				{
					zone_ban_ip[0] = IP_MASK0;
					zone_ban_mask[0] = 0;
					localcmd("ban 0\n");
				}
			}
		}
	}
	if (!found)
		dprint("unban: not found\n");
	zone_vars[ZONE_NUM_BANS] = n;			
};


