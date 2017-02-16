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
        if (get_property_int("sourcePoints") < 3) //once you have three, you can always go the hack-siphon-kick route
            desired_skill_order.listAppend($skill[Big Guns]); //tons of damage
        desired_skill_order.listAppend($skill[Humiliating Hack]); //delevel a bunch
        desired_skill_order.listAppend($skill[Data Siphon]); //restore MP from attacks
        desired_skill_order.listAppend($skill[Source Kick]); //also a lot of damage...?
        desired_skill_order.listAppend($skill[Overclocked]); //+init
        
        desired_skill_order.listAppend($skill[Restore]); //restore HP
        desired_skill_order.listAppend($skill[Bullet Time]); //dodge 3 ranged
        desired_skill_order.listAppend($skill[True Disbeliever]); //dodge 3 hack
        desired_skill_order.listAppend($skill[Code Block]); //dodge 3 melee
        
        desired_skill_order.listAppend($skill[Disarmament]); //something
        desired_skill_order.listAppend($skill[Reboot]); //removes latency
        desired_skill_order.listAppend($skill[Big Guns]); //tons of damage
        
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
        if ($item[no spoon].available_amount() > 0)
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
        CopiedMonstersGenerateDescriptionForMonster("source agent", description, true, false);
        
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