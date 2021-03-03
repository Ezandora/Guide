
RegisterResourceGenerationFunction("IOTMClanFloundryGenerateResource");
void IOTMClanFloundryGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__misc_state["VIP available"] || !$item[Clan Floundry].is_unrestricted())
        return;
    if (!__misc_state["in run"])
        return;
    if (my_path_id() == PATH_G_LOVER)
    	return;
    
    //if (get_property_boolean("_floundryFabricated"))
        //return;
    foreach it in $items[bass clarinet,fish hatchet,carpe,codpiece,troutsers,tunac]
    {
        if (it.available_amount() > 0)
            return;
        if (it == $item[none])
            return;
    }
    
    string [int] description;
    
    string [int][int] equipment;
    if (__misc_state["can equip just about any weapon"])
    {
        //Bass clarinet: -10% combat, 1h ranged weapon, +100% moxie, -3 MP skill cost, +50 ranged damage, 10 white pixels
        string line = "-10% combat, +100% moxie, -3 MP skill cost, +50 ranged damage";
        if (!__quest_state["Level 13"].state_boolean["digital key used"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
            line += ", 10 white pixels";
        equipment.listAppend(listMake("Bass clarinet", "ranged weapon", line));
        //Fish hatchet: -10% combat, 1h axe, +100% muscle, +5 familiar weight, +50 weapon damage, +5 bridge progress
        line = "-10% combat, +100% muscle, +5 familiar weight, +50 weapon damage";
        if (!__quest_state["Level 9"].state_boolean["bridge complete"])
            line += ", +5 bridge progress";
        equipment.listAppend(listMake("Fish hatchet", "weapon", line));
    }
    //Codpiece: acc, -?% combat, +100% myst, +100 max MP, +50 spell damage, 8 bubblin' crudes
    equipment.listAppend(listMake("Codpiece", "acc", "-10% combat, +100% myst, +100 max MP, +50 spell damage" + (can_interact() ? "" : ", 8 bubblin' crudes")));
    //Carpe: back, +combat, +50% myst, regen ~8 MP, +50% meat
    equipment.listAppend(listMake("Carpe", "back", "+combat, +50% meat, +50% myst, regen ~8 MP"));
    //Tunac tunac tun: +combat, shirt, +50% muscle, +25 ML, +25% item
    if (__misc_state["Torso aware"])
    {
        equipment.listAppend(listMake("Tunac", "shirt", "+combat, +25 ML, +25% item, +50% muscle"));
    }
    //Troutsers: pants, +50% moxie, +50% pickpocket, +5 all res, +11 prismatic damage
    equipment.listAppend(listMake("Troutsers", " pants", "+50% moxie, +50% pickpocket, +5 all res, +11 prismatic damage"));
    description.listAppend(HTMLGenerateSimpleTableLines(equipment));
    
    
    resource_entries.listAppend(ChecklistEntryMake("__item fishy fish", "clan_viplounge.php?action=floundry", ChecklistSubentryMake("Rentable floundry equipment", "", description), 8));
}
