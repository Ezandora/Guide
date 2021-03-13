void QSpookyravenLightsOutGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
    //nextSpookyravenElizabethRoom
    //nextSpookyravenStephenRoom
    
    if (get_property_int("lastLightsOutTurn") >= total_turns_played())
        return;
    
    string next_elizabeth_room = get_property("nextSpookyravenElizabethRoom");
    string next_stephen_room = get_property("nextSpookyravenStephenRoom");
    location next_elizabeth_location = next_elizabeth_room.to_location();
    location next_stephen_location = next_stephen_room.to_location();
    
    int turns_until_next_lights_out = -1;
    
    //Thought about enabling this, but it's better to only show it when they ask for spookyraven tracking, I think...
    //then again, spookyraven tracking doesn't work well with automation (auto-aborts, even if adventuring in relevant locations)
    //turns_until_next_lights_out = 37 - total_turns_played() % 37;
    
    Counter lights_out_counter = CounterLookup("Spookyraven Lights Out");
    if (lights_out_counter.CounterExists() && !lights_out_counter.CounterIsRange())
    {
        //turns_until_next_lights_out = lights_out_counter.CounterGetNextExactTurn(); //LYING.
        turns_until_next_lights_out = 37 - total_turns_played() % 37;
    }
        
    
    if (turns_until_next_lights_out == 37)
        turns_until_next_lights_out = 0;
    
    if (turns_until_next_lights_out == -1)
        return;
    
    string url = "";
    
    ChecklistSubentry [int] important_subentries;
    if (turns_until_next_lights_out == 0 && from_task)
    {
        //now
        if (next_stephen_location != $location[none])
        {
            string [location][int] stephen_area_descriptions;
            stephen_area_descriptions[$location[The Haunted Bedroom]] = listMake("Search for a light", "Search a nearby nightstand", "Check a nightstand on your left");
            stephen_area_descriptions[$location[The Haunted Nursery]] = listMake("Search for a lamp", "Search over by the (gaaah) stuffed animals", "Examine the Dresser", "Open the bear and put your hand inside", "Unlock the box");
            stephen_area_descriptions[$location[The Haunted Conservatory]] = listMake("Make a torch", "Examine the graves", "Examine the grave marked \"Crumbles\"");
            stephen_area_descriptions[$location[The Haunted Billiards Room]] = listMake("Search for a light", "What the heck, let's explore a bit", "Examine the taxidermy heads");
            stephen_area_descriptions[$location[The Haunted Wine Cellar]] = listMake("Try to find a light", "Keep your cool", "Investigate the wine racks", "Examine the Pinot Noir rack");
            stephen_area_descriptions[$location[The Haunted Boiler Room]] = listMake("Look for a light", "Search the barrel", "No, but I will anyway");
            stephen_area_descriptions[$location[The Haunted Laboratory]] = listMake("Search for a light", "Check it out", "Examine the weird machines", "Enter 23-47-99 and turn on the machine", "Oh god");
        
            string [int] description;
            
            string first_line = "";
            if (__misc_state["in run"])
            {
                if (__misc_state["familiars temporarily blocked"])
                    first_line += "Not useful this run. ";
                else
                    first_line += "Situationally useful (+familiar weight) in-run. ";
            }
            if (next_stephen_location == $location[The Haunted Laboratory])
                first_line += HTMLGenerateSpanFont("Will take a turn.", "red");
            else
                first_line += "Will not take a turn.";
            
            if (first_line != "")
                description.listAppend(first_line);
            
            string line = "Adventure in " + next_stephen_room;
            if (next_stephen_location == $location[The Haunted Laboratory])
                line += " to fight Stephen Spookyraven";
            line += ".";
            if (stephen_area_descriptions contains next_stephen_location)
                line += "|*" + stephen_area_descriptions[next_stephen_location].listJoinComponents(__html_right_arrow_character) + ".";
            description.listAppend(line);
            
            url = next_stephen_location.getClickableURLForLocation();
            
            important_subentries.listAppend(ChecklistSubentryMake("Stephen Spookyraven Quest", "", description));
        }
        
        
        if (next_elizabeth_location != $location[none])
        {
            string [location][int] elizabeth_area_descriptions;
            elizabeth_area_descriptions[$location[The Haunted Storage Room]] = listMake("Look out the Window");
            elizabeth_area_descriptions[$location[The Haunted Laundry Room]] = listMake("Check a Pile of Stained Sheets");
            elizabeth_area_descriptions[$location[The Haunted Bathroom]] = listMake("Inspect the Bathtub");
            elizabeth_area_descriptions[$location[The Haunted Kitchen]] = listMake("Make a Snack");
            elizabeth_area_descriptions[$location[The Haunted Library]] = listMake("Go to the Childrens' Section");
            elizabeth_area_descriptions[$location[The Haunted Ballroom]] = listMake("Dance with Yourself");
            elizabeth_area_descriptions[$location[The Haunted Gallery]] = listMake("Check out the Tormented Damned Souls Painting");
        
            string [int] description;
            string first_line = "";
            if (__misc_state["in run"])
                first_line += "Not useful in-run. ";
            if (next_elizabeth_location == $location[The Haunted Gallery])
                first_line += HTMLGenerateSpanFont("Will take a turn.", "red");
            else
                first_line += "Will not take a turn.";
            
            if (first_line != "")
                description.listAppend(first_line);
            
            string line = "Adventure in " + next_elizabeth_room;
            if (next_elizabeth_location == $location[The Haunted Gallery])
                line += " to fight Elizabeth Spookyraven";
            line += ".";
            if (elizabeth_area_descriptions contains next_elizabeth_location)
                line += "|*" + elizabeth_area_descriptions[next_elizabeth_location].listJoinComponents(__html_right_arrow_character) + ".";
            description.listAppend(line);
            
            
            if (url.length() == 0)
                url = next_elizabeth_location.getClickableURLForLocation();
            
            important_subentries.listAppend(ChecklistSubentryMake("Elizabeth Spookyraven Quest", "", description));
        }
    }
    else if ((turns_until_next_lights_out < 6 && from_task) || (turns_until_next_lights_out >= 6 && !from_task))
    {
        //Soon...
        //FIXME should we show this?
        string [int] available_questlines;
        if (next_stephen_location != $location[none])
            available_questlines.listAppend("Stephen");
        if (next_elizabeth_location != $location[none])
            available_questlines.listAppend("Elizabeth");
        if (available_questlines.count() > 0)
        {
            optional_task_entries.listAppend(ChecklistEntryMake(30, "__half Lights Out", "", ChecklistSubentryMake("Lights Out in " + pluralise(turns_until_next_lights_out, "adventure", "adventures"), "", available_questlines.listJoinComponents(",", "and") + " quest " + (available_questlines.count() > 1 ? "lines" : "line") + "."), (from_task ? 5 : 8)));
        }
    }
    
    if (important_subentries.count() > 0)
    {
        if (url == "place.php?whichplace=manor2" && !get_property_ascension("lastSecondFloorUnlock"))
            url = "";
        task_entries.listAppend(ChecklistEntryMake(31, "__half Lights Out", url, important_subentries, -11));
    }
}

void QSpookyravenLightsOutGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QSpookyravenLightsOutGenerateEntry(task_entries, optional_task_entries, true);
    
    if (get_property_int("lastLightsOutTurn") < total_turns_played() && total_turns_played() % 37 == 0 && __misc_state["in run"])
    {
        string [int] exploit_description;
        string url = "";
        if (__iotms_usable[$item[haunted doghouse]])
        {
            location [int] possible_locations;
            boolean [location] all_lights_out_locations;
            all_lights_out_locations[$location[the haunted storage room]] = true;
            all_lights_out_locations[$location[the haunted Laundry Room]] = true;
            //all_lights_out_locations[$location[the haunted Bathroom]] = true; //Very small chance of a demon name, which costs a turn. It happened to me!
            all_lights_out_locations[$location[the haunted Kitchen]] = true;
            all_lights_out_locations[$location[the haunted Library]] = true;
            all_lights_out_locations[$location[the haunted Ballroom]] = true;
            all_lights_out_locations[$location[the haunted Gallery]] = true;
            if ($location[the haunted Bedroom].turns_spent < 10)
                all_lights_out_locations[$location[the haunted Bedroom]] = true;
            all_lights_out_locations[$location[the haunted Nursery]] = true;
            all_lights_out_locations[$location[the haunted Conservatory]] = true;
            all_lights_out_locations[$location[the haunted Billiards Room]] = true;
            all_lights_out_locations[$location[the haunted Wine Cellar]] = true;
            all_lights_out_locations[$location[the haunted Boiler Room]] = true;
            all_lights_out_locations[$location[the haunted Laboratory]] = true;
            
            foreach l in all_lights_out_locations
            {
                if (l.combatTurnsAttemptedInLocation() < 5)
                    continue;
                if (l.noncombat_queue.contains_text("Wooooooof!"))
                    continue;
                possible_locations.listAppend(l);
            }
            if (possible_locations.count() > 0)
            {
                exploit_description.listAppend("Adventure in " + possible_locations.listJoinComponents(", ", "or") + " to potentially trigger a halloweiner adventure.|It won't cost a turn.");
                url = possible_locations[0].getClickableURLForLocation();
            }
        }
        if ($item[turkey blaster].available_amount() + $item[turkey blaster].creatable_amount() > 0 && availableSpleen() >= 2 && get_property_int("_turkeyBlastersUsed") < 3)
        {
            location [int] possible_locations;
            foreach l in $locations[the haunted gallery,the haunted bathroom]
            {
                if (l.delayRemainingInLocation() >= 4 && l.locationAvailable())
                {
                    possible_locations.listAppend(l);
                    
                }
            }
            if (possible_locations.count() > 0)
            {
                exploit_description.listAppend("Adventure in " + possible_locations.listJoinComponents(", ", "or") + ", then chew a turkey blaster to burn delay.");
                if (url == "")
                    url = possible_locations[0].getClickableURLForLocation();
            }
        }
        if (exploit_description.count() > 0)
            task_entries.listAppend(ChecklistEntryMake(32, "__half Lights Out", url, ChecklistSubentryMake("Lights Out Exploit", "", exploit_description), -11));
    }
}

void QSpookyravenLightsOutGenerateResource(ChecklistEntry [int] resource_entries)
{
	QSpookyravenLightsOutGenerateEntry(resource_entries, resource_entries, false);
}
