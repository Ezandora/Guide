void QLevel11Init()
{
    if (!__misc_state["In run"])
        return;
	//questL11MacGuffin, questL11Manor, questL11Palindome, questL11Pyramid, questL11Worship
	//hiddenApartmentProgress, hiddenBowlingAlleyProgress, hiddenHospitalProgress, hiddenOfficeProgress, hiddenTavernUnlock
	//relocatePygmyJanitor, relocatePygmyLawyer
	
	
	/*
	gnasirProgress is a bitmap of things you've done with Gnasir to advance desert exploration:

	stone rose = 1
	black paint = 2
	killing jar = 4
	worm-riding manual pages (15) = 8
	successful wormride = 16
	*/
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11MacGuffin");
		state.quest_name = "MacGuffin Quest";
		state.image_name = "MacGuffin";
		state.council_quest = true;
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11"] = state;
		__quest_state["MacGuffin"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Manor");
		state.quest_name = "Lord Spookyraven Quest";
		state.image_name = "Spookyraven manor";
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Manor"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Palindome");
		state.quest_name = "Palindome Quest";
		state.image_name = "Palindome";
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Palindome"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Pyramid");
		state.quest_name = "Pyramid Quest";
		state.image_name = "Pyramid";
		
		int gnasir_progress = get_property_int("gnasirProgress");
		
		state.state_boolean["Stone Rose Given"] = (gnasir_progress & 1) > 0;
		state.state_boolean["Black Paint Given"] = (gnasir_progress & 2) > 0;
		state.state_boolean["Killing Jar Given"] = (gnasir_progress & 4) > 0;
		state.state_boolean["Manual Pages Given"] = (gnasir_progress & 8) > 0;
		state.state_boolean["Wormridden"] = (gnasir_progress & 16) > 0;
		
		state.state_int["Desert Exploration"] = get_property_int("desertExploration");
		state.state_boolean["Desert Explored"] = (state.state_int["Desert Exploration"] == 100);
        if (state.finished) //in case mafia doesn't detect it properly
        {
            state.state_int["Desert Exploration"] = 100;
            state.state_boolean["Desert Explored"] = true;
        }
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Pyramid"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Worship");
		state.quest_name = "Hidden City Quest";
		state.image_name = "Hidden City";
        
        state.state_boolean["Hospital finished"] = (get_property_int("hiddenHospitalProgress") >= 8);
        state.state_boolean["Bowling alley finished"] = (get_property_int("hiddenBowlingAlleyProgress") >= 8);
        state.state_boolean["Apartment finished"] = (get_property_int("hiddenApartmentProgress") >= 8);
        state.state_boolean["Office finished"] = (get_property_int("hiddenOfficeProgress") >= 8);
        
        if (state.finished) //backup
        {
            state.state_boolean["Hospital finished"] = true;
            state.state_boolean["Bowling alley finished"] = true;
            state.state_boolean["Apartment finished"] = true;
            state.state_boolean["Office finished"] = true;
        }
        
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Hidden City"] = state;
	}

	
	//hidden temple unlock:
	if (true)
	{
		QuestState state;
		
		if (get_property_int("lastTempleUnlock") == my_ascensions())
			QuestStateParseMafiaQuestPropertyValue(state, "finished");
		else if (__quest_state["Level 2"].startable)
        {
            requestQuestLogLoad();
			QuestStateParseMafiaQuestPropertyValue(state, "started");
        }
		else
			QuestStateParseMafiaQuestPropertyValue(state, "unstarted");
		state.quest_name = "Hidden Temple Unlock";
		state.image_name = "spooky forest";
		
		__quest_state["Hidden Temple Unlock"] = state;
	}
}

void QLevel11BaseGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11"].in_progress)
        return;

    QuestState base_quest_state = __quest_state["Level 11"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";
    boolean make_entry_future = false;
    if (base_quest_state.mafia_internal_step < 2)
    {
        //Unlock black market:
        url = "woods.php";
        if ($item[black market map].available_amount() > 0)
            subentry.entries.listAppend("Unlock the black market.");
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Unlock the black market by adventuring in the Black Forest with -combat.");
            if (__misc_state_string["ballroom song"] != "-combat")
            {
                subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
                make_entry_future = true;
            }
        }
        
        
        familiar bird_needed_familiar;
        item bird_needed;
        if (my_path() == "Bees Hate You")
        {
            bird_needed_familiar = $familiar[reconstituted crow];
            bird_needed = $item[reconstituted crow];
        }
        else
        {
            bird_needed_familiar = $familiar[reassembled blackbird];
            bird_needed = $item[reassembled blackbird];
        }
        if (!have_familiar(bird_needed_familiar) && bird_needed.available_amount() == 0)
        {
            string line = "";
            line = "Acquire " + bird_needed + ".";
            item [int] missing_components = missingComponentsToMakeItem(bird_needed);
        
            if (missing_components.count() == 0)
                line += " You have all the parts, make it.";
            else
                line += " Parts needed: " + missing_components.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
            subentry.modifiers.listAppend("+100% item"); //FIXME what is the drop rate for bees hate you items? we don't know...
        }
        else
        {
            if ($item[black market map].available_amount() > 0)
                subentry.entries.listAppend("Use the black market map");
            
        }
    }
    else if (base_quest_state.mafia_internal_step < 3)
    {
        //Vacation:
        if ($item[forged identification documents].available_amount() == 0)
        {
            url = "store.php?whichstore=l";
            subentry.entries.listAppend("Buy forged identification documents from the black market.");
            if ($item[can of black paint].available_amount() == 0)
                subentry.entries.listAppend("Also buy a can of black paint while you're there, for the desert quest.");
        }
        else
        {
            url = "place.php?whichplace=desertbeach";
            subentry.entries.listAppend("Vacation at the shore, read diary.");
        }
    }
    else if (base_quest_state.mafia_internal_step < 4)
    {
        //Have diary:
        if ($item[holy macguffin].available_amount() == 0)
        {
            //nothing to say
            //subentry.entries.listAppend("Retrieve the MacGuffin.");
            return;
        }
        else
        {
            url = "town.php";
            subentry.entries.listAppend("Speak to the council.");
        }
    }
    if (make_entry_future)
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the black forest]));
    else
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the black forest]));
}

void QLevel11ManorGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Manor"].in_progress)
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Manor"];
    ChecklistSubentry subentry;
    string url = "";
    subentry.header = base_quest_state.quest_name;
    string image_name = base_quest_state.image_name;
    if ($item[lord spookyraven's spectacles].available_amount() == 0)
    {
        subentry.entries.listAppend("Find lord spookyraven's spectacles in the haunted bedroom.");
        url = "place.php?whichplace=town_right";
        if ($location[the haunted bedroom].locationAvailable())
            url = "place.php?whichplace=spookyraven2";
    }
    else if (!locationAvailable($location[the haunted ballroom]))
    {
        subentry.entries.listAppend("Unlock the haunted ballroom.");
        url = "place.php?whichplace=spookyraven2";
    }
    else if (base_quest_state.mafia_internal_step < 2)
    {
        url = "place.php?whichplace=spookyraven2";
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Run -combat in the haunted ballroom.");
        
        if (delayRemainingInLocation($location[the haunted ballroom]) > 0)
        {
            string line = "Delay for ~" + pluralize(delayRemainingInLocation($location[the haunted ballroom]), "turn", "turns");
            if (__misc_state["have hipster"])
            {
                subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                line += ", use " + __misc_state_string["hipster name"];
            }
            line += ". (not tracked properly, sorry)";
            subentry.entries.listAppend(line);
        }
        image_name = "Haunted Ballroom";
    }
    else if (base_quest_state.mafia_internal_step < 3)
    {
        url = "manor3.php";
        subentry.modifiers.listAppend("+400% item");
        subentry.entries.listAppend("Collect wine.");
        image_name = "Wine racks";
    }
    else
    {
        url = "manor3.php";
        subentry.modifiers.listAppend("elemental resistance");
        subentry.entries.listAppend("Fight Lord Spookyraven.");
        image_name = "demon summon";
    }

    task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the haunted ballroom, the haunted wine cellar (northwest), the haunted wine cellar (northeast), the haunted wine cellar (southwest), the haunted wine cellar (southeast), summoning chamber]));
}

void QLevel11PalindomeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Palindome"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Palindome"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url;
    
    if (base_quest_state.mafia_internal_step == 1 && $item[talisman o' nam].available_amount() == 0)
    {
        //1 -> find palindome
        url = "place.php?whichplace=cove";
        subentry.entries.listAppend("Find the palindome. The pirates will know the way.");
        
        string line = "Run -combat to unlock belowdecks.|Then olfact gaudy pirate belowdecks";
        if (!__quest_state["Level 13"].state_boolean["have relevant guitar"])
            line += ", and possibly run +400% item to find a guitar";
        line += ".";
        subentry.entries.listAppend(line);
        if ($item[gaudy key].available_amount() > 0)
            subentry.entries.listAppend("Use " + $item[gaudy key].pluralize() + ".");
            
    }
    else if (base_quest_state.mafia_internal_step == 2 || ($item[talisman o' nam].available_amount() > 0 && base_quest_state.mafia_internal_step == 1))
    {
        subentry.entries.listAppend("Adventure in the palindome.");
        url = "place.php?whichplace=plains";
        //2 -> palindome found, collect items, find dr. awkward
        if ($item[stunt nuts].available_amount() + $item[wet stunt nut stew].available_amount() == 0 || $item[ketchup hound].available_amount() == 0)
        {
            subentry.modifiers.listAppend("+234% item");
            subentry.modifiers.listAppend("+combat");
        }
        if ($item[talisman o' nam].equipped_amount() == 0)
            subentry.entries.listAppend("Equip the Talisman o' Nam.");
            
        if ($item[wet stunt nut stew].available_amount() == 0 && $item[stunt nuts].available_amount() == 0)
            subentry.entries.listAppend("Acquire stunt nuts from Bob Racecar or Racecar Bob. (30% drop)");
        if ($item[ketchup hound].available_amount() == 0)
            subentry.entries.listAppend("Acquire ketchup hound from Bob Racecar or Racecar Bob. (35%/??% drop)");
        if ($item[photograph of god].available_amount() == 0)
            subentry.entries.listAppend("Acquire the photograph of god. (superlikely)");
        if ($item[hard rock candy].available_amount() == 0)
            subentry.entries.listAppend("Acquire hard rock candy. (superlikely)");
        if ($item[hard-boiled ostrich egg].available_amount() == 0)
            subentry.entries.listAppend("Acquire a hard-boiled ostrich egg. (superlikely)");
        
        if ($item[ketchup hound].available_amount() > 0 && $item[photograph of god].available_amount() > 0 && $item[hard rock candy].available_amount() > 0 && $item[hard-boiled ostrich egg].available_amount() > 0)
            subentry.entries.listAppend("Wait for Dr. Awkward to show up.");
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        url = "cobbsknob.php?action=tolabs";
        //3 -> track down mr. alarm
        if (!in_hardcore() && $item[wet stunt nut stew].available_amount() == 0)
            subentry.entries.listAppend("If pulling wet stew, make wet stunt nut stew BEFORE finding Mr. Alarm.");
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Read &quot;I Love Me, Vol. I&quot;.");
        subentry.entries.listAppend("Track down Mr. Alarm. (-combat, cobb's knob laboratory)");
        if (__misc_state["free runs available"])
            subentry.modifiers.listAppend("free runs");
    }
    else if (base_quest_state.mafia_internal_step == 4 && $item[mega gem].available_amount() == 0)
    {
        //4 -> acquire wet stunt nut stew, give to mr. alarm
        if ($item[wet stunt nut stew].available_amount() == 0)
        {
            url = "woods.php";
            if (($item[bird rib].available_amount() > 0 && $item[lion oil].available_amount() > 0 || $item[wet stew].available_amount() > 0) && $item[stunt nuts].available_amount() > 0)
                subentry.entries.listAppend("Cook wet stunt nut stew.");
            else
            {
                subentry.entries.listAppend("Acquire and make wet stunt nut stew.");
                if ($item[wet stunt nut stew].available_amount() == 0 && $item[stunt nuts].available_amount() == 0)
                    subentry.entries.listAppend("Acquire stunt nuts from Bob Racecar or Racecar Bob in Palindome. (30% drop)");
                if ($items[wet stew].available_amount() == 0 && ($items[bird rib].available_amount() == 0 || $items[lion oil].available_amount() == 0))
                {
                    string [int] components;
                    if ($item[bird rib].available_amount() == 0)
                        components.listAppend($item[bird rib]);
                    if ($item[lion oil].available_amount() == 0)
                        components.listAppend($item[lion oil]);
                    string line = "Adventure in Whitey's Grove to acquire " + components.listJoinComponents("", "and") + ".|Need +186% item and +combat.";
                    if (familiar_is_usable($familiar[jumpsuited hound dog]))
                        line += " (hound dog is useful for this)";
                    subentry.entries.listAppend(line);
                    subentry.modifiers.listAppend("+combat");
                    subentry.modifiers.listAppend("+186% item");
                    if (!in_hardcore())
                        subentry.entries.listAppend("Or pull wet stew.");
                }
            }
        }
        else
        {
            url = "cobbsknob.php?action=tolabs";
            subentry.entries.listAppend("Track down Mr. Alarm. (cobb's knob laboratory, first adventure)");
        }
    }
    else if (base_quest_state.mafia_internal_step == 5 || $item[mega gem].available_amount() > 0)
    {
        url = "place.php?whichplace=plains";
        //5 -> fight dr. awkward
        string [int] tasks;
        if ($item[talisman o' nam].equipped_amount() == 0)
            tasks.listAppend("equip the Talisman o' Nam");
        if ($item[mega gem].equipped_amount() == 0)
            tasks.listAppend("equip the Mega Gem");
        
        tasks.listAppend("fight Dr. Awkward");
        subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
    }

    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the poop deck, belowdecks,the palindome,cobb's knob laboratory,whitey's grove]));
}

void QLevel11PyramidGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Pyramid"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Pyramid"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";
    
    if (!base_quest_state.state_boolean["Desert Explored"])
    {
        url = "place.php?whichplace=desertbeach";
        int exploration = base_quest_state.state_int["Desert Exploration"];
        int exploration_remaining = 100 - exploration;
        float exploration_per_turn = 1.0;
        if ($item[uv-resistant compass].available_amount() > 0)
            exploration_per_turn = 2.0;
        if (lookupItem("ornate dowsing rod").available_amount() > 0)
            exploration_per_turn = 3.0; //FIXME make completely accurate for first turn? not enough information available
        int combats_remaining = exploration_remaining;
        combats_remaining = ceil(to_float(exploration_remaining) / exploration_per_turn);
        subentry.entries.listAppend(exploration_remaining + "% exploration remaining. (" + pluralize(combats_remaining, "combat", "combats") + ")");
        if (__last_adventure_location == $location[the arid, extra-dry desert] && $effect[ultrahydrated].have_effect() == 0)
        {
            string [int] description;
            description.listAppend("Adventure in the Oasis.");
            if ($items[ten-leaf clover, disassembled clover].available_amount() > 0)
                description.listAppend("Potentially clover for 20 turns, versus 5.");
            task_entries.listAppend(ChecklistEntryMake("__effect ultrahydrated", "", ChecklistSubentryMake("Acquire Ultrahydrated Effect", "", description), -11));
        }
        if (exploration < 10)
        {
            int turns_until_gnasir_found = ceil(to_float(10 - exploration) / exploration_per_turn) + 1;
            
            subentry.entries.listAppend("Find Gnasir in " + pluralize(turns_until_gnasir_found, "turn", "turns") + ".");
        }
        else if (exploration == 10 && $location[the arid, extra-dry desert].noncombatTurnsAttemptedInLocation() == 0)
        {
            subentry.entries.listAppend("Find Gnasir next turn.");
            
        }
        else
        {
            boolean need_pages = false;
            if (!base_quest_state.state_boolean["Black Paint Given"])
            {
                if ($item[can of black paint].available_amount() == 0)
                    subentry.entries.listAppend("Buy can of black paint, give it to Gnasir.");
                else
                    subentry.entries.listAppend("Give can of black paint to Gnasir.");
                    
            }
            if (!base_quest_state.state_boolean["Stone Rose Given"])
            {
                if ($item[stone rose].available_amount() > 0)
                    subentry.entries.listAppend("Give stone rose to Gnasir.");
                else
                {
                    string line = "Potentially adventure in Oasis for stone rose.";
                    if (delayRemainingInLocation($location[the oasis]) > 0)
                    {
                        string hipster_text = "";
                        if (__misc_state["have hipster"])
                        {
                            hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
                        }
                        line += "|Delay for " + pluralize(delayRemainingInLocation($location[the oasis]), "turn", "turns") + hipster_text + ".";
                    }
                    subentry.entries.listAppend(line);
                }
            }
            if (!base_quest_state.state_boolean["Manual Pages Given"])
            {
                if ($item[worm-riding manual page].available_amount() == 15)
                    subentry.entries.listAppend("Give Gnasir the worm-riding manual pages.");
                else
                {
                    int remaining = 15 - $item[worm-riding manual page].available_amount();
                    
                    subentry.entries.listAppend("Find " + pluralize(remaining, $item[worm-riding manual page]) + ".");
                    need_pages = true;
                }
                
            }
            else if (!base_quest_state.state_boolean["Wormridden"])
            {
                subentry.modifiers.listAppend("rhythm");
                if ($item[drum machine].available_amount() > 0)
                {
                    subentry.entries.listAppend("Use drum machine.");
                }
            }
            if (!base_quest_state.state_boolean["Wormridden"] && $item[drum machine].available_amount() == 0)
            {				
                subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), use drum machine.");
                subentry.modifiers.listAppend("+234% item");
            }
            if (!base_quest_state.state_boolean["Killing Jar Given"])
            {
                if ($item[killing jar].available_amount() > 0)
                    subentry.entries.listAppend("Give Gnasir the killing jar.");
                else
                    subentry.entries.listAppend("Potentially find killing jar. (banshee, haunted library, 10% drop, YR?)");
            }
            
            if (__misc_state["have hipster"])
            {
                subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                
                string line = __misc_state_string["hipster name"].capitalizeFirstLetter() + " for free combats";
                if (need_pages)
                    line += " and manual pages";
                line += ".";
                subentry.entries.listAppend(line);
            }
        }
        if ($effect[ultrahydrated].have_effect() == 0)
        {
            if (exploration > 0)
                subentry.entries.listAppend("Acquire ultrahydrated effect from oasis. (potential clover for 20 adventures)");
        }
        if ($item[desert sightseeing pamphlet].available_amount() > 0)
        {
            if ($item[desert sightseeing pamphlet].available_amount() == 1)
                subentry.entries.listAppend("Use your desert sightseeing pamphlet. (+15% exploration)");
            else
                subentry.entries.listAppend("Use your desert sightseeing pamphlets. (+15% exploration)");
        }
        
        if (__misc_state["can equip just about any weapon"])
        {
            if (lookupItem("ornate dowsing rod").available_amount() > 0)
            {
                if (lookupItem("ornate dowsing rod").equipped_amount() == 0)
                {
                    subentry.entries.listAppend("Equip the ornate dowsing rod.");
                }
            }
            else
            {
                if ($item[uv-resistant compass].available_amount() == 0)
                {
                    string line = "Acquire UV-resistant compass, equip for faster desert exploration. (shore vacation)";
                  
                    if (lookupItem("odd silver coin").available_amount() > 0)
                    {
                        line += "|Or acquire ornate dowsing rod from Paul's Boutique? (5 odd silver coins)";
                    }
                    subentry.entries.listAppend(line);
                  
                }
                else if ($item[uv-resistant compass].available_amount() > 0 && $item[uv-resistant compass].equipped_amount() == 0)
                {
                    subentry.entries.listAppend("Equip the UV-resistant compass.");
                }
            }
        }
        
    }
    else
    {
        //Desert explored.
        if ($item[staff of ed].available_amount() + $item[staff of ed].creatable_amount() == 0)
        {
            //Staff of ed.
            subentry.entries.listAppend("Find the Staff of Ed.");
        }
        else if (base_quest_state.mafia_internal_step == 12)
        {
            url = "place.php?whichplace=desertbeach";
            subentry.entries.listAppend("Visit the pyramid, click on it.");
        }
        else
        {
            url = "pyramid.php";
            //Pyramid unlocked:
            int pyramid_position = get_property_int("pyramidPosition");
            
            //I think there are... five positions?
            //1=Ed, 2=bad, 3=vending machine, 4=token, 5=bad
            int next_position_needed = -1;
            int additional_turns_after_that = 0;
            string task;
            boolean ed_waiting = get_property_boolean("pyramidBombUsed");
            if (2318.to_item().available_amount() > 0 || ed_waiting)
            {
                //need 1
                next_position_needed = 1;
                additional_turns_after_that = 0;
                
                int ed_ml = 180 + monster_level_adjustment();
                task = "fight Ed in the lower chambers";
                if (ed_ml > my_buffedstat($stat[moxie]))
                    task += " (" + ed_ml + " attack)";
            }
            else if ($item[ancient bronze token].available_amount() > 0)
            {
                //need 3
                next_position_needed = 3;
                additional_turns_after_that = 3;
                task = "acquire " + 2318.to_item().to_string() + " in lower chamber";
            }
            else
            {
                //need 4
                next_position_needed = 4;
                additional_turns_after_that = 3 + 4;
                task = "acquire token in lower chamber";
            }
            
            int spins_needed = (next_position_needed - pyramid_position + 10) % 5;
            
            string [int] tasks;
            if (spins_needed > 0)
            {
                if (spins_needed == 1)
                    tasks.listAppend("spin the pyramid One More Time");
                else
                    tasks.listAppend("spin the pyramid " + spins_needed.int_to_wordy() + " times");
            }
            tasks.listAppend(task);
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
            
            if ($item[tomb ratchet].available_amount() > 0)
                subentry.entries.listAppend(pluralize($item[tomb ratchet]) + " available.");
            //FIXME track wheel being placed
            //FIXME tell them which route is better from where they are
        }
    }
    
    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the arid\, extra-dry desert,the oasis,the upper chamber,the lower chambers, the middle chamber]));
}

boolean [item] __dense_liana_machete_items = $items[antique machete,Machetito,Muculent machete,Papier-m&acirc;ch&eacute;te];

void generateHiddenAreaUnlockForShrine(string [int] description, location shrine)
{
    boolean have_machete_equipped = false;
    item machete_available = $item[none];
    foreach it in __dense_liana_machete_items
    {
        if (it.available_amount() > 0)
            machete_available = it;
        if (it.equipped_amount() > 0)
            have_machete_equipped = true;
    }
    int liana_remaining = MAX(0, 3 - shrine.combatTurnsAttemptedInLocation());
    if (shrine != $location[a massive ziggurat])
        description.listAppend("Unlock by visiting " + shrine + ".");
    if (liana_remaining > 0 && shrine.noncombatTurnsAttemptedInLocation() == 0)
    {
        string line = liana_remaining.int_to_wordy().capitalizeFirstLetter() + " dense liana remain.";
        
        if (__misc_state["can equip just about any weapon"])
        {
            if (machete_available == $item[none])
                line += " Acquire a machete first.";
            else if (!have_machete_equipped)
                line += " Equip " + machete_available + " first.";
        }
        description.listAppend(line);
    }
}

void QLevel11HiddenCityGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Hidden City"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Hidden City"];
    ChecklistEntry entry;
    entry.target_location = "place.php?whichplace=hiddencity";
    entry.image_lookup_name = base_quest_state.image_name;
    entry.should_indent_after_first_subentry = true;
    entry.should_highlight = $locations[the hidden temple, the hidden apartment building, the hidden hospital, the hidden office building, the hidden bowling alley, the hidden park, a massive ziggurat,an overgrown shrine (northwest),an overgrown shrine (southwest),an overgrown shrine (northeast),an overgrown shrine (southeast)] contains __last_adventure_location;
    
    if (!__quest_state["Hidden Temple Unlock"].finished)
    {
        return;
    }
    else if (!locationAvailable($location[the hidden park]))
    {
        entry.image_lookup_name = "Hidden Temple";
        ChecklistSubentry subentry;
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Unlock the hidden city via the hidden temple.");
        if ($item[the Nostril of the Serpent].available_amount() == 0)
            subentry.entries.listAppend("Need nostril of the serpent.");
        if ($item[stone wool].available_amount() > 0)
            subentry.entries.listAppend(pluralize($item[stone wool]) + " available.");
        entry.subentries.listAppend(subentry);
        entry.target_location = "woods.php";
    }
    else
    {		
        if (true)
        {
            ChecklistSubentry subentry;
            subentry.header = base_quest_state.quest_name;
            entry.subentries.listAppend(subentry);
        }
        //Not sure exactly how these work.
        //8 appears to be finished.
        //1 appears to be "area unlocked"
        boolean hidden_tavern_unlocked = (get_property_int("hiddenTavernUnlock") == my_ascensions());
        boolean janitors_relocated_to_park = (get_property_int("relocatePygmyJanitor") == my_ascensions());
        boolean have_machete = false;
    
        have_machete = __dense_liana_machete_items.available_amount() > 0;
    
        int bowling_progress = get_property_int("hiddenBowlingAlleyProgress");
        if (bowling_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Bowling Alley";
        
            if (bowling_progress == 7 || $item[scorched stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place scorched stone sphere in shrine.");
            }
            else if (bowling_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (southeast)]);
            }
            else
            {
                int rolls_needed = 6 - bowling_progress;
                
                if (!(rolls_needed == 1 && $item[bowling ball].available_amount() > 0))
                {
                    subentry.modifiers.listAppend("+150% item");
                    subentry.entries.listAppend("Olfact bowler, run +150% item.");
                    if (!$monster[pygmy orderlies].is_banished())
                        subentry.entries.listAppend("Potentially banish pgymy orderlies.");
                }
                
                string line;
                line = int_to_wordy(rolls_needed).capitalizeFirstLetter();
                if (rolls_needed > 1)
                    line += " more rolls";
                else
                    line = "One More Roll";
                line += " until protector spirit fight.";
                
                subentry.entries.listAppend(line);
                
                //FIXME pop up a reminder to acquire bowl of scorpions
                if (__misc_state["free runs usable"])
                {
                    if (hidden_tavern_unlocked)
                    {
                        if ($item[bowl of scorpions].available_amount() == 0)
                            subentry.entries.listAppend(HTMLGenerateSpanOfClass("Buy a bowl of scorpions", "r_bold") + " from the Hidden Tavern to free run from drunk pygmys.");
                    }
                    else
                    {
                        subentry.entries.listAppend("Possibly unlock the hidden tavern first, for free runs from drum pygmys.");
                    }
                }
            }
        
        
        
            entry.subentries.listAppend(subentry);
        }
        int hospital_progress = get_property_int("hiddenHospitalProgress");
        if (hospital_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Hospital";
            if (hospital_progress == 7 || $item[dripping stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place dripping stone sphere in shrine.");
            }
            else if (hospital_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Southwest)]);
            }
            else
            {
                subentry.entries.listAppend("Olfact surgeon.");
                if (!$monster[pygmy orderlies].is_banished())
                    subentry.entries.listAppend("Potentially banish pgymy orderlies.");
        
        
                item [int] items_we_have_unequipped;
                foreach it in $items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel]
                {
                    boolean can_equip = true;
                    if (it.to_slot() == $slot[shirt] && !have_skill($skill[Torso Awaregness]))
                        can_equip = false;
                    if (it.available_amount() > 0 && equipped_amount(it) == 0 && can_equip)
                        items_we_have_unequipped.listAppend(it);
                }
                if (items_we_have_unequipped.count() > 0)
                {
                    subentry.entries.listAppend("Equipment unequipped: (+10% chance of protector spirit per piece)|*" + items_we_have_unequipped.listJoinComponents("|*"));
                }
            }
            
            
            entry.subentries.listAppend(subentry);
        }
        int apartment_progress = get_property_int("hiddenApartmentProgress");
        if (apartment_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Apartment";
            if (apartment_progress == 7 || $item[moss-covered stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place moss-covered stone sphere in shrine.");
            }
            else if (apartment_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northwest)]);
            }
            else
            {
                subentry.entries.listAppend("Olfact shaman.");
                //if (!$monster[pygmy witch lawyer].is_banished())
                    //subentry.entries.listAppend("Potentially banish lawyers.");
                subentry.entries.listAppend("NC appears every 9th adventure.");
                
                string [int] curse_sources;
                if (__misc_state["can drink just about anything"])
                {
                    if (hidden_tavern_unlocked)
                        curse_sources.listAppend("cursed punch from the tavern");
                    else
                        curse_sources.listAppend("cursed punch from the tavern, if you unlock it");
                }
                curse_sources.listAppend("fighting a pygmy shaman");
                curse_sources.listAppend("non-combat (try to avoid)");
                string curse_details = "";
                curse_details = " Acquired from " + curse_sources.listJoinComponents(", ", "or") + ".";
                
                if ($effect[thrice-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("You're thrice-cursed. Fight the protector spirit!");
                }
                else if ($effect[twice-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("Need one more curse." + curse_details);
                }
                else if ($effect[once-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("Need two more curses." + curse_details);
                }
                else
                {
                    subentry.entries.listAppend("Need three more curses." + curse_details);
                }
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
        int office_progress = get_property_int("hiddenOfficeProgress");
        if (office_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Office";
            if (office_progress == 7 || $item[crackling stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place crackling stone sphere in shrine.");
            }
            else if (office_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northeast)]);
            }
            else
            {
                subentry.entries.listAppend("NC appears first on the 6th adventure, then every 5 adventures.");
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
                if ($item[McClusky file (complete)].available_amount() == 0)
                {
                    if ($item[Boring binder clip].available_amount() == 0)
                        subentry.entries.listAppend("Need boring binder clip. (raid the supply cabinet, office NC)");
                    int files_found = $item[McClusky file (page 1)].available_amount() + $item[McClusky file (page 2)].available_amount() + $item[McClusky file (page 3)].available_amount() + $item[McClusky file (page 4)].available_amount() + $item[McClusky file (page 5)].available_amount();
                    int files_not_found = 5 - files_found;
                    if (files_not_found > 0)
                    {
                        subentry.entries.listAppend("Need " + pluralize(files_not_found, "McClusky file", "McClusky files") + ". Found from pygmy witch accountants.");
                        subentry.entries.listAppend("Olfact accountant");
                        //if (!$monster[pygmy witch lawyer].is_banished())
                            //subentry.entries.listAppend("Potentially banish lawyers.");
                    }
                }
                else
                {
                    subentry.entries.listAppend("You have the complete McClusky files, fight boss.");
                }
            }
            entry.subentries.listAppend(subentry);
        }
        if (bowling_progress == 8 && hospital_progress == 8 && apartment_progress == 8 && office_progress == 8 || $item[stone triangle].available_amount() == 4)
        {
            ChecklistSubentry subentry;
            subentry.header = "Massive Ziggurat";
            //Instead of checking for four stone triangles, we check for the lack of all four stone spheres. That way it should detect properly after you fight the boss (presumably losing stone triangles), and lost?
        
            int spheres_available = $item[moss-covered stone sphere].available_amount() + $item[dripping stone sphere].available_amount() + $item[crackling stone sphere].available_amount() + $item[scorched stone sphere].available_amount();
        
            if (spheres_available > 0)
            {
                subentry.entries.listAppend("Acquire stone triangles");
            }
            else
            {
                if ($location[a massive ziggurat].combatTurnsAttemptedInLocation() <3 && $location[a massive ziggurat].noncombatTurnsAttemptedInLocation() == 0)
                {
                    generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                }
                else
                {
                    subentry.modifiers.listAppend("elemental damage");
                    subentry.entries.listAppend("Fight the protector spirit!");
                }
            }
        
            entry.subentries.listAppend(subentry);
        }
        else
        {
            if ($location[a massive ziggurat].combatTurnsAttemptedInLocation() <3)
            {
                ChecklistSubentry subentry;
                subentry.header = "Massive Ziggurat";
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                entry.subentries.listAppend(subentry);
            }
            if (!hidden_tavern_unlocked)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Tavern";
                boolean should_output = true;
            
                if ($item[book of matches].available_amount() > 0)
                    subentry.entries.listAppend("Use book of matches");
                else
                {
                    if (janitors_relocated_to_park)
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, Hidden Park, 10% drop)");
                    else
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, everywhere in the hidden city, 10% drop)");
                    
                    string [int] tavern_provides;
                    if (bowling_progress < 8)
                        tavern_provides.listAppend("Free runs from drunk pygmys.");
                    if (__misc_state["can drink just about anything"])
                    {
                        if (apartment_progress < 8)
                            tavern_provides.listAppend("Curses for hidden apartment.");
                        int adventures_given = 15;
                        if (have_skill($skill[the ode to booze]))
                            adventures_given += 6;
                        
                        tavern_provides.listAppend("Nightcap drink. (Fog Murderer for " + adventures_given + " adventures)");
                    }
                    if (tavern_provides.count() > 0)
                        subentry.entries.listAppend("Hidden Tavern provides:|*" + tavern_provides.listJoinComponents("|*"));
                    else
                        should_output = false; //don't bother, no reason to... I think?
                
                }
                if (should_output)
                    entry.subentries.listAppend(subentry);
            }
            if (!janitors_relocated_to_park || !have_machete)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Park";
            
                subentry.modifiers.listAppend("-combat");
                if (!have_machete)
                {
                    int turns_remaining = MAX(0, 6 - $location[the hidden park].turnsAttemptedInLocation());
                    string line;
                    line += "Adventure for " + turns_remaining.int_to_wordy() + " turns here for antique machete to clear dense lianas.";
                    if (canadia_available())
                        line += "|Or potentially use muculent machete by acquiring forest tears. (kodama, Outskirts of Camp Logging Camp, 30% drop or clover)";
                    subentry.entries.listAppend(line);
                }
                if (!janitors_relocated_to_park)
                    subentry.entries.listAppend("Potentially relocate janitors to park via non-combat.");
                else
                    subentry.entries.listAppend("Acquire useful items from dumpster with -combat.");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            
                entry.subentries.listAppend(subentry);
            }
        }
    
    
        if (false) //debug internals
        {
            ChecklistSubentry subentry;
            subentry.header = "Debug";
            string [int] show_properties = split_string_mutable("hiddenApartmentProgress,hiddenBowlingAlleyProgress,hiddenHospitalProgress,hiddenOfficeProgress", ","); //8,8,8,8 when finished
            foreach key in show_properties
                subentry.entries.listAppend(show_properties[key] + " = " + get_property(show_properties[key]).HTMLEscapeString());
        
            if (get_property_int("hiddenTavernUnlock") == my_ascensions())
                subentry.entries.listAppend("hidden tavern unlocked");
            else
                subentry.entries.listAppend("hidden tavern not yet");
        
            if (get_property_int("relocatePygmyJanitor") == my_ascensions())
                subentry.entries.listAppend("Janitors relocated to park");
            else
                subentry.entries.listAppend("JANITORS EVERYWHERE");
        
        
            if (get_property_int("relocatePygmyLawyer") == my_ascensions())
                subentry.entries.listAppend("Lawyers relocated");
            else
                subentry.entries.listAppend("Lawyers still around");
        
            string [int] saving_lines;
            saving_lines.listAppendList(subentry.entries);
            subentry.entries.listClear();
            subentry.entries.listAppend(saving_lines.listJoinComponents("|"));

            entry.subentries.listAppend(subentry);
        }
    }
    if (entry.subentries.count() > 0)
        task_entries.listAppend(entry);
}

void QLevel11HiddenTempleGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Hidden Temple Unlock"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Hidden Temple Unlock"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    
    if (delayRemainingInLocation($location[the spooky forest]) > 0)
    {
		string hipster_text = "";
		if (__misc_state["have hipster"])
		{
			hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
		}
        string line = "Delay for " + pluralize(delayRemainingInLocation($location[the spooky forest]), "turn", "turns") + hipster_text + ".";
        subentry.entries.listAppend(line);
        subentry.entries.listAppend("Run -combat after that.");
    }
    else
    {
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Run -combat in the spooky forest.");
    }
    if (__misc_state["free runs available"])
    {
        subentry.modifiers.listAppend("free runs");
        subentry.entries.listAppend("Free run from low-stat monsters.");
    }
    
    int ncs_remaining = 0;
        
    if ($item[spooky sapling].available_amount() == 0)
    {
        if (my_meat() < 100)
            subentry.entries.listAppend("Obtain 100 meat for spooky sapling.");
        else
            subentry.entries.listAppend("Acquire spooky sapling.|*Follow the old road" + __html_right_arrow_character + "Talk to the hunter" + __html_right_arrow_character + "Buy a tree");
        ncs_remaining += 1;
    }
        
    if ($item[tree-holed coin].available_amount() == 0)
    {
        if ($item[spooky temple map].available_amount() == 0)
        {
            //no coin, no map
            subentry.entries.listAppend("Acquire tree-holed coin, then map.|*Explore the stream" + __html_right_arrow_character + "Squeeze into the cave");
            ncs_remaining += 2;
        }
        else
        {
            //no coin, have map, nothing to do here
        }
    }
    else
    {
        if ($item[spooky temple map].available_amount() == 0)
        {
            //coin, no map
            subentry.entries.listAppend("Acquire spooky temple map.|*Brave the dark thicket" + __html_right_arrow_character + "Follow the coin" + __html_right_arrow_character + "Insert coin to continue");
            
            ncs_remaining += 1;
        }
        else
        {
            //wait, what?
            subentry.entries.listAppend("how did we get here?");
        }
    }
    if ($item[spooky-gro fertilizer].available_amount() == 0)
    {
        subentry.entries.listAppend("Acquire spooky-gro fertilizer.|*Brave the dark thicket" + __html_right_arrow_character + "Investigate the dense foliage");
        ncs_remaining += 1;
    }
    if ($item[spooky temple map].available_amount() > 0 && $item[spooky-gro fertilizer].available_amount() > 0 && $item[spooky sapling].available_amount() > 0)
    {
        subentry.modifiers.listClear();
        subentry.entries.listClear();
        subentry.entries.listAppend("Use the spooky temple map");
    }
    
    if (ncs_remaining > 0)
    {
        float spooky_forest_nc_rate = clampNormalf(1.0 - (85.0 + combat_rate_modifier()) / 100.0);
        
        float turns_remaining = -1.0;
        float turns_per_nc = 7.0;
        if (spooky_forest_nc_rate > 0.0)
            turns_per_nc = MIN(7.0, 1.0 / spooky_forest_nc_rate);
            
        turns_remaining = ncs_remaining.to_float() * turns_per_nc;
        turns_remaining += delayRemainingInLocation($location[the spooky forest]);
        
        subentry.entries.listAppend("~" + turns_remaining.roundForOutput(1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
    }
    
    if (__misc_state_string["ballroom song"] != "-combat")
    {
        subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "", subentry, $locations[the spooky forest]));
    }
    else
    {
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "woods.php", subentry, , $locations[the spooky forest]));
    }
}


void QLevel11GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__misc_state["In run"])
        return;
    //Such a complicated quest.
    QLevel11BaseGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11ManorGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11PalindomeGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11PyramidGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11HiddenCityGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11HiddenTempleGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}