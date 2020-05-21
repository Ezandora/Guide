RegisterResourceGenerationFunction("IOTMBetterShroomsAndGardensGenerateResource");
void IOTMBetterShroomsAndGardensGenerateResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getFreeFights() {
        int freeFightsUsed = get_property_int("_mushroomGardenFights");
        int totalFreeFights = 1;

        if (my_path_id() == PATH_OF_THE_PLUMBER) {
            totalFreeFights = 5;
        }
        int freeFightsLeft = totalFreeFights - freeFightsUsed;

        // Title
        string main_title = freeFightsLeft + " free fight";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (freeFightsLeft > 0) {
            description.listAppend("Fight a piranha plant");
            if (my_path_id() == PATH_OF_THE_PLUMBER) {
                description.listAppend("Drops extra coins and mushrooms");
            }
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!__iotms_usable[lookupItem("packet of mushroom spores")]) return;
	
    ChecklistEntry entry;
    entry.image_lookup_name = "__item Better Shrooms and Gardens catalog";
    entry.url = "campground.php";

    ChecklistSubentry pills = getFreeFights();
    if (pills.entries.count() > 0) {
        entry.subentries.listAppend(pills);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}