RegisterTaskGenerationFunction("IOTMGuzzlrGenerateTask");
void IOTMGuzzlrGenerateTask(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries) {
    boolean startedQuest = get_property("questGuzzlr") != "unstarted";
    location questLocation = get_property("guzzlrQuestLocation").to_location();
    
    ChecklistSubentry getGuzzling() {
        item questBooze = get_property("guzzlrQuestBooze").to_item();
        string questTier = get_property("guzzlrQuestTier");
        int platinumDeliveriesLeft = 1 - get_property_int("_guzzlrPlatinumDeliveries");
        int goldDeliveriesLeft = 3 - get_property_int("_guzzlrGoldDeliveries");

        boolean hasBooze = questBooze.available_amount() > 0;

        if (questTier == "platinum") {
            hasBooze = lookupItem("Steamboat").available_amount() > 0
                || lookupItem("Ghiaccio Colada").available_amount() > 0
                || lookupItem("Nog-on-the-Cob").available_amount() > 0
                || lookupItem("Sourfinger").available_amount() > 0
                || lookupItem("Buttery Boy").available_amount() > 0;
        }

        boolean hasShoes = lookupItem("Guzzlr shoes").available_amount() > 0;
        boolean hasPants = lookupItem("Guzzlr pants").available_amount() > 0;

        boolean hasShoesEquipped = lookupItem("Guzzlr shoes").equipped_amount() > 0;
        boolean hasPantsEquipped = lookupItem("Guzzlr pants").equipped_amount() > 0;

        // Title
        string main_title = "Deliver booze";

        // Subtitle
        string subtitle = "+combat";

        // Entries
        string [int] description;

        if (startedQuest) {
            if (hasBooze) {
                if (questTier == "platinum") {
                    description.listAppend("Deliver platinum booze by adventuring in " + questLocation + ".");
                } else {
                    description.listAppend("Deliver " + questBooze + " by adventuring in " + questLocation + ".");
                }
            } else {
                if (questTier == "platinum") {
                    description.listAppend("Obtain one of the following:" + HTMLGenerateIndentedText("| • Steamboat | • Ghiaccio Colada | • Nog-on-the-Cob | • Sourfinger | • Buttery Boy"));
                } else {
                    description.listAppend("Obtain a " + questBooze + ".");
                }
            }

            if (hasShoes && !hasShoesEquipped) {
                description.listAppend(HTMLGenerateSpanFont("Equip your Guzzlr shoes for quicker deliveries.", "red"));
            }

            if (hasPants && !hasPantsEquipped) {
                description.listAppend(HTMLGenerateSpanFont("Equip your Guzzlr pants for more Guzzlrbucks.", "red"));
            }
        } else {
            string chooseDeliveryMessage = "Start a delivery by choosing a client:" + HTMLGenerateIndentedText("| • Bronze");

            if (goldDeliveriesLeft > 0) {
                chooseDeliveryMessage += HTMLGenerateIndentedText("| • Gold " + HTMLGenerateSpanFont("(" + goldDeliveriesLeft + " available)", "grey")); 
            }

            if (platinumDeliveriesLeft > 0) {
                chooseDeliveryMessage += HTMLGenerateIndentedText("| • Platinum " + HTMLGenerateSpanFont("(" + platinumDeliveriesLeft + " available)", "grey")); 
            }
            description.listAppend(chooseDeliveryMessage);
        }

        if (!hasShoes) {
            description.listAppend(HTMLGenerateSpanFont("Could buy Guzzlr shoes for quicker deliveries.", "grey"));
        }

        if (!hasPants) {
            description.listAppend(HTMLGenerateSpanFont("Could buy Guzzlr pants for more Guzzlrbucks.", "grey"));
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupItem("Guzzlr tablet").have()) return;
    if (__misc_state["in run"]) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__item Guzzlr tablet";
    if (startedQuest) {
        entry.url = questLocation.getClickableURLForLocation();
    } else {
        entry.url = "inventory.php?tap=guzzlr";
    }

    ChecklistSubentry lectures = getGuzzling();
    if (lectures.entries.count() > 0) {
        entry.subentries.listAppend(lectures);
    }

    if (entry.subentries.count() > 0) {
        optional_task_entries.listAppend(entry);
    }
}
