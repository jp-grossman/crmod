//
// Strings.qc
//
// A bunch of routines for returning various strings.
// Several routines were inspired by the clanring server mod.
//
// All code by J.P. Grossman unless otherwise commented.
//

//
//  F T O S  G O L D
//
//  Return some gold number strings.
//
string (float n) strings_ftos_gold =
{
	return "\0":"\1":"\2":"\3":"\4":"\5":"\6":"\7":"\8":"\9"[n * %2];
};

string (float n) strings_ftos_gold2 =
{
    return " \0":" \1":" \2":" \3":" \4":" \5":" \6":" \7":" \8":" \9":
           "\1\0":"\1\1":"\1\2":"\1\3":"\1\4":"\1\5":"\1\6"[n * %3];
};

//
//  G E T  F L A G S
//
//  Returns "[QOR]" where [QOR] are the quad, ring and
//  suit flags (either present or absent).
//
string (entity e) strings_get_flags = 
{
	local float index;

	index = 0;
	if (e.items & IT_SUIT)
		index = index + %8;
	if (e.items & IT_INVISIBILITY)
		index = index + %16;
	if (e.items & IT_QUAD)
		index = index + %32;

	return " \[   \] ":" \[  ソ] ":" \[ \0 \] ":" \[ \0ソ] ":" \[Q  \] ":" \[Q ソ] ":" \[Q\0 \] ":" \[Q\0ソ] "[index];
};

//
//  G E T  W E A P O N
//
string (entity e) strings_get_weapon =
{
    if (e.weapon == 32)   return " Rocket Launcher \n";
    if (e.weapon == 64)   return "  Lightning Gun  \n";
    if (e.weapon == 16)   return " Grenade Launcher\n";
    if (e.weapon == 8)    return "  Super Nailgun  \n";
    if (e.weapon == 2)    return "  Super Shotgun  \n";
    if (e.weapon == 4)    return "     Nailgun     \n";
    if (e.weapon == 1)    return "     Shotgun     \n";
    if (e.weapon == 4096) return "       Axe       \n";
    return "";
};

//
//  G E T  T E A M N A M E
//
//  Return the colour string corresponding to a given team.
//
string (float num) strings_get_teamname =
{
	return "Brown team\{0}    ":"Light Blue team":   "Green team\{0}    ":"Red team\{0}      ":
		   "Olive team\{0}    ":"Gold team\{0}     ":"Flesh team\{0}    ":"Lavender team\{0} ":
		   "Purple team\{0}   ":"Beige team\{0}    ":"Aqua team\{0}     ":"Yellow team\{0}   ":
		   "Blue team\{0}     "[(num - 1) * %16];
};

//
//  G E T  T E A M N A M E  B R O N Z E
//
//  Same as above, but in bronze letters - exactly 15 of them
//  My God, I've gone insane.
//
string (float num) strings_get_teamname_bronze =
{
	return "\bBrown team     ":"\bLight Blue team":"\bGreen team     ":"\bRed team       ":
		   "\bOlive team     ":"\bGold team      ":"\bFlesh team     ":"\bLavender team  ":
		   "\bPurple team    ":"\bBeige team     ":"\bAqua team      ":"\bYellow team    ":
		   "\bBlue team      "[(num - 1) * %16];
};

//
//  G E T  T E A M N A M E 2
//
//  Return the colour string corresponding to a given team.
//  The string contains EXACTLY 10 characters.
//
string (float num) strings_get_teamname2 =
{
    return "Brown     ":"Light Blue":"Green     ":"Red       ":
		   "Olive     ":"Gold      ":"Flesh     ":"Lavender  ":
		   "Purple    ":"Beige     ":"Aqua      ":"Yellow    ":
		   "Blue      "[(num - 1) * %11];
};

//
//  G E T  T E A M N A M E 3
//
//  For when 10 characters is too many.. I can't believe I'm doing this.
//
string (float num) strings_get_teamname3 =
{
    return "Brown   ":"Lt. Blue":"Green   ":"Red     ":
		   "Olive   ":"Gold    ":"Flesh   ":"Lavender":
		   "Purple  ":"Beige   ":"Aqua    ":"Yellow  ":
		   "Blue    "[(num - 1) * %9];
};

//
//  G E T  T E A M N A M E 1 5
//
//  Well I'm getting used to this now..
//
string (float num) strings_get_teamname15 =
{
    return "  Brown        ":"  Light Blue   ":"  Green        ":"  Red          ":
		   "  Olive        ":"  Gold         ":"  Flesh        ":"  Lavender     ":
		   "  Purple       ":"  Beige        ":"  Aqua         ":"  Yellow       ":
		   "  Blue         "[(num - 1) * %16];
};

//
//  G E T  C O L O U R
//
//  Return the colour string corresponding to a given team.
//
string (float num) strings_get_colour =
{
	return "brown\{0}    ":"light blue":   "green\{0}    ":"red\{0}      ":
		   "olive\{0}    ":"gold\{0}     ":"flesh\{0}    ":"lavender\{0} ":
		   "purple\{0}   ":"beige\{0}    ":"aqua\{0}     ":"yellow\{0}   ":
		   "blue\{0}     "[(num - 1) * %11];
};

//
//  G E T  T E A M N A M E  U P  B Y
//
//  Return the "colour up by " string corresponding to a given team.
//
string (float num) strings_get_teamname_up_by =
{
        return "        Brown up by ":"   Light Blue up by ":"        Green up by ":"          Red up by ":
			   "        Olive up by ":"         Gold up by ":"        Flesh up by ":"     Lavender up by ":
			   "       Purple up by ":"        Beige up by ":"         Aqua up by ":"       Yellow up by ":
			   "         Blue up by "[(num - 1) * %21];
};

//
//  G E T  M A P N A M E
//
//  Return the nth map name.
//
string (float mapnum) strings_get_mapname =
{
    if (mapnum <= 10)
    {
        if (mapnum == 0)
            return "start";
        if (mapnum == 1)
            return "start0";
        if (mapnum == 2)
            return "start1";
        if (mapnum == 3)
            return "end";
        return "";
    }
    if (mapnum < 49)
		return	"e1m1":"e1m2":"e1m3":"e1m4":"e1m5":"e1m6":"e1m7":"e1m8":"\{0}   ":"\{0}   ":
				"e2m1":"e2m2":"e2m3":"e2m4":"e2m5":"e2m6":"e2m7":"\{0}   ":"\{0}   ":"\{0}   ": 
				"e3m1":"e3m2":"e3m3":"e3m4":"e3m5":"e3m6":"e3m7":"\{0}   ":"\{0}   ":"\{0}   ": 
				"e4m1":"e4m2":"e4m3":"e4m4":"e4m5":"e4m6":"e4m7":"e4m8"[(mapnum - 11) * %5];
	if (mapnum < 51)
		return "";
	if (mapnum < 57)
		return "dm1":"dm2":"dm3":"dm4":"dm5":"dm6"[(mapnum - 51) * %4];
	if (mapnum < 60)
		return "";
    return @array_user_map[(mapnum - 60) * %1];
};

//
//  G E T  M O D E
//
//  Returns "Normal", "Practice", or "Match".
//
string (float mode) strings_get_mode =
{
	return "Normal\{0}\{0}":"Practice":"Match\{0}\{0}\{0}":"Individual"[mode * %9];
};

//
//  S Z P L U R A L
//
//  Helper string for printing.
//
string (float n) strings_szplural =
{
    if (n == 1)
        return "";
    return "s";
};

//
//  F U N C T I O N  N A M E
//
//  Pass a pointer to the function
//
string (float f) strings_function_name = 
{
	local float p;

	p = AddInt(&progs, progs[PR_OFS_FUNCTIONS]);
	p = AddInt(p, f * 36);
	return @(*p)[%4];
};

