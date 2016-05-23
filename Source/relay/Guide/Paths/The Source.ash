RegisterTaskGenerationFunction("PathTheSourceGenerateTasks");
void PathTheSourceGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_THE_SOURCE)
		return;
    if (!mafiaIsPastRevision(16944))
        return;
    
    /*
    questM26Oracle
    sourceOracleTarget
    sourceAgentsDefeated
    sourceEnlightenment
    sourcePoints
    */
    
    int enlightenment = get_property_int("sourceEnlightenment");
    int learned_skill_count = 0;
    foreach s in lookupSkills("Overclocked,Bullet Time,True Disbeliever,Code Block,Disarmament,Big Guns,Humiliating Hack,Source Kick,Reboot,Restore,Data Siphon")
    {
        if (s.have_skill())
            learned_skill_count += 1;
    }
    if (enlightenment > 0 && learned_skill_count < 11)
    {
        string [int] description;
        
        skill [int] desired_skill_order;
        desired_skill_order.listAppend(lookupSkill("Big Guns")); //tons of damage
        desired_skill_order.listAppend(lookupSkill("Humiliating Hack")); //delevel a bunch
        desired_skill_order.listAppend(lookupSkill("Data Siphon")); //restore MP from attacks
        desired_skill_order.listAppend(lookupSkill("Overclocked")); //+init
        desired_skill_order.listAppend(lookupSkill("Source Kick")); //also a lot of damage...?
        
        desired_skill_order.listAppend(lookupSkill("Restore")); //restore HP
        desired_skill_order.listAppend(lookupSkill("Bullet Time")); //dodge 3 ranged
        desired_skill_order.listAppend(lookupSkill("True Disbeliever")); //dodge 3 hack
        desired_skill_order.listAppend(lookupSkill("Code Block")); //dodge 3 melee
        
        desired_skill_order.listAppend(lookupSkill("Disarmament")); //something
        desired_skill_order.listAppend(lookupSkill("Reboot")); //removes latency
        
        foreach key, s in desired_skill_order
        {
            if (!s.have_skill())
            {
                description.listAppend("Maybe " + s + " next.");
                break;
            }
        }
        
        task_entries.listAppend(ChecklistEntryMake("ringing phone", "place.php?whichplace=manor1&action=manor1_sourcephone_ring", ChecklistSubentryMake("Learn source skill", "", description), -11));
    }
    
    if (enlightenment + learned_skill_count < 11)
    {
        boolean later = false;
        string title = "";
        string [int] description;
        string url = "";
        string target = get_property("sourceOracleTarget");
        location target_location = target.to_location();
        if (lookupItem("no spoon").available_amount() > 0)
        {
            title = "Return to the Oracle";
            url = "place.php?whichplace=town_wrong&action=townwrong_oracle";
        }
        else if (target == "" || !QuestState("questM26Oracle").started)
        {
            title = "Visit the Oracle";
            url = "place.php?whichplace=town_wrong&action=townwrong_oracle";
            string line = "If you want another source skill.";
            if (learned_skill_count > 0)
                line += " (have " + learned_skill_count + " so far.)";
            description.listAppend(line);
        }
        else if (target_location != $location[none])
        {
            title = "Oracle Quest";
            url = target_location.getClickableURLForLocation();
            if (!target_location.locationAvailable())
            {
                later = true;
                title += " later";
                if (target_location == $location[the skeleton store])
                {
                    later = false;
                    title = "Start the skeleton store quest";
                    description.listAppend("Visit the meatsmith.");
                    url = "shop.php?whichshop=meatsmith&action=talk";
                }
                else if (target_location == $location[madness bakery])
                {
                    later = false;
                    title = "Start the madness bakery quest";
                    description.listAppend("Visit the Armory and Leggery.");
                    url = "shop.php?whichshop=armory&action=talk";
                }
                else if (target_location == $location[the overgrown lot])
                {
                    later = false;
                    title = "Start the Galaktik quest";
                    description.listAppend("Visit Doc Galaktik.");
                    url = "shop.php?whichshop=doc&action=talk";
                }
                description.listAppend("Unlock " + target_location + " first.");
            }
            else
            {
                description.listAppend("Adventure in " + target_location + ".");
                description.listAppend("No spoon unappears after eleven combat turns.");
            }
        }
        
        if (title != "")
        {
            ChecklistEntry entry = ChecklistEntryMake("__item cookie cookie", url, ChecklistSubentryMake(title, "", description), -1);
            if (target_location != $location[none] && target_location == __last_adventure_location)
                entry.should_highlight = true;
            if (later)
                future_task_entries.listAppend(entry);
            else
                optional_task_entries.listAppend(entry);
        }
    }
    
    int source_interval = get_property_int("sourceInterval");
    if (source_interval == 200 || source_interval == 400)
    {
        string [int] description;
        if (monster_level_adjustment() > 0)
            description.listAppend("Possibly remove +ML.");
        //FIXME mention init, stats
        
        string stat_description;
        
        if (get_property_int("sourceAgentsDefeated") > 0)
            stat_description += pluralise(get_property_int("sourceAgentsDefeated"), "agent", "agents") + " defeated so far. ";
        stat_description += lookupMonster("Source agent").base_attack + " attack.";
        float our_init = initiative_modifier();
        if (lookupSkill("Overclocked").have_skill())
            our_init += 200;
        float chance_to_get_jump = clampf(100 - lookupMonster("Source Agent").base_initiative + our_init, 0.0, 100.0);
        if (chance_to_get_jump >= 100.0)
            stat_description += "|Will gain initiative on agent.";
        else if (chance_to_get_jump <= 0.0)
            stat_description += "|Will not gain initiative on agent.";
        else
            stat_description += "|" + round(chance_to_get_jump) + "% chance to gain initiative on agent.";
        description.listAppend(stat_description);
        if (__last_adventure_location == $location[the haunted bedroom])
            description.listAppend("Won't appear in the haunted bedroom, so may want to go somewhere else?");
        task_entries.listAppend(ChecklistEntryMake("__item software glitch", "", ChecklistSubentryMake("Source agent now or soon", "", description), -11));
    }
    else if (source_interval > 0)
    {
        string [int] description;
        int turns = (source_interval - 400) / 200;
        if (get_property_int("sourceAgentsDefeated") > 0)
            description.listAppend(pluralise(get_property_int("sourceAgentsDefeated"), "agent", "agents") + " defeated so far.");
        if (QuestState("questM26Oracle").in_progress)
            description.listAppend("Oracle quests won't advance the counter.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item software glitch", "", ChecklistSubentryMake("Source agent after ~" + pluralise(turns, "won combat", "won combats"), "", description)));
    }
}

RegisterResourceGenerationFunction("PathTheSourceGenerateResource");
void PathTheSourceGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id() != PATH_THE_SOURCE)
		return;
}