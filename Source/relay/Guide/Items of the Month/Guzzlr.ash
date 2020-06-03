RegisterTaskGenerationFunction("IOTMGuzzlrQuestGenerateTask");
void IOTMGuzzlrQuestGenerateTask(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries) {
    if (get_property("questGuzzlr") == "unstarted") return;
    location questLocation = get_property("guzzlrQuestLocation").to_location();

    //todo: tell if the area accepts wanderers; tell how much more +combat would be needed to guarantee only combats; use _guzzlrDeliveries to tell the user how long the quest will take
    
    ChecklistSubentry gigEconomy() {
        item questBooze = get_property("guzzlrQuestBooze").to_item();
        string questTier = get_property("guzzlrQuestTier");

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

        if (hasBooze) {
            if (questTier == "platinum") {
                description.listAppend("Deliver platinum booze by adventuring in " + questLocation + ".");
            } else {
                description.listAppend("Deliver " + questBooze + " by adventuring in " + questLocation + ".");
            }
        } else {
            if (questTier == "platinum") {
                description.listAppend("Obtain one of the following:" + HTMLGenerateIndentedText("| • Steamboat | • Ghiaccio Colada | • Nog-on-the-Cob | • Sourfinger | • Buttery Boy")); //todo: strikethrough unobtainable booze? Tell how to get each?
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

        if (!hasShoes) {
            description.listAppend(HTMLGenerateSpanFont("Could buy Guzzlr shoes for quicker deliveries.", "grey"));
        }

        if (!hasPants) {
            description.listAppend(HTMLGenerateSpanFont("Could buy Guzzlr pants for more Guzzlrbucks.", "grey"));
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupItem("Guzzlr tablet").have()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__item Guzzlrbuck";
    entry.url = questLocation.getClickableURLForLocation();

    ChecklistSubentry delivery = gigEconomy();
    if (delivery.entries.count() > 0) {
        entry.subentries.listAppend(delivery);
    }

    if (entry.subentries.count() > 0) {
        optional_task_entries.listAppend(entry);
    }
}

RegisterTaskGenerationFunction("IOTMGuzzlrTabletGenerateTask");
void IOTMGuzzlrTabletGenerateTask(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries) {

    ChecklistSubentry getGuzzling() { // for either telling the player to accept a quest, or reminding them if they can abandon it
        boolean startedQuest = get_property("questGuzzlr") != "unstarted";
        boolean canAbandonQuest = !get_property_boolean("_guzzlrQuestAbandoned");
        string questTier = get_property("guzzlrQuestTier");
        int platinumDeliveriesLeft = 1 - get_property_int("_guzzlrPlatinumDeliveries");
        int goldDeliveriesLeft = 3 - get_property_int("_guzzlrGoldDeliveries");
        boolean canAcceptPlatinum = get_property_int("guzzlrGoldDeliveries") >= 5;
        boolean canAcceptGold = get_property_int("guzzlrBronzeDeliveries") >= 5;

        // Title
        string main_title;

        // Subtitle
        string subtitle;

        // Entries
        string [int] description;

        if (startedQuest && canAbandonQuest) {
            main_title = "Can abandon quest";
            description.listAppend("I mean... if you think you're not up to it...");
            if (questTier == "platinum") {
                description.listAppend("Do this to keep the Guzzlr cocktail set for yourself");
            }
        } else if (!startedQuest) {
            if (__misc_state["in run"] && platinumDeliveriesLeft > 0 && canAcceptPlatinum) {
                main_title = "Get your daily Guzzlr cocktail set";
                subtitle = "Accept a platinum quest";
                description.listAppend(canAbandonQuest ? "Then, abandon the quest." : "Will be stuck with this quest for the rest of the day.");
            } else if (!__misc_state["in run"]) {
                main_title = "Accept a booze delivery quest";
                string chooseDeliveryMessage = "Start a delivery by choosing a client:" + HTMLGenerateIndentedText("| • Bronze");

                if (goldDeliveriesLeft > 0 && canAcceptGold) {
                    chooseDeliveryMessage += HTMLGenerateIndentedText("| • Gold " + HTMLGenerateSpanFont("(" + goldDeliveriesLeft + " available)", "grey")); 
                }

                if (platinumDeliveriesLeft > 0 && canAcceptPlatinum) {
                    chooseDeliveryMessage += HTMLGenerateIndentedText("| • Platinum " + HTMLGenerateSpanFont("(" + platinumDeliveriesLeft + " available)", "grey") + (canAbandonQuest ? " (Abandon for free cocktail set?)" : ""));
                }
                description.listAppend(chooseDeliveryMessage);
                if (canAbandonQuest) {
                    description.listAppend("Can abandon 1 quest today.");
                }
            }
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }


    if (!lookupItem("Guzzlr tablet").have()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__item Guzzlr tablet";
    entry.url = "inventory.php?tap=guzzlr";

    ChecklistSubentry guzzls = getGuzzling();
    if (guzzls.entries.count() > 0) {
        entry.subentries.listAppend(guzzls);
    }

    if (entry.subentries.count() > 0) {
        optional_task_entries.listAppend(entry);
    }
}
//todo: a separate tile to suggest how to use a spare cocktail set, when in run?
