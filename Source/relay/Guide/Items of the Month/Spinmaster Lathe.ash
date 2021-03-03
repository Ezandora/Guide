
RegisterGenerationFunction("IOTMSpinmasterLatheGenerate");
void IOTMSpinmasterLatheGenerate(ChecklistCollection checklists)
{
	if (!get_property_boolean("_spinmasterLatheVisited") && lookupItem("SpinMaster&trade; lathe").have())
	{
        checklists.add(C_OPTIONAL_TASKS, ChecklistEntryMake("__item SpinMaster&trade; lathe", "inventory.php?which=3&ftext=SpinMaster&amp;trade;+lathe", ChecklistSubentryMake("Collect SpinMaster&trade; hardwood", "", "Use your SpinMaster&trade; lathe."), 1));
	}
	
	item hardwood = lookupItem("flimsy hardwood scraps");
	
	if (true)
	{
		string [int] description;
        //Show options:
        string [item] creations_descriptions = {
	        lookupItem("beechwood blowgun"):"+100% ranged damage, +25 moxie, +5 moxie stat/fight, disappears<hr>Poison Dart combat skill once/fight (50% HP + zeno damage)",
	        lookupItem("birch battery"):"+100 MP, ~17MP regen, disappears",
	        lookupItem("ebony epee"):"+100% weapon damage, +25 muscle, +5 muscle stat/fight, disappears<hr>Disarming Thrust combat skill once/fight (reduces ~30% monster attack)",
	        lookupItem("maple magnet"):"Collects rare wood, +100 HP, +50% weapon drop, +50% acc drop, disappears",
	        lookupItem("weeping willow wand"):"+100% spell damage, +25 myst, +5 myst stat/fight, disappears<hr>Barrage of Tears combat skill once/fight (physical/spooky damage, 25% monster HP each)",
            
	        lookupItem("hemlock helm"):"+100% muscle, +30 ML, +5 fights/day",
	        lookupItem("balsam barrel"):"+50% stats, +15% item, 15 HP/MP regen",
	        lookupItem("purpleheart \"pants\""):"+100% moxie, +50% init, +5 adv/day",
	        lookupItem("wormwood wedding ring"):"+100% myst, +50% meat, +30 spooky damage/spell damage, +3 spooky res",
	        lookupItem("redwood rain stick"):"+20% item (20 turns)",
	        lookupItem("drippy diadem"):"Protects against The Drip",
        };
        
        item [int] display_order =
        {
            lookupItem("beechwood blowgun"),
            lookupItem("birch battery"),
            lookupItem("ebony epee"),
            lookupItem("maple magnet"),
            lookupItem("weeping willow wand"),
            lookupItem("hemlock helm"),
            lookupItem("balsam barrel"),
            lookupItem("purpleheart pants"),
            lookupItem("wormwood wedding ring"),
            lookupItem("redwood rain stick"),
            lookupItem("drippy diadem"),
        };
        string [item] location_to_farm_item_components = {
	        lookupItem("hemlock helm"):"Dreadsylvanian Woods",
	        lookupItem("balsam barrel"):"The Smut Orc Logging Camp",
	        lookupItem("purpleheart \"pants\""):"The Purple Light District",
	        lookupItem("wormwood wedding ring"):"The Worm Wood",
	        lookupItem("redwood rain stick"):"The Jungles of Ancient Loathing",
	        lookupItem("drippy diadem"):"The Dripping Trees",
        };
        item [item] secondary_components = {
	        lookupItem("hemlock helm"):lookupItem("Dreadsylvanian hemlock"),
	        lookupItem("balsam barrel"):lookupItem("sweaty balsam"),
	        lookupItem("purpleheart \"pants\""):lookupItem("purpleheart logs"),
	        lookupItem("wormwood wedding ring"):lookupItem("wormwood stick"),
	        lookupItem("redwood rain stick"):lookupItem("ancient redwood"),
	        lookupItem("drippy diadem"):lookupItem("Dripwood slab"),
        };
        boolean have_hardwood = hardwood.have();
        foreach key, it in display_order
        {
            if (!(secondary_components contains it))
            {
            	//hardwood:
                if (!__misc_state["in run"])
                	continue;
                if (!have_hardwood)
	            	continue;
            }
            
            int amount_needed = 1;
            //assumption: weapon_hands() always returns zero for non-weapons
            if (it.weapon_hands() == 1)
            {
            	amount_needed = maximumSimultaneous1hWeaponsEquippable();
            }
            if (it.available_amount() >= amount_needed) continue;
            
            
        	string item_description = creations_descriptions[it];
            string base_description = it.getBasicItemDescription();
            string line = "<strong>" + it.capitaliseFirstLetter() + "</strong>: " + base_description + "|*" + item_description;
            
            
        	if (secondary_components contains it && secondary_components[it].available_amount() == 0)
            {
            	if (in_ronin())
                {
                	continue;
                }
                else
                {
                	if (location_to_farm_item_components contains it)
                    	line += "|*Collect wood components in " + location_to_farm_item_components[it] + (!lookupItem("maple magnet").equipped() ? " with the maple magnet equipped" : "") + ".";
                	line = HTMLGenerateSpanFont(line, "grey");
                }
            }
        	description.listAppend(line);
        }
        if (description.count() > 0)
        {
        	checklists.add(C_RESOURCES, ChecklistEntryMake("__item " + hardwood, "shop.php?whichshop=lathe", ChecklistSubentryMake(pluralise(hardwood), "", description), 5));
        }
	}
}
