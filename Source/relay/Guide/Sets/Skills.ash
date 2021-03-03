string [int] SSkillsPotentialCraftingOptions()
{
    string [int] potential_options;
    if ($item[knob cake].available_amount() == 0 && !__quest_state["Level 6"].finished)
        potential_options.listAppend("knob cake");
    if (__misc_state["can eat just about anything"])
        potential_options.listAppend("food");
    if (__misc_state["can drink just about anything"])
        potential_options.listAppend("drink");
    if ($skill[advanced saucecrafting].skill_is_usable())
        potential_options.listAppend("sauceror potions");
    return potential_options;
}


RegisterTaskGenerationFunction("SSkillsGenerateTasks");
void SSkillsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($skill[Lock Picking].skill_is_usable() && !get_property_boolean("lockPicked") && (__quest_state["Level 13"].state_boolean["need to find Boris's key"] || __quest_state["Level 13"].state_boolean["need to find Jarlsberg's key"] || __quest_state["Level 13"].state_boolean["need to find Sneaky Pete's key"]))
    {
    	boolean [item] missing_items;
        if (__quest_state["Level 13"].state_boolean["need to find Boris's key"])
        	missing_items[$item[Boris's key]] = true;
        if (__quest_state["Level 13"].state_boolean["need to find Jarlsberg's key"])
        	missing_items[$item[Jarlsberg's key]] = true;
        if (__quest_state["Level 13"].state_boolean["need to find Sneaky Pete's key"])
        	missing_items[$item[Sneaky Pete's key]] = true;
        
        optional_task_entries.listAppend(ChecklistEntryMake("__skill Lock Picking", "skillz.php", ChecklistSubentryMake("Cast Lock Picking", "", "Collect " + (missing_items.count() > 1 ? "either " : " ") + missing_items.listInvert().listJoinComponents(", ", "or") + "."), 5));
    }
}

void SSkillsGenerateResource(ChecklistEntry [int] resource_entries)
{
    string url;
	if (skill_is_usable($skill[inigo's incantation of inspiration]))
	{
		int inigos_casts_remaining = 5 - get_property_int("_inigosCasts");
		string description = SSkillsPotentialCraftingOptions().listJoinComponents(", ").capitaliseFirstLetter();
		if (inigos_casts_remaining > 0)
			resource_entries.listAppend(ChecklistEntryMake("__effect Inigo's Incantation of Inspiration", "skills.php", ChecklistSubentryMake(pluralise(inigos_casts_remaining, "Inigo's cast", "Inigo's casts") + " remaining", "", description), 10).ChecklistEntrySetCategory("buff"));
	}
	int free_crafts_left = 0;
	if ($effect[Inigo's Incantation of Inspiration].have_effect() >= 5)
	{
        free_crafts_left += $effect[Inigo's Incantation of Inspiration].have_effect() / 5;
	}
    if ($skill[rapid prototyping].skill_is_usable())
    {
        free_crafts_left += clampi(5 - get_property_int("_rapidPrototypingUsed"), 0, 5);
    }
    if ($skill[Expert Corner-Cutter].skill_is_usable())
    {
        free_crafts_left += clampi(5 - get_property_int("_expertCornerCutterUsed"), 0, 5);
    }
    if (free_crafts_left > 0)
    {
        string description = SSkillsPotentialCraftingOptions().listJoinComponents(", ").capitaliseFirstLetter();
        resource_entries.listAppend(ChecklistEntryMake("__item tenderizing hammer", "", ChecklistSubentryMake(pluralise(free_crafts_left, "free craft", "free crafts") + " remaining", "", description), 10));
    }
	ChecklistSubentry [int] subentries;
	int importance = 11;
	
	string [skill] skills_to_details;
	string [skill] skills_to_urls;
    string [skill] skills_to_title_notes;
	skill [string][int] property_summons_to_skills;
	int [string] property_summon_limits;
	
    if ($skill[advanced saucecrafting].have_skill())
        property_summons_to_skills["reagentSummons"] = listMake($skill[advanced saucecrafting], $skill[the way of sauce]);
    if ($skill[Pastamastery].have_skill())
        property_summons_to_skills["noodleSummons"] = listMake($skill[Pastamastery], $skill[Transcendental Noodlecraft]);
    if ($skill[Advanced Cocktailcrafting].have_skill())
        property_summons_to_skills["cocktailSummons"] = listMake($skill[Advanced Cocktailcrafting], $skill[Superhuman Cocktailcrafting]);
	property_summons_to_skills["_coldOne"] = listMake($skill[Grab a Cold One]);
	property_summons_to_skills["_spaghettiBreakfast"] = listMake($skill[spaghetti breakfast]);
	property_summons_to_skills["_discoKnife"] = listMake($skill[that's not a knife]);
	property_summons_to_skills["_lunchBreak"] = listMake($skill[lunch break]);
	property_summons_to_skills["_psychokineticHugUsed"] = listMake($skill[Psychokinetic Hug]);
	property_summons_to_skills["_pirateBellowUsed"] = listMake($skill[Pirate Bellow]);
	property_summons_to_skills["_holidayFunUsed"] = listMake($skill[Summon Holiday Fun!]);
	property_summons_to_skills["_summonCarrotUsed"] = listMake($skill[Summon Carrot]);
	property_summons_to_skills["_summonAnnoyanceUsed"] = listMake($skill[summon annoyance]);
    property_summons_to_skills["_perfectFreezeUsed"] = listMake($skill[Perfect Freeze]);
    property_summons_to_skills["_communismUsed"] = listMake($skill[Communism!]);
    property_summons_to_skills["_preventScurvy"] = listMake($skill[Prevent Scurvy and Sobriety]);
    
    skills_to_title_notes[$skill[summon annoyance]] = get_property_int("summonAnnoyanceCost") + " swagger";
    
    
    
    
    
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
    {
		property_summons_to_skills["_petePartyThrown"] = listMake($skill[Throw Party]);
		property_summons_to_skills["_peteRiotIncited"] = listMake($skill[Incite Riot]);
        
        int audience_max = 30;
        int hate_useful_max = 25; //ashes and soda max out early; more audience hatred only gives crates and grenades, not of absolute importance
        if ($item[Sneaky Pete's leather jacket].equipped_amount() > 0 || $item[Sneaky Pete's leather jacket (collar popped)].equipped_amount() > 0)
        {
            audience_max = 50;
            hate_useful_max = 41;
        }
            
        if (my_audience() < audience_max)
            skills_to_details[$skill[Throw Party]] = "Ideally have " + audience_max + " audience love before casting.";
        else
            skills_to_details[$skill[Throw Party]] = "Gain party supplies.";
        
        if (my_audience() > -hate_useful_max)
            skills_to_details[$skill[Incite Riot]] = "Ideally have " + hate_useful_max + " audience hate before casting.";
        else
            skills_to_details[$skill[Incite Riot]] = "This fire is out of control";
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
    property_summons_to_skills["_grimoireConfiscatorSummons"] = listMake($skill[Summon Confiscated Things]);
    skills_to_urls[$skill[Summon Confiscated Things]] = "campground.php?action=bookshelf";
    property_summons_to_skills["_candySummons"] = listMake($skill[Summon Crimbo Candy]);
    property_summons_to_skills["_summonResortPassUsed"] = listMake($skill[Summon Kokomo Resort Pass]);
    property_summons_to_skills["_incredibleSelfEsteemCast"] = listMake($skill[Incredible Self-Esteem]);
    skills_to_details[$skill[Incredible Self-Esteem]] = "Gives or extends affirmation buffs.";
    if (__misc_state["in run"] && $item[Daily Affirmation: Always be Collecting].available_amount() > 0 && $item[Daily Affirmation: Always be Collecting].to_effect().have_effect() == 0)
        skills_to_details[$skill[Incredible Self-Esteem]] += "|Possibly use Always be Collecting affirmation before casting.";
    
    foreach s in $skills[Summon Hilarious Objects,Summon Tasteful Items,Summon Alice's Army Cards,Summon Geeky Gifts]
        skills_to_urls[s] = "campground.php?action=bookshelf";
    
	
	
    int muscle_basestat = my_basestat($stat[muscle]);
	item summoned_knife = $item[none];
	if (muscle_basestat < 10)
		summoned_knife = $item[boot knife];
	else if (muscle_basestat < 20)
		summoned_knife = $item[broken beer bottle];
	else if (muscle_basestat < 40)
		summoned_knife = $item[sharpened spoon];
	else if (muscle_basestat < 60)
		summoned_knife = $item[candy knife];
	else
		summoned_knife = $item[soap knife];
	if (summoned_knife.available_amount() > 0 && summoned_knife != $item[none])
    {
        //already have the knife, don't annoy them:
        //(or ask them to closet the knife?)
        remove property_summons_to_skills["_discoKnife"];
		//skills_to_details[$skill[that's not a knife]] = "Closet " + summoned_knife + " first.";
    }
	
	foreach property in property_summons_to_skills
	{
		if (get_property_int(property) >= property_summon_limits[property] || get_property_boolean(property))
			continue;
		foreach key in property_summons_to_skills[property]
		{
			skill s = property_summons_to_skills[property][key];
			if (!s.skill_is_usable())
				continue;
				
			string line = s.to_string();
			string [int] description;
			if (s.mp_cost() > 0)
			{
				line += " (" + s.mp_cost() + " MP)";
				//description.listAppend(s.mp_cost() + " MP");
			}
            if (skills_to_title_notes contains s)
            {
				line += " (" + skills_to_title_notes[s] + " )";
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
		resource_entries.listAppend(entry);
	}

    
    if ($skill[Evoke Eldritch Horror].skill_is_usable() && !get_property_boolean("_eldritchHorrorEvoked"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__skill Evoke Eldritch Horror", "skillz.php", ChecklistSubentryMake("Evoke Eldritch Horror", "", "Free fight."), 5).ChecklistEntryTag("daily free fight"));
    }
    if (!get_property_boolean("_eldritchTentacleFought") && my_path_id() != PATH_EXPLOSIONS)
    {
        resource_entries.listAppend(ChecklistEntryMake("__skill Evoke Eldritch Horror", "place.php?whichplace=forestvillage", ChecklistSubentryMake("Free Science Tent Tentacle fight", "", ""), 5).ChecklistEntryTag("daily free fight"));
    }
}
