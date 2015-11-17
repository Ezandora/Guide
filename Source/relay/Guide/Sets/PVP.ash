void SPVPGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!hippy_stone_broken())
        return;
    if (pvp_attacks_left() > 0)
    {
        string today = format_today_to_string("MMdd");
        boolean [string] season_end_dates;
        //season_end_dates["0228"] = true; //FIXME support this by calculating leap years.
        season_end_dates["0430"] = true;
        season_end_dates["0630"] = true;
        season_end_dates["0831"] = true;
        season_end_dates["1031"] = true;
        season_end_dates["1231"] = true;
        
        if (season_end_dates contains today)
        {
            optional_task_entries.listAppend(ChecklistEntryMake("__effect Swordholder", "peevpee.php?place=fight", ChecklistSubentryMake("Run all of your fights", "", listMake("Season ends today.", "Make sure to get the seasonal item if you haven't, as well."))));
        }
    }
}