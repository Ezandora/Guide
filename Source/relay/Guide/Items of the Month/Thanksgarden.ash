RegisterResourceGenerationFunction("IOTMThanksgardenGenerateResource");
void IOTMThanksgardenGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__misc_state["in run"])
        return;
    
    item turkey_blaster = $item[turkey blaster];
    item stuffing_fluffer = $item[stuffing fluffer];
    item cashew = $item[cashew];
    item cornucopia = $item[cornucopia];
    
    ChecklistSubentry [int] subentries;
    string url;
    string image_name;
    
    
    
    if (cornucopia.available_amount() > 0 && in_ronin())
    {
        string [int] description;
        description.listAppend("Open for thanksgarden food.");
        if (image_name == "")
            image_name = "__item cornucopia";
        if (url == "")
            url = "inventory.php?ftext=cornucopia";
        subentries.listAppend(ChecklistSubentryMake(pluralise(cornucopia), "", description));
    }
    int cashew_amount = cashew.available_amount();
    if (cashew_amount > 0 && in_ronin())
    {
        string [int] description;
        string [int] options;
        //so creatable_amount() is weird, so we perform the calculation ourselves
        /*
        > ash $item[cashew].available_amount()

        Returned: 13

        > ash $item[turkey blaster].creatable_amount()

        Returned: 0
        */
        if (myPathId() != PATH_NUCLEAR_AUTUMN && spleen_limit() > 0 && $item[cashew].available_amount() >= 3)
            options.listAppend(HTMLGreyOutTextUnlessTrue(pluralise($item[cashew].available_amount() / 3, $item[turkey blaster]) + " to burn delay", cashew_amount >= 3));
        if (!__quest_state["Level 12"].finished)
            options.listAppend(HTMLGreyOutTextUnlessTrue(pluralise($item[cashew].available_amount() / 3, $item[stuffing fluffer]) + " for the war", cashew_amount >= 3));
        if (myPathId() != PATH_NUCLEAR_AUTUMN && fullness_limit() > 0)
            options.listAppend("various foods");
        if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"] && $item[gravy boat].available_amount() == 0)
            options.listAppend(HTMLGreyOutTextUnlessTrue("gravy boat for the cyrpt (somewhat marginal)", cashew_amount >= 3));
        if (options.count() > 0)
            description.listAppend("Could make into " + options.listJoinComponents(", ", "or") + ".");
        
        string [int] foods_we_can_make;
        
        if (image_name == "")
            image_name = "__item cashew";
        if (url == "")
            url = "shop.php?whichshop=thankshop";
        subentries.listAppend(ChecklistSubentryMake(pluralise(cashew), "", description));
    }
    
    if (turkey_blaster.available_amount() > 0 && myPathId() != PATH_NUCLEAR_AUTUMN)
    {
        string [int] description;
        int uses_left = clampi(3 - get_property_int("_turkeyBlastersUsed"), 0, 3);
        int pre_spleen_uses_left = uses_left;
        uses_left = MIN(uses_left, availableSpleen() / 2);
        
        string [int] delay_areas;
        foreach l in $locations[the outskirts of cobb's knob,the spooky forest,The Castle in the Clouds in the Sky (Ground Floor),the haunted gallery,the haunted bathroom,the haunted ballroom,the boss bat's lair]
        {
            if (l.delayRemainingInLocation() > 1)
                delay_areas.listAppend(l);
        }
        
        description.listAppend("Will burn five turns of delay in the last area you've adventured.");
        if (delay_areas.count() > 0)
            description.listAppend("Suggested areas:|*" + delay_areas.listJoinComponents(", ", "and") + ".");
        if (uses_left == 0)
        {
            if (pre_spleen_uses_left > 0)
                description.listAppend("Cannot use any more today; no spleen room.");
            else
                description.listAppend("Cannot use any more today.");
        }
        else
            description.listAppend("Can use " + pluraliseWordy(uses_left, "more time", "more times") + " today.");
        
        
        if (image_name == "")
            image_name = "__item turkey blaster";
        if (url == "")
            url = "inventory.php?ftext=turkey+blaster";
        subentries.listAppend(ChecklistSubentryMake(pluralise(turkey_blaster), "", description));
    }
    if (!__quest_state["Level 12"].finished && __quest_state["Level 12"].state_int["frat boys left on battlefield"] > 0 && __quest_state["Level 12"].state_int["hippies left on battlefield"] > 0 && stuffing_fluffer.available_amount() > 0)
    {
        string [int] description;
        description.listAppend("Clears out level twelve armies. Use before adventuring on the battlefield.");
        
        if (image_name == "")
            image_name = "__item stuffing fluffer";
        if (url == "")
            url = "inventory.php?ftext=stuffing+fluffer";
        subentries.listAppend(ChecklistSubentryMake(pluralise(stuffing_fluffer), "", description));
    }
    
    
    if (subentries.count() > 0)
    {
        resource_entries.listAppend(ChecklistEntryMake(image_name, url, subentries, 4));
    }
    
}

RegisterTaskGenerationFunction("IOTMThanksgardenGenerateTasks");
void IOTMThanksgardenGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    int delay_limit = 4;
    if (get_property_int("_turkeyBlastersUsed") < 3 && availableSpleen() >= 2 && $item[turkey blaster].available_amount() + $item[turkey blaster].creatable_amount() > 0 && get_property_location("lastAdventure").delayRemainingInLocation() >= delay_limit)
    {
        string url = "";
        if ($item[turkey blaster].available_amount() > 0)
            url = "inventory.php?ftext=turkey+blaster";
        else
            url = "shop.php?whichshop=thankshop";
        location last_location = get_property_location("lastAdventure");
        string [int] description;
        description.listAppend("Save " + MIN(5, last_location.delayRemainingInLocation()) + " turns in " + last_location + ".");
        if (my_level() < 4)
            description.listAppend("Reach level four first.");
        boolean allow = true;
        if ($locations[the penultimate fantasy airship,the hidden office building,the hidden apartment building] contains last_location)
            allow = false;
        if (allow)
            task_entries.listAppend(ChecklistEntryMake("__item turkey blaster", url, ChecklistSubentryMake("Chew turkey blaster", "", description), -11));
    }
}
