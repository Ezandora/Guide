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
        if (l == $location[the haunted wine cellar (automatic)])
            continue;
        monster [int] location_monsters = l.get_monsters();
        foreach key in location_monsters
        {
            if (location_monsters[key] == m)
                result.listAppend(l);
        }
    }
    
    return result;
}

ChecklistSubentry SBHHGenerateHunt(string bounty_item_name, int amount_found, int amount_needed, monster target_monster, location [int] relevant_locations, StringHandle url)
{
    //FIXME update to use new bounty API once 16.3 is out for a sufficient time
    ChecklistSubentry subentry;
    
    subentry.header = "Bounty hunt for " + bounty_item_name.HTMLEscapeString();
    
    
    
    
    //Look up monster location:
    location [int] monster_locations = locationsForMonster(target_monster);
    
    relevant_locations.listAppendList(monster_locations);
    
    
    boolean [location] skippable_ncs_locations = $locations[the stately pleasure dome, the poop deck, the spooky forest,The Haunted Gallery,tower ruins,the castle in the clouds in the sky (top floor), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (basement), mt. molehill, the jungles of ancient loathing];
    
    boolean [location] want_nc_locations = $locations[the penultimate fantasy airship];
    
    string turns_remaining_string = "";
    
    boolean need_plus_combat = false;
    boolean need_minus_combat = false;
    
    
    location [int] target_locations;
    if (amount_needed != -1 && target_monster != $monster[none] && monster_locations.count() > 0)
    {
        float min_turns_remaining = 100000000.0;
        foreach key in monster_locations
        {
            location l = monster_locations[key];
            boolean noncombats_skippable = (skippable_ncs_locations contains l);
            boolean noncombats_wanted = (want_nc_locations contains l);
            float [monster] appearance_rates = l.appearance_rates_adjusted();
            int number_remaining = amount_needed - amount_found;
            
            
            if (number_remaining == 0)
            {
                if (url.s.length() == 0)
                    url.s = "place.php?whichplace=forestvillage";
                subentry.header = "Return to the bounty hunter hunter";
                return subentry;
            }
            string clickable_url = getClickableURLForLocation(l);
            if (clickable_url.length() > 0 && (url.s.length() == 0 || url.s == "place.php?whichplace=forestvillage")) //if it's that URL, then it's back to the BHH - we'd rather override that with a bounty
                url.s = clickable_url;
            
            float bounty_appearance_rate = appearance_rates[target_monster] / 100.0;
            if (noncombats_skippable)
            {
                //Recorrect for NC:
                float nc_rate = appearance_rates[$monster[none]] / 100.0;
                if (nc_rate != 1.0)
                    bounty_appearance_rate /= (1.0 - nc_rate);
            }
            else if (noncombats_wanted)
            {
                //Recorrect for NC:
                float nc_rate = appearance_rates[$monster[none]] / 100.0;
                bounty_appearance_rate += nc_rate;
            }
            
            
            if (bounty_appearance_rate != 0.0)
            {
                float turns_remaining = number_remaining.to_float() / bounty_appearance_rate;
                if (turns_remaining <= min_turns_remaining)
                {
                    if (turns_remaining != min_turns_remaining)
                        target_locations.listClear();
                    target_locations.listAppend(l);
                    
                    min_turns_remaining = turns_remaining;
                    turns_remaining_string = " ~" + pluralize(round(turns_remaining), "turn remains", "turns remain") + ".";
                }
            }
            if (noncombats_wanted && appearance_rates[$monster[none]] != 0.0)
                need_minus_combat = true;
            else if (!noncombats_skippable && appearance_rates[$monster[none]] != 0.0)
                need_plus_combat = true;
        }
    }
    
    
    if (need_plus_combat)
        subentry.modifiers.listAppend("+combat");
    if (need_minus_combat)
        subentry.modifiers.listAppend("-combat");
    
    if (target_monster != $monster[none])
    {
        subentry.entries.listAppend("From a " + target_monster + " in " + target_locations.listJoinComponents(", ", "or") + ".");
        subentry.modifiers.listAppend("olfact " + target_monster);
        subentry.modifiers.listAppend("banish");
    }
    
    
    if (amount_needed == -1)
    {
        subentry.entries.listAppend(amount_found + " found." + turns_remaining_string);
    }
    else
    {
        int amount_remaining = amount_needed - amount_found;
        subentry.entries.listAppend(amount_remaining.int_to_wordy().capitalizeFirstLetter() + " left." + turns_remaining_string);
        //subentry.entries.listAppend(amount_found + " out of " + amount_needed + " found." + turns_remaining_string);
    }
    
    item [string] bounty_item_to_unlock;
    
    bounty_item_to_unlock["glittery skate key"] = $item[tiny bottle of absinthe];
    bounty_item_to_unlock["pile of country guano"] = $item[astral mushroom];
    if (!get_property_boolean("_psychoJarUsed"))
    {
        bounty_item_to_unlock["greasy string"] = $item[jar of psychoses (The Meatsmith)];
        bounty_item_to_unlock["pixellated ashes"] = $item[jar of psychoses (The Crackpot Mystic)];
        bounty_item_to_unlock["unlucky claw"] = $item[jar of psychoses (The Suspicious-Looking Guy)];
    }
    bounty_item_to_unlock["pop art banana peel"] = $item[llama lama gong];
    bounty_item_to_unlock["wig powder"] = $item[&quot;DRINK ME&quot; potion];
    bounty_item_to_unlock["grizzled stubble"] = $item[transporter transponder];
    bounty_item_to_unlock["hickory daiquiri"] = $item[devilish folio];
    
    if (bounty_item_to_unlock contains bounty_item_name)
        subentry.entries.listAppend("Accessed with " + bounty_item_to_unlock[bounty_item_name] + ".");
    
        
    if ((bounty_item_name == "half-empty bottle of eyedrops" || bounty_item_name == "broken plunger handle") && knoll_available())
    {
        url.s = "place.php?whichplace=forestvillage";
        subentry.entries.listClear();
        subentry.modifiers.listClear();
        subentry.entries.listAppend("Unable to complete this bounty under knoll sign.");
        subentry.header = "Cancel bounty hunt for " + bounty_item_name.HTMLEscapeString();
    }
    
    if (bounty_item_name == "greasy string")
        subentry.entries.listAppend("Run away from non-salaminders to complete this bounty in a day.");
    
    if (bounty_item_name == "burned-out arcanodiode")
    {
        if (monster_level_adjustment() < 20)
            subentry.entries.listAppend(HTMLGenerateSpanFont("Run +20 ML to find more MechaMechs.", "red", ""));
    }
    
    return subentry;
}

void SBountyHunterHunterGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Preliminary support, this may break.
    //currentEasyBountyItem, currentHardBountyItem, currentSpecialBountyItem
    
    //FIXME add suggesting taking bounties if we can detect if they have a bounty available
    ChecklistSubentry [int] subentries;
    string [int] bounty_property_names = split_string_alternate("currentEasyBountyItem,currentHardBountyItem,currentSpecialBountyItem", ",");
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
    
    StringHandle url_handle;
    
    
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
        string [int] split = split_string_alternate(property_value, ":");
        if (split.count() != 2)
            continue;
        string bounty_item_name = split[0];
        int amount_found = split[1].to_int_silent();
        
        if (bounty_item_name.length() == 0 || bounty_item_name == "null") //unknown
            bounty_item_name = "unknown";
        
        int amount_needed = -1;
        monster target_monster = $monster[none];
        
        if (bounty_file contains bounty_item_name)
        {
            BountyFileEntry file_entry = bounty_file[bounty_item_name];
            amount_needed = file_entry.amount_needed;
            target_monster = file_Entry.bounty_monster;
        }
        subentries.listAppend(SBHHGenerateHunt(bounty_item_name, amount_found, amount_needed, target_monster, relevant_locations, url_handle));
        
    }
    
    boolean [location] highlight_locations = listGeneratePresenceMap(relevant_locations);
    if (subentries.count() > 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item bounty-hunting helmet", url_handle.s, subentries, highlight_locations));
    }
}