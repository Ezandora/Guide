import "relay/Guide/Support/List.ash"


float __setting_indention_width_in_em = 1.45;
string __setting_indention_width = __setting_indention_width_in_em + "em";

string __html_right_arrow_character = "&#9658;";

//Design note: try to prefer HTMLAppend to HTMLGenerate due to lack of temporary objects.


buffer HTMLAppendTagPrefix(buffer out, string tag, string attribute_1, string value_1, string attribute_2, string value_2)
{
	out.append("<");
	out.append(tag);
	
    out.append(" ");
    out.append(attribute_1);
    if (value_1 != "")
    {
        boolean is_integer = value_1.is_integer(); //don't put quotes around integer attributes (i.e. width, height)
        
        out.append("=");
        if (!is_integer)
            out.append("\"");
        out.append(value_1);
        if (!is_integer)
            out.append("\"");
    }
    
    out.append(" ");
    out.append(attribute_2);
    if (value_2 != "")
    {
        boolean is_integer = value_2.is_integer(); //don't put quotes around integer attributes (i.e. width, height)
        
        out.append("=");
        if (!is_integer)
            out.append("\"");
        out.append(value_2);
        if (!is_integer)
            out.append("\"");
    }
    
    
    
	out.append(">");
	return out;
}

buffer HTMLAppendTagPrefix(buffer out, string tag, string attribute_1, string value_1)
{
	out.append("<");
	out.append(tag);
	
    out.append(" ");
    out.append(attribute_1);
    if (value_1 != "")
    {
        boolean is_integer = value_1.is_integer(); //don't put quotes around integer attributes (i.e. width, height)
        
        out.append("=");
        if (!is_integer)
            out.append("\"");
        out.append(value_1);
        if (!is_integer)
            out.append("\"");
    }
    
    
	out.append(">");
	return out;
}

buffer HTMLAppendTagPrefix(buffer out, string tag, string [string] attributes)
{
	out.append("<");
	out.append(tag);
	foreach attribute_name, attribute_value in attributes
	{
		//string attribute_value = attributes[attribute_name];
		out.append(" ");
		out.append(attribute_name);
		if (attribute_value != "")
		{
			boolean is_integer = attribute_value.is_integer(); //don't put quotes around integer attributes (i.e. width, height)
			
			out.append("=");
			if (!is_integer)
				out.append("\"");
			out.append(attribute_value);
			if (!is_integer)
				out.append("\"");
		}
	}
	out.append(">");
	return out;
}

buffer HTMLGenerateTagPrefix(string tag, string [string] attributes)
{
	buffer result;
	return HTMLAppendTagPrefix(result, tag, attributes);
}

buffer HTMLAppendTagPrefix(buffer out, string tag)
{
    out.append("<");
    out.append(tag);
    out.append(">");
    return out;
}

buffer HTMLGenerateTagPrefix(string tag)
{
    buffer result;
    result.append("<");
    result.append(tag);
    result.append(">");
    return result;
}


buffer HTMLAppendTagSuffix(buffer out, string tag)
{
    out.append("</");
    out.append(tag);
    out.append(">");
    return out;
}

buffer HTMLGenerateTagSuffix(string tag)
{
    buffer result;
    return result.HTMLAppendTagSuffix(tag);
}

buffer HTMLAppendTagWrap(buffer out, string tag, string source, string [string] attributes)
{
    out.HTMLAppendTagPrefix(tag, attributes);
    out.append(source);
    out.HTMLAppendTagSuffix(tag);
	return out;
}

buffer HTMLGenerateTagWrap(string tag, string source, string [string] attributes)
{
    buffer result;
    return result.HTMLAppendTagWrap(tag, source, attributes);
}

buffer HTMLGenerateTagWrap(string tag, string source)
{
    buffer result;
    result.HTMLAppendTagPrefix(tag);
    result.append(source);
    result.HTMLAppendTagSuffix(tag);
	return result;
}

buffer HTMLAppendDivOfClass(buffer out, string source, string class_name)
{
	if (class_name == "")
	{
		out.append("<div>");
		//return HTMLGenerateTagWrap("div", source);
    }
	else
	{
		out.append("<div class=\"");
        out.append(class_name);
        out.append("\">");
		//return HTMLGenerateTagWrap("div", source, mapMake("class", class_name));
    }
    out.append(source);
    out.append("</div>");
    
    return out;
}

buffer HTMLGenerateDivOfClass(string source, string class_name)
{
	buffer out;
	out.HTMLAppendDivOfClass(source, class_name);
	return out;
}

buffer HTMLGenerateDivOfClassAndStyle(string source, string class_name, string extra_style)
{
	return HTMLGenerateTagWrap("div", source, mapMake("class", class_name, "style", extra_style));
}

buffer HTMLGenerateDivOfStyle(string source, string style)
{
	if (style == "")
		return HTMLGenerateTagWrap("div", source);
	
	return HTMLGenerateTagWrap("div", source, mapMake("style", style));
}

buffer HTMLGenerateDiv(string source)
{
    return HTMLGenerateTagWrap("div", source);
}

buffer HTMLGenerateSpan(string source)
{
    return HTMLGenerateTagWrap("span", source);
}

buffer HTMLGenerateSpanOfClass(string source, string class_name)
{
	if (class_name == "")
		return HTMLGenerateTagWrap("span", source);
	else
		return HTMLGenerateTagWrap("span", source, mapMake("class", class_name));
}

buffer HTMLGenerateSpanOfStyle(string source, string style)
{
	if (style == "")
    {
        buffer out;
        out.append(source);
        return out;
    }
	return HTMLGenerateTagWrap("span", source, mapMake("style", style));
}

buffer HTMLGenerateSpanFont(string source, string font_colour, string font_size)
{
	if (font_colour == "" && font_size == "")
    {
        buffer out;
        out.append(source);
        return out;
    }
		
	buffer style;
	
	if (font_colour != "")
    {
		//style += "color:" + font_colour + ";";
        style.append("color:");
        style.append(font_colour);
        style.append(";");
    }
	if (font_size != "")
    {
		//style += "font-size:" + font_size + ";";
        style.append("font-size:");
        style.append(font_size);
        style.append(";");
    }
	return HTMLGenerateSpanOfStyle(source, style.to_string());
}

buffer HTMLGenerateSpanFont(string source, string font_colour)
{
    return HTMLGenerateSpanFont(source, font_colour, "");
}

string HTMLConvertStringToAnchorID(string id)
{
    if (id.length() == 0)
        return id;
    
	id = to_string(replace_string(id, " ", "_"));
	//ID and NAME must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".")
    
	//FIXME do that
	return id;
}

string HTMLEscapeString(string line)
{
    return entity_encode(line);
}

string HTMLStripTags(string html)
{
    matcher pattern = create_matcher("<[^>]*>", html);
    return pattern.replace_all("");
}


string [string] generateMainLinkMap(string url)
{
    return mapMake("class", "r_a_undecorated", "href", url, "target", "mainpane");
}



string HTMLGreyOutTextUnlessTrue(string text, boolean conditional)
{
    if (conditional)
        return text;
    return HTMLGenerateSpanFont(text, "gray");
}

//Should this be here...? Might be "Guide" instead of this.
string HTMLGenerateTooltip(string underline_text, string inner_html)
{
	return HTMLGenerateSpanOfClass(HTMLGenerateSpanOfClass(inner_html, "r_tooltip_inner_class") + underline_text, "r_tooltip_outer_class");
}
