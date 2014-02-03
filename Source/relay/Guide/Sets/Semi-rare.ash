
record Semirare
{
    location place;
    string [int] reasons;
    int importance;
};

Semirare SemirareMake(location place, string [int] reasons, int importance)
{
    Semirare result;
    result.place = place;
    result.reasons = reasons;
    result.importance = importance;
    return result;
}

Semirare SemirareMake(location place, string reason, int importance)
{
    return SemirareMake(place, listMake(reason), importance);
}

void listAppend(Semirare [int] list, Semirare entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void SemirareGenerateDescription(string [int] description)
{
	if (__misc_state_string["Turn range until semi-rare"] != "" && __misc_state["can eat just about anything"])
	{
		string line = "Eat a fortune cookie";
		if (availableFullness() == 0)
			line += " later.";
        else
            line += ".";
		description.listAppend(line);
	}
	location last_location = $location[none];
	if (get_property_int("lastSemirareReset") == my_ascensions() && get_property("semirareLocation") != "")
	{
		last_location = get_property_location("semirareLocation");
        if (last_location != $location[none])
            description.listAppend("Last semi-rare: " + last_location);
	}
	
	
    Semirare [int] semirares;
	//Generate things to do:
	if (__misc_state["In run"])
	{
		if (__misc_state["can equip just about any weapon"])
		{
			if (!have_outfit_components("Knob Goblin Elite Guard Uniform"))
			{
				string [int] reasons;
				if (!__quest_state["Level 8"].finished)
					reasons.listAppend("Cobb's Knob quest");
                if (!dispensary_available())
                    reasons.listAppend("dispensary access (+item, +familiar weight, cheapish MP)");
                if (reasons.count() > 0)
                    semirares.listAppend(SemirareMake($location[cobb's knob barracks], "|*Acquire KGE outfit for " + reasons.listJoinComponents(", ", "and"), 0));
			}
			if (!have_outfit_components("Mining Gear") && !__quest_state["Level 8"].state_boolean["Past mine"])
				semirares.listAppend(SemirareMake($location[Itznotyerzitz Mine], "|*Acquire mining gear for trapper quest.|*Run +234% item to get drop.", 0));
		}
		if ($item[stone wool].available_amount() < 2 && !locationAvailable($location[the hidden park]))
		{
			semirares.listAppend(SemirareMake($location[The Hidden Temple], "|*Acquire stone wool for unlocking hidden city.|*Run +100% item. (or up to +400% item for +3 adventures)", 0));
		}
		if ($item[Mick's IcyVapoHotness Inhaler].available_amount() == 0 && $effect[Sinuses For Miles].have_effect() == 0 && !__quest_state["Level 12"].state_boolean["Nuns Finished"])
			semirares.listAppend(SemirareMake($location[the castle in the clouds in the sky (top floor)], "|*+200% meat inhaler (10 turns), for nuns quest.", 0));
	
		//limerick dungeon - +100% item
		if ($item[cyclops eyedrops].available_amount() == 0 && $effect[One Very Clear Eye].have_effect() == 0)
			semirares.listAppend(SemirareMake($location[the limerick dungeon], "|*+100% items eyedrops (10 turns), for tomb rats and low drops.", 0));
	
        if (needMoreFamiliarWeightForTower())
        {
			semirares.listAppend(SemirareMake($location[cobb's knob menagerie\, level 2], "|*+10 familiar weight, for tower familiars.", 0));
        }
		//three turn generation SRs go here
		if (true)
		{
			Semirare food_semirares;
			food_semirares.importance = 11;
		
			string [int] line;
			if (__misc_state["can eat just about anything"] && last_location != $location[the haunted pantry])
				line.listAppend("The Haunted Pantry: 3 epic fullness food");
			if (__misc_state["can drink just about anything"] && last_location != $location[the sleazy back alley])
				line.listAppend("The Sleazy Back Alley: 3 epic drunkenness drink");
			if (__misc_state["can eat just about anything"] && __misc_state["can drink just about anything"] && last_location != $location[the outskirts of cobb's knob])
				line.listAppend("The Outskirts of Cobb's Knob: 3 epic full drunkenness food/drink");
			food_semirares.reasons.listAppend(line.listJoinComponents("|"));
			if (line.count() > 0)
				semirares.listAppend(food_semirares);
		}
	}
		
	//aftercore? sea quest, sand dollars, giant pearl
	
	sort semirares by value.importance;
	
	foreach key in semirares
	{
		Semirare sr = semirares[key];
		string [int] explanation = sr.reasons;
		
		
		if (last_location == sr.place && sr.place != $location[none])
			explanation.listAppend(HTMLGenerateSpanOfClass("Can't use yet, last semi-rare was here", "r_bold"));
		
		if (explanation.count() == 0)
			continue;
		string first = sr.place.to_string();
		if (sr.place == $location[none])
			first = "";
			
		string line;
		if (explanation.count() > 1)
		{
			line = first + HTMLGenerateIndentedText(HTMLGenerateDiv(explanation.listJoinComponents("<hr>")));
		}
		else
		{
			line = listFirstObject(explanation);
			if (line.stringHasPrefix("|") || first == "")
				line = first + line;
			else
				line = first + ": " + line;
		}
		//string line = first + HTMLGenerateIndentedText(HTMLGenerateDiv(explanation.listJoinComponents(HTMLGenerateDivOfStyle("", "border-top:1px solid;width:30%;"))));
		if (!locationAvailable(sr.place) && sr.place != $location[none])
		{
			line = HTMLGenerateSpanOfClass(line, "r_future_option");
		}
		description.listAppend(line);
	}
}



void SSemirareGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
	if (__misc_state_string["Turns until semi-rare"] != "")
	{
		string [int] potential_turns = split_string_mutable(__misc_state_string["Turns until semi-rare"], ",");
		
		if (potential_turns.count() == 1)
		{
			int turns_until = potential_turns[0].to_int();
			if (turns_until == 0)
			{
				very_important = true;
				title = "Semi-rare now";
			}
			else
				title = pluralize(turns_until, "turn", "turns") + " until semi-rare";
				
			min_turns_until = turns_until;
		}
		else
		{
			min_turns_until = potential_turns[0].to_int();
			if (potential_turns[0].to_int() == 0)
            {
				very_important = true;
                potential_turns[0] = "Now"; //don't like editing this, possibly copy list?
            }
			title = potential_turns.listJoinComponents(", ", "or") + " turns until semi-rare";
		}
			
	}
	else if (__misc_state_string["Turn range until semi-rare"] != "")
	{
		string [int] turn_range_string = split_string_mutable(__misc_state_string["Turn range until semi-rare"], ",");
		if (turn_range_string.count() == 2) //should be
		{
			Vec2i turn_range = Vec2iMake(turn_range_string[0].to_int(), turn_range_string[1].to_int());
			title = "[" + turn_range_string.listJoinComponents(" to ") + "] turns until semi-rare";
			
			min_turns_until = turn_range.x;
			
			if (turn_range.x <= 0)
				very_important = true;
		}
		else
			return; //internal bug
	}
	
	if (from_task && min_turns_until > show_up_in_tasks_turn_cutoff)
		return;
	if (!from_task && min_turns_until <= show_up_in_tasks_turn_cutoff)
		return;
		
	string [int] description;
	if (title != "")
	{
		SemirareGenerateDescription(description);
	}
	
	if (title != "")
	{
		int importance = 4;
		if (very_important)
			importance = -11;
		ChecklistEntry entry = ChecklistEntryMake("__item fortune cookie", "", ChecklistSubentryMake(title, "", description), importance);
		if (very_important)
			task_entries.listAppend(entry);
		else
			optional_task_entries.listAppend(entry);
			
	}
}

void SSemirareGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SSemirareGenerateEntry(available_resources_entries, available_resources_entries, false);
}

void SSemirareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SSemirareGenerateEntry(task_entries, optional_task_entries, true);
}