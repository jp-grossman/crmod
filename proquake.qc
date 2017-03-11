//
// ProQuake.qc
//
// ProQuake interface
//

float	MOD_PROQUAKE	= 1;

float	PQC_NOP			= 1;
float	PQC_NEW_TEAM	= 2;
float	PQC_ERASE_TEAM	= 3;
float	PQC_TEAM_FRAGS	= 4;
float	PQC_MATCH_TIME	= 5;
float	PQC_MATCH_RESET	= 6;
float	PQC_PING_TIMES	= 7;

//
//  W R I T E  B Y T E
//
void (float msg_dest, float b) proquake_write_byte = 
{
	WriteByte(#, 16 + (b / 16));
	WriteByte(#, 16 + (b & 15));	
};

//
//  W R I T E  S H O R T
//
void (float msg_dest, float s) proquake_write_short = 
{
	proquake_write_byte(#, s / 256);
	proquake_write_byte(#, s & 255);
};

//
//  N E W  T E A M
//
void (float msg_dest, float tnum, float shirt) proquake_new_team = 
{
	WriteByte(#, SVC_STUFFCMD);
	WriteByte(#, MOD_PROQUAKE);
	WriteByte(#, PQC_NEW_TEAM);
	WriteByte(#, tnum + 16);
	WriteByte(#, shirt + 16);
	WriteByte(#, 0);
};

//
//  E R A S E  T E A M
//
void (float tnum) proquake_erase_team = 
{
	WriteByte(MSG_ALL, SVC_STUFFCMD);
	WriteByte(#, MOD_PROQUAKE);
	WriteByte(#, PQC_ERASE_TEAM);
	WriteByte(#, tnum + 16);
	WriteByte(#, 0);
};

//
//  S E N D  T E A M  F R A G S
//
void (float msg_dest, float tnum, float tfrags) proquake_send_team_frags = 
{
	WriteByte(#, SVC_STUFFCMD);
	WriteByte(#, MOD_PROQUAKE);
	WriteByte(#, PQC_TEAM_FRAGS);
	WriteByte(#, tnum + 16);
	if (tfrags < 0)
		tfrags = tfrags + 65536;
	proquake_write_short(#, tfrags);
	WriteByte(#, 0);
};

//
//  S E N D  M A T C H  T I M E
//
void (float minutes, float seconds) proquake_send_match_time = 
{
	WriteByte(MSG_ALL, SVC_STUFFCMD);
	WriteByte(#, MOD_PROQUAKE);
	WriteByte(#, PQC_MATCH_TIME);
	proquake_write_byte(#, minutes);
	proquake_write_byte(#, seconds);
	WriteByte(#, 0);
};

//
//  S E N D  M A T C H  R E S E T
//
void () proquake_send_match_reset = 
{
	WriteByte(MSG_ALL, SVC_STUFFCMD);
	WriteByte(#, MOD_PROQUAKE);
	WriteByte(#, PQC_MATCH_RESET);
	WriteByte(#, 0);
};

//
//  S E N D  P I N G  T I M E S
//
void () proquake_send_ping_times = 
{
	local entity player;
	local float i, ping;

	WriteByte(MSG_ALL, SVC_STUFFCMD);
	WriteByte(#, MOD_PROQUAKE);
	WriteByte(#, PQC_PING_TIMES);
	player = find(world, classname, "player");
	while (player)
	{
		ping = 0;
		for (i = 0 ; i < %16 ; i = i + %1)
			ping = ping + player.cl[i + CL_PING_TIMES];
		ping = ping * 1000 / 16;
		if (ping < 1)
			ping = 1;
		if (ping > 4095)
			ping = 4095;
		ping = ping + ((player.colormap - 1) * 4096);
		proquake_write_short(MSG_ALL, ping);
		player = find(player, classname, "player");
	}
	proquake_write_short(MSG_ALL, 0);
	WriteByte(#, 0);
};

//
//  C O N N E C T  T H I N K
//
void () proquake_connect_think = 
{
	local entity t;
	local float tfrags;

	if ((elohim_playmode & ELOHIM_MATCH_MODE) && teamplay)
	{
		for (t = elohim_sentinel.next_team ; t ; t = t.next_team)
		{
			msg_entity = self.owner;
			proquake_new_team(MSG_ONE, t.height, t.colormap);
			proquake_send_team_frags(#, t.height, t.frags);
		}
	}
	remove(self);
};

//
//  C L I E N T  C O N N E C T
//
void () proquake_client_connect = 
{
	utils_make_scheduled_event(proquake_connect_think, 1);
};