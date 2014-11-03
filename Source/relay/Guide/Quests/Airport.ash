
void QSleazeAirportGenerateTasks(ChecklistEntry [int] task_entries)
{
    /*
    questESlAudit(user, now 'unstarted', default unstarted)
    questESlBacteria(user, now 'unstarted', default unstarted)
    questESlCheeseburger(user, now 'unstarted', default unstarted)
    questESlCocktail(user, now 'unstarted', default unstarted)
    questESlDebt(user, now 'unstarted', default unstarted)
    questESlFish(user, now 'unstarted', default unstarted)
    questESlMushStash(user, now 'unstarted', default unstarted)
    questESlSalt(user, now 'unstarted', default unstarted)
    questESlSprinkles(user, now 'unstarted', default unstarted)
    */
}

void QSleazeAirportGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    if (!(get_property_boolean("_sleazeAirportToday") || get_property_boolean("sleazeAirportAlways")))
        return;
    if (get_property("umdLastObtained").length() > 0 && !__misc_state["In run"])
    {
        string umd_date_obtained = get_property("umdLastObtained");
        
        int day_in_year_acquired_umd = format_date_time("yyyy-MM-dd", umd_date_obtained, "D").to_int();
        int year_umd_acquired = format_date_time("yyyy-MM-dd", umd_date_obtained, "yyyy").to_int();
        
        string todays_date = today_to_string();
        int today_day_in_year = format_date_time("yyyyMMdd", todays_date, "D").to_int();
        int todays_year = format_date_time("yyyyMMdd", todays_date, "yyyy").to_int();
        
        //We compute the delta of days since last UMD obtained. If it's seven or higher, they can obtain it.
        //If the year is different, more complicated.
        //Umm... this will inevitably have an off by one error from me not looking closely enough.
        
        boolean has_been_seven_days = false;
        if (year_umd_acquired != todays_year)
        {
            //Query the number of days in last year, then subtract it from day_in_year_acquired_umd.
            
            int days_in_last_year = format_date_time("yyyy-MM-dd", todays_year + "-12-31", "D").to_int(); //this may work well past the year 10k. if it doesn't and you track down this bug and it's a problem, hello from eight thousand years ago!
            
            day_in_year_acquired_umd -= days_in_last_year * (todays_year - year_umd_acquired); //this is technically incorrect due to leap years, but it'll still result in proper checking. do not use for delta code
        }
        
        if (today_day_in_year - day_in_year_acquired_umd >= 7)
            has_been_seven_days = true;
        if (has_been_seven_days)
        {
            string [int] description;
            description.listAppend("Adventure in the Sunken Party Yacht.|Choose the first option from a non-combat that appears every twenty adventures.");
            description.listAppend("Found once every seven days.");
            if ($effect[fishy].have_effect() == 0)
                description.listAppend("Possibly acquire fishy effect first.");
            
            available_resources_entries.listAppend(ChecklistEntryMake("__item ultimate mind destroyer", $location[The Sunken Party Yacht].getClickableURLForLocation(), ChecklistSubentryMake("Ultimate Mind Destroyer collectable", "free runs", description), $locations[The Sunken Party Yacht]));
        }
    }
}

//

void QJunglePunGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item encrypted micro-cassette recorder";
    state.quest_name = "Pungle in the Jungle";
	QuestStateParseMafiaQuestProperty(state, "questESpJunglePun");
    
    if (!state.in_progress)
        return;
    item recorder = lookupItem("encrypted micro-cassette recorder");
    
    if (recorder.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    int puns_remaining = 11 - get_property_int("junglePuns");
    if (state.mafia_internal_step <= 2 && puns_remaining > 0)
    {
        subentry.entries.listAppend("Adventure in the The Deep Dark Jungle.");
        subentry.modifiers.listAppend("+myst?");
        
        string [int] items_to_equip;
        if (recorder.equipped_amount() == 0)
        {
            items_to_equip.listAppend("encrypted micro-cassette recorder");
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red", ""));
            url = "inventory.php?which=2";
        }
        
        subentry.entries.listAppend(pluralizeWordy(puns_remaining, "pun", "puns").capitalizeFirstLetter() + " remaining.");
    }
    else
        subentry.entries.listAppend("Return to the radio and reply.");
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Deep Dark Jungle")));
}

void QFakeMediumGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__familiar happy medium";
    state.quest_name = "Fake Medium at Large";
	QuestStateParseMafiaQuestProperty(state, "questESpFakeMedium");
    
    if (!state.in_progress)
        return;
    item collar = lookupItem("ESP suppression collar");
    
    
	ChecklistSubentry subentry;
    
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    if (state.mafia_internal_step == 1 && collar.available_amount() == 0)
    {
        subentry.entries.listAppend("Adventure in the The Secret Government Laboratory, find a non-combat every twenty turns.");
        
        string [int,int] solutions;
        
        solutions.listAppend(listMake("dust motes float", "star"));
        solutions.listAppend(listMake("circle of light", "circle"));
        solutions.listAppend(listMake("waves a fly away", "waves"));
        solutions.listAppend(listMake("square one", "square"));
        solutions.listAppend(listMake("expression only adds to your anxiety", "plus"));
        
        
        subentry.entries.listAppend("The last line of the adventure text gives the solution:|*" + HTMLGenerateSimpleTableLines(solutions));
        
        string [int] items_to_equip;
        if (lookupItem("Personal Ventilation Unit").equipped_amount() == 0 && lookupItem("Personal Ventilation Unit").available_amount() > 0)
        {
            items_to_equip.listAppend("Personal Ventilation Unit");
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red", ""));
            url = "inventory.php?which=2";
        }
    }
    else
        subentry.entries.listAppend("Return to the radio and reply.");
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Secret Government Laboratory")));
}


void QClipperGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item military-grade fingernail clippers";
    state.quest_name = "The Big Clipper";
	QuestStateParseMafiaQuestProperty(state, "questESpClipper");
    
    if (!state.in_progress)
        return;
    item clipper = lookupItem("military-grade fingernail clippers");
    
    if (clipper.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    int fingernails_remaining = 23 - get_property_int("fingernailsClipped");
    if (state.mafia_internal_step == 1 && fingernails_remaining > 0)
    {
        subentry.entries.listAppend("Adventure in the The Mansion of Dr. Weirdeaux, use the military-grade fingernail clippers on the monsters three times per fight.");
        
        int turns_remaining = ceil(fingernails_remaining.to_float() / 3.0);
        
        subentry.entries.listAppend(fingernails_remaining + " fingernails / " + pluralize(turns_remaining, "turn", "turns") + " remaining.");
    }
    else
        subentry.entries.listAppend("Return to the radio and reply.");
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Mansion of Dr. Weirdeaux")));
}

void QGoreGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item gore bucket";
    state.quest_name = "Gore Tipper";
	QuestStateParseMafiaQuestProperty(state, "questESpGore");
    
    if (!state.in_progress)
        return;
    item bucket = lookupItem("gore bucket");
    
    if (bucket.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    int gore_remaining = 100 - get_property_int("goreCollected");
    if (state.mafia_internal_step <= 2 && gore_remaining > 0)
    {
        subentry.entries.listAppend("Adventure in the The Secret Government Laboratory.");
        subentry.modifiers.listAppend("+meat");
        string [int] items_to_equip;
        if (bucket.equipped_amount() == 0)
        {
            items_to_equip.listAppend("gore bucket");
        }
        if (lookupItem("Personal Ventilation Unit").equipped_amount() == 0 && lookupItem("Personal Ventilation Unit").available_amount() > 0)
        {
            items_to_equip.listAppend("Personal Ventilation Unit");
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red", ""));
            url = "inventory.php?which=2";
        }
        subentry.entries.listAppend(pluralize(gore_remaining, "pound", "pounds") + " remaining.");
    }
    else
        subentry.entries.listAppend("Return to the radio and reply.");
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Secret Government Laboratory")));
}

void QSpookyAirportGenerateTasks(ChecklistEntry [int] task_entries)
{
    /*
    questESpClipper(user, now 'unstarted', default unstarted)
    questESpEVE(user, now 'unstarted', default unstarted)
    questESpFakeMedium(user, now 'unstarted', default unstarted)
    √questESpGore(user, now 'started', default unstarted)
    questESpJunglePun(user, now 'unstarted', default unstarted)
    */
    
    QClipperGenerateTasks(task_entries);
    //QEVEGenerateTasks(task_entries);
    QFakeMediumGenerateTasks(task_entries);
    QGoreGenerateTasks(task_entries);
    QJunglePunGenerateTasks(task_entries);
}

void QAirportGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    ChecklistEntry [int] chosen_entries = optional_task_entries;
    if (__misc_state["In run"])
        chosen_entries = future_task_entries;
    
    QSleazeAirportGenerateTasks(chosen_entries);
    QSpookyAirportGenerateTasks(chosen_entries);
}

void QAirportGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    QSleazeAirportGenerateResource(available_resources_entries);
}