RegisterTaskGenerationFunction("IOTMLilDoctorBagGenerateTasks");
void IOTMLilDoctorBagGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (lookupItem("Lil' Doctor&trade; bag").available_amount() == 0) return;
    //Quest:
    int doctor_bag_upgrades = get_property_int("doctorBagUpgrades");
    int doctor_bag_lights = get_property_int("doctorBagQuestLights");
    string doctor_bag_quest_state = get_property("questDoctorBag");

    if (doctor_bag_quest_state == "unstarted" && (doctor_bag_upgrades > 6 || __misc_state["in run"])) return;

    string title;
    string [int] description;
    string url;

    if (doctor_bag_quest_state != "unstarted") {
        location doctor_bag_quest_location = get_property_location("doctorBagQuestLocation");
        item doctor_bag_quest_item = get_property_item("doctorBagQuestItem");
        title = "Medic! Medic!!";
        url = doctor_bag_quest_location.getClickableURLForLocation();
        
        if (doctor_bag_quest_item.item_amount() == 0)
            description.listAppend("Acquire a " + (doctor_bag_quest_item != $item[none] ? doctor_bag_quest_item + "." : "something..?"));
        description.listAppend("Adventure in " + doctor_bag_quest_location + ".");

        description.listAppend("Will give " + (doctor_bag_upgrades < 7 ? "progress towards upgrading the bag and " : "") + "meat."); // There is no "n° of quests completed this ascension" property, so can't predict how much you'll get
    }

    if (doctor_bag_upgrades < 7) {
        if (title == "") {
            title = "Upgrade your Lil' doctor bag";
            description.listAppend("Adventure with your doctor bag equipped to get a delivery quest."); // no way to know if they "turned off" their bag
        }
        description.listAppend(pluralise(35 - doctor_bag_lights - doctor_bag_upgrades * 5, "quest", "quests") + " until bag is fully upgraded.");
    }
    
    optional_task_entries.listAppend(ChecklistEntryMake("__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(title, "", description), 9));
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
            url = "inventory.php?ftext=lil'+doctor";
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
        if (lookupItem("Lil' Doctor&trade; bag").equipped_amount() == 0) {
            description.listAppend(HTMLGenerateSpanFont("Equip the Lil'l Doctor™ bag first", "red"));
            url = "inventory.php?which=3";
        } else {
            description.listAppend("Free run/banish");
        }
        resource_entries.listAppend(ChecklistEntryMake("__item Lil' Doctor&trade; bag", url, ChecklistSubentryMake(pluralise(banishes_left, "reflex hammer", "reflex hammers"), "", description), 0).ChecklistEntryTagEntry("banish"));
    }
}
