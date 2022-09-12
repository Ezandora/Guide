
//
RegisterGenerationFunction("IOTMPottedPowerPlantGenerate");
void IOTMPottedPowerPlantGenerate(ChecklistCollection checklists)
{
	//_pottedPowerPlant, shockingLickCharges
	
	if (lookupItem("potted power plant").have() && mafiaIsPastRevision(20657))
	{
        int plant_picks_remaining = 0;
		string [int] plant_pick_state = get_property("_pottedPowerPlant").split_string_alternate(",");
        foreach key, pick in plant_pick_state
        {
        	if (pick == "") continue;
            if (pick == "0") continue;
            if (is_integer(pick)) plant_picks_remaining += 1;
        }
        if (plant_pick_state.count() == 0)
        	plant_picks_remaining = 7; //guess
        if (plant_picks_remaining > 0)
        {
            checklists.add(C_RESOURCES, ChecklistEntryMake(519, "__item potted power plant", "inv_use.php?pwd=" + my_hash() + "&whichitem=10738", ChecklistSubentryMake(pluralise(plant_picks_remaining, "potted power plant pick", "potted power plant picks"), "", ""), 2)).ChecklistEntryTag("Potted Power Plant");
        }
	}
	if (in_ronin())
	{
        string [item] battery_descriptions = {
        	lookupItem("battery (AAA)"):"+50% spell damage, regen ~7MP/adv (30 turns), 30 MP",
        	lookupItem("battery (AA)"):"+50% spell damage, +50% init, regen ~7MP/adv (30 turns), 40 MP",
        	lookupItem("battery (D)"):"+50% spell damage, +50% init, +3 stats/fight, regen ~7MP/adv (30 turns), 50 MP",
        	lookupItem("battery (9-Volt)"):"1 freekill charge, +50% spell damage, +50% init, +3 stats/fight, regen ~7MP/adv (30 turns), 60 MP",
        	lookupItem("battery (lantern)"):"1 freekill charge, +100% item, +50% spell damage, +50% init, +3 stats/fight, regen ~7MP/adv (30 turns), 70 MP",
        	lookupItem("battery (car)"):"1 freekill charge, +100% item, +100% meat, +50% spell damage, +50% init, +3 stats/fight, regen ~7MP/adv (30 turns), 80 MP",
        };
        if (my_path_id_legacy() == PATH_ROBOT)
        {
        	battery_descriptions[lookupItem("battery (AAA)")] += ", 15 energy";
        	battery_descriptions[lookupItem("battery (AA)")] += ", 20 energy";
        	battery_descriptions[lookupItem("battery (D)")] += ", 25 energy";
        	battery_descriptions[lookupItem("battery (9-Volt)")] += ", 30 energy";
        	battery_descriptions[lookupItem("battery (lantern)")] += ", 35 energy";
        	battery_descriptions[lookupItem("battery (car)")] += ", 40 energy";
        }
        string [int] creatables;
        string url = "inventory.php?which=3&ftext=battery";
        foreach it, item_description in battery_descriptions
        {
        	if (it.have())
            {
                checklists.add(C_RESOURCES, ChecklistEntryMake(520, "__item " + it, url, ChecklistSubentryMake(pluralise(it), "", item_description), 2)).ChecklistEntryTag("Potted Power Plant");
            }
            int creatable_amount = it.creatable_amount();
            if (creatable_amount > 0)
            {
            	creatables.listAppend("<strong>" + pluralise(creatable_amount, it) + "</strong>: " + item_description);
            }
        }
        if (creatables.count() > 0)
        {
            checklists.add(C_RESOURCES, ChecklistEntryMake(521, "__item potted power plant", url, ChecklistSubentryMake("Creatable batteries", "", creatables), 2)).ChecklistEntryTag("Potted Power Plant");
        }
	}
	int shocking_lick_charges = get_property_int("shockingLickCharges");
	if (shocking_lick_charges > 0)
	{
        checklists.add(C_RESOURCES, ChecklistEntryMake(522, "__skill Shocking Lick", "", ChecklistSubentryMake(pluralise(shocking_lick_charges, "Shocking Lick", "Shocking Licks"), "", "Free instakill."), 1).ChecklistEntryTag("free instakill"));
	}
}
