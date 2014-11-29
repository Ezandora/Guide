
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
        if ($location[the boss bat's lair].locationAvailable())
            state.state_int["areas unlocked"] = 3;
            
	}
	else if (state.finished)
	{
		state.state_int["areas unlocked"] = 3;
	}
	
	if (my_level() >= 4)
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
	
    if (false) //mafia used to update to step4 upon acquiring the bandana - FIXME update to test for that when mafia updates for new boss bat
    {
        subentry.entries.listAppend("Quest finished, speak to the council of loathing.");
        url = "place.php?whichplace=town";
    }
    else if ($location[the boss bat's lair].locationAvailable())
    {
        subentry.entries.listAppend("Possibly run +meat in the boss bat's lair. (250 meat drop)");
        subentry.modifiers.listAppend("+meat");
		if (delayRemainingInLocation($location[the boss bat's lair]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the boss bat's lair]), "turn", "turns") + " before boss bat shows up.";
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
            string line = pluralizeWordy(areas_locked, "area", "areas").capitalizeFirstLetter() + " to unlock";
            /*if ($item[sonar-in-a-biscuit].available_amount() > 0)
                line += ", " + pluralize($item[sonar-in-a-biscuit]);*/
            line += ".";
            subentry.entries.listAppend(line);
        }
        
        if ($item[sonar-in-a-biscuit].available_amount() > 0 && areas_locked > 0)
        {
            int amount = MIN(areas_locked, $item[sonar-in-a-biscuit].available_amount());
            subentry.entries.listAppend("Use " + pluralize(amount, $item[sonar-in-a-biscuit]));
            url = "inventory.php?which=3";
        }
        
        boolean have_stench_resistance = (numeric_modifier("stench resistance") > 0.0);
        if (!have_stench_resistance)
        {
            string line = "Need " + HTMLGenerateSpanOfClass("stench resistance", "r_element_stench") + " to adventure in Guano Junction.";
            if ($item[bum cheek].available_amount() > 0)
            {
                if ($item[bum cheek].equipped_amount() == 0)
                    line += "|*Equip your bum cheek.";
            }
            else if ($item[knob goblin harem veil].available_amount() == 0)
                line += "|*Possibly acquire a knob goblin harem veil.";
            else
            {
                if ($item[knob goblin harem veil].equipped_amount() == 0)
                    line += "|*Possibly equip your knob goblin harem veil.";
            }
            subentry.entries.listAppend(line);
        }
        
        
        if (__misc_state["can use clovers"] && sonars_needed >= 2)
            subentry.entries.listAppend("Potentially clover Guano Junction for two sonar-in-a-biscuit");
        if ($item[enchanted bean].available_amount() == 0 && !__quest_state["level 10"].state_boolean["beanstalk grown"])
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
            subentry.entries.listAppend("Screambat after " + pluralizeWordy(turns_until_next_screambat, "turn", "turns") + ".");
        
        if (!screambat_up_now)
        {
            if (__misc_state["yellow ray available"] && sonars_needed > 0)
                subentry.entries.listAppend("Potentially yellow ray for sonar-in-a-biscuit.");
            if (sonars_needed > 0)
                subentry.entries.listAppend("Run +item in the beanbat and batrat burrow for biscuits. (15% drop)");
            subentry.modifiers.listAppend("+566% item");
        }
        //subentry.entries.listAppend("Run +meat in the boss bat's lair, if you wish. (250 meat drop)");
	}
    
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the bat hole entrance, guano junction, the batrat and ratbat burrow, the beanbat chamber,the boss bat's lair]));
}