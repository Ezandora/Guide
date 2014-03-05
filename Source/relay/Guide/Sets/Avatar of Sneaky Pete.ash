

void SSneakyPeteGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    //my_audience() whenever 16.3 is out
    
    
	ChecklistEntry entry;
	entry.target_location = "";
	entry.image_lookup_name = "";
    entry.importance_level = 1;
    
    
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
            
            if (entry.image_lookup_name.length() == 0)
                entry.image_lookup_name = "__skill Easy Riding";
        
            entry.subentries.listAppend(ChecklistSubentryMake(pluralize(free_peel_outs_available, "peel out", "peel outs"), "10 MP/cast", description));
        }
    }
    
    if (lookupSkill("Fix Jukebox").have_skill() && get_property_int("_peteJukeboxFixed") < 3 && get_revision() >= 13785)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJukeboxFixed"));
        
        string [int] description;
        description.listAppend("+300% item, one combat.");
        description.listAppend("+10 audience love.");
        
        if (entry.image_lookup_name.length() == 0)
            entry.image_lookup_name = "__effect jukebox hero";
        
        entry.subentries.listAppend(ChecklistSubentryMake(pluralize(uses_remaining, "jukebox fix", "jukebox fixes"), "25 MP", description));
    }
    
    if (lookupSkill("Jump Shark").have_skill() && get_property_int("_peteJumpedShark") < 3 && get_revision() >= 13730)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJumpedShark"));
        
        string [int] description;
        description.listAppend((10 * my_level()) + " muscle/mysticality/moxie. (increases with level)");
        description.listAppend("+10 audience hate.");
        
        if (entry.image_lookup_name.length() == 0)
            entry.image_lookup_name = "__skill jump shark";
        entry.subentries.listAppend(ChecklistSubentryMake(pluralize(uses_remaining, "shark jump", "shark jumps"), "25 MP", description));
    }
    
    
    if (entry.subentries.count() > 0)
        available_resources_entries.listAppend(entry);
}

void SSneakyPeteGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    
    
    if (true)
    {
        string [int] parts_not_upgraded;
        int motorcycle_upgrades_have = 0;
        
        foreach s in $strings[peteMotorbikeTires,peteMotorbikeGasTank,peteMotorbikeHeadlight,peteMotorbikeCowling,peteMotorbikeMuffler,peteMotorbikeSeat]
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
    
    //sneakyPetePoints first
    /*int skills_available = MIN(30, MIN(15, my_level()) + get_property_int("sneakyPetePoints"));
    
    int skills_have = 0;
    foreach s in lookupSkills("Catchphrase,Mixologist,Throw Party,Fix Jukebox,Snap Fingers,Shake It Off,Check Hair,Cocktail Magic,Make Friends,Natural Dancer,Rev Engine,Born Showman,Pop Wheelie,Rowdy Drinker,Peel Out,Easy Riding,Check Mirror,Riding Tall,Biker Swagger,Flash Headlight,Insult,Live Fast,Incite Riot,Jump Shark,Animal Magnetism,Smoke Break,Hard Drinker,Unrepentant Thief,Brood,Walk Away From Explosion")
    {
        if (s.have_skill())
            skills_have += 1;
    }
    
    if (skills_available > skills_have)
    {
        string [int] description;
        description.listAppend("At least " + pluralizeWordy(skills_available - skills_have, "skill", "skills") + " available.");
        optional_task_entries.listAppend(ChecklistEntryMake("__skill Natural Dancer", "da.php?place=gate3", ChecklistSubentryMake("Buy Sneaky Pete skills", "", description), 11));
    }*/
}