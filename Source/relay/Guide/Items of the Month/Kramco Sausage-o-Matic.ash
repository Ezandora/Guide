

RegisterTaskGenerationFunction("IOTMKramcoSausageOMaticGenerateTasks");
void IOTMKramcoSausageOMaticGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (lookupItem("Kramco Sausage-o-Matic&trade;").available_amount() == 0) return;
    
    if (!__misc_state["in run"]) return;
    //If goblin is up, display reminder:
    
    KramcoSausageFightInformation fight_information = KramcoCalculateSausageFightInformation();
    if (fight_information.turns_to_next_guaranteed_fight == 0)
    {
        
        string url = "";
        string [int] description;
        string title = "Fight sausage goblin ";
        if (lookupItem("Kramco Sausage-o-Matic&trade;").equipped_amount() == 0)
        {
            description.listAppend(HTMLGenerateSpanFont("Equip the Kramco Sausage-o-Matic&trade; first.", "red"));
            url = "inventory.php?which=2";
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
    if (lookupItem("magical sausage").available_amount() > 0 && sausages_eaten < 23)
    {
    	string title;
        string description;
        title = "Eat " + pluralise(MIN(lookupItem("magical sausage").available_amount(), 23 - sausages_eaten), "magical sausage", "magical sausages");
        description = "+1 adventure each.";
        optional_task_entries.listAppend(ChecklistEntryMake("__item magical sausage", "inventory.php?which=1", ChecklistSubentryMake(title, "", description), 8));
    }
}

RegisterResourceGenerationFunction("IOTMKramcoSausageOMaticGenerateResource");
void IOTMKramcoSausageOMaticGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (lookupItem("Kramco Sausage-o-Matic&trade;").available_amount() == 0) return;
	
    ChecklistEntry entry;
    entry.image_lookup_name = "__item Kramco Sausage-o-Matic&trade;";
    entry.url = "inventory.php?action=grind";
    entry.importance_level = 1;
    
    
    string [int] main_description;
    string main_title = "Kramco Sausage-o-Matic&trade; fights";
    
    KramcoSausageFightInformation fight_information = KramcoCalculateSausageFightInformation();
    
    
    
    
    if (fight_information.turns_to_next_guaranteed_fight == 0)
	    main_title = "Sausage goblin fight now?";
    else
    	main_title = pluralise(fight_information.turns_to_next_guaranteed_fight, "turn(?)", "turns(?)") + " until next sausage goblin fight";
    if (fight_information.turns_to_next_guaranteed_fight > 0)
	    main_description.listAppend(round(fight_information.probability_of_sausage_fight * 100.0) + "%(?) chance of goblin fight this turn.");
    main_description.listAppend("Does not cost a turn, burns delay.");
       
    int fights_so_far = get_property_int("_sausageFights");
    if (fights_so_far > 0)
	    main_description.listAppend("Fought " + pluralise(fights_so_far, "goblin", "goblins") + " so far.");
    
    entry.subentries.listAppend(ChecklistSubentryMake(main_title, "", main_description));
	if (lookupItem("magical sausage casing").available_amount() > 0 && __misc_state["in run"])
	{
        //FIXME
        string [int] sausage_description;
        int sausages_made = get_property_int("_sausagesMade");
        int meat_cost = 111 * (sausages_made + 1);
        sausage_description.listAppend("+1 adventures each.");
        sausage_description.listAppend("Currently costs " + meat_cost + " meat to make one.");
    	entry.subentries.listAppend(ChecklistSubentryMake(pluralise(lookupItem("magical sausage casing").available_amount(), "magical sausage", "magical sausages") + " creatable", "", sausage_description));
	}
	
	
	resource_entries.listAppend(entry);
	
	
    //resource_entries.listAppend(ChecklistEntryMake("__item Kramco Sausage-o-Matic&trade;", "", ChecklistSubentryMake(title, "", "Free run/banish."), 6));
}
