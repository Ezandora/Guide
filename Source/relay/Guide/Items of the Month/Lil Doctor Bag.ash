RegisterTaskGenerationFunction("IOTMLilDoctorBagGenerateTasks");
void IOTMLilDoctorBagGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (lookupItem("Lil' Doctor&trade; bag").available_amount() == 0) return;
    //Quest:
    
}

RegisterResourceGenerationFunction("IOTMLilDoctorBagGenerateResource");
void IOTMLilDoctorBagGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (lookupItem("Lil' Doctor&trade; bag").available_amount() == 0) return;
	//Otoscope: +200% item
    int otoscopes_left = clampi(3 - get_property_int("_otoscopeUsed"), 0, 3);
    if (otoscopes_left > 0 && __misc_state["in run"])
    {
        string url;
        string [int] description;
        description.listAppend("+200% item for one turn, cast in combat.");
        
        if (lookupItem("Lil' Doctor&trade; bag").equipped_amount() == 0)
        {
            description.listAppend("Equip the Lil'l Doctor™ bag first.");
            url = "inventory.php?which=3";
        }
        //if (snojo_skill_entry.image_lookup_name == "")
            //snojo_skill_entry.image_lookup_name = "__skill shattering punch";
        resource_entries.listAppend(ChecklistEntryMake("__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(otoscopes_left, "otoscope", "otoscopes"), "", description), 8));
    }
	//Chest X-Ray: instakill
    int instakills_left = clampi(3 - get_property_int("_chestXRayUsed"), 0, 3);
    if (instakills_left > 0)
    {
    	string url;
        string [int] description;
        description.listAppend("Win a fight without taking a turn.");
        
        if (lookupItem("Lil' Doctor&trade; bag").equipped_amount() == 0)
        {
        	description.listAppend("Equip the Lil'l Doctor™ bag first.");
            url = "inventory.php?which=3";
        }
        //if (snojo_skill_entry.image_lookup_name == "")
            //snojo_skill_entry.image_lookup_name = "__skill shattering punch";
        resource_entries.listAppend(ChecklistEntryMake("__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(instakills_left, "chest x-ray", "chest x-rays"), "", description), 0).ChecklistEntryTagEntry("free instakill"));
        
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
        if (lookupItem("Lil' Doctor&trade; bag").equipped_amount() == 0)
        {
            description.listAppend("Equip the Lil'l Doctor™ bag first.");
            url = "inventory.php?which=3";
        }
        resource_entries.listAppend(ChecklistEntryMake("__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(banishes_left, "reflex hammer", "reflex hammers"), "", description), 0).ChecklistEntryTagEntry("banish"));
    }
}
