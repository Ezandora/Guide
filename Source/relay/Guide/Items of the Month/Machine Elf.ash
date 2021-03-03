static
{
    string [item] __machine_elf_abstractions_description;
    
    void machineElfAbstractionDescriptionsInit()
    {
        __machine_elf_abstractions_description[$item[abstraction: motion]] = "+100% init";
        __machine_elf_abstractions_description[$item[abstraction: certainty]] = "+100% item";
        __machine_elf_abstractions_description[$item[abstraction: joy]] = "+10 familiar weight";
        __machine_elf_abstractions_description[$item[abstraction: category]] = "+25% mysticality gains";
        __machine_elf_abstractions_description[$item[abstraction: perception]] = "+25% moxie gains";
        __machine_elf_abstractions_description[$item[abstraction: purpose]] = "+25% muscle gains";
    }
    machineElfAbstractionDescriptionsInit();
}

RegisterResourceGenerationFunction("IOTMMachineElfFamiliarGenerateResource");
void IOTMMachineElfFamiliarGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!$familiar[machine elf].familiar_is_usable())
        return;
    
    string url = "place.php?whichplace=dmt";
    if (my_familiar() != $familiar[machine elf])
        url = "familiar.php";
    int importance = 0;
    if (!__misc_state["in run"] || !__misc_state["need to level"])
        importance = 6;
    
    ChecklistEntry entry = ChecklistEntryMake();
    entry.image_lookup_name = "__familiar machine elf";
    entry.url = url;
    entry.importance_level = importance;
    if (__last_adventure_location == $location[the deep machine tunnels])
        entry.should_highlight = true;
    
    
    
    
    //This test is incredibly inaccurate, because all sorts of things end up in the NC queue. (We All Wear Masks, Approach the Jellyfish, The Mad Tea Party)
    boolean duplication_nc_probably_visited = true;
    if ($location[the deep machine tunnels].noncombat_queue == "")
        duplication_nc_probably_visited = false;
    else if ($location[the deep machine tunnels].noncombatTurnsAttemptedInLocation() >= 5)
    {
        duplication_nc_probably_visited = true;
    }
    else
    {
        duplication_nc_probably_visited = false;
        //Look for known strings for the second part of the NC name:
        //The full list I've seen is:
        //Across The Universe,Backwards In Time,Forwards In Time,Into The 4th Dimension,Into The 5th Dimension,Into The 6th Dimension,Into The 7th Dimension,Into The 8th Dimension,Into The 9th Dimension,Into The Ether,Into Your Body,Into Your Consciousness,Into Your Courage,Into Your Dreams,Into Your Experience,Into Your Eye,Into Your Heart,Into Your Life,Into Your Liver,Into Your Memories,Into Your Mind,Into Your Pineal Gland,Into Your Regrets,Into Your Soul,Into Your Third Ear,Into Your Third Eye,Into Your Thoughts,Into Your Timeline,Into Your Voice,Sideways In Time
        foreach s in $strings[Across The Universe,Backwards In Time,Forwards In Time,Sideways In Time,Into The ,Into Your ]
        {
            if ($location[the deep machine tunnels].noncombat_queue.contains_text(s))
            {
                duplication_nc_probably_visited = true;
                break;
            }
        }
    }
    if (!duplication_nc_probably_visited && $location[the deep machine tunnels].turns_spent >= 5)
    {
        string [int] description;
        description.listAppend("Next" + ($location[the deep machine tunnels].turns_spent > 5 ? "(?)" : "") + " turn in the DMT. Costs a turn.");
        description.listAppend("Copy a PVPable potion, food, drink, or spleen item.");
        item [int] suggested_items;
        if (suggested_items.count() > 0)
            description.listAppend("Possibly " + suggested_items.listJoinComponents(", ", "or") + ".");
        entry.subentries.listAppend(ChecklistSubentryMake("Item duplication available", "", description));
    }
    
    
    
    int free_fights_remaining = clampi(5 - get_property_int("_machineTunnelsAdv"), 0, 5);
    if (free_fights_remaining > 0)
    {
        string [int] description;
        string [int] modifiers;
        string [int] tasks;
        if (my_familiar() != $familiar[machine elf])
        {
            tasks.listAppend("bring along your machine elf");
        }
        tasks.listAppend("adventure in the machine tunnels");
        string line = tasks.listJoinComponents(", ", "and").capitaliseFirstLetter();
        if (__misc_state["need to level"])
        {
            modifiers.listAppend("+" + my_primestat().to_lower_case());
            line += " to gain stats";
        }
        line += ".";
        description.listAppend(line);
        
        if (spleen_limit() > 0)
        {
            //abstraction: sensation -> square monster -> abstraction: motion (+100% init)
            //abstraction: thought -> triangle monster -> abstraction: certainty (+100% item)
            //abstraction: action -> circle monster -> abstraction: joy (+10 familiar weight)
            //FIXME suggest abstraction methods.
            item [item] abstraction_conversions;
            abstraction_conversions[$item[abstraction: sensation]] = $item[abstraction: motion];
            abstraction_conversions[$item[abstraction: thought]] = $item[abstraction: certainty];
            if (!__misc_state["familiars temporarily blocked"])
                abstraction_conversions[$item[abstraction: action]] = $item[abstraction: joy];
            
            monster [item] abstraction_monsters;
            abstraction_monsters[$item[abstraction: sensation]] = $monster[Performer of Actions];
            abstraction_monsters[$item[abstraction: thought]] = $monster[Perceiver of Sensations];
            abstraction_monsters[$item[abstraction: action]] = $monster[Thinker of Thoughts];
            
            string [monster] monster_descriptions;
            monster_descriptions[$monster[Performer of Actions]] = "square";
            monster_descriptions[$monster[Perceiver of Sensations]] = "triangle";
            monster_descriptions[$monster[Thinker of Thoughts]] = "circle";
            
            
            
            foreach source, result in abstraction_conversions
            {
                string result_description = __machine_elf_abstractions_description[result];
                if (result_description == "")
                    continue;
                if (source.item_amount() == 0)
                    continue;
                
                monster m = abstraction_monsters[source];
                string monster_text = monster_descriptions[m] + " monster";
                
                string line = "Throw " + source + " at " + monster_text;
                if (last_monster() == m)
                    line = HTMLGenerateSpanOfClass(line, "r_bold");
                line += " for " + result_description + " spleen potion. (50 turns)";
                
                description.listAppend(line);
            }
            if ($item[abstraction: thought].item_amount() == 0)
                description.listAppend("Possibly run the machine elf elsewhere first, for transmutable potions.");
        }
        //entry.subentries.listAppend(ChecklistSubentryMake(pluralise(free_fights_remaining, "free elf fight", "free elf fights"), modifiers, description));
        resource_entries.listAppend(ChecklistEntryMake(entry.image_lookup_name, entry.url, ChecklistSubentryMake(pluralise(free_fights_remaining, "free elf fight", "free elf fights"), modifiers, description)).ChecklistEntryTag("daily free fight"));
    }
    if (entry.subentries.count() > 0)
    {
        resource_entries.listAppend(entry);
    }
}

RegisterResourceGenerationFunction("IOTMMachineElfGenerateResource");
void IOTMMachineElfGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (in_ronin() && spleen_limit() > 0)
    {
        boolean [item] useful_abstractions;
        
        useful_abstractions[$item[abstraction: motion]] = true;
        useful_abstractions[$item[abstraction: certainty]] = true;
        if (!__misc_state["familiars temporarily blocked"])
            useful_abstractions[$item[abstraction: joy]] = true;
        if (__misc_state["need to level"])
        {
            if (my_primestat() == $stat[muscle])
                useful_abstractions[$item[abstraction: purpose]] = true;
            else if (my_primestat() == $stat[mysticality])
                useful_abstractions[$item[abstraction: category]] = true;
            else if (my_primestat() == $stat[moxie])
                useful_abstractions[$item[abstraction: perception]] = true;
        }
        
        string image_name = "";
		ChecklistSubentry [int] abstraction_lines;
        foreach it in useful_abstractions
        {
			if (it.available_amount() == 0 || !it.is_unrestricted())
				continue;
			string description = __machine_elf_abstractions_description[it] + ". (50 turns, one spleen)";
			if (image_name == "")
                image_name = "__item " + it;
			abstraction_lines.listAppend(ChecklistSubentryMake(pluralise(it), "",  description));
		}
		if (abstraction_lines.count() > 0)
			resource_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=1", abstraction_lines, 7));
    }
}
