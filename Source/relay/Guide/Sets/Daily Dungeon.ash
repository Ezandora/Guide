void SDailyDungeonGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	
	if (__last_adventure_location == $location[The Daily Dungeon])
	{
		if ($item[ring of detect boring doors].equipped_amount() == 0 && $item[ring of detect boring doors].available_amount() > 0 && !get_property_boolean("dailyDungeonDone"))
		{
			task_entries.listAppend(ChecklistEntryMake("__item ring of detect boring doors", "inventory.php?which=2", ChecklistSubentryMake("Wear ring of detect boring doors", "", "Speeds up daily dungeon"), -11));
		}
		if (familiar_is_usable($familiar[gelatinous cubeling]) && ($item[pick-o-matic lockpicks].available_amount() == 0 || $item[eleven-foot pole].available_amount() == 0 || $item[Ring of Detect Boring Doors].available_amount() == 0)) //have familiar, but not the drops
		{
			task_entries.listAppend(ChecklistEntryMake("__familiar gelatinous cubeling", "", ChecklistSubentryMake("Use a gelatinous cubeling first", "", "You're adventuring in the daily dungeon without cubeling drops"), -11));
		}
	}
	
	
	boolean need_to_do_daily_dungeon = false;
	
	if (__misc_state_int["fat loot tokens needed"] > 0)
		need_to_do_daily_dungeon = true;
	
	string [int] daily_dungeon_aftercore_items_wanted; 
	
	if (__misc_state["In aftercore"])
	{
		int tokens_needed = 0;
		if (!__misc_state["familiars temporarily missing"])
		{
			if (!have_familiar($familiar[gelatinous cubeling]) && $item[dried gelatinous cube].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("gelatinous cubeling");
				tokens_needed += 27;
			}
		}
		if (!__misc_state["skills temporarily missing"])
		{
			if (!have_skill($skill[singer's faithful ocelot]) && $item[Spellbook: Singer's Faithful Ocelot].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("Singer's faithful ocelot");
				tokens_needed += 15;
			}
			if (!have_skill($skill[Drescher's Annoying Noise]) && $item[Spellbook: Drescher's Annoying Noise].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("Drescher's Annoying Noise");
				tokens_needed += 15;
			}
			if (!have_skill($skill[Walberg's Dim Bulb]) && $item[Spellbook: Walberg's Dim Bulb].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("Walberg's Dim Bulb");
				tokens_needed += 15;
			}
		}
		if (tokens_needed > $item[fat loot token].available_amount())
		{
			need_to_do_daily_dungeon = true;
			__misc_state_int["fat loot tokens needed"] += tokens_needed - $item[fat loot token].available_amount();
		}
	}
	
	boolean delay_daily_dungeon = false;
	string delay_daily_dungeon_reason = "";
	if (need_to_do_daily_dungeon)
	{
		if (familiar_is_usable($familiar[gelatinous cubeling]))
		{
			if ($item[eleven-foot pole].available_amount() == 0 || $item[ring of detect boring doors].available_amount() == 0 || $item[pick-o-matic lockpicks].available_amount() == 0)
			{
				delay_daily_dungeon = true;
				delay_daily_dungeon_reason = "Bring along the gelatinous cubeling first";
				ChecklistSubentry subentry;
			
                string url = "";
                if (my_familiar() != $familiar[gelatinous cubeling])
                    url = "familiar.php";
				subentry.header = "Bring along the gelatinous cubeling";
			
				subentry.entries.listAppend("Acquire items to speed up the daily dungeon.");
			
				optional_task_entries.listAppend(ChecklistEntryMake("__familiar gelatinous cubeling", url, subentry));
			}
		}
		else
		{
			//No gelatinous cubeling.
			//But! We can acquire a skeleton key in-run.
			//So suggest doing that:
			boolean can_make_skeleton_key = ($item[loose teeth].available_amount() > 0 && $item[skeleton bone].available_amount() > 0);
			
			if ($item[pick-o-matic lockpicks].available_amount() == 0 && $item[skeleton key].available_amount() == 0 && (!__quest_state["Level 7"].state_boolean["nook finished"] || can_make_skeleton_key)) //they don't have lockpicks or a key, and they can reasonably acquire a key
			{
				delay_daily_dungeon = true;
				if (can_make_skeleton_key)
					delay_daily_dungeon_reason = "Make a skeleton key first. (you have the ingredients)";
				else
					delay_daily_dungeon_reason = "Acquire a skeleton key first. (from defiled nook)";
					
					
				if (can_make_skeleton_key)
				{
					//wonder if I should suggest this if they just can in general?
					ChecklistEntry cl = ChecklistEntryMake("__item skeleton key", "", ChecklistSubentryMake("Make a skeleton key", "", listMake("You have the ingredients.", "Speeds up the daily dungeon.")));
                    if (__last_adventure_location == $location[The Daily Dungeon])
                    {
                        cl.importance_level = -1;
                        task_entries.listAppend(cl);
                    }
                    else
                        optional_task_entries.listAppend(cl);
				}
			}
		}
	}
    
    if (get_property_int("_lastDailyDungeonRoom") > 0)
        need_to_do_daily_dungeon = true;
	if (need_to_do_daily_dungeon && !get_property_boolean("dailyDungeonDone"))
	{
		if (delay_daily_dungeon)
		{
			future_task_entries.listAppend(ChecklistEntryMake("daily dungeon", "da.php", ChecklistSubentryMake("Daily Dungeon", "", delay_daily_dungeon_reason), $locations[the daily dungeon]));
		}
		else
		{
            string url = "da.php";
			string [int] description;
			string l;
            
            if (__misc_state_int["fat loot tokens needed"] > 0)
                l = pluralize(__misc_state_int["fat loot tokens needed"], "token", "tokens") + " needed.";
			
			if (daily_dungeon_aftercore_items_wanted.count() > 0)
                l += "|Misssing " + daily_dungeon_aftercore_items_wanted.listJoinComponents(", ", "and") + ". Possibly buy them in the mall?";
				//l += HTMLGenerateIndentedText(daily_dungeon_aftercore_items_wanted);
            if (l.length() > 0)
                description.listAppend(l);
			if (!__misc_state["In Aftercore"])
			{
				string submessage = "";
				if (familiar_is_usable($familiar[gelatinous cubeling]))
					submessage = "";
				if (__misc_state["zap wand available"] && __misc_state_int["DD Tokens and keys available"] > 0)
					submessage = "Or zap for it";
				if (submessage.length() > 0)
					description.listAppend(submessage);
			}
			
			if (!in_ronin() && !have_familiar($familiar[gelatinous cubeling]))
			{
				string [int] shopping_list;
				foreach it in $items[eleven-foot pole,ring of detect boring doors,pick-o-matic lockpicks]
				{
					if (it.available_amount() > 0)
						continue;
					if (it == $item[pick-o-matic lockpicks] && $item[skeleton key].available_amount() > 0)
						continue;
					shopping_list.listAppend(it);
				}
				if (shopping_list.count() > 0)
					description.listAppend("Buy " + shopping_list.listJoinComponents(", ", "and") + " from mall.");
			}
			
            int rooms_left = MAX(0, 15 - get_property_int("_lastDailyDungeonRoom"));
            boolean need_ring = true;
            if (get_property_int("_lastDailyDungeonRoom") > 10)
            {
                need_ring = false;
            }
			if ($item[ring of detect boring doors].available_amount() > 0 && need_ring)
			{
				if ($item[ring of detect boring doors].equipped_amount() == 0)
                {
                    url = "inventory.php?which=2";
					description.listAppend("Wear the ring of detect boring doors.");
                }
				else
					description.listAppend("Keep the ring of detect boring doors equipped.");
			}
			
            if (rooms_left < 15)
                description.listAppend(pluralizeWordy(rooms_left, "room", "rooms").capitalizeFirstLetter() + " left.");
			
			optional_task_entries.listAppend(ChecklistEntryMake("daily dungeon", url, ChecklistSubentryMake("Daily Dungeon", "", description), $locations[the daily dungeon]));
		}
	}

}