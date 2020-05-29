RegisterTaskGenerationFunction("SAreaUnlocksGenerateTasks");
void SAreaUnlocksGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__misc_state["desert beach available"] && __misc_state["in run"] && my_path_id() != PATH_NUCLEAR_AUTUMN)
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
        if (my_path_id() == PATH_NUCLEAR_AUTUMN)
        {
            subentry.entries.listAppend("Wait until level eleven, which will unlock it autumnaically.");
        }
		else if (!knoll_available())
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
		if (my_path_id() == PATH_COMMUNITY_SERVICE)
        {
        	subentry.header += "?";
            subentry.entries.listAppend("Or not...?");
        }
        
        string url;
        boolean suggest_hippy_alternative = false;
        if (my_path_id() == PATH_NUCLEAR_AUTUMN)
        {
            suggest_hippy_alternative = true;
        }
        
        
        if (!(my_path_id() == PATH_NUCLEAR_AUTUMN && in_hardcore()))
        {
            if (__misc_state["desert beach available"])
                url = "place.php?whichplace=desertbeach";
            int scrip_number = $item[Shore Inc. Ship Trip Scrip].available_amount();
            int trips_needed = MAX(0, 3 - scrip_number);
            
            if ($item[dinghy plans].available_amount() > 0)
            {
                if ($item[dingy planks].available_amount() > 0)
                {
                    url = "inventory.php?which=3&ftext=dinghy+plans";
                    subentry.entries.listAppend("Use dinghy plans.");
                }
                else
                {
                    if (my_path_id() == PATH_NUCLEAR_AUTUMN)
                    {
                        subentry.entries.listAppend("Pull dingy planks, then build dinghy dinghy.");
                    }
                    else
                    {
                        url = "shop.php?whichshop=generalstore";
                        subentry.entries.listAppend("Buy dingy planks, then build dinghy dinghy.");
                    }
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
                if (!__misc_state["desert beach available"])
                    line_string += ", once the desert beach is unlocked";
                line_string += ".";
                int meat_needed = trip_meat_cost * trips_needed;
                if (my_meat() < meat_needed)
                    line_string += "|Need " + meat_needed + " meat for vacations, have " + my_meat() + ".";
                subentry.entries.listAppend(line_string);
                if ($item[skeleton].available_amount() > 0)
                    subentry.entries.listAppend("Skeletal skiff?");
            }
            else
            {
                url = "shop.php?whichshop=shore";
                subentry.entries.listAppend("Redeem scrip at shore for dinghy plans.");
            }
        }
        if (suggest_hippy_alternative)
        {
            string line_string = "Or try";
            if (my_path_id() == PATH_NUCLEAR_AUTUMN && in_hardcore())
                line_string = "Try";
            line_string += " the hippy quest in the woods";
            if (my_basestat(my_primestat()) < 25)
                line_string += ", once your mainstat reaches 25";
            else if (url == "")
                url = "place.php?whichplace=woods";
            line_string += ".";
            if (my_path_id() != PATH_NUCLEAR_AUTUMN)
                line_string += " (probably slower?)";
            subentry.entries.listAppend(line_string);
        }
        if (my_path_id() == PATH_NUCLEAR_AUTUMN && ($familiar[ms. puck man].familiar_is_usable() || $familiar[puck man].familiar_is_usable()))
        {
            string line = "Or build a yellow submarine.";
            string [int] missing_components = $item[yellow submarine].missingComponentsToMakeItemInHumanReadableFormat();
            if (missing_components.count() > 0)
                line += " Need " + missing_components.listJoinComponents(", ", "and") + ".";
            subentry.entries.listAppend(line);
        }
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeGasTank").length() == 0)
            subentry.entries.listAppend("Possibly upgrade your motorcycle's gas tank. (extra-buoyant)");
        
        
		ChecklistEntry entry = ChecklistEntryMake("__item dingy dinghy", url, subentry, $locations[the shore\, inc. travel agency]);
        if (my_path_id() == PATH_COMMUNITY_SERVICE)
        	optional_task_entries.listAppend(entry);
        else
        	task_entries.listAppend(entry);
        
	}
}
