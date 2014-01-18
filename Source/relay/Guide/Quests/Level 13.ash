
void QLevel13Init()
{
	//questL13Final
    
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL13Final");
    if (my_path() == "Bugbear Invasion")
        QuestStateParseMafiaQuestPropertyValue(state, "finished"); //never will start
	//QuestStateParseMafiaQuestPropertyValue(state, "step10");
	state.quest_name = "Naughty Sorceress Quest";
	state.image_name = "naughty sorceress lair";
	state.council_quest = true;
	//alternate idea: gate, mirror, stone mariachis, courtyard, tower... hmm, no
	
	state.state_boolean["past gates"] = (state.mafia_internal_step > 1);
	state.state_boolean["past keys"] = (state.mafia_internal_step > 3);
	state.state_boolean["past tower"] = (state.mafia_internal_step > 5);
	state.state_boolean["king waiting to be freed"] = (state.mafia_internal_step == 11);
    
    
	state.state_boolean["have relevant guitar"] = $items[acoustic guitarrr,heavy metal thunderrr guitarrr,stone banjo,Disco Banjo,Shagadelic Disco Banjo,Seeger's Unstoppable Banjo,Massive sitar,4-dimensional guitar,plastic guitar,half-sized guitar,out-of-tune biwa,Zim Merman's guitar,dueling banjo].available_amount() > 0;
    
	state.state_boolean["have relevant accordion"] = $items[stolen accordion,calavera concertina,Rock and Roll Legend,Squeezebox of the Ages,The Trickster's Trikitixa,toy accordion].available_amount() > 0;
	state.state_boolean["have relevant drum"] = $items[tambourine, big bass drum, black kettle drum, bone rattle, hippy bongo, jungle drum].available_amount() > 0;
    
    if (state.state_boolean["past keys"])
    {
        state.state_boolean["have relevant guitar"] = true;
        
        state.state_boolean["have relevant accordion"] = true;
        state.state_boolean["have relevant drum"] = true;
    }
	state.state_boolean["digital key used"] = state.state_boolean["past keys"]; //FIXME be finer-grained?
    
    boolean other_quests_completed = true;
    for i from 2 to 12
        if (!__quest_state["Level " + i].finished)
            other_quests_completed = false;
    if (other_quests_completed)
        state.startable = true;
    
	
	__quest_state["Level 13"] = state;
	__quest_state["Lair"] = state;
}


void QLevel13GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 13"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 13"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "lair.php";
	
	string image_name = base_quest_state.image_name;
	
	boolean should_output_main_entry = true;
	if (base_quest_state.mafia_internal_step == 1)
	{
		//at three gates
		subentry.entries.listAppend("At three gates.");
        if (__misc_state["can use clovers"] && (availableDrunkenness() >= 3 || inebriety_limit() == 0))
        {
            //FIXME be better
            if ($items[large box,blessed large box].available_amount() == 0 && $items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() > 0)
            {
                if (in_hardcore())
                    subentry.entries.listAppend("For potions, acquire a large box (fax, dungeons of doom) and meatpaste with a clover.");
                else
                    subentry.entries.listAppend("For potions, pull a large box and meatpaste with a clover.");
            }
        }
        else
            subentry.entries.listAppend("For potions, visit the dungeons of doom.");
        url = "lair1.php";
	}
	else if (base_quest_state.mafia_internal_step == 2)
	{
		//past three gates, at mirror
		subentry.entries.listAppend("At mirror.");
        url = "lair1.php";
	}
	else if (base_quest_state.mafia_internal_step == 3)
	{
		//past mirror, at six keys
		subentry.entries.listAppend("Six keys.");
        url = "lair2.php";
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
        url = "lair3.php";
		//at hedge maze
		subentry.modifiers.listAppend("+67% item");
		subentry.entries.listAppend("Hedge maze. Find puzzles.");
		if (item_drop_modifier() < 66.666666667)
			subentry.entries.listAppend("Need more +item.");
        if ($item[hedge maze key].available_amount() == 0)
			subentry.entries.listAppend("Find the key.");
        else
			subentry.entries.listAppend("Find the way out.");
		
	}
	else if (base_quest_state.mafia_internal_step == 5)
	{
		//at tower, time to kill monsters!
		subentry.entries.listAppend("Tower monsters.");
		//FIXME show levels and... um... all that
	}
	else if (base_quest_state.mafia_internal_step == 6)
	{
        url = "lair6.php";
		//past tower, at some sort of door code
		subentry.entries.listAppend("Puzzles.");
		subentry.entries.listAppend("Have mafia do it: Quests" + __html_right_arrow_character + "Tower (to shadow)");
	}
	else if (base_quest_state.mafia_internal_step == 7 || base_quest_state.mafia_internal_step == 8)
	{
        url = "lair6.php";
		//at top of tower (fight shadow??)
		//8 -> fight shadow
		subentry.modifiers.listAppend("+HP");
		subentry.modifiers.listAppend("+" + $monster[Your Shadow].monster_initiative() + "% init");
		subentry.entries.listAppend("Fight your shadow.");
	}
	else if (base_quest_state.mafia_internal_step == 9)
	{
        url = "lair6.php";
		//counter familiars
		subentry.modifiers.listAppend("+familiar weight");
		subentry.entries.listAppend("Counter familiars. Need 20-pound familiars.");
		subentry.entries.listAppend("Have mafia do it: Quests" + __html_right_arrow_character + "Tower (complete)");
	}
	else if (base_quest_state.mafia_internal_step == 10)
	{
        url = "lair6.php";
		//At NS. Good luck, we're all counting on you.
		subentry.modifiers.listAppend("+moxie equipment");
		subentry.modifiers.listAppend("no buffs");
		subentry.entries.listAppend("She awaits.");
		if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0)
			subentry.entries.listAppend("Run spangly mariachi pants on scarecrow. (2x potato)");
		else if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[swashbuckling pants].available_amount() > 0)
			subentry.entries.listAppend("Run swashbuckling pants on scarecrow. (2x potato)");
		else if (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0)
			subentry.entries.listAppend("Run spangly sombrero on mad hatrack. (2x potato)");
		else
			subentry.entries.listAppend("Run a potato familiar if you can.");
			
		image_name = "naughty sorceress";
	}
	else if (base_quest_state.mafia_internal_step == 11)
	{
        url = "lair6.php";
		//King is waiting in his prism.
		task_entries.listAppend(ChecklistEntryMake("__item puzzling trophy", "trophy.php", ChecklistSubentryMake("Check for trophies", "10k meat, trophy requirements", "Certain trophies are missable after freeing the king")));
		should_output_main_entry = false;
		
	}
	if (should_output_main_entry)
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry));
}