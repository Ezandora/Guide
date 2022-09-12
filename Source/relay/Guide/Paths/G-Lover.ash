
RegisterResourceGenerationFunction("PathGLoverGenerateResource");
void PathGLoverGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (my_path_id_legacy() != PATH_G_LOVER)
        return;
	
	item g = $item[9909];
	if (g.available_amount() > 0)
	{
		string [int] description;
        if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 && !__quest_state["Level 9"].finished && $items[a-boo glue,glued a-boo clue].available_amount() * 30 < __quest_state["Level 9"].state_int["a-boo peak hauntedness"])
  		description.listAppend("A-Boo glue: lets you use one a-boo clue.");
		if (!__quest_state["Level 9"].state_boolean["Peak Jar Completed"] && !__quest_state["Level 9"].finished && $item[jar of oil].available_amount() == 0 && g.available_amount() >= 3)
	        description.listAppend("Crude oil congealer: lets you create a jar of oil.");
        description.listAppend("Food, drink, +100% spleen item for fifty turns.");
		resource_entries.listAppend(ChecklistEntryMake(196, "__item g", "shop.php?whichshop=glover", ChecklistSubentryMake(pluralise(g) + " available", "", description), 3));
	}
}
