
string [int] SEquipmentGenerateXiblaxianHoloWristPuterDescription()
{
    string [int] description;
    string [int][int] table;
    table.listAppend(listMake("Outdoor", "polymer"));
    table.listAppend(listMake("Indoor", "circuitry"));
    table.listAppend(listMake("Underground", "alloy"));
    table.listAppend(listMake("Underwater", "polymer"));
    //this is kind of a hack:
    int index_to_bold = -1;
    if (__last_adventure_location.environment == "outdoor")
        index_to_bold = 0;
    else if (__last_adventure_location.environment == "indoor")
        index_to_bold = 1;
    else if (__last_adventure_location.environment == "underground")
        index_to_bold = 2;
    if (__last_adventure_location.environment == "underwater")
        index_to_bold = 3;
    
    if (index_to_bold != -1)
    {
        foreach key, v in table[index_to_bold]
            table[index_to_bold][key] = HTMLGenerateSpanOfClass(v, "r_bold");
    }
    description.listAppend(HTMLGenerateSimpleTableLines(table));
    
    string [int] items_owned;
    foreach it in $items[Xiblaxian alloy,Xiblaxian circuitry,Xiblaxian polymer,Xiblaxian crystal]
    {
        if (it.available_amount() > 0)
            items_owned.listAppend(it.available_amount() + " " + it);
    }
    
    description.listAppend("Own " + items_owned.listJoinComponents(", ", "and") + ".");
    return description;
}

void SEquipmentGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($item[Xiblaxian holo-wrist-puter].equipped_amount() > 0)
    {
        int turns_left = XiblaxianHoloWristPuterTurnsUntilNextItem();
        if (turns_left == 1 || turns_left == 0)
        {
            string [int] description = SEquipmentGenerateXiblaxianHoloWristPuterDescription();
            task_entries.listAppend(ChecklistEntryMake("__item Xiblaxian holo-wrist-puter", "", ChecklistSubentryMake("Xiblaxian item next combat", "", description), -11));
        }
    }
}

void SEquipmentGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($item[Xiblaxian holo-wrist-puter].equipped_amount() > 0)
    {
        int turns_left = XiblaxianHoloWristPuterTurnsUntilNextItem();
        if (turns_left != -1 || true)
        {
            string [int] description = SEquipmentGenerateXiblaxianHoloWristPuterDescription();
            //description.listAppend("_holoWristDrops = " + get_property_int("_holoWristDrops"));
            //description.listAppend("_holoWristProgress = " + get_property_int("_holoWristProgress"));
            
            string header = turns_left + " combats to Xiblaxian item";
            if (turns_left <= 1)
                header = "Xiblaxian next turn";
            resource_entries.listAppend(ChecklistEntryMake("__item Xiblaxian holo-wrist-puter", "", ChecklistSubentryMake(header, "", description), 8));
        }
    }
}