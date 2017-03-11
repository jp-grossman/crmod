//
// Motd.qc
//
// Message of the day code.  I created a whole new file so that it would
// be easier to beef up the motd.
//
// All code by J.P. Grossman unless otherwise commented.
//

string motd_top1;
string motd_top2;
string motd_top3;
string motd_top4;
string motd_top5;
string motd_top6;
string motd_top7_1;
string motd_top7_2;
string motd_top7_3;
string motd_top7_4;
string motd_top7_5;
string motd_top7_6;
string motd_bottom;

//
//  I N I T  W O R L D
//
//  Initialize the motd strings
//
void () motd_init_world =
{
    motd_top1 = "€‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€‚\n";
    motd_top2 = "€‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€‚\n\n";
    motd_top3 = "€‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€‚\n\n\n";
    motd_top4 = "€‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€‚\n\bhttp://planetquake.com/crmod\n\n\n";
    motd_top5 = "€‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€‚\nby J.P. Grossman\n\bhttp://planetquake.com/crmod\n\n\n";
    motd_top7_1 = "€ƒ‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€ƒ‚\n\nby J.P. Grossman\n\bhttp://www.crmod.com\n\n\n";
    motd_top7_2 = "€ƒ‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€ƒ‚\n\nby J.P. Grossman\n\bhttp://www.crmod.com\n\n\n";
    motd_top7_3 = "€ƒ‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€ƒ‚\n\nΫ by J.P. Grossman έ\nΫ \bhttp://www.crmod.com έ\n\n\n";
    motd_top7_4 = "€ƒ‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€ƒ‚\n\nby J.P. Grossman‘\n\bhttp://www.crmod.com‘\n\n\n";
    motd_top7_5 = "€ƒ‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€ƒ‚\n\nby J.P. Grossman‘\n\bhttp://www.crmod.com‘\n\n\n";
    motd_top7_6 = "€ƒ‚ΓμαξÒιξη ΓÒΝοδ«« Φ®—€ƒ‚\n\nΫ by J.P. Grossman έ\nΫ \bhttp://www.crmod.com έ\n\n\n";
    motd_bottom = "€‚";
};

void () motd_think =
{
	if (self.count == 0)
	{
		if (self.owner.style & ELOHIM_MOTD)
		{
			remove(self);
			return;
		}
		self.owner.button0 = 0;
	}

	// Remove the MOTD on fire or jump
	if (self.owner.button0 || self.owner.button2)
	{
		self.count = 26;
		self.cnt = 5;
	}

    self.owner.style = self.owner.style | ELOHIM_MOTD;

    if (self.count < 26)
    {	
		if (self.count == 0)
		{
			centerprint(self.owner, "no bots"); // to kick stoogebots
			centerprint(self.owner, "€‚\n\n\n\n");
		}

		else if (self.count == 1)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 2)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 3)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 4)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 5)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 6)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 7)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 8)
			centerprint(self.owner, "€‚\n\n\n\n");
		else if (self.count == 9)
			centerprint(self.owner, "€‚Ò€‚\n\n\n\n");
		else if (self.count == 10)
			centerprint(self.owner, "€‚ ΓÒΝο€‚\n\n\n\n");
		else if (self.count == 11)
			centerprint(self.owner, "€‚ξη ΓÒΝοδ«€‚\n\n\n\n");
		else if (self.count == 12)
			centerprint(self.owner, "€‚Òιξη ΓÒΝοδ«« €‚\n\n\n\n");
		else if (self.count == 13)
			centerprint(self.owner, "€‚αξÒιξη ΓÒΝοδ«« Φ€‚\n\n\n\n");
		else if (self.count == 14)
			centerprint(self.owner, motd_top1, "\n\n\n");
		else if (self.count == 15)
			centerprint(self.owner, motd_top1, motd_bottom, "\n\n\n");
		else if (self.count == 16)
			centerprint(self.owner, motd_top1, USER_MOTD5_1, motd_bottom, "\n\n");
		else if (self.count == 17)
			centerprint(self.owner, motd_top1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom, "\n");
		else if (self.count == 18)
			centerprint(self.owner, motd_top1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
		else if (self.count == 19)
			centerprint(self.owner, motd_top1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
		else if (self.count == 20)
			centerprint(self.owner, motd_top1, USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
		else if (self.count == 21)
			centerprint(self.owner, motd_top2, USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
		else if (self.count == 22)
			centerprint(self.owner, motd_top3, USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
		else if (self.count == 23)
			centerprint(self.owner, motd_top4, USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
		else if (self.count == 24)
		{
			centerprint(self.owner, motd_top5, USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
			self.count = 25;
		}

		self.nextthink = time + 0.1;

		if (self.count == 15 + NUM_USER_MOTD_LINES)
			self.count = 21;
		else
			self.count = self.count + 1;
	}
	else
	{
		if (self.cnt == 5)
		{
			self.owner.style = self.owner.style - ELOHIM_MOTD;
				centerprint(self.owner, " ");
			remove (self);
		}
		else
		{
			if (self.lip)
				self.lip = self.lip - 1;
			else
			{
				if (self.count == 26)
				{
					centerprint(self.owner, motd_top7_1, USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1, motd_bottom);
					self.cnt = self.cnt + 1;
				}
				else if (self.count == 27)
					centerprint(self.owner, motd_top7_2, USER_MOTD1_2, USER_MOTD2_2, USER_MOTD3_2, USER_MOTD4_2, USER_MOTD5_2, motd_bottom);
				else if (self.count == 28)
					centerprint(self.owner, motd_top7_3, USER_MOTD1_3, USER_MOTD2_3, USER_MOTD3_3, USER_MOTD4_3, USER_MOTD5_3, motd_bottom);
				else if (self.count == 29)
					centerprint(self.owner, motd_top7_4, USER_MOTD1_4, USER_MOTD2_4, USER_MOTD3_4, USER_MOTD4_4, USER_MOTD5_4, motd_bottom);
				else if (self.count == 30)
					centerprint(self.owner, motd_top7_5, USER_MOTD1_5, USER_MOTD2_5, USER_MOTD3_5, USER_MOTD4_5, USER_MOTD5_5, motd_bottom);
				else if (self.count == 31)
					centerprint(self.owner, motd_top7_6, USER_MOTD1_6, USER_MOTD2_6, USER_MOTD3_6, USER_MOTD4_6, USER_MOTD5_6, motd_bottom);

				if (self.count == 31)
					self.count = 26;
				else
					self.count = self.count + 1;

				self.lip = 4;
			}
			self.nextthink = time + 0.1;
		}
    }
};

//
//  C R E A T E
//
//  Create an entity to display the MOTD for 5 seconds (plus a bit).
//
void () motd_create =
{
    local entity intro;
	
	if (elohim_state & ELOHIM_MATCH_PAUSED)
		return;

    intro = utils_make_scheduled_event(motd_think, 0.5);
    intro.count = 0;
    intro.cnt = 0;
	intro.lip = 0;
};


