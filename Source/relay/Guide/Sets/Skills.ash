
void SSkillsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    string url;
	if (skill_is_usable($skill[inigo's incantation of inspiration]))
	{
		int inigos_casts_remaining = 5 - get_property_int("_inigosCasts");
		string description = "";
		string [int] potential_options;
		if ($item[knob cake].available_amount() == 0 && !__quest_state["Level 6"].finished)
			potential_options.listAppend("knob cake");
		if (__misc_state["can eat just about anything"])
			potential_options.listAppend("food");
		if (__misc_state["can drink just about anything"])
			potential_options.listAppend("drink");
		if (have_skill($skill[advanced saucecrafting]))
			potential_options.listAppend("sauceror potions");
		description = potential_options.listJoinComponents(", ").capitalizeFirstLetter();
		if (inigos_casts_remaining > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__effect Inigo's Incantation of Inspiration", "skills.php", ChecklistSubentryMake(pluralize(inigos_casts_remaining, "Inigo's cast", "Inigo's casts") + " remaining", "", description), 4));
	}
	ChecklistSubentry [int] subentries;
	int importance = 11;
	
	string [skill] skills_to_details;
	string [skill] skills_to_urls;
	skill [string][int] property_summons_to_skills;
	int [string] property_summon_limits;
	
	property_summons_to_skills["reagentSummons"] = listMake($skill[advanced saucecrafting], $skill[the way of sauce]);
	property_summons_to_skills["noodleSummons"] = listMake($skill[Pastamastery], $skill[Transcendental Noodlecraft]);
	property_summons_to_skills["cocktailSummons"] = listMake($skill[Advanced Cocktailcrafting], $skill[Superhuman Cocktailcrafting]);
	property_summons_to_skills["_coldOne"] = listMake($skill[Grab a Cold One]);
	property_summons_to_skills["_spaghettiBreakfast"] = listMake($skill[spaghetti breakfast]);
	property_summons_to_skills["_discoKnife"] = listMake($skill[that's not a knife]);
	property_summons_to_skills["_lunchBreak"] = listMake($skill[lunch break]);
	property_summons_to_skills["_psychokineticHugUsed"] = listMake(lookupSkill("Psychokinetic Hug"));
    
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
    {
		property_summons_to_skills["_petePartyThrown"] = listMake(lookupSkill("Throw Party"));
		property_summons_to_skills["_peteRiotIncited"] = listMake(lookupSkill("Incite Riot"));
        
        int audience_max = 30;
        int hate_useful_max = 25; //ashes and soda max out early; more audience hatred only gives crates and grenades, not of absolute importance
        if (lookupItem("Sneaky Pete's leather jacket").equipped_amount() > 0 || lookupItem("Sneaky Pete's leather jacket (collar popped)").equipped_amount() > 0)
        {
            audience_max = 50;
            hate_useful_max = 41;
        }
            
        
        skills_to_details[lookupSkill("Throw Party")] = "Ideally have " + audience_max + " audience love before casting.";
        skills_to_details[lookupSkill("Incite Riot")] = "Ideally have " + hate_useful_max + " audience hate before casting.";
    }
	//Jarlsberg:
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG)
	{
		property_summons_to_skills["_jarlsCreamSummoned"] = listMake($skill[Conjure Cream]);
		property_summons_to_skills["_jarlsEggsSummoned"] = listMake($skill[Conjure Eggs]);
		property_summons_to_skills["_jarlsDoughSummoned"] = listMake($skill[Conjure Dough]);
		property_summons_to_skills["_jarlsVeggiesSummoned"] = listMake($skill[Conjure Vegetables]);
		property_summons_to_skills["_jarlsCheeseSummoned"] = listMake($skill[Conjure Cheese]);
		property_summons_to_skills["_jarlsPotatoSummoned"] = listMake($skill[Conjure Potato]);
		property_summons_to_skills["_jarlsMeatSummoned"] = listMake($skill[Conjure Meat Product]);
		property_summons_to_skills["_jarlsFruitSummoned"] = listMake($skill[Conjure Fruit]);
	}
	if (my_path_id() == PATH_AVATAR_OF_BORIS)
	{
		property_summons_to_skills["_demandSandwich"] = listMake($skill[Demand Sandwich]);
		property_summon_limits["_demandSandwich"] = 3;
	}
    
	property_summons_to_skills["_requestSandwichSucceeded"] = listMake($skill[Request Sandwich]);
    
    property_summons_to_skills["grimoire1Summons"] = listMake($skill[Summon Hilarious Objects]);
    property_summons_to_skills["grimoire2Summons"] = listMake($skill[Summon Tasteful Items]);
    property_summons_to_skills["grimoire3Summons"] = listMake($skill[Summon Alice's Army Cards]);
    property_summons_to_skills["_grimoireGeekySummons"] = listMake($skill[Summon Geeky Gifts]);
    if (mafiaIsPastRevision(14300))
    {
        property_summons_to_skills["_grimoireConfiscatorSummons"] = listMake(lookupSkill("Summon Confiscated Things"));
        skills_to_urls[lookupSkill("Summon Confiscated Things")] = "campground.php?action=bookshelf";
    }
    property_summons_to_skills["_candySummons"] = listMake($skill[Summon Crimbo Candy]);
    
    foreach s in $skills[Summon Hilarious Objects,Summon Tasteful Items,Summon Alice's Army Cards,Summon Geeky Gifts]
        skills_to_urls[s] = "campground.php?action=bookshelf";
    
	
	
	item summoned_knife = $item[none];
	if (my_level() < 4)
		summoned_knife = $item[boot knife];
	else if (my_level() < 6)
		summoned_knife = $item[broken beer bottle];
	else if (my_level() < 8)
		summoned_knife = $item[sharpened spoon];
	else if (my_level() < 11)
		summoned_knife = $item[candy knife];
	else
		summoned_knife = $item[soap knife];
	if (summoned_knife.available_amount() > 0 && summoned_knife != $item[none])
    {
        //already have the knife, don't annoy them:
        remove property_summons_to_skills["_discoKnife"];
		//skills_to_details[$skill[that's not a knife]] = "Closet " + summoned_knife + " first.";
    }
	
	foreach property in property_summons_to_skills
	{
		if (get_property_int(property) > property_summon_limits[property] || get_property_boolean(property))
			continue;
		foreach key in property_summons_to_skills[property]
		{
			skill s = property_summons_to_skills[property][key];
			if (!s.have_skill())
				continue;
				
			string line = s.to_string();
			string [int] description;
			if (s.mp_cost() > 0)
			{
				line += " (" + s.mp_cost() + " MP)";
				//description.listAppend(s.mp_cost() + " MP");
			}
			string details = skills_to_details[s];
			if (details != "")
				description.listAppend(details);
                
                
            if (url.length() == 0)
            {
                if (skills_to_urls contains s)
                    url = skills_to_urls[s];
                else
                    url = "skills.php";
            }
			
			subentries.listAppend(ChecklistSubentryMake(line, "", description));
			break;
		}
	}
	
	if (subentries.count() > 0)
	{
		subentries.listPrepend(ChecklistSubentryMake("Skill summons:"));
		ChecklistEntry entry = ChecklistEntryMake("__item Knob Goblin love potion", url, subentries, importance);
		entry.should_indent_after_first_subentry = true;
		available_resources_entries.listAppend(entry);
	}
}