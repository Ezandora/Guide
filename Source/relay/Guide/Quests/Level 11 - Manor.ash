void QLevel11ManorInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Manor");
    state.quest_name = "Lord Spookyraven Quest";
    state.image_name = "Spookyraven manor";
    
    if (($items[Eye of Ed,Headpiece of the Staff of Ed].available_amount() > 0 || lookupItem("2325").available_amount() > 0) && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
        QuestStateParseMafiaQuestPropertyValue(state, "finished");
    
    
    boolean use_fast_route = true;
    if (!__misc_state["can equip just about any weapon"])
        use_fast_route = false;
    if (my_path_id() == PATH_NUCLEAR_AUTUMN && in_hardcore())
        use_fast_route = false;
    
    state.state_boolean["Can use fast route"] = use_fast_route;

    __quest_state["Level 11 Manor"] = state;
}

void QLevel11ManorGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Manor"].in_progress)
        return;
    if (__quest_state["Level 11"].mafia_internal_step <3 ) //strange bug where questL11MacGuffin = started, questL11Manor = step1
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Manor"];
    ChecklistSubentry subentry;
    string url = "";
    subentry.header = base_quest_state.quest_name;
    string image_name = base_quest_state.image_name;
    if (true)
    {
        boolean use_fast_route = base_quest_state.state_boolean["Can use fast route"];
        boolean recipe_will_be_autoread = (($item[lord spookyraven's spectacles].available_amount() > 0) && use_fast_route) && get_property_boolean("autoCraft");
        boolean recipe_was_autoread_with_glasses = (get_property("spookyravenRecipeUsed") == "with_glasses");
        boolean recipe_was_autoread = recipe_was_autoread_with_glasses || (get_property("spookyravenRecipeUsed") == "no_glasses");
        //FIXME spectacles first?
        if (!$location[the haunted ballroom].locationAvailable())
            return;
        if (!$location[the haunted ballroom].noncombat_queue.contains_text("We'll All Be Flat") && base_quest_state.mafia_internal_step < 2)
        {
            url = "place.php?whichplace=manor2";
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat in the haunted ballroom.");
            image_name = "Haunted Ballroom";
            if (delayRemainingInLocation($location[the haunted ballroom]) > 0)
            {
                string line = "Delay for " + pluralise(delayRemainingInLocation($location[the haunted ballroom]), "turn", "turns") + ".";
                if (__misc_state["have hipster"])
                {
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                }
                subentry.entries.listAppend(line);
            }
        }
        else
        {
            url = "manor3.php";
        
            if (use_fast_route && $item[lord spookyraven's spectacles].available_amount() == 0 && !recipe_was_autoread)
            {
                url = $location[the haunted bedroom].getClickableURLForLocation();
                subentry.entries.listAppend("Acquire Lord Spookyraven's spectacles from the haunted bedroom.|Unless you're using the slow route, in which case ignore this.");
                image_name = "__item Lord Spookyraven's spectacles";
            }
            else if ($item[recipe: mortar-dissolving solution].available_amount() == 0 && !__setting_debug_mode && !recipe_was_autoread)
            {
                if (recipe_will_be_autoread)
                {
                    subentry.entries.listAppend("Click on the suspicious masonry in the basement.");
                    image_name = "__item recipe: mortar-dissolving solution";
                }
                else if (use_fast_route && $item[lord spookyraven's spectacles].equipped_amount() == 0)
                {
                    url = "inventory.php?which=2";
                    subentry.entries.listAppend("Equip Lord Spookyraven's Spectacles, click on the suspicious masonry in the basement, then read the recipe.");
                    image_name = "__item Lord Spookyraven's spectacles";
                }
                else
                {
                    subentry.entries.listAppend("Click on the suspicious masonry in the basement, then read the recipe.");
                    image_name = "__item recipe: mortar-dissolving solution";
                }
                
            }
            else
            {
                //FIXME also make sure that is relevant when in the haunted bedroom/missing items
                //FIXME detect the chamber being opened
                boolean output_final_fight_info = false;
                if (use_fast_route)
                {
                    if ($item[wine bomb].available_amount() > 0 || base_quest_state.mafia_internal_step >= 4)
                    {
                        output_final_fight_info = true;
                    }
                    else if ($item[unstable fulminate].available_amount() > 0)
                    {
                        string [int] tasks;
                        if ($item[unstable fulminate].equipped_amount() == 0)
                        {
                            url = "inventory.php?which=2";
                            tasks.listAppend(HTMLGenerateSpanFont("Equip unstable fulminate", "red"));
                        }
                        image_name = "monstrous boiler";
                        
                        int ml_needed = 82;
                        int inherent_ml_modifier = 0;
                        //if (my_path_id() == PATH_HEAVY_RAINS) //need to test this
                            //inherent_ml_modifier = 82 - 40; //maybe?
                        ml_needed -= inherent_ml_modifier;
                        tasks.listAppend("adventure in the haunted boiler room with +" + ml_needed + " ML");
                        subentry.modifiers.listAppend("+" + ml_needed + " ML");
                        
                        subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
                        
                        int current_ml = $location[The Haunted Boiler Room].monster_level_adjustment_for_location();
                        
                        if (current_ml < ml_needed)
                        {
                            subentry.modifiers.listAppend("olfact boiler");
                        }
                        else
                        {
                            string [int] banish_targets;
                            if (!$monster[coaltergeist].is_banished())
                                banish_targets.listAppend("coaltergeist");
                            if (!$monster[steam elemental].is_banished())
                                banish_targets.listAppend("steam elemental");
                            if (banish_targets.count() > 0)
                                subentry.modifiers.listAppend("banish " + banish_targets.listJoinComponents(", "));
                        }
                        
                        float degrees_per_fight = 10 + floor(MAX((current_ml + inherent_ml_modifier).to_float(), 0.0) / 2.0);
                        
                        int boilers_needed = clampi(ceil(50.1 / degrees_per_fight.to_float()), 1, 6);
                        
                        monster boiler_monster = $monster[monstrous boiler];
                        float [monster] appearance_rates = $location[The Haunted Boiler Room].appearance_rates_adjusted();
                        
                        
                        float boiler_per_adventure = appearance_rates[boiler_monster] / 100.0;
                        
                        if (boiler_per_adventure != 0.0)
                        {
                            float turns_needed = boilers_needed.to_float() / boiler_per_adventure;
                            subentry.entries.listAppend("~" + turns_needed.roundForOutput(1) + " total turns to charge fulminate.");
                        }
                        else if ((appearance_rates contains boiler_monster) && boiler_monster != $monster[none])
                        {
                            subentry.entries.listAppend("Seemingly unable to find boilers. They miss you. They look up to you.");
                        }
                    }
                    else if (!recipe_was_autoread_with_glasses)
                    {
                        subentry.entries.listAppend("Need to " + ($item[lord spookyraven's spectacles].available_amount() == 0 ? "acquire and " : "") + "equip Lord Spookyraven's spectacles and read the recipe before you can use the quick route.");
                    }
                    else
                    {
                        //FIXME implement this differently?
                        boolean need_item_modifier = false;
                        if ($item[bottle of Chateau de Vinegar].available_amount() == 0)
                        {
                            //+booze? +food seemingly doesn't work on this one
                            subentry.entries.listAppend("Find bottle of Chateau de Vinegar from possessed wine rack in the haunted wine cellar.");
                            subentry.modifiers.listAppend("olfact wine rack");
                            need_item_modifier = true;
                            image_name = "possessed wine rack";
                        }
                        if ($item[blasting soda].available_amount() == 0)
                        {
                            subentry.entries.listAppend("Find blasting soda from the cabinet in the haunted laundry room.");
                            subentry.modifiers.listAppend("olfact cabinet");
                            need_item_modifier = true;
                            
                            if (image_name == base_quest_state.image_name)
                                image_name = "cabinet of Dr. Limpieza";
                        }
                        if (need_item_modifier)
                            subentry.modifiers.listPrepend("+item"); //Probably +item. Possibly an increasing drop.
                            
                        if ($item[bottle of Chateau de Vinegar].available_amount() > 0 && $item[blasting soda].available_amount() > 0)
                        {
                            url = "craft.php?mode=cook";
                            string line = "Cook unstable fulminate.";
                            if (!__misc_state["can cook for free"])
                                line += " (1 adventure)";
                            subentry.entries.listAppend(line);
                            image_name = "__item unstable fulminate";
                        }
                    }
                }
                if (!output_final_fight_info)
                {
                    item [location] searchables;
                    searchables[$location[the haunted kitchen]] = $item[loosening powder];
                    searchables[$location[the haunted conservatory]] = $item[powdered castoreum];
                    searchables[$location[the haunted bathroom]] = $item[drain dissolver];
                    searchables[$location[the haunted gallery]] = $item[triple-distilled turpentine];
                    searchables[$location[the haunted laboratory]] = $item[detartrated anhydrous sublicalc];
                    searchables[$location[the haunted storage room]] = $item[triatomaceous dust];
                    
                    
                    item [location] missing_searchables;
                    foreach l in searchables
                    {
                        item it = searchables[l];
                        if (it.available_amount() == 0)
                            missing_searchables[l] = it;
                    }
                    
                    if (missing_searchables.count() > 0)
                    {
                        string [int] places;
                        foreach l in missing_searchables
                        {
                            item it = searchables[l];
                            //places.listAppend(it.capitaliseFirstLetter() + " in " + l + ".");
                            places.listAppend(l.to_string().replace_string("The Haunted ", ""));
                        }
                        string line = "Scavenger hunt! ";
                        if (use_fast_route || !in_bad_moon())
                            line = "Alternatively, scavenger hunt! (likely much slower)|*";
                        //line += "Go search for:|*" + places.listJoinComponents("<hr>|*");
                        line += "Go search in the Haunted " + places.listJoinComponents(", ", "and");
                        subentry.entries.listAppend(line);
                        subentry.entries.listAppend("Read the recipe if you haven't.");
                        
                        //are these scheduled, or regular NCs?
                        //assuming scheduled for now
                        if (__misc_state["free runs available"])
                        {
                            subentry.modifiers.listAppend("free runs");
                        }
                        if (__misc_state["have hipster"])
                        {
                            subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                        }
                    }
                    else
                    {
                        subentry.entries.listClear();
                        subentry.modifiers.listClear();
                        output_final_fight_info = true;
                    }
                    
                }
                if (output_final_fight_info)
                {
                    image_name = "Demon Summon";
                    if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
                    {
                        subentry.entries.listAppend("Talk to Lord Spookyraven.");
                    }
                    else
                    {
                        subentry.modifiers.listAppend("elemental resistance");
                        subentry.entries.listAppend("Fight Lord Spookyraven.");
                        
                        if ($effect[Red Door Syndrome].have_effect() == 0 && my_meat() > 1000 && black_market_available())
                        {
                            subentry.entries.listAppend("A can of black paint can help with fighting him. Bit pricy. (1k meat)");
                        }
                    }
                }
                if (use_fast_route)
                {
                    if ($item[unstable fulminate].available_amount() == 0 && !output_final_fight_info && $item[bottle of Chateau de Vinegar].available_amount() == 0 && $item[bottle of Chateau de Vinegar].available_amount() == 0 && !recipe_will_be_autoread)
                        subentry.entries.listAppend("Remember to wear Spookyraven's spectacles/read the recipe if you haven't.");
                }
                else
                    subentry.entries.listAppend("Remember to read the recipe if you haven't.");
            }
        }
    }
    
    boolean [location] relevant_locations;
    relevant_locations[$location[the haunted ballroom]] = true;
    relevant_locations[$location[summoning chamber]] = true;
    relevant_locations[$location[the haunted wine cellar]] = true;
    relevant_locations[$location[The Haunted Boiler Room]] = true;
    relevant_locations[$location[The Haunted Laundry Room]] = true;
    foreach l in $locations[the haunted kitchen,the haunted conservatory,the haunted bathroom,the haunted gallery,the haunted laboratory,the haunted storage room]
        relevant_locations[l] = true;
    

    task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, relevant_locations));
}
