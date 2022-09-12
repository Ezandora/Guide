

RegisterResourceGenerationFunction("PathSneakyPeteGenerateResource");
void PathSneakyPeteGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id_legacy() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    
    
	ChecklistEntry entry = ChecklistEntryMake(148);
	entry.url = "";
	entry.image_lookup_name = "";
    entry.importance_level = 1;
    
    if (true)
    {
        int total_free_peel_outs_available = 10;
        if (get_property("peteMotorbikeTires") == "Racing Slicks")
            total_free_peel_outs_available += 20;
        
        int free_peel_outs_available = MAX(0, total_free_peel_outs_available - get_property_int("_petePeeledOut"));
        
        if ($skill[Peel Out].skill_is_usable() && free_peel_outs_available > 0)
        {
            string [int] description;
            
            boolean is_banish = false;
            if (get_property("peteMotorbikeMuffler") == "Extra-Smelly Muffler")
            {
                description.listAppend("Free runaway/banish in-combat.");
                is_banish = true;
            }
            else
                description.listAppend("Free runaway in-combat.");
            
            if (entry.image_lookup_name.length() == 0)
                entry.image_lookup_name = "__skill Easy Riding";
        
        	ChecklistSubentry subentry = ChecklistSubentryMake(pluralise(free_peel_outs_available, "peel out", "peel outs"), "10 MP/cast", description);
            if (is_banish)
            	resource_entries.listAppend(ChecklistEntryMake(149, "__skill Easy Riding", "", subentry).ChecklistEntryTag("free banish"));
            else
	            entry.subentries.listAppend(subentry);
        }
    }
    
    if ($skill[Fix Jukebox].skill_is_usable() && get_property_int("_peteJukeboxFixed") < 3)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJukeboxFixed"));
        
        string [int] description;
        description.listAppend("+300% item, one combat.");
        description.listAppend("+10 audience love.");
        
        if (entry.image_lookup_name.length() == 0)
            entry.image_lookup_name = "__effect jukebox hero";
        
        string [int] targets;
        //√banshee, √a batrat for sonar, √harem girl (contested), √burly sidekick, √quiet healer, √filthworms, √f'c'le without natural dancer, √a-boo clues
        if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && !__quest_state["Level 11 Desert"].state_boolean["Killing Jar Given"] && $item[killing jar].available_amount() == 0)
            targets.listAppend("Haunted Library - Banshee - Killing Jar to speed up desert exploration.");
        if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 3)
            targets.listAppend("Batrat/Ratbat - Sonar-in-a-biscuit.");
        
        if (!have_outfit_components("Knob Goblin Elite Guard Uniform") && !have_outfit_components("Knob Goblin Harem Girl Disguise") && !__quest_state["Level 5"].finished)
            targets.listAppend("Harem Girl - disguise for quest. (20% drop)");
        
		if (!__quest_state["Level 10"].finished && $item[mohawk wig].available_amount() == 0 && $item[s.o.c.k.].available_amount() == 0)
			targets.listAppend("Burly Sidekick (Mohawk wig) - speed up top floor of castle.");
        if ($item[amulet of extreme plot significance].available_amount() == 0 && !__quest_state["Level 10"].finished && !$location[The Castle in the Clouds in the Sky (Ground floor)].locationAvailable() && $item[s.o.c.k.].available_amount() == 0)
			targets.listAppend("Quiet Healer (amulet of extreme plot significance) - speed up castle basement.");
		if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
			targets.listAppend("Filthworms.");
            
        if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 && $item[a-boo clue].available_amount() < 3)
            targets.listAppend("A-Boo Peak - a-boo clues. (15% drop)");
        
        if (targets.count() > 0)
            description.listAppend("Potential targets:|*" + targets.listJoinComponents("<hr>|*"));
        
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(uses_remaining, "jukebox fix", "jukebox fixes"), "25 MP", description));
    }
    
    if ($skill[Jump Shark].skill_is_usable() && get_property_int("_peteJumpedShark") < 3)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJumpedShark"));
        
        string [int] description;
        description.listAppend((10 * my_level()) + " muscle/mysticality/moxie. (increases with level)");
        description.listAppend("+10 audience hate.");
        
        if (entry.image_lookup_name.length() == 0)
            entry.image_lookup_name = "__skill jump shark";
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(uses_remaining, "shark jump", "shark jumps"), "25 MP", description));
    }
    
    
    if (entry.subentries.count() > 0)
        resource_entries.listAppend(entry);
}

RegisterTaskGenerationFunction("PathSneakyPeteGenerateTasks");
void PathSneakyPeteGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id_legacy() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    
    
    if (true)
    {
        string [int] parts_not_upgraded;
        int motorcycle_upgrades_have = 0;
        
        foreach s in $strings[peteMotorbikeTires,peteMotorbikeGasTank,peteMotorbikeHeadlight,peteMotorbikeCowling,peteMotorbikeMuffler,peteMotorbikeSeat]
        {
            if (get_property(s) != "")
                motorcycle_upgrades_have += 1;
            else
                parts_not_upgraded.listAppend(s);
        }
        int motorcycle_upgrades_available = MIN(6, my_level() / 2);
        
        if (motorcycle_upgrades_have < motorcycle_upgrades_available)
        {
            string [int] description;
            description.listAppend(pluralise(motorcycle_upgrades_available - motorcycle_upgrades_have, "upgrade", "upgrades") + " available.");
            
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
                    
                    if ($skill[Flash Headlight].skill_is_usable())
                    {
                        options.listAppend("yellow ray from flash headlight");
                        options.listAppend("prismatic damage from flash headlight");
                    }
                    else
                    {
                        options.listAppend("yellow ray (need flash headlight)");
                        options.listAppend("prismatic damage (need flash headlight)");
                    }
                    if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"])
                        options.listAppend("+2% desert exporation");
                }
                else if (property_name == "peteMotorbikeMuffler")
                {
                    name = "Muffler";
                    if ($skill[Rev Engine].skill_is_usable())
                    {
                        options.listAppend("+combat% from rev engine");
                        options.listAppend("-combat% from rev engine");
                    }
                    else
                    {
                        options.listAppend("+X% combat from rev engine (need skill)");
                        options.listAppend("-X% combat from rev engine (need skill)");
                    }
                    if ($skill[Peel Out].skill_is_usable())
                        options.listAppend("peel out banishes");
                    else
                        options.listAppend("peel out banishes (need skill)");
                }
                else if (property_name == "peteMotorbikeTires")
                {
                    name = "Tires";
                    if ($skill[Peel Out].skill_is_usable())
                        options.listAppend("extra free runs with peel out");
                    else
                        options.listAppend("extra free runs (need peel out)");
                    if ($skill[Pop Wheelie].skill_is_usable())
                        options.listAppend("pop wheelie does more damage");
                    else
                        options.listAppend("pop wheelie does more damage (need skill)");
                    
                    if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
                        options.listAppend("near-instant level 8 quest completion");
                }
                
                if (name != "")
                {
                    upgrades.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + " - " + options.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
                    //upgrades.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + "|*" + options.listJoinComponents("|*"));
                }
            }
            description.listAppendList(upgrades);


            optional_task_entries.listAppend(ChecklistEntryMake(150, "__skill Easy Riding", "main.php?action=motorcycle", ChecklistSubentryMake("Upgrade your bike", "", description), 11));
            
        }
    }
    
    if ($skill[Check Mirror].skill_is_usable())
    {
        boolean have_intrinsic = false;
        foreach s in $strings[1553,Pompadour,Cowlick,Fauxhawk]
        {
            effect e = s.lookupEffect();
            if (e == $effect[none])
            {
                have_intrinsic = true; //can't track
                continue;
            }
            if (e.have_effect() == 2147483647)
                have_intrinsic = true;
        }
        if (!have_intrinsic)
        {
            string [int] description;
            
            description.listAppend("One adventure cost for an intrinsic.");
            string [int] options;
            options.listAppend("+3 all resistances (slicked-back do)");
            options.listAppend("+3 stats/fight (best, pompadour)");
            if (my_audience() >= 20)
                options.listAppend("+50% meat (cowlick)");
            else
                options.listAppend(HTMLGenerateSpanFont("+50% meat (requires 20 love)", "grey"));
            if (my_audience() <= -20)
                options.listAppend("+50% init (fauxhawk)");
            else
                options.listAppend(HTMLGenerateSpanFont("+50% init (requires 20 hate)", "grey"));
                
            //description.listAppend("Potential options:|*|*|*+|*");
            description.listAppend("Potential options:|*" + options.listJoinComponents("|*"));
            optional_task_entries.listAppend(ChecklistEntryMake(151, "__skill Check Mirror", "skills.php", ChecklistSubentryMake("Check mirror", "", description), 11));
        }
    }
    int audience_max = 30;
    if ($item[Sneaky Pete's leather jacket].equipped_amount() > 0 || $item[Sneaky Pete's leather jacket (collar popped)].equipped_amount() > 0)
    {
        audience_max = 50;
    }
    if ($skill[Throw Party].skill_is_usable() && my_audience() == audience_max && !get_property_boolean("_petePartyThrown"))
        task_entries.listAppend(ChecklistEntryMake(152, "__item party hat", "skills.php", ChecklistSubentryMake("Throw a party!", "", "Drinks."), -11));
    if ($skill[Incite Riot].skill_is_usable() && my_audience() == -audience_max && !get_property_boolean("_peteRiotIncited"))
        task_entries.listAppend(ChecklistEntryMake(153, "__item fire", "skills.php", ChecklistSubentryMake("Incite a riot", "", "Breaking the law, breaking the law."), -11));
    
    //sneakyPetePoints first
    int skills_available = MIN(30, MIN(15, my_level()) + get_property_int("sneakyPetePoints"));
    
    int skills_have = 0;
    //foreach s in $skills[Catchphrase,Mixologist,Throw Party,Fix Jukebox,Snap Fingers,Shake It Off,Check Hair,Cocktail Magic,Make Friends,Natural Dancer,Rev Engine,Born Showman,Pop Wheelie,Rowdy Drinker,Peel Out,Easy Riding,Check Mirror,Riding Tall,Biker Swagger,Flash Headlight,Insult,Live Fast,Incite Riot,Jump Shark,Animal Magnetism,Smoke Break,Hard Drinker,Unrepentant Thief,Brood,Walk Away From Explosion]
    foreach s in lookupSkillsInt($ints[15027,15019,15012,15028,15001,15007,15017,15008,15016,15004,15020,15025,15031,15021,15024,15023,15009,15002,15010,15015,15013,15011,15018,15014,15006,15026,15005,15003,15032,15030])
    {
        if (s.skill_is_usable())
            skills_have += 1;
    }
    
    if (skills_available > skills_have)
    {
        string [int] description;
        description.listAppend("At least " + pluraliseWordy(skills_available - skills_have, "skill", "skills") + " available.");
        optional_task_entries.listAppend(ChecklistEntryMake(154, "__skill Natural Dancer", "da.php?place=gate3", ChecklistSubentryMake("Buy Sneaky Pete skills", "", description), 11));
    }
}
