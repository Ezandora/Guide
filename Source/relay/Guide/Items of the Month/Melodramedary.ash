

RegisterGenerationFunction("IOTMMelodramedaryGenerate");
void IOTMMelodramedaryGenerate(ChecklistCollection checklists)
{
	familiar melodramedary = lookupFamiliar("Melodramedary");
	if (!melodramedary.have_familiar() || __misc_state["familiars temporarily blocked"]) return;
	
	item melodramedary_helmet = lookupItem("dromedary drinking helmet");
	/*√-desert
	-han on hoth
	-whatever else this does
	-spit:
	spit on me: +100% weapon/spell damage, +100% all stats (community service alert)
	spit on them: doubles the amount of items dropped
	*/
	
	boolean avoid_adding_main = false;
	
	int spit_level = get_property_int("camelSpit"); //starts at 100
	
	string title;// = spit_level + " Melodramedary spit";
	string [int] description;
	string url_main;
	string short_desc;
	
	if (my_familiar() != melodramedary)
	{
        url_main = "familiar.php";
        description.listAppend("Bring melodramedary along.");
	}
	if (spit_level < 100)
	{
		float spit_per_combat = 3.33;
        if (melodramedary.familiar_equipped_equipment() == melodramedary_helmet)
        {
        	spit_per_combat += 3.33 * 0.3;
        }
        else if (melodramedary_helmet.available_amount() > 0 && melodramedary_helmet.can_equip())
        {
        	description.listAppend("Should equip the dromedary drinking helmet.");
        }
        if (spit_level == 0 && my_familiar() != melodramedary)
        	avoid_adding_main = true;
        float remaining_spit = 100 - spit_level;
        
        float remaining_turns = remaining_spit / spit_per_combat;
        
        int estimated_turns = remaining_turns.floor();
        title = pluralise(estimated_turns, "combat", "combats") + " until melodramedary skill";
		//description.listAppend(pluralise(remaining_turns.round(), "turn", "turns") + " to next use.");
  
  		short_desc = estimated_turns.to_string();
    }
    else
    {
    	title = "Melodramedary combat skill ready";
        short_desc = "now";
    	string target_text;
     
     	string [int] targets;
        //FIXME write this
        if (targets.count() > 0)
	        target_text = "|Potential Targets:|*-" + targets.listJoinComponents("|*-");
    	description.listAppend(melodramedary.name + ", spit on me: +100% weapon/spell damage/stats buff. (15 turns)");
        description.listAppend(melodramedary.name + ", spit on them: doubles all items dropped from combat. " + target_text);
    }
	if (!avoid_adding_main)
		checklists.add(C_RESOURCES, ChecklistEntryMake("__familiar Melodramedary", url_main, ChecklistSubentryMake(title, "", description), 1)).ChecklistEntryTag("Melodramedary").ChecklistEntrySetCategory("familiar").ChecklistEntrySetShortDescription(short_desc);
	
	//There might not be any tracking for this?
	if (lookupItem("Fourth of May Cosplay Saber").have() && !get_property_boolean("_tauntaunTaunted") && false)
	{
		string url = "inventory.php?which=2";
		int cold_level = clampi(melodramedary.familiar_weight(), 1, 20);
  
  		string [int] tauntaun_description;
        tauntaun_description.listAppend("+" + cold_level + " cold res. (10 turns)");
        tauntaun_description.listAppend("Will reset Melodramedary familiar weight.");
        string [int] tasks;
        if (!lookupItem("Fourth of May Cosplay Saber").equipped())
        {
        	tasks.listAppend("equip Fourth of May Cosplay Saber");
        }
        if (my_familiar() != melodramedary)
        {
        	url = "familiar.php";
        	tasks.listAppend("change familiar to Melodramedary");
        }
        if (tasks.count() > 0)
        	tauntaun_description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        checklists.add(C_RESOURCES, ChecklistEntryMake("__familiar Melodramedary", url, ChecklistSubentryMake("Melodramedary buff", "", tauntaun_description), 1)).ChecklistEntryTag("Melodramedary");
	}
}
