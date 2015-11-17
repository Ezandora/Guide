Record BadMoonAdventure
{
    int encounter_id;
    string category;
    string description;
    string conditions_to_finish;
    boolean has_additional_requirements_not_yet_met;
    location [int] locations;
};

BadMoonAdventure BadMoonAdventureMake(int encounter_id, location [int] locations, string category, string description, string conditions_to_finish, boolean has_additional_requirements_not_yet_met)
{
    BadMoonAdventure adventure;
    adventure.encounter_id = encounter_id;
    adventure.category = category;
    adventure.description = description;
    adventure.conditions_to_finish = conditions_to_finish;
    adventure.has_additional_requirements_not_yet_met = has_additional_requirements_not_yet_met;
    adventure.locations = locations;
    return adventure;
}

BadMoonAdventure BadMoonAdventureMake(int encounter_id, location l, string category, string description, string conditions_to_finish, boolean has_additional_requirements_not_yet_met)
{
    location [int] locations;
    locations.listAppend(l);
    return BadMoonAdventureMake(encounter_id, locations, category, description, conditions_to_finish, has_additional_requirements_not_yet_met);
}

void listAppend(BadMoonAdventure [int] list, BadMoonAdventure entry)
{
    int position = list.count();
    while (list contains position)
        position += 1;
    list[position] = entry;
}


/*
Categories:
DAMAGE1
DAMAGE2
ELEMENTALDAMAGE1 - +10 elemental damage, -2 DR
ELEMENTALDAMAGE2 - +20 elemental damage, -2 DR
DAMAGE_REDUCTION - +DR, -8 weapon damage
Familiar Hatchlings -
ITEM_DROP
ITEMS
meat
MEAT_DROP
RESIST1
RESIST2
SKILLS
STAT1 - +20 one stat, -5 two other stats
STAT2 - +40 one stat, -50% familiar weight
STAT3 - +50% one stat, -50% other stat
*/
static
{
    BadMoonAdventure [int] __static_bad_moon_adventures;
    BadMoonAdventure [location] __static_bad_moon_adventures_by_location;
    void initialiseStaticBadMoonAdventures()
    {
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(2, lookupLocation("The Haunted Pantry"), "STAT1", "+20 myst, -5 muscle/moxie", "", false)); //FIXME is there a conditional on this?
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(3, lookupLocation("The Sleazy Back Alley"), "STAT1", "+20 moxie, -5 myst/muscle", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(4, lookupLocation("Cobb's Knob Treasury"), "STAT2", "+40 muscle, -50% familiar weight", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(5, lookupLocation("Cobb's Knob Kitchens"), "STAT2", "+40 myst, -50% familiar weight", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(6, lookupLocation("Cobb's Knob Harem"), "STAT2", "+40 moxie, -50% familiar weight", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(7, lookupLocation("Frat House"), "STAT3", "+50% muscle, -50% myst", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(8, lookupLocation("Frat House In Disguise"), "STAT3", "+50% muscle, -50% moxie", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(9, lookupLocation("Hippy Camp"), "STAT3", "+50% myst, -50% moxie", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(10, lookupLocation("Hippy Camp In Disguise"), "STAT3", "+50% myst, -50% muscle", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(11, lookupLocation("The Obligatory Pirate's Cove"), "STAT3", "+50% moxie, -50% muscle", "", false));
        //12 is gone?
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(15, lookupLocation("The Haunted Kitchen"), "ELEMENTALDAMAGE1", "+10 " + HTMLGenerateElementSpanDesaturated($element[hot]) + " damage, -2 DR", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(17, lookupLocation("The Haunted Library"), "ELEMENTALDAMAGE1", "+10 " + HTMLGenerateElementSpanDesaturated($element[spooky]) + " damage, -2 DR", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(18, lookupLocation("Guano Junction"), "ELEMENTALDAMAGE1", "+10 " + HTMLGenerateElementSpanDesaturated($element[stench]) + " damage, -2 DR", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(20, lookupLocation("The Icy Peak"), "ELEMENTALDAMAGE2", "+20 " + HTMLGenerateElementSpanDesaturated($element[cold]) + " damage, ~2 HP lost/round", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(28, lookupLocation("Tower Ruins"), "RESIST1", "+2 " + HTMLGenerateElementSpanDesaturated($element[spooky], "res") + ", 2x damage from stench/hot", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(32, lookupLocation("Cobb's Knob Laboratory"), "ITEM_DROP", "+50% item, -5 stats/fight", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(33, lookupLocation("The Haunted Bathroom"), "ITEM_DROP", "+100% item, -20 all stats", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(34, lookupLocation("The Unquiet Garves"), "MEAT_DROP", "+50% meat, -50% init", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(35, lookupLocation("The VERY Unquiet Garves"), "MEAT_DROP", "+200% meat, -50% item", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(38, lookupLocation("the spooky forest"), "meat", "1000 meat", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(41, lookupLocation("south of the border"), "meat", "4000 meat, beaten up", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(43, lookupLocation("Noob Cave"), "Familiar Hatchlings", "Black cat hatchling, 14 drunkenness", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(46, lookupLocation("A Barroom Brawl"), "Familiar Hatchlings", "Leprechaun hatchling, one drunkenness", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(47, lookupLocation("The Hidden Temple"), "ITEMS", "Loaded dice", "", false));
        __static_bad_moon_adventures.listAppend(BadMoonAdventureMake(48, lookupLocation("The Haunted Conservatory"), "Familiar Hatchlings", "Potato sprout", "", false));
    }
    initialiseStaticBadMoonAdventures();
}

//FIXME make this work in scripts that aren't guide
//We should probably have an "invalidate caches" message that happens whenever state may have changed.
//Maybe a global variable in the library that's incremented by one, and caches check themselves against that.
//Querying that variable would be through a function, so it automatically increments by one if the turncount changes.

BadMoonAdventure [int] __all_bad_moon_adventures_cache;
int __all_bad_moon_adventures_cache_on_turn = -1;
BadMoonAdventure [int] AllBadMoonAdventures()
{
    if (__all_bad_moon_adventures_cache.count() > 0 && __all_bad_moon_adventures_cache_on_turn == my_turncount())
        return __all_bad_moon_adventures_cache;
    BadMoonAdventure [int] adventures;
    
    foreach key, adventure in __static_bad_moon_adventures
    {
        adventures.listAppend(adventure);
    }
        
    adventures.listAppend(BadMoonAdventureMake(39, $location[the degrassi knoll garage], "meat", "2000 meat, -myst debuff", "finish meatcar guild quest", !QuestState("questG01Meatcar").finished));
    adventures.listAppend(BadMoonAdventureMake(40, $location[the bat hole entrance], "meat", "3000 meat, -moxie debuff", "open boss bat's lair", __quest_state["Level 4"].state_int["areas unlocked"] < 3));
    
    adventures.listAppend(BadMoonAdventureMake(1, lookupLocation("Outskirts of Cobb's Knob"), "STAT1", "+20 muscle, -5 myst/moxie", "find encryption key", $item[knob goblin encryption key].available_amount() == 0 && !$location[cobb's knob kitchens].locationAvailable()));
    adventures.listAppend(BadMoonAdventureMake(13, lookupLocation("The Haunted Billiards Room"), "DAMAGE1", "+10 damage, -2 DR", "open the Haunted Library", !$location[the haunted library].locationAvailable()));
    adventures.listAppend(BadMoonAdventureMake(14, lookupLocation("The Goatlet"), "ELEMENTALDAMAGE1", "+10 " + HTMLGenerateElementSpanDesaturated($element[cold]) + " damage, -2 DR", "unlock the eXtreme Slope", !$location[the extreme slope].locationAvailable()));
    //adventures.listAppend(BadMoonAdventureMake(19, lookupLocation("The Castle in the Clouds in the Sky (somewhere)"), "DAMAGE2", "+20 melee damage, ~2 HP lost/round", "completed trash quest", REPLACEMEB)); //FIXME investigate this
    //adventures.listAppend(BadMoonAdventureMake(21, lookupLocation("Oasis"), "ELEMENTALDAMAGE2", "+20 " + HTMLGenerateElementSpanDesaturated($element[hot]) + " damage, ~2 HP lost/round", "find worm-riding hooks", REPLACEMEB)); //??
    adventures.listAppend(BadMoonAdventureMake(22, lookupLocation("The Hole in the Sky"), "ELEMENTALDAMAGE2", "+20 " + HTMLGenerateElementSpanDesaturated($element[sleaze]) + " damage, ~2 HP lost/round", "make Richard's star key", $item[richard's star key].available_amount() == 0));
    adventures.listAppend(BadMoonAdventureMake(23, lookupLocation("The Haunted Ballroom"), "ELEMENTALDAMAGE2", "+20 " + HTMLGenerateElementSpanDesaturated($element[spooky]) + " damage, ~2 HP lost/round", "open Spookyraven basement", !$location[the haunted wine cellar].locationAvailable()));
    adventures.listAppend(BadMoonAdventureMake(24, lookupLocation("The Black Forest"), "ELEMENTALDAMAGE2", "+20 " + HTMLGenerateElementSpanDesaturated($element[stench]) + " damage, ~2 HP lost/round", "open black market", !black_market_available()));
    adventures.listAppend(BadMoonAdventureMake(25, lookupLocation("Inside the Palindome"), "RESIST1", "+2 " + HTMLGenerateElementSpanDesaturated($element[cold], "res") + ", 2x damage from hot/spooky", "defeat Dr. Awkward", !QuestState("questL11Palindome").finished));
    //adventures.listAppend(BadMoonAdventureMake(26, lookupLocation("REPLACEME"), "RESIST1", "+2 " + HTMLGenerateElementSpanDesaturated($element[hot], "res") + ", 2x damage from stench/sleaze", "REASONWHYNOTREPLACEME", REPLACEMEB)); //Pot-Unlucky - UNKNOWN
    adventures.listAppend(BadMoonAdventureMake(27, lookupLocation("The Valley of Rof L'm Fao"), "RESIST1", "+2 " + HTMLGenerateElementSpanDesaturated($element[sleaze], "res") + ", 2x damage from cold/spooky", "acquire facsimile dictionary", $item[facsimile dictionary].available_amount() == 0));
    adventures.listAppend(BadMoonAdventureMake(29, lookupLocation("The Arid, Extra-Dry Desert"), "RESIST1", "+2 " + HTMLGenerateElementSpanDesaturated($element[stench], "res") + ", 2x damage from cold/sleaze", "need to have ultrahydrated", $effect[ultrahydrated].have_effect() > 0));
    adventures.listAppend(BadMoonAdventureMake(30, lookupLocation("Beanbat Chamber"), "RESIST2", "+1 all res, -10% stats", "plant beanstalk", !__quest_state["Level 10"].state_boolean["beanstalk grown"]));
    adventures.listAppend(BadMoonAdventureMake(31, lookupLocation("The Haunted Wine Cellar"), "RESIST2", "+2 all res, -20% stats", "defeat Lord Spookyraven", !__quest_state["Level 11 Manor"].finished));
    adventures.listAppend(BadMoonAdventureMake(36, lookupLocation("8-bit realm"), "DAMAGE_REDUCTION", "+4 DR, -8 damage", "acquire digital key", $item[digital key].available_amount() == 0));
    adventures.listAppend(BadMoonAdventureMake(37, lookupLocation("The Penultimate Fantasy Airship"), "DAMAGE_REDUCTION", "+8 DR, -8 damage", "unlock castle", $item[s.o.c.k.].available_amount() == 0));
    QuestState white_citadel_quest = QuestState("questG02Whitecastle");
    adventures.listAppend(BadMoonAdventureMake(42, $location[whitey's grove], "meat", "5000 meat, -20% stats debuff", "finish white citadel quest? (this needs spading)", !(!white_citadel_quest.started || white_citadel_quest.finished)));
    //adventures.listAppend(BadMoonAdventureMake(45, lookupLocation("The Arid, Extra-Dry Desert"), "ITEMS", "anticheese", "need to not have ultrahydrated", $effect[ultrahydrated].have_effect() == 0)); //is this still here?
    
    adventures.listAppend(BadMoonAdventureMake(44, $location[the spooky forest], "SKILLS", "torso awaregness, -50% muscle debuff", "unlock hidden temple", get_property_int("lastTempleUnlock") != my_ascensions()));
    
    __all_bad_moon_adventures_cache = adventures;
    __all_bad_moon_adventures_cache_on_turn = my_turncount();
    
    return adventures;
}
BadMoonAdventure [string][int] AllBadMoonAdventuresByCategory()
{
    BadMoonAdventure [string][int] result;
    foreach key, adventure in AllBadMoonAdventures()
    {
        if (!(result contains adventure.category))
        {
            BadMoonAdventure [int] blank;
            result[adventure.category] = blank;
        }
        result[adventure.category].listAppend(adventure);
    }
    return result;
}

BadMoonAdventure [int] BadMoonAdventuresForLocation(location l)
{
    BadMoonAdventure [int] result;
    foreach key, adventure in AllBadMoonAdventures()
    {
        foreach key, l2 in adventure.locations
        {
            if (l == l2)
            {
                result.listAppend(adventure);
                break;
            }
        }
    }
    return result;
}

void SBadMoonGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!in_bad_moon())
        return;
    if (my_turncount() == 0 && !haveSeenBadMoonEncounter(43) && $item[black kitten].available_amount() == 0 && !$familiar[black cat].have_familiar())
    {
        string [int] description;
        description.listAppend("For a black cat run. So cute!");
        description.listAppend("Adventure in the noob cave " + HTMLGenerateSpanFont("once", "red") + ".");
        description.listAppend(HTMLGenerateSpanFont("Will cost 14 drunkenness.", "red"));
        optional_task_entries.listAppend(ChecklistEntryMake("__familiar black cat", "", ChecklistSubentryMake("Possibly adopt a black kitten", "", description)));
    }
    
    //Finding familiars - +item, +meat, +stats
    
    if (my_familiar() != $familiar[black cat])
    {
        if (!$familiar[blood-faced volleyball].have_familiar() && !$familiar[smiling rat].have_familiar())
        {
            string [int] description;
            string url;
            
            string [int] tasks;
            if ($item[blood-faced volleyball].available_amount() > 0)
            {
                tasks.listAppend("use blood-faced volleyball");
                url = "inventory.php?which=3";
            }
            else
            {
                int trinkets_needed = 0;
                if ($item[volleyball].available_amount() == 0)
                {
                    string line = "collect a volleyball";
                    if ($effect[bloody hand].have_effect() == 0 && $item[seal tooth].available_amount() == 0)
                    {
                        line += " and seal tooth";
                        trinkets_needed += 1;
                    }
                    line += " from the hermit";
                    tasks.listAppend(line);
                    url = "hermit.php";
                    trinkets_needed += 1;
                }
                if ($effect[bloody hand].have_effect() == 0)
                {
                    if ($item[seal tooth].available_amount() == 0 && $item[volleyball].available_amount() > 0)
                    {
                        tasks.listAppend("collect a seal tooth from the hermit");
                        url = "hermit.php";
                        trinkets_needed += 1;
                    }
                    tasks.listAppend("use seal tooth to acquire a bloody hand (ow!)");
                    if (url != "" && $item[seal tooth].available_amount() > 0)
                        url = "inventory.php?which=3";
                }
                int trinkets_missing = MAX(0, trinkets_needed - $items[worthless trinket,worthless gewgaw,worthless knick-knack].available_amount());
                if (trinkets_missing > 0)
                {
                    tasks.listPrepend("collect " + pluralise(trinkets_missing, $item[worthless trinket]) + " (use chewing gum)");
                    if ($item[chewing gum on a string].available_amount() == 0)
                        url = "shop.php?whichshop=generalstore";
                    else
                        url = "inventory.php?which=3";
                    if ($item[hermit permit].available_amount() == 0)
                    {
                        tasks.listPrepend("buy hermit permit");
                        url = "shop.php?whichshop=generalstore";
                    }
                }
                
                tasks.listAppend("use volleyball");
                if (url != "" && $item[volleyball].available_amount() > 0 && $effect[bloody hand].have_effect() > 0)
                    url = "inventory.php?which=3";
                        
                tasks.listAppend("use blood-faced volleyball");
            }
            description.listAppend(tasks.listJoinComponents(", ").capitaliseFirstLetter() + ".");
            optional_task_entries.listAppend(ChecklistEntryMake("__familiar blood-faced volleyball", url, ChecklistSubentryMake("Adopt a blood-faced volleyball", "", description)));
        }
        if (!$familiar[Leprechaun].have_familiar())
        {
            string [int] description;
            string url;
            if ($item[leprechaun hatchling].available_amount() > 0)
            {
                description.listAppend("Use a leprechaun hatchling.");
                url = "inventory.php?which=3";
            }
            else if (!haveSeenBadMoonEncounter(46) && $location[a barroom brawl].locationAvailable())
            {
                description.listAppend("Find in a barroom brawl.");
                url = $location[a barroom brawl].getClickableURLForLocation();
            }
            if (description.count() > 0)
                optional_task_entries.listAppend(ChecklistEntryMake("__familiar Leprechaun", url, ChecklistSubentryMake("Adopt a leprechaun", "", description), $locations[a barroom brawl]));
        }
        if (!$familiar[baby gravy fairy].have_familiar())
        {
            string [int] description;
            string [int] modifiers;
            string url;
            
            if ($item[pregnant mushroom].available_amount() > 0)
            {
                description.listAppend("Use a pregnant mushroom.");
                url = "inventory.php?which=3";
            }
            else if ($item[pregnant mushroom].creatable_amount() > 0)
            {
                description.listAppend("Create and use a pregnant mushroom.");
                url = "craft.php?mode=cook";
            }
            else
            {
                boolean need_minus_combat = false;
                if ($item[fairy gravy boat].available_amount() == 0)
                {
                    need_minus_combat = true;
                    description.listAppend("Adventure in the Haiku Dungeon for a fairy gravy boat.|Second choice in the NC.");
                    url = $location[the haiku dungeon].getClickableURLForLocation();
                }
                if ($item[Knob mushroom].available_amount() == 0)
                {
                    need_minus_combat = true;
                    description.listAppend("Find a knob mushroom somewhere.|Probably the haiku dungeon. First choice in the NC.|The cobb's knob kitchens are also an option. (?)");
                    url = $location[the haiku dungeon].getClickableURLForLocation();
                }
                if (need_minus_combat)
                    modifiers.listAppend("-combat");
            }
            
            optional_task_entries.listAppend(ChecklistEntryMake("__familiar baby gravy fairy", url, ChecklistSubentryMake("Adopt a baby gravy fairy", modifiers, description)));
        }
        if (!$familiar[cocoabo].have_familiar() && $item[cocoa egg].available_amount() + $item[cocoa egg].creatable_amount() > 0)
        {
            //thanks harumph
            string [int] description;
            string url;
            if ($item[cocoa egg].available_amount() == 0)
            {
                description.listAppend("Cook two cocoa eggshell fragments together twice, then cook two large cocoa eggshell fragments together.|Then use the cocoa egg.");
                url = "craft.php?mode=cook";
            }
            else
            {
                description.listAppend("Use a cocoa egg.");
                //url = "inventory.php?which=3";
            }
            optional_task_entries.listAppend(ChecklistEntryMake("__familiar cocoabo", url, ChecklistSubentryMake("Adopt a cocoabo", "", description)));
            
        }
    }
    //FIXME do we want the init semi-rare potion? it's only +100%... but, that might save a lot of turns?
}

void SBadMoonGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!in_bad_moon())
        return;
    
    if (in_bad_moon() && !get_property_boolean("styxPixieVisited"))
    {
        string [int] description;
        description.listAppend("Rubdown: +25% muscle, +5 DR, +10 damage.");
        description.listAppend("Mind: +25% mysticality, +10-15 mp regen, +15 spell damage.");
        description.listAppend("Colonge: +20% items, +25% moxie, +40% meat.");
		resource_entries.listAppend(ChecklistEntryMake("__effect Hella Smooth", "heydeze.php?place=styx", ChecklistSubentryMake("Styx pixie buff", "", description), 10));
    }
    
    if ($item[ghost key].available_amount() > 0 && __misc_state["in run"])
    {
        string url = "";
        if ($location[the haunted bedroom].locationAvailable())
            url = $location[the haunted bedroom].getClickableURLForLocation();
        
        string [int] description;
        
        if (__misc_state["need to level"])
        {
            string target_nightstand = "";
            if (my_primestat() == $stat[muscle])
                target_nightstand = "simple";
            else if (my_primestat() == $stat[mysticality])
                target_nightstand = "ornate";
            else if (my_primestat() == $stat[moxie])
                target_nightstand = "rustic";
            description.listAppend("? mainstat from a " + target_nightstand + " nightstand."); //wiki says 200, but I saw 87 at level nine in bad moon
        }
        description.listAppend("1000 meat from a mahogany nightstand.");
		resource_entries.listAppend(ChecklistEntryMake("__item ghost key", url, ChecklistSubentryMake(pluralise($item[ghost key]), "", description), 10));
        
    }
}

void SBadMoonGenerateCategoryChecklistEntry(BadMoonAdventure [string][int] adventures_by_category, ChecklistEntry [int] bad_moon_adventures_entries, string [int] categories, string image_name, string header, string [int] initial_d_escription)
{
    string [int][int] description_active;
    string [int][int] description_inactive;
    
    string url;
    boolean [location] relevant_locations;
    foreach key1, category in categories
    {
        foreach key2, adventure in adventures_by_category[category]
        {
            if (haveSeenBadMoonEncounter(adventure.encounter_id))
                continue;
                
            string [int] line;
            line.listAppend(adventure.locations.listJoinComponents(" / "));
            
            string line2 = adventure.description;
            
            
            boolean greyed_out = false;
            if (adventure.has_additional_requirements_not_yet_met)
            {
                line2 += ".|Need to " + adventure.conditions_to_finish + ".";
                //line = HTMLGenerateSpanFont(line, "grey");
                greyed_out = true;
            }
            else
                line2 += ".";
            line.listAppend(line2);
            
            if (!greyed_out)
            {
                boolean have_open_location = false;
                foreach key, l in adventure.locations
                {
                    if (l.locationAvailable())
                    {
                        if (url == "")
                            url = l.getClickableURLForLocation();
                        have_open_location = true;
                    }
                    /*if (__setting_debug_mode)
                    {
                        Error unable_to_find_location;
                        l.locationAvailable(unable_to_find_location);
                        if (unable_to_find_location.was_error)
                            print_html("\"" + l + "\" unknown to locationAvailable");
                        
                    }*/
                }
                if (!have_open_location)
                {
                    //line = HTMLGenerateSpanFont(line, "grey");
                    greyed_out = true;
                }
            }
            
            if (greyed_out)
            {
                foreach key, value in line
                {
                    line[key] = HTMLGenerateSpanFont(value, "grey");
                }
                description_inactive.listAppend(line);
            }
            else
            {
                foreach key, l in adventure.locations
                    relevant_locations[l] = true;
                description_active.listAppend(line);
            }
        }
    }
    string [int] description;
    
    description.listAppendList(initial_d_escription); //deja vu!
    foreach key in description_inactive
    {
        description_active.listAppend(description_inactive[key]);
    }
    if (description_active.count() + description.count() > 0)
    {
        description.listAppend(HTMLGenerateSimpleTableLines(description_active));
        bad_moon_adventures_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(header, "", description), relevant_locations));
    }
}

void SBadMoonGenerateCategoryChecklistEntry(BadMoonAdventure [string][int] adventures_by_category, ChecklistEntry [int] bad_moon_adventures_entries, string [int] categories, string image_name, string header)
{
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, categories, image_name, header, listMakeBlankString());
}

RegisterChecklistGenerationFunction("SBadMoonGenerateChecklists");
void SBadMoonGenerateChecklists(ChecklistCollection checklist_collection)
{
    if (!in_bad_moon())
        return;
    
    ChecklistEntry [int] bad_moon_adventures_entries = checklist_collection.lookup("Bad Moon Adventures").entries;
    
    
    //badMoonEncounter01 to badMoonEncounter48
    //umm... that's a lot...
    //each area has up to one encounter, but many areas may have the same encounter (frat house/hippy camp)
    
    /*
    They're all classified under different areas, though.
    
    Things to mention:
    √lots of meat, -something
    √+X% item, -something
    √+X% meat, -something
    √+2 elemental resistance, 2x damage from two other elements
    √+resistance all elements, all attributes -%
    √+20 mainstat, -5 other stats
    √+40 mainstat, -50% familiar weight (black cat!)
    √items, -something (√black kitten and terrarium, √torso awaregness, anticheese (irrelevant), √leprechaun, loaded dice (irrelevant), √potato sprout (irrelevant?)
    
    Maybe:
    √+50% stat, -50% other stat
    √+20 elemental damage, -~2 damage/round (g-g-g-ghosts!)
    √+10 elemental damage, -2 DR (g-g-g-ghosts!)
    
    ???:
    +DR, -8 weapon damage
    */
    
    BadMoonAdventure [string][int] adventures_by_category = AllBadMoonAdventuresByCategory();
    
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, listMake("meat"), "__item dense meat stack", "Meat");
    if (my_familiar() != $familiar[black cat])
        SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, listMake("Familiar hatchlings"), "__item Familiar-Gro&trade; Terrarium", "Familiar hatchlings");
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, listMake("ITEM_DROP"), "__item Mr. Cheeng's spectacles", "Item buffs");
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, listMake("MEAT_DROP"), "__item old leather wallet", "Meat buffs");
    
    string [int] elemental_damage_ordering = listMake("ELEMENTALDAMAGE1", "ELEMENTALDAMAGE2");
    if (my_level() >= 10)
        elemental_damage_ordering = listMake("ELEMENTALDAMAGE2", "ELEMENTALDAMAGE1"); //don't encourage the +20 buffs until later
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, listMake("RESIST1", "RESIST2"), "__item yak anorak", "Elemental resist buffs");
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, listMake("STAT2", "STAT1", "STAT3"), "__effect Phorcefullness", "Stat buffs");
    SBadMoonGenerateCategoryChecklistEntry(adventures_by_category, bad_moon_adventures_entries, elemental_damage_ordering, "__item oversized snowflake", "Elemental damage buffs", listMake("For defeating ghosts."));
    
    if (!$skill[torso awaregness].have_skill() && !haveSeenBadMoonEncounter(44) && $location[the hidden temple].locationAvailable())
    {
        string [int] description;
        description.listAppend("Spooky forest.");
        
        if ($item[grue egg omelette].available_amount() == 0 && $item[spooky mushroom].available_amount() == 0 && ($item[strange leaflet].available_amount() == 0 || $item[grue egg].available_amount() == 0))
        {
            description.listAppend("Farm a spooky mushroom (for grue omelette) while you're there: " + listMake("Explore the stream", "March to the marsh").listJoinComponents(__html_right_arrow_character));
        }
        else
            description.listAppend("Farm spices (for spicy burritos) while you're there: " + listMake("Brave the dark thicket", "Follow the even darker path", "Take the scorched path", "Investigate the moist crater").listJoinComponents(__html_right_arrow_character));
        
        bad_moon_adventures_entries.listAppend(ChecklistEntryMake("__item &quot;Humorous&quot; T-shirt", $location[the spooky forest].getClickableURLForLocation(), ChecklistSubentryMake("Torso Awaregness", "", description), $locations[the spooky forest]));
    }
    
    /*
    FIXME
    "Tower Ruins" unknown to locationAvailable
    "Frat House" unknown to locationAvailable
    "Frat House In Disguise" unknown to locationAvailable
    "Hippy Camp" unknown to locationAvailable
    "Hippy Camp In Disguise" unknown to locationAvailable
    */
}