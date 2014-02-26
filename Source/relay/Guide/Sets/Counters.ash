void SCountersInit()
{
    //parse counters:
	//Examples:
	//relayCounters(user, now '1378:Fortune Cookie:fortune.gif', default )
	//relayCounters(user, now '1539:Semirare window begin loc=*:lparen.gif:1579:Semirare window end loc=*:rparen.gif', default )
	//relayCounters(user, now '70:Semirare window begin:lparen.gif:80:Semirare window end loc=*:rparen.gif', default )
	//relayCounters(user, now '1750:Romantic Monster window begin loc=*:lparen.gif:1760:Romantic Monster window end loc=*:rparen.gif', default )
    //relayCounters(user, now '7604:Fortune Cookie:fortune.gif:7584:Fortune Cookie:fortune.gif', default )
    //relayCounters(user, now '450:Fortune Cookie:fortune.gif:458:Fortune Cookie:fortune.gif:401:Dance Card loc=109:guildapp.gif', default )
    //relayCounters(user, now '1271:Nemesis Assassin window begin loc=*:lparen.gif:1286:Nemesis Assassin window end loc=*:rparen.gif:1331:Fortune Cookie:fortune.gif', default )
    
	string counter_string = get_property("relayCounters");
	string [int] counter_split = split_string_mutable(counter_string, ":");
	
	Vec2i romantic_monster_window = Vec2iMake(-1, -1);
	boolean found_romantic_monster = false;
	
	Vec2i semirare_turn_range = Vec2iMake(-1, -1);
	boolean found_semirare_turn_range = false;
	string [int] potential_semirare_turns;
	int turns_until_dance_card = -1;
    
    int [string] windows_begin;
    int [string] windows_end;
	for i from 0 to (counter_split.count() - 1) by 3
	{
		if (i + 3 > counter_split.count())
			break;
		int turn_number = to_int(counter_split[i]);
		int turns_until_counter = turn_number - my_turncount();
		string counter_name = counter_split[i + 1];
		string counter_gif = counter_split[i + 2];
		
		if (counter_name.stringHasPrefix("Semirare window begin"))
		{
			semirare_turn_range.x = turns_until_counter;
			found_semirare_turn_range = true;
		}
		else if (counter_name.stringHasPrefix("Semirare window end"))
		{
			semirare_turn_range.y = turns_until_counter;
			found_semirare_turn_range = true;
		}
		else if (counter_name == "Fortune Cookie")
		{
			potential_semirare_turns.listAppend(turns_until_counter);
		}
		else if (counter_name.stringHasPrefix("Romantic Monster window begin"))
		{
			romantic_monster_window.x = turns_until_counter;
			found_romantic_monster = true;
		}
		else if (counter_name.stringHasPrefix("Romantic Monster window end"))
		{
			romantic_monster_window.y = turns_until_counter;
			found_romantic_monster = true;
		}
		else if (counter_name.stringHasPrefix("Dance Card"))
		{
			turns_until_dance_card = turns_until_counter;
		}
        else if (counter_name.contains_text("window begin"))
        {
            //generic window
            string found_window = counter_name.substring(0, counter_name.index_of(" window begin")).HTMLEscapeString();
            windows_begin[found_window] = turns_until_counter;
        }
        else if (counter_name.contains_text("window end"))
        {
            //generic window
            string found_window = counter_name.substring(0, counter_name.index_of(" window end")).HTMLEscapeString();
            windows_end[found_window] = turns_until_counter;
        }
	}
	__misc_state_int["Turns until dance card"] = turns_until_dance_card;
    if (potential_semirare_turns.count() == 1 && potential_semirare_turns[0] < 0) //missed it
        potential_semirare_turns.listClear();
	if (potential_semirare_turns.count() > 0)
	{
        sort potential_semirare_turns by value.to_int(); //fortune cookie counters are not always sorted
		__misc_state_string["Turns until semi-rare"] = potential_semirare_turns.listJoinComponents(",");
	}
	else if (found_semirare_turn_range && semirare_turn_range.y >= 0)
	{
		__misc_state_string["Turn range until semi-rare"] = semirare_turn_range.x + "," + semirare_turn_range.y;
	}
	if (found_romantic_monster)
	{
		__misc_state_string["Romantic Monster turn range"] = romantic_monster_window.x + "," + romantic_monster_window.y;
	}
	__misc_state_string["Romantic Monster Name"] = get_property("romanticTarget").HTMLEscapeString();
    
    string [int] found_counter_window_names;
    foreach window in windows_begin
    {
        int start_turn = windows_begin[window];
        int end_turn = -1;
        if (windows_end contains window)
            end_turn = windows_end[window];
        string window_turns = start_turn + "," + end_turn;
        __misc_state_string["range of counter window " + window] = window_turns;
        found_counter_window_names.listAppend(window);
    }
    foreach window in windows_end
    {
        if (windows_begin contains window)
            continue;
        int start_turn = -1;
        int end_turn = windows_end[window];
        string window_turns = start_turn + "," + end_turn;
        __misc_state_string["range of counter window " + window] = window_turns;
        found_counter_window_names.listAppend(window);
        
    }
    if (found_counter_window_names.count() > 0)
        __misc_state_string["Found counter windows"] = found_counter_window_names.listJoinComponents(",");
}

void SCountersGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
    string [string] window_image_names;
    window_image_names["Nemesis Assassin"] = "__familiar Penguin Goodfella"; //technically not always a penguin, but..
    window_image_names["Bee"] = "__effect Float Like a Butterfly, Smell Like a Bee"; //bzzz!
    window_image_names["Holiday Monster"] = "__familiar hand turkey";
    //window_image_names["Event Monster"] = ""; //no idea
    string [int] unknown_counters = __misc_state_string["Found counter windows"].split_string_mutable(",");
    foreach key in unknown_counters
    {
        string window_name = unknown_counters[key];
        if (window_name == "")
            continue;
        
        string [int] window_range = __misc_state_string["range of counter window " + window_name].split_string_mutable(",");
        Vec2i turn_range = Vec2iMake(window_range[0].to_int_silent(), window_range[1].to_int_silent());
        
        if (!(turn_range.x <= 10 && from_task) && !(turn_range.x > 10 && !from_task))
            continue;
        
        
        
        boolean very_important = false;
        if (turn_range.x <= 0)
            very_important = true;
        
        
        
        ChecklistSubentry subentry;
        subentry.header = window_name;
        
        
        if (turn_range.y <= 0)
            subentry.header += " now or soon";
        else if (turn_range.x <= 0)
            subentry.header += " between now and " + turn_range.y + " turns.";
        else
            subentry.header += " in [" + turn_range.x + " to " + turn_range.y + "] turns.";
        
        string image_name = "__item Pok&euml;mann figurine: Frank"; //default - some person
        if (window_image_names contains window_name)
            image_name = window_image_names[window_name];
        
        int importance = 10;
        if (very_important)
            importance = -11;
        ChecklistEntry entry = ChecklistEntryMake(image_name, "", subentry, importance);
        
        if (very_important)
            task_entries.listAppend(entry);
        else
            optional_task_entries.listAppend(entry);
        
    }
}

void SCountersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (__misc_state_int["Turns until dance card"] != -1)
	{
		int turns_until_dance_card = __misc_state_int["Turns until dance card"];
        
		string stats = "Gives ~" + __misc_state_float["dance card average stats"].round() + " mainstats.";
		if (turns_until_dance_card == 0)
		{
			task_entries.listAppend(ChecklistEntryMake("__item dance card", $location[the haunted ballroom].getClickableURLForLocation(), ChecklistSubentryMake("Dance card up now.", "", "Adventure in haunted ballroom. " + stats), -11));
		}
		else
		{
			optional_task_entries.listAppend(ChecklistEntryMake("__item dance card", "", ChecklistSubentryMake("Dance card up in " + pluralize(turns_until_dance_card, "adventure", "adventures") + ".", "", "Haunted ballroom. " + stats)));
		}
	}
    
	SCountersGenerateEntry(task_entries, optional_task_entries, true);
}

void SCountersGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SCountersGenerateEntry(available_resources_entries, available_resources_entries, false);
}