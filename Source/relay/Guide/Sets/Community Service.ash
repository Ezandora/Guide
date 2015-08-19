
void SCommunityServiceGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_path_id() != PATH_COMMUNITY_SERVICE) //FIXME not correct
        return;
    if (!__misc_state["in run"])
        return;
    if (!__setting_debug_mode) //not yet
        return;
    boolean [item] blacklist;
    
    //None, HP, muscle, mysticality, moxie, familiar weight, melee damage, spell damage, noncombat, booze drop, hot res
    //list in ideal order to finish the path as you are(?)
    
    //equaliser potions
    if (true)
    {
        item [int] hp_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Buffed HP Maximum", 150.0, blacklist); //what a strange lookup name
        item [int] hp_potions_2 = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Maximum HP", 150.0, blacklist); //something else?
        
        item [int] muscle_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Muscle", 0.0, blacklist);
        item [int] muscle_percent_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Muscle Percent", 0.0, blacklist);
        
        
        string [int] relevant_potions_output;
        foreach key, it in hp_potions
        {
            relevant_potions_output.listAppend(it + " (+" + it.to_effect().numeric_modifier("Buffed HP Maximum").roundForOutput(0) + ")");
        }
        
        task_entries.listAppend(ChecklistEntryMake("__item helmet turtle", "council.php", ChecklistSubentryMake("Perform HP service", "+hp", relevant_potions_output.listJoinComponents(", ", "and"))));
    }
    
    
    foreach s in $strings[Buffed HP Maximum,Muscle,Muscle Percent,Moxie,Moxie Percent,Mysticality,Mysticality Percent,Weapon Damage,Weapon Damage Percent,spell damage, spell damage percent,Combat Rate,hot resistance]
    {
        item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier(s, -100000.0, blacklist); //what a strange lookup name
        string [int] relevant_potions_output;
        foreach key, it in relevant_potions
        {
            relevant_potions_output.listAppend(it + " (+" + it.to_effect().numeric_modifier(s).roundForOutput(0) + ")");
        }
        task_entries.listAppend(ChecklistEntryMake("__item helmet turtle", "council.php", ChecklistSubentryMake("Perform " + s + " service", "", relevant_potions_output.listJoinComponents(", ", "and"))));
    }
}