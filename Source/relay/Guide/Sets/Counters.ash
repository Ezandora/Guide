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
    
    int water_level_modifier = 0;
    if (lookupEffect("Personal Thundercloud").have_effect() > 0)
        water_level_modifier += 2;
    else if (lookupSkill("Thundercloud").have_skill())
        waterbending_skills_can_cast.listAppend("Thundercloud");
    if (lookupEffect("The Rain In Loathing").have_effect() > 0)
        water_level_modifier += 2;
    else if (lookupSkill("Rainy Day").have_skill())
        waterbending_skills_can_cast.listAppend("Rainy Day");
    
    
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
    
    if (get_campground()[lookupItem("Little Geneticist DNA-Splicing Lab")] > 0 && mafiaIsPastRevision(13918) && !get_property_boolean("_dnaHybrid") && lookupEffect("Human-Fish Hybrid").have_effect() == 0 && !__misc_state["familiars temporarily blocked"])
    {
        //FIXME all once spaded
        //NOT giant isopod
        //gourmet gourami?
        //freshwater bonefish
        //alley catfish
        //piranhadon
        foreach s in $strings[freshwater bonefish,alley catfish,piranhadon]
        {
            monster_descriptions[s] = monster_descriptions[s] + " (fish DNA)";
        }
    }
    
    
    if (my_mp() > 50)
    {
        monster_descriptions["storm cow"] += HTMLGenerateSpanFont(", burn MP to 50 to survive", "red", "");
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
        terrain_monsters.listAppend(line);
        
        if (depth_min != depth_max)
        {
            line = monster_for_terrain_depth[terrain][depth_max];
            //if (monster_descriptions contains line)
                //line += " (" + monster_descriptions[line] + ")";
            if (monster_descriptions contains line)
                line = monster_descriptions[line];
            terrain_monsters.listAppend(line);
        }
        
        line = terrain.capitalizeFirstLetter() + ": ";
        if (!have_usable_last_terrain)
            line = HTMLGenerateSpanOfClass(line, "r_bold");
        line += terrain_monsters.listJoinComponents(", ", "or");
        if (last_terrain == terrain)
            line = HTMLGenerateSpanOfClass(line, "r_bold");
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
    window_image_names["Rain Monster"] = "__familiar personal raincloud";
    //window_image_names["Event Monster"] = ""; //no idea
    
    boolean [string] counter_blacklist = $strings[Romantic Monster,Semi-rare];
    
    string [int] all_counter_names = CounterGetAllNames();
    
    foreach key in all_counter_names
    {
        string window_name = all_counter_names[key];
        if (window_name == "")
            continue;
        if (counter_blacklist contains window_name)
            continue;
        
        Counter c = CounterLookup(window_name);
        if (!c.CounterIsRange())
            continue;
        
        Vec2i turn_range = c.CounterGetWindowRange();
        
        if (!(turn_range.x <= 10 && from_task) && !(turn_range.x > 10 && !from_task))
            continue;
        
        
        
        boolean very_important = false;
        if (turn_range.x <= 0)
            very_important = true;
        
        
        
        ChecklistSubentry subentry;
        subentry.header = window_name;
        
        
        if (turn_range.y <= 0)
            subentry.header += " now or soon";
        else if (turn_range.x <= 0)
            subentry.header += " between now and " + turn_range.y + " turns.";
        else
            subentry.header += " in [" + turn_range.x + " to " + turn_range.y + "] turns.";
        
        
        if (window_name == "Rain Monster" && my_path_id() == PATH_HEAVY_RAINS)
        {
            subentry.entries = SCountersGenerateDescriptionForRainMonster();
        }
        
        string image_name = "__item Pok&euml;mann figurine: Frank"; //default - some person
        if (window_image_names contains window_name)
            image_name = window_image_names[window_name];
        
        int importance = 10;
        if (very_important)
            importance = -11;
        ChecklistEntry entry = ChecklistEntryMake(image_name, "", subentry, importance);
        
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
            string stats = "Gives ~" + __misc_state_float["dance card average stats"].round() + " mainstats.";
            if (turns_until_dance_card == 0)
            {
                task_entries.listAppend(ChecklistEntryMake("__item dance card", $location[the haunted ballroom].getClickableURLForLocation(), ChecklistSubentryMake("Dance card up now.", "", "Adventure in haunted ballroom. " + stats), -11));
            }
            else
            {
                optional_task_entries.listAppend(ChecklistEntryMake("__item dance card", "", ChecklistSubentryMake("Dance card up after " + pluralize(turns_until_dance_card, "adventure", "adventures") + ".", "", "Haunted ballroom. " + stats)));
            }
        }
    }
    
	SCountersGenerateEntry(task_entries, optional_task_entries, true);
}

void SCountersGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SCountersGenerateEntry(available_resources_entries, available_resources_entries, false);
}