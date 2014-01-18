Record BountyFileEntry
{
    string plural;
    string difficulty;
    string image;
    int amount_needed;
    monster bounty_monster;
};


location [int] locationsForMonster(monster m)
{
    //hacky, slow, sorry
    location [int] result;
    if (m == $monster[none])
        return result;
    foreach l in $locations[]
    {
        monster [int] location_monsters = l.get_monsters();
        foreach key in location_monsters
        {
            if (location_monsters[key] == m)
                result.listAppend(l);
        }
    }
    
    return result;
}

ChecklistSubentry SBHHGenerateHunt(string bounty_item_name, int amount_found, int amount_needed, monster target_monster, location [int] relevant_locations)
{
    ChecklistSubentry subentry;
    
    subentry.header = "Bounty hunt for " + bounty_item_name.HTMLEscapeString();
    
    //Look up monster location:
    location [int] monster_locations = locationsForMonster(target_monster);
    
    relevant_locations.listAppendList(monster_locations);
    
    location target_location = $location[none];
    if (monster_locations.count() > 0)
        target_location = monster_locations[0];
    
    
    boolean [location] skippable_ncs_locations = $locations[the stately pleasure dome, the poop deck, the spooky forest,The Haunted Gallery,tower ruins,the castle in the clouds in the sky (top floor), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (basement)];
    boolean noncombats_skippable = (skippable_ncs_locations contains target_location) && target_location != $location[none];
    
    string turns_remaining_string = "";
    
    if (amount_needed != -1 && target_monster != $monster[none] && target_location != $location[none])
    {
        float [monster] appearance_rates = target_location.appearance_rates_adjusted();
        int number_remaining = amount_needed - amount_found;
        
        if (number_remaining == 0)
        {
            subentry.header = "Return to the bounty hunter hunter";
            return subentry;
        }
        
        float bounty_appearance_rate = appearance_rates[target_monster] / 100.0;
        if (noncombats_skippable)
        {
            //Recorrect for NC:
            float nc_rate = appearance_rates[$monster[none]] / 100.0;
            if (nc_rate != 1.0)
                bounty_appearance_rate /= (1.0 - nc_rate);
        }
        
        if (bounty_appearance_rate != 0.0)
        {
            float turns_remaining = number_remaining.to_float() / bounty_appearance_rate;
            turns_remaining_string = " ~" + pluralize(round(turns_remaining), "turn", "turns") + " remain.";
        }
        if (noncombats_skippable && appearance_rates[$monster[none]] != 0.0)
            subentry.modifiers.listAppend("+combat");
    }
    
    
    
    if (target_monster != $monster[none])
        subentry.entries.listAppend("From a " + target_monster + " in " + monster_locations.listJoinComponents(", ", "or") + ".");
    
    
    if (amount_needed == -1)
    {
        subentry.entries.listAppend(amount_found + " found." + turns_remaining_string);
    }
    else
    {
        subentry.entries.listAppend(amount_found + " out of " + amount_needed + " found." + turns_remaining_string);
    }
    
    
    return subentry;
}

void SBountyHunterHunterGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Preliminary support, this may break.
    //currentEasyBountyItem, currentHardBountyItem, currentSpecialBountyItem
    
    //FIXME add suggesting taking bounties if we can detect if they have a bounty available
    ChecklistSubentry [int] subentries;
    string [int] bounty_property_names = split_string_mutable("currentEasyBountyItem,currentHardBountyItem,currentSpecialBountyItem", ",");
    string [string] bounty_properties;
    boolean on_bounty = false;
    
    foreach key in bounty_property_names
    {
        string property_name = bounty_property_names[key];
        string property_value = get_property(property_name);
        if (property_value.length() == 0)
            continue;
        bounty_properties[property_name] = property_value;
        on_bounty = true;
    }
    
    
    if (!on_bounty)
        return;
    
    
    //Load bounty.txt, not sure how else to acquire this data:
    BountyFileEntry [string] bounty_file;
    file_to_map("bounty.txt", bounty_file);
    
    location [int] relevant_locations;
    foreach bounty_name in bounty_properties
    {
        string property_value = bounty_properties[bounty_name];
        
        //Parse:
        //Format is bounty_item:number_found
        string [int] split = split_string_mutable(property_value, ":");
        if (split.count() != 2)
            continue;
        string bounty_item_name = split[0];
        int amount_found = split[1].to_int_silent();
        
        if (bounty_item_name == "null") //unknown
            bounty_item_name = "unknown";
        
        int amount_needed = -1;
        monster target_monster = $monster[none];
        
        if (bounty_file contains bounty_item_name)
        {
            BountyFileEntry file_entry = bounty_file[bounty_item_name];
            amount_needed = file_entry.amount_needed;
            target_monster = file_Entry.bounty_monster;
        }
        subentries.listAppend(SBHHGenerateHunt(bounty_item_name, amount_found, amount_needed, target_monster, relevant_locations));
        
    }
    
    boolean [location] highlight_locations = listGeneratePresenceMap(relevant_locations);
    if (subentries.count() > 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item bounty-hunting helmet", "", subentries, highlight_locations));
    }
}