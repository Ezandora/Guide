RegisterResourceGenerationFunction("IOTMLibramGenerateResource");
void IOTMLibramGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (__misc_state["bookshelf accessible"])
	{
		int libram_mp_cost = nextLibramSummonMPCost();
		
		
		string [int] librams_usable;
		foreach s in __libram_skills
        {
			if (s.skill_is_usable())
				librams_usable.listAppend(s.to_string());
        }
		if (libram_mp_cost <= my_maxmp() && librams_usable.count() > 0)
		{
			ChecklistSubentry subentry;
			if (librams_usable.count() == 1)
				subentry.header = "Libram";
			else
				subentry.header = "Librams";
			subentry.header += " summonable";
			subentry.modifiers.listAppend(libram_mp_cost + "MP cost");
			
			string [int] readable_list;
			foreach key in librams_usable
			{
				string libram_name = librams_usable[key];
				if (libram_name.stringHasPrefix("Summon "))
					libram_name = libram_name.substring(7);
				readable_list.listAppend(libram_name);
			}
			
			subentry.entries.listAppend(readable_list.listJoinComponents(", ", "and") + ".");
            
            if ($skill[summon taffy].skill_is_usable() && get_property_int("_taffyYellowSummons") == 0)
            {
                float chance = powf(0.5, MAX(0, get_property_int("_taffyRareSummons") + 1));
                subentry.entries.listAppend("Could try to summon a yellow taffy. (" + (chance * 100.0).roundForOutput(1) + "% chance)");
                //_taffyYellowSummons
            }
            
			resource_entries.listAppend(ChecklistEntryMake("__item libram of divine favors", "campground.php?action=bookshelf", subentry, 7));
		}
		
		
		if ($skill[summon brickos].skill_is_usable() && __misc_state["in run"])
		{
			if (get_property_int("_brickoEyeSummons") <3)
			{
				ChecklistSubentry subentry;
				subentry.header =  (3 - get_property_int("_brickoEyeSummons")) + " BRICKO&trade; eye bricks obtainable";
				subentry.entries.listAppend("Cast Summon BRICKOs libram. (" + libram_mp_cost + " mp)");
				resource_entries.listAppend(ChecklistEntryMake("__item bricko eye brick", "campground.php?action=bookshelf", subentry, 9));
				
			}
		}
	}
	
	if ((__misc_state["in run"] || true) && availableDrunkenness() >= 0)
	{
		boolean [item] all_possible_bricko_fights = $items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner];
		
		int bricko_potential_fights_available = 0;
		foreach it in $items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner]
		{
			bricko_potential_fights_available += it.available_amount();
		}
		bricko_potential_fights_available = MIN(10 - get_property_int("_brickoFights"), bricko_potential_fights_available);
        if (!in_ronin())
            bricko_potential_fights_available = clampi(10 - get_property_int("_brickoFights"), 0, 10);
		if (bricko_potential_fights_available > 0)
		{
			ChecklistSubentry subentry;
			subentry.header = pluralise(bricko_potential_fights_available, "BRICKO&trade; fight", "BRICKO&trade; fights") + " ready";
			
			
			foreach fight in all_possible_bricko_fights
			{
				int number_available = fight.available_amount();
				if (number_available > 0)
                {
                    string line = pluralise(number_available, fight);
                    
                    if ($items[rock band flyers,jam band flyers].available_amount() > 0 && !__quest_state["Level 12"].state_boolean["Arena Finished"] && __quest_state["Level 12"].in_progress && get_property_int("flyeredML") < 10000)
                    {
                        monster m = fight.to_string().to_monster(); //is there a better way to look this up?
                        line += " (" + m.base_initiative + "% init)";
                    }
					subentry.entries.listAppend(line);
                }
			}
			
			item [int] craftable_fights;
			string [int] creatable;
			foreach fight in all_possible_bricko_fights
			{
                monster m = fight.to_string().to_monster(); //is there a better way to look this up?
				int bricks_needed = get_ingredients_fast(fight)[$item[bricko brick]];
				int monster_level = m.raw_attack;
				int number_available = creatable_amount(fight);
				if (number_available > 0)
				{
					craftable_fights.listAppend(fight);
					creatable.listAppend(pluralise(number_available, fight) + " (" + bricks_needed + " bricks, " + monster_level + "ML)");
				}
			}
			
			if (creatable.count() > 0)
				subentry.entries.listAppend("Creatable: (" + $item[bricko brick].available_amount() + " bricks available)" + HTMLGenerateIndentedText(creatable));
				
			resource_entries.listAppend(ChecklistEntryMake("__item bricko brick", "inventory.php?ftext=bricko", subentry, 7));
		}
	}
}
