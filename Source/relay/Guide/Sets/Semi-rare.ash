import "relay/Guide/Support/Location Choice.ash";

void SemirareGenerateDescription(string [int] description)
{
	if (CounterLookup("Semi-rare").CounterIsRange())
    {
        boolean fortune_output = false;
        string line;
        if (__misc_state["can eat just about anything"] && my_path_id() != PATH_NUCLEAR_AUTUMN && my_path_id() != PATH_G_LOVER)
        {
            line = "Eat a fortune cookie";
            if (availableFullness() <= 0)
                line += " later.";
            else
                line += ".";
            fortune_output = true;
        }
        if (__misc_state["VIP available"] && __misc_state["can drink just about anything"] && $item[Clan speakeasy].is_unrestricted())
        {
            if (fortune_output)
                line += " Or drink a Lucky Lindy";
            else
                line += "Drink a Lucky Lindy";
            if (availableDrunkenness() <= 0 || get_property_int("_speakeasyDrinksDrunk") >= 3)
                line += " later.";
            else
                line += ".";
            
        }
        if (CounterLookup("Semi-rare").CounterMayHitNextTurn())
        {
            description.listAppend("Already in counter window, probably should ignore this?");
        }
        else if (line != "")
            description.listAppend(line);
	}
	location last_location = $location[none];
	if (get_property_ascension("lastSemirareReset") && get_property("semirareLocation") != "")
	{
		last_location = get_property_location("semirareLocation");
        if (last_location != $location[none])
            description.listAppend("Last semi-rare: " + last_location);
	}
	
	
    LocationChoice [int] semirares;
	//Generate things to do:
	if (__misc_state["in run"])
	{
		if (__misc_state["can equip just about any weapon"])
		{
			if (!have_outfit_components("Knob Goblin Elite Guard Uniform"))
			{
				string [int] reasons;
				if (!__quest_state["Level 8"].finished)
					reasons.listAppend("Cobb's Knob quest");
                if (!dispensary_available())
                {
                    if (__misc_state["familiars temporarily blocked"])
                        reasons.listAppend("dispensary access (+item, cheapish MP)");
                    else
                        reasons.listAppend("dispensary access (+item, +familiar weight, cheapish MP)");
                }
                if (reasons.count() > 0)
                    semirares.listAppend(LocationChoiceMake($location[cobb's knob barracks], "|*Acquire KGE outfit for " + reasons.listJoinComponents(", ", "and"), 0));
			}
			if (!have_outfit_components("Mining Gear") && !__quest_state["Level 8"].state_boolean["Past mine"])
				semirares.listAppend(LocationChoiceMake($location[Itznotyerzitz Mine], "|*Acquire mining gear for trapper quest.|*Run +234% item to get drop.", 0));
		}
        int wool_needed = 1;
        if ($item[the nostril of the serpent].available_amount() == 0)
            wool_needed += 1;
		if ($item[stone wool].available_amount() < wool_needed && !locationAvailable($location[the hidden park]))
		{
			semirares.listAppend(LocationChoiceMake($location[The Hidden Temple], "|*Acquire stone wool for unlocking hidden city.|*Run +100% item. (or up to +400% item for +3 adventures)", 0));
		}
		if ($item[Mick's IcyVapoHotness Inhaler].available_amount() == 0 && $effect[Sinuses For Miles].have_effect() == 0 && !__quest_state["Level 12"].state_boolean["Nuns Finished"])
			semirares.listAppend(LocationChoiceMake($location[the castle in the clouds in the sky (top floor)], "|*+200% meat inhaler (10 turns), for nuns quest.", 0));
	
		//limerick dungeon - +100% item
		if ($item[cyclops eyedrops].available_amount() == 0 && $effect[One Very Clear Eye].have_effect() == 0)
			semirares.listAppend(LocationChoiceMake($location[the limerick dungeon], "|*+100% items eyedrops (10 turns), for tomb rats and low drops.", 0));
        if (in_bad_moon() && $item[bram's choker].available_amount() == 0)
			semirares.listAppend(LocationChoiceMake($location[The Haunted Boiler Room], "|*-5% combat accessory.", 0));
		//three turn generation SRs go here
		if (my_path_id() != PATH_SLOW_AND_STEADY)
		{
			LocationChoice food_semirares;
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
        
        //FIXME does small golem cause the wall of bones to reform?
        /*if (!__quest_state["Level 13"].state_boolean["past tower monsters"] && $item[small golem].available_amount() == 0 && (get_property("grimstoneMaskPath") == "gnome" || $item[grimstone mask].available_amount() > 0))
        {
            boolean can_create_golem = false;
            if ($item[clay].available_amount() >= 1 && ($item[leather].available_amount() >= 3 || $item[parchment].available_amount() >= 1))
                can_create_golem = true;
            if (!can_create_golem)
                semirares.listAppend(LocationChoiceMake($location[Ye Olde Medievale Villagee], "Small golem (towerkilling)", 0));
        }*/
        if (in_bad_moon() && __quest_state["Level 13"].state_boolean["shadow will need to be defeated"] && $item[scented massage oil].available_amount() + $item[scented massage oil].closet_amount() == 0 && !$skill[Ambidextrous Funkslinging].have_skill())
            semirares.listAppend(LocationChoiceMake($location[Cobb's Knob Harem], "|*Scented massage oil for shadow.", 0)); //theoretically, we could ignore this for DBs that aren't in a black cat run
	}
		
	//aftercore? sea quest, sand dollars, giant pearl
	
    LocationChoiceSort(semirares);
    
    //Post-process:
    foreach key in semirares
    {
		LocationChoice sr = semirares[key];
		if (last_location == sr.place && sr.place != $location[none])
			sr.reasons.listAppend(HTMLGenerateSpanOfClass("Can't use yet, last semi-rare was here", "r_bold"));
    }
	
    description.listAppendList(LocationChoiceGenerateDescription(semirares));
	/*foreach key in semirares
	{
		LocationChoice sr = semirares[key];
		string [int] explanation = sr.reasons;
		
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
			line = HTMLGenerateDivOfClass(line, "r_future_option");
		}
		description.listAppend(line);
	}*/
}



void SSemirareGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
    Counter semirare_counter = CounterLookup("Semi-rare");
    if (!semirare_counter.CounterExists())
        return;
    
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
    
    if (semirare_counter.CounterIsRange())
	{
        Vec2i turn_range = semirare_counter.CounterGetWindowRange();
        
        string turn_range_x_string = turn_range.x;
        if (turn_range.x <= -1)
            turn_range_x_string = "Past";
        if (turn_range.x == 0)
            turn_range_x_string = "Now";
        
        title = "[" + turn_range_x_string + " to " + turn_range.y + "] turns until semi-rare";
        
        min_turns_until = turn_range.x;
        
        if (turn_range.x <= 0)
            very_important = true;
        if (turn_range.y < 0)
            return;
	}
	else if (semirare_counter.exact_turns.count() > 0)
	{
        if (semirare_counter.exact_turns.count() == 1)
        {
			int turns_until = semirare_counter.exact_turns[0];
			if (turns_until == 0)
			{
				very_important = true;
				title = "Semi-rare now";
			}
			else
				title = pluralise(turns_until, "turn", "turns") + " until semi-rare";
				
			min_turns_until = turns_until;
        }
        else
        {
			min_turns_until = semirare_counter.exact_turns[0];
            string [int] turn_list;
            
            foreach key in semirare_counter.exact_turns
            {
                int value = semirare_counter.exact_turns[key];
                if (value == 0)
                {
                    very_important = true;
                    turn_list.listAppend("Now");
                }
                else if (!(value < 0))
                    turn_list.listAppend(value.to_string());
            }
            
			title = turn_list.listJoinComponents(", ", "or") + " turns until semi-rare";
        }
			
	}
	else
        return;
	
	if (from_task && min_turns_until > show_up_in_tasks_turn_cutoff)
		return;
	if (!from_task && min_turns_until <= show_up_in_tasks_turn_cutoff)
		return;
		
	string [int] description;
	if (title != "")
	{
		SemirareGenerateDescription(description);
	}
    if (very_important && __misc_state["monsters can be nearly impossible to kill"] && monster_level_adjustment() > 0)
        description.listAppend(HTMLGenerateSpanFont("Possibly remove +ML to survive. (at +" + monster_level_adjustment() + " ML)", "red"));
	boolean very_important_reduces_size = description.count() > 1;
    
	if (title != "")
	{
		int importance = 4;
		if (very_important)
        {
            if (very_important_reduces_size)
                importance = -10;
            else
                importance = -11;
        }
		ChecklistEntry entry = ChecklistEntryMake("__item fortune cookie", "", ChecklistSubentryMake(title, "", description), importance);
		if (very_important)
        {
			task_entries.listAppend(entry);
            
            if (very_important_reduces_size)
            {
                boolean setting_use_mouse_over_technique = false;
                string secondary_description = "[...]";
                if (!setting_use_mouse_over_technique)
                    secondary_description = "Scroll up for full description.";
                ChecklistEntry pop_up_reminder_entry = ChecklistEntryMake("__item fortune cookie", "", ChecklistSubentryMake(title, "", secondary_description), -11);
                pop_up_reminder_entry.only_show_as_extra_important_pop_up = true;
                pop_up_reminder_entry.container_div_attributes["onclick"] = "navbarClick(0, 'Tasks_checklist_container')";
                pop_up_reminder_entry.container_div_attributes["class"] = "r_clickable";
                
                //this feature is very, very buggy, so disable it:
                if (setting_use_mouse_over_technique)
                    pop_up_reminder_entry.subentries_on_mouse_over = entry.subentries;
                task_entries.listAppend(pop_up_reminder_entry);
            }
        }
		else
			optional_task_entries.listAppend(entry);
			
	}
}

void SSemirareGenerateResource(ChecklistEntry [int] resource_entries)
{
	SSemirareGenerateEntry(resource_entries, resource_entries, false);
}

void SSemirareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SSemirareGenerateEntry(task_entries, optional_task_entries, true);
}
