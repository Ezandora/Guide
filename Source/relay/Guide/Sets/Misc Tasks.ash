RegisterTaskGenerationFunction("SMiscTasksGenerateTasks");
void SMiscTasksGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //From tasks.ash. May be able to split off some of these into their own files:
	if (__misc_state["yellow ray available"] && __misc_state["in run"])
	{
		string [int] potential_targets;
		
		if (!have_outfit_components("Filthy Hippy Disguise") && !(get_property("sidequestOrchardCompleted") == "hippy" || get_property("sidequestOrchardCompleted") == "fratboy"))
			potential_targets.listAppend("Mysterious Island Hippy for outfit. (allows hippy store access; free redorant for +combat)");
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
			potential_targets.listAppend("Hippy/frat war outfit?");
		//fax targets?
		if (__misc_state["fax available"] || $skill[Rain Man].skill_is_usable())
		{
			potential_targets.listAppend("Anything on the fax list.");
		}
		
		if (!__quest_state["Level 10"].finished && $item[mohawk wig].available_amount() == 0)
			potential_targets.listAppend("Burly Sidekick (Mohawk wig) - speed up top floor of castle.");
		if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
			potential_targets.listAppend("Filthworms.");
		
		if (__quest_state["Boss Bat"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() <3)
		{
			if ($item[enchanted bean].available_amount() == 0 && !__misc_state["beanstalk grown"])
				potential_targets.listAppend("Beanbat. (enchanted bean, sonar-in-a-biscuit)");
			else
				potential_targets.listAppend("A bat. (sonar-in-a-biscuit)");
		}
        
        if (__misc_state["stench airport available"] && $item[filthy child leash].available_amount() == 0 && !__misc_state["familiars temporarily blocked"] && $items[ittah bittah hookah,astral pet sweater,snow suit,lead necklace].available_amount() == 0 && in_ronin() && my_path_id() != PATH_HEAVY_RAINS && my_path_id() != PATH_GELATINOUS_NOOB && my_path_id() != PATH_G_LOVER)
        {
            potential_targets.listAppend("Horrible tourist family (barf mountain) - +5 familiar weight leash.");
        }
		
		
		if (item_drop_modifier_ignoring_plants() < 234.0 && !__misc_state["in aftercore"])
			potential_targets.listAppend("Anything with 30% drop if you can't 234%. (dwarf foreman, bob racecar, drum machines, etc)");
            
        
        if (__misc_state_string["yellow ray source"] == "Unleash Cowrruption" && $effect[Cowrruption].have_effect() == 0)
        {
            potential_targets.listAppend(HTMLGenerateSpanFont("Acquire cowrruption first.", "red"));
        }
		
		optional_task_entries.listAppend(ChecklistEntryMake(__misc_state_string["yellow ray image name"], "", ChecklistSubentryMake("Fire yellow ray", "", potential_targets), 5));
	}
    
    if (__misc_state["in run"] && !have_mushroom_plot() && knoll_available() && __misc_state["can eat just about anything"] && fullness_limit() >= 4 && $item[spooky mushroom].available_amount() == 0 && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST && my_meat() >= 5000 && my_path_id() != PATH_SLOW_AND_STEADY && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
    {
        string [int] description;
        description.listAppend("For spooky mushrooms, to cook a grue egg omelette. (epic food)|Will " + ((my_meat() < 5000) ? "need" : "cost") + " 5k meat. Plant a spooky spore.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item spooky mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Possibly plant a mushroom plot", "", description), 5));
    
    }
	
	if (!have_outfit_components("Filthy Hippy Disguise") && __misc_state["mysterious island available"] && __misc_state["in run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].state_boolean["War started"] && !have_outfit_components("Frat Warrior Fatigues") && my_path_id() != PATH_EXPLOSION)
	{
		item [int] missing_pieces = missing_outfit_components("Filthy Hippy Disguise");
        
		string [int] description;
		string [int] modifiers;
        boolean should_be_future_task = false;
        
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
        string next_line_intro = "";
        if (!__misc_state["yellow ray almost certainly impossible"])
        {
            description.listAppend("Yellow-ray a hippy in the hippy camp if you can.");
            next_line_intro = "Otherwise, ";
        }
        else if (my_level() < 9)
            should_be_future_task = true;
        
		if (my_level() >= 9)
		{
			description.listAppend((next_line_intro + "run -combat " + (next_line_intro == "" ? " in the hippy camp" : "there") + ".").capitaliseFirstLetter());
			modifiers.listAppend("-combat");
		}
		else
		{
			description.listAppend((next_line_intro + "wait for level 9 for the non-combats.").capitaliseFirstLetter());
		}
        if ($familiar[slimeling].familiar_is_usable())
            modifiers.listAppend("slimeling?");
            
        ChecklistEntry entry = ChecklistEntryMake("__item filthy knitted dread sack", "island.php", ChecklistSubentryMake("Acquire a filthy hippy disguise", modifiers, description), $locations[hippy camp]);
        if (should_be_future_task)
            future_task_entries.listAppend(entry);
        else
            optional_task_entries.listAppend(entry);
	}
    
    if (__misc_state["in run"] && (inebriety_limit() == 0 || my_path_id() == PATH_SLOW_AND_STEADY) && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
    {
        string url = "";
        string [int] modifiers;
		if (__misc_state["have hipster"] && get_property_int("_hipsterAdv") < 7)
		{
			modifiers.listAppend(__misc_state_string["hipster name"]);
		}
        string [int] description = listMake("At the end of the day, enter a combat, but don't finish it. Rollover will end it for you.", "This gives an extra chance to look for a non-combat.");
        if (__quest_state["Level 3"].in_progress)
        {
            description.listAppend("Try using it to explore the typical tavern.");
            url = "cellar.php";
        }
		optional_task_entries.listAppend(ChecklistEntryMake("__item dead guy's watch", url, ChecklistSubentryMake("Use rollover runaway", modifiers, description), 8));
    }
    
    //I'm not sure if you ever need a frat boy ensemble in-run, even if you're doing the hippy side on the war? If you need war hippy fatigues, the faster (?) way is acquire hippy outfit -> frat warrior fatigues -> start the war / use desert adventure for hippy fatigues. But if they're sure...
	if (!have_outfit_components("Frat boy ensemble") && __misc_state["mysterious island available"] && __misc_state["in run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].started && $location[frat house].turnsAttemptedInLocation() >= 3 && ($location[frat house].combatTurnsAttemptedInLocation() > 0 || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Murder by Death") || $location[frat house].noncombat_queue.contains_text("I Just Wanna Fly") || $location[frat house].noncombat_queue.contains_text("From Stoked to Smoked") || $location[frat house].noncombat_queue.contains_text("Purple Hazers")))
    {
        //they don't have a frat boy ensemble, but they adventured in the pre-war frat house
        //I'm assuming this means they want the outfit, for whatever reason. So, suggest it, until the level 12 starts:
		item [int] missing_pieces = missing_outfit_components("Frat boy ensemble");
        
		string [int] description;
		string [int] modifiers;
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
        if (my_level() >= 9)
        {
            modifiers.listAppend("-combat");
            description.listAppend("Run -combat.");
        }
        else
            description.listAppend("Possibly wait until level 9, to unlock NCs in the area.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item orcish frat-paddle", "island.php", ChecklistSubentryMake("Acquire a frat boy ensemble?", modifiers, description), $locations[frat house]));
    }
		
	if ($item[strange leaflet].available_amount() > 0 && __misc_state["in run"])
	{
        boolean leaflet_quest_probably_finished = false;
        
        if ($item[giant pinky ring].available_amount() > 0) //invalid in casual, but eh
            leaflet_quest_probably_finished = true;
        if ($item[Frobozz Real-Estate Company Instant House (TM)].available_amount() > 0 || get_dwelling() == $item[Frobozz Real-Estate Company Instant House (TM)])
            leaflet_quest_probably_finished = true;
        
        if (!leaflet_quest_probably_finished)
        {
            string [int] description;
            boolean future_task = false;
            description.listAppend("Quests Menu" + __html_right_arrow_character + "Leaflet (With Stats)");
            
            if (__misc_state["need to level"])
            {
                item relevant_lamp;
                effect relevant_lamp_effect;
                if (my_primestat() == $stat[muscle])
                {
                    relevant_lamp = $item[red LavaCo Lamp&trade;];
                    relevant_lamp_effect = $effect[Red Menace];
                }
                else if (my_primestat() == $stat[mysticality])
                {
                    relevant_lamp = $item[blue LavaCo Lamp&trade;];
                    relevant_lamp_effect = $effect[Blue Eyed Devil];
                }
                else if (my_primestat() == $stat[moxie])
                {
                    relevant_lamp = $item[green LavaCo Lamp&trade;];
                    relevant_lamp_effect = $effect[Green Peace];
                }
                if (relevant_lamp != $item[none] && relevant_lamp_effect != $effect[none] && relevant_lamp.available_amount() > 0 && relevant_lamp_effect.have_effect() == 0)
                {
                    future_task = true;
                    description.listAppend("Possibly wait until tomorrow. The " + relevant_lamp + " bonus will give extra stats.");
                }
                else if (relevant_lamp_effect.have_effect() > 0)
                    description.listAppend("Soon, before the lava lamp effect runs out.");
                
                item [int] items_equipping = generateEquipmentToEquipForExtraExperienceOnStat(my_primestat());
                if (items_equipping.count() > 0)
                    description.listAppend("Could equip " + items_equipping.listJoinComponents(", ", "or") + " for more stats.");
            }
            
            ChecklistEntry entry = ChecklistEntryMake("__item strange leaflet", "", ChecklistSubentryMake("Strange leaflet quest", "", description));
            if (future_task)
                future_task_entries.listAppend(entry);
            else
                optional_task_entries.listAppend(entry);
        }
	}
	

	

    
    boolean have_spaghetti_breakfast = (($skill[spaghetti breakfast].skill_is_usable() && !get_property_boolean("_spaghettiBreakfast")) || $item[spaghetti breakfast].available_amount() > 0);
    if (__misc_state["in run"] && __misc_state["can eat just about anything"] && !get_property_boolean("_spaghettiBreakfastEaten") && my_fullness() == 0 && have_spaghetti_breakfast && my_path_id() != PATH_SLOW_AND_STEADY)
    {
    
        string [int] adventure_gain;
        adventure_gain[1] = "1";
        adventure_gain[2] = "1-2";
        adventure_gain[3] = "2";
        adventure_gain[4] = "2-3";
        adventure_gain[5] = "3";
        adventure_gain[6] = "3-4";
        adventure_gain[7] = "4";
        adventure_gain[8] = "4-5";
        adventure_gain[9] = "5";
        adventure_gain[10] = "5-6";
        adventure_gain[11] = "6";
        
        string adventures_gained = adventure_gain[MAX(1, MIN(11, my_level()))];
        
        string level_string = "";
        if (my_level() < 11)
            level_string = " Gain levels for more.";
        string url = "inventory.php?which=1";
        string [int] description;
        description.listAppend("Inedible if you eat anything else.|" + adventures_gained + " adventures/fullness." + level_string);
        if ($item[spaghetti breakfast].available_amount() == 0)
        {
            description.listAppend("Obtained by casting spaghetti breakfast.");
            url = "skills.php";
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item spaghetti breakfast", url, ChecklistSubentryMake("Eat " + $item[spaghetti breakfast] + " first", "", description), 8));
    }
    
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING && my_path_id() != PATH_NUCLEAR_AUTUMN)
    {
        item dwelling = get_dwelling();
        item upgraded_dwelling = $item[none];
        if ($item[Frobozz Real-Estate Company Instant House (TM)].available_amount() > 0 && (dwelling == $item[big rock] || dwelling == $item[Newbiesport&trade; tent] || get_dwelling() == $item[cottage]) && my_path_id() != PATH_G_LOVER)
        {
            upgraded_dwelling = $item[Frobozz Real-Estate Company Instant House (TM)];
        }
        else if ($item[Newbiesport&trade; tent].available_amount() > 0 && dwelling == $item[big rock] && my_path_id() != PATH_G_LOVER)
        {
            upgraded_dwelling = $item[Newbiesport&trade; tent];
        }
        if (upgraded_dwelling != $item[none])
        {
            string [int] reasons;
            reasons.listAppend("rollover");
            
            if (__misc_state_int["total free rests possible"] > 0)
                reasons.listAppend("free rests");
            
            string description = "Better HP/MP restoration via " + reasons.listJoinComponents(", ", "and") + ".";
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + upgraded_dwelling, "inventory.php?which=3", ChecklistSubentryMake("Use " + upgraded_dwelling, "", description), 8));
            
        }
    }
    
    if (__misc_state["in run"] && $item[dry cleaning receipt].available_amount() > 0)
    {
        item receipt_item = $item[none];
        if (my_primestat() == $stat[muscle])
            receipt_item = $item[power sock];
        else if (my_primestat() == $stat[mysticality])
            receipt_item = $item[wool sock];
        else if (my_primestat() == $stat[moxie])
            receipt_item = $item[moustache sock];
        if (receipt_item != $item[none] && receipt_item.available_amount() == 0)
        {
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + $item[dry cleaning receipt], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[dry cleaning receipt], "", "For " + receipt_item + " accessory."), 8));
        }
    }
}
