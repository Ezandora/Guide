/*
Random notes:
-Having both a torch and mining helmet equipped will drop items from both, but not sure if at the same time.

Relevant URLs:
http://forums.kingdomofloathing.com/vb/showthread.php?p=4721915#post4721915
http://forums.kingdomofloathing.com/vb/showthread.php?p=4713383#post4713383
http://forums.kingdomofloathing.com/vb/showthread.php?p=4717434#post4717434
http://forums.kingdomofloathing.com/vb/showthread.php?p=4730373#post4730373
http://forums.kingdomofloathing.com/vb/showpost.php?p=4749602&postcount=19
*/

//should we record spelunkyUpgrades here? may not use them
Record SpelunkingStatus
{
    boolean [location] areas_unlocked;
    boolean altar_unlocked;
    boolean noncombat_due_next_adventure;
    boolean sticky_bombs_unlocked;
    int turns_left;
    int gold;
    int bombs;
    int ropes;
    int keys;
    int sacrifices;
    string buddy;
};

location SpelunkingLookupLocationStatusName(string entry)
{
    if (entry == "Burial Ground")
        return $location[The Ancient Burial Ground];
    if (entry == "LOLmec's Lair")
        return $location[LOLmec's Lair];
    if (entry == "Hell")
        return $location[Hell];
    if (entry == "Yomama's Throne")
        return $location[Yomama's Throne];
    return ("The " + entry).to_location();
}

SpelunkingStatus SpelunkingParseStatus()
{
    //spelunkyStatus(user, now 'Turns: 3, Gold: 150, Bombs: 2, Ropes: 0, Keys: 0, Buddy: A Helpful Guy, Unlocks: , Jungle, Burial Ground, Spider Hole, Sticky Bombs', default )
    //spelunkyStatus(user, now 'Turns: 10, Gold: 209, Bombs: 6, Ropes: 3, Keys: 0, Buddy: , Unlocks: Jungle, Ice Caves, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit, Snake Pit', default )
    SpelunkingStatus spelunking_status;
    spelunking_status.areas_unlocked[$location[The Mines]] = true;
    
    boolean past_unlocks = false;
    string [int] status_split = get_property("spelunkyStatus").split_string(", ");
    
    spelunking_status.sacrifices = get_property_int("spelunkySacrifices");
    foreach key, entry in status_split
    {
        if (entry == "Non-combat Due")
        {
            spelunking_status.noncombat_due_next_adventure = true;
            continue;
        }
        if (entry.stringHasPrefix("Unlocks:"))
        {
            past_unlocks = true;
            entry = entry.replace_string("Unlocks: ", "");
        }
        if (past_unlocks)
        {
            if (entry == "Sticky Bombs") //this is treated as an "Unlocks"
                spelunking_status.sticky_bombs_unlocked = true;
            else if (entry == "Altar")
                spelunking_status.altar_unlocked = true;
            else
            {
                location l = SpelunkingLookupLocationStatusName(entry);
                if (l != $location[none])
                    spelunking_status.areas_unlocked[l] = true;
            }
        }
        
        if (entry.contains_text(": "))
        {
            string [int] split_entry = entry.split_string(": "); //hopefully, there isn't one that has a : inside of it... FIXME
            if (split_entry.count() < 2)
                continue;
            string header = split_entry[0];
            if (header == "Turns")
                spelunking_status.turns_left = split_entry[1].to_int_silent();
            else if (header == "Gold")
                spelunking_status.gold = split_entry[1].to_int_silent();
            else if (header == "Bombs")
                spelunking_status.bombs = split_entry[1].to_int_silent();
            else if (header == "Ropes")
                spelunking_status.ropes = split_entry[1].to_int_silent();
            else if (header == "Keys")
                spelunking_status.keys = split_entry[1].to_int_silent();
            else if (header == "Buddy")
                spelunking_status.buddy = split_entry[1].replace_string("A ", "");
            else
            {
                if (__setting_debug_mode)
                {
                    print_html("Unknown entry type \"" + entry + "\"");
                }
            }
        }
    }
    return spelunking_status;
}

void SpelunkingGenerateNCInformation(SpelunkingStatus spelunking_status, ChecklistEntry [int] task_entries, ChecklistEntry [int] future_task_entries)
{
    
    ChecklistEntry entry;
    entry.image_lookup_name = "__item sunken chest";
    entry.should_indent_after_first_subentry = true;
    
    string first_entry_title = "";
    boolean very_important = false;
    if (spelunking_status.noncombat_due_next_adventure)
    {
        very_important = true;
        first_entry_title = "Non-combat next adventure";
        entry.url = "place.php?whichplace=spelunky";
    }
    else
    {
        int turns_left = clampi(3 - get_property_int("spelunkyWinCount"), 0, 3);
        first_entry_title = "Non-combat after " + pluraliseWordy(turns_left, "combat", "combats");
    }
    int phase = get_property_int("spelunkyNextNoncombat");
    entry.subentries.listAppend(ChecklistSubentryMake(first_entry_title, "", "Next phase is " + phase.int_to_wordy() + "."));
    
    
    location [int] shopping_areas;
    location [int] crate_areas;
    location [int] tombstone_areas;
    
    location [int] evaluation_order;
    evaluation_order.listAppend($location[The Snake Pit]);
    evaluation_order.listAppend($location[The Mines]);
    evaluation_order.listAppend($location[The Spider Hole]);
    evaluation_order.listAppend($location[The Ancient Burial Ground]);
    evaluation_order.listAppend($location[The Jungle]);
    evaluation_order.listAppend($location[The Beehive]);
    evaluation_order.listAppend($location[the crashed u. f. o.]);
    evaluation_order.listAppend($location[The Ice Caves]);
    evaluation_order.listAppend($location[The City of Goooold]);
    evaluation_order.listAppend($location[The Temple Ruins]);
    
    //FIXME Some of these gold listings are inaccurate, I think.
    foreach key, l in evaluation_order
    {
        if (!spelunking_status.areas_unlocked[l])
            continue;
        string [int] description;
        if (l == $location[the mines])
        {
            if (phase == 1)
            {
                description.listAppend("20 gold.");
                if ($item[pot].available_amount() == 0)
                    description.listAppend("A pot. (deals 20 damage, gives 10 gold once when thrown)");
            }
            else if (phase == 2)
            {
                shopping_areas.listAppend(l);
                continue;
            }
            else if (phase == 3)
            {
                //
                if (!spelunking_status.areas_unlocked[$location[the snake pit]] && spelunking_status.bombs > 0 && !spelunking_status.areas_unlocked[$location[the spider hole]])
                {
                    description.listAppend("Unlock the Snake Pit, at the cost of a bomb.|Blocks out the Spider Hole.");
                }
                if (!spelunking_status.areas_unlocked[$location[the spider hole]] && spelunking_status.bombs > 0 && !spelunking_status.areas_unlocked[$location[the snake pit]])
                {
                    description.listAppend("Unlock the Spider Hole, at the cost of a rope.|Leads to sticky bombs. Blocks out the Snake Pit.");
                }
                
                string [int] damage_avoidance;
                if ($item[trusty whip].available_amount() > 0)
                {
                    string line = "take 0 or 5 damage";
                    if ($item[trusty whip].equipped_amount() == 0)
                        line += " (equip whip first)";
                    damage_avoidance.listAppend(line);
                }
                if ($slot[off-hand].equipped_item() != $item[none])
                    damage_avoidance.listAppend("sacrifice an off-hand");
                
                if (damage_avoidance.count() == 0)
                    damage_avoidance.listAppend("take 10 damage");
                description.listAppend(damage_avoidance.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
            }
        }
        else if (l == $location[the jungle])
        {
            if (phase == 1)
            {
                shopping_areas.listAppend(l);
                continue;
            }
            else if (phase == 2)
            {
                tombstone_areas.listAppend(l);
                continue;
            }
            else if (phase == 3)
            {
                if (!spelunking_status.areas_unlocked[$location[The Beehive]] && spelunking_status.bombs > 0 && !spelunking_status.areas_unlocked[$location[The Ancient Burial Ground]])
                {
                    string line = "Unlock the Beehive, at the cost of a bomb";
                    if (!spelunking_status.sticky_bombs_unlocked)
                        line += " and 15 damage";
                    
                    line += ".|Blocks out the Ancient Burial Ground.";
                    description.listAppend(line);
                }
                if (!spelunking_status.areas_unlocked[$location[The Ancient Burial Ground]] && spelunking_status.ropes > 0 && !spelunking_status.areas_unlocked[$location[The Beehive]])
                {
                    string line = "Unlock the Ancient Burial Ground, at the cost of a rope";
                    if ($item[yellow cape].available_amount() == 0 && $item[jetpack].available_amount() == 0)
                        line += " and 15 damage";
                    line += ".";
                    
                    if ($item[yellow cape].equipped_amount() == 0 && $item[jetpack].equipped_amount() == 0)
                    {
                        if ($item[jetpack].available_amount() > 0)
                            line += " (equip jetpack first)";
                        else if ($item[yellow cape].available_amount() > 0)
                            line += " (equip yellow cape first)";
                    }
                    line += "|Useful for a different-phase Clown Crown. Blocks out the Beehive.";
                    description.listAppend(line);
                }
                
                if ($item[spring boots].available_amount() > 0)
                {
                    string line = "Nothing.";
                    if ($item[spring boots].equipped_amount() == 0)
                        line += " (equip spring boots first)";
                    description.listAppend(line);
                }
                else
                    description.listAppend("Take 30 damage.");
            }
        }
        else if (l == $location[The Ice Caves])
        {
            if (phase == 1)
            {
                shopping_areas.listAppend(l);
                continue;
            }
            else if (phase == 2)
            {
                string line = "+50-60 gold";
                if ($item[cursed coffee cup].available_amount() > 0)
                {
                    line += ", restore 30 HP.";
                    if ($item[cursed coffee cup].equipped_amount() == 0)
                        line += " (equip cursed coffee cup first)";
                }
                else
                    line += ".";
                description.listAppend(line);
                
                if ($item[torch].available_amount() > 0)
                {
                    line = "";
                    if (spelunking_status.buddy.length() == 0)
                        line = "Gain a spelunking buddy.";
                    else
                        line = "Gain 60-70 gold.";
                    
                    if ($item[torch].equipped_amount() == 0)
                        line += " (equip a torch first)";
                    description.listAppend(line);
                }
            }
            else if (phase == 3)
            {
                if (!spelunking_status.altar_unlocked)
                {
                    description.listAppend("Unlock the Altar, take 10 damage.|Blocks out U.F.O.");
                }
                if (!spelunking_status.areas_unlocked[$location[The Crashed U. F. O.]] && spelunking_status.ropes >= 3 && !spelunking_status.altar_unlocked)
                    description.listAppend("Unlock the Crashed U. F. O., at the cost of three ropes.|Blocks out altar.");
                description.listAppend("Take 30 damage.");
            }
        }
        else if (l == $location[The Temple Ruins])
        {
            if (phase == 1)
            {
                crate_areas.listAppend(l);
                continue;
            }
            else if (phase == 2)
            {
                if (spelunking_status.buddy == "Resourceful Kid")
                {
                    description.listAppend("+250 gold.");
                }
                else if ($item[jetpack].available_amount() > 0)
                {
                    string line = "+250 gold.";
                    if ($item[jetpack].equipped_amount() == 0 && !($item[spring boots].equipped_amount() > 0 && $item[yellow cape].equipped_amount() > 0))
                        line += " (equip jetpack first)";
                    description.listAppend(line);
                }
                else if ($items[spring boots,yellow cape].items_missing().count() == 0)
                {
                    string line = "+250 gold.";
                    string [int] items_to_equip;
                    foreach it in $items[spring boots,yellow cape]
                    {
                        if (it.equipped_amount() == 0)
                            items_to_equip.listAppend(it);
                    }
                    if (items_to_equip.count() > 0)
                        line += " (equip " + items_to_equip.listJoinComponents(", ", "and") + " first)";
                    description.listAppend(line);
                    
                }
                else
                {
                    description.listAppend("+250 gold, lose all HP.");
                }
            }
            else if (phase == 3)
            {
                if (spelunking_status.keys > 0 && !spelunking_status.areas_unlocked[$location[The City of Goooold]])
                {
                    description.listAppend("Unlock The City of Goooold, at the cost of one key.");
                }
                else
                    description.listAppend("Take 40 damage.");
            }
        }
        else if ($locations[the snake pit,the beehive,the crashed u. f. o.] contains l)
        {
            crate_areas.listAppend(l);
            continue;
        }
        else if (l == $location[The Spider Hole])
        {
            boolean no_period = false;
            string line = "15-20 gold";
            if ($item[cursed coffee cup].available_amount() > 0)
            {
                //line += " and " + (MIN(my_maxhp() - my_hp(), 30)) + " HP.";
                line += " and restore 30 HP."; //consistency
                if ($item[cursed coffee cup].equipped_amount() == 0)
                {
                    line += " (equip the cursed coffee cup first)";
                    no_period = true;
                }
            }
            if (!no_period)
                line += ".";
            description.listAppend(line);
            
            if ($item[sturdy machete].available_amount() > 0)
            {
                if (spelunking_status.buddy.length() == 0)
                    line = "A buddy.";
                else
                    line = "30?-40 gold."; //????
                if ($item[sturdy machete].equipped_amount() == 0)
                    line += " (equip a sturdy machete first)";
                description.listAppend(line);
            }
            if ($item[torch].available_amount() > 0)
            {
                line = "30-50 gold.";
                if ($item[torch].equipped_amount() == 0)
                    line += " (equip a torch first)";
                description.listAppend(line);
            }
        }
        else if (l == $location[The Ancient Burial Ground])
        {
            tombstone_areas.listAppend(l);
            continue;
        }
        else if (l == $location[The City of Goooold])
        {
            if (spelunking_status.keys > 0)
                description.listAppend("+150 gold, at the cost of a key.");
            if (spelunking_status.bombs > 0)
                description.listAppend("+80-100 gold, at the cost of a bomb.");
            description.listAppend("+60 gold, but take 20 damage.");
        }
        entry.subentries.listAppend(ChecklistSubentryMake(l, "", description));
    }
    if (shopping_areas.count() > 0)
    {
        string [int] description;
        description.listAppend("Shopkeeper.");
        
        string [int] possible_inventory;
        possible_inventory.listAppend("bombs");
        possible_inventory.listAppend("ropes");
        possible_inventory.listAppend("a key");
        foreach it in $items[spelunking fedora,boomerang,sturdy machete,heavy pickaxe,spiked boots,spring boots,mining helmet,X-ray goggles,yellow cape,shotgun,jetpack]
        {
            if (it.available_amount() == 0)
                possible_inventory.listAppend(it);
        }
        description.listAppend("Could have " + possible_inventory.listJoinComponents(", ", "or") + ".");
        entry.subentries.listAppend(ChecklistSubentryMake(shopping_areas.listJoinComponents(", ", "or"), "", description));
    }
    if (crate_areas.count() > 0)
    {
        string [int] drops;
        drops.listAppend("3 ropes");
        drops.listAppend("3 bombs");
        foreach it in $items[heavy pickaxe,jetpack,sturdy machete,spring boots]
        {
            //seen crate give duplicate spring boots before
            drops.listAppend(it);
        }
        entry.subentries.listAppend(ChecklistSubentryMake(crate_areas.listJoinComponents(", ", "or"), "", "Crate. Gives " + drops.listJoinComponents(", ", "or") + "."));
        //Usually drops ropes/bombs?
    }
    if (tombstone_areas.count() > 0)
    {
        string [int] description;
    
        description.listAppend("20-30? gold or a skeleton buddy."); //highest seen for me is 27
        
        if ($item[heavy pickaxe].available_amount() > 0 && $item[Shotgun].available_amount() == 0)
        {
            string line = "Shotgun";
            if ($item[heavy pickaxe].equipped_amount() == 0)
                line += " (equip heavy pickaxe first)";
            line += ".";
            description.listAppend(line);
        }
        
        if ($item[x-ray goggles].available_amount() > 0 && $item[The Clown Crown].available_amount() == 0)
        {
            string line = "The Clown Crown";
            if ($item[x-ray goggles].equipped_amount() == 0)
                line += " (equip x-ray goggles first)";
            line += ".";
            description.listAppend(line);
        }
        entry.subentries.listAppend(ChecklistSubentryMake(tombstone_areas.listJoinComponents(", ", "or"), "", description));
    }
    
    
    if (very_important)
    {
        task_entries.listAppend(entry);
        string secondary_description = "Scroll up for full description.";
        ChecklistEntry pop_up_reminder_entry = ChecklistEntryMake(entry.image_lookup_name, "", ChecklistSubentryMake(entry.subentries[0].header, "", secondary_description), -11);
        pop_up_reminder_entry.only_show_as_extra_important_pop_up = true;
        pop_up_reminder_entry.container_div_attributes["onclick"] = "navbarClick(0, 'Tasks_checklist_container')";
        pop_up_reminder_entry.container_div_attributes["class"] = "r_clickable";
        
        task_entries.listAppend(pop_up_reminder_entry);
    }
    else
        future_task_entries.listAppend(entry);
}

string [item] SpelunkingGenerateEquipmentDescriptions(SpelunkingStatus spelunking_status)
{
    string [item] equipment_descriptions;
    
    equipment_descriptions[$item[trusty whip]] = "3-6 damage.";
    equipment_descriptions[$item[sturdy machete]] = "3-6 damage, +5 weapon damage.";
    equipment_descriptions[$item[shotgun]] = "6-12 damage, +10 ranged damage.";
    equipment_descriptions[$item[boomerang]] = "3-6 damage, delevels.";
    equipment_descriptions[$item[plasma rifle]] = "9-18 damage, +20 ranged damage.";
    
    equipment_descriptions[$item[Bananubis's Staff]] = "3-6 damage, -6 gold drops, raises a skeleton buddy";
    if (spelunking_status.buddy != "")
        equipment_descriptions[$item[Bananubis's Staff]] += " later";
    equipment_descriptions[$item[Bananubis's Staff]] += ".";
    if (spelunking_status.buddy.length() == 0)
    {
        if (spelunking_status.sacrifices < 3 && !spelunking_status.areas_unlocked[$location[the crashed u. f. o.]])
            equipment_descriptions[$item[Bananubis's Staff]] += "|Use this now if you want a buddy to sacrifice.";
        else
            equipment_descriptions[$item[Bananubis's Staff]] += "|Use this now if you want a skeleton buddy. (for +stat sacrificing or Yomama)";
    }
    
    equipment_descriptions[$item[crumbling skull]] = "Can throw for 20 damage.|Afterward, can find another.";
    equipment_descriptions[$item[8042]] = "Can throw for 30 damage.|Afterward, can find another.";
    equipment_descriptions[$item[pot]] = "2 DR, can throw for 20 damage/10 gold.";
    equipment_descriptions[$item[heavy pickaxe]] = "+5 all attributes";
    equipment_descriptions[$item[torch]] = "Deals 8-10 damage first round of combat.|Finds random bombs/ropes/gold.|Can be thrown for 100 damage.|Can be thrown at Yomama for recurring damage.";
    equipment_descriptions[$item[The Joke Book of the Dead]] = "-6 gold drops, +5 weapon damage, 5 DR.";
    equipment_descriptions[$item[cursed coffee cup]] = "-2 gold drops, restores HP after combat.";
    
    equipment_descriptions[$item[spelunking fedora]] = "+5 stats.";
    equipment_descriptions[$item[mining helmet]] = "2 DR, finds random ropes/bombs/gold.";
    equipment_descriptions[$item[X-ray goggles]] = "-5 moxie, +5 gold drops.";
    equipment_descriptions[$item[The Clown Crown]] = "-6 gold drops.";
    
    //Note: Both the yellow cape and jetpack affect both boots. How to?
    item [int] boots_available;
    foreach it in $items[spring boots,spiked boots]
    {
        if (it.available_amount() > 0)
            boots_available.listAppend(it);
    }
    
    equipment_descriptions[$item[yellow cape]] = "+5 moxie";
    if (boots_available.count() > 0)
        equipment_descriptions[$item[yellow cape]] += ", improves " + boots_available.listJoinComponents(", ", "and");
    equipment_descriptions[$item[yellow cape]] += ".";
    
    equipment_descriptions[$item[jetpack]] = "+10 moxie";
    if (boots_available.count() > 0)
        equipment_descriptions[$item[jetpack]] += ", improves " + boots_available.listJoinComponents(", ", "and");
    equipment_descriptions[$item[jetpack]] += ".";
    
    equipment_descriptions[$item[spring boots]] = "Avoids enemy attacks.";
    equipment_descriptions[$item[spiked boots]] = "Deals ";
    if ($item[jetpack].equipped_amount() > 0)
        equipment_descriptions[$item[spiked boots]] += "14-15";
    else if ($item[yellow cape].equipped_amount() > 0)
        equipment_descriptions[$item[spiked boots]] += "8-10";
    else
        equipment_descriptions[$item[spiked boots]] += "4-5";
    equipment_descriptions[$item[spiked boots]] += " damage first round of combat.";
    if ($item[jetpack].available_amount() > 0)
    {
        if ($item[jetpack].equipped_amount() == 0)
            equipment_descriptions[$item[spiked boots]] += " (equip jetpack for more)";
    }
    else if ($item[yellow cape].available_amount() > 0 && $item[yellow cape].equipped_amount() == 0)
        equipment_descriptions[$item[spiked boots]] += " (equip yellow cape for more)";
    
    return equipment_descriptions;
}

void SpelunkingGenerateEquipmentEntries(Checklist [int] checklists, SpelunkingStatus spelunking_status)
{
    /*ChecklistEntry [int] equipment_entries;

    if (true)
    {
        Checklist equipment_checklist;
        equipment_checklist = ChecklistMake("Equipment", equipment_entries);
        checklists.listAppend(equipment_checklist);
    }*/
    
    string [item] equipment_descriptions = SpelunkingGenerateEquipmentDescriptions(spelunking_status);
    
    
    item [slot][int] equipment_per_slot;
    
    foreach it in $items[trusty whip,sturdy machete,shotgun,boomerang,plasma rifle,Bananubis's Staff,crumbling skull,8042,pot,heavy pickaxe,torch,The Joke Book of the Dead,cursed coffee cup,spelunking fedora,mining helmet,X-ray goggles,The Clown Crown,yellow cape,jetpack,spring boots,spiked boots]
    {
        if (it.available_amount() == 0)
            continue;
        
        if (!(equipment_per_slot contains it.to_slot()))
        {
            item [int] blank_entries;
            equipment_per_slot[it.to_slot()] = blank_entries;
        }
        equipment_per_slot[it.to_slot()].listAppend(it);
    }
    
    slot [int] slot_evaluation_order;
    slot_evaluation_order.listAppend($slot[weapon]);
    slot_evaluation_order.listAppend($slot[off-hand]);
    slot_evaluation_order.listAppend($slot[hat]);
    slot_evaluation_order.listAppend($slot[back]);
    slot_evaluation_order.listAppend($slot[acc1]);
    foreach s in equipment_per_slot
    {
        if (!($slots[weapon,off-hand,hat,back,acc1] contains s))
            slot_evaluation_order.listAppend(s);
    }
    
    foreach key, s in slot_evaluation_order
    {
        if (!(equipment_per_slot contains s))
            continue;
        
        string slot_name = s.slot_to_plural_string().capitaliseFirstLetter();
        
        /*ChecklistEntry entry;
        entry.subentries.listAppend(ChecklistSubentryMake(slot_name, "", ""));
        entry.should_indent_after_first_subentry = true;
        boolean have_something_to_unequip = false;*/
        
        ChecklistEntry [int] checklist_entries;
        
        foreach key2 in equipment_per_slot[s]
        {
            item it = equipment_per_slot[s][key2];
            string header = it.capitaliseFirstLetter();
            if (it.available_amount() > 1)
                header = pluralise(it);
            string description;
            
            description = equipment_descriptions[it];
            
            /*if (it.equipped_amount() == 0)
                have_something_to_unequip = true;
            
            if (entry.image_lookup_name.length() == 0)
                entry.image_lookup_name = "__item " + it;
            
            entry.subentries.listAppend(ChecklistSubentryMake(header, "", description));*/
            ChecklistEntry entry = ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake(header, "", description));
            if (it.equipped_amount() > 0)
            {
                entry.should_highlight = true;
                if (it.to_slot() != $slot[none])
                    entry.url = "place.php?whichplace=spelunky";
            }
            else if (it.to_slot() != $slot[none])
            {
                //this is an interesting idea, but it violates our rule that clicking guide never modifies significant state
                //in other words, guide should feel "safe" to click on
                //I mean, you should never feel safe around guide. save yourself!
                //But, it seems useful enough to be worth doing...
                entry.url = "inv_equip.php?pwd=" + my_hash() + "&which=2&action=equip&whichitem=" + it.to_int();
                //KoLmafia/sideCommand?cmd=uneffect+effect&pwd=hash
                //entry.url = "KoLmafia/sideCommand?pwd=" + my_hash() + "&cmd=equip+" + it.replace_string(" ", "+");
                //entry.url = "inventory.php?which=2";
            }
            checklist_entries.listAppend(entry);
            
        }
        /*if (have_something_to_unequip)
            entry.url = "inventory.php?which=2";
        equipment_entries.listAppend(entry);*/
        
        

        if (true)
        {
            Checklist c;
            c = ChecklistMake(slot_name, checklist_entries);
            checklists.listAppend(c);
        }
    }
}


void LimitModeSpelunkingGenerateChecklists(Checklist [int] checklists)
{
    if (limit_mode() != "spelunky")
        return;
    ChecklistEntry [int] task_entries;
    ChecklistEntry [int] optional_task_entries;
    ChecklistEntry [int] future_task_entries;
    ChecklistEntry [int] resource_entries;

    if (true)
    {
        Checklist task_checklist;
        task_checklist = ChecklistMake("Tasks", task_entries);
        checklists.listAppend(task_checklist);
        
        
        Checklist optional_task_checklist;
        optional_task_checklist = ChecklistMake("Optional Tasks", optional_task_entries);
        checklists.listAppend(optional_task_checklist);
        
        Checklist future_task_checklist;
        future_task_checklist = ChecklistMake("Future Tasks", future_task_entries);
        checklists.listAppend(future_task_checklist);
        
        Checklist resources_checklist;
        resources_checklist = ChecklistMake("Resources", resource_entries);
        checklists.listAppend(resources_checklist);
    }
    
    string spelunking_url = "place.php?whichplace=spelunky";
    
    
    SpelunkingStatus spelunking_status = SpelunkingParseStatus();
    
    
    if (spelunking_status.turns_left == 0)
    {
        string [int] description;
        
        string [int] accomplishments;
        if (spelunking_status.gold > 0)
            accomplishments.listAppend("earned " + spelunking_status.gold + " gold");
        if (spelunking_status.sacrifices > 0)
            accomplishments.listAppend("sacrificed " + pluraliseWordy(spelunking_status.sacrifices, "noble friend", "noble friends")); //is this really an... accomplishment?
        if (accomplishments.count() > 0)
            description.listAppend("You " + accomplishments.listJoinComponents(", ", "and") + ".");
        
        task_entries.listAppend(ChecklistEntryMake("__item spelunking fedora", "place.php?whichplace=spelunky&action=spelunky_quit", ChecklistSubentryMake("Ride off into the sunset", "", description)));
        return;
    }
    
    SpelunkingGenerateNCInformation(spelunking_status, task_entries, future_task_entries);
    
    
    if (my_hp() == 0)
    {
        task_entries.listAppend(ChecklistEntryMake("__effect beaten up", spelunking_url, ChecklistSubentryMake("Heal", "", "Probably at your tent. (costs a turn)"), -11));
    }
    
    if ($item[jetpack].available_amount() > 0 && $item[yellow cape].equipped_amount() > 0 && !spelunking_status.noncombat_due_next_adventure)
    {
        task_entries.listAppend(ChecklistEntryMake("__item jetpack", "inv_equip.php?pwd=" + my_hash() + "&which=2&action=equip&whichitem=" + $item[jetpack].to_int(), ChecklistSubentryMake("Equip jetpack", "", "More efficient than the yellow cape."), -11));
    }
    
    if (get_property("spelunkyUpgrades").contains_text("N"))
    {
        int unlocks_found = 0;
        string upgrades_string = get_property("spelunkyUpgrades");
        for i from 0 to upgrades_string.length() - 1
        {
            if (upgrades_string.char_at(i) == "Y")
                unlocks_found += 1;
        }
        
        int unlocks_remaining = clampi(9 - unlocks_found, 0, 9);
        
        int after_this_remaining = MAX(0, unlocks_remaining - 1);
        
        if (after_this_remaining > 0)
            future_task_entries.listAppend(ChecklistEntryMake("__item heavy pickaxe", "", ChecklistSubentryMake("Spelunk " + pluraliseWordy(after_this_remaining, "more time", "more times") + " after this", "", "Unlock all the starting bonuses.")));
    }
    
    if (spelunking_status.altar_unlocked && spelunking_status.buddy != "")
    {
        string [int] description;
        //spelunking_status.sacrifices
        if (spelunking_status.buddy == "Resourceful Kid")
            description.listAppend("He's just a kid! Don't do it!");
        else if (spelunking_status.buddy == "Helpful Guy")
            description.listAppend("But, he's really helpful... a loyal companion at your side! Could you betray him?");
        else if (spelunking_status.buddy == "Skeleton")
        {
            description.listAppend("A skeleton probably won't mind. They're just magic, right?|Still, it is a betrayal...");
        }
        else if (spelunking_status.buddy == "Golden Monkey")
            description.listAppend("Animal sacrifice... is it really worth it?");
        else
            description.listAppend("But, will you betray your friend?");
        
        string [int] results;
        
        if (spelunking_status.sacrifices == 0)
            results.listAppend("cursed coffee cup");
        else if (spelunking_status.sacrifices == 1)
        {
            item next_item;
            if ($item[x-ray goggles].available_amount() == 0)
                next_item = $item[x-ray goggles];
            else if ($item[spiked boots].available_amount() == 0)
                next_item = $item[spiked boots];
            else if ($item[jetpack].available_amount() == 0)
                next_item = $item[jetpack];
            else
                next_item = $item[8042];
            results.listAppend(next_item);
        }
        else if (spelunking_status.sacrifices == 2)
            results.listAppend("The Joke Book of the Dead (used for unlocking Hell/fighting ghost)");
        
        
        if (spelunking_status.sacrifices == 0)
            results.listAppend("+10 to all stats");
        else if (spelunking_status.sacrifices == 1)
            results.listAppend("+5 to all stats");
        else if (spelunking_status.sacrifices >= 2)
            results.listAppend("+1 to all stats");
        
        if ($item[cursed coffee cup].available_amount() > 0)
        {
            string line = "30 HP restoration";
            if ($item[cursed coffee cup].equipped_amount() == 0)
                line += " (equip cursed coffee cup first)";
        }
        
        if ($item[Bananubis's Staff].available_amount() > 0)
            description.listAppend("Consider repeatedly summoning/sacrificing skeletons for extra stats. (Bananubis's Staff)");
        
        if (results.count() > 0)
            description.listAppend("Gives " + results.listJoinComponents(", ", "and") + ".");
        
        if (spelunking_status.sacrifices < 2)
            description.listAppend("Part of unlocking Hell."); //where else would you go?
        
        if (spelunking_status.sacrifices > 0)
            description.listAppend(pluraliseWordy(spelunking_status.sacrifices, "sacrifice", "sacrifices").capitaliseFirstLetter() + " so far.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item Cloaca-Cola-issue combat knife", spelunking_url, ChecklistSubentryMake("Possibly sacrifice " + spelunking_status.buddy.to_lower_case() + " at the altar", "", description)));
        //place.php?whichplace=spelunky&action=spelunky_side6
    }
    
    
    
    if ($item[the joke book of the dead].available_amount() > 0)
    {
        string url;
        string [int] description;
        string [int] tasks;
        description.listAppend("If you haven't already.");
        
        if ($item[the joke book of the dead].equipped_amount() == 0)
        {
            tasks.listAppend("after equipping " + $item[the joke book of the dead]);
            url = "inventory.php?which=2";
        }
        tasks.listAppend("click on the ghost");
        description.listAppend(tasks.listJoinComponents(", ").capitaliseFirstLetter() + ".");
        description.listAppend("Gives ten more turns on victory.");
        
        
        string [int] ideas;
        foreach it in $items[spring boots,boomerang,spelunking fedora]
        {
            if (it.equipped_amount() == 0)
                ideas.listAppend(it);
        }
        if (spelunking_status.buddy != "Skeleton")
            ideas.listAppend("skeleton");
        ideas.listAppend("ropes");
        
        
            
        description.listAppend("Defeating it involves... " + ideas.listJoinComponents(", ") + "?");
        
        optional_task_entries.listAppend(ChecklistEntryMake("__item ghost trap", url, ChecklistSubentryMake("Possibly attack the ghost", "", description)));
    }
    
    if (spelunking_status.areas_unlocked[$location[the city of Goooold]] && $item[Bananubis's Staff].available_amount() == 0)
    {
        string [int] description;
        description.listAppend("Part of unlocking Hell, and the staff can give stats via sacrifices.");
        if (spelunking_status.sticky_bombs_unlocked)
            description.listAppend("Throw two bombs.");
        else
        {
            string [int] tasks;
            if ($item[spring boots].available_amount() == 0)
                tasks.listAppend("acquire spring boots");
            else if ($item[spring boots].equipped_amount() == 0)
                tasks.listAppend("equip spring boots");
            tasks.listAppend("rope until spring boots activate");
            tasks.listAppend("throw a bomb");
            tasks.listAppend("throw a bomb or attack or whatever will kill him");
            description.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + "?");
            description.listAppend("Or acquire sticky bombs.");
        }
        description.listAppend("Appears after defeating five mummies in the area.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item Bananubis's Staff", spelunking_url, ChecklistSubentryMake("Defeat Bananubis", "", description)));
    }
    
    if (spelunking_status.areas_unlocked[$location[LOLmec's lair]] && !spelunking_status.areas_unlocked[$location[Hell]])
    {
        //defeat LOLMec
        string [int] description;
        description.listAppend("If you haven't already.");
        if (spelunking_status.bombs < 10)
            description.listAppend("Collect ten bombs first.");
        else
        {
            string line = "Throw ten bombs.";
            if (!spelunking_status.sticky_bombs_unlocked && spelunking_status.bombs >= 20)
                line += " Or twenty.";
            description.listAppend(line);
            if (!spelunking_status.sticky_bombs_unlocked)
            {
                if (!spelunking_status.areas_unlocked[$location[the snake pit]])
                    description.listAppend("Possibly acquire sticky bombs from the spider queen.");
                    
                string [int] ideas;
                foreach it in $items[spring boots,shotgun,spelunking fedora,8042]
                {
                    if (it.equipped_amount() == 0)
                        ideas.listAppend(it);
                }
                if (spelunking_status.buddy != "Skeleton")
                    ideas.listAppend("skeleton");
                ideas.listAppend("ropes");
                
                
                    
                description.listAppend("Umm... " + ideas.listJoinComponents(", ") + "?");
            }
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item LOLmec statuette", spelunking_url, ChecklistSubentryMake("Defeat LOLmec", "", description)));
    }
    
    if (spelunking_status.areas_unlocked[$location[Yomama's Throne]])
    {
        string [int] description;
        description.listAppend("If you haven't already.");
        description.listAppend("Umm... throw a bomb, throw a torch, stagger with ropes? Spring boots? Fedora?|Or defeat him another way. Skeleton buddy might help.");
        optional_task_entries.listAppend(ChecklistEntryMake("__item huge gold coin", spelunking_url, ChecklistSubentryMake("Defeat Yomama", "", description)));
    }
    
    if (!spelunking_status.areas_unlocked[$location[the temple ruins]])
    {
    }
    else if (!spelunking_status.areas_unlocked[$location[Hell]] && $items[Bananubis's Staff,The Joke Book of the Dead,The Clown Crown].items_missing().count() == 0)
    {
        if (spelunking_status.keys == 0)
        {
            optional_task_entries.listAppend(ChecklistEntryMake("__item Clan VIP Lounge key", "", ChecklistSubentryMake("Acquire a key", "", "For unlocking Hell.")));
        }
        else
        {
            string [int] description;
            string [int] tasks;
            string url;
            url = spelunking_url;
            
            foreach it in $items[Bananubis's Staff,The Joke Book of the Dead,The Clown Crown]
            {
                if (it.equipped_amount() == 0)
                {
                    tasks.listAppend("equip " + it);
                    url = "inventory.php?which=2";
                }
            }
            tasks.listAppend("click on LOLmec's lair");
            if (tasks.count() > 0)
                description.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
            description.listAppend(HTMLGenerateSpanFont("Only do this if you've defeated LOLmec already.", "red"));
            optional_task_entries.listAppend(ChecklistEntryMake("__item Clan VIP Lounge key", url, ChecklistSubentryMake("Unlock Hell", "", description)));
        }
    }
    else if (!spelunking_status.areas_unlocked[$location[Hell]] && !(spelunking_status.areas_unlocked[$location[the crashed u. f. o.]]))
    {
        string [int] description;
        string [int] tasks;
        if ($item[Bananubis's Staff].available_amount() == 0)
        {
            tasks.listAppend("acquire Bananubis's Staff");
        }
        if ($item[The Joke Book of the Dead].available_amount() == 0)
        {
            tasks.listAppend("sacrifice buddies for the Joke Book of the Dead");
        }
        if ($item[x-ray goggles].available_amount() == 0)
        {
            tasks.listAppend("acquire x-ray goggles");
        }
        if ($item[The Clown Crown].available_amount() == 0)
        {
            tasks.listAppend("acquire the Clown Crown from the jungle/burial ground NCs");
        }
        if (!spelunking_status.areas_unlocked[$location[LOLmec's lair]])
            tasks.listAppend("unlock LOLmec's lair");
        tasks.listAppend("defeat LOLmec");
        if (spelunking_status.keys == 0)
            tasks.listAppend("acquire a key");
        
        description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        optional_task_entries.listAppend(ChecklistEntryMake("__item handful of fire", "", ChecklistSubentryMake("Unlock Hell", "", description)));
    }
    
    if (true)
    {
        string [int] description;
        if (__setting_debug_mode && false)
        {
            //spelunkyNextNoncombat,spelunkyWinCount,spelunkyUpgrades,spelunkySacrifices
            foreach s in $strings[spelunkyStatus]
            {
                description.listAppend(s + " = \"" + get_property(s) + "\"");
            }
            description.listAppend("spelunking_status = " + spelunking_status.to_json());
        }
        
        string [int] areas_to_adventure_in;
        areas_to_adventure_in.listAppend("Mines: if the other areas are too difficult.");
        //snake pit - marginal?
        if (spelunking_status.areas_unlocked[$location[the spider hole]] && !spelunking_status.sticky_bombs_unlocked)
            areas_to_adventure_in.listAppend("The Spider Hole: to unlock sticky bombs.");
        //burial ground
        if (spelunking_status.areas_unlocked[$location[the jungle]] && $item[torch].available_amount() == 0)
            areas_to_adventure_in.listAppend("Jungle: chance a torch from tikimen. Throwing rocks works well here.");
        //beehive
        //UFO
        //ice caves - unlocking temple ruins...?
        if (spelunking_status.areas_unlocked[$location[The City of Goooold]] && $item[Bananubis's Staff].available_amount() == 0)
            areas_to_adventure_in.listAppend("City of Goooold: defeat boss for Bananubis's staff. Part of unlocking Hell.");
        //temple ruins
        if (spelunking_status.areas_unlocked[$location[the temple ruins]] && !spelunking_status.areas_unlocked[$location[lolmec's lair]])
            areas_to_adventure_in.listAppend("Temple ruins: unlock LOLmec's lair.");
        //lolmec's lair
        //yomama's lair
        if (spelunking_status.areas_unlocked[$location[hell]] && !spelunking_status.areas_unlocked[$location[yomama's throne]])
            areas_to_adventure_in.listAppend("Hell: unlock Yomama's throne after seven combats won.");
            
        if (spelunking_status.areas_unlocked[$location[the temple ruins]])
            areas_to_adventure_in.listAppend("Temple ruins: to collect gold.");
        else
            areas_to_adventure_in.listAppend("Somewhere: to collect gold.");
        if (areas_to_adventure_in.count() > 0)
            description.listAppend("Adventure in:|*" + areas_to_adventure_in.listJoinComponents("|*<hr>"));
            
        //description.listAppend("Usual combat strategy:|*Throw a bomb or rope if they're powerful (and you can afford it), then attack. Try to avoid taking damage, or heal it with a cursed coffee cup.");
        task_entries.listAppend(ChecklistEntryMake("__item heavy pickaxe", spelunking_url, ChecklistSubentryMake("Spelunk!", "", description)));
    }
    
    SpelunkingGenerateEquipmentEntries(checklists, spelunking_status);
}