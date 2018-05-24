
void setUpCSSStyles()
{
	string body_style = "";
    if (!__setting_use_kol_css)
    {
        //Base page look:
        body_style += "font-family:Arial,Helvetica,sans-serif;background-color:white;color:black;";
        PageAddCSSClass("a:link", "", "color:black;", -10);
        PageAddCSSClass("a:visited", "", "color:black;", -10);
        PageAddCSSClass("a:active", "", "color:black;", -10);
    }
    if (__setting_side_negative_space_is_dark)
        body_style += "background-color:" + __setting_dark_colour + ";";
    else
        body_style += "background-color:#FFFFFF;";
    body_style += "margin:0px;padding:0px;font-size:14px;";
    
    if (__setting_ios_appearance)
        body_style += "font-family:'Helvetica Neue',Arial, Helvetica, sans-serif;font-weight:lighter;";
    
    PageAddCSSClass("body", "", body_style, -11);
    
    PageAddCSSClass("body", "", "font-size:13px;", -11, __setting_media_query_medium_size);
    PageAddCSSClass("body", "", "font-size:12px;", -11, __setting_media_query_small_size);
    PageAddCSSClass("body", "", "font-size:12px;", -11, __setting_media_query_tiny_size);
    
    
	PageAddCSSClass("", "r_clickable", "cursor:pointer;cursor:hand;");
	PageAddCSSClass("", "r_future_option", "color:" + __setting_unavailable_colour + ";");
	
    PageAddCSSClass("a", "r_cl_internal_anchor", "position:absolute;z-index:2;padding-top:" + __setting_navbar_height + ";display:inline-block;");
	
    PageAddCSSClass("", "r_button", "visibility:hidden;cursor:pointer;color:#7F7F7F;font-size:1.5em;z-index:3;position:absolute;"); //background:" + __setting_page_background_colour + ";
	
    PageAddCSSClass("div", "r_word_wrap_group", "display:inline-block;");
	
	if (true)
	{
		string hr_definition;
		hr_definition = "height: 1px; margin-top: 1px; margin-bottom: 1px; border: 0px; width: 100%;";
	
		hr_definition += "background: " + __setting_line_colour + ";";
		PageAddCSSClass("hr", "", hr_definition);
	}
	
	
    if (__setting_fill_vertical)
        PageAddCSSClass("div", "r_vertical_fill", "bottom:0;left:0;right:0;position:fixed;height:100%;margin-left:auto;margin-right:auto;");
    
    if (__setting_show_navbar)
    {
        PageAddCSSClass("div", "r_navbar_line_separator", "position:absolute;float:left;min-width:1px;min-height:" + __setting_navbar_height + ";background:" + __setting_line_colour + ";");
        PageAddCSSClass("div", "r_navbar_text", "text-align:center;font-weight:bold;font-size:.9em;");
        PageAddCSSClass("div", "r_navbar_button_container", "overflow:hidden;vertical-align:top;display:inline-block;height:" + __setting_navbar_height + ";");
        
        if (__setting_gray_navbar)
        {
            PageAddCSSClass("div", "r_navbar_line_separator", "display:none;");
            PageAddCSSClass("div", "r_navbar_text", "text-align:center;font-size:.9em;font-weight:normal;");
            PageAddCSSClass("div", "r_navbar_button_container", "overflow:hidden;vertical-align:top;display:inline-block;height:" + __setting_navbar_height + ";");
            __setting_navbar_background_colour = __setting_page_background_colour;
        }
    }
    PageAddCSSClass("div", "r_bottom_outer_container", "height:" + __setting_navbar_height + ";position:fixed;z-index:6;width:100%;overflow:hidden;");
    if (true)
    {
        //Second holding container:
        string style = "";
        int width = __setting_horizontal_width;
        if (!__setting_fill_vertical)
            width -= 2;
        
        style += "max-width:" + width + "px;margin-left:auto; margin-right:auto;font-size:1em;";
        style += "height:" + __setting_navbar_height + ";";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
            style += "border-left:1px solid;border-right:1px solid;";
        style += "border-top:1px solid;border-color:" + __setting_line_colour + ";";
        PageAddCSSClass("div", "r_bottom_inner_container", style);
    }
    //PageAddCSSClass("", "r_location_bar_table_entry", "vertical-align:middle;padding-left:0.5em;display:table-cell;");
    PageAddCSSClass("", "r_location_bar_table_entry", "vertical-align:middle;padding-left:0.5em;padding-right:0.5em;display:table-cell;");
    PageAddCSSClass("", "r_location_bar_ellipsis_entry", "overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:100%;");
    
    PageAddCSSClass("", "r_only_display_if_not_large", "");
    PageAddCSSClass("", "r_only_display_if_not_large", "display:none !important;", 0, __setting_media_query_large_size);
    
    PageAddCSSClass("", "r_only_display_if_not_medium", "");
    PageAddCSSClass("", "r_only_display_if_not_medium", "display:none !important;", 0, __setting_media_query_medium_size);
    
    PageAddCSSClass("", "r_only_display_if_not_tiny", "");
    PageAddCSSClass("", "r_only_display_if_not_tiny", "display:none !important;", 0, __setting_media_query_tiny_size);
    
    PageAddCSSClass("", "r_only_display_if_not_small", "");
    PageAddCSSClass("", "r_only_display_if_not_small", "display:none !important;", 0, __setting_media_query_small_size);
    
    PageAddCSSClass("", "r_only_display_if_small", "display:none !important;", 0, __setting_media_query_large_size);
    PageAddCSSClass("", "r_only_display_if_small", "display:none !important;", 0,__setting_media_query_medium_size);
    PageAddCSSClass("", "r_only_display_if_small", "", 0, __setting_media_query_small_size);
    PageAddCSSClass("", "r_only_display_if_small", "display:none !important;", 0,__setting_media_query_tiny_size);
    
    PageAddCSSClass("", "r_only_display_if_tiny", "display:none !important;", 0, __setting_media_query_large_size);
    PageAddCSSClass("", "r_only_display_if_tiny", "display:none !important;", 0,__setting_media_query_medium_size);
    PageAddCSSClass("", "r_only_display_if_tiny", "display:none !important;", 0, __setting_media_query_small_size);
    PageAddCSSClass("", "r_only_display_if_tiny", "", 0, __setting_media_query_tiny_size);
    
    
    PageAddCSSClass("", "r_do_not_display_if_media_queries_unsupported", "display:none;");
    PageAddCSSClass("", "r_do_not_display_if_media_queries_unsupported", "", 0, __setting_media_query_large_size);
    PageAddCSSClass("", "r_do_not_display_if_media_queries_unsupported", "", 0,__setting_media_query_medium_size);
    PageAddCSSClass("", "r_do_not_display_if_media_queries_unsupported", "", 0, __setting_media_query_small_size);
    PageAddCSSClass("", "r_do_not_display_if_media_queries_unsupported", "", 0, __setting_media_query_tiny_size);
    
    PageAddCSSClass("", "r_location_bar_background_blur", "background:rgba(255, 255, 255, 0.95);box-shadow:0px 0px 1px 2px rgba(255, 255, 255, 0.95);");
    PageAddCSSClass("", "r_location_bar_background_blur_small", "background:rgba(255, 255, 255, 0.95);box-shadow:0px 0px 0.5px 1px rgba(255, 255, 255, 0.95);");
    
    PageAddCSSClass("", "r_tooltip_outer_class", "border-bottom:1px dotted;border-color:" + __setting_line_colour + ";");//"position:relative;");
    PageAddCSSClass("", "r_tooltip_inner_class", "background:white;border-style:solid;border-color:" + __setting_line_colour + ";border-width:1px;padding-left:1em;padding-right:1em;padding-bottom:0.25em;padding-top:0.25em;position:absolute;opacity:0;transition:visibility 0s linear 0.25s, opacity 0.25s linear;visibility:hidden;margin-top:1.5em;z-index:1000");
    PageAddCSSClass("", "r_tooltip_inner_class_margin", "margin-top:-200px;");
    PageAddCSSClass("", "r_tooltip_outer_class:hover .r_tooltip_inner_class", "opacity:1;visibility:visible;transition-delay:0s;");
    //PageAddCSSClass("", "r_tooltip_inner_class_weve_had_one_yes_but_what_about_second_inner_class", "background:white;border-style:solid;border-color:black;border-width:1px;padding:1em;top:1.5em;");
    
    PageAddCSSClass("", "r_no_css_transition", "-webkit-transition:none !important;-moz-transition:none !important;-o-transition:none !important;-ms-transition:none !important;transition:none !important;");
    
    PageAddCSSClass("img", "", "border:0px;");
}
