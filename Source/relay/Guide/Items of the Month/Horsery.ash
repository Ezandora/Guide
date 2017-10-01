RegisterTaskGenerationFunction("IOTMHorseryGenerateTasks");
void IOTMHorseryGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__iotms_usable[lookupItem("Horsery contract")]) return;
    if (get_property("_horsery") == "" && my_meat() >= 500)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item magical pony: Spectrum Dash", "place.php?whichplace=town_right&action=town_horsery", ChecklistSubentryMake("Bring along a horse!", "", "Probably the dark horse.")));
        
    }
}
