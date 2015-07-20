void S8bitRealmGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	int total_white_pixels = $item[white pixel].available_amount() + $item[white pixel].creatable_amount();
        
	if (__quest_state["Level 13"].state_boolean["digital key used"] || (total_white_pixels >= 30 || $item[digital key].available_amount() > 0))
    {
        return;
    }
    boolean need_route_output = true;
    //Need white pixels for digital key.
    if (familiar_is_usable($familiar[angry jung man]) && $item[psychoanalytic jar].available_amount() == 0 && $item[jar of psychoses (The Crackpot Mystic)].available_amount() == 0 && !get_property_boolean("_psychoJarUsed"))
    {
        //They have a jung man, but haven't acquired a jar yet.
        ChecklistSubentry subentry;
    
        string url = "";
        if (my_familiar() != $familiar[angry jung man])
            url = "familiar.php";
        int jung_mans_charge_turns_remaining = 1 + (30 - MIN(30, get_property_int("jungCharge")));

        subentry.header = "Bring along the angry jung man";
    
        subentry.entries.listAppend(pluralise(jung_mans_charge_turns_remaining, "turn", "turns") + " until jar drops. (skip 8-bit realm)");
        if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
            subentry.entries.listAppend("Or wait for pixellated monsters.");
    
        optional_task_entries.listAppend(ChecklistEntryMake("__familiar angry jung man", url, subentry));
        need_route_output = false;
    }
    if ($item[psychoanalytic jar].available_amount() > 0 || $item[jar of psychoses (The Crackpot Mystic)].available_amount() > 0 || get_property_boolean("_psychoJarUsed")) //FIXME check which jar used
    {
        string active_url = "";
        string title = "Adventure in fear man's level";
        //Have a jar, or jar was installed.
        string [int] description;
        string [int] modifiers;
        
        if (get_property_boolean("_psychoJarUsed"))
        {
            active_url = "place.php?whichplace=junggate_3";
            modifiers.listAppend("+150% item");
            modifiers.listAppend("olfact morbid skull");
            description.listAppend("Run +150% item, olfact morbid skull.");
            description.listAppend(total_white_pixels + "/30 white pixels found.");
            if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                description.listAppend("Or wait for pixellated monsters.");
        }
        else if ($item[jar of psychoses (The Crackpot Mystic)].available_amount() > 0)
        {
            active_url = "inventory.php?which=3";
            title = "Open the " + $item[jar of psychoses (The Crackpot Mystic)];
            description.listAppend("Fear Man's level access, for digital key.");
            if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                description.listAppend("Or wait for pixellated monsters.");
        }
        else if ($item[psychoanalytic jar].available_amount() > 0)
        {
            if (my_level() < 2) //no woods yet
                return;
            active_url = "place.php?whichplace=forestvillage&action=fv_mystic";
            title = "Psychoanalyze the crackpot mystic";
            description.listAppend("Fear Man's level access, for digital key.");
            if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                description.listAppend("Or wait for pixellated monsters.");
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item digital key", active_url, ChecklistSubentryMake(title, modifiers, description), $locations[fear man's level]));
        need_route_output = false;
    }
    if (need_route_output)
    {
        if (in_hardcore() || !$item[jar of psychoses (The Crackpot Mystic)].is_unrestricted())
        {
            string url = "place.php?whichplace=woods";
            string [int] description;
            string [int] modifiers;
            modifiers.listAppend("olfact bloopers");
            modifiers.listAppend("+100% item");
            
            description.listAppend("Run +100% item, olfact bloopers.");
            description.listAppend(total_white_pixels + "/30 white pixels found.");
            if (__misc_state["VIP available"] && __misc_state["fax equivalent accessible"])
                description.listAppend("Possibly consider faxing/copying a ghost. (+150% item, drops five white pixels)");
            if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                description.listAppend("Or wait for pixellated monsters.");
            if ($item[continuum transfunctioner].equipped_amount() == 0)
            {
                url = "inventory.php?which=2";
                description.listAppend("Equip the continuum transfunctioner.");
            }
            //No other choice. 8-bit realm.
            //Well, I suppose they could fax and arrow a ghost.
            if ($item[continuum transfunctioner].available_amount() > 0)
                optional_task_entries.listAppend(ChecklistEntryMake("inexplicable door", url, ChecklistSubentryMake("Adventure in the 8-bit realm", modifiers, description), $locations[8-bit realm]));
            else if (my_level() >= 2)
                optional_task_entries.listAppend(ChecklistEntryMake("__item continuum transfunctioner", "place.php?whichplace=forestvillage&action=fv_mystic", ChecklistSubentryMake("Acquire a continuum transfunctioner", "", "From the crackpot mystic.")));
        }
        else
        {
            //softcore, suggest pulling a jar of psychoses.
            string [int] description;
            description.listAppend("To make digital key.");
            if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                description.listAppend("Or wait for pixellated monsters.");
            optional_task_entries.listAppend(ChecklistEntryMake("__item psychoanalytic jar", "", ChecklistSubentryMake("Pull a jar of psychoses (The Crackpot Mystic)", "", description)));
        }
    }
}

void S8bitRealmGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!(__quest_state["Level 13"].state_boolean["digital key used"] || $item[digital key].available_amount() > 0))
        return;
    if (!__misc_state["In run"])
        return;
    //This is mainly for one crazy random summer, where you have many pixels.
    //Blue pixel potion - [50,80] MP restore
    //monster bait - +5% combat
    //pixel sword - ? - +15% init
    //red pixel potion - [100,120] HP restore - the shadow knows
    //pixel whip - useful against vampires
    //pixel grappling hook would be useful, but it's unlikely anyone would defeat all four bosses in-run (resets upon ascension)
    string [item] craftables;
    int [item] max_craftables_wanted;
    craftables[$item[blue pixel potion]] = "~65 MP restore";
    craftables[$item[monster bait]] = "+5% combat";
    max_craftables_wanted[$item[monster bait]] = 1;
    //pixel sword?
    if (__quest_state["Level 13"].state_boolean["shadow will need to be defeated"])
        craftables[$item[red pixel potion]] = "~110 HP restore for shadow";
    if ($locations[dreadsylvanian castle,the spooky forest,The Haunted Sorority House,The Daily Dungeon] contains __last_adventure_location) //known vampire locations. it's perfectly reasonable to test against the sorority house, here in 2015
    {
        craftables[$item[pixel whip]] = "vampire killer";
        max_craftables_wanted[$item[pixel whip]] = 1;
    }
    
    max_craftables_wanted[$item[blue pixel potion]] = 11;
    max_craftables_wanted[$item[red pixel potion]] = 4; //4 minimum to out-shadow
    
    string [int] crafting_list_have;
    string [int] crafting_list_cannot;
    foreach it, reason in craftables
    {
        if (it.available_amount() >= MAX(1, max_craftables_wanted[it]))
            continue;
        string line = it;
        
        if (max_craftables_wanted[it] != 1 && it.creatable_amount() > 0)
            line = pluralise(it.creatable_amount(), it);
        line += ": " + reason;
        if (it.creatable_amount() == 0)
        {
            line = HTMLGenerateSpanFont(line, "grey");
            crafting_list_cannot.listAppend(line);
        }
        else
            crafting_list_have.listAppend(line);
    }
    if (crafting_list_have.count() > 0)
    {
        string [int] crafting_list = crafting_list_have;
        crafting_list.listAppendList(crafting_list_cannot);
        string pixels_have = "Pixel crafting";
        resource_entries.listAppend(ChecklistEntryMake("__item white pixel", "place.php?whichplace=forestvillage&action=fv_mystic", ChecklistSubentryMake(pixels_have,  "", crafting_list), 10));
    }
}