RegisterResourceGenerationFunction("IOTMKGBriefcaseGenerateResource");
void IOTMKGBriefcaseGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[$item[kremlin's greatest briefcase]]) return;
    ChecklistEntry entry = ChecklistEntryMake(509);
    entry.image_lookup_name = "__item Kremlin's Greatest Briefcase";
    entry.importance_level = 5;
    entry.url = "place.php?whichplace=kgb";
    if (get_property_int("_kgbTranquilizerDartUses") < 3 && my_path_id_legacy() != PATH_POCKET_FAMILIARS)
    {
        string [int] description;
        description.listAppend("Free run/banishes for twenty turns.|Use the KGB tranquilizer dart skill in-combat.");
        if ($item[kremlin's greatest briefcase].equipped_amount() == 0)
        {
            description.listAppend("Equip the briefcase first.");
            //entry.url = "inventory.php?which=2";
        }
        resource_entries.listAppend(ChecklistEntryMake(510, "__item Kremlin's Greatest Briefcase", entry.url, ChecklistSubentryMake(pluralise(3 - get_property_int("_kgbTranquilizerDartUses"), "briefcase dart", "briefcase darts"), "", description)).ChecklistEntryTag("free banish"));
    }
    int clicks_remaining = clampi(22 - get_property_int("_kgbClicksUsed"), 0, 22);
    if (clicks_remaining > 0)
    {
        string [int] description;
        description.listAppend("All sorts of things. Buffs, martinis, cigars!");
        
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(clicks_remaining, "click", "clicks"), "", description));
    }
    if (entry.subentries.count() > 0)
        resource_entries.listAppend(entry);
}
