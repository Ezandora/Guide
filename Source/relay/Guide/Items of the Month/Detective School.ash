RegisterTaskGenerationFunction("IOTMDetectiveSchoolGenerateTasks");
void IOTMDetectiveSchoolGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__iotms_usable[$item[detective school application]])
        return;
    
    //Should we always mention this in aftercore?
    //Hmm... I suppose.
    int cases_remaining = clampi(3 - get_property_int("_detectiveCasesCompleted"), 0, 3);
    if (cases_remaining > 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake(530, "__item noir fedora", "place.php?whichplace=town_wrong&action=townwrong_precinct", ChecklistSubentryMake("Solve " + pluraliseWordy(cases_remaining, "more case", "more cases"), "", "Gives cop dollars."), 5));
    }
    if ($items[plastic detective badge,bronze detective badge,silver detective badge,gold detective badge].available_amount() == 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake(531, "__item plastic detective badge", "place.php?whichplace=town_wrong&action=townwrong_precinct", ChecklistSubentryMake("Collect your Precinct badge", "", ""), 5));
        
    }
}

RegisterResourceGenerationFunction("IOTMDetectiveSchoolGenerateResource");
void IOTMDetectiveSchoolGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[$item[detective school application]])
        return;
    
    //FIXME mention how much more they need to upgrade to the next badge?
    if (__misc_state["in run"] && in_ronin())
    {
        int cop_dollars_have = $item[cop dollar].available_amount();
        if (cop_dollars_have > 0)
        {
            string [int] description;
            
            string [int] buyables;
            
            string [int] ml_types_can_eat_drink;
            if (__misc_state["can eat just about anything"])
                ml_types_can_eat_drink.listAppend("food");
            if (__misc_state["can drink just about anything"])
                ml_types_can_eat_drink.listAppend("drink");
            if (ml_types_can_eat_drink.count() > 0 && cop_dollars_have >= 4)
                buyables.listAppend(ml_types_can_eat_drink.listJoinComponents("/"));
            if (cop_dollars_have >= 10)
            {
                buyables.listAppend("a -combat potion (50 turns)");
            }
            if (buyables.count() > 0)
                description.listAppend("Buy " + buyables.listJoinComponents(", ", "or") + ".");
            resource_entries.listAppend(ChecklistEntryMake(532, "__item cop dollar", "shop.php?whichshop=detective", ChecklistSubentryMake(pluralise($item[cop dollar]), "", description), 7));
        }
    }
}
