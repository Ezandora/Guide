RegisterTaskGenerationFunction("IOTMTunnelOfLoveGenerateTasks");
void IOTMTunnelOfLoveGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME whatever these end up being named:
    if (!mafiaIsPastRevision(17805))
        return;
    if (!__iotms_usable[lookupItem("heart-shaped crate")])
        return;
    if (get_property_boolean("_loveTunnelUsed"))
        return;
    
    string [int] description;
    //equipment: LOV Eardigan (+25% muscle exp, +25 ML), LOV Epaulettes (+25% myst exp), LOV Earrings (+25% moxie exp, +50% meat, +3 all res)
    //50-turn buffs: Lovebotamy (10 stats/fight), Open Heart Surgery (+10 familiar weight), Wandering Eye Surgery (+50% item)
    //item: boomerang (arrow), toy dart gun (???), chocolate (adventures), flowers (???), elephant (???), TOAST! (toasty!)
    
    description.listAppend("Three free fights. Attack, spell, and pickpocket respectively for elixirs.");
    if (myPathId() == PATH_GELATINOUS_NOOB)
        description.listAppend("Equipment choice unimportant.");
    else
    {
    	string [int] equipment_choices;
        equipment_choices.listAppend(HTMLBoldIfTrue("Eardigan", my_primestat() == $stat[muscle] && __misc_state["in run"] && my_level() < 13) + " (+25% muscle exp, +25 ML)");
        if (myPathId() != PATH_G_LOVER)
	        equipment_choices.listAppend(HTMLBoldIfTrue("Epaulettes", my_primestat() == $stat[mysticality] && __misc_state["in run"] && my_level() < 13) + " (+25% myst exp)");
        equipment_choices.listAppend(HTMLBoldIfTrue("Earrings", (my_primestat() == $stat[moxie] && __misc_state["in run"] && my_level() < 13) || __misc_state["in aftercore"] || my_level() >= 13) + " (+25% moxie exp, +50% meat, +3 all res)");
        description.listAppend("Equipment choice:|*" + equipment_choices.listJoinComponents(", ", "or"));
    }
    string [int] buff_choices;
    if (myPathId() != PATH_G_LOVER)
    	buff_choices.listAppend("+10 stats/fight");
    buff_choices.listAppend("+10 familiar weight");
    buff_choices.listAppend("+50% item");
    description.listAppend("Buff choice: (50 turns)|*" + buff_choices.listJoinComponents(", ", "or"));
    
    string [int] usable_items;
    if (myPathId() != PATH_LIVE_ASCEND_REPEAT)
        usable_items.listAppend("single-use wandering copier");
    usable_items.listAppend("chat hearts");
    if (myPathId() != PATH_SLOW_AND_STEADY && myPathId() != PATH_G_LOVER)
        usable_items.listAppend("chocolate (adventures)");
    if ($familiar[space jellyfish].familiar_is_usable())
        usable_items.listAppend("toast");
    description.listAppend("Item choice:|*" + usable_items.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
    
    optional_task_entries.listAppend(ChecklistEntryMake("__item pink candy heart", "place.php?whichplace=town_wrong", ChecklistSubentryMake("Take a love trip", "", description)));
}

RegisterResourceGenerationFunction("IOTMTunnelOfLoveGenerateResource");
void IOTMTunnelOfLoveGenerateResource(ChecklistEntry [int] resource_entries)
{
    //mostly the boomerang
    //what does sokka throw? a boomeraang!
    
    if (__misc_state["in run"] && in_ronin())
    {
        /*item enamorang = $item[LOV Enamorang];
        if (enamorang.available_amount() > 0)
        {
            resource_entries.listAppend(ChecklistEntryMake("__item LOV Enamorang", "", ChecklistSubentryMake(pluralise(enamorang), "", "Copies the monster once as an arrow."), 5));
            
        }*/
        item chocolate = lookupItem("LOV Extraterrestrial Chocolate");
        if (chocolate.available_amount() > 0 && myPathId() != PATH_SLOW_AND_STEADY)
        {
            //FIXME list other chocolates?
            resource_entries.listAppend(ChecklistEntryMake("__item LOV Extraterrestrial Chocolate", "", ChecklistSubentryMake(pluralise(chocolate), "", "Adventures!"), 5));
            
        }
    }
}
