
void QLevel10Init()
{
	//questL10Garbage
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL10Garbage");
	state.quest_name = "Castle Quest";
	state.image_name = "castle";
	state.council_quest = true;
    
    
    boolean beanstalk_grown = false;
    if ($items[Model airship,Plastic Wrap Immateria,Gauze Immateria,Tin Foil Immateria,Tissue Paper Immateria,S.O.C.K.].available_amount() > 0)
        beanstalk_grown = true;
    if (state.finished)
        beanstalk_grown = true;
    if ($location[the penultimate fantasy airship].turnsAttemptedInLocation() > 0)
        beanstalk_grown = true;
    
    state.state_boolean["Beanstalk grown"] = beanstalk_grown;
	
	
	if (my_level() >= 10)
		state.startable = true;
    
	__quest_state["Level 10"] = state;
	__quest_state["Castle"] = state;
}


void QLevel10GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 10"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 10"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	string image_name = base_quest_state.image_name;
    string url = "place.php?whichplace=beanstalk";
	
	if ($item[s.o.c.k.].available_amount() == 0)
	{
        if (!base_quest_state.state_boolean["Beanstalk grown"])
            subentry.entries.listAppend("Grow the beanstalk.");
		//FIXME check if enchanted bean used
		subentry.modifiers.listAppend("-combat");
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
		subentry.modifiers.listAppend("+item");
		
		string [int] things_we_want_item_for;
		things_we_want_item_for.listAppend("SGEEA");
		
		image_name = "__half penultimate fantasy airship";
		
		//immateria:
		
		item [int] immaterias_missing = $items[Tissue Paper Immateria,Tin Foil Immateria,Gauze Immateria,Plastic Wrap Immateria].items_missing();
		if (immaterias_missing.count() == 0)
			subentry.entries.listAppend("Immateria found, find Cid (-combat)");
		else
		{
			subentry.entries.listAppend("Find the immateria (-combat): " + listJoinComponents(immaterias_missing, ", ", "and"));
		}
		
		
        //FIXME it would be nice to track this
		subentry.entries.listAppend("20 total turns of delay.");
		if (__misc_state["have olfaction equivalent"] && !($effect[on the trail].have_effect() > 0 && get_property("olfactedMonster") == "Quiet Healer"))
			subentry.entries.listAppend("Potentially olfact quiet healer for SGEEAs");
		
		if ($item[model airship].available_amount() == 0)
			subentry.entries.listAppend("Acquire model airship from non-combat. (speeds up quest)");
		if ($item[amulet of extreme plot significance].available_amount() == 0)
		{
			things_we_want_item_for.listAppend("amulet of extreme plot significance");
			subentry.entries.listAppend("Acquire amulet of extreme plot significance (quiet healer, 10% drop) to speed up opening ground floor.");
		}
		if ($item[mohawk wig].available_amount() == 0)
		{
			things_we_want_item_for.listAppend("Mohawk wig");
			subentry.entries.listAppend("Acquire mohawk wig (Burly Sidekick, 10% drop) to speed up top floor.");
		}
        if (things_we_want_item_for.count() > 0)
            subentry.entries.listAppend("Potentially run +item for " + listJoinComponents(things_we_want_item_for, ", ", "and") + ".");
	}
	else
	{
        url = "place.php?whichplace=giantcastle";
		if ($location[The Castle in the Clouds in the Sky (Top floor)].locationAvailable())
		{
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Top floor. Run -combat.");
            if ($item[mohawk wig].equipped_amount() == 0 && $item[mohawk wig].available_amount() > 0)
                subentry.entries.listAppend("Wear your mohawk wig.");
            if ($item[model airship].available_amount() == 0)
            {
                if ($item[mohawk wig].available_amount() == 0) //no wig, no airship
                    subentry.entries.listAppend("Backfarm for a model airship in the fantasy airship. (non-combat option, run -combat)");
                else
                    subentry.entries.listAppend("Potentially backfarm for a model airship in the fantasy airship. (non-combat option, run -combat)"); //always suggest this - backfarming for model airship is faster than spending time in top floor, I think
            }
            
            //We don't suggest trying to complete this quest with the record, even if they lack the mohawk wig/model airship - I feel as though that would take quite a number of turns?
            //It's a 95% combat location (max nine/ten turns between non-combats), and the non-combats are split between two different sets.
            //There might be some internal mechanics to make it faster? Don't know.
			image_name = "goggles? yes!";
		}
		else if ($location[The Castle in the Clouds in the Sky (Ground floor)].locationAvailable())
		{
			subentry.entries.listAppend("Ground floor. Spend eleven turns here to unlock top floor.");
			image_name = "castle stairs up";
            
            
            if (true)
            {
                if (__misc_state["have hipster"])
                {
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                }
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
		}
		else
		{
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Basement. Run -combat.");
            if ($item[amulet of extreme plot significance].available_amount() > 0)
            {
                if ($item[amulet of extreme plot significance].equipped_amount() == 0)
                    subentry.entries.listAppend("Wear the amulet of extreme plot significance.");
                    
            }
            else
            {
                if (__misc_state["can equip just about any weapon"] && $item[titanium assault umbrella].available_amount() > 0 && $item[titanium assault umbrella].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip your titanium assault umbrella.");
                if ($item[massive dumbbell].available_amount() == 0)
                {
                    if ($item[titanium assault umbrella].available_amount() > 0)
                        subentry.entries.listAppend("Grab the massive dumbbell from gym if you can't reach the ground floor otherwise.");
                    else
                        subentry.entries.listAppend("Grab the massive dumbbell from gym.");
                }
                else
                    subentry.entries.listAppend("Place the massive dumbbell in the Open Source dumbwaiter.");
            }
			
			image_name = "lift, bro";
		}
	}
	
	task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the penultimate fantasy airship, the castle in the clouds in the sky (basement), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (top floor)]));
}