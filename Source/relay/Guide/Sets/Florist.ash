import "relay/Guide/Plants.ash";

RegisterTaskGenerationFunction("SFloristGenerateTasks");
void SFloristGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Friar:
	if (__iotms_usable[$item[Order of the Green Thumb Order Form]])
	{
        string image_name = "sunflower face";
		ChecklistSubentry subentry;
		subentry.header = "Plant florist plants in " + __last_adventure_location;
        
        PlantSuggestion [int] area_relevant_suggestions;
		foreach key, suggestion in __plants_suggested_locations
		{
			
			if (suggestion.loc != __last_adventure_location)
				continue;
            
            area_relevant_suggestions.listAppend(suggestion);
        }
        
        boolean single_mode_only = false;
        if (area_relevant_suggestions.count() == 1)
        {
            single_mode_only = true;
			PlantSuggestion suggestion = area_relevant_suggestions[0];
			string plant_name = suggestion.plant_name.capitaliseFirstLetter();
        
            subentry.header = "Plant " + plant_name + " in " + __last_adventure_location;
        }
		
		foreach key, suggestion in area_relevant_suggestions
		{
			string plant_name = suggestion.plant_name.capitaliseFirstLetter();
			Plant plant = __plant_properties[plant_name];
			
			string line;
            
            if (single_mode_only)
            {
                line = plant.zone_effect + ", " + plant.terrain;
                if (plant.territorial)
                    line = line + ", territorial";
                
                if (suggestion.details != "")
                    line += "|*" + suggestion.details;
            }
            else
            {
                line = plant_name + " (" + plant.zone_effect + ", " + plant.terrain;
                if (plant.territorial)
                    line = line + ", territorial";
                
                line += ")";
                if (suggestion.details != "")
                    line += "|*" + suggestion.details;
            }
			
            if (plant_name == "War Lily" || plant_name == "Rabid Dogwood" || plant_name == "Blustery Puffball")
            {
                if (monster_level_adjustment() + 30 > 150)
                {
                    //subentry.header = "Optionally plant florist plants in " + __last_adventure_location;
                    image_name = "__item pirate fledges";
                    
                    subentry.header += "?";
                    line += "|" + HTMLGenerateSpanFont("Very dangerous", "red") + ", monsters ";
                    if (monster_level_adjustment() > 150)
                        line += "are";
                    else
                        line += "will be";
                    line += " stagger immune.";
                }
            }
            
			subentry.entries.listAppend(line);
		}
		if (subentry.entries.count() > 0)
			task_entries.listAppend(ChecklistEntryMake(402, image_name, "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry, -11));
	}
}
