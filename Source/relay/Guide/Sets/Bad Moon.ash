void SBadMoonGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!in_bad_moon())
        return;
    if (my_turncount() == 0 && !get_property_boolean("badMoonEncounter43") && $item[black kitten].available_amount() == 0 && !$familiar[black cat].have_familiar())
    {
        string [int] description;
        description.listAppend("For a black cat run. So cute!");
        description.listAppend("Adventure in the noob cave " + HTMLGenerateSpanFont("once", "red") + ".");
        description.listAppend(HTMLGenerateSpanFont("Will cost 14 drunkenness.", "red"));
        optional_task_entries.listAppend(ChecklistEntryMake("__familiar black cat", "", ChecklistSubentryMake("Possibly adopt a black kitten", "", description)));
    }
}

void SBadMoonGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!in_bad_moon())
        return;
    
    if (in_bad_moon() && !get_property_boolean("styxPixieVisited"))
    {
        string [int] description;
        description.listAppend("Rubdown: +25% muscle, +5 DR, +10 damage.");
        description.listAppend("Mind: +25% mysticality, +10-15 mp regen, +15 spell damage.");
        description.listAppend("Colonge: +20% items, +25% moxie, +40% meat.");
		resource_entries.listAppend(ChecklistEntryMake("__effect Hella Smooth", "heydeze.php?place=styx", ChecklistSubentryMake("Styx pixie buff", "", description), 10));
    }
}

RegisterChecklistGenerationFunction("SBadMoonGenerateChecklists");
void SBadMoonGenerateChecklists(ChecklistCollection checklist_collection)
{
    if (!in_bad_moon())
        return;
    
    ChecklistEntry [int] bad_moon_adventures_entries = checklist_collection.lookup("Bad Moon Adventures").entries;
    
    
    //badMoonEncounter01 to badMoonEncounter48
    //umm... that's a lot...
    //each area has up to one encounter, but many areas may have the same encounter (frat house/hippy camp)
    
    /*
    They're all classified under different areas, though.
    
    Things to mention:
    √lots of meat, -something
    +2 elemental resistance, 2x damage from two other elements
    +resistance all elements, all attributes -%
    +X% item, -something
    +X% meat, -something
    +20 mainstat, -5 other stats
    +40 mainstat, -50% familiar weight (black cat!)
    items, -something (black kitten and terrarium, torso awaregness, anticheese, leprechaun, loaded dice (irrelevant), potato sprout (irrelevant?)
    
    Maybe:
    +50% stat, -50% other stat
    +20 elemental damage, -~2 damage/round (g-g-g-ghosts!)
    +10 elemental damage, -2 DR (g-g-g-ghosts!)
    
    ???:
    +DR, -8 weapon damage
    */
    
    Record BadMoonAdventure
    {
        int encounter_id;
        string description;
        string conditions_to_finish;
        boolean has_additional_requirements_not_yet_met;
        location [int] locations;
    };
    BadMoonAdventure BadMoonAdventureMake(int encounter_id, location [int] locations, string description, string conditions_to_finish, boolean has_additional_requirements_not_yet_met)
    {
        BadMoonAdventure adventure;
        adventure.encounter_id = encounter_id;
        adventure.description = description;
        adventure.conditions_to_finish = conditions_to_finish;
        adventure.has_additional_requirements_not_yet_met = has_additional_requirements_not_yet_met;
        adventure.locations = locations;
        return adventure;
    }
    BadMoonAdventure BadMoonAdventureMake(int encounter_id, location l, string description, string conditions_to_finish, boolean has_additional_requirements_not_yet_met)
    {
        location [int] locations;
        locations.listAppend(l);
        return BadMoonAdventureMake(encounter_id, locations, description, conditions_to_finish, has_additional_requirements_not_yet_met);
    }
    
    void listAppend(BadMoonAdventure [int] list, BadMoonAdventure entry)
    {
        int position = list.count();
        while (list contains position)
            position += 1;
        list[position] = entry;
    }

    
    
    BadMoonAdventure [int] meat_locations;
    
    meat_locations.listAppend(BadMoonAdventureMake(38, $location[the spooky forest], "1000 meat", "", false));
    meat_locations.listAppend(BadMoonAdventureMake(39, $location[the degrassi knoll garage], "2000 meat, -myst debuff", "finish meatcar guild quest", !QuestState("questG01Meatcar").finished));
    meat_locations.listAppend(BadMoonAdventureMake(40, $location[the bat hole entrance], "3000 meat, -moxie debuff", "open boss bat's lair", __quest_state["Level 4"].state_int["areas unlocked"] < 3));
    meat_locations.listAppend(BadMoonAdventureMake(41, $location[south of the border], "4000 meat, beaten up", "", false));
    meat_locations.listAppend(BadMoonAdventureMake(42, $location[whitey's grove], "5000 meat, -20% stats debuff", "opening the road to white citadel", __quest_state["White Citadel"].mafia_internal_step >= 2));
    
    string [int] description_active;
    string [int] description_inactive;
    string url;
    foreach key, adventure in meat_locations
    {
        if (get_property_boolean("badMoonEncounter" + adventure.encounter_id))
            continue;
            
        string line = adventure.locations.listJoinComponents(" / ") + ": " + adventure.description;
        
        
        boolean greyed_out = false;
        if (adventure.has_additional_requirements_not_yet_met)
        {
            line += " - need to " + adventure.conditions_to_finish;
            line += ".";
            line = HTMLGenerateSpanFont(line, "grey");
            greyed_out = true;
        }
        else
            line += ".";
        
        if (!greyed_out)
        {
            boolean have_open_location = false;
            foreach key, l in adventure.locations
            {
                if (l.locationAvailable())
                {
                    if (url == "")
                        url = l.getClickableURLForLocation();
                    have_open_location = true;
                }
            }
            if (!have_open_location)
            {
                line = HTMLGenerateSpanFont(line, "grey");
                greyed_out = true;
            }
        }
        
        if (greyed_out)
            description_inactive.listAppend(line);
        else
            description_active.listAppend(line);
    }
    bad_moon_adventures_entries.listAppend(ChecklistEntryMake("__item dense meat stack", url, ChecklistSubentryMake("Meat", "", description_active.listUnion(description_inactive))));
    
    
}