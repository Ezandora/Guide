//bad
/*RegisterTaskGenerationFunction("IOTMBetterShroomsAndGardensGenerateTasks");
void IOTMBetterShroomsAndGardensGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!(get_campground() contains $item[packet of mushroom spores])) return;
	
	int fights = get_property_int("_mushroomGardenFights");
	int fight_limit = 1;
	if (my_path_id() == PATH_LUIGI)
		fight_limit = 5;
    int fights_left = clampi(0, fight_limit - fights, fight_limit);
    
    if (fights_left > 0)
    {
    	string title = "Fight in your mushroom garden";
    	string [int] description;
        if (fights_left > 1)
        	description.listAppend(fights_left + " free fights left.");
        else
        	description.listAppend("Free fight.");
        description.listAppend("Pick the mushroom afterwards.");
        if (!__misc_state["in run"]) //rewards do not seem practical in-run
        	description.listAppend("Or fertilise it for long-term rewards.");
        
        optional_task_entries.listAppend(ChecklistEntryMake(611, "__item colossal free-range mushroom", "campground.php", ChecklistSubentryMake(title, "", description), 8));
    }
}*/

RegisterGenerationFunction("IOTMBetterShroomsAndGardensGenerate");
void IOTMBetterShroomsAndGardensGenerate(ChecklistCollection checklists)
{
	if (get_campground()[$item[packet of mushroom spores]] == 0) return;
	
	int max_fights = 1;
	if (my_path_id() == PATH_LUIGI)
		max_fights = 5;
    int fights_left = clampi(max_fights - get_property_int("_mushroomGardenFights"), 0, max_fights);
    if (fights_left > 0)
    {
    	string title = "Free mushroom fight";
        if (fights_left > 1)
        	title = pluralise(fights_left, "mushroom fight", "mushroom fights");
        string description;
        
        checklists.add(C_RESOURCES, ChecklistEntryMake(612, "__item immense free-range mushroom", "campground.php", ChecklistSubentryMake(title, "", description), 4).ChecklistEntryTag("daily free fight"));
    }
    if (!get_property_boolean("_mushroomGardenVisited") && fights_left <= 0)
    {
    	string title = "Pick mushroom garden";
        string description = "Or fertilise it for long-term rewards";
        checklists.add(C_OPTIONAL_TASKS, ChecklistEntryMake(613, "__item immense free-range mushroom", "campground.php", ChecklistSubentryMake(title, "", description), 4));
    	
    }
}




RegisterResourceGenerationFunction("IOTMBetterShroomsAndGardensGenerateResource");
void IOTMBetterShroomsAndGardensGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (in_ronin())
	{
		item [int] mushrooms;
        foreach it in $items[free-range mushroom,plump free-range mushroom,bulky free-range mushroom,giant free-range mushroom,immense free-range mushroom,colossal free-range mushroom]
        {
        	if (!it.have()) continue;
        	mushrooms.listAppend(it);
        }
        //we would use ChecklistEntryTag here, except I am not sure if it's stable and I only want the last entry to have the description
        ChecklistSubentry [int] subentries;
        string image_name;
        foreach key, it in mushrooms
        {
        	if (image_name == "") image_name = "__item " + it;
        	string [int] description;
            if (key == mushrooms.count() - 1)
            	description.listAppend("Use for mushroom filets.");
            subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", description));
        	//resource_entries.listAppend(ChecklistEntryMake(614, "__item " + it, "campground.php", ChecklistSubentryMake(pluralise(it), "", description), 8).ChecklistEntryTag("using shroom and garden item"));
        }
        if (subentries.count() > 0)
        	resource_entries.listAppend(ChecklistEntryMake(615, image_name, "inventory.php?which=3&ftext=mushroom", subentries, 8));
    }
}
