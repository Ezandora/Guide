RegisterResourceGenerationFunction("IOTMPowerfulGloveGenerateResource");
void IOTMPowerfulGloveGenerateResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getCharge() {
        int charge = get_property_int("_powerfulGloveBatteryPowerUsed");
        int chargeLeft = 100 - charge;

        // Title
        string main_title = chargeLeft + "% battery charge";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (chargeLeft > 0) {
            description.listAppend(HTMLGenerateSpanOfClass("Invisible Avatar (5% charge):", "r_bold") + " -10% combat.");
            description.listAppend(HTMLGenerateSpanOfClass("Triple Size (5% charge):", "r_bold") + " +200% all attributes.");
            if (chargeLeft > 5) {
                description.listAppend(HTMLGenerateSpanOfClass("Replace Enemy (10% charge):", "r_bold") + " Swap monster.");
            }
            description.listAppend(HTMLGenerateSpanOfClass("Shrink Enemy (5% charge):", "r_bold") + " Delevel.");
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
	if (!__misc_state["in run"]) return;
	
	if ((!__quest_state["Level 13"].state_boolean["digital key used"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
		|| myPathId() == PATH_OF_THE_PLUMBER) {
			ChecklistSubentry getExtraPixels() {
				// Title
				string main_title = "Get extra pixels";
				if (myPathId() == PATH_OF_THE_PLUMBER) {
					main_title = main_title + " and coins";
				}

				// Subtitle
				string subtitle = "";

				// Entries
				string [int] description;
				if (!have_equipped($item[Powerful Glove])) {
					description.listAppend("Equip Powerful Glove");
				}

				return ChecklistSubentryMake(main_title, subtitle, description);
			}

			if (!lookupItem("Powerful Glove").have()) return;
			
			ChecklistEntry entry;
			entry.image_lookup_name = "__item white pixel";
			entry.url = "/place.php?whichplace=forestvillage&action=fv_mystic";

			if (myPathId() == PATH_OF_THE_PLUMBER) {
				entry.importance_level = -10;
			}

			ChecklistSubentry extraPixels = getExtraPixels();
			if (extraPixels.entries.count() > 0) {
				entry.subentries.listAppend(extraPixels);
			}
			
			if (entry.subentries.count() > 0) {
				optional_task_entries.listAppend(entry);
			}
		}
}
