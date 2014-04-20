void QLevel11Init()
{
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
        
        state.state_boolean["Need instant camera"] = false;
        if (lookupItem("photograph of a dog").available_amount() + lookupItem("disposable instant camera").available_amount() == 0 && state.mafia_internal_step < 3 && mafiaIsPastRevision(13870))
            state.state_boolean["Need instant camera"] = true;
        
        
        state.state_boolean["dr. awkward's office unlocked"] = false;
        if (state.mafia_internal_step > 2)
            state.state_boolean["dr. awkward's office unlocked"] = true;
        //FIXME tracking this
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
        
        
        boolean have_uv_compass_equipped = false;
        
        if (!__misc_state["can equip just about any weapon"])
            have_uv_compass_equipped = true;
        if ($item[UV-resistant compass].equipped_amount() > 0)
            have_uv_compass_equipped = true;
        if (lookupItem("ornate dowsing rod").equipped_amount() > 0)
            have_uv_compass_equipped = true;
        
        state.state_boolean["Have UV-Compass eqipped"] = have_uv_compass_equipped;
	
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
        url = "place.php?whichplace=woods";
        if ($item[black market map].available_amount() > 0)
            subentry.entries.listAppend("Unlock the black market.");
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Unlock the black market by adventuring in the Black Forest with -combat.");
            if (!__quest_state["Manor Unlock"].state_boolean["ballroom song effectively set"])
            {
                subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
                make_entry_future = true;
            }
        }
        
        
        familiar bird_needed_familiar;
        item bird_needed;
        if (my_path_id() == PATH_BEES_HATE_YOU)
        {
            bird_needed_familiar = $familiar[reconstituted crow];
            bird_needed = $item[reconstituted crow];
        }
        else
        {
            bird_needed_familiar = $familiar[reassembled blackbird];
            bird_needed = $item[reassembled blackbird];
        }
        if (!have_familiar_replacement(bird_needed_familiar) && bird_needed.available_amount() == 0)
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
            {
                url = "inventory.php?which=3";
                subentry.entries.listAppend("Use the black market map.");
            }
            
        }
    }
    else if (base_quest_state.mafia_internal_step < 3)
    {
        //Vacation:
        if ($item[forged identification documents].available_amount() == 0)
        {
            url = "shop.php?whichshop=blackmarket";
            subentry.entries.listAppend("Buy forged identification documents from the black market.");
            if ($item[can of black paint].available_amount() == 0)
                subentry.entries.listAppend("Also buy a can of black paint while you're there, for the desert quest.");
        }
        else
        {
            if (CounterLookup("Semi-rare").CounterWillHitExactlyInTurnRange(0,2))
            {
                subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid vacationing; will override semi-rare.", "red", ""));
            }
            else
            {
                url = "place.php?whichplace=desertbeach";
                subentry.entries.listAppend("Vacation at the shore, read diary.");
            }
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
        if ($items[spooky putty sheet,Rain-Doh black box].available_amount() > 0)
            subentry.entries.listAppend("Possibly copy the monsters here. The copy will have all six wines.");
        image_name = "Wine racks";
    }
    else
    {
        url = "manor3.php";
        subentry.modifiers.listAppend("elemental resistance");
        subentry.entries.listAppend("Fight Lord Spookyraven.");
        
        if ($effect[Red Door Syndrome].have_effect() == 0 && my_meat() > 1000)
        {
            subentry.entries.listAppend("A can of black paint can help with fighting him. Bit pricy. (1k meat)");
        }
        
        image_name = "demon summon";
    }

    task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the haunted ballroom, the haunted wine cellar (northwest), the haunted wine cellar (northeast), the haunted wine cellar (southwest), the haunted wine cellar (southeast), summoning chamber]));
}

void QLevel11PalindomeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Palindome"].in_progress)
        return;
    if (__quest_state["Level 11"].finished)
        return;
    if ($items[staff of fats,Staff of Ed\, almost,Staff of Ed].available_amount() > 0)
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
        
        if (!is_wearing_outfit("Swashbuckling Getup") && $item[pirate fledges].equipped_amount() == 0)
            url = "inventory.php?which=2";
            
        if ($location[the poop deck].noncombat_queue.contains_text("It's Always Swordfish") || $location[belowdecks].turnsAttemptedInLocation() > 0)
        {
            subentry.modifiers.listAppend("olfact gaudy pirate");
            string line = "Olfact/copy gaudy pirate belowdecks";
            if (!__quest_state["Level 13"].state_boolean["have relevant guitar"])
            {
                line += ", and possibly run +400% item to find a guitar";
                subentry.modifiers.listAppend("+400% item");
            }
            line += ".";
            subentry.entries.listAppend(line);
            if ($item[gaudy key].available_amount() > 0)
                subentry.entries.listAppend("Use " + $item[gaudy key].pluralize() + ".");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat on the Poop Deck to unlock belowdecks.");
            subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 1, "unlock belowdecks"));
        }
            
    }
    else
    {
        url = "place.php?whichplace=palindome";
        if ($item[talisman o' nam].equipped_amount() == 0)
            url = "inventory.php?which=2";
        
        
        /*
        Quest steps:
        Adventure in palindome, acquire:
            photograph of a dog (7263) by taking a picture of one of the racecar twins(?) with a disposable instant camera
            photograph of an ostrich egg (7265)
            photograph of a red nugget (7264)
            photograph of god
            stunt nuts for wet stunt nut stew
            "I Love Me, Vol. I" (7262) (dropped from monster, possibly drab bard?, possibly after rest are available?)
         Use I love me, volume 1. This removes it from your inventory, and unlocks the office.
         Arrange the photographs on the shelf:
            god, red nugget, dog, ostrich egg
        This gives 2 Love Me, Vol. 2 (7270)
        Read it to unlock mr. alarm in left office. It will disappear.
        He'll tell you to go acquire wet stunt nut stew. Adventure in whitey's grove as per usual.
        Cook wet stunt nut stew.
        Go talk to mr. alarm. He'll give a mega gem.
        Go fight Dr. Awkward with both equipped.
        
        */
        
        if (!mafiaIsPastRevision(13870)) //not actually sure when palindome support went in, so just using a recent one
        {
            subentry.entries.listAppend("Update mafia to support revamp. Simple guide:");
            subentry.entries.listAppend("First you adventure in the Palindome.|Find three photographs via non-combats(?), and take a picture of Bob Racecar/Racecar Bob with a disposable instant camera. (found in NC in haunted bedroom)|Olfact bob racecar/racecar bob.|Also, possibly find stunt nuts. (30% drop, +234% item)");
            subentry.entries.listAppend("&quot;I Love Me, Vol.&quot; I will drop from the fifth dude-type monster. Read it to unlock Dr. Awkward's office.");
            subentry.entries.listAppend("Place all four photographs on the shelves in the office.|Order is god, red nugget, dog, and ostrich egg.");
            subentry.entries.listAppend("Read 2 Love Me, Vol. 2 to unlock Mr. Alarm's office.");
            subentry.entries.listAppend("Talk to Mr. Alarm, unlock Whitey's Grove. Run +186% item, +combat to find lion oil and bird rib.|Or, alternatively, adventure in the palindome. I don't know the details, sorry.");
            subentry.entries.listAppend("Cook wet stunt nut stew, talk to Mr. Alarm. He'll give you the Mega Gem.");
            subentry.entries.listAppend("Equip that to fight Dr. Awkward in his office.");
        }
        else if ($item[mega gem].available_amount() > 0 || base_quest_state.mafia_internal_step == 5)
        {
            //5 -> fight dr. awkward
            string [int] tasks;
            if ($item[talisman o' nam].equipped_amount() == 0)
                tasks.listAppend("equip the Talisman o' Nam");
            if ($item[mega gem].equipped_amount() == 0)
                tasks.listAppend("equip the Mega Gem");
            
            tasks.listAppend("fight Dr. Awkward in his office");
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        else if (base_quest_state.mafia_internal_step == 4 || base_quest_state.mafia_internal_step == 3)
        {
            //4 -> acquire wet stunt nut stew, give to mr. alarm
            //FIXME handle alternate route
            //step3 not supported yet, so we have this instead:
            if (base_quest_state.mafia_internal_step == 3)
                subentry.entries.listAppend("Use 2 Love Me, Vol. 2, then talk to Mr. Alarm in his office. Then:");
            
            if ($item[wet stunt nut stew].available_amount() == 0)
            {
                if (($item[bird rib].available_amount() > 0 && $item[lion oil].available_amount() > 0 || $item[wet stew].available_amount() > 0) && $item[stunt nuts].available_amount() > 0)
                {
                    url = "craft.php?mode=cook";
                    subentry.entries.listAppend("Cook wet stunt nut stew.");
                }
                else
                {
                    url = "place.php?whichplace=woods";
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
                    subentry.entries.listAppend("Or try the alternate route in the Palindome. (don't know how this works)");
                }
            }
            else
            {
                subentry.entries.listAppend("Talk to Mr. Alarm.");
                if ($item[talisman o' nam].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip the Talisman o' Nam.");
            }
        }
        else if (base_quest_state.mafia_internal_step == 3)
        {
            string [int] tasks;
            //talk to mr. alarm to unlock whitey's grove
            if (7270.to_item().available_amount() > 0)
            {
                //url = "inventory.php?which=3";
                tasks.listAppend("use 2 Love Me, Vol. 2");
            }
            if ($item[wet stunt nut stew].available_amount() > 0)
                tasks.listAppend("talk to Mr. Alarm");
            else
                tasks.listAppend("talk to Mr. Alarm to unlock Whitey's Grove");
                
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".");
            if ($item[talisman o' nam].equipped_amount() == 0)
                subentry.entries.listAppend("Equip the Talisman o' Nam.");
        }
        else
        {
            boolean dr_awkwards_office_unlocked = base_quest_state.state_boolean["dr. awkward's office unlocked"]; //no way to track this at the moment
            string single_entry_mode = "";
            boolean need_to_adventure_in_palindome = false;
            boolean need_palindome_location = true;
            
            //Need:
            //√Wet stunt nut stew / stunt nuts
            //√"I Love Me, Vol. I" (7262)
            //√instant camera -> 7263 photograph of a dog
            //√7264 photograph of a red nugget
            //√7265 photograph of an ostrich egg
            //√photograph of god
            subentry.entries.listAppend("Adventure in the palindome.");
            
            if (lookupItem("photograph of a dog").available_amount() == 0)
            {
                if (lookupItem("disposable instant camera").available_amount() == 0)
                {
                    subentry.modifiers.listClear();
                    subentry.modifiers.listAppend("-combat");
                    url = "place.php?whichplace=spookyraven2";
                    single_entry_mode = "Adventure in the haunted ballroom for a disposable instant camera.";
                    need_palindome_location = false;
                }
                else
                {
                    subentry.entries.listAppend("Photograph Bob Racecar or Racecar Bob with disposable instant camera.");
                    need_to_adventure_in_palindome = true;
                }
            }
            
            if ($item[stunt nuts].available_amount() + $item[wet stunt nut stew].available_amount() == 0 )
            {
                subentry.modifiers.listAppend("+234% item");
                subentry.entries.listAppend("Possibly acquire stunt nuts from Bob Racecar or Racecar Bob. (30% drop)");
                need_to_adventure_in_palindome = true;
            }
            
            
            string [int] missing_ncs;
            if (lookupItem("photograph of a red nugget").available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of a red nugget");
            }
            if (lookupItem("photograph of an ostrich egg").available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of an ostrich egg");
            }
            if ($item[photograph of god].available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of god");
            }
            if (missing_ncs.count() > 0)
            {
                subentry.entries.listAppend("Find " + missing_ncs.listJoinComponents(", ", "and") + " from non-combats.|(unknown if affected by -combat)");
                need_to_adventure_in_palindome = true;
            }
            
            
            
            
            //This must be after all other need_to_adventure_in_palindome checks:
            if (7262.to_item().available_amount() == 0 && !dr_awkwards_office_unlocked) //I love me, Vol. I
            {
                if (__misc_state["have olfaction equivalent"] && __misc_state_string["olfaction equivalent monster"] != "Racecar Bob" && __misc_state_string["olfaction equivalent monster"] != "Bob Racecar" && __misc_state_string["olfaction equivalent monster"] != "Drab Bard")
                {
                    subentry.modifiers.listAppend("olfact racecar");
                    subentry.entries.listAppend("Olfact Bob Racecar or Racecar Bob.");
                }
                string line = "Find I Love Me, Vol. I in-combat. Fifth dude-type monster.";
                if (!need_to_adventure_in_palindome) //counts stunt nuts and photographs
                    line += "|Well, unless you have already. If so, place the photographs in Dr. Awkward's Office.";
                else
                    line += "|Well, unless you have already.";
                subentry.entries.listAppend(line);
                need_to_adventure_in_palindome = true;
            }
            else if (7262.to_item().available_amount() > 0)
            {
                if (!need_to_adventure_in_palindome)
                {
                    url = "inventory.php?which=3";
                    subentry.entries.listAppend("Use I Love Me, Vol. I. Then place the photographs in Dr. Awkward's Office.");
                }
                else
                {
                    subentry.entries.listAppend("Have I Love Me, Vol. I. Collect photographs and such in the Palindome first..");
                }
            }
            
            if (!need_to_adventure_in_palindome)
            {
                if (subentry.entries contains 0)
                    remove subentry.entries[0]; //remove "Adventure in the palindome" by index - this is hacky
            }
            
            if (!need_to_adventure_in_palindome && dr_awkwards_office_unlocked)
            {
                subentry.modifiers.listClear();
                single_entry_mode = "Place items on shelves in Dr. Awkward's office.|Order is god, red nugget, dog, and ostrich egg.";
            }
                
            if (single_entry_mode.length() > 0)
            {
                subentry.entries.listClear();
                subentry.entries.listAppend(single_entry_mode);
            }
            if (need_palindome_location && $item[talisman o' nam].equipped_amount() == 0)
                subentry.entries.listAppend("Equip the Talisman o' Nam.");
        }
    }
    
    boolean [location] relevant_locations = makeConstantLocationArrayMutable($locations[the poop deck, belowdecks,cobb's knob laboratory,whitey's grove]);
    relevant_locations[__location_palindome] = true;

    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, relevant_locations));
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
            exploration_per_turn += 1.0;
        if (lookupItem("ornate dowsing rod").available_amount() > 0)
            exploration_per_turn += 2.0; //FIXME make completely accurate for first turn? not enough information available
        
        boolean have_blacklight_bulb = (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeHeadlight") == "Blacklight Bulb");
        if (have_blacklight_bulb)
            exploration_per_turn += 2.0;
        //FIXME deal with ultra-hydrated
        int combats_remaining = exploration_remaining;
        combats_remaining = ceil(to_float(exploration_remaining) / exploration_per_turn);
        subentry.entries.listAppend(exploration_remaining + "% exploration remaining. (" + pluralize(combats_remaining, "combat", "combats") + ")");
        if ($effect[ultrahydrated].have_effect() == 0)
        {
            if (__last_adventure_location == $location[the arid, extra-dry desert])
            {
                string [int] description;
                description.listAppend("Adventure in the Oasis.");
                if ($items[ten-leaf clover, disassembled clover].available_amount() > 0)
                    description.listAppend("Potentially clover for 20 turns, versus 5.");
                task_entries.listAppend(ChecklistEntryMake("__effect ultrahydrated", "place.php?whichplace=desertbeach", ChecklistSubentryMake("Acquire ultrahydrated effect", "", description), -11));
            }
            if (exploration > 0)
                subentry.entries.listAppend("Need ultra-hydrated from The Oasis. (potential clover for 20 turns)");
        }
        if (exploration < 10)
        {
            int turns_until_gnasir_found = -1;
            if (exploration_per_turn != 0.0)
                turns_until_gnasir_found = ceil(to_float(10 - exploration) / exploration_per_turn);
            
            subentry.entries.listAppend("Find Gnasir after " + pluralize(turns_until_gnasir_found, "turn", "turns") + ".");
        }
        else if (get_property_int("gnasirProgress") == 0 && exploration <= 14 && $location[the arid, extra-dry desert].noncombatTurnsAttemptedInLocation() == 0)
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
                    
                    subentry.entries.listAppend("Find " + pluralize(remaining, "more worm-riding manual page", "more worm-riding manual pages") + ".");
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
                if (base_quest_state.state_boolean["Manual Pages Given"])
                    subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), use drum machine.");
                else
                    subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), collect/return pages, then use drum machine.");
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
        if (!base_quest_state.state_boolean["Have UV-Compass eqipped"])
        {
            boolean should_output_compass_in_red = true;
            string line = "";
            if (lookupItem("ornate dowsing rod").available_amount() > 0)
            {
                line = "Equip the ornate dowsing rod.";
            }
            else
            {
                if ($item[uv-resistant compass].available_amount() == 0)
                {
                    line = "Acquire";
                    if (have_blacklight_bulb)
                    {
                        line = "Possibly acquire";
                        should_output_compass_in_red = false;
                    }
                  
                    line += " UV-resistant compass, equip for faster desert exploration. (shore vacation)";
                  
                    if (lookupItem("odd silver coin").available_amount() > 0)
                    {
                        line += "|Or acquire ornate dowsing rod from Paul's Boutique? (5 odd silver coins)";
                    }
                  
                }
                else if ($item[uv-resistant compass].available_amount() > 0)
                {
                    line = "Equip the UV-resistant compass.";
                }
            }
            if (line.length() > 0)
            {
                if (should_output_compass_in_red)
                    line = HTMLGenerateSpanFont(line, "red", "");
                subentry.entries.listAppend(line);
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
            boolean have_pyramid_position = false;
            int pyramid_position = get_property_int("pyramidPosition");
            
            //Uncertain:
            if (get_property_int("lastPyramidReset") == my_ascensions())
                have_pyramid_position = true;
            
            //I think there are... five positions?
            //1=Ed, 2=bad, 3=vending machine, 4=token, 5=bad
            int next_position_needed = -1;
            int additional_turns_after_that = 0;
            string task;
            boolean ed_waiting = get_property_boolean("pyramidBombUsed");
            boolean done_with_wheel_turning = false;
            if (2318.to_item().available_amount() > 0 || ed_waiting)
            {
                //need 1
                next_position_needed = 1;
                additional_turns_after_that = 0;
                
                boolean delay_for_semirare = CounterLookup("Semi-rare").CounterWillHitExactlyInTurnRange(0, 6);
                
                if (delay_for_semirare)
                {
                    task = HTMLGenerateSpanFont("Avoid fighting Ed the Undying, semi-rare coming up ", "red", "");
                }
                else
                {
                    int ed_ml = 180 + monster_level_adjustment_ignoring_plants();
                    task = "fight Ed in the lower chambers";
                    if (ed_ml > my_buffedstat($stat[moxie]))
                        task += " (" + ed_ml + " attack)";
                }
                if (ed_waiting)
                    done_with_wheel_turning = true;
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
            
            
            if (!have_pyramid_position)
            {
                tasks.listClear();
                tasks.listAppend("look at the pyramid");
            }
            
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
            
            if (!done_with_wheel_turning)
            {
                string [int] relevant_items;
                if ($item[tomb ratchet].available_amount() > 0)
                    relevant_items.listAppend(pluralize($item[tomb ratchet]));
                if ($item[tangle of rat tails].available_amount() > 0)
                    relevant_items.listAppend(pluralize($item[tangle of rat tails]));
                  
                if (relevant_items.count() > 0)
                    subentry.entries.listAppend(relevant_items.listJoinComponents(", ", "and") + " available.");
            }
            //FIXME track wheel being placed
            //noncombat_queue => Whee! will show if we have found the wheel
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
        entry.target_location = "place.php?whichplace=woods";
        ChecklistSubentry subentry;
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Unlock the hidden city via the hidden temple.");
        if ($item[the Nostril of the Serpent].available_amount() == 0)
            subentry.entries.listAppend("Need nostril of the serpent.");
        if ($item[stone wool].available_amount() > 0)
        {
            if ($effect[Stone-Faced].have_effect() == 0)
                entry.target_location = "inventory.php?which=3";
            subentry.entries.listAppend(pluralize($item[stone wool]) + " available.");
        }
        entry.subentries.listAppend(subentry);
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
        int hospital_progress = get_property_int("hiddenHospitalProgress");
        int apartment_progress = get_property_int("hiddenApartmentProgress");
        int office_progress = get_property_int("hiddenOfficeProgress");
        
        boolean at_last_spirit = false;
        
        if (bowling_progress == 8 && hospital_progress == 8 && apartment_progress == 8 && office_progress == 8 || $item[stone triangle].available_amount() == 4)
        {
            at_last_spirit = true;
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
                    subentry.entries.listAppend("Fight the protector spectre!");
                }
            }
        
            entry.subentries.listAppend(subentry);
        }
        if (!at_last_spirit)
        {
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
                if (my_basestat($stat[muscle]) < 62)
                {
                    string line = "Will need " + (62 - my_basestat($stat[muscle])) + " more muscle to equip machete.";
                    subentry.entries.listAppend(line);
                }
            
                entry.subentries.listAppend(subentry);
            }
        }
        
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
                if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && lookupSkill("Shake it off").have_skill())
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid using Shake It Off to heal", "red", "") + ", it'll remove the curse.");
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
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
                if ($item[McClusky file (complete)].available_amount() == 0)
                {
                    int files_found = $item[McClusky file (page 1)].available_amount() + $item[McClusky file (page 2)].available_amount() + $item[McClusky file (page 3)].available_amount() + $item[McClusky file (page 4)].available_amount() + $item[McClusky file (page 5)].available_amount();
                    int files_not_found = 5 - files_found;
                    if (files_not_found > 0)
                    {
                        subentry.entries.listAppend("Olfact accountant.");
                        subentry.entries.listAppend("Need " + pluralize(files_not_found, "more McClusky file", "more McClusky files") + ". Found from pygmy witch accountants.");
                        //if (!$monster[pygmy witch lawyer].is_banished())
                            //subentry.entries.listAppend("Potentially banish lawyers.");
                    }
                    if ($item[Boring binder clip].available_amount() == 0)
                        subentry.entries.listAppend("Need boring binder clip. (raid the supply cabinet, office NC)");
                }
                else
                {
                    subentry.entries.listAppend("You have the complete McClusky files, fight boss.");
                }
                subentry.entries.listAppend("NC appears first on the 6th adventure, then every 5 adventures.");
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
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
                    subentry.entries.listAppend("Potentially banish pygmy orderlies.");
                
        
                string [int] items_we_have_unequipped;
                item [int] items_we_have_equipped;
                foreach it in $items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel]
                {
                    boolean can_equip = true;
                    if (it.to_slot() == $slot[shirt] && !__misc_state["Torso aware"])
                        can_equip = false;
                    if (it.available_amount() > 0 && it.equipped_amount() == 0 && can_equip)
                    {
                        buffer line;
                        line.append(it);
                        line.append(" (");
                        line.append(it.to_slot().slot_to_string());
                        if (!it.can_equip())
                            line.append(", can't equip yet");
                        line.append(")");
                        items_we_have_unequipped.listAppend(line);
                    }
                    if (it.equipped_amount() > 0)
                        items_we_have_equipped.listAppend(it);
                }
                if (items_we_have_unequipped.count() > 0)
                {
                    subentry.entries.listAppend("Equipment unequipped: (+10% chance of protector spirit per piece)|*" + items_we_have_unequipped.listJoinComponents("|*"));
                }
                if (items_we_have_equipped.count() > 0)
                    subentry.entries.listAppend((items_we_have_equipped.count() * 10) + "+?% chance of protector spirit encounter.");
                else
                    subentry.entries.listAppend("?% chance of protector spirit encounter.");
            }
            
            
            entry.subentries.listAppend(subentry);
        }
    
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
                
                if ($item[bowling ball].available_amount() > 0)
                    line += "|Have " + pluralizeWordy($item[bowling ball]) + ".";
                
                subentry.entries.listAppend(line);
                
                //FIXME pop up a reminder to acquire bowl of scorpions
                if (__misc_state["free runs usable"])
                {
                    if (hidden_tavern_unlocked)
                    {
                        if ($item[bowl of scorpions].available_amount() == 0)
                            subentry.entries.listAppend(HTMLGenerateSpanFont("Buy a bowl of scorpions", "red", "") + " from the Hidden Tavern to free run from drunk pygmys.");
                    }
                    else
                    {
                        subentry.entries.listAppend("Possibly unlock the hidden tavern first, for free runs from drunk pygmies.");
                    }
                }
            }
        
        
        
            entry.subentries.listAppend(subentry);
        }
        
        if (!at_last_spirit)
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
                    subentry.entries.listAppend("Use book of matches.");
                else
                {
                    if (janitors_relocated_to_park)
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, Hidden Park, 20% drop)");
                    else
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, everywhere in the hidden city, 20% drop)");
                    
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
        }
    
    
        if (false) //debug internals
        {
            ChecklistSubentry subentry;
            subentry.header = "Debug";
            string [int] show_properties = split_string_alternate("hiddenApartmentProgress,hiddenBowlingAlleyProgress,hiddenHospitalProgress,hiddenOfficeProgress", ","); //8,8,8,8 when finished
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
        subentry.entries.listAppend("Use the spooky temple map.");
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
    
    if (my_level() < 6)
        subentry.entries.listAppend("There's also another unlock quest at level six, but it's slower.");
    else
        subentry.entries.listAppend("There's also another unlock quest, but it's slower.");
    
    if (!__quest_state["Manor Unlock"].state_boolean["ballroom song effectively set"])
    {
        subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "place.php?whichplace=woods", subentry, $locations[the spooky forest]));
    }
    else
    {
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "place.php?whichplace=woods", subentry, , $locations[the spooky forest]));
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