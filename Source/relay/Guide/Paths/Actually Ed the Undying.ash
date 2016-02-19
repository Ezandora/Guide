
RegisterTaskGenerationFunction("PathActuallyEdtheUndyingGenerateTasks");
void PathActuallyEdtheUndyingGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING) return;
    
    int skills_available = MIN(15, my_level()) - MIN(15, my_level()) / 3 + get_property_int("edPoints"); //assumption
    
    skills_available = MIN(21, skills_available);
    
    int skills_have = 0;
    foreach s in lookupSkillsInt($ints[17000,17001,17002,17003,17004,17005,17006,17007,17008,17009,17010,17011,17012,17013,17014,17015,17016,17017,17018,17019,17020])
    {
        if (s.skill_is_usable())
            skills_have += 1;
    }
    //FIXME describe what the next three skills do...?
    
    if (skills_available > skills_have)
    {
        string image_name = "__skill wisdom of thoth";
        string [int] description;
        description.listAppend("At least " + pluraliseWordy(skills_available - skills_have, "skill", "skills") + " available.");
        optional_task_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=edbase&action=edbase_book", ChecklistSubentryMake("Buy Undying skills", "", description), 11));
    }
    
    if (my_level() >= 13 && QuestState("questL13Final").finished)
    {
        if ($item[7965].available_amount() > 0 || $item[2334].available_amount() > 0) //holy macguffins
        {
            string [int] description;
            description.listAppend("Finishes the path.");
            if (availableSpleen() > 0)
                description.listAppend("May want to fill your " + availableSpleen() + " extra spleen first.");
            task_entries.listAppend(ChecklistEntryMake("Pyramid", "place.php?whichplace=edbase&action=edbase_altar", ChecklistSubentryMake("Put back the Holy MacGuffin", "", description), -10));
        }
        else
        {
            //tutorial.php
            string [int] modifiers;
            string [int] description;
            string url = "tutorial.php";
            
            if (!$monster[warehouse janitor].is_banished())
                modifiers.listAppend("banish janitor");
            
            description.listAppend("Adventure in the Secret Government Warehouse, use the items you find.");
            
            int progress_remaining = clampi(40 - get_property_int("warehouseProgress"), 0, 40);
            if ($item[warehouse inventory page].available_amount() > 0 && $item[warehouse map page].available_amount() > 0)
            {
                description.listClear();
                description.listAppend("Use warehouse inventory page.");
                url = "inventory.php?which=3";
            }
            else if (progress_remaining > 0)
            {
                if ($skill[Lash of the Cobra].have_skill())
                {
                    description.listAppend("Use lash of the cobra on the clerk and guard.");
                }
                else
                {
                    modifiers.listAppend("+item");
                }
            }
            string [int] items_available;
            foreach it in $items[warehouse inventory page,warehouse map page]
            {
                if (it.available_amount() > 0)
                    items_available.listAppend(pluraliseWordy(it));
            }
            if (items_available.count() > 0)
            {
                description.listAppend(items_available.listJoinComponents(", ", "and").capitaliseFirstLetter() + " available.");
            }
            
            string line;// = pluraliseWordy(progress_remaining, "remaining aisle", "remaining aisles").capitaliseFirstLetter() + ".";
            if (progress_remaining <= 0)
                line += "MacGuffin next turn";
            else
                line += "Fight " + progress_remaining + " more combats";
            if (progress_remaining > 1)
            {
                int page_pairs_remaining = ceil(progress_remaining.to_float() / 8.0);
                
                /*string [int] bring_me_the_red_pages;
                
                int first_value = -1;
                boolean identical_twins = false;
                foreach it in $items[warehouse inventory page,warehouse map page]
                {
                    int pages_remaining = page_pairs_remaining - it.available_amount();
                    if (pages_remaining > 0)
                    {
                        if (first_value == -1)
                            first_value = pages_remaining;
                        else if (first_value == pages_remaining)
                        {
                            identical_twins = true;
                            bring_me_the_red_pages.listAppend(it);
                            continue;
                        }
                        bring_me_the_red_pages.listAppend(pluraliseWordy(pages_remaining, it));
                    }
                }
                
                if (identical_twins)
                    line += bring_me_the_red_pages.listJoinComponents("/");
                else
                    line += bring_me_the_red_pages.listJoinComponents(", ", "and");*/
                    
                line += " or collect ";
                line += pluraliseWordy(page_pairs_remaining, "more page pair", "more page pairs");
            }
            line += ".";
            description.listAppend(line);
            
            task_entries.listAppend(ChecklistEntryMake("__item holy macguffin", url, ChecklistSubentryMake("Retrieve the Holy MacGuffin", modifiers, description), $locations[The Secret Council Warehouse]));
        }
    }
}

RegisterResourceGenerationFunction("PathActuallyEdtheUndyingGenerateResource");
void PathActuallyEdtheUndyingGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING) return;
    item ka = $item[Ka coin];
    if (ka.available_amount() > 0)
    {
        string [int] description;
        
        string [int][int] ka_table;
        
        int haunches_edible = clampi(availableSpleen() / 5, 0, 7);
        if (haunches_edible > $item[mummified beef haunch].available_amount())
        {
            int haunches_want = haunches_edible - $item[mummified beef haunch].available_amount();
            //15 ka coin
            string name;
            if (haunches_want > 1)
                name = pluralise(haunches_want, $item[mummified beef haunch]);
            else
                name = "mummified beef haunch";
            ka_table.listAppend(listMake(name, 15, "best spleen consumable"));
        }
        if ($item[linen bandages].available_amount() == 0 && $item[cotton bandages].available_amount() == 0 && $item[silk bandages].available_amount() == 0)
        {
            //linen bandages, 1 ka coin
            ka_table.listAppend(listMake("linen bandages", 1, "when beaten up outside a fight"));
        }
        
        //seven talisman of Renenutet (1 ka coin)
        //talisman of Horus (5 ka coin, +combat)
        int talismen_of_horus_wanted = 0;
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
            talismen_of_horus_wanted += 2;
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
            talismen_of_horus_wanted += 2;
        if ($item[pirate fledges].available_amount() == 0 && $item[talisman o' namsilat].available_amount() == 0)
            talismen_of_horus_wanted += 2;
        if (talismen_of_horus_wanted == 0) //where else do you need +combat? pirate's cove?
            talismen_of_horus_wanted = 1;
        if ($item[talisman of Horus].available_amount() < talismen_of_horus_wanted)
        {
            ka_table.listAppend(listMake("talisman of Horus", 5, "+combat potion"));
        }
        ka_table.listAppend(listMake("talisman of Renenutet", 1, "+lots item for one combat"));
        //body upgrades:
        string [int][int] skill_upgrade_order;
        skill_upgrade_order.listAppend(listMake("Extra Spleen", 5, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Another Extra Spleen", 10, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Yet Another Extra Spleen", 15, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Still Another Extra Spleen", 20, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Replacement Stomach", 30, "+5 stomach")); //fortune cookie
        skill_upgrade_order.listAppend(listMake("Just One More Extra Spleen", 25, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Okay Seriously, This is the Last Spleen", 30, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Replacement Liver", 30, "can drink"));
        skill_upgrade_order.listAppend(listMake("Upgraded Legs", 10, "+50% init"));
        skill_upgrade_order.listAppend(listMake("More Legs", 20, "+50% init"));
        skill_upgrade_order.listAppend(listMake("Elemental Wards", 10, "+1 all res"));
        skill_upgrade_order.listAppend(listMake("More Elemental Wards", 20, "+2 all res"));
        skill_upgrade_order.listAppend(listMake("Tougher Skin", 10, "+100 DA"));
        skill_upgrade_order.listAppend(listMake("Even More Elemental Wards", 30, "+3 all res"));
        skill_upgrade_order.listAppend(listMake("Upgraded Spine", 20, "+50% moxie"));
        skill_upgrade_order.listAppend(listMake("Upgraded Arms", 20, "+50% muscle"));
        skill_upgrade_order.listAppend(listMake("Armor Plating", 10, "+10 DR")); //marginal
        //skill_upgrade_order.listAppend(listMake("Bone Spikes", 20));
        //skill_upgrade_order.listAppend(listMake("Arm Blade", 20));
        //skill_upgrade_order.listAppend(listMake("Healing Scarabs")); //only useful if it prevents beaten up from non-combats?
        
        foreach key in skill_upgrade_order
        {
            string [int] l = skill_upgrade_order[key];
            skill s = l[0].lookupSkill();
            int ka_cost = l[1].to_int_silent();
            string reason = l[2];
            if (s == $skill[none])
                break;
            if (s.have_skill()) continue;
            
            
            /*string line = "Could upgrade your body with " + s + ".";
            if (ka_cost > ka.available_amount())
                line = HTMLGenerateSpanFont(line, "grey");
            description.listAppend(line);*/
            ka_table.listAppend(listMake(s, ka_cost, reason));
            break;
        }
        
        if (ka_table.count() > 0)
        {
            foreach key in ka_table
            {
                int ka_needed = ka_table[key][1].to_int_silent();
                if (ka_needed > ka.available_amount())
                {
                    foreach key2 in ka_table[key]
                    {
                        ka_table[key][key2] = HTMLGenerateSpanFont(ka_table[key][key2], "grey");
                    }
                }
            }
            description.listAppend(HTMLGenerateSimpleTableLines(ka_table));
        }
        
        string url = "";
        string [int] places_to_farm_ka;
        if (getHolidaysToday()["Halloween"])
        {
            places_to_farm_ka.listAppend("trick or treating");
            url = "place.php?whichplace=town";
        }
        if (__misc_state["spooky airport available"])
        {
            places_to_farm_ka.listAppend("laboratory on conspiracy island");
            if (url.length() == 0) url = $location[the secret government laboratory].getClickableURLForLocation();
        }
        if (__misc_state["hot airport available"])
        {
            places_to_farm_ka.listAppend("smooch army HQ");
            if (url.length() == 0) url = lookupLocation("The SMOOCH Army HQ").getClickableURLForLocation();
        }
        if (__misc_state["mysterious island available"] && !__quest_state["Level 12"].in_progress && my_level() < 9) //we test if we're under level 9 and the level 12 quest isn't in progress. maybe they ate a lot of hot dogs. it could happen!
        {
            places_to_farm_ka.listAppend("hippy camp");
            if (url.length() == 0) url = $location[hippy camp].getClickableURLForLocation();
        }
        
        if (places_to_farm_ka.count() > 0)
            description.listAppend("Could farm ka in the " + places_to_farm_ka.listJoinComponents(", ", "or") + ".");
        
        resource_entries.listAppend(ChecklistEntryMake("__item ka coin", url, ChecklistSubentryMake(ka.pluralise(), "", description), 6));
    }
    
    if (true)
    {
        ChecklistSubentry [int] subentries;
        string image_name = "";
        string [item] path_relevant_items;
        
        path_relevant_items[$item[talisman of Renenutet]] = "+lots% item in a single combat";
        path_relevant_items[$item[talisman of Horus]] = "+lots% combat potion";
        path_relevant_items[$item[ancient cure-all]] = "SGEEA-equivalent?";
        foreach s in $strings[linen bandages,cotton bandages,silk bandages]
        {
            if (lookupItem(s).available_amount() > 0)
            {
                path_relevant_items[lookupItem(s)] = "heal at zero HP";
                break;
            }
        }
        foreach it, reason in path_relevant_items
        {
            if (it.available_amount() > 0)
            {
                subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", reason.capitaliseFirstLetter() + "."));
                if (image_name.length() == 0)
                    image_name = "__item " + it;
            }
        }
        if (subentries.count() > 0)
            resource_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 6));
    }
    
    if ($skill[Lash of the cobra].have_skill() && mafiaIsPastRevision(15553) || true)
    {
        int lashes_remaining = 30 - get_property_int("_edLashCount");
        if (lashes_remaining > 0)
        {
            string [int] description;
            string [int] stealables;
            //Stuff:
            //snake +ML
            //badge of authority (HC)
            //warehouse
            //barret, aerith
            //pygmy witch lawyers
            //filthworms
            //war hippy drill sergeant
            //war outfit (if wrath of ra not available)
            //pirate outfit? specific monsters left
            //hot wings from p imp / g imp
            //beanbats (if unlocked, else batrats/ratbats, else guano junction)
            //skeletons in the nook
            //topiary animals in twin peak
            //dusken raider ghost (if oil needed)
            //oil cartel(?)
            if (stealables.count() > 0)
                description.listAppend("Steals a random item:|*" + stealables.listJoinComponents("|*"));
            else
                description.listAppend("Steals a random item.");
                
            resource_entries.listAppend(ChecklistEntryMake("__item cool whip", "", ChecklistSubentryMake(pluralise(lashes_remaining, "lash", "lashes") + " of the cobra left", "", description), 6));
        }
    }
}