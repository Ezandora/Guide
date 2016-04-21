
RegisterResourceGenerationFunction("PathAvatarOfWestOfLoathingGenerateResource");
void PathAvatarOfWestOfLoathingGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_WEST_OF_LOATHING)
		return;
    
    //Oils:
    string image_name = "";
    ChecklistSubentry [int] subentries;
    
    if (mafiaIsPastRevision(16881) && lookupSkill("Extract Oil").have_skill())
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
            string monster_oil_type = lookupAWOLOilForMonster(last_monster());
            if (monster_oil_type != "")
            {
                if (description != "")
                    description += " ";
                description += monster_oil_type + " against " + last_monster() + ".";
            }
            subentries.listAppend(ChecklistSubentryMake(pluralise(oils_remaining, "extractable oil", "extractable oils"), "", description));
        }
    }
    float [int] subentries_sort_value;
    
    string [item] tonic_descriptions;
    tonic_descriptions[lookupItem("Eldritch oil")] = "craftable";
    tonic_descriptions[lookupItem("Unusual oil")] = "+50% item (20 turns), craftable";
    tonic_descriptions[lookupItem("Skin oil")] = "+100% moxie (20 turns), craftable";
    tonic_descriptions[lookupItem("Snake oil")] = "+venom/medicine, craftable";
    
    tonic_descriptions[lookupItem("patent alacrity tonic")] = "+100% init (20 turns)"; //eldritch + unusual
    tonic_descriptions[lookupItem("patent sallowness tonic")] = "+30 ML (50 turns)"; //eldritch + skin
    tonic_descriptions[lookupItem("patent avarice tonic")] = "+50% meat (30 turns)"; //skin + unusual
    tonic_descriptions[lookupItem("patent invisibility tonic")] = "-15% combat (30 turns)"; //eldritch + snake
    tonic_descriptions[lookupItem("patent aggression tonic")] = "+15% combat (30 turns)"; //unusual + snake
    tonic_descriptions[lookupItem("patent preventative tonic")] = "+3 all res (30 turns)"; //skin + snake
    
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
        resource_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 8));
}


RegisterTaskGenerationFunction("PathAvatarOfWestOfLoathingGenerateTasks");
void PathAvatarOfWestOfLoathingGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string skill_url;
    ChecklistSubentry [int] skill_subentries;
    
    int [class] class_points;
    class_points[my_class()] = my_level();
    class_points[lookupClass("Cow Puncher")] += get_property_int("awolPointsCowpuncher");
    class_points[lookupClass("Beanslinger")] += get_property_int("awolPointsBeanslinger");
    class_points[lookupClass("Snake Oiler")] += get_property_int("awolPointsSnakeoiler");
    
    item [class] tale_for_class;
    tale_for_class[lookupClass("Cow Puncher")] = lookupItem("tales of the west: Cow Punching");
    tale_for_class[lookupClass("Beanslinger")] = lookupItem("Tales of the West: Beanslinging");
    tale_for_class[lookupClass("Snake Oiler")] = lookupItem("Tales of the West: Snake Oiling");
    
    boolean [class] have_advanced_skills_for_class;
    if (lookupSkill("Unleash Cowrruption").have_skill() || lookupSkill("Hard Drinker").have_skill() || lookupSkill("Walk: Cautious Prowl").have_skill())
        have_advanced_skills_for_class[lookupClass("Cow Puncher")] = true;
    if (lookupSkill("Beancannon").have_skill() || lookupSkill("Prodigious Appetite").have_skill() || lookupSkill("Walk: Prideful Strut").have_skill())
        have_advanced_skills_for_class[lookupClass("Beanslinger")] = true;
    if (lookupSkill("Long Con").have_skill() || lookupSkill("Tolerant Constitution").have_skill() || lookupSkill("Walk: Leisurely Amble").have_skill())
        have_advanced_skills_for_class[lookupClass("Snake Oiler")] = true;
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
    
    /*foreach it in $items[tales of the west: cow punching,Tales of the West: Beanslinging,Tales of the West: Snake Oiling]
    {
        if (it.available_amount() == 0)
            continue;
        string type = it.to_string().replace_string("Tales of the West: ", "");
        string title = "Learn a " + type + " skill";
        if (it.available_amount() > 1)
            title = "Learn " + it.available_amount().int_to_wordy() + " " + type + " skills";
        subentries.listAppend(ChecklistSubentryMake(title, "", "Use " + it + "."));
        if (url == "")
        {
            url = "inv_use.php?pwd=" + my_hash() + "&whichitem=" + it.to_int();
        }
    }*/
    if (skill_subentries.count() > 0)
    {
        task_entries.listAppend(ChecklistEntryMake("__item tales of the west: beanslinging", skill_url, skill_subentries, priority));
    }
    
    if (my_class() == lookupClass("Cow Puncher") && lookupItem("corrupted marrow").available_amount() > 0 && lookupItem("corrupted marrow").to_effect().have_effect() < 100 && in_ronin())
    {
        task_entries.listAppend(ChecklistEntryMake("__effect Cowrruption", "inventory.php?which=3", ChecklistSubentryMake("Use corrupted marrow", "", "+200% weapon damage/spell damage"), -11));
    }
}