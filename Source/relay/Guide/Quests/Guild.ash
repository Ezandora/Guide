
void QGuildInit()
{
    if (!($classes[seal clubber,turtle tamer,pastamancer,sauceror,disco bandit,accordion thief] contains my_class()))
        return;
	//questM02Artist
	QuestState state;
    
    if ($classes[seal clubber,turtle tamer] contains my_class())
        QuestStateParseMafiaQuestProperty(state, "questG09Muscle");
    if ($classes[pastamancer,sauceror] contains my_class())
        QuestStateParseMafiaQuestProperty(state, "questG07Myst");
    if ($classes[disco bandit,accordion thief] contains my_class())
        QuestStateParseMafiaQuestProperty(state, "questG08Moxie");
    if (guild_store_available())
        QuestStateParseMafiaQuestPropertyValue(state, "finished");
	
    
    
	//state.quest_name = "Guilded Youth";
    state.quest_name = "Join your guild";
    if (my_class() == $class[seal clubber])
        state.image_name = "__item seal-clubbing club";
    else if (my_class() == $class[turtle tamer])
        state.image_name = "__item helmet turtle";
    else if (my_class() == $class[pastamancer])
        state.image_name = "__item pasta spoon";
    else if (my_class() == $class[sauceror])
        state.image_name = "__item saucepan";
    else if (my_class() == $class[disco bandit])
        state.image_name = "__item disco mask";
    else if (my_class() == $class[accordion thief])
        state.image_name = "__item stolen accordion";
    
	if (state.mafia_internal_step < 2 && ($item[11-inch knob sausage].available_amount() > 0 || $item[exorcised sandwich].available_amount() > 0 && $location[the sleazy back alley].noncombat_queue.contains_text("Now's Your Pants!")))
	{
        QuestStateParseMafiaQuestPropertyValue(state, "step1");
	}
	
	state.startable = true;
	
	__quest_state["Guild"] = state;
}


void QGuildGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!($classes[seal clubber,turtle tamer,pastamancer,sauceror,disco bandit,accordion thief] contains my_class()))
        return;
	QuestState base_quest_state = __quest_state["Guild"];
	if (base_quest_state.finished)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "";
    
    if (__misc_state["in run"] && my_path_id() != PATH_PICKY && !in_bad_moon())
    {
        if ($classes[pastamancer,sauceror] contains my_class() && $location[the haunted pantry].turnsAttemptedInLocation() == 0)
            return;
        if ($classes[disco bandit,accordion thief] contains my_class() && $location[the sleazy back alley].turnsAttemptedInLocation() == 0)
            return;
        if (!base_quest_state.started && !($classes[seal clubber,turtle tamer] contains my_class()))
            return;
    }
	
    boolean [location] relevant_location;
    
    if (!base_quest_state.started)
    {
		subentry.entries.listAppend("Talk to your guild chief.");
        active_url = "guild.php";
    }
    else if (base_quest_state.mafia_internal_step == 1)
    {
        boolean output_modifiers = false;
        if ($classes[seal clubber,turtle tamer] contains my_class())
        {
            //cobb's knob
            active_url = $location[the outskirts of Cobb's Knob].getClickableURLForLocation();
            relevant_location[$location[the outskirts of Cobb's Knob]] = true;
            subentry.entries.listAppend("Adventure in the outskirts of Cobb's Knob to find the sausage.");
            output_modifiers = true;
        }
        if ($classes[pastamancer,sauceror] contains my_class())
        {
            //haunted pantry
            active_url = $location[the haunted pantry].getClickableURLForLocation();
            relevant_location[$location[the haunted pantry]] = true;
            subentry.entries.listAppend("Adventure in the haunted pantry to exorcise the poltersandwich.");
            output_modifiers = true;
        }
        if ($classes[disco bandit,accordion thief] contains my_class())
        {
            //sleazy back alley
            relevant_location[$location[the sleazy back alley]] = true;
            if ($slot[pants].equipped_item() == $item[none])
            {
                active_url = "inventory.php?which=2";
                subentry.entries.listAppend("Equip some pants.");
            }
            else
            {
                active_url = $location[the sleazy back alley].getClickableURLForLocation();
                subentry.entries.listAppend("Adventure in the sleazy back alley to steal your own pants.");
                output_modifiers = true;
            }
        }
        
        if (output_modifiers)
        {
            if (__misc_state["free runs available"])
            {
                subentry.modifiers.listAppend("free runs");
            }
            if (__misc_state["have hipster"])
            {
                subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
            }
        }
	}
    else if (base_quest_state.mafia_internal_step == 2)
    {
		subentry.entries.listAppend("Talk to your guild chief.");
        active_url = "guild.php";
    }
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, relevant_location));
}