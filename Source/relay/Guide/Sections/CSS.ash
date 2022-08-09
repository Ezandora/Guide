
void setUpCSSStyles()
{
	string body_style = "";
    if (!__setting_use_kol_css)
    {
        //Base page look:
        body_style += "font-family:Arial,Helvetica,sans-serif;background-color:var(--main_content_background_colour);color:var(--main_content_text_colour);";
        PageAddCSSClass("a:link", "", "color:var(--main_content_text_colour);", -10);
        PageAddCSSClass("a:visited", "", "color:var(--main_content_text_colour);", -10);
        PageAddCSSClass("a:active", "", "color:var(--main_content_text_colour);", -10);
    }
    if (__setting_side_negative_space_is_dark)
        body_style += "background-color:var(--dark_colour);";
    else
        body_style += "background-color:var(--main_content_background_colour);";
    body_style += "margin:0px;padding:0px;font-size:14px;";
    
    if (__setting_ios_appearance)
        body_style += "font-family:'Helvetica Neue',Arial, Helvetica, sans-serif;font-weight:lighter;";
    if (__setting_newstyle_navbars)
    	body_style += "overflow:hidden;";
    
    PageAddCSSClass("body", "", body_style, -11);
    
    PageAddCSSClass("body", "", "font-size:13px;", -11, __setting_media_query_medium_size);
    PageAddCSSClass("body", "", "font-size:12px;", -11, __setting_media_query_small_size);
    PageAddCSSClass("body", "", "font-size:12px;", -11, __setting_media_query_tiny_size);
    
    
    //PageAddCSSClass("body", "", "filter:brightness(85%) invert(1)  hue-rotate(180deg);", -11, "@media (prefers-color-scheme: dark)"); //welcome to moonside. disabled, because KOL is not dark mode
    
    
	PageAddCSSClass("", "r_clickable", "cursor:pointer;cursor:hand;user-select:none;-webkit-user-select:none;");
    PageAddCSSClass("", "r_clickable:hover", "background-color:var(--hover_alternate_colour);");
	PageAddCSSClass("", "r_future_option", "color:var(--unavailable_colour);");
	
    PageAddCSSClass("a", "r_cl_internal_anchor", "position:absolute;z-index:2;padding-top:" + __setting_navbar_height + ";display:inline-block;");
	
    PageAddCSSClass("", "r_button", "display:none;cursor:pointer;color:#7F7F7F;font-size:1.5em;");
	
    PageAddCSSClass("div", "r_word_wrap_group", "display:inline-block;");
	
	if (true)
	{
		string hr_definition;
		hr_definition = "height: 1px; margin-top: 1px; margin-bottom: 1px; border: 0px; width: 100%;";
	
		hr_definition += "background: var(--line_colour);";
		PageAddCSSClass("hr", "", hr_definition);
	}
	
	
    if (__setting_fill_vertical)
        PageAddCSSClass("div", "r_vertical_fill", "bottom:0;left:0;right:0;position:fixed;height:100%;margin-left:auto;margin-right:auto;");
    
    if (__setting_show_navbar)
    {
        PageAddCSSClass("div", "r_navbar_line_separator", "position:absolute;float:left;min-width:1px;min-height:" + __setting_navbar_height + ";background:var(--line_colour);");
        PageAddCSSClass("div", "r_navbar_text", "text-align:center;font-weight:bold;font-size:.9em;");
        PageAddCSSClass("div", "r_navbar_button_container", "overflow:hidden;vertical-align:top;display:inline-block;min-height:" + __setting_navbar_height + ";");
        
        if (__setting_gray_navbar)
        {
            PageAddCSSClass("div", "r_navbar_line_separator", "display:none;");
            PageAddCSSClass("div", "r_navbar_text", "text-align:center;font-size:.9em;font-weight:normal;");
            PageAddCSSClass("div", "r_navbar_button_container", "overflow:hidden;vertical-align:top;display:inline-block;min-height:" + __setting_navbar_height + ";");
            __setting_navbar_background_colour = __setting_page_background_colour;
        }
    }
    if (!__setting_newstyle_navbars)
    	PageAddCSSClass("div", "r_bottom_outer_container", "min-height:" + __setting_navbar_height + ";position:fixed;z-index:6;width:100%;overflow:hidden;");
    else
	    PageAddCSSClass("div", "r_bottom_outer_container", "min-height:" + __setting_navbar_height + ";width:100%;overflow:hidden;");
    if (true)
    {
        //Second holding container:
        string style = "";
        //int width = __setting_horizontal_width;
        //if (!__setting_fill_vertical)
            //width -= 2;
        
        style += "margin-left:auto; margin-right:auto;font-size:1em;"; //max-width:" + width + "px;
        style += "min-height:" + __setting_navbar_height + ";";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
            style += "border-left:1px solid;border-right:1px solid;";
        style += "border-top:1px solid;border-color:var(--line_colour);";
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
    
    PageAddCSSClass("", "r_tooltip_outer_class", "border-bottom:1px dotted;border-color:var(--line_colour);position:relative;");
    PageAddCSSClass("", "r_tooltip_inner_class", "background:var(--main_content_background_colour);border-style:solid;border-color:var(--line_colour);border-width:1px;padding-left:1em;padding-right:1em;padding-bottom:0.25em;padding-top:0.25em;position:absolute;opacity:0;transition:visibility 0s linear 0.25s, opacity 0.25s linear;visibility:hidden;margin-top:1.5em;z-index:1000;width:60vw;white-space:normal;box-shadow:0px 0px 0px 10000px rgba(0,0,0,0.5);"); //white-space:nowrap;
    PageAddCSSClass("", "r_tooltip_inner_class_margin", "margin-top:-200px;");
    PageAddCSSClass("", "r_tooltip_outer_class:hover .r_tooltip_inner_class", "opacity:1;visibility:visible;transition-delay:0s;");
    //PageAddCSSClass("", "r_tooltip_inner_class_weve_had_one_yes_but_what_about_second_inner_class", "background:var(--main_content_background_colour);border-style:solid;border-color:black;border-width:1px;padding:1em;top:1.5em;");
    
    PageAddCSSClass("", "r_no_css_transition", "-webkit-transition:none !important;-moz-transition:none !important;-o-transition:none !important;-ms-transition:none !important;transition:none !important;");
    
    
    
    PageAddCSSClass("img", "", "border:0px;mix-blend-mode:multiply;");
    


    PageAddCSSClass(":root", "",
    "--unavailable_colour:" + __setting_unavailable_colour + ";" +
    "--line_colour:" + __setting_line_colour + ";" +
    "--dark_colour:" + __setting_dark_colour + ";" +
    "--modifier_colour:" + __setting_modifier_colour + ";" +
    "--navbar_background_colour:" + __setting_navbar_background_colour + ";" +
    "--page_background_colour:" + __setting_page_background_colour + ";" +
    "--main_content_background_colour:" + __setting_main_content_background_colour + ";" +
    "--main_content_text_colour:" + __setting_main_content_text_colour + ";" +
    "--hover_alternate_colour:" + __setting_hover_alternate_colour + ";"
    );
    if (true)
    {
        string style = "";
        style += "padding-top:5px;padding-bottom:0.25em;"; //max-width:" + max_width_setting + "px;
        if (true)//!__setting_fill_vertical) //FIXME investigate
            style += "background-color:var(--page_background_colour);";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
        {
            style += "border:1px solid;border-top:0px;border-bottom:1px solid;";
            style += "border-color:var(--line_colour);";
        }
    	PageAddCSSClass("", "r_main_holding_container", style);
    }
    if (false)
    {
    	//Dark mode override:
        //doesn't work in gecko
        
        PageAddCSSClass(":root", "",
        "--unavailable_colour:" + __setting_unavailable_colour_dark + ";" +
        "--line_colour:" + __setting_line_colour_dark + ";" +
        "--dark_colour:" + __setting_dark_colour_dark + ";" +
        "--modifier_colour:" + __setting_modifier_colour_dark + ";" +
        "--navbar_background_colour:" + __setting_navbar_background_colour_dark + ";" +
        "--page_background_colour:" + __setting_page_background_colour_dark + ";" +
        "--main_content_background_colour:" + __setting_main_content_background_colour_dark + ";" +
    	"--main_content_text_colour:" + __setting_main_content_text_colour_dark + ";" +
    	"--hover_alternate_colour:" + __setting_hover_alternate_colour_dark + ";"
        ,1, "@media (prefers-color-scheme: dark)");
        
     	//PageAddCSSClass("body", "", "color:white;", 1, "@media (prefers-color-scheme: dark)");
        PageAddCSSClass("", "r_clickable:hover", "background-color:" + "#444444" + ";", 1, "@media (prefers-color-scheme: dark)");
     
     	//FIXME are these correct?
    	PageAddCSSClass("", "r_location_bar_background_blur", "background:rgba(13, 13, 13, 1.0);box-shadow:0px 0px 1px 2px rgba(13, 13, 13, 1.0);", 1, "@media (prefers-color-scheme: dark)");
    	PageAddCSSClass("", "r_location_bar_background_blur_small", "background:rgba(13, 13, 13, 1.0);box-shadow:0px 0px 0.5px 1px rgba(13, 13, 13, 1.0);", 1, "@media (prefers-color-scheme: dark)");
        
        
        //Highlight gradient:
        string highlight_colour = __setting_dark_colour_dark; //"#0F0F0F";
        string dark_container_gradient = "background: #000000;background: -moz-linear-gradient(left, #000000 50%, " + highlight_colour + " 75%, " + highlight_colour + " 100%);background: -webkit-gradient(linear, left top, right top, color-stop(50%,#000000), color-stop(75%," + highlight_colour + "), color-stop(100%," + highlight_colour + "));background: -webkit-linear-gradient(left, #000000 50%," + highlight_colour + " 75%," + highlight_colour + " 100%);background: -o-linear-gradient(left, #000000 50%," + highlight_colour + " 75%," + highlight_colour + " 100%);background: -ms-linear-gradient(left, #000000 50%," + highlight_colour + " 75%," + highlight_colour + " 100%);background: linear-gradient(to right, #000000 50%," + highlight_colour + " 75%," + highlight_colour + " 100%);filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#000000', endColorstr='" + highlight_colour + "',GradientType=1 );"; //help
        PageAddCSSClass("div", "r_cl_l_container_highlighted", dark_container_gradient);
    	/*
    	PageAddCSSClass("", "r_main_holding_container", "background-color:" + __setting_page_background_colour_dark + ";", 1, "@media (prefers-color-scheme: dark)");
    	PageAddCSSClass("", "r_cl_header_clicked", "background-color:" + __setting_line_colour_dark + ";", 1, "@media (prefers-color-scheme: dark)"); //line
    	PageAddCSSClass("div", "r_cl_l_left_showhide_clicked", "background-color:" + __setting_line_colour_dark + ";", 1, "@media (prefers-color-scheme: dark)");
     
     
     
    	
     	*/
        if (false)
        {
        	//Approach 1: Give a vertical white section
        	PageAddCSSClass("", "r_cl_l_left", "background-color:white;", 1, "@media (prefers-color-scheme: dark)");
        }
        else if (true)
        {
        	//Approach two: invert all images.
        	PageAddCSSClass("img", "", "filter:invert(1);mix-blend-mode:lighten;");
         	//PageAddCSSClass("", "r_resource_bar_image", "mix-blend-mode:lighten !important;", 1, "@media (prefers-color-scheme: dark)");
             PageAddCSSClass("div", "r_cl_l_container_minimised:hover", "background-color:var(--hover_alternate_colour);mix-blend-mode:lighten;");
        }
     
    }
}
