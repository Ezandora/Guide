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
    else if (realworld_date == "0704")
        holidays["Dependence Day"] = true;
    
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
    boolean [string] holidays = getHolidaysForDate(format_today_to_string("MMdd"), gameday_to_int()); //FIXME Y10K error
    if (holiday() != "")
        holidays[holiday()] = true;
    return holidays;
}

boolean [string] getHolidaysTomorrow()
{
    //FIXME support next real-world day
    return getHolidaysForDate("", ((gameday_to_int() + 1) % 96));
}
