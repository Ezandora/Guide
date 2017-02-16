RegisterResourceGenerationFunction("IOTMTimeSpinnerGenerateResource");
void IOTMTimeSpinnerGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!mafiaIsPastRevision(17209))
        return;
    //Warn about eating if they're low on turns - you can't use the time spinner when you're out of adventures.
    if ($item[Time-Spinner].available_amount() == 0)
        return;
    int minutes_left = clampi(10 - get_property_int("_timeSpinnerMinutesUsed"), 0, 10);
    if (minutes_left <= 0)
        return;
    
    string [int] description;
    
    if (minutes_left >= 3)
    {
        //Recent fight - 3 minutes - fight something past. Umm... hmm... same as any monster you copy? Though with restrictions. Plus olfaction-lite in NA.
        int amount = minutes_left / 3;
        description.listAppend(HTMLGenerateSpanOfClass(pluralise(amount, "recent fight", "recent fights"), "r_bold") + ": Re-fight a monster this ascension.");
        //Delicious meal - 3 minutes
        if (__misc_state["can eat just about anything"] && availableFullness() > 0)
        {
            description.listAppend(HTMLGenerateSpanOfClass(pluralise(amount, "meal", "meals"), "r_bold") + ": Re-eat something else today.");
        }
    }
    //Way back in time - 1 minute, stats, costs a turn(?)
    if (minutes_left >= 2)
    {
        //Visit the far future - 2 minutes, star-trek mini-game, lets you replicate things. Script fodder.
        if (!get_property_boolean("_timeSpinnerReplicatorUsed"))
        {
            string [int] options;
            if (__misc_state["can eat just about anything"] && availableFullness() > 0)
                options.listAppend("epic food");
            if (__misc_state["can drink just about anything"] && availableDrunkenness() > 0)
                options.listAppend("drink");
            if (!in_ronin())
                options.listAppend("something to sell");
            if (my_path_id() == PATH_GELATINOUS_NOOB && !lookupSkill("Pathological Greed").have_skill() && $item[shot of Kardashian Gin].available_amount() == 0)
            {
                options.listAppend("Kardashian Gin for +meat skill");
            }
            if (options.count() == 0)
                options.listAppend("item");
            description.listAppend(HTMLGenerateSpanOfClass("Future", "r_bold") + ": once/day " + options.listJoinComponents(" / ") + ".");
        }
    }
    //Play a time prank - 1 minute, heart
    
    resource_entries.listAppend(ChecklistEntryMake("Hourglass", "inv_use.php?whichitem=9104&pwd=" + my_hash(), ChecklistSubentryMake(pluralise(minutes_left, "Time-Spinner minute", "Time-Spinner minutes"), "", description), 5));
}