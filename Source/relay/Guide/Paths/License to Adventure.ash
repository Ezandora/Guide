RegisterTaskGenerationFunction("PathLicenseToAdventureGenerateTasks");
void PathLicenseToAdventureGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_path_id() != PATH_LICENSE_TO_ADVENTURE)
        return;
    if (lookupItem("Victor's Spoils").available_amount() > 0)
    {
        task_entries.listAppend(ChecklistEntryMake("__item victor's spoils", "inventory.php?which=3", ChecklistSubentryMake("Use Victor's Spoils", "", "Gives eleven adventures."), 3));
    }
}
