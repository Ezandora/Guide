RegisterGenerationFunction("IOTMRedNosedSnapperGenerate");
void IOTMRedNosedSnapperGenerate(ChecklistCollection checklists)
{
	familiar snapper_familiar = lookupFamiliar("Red-Nosed Snapper");
	if (!snapper_familiar.have_familiar() || __misc_state["familiars temporarily blocked"]) return;
	
	
	//List all(?) combat items
	//Relevant...
	
	
	
	boolean [phylum] blocked_phylums_for_inventory_display = $phylums[penguin,goblin,orc];
	//boolean [phylum] allowed_phylums_for_always_inventory_display = $phylums[dude, horror];
	string [phylum] phylum_reward_description =
	{
		$phylum[none]:"nothing",
        $phylum[orc]:"booze (12.5 adventures)",
        $phylum[constellation]:"yellow ray combat item",
        $phylum[dude]:"free banish combat item",
        $phylum[horror]:"free kill combat item",
        $phylum[plant]:"restore HP combat item",
        $phylum[goblin]:"food (12 adventures)",
        $phylum[beast]:"+5 cold res potion (20 turns)",
        $phylum[demon]:"+5 hot res potion (20 turns)",
        $phylum[elf]:"+50% candy drop potion (20 turns)",
        $phylum[hippy]:"+5 strench res potion (20 turns)",
        $phylum[mer-kin]:"+30% underwater item drop potion (20 turns)",
        $phylum[slime]:"+5 sleaze res potion (20 turns)",
        $phylum[undead]:"+5 spooky res potion (20 turns)",
        $phylum[bug]:"+100% HP, ~9 HP/adv regen spleen item (60 turns)",
        $phylum[construct]:"+150% init spleen item (30 turns)",
        $phylum[elemental]:"+50% max MP, ~4 MP/adv spleen item (60 turns)",
        $phylum[fish]:"Fishy effect - spleen item (30 turns)",
        $phylum[hobo]:"+100% meat drop spleen item (60 turns)",
        $phylum[humanoid]:"+50% muscle exp spleen item (30 turns)",
        $phylum[pirate]:"+50% moxie exp spleen item (30 turns)",
        $phylum[weird]:"+50% myst exp spleen item (30 turns)",
        $phylum[penguin]:"500 meat",
	};
	
	item [phylum] phylum_reward_item =
	{
        $phylum[orc]:lookupItem("boot flask"),
        $phylum[constellation]:lookupItem("micronova"),
        $phylum[dude]:lookupItem("human musk"),
        $phylum[horror]:lookupItem("powdered madness"),
        $phylum[plant]:lookupItem("goodberry"),
        $phylum[goblin]:lookupItem("guffin"),
        $phylum[beast]:lookupItem("patch of extra-warm fur"),
        $phylum[demon]:lookupItem("infernal snowball"),
        $phylum[elf]:lookupItem("peppermint syrup"),
        $phylum[hippy]:lookupItem("organic potpourri"),
        $phylum[mer-kin]:lookupItem("Mer-kin eyedrops"),
        $phylum[slime]:lookupItem("extra-strength goo"),
        $phylum[undead]:lookupItem("unfinished pleasure"),
        $phylum[bug]:lookupItem("a bug's lymph"),
        $phylum[construct]:lookupItem("industrial lubricant"),
        $phylum[elemental]:lookupItem("livid energy"),
        $phylum[fish]:lookupItem("fish sauce"),
        $phylum[hobo]:lookupItem("beggin' cologne"),
        $phylum[humanoid]:lookupItem("vial of humanoid growth hormone"),
        $phylum[pirate]:lookupItem("Shantix™"),
        $phylum[weird]:lookupItem("non-Euclidean angle"),
        $phylum[penguin]:lookupItem("envelope full of Meat"),
	};
	
	
	
	phylum [int] phylum_display_order =
	{
        $phylum[dude],
        $phylum[horror],
        $phylum[humanoid],
        $phylum[pirate],
        $phylum[weird],
        $phylum[hobo],
        $phylum[constellation],
        
        $phylum[orc],
        $phylum[plant],
        $phylum[goblin],
        $phylum[beast],
        $phylum[demon],
        $phylum[elf],
        $phylum[hippy],
        $phylum[mer-kin],
        $phylum[slime],
        $phylum[undead],
        $phylum[bug],
        $phylum[construct],
        $phylum[elemental],
        $phylum[fish],
        $phylum[penguin],
	};
	
	string url;
	
	if (my_familiar() == snapper_familiar)
		url = "familiar.php?action=guideme&pwd=" + my_hash();
    else
    	url = "familiar.php";
	string title = "Red-Nosed Snapper";
	string [int] description;
	
	//Show current zone info
	
	phylum current_phylum = get_property("redSnapperPhylum").to_phylum();
	int progress = get_property_int("redSnapperProgress");
	int remaining = clampi(11 - progress, 0, 11);
	location current_location = my_location();
	int musk_uses_remaining = clampi(3 - get_property_int("_humanMuskUses"), 0, 3);
	int madness_uses_remaining = clampi(5 - get_property_int("_powderedMadnessUses"), 0, 5);
	
	
	phylum_reward_description[$phylum[dude]] = "free banish combat item (" + musk_uses_remaining + " free today)";
    phylum_reward_description[$phylum[horror]] = "free kill combat item (" + madness_uses_remaining + " free today)";
	
	monster [phylum][int] current_monsters_by_phylum;
    int total_monster_count = 0;
    if (current_location != $location[none])
    {
        foreach m, rate in current_location.appearance_rates(true)
        {
        	if (rate <= 0.0) continue;
            
            
            current_monsters_by_phylum[m.phylum][current_monsters_by_phylum[m.phylum].count()] = m;
            total_monster_count += 1;
        }
    }
	
	if (current_phylum != $phylum[none])
	{
		description.listAppend("Tracking phylum " + current_phylum + "; " + remaining + " remaining.");
        
        description.listAppend("Rewards " + phylum_reward_item[current_phylum] + ".|*" + phylum_reward_description[current_phylum] + ".");
        
        if (current_monsters_by_phylum[current_phylum].count() > 0)
        {
        	float current_phylum_appearance_rate = 0.0;
            if (total_monster_count != 0)
            	current_phylum_appearance_rate = to_float(current_monsters_by_phylum[current_phylum].count()) / to_float(total_monster_count);
                
            description.listAppend((current_phylum_appearance_rate * 100.0).round() + "% appearance rate in " + current_location);
        	//line += "|*Potential encounters: " + current_monsters_by_phylum[current_phylum].listJoinComponents(", ", "or") + ".";
        }
	}
	
	
	
	
	//Item table will not layout properly as a popup; discarded.
	//string [int][int] item_table;
	//item_table.listAppend(listMake("<strong>Phylum</strong>", "<strong>Reward item</strong>", "<strong>Description</strong>"));
	
	buffer item_table_description;
	boolean first = true;
	foreach key, p in phylum_display_order
	{
		item reward_item = phylum_reward_item[p];
		string reward_item_description = phylum_reward_description[p];
        
        if (first)
        	first = false;
        else
	        item_table_description.append("<hr>");
        item_table_description.append("<strong>" + p + "</strong> - " + reward_item);
        //item_table_description.append("<br>" + reward_item);
        item_table_description.append(HTMLGenerateDivOfClassAndStyle(reward_item_description, "r_indention", "F"));
        
        /*string [int] line;
        line.listAppend(p.to_string().capitaliseFirstLetter());
        line.listAppend(reward_item);
        line.listAppend(reward_item_description);
        
        item_table.listAppend(line);*/
	}
	
	//string item_table_description = HTMLGenerateSimpleTableLines(item_table);
	
	description.listAppend(HTMLGenerateTooltip("Mouse over for all dropped items.", item_table_description.to_string()));
	
	
    checklists.add(C_RESOURCES, ChecklistEntryMake(548, "__familiar Red-Nosed Snapper", url, ChecklistSubentryMake(title, "", description), 1)).ChecklistEntryTag("Red-Nosed Snapper").ChecklistEntrySetCategory("familiar").ChecklistEntrySetShortDescription(remaining);
    
    
    //boolean display_everything = in_ronin();
    if (in_ronin())
    {
    	foreach p, reward_item in phylum_reward_item
        {
        	if (blocked_phylums_for_inventory_display[p]) continue;
        	if (reward_item.available_amount() == 0) continue;
            //if (!display_everything && !allowed_phylums_for_always_inventory_display[p]) continue;
            checklists.add(C_RESOURCES, ChecklistEntryMake(549, "__item " + reward_item, "", ChecklistSubentryMake(pluralise(reward_item), "", phylum_reward_description[p]), 1)).ChecklistEntryTag("Red-Nosed Snapper").ChecklistEntrySetCategory("familiar");
            
        }
    }
	
}
