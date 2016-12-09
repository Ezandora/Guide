import "relay/Guide/Support/Banishers.ash";

void SEventsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    return;
}

void SCrimbo2015GenerateResource(ChecklistEntry [int] resource_entries)
{
    string year_and_month = format_today_to_string("yyyyMM");
    if (year_and_month != "201512")
        return;
    if (mafiaIsPastRevision(16544) && !in_ronin())
    {
        int herb_uses_left = clampi(10 - get_property_int("_fragrantHerbsUsed"), 0, 10);
        if ($item[bundle of &quot;fragrant&quot; herbs].available_amount() > 0 && herb_uses_left > 0)
        {
            string [int] description;
            description.listAppend("Free run/banish three monsters at once.");
            monster [int] banished_monsters;
            foreach key, b in BanishesActive()
            {
                if (b.banish_source == "bundle of &quot;fragrant&quot; herbs")
                {
                    banished_monsters.listAppend(b.banished_monster);
                }
            }
            if (banished_monsters.count() > 0)
                description.listAppend("Have " + banished_monsters.listJoinComponents(", ", "and") + " banished.");
            resource_entries.listAppend(ChecklistEntryMake("__item bundle of &quot;fragrant&quot; herbs", "", ChecklistSubentryMake(pluralise(herb_uses_left, "fragrant herb banish", "fragrant herb banishes"), "", description), 3));
        }
        int stockpile_uses_left = clampi(10 - get_property_int("_nuclearStockpileUsed"), 0, 10);
        if ($item[nuclear stockpile].available_amount() > 0 && stockpile_uses_left > 0)
        {
            string [int] description;
            description.listAppend("Does not cost a turn.");
            resource_entries.listAppend(ChecklistEntryMake("__item nuclear stockpile", "", ChecklistSubentryMake(pluralise(stockpile_uses_left, "nuclear stockpile instakill", "nuclear stockpile instakills"), "", description), 3));
        }
    }
}

void SEventsGenerateResource(ChecklistEntry [int] resource_entries)
{
    SCrimbo2015GenerateResource(resource_entries);
}