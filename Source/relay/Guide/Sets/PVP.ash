void SPVPGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!hippy_stone_broken())
        return;
    if (pvp_attacks_left() > 0 && today_is_pvp_season_end())
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__effect Swordholder", "peevpee.php?place=fight", ChecklistSubentryMake("Run all of your fights", "", listMake("Season ends today.", "Make sure to get the seasonal item if you haven't, as well."))));
    }
}