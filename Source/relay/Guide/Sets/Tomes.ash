void STomesGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (true)
	{
		ChecklistSubentry [int] subentries;		
		
        if (!can_interact())
        {
            int summons_remaining = 3 - get_property_int("tomeSummons");
            subentries.listAppend(ChecklistSubentryMake(pluralize(summons_remaining, "tome summon", "tome summons") + " remaining", "", ""));
        }
		
		
		int tome_count = 0;
		
		string [skill] tome_summons_property_names;
		tome_summons_property_names[$skill[Summon Smithsness]] = "_smithsnessSummons";
		tome_summons_property_names[$skill[summon clip art]] = "_clipartSummons";
		tome_summons_property_names[$skill[Summon Sugar Sheets]] = "_sugarSummons";
		tome_summons_property_names[$skill[Summon Snowcones]] = "_snowconeSummons";
		tome_summons_property_names[$skill[Summon Stickers]] = "_stickerSummons";
		tome_summons_property_names[$skill[Summon Rad Libs]] = "_radlibSummons";
		
        boolean have_tome_summons = false;
		int [skill] summons_available;
		foreach s in tome_summons_property_names
		{
			string property_name = tome_summons_property_names[s];
			int value = 0;
			if (s.have_skill())
			{
				if (in_ronin())
					value = 3 - get_property_int("tomeSummons");
				else
					value = 3 - get_property_int(property_name);
                if (value > 0)
                    have_tome_summons = true;
			}
			summons_available[s] = value;
		}
        if (!have_tome_summons)
            return;
		
		if (summons_available[$skill[Summon Smithsness]] > 0)
		{
			string [int] description;
			
			string [int] flask_suggestions;
			
			string [int] smithereen_suggestions;
			smithsnessGenerateSmithereensSuggestions(smithereen_suggestions);
			
			
			string [int] coal_suggestions;
			smithsnessGenerateCoalSuggestions(coal_suggestions);
			
			if (true)
			{
                int merry_smithsness_currently_available = $item[flaskfull of hollow].available_amount() * 150 + $effect[merry smithsness].have_effect();
				string building_line = "+25 smithsness (150 turns)";
				if (merry_smithsness_currently_available > 0)
					building_line += " (" + merry_smithsness_currently_available + " turns currently available)";
				flask_suggestions.listAppend(building_line);
				
			}
			
            
            if (__misc_state["In run"])
            {
                description.listAppend("1 Flaskfull of Hollow" + HTMLGenerateIndentedText(flask_suggestions.listJoinComponents("<hr>")));
                description.listAppend("1 Lump of Brituminous coal" + HTMLGenerateIndentedText(coal_suggestions.listJoinComponents("<hr>")));
                description.listAppend("1 Handful of Smithereens" + HTMLGenerateIndentedText(smithereen_suggestions.listJoinComponents("<hr>")));
            }
            else
                description.listAppend("Flaskfull of Hollow, Lump of Brituminous coal, and Handful of Smithereens");

			
			string name = "The Smith's Tome";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Smithsness]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
			
		}
		if (summons_available[$skill[summon clip art]] > 0)
		{
			string [int] description;
            if (__misc_state["in run"])
            {
                if ($item[shining halo].available_amount() == 0 && __misc_state["need to level"])
                    description.listAppend("Shining halo: +3 stats/fight when unarmed");
                if ($item[frosty halo].available_amount() == 0 && $item[a light that never goes out].available_amount() == 0)
                    description.listAppend("Frosty halo: 25% items when unarmed");
                if ($item[furry halo].available_amount() == 0)
                {
                    string line = "Furry halo: +5 familiar weight when unarmed";
                    if (__misc_state["free runs available"])
                        line += " (1 free run/day)";
                    description.listAppend(line);
                }
                if ($item[time halo].available_amount() == 0 && my_daycount() <3 )
                    description.listAppend("Time halo: +5 adventures/day");
                    
                if ($item[bucket of wine].available_amount() == 0 && __misc_state["can drink just about anything"])
                {
                    if (have_skill($skill[the ode to booze]))
                        description.listAppend("Bucket of wine: 28 adventures nightcap with ode");
                    else if (get_property_int("hiddenTavernUnlock") != my_ascensions() && $item[ye olde meade].available_amount() == 0) //just use fog murderers or meade instead, about the same
                        description.listAppend("Bucket of wine: 18 adventures nightcap");
                }
                    
                if (__misc_state["can eat just about anything"] && __misc_state["need to level"])
                    description.listAppend("Ultrafondue: 3 fullness awesome food, +15ML for 30 adventures");
                if (true)
                {
                    string line = "Crystal skull: banish in high monster count zones";
                    if (have_skill($skill[Summon Smithsness]) && !__misc_state["In aftercore"])
                        line += "|*Smith's Tome has a better one";
                    description.listAppend(line);
                }
                if ($item[borrowed time].available_amount() == 0 && !get_property_boolean("_borrowedTimeUsed") && my_daycount() > 1)
                    description.listAppend("Borrowed time: 20 adventures on last day");
                
                string [int] familiar_suggestions;
                if (familiar_is_usable($familiar[he-boulder]) && $item[quadroculars].available_amount() == 0)
                    familiar_suggestions.listAppend("He-Boulder 100-turn YR");
                if (familiar_is_usable($familiar[obtuse angel]) && !familiar_is_usable($familiar[Reanimated Reanimator]))
                    familiar_suggestions.listAppend("+1 angel copy");
                    
                if (familiar_suggestions.count() > 0)
                    description.listAppend("Box of familiar jacks: free familiar equipment (" + listJoinComponents(familiar_suggestions, ", ") + ")");
                else
                    description.listAppend("Box of familiar jacks: free familiar equipment");
            }
			
			string name = "Tome of Clip Art";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Clip Art]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Sugar Sheets]] > 0)
		{
			string [int] description;
            
            SugarGenerateSuggestions(description);
				
			string name = "Tome of Sugar Shummoning";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Sugar Sheets]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Snowcones]] > 0)
		{
			string [int] description;
			//FIXME check this
			
			string name = "Tome of Snowcone Summoning";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Snowcones]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Stickers]] > 0)
		{
			string [int] description;
			//FIXME check this
			
			string name = "Scratch 'n' Sniff Sticker Tome";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Stickers]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Rad Libs]] > 0)
		{
			string [int] description;
			
			//FIXME check this
			
			string name = "Tome of Rad Libs";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Rad Libs]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		
        
        ChecklistEntry entry = ChecklistEntryMake("__item tome of clip art", "campground.php?action=bookshelf", subentries);
        if (!can_interact())
            entry.should_indent_after_first_subentry = true;
        available_resources_entries.listAppend(entry);
	}
}