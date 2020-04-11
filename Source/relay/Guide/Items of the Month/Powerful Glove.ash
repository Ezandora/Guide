RegisterResourceGenerationFunction("IOTMPowerfulGloveGenerateResource");
void IOTMPowerfulGloveGenerateResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getCharge() {
        int charge = get_property_int("_powerfulGloveBatteryPowerUsed");
        int chargeLeft = 100 - charge;

        // Title
        string main_title = chargeLeft + "% Charge";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (chargeLeft > 0) {
            description.listAppend(HTMLGenerateSpanOfClass("Invisible Avatar:", "r_bold") + " -10% Combat");
            description.listAppend(HTMLGenerateSpanOfClass("Triple Size:", "r_bold") + " +200% all attributes");
            if (chargeLeft > 5) {
                description.listAppend(HTMLGenerateSpanOfClass("Wednesday:", "r_bold") + " Swap Monster");
            }
            description.listAppend(HTMLGenerateSpanOfClass("Thursday:", "r_bold") + " Delevel");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupItem("Powerful Glove").have()) return;
	
    ChecklistEntry entry;
    entry.image_lookup_name = "__item Powerful Glove";
    entry.url = "skillz.php";

    ChecklistSubentry charge = getCharge();
    if (charge.entries.count() > 0) {
        entry.subentries.listAppend(charge);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}

RegisterTaskGenerationFunction("IOTMPowerfulGloveTask");
void IOTMPowerfulGloveTask(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    ChecklistSubentry getExtraCoins() {
        // Title
        string main_title = "Get extra coins";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        print(my_path_id());
        if (my_path_id() == PATH_OF_THE_PLUMBER && !have_equipped($item[Powerful Glove])) {
            description.listAppend("Equip Powerful Glove");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupItem("Powerful Glove").have()) return;
	
    ChecklistEntry entry;
    entry.image_lookup_name = "__item coin";
    entry.url = "skillz.php";
    entry.importance_level = -10;

    ChecklistSubentry extraCoins = getExtraCoins();
    if (extraCoins.entries.count() > 0) {
        entry.subentries.listAppend(extraCoins);
    }
    
    if (entry.subentries.count() > 0) {
        optional_task_entries.listAppend(entry);
    }
}