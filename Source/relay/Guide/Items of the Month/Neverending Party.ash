RegisterTaskGenerationFunction("IOTMNeverendingPartyGenerateTasks");
void IOTMNeverendingPartyGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!mafiaIsPastRevision(18865))
        return;
    if (!__iotms_usable[lookupItem("Neverending Party invitation envelope")])
        return;
    //Quest suggestions:
    //_partyHard (boolean), _questPartyFair (Quest), _questPartyFairProgress (integer?), _questPartyFairQuest (string? - "partiers", )
    
    QuestState quest_state = QuestState("_questPartyFair");
    //_questPartyFair is "" instead of unstarted if they didn't start it.
    if (quest_state.in_progress)
    {
        string quest_name = get_property("_questPartyFairQuest");
        //strange - went from "unstarted" to "step1" when accepting the partiers quest
        boolean party_hard = get_property_boolean("_partyHard");
        int [int] progress_split;
        foreach key, v in get_property("_questPartyFairProgress").split_string(" ")
        {
        	if (v == "") continue;
            progress_split.listAppend(v.to_int());
        }
        int progress = progress_split[0];
        
        string [int] modifiers;
        string [int] description;
        string url = "place.php?whichplace=town_wrong";
        boolean finished = false;
        if (party_hard && lookupItem("PARTY HARD T-shirt").equipped_amount() == 0)
        {
            description.listAppend(HTMLGenerateSpanFont("Equip the PARTY HARD T-shirt.", "red"));
            url = "inventory.php?ftext=party+hard+t-shirt";
        }
        //partiers - progress starts at 50 in not-hard
        if (quest_name == "partiers")
        {
            if (progress > 0)
            {
            	description.listAppend(pluralise(progress, "partier", "partiers") + " remain.");
                if (lookupItem("intimidating chainsaw").available_amount() == 0)
                {
                	description.listAppend("Collect the intimidating chainsaw.|" + listMake("Investigate the basement", "Grab the chainsaw").listJoinComponents(__html_right_arrow_character));
                }
                else if (lookupItem("intimidating chainsaw").equipped_amount() == 0)
                {
                	description.listAppend(HTMLGenerateSpanFont("Equip the intimidating chainsaw.", "red"));
                    url = "inventory.php?ftext=intimidating+chainsaw";
                }
                if (lookupItem("jam band bootleg").item_amount() > 0)
                {
                    description.listAppend("Pop in the bootleg.|" + listMake("Head Upstairs", "Pop a bootleg in the stereo").listJoinComponents(__html_right_arrow_character));
                }
                else if (!in_ronin())
                {
                    description.listAppend("Buy a jam band bootleg in the mall?");
                }
                if (lookupItem("Purple Beast energy drink").item_amount() > 0)
                {
                    description.listAppend("Pour the energy drink into the pool.|" + listMake("Go to the back yard", "Pour Purple Beast into the pool").listJoinComponents(__html_right_arrow_character));
                }
                else if (!in_ronin())
                {
                    description.listAppend("Buy a Purple Beast energy drink in the mall?");
                }
            }
            else
            {
            	finished = true;
            }
        }
        else if (quest_name == "booze")
        {
            //unremarkable duffel bag gives item; from jock
            
            if (quest_state.mafia_internal_step < 2)
            {
                description.listAppend("Talk to Gerald.|" + listMake("Go to the back yard", "Find Gerald").listJoinComponents(__html_right_arrow_character));
            }
            else
            {
            	int amount_needed = progress_split[0];
                item item_needed = progress_split[1].to_item();
                if (item_needed == $item[none])
                {
                	description.listAppend("Unknown item needed.");
                }
                else if (item_needed.item_amount() < amount_needed)
                {
                	description.listAppend("Need to collect " + amount_needed + " " + item_needed + ".");
                    description.listAppend("Can collect from unremarkable duffel bags, from the jock.");
                    modifiers.listAppend("olfact jock");
                }
                else
                    description.listAppend("Talk to Gerald.|" + listMake("Go to the back yard", "Give Gerald the booze").listJoinComponents(__html_right_arrow_character));
            }
        }
        else if (quest_name == "food")
        {
            //van key gives item; from burnout
            
            if (quest_state.mafia_internal_step < 2)
            {
                description.listAppend("Talk to Geraldine.|" + listMake("Check out the kitchen", "Talk to the woman").listJoinComponents(__html_right_arrow_character));
            }
            else
            {
                int amount_needed = progress_split[0];
                item item_needed = progress_split[1].to_item();
                
                if (item_needed == $item[none])
                {
                    description.listAppend("Unknown item needed.");
                }
                else if (item_needed.item_amount() < amount_needed)
                {
                    description.listAppend("Need to collect " + amount_needed + " " + item_needed + ".");
                    description.listAppend("Can collect from van keys, from the burnout.");
                    modifiers.listAppend("olfact burnout");
                }
                else
                	description.listAppend("Talk to Geraldine again.|" + listMake("Check out the kitchen", "Give Geraldine the snacks").listJoinComponents(__html_right_arrow_character));
            }
        }
        else if (quest_name == "trash")
        {
            if (true)
            {
            	modifiers.listAppend("+200% item");
                //Progress on this quest seems to be bugged - starts at zero, doesn't change unless we look at the quest log.
                //description.listAppend("Progress: " + progress);
                description.listAppend("Run +200% item.");
                if (lookupItem("gas can").item_amount() > 0)
                {
                    description.listAppend(listMake("Check out the kitchen", "Burn some trash").listJoinComponents(__html_right_arrow_character));
                }
                else if (!in_ronin())
                {
                    description.listAppend("Buy a gas can in the mall?");
                }
            }
            else
            {
            	finished = true;
            }
        }
        else if (quest_name == "woots")
        {
            if (progress < 100)
            {
                description.listAppend(progress + " out of 100 megawoots.");
                //equip cosmetic football
                if (lookupItem("cosmetic football").available_amount() == 0 && !in_ronin())
                {
                    description.listAppend("Buy the cosmetic football in the mall?");
                }
                if (lookupItem("cosmetic football").available_amount() > 0 && lookupItem("cosmetic football").equipped_amount() == 0)
                {
                    description.listAppend(HTMLGenerateSpanFont("Equip the cosmetic football.", "red"));
                    url = "inventory.php?ftext=cosmetic+football";
                }
                //very small red dress
                if (lookupItem("very small red dress").item_amount() > 0)
                {
                    description.listAppend(listMake("Head upstairs", "Toss the red dress on the lamp").listJoinComponents(__html_right_arrow_character));
                }
                else if (!in_ronin())
                {
                    description.listAppend("Buy a very small red dress in the mall?");
                }
                //electronics kit
                if (lookupItem("electronics kit").item_amount() > 0)
                {
                    description.listAppend(listMake("Investigate the basement", "Modify the living room lights").listJoinComponents(__html_right_arrow_character));
                }
                else if (!in_ronin())
                {
                    description.listAppend("Buy a electronics kit in the mall?");
                }
            }
            else
            	finished = true;
        }
        else if (quest_name == "dj")
        {
            if (progress > 0)
            {
                modifiers.listAppend("+meat");
                modifiers.listAppend("olfact jocks");
                modifiers.listAppend("banish burnouts");
                description.listAppend(progress + " meat remaining.");
                description.listAppend("Run +meat, olfact jocks, banish burnouts.");
                if (my_buffedstat($stat[moxie]) >= 300)
                {
                    description.listAppend("Open the safe.|" + listMake("Head upstairs", "Crack the safe").listJoinComponents(__html_right_arrow_character));
                }
                else
                {
                	description.listAppend("Possibly buff to 300 moxie?");
                    modifiers.listAppend("300 moxie");
                }
            }
            else
            	finished = true;
        }
        else if (quest_name == "")
        {
        }
        else
            description.listAppend("Unhandled quest \"" + quest_name + "\"");
        if (finished)
        {
        	description.listAppend("Visit the party one last time to finish the quest.");
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item party hat", url, ChecklistSubentryMake("Neverending Party Quest", modifiers, description), 8, lookupLocations("The Neverending Party")));
    }
}

RegisterResourceGenerationFunction("IOTMNeverendingPartyGenerateResource");
void IOTMNeverendingPartyGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!mafiaIsPastRevision(18865))
        return;
    if (!__iotms_usable[lookupItem("Neverending Party invitation envelope")])
        return;
    
    int free_fights_left = clampi(10 - get_property_int("_neverendingPartyFreeTurns"), 0, 10);
    if (QuestState("_questPartyFair").finished)
    	free_fights_left = 0;
    string [int] modifiers;
    string [int] description;
    modifiers.listAppend("+meat");
    
    if (free_fights_left >= 2)
    {
        if (__misc_state["need to level"])
        {
            string [int] directions;
            if (my_primestat() == $stat[muscle])
            {
                directions.listAppend("Kitchen");
                directions.listAppend("Muscle spice");
            }
            else if (my_primestat() == $stat[mysticality])
            {
                directions.listAppend("Upstairs");
                directions.listAppend("Read the tomes");
            }
            else if (my_primestat() == $stat[moxie])
            {
                directions.listAppend("Basement");
                directions.listAppend("Use the hair gel");
            }
            description.listAppend("Experience buff: " + directions.listJoinComponents(__html_right_arrow_character) + ".");
        }
        if (__misc_state["in run"])
            description.listAppend("ML buff: " + listMake("Backyard", "Candle wax").listJoinComponents(__html_right_arrow_character));
    }
    if (free_fights_left > 0)
	    resource_entries.listAppend(ChecklistEntryMake("__item party hat", "place.php?whichplace=town_wrong", ChecklistSubentryMake(pluralise(free_fights_left, "free party fight", "free party fights"), modifiers, description), lookupLocations("The Neverending Party")).ChecklistEntryTagEntry("daily free fight"));
    
}
