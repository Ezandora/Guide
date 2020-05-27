
RegisterTaskGenerationFunction("IOTMGarbageToteGenerateTasks");
void IOTMGarbageToteGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (lookupItem("January's Garbage Tote").available_amount() == 0) return;
	boolean [item] relevant_items;
	if (get_property_int("garbageTreeCharge") > 0)
		relevant_items[lookupItem("deceased crimbo tree")] = true;
    if (get_property_int("garbageShirtCharge") > 0 && __misc_state["Torso aware"])
        relevant_items[lookupItem("makeshift garbage shirt")] = true;
    if (get_property_int("garbageChampagneCharge") > 0)
        relevant_items[lookupItem("broken champagne bottle")] = true;
    relevant_items[lookupItem("tinsel tights")] = true;
    relevant_items[lookupItem("wad of used tape")] = true;
	if (relevant_items.available_amount() == 0) {
		string [int] description;
        if (my_level() < 13 && get_property_int("garbageShirtCharge") > 0 && __misc_state["Torso aware"]) {
            description.listAppend("Makeshift garbage shirt (double statgain for " + pluralise(get_property_int("garbageShirtCharge"), "more turn", "more turns") + ".)");
        }
        else if (my_level() < 13)
        	description.listAppend("Tinsel tights (+25 ML)");
        description.listAppend("Wad of used tape (+15% item, +30% meat)");
        if (get_property_int("garbageChampagneCharge") > 0)
        	description.listAppend("Broken champagne bottle (double +item for " + pluralise(get_property_int("garbageChampagneCharge"), "more turn", "more turns") + ".)");
        
        
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
	
    string [item] item_charge_property;
	string [item] item_effect_description;
    int [item] item_charge_default;
	
	if (__misc_state["Torso aware"]) {
		item_charge_property[lookupItem("makeshift garbage shirt")] = "garbageShirtCharge";
        item_effect_description[lookupItem("makeshift garbage shirt")] = "Doubles statgain";
        item_charge_default[lookupItem("makeshift garbage shirt")] = 37;
    }

    item_charge_property[lookupItem("broken champagne bottle")] = "garbageChampagneCharge";
    item_effect_description[lookupItem("broken champagne bottle")] = "Doubles +item";
    item_charge_default[lookupItem("broken champagne bottle")] = 11;

    item_charge_property[lookupItem("deceased crimbo tree")] = "garbageTreeCharge";
    item_effect_description[lookupItem("deceased crimbo tree")] = "Absorbs damage";
    item_charge_default[lookupItem("deceased crimbo tree")] = 1000;
	
	ChecklistEntry entry;
	entry.url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9690";
	entry.importance_level = 8;
	
    boolean outdatedGarbage = !get_property_boolean("_garbageItemChanged");

	foreach it, property_name in item_charge_property {
        int charge = get_property_int(property_name);
        boolean have = it.available_amount() > 0;
        if (!have && outdatedGarbage)
            charge = item_charge_default[it];

        if (!have && charge == 0) continue;
        if (!have && !(lookupItems("makeshift garbage shirt,broken champagne bottle") contains it)) continue;
        string title;
        string [int] description;
        string url = "inventory.php?which=2";
        if (charge > 0) {
            title = pluralise(charge, "charge", "charges") + " of " + it;
            description.listAppend(item_effect_description[it] + "." + (!have ? " Not active." : ""));
            if (have && outdatedGarbage)
                description.listAppend("Charges are from previous day. Will get " + item_charge_default[it] + " more when you interact with the Tote (you will lose those " + charge + ").");
        } else {
            title = HTMLGenerateSpanFont("No charges of " + it, "red");
            description.listAppend(outdatedGarbage ? "Interact with Tote to refill charges." : "Switch out for something else.");
            url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9690";
        }
        if (entry.image_lookup_name == "")
	        entry.image_lookup_name = "__item " + it;
		entry.subentries.listAppend(ChecklistSubentryMake(title, "", description));   
        //resource_entries.listAppend(ChecklistEntryMake("__item " + it, url, ChecklistSubentryMake(title, "", description), 8));
	}
	if (entry.subentries.count() > 0)
		resource_entries.listAppend(entry);
}
