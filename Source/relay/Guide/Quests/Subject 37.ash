
void QSubject37Init()
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM13Escape");
    
    
	state.quest_name = "The Pretty Good Escape";
	state.image_name = "__item mysterious silver lapel pin";
	
	state.startable = true;
	
	__quest_state["Subject 37"] = state;
}


void QSubject37GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Subject 37"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    
    string active_url = $location[Cobb's Knob Menagerie, Level 1].getClickableURLForLocation();
    
    /*
started	Subject 37 wants you to investigate the Cobb's Knob Laboratories and find out what they're planning.
step1	Take the file you found back to Subject 37.
step2	Subject 37 wants something from the BASIC Elementals on level 1 of the Cobb's Knob Menagerie.
step3	Take the GOTO back to Subject 37.
step4	Subject 37 wants some weremoose spit from level 2 of the Cobb's Knob Menagerie.
step5	Take the spit back to Subject 37.
step6	Subject 37 wants some abominable blubber from level 3 of the Cobb's Knob Menagerie.
step7	Take the blubber back to Subject 37.
step8	You've done a good turn, and helped Subject 37 make his escape from the Cobb's Knob Menagerie.
    */
    
    boolean need_to_return_goto = base_quest_state.mafia_internal_step <= 3;
    boolean need_to_return_weremoose = base_quest_state.mafia_internal_step <= 5;
    boolean need_to_return_blubber = base_quest_state.mafia_internal_step <= 7;
    
    if (base_quest_state.mafia_internal_step == 1)
    {
        subentry.entries.listAppend("Acquire a subject 37 file from Knob Goblin Very Mad Scientist.");
        if (!$monster[Knob Goblin Mad Scientist].is_banished())
            subentry.modifiers.listAppend("banish Knob Goblin Mad Scientist");
        active_url = $location[Cobb's Knob Laboratory].getClickableURLForLocation();
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        subentry.entries.listAppend("Return the file to Subject 37.");
    }
    else
    {
    	boolean [item] items_needed;
     
        item [int] items_to_buy_in_mall;
        if (need_to_return_goto && $item[goto].available_amount() == 0)
        {
            //234% item from BASIC elemental
            if (!in_ronin())
            {
            	items_needed[$item[goto]] = true;
            }
            else
            {
                subentry.modifiers.listAppend("+234% item");
                subentry.entries.listAppend("10 ADVENTURE \"MENAGERIE LEVEL 1\"|20 PRINT \"COLLECT GOTO FROM BASIC ELEMENTAL\"|30 GOTO 10");
            }
        }
        if (need_to_return_weremoose && $item[weremoose spit].available_amount() == 0)
        {
            //+item? from weremoose
            if (!in_ronin())
            {
                items_needed[$item[weremoose spit]] = true;
            }
            else
            {
                if (subentry.modifiers.count() == 0)
                    subentry.modifiers.listAppend("+item?");
                subentry.entries.listAppend("Collect weremoose spit from a weremoose in Menagerie Level 2.");
            }
        }
        if (need_to_return_blubber && $item[abominable blubber].available_amount() == 0)
        {
            //234% item from Portly Abomination
            if (!in_ronin())
            {
                items_needed[$item[abominable blubber]] = true;
            }
            else
            {
                if (subentry.modifiers.count() == 0)
                    subentry.modifiers.listAppend("+234% item");
                subentry.entries.listAppend("Collect abominable blubber from a Portly Abomination in Menagerie Level 3.");
            }
        }
        foreach it in items_needed
        {
        	if (it.available_amount() == 0)
                items_to_buy_in_mall.listAppend(it);
            else
                subentry.entries.listAppend("Acquire " + it + ", from storage(?).");
        }
        if (items_to_buy_in_mall.count() > 0)
        {
            subentry.entries.listAppend("Buy " + items_to_buy_in_mall.listJoinComponents(", ", "and") + " from the mall.");
            active_url = "mall.php";
        }
        if (subentry.entries.count() == 0)
        {
            subentry.entries.listAppend("Speak to Subject 37.");
        }
    }
		
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[]));
}
