void QSpaceElvesInit()
{
	//questG04Nemesis
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questF04Elves");
	
	state.quest_name = "Repair the Elves' Shield Generator Quest";
	state.image_name = "spooky little girl";
	
	if (my_basestat(my_primestat()) >= 12)
		state.startable = true;
		
	
	__quest_state["Space Elves"] = state;
}


void QSpaceElvesGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Space Elves"];
	if (base_quest_state.finished)
		return;
    
    string url = "place.php?whichplace=spaaace";
    
    boolean turns_spent_in_locations_already = false;
    if ($locations[Domed City of Ronaldus,Domed City of Grimacia,Hamburglaris Shield Generator].turnsAttemptedInLocation() > 0)
        turns_spent_in_locations_already = true;
    
    if (!turns_spent_in_locations_already && $effect[transpondent].have_effect() == 0) //suggest it when they go to spaaace, otherwise, don't bug them?
        return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    subentry.entries.listAppend("Gives 200 lunar isotopes and Elvish Paradise access.");
    
	if (base_quest_state.mafia_internal_step < 3)
	{
		string [int] ronald_map_entries;
		string [int] grimace_map_entries;
		if ($item[e.m.u. rocket thrusters].available_amount() == 0)
			ronald_map_entries.listAppend("Ronald map" + __html_right_arrow_character + "Try the Swimming Pool" + __html_right_arrow_character + "To the Left, to the Left" + __html_right_arrow_character + "Take the Red Door");
		if ($item[E.M.U. joystick].available_amount() == 0)
			ronald_map_entries.listAppend("Ronald map" + __html_right_arrow_character + "Check out the Armory" + __html_right_arrow_character + "My Left Door" + __html_right_arrow_character + "Crawl through the Ventilation Duct");
		if ($item[E.M.U. harness].available_amount() == 0)
			grimace_map_entries.listAppend("Grimace map" + __html_right_arrow_character + "Check out the Coat Check" + __html_right_arrow_character + "Exit, Stage Left" + __html_right_arrow_character + "Be the Duke of the Hazard");
		if ($item[E.M.U. helmet].available_amount() == 0)
			grimace_map_entries.listAppend("Grimace map" + __html_right_arrow_character + "Check out the Coat Check" + __html_right_arrow_character + "Stage Right, Even" + __html_right_arrow_character + "Try the Starboard Door");
		if (ronald_map_entries.count() > 0)
		{
			string header = "Ronald prime:";
			string [int] line;
			int maps_needed = ronald_map_entries.count() - $item[map to safety shelter ronald prime].available_amount();
			if (maps_needed > 0)
            {
                if (subentry.modifiers.count() == 0)
                    subentry.modifiers.listAppend("+item");
				line.listAppend("Acquire " + pluralize(maps_needed, $item[map to safety shelter ronald prime]));
            }
			
            line.listAppendList(ronald_map_entries);
			
				
			subentry.entries.listAppend(header + HTMLGenerateIndentedText(line.listJoinComponents("<hr>")));
		}
		if (grimace_map_entries.count() > 0)
		{
			string header = "Grimace prime:";
			string [int] line;
			int maps_needed = grimace_map_entries.count() - $item[map to safety shelter grimace prime].available_amount();
			if (maps_needed > 0)
            {
                if (subentry.modifiers.count() == 0)
                    subentry.modifiers.listAppend("+item");
				line.listAppend("Acquire " + pluralize(maps_needed, $item[map to safety shelter grimace prime]));
            }
				
            line.listAppendList(grimace_map_entries);
			subentry.entries.listAppend(header + HTMLGenerateIndentedText(line.listJoinComponents("<hr>")));
		}
		if (ronald_map_entries.count() == 0 && grimace_map_entries.count() == 0)
			subentry.entries.listAppend("Look for the spooky little girl on Grimace or Ronald.");
        else if ($items[map to safety shelter ronald prime, map to safety shelter grimace prime].available_amount() > 0)
            url = "inventory.php?which=3";
	}
	else if (base_quest_state.mafia_internal_step == 3)
	{
		if ($item[spooky little girl].equipped_amount() == 0)
			subentry.entries.listAppend("Equip spooky little girl.");
		else if ($item[spooky little girl].available_amount() == 0)
			subentry.entries.listAppend("spooky");
		else
		{
			subentry.entries.listAppend("Adventure in Grimace with spooky little girl.");
		}
			
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
		if ($item[E.M.U. Unit].equipped_amount() == 0)
			subentry.entries.listAppend("Equip E.M.U. Unit.");
		else
			subentry.entries.listAppend("Adventure at the Hamburglaris Shield Generator, solve puzzle.");
	}
	if ($effect[Transpondent].have_effect() == 0)
	{
		subentry.entries.listClear();
        subentry.entries.listAppend("Gives 200 lunar isotopes and Elvish Paradise access.");
		subentry.entries.listAppend("Use transporter transponder to reach spaaace.");
        if ($item[transporter transponder].available_amount() > 0)
            url = "inventory.php?which=3";
        else
            url = "mall.php";
	}
	
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[domed city of ronaldus, domed city of grimacia,hamburglaris shield generator]));
}