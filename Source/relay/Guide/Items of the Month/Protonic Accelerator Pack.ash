RegisterTaskGenerationFunction("IOTMProtonicAcceleratorPackGenerateTasks");
void IOTMProtonicAcceleratorPackGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Quest:
    if (QuestState("questPAGhost").in_progress || get_property("ghostLocation") != "")
    {
        int priority = 0;
        if (__misc_state["in run"])
            priority = -1;
        location ghost_location = get_property_location("ghostLocation");
        string title = "Defeat the ghost in " + ghost_location;
        string [int] description;
        string url = ghost_location.getClickableURLForLocation();
        description.listAppend("Won't cost a turn.");
        if (lookupItem("protonic accelerator pack").equipped_amount() > 0)
            description.listAppend("Cast \"shoot ghost\" three times, then \"trap ghost\".");
        item [int] items_to_equip;
        if (lookupItem("protonic accelerator pack").equipped_amount() == 0 && lookupItem("protonic accelerator pack").available_amount() > 0)
        {
            //Strictly speaking, they don't need the pack equipped to fight the monster, but they won't be able to trap it and get the item.
            url = "inventory.php?which=2";
            items_to_equip.listAppend(lookupItem("protonic accelerator pack"));
        }
        if (ghost_location == $location[inside the palindome] && $item[Talisman o' Namsilat].equipped_amount() == 0)
        {
            if ($item[Talisman o' Namsilat].available_amount() == 0)
            {
                priority = 10;
                description.listAppend("Need Talisman o' Namsilat first.");
            }
            else
            {
                url = "inventory.php?which=2";
                items_to_equip.listAppend($item[talisman o' namsilat]);
            }
        }
        if (items_to_equip.count() > 0)
            description.listAppend("Equip the " + items_to_equip.listJoinComponents(", ", "and") + " first.");
        if (ghost_location != $location[none])
            optional_task_entries.listAppend(ChecklistEntryMake("__item protonic accelerator pack", url, ChecklistSubentryMake(title, "", description), priority));
    }
}


RegisterResourceGenerationFunction("IOTMProtonicAcceleratorPackGenerateResource");
void IOTMProtonicAcceleratorPackGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupItem("protonic accelerator pack").available_amount() == 0)
        return;
    
    if (!get_property_boolean("_streamsCrossed") &&__misc_state["in run"] && mafiaIsPastRevision(17085))
    {
        string [int] description;
        string url = "showplayer.php?who=2807390"; //ProtonicBot is a real bot that will steal your turtle mechs at the first sign of defiance.
        description.listAppend("+20% stats for 10 turns.");
        if (lookupItem("protonic accelerator pack").equipped_amount() == 0)
        {
            url = "inventory.php?which=2";
            description.listAppend("Equip the protonic accelerator pack first.");
        }
        resource_entries.listAppend(ChecklistEntryMake("__item protonic accelerator pack", url, ChecklistSubentryMake("Stream crossing", "", description), 8));
    }
}