RegisterResourceGenerationFunction("IOTMSnojoGenerateResource");
void IOTMSnojoGenerateResource(ChecklistEntry [int] resource_entries)
{
    ChecklistEntry snojo_skill_entry;
    if (lookupSkill("Shattering Punch").have_skill() && mafiaIsPastRevision(16617))
    {
        int punches_left = clampi(3 - get_property_int("_shatteringPunchUsed"), 0, 3);
        if (punches_left > 0)
        {
            string [int] description;
            description.listAppend("Win a fight without taking a turn.");
            
            
            if (snojo_skill_entry.image_lookup_name == "")
                snojo_skill_entry.image_lookup_name = "__skill shattering punch";
            snojo_skill_entry.subentries.listAppend(ChecklistSubentryMake(pluralise(punches_left, "shattering punch", "shattering punches"), "", description));
            
        }
    }
    if (lookupSkill("Snokebomb").have_skill() && mafiaIsPastRevision(10000000))
    {
        int snokes_left = clampi(3 - get_property_int("_snokebombUsed"), 0, 3);
        if (snokes_left > 0)
        {
            string [int] description;
            description.listAppend("Free run/banish.");
            if (snojo_skill_entry.image_lookup_name == "")
                snojo_skill_entry.image_lookup_name = "__skill Snokebomb";
            Banish snoke_banish = BanishByName("snokebomb");
            int turns_left_of_banish = snoke_banish.BanishTurnsLeft();
            if (turns_left_of_banish > 0)
            {
                //is this relevant? we don't describe this for pantsgiving
                description.listAppend("Currently used on " + snoke_banish.banished_monster + " for " + pluralise(turns_left_of_banish, "more turn", "more turns") + ".");
            }
            snojo_skill_entry.subentries.listAppend(ChecklistSubentryMake(pluralise(snokes_left, "snokebomb", "snokebombs"), "", description));
            
        }
    }
    
    if (snojo_skill_entry.subentries.count() > 0)
    {
        snojo_skill_entry.importance_level = 6;
        if (!__misc_state["in run"])
            snojo_skill_entry.importance_level = 9;
        resource_entries.listAppend(snojo_skill_entry);
    }


    //Everything past here is for snojo owners:
    if (!get_property_boolean("snojoAvailable") || in_bad_moon() || !lookupItem("X-32-F snowman crate").is_unrestricted())
        return;
    
    int fights_remaining = clampi(10 - get_property_int("_snojoFreeFights"), 0, 10);
    if (!mafiaIsPastRevision(16598))
        fights_remaining = 0;
    if (fights_remaining > 0)
    {
        item [stat] training_equipment_for_stat;
        training_equipment_for_stat[$stat[muscle]] = lookupItem("training belt");
        training_equipment_for_stat[$stat[mysticality]] = lookupItem("training legwarmers");
        training_equipment_for_stat[$stat[moxie]] = lookupItem("training helmet");
        
        item [stat] consumable_reward_for_stat;
        consumable_reward_for_stat[$stat[muscle]] = lookupItem("ancient medicinal herbs");
        consumable_reward_for_stat[$stat[mysticality]] = lookupItem("ice rice");
        consumable_reward_for_stat[$stat[moxie]] = lookupItem("iced plum wine");
        
        string [item] reward_descriptions;
        reward_descriptions[lookupItem("training belt")] = "+25 ML accessory";
        reward_descriptions[lookupItem("training helmet")] = "+25% item hat";
        reward_descriptions[lookupItem("training legwarmers")] = "+5 res accessory";
        reward_descriptions[lookupItem("ice rice")] = "epic food";
        reward_descriptions[lookupItem("iced plum wine")] = "epic drink";
        
        
        string [int] description;
        
        string setting = get_property("snojoSetting");
        
        if (setting == "NONE" || setting == "")
        {
            description.listAppend("Visit the control console.");
        }
        
        string wins_property = "";
        stat current_stat;
        if (setting == "MUSCLE")
        {
            current_stat = $stat[muscle];
            wins_property = "snojoMuscleWins";
        }
        else if (setting == "MOXIE")
        {
            current_stat = $stat[moxie];
            wins_property = "snojoMoxieWins";
        }
        else if (setting == "MYSTICALITY")
        {
            current_stat = $stat[mysticality];
            wins_property = "snojoMysticalityWins";
        }
        
        int wins = 0;
        if (wins_property != "")
            wins = get_property_int(wins_property);
        
        
        int [string] winnings;
        if (wins_property != "")
        {
            winnings["skill scroll"] = 50;
            if (reward_descriptions[training_equipment_for_stat[current_stat]] != "")
                winnings[reward_descriptions[training_equipment_for_stat[current_stat]]] = 11;
            if (consumable_reward_for_stat[current_stat] != $item[none])
                winnings[consumable_reward_for_stat[current_stat].to_string()] = MAX(7, ceil(wins.to_float() / 7.0) * 7);
        }
        
        //Output in order of upcoming appearance:
        string [int] winnings_order;
        foreach winning in winnings
            winnings_order.listAppend(winning);
        sort winnings_order by winnings[value];
        
        string [int] various_winnings_upcoming;
        foreach key, winning in winnings_order
        {
            int timing = winnings[winning];
            if (wins >= timing)
                continue;
            int turns_remaining = timing - wins;
            if (turns_remaining == 1)
                various_winnings_upcoming.listAppend(winning + " next turn");
            else
                various_winnings_upcoming.listAppend(winning + " in " + pluralise(turns_remaining, "turn", "turns"));
        }
        
        if (various_winnings_upcoming.count() > 0)
            description.listAppend(various_winnings_upcoming.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        
        if (wins >= 50 && setting != "TOURNAMENT")
        {
            string [int] switchables;
            if (get_property_int("snojoMuscleWins") < 50)
                switchables.listAppend("muscle");
            if (get_property_int("snojoMoxieWins") < 50)
                switchables.listAppend("moxie");
            if (get_property_int("snojoMysticalityWins") < 50)
                switchables.listAppend("mysticality");
            if (switchables.count() > 0)
                description.listAppend("Could switch to " + switchables.listJoinComponents(", ", "or") + " for skill scrolls.");
        }
        if (__misc_state["in run"])
        {
            //Possible rewards to switch to:
            string [int] switchable_options;
            foreach s in $stats[muscle,moxie,mysticality]
            {
                if (s == current_stat)
                    continue;
                item training_equipment = training_equipment_for_stat[s];
                item consumable = consumable_reward_for_stat[s];
                
                string [int] acquirable_descriptions;
                if (training_equipment.available_amount() == 0)
                {
                    acquirable_descriptions.listAppend("a " + reward_descriptions[training_equipment]);
                }
                if (s != $stat[muscle] && !(!__misc_state["can drink just about anything"] && s == $stat[moxie]) && !(!__misc_state["can eat just about anything"] && s == $stat[mysticality]))
                {
                    acquirable_descriptions.listAppend(reward_descriptions[consumable]);
                }
                if (acquirable_descriptions.count() > 0)
                    switchable_options.listAppend(s.to_string().to_lower_case() + " for " + acquirable_descriptions.listJoinComponents("/"));
            }
            if (switchable_options.count() > 0)
            {
                description.listAppend("Could switch to " + switchable_options.listJoinComponents(", ", "or") + ".");
            }
        }
        int importance = 6;
        if (__misc_state["in run"])
            importance = 0;
        resource_entries.listAppend(ChecklistEntryMake("__item snow suit", "place.php?whichplace=snojo", ChecklistSubentryMake(pluralise(fights_remaining, "free Snojo fight", "free Snojo fights"), "", description), importance));
    }
}