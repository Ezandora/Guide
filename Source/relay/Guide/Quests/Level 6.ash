
void QLevel6Init()
{
	//questL06Friar
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL06Friar");
    if (my_path_id() == PATH_COMMUNITY_SERVICE) QuestStateParseMafiaQuestPropertyValue(state, "finished");
	state.quest_name = "Deep Fat Friars' Quest";
	state.image_name = "forest friars";
	state.council_quest = true;
	
	if (my_level() >= 6 || my_path_id() == PATH_EXPLOSIONS)
		state.startable = true;
	
	__quest_state["Level 6"] = state;
	__quest_state["Friars"] = state;
}

float QLevel6TurnsToCompleteArea(location place)
{
    //FIXME not sure how accurate these calculations are.
    //First NC will always happen at 6, second at 11, third at 16.
    int turns_spent_in_zone = turnsAttemptedInLocation(place); //not always accurate
    int ncs_found = noncombatTurnsAttemptedInLocation(place);
    
    boolean [string] area_known_ncs;
    if (place == $location[the dark neck of the woods])
        area_known_ncs = $strings[How Do We Do It? Quaint and Curious Volume!,Strike One!,Dodecahedrariffic!];
    if (place == $location[The Dark Heart of the Woods])
        area_known_ncs = $strings[Moon Over the Dark Heart,Running the Lode,Imp Be Nimble\, Imp Be Quick];
    if (place == $location[The Dark Elbow of the Woods])
        area_known_ncs = $strings[Deep Imp Act,Imp Art\, Some Wisdom,Butter Knife? I'll Take the Knife];
    
    if (area_known_ncs.count() > 0)
    {
        ncs_found = 0;
        string [int] location_ncs = place.locationSeenNoncombats();
        foreach key, s in location_ncs
        {
            if (area_known_ncs contains s)
                ncs_found += 1;
        }
    }
    if (ncs_found == 3)
        return 0.0;
    
    float turns_remaining = 0.0;
    int ncs_remaining = MAX(0, 3 - ncs_found);
    
    float combat_rate = 0.9 + combat_rate_modifier() / 100.0;
    float noncombat_rate = 1.0 - combat_rate;
    
    if (noncombat_rate != 0.0)
        turns_remaining = ncs_remaining / noncombat_rate;
    else
        turns_remaining = 10000.0; //how do you refer to infinity in this language?
    
    return MIN(turns_remaining, MAX(0.0, 16.0 - turns_spent_in_zone.to_float()));
}


void QLevel6GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 6"].in_progress)
		return;
	boolean want_hell_ramen = false;
	if ($skill[pastamastery].skill_is_usable() && $skill[Advanced Saucecrafting].skill_is_usable())
		want_hell_ramen = true;
    if (my_path_id() == PATH_SLOW_AND_STEADY)
        want_hell_ramen = false;
    want_hell_ramen = false; //this needs rethinking
    
	boolean hot_wings_relevant = __quest_state["Pirate Quest"].state_boolean["hot wings relevant"];
	boolean need_more_hot_wings = __quest_state["Pirate Quest"].state_boolean["need more hot wings"];
	
	QuestState base_quest_state = __quest_state["Level 6"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	if (want_hell_ramen && __misc_state["have olfaction equivalent"])
		subentry.modifiers.listAppend("olfact hellions");
	
	string [int] sources_need_234;
	if (want_hell_ramen)
		sources_need_234.listAppend("hell ramen");
	if (need_more_hot_wings)
		sources_need_234.listAppend("hot wings");
	if (sources_need_234.count() > 0)
		subentry.modifiers.listAppend("+234% item");
    
    boolean hipster_fights_needed = false;
    boolean need_minus_combat = false;
	if ($item[dodecagram].available_amount() == 0)
    {
        hipster_fights_needed = true;
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Neck of the Woods", "r_bold") + ", acquire dodecagram.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the dark neck of the woods]), 1) + " average turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	if ($item[box of birthday candles].available_amount() == 0)
    {
        hipster_fights_needed = true;
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Heart of the Woods", "r_bold") + ", acquire box of birthday candles.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the Dark Heart of the Woods]), 1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	if ($item[Eldritch butterknife].available_amount() == 0)
    {
        hipster_fights_needed = true;
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Elbow of the Woods", "r_bold") + ", acquire Eldritch butterknife.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the Dark Elbow of the Woods]), 1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
    
    //hipster fights advance the superlikelies. in slow paths, is this relevant?
    //FIXME suggest in HCO/S&S?
    //if (hipster_fights_needed && __misc_state["have hipster"])
        //subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
	
    string [int] needed_modifiers;
    if (need_minus_combat)
    {
        subentry.modifiers.listAppend("-combat");
        needed_modifiers.listAppend("-combat");
    }
	if (sources_need_234.count() > 0)
        needed_modifiers.listAppend("+234% item for " + listJoinComponents(sources_need_234, "/"));
    if (needed_modifiers.count() > 0)
        subentry.entries.listAppend("Run " + needed_modifiers.listJoinComponents(", ", "and") + ".");
    
	if ($item[dodecagram].available_amount() + $item[box of birthday candles].available_amount() + $item[Eldritch butterknife].available_amount() == 3)
    {
        if (!(hot_wings_relevant && $item[hot wing].available_amount() <3))
        {
            subentry.entries.listAppend("Go to the cairn stones!");
        }
        else
        {
            subentry.entries.listAppend("Visit the dark heart of the woods for hot wings.");
        }
    }
	if (!get_property_ascension("lastTempleUnlock") && QuestState("questM16Temple").in_progress && $item[heavy-duty bendy straw].available_amount() == 0)
        subentry.entries.listAppend("Potentially find a heavy-duty bendy straw, first.|From fallen archfiends in the dark heart of the woods.");
	if (__misc_state_int["ruby w needed"] > 0)
		subentry.entries.listAppend("Potentially find ruby W, if not clovering (w imp, dark neck, 30% drop)");
	if (hot_wings_relevant)
    {
        if ($item[hot wing].available_amount() <3 )
            subentry.entries.listAppend((MIN(3, $item[hot wing].available_amount())) + "/3 hot wings for pirate quest. (optional, 30% drop)");
        else
            subentry.entries.listAppend((MIN(3, $item[hot wing].available_amount())) + "/3 hot wings for pirate quest.");
    }
	boolean should_delay = false;
	if (!__quest_state["Manor Unlock"].state_boolean["ballroom song effectively set"] && need_minus_combat)
	{
		subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
		should_delay = true;
	}
	
	if (should_delay)
		future_task_entries.listAppend(ChecklistEntryMake(76, base_quest_state.image_name, "friars.php", subentry, $locations[the dark neck of the woods, the dark heart of the woods, the dark elbow of the woods]));
	else
		task_entries.listAppend(ChecklistEntryMake(77, base_quest_state.image_name, "friars.php", subentry, $locations[the dark neck of the woods, the dark heart of the woods, the dark elbow of the woods]));
}
