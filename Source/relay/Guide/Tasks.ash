import "relay/Guide/Support/Checklist.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Plants.ash"
import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Sets.ash"

void generateTasks(Checklist [int] checklists)
{
	ChecklistEntry [int] task_entries;
	
	ChecklistEntry [int] optional_task_entries;
		
	ChecklistEntry [int] future_task_entries;
	
	
	//Friar:
	if (florist_available())
	{
        string image_name = "sunflower face";
		ChecklistSubentry subentry;
		subentry.header = "Plant florist plants in " + __last_adventure_location;
        
        PlantSuggestion [int] area_relevant_suggestions;
		foreach key, suggestion in __plants_suggested_locations
		{
			
			if (suggestion.loc != __last_adventure_location)
				continue;
            
            area_relevant_suggestions.listAppend(suggestion);
        }
        
        boolean single_mode_only = false;
        if (area_relevant_suggestions.count() == 1)
        {
            single_mode_only = true;
			PlantSuggestion suggestion = area_relevant_suggestions[0];
			string plant_name = suggestion.plant_name.capitaliseFirstLetter();
        
            subentry.header = "Plant " + plant_name + " in " + __last_adventure_location;
        }
		
		foreach key, suggestion in area_relevant_suggestions
		{
			string plant_name = suggestion.plant_name.capitaliseFirstLetter();
			Plant plant = __plant_properties[plant_name];
			
			string line;
            
            if (single_mode_only)
            {
                line = plant.zone_effect + ", " + plant.terrain;
                if (plant.territorial)
                    line = line + ", territorial";
                
                if (suggestion.details != "")
                    line += "|*" + suggestion.details;
            }
            else
            {
                line = plant_name + " (" + plant.zone_effect + ", " + plant.terrain;
                if (plant.territorial)
                    line = line + ", territorial";
                
                line += ")";
                if (suggestion.details != "")
                    line += "|*" + suggestion.details;
            }
			
            if (plant_name == "War Lily" || plant_name == "Rabid Dogwood" || plant_name == "Blustery Puffball")
            {
                if (monster_level_adjustment() + 30 > 150)
                {
                    //subentry.header = "Optionally plant florist plants in " + __last_adventure_location;
                    image_name = "__item pirate fledges";
                    
                    subentry.header += "?";
                    line += "|" + HTMLGenerateSpanFont("Very dangerous", "red") + ", monsters ";
                    if (monster_level_adjustment() > 150)
                        line += "are";
                    else
                        line += "will be";
                    line += " stagger immune.";
                }
            }
            
			subentry.entries.listAppend(line);
		}
		if (subentry.entries.count() > 0)
			task_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry, -11));
	}
	
	QuestsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
	if (!__misc_state["desert beach available"] && __misc_state["in run"])
	{
        string url;
		ChecklistSubentry subentry;
        boolean optional = false;
		subentry.header = "Unlock desert beach";
        boolean [location] relevant_locations;
        if (my_path_id() == PATH_COMMUNITY_SERVICE)
        {
            subentry.header = "Optionally unlock desert beach";
            subentry.entries.listAppend("Not needed to finish path.");
            optional = true;
        }
		if (!knoll_available())
		{
            relevant_locations[$location[the degrassi knoll garage]] = true;
			string meatcar_line = "Build a bitchin' meatcar.";
			if ($item[bitchin' meatcar].creatable_amount() > 0)
				meatcar_line += "|*You have all the parts, build it!";
			else
			{
				item [int] missing_parts_list = missingComponentsToMakeItem($item[bitchin' meatcar]);
                boolean [item] missing_parts = missing_parts_list.listInvert();
                
                //Tires - 100% drop - Gnollish Tirejuggler in The Degrassi Knoll Garage
                //empty meat tank, cog, spring, sprocket - Gnollish toolbox - Gnollish Gearhead in The Degrassi Knoll Garage
                //
                string [int] meatcar_modifiers;
                if (missing_parts[$item[empty meat tank]] || missing_parts[$item[cog]] || missing_parts[$item[spring]] || missing_parts[$item[sprocket]])
                {
                    meatcar_modifiers.listAppend("+34% item");
                    meatcar_modifiers.listAppend("olfact gnollish gearhead");
                }
                
                    
                meatcar_modifiers.listAppend("banish guard bugbear");
                    
                if (meatcar_modifiers.count() > 0)
                    meatcar_line += "|*" + ChecklistGenerateModifierSpan(meatcar_modifiers);
				
				meatcar_line += "|*Parts needed: " + missing_parts_list.listJoinComponents(", ", "and") + ".";
                if (missing_parts[$item[tires]] || missing_parts[$item[empty meat tank]] || missing_parts[$item[cog]] || missing_parts[$item[spring]] || missing_parts[$item[sprocket]])
                    meatcar_line += " (found in the degrassi knoll garage?)";
			}
			subentry.entries.listAppend(meatcar_line);
			
            if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
                subentry.entries.listAppend("Or buy a desert bus pass. (5000 meat)");
			if ($item[pumpkin].available_amount() > 0)
				subentry.entries.listAppend("Or build a pumpkin carriage.");
            if ($items[can of Br&uuml;talbr&auml;u,can of Drooling Monk,can of Impetuous Scofflaw,fancy tin beer can].available_amount() > 0)
				subentry.entries.listAppend("Or build a tin lizzie.");
            url = "place.php?whichplace=knoll_hostile";
		}
		else
		{
            url = "shop.php?whichshop=gnoll";
			int meatcar_price = $item[spring].npc_price() + $item[sprocket].npc_price() + $item[cog].npc_price() + $item[empty meat tank].npc_price() + 100 + $item[tires].npc_price() + $item[sweet rims].npc_price() + $item[spring].npc_price();
			subentry.entries.listAppend("Build a bitchin' meatcar. (" + meatcar_price + " meat)");
		}
		
        ChecklistEntry entry = ChecklistEntryMake("__item bitchin' meatcar", url, subentry, relevant_locations);
        if (optional)
            optional_task_entries.listAppend(entry);
        else
            task_entries.listAppend(entry);
	}
	else if (!__misc_state["mysterious island available"] && __misc_state["in run"])
	{
		ChecklistSubentry subentry;
		subentry.header = "Unlock mysterious island";
		
		int scrip_number = $item[Shore Inc. Ship Trip Scrip].available_amount();
		int trips_needed = MAX(0, 3 - scrip_number);
        
        string url = "place.php?whichplace=desertbeach";
        
		if ($item[dinghy plans].available_amount() > 0)
        {
            if ($item[dingy planks].available_amount() > 0)
            {
                url = "inventory.php?which=3";
                subentry.entries.listAppend("Use dinghy plans.");
            }
            else
            {
                url = "shop.php?whichshop=generalstore";
                subentry.entries.listAppend("Buy dingy planks, then build dinghy dinghy.");
            }
                
        }
		else if (trips_needed > 0)
		{
            int trip_adventure_cost = 3;
            int trip_meat_cost = 500;
            if (my_path_id() == PATH_WAY_OF_THE_SURPRISING_FIST)
            {
                trip_adventure_cost = 5;
                trip_meat_cost = 5;
            }
			string line_string = "Shore, " + (trip_adventure_cost * trips_needed) + " adventures";
			int meat_needed = trip_meat_cost * trips_needed;
			if (my_meat() < meat_needed)
				line_string += "|Need " + meat_needed + " meat for vacations, have " + my_meat() + ".";
			subentry.entries.listAppend(line_string);
            if ($item[skeleton].available_amount() > 0)
                subentry.entries.listAppend("Skeletal skiff?");
            
            //Think this is slower, so don't suggest:
            /*line_string = "Or try the hippy quest in the woods";
            if (my_basestat(my_primesubstat()) < 25)
                line_string += ", once your mainstat reaches 25";
            line_string += ". (probably slower?)";
            subentry.entries.listAppend(line_string);*/
		}
		else
		{
            url = "shop.php?whichshop=shore";
			subentry.entries.listAppend("Redeem scrip at shore for dinghy plans.");
		}
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeGasTank").length() == 0)
            subentry.entries.listAppend("Possibly upgrade your motorcycle's gas tank. (extra-buoyant)");
		task_entries.listAppend(ChecklistEntryMake("__item dingy dinghy", url, subentry, $locations[the shore\, inc. travel agency]));
	}
	
	
	if (__misc_state["need to level"] && my_path_id() != PATH_COMMUNITY_SERVICE)
	{
		ChecklistSubentry subentry;
		
		int main_substats = my_basestat(my_primesubstat());
		int substats_remaining = substatsForLevel(my_level() + 1) - main_substats;
		
		subentry.header = "Level to " + (my_level() + 1);
		
		subentry.entries.listAppend("Gain " + pluralise(substats_remaining, "substat", "substats") + ".");
        
        string url = "";
        
        boolean spooky_airport_unlocked = __misc_state["spooky airport available"];
        boolean stench_airport_unlocked = __misc_state["stench airport available"];
        
        if (__misc_state["Chateau Mantegna available"] && __misc_state_int["free rests remaining"] > 0)
            url = "place.php?whichplace=chateau";
        else if (stench_airport_unlocked && monster_level_adjustment() >= 150)
            url = $location[Uncle Gator's Country Fun-Time Liquid Waste Sluice].getClickableURLForLocation();
        else if (spooky_airport_unlocked && ($effect[jungle juiced].have_effect() > 0 || ($item[jungle juice].available_amount() > 0 && availableDrunkenness() > 0 && __misc_state["can drink just about anything"])))
            url = $location[the deep dark jungle].getClickableURLForLocation();
        else if (__misc_state["Chateau Mantegna available"])
            url = "place.php?whichplace=chateau";
        else if (__misc_state["sleaze airport available"])
            url = $location[sloppy seconds diner].getClickableURLForLocation();
        else if (spooky_airport_unlocked)
            url = $location[the deep dark jungle].getClickableURLForLocation();
        else if ($item[GameInformPowerDailyPro walkthru].available_amount() > 0)
            url = $location[video game level 1].getClickableURLForLocation();
        else if (my_primestat() == $stat[muscle] && $location[the haunted billiards room].locationAvailable())
            url = $location[the haunted gallery].getClickableURLForLocation();
        else if (my_primestat() == $stat[mysticality] && $location[the haunted bedroom].locationAvailable())
            url = $location[the haunted bathroom].getClickableURLForLocation();
        else if (my_primestat() == $stat[moxie] && $location[the haunted bedroom].locationAvailable())
            url = $location[the haunted ballroom].getClickableURLForLocation();
            
        
        //133.33333333333333 meat per stat
        int maximum_allowed_to_donate = 10000 * my_level();
        int cost_to_donate_for_level = ceil(substats_remaining.to_float() / 1.5) * 200.0;
        int min_cost_to_donate_for_level = ceil(substats_remaining.to_float() / 2.0) * 200.0;
        if (min_cost_to_donate_for_level <= my_meat() && min_cost_to_donate_for_level <= maximum_allowed_to_donate)
        {
            string statue_name = "";
            if (my_primestat() == $stat[muscle] && $item[boris's key].available_amount() > 0)
            {
                statue_name = "Boris";
                if (cost_to_donate_for_level < 2000 || cost_to_donate_for_level < my_meat() * 0.2)
                    url = "da.php?place=gate1";
            }
            else if (my_primestat() == $stat[mysticality] && $item[jarlsberg's key].available_amount() > 0 && my_path_id() != PATH_AVATAR_OF_JARLSBERG)
            {
                statue_name = "Jarlsberg";
                if (cost_to_donate_for_level < 2000 || cost_to_donate_for_level < my_meat() * 0.2)
                    url = "da.php?place=gate2";
            }
            else if (my_primestat() == $stat[moxie] && $item[sneaky pete's key].available_amount() > 0 && my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
            {
                statue_name = "Sneaky Pete";
                if (cost_to_donate_for_level < 2000 || cost_to_donate_for_level < my_meat() * 0.2)
                    url = "da.php?place=gate3";
            }
                
            if (statue_name != "" && !(can_interact() && cost_to_donate_for_level > 20000))
            {
                buffer line = "Possibly donate ".to_buffer();
                if (cost_to_donate_for_level == min_cost_to_donate_for_level)
                    line.append(cost_to_donate_for_level);
                else
                {
                    line.append(min_cost_to_donate_for_level);
                    line.append(" to ");
                    line.append(cost_to_donate_for_level);
                }
                line.append(" meat to the statue of ");
                line.append(statue_name);
                line.append(".");
                subentry.entries.listAppend(line);
                
            }
        }
        
        
        
        string image_name = "player character";
        
        if (false)
        {
            //vertically less imposing:
            //disabled for now - player avatars look better. well, sneaky pete's avatar looks better...
            image_name = "mini-adventurer blank female";
            
            string [class] class_images;
            class_images[$class[seal clubber]] = "mini-adventurer seal clubber female";
            class_images[$class[turtle tamer]] = "mini-adventurer turtle tamer female";
            class_images[$class[pastamancer]] = "mini-adventurer pastamancer female";
            class_images[$class[sauceror]] = "mini-adventurer sauceror female";
            class_images[$class[disco bandit]] = "mini-adventurer disco bandit female";
            class_images[$class[accordion thief]] = "mini-adventurer accordion thief female";
            
            if (class_images contains my_class())
                image_name = class_images[my_class()];
        }
		
		
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, 11));
	}
	
	
	
		
	

	

	if (__misc_state["yellow ray available"] && __misc_state["in run"])
	{
		string [int] potential_targets;
		
		if (!have_outfit_components("Filthy Hippy Disguise"))
			potential_targets.listAppend("Mysterious Island Hippy for outfit. (allows hippy store access; free redorant for +combat)");
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
			potential_targets.listAppend("Hippy/frat war outfit?");
		//fax targets?
		if (__misc_state["fax available"] || $skill[Rain Man].skill_is_usable())
		{
			potential_targets.listAppend("Anything on the fax list.");
		}
		
		if (!__quest_state["Level 10"].finished && $item[mohawk wig].available_amount() == 0)
			potential_targets.listAppend("Burly Sidekick (Mohawk wig) - speed up top floor of castle.");
		if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
			potential_targets.listAppend("Filthworms.");
		
		if (__quest_state["Boss Bat"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() <3)
		{
			if ($item[enchanted bean].available_amount() == 0 && !__misc_state["beanstalk grown"])
				potential_targets.listAppend("Beanbat. (enchanted bean, sonar-in-a-biscuit)");
			else
				potential_targets.listAppend("A bat. (sonar-in-a-biscuit)");
		}
        
        if (__misc_state["stench airport available"] && $item[filthy child leash].available_amount() == 0 && !__misc_state["familiars temporarily blocked"] && $items[ittah bittah hookah,astral pet sweater,snow suit,lead necklace].available_amount() == 0 && !can_interact() && my_path_id() != PATH_HEAVY_RAINS)
        {
            potential_targets.listAppend("Horrible tourist family (barf mountain) - +5 familiar weight leash.");
        }
		
		
		if (item_drop_modifier_ignoring_plants() < 234.0 && !__misc_state["in aftercore"])
			potential_targets.listAppend("Anything with 30% drop if you can't 234%. (dwarf foreman, bob racecar, drum machines, etc)");
		
		optional_task_entries.listAppend(ChecklistEntryMake(__misc_state_string["yellow ray image name"], "", ChecklistSubentryMake("Fire yellow ray", "", potential_targets), 5));
	}
    if (__misc_state["in run"] && !have_mushroom_plot() && knoll_available() && __misc_state["can eat just about anything"] && fullness_limit() >= 4 && $item[spooky mushroom].available_amount() == 0 && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST && my_meat() >= 5000 && my_path_id() != PATH_SLOW_AND_STEADY && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
    {
        string [int] description;
        description.listAppend("For spooky mushrooms, to cook a grue egg omelette. (epic food)|Will " + ((my_meat() < 5000) ? "need" : "cost") + " 5k meat. Plant a spooky spore.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item spooky mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Possibly plant a mushroom plot", "", description), 5));
    
    }
	
	if (__misc_state["need to level"])
	{
        string url = "";
		int mcd_max_limit = 10;
		boolean have_mcd = false;
		if (canadia_available() || knoll_available() || gnomads_available() && __misc_state["desert beach available"] || in_bad_moon())
			have_mcd = true;
        if (canadia_available())
            mcd_max_limit = 11;
        if (knoll_available())
        {
            if ($item[detuned radio].available_amount() > 0)
                url = "inventory.php?which=3";
            else
                url = "shop.php?whichshop=gnoll";
        }
        //FIXME URLs for the other ones
		if (current_mcd() < mcd_max_limit && have_mcd && monster_level_adjustment() < 150 && !in_bad_moon())
		{
			optional_task_entries.listAppend(ChecklistEntryMake("__item detuned radio", url, ChecklistSubentryMake("Set monster control device to " + mcd_max_limit, "", roundForOutput(mcd_max_limit * __misc_state_float["ML to mainstat multiplier"], 2) + " mainstats/turn")));
		}
	}
	
	if (!have_outfit_components("Filthy Hippy Disguise") && __misc_state["mysterious island available"] && __misc_state["in run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].state_boolean["War started"])
	{
		item [int] missing_pieces = missing_outfit_components("Filthy Hippy Disguise");
        
		string [int] description;
		string [int] modifiers;
        boolean should_be_future_task = false;
        
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
        string next_line_intro = "";
        if (!__misc_state["yellow ray almost certainly impossible"])
        {
            description.listAppend("Yellow-ray a hippy in the hippy camp if you can.");
            next_line_intro = "Otherwise, ";
        }
        else if (my_level() < 9)
            should_be_future_task = true;
        
		if (my_level() >= 9)
		{
			description.listAppend((next_line_intro + "run -combat " + (next_line_intro == "" ? " in the hippy camp" : "there") + ".").capitaliseFirstLetter());
			modifiers.listAppend("-combat");
		}
		else
		{
			description.listAppend((next_line_intro + "wait for level 9.").capitaliseFirstLetter());
		}
        if ($familiar[slimeling].familiar_is_usable())
            modifiers.listAppend("slimeling?");
            
        ChecklistEntry entry = ChecklistEntryMake("__item filthy knitted dread sack", "island.php", ChecklistSubentryMake("Acquire a filthy hippy disguise", modifiers, description), $locations[hippy camp]);
        if (should_be_future_task)
            future_task_entries.listAppend(entry);
        else
            optional_task_entries.listAppend(entry);
	}
    
    if (__misc_state["in run"] && (inebriety_limit() == 0 || my_path_id() == PATH_SLOW_AND_STEADY) && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
    {
        //may be removed in the future?
        //FIXME does this burn delay?
        string [int] modifiers;
		if (__misc_state["have hipster"] && get_property_int("_hipsterAdv") < 7)
		{
			modifiers.listAppend(__misc_state_string["hipster name"]);
		}
		optional_task_entries.listAppend(ChecklistEntryMake("__item dead guy's watch", "", ChecklistSubentryMake("Use rollover runaway", modifiers, listMake("At the end of the day, enter a combat, but don't finish it. Rollover will end it for you.", "This gives an extra chance to look for a non-combat.")), 8));
    }
    
    //I'm not sure if you ever need a frat boy ensemble in-run, even if you're doing the hippy side on the war? If you need war hippy fatigues, the faster (?) way is acquire hippy outfit -> frat warrior fatigues -> start the war / use desert adventure for hippy fatigues. But if they're sure...
	if (!have_outfit_components("Frat boy ensemble") && __misc_state["mysterious island available"] && __misc_state["in run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].started && $location[frat house].turnsAttemptedInLocation() >= 3 && ($location[frat house].combatTurnsAttemptedInLocation() > 0 || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Murder by Death") || $location[frat house].noncombat_queue.contains_text("I Just Wanna Fly") || $location[frat house].noncombat_queue.contains_text("From Stoked to Smoked") || $location[frat house].noncombat_queue.contains_text("Purple Hazers")))
    {
        //they don't have a frat boy ensemble, but they adventured in the pre-war frat house
        //I'm assuming this means they want the outfit, for whatever reason. So, suggest it, until the level 12 starts:
		item [int] missing_pieces = missing_outfit_components("Frat boy ensemble");
        
		string [int] description;
		string [int] modifiers;
        modifiers.listAppend("-combat");
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
			description.listAppend("Run -combat.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item homoerotic frat-paddle", "island.php", ChecklistSubentryMake("Acquire a frat boy ensemble?", modifiers, description), $locations[frat house]));
    }
		
	if ($item[strange leaflet].available_amount() > 0 && __misc_state["in run"])
	{
        boolean leaflet_quest_probably_finished = false;
        
        if ($item[giant pinky ring].available_amount() > 0) //invalid in casual, but eh
            leaflet_quest_probably_finished = true;
        if ($item[Frobozz Real-Estate Company Instant House (TM)].available_amount() > 0 || get_dwelling() == $item[Frobozz Real-Estate Company Instant House (TM)])
            leaflet_quest_probably_finished = true;
        
        if (!leaflet_quest_probably_finished)
        {
            string [int] description;
            boolean future_task = false;
            description.listAppend("Quests Menu" + __html_right_arrow_character + "Leaflet (With Stats)");
            
            if (__misc_state["need to level"])
            {
                item relevant_lamp;
                effect relevant_lamp_effect;
                if (my_primestat() == $stat[muscle])
                {
                    relevant_lamp = lookupItem("red LavaCo Lamp&trade;");
                    relevant_lamp_effect = lookupEffect("Red Menace");
                }
                else if (my_primestat() == $stat[mysticality])
                {
                    relevant_lamp = lookupItem("blue LavaCo Lamp&trade;");
                    relevant_lamp_effect = lookupEffect("Blue Eyed Devil");
                }
                else if (my_primestat() == $stat[moxie])
                {
                    relevant_lamp = lookupItem("green LavaCo Lamp&trade;");
                    relevant_lamp_effect = lookupEffect("Green Peace");
                }
                if (relevant_lamp != $item[none] && relevant_lamp_effect != $effect[none] && relevant_lamp.available_amount() > 0 && relevant_lamp_effect.have_effect() == 0)
                {
                    future_task = true;
                    description.listAppend("Possibly wait until tomorrow. The " + relevant_lamp + " bonus will give extra stats.");
                }
                else if (relevant_lamp_effect.have_effect() > 0)
                    description.listAppend("Soon, before the lava lamp effect runs out.");
                
                item [int] items_equipping = generateEquipmentToEquipForExtraExperienceOnStat(my_primestat());
                if (items_equipping.count() > 0)
                    description.listAppend("Could equip " + items_equipping.listJoinComponents(", ", "or") + " for more stats.");
            }
            
            ChecklistEntry entry = ChecklistEntryMake("__item strange leaflet", "", ChecklistSubentryMake("Strange leaflet quest", "", description));
            if (future_task)
                future_task_entries.listAppend(entry);
            else
                optional_task_entries.listAppend(entry);
        }
	}
	

	SetsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	

    
    boolean have_spaghetti_breakfast = (($skill[spaghetti breakfast].skill_is_usable() && !get_property_boolean("_spaghettiBreakfast")) || $item[spaghetti breakfast].available_amount() > 0);
    if (__misc_state["in run"] && __misc_state["can eat just about anything"] && !get_property_boolean("_spaghettiBreakfastEaten") && my_fullness() == 0 && have_spaghetti_breakfast && my_path_id() != PATH_SLOW_AND_STEADY)
    {
    
        string [int] adventure_gain;
        adventure_gain[1] = "1";
        adventure_gain[2] = "1-2";
        adventure_gain[3] = "2";
        adventure_gain[4] = "2-3";
        adventure_gain[5] = "3";
        adventure_gain[6] = "3-4";
        adventure_gain[7] = "4";
        adventure_gain[8] = "4-5";
        adventure_gain[9] = "5";
        adventure_gain[10] = "5-6";
        adventure_gain[11] = "6";
        
        string adventures_gained = adventure_gain[MAX(1, MIN(11, my_level()))];
        
        string level_string = "";
        if (my_level() < 11)
            level_string = " Gain levels for more.";
        string url = "inventory.php?which=1";
        string [int] description;
        description.listAppend("Inedible if you eat anything else.|" + adventures_gained + " adventures/fullness." + level_string);
        if ($item[spaghetti breakfast].available_amount() == 0)
        {
            description.listAppend("Obtained by casting spaghetti breakfast.");
            url = "skills.php";
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item spaghetti breakfast", url, ChecklistSubentryMake("Eat " + $item[spaghetti breakfast] + " first", "", description), 8));
    }
    
    if (true)
    {
        item dwelling = get_dwelling();
        item upgraded_dwelling = $item[none];
        if ($item[Frobozz Real-Estate Company Instant House (TM)].available_amount() > 0 && (dwelling == $item[big rock] || dwelling == $item[Newbiesport&trade; tent] || get_dwelling() == $item[cottage]))
        {
            upgraded_dwelling = $item[Frobozz Real-Estate Company Instant House (TM)];
        }
        else if ($item[Newbiesport&trade; tent].available_amount() > 0 && dwelling == $item[big rock])
        {
            upgraded_dwelling = $item[Newbiesport&trade; tent];
        }
        if (upgraded_dwelling != $item[none])
        {
            string [int] reasons;
            reasons.listAppend("rollover");
            
            if (__misc_state_int["total free rests possible"] > 0)
                reasons.listAppend("free rests");
            
            string description = "Better HP/MP restoration via " + reasons.listJoinComponents(", ", "and") + ".";
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + upgraded_dwelling, "inventory.php?which=3", ChecklistSubentryMake("Use " + upgraded_dwelling, "", description), 8));
            
        }
    }
    
    if (__misc_state["in run"] && $item[dry cleaning receipt].available_amount() > 0)
    {
        item receipt_item = $item[none];
        if (my_primestat() == $stat[muscle])
            receipt_item = $item[power sock];
        else if (my_primestat() == $stat[mysticality])
            receipt_item = $item[wool sock];
        else if (my_primestat() == $stat[moxie])
            receipt_item = $item[moustache sock];
        if (receipt_item != $item[none] && receipt_item.available_amount() == 0)
        {
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + $item[dry cleaning receipt], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[dry cleaning receipt], "", "For " + receipt_item + " accessory."), 8));
        }
    }
    
	checklists.listAppend(ChecklistMake("Tasks", task_entries));
	checklists.listAppend(ChecklistMake("Optional Tasks", optional_task_entries));
	checklists.listAppend(ChecklistMake("Future Tasks", future_task_entries));
}