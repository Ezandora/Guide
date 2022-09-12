static
{
    item [skill][int] __gelatinous_items_that_give_skill;
    
    string [int] __gelatinous_skill_ids_to_descriptions {23001:"+1 hot res", 23002:"+1 hot res", 23003:"+2 hot res", 23004:"+2 hot res", 23005:"+3 hot res", 23006:"+1 cold res", 23007:"+1 cold res", 23008:"+2 cold res", 23009:"+2 cold res", 23010:"+3 cold res", 23011:"+1 stench res", 23012:"+1 stench res", 23013:"+2 stench res", 23014:"+2 stench res", 23015:"+3 stench res", 23016:"+1 spooky res", 23017:"+1 spooky res", 23018:"+2 spooky res", 23019:"+2 spooky res", 23020:"+3 spooky res", 23021:"+1 sleaze res", 23022:"+1 sleaze res", 23023:"+2 sleaze res", 23024:"+2 sleaze res", 23025:"+3 sleaze res", 23026:"+30 DA", 23027:"+40 DA", 23028:"+50 DA", 23029:"+60 DA", 23030:"+70 DA", 23031:"+5 DR", 23032:"+5 DR", 23033:"+10 DR", 23034:"+10 DR", 23035:"+20 DR", 23036:"+10% init", 23037:"+20% init", 23038:"+30% init", 23039:"+40% init", 23040:"+50% init", 23041:"+3 stats/fight", 23042:"+3 stats/fight", 23043:"+5 stats/fight", 23044:"+5 stats/fight", 23045:"+7 stats/fight", 23046:"+1 adv/absorbed item", 23047:"+1 adv/absorbed item", 23048:"+2 adv/absorbed item", 23049:"+2 adv/absorbed item", 23050:"+3 adv/absorbed item", 23051:"+5 stats/absorbed item", 23052:"+10 stats/absorbed item", 23053:"+15 stats/absorbed item", 23054:"+20 stats/absorbed item", 23055:"+25 stats/absorbed item", 23056:"+20% HP", 23057:"+30% HP", 23058:"+40% HP", 23059:"+50% HP", 23060:"+100% HP", 23061:"+20% MP", 23062:"+30% MP", 23063:"+40% MP", 23064:"+50% MP", 23065:"+100% MP", 23066:"+20% item", 23067:"+20% item", 23068:"+30% item", 23069:"+40% item", 23070:"+50% item", 23071:"+10% pickpocket", 23072:"+20% pickpocket", 23073:"+30% pickpocket", 23074:"+40% pickpocket", 23075:"+50% pickpocket", 23076:"+30% meat", 23077:"+40% meat", 23078:"+50% meat", 23079:"+60% meat", 23080:"+70% meat", 23081:"+5 muscle", 23082:"+10 muscle", 23083:"+15 muscle", 23084:"+20 muscle", 23085:"+25 muscle", 23086:"+5 myst", 23087:"+10 myst", 23088:"+15 myst", 23089:"+20 myst", 23090:"+25 myst", 23091:"+5 moxie", 23092:"+10 moxie", 23093:"+15 moxie", 23094:"+20 moxie", 23095:"+25 moxie", 23096:"+7 damage", 23097:"+9 damage", 23098:"+11 damage", 23099:"+13 damage", 23100:"+15 damage", 23101:"+3 Hot Damage", 23102:"+5 Hot Damage", 23103:"+7 Hot Damage", 23104:"+9 Hot Damage", 23105:"+11 Hot Damage", 23106:"+3 Cold Damage", 23107:"+5 Cold Damage", 23108:"+7 Cold Damage", 23109:"+9 Cold Damage", 23110:"+11 Cold Damage", 23111:"+3 Stench Damage", 23112:"+5 Stench Damage", 23113:"+7 Stench Damage", 23114:"+9 Stench Damage", 23115:"+11 Stench Damage", 23116:"+3 Spooky Damage", 23117:"+5 Spooky Damage", 23118:"+7 Spooky Damage", 23119:"+9 Spooky Damage", 23120:"+11 Spooky Damage", 23121:"+3 Sleaze Damage", 23122:"+5 Sleaze Damage", 23123:"+7 Sleaze Damage", 23124:"+9 Sleaze Damage", 23125:"+11 Sleaze Damage", 23301:"-combat buff", 23302:"-combat buff", 23303:"-combat buff", 23304:"+combat buff", 23305:"+combat buff", 23306:"+combat buff"};
    int [int] __gelatinous_evaluation_order {0:23301, 1:23302, 2:23303, 3:23304, 4:23305, 5:23306, 6:23046, 7:23047, 8:23048, 9:23049, 10:23050, 11:23051, 12:23052, 13:23053, 14:23054, 15:23055, 16:23041, 17:23042, 18:23043, 19:23044, 20:23045, 21:23066, 22:23067, 23:23068, 24:23069, 25:23070, 26:23076, 27:23077, 28:23078, 29:23079, 30:23080, 31:23026, 32:23027, 33:23028, 34:23029, 35:23030, 36:23031, 37:23032, 38:23033, 39:23034, 40:23035, 41:23036, 42:23037, 43:23038, 44:23039, 45:23040, 46:23056, 47:23057, 48:23058, 49:23059, 50:23060, 51:23061, 52:23062, 53:23063, 54:23064, 55:23065, 56:23071, 57:23072, 58:23073, 59:23074, 60:23075, 61:23001, 62:23002, 63:23003, 64:23004, 65:23005, 66:23006, 67:23007, 68:23008, 69:23009, 70:23010, 71:23011, 72:23012, 73:23013, 74:23014, 75:23015, 76:23016, 77:23017, 78:23018, 79:23019, 80:23020, 81:23021, 82:23022, 83:23023, 84:23024, 85:23025, 86:23081, 87:23082, 88:23083, 89:23084, 90:23085, 91:23086, 92:23087, 93:23088, 94:23089, 95:23090, 96:23091, 97:23092, 98:23093, 99:23094, 100:23095, 101:23096, 102:23097, 103:23098, 104:23099, 105:23100, 106:23101, 107:23102, 108:23103, 109:23104, 110:23105, 111:23106, 112:23107, 113:23108, 114:23109, 115:23110, 116:23111, 117:23112, 118:23113, 119:23114, 120:23115, 121:23116, 122:23117, 123:23118, 124:23119, 125:23120, 126:23121, 127:23122, 128:23123, 129:23124, 130:23125};
    
    int [int] __gelatinous_skill_raw_modifier_number {23001:1, 23002:1, 23003:2, 23004:2, 23005:3, 23006:1, 23007:1, 23008:2, 23009:2, 23010:3, 23011:1, 23012:1, 23013:2, 23014:2, 23015:3, 23016:1, 23017:1, 23018:2, 23019:2, 23020:3, 23021:1, 23022:1, 23023:2, 23024:2, 23025:3, 23026:30, 23027:40, 23028:50, 23029:60, 23030:70, 23031:5, 23032:5, 23033:10, 23034:10, 23035:20, 23036:10, 23037:20, 23038:30, 23039:40, 23040:50, 23041:3, 23042:3, 23043:5, 23044:5, 23045:7, 23046:1, 23047:1, 23048:2, 23049:2, 23050:3, 23051:5, 23052:10, 23053:15, 23054:20, 23055:25, 23056:20, 23057:30, 23058:40, 23059:50, 23060:100, 23061:20, 23062:30, 23063:40, 23064:50, 23065:100, 23066:20, 23067:20, 23068:30, 23069:40, 23070:50, 23071:10, 23072:20, 23073:30, 23074:40, 23075:50, 23076:30, 23077:40, 23078:50, 23079:60, 23080:70, 23081:5, 23082:10, 23083:15, 23084:20, 23085:25, 23086:5, 23087:10, 23088:15, 23089:20, 23090:25, 23091:5, 23092:10, 23093:15, 23094:20, 23095:25, 23096:7, 23097:9, 23098:11, 23099:13, 23100:15, 23101:3, 23102:5, 23103:7, 23104:9, 23105:11, 23106:3, 23107:5, 23108:7, 23109:9, 23110:11, 23111:3, 23112:5, 23113:7, 23114:9, 23115:11, 23116:3, 23117:5, 23118:7, 23119:9, 23120:11, 23121:3, 23122:5, 23123:7, 23124:9, 23125:11};
}
void initialiseGelatinousStatics()
{
    if (__gelatinous_items_that_give_skill.count() > 0)
        return;
    foreach it in $items[]
    {
        if (!it.item_is_pvp_stealable() && !(it.gift && it.discardable) && !($items[interesting clod of dirt,dirty bottlecap,discarded button] contains it)) continue;
        
		if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot()) //familiar equipment fine
			continue;
		if ($items[map to Madness Reef,map to the Marinara Trench,map to Anemone Mine,map to the Dive Bar,map to the Skate Park, glass of &quot;milk&quot;, cup of &quot;tea&quot;, thermos of &quot;whiskey&quot;, Lucky Lindy, Bee's Knees, Sockdollager, Ish Kabibble, Hot Socks, Phonus Balonus, Flivver, Sloppy Jalopy] contains it) //'
			continue;
        
        int lookup = it.descid.to_int_silent() % 125 + 23001;
        int item_id = it.to_int();
        //Hardcoded:
        if (item_id == 9353)
            lookup = 23302;
        else if (item_id == 9349)
            lookup = 23304;
        else if (item_id == 9357)
            lookup = 23301;
        else if (item_id == 9359)
            lookup = 23306;
        else if (item_id == 9361)
            lookup = 23305;
        else if (item_id == 9354)
            lookup = 23303;
        skill s = lookup.to_skill();
        if (!(__gelatinous_items_that_give_skill contains s))
            __gelatinous_items_that_give_skill[s] = listMakeBlankItem();
        __gelatinous_items_that_give_skill[s].listAppend(it);
    }
    
    
}


RegisterTaskGenerationFunction("PathGelatinousNoobGenerateTasks");
void PathGelatinousNoobGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id_legacy() != PATH_GELATINOUS_NOOB)
		return;
    
    int total_absorptions = 2 + MIN(13, my_level());
    int absorptions_used = get_property_int("_noobSkillCount");
    //int absorptions_used = my_absorbs(); //FIXME next point release, 17.7
    int absorptions_left = total_absorptions - absorptions_used;
    if (absorptions_left > 0)
    {
        initialiseGelatinousStatics();
        string [int] description;
        
        
        if (true)
        {
            boolean [item] blocklist;
            
            if (__quest_state["Level 9"].state_int["peak tests remaining"] > 0)
                blocklist[$item[rusty hedge trimmers]] = true;
            if ($item[goat cheese].available_amount() <= 3 && !__quest_state["Level 8"].state_boolean["Past mine"])
            {
                blocklist[$item[goat cheese]] = true;
                blocklist[$item[goat cheese pizza]] = true;
            }
            foreach it in $items[print screen button,spooky-gro fertilizer,cuppa obscuri tea]
                blocklist[it] = true;
            if (__quest_state["Pirate Quest"].state_boolean["hot wings relevant"] && $item[hot wing].available_amount() <= 3)
                blocklist[$item[hot wing]] = true;
                
            //Collect a list for each grouping:
            
            int [int][int] first_level_group_evaluation_indices;
            for grouping_index from 23125 to 23001 by -5
            {
                int [int] group_indices;
                for i from grouping_index to grouping_index - 4 by -1
                {
                    group_indices.listAppend(i);
                }
                first_level_group_evaluation_indices[grouping_index] = group_indices;
            }
            first_level_group_evaluation_indices[23301] = listMake(23303, 23302, 23301);
            first_level_group_evaluation_indices[23304] = listMake(23306, 23305, 23304);
            
            string [int][int] grouping_to_relevant_items;
            
            skill [int][int] grouping_to_group_skills;
            skill [int] grouping_to_relevant_items_skill;
            boolean [int] grouping_should_grey_out;
            //for grouping_index from 23125 to 23001 by -5
            foreach grouping_index in first_level_group_evaluation_indices
            {
                int [int] group_indices = first_level_group_evaluation_indices[grouping_index];
                
                skill [int] group_skills;
                //for i from grouping_index to grouping_index - 4 by -1
                foreach key2, i in group_indices
                {
                   skill s = i.to_skill();
                   if (s.have_skill()) continue;
                    group_skills.listAppend(s);
                }
                //print_html("group_skills = " + group_skills.to_json());
                grouping_to_group_skills[grouping_index] = group_skills;
                //The ideal here is, we want to find a list of items for the best skill in the group.
                //If that's not possible, we do the second best skill, etc. We also list the best pull, but only if it's relevant
                item pullable_item = $item[none];
                item [int] relevant_items;
                boolean on_first = true;
                foreach key, s in group_skills
                {
                    if (key > 0)
                        on_first = false;
                    foreach key2, it in __gelatinous_items_that_give_skill[s]
                    {
                        if (blocklist contains it)
                            continue;
                        if (it.available_amount() == 0 && it.creatable_amount() == 0 && (it.npc_price() == 0 || it.npc_price() > my_meat()))
                        {
                            if (pulls_remaining() > 0 && !it.gift && key == 0 && it.is_unrestricted())
                            {
                                if (pullable_item == $item[none] || (it.historical_price() < pullable_item.historical_price() && it.historical_price() > 0))
                                    pullable_item = it;
                            }
                            continue;
                        }
                        relevant_items.listAppend(it);
                    }
                    if (relevant_items.count() > 0)
                    {
                        grouping_to_relevant_items_skill[grouping_index] = s;
                        break;
                    }
                }
                boolean should_grey_out = false;
                if (grouping_to_relevant_items_skill[grouping_index] == $skill[none])
                {
                    grouping_to_relevant_items_skill[grouping_index] = group_skills[0];
                    should_grey_out = true;
                }
                grouping_should_grey_out[grouping_index] = should_grey_out;
                string [int] relevant_items_out;
                //sort relevant_items by (value.historical_price() <= 0 ? 999999999 : value.historical_price());
                //NPC price is more relevant in-run, since cost of acquisition.
                sort relevant_items by (value.npc_price() > 0 ? value.npc_price() : (value.historical_price() <= 0 ? 999999999 : value.historical_price()));
                if (relevant_items[0].npc_price() > 0 && relevant_items[0].npc_price() <= 1000) //something cheap and obtainable? ignore the rest
                {
                    //examples: fermenting powder, herbs, pickled egg
                    relevant_items_out.listAppend(relevant_items[0]);
                }
                else
                {
                    foreach key, it in relevant_items
                    {
                        if (key > 2) break;
                        relevant_items_out.listAppend(it);
                    }
                }
                if (pulls_remaining() > 0 && (!on_first || relevant_items.count() == 0) && pullable_item != $item[none])
                {
                    string line = pullable_item + " (pull";
                    if (!should_grey_out)
                        line += " for +" + __gelatinous_skill_raw_modifier_number[group_skills[0].to_int()];
                    line += ")";
                    line = HTMLGenerateSpanFont(line, "gray");
                    relevant_items_out.listPrepend(line);
                }
                grouping_to_relevant_items[grouping_index] = relevant_items_out;
            }
            
            foreach key, s_id in __gelatinous_evaluation_order
            {
                if (s_id % 5 != 0 && s_id != 23301 && s_id != 23304) continue;
                skill s = s_id.to_skill();
                int grouping_index = s_id;
                
                string [int] relevant_items = grouping_to_relevant_items[grouping_index];
                skill [int] group_skills = grouping_to_group_skills[grouping_index];
                skill relevant_items_skill = grouping_to_relevant_items_skill[grouping_index];
                
                //print_html("s = " + s + " group_skills = " + group_skills.to_json() + ", relevant_items = " + relevant_items.to_json());
                
                //description.listAppend(relevant_items_skill + ": " + __gelatinous_skill_ids_to_descriptions[relevant_items_skill.to_int()]);
                string extra_data;
                if ($familiar[robortender].familiar_is_usable())
                {
                    phylum [int] phylums_to_run_against;
                    if (grouping_index == 23301)
                    {
                        if (!$skill[bendable knees].have_skill() && $item[bottle of gregnadigne].available_amount() == 0)
                            phylums_to_run_against.listAppend($phylum[humanoid]);
                        if (!$skill[retractable toes].have_skill() && $item[cocktail mushroom].available_amount() == 0)
                            phylums_to_run_against.listAppend($phylum[goblin]);
                        if (!$skill[ink gland].have_skill() && $item[shot of granola liqueur].available_amount() == 0)
                            phylums_to_run_against.listAppend($phylum[hippy]);
                    }
                    if (grouping_index == 23304)
                    {
                        if (!$skill[frown muscles].have_skill() && $item[bottle of novelty hot sauce].available_amount() == 0)
                            phylums_to_run_against.listAppend($phylum[demon]);
                        if (!$skill[anger glands].have_skill() && $item[limepatch].available_amount() == 0)
                            phylums_to_run_against.listAppend($phylum[pirate]);
                        if (!$skill[powerful vocal chords].have_skill() && $item[baby oil shooter].available_amount() == 0)
                            phylums_to_run_against.listAppend($phylum[orc]);
                    }
                    if (phylums_to_run_against.count() > 0)
                        extra_data += "Run robortender against " + phylums_to_run_against.listJoinComponents(", ", "and");
                }
                
                string line = HTMLGenerateSpanOfClass(__gelatinous_skill_ids_to_descriptions[relevant_items_skill.to_int()], "r_bold");
                if (relevant_items.count() > 0 || extra_data != "")
                {
                    if (relevant_items.count() > 0)
                        line += ": " + relevant_items.listJoinComponents(", ", "or");
                    if (extra_data != "")
                        line += "|*" + extra_data;
                    line += ".";
                    if (grouping_should_grey_out[grouping_index])
                        line = HTMLGenerateSpanFont(line, "gray");
                    description.listAppend(line);
                }
                
            }
            description.listAppend("Or equipment, for their buffs." + (combat_rate_modifier() > -25 ? "|*Bram's choker, ring of conflict, duonoculars, rusted shootin' iron, or red shoe especially." : ""));
            if ($skill[Large Intestine].have_skill())
                description.listAppend("Or potted cactus, for +5 adventures.");
            //foreach s in __gelatinous_items_that_give_skill
            /*foreach key, s_id in __gelatinous_evaluation_order
            {
                skill s = s_id.to_skill();
                if (s.have_skill()) continue;
                
                string [int] relevant_items;
                item pullable_item = $item[none];
                boolean should_grey_out = false;
                foreach key, it in __gelatinous_items_that_give_skill[s]
                {
                    if (blocklist contains it)
                        continue;
                    if (it.available_amount() == 0 && it.creatable_amount() == 0 && (it.npc_price() == 0 || it.npc_price() > my_meat()))
                    {
                        if (pulls_remaining() > 0 && !it.gift)
                        {
                            if (pullable_item == $item[none] || (it.historical_price() < pullable_item.historical_price() && it.historical_price() > 0))
                                pullable_item = it;
                        }
                        continue;
                    }
                    relevant_items.listAppend(it);
                }
                if (pullable_item != $item[none] && relevant_items.count() == 0)
                {
                    if (relevant_items.count() == 0)
                        should_grey_out = true;
                    relevant_items.listAppend(HTMLGenerateSpanFont(pullable_item + " (pull)", "gray"));
                }
                string line = HTMLGenerateSpanOfClass(__gelatinous_skill_ids_to_descriptions[s.to_int()], "r_bold");
                if (relevant_items.count() > 0)
                    line += ": " + relevant_items.listJoinComponents(", ", "or") + ".";
                else
                    should_grey_out = true;
                if (should_grey_out)
                    line = HTMLGenerateSpanFont(line, "gray");
                description.listAppend(line);
            }*/
        }
        optional_task_entries.listAppend(ChecklistEntryMake(181, "__familiar Gelatinous Cubeling", "inventory.php", ChecklistSubentryMake("Absorb " + pluralise(absorptions_left, "item", "items"), "", description), -1));
    }
    
    if ($familiar[Robortender].have_familiar())
    {
    
        string url = "";
        
        if (my_familiar() != $familiar[Robortender])
            url = "familiar.php";
        phylum [int] phylums_to_run_against;
        location [int] suggested_locations;
        string [int] matchup_type;
        boolean have_minus = false;
        boolean have_plus = false;
        if (!$skill[bendable knees].have_skill() && $item[bottle of gregnadigne].available_amount() == 0)
        {
            phylums_to_run_against.listAppend($phylum[humanoid]);
            suggested_locations.listAppend($location[the old landfill]);
            matchup_type.listAppend("-");
            have_minus = true;
        }
        if (!$skill[retractable toes].have_skill() && $item[cocktail mushroom].available_amount() == 0)
        {
            phylums_to_run_against.listAppend($phylum[goblin]);
            suggested_locations.listAppend($location[the outskirts of cobb's knob]);
            matchup_type.listAppend("-");
            have_minus = true;
        }
        if (!$skill[ink gland].have_skill() && $item[shot of granola liqueur].available_amount() == 0)
        {
            phylums_to_run_against.listAppend($phylum[hippy]);
            suggested_locations.listAppend($location[hippy camp]);
            matchup_type.listAppend("-");
            have_minus = true;
        }
        if (!$skill[frown muscles].have_skill() && $item[bottle of novelty hot sauce].available_amount() == 0)
        {
            phylums_to_run_against.listAppend($phylum[demon]);
            suggested_locations.listAppend($location[the dark heart of the woods]);
            matchup_type.listAppend("+");
            have_plus = true;
        }
        if (!$skill[anger glands].have_skill() && $item[limepatch].available_amount() == 0)
        {
            phylums_to_run_against.listAppend($phylum[pirate]);
            suggested_locations.listAppend($location[the obligatory pirate's cove]);
            matchup_type.listAppend("+");
            have_plus = true;
        }
        if (!$skill[powerful vocal chords].have_skill() && $item[baby oil shooter].available_amount() == 0)
        {
            phylums_to_run_against.listAppend($phylum[orc]);
            suggested_locations.listAppend($location[frat house]);
            matchup_type.listAppend("+");
            have_plus = true;
        }
            
        string [int] skill_types;
        if (have_minus)
            skill_types.listAppend("-combat");
        if (have_plus)
            skill_types.listAppend("+combat");
        string [int] description;
        description.listAppend("Collect components for " + skill_types.listJoinComponents(", ", "and") + " skills.");
        if (suggested_locations.count() > 0)
        {
            string [int] locations_out;
            foreach key, l in suggested_locations
            {
                locations_out.listAppend(l + " (" + matchup_type[key] + ")");
            }
            description.listAppend("Could look in " + locations_out.listJoinComponents(", ", "and") + ".");
            if (url == "")
                url = suggested_locations[0].getClickableURLForLocation();
        }
        if (phylums_to_run_against.count() > 0)
        {
            string [int] phylums_out;
            foreach key, p in phylums_to_run_against
            {
                phylums_out.listAppend(p + " (" + matchup_type[key] + ")");
            }
            optional_task_entries.listAppend(ChecklistEntryMake(182, "__familiar Robortender", url, ChecklistSubentryMake("Run robortender against " + phylums_out.listJoinComponents(", ", "and"), "", description), 5));
        }
    }
}
