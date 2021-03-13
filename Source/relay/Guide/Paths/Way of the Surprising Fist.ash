//Some simple suggestions for this forgotten path:
RegisterResourceGenerationFunction("PathWOTSFGenerateResource");
void PathWOTSFGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
		return;
	//Meat:
	if (have_outfit_components("Knob Goblin Harem Girl Disguise") && !get_property_boolean("_treasuryHaremMeatCollected") && locationAvailable($location[Cobb's Knob Barracks]))
	{
		resource_entries.listAppend(ChecklistEntryMake(194, "meat", "cobbsknob.php", ChecklistSubentryMake("Cobb's Knob treasury meat", "", "Wear harem girl disguise, adventure once for 500 meat."), 5));
	}
	//Skills:
	string [int] fist_teaching_properties = split_string_alternate("fistTeachingsBarroomBrawl,fistTeachingsBatHole,fistTeachingsConservatory,fistTeachingsFratHouse,fistTeachingsFunHouse,fistTeachingsHaikuDungeon,fistTeachingsMenagerie,fistTeachingsNinjaSnowmen,fistTeachingsPokerRoom,fistTeachingsRoad,fistTeachingsSlums", ",");
	location [string] teaching_properties_to_locations;
	teaching_properties_to_locations["fistTeachingsBarroomBrawl"] = $location[A Barroom Brawl];
	teaching_properties_to_locations["fistTeachingsBatHole"] = $location[The Bat Hole Entrance];
	teaching_properties_to_locations["fistTeachingsConservatory"] = $location[The Haunted Conservatory];
	teaching_properties_to_locations["fistTeachingsFratHouse"] = $location[Frat House];
	teaching_properties_to_locations["fistTeachingsFunHouse"] = $location[The "Fun" House];
	teaching_properties_to_locations["fistTeachingsHaikuDungeon"] = $location[The Haiku Dungeon];
	teaching_properties_to_locations["fistTeachingsMenagerie"] = $location[Cobb's Knob Menagerie\, Level 2];
	teaching_properties_to_locations["fistTeachingsNinjaSnowmen"] = $location[Lair of the Ninja Snowmen];
	teaching_properties_to_locations["fistTeachingsPokerRoom"] = $location[The Poker Room];
	teaching_properties_to_locations["fistTeachingsRoad"] = $location[The Road to the White Citadel];
	teaching_properties_to_locations["fistTeachingsSlums"] = $location[Pandamonium Slums];
	
	string [int] missing_areas;
	foreach key in fist_teaching_properties
	{
		string property = fist_teaching_properties[key];
		if (!get_property_boolean(property))
		{
			location place = teaching_properties_to_locations[property];
			missing_areas.listAppend(place.HTMLGenerateFutureTextByLocationAvailability());
		}
	}
	if (missing_areas.count() > 0)
		resource_entries.listAppend(ChecklistEntryMake(195, "__item Teachings of the Fist", "", ChecklistSubentryMake("Teachings of the Fist", "", "Found in " + missing_areas.listJoinComponents(", ", "and") + "."), 5));
		
}
