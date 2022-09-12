
void QLevel9Init()
{
	//questL09Topping
	//oilPeakProgress
	//twinPeakProgress
	//booPeakProgress
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL09Topping");
    if (my_path_id_legacy() == PATH_COMMUNITY_SERVICE) QuestStateParseMafiaQuestPropertyValue(state, "finished");
	state.quest_name = "Highland Lord Quest";
	state.image_name = "orc chasm";
	state.council_quest = true;
	
    //Recorded in-run:
    //twinPeakProgress(user, now '1', default 0) - +stench one done
    //twinPeakProgress(user, now '3', default 0) - +stench, +item ones done
    //twinPeakProgress(user, now '7', default 0) - +stench, +item, jar ones done
    //twinPeakProgress(user, now '15', default 0) - finished
	//twinPeakProgress(user, now '3', default 0) -> item done, stench done, jar not done, init not done, quest started
	
	if (state.mafia_internal_step > 1)
	{
		state.state_boolean["bridge complete"] = true;
	}
	else
	{
		int bridge_progress = get_property_int("chasmBridgeProgress");
		int fasteners_have = bridge_progress + $item[thick caulk].available_amount() + $item[long hard screw].available_amount() + $item[messy butt joint].available_amount() + 5 * $item[smut orc keepsake box].usable_amount() + 5 * $item[snow boards].usable_amount();
		int lumber_have = bridge_progress + $item[morningwood plank].available_amount() + $item[raging hardwood plank].available_amount() + $item[weirdwood plank].available_amount() + 5 * $item[smut orc keepsake box].usable_amount() + 5 * $item[snow boards].usable_amount();
        if (my_path_id_legacy() == PATH_LICENSE_TO_ADVENTURE && get_property_boolean("bondBridge"))
        {
            fasteners_have += 15;
            lumber_have += 15;
        }
		
		int fasteners_needed = MAX(0, 30 - fasteners_have);
		int lumber_needed = MAX(0, 30 - lumber_have);
		
		state.state_int["bridge fasteners needed"] = fasteners_needed;
		state.state_int["bridge lumber needed"] = lumber_needed;
	}
	
	if (my_level() >= 9 || my_path_id_legacy() == PATH_EXPLOSIONS)
		state.startable = true;
		
	
	state.state_boolean["can complete twin peaks quest quickly"] = true;
	
	if (my_path_id_legacy() == PATH_BEES_HATE_YOU)
		state.state_boolean["can complete twin peaks quest quickly"] = false;
	
	state.state_float["oil peak pressure"] = get_property_float("oilPeakProgress");
	if ($location[oil peak].noncombat_queue.contains_text("Unimpressed with Pressure"))
        state.state_float["oil peak pressure"] = 0.0;
	state.state_int["twin peak progress"] = get_property_int("twinPeakProgress");
	state.state_int["a-boo peak hauntedness"] = get_property_int("booPeakProgress");
    if ($location[a-boo peak].noncombat_queue.contains_text("Come On Ghosty, Light My Pyre"))
        state.state_int["a-boo peak hauntedness"] = 0;
    
	
	if (!state.state_boolean["bridge complete"]) //haven't gotten over there yet. not sure what mafia says at this point, so set some defaults:
	{
		state.state_int["twin peak progress"] = 0;
		state.state_float["oil peak pressure"] = 310.66;
		state.state_int["a-boo peak hauntedness"] = 100;
	}
	if (state.finished)
	{
		state.state_boolean["bridge complete"] = true;
		
		state.state_int["twin peak progress"] = 15;
		state.state_float["oil peak pressure"] = 0.0;
		state.state_int["a-boo peak hauntedness"] = 0;
	}
    
    if (state.state_float["oil peak pressure"] > 500.0) //not sure what causes this. detecting this situation
    {
        state.state_float["oil peak pressure"] = 310.66;
        state.state_boolean["oil peak pressure bug in effect"] = true;
    }
    
    
    int twin_progress = state.state_int["twin peak progress"];
    
    state.state_boolean["Peak Stench Completed"] = (twin_progress & 1) > 0;
    state.state_boolean["Peak Item Completed"] = (twin_progress & 2) > 0;
    state.state_boolean["Peak Jar Completed"] = (twin_progress & 4) > 0;
    state.state_boolean["Peak Init Completed"] = (twin_progress & 8) > 0;
    
    state.state_int["peak tests remaining"] = 0;
    foreach s in $strings[Peak Stench Completed,Peak Item Completed,Peak Jar Completed,Peak Init Completed]
    {
        if (!state.state_boolean[s])
            state.state_int["peak tests remaining"] += 1;
    }
    
	__quest_state["Level 9"] = state;
	__quest_state["Highland Lord"] = state;
}

void QLevel9GenerateTasksSidequests(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Level 9"];
    
	if (base_quest_state.state_int["a-boo peak hauntedness"] > 0)
	{
        boolean should_delay = false;
		string [int] details;
		string [int] modifiers;
        int clues_needed = ceil(MIN(base_quest_state.state_int["a-boo peak hauntedness"], 90).to_float() / 30.0);
        
        if (true)
        {
            int clues_remaining = MAX(0, clues_needed - $item[a-boo clue].available_amount());
            string [int] tasks;
            if (base_quest_state.state_int["a-boo peak hauntedness"] > 90)
                tasks.listAppend("get down to 90% hauntedness");
            if (clues_remaining > 0)
                tasks.listAppend("collect " + clues_remaining.int_to_wordy() + " a-boo clues");
            tasks.listAppend("use/survive each clue to finish quest.|May want to consider delaying until end of the run");
            details.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
        }
        
		modifiers.listAppend("+567% item");
		details.listAppend(base_quest_state.state_int["a-boo peak hauntedness"] + "% hauntedness.");
        
        float item_drop_multiplier = (100.0 + $location[a-boo peak].item_drop_modifier_for_location())/100.0;
        
        if (true)
        {
            string line = "Have " + pluralise($items[a-boo clue,glued a-boo clue].available_amount(), $item[a-boo clue]) + ".";
            
            float clue_drop_rate = clampf(item_drop_multiplier * 0.15, 0.0, 1.0);
            line += " " + clue_drop_rate.roundForOutput(2) + " clues/adventure at +" + ((item_drop_multiplier - 1) * 100.0).roundForOutput(1) + "% item.";
            
            details.listAppend(line);
        }
        
        
		if (base_quest_state.state_int["a-boo peak hauntedness"] <= 90 && __misc_state["can use clovers"] && $item[a-boo clue].available_amount() < clues_needed)
        {
            details.listAppend("Can clover for two A-Boo clues.");
        }
        
		
		
        
        int spooky_damage_taken_cumulative = 0;
        int cold_damage_taken_cumulative = 0;
        
        int [int] spooky_damage_levels;
        int [int] cold_damage_levels;
        
        int [int] damage_levels = listMake(13, 25, 50, 125, 250);
        
        foreach key in damage_levels
        {
            int damage = damage_levels[key];
            if ($item[glass pie plate].equipped_amount() > 0)
                damage /= 2;
            
            int spooky_damage_at_level = damageTakenByElement(damage, $element[spooky]);
            int cold_damage_at_level = damageTakenByElement(damage, $element[cold]);
            
            spooky_damage_taken_cumulative += spooky_damage_at_level;
            cold_damage_taken_cumulative += cold_damage_at_level;
            
            spooky_damage_levels.listAppend(spooky_damage_taken_cumulative);
            cold_damage_levels.listAppend(cold_damage_taken_cumulative);
        }
        
        boolean can_survive_clues_now = false;
        if (true)
        {
            string line;
        
            int hp_damage_taken = spooky_damage_levels[4] + cold_damage_levels[4] + 2;
            string hp_string = hp_damage_taken + " HP";
            if (hp_damage_taken >= my_hp())
                hp_string = HTMLGenerateSpanFont(hp_string, "red");
            
            if (hp_damage_taken <= my_maxhp())
                can_survive_clues_now = true;
            line = "Need " + hp_string + " (" + HTMLGenerateSpanOfClass(spooky_damage_levels[4] + " spooky", "r_element_spooky") + ", " + HTMLGenerateSpanOfClass(cold_damage_levels[4] + " cold", "r_element_cold") + ") to survive 30% effective A-Boo clues.";
            if (hp_damage_taken >= my_hp())
            {
                hp_damage_taken = spooky_damage_levels[3] + cold_damage_levels[3] + 2;
                string hp_string = hp_damage_taken + " HP";
                if (hp_damage_taken >= my_hp())
                    hp_string = HTMLGenerateSpanFont(hp_string, "red");
                
                line += "|Or ";
                line += hp_string;
                line += " to survive 22% effectiveness clues.";
            }
            if ($item[glass pie plate].available_amount() > 0 && $item[glass pie plate].can_equip() && $item[glass pie plate].equipped_amount() == 0)
                line += "|Equip the glass pie plate for half damage.";
            
            details.listAppend(line);
        }
        
        if (!black_market_available() && my_path_id_legacy() != PATH_WAY_OF_THE_SURPRISING_FIST && my_path_id_legacy() != PATH_NUCLEAR_AUTUMN)
        {
            details.listAppend("Possibly unlock the black market first, for cans of black paint. (+2 " + HTMLGenerateSpanOfClass("spooky", "r_element_spooky") + "/" + HTMLGenerateSpanOfClass("cold", "r_element_cold") + " res buff, 1k meat)");
        }
        if ($item[a-boo clue].available_amount() * 30 >= base_quest_state.state_int["a-boo peak hauntedness"] && my_level() < 13) //wait for later
            should_delay = true;
        if (can_survive_clues_now)
            should_delay = false;
        
        ChecklistEntry checklist_entry = ChecklistEntryMake(65, "a-boo peak", "place.php?whichplace=highlands", ChecklistSubentryMake("A-Boo Peak", modifiers, details), $locations[a-boo peak]);
		if (should_delay)
        {
            checklist_entry.importance_level = 11;
            future_task_entries.listAppend(checklist_entry);
        }
        else
            task_entries.listAppend(checklist_entry);
	}
    else if (!$location[a-boo peak].noncombat_queue.contains_text("Come On Ghosty, Light My Pyre"))
    {
		string [int] details;
		string [int] modifiers;
        
        details.listAppend("Light the fire!");
        
        ChecklistEntry checklist_entry = ChecklistEntryMake(66, "a-boo peak", "place.php?whichplace=highlands", ChecklistSubentryMake("A-Boo Peak", modifiers, details), $locations[a-boo peak]);
        task_entries.listAppend(checklist_entry);
    }
	if (base_quest_state.state_int["twin peak progress"] < 15)
	{
		string [int] details;
		string [int] modifiers;
        string url = "place.php?whichplace=highlands";
		
		if (base_quest_state.state_boolean["can complete twin peaks quest quickly"])
		{
            int progress = base_quest_state.state_int["twin peak progress"];
            
            boolean stench_completed = base_quest_state.state_boolean["Peak Stench Completed"];
            boolean item_completed = base_quest_state.state_boolean["Peak Item Completed"];
            boolean jar_completed = base_quest_state.state_boolean["Peak Jar Completed"];
            boolean init_completed = base_quest_state.state_boolean["Peak Init Completed"];
            
            boolean can_complete_stench = false;
            boolean can_complete_item = false;
            boolean can_complete_jar = false;
            boolean can_complete_init = false;
            
            boolean have_at_least_one_usable_option = false;
            
            
            if (!stench_completed && numeric_modifier("stench resistance") >= 4.0)
                can_complete_stench = true;
            if (!item_completed)
            {
                int effective_familiar_weight = my_familiar().familiar_weight() + numeric_modifier("familiar weight");
                
                int familiar_weight_from_familiar_equipment = $slot[familiar].equipped_item().numeric_modifier("familiar weight"); //need to cancel it out
                
                float familiar_item_drop = my_familiar().numeric_modifier("item drop", effective_familiar_weight - familiar_weight_from_familiar_equipment, $slot[familiar].equipped_item());
                //FIXME implement item_drop_modifier_for_location (friars does not count for this test, so maybe item_drop_modifier_ignoring_plants())
                float effective_non_familiar_item = $location[twin peak].item_drop_modifier_for_location() - familiar_item_drop + numeric_modifier("food drop");
                if (effective_non_familiar_item >= 50.0)
                    can_complete_item = true;
            }
            if (!jar_completed && $item[jar of oil].available_amount() > 0)
                can_complete_jar = true;
            if (!init_completed && (stench_completed && item_completed && jar_completed) && initiative_modifier() >= 40)
                can_complete_init = true;
            
            if (can_complete_stench || can_complete_item || can_complete_jar || can_complete_init)
                have_at_least_one_usable_option = true;
            
            if (!have_at_least_one_usable_option)
                details.listAppend(HTMLGenerateSpanFont("Avoid adventuring in area until requirements met.", "red"));
            
            string [int] options_left;
            
            if (!stench_completed)
            {
                string line = "investigate room 37";
                if (options_left.count() == 0)
                    line = line.capitaliseFirstLetter(); //have to pre-capitalise because of possible HTML later
                if (!can_complete_stench)
                    line = HTMLGenerateSpanFont(line, "gray");
                options_left.listAppend(line);
            }
            if (!item_completed)
            {
                string line = "search the pantry";
                if (options_left.count() == 0)
                    line = line.capitaliseFirstLetter();
                if (!can_complete_item)
                    line = HTMLGenerateSpanFont(line, "gray");
                options_left.listAppend(line);
            }
            if (!jar_completed)
            {
                string line = "follow the faint sound of music";
                if (options_left.count() == 0)
                    line = line.capitaliseFirstLetter();
                if (!can_complete_jar)
                    line = HTMLGenerateSpanFont(line, "gray");
                options_left.listAppend(line);
            }
            if (!init_completed)
            {
                string line = "you";
                if (options_left.count() == 0)
                    line = line.capitaliseFirstLetter();
                if (!can_complete_init)
                    line = HTMLGenerateSpanFont(line, "gray");
                options_left.listAppend(line);
            }
            
            details.listAppend(options_left.listJoinComponents(", ", "and") + ".");
            
            boolean can_complete_using_trimmers = false;
            if ($item[rusty hedge trimmers].available_amount() >= options_left.count()) //purely trimmers, now
            {
                can_complete_using_trimmers = true;
                if (have_at_least_one_usable_option)
                    url = "inventory.php?which=3";
            }
			if (numeric_modifier("stench resistance") < 4.0 && !stench_completed)
            {
				details.listAppend("+" + (4.0 - numeric_modifier("stench resistance")).floor() + " more " + HTMLGenerateSpanOfClass("stench", "r_element_stench") + " resist required.");
            }
            if (!can_complete_using_trimmers)
            {
                modifiers.listAppend("-combat");
                modifiers.listAppend("+item");
                modifiers.listAppend("olfact a topiary animal");
            }
				
            if (!item_completed && !can_complete_item)
            {
                details.listAppend("+50% non-familiar item required. (+food works)");
            }
			
			if ($item[jar of oil].available_amount() == 0 && !jar_completed)
            {
                string line = HTMLGenerateSpanFont("Jar of oil required", "red") + ".";
                if ($item[bubblin' crude].available_amount() >= 12)
                    line += " Can make by multi-using 12 bubblin' crude.";
                else
                    line += " Visit oil peak for bubblin' crude.";
				details.listAppend(line);
            }
			if (initiative_modifier() < 40.0 && !init_completed)
            {
                string line = "+40% init required.";
                if (options_left.count() > 1)
                    line = "+40% init will be required later.";
                if ($familiar[oily woim].familiar_is_usable() && !($familiars[oily woim,happy medium] contains my_familiar()))
                {
                    if (!(my_familiar() == $familiar[Xiblaxian Holo-Companion] && my_familiar() != $familiar[none]))
                        line += "|Run " + $familiar[oily woim] + " for +init.";
                }
				details.listAppend(line);
            }
            
			if ($item[rusty hedge trimmers].available_amount() > 0)
            {
                if (!have_at_least_one_usable_option)
                    details.listAppend("Have " + pluraliseWordy(MIN(options_left.count(), $item[rusty hedge trimmers].available_amount()), $item[rusty hedge trimmers]) + ".");
                else if ($item[rusty hedge trimmers].available_amount() > 1)
                    details.listAppend("Use " + pluraliseWordy(MIN(options_left.count(), $item[rusty hedge trimmers].available_amount()), $item[rusty hedge trimmers]) + ".");
                else
                    details.listAppend("Use rusty hedge trimmers.");
            }
            
            int ncs_need_to_visit_by_hand = MAX(0, options_left.count() - $item[rusty hedge trimmers].available_amount());
            int ncs_need_to_visit_with_hedge = options_left.count() - ncs_need_to_visit_by_hand;
            if (have_at_least_one_usable_option && !can_complete_using_trimmers)
                details.listAppend(generateTurnsToSeeNoncombat(80, ncs_need_to_visit_by_hand, "", 0, ncs_need_to_visit_with_hedge));
            
            
		}
		else
		{
			details.listAppend("Spend 50 total turns in the twin peak.");
		}
		task_entries.listAppend(ChecklistEntryMake(67, "twin peak", url, ChecklistSubentryMake("Twin Peak", modifiers, details), $locations[twin peak]));
	}
    boolean need_jar_of_oil = false;
    if ($item[jar of oil].available_amount() == 0 && $item[bubblin' crude].available_amount() < 12 && !base_quest_state.state_boolean["Peak Jar Completed"] && base_quest_state.state_boolean["can complete twin peaks quest quickly"])
        need_jar_of_oil = true;
        
	if (base_quest_state.state_float["oil peak pressure"] > 0.0 || need_jar_of_oil)
	{
		string [int] details;
		string [int] modifiers;
        
        int oil_ml = monster_level_adjustment_for_location($location[oil peak]);
        
        if (my_path_id_legacy() == PATH_HEAVY_RAINS)
        {
            //heavy rains ML doesn't affect which oil monster you get; cancel out the rain effect:
            //int inherent_ml_reduction = monster_level_adjustment() - numeric_modifier("Monster Level");
            //oil_ml -= inherent_ml_reduction;
            //FIXME this is complicated
        }
        
        int turns_remaining_at_current_ml = 0;
        if (base_quest_state.state_float["oil peak pressure"] > 0.0)
        {
            modifiers.listAppend("+100 ML");
            
            
            string line = "Run +" + HTMLGenerateSpanFont("20/50", "", "0.8em") + "/100 ML (at ";
            string adjustment = (oil_ml > 0 ? "+" : "") + oil_ml + " ML";
            if (oil_ml < 100)
                adjustment = HTMLGenerateSpanFont(adjustment, "red");
            adjustment += ")";
            details.listAppend(line + adjustment);
            
            
            float pressure_reduced_per_turn = 0.0;
            if ($item[dress pants].available_amount() > 0)
            {
                if ($item[dress pants].equipped_amount() > 0)
                {
                    pressure_reduced_per_turn += 6.34;
                }
                else
                {
                    if (oil_ml < 100) //only worth it <100 usually
                        details.listAppend("Wear dress pants.");
                }
            }
            if (oil_ml >= 100)
                pressure_reduced_per_turn += 63.4;
            else if (oil_ml >= 50)
                pressure_reduced_per_turn += 31.7;
            else if (oil_ml >= 20)
                pressure_reduced_per_turn += 19.02;
            else
                pressure_reduced_per_turn += 6.34;
                
            if (fabs(pressure_reduced_per_turn) > 0.01)
                turns_remaining_at_current_ml = ceil(base_quest_state.state_float["oil peak pressure"] / pressure_reduced_per_turn);
            
            string line2 = pluralise(turns_remaining_at_current_ml, "turn", "turns") + " remaining at " + oil_ml + " ML.";
            if (base_quest_state.state_boolean["oil peak pressure bug in effect"])
                line2 = "At most " + line2 + " (unable to track, sorry)";
            details.listAppend(line2);
            
            if (oil_ml < 50 && $item[dress pants].available_amount() == 0 && !in_hardcore())
                details.listAppend("If you can't reach +50 ML or more, possibly consider pulling and wearing dress pants. (lazy pull, doesn't add ML but saves 4 or 24 turns)");
        }
		if (need_jar_of_oil)
		{
			modifiers.listAppend("+item");
            string item_drop_string = "";
            int [int] drop_rates;
            if (oil_ml >= 100)
            {
                //last is possibly 10%, needs more spading
                item_drop_string = "100%/30%/10% drops";
                drop_rates = listMake(100, 30, 10);
            }
            else if (oil_ml >= 50)
            {
                item_drop_string = "100%/30% drops";
                drop_rates = listMake(100, 30);
            }
            else if (oil_ml >= 20)
            {
                item_drop_string = "100%/10% drops";
                drop_rates = listMake(100, 10);
            }
            else
            {
                item_drop_string = "100% drop";
                drop_rates = listMake(100);
            }
            
            float crudes_per_adventure = 0.0;
            float item_drop_rate_multiplier = (100.0 + $location[oil peak].item_drop_modifier_for_location()) / 100.0;
            foreach key in drop_rates
            {
                int rate = drop_rates[key];
                float effective_rate = MIN(1.0, rate.to_float() / 100.0 * item_drop_rate_multiplier);
                crudes_per_adventure += effective_rate;
            }
            string crude_string = "~" + crudes_per_adventure.roundForOutput(1) + " crude/adventure.";
            if (turns_remaining_at_current_ml > 0)
                crude_string += " ~" + (crudes_per_adventure * turns_remaining_at_current_ml.to_float()).roundForOutput(1) + " crudes before fire lit.";
            
            
            if ($item[bubblin' crude].available_amount() < 12)
            {
                details.listAppend("Run +item to acquire " + pluralise(MAX(0, 12 - $item[bubblin' crude].available_amount()), "more bubblin' crude", "more bubblin' crudes") + ". (" + item_drop_string + ")|" + crude_string);
                if ($item[duskwalker syringe].available_amount() > 0)
                    details.listAppend("Use " + $item[duskwalker syringe].pluralise() + " in-combat for more crude.");
            }
		}
		
		task_entries.listAppend(ChecklistEntryMake(68, "oil peak", "place.php?whichplace=highlands", ChecklistSubentryMake("Oil Peak", modifiers, details), $locations[oil peak]));
	}
    else if (!$location[oil peak].noncombat_queue.contains_text("Unimpressed with Pressure"))
    {
        string [int] details;
        string [int] modifiers;
        
        details.listAppend("Light the fire!");
        
		task_entries.listAppend(ChecklistEntryMake(69, "oil peak", "place.php?whichplace=highlands", ChecklistSubentryMake("Oil Peak", modifiers, details), $locations[oil peak]));
    }
}

void QLevel9GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 9"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 9"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
    string url = "place.php?whichplace=highlands";
	int tasks_before = task_entries.count() + optional_task_entries.count() + future_task_entries.count();
	
	if (base_quest_state.mafia_internal_step == 1)
    {
        url = "place.php?whichplace=orc_chasm";
		//build bridge:
  
        //if (__misc_state["have olfaction equivalent"]) //don't remember what you'd olfact here
            //subentry.modifiers.listAppend("olfaction");
		subentry.entries.listAppend("Build a bridge.");
  
        string smut_orc_noncombat_progress_string = get_property("smutOrcNoncombatProgress");
        boolean orc_tracking_supported = false;
        if (smut_orc_noncombat_progress_string != "")
        {
            orc_tracking_supported = true;
        }
        float weapon_damage_actual = numeric_modifier("Weapon Damage");
        //correct numeric_modifier's response to actual:
        foreach s in $slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3,familiar]
        {
        	item it = s.equipped_item();
            if (it == $item[none]) continue;
            if (it.to_slot() != $slot[weapon]) continue;
            weapon_damage_actual -= it.get_power().to_float() * 0.15;
        }
        
        int choice_1_pieces_gained = MAX(3, MIN(14, sqrt((my_buffedstat($stat[muscle]) + weapon_damage_actual) / 15.0 * (numeric_modifier("Weapon Damage Percent") / 100.0 + 1.0))));
        int choice_2_pieces_gained = MAX(3, MIN(14, sqrt((my_buffedstat($stat[mysticality]) + numeric_modifier("Spell Damage")) / 15.0 * (numeric_modifier("Spell Damage Percent") / 100.0 + 1.0))));
        int choice_3_pieces_gained = MAX(3, MIN(14, sqrt((my_buffedstat($stat[moxie]) / 30.0 * (numeric_modifier("Sleaze Resistance") * 0.69 + 1.0)))));
        
        if (orc_tracking_supported)
        {
            int smut_orc_noncombat_progress = smut_orc_noncombat_progress_string.to_int_silent();
            if (smut_orc_noncombat_progress < 15)
            {
                subentry.modifiers.listAppend("+item");
            	subentry.modifiers.listAppend("-ML");
                int percent_to_nc = smut_orc_noncombat_progress.to_float() / 15.0 * 100; 
            	subentry.entries.listAppend("Run as little monster level as possible.|Overkill the orcs with as much " + HTMLGenerateSpanOfClass("cold damage", "r_element_cold") + " as you can.|" + percent_to_nc + "% to NC.");
            }
            else
            {
            	int best_choice_pieces = choice_1_pieces_gained;
            	string best_choice = "the first choice";
                if (choice_2_pieces_gained > best_choice_pieces)
                {
	                best_choice = "the second choice";
                	best_choice_pieces = choice_2_pieces_gained;
                }
                if (choice_3_pieces_gained > best_choice_pieces)
                {
                    best_choice = "the third choice";
                    best_choice_pieces = choice_3_pieces_gained;
                }
                
            	subentry.entries.listAppend("Next encounter will be the non-combat.|Choose <strong>" + best_choice + "</strong>. (<strong>" + best_choice_pieces + "</strong> pieces gained)");
                string line;
            	line += "Your buffing options are:";
                line += "|*Buff <strong>+muscle</strong>/<strong>weapon damage percent</strong>/<small>weapon damage</small> for the first NC option. (at <strong>" + choice_1_pieces_gained + "</strong> pieces)";
                line += "|*Or <strong>+myst</strong>/<strong>spell damage percent</strong>/<small>spell damage</small> for the second NC option. (at <strong>" + choice_2_pieces_gained + "</strong> pieces)";
                line += "|*Or <strong>+moxie</strong>/<strong>sleaze resistance</strong> and choose the third option at the NC. (at <strong>" + choice_3_pieces_gained + "</strong> pieces)";
                subentry.entries.listAppend(line);
            }
        }
        else
        {
            subentry.modifiers.listAppend("+item");
            subentry.modifiers.listAppend("-ML");
            subentry.modifiers.listAppend("+moxie");
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("+sleaze resistance", "r_element_sleaze_desaturated"));
            //FIXME show how effective you are at the moment.
            subentry.entries.listAppend("Run as little monster level as possible.|Overkill the orcs with as much cold damage as you can.");
            subentry.entries.listAppend("Then:");
            subentry.entries.listAppend("|*Buff +muscle/weapon damage/weapon damage percent for the first NC option.");
            subentry.entries.listAppend("|*Or +myst/spell damage/spell damage percent for the second NC option.");
            subentry.entries.listAppend("|*Or +moxie/sleaze resistance and choose the third option at the NC.");
        }
        
        if (get_property("questM15Lol") != "finished" && ($item[bridge].available_amount() > 0 || $item[dictionary].available_amount() == 0) && false) //it's gone!
        {
            if ($item[bridge].available_amount() > 0)
                subentry.entries.listAppend("Place the bridge.");
            else if ($item[abridged dictionary].available_amount() > 0)
                subentry.entries.listAppend("Untinker the abridged dictionary.");
            else
                subentry.entries.listAppend("Acquire an abridged dictionary from the pirates, untinker it.");
        }
		int fasteners_needed = base_quest_state.state_int["bridge fasteners needed"];
		int lumber_needed = base_quest_state.state_int["bridge lumber needed"];
		
		if (__misc_state["can equip just about any weapon"])
		{
            if (lumber_needed > 0)
            {
                if ($item[logging hatchet].available_amount() > 0 && $item[logging hatchet].equipped_amount() == 0)
                    subentry.entries.listAppend("Possibly equip that logging hatchet.");
                else if ($item[logging hatchet].available_amount() == 0 && canadia_available())
                    subentry.entries.listAppend("Possibly acquire a logging hatchet. (first adventure in Camp Logging Camp in Little Canadia)");
            }
			
            if (fasteners_needed > 0)
            {
                if ($item[loadstone].available_amount() > 0 && $item[loadstone].equipped_amount() == 0)
                    subentry.entries.listAppend("Possibly equip that loadstone.");
                else if ($item[loadstone].available_amount() == 0 && !__quest_state["Level 8"].state_boolean["Past mine"])
                    subentry.entries.listAppend("Possibly find a loadstone in the mine.");
            }
		}
		
        if (($item[snow berries].available_amount() > 0 || $item[ice harvest].available_amount() > 0) && $item[snow boards].available_amount() < 4)
			subentry.entries.listAppend("Possibly make snow boards.");
        if (__misc_state["can use clovers"])
			subentry.entries.listAppend("Possibly clover for 3 lumber and 3 fasteners.");

		
		string [int] line;
		if (fasteners_needed > 0)
			line.listAppend(fasteners_needed + " fasteners");
		if (lumber_needed > 0)
			line.listAppend(lumber_needed + " lumber");
            
        if (lumber_needed + fasteners_needed == 0)
        {
            //finished
            subentry.modifiers.listClear();
            subentry.entries.listClear();
            subentry.entries.listAppend("Build a bridge!");
        }
		if ($item[smut orc keepsake box].available_amount() > 0)
			subentry.entries.listAppend("Open " + pluralise($item[smut orc keepsake box]) + ".");
		if (line.count() > 0)
			subentry.entries.listAppend("Need " + line.listJoinComponents(" ", "and") + ".");
	}
	/*else if (base_quest_state.mafia_internal_step == 2)
	{
		//bridge built, talk to angus:
		subentry.entries.listAppend("Talk to Angus in the Highland Lord's tower.");
	}*/
	else if (base_quest_state.mafia_internal_step == 2 || base_quest_state.mafia_internal_step == 3)
	{
		//do three peaks:
		//subentry.entries.listAppend("Light the fires!");
        if ($location[oil peak].noncombat_queue.contains_text("Unimpressed with Pressure") && $location[a-boo peak].noncombat_queue.contains_text("Come On Ghosty, Light My Pyre") && base_quest_state.state_int["twin peak progress"] == 15)
            subentry.entries.listAppend("Talk to Lord Angus to finish the quest.");
        else
            subentry.entries.listAppend("Light the fires!");
		QLevel9GenerateTasksSidequests(task_entries, optional_task_entries, future_task_entries);
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
		//fires lit, talk to angus again:
		subentry.entries.listAppend("Talk to Angus in the Highland Lord's tower.");
	}
	int tasks_after = task_entries.count() + optional_task_entries.count() + future_task_entries.count();
	if (tasks_before == tasks_after) //if our sidequests didn't add anything, show something:
		task_entries.listAppend(ChecklistEntryMake(70, base_quest_state.image_name, url, subentry, $locations[the smut orc logging camp,a-boo peak,oil peak,twin peak]));
}
