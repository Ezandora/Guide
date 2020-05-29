
RegisterTaskGenerationFunction("PathBugbearInvasionGenerateTasks");
void PathBugbearInvasionGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_BUGBEAR_INVASION)
		return;
    if (!__misc_state["in run"])
        return;
    
    
    //task_entries.listAppend(ChecklistEntryMake("bugbear", "place.php?whichplace=bugbearship", ChecklistSubentryMake("Bugbears!", "", "I have no idea.")));
    
    /*
        Properties:
        statusEngineering
        statusGalley
        statusMedbay
        statusMorgue
        statusNavigation
        statusScienceLab
        statusSonar
        statusSpecialOps
        statusWasteProcessing
        mothershipProgress
        
        Possible values for status:
        [number] - Number of biodata collected.
        unlocked - area unlocked, but floor not open in mothership...?
        open - area unlocked, area available
        cleared - maybe?
        
        mothershipProgress: 0 at start
        1 when unlocked science lab, morgue, and special ops
        2 when unlocked engineering, navigation, galley
        3 when unlocked bridge
        
    */
    //Let's see... first you need a key-o-tron to access the mothership.
    //With that, you can collect biometric data for each area.
    //Then there's mothershipProgress for each zone and tasks for each zone.
    
    boolean defiled_nook_open = true;
    if (get_property_int("cyrptNookEvilness") == 0 && __quest_state["Level 7"].started)
        defiled_nook_open = false;
    
    location [int] location_evaluation_order;
    location_evaluation_order.listAppend($location[Medbay]);
    location_evaluation_order.listAppend($location[Waste Processing]);
    location_evaluation_order.listAppend($location[Sonar]);
    location_evaluation_order.listAppend($location[Science Lab]);
    location_evaluation_order.listAppend($location[Morgue]);
    location_evaluation_order.listAppend($location[Special Ops]);
    location_evaluation_order.listAppend($location[Engineering]);
    location_evaluation_order.listAppend($location[Navigation]);
    location_evaluation_order.listAppend($location[Galley]);
    
        
    string [location] property_names_for_areas;
    property_names_for_areas[$location[Engineering]] = "statusEngineering"; //does not seem to track battlesuit types fought
    property_names_for_areas[$location[Galley]] = "statusGalley";
    property_names_for_areas[$location[Medbay]] = "statusMedbay";
    property_names_for_areas[$location[Morgue]] = "statusMorgue";
    property_names_for_areas[$location[Navigation]] = "statusNavigation";
    property_names_for_areas[$location[Science Lab]] = "statusScienceLab";
    property_names_for_areas[$location[Sonar]] = "statusSonar";
    property_names_for_areas[$location[Special Ops]] = "statusSpecialOps";
    property_names_for_areas[$location[Waste Processing]] = "statusWasteProcessing";
    
    string [location] image_name_for_location;
    image_name_for_location[$location[Engineering]] = "__monster " + $monster[liquid metal bugbear];
    image_name_for_location[$location[Galley]] = "__monster " + $monster[trendy bugbear chef];
    image_name_for_location[$location[Medbay]] = "__monster " + $monster[anesthesiologist bugbear];
    image_name_for_location[$location[Morgue]] = "__monster " + $monster[bugbear mortician];
    image_name_for_location[$location[Navigation]] = "__monster " + $monster[N-space Virtual Assistant];
    image_name_for_location[$location[Science Lab]] = "__monster " + $monster[bugbear scientist];
    image_name_for_location[$location[Sonar]] = "__monster " + $monster[batbugbear];
    image_name_for_location[$location[Special Ops]] = "__monster " + $monster[Black Ops Bugbear];
    image_name_for_location[$location[Waste Processing]] = "__monster " + $monster[scavenger bugbear];
    
    
    string [location] printable_names_for_areas;
    printable_names_for_areas[$location[Engineering]] = "the engineering room";
    printable_names_for_areas[$location[Galley]] = "the galley";
    printable_names_for_areas[$location[Medbay]] = "the medbay";
    printable_names_for_areas[$location[Morgue]] = "the morgue";
    printable_names_for_areas[$location[Navigation]] = "the navigation room";
    printable_names_for_areas[$location[Science Lab]] = "the science lab";
    printable_names_for_areas[$location[Sonar]] = "the sonar room";
    printable_names_for_areas[$location[Special Ops]] = "the special ops room";
    printable_names_for_areas[$location[Waste Processing]] = "the waste processing room";
    
    int [location] minimum_mothership_progress_for_area;
    minimum_mothership_progress_for_area[$location[Engineering]] = 2;
    minimum_mothership_progress_for_area[$location[Galley]] = 2;
    minimum_mothership_progress_for_area[$location[Navigation]] = 2;
    minimum_mothership_progress_for_area[$location[Morgue]] = 1;
    minimum_mothership_progress_for_area[$location[Science Lab]] = 1;
    minimum_mothership_progress_for_area[$location[Special Ops]] = 1;
    minimum_mothership_progress_for_area[$location[Medbay]] = 0;
    minimum_mothership_progress_for_area[$location[Sonar]] = 0;
    minimum_mothership_progress_for_area[$location[Waste Processing]] = 0;
    
    if ($item[key-o-tron].available_amount() == 0)
    {
        if ($item[key-o-tron].creatable_amount() > 0)
        {
            task_entries.listAppend(ChecklistEntryMake("__item key-o-tron", "inv_use.php?pwd=" + my_hash() + "&whichitem=5683", ChecklistSubentryMake("Create key-o-tron", "", "Use 5 BURTs."), -11));
        }
        else
        {
            string url = "";
            int burts_needed = clampi(5 - $item[BURT].available_amount(), 0, 5);
            string [int] description;
            description.listAppend("To make a key-o-tron.");
            
            string [int] source_locations_available;
            string [int] source_locations_unavailable;
            //Possible areas:
            
            boolean [location] unavailable_locations_to_show = $locations[The Sleazy Back Alley,The Spooky Forest,cobb's knob Laboratory,The Defiled Nook,Lair of the Ninja Snowmen,The Penultimate Fantasy Airship,The Haunted Gallery,The Battlefield (Frat Uniform)];
            
            boolean [location] relevant_locations = $locations[The Sleazy Back Alley,The Spooky Forest,The Bat Hole Entrance,The Batrat and Ratbat Burrow,Guano Junction,The Beanbat Chamber,cobb's knob Laboratory,Lair of the Ninja Snowmen,The Penultimate Fantasy Airship,The Haunted Gallery,The Battlefield (Frat Uniform),The Orcish Frat House (Bombed Back to the Stone Age),The Hippy Camp (Bombed Back to the Stone Age)].makeConstantLocationArrayMutable();  //FIXME the battlefield (hippy uniform)?
            relevant_locations[$location[the very unquiet garves]] = true;
            
            if (defiled_nook_open)
                relevant_locations[$location[the defiled nook]] = true;
            else
                relevant_locations[$location[The VERY Unquiet Garves]] = true;
            
            //FIXME always URL in areas we have olfacted...?
            foreach l in relevant_locations
            {
                string place = l.to_string();
                
                if (!l.locationAvailable())
                {
                    if (unavailable_locations_to_show contains l)
                        source_locations_unavailable.listAppend(HTMLGenerateSpanFont(place, "grey"));
                }
                else
                {
                    source_locations_available.listAppend(place);
                    string place_url = l.getClickableURLForLocation();
                    if (place_url.length() != 0)
                        url = place_url;
                }
            }
            string line = "Places to collect them:|*" + source_locations_available.listJoinComponents("|*");
            if (source_locations_unavailable.count() > 0)
                line += "|*" + source_locations_unavailable.listJoinComponents("|*");
            description.listAppend(line);
            
            task_entries.listAppend(ChecklistEntryMake("__item key-o-tron", url, ChecklistSubentryMake("Collect " + int_to_wordy(burts_needed) + " more BURT" + ((burts_needed) > 1 ? "s" : ""), "", description)));
        }
    }
    else
    {
        //
        location [location][int] locations_relevant_to_acquire_biodata;
        int [location] biodata_amount_needed_for_area;
        
        
        biodata_amount_needed_for_area[$location[Engineering]] = 9;
        biodata_amount_needed_for_area[$location[Galley]] = 9;
        biodata_amount_needed_for_area[$location[Medbay]] = 3;
        biodata_amount_needed_for_area[$location[Morgue]] = 6;
        biodata_amount_needed_for_area[$location[Navigation]] = 9;
        biodata_amount_needed_for_area[$location[Science Lab]] = 6;
        biodata_amount_needed_for_area[$location[Sonar]] = 3;
        biodata_amount_needed_for_area[$location[Special Ops]] = 6;
        biodata_amount_needed_for_area[$location[Waste Processing]] = 3;
        
        monster [location] bugbears_to_hunt_for_location;
        
        bugbears_to_hunt_for_location[$location[Engineering]] = $monster[Battlesuit Bugbear Type];
        bugbears_to_hunt_for_location[$location[Galley]] = $monster[trendy bugbear chef];
        bugbears_to_hunt_for_location[$location[Medbay]] = $monster[hypodermic bugbear];
        bugbears_to_hunt_for_location[$location[Morgue]] = $monster[bugaboo];
        bugbears_to_hunt_for_location[$location[Navigation]] = $monster[ancient unspeakable bugbear];
        bugbears_to_hunt_for_location[$location[Science Lab]] = $monster[bugbear scientist];
        bugbears_to_hunt_for_location[$location[Sonar]] = $monster[batbugbear];
        bugbears_to_hunt_for_location[$location[Special Ops]] = $monster[Black Ops Bugbear];
        bugbears_to_hunt_for_location[$location[Waste Processing]] = $monster[scavenger bugbear];
        
        foreach l in property_names_for_areas
        {
            locations_relevant_to_acquire_biodata[l] = listMakeBlankLocation();
        }
        
        locations_relevant_to_acquire_biodata[$location[waste processing]].listAppend($location[the sleazy back alley]);
        locations_relevant_to_acquire_biodata[$location[Medbay]].listAppend($location[the Spooky Forest]);
        locations_relevant_to_acquire_biodata[$location[Sonar]].listAppend($location[The Bat Hole Entrance]);
        locations_relevant_to_acquire_biodata[$location[Sonar]].listAppend($location[The Batrat and Ratbat Burrow]);
        locations_relevant_to_acquire_biodata[$location[Sonar]].listAppend($location[Guano Junction]);
        locations_relevant_to_acquire_biodata[$location[Sonar]].listAppend($location[The Beanbat Chamber]);
        
        locations_relevant_to_acquire_biodata[$location[Science Lab]].listAppend($location[cobb's knob laboratory]);
        
        
        locations_relevant_to_acquire_biodata[$location[Special Ops]].listAppend($location[Lair of the Ninja Snowmen]);
        locations_relevant_to_acquire_biodata[$location[Engineering]].listAppend($location[The Penultimate Fantasy Airship]);
        locations_relevant_to_acquire_biodata[$location[Navigation]].listAppend($location[The Haunted Gallery]);
        
        if (!__quest_state["Level 12"].finished)
        {
            locations_relevant_to_acquire_biodata[$location[Galley]].listAppend($location[The Battlefield (Frat Uniform)]);
        }
        else
        {
            //FIXME determine which side won
            locations_relevant_to_acquire_biodata[$location[Galley]].listAppend($location[The Orcish Frat House (Bombed Back to the Stone Age)]);
            locations_relevant_to_acquire_biodata[$location[Galley]].listAppend($location[The Hippy Camp (Bombed Back to the Stone Age)]);
        }
        
        if (defiled_nook_open)
            locations_relevant_to_acquire_biodata[$location[Morgue]].listAppend($location[the defiled nook]);
        else
            locations_relevant_to_acquire_biodata[$location[Morgue]].listAppend($location[The VERY Unquiet Garves]);
        
        string url = "";
        boolean do_not_override_url = false;
        
        string [int] description;
        boolean [location] relevant_locations;
        foreach l, biodata_needed in biodata_amount_needed_for_area
        {
            string biodata_have_string = get_property(property_names_for_areas[l]);
            if (!biodata_have_string.is_integer())
                continue;
            int biodata_have = biodata_have_string.to_int_silent();
            if (biodata_have >= biodata_needed)
                continue;
            int biodata_remaining = MAX(0, biodata_needed - biodata_have);
            
            //FIXME check if we have an area open
            location [int] areas_we_can_adventure_in;
            foreach key, l2 in locations_relevant_to_acquire_biodata[l]
            {
                areas_we_can_adventure_in.listAppend(l2);
                relevant_locations[l2] = true;
                
                string this_url = l2.getClickableURLForLocation();
                if (this_url != "" && !do_not_override_url && l2.locationAvailable())
                    url = this_url;
                if ($effect[on the trail].have_effect() > 0 && get_property_monster("olfactedMonster") == bugbears_to_hunt_for_location[l])
                {
                    do_not_override_url = true;
                }
            }
            if (areas_we_can_adventure_in.count() > 0 && l.turns_spent == 0)
            {
                
                boolean tracking_works = true;
                if ($locations[the Penultimate Fantasy Airship,Lair of the Ninja Snowmen] contains l && biodata_remaining == biodata_needed)
                    tracking_works = false;
                boolean at_least_one_area_open = false;
                foreach key, l in areas_we_can_adventure_in
                {
                    if (l.locationAvailable())
                        at_least_one_area_open = true;
                }
                string line;
                line += "Fight " + int_to_wordy(biodata_remaining);
                
                if (!tracking_works)
                    line += " total ";
                else
                    line += " more ";
                line += bugbears_to_hunt_for_location[l] + " in";
                
                if (areas_we_can_adventure_in.count() == 1)
                {
                    line += " " + areas_we_can_adventure_in.listJoinComponents("") + ".";
                    line += "|Unlocks " + l + ".";
                }
                else
                {
                    line += ": |*" + areas_we_can_adventure_in.listJoinComponents("|*");
                    line += "|*<hr>Unlocks " + l + ".";
                }
                if (!tracking_works)
                    line += "|Umm... unless you already did that. (no tracking)";
                if (!at_least_one_area_open)
                    line = HTMLGenerateSpanFont(line, "grey");
                description.listAppend(line);
            }
        }
        if (description.count() > 0)
        {
            if ($item[crayon shavings].available_amount() > 0)
                description.listPrepend($item[crayon shavings].available_amount().int_to_wordy().capitaliseFirstLetter() + " crayon shavings available for copying bugbears.");
            if ($item[bugbear detector].available_amount() > 0 && $item[bugbear detector].equipped_amount() == 0)
                description.listPrepend(HTMLGenerateSpanFont("Equip bugbear detector first.", "red"));
            task_entries.listAppend(ChecklistEntryMake("__item software glitch", url, ChecklistSubentryMake("Collect biodata", "", description), relevant_locations));
        }
    }
    int mothership_progress = get_property_int("mothershipProgress");
    
    if (true)
    {
        ChecklistEntry entry;
        entry.url = "place.php?whichplace=bugbearship";
        entry.image_lookup_name = "bugbear";
        foreach key, l in location_evaluation_order
        {
            string property_name = property_names_for_areas[l];
            if (get_property(property_name) != "open" && !(get_property(property_name).is_integer() && l.turns_spent > 0))
                continue;
                
            if (mothership_progress < minimum_mothership_progress_for_area[l])
                continue;
            if (entry.image_lookup_name == "bugbear" && image_name_for_location[l] != "")
                entry.image_lookup_name = image_name_for_location[l];
                
            string [int] modifiers;
            string [int] description;
            if (l == $location[medbay])
            {
                modifiers.listAppend("olfact anesthesiologist bugbear");
                description.listAppend("Fight anesthesiologist bugbears to summon and defeat the robo-surgeon.");
                description.listAppend("Banishes won't help...?");
            }
            else if (l == $location[sonar])
            {
                modifiers.listAppend("-combat");
                description.listAppend("Run -combat, look for the machine.");
                description.listAppend("Set Pinging machine to 2.");
                description.listAppend("Set Whurming machine to 4.");
                description.listAppend("Set Boomchucking machine to 8.");
            }
            else if (l == $location[waste processing])
            {
                if ($item[bugbear communicator badge].available_amount() > 0)
                {
                    if ($item[bugbear communicator badge].equipped_amount() == 0)
                    {
                        description.listAppend("Equip the bugbear communicator badge.");
                    }
                    else
                    {
                        description.listAppend("Adventure once to finish the area.");
                    }
                }
                else
                {
                    modifiers.listAppend("olfact creepy eye-stalk tentacle monster");
                    modifiers.listAppend("+item");
                    description.listAppend("Acquire and use handfuls of juicy garbage.");
                    if ($item[handful of juicy garbage].available_amount() > 0)
                    {
                        task_entries.listAppend(ChecklistEntryMake("__item handful of juicy garbage", "inventory.php?which=3&ftext=handful+of+juicy+garbage", ChecklistSubentryMake("Use handful of juicy garbage", "", "Might find a bugbear communicator badge."), -11));
                    }
                }
            }
            else if (l == $location[science lab])
            {
                //FIXME want tracking for scientists trapped
                modifiers.listAppend("+item");
                description.listAppend("Collect quantum nanopolymer spider webs from spiderbugbears, use them on the poor innocent scientists.");
                if ($item[quantum nanopolymer spider web].available_amount() > 0)
                    description.listAppend(pluraliseWordy($item[quantum nanopolymer spider web]).capitaliseFirstLetter() + " available.");
            }
            else if (l == $location[morgue])
            {
                //FIXME want tracking of parts
                if ($item[bugbear autopsy tweezers].available_amount() > 0)
                    modifiers.listAppend("-combat");
                if ($item[bugbear autopsy tweezers].available_amount() < 5)
                {
                    if (!$monster[bugaboo].is_banished())
                        modifiers.listAppend("banish bugaboos OR olfact bugbear morticians");
                    description.listAppend("Collect bugbear autopsy tweezers from bugbear morticians.");
                }
                
                if ($item[bugbear autopsy tweezers].available_amount() > 0)
                    description.listAppend("Run -combat to use the tweezers on the choice adventure.");
            }
            else if (l == $location[special ops])
            {
                boolean [item] relevant_equipment = $items[fire,uv monocular,rain-doh green lantern,fluorescent lightbulb];
                item [int] items_to_equip;
                foreach it in relevant_equipment
                {
                    if (it.available_amount() > 0 && it.equipped_amount() == 0)
                        items_to_equip.listAppend(it);
                }
                if (items_to_equip.count() > 0)
                    description.listAppend(HTMLGenerateSpanFont("Equip your " + items_to_equip.listJoinComponents(", ", "and") + ".", "red"));
                if ($item[uv monocular].available_amount() == 0 && $item[uv monocular].creatable_amount() > 0)
                    description.listAppend("Could create the UV Monocular with your BURTs.");
                
                description.listAppend("Search in darkness.");
                
                if ($item[flaregun].available_amount() > 0)
                    description.listAppend("Shoot a flare in the choice adventure if you haven't.");
            }
            else if (l == $location[Engineering])
            {
                //FIXME want tracking on liquid metal bugbears
                modifiers.listAppend("+item");
                if (!$monster[Battlesuit Bugbear Type].is_banished())
                {
                    modifiers.listAppend("banish " + $monster[Battlesuit Bugbear Type]);
                }
                description.listAppend("Collect drone self-destruct chips from drones, use them on liquid metal bugbears.");
                if ($item[drone self-destruct chip].available_amount() > 0)
                    description.listAppend(pluraliseWordy($item[drone self-destruct chip]).capitaliseFirstLetter() + " available.");
            }
            else if (l == $location[Navigation])
            {
                if ($effect[N-Spatial vision].have_effect() > 0)
                {
                    string method_to_remove = "";
                    //FIXME write this
                    if ($skill[disco nap].skill_is_usable() && $skill[adventurer of leisure].skill_is_usable())
                        method_to_remove = "disco nap.";
                    else if ($item[bugbear purification pill].available_amount() > 0)
                        method_to_remove = "bugbear purification pill.";
                    else if ($item[bugbear purification pill].creatable_amount() > 0)
                        method_to_remove = "bugbear purification pill. (make from BURTs)";
                    else if ($item[soft green echo eyedrop antidote].available_amount() > 0)
                        method_to_remove = "soft green echo eyedrop antidote. (probably not worth it)";
                    
                    if (method_to_remove != "")
                        description.listAppend("Remove N-Spatial vision with " + method_to_remove);
                    else
                        description.listAppend("Avoid adventuring here until N-Spatial vision is gone.");
                }
                else
                {
                    if (!$monster[ancient unspeakable bugbear].is_banished())
                    {
                        modifiers.listAppend("banish ancient unspeakable bugbears OR olfact n-space virtual assistants"); //zero space. Zee-roh spaa ce. Spac-uh.
                    }
                    description.listAppend("Defeat ~ten total N-space assistants.");
                }
            }
            else if (l == $location[Galley])
            {
                //FIXME tracking ML defeated, cavebugbear attack
                modifiers.listAppend("+ML");
                if (!$monster[trendy bugbear chef].is_banished())
                {
                    modifiers.listAppend("banish trendy bugbear chefs OR olfact angry cavebugbears");
                }
                description.listAppend("Defeat 5k ML worth of angry cavebugbears.");
                if ($item[pacification grenade].creatable_amount() + $item[pacification grenade].available_amount() > 0)
                    description.listAppend("Can " + ($item[pacification grenade].available_amount() == 0 ? "make and " : "") + "throw a pacification grenade if they become too difficult.");
            }
            
            entry.subentries.listAppend(ChecklistSubentryMake("Clear " + printable_names_for_areas[l], modifiers, description));
            if ($locations[Medbay,Waste Processing,Sonar,Science Lab,Morgue,Special Ops,Engineering,Navigation,Galley] contains __last_adventure_location)
                entry.should_highlight = true;
        }
        if (entry.subentries.count() > 0)
            task_entries.listAppend(entry);
    }
    
    if (mothership_progress >= 3)
    {
        //
        boolean other_quests_completed = true;
        for i from 2 to 12
        {
            if (!__quest_state["Level " + i].finished)
                other_quests_completed = false;
        }
        if (other_quests_completed && my_level() >= 13)
        {
            if ($item[jeff goldblum larva].available_amount() == 0)
            {
                //hacky:
                task_entries.listAppend(ChecklistEntryMake("council", "place.php?whichplace=town", ChecklistSubentryMake("Visit the Council of Loathing", "", "Obtain Jeff Goldblum larva.")));
            }
            else
            {
                //no tracking for bridge captain defeated?
                task_entries.listAppend(ChecklistEntryMake("bugbear", "place.php?whichplace=bugbearship", ChecklistSubentryMake("Fight the Bugbear Captain", "", listMake("On the bridge.", "Then free the king. Maybe."))));
            }
        }
    }
}

RegisterResourceGenerationFunction("PathBugbearInvasionGenerateResource");
void PathBugbearInvasionGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id() != PATH_BUGBEAR_INVASION)
		return;
    if (!__misc_state["in run"])
        return;
    if ($item[crayon shavings].available_amount() > 0)
    {
		resource_entries.listAppend(ChecklistEntryMake("__item crayon shavings", "", ChecklistSubentryMake(pluralise($item[crayon shavings].available_amount(), "crayon shaving copy", "crayon shaving copies") + " available", "", "Bugbears only.")));
    }
    if ($item[BURT].available_amount() > 0)
    {
        string [int] description;
        
        string [item] item_reason;
        item_reason[$item[pacification grenade]] = "trades speed for survivability in the galley";
        item_reason[$item[key-o-tron]] = "collects biodata";
        item_reason[$item[bugbear detector]] = "find the elusive creature";
        item_reason[$item[uv monocular]] = "useful in special ops";
        item_reason[$item[bugbear purification pill]] = "removes a negative effect";
        if (get_property("statusNavigation") != "cleared" && !($skill[disco nap].skill_is_usable() && $skill[adventurer of leisure].skill_is_usable()))
            item_reason[$item[bugbear purification pill]] += " (useful in Navigation)";
        item [int] relevant_items;
        relevant_items.listAppend($item[bugbear purification pill]);
        if (get_property("statusGalley") != "cleared")
            relevant_items.listAppend($item[pacification grenade]);
        relevant_items.listAppend($item[key-o-tron]);
        relevant_items.listAppend($item[bugbear detector]);
        if (get_property("statusSpecialOps") != "cleared")
            relevant_items.listAppend($item[uv monocular]);
        
        int [item] amount_wanted;
        amount_wanted[$item[pacification grenade]] = -1;
        
        foreach key, it in relevant_items
        {
            if (it.available_amount() > 0 && amount_wanted[it] != -1)
                continue;
            string line = it + " - ";
            line += item_reason[it] + ".";
            
            if (it.creatable_amount() == 0)
                line = HTMLGenerateSpanFont(line, "grey");
            description.listAppend(line);
        }
		resource_entries.listAppend(ChecklistEntryMake("__item BURT", "inv_use.php?pwd=" + my_hash() + "&whichitem=5683", ChecklistSubentryMake(pluralise($item[BURT]) + " available", "", description), 8));
    }
}
