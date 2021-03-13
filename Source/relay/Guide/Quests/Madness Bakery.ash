//questM25Armorer
void QMadnessBakeryInit()
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM25Armorer");
	
	state.quest_name = "Lending a Hand (and a Foot)";
	state.image_name = "__item unlit birthday cake";
    
	
	__quest_state["Madness Bakery"] = state;
}


RegisterGenerationFunction("QMadnessBakeryGenerate");
void QMadnessBakeryGenerate(ChecklistCollection checklists)
{
	QuestState base_quest_state = __quest_state["Madness Bakery"];
	if (!base_quest_state.in_progress)
		return;
    
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string url = "place.php?whichplace=town_right";
    
    if ($item[no-handed pie].available_amount() > 0 || base_quest_state.mafia_internal_step >= 5)
    {
        subentry.entries.listAppend("Talk to the leggerer.");
        url = "place.php?whichplace=town_market";
    }
    else
    {
        //step1 seems to exist, but no information on office visits left
        //step2 - cake lord
        //step3 - in the progress of talking to madeline
        //step4 - acquire cake
        //step5 - melon lord?
        subentry.entries.listAppend("Adventure in the Madness Bakery|Choose the first option in the non-combat repeatedly.");
    }
		
	checklists.add(C_AFTERCORE_TASKS, ChecklistEntryMake(1, base_quest_state.image_name, url, subentry, $locations[Madness Bakery]));
}
