import "relay/Guide/Support/Counter.ash"

void SCountersInit()
{
    CountersInit();
}

string [int] SCountersGenerateDescriptionForRainMonster()
{
    string [int] description;
    
    string last_terrain = __last_adventure_location.environment;
    
    string [int] waterbending_skills_can_cast;
    
    if ($effect[Personal Thundercloud].have_effect() == 0 && $skill[Thundercloud].skill_is_usable())
        waterbending_skills_can_cast.listAppend("Thundercloud");
    
    if ($effect[The Rain In Loathing].have_effect() == 0 && $skill[Rainy Day].skill_is_usable())
        waterbending_skills_can_cast.listAppend("Rainy Day");
    
    int water_level_modifier = numeric_modifier("water level");
    
    string [string][int] monster_for_terrain_depth;
    int [string] base_depth_for_terrain;
    
    foreach terrain in $strings[underground,indoor,outdoor]
    {
        monster_for_terrain_depth[terrain][1] = "giant isopod";
        monster_for_terrain_depth[terrain][2] = "gourmet gourami";
        monster_for_terrain_depth[terrain][3] = "freshwater bonefish";
        monster_for_terrain_depth[terrain][4] = "alley catfish";
        monster_for_terrain_depth[terrain][5] = "piranhadon";
    }
    base_depth_for_terrain["underground"] = 5;
    base_depth_for_terrain["indoor"] = 3;
    base_depth_for_terrain["outdoor"] = 1;
    monster_for_terrain_depth["underground"][6] = "giant tardigrade";
    monster_for_terrain_depth["indoor"][6] = "aquaconda";
    monster_for_terrain_depth["outdoor"][6] = "storm cow";
    
    string [string] monster_descriptions;
    monster_descriptions["giant isopod"] = "fishbone";
    monster_descriptions["freshwater bonefish"] = "2x fishbone";
    monster_descriptions["piranhadon"] = "3x fishbone";
    monster_descriptions["gourmet gourami"] = "+init potion";
    monster_descriptions["alley catfish"] = "-washaway potion";
    
    //init potion
    //-washaway potion
    //
    
    monster_descriptions["giant tardigrade"] = "thunder skill";
    monster_descriptions["aquaconda"] = "rain skill";
    monster_descriptions["storm cow"] = "lightning skill";
    
    if (get_campground()[$item[Little Geneticist DNA-Splicing Lab]] > 0 && mafiaIsPastRevision(13918) && !get_property_boolean("_dnaHybrid") && $effect[Human-Fish Hybrid].have_effect() == 0 && !__misc_state["familiars temporarily blocked"])
    {
        //FIXME all once spaded
        //NOT giant isopod
        //gourmet gourami?
        //freshwater bonefish
        //alley catfish
        //piranhadon
        foreach s in $strings[gourmet gourami,freshwater bonefish,alley catfish,piranhadon]
        {
            monster_descriptions[s] = monster_descriptions[s] + " (fish DNA)";
        }
    }
    
    
    if (my_mp() > 50)
    {
        monster_descriptions["storm cow"] += HTMLGenerateSpanFont(", burn MP to 50 to survive", "red");
    }
    
    boolean have_usable_last_terrain = (last_terrain == "outdoor" || last_terrain == "indoor" || last_terrain == "underground");
    foreach terrain in $strings[outdoor,indoor,underground]
    {
        int depth_min = base_depth_for_terrain[terrain] + water_level_modifier;
        int depth_max = depth_min + 1;
        
        depth_min = clampi(depth_min, 1, 6);
        depth_max = clampi(depth_max, 1, 6);
        
        string [int] terrain_monsters;
        string line = monster_for_terrain_depth[terrain][depth_min];
        //if (monster_descriptions contains line)
            //line += " (" + monster_descriptions[line] + ")";
        if (monster_descriptions contains line)
            line = monster_descriptions[line];
        if (last_terrain == terrain && (__last_adventure_location.recommended_stat < 40 || depth_min == depth_max))
            line = HTMLGenerateSpanOfClass(line, "r_bold");
        terrain_monsters.listAppend(line);
        
        if (depth_min != depth_max)
        {
            line = monster_for_terrain_depth[terrain][depth_max];
            //if (monster_descriptions contains line)
                //line += " (" + monster_descriptions[line] + ")";
            if (monster_descriptions contains line)
                line = monster_descriptions[line];
            if (last_terrain == terrain && __last_adventure_location.recommended_stat >= 40)
                line = HTMLGenerateSpanOfClass(line, "r_bold");
            terrain_monsters.listAppend(line);
        }
        
        line = terrain.capitaliseFirstLetter() + ": ";
        if (!have_usable_last_terrain || last_terrain == terrain)
            line = HTMLGenerateSpanOfClass(line, "r_bold");
        line += terrain_monsters.listJoinComponents(", ", "or");
        //if (last_terrain == terrain)
            //line = HTMLGenerateSpanOfClass(line, "r_bold");
        description.listAppend(line);
    }
    
    if (waterbending_skills_can_cast.count() > 0)
        description.listAppend("Can cast " + waterbending_skills_can_cast.listJoinComponents(", ", "and") + " for deeper water.");
    
    
    return description;
}

void SCountersGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
    string [string] window_image_names;
    window_image_names["Nemesis Assassin"] = "__familiar Penguin Goodfella"; //technically not always a penguin, but..
    window_image_names["Bee"] = "__effect Float Like a Butterfly, Smell Like a Bee"; //bzzz!
    window_image_names["Holiday Monster"] = "__familiar hand turkey";
    if (getHolidaysToday()["El Dia De Los Muertos Borrachos"])
        window_image_names["Holiday Monster"] = "__item corpse island iced tea";
    window_image_names["Rain Monster"] = "__familiar personal raincloud";
    window_image_names["WoL Monster"] = "__effect Cowrruption";
    window_image_names["Digitize Monster"] = "__item source essence";
    window_image_names["Romantic Monster"] = "__familiar " + __misc_state_string["obtuse angel name"];
    //window_image_names["Event Monster"] = ""; //no idea
    
    
    
    boolean [string] counter_blacklist = $strings[Semi-rare]; //Romantic Monster,
    boolean [string] non_range_whitelist = $strings[Digitize Monster];
    
    string [int] all_counter_names = CounterGetAllNames(true);
    
    foreach key in all_counter_names
    {
        string window_name = all_counter_names[key];
        if (window_name == "")
            continue;
        if (counter_blacklist contains window_name)
            continue;
        
        Counter c = CounterLookup(window_name, ErrorMake(), true);
        if (!c.CounterIsRange() && !(non_range_whitelist contains window_name))
            continue;
        boolean counter_is_range = c.CounterIsRange();
        Vec2i turn_range = c.CounterGetWindowRange();
        int next_exact_turn = c.CounterGetNextExactTurn();
        
        if (counter_is_range && !(turn_range.x <= 10 && from_task) && !(turn_range.x > 10 && !from_task) && window_name != "Romantic Monster")
            continue;
        
        
        boolean very_important = false;
        if (turn_range.x <= 0 && counter_is_range)
            very_important = true;
        if (!counter_is_range && next_exact_turn <= 3) //warn three turns ahead
            very_important = true;
        
        
        ChecklistSubentry subentry;
        string url;
        string window_display_name = window_name;
        
        monster fighting_monster;
        if (window_name == "Digitize Monster")
        {
            fighting_monster = get_property_monster("_sourceTerminalDigitizeMonster");
            string monster_name = fighting_monster.to_lower_case();
            if (monster_name == "")
                window_display_name = "Digitised monster";
            else
                window_display_name = "Digitised " + monster_name;
        }
        if (window_name == "Romantic Monster")
        {
            fighting_monster = get_property_monster("romanticTarget");
            window_display_name = "Arrowed " + __misc_state_string["Romantic Monster Name"].to_lower_case();
        }
        subentry.header = window_display_name;
        
        
        if (!counter_is_range)
        {
            if (next_exact_turn <= 0)
                subentry.header += HTMLGenerateSpanFont(" now", "red");
            else
                subentry.header += " after " + pluralise(next_exact_turn, "more turn", "more turns");
        }
        else if (turn_range.y <= 0)
            subentry.header += " now or soon";
        else if (turn_range.x <= 0)
            subentry.header += " between now and " + turn_range.y + " turns.";
        else
            subentry.header += " in [" + turn_range.x + " to " + turn_range.y + "] turns.";
        
        
        if (window_name == "Digitize Monster")
        {
            //Display next window:
            int next_window_count = get_property_int("_sourceTerminalDigitizeMonsterCount") + 1;
            //Vec2i next_window_range = Vec2iMake(15 + 10 * next_window_count, 25 + 10 * next_window_count);
            int next_turn_count = next_window_count * 10 + 10;
            //subentry.entries.listAppend("Next window will be [" + next_window_range.x + " to " + next_window_range.y + "] turns.");
            subentry.entries.listAppend("Next gap will be " + next_turn_count + " turns.");
            
            //calculate the limit:
            boolean [string] chips = getInstalledSourceTerminalSingleChips();
            int digitisations = get_property_int("_sourceTerminalDigitizeUses");
            int digitisation_limit = 1;
            if (chips["TRAM"])
                digitisation_limit += 1;
            if (chips["TRIGRAM"])
                digitisation_limit += 1;
            int digitisations_left = clampi(digitisation_limit - digitisations, 0, 3);
            if (get_property_int("_sourceTerminalDigitizeMonsterCount") >= 2 && digitisations < digitisation_limit)
                subentry.entries.listAppend("Could re-digitise to reset the window.");
        }
        if (window_name == "Rain Monster" && my_path_id() == PATH_HEAVY_RAINS)
        {
            subentry.entries = SCountersGenerateDescriptionForRainMonster();
        }
        if (fighting_monster != $monster[none])
        {
            CopiedMonstersGenerateDescriptionForMonster(fighting_monster, subentry.entries, (turn_range.x <= 0), false);
        }
        if (c.waiting_for_adventure_php)
            subentry.entries.listAppend("Need to adventure in adventure.php to start counting.");
        
        if ((turn_range.x <= 0 && counter_is_range) || (!counter_is_range && next_exact_turn <= 0))
        {
            if (get_property_boolean("dailyDungeonDone"))
            {
                url = "da.php";
                subentry.entries.listAppend("Could check for free in the daily dungeon.");
            }
            else if (get_property_int("hiddenApartmentProgress") >= 1 && get_property_int("hiddenBowlingAlleyProgress") >= 1 && get_property_int("hiddenHospitalProgress") >= 1 && get_property_int("hiddenOfficeProgress") >= 1) //we could support suggesting each shrine individually, but effort
            {
                url = $location[the hidden park].getClickableURLForLocation();
                subentry.entries.listAppend("Could check for free in one of the shrines.");
            }
        }
        
        string image_name = "__item Pok&euml;mann figurine: Frank"; //default - some person
        if (window_image_names contains window_name)
            image_name = window_image_names[window_name];
        
        int importance = 10;
        if (very_important)
            importance = -11;
        ChecklistEntry entry = ChecklistEntryMake(image_name, url, subentry, importance);
        
        if (very_important)
            task_entries.listAppend(entry);
        else
            optional_task_entries.listAppend(entry);
        
    }
}

void SCountersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (true)
    {
        //dance card:
        int turns_until_dance_card = CounterLookup("Dance Card").CounterGetNextExactTurn();
        
        if (turns_until_dance_card >= 0)
        {
            string stats = "Gives ~" + __misc_state_float["dance card average stats"].round() + " ";
            if (my_primestat() == $stat[moxie])
                stats += "mainstat";
            else
                stats += "moxie";
            stats += ".";
            if (turns_until_dance_card == 0)
            {
                task_entries.listAppend(ChecklistEntryMake("__item dance card", $location[the haunted ballroom].getClickableURLForLocation(), ChecklistSubentryMake("Dance card up now.", "", "Adventure in haunted ballroom. " + stats), -11));
            }
            else
            {
                optional_task_entries.listAppend(ChecklistEntryMake("__item dance card", "", ChecklistSubentryMake("Dance card up after " + pluralise(turns_until_dance_card, "adventure", "adventures") + ".", "", "Haunted ballroom. " + stats)));
            }
        }
    }
    
	SCountersGenerateEntry(task_entries, optional_task_entries, true);
}

void SCountersGenerateResource(ChecklistEntry [int] resource_entries)
{
	SCountersGenerateEntry(resource_entries, resource_entries, false);
}