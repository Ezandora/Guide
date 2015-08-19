
void QFeloniaInit()
{
	//questM03Bugbear
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM03Bugbear");
	
	state.quest_name = "Felonia";
	state.image_name = "__item knoll mushroom";
	
	state.startable = knoll_available();
	
	__quest_state["Felonia"] = state;
}


void QFeloniaGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Felonia"];
	if (!base_quest_state.in_progress)
		return;
    if (!knoll_available())
        return;
    if (__misc_state["familiars temporarily blocked"]) //cannot complete
        return;
    if (__misc_state["in run"] && $location[the bugbear pen].turnsAttemptedInLocation() == 0)
        return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string url = "place.php?whichplace=knoll_friendly";
	
    if (get_property("lastEncounter") == "Felonia, Queen of the Spooky Gravy Fairies")
    {
        subentry.header = "Speak to Mayor Zapruder";
    }
    else if (base_quest_state.mafia_internal_step == 1)
    {
        //Acquire annoying pitchfork:
        subentry.header = "Tame the Bugbears";
        if ($item[annoying pitchfork].available_amount() == 0)
        {
            if (can_interact())
            {
                subentry.entries.listAppend("Acquire annoying pitchfork in the mall.");
                url = "mall.php";
            }
            else
            {
                subentry.entries.listAppend("Acquire annoying pitchfork from an annoying spooky gravy fairy in the Bugbear Pens.");
            }
        }
        else
            subentry.entries.listAppend("Speak to Mayor Zapruder to give him the annoying pitchfork.");
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        //Acquire the right mushroom:
        subentry.header = "Summon a Mushroom Familiar";
        
        if ($item[frozen mushroom].available_amount() > 0 && $item[stinky mushroom].available_amount() > 0 && $item[flaming mushroom].available_amount() > 0)
        {
            subentry.entries.listAppend("Speak to Mayor Zapruder to give him mushrooms.");
        }
        else
        {
            subentry.entries.listAppend("Grow the mushroom Mayor Zapruder wants.");
            url = "knoll_mushrooms.php";
        }
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        //defeat felonia:
        subentry.header = "Defeat Felonia";
        
        boolean currently_using_a_relevant_familiar = false;
        familiar fairy_to_use = $familiar[none];
        foreach f in $familiars[Flaming Gravy Fairy,Frozen Gravy Fairy,Stinky Gravy Fairy,Sleazy Gravy Fairy,spooky gravy fairy]
        {
            if (f.have_familiar())
                fairy_to_use = f;
            if (my_familiar() == f)
                currently_using_a_relevant_familiar = true;
        }
        if ($familiar[spooky gravy fairy].have_familiar())
            fairy_to_use = $familiar[spooky gravy fairy];
        
        if (fairy_to_use == $familiar[none])
        {
            item [int] fairies_can_grow;
            foreach it in $items[pregnant flaming mushroom,pregnant frozen mushroom,pregnant stinky mushroom,pregnant oily golden mushroom,pregnant gloomy black mushroom]
            {
                fairies_can_grow.listAppend(it);
            }
            if (fairies_can_grow.count() == 0)
            {
                subentry.entries.listAppend("Um... try to find a gravy fairy somehow.");
            }
            else
            {
                subentry.entries.listAppend("Grow one of " + fairies_can_grow.listJoinComponents(", ", "or") + ".");
            }
        }
        else if (!currently_using_a_relevant_familiar)
        {
            subentry.entries.listAppend("Bring along a " + fairy_to_use + ".");
            url = "familiar.php";
        }
        else
        {
            boolean need_minus_combat = false;
            if ($item[inexplicably glowing rock].available_amount() > 0 && $item[spooky glove].available_amount() > 0)
            {
                string [int] tasks;
                if ($item[spooky glove].equipped_amount() == 0)
                {
                    tasks.listAppend("equip the spooky glove");
                    url = "inventory.php?which=2";
                }
                tasks.listAppend("defeat Felonia");
                
                subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + " in the Spooky Gravy Burrow.");
                need_minus_combat = true;
            }
            else
            {
                item [int] items_needed;
                if ($item[inexplicably glowing rock].available_amount() == 0)
                {
                    items_needed.listAppend($item[inexplicably glowing rock]);
                    need_minus_combat = true;
                }
                
                if ($item[spooky glove].available_amount() == 0)
                {
                    if ($item[spooky fairy gravy].available_amount() > 0 && $item[small leather glove].available_amount() > 0)
                    {
                        url = "craft.php?mode=cook";
                        subentry.entries.listAppend("Make and wear a spooky glove. (cook spooky fairy gravy + small leather glove)");
                    }
                    else
                    {
                        if ($item[spooky fairy gravy].available_amount() == 0)
                        {
                            items_needed.listAppend($item[spooky fairy gravy]);
                            need_minus_combat = true;
                        }
                        if ($item[small leather glove].available_amount() == 0)
                        {
                            subentry.modifiers.listAppend("+900% item");
                            items_needed.listAppend($item[small leather glove]);
                            subentry.entries.listAppend("Or buy small leather glove in the mall.");
                        }
                    }
                }
                if (items_needed.count() > 0)
                {
                    subentry.entries.listPrepend("Adventure in the Spooky Gravy Burrow for " + items_needed.listJoinComponents(", ", "and") + ".");
                }
            }
        
            if (need_minus_combat)
                subentry.modifiers.listPrepend("-combat?");
        }
    }
    
    boolean [location] relevant_locations;
    relevant_locations[$location[the bugbear pen]] = true;
    relevant_locations[$location[the spooky gravy burrow]] = true;
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, relevant_locations));
}