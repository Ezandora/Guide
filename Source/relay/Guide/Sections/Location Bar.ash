import "relay/Guide/Sections/Location Bar Popup.ash";
import "relay/Guide/Sets/Bad Moon.ash";

buffer generateLocationBar(boolean displaying_navbar)
{
    buffer bar;
    if (!playerIsLoggedIn())
        return bar;
    location l = __last_adventure_location;
    if (!__setting_location_bar_uses_last_location && !get_property_boolean("_relay_guide_setting_ignore_next_adventure_for_location_bar") && get_property_location("nextAdventure") != $location[none]) //setting exists for ascension scripts that alter my_location() to a null value/noob cave whenever they're not adventuring somewhere specific, to avoid environment-based effects on modifiers.
        l = get_property_location("nextAdventure");
    //l = my_location();
    
    if (l == $location[none] || __misc_state["In valhalla"])
        return "".to_buffer();
    
    
    string url = l.getClickableURLForLocation();
    
    
    float [monster] monster_appearance_rates = l.appearance_rates_adjusted();
    
    
    int nc_rate = MAX(0.0, monster_appearance_rates[$monster[none]]);
    
    float location_base_ml = l.monster_level_adjustment_for_location();
    float location_base_init_penalty = monsterExtraInitForML(location_base_ml);
    if (l.locationHasPlant("Impatiens") || l.locationHasPlant("Shuffle Truffle"))
        location_base_init_penalty -= 25.0;
    
    
    float average_ml = 0.0;
    float max_init = 0.0;
    float sample_count = 0.0;
    
    boolean [location] locations_where_monsters_always_matter = $locations[the haunted bedroom];
    
    foreach m in monster_appearance_rates
    {
        if (monster_appearance_rates[m] <= 0.0 && !(locations_where_monsters_always_matter contains l)) //one-time hack, sure?
            continue;
        if (m == $monster[none])
            continue;
        average_ml += m.raw_attack + location_base_ml;
        
        if (m.raw_attack == m.base_attack && location_base_ml > 0) //scaling monsters will have equivalent base_attack and raw_attack with ML already applied.
            average_ml -= location_base_ml; //this will be slightly incorrect with plants, due to how location ML works, but fixing it is very complicated
        
        max_init = MAX(max_init, m.raw_initiative + location_base_init_penalty);
        sample_count += 1.0;
    }
    if (sample_count > 0.0)
    {
        average_ml /= sample_count;
    }
    
    float chance_of_jump = 0.0;
    chance_of_jump = clampNormalf(((100.0 - max_init) + initiative_modifier_ignoring_plants()) / 100.0);
    
    string [int] plant_data;
    
    if (florist_available())
    {
        string [location, 3] florist_plants = get_florist_plants();
        
        if (florist_plants contains l)
        {
            string [3] area_plants = get_florist_plants()[l];
            
            foreach key in area_plants
            {
                string plant_name = area_plants[key];
                if (plant_name.length() == 0)
                    continue;
                string plant_description = plant_name.getPlantDescription();
                
                string class_name = "";
                //Half-saturation of their original colour, to fit in with the modifier look:
                if (plant_description == "spooky attack")
                    class_name = "r_element_spooky_desaturated";
                else if (plant_description == "hot attack")
                    class_name = "r_element_hot_desaturated";
                else if (plant_description == "sleaze attack")
                    class_name = "r_element_sleaze_desaturated";
                else if (plant_description == "stench attack")
                    class_name = "r_element_stench_desaturated";
                else if (plant_description == "cold attack")
                    class_name = "r_element_cold_desaturated";
                
                if (class_name != "")
                    plant_description = HTMLGenerateSpanOfClass(plant_description, class_name);
                
                if (plant_description != "")
                    plant_data.listAppend(plant_description);
                else
                    plant_data.listAppend("Unknown");
            }
        }
        if (plant_data.count() == 0 && l.environment != "unknown" && l.environment != "none" && l.environment != "")
        {
            if (l == $location[The Valley of Rof L'm Fao])
                plant_data.listAppend(l.environment.replace_string("o", "0"));
            else if (!($locations[The Prince's Restroom,The Prince's Dance Floor,The Prince's Kitchen,The Prince's Balcony,The Prince's Lounge,The Prince's Canapes table,the shore\, inc. travel agency] contains l))
                plant_data.listAppend(l.environment.capitaliseFirstLetter());
        }
    }
    
    
    /*int [location] pressure_penalties;
    pressure_penalties[$location[The Briny Deeps]] = 25;
    pressure_penalties[$location[The Brinier Deepers]] = 50;
    pressure_penalties[$location[The Briniest Deepests]] = 75;
    foreach loc in $locations[An Octopus's Garden,The Wreck of the Edgar Fitzsimmons,Madness Reef,The Mer-Kin Outpost,The Skate Park,The Coral Corral]
        pressure_penalties[loc] = 100;
    foreach loc in $locations[Mer-kin Colosseum,Mer-kin Library,Mer-kin Gymnasium,Mer-kin Elementary School]
        pressure_penalties[loc] = 150;
    foreach loc in $locations[The Marinara Trench,Anemone Mine,The Dive Bar,The Caliginous Abyss]
        pressure_penalties[loc] = 200;*/
    
    
    string custom_location_information;
    string custom_location_url;
    if (l == $location[domed city of ronaldus])
    {
        int ronald_phase = moon_phase() % 8;
        if (ronald_phase == 4)
            custom_location_information = "30% aliens";
        else if (ronald_phase < 2 || ronald_phase > 6)
            custom_location_information = "No aliens";
        else
            custom_location_information = "15% aliens";
    }
    else if (l == $location[domed city of grimacia])
    {
        int grimace_phase = moon_phase() / 2;
        if (grimace_phase == 4)
            custom_location_information = "30% aliens";
        else if (grimace_phase < 2 || grimace_phase > 6)
            custom_location_information = "No aliens";
        else
            custom_location_information = "15% aliens";
    }
    else if (l == $location[a-boo peak])
    {
        if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
        {
            custom_location_information = __quest_state["Level 9"].state_int["a-boo peak hauntedness"] + "% haunted";
        }
    }
    else if (l == $location[oil peak])
    {
        if (__quest_state["Level 9"].state_float["oil peak pressure"] > 0.0)
        {
            float pressure = __quest_state["Level 9"].state_float["oil peak pressure"];
            float pressure_remaining = pressure / 310.66;
            custom_location_information = round(clampNormalf(pressure_remaining) * 100.0) + "% pressure";
        }
    }
    else if (l == $location[Inside the Palindome])
    {
        if (!__quest_state["Level 11 Palindome"].state_boolean["dr. awkward's office unlocked"])
        {
            float likelyhood_of_dudes = 0.0;
            foreach m in monster_appearance_rates
            {
                if (monster_appearance_rates[m] <= 0.0)
                    continue;
                if (m == $monster[none])
                    continue;
                if (m == $monster[bob racecar] || m == $monster[racecar bob] || m == $monster[drab bard])
                    likelyhood_of_dudes += monster_appearance_rates[m];
            }
            custom_location_information = likelyhood_of_dudes.round() + "% dudes";
        }
    }
    /*else if (l == $location[twin peak]) //disabled, not very useful
    {
        string [int] entries;
        
        if (!__quest_state["Level 9"].state_boolean["Peak Stench Completed"])
            entries.listAppend(HTMLGenerateSpanOfClass("room 237", "r_element_stench_desaturated"));
        if (!__quest_state["Level 9"].state_boolean["Peak Item Completed"])
            entries.listAppend("pantry");
        if (!__quest_state["Level 9"].state_boolean["Peak Jar Completed"])
            entries.listAppend("music");
        if (!__quest_state["Level 9"].state_boolean["Peak Init Completed"])
            entries.listAppend("you");
        custom_location_information = entries.generateLocationBarModifierEntries();
    }*/
    else if (l == $location[the arid\, extra-dry desert])
    {
        if (__quest_state["Level 11 Desert"].state_int["Desert Exploration"] < 100)
        {
            custom_location_information = __quest_state["Level 11 Desert"].state_int["Desert Exploration"] + "% explored";
        }
    }
    else if (l == $location[barrrney's barrr])
    {
        if (!__quest_state["Pirate Quest"].finished)
        {
            custom_location_information = pluralise(__quest_state["Pirate Quest"].state_int["insult count"], "insult", "insults");
        }
    }
    else if ($locations[Dreadsylvanian Woods,Dreadsylvanian Village,Dreadsylvanian Castle,The Slime Tube,A Maze of Sewer Tunnels,Hobopolis Town Square,Burnbarrel Blvd.,Exposure Esplanade,The Heap,The Ancient Hobo Burial Ground,The Purple Light District] contains l)
    {
        custom_location_information = "Clan logs";
        custom_location_url = "clan_raidlogs.php";
    }
    else if (l == $location[the defiled alcove])
        custom_location_information = __quest_state["Level 7"].state_int["alcove evilness"] + " evilness";
    else if (l == $location[the defiled nook])
        custom_location_information = __quest_state["Level 7"].state_int["nook evilness"] + " evilness";
    else if (l == $location[the defiled cranny])
        custom_location_information = __quest_state["Level 7"].state_int["cranny evilness"] + " evilness";
    else if (l == $location[the defiled niche])
        custom_location_information = __quest_state["Level 7"].state_int["niche evilness"] + " evilness";
    else if (l == $location[the battlefield (hippy uniform)])
        custom_location_information = pluralise(__quest_state["Level 12"].state_int["frat boys left on battlefield"], "frat boy", "frat boys");
    else if (l == $location[the battlefield (frat uniform)])
        custom_location_information = pluralise(__quest_state["Level 12"].state_int["hippies left on battlefield"], "hippy", "hippies");
    else if ($locations[The Briny Deeps,The Brinier Deepers,The Briniest Deepests,An Octopus's Garden,The Wreck of the Edgar Fitzsimmons,Madness Reef,The Mer-Kin Outpost,The Skate Park,The Coral Corral,Mer-kin Colosseum,Mer-kin Library,Mer-kin Gymnasium,Mer-kin Elementary School,The Marinara Trench,Anemone Mine,The Dive Bar,The Caliginous Abyss] contains l)
    {
        Error error;
        float pressure_penalty = l.pressurePenaltyForLocation(error);
        custom_location_information = pressure_penalty.floor() + "% pressure";
        if (error.was_error)
            custom_location_information = "Unknown pressure";
        /*int pressure_penalty = MAX(0, -numeric_modifier("item drop penalty"));
        if (l == my_location())
            custom_location_information = pressure_penalty + "% pressure";
        else //numeric_modifier is location sensitive
            custom_location_information = "Unknown pressure";*/
    }
    else if ($locations[The Prince's Restroom,The Prince's Dance Floor,The Prince's Kitchen,The Prince's Balcony,The Prince's Lounge,The Prince's Canapes table] contains l)
    {
        int minutes_to_midnight = get_property_int("cinderellaMinutesToMidnight");
        if (minutes_to_midnight > 0)
            custom_location_information = pluralise(minutes_to_midnight, "minute", "minutes") + " left";
    }
    else if ($locations[Ye Olde Medievale Villagee,Portal to Terrible Parents,Rumpelstiltskin's Workshop] contains l)
    {
        int turns_left = clampi(30 - get_property_int("rumpelstiltskinTurnsUsed"), 0, 30);
        custom_location_information = pluralise(turns_left, "turn", "turns") + " left";
    }
    else if (l == $location[fernswarthy's basement])
    {
        custom_location_information = "Floor " + __misc_state_int["Basement Floor"];
    }
        
    //else if (pressure_penalties contains l)
        //custom_location_information = pressure_penalties[l] + "% pressure";
    
    string [int] monster_data;
    if (false)
    {
        boolean even_appearance_rates = true;
        float last_seen_rate = -10000.0;
        foreach m in monster_appearance_rates
        {
            if (m == $monster[none])
                continue;
            float rate = monster_appearance_rates[m];
            if (rate <= 0.0)
                continue;
            if (last_seen_rate == -10000.0)
                last_seen_rate = rate;
            else if (rate != last_seen_rate)
            {
                even_appearance_rates = false;
                break;
            }
                
        }
        foreach m in monster_appearance_rates
        {
            if (m == $monster[none])
                continue;
            float rate = monster_appearance_rates[m];
            if (rate <= 0.0)
                continue;
            if (even_appearance_rates)
                monster_data.listAppend(m.to_string());
            else
                monster_data.listAppend(m.to_string() + " (" + rate.round() + "%)");
        }
    }
    
    float mpa = -1.0;
    boolean should_output_meat_drop = false;
    if (false) //disabled for the moment, still thinking about this. is it really that useful...?
    {
        float base_mpa = 0.0;
        float total_appearance = 0.0;
        foreach m in monster_appearance_rates
        {
            if (m == $monster[none])
                continue;
            float rate = monster_appearance_rates[m];
            if (rate <= 0.0)
                continue;
            
            float average_meat = (m.min_meat + m.max_meat) * 0.5;
            
            total_appearance += rate;
            base_mpa += average_meat * rate;
        }
        if (total_appearance != 0.0)
        {
            base_mpa /= total_appearance;
            mpa = base_mpa * (1.0 + meat_drop_modifier() / 100.0);
        }
        if (numeric_modifier(my_familiar(), "meat drop", familiar_weight(my_familiar()), $slot[familiar].equipped_item()) > 0.0)
            should_output_meat_drop = true;
        if (l == $location[the themthar hills])
            should_output_meat_drop = true;
    }
    
    string [int] location_data;
    string [int] location_urls;
    float [int] location_fixed_widths;
    
    if (__misc_state["in run"])
    {
        int area_delay = l.delayRemainingInLocation();
        
        int turns_spent = l.turns_spent;
        if (area_delay > 0)
            location_data.listAppend(pluralise(area_delay, "turn", "turns") + "<br>delay");
        else if (turns_spent > 0)
            location_data.listAppend(pluralise(turns_spent, "turn", "turns"));
    }
    
    //easy list:
    //FIXME just use that test instead?
    //ashq foreach l in $locations[] if (l.appearance_rates().count() == 1 && l.appearance_rates()[$monster[none]] == 100.0) print(l);
    boolean [location] nc_blacklist = $locations[Pump Up Muscle,Pump Up Mysticality,Pump Up Moxie,The Shore\, Inc. Travel Agency,Goat Party,Pirate Party,Lemon Party,The Roulette Tables,The Poker Room,Anemone Mine (Mining),The Knob Shaft (Mining),Friar Ceremony Location,Itznotyerzitz Mine (in Disguise),The Prince's Restroom,The Prince's Dance Floor,The Prince's Kitchen,The Prince's Balcony,The Prince's Lounge,The Prince's Canapes table,Portal to Terrible Parents,fernswarthy's basement];
    
    if ((my_buffedstat($stat[moxie]) < average_ml || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE) && sample_count > 0 && __misc_state["in run"] && monster_level_adjustment() < 100)
    {
        //Init:
        //We only show this if the monsters out-moxie the player in-run. It feels as though it can easily be information overload otherwise.
        if (true)
        {
            if (chance_of_jump == 0 && false)
                location_data.listAppend("No jump");
            else
                location_data.listAppend((chance_of_jump * 100.0).round() + "% jump");
        }
        else if (true)
        {
            if (chance_of_jump <= 0.0)
                location_data.listAppend(max_init.round() + "% init<br>" + (chance_of_jump * 100.0).round() + "% jump");
            else
                location_data.listAppend((chance_of_jump * 100.0).round() + "% jump");
        }
        else if (false)
        {
            string line;
            if (chance_of_jump >= 1.0)
                line = "100% jump";
            else
                line = max_init.round() + "% init<br>" + (chance_of_jump * 100.0).round() + "% jump";
            location_data.listAppend(line);
        }
        else if (chance_of_jump < 1.0)
        {
            if (false)
                location_data.listAppend(max_init.round() + "% init<br>" + (chance_of_jump * 100.0).round() + "% jump");
            else
                location_data.listAppend((chance_of_jump * 100.0).round() + "% jump");
        }
    }
    if (nc_rate > 0.0 && !(nc_blacklist contains l))
        location_data.listAppend(nc_rate + "% NCs");
    if (custom_location_information != "")
    {
        location_data.listAppend(custom_location_information);
        if (custom_location_url != "")
            location_urls[location_data.count() - 1] = custom_location_url;
    }
    
    if (my_path_id() == PATH_HEAVY_RAINS)
    {
        boolean has_items_that_will_wash_away = false;
        
        foreach key, m in l.get_monsters()
        {
            foreach it, drop_rate in m.item_drops()
            {
                if (drop_rate == 0)
                    continue;
                if (drop_rate == 100)
                    continue;
                if (it.quest)
                    continue;
                has_items_that_will_wash_away = true;
                break;
            }
            if (has_items_that_will_wash_away)
                break;
        }
        
        if (has_items_that_will_wash_away)
        {
            //Calculate washaway chance:
            boolean unknown_washaway = false;
            int current_water_level = l.water_level_of_location();
            
            int washaway_chance = current_water_level * 5;
            if ($item[fishbone catcher's mitt].equipped_amount() > 0)
                washaway_chance -= 15; //GUESS
            
            if ($effect[Fishy Whiskers].have_effect() > 0)
            {
                //washaway_chance -= ?; //needs spading
                unknown_washaway = true;
            }
            if (unknown_washaway)
                location_data.listAppend("?% wash");
            else
                location_data.listAppend(washaway_chance + "% wash");
        }
    }
    if (mpa != -1.0 && should_output_meat_drop)
    {
        location_data.listAppend(mpa.round() + " MPA");
    }
    if (monster_data.count() > 0)
    {
        location_data.listAppend(pluralise(monster_data.count(), "monster", "monsters"));
    }
    if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
    {
        float average_coins_gained = 0.0;
        foreach m, rate in monster_appearance_rates
        {
            if (rate <= 0) continue;
            float coin_from_monster = m.ka_dropped();
            //NC should already be included in appearance rates?
            average_coins_gained += coin_from_monster * rate / 100.0;
        }
        if (average_coins_gained <= 0.0)
            location_data.listAppend("No ka");
        else
            location_data.listAppend(average_coins_gained.roundForOutput(1) + " ka");
    }
    
    boolean [location] powerleveling_locations = $locations[hamburglaris shield generator,video game level 1,video game level 2,video game level 3];
    
    if (sample_count > 0 && (__misc_state["in run"] || powerleveling_locations contains l || average_ml > my_buffedstat($stat[moxie])))
    {
        if (false)
            location_data.listAppend(average_ml.round() + " ML<br>" + (average_ml * __misc_state_float["ML to mainstat multiplier"]).round() + " " + my_primestat().to_lower_case() + "/fight");
        else
            location_data.listAppend(average_ml.round() + " ML");
    }
    
    if (in_bad_moon())
    {
        boolean bad_moon_adventure_possible_now = false;
        boolean bad_moon_adventure_possible = false;
        
        BadMoonAdventure [int] bad_moon_adventures = BadMoonAdventuresForLocation(l);
        
        if (bad_moon_adventures.count() > 0)
        {
            foreach key, adventure in bad_moon_adventures
            {
                boolean possible = !get_property_boolean("badMoonEncounter" + adventure.encounter_id);
                if (possible)
                    bad_moon_adventure_possible = possible;
                if (!bad_moon_adventure_possible_now)
                    bad_moon_adventure_possible_now = !adventure.has_additional_requirements_not_yet_met;
            }
        }
        
        if (bad_moon_adventure_possible)
        {
            string style = "margin-top:1px;";
            if (!bad_moon_adventure_possible_now)
                style += "opacity:0.25;";
            string image_html = HTMLGenerateTagPrefix("img", mapMake("src", __bad_moon_small_image_data, "style", style)); //"images/itemimages/badmoon.gif"
            location_data.listAppend(image_html);
            location_fixed_widths[location_data.count() - 1] = 0.15; //won't display otherwise
        }
    }
    
    if (plant_data.count() > 0)
    {
        string line;
        
        line = plant_data.generateLocationBarModifierEntries();
        
        
        if (__setting_location_bar_fixed_layout)
            line = HTMLGenerateDivOfClass(line, "r_location_bar_ellipsis_entry");
        location_data.listAppend(line);
        if (l == __last_adventure_location)
            location_urls[location_data.count() - 1] = "place.php?whichplace=forestvillage&amp;action=fv_friar";
    }
    if (true)
    {
        //Holding containers:
        string style;
        if (displaying_navbar)
            style += "bottom:" + __setting_navbar_height + ";";
        else
            style += "bottom:0px;";
        
        string onmouseenter_code;
        string onmouseleave_code;
        
        if (__setting_enable_location_popup_box)
        {
            onmouseenter_code = "if (document.getElementById('r_location_popup_box') != undefined) { document.getElementById('r_location_popup_box').style.display = 'inline'; document.getElementById('r_location_popup_blackout').style.display = 'inline'; }";
            onmouseleave_code = "document.getElementById('r_location_popup_box').style.display = 'none'; document.getElementById('r_location_popup_blackout').style.display = 'none';";
        }
            
        string [string] outer_containiner_map = mapMake("class", "r_bottom_outer_container", "style", style);
        bar.append(HTMLGenerateTagPrefix("div", outer_containiner_map));
        
        string [string] inner_containiner_map = mapMake("class", "r_bottom_inner_container", "style", "background:white;");
        if (onmouseenter_code != "")
            inner_containiner_map["onmouseenter"] = onmouseenter_code;
        if (onmouseleave_code != "")
            inner_containiner_map["onmouseleave"] = onmouseleave_code;
        bar.append(HTMLGenerateTagPrefix("div", inner_containiner_map));
    }
    
    
    
    
    
    string [int] table_entries;
    string [int] table_entry_urls;
    string [int] table_entry_styles;
    string [int] table_entry_classes;
    float [int] table_entry_width_weight;
    float [int] table_entry_fixed_width_percentage;
    if (true)
    {
        buffer style;
        if (location_data.count() > 0)
            style.append("text-align:left;");
        style.append("padding-left:" + __setting_indention_width + ";");
        //style.append("text-wrap:none;");
        //style.append("overflow:hidden;");
        //style.append("white-space:nowrap;");
        //style.append("text-overflow:clip;");

        string l_name = l.to_string();
        
        if (__setting_location_bar_fixed_layout)
            l_name = HTMLGenerateDivOfClass(l_name, "r_location_bar_ellipsis_entry");
        
        //table_entries.listAppend(HTMLGenerateTagWrap("div", l_name, mapMake("class", "r_bold", "style", style)));
        table_entries.listAppend(l_name);
        table_entry_classes[table_entries.count() - 1] = "r_bold";
        table_entry_styles[table_entries.count() - 1] = style;
        table_entry_width_weight[table_entries.count() - 1] = 1.05;
    }
    table_entries.listAppendList(location_data);
    foreach key in location_urls
    {
        table_entry_urls[key + 1] = location_urls[key];
    }
    foreach key in location_fixed_widths
    {
        table_entry_fixed_width_percentage[key + 1] = location_fixed_widths[key];
    }
    foreach key in location_data
    {
        table_entry_width_weight[key + 1] = 0.8;
    }
    
    
    
    bar.append(generateLocationBarTable(table_entries, table_entry_urls, table_entry_styles, table_entry_classes, table_entry_width_weight, table_entry_fixed_width_percentage, url));
    
    

    //bar.append("</div>");
    
    
    
    
    bar.append("</div>");
    bar.append("</div>");
    
    float bottom_coordinates = __setting_navbar_height_in_em;
    if (displaying_navbar)
        bottom_coordinates = __setting_navbar_height_in_em * 2.0;
    bar.append(generateLocationPopup(bottom_coordinates));
    return bar;
}
