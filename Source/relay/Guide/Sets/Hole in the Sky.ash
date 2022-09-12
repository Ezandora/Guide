
boolean HITSStillRelevant()
{
	if (__misc_state["Example mode"])
		return true;
	if (!__misc_state["in run"])
		return false;
	if (__quest_state["Level 13"].state_boolean["Richard's star key used"])
		return false;
	if (!__quest_state["Level 10"].finished && my_path_id_legacy() != PATH_EXPLOSIONS)
		return false;
        
	return true;
}

void QHitsInit()
{
    //This isn't really a quest...
	QuestState state;
    
    state.quest_name = "Hole in the Sky";
    state.image_name = "Hole in the Sky";
    
    
    int charts_want = 0;
    int stars_want = 0;
    int lines_want = 0;
    
	if ($item[richard's star key].available_amount() == 0)
    {
		charts_want += 1;
		stars_want += 8;
		lines_want += 7;
    }
    
    if (!HITSStillRelevant())
    {
        charts_want = 0;
        stars_want = 0;
        lines_want = 0;
    }
    
    state.state_int["star charts needed"] = MAX(0, charts_want - $item[star chart].available_amount());
    state.state_int["stars needed"] = MAX(0, stars_want - $item[star].available_amount());
    state.state_int["lines needed"] = MAX(0, lines_want - $item[line].available_amount());
    
	__quest_state["Hole in the Sky"] = state;
}

void QHitsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!HITSStillRelevant())
		return;
	ChecklistSubentry subentry;
	subentry.header = "Hole in the Sky";
	
    string active_url = "";
    //Super unclear code. Sorry.
    //FIXME rewrite now that we don't need equipment
    
    int star_charts_needed = 0;
    int stars_needed_base = 0;
    int lines_needed_base = 0;
    
    string [int] item_names_needed;
    
	if ($item[richard's star key].available_amount() == 0)
	{
		star_charts_needed += 1;
		stars_needed_base += 8;
		lines_needed_base += 7;
		item_names_needed.listAppend($item[richard's star key]);
	}
    int [int] stars_needed_options;
    int [int] lines_needed_options;
    string [int] needed_options_names;
	if (needed_options_names.count() == 0)
	{
		stars_needed_options.listAppend(stars_needed_base + 0);
		lines_needed_options.listAppend(lines_needed_base + 0);
	}
	
	//Convert what we need total to what's remaining:
	int star_charts_remaining = MAX(0, star_charts_needed - $item[star chart].available_amount());
    int [int] stars_remaining;
    int [int] lines_remaining;
    string [int] remaining_options_names;
    
    boolean have_met_stars_requirement = true;
    boolean have_met_lines_requirement = true;
    
    foreach key in stars_needed_options
    {
    	if (needed_options_names contains key)
	    	remaining_options_names[key] = needed_options_names[key];
    	stars_remaining[key] = MAX(0, stars_needed_options[key] - $item[star].available_amount());
    	lines_remaining[key] = MAX(0, lines_needed_options[key] - $item[line].available_amount());
    	
    	if (stars_remaining[key] > 0)
    		have_met_stars_requirement = false;
    	if (lines_remaining[key] > 0)
    		have_met_lines_requirement = false;
    }
    
    if (__misc_state["Example mode"])
    {
        star_charts_remaining = 1;
        have_met_stars_requirement = false;
        have_met_lines_requirement = false;
    }
    
    if (have_met_stars_requirement)
    {
    	//Have all stars, suggest star sword (least lines)
    	//Remove non-sword:
    	foreach key in remaining_options_names
    	{
    		if (remaining_options_names[key] != "star sword")
    		{
    			remove remaining_options_names[key];
    			remove stars_remaining[key];
    			remove lines_remaining[key];
    		}
    	}
    }
    else if (have_met_lines_requirement)
    {
    	//Have all lines, suggest star crossbow (least stars)
    	//Remove non-crossbow:
    	foreach key in remaining_options_names
    	{
    		if (remaining_options_names[key] != "star crossbow")
    		{
    			remove remaining_options_names[key];
    			remove stars_remaining[key];
    			remove lines_remaining[key];
    		}
    	}
    }
    if (remaining_options_names.count() > 0)
    {
        item_names_needed.listAppend(remaining_options_names.listJoinComponents("/", ""));
    }
	
	if (item_names_needed.count() == 0)
		return;
		
	
	if (!$location[the hole in the sky].locationAvailable())
	{
		//find a way to space:
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Run -combat on the top floor of the castle for the steam-powered model rocketship.|From steampunk non-combat, unlocks Hole in the Sky.");
        active_url = "place.php?whichplace=giantcastle";
        
        
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(95, 1, "", 9));
	}
	else
	{
        active_url = "place.php?whichplace=beanstalk";
		//We've made it out to space:
		subentry.entries.listAppend("Need " + item_names_needed.listJoinComponents(", ", "and") + ".");
		
		string [int] required_components;
		if (star_charts_remaining > 0)
			required_components.listAppend(pluralise(star_charts_remaining, $item[star chart]));
		foreach key in stars_remaining
		{
			string [int] line;
			if (stars_remaining[key] > 0)
				line.listAppend(pluralise(stars_remaining[key], $item[star]));
			if (lines_remaining[key] > 0)
				line.listAppend(pluralise(lines_remaining[key], $item[line]));
			string route = "";
			if (remaining_options_names contains key)
			{
				route = " (" + remaining_options_names[key];
				if (stars_remaining.count() > 1)
					route += " route";
				route += ")";
			}
			if (line.count() > 0)
				required_components.listAppend(line.listJoinComponents(" / ") + route);
		}
		if (required_components.count() > 0)
		{
            if (star_charts_remaining == 1 && have_met_stars_requirement && have_met_lines_requirement && !in_hardcore())
            {
                subentry.entries.listAppend("Can pull a star chart.");
            }
			//require more components:
			if (remaining_options_names.count() <= 1)
				subentry.entries.listAppend("Need " + required_components.listJoinComponents(", ", ""));
			else
				subentry.entries.listAppend("Need:|*" + required_components.listJoinComponents("|*", "or"));
        
            //FIXME if we need only one type, recommend a different monster to olfact
            
            if (star_charts_remaining > 0 && in_hardcore())
            {
                //olfact nothing, interferes with astronomers
                //they prefer interferometry
            }
            else if (!have_met_stars_requirement || !have_met_lines_requirement)
            {
                if (my_ascensions() % 2 == 0)
                    subentry.entries.listAppend("Olfact skinflute.");
                else
                    subentry.entries.listAppend("Olfact camel's toe.");
            }
            
			if (!have_met_stars_requirement || !have_met_lines_requirement)
				subentry.modifiers.listAppend("+234% item");
                
            if ($familiar[space jellyfish].familiar_is_usable())
            {
                //Space Directions NC:
                //39, 46
                int turns_spent = $location[the hole in the sky].turns_spent;
                boolean nc_up = false;
                int turns_to_next_nc = 0;
                if (turns_spent < 2)
                    turns_to_next_nc = 2 - turns_spent;
                else
                    turns_to_next_nc = 7 - (turns_spent - 2) % 7;
                    
                if (turns_spent == 2)
                    nc_up = true;
                else if ((turns_spent - 2) % 7 == 0)
                    nc_up = true;
                if (nc_up)
                {
                    //Apparently skipping the NC just makes it re-appear the next adventure?
                    if (true) //get_property("lastEncounter") != "Space Directions")
                    {
                        string line = "";
                        string [int] choices;
                        boolean an = false;
                        if (star_charts_remaining > 0)
                        {
                            choices.listAppend("astronomer");
                            an = true;
                        }
                        if (!have_met_stars_requirement || !have_met_lines_requirement)
                        {
                            choices.listAppend("camel's toe");
                        }
                        if ($familiar[space jellyfish] != my_familiar())
                            line = HTMLGenerateSpanFont("Bring along your space jellyfish", "red") + ", it'll let you choose a " + choices.listJoinComponents(", ", "or");
                        else
                            line = "Jellyfish NC next adventure. Will let you fight a" + (an ? "n" : "") + " " + choices.listJoinComponents(", ", "or");
                        /*if (star_charts_remaining > 0)
                        {
                            choices.listAppend("astronomer");
                            line = HTMLGenerateSpanFont("Bring along your space jellyfish", colour) + ", it'll let you choose an astronomer/camel";
                        }
                        else
                            line = HTMLGenerateSpanFont("Possibly bring along your space jellyfish", colour) + ", it'll let you choose an camel";*/
                        line += " this adventure.";
                        if (!have_met_stars_requirement || !have_met_lines_requirement)
                            line += "|Though that will reduce your +item, so choose wisely.";
                        subentry.entries.listAppend(line);
                    }
                }
                else
                {
                    if (get_property_int("singleFamiliarRun").to_familiar() != $familiar[space jellyfish] && $familiar[space jellyfish] == my_familiar())
                    {
                        subentry.entries.listAppend(HTMLGenerateSpanFont("Switch to another familiar?", "red"));
                    }
                    string line = pluraliseWordy(turns_to_next_nc, "more turn", "more turns").capitaliseFirstLetter() + " to jellyfish choice NC.";
                    subentry.entries.listAppend(line);
                }
            }
		}
		else
			subentry.entries.listAppend("Can make Richard's Star Key.");
	}
	optional_task_entries.listAppend(ChecklistEntryMake(388, "hole in the sky", active_url, subentry, $locations[the hole in the sky, the castle in the clouds in the sky (top floor)]));
}


void QHitsGenerateMissingItems(ChecklistEntry [int] items_needed_entries)
{
	if (!__misc_state["in run"] && !__misc_state["Example mode"])
		return;
	if (__quest_state["Level 13"].state_boolean["Richard's star key used"])
		return;
	//is this the best way to convey this information?
	//maybe all together instead? complicated...
    string url = $location[the hole in the sky].getClickableURLForLocation();
    if (!$location[the hole in the sky].locationAvailable())
        url = $location[The Castle in the Clouds in the Sky (basement)].getClickableURLForLocation();
	if ($item[richard's star key].available_amount() == 0)
	{
		string [int] oh_my_stars_and_gauze_garters;
		oh_my_stars_and_gauze_garters.listAppend(MIN(1, $item[star chart].available_amount()) + "/1 star chart");
		oh_my_stars_and_gauze_garters.listAppend(MIN(8, $item[star].available_amount()) + "/8 stars");
		oh_my_stars_and_gauze_garters.listAppend(MIN(7, $item[line].available_amount()) + "/7 lines");
		items_needed_entries.listAppend(ChecklistEntryMake(389, "__item richard's star key", url, ChecklistSubentryMake("Richard's star key", "", oh_my_stars_and_gauze_garters.listJoinComponents(", ", "and"))));
	}
}
