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
	
	ChecklistSubentry getMushroomState() {
		int mushroomLevel = get_property_int("mushroomGardenCropLevel");
		
		// Title
		string main_title = "Upkeep your Mushroom";
		
		// Subtitle
		string subtitle = "";
		
		// Entries
		string [int] description;
		
		if (!get_property_boolean("_mushroomGardenVisited")) {
			description.listAppend("Mushroom is at tier " + mushroomLevel);
			description.listAppend("Will give:");
			description.listAppend((MIN(3, mushroomLevel)*3) + " filets");
			if (mushroomLevel > 3) {
				description.listAppend(MIN(2, mushroomLevel - 3) + " slab");
			} else {
				description.listAppend("+1 Slab at tier 4 & 5");
			}
			if (mushroomLevel > 10) {
				description.listAppend("A mushroom house");
				description.listAppend("No reason to wait any longer");
			} else {
				description.listAppend("House at tier 11");
			}
		}
		
		return ChecklistSubentryMake(main_title, subtitle, description);
	}

	if (!__iotms_usable[lookupItem("packet of mushroom spores")]) return;
	
    ChecklistEntry entry;
    entry.image_lookup_name = "__item Better Shrooms and Gardens catalog";
    entry.url = "campground.php";

    ChecklistSubentry piranhas = getFreeFights();
    if (piranhas.entries.count() > 0) {
        entry.subentries.listAppend(piranhas);
    }
	
    ChecklistSubentry shroom = getMushroomState();
    if (shroom.entries.count() > 0) {
        entry.subentries.listAppend(shroom);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}
