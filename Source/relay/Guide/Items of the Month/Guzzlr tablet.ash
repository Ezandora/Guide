RegisterGenerationFunction("IOTMGuzzlrTabletGenerate");
void IOTMGuzzlrTabletGenerate(ChecklistCollection checklists)
{
	if (!$item[guzzlr tablet].have()) return;
	
	QuestState guzzlr_quest_state = QuestState("questGuzzlr"); 
	if (guzzlr_quest_state.in_progress)
	{
        location target_location = get_property_location("guzzlrQuestLocation");
        string target_item_string = get_property("guzzlrQuestBooze");
        item target_item = target_item_string.to_item();
        
    	if (target_item_string == "special personalized cocktail")
     		target_item = $item[Guzzlr cocktail set];
        
        string target_item_description = target_item;
        boolean have_target_item = target_item.item_amount() > 0;
        
        if (target_item == $item[Guzzlr cocktail set])
        {
        	boolean [item] potential_drinks = $items[Steamboat,Ghiaccio Colada,Nog-on-the-Cob,Sourfinger,Buttery Boy];
            have_target_item = false;
            foreach it in potential_drinks
            {
            	if (it.item_amount() > 0)
             	{
                	target_item = it;
                    target_item_description = target_item;
                    have_target_item = true;
                    break;
                }
            }
            if (!have_target_item)
            {
            	target_item_description = potential_drinks.listInvert().listJoinComponents(", ", "or");
            }
        }
        
        string [int] description;
        
        description.listAppend("Adventure in " + target_location + " to deliever a " + target_item + ".");
        if (target_item != $item[none] && !have_target_item)
        	description.listAppend(HTMLGenerateSpanFont("Acquire a " + target_item_description + " first.", "red"));
        
        
        boolean [item] all_relevant_items = $items[Guzzlr pants,Guzzlr shoes];
        
        boolean [item] items_to_equip;
        foreach it in all_relevant_items
        {
        	if (!it.equipped() && it.have())
         		items_to_equip[it] = true;   
        }
        
        if (items_to_equip.count() > 0)
        	description.listAppend(HTMLGenerateSpanFont("Equip " + items_to_equip.listInvert().listJoinComponents(", ", "and") + " first.", "red"));
        checklists.add(C_AFTERCORE_TASKS, ChecklistEntryMake("__item guzzlr tablet", target_location.getClickableURLForLocation(), ChecklistSubentryMake("Guzzlr quest", "", description), 8, locationToLocationMap(target_location)));
	}
	//I think "_guzzlrPlatinumDeliveries" will tell you how many deliveries you started today
	//did a platinum from the previous day, _guzzlrPlatinumDeliveries was zero, started a new one today, went up to one 
	if (!guzzlr_quest_state.started && get_property_int("_guzzlrPlatinumDeliveries") == 0 && get_property_int("guzzlrGoldDeliveries") >= 5)
	{
        checklists.add(C_OPTIONAL_TASKS, ChecklistEntryMake("__item guzzlr tablet", "inventory.php?tap=guzzlr", ChecklistSubentryMake("Start platinum guzzlr quest", "", "Daily collectable."), 8));
	}
}
