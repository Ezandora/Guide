
RegisterResourceGenerationFunction("IOTMSpacegateGenerateResource");
void IOTMSpacegateGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[lookupItem("Spacegate access badge")])
        return;
    if (!get_property_boolean("_spacegateVaccine"))
    {
        boolean rainbow_unlocked = get_property_boolean("spacegateVaccine1"); //+3 all res
        boolean broad_spectrum_unlocked = get_property_boolean("spacegateVaccine2"); //+50% all stats
        boolean emotional_unlocked = get_property_boolean("spacegateVaccine3"); //+30 ML
        
        string [int] options;
        if (emotional_unlocked)
            options.listAppend("+30 ML");
        if (broad_spectrum_unlocked)
            options.listAppend("+50% stats");
        if (rainbow_unlocked)
            options.listAppend("+3 all res");
        
        boolean missing_one = !rainbow_unlocked || !broad_spectrum_unlocked || !emotional_unlocked;
        if (missing_one && lookupItem("spacegate research").available_amount() > 0)
            options.listAppend("unlock additional vaccines");
        if (options.count() > 0)
        {
            string [int] description;
            description.listAppend("30 turns, once/day.|" + options.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
            
            resource_entries.listAppend(ChecklistEntryMake("__item plus sign", "place.php?whichplace=spacegate&action=sg_vaccinator", ChecklistSubentryMake("Vaccination", "", description), 8));
        }
    }
}