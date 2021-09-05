//
// name.qc
//
// name_fix and supporting routines
//

void () score_name_change;
void (float client, string name) score_write_name;

//
//  R E M O V E  B A D  C H A R S
//
void () name_remove_bad_chars = 
{
	local float p;

	p = &self.pname;
	if (BIG_ENDIAN)
		p = AddInt(p, %-3);
	&%556 = %0;	
	while (1)
	{
		(*B457L463)[0] = (*p)[0];
		if (!world[%115])
			return;
		if ((world[%115] < %3) || (world[%115] == %10))
			&%556 = ' ';
		else if (world[%115] == %13)
			&%556 = %141;
		else if (world[%115] == '"')
			&%556 = ''';
		(*p)[0] = (*B457L463)[0];
		p = AddInt(p, %1);
	}		
};

//
//  M A K E  N A M E 1 5
//
void () name_make_name15 = 
{
	local float p, i, end;

	p = AddInt(&self.name15, PSTRING_TO_PQUAKEC);
	if (BIG_ENDIAN)
		p = AddInt(p, %-3);
	&%556 = %0;
	end = 0;
	for (i = 0 ; i < 15 ; i = i + 1)
	{
		(*B457L463)[0] = (*p)[0];
		if (!world[%115])
			end = 1;
		if (end)
		{
			&%556 = ' ';
			(*p)[0] = (*B457L463)[0];
		}
		p = AddInt(p, %1);
	}
	(*B457L463)[0] = (*p)[0];
	&%556 = 0;
	(*p)[0] = (*B457L463)[0];
};

string DEQUAKE = 
" #### #### # >..[]0123456789.<->"
" !`#$%&'()*+,-./0123456789:;<=>?"
"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
"'abcdefghijklmnopqrstuvwxyz{|}~<"
"(=)## #### # >..[]0123456789.<->"
" !`#$%&'()*+,-./0123456789:;<=>?"
"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
"'abcdefghijklmnopqrstuvwxyz{|}~<";

//
//  M A K E  N A M E 1 5 T E X T
//
void () name_make_name15text = 
{
	local float p, i, p2;

	p = AddInt(&self.name15text, PSTRING_TO_PQUAKEC);
	if (BIG_ENDIAN)
		p = AddInt(p, %-3);
	for (i = 0 ; i < 15 ; i = i + 1)
	{
		&%556 = %0;
		(*B457L463)[0] = (*p)[0];
		p2 = AddInt(&DEQUAKE[world[%115]], PSTRING_TO_PQUAKEC);
		if (!BIG_ENDIAN)
			p2 = AddInt(p2, %-3);
		&%556 = (*p2)[0];
		(*p)[0] = (*B457L463)[0];
		p = AddInt(p, %1);
	}
};

//
//  B R O A D C A S T
//
void (string name) name_broadcast = 
{
	WriteByte(MSG_ALL, SVC_UPDATENAME);
	WriteByte(MSG_ALL, self.colormap - 1);
	WriteString(MSG_ALL, name);
};

//
//  F I X
//
void () name_fix = 
{
	local entity p, p2;

	if (self.netname == "Ž\bMephistopheles")  // My very own hack :)
	{
		strcpy(self.netname, " Elohim\b\.Mephistopheles");
		strcpy(self.name15, " Mephistopheles");
		strcpy(self.name15text, " Mephistopheles");
		if (self.oflags & ELOHIM_AFK)
			strcpy(self.name_ready, "\b\.Mephistopheles AFK");
		else
			strcpy(self.name_ready, "\b\.Mephistopheles READY");
		self.pname = *AddInt(&self.name15, PSTRING_TO_PQUAKEC); // hack to avoid calling name_fix
	}
	else
	{
		self.pname = *AddInt(&self.netname, PSTRING_TO_PQUAKEC); // needed because of the hack

		name_remove_bad_chars();

		// make copies 
		p = *AddInt(&self.name15, PSTRING_TO_PQUAKEC);
		p^[%0] = self.pname^[%4] = self.pname^[%0];
		p[%3] = self.pname[%7] = self.pname[%3];

		// make name15
		name_make_name15();

		// make more copies
		p^[%4] = p^[%8] = p^[%0];
		p[%7] = p[%11] = p[%3];

		// make name15text
		name_make_name15text();

		// make name_ready
		if (self.oflags & ELOHIM_AFK)
			p2 = *AddInt(&"\b AFK", PSTRING_TO_PQUAKEC);
		else
		{
			if (self.elohim_player_id)
			{
				p2 = *AddInt(&" READY", PSTRING_TO_PQUAKEC);//Sputnik, use White chars if they are logged in, bronze if they aren't.
			}
			else
				p2 = *AddInt(&"\b READY", PSTRING_TO_PQUAKEC);
		}
		p = *AddInt(&p, %47);
		p[0] = p2[0];
		p[%1] = p2[%1];
	}

/*
	dprint("name       = '", self.netname, "'\n");
	dprint("name15     = '", self.name15, "'\n");
	dprint("name15text = '", self.name15text, "'\n");
	dprint("name_ready = '", self.name_ready, "'\n");
	bprint("name_fix: fixed name\n");
*/

	if (((elohim_playmode & ELOHIM_MATCH_MODE) && !(elohim_state & ELOHIM_MATCH_STARTED) && (self.style & ELOHIM_READY)) || (self.oflags & ELOHIM_AFK))
		name_broadcast(self.name_ready);
	else
		name_broadcast(self.netname);
	score_name_change();
};

//
//  S E N D  N A M E S
//
//  Called after a new client connects or after the teamscores are removed
//  to put back special names (for now, just ready names)
//
void () name_send_names = 
{
	local entity e;

	if ((elohim_playmode & ELOHIM_MATCH_MODE) && !(elohim_state & ELOHIM_MATCH_STARTED))
	{
		msg_entity = self;
		for (e = elohim_sentinel.next_player ; e ; e = e.next_player)
		{
			if (e.style & ELOHIM_READY)
				score_write_name(e.colormap - 1, e.name_ready);
		}
	}
};