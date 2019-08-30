import "relay/Guide/QuestState.ash"
import "relay/Guide/Support/Checklist.ash"

boolean [item] __pulls_reasonable_to_buy_in_run;

int pullable_amount(item it, int maximum_total_wanted)
{
	boolean buyable_in_run = false;
	if (__pulls_reasonable_to_buy_in_run contains it)
		buyable_in_run = true;
    if (it.tradeable && it.historical_price() > 0 && it.historical_price() < 50000)
    	buyable_in_run = true;
	if (maximum_total_wanted == 0)
		maximum_total_wanted = __misc_state_int["pulls available"] + it.available_amount();
	if (__misc_state["Example mode"]) //simulate pulls
	{
		if (buyable_in_run)
			return min(__misc_state_int["pulls available"], maximum_total_wanted);
		else
			return min(__misc_state_int["pulls available"], min(storage_amount(it) + it.available_amount(), maximum_total_wanted));
	}
	
	int amount = storage_amount(it);
	if (buyable_in_run)
		amount = 20;
	int total_amount = amount + it.available_amount();
	
	if (total_amount > maximum_total_wanted)
	{
		amount = maximum_total_wanted - it.available_amount();
	}
	
	if (amount < 0) amount = 0;
	return min(__misc_state_int["pulls available"], amount);
}

int pullable_amount(item it)
{
	return pullable_amount(it, 0);
}


//generic pull item
record GPItem
{
	//Either item OR alternate_name
	item it;
	string alternate_name;
	string alternate_image_name;
	
	string reason;
	int max_wanted;
};

GPItem GPItemMake(item it, string reason, int max_wanted)
{
	GPItem result;
	result.it = it;
	result.reason = reason;
	result.max_wanted = max_wanted;
	return result;
}

GPItem GPItemMake(item it, string reason)
{
	return GPItemMake(it, reason, 1);
}

GPItem GPItemMake(string alternate_name, string alternate_image_name, string reason)
{
	GPItem result;
	result.alternate_name = alternate_name;
	result.alternate_image_name = alternate_image_name;
	result.reason = reason;
	result.max_wanted = 1;
	return result;
}

void listAppend(GPItem [int] list, GPItem entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void generatePullList(Checklist [int] checklists)
{
    //Needs improvement.
	ChecklistEntry [int] pulls_entries;
	
	int pulls_available = __misc_state_int["pulls available"];
	if (pulls_available <= 0)
		return;
	if (pulls_available > 0)
		pulls_entries.listAppend(ChecklistEntryMake("special subheader", "", ChecklistSubentryMake(pluralise(pulls_available, "pull", "pulls") + " remaining")));
	
	item [int] pullable_list_item;
	int [int] pullable_list_max_wanted;
	string [int] pullable_list_reason;
	
	GPItem [int] pullable_item_list;
    
    boolean combat_items_usable = true;
    if (my_path_id() == PATH_POCKET_FAMILIARS)
    	combat_items_usable = false;
    
    if (my_path_id() == PATH_COMMUNITY_SERVICE)
    	pullable_item_list.listAppend(GPItemMake($item[pocket wish], "Saves turns on everything in Community Service.", 20));
    if (__misc_state["need to level"])
    {
        if (my_primestat() == $stat[muscle])
        {
            pullable_item_list.listAppend(GPItemMake($item[fake washboard], "+25% to mainstat gain, offhand."));
            pullable_item_list.listAppend(GPItemMake($item[red LavaCo Lamp&trade;], "+5 adventures, 50 turns of +50% mainstat gain after rollover."));
        }
        else if (my_primestat() == $stat[mysticality])
        {
            pullable_item_list.listAppend(GPItemMake($item[basaltamander buckler], "+25% to mainstat gain, offhand."));
            pullable_item_list.listAppend(GPItemMake($item[blue LavaCo Lamp&trade;], "+5 adventures, 50 turns of +50% mainstat gain after rollover."));
            if (my_path_id() == PATH_THE_SOURCE)
            {
                int amount = 3;
                if ($item[battle broom].available_amount() > 0)
                    amount = 2;
                pullable_item_list.listAppend(GPItemMake($item[wal-mart nametag], "+4 mainstat/fight", amount));
            }
        }
        else if (my_primestat() == $stat[moxie])
        {
            pullable_item_list.listAppend(GPItemMake($item[backwoods banjo], "+20% to mainstat gain, 2h weapon."));
            pullable_item_list.listAppend(GPItemMake($item[green LavaCo Lamp&trade;], "+5 adventures, 50 turns of +50% mainstat gain after rollover."));
            if (my_path_id() == PATH_THE_SOURCE)
                pullable_item_list.listAppend(GPItemMake($item[wal-mart overalls], "+4 mainstat/fight"));
        }
    }
	
	//IOTMs:
	if ($item[empty rain-doh can].available_amount() == 0 && $item[can of rain-doh].available_amount() == 0)
		pullable_item_list.listAppend(GPItemMake($item[can of rain-doh], "5 copies/day|everything really", 1));
	if ($items[empty rain-doh can,can of rain-doh,spooky putty monster].available_amount() == 0)
		pullable_item_list.listAppend(GPItemMake($item[spooky putty sheet], "5 copies/day", 1));
    if (true)
    {
        string line = "So many things!";
        if ($item[over-the-shoulder folder holder].storage_amount() > 0)
        {
            string [int] description;
            string [item] folder_descriptions;
            
            folder_descriptions[$item[folder (red)]] = "+20 muscle";
            folder_descriptions[$item[folder (blue)]] = "+20 myst";
            folder_descriptions[$item[folder (green)]] = "+20 moxie";
            folder_descriptions[$item[folder (magenta)]] = "+15 muscle +15 myst";
            folder_descriptions[$item[folder (cyan)]] = "+15 myst +15 moxie";
            folder_descriptions[$item[folder (yellow)]] = "+15 muscle +15 moxie";
            folder_descriptions[$item[folder (smiley face)]] = "+2 muscle stat/fight";
            folder_descriptions[$item[folder (wizard)]] = "+2 myst stat/fight";
            folder_descriptions[$item[folder (space skeleton)]] = "+2 moxie stat/fight";
            folder_descriptions[$item[folder (D-Team)]] = "+1 stat/fight";
            folder_descriptions[$item[folder (Ex-Files)]] = "+5% combat";
            folder_descriptions[$item[folder (skull and crossbones)]] = "-5% combat";
            folder_descriptions[$item[folder (Knight Writer)]] = "+40% init";
            folder_descriptions[$item[folder (Jackass Plumber)]] = "+25 ML";
            folder_descriptions[$item[folder (holographic fractal)]] = "+4 all res";
            folder_descriptions[$item[folder (barbarian)]] = "stinging damage";
            folder_descriptions[$item[folder (rainbow unicorn)]] = "prismatic stinging damage";
            folder_descriptions[$item[folder (Seawolf)]] = "-pressure penalty";
            folder_descriptions[$item[folder (dancing dolphins)]] = "+50% item (underwater)";
            folder_descriptions[$item[folder (catfish)]] = "+15 familiar weight (underwater)";
            folder_descriptions[$item[folder (tranquil landscape)]] = "15 DR / 15 HP & MP regen";
            folder_descriptions[$item[folder (owl)]] = "+500% item (dreadsylvania)";
            folder_descriptions[$item[folder (Stinky Trash Kid)]] = "passive stench damage";
            folder_descriptions[$item[folder (sports car)]] = "+5 adv";
            folder_descriptions[$item[folder (sportsballs)]] = "+5 PVP fights";
            folder_descriptions[$item[folder (heavy metal)]] = "+5 familiar weight";
            folder_descriptions[$item[folder (Yedi)]] = "+50% spell damage";
            folder_descriptions[$item[folder (KOLHS)]] = "+50% item (KOLHS)";
            
            foreach s in $slots[folder1,folder2,folder3]
            {
                item folder = s.equipped_item();
                if (folder == $item[none]) continue;
                
                if (folder_descriptions contains folder)
                    description.listAppend(folder_descriptions[folder]);
            }
            if (description.count() > 0)
                line = description.listJoinComponents(" / ");
        }
        pullable_item_list.listAppend(GPItemMake($item[over-the-shoulder folder holder], line, 1));
    }
    
	pullable_item_list.listAppend(GPItemMake($item[pantsgiving], "5x banish/day|+2 stats/fight|+15% items|2 extra fullness (realistically)", 1));
    if (!__misc_state["familiars temporarily blocked"]) //relevant in heavy rains, on the +item/+meat underwater familiars
        pullable_item_list.listAppend(GPItemMake($item[snow suit], "+20 familiar weight for a while" + (($familiar[pair of stomping boots].is_unrestricted() && __misc_state["free runs usable"]) ? ", +4 free runs" : "") + "|+10% item|spleen items", 1));
    if (!__misc_state["familiars temporarily blocked"] && ($item[protonic accelerator pack].available_amount() == 0 || $familiar[machine elf].familiar_is_usable())) //if you have a machine elf, it might be worth pulling a bjorn with a protonic pack anyways
    {
        if ($item[Buddy Bjorn].storage_amount() > 0)
            pullable_item_list.listAppend(GPItemMake($item[Buddy Bjorn], "+10ML/+lots MP hat|or +item/+init/+meat/etc", 1));
        else if ($item[buddy bjorn].available_amount() == 0)
            pullable_item_list.listAppend(GPItemMake($item[crown of thrones], "+10ML/+lots MP hat|or +item/+init/+meat/etc", 1));
    }
	pullable_item_list.listAppend(GPItemMake($item[boris's helm], "+15ML/+5 familiar weight/+init/+mp regeneration/+weapon damage", 1));
    if (__misc_state["need to level"])
    {
        pullable_item_list.listAppend(GPItemMake($item[plastic vampire fangs], "Large stat gain, once/day.", 1));
        pullable_item_list.listAppend(GPItemMake($item[operation patriot shield], "+america", 1));
        pullable_item_list.listAppend(GPItemMake($item[the crown of ed the undying], "Various in-run modifiers. (init, HP, ML/item/meat/etc)", 1));
    }
    pullable_item_list.listAppend(GPItemMake($item[v for vivala mask], "?", 1));
	
	if (my_primestat() == $stat[mysticality] && my_path_id() != PATH_HEAVY_RAINS) //should we only suggest this for mysticality classes?
		pullable_item_list.listAppend(GPItemMake($item[Jarlsberg's Pan], "?", 1)); //"
	pullable_item_list.listAppend(GPItemMake($item[loathing legion knife], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[greatest american pants], "navel runaways|others", 1));
	pullable_item_list.listAppend(GPItemMake($item[juju mojo mask], "?", 1));
    if (__misc_state["free runs usable"])
    {
        pullable_item_list.listAppend(GPItemMake($item[navel ring of navel gazing], "free runaways|easy fights", 1));
        if (combat_items_usable)
	        pullable_item_list.listAppend(GPItemMake($item[mafia middle finger ring], "one free runaway/banish/day", 1));
    }
	//pullable_item_list.listAppend(GPItemMake($item[haiku katana], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[bottle-rocket crossbow], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[jekyllin hide belt], "+variable% item", 3));
    
    if (__misc_state["need to level"])
    {
        pullable_item_list.listAppend(GPItemMake($item[hockey stick of furious angry rage], "+30ML accessory.", 1));
    }
    pullable_item_list.listAppend(GPItemMake($item[ice sickle], "+15ML 1h weapon|+item/+meat/+init foldables", 1));
    if ($item[buddy bjorn].available_amount() == 0)
        pullable_item_list.listAppend(GPItemMake($item[camp scout backpack], "+15% items on back", 1));
    if (__misc_state["Torso aware"])
    {
        pullable_item_list.listAppend(GPItemMake($item[flaming pink shirt], "+15% items on shirt. (marginal)" + (__misc_state["familiars temporarily blocked"] ? "" : "|Or extra experience on familiar. (very marginal)"), 1));
        if (__misc_state["need to level"] && $item[Sneaky Pete's leather jacket (collar popped)].available_amount() == 0 && $item[Sneaky Pete's leather jacket].available_amount() == 0)
        {
            
            if ($item[Sneaky Pete's leather jacket (collar popped)].storage_amount() + $item[Sneaky Pete's leather jacket].storage_amount() > 0)
            {
                if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
                    pullable_item_list.listAppend(GPItemMake($item[Sneaky Pete's leather jacket], "+30ML/+meat/+adv/+init/+moxie shirt", 1));
            }
            else
                pullable_item_list.listAppend(GPItemMake($item[cane-mail shirt], "+20ML shirt", 1));
        }
    }
    if (__quest_state["Level 10"].mafia_internal_step >= 8)
    {
    	if (__quest_state["Level 10"].mafia_internal_step == 8 && $item[amulet of extreme plot significance].available_amount() == 0)
        {
        	pullable_item_list.listAppend(GPItemMake($item[amulet of extreme plot significance], "Speeds up castle basement.", 1));
        }
        if (!__quest_state["Level 10"].finished && $item[mohawk wig].available_amount() == 0)
        {
            pullable_item_list.listAppend(GPItemMake($item[mohawk wig], "Speeds up top floor of castle.", 1));
        }
    }
    if (my_path_id() != PATH_G_LOVER)
	    pullable_item_list.listAppend(GPItemMake($item[Clara's Bell], "Forces a non-combat, once/day.", 1));
    if (combat_items_usable)
    	pullable_item_list.listAppend(GPItemMake($item[replica bat-oomerang], "Saves three turns/day.", 1));
    
    if (__misc_state["spooky airport available"] && __misc_state["need to level"] && __misc_state["can drink just about anything"] && $effect[jungle juiced].have_effect() == 0)
    {
        pullable_item_list.listAppend(GPItemMake($item[jungle juice], "Drink that doubles stat-gain in the deep dark jungle.", 1));
    }
    
	
	boolean have_super_fairy = false;
	if ((familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0) || (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0))
		have_super_fairy = true;
	if (!have_super_fairy && my_path_id() != PATH_HEAVY_RAINS && false)
	{
		if (familiar_is_usable($familiar[fancypants scarecrow]))
			pullable_item_list.listAppend(GPItemMake($item[spangly mariachi pants], "2x fairy on fancypants scarecrow", 1));
		else if (familiar_is_usable($familiar[mad hatrack]))
			pullable_item_list.listAppend(GPItemMake($item[spangly sombrero], "2x fairy on mad hatrack", 1));
	}
	//pullable_item_list.listAppend(GPItemMake($item[jewel-eyed wizard hat], "a wizard is you!", 1));
	//pullable_item_list.listAppend(GPItemMake($item[origami riding crop], "+5 stats/fight, but only if the monster dies quickly", 1)); //not useful?
	//pullable_item_list.listAppend(GPItemMake($item[plastic pumpkin bucket], "don't know", 1)); //not useful?
	//pullable_item_list.listAppend(GPItemMake($item[packet of mayfly bait], "why let it go to waste?", 1));
	
	if ($items[greatest american pants, navel ring of navel gazing].available_amount() + pullable_amount($item[greatest american pants]) + pullable_amount($item[navel ring of navel gazing]) == 0)
		pullable_item_list.listAppend(GPItemMake($item[peppermint parasol], "free runaways", 1));
    
    
	if (__misc_state["can eat just about anything"] && availableFullness() > 0)
	{
        string [int] food_selections;
        
        if (__misc_state_int["fat loot tokens needed"] > 0)
        {
            string [int] which_pies;
            if ($items[boris's key,boris's key lime pie].available_amount() == 0 && my_path_id() != PATH_G_LOVER)
                which_pies.listAppend("Boris");
            if ($items[jarlsberg's key,jarlsberg's key lime pie].available_amount() == 0)
                which_pies.listAppend("Jarlsberg");
            if ($items[sneaky pete's key,sneaky pete's key lime pie].available_amount() == 0 && my_path_id() != PATH_G_LOVER)
                which_pies.listAppend("Sneaky Pete");
            string line;
            if (which_pies.count() > 0)
                line += which_pies.listJoinComponents("/") + "'s ";
            line += "key lime pie";
            if (which_pies.count() > 1)
                line += "s";
            food_selections.listAppend(line);
        }
        if (availableFullness() >= 5)
        {
            if (my_level() >= 13 && my_path_id() != PATH_G_LOVER)
                food_selections.listAppend("hi meins");
            else if ($item[moon pie].is_unrestricted() && my_path_id() != PATH_G_LOVER)
                food_selections.listAppend("moon pies");
            
            if (my_path_id() != PATH_G_LOVER)
	            food_selections.listAppend("fleetwood mac 'n' cheese" + (my_level() < 8 ? " (level 8)" : ""));
            if ($item[karma shawarma].is_unrestricted())
                food_selections.listAppend("karma shawarma? (expensive" + (my_level() < 7 ? ", level 7" : "") + ")");
            //FIXME maybe the new pasta?
        }
        
        string description;
        if (food_selections.count() > 0)
            description = food_selections.listJoinComponents(", ") + ", etc.";
		pullable_item_list.listAppend(GPItemMake("Food", "hell ramen", description));
	}
	if (__misc_state["can drink just about anything"] && availableDrunkenness() >= 0 && inebriety_limit() >= 5)
	{
        string [int] drink_selections;
        if ($item[wrecked generator].is_unrestricted())
            drink_selections.listAppend("wrecked generators");
        if ($item[Ice Island Long Tea].is_unrestricted())
            drink_selections.listAppend("Ice Island Long Tea");
        
        string description;
        if (drink_selections.count() > 0)
            description = drink_selections.listJoinComponents(", ") + ", etc.";
        
		pullable_item_list.listAppend(GPItemMake("Drink", "gibson", description));
	}
    
    //pullable_item_list.listAppend(GPItemMake($item[slimy alveolus], "40 turns of +50ML (" + floor(40 * 50 * __misc_state_float["ML to mainstat multiplier"]) +" mainstat total, cave bar levelling)|1 spleen", 3)); //marginal now. low-skill oil peak/cyrpt?
	
	
    if (!get_property_boolean("_blankoutUsed") && __misc_state["free runs usable"])
        pullable_item_list.listAppend(GPItemMake($item[bottle of blank-out], "run away from your problems", 1));
	
	
    if (!__quest_state["Level 11 Hidden City"].finished && !__quest_state["Level 11"].finished && (get_property_int("hiddenApartmentProgress") < 1 || get_property_int("hiddenBowlingAlleyProgress") < 1 || get_property_int("hiddenHospitalProgress") < 1 || get_property_int("hiddenOfficeProgress") < 1) && __misc_state["can equip just about any weapon"] && my_path_id() != PATH_POCKET_FAMILIARS)
    {
        boolean have_machete = false;
        foreach it in __dense_liana_machete_items
        {
            if (it.available_amount() > 0 && it.is_unrestricted())
                have_machete = true;
        }
        if (!have_machete)
        {
            if (my_basestat($stat[muscle]) < 62 && $item[machetito].is_unrestricted())
            {
                //machetito
                pullable_item_list.listAppend(GPItemMake($item[machetito], "Machete for dense liana", 1));
            }
            else if ($item[muculent machete].is_unrestricted() && my_path_id() != PATH_G_LOVER) //my_basestat($stat[muscle]) < 62 &&
            {
                //muculent machete, also gives +5% meat, op ti mal
                pullable_item_list.listAppend(GPItemMake($item[muculent machete], "Machete for dense liana", 1));
            }
            else
            {
                //antique machete
                pullable_item_list.listAppend(GPItemMake($item[antique machete], "Machete for dense liana", 1));
            }
        }
    }
	
	//Quest-relevant items:
	if ($familiar[Intergnat].familiar_is_usable() && my_path_id() != PATH_G_LOVER)
    {
        pullable_item_list.listAppend(GPItemMake($item[infinite BACON machine], "One copy/day with ~seven turns of intergnat.", 1));
    }
	if (!__quest_state["Level 9"].state_boolean["bridge complete"])
	{
		int boxes_needed = MIN(__quest_state["Level 9"].state_int["bridge fasteners needed"], __quest_state["Level 9"].state_int["bridge lumber needed"]) / 5;
		
		boxes_needed = MIN(6, boxes_needed); //bridge! farming?
		
		if (boxes_needed > 0 && my_path_id() != PATH_G_LOVER)
			pullable_item_list.listAppend(GPItemMake($item[smut orc keepsake box], "Skip level 9 bridge building.", boxes_needed));
	}
    if (__quest_state["Level 9"].state_int["peak tests remaining"] > 0)
    {
        int trimmers_needed = clampi(__quest_state["Level 9"].state_int["peak tests remaining"], 0, 4);
        if (trimmers_needed > 0)
			pullable_item_list.listAppend(GPItemMake($item[rusty hedge trimmers], "Speed up twin peak, burn delay.|Saves ~2 turns each?", trimmers_needed));
    }
	if (!__quest_state["Level 11 Palindome"].finished && $item[mega gem].available_amount() == 0 && ($item[wet stew].available_amount() + $item[wet stunt nut stew].available_amount() + $item[wet stew].creatable_amount() == 0) && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
		pullable_item_list.listAppend(GPItemMake($item[wet stew], "make into wet stunt nut stew|skip whitey's grove", 1));
    
    if (__quest_state["Level 11"].mafia_internal_step < 2)
        pullable_item_list.listAppend(GPItemMake($item[blackberry galoshes], "speed up black forest by 2-3? turns", 1));
        
    if (my_path_id() == PATH_HEAVY_RAINS)
        pullable_item_list.listAppend(GPItemMake($item[fishbone catcher's mitt], "offhand, less items washing away", 1));
    
        
    //OUTFITS: √Pirate outfit, √War outfit, √Ninja "outfit"
    if (!__quest_state["Level 12"].finished && (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues")))
    {
        item [int] missing_hippy_components = missing_outfit_components("War Hippy Fatigues");
        item [int] missing_frat_components = missing_outfit_components("Frat Warrior Fatigues");
        pullable_item_list.listAppend(GPItemMake("Island War Outfit", "__item round purple sunglasses", "<strong>Hippy</strong>: " + missing_hippy_components.listJoinComponents(", ", "and") + ".|<strong>Frat boy</strong>: " + missing_frat_components.listJoinComponents(", ", "and") + "."));
    }
    
    if (!__quest_state["Level 8"].state_boolean["Mountain climbed"] && !have_outfit_components("eXtreme Cold-Weather Gear"))
    {
        item [int] missing_ninja_components = items_missing($items[ninja carabiner, ninja crampons, ninja rope]);
        if (missing_ninja_components.count() > 0)
        {
            string description = missing_ninja_components.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".";
            
            if (numeric_modifier("cold resistance") < 5.0)
                description += "|Will require five " + HTMLGenerateSpanOfClass("cold", "r_element_cold") + " resist to use properly.";
            pullable_item_list.listAppend(GPItemMake("Ninja peak climbing", "__item " + missing_ninja_components[0], description));
        }
    }
    
    if (!__quest_state["Level 8"].state_boolean["Past mine"] && __quest_state["Level 8"].state_string["ore needed"] != "" && !$skill[unaccompanied miner].skill_is_usable())
    {
        item ore_needed = __quest_state["Level 8"].state_string["ore needed"].to_item();
        if (ore_needed != $item[none] && ore_needed.available_amount() < 3)
        {
            pullable_item_list.listAppend(GPItemMake(ore_needed, "Level 8 quest.", 3));
        }
    }
    
    //alas
    if (($item[talisman o' namsilat].available_amount() == 0 || !__quest_state["Level 9"].state_boolean["bridge complete"]) && !have_outfit_components("Swashbuckling Getup") && $item[pirate fledges].available_amount() == 0 && false)// && !__quest_state["Pirate Quest"].finished)
    {
        item [int] missing_outfit_components = missing_outfit_components("Swashbuckling Getup");
        if (missing_outfit_components.count() > 0)
        {
            string entry = missing_outfit_components.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".";
            if ($item[eyepatch].available_amount() == 0)
                entry += "|Or NPZR head/clockwork pirate skull to untinker for eyepatch/clockwork maid.";
            if (!__quest_state["Pirate Quest"].state_boolean["valid"])
            	entry += "|No, really! You can get a free bridge!";
            pullable_item_list.listAppend(GPItemMake("Swashbuckling Getup", "__item " + missing_outfit_components[0], entry));
        }
    }
    
    //FIXME suggest machetito?
    //FIXME suggest super marginal stuff in SCO or S&S
    //Ideas: Goat cheese, keepsake box, √spooky-gro fertilizer, harem outfit, perfume, rusty hedge trimmers, bowling ball, surgeon gear, tomb ratchets or tangles, all the other pies
    //FIXME suggest ore when we don't have access to free mining
    
    if (!have_outfit_components("Knob Goblin Elite Guard Uniform") && !__quest_state["Level 5"].finished)
    {
        item [int] missing_outfit_components = missing_outfit_components("Knob Goblin Harem Girl Disguise");
        
        string entry = missing_outfit_components.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".";
        entry += " Level 5 quest.";
        if (missing_outfit_components.count() > 0)
            pullable_item_list.listAppend(GPItemMake("Knob Goblin Harem Girl Disguise", "__item " + missing_outfit_components[0], entry));
    }
    if (!__misc_state["can reasonably reach -25% combat"])
    {
        if ((my_primestat() == $stat[moxie] || my_basestat($stat[moxie]) >= 35) && $item[iFlail].item_is_usable())
            pullable_item_list.listAppend(GPItemMake($item[iFlail], "-combat, +11 ML, +5 familiar weight"));
        if (__misc_state["Torso aware"] && $item[xiblaxian stealth vest].item_is_usable()) //FIXME exclusiveness with camouflage T-shirt. probably should pull camou if we're over muscle stat, otherwise stealth vest, or whichever we have
            pullable_item_list.listAppend(GPItemMake($item[xiblaxian stealth vest], "-combat shirt"));
        if ($item[duonoculars].item_is_usable())
	        pullable_item_list.listAppend(GPItemMake($item[duonoculars], "-combat, +5 ML"));
        pullable_item_list.listAppend(GPItemMake($item[ring of conflict], "-combat"));
        if (($item[red shoe].can_equip() || my_path_id() == PATH_GELATINOUS_NOOB) && $item[red shoe].item_is_usable())
            pullable_item_list.listAppend(GPItemMake($item[red shoe], "-combat"));
    }
	
	if (my_path_id() != PATH_COMMUNITY_SERVICE)
		pullable_item_list.listAppend(GPItemMake($item[ten-leaf clover], "Various turn saving.|Generic pull.", 20));
    
    if (!get_property_ascension("lastTempleUnlock") && $item[spooky-gro fertilizer].item_amount() == 0 && my_path_id() != PATH_G_LOVER)
        pullable_item_list.listAppend(GPItemMake($item[spooky-gro fertilizer], "Saves 2.5 turns while unlocking temple."));
	
	string [int] scrip_reasons;
	int scrip_needed = 0;
	if (!__misc_state["mysterious island available"] && $item[dinghy plans].available_amount() == 0)
	{
		scrip_needed += 3;
		scrip_reasons.listAppend("mysterious island");
	}
	if ($item[uv-resistant compass].available_amount() == 0 && $item[ornate dowsing rod].available_amount() == 0 && __misc_state["can equip just about any weapon"] && !__quest_state["Level 11 Desert"].state_boolean["Desert Explored"])
	{
		scrip_needed += 1;
		scrip_reasons.listAppend($item[uv-resistant compass].to_string());
	}
	if (scrip_needed > 0 && my_path_id() != PATH_COMMUNITY_SERVICE && my_path_id() != PATH_EXPLOSIONS)
	{
		pullable_item_list.listAppend(GPItemMake($item[Shore Inc. Ship Trip Scrip], "Saves three turns each.|" + scrip_reasons.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".", scrip_needed));
	}
    //FIXME add hat/stuffing fluffer/blank-out
    if (availableSpleen() >= 2 && my_path_id() != PATH_NUCLEAR_AUTUMN && my_path_id() != PATH_G_LOVER && my_path_id() != PATH_COMMUNITY_SERVICE)
    {
		pullable_item_list.listAppend(GPItemMake($item[turkey blaster], "Burns five turns of delay in last adventured area. Costs spleen, limited uses/day.", MIN(3 - get_property_int("_turkeyBlastersUsed"), MIN(availableSpleen() / 2, 3)))); //FIXME learn what this limit is. also suggest in advance?
    }
    if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"]) //only area that realistically could use it
    {
        pullable_item_list.listAppend(GPItemMake($item[gravy boat], "Wear to save two turns in the cyrpt.")); //marginal, especially since you're pulling a bunch of turkey blasters, but...
        
    }
    if (!__quest_state["Level 12"].finished && __quest_state["Level 12"].state_int["frat boys left on battlefield"] >= 936 && __quest_state["Level 12"].state_int["hippies left on battlefield"] >= 936)
    {
        pullable_item_list.listAppend(GPItemMake($item[stuffing fluffer], "Saves eight turns if you use two at the start of fighting in the war.", 2));
    }
    
    if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && __quest_state["Level 11 Desert"].state_int["Desert Exploration"] < 95)
    {
        if (!__quest_state["Level 11 Desert"].state_boolean["Wormridden"] && my_path_id() != PATH_G_LOVER)
            pullable_item_list.listAppend(GPItemMake($item[drum machine], "30% desert exploration with pages.", 1));
        if (!__quest_state["Level 11 Desert"].state_boolean["Killing Jar Given"] && $location[the haunted bedroom].locationAvailable())
            pullable_item_list.listAppend(GPItemMake($item[killing jar], "15% desert exploration.", 1));
        if (!__quest_state["Level 11 Desert"].state_boolean["Black Paint Given"] && my_path_id() == PATH_NUCLEAR_AUTUMN)
            pullable_item_list.listAppend(GPItemMake($item[can of black paint], "15% desert exploration.", 1));
    }
    if (__quest_state["Level 11 Ron"].mafia_internal_step <= 2 && __quest_state["Level 11 Ron"].state_int["protestors remaining"] > 1)
    {
        item [int] missing_freebird_components = items_missing($items[lynyrdskin cap,lynyrdskin tunic,lynyrdskin breeches,lynyrd musk]);
        if (missing_freebird_components.count() > 0)
        {
            string description = missing_freebird_components.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".";
            description += "|Plus four clovers. Skips the entire protestor zone in like four turns?";
            pullable_item_list.listAppend(GPItemMake("Weird copperhead NC strategy", "__item " + missing_freebird_components[0], description));
        }
        if (my_path_id() != PATH_GELATINOUS_NOOB)
	        pullable_item_list.listAppend(GPItemMake($item[deck of lewd playing cards], "+138 sleaze damage equip for copperhead NC.", 1));
        
    }
    
    if (__misc_state["need to level"] && __misc_state["Chateau Mantegna available"] && __misc_state_int["free rests remaining"] > 0 && false)
    {
        //This is not currently suggested because I'm not sure if it's worth it for anyone but unrestricted or the very high end speed ascension.
        //It seems to give about as much stats as a good clover, which you can also pull, and are much cheaper.
        //Unrestricted has up to 17 free rests. That's around 680 extra stats, which is fairly good. But leveling isn't as much of a problem either... or is it?
        item dis_item = $item[none];
        if (my_primestat() == $stat[muscle])
            dis_item = $item[baobab sap];
        else if (my_primestat() == $stat[mysticality])
            dis_item = $item[desktop zen garden];
        else if (my_primestat() == $stat[moxie])
            dis_item = $item[Marvin's marvelous pill];
        int ideal_extra_stats_worth = 20 * (__misc_state_int["free rests remaining"] + total_free_rests());
        if (dis_item != $item[none] && dis_item.to_effect().have_effect() == 0)
            pullable_item_list.listAppend(GPItemMake(dis_item, "+20% mainstat gain.|Use with Chateau resting; at the end of the day, rest with this potion active to gain extra stats.<br>Then rest again after rollover.<br>Worth up to " + ideal_extra_stats_worth + " " + my_primestat() + ".", 1));
        
    }
    if ($item[Mr. Cheeng's spectacles] != $item[none])
        pullable_item_list.listAppend(GPItemMake($item[Mr. Cheeng's spectacles], "+15% item, +30% spell damage, acquire random potions in-combat.|Not particularly optimal, but fun."));
    if (availableSpleen() > 0 && my_path_id() != PATH_LIVE_ASCEND_REPEAT)
	    pullable_item_list.listAppend(GPItemMake($item[stench jelly], "Skips ahead to an NC, saves 2.5? turns each.", 20));
     
    if ($item[pocket wish].item_is_usable())
	    pullable_item_list.listAppend(GPItemMake($item[pocket wish], "Saves turns?", 20));   
    
    //int pills_pullable = clampi(20 - (get_property_int("_powerPillUses") + $item[power pill].available_amount()), 0, 20);
    int pills_pullable = clampi(20 - get_property_int("_powerPillUses"), 0, 20);
    if (pills_pullable > 0 && ($familiar[ms. puck man].have_familiar() || $familiar[puck man].have_familiar()))
    {
        pullable_item_list.listAppend(GPItemMake($item[power pill], "Saves one turn each.", pills_pullable));
    }
    if (my_meat() < 1000)
        pullable_item_list.listAppend(GPItemMake($item[1\,970 carat gold], "Autosells for 19700 meat.|Not optimal in the slightest.", 1));
	if ($skill[ancestral recall].have_skill() && my_adventures() < 10)
    {
        int casts = get_property_int("_ancestralRecallCasts");
        if (casts < 10)
            pullable_item_list.listAppend(GPItemMake($item[blue mana], "+3 adventures each.|Probably a bad idea.", clampi(10 - casts, 0, 10)));
    }
    if (my_path_id() == PATH_GELATINOUS_NOOB || my_path_id() == PATH_NUCLEAR_AUTUMN)
    {
        pullable_item_list.listAppend(GPItemMake($item[filthy lucre], "Turn into odor extractors for olfaction.", 6));
    }
    if (my_path_id() != PATH_SLOW_AND_STEADY)
    {
    	//unify these... later...
        foreach it in $items[mafia thumb ring,License to Chill,etched hourglass]
            pullable_item_list.listAppend(GPItemMake(it, "lazy turngen", 1));
    }
    
	
	boolean currently_trendy = (my_path_id() == PATH_TRENDY);
	foreach key in pullable_item_list
	{
		GPItem gp_item = pullable_item_list[key];
		string reason = gp_item.reason;
		string [int] reason_list = split_string_alternate(reason, "\\|");
		
		if (gp_item.alternate_name != "")
		{
			pulls_entries.listAppend(ChecklistEntryMake(gp_item.alternate_image_name, "storage.php", ChecklistSubentryMake(gp_item.alternate_name, "", reason_list)));
			continue;
		}
		
		
		item [int] items;
		int [item] related_items = get_related(gp_item.it, "fold");
		if (related_items.count() == 0)
			items.listAppend(gp_item.it);
		else
		{
			foreach it in related_items
				items.listAppend(it);
		}
		
		
		int max_wanted = gp_item.max_wanted;
		
        int found_total;
        foreach key, it in items
        {
            found_total += it.available_amount();
        }
        if (found_total >= max_wanted)
            continue;
        if (my_path_id() == PATH_GELATINOUS_NOOB)
        {
            boolean allowed = false;
            boolean [item] whitelist = $items[gravy boat,blackberry galoshes,machetito,muculent machete,antique machete,Mr. Cheeng's spectacles,buddy bjorn,crown of thrones,navel ring of navel gazing,greatest american pants,plastic vampire fangs,the jokester's gun];
            foreach key, it in items
            {
                if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot() && !(whitelist contains it) && !it.discardable && !__items_in_outfits[it])
                {
                }
                else
                    allowed = true;
            }
            if (!allowed)
            {
                //print_html("Rejecting " + items[0]);
                continue;
            }
        }
		
		foreach key in items
		{
			item it = items[key];
			if (currently_trendy && !is_trendy(it))
				continue;
            if (!is_unrestricted(it))
                continue;
            //if (!it.is_unrestricted()) continue; //FIXME uncomment next point release
			int actual_amount = pullable_amount(it, max_wanted);
			if (actual_amount > 0)
			{
                string url = "storage.php";
                if (it != $item[none])
                {
                    if (it.fullness > 0 || it.inebriety > 0)
                        url = "storage.php?which=1";
                    if (it.to_slot() != $slot[none])
                        url = "storage.php?which=2";
                }
              
                if (it.storage_amount() == 0 && (__pulls_reasonable_to_buy_in_run contains it) && it != $item[ten-leaf clover] && it != $item[none])
                    url = "mall.php";
              
				if (max_wanted == 1)
					pulls_entries.listAppend(ChecklistEntryMake(it, url, ChecklistSubentryMake(it, "", reason_list)));
				else
					pulls_entries.listAppend(ChecklistEntryMake(it, url, ChecklistSubentryMake(pluralise(actual_amount, it), "", reason_list)));
				break;
			}
		}
	}
	
	checklists.listAppend(ChecklistMake("Suggested Pulls", pulls_entries));
}

void PullsInit()
{
    //Pulls which are reasonable to buy in the mall, then pull:
	__pulls_reasonable_to_buy_in_run = $items[peppermint parasol,slimy alveolus,bottle of blank-out,disassembled clover,ten-leaf clover,ninja rope,ninja crampons,ninja carabiner,clockwork maid,sonar-in-a-biscuit,knob goblin perfume,chrome ore,linoleum ore,asbestos ore,goat cheese,enchanted bean,dusty bottle of Marsala,dusty bottle of Merlot,dusty bottle of Muscat,dusty bottle of Pinot Noir,dusty bottle of Port,dusty bottle of Zinfandel,ketchup hound,lion oil,bird rib,stunt nuts,drum machine,beer helmet,distressed denim pants,bejeweled pledge pin,reinforced beaded headband,bullet-proof corduroys,round purple sunglasses,wand of nagamar,ng,star crossbow,star hat,star staff,star sword,Star key lime pie,Boris's key lime pie,Jarlsberg's key lime pie,Sneaky Pete's key lime pie,tomb ratchet,tangle of rat tails,swashbuckling pants,stuffed shoulder parrot,eyepatch,Knob Goblin harem veil,knob goblin harem pants,knob goblin elite polearm,knob goblin elite pants,knob goblin elite helm,cyclops eyedrops,mick's icyvapohotness inhaler,large box,marzipan skull,jaba&ntilde;ero-flavored chewing gum,handsomeness potion,Meleegra&trade; pills,pickle-flavored chewing gum,lime-and-chile-flavored chewing gum,gremlin juice,wussiness potion,Mick's IcyVapoHotness Rub,super-spiky hair gel,adder bladder,black no. 2,skeleton,rock and roll legend,wet stew,glass of goat's milk,hot wing,frilly skirt,pygmy pygment,wussiness potion,gremlin juice,adder bladder,Angry Farmer candy,thin black candle,super-spiky hair gel,Black No. 2,Mick's IcyVapoHotness Rub,Frigid ninja stars,Spider web,Sonar-in-a-biscuit,Black pepper,Pygmy blowgun,Meat vortex,Chaos butterfly,Photoprotoneutron torpedo,Fancy bath salts,inkwell,Hair spray,disease,bronzed locust,Knob Goblin firecracker,powdered organs,leftovers of indeterminate origin,mariachi G-string,NG,plot hole,baseball,razor-sharp can lid,tropical orchid,stick of dynamite,barbed-wire fence,smut orc keepsake box,spooky-gro fertilizer,machetito,muculent machete,antique machete,rusty hedge trimmers,Ice Island Long Tea,killing jar,can of black paint,gravy boat,ring of conflict,bram's choker,duonoculars];
}
