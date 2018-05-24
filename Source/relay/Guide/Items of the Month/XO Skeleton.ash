
RegisterResourceGenerationFunction("IOTMXOSkeletonGenerateResource");
void IOTMXOSkeletonGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!lookupFamiliar("XO Skeleton").familiar_is_usable()) return;
	
	
	
	int hugs_remaining = clampi(11 - get_property_int("_xoHugsUsed"), 0, 11);
	
	ChecklistEntry entry;
	entry.image_lookup_name = "__familiar xo skeleton";
	entry.importance_level = 3;
	if (my_familiar() != lookupFamiliar("XO Skeleton"))
		entry.url = "familiar.php";
	
	
	if ((my_familiar() == lookupFamiliar("XO Skeleton") || __misc_state["in run"]) && hugs_remaining > 0)
	{
		string [int] description;
  		description.listAppend("Instantly v-pocket an item.");
    	if (__misc_state["in run"] && my_path_id() != PATH_COMMUNITY_SERVICE)
     	{
      		string [int] options;
        	if (!__quest_state["Level 12"].finished && get_property("sidequestOrchardCompleted") == "none" && !($effect[Filthworm Guard Stench].have_effect() > 0 || $item[Filthworm royal guard scent gland].available_amount() > 0))      
        		options.listAppend("filthworms");
         	if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && !QuestState("questM20Necklace").finished)
	            options.listAppend("banshee librarian (killing jar)");
            if (get_property_int("hiddenApartmentProgress") < 7 || get_property_int("hiddenOfficeProgress") < 7)
	            options.listAppend("pygmy witch lawyer (short writs)");
            if (!have_outfit_components("Swashbuckling Getup"))
	            options.listAppend("obligatory pirate's cove (outfit)");
            if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] >= 90)
	            options.listAppend("Whatsian Commando Ghost (ghost free runaway)");
        	if (options.count() > 0)
         		description.listAppend(options.listJoinComponents(", ").capitaliseFirstLetter() + ", etc.");            
      	}            
		entry.subentries.listAppend(ChecklistSubentryMake(pluralise(hugs_remaining, "hug", "hugs"), "", description));
	}
	
	if (__misc_state["in run"] && in_ronin())
	{
        int xes = lookupItem("9543").available_amount();
        int os = lookupItem("9544").available_amount();
        
        //two Os: pair of candy glasses (10 adventures of +50% item)
        //Hide-rox™ cookie: 3 os, 1-size food, myst tower test
        //jug of booze: 3 xes, 1-size booze, moxie tower test
        //glyph of athleticism: 5 Os, 1-size spleen, muscle tower test
        //bridge truss: 23 xes, 15 bridge progress, takes forever to acquire
		
		string header;
        string [int] description;
		if (xes > 0)
  	      header += pluralise(xes, "X", "Xes");
        if (os > 0)
        {
        	if (header != "")
         		header += ", ";
            header += pluralise(os, "O", "Os");
        }
        
        boolean [string] options;
        
        options["pair of candy glasses: +50% item (10 turns)"] = (os >= 2);
        if (!__quest_state["Level 9"].state_boolean["bridge complete"] && my_path_id() != PATH_COMMUNITY_SERVICE)
	        options["bridge truss: half a bridge, takes forever to get"] = (xes >= 23);
        if (!__quest_state["Level 13"].state_boolean["Stat race completed"])
        {
        	stat stat_race_type = __quest_state["Level 13"].state_string["Stat race type"].to_stat();
         	//if (stat_race_type == $stat[muscle])
        }
        foreach option, available in options
        {
        	string line = option;
         	if (!available)
          		line = HTMLGenerateSpanFont(line, "gray");
            description.listAppend(line);            
        }
        
        entry.subentries.listAppend(ChecklistSubentryMake(header, "", description));
	}
	
	if (entry.subentries.count() > 0)
		resource_entries.listAppend(entry);
}
