
void QLevel4Init()
{
	//questL04Bat
	//be sure to set state_int["areas unlocked"]
    
    //started -> no areas unlocked
    //step1 -> 1 area unlocked
    //step2 -> 2 areas unlocked
    //step3 -> 3 areas unlocked
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL04Bat");
    if (my_path_id() == PATH_COMMUNITY_SERVICE) QuestStateParseMafiaQuestPropertyValue(state, "finished");
	
	state.quest_name = "Boss Bat Quest";
	state.image_name = "Boss Bat";
	state.council_quest = true;
	
	if (state.in_progress)
	{
		//Zones opened?
        if ($location[the batrat and ratbat burrow].locationAvailable())
            state.state_int["areas unlocked"] = 1;
        if ($location[the beanbat chamber].locationAvailable())
            state.state_int["areas unlocked"] = 2;
        if ($location[the boss bat\'s lair].locationAvailable())
            state.state_int["areas unlocked"] = 3;
            
	}
	else if (state.finished)
	{
		state.state_int["areas unlocked"] = 3;
	}
	
	if (my_level() >= 4 || my_path_id() == PATH_EXPLOSIONS)
		state.startable = true;
		
	__quest_state["Level 4"] = state;
	__quest_state["Boss Bat"] = state;
}


void QLevel4GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 4"].in_progress)
		return;
	
	QuestState base_quest_state = __quest_state["Level 4"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "place.php?whichplace=bathole";
	
    if (base_quest_state.mafia_internal_step >= 5)
    {
        subentry.entries.listAppend("Quest finished, speak to the council of loathing.");
        url = "place.php?whichplace=town";
    }
    else if ($location[the boss bat\'s lair].locationAvailable())
    {
        subentry.entries.listAppend("Possibly run +meat in the boss bat's lair. (250 meat drop)");
        subentry.modifiers.listAppend("+meat");
		if (delayRemainingInLocation($location[the boss bat\'s lair]) > 0)
		{
			string line = "Delay for " + pluralise(delayRemainingInLocation($location[the boss bat\'s lair]), "turn", "turns") + " before boss bat shows up.";
            subentry.entries.listAppend(line);
		}
    }
    else
    {
        int areas_unlocked = base_quest_state.state_int["areas unlocked"];
        int areas_locked = 3 - areas_unlocked;
        int sonars_needed = MAX(areas_locked - $item[sonar-in-a-biscuit].available_amount(), 0);
        
        
        if (true)
        {
            string line = pluraliseWordy(areas_locked, "area", "areas").capitaliseFirstLetter() + " to unlock";
            /*if ($item[sonar-in-a-biscuit].available_amount() > 0)
                line += ", " + pluralise($item[sonar-in-a-biscuit]);*/
            line += ".";
            subentry.entries.listAppend(line);
        }
        
        if ($item[sonar-in-a-biscuit].available_amount() > 0 && areas_locked > 0 && my_path_id() != PATH_G_LOVER && my_path_id() != PATH_BEES_HATE_YOU)
        {
            int amount = MIN(areas_locked, $item[sonar-in-a-biscuit].available_amount());
            subentry.entries.listAppend("Use " + pluralise(amount, $item[sonar-in-a-biscuit]));
            url = "inventory.php?which=3";
        }
        
        boolean have_stench_resistance = (numeric_modifier("stench resistance") > 0.0);
        if (!have_stench_resistance)
        {
            string line = "Need " + HTMLGenerateSpanOfClass("stench resistance", "r_element_stench") + " to adventure in Guano Junction.";
            string [int] possibilities;
            //This could be more... unified:
            if ($item[ghost of a necklace].available_amount() > 0)
            {
                if ($item[ghost of a necklace].equipped_amount() == 0)
                    line += "|*Equip your ghost of a necklace.";
            }
            else if ($item[bum cheek].available_amount() > 0)
            {
                if ($item[bum cheek].equipped_amount() == 0)
                    line += "|*Equip your bum cheek.";
            }
            else if ($item[knob goblin harem veil].available_amount() == 0)
            {
                possibilities.listAppend("acquire a knob goblin harem veil");
                possibilities.listAppend("finish the first floor of spookyraven manor");
            }
            else
            {
                if ($item[knob goblin harem veil].equipped_amount() == 0)
                {
                    possibilities.listAppend("equip your knob goblin harem veil");
                }
            }
            if ($skill[elemental saucesphere].have_skill())
            {
                possibilities.listAppend("cast elemental saucesphere");
            }
            else if (my_class() == $class[sauceror])
                possibilities.listAppend("learn elemental saucesphere at guild trainer");
            if (possibilities.count() > 0)
                line += "|*Possibly " + possibilities.listJoinComponents(", ", "or") + ".";
            
            subentry.entries.listAppend(line);
        }
        
        
        if (__misc_state["can use clovers"] && sonars_needed >= 2 && my_path_id() != PATH_G_LOVER)
            subentry.entries.listAppend("Potentially clover Guano Junction for two sonar-in-a-biscuit");
        if ($item[enchanted bean].available_amount() == 0 && !__quest_state["Level 10"].state_boolean["beanstalk grown"])
        {
            if ($location[the beanbat chamber].locationAvailable())
                subentry.entries.listAppend("Run +100% item in the beanbat chamber for a single turn for enchanted bean. (50% drop)");
            else
                subentry.entries.listAppend("When beanbat chamber is unlocked, run +100% item for a single turn there for enchanted bean (50% drop)");
        }
        
        int total_turns = $location[Guano Junction].turns_spent + $location[The Batrat and Ratbat Burrow].turns_spent + $location[The Beanbat Chamber].turns_spent;
        int turns_until_next_screambat = 8 - (total_turns % 8);
        if (turns_until_next_screambat == 8 && total_turns != 0) turns_until_next_screambat = 0;
        boolean screambat_up_now = false;
        
        if (turns_until_next_screambat == 0)
        {
            screambat_up_now = true;
            subentry.entries.listAppend("Screambat next turn.");
        }
        else
            subentry.entries.listAppend("Screambat after " + pluraliseWordy(turns_until_next_screambat, "turn", "turns") + ".");
        
        if (!screambat_up_now && my_path_id() != PATH_G_LOVER)
        {
            if (__misc_state["yellow ray available"] && sonars_needed > 0)
                subentry.entries.listAppend("Potentially yellow ray for sonar-in-a-biscuit.");
            if (sonars_needed > 0)
                subentry.entries.listAppend("Run +item in the batrat and ratbat burrow for biscuits. (15% drop)");
            subentry.modifiers.listAppend("+566% item");
        }
        //subentry.entries.listAppend("Run +meat in the boss bat's lair, if you wish. (250 meat drop)");
	}
    
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the bat hole entrance, guano junction, the batrat and ratbat burrow, the beanbat chamber,the boss bat's lair]));
}
