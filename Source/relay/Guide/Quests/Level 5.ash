
void QLevel5Init()
{
	//questL05Goblin
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL05Goblin");
	state.quest_name = "Knob Goblin Quest";
	state.image_name = "cobb's knob";
	state.council_quest = true;
	
	
	if (my_level() >= 5)
		state.startable = true;
		
	if (get_property("questL05Goblin") == "unstarted" && $item[knob goblin encryption key].available_amount() == 0)
	{
		//start the quest anyways, because they need to acquire the encryption key:
        //there's also an edge case here in BIG!, where you want to avoid visiting the council for a while to yellow ray an outfit
		QuestStateParseMafiaQuestPropertyValue(state, "started");
	}
		
		
	__quest_state["Level 5"] = state;
	__quest_state["Knob Goblin King"] = state;
}


void QLevel5GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 5"].in_progress)
		return;
    if (my_path_id() == PATH_COMMUNITY_SERVICE || __misc_state["in aftercore"])
        return;
    string url = "place.php?whichplace=plains";
	//if the quest isn't started and we have unlocked the barracks, wait until it's started:
	if (get_property("questL05Goblin") == "unstarted" && $item[knob goblin encryption key].available_amount() > 0) //have key already, waiting for quest to start, nothing more to do here
		return;
		
	QuestState base_quest_state = __quest_state["Level 5"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
	boolean should_output = true;
	
	if (!$location[cobb's knob barracks].locationAvailable())
	{
		if ($item[knob goblin encryption key].available_amount() == 0)
		{
			//Need key:
			//Unlocking:
			if (__misc_state["have hipster"])
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			if (__misc_state["free runs available"])
				subentry.modifiers.listAppend("free runs");
                
            int turns_spent = $location[the outskirts of cobb's knob].turns_spent;
            if (turns_spent != -1)
            {
                int delay_turns_remaining = 10 - turns_spent;
                if (delay_turns_remaining == 0)
                    subentry.entries.listAppend("Map appears next turn in cobb's knob.");
                else
                    subentry.entries.listAppend("Delay for " + pluraliseWordy(delay_turns_remaining, "more turn", "more turns") + " in cobb's knob to unlock area.");
            }
            else
                subentry.entries.listAppend("Delay for ten turns in cobb's knob to unlock area.");
            if ($classes[seal clubber, turtle tamer] contains my_class() && !__misc_state["guild open"] && !QuestState("questG09Muscle").started)
            {
                url = "guild.php";
                subentry.entries.listAppend("Start your guild quest first.");
            }
		}
		else if ($item[cobb's knob map].available_amount() > 0 && $item[knob goblin encryption key].available_amount() > 0)
		{
            url = "inventory.php?which=3";
			subentry.entries.listAppend("Use cobb's knob map to unlock area.");
		}
		else if ($item[cobb's knob map].available_amount() == 0 && $item[knob goblin encryption key].available_amount() > 0)
			should_output = false;
	}
	else
	{
        url = "cobbsknob.php";
		//Cobb's knob unlocked. Now to set up for king:
		
		boolean can_use_harem_route = true;
		boolean can_use_kge_route = true;
		
		boolean have_knob_cake_or_ingredients = false;
		have_knob_cake_or_ingredients = ($item[knob cake].available_amount() > 0 || creatable_amount($item[knob cake]) > 0);
		
		if (can_use_kge_route && have_outfit_components("Knob Goblin Elite Guard Uniform") && have_knob_cake_or_ingredients)
			can_use_harem_route = false;
		else if (can_use_harem_route && have_outfit_components("Knob Goblin Harem Girl Disguise") && have_outfit_components("Knob Goblin Elite Guard Uniform")) //only stop guarding after KGE is acquired, for dispensary
			can_use_kge_route = false;
		
		if (!__misc_state["can equip just about any weapon"])
			can_use_kge_route = false;
        string fight_king_string = "fight king";
        if (53 + monster_level_adjustment() > my_buffedstat($stat[moxie]))
            fight_king_string += " (" + (53 + monster_level_adjustment()) + " attack)";
		if (can_use_harem_route)
		{
			string [int] harem_modifiers;
			string [int] harem_lines;
			if (!have_outfit_components("Knob Goblin Harem Girl Disguise"))
			{
				harem_lines.listAppend("Need disguise.|*20% drop from harem girls (olfact)|*Or adventure in zone for eleven (or more) turns.");
				harem_modifiers.listAppend("+400% item");
				harem_modifiers.listAppend("olfact harem girls");
                if ($familiar[slimeling].familiar_is_usable())
                    harem_modifiers.listAppend("slimeling?");
			}
			else
			{
				string [int] things_to_do_before_fighting_king;
				if (!is_wearing_outfit("Knob Goblin Harem Girl Disguise"))
					things_to_do_before_fighting_king.listAppend("wear harem girl disguise");
				if ($effect[Knob Goblin Perfume].have_effect() > 0)
				{
				}
				else
				{
					if ($item[knob goblin perfume].available_amount() > 0)
					{
						things_to_do_before_fighting_king.listAppend("use knob goblin perfume");
					}
					else
					{
						things_to_do_before_fighting_king.listAppend("adventure in harem for perfume");
					}
				}
				things_to_do_before_fighting_king.listAppend(fight_king_string);
				harem_lines.listAppend(things_to_do_before_fighting_king.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
			}
			subentry.entries.listAppend("Harem route:|*" + ChecklistGenerateModifierSpan(harem_modifiers) + harem_lines.listJoinComponents("|*"));
		}
		if (can_use_kge_route)
		{
			string [int] kge_modifiers;
			string [int] kge_lines;
			
			if (!have_outfit_components("Knob Goblin Elite Guard Uniform"))
			{
				int outfit_pieces_needed = 0;
				if ($item[Knob Goblin elite polearm].available_amount() == 0)
					outfit_pieces_needed += 1;
				if ($item[Knob Goblin elite pants].available_amount() == 0)
					outfit_pieces_needed += 1;
				if ($item[Knob Goblin elite helm].available_amount() == 0)
					outfit_pieces_needed += 1;
				//take into account combats?
				//with banishes and slimeling and +item and?
                //too complicated. Possibly remove?
				kge_modifiers.listAppend("-combat");
                if ($familiar[slimeling].familiar_is_usable())
                    kge_modifiers.listAppend("slimeling?");
				string line = "Need knob goblin elite guard uniform.|*Semi-rare in barracks.|*Or run -combat in barracks";
				if (familiar_is_usable($familiar[slimeling]))
					line += " with slimeling";
                    
                line += ".";
                
                line += "|*" + generateTurnsToSeeNoncombat(85, outfit_pieces_needed, "acquire outfit via only non-combats");
				kge_lines.listAppend(line);
			}
			else
			{
				string cook_cake_line  = "cook a knob cake";
                
                 if (!__misc_state["can cook for free"])
                 {
                    cook_cake_line += " (1 adventure";
                    if (skill_is_usable($skill[inigo's incantation of inspiration]))
                        cook_cake_line += ", can use inigo's";
                    cook_cake_line += ")";
                }
				string [int] things_to_do_before_fighting_king;
				if (!is_wearing_outfit("Knob Goblin Elite Guard Uniform"))
					things_to_do_before_fighting_king.listAppend("wear knob goblin elite guard uniform");
                    
                    
                boolean have_first_step = ($item[knob cake pan].available_amount() > 0 || $item[unfrosted Knob cake].available_amount() > 0);
                boolean have_second_step = ($item[knob batter].available_amount() > 0 || $item[unfrosted Knob cake].available_amount() > 0);
                boolean have_third_step = ($item[knob frosting].available_amount() > 0);
                have_third_step = have_third_step && have_second_step && have_first_step;
                have_second_step = have_second_step && have_first_step;
                    
				if ($item[knob cake].available_amount() > 0)
				{
				}
				else if (have_first_step && have_second_step && have_third_step)
				{
					things_to_do_before_fighting_king.listAppend(cook_cake_line);
				}
				else
				{
					
					string times_remaining = "three times";
					if (have_first_step)
						times_remaining = "two times";
					if (have_second_step)
						times_remaining = "One More Time";
					if (have_third_step)
						times_remaining = "zero times?";
					string line = "adventure in kitchens " + times_remaining + " for knob cake components";
					things_to_do_before_fighting_king.listAppend(line);
					things_to_do_before_fighting_king.listAppend(cook_cake_line);
				}
				things_to_do_before_fighting_king.listAppend(fight_king_string);
				kge_lines.listAppend(things_to_do_before_fighting_king.listJoinComponents(", then ", "").capitaliseFirstLetter() + ".");
			}
			subentry.entries.listAppend("Guard route:|*" + ChecklistGenerateModifierSpan(kge_modifiers) + kge_lines.listJoinComponents("|*"));
		}
        if (!__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "")
        {
            stat stat_race_type = __quest_state["Level 13"].state_string["Stat race type"].to_stat();
            
            int change_mcd_to = -1;
            if (stat_race_type == $stat[muscle] && (current_mcd() == 3 || current_mcd() == 7))
                change_mcd_to = -2;
            else if (stat_race_type == $stat[mysticality])
                change_mcd_to = 3;
            else if (stat_race_type == $stat[moxie])
                change_mcd_to = 7;
                
            if (change_mcd_to != -1 && change_mcd_to != current_mcd())
            {
                subentry.entries.listAppend("For the king fight, change MCD to " + change_mcd_to + " for the tower stat test. (+" + stat_race_type.to_lower_case() + ")");
            }
        }
	}
    
	
	if (should_output)
		task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[cobb's knob barracks, cobb's knob kitchens, cobb's knob harem, the outskirts of cobb's knob]));
}