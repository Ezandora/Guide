RegisterTaskGenerationFunction("PathCommunityServiceGenerateTasks");
void PathCommunityServiceGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_path_id() != PATH_COMMUNITY_SERVICE)
        return;
    if (!__misc_state["in run"])
        return;
    boolean [item] blocklist;
    
    /*string [int] service_display_order = {0:"Coil Wire",
    1:"",
    2:"",
    3:"",
    4:"",
    5:"",
    6:"",
    7:"",
    8:"",
    9:"",
    10:""
    };*/
    boolean [string] services_performed = listInvert(get_property("csServicesPerformed").split_string_alternate(","));
    string [int] choice_id_order = {
        "Coil Wire", //flat
        "Donate Blood",
        "Feed The Children (But Not Too Much)",
        "Build Playground Mazes",
        "Feed Conspirators",
        "Breed More Collies",
        "Reduce Gazelle Population",
        "Make Sausage",
        "Be a Living Statue",
        "Make Margaritas",
        "Clean Steam Tunnels"
    };
    //the spreadsheet we were using does +item before the stat tests, but I'm moving it after them, because cold-filtered water is ten turns, and the +item test doesn't give anything that helps with stats
    //and technically, muscle gives bag of grain
    string [int] service_display_order = {
    	"Coil Wire", //flat
        "Feed The Children (But Not Too Much)", //muscle
        "Feed Conspirators", //moxie
        "Donate Blood", //hp
        "Build Playground Mazes", //myst
        "Make Margaritas", //item/booze
        "Reduce Gazelle Population", //melee
        "Make Sausage", //spell
        "Clean Steam Tunnels", //hot res
        "Breed More Collies", //familiar weight
        "Be a Living Statue", //-combat
    };
    /*string [string] service_names_to_property = {"Donate Blood":"REPLACEME"
    	"Feed The Children (But Not Too Much)":"Muscle",
        "Build Playground Mazes":"Mysticality",
        "Feed Conspirators":"Moxie",
        "Breed More Collies":"Familiar Weight",
        "Reduce Gazelle Population":"REPLACEME",
        "Make Sausage":"REPLACEME",
        "Be a Living Statue":"REPLACEME",
        "Make Margaritas":"REPLACEME",
        "Clean Steam Tunnels":"Hot Resistance",
    };*/
    //None, HP, muscle, mysticality, moxie, familiar weight, melee damage, spell damage, noncombat, booze drop, hot res
    //list in ideal order to finish the path as you are(?)
    int REPLACEME = 10000;
    foreach key, service_name in service_display_order
    {
    	string [int] modifiers;
        string [int] description;
        int turns = PathCommunityServiceEstimateTurnsTakenForTask(service_name);
        string service_lookup_name = service_name;
        if (service_lookup_name == "Feed The Children (But Not Too Much)")
        	service_lookup_name = "Feed The Children";
        if (services_performed[service_lookup_name]) continue;
        
        boolean [string] numeric_modifiers;
        string short_test_description;
        boolean prefer_negative = false;
        string image_name = "";
        if (service_name == "Donate Blood")
        {
        	image_name = "__item blood-drive sticker";
        	modifiers.listAppend("HP");
            modifiers.listAppend("muscle");
            short_test_description = "HP";
        	numeric_modifiers = $strings[Buffed HP Maximum,Maximum HP,Muscle,Muscle Percent];
        }
        else if (service_name == "Coil Wire")
        {
            image_name = "__item a ten-percent bonus";
        }
        else if (service_name == "Make Margaritas")
        {
            image_name = "__item emergency margarita";
            modifiers.listAppend("item");
            modifiers.listAppend("booze drop");
            short_test_description = "item drop, booze drop";
            numeric_modifiers = $strings[Item Drop,Booze Drop];
        }
        else if (service_name == "Feed The Children (But Not Too Much)" || service_name == "Build Playground Mazes" || service_name == "Feed Conspirators")
        {
        	stat using_stat;
            if (service_name == "Feed The Children (But Not Too Much)")
            {
            	using_stat = $stat[muscle];
                image_name = "__item bag of grain";
            }
            else if (service_name == "Build Playground Mazes")
            {
                using_stat = $stat[mysticality];
                image_name = "__item pocket maze";
            }
            else if (service_name == "Feed Conspirators")
            {
                using_stat = $stat[moxie];
                image_name = "__item shady shades";
            }
            modifiers.listAppend("+" + using_stat);
            short_test_description = using_stat;
            numeric_modifiers[using_stat.to_string()] = true;
            numeric_modifiers[using_stat + " Percent"] = true;
            int basestat = my_basestat(using_stat);
            boolean relevant_thrall_active = false;
            if (my_thrall() == $thrall[Elbow Macaroni] && using_stat == $stat[muscle])
            {
            	basestat = my_basestat($stat[mysticality]);
                relevant_thrall_active = true;
            }
            if (my_thrall() == $thrall[Penne Dreadful] && using_stat == $stat[moxie])
            {
                basestat = my_basestat($stat[mysticality]);
                relevant_thrall_active = true;
            }
            
            turns = 60 - (my_buffedstat(using_stat) - basestat) / 30;
            if (turns > 1)
            {
                //turns saved = (buffed - base) / 30
                //60 = (buffed - base) / 30
                //1800 = buffed - base
                //buffed = 1800 + base
                int needed_buffed_stat = 1800 + basestat;
                float percentage = to_float(needed_buffed_stat - my_buffedstat(using_stat)) / to_float(basestat) * 100.0;
                description.listAppend("Need to buff " + using_stat + " to " + needed_buffed_stat + " (+" + (needed_buffed_stat - my_buffedstat(using_stat)) + " / +" + percentage.round() + "% from here)");
                if (relevant_thrall_active)
                {
                }
                else if (using_stat != $stat[mysticality] && my_primestat() == $stat[mysticality] && $item[oil of expertise].to_effect().have_effect() == 0)
                {
                	description.listAppend("Possibly use oil of expertise to equalise basestats." + ($items[cherry,oil of expertise].available_amount() == 0 ? "|Can get a cherry from novelty tropical skeleton in the skeleton store. Run +234% item." : ""));
                    if (my_class() == $class[pastamancer]) description.listAppend("Or use pastamancer thralls.");
                }
            }
        }
        else if (service_name == "Reduce Gazelle Population")
        {
            image_name = "__item weird gazelle steak";
            modifiers.listAppend("+weapon damage, +weapon damage percent");
            short_test_description = "melee damage, melee damage percent";
            numeric_modifiers = $strings[Weapon Damage,Weapon Damage Percent];
            if ($skill[Bow-Legged Swagger].have_skill() && $effect[Bow-Legged Swagger].have_effect() == 0 && !get_property_boolean("_bowleggedSwaggerUsed"))
            {
            	description.listAppend("Cast Bow-Legged Swagger for twice effectiveness.");
            }
        }
        else if (service_name == "Make Sausage")
        {
            image_name = "__item sausage without a cause";
            modifiers.listAppend("+spell damage, +spell damage percent");
            short_test_description = "spell damage";
            numeric_modifiers = $strings[Spell Damage,Spell Damage Percent];
        }
        else if (service_name == "Clean Steam Tunnels")
        {
            image_name = "__item vintage smart drink";
        	//FIXME red
            modifiers.listAppend("+hot resistance");
            short_test_description = "hot resistance";
            numeric_modifiers = $strings[Hot Resistance];
        }
        else if (service_name == "Breed More Collies")
        {
            image_name = "__item squeaky toy rose";
            modifiers.listAppend("+familiar weight");
            short_test_description = "familiar weight";
            numeric_modifiers = $strings[Familiar Weight];
        }
        else if (service_name == "Be a Living Statue")
        {
            image_name = "__item silver face paint";
            modifiers.listAppend("-combat");
            short_test_description = "-combat";
            numeric_modifiers = $strings[Combat Rate];
            prefer_negative = true;
        }
        
        turns = clampi(turns, 1, 60);
        if (short_test_description != "")
	        description.listAppend("Buff " + short_test_description + ".");
        
        
        
        
        description.listAppend(pluralise(turns, "turn", "turns") + ".");
        task_entries.listAppend(ChecklistEntryMake(173, image_name, "council.php", ChecklistSubentryMake(service_name, modifiers, description)));
    }
    //equaliser potions
    /*if (true)
    {
        item [int] hp_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Buffed HP Maximum", 150.0, blocklist); //what a strange lookup name
        item [int] hp_potions_2 = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Maximum HP", 150.0, blocklist); //something else?
        
        item [int] muscle_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Muscle", 0.0, blocklist);
        item [int] muscle_percent_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Muscle Percent", 0.0, blocklist);
        
        
        string [int] relevant_potions_output;
        foreach key, it in hp_potions
        {
            relevant_potions_output.listAppend(it + " (+" + it.to_effect().numeric_modifier("Buffed HP Maximum").roundForOutput(0) + ")");
        }
        
        task_entries.listAppend(ChecklistEntryMake(174, "__item helmet turtle", "council.php", ChecklistSubentryMake("Perform HP service", "+hp", relevant_potions_output.listJoinComponents(", ", "and"))));
    }
    
    
    foreach s in $strings[Buffed HP Maximum,Muscle,Muscle Percent,Moxie,Moxie Percent,Mysticality,Mysticality Percent,Weapon Damage,Weapon Damage Percent,spell damage, spell damage percent,Combat Rate,hot resistance]
    {
        item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier(s, -100000.0, blocklist); //what a strange lookup name
        string [int] relevant_potions_output;
        foreach key, it in relevant_potions
        {
            relevant_potions_output.listAppend(it + " (+" + it.to_effect().numeric_modifier(s).roundForOutput(0) + ")");
        }
        task_entries.listAppend(ChecklistEntryMake(175, "__item helmet turtle", "council.php", ChecklistSubentryMake("Perform " + s + " service", "", relevant_potions_output.listJoinComponents(", ", "and"))));
    }*/
}
