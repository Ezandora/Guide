import "relay/Guide/Settings.ash"
import "relay/Guide/Support/Counter.ash"
import "relay/Guide/State.ash"
import "relay/Guide/Missing Items.ash"
import "relay/Guide/Support/Math.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Tasks.ash"
import "relay/Guide/Limit Mode/Spelunking.ash"
import "relay/Guide/Daily Resources.ash"
import "relay/Guide/Strategy.ash"
import "relay/Guide/Sections/Messages.ash"
import "relay/Guide/Sections/Checklists.ash"
import "relay/Guide/Sections/Location Bar.ash"
import "relay/Guide/Sections/API.ash"
import "relay/Guide/Sections/Navigation Bar.ash"
import "relay/Guide/Sections/Tests.ash"
import "relay/Guide/Sections/CSS.ash"


void runMain(string relay_filename)
{
    __relay_filename = relay_filename;

	string [string] form_fields = form_fields();
	if (form_fields["API status"].length() > 0)
	{
        write(generateAPIResponse().to_json());
        return;
	}
    
	boolean output_body_tag_only = false;
	if (form_fields["body tag only"].length() > 0)
	{
		output_body_tag_only = true;
	}
	
	if (__setting_debug_mode && __setting_debug_enable_example_mode_in_aftercore && get_property_boolean("kingLiberated"))
	{
		__misc_state["Example mode"] = true;
	}
	
    
    locationCompatibilityInit();
	PageInit();
	ChecklistInit();
	setUpCSSStyles();
	
	
	Checklist [int] ordered_output_checklists;
	generateChecklists(ordered_output_checklists);
	
    string guide_title = "Guide";
	
	PageSetTitle(guide_title);
	
    if (__setting_use_kol_css)
        PageWriteHead(HTMLGenerateTagPrefix("link", mapMake("rel", "stylesheet", "type", "text/css", "href", "/images/styles.css")));
        
    PageWriteHead(HTMLGenerateTagPrefix("meta", mapMake("name", "viewport", "content", "width=device-width")));
	
	
    if (__relay_filename == "relay_Guide.ash")
        PageSetBodyAttribute("onload", "GuideInit('relay_Guide.ash'," + __setting_horizontal_width + ");");
    //We don't give the javascript __relay_filename, because it's unsafe without escaping, and writing escape functions yourself is a bad plan.
    //So if they rename the file, automatic refreshing and opening in a new window is disabled.
    
    boolean displaying_navbar = false;
	if (__setting_show_navbar)
	{
		if (ordered_output_checklists.count() > 1)
			displaying_navbar = true;
	}
	if (displaying_navbar)
	{
        buffer navbar = generateNavbar(ordered_output_checklists);
        PageWrite(navbar);
	}
    
    if (__setting_show_location_bar)
    {
        buffer location_bar = generateLocationBar(displaying_navbar);
        PageWrite(location_bar);
    }
	

	int max_width_setting = __setting_horizontal_width;
	
	PageWrite(HTMLGenerateTagPrefix("div", mapMake("class", "r_centre", "style", "max-width:" + max_width_setting + "px;"))); //centre holding container
	
    
    
    
    if (true)
    {
        //Buttons.
        //position:absolute holding container, so we can absolutely position these:
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "position:absolute;" + "width:100%;max-width:" + max_width_setting + "px;")));
        
        string [string] base_image_map;
        base_image_map["width"] = "12";
        base_image_map["height"] = "12";
        base_image_map["class"] = "r_button";
        
        string [string] image_map = mapCopy(base_image_map);
        image_map["src"] = __close_image;
        image_map["onclick"] = "buttonCloseClicked(event)";
        image_map["style"] = "left:5px;top:5px;";
        image_map["id"] = "button_close_box";
        image_map["alt"] = "Close";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        
        image_map = mapCopy(base_image_map);
        image_map["src"] = __new_window_image;
        image_map["id"] = "button_new_window";
        image_map["onclick"] = "buttonNewWindowClicked(event)";
        image_map["style"] = "right:5px;top:5px;";
        image_map["alt"] = "Open in new window";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        image_map = mapCopy(base_image_map);
        image_map["src"] = __left_arrow_image;
        image_map["id"] = "button_arrow_right_left";
        image_map["onclick"] = "buttonRightLeftClicked(event)";
        image_map["style"] = "right:5px;top:30px;";
        image_map["alt"] = "Show chat pane";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        image_map = mapCopy(base_image_map);
        image_map["src"] = __right_arrow_image;
        image_map["id"] = "button_arrow_right_right";
        image_map["onclick"] = "buttonRightRightClicked(event)";
        image_map["style"] = "right:5px;top:30px;";
        image_map["alt"] = "Hide chat pane";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        PageWrite("</div>");
    }
    
    if (true)
    {
        //Holding container:
        string style = "";
        style += "max-width:" + max_width_setting + "px;padding-top:5px;padding-bottom:0.25em;";
        if (!__setting_fill_vertical)
            style += "background-color:" + __setting_page_background_colour + ";";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
        {
            style += "border:1px solid;border-top:0px;border-bottom:1px solid;";
            style += "border-color:" + __setting_line_colour + ";";
        }
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
    
	PageWrite(HTMLGenerateSpanOfStyle("Guide", "font-weight:bold; font-size:1.5em"));
	
	outputChecklists(ordered_output_checklists);
	
    
    if (true)
    {
        //Gray text at the bottom:
        string line;
        line = HTMLGenerateTagWrap("span", "<br>Automatic refreshing disabled.", mapMake("id", "refresh_status"));
        line += HTMLGenerateTagWrap("a", "<br>Written by Ezandora.", generateMainLinkMap("showplayer.php?who=1557284"));
        line += "<br>" + __version;
        
        PageWrite(HTMLGenerateDivOfStyle(line, "font-size:0.777em;color:gray;"));
        
        if (true)
        {
            //Hacky layout, sorry:
            string [string] image_map;
            image_map["width"] = "12";
            image_map["height"] = "12";
            image_map["class"] = "r_button";
            image_map["src"] = __refresh_image;
            image_map["id"] = "button_refresh";
            image_map["onclick"] = "document.location.reload(true)";
            image_map["style"] = "position:relative;top:-12px;right:3px;";
            image_map["alt"] = "Refresh";
            image_map["title"] = image_map["alt"];
            PageWrite(HTMLGenerateDivOfStyle(HTMLGenerateTagPrefix("img", image_map), "max-height:0px;width:100%;text-align:right;"));
        }
    }
    
	PageWrite("</div>");
	PageWrite("</div>");
	if (displaying_navbar) //in-div spacing at bottom for navbar
		PageWrite(HTMLGenerateDivOfStyle("", "height:" + (__setting_navbar_height_in_em - 0.05) + "em;"));
    if (__setting_show_location_bar) //in-div spacing at bottom for location bar
		PageWrite(HTMLGenerateDivOfStyle("", "height:" + (__setting_navbar_height_in_em - 0.05) + "em;"));
    
    if (__setting_fill_vertical)
    {
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-1;background-color:" + __setting_page_background_colour + ";max-width:" + __setting_horizontal_width + "px;"))); //Color fill
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-11;border-left:1px solid;border-right:1px solid;border-color:" + __setting_line_colour + ";width:" + (__setting_horizontal_width) + "px;"))); //Vertical border lines, empty background
    }
    PageWriteHead("<script type=\"text/javascript\" src=\"relay_Guide.js\"></script>");
    
    
    if (output_body_tag_only)
    	write(__global_page.body_contents);
    else
		PageGenerateAndWriteOut();
}