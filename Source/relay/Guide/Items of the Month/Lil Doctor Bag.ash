RegisterGenerationFunction("IOTMLilDoctorBagGenerate");
void IOTMLilDoctorBagGenerate(ChecklistCollection checklists)
{
    if (!$item[Lil' Doctor&trade; bag].have()) return;
    //Quest:
    
    if (QuestState("questDoctorBag").in_progress)
    {
    	item required_item = get_property_item("doctorBagQuestItem");
    	location target_location = get_property_location("doctorBagQuestLocation");
     
     	string [int] description;
        description.listAppend("Adventure in " + target_location + ". Free runs/delay burning helps.");
        if (required_item.item_amount() == 0)
        	description.listAppend("Acquire a " + required_item + " first.");
     
     	description.listAppend("Reward is marginal.");
        checklists.add(C_AFTERCORE_TASKS, ChecklistEntryMake(554, "__item Lil' Doctor&trade; bag", target_location.getClickableURLForLocation(), ChecklistSubentryMake("Lil' Doctor quest", "", description), 11, locationToLocationMap(target_location)));   
    }
    
	//Otoscope: +200% item
    int otoscopes_left = clampi(3 - get_property_int("_otoscopeUsed"), 0, 3);
    if (otoscopes_left > 0 && __misc_state["in run"])
    {
        string url;
        string [int] description;
        description.listAppend("+200% item for one turn, cast in combat.");
        
        url = generateEquipmentLink($item[Lil' Doctor&trade; bag]);
        if ($item[Lil' Doctor&trade; bag].equipped_amount() == 0)
        {
            description.listAppend("Equip the Lil'l Doctor™ bag first.");
        }
        //if (snojo_skill_entry.image_lookup_name == "")
            //snojo_skill_entry.image_lookup_name = "__skill shattering punch";
        checklists.add(C_RESOURCES, ChecklistEntryMake(555, "__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(otoscopes_left, "otoscope", "otoscopes"), "", description), 8).ChecklistEntrySetSpecificImage("__skill otoscope"));
    }
	//Chest X-Ray: instakill
    int instakills_left = clampi(3 - get_property_int("_chestXRayUsed"), 0, 3);
    if (instakills_left > 0)
    {
    	string url;
        string [int] description;
        description.listAppend("Win a fight without taking a turn.");
        
        url = generateEquipmentLink($item[Lil' Doctor&trade; bag]);
        if ($item[Lil' Doctor&trade; bag].equipped_amount() == 0)
        {
        	description.listAppend("Equip the Lil'l Doctor™ bag first.");
        }
        //if (snojo_skill_entry.image_lookup_name == "")
            //snojo_skill_entry.image_lookup_name = "__skill shattering punch";
        checklists.add(C_RESOURCES, ChecklistEntryMake(556, "__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(instakills_left, "chest x-ray", "chest x-rays"), "", description), 0).ChecklistEntryTag("free instakill").ChecklistEntrySetSpecificImage("__skill chest x-ray"));
        
    }
	//Reflex Hammer: Banish
    int banishes_left = clampi(3 - get_property_int("_reflexHammerUsed"), 0, 3);
    if (banishes_left > 0)
    {
        string url;
        string [int] description;
        description.listAppend("Free run/banish.");
        Banish banish_entry = BanishByName("Reflex Hammer");
        int turns_left_of_banish = banish_entry.BanishTurnsLeft();
        if (turns_left_of_banish > 0)
        {
            //is this relevant? we don't describe this for pantsgiving
            description.listAppend("Currently used on " + banish_entry.banished_monster + " for " + pluralise(turns_left_of_banish, "more turn", "more turns") + ".");
        }
        url = generateEquipmentLink($item[Lil' Doctor&trade; bag]);
        if ($item[Lil' Doctor&trade; bag].equipped_amount() == 0)
        {
            description.listAppend("Equip the Lil'l Doctor™ bag first.");
        }
        checklists.add(C_RESOURCES, ChecklistEntryMake(557, "__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(banishes_left, "reflex hammer", "reflex hammers"), "", description), 0).ChecklistEntryTag("free banish").ChecklistEntrySetSpecificImage("__skill reflex hammer"));
    }
}
