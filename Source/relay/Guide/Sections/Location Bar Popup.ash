import "relay/Guide/Support/Banishers.ash";

static
{
    boolean [item] __items_that_craft_food;
    
    void initialiseItemsThatCraftFood()
    {
        foreach crafted_item in $items[]
        {
            string craft_type = crafted_item.craft_type();
            if (!craft_type.contains_text("Cooking"))
                continue;
            foreach it in crafted_item.get_ingredients()
            {
                __items_that_craft_food[it] = true;
            }
        }
    }
    initialiseItemsThatCraftFood();
}

string generateLocationBarModifierEntries(string [int] entries_in)
{
    if (entries_in.count() == 1)
        return entries_in.listJoinComponents(", ");
    
    //Returns entries using a minimum-width algorithm designed to use two lines.
    
    string [int] entries = entries_in;
    if (!entries.listKeysMeetStrictRequirements()) //insure we can test [key + 1] and such
        entries = entries.listCopyStrictRequirements();
    
    int [int] entries_length;
    foreach key in entries
    {
        entries_length[key] = entries[key].HTMLStripTags().length();
    }
    
    int calculating_sum = 0;
    
    int smallest_length = 0;
    int smallest_length_index = -1;
    foreach key in entries
    {
        if (key == entries.count() - 1)
            continue;
        
        calculating_sum += entries_length[key];
        //If we split at the end of this entry, what will be our length?
        int line_1_length = calculating_sum;
        int line_2_length = 0;
        foreach key2 in entries
        {
            if (key2 <= key)
                continue;
            line_2_length += entries_length[key2];
        }
        int line_length = MAX(line_1_length, line_2_length);
        
        if (smallest_length_index == -1)
        {
            smallest_length = line_length;
            smallest_length_index = key;
        }
        else
        {
            if (smallest_length >= line_length)
            {
                smallest_length_index = key;
                smallest_length = line_length;
            }
        }
    }
    //Split after smallest_length:
    buffer result;
    foreach key in entries
    {
        result.append(entries[key]);
        boolean should_br = false;
        if (key == smallest_length_index)
            should_br = true;
        if (key != entries.count() - 1)
        {
            if (should_br)
                result.append(",");
            else
                result.append(", ");
        }
        if (should_br)
            result.append("<br>");
        
    }
    return result;
}


buffer generateLocationBarTable(string [int] table_entries, string [int] table_entry_urls, string [int] table_entry_styles, string [int] table_entry_classes, float [int] table_entry_width_weight, float [int] table_entry_fixed_width_percentage, string base_url)
{
    buffer bar;


    int [int] table_entry_widths;
    if (__setting_location_bar_fixed_layout)
    {
        float reserved_percentage = 0.0;
        foreach key, v in table_entry_fixed_width_percentage
            reserved_percentage += v;
        reserved_percentage = clampf(reserved_percentage, 0.0, 1.0);
    
    
        int [int] table_entry_character_length;
        foreach key in table_entries
        {
            if (table_entry_fixed_width_percentage contains key)
                continue;
            //Complicated:
            string entry = table_entries[key];
            string [int] lines = entry.split_string("<br>");
            int max_length = 0;
            foreach key2 in lines
            {
                //Remove HTML:
                string l = HTMLStripTags(lines[key2]);
                max_length = MAX(max_length, l.length());
            }
            if (table_entry_width_weight contains key)
                max_length = round(max_length.to_float() * table_entry_width_weight[key]);
            table_entry_character_length[key] = max_length;
        }
        int total_character_count = listSum(table_entry_character_length);
        int [int] proportional_character_lengths;
        foreach key in table_entry_character_length
        {
            if (table_entry_fixed_width_percentage contains key)
                continue;
            int v = table_entry_character_length[key];
            if (total_character_count != 0 && __setting_location_bar_limit_max_width)
            {
                if (v.to_float() / total_character_count.to_float() >= __setting_location_bar_max_width_per_entry)
                {
                    v = floor(total_character_count.to_float() * __setting_location_bar_max_width_per_entry);
                }
            }
            proportional_character_lengths[key] = v;
        }
        
        float remaining_percentage = 100.0 * (1.0 - reserved_percentage);
        
        int proportional_total = listSum(proportional_character_lengths);
        foreach key in table_entry_fixed_width_percentage
        {
            table_entry_widths[key] = clampf(table_entry_fixed_width_percentage[key], 0.0, 1.0) * 100.0;
        }
        foreach key in proportional_character_lengths
        {
            if (table_entry_fixed_width_percentage contains key)
                continue;
            int v = proportional_character_lengths[key];
            int width = 25;
            if (proportional_character_lengths.count() > 0)
                width = floor(remaining_percentage / proportional_character_lengths.count().to_float()); //backup
            if (proportional_total != 0)
            {
                width = v.to_float() / proportional_total.to_float() * remaining_percentage;
            }
            table_entry_widths[key] = width;
        }
    }
    
    if (table_entry_widths.listSum() > 100)
    {
        //Safety backup. Renormalize:
        int current_sum = table_entry_widths.listSum();
        foreach key in table_entry_widths
        {
            if (current_sum != 0) //not strictly necessary, will always be true (as the code currently is)
                table_entry_widths[key] = floor(table_entry_widths[key].to_float() / current_sum.to_float() * 100.0);
        }
    }
    
    
    if (true)
    {
        buffer table_style;
        table_style.append("display:table;width:100%;height:100%;text-align:center;");
        if (__setting_location_bar_fixed_layout)
            table_style.append("table-layout:fixed;");
        bar.append(HTMLGenerateTagPrefix("div", mapMake("style", table_style))); //
    }
    
    foreach key in table_entries
    {
        string s = table_entries[key];
        string entry_url = base_url;
        if (table_entry_urls contains key)
            entry_url = table_entry_urls[key];
        
        string [string] map;
        
        if (entry_url.length() > 0)
            map = generateMainLinkMap(entry_url);
        map["class"] += " r_location_bar_table_entry";
        if (table_entry_classes contains key)
            map["class"] += " " + table_entry_classes[key];
        if (table_entry_styles contains key)
            map["style"] += table_entry_styles[key];
        
        if (table_entry_widths contains key)
            map["style"] += "width:" + table_entry_widths[key] + "%;";
        
        if (entry_url.length() != 0)
            bar.append(HTMLGenerateTagPrefix("a", map));
        else
            bar.append(HTMLGenerateTagPrefix("div", map));
        
        if (table_entry_classes contains key)
            bar.append(s);
        else
            bar.append(HTMLGenerateTagWrap("div", s, mapMake("class", "r_cl_modifier_inline"))); //r_cl_modifier_inline needs its own div due to CSS class order precedence
        if (entry_url.length() != 0)
        {
            bar.append("</a>");
        }
        else
            bar.append("</div>");
    }
    
    
    bar.append(HTMLGenerateTagSuffix("div"));
    
    
    
    return bar;
}



buffer generateLocationPopup(float bottom_coordinates)
{
    buffer buf;
    location l = __last_adventure_location;
    if (!__setting_location_bar_uses_last_location)
        l = my_location();
    if (!__setting_enable_location_popup_box)
        return buf;
    
    buf.append(HTMLGenerateTagWrap("div", "", mapMake("id", "r_location_popup_blackout", "style", "position:fixed;z-index:4;width:100%;height:100%;background:rgba(0,0,0,0.5);display:none;")));
    
    
    buf.append(HTMLGenerateTagPrefix("div", mapMake("id", "r_location_popup_box", "style", "bottom:" + bottom_coordinates + "em;display:none;height:auto;" /*+ "border-top:3px solid;border-color:" + __setting_line_color + ";"*/, "class", "r_bottom_outer_container")));
    buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_bottom_inner_container", "style", "background:white;height:auto;")));
    
    float [monster] appearance_rates_adjusted = l.appearance_rates_adjusted();
    float [monster] appearance_rates_next_turn = l.appearance_rates(true);
    //should we take into account the combat queue, etc?
    
    //buf.append("appearance_rates_next_turn = " + appearance_rates_next_turn.to_json() + "<br>");
    
    string [monster] monsters_that_we_cannot_encounter;
    if (lookupEffect("Ancient Annoying Serpent Poison").have_effect() == 0)
    {
        foreach m in $monsters[the frattlesnake,Batsnake,Frozen Solid Snake,Burning Snake of Fire,The Snake With Like Ten Heads,Snakeleton]
        {
            monsters_that_we_cannot_encounter[m] = "not on copperhead quest";
        }
    }
    if (l == $location[the boss bat's lair])
    {
        if (l.delayRemainingInLocation() > 0)
        {
            monsters_that_we_cannot_encounter[$monster[boss bat]] = "on delay";
        }
    }
    else if (l == $location[the defiled niche])
    {
        int evilness = __quest_state["Level 7"].state_int["niche evilness"];
        if (evilness > 25)
        {
            monsters_that_we_cannot_encounter[$monster[gargantulihc]] = "evilness too high";
        }
        else if (evilness > 0)
        {
            monsters_that_we_cannot_encounter[$monster[senile lihc]] = "boss up";
            monsters_that_we_cannot_encounter[$monster[slick lihc]] = "boss up";
            monsters_that_we_cannot_encounter[$monster[dirty old lihc]] = "boss up";
        }
    }
    else if (l == $location[the defiled cranny])
    {
        int evilness = __quest_state["Level 7"].state_int["cranny evilness"];
        if (evilness > 25)
        {
            monsters_that_we_cannot_encounter[$monster[huge ghuol]] = "evilness too high";
        }
        else if (evilness > 0)
        {
            foreach m in $monsters[gluttonous ghuol,gaunt ghuol,swarm of ghuol whelps,big swarm of ghuol whelps,giant swarm of ghuol whelps]
                monsters_that_we_cannot_encounter[m] = "boss up";
        }
    }
    else if (l == $location[the defiled nook])
    {
        int evilness = __quest_state["Level 7"].state_int["nook evilness"];
        if (evilness > 25)
        {
            monsters_that_we_cannot_encounter[$monster[giant skeelton]] = "evilness too high";
        }
        else if (evilness > 0)
        {
            foreach m in $monsters[spiny skelelton,toothy sklelton]
                monsters_that_we_cannot_encounter[m] = "boss up";
        }
    }
    else if (l == $location[oil peak])
    {
        int oil_ml = $location[oil peak].monster_level_adjustment_for_location();
        monster correct_monster = $monster[oil slick];
        if (oil_ml < 20)
            correct_monster = $monster[oil slick];
        else if (oil_ml < 50)
            correct_monster = $monster[oil tycoon];
        else if (oil_ml < 100)
            correct_monster = $monster[oil baron];
        else if (oil_ml >= 100)
            correct_monster = $monster[oil cartel];
        foreach m in $monsters[oil slick,oil tycoon,oil baron,oil cartel]
        {
            if (m != correct_monster)
                monsters_that_we_cannot_encounter[m] = "ML";
        }
    }
    //FIXME other defileds
    
    boolean banishes_are_possible = true;
    if ($locations[the secret government laboratory,sloppy seconds diner] contains l)
        banishes_are_possible = false;
    
    foreach m in appearance_rates_next_turn
    {
        if (monsters_that_we_cannot_encounter contains m)// || m.is_banished())
            remove appearance_rates_next_turn[m];
    }
    //l.appearance_rates(true) doesn't seem to take into account banished monsters, so correct:
    appearance_rates_next_turn[$monster[none]] = 0.0; //ignore
    float arnt_sum = 0.0;
    foreach m, rate in appearance_rates_next_turn
    {
        if (m.is_banished() && banishes_are_possible)
            appearance_rates_next_turn[m] = MIN(appearance_rates_next_turn[m], 0.0);
        else if (rate > 0.0)
            arnt_sum += appearance_rates_next_turn[m];
    }
    if (arnt_sum != 100.0 && arnt_sum != 0.0)
    {
        float inverse = 1.0 / (arnt_sum / 100.0);
        
        foreach m, rate in appearance_rates_next_turn
        {
            if (rate > 0.0)
                appearance_rates_next_turn[m] *= inverse;
        }
    }
    //buf.append("appearance_rates_next_turn = " + appearance_rates_next_turn.to_json());
    
    monster [int] monster_display_order;
    boolean rates_are_equal = true;
    boolean next_rates_are_equal = true;
    float last_rate = -1.0;
    float last_next_rate = -1.0;
    foreach m in appearance_rates_adjusted
    {
        if (m == $monster[none])
            continue;
        monster_display_order.listAppend(m);
        float rate = appearance_rates_adjusted[m];
        float next_rate = appearance_rates_next_turn[m];
        if (rate > 0.0 && m != $monster[none])
        {
            if (last_rate == -1.0)
                last_rate = rate;
            else if (fabs(last_rate - rate) > 0.01)
            {
                rates_are_equal = false;
            }
        }
        
        if (next_rate > 0.0 && m != $monster[none])
        {
            if (last_next_rate == -1.0)
                last_next_rate = next_rate;
            else if (fabs(last_next_rate - next_rate) > 0.01)
            {
                next_rates_are_equal = false;
            }
        }
    }
    
    boolean [monster] possible_alien_monsters;
    if (!(appearance_rates_adjusted contains last_monster())) //wandering monsters, etc
    {
        possible_alien_monsters[last_monster()] = true;
        monster_display_order.listAppend(last_monster());
    }
    
    int minimal_cutoff_monster_count = 10;
    boolean try_for_minimal_display = false;
    if (monster_display_order.count() > minimal_cutoff_monster_count)
        try_for_minimal_display = true;
    
    if (next_rates_are_equal)
    {
        //equality
        sort monster_display_order by -appearance_rates_next_turn[value];
        sort monster_display_order by -appearance_rates_adjusted[value] - (possible_alien_monsters[value] ? -100.0 : 0);
    }
    else
    {
        sort monster_display_order by -appearance_rates_adjusted[value] - (possible_alien_monsters[value] ? -100.0 : 0);
        sort monster_display_order by -appearance_rates_next_turn[value] - (possible_alien_monsters[value] ? -100.0 : 0);
    }
    /*if (try_for_minimal_display)
        sort monster_display_order by appearance_rates_next_turn[value];
    else
        sort monster_display_order by -appearance_rates_next_turn[value];*/
    int monsters_displayed = 0;
    
    boolean can_display_as_2x = true;
    
    if (false) //trying with it off - it feels better to use layout more effectively, rather than try to line up everything. example area: domed city of grimacia
    {
        foreach key, m in monster_display_order
        {
            int item_count_displaying = m.item_drops_array().count();
            if (item_count_displaying <= 1)
            {
            }
            else if (item_count_displaying == 2 || (item_count_displaying % 2 == 0 && item_count_displaying % 3 != 0))
            {
            }
            else
                can_display_as_2x = false;
        }
    }
    
    float rate_nc_cancel_multiplier = 1.0;
    if (appearance_rates_adjusted[$monster[none]] > 0.0)
    {
        float divisor = (1.0 - appearance_rates_adjusted[$monster[none]] / 100.0);
        if (divisor != 0.0)
            rate_nc_cancel_multiplier = 1.0 / divisor;
    }
    
    boolean [monster] monsters_to_display_items_minimally;
    int item_minimal_display_limit = 6;
    foreach key, m in monster_display_order
    {
        //pooltergeist has lots of items, but they're very short named
        int total_string_length = 0;
        foreach key, r in m.item_drops_array()
        {
            total_string_length += r.drop.to_string().length();
        }
        if (m.item_drops_array().count() > item_minimal_display_limit && total_string_length >= 100)
            monsters_to_display_items_minimally[m] = true;
    }
    
    
    foreach key, m in monster_display_order
    {
        string [int] fl_entries;
        string [int] fl_entry_urls;
        string [int] fl_entry_styles;
        string [int] fl_entry_classes;
        float [int] fl_entry_width_weight;
        float [int] fl_entry_fixed_width_percentage;
        
        string monster_image_url = "images/adventureimages/" + m.image;
        if (m.image.length() == 0)
            monster_image_url = "";
        ServerImageStats monster_image_stats = ServerImageStatsOfImageURL(monster_image_url);
        float rate = appearance_rates_adjusted[m] * rate_nc_cancel_multiplier;
        float next_rate = appearance_rates_next_turn[m]; //already normalised for monsters
        monsters_displayed += 1;
        if (monsters_displayed > 1)
            buf.append(HTMLGenerateTagPrefix("hr", mapMake("style", "margin:0px;")));
        //buf.append(HTMLGenerateTagPrefix("span", mapMake("style", "width:100%;display:inline-block;")));
        
        //Layer hack - we want a white blurred background for text, to put over the monster image, but text-shadow is limited
        //So, layer a bunch of individual text shadows. WARNING: performance will be bad?
        //Text shadow disabled, doesn't look too good
        /*string text_shadow_base_string = "0px 0px 1em rgba(255,255,255,1.0)";
        string [int] layered_shadows;
        for i from 0 to 32
            layered_shadows.listAppend(text_shadow_base_string);*/
        
        //buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "width:100%;display:table;padding:0.25em;z-index:7;position:relative;text-shadow:" + layered_shadows.listJoinComponents(", ") + ";"))); //text-shadow:0px 0px 11px #FFFFFF; -webkit-text-fill-color:#000000;-webkit-text-stroke-width:1em;-webkit-text-stroke-color:#007FFF;
        boolean avoid_outputting_conditional = false;
        boolean monster_cannot_be_encountered = false;
        string reason_monster_cannot_be_encountered = "";
        if (m.is_banished() && banishes_are_possible)
        {
            monster_cannot_be_encountered = m.is_banished();
            reason_monster_cannot_be_encountered = "banished";
        }
        else if (monsters_that_we_cannot_encounter contains m)
        {
            monster_cannot_be_encountered = true;
            reason_monster_cannot_be_encountered = monsters_that_we_cannot_encounter[m];
        }
        else if (appearance_rates_adjusted[$monster[none]] >= 100.0)
        {
            monster_cannot_be_encountered = true;
            reason_monster_cannot_be_encountered = "no combats";
            avoid_outputting_conditional = true;
        }
        if (true)
        {
            //string style = "width:100%;display:table;padding:0.25em;z-index:7;position:relative;overflow:hidden;";
            string style = "width:100%;padding-bottom:0.1em;z-index:7;position:relative;overflow:hidden;";
            if (try_for_minimal_display)
                style += "padding-top:0.1em;";
            if (monster_cannot_be_encountered)
                style += "color:grey;";
            if (monster_image_stats.height > 100 && false) //those tall monsters like to impress
                style += "min-height:100px;";
            buf.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
        }
        
        //fade at the bottom. doesn't look good:
        //buf.append(HTMLGenerateTagWrap("span", "", mapMake("src", monster_image_url, "style", "position:absolute;bottom:0px;width:100%;display:block;height:25px;z-index:-1;background: -moz-linear-gradient(top, rgba(255,255,255,0) 0%, rgba(255,255,255,1) 90%, rgba(255,255,255,1) 100%);background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(255,255,255,0)), color-stop(90%,rgba(255,255,255,1)), color-stop(100%,rgba(255,255,255,1)));background: -webkit-linear-gradient(top, rgba(255,255,255,0) 0%,rgba(255,255,255,1) 90%,rgba(255,255,255,1) 100%);background: -o-linear-gradient(top, rgba(255,255,255,0) 0%,rgba(255,255,255,1) 90%,rgba(255,255,255,1) 100%);background: -ms-linear-gradient(top, rgba(255,255,255,0) 0%,rgba(255,255,255,1) 90%,rgba(255,255,255,1) 100%);background: linear-gradient(to bottom, rgba(255,255,255,0) 0%,rgba(255,255,255,1) 90%,rgba(255,255,255,1) 100%);filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#00ffffff', endColorstr='#ffffff',GradientType=0 );")));
        if (!monster_image_url.contains_text("nopic.gif") && monster_image_url.length() > 0)
        {
            //FIXME centre image if it's small? maybe a table? more tables!
            boolean from_bottom_instead = false;
            if ($strings[images/adventureimages/lower_b.gif,images/adventureimages/lower_k.gif,images/adventureimages/lower_h.gif,images/adventureimages/upper_q.gif,images/adventureimages/aswarm.gif,images/adventureimages/lowerm.gif,images/adventureimages/dad_machine.gif] contains monster_image_url && monster_image_stats.maximum_y_coordinate != -1 && monster_image_stats.height != -1) //dungeons of doom, dad sea monkee
                from_bottom_instead = true;
            
            
            float max_height = 100;
            //monster_image_stats.height
            //make max_height adjust:
            float effective_height = monster_image_stats.maximum_y_coordinate - monster_image_stats.minimum_y_coordinate + 1;
            float height_fraction = 1.0;
            if (monster_image_stats.height > 0)
                height_fraction = effective_height / monster_image_stats.height.to_float();
            
            if (height_fraction > 0)
                max_height = 100.0 / height_fraction;
            //buf.append("height_fraction = " + height_fraction);
            
            string image_style = "position:absolute;right:0px;top:0px;max-height:" + max_height.ceil() + "px;z-index:-3;";
            if (monster_cannot_be_encountered)
                image_style += "opacity:0.1;";
            else if (last_monster() == m)
                image_style += "opacity:1.0;";
            else if (m.attributes.contains_text("ULTRARARE"))
                image_style += "opacity:0.1;";
            else
                image_style += "opacity:0.5;";
            if (from_bottom_instead)
            {
                float location_of_first_bottom_pixel = monster_image_stats.maximum_y_coordinate;
                float margin_bottom = monster_image_stats.height - location_of_first_bottom_pixel;
                if (monster_image_stats.height != 100)
                {
                    //correct margin, as we scale images down to 100
                    float ratio = monster_image_stats.height.to_float() / 100.0;
                    if (ratio != 0.0)
                        margin_bottom /= ratio;
                }
                image_style += "bottom:0px;";
                image_style += "margin-bottom:-" + ceil(margin_bottom) + "px;";
                
            }
            else
            {
                float location_of_first_top_pixel = MAX(0, monster_image_stats.minimum_y_coordinate);
                if (monster_image_stats.height != 100 && false) //FIXME ???
                {
                    //correct margin, as we scale images down to 100
                    float ratio = monster_image_stats.height.to_float() / 100.0;
                    if (ratio != 0.0)
                        location_of_first_top_pixel /= ratio;
                }
                if (location_of_first_top_pixel > 0)
                    image_style += "margin-top:-" + location_of_first_top_pixel + "px;";
            }
            buf.append(HTMLGenerateTagPrefix("img", mapMake("src", monster_image_url, "style", image_style)));
        }
        
        //buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "float:left;display:inline-block;")));
        //buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;vertical-align:top;padding-left:0.5em;")));
        
        /*if (try_for_minimal_display)
            buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table;")));
        else
        {
            int min_height = 30;
            if (monster_cannot_be_encountered)
                min_height = 0;
            buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table;min-height:" + min_height + "px;")));
        }
        buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;vertical-align:middle;")));*/
        
        if (true)
        {
            string style;
            float width_weight = 1.4;
            if (monster_cannot_be_encountered)
            {
                style += "text-decoration:line-through;";
                //width_weight = 1.0;
            }
            else
                style = "font-size:1.2em;";
            style += "text-align:left;";
            //buf.append(HTMLGenerateTagWrap("span", m.capitalizeFirstLetter(), mapMake("class", "r_bold", "style", style)));
            
            fl_entries.listAppend(m.capitalizeFirstLetter());
            fl_entry_classes[fl_entries.count() - 1] = "r_bold r_location_bar_ellipsis_entry";
            fl_entry_styles[fl_entries.count() - 1] = style;
            //fl_entry_fixed_width_percentage[fl_entries.count() - 1] = 0.33;
            //fl_entry_fixed_width_percentage[fl_entries.count() - 1] = 0.4;
            fl_entry_width_weight[fl_entries.count() - 1] = width_weight;
        }
        
        
        
        //FIXME handle canceling NC
        buffer rate_buffer;
        if (m.is_banished() && banishes_are_possible)
        {
            rate_buffer.append("banished");
            Banish banish_information = m.BanishForMonster();
            if (banish_information.banish_source.length() > 0)
            {
                rate_buffer.append(" by ");
                rate_buffer.append(banish_information.banish_source);
            }
            if (banish_information.custom_reset_conditions.length() > 0)
            {
                rate_buffer.append(" until ");
                rate_buffer.append(banish_information.custom_reset_conditions);
            }
            else if (banish_information.banish_turn_length == -1)
                rate_buffer.append(" forever");
            else if (banish_information.banish_turn_length > 0)
            {
                int turns_left = banish_information.BanishTurnsLeft();
                rate_buffer.append(" for ");
                rate_buffer.append(pluralize(turns_left, "more turn", "more turns"));
            }
            rate_buffer.append(" ");
            avoid_outputting_conditional = true;
        }
        else if (m.attributes.contains_text("SEMIRARE"))
        {
            rate_buffer.append("semi-rare ");
            avoid_outputting_conditional = true;
        }
        else if (m.attributes.contains_text("ULTRARARE"))
        {
            rate_buffer.append("ultra rare ");
            avoid_outputting_conditional = true;
        }
        else if (m.boss)
        {
            rate_buffer.append("boss ");
            avoid_outputting_conditional = true;
        }
        if (rate > 0 && !(m.is_banished() && banishes_are_possible) && !monster_cannot_be_encountered)
        {
            if (!rates_are_equal)
            {
                rate_buffer.append(rate.roundForOutput(0));
                rate_buffer.append("%");
            }
            if (next_rate != rate && next_rate > 0 && !next_rates_are_equal)
            {
                if (rates_are_equal)
                    rate_buffer.append("equal %");
                rate_buffer.append("<br>next ");
                
                rate_buffer.append(next_rate.roundForOutput(0));
                rate_buffer.append("%");
            }
        }
        else if (rate <= 0)
        {
            if (possible_alien_monsters contains m)
                rate_buffer.append("elsewhere");
            else if (!avoid_outputting_conditional)
                rate_buffer.append("conditional");
            //rate_buffer.append(" ("); rate_buffer.append(rate); rate_buffer.append(")");
        }
        //seen values for rate:
        //0.0 for bosses
        //-1.0 for ultra-rares
        
        if (rate_buffer.length() > 0)
        {
            //buf.append(" ");
            //buf.append(rate_buffer);
            fl_entries.listAppend(rate_buffer);
            //fl_entry_styles[fl_entries.count() - 1] = "text-align:left;";
        }
        if (monster_cannot_be_encountered && reason_monster_cannot_be_encountered != "banished")
        {
            //buf.append(" ");
            //buf.append(reason_monster_cannot_be_encountered);
            fl_entries.listAppend(reason_monster_cannot_be_encountered);
        }
        
        
        
        
        
        
        int item_count_displaying = m.item_drops_array().count();
        if (item_count_displaying > 0 && try_for_minimal_display && !monster_cannot_be_encountered)
        {
            fl_entries.listAppend(pluralize(item_count_displaying, "item", "items"));
            /*item [int] items_dropped;
            foreach key, r in m.item_drops_array()
                items_dropped.listAppend(r.drop);
            buf.append(items_dropped.listJoinComponents(", "));*/
        }
        
        
        if (true)
        {
            string [int] stats_l1;
            string [int] stats_l2;
            //if (m.base_hp > 0)
                //stats_l1.listAppend(m.base_hp + " HP");
            if (m.phylum != $phylum[none])
            {
                string line = m.phylum;
                if (true && m.attack_element != $element[none])
                    line = HTMLGenerateSpanOfClass(line, "r_element_" + m.attack_element + "_desaturated");
                stats_l1.listAppend(line);
            }
            /*if (m.attack_element != $element[none] && false)
            {
                stats_l2.listAppend(HTMLGenerateSpanOfClass(m.attack_element, "r_element_" + m.attack_element + "_desaturated"));
            }*/
            if (m.max_meat > 0)
            {
                float average_meat = (m.min_meat + m.max_meat) * 0.5;
                average_meat *= (1.0 + meat_drop_modifier() / 100.0);
                if (average_meat > 0)
                    stats_l1.listAppend(average_meat.round() + " meat");
            }
            if (m.raw_attack > 0 && false) //is this really useful?
                stats_l2.listAppend(m.raw_attack + " ML");
            //if (m.raw_defense > 0)
                //stats_l2.listAppend(m.raw_defense + " def");
            
            if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
            {
                int ka_dropped = m.ka_dropped();
                if (ka_dropped > 0)
                    stats_l1.listAppend(ka_dropped + " ka");
            }
            
            if (m.expected_damage() > 1 && m.expected_damage() > my_hp().to_float() * 0.75)
            {
                string damage_text = m.expected_damage() + " dmg";
                if (m.expected_damage() >= 0.75 * my_hp())
                    damage_text = HTMLGenerateSpanOfClass(damage_text, "r_element_hot_desaturated"); //"#FC686F", "");
                stats_l2.listAppend(damage_text);
            }
            
            if (stats_l2.count() == 0 && stats_l1.count() == 2) //hack
            {
                stats_l2.listAppend(stats_l1[1]);
                remove stats_l1[1];
            }
            
            string line = stats_l1.listJoinComponents(" / ");
            if (stats_l2.count() > 0)
                line += "<br>" + stats_l2.listJoinComponents(" / ");
            fl_entries.listAppend(line);
            fl_entry_styles[fl_entries.count() - 1] = "text-align:right;";
            //fl_entry_fixed_width_percentage[fl_entries.count() - 1] = 0.4;
            fl_entry_width_weight[fl_entries.count() - 1] = 1.4;
        }
        
        //buf.append(HTMLGenerateTagSuffix("div"));
        //buf.append(HTMLGenerateTagSuffix("div"));
        //add background blur:
        //FIXME use a CSS class
        if (true)
        {
            foreach key, entry in fl_entries
            {
                entry = HTMLGenerateSpanOfClass(entry, "r_location_bar_background_blur");
                fl_entries[key] = entry;
            }
        }
        if (!(m.is_banished() && banishes_are_possible))
        {
            if (fl_entries.count() == 2)
                fl_entry_fixed_width_percentage[0] = 0.60;
            else if (fl_entries.count() == 3)
            {
                fl_entry_fixed_width_percentage[0] = 0.50;
                fl_entry_fixed_width_percentage[1] = 0.2;
                fl_entry_fixed_width_percentage[2] = 0.3;
            }
        }
            //remove fl_entry_fixed_width_percentage[0];
        
        //buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "background:rgba(222, 222, 222 ,0.9);")));
        buf.append(generateLocationBarTable(fl_entries, fl_entry_urls, fl_entry_styles, fl_entry_classes, fl_entry_width_weight, fl_entry_fixed_width_percentage, ""));
        //buf.append(HTMLGenerateTagSuffix("div"));
        
        
        //buf.append(HTMLGenerateIndentedText(m.to_json()));
        if (item_count_displaying > 0 && !try_for_minimal_display && !monster_cannot_be_encountered)
        {
            //buf.append(HTMLGenerateTagPrefix("hr", mapMake("style", "margin-left:10px;")));
            //buf.append("<hr>");
            //buf.append(HTMLGenerateIndentedText(m.item_drops().to_json()));
            
            //buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_indention")));
            //buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "margin-left:30px;")));
            boolean want_item_minimal_display = false;
            if (try_for_minimal_display || monsters_to_display_items_minimally[m] || monsters_to_display_items_minimally.count() > 2)
                want_item_minimal_display = true;
            string item_font_size = "medium";
            if (true)
            {
                string style;
                //style += "line-height:.9em;";
                //style += "line-height:0px;";
                style += "font-size:0;";
                if (want_item_minimal_display)
                    item_font_size = "0.8rem;";
                //if (want_item_minimal_display)
                    //style += "font-size:0.8em;display:inline;";
                if (style.length() > 0)
                    buf.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
                else
                    buf.append(HTMLGenerateTagPrefix("div"));
            }
            int number_of_slimeling_eligible_items = 0;
            foreach key, r in m.item_drops_array()
            {
                if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains r.drop.to_slot())
                    number_of_slimeling_eligible_items += 1;
            }
            
            foreach key, r in m.item_drops_array()
            //foreach key, r in item_drops_array
            {
                //when "r.type" == "0", I think that means the drop rate is unknown
                item it = r.drop;
                int drop_rate = r.rate;
                int adjusted_base_drop_rate = drop_rate;
                boolean drop_rate_is_actually_zero = false;
                boolean drop_rate_is_guess = false;
                
                boolean item_is_conditional = r.type.contains_text("c");
                boolean item_is_stealable_accordion = r.type.contains_text("a");
                boolean item_is_pickpockable_only = r.type.contains_text("p");
                boolean item_cannot_be_pickpocketed = r.type.contains_text("n"); //FIXME use this for anything?
                boolean item_rate_is_fixed = r.type.contains_text("f");
                buffer trailing_buffer_loop;
                boolean grey_out_item = false;
                if (item_is_stealable_accordion && my_class() != $class[accordion thief])
                {
                    grey_out_item = true;
                    adjusted_base_drop_rate = 0;
                    drop_rate_is_actually_zero = true;
                }
                if (item_is_pickpockable_only && !__misc_state["can pickpocket"])
                {
                    grey_out_item = true;
                    adjusted_base_drop_rate = 0;
                    drop_rate_is_actually_zero = true;
                }
                if (it == $item[reflection of a map] && get_property_int("pendingMapReflections") == 0)
                {
                    grey_out_item = true;
                    adjusted_base_drop_rate = 0;
                    drop_rate_is_actually_zero = true;
                }
                if (($items[folder (red),folder (blue),folder (green),folder (magenta),folder (cyan),folder (yellow),folder (smiley face),folder (wizard),folder (space skeleton),folder (D-Team),folder (Ex-Files),folder (skull and crossbones),folder (Knight Writer),folder (Jackass Plumber),folder (holographic fractal),folder (barbarian),folder (rainbow unicorn),folder (Seawolf),folder (dancing dolphins),folder (catfish),folder (tranquil landscape),folder (owl),folder (Stinky Trash Kid),folder (sports car),folder (sportsballs),folder (heavy metal),folder (Yedi),folder (KOLHS)] contains it))
                {
                    if (drop_rate <= 0)
                    {
                        drop_rate = 5; //assumed
                        adjusted_base_drop_rate = drop_rate; //assumed
                        drop_rate_is_guess = true;
                    }
                    if ($item[over-the-shoulder folder holder].equipped_amount() == 0)
                    {
                        grey_out_item = true;
                        adjusted_base_drop_rate = 0;
                        drop_rate_is_actually_zero = true;
                        drop_rate_is_guess = false;
                    }
                }
                
                if (grey_out_item)
                {
                    buf.append(HTMLGenerateTagPrefix("span", mapMake("style", "color:grey;")));
                    trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("span"));
                }
                
                //buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_word_wrap_group", "style", "width:49%;")));
                //buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_word_wrap_group", "style", "width:49%;")));
                int items_per_line = 1;
                string holder_class_name = "r_word_wrap_group";
                if (try_for_minimal_display)
                    holder_class_name = "r_word_wrap_group";
                else if (item_count_displaying == 1)
                {
                    holder_class_name = "r_location_popup_item_holding_block_1x";
                    items_per_line = 1;
                }
                //else if ((item_count_displaying == 2 || (item_count_displaying % 2 == 0 && item_count_displaying % 3 != 0)) && can_display_as_2x)
                else if (item_count_displaying == 2 || ceil(item_count_displaying.to_float() / 2.0) == ceil(item_count_displaying.to_float() / 3.0))
                {
                    holder_class_name = "r_location_popup_item_holding_block_2x";
                    items_per_line = 2;
                }
                else
                {
                    holder_class_name = "r_location_popup_item_holding_block";
                    items_per_line = 3;
                }
                
                if (true)
                {
                    string style;
                    //style += "background:rgba(255, 255, 255, 0.95);box-shadow:0px 0px 2px 2px rgba(255, 255, 255, 0.95);";
                    //style += "background:teal;";
                    //style += "font-size:0;";
                    buf.append(HTMLGenerateTagPrefix("div", mapMake("class", holder_class_name, "style", style)));
                }
                
                trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("div"));
                
                boolean use_tables_here = true;
                
                //buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_word_wrap_group", "style", "padding-right:0.5em")));
                if (true)
                {
                    string style;
                    if (use_tables_here)
                       style += "display:table;";
                    //style += "background:rgba(255, 255, 255, 0.95);box-shadow:0px 0px 2px 2px rgba(255, 255, 255, 0.95);";
                    style += "margin:0px;padding:0px;border-spacing:0px;";
                    buf.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
                    //style = "background:rgba(0, 127, 255, 0.75);";
                    trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("div"));
                    if (use_tables_here)
                    {
                        buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-row;")));
                        //style = "background:rgba(0, 127, 255, 0.75);";
                        trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("div"));
                    }
                }
                
                string image_url = "images/itemimages/" + it.smallimage;
                if (it.smallimage.contains_text("/"))
                    image_url = "images/" + it.smallimage;
                if (it.image.length() > 0 && !try_for_minimal_display)
                {
                    if (use_tables_here)
                    {
                        buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;vertical-align:middle;", "class", "r_location_bar_background_blur")));
                    }
                    int image_size = 30;
                    if (want_item_minimal_display)
                        image_size = 15;
                    string [string] image_map = mapMake("src", image_url, "width", image_size, "height", image_size);
                    image_map["style"] += "display:block;"; //removes implicit pixels around image. css
                    if (grey_out_item)
                        image_map["style"] += "opacity:0.5;";
                    buf.append(HTMLGenerateTagPrefix("img", image_map));
                    if (use_tables_here)
                    {
                        buf.append(HTMLGenerateTagSuffix("div"));
                    }
                }
                if (use_tables_here)
                {
                    string style = "display:table-cell;vertical-align:middle;padding-left:0.25em;font-size:" + item_font_size + ";";
                    //style += "background:rgba(255, 255, 255, 0.95);box-shadow:0px 0px 2px 2px rgba(255, 255, 255, 0.95);";
                    buf.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
                    trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("div"));
                    
                    buf.append(HTMLGenerateTagPrefix("span", mapMake("class", "r_location_bar_background_blur")));
                    trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("span"));
                }
                if (false)
                {
                    buf.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:none;")));
                    trailing_buffer_loop.prepend(HTMLGenerateTagSuffix("div"));
                }
                
                string [int] item_display_properties;
                if (adjusted_base_drop_rate == 0 && !drop_rate_is_actually_zero)
                {
                    if (!item_is_stealable_accordion)
                    {
                        buf.append("?%");
                        buf.append(" ");
                    }
                }
                else if (adjusted_base_drop_rate < 100)
                {
                    float effective_drop_rate = adjusted_base_drop_rate;
                    float item_modifier = l.item_drop_modifier_for_location();
                    if (it.fullness > 0 || (__items_that_craft_food contains it))
                        item_modifier += numeric_modifier("Food Drop");
                    if (it.inebriety > 0)
                        item_modifier += numeric_modifier("Booze Drop");
                    if (it.to_slot() == $slot[hat])
                        item_modifier += numeric_modifier("Hat Drop");
                    if (it.to_slot() == $slot[weapon])
                        item_modifier += numeric_modifier("Weapon Drop");
                    if (it.to_slot() == $slot[off-hand])
                        item_modifier += numeric_modifier("Offhand Drop");
                    if (it.to_slot() == $slot[shirt])
                        item_modifier += numeric_modifier("Shirt Drop");
                    if (it.to_slot() == $slot[pants])
                        item_modifier += numeric_modifier("Pants Drop");
                    if ($slots[acc1,acc2,acc3] contains it.to_slot())
                        item_modifier += numeric_modifier("Accessory Drop");
                    if (it.candy)
                        item_modifier += numeric_modifier("Candy Drop");
                    if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot()) //assuming familiar equipment isn't "gear"
                        item_modifier += numeric_modifier("Gear Drop");
                    if (item_is_pickpockable_only)
                    {
                        if (__misc_state["can pickpocket"])
                            item_modifier = numeric_modifier("pickpocket chance");
                        else
                            item_modifier = 0.0;
                    }
                    if (item_rate_is_fixed)
                        item_modifier = 0.0;
                    if ($locations[sweet-ade lake,Eager Rice Burrows,Gumdrop Forest] contains l)
                    {
                        item_modifier = 0.0;
                        if (it.candy)
                            item_modifier += numeric_modifier("Candy Drop");
                    }
                    //FIXME slimeling?
                    //FIXME pickpocketting...?
                    
                    effective_drop_rate *= 1.0 + item_modifier / 100.0;
                    if (my_path_id() == PATH_HEAVY_RAINS)
                    {
                        effective_drop_rate = clampf(floor(effective_drop_rate), 0.0, 100.0);
                        float washaway_rate = l.washaway_rate_of_location();
                        effective_drop_rate *= (1.0 - washaway_rate);
                    }
                    if (my_familiar() == $familiar[slimeling] && ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot()) && effective_drop_rate < 100.0)
                    {
                        effective_drop_rate = clampf(floor(effective_drop_rate), 0.0, 100.0);
                        //number_of_slimeling_eligible_items
                        float slimeling_chance = 0.0;
                        if (number_of_slimeling_eligible_items > 0)
                            slimeling_chance = 1.0 / number_of_slimeling_eligible_items.to_float();
                        
                        int effective_familiar_weight = my_familiar().familiar_weight() + numeric_modifier("familiar weight");
                        int familiar_weight_from_familiar_equipment = $slot[familiar].equipped_item().numeric_modifier("familiar weight"); //need to cancel it out
                        
                        float slimeling_base_drop_rate = my_familiar().numeric_modifier("item drop", effective_familiar_weight - familiar_weight_from_familiar_equipment, $slot[familiar].equipped_item());
                        if ($slot[familiar].equipped_item() == $item[undissolvable contact lenses])
                            slimeling_base_drop_rate += 25.0;
                        
                        slimeling_chance *= adjusted_base_drop_rate.to_float() * (1.0 + slimeling_base_drop_rate / 100.0);
                        effective_drop_rate += (100.0 - effective_drop_rate) * (slimeling_chance / 100.0);
                    }
                    
                    effective_drop_rate = clampf(floor(effective_drop_rate), 0.0, 100.0);
                    
                    
                    if (!grey_out_item)
                    {
                        buf.append(effective_drop_rate.floor());
                        if (drop_rate_is_guess)
                            buf.append("?");
                        buf.append("% ");
                    }
                    
                    if (fabs(effective_drop_rate - drop_rate.to_float()) > 0.01)
                    {
                        buffer line;
                        line.append(drop_rate);
                        line.append("%");
                        if (drop_rate_is_guess)
                            line.append("?");
                        item_display_properties.listAppend(line.to_string());
                    }
                }
                buf.append(it);
                if (item_is_conditional)
                {
                    item_display_properties.listAppend("conditional");
                }
                if (item_is_stealable_accordion)
                    item_display_properties.listAppend("stealable");
                if (item_is_pickpockable_only)
                    item_display_properties.listAppend("pickpocket");
                if (item_rate_is_fixed)
                    item_display_properties.listAppend("unaffected by +item");
                if (item_display_properties.count() > 0)
                {
                    buf.append(HTMLGenerateTagPrefix("span", mapMake("class", "r_cl_modifier_inline")));
                    buf.append(" (");
                    buf.append(item_display_properties.listJoinComponents(", "));
                    buf.append(")");
                    buf.append(HTMLGenerateTagSuffix("span"));
                }
                buf.append(trailing_buffer_loop);
            }
            buf.append(HTMLGenerateTagSuffix("div"));
        }
        
        //buf.append(HTMLGenerateTagSuffix("div"));
        buf.append(HTMLGenerateTagSuffix("div"));
        //break;
    }
    if (monsters_displayed == 0)
        return "".to_buffer();
    //buf.append(l.appearance_rates(true).to_json());
    buf.append(HTMLGenerateTagSuffix("div"));
    buf.append(HTMLGenerateTagSuffix("div"));
    
    return buf;
}
