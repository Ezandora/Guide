import "relay/Guide/Settings.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Support/IOTMs.ash"
import "relay/Guide/Sections/User Preferences.ash"
import "relay/Guide/Support/Statics.ash"
import "relay/Guide/Support/Statics 2.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Sections/Globals.ash"
import "relay/Guide/Sections/Data.ash"
import "relay/Guide/Support/Counter.ash"
import "relay/Guide/Support/Library 2.ash"
import "relay/Guide/State.ash"
import "relay/Guide/Missing Items.ash"
import "relay/Guide/Support/Math.ash"
import "relay/Guide/Tasks.ash"
import "relay/Guide/Limit Mode/Spelunking.ash"
import "relay/Guide/Daily Resources.ash"
import "relay/Guide/Strategy.ash"
import "relay/Guide/Sections/Messages.ash"
import "relay/Guide/Sections/Checklists.ash"
import "relay/Guide/Sections/Location Bar.ash"
import "relay/Guide/Sections/API.ash"
import "relay/Guide/Sections/Navigation Bar.ash"
import "relay/Guide/Sections/Resource Bar.ash"
import "relay/Guide/Sections/Tests.ash"
import "relay/Guide/Sections/CSS.ash"
import "relay/Guide/Items of the Month/Items of the Month import.ash"
import "relay/Guide/Paths/Paths import.ash"


void runMain()
{
	if (false)
	{
		//Minimal mode, for testing performance.
		write("you are ascending too slowly, ascend faster!"); return;
    }
    write(" "); //mafia will return a 404 if we write nothing (i.e. when setting user preferences). I suppose we should always write an API response or something
	string [string] form_fields = form_fields();
	//print_html("relay_Guide.ash, form_fields = " + form_fields.to_json()); 
	if (form_fields["API status"] != "")
	{
        string [string] api_response = generateAPIResponse();
        write(api_response.to_json());
        return;
	}
    
	boolean output_body_tag_only = false;
	if (form_fields["body tag only"] != "")
	{
		output_body_tag_only = true;
	}
    else if (form_fields["set user preferences"] != "")
    {
    	//In this case, every other key=value is set in our own preference tracking.
        //this design is kind of wonky, don't like it - the implicit "everything else"
        processSetUserPreferences(form_fields);
        return;
    }
    //else if (form_fields.count() > 0)
        //print_html("Form fields: " + form_fields.to_json());
	
    
    locationCompatibilityInit();
	PageInit();
	ChecklistInit();
	setUpCSSStyles();
	
	
	Checklist [int] ordered_output_checklists;
	generateChecklists(ordered_output_checklists);
	
    string guide_title = "Guide";
    if (limit_mode() == "batman")
        guide_title = "Bat-Guide";
	
	PageSetTitle(guide_title);
	
    if (__setting_use_kol_css)
        PageWriteHead(HTMLGenerateTagPrefix("link", mapMake("rel", "stylesheet", "type", "text/css", "href", "/images/styles.css")));
        
    PageWriteHead(HTMLGenerateTagPrefix("meta", mapMake("name", "viewport", "content", "width=device-width")));
	
	
	
	
	
	boolean resource_bar_open = PreferenceGetBoolean("resource bar open");
	string using_relay_filename = __relay_filename;
    if (__relay_filename.to_lower_case() == "relay_guide.ash")
    	using_relay_filename = __relay_filename;
	
	string guide_init_code = "GuideParachuteInit(); GuideInit('" + using_relay_filename + "'," + __setting_horizontal_width + "," + resource_bar_open + ", '" + __version + "');";
	
    PageSetBodyAttribute("onload", guide_init_code); //not escaped
    
    boolean drunk = $item[beer goggles].equipped_amount() > 0;
    
    if (drunk)
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "-webkit-filter:blur(4.0px) brightness(1.01);"))); //FIXME make this animated
        
    boolean buggy = (my_familiar() == $familiar[software bug] || $item[iShield].equipped_amount() > 0);
    if (buggy)
    {
        //Ideally we'd want to layer over a mosaic filter, giving a Cinepak look, but pixel manipulation techniques are limited in HTML.
        string chosen_font;
        //chosen_font = "'Comic Sans MS', cursive, sans-serif;"; //DO NOT USE
        //chosen_font = "'Courier New', Courier, monospace;";
        chosen_font = "'Helvetica Neue',Arial, Helvetica, sans-serif;font-weight:300;";
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "font-family:" + chosen_font)));
        //PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "")));
        //
    }
    
    buffer various_bar_buffer;
    boolean displaying_navbar = false;
	if (__setting_show_navbar)
	{
		if (ordered_output_checklists.count() > 1)
			displaying_navbar = true;
	}
	
    if (true)
    {
        buffer resource_bar = generateResourceBar(ordered_output_checklists);
        various_bar_buffer.append(resource_bar);
    }
    if (__setting_show_location_bar)
    {
        buffer location_bar = generateLocationBar(displaying_navbar);
        various_bar_buffer.append(location_bar);
    }
	if (displaying_navbar)
	{
        buffer navbar = generateNavbar(ordered_output_checklists);
        various_bar_buffer.append(navbar);
	}
    
    
    
    
    if (true)
    {
        //Buttons.
        //position:absolute holding container, so we can absolutely position these, absolutely:
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "position:absolute;" + "width:100%;"))); //max-width:" + max_width_setting + "px;"
        
        int button_size = 16;
        int vertical_button_spacing = button_size / 2;
        string [string] base_image_map;
        base_image_map["width"] = button_size;
        base_image_map["height"] = button_size;
        base_image_map["class"] = "r_button";
        
        
        //Left side:
        string [string] image_map = mapCopy(base_image_map);
        image_map["src"] = __close_image_data;
        image_map["onclick"] = "buttonCloseClicked(event)";
        image_map["style"] = "left:5px;top:5px;position:fixed;z-index:4;";
        image_map["id"] = "button_close_box";
        image_map["alt"] = "Close";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        PageWrite("</div>");
        
        
        string spacing_div = "<span style=\"width:1em;height:1px;\"> </span>";
        
        
        //Right side:
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "position:absolute;" + "right:20px;top:3px;z-index:5;")));
        
        image_map = mapCopy(base_image_map);
        image_map["src"] = __new_window_image_data;
        image_map["id"] = "button_new_window";
        image_map["onclick"] = "buttonNewWindowClicked(event)";
        //image_map["style"] = "right:5px;top:5px;";
        //image_map["style"] = "top:5px;right:" + (button_size * 2 + vertical_button_spacing * 1) + "px;";
        image_map["alt"] = "Open in new window";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        PageWrite(spacing_div);
        image_map = mapCopy(base_image_map);
        image_map["src"] = __left_arrow_image_data;
        image_map["id"] = "button_arrow_right_left";
        image_map["onclick"] = "buttonRightLeftClicked(event)";
        //image_map["style"] = "right:5px;top:30px;";
        //image_map["style"] = "top:5px;right:" + (button_size * 3 + vertical_button_spacing * 2) + "px;";
        image_map["alt"] = "Show chat pane";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        image_map = mapCopy(base_image_map);
        image_map["src"] = __right_arrow_image_data;
        image_map["id"] = "button_arrow_right_right";
        image_map["onclick"] = "buttonRightRightClicked(event)";
        //image_map["style"] = "right:5px;top:30px;";
        //image_map["style"] = "top:5px;right:" + (button_size * 3 + vertical_button_spacing * 2) + "px;";
        image_map["alt"] = "Hide chat pane";
        image_map["title"] = image_map["alt"];
        PageWrite(HTMLGenerateTagPrefix("img", image_map));
        
        
        
        if (true)
        {
        	PageWrite(spacing_div);
            image_map = mapCopy(base_image_map);
            image_map["src"] = __refresh_image_data;
            image_map["id"] = "button_refresh";
            image_map["onclick"] = "document.location.reload(true)";
            //image_map["style"] = "right:5px;top:5px;";
            //image_map["style"] = "top:5px;right:" + (button_size * 1 + vertical_button_spacing * 1) + "px;";
            image_map["alt"] = "Refresh";
            image_map["title"] = image_map["alt"];
            PageWrite(HTMLGenerateTagPrefix("img", image_map));
        }
        PageWrite("</div>");
    }
    
    
    if (__setting_newstyle_navbars)
    	__setting_fill_vertical = false;
    
    
    
    if (__setting_newstyle_navbars)
    {
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("class", "r_centre", "style", "display:flex;flex-direction:column;height:100vh;")));
    }
    if (!__setting_newstyle_navbars)
    	PageWrite(various_bar_buffer);
	

	int max_width_setting = __setting_horizontal_width;
	string main_holder_extra_style;
	if (__setting_newstyle_navbars)
		main_holder_extra_style = "flex-grow:1;flex-shrink:1;overflow-x:hidden;overflow-y:auto;";
    main_holder_extra_style += "width:100%;";
	
	
    
    
    
	PageWrite(HTMLGenerateTagPrefix("div", mapMake("id", "main_content_holder", "class", "r_centre", "style", main_holder_extra_style))); //centre holding container //"max-width:" + max_width_setting + "px;"
    if (true)
    {
        //Holding container:
        string style = "";
        style += "padding-top:5px;padding-bottom:0.25em;"; //max-width:" + max_width_setting + "px;
        if (!__setting_fill_vertical)
            style += "background-color:" + __setting_page_background_colour + ";";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
        {
            style += "border:1px solid;border-top:0px;border-bottom:1px solid;";
            style += "border-color:" + __setting_line_colour + ";";
        }
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
    if (true)
    {
    	//showhide mouseover popup:
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "position:relative;")));
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("id", "showhide_mouseover_popup", "class", "showhide_mouseover_popup_class" )));
        PageWrite("</div>"); //showhide_mouseover_popup container
    }
    
	PageWrite(HTMLGenerateSpanOfStyle(guide_title, "font-weight:bold; font-size:1.5em"));
	
	outputChecklists(ordered_output_checklists);
	
    
    if (true)
    {
        //Gray text at the bottom:
        string line;
        line = HTMLGenerateTagWrap("span", "<br>Automatic refreshing disabled.", mapMake("id", "refresh_status"));
        line += HTMLGenerateTagWrap("a", "<br>Written by Ezandora.", generateMainLinkMap("showplayer.php?who=1557284"));
        line += "<br>" + __version;
        
        PageWrite(HTMLGenerateDivOfStyle(line, "font-size:0.777em;color:gray;"));
        
        /*if (false)
        {
        	boolean method_1_enabled = false;
            //Hacky layout, sorry:
            string [string] image_map;
            int size = 12;
            if (!method_1_enabled)
            {
            	size = 16;
            }
            image_map["width"] = size;
            image_map["height"] = size;
            image_map["class"] = "r_button";
            image_map["src"] = __refresh_image_data;
            image_map["id"] = "button_refresh";
            image_map["onclick"] = "document.location.reload(true)";
            if (method_1_enabled)
	            image_map["style"] = "position:relative;top:-12px;right:3px;visibility:visible;";
            else
	            image_map["style"] = "position:relative;visibility:visible;";
            image_map["alt"] = "Refresh";
            image_map["title"] = image_map["alt"];
            if (method_1_enabled)
	            PageWrite(HTMLGenerateDivOfStyle(HTMLGenerateTagPrefix("img", image_map), "width:100%;text-align:right;height:0px;")); //max-height:0px;
            else
            	PageWrite(HTMLGenerateDivOfStyle(HTMLGenerateTagPrefix("img", image_map), "position:fixed;right:" + (16) + "px;top:5px;z-index:1000;"));
        }*/
    }
    boolean matrix_enabled = false;
    if (my_path_id() == PATH_THE_SOURCE || $familiars[dataspider,Baby Bugged Bugbear] contains my_familiar())
    {
        matrix_enabled = !PreferenceGetBoolean("matrix disabled");
        if (true)
        {
            //We support disabling this feature, largely because it causes someone's browser to crash. Probably bad RAM.
            //I personally consider that to be a path-appropriate feature, but...
            string [string] image_map;
            image_map["width"] = "16";
            image_map["height"] = "16";
            image_map["class"] = "r_button";
            image_map["id"] = "button_refresh";
            image_map["style"] = "position:relative;top:-16px;left:3px;visibility:visible;";
            if (matrix_enabled)
            {
                image_map["src"] = __red_pill_image;
                image_map["onclick"] = "setMatrixStatus(true)";
                image_map["alt"] = "Matrix enabled";
            }
            else
            {
                image_map["src"] = __blue_pill_image;
                image_map["onclick"] = "setMatrixStatus(false)";
                image_map["alt"] = "Matrix disabled";
            }
            image_map["title"] = image_map["alt"];
            PageWrite(HTMLGenerateDivOfStyle(HTMLGenerateTagPrefix("img", image_map), "width:100%;text-align:left;")); //max-height:0px;
        }
    }
    
	PageWrite("</div>");
	PageWrite("</div>");
	
	if (!__setting_newstyle_navbars)
	{
        if (displaying_navbar) //in-div spacing at bottom for navbar
            PageWrite(HTMLGenerateDivOfStyle("", "min-height:" + (__setting_navbar_height_in_em - 0.05) + "em;"));
        if (__setting_show_location_bar) //in-div spacing at bottom for location bar
            PageWrite(HTMLGenerateDivOfStyle("", "min-height:" + (__setting_navbar_height_in_em - 0.05) + "em;"));
    }
    if (__setting_fill_vertical)
    {
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-1;background-color:" + __setting_page_background_colour + ";"))); //Color fill //max-width:" + __setting_horizontal_width + "px;"
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-11;border-left:1px solid;border-right:1px solid;border-color:" + __setting_line_colour + ";width:" + (__setting_horizontal_width) + "px;"))); //Vertical border lines, empty background
    }
    PageWriteHead("<script type=\"text/javascript\" src=\"GuideBrowserSide.js\"></script>");
    PageWriteHead("<script type=\"text/javascript\">function GuideParachuteInit() { if (typeof GuideInit !== 'function') { document.getElementById('extra_words_at_top').innerHTML = '<H1>Reinstall Guide</H1><H3>Installation is corrupted, missing javascript file GuideBrowserSide.js</H3>Functionality is limited.'}}</script>"); //mafia bug; we renamed a javascript file in a past release, and mafia will not always install a new file, silently breaking an installation
    
    if (matrix_enabled)
    {
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "opacity:0;visibility:hidden;background:black;position:fixed;top:0;left:0;z-index:303;width:100%;height:100%;", "id", "matrix_canvas_holder", "onclick", "matrixStopAnimation();", "onmousemove", "matrixStopAnimation();")));
        PageWrite(HTMLGenerateTagWrap("canvas", "", mapMake("width", "1", "height", "1", "id", "matrix_canvas", "style", "")));
        PageWrite("</div>");
        PageWrite(HTMLGenerateTagPrefix("img", mapMake("src", __matrix_glyphs, "id", "matrix_glyphs", "style", "display:none;")));
    }
    
    if (drunk)
        PageWrite("</div>");
    if (buggy)
        PageWrite("</div>");
        
        
    if (__setting_newstyle_navbars)
    {
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "")));
    	PageWrite(various_bar_buffer);
        PageWrite("</div>");
        PageWrite("</div>"); //main flexbox container
    }
    
    if (output_body_tag_only)
    	write(PageGenerateBodyContents());
    else
		PageGenerateAndWriteOut();
}
