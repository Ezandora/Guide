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
			task_entries.listAppend(ChecklistEntryMake("plant up sea daisy", "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry, -11));
	}
	
	QuestsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
	if (!__misc_state["desert beach available"])
	{
        string url;
		ChecklistSubentry subentry;
		subentry.header = "Unlock desert beach";
		if (!knoll_available())
		{
			string meatcar_line = "Build a bitchin' meatcar.";
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
			subentry.entries.listAppend("Build a bitchin' meatcar. (" + meatcar_price + " meat)");
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
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeGasTank").length() == 0)
            subentry.entries.listAppend("Possibly upgrade your motorcycle's gas tank. (extra-buoyant)");
		task_entries.listAppend(ChecklistEntryMake("__item dingy dinghy", url, subentry, $locations[the shore\, inc. travel agency]));
	}



	
	
	
	if (my_path_id() == PATH_BUGBEAR_INVASION)
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
    if (__misc_state["In run"] && !have_mushroom_plot() && knoll_available() && __misc_state["can eat just about anything"] && fullness_limit() >= 4 && $item[spooky mushroom].available_amount() == 0 && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST && my_meat() >= 5000)
    {
        string [int] description;
        description.listAppend("For spooky mushrooms, to cook a grue egg omelette. (epic food)|Will " + ((my_meat() < 5000) ? "need" : "cost") + " 5k meat.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item spooky mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Possibly plant a mushroom plot", "", description), 5));
    
    }
	
	if (__misc_state["need to level"])
	{
        string url = "";
		int mcd_max_limit = 10;
		boolean have_mcd = false;
		if (canadia_available() || knoll_available() || gnomads_available() || in_bad_moon())
			have_mcd = true;
        if (canadia_available())
            mcd_max_limit = 11;
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
    //FIXME better detection
	if (!have_outfit_components("Frat boy ensemble") && __misc_state["mysterious island available"] && __misc_state["In run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].started && ($location[frat house].combatTurnsAttemptedInLocation() > 0 || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Murder by Death") || $location[frat house].noncombat_queue.contains_text("I Just Wanna Fly") || $location[frat house].noncombat_queue.contains_text("From Stoked to Smoked") || $location[frat house].noncombat_queue.contains_text("Purple Hazers")))
    {
        //they don't have a frat boy ensemble, but they adventured in the pre-war frat house
        //I'm assuming this means they want the outfit, for whatever reason. So, suggest it, until the level 12 starts:
		item [int] missing_pieces = missing_outfit_components("Frat boy ensemble");
        
		string [int] description;
		string [int] modifiers;
        modifiers.listAppend("-combat");
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
			description.listAppend("Run -combat.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item homoerotic frat-paddle", "island.php", ChecklistSubentryMake("Acquire a frat boy ensemble", modifiers, description), $locations[frat house]));
    }
		
	if ($item[strange leaflet].available_amount() > 0 && $item[giant pinky ring].available_amount() == 0) //very hacky way of testing if leaflet quest was done - in theory, they could smash the ring or pull one (or be casual)
	{
		optional_task_entries.listAppend(ChecklistEntryMake("__item strange leaflet", "", ChecklistSubentryMake("Strange leaflet quest", "", "Quests Menu" + __html_right_arrow_character + "Leaflet (With Stats)")));
	}
	

	SetsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	

    
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
    
    if (__misc_state["In run"])
    {
        item dwelling = get_dwelling();
        item upgraded_dwelling = $item[none];
        if ($item[Frobozz Real-Estate Company Instant House (TM)].available_amount() > 0 && (dwelling == $item[big rock] || dwelling == $item[Newbiesport&trade; tent]))
        {
            upgraded_dwelling = $item[Frobozz Real-Estate Company Instant House (TM)];
        }
        else if ($item[Newbiesport&trade; tent].available_amount() > 0 && dwelling == $item[big rock])
        {
            upgraded_dwelling = $item[Newbiesport&trade; tent];
        }
        if (upgraded_dwelling != $item[none])
        {
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + upgraded_dwelling, "inventory.php?which=3", ChecklistSubentryMake("Use " + upgraded_dwelling, "", "Better HP/MP restoration via rollover and free rests."), 8));
            
        }
    }
    
	checklists.listAppend(ChecklistMake("Tasks", task_entries));
	checklists.listAppend(ChecklistMake("Optional Tasks", optional_task_entries));
	checklists.listAppend(ChecklistMake("Future Tasks", future_task_entries));
}