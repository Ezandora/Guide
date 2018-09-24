
RegisterResourceGenerationFunction("IOTMNeverendingPartyGenerateResource");
void IOTMNeverendingPartyGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!mafiaIsPastRevision(18865))
        return;
    if (!__iotms_usable[lookupItem("Neverending Party invitation envelope")])
        return;
    
    int free_fights_left = clampi(10 - get_property_int("_neverendingPartyFreeTurns"), 0, 10);
    
    string [int] modifiers;
    string [int] description;
    modifiers.listAppend("+meat");
    
    if (free_fights_left >= 2)
    {
        if (__misc_state["need to level"])
        {
            string [int] directions;
            if (my_primestat() == $stat[muscle])
            {
                directions.listAppend("Kitchen");
                directions.listAppend("Muscle spice");
            }
            else if (my_primestat() == $stat[mysticality])
            {
                directions.listAppend("Upstairs");
                directions.listAppend("Read the tomes");
            }
            else if (my_primestat() == $stat[moxie])
            {
                directions.listAppend("Basement");
                directions.listAppend("Use the hair gel");
            }
            description.listAppend("Experience buff: " + directions.listJoinComponents(__html_right_arrow_character) + ".");
        }
        if (__misc_state["in run"])
            description.listAppend("ML buff: " + listMake("Backyard", "Candle wax").listJoinComponents(__html_right_arrow_character));
    }
    if (free_fights_left > 0)
	    resource_entries.listAppend(ChecklistEntryMake("__item party hat", "place.php?whichplace=town_wrong", ChecklistSubentryMake(pluralise(free_fights_left, "free party fight", "free party fights"), modifiers, description), lookupLocations("The Neverending Party")).ChecklistEntryTagEntry("daily free fight"));
}
