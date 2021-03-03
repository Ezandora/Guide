
RegisterResourceGenerationFunction("IOTMBarrelGodGenerateResource");
void IOTMBarrelGodGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[$item[shrine to the Barrel god]])
        return;
    
    
    if (!get_property_boolean("_barrelPrayer"))
    {
        string [int] description;
        string [int][int] gear;
        
        if (__misc_state["can equip just about any weapon"] && !get_property_boolean("prayedForProtection"))
            gear.listAppend(listMake("Protection", "+50 ML, +100 HP, +25% muscle offhand"));
        if (!get_property_boolean("prayedForGlamour"))
            gear.listAppend(listMake("Glamour", "+50% item, ~8 MP regen, +25% myst accessory"));
        if (!get_property_boolean("prayedForVigor"))
            gear.listAppend(listMake("Vigor", "+50% init, ~15 HP regen, +25% moxie pants"));
        
        if (gear.count() > 0)
            description.listAppend("Once/ascension gear:|*" + HTMLGenerateSimpleTableLines(gear));
        string buff_description;
        if (my_class() == $class[seal clubber])
            buff_description = "+150% weapon damage";
        else if (my_class() == $class[turtle tamer])
            buff_description = "ode-to-booze type for food";
        else if (my_class() == $class[pastamancer])
            buff_description = "+90% item";
        else if (my_class() == $class[sauceror])
            buff_description = "+150% spell damage";
        else if (my_class() == $class[disco bandit])
            buff_description = "+150% ranged damage";
        else if (my_class() == $class[accordion thief])
            buff_description = "ode-to-booze type / +45% booze drops";
        
        if (buff_description != "")
            description.listAppend(buff_description.capitaliseFirstLetter() + " buff for 50 turns." + ($item[map to the Biggest Barrel].available_amount() == 0 && (my_daycount() >= 7 || !in_ronin()) ? "|Might give the map to the Biggest Barrel." : ""));
        
        resource_entries.listAppend(ChecklistEntryMake("barrel god", "da.php?barrelshrine=1", ChecklistSubentryMake("Barrel worship", "", description), 8).ChecklistEntrySetCategory("equipment"));
    }
    
    if (in_ronin())
    {
        item [int] barrels_around;
        foreach it in $items[little firkin,normal barrel,big tun,weathered barrel,dusty barrel,disintegrating barrel,moist barrel,rotting barrel,mouldering barrel,barnacled barrel]
        {
            if (it.item_amount() > 0)
                barrels_around.listAppend(it);
        }
        if (barrels_around.count() > 0)
        {
            string [int] plurals;
            foreach key, it in barrels_around
            {
                plurals.listAppend(pluralise(it.item_amount(), it));
            }
            string url = "inv_use.php?pwd=" + my_hash() + "&whichitem=" + barrels_around[0].to_int() + "&choice=1";
            string [int] description;
            description.listAppend(plurals.listJoinComponents(", ", "and") + ".");
            resource_entries.listAppend(ChecklistEntryMake("__item " + barrels_around[0], url, ChecklistSubentryMake("Smashable barrels", "", description), 8));
        }
    }
}
RegisterGenerationFunction("IOTMBarrelGodGenerate");
void IOTMBarrelGodGenerate(ChecklistCollection checklists)
{
    //we could suggest they defeat the barrelmech if they have the map anyways... hmm
    if ($item[map to the Biggest Barrel].available_amount() > 0 && (!$item[chest barrel].haveAtLeastXOfItemEverywhere(1) || !$item[barrelhead].haveAtLeastXOfItemEverywhere(1) || !$item[bottoms of the barrel].haveAtLeastXOfItemEverywhere(1)))
    {
        string [int] description;
        description.listAppend("Use map to the Biggest Barrel.");
        description.listAppend("To defeat him, deal up to, but not over, 150 HP/round. Otherwise, he'll heal his HP.|You'll also want healing items.");
        if ($skill[belch the rainbow].have_skill())
            description.listAppend("Could run -250 ML and cast belch the rainbow over and over, if you've upgraded that.");
        if (!in_ronin())
        {
            string line = "Could throw chipotle wasabi cilantro aioli repeatedly.";
            if ($item[chipotle wasabi cilantro aioli].item_amount() < 22)
                line += "|Acquire 22 of them first, though.";
            description.listAppend(line);
        }
        description.listAppend("Can only be fought once a day, until defeated.");
        checklists.add(C_AFTERCORE_TASKS, ChecklistEntryMake("barrel god", "inventory.php?ftext=map+to+the+Biggest+Barrel", ChecklistSubentryMake("Defeat the Barrelmech", "", description), 8));
    }
}
