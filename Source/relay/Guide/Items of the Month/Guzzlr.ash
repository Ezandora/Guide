RegisterTaskGenerationFunction("IOTMGuzzlrQuestGenerateTask");
void IOTMGuzzlrQuestGenerateTask(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries) {
    if (get_property("questGuzzlr") == "unstarted") return;
    location questLocation = get_property("guzzlrQuestLocation").to_location();
    
    ChecklistSubentry gigEconomy() {
        string questTier = get_property("guzzlrQuestTier");
        item questBooze = get_property("guzzlrQuestBooze").to_item();
        boolean [item] questBoozePlatinum;
        foreach platinumDrink in $strings[Steamboat, Ghiaccio Colada, Nog-on-the-Cob, Sourfinger, Buttery Boy] {
            questBoozePlatinum [lookupItem(platinumDrink)] = true;
        }

        int guzzlrQuestNumber = min(8, get_property_int("_guzzlrDeliveries") + 1);

        int [int] [boolean] guzzlrDeliveryTurnRange; //int= value of guzzlrQuestNumber; boolean= using shoes
            guzzlrDeliveryTurnRange [1] [false] = 10; guzzlrDeliveryTurnRange [1] [true] = 7;
            guzzlrDeliveryTurnRange [2] [false] = 12; guzzlrDeliveryTurnRange [2] [true] = 8;
            guzzlrDeliveryTurnRange [3] [false] = 13; guzzlrDeliveryTurnRange [3] [true] = 9;
            guzzlrDeliveryTurnRange [4] [false] = 15; guzzlrDeliveryTurnRange [4] [true] = 10;
            guzzlrDeliveryTurnRange [5] [false] = 17; guzzlrDeliveryTurnRange [5] [true] = 12;
            guzzlrDeliveryTurnRange [6] [false] = 20; guzzlrDeliveryTurnRange [6] [true] = 15;
            guzzlrDeliveryTurnRange [7] [false] = 25; guzzlrDeliveryTurnRange [7] [true] = 17;
            guzzlrDeliveryTurnRange [8] [false] = 34; guzzlrDeliveryTurnRange [8] [true] = 25;

        boolean hasBooze;
        boolean hasBoozeSomewhere;

        if (questTier == "platinum") {
            hasBooze = questBoozePlatinum.item_amount() > 0;
            hasBoozeSomewhere = questBoozePlatinum.available_amount() + questBoozePlatinum.display_amount() > 0;
        } else {
            hasBooze = questBooze.item_amount() > 0;
            hasBoozeSomewhere = questBooze.available_amount() + questBoozePlatinum.display_amount() > 0;
        }

        boolean hasShoes = lookupItem("Guzzlr shoes").available_amount() > 0;
        boolean hasPants = lookupItem("Guzzlr pants").available_amount() > 0;

        boolean hasShoesEquipped = lookupItem("Guzzlr shoes").equipped_amount() > 0;
        boolean hasPantsEquipped = lookupItem("Guzzlr pants").equipped_amount() > 0;

        // Title
        string main_title = "Deliver booze";

        // Subtitle
        string subtitle = "free fights";
        initialiseLocationCombatRates(); //not done anywhere else in this script
        if (__location_combat_rates contains questLocation) {
            int rate = __location_combat_rates [questLocation];

            if (rate == -1) //if unknown
                subtitle += ", +combat";
            else if (rate != 100 && rate != 0)
                subtitle += ", +" + (100 - rate) + "% combat";
        } else //if unlisted
            subtitle += ", +combat";

        // Entries
        string [int] description;

        if (hasBooze) {
            description.listAppend("Deliver " + (questTier == "platinum" ? "platinum booze" : questBooze) + " by adventuring in " + questLocation + ".");
        } else {
            if (questTier == "platinum") {
                int [item] creatablePlatinumDrinks = questBoozePlatinum.creatable_items();
                description.listAppend("Obtain one of the following:| • Steamboat" + (creatablePlatinumDrinks contains lookupItem("Steamboat") ? " (can make with a miniature boiler)" : "") + " | • Ghiaccio Colada" + (creatablePlatinumDrinks contains lookupItem("Ghiaccio Colada") ? " (can make with a cold wad)" : "") + " | • Nog-on-the-Cob" + (creatablePlatinumDrinks contains lookupItem("Nog-on-the-Cob") ? " (can make with a robin's egg)" : "") + " | • Sourfinger" + (creatablePlatinumDrinks contains lookupItem("Sourfinger") ? " (can make with a mangled finger)" : "") + " | • Buttery Boy" + (creatablePlatinumDrinks contains lookupItem("Buttery Boy") ? " (can make with a Dish of Clarified Butter)" : ""));
                if (hasBoozeSomewhere) {
                    string [int] goLookThere;

                    if (get_property_boolean("autoSatisfyWithStorage") && questBoozePlatinum.storage_amount() > 0 && can_interact())
                        goLookThere.listAppend("in hagnk's storage");
                    if (get_property_boolean("autoSatisfyWithCloset") && questBoozePlatinum.closet_amount() > 0)
                        goLookThere.listAppend("in your closet");
                    if (get_property_boolean("autoSatisfyWithStash") && questBoozePlatinum.stash_amount() > 0)
                        goLookThere.listAppend("in your clan stash");
                    if (questBoozePlatinum.display_amount() > 0) // there's no relevant mafia property; is never taken into consideration
                        goLookThere.listAppend("in your display case");

                    description.listAppend("Go look " + (goLookThere.count() > 0 ? goLookThere.listJoinComponents(", ", "or") + "." : "...somewhere?"));
                }
            } else {
                description.listAppend("Obtain a " + questBooze + ".");
                if (hasBoozeSomewhere) {
                    string [int] goLookThere;

                    if (get_property_boolean("autoSatisfyWithStorage") && questBooze.storage_amount() > 0 && can_interact())
                        goLookThere.listAppend(questBooze.storage_amount() + " in hagnk's storage");
                    if (get_property_boolean("autoSatisfyWithCloset") && questBooze.closet_amount() > 0)
                        goLookThere.listAppend(questBooze.closet_amount() + " in your closet");
                    if (get_property_boolean("autoSatisfyWithStash") && questBooze.stash_amount() > 0)
                        goLookThere.listAppend(questBooze.stash_amount() + " in your clan stash");
                    if (questBooze.display_amount() > 0)
                        goLookThere.listAppend(questBooze.display_amount() + " in your display case");

                    description.listAppend("Have " + (goLookThere.count() > 0 ? goLookThere.listJoinComponents(", ", "and") + "." : "some... somewhere..?"));
                }

                if (questBooze.creatable_amount() > 0)
                    description.listAppend("Could craft one.");
            }
        }

        if (hasShoes) {
            description.listAppend("Takes " + guzzlrDeliveryTurnRange [guzzlrQuestNumber] [true] + " fights if you always wear the shoes.");
            description.listAppend("Takes " + guzzlrDeliveryTurnRange [guzzlrQuestNumber] [false] + " fights if you never wear the shoes.");
        } else
            description.listAppend("Takes " + guzzlrDeliveryTurnRange [guzzlrQuestNumber] [false] + " fights.");

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
        boolean hasShoes = lookupItem("Guzzlr shoes").available_amount() > 0;
        int guzzlrQuestNumber = min(8, get_property_int("_guzzlrDeliveries") + 1);

        string [int] guzzlrDeliveryTurnRange; //int= value of guzzlrQuestNumber
            guzzlrDeliveryTurnRange [1] = hasShoes ? "7-10" : "10";
            guzzlrDeliveryTurnRange [2] = hasShoes ? "8-12" : "12";
            guzzlrDeliveryTurnRange [3] = hasShoes ? "9-13" : "13";
            guzzlrDeliveryTurnRange [4] = hasShoes ? "10-15" : "15";
            guzzlrDeliveryTurnRange [5] = hasShoes ? "12-17" : "17";
            guzzlrDeliveryTurnRange [6] = hasShoes ? "15-20" : "20";
            guzzlrDeliveryTurnRange [7] = hasShoes ? "17-25" : "25";
            guzzlrDeliveryTurnRange [8] = hasShoes ? "25-34" : "34";

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
                description.listAppend("Will take " + guzzlrDeliveryTurnRange [guzzlrQuestNumber] + " fights.");
                if (canAbandonQuest) {
                    description.listAppend("Can abandon 1 more quest today.");
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
