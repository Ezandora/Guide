
RegisterTaskGenerationFunction("IOTMGarbageToteGenerateTasks");
void IOTMGarbageToteGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (lookupItem("January's Garbage Tote").available_amount() == 0) return;
	boolean [item] relevant_items;
	if (get_property_int("_garbageTreeCharge") > 0)
		relevant_items[lookupItem("deceased crimbo tree")] = true;
    if (get_property_int("_garbageShirtCharge") > 0)
        relevant_items[lookupItem("makeshift garbage shirt")] = true;
    if (get_property_int("_garbageChampagneCharge") > 0)
        relevant_items[lookupItem("broken champagne bottle")] = true;
    relevant_items[lookupItem("tinsel tights")] = true;
    relevant_items[lookupItem("wad of used tape")] = true;
	if (relevant_items.available_amount() == 0)
	{
		string [int] description;
        if (my_level() < 13 && get_property_int("_garbageShirtCharge") > 0)
        {
            description.listAppend("Makeshift garbage shirt (double statgain for " + pluralise(get_property_int("_garbageShirtCharge"), "more turn", "more turns") + ".)");
        }
        else if (my_level() < 13)
        	description.listAppend("Tinsel tights (+25 ML)");
        description.listAppend("Wad of used tape (+15% item, +30% meat)");
        if (get_property_int("_garbageChampagneCharge") > 0)
        	description.listAppend("Broken champagne bottle (double +item for " + pluralise(get_property_int("_garbageChampagneCharge"), "more turn", "more turns") + ".)");
        
        
        optional_task_entries.listAppend(ChecklistEntryMake("__item January's Garbage Tote", "inv_use.php?pwd=" + my_hash() + "&whichitem=9690", ChecklistSubentryMake("Collect a garbage tote item", "", description), 1));
	}
}


RegisterResourceGenerationFunction("IOTMGarbageToteGenerateResource");
void IOTMGarbageToteGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupItem("January's Garbage Tote").available_amount() == 0) return;
	//_garbageShirtCharge from 37 to 0
	//_garbageChampagneCharge from 11 to 0
	//_garbageTreeCharge from 1000 to 0
	
	string [item] item_effect_description;
	string [item] item_charge_property;
	
	item_charge_property[lookupItem("makeshift garbage shirt")] = "_garbageShirtCharge";
    item_charge_property[lookupItem("broken champagne bottle")] = "_garbageChampagneCharge";
    item_charge_property[lookupItem("deceased crimbo tree")] = "_garbageTreeCharge";
    
    
    item_effect_description[lookupItem("makeshift garbage shirt")] = "Doubles statgain";
    item_effect_description[lookupItem("broken champagne bottle")] = "Doubles +item";
    item_effect_description[lookupItem("deceased crimbo tree")] = "Absorbs damage";
	
	foreach it, property_name in item_charge_property
	{
		if (it.available_amount() == 0) continue;
        int charge = get_property_int(property_name);
        
        string title;
        string [int] description;
        string url = "inventory.php?which=2";
        if (charge > 0)
        {
            title = pluralise(charge, "charge", "charges") + " of " + it;
            description.listAppend(item_effect_description[it] + ".");
        }
        else
        {
        	title = HTMLGenerateSpanFont("No charges of " + it, "red");
            description.listAppend("Switch out for something else.");
            url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9690";
        }
        resource_entries.listAppend(ChecklistEntryMake("__item " + it, url, ChecklistSubentryMake(title, "", description), 8));
	}
}
