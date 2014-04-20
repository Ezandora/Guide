void SGrimstoneHareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    modifiers.listAppend("mysticality");
    modifiers.listAppend("spell damage percent");
    modifiers.listAppend("spell critical percent");
    int time_remaining = lookupEffect("hare-brained").have_effect();
    
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
    
    
    boolean have_shrap = lookupSkill("shrap").have_skill();
    
    if (have_shrap && $effect[hotform].have_effect() > 0)
        elemental_descriptions["hot"] = "Shrap (" + elemental_descriptions["hot"] + ")";
    else if ($skill[volcanometeor showeruption].have_skill())
        elemental_descriptions["hot"] = "Volcanometeor Showeruption (" + elemental_descriptions["hot"] + ")";
    else if ($skill[Awesome Balls of Fire].have_skill())
        elemental_descriptions["hot"] = "Awesome Balls of Fire (" + elemental_descriptions["hot"] + ")";
    else
        missing_hobopolis_spells.listAppend("Awesome Balls of Fire");
    
    
    if (have_shrap && $effect[coldform].have_effect() > 0)
        elemental_descriptions["cold"] = "Shrap (" + elemental_descriptions["cold"] + ")";
    else if ($skill[Snowclone].have_skill())
        elemental_descriptions["cold"] = "Snowclone (" + elemental_descriptions["cold"] + ")";
    else
        missing_hobopolis_spells.listAppend("Snowclone");
    
    if (have_shrap && $effect[spookyform].have_effect() > 0)
        elemental_descriptions["spooky"] = "Shrap (" + elemental_descriptions["spooky"] + ")";
    else if ($skill[Raise Backup Dancer].have_skill())
        elemental_descriptions["spooky"] = "Raise Backup Dancer (" + elemental_descriptions["spooky"] + ")";
    else
        missing_hobopolis_spells.listAppend("Raise Backup Dancer");
    
    if (have_shrap && $effect[stenchform].have_effect() > 0)
        elemental_descriptions["stench"] = "Shrap (" + elemental_descriptions["stench"] + ")";
    else if ($skill[Eggsplosion].have_skill())
        elemental_descriptions["stench"] = "Eggsplosion (" + elemental_descriptions["stench"] + ")";
    else
        missing_hobopolis_spells.listAppend("Eggsplosion");
    
    
    if (have_shrap && $effect[sleazeform].have_effect() > 0)
        elemental_descriptions["sleaze"] = "Shrap (" + elemental_descriptions["sleaze"] + ")";
    else if ($skill[Grease Lightning].have_skill())
        elemental_descriptions["sleaze"] = "Grease Lightning (" + elemental_descriptions["sleaze"] + ")";
    else
        missing_hobopolis_spells.listAppend("Grease Lightning");
    
    
    
    string [int][int] vehicle_descriptions;
    if (!lookupMonster("Fire truck").is_banished())
        vehicle_descriptions.listAppend(listMake("Fire truck", elemental_descriptions["hot"]));
    if (!lookupMonster("ice cream truck").is_banished())
        vehicle_descriptions.listAppend(listMake("ice cream truck", elemental_descriptions["cold"]));
    if (!lookupMonster("monster hearse").is_banished())
        vehicle_descriptions.listAppend(listMake("monster hearse", elemental_descriptions["spooky"]));
    if (!lookupMonster("sewer tanker").is_banished())
        vehicle_descriptions.listAppend(listMake("sewer tanker", elemental_descriptions["stench"]));
    if (!lookupMonster("sketchy van").is_banished())
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
    
    if ($skill[frigidalmatian].have_skill() && $effect[frigidalmatian].have_effect() == 0)
        description.listAppend("Could cast frigidalmatian. (expensive)");
    
    if (my_basestat($stat[mysticality]) < 400)
        description.listAppend("May want to gain " + (400 - my_basestat($stat[mysticality])) + " more mysticality.");
    
    description.listAppend(pluralize(time_remaining, "turn", "turns") + " remaining in race.");
    
    
    
    
    //lookupLocation("A Deserted Stretch of I-911")
	optional_task_entries.listAppend(ChecklistEntryMake("__effect hare-brained", "place.php?whichplace=ioty2014_hare", ChecklistSubentryMake("Hare Race", modifiers, description)));
}


void SGrimstoneGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //grimstoneMaskPath
    //rumpelstiltskinTurnsUsed gives number of turns used getting materials. rumpelstiltskinKidsRescued gives the number of children rescued. It is likely that there are more messages than are documented on the wiki, so if some are missing and aren't parsed correctly, please put a note in the forum.
    //cinderellaMinutesToMidnight gives number of turns remaining. cinderellaScore gives the current score. Also added grimstoneMaskPath which gives the current grimstone content available, "stepmother", "wolf", "witch", "gnome" or "hare".
    if (lookupEffect("hare-brained").have_effect() > 0)
        SGrimstoneHareGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}