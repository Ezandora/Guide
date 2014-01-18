
void QWizardOfEgoInit()
{
    if (!__misc_state["In aftercore"]) //not yet
        return;
    if ($items[Manual of Dexterity,Manual of Labor,Manual of Transmission].available_amount() > 0) //finished already
        return;
        
	//questM02Artist
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questG03Ego");
	
	state.quest_name = "The Wizard of Ego";
	state.image_name = "__item dilapidated wizard hat";
	
	state.startable = true;
	
	__quest_state["Wizard of Ego"] = state;
}


void QWizardOfEgoGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Wizard of Ego"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string url = "";
    if (base_quest_state.mafia_internal_step == 7 || $item[dusty old book].available_amount() > 0)
    {
        //7	You found some kind of dusty old book in Fernswarthy's tower. Hopefully that's enough to keep that guy in your guild off your case.
        url = "guild.php";
        subentry.entries.listAppend("Speak to the guild.");
    }
    else if (base_quest_state.mafia_internal_step == 1)
    {
        url = "place.php?whichplace=plains";
        //1	You've been tasked with digging up the grave of an ancient and powerful wizard and bringing back a key that was buried with him. What could possibly go wrong?
        if ($item[Fernswarthy's key].available_amount() > 0)
        {
            url = "guild.php";
            subentry.entries.listAppend("Return to your guild.");
        }
        else if ($items[grave robbing shovel, rusty grave robbing shovel].available_amount() == 0)
        {
            subentry.entries.listAppend("Acquire a grave robbing shovel. (from mall)");
        }
        else
        {
            subentry.entries.listAppend("Adventure at the misspelled cemetary.");
        }
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        //2	Well, you got the key and turned it in -- mission accomplished. How much do you wanna bet, though, that they won't be able to find anyone else to search the tower, and you'll be stuck with the dirty work again?
        url = "guild.php";
        subentry.entries.listAppend("Speak to the guild.");
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        //3	Much as you expected, you've been given back the key to Fernswarthy's tower and ordered to investigate.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins.");
    }
    else if (base_quest_state.mafia_internal_step == 4)
    {
        //4	You've unlocked Fernswarthy's tower. Now you just have to find something to show your guild leaders, to prove you haven't just been slacking off this whole time.
        //Unlocking just means visiting the area.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins. Three more non-combats remain.");
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //5	You've found some stairs in Fernswarthy's tower, but they don't lead to much. Better keep looking.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins. Two more non-combats remain.");
    }
    else if (base_quest_state.mafia_internal_step == 6)
    {
        //6	You've found a trapdoor to Fernswarthy's basement, which is potentially interesting and/or dangerous. It's probably not what your Guild is interested in, though, so you should probably keep looking.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins. One more non-combat remain.");
    }
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[pre-cyrpt cemetary,post-cyrpt cemetary, tower ruins]));
}