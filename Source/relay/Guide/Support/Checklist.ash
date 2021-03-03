import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Support/KOLImage.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Page.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Settings.ash"

//Standard checklist names:
string C_REQUIRED_ITEMS = "Required Items";
string C_RESOURCES = "Resources";
string C_TASKS = "Tasks";
string C_OPTIONAL_TASKS = "Optional Tasks";
string C_AFTERCORE_TASKS = "Aftercore Quests";
string C_FUTURE_TASKS = "Future Tasks";


record ChecklistSubentry
{
	string header;
	string [int] modifiers;
	string [int] entries;
};


ChecklistSubentry ChecklistSubentryMake(string header, string [int] modifiers, string [int] entries)
{
	boolean all_subentries_are_empty = true;
	foreach key in entries
	{
		if (entries[key] != "")
			all_subentries_are_empty = false;
	}
	ChecklistSubentry result;
	result.header = header;
	result.modifiers = modifiers;
	if (!all_subentries_are_empty)
		result.entries = entries;
	return result;
}

ChecklistSubentry ChecklistSubentryMake(string header, string modifiers, string [int] entries)
{
	if (modifiers == "")
		return ChecklistSubentryMake(header, listMakeBlankString(), entries);
	else
		return ChecklistSubentryMake(header, listMake(modifiers), entries);
}


ChecklistSubentry ChecklistSubentryMake(string header, string [int] entries)
{
	return ChecklistSubentryMake(header, listMakeBlankString(), entries);
}

ChecklistSubentry ChecklistSubentryMake(string header, string [int] modifiers, string e1)
{
	return ChecklistSubentryMake(header, modifiers, listMake(e1));
}

ChecklistSubentry ChecklistSubentryMake(string header, string [int] modifiers, string e1, string e2)
{
	return ChecklistSubentryMake(header, modifiers, listMake(e1, e2));
}


ChecklistSubentry ChecklistSubentryMake(string header, string modifiers, string e1)
{
	if (modifiers == "")
		return ChecklistSubentryMake(header, listMakeBlankString(), listMake(e1));
	else
		return ChecklistSubentryMake(header, listMake(modifiers), listMake(e1));
}

ChecklistSubentry ChecklistSubentryMake(string header)
{
	return ChecklistSubentryMake(header, "", "");
}

void listAppend(ChecklistSubentry [int] list, ChecklistSubentry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listPrepend(ChecklistSubentry [int] list, ChecklistSubentry entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

ChecklistSubentry [int] listMake(ChecklistSubentry e1)
{
	ChecklistSubentry [int] result;
	result.listAppend(e1);
	return result;
}


int CHECKLIST_DEFAULT_IMPORTANCE = 0;
record ChecklistEntry
{
	string image_lookup_name;
	string url;
    string [string] container_div_attributes;
	ChecklistSubentry [int] subentries;
	boolean should_indent_after_first_subentry;
    
    boolean should_highlight;
	
	int importance_level; //Entries will be resorted by importance level before output, ascending order. Default importance is 0. Convention is to vary it from [-11, 11] for reasons that are clear and well supported in the narrative.
    boolean only_show_as_extra_important_pop_up; //only valid if -11 importance or lower - only shows up as a pop-up, meant to inform the user they can scroll up to see something else (semi-rares)
    ChecklistSubentry [int] subentries_on_mouse_over; //replaces subentries
    
    string combination_tag; //Entries with identical combination tags will be combined into one, with the "first" taking precedence.
    string short_description; //five letters or less
    string category; //similar to combination_tags, except they aren't combined - just "grouped" next to each other
    string specific_image;
    string abridged_header; //custom
    
    string internal_generation_identifier;
    string [string] internal_processing_data; //when combined via tags, the data is += to each other with a | separator
    
    int [int] internal_processing_data_subentry_content_id; //key is subentry index, value is content id. stored this "high" instead of internal_processing_data because this is simpler than a generic system
};

//In retrospect, making all these ChecklistEntryMake overloads was a mistake
//may want to consider removing some? but they're *all* used
ChecklistEntry ChecklistEntryMakeInternal(string image_lookup_name, string url, ChecklistSubentry [int] subentries, int importance, boolean should_highlight)
{
	ChecklistEntry result;
	result.image_lookup_name = image_lookup_name;
	result.url = url;
	result.subentries = subentries;
	result.importance_level = importance;
    result.should_highlight = should_highlight;
    
    //This generation process adds about nine milliseconds to load time: (6.6% load cost)
    //This is the only way I can think of it make checklist entries have a "unique" identifier. There are a lot of "vague" identifiers - image name, url, first entry title - but those change.
    if (true)
    {
    	/*
        Example:
        Checklist.ash: ChecklistEntryMakeInternal L193
        Spinmaster Lathe.ash: ChecklistEntryMake L104
        Checklists.ash: IOTMSpinmasterLatheGenerate L237
        Main.ash: generateChecklists L71
        relay_Guide.ash: runMain L9
        Globals.ash: main L45
        */
    	//Mystery I've never really solved: how to store the result from get_stack_trace() into a variable, instead of calling it three times? don't know the syntax
        
        /*print_html("");
        foreach key, r in get_stack_trace()
        {
        	print_html(r.file + ": " + r.name + " L" + r.line);
        }*/
        //Note that there can be non-unique entries with the same file, function, and line; doctor bag and emotion chip, as an example, because they're in a loop.
        //But, those are often grouped together anyways, so...
        buffer generation_identifier; //Considered making this part of the record to prevent an alloc, but
        generation_identifier.append(get_stack_trace()[1].file);
        generation_identifier.append(get_stack_trace()[2].name);
        generation_identifier.append(get_stack_trace()[1].line);
        result.internal_generation_identifier = generation_identifier.to_string();
    }
	return result;
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry [int] subentries, int importance, boolean should_highlight)
{
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, importance, should_highlight);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry [int] subentries, int importance)
{
    return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, importance, false);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry [int] subentries, int importance, boolean [location] highlight_if_last_adventured)
{
    boolean should_highlight = false;
    
    if (highlight_if_last_adventured contains __last_adventure_location)
        should_highlight = true;
    return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, importance, should_highlight);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry [int] subentries)
{
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, CHECKLIST_DEFAULT_IMPORTANCE, false);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry [int] subentries, boolean [location] highlight_if_last_adventured)
{
    boolean should_highlight = false;
    
    if (highlight_if_last_adventured contains __last_adventure_location)
        should_highlight = true;
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, CHECKLIST_DEFAULT_IMPORTANCE, should_highlight);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry subentry, int importance)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, importance, false);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry subentry, int importance, boolean [location] highlight_if_last_adventured)
{
    boolean should_highlight = false;
    
    if (highlight_if_last_adventured contains __last_adventure_location)
        should_highlight = true;
        
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, importance, should_highlight);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry subentry)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, CHECKLIST_DEFAULT_IMPORTANCE, false);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry subentry, boolean [location] highlight_if_last_adventured)
{
    boolean should_highlight = false;
    
    if (highlight_if_last_adventured contains __last_adventure_location)
        should_highlight = true;
        
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMakeInternal(image_lookup_name, url, subentries, CHECKLIST_DEFAULT_IMPORTANCE, should_highlight);
}

ChecklistEntry ChecklistEntryMake()
{
	ChecklistSubentry [int] blank_subentries;
	return ChecklistEntryMakeInternal("", "", blank_subentries, 0, false);
}



//Secondary level of making checklist entries; setting properties and returning them.
ChecklistEntry ChecklistEntryTag(ChecklistEntry e, string tag)
{
    e.combination_tag = tag;
    return e;
}

ChecklistEntry ChecklistEntrySetShortDescription(ChecklistEntry e, string short_description)
{
	e.short_description = short_description;
	return e;
}
ChecklistEntry ChecklistEntrySetCategory(ChecklistEntry e, string category)
{
	e.category = category;
	return e;
}
ChecklistEntry ChecklistEntrySetSpecificImage(ChecklistEntry e, string specific_image)
{
	e.specific_image = specific_image;
	return e;
}
ChecklistEntry ChecklistEntrySetAbridgedHeader(ChecklistEntry e, string abridged_header)
{
	e.abridged_header = abridged_header;
	return e;
}


ChecklistEntry listAppend(ChecklistEntry [int] list, ChecklistEntry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
	return list[position];
}

void listAppendList(ChecklistEntry [int] list, ChecklistEntry [int] entries)
{
	foreach key in entries
		list.listAppend(entries[key]);
}

void listClear(ChecklistEntry [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}


record Checklist
{
	string title;
	ChecklistEntry [int] entries;
    
    boolean disable_generating_id; //disable generating checklist anchor and title-based div identifier
};


Checklist ChecklistMake(string title, ChecklistEntry [int] entries)
{
	Checklist cl;
	cl.title = title;
	cl.entries = entries;
	return cl;
}

Checklist ChecklistMake()
{
	Checklist cl;
	return cl;
}

void listAppend(Checklist [int] list, Checklist entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listRemoveKeys(Checklist [int] list, int [int] keys_to_remove)
{
	foreach i in keys_to_remove
	{
		int key = keys_to_remove[i];
		if (!(list contains key))
			continue;
		remove list[key];
	}
}


string ChecklistGenerateModifierSpan(string [int] modifiers)
{
    if (modifiers.count() == 0)
        return "";
	return HTMLGenerateSpanOfClass(modifiers.listJoinComponents(", "), "r_cl_modifier");
}

string ChecklistGenerateModifierSpan(string modifier)
{
	return HTMLGenerateSpanOfClass(modifier, "r_cl_modifier");
}


void ChecklistInit()
{
	PageAddCSSClass("a", "r_cl_internal_anchor", "");
	//PageAddCSSClass("", "r_cl_modifier_inline", "font-size:0.80em; color:" + __setting_modifier_colour + ";");
	//PageAddCSSClass("", "r_cl_modifier", "font-size:0.80em; color:" + __setting_modifier_colour + "; display:block;");
    PageAddCSSClass("", "r_cl_modifier_inline", "font-size:0.85em; color:" + __setting_modifier_colour + ";");
    PageAddCSSClass("", "r_cl_modifier", "font-size:0.85em; color:" + __setting_modifier_colour + "; display:block;");
	
	PageAddCSSClass("", "r_cl_header", "text-align:center; font-size:1.15em; font-weight:bold;width:100%;padding-bottom:5px;border-bottom:1px solid " + __setting_line_colour + ";padding-top:5px;");
	PageAddCSSClass("", "r_cl_header_clicked", "background-color:" + __setting_line_colour + ";"); //__setting_line_colour is too light
	//Thought about making subheaders for abridged mode bigger - 1.5em fits fine within the vertical space - but it looks weird, like shouting.
	PageAddCSSClass("", "r_cl_subheader", "font-size:1.07em; font-weight:bold;");
	PageAddCSSClass("", "r_cl_subheader_abridged", "font-size:1.07em; font-weight:bold;");
	
	
	PageAddCSSClass("div", "r_cl_inter_spacing_divider", "width:100%; height:12px;");
    
    string container_gradient = "background: #ffffff;background: -moz-linear-gradient(left, #ffffff 50%, #F0F0F0 75%, #F0F0F0 100%);background: -webkit-gradient(linear, left top, right top, color-stop(50%,#ffffff), color-stop(75%,#F0F0F0), color-stop(100%,#F0F0F0));background: -webkit-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: -o-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: -ms-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: linear-gradient(to right, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#F0F0F0',GradientType=1 );"; //help
    
    if (!__use_flexbox_on_checklists)
    {
        PageAddCSSClass("div", "r_cl_l_container_highlighted", container_gradient + "padding-top:5px;padding-bottom:5px;");
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:5px;padding-bottom:5px;");
        PageAddCSSClass("", "r_cl_l_left", "float:left;width:" + __setting_image_width_large + "px;margin-left:20px;overflow:hidden;");
        PageAddCSSClass("", "r_cl_l_right_container", "width:100%;margin-left:" + (-__setting_image_width_large - 20) + "px;float:right;text-align:left;vertical-align:top;");
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + (__setting_image_width_large + 20 + 2) + "px;display:inline-block;margin-right:20px;");
    }
    //string hr_width = __setting_indention_width;
    //string half_hr_width = (__setting_indention_width_in_em / 2.0) + "em";
    string hr_width = "0px";
    string half_hr_width = "0px";
    PageAddCSSClass("hr", "r_cl_hr", "padding:0px;margin-top:0px;margin-bottom:0px;width:auto; margin-left:" + hr_width + ";margin-right:" + hr_width +";");
    PageAddCSSClass("hr", "r_cl_hr_extended", "padding:0px;margin-top:0px;margin-bottom:0px;width:auto; margin-left:" + hr_width + ";margin-right:0px;");
	PageAddCSSClass("div", "r_cl_holding_container", "display:inline-block;");
	
    
    PageAddCSSClass("", "r_cl_image_container_large", "display:block;");
    PageAddCSSClass("", "r_cl_image_container_medium", "display:none;");
    PageAddCSSClass("", "r_cl_image_container_small", "display:none;");
    
	if (true)
	{
		string div_style = "";
		div_style = "margin:0px;";
        /*div_style += "border-style: solid; border-color:" + __setting_line_colour + ";";
        div_style += "border:1px;";
        div_style += "border-left:0px; border-right:0px;border-bottom:0px;";*/
        div_style += "border-top:1px solid " + __setting_line_colour + ";";
        div_style += "background-color:#FFFFFF; width:100%;";// padding-top:5px;";
        if (__use_flexbox_on_checklists)
        	div_style += "display:flex;flex-wrap:wrap;align-items:stretch;";
		PageAddCSSClass("div", "r_cl_checklist_container", div_style);
	}
    
    //media queries:
    if (!__use_table_based_layouts)
    {
    	if (!__use_flexbox_on_checklists)
        {
            PageAddCSSClass("", "r_cl_l_left", "width:" + __setting_image_width_medium + "px;margin-left:5px;", 0, __setting_media_query_medium_size);
            PageAddCSSClass("", "r_cl_l_right_container", "margin-left:" + (-__setting_image_width_medium - 5) + "px;", 0, __setting_media_query_medium_size);
            PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + (__setting_image_width_medium + 5 + 2) + "px;margin-right:10px;", 0, __setting_media_query_medium_size);
            PageAddCSSClass("div", "r_cl_l_container", "padding-top:4px;padding-bottom:4px;", 0, __setting_media_query_medium_size);
        }
        
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:" + half_hr_width + ";margin-right:" + half_hr_width + ";", 0, __setting_media_query_medium_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:" + half_hr_width + ";", 0, __setting_media_query_medium_size);
        
        
    	if (!__use_flexbox_on_checklists)
        {
            PageAddCSSClass("", "r_cl_l_left", "width:" + (__setting_image_width_small) + "px;margin-left:5px;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_cl_l_right_container", "margin-left:" + (-(__setting_image_width_small) - 10) + "px;", 0, __setting_media_query_small_size);
            PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + ((__setting_image_width_small) + 10) + "px;margin-right:3px;", 0, __setting_media_query_small_size);
            PageAddCSSClass("div", "r_cl_l_container", "padding-top:3px;padding-bottom:3px;", 0, __setting_media_query_small_size);
        }
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:0px;margin-right:0px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:0px;", 0, __setting_media_query_small_size);
        
        
    	if (!__use_flexbox_on_checklists)
        {
            PageAddCSSClass("", "r_cl_l_left", "width:" + (0) + "px;margin-left:3px;", 0, __setting_media_query_tiny_size);
            PageAddCSSClass("", "r_cl_l_right_container", "margin-left:" + (-(0) - 3) + "px;", 0, __setting_media_query_tiny_size);
            PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + ((0) + 3 + 2) + "px;margin-right:3px;", 0, __setting_media_query_tiny_size);
            PageAddCSSClass("div", "r_cl_l_container", "padding-top:3px;padding-bottom:3px;", 0, __setting_media_query_tiny_size);
        }
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:0px;margin-right:0px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:0px;", 0, __setting_media_query_tiny_size);
        
        
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:block;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:none;", 0, __setting_media_query_medium_size);
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:none;", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:block;", 0, __setting_media_query_small_size);
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:none;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:none;", 0, __setting_media_query_tiny_size);
        
        PageAddCSSClass("", "r_small_float_indention", "display:none");
        
        PageAddCSSClass("", "r_indention_not_small", "margin-left:" + __setting_indention_width + ";");
        if (__setting_small_size_uses_full_width)
        {
        	if (!__use_flexbox_on_checklists)
	            PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:10px;margin-right:3px;min-width:80%;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_cl_image_container_small", "display:block;float:left;", 0, __setting_media_query_small_size);
            //PageAddCSSClass("", "r_small_float_indention", "display:inline;width:0.5em;height:" + (__setting_image_width_small - 10) + "px;float:left;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_small_float_indention", "display:inline;width:0.5em;float:left;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_indention_not_small", "margin-left:0.75em;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_indention_not_small", "margin-left:0.75em;", 0, __setting_media_query_tiny_size);
        }
        
        
        PageAddCSSClass("", "r_indention", "margin-left:0.75em;", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_indention", "margin-left:0.75em;", 0, __setting_media_query_tiny_size);
    }
    
    if (__use_flexbox_on_checklists)
    {
    	//padding-top:5px;padding-bottom:5px;
        PageAddCSSClass("div", "r_cl_l_container", "display:flex;flex-direction:row;flex-wrap:nowrap;justify-content:flex-start;align-items:stretch;border-bottom:1px solid " + __setting_line_colour + ";flex-grow:1;width:100%;width:100%;"); //width:600px;
        PageAddCSSClass("div", "r_cl_l_container_highlighted", container_gradient);
        PageAddCSSClass("div", "r_cl_l_container_minimised", "width:200px;");
        PageAddCSSClass("div", "r_cl_l_container_always_minimised", "width:200px;");
        //PageAddCSSClass("div", "r_cl_l_container_minimised", "");
        
        
        PageAddCSSClass("", "r_cl_l_right_container", "width:100%;" + "px;text-align:left;padding-top:5px;padding-bottom:5px;margin-left:3px;align-self:center;padding-right:5px;");
        PageAddCSSClass("div", "r_cl_l_right_content", ""); //display:inline-block;
        PageAddCSSClass("div", "r_cl_l_right_content_abridged", "display:none;");
        
        PageAddCSSClass("", "r_cl_l_left", "flex-basis:" + (__setting_image_width_large) + "px;overflow:hidden;padding-top:5px;padding-bottom:5px;flex-shrink:0;");
        PageAddCSSClass("", "r_cl_l_left", "max-width:" + (__setting_image_width_medium) + "px;margin-left:5px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_l_left", "max-width:" + (__setting_image_width_small) + "px;margin-left:5px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_l_left", "max-width:" + (0) + "px;margin-left:3px;", 0, __setting_media_query_tiny_size);
        
        
        if (false)
        {
        	//solid background:
            //PageAddCSSClass("div", "r_cl_l_left_showhide", "cursor:pointer;background:" + __setting_line_colour + ";width:20px;flex-shrink:0;");
        }
        else
        {
            //PageAddCSSClass("div", "r_cl_l_left_showhide:hover", "background:" + __setting_line_colour + ";");
        }
        //PageAddCSSClass("div", "r_cl_l_left_showhide_blank", "width:21px;max-width:21px;min-width:21px;flex-shrink:0;");
        
        //art design student
        
        PageAddCSSClass("div", "r_cl_l_left_showhide_clicked", "background-color:" + __setting_page_background_colour + ";"); //this looks nicer, but line matches header clicked
        //PageAddCSSClass("div", "r_cl_l_left_showhide_clicked", "background-color:" + __setting_line_colour + ";");
        
        PageAddCSSClass("div", "r_cl_l_left_showhide", "border-right:1px solid " + __setting_line_colour + ";border-left:1px solid " + __setting_line_colour + ";width:15px;max-width:15px;min-width:15px;flex-shrink:0;flex-grow:0;flex-basis:0;margin-left:-1px;"); //-1 px to hide the left border
        PageAddCSSClass("div", "r_cl_l_container_minimised:hover", "background-color:" + "#CCCCCC" + ";mix-blend-mode:multiply;");
        //PageAddCSSClass("div", "r_cl_l_left_showhide:hover", "background-color:" + "#CCCCCC" + ";");
        PageAddCSSClass("div", "r_cl_l_left_showhide", "width:20px;max-width:20px;min-width:15px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_left_showhide", "width:15px;max-width:15px;min-width:15px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_left_showhide", "width:10px;max-width:10px;min-width:10px;", 0, __setting_media_query_tiny_size);
        //Order matters; this class must be defined after r_cl_l_left_showhide to override it.
        PageAddCSSClass("div", "r_cl_l_left_showhide_blank", "border-right:1px solid transparent;border-left:1px solid transparent;");
        PageAddCSSClass("div", "r_cl_l_left_showhide_blank:hover", "cursor:auto;background:transparent;");
        
        PageAddCSSClass("div", "showhide_mouseover_popup_class", "position:absolute;background:white;width:100%;z-index:5;border-bottom:1px solid " + __setting_line_colour + ";border-right:1px solid " + __setting_line_colour + ";pointer-events:none;box-shadow:0px 0px 30px 0px black;display:none;");
         //transition:opacity 0.25s; box-shadow:0px 0px 0px 10000px rgba(0,0,0,0.5); opacity:0;
        
    }
}

//Creates if not found:
Checklist lookupChecklist(Checklist [int] checklists, string title)
{
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		if (cl.title == title)
			return cl;
	}
	//Not found, create one.
	Checklist cl = ChecklistMake();
	cl.title = title;
	checklists.listAppend(cl);
	return cl;
}

void ChecklistFormatSubentry(ChecklistSubentry subentry)
{
    foreach i in subentry.entries
    {
        string [int] line_split = split_string_alternate(subentry.entries[i], "\\|");
        foreach l in line_split
        {
            if (stringHasPrefix(line_split[l], "*"))
            {
                //remove prefix:
                //indent:
                line_split[l] = HTMLGenerateIndentedText(substring(line_split[l], 1));
            }
        }
        //Recombine:
        buffer building_line;
        boolean first = true;
        boolean last_was_indention = false;
        foreach key in line_split
        {
            string line = line_split[key];
            if (!contains_text(line, "class=\"r_indention\"") && !first && !last_was_indention) //hack way of testing for indention
            {
                building_line.append("<br>");
            }
            last_was_indention = contains_text(line, "class=\"r_indention\"");
            building_line.append(line);
            first = false;
        }
        subentry.entries[i] = to_string(building_line);
    }
}

Record ChecklistGeneratedEntryHTML
{
	buffer out;
	boolean small_enough_for_showhide_to_ignore;
	string abridged_header_text;
};

ChecklistGeneratedEntryHTML ChecklistGenerateEntryHTMLFull(ChecklistEntry entry, ChecklistSubentry [int] subentries, string anchor_url, boolean setting_use_holding_containers_per_subentry)
{
    Vec2i max_image_dimensions_large = Vec2iMake(__setting_image_width_large, 75);
    Vec2i max_image_dimensions_medium = Vec2iMake(__setting_image_width_medium, 50);
    Vec2i max_image_dimensions_small = Vec2iMake(__setting_image_width_small, 50);
    if (__setting_small_size_uses_full_width)
        max_image_dimensions_small = Vec2iMake(__setting_image_width_small,__setting_image_width_small);
    boolean outputting_anchor = anchor_url != "";
    boolean outputting_as_anchor = anchor_url != "";
    
    string [string] main_containers_base_map;
    if (outputting_as_anchor)
	    main_containers_base_map = mapMake("target", "mainpane", "href", entry.url, "class", "r_a_undecorated");
    
    string anchor_prefix_html = ""; //HTMLGenerateTagPrefix("a", main_containers_base_map);
    string main_container_tag = "div";
    if (outputting_as_anchor)
    	main_container_tag = "a";
    
    
    ChecklistGeneratedEntryHTML final_result;
    buffer result;
    if (true)
    {
        
        buffer image_container;
        
        if (outputting_anchor && !__setting_entire_area_clickable)
            image_container.append(anchor_prefix_html);
        
        image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large, "r_cl_image_container_large"));
        image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_medium, "r_cl_image_container_medium"));
        if (!__setting_small_size_uses_full_width)
            image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_small, "r_cl_image_container_small"));
        
        if (outputting_anchor && !__setting_entire_area_clickable)
            image_container.append("</a>");
        
        //result.HTMLAppendDivOfClass(image_container, "r_cl_l_left");
        string [string] cl_l_left_map = main_containers_base_map.mapCopy();
        cl_l_left_map["class"] += " r_cl_l_left";
        result.HTMLAppendTagPrefix(main_container_tag, cl_l_left_map);
        result.append(image_container);
        result.HTMLAppendTagSuffix(main_container_tag);
        
    }
    //else
        //result.HTMLAppendDivOfClass(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large), "r_cl_l_left");
    
    
    //result.HTMLAppendTagPrefix("div", "class", "r_cl_l_right_container");
    
    
    string [string] r_cl_l_right_container = main_containers_base_map.mapCopy();
    r_cl_l_right_container["class"] += " r_cl_l_right_container";
    result.HTMLAppendTagPrefix(main_container_tag, r_cl_l_right_container);
    
    if (outputting_anchor && !__setting_entire_area_clickable)
        result.append(anchor_prefix_html);
    //internal_processing_data
    //if (entry.internal_processing_data contains "content_id")
    	//r_cl_l_right_content_map["data-content-ids"] = entry.internal_processing_data["content_id"]; 
    result.HTMLAppendTagPrefix("div", "class", "r_cl_l_right_content");
    
    if (__setting_small_size_uses_full_width)
    {
        result.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_small, "r_cl_image_container_small"));
        
        result.HTMLAppendTagWrap("div", "", mapMake("class", "r_small_float_indention", "style", "height: " + __kol_image_generate_image_html_return_final_size.y + "px;"));
        //result.HTMLAppendDivOfClass("", "r_small_float_indention"); //&nbsp; to have it display. hack
    }
    
    string [string] hardcoded_combination_tag_descriptions = {
    "free instakill":"Free instant kills",
	"daily free fight":"Daily free fights",
	"free banish":"Free banishes",
	"emotion chip combat":"Emotion chip",
	"banish":"Turn-costing banishes",
	"zutara":"Fortune Teller",
	"telegraph skill":"",
	"consumption junction, what's your function?":"Consumption space",
    };
    
    buffer abridged_buffer;
    //int approximate_subtext_height = 0;
    boolean first = true;
    int approximate_lines = subentries.count();
    foreach j in subentries
    {
        ChecklistSubentry subentry = subentries[j];
        if (subentry.header == "")
            continue;
        string subheader = subentry.header;
        
        boolean indent_this_entry = false;
        if (!first && entry.should_indent_after_first_subentry)
        {
            indent_this_entry = true;
        }
        
        
        
        if (indent_this_entry)
            result.HTMLAppendTagPrefix("div", "class", "r_indention");
        
        
        //internal_processing_data_subentry_content_id
        
        if (true)
        {
        	//result.append(HTMLGenerateSpanOfClass(subheader, "r_cl_subheader"));
         
         
        	string [string] subheader_map = mapMake("class", "r_cl_subheader");
            if (entry.internal_processing_data_subentry_content_id.count() > 0)
            	subheader_map["data-content-id"] = entry.internal_processing_data_subentry_content_id[j];
            result.HTMLAppendTagPrefix("span", subheader_map);
            result.append(subheader);
            result.HTMLAppendTagSuffix("span");
            
            if (first)
            {
                abridged_buffer.HTMLAppendTagPrefix("span", "class", "r_cl_subheader_abridged");
                
                
                string core_text = subheader;
                
                if (entry.abridged_header != "")
                {
                	core_text = entry.abridged_header;
                }
            	else if (entry.combination_tag != "" && subentries.count() > 1)
                {
                	if (hardcoded_combination_tag_descriptions contains entry.combination_tag)
                    {
                    	if (hardcoded_combination_tag_descriptions[entry.combination_tag] != "")
                        {
                 			core_text = hardcoded_combination_tag_descriptions[entry.combination_tag];
                        }
                    }
                    else
                    {
	                	core_text = entry.combination_tag.capitaliseFirstLetter();
                    }
                }
                final_result.abridged_header_text = core_text.entity_encode();
                abridged_buffer.append(core_text);
                abridged_buffer.HTMLAppendTagSuffix("span");
            }
        }
        
        string indention_class = "r_indention";
        if (__setting_small_size_uses_full_width)
        	indention_class = "r_indention_not_small";
        
        if (true)
        {
        	string [string] indention_map = mapMake("class", indention_class);
            if (entry.internal_processing_data_subentry_content_id.count() > 0)
            	indention_map["data-content-id"] = entry.internal_processing_data_subentry_content_id[j];
            result.HTMLAppendTagPrefix("div", indention_map);
        }
        approximate_lines += subentry.modifiers.count();
        approximate_lines += subentry.entries.count();
        if (subentry.modifiers.count() > 0)
            result.append(ChecklistGenerateModifierSpan(listJoinComponents(subentry.modifiers, ", ")));
        if (subentry.entries.count() > 0)
        {
        	//approximate_subtext_height += subentry.entries.count();
            int intra_k = 0;
            if (setting_use_holding_containers_per_subentry)
                result.HTMLAppendTagPrefix("div", "class", "r_cl_holding_container"); //HRs
            while (intra_k < subentry.entries.count())
            { 
                if (intra_k > 0)
                {
                    result.append("<hr>");
                }
                string line = subentry.entries[listKeyForIndex(subentry.entries, intra_k)];
                
                //if (line.contains_text("<div class=\"r_stl_container_row\">") || line.contains_text("<hr>"))
                	//approximate_subtext_height += 1;
                
                //if (line.contains_text("<hr"))
                result.HTMLAppendDivOfClass(line, "r_cl_holding_container"); //For nested HRs, sizes them down a bit
                
                intra_k += 1;
            }
            if (setting_use_holding_containers_per_subentry)
                result.append("</div>");
        }
        result.append("</div>");
        if (indent_this_entry)
            result.append("</div>");
        first = false;
    }
    result.append("</div>"); //r_cl_l_right_content
    
    
    result.HTMLAppendTagPrefix("div", "class", "r_cl_l_right_content_abridged");
    result.append(abridged_buffer);
    result.append("</div>"); //r_cl_l_right_content_abridged
    
    if (outputting_anchor && !__setting_entire_area_clickable)
        result.append("</a>");
    result.HTMLAppendTagSuffix(main_container_tag); //r_cl_l_right_container
    
    if (!__use_flexbox_on_checklists)
	    result.HTMLAppendDivOfClass("", "r_end_floating_elements"); //stop floating
     
    final_result.out = result;
    final_result.small_enough_for_showhide_to_ignore = approximate_lines <= 1; //approximate_subtext_height <= 1;
    //final_result.small_enough_for_showhide_to_ignore = false;
    
    return final_result;
}

buffer ChecklistGenerateEntryHTML(ChecklistEntry entry, ChecklistSubentry [int] subentries, string anchor_url, boolean setting_use_holding_containers_per_subentry)
{
	return ChecklistGenerateEntryHTMLFull(entry, subentries, anchor_url, setting_use_holding_containers_per_subentry).out;
}

buffer ChecklistGenerate(Checklist cl, boolean output_borders)
{
	ChecklistEntry [int] entries = cl.entries;
	
	//Combine entries with identical combination tags:
	ChecklistEntry [string] combination_tag_entries;
	foreach key, entry in entries
	{
		if (entry.combination_tag == "") continue;
        if (entry.only_show_as_extra_important_pop_up) continue; //do not support this feature with this
        if (entry.subentries_on_mouse_over.count() > 0) continue;
        if (entry.container_div_attributes.count() > 0) continue;
        
        if (!(combination_tag_entries contains entry.combination_tag))
        {
        	entry.importance_level -= 1; //combined entries gain a hack; a level above everything else
        	combination_tag_entries[entry.combination_tag] = entry;
            continue;
        }
        ChecklistEntry master_entry = combination_tag_entries[entry.combination_tag];
        
        if (entry.should_highlight)
        	master_entry.should_highlight = true;
        if (master_entry.url == "" && entry.url != "")
        	master_entry.url = entry.url;
        master_entry.importance_level = min(master_entry.importance_level, entry.importance_level - 1);
        foreach key, subentry in entry.subentries
        { 
        	master_entry.subentries.listAppend(subentry);
            //Bring over internal_processing_data_subentry_content_id:
            master_entry.internal_processing_data_subentry_content_id[master_entry.subentries.count() - 1] = entry.internal_processing_data_subentry_content_id[key];
        }
        foreach key, value in entry.internal_processing_data
        {
        	if (!(master_entry.internal_processing_data contains key))
            	master_entry.internal_processing_data[key] = value;
            else
            {
            	master_entry.internal_processing_data[key] += "|" + value;
            }
        }
        remove entries[key];
	}
	
	//Sort by importance:
	sort entries by value.importance_level;
    
	
	if (true)
	{
		//Format subentries:
		foreach i in entries
		{
			ChecklistEntry entry = entries[i];
			foreach j in entry.subentries
			{
                ChecklistFormatSubentry(entry.subentries[j]);
			}
			foreach j in entry.subentries_on_mouse_over
			{
                ChecklistFormatSubentry(entry.subentries_on_mouse_over[j]);
			}
		}
	}

	boolean skip_first_entry = false;
	string special_subheader = "";
	if (entries.count() > 0)
	{
		if (entries[0].image_lookup_name == "special subheader")
		{
			if (entries[0].subentries.count() > 0)
			{
				special_subheader = entries[0].subentries[0].header;
				skip_first_entry = true;
			}
		}
	}
	
	
	buffer result;
    if (output_borders)
        result.HTMLAppendDivOfClass("", "r_cl_inter_spacing_divider"); //spacing
	
    if (!cl.disable_generating_id)
        result.HTMLAppendTagWrap("a", "", mapMake("id", HTMLConvertStringToAnchorID(cl.title), "class", "r_cl_internal_anchor"));
	
    string [string] main_container_map;
    main_container_map["class"] = "r_cl_checklist_container";
    if (!cl.disable_generating_id)
        main_container_map["id"] = HTMLConvertStringToAnchorID(cl.title + " checklist container");
    main_container_map["data-title"] = cl.title;
    if (!output_borders)
        main_container_map["style"] = "border:0px;";
    result.HTMLAppendTagPrefix("div", main_container_map);
	
	
	result.HTMLAppendTagWrap("div", cl.title, mapMake("class", "r_cl_header r_clickable", "onmousedown", "checklistHeaderButtonClicked(window.event)"));
	
	if (special_subheader != "")
		result.append(ChecklistGenerateModifierSpan(special_subheader));
	
	int starting_intra_i = 0;
	if (skip_first_entry)
		starting_intra_i = 1;
	int intra_i = 0;
	int entries_output = 0;
    boolean last_was_highlighted = false;
    int current_mouse_over_id = 1;
	foreach i in entries
	{
		if (intra_i < starting_intra_i)
		{
			intra_i += 1;
			continue;
		}
		ChecklistEntry entry = entries[i];
		if (intra_i > starting_intra_i && !__use_flexbox_on_checklists)
		{
            boolean next_is_highlighted = false;
            if (entry.should_highlight)
                next_is_highlighted = true;
            string class_name = "r_cl_hr";
            if (last_was_highlighted || next_is_highlighted)
                class_name = "r_cl_hr_extended";
			result.HTMLAppendTagPrefix("hr", "class", class_name);
		}
        if (__use_table_based_layouts)
            __setting_entire_area_clickable = true;
		boolean outputting_anchor = false;
        buffer anchor_prefix_html;
		if (entry.url != "")
		{
            anchor_prefix_html = HTMLGenerateTagPrefix("a", mapMake("target", "mainpane", "href", entry.url, "class", "r_a_undecorated"));
			outputting_anchor = true;
		}
        if (outputting_anchor && __setting_entire_area_clickable)
			result.append(anchor_prefix_html);
		
		boolean setting_use_holding_containers_per_subentry = true;
			
		Vec2i max_image_dimensions_large = Vec2iMake(__setting_image_width_large, 75);
		Vec2i max_image_dimensions_medium = Vec2iMake(__setting_image_width_medium, 50);
		Vec2i max_image_dimensions_small = Vec2iMake(__setting_image_width_small, 50);
        if (__setting_small_size_uses_full_width)
            max_image_dimensions_small = Vec2iMake(__setting_image_width_small,__setting_image_width_small);
        
        string container_class = "r_cl_l_container";
        if (entry.should_highlight)
            container_class += " r_cl_l_container_highlighted";
        last_was_highlighted = entry.should_highlight;
        
        ChecklistGeneratedEntryHTML generated_entry = ChecklistGenerateEntryHTMLFull(entry, entry.subentries, entry.url, setting_use_holding_containers_per_subentry);
        buffer generated_subentry_html = generated_entry.out;
        if (generated_entry.small_enough_for_showhide_to_ignore)
        	container_class += " r_cl_l_container_always_minimised";
        if (entry.subentries_on_mouse_over.count() > 0)
        {
            buffer generated_mouseover_subentry_html = ChecklistGenerateEntryHTML(entry, entry.subentries_on_mouse_over, entry.url, setting_use_holding_containers_per_subentry);
            
            //Can't properly escape, so generate two no-show divs and replace them as needed:
            //We could just have a div that shows up when we mouse over...
            //This is currently very buggy.
            entry.container_div_attributes["onmouseenter"] = "event.currentTarget.innerHTML = document.getElementById('r_temp_o" + current_mouse_over_id + "').innerHTML";
            entry.container_div_attributes["onmouseleave"] = "event.currentTarget.innerHTML = document.getElementById('r_temp_l" + current_mouse_over_id + "').innerHTML";
            
            result.HTMLAppendTagPrefix("div", "id", "r_temp_o" + current_mouse_over_id, "style", "display:none");
            result.append(generated_mouseover_subentry_html);
            result.HTMLAppendTagSuffix("div");
            result.HTMLAppendTagPrefix("div", "id", "r_temp_l" + current_mouse_over_id, "style", "display:none");
            result.append(generated_subentry_html);
            result.HTMLAppendTagSuffix("div");
            
            current_mouse_over_id += 1;
        }
        
        entry.container_div_attributes["class"] += (entry.container_div_attributes contains "class" ? " " : "") + container_class;
        
        string entry_stable_id = entry.internal_generation_identifier;
        if (entry.combination_tag != "")
        	entry_stable_id = entry.combination_tag;
        
        if (entry_stable_id != "")
	        entry.container_div_attributes["data-stable-id"] = entry_stable_id;
        else if (my_id() == 1557284)
        	print_html("warning: no stable id for " + entry.subentries[0].header); //usually caused by a lack of checklistentrymake
         
        if (generated_entry.abridged_header_text != "")
			entry.container_div_attributes["data-abridged-text"] = generated_entry.abridged_header_text;
        
        if (entry.internal_processing_data contains "content_id")
            entry.container_div_attributes["data-content-ids"] = entry.internal_processing_data["content_id"]; 
        result.HTMLAppendTagPrefix("div", entry.container_div_attributes);
        
		/*if (__use_table_based_layouts)
		{
			//table-based layout:
			result.append("<table cellpadding=0 cellspacing=0><tr>");
			
			result.HTMLAppendTagWrap("td", "", mapMake("style", "width:" + __setting_indention_width + ";"));
			result.append("<td>");
			result.HTMLAppendTagPrefix("td", "style", "min-width:" + __setting_image_width_large + "px; max-width:" + __setting_image_width_large + "px; width:" + __setting_image_width_large + "px;vertical-align:top; text-align: center;");
			
			result.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large));
			
			result.append("</td>");
			result.HTMLAppendTagPrefix("td", "style", "text-align:left; vertical-align:top");
			
				
			boolean first = true;
			foreach j in entry.subentries
			{
				ChecklistSubentry subentry = entry.subentries[j];
				if (subentry.header == "")
					continue;
				string subheader = subentry.header;
				
				boolean indent_this_entry = false;
				if (first)
				{
					first = false;
				}
				else if (entry.should_indent_after_first_subentry)
				{
					indent_this_entry = true;
				}
				if (indent_this_entry)
					result.HTMLAppendTagPrefix("div", "class", "r_indention");
				
				result.append("<table cellpadding=0 cellspacing=0><tr><td colspan=2>");
			
				result.append(HTMLGenerateSpanOfClass(subheader, "r_cl_subheader"));
				
				result.append("</td></tr>");
				
				
				result.append("<tr>");
				result.HTMLAppendTagWrap("td", "", mapMake("style", "width:" + __setting_indention_width + ";"));
				result.append("<td>");
				if (subentry.modifiers.count() > 0)
					result.append(ChecklistGenerateModifierSpan(listJoinComponents(subentry.modifiers, ", ") + "<br>"));
				if (subentry.entries.count() > 0)
				{
					int intra_k = 0;
					while (intra_k < subentry.entries.count())
					{ 
						if (intra_k > 0)
							result.append("<hr>");
						string line = subentry.entries[listKeyForIndex(subentry.entries, intra_k)];
						line = HTMLGenerateDivOfClass(line, "r_cl_holding_container"); //For nested HRs
						
						
						result.append(line);
						
						intra_k += 1;
					}
				}
				result.append("</td></tr>");
				
				result.append("</table>");
				if (indent_this_entry)
					result.append("</div>");
			}		
			result.append("</td>");
			result.append("</tr></table>");
		}
		else*/
        if (true)
		{
        	if (__use_flexbox_on_checklists && __enable_showhide_feature)
            {
                //int approximate_height = generated_subentry_html.split_string("<").count(); //r_cl_holding_container
                string [string] showhide_map;
                showhide_map["class"] = "r_cl_l_left_showhide";
            	if (generated_entry.small_enough_for_showhide_to_ignore)// || !output_borders)
                {
                    showhide_map["class"] += " r_cl_l_left_showhide_blank";
                }
                else
                {
                	showhide_map["class"] += " r_clickable";
                	showhide_map["onmousedown"] = "showhideButtonClicked(window.event)";
                }
                result.append(HTMLGenerateTagWrap("div", " ", showhide_map));
                //result.append("<div>" + approximate_height + "</div>");
            }
			//div-based layout:
            //result.append(ChecklistGenerateEntryHTML(entry, entry.subentries, entry.url, setting_use_holding_containers_per_subentry));
            result.append(generated_subentry_html);
		}
        result.append("</div>");

		
		if (outputting_anchor && __setting_entire_area_clickable)
            result.append("</a>");
		
		intra_i += 1;
		entries_output += 1;
	}
	result.append("</div>");
	
    if (output_borders)
        result.HTMLAppendDivOfClass("", "r_cl_inter_spacing_divider");
	
	return result;
}


buffer ChecklistGenerate(Checklist cl)
{
    return ChecklistGenerate(cl, true);
}


Record ChecklistCollection
{
    Checklist [string] checklists;
};

//NOTE: WILL DESTRUCTIVELY EDIT CHECKLISTS GIVEN TO IT
//mostly because there's no easy way to copy an object in ASH
//without manually writing a copy function and insuring it is synched
Checklist [int] ChecklistCollectionMergeWithLinearList(ChecklistCollection collection, Checklist [int] other_checklists)
{
    Checklist [int] result;
    
    boolean [string] seen_titles;
    foreach key, checklist in other_checklists
    {
        seen_titles[checklist.title] = true;
        result.listAppend(checklist);
    }
    foreach key, checklist in collection.checklists
    {
        if (seen_titles contains checklist.title)
        {
            foreach key, checklist2 in result
            {
                if (checklist2.title == checklist.title)
                {
                    checklist2.entries.listAppendList(checklist.entries);
                    break;
                }
            }
        }
        else
        {
            result.listAppend(checklist);
        }
    }
    
    return result;
}

Checklist lookup(ChecklistCollection checklists, string name)
{
    if (checklists.checklists contains name)
        return checklists.checklists[name];
    
    Checklist c = ChecklistMake();
    c.title = name;
    checklists.checklists[c.title] = c;
    return c;
}

//Preferred use. Returns entry you just added:
//Example usage:
//checklists.add(C_RESOURCES, ChecklistEntryMake(etc));
//I suppose we could do...
//checklists.add(C_RESOURCES).setURL("inventory.php").setImage("__item disco ball").addSubentries(subentries).setShouldHighlightIfAdventuringAtLocation($location[noob cave]);
//What would be nice if we could do something like this:
//checklists.add(C_RESOURCES, {url:"inventory.php", image:"__item disco ball", subentry:{title:"Important Title", description:description}, highlightLocation:$location[noob cave]});
//and location: doing both url: and highlightLocation:
//checklists.add(C_RESOURCES, {location:$location[noob cave], item:$item[disco ball], subentry:{title:"Important Title", description:description}});
//with some prefix to make that work without quotes
//or better
//checklists.add(C_RESOURCES, {location:$location[noob cave], item:$item[disco ball], title:"Important Title", description:description});
//which just automatically creates a single subentry
//But, I don't think mafia's map system is strong enough for that, and functions don't allow tagging arguments like that. Alas.
ChecklistEntry add(ChecklistCollection checklists, string collection_name, ChecklistEntry entry)
{
	Checklist c = checklists.lookup(collection_name);
	return c.entries.listAppend(entry);
}


ChecklistEntry add(ChecklistCollection checklists, string collection_name)
{
	ChecklistEntry entry = ChecklistEntryMake();
	Checklist c = checklists.lookup(collection_name);
	return c.entries.listAppend(entry);
}
