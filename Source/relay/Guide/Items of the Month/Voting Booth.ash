
//Throw your voting boot:
RegisterTaskGenerationFunction("IOTMVotingBootGenerateTasks");
void IOTMVotingBootGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!mafiaIsPastRevision(18965))
        return;
    if (!__iotms_usable[lookupItem("voter registration form")]) return;
    
    if (lookupItem("&quot;I Voted!&quot; sticker").available_amount() == 0 || false) {
        //Vote!
        string [int] description;
        if (in_ronin())
            description.listAppend("Gives special modifiers, and unlocks three free fights to burn delay.");
        else
            description.listAppend("Gives special modifiers.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", "place.php?whichplace=town_right&action=townright_vote", ChecklistSubentryMake("Vote!", "", description), 8));
        return;
    }
    
    int turns_before_vote_fight = 11 - (((total_turns_played() % 11) - 1 + 11) % 11);
    boolean vote_fight_now = total_turns_played() % 11 == 1 && get_property_int("lastVoteMonsterTurn") < total_turns_played();
    int vote_free_fights_left = 3 - get_property_int("_voteFreeFights");

    if (vote_free_fights_left > 0) {
        if (vote_fight_now) {
            string url = "";
            string [int] description;
            if (lookupItem("&quot;I Voted!&quot; sticker").equipped_amount() == 0) {
                description.listAppend(HTMLGenerateSpanFont("Equip the I Voted! sticker first.", "red"));
                url = "inventory.php?ftext=i+voted!";
            }
            description.listAppend("Free fight that burns delay. " + vote_free_fights_left + " left.");
            location [int] possible_locations = generatePossibleLocationsToBurnDelay();
            if (possible_locations.count() > 0) {
                description.listAppend("Adventure in " + possible_locations.listJoinComponents(", ", "or") + " to burn delay.");
                if (url == "")
                    url = possible_locations[0].getClickableURLForLocation();
            }
            monster fighting_monster = get_property_monster("_voteMonster");
            string title = "Fight voting monster";
            if (fighting_monster != $monster[none])
                title += " " + fighting_monster;
            task_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", url, ChecklistSubentryMake(title, "", description), -11));
        } else {
            optional_task_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", "", ChecklistSubentryMake("Voting monster after " + pluralise(turns_before_vote_fight, "More Turn", "more turns") + "", "", "Free fight to burn delay with (" + vote_free_fights_left + " left)."), 10));
        }
    }

    if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5 && vote_free_fights_left <= 0 && vote_fight_now && $skill[meteor lore].have_skill() && get_property_int("_macrometeoriteUses") < 10 && !CounterLookup("portscan.edu").CounterWillHitNextTurn() && $location[Sonofa Beach].locationAvailable()) { //Could change this to make it compatible with Replace Enemy?
        string title = "Lobsterfrogman voting macrometeorite trick time";
        string [int] description;
        string url = "";
        monster fighting_monster = get_property_monster("_voteMonster");
        if (lookupItem("&quot;I Voted!&quot; sticker").equipped_amount() == 0) {
            description.listAppend(HTMLGenerateSpanFont("Equip the I Voted! sticker first.", "red"));
            url = "inventory.php?ftext=i+voted!";
        }
        description.listAppend("Adventure in the sonofa beach, macrometeorite the " + (fighting_monster == $monster[none] ? "voting monster" : fighting_monster.to_string()) + ", and you'll get a lobsterfrogman.");
        task_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", url, ChecklistSubentryMake(title, "", description), -11));
        
    }
}

RegisterResourceGenerationFunction("IOTMVotingBootGenerateResource");
void IOTMVotingBootGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupItem("&quot;I Voted!&quot; sticker").available_amount() == 0) return;
    
    int vote_free_fights_left = 3 - get_property_int("_voteFreeFights");
    if (get_property_int("_voteFreeFights") < 3) {
        resource_entries.listAppend(ChecklistEntryMake("__item &quot;I Voted!&quot; sticker", "", ChecklistSubentryMake(pluralise(vote_free_fights_left, "voting monster", "voting monsters"), "", "Free fight."), 8).ChecklistEntryTagEntry("daily free fight"));
    }
}
