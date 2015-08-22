
void QWhiteCitadelInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questG02Whitecastle");
    
    //sorry, no way to query for familiar name
    state.quest_name = my_name().HTMLEscapeString() + " and Kumar Go To White Citadel";
    if (my_familiar() == $familiar[black cat])
        state.quest_name = my_name().HTMLEscapeString() + " and Luna Go To White Citadel";
    state.image_name = "__item White Citadel burger";
    
    if ($item[White Citadel Satisfaction Satchel].available_amount() > 0 && state.mafia_internal_step < 11)
        QuestStateParseMafiaQuestPropertyValue(state, "step10");
    if ($effect[SOME PIGS].have_effect() == 2147483647 && state.mafia_internal_step < 7)
        QuestStateParseMafiaQuestPropertyValue(state, "step6");
    
    __quest_state["White Citadel"] = state;
}

void QWhiteCitadelGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__misc_state["in aftercore"] && !in_bad_moon()) //not yet
        return;
    if (!__misc_state["guild open"]) //bugged
        return;
	QuestState base_quest_state = __quest_state["White Citadel"];
	if (!base_quest_state.in_progress && !(in_bad_moon() && !base_quest_state.started))
		return;
    
    boolean using_black_cat_equivalent = ($familiars[O.A.F.,black cat] contains my_familiar());
    
    if (__misc_state["in run"] && $location[The Road to the White Citadel].turnsAttemptedInLocation() == 0 && !in_bad_moon()) //not until they're sure
        return;
    
    boolean add_as_future_task = false;
    
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "place.php?whichplace=woods";
    
    if (in_bad_moon())
    {
        string [int] reasons;
        if (base_quest_state.mafia_internal_step < 6)
            reasons.listAppend("duonoculars");
        if (base_quest_state.mafia_internal_step < 8)
            reasons.listAppend("food from the wand of pigification");
        if (base_quest_state.mafia_internal_step < 11)
            reasons.listAppend("an epic drink");
        
        if (reasons.count() > 0)
            subentry.entries.listAppend("Relevant in Bad Moon for " + reasons.listJoinComponents(", ", "and") + ".");
    }
    if (!base_quest_state.started)
    {
        if (QuestState("questG01Meatcar").finished || $item[bitchin' meatcar].available_amount() > 0)
        {
            subentry.entries.listAppend("Visit your friend at the guild to start the quest.");
            active_url = "guild.php";
        }
        else
        {
            subentry.entries.listAppend("Build a meatcar first.");
            active_url = "";
        }
    }
    else if (base_quest_state.mafia_internal_step == 1)
    {
        //1	Find the road to the White Citadel, somewhere in Whitey's Grove.
        //Unlock the road to white citadel:
        subentry.modifiers.listAppend("+15% combat");
        subentry.modifiers.listAppend("free runs");
        subentry.entries.listAppend("Adventure in Whitey's Grove, unlock the road to the White Citadel.");
    }
    else if (base_quest_state.mafia_internal_step >= 2 && base_quest_state.mafia_internal_step <= 4)
    {
        //2	You've found the Road to the White Citadel! Now you can begin your quest there.
        //3	Make your way through the dark forest near the Road to the White Citadel
        //4	pairs of burnouts near the Road to the White Citadel.
        int burnouts_defeated = get_property_int("burnoutsDefeated");
        int burnouts_remaining = 30 - burnouts_defeated;
        
        subentry.modifiers.listAppend("+item");
        
        subentry.entries.listAppend("Adventure on the Road to White Citadel, defeat " + pluraliseWordy(burnouts_remaining, "more set of burn-outs", "more burn-outs") + ".");
        
        item opium_grenade = $item[opium grenade];
        
        if (burnouts_remaining > 1)
        {
            if (opium_grenade.storage_amount() > 1 && pulls_remaining() == -1)
                subentry.entries.listAppend("Pull some opium grenades from hagnk's.");
            else if (opium_grenade.storage_amount() > 0 && pulls_remaining() == -1)
                subentry.entries.listAppend("Pull an opium grenade from hagnk's.");
            else if (opium_grenade.available_amount() == 1)
                subentry.entries.listAppend("Throw an opium grenade at burnouts.");
            else if (opium_grenade.available_amount() > 1)
                subentry.entries.listAppend("Throw opium grenades at burnouts.");
        }
        
        if ($item[poppy].available_amount() >= 2)
        {
            string line = "Make opium grenade. (meatpaste poppy + poppy)";
            if (opium_grenade.available_amount() == 0)
                line = HTMLGenerateSpanFont(line, "red");
            subentry.entries.listAppend(line);
        }
        
        //turn estimation why not?
        float grenades_have_now = opium_grenade.available_amount().to_float() + $item[poppy].available_amount().to_float() * 0.5;
        
        float poppy_one_drop_rate = clampNormalf(0.3 * (1.0 + $location[the road to the white citadel].item_drop_modifier_for_location() / 100.0));
        float poppy_two_drop_rate = clampNormalf(0.1 * (1.0 + $location[the road to the white citadel].item_drop_modifier_for_location() / 100.0));
        if (using_black_cat_equivalent)
        {
            //strangely, there's no public listing of the batting away rates of these familiars
            //umm... let's go with the assumption of 25%.
            //data we have: 35 items batted, 120 items not batted, 22.5% rate. so 20-25%?
            poppy_one_drop_rate *= 0.75;
            poppy_two_drop_rate *= 0.75;
        }
        
        if (my_path_id() == PATH_HEAVY_RAINS)
        {
            float washaway_rate = $location[The Road to the White Citadel].washaway_rate_of_location();
            
            poppy_one_drop_rate *= (1.0 - washaway_rate);
            poppy_two_drop_rate *= (1.0 - washaway_rate);
        }
        
        float grenades_per_combat = (poppy_one_drop_rate + poppy_two_drop_rate) * 0.5;
        
        float turns_remaining = burnouts_remaining;
        float burnouts_defeated_per_turn = 1.0 + grenades_per_combat * 2.0;
        
        if (burnouts_defeated_per_turn > 0.0)
        {
            //very approximate:
            float operating_burnouts_remaining = burnouts_remaining;
            
            operating_burnouts_remaining -= 3.0 * grenades_have_now;
            turns_remaining = grenades_have_now * 1.0;
            
            turns_remaining += operating_burnouts_remaining / burnouts_defeated_per_turn;
        }
        turns_remaining = clampf(turns_remaining, 1.0, 30.0);
        if (burnouts_remaining == 1)
            subentry.entries.listAppend("One More Turn remaining.");
        else
            subentry.entries.listAppend("~" + turns_remaining.roundForOutput(1) + " turns remaining.");
        
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //5	Defeat the terrible biclops guarding the Road to the White Citadel.
        subentry.entries.listAppend("Defeat the terrible biclops on the Road to the White Citadel.");
    }
    else if (base_quest_state.mafia_internal_step == 6)
    {
        //6	(Make your way through the dark forest near the Road to the White Citadel)
        subentry.entries.listAppend("Adventure on the Road to the White Citadel.");
        
        string line;
        
        line = "Careful: this will turn your familiars into pigs";
        if (!using_black_cat_equivalent)
            line = HTMLGenerateSpanFont(line, "red"); //ruby red spanners
        line += ", who are unable to do anything, until you defeat Circe.";
        
        if (using_black_cat_equivalent)
            line += "|Um... not that you'll mind.";
        subentry.entries.listAppend(line);
    }
    else if (base_quest_state.mafia_internal_step == 7)
    {
        //7	Get into the witch's hut near the Road to the White Citadel. You could break the door down, but that seems risky. Maybe you can find a key somewhere?
        subentry.entries.listAppend("Kick in the front door of the witch, on the Road to the White Citadel.");
        subentry.entries.listAppend("This will bring back your familiars.");
        if (my_familiar() == $familiar[black cat])
        {
            add_as_future_task = true;
            subentry.entries.listAppend("Or possibly don't. Poor kitty...");
        }
        else if (my_familiar() == $familiar[O.A.F.])
        {
            add_as_future_task = true;
            subentry.entries.listAppend("Or possibly don't. Poor robot...");
        }
    }
    else if (base_quest_state.mafia_internal_step == 8 || base_quest_state.mafia_internal_step == 9)
    {
        //8	(Make your way through the dark forest near the Road to the White Citadel)
        //9	Get through the cave full of shiny, delicious, enticing treasure chests near the Road to the White Citadel.
        subentry.entries.listAppend("Adventure on the Road to the White Citadel, ignoring the treasure chests.");
    }
    else if (base_quest_state.mafia_internal_step == 10)
    {
        //10	Defeat the final obstacle on your way down the Road to the White Citadel.
        subentry.entries.listAppend("Defeat Elp&iacute;zo &amp; Crosybdis, on the Road to the White Citadel, then collect the White Citadel Satisfaction Satchel.");
    }
    else if (base_quest_state.mafia_internal_step == 11 && $item[White Citadel Satisfaction Satchel].available_amount() == 0)
    {
        //11	lunch at the White Citadel.
        subentry.entries.listAppend("Visit the white citadel for the White Citadel Satisfaction Satchel.");
    }
    else if (base_quest_state.mafia_internal_step == 11 || $item[White Citadel Satisfaction Satchel].available_amount() > 0)
    {
        //11	lunch at the White Citadel.
        //Visit guild:
        subentry.entries.listAppend("Visit your friend at the guild.");
        active_url = "guild.php";
    }
//final	You've delivered a satchel of incredibly greasy food to someone you barely know. Plus, you can now shop at White Citadel whenever you want. Awesome!
    
    
    boolean [location] relevant_locations;
    relevant_locations[$location[whitey's grove]] = true;
    relevant_locations[$location[the road to the white citadel]] = true;
    
    string image_name = base_quest_state.image_name;
    if (my_familiar() == $familiar[black cat])
        image_name = "__familiar black cat";
        
        
    ChecklistEntry entry = ChecklistEntryMake(image_name, active_url, subentry, relevant_locations);
    if (add_as_future_task)
        future_task_entries.listAppend(entry);
    else
        optional_task_entries.listAppend(entry);
}