RegisterResourceGenerationFunction("IOTMSnojoGenerateResource");
void IOTMSnojoGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!get_property_boolean("snojoAvailable") || in_bad_moon() || !lookupItem("X-32-F snowman crate").is_unrestricted())
        return;
    
    int fights_remaining = clampi(10 - get_property_int("_snojoFreeFights"), 0, 10);
    if (!mafiaIsPastRevision(16598))
        fights_remaining = 0;
    if (fights_remaining > 0)
    {
        string [int] description;
        
        string setting = get_property("snojoSetting");
        
        item reward_item = $item[none];
        string wins_property = "";
        string training_equipment_description;
        if (setting == "MUSCLE")
        {
            wins_property = "snojoMuscleWins";
            reward_item = lookupItem("ancient medicinal herbs");
            training_equipment_description = "+25 ML accessory";
        }
        else if (setting == "MOXIE")
        {
            wins_property = "snojoMoxieWins";
            reward_item = lookupItem("iced plum wine");
            training_equipment_description = "+25% item hat";
        }
        else if (setting == "MYSTICALITY")
        {
            wins_property = "snojoMysticalityWins";
            reward_item = lookupItem("ice rice");
            training_equipment_description = "+5 res accessory";
        }
        
        int wins = 0;
        if (wins_property != "")
            wins = get_property_int(wins_property);
        
        
        int [string] winnings;
        if (wins_property != "")
        {
            winnings["skill scroll"] = 50;
            if (training_equipment_description != "")
                winnings[training_equipment_description] = 11;
            if (reward_item != $item[none])
                winnings[reward_item.to_string()] = MAX(7, ceil(wins.to_float() / 7.0) * 7);
        }
        
        //Output in order of upcoming appearance:
        string [int] winnings_order;
        foreach winning in winnings
            winnings_order.listAppend(winning);
        sort winnings_order by winnings[value];
        
        string [int] various_winnings_upcoming;
        foreach key, winning in winnings_order
        {
            int timing = winnings[winning];
            if (wins > timing)
                continue;
            int turns_remaining = timing - wins;
            if (turns_remaining == 1)
                various_winnings_upcoming.listAppend(winning + " next turn");
            else
                various_winnings_upcoming.listAppend(winning + " in " + pluralise(turns_remaining, "turn", "turns"));
        }
        
        if (various_winnings_upcoming.count() > 0)
            description.listAppend(various_winnings_upcoming.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        
        if (wins >= 50 && setting != "TOURNAMENT")
        {
            string [int] switchables;
            if (get_property_int("snojoMuscleWins") < 50)
                switchables.listAppend("muscle");
            if (get_property_int("snojoMoxieWins") < 50)
                switchables.listAppend("moxie");
            if (get_property_int("snojoMysticalityWins") < 50)
                switchables.listAppend("mysticality");
            if (switchables.count() > 0)
                description.listAppend("Could switch to " + switchables.listJoinComponents(", ", "or") + " for skill scrolls.");
        }
        int importance = 6;
        if (__misc_state["in run"])
            importance = 2;
        resource_entries.listAppend(ChecklistEntryMake("__item snow suit", "place.php?whichplace=snojo", ChecklistSubentryMake(pluralise(fights_remaining, "free Snojo fight", "free Snojo fights"), "", description), importance));
    }
}