RegisterResourceGenerationFunction("IOTMBirdADayCalendar");
void IOTMBirdADayCalendar(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getBirdMods() {

        string birdMods = get_property("_birdOfTheDayMods");
        int birdsSought = get_property_int("_birdsSoughtToday");

        // Title
        string main_title = "Seek Bird";

        // Subtitle
        string subtitle = "10 Turn Buff";

        // Entries
        string [int] description;
        if (get_property_boolean("_canSeekBirds")) {
            string [int] modStrings = birdMods.split_string(", ");
            foreach index, modString in modStrings {
                string [int] modProperties = modString.split_string(": ");
                string modName = modProperties[0];
                string modValue = modProperties[1];

                string name = modName + ": ";
                switch(modName) {
                    case "Cold Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_cold");
                        break;  
                    case "Hot Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_hot");
                        break;              
                    case "Sleaze Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_sleaze");
                        break;
                    case "Spooky Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_spooky");
                        break;
                    case "Stench Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_stench");
                        break;
                }

                description.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + modValue);
            }
        } else {
            main_title = "Discover your daily Bird";
            subtitle = "";
            description.listAppend("Use your calendar to get a new skill for the day");
            if (have_effect($effect[Blessing of the Bird]) > 0)
                description.listAppend(HTMLGenerateSpanFont("Still have an old blessing", "red") + "|Using the calendar will replace the old buff's modifiers with the new ones.");
        }
        
        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    ChecklistSubentry getFavoriteBird() {

        string favoriteBirdMods = get_property("yourFavoriteBirdMods");
        boolean canSeekFavBird = have_skill($skill[Visit your Favorite Bird]);

        // Title
        string main_title = "Favorite";

        // Subtitle
        string subtitle = "20 Turn Buff";

        // Entries
        string [int] description;

        if (favoriteBirdMods != "" && canSeekFavBird && !get_property_boolean("_favoriteBirdVisited")) {
            string [int] modStrings = favoriteBirdMods.split_string(", ");
            foreach index, modString in modStrings {
                string [int] modProperties = modString.split_string(": ");
                string modName = modProperties[0];
                string modValue = modProperties[1];

                string name = modName + ": ";
                switch(modName) {
                    case "Cold Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_cold");
                        break;  
                    case "Hot Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_hot");
                        break;              
                    case "Sleaze Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_sleaze");
                        break;
                    case "Spooky Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_spooky");
                        break;
                    case "Stench Resistance":
                        name = HTMLGenerateSpanOfClass(modName + ": ", "r_element_stench");
                        break;
                }

                description.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + modValue);
            }
        }
        
        return ChecklistSubentryMake(main_title, subtitle, description);
    }


    if (!lookupItem("Bird-a-Day calendar").have()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__effect Blessing of the Bird";
    entry.url = get_property_boolean("_canSeekBirds") ? "skillz.php" : "inv_use.php?pwd=" + my_hash() + "&whichitem=10434";

    ChecklistSubentry birdMods = getBirdMods();
    if (birdMods.entries.count() > 0) {
        entry.subentries.listAppend(birdMods);
    }

    ChecklistSubentry favoriteBird = getFavoriteBird();
    if (favoriteBird.entries.count() > 0) {
        entry.subentries.listAppend(favoriteBird);
    }

    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}
