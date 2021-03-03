boolean __setting_resource_intra_text = true;

buffer generateResourceBar(Checklist [int] ordered_output_checklists)
{
	buffer bar;
	
    if (!playerIsLoggedIn())
        return bar;
    
    
    //Info container:
    //Use position:absolute in case the info container is too tall for the window.
    bar.append("<div style=\"position:relative;\">");
    bar.append("<div style=\"position:absolute;bottom:0px;width:100%;\">");
    //unused:
    //bar.append("<div style=\"width:100%;height:20px;opacity:0.0;\" id=\"resource_bar_info_container_shadow\"></div>");
    //bar.append("<div style=\"width:100%;height:20px;background: linear-gradient(0deg, rgba(0,0,0,1) 0%, rgba(0,0,0,0) 100%);\" id=\"resource_bar_info_container_shadow\"></div>");
    //bar.append("<div style=\"width:100%;height:20px;transition:opacity 0.25s;background-image:url(" + __importance_bar_gradient + ");background-repeat:repeat-x;transform:scaleY(-1);opacity:0.0;\" id=\"resource_bar_info_container_shadow\"></div>");
    
    
    bar.HTMLAppendTagWrap("div", "", mapMake("id", "r_location_popup_blackout_info_container", "class", "r_popup_blackout_class", "style", "z-index:1;"));
    
bar.append("<div style=\"background:white;width:100%;text-align:left;z-index:2;position:relative;display:flex;\" id=\"resource_bar_info_container\"></div>"); //display:none; //position:relative may break things?
    bar.append("</div>");
    bar.append("</div>");
    
    //Generate hide/show button:
    if (true)
    {
    	int size = 20; //30
    	bar.append("<div style=\"overflow:hidden;cursor:pointer;position:absolute;width:" + size + "px;height:" + size + "px;margin-top:-" + size + "px;font-size:" + (size - 2) + "px;font-weight:bold;color:" + __setting_line_colour + ";border-top:1px solid " + __setting_line_colour + ";background:white;border-right:1px solid " + __setting_line_colour + ";\" id=\"resource_bar_hide_show_button\" onclick=\"handleResourceBarClick();\">");
        bar.append("&nbsp;");
        bar.append("</div>");
    }
    //Setup:
    if (true)
    {
        //Holding containers:
        string style;
        style += "height:auto;";
        /*if (true)
            style += "bottom:" + (2 * __setting_navbar_height_in_em) + "em;";
        else
            style += "bottom:" + __setting_navbar_height + ";";*/
        
        style += "max-height:33vh;"; //overflow-y:auto; tends to show up for like one pixel. there should be a way to set a minimum threshold - one pixel doesn't matter
        //style += "transition:height 0.25s;";
        style += "transition:max-height 0.5s;";
        style += "width:100%;";
        style += "z-index:2;position:relative;";
        string onmouseenter_code;
        string onmouseleave_code;
        
            
        string [string] outer_containiner_map = mapMake("class", "", "style", style, "id", "resource_bar_outer_container");
        bar.HTMLAppendTagPrefix("div", outer_containiner_map);
        
        string [string] inner_containiner_map = mapMake("id", "resource_bar_inner_container", "class", "r_bottom_inner_container", "style", "height:auto;text-align:right;background-color:white;"); //text-align right so consumption is always bottom-right //text-align:right;
        if (onmouseenter_code != "")
            inner_containiner_map["onmouseenter"] = onmouseenter_code;
        if (onmouseleave_code != "")
            inner_containiner_map["onmouseleave"] = onmouseleave_code;
        bar.HTMLAppendTagPrefix("div", inner_containiner_map);
    }
    //Core
    
    //bar.append("stuff lol");
    boolean [string] seen_image_lookup_names_hack;
    
    
    boolean [string] tags_we_pay_attention_to = $strings[banish,free banish,daily free fight,free instakill,buff,consumption junction\, what's your function?];
    
    float [string] category_priority = {
    "":-100000,
    "consumption junction, what's your function?":-100001,
    "free instakill":120,
    "banish":109,
    "free banish":110,
    "daily free fight":100,
    "familiar":200, //fitts law this one, always upper-left
    "iotm":-9,
    "equipment":-10,
    "skill":-20,
    "combat skill":-20,
    "buff":-30,
    };
    
    //ran these choices through a deuteranomaly filter; instakills/banishes/daily free fights look like different intensities of the same colour, which is appropriate since they are very similar concepts. equipment and familiars are off somewhere else.
    //I am open to suggestions to better choices
    int [string] category_hardcoded_hues = {
    "free instakill":200,
    "banish":200 + 45,
    "free banish":200 + 45,
    "daily free fight":200 + 45*2,
    "iotm":70, //intentionally similar to equipment
    "equipment":60, //90
    "familiar":90+45,//200 + 240,
    "skill":30,
    "combat skill":30,
    "buff":30, //basically the same as skill
    };
    
    boolean [string] categories_to_not_flex = {"consumption junction, what's your function?":true};
    string [string] category_hardcoded_colours = {
    "consumption junction, what's your function?":"#FFFFFF",
    };
    
    string [string] shortened_category_names = 
    {
    	"familiar":"familiars",
    	"free instakill":"instakills",
    	"banish":"banishes",
        "free banish":"free banishes",
    	"equipment":"iotms",
    	"daily free fight":"fights",
    	"skill":"skills",
        "combat skill":"combat skills",
    	"buff":"buffs",
        "consumption junction, what's your function?":"nom noms",
    };
    
    string [string] readable_category_names = 
    {
    	"familiar":"Familiars",
    	"free instakill":"Free instakills",
    	"banish":"Banishes",
        "free banish":"Free Banishes",
    	"equipment":"Equipment",
    	"daily free fight":"Free fights",
    	"skill":"Skills",
        "combat skill":"Combat Skills",
    	"buff":"Buffs",
        "consumption junction, what's your function?":"Nom noms",
    };
    
    if (true)
    {
    	//debugging:
        foreach category, hue in category_hardcoded_hues
        {
            while (hue >= 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;
            category_hardcoded_hues[category] = hue;
        }
    }
        //hues I like: 340, 245, 93, 193
    
    ChecklistEntry [string][int] output_entries;
    int total_entry_count = 0;
    foreach key, checklist in ordered_output_checklists
    {
    	//bar.append(checklist.title + ", ");
        if (checklist.title != "Resources") continue;
		sort checklist.entries by value.importance_level; //FIXME better
        foreach key2, entry in checklist.entries
        {
        	string category = "";
         
         	//Various categories.
          
            if (entry.image_lookup_name.contains_text("__familiar") && category == "") //FIXME do not if shortdesc is empty
            	category = "familiar";
            if (entry.image_lookup_name.contains_text("__skill") && category == "")
            	category = "skill";
            
            //FIXME unify with kolimage
            if (entry.image_lookup_name.stringHasPrefix("__item "))
            {
                item it = entry.image_lookup_name.substring(7).to_item();
                if (it != $item[none])
                {
                	if ($slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3] contains it.to_slot() && !($items[disco ball,observational glasses,inflatable duck,genie's turbane,insane tophat] contains it))
                    {
                    	if (!it.tradeable || it.historical_price() >= 10000000) //probably IOTM
	                 	   category = "equipment";
                    }
                }
                //if (it.combat) //only found double-ice in casual
                	//category = "combat item";
            }
            
         
         	if (entry.category != "")
            	category = entry.category;
         	//only combine things that are universal; we also use the tagging system for like, specific IOTMs
            if (entry.combination_tag != "" && tags_we_pay_attention_to[entry.combination_tag])
            	category = entry.combination_tag;
            
            if (category == "blank")
            	category = "";
            
            
            if (category == "" && false)
            	print_html("handle \"" + entry.image_lookup_name + "\"");
         
            if (!(output_entries contains category))
            	 output_entries[category][0] = entry;
            else
	        	output_entries[category].listAppend(entry);
            total_entry_count += 1;
        }
    }
    
    if (total_entry_count <= 0)
    {
    	buffer blank;
    	return blank;
    }
    
    string [int] category_order;
    
    foreach category in output_entries
    {
    	category_order.listAppend(category);
    }
    sort category_order by -category_priority[value];
    
    bar.append("<div id=\"flex_capacitor\" style=\"display:flex;flex-flow:row wrap;align-items:stretch;\">"); //flexbox
    //justify-content:flex-end;
    //justify-content:space-between;
    
    boolean setting_weird_flex = true;
    if (setting_weird_flex)
    {
    	//use media queries to adjust flex basis
        //I assume there's a "better" way to do this with columns? but it's hot out and I want something that works
        //maybe later
        //update: this was a terrible idea, do not
        
        bar.HTMLAppendTagPrefix("style", "type", "text/css");
        int last_minimum_width = total_entry_count * 30;
        //We go through each possibility of row counts.
        //Like if we only have one row of icons, two rows, three rows, etc.
        //Then we compute the width this would be, the entries per row, and set up media queries so CSS auto-adjusts the boxes so they are spaced evenly.
        //FIXME properly support this with regard to it not mattering anyways. How do we compute that...?
        //after 8, we reach the 1080p 33% limit
        for row_count from 1 to 8
        {
            int entries_per_row = ceiling(to_float(total_entry_count) / to_float(row_count));
            
            if (entries_per_row == 0) continue;
            string max_width_css = (100.0 / to_float(entries_per_row)) + "%";
            float percentage = to_float(row_count) / to_float(total_entry_count) * 100.0;
        	int minimum_width_for_this_row_count = entries_per_row * 30;
            
            
            //from past attempts:
            /*int suggested_pixel_size = 30;
            int total_available_width = minimum_width_for_this_row_count * row_count;
            int total_available_width_last = last_minimum_width * row_count;
            int max_suggested_pixel_size = MAX(30, ceiling(to_float(minimum_width_for_this_row_count) / to_float(entries_per_row)));*/
            
            
            //int max_suggested_pixel_size = MAX(30, floor(to_float(total_available_width_last - 1) / to_float(total_entry_count)));
            
            
            string media_query;
            if (row_count == 1)
            	media_query = "@media (min-width: " + minimum_width_for_this_row_count + "px)";
            else
            	media_query = "@media (min-width: " + minimum_width_for_this_row_count + "px) and (max-width: " + (last_minimum_width - 1) + "px)";
    		//PageAddCSSClass("div", "resource_entry", "flex-basis:" + suggested_pixel_size + "px", 0, media_query);
            //float percentage = 1.0 / to_float(entries_per_row) * 100.0;
            //percentage = to_float(total_entry_count - 1) / to_float(total_entry_count) * percentage; //slight wiggle room
            //percentage = 0.95 * percentage;
            
            
            //PageAddCSSClass("div", "resource_entry", "max-width:" + max_width + ";min-width:30px;flex-basis:" + percentage + "%;", 0, media_query);
            //we can't use the page's css classes, because those won't auto-update with our refreshing system
            bar.append(media_query);
            bar.append(" { ");
            bar.append("div.resource_entry {");
            bar.append("max-width:" + max_width_css + ";min-width:30px;flex-basis:" + percentage + "%;");
            bar.append(" } ");
            bar.append(" } ");
            
            
            //print_html(row_count + " minimum_width_for_this_row_count = " + minimum_width_for_this_row_count + " entries_per_row = " + entries_per_row + " max_suggested_pixel_size = " + max_suggested_pixel_size);
            //print_html(row_count + ", w= " + minimum_width_for_this_row_count + " tw = " + total_available_width + " max_suggested_pixel_size = " + max_suggested_pixel_size + " tec = " + total_entry_count + " percentage = " + percentage + "%");
      
            last_minimum_width = minimum_width_for_this_row_count;
        }
        bar.append("</style>");
    }
    PageAddCSSClass("div", "resource_entry", "flex-basis:30px;"); //base
    
    boolean no_break_category_lines = false; //wastes quite a bit of space; do not enable
    int next_assigned_id = 1;
    foreach key0, category in category_order
    {
    	if (false)
	    	print_html("category = \"" + category + "\" priority = " + category_priority[category]);
        
        int hue = -1;
        if (category_hardcoded_hues contains category)
        	hue = category_hardcoded_hues[category];
        string background_colour = "#FFFFFF";
        string background_colour_intense = "#DDDDDD";
        string background_colour_faded_out_alpha = "#FFFFFF";
        string background_color_slightly_transparent = "rgba(255,255,255,0.9)";
        if (category != "")
        {
        	if (category_hardcoded_colours contains category)
            {
            	background_colour = category_hardcoded_colours[category];
            }
        	else if (hue != -1)
            {
		        background_colour = "hsl(" + hue + ",100%, 90%)"; //70%, 85%
                background_colour_intense = "hsl(" + hue + ",100%, 70%)";
                background_colour_faded_out_alpha = "hsla(" + hue + ",100%, 90%, 0.0)"; 
                background_color_slightly_transparent = "hsla(" + hue + ",100%, 90%, 90%)"; 
            }
            else
            {
		        background_colour = "#DDDDDD";
                background_colour_intense = "black";
                background_colour_faded_out_alpha = "rgba(221, 221, 221, 0.0)"; 
            }
        }
        //else
            //category_background_style = "background-color:#DDDDDD;";
        if (false)
        {
        	//Black and white mode:
            //Disabled because it turns into a sea of grey.
            background_colour = "#FFFFFF";
            background_colour_intense = "#DDDDDD";
            background_colour_faded_out_alpha = "#FFFFFF";
            background_color_slightly_transparent = "rgba(255,255,255,0.9)";
            if (key0 % 2 == 1)
            {
		        background_colour = "#DDDDDD";
                background_colour_intense = "black";
                background_colour_faded_out_alpha = "rgba(221, 221, 221, 0.0)"; 
            }
        }
        string category_background_style = "";
        if (background_colour != "")
            category_background_style = "background-color:" + background_colour + ";";
            
            
        
        boolean have_overall_div = no_break_category_lines;
        string overall_div_extra_style = "";
        if (category == "consumption junction, what's your function?" && false)
        {
        	have_overall_div = true;
            overall_div_extra_style = "float:right;";
        }
        if (have_overall_div)
	        bar.append("<div style=\"display:inline-block;" + overall_div_extra_style + "\">");
         
         
        if (false)
        {
        	//failed attempt at sideways headers
            string shortened = shortened_category_names[category];
            if (shortened == "") shortened = category;
            bar.append("<div style=\"display:inline-block;width:30px;font-size:0.8em;text-align:center;" + category_background_style + "\">"); //height:calc(30px + 1.4em);
            //bar.append("<div style=\"width:15px;background-color:white;z-index:20;display:inline-block;transform:rotate(90deg);transform-origin:0 0;\">"); //width:" + (shortened.length() * 0.5) + "em;
            //bar.append(shortened);
            //bar.append("</div>");
            bar.append("</div>");
        }
         
        if (false)
        	bar.append("<span style=\"width:100%;font-size:0.8em;\">" + category + "</span><br>"); //wastes too much vertical space, requires(?) bo break lines
    	foreach key, entry in output_entries[category]
        {
            string found_shortdesc;
            string scanning_string = entry.subentries[0].header;
            if (entry.short_description != "")
            	found_shortdesc = entry.short_description;
            if (found_shortdesc == "" && scanning_string.contains_text(" to "))
            	found_shortdesc = scanning_string.group_string("([0-9]+ to [0-9]+)")[0][1].replace_string(" to ", "-");
            if (found_shortdesc == "")
	        	found_shortdesc = scanning_string.group_string("([~+-]*[0-9]+[,-]*[0-9]*[^ ]*) ")[0][1]; //[^\\(]* //allow commas
            if (entry.short_description == "blank")
            	found_shortdesc = "";

            //found_shortdesc = entry.subentries[0].header + " (" + found_shortdesc + ")";
            
            //if (found_shortdesc == "")
            	//found_shortdesc = entry.subentries[0].header.group_string("([^ ]+)")[0][1]; 
            
        	if (false && seen_image_lookup_names_hack[entry.image_lookup_name] && found_shortdesc == "") continue;
            
            string extra_style;
            if (entry.should_highlight)
            {
            	//extra_style += "box-sizing: border-box; border:1px solid black;";
                extra_style += "background: linear-gradient(to right, " + background_colour + " 0%," + background_colour_intense + " 100%);";
            }
            string float_direction = "left";
            
            int flex_grow = 1;
            if (categories_to_not_flex[category] && false) //incompatible with media queries
            	flex_grow = 0;
            string display_style = "display:inline-block;float:" + float_direction + ";";
            if (__setting_resource_intra_text)
	            display_style += "height:30px;position:relative;";
            else
	            display_style += "height:calc(30px + 1.2em);";
            display_style += "text-align:left;flex-grow:" + flex_grow + ";text-align:center;"; //width:30px;
            //flex-basis:30px;
            if (true)
            {
            	//justify-content:space-around;
            	//display_style = "display:flex;flex-flow:row wrap;flex-basis:30px;";
                //display_style = "flex-basis:30px;";
            	//display_style = "display:flex;flex-grow:1;flex-flow:row wrap;flex-basis:30px;align-items:flex-start;align-content:stretch;justify-content:space-around;";
            }
            //displayResourceBarPopupFor
            int this_resource_id = next_assigned_id; next_assigned_id += 1;
            entry.internal_processing_data["content_id"] = this_resource_id;
            foreach key2 in entry.subentries
            {
            	entry.internal_processing_data_subentry_content_id[key2] = this_resource_id;
            }
            
            string font_size = "1.0em"; //"0.8em";
            
            string [string] main_element_div_map = mapMake("style", display_style + "font-weight:bold;font-size:" + font_size + ";" + category_background_style + extra_style, "class", "resource_entry", "onmouseover", "displayResourceBarPopupFor(this);", "onmouseout", "cancelResourceBarPopup();");
            
            main_element_div_map["data-resource-id"] = this_resource_id;
            main_element_div_map["data-background-colour"] = background_colour;
            main_element_div_map["data-background-colour-faded-out-alpha"] = background_colour_faded_out_alpha;
            main_element_div_map["data-readable-category-name"] = readable_category_names[category];
            
            
            bar.HTMLAppendTagPrefix("div", main_element_div_map); 
            
        	//bar.append("<div style=\"" + display_style + "font-size:0.8em;" + category_background_style + extra_style + "\" class=\"resource_entry\">");
             //bar.append("<div style=\"" + display_style + "\">");
         
            if (entry.url != "")
            {
                string anchor_prefix_html = HTMLGenerateTagPrefix("a", mapMake("target", "mainpane", "href", entry.url, "class", "r_a_undecorated"));
                bar.append(anchor_prefix_html);
            }
         
         	//display:flex;flex-direction:column;flex-grow:1;flex-wrap:wrap;flex-basis:30px;
             //height:calc(30px + 0.8em);
         	//class=\"r_cl_l_container_highlighted\"
         
         	boolean enable_all_absolute_hack = false;
            if (enable_all_absolute_hack)
            {
                bar.append("<div style=\"position:relative;display:inline-block;vertical-align:top;\">");
                bar.append("<div style=\"position:absolute;display:inline-block;\">");   
         	}
            if (key == 0 && category != "")
            {
            	string shortened = shortened_category_names[category];
                if (shortened == "") shortened = category;
                bar.append("<div style=\"position:relative;display:inline;font-size:1.0em;font-weight:bold;visibility:hidden;\" id=\"category_" + key0 + "\">");
                bar.append("<div style=\"position:absolute;left:0px;top:calc(15px - 0.5em - 1px);background-color:white;z-index:20;padding:2px 2px 2px 2px;\">"); //width:" + (shortened.length() * 0.5) + "em;
                bar.append(shortened);
                bar.append("</div>");
                bar.append("</div>");
            }
            
            string image_name = entry.image_lookup_name;
            buffer image_cancel_html;
            if (entry.specific_image != "")
            {
            	image_name = entry.specific_image;
                if (false)
                {
                	//"tagging" - doesn't look good. we intentionally gave it a background but that looks worse
                    bar.append("<div style=\"position:relative;display:inline-block;\">");
                    bar.append("<div style=\"z-index:2;display:inline-block;position:absolute;left:15px;top:15px;" + category_background_style + "\">");
                    bar.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, Vec2iMake(15, 15), "", "mix-blend-mode:multiply;"));
                    bar.append("</div>");
                    image_cancel_html.append("</div>"); //position:relative
                }
            }
        	string image_html = KOLImageGenerateImageHTML(image_name, true, Vec2iMake(30, 30), "", "display:inline-block;mix-blend-mode:multiply;"); //float:left;
            bar.append(image_html);
            bar.append(image_cancel_html);
            
            
            
            if (found_shortdesc == "" && !__setting_resource_intra_text)
            	found_shortdesc = "&nbsp;";
            if (found_shortdesc != "")
            {
            	/*if (__setting_resource_intra_text)
                {
                	bar.append("<div style=\"position:relative;bottom:0px;\">");
                    bar.append(found_shortdesc);
                    bar.append("</div>");
                }*/
                
                string main_style = "display:inline-block;margin:0 0 0 0;width:100%;text-align:center;";
                if (__setting_resource_intra_text)
                {
                	main_style = "position:absolute;bottom:0px;";
                    if (false)
                    {
                    	main_style += "background:" + background_color_slightly_transparent + ";";
                    }
                    else
                    {
                    	main_style += "background:" + background_colour + ";";
                    }
                    string [int] font_size_for_character_count = {
                    1:"1.2em",
                    2:"1.2em",
                    3:"0.9em",
                    4:"0.85em",
                    5:"0.8em",
                    6:"0.8em",
                    7:"0.8em",
                    };
                    
                    int character_length = found_shortdesc.length();
                    if (font_size_for_character_count contains character_length)
                    {
                    	main_style += "font-size:" + font_size_for_character_count[character_length] + ";"; 
                    }
                    
                    if (false)
                    {
                    	//first appearance:
                    	main_style += "width:100%;";//text-align:right;";
                    }
                    else
                    {
                    	//second, right-aligned:
                        main_style += "right:0px;";
                        //main_style += "padding-left:0.2em;padding-top:0.1em;padding-right:0.1em;";
                        //main_style += "padding-left:0.3em;padding-top:0.2em;padding-right:0.1em;"; //rectangle
                        main_style += "padding-left:0.2em;padding-top:0.1em;padding-right:0.1em;border-radius:30%;"; //circle
                        
                    }
                }
            	bar.append("<div style=\"" + main_style + "\">");
                //bar.append("<center style=\"font-size:0.8em;color:black;\">"); //margin-top:-3px;
                //bar.append("<span style=\"margin-top:-13px;display:inline;\">");
                
                boolean relative_enabled = false;
                if (relative_enabled)
                {
                    bar.append("<div style=\"position:relative;display:inline-block;\">&nbsp;");
                    bar.append("<div style=\"position:absolute;display:inline-block;\">");
                }
            	bar.append(found_shortdesc);
                if (relative_enabled)
                {
                    bar.append("</div>");
                    bar.append("</div>");
                }
                
                //Small images don't "work" because they mix-blend into the darkness of the image.
                if (false && entry.specific_image != "")
                {
                    bar.append("<div style=\"position:relative;display:inline-block;\">");
                    bar.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, Vec2iMake(15, 15), "", "position:absolute;bottom:-3px;"));
                    bar.append("</div>");
                }
                //bar.append("</span>");
            	//bar.append("</center>");
                bar.append("</div>");
            }
            if (enable_all_absolute_hack)
            {
                bar.append("</div>");
                bar.append("</div>");
         	}
            if (entry.url != "")
                bar.append("</a>");
            bar.append("</div>");
         	seen_image_lookup_names_hack[entry.image_lookup_name] = true;   
        }
        if (have_overall_div)
        	bar.append("</div>");
        //if (category_order contains (key0 + 1))
	        //bar.append("|");
        //if (category_order contains (key0 + 1))
        	//bar.append("<div style=\"width:30px;height:calc(30px + 0.8em);display:inline-block;\"></div>");
    }
    bar.append("</div>"); //flexbox
    
    //if (no_break_category_lines)
	    //bar.append("<div style=\"float:none;\"></div>");
        
    bar.append("</div>");
    bar.append("</div>");
    return bar;
}
