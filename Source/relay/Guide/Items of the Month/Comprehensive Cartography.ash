RegisterGenerationFunction("IOTMComprehensiveCartographyGenerate");
void IOTMComprehensiveCartographyGenerate(ChecklistCollection checklists)
{
	if (!lookupSkill("Comprehensive Cartography").skill_is_usable()) return;
	
	
	int monster_maps_remaining = clampi(3 - get_property_int("_monstersMapped"), 0, 3);
	
	
	boolean currently_mapping_monsters = get_property_boolean("mappingMonsters");
	
	if (monster_maps_remaining > 0)
	{
		string title = pluralise(monster_maps_remaining, "Map the Monster", "Map the Monsters");
        string [int] description;
        description.listAppend("Allows picking which monster to encounter next adventure.");
        if (currently_mapping_monsters)
        	description.listAppend("Skill is up; choice will appear next adventure");
        
        checklists.add(C_RESOURCES, ChecklistEntryMake(454, "__skill Map the Monsters", "skillz.php", ChecklistSubentryMake(title, "", description), 0)).ChecklistEntrySetCategory("skill");
	}
	
	if (currently_mapping_monsters)
	{
		string title = "Monster Map Active";
        string [int] description;
        description.listAppend("Pick a monster to fight, when you adventure.");
        checklists.add(C_TASKS, ChecklistEntryMake(455, "__skill Map the Monsters", "main.php", ChecklistSubentryMake(title, "", description), -11));
	}
	
	//FIXME other half: the special adventures. have we seen them yet? how should we output this?
	//billiards room especially
}
