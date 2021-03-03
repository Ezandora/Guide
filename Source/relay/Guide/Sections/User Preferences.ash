string [string] __user_preferences_private;
boolean __read_user_preferences_initially = false;



//File implementation:
//Preferred, but not chosen in case this somehow triggers an HD read too often:
/*string __user_preferences_file_name = "data/relay_ezandora_guide_preferences_" + my_id() + ".txt";
void readUserPreferences()
{
    __read_user_preferences_initially = true;
    file_to_map(__user_preferences_file_name, __user_preferences_private);
}

void writeUserPreferences()
{
    map_to_file(__user_preferences_private, __user_preferences_file_name);
}*/


string __user_preferences_property_name = "ezandora_guide_preferences";
void readUserPreferences()
{
    string [string] blank;
    __user_preferences_private = blank;
    string guide_value = get_property(__user_preferences_property_name);
    foreach key, pair in guide_value.split_string_alternate(";")
    {
        string [int] split = pair.split_string_alternate("=");
        if (split.count() != 2)
            continue;
        __user_preferences_private[split[0]] = split[1];
    }
    __read_user_preferences_initially = true;
}

void writeUserPreferences()
{
    if (!__read_user_preferences_initially)
        readUserPreferences();
    buffer output_value;
    boolean first = true;
    foreach key, value in __user_preferences_private
    {
        if (!first)
            output_value.append(";");
        else
            first = false;
        output_value.append(key);
        output_value.append("=");
        output_value.append(value);
    }
    set_property(__user_preferences_property_name, output_value);
}


string PreferenceGet(string name)
{
    if (!__read_user_preferences_initially)
        readUserPreferences();
    
    return __user_preferences_private[name];
}

boolean PreferenceGetBoolean(string name)
{
    return PreferenceGet(name).to_boolean();
}

void PreferenceSet(string name, string value)
{
	//print_html("PreferenceSet(" + name + ", " + value + ")");
    if (!__read_user_preferences_initially)
        readUserPreferences();
    __user_preferences_private[name] = value;
    writeUserPreferences();
}


void processSetUserPreferences(string [string] form_fields)
{
    foreach key, value in form_fields
    {
        if (key == "set user preferences")
            continue;
        PreferenceSet(key, value);
    }
}
