RegisterTaskGenerationFunction("IOTMKramcoSausageOMaticGenerateTasks");
void IOTMKramcoSausageOMaticGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!$item[Kramco Sausage-o-Matic&trade;].have()) return;
    if (!__misc_state["can equip just about any off-hand"]) return;
    
    if (!__misc_state["in run"]) return;
    //If goblin is up, display reminder:
    KramcoSausageFightInformation fight_information = KramcoCalculateSausageFightInformation();
    if (fight_information.turns_to_next_guaranteed_fight == 0 && my_path_id() != PATH_LIVE_ASCEND_REPEAT && __misc_state["in run"])
    {
        
        string url = "";
        string [int] description;
        string title = "Fight sausage goblin ";
        if ($item[Kramco Sausage-o-Matic&trade;].equipped_amount() == 0)
        {
            description.listAppend(HTMLGenerateSpanFont("Equip the Kramco Sausage-o-Matic&trade; first.", "red"));
            url = generateEquipmentLink($item[kramco sausage-o-matic&trade;]);
        }
        description.listAppend("Free fight that burns delay.");
        location [int] possible_locations = generatePossibleLocationsToBurnDelay();
        if (possible_locations.count() > 0)
        {
            description.listAppend("Adventure in " + possible_locations.listJoinComponents(", ", "or") + " to burn delay.");
            if (url == "")
                url = possible_locations[0].getClickableURLForLocation();
        }
        task_entries.listAppend(ChecklistEntryMake("__item Kramco Sausage-o-Matic&trade;", url, ChecklistSubentryMake(title, "", description), -11));
    }
    int sausages_eaten = get_property_int("_sausagesEaten");
    if ($item[magical sausage].have() && sausages_eaten < 23)
    {
    	string title;
        string description;
        title = "Eat " + pluralise(MIN($item[magical sausage].available_amount(), 23 - sausages_eaten), "magical sausage", "magical sausages");
        description = "+1 adventure each.";
        optional_task_entries.listAppend(ChecklistEntryMake("__item magical sausage", "inventory.php?which=1", ChecklistSubentryMake(title, "", description), 8));
    }
}

RegisterResourceGenerationFunction("IOTMKramcoSausageOMaticGenerateResource");
void IOTMKramcoSausageOMaticGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!$item[Kramco Sausage-o-Matic&trade;].have()) return;
    if (!__misc_state["can equip just about any off-hand"]) return;
	
	if (my_path_id() == PATH_LIVE_ASCEND_REPEAT) return;
    ChecklistEntry entry = ChecklistEntryMake();
    entry.image_lookup_name = "__item Kramco Sausage-o-Matic&trade;";
    entry.url = "inventory.php?action=grind";
    entry.url = generateEquipmentLink($item[Kramco Sausage-o-Matic&trade;]);
    entry.importance_level = -2;
    
    
    string [int] main_description;
    string main_title = "Kramco Sausage-o-Matic&trade; fights";
    
    KramcoSausageFightInformation fight_information = KramcoCalculateSausageFightInformation();
    
    
    
    
    if (fight_information.turns_to_next_guaranteed_fight == 0)
    {
	    main_title = "Sausage goblin fight now";
     	entry.ChecklistEntrySetShortDescription("now");   
    }
    else
    	main_title = pluralise(fight_information.turns_to_next_guaranteed_fight, "turn", "turns") + " until next guaranteed sausage goblin fight";
    if (fight_information.turns_to_next_guaranteed_fight > 0)
    {
	    main_description.listAppend(round(fight_information.probability_of_sausage_fight * 100.0) + "% chance of goblin fight this turn.");
        
        //too confusing to switch
        //if (fight_information.turns_to_next_guaranteed_fight >= my_adventures() || fight_information.turns_to_next_guaranteed_fight >= 50)
	     	//entry.ChecklistEntrySetShortDescription(round(fight_information.probability_of_sausage_fight * 100.0) + "%");   
    }
    main_description.listAppend("Does not cost a turn, burns delay.");
       
    int fights_so_far = get_property_int("_sausageFights");
    if (fights_so_far > 0)
	    main_description.listAppend("Fought " + pluralise(fights_so_far, "goblin", "goblins") + " so far.");
     
     
	
	if (fight_information.turns_to_next_guaranteed_fight > 0)
	{
		string second_stage = "if you keep the grinder equipped";
        if (!$item[Kramco Sausage-o-Matic&trade;].equipped())
        	second_stage = "if you equip and keep on the grinder";
		main_description.listAppend("~" + fight_information.average_turns_to_next_sausage_fight_if_continually_equipped.roundForOutput(1) + " turns to encounter a goblin, " + second_stage + ".");
    }
    
    entry.subentries.listAppend(ChecklistSubentryMake(main_title, "", main_description));
	if ($item[magical sausage casing].available_amount() > 0 && __misc_state["in run"])
	{
        //FIXME
        string [int] sausage_description;
        int sausages_made = get_property_int("_sausagesMade");
        int meat_cost = 111 * (sausages_made + 1);
        sausage_description.listAppend("+1 adventures each.");
        sausage_description.listAppend("Currently costs " + meat_cost + " meat to make one.");
    	entry.subentries.listAppend(ChecklistSubentryMake(pluralise($item[magical sausage casing].available_amount(), "magical sausage", "magical sausages") + " creatable", "", sausage_description));
	}
	
	
	resource_entries.listAppend(entry);
	
	
    //resource_entries.listAppend(ChecklistEntryMake("__item Kramco Sausage-o-Matic&trade;", "", ChecklistSubentryMake(title, "", "Free run/banish."), 6));
}
