boolean [item] __dense_liana_machete_items = $items[antique machete,Machetito,Muculent machete,Papier-m&acirc;ch&eacute;te];

int numberOfDenseLianaFoughtInShrine(location shrine)
{
    //need to check the combat names due to wanderers:
    int dense_liana_defeated = 0;
    string [int] area_combats_seen = shrine.locationSeenCombats();
    foreach key, s in area_combats_seen
    {
        if (s == "dense liana")
            dense_liana_defeated += 1;
    }
    return dense_liana_defeated;
}

void QLevel11HiddenCityInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Worship");
    state.quest_name = "Hidden City Quest";
    state.image_name = "Hidden City";
    
    state.state_boolean["Hospital finished"] = (get_property_int("hiddenHospitalProgress") >= 8);
    state.state_boolean["Bowling alley finished"] = (get_property_int("hiddenBowlingAlleyProgress") >= 8);
    state.state_boolean["Apartment finished"] = (get_property_int("hiddenApartmentProgress") >= 8);
    state.state_boolean["Office finished"] = (get_property_int("hiddenOfficeProgress") >= 8);
    
    state.state_boolean["need machete for liana"] = true;
    foreach it in __dense_liana_machete_items
    {
        if (it.available_amount() > 0)
        {
            state.state_boolean["need machete for liana"] = false;
            break;
        }
    }
    
    if (get_property_int("hiddenBowlingAlleyProgress") >= 1 && get_property_int("hiddenHospitalProgress") >= 1 && get_property_int("hiddenApartmentProgress") >= 1 && get_property_int("hiddenOfficeProgress") >= 1 && $location[a massive Ziggurat].numberOfDenseLianaFoughtInShrine() >= 3 && state.mafia_internal_step >= 4)
        state.state_boolean["need machete for liana"] = false;
    
    if (!__misc_state["can equip just about any weapon"])
        state.state_boolean["need machete for liana"] = false;
    
    
    if (state.finished) //backup
    {
        state.state_boolean["Hospital finished"] = true;
        state.state_boolean["Bowling alley finished"] = true;
        state.state_boolean["Apartment finished"] = true;
        state.state_boolean["Office finished"] = true;
        state.state_boolean["need machete for liana"] = false;
    }
    
    __quest_state["Level 11 Hidden City"] = state;
}


void generateHiddenAreaUnlockForShrine(string [int] description, location shrine)
{
    boolean have_machete_equipped = false;
    item machete_available = $item[none];
    foreach it in __dense_liana_machete_items
    {
        if (it.available_amount() > 0)
            machete_available = it;
        if (it.equipped_amount() > 0)
            have_machete_equipped = true;
    }
    //int liana_remaining = MAX(0, 3 - shrine.combatTurnsAttemptedInLocation());
    int liana_remaining = MAX(0, 3 - shrine.numberOfDenseLianaFoughtInShrine());
    
    if (shrine != $location[a massive ziggurat])
        description.listAppend("Unlock by visiting " + shrine + ".");
    if (liana_remaining > 0 && shrine.noncombatTurnsAttemptedInLocation() == 0)
    {
        string line = liana_remaining.int_to_wordy().capitalizeFirstLetter() + " dense liana remain.";
        
        if (__misc_state["can equip just about any weapon"])
        {
            if (machete_available == $item[none])
                line += " Acquire a machete first.";
            else if (!have_machete_equipped)
                line += " Equip " + machete_available + " first.";
        }
        description.listAppend(line);
    }
}

void QLevel11HiddenCityGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Hidden City"].in_progress)
        return;
    if (__quest_state["Level 11"].mafia_internal_step <3 ) //strange bug where questL11MacGuffin = started, questL11Manor = step1
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Hidden City"];
    ChecklistEntry entry;
    entry.target_location = "place.php?whichplace=hiddencity";
    entry.image_lookup_name = base_quest_state.image_name;
    entry.should_indent_after_first_subentry = true;
    entry.should_highlight = $locations[the hidden temple, the hidden apartment building, the hidden hospital, the hidden office building, the hidden bowling alley, the hidden park, a massive ziggurat,an overgrown shrine (northwest),an overgrown shrine (southwest),an overgrown shrine (northeast),an overgrown shrine (southeast)] contains __last_adventure_location;
    
    if (!__quest_state["Hidden Temple Unlock"].finished)
    {
        return;
    }
    else if (!locationAvailable($location[the hidden park]))
    {
        entry.image_lookup_name = "Hidden Temple";
        entry.target_location = "place.php?whichplace=woods";
        ChecklistSubentry subentry;
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Unlock the hidden city via the hidden temple.");
        if ($item[the Nostril of the Serpent].available_amount() == 0)
            subentry.entries.listAppend("Need nostril of the serpent.");
        if ($item[stone wool].available_amount() > 0)
        {
            if ($effect[Stone-Faced].have_effect() == 0)
                entry.target_location = "inventory.php?which=3";
            subentry.entries.listAppend(pluralize($item[stone wool]) + " available.");
        }
        entry.subentries.listAppend(subentry);
    }
    else
    {		
        if (true)
        {
            ChecklistSubentry subentry;
            subentry.header = base_quest_state.quest_name;
            entry.subentries.listAppend(subentry);
        }
        //Not sure exactly how these work.
        //8 appears to be finished.
        //1 appears to be "area unlocked"
        boolean hidden_tavern_unlocked = (get_property_int("hiddenTavernUnlock") == my_ascensions());
        boolean janitors_relocated_to_park = (get_property_int("relocatePygmyJanitor") == my_ascensions());
        boolean have_machete = false;
    
        have_machete = __dense_liana_machete_items.available_amount() > 0;
        int bowling_progress = get_property_int("hiddenBowlingAlleyProgress");
        int hospital_progress = get_property_int("hiddenHospitalProgress");
        int apartment_progress = get_property_int("hiddenApartmentProgress");
        int office_progress = get_property_int("hiddenOfficeProgress");
        
        if (!base_quest_state.state_boolean["need machete for liana"])
            have_machete = true;
        
        boolean at_last_spirit = false;
        
        if (bowling_progress == 8 && hospital_progress == 8 && apartment_progress == 8 && office_progress == 8 || $item[stone triangle].available_amount() == 4)
        {
            at_last_spirit = true;
            ChecklistSubentry subentry;
            subentry.header = "Massive Ziggurat";
            //Instead of checking for four stone triangles, we check for the lack of all four stone spheres. That way it should detect properly after you fight the boss (presumably losing stone triangles), and lost?
        
            int spheres_available = $item[moss-covered stone sphere].available_amount() + $item[dripping stone sphere].available_amount() + $item[crackling stone sphere].available_amount() + $item[scorched stone sphere].available_amount();
        
            if (spheres_available > 0)
            {
                subentry.entries.listAppend("Acquire stone triangles");
            }
            else
            {
                if ($location[a massive ziggurat].numberOfDenseLianaFoughtInShrine() <3 && $location[a massive ziggurat].noncombatTurnsAttemptedInLocation() == 0)
                {
                    generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                }
                else
                {
                    if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
                    {
                        subentry.entries.listAppend("Talk to the protector spectre.");
                    }
                    else
                    {
                        subentry.modifiers.listAppend("elemental damage");
                        subentry.entries.listAppend("Fight the protector spectre!");
                    }
                }
            }
        
            entry.subentries.listAppend(subentry);
        }
        if (!at_last_spirit)
        {
            if ((!janitors_relocated_to_park && !$monster[pygmy janitor].is_banished()) || !have_machete)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Park";
            
                subentry.modifiers.listAppend("-combat");
                if (!have_machete)
                {
                    int turns_remaining = MAX(0, 7 - $location[the hidden park].turnsAttemptedInLocation());
                    string line;
                    line += "Adventure for ";
                    if (turns_remaining == 1)
                        line += "One More Turn";
                    else
                        line += turns_remaining.int_to_wordy() + " more turns";
                    line += " here for antique machete to clear dense lianas.";
                    if (canadia_available())
                        line += "|Or potentially use muculent machete by acquiring forest tears. (kodama, Outskirts of Camp Logging Camp, 30% drop or clover)";
                    subentry.entries.listAppend(line);
                }
                if (!janitors_relocated_to_park)
                    subentry.entries.listAppend("Potentially relocate janitors to park via non-combat.");
                else
                    subentry.entries.listAppend("Acquire useful items from dumpster with -combat.");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
                if (my_basestat($stat[muscle]) < 62)
                {
                    string line = "Will need " + (62 - my_basestat($stat[muscle])) + " more muscle to equip machete.";
                    subentry.entries.listAppend(line);
                }
            
                entry.subentries.listAppend(subentry);
            }
        }
        
        if (apartment_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Apartment";
            if (apartment_progress == 7 || $item[moss-covered stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place moss-covered stone sphere in shrine.");
            }
            else if (apartment_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northwest)]);
            }
            else
            {
                subentry.entries.listAppend("Olfact shaman.");
                //if (!$monster[pygmy witch lawyer].is_banished())
                    //subentry.entries.listAppend("Potentially banish lawyers.");
                    
                int turns_spent = $location[the hidden apartment building].turns_spent;
                if (turns_spent == -1)
                    subentry.entries.listAppend("NC appears every 9th adventure.");
                else
                {
                    int turns_until_next_nc = (9 - (turns_spent % 9)) - 1;
                    if (turns_until_next_nc == 0)
                        subentry.entries.listAppend("Non-combat appears next turn.");
                    else
                        subentry.entries.listAppend("Non-combat appears after " + pluralizeWordy(turns_until_next_nc, "turn", "turns") + ".");
                }
                
                string [int] curse_sources;
                if (__misc_state["can drink just about anything"])
                {
                    if (hidden_tavern_unlocked)
                        curse_sources.listAppend("cursed punch from the tavern");
                    else
                        curse_sources.listAppend("cursed punch from the tavern, if you unlock it");
                }
                curse_sources.listAppend("fighting a pygmy shaman");
                curse_sources.listAppend("non-combat (try to avoid)");
                string curse_details = "";
                curse_details = " Acquired from " + curse_sources.listJoinComponents(", ", "or") + ".";
                
                if (my_class() == $class[pastamancer] && my_thrall() == $thrall[Vampieroghi] && my_thrall().level >= 5)
                {
                    //FIXME should this be a reminder too, if adventuring there? hmm...
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Change your thrall - Vampieroghi will remove curses.", "red", ""));
                }
                
                if ($effect[thrice-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("You're thrice-cursed. Fight the protector spirit!");
                }
                else if ($effect[twice-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("Need one more curse." + curse_details);
                }
                else if ($effect[once-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("Need two more curses." + curse_details);
                }
                else
                {
                    subentry.entries.listAppend("Need three more curses." + curse_details);
                }
                if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && $skill[Shake it off].skill_is_usable())
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid using Shake It Off to heal", "red", "") + ", it'll remove the curse.");
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
        if (office_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Office";
            if (office_progress == 7 || $item[crackling stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place crackling stone sphere in shrine.");
            }
            else if (office_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northeast)]);
            }
            else
            {
                int files_found = $item[McClusky file (page 1)].available_amount() + $item[McClusky file (page 2)].available_amount() + $item[McClusky file (page 3)].available_amount() + $item[McClusky file (page 4)].available_amount() + $item[McClusky file (page 5)].available_amount();
                int files_not_found = 5 - files_found;
                if ($item[McClusky file (complete)].available_amount() == 0)
                {
                    if (files_not_found > 0)
                    {
                        subentry.entries.listAppend("Olfact accountant.");
                        subentry.entries.listAppend("Need " + pluralize(files_not_found, "more McClusky file", "more McClusky files") + ". Found from pygmy witch accountants.");
                        //if (!$monster[pygmy witch lawyer].is_banished())
                            //subentry.entries.listAppend("Potentially banish lawyers.");
                    }
                    if ($item[Boring binder clip].available_amount() == 0)
                        subentry.entries.listAppend("Need boring binder clip. (raid the supply cabinet, office NC)");
                }
                else
                {
                    subentry.entries.listAppend("You have the complete McClusky files, fight boss.");
                }
                
                int turns_spent = $location[the hidden office building].turns_spent;
                
                if (turns_spent == -1)
                    subentry.entries.listAppend("Non-combat appears first on the 6th adventure, then every 5 adventures.");
                else
                {
                    int turns_until_next_nc = -1;
                    if (turns_spent < 6)
                        turns_until_next_nc = (6 - turns_spent) - 1;
                    else
                        turns_until_next_nc = (5 - ((turns_spent - 6) % 5)) - 1;
                    if (turns_until_next_nc == 0)
                        subentry.entries.listAppend("Non-combat appears next turn.");
                    else
                        subentry.entries.listAppend("Non-combat appears after " + pluralizeWordy(turns_until_next_nc, "turn", "turns") + ".");
                        
                    if (turns_until_next_nc == 0 && $item[McClusky file (complete)].available_amount() == 0 && $item[Boring binder clip].available_amount() > 0)
                    {
                        if (files_not_found > 0)
                        {
                            subentry.entries.listAppend(HTMLGenerateSpanFont("Go adventure in the apartment building for files instead.", "red", ""));
                        }
                    }
                }
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
        if (hospital_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Hospital";
            if (hospital_progress == 7 || $item[dripping stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place dripping stone sphere in shrine.");
            }
            else if (hospital_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Southwest)]);
            }
            else
            {
                if ($items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel].items_missing().count() > 0)
                {
                    subentry.entries.listAppend("Olfact surgeon.");
                    if (!$monster[pygmy orderlies].is_banished())
                        subentry.entries.listAppend("Potentially banish pygmy orderlies.");
                }
                
        
                string [int] items_we_have_unequipped;
                item [int] items_we_have_equipped;
                foreach it in $items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel]
                {
                    boolean can_equip = true;
                    if (it.to_slot() == $slot[shirt] && !__misc_state["Torso aware"])
                        can_equip = false;
                    if (it.available_amount() > 0 && it.equipped_amount() == 0 && can_equip)
                    {
                        buffer line;
                        line.append(it);
                        line.append(" (");
                        line.append(it.to_slot().slot_to_string());
                        if (!it.can_equip())
                            line.append(", can't equip yet");
                        line.append(")");
                        items_we_have_unequipped.listAppend(line);
                    }
                    if (it.equipped_amount() > 0)
                        items_we_have_equipped.listAppend(it);
                }
                if (items_we_have_unequipped.count() > 0)
                {
                    subentry.entries.listAppend("Equipment unequipped: (+10% chance of protector spirit per piece)|*" + items_we_have_unequipped.listJoinComponents("|*"));
                }
                //the cap they implemented seems to be, if you spend thirty turns in the hospital, you always get You, M.D., and it'll come back if you skip it
                //it appeared on turn 31, with zero doctor equipment equipped
                if (items_we_have_equipped.count() > 0)
                    subentry.entries.listAppend((items_we_have_equipped.count() * 10) + "% chance of protector spirit encounter.");
                else
                    subentry.entries.listAppend("Without doctor equipment equipped, this area takes thirty-one turns.");
            }
            
            
            entry.subentries.listAppend(subentry);
        }
    
        if (bowling_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Bowling Alley";
        
            if (bowling_progress == 7 || $item[scorched stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place scorched stone sphere in shrine.");
            }
            else if (bowling_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (southeast)]);
            }
            else
            {
                int rolls_needed = 6 - bowling_progress;
                boolean worry_about_free_runs = false;
                if (rolls_needed > $item[bowling ball].available_amount_including_closet())
                {
                    subentry.modifiers.listAppend("+150% item");
                    subentry.entries.listAppend("Olfact bowler, run +150% item.");
                    if (!$monster[pygmy orderlies].is_banished())
                        subentry.entries.listAppend("Potentially banish pygmy orderlies.");
                    worry_about_free_runs = true;
                }
                
                string line;
                line = int_to_wordy(rolls_needed).capitalizeFirstLetter();
                if (rolls_needed > 1)
                    line += " more rolls";
                else
                    line = "One More Roll";
                line += " until protector spirit fight.";
                
                if ($item[bowling ball].item_amount() > 0)
                    line += "|Have " + pluralizeWordy($item[bowling ball].item_amount(), $item[bowling ball]) + ".";
                if ($item[bowling ball].item_amount() < rolls_needed)
                {
                    if ($item[bowling ball].closet_amount() > 0 && $item[bowling ball].item_amount() > 0)
                        line += " (" + ($item[bowling ball].item_amount() + $item[bowling ball].closet_amount()).int_to_wordy() + " total with closet)";
                    else if ($item[bowling ball].closet_amount() > 0)
                    {
                        line += "|Have " + pluralizeWordy($item[bowling ball].closet_amount(), $item[bowling ball]) + " in closet.";
                        if ($item[bowling ball].closet_amount() >= rolls_needed)
                            line += " (take them out!)";
                    }
                }
                
                subentry.entries.listAppend(line);
                
                //FIXME pop up a reminder to acquire bowl of scorpions
                if (__misc_state["free runs usable"] && worry_about_free_runs)
                {
                    if (hidden_tavern_unlocked)
                    {
                        if ($item[bowl of scorpions].item_amount() == 0 && !$monster[drunk pygmy].is_banished())
                            subentry.entries.listAppend(HTMLGenerateSpanFont("Buy a bowl of scorpions", "red", "") + " from the Hidden Tavern to free run from drunk pygmys.");
                    }
                    else
                    {
                        subentry.entries.listAppend("Possibly unlock the hidden tavern first, for free runs from drunk pygmies.");
                    }
                }
            }
        
        
        
            entry.subentries.listAppend(subentry);
        }
        
        if (!at_last_spirit)
        {
            if ($location[a massive ziggurat].numberOfDenseLianaFoughtInShrine() <3)
            {
                ChecklistSubentry subentry;
                subentry.header = "Massive Ziggurat";
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                entry.subentries.listAppend(subentry);
            }
            if (!hidden_tavern_unlocked)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Tavern";
                boolean should_output = true;
            
                if ($item[book of matches].available_amount() > 0)
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Use book of matches.", "red", ""));
                else
                {
                    if (janitors_relocated_to_park)
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, Hidden Park, 20% drop)");
                    else
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, everywhere in the hidden city, 20% drop)");
                    
                    string [int] tavern_provides;
                    if (bowling_progress < 7 && __misc_state["free runs usable"])
                        tavern_provides.listAppend("Free runs from drunk pygmys.");
                    if (__misc_state["can drink just about anything"])
                    {
                        if (apartment_progress < 8)
                            tavern_provides.listAppend("Curses for hidden apartment.");
                        int adventures_given = 15;
                        if ($skill[the ode to booze].skill_is_usable())
                            adventures_given += 6;
                        
                        if (my_path_id() != PATH_SLOW_AND_STEADY)
                            tavern_provides.listAppend("Nightcap drink. (Fog Murderer for " + adventures_given + " adventures)");
                    }
                    if (tavern_provides.count() > 0)
                        subentry.entries.listAppend("Hidden Tavern provides:|*" + tavern_provides.listJoinComponents("|*"));
                    else
                        should_output = false; //don't bother, no reason to... I think?
                
                }
                if (should_output)
                    entry.subentries.listAppend(subentry);
            }
        }
    }
    if (entry.subentries.count() > 0)
        task_entries.listAppend(entry);
}
