static
{
    string [item] __machine_elf_abstractions_description;
    
    void machineElfAbstractionDescriptionsInit()
    {
        __machine_elf_abstractions_description[lookupItem("abstraction: motion")] = "+100% init";
        __machine_elf_abstractions_description[lookupItem("abstraction: certainty")] = "+100% item";
        __machine_elf_abstractions_description[lookupItem("abstraction: joy")] = "+10 familiar weight";
        __machine_elf_abstractions_description[lookupItem("abstraction: category")] = "+25% mysticality gains";
        __machine_elf_abstractions_description[lookupItem("abstraction: perception")] = "+25% moxie gains";
        __machine_elf_abstractions_description[lookupItem("abstraction: purpose")] = "+25% muscle gains";
    }
    machineElfAbstractionDescriptionsInit();
}

RegisterResourceGenerationFunction("IOTMMachineElfFamiliarGenerateResource");
void IOTMMachineElfFamiliarGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!lookupFamiliar("machine elf").familiar_is_usable())
        return;
    
    int free_fights_remaining = clampi(5 - get_property_int("_machineTunnelsAdv"), 0, 5);
    if (free_fights_remaining > 0 && mafiaIsPastRevision(16550))
    {
        string url = "place.php?whichplace=dmt";
        string [int] description;
        string [int] modifiers;
        int importance = 0;
        if (!__misc_state["in run"] || !__misc_state["need to level"])
            importance = 6;
        string [int] tasks;
        if (my_familiar() != lookupFamiliar("machine elf"))
        {
            url = "familiar.php";
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
            abstraction_conversions[lookupItem("abstraction: sensation")] = lookupItem("abstraction: motion");
            abstraction_conversions[lookupItem("abstraction: thought")] = lookupItem("abstraction: certainty");
            if (!__misc_state["familiars temporarily blocked"])
                abstraction_conversions[lookupItem("abstraction: action")] = lookupItem("abstraction: joy");
            
            monster [item] abstraction_monsters;
            abstraction_monsters[lookupItem("abstraction: sensation")] = lookupMonster("Performer of Actions");
            abstraction_monsters[lookupItem("abstraction: thought")] = lookupMonster("Perceiver of Sensations");
            abstraction_monsters[lookupItem("abstraction: action")] = lookupMonster("Thinker of Thoughts");
            
            string [monster] monster_descriptions;
            monster_descriptions[lookupMonster("Performer of Actions")] = "square";
            monster_descriptions[lookupMonster("Perceiver of Sensations")] = "triangle";
            monster_descriptions[lookupMonster("Thinker of Thoughts")] = "circle";
            
            
            
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
            if (lookupItem("abstraction: thought").item_amount() == 0)
                description.listAppend("Possibly run the machine elf elsewhere first, for transmutable potions.");
        }
        ChecklistSubentry [int] subentries;
        subentries.listAppend(ChecklistSubentryMake(pluralise(free_fights_remaining, "free elf fight", "free elf fights"), modifiers, description));
        resource_entries.listAppend(ChecklistEntryMake("__familiar machine elf", url, subentries, importance, lookupLocations("the deep machine tunnels")));
    }
}

RegisterResourceGenerationFunction("IOTMMachineElfGenerateResource");
void IOTMMachineElfGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (in_ronin() && spleen_limit() > 0)
    {
        boolean [item] useful_abstractions;
        
        useful_abstractions[lookupItem("abstraction: motion")] = true;
        useful_abstractions[lookupItem("abstraction: certainty")] = true;
        if (!__misc_state["familiars temporarily blocked"])
            useful_abstractions[lookupItem("abstraction: joy")] = true;
        if (__misc_state["need to level"])
        {
            if (my_primestat() == $stat[muscle])
                useful_abstractions[lookupItem("abstraction: purpose")] = true;
            else if (my_primestat() == $stat[mysticality])
                useful_abstractions[lookupItem("abstraction: category")] = true;
            else if (my_primestat() == $stat[moxie])
                useful_abstractions[lookupItem("abstraction: perception")] = true;
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