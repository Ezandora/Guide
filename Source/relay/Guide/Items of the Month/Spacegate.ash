
RegisterResourceGenerationFunction("IOTMSpacegateGenerateResource");
void IOTMSpacegateGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[$item[Spacegate access badge]])
        return;
    if (!get_property_boolean("_spacegateVaccine") && my_path_id_legacy() != PATH_G_LOVER)
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
        if (missing_one && $item[spacegate research].available_amount() > 0)
            options.listAppend("unlock additional vaccines");
        if (options.count() > 0)
        {
            string [int] description;
            description.listAppend("30 turns, once/day.|" + options.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
            
            resource_entries.listAppend(ChecklistEntryMake(603, "__item plus sign", "place.php?whichplace=spacegate&action=sg_vaccinator", ChecklistSubentryMake("Vaccination", "", description), 8).ChecklistEntrySetCategory("buff"));
        }
    }
    if (__misc_state["in run"] && my_primestat() == $stat[moxie] && __misc_state["need to level"] && get_property("_spacegatePlanetName") == "")
    {
        //Dial TFHSXKK:
        string [int] description;
        description.listAppend("Dial TFHSXKK, and skip every adventure until you reach Paradise Under a Strange Sun.|Will give 1000 stats and cost a turn. Not strictly optimal.");
        resource_entries.listAppend(ChecklistEntryMake(604, "__item portable spacegate", "place.php?whichplace=spacegate&action=sg_Terminal", ChecklistSubentryMake("Spacegate dial", "", description), 8));
    }
}
