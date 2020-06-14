import "relay/Guide/Support/Monster Data.ash";

RegisterTaskGenerationFunction("IOTMProtonicAcceleratorPackGenerateTasks");
void IOTMProtonicAcceleratorPackGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Quest:
    if (QuestState("questPAGhost").in_progress || get_property("ghostLocation") != "")
    {
        int priority = 0;
        if (__misc_state["in run"])
            priority = -1;
        location ghost_location = get_property_location("ghostLocation");
        monster ghost = __protonic_monster_for_location[ghost_location];
        float ml_in_location = ghost_location.monster_level_adjustment_for_location();
        string title = "Defeat the ghost in " + ghost_location;
        string [int] description;
        string [int] modifiers;
        string url = ghost_location.getClickableURLForLocation();
        description.listAppend("Won't cost a turn.");
        if ($item[protonic accelerator pack].equipped_amount() > 0)
        {
            float expected_damage = ghost.expectedDamageFromGhostAfterCastingShootGhost();
            float hp_needed = expected_damage * 3;
            
            //FIXME initial hit damage
            //don't know if expected_damage() will be correct, it isn't always
            float initial_hit_damage = ghost.expected_damage();
            float elemental_ml_damage = 0.0;
            if (ml_in_location >= 26.0 && ghost.defense_element != $element[none])
            {
                //[Monster Attack] * MIN( ( [Bonus ML] - 25 ) / 500 , 1 / 2 )
                //FIXME range. 1.1?
                elemental_ml_damage = 1.1 * ghost.base_attack * min(0.5, (ml_in_location - 25.0) / 500.0);
                elemental_ml_damage *= 1.0 - elemental_resistance(ghost.defense_element) / 100.0;
                elemental_ml_damage = ceil(elemental_ml_damage);
            }
            hp_needed += elemental_ml_damage + initial_hit_damage;
            
            if (hp_needed >= my_maxhp())
            {
                description.listAppend(HTMLGenerateSpanFont("Do not cast \"shoot ghost\", you won't survive.", "red"));
                if (ml_in_location <= 50)
                    description.listAppend("Or stun the monster for multiple rounds, and cast \"shoot ghost\" three times, then \"trap ghost\".");
            }
            else if (hp_needed >= my_hp())
            {
                description.listAppend(HTMLGenerateSpanFont("Restore HP", "red") + " to cast \"shoot ghost\".");
                if (ml_in_location <= 50)
                    description.listAppend("Or stun the monster for multiple rounds, and cast \"shoot ghost\" three times, then \"trap ghost\".");
            }
            else
            {
                description.listAppend("Cast \"shoot ghost\" three times, then \"trap ghost\".");
            }
            description.listAppend("After casting \"shoot ghost\", the ghost will deal " + expected_damage.to_int() + " damage/round.");
        }
        item [int] items_to_equip;
        if ($item[protonic accelerator pack].equipped_amount() == 0 && $item[protonic accelerator pack].available_amount() > 0)
        {
            //Strictly speaking, they don't need the pack equipped to fight the monster, but they won't be able to trap it and get the item.
            url = "inventory.php?which=2";
            items_to_equip.listAppend($item[protonic accelerator pack]);
        }
        if (ghost_location == $location[inside the palindome] && $item[Talisman o' Namsilat].equipped_amount() == 0)
        {
            if ($item[Talisman o' Namsilat].available_amount() == 0)
            {
                priority = 10;
                description.listAppend("Need Talisman o' Namsilat first.");
            }
            else
            {
                url = "inventory.php?which=2";
                items_to_equip.listAppend($item[talisman o' namsilat]);
            }
        }
        if (ghost_location == $location[the skeleton store] && !ghost_location.locationAvailable())
        {
            //bone with a price tag on it
            if (my_path_id() == PATH_NUCLEAR_AUTUMN)
            {
                if ($item[bone with a price tag on it].available_amount() > 0)
                {
                    url = "inventory.php?ftext=bone+with+a+price+tag+on+it";
                    description.listAppend("Use the bone with a price tag on it to unlock the store.");
                }
            }
            else
            {
                url = "shop.php?whichshop=meatsmith&action=talk";
                description.listAppend("Talk to the meatsmith and start his quest.");
            }
        }
        if (ghost_location == $location[The Overgrown Lot] && !ghost_location.locationAvailable())
        {
            //bone with a price tag on it
            if (my_path_id() == PATH_NUCLEAR_AUTUMN)
            {
                if ($item[map to a hidden booze cache].available_amount() > 0)
                {
                    url = "inventory.php?ftext=map+to+a+hidden+booze+cache";
                    description.listAppend("Use the map to a hidden booze cache to unlock the store.");
                }
            }
            else
            {
                url = "shop.php?whichshop=doc&action=talk";
                description.listAppend("Talk to Doc Galaktik and start his quest.");
            }
        }
        if (ghost_location == $location[Madness Bakery] && !ghost_location.locationAvailable())
        {
            //bone with a price tag on it
            if (my_path_id() == PATH_NUCLEAR_AUTUMN)
            {
                if ($item[hypnotic breadcrumbs].available_amount() > 0)
                {
                    url = "inventory.php?ftext=hypnotic+breadcrumbs";
                    description.listAppend("Use the hypnotic breadcrumbs to unlock the store.");
                }
            }
            else
            {
                url = "shop.php?whichshop=armory&action=talk";
                description.listAppend("Talk to Armorer and start his quest.");
            }
        }
        
        if (items_to_equip.count() > 0)
            description.listAppend("Equip the " + items_to_equip.listJoinComponents(", ", "and") + " first.");
        
        element [location] elements_to_resist;
        elements_to_resist[$location[Cobb's Knob Treasury]] = $element[spooky];
        elements_to_resist[$location[The Haunted Conservatory]] = $element[stench];
        elements_to_resist[$location[The Haunted Gallery]] = $element[hot];
        elements_to_resist[$location[The Haunted Kitchen]] = $element[cold];
        elements_to_resist[$location[The Haunted Wine Cellar]] = $element[sleaze];
        elements_to_resist[$location[The Icy Peak]] = $element[hot];
        elements_to_resist[$location[Inside the Palindome]] = $element[spooky];
        elements_to_resist[$location[Madness Bakery]] = $element[hot];
        elements_to_resist[$location[The Old Landfill]] = $element[stench];
        elements_to_resist[$location[The Overgrown Lot]] = $element[sleaze];
        elements_to_resist[$location[The Skeleton Store]] = $element[spooky];
        elements_to_resist[$location[The Smut Orc Logging Camp]] = $element[spooky];
        elements_to_resist[$location[The Spooky Forest]] = $element[spooky];
        
        if (elements_to_resist contains ghost_location)
            modifiers.listAppend(HTMLGenerateSpanOfClass("+" + elements_to_resist[ghost_location] + " resist", "r_element_" + elements_to_resist[ghost_location]));
            
        if (ghost_location != $location[none])
            optional_task_entries.listAppend(ChecklistEntryMake("__item protonic accelerator pack", url, ChecklistSubentryMake(title, modifiers, description), priority));
    }
}


RegisterResourceGenerationFunction("IOTMProtonicAcceleratorPackGenerateResource");
void IOTMProtonicAcceleratorPackGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($item[protonic accelerator pack].available_amount() == 0)
        return;
    
    if (!get_property_boolean("_streamsCrossed") &&__misc_state["in run"] && mafiaIsPastRevision(17085) && my_path_id() != PATH_G_LOVER)
    {
        string [int] description;
        string url = "showplayer.php?who=2807390"; //ProtonicBot is a real bot that will steal your turtle mechs at the first sign of defiance.
        description.listAppend("+20% stats for 10 turns.");
        if ($item[protonic accelerator pack].equipped_amount() == 0)
        {
            url = "inventory.php?ftext=protonic+accelerator+pack";
            description.listAppend("Equip the protonic accelerator pack first.");
        }
        resource_entries.listAppend(ChecklistEntryMake("__item protonic accelerator pack", url, ChecklistSubentryMake("Stream crossing", "", description), 8));
    }
}
