//
// vote.qc
//
// This file contains code to implement voting.  All votes consist of an
// initial request followed by a 21 second vote.  elohim_request contains
// the request strings.
//
// For all requests .use points to a function which is called when
// the vote passes, and .th_die points to a function which is called when
// the vote dies.  The die function is optional; the pass function must
// be passed to vote_init.  Sample usage:
//
//    vote_init("change level to ", newmap, admin_change_level);
//    vote_yes();
//
// All code by J.P. Grossman unless otherwise commented.
//

// Function declarations
void () vote_repeat;
void () vote_accept;
void () vote_reject;
void () vote_clear;
float () vote_majority;
void () SUB_Null;
void () votables_make_admin;
void () votables_set_mode;

//
//  I N I T
//
//  Prints a message composed of strings s1 and s2 and initializes
//  a vote (if one is not already in progress).  'accept' is a
//  function that is called when the vote passes.
//
//  Returns TRUE if successful, FALSE otherwise.
//
float (string s1, string s2, void () accept) vote_init =
{
    // Check to see if there's already a vote in progress
    if (elohim_request)
    {
        sprint(self, "There is already a vote in progress\n");
        return FALSE;
    }

	// Don't start votes during match unless it's by a player
	if ((elohim_state & ELOHIM_MATCH_STARTED) && !(self.style & (ELOHIM_READY | ELOHIM_ADMINISTRATOR)))
	{
		sprint(self, "Match observers cannot initiate votes\n");
		return FALSE;
	}

	clear_afk_status(self);//Sputnik 

    elohim_request = spawn();
    elohim_request.classname = "elohim_request";
    elohim_request.th_die = SUB_Null;
    elohim_request.think = vote_repeat;
    elohim_request.use = accept;
    elohim_request.wad = s1;
    elohim_request.map = s2;
    elohim_request.count = 0;
	elohim_request.owner = self;
    utils_do_players(vote_clear);

    // If there's only one voter then it will pass as soon as that
    // person votes yes; no need to print the request.
    if (!vote_majority())
        vote_repeat();

    return TRUE;
};

//
//  C L E A R
//
void () vote_clear =
{
    self.style = self.style - (self.style & ELOHIM_YES);
};

//
//  Y E S
//
//  Called when a player votes yes.
//
void () vote_yes =
{
	local string s;

	clear_afk_status(self);//Sputnik 

	if (self.crmod_hack_count == 10)
		s = "V";
	else
		s = ftos(self.crmod_hack_count);

    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        // accept immediately
		announce4(self.netname," passed the vote as admin(",s,").\n");
        vote_accept();
        return;
    }

    if (self.style & ELOHIM_YES)
    {
        sprint(self, "\nWise man say: \"Vote early, vote often\"\n");
        return;
    }

	if (self != elohim_request.owner)
	{
		bprint (self.netname, " voted yes.\n");
	}

    self.style = self.style | ELOHIM_YES;
    if (vote_majority())
        vote_accept();
};

//
//  N O
//
//  Called when a player votes no.
//
void () vote_no =
{
	local string s;

	clear_afk_status(self);//Sputnik 

	if (self.crmod_hack_count == 10)
		s = "V";
	else
		s = ftos(self.crmod_hack_count);

    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        // reject immediately
		announce4(self.netname," rejected the vote as admin(",s,").\n");
        vote_reject();
        return;
    }
	bprint (self.netname, " voted \bno.\n");
    vote_clear();
};

//
//  M A J O R I T Y
//
//  Return TRUE if the majority of players have responded 'yes',
//  FALSE otherwise.  Observers only get x% of a vote based on number of players.
//

float () vote_majority =
{
	local entity player;
	local float vote_count;

	vote_count = 0;

	player = find(world, classname, "player");
	
	while (player)
	{
		if ((player.style & ELOHIM_CONNECTED) && !(player.style & CRMOD_QSMACK) && !(player.oflags & ELOHIM_AFK))
		{			
			if (player.style & ELOHIM_YES || player == self)
			{
				if (elohim_state & ELOHIM_MATCH_STARTED)//QuakeC is limited so this is weird
				{
					if (player.style & ELOHIM_OBSERVER)
					{
						vote_count = vote_count + 0;
					}
					else
						vote_count = vote_count + 1;
				}
				else
					vote_count = vote_count + 1;

				// special case.. set mode to match if there are 4 yes votes
				if ((elohim_request.use == votables_set_mode) && (elohim_request.map == strings_get_mode(ADMIN_MATCH_MODE)))
				{
					if (vote_count >= 4)
						return TRUE;
				}				
			}
			else
			{
				if (elohim_state & ELOHIM_MATCH_STARTED)
				{
					if (player.style & ELOHIM_OBSERVER)
					{
						vote_count = vote_count - 0;
					}
					else
						vote_count = vote_count - 1;
				}
				else
					vote_count = vote_count - 1;
			}
		}
		player = find(player, classname, "player");
	}

	if (vote_count > 0)
		return TRUE;
	
	return FALSE;
};

/*
float () vote_majority =
{
    local entity player;
    local float vote_count, players, observers, obs_vote;

    players = observers = vote_count = 0;                                                
	
	if (elohim_state & ELOHIM_MATCH_STARTED)//Sputnik: If match has started then observers only get a x% of the player vote.
	{
		player = find(world, classname, "player");
		while (player)
		{
			if ((player.style & ELOHIM_CONNECTED) && !(player.style & CRMOD_QSMACK) && !(player.oflags & ELOHIM_AFK))
			{
				if (player.style & ELOHIM_OBSERVER)
					observers = observers + 1;
				else
					players = players + 1;
			}
			player = find(player, classname, "player");
		}
		
		if ((players) && (observers))
		{	
			obs_vote = 99 * players / observers;
			if (obs_vote > 99)
				obs_vote = 99;
		}
		else
			obs_vote = 100;
	}
	else
		obs_vote = 100;//Sputnik: Else all clients' votes are counted equally.

    player = find(world, classname, "player");
    while (player)
    {
        if ((player.style & ELOHIM_CONNECTED) && !(player.style & CRMOD_QSMACK) && !(player.oflags & ELOHIM_AFK))
        {
            local float vote;
			if (player.style & ELOHIM_OBSERVER)
                vote = obs_vote;				// CRMOD
            else
                vote = 100;

            if (player.style & ELOHIM_YES || player == self)
                vote_count = vote_count + vote;
            else
                vote_count = vote_count - vote;
        }
        player = find(player, classname, "player");
    }
	if (elohim_request.use == votables_make_admin)
	{
		if (vote_count > 100)
			return TRUE;
	}
	else if (vote_count > 1)//Sputnik: This has to be 1 or else a 'player' will pass a vote immediately when initiated in matchmode.
return TRUE;

	// special case.. set mode to match if there are 4 yes votes
	if ((elohim_request.use == votables_set_mode) && (elohim_request.map == strings_get_mode(ADMIN_MATCH_MODE)))
	{
		vote_count = 0;
		player = find(world, classname, "player");
		while (player)
		{
			if ((player.style & ELOHIM_CONNECTED) && !(player.style & CRMOD_QSMACK) && (player.style & ELOHIM_YES))
				vote_count = vote_count + 1;
	        player = find(player, classname, "player");
		}
		if (vote_count >= 4)
			return TRUE;
	}

    return FALSE;
};
*/
//
//  R E P E A T
//
//  Print the request; schedule the next automatic action.
//  elohim_request.count counts the number of times the request
//  has been displayed.
//
void () vote_repeat =
{
    bprint((elohim_request.owner.netname)," ςερυεστσ το \b", elohim_request.wad, elohim_request.map, "\n");
    bprint("Type \byes\b or \bno\b in console to vote\n");
	sound (world, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
    elohim_request.nextthink = time + 7;
    elohim_request.count = elohim_request.count + 1;
    if (elohim_request.count == 3)
        elohim_request.think = vote_reject;
};

//
//  A C C E P T
//
void () vote_accept =
{
    elohim_request.use();
    remove(elohim_request);
    elohim_request = world;
};

//
//  R E J E C T
//
//  Called when the vote is cancelled by an administrator or
//  21 seconds elapse.
//
void () vote_reject =
{
	bprint("\{1}Vote cancelled\n");
    elohim_request.th_die();
    remove(elohim_request);
    elohim_request = world;
};

//
//  I M P U L S E
//
void () vote_impulse =
{
    if (!elohim_request)
    {
        sprint(self, "Nothing to vote on\n");
        return;
    }

    if (self.impulse == 115)
        vote_yes();
    else if (self.impulse == 116)
        vote_no();
};
