
RegisterGenerationFunction("IOTMCargoCultistShortsGenerate");
void IOTMCargoCultistShortsGenerate(ChecklistCollection checklists)
{
	item cultist_shorts = lookupItem("Cargo Cultist Shorts");
	if (!cultist_shorts.have()) return;
	
	if (!get_property_boolean("_cargoPocketEmptied"))
	{
		string [int] description;
        
        
        checklists.add(C_RESOURCES, ChecklistEntryMake(546, "__item Cargo Cultist Shorts", "inventory.php?action=pocket", ChecklistSubentryMake("Cargo Cultist Shorts pocket", "", description), 1));
	}
}
