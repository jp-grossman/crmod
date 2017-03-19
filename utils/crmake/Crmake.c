//
// crmake.c
//
// crmake reads "userdefs.cfg" and incorporates the information into progs.dat
//

#define _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_DEPRECATE

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#define BUFSIZE 16384

char progs[BUFSIZE];	// used to store the beginning of progs.dat
char userdefs[BUFSIZE]; // used to store userdefs.cfg

// buffer locations in progs.dat
char *max_suicides;
char *num_user_motd_lines;
char *user_motd[5][6];
char *user_map[10];
char *qsmack[5];

// used for parsing
char *prch;		// pointer to the next charater in progs
char *uservar;	// pointer to where the next string should be stored
int var_length; // # characters allocated for user variable
int prline = 1; // line number

#define FALSE 0
#define TRUE 1

//
//  D I E
//
//  Print and error message and exit
//
void Die (char *message, ...)
{
	va_list args;

	va_start(args, message);
	fprintf(stderr, "Error: ");
	vfprintf(stderr, message, args);
	va_end(args);
	exit(1);
}

//
//  R E A D  F I L E
//
//  Read the specified file into the specified buffer until EOF or
//  BUFFSIZE characters have been read
//
FILE *ReadFile (char *filename, char *buff)
{
	FILE *file;
	int i, n;

	if ((file = fopen(filename, "r+b")) == NULL)
		Die("Cannot open %s\n", filename);

	printf("Reading %s...\n", filename);

	for (i = 0 ; i < BUFSIZE ; i++)
	{
		if((n = fgetc(file)) == EOF)
		{
			buff[i] = 0;
			return file;
		}
		buff[i] = n;
	}
	buff[BUFSIZE - 1] = 0;

	return file;
}

//
//  S K I P  W H I T E  S P A C E
//
//  Skip white space and keep track of line numbers.
//
void SkipWhiteSpace (void)
{
	while (*prch == ' ' || *prch == '\t' || *prch == '\n' || *prch == '\r')
	{
		if (*prch++ == '\n')
			prline++;
	}
	if (prch[0] == '/' && prch[1] == '/')
	{
		while(*prch++ != '\n')
		{
			if (!*prch)
				return;
		}
		prline++;
		SkipWhiteSpace();
	}
}

//
//  G E T  C H A R
//
//  If the next character is not ch, print an error message and exit.
//
void GetChar (char ch)
{
	if (*prch++ != ch)
		Die("Expected '%c' at line %d\n", ch, prline);
}

//
//  G E T  U S E R  V A R
//
//  Figure out which user variable is being assigned to; set
//  uservar and var_length accordingly.
// 
void GetUserVar (void)
{
	int i, j;

	if (!strncmp(prch, "MAX_SUICIDES", 12))
	{
		var_length = 1;
		uservar = max_suicides;
		prch += 12;
	}
	else if (!strncmp(prch, "NUM_USER_MOTD_LINES", 19))
	{
		var_length = 1;
		uservar = num_user_motd_lines;
		prch += 19;
	}
	else if (!strncmp(prch, "USER_MOTD", 9))
	{	
		prch += 9;
		i = prch[0] - '1';
		j = prch[2] - '1';
		if (i < 0 || i > 4 || j < 0 || j > 5 || prch[1] != '_')
			Die("Bad USER_MOTD def at line %d\n", prline);
		prch += 3;
		var_length = 40;
		uservar = user_motd[i][j];
	}
	else if (!strncmp(prch, "USER_MAP", 8))
	{
		prch += 8;
		i = prch[0] - '0';
		if (i < 0 || i > 9)
			Die("Bad USER_MAP def at line %d\n", prline);
		prch++;
		var_length = 15;
		uservar = user_map[i];
	}
	else if (!strncmp(prch, "QSMACK", 6))
	{
		prch += 6;
		i = prch[0] - '1';
		if (i < 0 || i > 4)
			Die("Bad QSMACK def at line %d\n", prline);
		prch++;
		var_length = 3;
		uservar = qsmack[i];
	}
	else
		Die("Unknown user var at line %d\n", prline);
}

//
//  G E T  S T R I N G
//
//  Read the string, up to var_length characters, into uservar.
//
void GetString (void)
{
	int count = 0;

	GetChar('\"');
	while (*prch != '\"' && count < var_length)
	{
		if (*prch == '\n')
			Die("Newline inside sting at line %d\n", prline);
		if (*prch == '\\')
		{
			prch++;
			if (*prch != '\"' && *prch != '\\')
				Die("Bad escape sequence at line %d\n", prline);
		}
		*uservar++ = *prch++;
		count++;
	}
	if (*prch != '\"')
		Die("String too long at line %d\n", prline);
	prch++;
	*uservar = 0;
}

//
//  I N I T  U S E R  D E F S  D A T A
//
//  Set up defaults.
//
void InitUserDefsData (void)
{
	int i, j;

	sprintf(max_suicides, "3");
	sprintf(num_user_motd_lines, "0");
	for (i = 0 ; i < 5 ; i++)
	{
		for (j = 0 ; j < 6 ; j++)
			user_motd[i][j][0] = 0;
	}
	for (i = 0 ; i < 10 ; i++)
		user_map[i][0] = 0;
	for (i = 0 ; i < 5 ; i++)
		qsmack[i][0] = 0;
}

//
//  G E T  U S E R  D E F S  D A T A
//
//  Go through userdefs.cfg and parse all assignments.
//
void GetUserDefsData (void)
{
	InitUserDefsData();

	prch = userdefs;
	SkipWhiteSpace();
	while (*prch)
	{
		GetUserVar();
		SkipWhiteSpace();
		GetChar('=');
		SkipWhiteSpace();
		GetString();
		GetChar(';');
		SkipWhiteSpace();
	}
}

//
//  D U M P  U S E R  D E F S  D A T A
//
//  Used for debugging.
//
void DumpUserDefsData (void)
{
	int i, j;

	printf("MAX_SUICIDES = %s\n", max_suicides);
	printf("NUM_USER_MOTD_LINES = %s\n", num_user_motd_lines);
	for (i = 0 ; i < 10 ; i++)
		printf("USER_MAP%d = %s\n", i, user_map[i]);
	for (i = 0 ; i < 5 ; i++)
		printf("QSMACK%d = %s\n", i, qsmack[i]);
	for (i = 0 ; i < 5 ; i++)
	{
		for (j = 0 ; j < 6 ; j++)
			printf("USER_MOTD%d_%d = %s\n", i+1, j+1, user_motd[i][j]);
	}
}

//
//  A D J U S T  M O T D
//
//  Adjust the MOTD according to how many lines there are.
//
void AdjustMOTD (void)
{
	int numlines;
	int j;

	numlines = num_user_motd_lines[0] - '0';
	if (numlines < 0 || numlines > 5)
		Die("Bad NUM_USER_MOTD_LINES\n");

	if (numlines == 0)
	{
		// provide a default MOTD
		strcpy(user_motd[0][0], "type »≈Ã–≠”≈“÷≈“ in console for help");
		strcpy(user_motd[0][1], "étype »≈Ã–≠”≈“÷≈“ in console for helpé");
		strcpy(user_motd[0][2], "\016type HELP-SERVER in console for help\016");
		strcpy(user_motd[0][3], "étype »≈Ã–≠”≈“÷≈“ in console for helpé");
		strcpy(user_motd[0][4], "\016type »≈Ã–≠”≈“÷≈“ in console for help\016");
		strcpy(user_motd[0][5], "étype »≈Ã–≠”≈“÷≈“ in console for helpé");
		numlines = 1;
	}
	if (numlines == 1)
	{
		for (j = 0 ; j < 6 ; j++)
		{
			sprintf(user_motd[3][j], "%s\n", user_motd[0][j]);
			sprintf(user_motd[2][j], "\n");
			sprintf(user_motd[4][j], "\n");
			user_motd[0][j][0] = 0;
			user_motd[1][j][0] = 0;
		}
		numlines = 3;
	}
	else if (numlines == 2)
	{
		for (j = 0 ; j < 6 ; j++)
		{
			sprintf(user_motd[2][j], "%s\n", user_motd[0][j]);
			sprintf(user_motd[3][j], "%s\n", user_motd[1][j]);
			sprintf(user_motd[1][j], "\n");
			sprintf(user_motd[4][j], "\n");
			user_motd[0][j][0] = 0;
		}
		numlines = 4;
	}
	else if (numlines == 3)
	{
		for (j = 0 ; j < 6 ; j++)
		{
			sprintf(user_motd[3][j], "%s\n", user_motd[2][j]);
			sprintf(user_motd[2][j], "%s\n", user_motd[1][j]);
			sprintf(user_motd[1][j], "%s\n", user_motd[0][j]);
			sprintf(user_motd[0][j], "\n");
			sprintf(user_motd[4][j], "\n");
		}
		numlines = 5;
	}
	else if (numlines == 4)
	{
		for (j = 0 ; j < 6 ; j++)
		{
			sprintf(user_motd[4][j], "%s\n", user_motd[3][j]);
			sprintf(user_motd[3][j], "%s\n", user_motd[2][j]);
			sprintf(user_motd[2][j], "%s\n", user_motd[1][j]);
			sprintf(user_motd[1][j], "%s\n", user_motd[0][j]);
			user_motd[0][j][0] = 0;
		}
	}
	else
		for (j = 0 ; j < 6 ; j++)
		{
			sprintf(user_motd[4][j], "%s\n", user_motd[4][j]);
			sprintf(user_motd[3][j], "%s\n", user_motd[3][j]);
			sprintf(user_motd[2][j], "%s\n", user_motd[2][j]);
			sprintf(user_motd[1][j], "%s\n", user_motd[1][j]);
			sprintf(user_motd[0][j], "%s\n", user_motd[0][j]);
		}
	num_user_motd_lines[0] = '0' + numlines;
}

//
//  F I N D  T A G
//
//  Find the next occurrence of "tag" in progs; return a pointer
//  to the occurrence or NULL if none was found.
//
char *FindTag (char *pch)
{
	while ((pch - progs) < BUFSIZE && strncmp(pch, "t!g", 3))
		pch++;
	if (pch - progs < BUFSIZE)
		return pch;
	return NULL;
}

//
//  F I N D  P O I N T E R S
//
//  Search progs.dat for the string tags.
//
void FindPointers (void)
{
	char *ch = progs;
	int i, j;

	max_suicides = NULL;
	num_user_motd_lines = NULL;
	for (i = 0 ; i < 10 ; i++)
		user_map[i] = NULL;
	for (i = 0 ; i < 5 ; i++)
	{
		for (j = 0 ; j < 6 ; j++)
			user_motd[i][j] = NULL;
	}

	while (ch = FindTag(ch))
	{
		switch(ch[-1])
		{
		case 's':
			max_suicides = ch - 3;
			break;

		case 'n':
			num_user_motd_lines = ch - 3;
			break;

		case 'l':
			i = ch[3] - '0';
			if (i >= 0 && i <= 9)
				user_map[i] = ch - 17;
			break;

		case 'm':
			i = ch[3] - '1';
			j = ch[4] - '1';
			if (i >= 0 && i <= 4 && j >= 0 && j <= 5)
				user_motd[i][j] = ch - 42;
			break;

		case 'q':
			i = ch[3] - '1';
			if (i >= 0 && i <= 4)
				qsmack[i] = ch - 5;
			break;
		}
		ch += 3;
	}
}

//
//  C H E C K  P O I N T E R S
//
//  Make sure we found all the string pointers.
//
int CheckPointers (void)
{
	int i, j;

	if (max_suicides == NULL || num_user_motd_lines == NULL)
		return FALSE;
	for (i = 0 ; i < 10 ; i++)
	{
		if (user_map[i] == NULL)
			return FALSE;
	}
	for (i = 0 ; i < 5 ; i++)
	{
		if (qsmack[i] == NULL)
			return FALSE;
	}
	for (i = 0 ; i < 5 ; i++)
	{
		for (j = 0 ; j < 6 ; j++)
		{
			if (user_motd[i][j] == NULL)
				return FALSE;
		}
	}
	return TRUE;
}

//
//  M A I N
//
void main (int csz, char *rgsz[])
{
	FILE *fprogs;
	int i;
    char *dir = ".";
    char progs_file[64];
    char userdefs_file[64];

    if (csz > 1)
        dir = rgsz[1];
    sprintf(progs_file, "%s/progs.dat", dir);
    sprintf(userdefs_file, "%s/userdefs.cfg", dir);

	printf("*** Running crmake v4.1 ***\n");

	fprogs = ReadFile(progs_file, progs);

	FindPointers();
	if (!CheckPointers())
		Die("Bad progs.dat\ncrmake only works with ClanRing CRMod++ versions 4.1 and up.\n");

	fclose(ReadFile(userdefs_file, userdefs));

	GetUserDefsData();	
	AdjustMOTD();

	printf("Writing progs.dat...\n");

	fseek(fprogs, 0, 0); /* SEEK_SET */
	for (i = 0 ; i < BUFSIZE - 1 ; i++)
		fputc(progs[i], fprogs);
	fclose(fprogs);

	printf("Done.\n");

	//DumpUserDefsData();
}
