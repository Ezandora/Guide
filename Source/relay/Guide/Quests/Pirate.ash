
void QPirateInit()
{
	//questM12Pirate ?
	//lastPirateInsult1 through lastPirateInsult8
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questM12Pirate");
	state.quest_name = "Pirate Quest";
	state.image_name = "pirate quest";
	
	if (__misc_state["mysterious island available"])
	{
		state.startable = true;
		if (!state.in_progress && !state.finished)
		{
			QuestStateParseMafiaQuestPropertyValue(state, "started");
		}
	}
    
    
	boolean hot_wings_relevant = knoll_available() || $item[frilly skirt].available_amount() > 0;
    if (state.mafia_internal_step >= 4) //done that already
        hot_wings_relevant = false;
	boolean need_more_hot_wings = $item[hot wing].available_amount() <3 && hot_wings_relevant;
    
    state.state_boolean["hot wings relevant"] = hot_wings_relevant;
    state.state_boolean["need more hot wings"] = need_more_hot_wings;
    
    
	int insult_count = 0;
	for i from 1 to 8
	{
		if (get_property_boolean("lastPirateInsult" + i))
			insult_count += 1;
	}
    state.state_int["insult count"] = insult_count;
    
    if ($item[Orcish Frat House blueprints].available_amount() > 0 && state.mafia_internal_step <3 )
        QuestStateParseMafiaQuestPropertyValue(state, "step2");
    
	//Certain characters are in weird states, I think?
    if ($item[pirate fledges].available_amount() > 0 || $item[talisman o' nam].available_amount() > 0)
        QuestStateParseMafiaQuestPropertyValue(state, "finished");
	__quest_state["Pirate Quest"] = state;
}


void QPirateGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Pirate Quest"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Pirate Quest"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "";
    
	boolean have_outfit = have_outfit_components("Swashbuckling Getup");
	if ($item[pirate fledges].available_amount() > 0)
		have_outfit = true;
        
    int insult_count = base_quest_state.state_int["insult count"];
	
	float [int] insult_success_likelyhood;
	//haven't verified these numbers, need to double-check
	insult_success_likelyhood[0] = 0.0;
	insult_success_likelyhood[1] = 0.0;
	insult_success_likelyhood[2] = 0.0;
	insult_success_likelyhood[3] = 0.0179;
	insult_success_likelyhood[4] = 0.071;
	insult_success_likelyhood[5] = 0.1786;
	insult_success_likelyhood[6] = 0.357;
	insult_success_likelyhood[7] = 0.625;
	insult_success_likelyhood[8] = 1.0;
	
    boolean delay_for_future = false;
    boolean can_acquire_cocktail_napkins = false;
	
	if (!have_outfit)
	{
        url = "island.php";
		string line = "Acquire outfit.";
		
		item [int] outfit_pieces = outfit_pieces("Swashbuckling Getup");
		item [int] outfit_pieces_needed;
		foreach key in outfit_pieces
		{
			item piece = outfit_pieces[key];
			if (piece.available_amount() == 0)
				outfit_pieces_needed.listAppend(piece);
		}
		line += " Need " + outfit_pieces_needed.listJoinComponents(", ", "and") + ".";
		subentry.entries.listAppend(line);
		
		subentry.modifiers.listAppend("+item");
		subentry.modifiers.listAppend("-combat");
        int ncs_relevant = 0; //out of six
        if ($item[stuffed shoulder parrot].available_amount() == 0 || $item[eyepatch].available_amount() == 0)
            ncs_relevant += 1;
        if ($item[eyepatch].available_amount() == 0 || $item[swashbuckling pants].available_amount() == 0)
            ncs_relevant += 1;
        if ($item[swashbuckling pants].available_amount() == 0 || $item[stuffed shoulder parrot].available_amount() == 0)
            ncs_relevant += 1;
        
        float average_combat_rate = clampNormalf(.6 + combat_rate_modifier() / 100.0);
        float average_nc_rate = 1.0 - average_combat_rate;
        
        float average_useful_nc_rate = average_nc_rate * (ncs_relevant.to_float() / 6.0);
        //FIXME make this more accurate
        float turns_remaining = -1.0;
        if (average_useful_nc_rate != 0.0)
            turns_remaining = outfit_pieces_needed.count().to_float() / average_useful_nc_rate;
		subentry.entries.listAppend("Run -combat in the obligatory pirate's cove." + "|~" + turns_remaining.roundForOutput(1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        
        if (!__quest_state["Manor Unlock"].state_boolean["ballroom song effectively set"])
        {
            subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
            delay_for_future = true;
        }
	}
	else
	{
        url = "place.php?whichplace=cove";
        
        if (!is_wearing_outfit("Swashbuckling Getup") && $item[pirate fledges].equipped_amount() == 0)
            url = "inventory.php?which=2";
            
        
		if (base_quest_state.mafia_internal_step == 1)
		{
            can_acquire_cocktail_napkins = true;
			//caronch gave you a map
			if ($item[Cap'm Caronch's nasty booty].available_amount() == 0 && $item[Cap'm Caronch's Map].available_amount() > 0)
			{
                url = "inventory.php?which=3";
				subentry.entries.listAppend("Use Cap'm Caronch's Map, fight a booty crab.");
				subentry.entries.listAppend("Possibly run +meat. (300 base drop)");
                subentry.modifiers.listAppend("+meat");
			}
			else if (have_outfit)
            {
                subentry.modifiers.listAppend("-combat");
				subentry.entries.listAppend("Find Cap'm Caronch in Barrrney's Barrr.");
            }
		}
		else if (base_quest_state.mafia_internal_step == 2)
		{
            can_acquire_cocktail_napkins = true;
			//give booty back to caronch
			subentry.entries.listAppend("Find Cap'm Caronch in Barrrney's Barrr.");
		}
		else if (base_quest_state.mafia_internal_step == 3)
		{
            can_acquire_cocktail_napkins = true;
			//have blueprints, catburgle
			string line = "Use the Orcish Frat House blueprints";
			if (insult_count < 6)
            {
                subentry.modifiers.listAppend("+20% combat");
				line += ", once you have at least six insults"; //in certain situations five might be slightly faster? but that skips a lot of combats, so probably not
            }
			line += ".";
			
            string method;
			if (have_outfit_components("Frat Boy Ensemble") && __misc_state["can equip just about any weapon"])
			{
				string [int] todo;
				if (!is_wearing_outfit("Frat Boy Ensemble"))
					todo.listAppend("wear frat boy ensemble");
				todo.listAppend("attempt a frontal assault");
				method = todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".";
			}
			else if ($item[mullet wig].available_amount() > 0 && $item[briefcase].available_amount() > 0)
			{
				string [int] todo;
				if ($item[mullet wig].equipped_amount() == 0)
					todo.listAppend("wear mullet wig");
				todo.listAppend("go in through the side door");
				method = todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".";
			}
			else if (knoll_available() || $item[frilly skirt].available_amount() > 0)
			{
				string [int] todo;
                if (insult_count < 6)
                    todo.listAppend("acquire at least six insults");
				if ($item[hot wing].available_amount() <3 )
					todo.listAppend("acquire " + pluralize((3 - $item[hot wing].available_amount()), "more hot wing", "more hot wings"));
				if ($item[frilly skirt].equipped_amount() == 0)
					todo.listAppend("wear frilly skirt");
				todo.listAppend("catburgle");
                string line2 = todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".";
				method = line2;
			}
			else
			{
				method = "Not sure how to approach this efficiently, sorry.";
			}
            line += "|" + method;
			subentry.entries.listAppend(line);
		}
		else if (base_quest_state.mafia_internal_step == 4)
		{
			//acquired teeth, give them back
			subentry.entries.listAppend("Find Cap'm Caronch in Barrrney's Barrr. (next adventure)");
		}
		else if (base_quest_state.mafia_internal_step == 5)
		{
			//ricketing
			subentry.entries.listAppend("Play beer pong.");
			subentry.entries.listAppend("If you want more insults now, adventure in the Obligatory Pirate's Cove, not in the Barrr.");
		}
		else if (base_quest_state.mafia_internal_step == 6)
		{
			//f'c'le
			//We can't tell them which ones they need, precisely, since they may have already used them.
			//We can tell them which ones they have... but it's still unreliable. I guess a single message if they have all three?
			string line = "F'c'le.";
			string additional_line = "";
            
            item [int] missing_washing_items = $items[rigging shampoo,mizzenmast mop,ball polish].items_missing();
            
			if (missing_washing_items.count() == 0)
            {
                url = "inventory.php?which=3";
				line += " " + HTMLGenerateSpanFont("Use rigging shampoo, mizzenmast mop, and ball polish", "red", "") + ", then adventure to complete quest.";
            }
			else
			{
                subentry.modifiers.listAppend("+234% item");
                subentry.modifiers.listAppend("+20% combat");
				line += " Run +234% item, +combat, and collect " + missing_washing_items.listJoinComponents(", ", "and") + ".";
				if ($location[the f'c'le].item_drop_modifier_for_location() < 234.0)
					additional_line = "This location can be a nightmare without +234% item.";
			}
            
			subentry.entries.listAppend(line);
			if (additional_line != "")
				subentry.entries.listAppend(additional_line);
            if (!$monster[clingy pirate].is_banished() && $item[cocktail napkin].available_amount() > 0)
            {
                subentry.entries.listAppend("Use cocktail napkin on clingy pirate to " + (__misc_state["free runs usable"] ? "free run/" : "") + "banish.");
            }
		}
        
        if (base_quest_state.mafia_internal_step <= 3 && my_inebriety() > 0)
        {
            subentry.entries.listAppend("Could wait until rollover; one of the non-combats can become a combat at zero drunkenness.");
        }
        
        
        if (__misc_state["free runs available"] && !can_acquire_cocktail_napkins)
            subentry.modifiers.listAppend("free runs");
	}
	boolean should_output_insult_data = false;
	if ($item[the big book of pirate insults].available_amount() > 0 || have_outfit)
		should_output_insult_data = true;
	if (base_quest_state.mafia_internal_step >= 6)
		should_output_insult_data = false;
		
	if (should_output_insult_data)
	{
		string line = "At " + pluralize(insult_count, "insult", "insults") + ". " + roundForOutput(insult_success_likelyhood[insult_count] * 100, 1) + "% chance of beer pong success.";
		if (insult_count < 8)
			line += "|Insult every pirate with the big book of pirate insults.";
		subentry.entries.listAppend(line);
	}
	if ($item[the big book of pirate insults].available_amount() == 0 && base_quest_state.mafia_internal_step < 6 && have_outfit)
		subentry.entries.listAppend(HTMLGenerateSpanFont("Buy the big book of pirate insults.", "red", ""));
	
    if (can_acquire_cocktail_napkins && $item[cocktail napkin].available_amount() == 0)
    {
        subentry.modifiers.listAppend("+item");
        subentry.entries.listAppend("Try to acquire a cocktail napkin to speed up F'c'le. (10% drop, marginal)");
    }
    
	if (!is_wearing_outfit("Swashbuckling Getup") && have_outfit)
    {
        string [int] stats_needed;
        if (my_basestat($stat[moxie]) < 25)
            stats_needed.listAppend("moxie");
        if (my_basestat($stat[mysticality]) < 25)
            stats_needed.listAppend("mysticality");
        string line = "Wear swashbuckling getup.";
        
        if (stats_needed.count() > 0)
        {
            delay_for_future = true;
            line += HTMLGenerateSpanOfClass(" Need 25 " + stats_needed.listJoinComponents(", ", "and"), "r_bold") + ".";
        }
		subentry.entries.listAppend(line);
    }
        
    if (delay_for_future)
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the obligatory pirate's cove, barrrney's barrr, the f'c'le]));
    else
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the obligatory pirate's cove, barrrney's barrr, the f'c'le]));
}