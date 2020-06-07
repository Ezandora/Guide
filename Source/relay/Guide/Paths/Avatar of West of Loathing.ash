
RegisterResourceGenerationFunction("PathAvatarOfWestOfLoathingGenerateResource");
void PathAvatarOfWestOfLoathingGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (myPathId() != PATH_AVATAR_OF_WEST_OF_LOATHING && !($classes[snake oiler,beanslinger,cow puncher] contains my_class()))
		return;
    
    //Oils:
    string image_name = "";
    ChecklistSubentry [int] subentries;
    
    if (mafiaIsPastRevision(16881) && $skill[Extract Oil].have_skill())
    {
        int oils_extracted = get_property_int("_oilExtracted");
        int oils_remaining = clampi(15 - oils_extracted, 0, 15);
        if (oils_extracted < 15)
        {
            string description;
            if (oils_extracted >= 5)
            {
                int percentage_left = clampi(100 - (oils_extracted - 5) * 10, 0, 100);
                description = percentage_left + "% chance.";
            }
            item monster_oil_type = lookupAWOLOilForMonster(last_monster());
            if (monster_oil_type != $item[none])
            {
                if (description != "")
                    description += " ";
                description += monster_oil_type.capitaliseFirstLetter() + " against " + last_monster() + ".";
            }
            if (image_name == "")
                image_name = "__item Snake oil";
            subentries.listAppend(ChecklistSubentryMake(pluralise(oils_remaining, "extractable oil", "extractable oils"), "", description));
        }
    }
    float [int] subentries_sort_value;
    
    string [item] tonic_descriptions;
    tonic_descriptions[$item[Eldritch oil]] = "craftable";
    tonic_descriptions[$item[Unusual oil]] = "+50% item (20 turns), craftable";
    tonic_descriptions[$item[Skin oil]] = "+100% moxie (20 turns), craftable";
    tonic_descriptions[$item[Snake oil]] = "+venom/medicine, craftable";
    
    tonic_descriptions[$item[patent alacrity tonic]] = "+100% init (20 turns)"; //eldritch + unusual
    tonic_descriptions[$item[patent sallowness tonic]] = "+30 ML (50 turns)"; //eldritch + skin
    tonic_descriptions[$item[patent avarice tonic]] = "+50% meat (30 turns)"; //skin + unusual
    tonic_descriptions[$item[patent invisibility tonic]] = "-15% combat (30 turns)"; //eldritch + snake
    tonic_descriptions[$item[patent aggression tonic]] = "+15% combat (30 turns)"; //unusual + snake
    tonic_descriptions[$item[patent preventative tonic]] = "+3 all res (30 turns)"; //skin + snake
    
    foreach it in tonic_descriptions
    {
        if (it.available_amount() == 0 && it.creatable_amount() == 0)
            continue;
        
        string description = tonic_descriptions[it];
        if (image_name == "")
            image_name = "__item " + it;
        string name;
        if (it.available_amount() > 0)
            name = pluralise(it);
        if (it.creatable_amount() > 0)
        {
            if (it.available_amount() != 0)
                name += " (" + it.creatable_amount() + " craftable)";
            else
                name = pluralise(it.creatable_amount(), "craftable " + it, "craftable " + it.plural);
        }
        if (it.available_amount() == 0)
        {
            subentries_sort_value[subentries.count()] = 1.0;
            name = HTMLGenerateSpanFont(name, "grey");
            description = HTMLGenerateSpanFont(description, "grey");
        }
        else
        {
            subentries_sort_value[subentries.count()] = 0.0;
        }
        subentries.listAppend(ChecklistSubentryMake(name, "", description));
    }
    sort subentries by subentries_sort_value[index];
    if (subentries.count() > 0)
        resource_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 2));
    
    
    //Should we display beancannon in aftercore? I guess we could suggest a cheap source of it...? Maybe another time.
    if ($skill[Beancannon].have_skill() && in_ronin())
    {
        string [int] banish_sources;
        int banish_count = 0;
        int equipped_amount = 0;
        foreach it in __beancannon_source_items
        {
            if (it.available_amount() == 0)
                continue;
            banish_count += it.available_amount();
            string description = it;
            if (it.available_amount() > 1)
                description = it.pluralise();
            equipped_amount += it.equipped_amount();
            banish_sources.listAppend(description);
        }
        if (banish_count > 0 || !in_ronin())
        {
            string [int] description;
            if (banish_sources.count() > 0)
                description.listAppend("From " + banish_sources.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
            string url = "";
            if (equipped_amount == 0)
            {
                description.listAppend("Equip one before banishing.");
                url = "inventory.php?which=2";
            }
            string title = pluralise(banish_count, "beancannon banish", "beancannon banishes");
            if (!in_ronin())
                title = "Beancannon banishes";
            resource_entries.listAppend(ChecklistEntryMake("__skill beancannon", url, ChecklistSubentryMake(title, "", description), 8).ChecklistEntryTagEntry("banish"));
        }
    }
    
    if ($skill[Long Con].have_skill() && mafiaIsPastRevision(16812) && get_property_int("_longConUsed") < 5)
    {
        int uses_remaining = clampi(5 - get_property_int("_longConUsed"), 0, 5);
        string [int] description;
        string line = "Olfaction.";
        description.listAppend(line);
        resource_entries.listAppend(ChecklistEntryMake("__effect Greaser Lightnin'", "", ChecklistSubentryMake(pluralise(uses_remaining, "long con", "long cons") + " remaining", "", description), 8));
    }
}


RegisterTaskGenerationFunction("PathAvatarOfWestOfLoathingGenerateTasks");
void PathAvatarOfWestOfLoathingGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (myPathId() != PATH_AVATAR_OF_WEST_OF_LOATHING)
		return;
    string skill_url;
    ChecklistSubentry [int] skill_subentries;
    
    int [class] class_points;
    class_points[my_class()] = my_level();
    class_points[$class[Cow Puncher]] += get_property_int("awolPointsCowpuncher");
    class_points[$class[Beanslinger]] += get_property_int("awolPointsBeanslinger");
    class_points[$class[Snake Oiler]] += get_property_int("awolPointsSnakeoiler");
    
    item [class] tale_for_class;
    tale_for_class[$class[Cow Puncher]] = $item[tales of the west: Cow Punching];
    tale_for_class[$class[Beanslinger]] = $item[Tales of the West: Beanslinging];
    tale_for_class[$class[Snake Oiler]] = $item[Tales of the West: Snake Oiling];
    
    boolean [class] have_advanced_skills_for_class;
    if ($skill[Unleash Cowrruption].have_skill() || $skill[[18008]Hard Drinker].have_skill() || $skill[Walk: Cautious Prowl].have_skill())
        have_advanced_skills_for_class[$class[Cow Puncher]] = true;
    if ($skill[Beancannon].have_skill() || $skill[Prodigious Appetite].have_skill() || $skill[Walk: Prideful Strut].have_skill())
        have_advanced_skills_for_class[$class[Beanslinger]] = true;
    if ($skill[Long Con].have_skill() || $skill[Tolerant Constitution].have_skill() || $skill[Walk: Leisurely Amble].have_skill())
        have_advanced_skills_for_class[$class[Snake Oiler]] = true;
    float priority = 0;
    foreach c in class_points
    {
        int total_points_available = class_points[c];
        if (total_points_available == 0)
            continue;
        
        int class_skills_learned = 0;
        foreach key, s in __skills_by_class[c]
        {
            if (s.have_skill())
                class_skills_learned += 1;
        }
        if (class_skills_learned >= 10)
            continue;
        
        int skills_left_to_learn = total_points_available - class_skills_learned;
        if (skills_left_to_learn <= 0)
            continue;
        
        int limit = 7; //theoretically, they might be unable to learn the advanced skills, so only make this a priority if we're under that or know we have advanced skills
        if (have_advanced_skills_for_class[c])
            limit = 10;
        if (class_skills_learned < limit)
            priority = -11;
        item tale = tale_for_class[c];
        
        string title = "Learn a " + c + " skill";
        if (skills_left_to_learn > 1)
            title = "Learn " + skills_left_to_learn.int_to_wordy() + " " + c + " skills";
        if (skill_url == "")
        {
            skill_url = "inv_use.php?pwd=" + my_hash() + "&whichitem=" + tale.to_int();
        }
        skill_subentries.listAppend(ChecklistSubentryMake(title, "", "Use " + tale + "."));
    }
    
    if (skill_subentries.count() > 0)
    {
        task_entries.listAppend(ChecklistEntryMake("__item tales of the west: beanslinging", skill_url, skill_subentries, priority));
    }
    
    if (my_class() == $class[Cow Puncher] && $item[corrupted marrow].available_amount() > 0 && $item[corrupted marrow].to_effect().have_effect() < 100 && in_ronin())
    {
        task_entries.listAppend(ChecklistEntryMake("__effect Cowrruption", "inventory.php?ftext=corrupted+marrow", ChecklistSubentryMake("Use corrupted marrow", "", "+200% weapon damage/spell damage"), -11));
    }
}
