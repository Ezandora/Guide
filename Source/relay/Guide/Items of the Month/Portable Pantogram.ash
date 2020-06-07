
RegisterTaskGenerationFunction("IOTMPortablePantogramGenerateTasks");
void IOTMPortablePantogramGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__iotms_usable[lookupItem("portable pantogram")]) return;
	if (lookupItem("pantogram pants").available_amount() > 0) return;
	
    if (myPathId() == PATH_BEES_HATE_YOU) return;
	string [int] description;
	
	
	string [int][int] slot_options;
	for i from 1 to 5
		slot_options[i] = listMakeBlankString();
    
    //Slot 1: muscle, myst, moxie. Tower stat test, then muscle.
    if (__misc_state["in run"] && !__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "")
    	slot_options[1].listAppend(__quest_state["Level 13"].state_string["Stat race type"]);
    else if (__misc_state["in run"])
    	slot_options[1].listAppend("muscle");
	//Slot 2: Resistance. Cold? Spooky?
	if (__misc_state["in run"])
	{
		if (myPathId() == PATH_COMMUNITY_SERVICE)
            slot_options[2].listAppend("hot resistance");
        else if (!__quest_state["Level 9"].state_boolean["bridge complete"])
            slot_options[2].listAppend("sleaze resistance"); //bridge building
        else
	    	slot_options[2].listAppend("spooky resistance"); //a-boo peak, and slightly more useful than cold resistance
    }
	//Slot 3: drops of blood (+40 HP). -3 MP to use skills is nice, I guess? but it takes a baconstone
	if (__misc_state["in run"])
		slot_options[3].listAppend("drops of blood (+40 HP)");
	if ($item[baconstone].available_amount() > 0 && __misc_state["in run"])
		slot_options[3].listAppend("baconstone (-3 MP to use skills)");
	//Slot 4:
	if ($item[taco shell].npc_price() > 0)
		slot_options[4].listAppend("taco shell (+30% meat)");
    if (($item[porquoise].npc_price() > 0 && __misc_state["in run"]) || can_interact())
        slot_options[4].listAppend("porquoise (+60% meat)");
    if (myPathId() == PATH_COMMUNITY_SERVICE)
    {
        slot_options[4].listAppend("your hopes (+20 weapon damage)");
        slot_options[4].listAppend("your dreams (+20% spell damage)");
    }
	if (__misc_state["in run"])
	{
	}
	else
	{
        slot_options[4].listAppend("tiny dancer (+30% item)");
	}
	//slot_options[4].listAppend("???");
	//Slot 5:
    slot_options[5].listAppend("some self-respect (-combat)");
    if (myPathId() != PATH_COMMUNITY_SERVICE)
    	slot_options[5].listAppend("some self-control (+combat)");
    if (!__misc_state["in run"])
    	slot_options[5].listAppend("ten-leaf clover (hilarious items)");
    if ($item[bar skin].available_amount() > 0 && __misc_state["in run"])
    	slot_options[5].listAppend("bar skin (+50% init)");
	
	foreach slot_id in slot_options
	{
		if (slot_options[slot_id].count() == 0) continue;
		description.listAppend(slot_options[slot_id].listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
	}
    optional_task_entries.listAppend(ChecklistEntryMake("__item portable pantogram", "inv_use.php?pwd=" + my_hash() + "&whichitem=9573", ChecklistSubentryMake("Summon pants", "", description), 1));
}
