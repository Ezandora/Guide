static
{
    item [skill][int] __gelatinous_items_that_give_skill;
    
    string [int] __gelatinous_skill_ids_to_descriptions {23001:"+1 hot res", 23002:"+1 hot res", 23003:"+2 hot res", 23004:"+2 hot res", 23005:"+3 hot res", 23006:"+1 cold res", 23007:"+1 cold res", 23008:"+2 cold res", 23009:"+2 cold res", 23010:"+3 cold res", 23011:"+1 stench res", 23012:"+1 stench res", 23013:"+2 stench res", 23014:"+2 stench res", 23015:"+3 stench res", 23016:"+1 spooky res", 23017:"+1 spooky res", 23018:"+2 spooky res", 23019:"+2 spooky res", 23020:"+3 spooky res", 23021:"+1 sleaze res", 23022:"+1 sleaze res", 23023:"+2 sleaze res", 23024:"+2 sleaze res", 23025:"+3 sleaze res", 23026:"+30 DA", 23027:"+40 DA", 23028:"+50 DA", 23029:"+60 DA", 23030:"+70 DA", 23031:"+5 DR", 23032:"+5 DR", 23033:"+10 DR", 23034:"+10 DR", 23035:"+20 DR", 23036:"+10% init", 23037:"+20% init", 23038:"+30% init", 23039:"+40% init", 23040:"+50% init", 23041:"+3 stats/fight", 23042:"+3 stats/fight", 23043:"+5 stats/fight", 23044:"+5 stats/fight", 23045:"+7 stats/fight", 23046:"+1 adv/absorbed item", 23047:"+1 adv/absorbed item", 23048:"+2 adv/absorbed item", 23049:"+2 adv/absorbed item", 23050:"+3 adv/absorbed item", 23051:"+5 stats/absorbed item", 23052:"+10 stats/absorbed item", 23053:"+15 stats/absorbed item", 23054:"+20 stats/absorbed item", 23055:"+25 stats/absorbed item", 23056:"+20% HP", 23057:"+30% HP", 23058:"+40% HP", 23059:"+50% HP", 23060:"+100% HP", 23061:"+20% MP", 23062:"+30% MP", 23063:"+40% MP", 23064:"+50% MP", 23065:"+100% MP", 23066:"+20% item", 23067:"+20% item", 23068:"+30% item", 23069:"+40% item", 23070:"+50% item", 23071:"+10% pickpocket", 23072:"+20% pickpocket", 23073:"+30% pickpocket", 23074:"+40% pickpocket", 23075:"+50% pickpocket", 23076:"+30% meat", 23077:"+40% meat", 23078:"+50% meat", 23079:"+60% meat", 23080:"+70% meat", 23081:"+5 muscle", 23082:"+10 muscle", 23083:"+15 muscle", 23084:"+20 muscle", 23085:"+25 muscle", 23086:"+5 myst", 23087:"+10 myst", 23088:"+15 myst", 23089:"+20 myst", 23090:"+25 myst", 23091:"+5 moxie", 23092:"+10 moxie", 23093:"+15 moxie", 23094:"+20 moxie", 23095:"+25 moxie", 23096:"+7 damage", 23097:"+9 damage", 23098:"+11 damage", 23099:"+13 damage", 23100:"+15 damage", 23101:"+3 Hot Damage", 23102:"+5 Hot Damage", 23103:"+7 Hot Damage", 23104:"+9 Hot Damage", 23105:"+11 Hot Damage", 23106:"+3 Cold Damage", 23107:"+5 Cold Damage", 23108:"+7 Cold Damage", 23109:"+9 Cold Damage", 23110:"+11 Cold Damage", 23111:"+3 Stench Damage", 23112:"+5 Stench Damage", 23113:"+7 Stench Damage", 23114:"+9 Stench Damage", 23115:"+11 Stench Damage", 23116:"+3 Spooky Damage", 23117:"+5 Spooky Damage", 23118:"+7 Spooky Damage", 23119:"+9 Spooky Damage", 23120:"+11 Spooky Damage", 23121:"+3 Sleaze Damage", 23122:"+5 Sleaze Damage", 23123:"+7 Sleaze Damage", 23124:"+9 Sleaze Damage", 23125:"+11 Sleaze Damage"};
    int [int] __gelatinous_evaluation_order {0:23046, 1:23047, 2:23048, 3:23049, 4:23050, 5:23051, 6:23052, 7:23053, 8:23054, 9:23055, 10:23041, 11:23042, 12:23043, 13:23044, 14:23045, 15:23066, 16:23067, 17:23068, 18:23069, 19:23070, 20:23076, 21:23077, 22:23078, 23:23079, 24:23080, 25:23026, 26:23027, 27:23028, 28:23029, 29:23030, 30:23031, 31:23032, 32:23033, 33:23034, 34:23035, 35:23036, 36:23037, 37:23038, 38:23039, 39:23040, 40:23056, 41:23057, 42:23058, 43:23059, 44:23060, 45:23061, 46:23062, 47:23063, 48:23064, 49:23065, 50:23071, 51:23072, 52:23073, 53:23074, 54:23075, 55:23001, 56:23002, 57:23003, 58:23004, 59:23005, 60:23006, 61:23007, 62:23008, 63:23009, 64:23010, 65:23011, 66:23012, 67:23013, 68:23014, 69:23015, 70:23016, 71:23017, 72:23018, 73:23019, 74:23020, 75:23021, 76:23022, 77:23023, 78:23024, 79:23025, 80:23081, 81:23082, 82:23083, 83:23084, 84:23085, 85:23086, 86:23087, 87:23088, 88:23089, 89:23090, 90:23091, 91:23092, 92:23093, 93:23094, 94:23095, 95:23096, 96:23097, 97:23098, 98:23099, 99:23100, 100:23101, 101:23102, 102:23103, 103:23104, 104:23105, 105:23106, 106:23107, 107:23108, 108:23109, 109:23110, 110:23111, 111:23112, 112:23113, 113:23114, 114:23115, 115:23116, 116:23117, 117:23118, 118:23119, 119:23120, 120:23121, 121:23122, 122:23123, 123:23124, 124:23125};
    
    int [int] __gelatinous_skill_raw_modifier_number {23001:1, 23002:1, 23003:2, 23004:2, 23005:3, 23006:1, 23007:1, 23008:2, 23009:2, 23010:3, 23011:1, 23012:1, 23013:2, 23014:2, 23015:3, 23016:1, 23017:1, 23018:2, 23019:2, 23020:3, 23021:1, 23022:1, 23023:2, 23024:2, 23025:3, 23026:30, 23027:40, 23028:50, 23029:60, 23030:70, 23031:5, 23032:5, 23033:10, 23034:10, 23035:20, 23036:10, 23037:20, 23038:30, 23039:40, 23040:50, 23041:3, 23042:3, 23043:5, 23044:5, 23045:7, 23046:1, 23047:1, 23048:2, 23049:2, 23050:3, 23051:5, 23052:10, 23053:15, 23054:20, 23055:25, 23056:20, 23057:30, 23058:40, 23059:50, 23060:100, 23061:20, 23062:30, 23063:40, 23064:50, 23065:100, 23066:20, 23067:20, 23068:30, 23069:40, 23070:50, 23071:10, 23072:20, 23073:30, 23074:40, 23075:50, 23076:30, 23077:40, 23078:50, 23079:60, 23080:70, 23081:5, 23082:10, 23083:15, 23084:20, 23085:25, 23086:5, 23087:10, 23088:15, 23089:20, 23090:25, 23091:5, 23092:10, 23093:15, 23094:20, 23095:25, 23096:7, 23097:9, 23098:11, 23099:13, 23100:15, 23101:3, 23102:5, 23103:7, 23104:9, 23105:11, 23106:3, 23107:5, 23108:7, 23109:9, 23110:11, 23111:3, 23112:5, 23113:7, 23114:9, 23115:11, 23116:3, 23117:5, 23118:7, 23119:9, 23120:11, 23121:3, 23122:5, 23123:7, 23124:9, 23125:11};
}
void initialiseGelatinousStatics()
{
    if (__gelatinous_items_that_give_skill.count() > 0)
        return;
    foreach it in $items[]
    {
        if (!it.item_is_pvp_stealable() && !(it.gift && it.discardable) && !(lookupItems("interesting clod of dirt,dirty bottlecap,discarded button") contains it)) continue;
        
		if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot()) //familiar equipment fine
			continue;
		if ($items[map to Madness Reef,map to the Marinara Trench,map to Anemone Mine,map to the Dive Bar,map to the Skate Park, glass of &quot;milk&quot;, cup of &quot;tea&quot;, thermos of &quot;whiskey&quot;, Lucky Lindy, Bee's Knees, Sockdollager, Ish Kabibble, Hot Socks, Phonus Balonus, Flivver, Sloppy Jalopy] contains it) //'
			continue;
        
        int lookup = it.descid.to_int_silent() % 125 + 23001;
        skill s = lookup.to_skill();
        if (!(__gelatinous_items_that_give_skill contains s))
            __gelatinous_items_that_give_skill[s] = listMakeBlankItem();
        __gelatinous_items_that_give_skill[s].listAppend(it);
    }
    
    
}


RegisterTaskGenerationFunction("PathGelatinousNoobGenerateTasks");
void PathGelatinousNoobGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_GELATINOUS_NOOB)
		return;
    
    //FIXME 13 guess
    //noobDeferredPoints does something else; seems to be a choice at the start of the ascension?
    int total_absorptions = 2 + MIN(13, my_level());
    int absorptions_used = get_property_int("_noobSkillCount");
    int absorptions_left = total_absorptions - absorptions_used;
    if (!mafiaIsPastRevision(17821)) //tracking
        absorptions_left = 0;
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
            blocklist[$item[print screen button]] = true;
            if (__quest_state["Pirate Quest"].state_boolean["hot wings relevant"] && $item[hot wing].available_amount() <= 3)
                blocklist[$item[hot wing]] = true;
            
                
            //Collect a list for each grouping:
            
            string [int][int] grouping_to_relevant_items;
            
            skill [int][int] grouping_to_group_skills;
            skill [int] grouping_to_relevant_items_skill;
            boolean [int] grouping_should_grey_out;
            for grouping_index from 23125 to 23001 by -5
            {
                skill [int] group_skills;
                for i from grouping_index to grouping_index - 4 by -1
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
                sort relevant_items by (value.historical_price() <= 0 ? 999999999 : value.historical_price());
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
                if (s_id % 5 != 0) continue;
                skill s = s_id.to_skill();
                int grouping_index = s_id;
                
                string [int] relevant_items = grouping_to_relevant_items[grouping_index];
                skill [int] group_skills = grouping_to_group_skills[grouping_index];
                skill relevant_items_skill = grouping_to_relevant_items_skill[grouping_index];
                
                //print_html("s = " + s + " group_skills = " + group_skills.to_json() + ", relevant_items = " + relevant_items.to_json());
                
                //description.listAppend(relevant_items_skill + ": " + __gelatinous_skill_ids_to_descriptions[relevant_items_skill.to_int()]);
                string line = HTMLGenerateSpanOfClass(__gelatinous_skill_ids_to_descriptions[relevant_items_skill.to_int()], "r_bold");
                if (relevant_items.count() > 0)
                {
                    line += ": " + relevant_items.listJoinComponents(", ", "or") + ".";
                    if (grouping_should_grey_out[grouping_index])
                        line = HTMLGenerateSpanFont(line, "gray");
                    description.listAppend(line);
                }
                
            }
            description.listAppend("Or equipment, for their buffs." + (combat_rate_modifier() > -25 ? "|*Bram's choker, ring of conflict, duonoculars, rusted shootin' iron, or red shoe especially." : ""));
            if (lookupSkill("Large Intestine").have_skill())
                description.listAppend("Or potted cactus, for extra adventures.");
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
        
        optional_task_entries.listAppend(ChecklistEntryMake("__familiar Gelatinous Cubeling", "inventory.php", ChecklistSubentryMake("Absorb " + pluralise(absorptions_left, "item", "items"), "", description), -1));
    }
}