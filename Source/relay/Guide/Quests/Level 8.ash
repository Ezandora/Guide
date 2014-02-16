import "relay/Guide/Sets/Copied Monsters.ash" //A quaint and curious import.

void QLevel8Init()
{
	//questL08Trapper
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL08Trapper");
	state.quest_name = "Trapper Quest";
	state.image_name = "trapper";
	state.council_quest = true;
    
	
	if (state.mafia_internal_step > 2)
		state.state_boolean["Past mine"] = true;
	if (state.mafia_internal_step > 3)
		state.state_boolean["Mountain climbed"] = true;
	if (state.mafia_internal_step > 5)
		state.state_boolean["Groar defeated"] = true;
	
	state.state_string["ore needed"] = get_property("trapperOre").HTMLEscapeString();
	
	if (my_level() >= 8)
		state.startable = true;
	
	__quest_state["Level 8"] = state;
	__quest_state["Trapper"] = state;
}


void QLevel8GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 8"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 8"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	string talk_to_trapper_string = "Go talk to the trapper.";
    
    float cold_resistance = numeric_modifier("cold resistance");
    string need_cold_res_string = "acquire " + (5.0 - cold_resistance).to_int() + " more " + HTMLGenerateSpanOfClass("cold resistance", "r_element_cold");
	
	if (base_quest_state.mafia_internal_step == 1)
	{
		subentry.entries.listAppend(talk_to_trapper_string);
	}
	else if (!base_quest_state.state_boolean["Past mine"])
	{
		string cheese_header; //string cheese
		string [int] cheese_lines;
		
		cheese_header = MIN(3, $item[goat cheese].available_amount()) + "/3 goat cheese found";
		if ($item[goat cheese].available_amount() <3 )
			cheese_header += " (40% drop)";
		
		boolean need_cheese = $item[goat cheese].available_amount() <3;
		
		if (need_cheese)
		{
			subentry.modifiers.listAppend("150% item");
			if (__misc_state["have olfaction equivalent"])
				subentry.modifiers.listAppend("olfact dairy goats");
			
				
			if (have_skill($skill[Advanced Saucecrafting]))
				cheese_lines.listAppend("Have " + pluralize($item[glass of goat's milk]) + " for magnesium (20% drop)");
		}
		
		subentry.entries.listAppend(cheese_header + HTMLGenerateIndentedText(cheese_lines));
		
		
		
		string ore_header;
		string [int] ore_lines;
		item ore_needed = to_item(base_quest_state.state_string["ore needed"]);
		
		ore_header = MIN(3, ore_needed.available_amount()) + "/3 " + ore_needed + " found";
		
		boolean need_ore = ore_needed.available_amount() <3;
		if (need_ore)
		{
			string [int] potential_ore_sources;
			potential_ore_sources.listAppend("Mining");
			potential_ore_sources.listAppend("Clovering itznotyerzitzmine (one of each ore, consider if zap available?)");
			
			
			
			boolean need_outfit = true;
			if (have_outfit_components("Mining Gear"))
				need_outfit = false;
			if (my_path_id() == PATH_AVATAR_OF_BORIS)
			{
				subentry.modifiers.listAppend("+150%/+1000% item");
				need_outfit = false;
				potential_ore_sources.listClear();
				potential_ore_sources.listAppend("Fight mountain men in the mine (40%, 10% drop for each ore)");
			}
			if (my_path_id() == PATH_WAY_OF_THE_SURPRISING_FIST)
			{
				string have_skill_text = "";
				if (!have_skill($skill[worldpunch]))
					have_skill_text = " (you do not have this skill yet)";
				potential_ore_sources.listAppend("Earthen Fist will allow mining." + have_skill_text);
				need_outfit = false;
			}
			ore_lines.listAppend("Potential sources of ore:" + HTMLGenerateIndentedText(potential_ore_sources));
			if (have_skill($skill[unaccompanied miner]))
				ore_lines.listAppend("You can free mine. Consider splitting mining over several days for zero-adventure cost.");
			if (need_outfit)
			{
				subentry.modifiers.listAppend("-combat");
				ore_lines.listAppend("Mining outfit not available. Consider acquiring one via -combat in mine or the semi-rare (30% drop)");
			}
		
		}
		subentry.entries.listAppend(ore_header + HTMLGenerateIndentedText(ore_lines));
		
		if (!need_cheese && !need_ore)
		{
			subentry.entries.listClear();
			subentry.entries.listAppend(talk_to_trapper_string);
			
		}
	}
	else if (!base_quest_state.state_boolean["Mountain climbed"])
	{
        //ninja:
        string ninja_line;
        boolean ninja_finishes_quest = false;
        if (true)
        {
            string [int] ninja_path;
            string [int] ninja_modifiers;
            
            item [int] items_needed;
            if ($item[ninja rope].available_amount() == 0) items_needed.listAppend($item[ninja rope]);
            if ($item[ninja carabiner].available_amount() == 0) items_needed.listAppend($item[ninja carabiner]);
            if ($item[ninja crampons].available_amount() == 0) items_needed.listAppend($item[ninja crampons]);
            
            if (items_needed.count() == 0)
            {
                if (cold_resistance < 5.0)
                    ninja_path.listAppend(need_cold_res_string.capitalizeFirstLetter() + ".");
                    
                ninja_path.listAppend("Climb the peak.");
                ninja_finishes_quest = true;
            }
            else
            {
                ninja_path.listAppend("Need " + items_needed.listJoinComponents(", ", "and") + ".");
                string [int] assassin_description;
                
                if (get_property_int("_romanticFightsLeft") > 0 && get_property_int("_romanticFightsLeft") >= items_needed.count() && get_property("romanticTarget") == "ninja snowman assassin")
                {
                    ninja_path.listAppend("They will find you.");
                }
                else
                {
                    ninja_modifiers.listAppend("+combat");
                    ninja_path.listAppend("Run +combat in Lair of the Ninja Snowmen, fight assassins.");
                    CopiedMonstersGenerateDescriptionForMonster("ninja snowman assassin", assassin_description, true, false);
                    ninja_path.listAppend(assassin_description.listJoinComponents("|"));
                    if (combat_rate_modifier() < 0.0)
                        ninja_path.listAppend("Need more +combat, assassins won't appear at " + combat_rate_modifier() + "% combat.");
                }
            }
            
            ninja_line = "Ninja path:";
            
            if (ninja_modifiers.count() > 0)
                ninja_line += "|*" + ChecklistGenerateModifierSpan(ninja_modifiers) + "|";
            ninja_line += HTMLGenerateIndentedText(ninja_path.listJoinComponents("<hr>"));
            
            if (ninja_finishes_quest)
                ninja_line = ninja_path.listJoinComponents("<hr>");
        }
        //eXtreme outfit:
        string extreme_line;
        if (true)
        {
            string [int] extreme_path;
            string [int] extreme_modifiers;
            
            
            
            item [int] items_needed = missing_outfit_components("eXtreme Cold-Weather Gear");
        
            if (items_needed.count() == 0)
            {
                if (!is_wearing_outfit("eXtreme Cold-Weather Gear"))
                    extreme_path.listAppend("Wear eXtreme Cold-Weather Gear, run -combat, become eXtreme, jump onto the mountain top.");
                else
                    extreme_path.listAppend("Run -combat, become eXtreme, jump onto the mountain top.");
                extreme_modifiers.listAppend("-combat");
            }
            else
            {
                extreme_path.listAppend("Acquire outfit components: " + items_needed.listJoinComponents(", ", "and") + ".");
                extreme_modifiers.listAppend("-combat");
                extreme_modifiers.listAppend("+item");
                extreme_path.listAppend("Run -combat and maybe +item on the eXtreme slope.");
            }
        
            extreme_line = "Extreme path:";
            
            if (extreme_modifiers.count() > 0)
                extreme_line += "|*" + ChecklistGenerateModifierSpan(extreme_modifiers) + "|";
            extreme_line += HTMLGenerateIndentedText(extreme_path.listJoinComponents("<hr>"));
            
        }
        if (!ninja_finishes_quest)
            subentry.entries.listAppend("Find a way to climb the peak.");
        subentry.entries.listAppend(ninja_line);
        if (!ninja_finishes_quest) //ninja need not tricks
            subentry.entries.listAppend(extreme_line);
	}
	else if (!base_quest_state.state_boolean["Groar defeated"])
	{
        int turns_remaining = MAX(0, 4 - $location[mist-shrouded peak].turnsAttemptedInLocation());
		string [int] todo;
		if (cold_resistance < 5.0)
			todo.listAppend(need_cold_res_string);
		todo.listAppend("fight Groar at the peak");
		subentry.entries.listAppend(todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
		
        if (turns_remaining > 1)
        {
            subentry.modifiers.listAppend("+meat");
            subentry.entries.listAppend("Optionally run +meat for " + pluralizeWordy((turns_remaining - 1), "turn", "turns") + ". (200 base meat drop)");
        }
	}
	else
	{
		subentry.entries.listAppend(talk_to_trapper_string);
	}
	
	
	
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "place.php?whichplace=mclargehuge", subentry, $locations[itznotyerzitz mine,the goatlet, lair of the ninja snowmen, the extreme slope,mist-shrouded peak, itznotyerzitz mine (in disguise)]));
}