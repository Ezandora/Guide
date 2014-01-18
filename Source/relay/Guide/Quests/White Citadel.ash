
void QWhiteCitadelInit()
{
    if (!__misc_state["In aftercore"]) //not yet
        return;
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questG02Whitecastle");
    
    //sorry, no way to query for familiar name
    state.quest_name = my_name().HTMLEscapeString() + " and Kumar Go To White Citadel";
    state.image_name = "__item White Citadel burger";
    
    
    __quest_state["White Citadel"] = state;
}

void QWhiteCitadelGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["White Citadel"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "woods.php";
    
    if (base_quest_state.mafia_internal_step == 1)
    {
        //1	You've been charged by your Guild (sort of) with the task of bringing back a delicious meal from the legendary White Citadel. You've been told it's somewhere near Whitey's Grove, in the Distant Woods.
        //Unlock the road to white citadel:
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Adventure in Whitey's Grove, unlock the road to White Citadel.");
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        //2	You've discovered the road from Whitey's Grove to the legendary White Citadel. You should explore it and see if you can find your way.
        //Find the cheetah:
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        subentry.entries.listAppend("Find a cheetah. (non-combat)");
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        //3	You're progressing down the road towards the White Citadel, but you'll need to find something that can help you get past that stupid cheetah if you're going to make it any further. Keep looking around.
        //Find "catnip" (100% drop), then find cheetah again:
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        if ($item[massive bag of catnip].available_amount() == 0)
        {
            subentry.modifiers.listAppend("+combat");
            subentry.entries.listAppend("Find a massive bag of catnip from a business hippy.");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Find a cheetah. (non-combat)");
        }
    }
    else if (base_quest_state.mafia_internal_step == 4)
    {
        //4	You've made your way further down the Road to the White Citadel, but you still haven't found it. Keep looking!
        //Find cliff:
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        subentry.entries.listAppend("Find a cliff. (non-combat)");
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //5	You've found the White Citadel, but it's at the bottom of a huge cliff. You should keep messing around on the Road until you find a way to get down the cliff.
        //Find hang glider (100% drop), then find NC again:
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        if ($item[hang glider].available_amount() == 0)
        {
            subentry.modifiers.listAppend("+combat");
            subentry.entries.listAppend("Find a hang glider from eXtreme sport orcs.");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Find a cliff. (non-combat)");
        }
    }
    else if (base_quest_state.mafia_internal_step == 6 && $item[White Citadel Satisfaction Satchel].available_amount() == 0)
    {
        //6	You have discovered the legendary White Citadel. You should probably go in there and get the carryout order you were trying to get in the first place. Funny how things spiral out of control, isn't it?
        //Visit the white citadel:
        subentry.entries.listAppend("Visit the White Citadel.");
    }
    else if (base_quest_state.mafia_internal_step == 7 || $item[White Citadel Satisfaction Satchel].available_amount() > 0)
    {
        //7	You've got the Satisfaction Satchel. Take it to your contact in your Guild for a reward.
        //Visit guild:
        subentry.entries.listAppend("Visit your friend at the guild.");
        active_url = "guild.php";
    }
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[whitey's grove, the road to white citadel]));
}