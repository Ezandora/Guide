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
        string main_title = pluralise(freeFightsLeft,"Pihrana Plant fight","Pihrana Plant fights");

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (freeFightsLeft > 0) {
            description.listAppend("Free fight.");
            if (my_path_id() == PATH_OF_THE_PLUMBER) {
                description.listAppend("Drops extra coins and mushrooms.");
            }
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }
	
	ChecklistSubentry getMushroomState() {
		int mushroomLevel = get_property_int("mushroomGardenCropLevel");
		int expectedFilets = MIN(3, mushroomLevel)*3;
		int expectedSlabs = clampi(mushroomLevel - 3, 0, 2);
		
		// Title
		string main_title = "Upkeep your mushroom";
		
		// Subtitle
		string subtitle = "One action per day";
		
		// Entries
		string [int] description;
		
		string [int] shroomYield;
        string [int] futureYield;
		if (!get_property_boolean("_mushroomGardenVisited")) {
			description.listAppend("Mushroom is at tier " + mushroomLevel);
			shroomYield.listAppend(expectedFilets + " filets");
			if (mushroomLevel > 3)
				shroomYield.listAppend( pluralise(expectedSlabs,"slab","slabs") );

            if (mushroomLevel < 2)
                futureYield.listAppend("+3 filets at tier 2");
            if (mushroomLevel < 3)
                futureYield.listAppend("+3 filets at tier 3");
            if (mushroomLevel < 4)
                futureYield.listAppend("+1 slab at tier 4");
            if (mushroomLevel < 5)
                futureYield.listAppend("+1 slab at tier 5");   

			if (mushroomLevel > 10)
				shroomYield.listAppend("A mushroom house");
			else
				futureYield.listAppend("+1 mushroom house at tier 11");
			
			description.listAppend("Harvesting now will give:" + HTMLGenerateIndentedText(shroomYield));
            description.listAppend( mushroomLevel > 10 ? HTMLGenerateSpanOfClass("No reason to fertilize any longer", "r_bold") : to_buffer("Otherwise, fertilize it, incrementing its size:" + HTMLGenerateIndentedText(futureYield)) );
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
		// Want this part to appear both in the garden's tile, and the free fights tile, so making a new entry
		resource_entries.listAppend(ChecklistEntryMake("__item Better Shrooms and Gardens catalog", "campground.php", piranhas).ChecklistEntryTagEntry("daily free fight"));
    }
	
    ChecklistSubentry shroom = getMushroomState();
    if (shroom.entries.count() > 0) {
        entry.subentries.listAppend(shroom);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}
