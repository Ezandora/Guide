
void QManorInit()
{
	QuestState state;
    
    
    state.state_boolean["need ballroom song set"] = false;
    
    if (true)
        state.state_boolean["need ballroom song set"] = true;
    
    //Trace every quest where it's worth setting the song:
    //Let's see...
    //L2: relevant
    //L3: relevant...? (skipping NCs)
    //L5: theoretically relevant (acquiring the KGE outfit without semi-rare)
    //L6: relevant
    //L7: relevant (two areas)
    //L8: relevant (climbing the mountain, acquiring mining outfit)
    //L9: relevant (twin peak)
    //L10: relevant (everywhere)
    //HitS: relevant (unlock)
    //L11: relevant (black forest, ballroom, pirates, hidden park, temple unlock, city unlock without semi-rare)
    //L12: relevant (starting the war)
    //L13: relevant, but marginal (south of the border, zap wand)
    //Pirates: relevant (acquiring outfit)
    
    //Hardcoded hacky test to see if we can reach -25% on skills alone. So far, this is only possible in one situation in sneaky pete.
    //We can also test this via equipment, but that takes up slots that may be needed for something else. (amulets, mohawk wigs, pirate fledges, war outfits...)
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && lookupSkill("Brood").have_skill() && mafiaIsPastRevision(13785) && get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler" && lookupSkill("Rev Engine").have_skill())
        state.state_boolean["need ballroom song set"] = false;
    
    if (__misc_state_string["ballroom song"] == "-combat")
        state.state_boolean["need ballroom song set"] = false;
    
    state.state_boolean["ballroom song effectively set"] = !state.state_boolean["need ballroom song set"];
    if (combat_rate_modifier() <= -25.0)
        state.state_boolean["ballroom song effectively set"] = true;
    
    
    
	if (locationAvailable($location[the haunted ballroom]) && !state.state_boolean["need ballroom song set"])
		QuestStateParseMafiaQuestPropertyValue(state, "finished");
	else
    {
		QuestStateParseMafiaQuestPropertyValue(state, "started");
    }
	state.quest_name = "Spookyraven Manor Unlock";
	state.image_name = "Spookyraven Manor";
    
	
	/*location zone_to_work_on = $location[none];
	if (!locationAvailable($location[the haunted billiards room]))
	{
		zone_to_work_on = $location[the haunted billiards room];
	}
	else if (!locationAvailable($location[the haunted library]))
	{
		zone_to_work_on = $location[the haunted library];
	}
	else if (!locationAvailable($location[the haunted bedroom]))
	{
		zone_to_work_on = $location[the haunted bedroom];
	}
	else if (!locationAvailable($location[the haunted ballroom]))
	{
		zone_to_work_on = $location[the haunted ballroom];
	}
	state.state_string["zone to work on"] = zone_to_work_on;*/
	
	__quest_state["Manor Unlock"] = state;
}


void QManorGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Manor Unlock"].in_progress)
		return;
    if (!__misc_state["In run"])
        return;
    
    boolean should_output_optionally = false;
	QuestState base_quest_state = __quest_state["Manor Unlock"];
	ChecklistSubentry subentry;
	//subentry.header = "Unlock Spookyraven Manor";
    
    //This is currently very incomplete, sorry.
	
	string url = "";
	
	string image_name = base_quest_state.image_name;
    
    boolean ballroom_probably_open = false;
    if ($location[the haunted ballroom].turnsAttemptedInLocation() > 0)
        ballroom_probably_open = true;
    if (__misc_state_string["ballroom song"].length() > 0) //FALSE if they haven't ascended since the revamp, I guess
        ballroom_probably_open = true;
    
    boolean second_floor_probably_open = false;
    
    if (get_property_int("lastSecondFloorUnlock") == my_ascensions())
        second_floor_probably_open = true;
    if (lookupItem("Lady Spookyraven's necklace").available_amount() > 0) //mostly
        second_floor_probably_open = true;
    if (lookupItem("ghost of a necklace").available_amount() > 0) //not, strictly speaking, true FIXME consider removing if mafia updates lastSecondFloorUnlock
        second_floor_probably_open = true;
    
    if (lookupItem("telegram from Lady Spookyraven").available_amount() > 0)
        second_floor_probably_open = false;
    if (lookupItem("7301").available_amount() == 0 || lookupItem("7302").available_amount() == 0)
        second_floor_probably_open = false;
    
    if (second_floor_probably_open)
    {
        if (lookupItem("Lady Spookyraven's necklace").available_amount() > 0)
        {
            subentry.header = "Speak to Lady Spookyraven";
            url = $location[the haunted kitchen].getClickableURLForLocation();
            image_name = "Lady Spookyraven";
        }
        else
        {
            if (!ballroom_probably_open)
            {
                //Haunted gallery, bathroom, bedroom
                if (lookupItem("Lady Spookyraven's powder puff").available_amount() == 0)
                {
                    //NC [?superlikely] in bathroom
                    //FIXME implement this
                }
                if (lookupItem("Lady Spookyraven's finest gown").available_amount() == 0)
                {
                    //elegant nightstand in bedroom (banish)
                    //also acquire disposable instant camera. spectacles...?
                    //FIXME implement this
                    
                }
                if (lookupItem("Lady Spookyraven's dancing shoes").available_amount() == 0)
                {
                    //NC (louvre or leave it) in gallery
                    //FIXME implement this
                }
            }
        }
    }
    else if (lookupItem("telegram from Lady Spookyraven").available_amount() > 0)
    {
        //telegram is removed on using it, even on old copies of mafia
        subentry.header = "Read telegram from Lady Spookyraven";
        url = "inventory.php?which=3";
        image_name = "__item telegram from Lady Spookyraven";
    }
    else if (lookupItem("7301").available_amount() == 0) //Spookyraven billiards room key
    {
        subentry.header = "Adventure in the Haunted Kitchen";
        url = $location[the haunted kitchen].getClickableURLForLocation();
        image_name = "__item tiny knife and fork";
        subentry.entries.listAppend("To unlock the Haunted Billiards Room.");
        
        subentry.entries.listAppend("Run " + HTMLGenerateSpanOfClass("hot", "r_element_hot") + " resistance and " + HTMLGenerateSpanOfClass("stench", "r_element_stench") + " resistance to search more drawers per turn.");
        subentry.entries.listAppend("Should take about ~25 drawers? Unspaded, sorry.");
        
        subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("hot res", "r_element_hot_desaturated"));
        subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("stench res", "r_element_stench_desaturated"));
    }
    else if (lookupItem("7302").available_amount() == 0) //Spookyraven library key
    {
        //Find key:
        subentry.header = "Adventure in the Haunted Billiards Room";
        url = $location[the Haunted Billiards Room].getClickableURLForLocation();
        image_name = "__item pool cue";
        subentry.entries.listAppend("To unlock the Haunted Library.");
        
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Train pool skill via -combat.");
        
        if ($item[pool cue].available_amount() == 0)
        {
            subentry.entries.listAppend("Find pool cue. (superlikely?)");
            
        }
        else if ($item[pool cue].equipped_amount() == 0)
        {
            subentry.entries.listAppend("Equip pool cue for +pool skill.");
        }
        if ($effect[chalky hand].have_effect() == 0& $item[handful of hand chalk].available_amount() > 0)
            subentry.entries.listAppend(HTMLGenerateSpanOfClass("Use handful of hand chalk", "r_bold") + " for +pool skill and faster pool skill training.");
        
        if (inebriety_limit() > 0)
        {
            //Drunkenness's effect is currently unknown FIXME
            //(last checked, it had zero effect on the listed pool skill, but they may have changed that or it's a hidden modifier ooOoOo)
            int desired_drunkenness = MIN(inebriety_limit(), 10);
            if (my_inebriety() < desired_drunkenness)
            {
                subentry.entries.listAppend("Consider drinking up to " + desired_drunkenness + " drunkenness. (may affect pool skill, unspaded)");
            }
            else if (my_inebriety() > desired_drunkenness)
                subentry.entries.listAppend("Consider waiting for rollover for better pool skill. (you're over " + desired_drunkenness + " drunkenness. This is a guess, needs spading)");
        }
    }
    else
    {
        //Library:
        subentry.header = "Adventure in the Haunted Library";
        url = $location[the Haunted Billiards Room].getClickableURLForLocation();
        image_name = "__item very overdue library book";
        subentry.modifiers.listAppend("olfact writing desk");
        
        subentry.entries.listAppend("To unlock the second floor.");
        subentry.entries.listAppend("Lady Spookyraven's Necklace drops from the fifth writing desk you encounter.");
        
        if ($item[killing jar].available_amount() == 0 && !__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"] && !__quest_state["Level 11 Pyramid"].state_boolean["Killing Jar Given"])
        {
            subentry.modifiers.listAppend("+900% item");
            subentry.entries.listAppend("Try to acquire a killing jar to speed up the desert later.|10% drop from banshee librarian.");
        }
        
    }
    
	
	/*location next_zone = to_location(base_quest_state.state_string["zone to work on"]);
	
	if (next_zone == $location[the haunted billiards room])
	{
		subentry.header = "Open the Haunted Billiards Room";
		url = "place.php?whichplace=town_right";
		image_name = "spookyraven manor locked";
		
		subentry.entries.listAppend("Adventure in the Haunted Pantry. (right side of the tracks)");
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			
		if (have_skill($skill[summon smithsness]) && $item[dirty hobo gloves].available_amount() == 0 && $item[hand in glove].available_amount() == 0 && __misc_state["Need to level"])
		{
			subentry.modifiers.listAppend("-combat");
			subentry.modifiers.listAppend("+234% item");
			subentry.entries.listAppend("Run +234% item and -combat for dirty hobo glove, for hand in glove. (+lots ML accessory)|Potentially olfact half-orc hobo as well, to find said glove in the back alley.");
		}
			
		if (subentry.modifiers.count() > 0)
			subentry.entries.listAppend("Ten turn delay. (use " + listJoinComponents(subentry.modifiers, ", ") + ")");
		else
			subentry.entries.listAppend("Ten turn delay.");
        
        
        if ($classes[pastamancer, sauceror] contains my_class() && !guild_store_available()) //FIXME tracking guild quest being started
            subentry.entries.listAppend("Possibly start your guild quest if you haven't.");
		
	}
	else if (next_zone == $location[the haunted library])
	{
		subentry.header = "Open the Haunted Library";
		url = "place.php?whichplace=spookyraven1";
		image_name = "haunted billiards room";
		
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		
		
		subentry.entries.listAppend("Adventure in the Haunted Billiards Room.");
		if ($item[pool cue].available_amount() == 0)
			subentry.entries.listAppend("Acquire a pool cue. (superlikely)");
		if (delayRemainingInLocation($location[the haunted billiards room]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the haunted billiards room]), "turn", "turns") + ".";
			if (__misc_state["have hipster"])
			{
				line += " (use " + __misc_state_string["hipster name"] + ")";
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
			subentry.entries.listAppend(line);
			subentry.entries.listAppend("Then run chalky hands once you have a pool cue. (use handful of hand chalk, 100% wraith drop)");
		}
		else if ($item[pool cue].available_amount() == 0)
			subentry.entries.listAppend("Run chalky hand and -combat once you have a pool cue. (use handful of hand chalk, 100% wraith drop)");
        else
        {
            if ($effect[chalky hand].have_effect() == 0)
                subentry.entries.listAppend("Run chalky hand. (use handful of hand chalk, 100% wraith drop)");
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat.");
            
            float nc_rate = 1.0 - (0.75 + combat_rate_modifier() / 100.0);
            float turns_to_finish = -1.0;
            if (nc_rate != 0.0)
                turns_to_finish = 1.0 / nc_rate;
            if (turns_to_finish != -1.0)
                subentry.entries.listAppend("~" + turns_to_finish.roundForOutput(1) + " turns to unlock at " + combat_rate_modifier().floor() + "% combat.");
        }
	}
	else if (next_zone == $location[the haunted bedroom])
	{
		subentry.header = "Open the Haunted Bedroom";
		url = "place.php?whichplace=spookyraven1";
		image_name = "haunted library";

        
		subentry.entries.listAppend("Adventure in the Haunted Library.");
		if (delayRemainingInLocation($location[the haunted library]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the haunted library]), "turn", "turns") + ".";
			if (__misc_state["have hipster"])
			{
				line += " (use " + __misc_state_string["hipster name"] + ")";
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
			line += "|Then run -combat.";
			subentry.entries.listAppend(line);
		}
		else
		{
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Run -combat.");
            
            float nc_rate = 1.0 - (0.75 + combat_rate_modifier() / 100.0);
            float turns_to_finish = -1.0;
            if (nc_rate != 0.0)
                turns_to_finish = 1.0 / nc_rate;
            if (turns_to_finish != -1.0)
                subentry.entries.listAppend("~" + turns_to_finish.roundForOutput(1) + " turns to unlock at " + combat_rate_modifier().floor() + "% combat.");
		}
        if ($item[killing jar].available_amount() == 0 && !__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"] && !__quest_state["Level 11 Pyramid"].state_boolean["Killing Jar Given"])
        {
            subentry.modifiers.listAppend("+900% item");
            subentry.entries.listAppend("Try to acquire a killing jar to speed up the desert later.|10% drop from banshee librarian.");
        }
		
		if (my_primestat() == $stat[muscle] && !locationAvailable($location[the haunted gallery]) && !__misc_state["Stat gain from NCs reduced"])
			subentry.entries.listAppend("Optionally, unlock gallery key conservatory adventure:|*Fall of the House of Spookyraven" + __html_right_arrow_character + "Chapter 2: Stephen and Elizabeth.");
	}
	else if (next_zone == $location[the haunted ballroom])
	{
		subentry.header = "Open the Haunted Ballroom";
		url = "place.php?whichplace=spookyraven2";
		image_name = "haunted bedroom";
		subentry.entries.listAppend("Adventure in the Haunted Bedroom.");
		
		if ($item[lord spookyraven's spectacles].available_amount() == 0)
			subentry.entries.listAppend("Acquire Lord Spookyraven's spectacles from ornate drawer NC.");
        if (__quest_state["Level 11 Palindome"].state_boolean["Need instant camera"] && 7266.to_item().available_amount() == 0)
			subentry.entries.listAppend("Acquire disposable instant camera from ornate drawer NC.");
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Run -combat.");
        
        //I think this is what lastBallroomUnlock does? It's when the key has dropped down?
        boolean clink_done = get_property_int("lastBallroomUnlock") == my_ascensions();
        if (clink_done)
            subentry.entries.listAppend("Unlock ballroom key. Wooden nightstand, second choice.");
        else
            subentry.entries.listAppend("Unlock ballroom key in two-step process. Wooden nightstand, first choice, then second.");
		
		//combat queue for haunted bedroom doesn't seem to update
        int delay_remaining = 5; //delayRemainingInLocation($location[the haunted bedroom])
		if (delay_remaining > 0 && !clink_done)
		{
			//string line = "Delay for " + pluralize(delay_remaining), "turn", "turns") + ".";
            string line = "Delay for 5 total turns. (can't track this, sorry)";
			if (__misc_state["have hipster"])
			{
				line += " (use " + __misc_state_string["hipster name"] + ")";
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
			subentry.entries.listAppend(line);
		}
        //Once delay is tracked:
        /*int ncs_needed = 4;
        if (!clink_done)
            ncs_needed *= 2;
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(20, ncs_needed, "", 0, delay_remaining));*/
	/*}
	else if (base_quest_state.state_boolean["need ballroom song set"])
	{
		next_zone = $location[The Haunted Ballroom];
		subentry.header = "Set -combat ballroom song";
		url = "place.php?whichplace=spookyraven2";
		//image_name = "Haunted Ballroom";
        image_name = "__item the Legendary Beat";
		subentry.modifiers.listAppend("-combat");
        
        subentry.entries.listAppend("Adventure in the Haunted Ballroom.");
        
        if (my_turncount() > 200 || base_quest_state.state_boolean["ballroom song effectively set"])
        {
            subentry.entries.listAppend("Well, unless you won't need -combat.");
            should_output_optionally = true;
        }
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 2, ""));
	}*/
	
	if (subentry.header.length() > 0)
    {
        ChecklistEntry entry = ChecklistEntryMake(image_name, url, subentry, $locations[the haunted pantry, the haunted library, the haunted billiards room, the haunted bedroom, the haunted ballroom]);
        if (should_output_optionally)
            optional_task_entries.listAppend(entry);
        else
            task_entries.listAppend(entry);
    }
}