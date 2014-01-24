import "relay/Guide/Support/Checklist.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Plants.ash"
import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Sets.ash"

void generateTasks(Checklist [int] checklists)
{
	ChecklistEntry [int] task_entries;
	
	ChecklistEntry [int] optional_task_entries;
		
	ChecklistEntry [int] future_task_entries;
	
	
	//Friar:
	if (florist_available())
	{
		ChecklistSubentry subentry;
		subentry.header = "Plant florist plants in " + __last_adventure_location;
		
		string [int] examining_plants;
		
		foreach key in __plants_suggested_locations
		{
			PlantSuggestion suggestion = __plants_suggested_locations[key];
			
			if (suggestion.loc != __last_adventure_location)
				continue;
				
			string plant_name = suggestion.plant_name.capitalizeFirstLetter();
			Plant plant = __plant_properties[plant_name];
			
			string line = plant_name + " (" + plant.zone_effect + ", " + plant.terrain;
			if (plant.territorial)
				line = line + ", territorial";
			
			line += ")";
			if (suggestion.details != "")
				line += "|*" + suggestion.details;
			subentry.entries.listAppend(line);
		}
		if (subentry.entries.count() > 0)
			task_entries.listAppend(ChecklistEntryMake("plant up sea daisy", "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry));
	}
	
	QuestsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
	if (!__misc_state["desert beach available"])
	{
        string url;
		ChecklistSubentry subentry;
		subentry.header = "Unlock desert beach";
		if (!knoll_available())
		{
			string meatcar_line = "Build a bitchin' meatcar";
			if (creatable_amount($item[bitchin' meatcar]) > 0)
				meatcar_line += "|*You have all the parts, build it!";
			else
			{
				item [int] missing_parts_list = missingComponentsToMakeItem($item[bitchin' meatcar]);
				
				meatcar_line += "|*Parts needed: " + missing_parts_list.listJoinComponents(", ", "and");
			}
			subentry.entries.listAppend(meatcar_line);
			
			subentry.entries.listAppend("Or buy a desert bus pass. (5000 meat)");
			if ($item[pumpkin].available_amount() > 0)
				subentry.entries.listAppend("Or build a pumpkin carriage.");
            if ($items[can of Br&uuml;talbr&auml;u,can of Drooling Monk,can of Impetuous Scofflaw,fancy tin beer can].available_amount() > 0)
				subentry.entries.listAppend("Or build a tin lizzie.");
            url = "place.php?whichplace=knoll_hostile";
		}
		else
		{
            url = "store.php?whichstore=4";
			int meatcar_price = $item[spring].npc_price() + $item[sprocket].npc_price() + $item[cog].npc_price() + $item[empty meat tank].npc_price() + 100 + $item[tires].npc_price() + $item[sweet rims].npc_price() + $item[spring].npc_price();
			subentry.entries.listAppend("Build a bitchin' meatcar (" + meatcar_price + " meat)");
		}
		
		task_entries.listAppend(ChecklistEntryMake("__item bitchin' meatcar", url, subentry));
	}
	else if (!__misc_state["mysterious island available"])
	{
		ChecklistSubentry subentry;
		subentry.header = "Unlock mysterious island";
		
		int scrip_number = $item[Shore Inc. Ship Trip Scrip].available_amount();
		int trips_needed = MAX(0, 3 - scrip_number);
        
        string url = "place.php?whichplace=desertbeach";
        
		if ($item[dinghy plans].available_amount() > 0)
        {
            if ($item[dingy planks].available_amount() > 0)
            {
                url = "inventory.php?which=3";
                subentry.entries.listAppend("Use dinghy plans.");
            }
            else
            {
                url = "store.php?whichstore=m";
                subentry.entries.listAppend("Buy dingy planks, then build dinghy dinghy.");
            }
                
        }
		else if (trips_needed > 0)
		{
			string line_string = "Shore, " + (3 * trips_needed) + " adventures";
			int meat_needed = trips_needed * 500;
			if (my_meat() < meat_needed)
				line_string += "|Need " + meat_needed + " meat for vacations, have " + my_meat() + "."; //FIXME what about way of the surprising fist?
			subentry.entries.listAppend(line_string);
            if ($item[skeleton].available_amount() > 0)
                subentry.entries.listAppend("Skeletal skiff?");
		}
		else
		{
			subentry.entries.listAppend("Redeem scrip at shore for dinghy plans.");
		}
		task_entries.listAppend(ChecklistEntryMake("__item dingy dinghy", url, subentry, $locations[the shore\, inc. travel agency]));
	}



	
	
	
	if (my_path() == "Bugbear Invasion")
	{
		
		task_entries.listAppend(ChecklistEntryMake("bugbear", "", ChecklistSubentryMake("Bugbears!", "", "I have no idea")));
	}
	
	
	if (__misc_state["need to level"])
	{
		ChecklistSubentry subentry;
		
		int main_substats = my_basestat(my_primesubstat());
		int substats_remaining = substatsForLevel(my_level() + 1) - main_substats;
		
		subentry.header = "Level to " + (my_level() + 1);
		
		subentry.entries.listAppend("Gain " + substats_remaining + " substats.");
		
		
		task_entries.listAppend(ChecklistEntryMake("player character", "", subentry, 11));
	}
	
	
	
	if ($effect[QWOPped Up].have_effect() > 0 && __misc_state["VIP available"] && get_property_int("_hotTubSoaks") < 5) //only suggest if they have hot tub access; other route is a SGEEA, too valuable
    {
        string [int] description;
        description.listAppend("Use hot tub.");
        
		task_entries.listAppend(ChecklistEntryMake("__effect qwopped up", "clan_viplounge.php", ChecklistSubentryMake("Remove QWOPped up effect", "", description), -11));
    }

		
	

	

	if (__misc_state["yellow ray available"] && __misc_state["In run"])
	{
		string [int] potential_targets;
		
		if (!have_outfit_components("Filthy Hippy Disguise"))
			potential_targets.listAppend("Mysterious Island Hippy for outfit. (allows hippy store access; free redorant for +combat)");
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
			potential_targets.listAppend("Hippy/frat war outfit?");
		//fax targets?
		if (__misc_state["fax available"])
		{
			potential_targets.listAppend("Anything on the fax list.");
		}
		
		if (!__quest_state["Level 10"].finished && $item[mohawk wig].available_amount() == 0)
			potential_targets.listAppend("Burly Sidekick (Mohawk wig) - speed up top floor of castle.");
		if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
			potential_targets.listAppend("Filthworms.");
		
		if (needTowerMonsterItem("disease"))
		{
			if (__quest_state["Level 5"].finished)
				potential_targets.listAppend("Knob goblin harem girl. (disease for tower, unless tower killing)");
			else
				potential_targets.listAppend("Knob goblin harem girl. (outfit for quest, disease for tower, unless tower killing)");
		}
		if (__quest_state["Boss Bat"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() <3)
		{
			if ($item[enchanted bean].available_amount() == 0 && !__misc_state["beanstalk grown"])
				potential_targets.listAppend("Beanbat. (enchanted bean, sonar-in-a-biscuit)");
			else
				potential_targets.listAppend("A bat. (sonar-in-a-biscuit)");
		}
		
		if (!__quest_state["Level 13"].state_boolean["have relevant guitar"] && !__quest_state["Level 13"].state_boolean["past keys"])
			potential_targets.listAppend("Grungy pirate. (guitar)");
		if (!__quest_state["Level 13"].state_boolean["past tower"])
			potential_targets.listAppend("Tower items? Gate items?");
		
		if (item_drop_modifier() < 234.0 && !__misc_state["In aftercore"])
			potential_targets.listAppend("Anything with 30% drop if you can't 234%. (dwarf foreman, bob racecar, drum machines, etc)");
		
		optional_task_entries.listAppend(ChecklistEntryMake(__misc_state_string["yellow ray image name"], "", ChecklistSubentryMake("Fire yellow ray", "", potential_targets), 5));
	}
	
	if (__misc_state["need to level"])
	{
        string url = "";
		int mcd_max_limit = 10;
		boolean have_mcd = false;
		if (canadia_available() || knoll_available() || gnomads_available() || in_bad_moon())
			have_mcd = true;
        if (knoll_available())
        {
            if ($item[detuned radio].available_amount() > 0)
                url = "inventory.php?which=3";
            else
                url = "store.php?whichstore=4";
        }
        //FIXME URLs for the other ones
		if (current_mcd() < mcd_max_limit && have_mcd && monster_level_adjustment() < 50)
		{
			optional_task_entries.listAppend(ChecklistEntryMake("__item detuned radio", url, ChecklistSubentryMake("Set monster control device to " + mcd_max_limit, "", (mcd_max_limit * __misc_state_float["ML to mainstat multiplier"]) + " mainstats/turn")));
		}
	}
	
	if (!have_outfit_components("Filthy Hippy Disguise") && __misc_state["mysterious island available"] && __misc_state["In run"] && !__quest_state["Level 12"].finished)
	{
		item [int] missing_pieces = missing_outfit_components("Filthy Hippy Disguise");
        
		string [int] description;
		string [int] modifiers;
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
		description.listAppend("Yellow-ray a hippy if you can.");
		if (my_level() >= 9)
		{
			description.listAppend("Otherwise, run -combat.");
			modifiers.listAppend("-combat");
		}
		else
		{
			description.listAppend("Otherwise, wait for level 9.");
		}
		optional_task_entries.listAppend(ChecklistEntryMake("__item filthy knitted dread sack", "island.php", ChecklistSubentryMake("Acquire a filthy hippy disguise", modifiers, description), $locations[hippy camp]));
	}
	if (!have_outfit_components("Frat boy ensemble") && __misc_state["mysterious island available"] && __misc_state["In run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].started && $location[frat house].combatTurnsAttemptedInLocation() > 0)
    {
        //they don't have a frat boy ensemble, but they adventured in the pre-war frat house
        //I'm assuming this means they want the outfit, for whatever reason. So, suggest it, until the level 12 starts:
		item [int] missing_pieces = missing_outfit_components("Frat boy ensemble");
        
		string [int] description;
		string [int] modifiers;
        modifiers.listAppend("-combat");
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
			description.listAppend("Run -combat.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item homoerotic frat-paddle", "island.php", ChecklistSubentryMake("Acquire a frat boy ensemble", modifiers, description, $locations[frat house])));
    }
		
	if (my_level() >= 9 && $item[giant pinky ring].available_amount() == 0) //very hacky way of testing if leaflet quest was done - in theory, they could smash the ring or pull one (or be casual)
	{
		optional_task_entries.listAppend(ChecklistEntryMake("__item strange leaflet", "", ChecklistSubentryMake("Strange leaflet quest", "", "Quests Menu" + __html_right_arrow_character + "Leaflet (With Stats)")));
	}
	

	SetsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
    
    if ($effect[beaten up].have_effect() > 0)
    {
        string [int] methods;
        string url;
        if ($skill[tongue of the walrus].have_skill())
        {
            methods.listAppend("Cast Tongue of the Walrus.");
            url = "skills.php";
        }
        else if (__misc_state["VIP available"] && get_property_int("_hotTubSoaks") < 5)
        {
            methods.listAppend("Soak in VIP hot tub.");
            url = "clan_viplounge.php";
        }
        else if (__misc_state_int["free rests remaining"] > 0)
        {
            methods.listAppend("Free rest at your campsite.");
            url = "campground.php";
        }
        
        foreach it in $items[tiny house,space tours tripple,personal massager,forest tears,csa all-purpose soap]
        {
            if (it.available_amount() > 0 && methods.count() == 0)
            {
                url = "inventory.php?which=1"; //may not be correct in all cases
                methods.listAppend("Use " + it + ".");
                break;
            }
        }
        
        if (methods.count() > 0)
            task_entries.listAppend(ChecklistEntryMake("__effect beaten up", url, ChecklistSubentryMake("Remove beaten up", "", methods), -11));
    }
    
    if (true)
    {
        //Don't get poisoned.
        effect [int] poison_effects;
        poison_effects.listAppend($effect[Hardly poisoned at all]);
        poison_effects.listAppend($effect[A Little Bit Poisoned]);
        poison_effects.listAppend($effect[Somewhat Poisoned]);
        poison_effects.listAppend($effect[Really Quite Poisoned]);
        poison_effects.listAppend($effect[Majorly Poisoned]);
        poison_effects.listAppend($effect[Toad In The Hole]);
        
        effect have_poison = $effect[none];
        foreach key in poison_effects
        {
            effect e = poison_effects[key];
            if (e.have_effect() > 0)
            {
                have_poison = e;
                break;
            }
        }
        if (have_poison != $effect[none])
        {
            string url = "";
            string [int] methods;
            
            if ($skill[disco nap].have_skill() && $skill[adventurer of leisure].have_skill())
            {
                url = "skills.php";
                methods.listAppend("Cast Disco Nap.");
            }
            else
            {
                url = "galaktik.php";
                methods.listAppend("Use Doc Galaktik's anti-anti-antidote.");
                if ($item[anti-anti-antidote].available_amount() > 0)
                    url = "inventory.php?which=1";
            }
            
            task_entries.listAppend(ChecklistEntryMake("__effect " + have_poison, url, ChecklistSubentryMake("Remove " + have_poison, "", methods), -11));
        }
	}
    if ($effect[Cunctatitis].have_effect() > 0 && $skill[disco nap].have_skill() && $skill[adventurer of leisure].have_skill())
    {
        string url = "skills.php";
        string method = "Cast disco power nap";
        task_entries.listAppend(ChecklistEntryMake("__effect Cunctatitis", url, ChecklistSubentryMake("Remove Cunctatitis", "", method), -11));
    }
    
    if (__last_adventure_location == $location[The Red Queen's Garden] && (!in_ronin() || $item[&quot;DRINK ME&quot; potion].available_amount() > 0) && get_property_int("pendingMapReflections") <= 0)
    {
        string url = "mall.php";
        
        if ($item[&quot;DRINK ME&quot; potion].available_amount() > 0)
            url = "inventory.php?which=3";
        
        task_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", url, ChecklistSubentryMake("Drink " + $item[&quot;DRINK ME&quot; potion], "+madness", "Otherwise, no reflections of a map will drop."), -11));
    }
    
    if ($effect[Merry Smithsness].have_effect() == 0 && (!in_ronin() || $item[flaskfull of hollow].available_amount() > 0) && $items[Meat Tenderizer is Murder,Ouija Board\, Ouija Board,Hand that Rocks the Ladle,Saucepanic,Frankly Mr. Shank,Shakespeare's Sister's Accordion,Sheila Take a Crossbow,A Light that Never Goes Out,Half a Purse,loose purse strings,Hand in Glove].equipped_amount() > 0)
    {
        //They (can) have a flaskfull of hollow and have a smithsness item equipped, but no merry smithsness.
        //So, suggest a high-priority task.
        //I suppose in theory they could be saving the flaskfull of hollow for later, for +item? In that case, we would be annoying them. They can closet the flask, but that isn't perfect...
        //Still, I feel as though having this reminder is better than not having it.
        
        //Four items are not on the list due to their marginal bonus: Hairpiece On Fire (+maximum MP), Vicar's Tutu (+maximum HP), Staff of the Headmaster's Victuals (+spell damage), Work is a Four Letter Sword (+weapon damage)
        string url = "mall.php";
        
        if ($item[flaskfull of hollow].available_amount() > 0)
            url = "inventory.php?which=3";
        
        task_entries.listAppend(ChecklistEntryMake("__item flaskfull of hollow", url, ChecklistSubentryMake("Drink " + $item[flaskfull of hollow], "", "Gives +25 smithsness"), -11));
    }
    
    boolean have_spaghetti_breakfast = (($skill[spaghetti breakfast].have_skill() && !get_property_boolean("_spaghettiBreakfast")) || $item[spaghetti breakfast].available_amount() > 0);
    if (__misc_state["In run"] && __misc_state["can eat just about anything"] && !get_property_boolean("_spaghettiBreakfastEaten") && my_fullness() == 0 && have_spaghetti_breakfast)
    {
    
        string [int] adventure_gain;
        adventure_gain[1] = "1";
        adventure_gain[2] = "?1-2?";
        adventure_gain[3] = "2";
        adventure_gain[4] = "2-3";
        adventure_gain[5] = "3";
        adventure_gain[6] = "3-4";
        adventure_gain[7] = "4";
        adventure_gain[8] = "4-5";
        adventure_gain[9] = "5";
        adventure_gain[10] = "5-6";
        adventure_gain[11] = "6";
        
        string adventures_gained = adventure_gain[MAX(1, MIN(11, my_level()))];
        
        string level_string = "";
        if (my_level() < 11)
            level_string = " Gain levels for more.";
        string url = "inventory.php?which=1";
        string [int] description;
        description.listAppend("Inedible if you eat anything else.|" + adventures_gained + " adventures/fullness." + level_string);
        if ($item[spaghetti breakfast].available_amount() == 0)
        {
            description.listAppend("Obtained by casting spaghetti breakfast.");
            url = "skills.php";
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item spaghetti breakfast", url, ChecklistSubentryMake("Eat " + $item[spaghetti breakfast] + " first", "", description), 8));
    }
    
	checklists.listAppend(ChecklistMake("Tasks", task_entries));
	checklists.listAppend(ChecklistMake("Optional Tasks", optional_task_entries));
	checklists.listAppend(ChecklistMake("Future Tasks", future_task_entries));
}