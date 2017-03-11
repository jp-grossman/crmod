//
// Userdefs.qc
//
// This file contains customizations for the Elohim mod.
// The strings are all buffers that are written to by crmake.
//
// All code by J.P. Grossman unless otherwise commented.
//

float (string s) utils_stof;

// Maximum number of suicides allowed per level in normal and match modes
float ELOHIM_MAX_SUICIDES;

// Intro message
string USER_MOTD1_1, USER_MOTD2_1, USER_MOTD3_1, USER_MOTD4_1, USER_MOTD5_1;
string USER_MOTD1_2, USER_MOTD2_2, USER_MOTD3_2, USER_MOTD4_2, USER_MOTD5_2;
string USER_MOTD1_3, USER_MOTD2_3, USER_MOTD3_3, USER_MOTD4_3, USER_MOTD5_3;
string USER_MOTD1_4, USER_MOTD2_4, USER_MOTD3_4, USER_MOTD4_4, USER_MOTD5_4;
string USER_MOTD1_5, USER_MOTD2_5, USER_MOTD3_5, USER_MOTD4_5, USER_MOTD5_5;
string USER_MOTD1_6, USER_MOTD2_6, USER_MOTD3_6, USER_MOTD4_6, USER_MOTD5_6;
float NUM_USER_MOTD_LINES;

// QSmack password
float QSMACK1, QSMACK2, QSMACK3, QSMACK4, QSMACK5;

//
//  I N I T  W O R L D
//
//  Create all string constants
//
void () userdefs_init_world =
{
    local string temp;

    // Number of suicides
    temp = "3 st!g";
    ELOHIM_MAX_SUICIDES = utils_stof(temp);
	if (ELOHIM_MAX_SUICIDES < 2)
		ELOHIM_MAX_SUICIDES = 2;

	// QSMACK
	temp = "100 qt!g1";
	QSMACK1 = utils_stof(temp);
	temp = "100 qt!g2";
	QSMACK2 = utils_stof(temp);
	temp = "100 qt!g3";
	QSMACK3 = utils_stof(temp);
	temp = "100 qt!g4";
	QSMACK4 = utils_stof(temp);
	temp = "100 qt!g5";
	QSMACK5 = utils_stof(temp);

    // User defined maps
    array_user_map[%0] = &"                lt!g0";
    array_user_map[%1] = &"                lt!g1";
    array_user_map[%2] = &"                lt!g2";
    array_user_map[%3] = &"                lt!g3";
    array_user_map[%4] = &"                lt!g4";
    array_user_map[%5] = &"                lt!g5";
    array_user_map[%6] = &"                lt!g6";
    array_user_map[%7] = &"                lt!g7";
    array_user_map[%8] = &"                lt!g8";
    array_user_map[%9] = &"                lt!g9";

    // Intro message
    temp = "0 nt!g";
    NUM_USER_MOTD_LINES = utils_stof(temp);

    // frame 1
    USER_MOTD1_1 = "                                         mt!g11";
    USER_MOTD2_1 = "                                         mt!g21";
    USER_MOTD3_1 = "                                         mt!g31";
    USER_MOTD4_1 = "                                         mt!g41";
    USER_MOTD5_1 = "                                         mt!g51";

    // frame 2
    USER_MOTD1_2 = "                                         mt!g12";
    USER_MOTD2_2 = "                                         mt!g22";
    USER_MOTD3_2 = "                                         mt!g32";
    USER_MOTD4_2 = "                                         mt!g42";
    USER_MOTD5_2 = "                                         mt!g52";

    // frame 3
    USER_MOTD1_3 = "                                         mt!g13";
    USER_MOTD2_3 = "                                         mt!g23";
    USER_MOTD3_3 = "                                         mt!g33";
    USER_MOTD4_3 = "                                         mt!g43";
    USER_MOTD5_3 = "                                         mt!g53";
                
    // frame 4
    USER_MOTD1_4 = "                                         mt!g14";
    USER_MOTD2_4 = "                                         mt!g24";
    USER_MOTD3_4 = "                                         mt!g34";
    USER_MOTD4_4 = "                                         mt!g44";
    USER_MOTD5_4 = "                                         mt!g54";

    // frame 5
    USER_MOTD1_5 = "                                         mt!g15";
    USER_MOTD2_5 = "                                         mt!g25";
    USER_MOTD3_5 = "                                         mt!g35";
    USER_MOTD4_5 = "                                         mt!g45";
    USER_MOTD5_5 = "                                         mt!g55";

    // frame 6
    USER_MOTD1_6 = "                                         mt!g16";
    USER_MOTD2_6 = "                                         mt!g26";
    USER_MOTD3_6 = "                                         mt!g36";
    USER_MOTD4_6 = "                                         mt!g46";
    USER_MOTD5_6 = "                                         mt!g56";
};

