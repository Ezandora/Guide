import "relay/Guide/Support/List.ash";
import "relay/Guide/Support/Ingredients.ash"



static
{
    int PATH_UNKNOWN = -1;
    int PATH_NONE = 0;
    int PATH_BOOZETAFARIAN = 1;
    int PATH_TEETOTALER = 2;
    int PATH_OXYGENARIAN = 3;

    int PATH_BEES_HATE_YOU = 4;
    int PATH_WAY_OF_THE_SURPRISING_FIST = 6;
    int PATH_TRENDY = 7;
    int PATH_AVATAR_OF_BORIS = 8;
    int PATH_BUGBEAR_INVASION = 9;
    int PATH_ZOMBIE_SLAYER = 10;
    int PATH_CLASS_ACT = 11;
    int PATH_AVATAR_OF_JARLSBERG = 12;
    int PATH_BIG = 14;
    int PATH_KOLHS = 15;
    int PATH_CLASS_ACT_2 = 16;
    int PATH_AVATAR_OF_SNEAKY_PETE = 17;
    int PATH_SLOW_AND_STEADY = 18;
    int PATH_HEAVY_RAINS = 19;
    int PATH_PICKY = 21;
    int PATH_STANDARD = 22;
    int PATH_ACTUALLY_ED_THE_UNDYING = 23;
    int PATH_ONE_CRAZY_RANDOM_SUMMER = 24;
    int PATH_COMMUNITY_SERVICE = 25;
    int PATH_AVATAR_OF_WEST_OF_LOATHING = 26;
    int PATH_THE_SOURCE = 27;
    int PATH_NUCLEAR_AUTUMN = 28;
    int PATH_GELATINOUS_NOOB = 29;
    int PATH_LICENSE_TO_ADVENTURE = 30;
    int PATH_LIVE_ASCEND_REPEAT = 31;
    int PATH_POCKET_FAMILIARS = 32;
    int PATH_G_LOVER = 33;
    int PATH_DISGUISES_DELIMIT = 34;
    int PATH_DEMIGUISE = 34;
    int PATH_DARK_GYFFTE = 35;
    int PATH_DARK_GIFT = 35;
    int PATH_VAMPIRE = 35;
    int PATH_2CRS = 36;
    int PATH_KINGDOM_OF_EXPLOATHING = 37;
    int PATH_EXPLOSION = 37;
    int PATH_EXPLOSIONS = 37;
    int PATH_EXPLODING = 37;
    int PATH_EXPLODED = 37;
    int PATH_OF_THE_PLUMBER = 38;
    int PATH_PLUMBER = 38;
    int PATH_LUIGI = 38;
    int PATH_MAMA_LUIGI = 38;
    int PATH_MARIO = 38;
    int PATH_LOW_KEY_SUMMER = 39;
    int PATH_LOKI = 39;
    int PATH_GREY_GOO = 40;
}

float numeric_modifier_replacement(item it, string modifier)
{
    string modifier_lowercase = modifier.to_lower_case();
    float additional = 0;
    if (my_path_id() == PATH_G_LOVER && !it.contains_text("g") && !it.contains_text("G"))
    	return 0.0;
    if (it == $item[your cowboy boots])
    {
        if (modifier_lowercase == "monster level" && $slot[bootskin].equipped_item() == $item[diamondback skin])
        {
            return 20.0;
        }
        if (modifier_lowercase == "initiative" && $slot[bootspur].equipped_item() == $item[quicksilver spurs])
            return 30;
        if (modifier_lowercase == "item drop" && $slot[bootspur].equipped_item() == $item[nicksilver spurs])
            return 30;
        if (modifier_lowercase == "muscle percent" && $slot[bootskin].equipped_item() == $item[grizzled bearskin])
            return 50.0;
        if (modifier_lowercase == "mysticality percent" && $slot[bootskin].equipped_item() == $item[frontwinder skin])
            return 50.0;
        if (modifier_lowercase == "moxie percent" && $slot[bootskin].equipped_item() == $item[mountain lion skin])
            return 50.0;
        //FIXME deal with rest (resistance, etc)
    }
    //so, when we don't have the smithsness items equipped, they have a numeric modifier of zero.
    //but, they always have an inherent value of five. so give them that.
    //FIXME do other smithsness items
    if (it == $item[a light that never goes out] && modifier_lowercase == "item drop")
    {
    	if (it.equipped_amount() == 0)
     	   additional += 5;
    }
    return numeric_modifier(it, modifier) + additional;
}


static
{
    skill [class][int] __skills_by_class;
    
    void initialiseSkillsByClass()
    {
        if (__skills_by_class.count() > 0) return;
        foreach s in $skills[]
        {
            if (s.class != $class[none])
            {
                if (!(__skills_by_class contains s.class))
                {
                    skill [int] blank;
                    __skills_by_class[s.class] = blank;
                }
                __skills_by_class[s.class].listAppend(s);
            }
        }
    }
    initialiseSkillsByClass();
}


static
{
    boolean [skill] __libram_skills;
    
    void initialiseLibramSkills()
    {
        foreach s in $skills[]
        {
            if (s.libram)
                __libram_skills[s] = true;
        }
    }
    initialiseLibramSkills();
}


static
{
    boolean [item] __minus_combat_equipment;
    boolean [item] __equipment;
    boolean [item] __items_in_outfits;
    boolean [string][item] __equipment_by_numeric_modifier;
    void initialiseItems()
    {
        foreach it in $items[]
        {
            //Crafting:
            //moved to ingredients.ash:
            /*string craft_type = it.craft_type();
            if (craft_type.contains_text("Cooking"))
            {
                foreach ingredient in it.get_ingredients_fast()
                {
                    __items_that_craft_food[ingredient] = true;
                }
            }*/
            
            //Equipment:
            if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3,familiar] contains it.to_slot())
            {
                __equipment[it] = true;
                if (it.numeric_modifier("combat rate") < 0)
                    __minus_combat_equipment[it] = true;
            }
        }
        foreach key, outfit_name in all_normal_outfits()
        {
            foreach key, it in outfit_pieces(outfit_name)
                __items_in_outfits[it] = true;
        }
    }
    initialiseItems();
}

boolean [item] equipmentWithNumericModifier(string modifier)
{
	modifier = modifier.to_lower_case();
    boolean [item] dynamic_items;
    dynamic_items[to_item("kremlin's greatest briefcase")] = true;
    dynamic_items[$item[your cowboy boots]] = true;
    dynamic_items[$item[a light that never goes out]] = true; //FIXME all smithsness items
    if (!(__equipment_by_numeric_modifier contains modifier))
    {
        //Build it:
        boolean [item] blank;
        __equipment_by_numeric_modifier[modifier] = blank;
        foreach it in __equipment
        {
            if (dynamic_items contains it) continue;
            if (it.numeric_modifier(modifier) != 0.0)
                __equipment_by_numeric_modifier[modifier][it] = true;
        }
    }
    //Certain equipment is dynamic. Inspect them dynamically:
    boolean [item] extra_results;
    foreach it in dynamic_items
    {
        if (it.numeric_modifier_replacement(modifier) != 0.0)
        {
            extra_results[it] = true;
        }
    }
    //damage + spell damage is basically the same for most things
    string secondary_modifier = "";
    foreach e in $elements[hot,cold,spooky,stench,sleaze]
    {
        if (modifier == e + " damage")
            secondary_modifier = e + " spell damage";
    }
    if (secondary_modifier != "")
    {
    	foreach it in equipmentWithNumericModifier(secondary_modifier)
        	extra_results[it] = true;
    }
    
    if (extra_results.count() == 0)
        return __equipment_by_numeric_modifier[modifier];
    else
    {
        //Add extras:
        foreach it in __equipment_by_numeric_modifier[modifier]
        {
            extra_results[it] = true;
        }
        return extra_results;
    }
}

static
{
    boolean [item] __beancannon_source_items = $items[Heimz Fortified Kidney Beans,Hellfire Spicy Beans,Mixed Garbanzos and Chickpeas,Pork 'n' Pork 'n' Pork 'n' Beans,Shrub's Premium Baked Beans,Tesla's Electroplated Beans,Frigid Northern Beans,Trader Olaf's Exotic Stinkbeans,World's Blackest-Eyed Peas];
}

static
{
    //This would be a good mafia proxy value. Feature request?
    boolean [skill] __combat_skills_that_are_spells;
    void initialiseCombatSkillsThatAreSpells()
    {
    	//Saucecicle,Surge of Icing are guesses
        foreach s in $skills[Awesome Balls of Fire,Bake,Blend,Blinding Flash,Boil,Candyblast,Cannelloni Cannon,Carbohydrate Cudgel,Chop,CLEESH,Conjure Relaxing Campfire,Creepy Lullaby,Curdle,Doubt Shackles,Eggsplosion,Fear Vapor,Fearful Fettucini,Freeze,Fry,Grease Lightning,Grill,Haggis Kick,Inappropriate Backrub,K&auml;seso&szlig;esturm,Mudbath,Noodles of Fire,Rage Flame,Raise Backup Dancer,Ravioli Shurikens,Salsaball,Saucegeyser,Saucemageddon,Saucestorm,Saucy Salve,Shrap,Slice,Snowclone,Spaghetti Spear,Stream of Sauce,Stringozzi Serpent,Stuffed Mortar Shell,Tear Wave,Toynado,Volcanometeor Showeruption,Wassail,Wave of Sauce,Weapon of the Pastalord,Saucecicle,Surge of Icing]
        {
            __combat_skills_that_are_spells[s] = true;
        }
        foreach s in $skills[Lavafava,Pungent Mung,Beanstorm] //FIXME cowcall? snakewhip?
            __combat_skills_that_are_spells[s] = true;
    }
    initialiseCombatSkillsThatAreSpells();
}

static
{
    boolean [monster] __snakes;
    void initialiseSnakes()
    {
        __snakes = $monsters[aggressive grass snake,Bacon snake,Batsnake,Black adder,Burning Snake of Fire,Coal snake,Diamondback rattler,Frontwinder,Frozen Solid Snake,King snake,Licorice snake,Mutant rattlesnake,Prince snake,Sewer snake with a sewer snake in it,Snakeleton,The Snake With Like Ten Heads,Tomb asp,Trouser Snake,Whitesnake];
    }
    initialiseSnakes();
}

item lookupAWOLOilForMonster(monster m)
{
    if (__snakes contains m)
        return $item[snake oil];
    else if ($phylums[beast,dude,hippy,humanoid,orc,pirate] contains m.phylum)
        return $item[skin oil];
    else if ($phylums[bug,construct,constellation,demon,elemental,elf,fish,goblin,hobo,horror,mer-kin,penguin,plant,slime,weird] contains m.phylum)
        return $item[unusual oil];
    else if ($phylums[undead] contains m.phylum)
        return $item[eldritch oil];
    return $item[none];
}

static
{
    monster [location] __protonic_monster_for_location {$location[Cobb's Knob Treasury]:$monster[The ghost of Ebenoozer Screege], $location[The Haunted Conservatory]:$monster[The ghost of Lord Montague Spookyraven], $location[The Haunted Gallery]:$monster[The ghost of Waldo the Carpathian], $location[The Haunted Kitchen]:$monster[The Icewoman], $location[The Haunted Wine Cellar]:$monster[The ghost of Jim Unfortunato], $location[The Icy Peak]:$monster[The ghost of Sam McGee], $location[Inside the Palindome]:$monster[Emily Koops, a spooky lime], $location[Madness Bakery]:$monster[the ghost of Monsieur Baguelle], $location[The Old Landfill]:$monster[The ghost of Vanillica "Trashblossom" Gorton], $location[The Overgrown Lot]:$monster[the ghost of Oily McBindle], $location[The Skeleton Store]:$monster[boneless blobghost], $location[The Smut Orc Logging Camp]:$monster[The ghost of Richard Cockingham], $location[The Spooky Forest]:$monster[The Headless Horseman]};
}



static
{
	boolean [monster][location] __monsters_natural_habitats;
}
boolean [location] getPossibleLocationsMonsterCanAppearInNaturally(monster m)
{
	if (__monsters_natural_habitats.count() == 0)
	{
		//initialise:
        foreach l in $locations[]
        {
        	foreach key, m in l.get_monsters()
            	__monsters_natural_habitats[m][l] = true;
        }
	}
	return __monsters_natural_habitats[m];
}
