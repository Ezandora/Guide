
string [int] SFaxGeneratePotentialFaxes(boolean suggest_less_powerful_faxes)
{
    string [int] potential_faxes;
    boolean can_arrow = false;
    if (get_property_int("_badlyRomanticArrows") == 0 && (familiar_is_usable($familiar[obtuse angel]) || familiar_is_usable($familiar[reanimated reanimator])))
        can_arrow = true;
    
    
    if (get_auto_attack() != 0)
    {
        potential_faxes.listAppend("Auto attack is on, disable it?");
    }
    
    if (__misc_state["in run"])
    {
        //sleepy mariachi
        if (familiar_is_usable($familiar[fancypants scarecrow]) || familiar_is_usable($familiar[mad hatrack]))
        {
            if ($item[spangly mariachi pants].available_amount() == 0 && in_hardcore())
            {
                string fax = "";
                fax += ChecklistGenerateModifierSpan("yellow ray");
                
                if (familiar_is_usable($familiar[fancypants scarecrow]))
                {
                    fax += "Makes scarecrow into superfairy";
                    if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
                    {
                        fax += " and +3 mainstat/turn hat";
                    }
                }
                else if (familiar_is_usable($familiar[mad hatrack]))
                    fax += "Makes hatrack into superfairy";
                fax += ".";
                
                fax = "sleepy mariachi" + HTMLGenerateIndentedText(fax);
                potential_faxes.listAppend(fax);
            }
        }
        
        //ninja snowman assassin (copy only)
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
        {
            int equipment_missing_count = $items[ninja carabiner,ninja crampons,ninja rope].items_missing().count();
            if (equipment_missing_count > 0)
            {
                string fax = "";
                string modifier_text = "+150% init or more";
                if (equipment_missing_count == 3)
                    modifier_text += ", two copies";
                if (equipment_missing_count == 2)
                    modifier_text += ", one copy";
                fax += ChecklistGenerateModifierSpan(modifier_text);
                if (equipment_missing_count == 3)
                    fax += "Copy twice for recreational mountain climbing.<br>";
                else if (equipment_missing_count == 2)
                    fax += "Copy once for recreational mountain climbing.<br>";
                fax += generateNinjaSafetyGuide(false);
                if ($familiar[obtuse angel].familiar_is_usable() && $familiar[reanimated reanimator].familiar_is_usable())
                    fax += "<br>Make sure to copy with angel, not the reanimator.";
                
            
                fax = "ninja snowman assassin" + HTMLGenerateIndentedText(fax);
                potential_faxes.listAppend(fax);
            }
        }
        
        int missing_ore = MAX(0, 3 - __quest_state["Level 8"].state_string["ore needed"].to_item().available_amount());
        if (!__quest_state["Level 8"].state_boolean["Past mine"] && missing_ore > 0 && !$skill[unaccompanied miner].skill_is_usable())
        {
            string fax = "";			
            fax += ChecklistGenerateModifierSpan("+150% item or more");
            fax += "Mining ores. Try to copy a few times.";
            if (__misc_state_string["obtuse angel name"] != "")
            {
                string arrow_text = " (arrow?)";
                if (get_property_int("_badlyRomanticArrows") > 0)
                    arrow_text = HTMLGenerateSpanFont(arrow_text, "gray");
                fax += arrow_text;
            }
        
            fax = "mountain man" + HTMLGenerateIndentedText(fax);
            potential_faxes.listAppend(fax);
        }
        
        
        if (!(__quest_state["Level 12"].finished || __quest_state["Level 12"].state_boolean["Lighthouse Finished"] || $item[barrel of gunpowder].available_amount() == 5))
        {
            string line = "Lobsterfrogman (lighthouse quest";
            if ($item[barrel of gunpowder].available_amount() < 4)
            {
                    line += "; copy";
                if (can_arrow)
                    line += "/arrow";
            }
            line += ")";
            potential_faxes.listAppend(line);
        }
        
        //orcish frat boy spy / war hippy
        if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues") && !__quest_state["Level 12"].finished)
            potential_faxes.listAppend("Bailey's Beetle (YR) / Hippy spy (30% drop) / Orcish frat boy spy (30% drop) - war outfit");
            
        //dirty thieving brigand...? 
        
        if (!__misc_state["can eat just about anything"]) //can't eat, can't fortune cookie
        {
            //Suggest kge, miner, baabaaburan:
            if (!dispensary_available() && !have_outfit_components("Knob Goblin Elite Guard Uniform"))
            {
                potential_faxes.listAppend("Knob Goblin Elite Guard Captain - unlocks dispensary");
            }
            if (!__quest_state["Level 8"].state_boolean["Past mine"] && !have_outfit_components("Mining Gear") && __misc_state["can equip just about any weapon"])
                potential_faxes.listAppend("7-Foot Dwarf Foreman - Mining gear for level 8 quest. Need YR or +234% items.");
            if (!locationAvailable($location[the hidden park]) && ($item[stone wool].available_amount()) < (2 - MIN(1, $item[the nostril of the serpent].available_amount())))
                potential_faxes.listAppend("Baa'baa'bu'ran - Stone wool for hidden city unlock. Need +100% items (or as much as you can get for extra wool)");
        }
        
        if (!familiar_is_usable($familiar[angry jung man]) && in_hardcore())
        {
            //Can't pull for jar of psychoses, no jung man...
            //It's time for a g-g-g-ghost! zoinks!
            if (!__quest_state["Level 13"].state_boolean["digital key used"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
            {
                string line = "Ghost - only if you can copy it.";
                if (can_arrow)
                    line += " (arrow?)";
                line += "|5 white pixels drop per ghost, speeds up digital key.|Run +150% item.";
                potential_faxes.listAppend(line);
            }
        }
        
        if (to_item("7301").available_amount() == 0 && get_property("questM20Necklace") != "finished" && $item[Lady Spookyraven's necklace].available_amount() == 0)
        {
            int effective_writing_desks_encountering = get_property_int("writingDesksDefeated");
            if (get_property_monster("romanticTarget") == $monster[writing desk])
                effective_writing_desks_encountering += get_property_int("_romanticFightsLeft");
            if (effective_writing_desks_encountering < 5)
            {
                string line = "Writing desk - <strong>only if you can copy it four times</strong>. Skips the manor's first floor if you fight five total.";
                
                if ($item[telegram from Lady Spookyraven].available_amount() > 0)
                    line += HTMLGenerateSpanFont("<br>Read the telegram from Lady Spookyraven first.", "red");
                potential_faxes.listAppend(line);
            }
        }
        
        if (in_hardcore() && $item[Bram's choker].available_amount() == 0 && combat_rate_modifier() > -25.0 && !(__quest_state["Level 13"].in_progress || (__quest_state["Level 13"].finished && my_path_id() != PATH_BUGBEAR_INVASION)))
        {
            string line = "Bram the Stoker - drops a -5% combat accessory.";
            if (my_basestat($stat[mysticality]) < 50)
                line += " (requires 50 myst)";
            potential_faxes.listAppend(line);
        }
        
        if (!in_hardcore() && $item[richard's star key].available_amount() + $item[richard's star key].creatable_amount() == 0 && !__quest_state["Level 13"].state_boolean["Richard's star key used"] && !($item[star].available_amount() >= 8 && $item[line].available_amount() >= 7))
        {
            string copy_type = "arrow";
            if (my_path_id() == PATH_HEAVY_RAINS) //arrows mean washaway in flooded areas
                copy_type = "copy";
            potential_faxes.listAppend("Skinflute - +234% item, fight 4 times (" + copy_type + ") to skip HITS with pulls.");
        }
        
        if (suggest_less_powerful_faxes)
        {
            //giant swarm of ghuol whelps
            if (__quest_state["Level 7"].state_boolean["cranny needs speed tricks"])
            {
                string line = "Giant swarm of ghuol whelps - +ML - with a copy possibly";
                if (!__quest_state["Level 7"].started)
                {
                    line = HTMLGenerateSpanFont(line + " (wait until quest started)", "gray");
                }
                potential_faxes.listAppend(line);
            }
            //modern zmobie
            if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
            {
                string line = "Modern zmobie - with copies/arrows";
                if (!__quest_state["Level 7"].started)
                {
                    line = HTMLGenerateSpanFont(line + " (wait until quest started)", "gray");
                }
                
                potential_faxes.listAppend(line);
            }
            //gaudy pirate (use for insults!)
            if (!__quest_state["Level 11 Palindome"].finished && $item[talisman o' namsilat].available_amount() == 0 && $items[snakehead charrrm,gaudy key].available_amount() < 2 && $items[Copperhead Charm,Copperhead Charm (rampant)].available_amount() < 2)
            {
                string description = "Gaudy pirate - two fights for talisman o' nam. (copy once)";
                if ($items[snakehead charrrm,gaudy key].available_amount() == 1)
                    description = "Gaudy pirate - one fight for talisman o' nam.";
                if (__quest_state["Pirate Quest"].mafia_internal_step < 6 && __quest_state["Pirate Quest"].state_int["insult count"] < 8)
                {
                    string l = "Pirate insult them!";
                    if ($item[the big book of pirate insults].available_amount() == 0)
                        l += " (get the big book of pirate insults first)";
                    
                    description += HTMLGenerateIndentedText(l);
                }
                potential_faxes.listAppend(description);
            }
            
            //screambat for sonar replacement
            if ((3 - __quest_state["Level 4"].state_int["areas unlocked"]) > $item[sonar-in-a-biscuit].available_amount())
            {
                string description = "Screambat - unlocks a single bat lair area";
                if (!__quest_state["Level 4"].in_progress)
                    description = HTMLGenerateSpanFont(description, "gray");
                potential_faxes.listAppend(description);
            }
            //drunken half-orc hobo (smiths)
            if (in_hardcore() && $skill[summon smithsness].skill_is_usable() && $items[dirty hobo gloves,hand in glove].available_amount() == 0)
            {
                string hobo_name = "Drunken half-orc hobo";
                if (my_ascensions() % 2 == 1)
                    hobo_name = "Hung-over half-orc hobo";
                potential_faxes.listAppend(hobo_name + " - run +234% item to make +ML smithness accessory.");
            }
            //nuns bandit for trickery
            if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            {
                string description = "Dirty thieving brigand - nuns trick.";
                if (!__quest_state["Level 12"].state_boolean["War started"])
                    description = HTMLGenerateSpanFont(description, "gray");
                potential_faxes.listAppend(description);
            }
            //monstrous boiler
            if (__quest_state["Level 11 Manor"].mafia_internal_step < 4 && $item[wine bomb].available_amount() == 0)
            {
                string description = "Monstrous boiler - charge up unstable fulminate.";
                if ($item[unstable fulminate].available_amount() == 0)
                    description = HTMLGenerateSpanFont(description, "gray");
                potential_faxes.listAppend(description);
            }
            if (true) //not sure about this
            {
                //marginal stuff:
                //whitesnake, white lion
                if (in_hardcore() && $items[wet stunt nut stew,mega gem].available_amount() == 0 && !__quest_state["Level 11 Palindome"].finished)
                {
                    string [int] stew_source_monsters;
                    if ($item[bird rib].available_amount() == 0)
                    {
                        stew_source_monsters.listAppend("whitesnake");
                    }
                    if ($item[lion oil].available_amount() == 0)
                    {
                        stew_source_monsters.listAppend("white lion");
                    }
                    if (stew_source_monsters.count() > 0)
                    {
                        string description = stew_source_monsters.listJoinComponents("/").capitaliseFirstLetter() + " - run +300% item/food drops for wet stunt nut stew components. (marginal?)";
                        
                        potential_faxes.listAppend(description);
                    }
                }
            }
            //blur
            if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && $item[drum machine].available_amount() == 0 && !__quest_state["Level 11 Desert"].state_boolean["Wormridden"] && in_hardcore())
            {
                potential_faxes.listAppend("Blur - +234% item for drum machine for possible desert exploration route.");
            }
            
            if (in_hardcore() && knoll_available() && __quest_state["Level 11 Hidden City"].state_boolean["need machete for liana"])
            {
                potential_faxes.listAppend("forest spirit - +234% item - forest tears can meatsmith into a muculent machete for dense liana");
            }
            //baa'baa'bu'ran
            //grungy pirate - for guitar (need 400% item/YR)
            //harem girl
            
            //FIXME rest
            //f'c'le - cleanly pirate/curmudgeonly pirate/that other pirate (and insults)
            //KGE
            
            //dairy goat? mostly for early milk of magnesium (stunt runs)
            //possessed wine rack / cabinet
            //pygmy shaman / accountant - if you absolutely have to
            //barret / aerith for equipment
            //racecar bob to olfact
            
            //brainsweeper for chef-in-the-box / bartender-in-the-box?
            //gremlins?
            
            //FIXME handsome mariachi/etc?
        }
    }
    else
    {
        //aftercore:
        //potential_faxes.listAppend("Adventurer Echo - event chroner");
        potential_faxes.listAppend("Clod Hopper (YR/+item) - floaty sand");
        potential_faxes.listAppend("Swarm of fudgewasps - fudge");
    }
    
    return potential_faxes;
}

void SFaxGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
    if (!__misc_state["in aftercore"] && !from_task)
        return;
    if (__misc_state["in aftercore"] && from_task)
        return;
    string url = "clan_viplounge.php?action=faxmachine";
    
    if (get_auto_attack() != 0)
    {
        url = "account.php?tab=combat";
    }
    
	if (__misc_state["fax available"] && $item[photocopied monster].available_amount() == 0)
        optional_task_entries.listAppend(ChecklistEntryMake("fax machine", url, ChecklistSubentryMake("Fax", "", listJoinComponents(SFaxGeneratePotentialFaxes(true), "<hr>"))));
    if ($skill[Rain Man].skill_is_usable() && my_rain() >= 50)
    {
        ChecklistEntry entry = ChecklistEntryMake("__skill rain man", "skills.php", ChecklistSubentryMake("Rain man copy", "50 rain drops", listJoinComponents(SFaxGeneratePotentialFaxes(true), "<hr>")));
        
        if (my_rain() > 93)
        {
            entry.importance_level = -10;
            task_entries.listAppend(entry);
        }
        else
            optional_task_entries.listAppend(entry);
    }
}

void SFaxGenerateResource(ChecklistEntry [int] resource_entries)
{
	SFaxGenerateEntry(resource_entries, resource_entries, false);
}


void SFaxGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SFaxGenerateEntry(task_entries, optional_task_entries, true);

}