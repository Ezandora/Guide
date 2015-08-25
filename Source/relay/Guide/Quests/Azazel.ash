
void QAzazelInit()
{
	//questG04Azazel
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM10Azazel");
	
	state.quest_name = "Azazel Quest";
	state.image_name = "steel margarita";
	
	if (my_basestat(my_primestat()) >= 12 && __quest_state["Level 6"].finished)
		state.startable = true;
	
	__quest_state["Azazel"] = state;
}

record AzazelBandMember
{
    string name;
    item [int] desired_items;
};

AzazelBandMember AzazelBandMemberMake(string name, item [int] desired_items)
{
    AzazelBandMember result;
    result.name = name;
    result.desired_items = desired_items;
    return result;
}

AzazelBandMember AzazelBandMemberMake(string name, item it1, item it2)
{
    return AzazelBandMemberMake(name, listMake(it1, it2));
}

void listAppend(AzazelBandMember [int] list, AzazelBandMember entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void QAzazelGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Azazel"];
    
    foreach consumable in $items[steel lasagna,steel margarita,steel-scented air freshener]
    {
        if (consumable.available_amount() == 0)
            continue;
        ChecklistSubentry subentry;
        
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Consume " + consumable + ".");
        optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "", subentry));
        return;
    }
    
	if (base_quest_state.finished)
		return;
    
    
    if ($skill[Stomach of Steel].skill_is_usable() || $skill[Liver of Steel].skill_is_usable() || $skill[Spleen of Steel].skill_is_usable())
        return;
    
    if (!__quest_state["Level 6"].finished)
        return;
    
    //We don't suggest or give advice on this quest in-run unless the player spends an adventure in one of the zones.
    //If that happens, they're probably sure they want the consumable items.
	if (!__misc_state["in aftercore"] && $locations[The Laugh Floor, Infernal Rackets Backstage].turnsAttemptedInLocation() == 0 && $items[Azazel's unicorn,Azazel's lollipop,Azazel's tutu].available_amount() == 0 && !in_bad_moon())
		return;
    
        
	ChecklistEntry entry;
	entry.url = "pandamonium.php";
	entry.image_lookup_name = base_quest_state.image_name;
	entry.should_indent_after_first_subentry = true;
    entry.should_highlight = $locations[the laugh floor, infernal rackets backstage] contains __last_adventure_location;
    
    if (true)
    {
        ChecklistSubentry subentry;
        
        subentry.header = base_quest_state.quest_name;
        
        subentry.entries.listAppend("Gives +5 consumable space.");
        
        if ($item[Azazel's unicorn].available_amount() > 0 && $item[Azazel's lollipop].available_amount() > 0 && $item[Azazel's tutu].available_amount() > 0)
        {
            subentry.entries.listAppend("Speak to Azazel.");
        }
        entry.subentries.listAppend(subentry);
    }
    
    boolean need_imp_airs = false;
    boolean need_bus_passes = false;
    if ($item[Azazel's tutu].available_amount() == 0)
    {
        //collect 5 cans of imp air and 5 bus passes
        ChecklistSubentry subentry;
        
        subentry.header = "Azazel's tutu";
        
        int imp_air_needed = MAX(0, 5 - $item[imp air].available_amount());
        int bus_passes_needed = MAX(0, 5 - $item[bus pass].available_amount());
        if (imp_air_needed == 0 && bus_passes_needed == 0)
        {
            subentry.entries.listAppend("Speak to the stranger.");
        }
        else
        {
            if (imp_air_needed > 0)
            {
                string line;
                line = "Need " + pluralise(imp_air_needed, $item[imp air]) + ", from the laugh floor.";
                if (!in_ronin())
                    line += " Or the mall.";
                subentry.entries.listAppend(line);
                need_imp_airs = true;
            }
            if (bus_passes_needed > 0)
            {
                string line;
                line = "Need " + pluralise(bus_passes_needed, $item[bus pass]) + ", from backstage.";
                if (!in_ronin())
                    line += " Or the mall.";
                subentry.entries.listAppend(line);
                need_bus_passes = true;
            }
        }
        entry.subentries.listAppend(subentry);
    }
	
    
    if ($item[Azazel's unicorn].available_amount() == 0)
    {
        ChecklistSubentry subentry;
        
        subentry.header = "Azazel's unicorn";
        
        int [item] band_items_available;
        int band_items_found = 0;
        foreach it in $items[comfy pillow,giant marshmallow,booze-soaked cherry,sponge cake,beer-scented teddy bear,gin-soaked blotter paper]
        {
            if (it.available_amount() > 0)
                band_items_found += 1;
            band_items_available[it] = it.available_amount();
        }
        
        //Try to solve the puzzle:
        //Hmm... FIXME is there any way to determine which ones we've given to band members?
        
        AzazelBandMember [int] band_members;
        band_members.listAppend(AzazelBandMemberMake("Bognort", $item[giant marshmallow], $item[gin-soaked blotter paper]));
        band_members.listAppend(AzazelBandMemberMake("Stinkface", $item[beer-scented teddy bear], $item[gin-soaked blotter paper]));
        band_members.listAppend(AzazelBandMemberMake("Flargwurm", $item[booze-soaked cherry], $item[sponge cake]));
        band_members.listAppend(AzazelBandMemberMake("Jim", $item[sponge cake], $item[comfy pillow]));
        
        string [int] quest_completion_instructions;
        boolean can_complete_quest = true;
        foreach key in band_members
        {
            AzazelBandMember musician = band_members[key];
            boolean found_item = false;
            foreach key2 in musician.desired_items
            {
                item it = musician.desired_items[key2];
                if (band_items_available[it] > 0)
                {
                    quest_completion_instructions.listAppend("Give " + musician.name + " a " + it + ".");
                    band_items_available[it] -= 1;
                    found_item = true;
                    break;
                }
            }
            if (!found_item)
                can_complete_quest = false;
        }
        
        if (can_complete_quest)
        {
            if (need_bus_passes)
                subentry.entries.listAppend("Run +item backstage.");
            subentry.entries.listAppend("Talk to Sven.|*" + quest_completion_instructions.listJoinComponents("|*"));
        }
        else
        {
            string and_item = "";
            if (need_bus_passes)
                and_item = " and +item";
            subentry.entries.listAppend("Run -combat" + and_item + " backstage.");
            subentry.entries.listAppend("Need band components.");
            subentry.modifiers.listAppend("-combat");
        }
        if (need_bus_passes)
        {
            subentry.modifiers.listAppend("+item");
            subentry.modifiers.listAppend("olfact serialbus");
        }
        
        entry.subentries.listAppend(subentry);
    }
    if ($item[Azazel's lollipop].available_amount() == 0)
    {
        //comedy club - fight on!
        ChecklistSubentry subentry;
        
        subentry.header = "Azazel's lollipop";
        
        
        if ($item[observational glasses].available_amount() > 0)
        {
            //talk to mourn
            string line = "Talk to Mourn.";
            if ($item[observational glasses].equipped_amount() == 0)
                line = "Equip the observational glasses, talk to mourn.";
            subentry.entries.listAppend(line);
        }
        else
        {
            subentry.modifiers.listAppend("+combat");
            string and_item = "";
            if (need_imp_airs)
                and_item = " and +item";
            subentry.entries.listAppend("Run +combat" + and_item + " on the laugh floor, find Larry.");
        }
        
        if (need_imp_airs)
        {
            subentry.modifiers.listAppend("+item");
            subentry.modifiers.listAppend("olfact ch imp");
        }
        entry.subentries.listAppend(subentry);
    }
    
	
	optional_task_entries.listAppend(entry);
}