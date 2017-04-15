//Extra data on monsters.
//We use the convention that $element[none] is physical.
record MonsterData
{
    //An example: Battlie Knight Ghost attack with both hot and physical.
    //Useful to know when calculating Shoot Ghost.
    boolean [element] basic_attack_elements;
    boolean is_protonic_ghost;
    float shoot_ghost_hp_attack_percentage;
};


static
{
    MonsterData [monster] __monster_data;
    
    void initialiseMonsterData()
    {
        foreach m in $monsters[]
        {
            MonsterData blank;
            __monster_data[m] = blank;
        }
        
        //Now, hardcoded:
        //Attack elements:
        __monster_data[$monster[Battlie Knight Ghost]].basic_attack_elements = $elements[hot, none];
        __monster_data[$monster[Claybender Sorcerer Ghost]].basic_attack_elements = $elements[spooky, none];
        __monster_data[$monster[Dusken Raider Ghost]].basic_attack_elements = $elements[sleaze,none];
        __monster_data[$monster[Space Tourist Explorer Ghost]].basic_attack_elements = $elements[sleaze,cold,hot,none];
        __monster_data[$monster[Whatsian Commando Ghost]].basic_attack_elements = $elements[sleaze,none];
        
        __monster_data[$monster[the ghost of Ebenoozer Screege]].basic_attack_elements = $elements[spooky];
        __monster_data[$monster[the ghost of Lord Montague Spookyraven]].basic_attack_elements = $elements[stench];
        __monster_data[$monster[the ghost of Waldo the Carpathian]].basic_attack_elements = $elements[hot];
        __monster_data[$monster[The Icewoman]].basic_attack_elements = $elements[cold];
        __monster_data[$monster[the ghost of Jim Unfortunato]].basic_attack_elements = $elements[sleaze];
        __monster_data[$monster[the ghost of Sam McGee]].basic_attack_elements = $elements[hot];
        __monster_data[$monster[Emily Koops\, a spooky lime]].basic_attack_elements = $elements[spooky];
        __monster_data[$monster[the ghost of Monsieur Baguelle]].basic_attack_elements = $elements[hot];
        __monster_data[$monster[the ghost of Vanillica "Trashblossom" Gorton]].basic_attack_elements = $elements[stench];
        __monster_data[$monster[the ghost of Oily McBindle]].basic_attack_elements = $elements[sleaze];
        __monster_data[$monster[boneless blobghost]].basic_attack_elements = $elements[spooky];
        __monster_data[$monster[the ghost of Richard Cockingham]].basic_attack_elements = $elements[spooky];
        __monster_data[$monster[The Headless Horseman]].basic_attack_elements = $elements[spooky];
        
        __monster_data[$monster[chalkdust wraith]].basic_attack_elements = $elements[none];
        __monster_data[$monster[plaid ghost]].basic_attack_elements = $elements[none,sleaze];
        
        //Protonic:
        foreach m in $monsters[The ghost of Ebenoozer Screege, Emily Koops\, a spooky lime, the ghost of Monsieur Baguelle, The ghost of Lord Montague Spookyraven, The ghost of Waldo the Carpathian, The Icewoman, The ghost of Jim Unfortunato, The ghost of Sam McGee, The ghost of Vanillica "Trashblossom" Gorton, the ghost of Oily McBindle, boneless blobghost, The ghost of Richard Cockingham, The Headless Horseman]
            __monster_data[m].is_protonic_ghost = true;
        //We think each protonic monster uses a different HP multiplier.
        //Emily and Jim, for instance, do way more damage than everyone else.
        //It starts at monster ID 1946, which has 40%, and counts up by 5%. So the actual formula is:
        //percentage = 0.05 * (monster_id - 1946) + 0.4
        __monster_data[$monster[boneless blobghost]].shoot_ghost_hp_attack_percentage = 0.45;
        __monster_data[$monster[the ghost of Monsieur Baguelle]].shoot_ghost_hp_attack_percentage = 0.5;
        __monster_data[$monster[the ghost of Ebenoozer Screege]].shoot_ghost_hp_attack_percentage = 0.65;
        __monster_data[$monster[the ghost of Vanillica "Trashblossom" Gorton]].shoot_ghost_hp_attack_percentage = 0.75;
        __monster_data[$monster[the ghost of Waldo the Carpathian]].shoot_ghost_hp_attack_percentage = 0.9;
        __monster_data[$monster[Emily Koops\, a spooky lime]].shoot_ghost_hp_attack_percentage = 0.95;
        
        //These are from historical logs:
        __monster_data[$monster[the ghost of Oily McBindle]].shoot_ghost_hp_attack_percentage = 0.4; //sleaze
        __monster_data[$monster[The Headless Horseman]].shoot_ghost_hp_attack_percentage = 0.55; //spooky
        __monster_data[$monster[The Icewoman]].shoot_ghost_hp_attack_percentage = 0.60; //cold
        __monster_data[$monster[the ghost of Lord Montague Spookyraven]].shoot_ghost_hp_attack_percentage = 0.70; //stench
        __monster_data[$monster[the ghost of Sam McGee]].shoot_ghost_hp_attack_percentage = 0.8; //hot
        __monster_data[$monster[the ghost of Richard Cockingham]].shoot_ghost_hp_attack_percentage = 0.85; //spooky
        __monster_data[$monster[the ghost of Jim Unfortunato]].shoot_ghost_hp_attack_percentage = 1.0; //sleaze
        
    }
    initialiseMonsterData();
}

//Calculations:
float expectedDamageFromGhostAfterCastingShootGhost(monster m)
{
    if (!m.attributes.contains_text("GHOST")) //no ghost
        return 0;
    /*
        Our guess for how shoot ghost works:
        After you cast it, the ghost will always hit you. It still uses its regular attacks, with corresponding elements, but always deals a percentage of your maximum HP as damage. Your resistances, DA, and DR apply, as per usual.
        Approximate full formula:
        damage = (maximum_hp * ghost_specific_multiplier - DR) * resistance * DA
        Each ghost has a specific multiplier. We're assuming non-protonic ghosts are 30%. But I've only checked a few. The protonic ones vary.
    */
    float percentage_multiplier = 0.3;
    if (__monster_data[m].is_protonic_ghost)
    {
        //Different ghosts have different multipliers:
        percentage_multiplier = 0.5;
        if (__monster_data[m].shoot_ghost_hp_attack_percentage != 0.0)
            percentage_multiplier = __monster_data[m].shoot_ghost_hp_attack_percentage;
    }
    float expected_damage = ceil(my_maxhp() * percentage_multiplier);
    //Apply DR, resistance, and DA, in that order:
    //We saw 2940 when we expected 2939. But then we saw 2939. So maybe these ceils do or do not happen. Or it's random rounding.
    //Same with expected 4119, obtained 4120 and 4119. Fixed that by switching the order of resistance and damage absorption. So maybe resistance is applied before DA, then rrounded at each step...?
    expected_damage = ceil(expected_damage - numeric_modifier("Damage Reduction"));
    //Umm... something to note: Battlie Knight Ghosts will attack with hot damage, even though they're spooky aligned.
    //Plus, they might just attack with physical damage.
    //So, we need to know what types of damage each ghost does.
    expected_damage = MAX(1, expected_damage);
    if (__monster_data[m].basic_attack_elements.count() > 0 && !(__monster_data[m].basic_attack_elements contains $element[none]))
    {
        //They do elemental attacks only. Probably a protonic ghost.
        float minimum_damage_seen = expected_damage;
        //Go through each element:
        foreach e in __monster_data[m].basic_attack_elements
        {
            float resistance_percent = elemental_resistance(e);
            float damage = MAX(1, ceil(expected_damage * (1.0 - resistance_percent / 100.0)));
            if (damage < minimum_damage_seen)
                minimum_damage_seen = damage;
        }
        expected_damage = minimum_damage_seen;
    }
    expected_damage = ceil(expected_damage * (1.0 - damage_absorption_percent() / 100.0));
    return MAX(1, ceil(expected_damage));
}