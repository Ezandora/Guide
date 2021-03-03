
RegisterGenerationFunction("IOTMGarbageToteGenerate");
void IOTMGarbageToteGenerate(ChecklistCollection checklists)
{
	if (!$item[January's Garbage Tote].have()) return;
	boolean [item] relevant_items;
	if (get_property_int("garbageTreeCharge") > 0)
		relevant_items[$item[deceased crimbo tree]] = true;
    if (get_property_int("garbageShirtCharge") > 0 && __misc_state["Torso aware"])
        relevant_items[$item[makeshift garbage shirt]] = true;
    if (get_property_int("garbageChampagneCharge") > 0)
        relevant_items[$item[broken champagne bottle]] = true;
    relevant_items[$item[tinsel tights]] = true;
    relevant_items[$item[wad of used tape]] = true;
	if (relevant_items.available_amount() == 0)
	{
		string [int] description;
        if (my_level() < 13 && get_property_int("garbageShirtCharge") > 0 && __misc_state["Torso aware"])
        {
            description.listAppend("Makeshift garbage shirt (double statgain for " + pluralise(get_property_int("garbageShirtCharge"), "more turn", "more turns") + ".)");
        }
        else if (my_level() < 13)
        	description.listAppend("Tinsel tights (+25 ML)");
        description.listAppend("Wad of used tape (+15% item, +30% meat)");
        if (get_property_int("garbageChampagneCharge") > 0)
        	description.listAppend("Broken champagne bottle (double +item for " + pluralise(get_property_int("garbageChampagneCharge"), "more turn", "more turns") + ".)");
        
        
        checklists.add(C_OPTIONAL_TASKS, ChecklistEntryMake("__item January's Garbage Tote", "inv_use.php?pwd=" + my_hash() + "&whichitem=9690", ChecklistSubentryMake("Collect a garbage tote item", "", description), 1));
	}
	
	
	//resources:
	
	string [item] item_effect_description;
	string [item] item_charge_property;
	
	if (__misc_state["Torso aware"])
		item_charge_property[$item[makeshift garbage shirt]] = "garbageShirtCharge";
    item_charge_property[$item[broken champagne bottle]] = "garbageChampagneCharge";
    item_charge_property[$item[deceased crimbo tree]] = "garbageTreeCharge";
    
    
    if (__misc_state["Torso aware"])
	    item_effect_description[$item[makeshift garbage shirt]] = "Doubles statgain";
    item_effect_description[$item[broken champagne bottle]] = "Doubles +item";
    item_effect_description[$item[deceased crimbo tree]] = "Absorbs damage";
	
	foreach it, property_name in item_charge_property
	{
        int charge = get_property_int(property_name);
        boolean have = it.available_amount() > 0;
        if (!have && charge == 0) continue;
        if (!have && !($items[makeshift garbage shirt,broken champagne bottle] contains it)) continue;
        string title;
        string [int] description;
        string url = generateEquipmentLink(it);
        if (charge > 0)
        {
            title = pluralise(charge, "charge", "charges") + " of " + it;
            description.listAppend(item_effect_description[it] + "." + (!have ? " Not active." : ""));
        }
        else
        {
        	title = HTMLGenerateSpanFont("No charges of " + it, "red");
            description.listAppend("Switch out for something else.");
            url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9690";
        }   
        checklists.add(C_RESOURCES, ChecklistEntryMake("__item " + it, url, ChecklistSubentryMake(title, "", description), 8).ChecklistEntryTag("garbage tote"));
	}
}
