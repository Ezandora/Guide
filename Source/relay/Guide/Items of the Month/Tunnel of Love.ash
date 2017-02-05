RegisterTaskGenerationFunction("IOTMTunnelOfLoveGenerateTasks");
void IOTMTunnelOfLoveGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME whatever these end up being named:
    if (!get_property_boolean("tunnelOfLoveAvailable"))
        return;
    if (get_property_boolean("_tunnelOfLoveVisited"))
        return;
    
    string [int] description;
    //equipment: cardigan, epaulettes, earrings
    //50-turn buffs: Lovebotamy (10 stats/fight), Open Heart Surgery (+10 familiar weight), Wandering Eye Surgery (+50% item)
    //item: boomerang (arrow), toy dart gun (???), chocolate (adventures), flowers (???), elephant (???), TOAST! (toasty!)
    
    
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