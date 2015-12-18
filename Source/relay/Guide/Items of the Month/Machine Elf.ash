
RegisterResourceGenerationFunction("IOTMMachineElfGenerateResource");
void IOTMMachineElfGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!lookupFamiliar("machine elf").familiar_is_usable())
        return;
    
    int free_fights_remaining = clampi(5 - get_property_int("_machineElfFights"), 0, 5);
    if (false && free_fights_remaining > 0 && mafiaIsPastRevision(10000000000))
    {
        string url = "place.php?whichplace=dmt";
        string [int] description;
        string [int] modifiers;
        int importance = 0;
        if (!__misc_state["in run"] || !__misc_state["need to level"])
            importance = 6;
        string [int] tasks;
        if (my_familiar() != lookupFamiliar("machine elf"))
        {
            url = "familiar.php";
            tasks.listAppend("bring along your machine elf");
        }
        tasks.listAppend("adventure in the machine tunnels");
        description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + " to gain stats.");
        //FIXME suggest abstraction methods.
        modifiers.listAppend("+" + my_primestat().to_lower_case());
        resource_entries.listAppend(ChecklistEntryMake("__familiar machine elf", url, ChecklistSubentryMake(pluralise(free_fights_remaining, "free elf fight", "free elf fights"), "", description), importance));
    }
}