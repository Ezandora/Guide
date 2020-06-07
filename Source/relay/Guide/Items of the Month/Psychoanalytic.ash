

void IOTMPShadyPastGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($item[White Dragon Fang].available_amount() == 0)
    {
        boolean can_acquire_taijijian = ($item[strange goggles].available_amount() > 0 || $item[toy taijijian].available_amount() > 0 || !in_ronin());
        if ($item[magical battery].available_amount() > 0 && can_acquire_taijijian)
        {
            description.listAppend("To make the White Dragon Fang, meatpaste together the toy taijijian with the magical battery.");
        }
    }
    
    string last_combat = $location[chinatown tenement].lastCombatInLocation();
    if ($location[chinatown tenement].combat_queue.contains_text("White Bone Demon") && description.count() == 0) //somewhat limited way of detecting that we are finished
        return;
    if ($item[Test site key].available_amount() > 0)
    {
        //Last segment:
        
        int gold_pieces_needed = MAX(0, 30 - $item[gold piece].available_amount());
        if (last_combat == "the server")
        {
            description.listAppend("Fight the White Bone Demon.");
        }
        else if (gold_pieces_needed > 0)
        {
            //at least one gold piece from a desperate gold farmer is under 21.89% drop rate
            //needs spading
            description.listAppend("Adventure in the chinatown tenement, acquire " + pluralise(gold_pieces_needed, "more gold piece", "more gold pieces") + ".");
            modifiers.listAppend("+400%? item");
            
            if (__misc_state["have olfaction equivalent"])
                modifiers.listAppend("olfact desperate gold farmer");
        }
        else
        {
            description.listAppend("Adventure in the chinatown tenement, fight the server.|Once the server's panel falls off, use the strange goggles.");
        }
    }
    else if ($item[CEO office card].available_amount() > 0)
    {
        //Use to see wheels within wheels.
        description.listAppend("Use CEO office card.");
    }
    else if ($items[makeshift yakuza mask,Novelty tattoo sleeves].items_missing().count() == 0)
    {
        //Visit the first floor.
        item [int] equip_items;
        foreach it in $items[makeshift yakuza mask,novelty tattoo sleeves]
        {
            if (it.equipped_amount() == 0)
                equip_items.listAppend(it);
        }
        if (equip_items.count() > 0 && $location[1st floor\, shiawase-mitsuhama building].turnsAttemptedInLocation() == 0)
        {
            description.listAppend("Equip " + equip_items.listJoinComponents(", ", "and") + ".");
        }
        else
        {
            description.listAppend("Adventure on the floors of the Shiawase-Mitsuhama building, acquire and use cards.");
            
            foreach it in $items[zaibatsu level 2 card, zaibatsu level 3 card]
            {
                if (it.available_amount() == 0)
                    continue;
                description.listAppend("Use " + it + ".");
            }
        }
    }
    else if ($item[strange goggles].available_amount() > 0)
    {
        //Make yakuza mask.
        if ($item[makeshift yakuza mask].available_amount() == 0)
        {
            string line = "Assemble a makeshift yakuza mask with items from the chinatown shops.";
            
            item [int] missing_parts_list = missingComponentsToMakeItem($item[makeshift yakuza mask]);
            if (missing_parts_list.count() == 0)
                line = "Assemble a makeshift yakuza mask.|(rhinoceros horn + rhinoceros horn) + (furry pink pillow + bottle of limeade)";
            else
                line += "|Missing " + missing_parts_list.listJoinComponents(", ", "and") + ".";
            
            description.listAppend(line);
        }
        if ($item[Novelty tattoo sleeves].available_amount() == 0)
        {
            description.listAppend("Buy novelty tattoo sleeves from the chinatown shops.");
        }
    }
    else if ($item[zaibatsu lobby card].available_amount() > 0)
    {
        //Triad factory.
        description.listAppend("Adventure in the sewer triad factory, defeat the Sierpinski brothers.");
        description.listAppend("Run +item for a possible magical battery.");
        modifiers.listAppend("+item");
    }
    else
    {
        //Start of quest.
        description.listAppend("Adventure in the Chinatown shops, defeat a yakuza courier.");
    }
    

	optional_task_entries.listAppend(ChecklistEntryMake("chinatown", "place.php?whichplace=junggate_1", ChecklistSubentryMake("The Suspicious-Looking Guy's Shady Past", modifiers, description),$locations[chinatown shops, chinatown tenement, triad factory,1st floor\, shiawase-mitsuhama building,2nd floor\, shiawase-mitsuhama building,3rd floor\, shiawase-mitsuhama building]));
}

void IOTMPOldManGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($location[The Old Man's Bathtime Adventures].lastNoncombatInLocation() == "Journey's End") //somewhat limited way of detecting that we are finished
        return;
    
    description.listAppend("Sail the seas. Try to one-hit kill the sea monsters.");
    
    if ($item[Bloodbath].available_amount() == 0)
        description.listAppend("Need to finish the area with 50+ crew to acquire Bloodbath.");
    else if ($item[ornamental sextant].available_amount() == 0)
        description.listAppend("Need to finish the area with 37+ crew to acquire ornamental sextant.");
    else if ($item[miniature deck cannon].available_amount() == 0)
        description.listAppend("Need to finish the area with [24 to 36] crew to acquire miniature deck cannon.");
    else if ($item[Foam naval trousers].available_amount() == 0)
        description.listAppend("Need to finish the area with [24 to 36] crew to acquire Foam naval trousers.");
    else if ($item[Foam commodore's hat].available_amount() == 0)
        description.listAppend("Need to finish the area with [24 to 36] crew to acquire Foam commodore's hat.");
    
    description.listAppend("Choose +crew non-combat options, add monsters if you can.");
    
    
    monster olfacted_monster = get_property_monster("olfactedMonster");
    if ($effect[on the trail].have_effect() == 0)
        olfacted_monster = $monster[none];
    boolean olfacted_relevant_monster = ($monsters[ferocious roc,giant man-eating shark,Bristled Man-O-War,The Cray-Kin,Deadly Hydra] contains olfacted_monster);
    
    if (__misc_state["have olfaction equivalent"] && !olfacted_relevant_monster)
    {
        description.listAppend("Olfact any monster that is not a fearsome giant squid.");
        modifiers.listAppend("olfaction");
    }
        
    if (my_basestat($stat[mysticality]) >= 200)
    {
        if ($item[Mesmereyes&trade; contact lenses].equipped_amount() == 0)
        {
            description.listAppend("Wear " + $item[Mesmereyes&trade; contact lenses] + ".");
        }
    }
    else
    {
        if ($item[Attorney's badge].equipped_amount() == 0)
        {
            description.listAppend("Wear " + $item[Attorney's badge] + ".");
        }
        description.listAppend("Possibly level mysticality to 200 to wear " + $item[Mesmereyes&trade; contact lenses] + ", makes this area much easier.");
    }
    
    if ($item[Young Man's Crew Sequester].available_amount() > 0)
        description.listAppend("Young Man's Crew Sequester available. (+5 crew)");
    if ($item[Young Man's Cargo Load].available_amount() > 0)
        description.listAppend("Young Man's Cargo Load available. (+4 crayons, +16 bubbles)");
    
    //very limited potato detection:
    if (my_familiar() != $familiar[levitating potato] && !(my_familiar() == $familiar[fancypants scarecrow] && ($slot[familiar].equipped_item() == $item[swashbuckling pants] || $slot[familiar].equipped_item() == $item[spangly mariachi pants]))  && !(my_familiar() == $familiar[mad hatrack] && $slot[familiar].equipped_item() == $item[spangly sombrero]))
        description.listAppend("Run a potato familiar of some kind.");
    
    
	optional_task_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "", ChecklistSubentryMake("The Old Man's Bathtime Adventure", modifiers, description),$locations[The Old Man's Bathtime Adventures]));
}

void IOTMPMeatGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($location[The Nightmare Meatrealm].lastCombatInLocation() == "The Beefhemoth") //somewhat limited way of detecting that we are finished
        return;
        
    modifiers.listAppend("+meat");
    description.listAppend("Adventure until you find the beefhemoth, defeat him.");
    if ($items[the sword in the steak, meatcleaver].available_amount() == 0)
        description.listAppend("The Sword in the Steak is from a 0.1% likelyhood non-combat.|To find it, run away from monsters, preferrably with greatest american pants/navel ring of navel gazing.");
    if ($item[meatcleaver].available_amount() == 0 && $item[the sword in the steak].available_amount() > 0)
    {
        if (my_buffedstat($stat[muscle]) < 1000)
            description.listAppend("To pull the sword from the steak, buff muscle to 1000.");
        else
            description.listAppend("Pull the sword from the steak, adventurer.");
    }
        
        
	optional_task_entries.listAppend(ChecklistEntryMake("meat", "place.php?whichplace=junggate_6", ChecklistSubentryMake("The Meatsmith's Brainspace", modifiers, description),$locations[The Nightmare Meatrealm]));
}

void IOTMPGourdGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($location[the gourd!].lastCombatInLocation() == "Fnord the Unspeakable") //This should work for termination detection?
        return;
        
    modifiers.listAppend("+item?");
    description.listAppend("Adventure in the gourd.");
    if ($item[truthsayer].available_amount() == 0)
    {
        string [int] components;
        boolean [item] items_implicitly_have;
        if ($item[loose blade].available_amount() > 0)
        {
            items_implicitly_have[$item[goblin collarbone]] = true;
            items_implicitly_have[$item[sharp tin strip]] = true;
        }
        if ($item[goblin bone hilt].available_amount() > 0)
        {
            items_implicitly_have[$item[goblin collarbone]] = true;
            items_implicitly_have[$item[wad of spider silk]] = true;
        }
        if ($item[sticky sword blade].available_amount() > 0)
        {
            items_implicitly_have[$item[sharp tin strip]] = true;
            items_implicitly_have[$item[wad of spider silk]] = true;
        }
        foreach it in $items[sharp tin strip, wad of spider silk, goblin collarbone]
        {
            string line = it;
            if (it.available_amount() == 0 && !(items_implicitly_have contains it))
                line = HTMLGenerateSpanFont(line, "gray");
            components.listAppend(line);
        }
        description.listAppend("Truthsayer is (" + components.listJoinComponents(" + ") + "), found from gourd monsters.");
    }
    
        
	optional_task_entries.listAppend(ChecklistEntryMake("__item gourd potion", "place.php?whichplace=junggate_2", ChecklistSubentryMake("The Gourd", modifiers, description),$locations[The gourd!]));
}

void IOTMPCrackpotGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    //Despair, rage, envy. Anger, fear, doubt, regret.
    string url = "place.php?whichplace=junggate_3";
    string image_name = "__item red pixel";
    
    boolean need_byte_sword = !($item[byte].available_amount() + $item[byte].storage_amount() > 0 || $item[flickering pixel].available_amount() + $item[flickering pixel].storage_amount() >= 8);
    
    if ($item[flickering pixel].available_amount() == 8)
    {
        description.listAppend("Use eight flickering pixels to acquire the sword, byte.");
    }
    
    string [int] bosses_remaining;
    
    if ($location[anger man's level].lastCombatInLocation() != "Anger man")
        bosses_remaining.listAppend("anger man");
    if ($location[fear man's level].lastCombatInLocation() != "Fear man")
        bosses_remaining.listAppend("fear man");
    if ($location[doubt man's level].lastCombatInLocation() != "Doubt man")
        bosses_remaining.listAppend("doubt man");
    if ($location[regret man's level].lastCombatInLocation() != "Regret man")
        bosses_remaining.listAppend("regret man");
        
    if (bosses_remaining.count() == 0 && description.count() == 0)
        return;
        
    if (__last_adventure_location == $location[anger man's level] && $location[anger man's level].lastCombatInLocation() != "Anger man")
    {
        description.listAppend("Adventure in anger man's level, defeat the boss.");
        string [int] stats_needed_to_complete_zone;
        string [int] stats_needed_for_flickering_pixel;
        foreach s in $stats[muscle, mysticality, moxie]
        {
            if (s.my_buffedstat() < 50)
            {
                stats_needed_to_complete_zone.listAppend(s.to_string().to_lower_case());
            }
            if (s.my_buffedstat() < 500)
            {
                stats_needed_for_flickering_pixel.listAppend(s.to_string().to_lower_case());
            }
        }
        
        float resistance = numeric_modifier("hot resistance");
        int resistance_needed = MAX(0, floor(25 - resistance));
        if (resistance < 25.0 && need_byte_sword)
            description.listAppend("Need " + resistance_needed + " more hot resistance for the first flickering pixel.");
        
        if (stats_needed_to_complete_zone.count() > 0)
            description.listAppend("Need 50 " + stats_needed_to_complete_zone.listJoinComponents(", ", "and") + " to pass first test.");
        if (stats_needed_for_flickering_pixel.count() > 0 && need_byte_sword)
            description.listAppend("Need 500 " + stats_needed_for_flickering_pixel.listJoinComponents(", ", "and") + " for the second flickering pixels.");
            
            
    }
    else if (__last_adventure_location == $location[fear man's level] && $location[fear man's level].lastCombatInLocation() != "Fear man")
    {
        description.listAppend("Adventure in fear man's level, defeat the boss.");
        
        //50 moxie to complete
        //300 moxie for first flickering
        //25 spooky res for second flickering
        
        if (my_buffedstat($stat[moxie]) < 50)
            description.listAppend("Need 50 total moxie pass first test.");
            
        if (my_buffedstat($stat[moxie]) < 300 && need_byte_sword)
            description.listAppend("Need 300 total moxie for the first flickering pixel.");
            
        float resistance = numeric_modifier("spooky resistance");
        int resistance_needed = MAX(0, floor(25 - resistance));
        if (resistance < 25.0 && need_byte_sword)
            description.listAppend("Need " + resistance_needed + " more spooky resistance for the second flickering pixel.");
    }
    else if (__last_adventure_location == $location[doubt man's level] && $location[doubt man's level].lastCombatInLocation() != "Doubt man")
    {
        description.listAppend("Adventure in doubt man's level, defeat the boss.");
            
        //weapon damage >= 100 to complete
        //HP > 100 to complete
        //weapon damage >= 276(?) for first flickering
        //HP >= 1000 for second flickering
        
        int weapon_damage = numeric_modifier("weapon damage").floor();
        if (weapon_damage < 100)
            description.listAppend("Need " + (100 - weapon_damage) + " more weapon damage to pass first test.");
        if (weapon_damage < 276 && need_byte_sword)
            description.listAppend("Need " + (276 - weapon_damage) + "(?) more weapon damage for the first flickering pixel.");
        
        if (my_hp() < 100)
            description.listAppend("Need 100 total HP to pass second test.");
        if (my_hp() < 1000 && need_byte_sword)
            description.listAppend("Need 1000 total HP for the second flickering pixel.");
    }
    else if (__last_adventure_location == $location[regret man's level] && $location[regret man's level].lastCombatInLocation() != "Regret man")
    {
        description.listAppend("Adventure in regret man's level, defeat the boss.");
        
        //MP >= 100 to complete
        //total elemental damage >= 50 to complete
        //MP >= 1000 for first flickering
        //total elemental damage >= 100 for second flickering
        
        if (my_mp() < 100)
            description.listAppend("Need 100 total MP to pass first test.");
        if (my_mp() < 1000 && need_byte_sword)
            description.listAppend("Need 1000 total MP for the first flickering pixel.");
        //int total_elemental_damage = numeric_modifier("cold damage") + numeric_modifier("hot damage") + numeric_modifier("sleaze damage") + numeric_modifier("spooky damage") + numeric_modifier("stench damage");
        
        //FIXME I am not sure if this is correct. How exactly does this test work?
        string [int] missing_second_test;
        string [int] missing_second_pixel_test;
        foreach e in $strings[cold,hot,sleaze,spooky,stench]
        {
            string element_html_id = "r_element_" + e;
            int damage = numeric_modifier(e + " damage").floor();
            if (damage < 50)
                missing_second_test.listAppend(HTMLGenerateSpanOfClass((50 - damage) + " more " + e, element_html_id));
            if (damage < 60)
                missing_second_pixel_test.listAppend(HTMLGenerateSpanOfClass((60 - damage) + " more " + e, element_html_id));
            
        }
        if (missing_second_test.count() > 0)
            description.listAppend("Need " + missing_second_test.listJoinComponents(", ", "and") + " damage to pass the second test.");
        if (missing_second_pixel_test.count() > 0)
            description.listAppend("Need " + missing_second_pixel_test.listJoinComponents(", ", "and") + " damage for the second flickering pixel.");
    }
    
    string await = " await.";
    if (bosses_remaining.count() == 1)
        await = " awaits.";
    if (bosses_remaining.count() > 0)
        description.listAppend(bosses_remaining.listJoinComponents(", ", "and").capitaliseFirstLetter() + await);
    else if ($item[flickering pixel].available_amount() == 8)
    {
        url = "inventory.php?ftext=flickering+pixel";
        image_name = "__item flickering pixel";
    }
    
    if (__misc_state["in run"])
        description.listAppend("(this isn't ascension relevant after you've gotten a digital key)");
        
	optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake("The Crackpot Mystic's Psychoses", modifiers, description),$locations[anger man's level, fear man's level, doubt man's level, regret man's level]));
}



void IOTMPJickGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($item[sword of procedural generation].available_amount() > 0)
        return;
        
    description.listAppend("Fight skeletons.");
    description.listAppend("Make sure you have a monster manuel first; once this tower is complete, there's no way to get these factoids ever again.");
    
    //FIXME be more specific
        
	optional_task_entries.listAppend(ChecklistEntryMake("__item skeleton", "", ChecklistSubentryMake("Jick's Obsessions", modifiers, description),$locations[the tower of procedurally-generated skeletons]));
}



void IOTMPArtistGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    
    foreach e in $effects[My Breakfast With Andrea,The Champion's Breakfast,Tiffany's Breakfast,Breakfast Clubbed]
    {
        if (e.have_effect() > 0)
            return;
    }
    //Let's see.
    //The way this quest works is, you find utensils in the kitchen drawer. (or the mall)
    //Then, you adventure in the grocery bag, and use a utensil on the monsters.
    //The utensil you use on the monster determines breakfast.
    
    
    description.listAppend("Make a breakfast.");
    description.listAppend("To do this, you find utensils in the kitchen drawer, and use them, in combat, on the five different foods in the grocery bag.|Which utensil you use on which food helps determine your breakfast.");
    
    
    string [int] missing_utensils;
    foreach it in $items[Artist's Butterknife of Regret,Artist's Cookie Cutter of Loneliness,Artist's Cr&egrave;me Brul&eacute;e Torch of Fury,Artist's Spatula of Despair,Artist's Whisk of Misery]
    {
        if (it.available_amount() > 0)
            continue;
        string utensil_readable_name = it.to_string().replace_string("Artist's ", "");
        
        missing_utensils.listAppend(utensil_readable_name);
    }
    
    if (missing_utensils.count() > 0)
    {
        modifiers.listAppend("+300% item");
        description.listAppend("Find utensils in the kitchen drawer, or buy in the mall.|Utensils missing:|*" + missing_utensils.listJoinComponents(", ", "and") + ".");
    }
    
    string [int] breakfasts;
    
    string breakfast_line;
    //Meat & Knife, Bread & Knife, Batter & Spatula, Eggs & Whisk, Potatoes & Knife
    breakfast_line += "My Breakfast With Andrea: (+meat)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Butterknife";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Butterknife";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Spatula";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Whisk";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Butterknife";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    //Meat & Cutter, Bread & Torch, Batter & Whisk, Eggs & Torch, Potatoes & Torch
    breakfast_line += "<hr>";
    breakfast_line += "The Champion's Breakfast: (+init)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Whisk";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    //Meat & Spatula, Bread & Cutter, Batter & Cutter, Eggs & Spatula, Potatoes & Whisk
    breakfast_line += "<hr>";
    breakfast_line += "Tiffany's Breakfast: (+item)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Spatula";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Spatula";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Whisk";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    
    //It's actually anything, but let's pick one:
    //Meat & Torch, Bread & Whisk, Batter & Knife, Eggs & Cutter, Potatoes & Spatula
    breakfast_line += "<hr>";
    breakfast_line += "Breakfast Clubbed: (+ML)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Whisk";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Butterknife";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Spatula";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    description.listAppend("There are four different breakfasts possible:" + HTMLGenerateIndentedText(breakfasts));
    
    if ($item[Ginsu&trade;].available_amount() == 0)
        description.listAppend("Making all four breakfasts in the same ascension lets you acquire the sword, " + $item[Ginsu&trade;] + ".");
        
	optional_task_entries.listAppend(ChecklistEntryMake("__effect My Breakfast With Andrea", "place.php?whichplace=junggate_5", ChecklistSubentryMake("The Pretentious Artist's Obsession", modifiers, description),$locations[a kitchen drawer, a grocery bag]));
}

RegisterTaskGenerationFunction("IOTMPsychoanalyticGenerateTasks");
void IOTMPsychoanalyticGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!get_property_boolean("_psychoJarUsed"))
        return;
    //Can't detect which jar was used, so check where they've been:
    if ($locations[chinatown shops, chinatown tenement, triad factory,1st floor\, shiawase-mitsuhama building,2nd floor\, shiawase-mitsuhama building,3rd floor\, shiawase-mitsuhama building] contains __last_adventure_location)
    {
        //√
        IOTMPShadyPastGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[The Old Man's Bathtime Adventures] contains __last_adventure_location)
    {
        //√
        IOTMPOldManGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[The Nightmare Meatrealm] contains __last_adventure_location)
    {
        IOTMPMeatGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[The gourd!] contains __last_adventure_location)
    {
        IOTMPGourdGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[anger man's level, fear man's level, doubt man's level, regret man's level] contains __last_adventure_location)
    {
        //√
        IOTMPCrackpotGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[the tower of procedurally-generated skeletons] contains __last_adventure_location)
    {
        IOTMPJickGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[a kitchen drawer, a grocery bag] contains __last_adventure_location)
    {
        //√
        IOTMPArtistGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
}
