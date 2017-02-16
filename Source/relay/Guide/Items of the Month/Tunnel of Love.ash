RegisterTaskGenerationFunction("IOTMTunnelOfLoveGenerateTasks");
void IOTMTunnelOfLoveGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME whatever these end up being named:
    if (!mafiaIsPastRevision(17805))
        return;
    if (!get_property_boolean("loveTunnelAvailable"))
        return;
    if (get_property_boolean("_loveTunnelUsed"))
        return;
    
    string [int] description;
    //equipment: LOV Eardigan (+25% muscle exp, +25 ML), LOV Epaulettes (+25% myst exp), LOV Earrings (+25% moxie exp, +50% meat, +3 all res)
    //50-turn buffs: Lovebotamy (10 stats/fight), Open Heart Surgery (+10 familiar weight), Wandering Eye Surgery (+50% item)
    //item: boomerang (arrow), toy dart gun (???), chocolate (adventures), flowers (???), elephant (???), TOAST! (toasty!)
    
    description.listAppend("Three free fights. Attack, spell, and pickpocket respectively for elixirs.");
    if (my_path_id() == PATH_GELATINOUS_NOOB)
        description.listAppend("Equipment choice unimportant.");
    else
        description.listAppend("Equipment choice:|*" + HTMLBoldIfTrue("Eardigan", my_primestat() == $stat[muscle] && __misc_state["in run"] && my_level() < 13) + " (+25% muscle exp, +25 ML), " + HTMLBoldIfTrue("Epaulettes", my_primestat() == $stat[mysticality] && __misc_state["in run"] && my_level() < 13) + " (+25% myst exp), or " + HTMLBoldIfTrue("Earrings", (my_primestat() == $stat[moxie] && __misc_state["in run"] && my_level() < 13) || __misc_state["in aftercore"] || my_level() >= 13) + " (+25% moxie exp, +50% meat, +3 all res)");
    description.listAppend("Buff choice: (50 turns)|*+10 stats/fight, +10 familiar weight, or +50% item.");
    description.listAppend("Item choice:|*Single-use wandering copier, chat hearts, or chocolate (adventures).");
    
    optional_task_entries.listAppend(ChecklistEntryMake("__item pink candy heart", "place.php?whichplace=town_wrong", ChecklistSubentryMake("Take a love trip", "", description)));
}

RegisterResourceGenerationFunction("IOTMTunnelOfLoveGenerateResource");
void IOTMTunnelOfLoveGenerateResource(ChecklistEntry [int] resource_entries)
{
    //mostly the boomerang
    //what does sokka throw? a boomeraang!
    
    if (__misc_state["in run"])
    {
        item enamorang = lookupItem("LOV Enamorang");
        if (enamorang.available_amount() > 0)
        {
            resource_entries.listAppend(ChecklistEntryMake("__item LOV Enamorang", "", ChecklistSubentryMake(pluralise(enamorang), "", "Copies the monster once as an arrow."), 5));
            
        }
        item chocolate = lookupItem("LOV Extraterrestrial Chocolate");
        if (chocolate.available_amount() > 0 && my_path_id() != PATH_SLOW_AND_STEADY)
        {
            //FIXME list other chocolates?
            resource_entries.listAppend(ChecklistEntryMake("__item LOV Extraterrestrial Chocolate", "", ChecklistSubentryMake(pluralise(chocolate), "", "Adventures!"), 5));
            
        }
    }
}