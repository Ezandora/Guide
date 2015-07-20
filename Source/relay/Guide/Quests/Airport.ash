boolean __QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished = false;
ChecklistEntry QSleazeAirportGenerateQuestFramework(ChecklistEntry [int] task_entries, string quest_property_name, string quest_name, string image_name, int amount_of_something_to_collect, item item_to_collect, string property_name_to_collect, string item_to_collect_singular, string item_to_collect_plural, location target_location, string quest_giver, item item_to_equip)
{
    __QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished = false;
    QuestState state;
    state.image_name = image_name;
    state.quest_name = quest_name;
	QuestStateParseMafiaQuestProperty(state, quest_property_name);
    
    boolean should_ignore_for_now = false;
    
    if (quest_property_name == "questESlMushStash" || quest_property_name == "questESlBacteria")
    {
        //questESlAudit, questESlMushStash, questESlBacteria
        if (QuestState("questESlAudit").in_progress)
            should_ignore_for_now = true;
        if (quest_property_name == "questESlBacteria" && QuestState("questESlMushStash").in_progress)
            should_ignore_for_now = true;
    }
    
    if (!state.in_progress || should_ignore_for_now)
    {
        ChecklistEntry blank_entry;
        return blank_entry;
    }
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_sleaze";
    
    int remaining_of_item = 0;
    if (item_to_collect != $item[none])
    {
        remaining_of_item = amount_of_something_to_collect - item_to_collect.item_amount();
        if (item_to_collect_singular.length() == 0)
            item_to_collect_singular = item_to_collect.to_string();
        if (item_to_collect_plural.length() == 0)
            item_to_collect_plural = item_to_collect.plural;
    }
    else
    {
        remaining_of_item = amount_of_something_to_collect - get_property_int(property_name_to_collect);
    }
    
    remaining_of_item = MAX(0, remaining_of_item);
    
    if (state.mafia_internal_step <= 2 && remaining_of_item > 0)
    {
        string line = "Adventure in the " + target_location + " and collect ";
        line += remaining_of_item.int_to_wordy();
        line += " more ";
        if (remaining_of_item > 1)
            line += item_to_collect_plural;
        else
            line += item_to_collect_singular;
        line += ".";
        subentry.entries.listAppend(line);
        
        if (item_to_equip != $item[none] && item_to_equip.available_amount() > 0 && item_to_equip.equipped_amount() == 0)
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + item_to_equip + ".", "red"));
        if (target_location == $location[The Sunken Party Yacht] && $effect[fishy].have_effect() == 0)
        {
            subentry.entries.listAppend("Try to acquire Fishy effect.");
        }
        if (quest_property_name == "questESlAudit" || quest_property_name == "questESlMushStash")
        {
            string [int] remaining_quests_after_this;
            if (quest_property_name == "questESlAudit")
            {
                if (QuestState("questESlMushStash").in_progress)
                    remaining_quests_after_this.listAppend("Pencil-Thin Mush Stash");
            }
            if (QuestState("questESlBacteria").in_progress)
                remaining_quests_after_this.listAppend("Cultural Studies");
            
            //questESlAudit, questESlMushStash, questESlBacteria
            if (remaining_quests_after_this.count() > 0)
            {
                /*string line = "The quest";
                if (remaining_quests_after_this.count() > 1)
                    line += "s";
                line += " ";
                line += remaining_quests_after_this.listJoinComponents(", ", "and") + " will be available next.";*/
                string line = pluraliseWordy(remaining_quests_after_this.count(), "quest", "quests").capitaliseFirstLetter() + " will be available after this.";
                subentry.entries.listAppend(line);
            }
        }
    }
    else
    {
        subentry.entries.listAppend("Return to " + quest_giver + ".");
        __QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished = true;
    }
    
    
    boolean [location] target_locations;
    target_locations[target_location] = true;
    ChecklistEntry output_entry = ChecklistEntryMake(state.image_name, url, subentry, target_locations);
    
    task_entries.listAppend(output_entry);
    
    return output_entry;
}

void QSleazeAirportMushStashGenerateTasks(ChecklistEntry [int] task_entries)
{
    //jimmy, fun-guy
    //run +item, collect 10 pencil thin mushrooms (item)
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlMushStash", "Pencil-Thin Mush Stash", "__item pencil thin mushroom", 10, $item[pencil thin mushroom], "", "", "", $location[The Fun-Guy Mansion], "Buff Jimmy", $item[none]);
    
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("+item");
}

void QSleazeAirportAuditGenerateTasks(ChecklistEntry [int] task_entries)
{
    //questESlAudit
    //taco dan, fun-guy
    //look for 10 Taco Dan's Taco Stand's Taco Receipt (item). requires Sleight of Mind effect from sleight-of-hand mushrooms dropped from area
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlAudit", "Audit-Tory Hallucinations", "__item Taco Dan's Taco Stand's Taco Receipt", 10, $item[Taco Dan's Taco Stand's Taco Receipt], "", "receipt", "receipts", $location[The Fun-Guy Mansion], "Taco Dan", $item[none]);
    
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    
    if ($effect[sleight of mind].have_effect() == 0 && $item[sleight-of-hand mushroom].available_amount() > 0)
    {
        entry.subentries[0].entries.listAppend(HTMLGenerateSpanFont("Use sleight-of-hand mushroom", "red") + " to acquire receipts.");
    }
}

void QSleazeAirportBacteriaGenerateTasks(ChecklistEntry [int] task_entries)
{
    //broden, fun-guy, brodenBacteria
    //+all(?) elemental resistance
    //collect 10 bacteria
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlBacteria", "Cultural Studies", "__item chainsaw chain", 10, $item[none], "brodenBacteria", "bacteria", "bacteria", $location[The Fun-Guy Mansion], "Broden", $item[none]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("+elemental resistance");
}


void QSleazeAirportCheeseburgerGenerateTasks(ChecklistEntry [int] task_entries)
{
    //jimmy, diner
    //buffJimmyIngredients - need 15(?)
    //equip Paradaisical Cheeseburger recipe, olfact Sloppy Seconds Burgers
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlCheeseburger", "Paradise Cheeseburger", "__item hamburger", 15, $item[none], "buffJimmyIngredients", "ingredient", "ingredients", $location[sloppy seconds diner], "Buff Jimmy", $item[Paradaisical Cheeseburger recipe]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("olfact Burgers");
}

void QSleazeAirportCocktailGenerateTasks(ChecklistEntry [int] task_entries)
{
    //taco dan, diner
    //tacoDanCocktailSauce
    //equip Taco Dan's Taco Stand Cocktail Sauce Bottle, olfact Sloppy Seconds Cocktails
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlCocktail", "Cocktail as old as Cocktime", "__item Taco Dan's Taco Stand Cocktail Sauce Bottle", 15, $item[none], "tacoDanCocktailSauce", "sauce", "sauce", $location[sloppy seconds diner], "Taco Dan", $item[Taco Dan's Taco Stand Cocktail Sauce Bottle]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("olfact Cocktails");
}

void QSleazeAirportSprinklesGenerateTasks(ChecklistEntry [int] task_entries)
{
    //broden, diner
    //brodenSprinkles
    //equip sprinkle shaker, olfact Sloppy Seconds Sundaes
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlSprinkles", "A Light Sprinkle", "__item sprinkle shaker", 15, $item[none], "brodenSprinkles", "sprinkles", "sprinkles", $location[sloppy seconds diner], "Broden", $item[sprinkle shaker]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("olfact Sundaes");
}


void QSleazeAirportSaltGenerateTasks(ChecklistEntry [int] task_entries)
{
    //jimmy, yacht
    //collect 50 salty sailor salts (item), olfact son of a son of a sailor, run +ML, want fishy
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlSalt", "Lost Shaker of Salt", "__item salty sailor salt", 50, $item[salty sailor salt], "", "salt", "salts", $location[The Sunken Party Yacht], "Buff Jimmy", $item[none]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("+ML");
    entry.subentries[0].modifiers.listAppend("olfact son of a son of a sailor");
}

void QSleazeAirportFishGenerateTasks(ChecklistEntry [int] task_entries)
{
    //taco dan, yacht
    //tacoDanFishMeat
    //collect 300 fish meat, olfact taco fish, run +meat, want fishy
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlFish", "Dirty Fishy Dish", "__item fishy fish", 300, $item[none], "tacoDanFishMeat", "fish meat", "fish meat", $location[The Sunken Party Yacht], "Taco Dan", $item[none]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("+meat");
    entry.subentries[0].modifiers.listAppend("olfact taco fish");
}

void QSleazeAirportDebtGenerateTasks(ChecklistEntry [int] task_entries)
{
    //broden, yacht
    //collect 15 bike rental broupon (item), olfact drownedbeat, want fishy
    ChecklistEntry entry = QSleazeAirportGenerateQuestFramework(task_entries, "questESlDebt", "Beat Dead the Deadbeats", "__item fixed-gear bicycle", 15, $item[bike rental broupon], "", "", "", $location[The Sunken Party Yacht], "Broden", $item[none]);
    if (__QSleazeAirportGenerateQuestFramework_return_quest_nearly_finished)
        return;
    entry.subentries[0].modifiers.listAppend("olfact drownedbeat");
}


void QSleazeAirportGenerateTasks(ChecklistEntry [int] task_entries)
{
    /*
    questESlMushStash - (?)Jimmy, Fun-Guy
    questESlAudit - (?)Taco Dan, Fun-Guy
    questESlBacteria - Broden, Fun-Guy, brodenBacteria
    
    questESlCheeseburger - Jimmy, Sloppy Seconds Diner, buffJimmyIngredients(?)
    questESlCocktail - Taco Dan, Sloppy Seconds Diner, tacoDanCocktailSauce
    questESlSprinkles - Broden, Sloppy Seconds Diner, brodenSprinkles
    
    questESlSalt - Jimmy, Sunken Yacht
    questESlFish - Taco Dan, Sunken Yacht, tacoDanFishMeat
    questESlDebt - (?)Broden, Sunken Yacht
    */
    if (__misc_state["In run"] && !($locations[the sunken party yacht,sloppy seconds diner,the fun-guy mansion] contains __last_adventure_location)) //too many
        return;
    ChecklistEntry [int] subtask_entries;
    QSleazeAirportMushStashGenerateTasks(subtask_entries); //√
    QSleazeAirportAuditGenerateTasks(subtask_entries); //√
    QSleazeAirportBacteriaGenerateTasks(subtask_entries); //√
    QSleazeAirportCheeseburgerGenerateTasks(subtask_entries); //√
    QSleazeAirportCocktailGenerateTasks(subtask_entries); //√
    QSleazeAirportSprinklesGenerateTasks(subtask_entries); //√ mostly - quest didn't set to finish at the end (mafia bug?)
    QSleazeAirportSaltGenerateTasks(subtask_entries); //√
    QSleazeAirportFishGenerateTasks(subtask_entries); //√
    QSleazeAirportDebtGenerateTasks(subtask_entries); //√
    
    if (subtask_entries.count() > 0)
    {
        //Combine them into one entry, for convenience:
        ChecklistEntry final_entry;
        boolean first = true;
        foreach key, entry in subtask_entries
        {
            if (first)
            {
                final_entry = entry;
                first = false;
            }
            else
            {
                foreach key2, subentry in entry.subentries
                {
                    final_entry.subentries.listAppend(subentry);
                }
                if (entry.should_highlight)
                    final_entry.should_highlight = true;
            }
            
        }
        
        task_entries.listAppend(final_entry);
    }
}

void QSleazeAirportGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__misc_state["sleaze airport available"])
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
            
            resource_entries.listAppend(ChecklistEntryMake("__item ultimate mind destroyer", $location[The Sunken Party Yacht].getClickableURLForLocation(), ChecklistSubentryMake("Ultimate Mind Destroyer collectable", "free runs", description), $locations[The Sunken Party Yacht]));
        }
    }
}

//

void QSpookyAirportJunglePunGenerateTasks(ChecklistEntry [int] task_entries)
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
        subentry.entries.listAppend("Adventure in The Deep Dark Jungle.");
        subentry.modifiers.listAppend("+myst");
        
        string [int] items_to_equip;
        if (recorder.equipped_amount() == 0)
        {
            items_to_equip.listAppend("encrypted micro-cassette recorder");
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
        
        subentry.entries.listAppend(pluraliseWordy(puns_remaining, "pun", "puns").capitaliseFirstLetter() + " remaining.");
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Deep Dark Jungle")));
}

void QSpookyAirportFakeMediumGenerateTasks(ChecklistEntry [int] task_entries)
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
        subentry.entries.listAppend("Adventure in The Secret Government Laboratory, find a non-combat every twenty turns.");
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
        
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
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Secret Government Laboratory")));
}


void QSpookyAirportClipperGenerateTasks(ChecklistEntry [int] task_entries)
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
        subentry.entries.listAppend("Adventure in The Mansion of Dr. Weirdeaux, use the military-grade fingernail clippers on the monsters three times per fight.");
        
        int turns_remaining = ceil(fingernails_remaining.to_float() / 3.0);
        
        subentry.entries.listAppend(fingernails_remaining + " fingernails / " + pluralise(turns_remaining, "turn", "turns") + " remaining.");
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Mansion of Dr. Weirdeaux")));
}

void QSpookyAirportEveGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item vial of patchouli oil"; //science lab
    state.quest_name = "Choking on the Rind";
	QuestStateParseMafiaQuestProperty(state, "questESpEVE");
    
    if (!state.in_progress)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    if (state.mafia_internal_step < 2)
    {
        subentry.entries.listAppend("Adventure in The Secret Government Laboratory, find a non-combat every twenty turns.|At the choice adventure, choose " + listMake("Left", "Left", "Right", "Left", "Right").listJoinComponents(__html_right_arrow_character) + ".");
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
        string [int] items_to_equip;
        if (lookupItem("Personal Ventilation Unit").equipped_amount() == 0 && lookupItem("Personal Ventilation Unit").available_amount() > 0)
        {
            items_to_equip.listAppend("Personal Ventilation Unit");
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Secret Government Laboratory")));
}



void QSpookyAirportSmokesGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item pack of smokes";
    state.quest_name = "Everyone's Running Out of Smokes";
	QuestStateParseMafiaQuestProperty(state, "questESpSmokes");
    
    if (!state.in_progress)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    item smokes = lookupItem("pack of smokes");
    
    if (state.mafia_internal_step < 2 && smokes.available_amount() < 10)
    {
        subentry.entries.listAppend("Adventure in The Deep Dark Jungle and collect smokes from the smoke monster.");
        subentry.modifiers.listAppend("olfact smoke monster");
        
        if (smokes != $item[none])
        {
            subentry.entries.listAppend(pluraliseWordy(clampi(10 - smokes.available_amount(), 0, 10), "more pack of smokes", "more packs of smokes").capitaliseFirstLetter() + " remaining.");
        }
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Deep Dark Jungle")));
}


void QSpookyAirportGoreGenerateTasks(ChecklistEntry [int] task_entries)
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
        subentry.entries.listAppend("Adventure in The Secret Government Laboratory.");
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
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
        subentry.entries.listAppend(pluralise(gore_remaining, "pound", "pounds") + " remaining.");
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Secret Government Laboratory")));
}


void QSpookyAirportOutOfOrderGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item GPS-tracking wristwatch";
    state.quest_name = "Out of Order";
	QuestStateParseMafiaQuestProperty(state, "questESpOutOfOrder");
    
    if (!state.in_progress)
        return;
    item wristwatch = lookupItem("GPS-tracking wristwatch");
    
    if (wristwatch.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    if (state.mafia_internal_step <= 2 && lookupItem("Project T. L. B.").item_amount() == 0)
    {
        subentry.modifiers.listAppend("+init");
        
        string [int] items_to_equip;
        if (wristwatch.equipped_amount() == 0)
        {
            items_to_equip.listAppend(wristwatch);
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
        else
            subentry.entries.listAppend("Adventure in The Deep Dark Jungle.");
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Deep Dark Jungle")));
}


void QSpookyAirportSerumGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item experimental serum P-00";
    state.quest_name = "Serum Sortie";
	QuestStateParseMafiaQuestProperty(state, "questESpSerum");
    
    if (!state.in_progress)
        return;
    item serum = $item[experimental serum P-00];
    
    if (serum == $item[none])
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_spooky";
    
    
    if (state.mafia_internal_step <= 2 && serum.item_amount() < 5)
    {
        if (serum.available_amount() >= 5)
        {
            subentry.entries.listAppend("Pull " + pluralise(5 - serum.item_amount(), serum) + ".");
        }
        else
        {
            subentry.modifiers.listAppend("+item");
            
            subentry.entries.listAppend("Adventure in The Mansion of Dr. Weirdeaux, collect " + int_to_wordy(5 - serum.available_amount()) + " more " + serum.plural + ".");
        }
    }
    else
    {
        url = "place.php?whichplace=airport_spooky&action=airport2_radio";
        subentry.entries.listAppend("Return to the radio and reply.");
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("The Mansion of Dr. Weirdeaux")));
}

void QSpookyAirportWeirdeauxGenerateTasks(ChecklistEntry [int] task_entries)
{
    if (__last_adventure_location != $location[The Mansion of Dr. Weirdeaux] || my_level() >= 256)
        return;
    if (!can_interact())
        return;
    if (QuestState("questESpClipper").in_progress)
        return;
    
    string url = "place.php?whichplace=airport_spooky";
    string [int] description;
    string [int] modifiers;
    if (!$skill[curse of marinara].have_skill())
    {
        if (my_class() == $class[sauceror])
        {
            description.listAppend("Buy curse of marinara from the guild trainer.");
            url = "guild.php?place=trainer";
        }
        else if ($classes[disco bandit,disco bandit,seal clubber,turtle tamer,disco bandit,pastamancer,accordion thief,disco bandit] contains my_class())
        {
            description.listAppend("Ascend sauceror to buy curse of marinara.");
            url = "ascend.php";
        }
        else
            description.listAppend("Become a sauceror at the end of this ascension, to buy curse of marinara.");
    }
    else
    {
        if ($skill[utensil twist].have_skill() && lookupItem("dinsey's pizza cutter").available_amount() > 0)
        {
            string [int] tasks;
            if (lookupItem("dinsey's pizza cutter").equipped_amount() == 0)
                tasks.listAppend("equip Dinsey's Pizza Cutter");
            tasks.listAppend("cast curse of marinara");
            tasks.listAppend("keep monster stunned");
            tasks.listAppend("cast utensil twist repeatedly in combat");
            
            description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        }
        else
        {
            if ($skill[utensil twist].have_skill())
            {
                description.listAppend("Possibly acquire Dinsey's pizza cutter by fighting Wart Dinsey as a Pastamancer.");
            }
            else if (lookupItem("dinsey's pizza cutter").available_amount() > 0)
            {
                description.listAppend("Possibly acquire the pastamancer skill Utensil Twist.");
            }
            else
            {
                description.listAppend("Possibly acquire the pastamancer skill Utensil Twist and Dinsey's pizza cutter by fighting Wart Dinsey as a Pastamancer.");
            }
            //Drunkula's bell - 15% to 20% of your buffed myst as damage?
            //right bear arm - Grizzly Scene, once/fight, 50% HP damage
            //Staff of the Headmaster's Victuals - chefstaff (requires skill), jiggle does 30% of monster HP
            //Great Wolf's lice - reduces monster attack/def by 30%. ???
            //great wolf's right paw, great wolf's left paw - gives Great Slash ability, which deals 1/3rd buffed muscle damage per paw equipped
            description.listAppend("Cast curse of marinara at the start of combat, and keep monster stunned.");
            string [item] other_relevant_items;
            other_relevant_items[$item[drunkula's bell]] = "throw in combat to deal damage";
            other_relevant_items[$item[right bear arm]] = "grizzly scene deals 50% HP damage";
            if ($skill[Spirit of Rigatoni].skill_is_usable())
                other_relevant_items[$item[Staff of the Headmaster's Victuals]] = "jiggle for 30% HP damage";
            other_relevant_items[$item[Great Wolf's lice]] = "throw in combat to deal damage";
            other_relevant_items[$item[great wolf's left paw]] = "great slash skill deals damage";
            other_relevant_items[$item[great wolf's right paw]] = "great slash skill deals damage";
            
            string [int] possibilities;
            foreach it, desc in other_relevant_items
            {
                if (it.available_amount() == 0)
                    continue;
                string line = it.capitaliseFirstLetter() + " - " + desc + ".";
                if (it.to_slot() != $slot[none] && it.equipped_amount() == 0)
                    line += " (equip)";
                possibilities.listAppend(line);
            }
            description.listAppend("Try:|*" + possibilities.listJoinComponents("|*").capitaliseFirstLetter());
        }
        
        modifiers.listAppend("+spooky resistance");
        
        string [int] blocking_sources;
        if (!__misc_state["familiars temporarily blocked"])
            blocking_sources.listAppend("a potato familiar");
        foreach it in $items[Drunkula's ring of haze,Mesmereyes&trade; contact lenses,attorney's badge,ancient stone head,navel ring of navel gazing]
        {
            if (it.available_amount() == 0)
                continue;
            if (it.equipped_amount() > 0)
                continue;
            string line = it;
            if (it.equipped_amount() == 0)
                line += " (equip)";
            blocking_sources.listAppend(line);
        }
        if (my_class() == $class[pastamancer])
            blocking_sources.listAppend("spaghetti elemental thrall");
        if (blocking_sources.count() > 0)
            description.listAppend("Use sources of blocking, like " + blocking_sources.listJoinComponents(", ", "and") + ".");
    }
    
	task_entries.listAppend(ChecklistEntryMake("__effect Incredibly Hulking", url, ChecklistSubentryMake("Gain " + pluralise(clampi(256 - my_level(), 0, 256), "level", "levels"), modifiers, description), lookupLocations("The Mansion of Dr. Weirdeaux")));
}

void QSpookyAirportGenerateTasks(ChecklistEntry [int] task_entries)
{
    if (!__misc_state["spooky airport available"])
        return;
    if (__misc_state["In run"] && !(lookupLocations("the mansion of dr. weirdeaux,the secret government lab,the deep dark jungle") contains __last_adventure_location)) //a common strategy is to accept an island quest in-run, then finish it upon prism break to do two quests in a day. so, don't clutter their interface unless they're adventuring there? hmm...
        return;
    
    QSpookyAirportClipperGenerateTasks(task_entries);
    QSpookyAirportEVEGenerateTasks(task_entries);
    QSpookyAirportSmokesGenerateTasks(task_entries);
    QSpookyAirportSerumGenerateTasks(task_entries);
    QSpookyAirportOutOfOrderGenerateTasks(task_entries);
    QSpookyAirportFakeMediumGenerateTasks(task_entries);
    QSpookyAirportGoreGenerateTasks(task_entries);
    QSpookyAirportJunglePunGenerateTasks(task_entries);
    QSpookyAirportWeirdeauxGenerateTasks(task_entries);
}

void QStenchAirportFishTrashGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item trash net";
    state.quest_name = "Teach a Man to Fish Trash";
	QuestStateParseMafiaQuestProperty(state, "questEStFishTrash");
    
    if (!state.in_progress)
        return;
    item trash_net = lookupItem("trash net");
    
    if (trash_net.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    
    if (state.mafia_internal_step <= 2)
    {
        string [int] items_to_equip;
        if (trash_net.equipped_amount() == 0)
        {
            items_to_equip.listAppend(trash_net);
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
        else
        {
            int turns_remaining = clampi(get_property_int("dinseyFilthLevel") / 5, 0, 20);
            subentry.entries.listAppend("Adventure in Pirates of the Garbage Barges for " + pluraliseWordy(turns_remaining, "more turn", "more turns") + ".");
        }
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
        
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("pirates of the garbage barges")));
}

void QStenchAirportNastyBearsGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item black picnic basket";
    state.quest_name = "Nasty, Nasty Bears";
	QuestStateParseMafiaQuestProperty(state, "questEStNastyBears");
    
    if (!state.in_progress)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    
    int bears_left = 8 - get_property_int("dinseyNastyBearsDefeated");
    if (state.mafia_internal_step < 3 && bears_left > 0)
    {
        subentry.entries.listAppend("Adventure in Gator's Country Fun-Time Liquid Waste Sluice, defeat " + pluraliseWordy(bears_left, "more nasty bear", "more nasty bears") + ".");
        
        if (__misc_state["have olfaction equivalent"])
            subentry.modifiers.listAppend("olfact nasty bears?");
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("Gator's Country Fun-Time Liquid Waste Sluice")));
}

void QStenchAirportSocialJusticeIGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item ms. accessory";
    state.quest_name = "Social Justice Adventurer I";
	QuestStateParseMafiaQuestProperty(state, "questEStSocialJusticeI");
    
    if (!state.in_progress)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    
    int adventures_left = 15 - get_property_int("dinseySocialJusticeIProgress");
    if (state.mafia_internal_step < 2 && adventures_left > 0)
    {
        subentry.entries.listAppend("Adventure in Pirates of the Garbage Barges " + pluraliseWordy(adventures_left, "more time", "more times") + ".");
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("Pirates of the Garbage Barges")));
}

void QStenchAirportSocialJusticeIIGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__monster black knight";
    state.quest_name = "Social Justice Adventurer II";
	QuestStateParseMafiaQuestProperty(state, "questEStSocialJusticeII");
    
    if (!state.in_progress)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    
    if (state.mafia_internal_step < 2)
    {
        int adventures_left = clampi(15 - get_property_int("dinseySocialJusticeIIProgress"), 0, 15);
        subentry.entries.listAppend("Adventure in Uncle Gator's Country Fun-Time Liquid Waste Sluice " + pluraliseWordy(adventures_left, "more time", "more times") + ".");
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("Gator's Country Fun-Time Liquid Waste Sluice")));
}

void QStenchAirportSuperLuberGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item lube-shoes";
    state.quest_name = "Super Luber";
	QuestStateParseMafiaQuestProperty(state, "questEStSuperLuber");
    
    if (!state.in_progress)
        return;
    item quest_item = lookupItem("lube-shoes");
    
    if (quest_item.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    
    if (state.mafia_internal_step <= 2)
    {
        string [int] items_to_equip;
        if (quest_item.equipped_amount() == 0)
        {
            items_to_equip.listAppend(quest_item);
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
        else
        {
            subentry.entries.listAppend("Adventure in Barf Mountain, return to the kiosk after riding the rollercoaster.");
            subentry.modifiers.listAppend("optional +meat");
            if (lookupEffect("How to Scam Tourists").have_effect() == 0 && lookupItem("How to Avoid Scams").available_amount() > 0)
                subentry.entries.listAppend("Use How to Avoid Scams to farm extra meat, if you want.");
            
        }
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
        
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("barf mountain")));
}

void QStenchAirportZippityDooDahGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item tea for one";
    state.quest_name = "Whistling Zippity-Doo-Dah";
	QuestStateParseMafiaQuestProperty(state, "questEStZippityDooDah");
    
    if (!state.in_progress)
        return;
    item quest_item = lookupItem("Dinsey mascot mask");
    
    if (quest_item.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    int turns_remaining = clampi(15 - get_property_int("dinseyFunProgress"), 0, 15);
    
    if (state.mafia_internal_step <= 2)
    {
        string [int] items_to_equip;
        if (quest_item.equipped_amount() == 0)
        {
            items_to_equip.listAppend(quest_item);
        }
        if (items_to_equip.count() > 0)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Equip the " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
            url = "inventory.php?which=2";
        }
        else
        {
            subentry.entries.listAppend("Adventure in the Toxic Teacups for " + pluraliseWordy(turns_remaining, "more turn", "more turns") + ".");
        }
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
        
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("toxic teacups")));
}

void QStenchAirportWillWorkForFoodGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item complimentary Dinsey refreshments";
    state.quest_name = "Will Work With Food";
	QuestStateParseMafiaQuestProperty(state, "questEStWorkWithFood");
    
    if (!state.in_progress)
        return;
        
    item quest_item = lookupItem("complimentary Dinsey refreshments");
    
    if (quest_item.available_amount() == 0)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    int tourists_to_feed = clampi(30 - get_property_int("dinseyTouristsFed"), 0, 30);
    if (state.mafia_internal_step == 1)
    {
        subentry.entries.listAppend("Adventure in Barf Mountain, use complimentary Dinsey refreshments on garbage/angry tourists.");
        subentry.entries.listAppend(pluraliseWordy(tourists_to_feed, "more remains", "more remain").capitaliseFirstLetter() + ".");
        subentry.modifiers.listAppend("olfact angry/garbage tourists");
        
    }
    else
    {
        subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
        state.image_name = "stench airport kiosk";
        url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
    }
        
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("barf mountain")));
}

void QStenchAirportGiveMeFuelGenerateTasks(ChecklistEntry [int] task_entries)
{
    QuestState state;
    state.image_name = "__item toxic globule";
    state.quest_name = "Give me fuel";
	QuestStateParseMafiaQuestProperty(state, "questEStGiveMeFuel");
    
    if (!state.in_progress)
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = state.quest_name;
	string url = "place.php?whichplace=airport_stench";
    
    if (lookupItem("toxic globule").available_amount() < 20)
    {
        int globules_needed = clampi(20 - lookupItem("toxic globule").available_amount(), 0, 20);
        if (can_interact())
        {
            subentry.entries.listAppend("Buy " + pluralise(globules_needed, "more toxic globule", "more toxic globules") + " in the mall.");
            url = "mall.php";
        }
        else
        {
            subentry.modifiers.listAppend("+unknown");
            subentry.entries.listAppend("Adventure in the Toxic Teacups and collect " + pluralise(globules_needed, "more toxic globule", "more toxic globules") + ".");
        }
    }
    else
    {
        if (lookupItem("toxic globule").item_amount() < 20)
        {
            int globules_needed = clampi(20 - lookupItem("toxic globule").item_amount(), 0, 20);
            subentry.entries.listAppend("Pull " + pluralise(globules_needed, "more toxic globule", "more toxic globules") + ".");
        }
        else
        {
            subentry.entries.listAppend("Collect wages from the employee assignment kiosk.");
            state.image_name = "stench airport kiosk";
            url = "place.php?whichplace=airport_stench&action=airport3_kiosk";
        }
    }
    
	task_entries.listAppend(ChecklistEntryMake(state.image_name, url, subentry, lookupLocations("toxic teacups")));
}

void QStenchAirportGarbageGenerateTasks(ChecklistEntry [int] task_entries)
{
    if (get_property_boolean("_dinseyGarbageDisposed"))
        return;
    ChecklistSubentry subentry;
    /*subentry.header = "Turn in garbage";
    subentry.entries.listAppend("Maintenance Tunnels Access" + __html_right_arrow_character + "Waste Disposal.");
    task_entries.listAppend(ChecklistEntryMake("__item bag of park garbage", "place.php?whichplace=airport_stench&action=airport3_tunnels", subentry));*/
    if (lookupItem("bag of park garbage").item_amount() > 0)
    {
    }
    else if (lookupItem("bag of park garbage").available_amount() > 0)
    {
    }
    else if (can_interact())
    {
        
    }
}

void QStenchAirportWartDinseyGenerateTasks(ChecklistEntry [int] task_entries)
{
    if (get_property_int("lastWartDinseyDefeated") == my_ascensions())
        return;
        
    item dinsey_item;
    if (my_class() == $class[seal clubber])
        dinsey_item = lookupItem("Dinsey's oculus");
    else if (my_class() == $class[turtle tamer])
        dinsey_item = lookupItem("Dinsey's radar dish");
    else if (my_class() == $class[pastamancer])
        dinsey_item = lookupItem("Dinsey's pizza cutter");
    else if (my_class() == $class[sauceror])
        dinsey_item = lookupItem("Dinsey's brain");
    else if (my_class() == $class[disco bandit])
        dinsey_item = lookupItem("Dinsey's pants");
    else if (my_class() == $class[accordion thief])
        dinsey_item = lookupItem("Dinsey's glove");
    if (!($classes[seal clubber,turtle tamer,pastamancer,sauceror,disco bandit,accordion thief] contains my_class())) //class-specific items only drop when you're class-specific
        return;
        
    if (last_monster() != lookupMonster("Wart Dinsey"))
    {
        if (dinsey_item == $item[none] || haveAtLeastXOfItemEverywhere(dinsey_item, 1))
            return;
    }
    boolean [item] keycards = lookupItems("keycard &alpha;,keycard &beta;,keycard &gamma;,keycard &delta;");
    
    item [int] missing_keycards;
    foreach it in keycards
    {
        if (it.available_amount() == 0)
        {
            missing_keycards.listAppend(it);
        }
    }
    if (missing_keycards.count() > 0)
        return;
        
        
	string url = "place.php?whichplace=airport_stench&action=airport3_tunnels";
    string [int] description;
    string [int] modifiers;
    modifiers.listAppend("+" + MAX(250, lookupMonster("Wart Dinsey").base_initiative) + "% init");
    modifiers.listAppend("+lots all resistance");
    
    item mercenary_pistol = lookupItem("mercenary pistol");
    description.listAppend("Run +resistance, deal many sources of non-stench damage to him. (100 damage cap)");
    if (mercenary_pistol.available_amount() > 0)
    {
        string [int] tasks;
        if (mercenary_pistol.equipped_amount() == 0)
            tasks.listAppend("equip a mercenary pistol");
        item clip = lookupItem("special clip: boneburners");
        if (clip.item_amount() == 0 && lookupItem("special clip: splatterers").item_amount() > 0)
            clip = lookupItem("special clip: splatterers");
        if (clip.item_amount() == 0)
        {
            tasks.listAppend("acquire a few clips of " + clip);
        }
        tasks.listAppend("throw " + clip + " in combat");
        
        description.listAppend(tasks.listJoinComponents(", ").capitaliseFirstLetter() + ".");
    }
    else
    {
        description.listAppend("The mercenary pistol is useful for this, if you can acquire one.");
    }
    description.listAppend("Will acquire a " + dinsey_item + ".");
    
	task_entries.listAppend(ChecklistEntryMake("__item " + dinsey_item, url, ChecklistSubentryMake("Defeat Wart Dinsey", modifiers, description)));
}

void QStenchAirportGenerateTasks(ChecklistEntry [int] task_entries)
{
    if (!__misc_state["stench airport available"])
        return;
    if (__misc_state["In run"] && !(lookupLocations("Pirates of the Garbage Barges,Barf Mountain,The Toxic Teacups,Uncle Gator's Fun-Time Liquid Waste Sluice") contains __last_adventure_location))
        return;
    QStenchAirportFishTrashGenerateTasks(task_entries);
    QStenchAirportNastyBearsGenerateTasks(task_entries);
    QStenchAirportSocialJusticeIGenerateTasks(task_entries);
    QStenchAirportSocialJusticeIIGenerateTasks(task_entries);
    QStenchAirportSuperLuberGenerateTasks(task_entries);
    QStenchAirportZippityDooDahGenerateTasks(task_entries);
    QStenchAirportGarbageGenerateTasks(task_entries);
    QStenchAirportGiveMeFuelGenerateTasks(task_entries);
    QStenchAirportWillWorkForFoodGenerateTasks(task_entries);
    QStenchAirportWartDinseyGenerateTasks(task_entries);
}

void QAirportGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    ChecklistEntry [int] chosen_entries = optional_task_entries;
    if (__misc_state["In run"])
        chosen_entries = future_task_entries;
    
    QSleazeAirportGenerateTasks(chosen_entries);
    QSpookyAirportGenerateTasks(chosen_entries);
    QStenchAirportGenerateTasks(chosen_entries);
}

void QAirportGenerateResource(ChecklistEntry [int] resource_entries)
{
    QSleazeAirportGenerateResource(resource_entries);
}