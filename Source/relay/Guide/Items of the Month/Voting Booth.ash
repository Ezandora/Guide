
//Throw your voting boot:
RegisterTaskGenerationFunction("IOTMVotingBootGenerateTasks");
void IOTMVotingBootGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__iotms_usable[$item[voter registration form]]) return;
    
    if ($item[&quot;I Voted!&quot; sticker].available_amount() == 0 || false)
    {
    	//Vote!
        string [int] description;
        if (in_ronin())
	        description.listAppend("Gives special modifiers, and unlocks three free fights to burn delay.");
        else
            description.listAppend("Gives special modifiers.");
        optional_task_entries.listAppend(ChecklistEntryMake(574, "__item &quot;I Voted!&quot; sticker", "place.php?whichplace=town_right&action=townright_vote", ChecklistSubentryMake("Vote!", "", description), 8));
    }
    
    if ($item[&quot;I Voted!&quot; sticker].available_amount() == 0) return;
    if (total_turns_played() % 11 == 1 && get_property_int("lastVoteMonsterTurn") < total_turns_played() && get_property_int("_voteFreeFights") < 3)
    {
    	string url = "";
        string [int] description;
        if ($item[&quot;I Voted!&quot; sticker].equipped_amount() == 0)
        {
        	description.listAppend(HTMLGenerateSpanFont("Equip the I Voted! sticker first.", "red"));
            url = generateEquipmentLink($item[&quot;I Voted!&quot; sticker]);
        }
        description.listAppend("Free fight that burns delay.");
        location [int] possible_locations = generatePossibleLocationsToBurnDelay();
        if (possible_locations.count() > 0)
        {
            description.listAppend("Adventure in " + possible_locations.listJoinComponents(", ", "or") + " to burn delay.");
            if (url == "")
                url = possible_locations[0].getClickableURLForLocation();
        }
        monster fighting_monster = get_property_monster("_voteMonster");
        string title = "Fight voting monster";
        if (fighting_monster != $monster[none])
        	title += " " + fighting_monster;
        task_entries.listAppend(ChecklistEntryMake(575, "__item &quot;I Voted!&quot; sticker", url, ChecklistSubentryMake(title, "", description), -11));
    }
    if (get_property_int("_voteFreeFights") < 3 && !(total_turns_played() % 11 == 1 && get_property_int("lastVoteMonsterTurn") < total_turns_played()))
    {
    	int turns_left = 11 - (((total_turns_played() % 11) - 1 + 11) % 11);
        
        optional_task_entries.listAppend(ChecklistEntryMake(576, "__item &quot;I Voted!&quot; sticker", "", ChecklistSubentryMake("Voting monster after " + pluralise(turns_left, "More Turn", "more turns") + "", "", "Free fight to burn delay with."), 10));
    }
    if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5 && get_property_int("_voteFreeFights") >= 3 && total_turns_played() % 11 == 1 && get_property_int("lastVoteMonsterTurn") < total_turns_played() && $skill[meteor lore].have_skill() && get_property_int("_macrometeoriteUses") < 10 && !CounterLookup("portscan.edu").CounterWillHitNextTurn() && $location[Sonofa Beach].locationAvailable())
    {
        string title = "Lobsterfrogman voting macrometeorite trick time";
        string [int] description;
        string url = "";
        monster fighting_monster = get_property_monster("_voteMonster");
        if ($item[&quot;I Voted!&quot; sticker].equipped_amount() == 0)
        {
            description.listAppend(HTMLGenerateSpanFont("Equip the I Voted! sticker first.", "red"));
            url = generateEquipmentLink($item[&quot;I Voted!&quot; sticker]);
        }
        description.listAppend("Adventure in the sonofa beach, macrometeorite the " + (fighting_monster == $monster[none] ? "voting monster" : fighting_monster.to_string()) + ", and you'll get a lobsterfrogman.");
        task_entries.listAppend(ChecklistEntryMake(577, "__item &quot;I Voted!&quot; sticker", url, ChecklistSubentryMake(title, "", description), -11));
    	
    }
}

/*RegisterResourceGenerationFunction("IOTMVotingBootGenerateResource");
void IOTMVotingBootGenerateResource(ChecklistEntry [int] resource_entries)
{
	
    if ($item[&quot;I Voted!&quot; sticker].available_amount() == 0) return;
    
    if (get_property_int("_voteFreeFights") < 3 && !(total_turns_played() % 11 == 1 && get_property_int("lastVoteMonsterTurn") < total_turns_played()))
    {
    	
    }
}*/
