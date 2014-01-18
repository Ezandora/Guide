import "relay/Guide/QuestState.ash"
import "relay/Guide/Support/Checklist.ash"
import "relay/Guide/Support/LocationAvailable.ash"
import "relay/Guide/Sets/Sets import.ash"




void generateDailyResources(Checklist [int] checklists)
{
	ChecklistEntry [int] available_resources_entries;
		
	SetsGenerateResources(available_resources_entries);
	
	if (!get_property_boolean("_fancyHotDogEaten") && availableFullness() > 0 && __misc_state["VIP available"] && __misc_state["can eat just about anything"] && __misc_state["In run"]) //too expensive to use outside a run?
	{
		
		string name = "Fancy hot dog edible";
		string [int] description;
		string image_name = "basic hot dog";
		
		description.listAppend("Optimal Dog - Forces semi-rare next adventure");
		description.listAppend("Video Game Hot Dog - +25% item drops, +25% meat drops");
		description.listAppend("Scaredy Dog - -combat");
		description.listAppend("Junkyard dog - +combat, marginal");
		if (my_primestat() == $stat[muscle])
			description.listAppend("Savage macho dog - +50% muscle, leveling against scaling monsters?");
		if (my_primestat() == $stat[mysticality])
			description.listAppend("One with everything - +50% mysticality, leveling against scaling monsters?");
		if (my_primestat() == $stat[moxie])
			description.listAppend("Top Dog - +50% moxie, leveling against scaling monsters?");
			
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, "", ChecklistSubentryMake(name, "1 fullness", description), 5));
	}
	
		
	if (!get_property_boolean("_olympicSwimmingPoolItemFound") && __misc_state["VIP available"])
		available_resources_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "", ChecklistSubentryMake("Dive for swimming pool item", "", "\"swim item\" in GCLI"), 5));
	if (!get_property_boolean("_olympicSwimmingPool") && __misc_state["VIP available"])
		available_resources_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "clan_viplounge.php?action=swimmingpool", ChecklistSubentryMake("Swim in VIP pool", "50 turns", listMake("+20 ML, +30% init", "Or -combat")), 5));
	if (!get_property_boolean("_aprilShower") && __misc_state["VIP available"])
	{
		string [int] description;
		if (__misc_state["need to level"])
			description.listAppend("+mainstat gains (50 turns)");
		description.listAppend("Double-ice (nice hat, scarecrow pants, tower killing)");
		
		available_resources_entries.listAppend(ChecklistEntryMake("__item shard of double-ice", "", ChecklistSubentryMake("Take a shower", description), 5));
	}
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 )
    {
        int games_available = 3 - get_property_int("_poolGames");
        string [int] description;
        description.listAppend("+5 familiar weight, +50% weapon damage.");
        description.listAppend("Or +10% item, +50% init.");
        description.listAppend("Or +50% spell damage, +10 MP regeneration.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item pool cue", "clan_viplounge.php?action=pooltable", ChecklistSubentryMake(pluralize(games_available, "pool table game", "pool table games"), "10 turns", description), 5));
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
        if (!__misc_state["In run"])
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
            available_resources_entries.listAppend(ChecklistEntryMake("Monk", "friars.php", ChecklistSubentryMake("Forest Friars buff", "20 turns", description), 10));
    }
	
	
	
	
	
	
	if (!get_property_boolean("_madTeaParty") && __misc_state["VIP available"])
	{
        string [int] description;
        string line = "Various effects.";
        if (__misc_state["In run"])
        {
            line = "+20ML";
            if ($item[pail].available_amount() == 0)
                line += " with pail (you don't have one, talk to artist)";
            line += "|Or various effects.";
        }
        description.listAppend(line);
		available_resources_entries.listAppend(ChecklistEntryMake("__item insane tophat", "", ChecklistSubentryMake("Mad tea party", "30 turns", description), 5));
	}
	
	if (true)
	{
        string image_name = "__item hell ramen";
		ChecklistSubentry [int] subentries;
		if (availableFullness() > 0)
		{
            string [int] description;
            if ($effect[Got Milk].have_effect() > 0)
                description.listAppend(pluralize($effect[Got Milk]) + " available.");
			subentries.listAppend(ChecklistSubentryMake(availableFullness() + " fullness", "", description));
		}
		if (availableDrunkenness() >= 0 && inebriety_limit() > 0)
        {
            string title = "";
            string [int] description;
            if (subentries.count() == 0)
                image_name = "__item gibson";
            if ($effect[ode to booze].have_effect() > 0)
                description.listAppend(pluralize($effect[ode to booze]) + " available.");
            
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
			available_resources_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=1", subentries, 11));
	}
	
	if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
	{
		string [int] description;
		description.listAppend("Contains 1 monarch.");
        description.listAppend(pluralize(my_ascensions(), "king", "kings") + " freed.");
        string image_name;
        image_name = "__effect sleepy";
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, "lair6.php", ChecklistSubentryMake("1 Prism", "", description), 10));
	}
    
    if ((get_property("sidequestOrchardCompleted") == "hippy" || get_property("sidequestOrchardCompleted") == "fratboy") && !get_property_boolean("_hippyMeatCollected"))
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item herbs", "", ChecklistSubentryMake("Meat from the hippy store", "", "~4500 free meat."), 5));
    }
    if ((get_property("sidequestArenaCompleted") == "hippy" || get_property("sidequestArenaCompleted") == "fratboy") && !get_property_boolean("concertVisited"))
    {
        string [int] description;
        if (get_property("sidequestArenaCompleted") == "hippy")
        {
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
		available_resources_entries.listAppend(ChecklistEntryMake("__item the legendary beat", url, ChecklistSubentryMake("Arena concert", "20 turns", description), 5));
    }
    
    //Not sure how I feel about this. It's kind of extraneous?
    //Disabled for now.
    /*if (get_property_int("telescopeUpgrades") > 0 && !get_property_boolean("telescopeLookedHigh") && __misc_state["In run"])
    {
        string [int] description;
        int percentage = 5 * get_property_int("telescopeUpgrades");
        description.listAppend("+" + percentage + "% to all attributes. (10 turns)");
		available_resources_entries.listAppend(ChecklistEntryMake("__effect Starry-Eyed", "campground.php?action=telescope", ChecklistSubentryMake("Telescope buff", "", description), 10));
    }*/
    
    
    if (__misc_state_int["free rests remaining"] > 0)
    {
        //FIXME we could show that the MP/HP restore will be?
        //very difficult, I think?
        string [int] description;
		available_resources_entries.listAppend(ChecklistEntryMake("__effect sleepy", "campground.php", ChecklistSubentryMake(pluralizeWordy(__misc_state_int["free rests remaining"], "free rest", "free rests").capitalizeFirstLetter(), "", description), 10));
    }
    
    if (in_bad_moon() && !get_property_boolean("styxPixieVisited"))
    {
        string [int] description;
        description.listAppend("+40% meat, +20% items, +25% moxie.");
        description.listAppend("Or +25% mysticality, +10-15 mp regen.");
        description.listAppend("Or +25% muscle, +5 DR.");
		available_resources_entries.listAppend(ChecklistEntryMake("__effect Hella Smooth", "", ChecklistSubentryMake("Styx pixie buff", "", description), 10));
    }
    
    //FIXME skate park?
    
    if (my_path() != "Bees Hate You" && !get_property_boolean("guyMadeOfBeesDefeated") && get_property_int("guyMadeOfBeesCount") > 0 && (__misc_state["In aftercore"] || !__quest_state["Level 12"].state_boolean["Arena Finished"]))
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
		available_resources_entries.listAppend(ChecklistEntryMake("__item guy made of bee pollen", "place.php?whichplace=spookyraven2", ChecklistSubentryMake("The Guy Made Of Bees", "", description), 10));
    }
    
    if (stills_available() > 0)
    {
        string [int] description;
        string [int] mixables;
        if (__misc_state["can drink just about anything"])
        {
            mixables.listAppend("neuromancer-level drinks");
        }
        mixables.listAppend("~40MP from tonic water");
        
        description.listAppend(mixables.listJoinComponents(", ", "or").capitalizeFirstLetter() + ".");
        
		available_resources_entries.listAppend(ChecklistEntryMake("Superhuman Cocktailcrafting", "guild.php?place=still", ChecklistSubentryMake(pluralize(stills_available(), "still use", "still uses"), "", description), 10));
    }
    
    if (my_class() == $class[seal clubber])
    {
        //Seal summons:
        //FIXME suggest they equip a club (support swords with iron palms)
        int seal_summon_limit = 5;
        if ($item[Claw of the Infernal Seal].available_amount() > 0)
            seal_summon_limit = 10;
        int seals_summoned = get_property_int("_sealsSummoned");
        int summons_remaining = MAX(seal_summon_limit - seals_summoned, 0);
        
        string [int] description;
        
        //description left blank, due to possible revamp?
        
        if (summons_remaining > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item figurine of an ancient seal", "", ChecklistSubentryMake(pluralize(summons_remaining, "seal summon", "seal summons"), "", description), 10));
    }
    
    if (__misc_state["VIP available"])
    {
        if (!get_property_boolean("_lookingGlass"))
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", "clan_viplounge.php", ChecklistSubentryMake("A gaze into the looking glass", "", "Acquire a " + $item[&quot;DRINK ME&quot; potion] + "."), 10));
        }
        //_deluxeKlawSummons?
        //_crimboTree?
        
    }
    //_klawSummons?
    
    //Skill books we have used, but don't have the skill for?
    
	
	checklists.listAppend(ChecklistMake("Resources", available_resources_entries));
}