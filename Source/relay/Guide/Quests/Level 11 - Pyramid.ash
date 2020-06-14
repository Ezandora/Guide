
void QLevel11PyramidInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Pyramid");
    if (my_path_id() == PATH_COMMUNITY_SERVICE) QuestStateParseMafiaQuestPropertyValue(state, "finished");
    state.quest_name = "Pyramid Quest";
    state.image_name = "Pyramid";
    __quest_state["Level 11 Pyramid"] = state;
}

void QLevel11PyramidGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11"].in_progress)
        return;
    if (__quest_state["Level 11 Pyramid"].finished)
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Pyramid"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";
    if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"])
        return;
    //Desert explored.
    
    boolean definitely_have_staff_of_ed = false;
    if (2286.to_item().available_amount() > 0 && 2268.to_item().available_amount() > 0 && 2180.to_item().available_amount() > 0)
        definitely_have_staff_of_ed = true;
    
    if ($item[2325].available_amount() + $item[2325].creatable_amount() + $item[7961].available_amount() + $item[7961].creatable_amount() == 0 && !definitely_have_staff_of_ed)
    {
        //Staff of ed.
        //subentry.entries.listAppend("Find the Staff of Ed.");
        future_task_entries.listAppend(ChecklistEntryMake("Pyramid", "", ChecklistSubentryMake("Head down the pyramid", "", "Find the Staff of Ed.")));
        return;
    }
    else if (!base_quest_state.in_progress && $location[the upper chamber].turnsAttemptedInLocation() == 0)
    {
        url = "place.php?whichplace=desertbeach";
        subentry.entries.listAppend("Visit the pyramid, click on it.");
    }
    else
    {
        /*
        How the new pyramid seemingly works:
        Adventure six times in the upper chamber with -combat. (delay, free runs relevant) This unlocks the middle chamber with the adventure "Down Dooby-Doo Down Down"
        Adventure six times in the middle chamber with +400% item and banishes. (delay, free runs relevant). This unlocks the lower chamber.
        Adventure five times in the middle chamber with +400% item and banishes. (delay, free runs relevant) This unlocks the control chamber.
        After that, you handle the control chamber and solve the puzzle. One tomb ratchet/crumbling wooden wheel advances the puzzle by one step. So, you can farm tomb ratchets (+item) or wooden wheels (-combat). There's so much delay in the middle chamber though...
        "Under Control" is the control room unlock.
        
        */
        //middleChamberUnlock, lowerChamberUnlock, controlRoomUnlock implemented
        url = "place.php?whichplace=pyramid";
        boolean done_with_wheel_turning = false; //FIXME set this
        boolean should_generate_control_room_information = false;
        boolean ed_chamber_open = get_property_boolean("pyramidBombUsed");
        if (get_property_boolean("middleChamberUnlock") || $location[the middle chamber].turnsAttemptedInLocation() > 0 || $location[the upper chamber].noncombat_queue.contains_text("Down Dooby-Doo Down Down"))
        {
            //middle chamber unlocked:
            if (get_property_boolean("controlRoomUnlock") || $location[the middle chamber].noncombat_queue.contains_text("Under Control"))
            {
                //control room unlocked:
                should_generate_control_room_information = true;
                //FIXME implement this
                //FIXME suggest the better route
                subentry.modifiers.listAppend("+400% item OR -combat");
                subentry.modifiers.listAppend("olfact tomb rats");
                subentry.entries.listAppend("Can find crumbling wooden wheels in the upper chamber (-combat), or tomb ratchets in the middle chamber (+400% item, olfact rats)");
            }
            /*else if (get_property_boolean("lowerChamberUnlock") || $location[the middle chamber].noncombat_queue.contains_text("Further Down Dooby-Doo Down Down"))
            {
                //lower chamber unlocked:
                subentry.entries.listAppend("Adventure in the middle chamber for five total turns to unlock the control room.");
                subentry.modifiers.listAppend("+400% item");
                subentry.modifiers.listAppend("olfact tomb rats");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }*/
            else
            {
                //unlock lower chamber:
                int turns_spent = $location[the middle chamber].turns_spent;
                
                int turns_remaining = MAX(0, 11 - turns_spent);
                subentry.entries.listAppend("Adventure in the middle chamber for " + pluraliseWordy(turns_remaining, "more turn", "more turns") + " to unlock the control room.");
            
                subentry.modifiers.listAppend("+400% item");
                subentry.modifiers.listAppend("olfact tomb rats");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
                
            }
            if ($item[tangle of rat tails].available_amount() > 0)
                subentry.entries.listAppend("Use tangle of rat tails against tomb rats for more tomb ratchets.");
            if (my_path_id() == PATH_HEAVY_RAINS && $item[catfish whiskers].available_amount() > 0 && $effect[Fishy Whiskers].have_effect() == 0 && $item[tangle of rat tails].available_amount() > 0)
                subentry.entries.listAppend("Possibly use catfish whiskers to find more tomb ratchets.");
        }
        else
        {
            //unlock middle chamber:
            int turns_spent = $location[the upper chamber].turns_spent;
            int turns_remaining = MAX(0, 6 - turns_spent);
            subentry.entries.listAppend("Adventure in the upper chamber for " + pluraliseWordy(turns_remaining, "more turn", "more turns") + " to unlock the middle chamber.");
            subentry.modifiers.listAppend("-combat");
            if (__misc_state["have hipster"])
                subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
            if (__misc_state["free runs available"])
                subentry.modifiers.listAppend("free runs");
        }
        
        
        //Generate spin cycle:

        //this is not very good code:
        boolean have_pyramid_position = false;
        int pyramid_position = get_property_int("pyramidPosition");
        
        //Uncertain:
        //if (get_property_ascension("lastPyramidReset"))
        if (pyramid_position > 0) //does this work?
            have_pyramid_position = true;
        
        //I think there are... five positions?
        //1=Ed, 2=bad, 3=vending machine, 4=token, 5=bad
        int next_position_needed = -1;
        int additional_turns_after_that = 0;
        string task;
        done_with_wheel_turning = false;
        if (2318.to_item().available_amount() > 0 || ed_chamber_open)
        {
            //need 1
            next_position_needed = 1;
            additional_turns_after_that = 0;
            
            boolean delay_for_semirare = CounterLookup("Semi-rare").CounterWillHitExactlyInTurnRange(0, 6);
            if (delay_for_semirare)
            {
                task = HTMLGenerateSpanFont("Avoid fighting Ed the Undying, semi-rare coming up ", "red");
            }
            else
            {
                int ed_ml = 180 + monster_level_adjustment_for_location($location[the lower chambers]);
                task = "fight Ed in the lower chambers";
                if (ed_ml > my_buffedstat($stat[moxie]))
                    task += " (" + ed_ml + " attack)";
            }
            if (ed_chamber_open)
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
        int total_spins_needed = spins_needed + additional_turns_after_that;
        int spins_available = $item[tomb ratchet].available_amount() + $item[crumbling wooden wheel].available_amount();
        
        int extra_spin_sources_needed = clampi(total_spins_needed - spins_available, 0, 11);
        
        //Pyramid unlocked:
        if (should_generate_control_room_information)
        {
            
            string [int] tasks;
            if (spins_needed > 0)
            {
                if (spins_needed == 1)
                    tasks.listAppend("spin the pyramid One More Time");
                else
                    tasks.listAppend("spin the pyramid " + spins_needed.int_to_wordy() + " times");
                if ($item[tomb ratchet].available_amount() + $item[crumbling wooden wheel].available_amount() > 0)
                    url = "place.php?whichplace=pyramid&action=pyramid_control";
            }
            tasks.listAppend(task);
            
            
            if (!have_pyramid_position)
            {
                tasks.listClear();
                //tasks.listAppend("look at the pyramid"); //I dunno
            }
            
            if (ed_chamber_open && done_with_wheel_turning)
            {
                subentry.modifiers.listClear();
                subentry.entries.listClear();
            }
            
            if (tasks.count() > 0)
                subentry.entries.listPrepend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
            else
                subentry.entries.listAppend("Spin the control room, search the lower chambers! Then fight Ed.");
                
            if (ed_chamber_open && my_path_id() == PATH_EXPLOSIONS && lookupItem("low-pressure oxygen tank").equipped_amount() == 0)
            {
            	subentry.modifiers.listAppend("+hp regen");
                subentry.entries.listAppend("Keep +hp regen up, so you survive the multi-round fight without the oxygen tank?");
            }
        }
        
        if (!done_with_wheel_turning)
        {
            if (extra_spin_sources_needed > 0)
                subentry.entries.listAppend("Need " + HTMLGenerateSpanFont(int_to_wordy(extra_spin_sources_needed), "red") + " more ratchet/wheel" + ((extra_spin_sources_needed > 1) ? "s" : "") + ".");
            else
                subentry.entries.listAppend("Have enough wheels.");
            /*if (amount > 0)
                subentry.entries.listAppend(pluralise(amount, "wheel turn", "wheel turns") + " available.");*/
            if ($item[tangle of rat tails].available_amount() > 0 && extra_spin_sources_needed > 0)
                subentry.entries.listAppend(pluralise($item[tangle of rat tails]) + " available.");
        }
        
    }
    
    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the upper chamber,the lower chambers, the middle chamber]));
}
