

void SSneakyPeteGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    //my_audience() whenever 16.3 is out
    
    //FIXME put these in one entry?
    
    //Need more combat message spading before these can be enabled:
    /*
    if (lookupSkill("Fix Jukebox").have_skill() && get_property_int("_peteJukeboxFixed") < 3)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJukeboxFixed"));
        
        string [int] description;
        description.listAppend("+300% item, one combat.");
        description.listAppend("+audience love.");
        
        available_resources_entries.listAppend(ChecklistEntryMake("__effect jukebox hero", "", ChecklistSubentryMake(pluralize(uses_remaining, "Fix Jukebox", "Fix Jukeboxes"), "", description), 1));
    }
    
    if (lookupSkill("Jump Shark").have_skill() && get_property_int("_peteJumpedShark") < 3)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJumpedShark"));
        
        string [int] description;
        description.listAppend("-audience love.");
        
        available_resources_entries.listAppend(ChecklistEntryMake("__skill jump shark", "", ChecklistSubentryMake(pluralize(uses_remaining, "shark jump", "shark jumps"), "", description), 5));
    }*/
    
    if (get_revision() >= 13783)
    {
        int total_free_peel_outs_available = 10;
        if (get_property("peteMotorbikeTires") == "Racing Slicks")
            total_free_peel_outs_available += 20;
        
        int free_peel_outs_available = MAX(0, total_free_peel_outs_available - get_property_int("_petePeeledOut"));
        
        if (lookupSkill("Peel Out").have_skill() && free_peel_outs_available > 0)
        {
            string [int] description;
            
            if (get_property("peteMotorbikeMuffler") == "Extra-Smelly Muffler")
                description.listAppend("Free runaway/banish in-combat.");
            else
                description.listAppend("Free runaway in-combat.");
            
            available_resources_entries.listAppend(ChecklistEntryMake("__skill Easy Riding", "", ChecklistSubentryMake(pluralize(free_peel_outs_available, "peel out", "peel outs"), "10 MP/cast", description), 1));
        }
    }
}

void SSneakyPeteGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    
    
    if (true)
    {
        string [int] parts_not_upgraded;
        int motorcycle_upgrades_have = 0;
        
        foreach s in $strings[peteMotorbikeCowling,peteMotorbikeGasTank,peteMotorbikeHeadlight,peteMotorbikeMuffler,peteMotorbikeSeat,peteMotorbikeTires]
        {
            if (get_property(s).length() > 0)
                motorcycle_upgrades_have += 1;
            else
                parts_not_upgraded.listAppend(s);
        }
        int motorcycle_upgrades_available = MIN(6, my_level() / 2);
        
        if (motorcycle_upgrades_have < motorcycle_upgrades_available && (get_revision() > 13738 || motorcycle_upgrades_have > 0))
        {
            string [int] description;
            description.listAppend(pluralize(motorcycle_upgrades_available - motorcycle_upgrades_have, "upgrade", "upgrades") + " available.");
            
            string [int] upgrades;
            foreach key in parts_not_upgraded
            {
                string property_name = parts_not_upgraded[key];
                
                string name = "";
                string [int] options;
                
                if (property_name == "peteMotorbikeSeat")
                {
                    name = "Seat";
                    
                    options.listAppend("regenerate 5-6 HP/MP");
                    options.listAppend("find meat after combat (marginal)");
                    options.listAppend("-30 ML (harmful)");
                }
                else if (property_name == "peteMotorbikeCowling")
                {
                    name = "Cowling";
                    if (__quest_state["Level 7"].state_int["alcove evilness"] > 26 || __quest_state["Level 7"].state_int["cranny evilness"] > 26 || __quest_state["Level 7"].state_int["niche evilness"] > 26 || __quest_state["Level 7"].state_int["nook evilness"] > 26)
                        options.listAppend("faster cyrpt");
                    if (__quest_state["Level 12"].finished)
                        options.listAppend("passive +damage/round");
                    else
                        options.listAppend("passive +damage/round and +3 war kills");
                    options.listAppend("+5 stats/fight");
                }
                else if (property_name == "peteMotorbikeGasTank")
                {
                    name = "Gas tank";
                
                    if (!knoll_available() && !__misc_state["desert beach available"])
                        options.listAppend("desert beach access");
                    if (!__misc_state["mysterious island available"])
                        options.listAppend("mysterious island access");
                    options.listAppend("+50% combat initiative");
                }
                else if (property_name == "peteMotorbikeHeadlight")
                {
                    name = "Headlight";
                    
                    if (lookupSkill("Flash Headlight").have_skill())
                    {
                        options.listAppend("yellow ray from flash headlight");
                        options.listAppend("prismatic damage from flash headlight");
                    }
                    else
                    {
                        options.listAppend("yellow ray (need flash headlight)");
                        options.listAppend("prismatic damage (need flash headlight)");
                    }
                    if (!__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"])
                        options.listAppend("+2% desert exporation");
                }
                else if (property_name == "peteMotorbikeMuffler")
                {
                    name = "Muffler";
                    if (lookupSkill("Rev Engine").have_skill())
                    {
                        options.listAppend("+combat% from rev engine");
                        options.listAppend("-combat% from rev engine");
                    }
                    else
                    {
                        options.listAppend("+X% combat from rev engine (need skill)");
                        options.listAppend("-X% combat from rev engine (need skill)");
                    }
                    if (lookupSkill("Peel Out").have_skill())
                        options.listAppend("peel out banishes");
                    else
                        options.listAppend("peel out banishes (need skill)");
                }
                else if (property_name == "peteMotorbikeTires")
                {
                    name = "Tires";
                    if (lookupSkill("Peel Out").have_skill())
                        options.listAppend("extra free runs with peel out");
                    else
                        options.listAppend("extra free runs (need peel out)");
                    if (lookupSkill("Pop Wheelie").have_skill())
                        options.listAppend("pop wheelie does more damage");
                    else
                        options.listAppend("pop wheelie does more damage (need skill)");
                    
                    if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
                        options.listAppend("near-instant level 8 quest completion");
                }
                
                if (name.length() > 0)
                {
                    upgrades.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + " - " + options.listJoinComponents(", ", "or").capitalizeFirstLetter() + ".");
                    //upgrades.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + "|*" + options.listJoinComponents("|*"));
                }
            }
            description.listAppendList(upgrades);


            optional_task_entries.listAppend(ChecklistEntryMake("__skill Easy Riding", "main.php?action=motorcycle", ChecklistSubentryMake("Upgrade your bike", "", description), 11));
            
        }
    }
    
    if (true)
    {
        //FIXME buy skills?
        //need to know how many we have...
    }
}