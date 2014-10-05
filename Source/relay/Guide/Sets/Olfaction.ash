void SOlfactionGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!$skill[Transcendent Olfaction].have_skill())
        return;
    if ($effect[On the trail].have_effect() == 0)
        return;
    if ($item[soft green echo eyedrop antidote].available_amount() == 0) //no removal method
        return;
    
    //Add in some basic reminders to remove olfaction if adventuring in certain areas.
    
    monster olfacted_monster = get_property("olfactedMonster").to_monster();
    if (olfacted_monster == $monster[none] || __last_adventure_location == $location[none])
        return;
    
    monster [location] location_wanted_monster;
    
    if (__misc_state["In run"])
    {
        if ($item[Talisman o' Nam].available_amount() == 0 && !__quest_state["Level 11 Palindome"].finished)
            location_wanted_monster[$location[belowdecks]] = $monster[gaudy pirate];
        if (!__quest_state["Level 8"].state_boolean["Past mine"])
            location_wanted_monster[$location[the goatlet]] = $monster[dairy goat];
        if (!__quest_state["Level 7"].state_boolean["niche finished"])
            location_wanted_monster[$location[the defiled niche]] = $monster[dirty old lihc];
        
        if (!__quest_state["Azazel"].finished)
        {
            location_wanted_monster[$location[infernal rackets backstage]] = $monster[serialbus];
            location_wanted_monster[$location[the laugh floor]] = $monster[ch imp];
        }
        //Deliberately ignored - the quiet healer. (she's used to it) It's possible they may want to olfact the burly sidekick instead, and there's plenty of time in that area.
        
        if (!__quest_state["Level 11 Hidden City"].finished)
        {
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Apartment finished"] && $effect[thrice-cursed].have_effect() == 0)
                location_wanted_monster[$location[the hidden apartment building]] = $monster[pygmy shaman];
                
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Hospital finished"] && $items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel].items_missing().count() > 0)
                location_wanted_monster[$location[the hidden hospital]] = $monster[pygmy witch surgeon];
                
                
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Office finished"] && $item[McClusky file (page 5)].available_amount() == 0 && $item[McClusky file (complete)].available_amount() == 0)
                location_wanted_monster[$location[the hidden office building]] = $monster[pygmy witch accountant];
                
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Bowling alley finished"])
            location_wanted_monster[$location[the hidden bowling alley]] = $monster[pygmy bowler];
        }
        location_wanted_monster[$location[cobb's knob harem]] = $monster[knob goblin harem girl];
        location_wanted_monster[$location[The Dark Neck of the Woods]] = $monster[Hellion];
        if (have_skill($skill[summon smithsness]) && $item[dirty hobo gloves].available_amount() == 0 && $item[hand in glove].available_amount() == 0 && __misc_state["Need to level"])
        {
            location_wanted_monster[$location[The Sleazy Back Alley]] = $monster[drunken half-orc hobo];
            location_wanted_monster[$location[The Haunted Pantry]] = $monster[drunken half-orc hobo];
        }
        location_wanted_monster[$location[fear man's level]] = $monster[morbid skull];
        location_wanted_monster[$location[8-bit realm]] = $monster[blooper];
        
        
        if (!__quest_state["Level 11 Pyramid"].finished && olfacted_monster != $monster[tomb servant])
            location_wanted_monster[$location[the middle chamber]] = $monster[tomb rat];

        //FIXME make astronomer suggestions finer-grained
        if (!($monsters[One-Eyed Willie,Burrowing Bishop,Family Jewels,Hooded Warrior,Junk,Pork Sword,Skinflute,Trouser Snake,Twig and Berries,Axe Wound,Beaver,Box,Bush,Camel's Toe,Flange,Honey Pot,Little Man in the Canoe,Muff] contains olfacted_monster))
            location_wanted_monster[$location[the hole in the sky]] = $monster[astronomer];
    }
    
    if (!($monsters[ferocious roc,giant man-eating shark,Bristled Man-O-War,The Cray-Kin,Deadly Hydra] contains olfacted_monster))
        location_wanted_monster[$location[the old man's bathtime adventures]] = $monster[none];
    
    
    foreach l in location_wanted_monster
    {
        monster m = location_wanted_monster[l];
        if (l == $location[none])
            continue;
        if (__last_adventure_location != l)
            continue;
        if (m == olfacted_monster)
            continue;
        
        boolean all_other_monsters_banished = true;
        foreach key, m2 in l.get_monsters()
        {
            if (m == m2)
                continue;
            if (!m2.is_banished())
            {
                all_other_monsters_banished = false;
                break;
            }
        }
        if (all_other_monsters_banished)
            continue;
        
        string [int] description;
        
        string line;
        
        if (m != $monster[none])
            line += "To olfact " + m.HTMLEscapeString() + " instead of " + olfacted_monster.HTMLEscapeString() + ".|";
        else
            line += "To olfact in " + l + ".|";
        
        line += $item[soft green echo eyedrop antidote].pluralize() + " available.";
        
        description.listAppend(line);
        
        
        //Suggestion time!
        task_entries.listAppend(ChecklistEntryMake("__item " + $item[soft green echo eyedrop antidote], "inventory.php?which=1", ChecklistSubentryMake("Remove " + $effect[on the trail], "", description), -11));
        
        break;
    }
    
}