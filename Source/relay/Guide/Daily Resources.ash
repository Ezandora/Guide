import "relay/Guide/QuestState.ash"
import "relay/Guide/Support/Checklist.ash"
import "relay/Guide/Support/LocationAvailable.ash"
import "relay/Guide/Sets/Sets import.ash"



string [int] generateHotDogLine(string hotdog, string description, int fullness)
{
    description += " " + fullness + " full.";
    if (availableFullness() < fullness)
    {
        hotdog = HTMLGenerateSpanOfClass(hotdog , "r_future_option");
        description = HTMLGenerateSpanOfClass(description , "r_future_option");
    }
    return listMake(hotdog, description);
}


void generateDailyResources(Checklist [int] checklists)
{
	ChecklistEntry [int] resource_entries;
		
	SetsGenerateResources(resource_entries);
    QuestsGenerateResources(resource_entries);
	
	if (!get_property_boolean("_fancyHotDogEaten") && availableFullness() > 0 && __misc_state["VIP available"] && __misc_state["can eat just about anything"] && $item[Clan hot dog stand].is_unrestricted()) //too expensive to use outside a run? well, more that it's information overload
	{
		
		string name = "Fancy hot dog edible";
		string [int] description;
		string image_name = "basic hot dog";
		
        string [int][int] options;
		options.listAppend(generateHotDogLine("Optimal Dog", "Semi-rare next adventure.", 1));
        
        if (__misc_state["in run"])
        {
            options.listAppend(generateHotDogLine("Ghost Dog", "-combat, 30 turns.", 3));
            options.listAppend(generateHotDogLine("Video Game Hot Dog", "+25% item, +25% meat, pixels, 50 turns.", 3));
            options.listAppend(generateHotDogLine("Junkyard dog", "+combat, 30 turns.", 3));
            if (!__quest_state["Level 8"].finished || __quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
                options.listAppend(generateHotDogLine("Devil dog", "+3 cold/spooky res, 30 turns.", 3));
            if (!__quest_state["Level 9"].state_boolean["Peak Stench Completed"])
                options.listAppend(generateHotDogLine("Chilly dog", "+10ML and +3 stench/sleaze res, 30 turns.", 3));
            if (my_primestat() == $stat[muscle])
                options.listAppend(generateHotDogLine("Savage macho dog", "+50% muscle, 50 turns.", 2));
            if (my_primestat() == $stat[mysticality])
                options.listAppend(generateHotDogLine("One with everything", "+50% mysticality, 50 turns.", 2));
            if (my_primestat() == $stat[moxie])
                options.listAppend(generateHotDogLine("Sly Dog", "+50% moxie, 50 turns.", 2));
            if (__misc_state["need to level"] && __misc_state["Chateau Mantegna available"] && !$skill[Dog Tired].have_skill())
                options.listAppend(generateHotDogLine("Sleeping dog", "5 free rests/day (stats at chateau)", 2));
        }
			
        description.listAppend(HTMLGenerateSimpleTableLines(options));
		resource_entries.listAppend(ChecklistEntryMake(image_name, "clan_viplounge.php?action=hotdogstand", ChecklistSubentryMake(name, "", description), 5));
	}
	
		
	if (!get_property_boolean("_olympicSwimmingPoolItemFound") && __misc_state["VIP available"] && $item[Olympic-sized Clan crate].is_unrestricted())
		resource_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "", ChecklistSubentryMake("Dive for swimming pool item", "", "\"swim item\" in GCLI"), 5));
	if (!get_property_boolean("_olympicSwimmingPool") && __misc_state["VIP available"] && $item[Olympic-sized Clan crate].is_unrestricted())
		resource_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "clan_viplounge.php?action=swimmingpool", ChecklistSubentryMake("Swim in VIP pool", "50 turns", listMake("+20 ML, +30% init", "Or -combat")), 5));
	if (!get_property_boolean("_aprilShower") && __misc_state["VIP available"] && $item[Clan shower].is_unrestricted())
	{
		string [int] description;
		if (__misc_state["need to level"])
			description.listAppend("+mainstat gains. (50 turns)");
        
        string [int] reasons;
        if ($item[double-ice cap].available_amount() == 0)
            reasons.listAppend("nice hat");
        if ($familiar[fancypants scarecrow].familiar_is_usable() && $item[double-ice britches].available_amount() == 0)
            reasons.listAppend("scarecrow pants");
        //if (!__quest_state["Level 13"].state_boolean["past tower monsters"]) //don't think this is true
            //reasons.listAppend("situational tower killing");
        
        if (reasons.count() > 0)
            description.listAppend("Double-ice. (" + reasons.listJoinComponents(", ", "and") + ")");
        else
            description.listAppend("Double-ice.");
		
		resource_entries.listAppend(ChecklistEntryMake("__item shard of double-ice", "clan_viplounge.php?action=shower", ChecklistSubentryMake("Take a shower", description), 5));
	}
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 && $item[Clan pool table].is_unrestricted())
    {
        int games_available = 3 - get_property_int("_poolGames");
        string [int] description;
        if (__misc_state["familiars temporarily blocked"])
            description.listAppend("+50% weapon damage. (aggressively)");
        else
            description.listAppend("+5 familiar weight, +50% weapon damage. (aggressively)");
        description.listAppend("Or +50% spell damage, +10 MP regeneration. (strategically)");
        description.listAppend("Or +10% item, +50% init. (stylishly)");
		resource_entries.listAppend(ChecklistEntryMake("__item pool cue", "clan_viplounge.php?action=pooltable", ChecklistSubentryMake(pluralise(games_available, "pool table game", "pool table games"), "10 turns", description), 5));
    }
    if (__quest_state["Level 6"].finished && !get_property_boolean("friarsBlessingReceived"))
    {
        string [int] description;
        if (!__misc_state["familiars temporarily blocked"])
        {
            description.listAppend("+Familiar experience.");
            description.listAppend("Or +30% food drop.");
        }
        else
            description.listAppend("+30% food drop.");
        description.listAppend("Or +30% booze drop.");
        boolean should_output = true;
        if (!__misc_state["in run"])
        {
            should_output = false;
        }
        if (!should_output && familiar_weight(my_familiar()) < 20 && my_familiar() != $familiar[none])
        {
            description.listClear();
            description.listAppend("+Familiar experience.");
            should_output = true;
        }
        if (should_output)
            resource_entries.listAppend(ChecklistEntryMake("Monk", "friars.php", ChecklistSubentryMake("Forest Friars buff", "20 turns", description), 10));
    }
	
	
	
	
	
	
	if (!get_property_boolean("_madTeaParty") && __misc_state["VIP available"] && $item[Clan looking glass].is_unrestricted())
	{
        string [int] description;
        string line = "Various effects.";
        if (__misc_state["in run"] && my_path_id() != PATH_ZOMBIE_SLAYER && $item[pail].available_amount() > 0)
        {
            line = "+20ML";
            line += "|Or various effects.";
        }
        description.listAppend(line);
		resource_entries.listAppend(ChecklistEntryMake("__item insane tophat", "", ChecklistSubentryMake("Mad tea party", "30 turns", description), 5));
	}
	
	if (true)
	{
        string image_name = "__item hell ramen";
		ChecklistSubentry [int] subentries;
		if (availableFullness() > 0)
		{
            string [int] description;
            if ($effect[Got Milk].have_effect() > 0)
                description.listAppend(pluralise($effect[Got Milk]) + " available.");
			subentries.listAppend(ChecklistSubentryMake(availableFullness() + " fullness", "", description));
		}
		if (availableDrunkenness() >= 0 && inebriety_limit() > 0)
        {
            string title = "";
            string [int] description;
            if (subentries.count() == 0)
                image_name = "__item gibson";
            if ($effect[ode to booze].have_effect() > 0)
                description.listAppend(pluralise($effect[ode to booze]) + " available.");
            
            if (availableDrunkenness() > 0)
                title = availableDrunkenness() + " drunkenness";
            else
                title = "Can overdrink";
			subentries.listAppend(ChecklistSubentryMake(title, "", description));
        }
		if (availableSpleen() > 0)
		{
            if (subentries.count() == 0)
                image_name = "__item agua de vida";
			subentries.listAppend(ChecklistSubentryMake(availableSpleen() + " spleen", "", ""));
		}
		if (subentries.count() > 0)
			resource_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=1", subentries, 11));
	}
	
	if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
	{
		string [int] description;
		description.listAppend("Contains one (1) monarch.");
        description.listAppend(pluralise(my_ascensions(), "king", "kings") + " freed." + (my_ascensions() > 250 ? " Collect them all!" : ""));
        string image_name;
        image_name = "__effect sleepy";
		resource_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=nstower", ChecklistSubentryMake("1 Prism", "", description), 10));
	}
    
    if ((get_property("sidequestOrchardCompleted") == "hippy" || get_property("sidequestOrchardCompleted") == "fratboy") && !get_property_boolean("_hippyMeatCollected"))
    {
		resource_entries.listAppend(ChecklistEntryMake("__item herbs", "island.php", ChecklistSubentryMake("Meat from the hippy store", "", "~4500 free meat."), 5)); //FIXME consider shop.php?whichshop=hippy
    }
    if ((get_property("sidequestArenaCompleted") == "hippy" || get_property("sidequestArenaCompleted") == "fratboy") && !get_property_boolean("concertVisited"))
    {
        string [int] description;
        if (get_property("sidequestArenaCompleted") == "hippy")
        {
            if (!__misc_state["familiars temporarily blocked"])
                description.listAppend("+5 familiar weight.");
            description.listAppend("Or +20% item.");
            if (__misc_state["need to level"])
                description.listAppend("Or +5 stats/fight.");
        }
        else if (get_property("sidequestArenaCompleted") == "fratboy")
        {
            description.listAppend("+40% meat.");
            description.listAppend("+50% init.");
            description.listAppend("+10% all attributes.");
        }
        
        string url = "bigisland.php?place=concert";
        if (__quest_state["Level 12"].finished)
            url = "postwarisland.php?place=concert";
		resource_entries.listAppend(ChecklistEntryMake("__item the legendary beat", url, ChecklistSubentryMake("Arena concert", "20 turns", description), 5));
    }
    
    //Not sure how I feel about this. It's kind of extraneous?
    if (get_property_int("telescopeUpgrades") > 0 && !get_property_boolean("telescopeLookedHigh") && __misc_state["in run"] && availableDrunkenness() < 0 && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING && !in_bad_moon() && my_path_id() != PATH_NUCLEAR_AUTUMN)
    {
        string [int] description;
        int percentage = 5 * get_property_int("telescopeUpgrades");
        description.listAppend("+" + (percentage == 25 ? "35% or +25" : percentage) + "% to all attributes. (10 turns)");
		resource_entries.listAppend(ChecklistEntryMake("__effect Starry-Eyed", "campground.php?action=telescope", ChecklistSubentryMake("Telescope buff", "", description), 10));
    }
    
    
    if (__misc_state_int["free rests remaining"] > 0)
    {
        string [int] description;
        
        if (__misc_state["recommend resting at campsite"])
        {
            float resting_hp_percent = numeric_modifier("resting hp percent") / 100.0;
            float resting_mp_percent = numeric_modifier("resting mp percent") / 100.0;
            
            //FIXME trace down every rest effect and make this more accurate, instead of an initial guess.
            
            //If grimace or ronald is full, they double the gains of everything else.
            //This is reported as a modifier of +100% - so with pagoda, that's +200% HP
            //But, it's actually +300%, or 400% total. I could be wrong about this - my knowledge of rest mechanics is limited.
            //So, we'll explicitly check for grimace or ronald being full, then recalculate. Not great, but should work okay?
            //This is probably inaccurate in a great number of cases, due to the complication of resting.
            
            float overall_multiplier_hp = 1.0;
            float overall_multiplier_mp = 1.0;
            float bonus_resting_hp = numeric_modifier("bonus resting hp");
            float after_bonus_resting_hp = 0.0;
            int grimace_light = moon_phase() / 2;
            int ronald_light = moon_phase() % 8;
            if (grimace_light == 4)
            {
                resting_hp_percent -= 1.0;
                overall_multiplier_hp += 1.0;
            }
            if (ronald_light == 4)
            {
                resting_mp_percent -= 1.0;
                overall_multiplier_mp += 1.0;
            }
            
            if ($effect[L'instinct F&eacute;lin].have_effect() > 0) //not currently tracked by mafia. Seems to triple HP/MP gains.
            {
                overall_multiplier_hp *= 3.0;
                overall_multiplier_mp *= 3.0;
            }
            
            if ((get_campground() contains $item[gauze hammock]))
            {
                //Gauze hammock appears to be a flat addition applied after everything else, including grimace, pagoda, and l'instinct.
                //It shows up it bonus resting hp - we'll remove that, and add it back at the end.
                bonus_resting_hp -= 60.0;
                after_bonus_resting_hp += 60.0;
            }
            
            //FIXME chateau restore is different
            float rest_hp_restore = after_bonus_resting_hp + overall_multiplier_hp * (numeric_modifier("base resting hp") * (1.0 + resting_hp_percent) + bonus_resting_hp);
            float rest_mp_restore = overall_multiplier_mp * (numeric_modifier("base resting mp") * (1.0 + resting_mp_percent) + numeric_modifier("bonus resting mp"));
            description.listAppend(rest_hp_restore.floor() + " HP, " + rest_mp_restore.floor() + " MP");
            
            if ($item[pantsgiving].available_amount() > 0) //FIXME is pantsgiving intended to help at chateau?
            {
                if ($item[pantsgiving].equipped_amount() == 0)
                    description.listAppend("Wear pantsgiving for extra HP/MP.");
                if (availableFullness() > 0)
                    description.listAppend("Eat more for +" + (availableFullness() * 5) + " extra HP/MP.");
            }
        }
        else if (__misc_state_string["resting description"] == "Chateau Mantegna")
        {
            //FIXME what goes here
            if (my_path_id() == PATH_THE_SOURCE)
                description.listAppend("HP/MP.");
            else
                description.listAppend("HP/MP/stats.");
            if (my_level() < 9 && my_path_id() != PATH_THE_SOURCE)
                description.listAppend("May want to wait until level 9(?) for more stats from resting.");
            
            stat desired_stat = $stat[none];
            int [item] chateau = get_chateau();
            
            if (chateau[$item[electric muscle stimulator]] > 0)
                desired_stat = $stat[muscle];
            else if (chateau[$item[foreign language tapes]] > 0)
                desired_stat = $stat[mysticality];
            else if (chateau[$item[bowl of potpourri]] > 0)
                desired_stat = $stat[moxie];
            item [int] items_equipping = generateEquipmentToEquipForExtraExperienceOnStat(desired_stat);
            if (items_equipping.count() > 0 && __misc_state["need to level"])
                description.listAppend("Could equip " + items_equipping.listJoinComponents(", ", "or") + " for more stats.");
        }
        
		resource_entries.listAppend(ChecklistEntryMake("__effect sleepy", __misc_state_string["resting url"], ChecklistSubentryMake(pluraliseWordy(__misc_state_int["free rests remaining"], "free rest", "free rests").capitaliseFirstLetter(), "", description), 10));
    }
    
    //FIXME skate park?
    
    if (my_path_id() != PATH_BEES_HATE_YOU && !get_property_boolean("guyMadeOfBeesDefeated") && get_property_int("guyMadeOfBeesCount") > 0 && (__misc_state["in aftercore"] || !__quest_state["Level 12"].state_boolean["Arena Finished"]))
    {
        //Not really worthwhile? But I suppose we can track it if they've started it, and are either in aftercore or haven't flyered yet.
        //For flyering, it's 20 turns at -25%, 25 turns at -15%. 33 turns at -5%. Not worthwhile?
        int summon_count = get_property_int("guyMadeOfBeesCount");
        
        string [int] description;
        string times = "";
        if (summon_count == 4)
            times = "One More Time.";
        else
            times = int_to_wordy(5 - summon_count) + " times.";
        description.listAppend("Speak his name " + times);
        if ($item[antique hand mirror].available_amount() == 0)
            description.listAppend("Need antique hand mirror to win. Or towerkill.");
		resource_entries.listAppend(ChecklistEntryMake("__item guy made of bee pollen", $location[the haunted bathroom].getClickableURLForLocation(), ChecklistSubentryMake("The Guy Made Of Bees", "", description), 10));
    }
    
    if (stills_available() > 0)
    {
        string [int] description;
        string [int] mixables;
        if (__misc_state["can drink just about anything"] && my_path_id() != PATH_SLOW_AND_STEADY)
        {
            mixables.listAppend("neuromancer-level drinks");
        }
        mixables.listAppend("~40MP from tonic water");
        
        description.listAppend(mixables.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
        
		resource_entries.listAppend(ChecklistEntryMake("Superhuman Cocktailcrafting", "shop.php?whichshop=still", ChecklistSubentryMake(pluralise(stills_available(), "still use", "still uses"), "", description), 10));
    }
    
    if (__last_adventure_location == $location[The Red Queen\'s Garden])
    {
        string will_need_effect = "";
        if ($effect[down the rabbit hole].have_effect() == 0)
            will_need_effect = "|Will need to use &quot;DRINK ME&quot; potion first.";
        if (get_property_int("pendingMapReflections") > 0)
            resource_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "place.php?whichplace=rabbithole", ChecklistSubentryMake(pluralise(get_property_int("pendingMapReflections"), "pending reflection of a map", "pending reflections of a map"), "+900% item", "Adventure in the Red Queen's garden to acquire." + will_need_effect), 0));
        if ($items[reflection of a map].available_amount() > 0)
        {
            resource_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "inventory.php?which=3&ftext=reflection+of+a+map", ChecklistSubentryMake(pluralise($item[reflection of a map]), "", "Queen cookies." + will_need_effect), 0));
        }
    }
    
    if (__misc_state["VIP available"])
    {
        if (!get_property_boolean("_lookingGlass") && $item[Clan looking glass].is_unrestricted())
        {
            resource_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", "clan_viplounge.php?whichfloor=2", ChecklistSubentryMake("A gaze into the looking glass", "", "Acquire a " + $item[&quot;DRINK ME&quot; potion] + "."), 10));
        }
        //_deluxeKlawSummons?
        //_crimboTree?
        int soaks_remaining = __misc_state_int["hot tub soaks remaining"];
        if (__misc_state["in run"] && soaks_remaining > 0 && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING && my_path_id() != PATH_VAMPIRE)
        {
            string description = "Restore all HP, removes most bad effects.";
            resource_entries.listAppend(ChecklistEntryMake("__effect blessing of squirtlcthulli", "clan_viplounge.php", ChecklistSubentryMake(pluralise(soaks_remaining, "hot tub soak", "hot tub soaks"), "", description), 8));
        }
        
        
    }
    //_klawSummons?
    
    //Skill books we have used, but don't have the skill for?
    
    //soul sauce tracking?
    
    if ($item[can of rain-doh].available_amount() > 0 && $item[empty rain-doh can].available_amount() == 0 && __misc_state["in run"])
    {
        resource_entries.listAppend(ChecklistEntryMake("__item can of rain-doh", "inventory.php?which=3&ftext=can+of+rain-doh", ChecklistSubentryMake("Can of Rain-Doh", "", "Open it!"), 0));
    }
    
    
    
    if (get_property_int("goldenMrAccessories") > 0)
    {
        //FIXME inline with hugs
        int total_casts_available = get_property_int("goldenMrAccessories") * 5;
        int casts_used = get_property_int("_smilesOfMrA");
        
        int casts_remaining = total_casts_available - casts_used;
        
        if (casts_remaining > 0)
        {
            string image_name = "__item Golden Mr. Accessory";
            if (my_id() == 1043600)
                image_name = "__item defective Golden Mr. Accessory"; //does not technically give out sunshine, but...
            resource_entries.listAppend(ChecklistEntryMake(image_name, "skills.php", ChecklistSubentryMake(pluralise(casts_remaining, "smile of the Mr. Accessory", "smiles of the Mr. Accessory"), "", "Give away sunshine."), 8));
        }
    }
    
    if (__misc_state["Chateau Mantegna available"] && !get_property_boolean("_chateauDeskHarvested"))
    {
        string image_name = "__item fancy calligraphy pen";
        resource_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=chateau", ChecklistSubentryMake("Chateau desk openable", "", "Daily collectable."), 8));
    }
	
	checklists.listAppend(ChecklistMake("Resources", resource_entries));
}
