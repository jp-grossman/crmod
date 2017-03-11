
void (entity targ, entity attacker) ClientRate =
{
	local float target_k, attacker_k, expect, x;

	if ((targ == attacker) || (targ.classname != "player") || (attacker.classname != "player"))
		return;
		
	if ((targ.team == attacker.team) && teamplay)
	{
		targ.rating     = targ.rating - 5;
		attacker.rating = attacker.rating - 5;
		return;	
	}
		
	// Compute the expected outcome for the higher-rated player
	x = fabs(attacker.rating - targ.rating);
	if (x == 0 )
		expect = 0.50;
	else if (x <= 20)
		expect = 0.53;
	else if (x <= 40)
		expect = 0.58;
	else if (x <= 60)
		expect = 0.62;
	else if (x <= 80)
		expect = 0.66;
	else if (x <= 100)
		expect = 0.69;
	else if (x <= 120)
		expect = 0.73;
	else if (x <= 140)
		expect = 0.76;
	else if (x <= 160)
		expect = 0.79;
	else if (x <= 180)
		expect = 0.82;
	else if (x <= 200)
		expect = 0.84;
	else if (x <= 300)
		expect = 0.93;
	else if (x <= 400)
		expect = 0.97;
	else
		expect = 0.99;
	
	// Make it the expected outcome for the attacker
	if (attacker.rating < targ.rating)
		expect = 1 - expect;
	
	// attacker rating += K * (actual - expected)	
	if (attacker.fights < 10)
		attacker_k = 30;
	else if (attacker.rating < 2400)
		attacker_k = 15;
	else 
		attacker_k = 10;
	attacker.rating = attacker.rating + attacker_k * (1 - expect);

	// target rating += K * (actual_target - expected_target)
	if (targ.fights < 10)
		target_k = 30;
	else if (targ.rating < 2400)
		target_k = 15;
	else 
		target_k = 10;
	targ.rating = targ.rating - target_k * (1 - expect);

	targ.fights = targ.fights + 1;
	attacker.fights = attacker.fights + 1;
};

void (entity player, float n) RankPrintRank =
{
	local string s;
	local float r;

	if (player == self)
		sprint(self, " \[");
	else
		sprint(self, "  ");
	if (n < 10)
		sprint(self, " ");
	s = ftos(n);
	sprint(self, s);
	if (player == self)
		sprint(self, "\] ");
	else
		sprint(self, "  ");
	sprint(self, "№", player.name15, "№  ");
	if (player.fights >= 10)
	{
		r = floor(player.rating);
		if (r < 100)
			sprint(self, " ");
		if (r < 1000)
			sprint(self, " ");
		s = ftos(r);
		sprint(self, s, "  №  ");
	}
	else
		sprint(self, "      №  ");
	s = ftos(player.fights);
	sprint(self, s, "\n");
};

void () RankSort =
{
	local entity player, e;

	// First player
	player = find(world, classname, "player");
	elohim_sentinel.chain = player;
	if (!player)
		return;
		
	// Remaining players
	player.chain = world;
    player = find(player, classname, "player");
    while (player)
    {
		if (player.style & ELOHIM_CONNECTED)
		{
			e = elohim_sentinel;
			while ((e.chain != world) && 
				   ((e.chain.fights >= 10 && player.fights < 10) ||      
				    (e.chain.fights >= 10 && player.fights >= 10 && e.chain.rating > player.rating)))
			{
				e = e.chain;
			}
			player.chain = e.chain;
			e.chain = player;
		}
	    player = find(player, classname, "player");
    }
};

void () ShowRatings =
{
	local entity player;
	local float n;

	sprint(self, " rank №      name     № rating № fights \n"); 
    sprint(self, "ннннннлнннннннннннннннлннннннннлнннннннн\n");

	RankSort();    

	player = elohim_sentinel.chain;
	n = 1;
	while (player)
	{
		RankPrintRank(player, n);
		player = player.chain;
		n = n + 1;
	}
};