void SGrimstoneHareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    modifiers.listAppend("mysticality");
    modifiers.listAppend("spell damage percent");
    modifiers.listAppend("spell critical percent");
    int time_remaining = $effect[hare-brained].have_effect();
    
    //FIXME deal with coldform / hotform / etc
    
    description.listAppend("Adventure on the deserted stretch of road.|Cast elemental-aligned powerful spells on vehicles.|The more damage, the faster you go.");
    
    description.listAppend("The speedy/expensive strategy is to nanorhino/ice house/batter up/pantsgiving/crystal skull/etc. banish everything that isn't an ice cream truck, and olfact ice cream trucks.|Then run coldform, buff spell damage, mysticality, and spell damage critical.|Then cast shrap.");
    
    string [string] elemental_descriptions;
    
    string [int] missing_hobopolis_spells;
    
    elemental_descriptions["hot"] = HTMLGenerateSpanOfClass("hot", "r_element_hot");
    elemental_descriptions["cold"] = HTMLGenerateSpanOfClass("cold", "r_element_cold");
    elemental_descriptions["spooky"] = HTMLGenerateSpanOfClass("spooky", "r_element_spooky");
    elemental_descriptions["stench"] = HTMLGenerateSpanOfClass("stench", "r_element_stench");
    elemental_descriptions["sleaze"] = HTMLGenerateSpanOfClass("sleaze", "r_element_sleaze");
    
    
    boolean have_shrap = $skill[shrap].skill_is_usable();
    
    if (have_shrap && $effect[hotform].have_effect() > 0)
        elemental_descriptions["hot"] = "Shrap (" + elemental_descriptions["hot"] + ")";
    else if ($skill[volcanometeor showeruption].skill_is_usable())
        elemental_descriptions["hot"] = "Volcanometeor Showeruption (" + elemental_descriptions["hot"] + ")";
    else if ($skill[Awesome Balls of Fire].skill_is_usable())
        elemental_descriptions["hot"] = "Awesome Balls of Fire (" + elemental_descriptions["hot"] + ")";
    else
        missing_hobopolis_spells.listAppend("Awesome Balls of Fire");
    
    
    if (have_shrap && $effect[coldform].have_effect() > 0)
        elemental_descriptions["cold"] = "Shrap (" + elemental_descriptions["cold"] + ")";
    else if ($skill[Snowclone].skill_is_usable())
        elemental_descriptions["cold"] = "Snowclone (" + elemental_descriptions["cold"] + ")";
    else
        missing_hobopolis_spells.listAppend("Snowclone");
    
    if (have_shrap && $effect[spookyform].have_effect() > 0)
        elemental_descriptions["spooky"] = "Shrap (" + elemental_descriptions["spooky"] + ")";
    else if ($skill[Raise Backup Dancer].skill_is_usable())
        elemental_descriptions["spooky"] = "Raise Backup Dancer (" + elemental_descriptions["spooky"] + ")";
    else
        missing_hobopolis_spells.listAppend("Raise Backup Dancer");
    
    if (have_shrap && $effect[stenchform].have_effect() > 0)
        elemental_descriptions["stench"] = "Shrap (" + elemental_descriptions["stench"] + ")";
    else if ($skill[Eggsplosion].skill_is_usable())
        elemental_descriptions["stench"] = "Eggsplosion (" + elemental_descriptions["stench"] + ")";
    else
        missing_hobopolis_spells.listAppend("Eggsplosion");
    
    
    if (have_shrap && $effect[sleazeform].have_effect() > 0)
        elemental_descriptions["sleaze"] = "Shrap (" + elemental_descriptions["sleaze"] + ")";
    else if ($skill[Grease Lightning].skill_is_usable())
        elemental_descriptions["sleaze"] = "Grease Lightning (" + elemental_descriptions["sleaze"] + ")";
    else
        missing_hobopolis_spells.listAppend("Grease Lightning");
    
    
    
    string [int][int] vehicle_descriptions;
    if (!$monster[Fire truck].is_banished())
        vehicle_descriptions.listAppend(listMake("Fire truck", elemental_descriptions["hot"]));
    if (!$monster[ice cream truck].is_banished())
        vehicle_descriptions.listAppend(listMake("ice cream truck", elemental_descriptions["cold"]));
    if (!$monster[monster hearse].is_banished())
        vehicle_descriptions.listAppend(listMake("monster hearse", elemental_descriptions["spooky"]));
    if (!$monster[sewer tanker].is_banished())
        vehicle_descriptions.listAppend(listMake("sewer tanker", elemental_descriptions["stench"]));
    if (!$monster[sketchy van].is_banished())
        vehicle_descriptions.listAppend(listMake("sketchy van", elemental_descriptions["sleaze"]));
    
    monster last_encounter = get_property_monster("lastEncounter");
    string [int] vehicles = split_string_alternate("Fire truck,ice cream truck,monster hearse,sewer tanker,sketchy van", ",");
    
    foreach key in vehicles
    {
        monster vehicle = vehicles[key].to_monster();
        if (vehicle == $monster[none])
            continue;
        
        if (last_encounter != vehicle)
            continue;
        
        vehicle_descriptions[key][0] = HTMLGenerateSpanOfClass(vehicle_descriptions[key][0], "r_bold");
        vehicle_descriptions[key][1] = HTMLGenerateSpanOfClass(vehicle_descriptions[key][1], "r_bold");
    }
    
    description.listAppend("Spells to cast: " + HTMLGenerateIndentedText(HTMLGenerateSimpleTableLines(vehicle_descriptions)));
    
    if (my_familiar() != $familiar[magic dragonfish])
        description.listAppend("Run magic dragonfish familiar.");
    else if ($familiar[magic dragonfish].familiar_weight() < 20)
        description.listAppend("Gain " + (20 - $familiar[magic dragonfish].familiar_weight()) + " pounds on your magic dragonfish.");
    
    if (missing_hobopolis_spells.count() > 0)
        description.listAppend("Could acquire " + missing_hobopolis_spells.listJoinComponents(", ", "or") + " from the mall.");
    
    if ($skill[frigidalmatian].skill_is_usable() && $effect[frigidalmatian].have_effect() == 0)
        description.listAppend("Could cast frigidalmatian. (expensive)");
    
    if (my_basestat($stat[mysticality]) < 400)
        description.listAppend("May want to gain " + (400 - my_basestat($stat[mysticality])) + " more mysticality.");
    
    description.listAppend(pluralise(time_remaining, "turn", "turns") + " remaining in race.");
    
    
    
    
    //$location[A Deserted Stretch of I-911]
	optional_task_entries.listAppend(ChecklistEntryMake("__effect hare-brained", "place.php?whichplace=ioty2014_hare", ChecklistSubentryMake("Hare Race", modifiers, description)));
}

void SGrimstoneStepmotherGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    int minutes_to_midnight = get_property_int("cinderellaMinutesToMidnight");
    if (minutes_to_midnight <= 0)
        return;
    
    int score = get_property_int("cinderellaScore");
    string [int] description;
    string [int] modifiers;
    
    
    if (minutes_to_midnight > 0)
    {
        string line;
        line = pluralise(minutes_to_midnight, "minute", "minutes") + " to midnight.";
        
        if (score > 0)
            line += " " + pluralise(score, "point", "points") + " earned.";
        
        description.listAppend(line);
    }
    
    /*
        The idea behind this solution is you want to put three items into cindy's purse.
        The first two make her ignore her hankerchief and go to the restroom - where the doctored soap gives her puffy eyes - whereupon she returns and confirms the disease rumor.
        The third is the mouse, which you confront her about. Then later she'll not have the purse at all and go to the restroom again.
        
        There are other solutions, but I don't know them. Find them! It's a fun puzzle.
    */
    
    string [int][int] minute_to_action;
    minute_to_action[30] = listMake("Lounge", "Take a cigar from the sideboard"); //I say, old chap
    minute_to_action[29] = listMake("Balcony", "Examine the flowers."); //to give to prince
    minute_to_action[28] = listMake("Canapés Table", "Give your carnation to the Prince."); //causes sneezing fit at 23, 13, 3
    minute_to_action[27] = listMake("Canapés Table", "Slip something into Cindy's purse while she's distracted", "The cigar."); //Make her leave when sneezing
    minute_to_action[26] = listMake("Balcony", "Examine the flowers."); //For doctoring
    minute_to_action[25] = listMake("Restroom", "Rub the flower on the soap."); //For 23 sneezing.
    minute_to_action[24] = listMake("Lounge", "Start a rumor about Cinderella", "Cinderella has a terrible disease."); //Points!
    minute_to_action[23] = listMake("Lounge", "Take the empty cigar box."); //Mouse trap setup. 3 points (from sneezing)
    minute_to_action[22] = listMake("Kitchen", "Inspect the kitchen pantry."); //Acquire cinnamon, notice mouse hole.
    minute_to_action[21] = listMake("Canapés Table", "Take a piece of cheese."); //Mouse trap setup.
    minute_to_action[20] = listMake("Kitchen", "Set a trap for the mouse."); //Set up mouse trap with cigar box and cheese. (if we had room, soap too, but that adds one point and there's no room - used in 31-point solution)
    minute_to_action[19] = listMake("Canapés Table", "Slip something into Cindy's purse while she's distracted", "The cinnamon."); //For 13 sneezing fit, makes her ignore hankerchief.
    minute_to_action[18] = listMake("Lounge", "Take the whiskey flask."); //To make cindy drunk. 5 points (prince hears rumor)
    minute_to_action[17] = listMake("Canapés Table", "Pour some whisky into Cindy's glass."); //Cindy's drunk - used at 16, 6, and extra points from soap.
    minute_to_action[16] = listMake("Balcony", "Examine the flowers."); //For stealing a hairpin from baronness. 6 points (16 behavior hits, she's drunk)
    minute_to_action[15] = listMake("Balcony", "Speak with the Baroness."); //First step baronness
    minute_to_action[14] = listMake("Balcony", "Ask the Baroness what troubles her."); //Makes baronness move to dance floor
    minute_to_action[13] = listMake("Dance Floor", "Give your carnation to the Baroness and steal one of her hairpins."); //Now we can steal a hairpin. 11 points (sneezing fit with disease rumor)
    minute_to_action[12] = listMake("Restroom", "Look in the medicine cabinet", "Pick the lock", "Take the bottle of syrup of ipecac."); //Which we use to pick the lock of the medicine cabinet, acquiring ipecac.
    minute_to_action[11] = listMake("Kitchen", "Dose the tray of cannoli with ipecac."); //Ipecac we use here.
    minute_to_action[10] = listMake("Restroom", "Take some soap."); //We'll be throwing it later.
    minute_to_action[9] = listMake("Canapés Table", "Offer Cindy your 'customized' cannoli."); //Makes her throw up in eight turns. (no cinnamon)
    minute_to_action[8] = listMake("Kitchen", "Take the mouse out of the trap."); //It showed up. Hello mouse.
    minute_to_action[7] = listMake("Canapés Table", "Slip something into Cindy's purse while she's distracted", "The mouse."); //Third time.
    minute_to_action[6] = listMake("Canapés Table", "Ask Cindy to loan you her handkerchief."); //Hey, is that a mouse in your purse? 13 points. (one from mouse, one from 6 behavior)
    minute_to_action[5] = listMake("Dance Floor", "Kick some soap at Cindy."); //She's on the dance floor. Let's make her dance. 15 points. (dance!)
    minute_to_action[4] = listMake("Restroom", "Take some soap."); //Dancing supplies.
    minute_to_action[3] = listMake("Dance Floor", "Kick some soap at Cindy."); //Dance. 21 points (sneezing, dance!)
    minute_to_action[2] = listMake("Restroom", "Take some soap."); //Dancing supplies.
    minute_to_action[1] = listMake("Dance Floor", "Kick some soap at Cindy."); //She throws up. Dance. 32 points. (she threw up, dance!)
    
    if (false)
    {
        //output full details for reference:
        string line;
        foreach minute in minute_to_action
        {
            string description = minute_to_action[minute];
            line = "|" + pluralise(minute, "minute", "minutes") + ":|*" + minute_to_action[minute].listJoinComponents(" > ") + line;
        }
        description.listAppend(line);
    }
    //FIXME add the other two trophies?
    
    
    //int [int] needed_points_at_spot_to_be_following_correct_path; //score isn't tracked properly, and anyways there's split score per turn
    
    /*
√30	take cigar
√29	flower
√28	give flower to prince
√27	give cigar to cindy
√26	flower
√25	doctor soap
√24	spread rumour (disease)
√23	take empty cigar box
√22	inspect kitchen
√21	get cheese
√20	set trap
√19	plant cinnamon in cindy's purse
√18	get whiskey
√17	pour whiskey
√16	flower
√15	ask baronness
√14	ask baronness x2
√13	steal from baronness
√12	steal ipecac
√11	make cannoli (mouse available)
√10	get soap
√9	give cindy cannoli
√8	get mouse
√7	plant mouse
√6	ask for hankerchief
√5	kick soap
√4	get soap
√3	kick soap
√2	get soap
√1	kick soap
    */
    
    boolean output_next_step = true;
    //if (needed_points_at_spot_to_be_following_correct_path contains minutes_to_midnight && score != needed_points_at_spot_to_be_following_correct_path[minutes_to_midnight]) //they're doing a different route
        //output_next_step = false;
    
    if (minute_to_action contains minutes_to_midnight && output_next_step)
    {
        description.listAppend("Next step for 32 points:|*" + minute_to_action[minutes_to_midnight].listJoinComponents(__html_right_arrow_character));
        description.listAppend("Though, this is a fun puzzle to solve on your own.");
    }
    
    
    //FIXME add suggestions for other two trophies (partners in crime, ending party early)
	optional_task_entries.listAppend(ChecklistEntryMake("__item long-stemmed rose", "place.php?whichplace=ioty2014_cindy", ChecklistSubentryMake("The Prince's Ball", modifiers, description)));
}

void SGrimstoneWolfGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME I have no idea
}

void SGrimstoneWitchGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME I have no idea
}

void SGrimstoneGnomeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME I have no idea
}

void SGrimstoneGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //grimstoneMaskPath
    //rumpelstiltskinTurnsUsed gives number of turns used getting materials. rumpelstiltskinKidsRescued gives the number of children rescued. It is likely that there are more messages than are documented on the wiki, so if some are missing and aren't parsed correctly, please put a note in the forum.
    //cinderellaMinutesToMidnight gives number of turns remaining. cinderellaScore gives the current score. Also added grimstoneMaskPath which gives the current grimstone content available, "stepmother", "wolf", "witch", "gnome" or "hare".
    
    string mask_path = get_property("grimstoneMaskPath");
    
    if ($effect[hare-brained].have_effect() > 0)
        SGrimstoneHareGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    if (mask_path == "stepmother")
        SGrimstoneStepmotherGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    if (mask_path == "wolf")
        SGrimstoneWolfGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    if (mask_path == "witch")
        SGrimstoneWitchGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    if (mask_path == "gnome")
        SGrimstoneGnomeGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    if (mask_path == "tuxedo")
        task_entries.listAppend(ChecklistEntryMake("__item long-stemmed rose", "place.php?whichplace=arcade", ChecklistSubentryMake("Believe in yourself", "", ""), -11));
}