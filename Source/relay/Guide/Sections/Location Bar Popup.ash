import "relay/Guide/Support/Banishers.ash";
import "relay/Guide/Paths/Bad Moon.ash";

Record LBPItemInformation
{
    string image_url;
    boolean should_display_drop_current;
    string item_drop_current_information;
    string item_name;
    boolean should_display_drop_base;
    string item_drop_base_information;
    string [int] tags;
    boolean greyed_out;
};

void listAppend(LBPItemInformation [int] list, LBPItemInformation entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

buffer createItemInformationTableMethod2(int columns, LBPItemInformation [int] items_presenting, boolean want_item_minimal_display, string table_class, string table_style)
{
    buffer output_buffer;

    string [string] table_map;
    table_map = mapMake("style", "display:table;");
    if (table_style != "")
        table_map["style"] += table_style;
    if (table_class != "")
        table_map["class"] = table_class;
    output_buffer.append(HTMLGenerateTagPrefix("div", table_map));
    
    
    foreach key, info in items_presenting
    {
        if (key % columns == 0)
        {
            if (key != 0)
            {
                output_buffer.append("</div>");
            }
            output_buffer.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-row;")));
        }
        int image_size = 30;
        if (want_item_minimal_display)
            image_size = 15;
        
        //hack?
        float percentage = 33;
        if (columns == 2)
            percentage = 50;
        if (columns == 1)
            percentage = 100;
        
        
        int [int] image_sizes;
        string [int] image_classes;
        
        image_classes.listAppend("r_only_display_if_not_tiny"); // r_only_display_if_not_small");
        image_sizes.listAppend(image_size);
        
        //image_classes.listAppend("r_only_display_if_small");
        //image_sizes.listAppend(MIN(image_size, 20));
        
        string image_url = info.image_url;
        if (image_url.length() == 0)
        {
            image_url = "images/itemimages/confused.gif";
        }
        
        foreach key in image_sizes
        {
            int using_size = image_sizes[key];
            string image_class = image_classes[key];
            output_buffer.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;max-width:" + using_size + ";max-height:" + using_size + ";min-width:" + using_size + ";min-height:" + using_size + ";padding-left:3px;padding-right:3px;vertical-align:middle;", "class", image_class)));
            
            //Generate image:
            string [string] image_map = mapMake("src", image_url, "width", using_size, "height", using_size);
            
            image_map["style"] += "display:block;"; //removes implicit pixels around image
            if (info.greyed_out)
                image_map["style"] += "opacity:0.5;";
            image_map["alt"] = info.item_name;
            output_buffer.append(HTMLGenerateTagPrefix("img", image_map));
            output_buffer.append("</div>");
        }
        
        
        string main_tag_style = "display:table-cell;width:" + percentage + "%;vertical-align:middle;";
        if (info.greyed_out)
            main_tag_style += "color:gray;";
        if (want_item_minimal_display)
            main_tag_style += "font-size:0.9em;";
        output_buffer.append(HTMLGenerateTagPrefix("div", mapMake("style", main_tag_style)));
        if (want_item_minimal_display)
            output_buffer.append(HTMLGenerateTagPrefix("span", mapMake("class", "r_location_bar_background_blur_small")));
        else
            output_buffer.append(HTMLGenerateTagPrefix("span", mapMake("class", "r_location_bar_background_blur")));
        
        if (info.should_display_drop_current)
        {
            output_buffer.append(info.item_drop_current_information);
            output_buffer.append(" ");
        }
        output_buffer.append(info.item_name);
        
        string [int] secondary_line;
        if (info.should_display_drop_base)
            secondary_line.listAppend(info.item_drop_base_information);
        if (info.tags.count() > 0)
            secondary_line.listAppendList(info.tags);
        
        if (secondary_line.count() > 0)
        {
            string [string] tag_map = mapMake("class", "r_cl_modifier_inline");
            if (info.greyed_out)
                tag_map["style"] += "color:gray;";
            string wrap_type = "span"; //"div";
            if (want_item_minimal_display)
                wrap_type = "span";
            else
                tag_map["style"] += "display:block;";
            
            output_buffer.append(HTMLGenerateTagPrefix(wrap_type, tag_map));
            if (!want_item_minimal_display)
                output_buffer.append(HTMLGenerateTagPrefix("span", mapMake("class", "r_location_bar_background_blur")));
            if (want_item_minimal_display)
                output_buffer.append(" (");
            output_buffer.append(secondary_line.listJoinComponents(", "));
            if (want_item_minimal_display)
                output_buffer.append(")");
            if (!want_item_minimal_display)
                output_buffer.append("</span>");
            output_buffer.append(HTMLGenerateTagSuffix(wrap_type));
        }
        
        output_buffer.append("</span>");
        output_buffer.append("</div>");
    }
    output_buffer.append("</div>"); //row
    output_buffer.append("</div>"); //table
    return output_buffer;
}


buffer generateItemInformationMethod2(location l, monster m, boolean try_for_minimal_display, boolean [monster] monsters_to_display_items_minimally)
{
    int number_of_slimeling_eligible_items = 0;
    foreach key, r in m.item_drops_array()
    {
        if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains r.drop.to_slot())
            number_of_slimeling_eligible_items += 1;
    }
    
    
    LBPItemInformation [int] items_presenting;
    
    foreach key, r in m.item_drops_array()
    {
        item it = r.drop;
        int base_drop_rate = r.rate;
        
        
        
        int adjusted_base_drop_rate = base_drop_rate;
        boolean drop_rate_is_actually_zero = false;
        boolean drop_rate_is_guess = false;
        
        //r-type?
        boolean item_is_conditional = r.type.contains_text("c");
        boolean item_is_stealable_accordion = r.type.contains_text("a");
        boolean item_is_pickpockable_only = r.type.contains_text("p");
        boolean item_cannot_be_pickpocketed = r.type.contains_text("n"); //FIXME use this for anything?
        boolean item_rate_is_fixed = r.type.contains_text("f");
        boolean item_is_avatar_potion = r.drop.to_effect().string_modifier("Avatar") != "";
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
            if (base_drop_rate <= 0)
            {
                base_drop_rate = 5; //assumed
                adjusted_base_drop_rate = base_drop_rate; //assumed
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
        
        string [int] item_drop_modifiers_to_display;
        if (adjusted_base_drop_rate > 0 && adjusted_base_drop_rate < 100)
        {

            float effective_drop_rate = adjusted_base_drop_rate;
            float item_modifier = l.item_drop_modifier_for_location();
            if (it.fullness > 0 || (__items_that_craft_food contains it))
            {
                item_modifier += numeric_modifier("Food Drop");
                item_drop_modifiers_to_display.listAppend("+food");
            }
            if (it.inebriety > 0)
            {
                item_modifier += numeric_modifier("Booze Drop");
                item_drop_modifiers_to_display.listAppend("+booze");
            }
            if (it.to_slot() == $slot[hat])
            {
                item_modifier += numeric_modifier("Hat Drop");
                item_drop_modifiers_to_display.listAppend("+hat");
            }
            if (it.to_slot() == $slot[weapon])
            {
                item_modifier += numeric_modifier("Weapon Drop");
                item_drop_modifiers_to_display.listAppend("+weapon");
            }
            if (it.to_slot() == $slot[off-hand])
            {
                item_modifier += numeric_modifier("Offhand Drop");
                item_drop_modifiers_to_display.listAppend("+offhand");
            }
            if (it.to_slot() == $slot[shirt])
            {
                item_modifier += numeric_modifier("Shirt Drop");
                item_drop_modifiers_to_display.listAppend("+shirt");
            }
            if (it.to_slot() == $slot[pants])
            {
                item_modifier += numeric_modifier("Pants Drop");
                item_drop_modifiers_to_display.listAppend("+pants");
            }
            if ($slots[acc1,acc2,acc3] contains it.to_slot())
            {
                item_modifier += numeric_modifier("Accessory Drop");
                item_drop_modifiers_to_display.listAppend("+accessory");
            }
            if (it.candy)
            {
                item_modifier += numeric_modifier("Candy Drop");
                item_drop_modifiers_to_display.listAppend("+candy");
            }
            if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot()) //assuming familiar equipment isn't "gear"
            {
                item_modifier += numeric_modifier("Gear Drop");
                item_drop_modifiers_to_display.listAppend("+gear");
            }
            if (it == $item[black picnic basket] && $skill[Bear Essence].have_skill())
            {
                item_modifier += 20.0 * MAX(1, get_property_int("skillLevel134"));
            }
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
            //FIXME pickpocketting...?
            //FIXME black cat
            
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
            //not a quest item, ???
            //if (my_familiar() == $familiar[black cat])
            
            effective_drop_rate = clampf(floor(effective_drop_rate), 0.0, 100.0);
            adjusted_base_drop_rate = effective_drop_rate;
            
            if (l.environment == "underwater") //FIXME underwater drops are complicated and I'd have to look deeply into this to verify, so we just list a ? for now
                adjusted_base_drop_rate = -1;
        }

        
        
        //FIXME implement this
        LBPItemInformation info;
        
        info.image_url = "images/itemimages/" + it.smallimage;
        if (it.smallimage.contains_text("/"))
            info.image_url = "images/" + it.smallimage;
        
        if (!grey_out_item)
        {
            if (adjusted_base_drop_rate <= 0)
            {
                info.should_display_drop_current = true;
                info.item_drop_current_information = "?%";
            }
            else if (adjusted_base_drop_rate < 100 || base_drop_rate < 100)
            {
                info.should_display_drop_current = true;
                if (drop_rate_is_guess)
                    info.item_drop_current_information = adjusted_base_drop_rate + "?%";
                else
                    info.item_drop_current_information = adjusted_base_drop_rate + "%";
            }
        }
        info.item_name = it;
        if (it.available_amount() == 0)
            info.item_name = "<i>" + info.item_name + "</i>";
        
        if (base_drop_rate != adjusted_base_drop_rate && base_drop_rate > 0 && base_drop_rate < 100 && !grey_out_item)
        {
            info.should_display_drop_base = true;
            if (drop_rate_is_guess)
                info.item_drop_base_information = base_drop_rate + "?%";
            else
                info.item_drop_base_information = base_drop_rate + "%";
        }
        if (item_drop_modifiers_to_display.count() > 0)
        {
            if (info.item_drop_base_information != "")
                info.item_drop_base_information += ", ";
            info.item_drop_base_information += item_drop_modifiers_to_display.listJoinComponents(", ") + " drop";
        }
        if (item_is_conditional)
            info.tags.listAppend("conditional");
        if (item_is_pickpockable_only)
            info.tags.listAppend("pickpocket");
        if (item_rate_is_fixed)
            info.tags.listAppend("unaffected by +item");
        if (item_is_avatar_potion)
            info.tags.listAppend("avatar");
        info.greyed_out = grey_out_item;
        
        items_presenting.listAppend(info);
    }

    
    int columns = 3;
    if (items_presenting.count() % 2 == 0 && items_presenting.count() % 3 != 0 && items_presenting.count() < 8)
        columns = 2;
    if (items_presenting.count() < columns)
        columns = 1;
    
    boolean want_item_minimal_display = false;
    if (try_for_minimal_display || monsters_to_display_items_minimally[m] || monsters_to_display_items_minimally.count() > 2)
        want_item_minimal_display = true;
    
    boolean display_alternate_for_smaller_sizes = (columns == 3);
    
    buffer output_buffer;
    output_buffer.append(HTMLGenerateTagPrefix("div", mapMake("style", "padding-left:" + (__setting_indention_width_in_em * 0.5) + "em;")));
    string table_class = "";
    if (display_alternate_for_smaller_sizes)
        table_class = "r_only_display_if_not_tiny r_only_display_if_not_small";
    
    output_buffer.append(createItemInformationTableMethod2(columns, items_presenting, want_item_minimal_display, table_class, ""));
    
    if (display_alternate_for_smaller_sizes)
    {
        int maximum_columns = 2;
        if (items_presenting.count() >= 7 || monsters_to_display_items_minimally.count() >= 5) //hippy camp
            maximum_columns = 3;
        output_buffer.append(createItemInformationTableMethod2(MIN(columns, maximum_columns), items_presenting, want_item_minimal_display, "r_only_display_if_not_large r_only_display_if_not_medium r_do_not_display_if_media_queries_unsupported", "")); //font-size:0.95em;
    }
    output_buffer.append("</div>"); //container
    
    return output_buffer;
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
        
        if (entry_url != "")
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
            bar.append(HTMLGenerateTagWrap("div", s, mapMake("class", "r_cl_modifier_inline", "style", "color:black;"))); //r_cl_modifier_inline needs its own div due to CSS class order precedence
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



buffer generateLocationPopup(float bottom_coordinates, boolean location_bar_location_name_is_centre_aligned)
{
    buffer buf;
    location l = __last_adventure_location;
    if (!__setting_location_bar_uses_last_location && !get_property_boolean("_relay_guide_setting_ignore_next_adventure_for_location_bar") && get_property_location("nextAdventure") != $location[none])
        l = get_property_location("nextAdventure");
    if (!__setting_enable_location_popup_box)
        return buf;
    
    string transition_time = "0.5s";
    buf.append(HTMLGenerateTagWrap("div", "", mapMake("id", "r_location_popup_blackout", "style", "position:fixed;z-index:5;width:100%;height:100%;background:rgba(0,0,0,0.5);opacity:0;pointer-events:none;visibility:hidden;")));
    
    
    buf.append(HTMLGenerateTagPrefix("div", mapMake("id", "r_location_popup_box", "style", "height:auto;transition:bottom " + transition_time + ";z-index:5;opacity:0;pointer-events:none;bottom:-10000px", "class", "r_bottom_outer_container")));
    buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_bottom_inner_container", "style", "background:white;height:auto;")));
    
    float [monster] appearance_rates_adjusted = l.appearance_rates_adjusted();
    float [monster] appearance_rates_next_turn = l.appearance_rates(true);
    
    string [monster] monsters_that_we_cannot_encounter;
    if ($effect[Ancient Annoying Serpent Poison].have_effect() == 0)
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
                monsters_that_we_cannot_encounter[m] = "ML based";
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
    
    monster [int] monster_display_order;
    boolean rates_are_equal = true;
    boolean next_rates_are_equal = true;
    float last_rate = -1.0;
    float last_next_rate = -1.0;
    foreach m in appearance_rates_adjusted
    {
        if (m == $monster[none])
            continue;
        float rate = appearance_rates_adjusted[m];
        float next_rate = appearance_rates_next_turn[m];
        if (rate <= 0.0 && l == $location[Investigating a Plaintive Telegram])
            continue;
        monster_display_order.listAppend(m);
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
    int entries_displayed = 0;
    int monsters_displayed = 0;
    
    boolean can_display_as_2x = true;
    boolean spelunking = limit_mode() == "spelunky";
    
    /*if (false) //trying with it off - it feels better to use layout more effectively, rather than try to line up everything. example area: domed city of grimacia
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
    }*/
    
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
        if (m.image.contains_text("/"))
            monster_image_url = "images/" + m.image;
        if (m.image == "toxbeast1.gif")
            monster_image_url = "images/adventureimages/toxbeast3.gif";
        if (m.image.length() == 0)
            monster_image_url = "";
        ServerImageStats monster_image_stats = ServerImageStatsOfImageURL(monster_image_url);
        float rate = appearance_rates_adjusted[m] * rate_nc_cancel_multiplier;
        float next_rate = appearance_rates_next_turn[m]; //already normalised for monsters
        if (entries_displayed > 0)
            buf.append(HTMLGenerateTagPrefix("hr", mapMake("style", "margin:0px;")));
        entries_displayed += 1;
        monsters_displayed += 1;
            
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
        else if (appearance_rates_adjusted[$monster[none]] >= 100.0 && !(possible_alien_monsters contains m))
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
        if (!monster_image_url.contains_text("nopic.gif") && monster_image_url != "")
        {
            //FIXME centre image if it's small? maybe a table? more tables!
            boolean from_bottom_instead = false;
            //if ($strings[images/adventureimages/lower_b.gif,images/adventureimages/lower_k.gif,images/adventureimages/lower_h.gif,images/adventureimages/upper_q.gif,images/adventureimages/aswarm.gif,images/adventureimages/lowerm.gif,images/adventureimages/dad_machine.gif] contains monster_image_url && monster_image_stats.maximum_y_coordinate != -1 && monster_image_stats.height != -1) //dungeons of doom, dad sea monkee
                //from_bottom_instead = true;
            
            
            float max_height = 100;
            //monster_image_stats.height
            //make max_height adjust:
            float effective_height = monster_image_stats.maximum_y_coordinate - monster_image_stats.minimum_y_coordinate + 1;
            float height_fraction = 1.0;
            if (monster_image_stats.height > 0)
                height_fraction = effective_height / monster_image_stats.height.to_float();
            
            if (height_fraction > 0)
                max_height = 100.0 / height_fraction;
            
            string image_style = "position:absolute;right:0px;top:0px;max-height:" + max_height.ceil() + "px;z-index:-3;";
            if (monster_cannot_be_encountered)
                image_style += "opacity:0.1;";
            else if (last_monster() == m)
                image_style += "opacity:0.5;"; //1.0
            else if (m.attributes.contains_text("ULTRARARE"))
                image_style += "opacity:0.1;";
            else
                image_style += "opacity:0.2;"; //0.5
            if (from_bottom_instead && false) //disabled, no longer works
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
            buf.append(HTMLGenerateTagPrefix("img", mapMake("src", monster_image_url, "style", image_style, "alt", m)));
        }
        
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
            style += "text-align:left;padding-top:2px;";
            
            fl_entries.listAppend(m.capitaliseFirstLetter());
            fl_entry_classes[fl_entries.count() - 1] = "r_bold r_location_bar_ellipsis_entry";
            fl_entry_styles[fl_entries.count() - 1] = style;
            fl_entry_width_weight[fl_entries.count() - 1] = width_weight;
        }
        
        
        
        //FIXME handle canceling NC
        buffer rate_buffer;
        if (m.is_banished() && banishes_are_possible)
        {
            rate_buffer.append("banished");
            Banish banish_information = m.BanishForMonster();
            if (banish_information.banish_source != "")
            {
                rate_buffer.append(" by ");
                rate_buffer.append(banish_information.banish_source);
            }
            if (banish_information.custom_reset_conditions != "")
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
                rate_buffer.append(pluralise(turns_left, "more turn", "more turns"));
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
        }
        //seen values for rate:
        //0.0 for bosses
        //-1.0 for ultra-rares
        
        if (rate_buffer.length() > 0)
        {
            fl_entries.listAppend(rate_buffer);
        }
        if (monster_cannot_be_encountered && reason_monster_cannot_be_encountered != "banished")
        {
            fl_entries.listAppend(reason_monster_cannot_be_encountered);
        }
        
        
        
        
        
        
        int item_count_displaying = m.item_drops_array().count();
        if (item_count_displaying > 0 && try_for_minimal_display && !monster_cannot_be_encountered)
        {
            fl_entries.listAppend(pluralise(item_count_displaying, "item", "items"));
        }
        
        
        if (!monster_cannot_be_encountered)
        {
            string [int] stats_l1;
            string [int] stats_l2;
            //if (m.base_hp > 0)
                //stats_l1.listAppend(m.base_hp + " HP");
            if (m.phylum != $phylum[none] && !spelunking)
            {
                string line;
                if ($monsters[broodling seal] contains m)
                    line = "<del>cute</del><br>";
                line += m.phylum;
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
                if (average_meat >= 25) //ignore really low amounts
                {
                    if (l.environment == "underwater") //FIXME calculate this properly
                        stats_l1.listAppend("? meat");
                    else
                        stats_l1.listAppend(average_meat.round() + " meat");
                }
            }
            if (m.base_attack > 0)
                stats_l2.listAppend(m.base_attack + " ML");
            if (spelunking)
                stats_l2.listAppend(m.base_hp + " HP");
            if ($skill[Extract Oil].have_skill())
            {
                string oil_type = lookupAWOLOilForMonster(m);
                if (oil_type != "")
                    stats_l2.listAppend(oil_type);
            }
            //if (m.raw_defense > 0)
                //stats_l2.listAppend(m.raw_defense + " def");
            if (true)
            {
                boolean manuel_available = $monster[spooky vampire].monster_factoids_available(false) > 0;
                if (manuel_available)
                {
                    int factoids_left = 3 - monster_factoids_available(m, false);
                    if (m.attributes.contains_text("ULTRARARE") || m.attributes.contains_text("NOMANUEL")) //ULTRARARE test may be superfluous
                        factoids_left = 0;
                    if (factoids_left > 0)
                        stats_l2.listAppend(factoids_left + " more fact" + (factoids_left > 1 ? "s" : ""));
                }
            }
            
            if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
            {
                int ka_dropped = m.ka_dropped();
                if (ka_dropped > 0)
                    stats_l1.listAppend(ka_dropped + " ka");
            }
            
            if (m.expected_damage() > 1 && (m.expected_damage() >= my_hp().to_float() * 0.5 || ($monsters[spider gremlin,batwinged gremlin,erudite gremlin,vegetable gremlin] contains m)) || spelunking)
            {
                string damage_text = m.expected_damage() + " dmg";
                if (m.expected_damage() >= 0.75 * my_hp())
                    damage_text = HTMLGenerateSpanOfClass(damage_text, "r_element_hot_desaturated"); //"#FC686F", "");
                stats_l2.listAppend(damage_text);
            }
            
            if (stats_l2.count() == 0 && stats_l1.count() == 2) //rebalance hack
            {
                stats_l2.listPrepend(stats_l1[1]);
                remove stats_l1[1];
            }
            if (stats_l2.count() == 1 && stats_l1.count() == 3) //rebalance hack
            {
                stats_l2.listPrepend(stats_l1[2]);
                remove stats_l1[2];
            }
            
            if (stats_l1.count() + stats_l2.count() > 0)
            {
                string line = stats_l1.listJoinComponents(" / ");
                if (stats_l2.count() > 0)
                {
                    if (stats_l1.count() > 0)
                        line += "<br>";
                    line += stats_l2.listJoinComponents(" / ");
                }
                fl_entries.listAppend(line);
                fl_entry_styles[fl_entries.count() - 1] = "text-align:right;";
                fl_entry_width_weight[fl_entries.count() - 1] = 1.4;
            }
        }
        
        //add background blur:
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
            else if (fl_entries.count() == 4)
            {
                fl_entry_fixed_width_percentage[0] = 0.40;
                fl_entry_fixed_width_percentage[1] = 0.2;
                fl_entry_fixed_width_percentage[2] = 0.15;
                fl_entry_fixed_width_percentage[3] = 0.25;
            }
        }
            //remove fl_entry_fixed_width_percentage[0];
        
        buf.append(generateLocationBarTable(fl_entries, fl_entry_urls, fl_entry_styles, fl_entry_classes, fl_entry_width_weight, fl_entry_fixed_width_percentage, ""));
        
        
        if (item_count_displaying > 0 && !try_for_minimal_display && !monster_cannot_be_encountered && true)
        {
            buf.append(generateItemInformationMethod2(l, m, try_for_minimal_display,monsters_to_display_items_minimally));
        }
        
        //buf.append(HTMLGenerateTagSuffix("div"));
        buf.append(HTMLGenerateTagSuffix("div"));
        //break;
    }
    
    if (in_bad_moon())
    {
        BadMoonAdventure [int] bad_moon_adventures = BadMoonAdventuresForLocation(l);
        
        if (bad_moon_adventures.count() > 0)
        {
            foreach key, adventure in bad_moon_adventures
            {
                if (haveSeenBadMoonEncounter(adventure.encounter_id))
                    continue;
                    
                string [int] fl_entries;
                string [int] fl_entry_urls;
                string [int] fl_entry_styles;
                string [int] fl_entry_classes;
                float [int] fl_entry_width_weight;
                float [int] fl_entry_fixed_width_percentage;
                
                
                string image_style = "margin-top:1px;";
                if (adventure.has_additional_requirements_not_yet_met)
                    image_style += "opacity:0.25;";
                fl_entries.listAppend(HTMLGenerateTagPrefix("img", mapMake("src", __bad_moon_small_image_data, "style", image_style)));
                fl_entry_styles[fl_entries.count() - 1] = "text-align:right;";
                fl_entry_fixed_width_percentage[fl_entries.count() - 1] = 0.1;
                fl_entries.listAppend(adventure.description);
                fl_entry_styles[fl_entries.count() - 1] = "text-align:left;";
                if (adventure.has_additional_requirements_not_yet_met)
                    fl_entries.listAppend("Need to " + adventure.conditions_to_finish);
                
                
                buf.append(HTMLGenerateTagPrefix("hr", mapMake("style", "margin:0px;")));
                buf.append(generateLocationBarTable(fl_entries, fl_entry_urls, fl_entry_styles, fl_entry_classes, fl_entry_width_weight, fl_entry_fixed_width_percentage, ""));
            }
        }
    }
    
    
    if (false)
    {
        string [int] lines;
        string [int] lines_offscreen;
        if (false && l.parentdesc != "" && l.parentdesc != "No Category" && l.parentdesc.to_lower_case() != l.to_lower_case())
            lines.listAppend(l.parentdesc);
        if (!__misc_state["in run"] && l.turns_spent > 0)
        {
            lines.listAppend(pluralise(l.turns_spent, "turn spent", "turns spent")); //lines_offscreen
        }
        if (lines.count() + lines_offscreen.count() > 0)
        {
            if (entries_displayed >= 1)
                buf.append(HTMLGenerateTagPrefix("hr", mapMake("style", "margin:0px;")));
            string div_class = "r_cl_modifier_inline";
            string div_style = "height:1.1em;padding-top:1px;padding-bottom:1px;";
            if (location_bar_location_name_is_centre_aligned)
                div_class += " r_centre";
            else
                div_style += "padding-left:" + __setting_indention_width + ";";
            buf.append(HTMLGenerateTagPrefix("div", mapMake("class", div_class, "style", div_style)));
            buf.append(lines.listJoinComponents(" - "));
            buf.append("</div>");
            if (lines_offscreen.count() > 0)
            {
                buf.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_modifier_inline", "style", "position:absolute;right:0px;top:0px;")));
                buf.append(lines_offscreen.listJoinComponents(" - "));
                buf.append("</div>");
            }
            entries_displayed += 1;
        }
    }
    if (false)
    {
        string [int] fl_entries;
        string [int] fl_entry_urls;
        string [int] fl_entry_styles;
        string [int] fl_entry_classes;
        float [int] fl_entry_width_weight;
        float [int] fl_entry_fixed_width_percentage;
        
        if (false && l.parentdesc != "" && l.parentdesc != "No Category" && l.parentdesc.to_lower_case() != l.to_lower_case())
            fl_entries.listAppend(l.parentdesc);
        
        /*Error err;
        if (!l.locationAvailable(err))
        {
            if (!err.was_error)
                fl_entries.listAppend("Inaccessible"); //doesn't make any sense unless we add that one feature
        }*/
        
        if (!__misc_state["in run"] && l.turns_spent > 0)
            fl_entries.listAppend(pluralise(l.turns_spent, "turn spent", "turns spent"));
        
        boolean all_entries_blank = true;
        foreach key, entry in fl_entries
        {
            if (entry != "")
                all_entries_blank = false;
        }
        if (fl_entries.count() > 0 && !all_entries_blank)
        {
            if (entries_displayed >= 1)
                buf.append(HTMLGenerateTagPrefix("hr", mapMake("style", "margin:0px;")));
            /*if (fl_entries.count() == 2)
            {
                fl_entry_styles[1] += "text-align:right;";
            }*/
            foreach key in fl_entries
                fl_entry_styles[key] += "height:1.25em;";
                
            fl_entry_styles[0] += "text-align:left;";
            fl_entry_styles[0] += "padding-left:" + __setting_indention_width + ";";
            if (fl_entries.count() > 1)
            {
                fl_entry_styles[fl_entries.count() - 1] += "text-align:right;";
                fl_entry_styles[fl_entries.count() - 1] += "padding-right:" + __setting_indention_width + ";";
            }
            buf.append(generateLocationBarTable(fl_entries, fl_entry_urls, fl_entry_styles, fl_entry_classes, fl_entry_width_weight, fl_entry_fixed_width_percentage, ""));
            entries_displayed += 1;
            
            //output_hr_override = true;
        }
        
    }
    
    //boolean output_hr_override = false;
    
    if (entries_displayed == 0)
        return "".to_buffer();
    buf.append(HTMLGenerateTagSuffix("div"));
    //if (output_hr_override)
            //buf.append("<div style=\"position:absolute;bottom:-1px;min-height:2px;width:100%;z-index:10000;background:blue;\"></div>");
    buf.append(HTMLGenerateTagSuffix("div"));
    
    return buf;
}
