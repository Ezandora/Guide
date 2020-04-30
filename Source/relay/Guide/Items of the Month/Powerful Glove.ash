RegisterResourceGenerationFunction("IOTMPowerfulGloveGenerateResource");
void IOTMPowerfulGloveGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupItem("powerful glove").available_amount() == 0) return;
    if (!mafiaIsPastRevision(19725)) return;

    int charge_left = clampi(100 - get_property_int("_powerfulGloveBatteryPowerUsed"), 0, 100);

    string [int] description;
    if (charge_left > 0)
    {
        string url = "skillz.php";
        if (!lookupItem("Powerful Glove").equipped())
            url = "inventory.php?which=2";

        description.listAppend("10% charge: Replace a monster with another from the same zone.");
        description.listAppend("5% charge: -10% combat for 10 turns.");
        description.listAppend("5% charge: +200% stats for 20 turns.");

        resource_entries.listAppend(ChecklistEntryMake("__item powerful glove", url, ChecklistSubentryMake(charge_left + "% battery charge left", "", description), 1));
    }
}
