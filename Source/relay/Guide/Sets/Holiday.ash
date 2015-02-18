boolean [string] getHolidaysForDate(string realworld_date, int game_day)
{
    boolean [string] holidays;
    
    if (realworld_date == "0202")
        holidays["Groundhog Day"] = true;
    //april fools
    else if (realworld_date == "0401")
        holidays["April Fool's Day"] = true;
    //Talk Like a Pirate Day - september 19th
    else if (realworld_date == "0919")
        holidays["Talk Like a Pirate Day"] = true;
    else if (realworld_date == "1031")
        holidays["Halloween"] = true;
    else if (realworld_date == "0214")
        holidays["Valentine's Day"] = true;
    else if (realworld_date == "0525")
        holidays["Towel Day"] = true;
    
    //Crimbo
    if (now_to_string("M").to_int_silent() == 12)
        holidays["Crimbo"] = true;
        
    //Friday the 13th
    if (format_today_to_string("EEE d") == "Fri 13")
        holidays["Friday the 13th"] = true;
    
    
    
    //Festival of Jarlsberg - acquire the party hat? - Jarlsuary 1
    if (game_day == 0)
        holidays["Festival of Jarlsberg"] = true;
    //Valentine's Day! - Frankuary 4
    else if (game_day == 11)
        holidays["Valentine's Day"] = true;
    //St. Sneaky Pete's Day - Starch 3
    else if (game_day == 18)
        holidays["St. Sneaky Pete's Day"] = true;
    //Oyster Egg Day - April 2
    else if (game_day == 25)
        holidays["Oyster Egg Day"] = true;
    //El Dia de Los Muertos Borrachos? just wandering monsters... - Martinus 2
    else if (game_day == 33)
        holidays["El Dia de Los Muertos Borrachos"] = true;
    //Generic Summer Holiday - Bill 3
    else if (game_day == 42)
        holidays["Generic Summer Holiday"] = true;
    //Dependence Day - Bor 4
    else if (game_day == 51)
        holidays["Dependence Day"] = true;
    //Arrrbor Day - Petember 4
    else if (game_day == 59)
        holidays["Arrrbor Day"] = true;
    //Labór Day - Carlvember 6
    else if (game_day == 69)
        holidays["Labór Day"] = true;
    //Halloween / halloween tomorrow, save adventures? - Porktober 8
    else if (game_day == 79)
        holidays["Halloween"] = true;
    //feast of boris...? - Boozember 7
    else if (game_day == 86)
        holidays["Feast of Boris"] = true;
    //Yuletide? - Dougtember 4
    else if (game_day == 91)
        holidays["Yuletide"] = true;
        
    
    return holidays;
}

boolean [string] getHolidaysToday()
{
    return getHolidaysForDate(format_today_to_string("MMdd"), gameday_to_int()); //FIXME Y10K error
}

boolean [string] getHolidaysTomorrow()
{
    //FIXME support next real-world day
    return getHolidaysForDate("", ((gameday_to_int() + 1) % 96));
}


void SHolidayGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    boolean [string] todays_holidays = getHolidaysToday();
    boolean [string] all_tomorrows_parties = getHolidaysTomorrow();
    
    if (todays_holidays["Halloween"])
    {
        if (__misc_state["In run"])
        {
            string [int] description;
            description.listAppend("Free stats/items from monsters on the first block.");
            if (knoll_available() && !have_outfit_components("Filthy Hippy Disguise"))
            {
                item [int] missing_components = missing_outfit_components("Bugbear Costume");
                if (missing_components.count() > 0)
                    description.listAppend("If you need an outfit, buy a " + missing_components.listJoinComponents(", ", "and") + " from the knoll.");
            }
            optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "place.php?whichplace=town&action=town_trickortreat", ChecklistSubentryMake("Trick or treat for one block", "+" + my_primestat().to_lower_case(), description), $locations[trick-or-treating]));
        }
        else
        {
            string [int] description;
            description.listAppend("Wear an outfit, go from house to house.");
            description.listAppend("Remember you can trick-or-treat while drunk.");
            optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "place.php?whichplace=town&action=town_trickortreat", ChecklistSubentryMake("Trick or treat", "", description), $locations[trick-or-treating]));
        }
    }
    if (all_tomorrows_parties["Halloween"] && !__misc_state["In run"])
        optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "", ChecklistSubentryMake("Save turns for Halloween tomorrow", "", ""), 8));
    
    if (todays_holidays["Arrrbor Day"])
    {
        string [int] description;
        boolean [item] outfit_pieces_needed;
        foreach it in $items[crotchety pants,Saccharine Maple pendant,willowy bonnet]
        {
            if (!it.haveAtLeastXOfItemEverywhere(1))
                outfit_pieces_needed[it] = true;
        }
        //FIXME detect collecting reward?
        if ($items[bag of Crotchety Pine saplings,bag of Saccharine Maple saplings,bag of Laughing Willow saplings].available_amount() == 0)
        {
            description.listAppend("Choose a sapling type.");
            string [int] suggestions;
            if (outfit_pieces_needed[$item[crotchety pants]])
                suggestions.listAppend("Crotchety Pine");
            if (outfit_pieces_needed[$item[Saccharine Maple pendant]])
                suggestions.listAppend("Saccharine Maple");
            if (outfit_pieces_needed[$item[willowy bonnet]])
                suggestions.listAppend("Laughing Willow");
            if (suggestions.count() > 0)
                description.listAppend("Could try " + suggestions.listJoinComponents(", ", "or") + " for the reward item" + (suggestions.count() > 1 ? "s" : "") + ".");
        }
        else
        {
            item [int] bag_types;
            boolean have_a_bag_equipped = false;
            foreach it in $items[bag of Crotchety Pine saplings,bag of Saccharine Maple saplings,bag of Laughing Willow saplings]
            {
                if (it.available_amount() > 0)
                    bag_types.listAppend(it);
                if (it.equipped_amount() > 0)
                    have_a_bag_equipped = true;
            }
            if (!have_a_bag_equipped)
            {
                description.listAppend("Equip your " + bag_types.listJoinComponents(", ", "or") + ".");
            }
            else if (outfit_pieces_needed.count() > 0)
            {
                description.listAppend("Adventure for at least one hundred adventures to collect the outfit piece next holiday.");
            }
            else
            {
                description.listAppend("Adventure for at least two adventures to collect the potion reward next holiday.");
            }
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item spooky sapling", "place.php?whichplace=woods", ChecklistSubentryMake("Plant trees", "", description), 8));
    }
}