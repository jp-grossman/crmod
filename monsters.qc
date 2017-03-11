//
// ELOHIM_MOD
//
// The original monsters.qc is gone.. this file provides spawn functions
// for the monsters so that quake doesn't complain.
//
void() monster_fish = { remove(self); };
void() monster_army = { remove(self); };
void() monster_dog = { remove(self); };
void() monster_boss = { remove(self); };
void() monster_demon1 = { remove(self); };
void() monster_enforcer = { remove(self); };
void() monster_hell_knight = { remove(self); };
void() monster_knight = { remove(self); };
void() monster_ogre = { remove(self); };
void() monster_oldone = { remove(self); };
void() monster_shalrath = { remove(self); };
void() monster_shambler = { remove(self); };
void() monster_tarbaby = { remove(self); };
void() monster_wizard = { remove(self); };
void() monster_zombie = { remove(self); };
void() path_corner = 
{ 
	self.solid = SOLID_TRIGGER;
	setsize (self, '-8 -8 -8', '8 8 8');
};

// END_MOD
