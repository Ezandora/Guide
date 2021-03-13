
void SugarGenerateSuggestions(string [int] suggestions)
{
    if (!__misc_state["in run"])
        return;
    if ($item[sugar shield].available_amount() == 0 && $item[snow suit].available_amount() == 0)
        suggestions.listAppend("Sugar shield: +10 familiar weight equip");
    if ($item[sugar chapeau].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["past tower monsters"])
        suggestions.listAppend("Sugar chapeau: +50% spell damage (tower killing)");
}

RegisterResourceGenerationFunction("IOTMSugarGenerateResource");
void IOTMSugarGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!$item[sugar sheet].is_unrestricted())
        return;
    item [int] sugar_crafted_items;
    for i from 4178 to 4183
    {
        sugar_crafted_items.listAppend(i.to_item());
    }
    ChecklistSubentry [int] subentries;
    
    string image_name = "";
    
    if ($item[sugar sheet].available_amount() > 0 && __misc_state["in run"] && in_ronin())
    {
        string [int] suggestions;
        SugarGenerateSuggestions(suggestions);
        subentries.listAppend(ChecklistSubentryMake(pluralise($item[sugar sheet]), "", suggestions));
        
        image_name = "sugar sheet";
    }
    foreach key in sugar_crafted_items
    {  
        item it = sugar_crafted_items[key];
        if (it.available_amount() == 0)
            continue;
        int counter = get_property_int("sugarCounter" + it.to_int());
        if (counter == 0 && (!__misc_state["in run"] || !in_ronin())) //in aftercore, probably not as relevant
            continue;
        int combats_left = 31 - counter;
        subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", pluralise(combats_left, "combat", "combats") + " left."));
        if (image_name.length() == 0)
            image_name = it;
    }
    if (subentries.count() > 0)
    {
        resource_entries.listAppend(ChecklistEntryMake(605, image_name, "", subentries, 10));
    }
}
