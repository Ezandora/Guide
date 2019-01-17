
RegisterTaskGenerationFunction("IOTMVotingBootGenerateTasks");
void IOTMVotingBootGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!mafiaIsPastRevision(18965))
        return;
    if (!__iotms_usable[lookupItem("voter registration form")]) return;
    
    if (lookupItem("&quot;I Voted!&quot; sticker").available_amount() == 0 || false)
    {
    	//Vote!
        string [int] description;
        if (in_ronin())
	        description.listAppend("Gives special modifiers, and unlocks three free fights to burn delay.");
        else
            description.listAppend("Gives special modifiers.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", "place.php?whichplace=town_right&action=townright_vote", ChecklistSubentryMake("Vote!", "", description), 8));
    }
    
    if (lookupItem("&quot;I Voted!&quot; sticker").available_amount() > 0 && total_turns_played() % 11 == 1 && get_property_int("lastVoteMonsterTurn") < total_turns_played() && get_property_int("_voteFreeFights") < 3)
    {
    	string url = "";
        string [int] description;
        if (lookupItem("&quot;I Voted!&quot; sticker").equipped_amount() == 0)
        {
        	description.listAppend(HTMLGenerateSpanFont("Equip the I Voted! sticker first.", "red"));
            url = "inventory.php?which=2";
        }
        description.listAppend("Free fight.");
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
        task_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", url, ChecklistSubentryMake(title, "", description), -11));
    	
    }
    
}
