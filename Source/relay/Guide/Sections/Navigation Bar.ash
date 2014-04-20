buffer generateNavbar(Checklist [int] ordered_output_checklists)
{
    buffer navbar;
    navbar.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_bottom_outer_container", "style", "bottom:0px;")));
    navbar.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_bottom_inner_container", "style", "background:" + __setting_navbar_background_color + ";")));
    
    string [int] titles;
    foreach key in ordered_output_checklists
        titles.listAppend(ordered_output_checklists[key].title);
    
    if (titles.count() > 0)
    {
        int [int] each_width;
        //Calculate width of each title:
        if (__setting_navbar_has_proportional_widths)
        {
            int total_character_count = 0;
            foreach i in titles
            {
                string title = titles[i];
                int title_length = title.length();
                total_character_count += title_length;
            }
            if (total_character_count > 0)
            {
                foreach i in titles
                {
                    string title = titles[i];
                    float title_length = title.length();
                    
                    float calculating_value = (100.0 * title_length) / (to_float(total_character_count));
                    each_width[i] = floor(calculating_value);
                }					
            }
        }
        else
        {
            float remaining_width = 100.0;
            int number_done = 0;
            foreach i in titles
            {
                int shared_width = to_int(remaining_width / to_float(titles.count() - number_done));
                each_width[i] = shared_width;
                remaining_width -= shared_width;
                number_done += 1;
            }
        }
        boolean first = true;
        foreach i in titles
        {
            string title = titles[i];
            
            string onclick_javascript = "";
            
            //Cancel our usual link:
            onclick_javascript += "navbarClick(event,'" + HTMLConvertStringToAnchorID(title + " checklist container") + "')";
            
            navbar.append(HTMLGenerateTagPrefix("a", mapMake("class", "r_a_undecorated", "href", "#" + HTMLConvertStringToAnchorID(title), "onclick", onclick_javascript)));
            navbar.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_navbar_button_container", "style", "width:" + each_width[i] + "%;")));
            
            //Vertical separator:
            if (first)
                first = false;
            else if (!__setting_gray_navbar)
                navbar.append(HTMLGenerateDivOfClass("", "r_navbar_line_separator"));
            
            string text_div = HTMLGenerateDivOfClass(title, "r_navbar_text");
            if (__use_table_based_layouts)
            {
                //Vertical centering with tables:
                navbar.append("<table style=\"border-spacing:0px;margin-left:auto;margin-right:auto;height:100%;\"><tr><td style=\"vertical-align:middle;\">");
                navbar.append(text_div);
                navbar.append("</td></tr></table>");
            }
            else if (true)
            {
                //Vertical centering with divs:
                //Which is to... tell the browser to act like a table.
                //Sorry.
                navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", "padding-left:1px;padding-right:1px;margin-left:auto;margin-right:auto;display:table;height:100%;")));
                navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;vertical-align:middle;")));
                navbar.append(text_div);
                navbar.append("</div>");
                navbar.append("</div>");
            }
            else
            {
                //No vertical centering.
                navbar.append(text_div);
            }
            navbar.append("</div>");
            navbar.append("</a>");
        }
    }
    navbar.append("</div>");
    navbar.append("</div>");
    return navbar;
}