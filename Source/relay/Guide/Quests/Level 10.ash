
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
    if (state.mafia_internal_step > 1)
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
        //FIXME delay if ballroom song not set
        image_name = "penultimate fantasy airship";
        if (!base_quest_state.state_boolean["Beanstalk grown"])
        {
            if ($item[enchanted bean].available_amount() == 0)
            {
                subentry.entries.listAppend("Acquire enchanted bean from a beanbat.");
                subentry.modifiers.listAppend("+100% item");
                url = $location[the beanbat chamber].getClickableURLForLocation();
            }
            else
            {
                subentry.entries.listAppend("Grow the beanstalk.");
                url = "place.php?whichplace=plains";
            }
        }
        else
        {
            int turns_spent = $location[the penultimate fantasy airship].turns_spent;
            int turns_delay = -1;
            
            boolean need_minus_combat = true;
            if (turns_spent == -1)
                need_minus_combat = true;
            else if (turns_spent < 5)
            {
                need_minus_combat = false;
                turns_delay = 5 - turns_spent;
            }
            else if (turns_spent < 10 && $item[Tissue Paper Immateria].available_amount() > 0)
            {
                need_minus_combat = false;
                turns_delay = 10 - turns_spent;
            }
            else if (turns_spent < 15 && $item[Tin Foil Immateria].available_amount() > 0)
            {
                need_minus_combat = false;
                turns_delay = 15 - turns_spent;
            }
            else if (turns_spent < 20 && $item[Gauze Immateria].available_amount() > 0)
            {
                need_minus_combat = false;
                turns_delay = 20 - turns_spent;
            }
            else if (turns_spent < 25 && $item[Plastic Wrap Immateria].available_amount() > 0)
            {
                need_minus_combat = false;
                turns_delay = 25 - turns_spent;
            }
            
            //boolean need_minus_combat_only_for_model_airship = false;
            if ($item[model airship].available_amount() == 0 && turns_spent >= 5)
            {
                //if (!need_minus_combat)
                    //need_minus_combat_only_for_model_airship = true;
                need_minus_combat = true;
            }
            
            
            if (need_minus_combat)
                subentry.modifiers.listAppend("-combat");
            else
                subentry.modifiers.listAppend("possibly +combat");
            
            if (__misc_state["free runs available"])
                subentry.modifiers.listAppend("free runs");
            if (turns_spent < 25)
            {
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
            }
            
            string [int] things_we_want_item_for;
            
            if ($skill[Transcendent Olfaction].have_skill())
                things_we_want_item_for.listAppend("SGEEA");
            
            
            //immateria:
            
            item [int] immaterias_missing = $items[Tissue Paper Immateria,Tin Foil Immateria,Gauze Immateria,Plastic Wrap Immateria].items_missing();
            
            if (turns_delay != -1 && !need_minus_combat)
            {
                //subentry.entries.listAppend(pluralizeWordy(turns_delay, "turn", "turns").capitalizeFirstLetter() + " delay until -combat relevant.");
                string line = "After " + pluralizeWordy(turns_delay, "turn", "turns") + " delay, ";
                if (immaterias_missing.count() == 0)
                    subentry.entries.listAppend(line + "find Cid.");
                else
                    subentry.entries.listAppend(line + "find " + immaterias_missing.count().int_to_wordy() + " more immateria.");
                    //subentry.entries.listAppend(line + "find the immateria: " + listJoinComponents(immaterias_missing, ", ", "and"));
            }
            else
            {
                if (immaterias_missing.count() == 0)
                    subentry.entries.listAppend("Find Cid. (-combat)");
                else
                {
                    subentry.entries.listAppend("Find " + immaterias_missing.count().int_to_wordy() + " more immateria. (-combat)");
                    //subentry.entries.listAppend("Find the immateria (-combat): " + listJoinComponents(immaterias_missing, ", ", "and"));
                }
            }
            
            
            //FIXME it would be nice to track this
            if (turns_spent == -1)
                subentry.entries.listAppend("25 total turns of delay.");
            else if (turns_spent < 25)
                subentry.entries.listAppend(pluralize(25 - turns_spent, "turn", "turns") + " total delay remaining.");
            if ($skill[Transcendent Olfaction].have_skill() && !($effect[on the trail].have_effect() > 0 && get_property("olfactedMonster") == "Quiet Healer"))
                subentry.entries.listAppend("Potentially olfact quiet healer for SGEEAs");
            
            if ($items[amulet of extreme plot significance,mohawk wig].items_missing().count() > 0 && $familiar[slimeling].familiar_is_usable())
                subentry.modifiers.listAppend("slimeling?");
            
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
            {
                subentry.modifiers.listAppend("+item");
                subentry.entries.listAppend("Potentially run +item for " + listJoinComponents(things_we_want_item_for, ", ", "and") + ".");
            }
        }
	}
	else
	{
        url = "place.php?whichplace=giantcastle";
        if (get_property("lastEncounter") == "Keep On Turnin' the Wheel in the Sky")
        {
            url = "town.php";
            subentry.entries.listAppend("Talk to the council to finish quest.");
        }
		else if ($location[The Castle in the Clouds in the Sky (Top floor)].locationAvailable())
		{
            float turn_estimation = -1.0;
            float non_combat_rate = 1.0 - (0.95 + combat_rate_modifier() / 100.0);
            if (non_combat_rate < 0.11111111111111) //every nine adventures, minimum
                non_combat_rate = 0.11111111111111;
            
            //FIXME turn estimation for all routes, not just mohawk wig/model airship
            
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Top floor. Run -combat.");
            if ($item[mohawk wig].equipped_amount() == 0 && $item[mohawk wig].available_amount() > 0)
                subentry.entries.listAppend(HTMLGenerateSpanFont("Wear your mohawk wig.", "red", ""));
            if ($item[mohawk wig].available_amount() == 0 && !in_hardcore())
                subentry.entries.listAppend("Potentially pull and wear a mohawk wig.");
            if ($item[model airship].available_amount() == 0)
            {
                if ($item[mohawk wig].available_amount() == 0) //no wig, no airship
                    subentry.entries.listAppend("Backfarm for a model airship in the fantasy airship. (non-combat option, run -combat)");
                else
                    subentry.entries.listAppend("Potentially backfarm for a model airship in the fantasy airship. (non-combat option, run -combat)"); //always suggest this - backfarming for model airship is faster than spending time in top floor, I think
            }
            
            if ($item[mohawk wig].available_amount() > 0 && $item[model airship].available_amount() > 0)
            {
                if (non_combat_rate != 0.0)
                    turn_estimation = 1.0 / non_combat_rate;
            }
            
            //We don't suggest trying to complete this quest with the record, even if they lack the mohawk wig/model airship - I feel as though that would take quite a number of turns?
            //It's a 95% combat location (max nine/ten turns between non-combats), and the non-combats are split between two different sets.
            //There might be some internal mechanics to make it faster? Don't know.
			image_name = "goggles? yes!";
            
            if (turn_estimation != -1.0)
                subentry.entries.listAppend("~" + turn_estimation.roundForOutput(1) + " turns left on average.");
            
            if (CounterLookup("Semi-rare").CounterWillHitExactlyInTurnRange(1,1))
            {
                subentry.modifiers.listClear();
                subentry.entries.listClear();
                subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid adventuring here; wheel will override semi-rare.", "red", ""));
            }
		}
		else if ($location[The Castle in the Clouds in the Sky (Ground floor)].locationAvailable())
		{
            int turns_spent = $location[The Castle in the Clouds in the Sky (Ground floor)].turns_spent;
            int turns_remaining = 11;
            if (turns_spent != -1)
            {
                turns_remaining = 11 - turns_spent;
                if (turns_remaining == 1)
                    subentry.entries.listAppend("Ground floor. Spend One More Turn here to unlock top floor.");
                else
                    subentry.entries.listAppend("Ground floor. Spend " + pluralizeWordy(turns_remaining, "more turn", "more turns") + " here to unlock top floor.");
            }
            else
                subentry.entries.listAppend("Ground floor. Spend eleven turns here to unlock top floor.");
            
			image_name = "castle stairs up";
            
            if (__misc_state["Need to level"])
                subentry.entries.listAppend("Possibly acquire the very overdue library book from a non-combat. (stats)");
            
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
            
            float turn_estimation = -1.0;
            float non_combat_rate = 1.0 - (0.95 + combat_rate_modifier() / 100.0);
            if (non_combat_rate < 0.11111111111111) //every nine adventures, minimum
                non_combat_rate = 0.11111111111111;
            if ($item[amulet of extreme plot significance].available_amount() > 0)
            {
                if ($item[amulet of extreme plot significance].equipped_amount() == 0)
                    subentry.entries.listAppend("Possibly " + HTMLGenerateSpanFont("wear the amulet of extreme plot significance.", "red", "") + "|Or search for the non-combat, skip it, equip the amulet, and adventure again.");
                
                if (non_combat_rate != 0.0)
                    turn_estimation = 1.0 / non_combat_rate;
                
                    
            }
            else
            {
                boolean have_usable_umbrella = (__misc_state["can equip just about any weapon"] && $item[titanium assault umbrella].available_amount() > 0);
                
                if (have_usable_umbrella && $item[titanium assault umbrella].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip your titanium assault umbrella.");
                if ($item[massive dumbbell].available_amount() == 0)
                {
                    if (have_usable_umbrella)
                    {
                        subentry.entries.listAppend("Grab the massive dumbbell from gym if you can't reach the ground floor otherwise.");
                        
                        if (non_combat_rate != 0.0)
                            turn_estimation = (2.0 / 3.0) * (2.0 / non_combat_rate) + (1.0 / 3.0) * (1.0 / non_combat_rate); //1/3rd chance of instant completion with umbrella
                    }
                    else
                    {
                        subentry.entries.listAppend("Grab the massive dumbbell from gym.");
                        if (non_combat_rate != 0.0)
                            turn_estimation = 2.0 / non_combat_rate;
                    }
                    
                }
                else
                {
                    subentry.entries.listAppend("Place the massive dumbbell in the Open Source dumbwaiter.");
                    if (non_combat_rate != 0.0)
                        turn_estimation = 1.0 / non_combat_rate;
                }
            }
            
            if (turn_estimation != -1.0)
                subentry.entries.listAppend("~" + turn_estimation.roundForOutput(1) + " turns left on average.");
			
			image_name = "lift, bro";
		}
	}
	
	task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the penultimate fantasy airship, the castle in the clouds in the sky (basement), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (top floor)]));
}