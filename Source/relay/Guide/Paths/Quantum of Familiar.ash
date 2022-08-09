
RegisterGenerationFunction("PathQuantumOfFamiliarGenerate");
void PathQuantumOfFamiliarGenerate(ChecklistCollection checklists)
{
	if (my_path_id() != PATH_QUANTUM) return;
	int current_turn = total_turns_played();
	int next_quantum_alignment = get_property_int("_nextQuantumAlignment");
	//nextQuantumFamiliarTurn?
	
	if (current_turn >= next_quantum_alignment)
	{
		int turns_until_next_familiar_switch = clampi(get_property_int("nextQuantumFamiliarTurn") - current_turn, -1, 11);
		string [int] description;
        string turns_usable_in = pluralise(turns_until_next_familiar_switch, "turn", "turns");
        if (turns_until_next_familiar_switch == -1)
        	turns_usable_in = "unknown turns";
        description.listAppend("Will be usable in " + turns_usable_in + ".");
        if (get_property_int("_banderRunaways") < 11)
	        description.listAppend("Maybe a pair of stomping boots?");
        checklists.add(C_OPTIONAL_TASKS, ChecklistEntryMake(0, "__familiar pair of stomping boots", "qterrarium.php", ChecklistSubentryMake("Can align your next familiar", "", description), 0));
	}
}
