import "relay/Guide/Support/Checklist.ash";
import "relay/Guide/QuestState.ash";
import "relay/Guide/Sets.ash";

void generateMissingItems(Checklist [int] checklists)
{
	ChecklistEntry [int] items_needed_entries;
	
	if (!__misc_state["In run"])
		return;
	
    //thought about using getClickableURLForLocationIfAvailable for these, but our location detection is very poor, and there are corner cases regardless
	
	if (__misc_state["wand of nagamar needed"])
	{
		ChecklistSubentry [int] subentries;
		
		subentries[subentries.count()] = ChecklistSubentryMake("Wand of Nagamar", "", "");
		
		if (__misc_state_int["ruby w needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("ruby W", "Clover or +234% item", listMake("Clover the castle basement", "W Imp - Dark Neck of the Woods/Pandamonium Slums - 30% drop"));
		if (__misc_state_int["metallic a needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("metallic A", "Clover or +234% item", listMake("Clover the castle basement", "MagiMechTech MechaMech - Penultimate Fantasy Airship - 30% drop"));
		if (__misc_state_int["lowercase n needed"] > 0 && __misc_state_int["lowercase n available"] == 0)
		{
			string name = "lowercase N";
			subentries[subentries.count()] = ChecklistSubentryMake(name, "Clover or +234% item", listMake("Clover the castle basement", "XXX pr0n - Valley of Rof L'm Fao - 30% drop"));
		}
		if (__misc_state_int["heavy d needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("heavy D", "Clover or +150% item", listMake("Clover the castle basement", "Alphabet Giant - Castle Basement - 40% drop"));
			
		ChecklistEntry entry = ChecklistEntryMake("__item wand of nagamar", $location[the castle in the clouds in the sky (basement)].getClickableURLForLocation(), subentries);
		entry.should_indent_after_first_subentry = true;
		
		items_needed_entries.listAppend(entry);
	}
	
	if (!__quest_state["Level 13"].state_boolean["past keys"])
	{
		//Key items:
		if (!__quest_state["Level 13"].state_boolean["have relevant guitar"])
		{
			string [int] guitar_options;
			guitar_options.listAppend("For gate mariachis");
			if (__misc_state_int["pulls available"] > 0)
				guitar_options.listAppend("Pull");
			guitar_options.listAppend("Acoustic guitar - 20% drop, grungy pirate, belowdecks (4 monster location, yellow ray?)");
			guitar_options.listAppend("Stone banjo - one clover");
			guitar_options.listAppend("Massive sitar - hippy war store");
			if (my_class() == $class[Turtle tamer])
				guitar_options.listAppend("Dueling banjo - tame a turtle at whitey's grove");
			if (my_primestat() == $stat[muscle])
				guitar_options.listAppend("4-dimensional guitar - 5% drop, cubist bull, haunted gallery (yellow ray?)");
				
			items_needed_entries.listAppend(ChecklistEntryMake("__item Acoustic guitarrr", "", ChecklistSubentryMake("Guitar", "", guitar_options)));
		}
		
		if (!__quest_state["Level 13"].state_boolean["have relevant accordion"])
		{
            string url = "store.php?whichstore=z";
            string accordion_source = "Toy accordion, 150 meat";
            if (my_path_id() == PATH_ZOMBIE_SLAYER)
            {
                accordion_source = "Stolen accordion, from chewing gum on a string";
                url = "store.php?whichstore=m";
            }
			items_needed_entries.listAppend(ChecklistEntryMake("__item stolen accordion", url, ChecklistSubentryMake("Accordion", "", accordion_source)));
		}
		
		if (!__quest_state["Level 13"].state_boolean["have relevant drum"])
		{
			string [int] suggestions;
			suggestions.listAppend("Black kettle drum (black forest NC)");
			if ($item[broken skull].available_amount() > 0)
				suggestions.listAppend("Bone rattle (skeleton bone + broken skull)");
			suggestions.listAppend("Jungle drum (pygmy assault squad, hidden park, 10% drop)");
			suggestions.listAppend("Hippy bongo (YR hippy)");
			suggestions.listAppend("tambourine?");
			items_needed_entries.listAppend(ChecklistEntryMake("__item hippy bongo", $location[the black forest].getClickableURLForLocation(), ChecklistSubentryMake("Drum", "", suggestions)));
		}
		
		if ($item[skeleton key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["past keys"])
		{
			string line = "loose teeth";
			if ($item[loose teeth].available_amount() == 0)
				line += " (need)";
			else
				line += " (have)";
			line += " + skeleton bone";
			if ($item[skeleton bone].available_amount() == 0)
				line += " (need)";
			else
				line += " (have)";
			items_needed_entries.listAppend(ChecklistEntryMake("__item skeleton key", $location[the defiled nook].getClickableURLForLocation(), ChecklistSubentryMake("Skeleton key", "", line)));
		}
		
		if ($item[digital key].available_amount() == 0)
		{
			string [int] options;
            if ($item[digital key].creatable_amount() > 0)
            {
                options.listAppend("Have enough pixels, make it.");
            }
            else
            {
                options.listAppend("Fear man's level (jar)");
                if (__misc_state["fax accessible"] && in_hardcore()) //not suggesting this in SC
                    options.listAppend("Fax/copy a ghost");
                options.listAppend("8-bit realm (olfact blooper, slow)");
            }
            //FIXME URL?
			items_needed_entries.listAppend(ChecklistEntryMake("__item digital key", "", ChecklistSubentryMake("Digital key", "", options)));
		}
		string from_daily_dungeon_string = "From daily dungeon";
		if ($item[fat loot token].available_amount() > 0)
			from_daily_dungeon_string += "|" + pluralize($item[fat loot token]) + " available";
		if ($item[sneaky pete's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Sneaky Pete's key", "da.php", ChecklistSubentryMake("Sneaky Pete's key", "", options)));
		}
		if ($item[jarlsberg's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item jarlsberg's key", "da.php", ChecklistSubentryMake("Jarlsberg's key", "", options)));
		}
		if ($item[Boris's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Boris's key", "da.php", ChecklistSubentryMake("Boris's key", "", options)));
		}
	}
	
	//Tower items:
	if (!__quest_state["Level 13"].state_boolean["past tower"])
	{
		string [item] telescope_item_suggestions;
        
        string [item] telescope_item_url;
		
		//FIXME support __misc_state["can use clovers"] for these
		telescope_item_suggestions[$item[mick's icyvapohotness rub]] = "Raver giant, top floor of castle, 30% drop";
		telescope_item_suggestions[$item[leftovers of indeterminate origin]] = "Demonic icebox, haunted kitchen (5 monster location), 40% drop|Or clover haunted kitchen";
		telescope_item_suggestions[$item[NG]] = "Clover castle basement";
		telescope_item_suggestions[$item[adder bladder]] = "Black adder, black forest, 30% drop";
		telescope_item_suggestions[$item[plot hole]] = "Possibility giant, castle ground floor, 20% drop";
		telescope_item_suggestions[$item[chaos butterfly]] = "Possibility giant, castle ground floor, 20% drop";
		telescope_item_suggestions[$item[pygmy pygment]] = "Pygmy assault squad, hidden park, 25% drop";
		telescope_item_suggestions[$item[baseball]] = "Baseball bat, guano junction, 30% drop, 6 monsters (i.e. a lot)|Clover guano junction if you have any sonars-in-a-biscuit";
		telescope_item_suggestions[$item[frigid ninja stars]] = "Any ninja, Lair of the Ninja Snowmen, 20% drop";
		telescope_item_suggestions[$item[hair spray]] = "General store";
		
		telescope_item_suggestions[$item[spider web]] = "Spiders, sleazy back alley, 25% drop (2x)";
		
		
		telescope_item_suggestions[$item[black pepper]] = "Black picnic basket, black widow, black forest, 15% drop.|46%? open success rate.|Possibly clover black forest for one basket.|Possibly zap ancient spice/dehydrated caviar for it.";
		telescope_item_suggestions[$item[powdered organs]] = "Canopic jar, Tomb servant, Upper/Middle chamber, 30% drop.|~50% open success rate.";
		
		telescope_item_suggestions[$item[photoprotoneutron torpedo]] = "MagiMechTech MechaMech, fantasy airship, 30% drop";
		
		telescope_item_suggestions[$item[wussiness potion]] = "W imp, Dark Neck of the Woods/Pandamonium slums, 30% drop";
		
		telescope_item_suggestions[$item[gremlin juice]] = "Any gremlin, Junkyard, 3% drop (yellow ray)";
		telescope_item_suggestions[$item[Angry Farmer candy]] = "Need sugar rush";
		
        if (gnomads_available())
            telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Marzipan skull, bought from Gno-Mart";
		if (have_skill($skill[summon crimbo candy]))
			telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Summon crimbo candy";
		else if (have_skill($skill[candyblast]))
			telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Cast candyblast";
		else
			telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Raver giant, castle top floor, 30% drop"; //FIXME we need sugar rush, not angry farmer candy.
		telescope_item_suggestions[$item[thin black candle]] = "Goth Giant, Castle Top Floor, 30% drop|Non-combat on top floor. (slow)";
		telescope_item_suggestions[$item[super-spiky hair gel]] = "Protagonist, Penultimate Fantasy Airship, 20% drop";
		telescope_item_suggestions[$item[Black No. 2]] = "Black panther, black forest, 20% drop";
		telescope_item_suggestions[$item[Sonar-in-a-biscuit]] = "Bats, Batrat and Ratbat Burrow, 15% drop|Clover Guano Junction";
		telescope_item_suggestions[$item[Pygmy blowgun]] = "Pygmy blowgunner, hidden park, 30% drop";
		telescope_item_suggestions[$item[Meat vortex]] = "Me4t begZ0r, The Valley of Rof L'm Fao (7 monster location), 100% drop";
		telescope_item_suggestions[$item[Fancy bath salts]] = "Claw-foot bathtub, haunted bathroom, 35% drop";
		telescope_item_suggestions[$item[inkwell]] = "Writing desk, haunted library, 30% drop";
		telescope_item_suggestions[$item[disease]] = "Knob Goblin Harem Girl, Harem, 10% drop (YR)";
		if (locationAvailable($location[the "fun" house]))
			telescope_item_suggestions[$item[disease]] += "|Disease-in-the-box, fun house (6 monsters), 40% drop";
		telescope_item_suggestions[$item[bronzed locust]] = "Plaque of locusts, extra-dry desert, 20% drop";
		telescope_item_suggestions[$item[Knob Goblin firecracker]] = "Sub-Assistant Knob Mad Scientist, Outskirts of Cobb's Knob, 100% drop";
		telescope_item_suggestions[$item[mariachi G-string]] = "Irate mariachi, South of The Border, 30% drop (5 monster location, run +combat)";
		telescope_item_suggestions[$item[razor-sharp can lid]] = "Can of asparagus/can of tomatoes, Haunted Pantry, 40%/45% drop|NC in haunted pantry";
		
		
		
		telescope_item_suggestions[$item[tropical orchid]] = "Tropical island souvenir crate (vacation)";
		telescope_item_suggestions[$item[stick of dynamite]] = "Dude ranch souvenir crate (vacation)";
		telescope_item_suggestions[$item[barbed-wire fence]] = "Ski resort souvenir crate (vacation)";
        
        
        telescope_item_url[$item[razor-sharp can lid]] = $location[the haunted pantry].getClickableURLForLocation();
        telescope_item_url[$item[spider web]] = $location[the sleazy back alley].getClickableURLForLocation();
        telescope_item_url[$item[frigid ninja stars]] = $location[lair of the ninja snowmen].getClickableURLForLocation();
        telescope_item_url[$item[hair spray]] = "store.php?whichstore=m";
        telescope_item_url[$item[baseball]] = $location[guano junction].getClickableURLForLocation();
        telescope_item_url[$item[sonar-in-a-biscuit]] = $location[the batrat and ratbat burrow].getClickableURLForLocation();
        telescope_item_url[$item[NG]] = $location[the castle in the clouds in the sky (basement)].getClickableURLForLocation();
        telescope_item_url[$item[disease]] = $location[cobb's knob harem].getClickableURLForLocation();
        telescope_item_url[$item[photoprotoneutron torpedo]] = $location[the penultimate fantasy airship].getClickableURLForLocation();
        telescope_item_url[$item[chaos butterfly]] = $location[the castle in the clouds in the sky (ground floor)].getClickableURLForLocation();
        telescope_item_url[$item[leftovers of indeterminate origin]] = $location[the haunted kitchen].getClickableURLForLocation();
        telescope_item_url[$item[powdered organs]] = $location[the upper chamber].getClickableURLForLocation();
        telescope_item_url[$item[plot hole]] = $location[the castle in the clouds in the sky (ground floor)].getClickableURLForLocation();
        telescope_item_url[$item[inkwell]] = $location[the haunted library].getClickableURLForLocation();
        telescope_item_url[$item[Knob Goblin firecracker]] = $location[the outskirts of cobb's knob].getClickableURLForLocation();
        telescope_item_url[$item[mariachi G-string]] = $location[south of the border].getClickableURLForLocation();
        telescope_item_url[$item[pygmy blowgun]] = $location[the hidden park].getClickableURLForLocation();
        telescope_item_url[$item[fancy bath salts]] = $location[the haunted bathroom].getClickableURLForLocation();
        telescope_item_url[$item[black pepper]] = $location[the black forest].getClickableURLForLocation();
        telescope_item_url[$item[bronzed locust]] = $location[the arid\, extra-dry desert].getClickableURLForLocation();
        telescope_item_url[$item[meat vortex]] = $location[The valley of rof l'm fao].getClickableURLForLocation();
        telescope_item_url[$item[barbed-wire fence]] = $location[The Shore\, Inc. Travel Agency].getClickableURLForLocation();
        telescope_item_url[$item[stick of dynamite]] = $location[The Shore\, Inc. Travel Agency].getClickableURLForLocation();
        telescope_item_url[$item[tropical orchid]] = $location[The Shore\, Inc. Travel Agency].getClickableURLForLocation();
        if (__quest_state["Level 6"].finished)
            telescope_item_url[$item[wussiness potion]] = $location[pandamonium slums].getClickableURLForLocation();
        else
            telescope_item_url[$item[wussiness potion]] = $location[The Dark Neck of the Woods].getClickableURLForLocation();
        if (__quest_state["Level 12"].finished)
            telescope_item_url[$item[gremlin juice]] = $location[post-war junkyard].getClickableURLForLocation();
        else
            telescope_item_url[$item[gremlin juice]] = $location[next to that barrel with something burning in it].getClickableURLForLocation();
        if (gnomads_available())
            telescope_item_url[$item[Angry Farmer candy]] = ""; //need the URL to gno-mart
        else
            telescope_item_url[$item[Angry Farmer candy]] = $location[the castle in the clouds in the sky (top floor)].getClickableURLForLocation();
        telescope_item_url[$item[thin black candle]] = $location[the castle in the clouds in the sky (top floor)].getClickableURLForLocation();
        telescope_item_url[$item[Mick's IcyVapoHotness Rub]] = $location[the castle in the clouds in the sky (basement)].getClickableURLForLocation();
        telescope_item_url[$item[pygmy pygment]] = $location[the hidden park].getClickableURLForLocation();
        telescope_item_url[$item[super-spiky hair gel]] = $location[the penultimate fantasy airship].getClickableURLForLocation();
        telescope_item_url[$item[adder bladder]] = $location[the black forest].getClickableURLForLocation();
        telescope_item_url[$item[Black No. 2]] = $location[the black forest].getClickableURLForLocation();
        
		
		if (familiar_is_usable($familiar[gelatinous cubeling]))
		{
			foreach it in $items[knob goblin firecracker,razor-sharp can lid,spider web]
			{
				if (it == $item[none])
					continue;
				telescope_item_suggestions[it] += "|Or potentially bring along the gelatinous cubeling.";
			}
		}
		
		QuestState ns13_quest = __quest_state["Level 13"];
		
		string [int] state_strings;
		string [int] state_ns13_lookup_booleans;
		if (!ns13_quest.state_boolean["past gates"])
			state_strings.listAppend("Gate item");
		state_ns13_lookup_booleans.listAppend("Past gate");
        if (!__quest_state["Level 13"].state_boolean["past tower"])
        {
            for i from 1 to 6
            {
                state_strings.listAppend("Tower monster item " + i);
                state_ns13_lookup_booleans.listAppend("Past tower monster " + i);
            }
        }
		
		item [item][int] item_equivalents_lookup;
		item_equivalents_lookup[$item[angry farmer candy]] = listMakeBlankItem();
        foreach it in $items[that gum you like,Crimbo fudge,Crimbo peppermint bark,Crimbo candied pecan,cold hots candy,Daffy Taffy,Senior Mints,Wint-O-Fresh mint,stick of &quot;gum&quot;,pack of KWE trading card]
            item_equivalents_lookup[$item[angry farmer candy]].listAppend(it);
		
		int [item] towergate_items_needed_count; //bees hate you has duplicates
		foreach i in state_strings
		{
			if (ns13_quest.state_boolean[state_ns13_lookup_booleans[i]])
				continue;
			
			item it = __misc_state_string[state_strings[i]].to_item();
			
			if (it == $item[none])
			{
				string subentry_string = "Or towerkill";
				if (state_strings[i] == "Gate item")
					subentry_string = "";
				//unknown
                //FIXME mention looking into your telescope on the first entry
				items_needed_entries.listAppend(ChecklistEntryMake("Unknown", "", ChecklistSubentryMake("Unknown " + to_lower_case(state_strings[i]), "", subentry_string)));
			}
			else
			{
				int total_available_amount = it.available_amount() + closet_amount(it) - towergate_items_needed_count[it];
				
				if (item_equivalents_lookup[it].count() > 0)
				{
					foreach key in item_equivalents_lookup[it]
					{
						item it2 = item_equivalents_lookup[it][key];
						total_available_amount += it2.available_amount() + closet_amount(it2);
					}
				}
				if (total_available_amount <= 0)
				{
					string [int] details;
					if (state_strings[i] == "Gate item")
						details.listAppend("Gate item");
					else
						details.listAppend("Tower item - towerkill?");
					if (telescope_item_suggestions contains it)
						details.listAppend(telescope_item_suggestions[it]);
                    string url = "";
                    if (telescope_item_url contains it)
                        url = telescope_item_url[it];
                    
					items_needed_entries.listAppend(ChecklistEntryMake(it, url, ChecklistSubentryMake(it, "", details)));
				}
				
			}
			towergate_items_needed_count[it] = towergate_items_needed_count[it] + 1;
		}
	}
    
    if (true)
    {
        FloatHandle missing_weight;
        string [int] familiar_weight_how;
        string [int] familiar_weight_immediately_obtainable;
        string [int] familiar_weight_missing_potentials;
        boolean have_familiar_weight_for_tower = generateTowerFamiliarWeightMethod(familiar_weight_how, familiar_weight_immediately_obtainable, familiar_weight_missing_potentials,missing_weight);
        if (!have_familiar_weight_for_tower)
        {
            string [int] description;
            description.listAppend("For the sorceress's tower familiars.");
            if (familiar_weight_how.count() > 0)
                description.listAppend("Have " + familiar_weight_how.listJoinComponents(", ", "and") + ".");
            if (familiar_weight_immediately_obtainable.count() > 0)
                description.listAppend("Could use " + familiar_weight_immediately_obtainable.listJoinComponents(", ", "and") + ".");
            if (familiar_weight_missing_potentials.count() > 0)
                description.listAppend("Could acquire " + familiar_weight_missing_potentials.listJoinComponents(", ", "or") + ".");
            
            items_needed_entries.listAppend(ChecklistEntryMake("__familiar Sabre-Toothed Lime", "", ChecklistSubentryMake("+" + missing_weight.f.ceil() + " familiar weight buffs", "", description)));
        }
    }
	
	if ($item[lord spookyraven's spectacles].available_amount() == 0 && __quest_state["Level 11 Manor"].state_boolean["Can use fast route"] && !__quest_state["Level 11 Manor"].finished)
		items_needed_entries.listAppend(ChecklistEntryMake("__item lord spookyraven's spectacles", $location[the haunted bedroom].getClickableURLForLocation(), ChecklistSubentryMake("lord spookyraven's spectacles", "", "Found in Haunted Bedroom")));
    
    if ($item[enchanted bean].available_amount() == 0 && !__quest_state["Level 10"].state_boolean["Beanstalk grown"])
    {
		items_needed_entries.listAppend(ChecklistEntryMake("__item enchanted bean", $location[The Beanbat Chamber].getClickableURLForLocation(), ChecklistSubentryMake("Enchanted bean", "", "Found in the beanbat chamber.")));
    }
    
    if (__quest_state["Level 13"].state_boolean["shadow will need to be defeated"])
    {
        //Let's see
        //5 gauze garters + filthy poultices
        //Or...
        //red pixel potion (not worth farming, but if they have it...)
        //red potion
        //extra-strength red potion (they might find it)
        
    }
    if (__quest_state["Level 11 Palindome"].state_boolean["Need instant camera"])
    {
        item camera = 7266.to_item();
        if (camera != $item[none])
        {
            items_needed_entries.listAppend(ChecklistEntryMake("__item " + camera, $location[the haunted bedroom].getClickableURLForLocation(), ChecklistSubentryMake("Disposable instant camera", "", "Found in the Haunted Bedroom.")));
        }
    }
                               
    SetsGenerateMissingItems(items_needed_entries);
	
	checklists.listAppend(ChecklistMake("Required Items", items_needed_entries));
}