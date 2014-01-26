import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Support/KOLImage.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Page.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Settings.ash"


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


int CHECKLIST_DEFAULT_IMPORTANCE = 0;
record ChecklistEntry
{
	string image_lookup_name;
	string target_location;
	ChecklistSubentry [int] subentries;
	boolean should_indent_after_first_subentry;
    
    boolean should_highlight;
	
	int importance_level; //Entries will be resorted by importance level before output, ascending order. Default importance is 0. Convention is to vary it from [-11, 11] for reasons that are clear and well supported in the narrative.
};


ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, int importance, boolean should_highlight)
{
	ChecklistEntry result;
	result.image_lookup_name = image_lookup_name;
	result.target_location = target_location;
	result.subentries = subentries;
	result.importance_level = importance;
    result.should_highlight = should_highlight;
	return result;
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, int importance)
{
    return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance, false);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, int importance, boolean [location] highlight_if_last_adventured)
{
    boolean should_highlight = false;
    
    if (highlight_if_last_adventured contains __last_adventure_location)
        should_highlight = true;
    return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance, should_highlight);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries)
{
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, CHECKLIST_DEFAULT_IMPORTANCE);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, boolean [location] highlight_if_last_adventured)
{
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, CHECKLIST_DEFAULT_IMPORTANCE, highlight_if_last_adventured);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry, int importance)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry)
{
	return ChecklistEntryMake(image_lookup_name, target_location, subentry, CHECKLIST_DEFAULT_IMPORTANCE);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry, boolean [location] highlight_if_last_adventured)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, CHECKLIST_DEFAULT_IMPORTANCE, highlight_if_last_adventured);
}


void listAppend(ChecklistEntry [int] list, ChecklistEntry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
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
	PageAddCSSClass("", "r_cl_modifier", "font-size:0.80em; color:" + __setting_modifier_color + "; display:block;");
	
	PageAddCSSClass("", "r_cl_header", "text-align:center; font-size:1.15em; font-weight:bold;");
	PageAddCSSClass("", "r_cl_subheader", "font-size:1.07em; font-weight:bold;");
	PageAddCSSClass("div", "r_cl_inter_spacing_divider", "width:100%; height:12px;");
	PageAddCSSClass("div", "r_cl_l_container", "padding-top:5px;padding-bottom:5px;");
    
    string gradient = "background: #ffffff;background: -moz-linear-gradient(left, #ffffff 50%, #F0F0F0 75%, #F0F0F0 100%);background: -webkit-gradient(linear, left top, right top, color-stop(50%,#ffffff), color-stop(75%,#F0F0F0), color-stop(100%,#F0F0F0));background: -webkit-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: -o-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: -ms-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: linear-gradient(to right, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#F0F0F0',GradientType=1 );"; //help
	PageAddCSSClass("div", "r_cl_l_container_highlighted", gradient + "padding-top:5px;padding-bottom:5px;");
    
    
	PageAddCSSClass("div", "r_cl_l_left", "float:left;width:" + __setting_image_width_large + "px;margin-left:20px;overflow:hidden;");
	PageAddCSSClass("div", "r_cl_l_right_container", "width:100%;margin-left:" + (-__setting_image_width_large - 20) + "px;float:right;text-align:left;vertical-align:top;");
	PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + (__setting_image_width_large + 20 + 2) + "px;display:inline-block;margin-right:20px;");
    
    PageAddCSSClass("hr", "r_cl_hr", "padding:0px;margin-top:0px;margin-bottom:0px;width:auto; margin-left:" + __setting_indention_width + ";margin-right:" + __setting_indention_width +";");
    PageAddCSSClass("hr", "r_cl_hr_extended", "padding:0px;margin-top:0px;margin-bottom:0px;width:auto; margin-left:" + __setting_indention_width + ";margin-right:0px;");
	PageAddCSSClass("div", "r_cl_holding_container", "display:inline-block;");
	
    
    PageAddCSSClass("", "r_cl_image_container_large", "display:block;");
    PageAddCSSClass("", "r_cl_image_container_medium", "display:none;");
    PageAddCSSClass("", "r_cl_image_container_small", "display:none;");
    
	if (true)
	{
		string div_style = "";
		div_style = "margin:0px; border:1px; border-style: solid; border-color:" + __setting_line_color + ";";
        div_style += "border-left:0px; border-right:0px;";
        div_style += "background-color:#FFFFFF; width:100%; padding-top:5px;";
		PageAddCSSClass("div", "r_cl_checklist_container", div_style);
	}
    
    //media queries:
    if (!__use_table_based_layouts)
    {
        PageAddCSSClass("div", "r_cl_l_left", "width:" + __setting_image_width_medium + "px;margin-left:10px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_right_container", "margin-left:" + (-__setting_image_width_medium - 10) + "px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + (__setting_image_width_medium + 10 + 2) + "px;margin-right:10px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:4px;padding-bottom:4px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:" + (__setting_indention_width_in_em / 2.0) + "em;margin-right:" + (__setting_indention_width_in_em / 2.0) +"em;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:" + (__setting_indention_width_in_em / 2.0) + "em;", 0, __setting_media_query_medium_size);
        
        
        PageAddCSSClass("div", "r_cl_l_left", "width:" + (__setting_image_width_small) + "px;margin-left:10px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_right_container", "margin-left:" + (-(__setting_image_width_small) - 10) + "px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + ((__setting_image_width_small) + 10 + 10) + "px;margin-right:3px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:0px;margin-right:0px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:0px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:3px;padding-bottom:3px;", 0, __setting_media_query_small_size);
        
        
        PageAddCSSClass("div", "r_cl_l_left", "width:" + (0) + "px;margin-left:3px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_l_right_container", "margin-left:" + (-(0) - 3) + "px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + ((0) + 3 + 2) + "px;margin-right:3px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:0px;margin-right:0px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:0px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:3px;padding-bottom:3px;", 0, __setting_media_query_tiny_size);
        
        
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:block;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:none;", 0, __setting_media_query_medium_size);
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:none;", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:block;", 0, __setting_media_query_small_size);
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:none;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:none;", 0, __setting_media_query_tiny_size);
        
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

buffer ChecklistGenerate(Checklist cl, boolean output_borders)
{
	ChecklistEntry [int] entries = cl.entries;
	
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
				ChecklistSubentry subentry = entry.subentries[j];
				foreach k in subentry.entries
				{
					string [int] line_split = split_string_mutable(subentry.entries[k], "\\|");
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
					foreach key in line_split
					{
						string line = line_split[key];
						if (!contains_text(line, "class=\"r_indention\"") && !first) //hack way of testing for indention
						{
							building_line.append("<br>");
						}
						building_line.append(line);
						first = false;
					}
					subentry.entries[k] = to_string(building_line);
				}
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
        result.append(HTMLGenerateDivOfClass("", "r_cl_inter_spacing_divider")); //spacing
	
    if (!cl.disable_generating_id)
        result.append(HTMLGenerateTagWrap("a", "", mapMake("id", HTMLConvertStringToAnchorID(cl.title), "class", "r_cl_internal_anchor")));
	
    string [string] main_container_map;
    main_container_map["class"] = "r_cl_checklist_container";
    if (!cl.disable_generating_id)
        main_container_map["id"] = HTMLConvertStringToAnchorID(cl.title + " checklist container");
    if (!output_borders)
        main_container_map["style"] = "border:0px;";
    result.append(HTMLGenerateTagPrefix("div", main_container_map));
	
	
	result.append(HTMLGenerateDivOfClass(cl.title, "r_cl_header"));
	
	if (special_subheader != "")
		result.append(ChecklistGenerateModifierSpan(special_subheader));
	
	int starting_intra_i = 0;
	if (skip_first_entry)
		starting_intra_i = 1;
	int intra_i = 0;
	int entries_output = 0;
    boolean last_was_highlighted = false;
	foreach i in entries
	{
		if (intra_i < starting_intra_i)
		{
			intra_i += 1;
			continue;
		}
		ChecklistEntry entry = entries[i];
		if (intra_i > starting_intra_i)
		{
            boolean next_is_highlighted = false;
            if (entry.should_highlight)
                next_is_highlighted = true;
            string class_name = "r_cl_hr";
            if (last_was_highlighted || next_is_highlighted)
                class_name = "r_cl_hr_extended";
			result.append(HTMLGenerateTagPrefix("hr", mapMake("class", class_name)));
		}
        if (__use_table_based_layouts)
            __setting_entire_area_clickable = true;
		boolean outputting_anchor = false;
        buffer anchor_prefix_html;
        buffer anchor_suffix_html;
		if (entry.target_location != "")
		{
            anchor_prefix_html = HTMLGenerateTagPrefix("a", mapMake("target", "mainpane", "href", entry.target_location, "class", "r_a_undecorated"));
			anchor_suffix_html.append("</a>");
			outputting_anchor = true;
		}
        if (outputting_anchor && __setting_entire_area_clickable)
			result.append(anchor_prefix_html);
		
		boolean setting_use_holding_containers_per_subentry = true;
			
		Vec2i max_image_dimensions_large = Vec2iMake(__setting_image_width_large,75);
		Vec2i max_image_dimensions_medium = Vec2iMake(__setting_image_width_medium,50);
		Vec2i max_image_dimensions_small = Vec2iMake(__setting_image_width_small,50);
        
        string container_class = "r_cl_l_container";
        if (entry.should_highlight)
            container_class = "r_cl_l_container_highlighted";
        last_was_highlighted = entry.should_highlight;
        result.append(HTMLGenerateTagPrefix("div", mapMake("class", container_class)));
        
		if (__use_table_based_layouts)
		{
			//table-based layout:
			result.append("<table cellpadding=0 cellspacing=0><tr>");
			
			result.append(HTMLGenerateTagWrap("td", "", mapMake("style", "width:" + __setting_indention_width + ";")));
			result.append("<td>");
			result.append(HTMLGenerateTagPrefix("td", mapMake("style", "min-width:" + __setting_image_width_large + "px; max-width:" + __setting_image_width_large + "px; width:" + __setting_image_width_large + "px;vertical-align:top; text-align: center;")));
			
			result.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large));
			
			result.append("</td>");
			result.append(HTMLGenerateTagPrefix("td", mapMake("style", "text-align:left; vertical-align:top")));
			
				
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
					result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_indention")));
				
				result.append("<table cellpadding=0 cellspacing=0><tr><td colspan=2>");
			
				result.append(HTMLGenerateSpanOfClass(subheader, "r_cl_subheader"));
				
				result.append("</td></tr>");
				
				
				result.append("<tr>");
				result.append(HTMLGenerateTagWrap("td", "", mapMake("style", "width:" + __setting_indention_width + ";")));
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
		else
		{
			//div-based layout:
            
            if (true)
            {
                
                buffer image_container;
                
                if (outputting_anchor && !__setting_entire_area_clickable)
                    image_container.append(anchor_prefix_html);
                
                image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large, "r_cl_image_container_large"));
                image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_medium, "r_cl_image_container_medium"));
                image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_small, "r_cl_image_container_small"));
                
                if (outputting_anchor && !__setting_entire_area_clickable)
                    image_container.append(anchor_suffix_html);
                
                result.append(HTMLGenerateDivOfClass(image_container, "r_cl_l_left"));
                
            }
            else
                result.append(HTMLGenerateDivOfClass(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large), "r_cl_l_left"));
            
            
			result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_l_right_container")));
            
            if (outputting_anchor && !__setting_entire_area_clickable)
                result.append(anchor_prefix_html);
			result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_l_right_content")));
			
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
					result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_indention")));
				
				result.append(HTMLGenerateSpanOfClass(subheader, "r_cl_subheader"));
				result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_indention")));
				if (subentry.modifiers.count() > 0)
					result.append(ChecklistGenerateModifierSpan(listJoinComponents(subentry.modifiers, ", ")));
				if (subentry.entries.count() > 0)
				{
					int intra_k = 0;
					if (setting_use_holding_containers_per_subentry)
						result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_holding_container"))); //HRs
					while (intra_k < subentry.entries.count())
					{ 
						if (intra_k > 0)
							result.append("<hr>");
						string line = subentry.entries[listKeyForIndex(subentry.entries, intra_k)];
						
						//if (line.contains_text("<hr"))
						line = HTMLGenerateDivOfClass(line, "r_cl_holding_container"); //For nested HRs, sizes them down a bit
						
						result.append(line);
						
						intra_k += 1;
					}
					if (setting_use_holding_containers_per_subentry)
						result.append("</div>");
				}
				result.append("</div>");
				if (indent_this_entry)
					result.append("</div>");
			}
			result.append("</div>");
                if (outputting_anchor && !__setting_entire_area_clickable)
                    result.append(anchor_suffix_html);
			result.append("</div>");
			result.append(HTMLGenerateDivOfClass("", "r_end_floating_elements")); //stop floating
		}
        result.append("</div>");

		
		if (outputting_anchor && __setting_entire_area_clickable)
            result.append(anchor_suffix_html);
		
		intra_i += 1;
		entries_output += 1;
	}
	result.append("</div>");
	
    if (output_borders)
        result.append(HTMLGenerateDivOfClass("", "r_cl_inter_spacing_divider"));
	
	return result;
}


buffer ChecklistGenerate(Checklist cl)
{
    return ChecklistGenerate(cl, true);
}