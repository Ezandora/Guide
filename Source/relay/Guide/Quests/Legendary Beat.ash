void QLegendaryBeatInit()
{
    if ($item[Map to Professor Jacking's laboratory].available_amount() == 0)
        return;
	//questI02Beat
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questI02Beat");
    
    if (!state.started)
    {
        QuestStateParseMafiaQuestPropertyValue(state, "started");
    }
	
	state.quest_name = "Quest for the Legendary Beat";
	state.image_name = "__item the Legendary Beat";
    
    if (state.in_progress)
    {
        //FIXME temporary code
        //no way to detect if the legendary beat was found
        //if (state.mafia_internal_step < 2 && $location[professor jacking's small-o-fier].turnsAttemptedInLocation() > 0 || $location[professor jacking's huge-a-ma-tron].turnsAttemptedInLocation() > 0)
            //state.mafia_internal_step = 2;
    }
	
	__quest_state["Legendary Beat"] = state;
}

void QLegendaryBeatGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($item[Map to Professor Jacking's laboratory].available_amount() == 0)
        return;
        
	QuestState base_quest_state = __quest_state["Legendary Beat"];
	if (!base_quest_state.in_progress)
		return;
    
    //FIXME temporary:
    if (!($locations[professor jacking's small-o-fier, professor jacking's huge-a-ma-tron] contains __last_adventure_location))
        return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
        
    //FIXME support for fruit machine sidequest?
    
    if (base_quest_state.mafia_internal_step == 1 && false)
    {
        subentry.entries.listAppend("Defeat Professor Jacking.");
    }
    else if (base_quest_state.mafia_internal_step == 2 || true)
    {
        //Main quest, in reverse order:
        if ($item[can-you-dig-it?].available_amount() > 0 && $effect[stubbly legs].have_effect() > 0)
        {
            subentry.modifiers.listAppend("-combat");
            //6/7
            string [int] tasks;
            if ($item[can-you-dig-it?].equipped_amount() == 0)
                tasks.listAppend("equip can-you-dig-it?");
            tasks.listAppend("adventure in Small-O-Fier, find non-combat, dig your way to safety");
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
        }
        else if ($item[can-you-dig-it?].available_amount() > 0 && $effect[smooth legs].have_effect() > 0)
        {
            //5
            subentry.entries.listAppend("Gaze into the mirror.");
            subentry.entries.listAppend("Before you do, though, possibly look for/copy smooth jazz scabie factoids in the Small-O-Fier.");
        }
        else if ($effect[smooth legs].have_effect() > 0)
        {
            //4
            if ($effect[literally insane].have_effect() > 0 && $effect[broken dancing].have_effect() > 0 && $item[crazyleg's razor].available_amount() > 0)
                subentry.entries.listAppend("Use Crazyleg's razor repeatedly to extend smooth legs effect.");

            subentry.modifiers.listAppend("-combat");
            subentry.modifiers.listAppend("+item");
            subentry.entries.listAppend("Adventure in Small-O-Fier, find ocean non-combat, fight a smooth jazz scabie for can-you-dig-it?");
            
        }
        else if ($effect[literally insane].have_effect() > 0 && $effect[broken dancing].have_effect() > 0 && $item[crazyleg's razor].available_amount() > 0)
        {
            //3
            subentry.entries.listAppend("Use Crazyleg's razor. (repeatedly)");
        }
        else if ($effect[literally insane].have_effect() + $item[world's most unappetizing beverage].available_amount() > 0 && $effect[broken dancing].have_effect() + $item[squirmy violent party snack].available_amount() > 0 && $item[crazyleg's razor].available_amount() > 0)
        {
            string [int] tasks;
            boolean waiting = false;
            if ($effect[literally insane].have_effect() == 0)
            {
                if (availableDrunkenness() < 1)
                {
                    waiting = true;
                    tasks.listAppend("wait until you have 1 drunkenness available");
                }
                else
                    tasks.listAppend("drink the world's most unappetizing beverage");
            }
            if ($effect[broken dancing].have_effect() == 0)
            {
                if (availableFullness() < 1)
                {
                    tasks.listAppend("wait until you have 1 fullness available");
                    waiting = true;
                }
                else if (!waiting)
                    tasks.listAppend("eat a squirmy violent party snack");
            }
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        }
        else
        {
            boolean need_nc = false;
            //Need:
            //crazyleg's razor
            //literally insane / world's most unappetizing beverage / (hair of the calf and can of depilatory cream)
            //broken dancing / squirmy violent party snack / (a dance upon the palate/tiny frozen prehistoric meteorite jawbreaker)
            if ($item[crazyleg's razor].available_amount() == 0)
            {
                subentry.entries.listAppend("Acquire crazyleg's razor.|*Adventure in the Huge-A-Ma-Tron, defeat the Fearsome Wacken.");
            }
            if ($effect[literally insane].have_effect() + $item[world's most unappetizing beverage].available_amount() > 0)
            {
                //nothing, have them
            }
            else if ($item[world's most unappetizing beverage].creatable_amount() > 0)
            {
                subentry.entries.listAppend("Create the world's most unappetizing beverage.");
            }
            else
            {
                //parts:
                if ($item[hair of the calf].available_amount() == 0)
                {
                    need_nc = true;
                    subentry.entries.listAppend("Acquire hair of the calf.|*Adventure in Small-O-Fier, climb up a hair.");
                }
                if ($item[can of depilatory cream].available_amount() == 0)
                {
                    need_nc = true;
                    subentry.entries.listAppend("Acquire can of depilatory cream.|*Adventure in Small-O-Fier, find non-combat.");
                }
            }
            
            if ($effect[broken dancing].have_effect() + $item[squirmy violent party snack].available_amount() > 0)
            {
                //nothing, have them
            }
            else if ($item[squirmy violent party snack].creatable_amount() > 0)
            {
                subentry.entries.listAppend("Create a squirmy violent party snack.");
            }
            else
            {
                //parts:
                if ($item[a dance upon the palate].available_amount() == 0)
                {
                    subentry.entries.listAppend("Acquire a dance upon the palate.|*Adventure in Huge-A-Ma-Tron, crouch down and lick the world.");
                }
                if ($item[tiny frozen prehistoric meteorite jawbreaker].available_amount() == 0)
                {
                    string [int] meteorite_details;
                    
                    boolean [item] relevant_fruits = $items[blackberry, cherry, olive, plum, sea blueberry, strawberry]; //cheap ones, not all of them
                    item chosen_fruit = $item[blackberry];
                    foreach it in relevant_fruits
                    {
                        if (it.available_amount() > 0)
                        {
                            chosen_fruit = it;
                            break;
                        }
                    }
                    
                    if (chosen_fruit.available_amount() == 0)
                        meteorite_details.listAppend("Acquire a " + chosen_fruit + ".");
                    meteorite_details.listAppend("Put a " + chosen_fruit + " in the fruit machine if you haven't.");
                    if ($effect[hurricane force].have_effect() == 0)
                    {
                        need_nc = true;
                        meteorite_details.listAppend("Adventure in the Huge-A-Ma-Tron, dance on top of the world.");
                    }
                    else
                    {
                        meteorite_details.listAppend("Adventure in the Huge-A-Ma-Tron, defeat a loose coalition of yetis, snowmen, and goats.");
                    }
                    subentry.entries.listAppend("Acquire a tiny frozen prehistoric meteorite jawbreaker.|*" + meteorite_details.listJoinComponents("|*"));
                    
                    
                }
            }
            
            if (need_nc)
                subentry.modifiers.listAppend("-combat");
        }
    }
    
	task_entries.listAppend(ChecklistEntryMake(92, base_quest_state.image_name, "", subentry, $locations[professor jacking's small-o-fier, professor jacking's huge-a-ma-tron]));
}
