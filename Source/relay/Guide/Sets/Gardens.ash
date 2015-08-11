void generateGardenEntry(ChecklistEntry [int] resource_entries, boolean [item] garden_source_items, boolean [item] garden_creatable_items)
{
    ChecklistSubentry [int] subentries;
    string image_name = "";
    foreach it in garden_source_items
    {
        if (it.available_amount() == 0) continue;
        if (image_name.length() == 0)
            image_name = "__item " + it;
        subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", ""));
    }
    if (subentries.count() > 0)
    {
        ChecklistSubentry subentry = subentries[subentries.count() - 1]; //hacky
        
        
        int [item] creatable_items = garden_creatable_items.creatable_items();
        string [int] output_list;
        foreach it in creatable_items
        {
            int amount = creatable_items[it];
            
            if (it.to_slot() != $slot[none] && it.available_amount() > 0) //already have one
                continue;
            output_list.listAppend(pluralise(amount, it));
        }
        if (output_list.count() > 0)
        {
            subentry.entries.listAppend("Can create " + output_list.listJoinComponents(", ", "or") + ".");
        }
        resource_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 8));
    }
}



void SGardensGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!__misc_state["In run"])
        return;

    //Garden items:
    if (true)
    {
        boolean [item] garden_creatable_items;
        garden_creatable_items[$item[pumpkin juice]] = true;
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[pumpkin pie]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[pumpkin beer]] = true;
        if (__misc_state_string["yellow ray source"] == 4766.to_item().to_string())
            garden_creatable_items[4766.to_item()] = true;
        
        generateGardenEntry(resource_entries, $items[pumpkin], garden_creatable_items);
    }
    if (true)
    {
        boolean [item] garden_creatable_items;
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[peppermint patty]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[peppermint twist]] = true;
        if (__misc_state["free runs usable"])
            garden_creatable_items[$item[peppermint parasol]] = true;
        garden_creatable_items[$item[peppermint crook]] = true;
        generateGardenEntry(resource_entries, $items[peppermint sprout], garden_creatable_items);
    }
    if (true)
    {
        boolean [item] garden_creatable_items;
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[skeleton quiche]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[crystal skeleton vodka]] = true;
        if (!__misc_state["mysterious island available"])
            garden_creatable_items[$item[skeletal skiff]] = true;
        if (hippy_stone_broken())
            garden_creatable_items[$item[auxiliary backbone]] = true;
        generateGardenEntry(resource_entries, $items[skeleton], garden_creatable_items);
    }
    if (true)
    {
        generateGardenEntry(resource_entries, $items[handful of barley,cluster of hops,fancy beer bottle,fancy beer label], $items[can of Br&uuml;talbr&auml;u,can of Drooling Monk,can of Impetuous Scofflaw,bottle of old pugilist,bottle of professor beer,bottle of rapier witbier,artisanal homebrew gift package]);
    }
    if (true)
    {
        boolean [item] garden_creatable_items;
        
        foreach it in $items[snow cleats,snow crab,unfinished ice sculpture,snow mobile,ice bucket,bod-ice,snow belt,ice house,ice nine]
            garden_creatable_items[it] = true;
        
        if (!__quest_state["Level 9"].state_boolean["bridge complete"])
            garden_creatable_items[$item[snow boards]] = true;
        
        if (!__quest_state["Level 4"].finished)
            garden_creatable_items[$item[snow shovel]] = true;
        
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[snow crab]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[Ice Island Long Tea]] = true;
        if (hippy_stone_broken())
            garden_creatable_items[$item[ice nine]] = true;
        
        
        generateGardenEntry(resource_entries, $items[snow berries, ice harvest], garden_creatable_items);
    }
}