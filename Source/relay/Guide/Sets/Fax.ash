void SFaxGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
	if (!(__misc_state["fax available"] && $item[photocopied monster].available_amount() == 0))
        return;
    if (!__misc_state["In aftercore"] && !from_task)
        return;
    if (__misc_state["In aftercore"] && from_task)
        return;
    string url = "clan_viplounge.php?action=faxmachine";
    string [int] potential_faxes;
    
    boolean can_arrow = false;
    if (get_property_int("_badlyRomanticArrows") == 0 && (familiar_is_usable($familiar[obtuse angel]) || familiar_is_usable($familiar[reanimated reanimator])))
        can_arrow = true;
    
    
    if (get_auto_attack() != 0)
    {
        url = "account.php?tab=combat";
        potential_faxes.listAppend("Auto attack is on, disable it?");
    }
    
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
        if ($item[ninja carabiner].available_amount() + $item[ninja crampons].available_amount() + $item[ninja rope].available_amount() <3)
        {
            string fax = "";
            fax += ChecklistGenerateModifierSpan("+150% init or more, two copies");
            fax += "Copy twice for recreational mountain climbing";
            fax += "<br>" + generateNinjaSafetyGuide(false);
            if ($familiar[obtuse angel].familiar_is_usable() && $familiar[reanimated reanimator].familiar_is_usable())
                fax += "<br>Make sure to copy with angel, not the reanimator.";
            
        
            fax = "ninja snowman assassin" + HTMLGenerateIndentedText(fax);
            potential_faxes.listAppend(fax);
        }
    }
    
    
    //quantum mechanic
    if (!__quest_state["Level 13"].state_boolean["past gates"] && !(__misc_state["dungeons of doom unlocked"]) && __misc_state["can use clovers"] && $item[Blessed large box].available_amount() == 0 && $item[large box].available_amount() == 0 && in_hardcore())
    {
        string fax = "";			
        fax += ChecklistGenerateModifierSpan("+150% item, clover with result, 3 drunkenness.");
        fax += "Blessed large box. (skips opening dungeons of doom for NS gate)";
    
        fax = "quantum mechanic" + HTMLGenerateIndentedText(fax);
        potential_faxes.listAppend(fax);
    }
    
    
    if (!(__quest_state["Level 12"].finished || __quest_state["Level 12"].state_boolean["Lighthouse Finished"] || $item[barrel of gunpowder].available_amount() == 5))
    {
        string line = "Lobsterfrogman (lighthouse quest; copy";
        if (can_arrow)
            line += "/arrow";
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
    //sorceress tower/gate item monsters (so many, list them all)
    
    if (!familiar_is_usable($familiar[angry jung man]) && in_hardcore())
    {
        //Can't pull for jar of psychoses, no jung man...
        //It's time for a g-g-g-ghost! zoinks!
        if (!__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
        {
            string line = "Ghost - only if you can copy it.";
            if (can_arrow)
                line += " (arrow?)";
            line += "|5 white pixels drop per ghost, speeds up digital key.|Run +150% item.";
            potential_faxes.listAppend(line);
        }
    }
    
    optional_task_entries.listAppend(ChecklistEntryMake("fax machine", url, ChecklistSubentryMake("Fax", "", listJoinComponents(potential_faxes, "<hr>"))));
}

void SFaxGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SFaxGenerateEntry(available_resources_entries, available_resources_entries, false);
}


void SFaxGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SFaxGenerateEntry(task_entries, optional_task_entries, true);

}