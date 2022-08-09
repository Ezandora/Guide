buffer generateNavbar(Checklist [int] ordered_output_checklists)
{
    buffer navbar;
    
    string outer_style;
    if (!__setting_newstyle_navbars)
    	outer_style = "bottom:0px;";
    else
    	outer_style += "position:relative;z-index:6;";
    navbar.HTMLAppendTagPrefix("div", mapMake("id", "navigation_bar_outer_container", "class", "r_bottom_outer_container", "style", outer_style));
    navbar.HTMLAppendTagPrefix("div", "class", "r_bottom_inner_container", "style", "background:var(--navbar_background_colour);");
    
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
            
            navbar.HTMLAppendTagPrefix("a", mapMake("class", "r_a_undecorated", "href", "#" + HTMLConvertStringToAnchorID(title), "onclick", onclick_javascript));
            navbar.HTMLAppendTagPrefix("div", "class", "r_navbar_button_container", "style", "width:" + each_width[i] + "%;");
            
            //Vertical separator:
            if (first)
                first = false;
            else if (!__setting_gray_navbar)
                navbar.HTMLAppendDivOfClass("", "r_navbar_line_separator");
            
            string text_div = HTMLGenerateDivOfClass(title, "r_navbar_text");
            if (__use_table_based_layouts)
            {
                //Vertical centring with tables:
                navbar.append("<table style=\"border-spacing:0px;margin-left:auto;margin-right:auto;height:100%;\"><tr><td style=\"vertical-align:middle;\">");
                navbar.append(text_div);
                navbar.append("</td></tr></table>");
            }
            else if (true)
            {
                //Vertical centring with divs:
                //Which is to... tell the browser to act like a table.
                //Sorry.
                navbar.HTMLAppendTagPrefix("div", "style", "padding-left:1px;padding-right:1px;margin-left:auto;margin-right:auto;display:table;height:100%;min-height:" + __setting_navbar_height_in_em + "em;");
                navbar.HTMLAppendTagPrefix("div", "style", "display:table-cell;vertical-align:middle;");
                navbar.append(text_div);
                navbar.append("</div>");
                navbar.append("</div>");
            }
            else
            {
                //No vertical centring.
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
