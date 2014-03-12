//This script and its support scripts are in the public domain.

//These settings are for development. Don't worry about editing them.
string __version = "1.0.24";

//Debugging:
boolean __setting_debug_mode = false;
boolean __setting_debug_enable_example_mode_in_aftercore = false; //for testing. Will give false information, so don't enable
boolean __setting_debug_show_all_internal_states = false; //displays usable images/__misc_state/__misc_state_string/__misc_state_int/__quest_state

//Display settings:
boolean __setting_entire_area_clickable = false;
boolean __setting_side_negative_space_is_dark = false;
boolean __setting_fill_vertical = true;
int __setting_image_width_large = 100;
int __setting_image_width_medium = 70;
int __setting_image_width_small = 30;

boolean __show_importance_bar = true;
boolean __setting_show_navbar = true;
boolean __setting_navbar_has_proportional_widths = false; //doesn't look very good, remove?
boolean __use_table_based_layouts = false; //backup implementation
boolean __setting_use_kol_css = false; //images/styles.css

string __setting_unavailable_color = "#7F7F7F";
string __setting_line_color = "#B2B2B2";
string __setting_dark_color = "#C0C0C0";
string __setting_modifier_color = "#404040";
string __setting_navbar_background_color = "#FFFFFF";
string __setting_page_background_color = "#F7F7F7";

string __setting_media_query_large_size = "@media (min-width: 500px)";
string __setting_media_query_medium_size = "@media (min-width: 320px) and (max-width: 500px)";
string __setting_media_query_small_size = "@media (max-width: 320px) and (min-width: 225px)";
string __setting_media_query_tiny_size = "@media (max-width: 225px)";



float __setting_navbar_height_in_em = 2.3;
string __setting_navbar_height = __setting_navbar_height_in_em + "em";
int __setting_horizontal_width = 600;
boolean __setting_ios_appearance = false; //no don't

//Runtime variables:
string __relay_filename;
location __last_adventure_location;

//Allows error checking. The intention behind this design is Errors are passed in to a method. The method then sets the error if anything went wrong.
record Error
{
	boolean was_error;
	string explanation;
};

Error ErrorMake(boolean was_error, string explanation)
{
	Error err;
	err.was_error = was_error;
	err.explanation = explanation;
	return err;
}

Error ErrorMake()
{
	return ErrorMake(false, "");
}

void ErrorSet(Error err, string explanation)
{
	err.was_error = true;
	err.explanation = explanation;
}

void ErrorSet(Error err)
{
	ErrorSet(err, "Unknown");
}

//Coordinate system is upper-left origin.

int INT32_MAX = 2147483647;



float clampf(float v, float min_value, float max_value)
{
	if (v > max_value)
		return max_value;
	if (v < min_value)
		return min_value;
	return v;
}

float clampNormalf(float v)
{
	return clampf(v, 0.0, 1.0);
}

int clampi(int v, int min_value, int max_value)
{
	if (v > max_value)
		return max_value;
	if (v < min_value)
		return min_value;
	return v;
}
float clampNormali(int v)
{
	return clampi(v, 0, 1);
}

//random() will halt the script if range is <= 1, which can happen when picking a random object out of a variable-sized list.
int random_safe(int range)
{
	if (range < 2)
		return 0;
	return random(range);
}

//to_int will print a warning, but not halt, if you give it a non-int value.
//This function prevents the warning message.
//err is set if value is not an integer.
int to_int_silent(string value, Error err)
{
	if (is_integer(value))
        return to_int(value);
    ErrorSet(err, "Unknown integer \"" + value + "\".");
	return 0;
}

int to_int_silent(string value)
{
	return to_int_silent(value, ErrorMake());
}

//Allows for fractional digits, not just whole numbers. Useful for preventing "+233.333333333333333% item"-type output.
//Outputs 3.0, 3.1, 3.14, etc.
float round(float v, int additional_fractional_digits)
{
	if (additional_fractional_digits < 1)
		return v.round().to_float();
	float multiplier = 10.0 * additional_fractional_digits;
	return to_float(round(v * multiplier)) / multiplier;
}

//Similar to round() addition above, but also converts whole float numbers into integers for output
string roundForOutput(float v, int additional_fractional_digits)
{
	v = round(v, additional_fractional_digits);
	int vi = v.to_int();
	if (vi.to_float() == v)
		return vi.to_string();
	else
		return v.to_string();
}

float sqrt(float v, Error err)
{
    if (v < 0.0)
    {
        ErrorSet(err, "Cannot take square root of value " + v + " less than 0.0");
        return -1.0; //mathematically incorrect, but prevents halting. should return NaN
    }
	return square_root(v);
}

float sqrt(float v)
{
    return sqrt(v, ErrorMake());
}

float fabs(float v)
{
    if (v < 0.0)
        return -v;
    return v;
}

int abs(int v)
{
    if (v < 0)
        return -v;
    return v;
}

int ceiling(float v)
{
	return ceil(v);
}

int pow2i(int v)
{
	return v * v;
}

//x^p
float powf(float x, float p)
{
    return x ** p;
}

//x^p
int powi(int x, int p)
{
    return x ** p;
}

record Vec2i
{
	int x; //or width
	int y; //or height
};

Vec2i Vec2iMake(int x, int y)
{
	Vec2i result;
	result.x = x;
	result.y = y;
	
	return result;
}

Vec2i Vec2iCopy(Vec2i v)
{
    return Vec2iMake(v.x, v.y);
}

Vec2i Vec2iZero()
{
	return Vec2iMake(0,0);
}


record Rect
{
	Vec2i min_coordinate;
	Vec2i max_coordinate;
};

Rect RectMake(Vec2i min_coordinate, Vec2i max_coordinate)
{
	Rect result;
	result.min_coordinate = Vec2iCopy(min_coordinate);
	result.max_coordinate = Vec2iCopy(max_coordinate);
	return result;
}
Rect RectCopy(Rect r)
{
    return RectMake(r.min_coordinate, r.max_coordinate);
}

Rect RectMake(int min_x, int min_y, int max_x, int max_y)
{
	return RectMake(Vec2iMake(min_x, min_y), Vec2iMake(max_x, max_y));
}

Rect RectZero()
{
	return RectMake(Vec2iZero(), Vec2iZero());
}


void listAppend(Rect [int] list, Rect entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}
string listLastObject(string [int] list)
{
    if (list.count() == 0)
        return "";
    return list[list.count() - 1];
}

void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(string [int] list, string [int] entries)
{
	foreach key in entries
		list.listAppend(entries[key]);
}

void listAppend(item [int] list, item entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(item [int] list, item [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}



void listAppend(int [int] list, int entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(location [int] list, location entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(location [int] list, location [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}

void listAppend(effect [int] list, effect entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int] list, skill entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(familiar [int] list, familiar entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}




void listAppend(string [int][int] list, string [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listPrepend(string [int] list, string entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}


void listClear(string [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}
void listClear(int [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}
void listClear(location [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

string [int] listMakeBlankString()
{
	string [int] result;
	return result;
}

item [int] listMakeBlankItem()
{
	item [int] result;
	return result;
}

location [int] listMakeBlankLocation()
{
	location [int] result;
	return result;
}


string [int] listMake(string e1)
{
	string [int] result;
	result.listAppend(e1);
	return result;
}

string [int] listMake(string e1, string e2)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

string [int] listMake(string e1, string e2, string e3)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4, string e5)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

int [int] listMake(int e1)
{
	int [int] result;
	result.listAppend(e1);
	return result;
}

int [int] listMake(int e1, int e2)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

int [int] listMake(int e1, int e2, int e3)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

int [int] listMake(int e1, int e2, int e3, int e4)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

int [int] listMake(int e1, int e2, int e3, int e4, int e5)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

item [int] listMake(item e1)
{
	item [int] result;
	result.listAppend(e1);
	return result;
}

item [int] listMake(item e1, item e2)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

item [int] listMake(item e1, item e2, item e3)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

item [int] listMake(item e1, item e2, item e3, item e4)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

item [int] listMake(item e1, item e2, item e3, item e4, item e5)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

skill [int] listMake(skill e1)
{
	skill [int] result;
	result.listAppend(e1);
	return result;
}

skill [int] listMake(skill e1, skill e2)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3, skill e4)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3, skill e4, skill e5)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

string listJoinComponents(string [int] list, string joining_string, string and_string)
{
	buffer result;
	boolean first = true;
	int number_seen = 0;
	foreach i in list
	{
		if (first)
		{
			result.append(list[i]);
			first = false;
		}
		else
		{
			if (!(list.count() == 2 && and_string.length() > 0))
				result.append(joining_string);
			if (and_string.length() > 0 && number_seen == list.count() - 1)
			{
				result.append(" ");
				result.append(and_string);
				result.append(" ");
			}
			result.append(list[i]);
		}
		number_seen = number_seen + 1;
	}
	return result.to_string();
}

string listJoinComponents(string [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


string listJoinComponents(item [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert items to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(item [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}



string listJoinComponents(location [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert locations to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(location [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


void listRemoveKeys(string [int] list, int [int] keys_to_remove)
{
	foreach i in keys_to_remove
	{
		int key = keys_to_remove[i];
		if (!(list contains key))
			continue;
		remove list[key];
	}
}

string [string] mapMake()
{
	string [string] result;
	return result;
}

string [string] mapMake(string key1, string value1)
{
	string [string] result;
	result[key1] = value1;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3, string key4, string value4)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	result[key4] = value4;
	return result;
}
boolean [string] listGeneratePresenceMap(string [int] list)
{
	boolean [string] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [location] listGeneratePresenceMap(location [int] list)
{
	boolean [location] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

int [int] listConvertToInt(string [int] list)
{
	int [int] result;
	foreach key in list
		result[key] = list[key].to_int();
	return result;
}

item [int] listConvertToItem(string [int] list)
{
	item [int] result;
	foreach key in list
		result[key] = list[key].to_item();
	return result;
}

string listFirstObject(string [int] list)
{
    foreach key in list
        return list[key];
    return "";
}

//(I'm assuming maps have a consistent enumeration order, which may not be the case)
int listKeyForIndex(string [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int llistKeyForIndex(string [int][int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

string listGetRandomObject(string [int] list)
{
    if (list.count() == 0)
        return "";
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}


//Additions to standard API:
//Auto-conversion property functions:
boolean get_property_boolean(string property)
{
	return get_property(property).to_boolean();
}

int get_property_int(string property)
{
	return get_property(property).to_int_silent();
}

location get_property_location(string property)
{
	return get_property(property).to_location();
}

float get_property_float(string property)
{
	return get_property(property).to_float();
}

monster get_property_monster(string property)
{
	return get_property(property).to_monster();
}

buffer to_buffer(string str)
{
	buffer result;
	result.append(str);
	return result;
}


int PATH_UNKNOWN = -1;
int PATH_NONE = 0;
int PATH_TEETOTALER = 1;
int PATH_BOOZETAFARIAN = 2;
int PATH_OXYGENARIAN = 3;

int PATH_BEES_HATE_YOU = 9;
int PATH_WAY_OF_THE_SURPRISING_FIST = 10;
int PATH_TRENDY = 11;
int PATH_AVATAR_OF_BORIS = 12;
int PATH_BUGBEAR_INVASION = 13;
int PATH_ZOMBIE_SLAYER = 14;
int PATH_CLASS_ACT = 15;
int PATH_AVATAR_OF_JARLSBERG = 16;
int PATH_BIG = 17;
int PATH_KOLHS = 18;
int PATH_CLASS_ACT_2 = 19;
int PATH_AVATAR_OF_SNEAKY_PETE = 20;

int __my_path_id_cached = -11;
int my_path_id()
{
    if (__my_path_id_cached != -11)
        return __my_path_id_cached;
    string path_name = my_path();
    
    if (path_name == "" || path_name == "None")
        __my_path_id_cached = PATH_NONE;
    else if (path_name == "Teetotaler")
        __my_path_id_cached = PATH_TEETOTALER;
    else if (path_name == "Boozetafarian")
        __my_path_id_cached = PATH_BOOZETAFARIAN;
    else if (path_name == "Oxygenarian")
        __my_path_id_cached = PATH_OXYGENARIAN;
    else if (path_name == "Bees Hate You")
        __my_path_id_cached = PATH_BEES_HATE_YOU;
    else if (path_name == "Way of the Surprising Fist")
        __my_path_id_cached = PATH_WAY_OF_THE_SURPRISING_FIST;
    else if (path_name == "Trendy")
        __my_path_id_cached = PATH_TRENDY;
    else if (path_name == "Avatar of Boris")
        __my_path_id_cached = PATH_AVATAR_OF_BORIS;
    else if (path_name == "Bugbear Invasion")
        __my_path_id_cached = PATH_BUGBEAR_INVASION;
    else if (path_name == "Zombie Slayer")
        __my_path_id_cached = PATH_ZOMBIE_SLAYER;
    else if (path_name == "Class Act")
        __my_path_id_cached = PATH_CLASS_ACT;
    else if (path_name == "Avatar of Jarlsberg")
        __my_path_id_cached = PATH_AVATAR_OF_JARLSBERG;
    else if (path_name == "BIG!")
        __my_path_id_cached = PATH_BIG;
    else if (path_name == "KOLHS")
        __my_path_id_cached = PATH_KOLHS;
    else if (path_name == "Class Act II: A Class For Pigs")
        __my_path_id_cached = PATH_CLASS_ACT_2;
    else if (path_name == "Avatar of Sneaky Pete")
        __my_path_id_cached = PATH_AVATAR_OF_SNEAKY_PETE;
    else
        __my_path_id_cached = PATH_UNKNOWN;
    return __my_path_id_cached;
}

boolean have_familiar_replacement(familiar f)
{
    //have_familiar bugs in avatar of sneaky pete for now, so:
    if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
        return false;
    return f.have_familiar();
}

//Similar to have_familiar, except it also checks trendy (not sure if have_familiar supports trendy) and 100% familiar runs
boolean familiar_is_usable(familiar f)
{
    if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
        return false;
	int single_familiar_run = get_property_int("singleFamiliarRun");
	if (single_familiar_run != -1 && my_turncount() >= 30) //after 30 turns, they're probably sure
	{
		if (f == single_familiar_run.to_familiar())
			return true;
		return false;
	}
	if (my_path_id() == PATH_TRENDY)
	{
		if (!is_trendy(f))
			return false;
	}
	else if (my_path_id() == PATH_BEES_HATE_YOU)
	{
		if (f.to_string().contains_text("b") || f.to_string().contains_text("B")) //bzzzz!
			return false; //so not green
	}
	return have_familiar(f);
}

//Possibly skill_is_usable as well, for trendy and such.

boolean in_ronin()
{
	return !can_interact();
}

//split_string returns an immutable array, which will error on certain edits
//Use this function - it converts to an editable map.
string [int] split_string_mutable(string source, string delimiter)
{
	string [int] immutable_array = split_string(source, delimiter);
	string [int] result;
	foreach key in immutable_array
		result[key] = immutable_array[key];
	return result;
}


//Same as my_primestate(), except refers to substat
stat my_primesubstat()
{
	if (my_primestat() == $stat[muscle])
		return $stat[submuscle];
	else if (my_primestat() == $stat[mysticality])
		return $stat[submysticality];
	else if (my_primestat() == $stat[moxie])
		return $stat[submoxie];
	return $stat[none];
}

item [int] items_missing(boolean [item] items)
{
    item [int] result;
    foreach it in items
    {
        if (it.available_amount() == 0)
            result.listAppend(it);
    }
    return result;
}

string slot_to_string(slot s)
{
    if (s == $slot[acc1] || s == $slot[acc2] || s == $slot[acc3])
        return "accessory";
    else if (s == $slot[sticker1] || s == $slot[sticker2] || s == $slot[sticker3])
        return "sticker";
    else if (s == $slot[folder1] || s == $slot[folder2] || s == $slot[folder3] || s == $slot[folder4] || s == $slot[folder5])
        return "folder";
    else if (s == $slot[fakehand])
        return "fake hand";
    else if (s == $slot[crown-of-thrones])
        return "crown of thrones";
    //else if (s == $slot[buddy-bjorn])
        //return "buddy bjorn";
    return s;
}

int available_amount(boolean [item] items)
{
    //Usage:
    //$items[disco ball, corrupted stardust].available_amount()
    //Returns the total number of all items.
    int count = 0;
    foreach it in items
    {
        count += it.available_amount();
    }
    return count;
}

int available_amount(item [int] items)
{
    int count = 0;
    foreach key in items
    {
        count += items[key].available_amount();
    }
    return count;
}

int equipped_amount(boolean [item] items)
{
    int count = 0;
    foreach it in items
    {
        count += it.equipped_amount();
    }
    return count;
}

int [item] creatable_items(boolean [item] items)
{
    int [item] creatable_items;
    foreach it in items
    {
        if (it.creatable_amount() == 0)
            continue;
        creatable_items[it] = it.creatable_amount();
    }
    return creatable_items;
}


item [slot] equipped_items()
{
    item [slot] result;
    foreach s in $slots[]
    {
        item it = s.equipped_item();
        if (it == $item[none])
            continue;
        result[s] = it;
    }
    return result;
}

//Have at least one of these familiars:
boolean have_familiar_replacement(boolean [familiar] familiars)
{
    foreach f in familiars
    {
        if (f.have_familiar())
            return true;
    }
    return false;
}


string format_today_to_string(string desired_format)
{
    return format_date_time("yyyyMMdd", today_to_string(), desired_format);
}

item [int] missing_outfit_components(string outfit_name)
{
    item [int] outfit_pieces = outfit_pieces(outfit_name);
    item [int] missing_components;
    foreach key in outfit_pieces
    {
        item it = outfit_pieces[key];
        if (it.available_amount() == 0)
            missing_components.listAppend(it);
    }
    return missing_components;
}

//have_outfit() will tell you if you have an outfit, but only if you pass stat checks. This does not stat check:
boolean have_outfit_components(string outfit_name)
{
    return (outfit_name.missing_outfit_components().count() == 0);
}

string int_to_wordy(int v) //Not complete, only supports a handful:
{
    string [int] matches = split_string("zero,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen,twenty,twenty-one,twenty-two,twenty-three", ",");
    if (matches contains v)
        return matches[v];
    return v.to_string();
}

//Non-API-related functions:
boolean playerIsLoggedIn()
{
    return !(my_hash().length() == 0 || my_id() == 0);
}

int substatsForLevel(int level)
{
	if (level == 1)
		return 0;
	return pow2i(pow2i(level - 1) + 4);
}

int availableFullness()
{
	return fullness_limit() - my_fullness();
}

int availableDrunkenness()
{
	return inebriety_limit() - my_inebriety();
}

int availableSpleen()
{
	return spleen_limit() - my_spleen_use();
}

boolean stringHasPrefix(string s, string prefix)
{
	if (s.length() < prefix.length())
		return false;
	else if (s.length() == prefix.length())
		return (s == prefix);
	else if (substring(s, 0, prefix.length()) == prefix)
		return true;
	return false;
}
string capitalizeFirstLetter(string v)
{
	buffer buf = v.to_buffer();
	if (v.length() <= 0)
		return v;
	buf.replace(0, 1, buf.char_at(0).to_upper_case());
	return buf.to_string();
}



item [int] missingComponentsToMakeItemPrivateImplementation(item it, int it_amounted_needed, int recursion_limit_remaining)
{
	item [int] result;
    if (recursion_limit_remaining <= 0) //possible loop
        return result;
	if (it.available_amount() >= it_amounted_needed)
        return result;
	int [item] ingredients = get_ingredients(it);
	if (ingredients.count() == 0)
    {
        for i from 1 to (it_amounted_needed - it.available_amount())
            result.listAppend(it);
    }
	foreach ingredient in ingredients
	{
		int ingredient_amounted_needed = ingredients[ingredient];
		if (ingredient.available_amount() >= ingredient_amounted_needed) //have enough
            continue;
		//split:
		item [int] r = missingComponentsToMakeItemPrivateImplementation(ingredient, ingredient_amounted_needed, recursion_limit_remaining - 1);
        if (r.count() > 0)
        {
            result.listAppendList(r);
        }
	}
	return result;
}

item [int] missingComponentsToMakeItem(item it, int it_amounted_needed)
{
    return missingComponentsToMakeItemPrivateImplementation(it, it_amounted_needed, 30);
}


item [int] missingComponentsToMakeItem(item it)
{
    return missingComponentsToMakeItem(it, 1);
}

//For tracking time deltas. Won't accurately compare across day boundaries and isn't monotonic (be wary of negative deltas), but still useful for temporal rate limiting.
int getMillisecondsOfToday()
{
    //To replicate value in GCLI:
    //ash (now_to_string("H").to_int() * 60 * 60 * 1000 + now_to_string("m").to_int() * 60 * 1000 + now_to_string("s").to_int() * 1000 + now_to_string("S").to_int())
    return now_to_string("H").to_int_silent() * 60 * 60 * 1000 + now_to_string("m").to_int_silent() * 60 * 1000 + now_to_string("s").to_int_silent() * 1000 + now_to_string("S").to_int_silent();
}

//WARNING: Only accurate for up to five turns.
//It also will not work properly in certain areas, and possibly across day boundaries. Actually, it's kind of a hack.
//It should be sufficient for most instances of delay(), I think?
int combatTurnsAttemptedInLocation(location place)
{
    int count = 0;
    if (place.combat_queue.length() > 0)
        count += place.combat_queue.split_string("; ").count();
    return count;
}

int noncombatTurnsAttemptedInLocation(location place)
{
    int count = 0;
    if (place.noncombat_queue.length() > 0)
        count += place.noncombat_queue.split_string("; ").count();
    return count;
}

int turnsAttemptedInLocation(location place)
{
    return place.combatTurnsAttemptedInLocation() + place.noncombatTurnsAttemptedInLocation();
}

int turnsAttemptedInLocation(boolean [location] places)
{
    int count = 0;
    foreach place in places
        count += place.turnsAttemptedInLocation();
    return count;
}

string [int] locationSeenNoncombats(location place)
{
    return place.noncombat_queue.split_string_mutable("; ");
}

string [int] locationSeenCombats(location place)
{
    return place.combat_queue.split_string_mutable("; ");
}

string lastNoncombatInLocation(location place)
{
    if (place.noncombat_queue.length() > 0)
        return place.locationSeenNoncombats().listLastObject();
    return "";
}

string lastCombatInLocation(location place)
{
    if (place.noncombat_queue.length() > 0)
        return place.locationSeenCombats().listLastObject();
    return "";
}

int delayRemainingInLocation(location place)
{
    int delay_for_place = -1;
    int [location] place_delays;
    place_delays[$location[the spooky forest]] = 5;
    place_delays[$location[the haunted ballroom]] = 5;
    place_delays[$location[the haunted bedroom]] = 5;
    place_delays[$location[the haunted library]] = 5;
    place_delays[$location[the haunted billiards room]] = 5;
    place_delays[$location[the boss bat's lair]] = 4;
    place_delays[$location[the oasis]] = 5;
    
    
    if (place_delays contains place)
        delay_for_place = place_delays[place];
    if (delay_for_place == -1)
        return -1;
    return MAX(0, delay_for_place - place.turnsAttemptedInLocation());
}

int turnsCompletedInLocation(location place)
{
    return place.turnsAttemptedInLocation(); //FIXME make this correct
}

string pluralize(float value, string non_plural, string plural)
{
	if (value == 1.0)
		return value + " " + non_plural;
	else
		return value + " " + plural;
}

string pluralize(int value, string non_plural, string plural)
{
	if (value == 1)
		return value + " " + non_plural;
	else
		return value + " " + plural;
}

string pluralize(int value, item i)
{
	return pluralize(value, i.to_string(), i.plural);
}

string pluralize(item i) //whatever we have around
{
	return pluralize(i.available_amount(), i);
}

string pluralize(effect e)
{
    return pluralize(e.have_effect(), "turn", "turns") + " of " + e;
}

string pluralizeWordy(int value, string non_plural, string plural)
{
	if (value == 1)
		return value.int_to_wordy() + " " + non_plural;
	else
		return value.int_to_wordy() + " " + plural;
}

string pluralizeWordy(int value, item i)
{
	return pluralizeWordy(value, i.to_string(), i.plural);
}

string pluralizeWordy(item i) //whatever we have around
{
	return pluralizeWordy(i.available_amount(), i);
}

//Backwards compatibility:
//We want to be able to support new content with daily builds. But, we don't want to ask users to run a daily build.
//So these act as replacements for new content. Unknown lookups are given as $type[none] The goal is to have compatibility with the last major release.
//We use this instead of to_item() conversion functions, so we can easily identify them in the source.
item lookupItem(string name)
{
    return name.to_item();
}

boolean [item] lookupItems(string names) //CSV input
{
    boolean [item] result;
    string [int] item_names = split_string(names, ",");
    foreach key in item_names
    {
        item it = item_names[key].to_item();
        if (it == $item[none])
            continue;
        result[it] = true;
    }
    return result;
}

skill lookupSkill(string name)
{
    return name.to_skill();
}

boolean [skill] lookupSkills(string names) //CSV input
{
    boolean [skill] result;
    string [int] skill_names = split_string(names, ",");
    foreach key in skill_names
    {
        skill s = skill_names[key].to_skill();
        if (s == $skill[none])
            continue;
        result[s] = true;
    }
    return result;
}

effect lookupEffect(string name)
{
    return name.to_effect();
}

familiar lookupFamiliar(string name)
{
    return name.to_familiar();
}

location lookupLocation(string name)
{
    return name.to_location();
}

monster lookupMonster(string name)
{
    return name.to_monster();
}

boolean monsterDropsItem(monster m, item it)
{
	//record [int] drops = m.item_drops_array();
	foreach key in m.item_drops_array()
	{
		if (m.item_drops_array()[key].drop == it)
			return true;
	}
	return false;
}

//Takes into account banishes and olfactions.
//Probably will be inaccurate in many corner cases, sorry.
float [monster] appearance_rates_adjusted(location l)
{
    float [monster] source = l.appearance_rates();
    
    if (l == $location[the sleazy back alley])
        source[$monster[none]] = MIN(MAX(0, 20 - combat_rate_modifier()), 100);
    
    float minimum_monster_appearance = 1000000000.0;
    foreach m in source
    {
        float v = source[m];
        if (v > 0.0)
        {
            if (v < minimum_monster_appearance)
                minimum_monster_appearance = v;
        }
    }
    
    float [monster] source_altered;
    foreach m in source
    {
        float v = source[m];
        source_altered[m] = v / minimum_monster_appearance;
    }
    
    
    boolean lawyers_relocated = (get_property_int("relocatePygmyLawyer") == my_ascensions());
    boolean janitors_relocated = (get_property_int("relocatePygmyJanitor") == my_ascensions());
    if (l == $location[the hidden park])
    {
        if (janitors_relocated)
            source_altered[$monster[pygmy janitor]] += 1.0;
        if (lawyers_relocated)
            source_altered[$monster[pygmy witch lawyer]] += 1.0;
    }
    if (($locations[The Hidden Apartment Building,The Hidden Bowling Alley,The Hidden Hospital,The Hidden Office Building] contains l))
    {
        if (janitors_relocated && (source_altered contains $monster[pygmy janitor]))
            remove source_altered[$monster[pygmy janitor]];
        if (lawyers_relocated && (source_altered contains $monster[pygmy witch lawyer]))
            remove source_altered[$monster[pygmy witch lawyer]];
    }
    
    foreach m in source_altered
    {
        if (m.is_banished())
            source_altered[m] = 0.0;
    }
    
    if ($effect[on the trail].have_effect() > 0)
    {
        monster olfacted_monster = get_property("olfactedMonster").to_monster();
        if (olfacted_monster != $monster[none])
        {
            if (source_altered contains olfacted_monster)
                source_altered[olfacted_monster] += 3.0; //FIXME is this correct?
        }
    }
    
    
    //Convert source_altered to source.
    
    float total = 0.0;
    foreach m in source_altered
    {
        float v = source_altered[m];
        if (v > 0)
            total += v;
    }
    if ($locations[Guano Junction,the Batrat and Ratbat Burrow,the Beanbat Chamber] contains l)
    {
        //hacky, probably wrong:
        float v = total / 8.0;
        source_altered[$monster[screambat]] = v;
        total += v;
    }
    
    if (total > 0.0)
    {
        foreach m in source_altered
        {
            float v = source_altered[m];
            source[m] = v / total * 100.0;
        }
    }
    
    return source;
}


float [monster] appearance_rates_adjusted_cancel_nc(location l)
{
    float [monster] base_rates = appearance_rates_adjusted(l);
    float nc_rate = base_rates[$monster[none]];
    float nc_inverse_multiplier = 1.0;
    if (nc_rate != 1.0)
        nc_inverse_multiplier = 1.0 / (1.0 - nc_rate);
    foreach m in base_rates
    {
        if (m == $monster[none])
            base_rates[m] = 0.0;
        else
            base_rates[m] *= nc_inverse_multiplier;
    }
    return base_rates;
}


boolean locationHasPlant(location l, string plant_name)
{
    string [int] plants_in_place = get_florist_plants()[l];
    foreach key in plants_in_place
    {
        if (plants_in_place[key] == plant_name)
            return true;
    }
    return false;
}

Record StringHandle
{
    string s;
};

Record FloatHandle
{
    float f;
};


buffer generateTurnsToSeeNoncombat(int combat_rate, int noncombats_in_zone, string task, int max_turns_between_nc, int extra_starting_turns)
{
    float turn_estimation = -1.0;
    float noncombat_rate = 1.0 - (combat_rate + combat_rate_modifier()).to_float() / 100.0;
    
    
    if (noncombats_in_zone > 0)
    {
        float minimum_nc_rate = 0.0;
        if (max_turns_between_nc != 0)
            minimum_nc_rate = 1.0 / max_turns_between_nc.to_float();
        if (noncombat_rate < minimum_nc_rate)
            noncombat_rate = minimum_nc_rate;
        
        if (noncombat_rate > 0.0)
            turn_estimation = noncombats_in_zone.to_float() / noncombat_rate;
    }
    else
        turn_estimation = 0.0;
        
    if (turn_estimation == -1.0)
        return "".to_buffer();
    
    turn_estimation += extra_starting_turns;
    
    
    buffer result;
    result.append("~");
    result.append(turn_estimation.roundForOutput(1));
    if (turn_estimation == 1.0)
        result.append(" turn");
    else
        result.append(" turns");
    
    if (task.length() > 0)
    {
        result.append(" to ");
        result.append(task);
    }
    else
    {
        if (turn_estimation == 1.0)
            result.append(" remains");
        else
            result.append(" remain");
    }
    if (noncombats_in_zone > 0)
    {
        result.append(" at ");
        result.append(combat_rate_modifier().floor());
        result.append("% combat rate");
    }
    result.append(".");
    
    return result;
}

buffer generateTurnsToSeeNoncombat(int combat_rate, int noncombats_in_zone, string task, int max_turns_between_nc)
{
    return generateTurnsToSeeNoncombat(combat_rate, noncombats_in_zone, task, max_turns_between_nc, 0);
}

buffer generateTurnsToSeeNoncombat(int combat_rate, int noncombats_in_zone, string task)
{
    return generateTurnsToSeeNoncombat(combat_rate, noncombats_in_zone, task, 0);
}


int damageTakenByElement(int base_damage, float elemental_resistance)
{
    if (base_damage < 0)
        return 1;
    
    float effective_base_damage = MAX(30, base_damage).to_float();
    
    return MAX(1, ceil(base_damage.to_float() - effective_base_damage * elemental_resistance));
}

int damageTakenByElement(int base_damage, element e)
{
    float elemental_resistance = e.elemental_resistance() / 100.0;
    
    //mafia might already do this for us already, but I haven't checked:
    
    if (e == $element[cold] && $effect[coldform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[hot] && $effect[hotform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[sleaze] && $effect[sleazeform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[spooky] && $effect[spookyform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[stench] && $effect[stenchform].have_effect() > 0)
        elemental_resistance = 1.0;
        
        
    return damageTakenByElement(base_damage, elemental_resistance);
}


int monster_level_adjustment_ignoring_plants()
{
    int ml = monster_level_adjustment();
    
    
    
    location my_location = my_location();
    
    if (my_location != $location[none])
    {
        string [3] location_plants = get_florist_plants()[my_location];
        foreach key in location_plants
        {
            string plant = location_plants[key];
            if (plant == "Rabid Dogwood" || plant == "War Lily"  || plant == "Blustery Puffball")
            {
                ml -= 30;
                break;
            }
        }
        
    }
    return ml;
}
//Support for manually parsing the quest log:

record QLEntryStep
{
    string [int] possible_string_matches;
    boolean check_in_completed_log; //nemesis quest is strange - it goes into the "completed" log even though we're still in progress
};

QLEntryStep QLEntryStepMake(string [int] matches, boolean check_in_completed_log)
{
    QLEntryStep result;
    result.possible_string_matches = matches;
    result.check_in_completed_log = check_in_completed_log;
    return result;
}

QLEntryStep QLEntryStepMake(string [int] matches)
{
    return QLEntryStepMake(matches, false);
}

QLEntryStep QLEntryStepMake(string match, boolean check_in_completed_log)
{
    string [int] matches;
    matches.listAppend(match);
    return QLEntryStepMake(matches, check_in_completed_log);
}

QLEntryStep QLEntryStepMake(string match)
{
    return QLEntryStepMake(match, false);
}

boolean QLEntryStepMatchesLog(QLEntryStep step, string in_progress_log)
{
    foreach key in step.possible_string_matches
    {
        string possible_match = step.possible_string_matches[key];
        if (in_progress_log.contains_text(possible_match))
            return true;
    }
    return false;
}

void listAppend(QLEntryStep [int] list, QLEntryStep entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


record QuestLogEntry
{
    string exists_in_log_match_string;
    
	string property_name;
	QLEntryStep [int] steps;
    QLEntryStep completed_step;
};

int QuestLogEntryCurrentStep(QuestLogEntry entry)
{
    string completed_log = get_property("__relay_guide_last_quest_log_2");
    if (entry.completed_step.possible_string_matches.count() > 0)
    {
        if (QLEntryStepMatchesLog(entry.completed_step, completed_log))
            return INT32_MAX;
    }
    else
    {
        if (completed_log.contains_text(entry.exists_in_log_match_string))
            return INT32_MAX;
    }
        
    string in_progress_log = get_property("__relay_guide_last_quest_log_1");
    boolean quest_in_progress_log = in_progress_log.contains_text(entry.exists_in_log_match_string);
    
    int highest_step = 0;
    //Parse:
    foreach key in entry.steps
    {
        QLEntryStep step = entry.steps[key];
        boolean step_matches = false;
        if (step.check_in_completed_log)
            step_matches = step.QLEntryStepMatchesLog(completed_log);
        else if (quest_in_progress_log)
            step_matches = step.QLEntryStepMatchesLog(in_progress_log);
        if (step_matches)
        {
            highest_step = key + 1;
            break;
        }
    }
    return highest_step;
}

record QuestLog
{
    QuestLogEntry [string] tracked_entries;
};


QuestLog __quest_log;
boolean __quest_log_initialized = false;


void QuestLogPrivateInit()
{
	if (__quest_log_initialized)
		return;
	__quest_log_initialized = true;
	
    if (true)
    {
        //a dark and dank and sinister quest:
        QuestLogEntry entry;
        entry.property_name = "questG05Dark";
        entry.exists_in_log_match_string = "A Dark and Dank and Sinister Quest";
        entry.steps.listAppend(QLEntryStepMake("Finally it's time to meet this Nemesis you've been hearing so much about! The guy at your guild has marked your map with the location of a cave in the Big Mountains, where your Nemesis is supposedly hiding."));
        entry.steps.listAppend(QLEntryStepMake("Having opened the first door in your Nemesis' cave, you are now faced with a second one. Go figure"));
        entry.steps.listAppend(QLEntryStepMake("Having opened the second door in your Nemesis' cave, you are now"));
        entry.steps.listAppend(QLEntryStepMake("Woo! You're past the doors and it's time to stab some bastards"));
        entry.steps.listAppend(QLEntryStepMake("The door to your Nemesis' inner sanctum didn't seem to care for the password you tried earlier"));
        entry.steps.listAppend(QLEntryStepMake("Hear how the background music got all exciting? It's because you opened the door to your Nemesis' inner sanctum"));
        //entry.steps.listAppend(QLEntryStepMake("Your Nemesis has scuttled away in defeat, leaving you with a sweet Epic Hat and a feeling of smug superiority"));
        
        
        __quest_log.tracked_entries[entry.property_name] = entry;
    }
    if (true)
    {
        //Nemesis quest:
        
        QuestLogEntry entry;
        entry.property_name = "questG04Nemesis";
        entry.exists_in_log_match_string = "Me and My Nemesis";
        
        entry.steps.listAppend(QLEntryStepMake("One of your guild leaders has tasked you to recover a mysterious and unnamed artifact stolen by your Nemesis. Your first step is to smith an Epic Weapon"));
        entry.steps.listAppend(QLEntryStepMake("To unlock the full power of the Legendary Epic Weapon, you must defeat Beelzebozo, the Clown Prince of Darkness,"));
        entry.steps.listAppend(QLEntryStepMake("You've finally killed the clownlord Beelzebozo"));
        entry.steps.listAppend(QLEntryStepMake("You've successfully defeated Beelzebozo and claimed the last piece of the Legendary Epic Weapon"));
        entry.steps.listAppend(QLEntryStepMake("discovered where your Nemesis is hiding. It took long enough, jeez! Anyway, turns out it's a Dark and"));
        entry.steps.listAppend(QLEntryStepMake("You have successfully shown your Nemesis what for, and claimed an ancient hat of power. It's pretty sweet"));
        entry.steps.listAppend(QLEntryStepMake("You showed the Epic Hat to the class leader back at your guild, but they didn't seem much impressed. I guess all this Nemesis nonsense isn't quite finished yet, but at least with your Nemesis in hiding again you won't have to worry about it for a while.", true));
        entry.steps.listAppend(QLEntryStepMake("It appears as though some nefarious ne'er-do-well has put a contract on your head"));
        entry.steps.listAppend(QLEntryStepMake("You handily dispatched some thugs who were trying to collect on your bounty, but something tells you they won't be the last ones to try"));
        entry.steps.listAppend(QLEntryStepMake("Whoever put this hit out on you (like you haven't guessed already) has sent Mob Penguins to do their dirty work. Do you know any polar bears you could hire as bodyguards"));
        entry.steps.listAppend(QLEntryStepMake("So much for those mob penguins that were after your head! If whoever put this hit out on you wants you killed (which, presumably, they do) they'll have to find some much more competent thugs"));
        entry.steps.listAppend(QLEntryStepMake("have been confirmed: your Nemesis has put the order out for you to be hunted down and killed, and now they're sending their own guys instead of contracting out"));
        entry.steps.listAppend(QLEntryStepMake("Bam! So much for your Nemesis' assassins! If that's the best they've got, you have nothing at all to worry about"));
        entry.steps.listAppend(QLEntryStepMake("You had a run-in with some crazy mercenary or assassin or... thing that your Nemesis sent to do you in once and for all. A run-in followed by a run-out, evidently, "));
        entry.steps.listAppend(QLEntryStepMake("Now that you've dealt with your Nemesis' assassins and found a map to the secret tropical island volcano lair, it's time to take the fight to your foe. Booyah"));
        entry.steps.listAppend(QLEntryStepMake("You've arrived at the secret tropical island volcano lair, and it's time to finally put a stop to this Nemesis nonsense once and for all. As soon as you can find where they're hiding. Maybe you can find someone to ask"));
        
        if (true)
        {
            string [int] custom_step_strings;
            custom_step_strings.listAppend("Well, you defeated Gorgolok, but he got away. Again. Funny how he keeps escaping from you when he can't really run with those flippers");
            custom_step_strings.listAppend("Well, you defeated Stella, but she got away. Again. Is ninja training part of the standard poacher skill-set");
            custom_step_strings.listAppend("Well, you defeated the Spaghetti Elemental, but it got away. Again. Never have you met such an elusive noodle");
            custom_step_strings.listAppend("Well, you defeated Lumpy, but it got away. Again. Curse his viscous nature");
            custom_step_strings.listAppend("but he got away. Again. Who would've thought it was so difficult to kill a non-corporeal personification of a particular style of music");
            custom_step_strings.listAppend("Well, you defeated Lopez, but he got away. Again. Man, that guy is as hard to kill");
            entry.steps.listAppend(QLEntryStepMake(custom_step_strings));
        }
        entry.steps.listAppend(QLEntryStepMake("Congratulations on solving the lava maze, which is probably the biggest pain-in-the-ass puzzle in the entire game! Hooray! (Unless you cheated, in which case"));
        entry.steps.listAppend(QLEntryStepMake("have some sort of crazy powerful and hideous final form? I was, but then I wrote all of this,"));
        
        if (true)
        {
            string [int] custom_step_strings;
            custom_step_strings.listAppend("the Infernal Seal Gorgolok has fallen beneath your mighty assault. Never again will the");
            custom_step_strings.listAppend("Stella the Turtle Poacher has fallen beneath your mighty assault. Never again will the helpless ");
            custom_step_strings.listAppend(" evil Spaghetti Elemental has fallen beneath your mighty assault. Never again will the ");
            custom_step_strings.listAppend("Sinister Sauceblob has fallen beneath your mighty assault. Now the people of the Kingdom");
            custom_step_strings.listAppend("Spirit of New Wave has fallen beneath your mighty assault. Now the disco-loving people");
            custom_step_strings.listAppend("Somerset Lopez has fallen beneath your mighty assault. Now the eons-long ");
            entry.completed_step = QLEntryStepMake(custom_step_strings);
        }
        
        __quest_log.tracked_entries[entry.property_name] = entry;
    }
    
    if (true)
    {
        //hey hey
        QuestLogEntry entry;
        entry.property_name = "questS02Monkees";
        entry.exists_in_log_match_string = "Hey, Hey, They're Sea Monkees";
        entry.steps.listAppend(QLEntryStepMake("You rescued a strange, monkey-like creature from a Neptune Flytrap."));
        entry.steps.listAppend(QLEntryStepMake("Little Brother, the Sea Monkee, has asked you to find his older brother"));
        entry.steps.listAppend(QLEntryStepMake("You've rescued Little Brother's big brother, Big Brother. You should go talk to him"));
        entry.steps.listAppend(QLEntryStepMake("You've rescued Big Brother, who has agreed to sell you some stuff as a"));
        entry.steps.listAppend(QLEntryStepMake("Little Brother has asked you to rescue his grandpa. He says that Grandpa has been "));
        entry.steps.listAppend(QLEntryStepMake("You've rescued Grandpa, and he's got lots and lots of stories to tell"));
        //emptiness
        
        __quest_log.tracked_entries[entry.property_name] = entry;
    }
}

boolean QuestLogTracksProperty(string property_name)
{
	QuestLogPrivateInit();
    
    if (__quest_log.tracked_entries contains property_name)
        return true;
	return false;
}

string QuestLogLookupProperty(string property_name)
{
	QuestLogPrivateInit();
    
    if (!(__quest_log.tracked_entries contains property_name))
        return "";
    
	
	int step = __quest_log.tracked_entries[property_name].QuestLogEntryCurrentStep();
    
    if (step <= 0)
        return "unstarted";
    if (step == 1)
        return "started";
    if (step == INT32_MAX)
        return "finished";
    
    return "step" + (step - 1);
}

string [int] QuestLogTrackingProperties()
{
    string [int] result;
	QuestLogPrivateInit();
    foreach s in __quest_log.tracked_entries
    {
        result.listAppend(s);
    }
    return result;
}

//Quest status stores all/most of our quest information in an internal format that's easier to understand.
record QuestState
{
	string quest_name;
	string image_name;
	
	boolean startable; //can be started, but hasn't yet
	boolean started;
	boolean in_progress;
	boolean finished;
	
	int mafia_internal_step; //0 for not started. INT32_MAX for finished. This is +1 versus mafia's "step1/step2/stepX" system. "step1" is represented as 2, "step2" as 3, etc.
	
	boolean [string] state_boolean;
	string [string] state_string;
	int [string] state_int;
	float [string] state_float;
	
	boolean council_quest;
};

QuestState [string] __quest_state;
boolean [string] __misc_state;
string [string] __misc_state_string;
int [string] __misc_state_int;
float [string] __misc_state_float;

boolean safeToLoadQuestLog()
{
    int current_time = getMillisecondsOfToday();
    int last_reloaded_time = get_property_int("__relay_guide_last_quest_log_reload_time");
    int minimum_time_between_quest_log_reloads = 10000; //ten seconds, seems reasonable
    if (abs(current_time - last_reloaded_time) < minimum_time_between_quest_log_reloads)
        return false;
    return true;
}

string shrinkKOLPage(string html)
{
    int body_position = html.index_of("<body>");
    if (body_position != -1)
        return html.substring(body_position);
    return html;
}

boolean __loaded_quest_log = false;
void requestQuestLogLoad(string property_name)
{
    if (true) //disabled, remove later
        return;
    if (__loaded_quest_log)
        return;
    
    boolean [string] whitelist = $strings[questF01Primordial,questF02Hyboria,questF03Future,questI02Beat];
    //questF01Primordial questF02Hyboria questF03Future - minor tracking
    //questG02Whitecastle - tracked, but updates only started, finished, step1, step5?
    //questG03Ego - tracked, but not updated
    //questG04Nemesis questG05Dark - minor tracking
    //questI02Beat - need to know professor jacking being defeated
    
    if (!(whitelist contains property_name))
        return;
    
    __loaded_quest_log = true;
    
    
    
    boolean safe_to_load_again = safeToLoadQuestLog();
    int current_time = getMillisecondsOfToday();
    
    //Rate limit:
    //A load of both quest logs can be around 9 KiB, or less.
    //That's quite a bit of data. So, we want to prevent requesting this too much.
    //We rate limit - quest log loads can only happen every ten seconds.
    //We have a javascript mechanism in place to reload at a later time, if we skip the check. This insures stale data won't be visible beyond the limit interval.
    
    
    if (safe_to_load_again)
    {
        boolean stale = false;
        string quest_log_2 = "";//visit_url("questlog.php?which=2");
        string quest_log_1 = "";//visit_url("questlog.php?which=1");
        if (quest_log_2.contains_text("Your Quest Log"))
            set_property("__relay_guide_last_quest_log_2", shrinkKOLPage(quest_log_2));
        else
            stale = true;
        if (quest_log_1.contains_text("Your Quest Log"))
            set_property("__relay_guide_last_quest_log_1", shrinkKOLPage(quest_log_1));
        else
            stale = true;
        set_property("__relay_guide_last_quest_log_reload_time", current_time.to_string());
        set_property("__relay_guide_stale_quest_data", stale.to_string());
    }
    else
    {
        set_property("__relay_guide_stale_quest_data", true.to_string());
    }
}

int QuestStateConvertQuestPropertyValueToNumber(string property_value)
{
	int result = 0;
	if (property_value == "")
		return -1;
	if (property_value == "started")
	{
		result = 1;
	}
	else if (property_value == "finished")
	{
		result = INT32_MAX;
	}
	else if (property_value.contains_text("step"))
	{
		//let's see...
		//lazy:
		string theoretical_int = property_value.replace_string("step", "");
		int step_value = theoretical_int.to_int_silent();
		
		result = step_value + 1;
		
		if (result < 0)
			result = 0;
	}
	else
	{
		//unknown
	}
	return result;
}


void QuestStateParseMafiaQuestPropertyValue(QuestState state, string property_value)
{
	state.started = false;
	state.finished = false;
    state.in_progress = false;
	state.mafia_internal_step = QuestStateConvertQuestPropertyValueToNumber(property_value);
	
	if (state.mafia_internal_step > 0)
		state.started = true;
	if (state.mafia_internal_step == INT32_MAX)
		state.finished = true;
	if (state.started && !state.finished)
		state.in_progress = true;
}

boolean QuestStateEquals(QuestState q1, QuestState q2)
{
	//not sure how to do record equality otherwise
	if (q1.quest_name != q2.quest_name)
		return false;
	if (q1.image_name != q2.image_name)
		return false;
	if (q1.startable != q2.startable)
		return false;
	if (q1.started != q2.started)
		return false;
	if (q1.in_progress != q2.in_progress)
		return false;
	if (q1.finished != q2.finished)
		return false;
	if (q1.mafia_internal_step != q2.mafia_internal_step)
		return false;
		
	if (q1.state_boolean != q2.state_boolean)
		return false;
	if (q1.state_string != q2.state_string)
		return false;
	if (q1.state_int != q2.state_int)
		return false;
	return true;
}

void QuestStateParseMafiaQuestProperty(QuestState state, string property_name, boolean allow_quest_log_load)
{
	state.QuestStateParseMafiaQuestPropertyValue(get_property(property_name));
    
    boolean should_load_anyways = false;
    if (!state.finished)
    {
        if (QuestLogTracksProperty(property_name))
            should_load_anyways = true;
    }
    
    if ((should_load_anyways || state.in_progress) && allow_quest_log_load)
    {
        requestQuestLogLoad(property_name);
        state.QuestStateParseMafiaQuestPropertyValue(get_property(property_name));
    }
    if (QuestLogTracksProperty(property_name) && !state.finished)
        state.QuestStateParseMafiaQuestPropertyValue(QuestLogLookupProperty(property_name));
}

void QuestStateParseMafiaQuestProperty(QuestState state, string property_name)
{
    QuestStateParseMafiaQuestProperty(state, property_name, true);
}

boolean needTowerMonsterItem(string in_item_name)
{
	if (in_item_name.to_item().available_amount() > 0)
		return false;
	for i from 1 to 6
	{
		string item_name = __misc_state_string["Tower monster item " + i];
		if (__quest_state["Level 13"].state_boolean["Past tower monster " + i])
			continue;
		if (in_item_name == item_name)
			return true;
	}
	return false;		
}




float __setting_indention_width_in_em = 1.45;
string __setting_indention_width = __setting_indention_width_in_em + "em";

string __html_right_arrow_character = "&#9658;";

buffer HTMLGenerateTagPrefix(string tag, string [string] attributes)
{
	buffer result;
	result.append("<");
	result.append(tag);
	foreach attribute_name in attributes
	{
		string attribute_value = attributes[attribute_name];
		result.append(" ");
		result.append(attribute_name);
		if (attribute_value != "")
		{
			boolean is_integer = attribute_value.is_integer(); //don't put quotes around integer attributes (i.e. width, height)
			
			result.append("=");
			if (!is_integer)
				result.append("\"");
			result.append(attribute_value);
			if (!is_integer)
				result.append("\"");
		}
	}
	result.append(">");
	
	return result;
}
buffer HTMLGenerateTagPrefix(string tag)
{
    buffer result;
    result.append("<");
    result.append(tag);
    result.append(">");
    return result;
}

buffer HTMLGenerateTagSuffix(string tag)
{
    buffer result;
    result.append("</");
    result.append(tag);
    result.append(">");
    return result;
}

buffer HTMLGenerateTagWrap(string tag, string source, string [string] attributes)
{
    buffer result;
    result.append(HTMLGenerateTagPrefix(tag, attributes));
    result.append(source);
    result.append(HTMLGenerateTagSuffix(tag));
	return result;
}

buffer HTMLGenerateTagWrap(string tag, string source)
{
    buffer result;
    result.append(HTMLGenerateTagPrefix(tag));
    result.append(source);
    result.append(HTMLGenerateTagSuffix(tag));
	return result;
}

buffer HTMLGenerateDivOfClass(string source, string class_name)
{
	if (class_name == "")
		return HTMLGenerateTagWrap("div", source);
	else
		return HTMLGenerateTagWrap("div", source, mapMake("class", class_name));
}

buffer HTMLGenerateDivOfClass(string source, string class_name, string extra_style)
{
	return HTMLGenerateTagWrap("div", source, mapMake("class", class_name, "style", extra_style));
}

buffer HTMLGenerateDivOfStyle(string source, string style)
{
	if (style == "")
		return source.to_buffer();
	
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
		return source.to_buffer();
	return HTMLGenerateTagWrap("span", source, mapMake("style", style));
}

buffer HTMLGenerateSpanFont(string source, string font_color, string font_size)
{
	if (font_color == "" && font_size == "")
		return source.to_buffer();
		
	string style = "";
	
	if (font_color != "")
		style += "color:" + font_color +";";
	if (font_size != "")
		style += "font-size:" + font_size +";";
	return HTMLGenerateSpanOfStyle(source, style);
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






record CSSEntry
{
    string tag;
    string class_name;
    string definition;
    int importance;
};

CSSEntry CSSEntryMake(string tag, string class_name, string definition, int importance)
{
    CSSEntry entry;
    entry.tag = tag;
    entry.class_name = class_name;
    entry.definition = definition;
    entry.importance = importance;
    return entry;
}

record CSSBlock
{
    CSSEntry [int] defined_css_classes;
    string identifier;
};

CSSBlock CSSBlockMake(string identifier)
{
    CSSBlock result;
    result.identifier = identifier;
    return result;
}

buffer CSSBlockGenerate(CSSBlock block)
{
    buffer result;
    
    if (block.defined_css_classes.count() > 0)
    {
        boolean output_identifier = (block.identifier.length() > 0);
        if (output_identifier)
        {
            result.append("\t\t\t");
            result.append(block.identifier);
            result.append(" {\n");
        }
        sort block.defined_css_classes by value.importance;
    
        foreach key in block.defined_css_classes
        {
            CSSEntry entry = block.defined_css_classes[key];
            result.append("\t\t\t");
            if (output_identifier)
                result.append("\t");
        
            if (entry.class_name == "")
                result.append(entry.tag + " { " + entry.definition + " }");
            else
                result.append(entry.tag + "." + entry.class_name + " { " + entry.definition + " }");
            result.append("\n");
        }
        if (output_identifier)
            result.append("\n\t\t\t}\n");
    }
    return result;
}

void listAppend(CSSEntry [int] list, CSSEntry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

record Page
{
	string title;
	buffer head_contents;
	buffer body_contents;
	string [string] body_attributes; //[attribute_name] -> attribute_value
	
    CSSBlock [string] defined_css_blocks; //There is always an implicit "" block.
};


Page __global_page;



Page Page()
{
	return __global_page;
}

buffer PageGenerate(Page page_in)
{
	buffer result;
	
	result.append("<!DOCTYPE html>\n"); //HTML 5 target
	result.append("<html>\n");
	
	//Head:
	result.append("\t<head>\n");
	result.append("\t\t<title>");
	result.append(page_in.title);
	result.append("</title>\n");
	if (page_in.head_contents.length() != 0)
	{
        result.append("\t\t");
		result.append(page_in.head_contents);
		result.append("\n");
	}
	//Write CSS styles:
    if (true)
    {
        result.append("\t\t");
        result.append(HTMLGenerateTagPrefix("style", mapMake("type", "text/css")));
        result.append("\n");
    }
    result.append(page_in.defined_css_blocks[""].CSSBlockGenerate()); //write first
    foreach identifier in page_in.defined_css_blocks
    {
        CSSBlock block = page_in.defined_css_blocks[identifier];
        if (identifier == "") //skip, already written
            continue;
        result.append(block.CSSBlockGenerate());
    }
    if (true)
    {
        result.append("\t\t</style>\n");
    }
	result.append("\t</head>\n");
	
	//Body:
	result.append("\t");
	result.append(HTMLGenerateTagPrefix("body", page_in.body_attributes));
	result.append("\n\t\t");
	result.append(page_in.body_contents);
	result.append("\n");
		
	result.append("\t</body>\n");
	

	result.append("</html>");
	
	return result;
}

void PageGenerateAndWriteOut(Page page_in)
{
	write(PageGenerate(page_in));
}

void PageSetTitle(Page page_in, string title)
{
	page_in.title = title;
}

void PageAddCSSClass(Page page_in, string tag, string class_name, string definition, int importance, string block_identifier)
{
    if (!(page_in.defined_css_blocks contains block_identifier))
        page_in.defined_css_blocks[block_identifier] = CSSBlockMake(block_identifier);
    page_in.defined_css_blocks[block_identifier].defined_css_classes.listAppend(CSSEntryMake(tag, class_name, definition, importance));
}

void PageAddCSSClass(Page page_in, string tag, string class_name, string definition, int importance)
{
    PageAddCSSClass(page_in, tag, class_name, definition, importance, "");
}

void PageAddCSSClass(Page page_in, string tag, string class_name, string definition)
{
    PageAddCSSClass(page_in, tag, class_name, definition, 0);
}


void PageWriteHead(Page page_in, string contents)
{
	page_in.head_contents.append(contents);
}

void PageWriteHead(Page page_in, buffer contents)
{
	page_in.head_contents.append(contents);
}


void PageWrite(Page page_in, string contents)
{
	page_in.body_contents.append(contents);
}

void PageWrite(Page page_in, buffer contents)
{
	page_in.body_contents.append(contents);
}

void PageSetBodyAttribute(Page page_in, string attribute, string value)
{
	page_in.body_attributes[attribute] = value;
}


//Global:

buffer PageGenerate()
{
	return PageGenerate(Page());
}

void PageGenerateAndWriteOut()
{
	write(PageGenerate());
}

void PageSetTitle(string title)
{
	PageSetTitle(Page(), title);
}

void PageAddCSSClass(string tag, string class_name, string definition)
{
	PageAddCSSClass(Page(), tag, class_name, definition);
}

void PageAddCSSClass(string tag, string class_name, string definition, int importance)
{
	PageAddCSSClass(Page(), tag, class_name, definition, importance);
}

void PageAddCSSClass(string tag, string class_name, string definition, int importance, string block_identifier)
{
	PageAddCSSClass(Page(), tag, class_name, definition, importance, block_identifier);
}

void PageWriteHead(string contents)
{
	PageWriteHead(Page(), contents);
}

void PageWriteHead(buffer contents)
{
	PageWriteHead(Page(), contents);
}

//Writes to body:

void PageWrite(string contents)
{
	PageWrite(Page(), contents);
}

void PageWrite(buffer contents)
{
	PageWrite(Page(), contents);
}

void PageSetBodyAttribute(string attribute, string value)
{
	PageSetBodyAttribute(Page(), attribute, value);
}


void PageInit()
{
	PageAddCSSClass("div", "r_center", "margin-left:auto; margin-right:auto;text-align:center;");
	PageAddCSSClass("", "r_bold", "font-weight:bold;");
	PageAddCSSClass("", "r_end_floating_elements", "clear:both;");
	
	
	PageAddCSSClass("", "r_element_stench", "color:green;");
	PageAddCSSClass("", "r_element_hot", "color:red;");
	PageAddCSSClass("", "r_element_cold", "color:blue;");
	PageAddCSSClass("", "r_element_sleaze", "color:purple;");
	PageAddCSSClass("", "r_element_spooky", "color:gray;");
	
	PageAddCSSClass("a", "r_a_undecorated", "text-decoration:none;color:inherit;");
	PageAddCSSClass("", "r_indention", "margin-left:" + __setting_indention_width + ";");
	
	//Simple table lines:
	PageAddCSSClass("div", "r_stl_container", "display:table;");
	PageAddCSSClass("div", "r_stl_container_row", "display:table-row;");
    PageAddCSSClass("div", "r_stl_entry", "padding:0px;margin:0px;display:table-cell;");
    PageAddCSSClass("div", "r_stl_spacer", "width:1em;");
}



string HTMLGenerateIndentedText(string text, string width)
{
	if (__use_table_based_layouts) //table-based layout
		return "<table cellpadding=0 cellspacing=0 width=100%><tr>" + HTMLGenerateTagWrap("td", "", mapMake("style", "width:" + width + ";")) + "<td>" + text + "</td></tr></table>";
	else //div-based layout:
		return HTMLGenerateDivOfClass(text, "r_indention");
}

string HTMLGenerateIndentedText(string [int] text)
{

	buffer building_text;
	foreach key in text
	{
		string line = text[key];
		building_text.append(HTMLGenerateDiv(line));
	}
	
	return HTMLGenerateIndentedText(to_string(building_text), __setting_indention_width);
}

string HTMLGenerateIndentedText(string text)
{
	return HTMLGenerateIndentedText(text, __setting_indention_width);
}


string HTMLGenerateSimpleTableLines(string [int][int] lines)
{
	buffer result;
	
	int max_columns = 0;
	foreach i in lines
	{
		max_columns = max(max_columns, lines[i].count());
	}
	
	if (__use_table_based_layouts)
	{
		//table-based layout:
		result.append("<table style=\"margin-right: 10px; width:100%;\" cellpadding=0 cellspacing=0>");
	
	
        int intra_i = 0;
		foreach i in lines
		{
            if (intra_i > 0)
            {
                result.append("<tr><td colspan=1000><hr></td></tr>");
            }
			result.append("<tr>");
			int intra_j = 0;
			foreach j in lines[i]
			{
				string entry = lines[i][j];
				result.append("<td align=");
				if (false && max_columns == 1)
					result.append("center");
				else if (intra_j == 0)
					result.append("left");
				else
					result.append("right");
				if (lines[i].count() < max_columns && intra_j == lines[i].count() - 1)
				{
					int calculated_colspan = max_columns - lines[i].count() + 1;
					result.append(" colspan=" + calculated_colspan);
				}
				result.append(">");
				result.append(entry);
				result.append("</td>");
				intra_j += 1;
			}
			result.append("</tr>");
            intra_i += 1;
		}
	
	
		result.append("</table>");
	}
	else
	{
		//div-based layout:
        int intra_i = 0;
        int last_cell_count = 0;
        result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_stl_container")));
		foreach i in lines
		{
            if (intra_i > 0)
            {
                result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_stl_container_row")));
                for i from 1 to last_cell_count //no colspan with display:table, generate extra (zero-padding, zero-margin) cells:
                {
                    result.append(HTMLGenerateDivOfClass("<hr>", "r_stl_entry"));
                }
                result.append("</div>");
                last_cell_count = 0;
            }
            result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_stl_container_row")));
            int intra_j = 0;
			foreach j in lines[i]
			{
				string entry = lines[i][j];
                if (intra_j > 0)
                {
                    result.append(HTMLGenerateDivOfClass("", "r_stl_entry r_stl_spacer"));
                    last_cell_count += 1;
                }
				result.append(HTMLGenerateDivOfClass(entry, "r_stl_entry"));
                last_cell_count += 1;
                
                intra_j += 1;
			}
			
            result.append("</div>");
            intra_i += 1;
		}
        result.append("</div>");
	}
	return result.to_string();
}

boolean __setting_show_alignment_guides = false;
//Library for displaying KOL images
//Each image is referred to by a string via KOLImageLookup, or KOLImageGenerateImageHTML
//There's a list of pre-set images in KOLImagesInit. Otherwise, it tries to look up the string as an item, then as a familiar, and then as an effect. If any matches are found, that image is output. (uses KoLmafia's internal database)
//Also "__item item name", "__familiar familiar name", and "__effect effect name" explicitly request those images.
//"__half lookup name" will reduce the image to half-size.
//NOTE: To use KOLImageGenerateImageHTML with should_center set to true, the page must have the class "r_center" set as "margin-left:auto; margin-right:auto;text-align:center;"

record KOLImage
{
	string url;
	
	Vec2i base_image_size;
	Rect crop;
	
	Rect [int] erase_zones; //rectangular zones which are generated as white divs on the output. Erases specific sections of the image. Can be offset by one pixel depending on the browser, sorry.
};

KOLImage [string] __kol_images;

KOLImage KOLImageMake(string url, Vec2i base_image_size, Rect crop)
{
	KOLImage result;
	result.url = url;
	result.base_image_size = base_image_size;
	result.crop = crop;
	return result;
}

KOLImage KOLImageMake(string url, Vec2i base_image_size)
{
	return KOLImageMake(url, base_image_size, RectZero());
}

KOLImage KOLImageMake(string url)
{
	return KOLImageMake(url, Vec2iZero(), RectZero());
}

KOLImage KOLImageMake()
{
	return KOLImageMake("", Vec2iZero(), RectZero());
}

//Does not need to be called directly.
boolean __kol_images_has_inited = false;
void KOLImagesInit()
{
    if (__kol_images_has_inited)
        return;
        
	PageAddCSSClass("div", "r_image_container", "overflow:hidden;position:relative;top:0px;left:0px;");
    __kol_images_has_inited = true;
	__kol_images["typical tavern"] = KOLImageMake("images/otherimages/woods/tavern0.gif", Vec2iMake(100,100), RectMake(0,39,99,97));
	__kol_images["boss bat"] = KOLImageMake("images/adventureimages/bossbat.gif", Vec2iMake(100,100), RectMake(0,27,99,74));
	__kol_images["bugbear"] = KOLImageMake("images/adventureimages/fallsfromsky.gif", Vec2iMake(100,150));
	
	__kol_images["twin peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(153,128,237,214));
	__kol_images["a-boo peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(40,134,127,218));
	__kol_images["oil peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(261,117,345,213));
	__kol_images["highland lord"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(375,73,457,144));
	__kol_images["orc chasm"] = KOLImageMake("images/otherimages/mountains/chasm.gif", Vec2iMake(100, 100), RectMake(0, 41, 99, 95));
	
	__kol_images["spooky forest"] = KOLImageMake("images/otherimages/woods/forest.gif", Vec2iMake(100, 100), RectMake(12,39,91,93));
	__kol_images["council"] = KOLImageMake("images/otherimages/council.gif", Vec2iMake(100, 100), RectMake(0,26,99,73));
	
	
	__kol_images["daily dungeon"] = KOLImageMake("images/otherimages/town/dd1.gif", Vec2iMake(100,100), RectMake(28,44,71,86));
	__kol_images["clover"] = KOLImageMake("images/itemimages/clover.gif", Vec2iMake(30,30));
	
	__kol_images["mayfly bait"] = KOLImageMake("images/itemimages/mayflynecklace.gif", Vec2iMake(30,30));
	__kol_images["spooky putty"] = KOLImageMake("images/itemimages/sputtysheet.gif", Vec2iMake(30,30));
	
	__kol_images["fax machine"] = KOLImageMake("images/otherimages/clanhall/faxmachine.gif", Vec2iMake(100,100), RectMake(34,28,62,54));
	
	__kol_images["unknown"] = KOLImageMake("images/itemimages/confused.gif", Vec2iMake(30,30));
	
	__kol_images["goth kid"] = KOLImageMake("images/itemimages/crayongoth.gif", Vec2iMake(30,30));
	__kol_images["hipster"] = KOLImageMake("images/itemimages/minihipster.gif", Vec2iMake(30,30));
	
	
	__kol_images[""] = KOLImageMake("images/itemimages/blank.gif", Vec2iMake(30,30));
	__kol_images["blank"] = KOLImageMake("images/itemimages/blank.gif", Vec2iMake(30,30));
	__kol_images["demon summon"] = KOLImageMake("images/otherimages/manor/chamber.gif", Vec2iMake(100,100), RectMake(14, 12, 88, 66));
	
	__kol_images["cobb's knob"] = KOLImageMake("images/otherimages/plains/knob2.gif", Vec2iMake(100,100), RectMake(12,43,86,78));
	
	__kol_images["generic dwelling"] = KOLImageMake("images/otherimages/campground/rest4.gif", Vec2iMake(100,100), RectMake(0,26,95,99));
	
	
	__kol_images["forest friars"] = KOLImageMake("images/otherimages/woods/stones0.gif", Vec2iMake(100,100), RectMake(0, 24, 99, 99));
	__kol_images["cyrpt"] = KOLImageMake("images/otherimages/plains/cyrpt.gif", Vec2iMake(100,100), RectMake(0, 33, 99, 99));
	__kol_images["trapper"] = KOLImageMake("images/otherimages/thetrapper.gif", Vec2iMake(60,100), RectMake(0,11,59,96));
	
	__kol_images["castle"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(234,158,362,290)); //experimental - half sized castle
	__kol_images["penultimate fantasy airship"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(75, 231, 190, 367));
	__kol_images["lift, bro"] = KOLImageMake("images/adventureimages/fitposter.gif", Vec2iMake(100,100));
	//__kol_images["castle stairs up"] = KOLImageMake("images/adventureimages/giantstairsup.gif", Vec2iMake(100,100), RectMake(0, 8, 99, 85));
    __kol_images["castle stairs up"] = KOLImageMake("images/adventureimages/giantstairsup.gif", Vec2iMake(100,100), RectMake(20, 10, 74, 83));
	__kol_images["castle stairs up"].erase_zones.listAppend(RectMake(70, 78, 76, 84));
    
    
	__kol_images["goggles? yes!"] = KOLImageMake("images/adventureimages/steamposter.gif", Vec2iMake(100,100));
	//__kol_images["hole in the sky"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(403, 4, 487, 92));
    __kol_images["hole in the sky"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(250,200), RectMake(201, 2, 243, 46));
	
	__kol_images["macguffin"] = KOLImageMake("images/itemimages/macguffin.gif", Vec2iMake(30,30));
	__kol_images["island war"] = KOLImageMake("images/otherimages/sigils/warhiptat.gif", Vec2iMake(50,50), RectMake(0,12,49,35));
	__kol_images["naughty sorceress"] = KOLImageMake("images/adventureimages/sorcform1.gif", Vec2iMake(100,100));
	__kol_images["naughty sorceress lair"] = KOLImageMake("images/otherimages/main/map6.gif", Vec2iMake(100,100), RectMake(6,0,50,43));
	
	__kol_images["king imprismed"] = KOLImageMake("images/otherimages/lair/kingprism1.gif", Vec2iMake(100,100));
	__kol_images["campsite"] = KOLImageMake("images/otherimages/plains/plains1.gif", Vec2iMake(100,100));
	__kol_images["trophy"] = KOLImageMake("images/otherimages/trophy/not_wearing_any_pants.gif", Vec2iMake(100,100));
	__kol_images["hidden temple"] = KOLImageMake("images/otherimages/woods/temple.gif", Vec2iMake(100,100), RectMake(16, 40, 89, 96));
	__kol_images["florist friar"] = KOLImageMake("images/adventureimages/floristfriar.gif", Vec2iMake(100,100), RectMake(31, 7, 77, 92));
	
	
	__kol_images["plant rutabeggar"] = KOLImageMake("images/otherimages/friarplants/plant2.gif", Vec2iMake(50,100), RectMake(1, 24, 47, 96));
	
	__kol_images["plant stealing magnolia"] = KOLImageMake("images/otherimages/friarplants/plant12.gif", Vec2iMake(49,100), RectMake(3, 15, 43, 94));
	
	__kol_images["plant shuffle truffle"] = KOLImageMake("images/otherimages/friarplants/plant24.gif", Vec2iMake(66,100), RectMake(4, 35, 63, 88));
	__kol_images["plant horn of plenty"] = KOLImageMake("images/otherimages/friarplants/plant22.gif", Vec2iMake(62,100), RectMake(4, 14, 58, 86));
	
	__kol_images["plant rabid dogwood"] = KOLImageMake("images/otherimages/friarplants/plant1.gif", Vec2iMake(57,100), RectMake(3, 16, 55, 98));
	__kol_images["plant rad-ish radish"] = KOLImageMake("images/otherimages/friarplants/plant3.gif", Vec2iMake(48,100), RectMake(4, 14, 42, 96));
	__kol_images["plant war lily"] = KOLImageMake("images/otherimages/friarplants/plant11.gif", Vec2iMake(49,100), RectMake(5, 5, 45, 98));
	
	__kol_images["plant canned spinach"] = KOLImageMake("images/otherimages/friarplants/plant13.gif", Vec2iMake(48,100), RectMake(3, 24, 46, 94));	
	__kol_images["plant blustery puffball"] = KOLImageMake("images/otherimages/friarplants/plant21.gif", Vec2iMake(54,100), RectMake(3, 38, 50, 90));
	__kol_images["plant wizard's wig"] = KOLImageMake("images/otherimages/friarplants/plant23.gif", Vec2iMake(53,100), RectMake(2, 15, 48, 90));
	
	__kol_images["plant up sea daisy"] = KOLImageMake("images/otherimages/friarplants/plant40.gif", Vec2iMake(64,100), RectMake(3, 6, 60, 92));
	__kol_images["sunflower face"] = KOLImageMake("images/otherimages/friarplants/plant40.gif", Vec2iMake(64,100), RectMake(6, 6, 58, 52));
	
	
	__kol_images["basic hot dog"] = KOLImageMake("images/itemimages/jarl_regdog.gif", Vec2iMake(30,30));
	__kol_images["Island War Arena"] = KOLImageMake("images/otherimages/bigisland/6.gif", Vec2iMake(100,100), RectMake(17, 28, 89, 76));
	__kol_images["Island War Lighthouse"] = KOLImageMake("images/otherimages/bigisland/17.gif", Vec2iMake(100,100), RectMake(30, 34, 68, 97));
	__kol_images["Island War Nuns"] = KOLImageMake("images/otherimages/bigisland/19.gif", Vec2iMake(100,100), RectMake(20, 43, 78, 87));
	__kol_images["Island War Farm"] = KOLImageMake("images/otherimages/bigisland/15.gif", Vec2iMake(100,100), RectMake(8, 50, 93, 88));
	__kol_images["Island War Orchard"] = KOLImageMake("images/otherimages/bigisland/3.gif", Vec2iMake(100,100), RectMake(20, 36, 99, 87));
	
	__kol_images["Island War Junkyard"] = KOLImageMake("images/otherimages/bigisland/25.gif", Vec2iMake(100,100), RectMake(0, 4, 99, 89));
	__kol_images["Island War Junkyard"].erase_zones.listAppend(RectMake(0, 2, 20, 6));
	__kol_images["Island War Junkyard"].erase_zones.listAppend(RectMake(9, 41, 95, 52));
	
	
	__kol_images["spookyraven manor"] = KOLImageMake("images/otherimages/town/manor.gif", Vec2iMake(100,100), RectMake(0, 22, 99, 99));
	
	__kol_images["spookyraven manor"].erase_zones.listAppend(RectMake(23, 18, 53, 28));
	
	
	__kol_images["spookyraven manor locked"] = KOLImageMake("images/otherimages/town/pantry.gif", Vec2iMake(80,80), RectMake(0, 26, 79, 79));
	
	__kol_images["haunted billiards room"] = KOLImageMake("images/otherimages/manor/sm4.gif", Vec2iMake(100,100), RectMake(12, 10, 93, 63));
	
	__kol_images["haunted library"] = KOLImageMake("images/otherimages/manor/sm7.gif", Vec2iMake(100,100), RectMake(14, 5, 92, 55));
	
	__kol_images["haunted bedroom"] = KOLImageMake("images/otherimages/manor/sm2_1b.gif", Vec2iMake(100,100), RectMake(18, 28, 91, 86));
    __kol_images["Haunted Ballroom"] = KOLImageMake("images/otherimages/manor/sm2_5.gif", Vec2iMake(100,200), RectMake(19, 11, 74, 76));
	
	__kol_images["Palindome"] = KOLImageMake("images/otherimages/plains/the_palindome.gif", Vec2iMake(96,86), RectMake(0, 17, 96, 83));
	
	
	__kol_images["high school"] = KOLImageMake("images/otherimages/town/kolhs.gif", Vec2iMake(100,100), RectMake(0, 26, 99, 92));
	//__kol_images["Toot Oriole"] = KOLImageMake("images/otherimages/oriole.gif", Vec2iMake(60,100), RectMake(0, 12, 59, 85));
	__kol_images["Toot Oriole"] = KOLImageMake("images/otherimages/mountains/noobsingtop.gif", Vec2iMake(200,100), RectMake(52, 18, 131, 49)); //I love this GIF

	__kol_images["bookshelf"] = KOLImageMake("images/otherimages/campground/bookshelf.gif", Vec2iMake(100,100), RectMake(0, 26, 99, 99));
	__kol_images["pirate quest"] = KOLImageMake("images/otherimages/trophy/party_on_the_big_boat.gif", Vec2iMake(100,100), RectMake(18, 3, 87, 64));
	__kol_images["meat"] = KOLImageMake("images/itemimages/meat.gif", Vec2iMake(30,30));
	__kol_images["monk"] = KOLImageMake("images/itemimages/monkhead.gif", Vec2iMake(30,30));
	
	
	__kol_images["Pyramid"] = KOLImageMake("images/otherimages/desertbeach/pyramid.gif", Vec2iMake(60,70), RectMake(12, 11, 47, 38));
	__kol_images["Pyramid"].erase_zones.listAppend(RectMake(14, 19, 19, 22));
	__kol_images["Pyramid"].erase_zones.listAppend(RectMake(41, 12, 45, 16));
	
	
	//__kol_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(114, 38, 213, 159)); //building, don't like
	//__kol_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(7, 240, 77, 294)); //shrine, too close to hidden temple
	__kol_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(426, 13, 504, 61)); //hidden tavern, small, better
	__kol_images["Dispensary"] = KOLImageMake("images/adventureimages/knobwindow.gif", Vec2iMake(100,100));
	
	
	__kol_images["Wine Racks"] = KOLImageMake("images/otherimages/manor/cellar4.gif", Vec2iMake(100,100), RectMake(17, 11, 96, 65));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(17, 11, 33, 12));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(39, 61, 42, 66));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(70, 61, 74, 66));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(94, 45, 97, 54));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(17, 49, 18, 53));
	
	
	__kol_images["Dad Sea Monkee"] = KOLImageMake("images/adventureimages/dad_machine.gif", Vec2iMake(400,300), RectMake(150,212,245,260));
	__kol_images["Shub-Jigguwatt"] = KOLImageMake("images/adventureimages/shub-jigguwatt.gif", Vec2iMake(300,300), RectMake(19, 17, 267, 288));
	__kol_images["Yog-Urt"] = KOLImageMake("images/adventureimages/yog-urt.gif", Vec2iMake(300,300), RectMake(36, 88, 248, 299));
	__kol_images["Sea"] = KOLImageMake("images/adventureimages/wizardfish.gif", Vec2iMake(100,100), RectMake(18, 23, 61, 72));
	__kol_images["Sea"].erase_zones.listAppend(RectMake(18, 23, 27, 28));
	__kol_images["Sea"].erase_zones.listAppend(RectMake(48, 23, 62, 35));
	__kol_images["Spooky little girl"] = KOLImageMake("images/adventureimages/axelgirl.gif", Vec2iMake(100,100), RectMake(37, 25, 63, 74));
	
	//hermit.gif and oldman.gif are almost identical. twins?
	
    __kol_images["astral spirit"] = KOLImageMake("images/otherimages/spirit.gif", Vec2iMake(60,100));
	__kol_images["Disco Bandit"] = KOLImageMake("images/otherimages/discobandit_f.gif", Vec2iMake(60,100), RectMake(0,6,59,87));
	__kol_images["Seal Clubber"] = KOLImageMake("images/otherimages/sealclubber_f.gif", Vec2iMake(60,100), RectMake(0,9,59,92));
	__kol_images["Turtle Tamer"] = KOLImageMake("images/otherimages/turtletamer_f.gif", Vec2iMake(60,100), RectMake(0,5,59,93));
	__kol_images["Pastamancer"] = KOLImageMake("images/otherimages/pastamancer_f.gif", Vec2iMake(60,100), RectMake(0,0,59,91));
	__kol_images["Sauceror"] = KOLImageMake("images/otherimages/sauceror_f.gif", Vec2iMake(60,100), RectMake(0,5,59,90));
	__kol_images["Accordion Thief"] = KOLImageMake("images/otherimages/accordionthief_f.gif", Vec2iMake(60,100), RectMake(0,2,59,99));
	__kol_images["Avatar of Sneaky Pete"] = KOLImageMake("images/otherimages/peteavatar_f.gif", Vec2iMake(60,100), RectMake(1,7,59,96));
	__kol_images["Avatar of Jarlsberg"] = KOLImageMake("images/otherimages/jarlsberg_avatar_f.gif", Vec2iMake(60,100), RectMake(0,6,59,96));
	__kol_images["Avatar of Boris"] = KOLImageMake("images/otherimages/boris_avatar_f.gif", Vec2iMake(60,100), RectMake(0,4,59,93));
	__kol_images["Zombie Master"] = KOLImageMake("images/otherimages/zombavatar_f.gif", Vec2iMake(60,100), RectMake(10,3,55,99));

	__kol_images["Nemesis Disco Bandit"] = KOLImageMake("images/adventureimages/newwave.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Seal Clubber"] = KOLImageMake("images/adventureimages/1_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Turtle Tamer"] = KOLImageMake("images/adventureimages/2_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Pastamancer"] = KOLImageMake("images/adventureimages/3_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Sauceror"] = KOLImageMake("images/adventureimages/4_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Accordion Thief"] = KOLImageMake("images/adventureimages/6_1.gif", Vec2iMake(100,100));
	
	__kol_images["sword guy"] = KOLImageMake("images/otherimages/leftswordguy.gif", Vec2iMake(80,100));
	__kol_images["Jick"] = KOLImageMake("images/otherimages/customavatars/1.gif", Vec2iMake(30,50));
	__kol_images["Pulverize"] = KOLImageMake("images/itemimages/blackhammer.gif", Vec2iMake(30,30));
	__kol_images["Superhuman Cocktailcrafting"] = KOLImageMake("images/itemimages/fruitym.gif", Vec2iMake(30,30));
    
	__kol_images["inexplicable door"] = KOLImageMake("images/otherimages/woods/8bitdoor.gif", Vec2iMake(100,100), RectMake(15, 43, 85, 99));
	__kol_images["Dungeons of Doom"] = KOLImageMake("images/otherimages/town/ddoom.gif", Vec2iMake(100,100), RectMake(31, 33, 68, 99));
    
	__kol_images["chinatown"] = KOLImageMake("images/otherimages/jung/jung_chinaback.gif", Vec2iMake(450,500), RectMake(188, 202, 229, 270));
	__kol_images["chinatown"].erase_zones.listAppend(RectMake(227, 247, 231, 256));
    
	__kol_images["__skill Easy Riding"] = KOLImageMake("images/itemimages/motorbike.gif", Vec2iMake(30,30));
	__kol_images["__skill jump shark"] = KOLImageMake("images/itemimages/sharkfin.gif", Vec2iMake(30,30));
	__kol_images["__skill Natural Dancer"] = KOLImageMake("images/itemimages/dance3.gif", Vec2iMake(30,30));
    
    
	
	string class_name = my_class().to_string();
	string class_nemesis_name = "Nemesis " + class_name;
	
	if (__kol_images contains class_name)
		__kol_images["Player Character"] = __kol_images[class_name];
	else
		__kol_images["Player Character"] = __kol_images["Disco Bandit"];
		
	if (__kol_images contains class_nemesis_name)
		__kol_images["Nemesis"] = __kol_images[class_nemesis_name];
	else
		__kol_images["Nemesis"] = __kol_images["Jick"];
}



KOLImage KOLImageLookup(string lookup_name)
{
    KOLImagesInit();
	if (!(__kol_images contains lookup_name))
	{
		//Automatically look up items, familiars, and effects by name:
		item it = lookup_name.to_item();
		familiar f = lookup_name.to_familiar();
		effect e = lookup_name.to_effect();
        string secondary_lookup_name = lookup_name;
        if (lookup_name.stringHasPrefix("__item "))
        {
            secondary_lookup_name = lookup_name.substring(7);
            f = $familiar[none];
            e = $effect[none];
            it = secondary_lookup_name.to_item();
        }
        else if (lookup_name.stringHasPrefix("__familiar "))
        {
            secondary_lookup_name = lookup_name.substring(11);
            it = $item[none];
            e = $effect[none];
            f = secondary_lookup_name.to_familiar();
        }
        if (lookup_name.stringHasPrefix("__effect "))
        {
            secondary_lookup_name = lookup_name.substring(9);
            f = $familiar[none];
            it = $item[none];
            e = secondary_lookup_name.to_effect();
        }
        //Disabled for now - skill images are a new feature.
        /*if (lookup_name.stringHasPrefix("__skill "))
        {
            secondary_lookup_name = lookup_name.substring(8);
            skill s = secondary_lookup_name.to_skill();
            
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + s.image, Vec2iMake(30,30));
            return __kol_images[lookup_name];
        }*/
        secondary_lookup_name = secondary_lookup_name.to_lower_case();
		if (it != $item[none] && it.smallimage != "" && it.to_string().to_lower_case() == secondary_lookup_name)
		{
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + it.smallimage, Vec2iMake(30,30));
		}
		else if (f != $familiar[none] && f.image != "" && f.to_string().to_lower_case() == secondary_lookup_name)
		{
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + f.image, Vec2iMake(30,30));
		}
        else if (e != $effect[none] && e.image != "" && e.to_string().to_lower_case() == secondary_lookup_name)
        {
            __kol_images[lookup_name] = KOLImageMake(e.image, Vec2iMake(30,30));
        }
		else
		{
            if (__setting_debug_mode)
                print("Unknown image \"" + lookup_name + "\"");
			return KOLImageMake();
		}
	}
	return __kol_images[lookup_name];
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_center, Vec2i max_image_dimensions, string container_additional_class)
{
    KOLImagesInit();
	lookup_name = to_lower_case(lookup_name);
    
    boolean half_sized_output = false;
	lookup_name = to_lower_case(lookup_name);
    if (lookup_name.stringHasPrefix("__half "))
    {
        lookup_name = lookup_name.substring(7);
        half_sized_output = true;
    }
    
    
	KOLImage kol_image = KOLImageLookup(lookup_name);
	buffer result;
	if (kol_image.url == "")
		return "".to_buffer();
    
    Vec2i image_size = Vec2iCopy(kol_image.base_image_size);
    Rect image_crop = RectCopy(kol_image.crop);
    
    
		
	boolean have_size = true;
	boolean have_crop = true;
	if (image_size.x == 0 || image_size.y == 0)
		have_size = false;
	if (image_crop.max_coordinate.x == 0 || image_crop.max_coordinate.y == 0)
		have_crop = false;
    
    
    float scale_ratio = 1.0;
    if (have_size || have_crop)
    {
        Vec2i effective_image_size = image_size;
            
        if (half_sized_output)
        {
            effective_image_size.x = round(effective_image_size.x.to_float() * 0.5);
            effective_image_size.y = round(effective_image_size.y.to_float() * 0.5);
        }
        if (have_crop)
            effective_image_size = Vec2iMake(image_crop.max_coordinate.x - image_crop.min_coordinate.x + 1, image_crop.max_coordinate.y - image_crop.min_coordinate.y + 1);
        
        if (half_sized_output && have_crop)
        {
            image_crop.min_coordinate.x = round(image_crop.min_coordinate.x.to_float() * 0.5);
            image_crop.min_coordinate.y = round(image_crop.min_coordinate.y.to_float() * 0.5);
            image_crop.max_coordinate.x = round(image_crop.max_coordinate.x.to_float() * 0.5);
            image_crop.max_coordinate.y = round(image_crop.max_coordinate.y.to_float() * 0.5);
        }
        
        if (effective_image_size.x > max_image_dimensions.x || effective_image_size.y > max_image_dimensions.y)
        {
            //Scale down, to match limitations:
            float image_ratio = 1.0;
            if (effective_image_size.x != 0.0 && effective_image_size.y != 0.0)
            {
                image_ratio = effective_image_size.y.to_float() / effective_image_size.x.to_float();
                //Try width-major:
                Vec2i new_image_size = Vec2iMake(max_image_dimensions.x.to_float(), max_image_dimensions.x.to_float() * image_ratio);
                if (new_image_size.x > max_image_dimensions.x || new_image_size.y > max_image_dimensions.y) //too big, try vertical-major:
                {
                    new_image_size = Vec2iMake(max_image_dimensions.y.to_float() / image_ratio, max_image_dimensions.y);
                }
                //Find ratio:
                if (new_image_size.x != 0.0)
                {
                    scale_ratio = new_image_size.x.to_float() / effective_image_size.x.to_float();
                }
            }
        }
    }
    if (scale_ratio > 1.0) scale_ratio = 1.0;
    if (scale_ratio < 1.0)
    {
        image_size.x = round(image_size.x.to_float() * scale_ratio);
        image_size.y = round(image_size.y.to_float() * scale_ratio);
        image_crop.min_coordinate.x = ceil(image_crop.min_coordinate.x.to_float() * scale_ratio);
        image_crop.min_coordinate.y = ceil(image_crop.min_coordinate.y.to_float() * scale_ratio);
        image_crop.max_coordinate.x = floor(image_crop.max_coordinate.x.to_float() * scale_ratio);
        image_crop.max_coordinate.y = floor(image_crop.max_coordinate.y.to_float() * scale_ratio);
    }
		
	boolean outputting_div = false;
	boolean outputting_erase_zones = false;
	Vec2i div_dimensions;
    
    if (container_additional_class.length() > 0)
        outputting_div = true;
	if (have_size)
	{
		div_dimensions = image_size;
		if (have_crop)
		{
			outputting_div = true;
			div_dimensions = Vec2iMake(image_crop.max_coordinate.x - image_crop.min_coordinate.x + 1,
									   image_crop.max_coordinate.y - image_crop.min_coordinate.y + 1);
		}
		else if (image_size.x > 100)
		{
			//Automatically crop to 100 pixels wide:
			outputting_div = true;
			div_dimensions = image_size;
			div_dimensions.x = min(100, div_dimensions.x);
		}
		if (kol_image.erase_zones.count() > 0)
		{
			outputting_div = true;
			outputting_erase_zones = true;
		}
	}
	
	if (outputting_div)
	{
		string style = "";
        
        if (have_size)
            style = "width:" + div_dimensions.x + "px; height:" + div_dimensions.y + "px;";
		if (__setting_show_alignment_guides)
			style += "background:purple;";
        
        string [int] classes;
        classes.listAppend("r_image_container");
        
        if (should_center)
            classes.listAppend("r_center");
        if (container_additional_class.length() > 0)
            classes.listAppend(container_additional_class);
        result.append(HTMLGenerateTagPrefix("div", mapMake("class", classes.listJoinComponents(" "), "style", style)));
	}
	
	string [string] img_tag_attributes;
	img_tag_attributes["src"] = kol_image.url;
	if (have_size)
	{
		img_tag_attributes["width"] =  image_size.x;
		img_tag_attributes["height"] =  image_size.y;
	}
    
    //Needs to be optimized to use buffers first.
    /*string unadorned_name = lookup_name;
    int breakout = 50;
    while (unadorned_name.length() > 0 && unadorned_name.stringHasPrefix("__") && breakout > 0)
    {
        int space_index = unadorned_name.index_of(" ") + 1;
        if (space_index < 0 || space_index > unadorned_name.length())
            space_index = unadorned_name.length();
        unadorned_name = unadorned_name.substring(space_index);
        breakout -= 1;
    }*/
    
	img_tag_attributes["alt"] = lookup_name.HTMLEscapeString();
	//img_tag_attributes["title"] = unadorned_name.HTMLEscapeString();
	
	if (have_crop && outputting_div)
	{
		//cordinates are upper-left
		//format is clip:rect(top-edge,right-edge,bottom-edge,left-edge);
		
		int top_edge = image_crop.min_coordinate.y;
		int bottom_edge = image_crop.max_coordinate.y;
		int left_edge = image_crop.min_coordinate.x;
		int right_edge = image_crop.max_coordinate.x;
		
		int margin_top = -(image_crop.min_coordinate.y);
		int margin_bottom = -(image_size.y - image_crop.max_coordinate.y);
		int margin_left = -(image_crop.min_coordinate.x);
		int margin_right = -(image_size.x - image_crop.max_coordinate.x);
		img_tag_attributes["style"] = "margin: " + margin_top + "px " + margin_right + "px " + margin_bottom + "px " + margin_left + "px;";
	}
	
	if (__setting_show_alignment_guides)
		img_tag_attributes["style"] += "opacity: 0.5;";
	
	result.append(HTMLGenerateTagPrefix("img", img_tag_attributes));
	
	if (outputting_erase_zones)
	{
		foreach i in kol_image.erase_zones
		{
			Rect zone = RectCopy(kol_image.erase_zones[i]);
			Vec2i dimensions = Vec2iMake(zone.max_coordinate.x - zone.min_coordinate.x + 1, zone.max_coordinate.y - zone.min_coordinate.y + 1);
            
            if (scale_ratio < 1.0)
            {
                dimensions.x = round(dimensions.x.to_float() * scale_ratio);
                dimensions.y = round(dimensions.y.to_float() * scale_ratio);
                zone.min_coordinate.x = round(zone.min_coordinate.x.to_float() * scale_ratio);
                zone.min_coordinate.y = round(zone.min_coordinate.y.to_float() * scale_ratio);
                zone.max_coordinate.x = round(zone.max_coordinate.x.to_float() * scale_ratio);
                zone.max_coordinate.y = round(zone.max_coordinate.y.to_float() * scale_ratio);
            }
			
			int top = 0;
			int left = 0;
			
			top = -image_crop.min_coordinate.y;
			left = -image_crop.min_coordinate.x;
			
			top += zone.min_coordinate.y;
			left += zone.min_coordinate.x;
			//Output a white div over this area:
			string style = "width:" + dimensions.x + "px;height:" + dimensions.y + "px;";
			if (__setting_show_alignment_guides)
				style += "background:pink;";
			else
				style += "background:#FFFFFF;";
			
			style += "z-index:2;position:absolute;top:" + top + "px;left:" + left + "px;";
			
			result.append(HTMLGenerateDivOfStyle("", style));
		}
	}
	
	if (outputting_div)
		result.append("</div>");
	return result;
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_center, Vec2i max_image_dimensions)
{
    return KOLImageGenerateImageHTML(lookup_name, should_center, max_image_dimensions, "");
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_center)
{
	return KOLImageGenerateImageHTML(lookup_name, should_center, Vec2iMake(65535, 65535));
}






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
//Library for checking if any given location is unlocked.
//Similar to canadv.ash, except there's no code for using items and no URLs are (currently) visited. This limits our accuracy.
//Currently, most locations are missing, sorry.




boolean [location] __la_location_is_available;

boolean __la_commons_were_inited = false;
int __la_turncount_initialized_on = -1;

boolean locationQuestPropertyPastInternalStepNumber(string quest_property, int number)
{
	return QuestStateConvertQuestPropertyValueToNumber(get_property(quest_property)) >= number;
}

//Do not call - internal implementation detail.
boolean locationAvailablePrivateCheck(location loc, Error able_to_find)
{
	string zone = loc.zone;
	
	if (zone == "KOL High School")
	{
		if (my_path_id() == PATH_KOLHS)
			return true;
		return false;
	}
	if (zone == "Mothership")
	{
		if (my_path_id() == PATH_BUGBEAR_INVASION)
			return true;
		return false;
	}
	if (zone == "BadMoon")
	{
		if (in_bad_moon())
			return true;
		return false;
	}
	
	switch (loc)
	{
		case $location[The Castle in the Clouds in the Sky (Ground floor)]:
			return get_property_int("lastCastleGroundUnlock") == my_ascensions();
		case $location[The Castle in the Clouds in the Sky (Top floor)]:
			return get_property_int("lastCastleTopUnlock") == my_ascensions();
		case $location[The Haunted Kitchen]:
		case $location[The Haunted Conservatory]:
		case $location[The Haunted Billiards Room]:
            if ($item[spookyraven library key].available_amount() > 0 || $item[spookyraven ballroom key].available_amount() > 0)
                return true;
			return get_property_int("lastManorUnlock") == my_ascensions();
		case $location[The Haunted Bedroom]:
		case $location[The Haunted Bathroom]:
            if ($item[spookyraven ballroom key].available_amount() > 0)
                return true;
			return get_property_int("lastSecondFloorUnlock") == my_ascensions();
		case $location[cobb's knob barracks]:
		case $location[cobb's knob kitchens]:
		case $location[cobb's knob harem]:
		case $location[cobb's knob treasury]:
			string quest_value = get_property("questL05Goblin");
			if (quest_value == "finished")
				return true;
			else if (quest_value == "started") //FIXME locationQuestPropertyPastInternalStepNumber
			{
				//Inference - quest is started. If map is missing, area must be unlocked
				if ($item[cobb's knob map].available_amount() > 0)
					return false;
				else //no map, must be available
					return true;
			}
			//unstarted, impossible
            return false;
		case $location[Vanya's Castle Chapel]:
			if ($item[map to Vanya's Castle].available_amount() > 0)
				return true;
			return false;
		case $location[the hidden park]:
			return locationQuestPropertyPastInternalStepNumber("questL11Worship", 4);
        case $location[the hidden temple]:
            return (get_property_int("lastTempleUnlock") == my_ascensions());
		case $location[the spooky forest]:
			return locationQuestPropertyPastInternalStepNumber("questL02Larva", 1);
		case $location[The Smut Orc Logging Camp]:
			return locationQuestPropertyPastInternalStepNumber("questL09Topping", 1);
		case $location[guano junction]:
			return locationQuestPropertyPastInternalStepNumber("questL04Bat", 1);
		case $location[itznotyerzitz mine]:
			return locationQuestPropertyPastInternalStepNumber("questL08Trapper", 2);
        case $location[the arid, extra-dry desert]:
			return (locationQuestPropertyPastInternalStepNumber("questL11MacGuffin", 3) || $item[your father's MacGuffin diary].available_amount() > 0);
        case $location[the oasis]:
			return (get_property_int("desertExploration") > 0) && (locationQuestPropertyPastInternalStepNumber("questL11MacGuffin", 3) || $item[your father's MacGuffin diary].available_amount() > 0);
        case $location[the defiled alcove]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptAlcoveEvilness") > 0;
        case $location[the defiled cranny]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptCrannyEvilness") > 0;
        case $location[the defiled niche]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptNicheEvilness") > 0;
        case $location[the defiled nook]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptNookEvilness") > 0;
		case $location[south of the border]:
			return $items[pumpkin carriage,desert bus pass, bitchin' meatcar, tin lizzie].available_amount() > 0;
		default:
			break;
	}
    if (loc.turnsAttemptedInLocation() > 0) //FIXME make this finer-grained, this is hacky
        return true;
	
	ErrorSet(able_to_find, "");
	return false;
}

void locationAvailablePrivateInit()
{
	if (__la_commons_were_inited && __la_turncount_initialized_on == my_turncount())
		return;
        
    if (__la_location_is_available.count() > 0)
    {
        foreach key in __la_location_is_available
        {
            remove __la_location_is_available[key];
        }
    }
	
	boolean [location] locations_always_available = $locations[the haunted pantry,the sleazy back alley,the outskirts of cobb's knob,the limerick dungeon,The Haiku Dungeon,The Daily Dungeon];
	foreach loc in locations_always_available
	{
		if (loc == $location[none])
			continue;
		__la_location_is_available[loc] = true;
	}
		
	string zones_never_accessible_string = "Gyms,Crimbo06,Crimbo07,Crimbo08,Crimbo09,Crimbo10,The Candy Diorama,Crimbo12,WhiteWed";
	
	item [location] locations_unlocked_by_item;
	effect [location] locations_unlocked_by_effect;
	
	item [string] zones_unlocked_by_item;
	effect [string] zones_unlocked_by_effect;
	
	locations_unlocked_by_item[$location[Cobb's Knob Menagerie\, Level 1]] = $item[Cobb's Knob Menagerie key];
	locations_unlocked_by_item[$location[Cobb's Knob Menagerie\, Level 2]] = $item[Cobb's Knob Menagerie key];
	locations_unlocked_by_item[$location[Cobb's Knob Menagerie\, Level 3]] = $item[Cobb's Knob Menagerie key];
	
	locations_unlocked_by_item[$location[the haunted ballroom]] = $item[spookyraven ballroom key];
	locations_unlocked_by_item[$location[The Haunted Library]] = $item[spookyraven library key];
	locations_unlocked_by_item[$location[The Haunted Gallery]] = $item[spookyraven gallery key];
	locations_unlocked_by_item[$location[The Castle in the Clouds in the Sky (Basement)]] = $item[S.O.C.K.];
	locations_unlocked_by_item[$location[the hole in the sky]] = $item[steam-powered model rocketship];
	
	locations_unlocked_by_item[$location[Vanya's Castle Foyer]] = $item[map to Vanya's Castle];
	
	
	zones_unlocked_by_item["Magic Commune"] = $item[map to the Magic Commune];
	zones_unlocked_by_item["Landscaper"] = $item[Map to The Landscaper's Lair];
	zones_unlocked_by_item["Kegger"] = $item[map to the Kegger in the Woods];
	zones_unlocked_by_item["Ellsbury's Claim"] = $item[Map to Ellsbury's Claim];
	zones_unlocked_by_item["Memories"] = $item[empty agua de vida bottle];
	zones_unlocked_by_item["Casino"] = $item[casino pass];
	
	zones_unlocked_by_effect["Astral"] = $effect[Half-Astral];
	zones_unlocked_by_effect["Spaaace"] = $effect[Transpondent];
	zones_unlocked_by_effect["RabbitHole"] = $effect[Down the Rabbit Hole];
	zones_unlocked_by_effect["Wormwood"] = $effect[Absinthe-Minded];	
	zones_unlocked_by_effect["Suburbs"] = $effect[Dis Abled];
	
	string [int] zones_never_accessible = split_string_mutable(zones_never_accessible_string, ",");
	
	boolean [string] zone_accessibility_status = zones_never_accessible.listGeneratePresenceMap();
	
	
	foreach loc in $locations[Shivering Timbers,A Skeleton Invasion!,The Cannon Museum,A Swarm of Yeti-Mounted Skeletons,The Bonewall,A Massive Flying Battleship,A Supply Train,The Bone Star,Grim Grimacite Site,A Pile of Old Servers,The Haunted Sorority House,Fightin' Fire,Super-Intense Mega-Grassfire,Fierce Flying Flames,Lord Flameface's Castle Entryway,Lord Flameface's Castle Belfry,Lord Flameface's Throne Room,A Stinking Abyssal Portal,A Scorching Abyssal Portal,A Terrifying Abyssal Portal,A Freezing Abyssal Portal,An Unsettling Abyssal Portal,A Yawning Abyssal Portal,The Space Odyssey Discotheque,The Spirit World]
	{
		__la_location_is_available[loc] = false;
	}
	
	foreach loc in locations_unlocked_by_item
	{
		if (locations_unlocked_by_item[loc].available_amount() > 0)
			__la_location_is_available[loc] = true;
		else
			__la_location_is_available[loc] = false;
	}
	foreach loc in locations_unlocked_by_effect
	{
		if (locations_unlocked_by_effect[loc].have_effect() > 0)
			__la_location_is_available[loc] = true;
		else
			__la_location_is_available[loc] = false;
	}
	
	foreach zone in zones_unlocked_by_item
	{
		if (zones_unlocked_by_item[zone].available_amount() > 0)
			zone_accessibility_status[zone] = true;
		else
			zone_accessibility_status[zone] = false;
	}
	foreach zone in zones_unlocked_by_effect
	{
		if (zones_unlocked_by_effect[zone].have_effect() > 0)
			zone_accessibility_status[zone] = true;
		else
			zone_accessibility_status[zone] = false;
	}
	
	
	
	
	
	foreach loc in $locations[]
	{
		if (zone_accessibility_status contains (loc.zone))
			__la_location_is_available[loc] = zone_accessibility_status[loc.zone];
	}
		
		
	__la_commons_were_inited = true;
    __la_turncount_initialized_on = my_turncount();
}

boolean locationAvailable(location loc, Error able_to_find)
{
    locationAvailablePrivateInit();
	if ((__la_location_is_available contains loc))
		return __la_location_is_available[loc];
	
	boolean [int] could_find;
	boolean is_available = locationAvailablePrivateCheck(loc, able_to_find);
	if (able_to_find.was_error)
		return false;
	__la_location_is_available[loc] = is_available;
	
	return is_available;
}

boolean locationAvailable(location loc)
{
	return locationAvailable(loc, ErrorMake());
}


void locationAvailableRunDiagnostics()
{
	location [string][int] unknown_locations_by_zone;
	
	foreach loc in $locations[]
	{
		Error able_to_find;
		locationAvailable(loc, able_to_find);
		if (!able_to_find.was_error)
			continue;
		if (!(unknown_locations_by_zone contains (loc.zone)))
			unknown_locations_by_zone[loc.zone] = listMakeBlankLocation();
		unknown_locations_by_zone[loc.zone].listAppend(loc);
	}
	if (unknown_locations_by_zone.count() > 0)
	{
		print("Unknown locations in location availability tester:");
		foreach zone in unknown_locations_by_zone
		{
			print(zone + ":");
			foreach key in unknown_locations_by_zone[zone]
			{
				location loc = unknown_locations_by_zone[zone][key];
				print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + loc);
			}
		}
	}
}

string HTMLGenerateFutureTextByLocationAvailability(string base_text, location place)
{
    if (!locationAvailable(place) && place != $location[none])
    {
        base_text = HTMLGenerateSpanOfClass(base_text, "r_future_option");
    }
    return base_text;
}

string HTMLGenerateFutureTextByLocationAvailability(location place)
{
	return HTMLGenerateFutureTextByLocationAvailability(place.to_string(), place);
}



string [location] __urls_for_locations;
boolean __urls_for_locations_initialized = false;

string getClickableURLForLocation(location l)
{
    if (!__urls_for_locations_initialized)
    {
        foreach l in $locations[The Beanbat Chamber, the bat hole entrance, the batrat and ratbat burrow, guano junction, the boss bat's lair]
            __urls_for_locations[l] = "place.php?whichplace=bathole";
        foreach l in $locations[the \"fun\" house, pre-cyrpt cemetary, post-cyrpt cemetary,The Outskirts of Cobb's Knob]
            __urls_for_locations[l] = "place.php?whichplace=plains";
            
        if ($item[talisman o' nam].equipped_amount() == 0)
            __urls_for_locations[$location[The Palindome]] = "inventory.php?which=2";
        else
            __urls_for_locations[$location[The Palindome]] = "place.php?whichplace=palindome";
        
        if ($location[cobb's knob barracks].locationAvailable())
            __urls_for_locations[$location[The Outskirts of Cobb's Knob]] = "cobbsknob.php";
        
        foreach l in $locations[cobb's knob barracks, cobb's knob kitchens, cobb's knob harem, cobb's knob treasury]
            __urls_for_locations[l] = "cobbsknob.php";
        __urls_for_locations[$location[a barroom brawl]] = "tavern.php";
        __urls_for_locations[$location[the sleazy back alley]] = "place.php?whichplace=town_wrong";
        
        foreach l in $locations[the spooky forest, whitey's grove, the road to white citadel, the black forest, the hidden temple]
            __urls_for_locations[l] = "place.php?whichplace=woods";
            
        if ($location[cobb's knob kitchens].locationAvailable())
            __urls_for_locations[$location[The Haunted Pantry]] = "place.php?whichplace=spookyraven1";
        else
            __urls_for_locations[$location[The Haunted Pantry]] = "place.php?whichplace=town_right";
            
            
        foreach l in $locations[The Oasis, the arid\, extra-dry desert, south of the border, The Shore\, Inc. Travel Agency]
            __urls_for_locations[l] = "place.php?whichplace=desertbeach";
        __urls_for_locations[$location[The Smut Orc Logging Camp]] = "place.php?whichplace=orc_chasm";
        foreach l in $locations[the haunted wine cellar (northwest), the haunted wine cellar (southwest), the haunted wine cellar (northeast), the haunted wine cellar (southeast)]
            __urls_for_locations[l] = "manor3.php";
        foreach l in $locations[the castle in the clouds in the sky (basement), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (top floor)]
            __urls_for_locations[l] = "place.php?whichplace=giantcastle";
            
        foreach l in $locations[the haunted gallery, the haunted billiards room, the haunted library, the haunted conservatory, the haunted kitchen]
            __urls_for_locations[l] = "place.php?whichplace=spookyraven1";
            
        foreach l in $locations[the haunted bedroom, the haunted ballroom, the haunted bathroom]
            __urls_for_locations[l] = "place.php?whichplace=spookyraven2";
            
            
        foreach l in $locations[the hidden apartment building, the hidden hospital, the hidden office building, the hidden bowling alley, the hidden park]
            __urls_for_locations[l] = "place.php?whichplace=hiddencity";
            
        foreach l in $locations[the extreme slope, the icy peak, lair of the ninja snowmen, the goatlet, itznotyerzitz mine]
            __urls_for_locations[l] = "place.php?whichplace=mclargehuge";
            
            
        foreach l in $locations[the poop deck, Barrrney's Barrr, the f'c'le, belowdecks]
            __urls_for_locations[l] = "place.php?whichplace=cove";
        foreach l in $locations[the penultimate fantasy airship,the hole in the sky]
            __urls_for_locations[l] = "place.php?whichplace=beanstalk";
            
        foreach l in $locations[the haiku dungeon, the limerick dungeon, the dungeons of doom, the enormous greater-than sign, the daily dungeon]
            __urls_for_locations[l] = "da.php";

        __urls_for_locations[$location[Anger Man's Level]] = "place.php?whichplace=junggate_3";
        if ($effect[Absinthe-Minded].have_effect() > 0)
        {
            foreach l in $locations[The Stately Pleasure Dome, the mouldering mansion, the rogue windmill]
                __urls_for_locations[l] = "place.php?whichplace=wormwood";
        }
        else
        {
            foreach l in $locations[The Stately Pleasure Dome, the mouldering mansion, the rogue windmill]
                __urls_for_locations[l] = "mall.php";
        }
        
        foreach l in $locations[chinatown shops, chinatown tenement, triad factory,1st floor\, shiawase-mitsuhama building,2nd floor\, shiawase-mitsuhama building,3rd floor\, shiawase-mitsuhama building]
            __urls_for_locations[l] = "place.php?whichplace=junggate_1";
        
        if ($effect[down the rabbit hole].have_effect() > 0)
            __urls_for_locations[$location[The Red Queen's Garden]] = "place.php?whichplace=rabbithole";
        else
            __urls_for_locations[$location[The Red Queen's Garden]] = "mall.php";
            
        if ($effect[Shape of...Mole!].have_effect() > 0)
            __urls_for_locations[$location[Mt. Molehill]] = "mountains.php";
        else
            __urls_for_locations[$location[Mt. Molehill]] = "mall.php";
        
        foreach l in $locations[the primordial soup, the jungles of ancient loathing, seaside megalopolis]
            __urls_for_locations[l] = "place.php?whichplace=memories";
            
        foreach l in $locations[domed city of ronaldus,domed city of grimacia,hamburglaris shield generator]
        {
            if ($effect[Transpondent].have_effect() > 0)
                __urls_for_locations[l] = "place.php?whichplace=spaaace";
            else
                __urls_for_locations[l] = "mall.php";
        }
        
        
        foreach l in $locations[The Clumsiness Grove,The Maelstrom of Lovers,The Glacier of Jerks]
        {
            if ($effect[Dis Abled].have_effect() > 0)
                __urls_for_locations[l] = "suburbandis.php";
            else
                __urls_for_locations[l] = "mall.php";
        }
        
        foreach l in $locations[Cobb's Knob Menagerie\, Level 1,Cobb's Knob Menagerie\, Level 2,Cobb's Knob Menagerie\, Level 3]
            __urls_for_locations[l] = "cobbsknob.php?action=tomenagerie";
        foreach l in $locations[cobb's knob laboratory,the knob shaft]
            __urls_for_locations[l] = "cobbsknob.php?action=tolabs";
            
        foreach l in $locations[the degrassi knoll restroom, the degrassi knoll bakery, the degrassi knoll gym, the degrassi knoll garage]
        {
            if (knoll_available())
                __urls_for_locations[l] = "place.php?whichplace=knoll_friendly";
            else
                __urls_for_locations[l] = "place.php?whichplace=knoll_hostile";
        }
        
        if (get_property_boolean("_psychoJarUsed"))
            __urls_for_locations[$location[the nightmare meatrealm]] = "place.php?whichplace=junggate_6";
        else
            __urls_for_locations[$location[the nightmare meatrealm]] = "mall.php";
        __urls_for_locations_initialized = true;
    }
    
    if (__urls_for_locations contains l)
        return __urls_for_locations[l];
    return "";
}

void QLevel2Init()
{
	//questL02Larva
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questL02Larva");
	
	state.quest_name = "Spooky Forest Quest";
	state.image_name = "Spooky Forest";
	state.council_quest = true;
	
	if (my_level() >= 2)
		state.startable = true;
	
	if (state.in_progress)
	{
		if ($item[mosquito larva].available_amount() > 0)
		{
			state.state_boolean["have mosquito"] = true;
		}
	}
	else if (state.finished)
	{
		state.state_boolean["have mosquito"] = true;
	}
	
	__quest_state["Level 2"] = state;
	__quest_state["Spooky Forest"] = state;
}


void QLevel2GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Level 2"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
    string url = "place.php?whichplace=woods";
	
	subentry.header = base_quest_state.quest_name;
	
	
	if (base_quest_state.state_boolean["have mosquito"])
	{
		subentry.entries.listAppend("Finished, go chat with the council.");
        url = "town.php";
	}
	else
	{
		string [int] modifiers;
		modifiers.listAppend("-combat");
		
		string hipster_text = "";
		if (__misc_state["have hipster"])
		{
			hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
			modifiers.listAppend(__misc_state_string["hipster name"]);
		}
		if (delayRemainingInLocation($location[the spooky forest]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the spooky forest]), "turn", "turns") + hipster_text + ".";
            subentry.entries.listAppend(line);
			subentry.entries.listAppend("Run -combat after that.");
		}
		else
			subentry.entries.listAppend("Run -combat");
		subentry.entries.listAppend("Explore the stream" + __html_right_arrow_character + "March to the marsh");
		
		
		if (__misc_state_string["ballroom song"] != "-combat")
			subentry.entries.listAppend("Possibly wait until -combat ballroom song set. (marginal)");
			
		if (__misc_state["free runs available"])
		{
			subentry.entries.listAppend("Free run from monsters (low stats)");
			modifiers.listAppend("free runs");
		}
			
			
		subentry.modifiers = modifiers;
	}
	
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the spooky forest]));
}

void QLevel3Init()
{
	//questL03Rat
	//lastTavernSquare
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL03Rat");
	
	state.quest_name = "Typical Tavern Quest";
	state.image_name = "Typical Tavern";
	state.council_quest = true;
	
	if (my_level() >= 3 && __quest_state["Level 2"].finished)
		state.startable = true;
	
	__quest_state["Level 3"] = state;
	__quest_state["Typical Tavern"] = state;
}


void QLevel3GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 3"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 3"];
	boolean wait_until_level_eleven = false;
	if (have_skill($skill[ur-kel's aria of annoyance]) && my_level() < 11)
		wait_until_level_eleven = true;
	
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
    
    boolean can_skip_cold = numeric_modifier("Cold Damage") >= 20.0;
    boolean can_skip_hot = numeric_modifier("Hot Damage") >= 20.0;
    boolean can_skip_spooky = numeric_modifier("Spooky Damage") >= 20.0;
    boolean can_skip_stench = numeric_modifier("Stench Damage") >= 20.0;
    
    
	float rat_king_chance = clampNormalf(monster_level_adjustment_ignoring_plants() / 300.0);
	
    float average_tangles_found = (rat_king_chance * 8.5);
	
	if (wait_until_level_eleven)
		subentry.entries.listAppend("May want to wait until level 11 for most +ML from aria");
	string line = "Run +ML for tangles (" + roundForOutput(rat_king_chance * 100.0, 0) + "% rat king chance, " + average_tangles_found.roundForOutput(1) + " tangles on average";
	line += ")";
	
	subentry.entries.listAppend(line);
	
	string [int] elemental_sources_available;
	if ($item[piddles].available_amount() > 0 && $effect[Belch the Rainbow&trade;].have_effect() == 0)
		elemental_sources_available.listAppend("+" + MIN(11, my_level()) + " piddles");
	
	
	if (have_skill($skill[Benetton's Medley of Diversity]) && my_level() >= 15 && get_property_int("_benettonsCasts") < 10)
		elemental_sources_available.listAppend("+15 Benetton's Medley of Diversity");
	
	string elemental_sources_available_string;
	if (elemental_sources_available.count() > 0)
		elemental_sources_available_string = " (" + listJoinComponents(elemental_sources_available, ", ") + " available)";
	
    if (true)
    {
        int ncs_skippable = 0;
        string [int] additionals;
        if (!can_skip_cold)
            additionals.listAppend(HTMLGenerateSpanOfClass("cold", "r_element_cold"));
        else
            ncs_skippable += 1;
        if (!can_skip_hot)
            additionals.listAppend(HTMLGenerateSpanOfClass("hot", "r_element_hot"));
        else
            ncs_skippable += 1;
        if (!can_skip_spooky)
            additionals.listAppend(HTMLGenerateSpanOfClass("spooky", "r_element_spooky"));
        else
            ncs_skippable += 1;
        if (!can_skip_stench)
            additionals.listAppend(HTMLGenerateSpanOfClass("stench", "r_element_stench"));
        else
            ncs_skippable += 1;
        
        string line;
        if (additionals.count() > 0)
            line += "Run -combat with +20 " + additionals.listJoinComponents("/") + " damage.";
        else
            line += "Run -combat.";
        if (ncs_skippable < 4)
            line += elemental_sources_available_string;
        if (ncs_skippable > 0)
        {
            float rate = ncs_skippable.to_float() / 4.0;
            if (ncs_skippable == 4)
                line += "|Can skip every non-combat.";
            else
                line += "|Can skip " + (rate * 100.0).round() + "% of non-combats.";
        }
        if (ncs_skippable == 0)
        {
            line += "|Or possibly +combat for stats.";
            subentry.modifiers.listAppend("+combat/-combat");
        }
        else
            subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend(line);
    }
    subentry.modifiers.listAppend("+300 ML");
    
    string url = "tavern.php";
    
    if (get_property_int("lastCellarReset") == my_ascensions())
        url = "cellar.php";
	
	if (wait_until_level_eleven)
		optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the typical tavern cellar]));
	else
		task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the typical tavern cellar]));
}

void QLevel4Init()
{
	//questL04Bat
	//be sure to set state_int["areas unlocked"]
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL04Bat");
	
	state.quest_name = "Boss Bat Quest";
	state.image_name = "Boss Bat";
	state.council_quest = true;
	
	if (state.in_progress)
	{
		//Zones opened?
	}
	else if (state.finished)
	{
		state.state_int["areas unlocked"] = 3;
	}
	
	if (my_level() >= 4)
		state.startable = true;
		
	__quest_state["Level 4"] = state;
	__quest_state["Boss Bat"] = state;
}


void QLevel4GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 4"].in_progress)
		return;
	
	QuestState base_quest_state = __quest_state["Level 4"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "place.php?whichplace=bathole";
	
    if ($item[Boss Bat bandana].available_amount() > 0)
    {
        subentry.entries.listAppend("Quest finished, speak to the council of loathing.");
        url = "town.php";
    }
    else if ($location[the boss bat's lair].locationAvailable())
    {
        subentry.entries.listAppend("Run +meat in the boss bat's lair, if you feel like it. (250 meat drop)");
        subentry.modifiers.listAppend("+meat");
		if (delayRemainingInLocation($location[the boss bat's lair]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the boss bat's lair]), "turn", "turns") + " before boss bat shows up.";
            subentry.entries.listAppend(line);
		}
    }
    else
    {
        subentry.modifiers.listAppend("+566% item");
        int areas_unlocked = base_quest_state.state_int["areas unlocked"];
        int areas_locked = 3 - areas_unlocked;
        int sonars_needed = MAX(areas_locked - $item[sonar-in-a-biscuit].available_amount(), 0);
        
        subentry.entries.listAppend("Unknown areas to unlock, " + pluralize($item[sonar-in-a-biscuit]));
        
        if ($item[sonar-in-a-biscuit].available_amount() > 0 && areas_locked > 0)
        {
            int amount = MIN(areas_locked, $item[sonar-in-a-biscuit].available_amount());
            subentry.entries.listAppend("Use " + pluralize(amount, $item[sonar-in-a-biscuit]));
        }
        
        boolean have_stench_resistance = (numeric_modifier("stench resistance") > 0.0);
        if (!have_stench_resistance)
        {
            string line = "Need " + HTMLGenerateSpanOfClass("stench resistance", "r_element_stench") + " to adventure in Guano Junction.";
            if ($item[bum cheek].available_amount() > 0)
            {
                if ($item[bum cheek].equipped_amount() == 0)
                    line += "|*Equip your bum cheek.";
            }
            else if ($item[knob goblin harem veil].available_amount() == 0)
                line += "|*Possibly acquire a knob goblin harem veil.";
            else
            {
                if ($item[knob goblin harem veil].equipped_amount() == 0)
                    line += "|*Possibly equip your knob goblin harem veil.";
            }
            subentry.entries.listAppend(line);
        }
        
        
        if (__misc_state["can use clovers"] && sonars_needed >= 2)
            subentry.entries.listAppend("Potentially clover Guano Junction for two sonar-in-a-biscuit");
        if ($item[enchanted bean].available_amount() == 0 && !__quest_state["level 10"].state_boolean["beanstalk grown"])
            subentry.entries.listAppend("When beanbat chamber is unlocked, run +100% item for a single turn there for enchanted bean (50% drop)");
        if (__misc_state["yellow ray available"] && sonars_needed > 0)
            subentry.entries.listAppend("Potentially yellow ray for sonar-in-a-biscuit");
        if (sonars_needed > 0)
            subentry.entries.listAppend("Run +item in the beanbat and batrat burrow for biscuits (15% drop)");
        subentry.entries.listAppend("Run +meat in the boss bat's lair, if you feel like it. (250 meat drop)");
        subentry.modifiers.listAppend("+meat");
	}
    
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the bat hole entrance, guano junction, the batrat and ratbat burrow, the beanbat chamber,the boss bat's lair]));
}

void QLevel5Init()
{
	//questL05Goblin
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL05Goblin");
	state.quest_name = "Knob Goblin Quest";
	state.image_name = "cobb's knob";
	state.council_quest = true;
	
	
	if (my_level() >= 5)
		state.startable = true;
		
	if (get_property("questL05Goblin") == "unstarted" && $item[knob goblin encryption key].available_amount() == 0 && my_level() < 5)
	{
		//start the quest anyways, because they need to acquire the encryption key:
		QuestStateParseMafiaQuestPropertyValue(state, "started");
	}
		
		
	__quest_state["Level 5"] = state;
	__quest_state["Knob Goblin King"] = state;
}


void QLevel5GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 5"].in_progress)
		return;
    string url = "place.php?whichplace=plains";
	//if the quest isn't started and we have unlocked the barracks, wait until it's started:
	if (get_property("questL05Goblin") == "unstarted" && $item[knob goblin encryption key].available_amount() > 0) //have key already, waiting for quest to start, nothing more to do here
		return;
		
	QuestState base_quest_state = __quest_state["Level 5"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
	boolean should_output = true;
	
	if (!$location[cobb's knob barracks].locationAvailable())
	{
		if ($item[knob goblin encryption key].available_amount() == 0)
		{
			//Need key:
			//Unlocking:
			if (__misc_state["have hipster"])
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			if (__misc_state["free runs available"])
				subentry.modifiers.listAppend("free runs");
			subentry.entries.listAppend("Delay for ten turns in cobb's knob to unlock area.");
            if ($classes[seal clubber, turtle tamer] contains my_class() && !guild_store_available()) //FIXME tracking guild quest being started
                subentry.entries.listAppend("Possibly start your guild quest if you haven't.");
		}
		else if ($item[cobb's knob map].available_amount() > 0 && $item[knob goblin encryption key].available_amount() > 0)
		{
			subentry.entries.listAppend("Use cobb's knob map to unlock area.");
		}
		else if ($item[cobb's knob map].available_amount() == 0 && $item[knob goblin encryption key].available_amount() > 0)
			should_output = false;
	}
	else
	{
        url = "cobbsknob.php";
		//Cobb's knob unlocked. Now to set up for king:
		
		boolean can_use_harem_route = true;
		boolean can_use_kge_route = true;
		
		boolean have_knob_cake_or_ingredients = false;
		have_knob_cake_or_ingredients = ($item[knob cake].available_amount() > 0 || creatable_amount($item[knob cake]) > 0);
		
		if (can_use_kge_route && have_outfit_components("Knob Goblin Elite Guard Uniform") && have_knob_cake_or_ingredients)
			can_use_harem_route = false;
		else if (can_use_harem_route && have_outfit_components("Knob Goblin Harem Girl Disguise") && have_outfit_components("Knob Goblin Elite Guard Uniform")) //only stop guarding after KGE is acquired, for dispensary
			can_use_kge_route = false;
		
		if (!__misc_state["can equip just about any weapon"])
			can_use_kge_route = false;
        string fight_king_string = "fight king";
        if (53 + monster_level_adjustment() > my_buffedstat($stat[moxie]))
            fight_king_string += " (" + (53 + monster_level_adjustment()) + " attack)";
		if (can_use_harem_route)
		{
			string [int] harem_modifiers;
			string [int] harem_lines;
			if (!have_outfit_components("Knob Goblin Harem Girl Disguise"))
			{
				harem_lines.listAppend("Need disguise.|*20% drop from harem girls (olfact)|*Or adventure in zone for eleven (or more) turns.");
				harem_modifiers.listAppend("+400% item");
				harem_modifiers.listAppend("olfact harem girls");
			}
			else
			{
				string [int] things_to_do_before_fighting_king;
				if (!is_wearing_outfit("Knob Goblin Harem Girl Disguise"))
					things_to_do_before_fighting_king.listAppend("wear harem girl disguise");
				if ($effect[Knob Goblin Perfume].have_effect() > 0)
				{
				}
				else
				{
					if ($item[knob goblin perfume].available_amount() > 0)
					{
						things_to_do_before_fighting_king.listAppend("use knob goblin perfume");
					}
					else
					{
						things_to_do_before_fighting_king.listAppend("adventure in harem for perfume");
					}
				}
				things_to_do_before_fighting_king.listAppend(fight_king_string);
				harem_lines.listAppend(things_to_do_before_fighting_king.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
			}
			subentry.entries.listAppend("Harem route:|*" + ChecklistGenerateModifierSpan(harem_modifiers) + harem_lines.listJoinComponents("|*"));
		}
		if (can_use_kge_route)
		{
			string [int] kge_modifiers;
			string [int] kge_lines;
			
			if (!have_outfit_components("Knob Goblin Elite Guard Uniform"))
			{
				int outfit_pieces_needed = 0;
				if ($item[Knob Goblin elite polearm].available_amount() == 0)
					outfit_pieces_needed += 1;
				if ($item[Knob Goblin elite pants].available_amount() == 0)
					outfit_pieces_needed += 1;
				if ($item[Knob Goblin elite helm].available_amount() == 0)
					outfit_pieces_needed += 1;
				//take into account combats?
				//with banishes and slimeling and +item and?
                //too complicated. Possibly remove?
				kge_modifiers.listAppend("-combat");
				string line = "Need knob goblin elite guard uniform.|*Semi-rare in barracks.|*Or run -combat in barracks.";
				if (familiar_is_usable($familiar[slimeling]))
					line += " with slimeling";
                
                line += "|*" + generateTurnsToSeeNoncombat(85, outfit_pieces_needed, "acquire outfit via only non-combats");
				kge_lines.listAppend(line);
			}
			else
			{
				string cook_cake_line  = "cook a knob cake (1 adventure";
				if (have_skill($skill[inigo's incantation of inspiration]))
					cook_cake_line += ", can use inigo's";
				cook_cake_line += ")";
				string [int] things_to_do_before_fighting_king;
				if (!is_wearing_outfit("Knob Goblin Elite Guard Uniform"))
					things_to_do_before_fighting_king.listAppend("wear knob goblin elite guard uniform");
				if ($item[knob cake].available_amount() > 0)
				{
				}
				else if (creatable_amount($item[knob cake]) > 0)
				{
					things_to_do_before_fighting_king.listAppend(cook_cake_line);
				}
				else
				{
					boolean have_first_step = ($item[knob cake pan].available_amount() > 0 || $item[unfrosted Knob cake].available_amount() > 0);
					boolean have_second_step = ($item[knob batter].available_amount() > 0 || $item[unfrosted Knob cake].available_amount() > 0);
					boolean have_third_step = ($item[knob frosting].available_amount() > 0); //should be impossible
					have_third_step = have_third_step && have_second_step && have_first_step;
					have_second_step = have_second_step && have_first_step;
					
					string times_remaining = "three times";
					if (have_first_step)
						times_remaining = "two times";
					if (have_second_step)
						times_remaining = "One More Time";
					if (have_third_step)
						times_remaining = "zero times?";
					string line = "adventure in kitchens " + times_remaining + " for knob cake components";
					things_to_do_before_fighting_king.listAppend(line);
					things_to_do_before_fighting_king.listAppend(cook_cake_line);
				}
				things_to_do_before_fighting_king.listAppend(fight_king_string);
				kge_lines.listAppend(things_to_do_before_fighting_king.listJoinComponents(", then ", "").capitalizeFirstLetter() + ".");
			}
			subentry.entries.listAppend("Guard route:|*" + ChecklistGenerateModifierSpan(kge_modifiers) + kge_lines.listJoinComponents("|*"));
		}
	}
	
	if (should_output)
		task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[cobb's knob barracks, cobb's knob kitchens, cobb's knob harem, the outskirts of cobb's knob]));
}

void QLevel6Init()
{
	//questL06Friar
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL06Friar");
	state.quest_name = "Deep Fat Friars' Quest";
	state.image_name = "forest friars";
	state.council_quest = true;
	
	if (my_level() >= 6)
		state.startable = true;
	
	__quest_state["Level 6"] = state;
	__quest_state["Friars"] = state;
}

float QLevel6TurnsToCompleteArea(location place)
{
    //FIXME not sure how accurate these calculations are.
    //First NC will always happen at 6, second at 11, third at 16.
    int turns_spent_in_zone = turnsAttemptedInLocation(place); //not always accurate
    int ncs_found = noncombatTurnsAttemptedInLocation(place);
    if (ncs_found == 3)
        return 0.0;
    float turns_remaining = 0.0;
    int ncs_remaining = MAX(0, 3 - ncs_found);
    
    float combat_rate = 0.85 + combat_rate_modifier() / 100.0;
    float noncombat_rate = 1.0 - combat_rate;
    
    if (noncombat_rate != 0.0)
        turns_remaining = ncs_remaining / noncombat_rate;
    
    return MIN(turns_remaining, MAX(0.0, 16.0 - turns_spent_in_zone.to_float()));
}


void QLevel6GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 6"].in_progress)
		return;
	boolean want_hell_ramen = false;
	if (have_skill($skill[pastamastery]) && have_skill($skill[Advanced Saucecrafting]))
		want_hell_ramen = true;
	boolean hot_wings_relevant = __quest_state["Pirate Quest"].state_boolean["hot wings relevant"];
	boolean need_more_hot_wings = __quest_state["Pirate Quest"].state_boolean["need more hot wings"];
	
	QuestState base_quest_state = __quest_state["Level 6"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	if (want_hell_ramen && __misc_state["have olfaction equivalent"])
		subentry.modifiers.listAppend("olfact hellions");
	
	string [int] sources_need_234;
	if (want_hell_ramen)
		sources_need_234.listAppend("hell ramen");
	if (need_more_hot_wings)
		sources_need_234.listAppend("hot wings");
	if (sources_need_234.count() > 0)
		subentry.modifiers.listAppend("+234% item");
    
    boolean need_minus_combat = false;
	if ($item[dodecagram].available_amount() == 0)
    {
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Neck of the Woods", "r_bold") + ", acquire dodecagram.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the dark neck of the woods]), 1) + " average turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	if ($item[box of birthday candles].available_amount() == 0)
    {
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Heart of the Woods", "r_bold") + ", acquire box of birthday candles.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the Dark Heart of the Woods]), 1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	if ($item[Eldritch butterknife].available_amount() == 0)
    {
		subentry.entries.listAppend("Adventure in " + HTMLGenerateSpanOfClass("Dark Elbow of the Woods", "r_bold") + ", acquire Eldritch butterknife.|~" + roundForOutput(QLevel6TurnsToCompleteArea($location[the Dark Elbow of the Woods]), 1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        need_minus_combat = true;
    }
	
    string [int] needed_modifiers;
    if (need_minus_combat)
    {
        subentry.modifiers.listAppend("-combat");
        needed_modifiers.listAppend("-combat");
    }
	if (sources_need_234.count() > 0)
        needed_modifiers.listAppend("+234% item for " + listJoinComponents(sources_need_234, "/"));
    if (needed_modifiers.count() > 0)
        subentry.entries.listAppend("Run " + needed_modifiers.listJoinComponents(", ", "and") + ".");
    
	if ($item[dodecagram].available_amount() + $item[box of birthday candles].available_amount() + $item[Eldritch butterknife].available_amount() == 3)
    {
        if (!(hot_wings_relevant && $item[hot wing].available_amount() <3))
        {
            subentry.entries.listAppend("Go to the cairn stones!");
        }
        else
        {
            subentry.entries.listAppend("Visit the dark heart of the woods for hot wings.");
        }
    }
	
	if (__misc_state_int["ruby w needed"] > 0)
		subentry.entries.listAppend("Potentially find ruby W, if not clovering (w imp, dark neck, 30% drop)");
	if (hot_wings_relevant)
    {
        if ($item[hot wing].available_amount() <3 )
            subentry.entries.listAppend((MIN(3, $item[hot wing].available_amount())) + "/3 hot wings for pirate quest. (optional, 30% drop)");
        else
            subentry.entries.listAppend((MIN(3, $item[hot wing].available_amount())) + "/3 hot wings for pirate quest.");
    }
	boolean should_delay = false;
	if (__misc_state_string["ballroom song"] != "-combat")
	{
		subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
		should_delay = true;
	}
	
	if (should_delay)
		future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "friars.php", subentry, $locations[the dark neck of the woods, the dark heart of the woods, the dark elbow of the woods]));
	else
		task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "friars.php", subentry, $locations[the dark neck of the woods, the dark heart of the woods, the dark elbow of the woods]));
}

void QLevel7Init()
{
	//questL07Cyrptic
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL07Cyrptic");
	state.quest_name = "Cyrpt Quest";
	state.image_name = "cyrpt";
	state.council_quest = true;
	
	if (my_level() >= 7)
		state.startable = true;
	
    if (state.started)
    {
        state.state_int["alcove evilness"] = get_property_int("cyrptAlcoveEvilness");
        state.state_int["cranny evilness"] = get_property_int("cyrptCrannyEvilness");
        state.state_int["niche evilness"] = get_property_int("cyrptNicheEvilness");
        state.state_int["nook evilness"] = get_property_int("cyrptNookEvilness");
	}
    else
    {
        //mafia won't track these properly until quest is started, I think?
        state.state_int["alcove evilness"] = 50;
        state.state_int["cranny evilness"] = 50;
        state.state_int["niche evilness"] = 50;
        state.state_int["nook evilness"] = 50;
    }
    
    if (state.finished)
    {
        //just in case:
        state.state_int["alcove evilness"] = 0;
        state.state_int["cranny evilness"] = 0;
        state.state_int["niche evilness"] = 0;
        state.state_int["nook evilness"] = 0;
    }
    
    foreach l in $strings[alcove,cranny,niche,nook]
    {
        boolean need_speeding_up = false;
        int evilness = state.state_int[l + " evilness"];
        if (evilness <= 26)
            need_speeding_up = false;
        else
            need_speeding_up = true;
        state.state_boolean[l + " needs speed tricks"] = need_speeding_up;
            
    }
    
	if (state.state_int["alcove evilness"] == 0)
		state.state_boolean["alcove finished"] = true;
	if (state.state_int["cranny evilness"] == 0)
		state.state_boolean["cranny finished"] = true;
	if (state.state_int["niche evilness"]  == 0)
		state.state_boolean["niche finished"] = true;
	if (state.state_int["nook evilness"] == 0)
		state.state_boolean["nook finished"] = true;
		
		
	__quest_state["Level 7"] = state;
	__quest_state["Cyrpt"] = state;
}


void QLevel7GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 7"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 7"];
	
	ChecklistEntry entry;
	entry.target_location = "crypt.php";
	entry.image_lookup_name = base_quest_state.image_name;
	entry.should_indent_after_first_subentry = true;
	entry.subentries.listAppend(ChecklistSubentryMake(base_quest_state.quest_name));
    entry.should_highlight = $locations[the defiled nook, the defiled cranny, the defiled alcove, the defiled niche, haert of the cyrpt] contains __last_adventure_location;
	
	string [int] evilness_properties = split_string_mutable("cyrptAlcoveEvilness,cyrptCrannyEvilness,cyrptNicheEvilness,cyrptNookEvilness", ",");
	string [string] evilness_text;
	
	foreach key in evilness_properties
	{
		string property = evilness_properties[key];
		int evilness = get_property_int(property);
		string text;
		if (evilness == 0)
			text = "Finished";
		else if (evilness <= 25)
			text = HTMLGenerateSpanFont("At boss", "red", "");
		else
			text = (evilness - 25) + " evilness to boss.";
		evilness_text[property] = text;
	}
	
	if (!base_quest_state.state_boolean["nook finished"])
	{
		int evilness = base_quest_state.state_int["nook evilness"];
		ChecklistSubentry subentry;
		subentry.header = "Defiled Nook";
		
		subentry.entries.listAppend(evilness_text["cyrptNookEvilness"]);
		
		if (evilness > 26)
		{
            subentry.modifiers.listAppend("+400% item");
            float item_drop = (100.0 + item_drop_modifier()) / 100.0;
            
            if ($location[the defiled nook].locationHasPlant("Horn of Plenty") && my_location() != $location[the defiled nook])
                item_drop += .25;
			float eyes_per_adventure = MIN(1.0, (item_drop) * 0.2);
            float eyes_value = 3.0;
            if (evilness < 29)
                eyes_value = clampi(evilness - 25 - 1, 0, 3);
			float evilness_per_adventure = MAX(1.0, 1.0 + eyes_per_adventure * eyes_value);
			
			if ($item[evil eye].available_amount() > 0)
            {
                if ($item[evil eye].available_amount() == 1)
                    subentry.entries.listAppend("Use your evil eye.");
                else
                    subentry.entries.listAppend("Use your evil eyes.");
            }
		
			float evilness_remaining = evilness - 25;
			evilness_remaining -= $item[evil eye].available_amount() * 3;
			if (evilness_remaining > 0)
			{
				float average_turns_remaining = (evilness_remaining / evilness_per_adventure);
				int theoretical_best_turns_remaining = ceil(evilness_remaining / 4.0);
				if (average_turns_remaining < theoretical_best_turns_remaining) //not sure about this. +344.91% item, 38 evilness, 4 optimal, 3.something not-optimal, what does it mean?
					average_turns_remaining = theoretical_best_turns_remaining;
		
				subentry.entries.listAppend(roundForOutput(eyes_per_adventure * 100.0, 0) + "% chance of evil eyes");
				subentry.entries.listAppend("~" + roundForOutput(average_turns_remaining, 1) + " turns remain to boss. (theoretical best: " + theoretical_best_turns_remaining + ")");
			}
		}
		
		
		entry.subentries.listAppend(subentry);
	}
	if (!base_quest_state.state_boolean["niche finished"])
	{
		int evilness = base_quest_state.state_int["niche evilness"];
		ChecklistSubentry subentry;
		subentry.header = "Defiled Niche";
		
		subentry.entries.listAppend(evilness_text["cyrptNicheEvilness"]);
        
        float [monster] appearance_rates = $location[the defiled niche].appearance_rates_adjusted_cancel_nc();
        float evilness_removed_per_adventure = 0.0;
        evilness_removed_per_adventure += 1.0 * appearance_rates[$monster[slick lihc]] / 100.0;
        evilness_removed_per_adventure += 1.0 * appearance_rates[$monster[senile lihc]] / 100.0;
        evilness_removed_per_adventure += 3.0 * appearance_rates[$monster[dirty old lihc]] / 100.0;
        
        float turns_remaining = MAX(0, evilness - 25);
        
        if (evilness_removed_per_adventure != 0.0)
            turns_remaining = MAX(1, turns_remaining / evilness_removed_per_adventure);
        
		if (evilness > 26)
        {
            subentry.modifiers.listAppend("olfaction");
            subentry.modifiers.listAppend("banish");
        }
		if (evilness > 25)
            subentry.entries.listAppend("~" + turns_remaining.roundForOutput(1) + " turns remaining to boss.");
		
		
		entry.subentries.listAppend(subentry);
	}
	if (!base_quest_state.state_boolean["cranny finished"])
	{
		ChecklistSubentry subentry;
		subentry.header = "Defiled Cranny";
		subentry.entries.listAppend(evilness_text["cyrptCrannyEvilness"]);
		
		if (base_quest_state.state_int["cranny evilness"] > 25)
		{
            subentry.modifiers.listAppend("-combat");
            subentry.modifiers.listAppend("+ML");
            float monster_level = monster_level_adjustment_ignoring_plants();
            
            if ($location[the defiled cranny].locationHasPlant("Blustery Puffball"))
                monster_level += 30;
            
            monster_level = MAX(monster_level, 0);
            
			float cranny_beep_beep_beep = MAX(3.0,sqrt(monster_level));
			int beep_boop_lookup = floor(cranny_beep_beep_beep) - 3;
            
            float area_combat_rate = clampNormalf(0.85 + combat_rate_modifier() / 100.0);
            float area_nc_rate = 1.0 - area_combat_rate;
            
            float average_beeps_per_turn = cranny_beep_beep_beep * area_nc_rate + 1.0 * area_combat_rate;
            float average_turns_remaining = ((base_quest_state.state_int["cranny evilness"] - 25) / average_beeps_per_turn);
			
			subentry.entries.listAppend("~" + cranny_beep_beep_beep.roundForOutput(1) + " beeps per ghuol swarm. ~" + average_turns_remaining.roundForOutput(1) + " turns remain to boss.");
		}
        else
            subentry.modifiers.listAppend("+meat");
		
		entry.subentries.listAppend(subentry);
	}
	if (!base_quest_state.state_boolean["alcove finished"])
	{
		ChecklistSubentry subentry;
		int evilness = base_quest_state.state_int["alcove evilness"];
		subentry.header = "Defiled Alcove";
		subentry.entries.listAppend(evilness_text["cyrptAlcoveEvilness"]);
		if (evilness > 26)
		{
            subentry.modifiers.listAppend("+init");
            subentry.modifiers.listAppend("-combat");
			int zmobies_needed = ceil((evilness.to_float() - 25.0) / 5.0);
			float zmobie_chance = min(100.0, 15.0 + initiative_modifier() / 10.0);
			
			subentry.entries.listAppend(pluralize(zmobies_needed, "modern zmobie", "modern zmobies") + " needed (" + roundForOutput(zmobie_chance, 0) + "% chance of appearing)");
            
            if ($familiar[oily woim].familiar_is_usable() && !($familiars[oily woim,happy medium] contains my_familiar()))
                subentry.entries.listAppend("Run " + $familiar[oily woim] + " for +init.");
			
		}
        else if (evilness <= 25)
            subentry.modifiers.listAppend("+meat");
		entry.subentries.listAppend(subentry);
	}
	if (base_quest_state.mafia_internal_step == 2)
	{
		entry.subentries[0].entries.listAppend("Go talk to the council to finish the quest.");
        entry.target_location = "town.php";
	}
	else if (base_quest_state.state_boolean["alcove finished"] && base_quest_state.state_boolean["cranny finished"] && base_quest_state.state_boolean["niche finished"] && base_quest_state.state_boolean["nook finished"])
	{
        float bonerdagon_attack = (90 + monster_level_adjustment());
        
        string line = "Fight bonerdagon!";
        if (my_basestat($stat[moxie]) < bonerdagon_attack)
            line += " (attack: " + bonerdagon_attack.round() + ")";
		entry.subentries[0].entries.listAppend(line);
	}
	task_entries.listAppend(entry);
}
float calculateCurrentNinjaAssassinMaxDamage()
{
    
	//float assassin_ml = 155.0 + monster_level_adjustment();
    float assassin_ml = $monster[ninja snowman assassin].base_attack + 5.0;
	float damage_absorption = raw_damage_absorption();
	float damage_reduction = damage_reduction();
	float moxie = my_buffedstat($stat[moxie]);
	float cold_resistance = numeric_modifier("cold resistance");
	float v = 0.0;
	
	//spaded by yojimboS_LAW
	//also by soirana
    
	float myst_class_extra_cold_resistance = 0.0;
	if (my_class() == $class[pastamancer] || my_class() == $class[sauceror] || my_class() == $class[avatar of jarlsberg])
		myst_class_extra_cold_resistance = 0.05;
	//Direct from the spreadsheet:
	if (cold_resistance < 9)
		v = ((((MAX((assassin_ml - moxie), 0.0) - damage_reduction) + 120.0) * MAX(0.1, MIN((1.1 - sqrt((damage_absorption/1000.0))), 1.0))) * ((1.0 - myst_class_extra_cold_resistance) - ((0.1) * MAX((cold_resistance - 5.0), 0.0))));
	else
		v = ((((MAX((assassin_ml - moxie), 0.0) - damage_reduction) + 120.0) * MAX(0.1, MIN((1.1 - sqrt((damage_absorption/1000.0))), 1.0))) * (0.1 - myst_class_extra_cold_resistance + (0.5 * (powf((5.0/6.0), (cold_resistance - 9.0))))));
	
	return v;
}

string generateNinjaSafetyGuide(boolean show_color)
{
	boolean can_survive = false;
	float init_needed = $monster[ninja snowman assassin].monster_initiative();
	init_needed = monster_initiative($monster[Ninja snowman assassin]);
	
	float damage_taken = calculateCurrentNinjaAssassinMaxDamage();
	
	string result;
	if (initiative_modifier() >= init_needed)
	{
		can_survive = true;
		result += "Keep";
	}
	else
		result += "Need";
	result += " +" + ceil(init_needed) + "% init to survive ninja, or ";
	
	int min_safe_damage = (ceil(damage_taken) + 2);
	if (my_hp() >= min_safe_damage)
	{
		result += "keep";
		can_survive = true;
	}
	else
		result += "need";
	result += " HP above " + min_safe_damage + ".";
    
    if (my_path_id() == PATH_CLASS_ACT_2 && monster_level_adjustment() > 50)
    {
        result += " Reduce ML to +50 to prevent elemental damage.";
        can_survive = false;
    }
	
	if (!can_survive && show_color)
		result = HTMLGenerateSpanFont(result, "red", "");
	return result;
}


void CopiedMonstersGenerateDescriptionForMonster(string monster_name, string [int] description, boolean show_details, boolean from_copy)
{
	if (monster_name == "Ninja snowman assassin")
	{
		description.listAppend(generateNinjaSafetyGuide(show_details));
        if (from_copy && $familiar[obtuse angel].familiar_is_usable() && $familiar[reanimated reanimator].familiar_is_usable())
        {
            string line = "Make sure to copy with angel, not the reanimator.";
            if (my_familiar() == $familiar[reanimated reanimator])
                line = HTMLGenerateSpanFont(line, "red", "");
            description.listAppend(line);
        }
	}
	else if (monster_name == "Quantum Mechanic")
	{
		string line;
		boolean requirements_met = false;
		if (item_drop_modifier() < 150.0)
			line += "Need ";
		else
		{
			line += "Keep ";
			requirements_met = true;
		}
		line += "+150% item for large box";
		if (show_details && !requirements_met)
			line = HTMLGenerateSpanFont(line, "red", "");
		description.listAppend(line);
	}
    else if ($strings[bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner] contains monster_name)
    {
        description.listAppend("Zero adventure cost, use to burn delay.");
    }
    else if (monster_name == "Lobsterfrogman" && show_details)
    {
        int lfm_attack = $monster[lobsterfrogman].base_attack + 5.0;
        string line = lfm_attack + " attack.";
        
		if (my_buffedstat($stat[moxie]) < lfm_attack)
			line = HTMLGenerateSpanFont(line, "red", "");
        description.listAppend(line);
    }
    else if (monster_name == "Big swarm of ghuol whelps" || monster_name == "Swarm of ghuol whelps" || monster_name == "Giant swarm of ghuol whelps")
    {
        float monster_level = monster_level_adjustment_ignoring_plants();
    
        monster_level = MAX(monster_level, 0);
        
        float cranny_beep_beep_beep = MAX(3.0,sqrt(monster_level));
        description.listAppend("~" + cranny_beep_beep_beep.roundForOutput(1) + " cranny beeps.");
    }
}

void generateCopiedMonstersEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
	string [int] description;
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
	if (__misc_state_string["Romantic Monster turn range"] != "" || get_property_int("_romanticFightsLeft") > 0)
	{
		string [int] turn_range_string = split_string_mutable(__misc_state_string["Romantic Monster turn range"], ",");
        
        Vec2i turn_range = Vec2iMake(turn_range_string[0].to_int(), turn_range_string[1].to_int()); //if these are zero, then we're still accurate
        
        title = "Arrowed " + __misc_state_string["Romantic Monster Name"].to_lower_case() + " appears ";
        
        if (turn_range.y <= 0)
            title += "now or soon";
        else if (turn_range.x <= 0)
            title += "between now and " + turn_range.y + " turns.";
        else
            title += "in [" + turn_range_string.listJoinComponents(" to ") + "] turns.";
        
        min_turns_until = turn_range.x;
        
        int fights_left = get_property_int("_romanticFightsLeft");
        if (fights_left > 1)
            description.listAppend(fights_left + " fights left.");
        else if (fights_left == 1)
            description.listAppend("Last fight.");
        
        
        
        
        if (turn_range.x <= 0)
            very_important = true;
	}
	if (from_task && min_turns_until > show_up_in_tasks_turn_cutoff)
		return;
	if (!from_task && min_turns_until <= show_up_in_tasks_turn_cutoff)
		return;
		
	if (title != "")
	{
		CopiedMonstersGenerateDescriptionForMonster(__misc_state_string["Romantic Monster Name"], description, very_important, false);
	}
	
	if (title != "")
	{
		int importance = 4;
		if (very_important)
			importance = -11;
		ChecklistEntry entry = ChecklistEntryMake(__misc_state_string["obtuse angel name"], "", ChecklistSubentryMake(title, "", description), importance);
		if (very_important)
			task_entries.listAppend(entry);
		else
			optional_task_entries.listAppend(entry);
			
	}
}

void SCopiedMonstersGenerateResourceForCopyType(ChecklistEntry [int] available_resources_entries, item shaking_object, string shaking_shorthand_name, string monster_name_property_name)
{
	if (shaking_object.available_amount() == 0)
		return;
    
    string url = "inventory.php?which=3";
	
	string [int] monster_description;
	string monster_name = get_property(monster_name_property_name).HTMLEscapeString();
	CopiedMonstersGenerateDescriptionForMonster(monster_name, monster_description, true, true);
    
    if (get_auto_attack() != 0)
    {
        url = "account.php?tab=combat";
        monster_description.listAppend("Auto attack is on, disable it?");
    }
	
	string line = monster_name.capitalizeFirstLetter() + HTMLGenerateIndentedText(monster_description);
	
	available_resources_entries.listAppend(ChecklistEntryMake(shaking_object, url, ChecklistSubentryMake(shaking_shorthand_name.capitalizeFirstLetter() + " monster trapped!", "", line)));
}

void SCopiedMonstersGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    //Sources:
	int copies_used = get_property_int("spookyPuttyCopiesMade") + get_property_int("_raindohCopiesMade");
	int copies_available = MIN(6,5*MIN($item[spooky putty sheet].available_amount() + $item[Spooky Putty monster].available_amount(), 1) + 5*MIN($item[Rain-Doh black box].available_amount() + $item[rain-doh box full of monster].available_amount(), 1));
    int copies_left = copies_available - copies_used;
	if (copies_left > 0)
	{
		string [int] copy_source_list;
		if ($item[spooky putty sheet].available_amount() + $item[Spooky Putty monster].available_amount() > 0)
        copy_source_list.listAppend("spooky putty");
		if ($item[Rain-Doh black box].available_amount() + $item[rain-doh box full of monster].available_amount() > 0)
        copy_source_list.listAppend("rain-doh black box");
        
		string copy_sources = copy_source_list.listJoinComponents("/");
		string name = "";
		//FIXME make this possibly say which one in the case of 6 (does that matter? how does that mechanic work?)
		name = pluralize(copies_left, copy_sources + " copy", copy_sources + " copies") + " left";
		string [int] description;
        
        //√ghuol whelps, √modern zmobies, √wine racks, √gaudy pirates, √lobsterfrogmen, √ninja assassin
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
            description.listAppend("Lobsterfrogman.");
        if (__quest_state["Level 7"].state_boolean["cranny needs speed tricks"])
            description.listAppend("Swarm of ghuol whelps.");
        if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
            description.listAppend("Modern zmobies.");
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"] && $items[ninja rope,ninja carabiner,ninja crampons].available_amount() == 0 && !have_outfit_components("eXtreme Cold-Weather Gear"))
            description.listAppend("Ninja assassin.");
        if (!__quest_state["Level 11"].finished && !__quest_state["Level 11 Palindome"].finished && $item[talisman o' nam].available_amount() == 0 && $items[gaudy key,snakehead charrrm].available_amount() < 2)
            description.listAppend("Gaudy pirate - copy once for extra key.");
        //√baa'baa. astronomer? √nuns trick brigand
        //FIXME astronomer when we can calculate that
        if (__misc_state["need to level"])
            description.listAppend("Baa'baa'bu'ran - stone wool for cave bar leveling.");
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            description.listAppend("Brigand - nuns trick.");
        if (!__quest_state["Level 11"].finished && __quest_state["Level 11 Manor"].mafia_internal_step < 4)
            description.listAppend("Wine cellar monsters. (copy has all six wines)");
        //possibly less relevant:
        //√ghosts/skulls/bloopers...?
        //seems very marginal
        //if (!__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
            //description.listAppend("Ghosts/morbid skulls/bloopers, for digital key. (marginal?)");
        //bricko bats, if they have bricko...?
        //if (__misc_state["bookshelf accessible"] && $skill[summon brickos].have_skill())
            //description.listAppend("Bricko bats...?");
        
		available_resources_entries.listAppend(ChecklistEntryMake(copy_source_list[0], "", ChecklistSubentryMake(name, "", description)));
	}
    
    if (!get_property_boolean("_cameraUsed") && $item[4-d camera].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item 4-d camera", "", ChecklistSubentryMake("4-d camera copy available", "", "")));
    }
    if (!get_property_boolean("_iceSculptureUsed") && lookupItem("unfinished ice sculpture").available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item unfinished ice sculpture", "", ChecklistSubentryMake("Ice sculpture copy available", "", "")));
    }
    if (my_path_id() == PATH_BUGBEAR_INVASION && $item[crayon shavings].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item crayon shavings", "", ChecklistSubentryMake(pluralize($item[crayon shavings].available_amount(), "crayon shaving copy", "crayon shaving copies") + " available", "", "Bugbears only.")));
    }
    if ($item[sticky clay homunculus].available_amount() > 0)
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item sticky clay homunculus", "", ChecklistSubentryMake(pluralize($item[sticky clay homunculus].available_amount(), "sticky clay copy", "sticky clay copies") + " available", "", "Unlimited/day.")));
    }
    
    //Copies made:


	generateCopiedMonstersEntry(available_resources_entries, available_resources_entries, false);
	SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[Rain-Doh box full of monster], "rain doh", "rainDohMonster");
	SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[spooky putty monster], "spooky putty", "spookyPuttyMonster");
    if (!get_property_boolean("_cameraUsed"))
        SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[shaking 4-d camera], "shaking 4-d camera", "cameraMonster");
	if (!get_property_boolean("_photocopyUsed"))
		SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[photocopied monster], "photocopied", "photocopyMonster");
	if (!get_property_boolean("_envyfishEggUsed"))
		SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[envyfish egg], "envyfish egg", "envyfishMonster");
	if (!get_property_boolean("_iceSculptureUsed"))
		SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, lookupItem("ice sculpture"), "ice sculpture", "iceSculptureMonster");
    
    SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[wax bugbear], "wax bugbear", "waxMonster");
    SCopiedMonstersGenerateResourceForCopyType(available_resources_entries, $item[crude monster sculpture], "crude sculpture", "crudeMonster");
}

void SCopiedMonstersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	generateCopiedMonstersEntry(task_entries, optional_task_entries, true);
	
}

void QLevel8Init()
{
	//questL08Trapper
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL08Trapper");
	state.quest_name = "Trapper Quest";
	state.image_name = "trapper";
	state.council_quest = true;
    
    if (get_property("peteMotorbikeTires") == "Snow Tires" && state.started && !state.finished && state.mafia_internal_step < 4) //sort of hacky - they're not actually there, but...
    {
        state.mafia_internal_step = 4;
    }
    
	
	if (state.mafia_internal_step > 2)
		state.state_boolean["Past mine"] = true;
	if (state.mafia_internal_step > 3)
		state.state_boolean["Mountain climbed"] = true;
	if (state.mafia_internal_step > 5)
		state.state_boolean["Groar defeated"] = true;
	
	state.state_string["ore needed"] = get_property("trapperOre").HTMLEscapeString();
	
	if (my_level() >= 8)
		state.startable = true;
	
	__quest_state["Level 8"] = state;
	__quest_state["Trapper"] = state;
}


void QLevel8GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 8"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 8"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	string talk_to_trapper_string = "Go talk to the trapper.";
    
    float cold_resistance = numeric_modifier("cold resistance");
    string need_cold_res_string = "acquire " + (5.0 - cold_resistance).to_int() + " more " + HTMLGenerateSpanOfClass("cold resistance", "r_element_cold");
	
	if (base_quest_state.mafia_internal_step == 1)
	{
		subentry.entries.listAppend(talk_to_trapper_string);
	}
	else if (!base_quest_state.state_boolean["Past mine"])
	{
		string cheese_header; //string cheese
		string [int] cheese_lines;
		
		cheese_header = MIN(3, $item[goat cheese].available_amount()) + "/3 goat cheese found";
		if ($item[goat cheese].available_amount() <3 )
			cheese_header += " (40% drop)";
		
		boolean need_cheese = $item[goat cheese].available_amount() <3;
		
		if (need_cheese)
		{
			subentry.modifiers.listAppend("150% item");
			if (__misc_state["have olfaction equivalent"])
				subentry.modifiers.listAppend("olfact dairy goats");
			
				
			if (have_skill($skill[Advanced Saucecrafting]))
				cheese_lines.listAppend("Have " + pluralize($item[glass of goat's milk]) + " for magnesium (20% drop)");
		}
		
		subentry.entries.listAppend(cheese_header + HTMLGenerateIndentedText(cheese_lines));
		
		
		
		string ore_header;
		string [int] ore_lines;
		item ore_needed = to_item(base_quest_state.state_string["ore needed"]);
		
		ore_header = MIN(3, ore_needed.available_amount()) + "/3 " + ore_needed + " found";
		
		boolean need_ore = ore_needed.available_amount() <3;
		if (need_ore)
		{
			string [int] potential_ore_sources;
			potential_ore_sources.listAppend("Mining");
			potential_ore_sources.listAppend("Clovering itznotyerzitzmine (one of each ore, consider if zap available?)");
			
			
			
			boolean need_outfit = true;
			if (have_outfit_components("Mining Gear"))
				need_outfit = false;
			if (my_path_id() == PATH_AVATAR_OF_BORIS)
			{
				subentry.modifiers.listAppend("+150%/+1000% item");
				need_outfit = false;
				potential_ore_sources.listClear();
				potential_ore_sources.listAppend("Fight mountain men in the mine (40%, 10% drop for each ore)");
			}
			if (my_path_id() == PATH_WAY_OF_THE_SURPRISING_FIST)
			{
				string have_skill_text = "";
				if (!have_skill($skill[worldpunch]))
					have_skill_text = " (you do not have this skill yet)";
				potential_ore_sources.listAppend("Earthen Fist will allow mining." + have_skill_text);
				need_outfit = false;
			}
			ore_lines.listAppend("Potential sources of ore:" + HTMLGenerateIndentedText(potential_ore_sources));
			if (have_skill($skill[unaccompanied miner]))
				ore_lines.listAppend("You can free mine. Consider splitting mining over several days for zero-adventure cost.");
			if (need_outfit)
			{
				subentry.modifiers.listAppend("-combat");
				ore_lines.listAppend("Mining outfit not available. Consider acquiring one via -combat in mine or the semi-rare (30% drop)");
			}
		
		}
		subentry.entries.listAppend(ore_header + HTMLGenerateIndentedText(ore_lines));
		
		if (!need_cheese && !need_ore)
		{
			subentry.entries.listClear();
			subentry.entries.listAppend(talk_to_trapper_string);
			
		}
	}
	else if (!base_quest_state.state_boolean["Mountain climbed"])
	{
        //ninja:
        string ninja_line;
        boolean ninja_finishes_quest = false;
        if (true)
        {
            string [int] ninja_path;
            string [int] ninja_modifiers;
            
            item [int] items_needed;
            if ($item[ninja rope].available_amount() == 0) items_needed.listAppend($item[ninja rope]);
            if ($item[ninja carabiner].available_amount() == 0) items_needed.listAppend($item[ninja carabiner]);
            if ($item[ninja crampons].available_amount() == 0) items_needed.listAppend($item[ninja crampons]);
            
            if (items_needed.count() == 0)
            {
                if (cold_resistance < 5.0)
                    ninja_path.listAppend(need_cold_res_string.capitalizeFirstLetter() + ".");
                    
                ninja_path.listAppend("Climb the peak.");
                ninja_finishes_quest = true;
            }
            else
            {
                ninja_path.listAppend("Need " + items_needed.listJoinComponents(", ", "and") + ".");
                string [int] assassin_description;
                
                if (get_property_int("_romanticFightsLeft") > 0 && get_property_int("_romanticFightsLeft") >= items_needed.count() && get_property("romanticTarget") == "ninja snowman assassin")
                {
                    ninja_path.listAppend("They will find you.");
                }
                else
                {
                    ninja_modifiers.listAppend("+combat");
                    ninja_path.listAppend("Run +combat in Lair of the Ninja Snowmen, fight assassins.");
                    CopiedMonstersGenerateDescriptionForMonster("ninja snowman assassin", assassin_description, true, false);
                    ninja_path.listAppend(assassin_description.listJoinComponents("|"));
                    if (combat_rate_modifier() < 0.0)
                        ninja_path.listAppend("Need more +combat, assassins won't appear at " + combat_rate_modifier() + "% combat.");
                }
            }
            
            ninja_line = "Ninja path:";
            
            if (ninja_modifiers.count() > 0)
                ninja_line += "|*" + ChecklistGenerateModifierSpan(ninja_modifiers) + "|";
            ninja_line += HTMLGenerateIndentedText(ninja_path.listJoinComponents("<hr>"));
            
            if (ninja_finishes_quest)
                ninja_line = ninja_path.listJoinComponents("<hr>");
        }
        //eXtreme outfit:
        string extreme_line;
        if (true)
        {
            string [int] extreme_path;
            string [int] extreme_modifiers;
            
            
            
            item [int] items_needed = missing_outfit_components("eXtreme Cold-Weather Gear");
        
            if (items_needed.count() == 0)
            {
                if (!is_wearing_outfit("eXtreme Cold-Weather Gear"))
                    extreme_path.listAppend("Wear eXtreme Cold-Weather Gear, run -combat, become eXtreme, jump onto the mountain top.");
                else
                    extreme_path.listAppend("Run -combat, become eXtreme, jump onto the mountain top.");
                extreme_modifiers.listAppend("-combat");
            }
            else
            {
                extreme_path.listAppend("Acquire outfit components: " + items_needed.listJoinComponents(", ", "and") + ".");
                extreme_modifiers.listAppend("-combat");
                extreme_modifiers.listAppend("+item");
                extreme_path.listAppend("Run -combat and maybe +item on the eXtreme slope.");
            }
        
            extreme_line = "Extreme path:";
            
            if (extreme_modifiers.count() > 0)
                extreme_line += "|*" + ChecklistGenerateModifierSpan(extreme_modifiers) + "|";
            extreme_line += HTMLGenerateIndentedText(extreme_path.listJoinComponents("<hr>"));
            
        }
        if (!ninja_finishes_quest)
            subentry.entries.listAppend("Find a way to climb the peak.");
        subentry.entries.listAppend(ninja_line);
        if (!ninja_finishes_quest) //ninja need not tricks
            subentry.entries.listAppend(extreme_line);
	}
	else if (!base_quest_state.state_boolean["Groar defeated"])
	{
        int turns_remaining = MAX(0, 4 - $location[mist-shrouded peak].turnsAttemptedInLocation());
        
        if (get_property("peteMotorbikeTires") == "Snow Tires")
            turns_remaining = 1;
        
		string [int] todo;
		if (cold_resistance < 5.0)
			todo.listAppend(need_cold_res_string);
		todo.listAppend("fight Groar at the peak");
		subentry.entries.listAppend(todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
		
        if (turns_remaining > 1)
        {
            subentry.modifiers.listAppend("+meat");
            subentry.entries.listAppend("Optionally run +meat for " + pluralizeWordy((turns_remaining - 1), "turn", "turns") + ". (200 base meat drop)");
        }
	}
	else
	{
		subentry.entries.listAppend(talk_to_trapper_string);
	}
	
	
	
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "place.php?whichplace=mclargehuge", subentry, $locations[itznotyerzitz mine,the goatlet, lair of the ninja snowmen, the extreme slope,mist-shrouded peak, itznotyerzitz mine (in disguise)]));
}

void QLevel9Init()
{
	//questL09Topping
	//oilPeakProgress
	//twinPeakProgress
	//booPeakProgress
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL09Topping");
	state.quest_name = "Highland Lord Quest";
	state.image_name = "orc chasm";
	state.council_quest = true;
	
    //Recorded in-run:
    //twinPeakProgress(user, now '1', default 0) - +stench one done
    //twinPeakProgress(user, now '3', default 0) - +stench, +item ones done
    //twinPeakProgress(user, now '7', default 0) - +stench, +item, jar ones done
    //twinPeakProgress(user, now '15', default 0) - finished
	//twinPeakProgress(user, now '3', default 0) -> item done, stench done, jar not done, init not done, quest started
	
	if (state.mafia_internal_step > 1)
	{
		state.state_boolean["bridge complete"] = true;
	}
	else
	{
		int bridge_progress = get_property_int("chasmBridgeProgress");
		int fasteners_have = bridge_progress + $item[thick caulk].available_amount() + $item[long hard screw].available_amount() + $item[messy butt joint].available_amount() + 5 * $item[smut orc keepsake box].available_amount() + 5 * lookupItem("snow boards").available_amount();
		int lumber_have = bridge_progress + $item[morningwood plank].available_amount() + $item[raging hardwood plank].available_amount() + $item[weirdwood plank].available_amount() + 5 * $item[smut orc keepsake box].available_amount() + 5 * lookupItem("snow boards").available_amount();
		
		int fasteners_needed = MAX(0, 30 - fasteners_have);
		int lumber_needed = MAX(0, 30 - lumber_have);
		
		state.state_int["bridge fasteners needed"] = fasteners_needed;
		state.state_int["bridge lumber needed"] = lumber_needed;
	}
	
	if (my_level() >= 9)
		state.startable = true;
		
	
	state.state_boolean["can complete twin peaks quest quickly"] = true;
	
	if (my_path_id() == PATH_BEES_HATE_YOU)
		state.state_boolean["can complete twin peaks quest quickly"] = false;
	
	state.state_float["oil peak pressure"] = get_property_float("oilPeakProgress");
	state.state_int["twin peak progress"] = get_property_int("twinPeakProgress");
	state.state_int["a-boo peak hauntedness"] = get_property_int("booPeakProgress");
    
	
	if (!state.state_boolean["bridge complete"]) //haven't gotten over there yet. not sure what mafia says at this point, so set some defaults:
	{
		state.state_int["twin peak progress"] = 0;
		state.state_float["oil peak pressure"] = 310.66;
		state.state_int["a-boo peak hauntedness"] = 100;
	}
	if (state.finished)
	{
		state.state_boolean["bridge complete"] = true;
		
		state.state_int["twin peak progress"] = 15;
		state.state_float["oil peak pressure"] = 0.0;
		state.state_int["a-boo peak hauntedness"] = 0;
	}
    
    if (state.state_float["oil peak pressure"] > 500.0) //not sure what causes this. detecting this situation
    {
        state.state_float["oil peak pressure"] = 310.66;
        state.state_boolean["oil peak pressure bug in effect"] = true;
    }
    
    
    int twin_progress = state.state_int["twin peak progress"];
    
    state.state_boolean["Peak Stench Completed"] = (twin_progress & 1) > 0;
    state.state_boolean["Peak Item Completed"] = (twin_progress & 2) > 0;
    state.state_boolean["Peak Jar Completed"] = (twin_progress & 4) > 0;
    state.state_boolean["Peak Init Completed"] = (twin_progress & 8) > 0;
    
	__quest_state["Level 9"] = state;
	__quest_state["Highland Lord"] = state;
}

void QLevel9GenerateTasksSidequests(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Level 9"];
    
	if (base_quest_state.state_int["a-boo peak hauntedness"] > 0)
	{
		string [int] details;
		string [int] modifiers;
        int clues_needed = ceil(MIN(base_quest_state.state_int["a-boo peak hauntedness"], 90).to_float() / 30.0);
        
        if (true)
        {
            int clues_remaining = MAX(0, clues_needed - $item[a-boo clue].available_amount());
            string [int] tasks;
            if (base_quest_state.state_int["a-boo peak hauntedness"] > 90)
                tasks.listAppend("get down to 90% hauntedness");
            if (clues_remaining > 0)
                tasks.listAppend("collect " + clues_remaining.int_to_wordy() + " a-boo clues");
            tasks.listAppend("use/survive each clue to finish quest.|May want to consider delaying until end of the run");
            details.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        
		modifiers.listAppend("+567% item");
		details.listAppend(base_quest_state.state_int["a-boo peak hauntedness"] + "% hauntedness.");
        
        float item_drop = (100.0 + item_drop_modifier())/100.0;
        if ($location[a-boo peak].locationHasPlant("Rutabeggar") && my_location() != $location[a-boo peak])
        {
            item_drop += 0.25;
        }
        
        if (true)
        {
            string line = "Have " + pluralize($item[a-boo clue]) + ".";
            
            float clue_drop_rate = item_drop * 0.15;
            line += " " + clue_drop_rate.roundForOutput(2) + " clues/adventure at +" + ((item_drop - 1) * 100.0).roundForOutput(1) + "% item.";
            
            details.listAppend(line);
        }
        
        
		if (base_quest_state.state_int["a-boo peak hauntedness"] <= 90 && __misc_state["can use clovers"] && $item[a-boo clue].available_amount() < clues_needed)
        {
            details.listAppend("Can clover for two A-Boo clues.");
        }
        
		
		
        
        int spooky_damage_taken_cumulative = 0;
        int cold_damage_taken_cumulative = 0;
        
        int [int] spooky_damage_levels;
        int [int] cold_damage_levels;
        
        int [int] damage_levels = listMake(13, 25, 50, 125, 250);
        
        foreach key in damage_levels
        {
            int damage = damage_levels[key];
            
            int spooky_damage_at_level = damageTakenByElement(damage, $element[spooky]);
            int cold_damage_at_level = damageTakenByElement(damage, $element[cold]);
            
            spooky_damage_taken_cumulative += spooky_damage_at_level;
            cold_damage_taken_cumulative += cold_damage_at_level;
            
            spooky_damage_levels.listAppend(spooky_damage_taken_cumulative);
            cold_damage_levels.listAppend(cold_damage_taken_cumulative);
        }
        
        if (true)
        {
            string line;
        
            int hp_damage_taken = spooky_damage_levels[4] + cold_damage_levels[4] + 2;
            string hp_string = hp_damage_taken + " HP";
            if (hp_damage_taken >= my_hp())
                hp_string = HTMLGenerateSpanFont(hp_string, "red", "");
            
            line = "Need " + hp_string + " (" + HTMLGenerateSpanOfClass(spooky_damage_levels[4] + " spooky", "r_element_spooky") + ", " + HTMLGenerateSpanOfClass(cold_damage_levels[4] + " cold", "r_element_cold") + ") to survive 30% effective A-Boo clues.";
            if (hp_damage_taken >= my_hp())
            {
                hp_damage_taken = spooky_damage_levels[3] + cold_damage_levels[3] + 2;
                string hp_string = hp_damage_taken + " HP";
                if (hp_damage_taken >= my_hp())
                    hp_string = HTMLGenerateSpanFont(hp_string, "red", "");
                
                line += "|Or ";
                line += hp_string;
                line += " to survive 22% effectiveness clues.";
            }
            
            details.listAppend(line);
        }
        
        if (!black_market_available() && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
        {
            details.listAppend("Possibly unlock the black market first, for cans of black paint. (+2 " + HTMLGenerateSpanOfClass("spooky", "r_element_spooky") + "/" + HTMLGenerateSpanOfClass("cold", "r_element_cold") + " res buff, 1k meat)");
        }
		
		task_entries.listAppend(ChecklistEntryMake("a-boo peak", "place.php?whichplace=highlands", ChecklistSubentryMake("A-Boo Peak", modifiers, details), $locations[a-boo peak]));
	}
	if (base_quest_state.state_int["twin peak progress"] < 15)
	{
		string [int] details;
		string [int] modifiers;
		
		if (base_quest_state.state_boolean["can complete twin peaks quest quickly"])
		{
            int progress = base_quest_state.state_int["twin peak progress"];
            
            boolean stench_completed = base_quest_state.state_boolean["Peak Stench Completed"];
            boolean item_completed = base_quest_state.state_boolean["Peak Item Completed"];
            boolean jar_completed = base_quest_state.state_boolean["Peak Jar Completed"];
            boolean init_completed = base_quest_state.state_boolean["Peak Init Completed"];
            
			modifiers.listAppend("-combat");
            modifiers.listAppend("+item");
            
            string [int] options_left;
            
            if (!stench_completed)
                options_left.listAppend("investigate room 37");
            if (!item_completed)
                options_left.listAppend("search the pantry");
            if (!jar_completed)
                options_left.listAppend("follow the faint sound of music");
            if (!init_completed)
                options_left.listAppend("you");
            
            details.listAppend(options_left.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".");
            
			if ($item[rusty hedge trimmers].available_amount() > 0)
            {
                if ($item[rusty hedge trimmers].available_amount() > 1)
                    details.listAppend("Use " + $item[rusty hedge trimmers].pluralize() + ".");
                else
                    details.listAppend("Use rusty hedge trimmers.");
            }
			if (numeric_modifier("stench resistance") < 4.0 && !stench_completed)
            {
				details.listAppend("+" + (4.0 - numeric_modifier("stench resistance")).floor() + " more " + HTMLGenerateSpanOfClass("stench", "r_element_stench") + " resist required.");
            }
            
				
            if (!item_completed)
            {
                //don't know an easy way to test for non-familiar +item
                details.listAppend("+50% non-familiar item required.");
            }
			
			if ($item[jar of oil].available_amount() == 0 && !jar_completed)
            {
                string line = HTMLGenerateSpanFont("Jar of oil required", "red", "") + ".";
                if ($item[bubblin' crude].available_amount() >= 12)
                    line += " Can make by multi-using 12 bubblin' crude.";
                else
                    line += " Visit oil peak for bubblin' crude.";
				details.listAppend(line);
            }
			if (initiative_modifier() < 40.0 && !init_completed)
            {
                string line = "+40% init required.";
                if (options_left.count() > 1)
                    line = "+40% init will be required later.";
                if ($familiar[oily woim].familiar_is_usable() && !($familiars[oily woim,happy medium] contains my_familiar()))
                    line += "|Run " + $familiar[oily woim] + " for +init.";
				details.listAppend(line);
            }
            
            int ncs_need_to_visit_by_hand = MAX(0, options_left.count() - $item[rusty hedge trimmers].available_amount());
            int ncs_need_to_visit_with_hedge = options_left.count() - ncs_need_to_visit_by_hand;
            details.listAppend(generateTurnsToSeeNoncombat(80, ncs_need_to_visit_by_hand, "", 0, ncs_need_to_visit_with_hedge));
            
            
		}
		else
		{
			details.listAppend("Spend 50 total turns in the twin peak.");
		}
		task_entries.listAppend(ChecklistEntryMake("twin peak", "place.php?whichplace=highlands", ChecklistSubentryMake("Twin Peak", modifiers, details), $locations[twin peak]));
	}
    boolean need_jar_of_oil = false;
    if ($item[jar of oil].available_amount() == 0 && $item[bubblin' crude].available_amount() < 12 && !base_quest_state.state_boolean["Peak Jar Completed"] && base_quest_state.state_boolean["can complete twin peaks quest quickly"])
        need_jar_of_oil = true;
        
	if (base_quest_state.state_float["oil peak pressure"] > 0.0 || need_jar_of_oil)
	{
		string [int] details;
		string [int] modifiers;
        
        int oil_ml = monster_level_adjustment_ignoring_plants();
        if ($location[oil peak].locationHasPlant("Rabid Dogwood"))
            oil_ml += 30;
        
        int turns_remaining_at_current_ml = 0;
        if (base_quest_state.state_float["oil peak pressure"] > 0.0)
        {
            modifiers.listAppend("+100 ML");
            
            
            string line = "Run +" + HTMLGenerateSpanFont("20/50", "", "0.8em") + "/100 ML (at ";
            string adjustment = "+" + oil_ml + " ML";
            if (oil_ml < 100)
                adjustment = HTMLGenerateSpanFont(adjustment, "red", "");
            adjustment += ")";
            details.listAppend(line + adjustment);
            
            
            float pressure_reduced_per_turn = 0.0;
            if ($item[dress pants].available_amount() > 0)
            {
                if ($item[dress pants].equipped_amount() > 0)
                {
                    pressure_reduced_per_turn += 6.34;
                }
                else
                {
                    if (oil_ml < 100) //only worth it <100 usually
                        details.listAppend("Wear dress pants.");
                }
            }
            if (oil_ml >= 100)
                pressure_reduced_per_turn += 63.4;
            else if (oil_ml >= 50)
                pressure_reduced_per_turn += 31.7;
            else if (oil_ml >= 20)
                pressure_reduced_per_turn += 19.02;
            else
                pressure_reduced_per_turn += 6.34;
                
            if (fabs(pressure_reduced_per_turn) > 0.01)
                turns_remaining_at_current_ml = ceil(base_quest_state.state_float["oil peak pressure"] / pressure_reduced_per_turn);
            
            string line2 = pluralize(turns_remaining_at_current_ml, "turn", "turns") + " remaining at " + oil_ml + " ML.";
            if (base_quest_state.state_boolean["oil peak pressure bug in effect"])
                line2 = "At most " + line2 + " (unable to track, sorry)";
            details.listAppend(line2);
        }
		if (need_jar_of_oil)
		{
			modifiers.listAppend("+item");
            string item_drop_string = "";
            int [int] drop_rates;
            if (oil_ml >= 100)
            {
                //last is possibly 10%, needs more spading
                item_drop_string = "100%/30%/10% drops";
                drop_rates = listMake(100, 30, 10);
            }
            else if (oil_ml >= 50)
            {
                item_drop_string = "100%/30% drops";
                drop_rates = listMake(100, 30);
            }
            else if (oil_ml >= 20)
            {
                item_drop_string = "100%/10% drops";
                drop_rates = listMake(100, 10);
            }
            else
            {
                item_drop_string = "100% drop";
                drop_rates = listMake(100);
            }
            
            float crudes_per_adventure = 0.0;
            float item_drop_rate_multiplier = (100.0 + item_drop_modifier()) / 100.0;
            foreach key in drop_rates
            {
                int rate = drop_rates[key];
                float effective_rate = MIN(1.0, rate.to_float() / 100.0 * item_drop_rate_multiplier);
                crudes_per_adventure += effective_rate;
            }
            string crude_string = "~" + crudes_per_adventure.roundForOutput(1) + " crude/adventure.";
            if (turns_remaining_at_current_ml > 0)
                crude_string += " ~" + (crudes_per_adventure * turns_remaining_at_current_ml.to_float()).roundForOutput(1) + " crudes before fire lit.";
            
            
            if ($item[bubblin' crude].available_amount() < 12)
            {
                details.listAppend("Run +item to acquire 12 bubblin' crude. (" + item_drop_string + ")|" + crude_string);
                details.listAppend("Need " + pluralize(MAX(0, 12 - $item[bubblin' crude].available_amount()), "more bubblin' crude", "more bubblin' crudes") + ".");
                if ($item[duskwalker syringe].available_amount() > 0)
                    details.listAppend("Use " + $item[duskwalker syringe].pluralize() + " in-combat for more crude.");
            }
		}
		
		task_entries.listAppend(ChecklistEntryMake("oil peak", "place.php?whichplace=highlands", ChecklistSubentryMake("Oil Peak", modifiers, details), $locations[oil peak]));
	}
}

void QLevel9GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 9"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 9"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
    string url = "place.php?whichplace=highlands";
	int tasks_before = task_entries.count() + optional_task_entries.count() + future_task_entries.count();
	
	if (base_quest_state.mafia_internal_step == 1)
    {
        url = "place.php?whichplace=orc_chasm";
		//build bridge:
		subentry.modifiers.listAppend("+item");
        if (__misc_state["have olfaction equivalent"])
            subentry.modifiers.listAppend("olfaction");
		subentry.entries.listAppend("Build a bridge.");
        
        if (get_property_int("chasmBridgeProgress") < 12)
        {
            if ($item[bridge].available_amount() > 0)
                subentry.entries.listAppend("Place the bridge.");
            else if ($item[abridged dictionary].available_amount() > 0)
                subentry.entries.listAppend("Untinker the abridged dictionary.");
            else
                subentry.entries.listAppend("Acquire an abridged dictionary from the pirates, untinker it.");
        }
		int fasteners_needed = base_quest_state.state_int["bridge fasteners needed"];
		int lumber_needed = base_quest_state.state_int["bridge lumber needed"];
		
		if (__misc_state["can equip just about any weapon"])
		{
            if (lumber_needed > 0)
            {
                if ($item[logging hatchet].available_amount() > 0 && $item[logging hatchet].equipped_amount() == 0)
                    subentry.entries.listAppend("Possibly equip that logging hatchet.");
                else if ($item[logging hatchet].available_amount() == 0 && canadia_available())
                    subentry.entries.listAppend("Possibly acquire a logging hatchet. (first adventure in Camp Logging Camp in Little Canadia)");
            }
			
            if (fasteners_needed > 0)
            {
                if ($item[loadstone].available_amount() > 0 && $item[loadstone].equipped_amount() == 0)
                    subentry.entries.listAppend("Possibly equip that loadstone.");
                else if ($item[loadstone].available_amount() == 0 && !__quest_state["Level 8"].state_boolean["Past mine"])
                    subentry.entries.listAppend("Possibly find a loadstone in the mine.");
            }
		}
		
        if ((lookupItem("snow berries").available_amount() > 0 || lookupItem("ice harvest").available_amount() > 0) && lookupItem("snow boards").available_amount() < 4)
			subentry.entries.listAppend("Possibly make snow boards.");
        if (__misc_state["can use clovers"])
			subentry.entries.listAppend("Possibly clover for 3 lumber and 3 fasteners.");

		
		string [int] line;
		if (fasteners_needed > 0)
			line.listAppend(fasteners_needed + " fasteners");
		if (lumber_needed > 0)
			line.listAppend(lumber_needed + " lumber");
            
        if (lumber_needed + fasteners_needed == 0)
        {
            //finished
            subentry.modifiers.listClear();
            subentry.entries.listClear();
            subentry.entries.listAppend("Build a bridge!");
        }
		if ($item[smut orc keepsake box].available_amount() > 0)
			subentry.entries.listAppend("Open " + pluralize($item[smut orc keepsake box]) + ".");
		if (line.count() > 0)
			subentry.entries.listAppend("Need " + line.listJoinComponents(" ", "and") + ".");
	}
	/*else if (base_quest_state.mafia_internal_step == 2)
	{
		//bridge built, talk to angus:
		subentry.entries.listAppend("Talk to Angus in the Highland Lord's tower.");
	}*/
	else if (base_quest_state.mafia_internal_step == 2 || base_quest_state.mafia_internal_step == 3)
	{
		//do three peaks:
		subentry.entries.listAppend("Light the fires!");
		QLevel9GenerateTasksSidequests(task_entries, optional_task_entries, future_task_entries);
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
		//fires lit, talk to angus again:
		subentry.entries.listAppend("Talk to Angus in the Highland Lord's tower.");
	}
	int tasks_after = task_entries.count() + optional_task_entries.count() + future_task_entries.count();
	if (tasks_before == tasks_after) //if our sidequests didn't add anything, show something:
		task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the smut orc logging camp]));
}

void QLevel10Init()
{
	//questL10Garbage
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL10Garbage");
	state.quest_name = "Castle Quest";
	state.image_name = "castle";
	state.council_quest = true;
    
    
    boolean beanstalk_grown = false;
    if ($items[Model airship,Plastic Wrap Immateria,Gauze Immateria,Tin Foil Immateria,Tissue Paper Immateria,S.O.C.K.].available_amount() > 0)
        beanstalk_grown = true;
    if (state.finished)
        beanstalk_grown = true;
    if ($location[the penultimate fantasy airship].turnsAttemptedInLocation() > 0)
        beanstalk_grown = true;
    
    state.state_boolean["Beanstalk grown"] = beanstalk_grown;
	
	
	if (my_level() >= 10)
		state.startable = true;
    
	__quest_state["Level 10"] = state;
	__quest_state["Castle"] = state;
}


void QLevel10GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 10"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 10"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	string image_name = base_quest_state.image_name;
    string url = "place.php?whichplace=beanstalk";
	
	if ($item[s.o.c.k.].available_amount() == 0)
	{
        //FIXME delay if ballroom song not set
        if (!base_quest_state.state_boolean["Beanstalk grown"])
        {
            subentry.entries.listAppend("Grow the beanstalk.");
            url = "place.php?whichplace=plains";
        }
		//FIXME check if enchanted bean used
		subentry.modifiers.listAppend("-combat");
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
		
		string [int] things_we_want_item_for;
        
        if ($skill[Transcendent Olfaction].have_skill())
            things_we_want_item_for.listAppend("SGEEA");
		
		image_name = "penultimate fantasy airship";
		
		//immateria:
		
		item [int] immaterias_missing = $items[Tissue Paper Immateria,Tin Foil Immateria,Gauze Immateria,Plastic Wrap Immateria].items_missing();
		if (immaterias_missing.count() == 0)
			subentry.entries.listAppend("Immateria found, find Cid (-combat)");
		else
		{
			subentry.entries.listAppend("Find the immateria (-combat): " + listJoinComponents(immaterias_missing, ", ", "and"));
		}
		
		
        //FIXME it would be nice to track this
		subentry.entries.listAppend("25 total turns of delay.");
		if ($skill[Transcendent Olfaction].have_skill() && !($effect[on the trail].have_effect() > 0 && get_property("olfactedMonster") == "Quiet Healer"))
			subentry.entries.listAppend("Potentially olfact quiet healer for SGEEAs");
		
		if ($item[model airship].available_amount() == 0)
			subentry.entries.listAppend("Acquire model airship from non-combat. (speeds up quest)");
		if ($item[amulet of extreme plot significance].available_amount() == 0)
		{
			things_we_want_item_for.listAppend("amulet of extreme plot significance");
			subentry.entries.listAppend("Acquire amulet of extreme plot significance (quiet healer, 10% drop) to speed up opening ground floor.");
		}
		if ($item[mohawk wig].available_amount() == 0)
		{
			things_we_want_item_for.listAppend("Mohawk wig");
			subentry.entries.listAppend("Acquire mohawk wig (Burly Sidekick, 10% drop) to speed up top floor.");
		}
        if (things_we_want_item_for.count() > 0)
        {
            subentry.modifiers.listAppend("+item");
            subentry.entries.listAppend("Potentially run +item for " + listJoinComponents(things_we_want_item_for, ", ", "and") + ".");
        }
	}
	else
	{
        url = "place.php?whichplace=giantcastle";
        if (get_property("lastEncounter") == "Keep On Turnin' the Wheel in the Sky")
        {
            url = "town.php";
            subentry.entries.listAppend("Talk to the council to finish quest.");
        }
		else if ($location[The Castle in the Clouds in the Sky (Top floor)].locationAvailable())
		{
            float turn_estimation = -1.0;
            float non_combat_rate = 1.0 - (0.95 + combat_rate_modifier() / 100.0);
            if (non_combat_rate < 0.11111111111111) //every nine adventures, minimum
                non_combat_rate = 0.11111111111111;
            
            //FIXME turn estimation for all routes, not just mohawk wig/model airship
            
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Top floor. Run -combat.");
            if ($item[mohawk wig].equipped_amount() == 0 && $item[mohawk wig].available_amount() > 0)
                subentry.entries.listAppend(HTMLGenerateSpanFont("Wear your mohawk wig.", "red", ""));
            if ($item[mohawk wig].available_amount() == 0 && !in_hardcore())
                subentry.entries.listAppend("Potentially pull and wear a mohawk wig.");
            if ($item[model airship].available_amount() == 0)
            {
                if ($item[mohawk wig].available_amount() == 0) //no wig, no airship
                    subentry.entries.listAppend("Backfarm for a model airship in the fantasy airship. (non-combat option, run -combat)");
                else
                    subentry.entries.listAppend("Potentially backfarm for a model airship in the fantasy airship. (non-combat option, run -combat)"); //always suggest this - backfarming for model airship is faster than spending time in top floor, I think
            }
            
            if ($item[mohawk wig].available_amount() > 0 && $item[model airship].available_amount() > 0)
            {
                if (non_combat_rate != 0.0)
                    turn_estimation = 1.0 / non_combat_rate;
            }
            
            //We don't suggest trying to complete this quest with the record, even if they lack the mohawk wig/model airship - I feel as though that would take quite a number of turns?
            //It's a 95% combat location (max nine/ten turns between non-combats), and the non-combats are split between two different sets.
            //There might be some internal mechanics to make it faster? Don't know.
			image_name = "goggles? yes!";
            
            if (turn_estimation != -1.0)
                subentry.entries.listAppend("~" + turn_estimation.roundForOutput(1) + " turns left on average.");
		}
		else if ($location[The Castle in the Clouds in the Sky (Ground floor)].locationAvailable())
		{
			subentry.entries.listAppend("Ground floor. Spend eleven turns here to unlock top floor.");
			image_name = "castle stairs up";
            
            if (__misc_state["Need to level"])
                subentry.entries.listAppend("Possibly acquire the very overdue library book from a non-combat. (stats)");
            
            if (true)
            {
                if (__misc_state["have hipster"])
                {
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                }
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
		}
		else
		{
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Basement. Run -combat.");
            
            float turn_estimation = -1.0;
            float non_combat_rate = 1.0 - (0.95 + combat_rate_modifier() / 100.0);
            if (non_combat_rate < 0.11111111111111) //every nine adventures, minimum
                non_combat_rate = 0.11111111111111;
            if ($item[amulet of extreme plot significance].available_amount() > 0)
            {
                if ($item[amulet of extreme plot significance].equipped_amount() == 0)
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Wear the amulet of extreme plot significance.", "red", ""));
                
                if (non_combat_rate != 0.0)
                    turn_estimation = 1.0 / non_combat_rate;
                
                    
            }
            else
            {
                boolean have_usable_umbrella = (__misc_state["can equip just about any weapon"] && $item[titanium assault umbrella].available_amount() > 0);
                
                if (have_usable_umbrella && $item[titanium assault umbrella].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip your titanium assault umbrella.");
                if ($item[massive dumbbell].available_amount() == 0)
                {
                    if (have_usable_umbrella)
                    {
                        subentry.entries.listAppend("Grab the massive dumbbell from gym if you can't reach the ground floor otherwise.");
                        
                        if (non_combat_rate != 0.0)
                            turn_estimation = (2.0 / 3.0) * (2.0 / non_combat_rate) + (1.0 / 3.0) * (1.0 / non_combat_rate); //1/3rd chance of instant completion with umbrella
                    }
                    else
                    {
                        subentry.entries.listAppend("Grab the massive dumbbell from gym.");
                        if (non_combat_rate != 0.0)
                            turn_estimation = 2.0 / non_combat_rate;
                    }
                    
                }
                else
                {
                    subentry.entries.listAppend("Place the massive dumbbell in the Open Source dumbwaiter.");
                    if (non_combat_rate != 0.0)
                        turn_estimation = 1.0 / non_combat_rate;
                }
            }
            
            if (turn_estimation != -1.0)
                subentry.entries.listAppend("~" + turn_estimation.roundForOutput(1) + " turns left on average.");
			
			image_name = "lift, bro";
		}
	}
	
	task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the penultimate fantasy airship, the castle in the clouds in the sky (basement), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (top floor)]));
}
void QLevel11Init()
{
	//questL11MacGuffin, questL11Manor, questL11Palindome, questL11Pyramid, questL11Worship
	//hiddenApartmentProgress, hiddenBowlingAlleyProgress, hiddenHospitalProgress, hiddenOfficeProgress, hiddenTavernUnlock
	//relocatePygmyJanitor, relocatePygmyLawyer
	
	
	/*
	gnasirProgress is a bitmap of things you've done with Gnasir to advance desert exploration:

	stone rose = 1
	black paint = 2
	killing jar = 4
	worm-riding manual pages (15) = 8
	successful wormride = 16
	*/
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11MacGuffin");
		state.quest_name = "MacGuffin Quest";
		state.image_name = "MacGuffin";
		state.council_quest = true;
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11"] = state;
		__quest_state["MacGuffin"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Manor");
		state.quest_name = "Lord Spookyraven Quest";
		state.image_name = "Spookyraven manor";
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Manor"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Palindome");
		state.quest_name = "Palindome Quest";
		state.image_name = "Palindome";
        
        state.state_boolean["Need instant camera"] = false; //FIXME track this
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Palindome"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Pyramid");
		state.quest_name = "Pyramid Quest";
		state.image_name = "Pyramid";
		
		int gnasir_progress = get_property_int("gnasirProgress");
		
		state.state_boolean["Stone Rose Given"] = (gnasir_progress & 1) > 0;
		state.state_boolean["Black Paint Given"] = (gnasir_progress & 2) > 0;
		state.state_boolean["Killing Jar Given"] = (gnasir_progress & 4) > 0;
		state.state_boolean["Manual Pages Given"] = (gnasir_progress & 8) > 0;
		state.state_boolean["Wormridden"] = (gnasir_progress & 16) > 0;
		
		state.state_int["Desert Exploration"] = get_property_int("desertExploration");
		state.state_boolean["Desert Explored"] = (state.state_int["Desert Exploration"] == 100);
        if (state.finished) //in case mafia doesn't detect it properly
        {
            state.state_int["Desert Exploration"] = 100;
            state.state_boolean["Desert Explored"] = true;
        }
        
        
        boolean have_uv_compass_equipped = false;
        
        if (!__misc_state["can equip just about any weapon"])
            have_uv_compass_equipped = true;
        if ($item[UV-resistant compass].equipped_amount() > 0)
            have_uv_compass_equipped = true;
        if (lookupItem("ornate dowsing rod").equipped_amount() > 0)
            have_uv_compass_equipped = true;
        
        state.state_boolean["Have UV-Compass eqipped"] = have_uv_compass_equipped;
	
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Pyramid"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Worship");
		state.quest_name = "Hidden City Quest";
		state.image_name = "Hidden City";
        
        state.state_boolean["Hospital finished"] = (get_property_int("hiddenHospitalProgress") >= 8);
        state.state_boolean["Bowling alley finished"] = (get_property_int("hiddenBowlingAlleyProgress") >= 8);
        state.state_boolean["Apartment finished"] = (get_property_int("hiddenApartmentProgress") >= 8);
        state.state_boolean["Office finished"] = (get_property_int("hiddenOfficeProgress") >= 8);
        
        if (state.finished) //backup
        {
            state.state_boolean["Hospital finished"] = true;
            state.state_boolean["Bowling alley finished"] = true;
            state.state_boolean["Apartment finished"] = true;
            state.state_boolean["Office finished"] = true;
        }
        
		if (my_level() >= 11)
			state.startable = true;
		__quest_state["Level 11 Hidden City"] = state;
	}

	
	//hidden temple unlock:
	if (true)
	{
		QuestState state;
		
		if (get_property_int("lastTempleUnlock") == my_ascensions())
			QuestStateParseMafiaQuestPropertyValue(state, "finished");
		else if (__quest_state["Level 2"].startable)
        {
			QuestStateParseMafiaQuestPropertyValue(state, "started");
        }
		else
			QuestStateParseMafiaQuestPropertyValue(state, "unstarted");
		state.quest_name = "Hidden Temple Unlock";
		state.image_name = "spooky forest";
		
		__quest_state["Hidden Temple Unlock"] = state;
	}
}

void QLevel11BaseGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11"].in_progress)
        return;

    QuestState base_quest_state = __quest_state["Level 11"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";
    boolean make_entry_future = false;
    if (base_quest_state.mafia_internal_step < 2)
    {
        //Unlock black market:
        url = "place.php?whichplace=woods";
        if ($item[black market map].available_amount() > 0)
            subentry.entries.listAppend("Unlock the black market.");
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Unlock the black market by adventuring in the Black Forest with -combat.");
            if (__misc_state_string["ballroom song"] != "-combat")
            {
                subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
                make_entry_future = true;
            }
        }
        
        
        familiar bird_needed_familiar;
        item bird_needed;
        if (my_path_id() == PATH_BEES_HATE_YOU)
        {
            bird_needed_familiar = $familiar[reconstituted crow];
            bird_needed = $item[reconstituted crow];
        }
        else
        {
            bird_needed_familiar = $familiar[reassembled blackbird];
            bird_needed = $item[reassembled blackbird];
        }
        if (!have_familiar_replacement(bird_needed_familiar) && bird_needed.available_amount() == 0)
        {
            string line = "";
            line = "Acquire " + bird_needed + ".";
            item [int] missing_components = missingComponentsToMakeItem(bird_needed);
        
            if (missing_components.count() == 0)
                line += " You have all the parts, make it.";
            else
                line += " Parts needed: " + missing_components.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
            subentry.modifiers.listAppend("+100% item"); //FIXME what is the drop rate for bees hate you items? we don't know...
        }
        else
        {
            if ($item[black market map].available_amount() > 0)
            {
                url = "inventory.php?which=3";
                subentry.entries.listAppend("Use the black market map.");
            }
            
        }
    }
    else if (base_quest_state.mafia_internal_step < 3)
    {
        //Vacation:
        if ($item[forged identification documents].available_amount() == 0)
        {
            url = "shop.php?whichshop=blackmarket";
            subentry.entries.listAppend("Buy forged identification documents from the black market.");
            if ($item[can of black paint].available_amount() == 0)
                subentry.entries.listAppend("Also buy a can of black paint while you're there, for the desert quest.");
        }
        else
        {
            url = "place.php?whichplace=desertbeach";
            subentry.entries.listAppend("Vacation at the shore, read diary.");
        }
    }
    else if (base_quest_state.mafia_internal_step < 4)
    {
        //Have diary:
        if ($item[holy macguffin].available_amount() == 0)
        {
            //nothing to say
            //subentry.entries.listAppend("Retrieve the MacGuffin.");
            return;
        }
        else
        {
            url = "town.php";
            subentry.entries.listAppend("Speak to the council.");
        }
    }
    if (make_entry_future)
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the black forest]));
    else
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the black forest]));
}

void QLevel11ManorGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Manor"].in_progress)
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Manor"];
    ChecklistSubentry subentry;
    string url = "";
    subentry.header = base_quest_state.quest_name;
    string image_name = base_quest_state.image_name;
    if ($item[lord spookyraven's spectacles].available_amount() == 0)
    {
        subentry.entries.listAppend("Find lord spookyraven's spectacles in the haunted bedroom.");
        url = "place.php?whichplace=town_right";
        if ($location[the haunted bedroom].locationAvailable())
            url = "place.php?whichplace=spookyraven2";
    }
    else if (!locationAvailable($location[the haunted ballroom]))
    {
        subentry.entries.listAppend("Unlock the haunted ballroom.");
        url = "place.php?whichplace=spookyraven2";
    }
    else if (base_quest_state.mafia_internal_step < 2)
    {
        url = "place.php?whichplace=spookyraven2";
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Run -combat in the haunted ballroom.");
        
        if (delayRemainingInLocation($location[the haunted ballroom]) > 0)
        {
            string line = "Delay for ~" + pluralize(delayRemainingInLocation($location[the haunted ballroom]), "turn", "turns");
            if (__misc_state["have hipster"])
            {
                subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                line += ", use " + __misc_state_string["hipster name"];
            }
            line += ". (not tracked properly, sorry)";
            subentry.entries.listAppend(line);
        }
        image_name = "Haunted Ballroom";
    }
    else if (base_quest_state.mafia_internal_step < 3)
    {
        url = "manor3.php";
        subentry.modifiers.listAppend("+400% item");
        subentry.entries.listAppend("Collect wine.");
        if ($items[spooky putty sheet,Rain-Doh black box].available_amount() > 0)
            subentry.entries.listAppend("Possibly copy the monsters here. The copy will have all six wines.");
        image_name = "Wine racks";
    }
    else
    {
        url = "manor3.php";
        subentry.modifiers.listAppend("elemental resistance");
        subentry.entries.listAppend("Fight Lord Spookyraven.");
        image_name = "demon summon";
    }

    task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the haunted ballroom, the haunted wine cellar (northwest), the haunted wine cellar (northeast), the haunted wine cellar (southwest), the haunted wine cellar (southeast), summoning chamber]));
}

void QLevel11PalindomeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Palindome"].in_progress)
        return;
    //Some emergency exits in case the revamp doesn't detect properly: (not sure yet)
    if (__quest_state["Level 11"].finished) //emergency tracking
        return;
    if ($items[staff of fats,Staff of Ed\, almost,Staff of Ed].available_amount() > 0)
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Palindome"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url;
    
    if (base_quest_state.mafia_internal_step == 1 && $item[talisman o' nam].available_amount() == 0)
    {
        //1 -> find palindome
        url = "place.php?whichplace=cove";
        subentry.entries.listAppend("Find the palindome. The pirates will know the way.");
        
        if ($location[the poop deck].noncombat_queue.contains_text("It's Always Swordfish"))
        {
            subentry.modifiers.listAppend("olfact gaudy pirate");
            string line = "Olfact/copy gaudy pirate belowdecks";
            if (!__quest_state["Level 13"].state_boolean["have relevant guitar"])
            {
                line += ", and possibly run +400% item to find a guitar";
                subentry.modifiers.listAppend("+400% item");
            }
            line += ".";
            subentry.entries.listAppend(line);
            if ($item[gaudy key].available_amount() > 0)
                subentry.entries.listAppend("Use " + $item[gaudy key].pluralize() + ".");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat to unlock belowdecks.");
            subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 1, "unlock belowdecks"));
        }
            
    }
    else
    {
        url = "place.php?whichplace=palindome";
        if ($item[talisman o' nam].equipped_amount() == 0)
            url = "inventory.php?which=2";
        
        
        /*
        Quest steps:
        Adventure in palindome, acquire:
            photograph of a dog (7263) by taking a picture of one of the racecar twins(?) with a disposable instant camera
            photograph of an ostrich egg (7265)
            photograph of a red nugget (7264)
            photograph of god
            stunt nuts for wet stunt nut stew
            "I Love Me, Vol. I" (7262) (dropped from monster, possibly drab bard?, possibly after rest are available?)
         Use I love me, volume 1. This removes it from your inventory, and unlocks the office.
         Arrange the photographs on the shelf:
            god, red nugget, dog, ostrich egg
        This gives 2 Love Me, Vol. 2 (7270)
        Read it to unlock mr. alarm in left office. It will disappear.
        He'll tell you to go acquire wet stunt nut stew. Adventure in whitey's grove as per usual.
        Cook wet stunt nut stew.
        Go talk to mr. alarm. He'll give a mega gem.
        Go fight Dr. Awkward with both equipped.
        
        */
        
        //I think we need mafia tracking before interactive mode can work?
        if ($item[mega gem].available_amount() > 0)
        {
            //5 -> fight dr. awkward
            string [int] tasks;
            if ($item[talisman o' nam].equipped_amount() == 0)
                tasks.listAppend("equip the Talisman o' Nam");
            if ($item[mega gem].equipped_amount() == 0)
                tasks.listAppend("equip the Mega Gem");
            
            tasks.listAppend("fight Dr. Awkward");
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        else if (false)
        {
            //acquire wet stunt nut stew, give to mr. alarm
            //FIXME handle alternate route
            
            //4 -> acquire wet stunt nut stew, give to mr. alarm
            if ($item[wet stunt nut stew].available_amount() == 0)
            {
                url = "place.php?whichplace=woods";
                if (($item[bird rib].available_amount() > 0 && $item[lion oil].available_amount() > 0 || $item[wet stew].available_amount() > 0) && $item[stunt nuts].available_amount() > 0)
                    subentry.entries.listAppend("Cook wet stunt nut stew.");
                else
                {
                    subentry.entries.listAppend("Acquire and make wet stunt nut stew.");
                    if ($item[wet stunt nut stew].available_amount() == 0 && $item[stunt nuts].available_amount() == 0)
                        subentry.entries.listAppend("Acquire stunt nuts from Bob Racecar or Racecar Bob in Palindome. (30% drop)");
                    if ($items[wet stew].available_amount() == 0 && ($items[bird rib].available_amount() == 0 || $items[lion oil].available_amount() == 0))
                    {
                        string [int] components;
                        if ($item[bird rib].available_amount() == 0)
                            components.listAppend($item[bird rib]);
                        if ($item[lion oil].available_amount() == 0)
                            components.listAppend($item[lion oil]);
                        string line = "Adventure in Whitey's Grove to acquire " + components.listJoinComponents("", "and") + ".|Need +186% item and +combat.";
                        if (familiar_is_usable($familiar[jumpsuited hound dog]))
                            line += " (hound dog is useful for this)";
                        subentry.entries.listAppend(line);
                        subentry.modifiers.listAppend("+combat");
                        subentry.modifiers.listAppend("+186% item");
                        if (!in_hardcore())
                            subentry.entries.listAppend("Or pull wet stew.");
                    }
                }
            }
            else
            {
                subentry.entries.listAppend("Talk to Mr. Alarm.");
                if ($item[talisman o' nam].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip the Talisman o' Nam.");
            }
        }
        else if (false)
        {
            string [int] tasks;
            //talk to mr. alarm to unlock whitey's grove
            if (7270.to_item().available_amount() > 0)
            {
                url = "inventory.php?which=3";
                tasks.listAppend("use 2 Love Me, Vol. 2");
            }
            if ($item[wet stunt nut stew].available_amount() > 0)
                tasks.listAppend("talk to Mr. Alarm");
            else
                tasks.listAppend("talk to Mr. Alarm to unlock Whitey's Grove");
                
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".");
            if ($item[talisman o' nam].equipped_amount() == 0)
                subentry.entries.listAppend("Equip the Talisman o' Nam.");
        }
        else if (false)
        {
            string single_entry_mode = "";
            //Do we have everything yet?
            if (false)
            {
                //Yes - place everything on the shelves
                if (false)
                {
                    //use book to unlock office
                    url = "inventory.php?which=3";
                    subentry.entries.listAppend("Read I Love Me, Vol I.");
                }
                else
                {
                    subentry.entries.listAppend("Place items on shelves.|Order is god, red nugget, dog, and ostrich egg.");
                }
            }
            else
            {
                //No
                
                //Need:
                //√Wet stunt nut stew / stunt nuts
                //√"I Love Me, Vol. I" (7262)
                //√instant camera -> 7263 photograph of a dog
                //√7264 photograph of a red nugget
                //√7265 photograph of an ostrich egg
                //√photograph of god
                subentry.entries.listAppend("Adventure in the palindome.");
                
                if ($item[stunt nuts].available_amount() + $item[wet stunt nut stew].available_amount() == 0 )
                {
                    subentry.modifiers.listAppend("+234% item");
                    subentry.entries.listAppend("Acquire stunt nuts from Bob Racecar or Racecar Bob. (30% drop)");
                }
                
                if (7262.to_item().available_amount() == 0) //I love me, Vol. I
                {
                    subentry.entries.listAppend("Find I Love Me, Vol. I in-combat. Fifth(?) dude-type monster.");
                }
                
                string [int] missing_ncs;
                if (lookupItem("photograph of a red nugget").available_amount() == 0)
                {
                    missing_ncs.listAppend("photograph of a red nugget");
                }
                if (lookupItem("photograph of an ostrich egg").available_amount() == 0)
                {
                    missing_ncs.listAppend("photograph of an ostrich egg");
                }
                if ($item[photograph of god].available_amount() == 0)
                {
                    missing_ncs.listAppend("photograph of god");
                }
                if (missing_ncs.count() > 0)
                    subentry.entries.listAppend("Find " + missing_ncs.listJoinComponents(", ", "and") + " from non-combats.|(unknown if affected by -combat");
                
                
                
                if (lookupItem("photograph of a dog").available_amount() == 0)
                {
                    if (lookupItem("disposable instant camera").available_amount() == 0)
                    {
                        url = "place.php?whichplace=spookyraven2";
                        single_entry_mode = "Adventure in the haunted ballroom for a disposable instant camera.";
                    }
                    else
                    {
                        subentry.entries.listAppend("Photograph Bob Racecar or Racecar Bob with disposable instant camera.");
                    }
                }
                
            }
            if (single_entry_mode.length() > 0)
            {
                subentry.entries.listClear();
                subentry.entries.listAppend(single_entry_mode);
            }
            else
            {
                if ($item[talisman o' nam].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip the Talisman o' Nam.");
            }
        }
        else
        {
            subentry.entries.listAppend("Quest was just revamped; here's a simple (and possibly inaccurate) guide:");
            subentry.entries.listAppend("First you adventure in the Palindome.|Find three photographs via non-combats(?), and take a picture of Bob Racecar/Racecar Bob with a disposable instant camera. (found in NC in haunted bedroom)|Olfact bob racecar/racecar bob.|Also, possibly find stunt nuts. (30% drop, +234% item)");
            subentry.entries.listAppend("&quot;I Love Me, Vol.&quot; I will drop from the fifth dude-type monster. Read it to unlock Dr. Awkward's office.");
            subentry.entries.listAppend("Place all four photographs on the shelves in the office.|Order is god, red nugget, dog, and ostrich egg.");
            subentry.entries.listAppend("Read 2 Love Me, Vol. 2 to unlock Mr. Alarm's office.");
            subentry.entries.listAppend("Talk to Mr. Alarm, unlock Whitey's Grove. Run +186% item, +combat to find lion oil and bird rib.|Or, alternatively, adventure in the palindome. I don't know the details, sorry.");
            subentry.entries.listAppend("Cook wet stunt nut stew, talk to Mr. Alarm. He'll give you the Mega Gem.");
            subentry.entries.listAppend("Equip that to fight Dr. Awkard in his office.");
        }
    }

    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the poop deck, belowdecks,the palindome,cobb's knob laboratory,whitey's grove]));
}

void QLevel11PyramidGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Pyramid"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Pyramid"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";
    
    if (!base_quest_state.state_boolean["Desert Explored"])
    {
        url = "place.php?whichplace=desertbeach";
        int exploration = base_quest_state.state_int["Desert Exploration"];
        int exploration_remaining = 100 - exploration;
        float exploration_per_turn = 1.0;
        if ($item[uv-resistant compass].available_amount() > 0)
            exploration_per_turn += 1.0;
        if (lookupItem("ornate dowsing rod").available_amount() > 0)
            exploration_per_turn += 2.0; //FIXME make completely accurate for first turn? not enough information available
        
        boolean have_blacklight_bulb = (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeHeadlight") == "Blacklight Bulb");
        if (have_blacklight_bulb)
            exploration_per_turn += 2.0;
        //FIXME deal with ultra-hydrated
        int combats_remaining = exploration_remaining;
        combats_remaining = ceil(to_float(exploration_remaining) / exploration_per_turn);
        subentry.entries.listAppend(exploration_remaining + "% exploration remaining. (" + pluralize(combats_remaining, "combat", "combats") + ")");
        if ($effect[ultrahydrated].have_effect() == 0)
        {
            if (__last_adventure_location == $location[the arid, extra-dry desert])
            {
                string [int] description;
                description.listAppend("Adventure in the Oasis.");
                if ($items[ten-leaf clover, disassembled clover].available_amount() > 0)
                    description.listAppend("Potentially clover for 20 turns, versus 5.");
                task_entries.listAppend(ChecklistEntryMake("__effect ultrahydrated", "place.php?whichplace=desertbeach", ChecklistSubentryMake("Acquire ultrahydrated effect", "", description), -11));
            }
            if (exploration > 0)
                subentry.entries.listAppend("Need ultra-hydrated from The Oasis. (potential clover for 20 turns)");
        }
        if (exploration < 10)
        {
            int turns_until_gnasir_found = -1;
            if (exploration_per_turn != 0.0)
                turns_until_gnasir_found = ceil(to_float(10 - exploration) / exploration_per_turn);
            
            subentry.entries.listAppend("Find Gnasir after " + pluralize(turns_until_gnasir_found, "turn", "turns") + ".");
        }
        else if (get_property_int("gnasirProgress") == 0 && exploration <= 14 && $location[the arid, extra-dry desert].noncombatTurnsAttemptedInLocation() == 0)
        {
            subentry.entries.listAppend("Find Gnasir next turn.");
        }
        else
        {
            boolean need_pages = false;
            if (!base_quest_state.state_boolean["Black Paint Given"])
            {
                if ($item[can of black paint].available_amount() == 0)
                    subentry.entries.listAppend("Buy can of black paint, give it to Gnasir.");
                else
                    subentry.entries.listAppend("Give can of black paint to Gnasir.");
                    
            }
            if (!base_quest_state.state_boolean["Stone Rose Given"])
            {
                if ($item[stone rose].available_amount() > 0)
                    subentry.entries.listAppend("Give stone rose to Gnasir.");
                else
                {
                    string line = "Potentially adventure in Oasis for stone rose.";
                    if (delayRemainingInLocation($location[the oasis]) > 0)
                    {
                        string hipster_text = "";
                        if (__misc_state["have hipster"])
                        {
                            hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
                        }
                        line += "|Delay for " + pluralize(delayRemainingInLocation($location[the oasis]), "turn", "turns") + hipster_text + ".";
                    }
                    subentry.entries.listAppend(line);
                }
            }
            if (!base_quest_state.state_boolean["Manual Pages Given"])
            {
                if ($item[worm-riding manual page].available_amount() == 15)
                    subentry.entries.listAppend("Give Gnasir the worm-riding manual pages.");
                else
                {
                    int remaining = 15 - $item[worm-riding manual page].available_amount();
                    
                    subentry.entries.listAppend("Find " + pluralize(remaining, "more worm-riding manual page", "more worm-riding manual pages") + ".");
                    need_pages = true;
                }
                
            }
            else if (!base_quest_state.state_boolean["Wormridden"])
            {
                subentry.modifiers.listAppend("rhythm");
                if ($item[drum machine].available_amount() > 0)
                {
                    subentry.entries.listAppend("Use drum machine.");
                }
            }
            if (!base_quest_state.state_boolean["Wormridden"] && $item[drum machine].available_amount() == 0)
            {
                if (base_quest_state.state_boolean["Manual Pages Given"])
                    subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), use drum machine.");
                else
                    subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), collect/return pages, then use drum machine.");
                subentry.modifiers.listAppend("+234% item");
            }
            if (!base_quest_state.state_boolean["Killing Jar Given"])
            {
                if ($item[killing jar].available_amount() > 0)
                    subentry.entries.listAppend("Give Gnasir the killing jar.");
                else
                    subentry.entries.listAppend("Potentially find killing jar. (banshee, haunted library, 10% drop, YR?)");
            }
            
            if (__misc_state["have hipster"])
            {
                subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                
                string line = __misc_state_string["hipster name"].capitalizeFirstLetter() + " for free combats";
                if (need_pages)
                    line += " and manual pages";
                line += ".";
                subentry.entries.listAppend(line);
            }
        }
        if ($effect[ultrahydrated].have_effect() == 0)
        {
            if (exploration > 0)
                subentry.entries.listAppend("Acquire ultrahydrated effect from oasis. (potential clover for 20 adventures)");
        }
        if ($item[desert sightseeing pamphlet].available_amount() > 0)
        {
            if ($item[desert sightseeing pamphlet].available_amount() == 1)
                subentry.entries.listAppend("Use your desert sightseeing pamphlet. (+15% exploration)");
            else
                subentry.entries.listAppend("Use your desert sightseeing pamphlets. (+15% exploration)");
        }
        if (!base_quest_state.state_boolean["Have UV-Compass eqipped"])
        {
            boolean should_output_compass_in_red = true;
            string line = "";
            if (lookupItem("ornate dowsing rod").available_amount() > 0)
            {
                line = "Equip the ornate dowsing rod.";
            }
            else
            {
                if ($item[uv-resistant compass].available_amount() == 0)
                {
                    line = "Acquire";
                    if (have_blacklight_bulb)
                    {
                        line = "Possibly acquire";
                        should_output_compass_in_red = false;
                    }
                  
                    line += " UV-resistant compass, equip for faster desert exploration. (shore vacation)";
                  
                    if (lookupItem("odd silver coin").available_amount() > 0)
                    {
                        line += "|Or acquire ornate dowsing rod from Paul's Boutique? (5 odd silver coins)";
                    }
                  
                }
                else if ($item[uv-resistant compass].available_amount() > 0)
                {
                    line = "Equip the UV-resistant compass.";
                }
            }
            if (line.length() > 0)
            {
                if (should_output_compass_in_red)
                    line = HTMLGenerateSpanFont(line, "red", "");
                subentry.entries.listAppend(line);
            }
        }
    }
    else
    {
        //Desert explored.
        if ($item[staff of ed].available_amount() + $item[staff of ed].creatable_amount() == 0)
        {
            //Staff of ed.
            subentry.entries.listAppend("Find the Staff of Ed.");
        }
        else if (base_quest_state.mafia_internal_step == 12)
        {
            url = "place.php?whichplace=desertbeach";
            subentry.entries.listAppend("Visit the pyramid, click on it.");
        }
        else
        {
            url = "pyramid.php";
            //Pyramid unlocked:
            boolean have_pyramid_position = false;
            int pyramid_position = get_property_int("pyramidPosition");
            
            //Uncertain:
            if (get_property_int("lastPyramidReset") == my_ascensions())
                have_pyramid_position = true;
            
            //I think there are... five positions?
            //1=Ed, 2=bad, 3=vending machine, 4=token, 5=bad
            int next_position_needed = -1;
            int additional_turns_after_that = 0;
            string task;
            boolean ed_waiting = get_property_boolean("pyramidBombUsed");
            boolean done_with_wheel_turning = false;
            if (2318.to_item().available_amount() > 0 || ed_waiting)
            {
                //need 1
                next_position_needed = 1;
                additional_turns_after_that = 0;
                
                int ed_ml = 180 + monster_level_adjustment_ignoring_plants();
                task = "fight Ed in the lower chambers";
                if (ed_ml > my_buffedstat($stat[moxie]))
                    task += " (" + ed_ml + " attack)";
                if (ed_waiting)
                    done_with_wheel_turning = true;
            }
            else if ($item[ancient bronze token].available_amount() > 0)
            {
                //need 3
                next_position_needed = 3;
                additional_turns_after_that = 3;
                task = "acquire " + 2318.to_item().to_string() + " in lower chamber";
            }
            else
            {
                //need 4
                next_position_needed = 4;
                additional_turns_after_that = 3 + 4;
                task = "acquire token in lower chamber";
            }
            
            int spins_needed = (next_position_needed - pyramid_position + 10) % 5;
            
            string [int] tasks;
            if (spins_needed > 0)
            {
                if (spins_needed == 1)
                    tasks.listAppend("spin the pyramid One More Time");
                else
                    tasks.listAppend("spin the pyramid " + spins_needed.int_to_wordy() + " times");
            }
            tasks.listAppend(task);
            
            
            if (!have_pyramid_position)
            {
                tasks.listClear();
                tasks.listAppend("look at the pyramid");
            }
            
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
            
            if (!done_with_wheel_turning)
            {
                string [int] relevant_items;
                if ($item[tomb ratchet].available_amount() > 0)
                    relevant_items.listAppend(pluralize($item[tomb ratchet]));
                if ($item[tangle of rat tails].available_amount() > 0)
                    relevant_items.listAppend(pluralize($item[tangle of rat tails]));
                  
                if (relevant_items.count() > 0)
                    subentry.entries.listAppend(relevant_items.listJoinComponents(", ", "and") + " available.");
            }
            //FIXME track wheel being placed
            //FIXME tell them which route is better from where they are
        }
    }
    
    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the arid\, extra-dry desert,the oasis,the upper chamber,the lower chambers, the middle chamber]));
}

boolean [item] __dense_liana_machete_items = $items[antique machete,Machetito,Muculent machete,Papier-m&acirc;ch&eacute;te];

void generateHiddenAreaUnlockForShrine(string [int] description, location shrine)
{
    boolean have_machete_equipped = false;
    item machete_available = $item[none];
    foreach it in __dense_liana_machete_items
    {
        if (it.available_amount() > 0)
            machete_available = it;
        if (it.equipped_amount() > 0)
            have_machete_equipped = true;
    }
    int liana_remaining = MAX(0, 3 - shrine.combatTurnsAttemptedInLocation());
    if (shrine != $location[a massive ziggurat])
        description.listAppend("Unlock by visiting " + shrine + ".");
    if (liana_remaining > 0 && shrine.noncombatTurnsAttemptedInLocation() == 0)
    {
        string line = liana_remaining.int_to_wordy().capitalizeFirstLetter() + " dense liana remain.";
        
        if (__misc_state["can equip just about any weapon"])
        {
            if (machete_available == $item[none])
                line += " Acquire a machete first.";
            else if (!have_machete_equipped)
                line += " Equip " + machete_available + " first.";
        }
        description.listAppend(line);
    }
}

void QLevel11HiddenCityGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Hidden City"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Hidden City"];
    ChecklistEntry entry;
    entry.target_location = "place.php?whichplace=hiddencity";
    entry.image_lookup_name = base_quest_state.image_name;
    entry.should_indent_after_first_subentry = true;
    entry.should_highlight = $locations[the hidden temple, the hidden apartment building, the hidden hospital, the hidden office building, the hidden bowling alley, the hidden park, a massive ziggurat,an overgrown shrine (northwest),an overgrown shrine (southwest),an overgrown shrine (northeast),an overgrown shrine (southeast)] contains __last_adventure_location;
    
    if (!__quest_state["Hidden Temple Unlock"].finished)
    {
        return;
    }
    else if (!locationAvailable($location[the hidden park]))
    {
        entry.image_lookup_name = "Hidden Temple";
        entry.target_location = "place.php?whichplace=woods";
        ChecklistSubentry subentry;
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Unlock the hidden city via the hidden temple.");
        if ($item[the Nostril of the Serpent].available_amount() == 0)
            subentry.entries.listAppend("Need nostril of the serpent.");
        if ($item[stone wool].available_amount() > 0)
        {
            if ($effect[Stone-Faced].have_effect() == 0)
                entry.target_location = "inventory.php?which=3";
            subentry.entries.listAppend(pluralize($item[stone wool]) + " available.");
        }
        entry.subentries.listAppend(subentry);
    }
    else
    {		
        if (true)
        {
            ChecklistSubentry subentry;
            subentry.header = base_quest_state.quest_name;
            entry.subentries.listAppend(subentry);
        }
        //Not sure exactly how these work.
        //8 appears to be finished.
        //1 appears to be "area unlocked"
        boolean hidden_tavern_unlocked = (get_property_int("hiddenTavernUnlock") == my_ascensions());
        boolean janitors_relocated_to_park = (get_property_int("relocatePygmyJanitor") == my_ascensions());
        boolean have_machete = false;
    
        have_machete = __dense_liana_machete_items.available_amount() > 0;
        int bowling_progress = get_property_int("hiddenBowlingAlleyProgress");
        int hospital_progress = get_property_int("hiddenHospitalProgress");
        int apartment_progress = get_property_int("hiddenApartmentProgress");
        int office_progress = get_property_int("hiddenOfficeProgress");
        
        boolean at_last_spirit = false;
        
        if (bowling_progress == 8 && hospital_progress == 8 && apartment_progress == 8 && office_progress == 8 || $item[stone triangle].available_amount() == 4)
        {
            at_last_spirit = true;
            ChecklistSubentry subentry;
            subentry.header = "Massive Ziggurat";
            //Instead of checking for four stone triangles, we check for the lack of all four stone spheres. That way it should detect properly after you fight the boss (presumably losing stone triangles), and lost?
        
            int spheres_available = $item[moss-covered stone sphere].available_amount() + $item[dripping stone sphere].available_amount() + $item[crackling stone sphere].available_amount() + $item[scorched stone sphere].available_amount();
        
            if (spheres_available > 0)
            {
                subentry.entries.listAppend("Acquire stone triangles");
            }
            else
            {
                if ($location[a massive ziggurat].combatTurnsAttemptedInLocation() <3 && $location[a massive ziggurat].noncombatTurnsAttemptedInLocation() == 0)
                {
                    generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                }
                else
                {
                    subentry.modifiers.listAppend("elemental damage");
                    subentry.entries.listAppend("Fight the protector spectre!");
                }
            }
        
            entry.subentries.listAppend(subentry);
        }
        if (!at_last_spirit)
        {
            if (!janitors_relocated_to_park || !have_machete)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Park";
            
                subentry.modifiers.listAppend("-combat");
                if (!have_machete)
                {
                    int turns_remaining = MAX(0, 6 - $location[the hidden park].turnsAttemptedInLocation());
                    string line;
                    line += "Adventure for " + turns_remaining.int_to_wordy() + " turns here for antique machete to clear dense lianas.";
                    if (canadia_available())
                        line += "|Or potentially use muculent machete by acquiring forest tears. (kodama, Outskirts of Camp Logging Camp, 30% drop or clover)";
                    subentry.entries.listAppend(line);
                }
                if (!janitors_relocated_to_park)
                    subentry.entries.listAppend("Potentially relocate janitors to park via non-combat.");
                else
                    subentry.entries.listAppend("Acquire useful items from dumpster with -combat.");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
                if (my_basestat($stat[muscle]) < 62)
                {
                    string line = "Will need " + (62 - my_basestat($stat[muscle])) + " more muscle to equip machete.";
                    subentry.entries.listAppend(line);
                }
            
                entry.subentries.listAppend(subentry);
            }
        }
        
        if (apartment_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Apartment";
            if (apartment_progress == 7 || $item[moss-covered stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place moss-covered stone sphere in shrine.");
            }
            else if (apartment_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northwest)]);
            }
            else
            {
                subentry.entries.listAppend("Olfact shaman.");
                //if (!$monster[pygmy witch lawyer].is_banished())
                    //subentry.entries.listAppend("Potentially banish lawyers.");
                subentry.entries.listAppend("NC appears every 9th adventure.");
                
                string [int] curse_sources;
                if (__misc_state["can drink just about anything"])
                {
                    if (hidden_tavern_unlocked)
                        curse_sources.listAppend("cursed punch from the tavern");
                    else
                        curse_sources.listAppend("cursed punch from the tavern, if you unlock it");
                }
                curse_sources.listAppend("fighting a pygmy shaman");
                curse_sources.listAppend("non-combat (try to avoid)");
                string curse_details = "";
                curse_details = " Acquired from " + curse_sources.listJoinComponents(", ", "or") + ".";
                
                if ($effect[thrice-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("You're thrice-cursed. Fight the protector spirit!");
                }
                else if ($effect[twice-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("Need one more curse." + curse_details);
                }
                else if ($effect[once-cursed].have_effect() > 0)
                {
                    subentry.entries.listAppend("Need two more curses." + curse_details);
                }
                else
                {
                    subentry.entries.listAppend("Need three more curses." + curse_details);
                }
                if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && lookupSkill("Shake it off").have_skill())
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid using Shake It Off to heal", "red", "") + ", it'll remove the curse.");
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
        if (office_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Office";
            if (office_progress == 7 || $item[crackling stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place crackling stone sphere in shrine.");
            }
            else if (office_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northeast)]);
            }
            else
            {
                if ($item[McClusky file (complete)].available_amount() == 0)
                {
                    int files_found = $item[McClusky file (page 1)].available_amount() + $item[McClusky file (page 2)].available_amount() + $item[McClusky file (page 3)].available_amount() + $item[McClusky file (page 4)].available_amount() + $item[McClusky file (page 5)].available_amount();
                    int files_not_found = 5 - files_found;
                    if (files_not_found > 0)
                    {
                        subentry.entries.listAppend("Olfact accountant.");
                        subentry.entries.listAppend("Need " + pluralize(files_not_found, "more McClusky file", "more McClusky files") + ". Found from pygmy witch accountants.");
                        //if (!$monster[pygmy witch lawyer].is_banished())
                            //subentry.entries.listAppend("Potentially banish lawyers.");
                    }
                    if ($item[Boring binder clip].available_amount() == 0)
                        subentry.entries.listAppend("Need boring binder clip. (raid the supply cabinet, office NC)");
                }
                else
                {
                    subentry.entries.listAppend("You have the complete McClusky files, fight boss.");
                }
                subentry.entries.listAppend("NC appears first on the 6th adventure, then every 5 adventures.");
        
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
            }
            entry.subentries.listAppend(subentry);
        }
        if (hospital_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Hospital";
            if (hospital_progress == 7 || $item[dripping stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place dripping stone sphere in shrine.");
            }
            else if (hospital_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Southwest)]);
            }
            else
            {
                subentry.entries.listAppend("Olfact surgeon.");
                if (!$monster[pygmy orderlies].is_banished())
                    subentry.entries.listAppend("Potentially banish pgymy orderlies.");
                
        
                string [int] items_we_have_unequipped;
                item [int] items_we_have_equipped;
                foreach it in $items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel]
                {
                    boolean can_equip = true;
                    if (it.to_slot() == $slot[shirt] && !__misc_state["Torso aware"])
                        can_equip = false;
                    if (it.available_amount() > 0 && it.equipped_amount() == 0 && can_equip)
                    {
                        buffer line;
                        line.append(it);
                        line.append(" (");
                        line.append(it.to_slot().slot_to_string());
                        if (!it.can_equip())
                            line.append(", can't equip yet");
                        line.append(")");
                        items_we_have_unequipped.listAppend(line);
                    }
                    if (it.equipped_amount() > 0)
                        items_we_have_equipped.listAppend(it);
                }
                if (items_we_have_unequipped.count() > 0)
                {
                    subentry.entries.listAppend("Equipment unequipped: (+10% chance of protector spirit per piece)|*" + items_we_have_unequipped.listJoinComponents("|*"));
                }
                if (items_we_have_equipped.count() > 0)
                {
                    subentry.entries.listAppend((items_we_have_equipped.count() * 10) + "% chance of protector spirit encounter.");
                }
            }
            
            
            entry.subentries.listAppend(subentry);
        }
    
        if (bowling_progress < 8)
        {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Bowling Alley";
        
            if (bowling_progress == 7 || $item[scorched stone sphere].available_amount() > 0)
            {
                subentry.entries.listAppend("Place scorched stone sphere in shrine.");
            }
            else if (bowling_progress == 0)
            {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (southeast)]);
            }
            else
            {
                int rolls_needed = 6 - bowling_progress;
                
                if (!(rolls_needed == 1 && $item[bowling ball].available_amount() > 0))
                {
                    subentry.modifiers.listAppend("+150% item");
                    subentry.entries.listAppend("Olfact bowler, run +150% item.");
                    if (!$monster[pygmy orderlies].is_banished())
                        subentry.entries.listAppend("Potentially banish pgymy orderlies.");
                }
                
                string line;
                line = int_to_wordy(rolls_needed).capitalizeFirstLetter();
                if (rolls_needed > 1)
                    line += " more rolls";
                else
                    line = "One More Roll";
                line += " until protector spirit fight.";
                
                if ($item[bowling ball].available_amount() > 0)
                    line += "|Have " + pluralizeWordy($item[bowling ball]) + ".";
                
                subentry.entries.listAppend(line);
                
                //FIXME pop up a reminder to acquire bowl of scorpions
                if (__misc_state["free runs usable"])
                {
                    if (hidden_tavern_unlocked)
                    {
                        if ($item[bowl of scorpions].available_amount() == 0)
                            subentry.entries.listAppend(HTMLGenerateSpanFont("Buy a bowl of scorpions", "red", "") + " from the Hidden Tavern to free run from drunk pygmys.");
                    }
                    else
                    {
                        subentry.entries.listAppend("Possibly unlock the hidden tavern first, for free runs from drunk pygmies.");
                    }
                }
            }
        
        
        
            entry.subentries.listAppend(subentry);
        }
        
        if (!at_last_spirit)
        {
            if ($location[a massive ziggurat].combatTurnsAttemptedInLocation() <3)
            {
                ChecklistSubentry subentry;
                subentry.header = "Massive Ziggurat";
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                entry.subentries.listAppend(subentry);
            }
            if (!hidden_tavern_unlocked)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Tavern";
                boolean should_output = true;
            
                if ($item[book of matches].available_amount() > 0)
                    subentry.entries.listAppend("Use book of matches.");
                else
                {
                    if (janitors_relocated_to_park)
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, Hidden Park, 20% drop)");
                    else
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, everywhere in the hidden city, 20% drop)");
                    
                    string [int] tavern_provides;
                    if (bowling_progress < 8)
                        tavern_provides.listAppend("Free runs from drunk pygmys.");
                    if (__misc_state["can drink just about anything"])
                    {
                        if (apartment_progress < 8)
                            tavern_provides.listAppend("Curses for hidden apartment.");
                        int adventures_given = 15;
                        if (have_skill($skill[the ode to booze]))
                            adventures_given += 6;
                        
                        tavern_provides.listAppend("Nightcap drink. (Fog Murderer for " + adventures_given + " adventures)");
                    }
                    if (tavern_provides.count() > 0)
                        subentry.entries.listAppend("Hidden Tavern provides:|*" + tavern_provides.listJoinComponents("|*"));
                    else
                        should_output = false; //don't bother, no reason to... I think?
                
                }
                if (should_output)
                    entry.subentries.listAppend(subentry);
            }
        }
    
    
        if (false) //debug internals
        {
            ChecklistSubentry subentry;
            subentry.header = "Debug";
            string [int] show_properties = split_string_mutable("hiddenApartmentProgress,hiddenBowlingAlleyProgress,hiddenHospitalProgress,hiddenOfficeProgress", ","); //8,8,8,8 when finished
            foreach key in show_properties
                subentry.entries.listAppend(show_properties[key] + " = " + get_property(show_properties[key]).HTMLEscapeString());
        
            if (get_property_int("hiddenTavernUnlock") == my_ascensions())
                subentry.entries.listAppend("hidden tavern unlocked");
            else
                subentry.entries.listAppend("hidden tavern not yet");
        
            if (get_property_int("relocatePygmyJanitor") == my_ascensions())
                subentry.entries.listAppend("Janitors relocated to park");
            else
                subentry.entries.listAppend("JANITORS EVERYWHERE");
        
        
            if (get_property_int("relocatePygmyLawyer") == my_ascensions())
                subentry.entries.listAppend("Lawyers relocated");
            else
                subentry.entries.listAppend("Lawyers still around");
        
            string [int] saving_lines;
            saving_lines.listAppendList(subentry.entries);
            subentry.entries.listClear();
            subentry.entries.listAppend(saving_lines.listJoinComponents("|"));

            entry.subentries.listAppend(subentry);
        }
    }
    if (entry.subentries.count() > 0)
        task_entries.listAppend(entry);
}

void QLevel11HiddenTempleGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Hidden Temple Unlock"].in_progress)
        return;
        
    QuestState base_quest_state = __quest_state["Hidden Temple Unlock"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    
    if (delayRemainingInLocation($location[the spooky forest]) > 0)
    {
		string hipster_text = "";
		if (__misc_state["have hipster"])
		{
			hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
		}
        string line = "Delay for " + pluralize(delayRemainingInLocation($location[the spooky forest]), "turn", "turns") + hipster_text + ".";
        subentry.entries.listAppend(line);
        subentry.entries.listAppend("Run -combat after that.");
    }
    else
    {
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Run -combat in the spooky forest.");
    }
    if (__misc_state["free runs available"])
    {
        subentry.modifiers.listAppend("free runs");
        subentry.entries.listAppend("Free run from low-stat monsters.");
    }
    
    int ncs_remaining = 0;
        
    if ($item[spooky sapling].available_amount() == 0)
    {
        if (my_meat() < 100)
            subentry.entries.listAppend("Obtain 100 meat for spooky sapling.");
        else
            subentry.entries.listAppend("Acquire spooky sapling.|*Follow the old road" + __html_right_arrow_character + "Talk to the hunter" + __html_right_arrow_character + "Buy a tree");
        ncs_remaining += 1;
    }
        
    if ($item[tree-holed coin].available_amount() == 0)
    {
        if ($item[spooky temple map].available_amount() == 0)
        {
            //no coin, no map
            subentry.entries.listAppend("Acquire tree-holed coin, then map.|*Explore the stream" + __html_right_arrow_character + "Squeeze into the cave");
            ncs_remaining += 2;
        }
        else
        {
            //no coin, have map, nothing to do here
        }
    }
    else
    {
        if ($item[spooky temple map].available_amount() == 0)
        {
            //coin, no map
            subentry.entries.listAppend("Acquire spooky temple map.|*Brave the dark thicket" + __html_right_arrow_character + "Follow the coin" + __html_right_arrow_character + "Insert coin to continue");
            
            ncs_remaining += 1;
        }
        else
        {
            //wait, what?
            subentry.entries.listAppend("how did we get here?");
        }
    }
    if ($item[spooky-gro fertilizer].available_amount() == 0)
    {
        subentry.entries.listAppend("Acquire spooky-gro fertilizer.|*Brave the dark thicket" + __html_right_arrow_character + "Investigate the dense foliage");
        ncs_remaining += 1;
    }
    if ($item[spooky temple map].available_amount() > 0 && $item[spooky-gro fertilizer].available_amount() > 0 && $item[spooky sapling].available_amount() > 0)
    {
        subentry.modifiers.listClear();
        subentry.entries.listClear();
        subentry.entries.listAppend("Use the spooky temple map.");
    }
    
    if (ncs_remaining > 0)
    {
        float spooky_forest_nc_rate = clampNormalf(1.0 - (85.0 + combat_rate_modifier()) / 100.0);
        
        float turns_remaining = -1.0;
        float turns_per_nc = 7.0;
        if (spooky_forest_nc_rate > 0.0)
            turns_per_nc = MIN(7.0, 1.0 / spooky_forest_nc_rate);
            
        turns_remaining = ncs_remaining.to_float() * turns_per_nc;
        turns_remaining += delayRemainingInLocation($location[the spooky forest]);
        
        subentry.entries.listAppend("~" + turns_remaining.roundForOutput(1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
    }
    
    if (my_level() < 6)
        subentry.entries.listAppend("There's also another unlock quest at level six, but it's slower.");
    else
        subentry.entries.listAppend("There's also another unlock quest, but it's slower.");
    
    if (__misc_state_string["ballroom song"] != "-combat")
    {
        subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "place.php?whichplace=woods", subentry, $locations[the spooky forest]));
    }
    else
    {
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "place.php?whichplace=woods", subentry, , $locations[the spooky forest]));
    }
}


void QLevel11GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__misc_state["In run"])
        return;
    //Such a complicated quest.
    QLevel11BaseGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11ManorGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11PalindomeGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11PyramidGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11HiddenCityGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    QLevel11HiddenTempleGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}

void QLevel12Init()
{
	//questL12War
	//fratboysDefeated, hippiesDefeated
	//sidequestArenaCompleted, sidequestFarmCompleted, sidequestJunkyardCompleted, sidequestLighthouseCompleted, sidequestNunsCompleted, sidequestOrchardCompleted
	//warProgress
	
	//Sidequests:
	//state_boolean["Lighthouse Finished"]
	//state_boolean["Orchard Finished"]
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL12War");
	state.quest_name = "Island War Quest";
	state.image_name = "island war";
	state.council_quest = true;
	
	state.state_boolean["Arena Finished"] = (get_property("sidequestArenaCompleted") != "none");
	state.state_boolean["Farm Finished"] = (get_property("sidequestFarmCompleted") != "none");
	state.state_boolean["Junkyard Finished"] = (get_property("sidequestJunkyardCompleted") != "none");
	state.state_boolean["Lighthouse Finished"] = (get_property("sidequestLighthouseCompleted") != "none");
	state.state_boolean["Nuns Finished"] = (get_property("sidequestNunsCompleted") != "none");
	state.state_boolean["Orchard Finished"] = (get_property("sidequestOrchardCompleted") != "none");
    
    state.state_int["hippies left on battlefield"] = 1000 - get_property_int("hippiesDefeated");
    state.state_int["frat boys left on battlefield"] = 1000 - get_property_int("fratboysDefeated");
	
	if (state.finished)
	{
		state.state_boolean["Arena Finished"] = true;
		state.state_boolean["Farm Finished"] =  true;
		state.state_boolean["Junkyard Finished"] = true;
		state.state_boolean["Lighthouse Finished"] = true;
		state.state_boolean["Nuns Finished"] = true;
		state.state_boolean["Orchard Finished"] = true;
	}
	
	if (false)
	{
		//Internal debugging:
		state.state_boolean["Arena Finished"] = false;
		state.state_boolean["Farm Finished"] =  false;
		state.state_boolean["Junkyard Finished"] = false;
		state.state_boolean["Lighthouse Finished"] = false;
		state.state_boolean["Nuns Finished"] = false;
		state.state_boolean["Orchard Finished"] = false;
	}
	
	if (my_level() >= 12 && ($location[The Palindome].turnsAttemptedInLocation() > 0 || $items[mega gem,&quot;I Love Me\, Vol. I&quot;,Staff of Ed,Staff of Fats,Staff of Ed\, almost].available_amount() > 0))
		state.startable = true;
    
	__quest_state["Level 12"] = state;
	__quest_state["Island War"] = state;
}

void QLevel12GenerateTasksSidequests(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Level 12"];
	if (!base_quest_state.state_boolean["Orchard Finished"])
	{
		string [int] details;
		string [int] modifiers;
	
        string url = "bigisland.php?place=orchard";
		modifiers.listAppend("+1000% item");
		if (__misc_state["yellow ray potentially available"])
			modifiers.listAppend("potential YR");
	
        monster pickpocket_monster = $monster[none];
        boolean need_gland = false;
		if ($item[heart of the filthworm queen].available_amount() > 0)
		{
			modifiers.listClear();
			details.listAppend("Go talk to the hippies to complete quest.");
		}
		else if ($effect[Filthworm Guard Stench].have_effect() > 0 || $item[Filthworm royal guard scent gland].available_amount() > 0)
		{
			if ($effect[Filthworm Guard Stench].have_effect() == 0)
            {
                url = "inventory.php?which=3";
				details.listAppend("Use filthworm royal guard scent gland");
            }
			modifiers.listClear();
			details.listAppend("Defeat the filthworm queen in the queen's chamber.");
		}
		else if ($effect[Filthworm Drone Stench].have_effect() > 0 || $item[Filthworm drone scent gland].available_amount() > 0)
		{
			if ($effect[Filthworm Drone Stench].have_effect() == 0)
            {
                url = "inventory.php?which=3";
				details.listAppend("Use filthworm drone scent gland");
            }
			details.listAppend("Adventure with +item in the guards' chamber.");
            need_gland = true;
            pickpocket_monster = $monster[filthworm royal guard];
		}
		else if ($effect[Filthworm Larva Stench].have_effect() > 0 || $item[filthworm hatchling scent gland].available_amount() > 0)
		{
			if ($effect[Filthworm Larva Stench].have_effect() == 0)
            {
                url = "inventory.php?which=3";
				details.listAppend("Use filthworm hatchling scent gland");
            }
			details.listAppend("Adventure with +item in the feeding chamber.");
            need_gland = true;
            pickpocket_monster = $monster[filthworm drone];
		}
		else
		{
			details.listAppend("Adventure with +item in the hatching chamber.");
            need_gland = true;
            pickpocket_monster = $monster[larval filthworm];
		}
        
        if (__misc_state["can pickpocket"] && pickpocket_monster != $monster[none])
        {
            int total_initiative_needed = pickpocket_monster.base_initiative;
            int initiative_needed = total_initiative_needed - initiative_modifier();
            if (initiative_needed > 0)
                details.listAppend("Need " + initiative_needed + "% more initiative to pickpocket every turn.");
        }
        
        if (need_gland)
        {
            float effective_item_drop = item_drop_modifier() / 100.0;
            //FIXME take into account pickpocketing, init, etc.
            float average_glands_found_per_combat = MIN(1.0, (effective_item_drop + 1.0) * 0.1);
            float turns_per_gland = -1.0;
            if (average_glands_found_per_combat != 0.0)
                turns_per_gland = 1.0 / average_glands_found_per_combat;
            details.listAppend("~" + roundForOutput(turns_per_gland, 1) + " turns per gland.");
        }
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Orchard", url, ChecklistSubentryMake("Island War Orchard Quest", modifiers, details), $locations[the hatching chamber, the feeding chamber, the royal guard chamber, the filthworm queen's chamber]));
	}
	if (!base_quest_state.state_boolean["Farm Finished"])
	{
		string [int] details;
		details.listAppend("Great flappin' beasts, with webbed feet and bills! dooks!");
		string [int] modifiers;
        modifiers.listAppend("+meat");
        
        string [int] tasks;
        int ncs_seen = $location[McMillicancuddy's Barn].noncombatTurnsAttemptedInLocation();
        
        if (ncs_seen < 3)
        {
            tasks.listAppend("make a fence out of the barbed wire");
            tasks.listAppend("knock over the lantern");
            tasks.listAppend("dump out the drum");
            details.listAppend("Remember to use a chaos butterfly in combat before clearing the barn.|Then " + tasks.listJoinComponents(", ", "and") + ".");
            
            
            if (__misc_state["free runs available"])
                modifiers.listAppend("free runs in barn");
        }
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Farm", "bigisland.php?place=farm", ChecklistSubentryMake("Island War Farm Quest", modifiers, details), $locations[mcmillicancuddy's farm,mcmillicancuddy's barn,mcmillicancuddy's pond,mcmillicancuddy's back 40,mcmillicancuddy's other back 40,mcmillicancuddy's granary,mcmillicancuddy's bog,mcmillicancuddy's family plot,mcmillicancuddy's shady thicket]));
	}
	if (!base_quest_state.state_boolean["Nuns Finished"])
	{
		string [int] details;
		int meat_gotten = get_property_int("currentNunneryMeat");
		int meat_remaining = 100000 - meat_gotten;
		details.listAppend(meat_remaining + " meat remaining");
	
		float meat_drop_multiplier = meat_drop_modifier() / 100.0 + 1.0;
		vec2i brigand_meat_drop_range = vec2iMake(800 * meat_drop_multiplier, 1200 * meat_drop_multiplier);
		vec2i turn_range;
		if (brigand_meat_drop_range.x != 0 && brigand_meat_drop_range.y != 0)
			turn_range = vec2iMake(ceil(to_float(meat_remaining) / to_float(brigand_meat_drop_range.y)),
			ceil(to_float(meat_remaining) / to_float(brigand_meat_drop_range.x)));
		
		//FIXME consider looking into tracking how long until the semi-rare item runs out, for turn calculation
		if (turn_range.x == turn_range.y)
			details.listAppend(pluralize(turn_range.x, "turn", "turns") + " remaining");
		else
			details.listAppend("[" + turn_range.x + " to " + turn_range.y + "] turns remaining");
            
        if ($effect[Sinuses For Miles].have_effect() > 0 && get_property_int("lastTempleAdventures") != my_ascensions() && $item[stone wool].available_amount() > 0)
            details.listAppend("Potentially use stone wool and visit the hidden temple to extend Sinuses for Miles for 3 turns.");
            
            
        if (lookupItem("Sneaky Pete's leather jacket (collar popped)").equipped_amount() > 0)
            details.listAppend("Might want to unpop the collar. (+20% meat)");
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Nuns", "bigisland.php?place=nunnery", ChecklistSubentryMake("Island War Nuns Quest", "+meat", details), $locations[the themthar hills]));
	}
	if (!base_quest_state.state_boolean["Junkyard Finished"])
	{
		string [int] details;
		if ($item[molybdenum magnet].available_amount() == 0)
		{
			details.listAppend("Talk to Yossarian first.");
		}
		else
		{
			location [item] items_and_locations;
			items_and_locations[$item[molybdenum hammer]] = $location[Next to that Barrel with Something Burning in it];
			items_and_locations[$item[molybdenum screwdriver]] = $location[Out By that Rusted-Out Car];
			items_and_locations[$item[molybdenum pliers]] = $location[Near an Abandoned Refrigerator];
			items_and_locations[$item[molybdenum crescent wrench]] = $location[Over Where the Old Tires Are];
			boolean have_all = true;
            
            string [location][int] location_monsters;
            location_monsters[$location[Next to that Barrel with Something Burning in it]] = listMake("tool batwinged", "vegetable");
            location_monsters[$location[Out By that Rusted-Out Car]] = listMake("tool vegetable", "erudite");
            location_monsters[$location[Near an Abandoned Refrigerator]] = listMake("tool spider", "batwinged");
            location_monsters[$location[Over Where the Old Tires Are]] = listMake("tool erudite", "spider");
            
            string [int] areas_left_strings;
			foreach it in items_and_locations
			{
				location loc = items_and_locations[it];
				if (it.available_amount() > 0)
				{
					continue;
				}
				else
					have_all = false;
                areas_left_strings.listAppend(loc.to_string().to_lower_case() + " (" + location_monsters[loc].listJoinComponents(", ") + ")");
			}
            if (areas_left_strings.count() > 0)
                details.listAppend("Areas left:|*" + areas_left_strings.listJoinComponents("|*"));
			if (have_all)
				details.listAppend("Talk to Yossarian to complete quest.");
			else
            {
                if ($skill[suckerpunch].have_skill())
                {
                    details.listAppend("Cast suckerpunch to stasis gremlins.");
                }
                else if ($item[dictionary].available_amount() > 0)
                {
                    details.listAppend("Read from the dictionary to stasis gremlins.");
                }
                else if ($item[seal tooth].available_amount() > 0)
                {
                    details.listAppend("Use your seal tooth to stasis gremlins.");
                }
                else
                    details.listAppend(HTMLGenerateSpanFont("Acquire a seal tooth", "red", "") + " to stasis gremlins. (from hermit)");
                if (!$monster[a.m.c. gremlin].is_banished())
                    details.listAppend("Potentially banish A.M.C. Gremlin.");
            }
		}
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Junkyard", "bigisland.php?place=junkyard", ChecklistSubentryMake("Island War Junkyard Quest", listMake("+DR", "+DA", "+HP"), details), $locations[next to that barrel with something burning in it,near an abandoned refrigerator,over where the old tires are,out by that rusted-out car]));
	}
	if (!base_quest_state.state_boolean["Lighthouse Finished"])
	{
		string [int] details;
	
        int gunpowder_needed = MAX(0, 5 - $item[barrel of gunpowder].available_amount());
        
        
        if (gunpowder_needed > 0)
        {
            if (gunpowder_needed == 1)
                details.listAppend("Need " + gunpowder_needed + " more barrel of gunpowder.");
            else
                details.listAppend("Need " + gunpowder_needed + " more barrels of gunpowder.");
            
            
            
            //this is an approximation:
            //off by a little over half a turn on average
            float effective_combat_rate = (11.0 / 12.0) * clampNormalf(0.1 + combat_rate_modifier() / 100.0) + (1.0 / 12.0) * 1.0;
            float turns_per_lobster = -1.0;
            if (effective_combat_rate != 0.0)
                turns_per_lobster = 1.0 / effective_combat_rate;
                
            
            float turns_to_complete = gunpowder_needed.to_float() * turns_per_lobster;
            
            //I had the data lying around, so why not?
            //misses <-10 and >30, but the estimate above will catch that
            float [int][int] lfm_simulation_data;
            lfm_simulation_data[5][-10] = 60.00; lfm_simulation_data[5][-5] = 40.02; lfm_simulation_data[5][0] = 29.92; lfm_simulation_data[5][5] = 23.84; lfm_simulation_data[5][10] = 19.76; lfm_simulation_data[5][15] = 16.84; lfm_simulation_data[5][20] = 14.66; lfm_simulation_data[5][25] = 13.00; lfm_simulation_data[4][-10] = 48.00; lfm_simulation_data[4][-5] = 32.27; lfm_simulation_data[4][0] = 24.20; lfm_simulation_data[4][5] = 19.29; lfm_simulation_data[4][10] = 16.00; lfm_simulation_data[4][15] = 13.68; lfm_simulation_data[4][20] = 11.96; lfm_simulation_data[4][25] = 10.63; lfm_simulation_data[3][-10] = 36.00; lfm_simulation_data[3][-5] = 24.53; lfm_simulation_data[3][0] = 18.47; lfm_simulation_data[3][5] = 14.78; lfm_simulation_data[3][10] = 12.34; lfm_simulation_data[3][15] = 10.59; lfm_simulation_data[3][20] = 9.26; lfm_simulation_data[3][25] = 8.20; lfm_simulation_data[2][-10] = 24.00; lfm_simulation_data[2][-5] = 16.79; lfm_simulation_data[2][0] = 12.84; lfm_simulation_data[2][5] = 10.38; lfm_simulation_data[2][10] = 8.68; lfm_simulation_data[2][15] = 7.40; lfm_simulation_data[2][20] = 6.40; lfm_simulation_data[2][25] = 5.60; lfm_simulation_data[1][-10] = 12.00; lfm_simulation_data[1][-5] = 9.19; lfm_simulation_data[1][0] = 7.17; lfm_simulation_data[1][5] = 5.72; lfm_simulation_data[1][10] = 4.66; lfm_simulation_data[1][15] = 3.87; lfm_simulation_data[1][20] = 3.29; lfm_simulation_data[1][25] = 2.84; lfm_simulation_data[5][26] = 12.71; lfm_simulation_data[5][27] = 12.44; lfm_simulation_data[5][28] = 12.18; lfm_simulation_data[5][29] = 11.93; lfm_simulation_data[5][30] = 11.69; lfm_simulation_data[4][26] = 10.40; lfm_simulation_data[4][27] = 10.17; lfm_simulation_data[4][28] = 9.96; lfm_simulation_data[4][29] = 9.75; lfm_simulation_data[4][30] = 9.56; lfm_simulation_data[3][26] = 8.01; lfm_simulation_data[3][27] = 7.83; lfm_simulation_data[3][28] = 7.65; lfm_simulation_data[3][29] = 7.48; lfm_simulation_data[3][30] = 7.32; lfm_simulation_data[2][26] = 5.46; lfm_simulation_data[2][27] = 5.33; lfm_simulation_data[2][28] = 5.20; lfm_simulation_data[2][29] = 5.07; lfm_simulation_data[2][30] = 4.96; lfm_simulation_data[1][26] = 2.76; lfm_simulation_data[1][27] = 2.69; lfm_simulation_data[1][28] = 2.62; lfm_simulation_data[1][29] = 2.56; lfm_simulation_data[1][30] = 2.50;
            
            if (lfm_simulation_data[gunpowder_needed] contains combat_rate_modifier().to_int())
            {
                turns_to_complete = lfm_simulation_data[gunpowder_needed][combat_rate_modifier().to_int()];
                if (gunpowder_needed != 0.0)
                    turns_per_lobster = turns_to_complete / gunpowder_needed.to_float();
            }
            
            details.listAppend("~" + roundForOutput(turns_to_complete, 1) + " turns to complete quest at " + combat_rate_modifier().floor() + "% combat.|~" + roundForOutput(turns_per_lobster, 1) + " turns per lobster.");
        }
        else
            details.listAppend("Talk to the lighthouse keeper.");
	
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Lighthouse", "bigisland.php?place=lighthouse", ChecklistSubentryMake("Island War Lighthouse Quest", listMake("+combat", "copies"), details), $locations[sonofa beach]));
	}
	if (!base_quest_state.state_boolean["Arena Finished"])
	{
		string [int] modifiers;
		modifiers.listAppend("+ML");
		float percent_done = clampf(get_property_int("flyeredML") / 10000.0 * 100.0, 0.0, 100.0);
		int ml_remaining = 10000 - get_property_int("flyeredML");
		string [int] details;
		if (percent_done >= 100.0)
		{
			modifiers.listClear();
			details.listAppend("Turn in quest.");
		}
		else
		{
			if ($item[jam band flyers].available_amount() == 0 && $item[rock band flyers].available_amount() == 0)
				details.listAppend("Acquire fliers.");
			details.listAppend("Flyer places around the kingdom (" + round(percent_done, 1) + "% ML completed, " + ml_remaining + " ML remains)");
		}
	
        //Normally, this would be bigisland.php?place=concert
        //But that could theoretically complete the quest for the wrong side, if they're wearing the wrong uniform and misclick.
		optional_task_entries.listAppend(ChecklistEntryMake("Island War Arena", "bigisland.php", ChecklistSubentryMake("Island War Arena Quest", modifiers, details)));
		
		if (ml_remaining > 0 && ($item[jam band flyers].available_amount() > 0 || $item[rock band flyers].available_amount() > 0))
		{
			item it = $item[jam band flyers];
			if ($item[rock band flyers].available_amount() > 0 && $item[jam band flyers].available_amount() == 0)
				it = $item[rock band flyers];
			task_entries.listAppend(ChecklistEntryMake(it, "", ChecklistSubentryMake("Flyer with " + it + " every combat", "+ML", details), -11));
		}
	}
}


void QLevel12GenerateBattlefieldDescription(ChecklistSubentry subentry, string side, int enemies_remaining, int enemies_defeated_per_combat, string enemy_name, string enemy_name_plural, string boss_name, string [int] sidequest_list, string [int] base_sidequest_list)
{
    if (enemies_defeated_per_combat == 0)
        return;
    
    int enemies_defeated = 1000 - enemies_remaining;
    string line;
    if (enemies_remaining > 0)
    {
        line = pluralize(enemies_remaining, enemy_name, enemy_name_plural) + " left.";
    }
    else
        line += "Fight " + boss_name + "!";
    int turns_remaining = ceiling(enemies_remaining.to_float() / enemies_defeated_per_combat.to_float());
    if (turns_remaining > 0)
    {
        line += "|*" + pluralize(turns_remaining, "turn", "turns") + " remaining.";
        line += " " + pluralize(enemies_defeated_per_combat, enemy_name, enemy_name_plural) + " defeated per combat.";
    }
    int enemies_to_defeat_for_unlock = -1;
    string area_to_unlock = "";
    string [int] areas_unlocked_but_not_completed;
    
    foreach key in base_sidequest_list
    {
        if (!__quest_state["Level 12"].state_boolean[base_sidequest_list[key] + " Finished"])
        {
            areas_unlocked_but_not_completed.listAppend(base_sidequest_list[key]);
        }
    }
    
    int [int] unlock_threshold;
    unlock_threshold[0] = 64;
    unlock_threshold[1] = 192;
    unlock_threshold[2] = 458;
    
    for i from 2 to 0 by -1
    {
        int threshold = unlock_threshold[i];
        if (!__quest_state["Level 12"].state_boolean[sidequest_list[i] + " Finished"])
        {
            if (enemies_defeated < threshold)
            {
                area_to_unlock = sidequest_list[i];
                enemies_to_defeat_for_unlock = threshold - enemies_defeated;
            }
            else
            {
                areas_unlocked_but_not_completed.listAppend(sidequest_list[i]);
            }
        }
    }
    
    if (enemies_to_defeat_for_unlock != -1)
    {
        int turns_to_reach = ceiling(enemies_to_defeat_for_unlock.to_float() / enemies_defeated_per_combat.to_float());
        line += "|*" + pluralize(turns_to_reach, "turn", "turns") + " (" + pluralize(enemies_to_defeat_for_unlock, enemy_name, enemy_name_plural) + ") to unlock " + area_to_unlock + ".";
    }
    
    if (areas_unlocked_but_not_completed.count() > 0)
        line += "|*Quests accessible: " + areas_unlocked_but_not_completed.listJoinComponents(", ", "and") + ".";
    
    subentry.entries.listAppend(line);
    
    if (enemies_remaining == 0)
    {
        string [int] items_to_turn_in_for;
        if (!__quest_state["Level 13"].finished)
        {
            if (side == "hippy")
                items_to_turn_in_for.listAppend("filthy poultices for shadow");
            else
                items_to_turn_in_for.listAppend("gauze garters for shadow");
        }
        if (!__quest_state["Level 13"].state_boolean["have relevant guitar"] && side == "hippy")
            items_to_turn_in_for.listAppend("massive sitar");
        
        string line2 = "Also, turn in gear to your home camp.";
        if (items_to_turn_in_for.count() > 0)
            line2 += " Acquire " + items_to_turn_in_for.listJoinComponents(", ", "and") + ", etc.";
        subentry.entries.listAppend(line2);
    }
}


void QLevel12GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 12"].in_progress)
		return;
	
	QuestState base_quest_state = __quest_state["Level 12"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
	
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "island.php", subentry, $locations[the battlefield (frat uniform), the battlefield (hippy uniform), wartime frat house, wartime frat house (hippy disguise), wartime hippy camp, wartime hippy camp (frat disguise)]));
	if (base_quest_state.mafia_internal_step < 2)
	{
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Start the war!");
        
        float noncombat_rate = 1.0 - (.85 + combat_rate_modifier() / 100.0);
        float turns_remaining = -1.0;
        if (noncombat_rate != 0.0)
            turns_remaining = 3.0 / noncombat_rate;
        
        
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
		{
            //FIXME suggest routes to doing both.
			subentry.entries.listAppend("Need either the war hippy fatigues or frat warrior fatigues outfit.");
		}
		else
        {
            string [int] stats_needed;
            if (my_basestat($stat[moxie]) < 70)
                stats_needed.listAppend((70 - my_basestat($stat[moxie])) + " more moxie");
            if (my_basestat($stat[mysticality]) < 70)
                stats_needed.listAppend((70 - my_basestat($stat[mysticality])) + " more mysticality");
            if (stats_needed.count() == 0)
                subentry.entries.listAppend("Wear war outfit, run -combat, adventure in other side's camp.");
            else
                subentry.entries.listAppend("Acquire " + stats_needed.listJoinComponents(", ", "and") + " to wear war outfit.");
            
            
            //need 70 moxie, 70 myst
            
        }
        
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(85, 3, "start war"));
	}
	else
	{
		int sides_completed_hippy = 0;
		int sides_completed_frat = 0;
		
		string [int] sidequest_properties = split_string_mutable("sidequestArenaCompleted,sidequestFarmCompleted,sidequestJunkyardCompleted,sidequestLighthouseCompleted,sidequestNunsCompleted,sidequestOrchardCompleted", ",");
		foreach key in sidequest_properties
		{
			string property_value = get_property(sidequest_properties[key]);
			if (property_value == "hippy")
				sides_completed_hippy += 1;
			else if (property_value == "fratboy")
				sides_completed_frat += 1;
		}
		int frat_boys_left = base_quest_state.state_int["frat boys left on battlefield"];
		int hippies_left = base_quest_state.state_int["hippies left on battlefield"];
		
		int frat_boys_defeated_per_combat = powi(2, sides_completed_hippy);
		int hippies_defeated_per_combat = powi(2, sides_completed_frat);
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeCowling") == "Rocket Launcher")
        {
            frat_boys_defeated_per_combat += 3;
            hippies_defeated_per_combat += 3;
        }
        
        
		if (frat_boys_left < 1000 || (frat_boys_left == 1000 && hippies_left == 1000) || sides_completed_hippy > 0)
            QLevel12GenerateBattlefieldDescription(subentry, "hippy", frat_boys_left, frat_boys_defeated_per_combat, "frat boy", "frat boys", "The Man", listMake("Lighthouse", "Junkyard", "Arena"), listMake("Orchard", "Nuns", "Farm"));
            
		if (hippies_left < 1000 || (frat_boys_left == 1000 && hippies_left == 1000) || sides_completed_frat > 0)
            QLevel12GenerateBattlefieldDescription(subentry, "frat boy", hippies_left, hippies_defeated_per_combat, "hippy", "hippies", "The Big Wisniewski", listMake("Orchard", "Nuns", "Farm"), listMake("Lighthouse", "Junkyard", "Arena"));
        
        if (frat_boys_left == 1 && hippies_left == 1)
		{
			if ($item[flaregun].available_amount() > 0)
				subentry.entries.listAppend("Wossname time! Adventure on battlefield, use a flaregun.");
			else if (!in_hardcore())
				subentry.entries.listAppend("Pull a flaregun for wossname.");
			else if (__misc_state["fax accessible"])
				subentry.entries.listAppend("Fax smarmy pirate, run +234% item (or YR) for flaregun for wossname.");
			else
				subentry.entries.listAppend("That almost was a wossname, but you needed more flare.");
		}
        
        item [int] items_to_closet_for_desert_hippy;
        foreach it in $items[reinforced beaded headband,round purple sunglasses,bullet-proof corduroys,beer helmet,distressed denim pants,bejeweled pledge pin]
        {
            if (it.available_amount() == 0)
                continue;
            items_to_closet_for_desert_hippy.listAppend(it);
        }
        
        if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
        {
            string line = "Visit the Arid, Extra-Dry Desert to find a hippy uniform.";
            if (items_to_closet_for_desert_hippy.count() > 0)
                line += "|But first closet " + items_to_closet_for_desert_hippy.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
        }
        //FIXME Add when spaded:
        /*else if (!have_outfit_components("War Hippy Fatigues"))
        {
            string line = "If you want a hippy uniform without visiting the battlefield, adventure in the Arid, Extra-Dry Desert.";
            if (items_to_closet_for_desert_hippy.count() > 0)
                line += "|But first closet " + items_to_closet_for_desert_hippy.listJoinComponents(", ", "and");
            subentry.entries.listAppend(line);
        }*/
        
		QLevel12GenerateTasksSidequests(task_entries, optional_task_entries, future_task_entries);
	}
	
}
Record TFWMInternalModifier
{
    string description;
    boolean have;
    boolean obtainable_now;
    boolean obtainable_theoretically;
    float bonus;
    
    boolean from_familiar_equipment;
};

boolean TFWMInternalModifierEquals(TFWMInternalModifier a, TFWMInternalModifier b)
{
    if (a.description != b.description)
        return false;
    if (a.have != b.have)
        return false;
    if (a.obtainable_now != b.obtainable_now)
        return false;
    if (a.obtainable_theoretically != b.obtainable_theoretically)
        return false;
    if (a.bonus != b.bonus)
        return false;
    if (a.from_familiar_equipment != b.from_familiar_equipment)
        return false;
    return true;
}

TFWMInternalModifier TFWMInternalModifierMake(string description, boolean have, boolean obtainable_now, boolean obtainable_theoretically, float bonus, boolean from_familiar_equipment)
{
    TFWMInternalModifier result;
    result.description = description;
    result.have = have;
    result.obtainable_now = obtainable_now;
    result.obtainable_theoretically = obtainable_theoretically;
    result.bonus = bonus;
    result.from_familiar_equipment = from_familiar_equipment;
    
    return result;
}

TFWMInternalModifier TFWMInternalModifierMake(string description, boolean have, boolean obtainable_now, boolean obtainable_theoretically, float bonus)
{
    return TFWMInternalModifierMake(description, have, obtainable_now, obtainable_theoretically, bonus, false);
}

TFWMInternalModifier TFWMInternalModifierMake()
{
    return TFWMInternalModifierMake("", false, false, false, 0);
}

TFWMInternalModifier TFWMInternalModifierMake(skill s)
{
    effect e = s.to_effect();
    string description = s;
    if (e != $effect[none] && e.have_effect() == 0)
        description += " (cast)";
    
    float weight_modifier = 0.0;
    if (e != $effect[none])
        weight_modifier = e.numeric_modifier("familiar weight");
    else
        weight_modifier = s.numeric_modifier("familiar weight");
    
    return TFWMInternalModifierMake(description, s.have_skill(), s.have_skill(), s.have_skill(), weight_modifier);
}

TFWMInternalModifier TFWMInternalModifierMake(item equippable_item)
{
    if (equippable_item.available_amount() == 0)
        return TFWMInternalModifierMake();
    float weight_modifier = equippable_item.numeric_modifier("familiar weight");
    
    if (equippable_item == $item[crown of thrones])
        weight_modifier = 5.0;
    
    
    string description = equippable_item;
    if (equippable_item.equipped_amount() == 0)
        description += " (equip)";
    
    TFWMInternalModifier result = TFWMInternalModifierMake(description, true, true, true, weight_modifier);
    
    if (equippable_item.to_slot() == $slot[familiar])
        result.from_familiar_equipment = true;
    return result;
}

void listAppend(TFWMInternalModifier [int] list, TFWMInternalModifier entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


//Returns TRUE if they currently have, or can easily have, enough to pass.
boolean generateTowerFamiliarWeightMethod(string [int] how, string [int] immediately_obtainable, string [int] missing_potentials, FloatHandle missing_weight)
{
    missing_weight.f = 0.0;
    if (__quest_state["Level 13"].mafia_internal_step > 9) //no need
        return true;
    if (!__misc_state["In run"])
        return true;
    if (__misc_state["familiars temporarily blocked"])
        return true;
    
    
    //Not the best of solutions, but...
    
    TFWMInternalModifier [int] weight_modifiers;
    
    //amphibian sympathy
    weight_modifiers.listAppend(TFWMInternalModifierMake($skill[amphibian sympathy]));
    //leash of linguini
    weight_modifiers.listAppend(TFWMInternalModifierMake($skill[leash of linguini]));
    //empathy of the newt
    weight_modifiers.listAppend(TFWMInternalModifierMake($skill[empathy of the newt]));
    //knob goblin pet-buffing spray
    if ($item[knob goblin pet-buffing spray].available_amount() > 0 || dispensary_available() || $effect[heavy petting].have_effect() > 0)
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("knob goblin pet-buffing spray", true, true, true, 5.0));
    }
    else if (__misc_state["can equip just about any weapon"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("knob goblin pet-buffing spray (unlock cobb's knob dispensary)", false, false, true, 5.0));
    }
    //hippy concert
    if (get_property("sidequestArenaCompleted") == "hippy" && !get_property_boolean("concertVisited") || $effect[Optimist Primal].have_effect() > 0)
    {
        boolean have_effect = $effect[Optimist Primal].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("Optimist Primal (hippy concert)", have_effect, have_effect || !get_property_boolean("concertVisited"), true, 5.0));
    }
    //irradiated pet snacks
    if ($item[irradiated pet snacks].available_amount() > 0 || $effect[healthy green glow].have_effect() > 0)
    {
        boolean have_effect = $effect[healthy green glow].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("irradiated pet snacks", have_effect, true, true, 10.0));
    }
    else if (__misc_state["can eat just about anything"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("irradiated pet snacks (semi-rare, menagerie level 2)", false, false, true, 10.0));
    }
    //billiards
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 || $effect[Billiards Belligerence].have_effect() > 0)
    {
        boolean have_effect = $effect[Billiards Belligerence].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("VIP Pool (play aggressively)", have_effect, have_effect || (get_property_int("_poolGames") <3), true, 5.0));
    }
    //tea party
    if (($item[&quot;DRINK ME&quot; potion].available_amount() > 0 || $effect[Down the Rabbit Hole].have_effect() > 0) && (!get_property_boolean("_madTeaParty") || $effect[You Can Really Taste the Dormouse].have_effect() > 0))
    {
        boolean have_effect = $effect[You Can Really Taste the Dormouse].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("Mad hatter (reinforced beaded headband)", have_effect, have_effect, true, 5.0));
    }
    //beastly paste
    if ($item[beastly paste].available_amount() > 0 || $effect[Beastly Flavor].have_effect() > 0)
    {
        boolean have_effect = $effect[Beastly Flavor].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("beastly paste (4 spleen)", have_effect, true, true, 3.0));
    }
    else if ($familiar[pair of stomping boots].familiar_is_usable())
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("beastly paste (4 spleen, stomp beasts)", false, false, true, 3.0));
    }
    //resolution
    if ($item[resolution: be kinder].available_amount() > 0 || $effect[Kindly Resolve].have_effect() > 0)
    {
        boolean have_effect = $effect[Kindly Resolve].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("resolution: be kinder", have_effect, true, true, 5.0));
    }
    else if ($skill[summon resolutions].have_skill() && __misc_state["bookshelf accessible"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("resolution: be kinder (summon)", false, false, true, 5.0));
    }
    //green candy heart
    if ($item[green candy heart].available_amount() > 0 || $effect[Heart of Green].have_effect() > 0)
    {
        boolean have_effect = $effect[Heart of Green].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("green candy heart", have_effect, true, true, 3.0));
    }
    else if ($skill[Summon Candy Hearts].have_skill() && __misc_state["bookshelf accessible"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("green candy heart (summon)", false, false, true, 3.0));
    }
    
    //sugar sheet, sugar shield
    if ($item[astral pet sweater].available_amount() == 0 && ($item[snow suit].available_amount() == 0 || $item[snow suit].numeric_modifier("familiar weight") < 10.0))
    {
        if ($item[sugar shield].available_amount() > 0)
            weight_modifiers.listAppend(TFWMInternalModifierMake($item[sugar shield]));
        else if ($item[sugar sheet].available_amount() > 0)
        {
            weight_modifiers.listAppend(TFWMInternalModifierMake("sugar shield (use sugar sheet)", false, true, true, 10.0, true));
        }
        else if ($skill[Summon Sugar Sheets].have_skill() && __misc_state["bookshelf accessible"])
        {
            //TFWMInternalModifier TFWMInternalModifierMake(string description, boolean have, boolean obtainable_now, boolean obtainable_theoretically, float bonus)
            weight_modifiers.listAppend(TFWMInternalModifierMake("sugar shield (summon sugar sheet)", false, false, true, 10.0, true));
        }
    }
    //ittah bittah hookah
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[ittah bittah hookah]));
    //lead necklace
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[lead necklace]));
    //snow suit - numeric_modifier($item[snow suit], "familiar weight")
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[snow suit]));
    //astral pet sweater
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[astral pet sweater]));
    
    //greaves of the whatever
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[greaves of the murk lord]));
    //furry halo
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[furry halo]));
    //CoT, if they have the right familiars
    if ($familiars[Animated Macaroni Duck, Autonomous Disco Ball, Barrrnacle, Gelatinous Cubeling, Ghost Pickle on a Stick, Misshapen Animal Skeleton, Pair of Ragged Claws, Penguin Goodfella, Spooky Pirate Skeleton].have_familiar_replacement())
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake($item[crown of thrones]));
    }
    
    
    //Find best familiar equipment:
    TFWMInternalModifier best_familiar_equipment;
    foreach key in weight_modifiers
    {
        TFWMInternalModifier modifier = weight_modifiers[key];
        if (modifier.have && modifier.from_familiar_equipment)
        {
            if (modifier.bonus > best_familiar_equipment.bonus)
                best_familiar_equipment = modifier;
        }
    }
    
    float total = 0.0;
    foreach key in weight_modifiers
    {
        TFWMInternalModifier modifier = weight_modifiers[key];
        string description = modifier.description;
        description += " (+" + modifier.bonus.floor() + ")";
        if (modifier.have)
        {
            if (best_familiar_equipment.have && modifier.from_familiar_equipment && !TFWMInternalModifierEquals(best_familiar_equipment, modifier)) //not our chosen familiar equipment
                continue;
            how.listAppend(description);
            total += modifier.bonus;
        }
        else if (modifier.obtainable_now)
        {
            immediately_obtainable.listAppend(description);
        }
        else if (modifier.obtainable_theoretically)
        {
            missing_potentials.listAppend(description);
        }
        
    }
    missing_weight.f = MAX(0, 19 - total);
    
    if (numeric_modifier("familiar weight") >= 19.0)
        return true;
    if (total >= 19.0)
        return true;
    else
        return false;
}

boolean needMoreFamiliarWeightForTower()
{
    string [int] how;
    string [int] immediately_obtainable;
    string [int] missing_potentials;
    FloatHandle missing_weight;
    return !generateTowerFamiliarWeightMethod(how, immediately_obtainable, missing_potentials, missing_weight);
}


void QLevel13Init()
{
	//questL13Final
    
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL13Final");
    if (my_path_id() == PATH_BUGBEAR_INVASION)
        QuestStateParseMafiaQuestPropertyValue(state, "finished"); //never will start
	state.quest_name = "Naughty Sorceress Quest";
	state.image_name = "naughty sorceress lair";
	state.council_quest = true;
	//alternate idea: gate, mirror, stone mariachis, courtyard, tower... hmm, no
	
	state.state_boolean["past gates"] = (state.mafia_internal_step > 1);
	state.state_boolean["past keys"] = (state.mafia_internal_step > 3);
	state.state_boolean["past tower"] = (state.mafia_internal_step > 5);
	state.state_boolean["shadow will need to be defeated"] = !(state.mafia_internal_step < 9);
    //FIXME what paths don't fight the shadow?
    
	state.state_boolean["king waiting to be freed"] = (state.mafia_internal_step == 11);
    
    
	state.state_boolean["have relevant guitar"] = $items[acoustic guitarrr,heavy metal thunderrr guitarrr,stone banjo,Disco Banjo,Shagadelic Disco Banjo,Seeger's Unstoppable Banjo,Massive sitar,4-dimensional guitar,plastic guitar,half-sized guitar,out-of-tune biwa,Zim Merman's guitar,dueling banjo].available_amount() > 0;
    
	state.state_boolean["have relevant accordion"] = $items[stolen accordion,calavera concertina,Rock and Roll Legend,Squeezebox of the Ages,The Trickster's Trikitixa,toy accordion].available_amount() > 0;
	state.state_boolean["have relevant drum"] = $items[tambourine, big bass drum, black kettle drum, bone rattle, hippy bongo, jungle drum].available_amount() > 0;
    
    if (state.state_boolean["past keys"])
    {
        state.state_boolean["have relevant guitar"] = true;
        
        state.state_boolean["have relevant accordion"] = true;
        state.state_boolean["have relevant drum"] = true;
    }
	state.state_boolean["digital key used"] = state.state_boolean["past keys"]; //FIXME be finer-grained?
    
    boolean other_quests_completed = true;
    for i from 2 to 12
    {
        if (!__quest_state["Level " + i].finished)
            other_quests_completed = false;
    }
    if (other_quests_completed && my_level() >= 13)
        state.startable = true;
    
	
	__quest_state["Level 13"] = state;
	__quest_state["Lair"] = state;
}


void QLevel13GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 13"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 13"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "lair.php";
	
	string image_name = base_quest_state.image_name;
    
	boolean should_output_main_entry = true;
	if (base_quest_state.mafia_internal_step == 1)
	{
		//at three gates
		subentry.entries.listAppend("At three gates.");
        if (__misc_state["can use clovers"] && (availableDrunkenness() >= 3 || inebriety_limit() == 0))
        {
            //FIXME be better
            if ($items[large box,blessed large box].available_amount() == 0 && $items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() > 0)
            {
                if (in_hardcore())
                    subentry.entries.listAppend("For potions, acquire a large box (fax, dungeons of doom) and meatpaste with a clover.");
                else
                    subentry.entries.listAppend("For potions, pull a large box and meatpaste with a clover.");
            }
        }
        else
            subentry.entries.listAppend("For potions, visit the dungeons of doom.");
        url = "lair1.php";
	}
	else if (base_quest_state.mafia_internal_step == 2)
	{
		//past three gates, at mirror
		subentry.entries.listAppend("At mirror.");
        url = "lair1.php";
	}
	else if (base_quest_state.mafia_internal_step == 3)
	{
		//past mirror, at six keys
		subentry.entries.listAppend("Six keys.");
        url = "lair2.php";
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
        url = "lair3.php";
		//at hedge maze
		subentry.modifiers.listAppend("+67% item");
		subentry.entries.listAppend("Hedge maze. Find puzzles.");
		if (item_drop_modifier() < 66.666666667)
			subentry.entries.listAppend("Need more +item.");
        if ($item[hedge maze key].available_amount() == 0)
			subentry.entries.listAppend("Find the key.");
        else
			subentry.entries.listAppend("Find the way out.");
            
            
        monster pickpocket_monster = $monster[Topiary Golem];
        if (__misc_state["can pickpocket"] && pickpocket_monster != $monster[none])
        {
            int total_initiative_needed = pickpocket_monster.base_initiative;
            int initiative_needed = total_initiative_needed - initiative_modifier();
            if (initiative_needed > 0)
                subentry.entries.listAppend("Need " + initiative_needed + "% more initiative to pickpocket every turn.");
        }
		
	}
	else if (base_quest_state.mafia_internal_step == 5)
	{
		//at tower, time to kill monsters!
		subentry.entries.listAppend("Tower monsters.");
		//FIXME show levels and... um... all that
	}
	else if (base_quest_state.mafia_internal_step == 6)
	{
        url = "lair6.php";
		//past tower, at some sort of door code
		subentry.entries.listAppend("Puzzles.");
		subentry.entries.listAppend("Have mafia do it: Quests" + __html_right_arrow_character + "Tower (to shadow)");
	}
	else if (base_quest_state.mafia_internal_step == 7 || base_quest_state.mafia_internal_step == 8)
	{
        url = "lair6.php";
		//at top of tower (fight shadow??)
		//8 -> fight shadow
		subentry.modifiers.listAppend("+HP");
		subentry.modifiers.listAppend("+" + $monster[Your Shadow].monster_initiative() + "% init");
		subentry.entries.listAppend("Fight your shadow.");
        foreach it in $items[attorney's badge, navel ring of navel gazing]
        {
            if (it.available_amount() > 0 && it.equipped_amount() == 0)
                subentry.entries.listAppend("Possibly equip your " + it + ". (blocks shadow)");
        }
	}
	else if (base_quest_state.mafia_internal_step == 9)
	{
        url = "lair6.php";
		//counter familiars
        
        if (!__misc_state["familiars temporarily blocked"])
        {
            subentry.modifiers.listAppend("+familiar weight");
            subentry.entries.listAppend("Counter familiars. Need 20-pound familiars.");
            subentry.entries.listAppend("Have mafia do it: Quests" + __html_right_arrow_character + "Tower (complete)");
            familiar [int] missing_familiars;
            foreach f in $familiars[Mosquito,Angry Goat,Barrrnacle,Sabre-Toothed Lime,Levitating Potato]
            {
                if (f.have_familiar_replacement())
                    continue;
                missing_familiars.listAppend(f);
            }
            if (missing_familiars.count() > 0)
            {
                string [item] where_to_find_hatchlings;
                where_to_find_hatchlings[$item[mosquito larva]] = "Spooky forest."; //should have it
                where_to_find_hatchlings[$item[goat]] = "Combine goat cheese (goatlet, dairy goat, 40% drop) with anti-cheese from the atomic testing house in the desert beach.";
                where_to_find_hatchlings[$item[barrrnacle]] = "Find from a crusty pirate in the f'c'le. (15% drop)";
                where_to_find_hatchlings[$item[sabre-toothed lime cub]] = "Combine saber teeth (goatlet, sabre-toothed goat, 5% drop, or stone age hippy camp, 20% drop) with a lime. (Menagerie level 1, fruit golem, 15% drop)";
                where_to_find_hatchlings[$item[potato sprout]] = "Complete the daily dungeon, visit vending machine.";
                if (in_bad_moon())
                    where_to_find_hatchlings[$item[potato sprout]] += " Alternatively, adventure in the haunted conservatory.";
                    
                string [int] missing_description;
                foreach key in missing_familiars
                {
                    familiar f = missing_familiars[key];
                    
                    string line;
                    if (missing_description.count() > 0)
                        line += "<hr>";
                    line += f.hatchling.capitalizeFirstLetter();
                    if (f.hatchling.available_amount() > 0)
                    {
                        line += "|*Use your " + f.hatchling + ".";
                    }
                    else
                    {
                        line += "|*" + where_to_find_hatchlings[f.hatchling];
                    }
                    missing_description.listAppend(line);
                }
                subentry.entries.listAppend("Missing familiars: " + HTMLGenerateIndentedText(missing_description));
            }
            
            FloatHandle missing_weight;
            string [int] familiar_weight_how;
            string [int] familiar_weight_immediately_obtainable;
            string [int] familiar_weight_missing_potentials;
            boolean have_familiar_weight_for_tower = generateTowerFamiliarWeightMethod(familiar_weight_how, familiar_weight_immediately_obtainable, familiar_weight_missing_potentials,missing_weight);
            if (!have_familiar_weight_for_tower)
            {
                string [int] description;
                description.listAppend("Need +" + missing_weight.f.floor() + " familiar weight.");
                if (familiar_weight_how.count() > 0)
                    description.listAppend("Have " + familiar_weight_how.listJoinComponents(", ", "and") + ".");
                if (familiar_weight_immediately_obtainable.count() > 0)
                    description.listAppend("Could use " + familiar_weight_immediately_obtainable.listJoinComponents(", ", "and") + ".");
                if (familiar_weight_missing_potentials.count() > 0 && missing_weight.f > 0.0)
                    description.listAppend("Could acquire " + familiar_weight_missing_potentials.listJoinComponents(", ", "or") + ".");
                
                subentry.entries.listAppend(description.listJoinComponents("|*"));
            }
        }
        else
            subentry.entries.listAppend("Counter familiars.");
	}
	else if (base_quest_state.mafia_internal_step == 10)
	{
        url = "lair6.php";
		//At NS. Good luck, we're all counting on you.
		subentry.modifiers.listAppend("+moxie equipment");
		subentry.modifiers.listAppend("no buffs");
		subentry.entries.listAppend("She awaits.");
		if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[swashbuckling pants].available_amount() > 0)
			subentry.entries.listAppend("Run swashbuckling pants on scarecrow. (2x potato)");
		else if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0)
			subentry.entries.listAppend("Run spangly mariachi pants on scarecrow. (2x potato)");
		else if (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0)
			subentry.entries.listAppend("Run spangly sombrero on mad hatrack. (2x potato)");
		else
			subentry.entries.listAppend("Run a potato familiar if you can.");
			
		image_name = "naughty sorceress";
	}
	else if (base_quest_state.mafia_internal_step == 11)
	{
        url = "lair6.php";
		//King is waiting in his prism.
		task_entries.listAppend(ChecklistEntryMake("__item puzzling trophy", "trophy.php", ChecklistSubentryMake("Check for trophies", "10k meat, trophy requirements", "Certain trophies are missable after freeing the king")));
		should_output_main_entry = false;
		
	}
	if (should_output_main_entry)
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry));
}

void QManorInit()
{
	QuestState state;
	if (locationAvailable($location[the haunted ballroom]) && __misc_state_string["ballroom song"] == "-combat")
		QuestStateParseMafiaQuestPropertyValue(state, "finished");
	else
    {
		QuestStateParseMafiaQuestPropertyValue(state, "started");
    }
	state.quest_name = "Spookyraven Manor Unlock";
	state.image_name = "Spookyraven Manor";
	
	location zone_to_work_on = $location[none];
	if (!locationAvailable($location[the haunted billiards room]))
	{
		zone_to_work_on = $location[the haunted billiards room];
	}
	else if (!locationAvailable($location[the haunted library]))
	{
		zone_to_work_on = $location[the haunted library];
	}
	else if (!locationAvailable($location[the haunted bedroom]))
	{
		zone_to_work_on = $location[the haunted bedroom];
	}
	else if (!locationAvailable($location[the haunted ballroom]))
	{
		zone_to_work_on = $location[the haunted ballroom];
	}
	else if (__misc_state_string["ballroom song"] != "-combat")
	{
	}
	state.state_string["zone to work on"] = zone_to_work_on;
	
	__quest_state["Manor Unlock"] = state;
}


void QManorGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Manor Unlock"].in_progress)
		return;
    if (!__misc_state["In run"])
        return;
	QuestState base_quest_state = __quest_state["Manor Unlock"];
	ChecklistSubentry subentry;
	//subentry.header = "Unlock Spookyraven Manor";
	
	string url = "";
	
	string image_name = base_quest_state.image_name;
	
	location next_zone = to_location(base_quest_state.state_string["zone to work on"]);
	
	
	if (next_zone == $location[the haunted billiards room])
	{
		subentry.header = "Open the Haunted Billiards Room";
		url = "place.php?whichplace=town_right";
		image_name = "spookyraven manor locked";
		
		subentry.entries.listAppend("Adventure in the Haunted Pantry. (right side of the tracks)");
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			
		if (have_skill($skill[summon smithsness]) && $item[dirty hobo gloves].available_amount() == 0 && $item[hand in glove].available_amount() == 0 && __misc_state["Need to level"])
		{
			subentry.modifiers.listAppend("-combat");
			subentry.modifiers.listAppend("+234% item");
			subentry.entries.listAppend("Run +234% item and -combat for dirty hobo glove, for hand in glove. (+lots ML accessory)|Potentially olfact half-orc hobo as well, to find said glove in the back alley.");
		}
			
		if (subentry.modifiers.count() > 0)
			subentry.entries.listAppend("Ten turn delay. (use " + listJoinComponents(subentry.modifiers, ", ") + ")");
		else
			subentry.entries.listAppend("Ten turn delay.");
        
        
        if ($classes[pastamancer, sauceror] contains my_class() && !guild_store_available()) //FIXME tracking guild quest being started
            subentry.entries.listAppend("Possibly start your guild quest if you haven't.");
		
	}
	else if (next_zone == $location[the haunted library])
	{
		subentry.header = "Open the Haunted Library";
		url = "place.php?whichplace=spookyraven1";
		image_name = "haunted billiards room";
		
		if (__misc_state["free runs available"])
			subentry.modifiers.listAppend("free runs");
		
		
		subentry.entries.listAppend("Adventure in the Haunted Billiards Room.");
		if ($item[pool cue].available_amount() == 0)
			subentry.entries.listAppend("Acquire a pool cue. (superlikely)");
		if (delayRemainingInLocation($location[the haunted billiards room]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the haunted billiards room]), "turn", "turns") + ".";
			if (__misc_state["have hipster"])
			{
				line += " (use " + __misc_state_string["hipster name"] + ")";
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
			subentry.entries.listAppend(line);
			subentry.entries.listAppend("Then run chalky hands once you have a pool cue. (use handful of hand chalk, 100% wraith drop)");
		}
		else if ($item[pool cue].available_amount() == 0)
			subentry.entries.listAppend("Run chalky hand and -combat once you have a pool cue. (use handful of hand chalk, 100% wraith drop)");
        else
        {
            if ($effect[chalky hand].have_effect() == 0)
                subentry.entries.listAppend("Run chalky hand. (use handful of hand chalk, 100% wraith drop)");
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat.");
            
            float nc_rate = 1.0 - (0.75 + combat_rate_modifier() / 100.0);
            float turns_to_finish = -1.0;
            if (nc_rate != 0.0)
                turns_to_finish = 1.0 / nc_rate;
            if (turns_to_finish != -1.0)
                subentry.entries.listAppend("~" + turns_to_finish.roundForOutput(1) + " turns to unlock at " + combat_rate_modifier().floor() + "% combat.");
        }
	}
	else if (next_zone == $location[the haunted bedroom])
	{
		subentry.header = "Open the Haunted Bedroom";
		url = "place.php?whichplace=spookyraven1";
		image_name = "haunted library";

        
		subentry.entries.listAppend("Adventure in the Haunted Library.");
		if (delayRemainingInLocation($location[the haunted library]) > 0)
		{
			string line = "Delay for " + pluralize(delayRemainingInLocation($location[the haunted library]), "turn", "turns") + ".";
			if (__misc_state["have hipster"])
			{
				line += " (use " + __misc_state_string["hipster name"] + ")";
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
			line += "|Then run -combat.";
			subentry.entries.listAppend(line);
		}
		else
		{
			subentry.modifiers.listAppend("-combat");
			subentry.entries.listAppend("Run -combat.");
            
            float nc_rate = 1.0 - (0.75 + combat_rate_modifier() / 100.0);
            float turns_to_finish = -1.0;
            if (nc_rate != 0.0)
                turns_to_finish = 1.0 / nc_rate;
            if (turns_to_finish != -1.0)
                subentry.entries.listAppend("~" + turns_to_finish.roundForOutput(1) + " turns to unlock at " + combat_rate_modifier().floor() + "% combat.");
		}
		
		if (my_primestat() == $stat[muscle] && !locationAvailable($location[the haunted gallery]) && !__misc_state["Stat gain from NCs reduced"])
			subentry.entries.listAppend("Optionally, unlock gallery key conservatory adventure:|*Fall of the House of Spookyraven" + __html_right_arrow_character + "Chapter 2: Stephen and Elizabeth.");
	}
	else if (next_zone == $location[the haunted ballroom])
	{
		subentry.header = "Open the Haunted Ballroom";
		url = "place.php?whichplace=spookyraven2";
		image_name = "haunted bedroom";
		subentry.entries.listAppend("Adventure in the Haunted Bedroom.");
		
		if ($item[lord spookyraven's spectacles].available_amount() == 0)
			subentry.entries.listAppend("Acquire Lord Spookyraven's spectacles from ornate drawer NC.");
        //FIXME uncomment when test available:
        if (/*__quest_state["Level 11 Palindome"].state_boolean["Need instant camera"] &&*/ 7266.to_item().available_amount() == 0)
			subentry.entries.listAppend("Possibly acquire disposable instant camera from ornate drawer NC.");
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Run -combat.");
        
        //I think this is what lastBallroomUnlock does? It's when the key has dropped down?
        boolean clink_done = get_property_int("lastBallroomUnlock") == my_ascensions();
        if (clink_done)
            subentry.entries.listAppend("Unlock ballroom key. Wooden nightstand, third choice.");
        else
            subentry.entries.listAppend("Unlock ballroom key in two-step process. Wooden nightstand, first choice, then third.");
		
		//combat queue for haunted bedroom doesn't seem to update
        int delay_remaining = 5; //delayRemainingInLocation($location[the haunted bedroom])
		if (delay_remaining > 0 && !clink_done)
		{
			//string line = "Delay for " + pluralize(delay_remaining), "turn", "turns") + ".";
            string line = "Delay for 5 total turns. (can't track this, sorry)";
			if (__misc_state["have hipster"])
			{
				line += " (use " + __misc_state_string["hipster name"] + ")";
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
			subentry.entries.listAppend(line);
		}
        //Once delay is tracked:
        /*int ncs_needed = 4;
        if (!clink_done)
            ncs_needed *= 2;
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(20, ncs_needed, "", 0, delay_remaining));*/
	}
	else if (__misc_state_string["ballroom song"] != "-combat")
	{
		next_zone = $location[The Haunted Ballroom];
		subentry.header = "Set -combat ballroom song";
		url = "place.php?whichplace=spookyraven2";
		image_name = "Haunted Ballroom";
		subentry.modifiers.listAppend("-combat");
        
        if (my_turncount() > 200)
            subentry.entries.listAppend("Well, unless you won't need -combat.");
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 2, ""));
	}
	
	if (next_zone != $location[none])
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the haunted pantry, the haunted library, the haunted billiards room, the haunted bedroom, the haunted ballroom]));
}

void QPirateInit()
{
	//questM12Pirate ?
	//lastPirateInsult1 through lastPirateInsult8
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questM12Pirate");
	state.quest_name = "Pirate Quest";
	state.image_name = "pirate quest";
	
	if (__misc_state["mysterious island available"])
	{
		state.startable = true;
		if (!state.in_progress && !state.finished)
		{
			QuestStateParseMafiaQuestPropertyValue(state, "started");
		}
	}
    
    
	boolean hot_wings_relevant = knoll_available() || $item[frilly skirt].available_amount() > 0;
    if (state.mafia_internal_step >= 4) //done that already
        hot_wings_relevant = false;
	boolean need_more_hot_wings = $item[hot wing].available_amount() <3 && hot_wings_relevant;
    
    state.state_boolean["hot wings relevant"] = hot_wings_relevant;
    state.state_boolean["need more hot wings"] = need_more_hot_wings;
    
    
	//Certain characters are in weird states, I think?
    if ($item[pirate fledges].available_amount() > 0 || $item[talisman o' nam].available_amount() > 0)
        QuestStateParseMafiaQuestPropertyValue(state, "finished");
	__quest_state["Pirate Quest"] = state;
}


void QPirateGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Pirate Quest"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Pirate Quest"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "";
    
	boolean have_outfit = have_outfit_components("Swashbuckling Getup");
	if ($item[pirate fledges].available_amount() > 0)
		have_outfit = true;
	int insult_count = 0;
	for i from 1 to 8
	{
		if (get_property_boolean("lastPirateInsult" + i))
			insult_count += 1;
	}
	
	float [int] insult_success_likelyhood;
	//haven't verified these numbers, need to double-check
	insult_success_likelyhood[0] = 0.0;
	insult_success_likelyhood[1] = 0.0;
	insult_success_likelyhood[2] = 0.0;
	insult_success_likelyhood[3] = 0.0179;
	insult_success_likelyhood[4] = 0.071;
	insult_success_likelyhood[5] = 0.1786;
	insult_success_likelyhood[6] = 0.357;
	insult_success_likelyhood[7] = 0.625;
	insult_success_likelyhood[8] = 1.0;
	
    boolean delay_for_future = false;
	
	if (!have_outfit)
	{
        url = "island.php";
		string line = "Acquire outfit.";
		
		item [int] outfit_pieces = outfit_pieces("Swashbuckling Getup");
		item [int] outfit_pieces_needed;
		foreach key in outfit_pieces
		{
			item piece = outfit_pieces[key];
			if (piece.available_amount() == 0)
				outfit_pieces_needed.listAppend(piece);
		}
		line += " Need " + outfit_pieces_needed.listJoinComponents(", ", "and") + ".";
		subentry.entries.listAppend(line);
		
		subentry.modifiers.listAppend("+item");
		subentry.modifiers.listAppend("-combat");
        int ncs_relevant = 0; //out of six
        if ($item[stuffed shoulder parrot].available_amount() == 0 || $item[eyepatch].available_amount() == 0)
            ncs_relevant += 1;
        if ($item[eyepatch].available_amount() == 0 || $item[swashbuckling pants].available_amount() == 0)
            ncs_relevant += 1;
        if ($item[swashbuckling pants].available_amount() == 0 || $item[stuffed shoulder parrot].available_amount() == 0)
            ncs_relevant += 1;
        
        float average_combat_rate = clampNormalf(.6 + combat_rate_modifier() / 100.0);
        float average_nc_rate = 1.0 - average_combat_rate;
        
        float average_useful_nc_rate = average_nc_rate * (ncs_relevant.to_float() / 6.0);
        //FIXME make this more accurate
        float turns_remaining = -1.0;
        if (average_useful_nc_rate != 0.0)
            turns_remaining = outfit_pieces_needed.count().to_float() / average_useful_nc_rate;
		subentry.entries.listAppend("Run -combat in the obligatory pirate's cove." + "|~" + turns_remaining.roundForOutput(1) + " turns remain at " + combat_rate_modifier().floor() + "% combat.");
        
        if (__misc_state_string["ballroom song"] != "-combat")
        {
            subentry.entries.listAppend(HTMLGenerateSpanOfClass("Wait until -combat ballroom song set.", "r_bold"));
            delay_for_future = true;
        }
	}
	else
	{
        url = "place.php?whichplace=cove";
        
        if (!is_wearing_outfit("Swashbuckling Getup") && $item[pirate fledges].equipped_amount() == 0)
            url = "inventory.php?which=2";
        
		if (base_quest_state.mafia_internal_step == 1)
		{
			//caronch gave you a map
			if ($item[Cap'm Caronch's nasty booty].available_amount() == 0 && $item[Cap'm Caronch's Map].available_amount() > 0)
			{
                url = "inventory.php?which=3";
				subentry.entries.listAppend("Use Cap'm Caronch's Map, fight a booty crab.");
				subentry.entries.listAppend("Possibly run +meat. (300 base drop)");
                subentry.modifiers.listAppend("+meat");
			}
			else if (have_outfit)
				subentry.entries.listAppend("Find Cap'm Caronch in Barrrney's Barrr.");
		}
		else if (base_quest_state.mafia_internal_step == 2)
		{
			//give booty back to caronch
			subentry.entries.listAppend("Find Cap'm Caronch in Barrrney's Barrr.");
		}
		else if (base_quest_state.mafia_internal_step == 3)
		{
			//have blueprints, catburgle
			string line = "Use the Orcish Frat House blueprints";
			if (insult_count < 6)
				line += ", once you have at least six insults"; //in certain situations five might be slightly faster? but that skips a lot of combats, so probably not
			line += ".";
			
            string method;
			if (have_outfit_components("Frat Boy Ensemble") && __misc_state["can equip just about any weapon"])
			{
				string [int] todo;
				if (!is_wearing_outfit("Frat Boy Ensemble"))
					todo.listAppend("wear frat boy ensemble");
				todo.listAppend("attempt a frontal assault");
				method = todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".";
			}
			else if ($item[mullet wig].available_amount() > 0 && $item[briefcase].available_amount() > 0)
			{
				string [int] todo;
				if ($item[mullet wig].equipped_amount() == 0)
					todo.listAppend("wear mullet wig");
				todo.listAppend("go in through the side door");
				method = todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".";
			}
			else if (knoll_available() || $item[frilly skirt].available_amount() > 0)
			{
				string [int] todo;
                if (insult_count < 6)
                    todo.listAppend("acquire at least six insults");
				if ($item[hot wing].available_amount() <3 )
					todo.listAppend("acquire " + pluralize((3 - $item[hot wing].available_amount()), "more hot wing", "more hot wings"));
				if ($item[frilly skirt].equipped_amount() == 0)
					todo.listAppend("wear frilly skirt");
				todo.listAppend("catburgle");
                string line2 = todo.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".";
				method = line2;
			}
			else
			{
				method = "Not sure how to approach this efficiently, sorry.";
			}
            line += "|" + method;
			subentry.entries.listAppend(line);
		}
		else if (base_quest_state.mafia_internal_step == 4)
		{
			//acquired teeth, give them back
			subentry.entries.listAppend("Find Cap'm Caronch in Barrrney's Barrr. (next adventure)");
		}
		else if (base_quest_state.mafia_internal_step == 5)
		{
			//ricketing
			subentry.entries.listAppend("Play beer pong.");
			subentry.entries.listAppend("If you want more insults now, adventure in the Obligatory Pirate's Cove, not in the Barrr.");
		}
		else if (base_quest_state.mafia_internal_step == 6)
		{
			//f'c'le
			//We can't tell them which ones they need, precisely, since they may have already used them.
			//We can tell them which ones they have... but it's still unreliable. I guess a single message if they have all three?
			string line = "F'c'le.";
			string additional_line = "";
            
            item [int] missing_washing_items = $items[rigging shampoo,mizzenmast mop,ball polish].items_missing();
            
			if (missing_washing_items.count() == 0)
            {
                url = "inventory.php?which=3";
				line += " " + HTMLGenerateSpanFont("Use rigging shampoo, mizzenmast mop, and ball polish", "red", "") + ", then adventure to complete quest.";
            }
			else
			{
                subentry.modifiers.listAppend("+234% item");
                subentry.modifiers.listAppend("+combat");
				line += " Run +234% item, +combat, and collect " + missing_washing_items.listJoinComponents(", ", "and") + ".";
				if (item_drop_modifier() < 234.0)
					additional_line = "This location can be a nightmare without +234% item.";
			}
            
			subentry.entries.listAppend(line);
			if (additional_line != "")
				subentry.entries.listAppend(additional_line);
            if (!$monster[clingy pirate].is_banished() && $item[cocktail napkin].available_amount() > 0)
                subentry.entries.listAppend("Use cocktail napkin on clingy pirate to free run/banish.");
		}
	}
	boolean should_output_insult_data = false;
	if ($item[the big book of pirate insults].available_amount() > 0 || have_outfit)
		should_output_insult_data = true;
	if (base_quest_state.mafia_internal_step >= 6)
		should_output_insult_data = false;
		
	if (should_output_insult_data)
	{
		string line = "At " + pluralize(insult_count, "insult", "insults") + ". " + roundForOutput(insult_success_likelyhood[insult_count] * 100, 1) + "% chance of beer pong success.";
		if (insult_count < 8)
			line += "|Insult every pirate with the big book of pirate insults.";
		subentry.entries.listAppend(line);
	}
	if ($item[the big book of pirate insults].available_amount() == 0 && base_quest_state.mafia_internal_step < 6 && have_outfit)
		subentry.entries.listAppend(HTMLGenerateSpanFont("Buy the big book of pirate insults.", "red", ""));
	
	if (!is_wearing_outfit("Swashbuckling Getup") && have_outfit)
    {
        string [int] stats_needed;
        if (my_basestat($stat[moxie]) < 25)
            stats_needed.listAppend("moxie");
        if (my_basestat($stat[mysticality]) < 25)
            stats_needed.listAppend("mysticality");
        string line = "Wear swashbuckling getup.";
        
        if (stats_needed.count() > 0)
        {
            delay_for_future = true;
            line += HTMLGenerateSpanOfClass(" Need 25 " + stats_needed.listJoinComponents(", ", "and"), "r_bold") + ".";
        }
		subentry.entries.listAppend(line);
    }
        
    if (delay_for_future)
        future_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the obligatory pirate's cove, barrrney's barrr, the f'c'le]));
    else
        task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the obligatory pirate's cove, barrrney's barrr, the f'c'le]));
}

//"started", "finished" observed for questG04Nemesis

void QNemesisInit()
{
    if (!($classes[seal clubber, turtle tamer, pastamancer, sauceror, disco bandit, accordion thief] contains my_class()))
        return;
	//questG04Nemesis
	QuestState state;
    
    //boolean should_quest_load = false;
    //if ($items[distilled seal blood,turtle chain,high-octane olive oil,peppercorns of power,vial of mojo,golden reeds,hammer of smiting,chelonian morningstar,greek pasta of peril,17-alarm saucepan,shagadelic disco banjo,squeezebox of the ages,Sledgehammer of the V&aelig;lkyr,Flail of the Seven Aspects,Wrath of the Capsaician Pastalords,Windsor Pan of the Source,Seeger's Unstoppable Banjo,The Trickster's Trikitixa].available_amount() > 0 || $location[the "fun" house].turnsAttemptedInLocation() > 0) //they've done something with regard to the quest, let's quest load
        //should_quest_load = true;
	
	QuestStateParseMafiaQuestProperty(state, "questG04Nemesis");
	
	state.quest_name = "Nemesis Quest";
	state.image_name = "__half Nemesis";
	
	if (my_basestat(my_primestat()) >= 12)
		state.startable = true;
    
    if (!state.finished)
    {
        //FIXME temporary code
        //Internal checking:
        
        item [class] class_epic_weapons;
        class_epic_weapons[$class[seal clubber]] = $item[bjorn's hammer];
        class_epic_weapons[$class[turtle tamer]] = $item[mace of the tortoise];
        class_epic_weapons[$class[pastamancer]] = $item[pasta of peril];
        class_epic_weapons[$class[sauceror]] = $item[5-alarm saucepan];
        class_epic_weapons[$class[disco bandit]] = $item[disco banjo];
        class_epic_weapons[$class[accordion thief]] = $item[rock and roll legend];
        item epic_weapon = class_epic_weapons[my_class()];
        if (state.mafia_internal_step < 2 && epic_weapon.available_amount() > 0)
            state.mafia_internal_step = 2;
        
        
        if (state.mafia_internal_step < 4 && $items[distilled seal blood,turtle chain,high-octane olive oil,Peppercorns of Power,vial of mojo,golden reeds].available_amount() > 0)
            state.mafia_internal_step = 4;
            
        if (state.mafia_internal_step < 5 && $items[hammer of smiting,chelonian morningstar,greek pasta of peril,17-alarm saucepan,shagadelic disco banjo,squeezebox of the ages].available_amount() > 0)
            state.mafia_internal_step = 5;
            
        if (state.mafia_internal_step < 6 && get_property("relayCounters").contains_text("Nemesis Assassin"))
            state.mafia_internal_step = 6;
        
        if (state.mafia_internal_step < 6 && get_property("questG05Dark") == "finished")
            state.mafia_internal_step = 6;
            
        
        if (state.mafia_internal_step < 15 && $item[secret tropical island volcano lair map].available_amount() > 0)
            state.mafia_internal_step = 15;
        
        if (state.mafia_internal_step < 18 && $items[Sledgehammer of the V&aelig;lkyr,Flail of the Seven Aspects,Wrath of the Capsaician Pastalords,Windsor Pan of the Source,Seeger's Unstoppable Banjo,The Trickster's Trikitixa].available_amount() > 0)
            state.mafia_internal_step = 18;
            
        if (state.mafia_internal_step < 17 && get_property("volcanoMaze1").length() > 0)
            state.mafia_internal_step = 17;
        
        //Location-based:
        if (state.mafia_internal_step == 15)
        {
            location [class] testing_location;
            testing_location[$class[seal clubber]] = $location[the broodling grounds];
            testing_location[$class[turtle tamer]] = $location[the outer compound];
            testing_location[$class[pastamancer]] = $location[the temple portico];
            testing_location[$class[sauceror]] = $location[convention hall lobby];
            testing_location[$class[disco bandit]] = $location[outside the club];
            testing_location[$class[accordion thief]] = $location[the island barracks];
            
            if (testing_location[my_class()].turnsAttemptedInLocation() > 0)
                state.mafia_internal_step = 16;
            if (state.mafia_internal_step < 16 && $location[The Nemesis' Lair].turnsAttemptedInLocation() > 0)
                state.mafia_internal_step = 16;
        }
        if (state.mafia_internal_step < 16 && $skill[Gothy Handwave].have_skill())
            state.mafia_internal_step = 16;
        if (state.mafia_internal_step < 16 && $items[Fouet de tortue-dressage,encoded cult documents,cult memo,spaghetti cult robe,hacienda key,bottle of G&uuml;-Gone].available_amount() > 0)
            state.mafia_internal_step = 16;
            
        if (!state.in_progress && state.mafia_internal_step > 0)
        {
            //force start:
            QuestStateParseMafiaQuestPropertyValue(state, "step" + (state.mafia_internal_step - 1));
        }
    }
	
	__quest_state["Nemesis"] = state;
}

void QNemesisGenerateIslandTasks(ChecklistSubentry subentry)
{
    if (my_class() == $class[disco bandit])
    {
        skill [int] rave_skills_needed;
        if (!$skill[Break It On Down].have_skill())
            rave_skills_needed.listAppend($skill[Break It On Down]);
        if (!$skill[Pop and Lock It].have_skill())
            rave_skills_needed.listAppend($skill[Pop and Lock It]);
        if (!$skill[Run Like the Wind].have_skill())
            rave_skills_needed.listAppend($skill[Run Like the Wind]);
        
        monster [skill] rave_skills_to_monster;
        rave_skills_to_monster[$skill[Break It On Down]] = $monster[breakdancing raver];
        rave_skills_to_monster[$skill[Pop and Lock It]] = $monster[pop-and-lock raver];
        rave_skills_to_monster[$skill[run like the wind]] = $monster[running man];
        
        boolean have_all_rave_skills = (rave_skills_needed.count() == 0);
        if (!$skill[gothy handwave].have_skill())
        {
            subentry.entries.listAppend("Talk to the girl in a black dress.");
        }
        else if (!have_all_rave_skills)
        {
            //Learn dance moves.
            string [int] monsters_to_fight;
            foreach key in rave_skills_needed
            {
                skill rave_skill = rave_skills_needed[key];
                monsters_to_fight.listAppend(rave_skills_to_monster[rave_skill].to_string());
            }
            subentry.entries.listAppend("Learn dance moves from the " + monsters_to_fight.listJoinComponents(", ", "and") + ".");
        }
        else
        {
            //Acquire ravosity.
            if (numeric_modifier("raveosity") >= 7)
            {
                subentry.entries.listAppend("Talk to the guard.");
            }
            else
            {
                int extra_raveosity_from_equip = 0;
                item [int] items_have_but_unequipped;
                foreach it in $items[rave visor,baggy rave pants,pacifier necklace,teddybear backpack,glowstick on a string,candy necklace,rave whistle,blue glowstick,green glowstick,purple glowstick,pink glowstick,orange glowstick,yellow glowstick]
                {
                    if (it.available_amount() > 0 && it.equipped_amount() == 0)
                    {
                        items_have_but_unequipped.listAppend(it);
                        extra_raveosity_from_equip += numeric_modifier(it, "raveosity").to_int();
                    }
                }
                
                int raveosity_needed = (7 - (extra_raveosity_from_equip + numeric_modifier("raveosity").to_int()));
                
                if (raveosity_needed > 0)
                {
                    string line = "Rave steal to find ";
                    
                    if (raveosity_needed == 1)
                        line += "One More Raveosity.";
                    else
                        line += raveosity_needed.int_to_wordy() + " more raveosity.";
                    subentry.entries.listAppend(line);
                }
                
                if (items_have_but_unequipped.count() > 0)
                    subentry.entries.listAppend("Wear " + items_have_but_unequipped.listJoinComponents(", ", "and") + ".");
            }
        }
    }
    else if (my_class() == $class[accordion thief])
    {
        if ($item[hacienda key].available_amount() >= 5)
            subentry.entries.listAppend("All keys found.");
        else
        {
            int keys_needed = MAX(0, 5 - $item[hacienda key].available_amount());
            subentry.entries.listAppend(keys_needed.int_to_wordy().capitalizeFirstLetter() + " keys to go.");
            subentry.entries.listAppend("Four are from the non-combat; one is from pick-pocketing a mariachi.");
        }
    }
    else if (my_class() == $class[pastamancer])
    {
        if ($item[spaghetti cult robe].available_amount() > 0)
        {
            if ($item[spaghetti cult robe].equipped_amount() == 0)
                subentry.entries.listAppend("Equip spaghetti cult robe, then enter the lair.");
            else
                subentry.entries.listAppend("Enter the lair.");
        }
        else if (my_thrall() == my_thrall())
        {
            string [int] tasks;
            if ($thrall[spaghetti elemental].level <3)
            {
                tasks.listAppend("level your cute and adorable spaghetti elemental to 3");
            }
            tasks.listAppend("defeat a cult member");
            
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        else if ($skill[Bind Spaghetti Elemental].have_skill())
        {
            subentry.entries.listAppend("Cast Bind Spaghetti Elemental.");
        }
        else
        {
            subentry.entries.listAppend("cult memos");
            if ($item[decoded cult documents].available_amount() > 0)
            {
                subentry.entries.listAppend("Use decoded cult documents.");
            }
            else
            {
                if ($item[encoded cult documents].available_amount() == 0)
                    subentry.entries.listAppend("Acquire encoded cult documents from a protestor.");
                
                int missing_cult_memos = MAX(0, 5 - $item[cult memo].available_amount());
                if (missing_cult_memos > 0)
                {
                    subentry.entries.listAppend("Acquire " + pluralize(missing_cult_memos, $item[cult memo]) + ".");
                }
                else if ($item[encoded cult documents].available_amount() > 0)
                {
                    subentry.entries.listAppend("Use cult memos.");
                }
            }
        }
    }
    else if (my_class() == $class[turtle tamer])
    {
        if ($item[Fouet de tortue-dressage].available_amount() == 0)
            subentry.entries.listAppend("Talk to a guy in the bushes.");
        else
        {
            if ($item[Fouet de tortue-dressage].equipped_amount() == 0)
                subentry.entries.listAppend("Equip Fouet de tortue-dressage.");
            subentry.entries.listAppend("Use Apprivoisez la tortue on french turtles a bunch, save them!|Then talk to the guy in the bushes.");
        }
    }
    else if (my_class() == $class[sauceror])
    {
        if ($item[bottle of G&uuml;-Gone].available_amount() == 0)
            subentry.entries.listAppend("Visit the boat.");
        else
        {
            if ($effect[slimeform].have_effect() > 0)
                subentry.entries.listAppend("Wiggle into the lair.|Also, go visit your mom in the slimetube.");
            else
                subentry.entries.listAppend("Use the " + $item[bottle of G&uuml;-Gone] + " on slime, make potions to get slimeform.");
        }
    }
    else if (my_class() == $class[seal clubber])
    {
        //FIXME make this work
        subentry.entries.listAppend("Don't quite know how this works. Here, have some text borrowed from the wiki:");
        subentry.entries.listAppend("Damage hellseal pups in combat to attract mother hellseals. If you kill the pups in one hit, the mother hellseals will never appear. Equip a club and kill mother hellseals using only weapon-based attacks to get 6 hellseal brains, 6 hellseal hides and 6 hellseal sinews. Do NOT use an attack familiar while fighting mother hellseals, or the bits you need will be ruined. (The Adorable Seal Larva you just received will not attack hellseals.)");
    }
}


void QNemesisGenerateClownTasks(ChecklistSubentry subentry)
{
    item [class] legendary_epic_weapon_craftable_source;
    legendary_epic_weapon_craftable_source[$class[seal clubber]] = $item[distilled seal blood];
    legendary_epic_weapon_craftable_source[$class[turtle tamer]] = $item[turtle chain];
    legendary_epic_weapon_craftable_source[$class[pastamancer]] = $item[high-octane olive oil];
    legendary_epic_weapon_craftable_source[$class[sauceror]] = $item[peppercorns of power];
    legendary_epic_weapon_craftable_source[$class[disco bandit]] = $item[vial of mojo];
    legendary_epic_weapon_craftable_source[$class[accordion thief]] = $item[golden reeds];
    
    subentry.modifiers.listAppend("-combat");
    subentry.entries.listAppend("Search in the Fun House.");
    int clownosity = numeric_modifier("Clownosity").floor();
    int clownosity_needed = MAX(4 - clownosity, 0);
    
    if (clownosity_needed > 0)
    {
        string [int] available_clown_sources;
        string [int] missing_sources;
        
        item [slot] possible_outfit;
        foreach it in $items[clown wig,clown whip,clownskin buckler,clownskin belt,clownskin harness,polka-dot bow tie,balloon sword,balloon helmet,foolscap fool's cap,bloody clown pants,clown shoes,big red clown nose]
        {
            int clownosity = numeric_modifier(it, "clownosity").floor();
            string description = it + " (" + clownosity + ")";
            if (it.available_amount() > 0 && it.equipped_amount() == 0 && it.can_equip())
            {
                available_clown_sources.listAppend(description);
                if (possible_outfit[it.to_slot()].numeric_modifier("clownosity").floor() < clownosity)
                    possible_outfit[it.to_slot()] = it;
            }
            if (it.available_amount() == 0)
                missing_sources.listAppend(description);
        }
        
        item [int] suggested_outfit;
        int clownosity_possible = 0;
        foreach key in possible_outfit
        {
            clownosity_possible += possible_outfit[key].numeric_modifier("clownosity").floor();
            suggested_outfit.listAppend(possible_outfit[key]);
            if (clownosity_possible >= clownosity_needed)
                break;
        }
        //Remove extraneous pieces:
        foreach key in suggested_outfit
        {
            int clownosity = suggested_outfit[key].numeric_modifier("clownosity").floor();
            if (clownosity_possible - clownosity >= clownosity_needed)
            {
                clownosity_possible -= clownosity;
                remove suggested_outfit[key];
            }
            
        }
        string line = "Need " + clownosity_needed + " more clownosity.";
        
        if (available_clown_sources.count() > 0)
        {
            if (clownosity_possible >= clownosity_needed)
                line += "|Equip " + suggested_outfit.listJoinComponents(", ", "and") + ".";
            else
                line += "|Equip " + available_clown_sources.listJoinComponents(", ", "or") + ".";
        }
        if (missing_sources.count() > 0 && clownosity_possible < clownosity_needed)
        {
            if (!in_ronin())
                line += "|Could buy " + missing_sources.listJoinComponents(", ", "or") + ".";
            else
                line += "|Find sources in the Fun House.";
        }
        
        subentry.entries.listAppend(line);
        
    }
}

void QNemesisGenerateCaveTasks(ChecklistSubentry subentry, item legendary_epic_weapon)
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questG05Dark", true);
    
    subentry.entries.listAppend("Visit the sinister cave.");
    int paper_strips_found = 0;
    
    if (state.mafia_internal_step == 0)
        state.mafia_internal_step = 1;
    foreach it in $items[a torn paper strip,a rumpled paper strip,a creased paper strip,a folded paper strip,a crinkled paper strip,a crumpled paper strip,a ragged paper strip,a ripped paper strip]
    {
        if (it.available_amount() > 0)
            paper_strips_found += 1;
    }
    if (true)
    {
        //FIXME temporary code
        if (state.mafia_internal_step < 4 && paper_strips_found > 0)
            state.mafia_internal_step = 4;
        if (state.mafia_internal_step < 4 && $location[nemesis cave].turnsAttemptedInLocation() > 0)
            state.mafia_internal_step = 4;
    }
        
        
    if (state.mafia_internal_step == 1 || state.mafia_internal_step == 2 || state.mafia_internal_step == 3)
    {
        //1	Finally it's time to meet this Nemesis you've been hearing so much about! The guy at your guild has marked your map with the location of a cave in the Big Mountains, where your Nemesis is supposedly hiding.
        //2	Having opened the first door in your Nemesis' cave, you are now faced with a second one. Go figure
        //3	Having opened the second door in your Nemesis' cave, you are now
        //First door:
        string [int] door_unlockers;
        
        //First door:
        if (state.mafia_internal_step <= 1)
        {
            if (my_primestat() == $stat[muscle])
                door_unlockers.listAppend("viking helmet");
            else if (my_primestat() == $stat[mysticality])
                door_unlockers.listAppend("stalk of asparagus");
            else if (my_primestat() == $stat[moxie])
                door_unlockers.listAppend("dirty hobo gloves");
        }
        
        //Second door:
        if (state.mafia_internal_step <= 2)
        {
            if (my_primestat() == $stat[muscle])
                door_unlockers.listAppend("insanely spicy bean burrito");
            else if (my_primestat() == $stat[mysticality])
                door_unlockers.listAppend("insanely spicy enchanted bean burrito");
            else if (my_primestat() == $stat[moxie])
                door_unlockers.listAppend("insanely spicy jumping bean burrito");
        }
            
        //Third door:
        
        if (state.mafia_internal_step <= 3)
        {
            if (my_class() == $class[seal clubber])
                door_unlockers.listAppend("clown whip");
            else if (my_class() == $class[turtle tamer])
                door_unlockers.listAppend("clownskin buckler");
            else if (my_class() == $class[pastamancer])
                door_unlockers.listAppend("boring spaghetti");
            else if (my_class() == $class[sauceror])
                door_unlockers.listAppend("tomato juice of powerful power");
            else if (my_class() == $class[disco bandit])
            {
                //suggest:
                
                string suggested_drink = "pink pony";
                int suggested_drink_amount = 0;
                
                foreach it in $items[a little sump'm sump'm,bungle in the jungle,calle de miel,ducha de oro,fuzzbump,horizontal tango,ocean motion,perpendicular hula,pink pony,rockin' wagon,roll in the hay,slap and tickle,slip 'n' slide,tropical swill]
                {
                    if (it.available_amount() > suggested_drink_amount)
                    {
                        suggested_drink_amount = it.available_amount();
                        suggested_drink = it;
                    }
                }
                door_unlockers.listAppend(suggested_drink);
            }
            else if (my_class() == $class[accordion thief])
                door_unlockers.listAppend("polka of plenty buffed on you");
        }
        
        subentry.entries.listAppend("Open doors via " + door_unlockers.listJoinComponents(", then ") + ".");
    }
    else if (state.mafia_internal_step == 4 || state.mafia_internal_step == 5)
    {
        //4	Woo! You're past the doors and it's time to stab some bastards
        //5	The door to your Nemesis' inner sanctum didn't seem to care for the password you tried earlier
        
        if (paper_strips_found >= 8)
        {
            subentry.entries.listAppend("Speak the password, then fight your nemesis.|Then wait for assassins.");
            if (legendary_epic_weapon.equipped_amount() == 0)
                subentry.entries.listAppend("Equip " + legendary_epic_weapon + ".");
        }
        else
        {
            subentry.modifiers.listAppend("+234% item");
            subentry.entries.listAppend("Run +234% item in the large chamber.");
            int strips_needed = MAX(8 - paper_strips_found, 0);
            float average_turns = clampNormalf(0.3 * (1.0 + item_drop_modifier() / 100.0));
            if (average_turns != 0.0)
                average_turns = strips_needed / average_turns;
            else
                average_turns = -1.0;
            subentry.entries.listAppend("Find " + pluralizeWordy(strips_needed, "paper strip", "paper strips") + ". ~" + average_turns.roundForOutput(1) + " turns left.");
        }
    }
    else if (state.mafia_internal_step == 6)
    {
        //6	Hear how the background music got all exciting? It's because you opened the door to your Nemesis' inner sanctum
        subentry.entries.listAppend("Fight your nemesis.");
        if (legendary_epic_weapon.equipped_amount() == 0)
            subentry.entries.listAppend("Equip " + legendary_epic_weapon + ".");
    }
}

void QNemesisGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Nemesis"];
	if (base_quest_state.finished)
		return;
    if (!($classes[seal clubber,turtle tamer,pastamancer,sauceror,disco bandit,accordion thief] contains my_class()))
        return;
    
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    string url = "";
    
    //volcanoMaze1 through volcanoMaze5 is relevant, blank when not available
    
    boolean have_legendary_epic_weapon = false;
    boolean have_epic_weapon = false;
    
    item [class] class_epic_weapons;
    item [class] class_legendary_epic_weapons;
    item [class] class_ultimate_legendary_epic_weapons;
    
    class_epic_weapons[$class[seal clubber]] = $item[bjorn's hammer];
    class_epic_weapons[$class[turtle tamer]] = $item[mace of the tortoise];
    class_epic_weapons[$class[pastamancer]] = $item[pasta of peril];
    class_epic_weapons[$class[sauceror]] = $item[5-alarm saucepan];
    class_epic_weapons[$class[disco bandit]] = $item[disco banjo];
    class_epic_weapons[$class[accordion thief]] = $item[rock and roll legend];
    item epic_weapon = class_epic_weapons[my_class()];
    
    
    class_legendary_epic_weapons[$class[seal clubber]] = $item[hammer of smiting];
    class_legendary_epic_weapons[$class[turtle tamer]] = $item[chelonian morningstar];
    class_legendary_epic_weapons[$class[pastamancer]] = $item[greek pasta of peril];
    class_legendary_epic_weapons[$class[sauceror]] = $item[17-alarm saucepan];
    class_legendary_epic_weapons[$class[disco bandit]] = $item[shagadelic disco banjo];
    class_legendary_epic_weapons[$class[accordion thief]] = $item[squeezebox of the ages];
    item legendary_epic_weapon = class_legendary_epic_weapons[my_class()];
    
    
    
    class_ultimate_legendary_epic_weapons[$class[seal clubber]] = $item[Sledgehammer of the V&aelig;lkyr];
    class_ultimate_legendary_epic_weapons[$class[turtle tamer]] = $item[Flail of the Seven Aspects];
    class_ultimate_legendary_epic_weapons[$class[pastamancer]] = $item[Wrath of the Capsaician Pastalords];
    class_ultimate_legendary_epic_weapons[$class[sauceror]] = $item[Windsor Pan of the Source];
    class_ultimate_legendary_epic_weapons[$class[disco bandit]] = $item[Seeger's Unstoppable Banjo];
    class_ultimate_legendary_epic_weapons[$class[accordion thief]] = $item[The Trickster's Trikitixa];
    item ultimate_legendary_epic_weapon = class_ultimate_legendary_epic_weapons[my_class()];
    
    if (epic_weapon.available_amount() > 0)
        have_epic_weapon = true;
    if (legendary_epic_weapon.available_amount() > 0)
        have_legendary_epic_weapon = true;
        
	if (!__misc_state["In aftercore"] && !have_legendary_epic_weapon)
		return;
        
        
    string [class] first_boss_name;
    first_boss_name[$class[Seal Clubber]] = "Gorgolok, the Infernal Seal";
    first_boss_name[$class[Turtle Tamer]] = "Stella, the Turtle Poacher";
    first_boss_name[$class[Pastamancer]] = "Spaghetti Elemental";
    first_boss_name[$class[Sauceror]] = "Lumpy, the Sinister Sauceblob";
    first_boss_name[$class[Disco Bandit]] = "The Spirit of New Wave";
    first_boss_name[$class[Accordion Thief]] = "Somerset Lopez, Dread Mariachi";
    
    if (base_quest_state.mafia_internal_step <= 1)
    {
        //1	One of your guild leaders has tasked you to recover a mysterious and unnamed artifact stolen by your Nemesis. Your first step is to smith an Epic Weapon
        if (have_epic_weapon)
        {
            subentry.entries.listAppend("Speak to your guild.");
            url = "guild.php";
        }
        else
            subentry.entries.listAppend("Acquire epic weapon. (" + epic_weapon + ")");
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        //2	To unlock the full power of the Legendary Epic Weapon, you must defeat Beelzebozo, the Clown Prince of Darkness,
        QNemesisGenerateClownTasks(subentry);
        url = "place.php?whichplace=plains";
    }
    else if (base_quest_state.mafia_internal_step == 3 || base_quest_state.mafia_internal_step == 4)
    {
        //3	You've finally killed the clownlord Beelzebozo
        //4	You've successfully defeated Beelzebozo and claimed the last piece of the Legendary Epic Weapon
        if (have_legendary_epic_weapon)
        {
            subentry.entries.listAppend("Speak to your guild.");
            url = "guild.php";
        }
        else
        {
            subentry.entries.listAppend("Make " + legendary_epic_weapon + ".");
        }
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //5	discovered where your Nemesis is hiding. It took long enough, jeez! Anyway, turns out it's a Dark and
        url = "cave.php";
        QNemesisGenerateCaveTasks(subentry,legendary_epic_weapon);
    }
    else if (base_quest_state.mafia_internal_step >= 6 && base_quest_state.mafia_internal_step < 15)
    {
        //6	You have successfully shown your Nemesis what for, and claimed an ancient hat of power. It's pretty sweet
        //7	You showed the Epic Hat to the class leader back at your guild, but they didn't seem much impressed. I guess all this Nemesis nonsense isn't quite finished yet, but at least with your Nemesis in hiding again you won't have to worry about it for a while.
        //8	It appears as though some nefarious ne'er-do-well has put a contract on your head
        //9	You handily dispatched some thugs who were trying to collect on your bounty, but something tells you they won't be the last ones to try
        
        //10	Whoever put this hit out on you (like you haven't guessed already) has sent Mob Penguins to do their dirty work. Do you know any polar bears you could hire as bodyguards
        //11	So much for those mob penguins that were after your head! If whoever put this hit out on you wants you killed (which, presumably, they do) they'll have to find some much more competent thugs
        //12	have been confirmed: your Nemesis has put the order out for you to be hunted down and killed, and now they're sending their own guys instead of contracting out
        //13	Bam! So much for your Nemesis' assassins! If that's the best they've got, you have nothing at all to worry about
        //14	You had a run-in with some crazy mercenary or assassin or... thing that your Nemesis sent to do you in once and for all. A run-in followed by a run-out, evidently,
        subentry.entries.listAppend("Wait for assassins.");
        if (my_basestat(my_primestat()) < 90)
            subentry.entries.listAppend("Level to 90 " + my_primestat().to_lower_case() + ".");
    }
    else if (base_quest_state.mafia_internal_step == 15)
    {
        //15	Now that you've dealt with your Nemesis' assassins and found a map to the secret tropical island volcano lair, it's time to take the fight to your foe. Booyah
        //find island
        if ($item[pirate fledges].available_amount() == 0)
        {
            subentry.entries.listAppend("Finish pirate quest first.");
        }
        else
        {
            url = "place.php?whichplace=cove";
            subentry.entries.listAppend("Ask the pirates how to find the island.");
            if ($item[pirate fledges].equipped_amount() == 0 && !is_wearing_outfit("Swashbuckling Getup"))
            {
                url = "inventory.php?which=2";
                subentry.entries.listAppend("Wear pirate fledges.");
            }
            subentry.modifiers.listAppend("-combat");
        }
    }
    else if (base_quest_state.mafia_internal_step == 16)
    {
        //16	You've arrived at the secret tropical island volcano lair, and it's time to finally put a stop to this Nemesis nonsense once and for all. As soon as you can find where they're hiding. Maybe you can find someone to ask
        if ($location[The Nemesis' Lair].turnsAttemptedInLocation() > 0)
        {
            if (my_class() == $class[disco bandit])
                subentry.entries.listAppend("Fight daft punk, then your nemesis face to face.|Then solve the volcano maze.");
            else
                subentry.entries.listAppend("Fight goons, then your nemesis.|Then solve the volcano maze.");
        }
        else
            QNemesisGenerateIslandTasks(subentry);
        url = "volcanoisland.php";
    }
    else if (base_quest_state.mafia_internal_step >= 17 && base_quest_state.mafia_internal_step <= 19)
    {
        //17	Congratulations on solving the lava maze, which is probably the biggest pain-in-the-ass puzzle in the entire game! Hooray! (Unless you cheated, in which case
        if (base_quest_state.mafia_internal_step == 17)
            subentry.entries.listAppend("Solve the volcano maze, then fight your nemesis.");
        else
            subentry.entries.listAppend("Fight your nemesis.");
        url = "volcanoisland.php";
        if (legendary_epic_weapon.equipped_amount() == 0 && ultimate_legendary_epic_weapon.equipped_amount() == 0)
            subentry.entries.listAppend("Equip " + legendary_epic_weapon + ".");
    }
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the "fun" house, nemesis cave, the nemesis' lair, the broodling grounds, the outer compound, the temple portico, convention hall lobby, outside the club, the island barracks, the poop deck]));
}
//merkinQuestPath

void QSeaInit()
{
	if (!__misc_state["In aftercore"])
		return;
    
    //Have they adventured anywhere underwater?
    boolean have_adventured_in_relevant_area = false;
    foreach l in $locations[the briny deeps, the brinier deepers, the briniest deepests, an octopus's garden,the wreck of the edgar fitzsimmons, the mer-kin outpost, madness reef,the marinara trench, the dive bar,anemone mine, the coral corral, mer-kin elementary school,mer-kin library,mer-kin gymnasium,mer-kin colosseum,the caliginous abyss]
    {
        if (l.turnsAttemptedInLocation() > 0)
        {
            have_adventured_in_relevant_area = true;
            break;
        }
    }
    //don't list the quest unless they've started on the path under the sea:
    if (!have_adventured_in_relevant_area && $items[Mer-kin trailmap,Mer-kin lockkey,Mer-kin stashbox,wriggling flytrap pellet,damp old boot,Grandma's Map,Grandma's Chartreuse Yarn,Grandma's Fuchsia Yarn,Grandma's Note].available_amount() == 0)
        return;
        
    
	//FIXME support mom
    if (true)
    {
        QuestState state;
        
        string quest_path = get_property("merkinQuestPath");
        if (quest_path == "done")
            QuestStateParseMafiaQuestPropertyValue(state, "finished");
        else
        {
            QuestStateParseMafiaQuestPropertyValue(state, "started");
        }
        
        state.quest_name = "Sea Quest";
        state.image_name = "Sea";
        
        __quest_state["Sea Temple"] = state;
    }
    if (true)
    {
        QuestState state;
        
        QuestStateParseMafiaQuestProperty(state, "questS02Monkees", false); //don't issue a quest load
        state.quest_name = "Hey, Hey, They're Sea Monkees";
        state.image_name = "Sea";
        
        
        __quest_state["Sea Monkees"] = state;
    }
}

void QSeaGenerateTempleEntry(ChecklistSubentry subentry, StringHandle image_name)
{
    string path = get_property("merkinQuestPath");
    
    boolean can_fight_dad_sea_monkee = $items[Goggles of Loathing,Stick-Knife of Loathing,Scepter of Loathing,Jeans of Loathing,Treads of Loathing,Belt of Loathing,Pocket Square of Loathing].items_missing().count() <= 1;
    
    boolean have_one_outfit = false;
    if (can_fight_dad_sea_monkee)
        have_one_outfit = true;
    foreach outfit_name in $strings[Mer-kin Scholar's Vestments,Mer-kin Gladiatorial Gear,Crappy Mer-kin Disguise]
    {
        if (have_outfit_components(outfit_name))
        {
            have_one_outfit = true;
            break;
        }
    }
    
    
    if (!have_one_outfit)
    {
        subentry.entries.listAppend("Acquire crappy mer-kin disguise from grandma sea monkee.");
        return;
    }
    
    boolean at_boss = false;
    boolean at_gladiator_boss = false;
    boolean at_scholar_boss = false;
    if (path == "gladiator")
    {
        image_name.s = "Shub-Jigguwatt";
        at_gladiator_boss = true;
    }
    else if (path == "scholar")
    {
        image_name.s = "Yog-Urt";
        at_scholar_boss = true;
    }
    at_boss = at_gladiator_boss || at_scholar_boss;
    
    if (!at_boss || at_gladiator_boss)
    {
        string [int] description;
        string [int] modifiers;
        //gladiator:
        if (at_gladiator_boss)
        {
            description.listAppend("Buff muscle, equip a powerful weapon.");
            description.listAppend("Delevel him with crayon shavings for a bit, then attack with your weapon.");
            description.listAppend("Make sure not to have anything along that will attack him. (saucespheres, familiars, hand in glove, etc)");
            if (my_mp() > 0)
                description.listAppend("Try to reduce your MP to 0 before fighting him.");
        }
        else
        {
            if (!have_outfit_components("Mer-kin Gladiatorial Gear"))
            {
                description.listAppend("Acquire gladiatorial outfit.|Components can be found by running +combat in the gymnasium.");
                modifiers.listAppend("+combat");
            }
            else
            {
                string shrap_suggestion = "Shrap is nice for this.";
                if (!lookupSkill("shrap").have_skill())
                {
                    if (lookupItem("warbear metalworking primer (used)").available_amount() > 0)
                    {
                        shrap_suggestion += " (use your used copy of warbear metalworking primer)";
                    }
                    else
                        shrap_suggestion += " (from warbear metalworking primer)";
                }
                modifiers.listAppend("spell damage percent");
                modifiers.listAppend("mysticality");
                description.listAppend("Fight in the colosseum!");
                description.listAppend("Easy way is to buff mysticality and spell damage percent, then cast powerful spells.|" + shrap_suggestion);
                description.listAppend("There's another way, but it's a bit complicated. Check the wiki?");
            }
        }
        string modifier_string = "";
        if (modifiers.count() > 0)
            modifier_string = ChecklistGenerateModifierSpan(modifiers);
        if (description.count() > 0)
            subentry.entries.listAppend("Gladiator path" +  HTMLGenerateIndentedText(modifier_string + description.listJoinComponents("<hr>")));
    }
    if (!at_boss || at_scholar_boss)
    {
        string [int] description;
        string [int] modifiers;
        //scholar:
        if (at_scholar_boss)
        {
            description.listAppend("Wear several mer-kin prayerbeads and possibly a mer-kin gutgirdle.");
            description.listAppend("Avoid wearing any +hp gear or buffs. Ideally, you want low HP.");
            description.listAppend("Each round, use a different healing item, until you lose the Suckrament effect.|After that, your stats are restored. Fully heal, then " + HTMLGenerateSpanOfClass("attack with elemental damage", "r_bold") + ".");
            string [item] potential_healers;
            potential_healers[$item[mer-kin healscroll]] = "mer-kin healscroll (full HP)";
            potential_healers[$item[scented massage oil]] = "scented massage oil (full HP)";
            potential_healers[$item[soggy used band-aid]] = "soggy used band-aid (full HP)";
            potential_healers[$item[extra-strength red potion]] = "extra-strength red potion (+200 HP)";
            potential_healers[$item[red pixel potion]] = "red pixel potion (+100-120 HP)";
            potential_healers[$item[red potion]] = "red potion (+100 HP)";
            potential_healers[$item[filthy poultice]] = "filthy poultice (+80-120 HP)";
            potential_healers[$item[gauze garter]] = "gauze garter (+80-120 HP)";
            potential_healers[$item[green pixel potion]] = "green pixel potion (+40-60 HP)";
            potential_healers[$item[cartoon heart]] = "cartoon heart (40-60 HP)";
            potential_healers[$item[red plastic oyster egg]] = "red plastic oyster egg (+35-40 HP)";
            string [int] description_healers;
            
            foreach it in potential_healers
            {
                if (it.available_amount() > 0)
                    description_healers.listAppend(potential_healers[it]);
                else
                    description_healers.listAppend(HTMLGenerateSpanFont(potential_healers[it], "red", ""));
            }
            description.listAppend("Potential healing items:|*" + description_healers.listJoinComponents("|*"));
        }
        else
        {
            if (!have_outfit_components("Mer-kin Scholar's Vestments"))
            {
                description.listAppend("Acquire scholar outfit.|Components can be found by running -combat in the elementary school.");
                modifiers.listAppend("-combat");
            }
            else
            {
                if ($item[Mer-kin dreadscroll].available_amount() == 0)
                {
                    description.listAppend("Adventure in the library. Find the dreadscroll.");
                    modifiers.listAppend("-combat");
                }
                else
                {
                    if ($effect[deep-tainted mind].have_effect() > 0)
                        description.listAppend("Solve the dreadscroll.|Wait for Deep-Tainted Mind to wear off.");
                    else
                        description.listAppend("Solve the dreadscroll.");
                    description.listAppend("Clues are from:|*Three non-combats in the library. (vocabulary)|*Use a mer-kin killscroll in combat. (vocabulary)|*Use a mer-kin healscroll in combat. (vocabulary)|*Use a mer-kin knucklebone.|*Cast deep dark visions.|*Eat sushi with mer-kin worktea.");
                    
                    int vocabulary = get_property_int("merkinVocabularyMastery");
                    if (vocabulary < 10)
                        description.listAppend("At " + (vocabulary * 10) + "% Mer-Kin vocabulary. (use mer-kin wordquiz with a mer-kin cheatsheet)");
                    else
                        description.listAppend("Mer-Kin vocabulary mastered.");
                }
            }
        }
        string modifier_string = "";
        if (modifiers.count() > 0)
            modifier_string = ChecklistGenerateModifierSpan(modifiers);
        if (description.count() > 0)
            subentry.entries.listAppend("Scholar path" +  HTMLGenerateIndentedText(modifier_string + description.listJoinComponents("<hr>")));
    }
    if (!at_boss && can_fight_dad_sea_monkee)
    {
        string [int] description;
        
        description.listAppend("Equip Clothing of Loathing, go to the temple.");
        description.listAppend("Cast 120MP hobopolis spells at him.");
        description.listAppend("Use Mafia's \"dad\" GCLI command to see which element to use which round.");
        if (my_mp() < 1200)
            description.listAppend("Will need 1200MP, or less if using shrap/volcanometeor showeruption.");
            
        string [int] modifiers_needed_150;
        foreach s in $stats[]
        {
            if (s.my_basestat() < 150)
                modifiers_needed_150.listAppend((150 - s.my_basestat()) + " more " + s.to_lower_case());
        }
        
        if (modifiers_needed_150.count() > 0)
            description.listAppend("Need " + modifiers_needed_150.listJoinComponents(", ", "and") + " to wear Clothing of Loathing.");
        
        if (description.count() > 0)
            subentry.entries.listAppend("Dad sea monkee path" + HTMLGenerateIndentedText(description.listJoinComponents("<hr>")));
    }
    
    item [class] class_to_scholar_item;
    item [class] class_to_gladiator_item;
    
    class_to_scholar_item[$class[seal clubber]] = $item[Cold Stone of Hatred];
    class_to_scholar_item[$class[turtle tamer]] = $item[Girdle of Hatred];
    class_to_scholar_item[$class[pastamancer]] = $item[Staff of Simmering Hatred];
    class_to_scholar_item[$class[sauceror]] = $item[Pantaloons of Hatred];
    class_to_scholar_item[$class[disco bandit]] = $item[Fuzzy Slippers of Hatred];
    class_to_scholar_item[$class[accordion thief]] = $item[Lens of Hatred];
    
    class_to_gladiator_item[$class[seal clubber]] = $item[Ass-Stompers of Violence];
    class_to_gladiator_item[$class[turtle tamer]] = $item[Brand of Violence];
    class_to_gladiator_item[$class[pastamancer]] = $item[Novelty Belt Buckle of Violence];
    class_to_gladiator_item[$class[sauceror]] = $item[Lens of Violence];
    class_to_gladiator_item[$class[disco bandit]] = $item[Pigsticker of Violence];
    class_to_gladiator_item[$class[accordion thief]] = $item[Jodhpurs of Violence];
    
    item scholar_item = class_to_scholar_item[my_class()];
    item gladiator_item = class_to_gladiator_item[my_class()];
    
    if (!at_boss)
    {
        string line = "Can acquire " + scholar_item + " (scholar) or " + gladiator_item + " (gladiator)";
        if (can_fight_dad_sea_monkee)
            line += " or " + $item[pocket square of loathing] + " (dad)";
        subentry.entries.listAppend(line);
    }
    else if (at_gladiator_boss)
        subentry.entries.listAppend("Will acquire " + gladiator_item + ".");
    else if (at_scholar_boss)
        subentry.entries.listAppend("Will acquire " + scholar_item + ".");
}

//Hmm. Possibly show taffy in resources, if they're under the sea?

void QSeaGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState temple_quest_state = __quest_state["Sea Temple"];
	QuestState monkees_quest_state = __quest_state["Sea Monkees"];
	
	if (!__misc_state["In aftercore"])
		return;
    
	boolean have_something_to_do_in_sea = false;
	if (!temple_quest_state.finished && (temple_quest_state.in_progress || temple_quest_state.startable))
		have_something_to_do_in_sea = true;
		
	ChecklistSubentry subentry;
	string image_name = temple_quest_state.image_name;
	
	subentry.header = temple_quest_state.quest_name;
	string url = "seafloor.php";
    boolean need_minus_combat_modifier = false;
	
    
    if ($effect[fishy].have_effect() == 0)
    {
        string line = "Acquire fishy.|*Easy way: Semi-rare in the brinier deeps, 50 turns.";
        if ($item[fishy pipe].available_amount() > 0 && !get_property_boolean("_fishyPipeUsed"))
            line += "|*Use fishy pipe.";
        subentry.entries.listAppend(line);
    }
        
	if (!temple_quest_state.finished)
	{
		if (get_property("seahorseName").length() == 0)
		{
            boolean professional_roper = false;
            //merkinLockkeyMonster questS01OldGuy questS02Monkees
			//Need to reach the temple:
			if (get_property("lassoTraining") != "expertly")
			{
				string line = "";
				if ($item[sea lasso].available_amount() == 0)
					line += "Buy and use a sea lasso in each combat.";
				else
					line += "Use a sea lasso in each combat.";
				if ($item[sea cowboy hat].equipped_amount() == 0)
					line += "|*Wear a sea cowboy hat to improve roping.";
				if ($item[sea chaps].equipped_amount() == 0)
					line += "|*Wear sea chaps to improve roping.";
				subentry.entries.listAppend(line);
			}
            else
            {
                professional_roper = true;
				string line = "";
				if ($item[sea lasso].available_amount() == 0)
					line += "Buy a sea lasso.";
				if ($item[sea cowbell].available_amount() <3 )
                {
                    int needed_amount = MAX(3 - $item[sea cowbell].available_amount(), 0);
					line += "Buy " + pluralizeWordy(needed_amount, "sea cowbell", "sea cowbells") + ".";
                }
                if (line.length() > 0)
                    subentry.entries.listAppend(line);
            }
            location class_grandpa_location;
            if (my_primestat() == $stat[muscle])
                class_grandpa_location = $location[Anemone Mine];
            if (my_primestat() == $stat[mysticality])
                class_grandpa_location = $location[The Marinara Trench];
            if (my_primestat() == $stat[moxie])
                class_grandpa_location = $location[the dive bar];
            
            int grandpa_ncs_remaining = 3 - class_grandpa_location.noncombatTurnsAttemptedInLocation();
            //Detect where we are:
            //This won't work beyond talking to little brother, my apologies
            if ($location[the Coral corral].turnsAttemptedInLocation() > 0)
            {
                //Coral corral. Banish strategy.
                string sea_horse_details;
                if (!professional_roper)
                    sea_horse_details = "|But first, train up your roping skills.";
                else
                    sea_horse_details = "|Once found, use three sea cowbells on him, then a sea lasso.";
                subentry.entries.listAppend("Look for your sea horse in the Coral Corral." + sea_horse_details);
                string [int] banish_monsters;
                monster [int] monster_list = $location[the coral corral].get_monsters();
                foreach key in monster_list
                {
                    monster m = monster_list[key];
                    if (!m.is_banished() && m != $monster[wild seahorse])
                        banish_monsters.listAppend(m.to_string());
                }
                if (banish_monsters.count() > 0)
                    subentry.entries.listAppend("Banish " + banish_monsters.listJoinComponents(", ", "and") + " with separate banish sources to speed up area.");
            }
            else if (false)
            {
                //Ask grandpa about currents.
            }
            else if (false)
            {
                //Use trailmap.
            }
            else if (false)
            {
                //Then stash box. Mention monster source.
            }
            else if ($location[the mer-kin outpost].turnsAttemptedInLocation() > 0 || grandpa_ncs_remaining == 0)
            {
                //Find lockkey as well.
                if ($item[Mer-kin trailmap].available_amount() > 0)
                {
                    subentry.entries.listAppend("Use Mer-kin trailmap.");
                }
                else if ($item[Mer-kin lockkey].available_amount() == 0)
                {
                    subentry.entries.listAppend("Adventure in the Mer-Kin outpost, acquire a lockkey.");
                    subentry.entries.listAppend("Unless you unlocked the currents already, in which case go to the corral.");
                }
                else if ($item[Mer-kin stashbox].available_amount() == 0)
                {
                    string nc_details = "";
                    monster lockkey_monster = get_property("merkinLockkeyMonster").to_monster();
                    if (lockkey_monster == $monster[mer-kin burglar])
                    {
                        nc_details = "Stashbox is in the camouflaged tent.";
                    }
                    else if (lockkey_monster == $monster[mer-kin raider])
                    {
                        nc_details = "Stashbox is in the skull-bedecked tent.";
                    }
                    else if (lockkey_monster == $monster[mer-kin healer])
                    {
                        nc_details = "Stashbox is in the glyphed tent.";
                    }
                    
                    need_minus_combat_modifier = true;
                    subentry.entries.listAppend("Adventure in the Mer-Kin outpost, find non-combat.|" + nc_details);
                }
                else
                {
                    subentry.entries.listAppend("Open stashbox.");
                }
                
            }
            else if (monkees_quest_state.mafia_internal_step == 5 || class_grandpa_location.turnsAttemptedInLocation() > 0)
            {
                //Find grandpa in one of the three zones.
                need_minus_combat_modifier = true;
                subentry.entries.listAppend("Find grandpa sea monkee in " + class_grandpa_location + ".|" + pluralizeWordy(grandpa_ncs_remaining, "non-combat remains", "non-combats remain").capitalizeFirstLetter() + ".");
            }
            else if (monkees_quest_state.mafia_internal_step == 4)
            {
                //Talk to little brother.
                subentry.entries.listAppend("Talk to little brother.");
                url = "monkeycastle.php";
            }
            else if (monkees_quest_state.mafia_internal_step == 3)
            {
                //Talk to big brother.
                subentry.entries.listAppend("Talk to big brother.");
                url = "monkeycastle.php";
            }
            else if (monkees_quest_state.mafia_internal_step == 2 || $location[The Wreck of the Edgar Fitzsimmons].turnsAttemptedInLocation() > 0)
            {
                //Adventure in wreck, free big brother.
                need_minus_combat_modifier = true;
                subentry.entries.listAppend("Free big brother. Adventure in the wreck.|Then talk to him and little brother, find grandpa.");
            }
            else if (monkees_quest_state.mafia_internal_step == 1)
            {
                //Talk to little brother
                subentry.entries.listAppend("Talk to little brother.");
                url = "monkeycastle.php";
            }
            else if (monkees_quest_state.mafia_internal_step < 1)
            {
                //Octopus's garden, obtain wriggling flytrap pellet
                if ($item[wriggling flytrap pellet].available_amount() == 0)
                    subentry.entries.listAppend("Adventure in octopus's garden, find a wriggling flytrap pellet.|Or talk to little brother if you've done that already.");
                else
                {
                    url = "inventory.php?which=3";
                    subentry.entries.listAppend("Open a wriggling flytrap pellet, talk to little brother.");
                }
            }
            
            //Find grandma IF they don't have a disguise/cloathing.
		}
		else
		{
            url = "seafloor.php?action=currents";
            StringHandle image_name_handle;
            image_name_handle.s = image_name;
            QSeaGenerateTempleEntry(subentry, image_name_handle);
            image_name = image_name_handle.s;
        }
	}
            
    if ($item[damp old boot].available_amount() > 0)
    {
        string [int] description;
        if ($item[fishy pipe].available_amount() == 0)
            description.listAppend("Choose the fishy pipe.");
        else if ($item[das boot].available_amount() == 0)
            description.listAppend("Choose the das boot.");
        else
            description.listAppend("Choose the damp old wallet.");
        
		optional_task_entries.listAppend(ChecklistEntryMake("__item damp old boot", "place.php?whichplace=sea_oldman", ChecklistSubentryMake("Return damp old boot to the old man", "", description)));
        
    }
    if ($items[Grandma's Map,Grandma's Chartreuse Yarn,Grandma's Fuchsia Yarn,Grandma's Note].available_amount() > 0)
    {
        string line = "Optionally, rescue grandma.";
        if ($item[grandma's map].available_amount() > 0)
        {
            line += "|Adventure at the mer-kin outpost, find her.";
            need_minus_combat_modifier = true;
        }
        else
        {
            item [int] missing_items = $items[Grandma's Chartreuse Yarn,Grandma's Fuchsia Yarn,Grandma's Note].items_missing();
            
            if (missing_items.count() == 0)
            {
                line += "|Ask grandpa about the note.";
            }
            else
            {
                line += "|Adventure at the mer-kin outpost, find " + missing_items.listJoinComponents(", ", "and") + ".";
                need_minus_combat_modifier = true;
            }
        }
        subentry.entries.listAppend(line);
    }
    
    if (need_minus_combat_modifier)
        subentry.modifiers.listAppend("-combat");
	
	if (have_something_to_do_in_sea)
		optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the brinier deepers, an octopus's garden,the wreck of the edgar fitzsimmons, the mer-kin outpost, madness reef,the marinara trench, the dive bar,anemone mine, the coral corral, mer-kin elementary school,mer-kin library,mer-kin gymnasium,mer-kin colosseum,the caliginous abyss]));
}
void QSpaceElvesInit()
{
	//questG04Nemesis
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questF04Elves");
	
	state.quest_name = "Repair the Elves' Shield Generator Quest";
	state.image_name = "spooky little girl";
	
	if (my_basestat(my_primestat()) >= 12)
		state.startable = true;
		
	
	__quest_state["Space Elves"] = state;
}


void QSpaceElvesGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Space Elves"];
	if (base_quest_state.finished)
		return;
    
    string url = "place.php?whichplace=spaaace";
    
    boolean turns_spent_in_locations_already = false;
    if ($locations[Domed City of Ronaldus,Domed City of Grimacia,Hamburglaris Shield Generator].turnsAttemptedInLocation() > 0)
        turns_spent_in_locations_already = true;
    
    if (!turns_spent_in_locations_already && $effect[transpondent].have_effect() == 0) //suggest it when they go to spaaace, otherwise, don't bug them?
        return;
    if (in_ronin() && $effect[transpondent].have_effect() == 0 && $item[transporter transponder].available_amount() == 0)
        return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    subentry.entries.listAppend("Gives 200 lunar isotopes and Elvish Paradise access.");
    
	if (base_quest_state.mafia_internal_step < 3)
	{
		string [int] ronald_map_entries;
		string [int] grimace_map_entries;
		if ($item[e.m.u. rocket thrusters].available_amount() == 0)
			ronald_map_entries.listAppend("Ronald map" + __html_right_arrow_character + "Try the Swimming Pool" + __html_right_arrow_character + "To the Left, to the Left" + __html_right_arrow_character + "Take the Red Door");
		if ($item[E.M.U. joystick].available_amount() == 0)
			ronald_map_entries.listAppend("Ronald map" + __html_right_arrow_character + "Check out the Armory" + __html_right_arrow_character + "My Left Door" + __html_right_arrow_character + "Crawl through the Ventilation Duct");
		if ($item[E.M.U. harness].available_amount() == 0)
			grimace_map_entries.listAppend("Grimace map" + __html_right_arrow_character + "Check out the Coat Check" + __html_right_arrow_character + "Exit, Stage Left" + __html_right_arrow_character + "Be the Duke of the Hazard");
		if ($item[E.M.U. helmet].available_amount() == 0)
			grimace_map_entries.listAppend("Grimace map" + __html_right_arrow_character + "Check out the Coat Check" + __html_right_arrow_character + "Stage Right, Even" + __html_right_arrow_character + "Try the Starboard Door");
		if (ronald_map_entries.count() > 0)
		{
			string header = "Ronald prime:";
			string [int] line;
			int maps_needed = ronald_map_entries.count() - $item[map to safety shelter ronald prime].available_amount();
			if (maps_needed > 0)
            {
                if (subentry.modifiers.count() == 0)
                    subentry.modifiers.listAppend("+item");
				line.listAppend("Acquire " + pluralize(maps_needed, $item[map to safety shelter ronald prime]));
            }
			
            line.listAppendList(ronald_map_entries);
			
				
			subentry.entries.listAppend(header + HTMLGenerateIndentedText(line.listJoinComponents("<hr>")));
		}
		if (grimace_map_entries.count() > 0)
		{
			string header = "Grimace prime:";
			string [int] line;
			int maps_needed = grimace_map_entries.count() - $item[map to safety shelter grimace prime].available_amount();
			if (maps_needed > 0)
            {
                if (subentry.modifiers.count() == 0)
                    subentry.modifiers.listAppend("+item");
				line.listAppend("Acquire " + pluralize(maps_needed, $item[map to safety shelter grimace prime]));
            }
				
            line.listAppendList(grimace_map_entries);
			subentry.entries.listAppend(header + HTMLGenerateIndentedText(line.listJoinComponents("<hr>")));
		}
		if (ronald_map_entries.count() == 0 && grimace_map_entries.count() == 0)
			subentry.entries.listAppend("Look for the spooky little girl on Grimacia or Ronaldus.");
        else if ($items[map to safety shelter ronald prime, map to safety shelter grimace prime].available_amount() > 0)
            url = "inventory.php?which=3";
	}
	else if (base_quest_state.mafia_internal_step == 3)
	{
		if ($item[spooky little girl].equipped_amount() == 0)
			subentry.entries.listAppend("Equip spooky little girl.");
		else if ($item[spooky little girl].available_amount() == 0)
			subentry.entries.listAppend("spooky");
		else
		{
			subentry.entries.listAppend("Adventure in Grimacia with spooky little girl.");
		}
			
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
		if ($item[E.M.U. Unit].equipped_amount() == 0)
			subentry.entries.listAppend("Equip E.M.U. Unit.");
		else
			subentry.entries.listAppend("Adventure at the Hamburglaris Shield Generator, solve puzzle.");
	}
	if ($effect[Transpondent].have_effect() == 0)
	{
		subentry.entries.listClear();
        subentry.entries.listAppend("Gives 200 lunar isotopes and Elvish Paradise access.");
		subentry.entries.listAppend("Use transporter transponder to reach spaaace.");
        if ($item[transporter transponder].available_amount() > 0)
            url = "inventory.php?which=3";
        else
            url = "mall.php";
	}
	
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[domed city of ronaldus, domed city of grimacia,hamburglaris shield generator]));
}

void QAzazelInit()
{
	//questG04Azazel
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM10Azazel");
	
	state.quest_name = "Azazel Quest";
	state.image_name = "steel margarita";
	
	if (my_basestat(my_primestat()) >= 12 && __quest_state["Level 6"].finished)
		state.startable = true;
	
	__quest_state["Azazel"] = state;
}

record AzazelBandMember
{
    string name;
    item [int] desired_items;
};

AzazelBandMember AzazelBandMemberMake(string name, item [int] desired_items)
{
    AzazelBandMember result;
    result.name = name;
    result.desired_items = desired_items;
    return result;
}

AzazelBandMember AzazelBandMemberMake(string name, item it1, item it2)
{
    return AzazelBandMemberMake(name, listMake(it1, it2));
}

void listAppend(AzazelBandMember [int] list, AzazelBandMember entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void QAzazelGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Azazel"];
    
    foreach consumable in $items[steel lasagna,steel margarita,steel-scented air freshener]
    {
        if (consumable.available_amount() == 0)
            continue;
        ChecklistSubentry subentry;
        
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Consume " + consumable + ".");
        optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "", subentry));
        return;
    }
    
	if (base_quest_state.finished)
		return;
    
    
    if ($skill[Stomach of Steel].have_skill() || $skill[Liver of Steel].have_skill() || $skill[Spleen of Steel].have_skill())
        return;
    
    
    //We don't suggest or give advice on this quest in-run unless the player spends an adventure in one of the zones.
    //If that happens, they're probably sure they want the consumable items.
	if (!__misc_state["In aftercore"] && $locations[The Laugh Floor, Infernal Rackets Backstage].turnsAttemptedInLocation() == 0 && $items[Azazel's unicorn,Azazel's lollipop,Azazel's tutu].available_amount() == 0)
		return;
    
        
	ChecklistEntry entry;
	entry.target_location = "pandamonium.php";
	entry.image_lookup_name = base_quest_state.image_name;
	entry.should_indent_after_first_subentry = true;
    entry.should_highlight = $locations[the laugh floor, infernal rackets backstage] contains __last_adventure_location;
    
    if (true)
    {
        ChecklistSubentry subentry;
        
        subentry.header = base_quest_state.quest_name;
        
        subentry.entries.listAppend("Gives +5 consumable space.");
        
        if ($item[Azazel's unicorn].available_amount() > 0 && $item[Azazel's lollipop].available_amount() > 0 && $item[Azazel's tutu].available_amount() > 0)
        {
            subentry.entries.listAppend("Speak to Azazel.");
        }
        entry.subentries.listAppend(subentry);
    }
    
    boolean need_imp_airs = false;
    boolean need_bus_passes = false;
    if ($item[Azazel's tutu].available_amount() == 0)
    {
        //collect 5 cans of imp air and 5 bus passes
        ChecklistSubentry subentry;
        
        subentry.header = "Azazel's tutu";
        
        int imp_air_needed = MAX(0, 5 - $item[imp air].available_amount());
        int bus_passes_needed = MAX(0, 5 - $item[bus pass].available_amount());
        if (imp_air_needed == 0 && bus_passes_needed == 0)
        {
            subentry.entries.listAppend("Speak to the stranger.");
        }
        else
        {
            if (imp_air_needed > 0)
            {
                string line;
                line = "Need " + pluralize(imp_air_needed, $item[imp air]) + ", from the laugh floor.";
                if (!in_ronin())
                    line += " Or the mall.";
                subentry.entries.listAppend(line);
                need_imp_airs = true;
            }
            if (bus_passes_needed > 0)
            {
                string line;
                line = "Need " + pluralize(bus_passes_needed, $item[bus pass]) + ", from backstage.";
                if (!in_ronin())
                    line += " Or the mall.";
                subentry.entries.listAppend(line);
                need_bus_passes = true;
            }
        }
        entry.subentries.listAppend(subentry);
    }
	
    
    if ($item[Azazel's unicorn].available_amount() == 0)
    {
        ChecklistSubentry subentry;
        
        subentry.header = "Azazel's unicorn";
        
        int [item] band_items_available;
        int band_items_found = 0;
        foreach it in $items[comfy pillow,giant marshmallow,booze-soaked cherry,sponge cake,beer-scented teddy bear,gin-soaked blotter paper]
        {
            if (it.available_amount() > 0)
                band_items_found += 1;
            band_items_available[it] = it.available_amount();
        }
        
        //Try to solve the puzzle:
        //Hmm... FIXME is there any way to determine which ones we've given to band members?
        
        AzazelBandMember [int] band_members;
        band_members.listAppend(AzazelBandMemberMake("Bognort", $item[giant marshmallow], $item[gin-soaked blotter paper]));
        band_members.listAppend(AzazelBandMemberMake("Stinkface", $item[beer-scented teddy bear], $item[gin-soaked blotter paper]));
        band_members.listAppend(AzazelBandMemberMake("Flargwurm", $item[booze-soaked cherry], $item[sponge cake]));
        band_members.listAppend(AzazelBandMemberMake("Jim", $item[comfy pillow], $item[sponge cake]));
        
        string [int] quest_completion_instructions;
        boolean can_complete_quest = true;
        foreach key in band_members
        {
            AzazelBandMember musician = band_members[key];
            boolean found_item = false;
            foreach key2 in musician.desired_items
            {
                item it = musician.desired_items[key2];
                if (band_items_available[it] > 0)
                {
                    quest_completion_instructions.listAppend("Give " + musician.name + " a " + it + ".");
                    band_items_available[it] -= 1;
                    found_item = true;
                    break;
                }
            }
            if (!found_item)
                can_complete_quest = false;
        }
        
        if (can_complete_quest)
        {
            if (need_bus_passes)
                subentry.entries.listAppend("Run +item backstage.");
            subentry.entries.listAppend("Talk to Sven.|*" + quest_completion_instructions.listJoinComponents("|*"));
        }
        else
        {
            string and_item = "";
            if (need_bus_passes)
                and_item = " and +item";
            subentry.entries.listAppend("Run -combat" + and_item + " backstage.");
            subentry.entries.listAppend("Need band components.");
            subentry.modifiers.listAppend("-combat");
        }
        if (need_bus_passes)
        {
            subentry.modifiers.listAppend("+item");
            subentry.modifiers.listAppend("olfact serialbus");
        }
        
        entry.subentries.listAppend(subentry);
    }
    if ($item[Azazel's lollipop].available_amount() == 0)
    {
        //comedy club - fight on!
        ChecklistSubentry subentry;
        
        subentry.header = "Azazel's lollipop";
        
        
        if ($item[observational glasses].available_amount() > 0)
        {
            //talk to mourn
            string line = "Talk to Mourn.";
            if ($item[observational glasses].equipped_amount() == 0)
                line = "Equip the observational glasses, talk to mourn.";
            subentry.entries.listAppend(line);
        }
        else
        {
            subentry.modifiers.listAppend("+combat");
            string and_item = "";
            if (need_imp_airs)
                and_item = " and +item";
            subentry.entries.listAppend("Run +combat" + and_item + " on the laugh floor, find Larry.");
        }
        
        if (need_imp_airs)
        {
            subentry.modifiers.listAppend("+item");
            subentry.modifiers.listAppend("olfact ch imp");
        }
        entry.subentries.listAppend(subentry);
    }
    
	
	optional_task_entries.listAppend(entry);
}

void QUntinkerInit()
{
	//questM01Untinker
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM01Untinker");
	
	state.quest_name = "Untinker's Quest";
	state.image_name = "rusty screwdriver";
	
	state.startable = locationAvailable($location[the spooky forest]);
	
	__quest_state["Untinker"] = state;
}


void QUntinkerGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Untinker"];
	if (base_quest_state.finished || !base_quest_state.startable)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string url = "";
	
	if ($item[rusty screwdriver].available_amount() > 0 || base_quest_state.mafia_internal_step == 0)
	{
		subentry.entries.listAppend("Speak to the Untinker.");
		url = "place.php?whichplace=forestvillage";
	}
	else
	{
        //Acquire rusty screwdriver:
		if (knoll_available())
		{
			subentry.entries.listAppend("Speak to Innabox in Degrassi Knoll.");
			url = "place.php?whichplace=knoll_friendly";
		}
		else
		{
            url = "place.php?whichplace=knoll_hostile";
			subentry.entries.listAppend("Retrieve screwdriver from the Degrassi Knoll Garage.|(25% superlikely)");
			if (__misc_state["free runs available"])
			{
				subentry.modifiers.listAppend("free runs");
			}
			if (__misc_state["have hipster"])
			{
				subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
			}
		}
	}
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the degrassi knoll garage]));
}

void QArtistInit()
{
	//questM02Artist
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM02Artist");
    
    if (!state.started && $items[pail of pretentious paint, pretentious paintbrush, pretentious palette].available_amount() > 0)
        QuestStateParseMafiaQuestPropertyValue(state, "started");
	
	state.quest_name = "Pretentious Artist's Quest";
	state.image_name = "__item pretentious palette";
	
	state.startable = true;
	
	__quest_state["Artist"] = state;
}


void QArtistGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Artist"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "";
	
	boolean output_modifiers = false;
	if ($item[pretentious palette].available_amount() == 0)
	{
		//haunted pantry
        if (active_url == "")
            active_url = $location[the haunted pantry].getClickableURLForLocation();
		subentry.entries.listAppend("Adventure in the haunted pantry for pretentious palette. (25% superlikely)");
		output_modifiers = true;
	}
	if ($item[pretentious paintbrush].available_amount() == 0)
	{
		//cobb's knob
        if (active_url == "")
            active_url = $location[the outskirts of Cobb's Knob].getClickableURLForLocation();
		subentry.entries.listAppend("Adventure in the outskirts of Cobb's Knob for pretentious paintbrush. (25% superlikely)");
		output_modifiers = true;
	}
	if ($item[pail of pretentious paint].available_amount() == 0)
	{
		//sleazy back alley
        if (active_url == "")
            active_url = $location[the sleazy back alley].getClickableURLForLocation();
		subentry.entries.listAppend("Adventure in the sleazy back alley for pail of pretentious paint. (25% superlikely)");
		output_modifiers = true;
	}
	
	if (output_modifiers)
	{
		if (__misc_state["free runs available"])
		{
			subentry.modifiers.listAppend("free runs");
		}
		if (__misc_state["have hipster"])
		{
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
		}
	}
	
	if ($item[pretentious palette].available_amount() > 0 && $item[pretentious paintbrush].available_amount() > 0 && $item[pail of pretentious paint].available_amount() > 0)
	{
		subentry.entries.listAppend("Talk to the pretentious artist.");
        active_url = "place.php?whichplace=town_wrong";
	}
	
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the sleazy back alley, the outskirts of cobb's knob, the haunted pantry]));
}
void QLegendaryBeatInit()
{
    if ($item[Map to Professor Jacking's laboratory].available_amount() == 0)
        return;
	//questI02Beat
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questI02Beat");
    
    if (!state.started)
    {
        requestQuestLogLoad("questI02Beat");
        QuestStateParseMafiaQuestPropertyValue(state, "started");
    }
	
	state.quest_name = "Quest for the Legendary Beat";
	state.image_name = "__item the Legendary Beat";
    
    if (state.in_progress)
    {
        //FIXME temporary code
        //no way to detect if the legendary beat was found
        //if (state.mafia_internal_step < 2 && $location[professor jacking's small-o-fier].turnsAttemptedInLocation() > 0 || $location[professor jacking's huge-a-ma-tron].turnsAttemptedInLocation() > 0)
            //state.mafia_internal_step = 2;
    }
	
	__quest_state["Legendary Beat"] = state;
}

void QLegendaryBeatGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($item[Map to Professor Jacking's laboratory].available_amount() == 0)
        return;
        
	QuestState base_quest_state = __quest_state["Legendary Beat"];
	if (!base_quest_state.in_progress)
		return;
    
    //FIXME temporary:
    if (!($locations[professor jacking's small-o-fier, professor jacking's huge-a-ma-tron] contains __last_adventure_location))
        return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
        
    //FIXME support for fruit machine sidequest?
    
    if (base_quest_state.mafia_internal_step == 1 && false)
    {
        subentry.entries.listAppend("Defeat Professor Jacking.");
    }
    else if (base_quest_state.mafia_internal_step == 2 || true)
    {
        //Main quest, in reverse order:
        if ($item[can-you-dig-it?].available_amount() > 0 && $effect[stubbly legs].have_effect() > 0)
        {
            subentry.modifiers.listAppend("-combat");
            //6/7
            string [int] tasks;
            if ($item[can-you-dig-it?].equipped_amount() == 0)
                tasks.listAppend("equip can-you-dig-it?");
            tasks.listAppend("adventure in Small-O-Fier, find non-combat, dig your way to safety");
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        else if ($item[can-you-dig-it?].available_amount() > 0 && $effect[smooth legs].have_effect() > 0)
        {
            //5
            subentry.entries.listAppend("Gaze into the mirror.");
            subentry.entries.listAppend("Before you do, though, possibly look for/copy smooth jazz scabie factoids in the Small-O-Fier.");
        }
        else if ($effect[smooth legs].have_effect() > 0)
        {
            //4
            if ($effect[literally insane].have_effect() > 0 && $effect[broken dancing].have_effect() > 0 && $item[crazyleg's razor].available_amount() > 0)
                subentry.entries.listAppend("Use Crazyleg's razor repeatedly to extend smooth legs effect.");

            subentry.modifiers.listAppend("-combat");
            subentry.modifiers.listAppend("+item");
            subentry.entries.listAppend("Adventure in Small-O-Fier, find ocean non-combat, fight a smooth jazz scabie for can-you-dig-it?");
            
        }
        else if ($effect[literally insane].have_effect() > 0 && $effect[broken dancing].have_effect() > 0 && $item[crazyleg's razor].available_amount() > 0)
        {
            //3
            subentry.entries.listAppend("Use Crazyleg's razor. (repeatedly)");
        }
        else if ($effect[literally insane].have_effect() + $item[world's most unappetizing beverage].available_amount() > 0 && $effect[broken dancing].have_effect() + $item[squirmy violent party snack].available_amount() > 0 && $item[crazyleg's razor].available_amount() > 0)
        {
            string [int] tasks;
            boolean waiting = false;
            if ($effect[literally insane].have_effect() == 0)
            {
                if (availableDrunkenness() < 1)
                {
                    waiting = true;
                    tasks.listAppend("wait until you have 1 drunkenness available");
                }
                else
                    tasks.listAppend("drink the world's most unappetizing beverage");
            }
            if ($effect[broken dancing].have_effect() == 0)
            {
                if (availableFullness() < 1)
                {
                    tasks.listAppend("wait until you have 1 fullness available");
                    waiting = true;
                }
                else if (!waiting)
                    tasks.listAppend("eat a squirmy violent party snack");
            }
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".");
        }
        else
        {
            boolean need_nc = false;
            //Need:
            //crazyleg's razor
            //literally insane / world's most unappetizing beverage / (hair of the calf and can of depilatory cream)
            //broken dancing / squirmy violent party snack / (a dance upon the palate/tiny frozen prehistoric meteorite jawbreaker)
            if ($item[crazyleg's razor].available_amount() == 0)
            {
                subentry.entries.listAppend("Acquire crazyleg's razor.|*Adventure in the Huge-A-Ma-Tron, defeat the Fearsome Wacken.");
            }
            if ($effect[literally insane].have_effect() + $item[world's most unappetizing beverage].available_amount() > 0)
            {
                //nothing, have them
            }
            else if ($item[world's most unappetizing beverage].creatable_amount() > 0)
            {
                subentry.entries.listAppend("Create the world's most unappetizing beverage.");
            }
            else
            {
                //parts:
                if ($item[hair of the calf].available_amount() == 0)
                {
                    need_nc = true;
                    subentry.entries.listAppend("Acquire hair of the calf.|*Adventure in Small-O-Fier, climb up a hair.");
                }
                if ($item[can of depilatory cream].available_amount() == 0)
                {
                    need_nc = true;
                    subentry.entries.listAppend("Acquire can of depilatory cream.|*Adventure in Small-O-Fier, find non-combat.");
                }
            }
            
            if ($effect[broken dancing].have_effect() + $item[squirmy violent party snack].available_amount() > 0)
            {
                //nothing, have them
            }
            else if ($item[squirmy violent party snack].creatable_amount() > 0)
            {
                subentry.entries.listAppend("Create a squirmy violent party snack.");
            }
            else
            {
                //parts:
                if ($item[a dance upon the palate].available_amount() == 0)
                {
                    subentry.entries.listAppend("Acquire a dance upon the palate.|*Adventure in Huge-A-Ma-Tron, crouch down and lick the world.");
                }
                if ($item[tiny frozen prehistoric meteorite jawbreaker].available_amount() == 0)
                {
                    string [int] meteorite_details;
                    
                    boolean [item] relevant_fruits = $items[blackberry, cherry, olive, plum, sea blueberry, strawberry]; //cheap ones, not all of them
                    item chosen_fruit = $item[blackberry];
                    foreach it in relevant_fruits
                    {
                        if (it.available_amount() > 0)
                        {
                            chosen_fruit = it;
                            break;
                        }
                    }
                    
                    if (chosen_fruit.available_amount() == 0)
                        meteorite_details.listAppend("Acquire a " + chosen_fruit + ".");
                    meteorite_details.listAppend("Put a " + chosen_fruit + " in the fruit machine if you haven't.");
                    if ($effect[hurricane force].have_effect() == 0)
                    {
                        need_nc = true;
                        meteorite_details.listAppend("Adventure in the Huge-A-Ma-Tron, dance on top of the world.");
                    }
                    else
                    {
                        meteorite_details.listAppend("Adventure in the Huge-A-Ma-Tron, defeat a loose coalition of yetis, snowmen, and goats.");
                    }
                    subentry.entries.listAppend("Acquire a tiny frozen prehistoric meteorite jawbreaker.|*" + meteorite_details.listJoinComponents("|*"));
                    
                    
                }
            }
            
            if (need_nc)
                subentry.modifiers.listAppend("-combat");
        }
    }
    
	task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, "", subentry, $locations[professor jacking's small-o-fier, professor jacking's huge-a-ma-tron]));
}
//Currently disabled. Complicated.

void QMemoriesInit()
{
    if (true)
        return;
    if (true)
    {
        QuestState state;
        QuestStateParseMafiaQuestProperty(state, "questF01Primordial");
        
        state.quest_name = "Primordial Fear Quest";
        state.image_name = "__item empty agua de vida bottle";
        
        
        __quest_state["Primordial Fear"] = state;
    }
    if (true)
    {
        QuestState state;
        QuestStateParseMafiaQuestProperty(state, "questF02Hyboria");
        
        state.quest_name = "Hyboria Quest";
        state.image_name = "__item empty agua de vida bottle";
        
        
        __quest_state["Hyboria"] = state;
    }
    if (true)
    {
        QuestState state;
        QuestStateParseMafiaQuestProperty(state, "questF03Future");
        
        state.quest_name = "Future Quest";
        state.image_name = "__item empty agua de vida bottle";
        
        
        __quest_state["Future"] = state;
    }
}


void QMemoriesPrimordialFearGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Primordial Fear"];
	if (!base_quest_state.in_progress)
		return;
    string active_url = "";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    //FIXME implement this
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the primordial soup]));
}

void QMemoriesHyboriaGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Hyboria"];
	if (!base_quest_state.in_progress)
		return;
    string active_url = "";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    //FIXME implement this
    
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the jungles of ancient loathing]));
}

void QMemoriesFutureGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Future"];
	if (!base_quest_state.in_progress)
		return;
    string active_url = "";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    //FIXME implement this
    
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[seaside megalopolis]));
}

void QMemoriesGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (true)
        return;
    if (__quest_state["Primordial Fear"].in_progress)
    {
        QMemoriesPrimordialFearGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    else if (__quest_state["Hyboria"].in_progress)
    {
        QMemoriesHyboriaGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    else if (__quest_state["Future"].in_progress)
    {
        QMemoriesFutureGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
}

void QWhiteCitadelInit()
{
    if (!__misc_state["In aftercore"]) //not yet
        return;
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questG02Whitecastle");
    
    //sorry, no way to query for familiar name
    state.quest_name = my_name().HTMLEscapeString() + " and Kumar Go To White Citadel";
    state.image_name = "__item White Citadel burger";
    
    
    __quest_state["White Citadel"] = state;
}

void QWhiteCitadelGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["White Citadel"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "place.php?whichplace=woods";
    
    if (true)
    {
        //FIXME temporary code
        //Somewhat inaccurate:
        int cheetahs_seen = 0;
        int holidays_seen = 0;
        string [int] noncombats_seen = $location[the road to white citadel].locationSeenNoncombats();
        foreach key in noncombats_seen
        {
            string noncombat = noncombats_seen[key];
            if (noncombat == "Cheetahs Never Lose")
                cheetahs_seen += 1;
            if (noncombat == "Summer Holiday")
                holidays_seen += 1;
        }
        
        if (base_quest_state.mafia_internal_step == 1)
        {
            if ($location[whitey's grove].noncombat_queue.contains_text("It's A Sign!"))
                base_quest_state.mafia_internal_step = 2;
        }
        if (base_quest_state.mafia_internal_step > 1)
        {
            if (base_quest_state.mafia_internal_step <3 && cheetahs_seen > 0)
            {
                base_quest_state.mafia_internal_step = 3;
            }
            if (base_quest_state.mafia_internal_step < 4 && cheetahs_seen > 1)
            {
                base_quest_state.mafia_internal_step = 4;
            }
            if (base_quest_state.mafia_internal_step < 5 && holidays_seen > 0)
            {
                base_quest_state.mafia_internal_step = 5;
            }
        }
        //6 is accurate
    }
    
    
    if (base_quest_state.mafia_internal_step == 1)
    {
        //1	You've been charged by your Guild (sort of) with the task of bringing back a delicious meal from the legendary White Citadel. You've been told it's somewhere near Whitey's Grove, in the Distant Woods.
        //Unlock the road to white citadel:
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Adventure in Whitey's Grove, unlock the road to White Citadel.");
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        //2	You've discovered the road from Whitey's Grove to the legendary White Citadel. You should explore it and see if you can find your way.
        //Find the cheetah:
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        subentry.entries.listAppend("Find a cheetah. (non-combat)");
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        //3	You're progressing down the road towards the White Citadel, but you'll need to find something that can help you get past that stupid cheetah if you're going to make it any further. Keep looking around.
        //Find "catnip" (100% drop), then find cheetah again:
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        if ($item[massive bag of catnip].available_amount() == 0)
        {
            subentry.modifiers.listAppend("+combat");
            subentry.entries.listAppend("Find a massive bag of catnip from a business hippy.");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Find a cheetah. (non-combat)");
        }
    }
    else if (base_quest_state.mafia_internal_step == 4)
    {
        //4	You've made your way further down the Road to the White Citadel, but you still haven't found it. Keep looking!
        //Find cliff:
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        subentry.entries.listAppend("Find a cliff. (non-combat)");
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //5	You've found the White Citadel, but it's at the bottom of a huge cliff. You should keep messing around on the Road until you find a way to get down the cliff.
        //Find hang glider (100% drop), then find NC again:
        subentry.entries.listAppend("Adventure on the road to White Citadel.");
        if ($item[hang glider].available_amount() == 0)
        {
            subentry.modifiers.listAppend("+combat");
            subentry.entries.listAppend("Find a hang glider from eXtreme sport orcs.");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Find a cliff. (non-combat)");
        }
    }
    else if (base_quest_state.mafia_internal_step == 6 && $item[White Citadel Satisfaction Satchel].available_amount() == 0)
    {
        //6	You have discovered the legendary White Citadel. You should probably go in there and get the carryout order you were trying to get in the first place. Funny how things spiral out of control, isn't it?
        //Visit the white citadel:
        subentry.entries.listAppend("Visit the White Citadel.");
    }
    else if (base_quest_state.mafia_internal_step == 7 || $item[White Citadel Satisfaction Satchel].available_amount() > 0)
    {
        //7	You've got the Satisfaction Satchel. Take it to your contact in your Guild for a reward.
        //Visit guild:
        subentry.entries.listAppend("Visit your friend at the guild.");
        active_url = "guild.php";
    }
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[whitey's grove, the road to white citadel]));
}

void QWizardOfEgoInit()
{
    if (!__misc_state["In aftercore"]) //not yet
        return;
    if ($items[Manual of Dexterity,Manual of Labor,Manual of Transmission].available_amount() > 0) //finished already
        return;
        
	//questM02Artist
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questG03Ego");
    
    if (!state.finished)
    {
        //FIXME temporary code
        //Update internal step locally:
        //(this is buggy)
        if (state.mafia_internal_step < 7 && $item[dusty old book].available_amount() > 0)
        {
            state.mafia_internal_step = 7;
        }
        if (state.mafia_internal_step < 1 && $location[pre-cyrpt cemetary].noncombat_queue.contains_text("A Grave Mistake") || $location[post-cyrpt cemetary].noncombat_queue.contains_text("A Grave Mistake"))
            state.mafia_internal_step = 1;
        if (state.mafia_internal_step < 2 && $location[pre-cyrpt cemetary].noncombat_queue.contains_text("A Grave Situation") || $location[post-cyrpt cemetary].noncombat_queue.contains_text("A Grave Situation"))
            state.mafia_internal_step = 2;
        
        if (state.mafia_internal_step < 2 && $item[Fernswarthy's key].available_amount() > 0)
            state.mafia_internal_step = 2;
        
        if (state.mafia_internal_step < 4 && $location[tower ruins].turnsAttemptedInLocation() > 0 && $item[Fernswarthy's key].available_amount() > 0)
            state.mafia_internal_step = 4;
        
        if (state.mafia_internal_step < 5 && $location[tower ruins].noncombat_queue.contains_text("Staring into Nothing"))
            state.mafia_internal_step = 5;
        if (state.mafia_internal_step < 6 && $location[tower ruins].noncombat_queue.contains_text("Into the Maw of Deepness"))
            state.mafia_internal_step = 6;
        if (state.mafia_internal_step < 7 && $location[tower ruins].noncombat_queue.contains_text("Take a Dusty Look!"))
            state.mafia_internal_step = 7;
        
        if (!state.in_progress && state.mafia_internal_step > 0 && $item[Fernswarthy's key].available_amount() > 0)
        {
            QuestStateParseMafiaQuestPropertyValue(state, "step" + (state.mafia_internal_step - 1));
        }
    }
	
	state.quest_name = "The Wizard of Ego";
	state.image_name = "__item dilapidated wizard hat";
	
	state.startable = true;
	
	__quest_state["Wizard of Ego"] = state;
}


void QWizardOfEgoGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Wizard of Ego"];
	if (!base_quest_state.in_progress)
		return;
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
	
	string url = "";
    if (base_quest_state.mafia_internal_step == 7 || $item[dusty old book].available_amount() > 0)
    {
        //7	You found some kind of dusty old book in Fernswarthy's tower. Hopefully that's enough to keep that guy in your guild off your case.
        url = "guild.php";
        subentry.entries.listAppend("Speak to the guild.");
    }
    else if (base_quest_state.mafia_internal_step == 1)
    {
        url = "place.php?whichplace=plains";
        //1	You've been tasked with digging up the grave of an ancient and powerful wizard and bringing back a key that was buried with him. What could possibly go wrong?
        if ($item[Fernswarthy's key].available_amount() > 0)
        {
            url = "guild.php";
            subentry.entries.listAppend("Return to your guild.");
        }
        else if ($items[grave robbing shovel, rusty grave robbing shovel].available_amount() == 0)
        {
            subentry.entries.listAppend("Acquire a grave robbing shovel. (from mall)");
        }
        else
        {
            subentry.entries.listAppend("Adventure at the misspelled cemetary.");
        }
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
        //2	Well, you got the key and turned it in -- mission accomplished. How much do you wanna bet, though, that they won't be able to find anyone else to search the tower, and you'll be stuck with the dirty work again?
        url = "guild.php";
        subentry.entries.listAppend("Speak to the guild.");
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        //3	Much as you expected, you've been given back the key to Fernswarthy's tower and ordered to investigate.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins.");
    }
    else if (base_quest_state.mafia_internal_step == 4)
    {
        //4	You've unlocked Fernswarthy's tower. Now you just have to find something to show your guild leaders, to prove you haven't just been slacking off this whole time.
        //Unlocking just means visiting the area.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins. Three more non-combats remain.");
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //5	You've found some stairs in Fernswarthy's tower, but they don't lead to much. Better keep looking.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins. Two more non-combats remain.");
    }
    else if (base_quest_state.mafia_internal_step == 6)
    {
        //6	You've found a trapdoor to Fernswarthy's basement, which is potentially interesting and/or dangerous. It's probably not what your Guild is interested in, though, so you should probably keep looking.
        url = "fernruin.php";
        subentry.modifiers.listAppend("-combat?");
        subentry.entries.listAppend("Adventure in the tower ruins. One more non-combat remain.");
    }
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[pre-cyrpt cemetary,post-cyrpt cemetary, tower ruins]));
}


void QuestsInit()
{
	QPirateInit();
	QManorInit();
	QLevel2Init();
	QLevel3Init();
	QLevel4Init();
	QLevel5Init();
	QLevel6Init();
	QLevel7Init();
	QLevel8Init();
	QLevel9Init();
	QLevel10Init();
	QLevel11Init();
	QLevel12Init();
	QLevel13Init();
	QNemesisInit();
	QSeaInit();
	QSpaceElvesInit();
	QAzazelInit();
	QUntinkerInit();
	QArtistInit();
	QLegendaryBeatInit();
	QMemoriesInit();
	QWhiteCitadelInit();
	QWizardOfEgoInit();
}


void QuestsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QLevel2GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel3GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel4GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel5GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel6GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel7GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel8GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel9GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel10GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel11GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel12GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLevel13GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
	QManorGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QPirateGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QNemesisGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QSeaGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QSpaceElvesGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QAzazelGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    
	QUntinkerGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QArtistGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QLegendaryBeatGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QMemoriesGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QWhiteCitadelGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QWizardOfEgoGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}




record Semirare
{
    location place;
    string [int] reasons;
    int importance;
};

Semirare SemirareMake(location place, string [int] reasons, int importance)
{
    Semirare result;
    result.place = place;
    result.reasons = reasons;
    result.importance = importance;
    return result;
}

Semirare SemirareMake(location place, string reason, int importance)
{
    return SemirareMake(place, listMake(reason), importance);
}

void listAppend(Semirare [int] list, Semirare entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void SemirareGenerateDescription(string [int] description)
{
	if (__misc_state_string["Turn range until semi-rare"] != "" && __misc_state["can eat just about anything"])
	{
		string line = "Eat a fortune cookie";
		if (availableFullness() == 0)
			line += " later.";
        else
            line += ".";
		description.listAppend(line);
	}
	location last_location = $location[none];
	if (get_property_int("lastSemirareReset") == my_ascensions() && get_property("semirareLocation") != "")
	{
		last_location = get_property_location("semirareLocation");
        if (last_location != $location[none])
            description.listAppend("Last semi-rare: " + last_location);
	}
	
	
    Semirare [int] semirares;
	//Generate things to do:
	if (__misc_state["In run"])
	{
		if (__misc_state["can equip just about any weapon"])
		{
			if (!have_outfit_components("Knob Goblin Elite Guard Uniform"))
			{
				string [int] reasons;
				if (!__quest_state["Level 8"].finished)
					reasons.listAppend("Cobb's Knob quest");
                if (!dispensary_available())
                    reasons.listAppend("dispensary access (+item, +familiar weight, cheapish MP)");
                if (reasons.count() > 0)
                    semirares.listAppend(SemirareMake($location[cobb's knob barracks], "|*Acquire KGE outfit for " + reasons.listJoinComponents(", ", "and"), 0));
			}
			if (!have_outfit_components("Mining Gear") && !__quest_state["Level 8"].state_boolean["Past mine"])
				semirares.listAppend(SemirareMake($location[Itznotyerzitz Mine], "|*Acquire mining gear for trapper quest.|*Run +234% item to get drop.", 0));
		}
		if ($item[stone wool].available_amount() < 2 && !locationAvailable($location[the hidden park]))
		{
			semirares.listAppend(SemirareMake($location[The Hidden Temple], "|*Acquire stone wool for unlocking hidden city.|*Run +100% item. (or up to +400% item for +3 adventures)", 0));
		}
		if ($item[Mick's IcyVapoHotness Inhaler].available_amount() == 0 && $effect[Sinuses For Miles].have_effect() == 0 && !__quest_state["Level 12"].state_boolean["Nuns Finished"])
			semirares.listAppend(SemirareMake($location[the castle in the clouds in the sky (top floor)], "|*+200% meat inhaler (10 turns), for nuns quest.", 0));
	
		//limerick dungeon - +100% item
		if ($item[cyclops eyedrops].available_amount() == 0 && $effect[One Very Clear Eye].have_effect() == 0)
			semirares.listAppend(SemirareMake($location[the limerick dungeon], "|*+100% items eyedrops (10 turns), for tomb rats and low drops.", 0));
	
        if (needMoreFamiliarWeightForTower())
        {
			semirares.listAppend(SemirareMake($location[cobb's knob menagerie\, level 2], "|*+10 familiar weight, for tower familiars.", 0));
        }
		//three turn generation SRs go here
		if (true)
		{
			Semirare food_semirares;
			food_semirares.importance = 11;
		
			string [int] line;
			if (__misc_state["can eat just about anything"] && last_location != $location[the haunted pantry])
				line.listAppend("The Haunted Pantry: 3 epic fullness food");
			if (__misc_state["can drink just about anything"] && last_location != $location[the sleazy back alley])
				line.listAppend("The Sleazy Back Alley: 3 epic drunkenness drink");
			if (__misc_state["can eat just about anything"] && __misc_state["can drink just about anything"] && last_location != $location[the outskirts of cobb's knob])
				line.listAppend("The Outskirts of Cobb's Knob: 3 epic full drunkenness food/drink");
			food_semirares.reasons.listAppend(line.listJoinComponents("|"));
			if (line.count() > 0)
				semirares.listAppend(food_semirares);
		}
	}
		
	//aftercore? sea quest, sand dollars, giant pearl
	
	sort semirares by value.importance;
	
	foreach key in semirares
	{
		Semirare sr = semirares[key];
		string [int] explanation = sr.reasons;
		
		
		if (last_location == sr.place && sr.place != $location[none])
			explanation.listAppend(HTMLGenerateSpanOfClass("Can't use yet, last semi-rare was here", "r_bold"));
		
		if (explanation.count() == 0)
			continue;
		string first = sr.place.to_string();
		if (sr.place == $location[none])
			first = "";
			
		string line;
		if (explanation.count() > 1)
		{
			line = first + HTMLGenerateIndentedText(HTMLGenerateDiv(explanation.listJoinComponents("<hr>")));
		}
		else
		{
			line = listFirstObject(explanation);
			if (line.stringHasPrefix("|") || first == "")
				line = first + line;
			else
				line = first + ": " + line;
		}
		//string line = first + HTMLGenerateIndentedText(HTMLGenerateDiv(explanation.listJoinComponents(HTMLGenerateDivOfStyle("", "border-top:1px solid;width:30%;"))));
		if (!locationAvailable(sr.place) && sr.place != $location[none])
		{
			line = HTMLGenerateDivOfClass(line, "r_future_option");
		}
		description.listAppend(line);
	}
}



void SSemirareGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task) //if from_task is false, assumed to be from resources
{
	boolean very_important = false;
	int show_up_in_tasks_turn_cutoff = 10;
	string title = "";
	int min_turns_until = -1;
	if (__misc_state_string["Turns until semi-rare"] != "")
	{
		string [int] potential_turns = split_string_mutable(__misc_state_string["Turns until semi-rare"], ",");
		
		if (potential_turns.count() == 1)
		{
			int turns_until = potential_turns[0].to_int();
			if (turns_until == 0)
			{
				very_important = true;
				title = "Semi-rare now";
			}
			else
				title = pluralize(turns_until, "turn", "turns") + " until semi-rare";
				
			min_turns_until = turns_until;
		}
		else
		{
			min_turns_until = potential_turns[0].to_int();
            foreach key in potential_turns
            {
                int value = potential_turns[key].to_int();
                if (value == 0)
                {
                    very_important = true;
                    potential_turns[key] = "Now"; //don't like editing this, possibly copy list?
                }
                else if (value < 0)
                    remove potential_turns[key];
            }
			title = potential_turns.listJoinComponents(", ", "or") + " turns until semi-rare";
		}
			
	}
	else if (__misc_state_string["Turn range until semi-rare"] != "")
	{
		string [int] turn_range_string = split_string_mutable(__misc_state_string["Turn range until semi-rare"], ",");
		if (turn_range_string.count() == 2) //should be
		{
			Vec2i turn_range = Vec2iMake(turn_range_string[0].to_int(), turn_range_string[1].to_int());
			title = "[" + turn_range_string.listJoinComponents(" to ") + "] turns until semi-rare";
			
			min_turns_until = turn_range.x;
			
			if (turn_range.x <= 0)
				very_important = true;
		}
		else
			return; //internal bug
	}
	
	if (from_task && min_turns_until > show_up_in_tasks_turn_cutoff)
		return;
	if (!from_task && min_turns_until <= show_up_in_tasks_turn_cutoff)
		return;
		
	string [int] description;
	if (title != "")
	{
		SemirareGenerateDescription(description);
	}
	
	if (title != "")
	{
		int importance = 4;
		if (very_important)
			importance = -11;
		ChecklistEntry entry = ChecklistEntryMake("__item fortune cookie", "", ChecklistSubentryMake(title, "", description), importance);
		if (very_important)
			task_entries.listAppend(entry);
		else
			optional_task_entries.listAppend(entry);
			
	}
}

void SSemirareGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SSemirareGenerateEntry(available_resources_entries, available_resources_entries, false);
}

void SSemirareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SSemirareGenerateEntry(task_entries, optional_task_entries, true);
}
void smithsnessGenerateCoalSuggestions(string [int] coal_suggestions)
{
    if (!__misc_state["In run"])
        return;
	string [item] coal_item_suggestions;
	
	if (__misc_state["can equip just about any weapon"])
	{
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            coal_item_suggestions[$item[half a purse]] = "2x smithsness meat for nuns";
		coal_item_suggestions[$item[A Light that Never Goes Out]] = "2x smithsness +item";
			
			
		if (my_class() == $class[seal clubber])
			coal_item_suggestions[$item[Meat Tenderizer is Murder]] = "weapon, +2x smithsness muscle %";
		else if (my_class() == $class[turtle tamer])
			coal_item_suggestions[$item[Ouija Board, Ouija Board]] = "weapon, +2x smithsness muscle %";
		else if (my_class() == $class[pastamancer])
			coal_item_suggestions[$item[Hand that Rocks the Ladle]] = "weapon, +2x smithsness mysticality %";
		else if (my_class() == $class[sauceror])
			coal_item_suggestions[$item[Saucepanic]] = "weapon, +myst stats, +2x smithsness mysticality %";
		else if (my_class() == $class[disco bandit])
			coal_item_suggestions[$item[Frankly Mr. Shank]] = "weapon, +2x smithsness moxie %";
		else if (my_class() == $class[accordion thief])
			coal_item_suggestions[$item[Shakespeare's Sister's Accordion]] = "weapon, +2x smithsness moxie %, useful cadenza";
		//not sure I like these suggestions based off of mainstat, but...
		else if (my_primestat() == $stat[mysticality])
			coal_item_suggestions[$item[Staff of the Headmaster's Victuals]] = "weapon, +smithsnesss spell damage";
		else if (my_primestat() == $stat[muscle])
			coal_item_suggestions[$item[Work is a Four Letter Sword]] = "weapon, +2x smithsness weapon damage";
		else if (my_primestat() == $stat[moxie])
			coal_item_suggestions[$item[Sheila Take a Crossbow]] = "weapon, +smithsness initiative";
			
			
	}
	coal_item_suggestions[$item[Hand in Glove]] = "lots of +ML";
	if ($item[dirty hobo gloves].available_amount() == 0)
		coal_item_suggestions[$item[Hand in Glove]] += " (need dirty hobo gloves)";
	else
		coal_item_suggestions[$item[Hand in Glove]] += " (have dirty hobo gloves)";
	if (knoll_available() || $item[maiden wig].available_amount() > 0)
		coal_item_suggestions[$item[Hairpiece On Fire]] = "+4 adventures, +5 smithness hat, +smithsness MP";
	if (knoll_available() || $item[frilly skirt].available_amount() > 0)
	{
		coal_item_suggestions[$item[Vicar's Tutu]] = "+5 smithsness pants, +smithsness HP";
		
		if (hippy_stone_broken())
			coal_item_suggestions[$item[Vicar's Tutu]] = coal_item_suggestions[$item[Vicar's Tutu]] + ", +3 PVP fights";
	}
	
	if (have_skill($skill[pulverize]))
		coal_suggestions.listAppend("Smash smithed weapon for more smithereens");
	foreach it in coal_item_suggestions
	{
		int number_wanted_max = 1;
		if (it.to_slot() == $slot[weapon] && it.weapon_hands() == 1)
		{
			if (have_skill($skill[double-fisted skull smashing]))
				number_wanted_max += 1;
			if (familiar_is_usable($familiar[disembodied hand]))
				number_wanted_max += 1;
		}
		
		if (it.available_amount() >= number_wanted_max)
			continue;
		string suggestion = coal_item_suggestions[it];
		coal_suggestions.listAppend(it + ": " + suggestion);
	}
}

void smithsnessGenerateSmithereensSuggestions(string [int] smithereen_suggestions) //suggestereens
{
	smithereen_suggestions.listAppend(7014.to_item().to_string() + ": free run/banish for 20 turns");
	
	if (__misc_state["can eat just about anything"] && availableFullness() >= 2)
	{
		smithereen_suggestions.listAppend("Charming Flan: 2 fullness epic food|Miserable Pie: 2 fullness awesome food, 50 turns of +10 smithsness");
	}
		
	if (__misc_state["can drink just about anything"] && availableDrunkenness() >= 2)
	{
		smithereen_suggestions.listAppend("Vulgar Pitcher: 2 drunkenness epic drink|Bigmouth: 2 drunkenness awesome drink, 50 turns of +10 smithsness");
	}
	if (!$familiar[he-boulder].familiar_is_usable())
		smithereen_suggestions.listAppend("Golden Light: Yellow ray");
	
}

void SSmithsnessGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (__misc_state["In run"] && $item[handful of smithereens].available_amount() > 0)
	{
		string [int] smithereen_suggestions;
		smithsnessGenerateSmithereensSuggestions(smithereen_suggestions);
		available_resources_entries.listAppend(ChecklistEntryMake("__item handful of smithereens", "", ChecklistSubentryMake(pluralize($item[handful of smithereens]), "", smithereen_suggestions.listJoinComponents("<hr>")), 10));
	}
	if (__misc_state["In run"] && $item[lump of Brituminous coal].available_amount() > 0)
	{
		string [int] coal_suggestions;
		smithsnessGenerateCoalSuggestions(coal_suggestions);
		available_resources_entries.listAppend(ChecklistEntryMake("__item lump of Brituminous coal", "", ChecklistSubentryMake(pluralize($item[lump of Brituminous coal]), "", coal_suggestions.listJoinComponents("<hr>")), 10));
	}
	if ($item[flaskfull of hollow].available_amount() > 0 && $effect[Merry Smithsness].have_effect() < 25 && __misc_state["In run"])
	{
		int turns_left = $effect[Merry Smithsness].have_effect();
		string [int] details;
		details.listAppend(pluralize((turns_left + 150 * $item[flaskfull of hollow].available_amount()), "turn", "turns") + " of +25 smithsness");
		if (turns_left > 0)
			details.listAppend("Effect will run out in " + pluralize(turns_left, "turn", "turns"));
		available_resources_entries.listAppend(ChecklistEntryMake("__item flaskfull of hollow", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[flaskfull of hollow]), "", details), 10));
	}
}

boolean HITSStillRelevant()
{
	if (__misc_state["Example mode"])
		return true;
	if (!__misc_state["In run"])
		return false;
	if (__quest_state["Level 13"].state_boolean["past keys"])
		return false;
	if (!__quest_state["Level 10"].finished)
		return false;
        
	return true;
}

void QHitsInit()
{
}

void QHitsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!HITSStillRelevant())
		return;
	
	ChecklistSubentry subentry;
	subentry.header = "Hole in the Sky";
	
    string active_url = "";
    //Super unclear code. Sorry.
    
    int star_charts_needed = 0;
    int stars_needed_base = 0;
    int lines_needed_base = 0;
    
    string [int] item_names_needed;
    
	if ($item[richard's star key].available_amount() == 0)
	{
		star_charts_needed += 1;
		stars_needed_base += 8;
		lines_needed_base += 7;
		item_names_needed.listAppend($item[richard's star key]);
	}
	if ($item[star hat].available_amount() == 0)
	{
		star_charts_needed += 1;
		stars_needed_base += 5;
		lines_needed_base += 3;
		item_names_needed.listAppend($item[star hat]);
	}
	if (!$familiar[star starfish].have_familiar_replacement() && !__misc_state["familiars temporarily blocked"])
	{
		star_charts_needed += 1;
		stars_needed_base += 6;
		lines_needed_base += 4;
		item_names_needed.listAppend($item[star starfish]);
	}
    int [int] stars_needed_options;
    int [int] lines_needed_options;
    string [int] needed_options_names;
	if (__misc_state["can equip just about any weapon"])
	{
		if ($item[Star crossbow].available_amount() == 0 && $item[Star staff].available_amount() == 0 && $item[Star sword].available_amount() == 0)
		{
			star_charts_needed += 1;
			//Three paths:
			stars_needed_options.listAppend(stars_needed_base + 5);
			lines_needed_options.listAppend(lines_needed_base + 6);
			needed_options_names.listAppend("star crossbow");
			
			stars_needed_options.listAppend(stars_needed_base + 6);
			lines_needed_options.listAppend(lines_needed_base + 5);
			needed_options_names.listAppend("star staff");
			
			stars_needed_options.listAppend(stars_needed_base + 7);
			lines_needed_options.listAppend(lines_needed_base + 4);
			needed_options_names.listAppend("star sword");
			
		}
	}
	if (needed_options_names.count() == 0)
	{
		stars_needed_options.listAppend(stars_needed_base + 0);
		lines_needed_options.listAppend(lines_needed_base + 0);
	}
	
	//Convert what we need total to what's remaining:
	int star_charts_remaining = MAX(0, star_charts_needed - $item[star chart].available_amount());
    int [int] stars_remaining;
    int [int] lines_remaining;
    string [int] remaining_options_names;
    
    boolean have_met_stars_requirement = true;
    boolean have_met_lines_requirement = true;
    
    foreach key in stars_needed_options
    {
    	if (needed_options_names contains key)
	    	remaining_options_names[key] = needed_options_names[key];
    	stars_remaining[key] = MAX(0, stars_needed_options[key] - $item[star].available_amount());
    	lines_remaining[key] = MAX(0, lines_needed_options[key] - $item[line].available_amount());
    	
    	if (stars_remaining[key] > 0)
    		have_met_stars_requirement = false;
    	if (lines_remaining[key] > 0)
    		have_met_lines_requirement = false;
    }
    
    if (have_met_stars_requirement)
    {
    	//Have all stars, suggest star sword (least lines)
    	//Remove non-sword:
    	foreach key in remaining_options_names
    	{
    		if (remaining_options_names[key] != "star sword")
    		{
    			remove remaining_options_names[key];
    			remove stars_remaining[key];
    			remove lines_remaining[key];
    		}
    	}
    }
    else if (have_met_lines_requirement)
    {
    	//Have all lines, suggest star crossbow (least stars)
    	//Remove non-crossbow:
    	foreach key in remaining_options_names
    	{
    		if (remaining_options_names[key] != "star crossbow")
    		{
    			remove remaining_options_names[key];
    			remove stars_remaining[key];
    			remove lines_remaining[key];
    		}
    	}
    }
    if (remaining_options_names.count() > 0)
    {
        item_names_needed.listAppend(remaining_options_names.listJoinComponents("/", ""));
    }
	
	if (item_names_needed.count() == 0)
		return;
		
	
	if ($item[steam-powered model rocketship].available_amount() == 0)
	{
		//find a way to space:
		subentry.modifiers.listAppend("-combat");
		subentry.entries.listAppend("Run -combat on the top floor of the castle for the steam-powered model rocketship.|From steampunk non-combat, unlocks Hole in the Sky.");
        active_url = "place.php?whichplace=giantcastle";
        
        
        subentry.entries.listAppend(generateTurnsToSeeNoncombat(95, 1, "", 9));
	}
	else
	{
        active_url = "place.php?whichplace=beanstalk";
		//We've made it out to space:
		subentry.entries.listAppend("Need " + item_names_needed.listJoinComponents(", ", "and") + ".");
		
		string [int] required_components;
		if (star_charts_remaining > 0)
			required_components.listAppend(pluralize(star_charts_remaining, $item[star chart]));
		foreach key in stars_remaining
		{
			string [int] line;
			if (stars_remaining[key] > 0)
				line.listAppend(pluralize(stars_remaining[key], $item[star]));
			if (lines_remaining[key] > 0)
				line.listAppend(pluralize(lines_remaining[key], $item[line]));
			string route = "";
			if (remaining_options_names contains key)
			{
				route = " (" + remaining_options_names[key];
				if (stars_remaining.count() > 1)
					route += " route";
				route += ")";
			}
			if (line.count() > 0)
				required_components.listAppend(line.listJoinComponents(" / ") + route);
		}
		if (required_components.count() > 0)
		{
			//require more components:
			if (remaining_options_names.count() <= 1)
				subentry.entries.listAppend("Need " + required_components.listJoinComponents(", ", ""));
			else
				subentry.entries.listAppend("Need:|*" + required_components.listJoinComponents("|*", "or"));
			
			if (star_charts_remaining > 1)
			{
				subentry.entries.listAppend("Olfact astronomers.");
			}
			else if (star_charts_remaining == 0) //no need for astronomers
			{
				if (my_ascensions() % 2 == 0)
					subentry.entries.listAppend("Olfact skinflute.");
				else
					subentry.entries.listAppend("Olfact camel's toe.");
			}
			if (!have_met_stars_requirement || !have_met_lines_requirement)
				subentry.modifiers.listAppend("+234% item");
		}
		else
			subentry.entries.listAppend("Can make everything.");
	}
	optional_task_entries.listAppend(ChecklistEntryMake("hole in the sky", active_url, subentry, $locations[the hole in the sky, the castle in the clouds in the sky (top floor)]));
}


void QHitsGenerateMissingItems(ChecklistEntry [int] items_needed_entries)
{
	if (!__misc_state["In run"] && !__misc_state["Example mode"])
		return;
	if (__quest_state["Level 13"].state_boolean["past keys"])
		return;
	//is this the best way to convey this information?
	//maybe all together instead? complicated...
	if ($item[richard's star key].available_amount() == 0)
	{
		string [int] oh_my_stars_and_gauze_garters;
		oh_my_stars_and_gauze_garters.listAppend($item[star chart].available_amount() + "/1 star chart");
		oh_my_stars_and_gauze_garters.listAppend($item[star].available_amount() + "/8 stars");
		oh_my_stars_and_gauze_garters.listAppend($item[line].available_amount() + "/7 lines");
		items_needed_entries.listAppend(ChecklistEntryMake("__item richard's star key", "", ChecklistSubentryMake("Richard's star key", "", oh_my_stars_and_gauze_garters.listJoinComponents(", ", "and"))));
	}
	
	if ($item[star hat].available_amount() == 0)
	{
		string [int] oh_my_stars_and_gauze_garters;
		oh_my_stars_and_gauze_garters.listAppend($item[star chart].available_amount() + "/1 star chart");
		oh_my_stars_and_gauze_garters.listAppend($item[star].available_amount() + "/5 stars");
		oh_my_stars_and_gauze_garters.listAppend($item[line].available_amount() + "/3 lines");
		items_needed_entries.listAppend(ChecklistEntryMake("__item star hat", "", ChecklistSubentryMake("Star hat", "", oh_my_stars_and_gauze_garters.listJoinComponents(", ", "and"))));
	}
	if ($item[star crossbow].available_amount() + $item[star staff].available_amount() + $item[star sword].available_amount() == 0)
	{
		string [int] oh_my_stars_and_gauze_garters;
		oh_my_stars_and_gauze_garters.listAppend($item[star chart].available_amount() + "/1 star chart");
		oh_my_stars_and_gauze_garters.listAppend($item[star].available_amount() + "/[5, 6, or 7] stars");
		oh_my_stars_and_gauze_garters.listAppend($item[line].available_amount() + "/[6, 5, or 4] lines");
		items_needed_entries.listAppend(ChecklistEntryMake("__item star crossbow", "", ChecklistSubentryMake("Star crossbow, staff, or sword", "", oh_my_stars_and_gauze_garters.listJoinComponents(", ", "and"))));
	}
	if (!have_familiar_replacement($familiar[star starfish]) && !__misc_state["familiars temporarily blocked"])
	{
		if ($item[star starfish].available_amount() > 0)
		{
			items_needed_entries.listAppend(ChecklistEntryMake("__item star starfish", "", ChecklistSubentryMake("Star starfish", "", "You have one, use it.")));
		}
		else
		{
			string [int] oh_my_stars_and_gauze_garters;
			oh_my_stars_and_gauze_garters.listAppend($item[star chart].available_amount() + "/1 star chart");
			oh_my_stars_and_gauze_garters.listAppend($item[star].available_amount() + "/6 stars");
			oh_my_stars_and_gauze_garters.listAppend($item[line].available_amount() + "/4 lines");
			items_needed_entries.listAppend(ChecklistEntryMake("__item star starfish", "", ChecklistSubentryMake("Star starfish", "", oh_my_stars_and_gauze_garters.listJoinComponents(", ", "and"))));
		}
	}
}
void SFamiliarsGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
	if (get_property_int("_badlyRomanticArrows") == 0 && (familiar_is_usable($familiar[obtuse angel]) || familiar_is_usable($familiar[reanimated reanimator])))
	{
        if (!__misc_state["In aftercore"] && !from_task)
            return;
        if (__misc_state["In aftercore"] && from_task)
            return;
		string familiar_image = __misc_state_string["obtuse angel name"];
        string [int] description;
        string title = "Arrow monster";
        if (familiar_image == "reanimated reanimator")
            title = "Wink at monster";
        string url;
        if (!($familiars[obtuse angel, reanimated reanimator] contains my_familiar()))
            url = "familiar.php";
		
		if ($familiar[reanimated reanimator].familiar_is_usable() || ($familiar[obtuse angel].familiar_is_usable() && $familiar[obtuse angel].familiar_equipment() == $item[quake of arrows]))
            description.listAppend("Three wandering copies.");
        else
            description.listAppend("Two wandering copies.");
		
		string [int] potential_targets;
        //a short list:
        if (__quest_state["Level 7"].state_int["alcove evilness"] > 31)
            potential_targets.listAppend("modern zmobie");
            
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"] && $items[ninja rope,ninja carabiner,ninja crampons].available_amount() == 0 && !have_outfit_components("eXtreme Cold-Weather Gear"))
            potential_targets.listAppend("ninja assassin");
        
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
            potential_targets.listAppend("lobsterfrogman");
        
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"] && have_outfit_components("Frat Warrior Fatigues") && have_outfit_components("War Hippy Fatigues")) //brigand trick
            potential_targets.listAppend("brigand");
        
        if (!familiar_is_usable($familiar[angry jung man]) && in_hardcore() && !__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0 && __misc_state["fax accessible"])
            potential_targets.listAppend("ghost");
        
        if ($items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner].available_amount() > 0 || $skill[summon brickos].have_skill())
            potential_targets.listAppend("BRICKO monster");
        
        if (potential_targets.count() > 0)
            description.listAppend("Possibly a " + potential_targets.listJoinComponents(", ", "or") + ".");
        
		optional_task_entries.listAppend(ChecklistEntryMake(familiar_image, url, ChecklistSubentryMake(title, "", description), 6));
	}
}

void SFamiliarsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (__misc_state["free runs usable"] && ($familiar[pair of stomping boots].familiar_is_usable() || (have_skill($skill[the ode to booze]) && $familiar[Frumious Bandersnatch].familiar_is_usable())))
	{
		int runaways_used = get_property_int("_banderRunaways");
		string name = runaways_used + " familiar runaways used";
		string [int] description;
		string image_name = "";
        
        string url = "";
		
		if ($familiar[Frumious Bandersnatch].familiar_is_usable() && $skill[the ode to booze].have_skill())
		{
			image_name = "Frumious Bandersnatch";
		}
		else if ($familiar[pair of stomping boots].familiar_is_usable())
		{
			image_name = "pair of stomping boots";
		}
        
        if (!($familiars[Frumious Bandersnatch, pair of stomping boots] contains my_familiar()))
            url = "familiar.php";
		int snow_suit_runs = floor(numeric_modifier($item[snow suit], "familiar weight") / 5.0);
		
		if ($item[snow suit].available_amount() == 0)
			snow_suit_runs = 0;
			
		if (snow_suit_runs >= 2)
			description.listAppend("Snow Suit available (+" + snow_suit_runs + " runs)");
		else if ($item[sugar shield].available_amount() > 0)
			description.listAppend("Sugar shield available (+2 runs)");
			
			
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(name, "", description)));
	}
	
	if (true)
	{
		int hipster_fights_available = __misc_state_int["hipster fights available"];
			
		if (($familiar[artistic goth kid].familiar_is_usable() || $familiar[Mini-Hipster].familiar_is_usable()) && hipster_fights_available > 0)
		{
			string name = "";
			string [int] description;
				
			name = pluralize(hipster_fights_available, __misc_state_string["hipster name"] + " fight", __misc_state_string["hipster name"] + " fights") + " available";
			
			int [int] hipster_chances;
			hipster_chances[7] = 50;
			hipster_chances[6] = 40;
			hipster_chances[5] = 30;
			hipster_chances[4] = 20;
			hipster_chances[3] = 10;
			hipster_chances[2] = 10;
			hipster_chances[1] = 10;
            
            string url = "";
            if (!($familiars[artistic goth kid,mini-hipster] contains my_familiar()))
                url = "familiar.php";
			
			description.listAppend(hipster_chances[hipster_fights_available] + "% chance of appearing.");
			int importance = 0;
            if (!__misc_state["In run"])
                importance = 6;
			available_resources_entries.listAppend(ChecklistEntryMake(__misc_state_string["hipster name"], url, ChecklistSubentryMake(name, "", description), importance));
		}
	}
	
	
	if ($familiar[nanorhino].familiar_is_usable() && get_property_int("_nanorhinoCharge") == 100)
	{
		ChecklistSubentry [int] subentries;
		string [int] description_banish;
		
        string url = "";
        
        if (my_familiar() != $familiar[nanorhino])
            url = "familiar.php";
		
        if (get_property("_nanorhinoBanishedMonster") != "")
            description_banish.listAppend(get_property("_nanorhinoBanishedMonster").HTMLEscapeString().capitalizeFirstLetter() + " currently banished.");
        else
            description_banish.listAppend("All day. Cast muscle combat skill.");
		if (__misc_state["have muscle class combat skill"])
			subentries.listAppend(ChecklistSubentryMake("Nanorhino Banish", "", description_banish));
		if (__misc_state["need to level"] && __misc_state["have mysticality class combat skill"])
			subentries.listAppend(ChecklistSubentryMake("Nanorhino Gray Goo", "", "130? mainstat, fire against non-item monster with >90 attack. Cast mysticality combat skill."));
		if (!$familiar[he-boulder].familiar_is_usable() && __misc_state["have moxie class combat skill"] && __misc_state["In run"])
			subentries.listAppend(ChecklistSubentryMake("Nanorhino Yellow Ray", "", "Cast moxie combat skill."));
		if (subentries.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__familiar nanorhino", url, subentries, 5));
	}
	if (__misc_state["yellow ray available"] && !__misc_state["In run"])
    {
        available_resources_entries.listAppend(ChecklistEntryMake(__misc_state_string["yellow ray image name"], "", ChecklistSubentryMake("Yellow ray available", "", "From " + __misc_state_string["yellow ray source"] + "."), 6));
    }
    
    if (my_familiar() == $familiar[happy medium] || $familiar[happy medium].charges > 0 && $familiar[happy medium].familiar_is_usable()) //|| stuff
    {
        //FIXME request support for tracking medium combats.
        string title;
        string [int] description;
        
        int charges = $familiar[happy medium].charges;
        int siphons = get_property_int("_mediumSiphons");
        
        int adventures_to_next_at_most = 3 + siphons;
        
        if (charges == 3)
        {
            title = "Red medium";
            description.listAppend("4.25 turns/drunkenness.");
        }
        else if (charges == 2)
        {
            title = "Orange medium";
            description.listAppend("3.25 turns/drunkenness.");
            description.listAppend(pluralizeWordy(adventures_to_next_at_most, "turn", "turns").capitalizeFirstLetter() + " (at most) to red.");
        }
        else if (charges == 1)
        {
            title = "Blue medium";
            description.listAppend("2.25 turns/drunkenness.");
            description.listAppend(pluralizeWordy(adventures_to_next_at_most, "turn", "turns").capitalizeFirstLetter() + " (at most) to orange.");
        }
        else
        {
            title = "Uncharged medium";
            description.listAppend(pluralizeWordy(adventures_to_next_at_most, "turn", "turns").capitalizeFirstLetter() + " (at most) to blue. ");
        }
        string url;
        if (my_familiar() != $familiar[happy medium])
            url = "familiar.php";
        
        int importance = 6;
        if (my_familiar() == $familiar[happy medium] || charges > 0)
            importance = 0;
        available_resources_entries.listAppend(ChecklistEntryMake("__familiar happy medium", url, ChecklistSubentryMake(title, "", description), importance));
    }
    if (my_familiar() == $familiar[steam-powered cheerleader] || $familiar[steam-powered cheerleader].familiar_is_usable() && get_property_int("_cheerleaderSteam") < 200)
    {
        string title;
        string [int] description;
        
        int steam_remaining = get_property_int("_cheerleaderSteam");
        float multiplier = 1.0;
        float next_multiplier_level = 1.0;
        
        int next_steam_level = 0;
        
        boolean has_socket_set = $familiar[steam-powered cheerleader].familiar_equipped_equipment() == $item[school spirit socket set];
        
        if (steam_remaining >= 151)
        {
            multiplier = 1.4;
            next_multiplier_level = 1.3;
            next_steam_level = 150;
        }
        else if (steam_remaining >= 101)
        {
            multiplier = 1.3;
            next_multiplier_level = 1.2;
            next_steam_level = 100;
        }
        else if (steam_remaining >= 51)
        {
            multiplier = 1.2;
            next_multiplier_level = 1.1;
            next_steam_level = 50;
        }
        else if (steam_remaining >= 1)
        {
            multiplier = 1.1;
            next_multiplier_level = 1.0;
            next_steam_level = 0;
        }
        
        int steam_at_this_level_remaining = steam_remaining - next_steam_level;
        int turns_remaining_at_this_level = steam_at_this_level_remaining;
        if (!has_socket_set)
            turns_remaining_at_this_level = turns_remaining_at_this_level / 2;
        
        
        
        title = multiplier + "x fairy steam-powered cheerleader";
        
        if (turns_remaining_at_this_level > 0)
            description.listAppend(pluralize(turns_remaining_at_this_level, "turn remains", "turns remain") + " until " + next_multiplier_level + "x.");
        
        int importance = 6;
        if (my_familiar() == $familiar[steam-powered cheerleader])
            importance = 0;
        
    
        string url;
        if (my_familiar() != $familiar[steam-powered cheerleader])
            url = "familiar.php";
        
        
        available_resources_entries.listAppend(ChecklistEntryMake("__familiar steam-powered cheerleader", url, ChecklistSubentryMake(title, "", description), importance));
    }
    
    //FIXME small medium, organ grinder, charged boots
	SFamiliarsGenerateEntry(available_resources_entries, available_resources_entries, false);
}

void SFamiliarsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_familiar() == $familiar[none] && !__misc_state["single familiar run"] && !__misc_state["familiars temporarily blocked"])
	{
		string image_name = "black cat";
		optional_task_entries.listAppend(ChecklistEntryMake(image_name, "familiar.php", ChecklistSubentryMake("Bring along a familiar", "", "")));
	}
	SFamiliarsGenerateEntry(task_entries, optional_task_entries, true);
}


void SDispensaryGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	//Not sure how I feel about this. The dispensary is very useful, but not necessary to complete an ascension.
	if (dispensary_available())
		return;
	if (!__misc_state["can equip just about any weapon"]) //need to wear KGE to learn the password
		return;
	
	if (!__quest_state["Level 5"].started || !locationAvailable($location[cobb's knob barracks]))
		return;
	
	ChecklistSubentry subentry;
	subentry.header = "Unlock Cobb's Knob Dispensary";
	
	string [int] dispensary_advantages;
	if (!black_market_available() && !__misc_state["MMJs buyable"])
		dispensary_advantages.listAppend("MP Restorative");
	dispensary_advantages.listAppend("+30% meat");
	dispensary_advantages.listAppend("+15% items");
	if (my_path_id() != PATH_BEES_HATE_YOU && !__misc_state["familiars temporarily blocked"])
		dispensary_advantages.listAppend("+5 familiar weight");
	dispensary_advantages.listAppend("+1 mainstat/fight");
	
	if (dispensary_advantages.count() > 0)
		subentry.entries.listAppend("Access to " + dispensary_advantages.listJoinComponents(", ", "and") + " buff items");
		
	if ($item[Cobb's Knob lab key].available_amount() == 0)
		subentry.entries.listAppend("Find the cobb's knob lab key either laying around, or defeat the goblin king.");
	else
	{
		if (have_outfit_components("Knob Goblin Elite Guard Uniform"))
		{
			if (!is_wearing_outfit("Knob Goblin Elite Guard Uniform"))
				subentry.entries.listAppend("Wear KGE outfit, adventure in Cobb's Knob Barracks.");
			else
				subentry.entries.listAppend("Adventure in Cobb's Knob Barracks.");
		}
		else
			subentry.entries.listAppend("Acquire KGE outfit");
	}
	optional_task_entries.listAppend(ChecklistEntryMake("Dispensary", "cobbsknob.php", subentry, 10));
}

void SSkillsGenerateResource(ChecklistEntry [int] available_resources_entries)
{	
	if (have_skill($skill[inigo's incantation of inspiration]))
	{
		int inigos_casts_remaining = 5 - get_property_int("_inigosCasts");
		string description = "";
		string [int] potential_options;
		if ($item[knob cake].available_amount() == 0 && !__quest_state["Level 6"].finished)
			potential_options.listAppend("knob cake");
		if (__misc_state["can eat just about anything"])
			potential_options.listAppend("food");
		if (__misc_state["can drink just about anything"])
			potential_options.listAppend("drink");
		if (have_skill($skill[advanced saucecrafting]))
			potential_options.listAppend("sauceror potions");
		description = potential_options.listJoinComponents(", ").capitalizeFirstLetter();
		if (inigos_casts_remaining > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__effect Inigo's Incantation of Inspiration", "skills.php", ChecklistSubentryMake(pluralize(inigos_casts_remaining, "Inigo's cast", "Inigo's casts") + " remaining", "", description), 4));
	}
	ChecklistSubentry [int] subentries;
	int importance = 11;
	
	string [skill] skills_to_details;
	
	skill [string][int] property_summons_to_skills;
	int [string] property_summon_limits;
	
	property_summons_to_skills["reagentSummons"] = listMake($skill[advanced saucecrafting], $skill[the way of sauce]);
	property_summons_to_skills["noodleSummons"] = listMake($skill[Pastamastery], $skill[Transcendental Noodlecraft]);
	property_summons_to_skills["cocktailSummons"] = listMake($skill[Advanced Cocktailcrafting], $skill[Superhuman Cocktailcrafting]);
	property_summons_to_skills["_coldOne"] = listMake($skill[Grab a Cold One]);
	property_summons_to_skills["_spaghettiBreakfast"] = listMake($skill[spaghetti breakfast]);
	property_summons_to_skills["_discoKnife"] = listMake($skill[that's not a knife]);
	property_summons_to_skills["_lunchBreak"] = listMake($skill[lunch break]);
    
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
    {
		property_summons_to_skills["_petePartyThrown"] = listMake(lookupSkill("Throw Party"));
		property_summons_to_skills["_peteRiotIncited"] = listMake(lookupSkill("Incite Riot"));
        
        int audience_max = 30;
        if (lookupItem("Sneaky Pete's leather jacket").equipped_amount() > 0 || lookupItem("Sneaky Pete's leather jacket (collar popped)").equipped_amount() > 0)
            audience_max = 50;
        
        skills_to_details[lookupSkill("Throw Party")] = "Ideally have " + audience_max + " audience love before casting.";
        skills_to_details[lookupSkill("Incite Riot")] = "Ideally have " + audience_max + " audience hate before casting.";
    }
	//Jarlsberg:
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG)
	{
		property_summons_to_skills["_jarlsCreamSummoned"] = listMake($skill[Conjure Cream]);
		property_summons_to_skills["_jarlsEggsSummoned"] = listMake($skill[Conjure Eggs]);
		property_summons_to_skills["_jarlsDoughSummoned"] = listMake($skill[Conjure Dough]);
		property_summons_to_skills["_jarlsVeggiesSummoned"] = listMake($skill[Conjure Vegetables]);
		property_summons_to_skills["_jarlsCheeseSummoned"] = listMake($skill[Conjure Cheese]);
		property_summons_to_skills["_jarlsPotatoSummoned"] = listMake($skill[Conjure Potato]);
		property_summons_to_skills["_jarlsMeatSummoned"] = listMake($skill[Conjure Meat Product]);
		property_summons_to_skills["_jarlsFruitSummoned"] = listMake($skill[Conjure Fruit]);
	}
	if (my_path_id() == PATH_AVATAR_OF_BORIS)
	{
		property_summons_to_skills["_demandSandwich"] = listMake($skill[Demand Sandwich]);
		property_summon_limits["_demandSandwich"] = 3;
	}
    
	property_summons_to_skills["_requestSandwichSucceeded"] = listMake($skill[Request Sandwich]);
    
    property_summons_to_skills["grimoire1Summons"] = listMake($skill[Summon Hilarious Objects]);
    property_summons_to_skills["grimoire2Summons"] = listMake($skill[Summon Tasteful Items]);
    property_summons_to_skills["grimoire3Summons"] = listMake($skill[Summon Alice's Army Cards]);
    property_summons_to_skills["_grimoireGeekySummons"] = listMake($skill[Summon Geeky Gifts]);
	
	
	item summoned_knife = $item[none];
	if (my_level() < 4)
		summoned_knife = $item[boot knife];
	else if (my_level() < 6)
		summoned_knife = $item[broken beer bottle];
	else if (my_level() < 8)
		summoned_knife = $item[sharpened spoon];
	else if (my_level() < 11)
		summoned_knife = $item[candy knife];
	else
		summoned_knife = $item[soap knife];
	if (summoned_knife.available_amount() > 0 && summoned_knife != $item[none])
    {
        //already have the knife, don't annoy them:
        remove property_summons_to_skills["_discoKnife"];
		//skills_to_details[$skill[that's not a knife]] = "Closet " + summoned_knife + " first.";
    }
	
	foreach property in property_summons_to_skills
	{
		if (get_property_int(property) > property_summon_limits[property] || get_property_boolean(property))
			continue;
		foreach key in property_summons_to_skills[property]
		{
			skill s = property_summons_to_skills[property][key];
			if (!s.have_skill())
				continue;
				
			string line = s.to_string();
			string [int] description;
			if (s.mp_cost() > 0)
			{
				line += " (" + s.mp_cost() + " MP)";
				//description.listAppend(s.mp_cost() + " MP");
			}
			string details = skills_to_details[s];
			if (details != "")
				description.listAppend(details);
			
			subentries.listAppend(ChecklistSubentryMake(line, "", description));
			break;
		}
	}
	
	if (subentries.count() > 0)
	{
		subentries.listPrepend(ChecklistSubentryMake("Skill summons:"));
		ChecklistEntry entry = ChecklistEntryMake("__item Knob Goblin love potion", "skills.php", subentries, importance);
		entry.should_indent_after_first_subentry = true;
		available_resources_entries.listAppend(entry);
	}
}
void SMiscItemsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	int importance_level_item = 7;
	int importance_level_unimportant_item = 8;
    
    boolean in_run = __misc_state["In run"];
    
	int navel_percent_chance_of_runaway = 20;
	if (true)
	{
        //Look up navel ring chances:
		int [int] navel_ring_runaway_chance;
		navel_ring_runaway_chance[0] = 100;
		navel_ring_runaway_chance[1] = 100;
		navel_ring_runaway_chance[2] = 100;
		navel_ring_runaway_chance[3] = 80;
		navel_ring_runaway_chance[4] = 80;
		navel_ring_runaway_chance[5] = 80;
		navel_ring_runaway_chance[6] = 50;
		navel_ring_runaway_chance[7] = 50;
		navel_ring_runaway_chance[8] = 50;
		navel_ring_runaway_chance[9] = 20;
		int navel_runaway_progress = get_property_int("_navelRunaways");
        
		if (navel_ring_runaway_chance contains navel_runaway_progress)
            navel_percent_chance_of_runaway = navel_ring_runaway_chance[navel_runaway_progress];
	}
	
	if ($item[navel ring of navel gazing].available_amount() > 0)
	{
		string name = "Navel Ring runaways";
        
        string url = "";
        if ($item[navel ring of navel gazing].equipped_amount() == 0)
            url = "inventory.php?which=2";
		
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item navel ring of navel gazing", url, ChecklistSubentryMake(name, "", description)));
	}
	
	if ($item[greatest american pants].available_amount() > 0)
	{
		string name = "Greatest American Pants";
		
        string url = "";
        if ($item[greatest american pants].equipped_amount() == 0)
            url = "inventory.php?which=2";
        
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
        
        int buffs_remaining = 5 - get_property_int("_gapBuffs");
        if (buffs_remaining > 0)
            description.listAppend(pluralize(buffs_remaining, "buff", "buffs") + " remaining.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item greatest american pants", url, ChecklistSubentryMake(name, "", description)));
	}
	if ($item[peppermint parasol].available_amount() > 0 && in_run) //don't think we want to use the parasol in aftercore, it's expensive
	{
		int parasol_progress = get_property_int("parasolUsed");
		string name = "";
		
		name = parasol_progress + "/10 peppermint parasol uses";
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item peppermint parasol", "", ChecklistSubentryMake(name, "", description)));
	}
	if ($item[pantsgiving].available_amount() > 0)
	{
		ChecklistSubentry subentry = ChecklistSubentryMake("Pantsgiving", "", "");
        
        string url = "";
        
        if ($item[pantsgiving].equipped_amount() == 0)
            url = "inventory.php?which=2";
		
		
		int banishes_available = 5 - get_property_int("_pantsgivingBanish");
		if (banishes_available > 0)
        subentry.entries.listAppend(pluralize(banishes_available, "banish", "banishes") + " available.");
        
		int pantsgiving_fullness_used = get_property_int("_pantsgivingFullness");
		int pantsgiving_adventures_used = get_property_int("_pantsgivingCount");
		int pantsgiving_pocket_crumbs_found = get_property_int("_pantsgivingCrumbs");
		int pantsgiving_potential_crumbs_remaining = 10 - pantsgiving_pocket_crumbs_found;
		
		int adventures_needed_for_fullness_boost = 5 * powi(10, pantsgiving_fullness_used);
		int adventures_needed_for_fullness_boost_x2 = 5 * powi(10, 1 + pantsgiving_fullness_used);
		
		if (adventures_needed_for_fullness_boost > pantsgiving_adventures_used)
		{
			int number_left = adventures_needed_for_fullness_boost - pantsgiving_adventures_used;
			subentry.entries.listAppend(pluralize(number_left, "adventure", "adventures") + " until next fullness.");
		}
		else //already there
		{
			string extra_fullness_available = "Fullness";
			if (pantsgiving_adventures_used > adventures_needed_for_fullness_boost_x2)
            extra_fullness_available = "2x fullness";
			if (availableFullness() == 0)
			{
				subentry.entries.listAppend(extra_fullness_available + " available next adventure.");
			}
			else
                subentry.entries.listAppend(extra_fullness_available + " available when you're full.");
		}
		
		if (pantsgiving_potential_crumbs_remaining > 0)
			subentry.entries.listAppend(pluralize(pantsgiving_potential_crumbs_remaining, " pocket crumb item", " pocket crumb items") + " left.");
		
		if (subentry.entries.count() > 0)
		{
			ChecklistEntry entry = ChecklistEntryMake("__item pantsgiving", url, subentry);
			entry.should_indent_after_first_subentry = true;
			available_resources_entries.listAppend(entry);
		}
	}
    
    
    
    if (__misc_state["free runs usable"] && in_run && $item[bottle of blank-out].available_amount() > 0)
	{
		string [int] description;
		string name;
		int blankout_count = $item[bottle of blank-out].available_amount();
		name += pluralize(blankout_count, "blank-out", "blank-out");
        
		if ($item[glob of blank-out].available_amount() == 0)
            description.listAppend("Use blank-out for glob.");
        if (get_property_boolean("_blankOutUsed"))
            description.listAppend("Will have to wait until tomorrow to open.");
        
		available_resources_entries.listAppend(ChecklistEntryMake("__item Bottle of Blank-Out", "inventory.php?which=3", ChecklistSubentryMake(name, "", description)));
	}
    if (__misc_state["free runs usable"] && $item[glob of blank-out].available_amount() > 0)
    {
		int uses_remaining = 5 - get_property_int("blankOutUsed");
		string [int] description;
		string name;
        description.listAppend("Use glob of blank-out in combat.");
        if (!in_run)
            description.listAppend("Will disappear when you ascend.");
        
        name = pluralize(uses_remaining, "blank-out runaway", "blank-out runaways");
		available_resources_entries.listAppend(ChecklistEntryMake("__item glob of blank-out", "", ChecklistSubentryMake(name, "", description)));
    }

	if ($item[BitterSweetTarts].available_amount() > 0 && __misc_state["need to level"])
	{
		int modifier = min(11, my_level());
		string [int] description;
		description.listAppend("+" + modifier + " stats/fight, 10 turns");
		if (my_level() < 11)
		{
			description.listAppend("Wait until level 11 for full effectiveness");
		}
		available_resources_entries.listAppend(ChecklistEntryMake("__item BitterSweetTarts", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[BitterSweetTarts]), "", description), importance_level_item));
	}
	if ($item[polka pop].available_amount() > 0 && in_run)
	{
		int modifier = 5 * min(11, my_level());
		string [int] description;
        description.listAppend("+" + modifier + "% item, " + "+" + modifier + "% meat");
		if (my_level() < 11)
		{
			description.listAppend("Wait until level 11 for full effectiveness");
		}
		available_resources_entries.listAppend(ChecklistEntryMake("__item polka pop", "", ChecklistSubentryMake(pluralize($item[polka pop]), "10 turns", description), importance_level_item));
	}
        
    if (lookupItem("frost flower").available_amount() > 0 && in_run)
    {
        string [int] description;
        description.listAppend("+100% item, +200% meat, +25 ML, +100% init");
        available_resources_entries.listAppend(ChecklistEntryMake("__item frost flower", "inventory.php?which=3", ChecklistSubentryMake(lookupItem("frost flower").pluralize(), "50 turns", description), importance_level_item));
    }
	if (in_run)
	{
		string [item] resolution_descriptions;
		resolution_descriptions[$item[resolution: be happier]] = "+15% item (20 turns)";
		//resolution_descriptions[$item[resolution:be feistier]] = "+20 spell damage"; //information overload?
		if (__misc_state["need to level"])
		{
			resolution_descriptions[$item[resolution: be stronger]] = "+2 muscle stats/combat (20 turns)";
			resolution_descriptions[$item[resolution: be smarter]] = "+2 mysticality stats/combat (20 turns)";
			resolution_descriptions[$item[resolution: be sexier]] = "+2 moxie stats/combat (20 turns)";
		}
		resolution_descriptions[$item[resolution: be kinder]] = "+5 familiar weight (20 turns)";
		resolution_descriptions[$item[resolution: be luckier]] = "+5% item, +5% meat, +10% init, others (20 turns)"; //???
		resolution_descriptions[$item[resolution: be more adventurous]] = "+2 adventures at rollover";
		resolution_descriptions[$item[resolution: be wealthier]] = "+30% meat";
        
        
	
		ChecklistSubentry [int] resolution_lines;
		foreach it in resolution_descriptions
		{
			if (it.available_amount() == 0)
				continue;
			string description = resolution_descriptions[it];
			
			resolution_lines.listAppend(ChecklistSubentryMake(pluralize(it), "",  description));
		}
		if (resolution_lines.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item resolution: be luckier", "inventory.php?which=3", resolution_lines, importance_level_item));
			
	}
	if (in_run)
	{
        //doesn't show how much, because wahh I don't wanna write taffy code
		string [item] taffy_descriptions;
		taffy_descriptions[$item[pulled yellow taffy]] = "+meat, +item";
		if (__misc_state["need to level"])
		{
            taffy_descriptions[$item[pulled red taffy]] = "+moxie stats/fight";
            taffy_descriptions[$item[pulled orange taffy]] = "+muscle stats/fight";
            taffy_descriptions[$item[pulled violet taffy]] = "+mysticality stats/fight";
		}
		taffy_descriptions[$item[pulled blue taffy]] = "+familiar weight, +familiar experience";
        string image_name = "";
		ChecklistSubentry [int] taffy_lines;
		foreach it in taffy_descriptions
		{
			if (it.available_amount() == 0)
				continue;
			string description = taffy_descriptions[it];
			if (image_name == "")
                image_name = "__item " + it;
			taffy_lines.listAppend(ChecklistSubentryMake(pluralize(it), "",  description));
		}
		if (taffy_lines.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake(image_name, "", taffy_lines, importance_level_item));
			
	}
	
	
	
	if (in_run)
	{
		if (7014.to_item().available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item " + 7014.to_item().to_string(), "", ChecklistSubentryMake(pluralize(7014.to_item()), "", "Free run, banish for 20 turns"), importance_level_item));
		if ($item[crystal skull].available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item crystal skull", "", ChecklistSubentryMake(pluralize($item[crystal skull]), "", "Turn-costing banishing"), importance_level_item));
            
		if ($item[harold's bell].available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item harold's bell", "", ChecklistSubentryMake(pluralize($item[harold's bell]), "", "Turn-costing banishing"), importance_level_item));
        
		if ($item[lost key].available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item lost key", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[lost key]), "", "Lost pill bottle is mini-fridge, take a nap, open the pill bottle"), importance_level_item));
			
		if ($item[soft green echo eyedrop antidote].available_amount() > 0 && have_skill($skill[Transcendent Olfaction]))
			available_resources_entries.listAppend(ChecklistEntryMake("__item soft green echo eyedrop antidote", "", ChecklistSubentryMake(pluralize($item[soft green echo eyedrop antidote]), "", "Removes on the trail, teleportitis"), importance_level_unimportant_item));
			
		if ($item[sack lunch].available_amount() > 0)
		{
			string [int] description;
			int importance = importance_level_item;
			if (my_level() < 11)
			{
				description.listAppend("Wait until level 11+ to open for best food.");
				importance = importance_level_unimportant_item;
			}
			else
			{
				description.listAppend("Safe to open.");
			}
			available_resources_entries.listAppend(ChecklistEntryMake("__item sack lunch", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[sack lunch]), "", description), importance));
		}
        
        if (true)
        {
			ChecklistSubentry [int] subentries;
            string image_name = "";
            
            string [item] descriptions;
            descriptions[$item[NPZR chemistry set]] = "Open for 20 invisibility/irresistibility/irritability potions.";
            descriptions[$item[invisibility potion]] = "-5% combat (20 turns)";
            descriptions[$item[irresistibility potion]] = "+5% combat (20 turns)";
            descriptions[$item[irritability potion]] = "+15 ML (20 turns)";
            
            foreach it in $items[NPZR chemistry set,invisibility potion,irresistibility potion,irritability potion]
            {
                if (it.available_amount() == 0)
                    continue;
                if (image_name.length() == 0)
                    image_name = "__item " + it;
                    
                subentries.listAppend(ChecklistSubentryMake(pluralize(it), "", descriptions[it]));
            }
            
            if (subentries.count() > 0)
                available_resources_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=3", subentries, importance_level_item));
        }
	}
	if ($item[smut orc keepsake box].available_amount() > 0 && !__quest_state["Level 9"].state_boolean["bridge complete"])
		available_resources_entries.listAppend(ChecklistEntryMake("__item smut orc keepsake box", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[smut orc keepsake box]), "", "Open for bridge building."), 0));
		
		
	int clovers_available = $items[disassembled clover,ten-leaf clover].available_amount();
	if (clovers_available > 0 && in_run)
	{
		ChecklistSubentry subentry;
		subentry.header = pluralize(clovers_available, "clover", "clovers") + " available";
        
		
		if (!__quest_state["Level 13"].state_boolean["past gates"] && $item[blessed large box].available_amount() == 0)
			subentry.entries.listAppend("Blessed large box");
		if (!__quest_state["Level 9"].state_boolean["bridge complete"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Orc logging camp, for bridge building", $location[the smut orc logging camp]));
		if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 || !__quest_state["Level 9"].state_boolean["bridge complete"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("A-Boo clues", $location[a-boo peak]));
		if (__misc_state["wand of nagamar needed"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Wand of nagamar components (castle basement)", $location[the castle in the clouds in the sky (basement)]));
		boolean have_all_gum = $item[pack of chewing gum].available_amount() > 0 || ($item[jaba&ntilde;ero-flavored chewing gum].available_amount() > 0 && $item[lime-and-chile-flavored chewing gum].available_amount() > 0 && $item[pickle-flavored chewing gum].available_amount() > 0 && $item[tamarind-flavored chewing gum].available_amount() > 0);
		if (!__quest_state["Level 13"].state_boolean["past gates"] && !have_all_gum && !gnomads_available())
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Potential gate border gum", $location[south of the border]));
		if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 2)
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("2 sonar-in-a-biscuit (Guano Junction)", $location[guano junction]));
		if (!__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Ultrahydrated (Oasis)", $location[the oasis]));
		if (__misc_state["need to level"] && !__misc_state["Stat gain from NCs reduced"])
        {
            location l = $location[none];
            if (my_primestat() == $stat[moxie])
                l = $location[the haunted ballroom];
            else if (my_primestat() == $stat[mysticality])
                l = $location[the haunted bathroom];
            else if (my_primestat() == $stat[muscle])
                l = $location[the haunted gallery];
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Powerlevelling (" + l + ")", l));
        }
        if (!__quest_state["Level 13"].state_boolean["have relevant guitar"] && $item[big rock].available_amount() == 0)
			subentry.entries.listAppend("Possible guitar, via big rock");
		//put relevant tower items here
		
		available_resources_entries.listAppend(ChecklistEntryMake("clover", "", subentry, 7));
	}
	if (in_run)
	{
		if ($item[gameinformpowerdailypro magazine].available_amount() > 0)
		{
			string [int] description;
			description.listAppend("Zero-turn free SGEAA and scrolls");
			available_resources_entries.listAppend(ChecklistEntryMake("__item gameinformpowerdailypro magazine", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[gameinformpowerdailypro magazine]), "", description), importance_level_unimportant_item));
		}
	}
    if ($item[divine champagne popper].available_amount() > 0)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item divine champagne popper", "", ChecklistSubentryMake(pluralize($item[divine champagne popper]), "", "Free run and five-turn banish."), importance_level_unimportant_item));
    }
    if (__misc_state["need to level"])
    {
		if ($item[dance card].available_amount() > 0 && my_primestat() == $stat[moxie])
        {
			string [int] description;
			description.listAppend("Gain ~" + round(__misc_state_float["dance card average stats"]) + " mainstat from delayed adventure in the haunted ballroom.");
			available_resources_entries.listAppend(ChecklistEntryMake("__item dance card", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[dance card]), "", description), importance_level_unimportant_item));
        }
    }
	if ($item[stone wool].available_amount() > 0)
	{
		string [int] description;
		
		int quest_needed = 2;
		if ($item[the nostril of the serpent].available_amount() > 0)
			quest_needed -= 1;
		if (locationAvailable($location[the hidden park]))
			quest_needed = 0;
		
		if (quest_needed > 0)
			description.listAppend(quest_needed + " to unlock hidden city");
		if (__misc_state["need to level"])
			description.listAppend("Cave bar");
		if (get_property_int("lastTempleAdventures") != my_ascensions())
        {
            string line = "+3 adventures, +3 duration to ten effects. (once/ascension)";
            if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
                line += "|Can use to extend effects at nuns.";
			description.listAppend(line);
        }
		if (description.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item stone wool", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[stone wool]), "", description), importance_level_unimportant_item));
	}
    if ($item[the legendary beat].available_amount() > 0 && !get_property_boolean("_legendaryBeat"))
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item The Legendary Beat", "inventory.php?which=3", ChecklistSubentryMake("The Legendary Beat", "", "+50% item. (20 turns)"), importance_level_item));
        
    }
    item zap_wand_owned;
	if (true)
	{
		zap_wand_owned = $item[none];
		foreach wand in $items[aluminum wand,ebony wand,hexagonal wand,marble wand,pine wand]
		{
			if (wand.available_amount() > 0)
			{
				zap_wand_owned = wand;
				break;
			}
		}
		if (zap_wand_owned != $item[none])
		{
            string url = "wand.php?whichwand=" + zap_wand_owned.to_int();
			int zaps_used = get_property_int("_zapCount");
			string [int] details;
			if (zaps_used == 0)
				details.listAppend("Can zap safely.");
			else
            {
                float [int] chances;
                chances[1] = 75.0;
                chances[2] = 18.75;
                chances[3] = 1.5625;
                float chance = chances[zaps_used];
                
                if (zaps_used >= 4)
                    details.listAppend("Warning: Cannot zap.");
                else
					details.listAppend("Warning: " + roundForOutput(100.0 - chance, 1) + "% chance of explosion.");
				if ($item[Platinum Yendorian Express Card].available_amount() > 0 && !get_property_boolean("expressCardUsed"))
					details.listAppend("Platinum Yendorian Express Card usable.");
            }
			available_resources_entries.listAppend(ChecklistEntryMake(zap_wand_owned, url, ChecklistSubentryMake(pluralize(zaps_used, "zap", "zaps") + " used with " + zap_wand_owned, "", details), 10));
		}
	}
    
    if (!get_property_boolean("_defectiveTokenChecked") && get_property_int("lastArcadeAscension") == my_ascensions())
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item jackass plumber home game", "arcade.php", ChecklistSubentryMake("Broken arcade game", "", "May find a defective game grid token."), importance_level_item));
    
    }
    if ($item[defective Game Grid token].available_amount() > 0 && !get_property_boolean("_defectiveTokenUsed"))
    {
        string [int] description;
        description.listAppend("+5 to everything. (5 turns)");
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item defective Game Grid token", "", ChecklistSubentryMake("Defective Game Grid Token", "", description), importance_level_item));
    }
    if ($item[Platinum Yendorian Express Card].available_amount() > 0 && !get_property_boolean("expressCardUsed"))
    {
        string [int] description;
        string line = "Extends buffs, restores HP";
        if (get_property_int("_zapCount") > 0 && zap_wand_owned != $item[none] && zap_wand_owned.available_amount() > 0)
            line += ", cools down " + zap_wand_owned;
        line += ".";
        description.listAppend(line);
        available_resources_entries.listAppend(ChecklistEntryMake("__item Platinum Yendorian Express Card", "", ChecklistSubentryMake("Platinum Yendorian Express Card", "", description), importance_level_item));
    }
    
    
    if ($item[mojo filter].available_amount() > 0 && get_property_int("currentMojoFilters") <3 && in_run)
    {
        int mojo_filters_usable = MIN(my_spleen_use(), MIN(3 - get_property_int("currentMojoFilters"), $item[mojo filter].available_amount()));
        string line = "Removes one spleen each.";
        if (mojo_filters_usable != $item[mojo filter].available_amount())
            line += "|" + pluralize(mojo_filters_usable, "filter", "filters") + " usable.";
        
        if (mojo_filters_usable > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item mojo filter", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[mojo filter]), "", line), importance_level_unimportant_item));
    }
    if ($item[distention pill].available_amount() > 0 && !get_property_boolean("_distentionPillUsed") && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item distention pill", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[distention pill]), "", "Adds one extra fullness.|Once/day."), importance_level_unimportant_item));
    }
    if ($item[synthetic dog hair pill].available_amount() > 0 && !get_property_boolean("_syntheticDogHairPillUsed") && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item synthetic dog hair pill", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[synthetic dog hair pill]), "", "Adds one extra drunkenness.|Once/day."), importance_level_unimportant_item));
    }
    if ($item[the lost pill bottle].available_amount() > 0 && in_run)
    {
        string header = pluralize($item[the lost pill bottle]);
        if ($item[the lost pill bottle].available_amount() == 1)
            header = $item[the lost pill bottle];
        available_resources_entries.listAppend(ChecklistEntryMake("__item the lost pill bottle", "inventory.php?which=3", ChecklistSubentryMake(header, "", "Open it."), importance_level_unimportant_item));
    }
    if (__misc_state["need to level"])
    {
        if ($item[Marvin's marvelous pill].available_amount() > 0 && __misc_state["need to level moxie"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item Marvin's marvelous pill", "", ChecklistSubentryMake(pluralize($item[Marvin's marvelous pill]), "", "+20% to moxie gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[drum of pomade].available_amount() > 0 && __misc_state["need to level moxie"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item drum of pomade", "", ChecklistSubentryMake(pluralize($item[drum of pomade]), "", "+15% to moxie gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[baobab sap].available_amount() > 0 && __misc_state["need to level muscle"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item baobab sap", "", ChecklistSubentryMake(pluralize($item[baobab sap]), "", "+20% to muscle gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[desktop zen garden].available_amount() > 0 && __misc_state["need to level mysticality"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item desktop zen garden", "", ChecklistSubentryMake(pluralize($item[desktop zen garden]), "", "+20% to mysticality gains. (10 turns)"), importance_level_unimportant_item));
        }
    }
    if ($item[munchies pill].available_amount() > 0 && fullness_limit() > 0 && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item munchies pill", "", ChecklistSubentryMake(pluralize($item[munchies pill]), "", "+3 turns from fortune cookies and other low-fullness foods."), importance_level_unimportant_item));
    }
    if (lookupItem("snow cleats").available_amount() > 0 && in_run)
        available_resources_entries.listAppend(ChecklistEntryMake("__item snow cleats", "", ChecklistSubentryMake(pluralize(lookupItem("snow cleats")), "", "-5% combat, 30 turns."), importance_level_item));
        
    if ($item[vitachoconutriment capsule].available_amount() > 0 && get_property_int("_vitachocCapsulesUsed") <3 && in_run)
    {
        string [int] adventures_remaining;
        int capsules_remaining = $item[vitachoconutriment capsule].available_amount();
        int vita_used = get_property_int("_vitachocCapsulesUsed");
        if (vita_used < 1)
        {
            adventures_remaining.listAppend("+5");
            vita_used += 1;
            capsules_remaining -= 1;
        }
        if (vita_used < 2 && capsules_remaining > 0)
        {
            adventures_remaining.listAppend("+3");
            vita_used += 1;
            capsules_remaining -= 1;
        }
        if (vita_used < 3 && capsules_remaining > 0)
        {
            adventures_remaining.listAppend("+1");
        }
        string line;
        line = adventures_remaining.listJoinComponents("/") + " adventures";
        if (adventures_remaining.count() == 1) //hacky
        {
            if (adventures_remaining[0] == "+1")
                line = "+1 adventure";
        }
        line += ".";
        available_resources_entries.listAppend(ChecklistEntryMake("__item vitachoconutriment capsule", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[vitachoconutriment capsule]), "", line), importance_level_unimportant_item));
    }
    
    if ($item[drum machine].available_amount() > 0 && in_run && (my_adventures() <= 1 || (availableDrunkenness() < 0 && availableDrunkenness() > -4)) && __quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"])
    {
        //Daycount strategy that never works, suggest:
        string line = (100.0 * ((item_drop_modifier() / 100.0 + 1.0) * (1.0 / 1000.0))).roundForOutput(2) + "% chance of spice melange.";
        if (my_adventures() == 0)
            line += "|Need one adventure.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item drum machine", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[drum machine]), "", line), importance_level_unimportant_item));
    }
    
    
    
    if (in_run)
    {
		if ($item[tattered scrap of paper].available_amount() > 0 && __misc_state["free runs usable"])
		{
			string [int] description;
			description.listAppend(($item[tattered scrap of paper].available_amount() / 2.0).roundForOutput(1) + " free runs.");
			available_resources_entries.listAppend(ChecklistEntryMake("__item tattered scrap of paper", "", ChecklistSubentryMake(pluralize($item[tattered scrap of paper]), "", description), importance_level_unimportant_item));
		}
		if ($item[dungeoneering kit].available_amount() > 0)
		{
			string line = "Open it.";
			if ($item[dungeoneering kit].available_amount() > 1)
				line = "Open them.";
			available_resources_entries.listAppend(ChecklistEntryMake("__item dungeoneering kit", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[dungeoneering kit]), "", line), importance_level_unimportant_item));
		}
        if ($item[Box of familiar jacks].available_amount() > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item box of familiar jacks", "", ChecklistSubentryMake(pluralize($item[Box of familiar jacks]), "", "Gives current familiar equipment."), importance_level_unimportant_item));
        if ($item[csa fire-starting kit].available_amount() > 0 && !get_property_boolean("_fireStartingKitUsed"))
        {
            string [int] description;
            description.listAppend("All-day 4 HP/MP regeneration.");
            if (hippy_stone_broken())
                description.listAppend("3 PVP fights.");
            available_resources_entries.listAppend(ChecklistEntryMake("__item csa fire-starting kit", "inventory.php?which=3", ChecklistSubentryMake($item[csa fire-starting kit], "", description), importance_level_unimportant_item));
        }
        
        if ($item[transporter transponder].available_amount() > 0)
        {
            string [int] options;
            if (__misc_state["need to level"])
                options.listAppend("powerleveling");
            if (fullness_limit() > 0 || inebriety_limit() > 0)
                options.listAppend("yellow ray in grimace for synthetic dog hair/distention pill");
            
            string description = "Spaaaaace access.";
            if (options.count() > 0)
                description += "|" + options.listJoinComponents(", ", "and").capitalizeFirstLetter();
            available_resources_entries.listAppend(ChecklistEntryMake("__item transporter transponder", "", ChecklistSubentryMake(pluralize($item[transporter transponder]), "", description), importance_level_unimportant_item));
        }
    }
    
    foreach it in $items[carton of astral energy drinks,astral hot dog dinner,astral six-pack]
    {
        if (it.available_amount() == 0)
            continue;
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake(pluralize(it), "", "Open for astral consumables."), importance_level_unimportant_item));
    }
    
    if ($item[map to safety shelter grimace prime].available_amount() > 0)
    {
        string line = "Use for synthetic dog hair or distention pill.";
        if (__misc_state["In aftercore"])
            line += "|Will disappear when you ascend.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + $item[map to safety shelter grimace prime], "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[map to safety shelter grimace prime]), "", line), importance_level_unimportant_item));
    }
    if ($item[rusty hedge trimmers].available_amount() > 0 && __quest_state["Level 9"].state_int["twin peak progress"] != 15)
    {
        string line = "Use to visit the Twin Peak non-combat.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + $item[rusty hedge trimmers], "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[rusty hedge trimmers]), "", line), importance_level_unimportant_item));
    }
    
    if (in_run && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
    {
        string image_name = "";
        string [int] autosell_list;
        foreach it in $items[meat stack, dense meat stack, really dense meat stack, solid gold bowling ball, fancy seashell necklace, commemorative war stein]
        {
            if (it.available_amount() == 0)
                continue;
            autosell_list.listAppend(it.pluralize());
            
            if (image_name.length() == 0)
                image_name = "__item " + it;
        }
        string [int] open_list;
        foreach it in $items[old coin purse, old leather wallet, black pension check, ancient vinyl coin purse, warm subject gift certificate,shiny stones]
        {
            if (it.available_amount() == 0)
                continue;
            open_list.listAppend(it.pluralize());
            
            if (image_name.length() == 0)
                image_name = "__item " + it;
        }
        
        string url = "";
        string [int] description;
        if (autosell_list.count() > 0)
        {
            url = "sellstuff_ugly.php";
            description.listAppend("Autosell " + autosell_list.listJoinComponents(", ", "and") + ".");
        }
        if (open_list.count() > 0)
        {
            url = "inventory.php?which=3";
            description.listAppend("Open " + open_list.listJoinComponents(", ", "and") + ".");
        }
        
        if (description.count() > 0)
        {
            available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake("Meat", "", description), importance_level_unimportant_item));
        }
    }
    //Penultimate Fantasy chest?
    
    item odd_silver_coin = lookupItem("odd silver coin");
    if (odd_silver_coin.available_amount() > 0 && in_run)
    {
        string [int] description;
        string [int][int] table;
        //cinnamon cannoli - 2 - 1 fullness awesome food. not worthwhile?
        //expensive champagne - 3 - 1-drunkness epic drink. not worthwhile?
        //polo trophy - 3 - +50ML for 15 turns
        //table.listAppend(listMake("polo trophy", "+50ML for 15 turns, marginal?", "3 coins")); //costs three adventures to find. I guess it'd only be relevant for cave bars? even then...
        //fancy oil painting - 4 - bridge building. 10 progress
        if (!__quest_state["Level 9"].state_boolean["bridge complete"] && (__quest_state["Level 9"].state_int["bridge fasteners needed"] > 0 || __quest_state["Level 9"].state_int["bridge lumber needed"] > 0))
            table.listAppend(listMake("fancy oil painting", "10 fasteners, 10 lumber", "4 coins"));
        //solid gold rosary - 5 - better cyrpt progression. need details (-4.5 evil?)
        if (!__quest_state["Level 7"].state_boolean["alcove finished"] || !__quest_state["Level 7"].state_boolean["cranny finished"] || !__quest_state["Level 7"].state_boolean["niche finished"] || !__quest_state["Level 7"].state_boolean["nook finished"])
            table.listAppend(listMake("solid gold rosary", "-4.5? evilness from cyrpt", "5 coins"));
        //ornate dowsing rod - 5 - better desert exploration (+2%)
        
        if (!__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"] && lookupItem("ornate dowsing rod").available_amount() == 0)
            table.listAppend(listMake("ornate dowsing rod", "+2% desert exploration", "5 coins"));
        description.listAppend(HTMLGenerateSimpleTableLines(table));
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + odd_silver_coin, "inventory.php?which=3", ChecklistSubentryMake(odd_silver_coin.pluralize(), "", description), importance_level_item));
    }
    item grimstone_mask = lookupItem("grimstone mask");
    if (grimstone_mask.available_amount() > 0 && in_run)
    {
        string [int] description;
        
        description.listAppend("Wear to take you places.");
        description.listAppend("The prince's ball lets you find odd silver coins.|Up to six, one adventure each.");
        description.listAppend("Rumpelstiltskin's for towerkilling with small golem.|Small golem is a 5k/round combat item.|Involves the semi-rare in village. Don't know the details, sorry.");
        if (get_property("grimstoneMaskPath").length() > 0)
            description.listAppend("Currently on the path of " + get_property("grimstoneMaskPath") + ".");
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + grimstone_mask, "inventory.php?which=3", ChecklistSubentryMake(grimstone_mask.pluralize(), "", description), importance_level_item));
    }
    
    if ($item[very overdue library book].available_amount() > 0 && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item very overdue library book", "inventory.php?which=3", ChecklistSubentryMake("Very overdue library book", "", "Open for 63 moxie/mysticality/muscle."), importance_level_unimportant_item));
    }
    
    if ($item[chest of the Bonerdagon].available_amount() > 0 && in_run)
    {
        string description = "Open for 150 muscle/mysticality/moxie and 3k meat.";
        if (!$familiar[ninja pirate zombie robot].have_familiar())
            description += "|Unless you want to make an NPZR this ascension.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item chest of the Bonerdagon", "inventory.php?which=3", ChecklistSubentryMake("chest of the Bonerdagon", "", description), importance_level_unimportant_item));
    }
    
    if (lookupItem("smoke grenade").available_amount() > 0 && in_run)
    {
        string description = "Turn-costing banish. (lasts 20 turns, no stats, no items, no meat)";
        available_resources_entries.listAppend(ChecklistEntryMake("__item smoke grenade", "", ChecklistSubentryMake(pluralize(lookupItem("Smoke grenade")), "", description), importance_level_unimportant_item));
    }
    
    if (lookupItem("pile of ashes").available_amount() > 0 && in_run)
    {
        string description = "-10% combat. (20 turns)";
        available_resources_entries.listAppend(ChecklistEntryMake("__item pile of ashes", "", ChecklistSubentryMake(pluralize(lookupItem("pile of ashes")), "", description), importance_level_unimportant_item));
    }
    if (lookupItem("7259").available_amount() > 0 && in_run)
    {
        string description = "Open for elemental damage combat items.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + lookupItem("7259"), "inventory.php?which=3", ChecklistSubentryMake(pluralize(lookupItem("7259")), "", description), importance_level_unimportant_item));
    }
}

//Commander Shepard, we
//[disconnect]

void SCouncilGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	//This may be unreliable. Consider disabling.
	boolean council_probably_wants_to_speak_to_you = false;
	string [int] reasons;
    boolean [string] seen_quest_name;
	foreach quest_name in __quest_state
	{
		QuestState state = __quest_state[quest_name];
		if (state.startable && !state.in_progress && !state.finished && state.council_quest)
		{
            if (seen_quest_name[state.quest_name])
                continue;
            seen_quest_name[state.quest_name] = true;
			reasons.listAppend(state.quest_name);
			council_probably_wants_to_speak_to_you = true;
		}
	}
	if (!council_probably_wants_to_speak_to_you)
		return;
	
	task_entries.listAppend(ChecklistEntryMake("council", "town.php", ChecklistSubentryMake("Visit the Council of Loathing", "", "Start the " + reasons.listJoinComponents(", ", "and") + ".")));
}


void SugarGenerateSuggestions(string [int] suggestions)
{
    if (!__misc_state["In run"])
        return;
    if ($item[sugar shield].available_amount() == 0 && $item[snow suit].available_amount() == 0)
        suggestions.listAppend("Sugar shield: +10 familiar weight equip");
    if ($item[sugar chapeau].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["past tower"])
        suggestions.listAppend("Sugar chapeau: +50% spell damage (tower killing)");
}

void SSugarGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    item [int] sugar_crafted_items;
    for i from 4178 to 4183
    {
        sugar_crafted_items.listAppend(i.to_item());
    }
    ChecklistSubentry [int] subentries;
    
    string image_name = "";
    
    if ($item[sugar sheet].available_amount() > 0 && __misc_state["In run"] )
    {
        string [int] suggestions;
        SugarGenerateSuggestions(suggestions);
        subentries.listAppend(ChecklistSubentryMake(pluralize($item[sugar sheet]), "", suggestions));
        
        image_name = "sugar sheet";
    }
    foreach key in sugar_crafted_items
    {  
        item it = sugar_crafted_items[key];
        if (it.available_amount() == 0)
            continue;
        int counter = get_property_int("sugarCounter" + it.to_int());
        int combats_left = 31 - counter;
        subentries.listAppend(ChecklistSubentryMake(pluralize(it), "", pluralize(combats_left, "combat", "combats") + " left."));
        if (image_name.length() == 0)
            image_name = it;
    }
    if (subentries.count() > 0)
    {
        available_resources_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 10));
    }
}
void STomesGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (true)
	{
		ChecklistSubentry [int] subentries;		
		
        if (!can_interact())
        {
            int summons_remaining = 3 - get_property_int("tomeSummons");
            subentries.listAppend(ChecklistSubentryMake(pluralize(summons_remaining, "tome summon", "tome summons") + " remaining", "", ""));
        }
		
		
		int tome_count = 0;
		
		string [skill] tome_summons_property_names;
		tome_summons_property_names[$skill[Summon Smithsness]] = "_smithsnessSummons";
		tome_summons_property_names[$skill[summon clip art]] = "_clipartSummons";
		tome_summons_property_names[$skill[Summon Sugar Sheets]] = "_sugarSummons";
		tome_summons_property_names[$skill[Summon Snowcones]] = "_snowconeSummons";
		tome_summons_property_names[$skill[Summon Stickers]] = "_stickerSummons";
		tome_summons_property_names[$skill[Summon Rad Libs]] = "_radlibSummons";
		
        boolean have_tome_summons = false;
		int [skill] summons_available;
		foreach s in tome_summons_property_names
		{
			string property_name = tome_summons_property_names[s];
			int value = 0;
			if (s.have_skill())
			{
				if (in_ronin())
					value = 3 - get_property_int("tomeSummons");
				else
					value = 3 - get_property_int(property_name);
                if (value > 0)
                    have_tome_summons = true;
			}
			summons_available[s] = value;
		}
        if (!have_tome_summons)
            return;
		
		if (summons_available[$skill[Summon Smithsness]] > 0)
		{
			string [int] description;
			
			string [int] flask_suggestions;
			
			string [int] smithereen_suggestions;
			smithsnessGenerateSmithereensSuggestions(smithereen_suggestions);
			
			
			string [int] coal_suggestions;
			smithsnessGenerateCoalSuggestions(coal_suggestions);
			
			if (true)
			{
                int merry_smithsness_currently_available = $item[flaskfull of hollow].available_amount() * 150 + $effect[merry smithsness].have_effect();
				string building_line = "+25 smithsness (150 turns)";
				if (merry_smithsness_currently_available > 0)
					building_line += " (" + merry_smithsness_currently_available + " turns currently available)";
				flask_suggestions.listAppend(building_line);
				
			}
			
			description.listAppend("1 Flaskfull of Hollow" + HTMLGenerateIndentedText(flask_suggestions.listJoinComponents("<hr>")));
			description.listAppend("1 Lump of Brituminous coal" + HTMLGenerateIndentedText(coal_suggestions.listJoinComponents("<hr>")));
			description.listAppend("1 Handful of Smithereens" + HTMLGenerateIndentedText(smithereen_suggestions.listJoinComponents("<hr>")));
			
			string name = "The Smith's Tome";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Smithsness]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
			
		}
		if (summons_available[$skill[summon clip art]] > 0)
		{
			string [int] description;
            if (__misc_state["in run"])
            {
                if ($item[shining halo].available_amount() == 0 && __misc_state["need to level"])
                    description.listAppend("Shining halo: +3 stats/fight when unarmed");
                if ($item[frosty halo].available_amount() == 0 && $item[a light that never goes out].available_amount() == 0)
                    description.listAppend("Frosty halo: 25% items when unarmed");
                if ($item[furry halo].available_amount() == 0)
                {
                    string line = "Furry halo: +5 familiar weight when unarmed";
                    if (__misc_state["free runs available"])
                        line += " (1 free run/day)";
                    description.listAppend(line);
                }
                if ($item[time halo].available_amount() == 0 && my_daycount() <3 )
                    description.listAppend("Time halo: +5 adventures/day");
                    
                if ($item[bucket of wine].available_amount() == 0 && __misc_state["can drink just about anything"])
                {
                    if (have_skill($skill[the ode to booze]))
                        description.listAppend("Bucket of wine: 28 adventures nightcap with ode");
                    else if (get_property_int("hiddenTavernUnlock") != my_ascensions() && $item[ye olde meade].available_amount() == 0) //just use fog murderers or meade instead, about the same
                        description.listAppend("Bucket of wine: 18 adventures nightcap");
                }
                    
                if (__misc_state["can eat just about anything"] && __misc_state["need to level"])
                    description.listAppend("Ultrafondue: 3 fullness awesome food, +15ML for 30 adventures");
                if (true)
                {
                    string line = "Crystal skull: banish in high monster count zones";
                    if (have_skill($skill[Summon Smithsness]) && !__misc_state["In aftercore"])
                        line += "|*Smith's Tome has a better one";
                    description.listAppend(line);
                }
                if ($item[borrowed time].available_amount() == 0 && !get_property_boolean("_borrowedTimeUsed") && my_daycount() > 1)
                    description.listAppend("Borrowed time: 20 adventures on last day");
                
                string [int] familiar_suggestions;
                if (familiar_is_usable($familiar[he-boulder]) && $item[quadroculars].available_amount() == 0)
                    familiar_suggestions.listAppend("He-Boulder 100-turn YR");
                if (familiar_is_usable($familiar[obtuse angel]) && !familiar_is_usable($familiar[Reanimated Reanimator]))
                    familiar_suggestions.listAppend("+1 angel copy");
                    
                if (familiar_suggestions.count() > 0)
                    description.listAppend("Box of familiar jacks: free familiar equipment (" + listJoinComponents(familiar_suggestions, ", ") + ")");
                else
                    description.listAppend("Box of familiar jacks: free familiar equipment");
            }
			
			string name = "Tome of Clip Art";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Clip Art]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Sugar Sheets]] > 0)
		{
			string [int] description;
            
            SugarGenerateSuggestions(description);
				
			string name = "Tome of Sugar Shummoning";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Sugar Sheets]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Snowcones]] > 0)
		{
			string [int] description;
			//FIXME check this
			
			string name = "Tome of Snowcone Summoning";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Snowcones]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Stickers]] > 0)
		{
			string [int] description;
			//FIXME check this
			
			string name = "Scratch 'n' Sniff Sticker Tome";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Stickers]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		if (summons_available[$skill[Summon Rad Libs]] > 0)
		{
			string [int] description;
			
			//FIXME check this
			
			string name = "Tome of Rad Libs";
			if (!in_ronin())
				name = pluralize(summons_available[$skill[Summon Rad Libs]], name + " summon", name + " summons");
			subentries.listAppend(ChecklistSubentryMake(name, "", description));
		}
		
        
        ChecklistEntry entry = ChecklistEntryMake("__item tome of clip art", "campground.php?action=bookshelf", subentries);
        if (!can_interact())
            entry.should_indent_after_first_subentry = true;
        available_resources_entries.listAppend(entry);
	}
}

record SmashedItem
{
    item it;
    float wads_found;
};

SmashedItem SmashedItemMake(item it, float wads_found)
{
    SmashedItem result;
    result.it = it;
    result.wads_found = wads_found;
    return result;
}

void listAppend(SmashedItem [int] list, SmashedItem entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void SPulverizeGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    if (!$skill[pulverize].have_skill())
        return;
    if (!in_ronin()) //list is far too long with your main inventory, and you can buy wads at this point
        return;
    if (availableSpleen() == 0) //only want wads for spleen. could disable this for planning? but information overload
        return;
    
    
    /*
     Smashable item types:
     BRICKO brick
     candycaine powder
     chunk of depleted Grimacite
     cold cluster
     cold nuggets
     cold powder
     cold wad
     corrupted stardust
     effluvious emerald
     epic wad
     glacial sapphire
     handful of Smithereens
     hot cluster
     hot nuggets
     hot powder
     hot wad
     sea salt crystal
     sleaze cluster
     sleaze nuggets
     sleaze powder
     sleaze wad
     spooky cluster
     spooky nuggets
     spooky powder
     spooky wad
     steamy ruby
     stench cluster
     stench nuggets
     stench powder
     stench wad
     sugar shard
     tawdry amethyst
     twinkly nuggets
     twinkly powder
     twinkly wad
     ultimate wad
     unearthly onyx
     useless powder
     wad of Crovacite
     */
    
    boolean [item] smashables_wanted = $items[cold wad,hot wad,sleaze wad,spooky wad,stench wad];
    
    string [int] details;
    
    string blacklist_string = "fireman's helmet,fire axe,enchanted fire extinguisher,fire hose,rainbow pearl earring,rainbow pearl necklace,rainbow pearl ring,steaming evil,ring of detect boring doors,giant discarded torn-up glove,giant discarded plastic fork,giant discarded bottlecap,toy ray gun,toy space helmet,toy jet pack,MagiMechTech NanoMechaMech,astronaut pants,ancient hot dog wrapper";
    
    if (!__quest_state["Level 13"].state_boolean["past keys"])
        blacklist_string += ",Tambourine,jungle drum,hippy bongo,bone rattle,black kettle drum,big bass drum";
    if (!__quest_state["Level 12"].finished)
        blacklist_string += ",reinforced beaded headband,bullet-proof corduroys,round purple sunglasses,beer helmet,distressed denim pants,bejeweled pledge pin";
    if (!__quest_state["Level 11 Hidden City"].state_boolean["Hospital finished"])
        blacklist_string += ",head mirror,surgical apron,bloodied surgical dungarees,surgical mask,half-size scalpel";
    string [int] blacklist_source = split_string_mutable(blacklist_string, ",");
    boolean [item] blacklist;
    foreach key in blacklist_source
        blacklist[blacklist_source[key].to_item()] = true;
    
    SmashedItem [int] available_smashed_items;
    //To generate a list of everything:
    //clear; ashq foreach it in $items[] if (it.get_related("pulverize").count() > 0 && it.tradeable && !it.quest && it.discardable && it.get_related("pulverize").to_json().contains_text("wad")) print(it.entity_encode());
    //We use this method because it's faster (saves ~20ms or so?) than iterating through all the items.
    foreach it in $items[yakskin pants,acoustic guitarrr,mesh cap,leather chaps,batblade,denim axe,heavy metal thunderrr guitarrr,drywall axe,ridiculously huge sword,Mohawk wig,giant needle,glowing red eye,furry pants,wolf mask,star sword,star crossbow,star staff,star pants,star hat,star buckler,star shirt,giant discarded plastic fork,yakskin skirt,yakskin kilt,furry skirt,furry kilt,giant discarded bottlecap,giant discarded torn-up glove,star spatula,hippy protest button,Lockenstock&trade; sandals,didgeridooka,bullet-proof corduroys,round purple sunglasses,wicker shield,black sword,black helmet,black shield,kick-ass kicks,beer helmet,distressed denim pants,perforated battle paddle,toy ray gun,toy space helmet,astronaut pants,toy jet pack,pygmy nose-bone,big bad voodoo mask,pygmy spear,headhunter necktie,pointed stick,black belt,lead pipe,reinforced beaded headband,fire poi,bejeweled pledge pin,Gaia beads,hippy medical kit,flowing hippy skirt,bottle opener belt buckle,keg shield,giant foam finger,war tongs,asbestos apron,energy drink IV,Elmley shades,beer bong,goatskin umbrella,wool hat,round green sunglasses,Ankh of Badahnkadh,giant cactus quill,wonderwall shield,palm-frond capris,extra-large palm-frond toupee,palm-frond cloak,Iiti Kitty phone charm,nasty rat mask,ratskin belt,bat hat,bat-ass leather jacket,catskin cap,catskin buckler,mummy mask,gauze shorts,black greaves,black cowboy hat,Maxwell's Silver Hammer,happiness,armgun,beer-a-pult,cast-iron legacy paddle,giant driftwood sculpture,massive sitar,stone baseball cap,blackberry slippers,blackberry moccasins,blackberry combat boots,battered hubcap,shiny hood ornament,furniture dolly,Earring of Fire,Pendant of Fire,Ring of Fire,Ice-Cold Beerring,Ice-Cold Aluminum Necklace,Ice-Cold Beer Ring,Unspeakable Earring,Choker of the Ultragoth,The Ring,Nose Ring of Putrescence,Putrid Pendant,Ring of the Sewer Snake,Mudflap-Girl Earring,Mudflap-Girl Necklace,Mudflap-Girl Ring,grumpy old man charrrm bracelet,tarrrnished charrrm bracelet,witty rapier,yohohoyo,booty chest charrrm bracelet,cannonball charrrm bracelet,copper ha'penny charrrm bracelet,silver tongue charrrm bracelet,buoybottoms,grungy flannel shirt,grungy bandana,grassy cutlass,solid gold pegleg,flamin' bindle,freezin' bindle,stinkin' bindle,spooky bindle,sleazy bindle,'WILL WORK FOR BOOZE' sign,panhandle panhandling hat,cup of infinite pencils,gatorskin umbrella,C.H.U.M. knife,lucky bottlecap,corncob pipe,Mr. Joe's bangles,frayed rope belt,club of the five seasons,rainbow crossbow,groovy prism necklace,six-rainbow shield,decaying wooden oar,giant fishhook,rusty old lantern,jungle drum,world's smallest violin,a butt tuba,charming flute,black kettle drum,magilaser blastercannon,frozen seal spine,rusty piece of rebar,cyber-mattock,X-37 gun,crown-shaped beanie,hopping socks,poodle skirt,letterman's jacket,silver pat&eacute; knife,silver cheese-slicer,pipe wrench,sleep mask,sock garters,heavy leather-bound tome,guard turtle shell,crowbar,spaghetti cult rosary,spaghetti cult mask,spangly mariachi pants,spangly mariachi vest,spangly sombrero,snailmail coif,snailmail breeches,snailmail hauberk,T&Icirc;&curren;&loz;lisman of Bai&oslash;&Dagger;,blackberry galoshes,trout fang,bindlestocking,keel-haulin' knife,ancient ice cream scoop,auxiliary backbone,gold crown,flaming sword,giant gym membership card,giant penguin keychain,giant turkey leg,pewter claymore,giant artisanal rice peeler,brown felt tophat,Mark I Steam-Hat,Mark II Steam-Hat,Mark III Steam-Hat,Mark IV Steam-Hat,Mark V Steam-Hat,punk rock jacket,giant safety pin,floral-print skirt,spectral axe,super-strong air freshener,Mer-kin gutgirdle,pogo stick,antique machete,surgical mask,head mirror,half-size scalpel,surgical apron,bloodied surgical dungarees,short-handled mop,smirking shrunken head,attorney's badge,pygmy briefs,sphygmomanometer,compression stocking,midriff scrubs,cold water bottle,accordionoid rocca,pygmy concertinette,ghost accordion,peace accordion,alarm accordion]
    {
        if (!it.tradeable || it.quest || !it.discardable) //probably valuable
            continue;
        if (it.available_amount() == 0)
            continue;
        int [item] pulverizations = it.get_related("pulverize");
        if (pulverizations.count() == 0)
            continue;
        if (blacklist[it])
            continue;
        
        
        int total_desired_smash_items_acquired = 0;
        foreach smashed_item in pulverizations
        {
            int smash_amount = pulverizations[smashed_item];
            if (!smashables_wanted[smashed_item])
                continue;
            
            total_desired_smash_items_acquired += smash_amount;
        }
        if (total_desired_smash_items_acquired > 0)
        {
            float average_total_smash_items_acquired = total_desired_smash_items_acquired.to_float() / 1000000.0;
            available_smashed_items.listAppend(SmashedItemMake(it, average_total_smash_items_acquired));
            
        }
    }
    
    sort available_smashed_items by -(value.wads_found * value.it.available_amount());
    
    int total_number_available = 0;
    string [int] output_list;
    foreach key in available_smashed_items
    {
        SmashedItem smashed_item = available_smashed_items[key];
        string line;
        
        line = smashed_item.it;
        
        output_list.listAppend(line);
        total_number_available += smashed_item.it.available_amount();
    }
    if (true)
    {
        //Alter lines so items aren't split up by word wrap:
        int number_seen = 0;
        foreach key in output_list
        {
            string line = output_list[key];
            
            if (number_seen < output_list.count() - 1) //comma needs to be part of the group
                line += ",";
            line = HTMLGenerateDivOfClass(line, "r_word_wrap_group");
            
            output_list[key] = line;
            number_seen += 1;
        }
    }
    details.listAppend("Can smash " + output_list.listJoinComponents(" ", "and").capitalizeFirstLetter() + " for spleen wads.");
    
    if (output_list.count() > 0)
    {
        string title;
        title = "Pulverizable equipment";
        available_resources_entries.listAppend(ChecklistEntryMake("pulverize", "", ChecklistSubentryMake(title, "", details), 10));
    }
}

void SAftercoreGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    
    if (!__misc_state["In aftercore"])
        return;
    //Campground items:
    int [item] campground_items = get_campground();
    
    if (campground_items[$item[clockwork maid]] == 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item sprocket", "", ChecklistSubentryMake("Install a clockwork maid", "", listMake("+8 adventures/day.", "Buy from mall."))));
    }
    if (campground_items[$item[pagoda plans]] == 0)
    {
        string url;
        string [int] details;
        details.listAppend("+3 adventures/day.");
        
        if ($item[hey deze nuts].available_amount() == 0)
        {
            if ($item[hey deze map].available_amount() == 0)
            {
                url = "pandamonium.php";
                details.listAppend("Adventure in Pandamonium Slums for Hey Deze Map. (25% superlikely)");
            }
            else
            {
                string [int] things_to_do;
                string [int] things_to_buy;
                if ($item[heavy metal sonata].available_amount() == 0)
                    things_to_buy.listAppend("heavy metal sonata");
                if ($item[heavy metal thunderrr guitarrr].available_amount() == 0)
                    things_to_buy.listAppend("heavy metal thunderrr guitarrr");
                if ($item[guitar pick].available_amount() == 0)
                    things_to_buy.listAppend("guitar pick");
                if (things_to_buy.count() > 0)
                    things_to_do.listAppend("buy " + things_to_buy.listJoinComponents(", ", "and") + " in mall, ");
                things_to_do.listAppend("use hey deze map");
				details.listAppend(things_to_do.listJoinComponents("", "then").capitalizeFirstLetter() + ".");
            }
        }
        if ($item[pagoda plans].available_amount() == 0)
        {
            if ($item[Elf Farm Raffle ticket].available_amount() == 0)
            {
                details.listAppend("Buy a Elf Farm Raffle ticket from the mall.");
            }
            else
            {
                if (url.length() == 0)
                    url = "inventory.php?which=3";
                if (in_bad_moon()) //Does bad moon aftercore require a clover?
                {
                    details.listAppend("Use Elf Farm Raffle ticket.");
                }
                else
                {
                    details.listAppend("Acquire ten-leaf clover, then use Elf Farm Raffle ticket.");
                }
            }
        }
        if ($item[ketchup hound].available_amount() == 0)
        {
            if (url.length() == 0)
                url = "mall.php";
            details.listAppend("Buy a ketchup hound from the mall.");
        }
        if ($item[ketchup hound].available_amount() > 0 && $item[hey deze nuts].available_amount() > 0 && $item[pagoda plans].available_amount() > 0)
        {
            if (url.length() == 0)
                url = "inventory.php?which=3";
            details.listAppend("Use a ketchup hound to install pagoda.");
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item pagoda plans", url, ChecklistSubentryMake("Install a pagoda", "", details)));
    }
    
    //Disabled - 16.2 errors.
    /*if (knoll_available() && !have_mushroom_plot() && get_property("plantingScript") != "")
    {
        //They can plant a mushroom plot, and they have a planting script. But they haven't yet, so let's suggest it:
        optional_task_entries.listAppend(ChecklistEntryMake("__item knob mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Plant a mushroom plot", "", "Degrassi Knoll")));
    }*/
}
void SLibramGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (__misc_state["bookshelf accessible"])
	{
		int libram_summoned = get_property_int("libramSummons");
        int next_libram_summoned = libram_summoned + 1;
		int libram_mp_cost = MAX(1 + (next_libram_summoned * (next_libram_summoned - 1)/2) + mana_cost_modifier(), 1);
		
		
		string [int] librams_usable;
		foreach s in $skills[]
        {
			if (s.libram && s.have_skill())
				librams_usable.listAppend(s.to_string());
        }
		if (libram_mp_cost <= my_maxmp() && librams_usable.count() > 0)
		{
			ChecklistSubentry subentry;
			if (librams_usable.count() == 1)
				subentry.header = "Libram";
			else
				subentry.header = "Librams";
			subentry.header += " summonable";
			subentry.modifiers.listAppend(libram_mp_cost + "MP cost");
			
			string [int] readable_list;
			foreach key in librams_usable
			{
				string libram_name = librams_usable[key];
				if (libram_name.stringHasPrefix("Summon "))
					libram_name = libram_name.substring(7);
				readable_list.listAppend(libram_name);
			}
			
			subentry.entries.listAppend(readable_list.listJoinComponents(", ", "and") + ".");
			available_resources_entries.listAppend(ChecklistEntryMake("__item libram of divine favors", "campground.php?action=bookshelf", subentry, 7));
		}
		
		
		if ($skill[summon brickos].have_skill())
		{
			if (get_property_int("_brickoEyeSummons") <3)
			{
				ChecklistSubentry subentry;
				subentry.header =  (3 - get_property_int("_brickoEyeSummons")) + " BRICKO&trade; eye bricks obtainable";
				subentry.entries.listAppend("Cast Summon BRICKOs libram. (" + libram_mp_cost + " mp)");
				available_resources_entries.listAppend(ChecklistEntryMake("__item bricko eye brick", "campground.php?action=bookshelf", subentry, 7));
				
			}
		}
	}
	
	if (__misc_state["In run"])
	{
		boolean [item] all_possible_bricko_fights = $items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner];
		
		int bricko_potential_fights_available = 0;
		foreach it in $items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner]
		{
			bricko_potential_fights_available += it.available_amount();
		}
		bricko_potential_fights_available = MIN(10 - get_property_int("_brickoFights"), bricko_potential_fights_available);
		if (bricko_potential_fights_available > 0)
		{
			ChecklistSubentry subentry;
			subentry.header =  bricko_potential_fights_available + " BRICKO&trade; fights ready";
			
			
			foreach fight in all_possible_bricko_fights
			{
				int number_available = fight.available_amount();
				if (number_available > 0)
					subentry.entries.listAppend(pluralize(number_available, fight));
			}
			
			item [int] craftable_fights;
			string [int] creatable;
			foreach fight in all_possible_bricko_fights
			{
                monster m = fight.to_string().to_monster(); //is there a better way to look this up?
				int bricks_needed = get_ingredients(fight)[$item[bricko brick]];
				int monster_level = m.raw_attack;
				int number_available = creatable_amount(fight);
				if (number_available > 0)
				{
					craftable_fights.listAppend(fight);
					creatable.listAppend(pluralize(number_available, fight) + " (" + bricks_needed + " bricks, " + monster_level + "ML)");
				}
			}
			
			if (creatable.count() > 0)
				subentry.entries.listAppend("Creatable: (" + $item[bricko brick].available_amount() + " bricks available)" + HTMLGenerateIndentedText(creatable));
				
			available_resources_entries.listAppend(ChecklistEntryMake("__item bricko brick", "inventory.php?which=3", subentry, 7));
		}
	}
}


void S8bitRealmGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	int total_white_pixels = $item[white pixel].available_amount() + creatable_amount($item[white pixel]);
	if (__quest_state["Level 13"].state_boolean["digital key used"] || (total_white_pixels >= 30 || $item[digital key].available_amount() > 0))
        return;
    boolean need_route_output = true;
    //Need white pixels for digital key.
    if (familiar_is_usable($familiar[angry jung man]) && $item[psychoanalytic jar].available_amount() == 0 && $item[jar of psychoses (The Crackpot Mystic)].available_amount() == 0 && !get_property_boolean("_psychoJarUsed"))
    {
        //They have a jung man, but haven't acquired a jar yet.
        ChecklistSubentry subentry;
    
        string url = "";
        if (my_familiar() != $familiar[angry jung man])
            url = "familiar.php";
        int jung_mans_charge_turns_remaining = 1 + (30 - MIN(30, get_property_int("jungCharge")));

        subentry.header = "Bring along the angry jung man";
    
        subentry.entries.listAppend(pluralize(jung_mans_charge_turns_remaining, "turn", "turns") + " until jar drops. (skip 8-bit realm)");
    
        optional_task_entries.listAppend(ChecklistEntryMake("__familiar angry jung man", url, subentry));
        need_route_output = false;
    }
    if ($item[psychoanalytic jar].available_amount() > 0 || $item[jar of psychoses (The Crackpot Mystic)].available_amount() > 0 || get_property_boolean("_psychoJarUsed")) //FIXME check which jar used
    {
        string active_url = "";
        string title = "Adventure in fear man's level";
        //Have a jar, or jar was installed.
        string [int] description;
        string [int] modifiers;
        
        if (get_property_boolean("_psychoJarUsed"))
        {
            active_url = "place.php?whichplace=junggate_3";
            modifiers.listAppend("+150% item");
            modifiers.listAppend("olfact morbid skull");
            description.listAppend("Run +150% item, olfact morbid skull.");
            description.listAppend(total_white_pixels + "/30 white pixels found.");
        }
        else if ($item[jar of psychoses (The Crackpot Mystic)].available_amount() > 0)
        {
            active_url = "inventory.php?which=3";
            title = "Open the " + $item[jar of psychoses (The Crackpot Mystic)];
            description.listAppend("Fear Man's level access, for digital key.");
        }
        else if ($item[psychoanalytic jar].available_amount() > 0)
        {
            active_url = "place.php?whichplace=forestvillage";
            title = "Psychoanalyze the crackpot mystic";
            description.listAppend("Fear Man's level access, for digital key.");
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item digital key", active_url, ChecklistSubentryMake(title, modifiers, description), $locations[fear man's level]));
        need_route_output = false;
    }
    if (need_route_output)
    {
        if (in_hardcore())
        {
            string [int] description;
            string [int] modifiers;
            modifiers.listAppend("olfact bloopers");
            modifiers.listAppend("+67% item");
            
            description.listAppend("Run +67% item, olfact bloopers.");
            description.listAppend(total_white_pixels + "/30 white pixels found.");
            if (__misc_state["VIP available"] && __misc_state["fax accessible"])
                description.listAppend("Possibly consider faxing/copying a ghost. (+150% item, drops five white pixels)");
            //No other choice. 8-bit realm.
            //Well, I suppose they could fax and arrow a ghost.
            if ($item[continuum transfunctioner].available_amount() > 0)
                optional_task_entries.listAppend(ChecklistEntryMake("inexplicable door", "place.php?whichplace=woods", ChecklistSubentryMake("Adventure in the 8-bit realm", modifiers, description), $locations[8-bit realm]));
            else if (my_level() >= 2)
                optional_task_entries.listAppend(ChecklistEntryMake("__item continuum transfunctioner", "place.php?whichplace=forestvillage", ChecklistSubentryMake("Acquire a continuum transfunctioner", "", "From the crackpot mystic.")));
        }
        else
        {
            //softcore, suggest pulling a jar of psychoses.
            optional_task_entries.listAppend(ChecklistEntryMake("__item psychoanalytic jar", "", ChecklistSubentryMake("Pull a jar of psychoses (The Crackpot Mystic)", "", "To make digital key.")));
        }
    }
}
void SDailyDungeonGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	
	if (__last_adventure_location == $location[The Daily Dungeon])
	{
		if ($item[ring of detect boring doors].equipped_amount() == 0 && $item[ring of detect boring doors].available_amount() > 0 && !get_property_boolean("dailyDungeonDone"))
		{
			task_entries.listAppend(ChecklistEntryMake("__item ring of detect boring doors", "inventory.php?which=2", ChecklistSubentryMake("Wear ring of detect boring doors", "", "Speeds up daily dungeon"), -11));
		}
		if (familiar_is_usable($familiar[gelatinous cubeling]) && ($item[pick-o-matic lockpicks].available_amount() == 0 || $item[eleven-foot pole].available_amount() == 0 || $item[Ring of Detect Boring Doors].available_amount() == 0)) //have familiar, but not the drops
		{
			task_entries.listAppend(ChecklistEntryMake("__familiar gelatinous cubeling", "", ChecklistSubentryMake("Use a gelatinous cubeling first", "", "You're adventuring in the daily dungeon without cubeling drops."), -11));
		}
	}
	
	
	boolean need_to_do_daily_dungeon = false;
	
	if (__misc_state_int["fat loot tokens needed"] > 0)
		need_to_do_daily_dungeon = true;
	
	string [int] daily_dungeon_aftercore_items_wanted; 
	
	if (__misc_state["In aftercore"])
	{
		int tokens_needed = 0;
		if (!__misc_state["familiars temporarily missing"])
		{
			if (!have_familiar_replacement($familiar[gelatinous cubeling]) && $item[dried gelatinous cube].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("gelatinous cubeling");
				tokens_needed += 27;
			}
		}
		if (!__misc_state["skills temporarily missing"])
		{
			if (!have_skill($skill[singer's faithful ocelot]) && $item[Spellbook: Singer's Faithful Ocelot].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("Singer's faithful ocelot");
				tokens_needed += 15;
			}
			if (!have_skill($skill[Drescher's Annoying Noise]) && $item[Spellbook: Drescher's Annoying Noise].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("Drescher's Annoying Noise");
				tokens_needed += 15;
			}
			if (!have_skill($skill[Walberg's Dim Bulb]) && $item[Spellbook: Walberg's Dim Bulb].available_amount() == 0)
			{
				daily_dungeon_aftercore_items_wanted.listAppend("Walberg's Dim Bulb");
				tokens_needed += 15;
			}
		}
		if (tokens_needed > $item[fat loot token].available_amount())
		{
			need_to_do_daily_dungeon = true;
			__misc_state_int["fat loot tokens needed"] += tokens_needed - $item[fat loot token].available_amount();
		}
	}
    //When we're down to two potential skeleton keys, mention they shouldn't use them in the door.
    int skeleton_key_amount = $item[skeleton key].available_amount() + $item[skeleton key].creatable_amount();
    boolean avoid_using_skeleton_key = ($item[pick-o-matic lockpicks].available_amount() == 0 && (skeleton_key_amount) <= 2 && skeleton_key_amount > 0 && !__quest_state["Level 13"].state_boolean["Past keys"] && in_ronin());
	
	boolean delay_daily_dungeon = false;
	string delay_daily_dungeon_reason = "";
	if (need_to_do_daily_dungeon)
	{
		if (familiar_is_usable($familiar[gelatinous cubeling]))
		{
            item [int] missing_items;
            
            missing_items = $items[eleven-foot pole,ring of detect boring doors,pick-o-matic lockpicks].items_missing();
			if (missing_items.count() > 0)
			{
				delay_daily_dungeon = true;
				delay_daily_dungeon_reason = "Bring along the gelatinous cubeling first";
				ChecklistSubentry subentry;
			
                string url = "";
                if (my_familiar() != $familiar[gelatinous cubeling])
                    url = "familiar.php";
				subentry.header = "Bring along the gelatinous cubeling";
			
				subentry.entries.listAppend("Acquire " + missing_items.listJoinComponents(", ", "and") + " to speed up the daily dungeon.");
			
				optional_task_entries.listAppend(ChecklistEntryMake("__familiar gelatinous cubeling", url, subentry));
			}
		}
		else
		{
			//No gelatinous cubeling.
			//But! We can acquire a skeleton key in-run.
			//So suggest doing that:
			boolean can_make_skeleton_key = ($items[loose teeth,skeleton bone].items_missing().count() == 0);
			
			if (!avoid_using_skeleton_key && ($item[pick-o-matic lockpicks].available_amount() == 0 && $item[skeleton key].available_amount() == 0 && (!__quest_state["Level 7"].state_boolean["nook finished"] || can_make_skeleton_key))) //they don't have lockpicks or a key, and they can reasonably acquire a key
			{
				delay_daily_dungeon = true;
				if (can_make_skeleton_key)
					delay_daily_dungeon_reason = "Make a skeleton key first. (you have the ingredients)";
				else
					delay_daily_dungeon_reason = "Acquire a skeleton key first. (from defiled nook)|Unless you can't reach that by the end of today.";
					
					
				if (can_make_skeleton_key)
				{
					ChecklistEntry cl = ChecklistEntryMake("__item skeleton key", "", ChecklistSubentryMake("Make a skeleton key", "", listMake("You have the ingredients.", "Speeds up the daily dungeon.")));
                    if (__last_adventure_location == $location[The Daily Dungeon])
                    {
                        cl.importance_level = -11;
                        task_entries.listAppend(cl);
                    }
                    else
                        optional_task_entries.listAppend(cl);
				}
			}
		}
	}
    
    
    //Pop up a warning:
    if (__last_adventure_location == $location[the daily dungeon] && avoid_using_skeleton_key && $item[skeleton key].available_amount() > 0)
    {
        task_entries.listAppend(ChecklistEntryMake("__item skeleton key", "", ChecklistSubentryMake("Avoid using the skeleton key in the daily dungeon", "", listMake("Running low, will need one for the gates.")), -11));
    }
    
    if (get_property_int("_lastDailyDungeonRoom") > 0)
        need_to_do_daily_dungeon = true;
	if (need_to_do_daily_dungeon && !get_property_boolean("dailyDungeonDone"))
	{
		if (delay_daily_dungeon)
		{
			future_task_entries.listAppend(ChecklistEntryMake("daily dungeon", "da.php", ChecklistSubentryMake("Daily Dungeon", "", delay_daily_dungeon_reason), $locations[the daily dungeon]));
		}
		else
		{
            string url = "da.php";
			string [int] description;
			string l;
            
            if (__misc_state_int["fat loot tokens needed"] > 0)
                l = pluralize(__misc_state_int["fat loot tokens needed"], "token", "tokens") + " needed.";
			
			if (daily_dungeon_aftercore_items_wanted.count() > 0)
            {
                if (l.length() > 0)
                    l += "|";
                l += "Missing " + daily_dungeon_aftercore_items_wanted.listJoinComponents(", ", "and") + ". Possibly buy ";
                if (daily_dungeon_aftercore_items_wanted.count() > 1)
                    l += "them";
                else
                    l += "it";
                l += " in the mall?";
            }
            if (l.length() > 0)
                description.listAppend(l);
			if (!__misc_state["In Aftercore"])
			{
				string submessage = "";
				if (familiar_is_usable($familiar[gelatinous cubeling]))
					submessage = "";
				if (__misc_state["zap wand available"] && __misc_state_int["DD Tokens and keys available"] > 0)
					submessage = "Or zap for it";
				if (submessage.length() > 0)
					description.listAppend(submessage);
			}
			
			if (!in_ronin() && !have_familiar_replacement($familiar[gelatinous cubeling]))
			{
				string [int] shopping_list;
				foreach it in $items[eleven-foot pole,ring of detect boring doors,pick-o-matic lockpicks]
				{
					if (it.available_amount() > 0)
						continue;
					if (it == $item[pick-o-matic lockpicks] && $item[skeleton key].available_amount() > 0)
						continue;
					shopping_list.listAppend(it);
				}
				if (shopping_list.count() > 0)
					description.listAppend("Buy " + shopping_list.listJoinComponents(", ", "and") + " from mall.");
			}
			
            int rooms_left = MAX(0, 15 - get_property_int("_lastDailyDungeonRoom"));
            boolean need_ring = true;
            if (get_property_int("_lastDailyDungeonRoom") > 10)
            {
                need_ring = false;
            }
			if ($item[ring of detect boring doors].available_amount() > 0 && need_ring)
			{
				if ($item[ring of detect boring doors].equipped_amount() == 0)
                {
                    url = "inventory.php?which=2";
					description.listAppend("Wear the ring of detect boring doors.");
                }
				else
					description.listAppend("Keep the ring of detect boring doors equipped.");
			}
            
			
            if (rooms_left < 15)
                description.listAppend(pluralizeWordy(rooms_left, "room", "rooms").capitalizeFirstLetter() + " left.");
            
            if (avoid_using_skeleton_key && $item[skeleton key].available_amount() > 0)
                description.listAppend(HTMLGenerateSpanOfClass("Avoid using your skeleton key, you don't have many left.", "r_bold"));
			
			optional_task_entries.listAppend(ChecklistEntryMake("daily dungeon", url, ChecklistSubentryMake("Daily Dungeon", "", description), $locations[the daily dungeon]));
		}
	}

}
void SCountersInit()
{
    //parse counters:
	//Examples:
	//relayCounters(user, now '1378:Fortune Cookie:fortune.gif', default )
	//relayCounters(user, now '1539:Semirare window begin loc=*:lparen.gif:1579:Semirare window end loc=*:rparen.gif', default )
	//relayCounters(user, now '70:Semirare window begin:lparen.gif:80:Semirare window end loc=*:rparen.gif', default )
	//relayCounters(user, now '1750:Romantic Monster window begin loc=*:lparen.gif:1760:Romantic Monster window end loc=*:rparen.gif', default )
    //relayCounters(user, now '7604:Fortune Cookie:fortune.gif:7584:Fortune Cookie:fortune.gif', default )
    //relayCounters(user, now '450:Fortune Cookie:fortune.gif:458:Fortune Cookie:fortune.gif:401:Dance Card loc=109:guildapp.gif', default )
    //relayCounters(user, now '1271:Nemesis Assassin window begin loc=*:lparen.gif:1286:Nemesis Assassin window end loc=*:rparen.gif:1331:Fortune Cookie:fortune.gif', default )
    
	string counter_string = get_property("relayCounters");
	string [int] counter_split = split_string_mutable(counter_string, ":");
	
	Vec2i romantic_monster_window = Vec2iMake(-1, -1);
	boolean found_romantic_monster = false;
	
	Vec2i semirare_turn_range = Vec2iMake(-1, -1);
	boolean found_semirare_turn_range = false;
	string [int] potential_semirare_turns;
	int turns_until_dance_card = -1;
    
    int [string] windows_begin;
    int [string] windows_end;
	for i from 0 to (counter_split.count() - 1) by 3
	{
		if (i + 3 > counter_split.count())
			break;
		int turn_number = to_int_silent(counter_split[i]);
		int turns_until_counter = turn_number - my_turncount();
		string counter_name = counter_split[i + 1];
		string counter_gif = counter_split[i + 2];
		
		if (counter_name.stringHasPrefix("Semirare window begin"))
		{
			semirare_turn_range.x = turns_until_counter;
			found_semirare_turn_range = true;
		}
		else if (counter_name.stringHasPrefix("Semirare window end"))
		{
			semirare_turn_range.y = turns_until_counter;
			found_semirare_turn_range = true;
		}
		else if (counter_name == "Fortune Cookie")
		{
			potential_semirare_turns.listAppend(turns_until_counter);
		}
		else if (counter_name.stringHasPrefix("Romantic Monster window begin"))
		{
			romantic_monster_window.x = turns_until_counter;
			found_romantic_monster = true;
		}
		else if (counter_name.stringHasPrefix("Romantic Monster window end"))
		{
			romantic_monster_window.y = turns_until_counter;
			found_romantic_monster = true;
		}
		else if (counter_name.stringHasPrefix("Dance Card"))
		{
			turns_until_dance_card = turns_until_counter;
		}
        else if (counter_name.contains_text("window begin"))
        {
            //generic window
            string found_window = counter_name.substring(0, counter_name.index_of(" window begin")).HTMLEscapeString();
            windows_begin[found_window] = turns_until_counter;
        }
        else if (counter_name.contains_text("window end"))
        {
            //generic window
            string found_window = counter_name.substring(0, counter_name.index_of(" window end")).HTMLEscapeString();
            windows_end[found_window] = turns_until_counter;
        }
	}
	__misc_state_int["Turns until dance card"] = turns_until_dance_card;
    if (potential_semirare_turns.count() == 1 && potential_semirare_turns[0] < 0) //missed it
        potential_semirare_turns.listClear();
	if (potential_semirare_turns.count() > 0)
	{
        sort potential_semirare_turns by value.to_int(); //fortune cookie counters are not always sorted
		__misc_state_string["Turns until semi-rare"] = potential_semirare_turns.listJoinComponents(",");
	}
	else if (found_semirare_turn_range && semirare_turn_range.y >= 0)
	{
		__misc_state_string["Turn range until semi-rare"] = semirare_turn_range.x + "," + semirare_turn_range.y;
	}
	if (found_romantic_monster)
	{
		__misc_state_string["Romantic Monster turn range"] = romantic_monster_window.x + "," + romantic_monster_window.y;
	}
	__misc_state_string["Romantic Monster Name"] = get_property("romanticTarget").HTMLEscapeString();
    
    string [int] found_counter_window_names;
    foreach window in windows_begin
    {
        int start_turn = windows_begin[window];
        int end_turn = -1;
        if (windows_end contains window)
            end_turn = windows_end[window];
        string window_turns = start_turn + "," + end_turn;
        __misc_state_string["range of counter window " + window] = window_turns;
        found_counter_window_names.listAppend(window);
    }
    foreach window in windows_end
    {
        if (windows_begin contains window)
            continue;
        int start_turn = -1;
        int end_turn = windows_end[window];
        string window_turns = start_turn + "," + end_turn;
        __misc_state_string["range of counter window " + window] = window_turns;
        found_counter_window_names.listAppend(window);
        
    }
    if (found_counter_window_names.count() > 0)
        __misc_state_string["Found counter windows"] = found_counter_window_names.listJoinComponents(",");
}

void SCountersGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
    string [string] window_image_names;
    window_image_names["Nemesis Assassin"] = "__familiar Penguin Goodfella"; //technically not always a penguin, but..
    window_image_names["Bee"] = "__effect Float Like a Butterfly, Smell Like a Bee"; //bzzz!
    window_image_names["Holiday Monster"] = "__familiar hand turkey";
    //window_image_names["Event Monster"] = ""; //no idea
    string [int] unknown_counters = __misc_state_string["Found counter windows"].split_string_mutable(",");
    foreach key in unknown_counters
    {
        string window_name = unknown_counters[key];
        if (window_name == "")
            continue;
        
        string [int] window_range = __misc_state_string["range of counter window " + window_name].split_string_mutable(",");
        Vec2i turn_range = Vec2iMake(window_range[0].to_int_silent(), window_range[1].to_int_silent());
        
        if (!(turn_range.x <= 10 && from_task) && !(turn_range.x > 10 && !from_task))
            continue;
        
        
        
        boolean very_important = false;
        if (turn_range.x <= 0)
            very_important = true;
        
        
        
        ChecklistSubentry subentry;
        subentry.header = window_name;
        
        
        if (turn_range.y <= 0)
            subentry.header += " now or soon";
        else if (turn_range.x <= 0)
            subentry.header += " between now and " + turn_range.y + " turns.";
        else
            subentry.header += " in [" + turn_range.x + " to " + turn_range.y + "] turns.";
        
        string image_name = "__item Pok&euml;mann figurine: Frank"; //default - some person
        if (window_image_names contains window_name)
            image_name = window_image_names[window_name];
        
        int importance = 10;
        if (very_important)
            importance = -11;
        ChecklistEntry entry = ChecklistEntryMake(image_name, "", subentry, importance);
        
        if (very_important)
            task_entries.listAppend(entry);
        else
            optional_task_entries.listAppend(entry);
        
    }
}

void SCountersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (__misc_state_int["Turns until dance card"] >= 0)
	{
		int turns_until_dance_card = __misc_state_int["Turns until dance card"];
        
		string stats = "Gives ~" + __misc_state_float["dance card average stats"].round() + " mainstats.";
		if (turns_until_dance_card == 0)
		{
			task_entries.listAppend(ChecklistEntryMake("__item dance card", $location[the haunted ballroom].getClickableURLForLocation(), ChecklistSubentryMake("Dance card up now.", "", "Adventure in haunted ballroom. " + stats), -11));
		}
		else
		{
			optional_task_entries.listAppend(ChecklistEntryMake("__item dance card", "", ChecklistSubentryMake("Dance card up in " + pluralize(turns_until_dance_card, "adventure", "adventures") + ".", "", "Haunted ballroom. " + stats)));
		}
	}
    
	SCountersGenerateEntry(task_entries, optional_task_entries, true);
}

void SCountersGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SCountersGenerateEntry(available_resources_entries, available_resources_entries, false);
}
//Some simple suggestions for this forgotten path:

void SWOTSFGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
		return;
}

void SWOTSFGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
		return;
	//Meat:
	if (have_outfit_components("Knob Goblin Harem Girl Disguise") && !get_property_boolean("_treasuryHaremMeatCollected") && locationAvailable($location[Cobb's Knob Barracks]))
	{
		available_resources_entries.listAppend(ChecklistEntryMake("meat", "cobbsknob.php", ChecklistSubentryMake("Cobb's Knob treasury meat", "", "Wear harem girl disguise, adventure once for 500 meat."), 5));
	}
	//Skills:
	string [int] fist_teaching_properties = split_string_mutable("fistTeachingsBarroomBrawl,fistTeachingsBatHole,fistTeachingsConservatory,fistTeachingsFratHouse,fistTeachingsFunHouse,fistTeachingsHaikuDungeon,fistTeachingsMenagerie,fistTeachingsNinjaSnowmen,fistTeachingsPokerRoom,fistTeachingsRoad,fistTeachingsSlums", ",");
	location [string] teaching_properties_to_locations;
	teaching_properties_to_locations["fistTeachingsBarroomBrawl"] = $location[A Barroom Brawl];
	teaching_properties_to_locations["fistTeachingsBatHole"] = $location[The Bat Hole Entrance];
	teaching_properties_to_locations["fistTeachingsConservatory"] = $location[The Haunted Conservatory];
	teaching_properties_to_locations["fistTeachingsFratHouse"] = $location[Frat House];
	teaching_properties_to_locations["fistTeachingsFunHouse"] = $location[The "Fun" House];
	teaching_properties_to_locations["fistTeachingsHaikuDungeon"] = $location[The Haiku Dungeon];
	teaching_properties_to_locations["fistTeachingsMenagerie"] = $location[Cobb's Knob Menagerie\, Level 2];
	teaching_properties_to_locations["fistTeachingsNinjaSnowmen"] = $location[Lair of the Ninja Snowmen];
	teaching_properties_to_locations["fistTeachingsPokerRoom"] = $location[The Poker Room];
	teaching_properties_to_locations["fistTeachingsRoad"] = $location[The Road to White Citadel];
	teaching_properties_to_locations["fistTeachingsSlums"] = $location[Pandamonium Slums];
	
	string [int] missing_areas;
	foreach key in fist_teaching_properties
	{
		string property = fist_teaching_properties[key];
		if (!get_property_boolean(property))
		{
			location place = teaching_properties_to_locations[property];
			missing_areas.listAppend(place.HTMLGenerateFutureTextByLocationAvailability());
		}
	}
	if (missing_areas.count() > 0)
		available_resources_entries.listAppend(ChecklistEntryMake("__item Teachings of the Fist", "", ChecklistSubentryMake("Teachings of the Fist", "", "Found in " + missing_areas.listJoinComponents(", ", "and") + "."), 5));
		
}
Record BountyFileEntry
{
    string plural;
    string difficulty;
    string image;
    int amount_needed;
    monster bounty_monster;
};


location [int] locationsForMonster(monster m)
{
    //hacky, slow, sorry
    location [int] result;
    if (m == $monster[none])
        return result;
    foreach l in $locations[]
    {
        if (l == $location[the haunted wine cellar (automatic)])
            continue;
        monster [int] location_monsters = l.get_monsters();
        foreach key in location_monsters
        {
            if (location_monsters[key] == m)
                result.listAppend(l);
        }
    }
    
    return result;
}

ChecklistSubentry SBHHGenerateHunt(string bounty_item_name, int amount_found, int amount_needed, monster target_monster, location [int] relevant_locations, StringHandle url)
{
    //FIXME update to use new bounty API once 16.3 is out for a sufficient time
    ChecklistSubentry subentry;
    
    subentry.header = "Bounty hunt for " + bounty_item_name.HTMLEscapeString();
    
    
    
    
    //Look up monster location:
    location [int] monster_locations = locationsForMonster(target_monster);
    
    relevant_locations.listAppendList(monster_locations);
    
    
    boolean [location] skippable_ncs_locations = $locations[the stately pleasure dome, the poop deck, the spooky forest,The Haunted Gallery,tower ruins,the castle in the clouds in the sky (top floor), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (basement), mt. molehill, the jungles of ancient loathing];
    
    boolean [location] want_nc_locations = $locations[the penultimate fantasy airship];
    
    string turns_remaining_string = "";
    
    boolean need_plus_combat = false;
    boolean need_minus_combat = false;
    
    location [int] target_locations;
    if (amount_needed != -1 && target_monster != $monster[none] && monster_locations.count() > 0)
    {
        float min_turns_remaining = 100000000.0;
        foreach key in monster_locations
        {
            location l = monster_locations[key];
            boolean noncombats_skippable = (skippable_ncs_locations contains l);
            boolean noncombats_wanted = (want_nc_locations contains l);
            float [monster] appearance_rates = l.appearance_rates_adjusted();
            int number_remaining = amount_needed - amount_found;
            
            if (number_remaining == 0)
            {
                if (url.s.length() == 0)
                    url.s = "place.php?whichplace=forestvillage";
                subentry.header = "Return to the bounty hunter hunter";
                return subentry;
            }
            string clickable_url = getClickableURLForLocation(l);
            if (clickable_url.length() > 0 && url.s.length() == 0)
                url.s = clickable_url;
            
            float bounty_appearance_rate = appearance_rates[target_monster] / 100.0;
            if (noncombats_skippable)
            {
                //Recorrect for NC:
                float nc_rate = appearance_rates[$monster[none]] / 100.0;
                if (nc_rate != 1.0)
                    bounty_appearance_rate /= (1.0 - nc_rate);
            }
            else if (noncombats_wanted)
            {
                //Recorrect for NC:
                float nc_rate = appearance_rates[$monster[none]] / 100.0;
                bounty_appearance_rate += nc_rate;
            }
            
            
            if (bounty_appearance_rate != 0.0)
            {
                float turns_remaining = number_remaining.to_float() / bounty_appearance_rate;
                if (turns_remaining <= min_turns_remaining)
                {
                    if (turns_remaining != min_turns_remaining)
                        target_locations.listClear();
                    target_locations.listAppend(l);
                    
                    min_turns_remaining = turns_remaining;
                    turns_remaining_string = " ~" + pluralize(round(turns_remaining), "turn remains", "turns remain") + ".";
                }
            }
            if (noncombats_wanted && appearance_rates[$monster[none]] != 0.0)
                need_minus_combat = true;
            else if (!noncombats_skippable && appearance_rates[$monster[none]] != 0.0)
                need_plus_combat = true;
        }
    }
    
    
    if (need_plus_combat)
        subentry.modifiers.listAppend("+combat");
    if (need_minus_combat)
        subentry.modifiers.listAppend("-combat");
    
    if (target_monster != $monster[none])
    {
        subentry.entries.listAppend("From a " + target_monster + " in " + target_locations.listJoinComponents(", ", "or") + ".");
        subentry.modifiers.listAppend("olfact " + target_monster);
        subentry.modifiers.listAppend("banish");
    }
    
    
    if (amount_needed == -1)
    {
        subentry.entries.listAppend(amount_found + " found." + turns_remaining_string);
    }
    else
    {
        int amount_remaining = amount_needed - amount_found;
        subentry.entries.listAppend(amount_remaining.int_to_wordy().capitalizeFirstLetter() + " left." + turns_remaining_string);
        //subentry.entries.listAppend(amount_found + " out of " + amount_needed + " found." + turns_remaining_string);
    }
    
    item [string] bounty_item_to_unlock;
    
    bounty_item_to_unlock["glittery skate key"] = $item[tiny bottle of absinthe];
    bounty_item_to_unlock["pile of country guano"] = $item[astral mushroom];
    if (!get_property_boolean("_psychoJarUsed"))
    {
        bounty_item_to_unlock["greasy string"] = $item[jar of psychoses (The Meatsmith)];
        bounty_item_to_unlock["pixellated ashes"] = $item[jar of psychoses (The Crackpot Mystic)];
        bounty_item_to_unlock["unlucky claw"] = $item[jar of psychoses (The Suspicious-Looking Guy)];
    }
    bounty_item_to_unlock["pop art banana peel"] = $item[llama lama gong];
    bounty_item_to_unlock["wig powder"] = $item[&quot;DRINK ME&quot; potion];
    bounty_item_to_unlock["grizzled stubble"] = $item[transporter transponder];
    bounty_item_to_unlock["hickory daiquiri"] = $item[devilish folio];
    
    if (bounty_item_to_unlock contains bounty_item_name)
        subentry.entries.listAppend("Accessed with " + bounty_item_to_unlock[bounty_item_name] + ".");
    
        
    if ((bounty_item_name == "half-empty bottle of eyedrops" || bounty_item_name == "broken plunger handle") && knoll_available())
    {
        url.s = "place.php?whichplace=forestvillage";
        subentry.entries.listClear();
        subentry.modifiers.listClear();
        subentry.entries.listAppend("Unable to complete this bounty under knoll sign.");
        subentry.header = "Cancel bounty hunt for " + bounty_item_name.HTMLEscapeString();
    }
    
    if (bounty_item_name == "greasy string")
        subentry.entries.listAppend("Run away from non-salaminders to complete this bounty in a day.");
    
    if (bounty_item_name == "burned-out arcanodiode")
    {
        if (monster_level_adjustment() < 20)
            subentry.entries.listAppend(HTMLGenerateSpanFont("Run +20 ML to find more MechaMechs.", "red", ""));
    }
    
    return subentry;
}

void SBountyHunterHunterGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Preliminary support, this may break.
    //currentEasyBountyItem, currentHardBountyItem, currentSpecialBountyItem
    
    //FIXME add suggesting taking bounties if we can detect if they have a bounty available
    ChecklistSubentry [int] subentries;
    string [int] bounty_property_names = split_string_mutable("currentEasyBountyItem,currentHardBountyItem,currentSpecialBountyItem", ",");
    string [string] bounty_properties;
    boolean on_bounty = false;
    
    foreach key in bounty_property_names
    {
        string property_name = bounty_property_names[key];
        string property_value = get_property(property_name);
        if (property_value.length() == 0)
            continue;
        bounty_properties[property_name] = property_value;
        on_bounty = true;
    }
    
    StringHandle url_handle;
    
    
    if (!on_bounty)
        return;
    
    
    //Load bounty.txt, not sure how else to acquire this data:
    BountyFileEntry [string] bounty_file;
    file_to_map("bounty.txt", bounty_file);
    
    location [int] relevant_locations;
    foreach bounty_name in bounty_properties
    {
        string property_value = bounty_properties[bounty_name];
        
        //Parse:
        //Format is bounty_item:number_found
        string [int] split = split_string_mutable(property_value, ":");
        if (split.count() != 2)
            continue;
        string bounty_item_name = split[0];
        int amount_found = split[1].to_int_silent();
        
        if (bounty_item_name.length() == 0 || bounty_item_name == "null") //unknown
            bounty_item_name = "unknown";
        
        int amount_needed = -1;
        monster target_monster = $monster[none];
        
        if (bounty_file contains bounty_item_name)
        {
            BountyFileEntry file_entry = bounty_file[bounty_item_name];
            amount_needed = file_entry.amount_needed;
            target_monster = file_Entry.bounty_monster;
        }
        subentries.listAppend(SBHHGenerateHunt(bounty_item_name, amount_found, amount_needed, target_monster, relevant_locations, url_handle));
        
    }
    
    boolean [location] highlight_locations = listGeneratePresenceMap(relevant_locations);
    if (subentries.count() > 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item bounty-hunting helmet", url_handle.s, subentries, highlight_locations));
    }
}

void SOldLevel9GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($location[The Valley of Rof L'm Fao].turnsAttemptedInLocation() == 0)
        return;
    if (__misc_state["In run"])
        return;
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questM15Lol", false); //don't issue a quest log load for this, no information gained
    if (!state.in_progress)
        return;
    
    string [int] description;
    
    if ($item[64735 scroll].available_amount() > 0)
    {
        description.listAppend("Use the 64735 scroll.");
    }
    else
    {
        description.listAppend("Make the 64735 scroll using the rampaging fax machine.");
        
        item [int] components_testing;
        if ($item[64067 scroll].available_amount() == 0)
        {
            components_testing.listAppend($item[30669 scroll]);
            components_testing.listAppend($item[33398 scroll]);
        }
        if ($item[668 scroll].available_amount() == 0)
        {
            components_testing.listAppend($item[334 scroll]);
            components_testing.listAppend($item[334 scroll]);
        }
        string [int] components_needed;
        int [item] amount_used;
        foreach key in components_testing
        {
            item it = components_testing[key];
            if (it.available_amount() - amount_used[it] <= 0)
            {
                components_needed.listAppend(it.to_string());
            }
            else
                amount_used[it] += 1;
        }
        if (components_needed.count() > 0)
            description.listAppend("Need " + components_needed.listJoinComponents(", ", "and") + ".");
        
        //suggest faxing?
        if (__misc_state["fax accessible"])
            description.listAppend("Possibly fax the rampaging adding machine (with all scroll components) for one-turn quest.");
        description.listAppend("Find rampaging adding machine, feed it 334 + 334, 30669 + 33398, 64067 + 668.");
        description.listAppend("31337 scroll is 30669 + 668. (334 + 334)");
    }
    ChecklistSubentry [int] subentries;
    subentries.listAppend(ChecklistSubentryMake("A Quest, LOL", "", description));
    optional_task_entries.listAppend(ChecklistEntryMake("__item 64735 scroll", "mountains.php", subentries, 10, $locations[the valley of rof l'm fao]));
}
void generateGardenEntry(ChecklistEntry [int] available_resources_entries, boolean [item] garden_source_items, boolean [item] garden_creatable_items)
{
    ChecklistSubentry [int] subentries;
    string image_name = "";
    foreach it in garden_source_items
    {
        if (it.available_amount() == 0) continue;
        if (image_name.length() == 0)
            image_name = "__item " + it;
        subentries.listAppend(ChecklistSubentryMake(pluralize(it), "", ""));
    }
    if (subentries.count() > 0)
    {
        ChecklistSubentry subentry = subentries[subentries.count() - 1]; //hacky
        
        
        int [item] creatable_items = garden_creatable_items.creatable_items();
        string [int] output_list;
        foreach it in creatable_items
        {
            int amount = creatable_items[it];
            
            if (it.to_slot() != $slot[none] && it.available_amount() > 0) //already have one
                continue;
            output_list.listAppend(pluralize(amount, it));
        }
        if (creatable_items.count() > 0)
        {
            subentry.entries.listAppend("Can create " + output_list.listJoinComponents(", ", "or") + ".");
        }
        available_resources_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 8));
    }
}



void SGardensGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (!__misc_state["In run"])
        return;

    //Garden items:
    if (true)
    {
        boolean [item] garden_creatable_items;
        garden_creatable_items[$item[pumpkin juice]] = true;
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[pumpkin pie]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[pumpkin beer]] = true;
        if (__misc_state_string["yellow ray source"] == 4766.to_item().to_string())
            garden_creatable_items[4766.to_item()] = true;
        
        generateGardenEntry(available_resources_entries, $items[pumpkin], garden_creatable_items);
    }
    if (true)
    {
        boolean [item] garden_creatable_items;
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[peppermint patty]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[peppermint twist]] = true;
        if (__misc_state["free runs usable"])
            garden_creatable_items[$item[peppermint parasol]] = true;
        garden_creatable_items[$item[peppermint crook]] = true;
        generateGardenEntry(available_resources_entries, $items[peppermint sprout], garden_creatable_items);
    }
    if (true)
    {
        boolean [item] garden_creatable_items;
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[$item[skeleton quiche]] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[$item[crystal skeleton vodka]] = true;
        if (!__misc_state["mysterious island available"])
            garden_creatable_items[$item[skeletal skiff]] = true;
        if (hippy_stone_broken())
            garden_creatable_items[$item[auxiliary backbone]] = true;
        generateGardenEntry(available_resources_entries, $items[skeleton], garden_creatable_items);
    }
    if (true)
    {
        generateGardenEntry(available_resources_entries, $items[handful of barley,cluster of hops,fancy beer bottle,fancy beer label], $items[can of Br&uuml;talbr&auml;u,can of Drooling Monk,can of Impetuous Scofflaw,bottle of old pugilist,bottle of professor beer,bottle of rapier witbier,artisanal homebrew gift package]);
    }
    if (true)
    {
        boolean [item] garden_creatable_items;
        
        foreach it in lookupItems("snow cleats,snow crab,unfinished ice sculpture,snow mobile,ice bucket,bod-ice,snow belt,ice house,ice nine")
            garden_creatable_items[it] = true;
        
        if (!__quest_state["Level 9"].state_boolean["bridge complete"])
            garden_creatable_items[lookupItem("snow boards")] = true;
        
        if (!__quest_state["Level 4"].finished)
            garden_creatable_items[lookupItem("snow shovel")] = true;
        
        if (__misc_state["can eat just about anything"])
            garden_creatable_items[lookupItem("snow crab")] = true;
        if (__misc_state["can drink just about anything"])
            garden_creatable_items[lookupItem("Ice Island Long Tea")] = true;
        if (hippy_stone_broken())
            garden_creatable_items[lookupItem("ice nine")] = true;
        
        
        generateGardenEntry(available_resources_entries, lookupItems("snow berries, ice harvest"), garden_creatable_items);
    }
}

void SKOLHSGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_KOLHS)
		return;
    
    
    ChecklistSubentry subentry;
    subentry.header = "Kingdom of Loathing High School";
    
    int adventures_used = get_property_int("_kolhsAdventures");
    int adventures_remaining = 40 - adventures_used;
    int bell_ring_ring_ring = get_property_int("_kolhsSavedByTheBell");
    int ring_ring_ring_ring_left = 3 - bell_ring_ring_ring;
    
    if (adventures_remaining > 0)
    {
        if ($effect[jamming with the jocks].have_effect() == 0 && $effect[greaser lightnin'].have_effect() == 0 && $effect[Nerd is the Word].have_effect() == 0)
            subentry.entries.listAppend("Acquire intrinsic in halls - use moxie, muscle, or mysticality combat skill.");
        subentry.entries.listAppend(adventures_remaining + " adventures left in school.");
    }
    else if (ring_ring_ring_ring_left > 0)
        subentry.entries.listAppend(pluralize(ring_ring_ring_ring_left, "bell ring", "bell rings") + " left.");
    
    
    if (subentry.entries.count() > 0)
        task_entries.listAppend(ChecklistEntryMake("high school", "", subentry, $locations[the hallowed halls, shop class, chemistry class, art class]));
    
    
    foreach it in $items[can of the cheapest beer,bottle of fruity &quot;wine&quot;,single swig of vodka]
    {
        if (it.available_amount() > 0 && my_inebriety() < 8) //is this eight or nine or
        {
            task_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake("Drink " + it, "", "Next one won't show up until you do."), -11));
            break;
        }
    }
}
void SFaxGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
	if (!(__misc_state["fax available"] && $item[photocopied monster].available_amount() == 0))
        return;
    if (!__misc_state["In aftercore"] && !from_task)
        return;
    if (__misc_state["In aftercore"] && from_task)
        return;
    string url = "clan_viplounge.php?action=faxmachine";
    string [int] potential_faxes;
    
    boolean can_arrow = false;
    if (get_property_int("_badlyRomanticArrows") == 0 && (familiar_is_usable($familiar[obtuse angel]) || familiar_is_usable($familiar[reanimated reanimator])))
        can_arrow = true;
    
    
    if (get_auto_attack() != 0)
    {
        url = "account.php?tab=combat";
        potential_faxes.listAppend("Auto attack is on, disable it?");
    }
    
    //sleepy mariachi
    if (familiar_is_usable($familiar[fancypants scarecrow]) || familiar_is_usable($familiar[mad hatrack]))
    {
        if ($item[spangly mariachi pants].available_amount() == 0 && in_hardcore())
        {
            string fax = "";
            fax += ChecklistGenerateModifierSpan("yellow ray");
            
            if (familiar_is_usable($familiar[fancypants scarecrow]))
            {
                fax += "Makes scarecrow into superfairy";
                if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
                {
                    fax += " and +3 mainstat/turn hat";
                }
            }
            else if (familiar_is_usable($familiar[mad hatrack]))
                fax += "Makes hatrack into superfairy";
            fax += ".";
            
            fax = "sleepy mariachi" + HTMLGenerateIndentedText(fax);
            potential_faxes.listAppend(fax);
        }
    }
    
    //ninja snowman assassin (copy only)
    if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
    {
        if ($item[ninja carabiner].available_amount() + $item[ninja crampons].available_amount() + $item[ninja rope].available_amount() <3)
        {
            string fax = "";
            fax += ChecklistGenerateModifierSpan("+150% init or more, two copies");
            fax += "Copy twice for recreational mountain climbing";
            fax += "<br>" + generateNinjaSafetyGuide(false);
            if ($familiar[obtuse angel].familiar_is_usable() && $familiar[reanimated reanimator].familiar_is_usable())
                fax += "<br>Make sure to copy with angel, not the reanimator.";
            
        
            fax = "ninja snowman assassin" + HTMLGenerateIndentedText(fax);
            potential_faxes.listAppend(fax);
        }
    }
    
    
    //quantum mechanic
    if (!__quest_state["Level 13"].state_boolean["past gates"] && !(__misc_state["dungeons of doom unlocked"]) && __misc_state["can use clovers"] && $item[Blessed large box].available_amount() == 0 && $item[large box].available_amount() == 0 && in_hardcore())
    {
        string fax = "";			
        fax += ChecklistGenerateModifierSpan("+150% item, clover with result, 3 drunkenness.");
        fax += "Blessed large box. (skips opening dungeons of doom for NS gate)";
    
        fax = "quantum mechanic" + HTMLGenerateIndentedText(fax);
        potential_faxes.listAppend(fax);
    }
    
    
    if (!(__quest_state["Level 12"].finished || __quest_state["Level 12"].state_boolean["Lighthouse Finished"] || $item[barrel of gunpowder].available_amount() == 5))
    {
        string line = "Lobsterfrogman (lighthouse quest; copy";
        if (can_arrow)
            line += "/arrow";
        line += ")";
        potential_faxes.listAppend(line);
    }
    
    //orcish frat boy spy / war hippy
    if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues") && !__quest_state["Level 12"].finished)
        potential_faxes.listAppend("Bailey's Beetle (YR) / Hippy spy (30% drop) / Orcish frat boy spy (30% drop) - war outfit");
        
    //dirty thieving brigand...? 
    
    if (!__misc_state["can eat just about anything"]) //can't eat, can't fortune cookie
    {
        //Suggest kge, miner, baabaaburan:
        if (!dispensary_available() && !have_outfit_components("Knob Goblin Elite Guard Uniform"))
        {
            potential_faxes.listAppend("Knob Goblin Elite Guard Captain - unlocks dispensary");
        }
        if (!__quest_state["Level 8"].state_boolean["Past mine"] && !have_outfit_components("Mining Gear") && __misc_state["can equip just about any weapon"])
            potential_faxes.listAppend("7-Foot Dwarf Foreman - Mining gear for level 8 quest. Need YR or +234% items.");
        if (!locationAvailable($location[the hidden park]) && ($item[stone wool].available_amount()) < (2 - MIN(1, $item[the nostril of the serpent].available_amount())))
            potential_faxes.listAppend("Baa'baa'bu'ran - Stone wool for hidden city unlock. Need +100% items (or as much as you can get for extra wool)");
    }
    //sorceress tower/gate item monsters (so many, list them all)
    
    if (!familiar_is_usable($familiar[angry jung man]) && in_hardcore())
    {
        //Can't pull for jar of psychoses, no jung man...
        //It's time for a g-g-g-ghost! zoinks!
        if (!__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0)
        {
            string line = "Ghost - only if you can copy it.";
            if (can_arrow)
                line += " (arrow?)";
            line += "|5 white pixels drop per ghost, speeds up digital key.|Run +150% item.";
            potential_faxes.listAppend(line);
        }
    }
    
    optional_task_entries.listAppend(ChecklistEntryMake("fax machine", url, ChecklistSubentryMake("Fax", "", listJoinComponents(potential_faxes, "<hr>"))));
}

void SFaxGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	SFaxGenerateEntry(available_resources_entries, available_resources_entries, false);
}


void SFaxGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SFaxGenerateEntry(task_entries, optional_task_entries, true);

}

void SDungeonsOfDoomGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Let's see...
    //Normally, we assume the best path is to fax a quantum mechanic (in HC) or pull a large box (in SC)
    //However, that won't work for paths without a fax machine, or for people without a VIP key, or for people who desire to open the dungeons of doom regardless.
    //So, we suggest it in those cases.
    //We also want to work in aftercore - if they haven't unlocked the DOD yet and they've started, give suggestions.
    
    //lastPlusSignUnlock is set by the oracle, not reading the book.
    string title = "Dungeons of Doom";
    string image_name = "Dungeons of Doom";
    string [int] description;
    string [int] modifiers;
    string url = "da.php";
    
    boolean should_output = true;
    
    int turns_attempted = $location[The Enormous Greater-Than Sign].turnsAttemptedInLocation() + $location[the dungeons of doom].turnsAttemptedInLocation();
    
    //Should we unlock/farm the dungeons of doom?
    if (my_basestat(my_primestat()) < 45) //not yet
        return;
    if (!__misc_state["In run"] && turns_attempted == 0) //no, they haven't started yet
        return;
    if (__misc_state["In run"] && __quest_state["Level 13"].state_boolean["past gates"]) //no need for potions
        return;
    if (__misc_state["In run"] && turns_attempted == 0) //in run, but they haven't gone there
    {
        //Let's see.
        //They haven't adventured there yet, so we should only suggest this if it's a good idea.
        if (__misc_state["fax accessible"] && __misc_state["can use clovers"] || !in_hardcore()) //they can fax quantum mechanics and use clovers
            return;
    }
    //They are in run, can't fax quantum mechanics and are in hardcore. So, we'll proceed.
    
    if (get_property_int("lastPlusSignUnlock") == my_ascensions())
    {
        should_output = false;
        //Dungeons of doom unlocked.
        if ($item[plus sign].available_amount() > 0)
        {
            should_output = true;
            //Read plus sign:
            title = "Read plus sign";
            image_name = "__item plus sign";
            url = "inventory.php?which=3";
        }
        else if (__misc_state["In run"])
        {
            int bang_potions_identified = 0;
            foreach s in $strings[lastBangPotion819,lastBangPotion820,lastBangPotion821,lastBangPotion822,lastBangPotion823,lastBangPotion824,lastBangPotion825,lastBangPotion826,lastBangPotion827]
            {
                if (get_property(s).length() > 0)
                    bang_potions_identified += 1;
            }
            if (get_property_int("lastBangPotionReset") != my_ascensions())
                bang_potions_identified = 0;
            //Dungeon of doom unlocked.
            //FIXME do more
            //Suggest identifying potions?
            //Actually. Suggest farming one large box and using a clover, unless bad moon or if they need potions right now and lack three spare drunkenness
            if (__misc_state["can use clovers"])
            {
                if ($items[blessed large box].available_amount() > 0)
                    return;
                if ($items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() == 0)
                    return;
                should_output = true;
                modifiers.listAppend("+150%/+400% item");
                description.listAppend("Run +item in the dungeons of doom, find a large box.|Meatpaste with clover to make a blessed large box. (one of each potion)");
                description.listAppend(bang_potions_identified + "/9 bang potions identified.");
            }
            else
            {
                modifiers.listAppend("+150%/+400% item");
                description.listAppend("Find potions, identify them in combat.|Or acquire one of each, then use with 3 drunkenness available.");
                description.listAppend(bang_potions_identified + "/9 bang potions identified.");
            }
        }
    }
    else
    {
        boolean adventuring_in_sign = true;
        string [int] tasks;
        if (my_meat() < 1000)
            tasks.listAppend("acquire 1000 meat");
        if ($item[plus sign].available_amount() == 0)
            tasks.listAppend("acquire plus sign from non-combat");
        else if ($effect[Teleportitis].have_effect() == 0)
            tasks.listAppend("acquire teleportitis from non-combat or uppercase Q hitting you");
        else
        {
            adventuring_in_sign = false;
            tasks.listAppend("find the oracle, pay for major consultation");
        }
        
        title = "Unlock dungeons of doom";
        if (adventuring_in_sign)
        {
            modifiers.listAppend("-combat");
            if (!__quest_state["Level 13"].state_boolean["past gates"])
            {
                modifiers.listAppend("+150%/+400% item");
                description.listAppend("Run -combat/+item in the enormous greater-than sign.");
            }
            else
                description.listAppend("Run -combat in the enormous greater-than sign.");
            
        }
        description.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
    }
    
    if (should_output)
        optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(title, modifiers, description), $locations[the enormous greater-than sign,the dungeons of doom]));
}
void SJarlsbergGenerateStaff(ChecklistEntry entry, item staff, string property_name, string description, boolean always_output)
{
    if (staff.available_amount() == 0)
        return;
    
    
    int uses_remaining = MAX(0, 5 - get_property_int(property_name));
    if (uses_remaining > 0 || always_output)
    {
        string title;
        title = staff;
        if (uses_remaining != 0)
        {
            title = uses_remaining + " " + staff.to_string().replace_string("Staff of the ", "");
            if (uses_remaining == 1)
                title += " use";
            else
                title += " uses";
        }
            //description = pluralizeWordy(uses_remaining, "use remains", "uses remain").capitalizeFirstLetter() + ".|" + description;
        entry.subentries.listAppend(ChecklistSubentryMake(title, "", description));
        if (entry.image_lookup_name == "")
            entry.image_lookup_name = "__item " + staff;
    }
}


void SJarlsbergGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_JARLSBERG)
		return;
    
	ChecklistEntry entry;
	entry.target_location = "";
	entry.image_lookup_name = "";
    
    
    //wizard staff:
    //Show uses:
    //_jiggleCheesedMonsters split by |
    
    SJarlsbergGenerateStaff(entry, $item[Staff of the All-Steak], "_jiggleSteak", "+300% items.", false);
    
    if (true)
    {
        string olfacted_monster = get_property("_jiggleCreamedMonster");
        boolean always_output = false;
        string cream_line = "Monster olfaction";
        if (olfacted_monster != "")
        {
            always_output = true;
            cream_line += "|Following a " + olfacted_monster.HTMLEscapeString() + ".";
        }
        SJarlsbergGenerateStaff(entry, $item[Staff of the Cream of the Cream], "_jiggleCream", cream_line, always_output);
    }
    if (true)
    {
        //I must capture the avatar (of jarlsberg) to regain my honor
        string [int] banished_monsters = split_string_mutable(get_property("_jiggleCheesedMonsters"), "|");
        boolean always_output = false;
        string cheese_line = "Banish monsters.";
        if (get_property("_jiggleCheesedMonsters").length() > 0)
        {
            cheese_line += "|Monsters banished: " + banished_monsters.listJoinComponents(", ", "and").HTMLEscapeString() + ".";
            always_output = true;
        }
        
        SJarlsbergGenerateStaff(entry, $item[Staff of the Standalone Cheese], "_jiggleCheese", cheese_line, always_output);
    }
    SJarlsbergGenerateStaff(entry, $item[Staff of the Staff of Life], "_jiggleLife", "Restores all HP.", false);
    
    if (entry.subentries.count() > 0)
        available_resources_entries.listAppend(entry);
}
Record COTSuggestion
{
    string reason;
    familiar [int] familiars;
};


COTSuggestion COTSuggestionMake(string reason, familiar [int] familiars)
{
    COTSuggestion suggestion;
    suggestion.reason = reason;
    suggestion.familiars = familiars;
    
    return suggestion;
}

COTSuggestion COTSuggestionMake(string reason, familiar f)
{
    familiar [int] familiar_list;
    familiar_list.listAppend(f);
    return COTSuggestionMake(reason, familiar_list);
}

COTSuggestion COTSuggestionMake(string reason, boolean [familiar] familiars_in)
{
    familiar [int] familiars_out;
    foreach f in familiars_in
        familiars_out.listAppend(f);
    return COTSuggestionMake(reason, familiars_out);
}

void listAppend(COTSuggestion [int] list, COTSuggestion entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


//Follows in order. If we can't find one in the first set, we check the second, then third, etc.
//This allows for supporting +25% meat, then falling back on +20%, etc.
Record COTSuggestionSet
{
    COTSuggestion [int] suggestions;
};

COTSuggestionSet COTSuggestionSetMake(COTSuggestion [int] suggestions)
{
    COTSuggestionSet suggestion_set;
    suggestion_set.suggestions = suggestions;
    
    return suggestion_set;
}

COTSuggestionSet COTSuggestionSetMake(COTSuggestion suggestion)
{
    COTSuggestionSet suggestion_set;
    suggestion_set.suggestions.listAppend(suggestion);
    
    return suggestion_set;
}

void listAppend(COTSuggestionSet [int] list, COTSuggestionSet entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


void SCOTGenerateSuggestions(string [int] description)
{
    familiar enthroned_familiar = my_enthroned_familiar();
    //Suggest what it offers:
    COTSuggestionSet [int] suggestion_sets;
    
    boolean have_two_available = false;
    if ($item[crown of thrones].available_amount() > 0 && lookupItem("Buddy Bjorn").available_amount() > 0)
        have_two_available = true;

    //Relevant:
    //+10ML
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+10 ML and +MP regen", $familiar[el vibrato megadrone])));
    //+15% item drops, or +10%
    if (true)
    {
        COTSuggestion [int] suggestions;
        suggestions.listAppend(COTSuggestionMake("+15% items", $familiars[li'l xenomorph, feral kobold]));
        suggestions.listAppend(COTSuggestionMake("+10% items", $familiars[Reassembled Blackbird,Reconstituted Crow,Oily Woim]));
        suggestion_sets.listAppend(COTSuggestionSetMake(suggestions));
    }
    //+2 moxie/muscle/mysticality stats/fight
    if (__misc_state["Need to level"])
    {
        if (my_primestat() == $stat[moxie])
        {
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 mainstat/fight", $familiars[blood-faced volleyball,jill-o-lantern, nervous tick,mariachi chihuahua, cymbal-playing monkey,hovering skull])));
        }
        else if (my_primestat() == $stat[mysticality])
        {
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 mainstat/fight", $familiars[reanimated reanimator,dramatic hedgehog,cheshire bat,pygmy bugbear shaman,hovering sombrero,sugar fruit fairy, uniclops])));
        }
        else if (my_primestat() == $stat[muscle])
        {
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 mainstat/fight", $familiars[hunchbacked minion, killer bee, grinning turtle,chauvinist pig, baby mutant rattlesnake])));
        }
    }
    //+25% / +20% meat from monsters
    if (true)
    {
        COTSuggestion [int] suggestions;
        suggestions.listAppend(COTSuggestionMake("+25% meat", $familiars[Knob Goblin Organ Grinder,Happy Medium,Hobo Monkey]));
        suggestions.listAppend(COTSuggestionMake("+20% meat", $familiars[Dancing Frog,Psychedelic Bear,Hippo Ballerina,Attention-Deficit Demon,Piano Cat,Coffee Pixie,Obtuse Angel,Hand Turkey,Leprechaun,Grouper Groupie,Mutant Cactus Bud,Jitterbug,Casagnova Gnome]));
        suggestion_sets.listAppend(COTSuggestionSetMake(suggestions));
    }
    //+5 to familiar weight
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+5 familiar weight", $familiars[Gelatinous Cubeling,Pair of Ragged Claws,Spooky Pirate Skeleton,Autonomous Disco Ball,Ghost Pickle on a Stick,Misshapen Animal Skeleton,Animated Macaroni Duck,Penguin Goodfella,Barrrnacle])));
    //+20% to combat init
    if (__misc_state["in run"])
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+20% init", $familiars[Teddy Bear,Emo Squid,Evil Teddy Bear,Syncopated Turtle,Untamed Turtle,Mini-Skulldozer,Cotton Candy Carnie,Origami Towel Crane,Feather Boa Constrictor,Levitating Potato,Temporal Riftlet,Squamous Gibberer,Cuddlefish,Teddy Borg])));
    //+15% to moxie/muscle/mysticality
    if (__misc_state["in run"])
    {
        if (true)
        {
            //Either scaling monster levelling, or the NS
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+15% moxie", $familiars[Ninja Snowflake,Nosy Nose,Clockwork Grapefruit,Sabre-Toothed Lime])));
        }
        if (my_primestat() == $stat[mysticality] && __misc_state["Need to level"])
        {
            //Scaling monster levelling
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+15% mysticality", $familiars[Ragamuffin Imp,Inflatable Dodecapede,Scary Death Orb,Snowy Owl,grue])));
        }
        else if (my_primestat() == $stat[muscle] && __misc_state["Need to level"])
        {
            //Scaling monster levelling
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+15% muscle", $familiars[MagiMechTech MicroMechaMech,Angry Goat,Wereturtle,Stab Bat,Wind-up Chattering Teeth,Imitation Crab])));
        }
    }
    //+20%/+15%/+10% to spell damage
    //Too marginal?
    /*if (__misc_state["in run"])
    {
        COTSuggestion [int] suggestions;
        suggestions.listAppend(COTSuggestionMake("+20% spell damage", $familiar[mechanical songbird]));
        suggestions.listAppend(COTSuggestionMake("+15% spell damage", $familiars[Magic Dragonfish,Pet Cheezling,Rock Lobster]));
        suggestions.listAppend(COTSuggestionMake("+10% spell damage", $familiars[Midget Clownfish,Star Starfish,Baby Yeti,Snow Angel,Wizard Action Figure,Dataspider,Underworld Bonsai,Whirling Maple Leaf,Rogue Program,Howling Balloon Monkey]));
        suggestion_sets.listAppend(COTSuggestionSetMake(suggestions));
    }*/
    //hot wings from reanimator
    if (true)
    {
        string [int] reanimator_reasons;
        
        if (!__quest_state["Level 13"].state_boolean["have relevant drum"] && $item[broken skull].available_amount() == 0)
        {
            reanimator_reasons.listAppend("broken skull (drum)");
        }
        if (__quest_state["Pirate Quest"].state_boolean["need more hot wings"])
            reanimator_reasons.listAppend("hot wings");
        
        if (reanimator_reasons.count() > 0)
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake(reanimator_reasons.listJoinComponents(", ").capitalizeFirstLetter(), $familiar[reanimated reanimator])));
    }
    if (__misc_state["in run"])
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("50% block", $familiar[Mariachi Chihuahua])));
    
    //knob mushrooms from badger
    if (__misc_state["in run"] && __misc_state["can eat just about anything"])
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("Knob mushrooms", $familiar[astral badger])));
        
    boolean need_cold_res = false;
    boolean need_all_res = false;
    //At a-boo peak, but not finished with it:
    if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 && __quest_state["Level 9"].state_boolean["bridge complete"])
        need_all_res = true;
    //Climbing the peak:
    if (__quest_state["Level 8"].state_boolean["Past mine"] && !__quest_state["Level 8"].state_boolean["Groar defeated"] && numeric_modifier("cold resistance") < 5.0)
        need_cold_res = true;
    
    if (__misc_state["in run"] && need_cold_res)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+3 cold res", $familiar[Flaming Face])));
    if (need_cold_res && !$familiar[flaming face].have_familiar_replacement())
        need_all_res = true;
    if (__misc_state["in run"] && need_all_res)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 all res", $familiars[Bulky Buddy Box,Exotic Parrot,Holiday Log,Pet Rock,Toothsome Rock])));
        
    if (__misc_state["in run"] && availableSpleen() >= 4)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("Spleen items", lookupFamiliar("Grim Brother"))));
    
    //slightly powerful:
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+combat", lookupFamiliar("Grim Brother"))));
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("-combat", lookupFamiliar("Grimstone Golem"))));
    
    if (get_property_int("_grimstoneMaskDropsCrown") == 0)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("Grimstone mask", lookupFamiliar("Grimstone Golem"))));
    string [int][int] familiar_options;
    foreach key in suggestion_sets
    {
        boolean found_relevant = false;
        COTSuggestionSet suggestion_set = suggestion_sets[key];
        foreach key2 in suggestion_set.suggestions
        {
            //Suggest the familiar with the highest weight, under the assumption they're using it more.
            COTSuggestion suggestion = suggestion_set.suggestions[key2];
            familiar best_familiar_by_weight = $familiar[none];
            familiar second_best_familiar_by_weight = $familiar[none];
            foreach key3 in suggestion.familiars
            {
                familiar f = suggestion.familiars[key3];
                if (f == $familiar[none]) //didn't find it
                    continue;
                if (f.have_familiar_replacement())
                {
                    if ((best_familiar_by_weight != enthroned_familiar || enthroned_familiar == $familiar[none]) && (best_familiar_by_weight == $familiar[none] || f.familiar_weight() > best_familiar_by_weight.familiar_weight() || f == enthroned_familiar))
                    {
                        second_best_familiar_by_weight = best_familiar_by_weight;
                        best_familiar_by_weight = f;
                    }
                    else if (second_best_familiar_by_weight == $familiar[none] || f.familiar_weight() > second_best_familiar_by_weight.familiar_weight())
                    {
                        if (best_familiar_by_weight != f)
                            second_best_familiar_by_weight = f;
                    }
                }
            }
            if (best_familiar_by_weight != $familiar[none])
            {
                string familiar_string;
                
                familiar_string = best_familiar_by_weight;
                if (enthroned_familiar == best_familiar_by_weight && enthroned_familiar != $familiar[none])
                    familiar_string = HTMLGenerateSpanOfClass(best_familiar_by_weight, "r_bold");
                    
                if (second_best_familiar_by_weight != $familiar[none] && have_two_available)
                    familiar_string += "|" + second_best_familiar_by_weight;
                familiar_options.listAppend(listMake(suggestion.reason, familiar_string));
                break;
            }
        }
    }
    if (familiar_options.count() > 0)
        description.listAppend(HTMLGenerateSimpleTableLines(familiar_options));
}

void SCOTGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if ($item[crown of thrones].available_amount() == 0 && lookupItem("Buddy Bjorn").available_amount() == 0)
		return;
    if (__misc_state["familiars temporarily blocked"]) //avatar paths
        return;
	string [int] description;
    
    item crown_item = $item[crown of thrones];
    if (crown_item.equipped_amount() == 0 && lookupItem("Buddy Bjorn").available_amount() > 0)
        crown_item = lookupItem("Buddy Bjorn");
    
    string image_name = "__item " + crown_item;
    familiar enthroned_familiar = my_enthroned_familiar();
    
    if (($item[crown of thrones].equipped_amount() > 0 || lookupItem("Buddy Bjorn").equipped_amount() > 0) || __misc_state["in run"])
    {
        SCOTGenerateSuggestions(description);
    }
    
	if (enthroned_familiar != $familiar[none])
    {
		description.listAppend(enthroned_familiar + " enthroned.");
        //image_name = "__familiar " + enthroned_familiar.to_string();
    }
    //FIXME my_bjorned_familiar() when 16.3
    
    string url = "familiar.php";
    if ($item[crown of thrones].equipped_amount() == 0 && lookupItem("Buddy Bjorn").equipped_amount() == 0)
        url = "inventory.php?which=2";
        
    string header = crown_item;
    item [int] available_sources;
    
    if (lookupItem("Buddy Bjorn").available_amount() > 0)
        available_sources.listAppend(lookupItem("Buddy Bjorn"));
    if ($item[crown of thrones].available_amount() > 0)
        available_sources.listAppend($item[crown of thrones]);
    if (available_sources.count() > 0)
        header = available_sources.listJoinComponents(", ", "and");
        
    if (description.count() > 0)
        available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(header, "", description), 8));
}


void SPShadyPastGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($item[White Dragon Fang].available_amount() == 0)
    {
        boolean can_acquire_taijijian = ($item[strange goggles].available_amount() > 0 || $item[toy taijijian].available_amount() > 0 || !in_ronin());
        if ($item[magical battery].available_amount() > 0 && can_acquire_taijijian)
        {
            description.listAppend("To make the White Dragon Fang, meatpaste together the toy taijijian with the magical battery.");
        }
    }
    
    string last_combat = $location[chinatown tenement].lastCombatInLocation();
    if ($location[chinatown tenement].combat_queue.contains_text("White Bone Demon") && description.count() == 0) //somewhat limited way of detecting that we are finished
        return;
    if ($item[Test site key].available_amount() > 0)
    {
        //Last segment:
        
        int gold_pieces_needed = MAX(0, 30 - $item[gold piece].available_amount());
        if (last_combat == "the server")
        {
            description.listAppend("Fight the White Bone Demon.");
        }
        else if (gold_pieces_needed > 0)
        {
            //at least one gold piece from a desperate gold farmer is under 21.89% drop rate
            //needs spading
            description.listAppend("Adventure in the chinatown tenement, acquire " + pluralize(gold_pieces_needed, $item[gold piece]) + ".");
            modifiers.listAppend("+400%? item");
            
            if (__misc_state["have olfaction equivalent"])
                modifiers.listAppend("olfact desperate gold farmer");
        }
        else
        {
            description.listAppend("Adventure in the chinatown tenement, fight the server.|Once the server's panel falls off, use the strange goggles.");
        }
    }
    else if ($item[CEO office card].available_amount() > 0)
    {
        //Use to see wheels within wheels.
        description.listAppend("Use CEO office card.");
    }
    else if ($items[makeshift yakuza mask,Novelty tattoo sleeves].items_missing().count() == 0)
    {
        //Visit the first floor.
        item [int] equip_items;
        foreach it in $items[makeshift yakuza mask,novelty tattoo sleeves]
        {
            if (it.equipped_amount() == 0)
                equip_items.listAppend(it);
        }
        if (equip_items.count() > 0 && $location[1st floor\, shiawase-mitsuhama building].turnsAttemptedInLocation() == 0)
        {
            description.listAppend("Equip " + equip_items.listJoinComponents(", ", "and") + ".");
        }
        else
        {
            description.listAppend("Adventure on the floors of the Shiawase-Mitsuhama building, acquire and use cards.");
            
            foreach it in $items[zaibatsu level 2 card, zaibatsu level 3 card]
            {
                if (it.available_amount() == 0)
                    continue;
                description.listAppend("Use " + it + ".");
            }
        }
    }
    else if ($item[strange goggles].available_amount() > 0)
    {
        //Make yakuza mask.
        if ($item[makeshift yakuza mask].available_amount() == 0)
        {
            string line = "Assemble a makeshift yazuka mask with items from the chinatown shops.";
            
            item [int] missing_parts_list = missingComponentsToMakeItem($item[makeshift yakuza mask]);
            if (missing_parts_list.count() == 0)
                line = "Assemble a makeshift yazuka mask.|(rhinoceros horn + rhinoceros horn) + (furry pink pillow + bottle of limeade)";
            else
                line += "|Missing " + missing_parts_list.listJoinComponents(", ", "and") + ".";
            
            description.listAppend(line);
        }
        if ($item[Novelty tattoo sleeves].available_amount() == 0)
        {
            description.listAppend("Buy novelty tattoo sleeves from the chinatown shops.");
        }
    }
    else if ($item[zaibatsu lobby card].available_amount() > 0)
    {
        //Triad factory.
        description.listAppend("Adventure in the sewer triad factory, defeat the Sierpinski brothers.");
        description.listAppend("Run +item for a possible magical battery.");
        modifiers.listAppend("+item");
    }
    else
    {
        //Start of quest.
        description.listAppend("Adventure in the Chinatown shops, defeat a yakuza courier.");
    }
    

	optional_task_entries.listAppend(ChecklistEntryMake("chinatown", "place.php?whichplace=junggate_1", ChecklistSubentryMake("The Suspicious-Looking Guy's Shady Past", modifiers, description),$locations[chinatown shops, chinatown tenement, triad factory,1st floor\, shiawase-mitsuhama building,2nd floor\, shiawase-mitsuhama building,3rd floor\, shiawase-mitsuhama building]));
}

void SPOldManGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($location[The Old Man's Bathtime Adventures].lastNoncombatInLocation() == "Journey's End") //somewhat limited way of detecting that we are finished
        return;
    
    description.listAppend("Sail the seas. Try to one-hit kill the sea monsters.");
    
    if ($item[Bloodbath].available_amount() == 0)
        description.listAppend("Need to finish the area with 50+ crew to acquire Bloodbath.");
    else if ($item[ornamental sextant].available_amount() == 0)
        description.listAppend("Need to finish the area with 37+ crew to acquire ornamental sextant.");
    else if ($item[miniature deck cannon].available_amount() == 0)
        description.listAppend("Need to finish the area with [24 to 36] crew to acquire miniature deck cannon.");
    else if ($item[Foam naval trousers].available_amount() == 0)
        description.listAppend("Need to finish the area with [24 to 36] crew to acquire Foam naval trousers.");
    else if ($item[Foam commodore's hat].available_amount() == 0)
        description.listAppend("Need to finish the area with [24 to 36] crew to acquire Foam commodore's hat.");
    
    description.listAppend("Choose +crew non-combat options, add monsters if you can.");
    
    
    monster olfacted_monster = get_property("olfactedMonster").to_monster();
    if ($effect[on the trail].have_effect() == 0)
        olfacted_monster = $monster[none];
    boolean olfacted_relevant_monster = ($monsters[ferocious roc,giant man-eating shark,Bristled Man-O-War,The Cray-Kin,Deadly Hydra] contains olfacted_monster);
    
    if (__misc_state["have olfaction equivalent"] && !olfacted_relevant_monster)
    {
        description.listAppend("Olfact any monster that is not a fearsome giant squid.");
        modifiers.listAppend("olfaction");
    }
        
    if (my_basestat($stat[mysticality]) >= 200)
    {
        if ($item[Mesmereyes&trade; contact lenses].equipped_amount() == 0)
        {
            description.listAppend("Wear " + $item[Mesmereyes&trade; contact lenses] + ".");
        }
    }
    else
    {
        if ($item[Attorney's badge].equipped_amount() == 0)
        {
            description.listAppend("Wear " + $item[Attorney's badge] + ".");
        }
        description.listAppend("Possibly level mysticality to 200 to wear " + $item[Mesmereyes&trade; contact lenses] + ", makes this area much easier.");
    }
    
    if ($item[Young Man's Crew Sequester].available_amount() > 0)
        description.listAppend("Young Man's Crew Sequester available. (+5 crew)");
    if ($item[Young Man's Cargo Load].available_amount() > 0)
        description.listAppend("Young Man's Cargo Load available. (+4 crayons, +16 bubbles)");
    
    //very limited potato detection:
    if (my_familiar() != $familiar[levitating potato] && !(my_familiar() == $familiar[fancypants scarecrow] && ($slot[familiar].equipped_item() == $item[swashbuckling pants] || $slot[familiar].equipped_item() == $item[spangly mariachi pants]))  && !(my_familiar() == $familiar[mad hatrack] && $slot[familiar].equipped_item() == $item[spangly sombrero]))
        description.listAppend("Run a potato familiar of some kind.");
    
    
	optional_task_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "", ChecklistSubentryMake("The Old Man's Bathtime Adventure", modifiers, description),$locations[The Old Man's Bathtime Adventures]));
}

void SPMeatGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($location[The Nightmare Meatrealm].lastCombatInLocation() == "The Beefhemoth") //somewhat limited way of detecting that we are finished
        return;
        
    modifiers.listAppend("+meat");
    description.listAppend("Adventure until you find the beefhemoth, defeat him.");
    if ($items[the sword in the steak, meatcleaver].available_amount() == 0)
        description.listAppend("The Sword in the Steak is from a 0.1% likelyhood non-combat.|To find it, run away from monsters, preferrably with greatest american pants/navel ring of navel gazing.");
    if ($item[meatcleaver].available_amount() == 0 && $item[the sword in the steak].available_amount() > 0)
    {
        if (my_buffedstat($stat[muscle]) < 1000)
            description.listAppend("To pull the sword from the steak, buff muscle to 1000.");
        else
            description.listAppend("Pull the sword from the steak, adventurer.");
    }
        
        
	optional_task_entries.listAppend(ChecklistEntryMake("meat", "place.php?whichplace=junggate_6", ChecklistSubentryMake("The Meatsmith's Brainspace", modifiers, description),$locations[The Nightmare Meatrealm]));
}

void SPGourdGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($location[the gourd!].lastCombatInLocation() == "Fnord the Unspeakable") //This should work for termination detection?
        return;
        
    modifiers.listAppend("+item?");
    description.listAppend("Adventure in the gourd.");
    if ($item[truthsayer].available_amount() == 0)
        description.listAppend("Truthsayer is (sharp tin strip + wad of spider silk + goblin collarbone), found from gourd monsters.");
    
        
	optional_task_entries.listAppend(ChecklistEntryMake("__item gourd potion", "", ChecklistSubentryMake("The Gourd", modifiers, description),$locations[The gourd!]));
}

void SPCrackpotGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    //Despair, rage, envy. Anger, fear, doubt, regret.
    string url = "place.php?whichplace=junggate_3";
    string image_name = "__item red pixel";
    
    boolean need_byte_sword = !($item[byte].available_amount() + $item[byte].storage_amount() > 0 || $item[flickering pixel].available_amount() + $item[flickering pixel].storage_amount() >= 8);
    
    if ($item[flickering pixel].available_amount() == 8)
    {
        description.listAppend("Use eight flickering pixels to acquire the sword, byte.");
    }
    
    string [int] bosses_remaining;
    
    if ($location[anger man's level].lastCombatInLocation() != "Anger man")
        bosses_remaining.listAppend("anger man");
    if ($location[fear man's level].lastCombatInLocation() != "Fear man")
        bosses_remaining.listAppend("fear man");
    if ($location[doubt man's level].lastCombatInLocation() != "Doubt man")
        bosses_remaining.listAppend("doubt man");
    if ($location[regret man's level].lastCombatInLocation() != "Regret man")
        bosses_remaining.listAppend("regret man");
        
    if (bosses_remaining.count() == 0 && description.count() == 0)
        return;
        
    if (__last_adventure_location == $location[anger man's level] && $location[anger man's level].lastCombatInLocation() != "Anger man")
    {
        description.listAppend("Adventure in anger man's level, defeat the boss.");
        string [int] stats_needed_to_complete_zone;
        string [int] stats_needed_for_flickering_pixel;
        foreach s in $stats[muscle, mysticality, moxie]
        {
            if (s.my_buffedstat() < 50)
            {
                stats_needed_to_complete_zone.listAppend(s.to_string().to_lower_case());
            }
            if (s.my_buffedstat() < 500)
            {
                stats_needed_for_flickering_pixel.listAppend(s.to_string().to_lower_case());
            }
        }
        
        float resistance = numeric_modifier("hot resistance");
        int resistance_needed = MAX(0, floor(25 - resistance));
        if (resistance < 25.0 && need_byte_sword)
            description.listAppend("Need " + resistance_needed + " more hot resistance for the first flickering pixel.");
        
        if (stats_needed_to_complete_zone.count() > 0)
            description.listAppend("Need 50 " + stats_needed_to_complete_zone.listJoinComponents(", ", "and") + " to pass first test.");
        if (stats_needed_for_flickering_pixel.count() > 0 && need_byte_sword)
            description.listAppend("Need 500 " + stats_needed_for_flickering_pixel.listJoinComponents(", ", "and") + " for the second flickering pixels.");
            
            
    }
    else if (__last_adventure_location == $location[fear man's level] && $location[fear man's level].lastCombatInLocation() != "Fear man")
    {
        description.listAppend("Adventure in fear man's level, defeat the boss.");
        
        //50 moxie to complete
        //300 moxie for first flickering
        //25 spooky res for second flickering
        
        if (my_buffedstat($stat[moxie]) < 50)
            description.listAppend("Need 50 total moxie pass first test.");
            
        if (my_buffedstat($stat[moxie]) < 300 && need_byte_sword)
            description.listAppend("Need 300 total moxie for the first flickering pixel.");
            
        float resistance = numeric_modifier("spooky resistance");
        int resistance_needed = MAX(0, floor(25 - resistance));
        if (resistance < 25.0 && need_byte_sword)
            description.listAppend("Need " + resistance_needed + " more spooky resistance for the second flickering pixel.");
    }
    else if (__last_adventure_location == $location[doubt man's level] && $location[doubt man's level].lastCombatInLocation() != "Doubt man")
    {
        description.listAppend("Adventure in doubt man's level, defeat the boss.");
            
        //weapon damage >= 100 to complete
        //HP > 100 to complete
        //weapon damage >= 276(?) for first flickering
        //HP >= 1000 for second flickering
        
        int weapon_damage = numeric_modifier("weapon damage").floor();
        if (weapon_damage < 100)
            description.listAppend("Need " + (100 - weapon_damage) + " more weapon damage to pass first test.");
        if (weapon_damage < 276 && need_byte_sword)
            description.listAppend("Need " + (276 - weapon_damage) + "(?) more weapon damage for the first flickering pixel.");
        
        if (my_hp() < 100)
            description.listAppend("Need 100 total HP to pass second test.");
        if (my_hp() < 1000 && need_byte_sword)
            description.listAppend("Need 1000 total HP for the second flickering pixel.");
    }
    else if (__last_adventure_location == $location[regret man's level] && $location[regret man's level].lastCombatInLocation() != "Regret man")
    {
        description.listAppend("Adventure in regret man's level, defeat the boss.");
        
        //MP >= 100 to complete
        //total elemental damage >= 50 to complete
        //MP >= 1000 for first flickering
        //total elemental damage >= 100 for second flickering
        
        if (my_mp() < 100)
            description.listAppend("Need 100 total MP to pass first test.");
        if (my_mp() < 1000 && need_byte_sword)
            description.listAppend("Need 1000 total MP for the first flickering pixel.");
        int total_elemental_damage = numeric_modifier("cold damage") + numeric_modifier("hot damage") + numeric_modifier("sleaze damage") + numeric_modifier("spooky damage") + numeric_modifier("stench damage");
        
        //FIXME I am not sure if this is correct. How exactly does this test work?
        string [int] missing_second_test;
        string [int] missing_second_pixel_test;
        foreach e in $strings[cold,hot,sleaze,spooky,stench]
        {
            string element_html_id = "r_element_" + e;
            int damage = numeric_modifier(e + " damage").floor();
            if (damage < 50)
                missing_second_test.listAppend(HTMLGenerateSpanOfClass((50 - damage) + " more " + e, element_html_id));
            if (damage < 100)
                missing_second_pixel_test.listAppend(HTMLGenerateSpanOfClass((100 - damage) + " more " + e, element_html_id));
            
        }
        if (missing_second_test.count() > 0)
            description.listAppend("Need " + missing_second_test.listJoinComponents(", ", "and") + " damage to pass the second test.");
        if (missing_second_pixel_test.count() > 0)
            description.listAppend("Need " + missing_second_pixel_test.listJoinComponents(", ", "and") + " damage for the second flickering pixel.");
    }
    
    string await = " await.";
    if (bosses_remaining.count() == 1)
        await = " awaits.";
    if (bosses_remaining.count() > 0)
        description.listAppend(bosses_remaining.listJoinComponents(", ", "and").capitalizeFirstLetter() + await);
    else if ($item[flickering pixel].available_amount() == 8)
    {
        url = "inventory.php?which=3";
        image_name = "__item flickering pixel";
    }
    
    if (__misc_state["In run"])
        description.listAppend("(this isn't ascension relevant after you've gotten a digital key)");
    
        
	optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake("The Crackpot Mystic's Psychoses", modifiers, description),$locations[anger man's level, fear man's level, doubt man's level, regret man's level]));
}



void SPJickGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    if ($item[sword of procedural generation].available_amount() > 0)
        return;
        
    description.listAppend("Fight skeletons.");
    description.listAppend("Make sure you have a monster manuel first; once this tower is complete, there's no way to get these factoids ever again.");
    
    //FIXME be more specific
        
	optional_task_entries.listAppend(ChecklistEntryMake("__item skeleton", "", ChecklistSubentryMake("Jick's Obsessions", modifiers, description),$locations[the tower of procedurally-generated skeletons]));
}



void SPArtistGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    
    foreach e in $effects[My Breakfast With Andrea,The Champion's Breakfast,Tiffany's Breakfast,Breakfast Clubbed]
    {
        if (e.have_effect() > 0)
            return;
    }
    //Let's see.
    //The way this quest works is, you find utensils in the kitchen drawer. (or the mall)
    //Then, you adventure in the grocery bag, and use a utensil on the monsters.
    //The utensil you use on the monster determines breakfast.
    
    
    description.listAppend("Make a breakfast.");
    description.listAppend("To do this, you find utensils in the kitchen drawer, and use them, in combat, on the five different foods in the grocery bag.|Which utensil you use on which food helps determine your breakfast.");
    
    
    string [int] missing_utensils;
    foreach it in $items[Artist's Butterknife of Regret,Artist's Cookie Cutter of Loneliness,Artist's Cr&egrave;me Brul&eacute;e Torch of Fury,Artist's Spatula of Despair,Artist's Whisk of Misery]
    {
        if (it.available_amount() > 0)
            continue;
        string utensil_readable_name = it.to_string().replace_string("Artist's ", "");
        
        missing_utensils.listAppend(utensil_readable_name);
    }
    
    if (missing_utensils.count() > 0)
    {
        modifiers.listAppend("+300% item");
        description.listAppend("Find utensils in the kitchen drawer, or buy in the mall.|Utensils missing:|*" + missing_utensils.listJoinComponents(", ", "and") + ".");
    }
    
    string [int] breakfasts;
    
    string breakfast_line;
    //Meat & Knife, Bread & Knife, Batter & Spatula, Eggs & Whisk, Potatoes & Knife
    breakfast_line += "My Breakfast With Andrea: (+meat)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Butterknife";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Butterknife";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Spatula";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Whisk";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Butterknife";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    //Meat & Cutter, Bread & Torch, Batter & Whisk, Eggs & Torch, Potatoes & Torch
    breakfast_line += "<hr>";
    breakfast_line += "The Champion's Breakfast: (+init)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Whisk";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    //Meat & Spatula, Bread & Cutter, Batter & Cutter, Eggs & Spatula, Potatoes & Whisk
    breakfast_line += "<hr>";
    breakfast_line += "Tiffany's Breakfast: (+item)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Spatula";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Spatula";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Whisk";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    
    //It's actually anything, but let's pick one:
    //Meat & Torch, Bread & Whisk, Batter & Knife, Eggs & Cutter, Potatoes & Spatula
    breakfast_line += "<hr>";
    breakfast_line += "Breakfast Clubbed: (+ML)";
    breakfast_line += "|*Meat" + __html_right_arrow_character + "Cr&egrave;me Brul&eacute;e Torch";
    breakfast_line += "|*Bread" + __html_right_arrow_character + "Whisk";
    breakfast_line += "|*Batter" + __html_right_arrow_character + "Butterknife";
    breakfast_line += "|*Eggs" + __html_right_arrow_character + "Cookie Cutter";
    breakfast_line += "|*Potatoes" + __html_right_arrow_character + "Spatula";
    breakfasts.listAppend(breakfast_line); breakfast_line = "";
    
    description.listAppend("There are four different breakfasts possible:" + HTMLGenerateIndentedText(breakfasts));
    
    if ($item[Ginsu&trade;].available_amount() == 0)
        description.listAppend("Making all four breakfasts in the same ascension lets you acquire the sword, " + $item[Ginsu&trade;] + ".");
        
	optional_task_entries.listAppend(ChecklistEntryMake("__effect My Breakfast With Andrea", "place.php?whichplace=junggate_5", ChecklistSubentryMake("The Pretentious Artist's Obsession", modifiers, description),$locations[a kitchen drawer, a grocery bag]));
}


void SPsychoanalyticGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!get_property_boolean("_psychoJarUsed"))
        return;
    //Can't detect which jar was used, so check where they've been:
    if ($locations[chinatown shops, chinatown tenement, triad factory,1st floor\, shiawase-mitsuhama building,2nd floor\, shiawase-mitsuhama building,3rd floor\, shiawase-mitsuhama building] contains __last_adventure_location)
    {
        //√
        SPShadyPastGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[The Old Man's Bathtime Adventures] contains __last_adventure_location)
    {
        //√
        SPOldManGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[The Nightmare Meatrealm] contains __last_adventure_location)
    {
        SPMeatGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[The gourd!] contains __last_adventure_location)
    {
        SPGourdGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[anger man's level, fear man's level, doubt man's level, regret man's level] contains __last_adventure_location)
    {
        //√
        SPCrackpotGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[the tower of procedurally-generated skeletons] contains __last_adventure_location)
    {
        SPJickGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
    if ($locations[a kitchen drawer, a grocery bag] contains __last_adventure_location)
    {
        //√
        SPArtistGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    }
}
void SOlfactionGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!$skill[Transcendent Olfaction].have_skill())
        return;
    if ($effect[On the trail].have_effect() == 0)
        return;
    if ($item[soft green echo eyedrop antidote].available_amount() == 0) //no removal method
        return;
    
    //Add in some basic reminders to remove olfaction if adventuring in certain areas.
    
    monster olfacted_monster = get_property("olfactedMonster").to_monster();
    if (olfacted_monster == $monster[none] || __last_adventure_location == $location[none])
        return;
    
    monster [location] location_wanted_monster;
    
    if (__misc_state["In run"])
    {
        if ($item[Talisman o' Nam].available_amount() == 0 && !__quest_state["Level 11 Palindome"].finished)
            location_wanted_monster[$location[belowdecks]] = $monster[gaudy pirate];
        if (!__quest_state["Level 8"].state_boolean["Past mine"])
            location_wanted_monster[$location[the goatlet]] = $monster[dairy goat];
        if (!__quest_state["Level 7"].state_boolean["niche finished"])
            location_wanted_monster[$location[the defiled niche]] = $monster[dirty old lihc];
        
        if (!__quest_state["Azazel"].finished)
        {
            location_wanted_monster[$location[infernal rackets backstage]] = $monster[serialbus];
            location_wanted_monster[$location[the laugh floor]] = $monster[ch imp];
        }
        //Deliberately ignored - the quiet healer. (she's used to it) It's possible they may want to olfact the burly sidekick instead, and there's plenty of time in that area.
        
        if (!__quest_state["Level 11 Hidden City"].finished)
        {
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Apartment finished"] && $effect[thrice-cursed].have_effect() == 0)
                location_wanted_monster[$location[the hidden apartment building]] = $monster[pygmy shaman];
                
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Hospital finished"] && $items[surgical apron,bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel].items_missing().count() > 0)
                location_wanted_monster[$location[the hidden hospital]] = $monster[pygmy witch surgeon];
                
                
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Office finished"] && $item[McClusky file (page 5)].available_amount() == 0 && $item[McClusky file (complete)].available_amount() == 0)
                location_wanted_monster[$location[the hidden office building]] = $monster[pygmy witch accountant];
                
            if (!__quest_state["Level 11 Hidden City"].state_boolean["Bowling alley finished"])
            location_wanted_monster[$location[the hidden bowling alley]] = $monster[pygmy bowler];
        }
        location_wanted_monster[$location[cobb's knob harem]] = $monster[knob goblin harem girl];
        location_wanted_monster[$location[The Dark Neck of the Woods]] = $monster[Hellion];
        if (have_skill($skill[summon smithsness]) && $item[dirty hobo gloves].available_amount() == 0 && $item[hand in glove].available_amount() == 0 && __misc_state["Need to level"])
        {
            location_wanted_monster[$location[The Sleazy Back Alley]] = $monster[drunken half-orc hobo];
            location_wanted_monster[$location[The Haunted Pantry]] = $monster[drunken half-orc hobo];
        }
        location_wanted_monster[$location[fear man's level]] = $monster[morbid skull];
        location_wanted_monster[$location[8-bit realm]] = $monster[blooper];
        
        
        if (!__quest_state["Level 11 Pyramid"].finished && olfacted_monster != $monster[tomb servant])
            location_wanted_monster[$location[the upper chamber]] = $monster[tomb rat];

        //FIXME make astronomer suggestions finer-grained
        if (!($monsters[One-Eyed Willie,Burrowing Bishop,Family Jewels,Hooded Warrior,Junk,Pork Sword,Skinflute,Trouser Snake,Twig and Berries,Axe Wound,Beaver,Box,Bush,Camel's Toe,Flange,Honey Pot,Little Man in the Canoe,Muff] contains olfacted_monster))
            location_wanted_monster[$location[the hole in the sky]] = $monster[astronomer];
    }
    
    if (!($monsters[ferocious roc,giant man-eating shark,Bristled Man-O-War,The Cray-Kin,Deadly Hydra] contains olfacted_monster))
        location_wanted_monster[$location[the old man's bathtime adventures]] = $monster[none];
    
    
    foreach l in location_wanted_monster
    {
        monster m = location_wanted_monster[l];
        if (l == $location[none])
            continue;
        if (__last_adventure_location != l)
            continue;
        if (m == olfacted_monster)
            continue;
        
        string [int] description;
        
        string line;
        
        if (m != $monster[none])
            line += "To olfact " + m.HTMLEscapeString() + " instead of " + olfacted_monster.HTMLEscapeString() + ".|";
        else
            line += "To olfact in " + l + ".|";
        
        line += $item[soft green echo eyedrop antidote].pluralize() + " available.";
        
        description.listAppend(line);
        
        
        //Suggestion time!
        task_entries.listAppend(ChecklistEntryMake("__item " + $item[soft green echo eyedrop antidote], "inventory.php?which=1", ChecklistSubentryMake("Remove " + $effect[on the trail], "", description), -11));
        
        break;
    }
    
}
boolean [string] getHolidaysForDate(string realworld_date, int game_day)
{
    boolean [string] holidays;
    
    if (realworld_date == "0202")
        holidays["Groundhog Day"] = true;
    //april fools
    else if (realworld_date == "0401")
        holidays["April Fool's Day"] = true;
    //Talk Like a Pirate Day - september 19th
    else if (realworld_date == "0919")
        holidays["Talk Like a Pirate Day"] = true;
    else if (realworld_date == "1031")
        holidays["Halloween"] = true;
    else if (realworld_date == "0214")
        holidays["Valentine's Day"] = true;
    
    //Crimbo
    if (now_to_string("M").to_int_silent() == 12)
        holidays["Crimbo"] = true;
        
    //Friday the 13th
    if (format_today_to_string("EEE d") == "Fri 13")
        holidays["Friday the 13th"] = true;
    
    
    
    //Festival of Jarlsberg - acquire the party hat? - Jarlsuary 1
    if (gameday_to_int() == 0)
        holidays["Festival of Jarlsberg"] = true;
    //Valentine's Day! - Frankuary 4
    else if (gameday_to_int() == 11)
        holidays["Valentine's Day"] = true;
    //St. Sneaky Pete's Day - Starch 3
    else if (gameday_to_int() == 18)
        holidays["St. Sneaky Pete's Day"] = true;
    //Oyster Egg Day - April 2
    else if (gameday_to_int() == 25)
        holidays["Oyster Egg Day"] = true;
    //El Dia de Los Muertos Borrachos? just wandering monsters... - Martinus 2
    else if (gameday_to_int() == 33)
        holidays["El Dia de Los Muertos Borrachos"] = true;
    //Generic Summer Holiday - Bill 3
    else if (gameday_to_int() == 42)
        holidays["Generic Summer Holiday"] = true;
    //Dependence Day - Bor 4
    else if (gameday_to_int() == 51)
        holidays["Dependence Day"] = true;
    //Arrrbor Day - Petember 4
    else if (gameday_to_int() == 59)
        holidays["Arrrbor Day"] = true;
    //Labór Day - Carlvember 6
    else if (gameday_to_int() == 69)
        holidays["Labór Day"] = true;
    //Halloween / halloween tomorrow, save adventures? - Porktober 8
    else if (gameday_to_int() == 79)
        holidays["Halloween"] = true;
    //feast of boris...? - Boozember 7
    else if (gameday_to_int() == 86)
        holidays["Feast of Boris"] = true;
    //Yuletide? - Dougtember 4
    else if (gameday_to_int() == 91)
        holidays["Yuletide"] = true;
        
    
    return holidays;
}

boolean [string] getHolidaysToday()
{
    return getHolidaysForDate(format_today_to_string("MMdd"), gameday_to_int()); //FIXME Y10K error
}

boolean [string] getHolidaysTomorrow()
{
    //FIXME support next real-world day
    return getHolidaysForDate("", ((gameday_to_int() + 1) % 96));
}


void SHolidayGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    boolean [string] todays_holidays = getHolidaysToday();
    boolean [string] all_tomorrows_parties = getHolidaysTomorrow();
    
    if (all_tomorrows_parties["Halloween"] && !__misc_state["In run"])
        optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "", ChecklistSubentryMake("Save turns for Halloween tomorrow", "", ""), 8));
}

void SRemindersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{

    
    if ($effect[beaten up].have_effect() > 0)
    {
        string [int] methods;
        string url;
        if ($skill[tongue of the walrus].have_skill())
        {
            methods.listAppend("Cast Tongue of the Walrus.");
            url = "skills.php";
        }
        else if (__misc_state["VIP available"] && get_property_int("_hotTubSoaks") < 5)
        {
            methods.listAppend("Soak in VIP hot tub.");
            url = "clan_viplounge.php";
        }
        else if (lookupSkill("Shake it off").have_skill())
        {
            methods.listAppend("Cast shake it off.");
            url = "skills.php";
        }
        else if (__misc_state_int["free rests remaining"] > 0)
        {
            methods.listAppend("Free rest at your campsite.");
            url = "campground.php";
        }
        
        foreach it in $items[tiny house,space tours tripple,personal massager,forest tears,csa all-purpose soap]
        {
            if (it.available_amount() > 0 && methods.count() == 0)
            {
                url = "inventory.php?which=1"; //may not be correct in all cases
                methods.listAppend("Use " + it + ".");
                break;
            }
        }
        
        if (methods.count() > 0)
            task_entries.listAppend(ChecklistEntryMake("__effect beaten up", url, ChecklistSubentryMake("Remove beaten up", "", methods), -11));
    }
    
    if (true)
    {
        //Don't get poisoned.
        effect [int] poison_effects;
        poison_effects.listAppend($effect[Hardly poisoned at all]);
        if (!hippy_stone_broken()) //FIXME remove next PVP season
            poison_effects.listAppend($effect[A Little Bit Poisoned]);
        poison_effects.listAppend($effect[Somewhat Poisoned]);
        poison_effects.listAppend($effect[Really Quite Poisoned]);
        poison_effects.listAppend($effect[Majorly Poisoned]);
        poison_effects.listAppend($effect[Toad In The Hole]);
        
        effect have_poison = $effect[none];
        foreach key in poison_effects
        {
            effect e = poison_effects[key];
            if (e.have_effect() > 0)
            {
                have_poison = e;
                break;
            }
        }
        if (have_poison != $effect[none])
        {
            string url = "";
            string [int] methods;
            
            /*if ($skill[disco nap].have_skill() && $skill[adventurer of leisure].have_skill())
            {
                url = "skills.php";
                methods.listAppend("Cast Disco Nap.");
            }
            else*/
            if (true)
            {
                url = "galaktik.php";
                methods.listAppend("Use Doc Galaktik's anti-anti-antidote.");
                if ($item[anti-anti-antidote].available_amount() > 0)
                    url = "inventory.php?which=1";
            }
            
            task_entries.listAppend(ChecklistEntryMake("__effect " + have_poison, url, ChecklistSubentryMake("Remove " + have_poison, "", methods), -11));
        }
	}
        if ($effect[Cunctatitis].have_effect() > 0 && $skill[disco nap].have_skill() && $skill[adventurer of leisure].have_skill())
    {
        string url = "skills.php";
        string method = "Cast disco nap.";
        task_entries.listAppend(ChecklistEntryMake("__effect Cunctatitis", url, ChecklistSubentryMake("Remove Cunctatitis", "", method), -11));
    }
    
    if (__last_adventure_location == $location[The Red Queen's Garden] && (!in_ronin() || $item[&quot;DRINK ME&quot; potion].available_amount() > 0) && get_property_int("pendingMapReflections") <= 0)
    {
        string url = "mall.php";
        
        if ($item[&quot;DRINK ME&quot; potion].available_amount() > 0)
            url = "inventory.php?which=3";
        
        task_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", url, ChecklistSubentryMake("Drink " + $item[&quot;DRINK ME&quot; potion], "+madness", "Otherwise, no reflections of a map will drop."), -11));
    }
    
    if ($effect[Merry Smithsness].have_effect() == 0 && (!in_ronin() || $item[flaskfull of hollow].available_amount() > 0) && $items[Meat Tenderizer is Murder,Ouija Board\, Ouija Board,Hand that Rocks the Ladle,Saucepanic,Frankly Mr. Shank,Shakespeare's Sister's Accordion,Sheila Take a Crossbow,A Light that Never Goes Out,Half a Purse,loose purse strings,Hand in Glove].equipped_amount() > 0)
    {
        //They (can) have a flaskfull of hollow and have a smithsness item equipped, but no merry smithsness.
        //So, suggest a high-priority task.
        //I suppose in theory they could be saving the flaskfull of hollow for later, for +item? In that case, we would be annoying them. They can closet the flask, but that isn't perfect...
        //Still, I feel as though having this reminder is better than not having it.
        
        //Four items are not on the list due to their marginal bonus: Hairpiece On Fire (+maximum MP), Vicar's Tutu (+maximum HP), Staff of the Headmaster's Victuals (+spell damage), Work is a Four Letter Sword (+weapon damage)
        string url = "mall.php";
        
        if ($item[flaskfull of hollow].available_amount() > 0)
            url = "inventory.php?which=3";
        
        task_entries.listAppend(ChecklistEntryMake("__item flaskfull of hollow", url, ChecklistSubentryMake("Drink " + $item[flaskfull of hollow], "", "Gives +25 smithsness"), -11));
    }
    
	if ($effect[QWOPped Up].have_effect() > 0 && __misc_state["VIP available"] && get_property_int("_hotTubSoaks") < 5) //only suggest if they have hot tub access; other route is a SGEEA, too valuable
    {
        string [int] description;
        description.listAppend("Use hot tub.");
        
		task_entries.listAppend(ChecklistEntryMake("__effect qwopped up", "clan_viplounge.php", ChecklistSubentryMake("Remove QWOPped up effect", "", description), -11));
    }


    if (get_property_monster("lastEncounter") == $monster[dr. awkward] && $item[mega gem].equipped_amount() > 0 && $items[staff of fats, Staff of Ed\, almost, Staff of Ed].available_amount() > 0)
    {
        //Just defeated Dr. Awkward.
        //This will disappear once they adventure somewhere else.
        string [int] description;
        
        description.listAppend("It's not useful now, wear a better accessory?");
        if ($item[talisman o' nam].equipped_amount() > 0)
            description.listAppend("Possibly the talisman as well.");
    
		task_entries.listAppend(ChecklistEntryMake("__item mega gem", "inventory.php?which=2", ChecklistSubentryMake("Possibly unequip the Mega Gem", "", description), -11));
    }
    
    if (__misc_state["need to level"])
    {
        ChecklistEntry stat_items;
        stat_items.image_lookup_name = "";
        stat_items.target_location = "inventory.php?which=3";
        stat_items.importance_level = -11;
        
        effect [item] item_effects;
        string [item] item_descriptions;
        if (__misc_state["need to level moxie"])
        {
            item_descriptions[$item[Ye Olde Bawdy Limerick]] = "+2 moxie stats/fight (20 turns)";
            item_effects[$item[Ye Olde Bawdy Limerick]] = $effect[From Nantucket];
            
            
            item_descriptions[$item[resolution: be sexier]] = "+2 moxie stats/fight (20 turns)";
            item_effects[$item[resolution: be sexier]] = $effect[Irresistible Resolve];
        }

        if (__misc_state["need to level muscle"])
        {
            item_descriptions[$item[Squat-Thrust Magazine]] = "+3 muscle stats/fight (20 turns)";
            item_effects[$item[Squat-Thrust Magazine]] = $effect[Squatting and Thrusting];
            
            
            item_descriptions[$item[resolution: be stronger]] = "+2 muscle stats/fight (20 turns)";
            item_effects[$item[resolution: be stronger]] = $effect[Strong Resolve];
        }
        if (__misc_state["need to level mysticality"])
        {
            item_descriptions[$item[O'RLY Manual]] = "+4 mysticality stats/fight (20 turns)";
            item_effects[$item[O'RLY Manual]] = $effect[You Read The Manual];
            
            
            item_descriptions[$item[resolution: be smarter]] = "+2 mysticality stats/fight (20 turns)";
            item_effects[$item[resolution: be smarter]] = $effect[Brilliant Resolve];
        }
        
        if (my_level() >= 11)
        {
            item_descriptions[$item[BitterSweetTarts]] = "+5.5 " + my_primestat().to_lower_case() + " stats/fight (10 turns)";
            item_effects[$item[BitterSweetTarts]] = $effect[Full of Wist];
        }
        
        item [int] relevant_items;
        string [int] relevant_descriptions;
        foreach it in item_descriptions
        {
            if (it.available_amount() == 0)
                continue;
            if (item_effects[it].have_effect() > 0)
                continue;
            if (stat_items.image_lookup_name.length() == 0)
                stat_items.image_lookup_name = "__item " + it;
            //stat_items.subentries.listAppend(ChecklistSubentryMake("Use " + it, "", item_descriptions[it]));
            relevant_items.listAppend(it);
            relevant_descriptions.listAppend(item_descriptions[it]);
        }
        
        ChecklistSubentry subentry;
        if (relevant_items.count() > 0)
        {
            subentry.header = "Use " + relevant_items.listJoinComponents(", ", "and");
            subentry.entries.listAppend(relevant_descriptions.listJoinComponents(", ", "and"));
        }
        
        
        if (subentry.header.length() > 0)
            stat_items.subentries.listAppend(subentry);
        if (stat_items.subentries.count() > 0)
        {
            task_entries.listAppend(stat_items);
        }
    }
    
    if ($item[evil eye].available_amount() > 0 && __quest_state["Level 7"].state_int["nook evilness"] > 25)
    {
        task_entries.listAppend(ChecklistEntryMake("__item " + $item[evil eye], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[evil eye], "", "Three cyrpt nook beeps."), -11));
    }
    
    if ($familiars[mini-hipster, artistic goth kid] contains my_familiar() && __misc_state["need to level"] && __misc_state_int["hipster fights available"] > 0 && !__misc_state["single familiar run"])
    {
        task_entries.listAppend(ChecklistEntryMake("__familiar " + my_familiar(), "", ChecklistSubentryMake("Buff " + my_primestat(), "", "Extra stats from " + my_familiar() + " fights."), -11));
    }
    
    boolean have_blacklight_bulb = (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeHeadlight") == "Blacklight Bulb");
    if (__last_adventure_location == $location[the arid\, extra-dry desert] && !__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"] && __misc_state["In run"] && !have_blacklight_bulb)
    {
        boolean have_uv_compass_equipped = __quest_state["Level 11 Pyramid"].state_boolean["Have UV-Compass eqipped"];
        
        if (!have_uv_compass_equipped)
        {
            string title;
            item compass_item = $item[UV-resistant compass];
            if (lookupItem("ornate dowsing rod").available_amount() > 0)
                compass_item = lookupItem("ornate dowsing rod");
            
            title = "Equip " + compass_item;
            if (compass_item.available_amount() == 0)
                title = "Find and equip " + compass_item;
            task_entries.listAppend(ChecklistEntryMake("__item " + compass_item, "", ChecklistSubentryMake(title, "", "Explore more efficiently."), -11));
        }
        
    }
    if ($item[bottle of blank-out].available_amount() > 0 && $item[glob of blank-out].available_amount() == 0 && __misc_state["In run"] && __misc_state["free runs usable"] && !get_property_boolean("_blankOutUsed"))
    {
        task_entries.listAppend(ChecklistEntryMake("__item " + $item[bottle of blank-out], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[bottle of blank-out], "", "Acquire glob to run away with."), -11));
    
    }
    if (__last_adventure_location == $location[the haunted ballroom] && $item[dance card].available_amount() > 0 && __misc_state["need to level"] && my_primestat() == $stat[moxie] && __misc_state_int["Turns until dance card"] == -1)
    {
        
        string [int] semirare_turns = __misc_state_string["Turns until semi-rare"].split_string(",");
        
        boolean delay_for_semirare = false;
        foreach key in semirare_turns
        {
            if (semirare_turns[key] == 3)
            {
                delay_for_semirare = true;
                break;
            }
        }
        
        if (delay_for_semirare)
            task_entries.listAppend(ChecklistEntryMake("__item " + $item[dance card], "", ChecklistSubentryMake(HTMLGenerateSpanFont("Avoid using " + $item[dance card], "red", ""), "", HTMLGenerateSpanFont("You have a semi-rare coming up then, wait a turn first.", "red", "")), -11));
        else
        {
            string [int] description;
            description.listAppend("Gives ~" + __misc_state_float["dance card average stats"].round() + " mainstat in four turns.");
            if ($item[dance card].available_amount() > 1)
                description.listAppend("Have " + $item[dance card].pluralizeWordy() + ".");
            task_entries.listAppend(ChecklistEntryMake("__item " + $item[dance card], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[dance card], "", description), -11));
        }
    }
}
void SGrimstoneHareGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    string [int] description;
    string [int] modifiers;
    
    modifiers.listAppend("mysticality");
    modifiers.listAppend("spell damage percent");
    modifiers.listAppend("spell critical percent");
    int time_remaining = lookupEffect("hare-brained").have_effect();
    
    //FIXME deal with coldform / hotform / etc
    
    description.listAppend("Adventure on the deserted stretch of road.|Cast elemental-aligned powerful spells on vehicles.|The more damage, the faster you go.");
    
    description.listAppend("The speedy/expensive strategy is to nanorhino/ice house/batter up/pantsgiving/crystal skull/etc. banish everything that isn't an ice cream truck, and olfact ice cream trucks.|Then run coldform, buff spell damage, mysticality, and spell damage critical.|Then cast shrap.");
    
    string [string] elemental_descriptions;
    
    string [int] missing_hobopolis_spells;
    
    elemental_descriptions["hot"] = HTMLGenerateSpanOfClass("hot", "r_element_hot");
    elemental_descriptions["cold"] = HTMLGenerateSpanOfClass("cold", "r_element_cold");
    elemental_descriptions["spooky"] = HTMLGenerateSpanOfClass("spooky", "r_element_spooky");
    elemental_descriptions["stench"] = HTMLGenerateSpanOfClass("stench", "r_element_stench");
    elemental_descriptions["sleaze"] = HTMLGenerateSpanOfClass("sleaze", "r_element_sleaze");
    
    
    boolean have_shrap = lookupSkill("shrap").have_skill();
    
    if (have_shrap && $effect[hotform].have_effect() > 0)
        elemental_descriptions["hot"] = "Shrap (" + elemental_descriptions["hot"] + ")";
    else if ($skill[volcanometeor showeruption].have_skill())
        elemental_descriptions["hot"] = "Volcanometeor Showeruption (" + elemental_descriptions["hot"] + ")";
    else if ($skill[Awesome Balls of Fire].have_skill())
        elemental_descriptions["hot"] = "Awesome Balls of Fire (" + elemental_descriptions["hot"] + ")";
    else
        missing_hobopolis_spells.listAppend("Awesome Balls of Fire");
    
    
    if (have_shrap && $effect[coldform].have_effect() > 0)
        elemental_descriptions["cold"] = "Shrap (" + elemental_descriptions["cold"] + ")";
    else if ($skill[Snowclone].have_skill())
        elemental_descriptions["cold"] = "Snowclone (" + elemental_descriptions["cold"] + ")";
    else
        missing_hobopolis_spells.listAppend("Snowclone");
    
    if (have_shrap && $effect[spookyform].have_effect() > 0)
        elemental_descriptions["spooky"] = "Shrap (" + elemental_descriptions["spooky"] + ")";
    else if ($skill[Raise Backup Dancer].have_skill())
        elemental_descriptions["spooky"] = "Raise Backup Dancer (" + elemental_descriptions["spooky"] + ")";
    else
        missing_hobopolis_spells.listAppend("Raise Backup Dancer");
    
    if (have_shrap && $effect[stenchform].have_effect() > 0)
        elemental_descriptions["stench"] = "Shrap (" + elemental_descriptions["stench"] + ")";
    else if ($skill[Eggsplosion].have_skill())
        elemental_descriptions["stench"] = "Eggsplosion (" + elemental_descriptions["stench"] + ")";
    else
        missing_hobopolis_spells.listAppend("Eggsplosion");
    
    
    if (have_shrap && $effect[sleazeform].have_effect() > 0)
        elemental_descriptions["sleaze"] = "Shrap (" + elemental_descriptions["sleaze"] + ")";
    else if ($skill[Grease Lightning].have_skill())
        elemental_descriptions["sleaze"] = "Grease Lightning (" + elemental_descriptions["sleaze"] + ")";
    else
        missing_hobopolis_spells.listAppend("Grease Lightning");
    
    
    
    string [int][int] vehicle_descriptions;
    if (!lookupMonster("Fire truck").is_banished())
        vehicle_descriptions.listAppend(listMake("Fire truck", elemental_descriptions["hot"]));
    if (!lookupMonster("ice cream truck").is_banished())
        vehicle_descriptions.listAppend(listMake("ice cream truck", elemental_descriptions["cold"]));
    if (!lookupMonster("monster hearse").is_banished())
        vehicle_descriptions.listAppend(listMake("monster hearse", elemental_descriptions["spooky"]));
    if (!lookupMonster("sewer tanker").is_banished())
        vehicle_descriptions.listAppend(listMake("sewer tanker", elemental_descriptions["stench"]));
    if (!lookupMonster("sketchy van").is_banished())
        vehicle_descriptions.listAppend(listMake("sketchy van", elemental_descriptions["sleaze"]));
    
    monster last_encounter = get_property_monster("lastEncounter");
    string [int] vehicles = split_string_mutable("Fire truck,ice cream truck,monster hearse,sewer tanker,sketchy van", ",");
    
    foreach key in vehicles
    {
        monster vehicle = vehicles[key].to_monster();
        if (vehicle == $monster[none])
            continue;
        
        if (last_encounter != vehicle)
            continue;
        
        vehicle_descriptions[key][0] = HTMLGenerateSpanOfClass(vehicle_descriptions[key][0], "r_bold");
        vehicle_descriptions[key][1] = HTMLGenerateSpanOfClass(vehicle_descriptions[key][1], "r_bold");
    }
    
    description.listAppend("Spells to cast: " + HTMLGenerateIndentedText(HTMLGenerateSimpleTableLines(vehicle_descriptions)));
    
    if (my_familiar() != $familiar[magic dragonfish])
        description.listAppend("Run magic dragonfish familiar.");
    else if ($familiar[magic dragonfish].familiar_weight() < 20)
        description.listAppend("Gain " + (20 - $familiar[magic dragonfish].familiar_weight()) + " pounds on your magic dragonfish.");
    
    if (missing_hobopolis_spells.count() > 0)
        description.listAppend("Could acquire " + missing_hobopolis_spells.listJoinComponents(", ", "or") + " from the mall.");
    
    if ($skill[frigidalmatian].have_skill() && $effect[frigidalmatian].have_effect() == 0)
        description.listAppend("Could cast frigidalmatian. (expensive)");
    
    if (my_basestat($stat[mysticality]) < 400)
        description.listAppend("May want to gain " + (400 - my_basestat($stat[mysticality])) + " more mysticality.");
    
    description.listAppend(pluralize(time_remaining, "turn", "turns") + " remaining in race.");
    
    
    
    
    //lookupLocation("A Deserted Stretch of I-911")
	optional_task_entries.listAppend(ChecklistEntryMake("__effect hare-brained", "place.php?whichplace=ioty2014_hare", ChecklistSubentryMake("Hare Race", modifiers, description)));
}


void SGrimstoneGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //grimstoneMaskPath
    //rumpelstiltskinTurnsUsed gives number of turns used getting materials. rumpelstiltskinKidsRescued gives the number of children rescued. It is likely that there are more messages than are documented on the wiki, so if some are missing and aren't parsed correctly, please put a note in the forum.
    //cinderellaMinutesToMidnight gives number of turns remaining. cinderellaScore gives the current score. Also added grimstoneMaskPath which gives the current grimstone content available, "stepmother", "wolf", "witch", "gnome" or "hare".
    if (lookupEffect("hare-brained").have_effect() > 0)
        SGrimstoneHareGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}


void SSneakyPeteGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    //my_audience() whenever 16.3 is out
    
    
	ChecklistEntry entry;
	entry.target_location = "";
	entry.image_lookup_name = "";
    entry.importance_level = 1;
    
    
    if (get_revision() >= 13783)
    {
        int total_free_peel_outs_available = 10;
        if (get_property("peteMotorbikeTires") == "Racing Slicks")
            total_free_peel_outs_available += 20;
        
        int free_peel_outs_available = MAX(0, total_free_peel_outs_available - get_property_int("_petePeeledOut"));
        
        if (lookupSkill("Peel Out").have_skill() && free_peel_outs_available > 0)
        {
            string [int] description;
            
            if (get_property("peteMotorbikeMuffler") == "Extra-Smelly Muffler")
                description.listAppend("Free runaway/banish in-combat.");
            else
                description.listAppend("Free runaway in-combat.");
            
            if (entry.image_lookup_name.length() == 0)
                entry.image_lookup_name = "__skill Easy Riding";
        
            entry.subentries.listAppend(ChecklistSubentryMake(pluralize(free_peel_outs_available, "peel out", "peel outs"), "10 MP/cast", description));
        }
    }
    
    if (lookupSkill("Fix Jukebox").have_skill() && get_property_int("_peteJukeboxFixed") < 3 && get_revision() >= 13785)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJukeboxFixed"));
        
        string [int] description;
        description.listAppend("+300% item, one combat.");
        description.listAppend("+10 audience love.");
        
        if (entry.image_lookup_name.length() == 0)
            entry.image_lookup_name = "__effect jukebox hero";
        
        entry.subentries.listAppend(ChecklistSubentryMake(pluralize(uses_remaining, "jukebox fix", "jukebox fixes"), "25 MP", description));
    }
    
    if (lookupSkill("Jump Shark").have_skill() && get_property_int("_peteJumpedShark") < 3 && get_revision() >= 13730)
    {
        int uses_remaining = MAX(0, 3 - get_property_int("_peteJumpedShark"));
        
        string [int] description;
        description.listAppend((10 * my_level()) + " muscle/mysticality/moxie. (increases with level)");
        description.listAppend("+10 audience hate.");
        
        if (entry.image_lookup_name.length() == 0)
            entry.image_lookup_name = "__skill jump shark";
        entry.subentries.listAppend(ChecklistSubentryMake(pluralize(uses_remaining, "shark jump", "shark jumps"), "25 MP", description));
    }
    
    
    if (entry.subentries.count() > 0)
        available_resources_entries.listAppend(entry);
}

void SSneakyPeteGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
		return;
    
    
    if (true)
    {
        string [int] parts_not_upgraded;
        int motorcycle_upgrades_have = 0;
        
        foreach s in $strings[peteMotorbikeTires,peteMotorbikeGasTank,peteMotorbikeHeadlight,peteMotorbikeCowling,peteMotorbikeMuffler,peteMotorbikeSeat]
        {
            if (get_property(s).length() > 0)
                motorcycle_upgrades_have += 1;
            else
                parts_not_upgraded.listAppend(s);
        }
        int motorcycle_upgrades_available = MIN(6, my_level() / 2);
        
        if (motorcycle_upgrades_have < motorcycle_upgrades_available && (get_revision() > 13738 || motorcycle_upgrades_have > 0))
        {
            string [int] description;
            description.listAppend(pluralize(motorcycle_upgrades_available - motorcycle_upgrades_have, "upgrade", "upgrades") + " available.");
            
            string [int] upgrades;
            foreach key in parts_not_upgraded
            {
                string property_name = parts_not_upgraded[key];
                
                string name = "";
                string [int] options;
                
                if (property_name == "peteMotorbikeSeat")
                {
                    name = "Seat";
                    
                    options.listAppend("regenerate 5-6 HP/MP");
                    options.listAppend("find meat after combat (marginal)");
                    options.listAppend("-30 ML (harmful)");
                }
                else if (property_name == "peteMotorbikeCowling")
                {
                    name = "Cowling";
                    if (__quest_state["Level 7"].state_int["alcove evilness"] > 26 || __quest_state["Level 7"].state_int["cranny evilness"] > 26 || __quest_state["Level 7"].state_int["niche evilness"] > 26 || __quest_state["Level 7"].state_int["nook evilness"] > 26)
                        options.listAppend("faster cyrpt");
                    if (__quest_state["Level 12"].finished)
                        options.listAppend("passive +damage/round");
                    else
                        options.listAppend("passive +damage/round and +3 war kills");
                    options.listAppend("+5 stats/fight");
                }
                else if (property_name == "peteMotorbikeGasTank")
                {
                    name = "Gas tank";
                
                    if (!knoll_available() && !__misc_state["desert beach available"])
                        options.listAppend("desert beach access");
                    if (!__misc_state["mysterious island available"])
                        options.listAppend("mysterious island access");
                    options.listAppend("+50% combat initiative");
                }
                else if (property_name == "peteMotorbikeHeadlight")
                {
                    name = "Headlight";
                    
                    if (lookupSkill("Flash Headlight").have_skill())
                    {
                        options.listAppend("yellow ray from flash headlight");
                        options.listAppend("prismatic damage from flash headlight");
                    }
                    else
                    {
                        options.listAppend("yellow ray (need flash headlight)");
                        options.listAppend("prismatic damage (need flash headlight)");
                    }
                    if (!__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"])
                        options.listAppend("+2% desert exporation");
                }
                else if (property_name == "peteMotorbikeMuffler")
                {
                    name = "Muffler";
                    if (lookupSkill("Rev Engine").have_skill())
                    {
                        options.listAppend("+combat% from rev engine");
                        options.listAppend("-combat% from rev engine");
                    }
                    else
                    {
                        options.listAppend("+X% combat from rev engine (need skill)");
                        options.listAppend("-X% combat from rev engine (need skill)");
                    }
                    if (lookupSkill("Peel Out").have_skill())
                        options.listAppend("peel out banishes");
                    else
                        options.listAppend("peel out banishes (need skill)");
                }
                else if (property_name == "peteMotorbikeTires")
                {
                    name = "Tires";
                    if (lookupSkill("Peel Out").have_skill())
                        options.listAppend("extra free runs with peel out");
                    else
                        options.listAppend("extra free runs (need peel out)");
                    if (lookupSkill("Pop Wheelie").have_skill())
                        options.listAppend("pop wheelie does more damage");
                    else
                        options.listAppend("pop wheelie does more damage (need skill)");
                    
                    if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
                        options.listAppend("near-instant level 8 quest completion");
                }
                
                if (name.length() > 0)
                {
                    upgrades.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + " - " + options.listJoinComponents(", ", "or").capitalizeFirstLetter() + ".");
                    //upgrades.listAppend(HTMLGenerateSpanOfClass(name, "r_bold") + "|*" + options.listJoinComponents("|*"));
                }
            }
            description.listAppendList(upgrades);


            optional_task_entries.listAppend(ChecklistEntryMake("__skill Easy Riding", "main.php?action=motorcycle", ChecklistSubentryMake("Upgrade your bike", "", description), 11));
            
        }
    }
    
    //sneakyPetePoints first
    /*int skills_available = MIN(30, MIN(15, my_level()) + get_property_int("sneakyPetePoints"));
    
    int skills_have = 0;
    foreach s in lookupSkills("Catchphrase,Mixologist,Throw Party,Fix Jukebox,Snap Fingers,Shake It Off,Check Hair,Cocktail Magic,Make Friends,Natural Dancer,Rev Engine,Born Showman,Pop Wheelie,Rowdy Drinker,Peel Out,Easy Riding,Check Mirror,Riding Tall,Biker Swagger,Flash Headlight,Insult,Live Fast,Incite Riot,Jump Shark,Animal Magnetism,Smoke Break,Hard Drinker,Unrepentant Thief,Brood,Walk Away From Explosion")
    {
        if (s.have_skill())
            skills_have += 1;
    }
    
    if (skills_available > skills_have)
    {
        string [int] description;
        description.listAppend("At least " + pluralizeWordy(skills_available - skills_have, "skill", "skills") + " available.");
        optional_task_entries.listAppend(ChecklistEntryMake("__skill Natural Dancer", "da.php?place=gate3", ChecklistSubentryMake("Buy Sneaky Pete skills", "", description), 11));
    }*/
}

void SetsInit()
{
    SCountersInit();
    QHitsInit();
}


void SetsGenerateResources(ChecklistEntry [int] available_resources_entries)
{
	SFamiliarsGenerateResource(available_resources_entries);
	SSemirareGenerateResource(available_resources_entries);
	SSkillsGenerateResource(available_resources_entries);
	SMiscItemsGenerateResource(available_resources_entries);
	SCopiedMonstersGenerateResource(available_resources_entries);
    STomesGenerateResource(available_resources_entries);
    SSmithsnessGenerateResource(available_resources_entries);
	SSugarGenerateResource(available_resources_entries);
    SPulverizeGenerateResource(available_resources_entries);
    SLibramGenerateResource(available_resources_entries);
    SWOTSFGenerateResource(available_resources_entries);
    SCountersGenerateResource(available_resources_entries);
    SGardensGenerateResource(available_resources_entries);
    SFaxGenerateResource(available_resources_entries);
    SJarlsbergGenerateResource(available_resources_entries);
    SCOTGenerateResource(available_resources_entries);
    SSneakyPeteGenerateResource(available_resources_entries);
    
    
}

void SetsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SFamiliarsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SSemirareGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDispensaryGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SCouncilGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SCopiedMonstersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SAftercoreGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QHitsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	S8bitRealmGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDailyDungeonGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SCountersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SWOTSFGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SKOLHSGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SBountyHunterHunterGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SOldLevel9GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SFaxGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDungeonsOfDoomGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SPsychoanalyticGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SOlfactionGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SHolidayGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SRemindersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SGrimstoneGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SSneakyPeteGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    
}


void SetsGenerateMissingItems(ChecklistEntry [int] items_needed_entries)
{
    QHitsGenerateMissingItems(items_needed_entries);
}



boolean [item] __pulls_reasonable_to_buy_in_run;

int pullable_amount(item it, int maximum_total_wanted)
{
	boolean buyable_in_run = false;
	if (__pulls_reasonable_to_buy_in_run contains it)
		buyable_in_run = true;
	if (maximum_total_wanted == 0)
		maximum_total_wanted = __misc_state_int["pulls available"] + it.available_amount();
	if (__misc_state["Example mode"]) //simulate pulls
	{
		if (buyable_in_run)
			return min(__misc_state_int["pulls available"], maximum_total_wanted);
		else
			return min(__misc_state_int["pulls available"], min(storage_amount(it) + it.available_amount(), maximum_total_wanted));
	}
	
	int amount = storage_amount(it);
	if (buyable_in_run)
		amount = 20;
	int total_amount = amount + it.available_amount();
	
	if (total_amount > maximum_total_wanted)
	{
		amount = maximum_total_wanted - it.available_amount();
	}
	
	if (amount < 0) amount = 0;
	return min(__misc_state_int["pulls available"], amount);
}

int pullable_amount(item it)
{
	return pullable_amount(it, 0);
}


//generic pull item
record GPItem
{
	//Either item OR alternate_name
	item it;
	string alternate_name;
	string alternate_image_name;
	
	string reason;
	int max_wanted;
};

GPItem GPItemMake(item it, string reason, int max_wanted)
{
	GPItem result;
	result.it = it;
	result.reason = reason;
	result.max_wanted = max_wanted;
	return result;
}

GPItem GPItemMake(item it, string reason)
{
	return GPItemMake(it, reason, 0);
}

GPItem GPItemMake(string alternate_name, string alternate_image_name, string reason)
{
	GPItem result;
	result.alternate_name = alternate_name;
	result.alternate_image_name = alternate_image_name;
	result.reason = reason;
	result.max_wanted = 1;
	return result;
}

void listAppend(GPItem [int] list, GPItem entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void generatePullList(Checklist [int] checklists)
{
    //Needs improvement.
	ChecklistEntry [int] pulls_entries;
	
	int pulls_available = __misc_state_int["pulls available"];
	if (pulls_available <= 0)
		return;
	if (pulls_available > 0)
		pulls_entries.listAppend(ChecklistEntryMake("special subheader", "", ChecklistSubentryMake(pluralize(pulls_available, "pull", "pulls") + " remaining")));
	
	item [int] pullable_list_item;
	int [int] pullable_list_max_wanted;
	string [int] pullable_list_reason;
	
	GPItem [int] pullable_item_list;
	
	//IOTMs:
	if ($items[empty rain-doh can,can of rain-doh,spooky putty monster].available_amount() == 0)
		pullable_item_list.listAppend(GPItemMake($item[spooky putty sheet], "5 copies/day", 1));
	pullable_item_list.listAppend(GPItemMake($item[over-the-shoulder folder holder], "So many things!", 1));
	pullable_item_list.listAppend(GPItemMake($item[pantsgiving], "5x banish/day|+2 stats/fight|+15% items|2 extra fullness (realistically)", 1));
    if (!__misc_state["familiars temporarily blocked"])
        pullable_item_list.listAppend(GPItemMake($item[snow suit], "+20 familiar weight for a while, +4 free runs|+10% item|spleen items", 1));
    if (!__misc_state["familiars temporarily blocked"])
    {
        if (lookupItem("Buddy Bjorn").storage_amount() > 0)
            pullable_item_list.listAppend(GPItemMake(lookupItem("Buddy Bjorn"), "+10ML/+lots MP hat|or +item/+init/+meat/etc", 1));
        else
            pullable_item_list.listAppend(GPItemMake($item[crown of thrones], "+10ML/+lots MP hat|or +item/+init/+meat/etc", 1));
    }
	pullable_item_list.listAppend(GPItemMake($item[boris's helm], "+15ML/+5 familiar weight/+init/+mp regeneration/+weapon damage", 1));
	if ($item[empty rain-doh can].available_amount() == 0 && $item[can of rain-doh].available_amount() == 0)
		pullable_item_list.listAppend(GPItemMake($item[can of rain-doh], "5 copies/day|everything really", 1));
	pullable_item_list.listAppend(GPItemMake($item[plastic vampire fangs], "?", 1));
    pullable_item_list.listAppend(GPItemMake($item[operation patriot shield], "?", 1));
    pullable_item_list.listAppend(GPItemMake($item[v for vivala mask], "?", 1));
	
	if (my_primestat() == $stat[mysticality]) //should we only suggest this for mysticality classes?
		pullable_item_list.listAppend(GPItemMake($item[Jarlsberg's Pan], "?", 1)); //"
	pullable_item_list.listAppend(GPItemMake($item[loathing legion knife], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[greatest american pants], "navel runaways|others", 1));
	pullable_item_list.listAppend(GPItemMake($item[juju mojo mask], "towerkilling?", 1));
	pullable_item_list.listAppend(GPItemMake($item[navel ring of navel gazing], "free runaways|easy fights", 1));
	//pullable_item_list.listAppend(GPItemMake($item[haiku katana], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[bottle-rocket crossbow], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[jekyllin hide belt], "+variable% item", 3));
    
    if (__misc_state["Need to level"])
    {
        pullable_item_list.listAppend(GPItemMake($item[hockey stick of furious angry rage], "+30ML accessory.", 1));
    }
    pullable_item_list.listAppend(GPItemMake($item[ice sickle], "+15ML 1h weapon|+item/+meat/+init foldables", 1));
	pullable_item_list.listAppend(GPItemMake($item[camp scout backpack], "+15% items on back", 1));
    if (__misc_state["Torso aware"])
    {
        pullable_item_list.listAppend(GPItemMake($item[flaming pink shirt], "+15% items on shirt. (marginal)" + (__misc_state["familiars temporarily blocked"] ? "" : "|Or extra experience on familiar. (very marginal)"), 1));
        if (__misc_state["Need to level"] && lookupItem("Sneaky Pete's leather jacket (collar popped)").available_amount() == 0 && lookupItem("Sneaky Pete's leather jacket").available_amount() == 0)
            pullable_item_list.listAppend(GPItemMake($item[cane-mail shirt], "+20ML shirt", 1));
    }
    
    
	
	boolean have_super_fairy = false;
	if ((familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0) || (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0))
		have_super_fairy = true;
	if (!have_super_fairy)
	{
		if (familiar_is_usable($familiar[fancypants scarecrow]))
			pullable_item_list.listAppend(GPItemMake($item[spangly mariachi pants], "2x fairy", 1));
		else if (familiar_is_usable($familiar[mad hatrack]))
			pullable_item_list.listAppend(GPItemMake($item[spangly sombrero], "2x fairy", 1));
	}
	//pullable_item_list.listAppend(GPItemMake($item[jewel-eyed wizard hat], "a wizard is you!", 1));
	//pullable_item_list.listAppend(GPItemMake($item[origami riding crop], "+5 stats/fight, but only if the monster dies quickly", 1)); //not useful?
	//pullable_item_list.listAppend(GPItemMake($item[plastic pumpkin bucket], "don't know", 1)); //not useful?
	//pullable_item_list.listAppend(GPItemMake($item[packet of mayfly bait], "why let it go to waste?", 1));
	
	if ($items[greatest american pants, navel ring of navel gazing].available_amount() + pullable_amount($item[greatest american pants]) + pullable_amount($item[navel ring of navel gazing]) == 0)
		pullable_item_list.listAppend(GPItemMake($item[peppermint parasol], "free runaways", 1));
		
	
	if (__misc_state["can eat just about anything"] && availableFullness() > 0)
	{
		pullable_item_list.listAppend(GPItemMake("Food", "hell ramen", "key lime pies, moon pies, fudge bunnies, etc."));
	}
	if (__misc_state["can drink just about anything"] && availableDrunkenness() >= 0)
	{
		pullable_item_list.listAppend(GPItemMake("Drink", "gibson", "wrecked generators, etc."));
	}
    
    if (__misc_state["In run"] && !__quest_state["Level 13"].state_boolean["past gates"] && ($items[large box, blessed large box].available_amount() == 0 && $items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() > 0))
        pullable_item_list.listAppend(GPItemMake($item[large box], "Combine with clover for blessed large box", 1));
    
    if (my_path_id() != PATH_CLASS_ACT_2) //FIXME really think about this suggestion
        pullable_item_list.listAppend(GPItemMake($item[slimy alveolus], "40 turns of +50ML (" + floor(40 * 50 * __misc_state_float["ML to mainstat multiplier"]) +" mainstat total, cave bar levelling)|1 spleen", 3));
	
	
    if (!get_property_boolean("_blankOutUsed"))
        pullable_item_list.listAppend(GPItemMake($item[bottle of blank-out], "run away from your problems|expensive", 1));
	
	
	
	//Quest-relevant items:
	
	if (!__quest_state["Level 9"].state_boolean["bridge complete"])
	{
		int boxes_needed = MIN(__quest_state["Level 9"].state_int["bridge fasteners needed"], __quest_state["Level 9"].state_int["bridge lumber needed"]) / 5;
		
		boxes_needed = MIN(3, boxes_needed); //bridge! farming?
		
		if (boxes_needed > 0)
			pullable_item_list.listAppend(GPItemMake($item[smut orc keepsake box], "skip level 9 bridge building", boxes_needed));
	}
	if (!__quest_state["Level 11 Palindome"].finished && $item[mega gem].available_amount() == 0 && ($item[wet stew].available_amount() + $item[wet stunt nut stew].available_amount() + $item[wet stew].creatable_amount() == 0))
		pullable_item_list.listAppend(GPItemMake($item[wet stew], "make into wet stunt nut stew|skip whitey's grove", 1));
    
    if (!__quest_state["Level 13"].state_boolean["Past keys"])
    {
        pullable_item_list.listAppend(GPItemMake($item[star hat], "speed up hole in the sky", 1));
        if ($items[star crossbow, star staff, star sword].available_amount() == 0)
            pullable_item_list.listAppend(GPItemMake($item[star crossbow], "speed up hole in the sky", 1));
	}
    
	//FIXME suggest guitar if we're out of clovers, we need one, and we've gone past belowdecks already?
    //FIXME suggest outfits?
	
	pullable_item_list.listAppend(GPItemMake($item[ten-leaf clover], "Turn saving everywhere|Generic pull"));
	
	string [int] scrip_reasons;
	int scrip_needed = 0;
	if (!__misc_state["mysterious island available"])
	{
		scrip_needed += 3;
		scrip_reasons.listAppend("mysterious island");
	}
	if ($item[uv-resistant compass].available_amount() == 0 && lookupItem("ornate dowsing rod").available_amount() == 0 && __misc_state["can equip just about any weapon"] && !__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"])
	{
		scrip_needed += 1;
		scrip_reasons.listAppend($item[uv-resistant compass].to_string());
	}
	if (scrip_needed > 0)
	{
		pullable_item_list.listAppend(GPItemMake($item[Shore Inc. Ship Trip Scrip], "Saves three turns each|" + scrip_reasons.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".", scrip_needed));
	}
	
	
	boolean currently_trendy = (my_path_id() == PATH_TRENDY);
	foreach key in pullable_item_list
	{
		GPItem gp_item = pullable_item_list[key];
		string reason = gp_item.reason;
		string [int] reason_list = split_string_mutable(reason, "\\|");
		
		if (gp_item.alternate_name != "")
		{
			pulls_entries.listAppend(ChecklistEntryMake(gp_item.alternate_image_name, "storage.php", ChecklistSubentryMake(gp_item.alternate_name, "", reason_list)));
			continue;
		}
		
		
		item [int] items;
		int [item] related_items = get_related(gp_item.it, "fold");
		if (related_items.count() == 0)
			items.listAppend(gp_item.it);
		else
		{
			foreach it in related_items
				items.listAppend(it);
		}
		
		
		int max_wanted = gp_item.max_wanted;
		
		
		foreach key in items
		{
			item it = items[key];
			if (currently_trendy && !is_trendy(it))
				continue;
			int actual_amount = pullable_amount(it, max_wanted);
			if (actual_amount > 0)
			{
				if (max_wanted == 1)
					pulls_entries.listAppend(ChecklistEntryMake(it, "storage.php", ChecklistSubentryMake(it, "", reason_list)));
				else
					pulls_entries.listAppend(ChecklistEntryMake(it, "storage.php", ChecklistSubentryMake(pluralize(actual_amount, it), "", reason_list)));
				break;
			}
		}
	}
	
	checklists.listAppend(ChecklistMake("Suggested Pulls", pulls_entries));
}

void PullsInit()
{
    //Pulls which are reasonable to buy in the mall, then pull:
	__pulls_reasonable_to_buy_in_run = $items[peppermint parasol,slimy alveolus,bottle of blank-out,disassembled clover,ten-leaf clover,ninja rope,ninja crampons,ninja carabiner,clockwork maid,sonar-in-a-biscuit,knob goblin perfume,chrome ore,linoleum ore,asbestos ore,goat cheese,enchanted bean,dusty bottle of Marsala,dusty bottle of Merlot,dusty bottle of Muscat,dusty bottle of Pinot Noir,dusty bottle of Port,dusty bottle of Zinfandel,ketchup hound,lion oil,bird rib,stunt nuts,drum machine,beer helmet,distressed denim pants,bejeweled pledge pin,reinforced beaded headband,bullet-proof corduroys,round purple sunglasses,wand of nagamar,ng,star crossbow,star hat,star staff,star sword,Star key lime pie,Boris's key lime pie,Jarlsberg's key lime pie,Sneaky Pete's key lime pie,tomb ratchet,tangle of rat tails,swashbuckling pants,stuffed shoulder parrot,eyepatch,Knob Goblin harem veil,knob goblin harem pants,knob goblin elite polearm,knob goblin elite pants,knob goblin elite helm,cyclops eyedrops,mick's icyvapohotness inhaler,large box,marzipan skull,jaba&ntilde;ero-flavored chewing gum,handsomeness potion,Meleegra&trade; pills,pickle-flavored chewing gum,lime-and-chile-flavored chewing gum,gremlin juice,wussiness potion,Mick's IcyVapoHotness Rub,super-spiky hair gel,adder bladder,black no. 2,skeleton,rock and roll legend,wet stew,glass of goat's milk,hot wing,frilly skirt,pygmy pygment,wussiness potion,gremlin juice,adder bladder,Angry Farmer candy,thin black candle,super-spiky hair gel,Black No. 2,Mick's IcyVapoHotness Rub,Frigid ninja stars,Spider web,Sonar-in-a-biscuit,Black pepper,Pygmy blowgun,Meat vortex,Chaos butterfly,Photoprotoneutron torpedo,Fancy bath salts,inkwell,Hair spray,disease,bronzed locust,Knob Goblin firecracker,powdered organs,leftovers of indeterminate origin,mariachi G-string,NG,plot hole,baseball,razor-sharp can lid,tropical orchid,stick of dynamite,barbed-wire fence,smut orc keepsake box];
}
//FIXME this should be customizable. But an interface for that would be tricky...

record PlantSuggestion
{
	location loc;
	string plant_name;
	string details;
};

PlantSuggestion PlantSuggestionMake(location loc, string plant_name, string details)
{
	PlantSuggestion result;
	result.loc = loc;
	result.plant_name = plant_name;
	result.details = details;
	return result;
}


void listAppend(PlantSuggestion [int] list, PlantSuggestion entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


PlantSuggestion [int] __plants_suggested_locations;

record Plant
{
	string name;
	string image_lookup_name; //auto-generated
	string zone_effect;
	string terrain;
	boolean territorial;
};

Plant PlantMake(string name, string zone_effect, string terrain, boolean territorial)
{
	Plant result;
	result.name = name;
	result.image_lookup_name = "Plant " + name;
	result.zone_effect = zone_effect;
	result.terrain = terrain;
	result.territorial = territorial;
	return result;
}
Plant [string] __plant_properties;
string [int] __plant_output_order; //MUST contain all plants


void finalizeSetUpFloristState()
{
	if (!florist_available())
		return;
	
	//Set up suggestions:
	//We can have this as either plants keeping track of a bunch of locations, or locations keeping track of a bunch of plants.
	//Keeping it the same as get_florist_plants makes it mentally easier to track, I guess.
	
	
	__plant_properties["Rabid Dogwood"] = PlantMake("Rabid Dogwood", "+30 ML", "outdoor", true);
	__plant_properties["Rutabeggar"] = PlantMake("Rutabeggar", "+25% item", "outdoor", true);
	__plant_properties["Rad-ish Radish"] = PlantMake("Rad-ish Radish", "+5 moxie stats/fight", "outdoor", true);
	
	__plant_properties["War Lily"] = PlantMake("War Lily", "+30 ML", "indoor", true);
	__plant_properties["Stealing Magnolia"] = PlantMake("Stealing Magnolia", "+25% item", "indoor", true);
	__plant_properties["Canned Spinach"] = PlantMake("Canned Spinach", "+5 muscle stats/fight", "indoor", true);
	
	__plant_properties["Blustery Puffball"] = PlantMake("Blustery Puffball", "+30 ML", "underground", true);
	__plant_properties["Horn of Plenty"] = PlantMake("Horn of Plenty", "+25% item", "underground", true);
	__plant_properties["Wizard's Wig"] = PlantMake("Wizard's Wig", "+5 myst stats/fight", "underground", true);
	__plant_properties["Shuffle Truffle"] = PlantMake("Shuffle Truffle", "+25% init", "underground", false);
	
	
	__plant_output_order = split_string("Rabid Dogwood,Rutabeggar,Rad-ish Radish,Artichoker,Smoke-ra,Skunk Cabbage,Deadly Cinnamon,Celery Stalker,Lettuce Spray,Seltzer Watercress,War Lily,Stealing Magnolia,Canned Spinach,Impatiens,Spider Plant,Red Fern,BamBOO!,Arctic Moss,Aloe Guv'nor,Pitcher Plant,Blustery Puffball,Horn of Plenty,Wizard's Wig,Shuffle Truffle,Dis Lichen,Loose Morels,Foul Toadstool,Chillterelle,Portlybella,Max Headshroom,Spankton,Kelptomaniac,Crookweed,Electric Eelgrass,Duckweed,Orca Orchid,Sargassum,Sub-Sea Rose,Snori,Up Sea Daisy", ",");
	
	//Go through all potentials:
	boolean [string] plants_used;
	if (true)
	{
		string [int] internal_plants_used = split_string(get_property("_floristPlantsUsed"), ",");
		foreach key in internal_plants_used
			plants_used[internal_plants_used[key]] = true;
	}
	//Shuffle Truffle - underground, init:
	if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
    {
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled alcove], "Shuffle Truffle", "+2.5% modern zmobie"));
	}
	//Horn of Plenty - underground, +item:
	if (__quest_state["Level 7"].state_boolean["nook needs speed tricks"] && item_drop_modifier() < 400.0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled nook], "horn of plenty", "Evil eye, 20% drop."));
	}
	if (!__quest_state["Level 11"].finished && item_drop_modifier() < 400.0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the upper chamber], "horn of plenty", "Tomb ratchets, 20% drop."));
	}
	if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 3)
	{
        string description = "Sonars-in-a-biscuit, 15% drop.";
        if (!__quest_state["Level 7"].state_boolean["nook finished"]) //FIXME test if that plant is planted already
            description += " Or ignore in favor of the defiled nook?";
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the batrat and ratbat burrow], "horn of plenty", description));
	}
    //Intentionally ignored: +item plants in the orchard. Normally you'd plant in the upper chamber instead, since both of these quests often happen on the same day? And there's three zones to plant in - way too complicated.
	if (!__quest_state["Level 12"].finished && __misc_state["need to level"] && __quest_state["Level 12"].state_int["frat boys left on battlefield"] != 0 && __quest_state["Level 12"].state_int["hippies left on battlefield"] != 0)
	{
		location battlefield_zone = $location[the battlefield (hippy uniform)];
        if (__quest_state["Level 12"].state_int["frat boys left on battlefield"] > __quest_state["Level 12"].state_int["hippies left on battlefield"])
            battlefield_zone = $location[the battlefield (frat uniform)];
		if (my_primestat() == $stat[moxie])
			__plants_suggested_locations.listAppend(PlantSuggestionMake(battlefield_zone, "Rad-ish Radish", ""));
		else
			__plants_suggested_locations.listAppend(PlantSuggestionMake(battlefield_zone, "Rabid Dogwood", ""));
	}
	if (__misc_state["need to level mysticality"])
	{
		//Wizard's Wig - underground, +5 myst stats/fight:
        //in SC, can reach level 7 first, so ignore this one:
        //if (!__quest_state["Level 4"].finished)
            //__plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Boss Bat's Lair], "Wizard's Wig", ""));
        if (!__quest_state["Level 7"].state_boolean["niche finished"])
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Defiled Niche], "Wizard's Wig", ""));
	}
	//Blustery Puffball - underground, +ML:
	if (!__quest_state["Level 7"].state_boolean["cranny finished"])
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled cranny], "Blustery Puffball", "More beeps from swarm of ghuol whelps."));
	}
	//Canned Spinach - indoor, +5 muscle stats/fight:
    if (my_primestat() == $stat[muscle] && __misc_state["need to level"])
    {
        //let's see... castle?
        if ($item[Spookyraven gallery key].available_amount() > 0 && !__misc_state["Stat gain from NCs reduced"])
        {
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[the haunted gallery], "Canned Spinach", "While powerlevelling."));
        }
    }
	
	//Stealing Magnolia - indoor, +item:
	//The haunted ballroom, except they may be changing that?
    if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
    {
        //let's see... castle?
        if (my_path_id() != PATH_CLASS_ACT_2)
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[the haunted ballroom], "Stealing Magnolia", "Dance cards from waltzers, for power leveling.")); //FIXME if stat changes in the future, remove this suggestion
        
	}
	//War Lily - indoor, +ML:
	//Rad-ish Radish - outdoor, +5 moxie stats/fight:
    if (__misc_state["need to level moxie"])
    {
        //you wouldn't plant +30ML at airship - because oil peak likely needs it today. FIXME suggest if oil peak done/planted? HCO I guess? I dunno
        __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Spooky Forest], "Rad-ish Radish", ""));
        __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Penultimate Fantasy Airship], "Rad-ish Radish", ""));
    }
	//Rutabeggar - outdoor, +item:
	if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[a-boo peak], "Rutabeggar", "A-boo clue, 15% drop."));
	}
	
	//Rabid Dogwood - outdoor, +ML:
	if (__quest_state["Level 9"].state_float["oil peak pressure"] > 0 && monster_level_adjustment() < 100)
    {
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[oil peak], "Rabid Dogwood", ""));
    }
	if (!__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"] && __misc_state["need to level"]) //you spend a lot of turns in the desert
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the arid, extra-dry desert], "Rabid Dogwood", ""));
	
	//Now, go through results, and remove all plants that are already in that location:
	
	string [location][int] current_plants = get_florist_plants();
	boolean [location][string] current_plants_used; //inverse of current_plants, used for quick searching
	foreach l in current_plants
	{
		foreach key in current_plants[l]
		{
			string plant = current_plants[l][key];
			current_plants_used[l][plant] = true;
		}
	}
	
	int [int] keys_removing;
	foreach key in __plants_suggested_locations
	{
		PlantSuggestion suggestion = __plants_suggested_locations[key];
		if (current_plants_used[suggestion.loc][suggestion.plant_name] || plants_used[suggestion.plant_name])
		{
			keys_removing.listAppend(key);
		}
	}
	foreach key in keys_removing
	{
		remove __plants_suggested_locations[keys_removing[key]];
	}
}

void generateFloristFriar(Checklist [int] checklists)
{
	if (!florist_available())
		return;
    if (!__misc_state["In run"]) //currently, these suggestions are in-run only
        return;
	ChecklistEntry [int] florist_entries;
	
    ChecklistSubentry [int] subentries;
	foreach key in __plant_output_order
	{
		string plant_name = __plant_output_order[key];
		if (!(__plant_properties contains plant_name))
			continue;
		Plant plant = __plant_properties[plant_name];
		
		ChecklistSubentry subentry;
		subentry.header = plant_name + ", " + plant.terrain;
		subentry.modifiers.listAppend(plant.zone_effect);
		
		//See if we suggested this plant anywhere:
		foreach key in __plants_suggested_locations
		{
			PlantSuggestion suggestion = __plants_suggested_locations[key];
			if (suggestion.plant_name == plant_name)
			{
				//we did
				string suggestion_text = suggestion.loc;
				if (suggestion.details != "")
					suggestion_text += " (" + suggestion.details + ")";
				if (!locationAvailable(suggestion.loc))
					subentry.entries.listAppend(HTMLGenerateSpanOfClass(suggestion_text, "r_future_option"));
				else
					subentry.entries.listAppend(suggestion_text);
			}
		}
        
        string image_name = plant.image_lookup_name;
		if (subentry.entries.count() > 0)
        {
            if (false)
                florist_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry));
            else
                subentries.listAppend(subentry);
        }
	}
    if (subentries.count() > 0)
    {
        florist_entries.listAppend(ChecklistEntryMake("plant up sea daisy", "place.php?whichplace=forestvillage&amp;action=fv_friar", subentries));
    }
	
	checklists.listAppend(ChecklistMake("Florist Friar", florist_entries));
}

void setUpExampleState()
{
	__misc_state["In run"] = true;
    
	//Do a default reset of each quest:
	
	foreach quest_name in __quest_state
	{
		QuestState state = __quest_state[quest_name];
		
		
		QuestStateParseMafiaQuestPropertyValue(state, "started");
		
		
		__quest_state[quest_name] = state;
	}
	
	__misc_state_int["pulls available"] = 17;
}


void setUpState()
{
	__last_adventure_location = get_property_location("lastAdventure");
    
	__misc_state["In aftercore"] = get_property_boolean("kingLiberated");
	__misc_state["In run"] = !__misc_state["In aftercore"];
    if (__misc_state["Example mode"])
        __misc_state["In run"] = true;
    __misc_state["In valhalla"] = (my_class().to_string() == "Astral Spirit");
    
	if (my_turncount() >= 30 && get_property_int("singleFamiliarRun") != -1)
		__misc_state["single familiar run"] = true;
	if ($item[Clan VIP Lounge key].available_amount() > 0)
		__misc_state["VIP available"] = true;
	boolean fax_available = false;
	if (__misc_state["VIP available"])
	{
		if (!get_property_boolean("_photocopyUsed"))
			fax_available = true;
		__misc_state["fax accessible"] = true;
	}
	
	if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_TRENDY)
	{
		__misc_state["fax accessible"] = false;
	}
    if (!__misc_state["fax accessible"])
		fax_available = false;
	__misc_state["fax available"] = fax_available;
	
	
	__misc_state["can eat just about anything"] = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_ZOMBIE_SLAYER || fullness_limit() == 0)
	{
		__misc_state["can eat just about anything"] = false;
	}
	
	__misc_state["can drink just about anything"] = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_KOLHS || inebriety_limit() == 0)
	{
		__misc_state["can eat just about anything"] = false;
	}
	
	
	__misc_state["can equip just about any weapon"] = true;
	if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_WAY_OF_THE_SURPRISING_FIST)
	{
		__misc_state["can equip just about any weapon"] = false;
	}
	
	
	__misc_state["MMJs buyable"] = false;
	if (get_property_int("lastGuildStoreOpen") == my_ascensions())
	{
		if (my_class() == $class[pastamancer] || my_class() == $class[sauceror] || (my_class() == $class[accordion thief] && my_level() >= 9))
            __misc_state["MMJs buyable"] = true;
	}
	
	//Check for moxie/mysticality/muscle combat skills:
	
	foreach s in $skills[]
	{
		if (!s.combat)
			continue;
		if (!s.have_skill())
			continue;
		if (s.class == $class[accordion thief] || s.class == $class[disco bandit])
			__misc_state["have moxie class combat skill"] = true;
		if (s.class == $class[pastamancer] || s.class == $class[sauceror])
			__misc_state["have mysticality class combat skill"] = true;
		if (s.class == $class[seal clubber] || s.class == $class[turtle tamer])
			__misc_state["have muscle class combat skill"] = true;
	}
	
	
	
	boolean yellow_ray_available = false;
	string yellow_ray_source = "";
	string yellow_ray_image_name = "";
	boolean yellow_ray_potentially_available = false;
    
    string [int] item_sources = split_string_mutable("4766,5229,6673,7013", ",");
    
    foreach key in item_sources
    {
        item source = item_sources[key].to_int().to_item();
        if (!(source.available_amount() > 0 || (source == 4766.to_item() && 4761.to_item().available_amount() > 0)))
            continue;
		yellow_ray_available = true;
		yellow_ray_source = source.to_string();
		yellow_ray_image_name = "__item " + source.to_string();
    }
    
	if (familiar_is_usable($familiar[nanorhino]) && __misc_state["have moxie class combat skill"] && get_property_int("_nanorhinoCharge") == 100)
	{
		yellow_ray_available = true;
		yellow_ray_source = "Nanorhino";
		yellow_ray_image_name = "nanorhino";
		
	}
	if (familiar_is_usable($familiar[he-boulder]))
	{
		yellow_ray_available = true;
		yellow_ray_source = "He-Boulder";
		yellow_ray_image_name = "he-boulder";
	}
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && lookupSkill("Flash Headlight").have_skill() && get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb")
    {
		yellow_ray_available = true;
		yellow_ray_source = "Flash Headlight";
		yellow_ray_image_name = "__skill Easy Riding";
    }
	
	if (yellow_ray_available)
		yellow_ray_potentially_available = true;
	
	if (my_path_id() == PATH_KOLHS)
		yellow_ray_potentially_available = true;
		
	
	if ($effect[Everything looks yellow].have_effect() > 0)
		yellow_ray_available = false;
	if (!yellow_ray_available)
		yellow_ray_source = "";
	__misc_state["yellow ray available"] = yellow_ray_available;
	__misc_state_string["yellow ray source"] = yellow_ray_source;
	__misc_state_string["yellow ray image name"] = yellow_ray_image_name;
	__misc_state["yellow ray potentially available"] = yellow_ray_potentially_available;
	
	boolean free_runs_usable = true;
	if (my_path_id() == PATH_BIG)
		free_runs_usable = false;
	__misc_state["free runs usable"] = free_runs_usable;
	
	boolean blank_outs_usable = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG)
		blank_outs_usable = false;
	if (!free_runs_usable)
		blank_outs_usable = false;
	__misc_state["blank outs usable"] = free_runs_usable;
	
	
	boolean free_runs_available = false;
	if (familiar_is_usable($familiar[pair of stomping boots]) || (have_skill($skill[the ode to booze]) && familiar_is_usable($familiar[Frumious Bandersnatch])))
		free_runs_available = true;
	if ($item[goto].available_amount() > 0 || $item[tattered scrap of paper].available_amount() > 0)
		free_runs_available = true;
	if ($item[greatest american pants].available_amount() > 0 || $item[navel ring of navel gazing].available_amount() > 0 || $item[peppermint parasol].available_amount() > 0)
		free_runs_available = true;
	if ($item[divine champagne popper].available_amount() > 0 || 2371.to_item().available_amount() > 0 || 7014.to_item().available_amount() > 0 || $item[handful of Smithereens].available_amount() > 0)
		free_runs_available = true;
	if ($item[V for Vivala mask].available_amount() > 0 && !get_property_boolean("_vmaskBanisherUsed"))
		free_runs_available = true;
	if (blank_outs_usable)
	{
		if ($item[bottle of Blank-Out].available_amount() > 0 || get_property_int("blankOutUsed") > 0)
			free_runs_available = true;
	}
	if (!free_runs_usable)
		free_runs_available = false;
	__misc_state["free runs available"] = free_runs_available;
	
	
	
	boolean some_olfact_available = false;
	if (have_skill($skill[Transcendent Olfaction]))
		some_olfact_available = true;
    if ($item[odor extractor].available_amount() > 0)
        some_olfact_available = true;
    if ($familiar[nosy nose].familiar_is_usable()) //weakened, but still relevantw
        some_olfact_available = true;
    if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
        some_olfact_available = true;
		
	__misc_state["have olfaction equivalent"] = some_olfact_available;
	
	
	boolean skills_temporarily_missing = false;
	boolean familiars_temporarily_blocked = false;
	boolean familiars_temporarily_missing = false;
	if (in_bad_moon())
	{
		skills_temporarily_missing = true;
		familiars_temporarily_missing = true;
	}
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
	{
		skills_temporarily_missing = true;
		familiars_temporarily_missing = true;
		familiars_temporarily_blocked = true;
	}
	if (my_path_id() == PATH_ZOMBIE_SLAYER)
	{
		skills_temporarily_missing = true;
	}
	if (my_path_id() == PATH_CLASS_ACT || my_path_id() == PATH_CLASS_ACT_2)
	{
		//not sure how mafia interprets "have_skill" under class act
		skills_temporarily_missing = true;
	}
	if (my_path_id() == PATH_TRENDY)
	{
		//not sure if this is correct
		//skills_temporarily_missing = true;
		//familiars_temporarily_missing = true;
	}
	__misc_state["skills temporarily missing"] = skills_temporarily_missing;
	__misc_state["familiars temporarily missing"] = familiars_temporarily_missing;
	__misc_state["familiars temporarily blocked"] = familiars_temporarily_blocked;
	
	
	__misc_state["AT skills available"] = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_ZOMBIE_SLAYER || ((my_path_id() == PATH_CLASS_ACT || my_path_id() == PATH_CLASS_ACT_2) && my_class() != $class[accordion thief]))
		__misc_state["AT skills available"] = false;
	
	
    __misc_state_float["Non-combat statgain multiplier"] = 1.0;
	__misc_state_float["ML to mainstat multiplier"] = 1.0 / (2.0  * 4.0);
	if (my_path_id() == PATH_CLASS_ACT_2)
	{
		__misc_state_float["ML to mainstat multiplier"] = 1.0 / (2.0 * 2.0);
        __misc_state_float["Non-combat statgain multiplier"] = 0.5;
		__misc_state["Stat gain from NCs reduced"] = true;
	}
	
	int pulls_available = 0;
	pulls_available = pulls_remaining();
	__misc_state_int["pulls available"] = pulls_available;
	
    //Calculate free rests available:
    int [skill] rests_granted_by_skills;
    rests_granted_by_skills[$skill[disco nap]] = 1;
    rests_granted_by_skills[$skill[adventurer of leisure]] = 2;
    rests_granted_by_skills[$skill[dog tired]] = 5;
    rests_granted_by_skills[$skill[executive narcolepsy]] = 1;
    rests_granted_by_skills[$skill[food coma]] = 10;
    
    int rests_used = get_property_int("timesRested");
    int total_rests_available = 0;
    if ($familiar[unconscious collective].have_familiar_replacement())
        total_rests_available += 3;
    
    foreach s in rests_granted_by_skills
    {
        if (s.have_skill())
            total_rests_available += rests_granted_by_skills[s];
    }
    
    __misc_state_int["total free rests possible"] = total_rests_available;
	__misc_state_int["free rests remaining"] = MAX(total_rests_available - rests_used, 0);
	
	//monster.monster_initiative() is usually what you need, but just in case:
	if (monster_level_adjustment() < 21)
		__misc_state_float["init ML penalty"] = 0.0;
	else if (monster_level_adjustment() < 41)
		__misc_state_float["init ML penalty"] = 0.0 + 1.0 * (monster_level_adjustment() - 20.0);
	else if (monster_level_adjustment() < 61)
		__misc_state_float["init ML penalty"] = 20.0 + 2.0 * (monster_level_adjustment() - 40.0);
	else if (monster_level_adjustment() < 81)
		__misc_state_float["init ML penalty"] = 60.0 + 3.0 * (monster_level_adjustment() - 60.0);
	else if (monster_level_adjustment() < 101)
		__misc_state_float["init ML penalty"] = 120.0 + 4.0 * (monster_level_adjustment() - 80.0);
	else
		__misc_state_float["init ML penalty"] = 200.0 + 5.0 * (monster_level_adjustment() - 100.0);
	
	
	//tower items:
	//telescope1 to telescope7
	item [string] telescope_to_item_map;
	telescope_to_item_map["an armchair"] = $item[pygmy pygment];
	telescope_to_item_map["a cowardly-looking man"] = $item[wussiness potion];
	telescope_to_item_map["a banana peel"] = $item[gremlin juice];
	telescope_to_item_map["a coiled viper"] = $item[adder bladder];
	telescope_to_item_map["a rose"] = $item[Angry Farmer candy];
	telescope_to_item_map["a glum teenager"] = $item[thin black candle];
	telescope_to_item_map["a hedgehog"] = $item[super-spiky hair gel];
	telescope_to_item_map["a raven"] = $item[Black No. 2];
	telescope_to_item_map["a smiling man smoking a pipe"] = $item[Mick's IcyVapoHotness Rub];
	telescope_to_item_map["catch a glimpse of a flaming katana"] = $item[Frigid ninja stars];
	telescope_to_item_map["catch a glimpse of a translucent wing"] = $item[Spider web];
	telescope_to_item_map["see a fancy-looking tophat"] = $item[Sonar-in-a-biscuit];
	telescope_to_item_map["see a flash of albumen"] = $item[Black pepper];
	telescope_to_item_map["see a giant white ear"] = $item[Pygmy blowgun];
	telescope_to_item_map["see a huge face made of Meat"] = $item[Meat vortex];
	telescope_to_item_map["see a large cowboy hat"] = $item[Chaos butterfly];
	telescope_to_item_map["see a periscope"] = $item[Photoprotoneutron torpedo];
	telescope_to_item_map["see a slimy eyestalk"] = $item[Fancy bath salts];
	telescope_to_item_map["see a strange shadow"] = $item[inkwell];
	telescope_to_item_map["see moonlight reflecting off of what appears to be ice"] = $item[Hair spray];
	telescope_to_item_map["see part of a tall wooden frame"] = $item[disease];
	telescope_to_item_map["see some amber waves of grain"] = $item[bronzed locust];
	telescope_to_item_map["see some long coattails"] = $item[Knob Goblin firecracker];
	telescope_to_item_map["see some pipes with steam shooting out of them"] = $item[powdered organs];
	telescope_to_item_map["see some sort of bronze figure holding a spatula"] = $item[leftovers of indeterminate origin];
	telescope_to_item_map["see the neck of a huge bass guitar"] = $item[mariachi G-string];
	telescope_to_item_map["see what appears to be the North Pole"] = $item[NG];
	telescope_to_item_map["see what looks like a writing desk"] = $item[plot hole];
	telescope_to_item_map["see the tip of a baseball bat"] = $item[baseball];
	telescope_to_item_map["see what seems to be a giant cuticle"] = $item[razor-sharp can lid];
	
	telescope_to_item_map["see a formidable stinger"] = $item[tropical orchid];
	telescope_to_item_map["see a wooden beam"] = $item[stick of dynamite];
	telescope_to_item_map["see a pair of horns"] = $item[barbed-wire fence];
	
	
	
	__misc_state_string["Gate item"] = telescope_to_item_map[get_property("telescope1")];
	__misc_state_string["Tower monster item 1"] = telescope_to_item_map[get_property("telescope2")];
	__misc_state_string["Tower monster item 2"] = telescope_to_item_map[get_property("telescope3")];
	__misc_state_string["Tower monster item 3"] = telescope_to_item_map[get_property("telescope4")];
	__misc_state_string["Tower monster item 4"] = telescope_to_item_map[get_property("telescope5")];
	__misc_state_string["Tower monster item 5"] = telescope_to_item_map[get_property("telescope6")];
	__misc_state_string["Tower monster item 6"] = telescope_to_item_map[get_property("telescope7")];
	
	if (my_path_id() == PATH_BEES_HATE_YOU)
	{
		__misc_state_string["Tower monster item 1"] = "tropical orchid";
		__misc_state_string["Tower monster item 2"] = "tropical orchid";
		__misc_state_string["Tower monster item 3"] = "tropical orchid";
		__misc_state_string["Tower monster item 4"] = "tropical orchid";
		__misc_state_string["Tower monster item 5"] = "tropical orchid";
		__misc_state_string["Tower monster item 6"] = "tropical orchid";
	}
	
	int ngs_needed = 0;
	if (__misc_state_string["Tower monster item 1"] == "NG")
		ngs_needed += 1;
	if (__misc_state_string["Tower monster item 2"] == "NG")
		ngs_needed += 1;
	if (__misc_state_string["Tower monster item 3"] == "NG")
		ngs_needed += 1;
	if (__misc_state_string["Tower monster item 4"] == "NG")
		ngs_needed += 1;
	if (__misc_state_string["Tower monster item 5"] == "NG")
		ngs_needed += 1;
	if (__misc_state_string["Tower monster item 6"] == "NG")
		ngs_needed += 1;
	
	
	
	//wand
	
	boolean wand_of_nagamar_needed = true;
	if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_BUGBEAR_INVASION || my_path_id() == PATH_ZOMBIE_SLAYER || my_path_id() == PATH_KOLHS)
		wand_of_nagamar_needed = false;
		
	int ruby_w_needed = 1;
	int metallic_a_needed = 1;
	int lowercase_n_needed = 1;
	int heavy_d_needed = 1;
	int [string] letters_needed;
	letters_needed["w"] = 1;
	letters_needed["a"] = 1;
	letters_needed["n"] = 1;
	letters_needed["d"] = 1;
	letters_needed["g"] = 0;
	
	int [string] letters_available;
	letters_available["w"] = $item[ruby w].available_amount() + $item[wa].available_amount();
	letters_available["a"] = $item[metallic a].available_amount() + $item[wa].available_amount();
	letters_available["n"] = $item[lowercase n].available_amount() + $item[nd].available_amount() + $item[ng].available_amount();
	letters_available["d"] = $item[heavy d].available_amount() + $item[nd].available_amount();
	letters_needed["n"] += ngs_needed;
	letters_needed["g"] += ngs_needed;
	
	if ($item[wand of nagamar].available_amount() > 0)
		wand_of_nagamar_needed = false;
		
		
		
	if (!wand_of_nagamar_needed)
	{
		letters_needed["w"] -= 1;
		letters_needed["a"] -= 1;
		letters_needed["n"] -= 1;
		letters_needed["d"] -= 1;
	}
	
	letters_needed["w"] = MAX(0, letters_needed["w"] - letters_available["w"]);
	letters_needed["a"] = MAX(0, letters_needed["a"] - letters_available["a"]);
	letters_needed["n"] = MAX(0, letters_needed["n"] - letters_available["n"]);
	letters_needed["d"] = MAX(0, letters_needed["d"] - letters_available["d"]);
		
	__misc_state["wand of nagamar needed"] = wand_of_nagamar_needed;
	__misc_state_int["ruby w needed"] = letters_needed["w"];
	__misc_state_int["metallic a needed"] = letters_needed["a"];
	__misc_state_int["lowercase n needed"] = letters_needed["n"];
	__misc_state_int["lowercase n available"] = letters_available["n"];
	__misc_state_int["heavy d needed"] = letters_needed["d"];
	__misc_state_int["original g needed"] = letters_needed["g"];
	
	
	int dd_tokens_and_keys_available = 0;
	int tokens_needed = 3;
	tokens_needed -= $item[fishbowl].available_amount();
	tokens_needed -= $item[fishtank].available_amount();
	tokens_needed -= $item[fish hose].available_amount();
	
	tokens_needed -= 2 * $item[hosed fishbowl].available_amount();
	tokens_needed -= 2 * $item[hosed tank].available_amount();
	
	tokens_needed -= 3 * $item[makeshift scuba gear].available_amount();
	
	tokens_needed -= $item[fat loot token].available_amount();
	tokens_needed -= $item[boris's key].available_amount();
	tokens_needed -= $item[jarlsberg's key].available_amount();
	tokens_needed -= $item[sneaky pete's key].available_amount();
	
	dd_tokens_and_keys_available += $item[fat loot token].available_amount();
	dd_tokens_and_keys_available += $item[boris's key].available_amount();
	dd_tokens_and_keys_available += $item[jarlsberg's key].available_amount();
	dd_tokens_and_keys_available += $item[sneaky pete's key].available_amount();
	
	__misc_state_int["fat loot tokens needed"] = MAX(0, tokens_needed);
	
	__misc_state_int["DD Tokens and keys available"] = dd_tokens_and_keys_available;
	
	boolean mysterious_island_unlocked = false;
	if ($items[dingy dinghy, skeletal skiff, junk junk].available_amount() > 0)
		mysterious_island_unlocked = true;
    
    if (get_property("peteMotorbikeGasTank") == "Extra-Buoyant Tank")
        mysterious_island_unlocked = true;
    if (get_property_int("lastIslandUnlock") == my_ascensions() && get_revision() >= 13812)
        mysterious_island_unlocked = true;
            
    if (!mysterious_island_unlocked)
    {
        if ($locations[frat house, hippy camp, the obligatory pirate's cove, frat house in disguise, the frat house (bombed back to the stone age), hippy camp in disguise, barrrney's barrr, the f'c'le, the poop deck, belowdecks, post-war junkyard, mcmillicancuddy's farm].turnsAttemptedInLocation() > 0) //backup
            mysterious_island_unlocked = true;
    }
    
        
    __misc_state["mysterious island available"] = mysterious_island_unlocked;
    
    
    
	
	__misc_state["desert beach available"] = false;
    if (get_property("peteMotorbikeGasTank") == "Large Capacity Tank")
        __misc_state["desert beach available"] = true;
    if (get_property_int("lastDesertUnlock") == my_ascensions() && get_revision() >= 13812)
        __misc_state["desert beach available"] = true;
	if ($location[south of the border].locationAvailable())
		__misc_state["desert beach available"] = true;
	if ($locations[The Shore\, Inc. Travel Agency,the arid\, extra-dry desert,the oasis, south of the border].turnsAttemptedInLocation() > 0) //weird issues with detecting the beach. check if we've ever adventured there as a back-up
		__misc_state["desert beach available"] = true;
	
	string ballroom_song = "";
	if (get_property("lastQuartetAscension") == my_ascensions())
	{
		//1 and 3 are a guess
		if (get_property("lastQuartetRequest") == "1")
		{
			ballroom_song = "+ML";
		}
		else if (get_property("lastQuartetRequest") == "2")
		{
			ballroom_song = "-combat";
		}
		else if (get_property("lastQuartetRequest") == "3")
		{
			ballroom_song = "+item";
		}
	}
	__misc_state_string["ballroom song"] = ballroom_song;
	
	__misc_state["Torso aware"] = false;
    if ($skill[Torso Awaregness].have_skill() || lookupSkill("Best Dressed").have_skill())
        __misc_state["Torso aware"] = true;
	
	int hipster_fights_used = get_property_int("_hipsterAdv");
	if (hipster_fights_used < 0) hipster_fights_used = 0;
	if (hipster_fights_used > 7) hipster_fights_used = 7;
	
	if (familiar_is_usable($familiar[Mini-Hipster]) && !(familiar_is_usable($familiar[artistic goth kid]) && hippy_stone_broken())) //use goth kid over hipster when PVPing
	{
		__misc_state_string["hipster name"] = "hipster";
		__misc_state_int["hipster fights available"] = 7 - hipster_fights_used;
		__misc_state["have hipster"] = true;
	}
	else if (familiar_is_usable($familiar[artistic goth kid]))
	{
		__misc_state_string["hipster name"] = "goth kid";
		__misc_state_int["hipster fights available"] = 7 - hipster_fights_used;
		__misc_state["have hipster"] = true;
	}
	__misc_state_string["obtuse angel name"] = "";
	if (familiar_is_usable($familiar[reanimated reanimator]))
		__misc_state_string["obtuse angel name"] = "Reanimated Reanimator";
	else if (familiar_is_usable($familiar[obtuse angel]))
		__misc_state_string["obtuse angel name"] = "Obtuse Angel";
	
	if (get_property_int("lastPlusSignUnlock") == my_ascensions())
		__misc_state["dungeons of doom unlocked"] = true;
	else
		__misc_state["dungeons of doom unlocked"] = false;
	
	__misc_state["can use clovers"] = true;
	if (in_bad_moon() && $items[ten-leaf clover, disassembled clover].available_amount() == 0)
		__misc_state["can use clovers"] = false;
		
		
	__misc_state["bookshelf accessible"] = true;
	if (my_path_id() == PATH_ZOMBIE_SLAYER || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
		__misc_state["bookshelf accessible"] = false;
        
    
	__misc_state["can pickpocket"] = false;
    if (my_class() == $class[disco bandit] || my_class() == $class[accordion thief] || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || $item[tiny black hole].equipped_amount() > 0 || $effect[Form of...Bird!].have_effect() > 0)
        __misc_state["can pickpocket"] = true;
        
        
        //Moxie Experience Percent
    float dance_card_average_stat_gain = MIN(2.25 * my_basestat($stat[moxie]), 300.0) * __misc_state_float["Non-combat statgain multiplier"] * (1.0 + numeric_modifier("Moxie Experience Percent") / 100.0);
    __misc_state_float["dance card average stats"] = dance_card_average_stat_gain;
}


void setUpQuestStateViaMafia()
{
	//Mafia's internal quest tracking system will sometimes need a quest log load to update.
	//It seems to work like this:
	//"unstarted" - quest not started
	//"started" - quest started, no progress (by log) we can see
	//"step1" - quest started, first log step completed
	//"stepX" - quest started, X steps completed
	//"finished" - quest ended
	
	QuestsInit();
	SetsInit();
	
	//Opening guild quest
	if (true)
	{
		//???
		QuestState state;
		state.startable = true;
	}
}


void finalizeSetUpState()
{
	//done after quest parsing
	
	if (__misc_state["Example mode"] || my_level() < 13 && !__misc_state["In aftercore"])
	{
		__misc_state["need to level"] = true;
	}
    __misc_state["need to level muscle"] = false;
    __misc_state["need to level mysticality"] = false;
    __misc_state["need to level moxie"] = false;
    
    if (__misc_state["In run"])
    {
        //62 muscle for antique machete/hidden hospital
        //70 moxie, 70 mysticality for war outfits
        if (my_primestat() == $stat[muscle] && __misc_state["need to level"])
            __misc_state["need to level muscle"] = true;
        if (my_primestat() == $stat[mysticality] && __misc_state["need to level"])
            __misc_state["need to level mysticality"] = true;
        if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
            __misc_state["need to level moxie"] = true;
        
        if (my_basestat($stat[muscle]) < 62)
            __misc_state["need to level muscle"] = true;
        if (my_basestat($stat[mysticality]) < 70)
            __misc_state["need to level mysticality"] = true;
        if (my_basestat($stat[moxie]) < 70)
            __misc_state["need to level moxie"] = true;
    }
	
	if (__misc_state_int["pulls available"] > 0)
	{
		PullsInit();
	}
	
	finalizeSetUpFloristState();
}

void setUpQuestState()
{
    if (__misc_state["In valhalla"])
        return;
	setUpQuestStateViaMafia();
}




void generateMissingItems(Checklist [int] checklists)
{
	ChecklistEntry [int] items_needed_entries;
	
	if (!__misc_state["In run"])
		return;
	
	
	if (__misc_state["wand of nagamar needed"])
	{
		ChecklistSubentry [int] subentries;
		
		subentries[subentries.count()] = ChecklistSubentryMake("Wand of Nagamar", "", "");
		
		if (__misc_state_int["ruby w needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("ruby W", "Clover or +234% item", listMake("Clover the castle basement", "W Imp - Dark Neck of the Woods/Pandamonium Slums - 30% drop"));
		if (__misc_state_int["metallic a needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("metallic A", "Clover or +234% item", listMake("Clover the castle basement", "MagiMechTech MechaMech - Penultimate Fantasy Airship - 30% drop"));
		if (__misc_state_int["lowercase n needed"] > 0 && __misc_state_int["lowercase n available"] == 0)
		{
			string name = "lowercase N";
			subentries[subentries.count()] = ChecklistSubentryMake(name, "Clover or +234% item", listMake("Clover the castle basement", "XXX pr0n - Valley of Rof L'm Fao - 30% drop"));
		}
		if (__misc_state_int["heavy d needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("heavy D", "Clover or +150% item", listMake("Clover the castle basement", "Alphabet Giant - Castle Basement - 40% drop"));
			
		ChecklistEntry entry = ChecklistEntryMake("__item wand of nagamar", "", subentries);
		entry.should_indent_after_first_subentry = true;
		
		items_needed_entries.listAppend(entry);
	}
	
	if (!__quest_state["Level 13"].state_boolean["past keys"])
	{
		//Key items:
		if (!__quest_state["Level 13"].state_boolean["have relevant guitar"])
		{
			string [int] guitar_options;
			guitar_options.listAppend("For gate mariachis");
			if (__misc_state_int["pulls available"] > 0)
				guitar_options.listAppend("Pull");
			guitar_options.listAppend("Acoustic guitar - 20% drop, grungy pirate, belowdecks (4 monster location, yellow ray?)");
			guitar_options.listAppend("Stone banjo - one clover");
			guitar_options.listAppend("Massive sitar - hippy war store");
			if (my_class() == $class[Turtle tamer])
				guitar_options.listAppend("Dueling banjo - tame a turtle at whitey's grove");
			if (my_primestat() == $stat[muscle])
				guitar_options.listAppend("4-dimensional guitar - 5% drop, cubist bull, haunted gallery (yellow ray?)");
				
			items_needed_entries.listAppend(ChecklistEntryMake("__item Acoustic guitarrr", "", ChecklistSubentryMake("Guitar", "", guitar_options)));
		}
		
		if (!__quest_state["Level 13"].state_boolean["have relevant accordion"])
		{
			items_needed_entries.listAppend(ChecklistEntryMake("__item stolen accordion", "", ChecklistSubentryMake("Accordion", "", "Toy accordion, 150 meat")));
		}
		
		if (!__quest_state["Level 13"].state_boolean["have relevant drum"])
		{
			string [int] suggestions;
			suggestions.listAppend("Black kettle drum (black forest NC)");
			if ($item[broken skull].available_amount() > 0)
				suggestions.listAppend("Bone rattle (skeleton bone + broken skull)");
			suggestions.listAppend("Jungle drum (pygmy assault squad, hidden park, 10% drop)");
			suggestions.listAppend("Hippy bongo (YR hippy)");
			suggestions.listAppend("tambourine?");
			items_needed_entries.listAppend(ChecklistEntryMake("__item hippy bongo", "", ChecklistSubentryMake("Drum", "", suggestions)));
		}
		
		if ($item[skeleton key].available_amount() == 0)
		{
			string line = "loose teeth";
			if ($item[loose teeth].available_amount() == 0)
				line += " (need)";
			else
				line += " (have)";
			line += " + skeleton bone";
			if ($item[skeleton bone].available_amount() == 0)
				line += " (need)";
			else
				line += " (have)";
			items_needed_entries.listAppend(ChecklistEntryMake("__item skeleton key", "", ChecklistSubentryMake("Skeleton key", "", line)));
		}
		
		if ($item[digital key].available_amount() == 0)
		{
			string [int] options;
            if ($item[digital key].creatable_amount() > 0)
            {
                options.listAppend("Have enough pixels, make it.");
            }
            else
            {
                options.listAppend("Fear man's level (jar)");
                if (__misc_state["fax accessible"] && in_hardcore()) //not suggesting this in SC
                    options.listAppend("Fax/copy a ghost");
                options.listAppend("8-bit realm (olfact blooper, slow)");
            }
			items_needed_entries.listAppend(ChecklistEntryMake("__item digital key", "", ChecklistSubentryMake("Digital key", "", options)));
		}
		string from_daily_dungeon_string = "From daily dungeon";
		if ($item[fat loot token].available_amount() > 0)
			from_daily_dungeon_string += "|" + pluralize($item[fat loot token]) + " available";
		if ($item[sneaky pete's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0)
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Sneaky Pete's key", "da.php", ChecklistSubentryMake("Sneaky Pete's key", "", options)));
		}
		if ($item[jarlsberg's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0)
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item jarlsberg's key", "da.php", ChecklistSubentryMake("Jarlsberg's key", "", options)));
		}
		if ($item[Boris's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0)
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Boris's key", "da.php", ChecklistSubentryMake("Boris's key", "", options)));
		}
	}
	
	//Tower items:
	if (!__quest_state["Level 13"].state_boolean["past tower"])
	{
		string [item] telescope_item_suggestions;
		
		//FIXME support __misc_state["can use clovers"] for these
		telescope_item_suggestions[$item[mick's icyvapohotness rub]] = "Raver giant, top floor of castle, 30% drop";
		telescope_item_suggestions[$item[leftovers of indeterminate origin]] = "Demonic icebox, haunted kitchen (5 monster location), 40% drop|Or clover haunted kitchen";
		telescope_item_suggestions[$item[NG]] = "Clover castle basement";
		telescope_item_suggestions[$item[adder bladder]] = "Black adder, black forest, 30% drop";
		telescope_item_suggestions[$item[plot hole]] = "Possibility giant, castle ground floor, 20% drop";
		telescope_item_suggestions[$item[chaos butterfly]] = "Possibility giant, castle ground floor, 20% drop";
		telescope_item_suggestions[$item[pygmy pygment]] = "Pygmy assault squad, hidden park, 25% drop";
		telescope_item_suggestions[$item[baseball]] = "Baseball bat, guano junction, 30% drop, 6 monsters (i.e. a lot)|Clover guano junction if you have any sonars-in-a-biscuit";
		telescope_item_suggestions[$item[frigid ninja stars]] = "Any ninja, Lair of the Ninja Snowmen, 20% drop";
		telescope_item_suggestions[$item[hair spray]] = "General store";
		
		telescope_item_suggestions[$item[spider web]] = "Spiders, sleazy back alley, 25% drop (2x)";
		
		
		telescope_item_suggestions[$item[black pepper]] = "Black picnic basket, black widow, black forest, 15% drop.|46%? open success rate.|Possibly clover black forest for one basket.|Possibly zap ancient spice/dehydrated caviar for it.";
		telescope_item_suggestions[$item[powdered organs]] = "Canopic jar, Tomb servant, Upper/Middle chamber, 30% drop.|~50% open success rate.";
		
		telescope_item_suggestions[$item[photoprotoneutron torpedo]] = "MagiMechTech MechaMech, fantasy airship, 30% drop";
		
		telescope_item_suggestions[$item[wussiness potion]] = "W imp, Dark Neck of the Woods/Pandamonium slums, 30% drop";
		
		telescope_item_suggestions[$item[gremlin juice]] = "Any gremlin, Junkyard, 3% drop (yellow ray)";
		telescope_item_suggestions[$item[Angry Farmer candy]] = "Need sugar rush";
		
		if (have_skill($skill[summon crimbo candy]))
			telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Summon crimbo candy";
		else if (have_skill($skill[candyblast]))
			telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Cast candyblast";
		else
			telescope_item_suggestions[$item[Angry Farmer candy]] += "|*Raver giant, castle top floor, 30% drop"; //FIXME we need sugar rush, not angry farmer candy.
		telescope_item_suggestions[$item[thin black candle]] = "Goth Giant, Castle Top Floor, 30% drop|Non-combat on top floor. (slow)";
		telescope_item_suggestions[$item[super-spiky hair gel]] = "Protagonist, Penultimate Fantasy Airship, 20% drop";
		telescope_item_suggestions[$item[Black No. 2]] = "Black panther, black forest, 20% drop";
		telescope_item_suggestions[$item[Sonar-in-a-biscuit]] = "Bats, Batrat and Ratbat Burrow, 15% drop|Clover Guano Junction";
		telescope_item_suggestions[$item[Pygmy blowgun]] = "Pygmy blowgunner, hidden park, 30% drop";
		telescope_item_suggestions[$item[Meat vortex]] = "Me4t begZ0r, The Valley of Rof L'm Fao (7 monster location), 100% drop";
		telescope_item_suggestions[$item[Fancy bath salts]] = "Claw-foot bathtub, haunted bathroom, 35% drop";
		telescope_item_suggestions[$item[inkwell]] = "Writing desk, haunted library, 30% drop";
		telescope_item_suggestions[$item[disease]] = "Knob Goblin Harem Girl, Harem, 10% drop (YR)";
		if (locationAvailable($location[the "fun" house]))
			telescope_item_suggestions[$item[disease]] += "|Disease-in-the-box, fun house (6 monsters), 40% drop";
		telescope_item_suggestions[$item[bronzed locust]] = "Plaque of locusts, extra-dry desert, 20% drop";
		telescope_item_suggestions[$item[Knob Goblin firecracker]] = "Sub-Assistant Knob Mad Scientist, Outskirts of Cobb's Knob, 100% drop";
		telescope_item_suggestions[$item[mariachi G-string]] = "Irate mariachi, South of The Border, 30% drop (5 monster location, run +combat)";
		telescope_item_suggestions[$item[razor-sharp can lid]] = "Can of asparagus/can of tomatoes, Haunted Pantry, 40%/45% drop|NC in haunted pantry";
		
		
		
		telescope_item_suggestions[$item[tropical orchid]] = "Tropical island souvenir crate (vacation)";
		telescope_item_suggestions[$item[stick of dynamite]] = "Dude ranch souvenir crate (vacation)";
		telescope_item_suggestions[$item[barbed-wire fence]] = "Ski resort souvenir crate (vacation)";
		
		if (familiar_is_usable($familiar[gelatinous cubeling]))
		{
			foreach it in $items[knob goblin firecracker,razor-sharp can lid,spider web]
			{
				if (it == $item[none])
					continue;
				telescope_item_suggestions[it] += "|Or potentially bring along the gelatinous cubeling.";
			}
		}
		
		QuestState ns13_quest = __quest_state["Level 13"];
		
		string [int] state_strings;
		string [int] state_ns13_lookup_booleans;
		if (!ns13_quest.state_boolean["past gates"])
			state_strings.listAppend("Gate item");
		state_ns13_lookup_booleans.listAppend("Past gate");
        if (!__quest_state["Level 13"].state_boolean["past tower"])
        {
            for i from 1 to 6
            {
                state_strings.listAppend("Tower monster item " + i);
                state_ns13_lookup_booleans.listAppend("Past tower monster " + i);
            }
        }
		
		item [item][int] item_equivalents_lookup;
		item_equivalents_lookup[$item[angry farmer candy]] = listMakeBlankItem();
        foreach it in $items[that gum you like,Crimbo fudge,Crimbo peppermint bark,Crimbo candied pecan,cold hots candy,Daffy Taffy,Senior Mints,Wint-O-Fresh mint]
            item_equivalents_lookup[$item[angry farmer candy]].listAppend(it);
		
		int [item] towergate_items_needed_count; //bees hate you has duplicates
		foreach i in state_strings
		{
			if (ns13_quest.state_boolean[state_ns13_lookup_booleans[i]])
				continue;
			
			item it = __misc_state_string[state_strings[i]].to_item();
			
			if (it == $item[none])
			{
				string subentry_string = "Or towerkill";
				if (state_strings[i] == "Gate item")
					subentry_string = "";
				//unknown
                //FIXME mention looking into your telescope on the first entry
				items_needed_entries.listAppend(ChecklistEntryMake("Unknown", "", ChecklistSubentryMake("Unknown " + to_lower_case(state_strings[i]), "", subentry_string)));
			}
			else
			{
				int total_available_amount = it.available_amount() + closet_amount(it) - towergate_items_needed_count[it];
				
				if (item_equivalents_lookup[it].count() > 0)
				{
					foreach key in item_equivalents_lookup[it]
					{
						item it2 = item_equivalents_lookup[it][key];
						total_available_amount += it2.available_amount() + closet_amount(it2);
					}
				}
				if (total_available_amount <= 0)
				{
					string [int] details;
					if (state_strings[i] == "Gate item")
						details.listAppend("Gate item");
					else
						details.listAppend("Tower item - towerkill?");
					if (telescope_item_suggestions contains it)
						details.listAppend(telescope_item_suggestions[it]);
					items_needed_entries.listAppend(ChecklistEntryMake(it, "", ChecklistSubentryMake(it, "", details)));
				}
				
			}
			towergate_items_needed_count[it] = towergate_items_needed_count[it] + 1;
		}
	}
    
    if (true)
    {
        FloatHandle missing_weight;
        string [int] familiar_weight_how;
        string [int] familiar_weight_immediately_obtainable;
        string [int] familiar_weight_missing_potentials;
        boolean have_familiar_weight_for_tower = generateTowerFamiliarWeightMethod(familiar_weight_how, familiar_weight_immediately_obtainable, familiar_weight_missing_potentials,missing_weight);
        if (!have_familiar_weight_for_tower)
        {
            string [int] description;
            description.listAppend("For the sorceress's tower familiars.");
            if (familiar_weight_how.count() > 0)
                description.listAppend("Have " + familiar_weight_how.listJoinComponents(", ", "and") + ".");
            if (familiar_weight_immediately_obtainable.count() > 0)
                description.listAppend("Could use " + familiar_weight_immediately_obtainable.listJoinComponents(", ", "and") + ".");
            if (familiar_weight_missing_potentials.count() > 0)
                description.listAppend("Could acquire " + familiar_weight_missing_potentials.listJoinComponents(", ", "or") + ".");
            
            items_needed_entries.listAppend(ChecklistEntryMake("__familiar Sabre-Toothed Lime", "", ChecklistSubentryMake("+" + missing_weight.f.ceil() + " familiar weight buffs", "", description)));
        }
    }
	
	if ($item[lord spookyraven's spectacles].available_amount() == 0)
		items_needed_entries.listAppend(ChecklistEntryMake("__item lord spookyraven's spectacles", "", ChecklistSubentryMake("lord spookyraven's spectacles", "", "Found in Haunted Bedroom")));
    
    if ($item[enchanted bean].available_amount() == 0 && !__quest_state["Level 10"].state_boolean["Beanstalk grown"])
    {
		items_needed_entries.listAppend(ChecklistEntryMake("__item enchanted bean", "", ChecklistSubentryMake("Enchanted bean", "", "Found in the beanbat chamber.")));
    }
    
    if (__quest_state["Level 13"].state_boolean["shadow will need to be defeated"])
    {
        //Let's see
        //5 gauze garters + filthy poultices
        //Or...
        //red pixel potion (not worth farming, but if they have it...)
        //red potion
        //extra-strength red potion (they might find it)
        
    }
    if (__quest_state["Level 11 Palindome"].state_boolean["Need instant camera"])
    {
        item camera = 7266.to_item();
        if (camera != $item[none])
        {
            string url = "";
            if ($location[the haunted bedroom].locationAvailable())
                url = "place.php?whichplace=spookyraven2";
            items_needed_entries.listAppend(ChecklistEntryMake("__item " + camera, "", ChecklistSubentryMake("Disposable instant camera", url, "Found in the Haunted Bedroom.")));
        }
    }
                               
    SetsGenerateMissingItems(items_needed_entries);
	
	checklists.listAppend(ChecklistMake("Required Items", items_needed_entries));
}









void generateTasks(Checklist [int] checklists)
{
	ChecklistEntry [int] task_entries;
	
	ChecklistEntry [int] optional_task_entries;
		
	ChecklistEntry [int] future_task_entries;
	
	
	//Friar:
	if (florist_available())
	{
		ChecklistSubentry subentry;
		subentry.header = "Plant florist plants in " + __last_adventure_location;
		
		string [int] examining_plants;
		
		foreach key in __plants_suggested_locations
		{
			PlantSuggestion suggestion = __plants_suggested_locations[key];
			
			if (suggestion.loc != __last_adventure_location)
				continue;
				
			string plant_name = suggestion.plant_name.capitalizeFirstLetter();
			Plant plant = __plant_properties[plant_name];
			
			string line = plant_name + " (" + plant.zone_effect + ", " + plant.terrain;
			if (plant.territorial)
				line = line + ", territorial";
			
			line += ")";
			if (suggestion.details != "")
				line += "|*" + suggestion.details;
			subentry.entries.listAppend(line);
		}
		if (subentry.entries.count() > 0)
			task_entries.listAppend(ChecklistEntryMake("sunflower face", "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry, -11));
	}
	
	QuestsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	
	if (!__misc_state["desert beach available"])
	{
        string url;
		ChecklistSubentry subentry;
		subentry.header = "Unlock desert beach";
		if (!knoll_available())
		{
			string meatcar_line = "Build a bitchin' meatcar.";
			if (creatable_amount($item[bitchin' meatcar]) > 0)
				meatcar_line += "|*You have all the parts, build it!";
			else
			{
				item [int] missing_parts_list = missingComponentsToMakeItem($item[bitchin' meatcar]);
				
				meatcar_line += "|*Parts needed: " + missing_parts_list.listJoinComponents(", ", "and");
			}
			subentry.entries.listAppend(meatcar_line);
			
			subentry.entries.listAppend("Or buy a desert bus pass. (5000 meat)");
			if ($item[pumpkin].available_amount() > 0)
				subentry.entries.listAppend("Or build a pumpkin carriage.");
            if ($items[can of Br&uuml;talbr&auml;u,can of Drooling Monk,can of Impetuous Scofflaw,fancy tin beer can].available_amount() > 0)
				subentry.entries.listAppend("Or build a tin lizzie.");
            url = "place.php?whichplace=knoll_hostile";
		}
		else
		{
            url = "store.php?whichstore=4";
			int meatcar_price = $item[spring].npc_price() + $item[sprocket].npc_price() + $item[cog].npc_price() + $item[empty meat tank].npc_price() + 100 + $item[tires].npc_price() + $item[sweet rims].npc_price() + $item[spring].npc_price();
			subentry.entries.listAppend("Build a bitchin' meatcar. (" + meatcar_price + " meat)");
		}
		
		task_entries.listAppend(ChecklistEntryMake("__item bitchin' meatcar", url, subentry));
	}
	else if (!__misc_state["mysterious island available"])
	{
		ChecklistSubentry subentry;
		subentry.header = "Unlock mysterious island";
		
		int scrip_number = $item[Shore Inc. Ship Trip Scrip].available_amount();
		int trips_needed = MAX(0, 3 - scrip_number);
        
        string url = "place.php?whichplace=desertbeach";
        
		if ($item[dinghy plans].available_amount() > 0)
        {
            if ($item[dingy planks].available_amount() > 0)
            {
                url = "inventory.php?which=3";
                subentry.entries.listAppend("Use dinghy plans.");
            }
            else
            {
                url = "store.php?whichstore=m";
                subentry.entries.listAppend("Buy dingy planks, then build dinghy dinghy.");
            }
                
        }
		else if (trips_needed > 0)
		{
			string line_string = "Shore, " + (3 * trips_needed) + " adventures";
			int meat_needed = trips_needed * 500;
			if (my_meat() < meat_needed)
				line_string += "|Need " + meat_needed + " meat for vacations, have " + my_meat() + "."; //FIXME what about way of the surprising fist?
			subentry.entries.listAppend(line_string);
            if ($item[skeleton].available_amount() > 0)
                subentry.entries.listAppend("Skeletal skiff?");
		}
		else
		{
			subentry.entries.listAppend("Redeem scrip at shore for dinghy plans.");
		}
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeGasTank").length() == 0)
            subentry.entries.listAppend("Possibly upgrade your motorcycle's gas tank. (extra-buoyant)");
		task_entries.listAppend(ChecklistEntryMake("__item dingy dinghy", url, subentry, $locations[the shore\, inc. travel agency]));
	}



	
	
	
	if (my_path_id() == PATH_BUGBEAR_INVASION)
	{
		
		task_entries.listAppend(ChecklistEntryMake("bugbear", "", ChecklistSubentryMake("Bugbears!", "", "I have no idea")));
	}
	
	
	if (__misc_state["need to level"])
	{
		ChecklistSubentry subentry;
		
		int main_substats = my_basestat(my_primesubstat());
		int substats_remaining = substatsForLevel(my_level() + 1) - main_substats;
		
		subentry.header = "Level to " + (my_level() + 1);
		
		subentry.entries.listAppend("Gain " + substats_remaining + " substats.");
		
		
		task_entries.listAppend(ChecklistEntryMake("player character", "", subentry, 11));
	}
	
	
	
		
	

	

	if (__misc_state["yellow ray available"] && __misc_state["In run"])
	{
		string [int] potential_targets;
		
		if (!have_outfit_components("Filthy Hippy Disguise"))
			potential_targets.listAppend("Mysterious Island Hippy for outfit. (allows hippy store access; free redorant for +combat)");
		if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues"))
			potential_targets.listAppend("Hippy/frat war outfit?");
		//fax targets?
		if (__misc_state["fax available"])
		{
			potential_targets.listAppend("Anything on the fax list.");
		}
		
		if (!__quest_state["Level 10"].finished && $item[mohawk wig].available_amount() == 0)
			potential_targets.listAppend("Burly Sidekick (Mohawk wig) - speed up top floor of castle.");
		if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
			potential_targets.listAppend("Filthworms.");
		
		if (needTowerMonsterItem("disease"))
		{
			if (__quest_state["Level 5"].finished)
				potential_targets.listAppend("Knob goblin harem girl. (disease for tower, unless tower killing)");
			else
				potential_targets.listAppend("Knob goblin harem girl. (outfit for quest, disease for tower, unless tower killing)");
		}
		if (__quest_state["Boss Bat"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() <3)
		{
			if ($item[enchanted bean].available_amount() == 0 && !__misc_state["beanstalk grown"])
				potential_targets.listAppend("Beanbat. (enchanted bean, sonar-in-a-biscuit)");
			else
				potential_targets.listAppend("A bat. (sonar-in-a-biscuit)");
		}
		
		if (!__quest_state["Level 13"].state_boolean["have relevant guitar"] && !__quest_state["Level 13"].state_boolean["past keys"])
			potential_targets.listAppend("Grungy pirate. (guitar)");
		if (!__quest_state["Level 13"].state_boolean["past tower"])
			potential_targets.listAppend("Tower items? Gate items?");
		
		if (item_drop_modifier() < 234.0 && !__misc_state["In aftercore"])
			potential_targets.listAppend("Anything with 30% drop if you can't 234%. (dwarf foreman, bob racecar, drum machines, etc)");
		
		optional_task_entries.listAppend(ChecklistEntryMake(__misc_state_string["yellow ray image name"], "", ChecklistSubentryMake("Fire yellow ray", "", potential_targets), 5));
	}
    if (__misc_state["In run"] && !have_mushroom_plot() && knoll_available() && __misc_state["can eat just about anything"] && fullness_limit() >= 4 && $item[spooky mushroom].available_amount() == 0 && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST && my_meat() >= 5000)
    {
        string [int] description;
        description.listAppend("For spooky mushrooms, to cook a grue egg omelette. (epic food)|Will " + ((my_meat() < 5000) ? "need" : "cost") + " 5k meat.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item spooky mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Possibly plant a mushroom plot", "", description), 5));
    
    }
	
	if (__misc_state["need to level"])
	{
        string url = "";
		int mcd_max_limit = 10;
		boolean have_mcd = false;
		if (canadia_available() || knoll_available() || gnomads_available() && __misc_state["desert beach available"] || in_bad_moon())
			have_mcd = true;
        if (canadia_available())
            mcd_max_limit = 11;
        if (knoll_available())
        {
            if ($item[detuned radio].available_amount() > 0)
                url = "inventory.php?which=3";
            else
                url = "store.php?whichstore=4";
        }
        //FIXME URLs for the other ones
		if (current_mcd() < mcd_max_limit && have_mcd && monster_level_adjustment() < 50)
		{
			optional_task_entries.listAppend(ChecklistEntryMake("__item detuned radio", url, ChecklistSubentryMake("Set monster control device to " + mcd_max_limit, "", (mcd_max_limit * __misc_state_float["ML to mainstat multiplier"]) + " mainstats/turn")));
		}
	}
	
	if (!have_outfit_components("Filthy Hippy Disguise") && __misc_state["mysterious island available"] && __misc_state["In run"] && !__quest_state["Level 12"].finished)
	{
		item [int] missing_pieces = missing_outfit_components("Filthy Hippy Disguise");
        
		string [int] description;
		string [int] modifiers;
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
		description.listAppend("Yellow-ray a hippy if you can.");
		if (my_level() >= 9)
		{
			description.listAppend("Otherwise, run -combat.");
			modifiers.listAppend("-combat");
		}
		else
		{
			description.listAppend("Otherwise, wait for level 9.");
		}
		optional_task_entries.listAppend(ChecklistEntryMake("__item filthy knitted dread sack", "island.php", ChecklistSubentryMake("Acquire a filthy hippy disguise", modifiers, description), $locations[hippy camp]));
	}
    //FIXME better detection
	if (!have_outfit_components("Frat boy ensemble") && __misc_state["mysterious island available"] && __misc_state["In run"] && !__quest_state["Level 12"].finished && !__quest_state["Level 12"].started && ($location[frat house].combatTurnsAttemptedInLocation() > 0 || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Sing This Explosion to Me") || $location[frat house].noncombat_queue.contains_text("Murder by Death") || $location[frat house].noncombat_queue.contains_text("I Just Wanna Fly") || $location[frat house].noncombat_queue.contains_text("From Stoked to Smoked") || $location[frat house].noncombat_queue.contains_text("Purple Hazers")))
    {
        //they don't have a frat boy ensemble, but they adventured in the pre-war frat house
        //I'm assuming this means they want the outfit, for whatever reason. So, suggest it, until the level 12 starts:
		item [int] missing_pieces = missing_outfit_components("Frat boy ensemble");
        
		string [int] description;
		string [int] modifiers;
        modifiers.listAppend("-combat");
		description.listAppend("Missing " + missing_pieces.listJoinComponents(", ", "and") + ".");
			description.listAppend("Run -combat.");
		optional_task_entries.listAppend(ChecklistEntryMake("__item homoerotic frat-paddle", "island.php", ChecklistSubentryMake("Acquire a frat boy ensemble", modifiers, description), $locations[frat house]));
    }
		
	if ($item[strange leaflet].available_amount() > 0 && $item[giant pinky ring].available_amount() == 0) //very hacky way of testing if leaflet quest was done - in theory, they could smash the ring or pull one (or be casual)
	{
		optional_task_entries.listAppend(ChecklistEntryMake("__item strange leaflet", "", ChecklistSubentryMake("Strange leaflet quest", "", "Quests Menu" + __html_right_arrow_character + "Leaflet (With Stats)")));
	}
	

	SetsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	

    
    boolean have_spaghetti_breakfast = (($skill[spaghetti breakfast].have_skill() && !get_property_boolean("_spaghettiBreakfast")) || $item[spaghetti breakfast].available_amount() > 0);
    if (__misc_state["In run"] && __misc_state["can eat just about anything"] && !get_property_boolean("_spaghettiBreakfastEaten") && my_fullness() == 0 && have_spaghetti_breakfast)
    {
    
        string [int] adventure_gain;
        adventure_gain[1] = "1";
        adventure_gain[2] = "?1-2?";
        adventure_gain[3] = "2";
        adventure_gain[4] = "2-3";
        adventure_gain[5] = "3";
        adventure_gain[6] = "3-4";
        adventure_gain[7] = "4";
        adventure_gain[8] = "4-5";
        adventure_gain[9] = "5";
        adventure_gain[10] = "5-6";
        adventure_gain[11] = "6";
        
        string adventures_gained = adventure_gain[MAX(1, MIN(11, my_level()))];
        
        string level_string = "";
        if (my_level() < 11)
            level_string = " Gain levels for more.";
        string url = "inventory.php?which=1";
        string [int] description;
        description.listAppend("Inedible if you eat anything else.|" + adventures_gained + " adventures/fullness." + level_string);
        if ($item[spaghetti breakfast].available_amount() == 0)
        {
            description.listAppend("Obtained by casting spaghetti breakfast.");
            url = "skills.php";
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item spaghetti breakfast", url, ChecklistSubentryMake("Eat " + $item[spaghetti breakfast] + " first", "", description), 8));
    }
    
    if (__misc_state["In run"])
    {
        item dwelling = get_dwelling();
        item upgraded_dwelling = $item[none];
        if ($item[Frobozz Real-Estate Company Instant House (TM)].available_amount() > 0 && (dwelling == $item[big rock] || dwelling == $item[Newbiesport&trade; tent]))
        {
            upgraded_dwelling = $item[Frobozz Real-Estate Company Instant House (TM)];
        }
        else if ($item[Newbiesport&trade; tent].available_amount() > 0 && dwelling == $item[big rock])
        {
            upgraded_dwelling = $item[Newbiesport&trade; tent];
        }
        if (upgraded_dwelling != $item[none])
        {
            string [int] reasons;
            reasons.listAppend("rollover");
            
            if (__misc_state_int["total free rests possible"] > 0)
                reasons.listAppend("free rests");
            
            string description = "Better HP/MP restoration via " + reasons.listJoinComponents(", ", "and") + ".";
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + upgraded_dwelling, "inventory.php?which=3", ChecklistSubentryMake("Use " + upgraded_dwelling, "", description), 8));
            
        }
    }
    
    if (__misc_state["In run"] && $item[dry cleaning receipt].available_amount() > 0)
    {
        item receipt_item = $item[none];
        if (my_primestat() == $stat[muscle])
            receipt_item = $item[power sock];
        else if (my_primestat() == $stat[mysticality])
            receipt_item = $item[wool sock];
        else if (my_primestat() == $stat[moxie])
            receipt_item = $item[moustache sock];
        if (receipt_item != $item[none] && receipt_item.available_amount() == 0)
        {
            optional_task_entries.listAppend(ChecklistEntryMake("__item " + $item[dry cleaning receipt], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[dry cleaning receipt], "", "For " + receipt_item + " accessory."), 8));
        }
    }
    
	checklists.listAppend(ChecklistMake("Tasks", task_entries));
	checklists.listAppend(ChecklistMake("Optional Tasks", optional_task_entries));
	checklists.listAppend(ChecklistMake("Future Tasks", future_task_entries));
}







string [int] generateHotDogLine(string hotdog, string description, int fullness)
{
    description += " " + fullness + " full.";
    if (availableFullness() < fullness)
    {
        hotdog = HTMLGenerateSpanOfClass(hotdog , "r_future_option");
        description = HTMLGenerateSpanOfClass(description , "r_future_option");
    }
    return listMake(hotdog, description);
}


void generateDailyResources(Checklist [int] checklists)
{
	ChecklistEntry [int] available_resources_entries;
		
	SetsGenerateResources(available_resources_entries);
	
	if (!get_property_boolean("_fancyHotDogEaten") && availableFullness() > 0 && __misc_state["VIP available"] && __misc_state["can eat just about anything"] && __misc_state["In run"]) //too expensive to use outside a run? well, more that it's information overload
	{
		
		string name = "Fancy hot dog edible";
		string [int] description;
		string image_name = "basic hot dog";
		
        string [int][int] options;
		options.listAppend(generateHotDogLine("Optimal Dog", "Semi-rare next adventure.", 1));
		options.listAppend(generateHotDogLine("Ghost Dog", "-combat, 30 turns.", 3));
		options.listAppend(generateHotDogLine("Video Game Hot Dog", "+25% item, +25% meat, pixels, 50 turns.", 3));
		options.listAppend(generateHotDogLine("Junkyard dog", "+combat, 30 turns.", 3));
        if (!__quest_state["Level 8"].finished || __quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
            options.listAppend(generateHotDogLine("Devil dog", "+3 cold/spooky res, 30 turns.", 3));
        if (!__quest_state["Level 9"].state_boolean["Peak Stench Completed"])
            options.listAppend(generateHotDogLine("Chilly dog", "+10ML and +3 stench/sleaze res, 30 turns.", 3));
		if (my_primestat() == $stat[muscle])
			options.listAppend(generateHotDogLine("Savage macho dog", "+50% muscle, 50 turns.", 2));
		if (my_primestat() == $stat[mysticality])
			options.listAppend(generateHotDogLine("One with everything", "+50% mysticality, 50 turns.", 2));
		if (my_primestat() == $stat[moxie])
			options.listAppend(generateHotDogLine("Sly Dog", "+50% moxie, 50 turns.", 2));
			
        description.listAppend(HTMLGenerateSimpleTableLines(options));
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, "clan_viplounge.php?action=hotdogstand", ChecklistSubentryMake(name, "", description), 5));
	}
	
		
	if (!get_property_boolean("_olympicSwimmingPoolItemFound") && __misc_state["VIP available"])
		available_resources_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "", ChecklistSubentryMake("Dive for swimming pool item", "", "\"swim item\" in GCLI"), 5));
	if (!get_property_boolean("_olympicSwimmingPool") && __misc_state["VIP available"])
		available_resources_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "clan_viplounge.php?action=swimmingpool", ChecklistSubentryMake("Swim in VIP pool", "50 turns", listMake("+20 ML, +30% init", "Or -combat")), 5));
	if (!get_property_boolean("_aprilShower") && __misc_state["VIP available"])
	{
		string [int] description;
		if (__misc_state["need to level"])
			description.listAppend("+mainstat gains (50 turns)");
        
        string [int] reasons;
        reasons.listAppend("nice hat");
        if ($familiar[fancypants scarecrow].familiar_is_usable())
            reasons.listAppend("scarecrow pants");
        reasons.listAppend("tower killing");
        
		description.listAppend("Double-ice (" + reasons.listJoinComponents(", ", "and") + ")");
		
		available_resources_entries.listAppend(ChecklistEntryMake("__item shard of double-ice", "", ChecklistSubentryMake("Take a shower", description), 5));
	}
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 )
    {
        int games_available = 3 - get_property_int("_poolGames");
        string [int] description;
        if (__misc_state["familiars temporarily blocked"])
            description.listAppend("+50% weapon damage. (aggressively)");
        else
            description.listAppend("+5 familiar weight, +50% weapon damage. (aggressively)");
        description.listAppend("Or +50% spell damage, +10 MP regeneration. (strategically)");
        description.listAppend("Or +10% item, +50% init. (stylishly)");
		available_resources_entries.listAppend(ChecklistEntryMake("__item pool cue", "clan_viplounge.php?action=pooltable", ChecklistSubentryMake(pluralize(games_available, "pool table game", "pool table games"), "10 turns", description), 5));
    }
    if (__quest_state["Level 6"].finished && !get_property_boolean("friarsBlessingReceived"))
    {
        string [int] description;
        if (!__misc_state["familiars temporarily blocked"])
        {
            description.listAppend("+Familiar experience.");
            description.listAppend("Or +30% food drop.");
        }
        else
            description.listAppend("+30% food drop.");
        description.listAppend("Or +30% booze drop.");
        boolean should_output = true;
        if (!__misc_state["In run"])
        {
            should_output = false;
        }
        if (!should_output && familiar_weight(my_familiar()) < 20 && my_familiar() != $familiar[none])
        {
            description.listClear();
            description.listAppend("+Familiar experience.");
            should_output = true;
        }
        if (should_output)
            available_resources_entries.listAppend(ChecklistEntryMake("Monk", "friars.php", ChecklistSubentryMake("Forest Friars buff", "20 turns", description), 10));
    }
	
	
	
	
	
	
	if (!get_property_boolean("_madTeaParty") && __misc_state["VIP available"])
	{
        string [int] description;
        string line = "Various effects.";
        if (__misc_state["In run"])
        {
            line = "+20ML";
            if ($item[pail].available_amount() == 0)
                line += " with pail (you don't have one, talk to artist)";
            line += "|Or various effects.";
        }
        description.listAppend(line);
		available_resources_entries.listAppend(ChecklistEntryMake("__item insane tophat", "", ChecklistSubentryMake("Mad tea party", "30 turns", description), 5));
	}
	
	if (true)
	{
        string image_name = "__item hell ramen";
		ChecklistSubentry [int] subentries;
		if (availableFullness() > 0)
		{
            string [int] description;
            if ($effect[Got Milk].have_effect() > 0)
                description.listAppend(pluralize($effect[Got Milk]) + " available.");
			subentries.listAppend(ChecklistSubentryMake(availableFullness() + " fullness", "", description));
		}
		if (availableDrunkenness() >= 0 && inebriety_limit() > 0)
        {
            string title = "";
            string [int] description;
            if (subentries.count() == 0)
                image_name = "__item gibson";
            if ($effect[ode to booze].have_effect() > 0)
                description.listAppend(pluralize($effect[ode to booze]) + " available.");
            
            if (availableDrunkenness() > 0)
                title = availableDrunkenness() + " drunkenness";
            else
                title = "Can overdrink";
			subentries.listAppend(ChecklistSubentryMake(title, "", description));
        }
		if (availableSpleen() > 0)
		{
            if (subentries.count() == 0)
                image_name = "__item agua de vida";
			subentries.listAppend(ChecklistSubentryMake(availableSpleen() + " spleen", "", ""));
		}
		if (subentries.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=1", subentries, 11));
	}
	
	if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
	{
		string [int] description;
		description.listAppend("Contains 1 monarch.");
        description.listAppend(pluralize(my_ascensions(), "king", "kings") + " freed.");
        string image_name;
        image_name = "__effect sleepy";
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, "lair6.php", ChecklistSubentryMake("1 Prism", "", description), 10));
	}
    
    if ((get_property("sidequestOrchardCompleted") == "hippy" || get_property("sidequestOrchardCompleted") == "fratboy") && !get_property_boolean("_hippyMeatCollected"))
    {
		available_resources_entries.listAppend(ChecklistEntryMake("__item herbs", "", ChecklistSubentryMake("Meat from the hippy store", "", "~4500 free meat."), 5));
    }
    if ((get_property("sidequestArenaCompleted") == "hippy" || get_property("sidequestArenaCompleted") == "fratboy") && !get_property_boolean("concertVisited"))
    {
        string [int] description;
        if (get_property("sidequestArenaCompleted") == "hippy")
        {
            description.listAppend("+5 familiar weight.");
            description.listAppend("Or +20% item.");
            if (__misc_state["need to level"])
                description.listAppend("Or +5 stats/fight.");
        }
        else if (get_property("sidequestArenaCompleted") == "fratboy")
        {
            description.listAppend("+40% meat.");
            description.listAppend("+50% init.");
            description.listAppend("+10% all attributes.");
        }
        
        string url = "bigisland.php?place=concert";
        if (__quest_state["Level 12"].finished)
            url = "postwarisland.php?place=concert";
		available_resources_entries.listAppend(ChecklistEntryMake("__item the legendary beat", url, ChecklistSubentryMake("Arena concert", "20 turns", description), 5));
    }
    
    //Not sure how I feel about this. It's kind of extraneous?
    //Disabled for now, errors in 16.2 release.
    /*if (get_property_int("telescopeUpgrades") > 0 && !get_property_boolean("telescopeLookedHigh") && __misc_state["In run"])
    {
        string [int] description;
        int percentage = 5 * get_property_int("telescopeUpgrades");
        description.listAppend("+" + percentage + "% to all attributes. (10 turns)");
		available_resources_entries.listAppend(ChecklistEntryMake("__effect Starry-Eyed", "campground.php?action=telescope", ChecklistSubentryMake("Telescope buff", "", description), 10));
    }*/
    
    
    if (__misc_state_int["free rests remaining"] > 0)
    {
        float resting_hp_percent = numeric_modifier("resting hp percent") / 100.0;
        float resting_mp_percent = numeric_modifier("resting mp percent") / 100.0;
        
        //FIXME trace down every rest effect and make this more accurate, instead of an initial guess.
        
        //If grimace or ronald is full, they double the gains of everything else.
        //This is reported as a modifier of +100% - so with pagoda, that's +200% HP
        //But, it's actually +300%, or 400% total. I could be wrong about this - my knowledge of rest mechanics is limited.
        //So, we'll explicitly check for grimace or ronald being full, then recalculate. Not great, but should work okay?
        //This is probably inaccurate in a great number of cases, due to the complication of resting.
        
        float overall_multiplier_hp = 1.0;
        float overall_multiplier_mp = 1.0;
        float bonus_resting_hp = numeric_modifier("bonus resting hp");
        float after_bonus_resting_hp = 0.0;
        int grimace_light = moon_phase() / 2;
        int ronald_light = moon_phase() % 8;
        if (grimace_light == 4)
        {
            resting_hp_percent -= 1.0;
            overall_multiplier_hp += 1.0;
        }
        if (ronald_light == 4)
        {
            resting_mp_percent -= 1.0;
            overall_multiplier_mp += 1.0;
        }
        
        if ($effect[L'instinct F&eacute;lin].have_effect() > 0) //not currently tracked by mafia. Seems to triple HP/MP gains.
        {
            overall_multiplier_hp *= 3.0;
            overall_multiplier_mp *= 3.0;
        }
        
        if ((get_campground() contains $item[gauze hammock]))
        {
            //Gauze hammock appears to be a flat addition applied after everything else, including grimace, pagoda, and l'instinct.
            //It shows up it bonus resting hp - we'll remove that, and add it back at the end.
            bonus_resting_hp -= 60.0;
            after_bonus_resting_hp += 60.0;
        }
        
        float rest_hp_restore = after_bonus_resting_hp + overall_multiplier_hp * (numeric_modifier("base resting hp") * (1.0 + resting_hp_percent) + bonus_resting_hp);
        float rest_mp_restore = overall_multiplier_mp * (numeric_modifier("base resting mp") * (1.0 + resting_mp_percent) + numeric_modifier("bonus resting mp"));
        string [int] description;
        description.listAppend(rest_hp_restore.floor() + " HP, " + rest_mp_restore.floor() + " MP");
		available_resources_entries.listAppend(ChecklistEntryMake("__effect sleepy", "campground.php", ChecklistSubentryMake(pluralizeWordy(__misc_state_int["free rests remaining"], "free rest", "free rests").capitalizeFirstLetter(), "", description), 10));
    }
    
    if (in_bad_moon() && !get_property_boolean("styxPixieVisited"))
    {
        string [int] description;
        description.listAppend("+40% meat, +20% items, +25% moxie.");
        description.listAppend("Or +25% mysticality, +10-15 mp regen.");
        description.listAppend("Or +25% muscle, +5 DR.");
		available_resources_entries.listAppend(ChecklistEntryMake("__effect Hella Smooth", "", ChecklistSubentryMake("Styx pixie buff", "", description), 10));
    }
    
    //FIXME skate park?
    
    if (my_path_id() != PATH_BEES_HATE_YOU && !get_property_boolean("guyMadeOfBeesDefeated") && get_property_int("guyMadeOfBeesCount") > 0 && (__misc_state["In aftercore"] || !__quest_state["Level 12"].state_boolean["Arena Finished"]))
    {
        //Not really worthwhile? But I suppose we can track it if they've started it, and are either in aftercore or haven't flyered yet.
        //For flyering, it's 20 turns at -25%, 25 turns at -15%. 33 turns at -5%. Not worthwhile?
        int summon_count = get_property_int("guyMadeOfBeesCount");
        
        string [int] description;
        string times = "";
        if (summon_count == 4)
            times = "One More Time.";
        else
            times = int_to_wordy(5 - summon_count) + " times.";
        description.listAppend("Speak his name " + times);
        if ($item[antique hand mirror].available_amount() == 0)
            description.listAppend("Need antique hand mirror to win. Or towerkill.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item guy made of bee pollen", "place.php?whichplace=spookyraven2", ChecklistSubentryMake("The Guy Made Of Bees", "", description), 10));
    }
    
    if (stills_available() > 0)
    {
        string [int] description;
        string [int] mixables;
        if (__misc_state["can drink just about anything"])
        {
            mixables.listAppend("neuromancer-level drinks");
        }
        mixables.listAppend("~40MP from tonic water");
        
        description.listAppend(mixables.listJoinComponents(", ", "or").capitalizeFirstLetter() + ".");
        
		available_resources_entries.listAppend(ChecklistEntryMake("Superhuman Cocktailcrafting", "shop.php?whichshop=still", ChecklistSubentryMake(pluralize(stills_available(), "still use", "still uses"), "", description), 10));
    }
    
    if (my_class() == $class[seal clubber])
    {
        //Seal summons:
        //FIXME suggest they equip a club (support swords with iron palms)
        int seal_summon_limit = 5;
        if ($item[Claw of the Infernal Seal].available_amount() > 0)
            seal_summon_limit = 10;
        int seals_summoned = get_property_int("_sealsSummoned");
        int summons_remaining = MAX(seal_summon_limit - seals_summoned, 0);
        
        string [int] description;
        
        //description left blank, due to possible revamp?
        
        if (summons_remaining > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item figurine of an ancient seal", "", ChecklistSubentryMake(pluralize(summons_remaining, "seal summon", "seal summons"), "", description), 10));
    }
    
    if (__last_adventure_location == $location[The Red Queen's Garden])
    {
        string will_need_effect = "";
        if ($effect[down the rabbit hole].have_effect() == 0)
            will_need_effect = "|Will need to use &quot;DRINK ME&quot; potion first.";
        if (get_property_int("pendingMapReflections") > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "place.php?whichplace=rabbithole", ChecklistSubentryMake(pluralize(get_property_int("pendingMapReflections"), "pending reflection of a map", "pending reflections of a map"), "+900% item", "Adventure in the Red Queen's garden to acquire." + will_need_effect), 0));
        if ($items[reflection of a map].available_amount() > 0)
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[reflection of a map]), "", "Queen cookies." + will_need_effect), 0));
        }
    }
    
    if (__misc_state["VIP available"])
    {
        if (!get_property_boolean("_lookingGlass"))
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", "clan_viplounge.php", ChecklistSubentryMake("A gaze into the looking glass", "", "Acquire a " + $item[&quot;DRINK ME&quot; potion] + "."), 10));
        }
        //_deluxeKlawSummons?
        //_crimboTree?
        int soaks_remaining = MAX(0, 5 - get_property_int("_hotTubSoaks"));
        if (__misc_state["In run"] && soaks_remaining > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__effect blessing of squirtlcthulli", "clan_viplounge.php", ChecklistSubentryMake(pluralize(soaks_remaining, "hot tub soak", "hot tub soaks"), "", "Restore all HP, removes most bad effects."), 8));
    }
    //_klawSummons?
    
    //Skill books we have used, but don't have the skill for?
    
    //soul sauce tracking?
    
    
    
    if (get_property_int("goldenMrAccessories") > 0)
    {
        //FIXME inline with hugs
        int total_casts_available = get_property_int("goldenMrAccessories") * 5;
        int casts_used = get_property_int("_smilesOfMrA");
        
        int casts_remaining = total_casts_available - casts_used;
        
        if (casts_remaining > 0)
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item Golden Mr. Accessory", "skills.php", ChecklistSubentryMake(pluralize(casts_remaining, "smile of the Mr. Accessory", "smiles of the Mr. Accessory"), "", "Give away sunshine."), 8));
        }
    }
	
	checklists.listAppend(ChecklistMake("Resources", available_resources_entries));
}
void generateStrategy(Checklist [int] checklists)
{
	ChecklistEntry [int] entries;
    
    if (!__misc_state["In run"])
        return;
    
    
    //What familiar to run. spleen items
    //Turn generation.
    //How to handle combat.
    //How to restore HP.
    //Where to get MP...?
    
    
	checklists.listAppend(ChecklistMake("Strategy", entries));
}

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
        body_style += "background-color:" + __setting_dark_color + ";";
    else
        body_style += "background-color:#FFFFFF;";
    body_style += "margin:0px;padding:0px;font-size:14px;";
    
    if (__setting_ios_appearance)
        body_style += "font-family:'Helvetica Neue',Arial, Helvetica, sans-serif;font-weight:lighter;";
    
    PageAddCSSClass("body", "", body_style, -11);
    
    PageAddCSSClass("body", "", "font-size:13px;", -11, __setting_media_query_medium_size);
    PageAddCSSClass("body", "", "font-size:12px;", -11, __setting_media_query_small_size);
    PageAddCSSClass("body", "", "font-size:12px;", -11, __setting_media_query_tiny_size);
    
    
	PageAddCSSClass("", "r_future_option", "color:" + __setting_unavailable_color + ";");
	
    PageAddCSSClass("a", "r_cl_internal_anchor", "position:absolute;z-index:2;padding-top:" + __setting_navbar_height + ";display:inline-block;");
	
	
    PageAddCSSClass("div", "r_word_wrap_group", "display:inline-block;");
	
	if (true)
	{
		string hr_definition;
		hr_definition = "height: 1px; margin-top: 1px; margin-bottom: 1px; border: 0px; width: 100%;";
	
		hr_definition += "background: " + __setting_line_color + ";";
		PageAddCSSClass("hr", "", hr_definition);
	}
	
	
    if (__setting_fill_vertical)
        PageAddCSSClass("div", "r_vertical_fill", "bottom:0;left:0;right:0;position:fixed;height:100%;margin-left:auto;margin-right:auto;");
    
    if (__setting_show_navbar)
    {
        PageAddCSSClass("div", "r_navbar_line_separator", "position:absolute;float:left;min-width:1px;min-height:" + __setting_navbar_height + ";background:" + __setting_line_color + ";");
        PageAddCSSClass("div", "r_navbar_text", "text-align:center;font-weight:bold;font-size:.9em;");
        PageAddCSSClass("div", "r_navbar_button_container", "overflow:hidden;vertical-align:top;display:inline-block;height:" + __setting_navbar_height + ";");
    }
    PageAddCSSClass("img", "", "border:0px;");
}

void generateImageTest(Checklist [int] checklists)
{
	ChecklistEntry [int] image_test_entries;
	KOLImagesInit();
	foreach i in __kol_images
	{
		KOLImage image = __kol_images[i];
		image_test_entries.listAppend(ChecklistEntryMake(i, "", ChecklistSubentryMake(i)));
		
	}
	checklists.listAppend(ChecklistMake("All images", image_test_entries));
}

void generateStateTest(Checklist [int] checklists)
{
	ChecklistEntry [int] misc_state_entries;
	ChecklistEntry [int] quest_state_entries;
    
	
    string [int] state_description;
    string [int] string_description;
    string [int] int_description;
	foreach key in __misc_state
	{
        state_description.listAppend(key + " = " + __misc_state[key]);
	}
	foreach key in __misc_state_string
	{
        string_description.listAppend(key + " = \"" + __misc_state_string[key] + "\"");
	}
	foreach key in __misc_state_int
	{
        int_description.listAppend(key + " = " + __misc_state_int[key]);
	}
	
    misc_state_entries.listAppend(ChecklistEntryMake("__item milky potion", "", ChecklistSubentryMake("Boolean", "", state_description.listJoinComponents("|"))));
    misc_state_entries.listAppend(ChecklistEntryMake("__item ghost thread", "", ChecklistSubentryMake("String", "", string_description.listJoinComponents("|"))));
    misc_state_entries.listAppend(ChecklistEntryMake("__item handful of numbers", "", ChecklistSubentryMake("Int", "", int_description.listJoinComponents("|"))));
	
	boolean [string] names_already_seen;
	
	foreach key in __quest_state
	{
		if (names_already_seen[key])
			continue;
		names_already_seen[key] = true;
		
		QuestState quest_state = __quest_state[key];
		
		string [int] full_name_list;
		full_name_list.listAppend(key);
		
		//Look for others:
		foreach key2 in __quest_state
		{
			if (key == key2)
				continue;
			QuestState quest_state_2 = __quest_state[key2];
			
			if (QuestStateEquals(quest_state, quest_state_2))
			{
				full_name_list.listAppend(key2);
				names_already_seen[key2] = true;
			}
		}
		
		ChecklistSubentry subentry;
		
		subentry.header = listJoinComponents(full_name_list, " / " );
		if (quest_state.quest_name != "")
			subentry.entries.listAppend("Internal name: " + quest_state.quest_name);
		
		subentry.entries.listAppend("Startable: " + quest_state.startable);
		subentry.entries.listAppend("Started: " + quest_state.started);
		subentry.entries.listAppend("In progress: " + quest_state.in_progress);
		subentry.entries.listAppend("Finished: " + quest_state.finished);
		subentry.entries.listAppend("Mafia's internal step: " + quest_state.mafia_internal_step);
		
		foreach key2 in quest_state.state_boolean
		{
			subentry.entries.listAppend(key2 + ": " + quest_state.state_boolean[key2]);
		}
		foreach key2 in quest_state.state_string
		{
			subentry.entries.listAppend(key2 + ": \"" + quest_state.state_string[key2] + "\"");
		}
		foreach key2 in quest_state.state_int
		{
			subentry.entries.listAppend(key2 + ": " + quest_state.state_int[key2]);
		}
		
		quest_state_entries.listAppend(ChecklistEntryMake(quest_state.image_name, "", subentry));
	}
	
	
	checklists.listAppend(ChecklistMake("Misc. States", misc_state_entries));
	checklists.listAppend(ChecklistMake("Quest States", quest_state_entries));
}


void generateMisc(Checklist [int] checklists)
{
	if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
	{
		ChecklistEntry [int] unimportant_task_entries;
		string [int] king_messages;
		king_messages.listAppend("You know, whenever.");
		king_messages.listAppend("Or become the new naughty sorceress?");
		unimportant_task_entries.listAppend(ChecklistEntryMake("king imprismed", "lair6.php", ChecklistSubentryMake("Free the King", "", king_messages)));
		
		checklists.listAppend(ChecklistMake("Unimportant Tasks", unimportant_task_entries));
	}
	
	if (availableDrunkenness() < 0 && $item[drunkula's wineglass].equipped_amount() == 0) //assuming in advance sneaky pete has some sort of drunkenness adventures
	{
        //They're drunk, so tasks aren't as relevant. Re-arrange everything:
        string url;
        
        //Give them something to mindlessly click on:
        //url = "bet.php";
       if ($coinmaster[Game Shoppe].is_accessible())
            url = "aagame.php";
        
        
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
		
		lookupChecklist(checklists, "Future Tasks").entries.listAppendList(lookupChecklist(checklists, "Tasks").entries);
		lookupChecklist(checklists, "Future Tasks").entries.listAppendList(lookupChecklist(checklists, "Optional Tasks").entries);
		lookupChecklist(checklists, "Future Unimportant Tasks").entries.listAppendList(lookupChecklist(checklists, "Unimportant Tasks").entries);
		
		lookupChecklist(checklists, "Tasks").entries.listClear();
		lookupChecklist(checklists, "Optional Tasks").entries.listClear();
		lookupChecklist(checklists, "Unimportant Tasks").entries.listClear();
		
        string [int] description;
        string line = "You're drunk.";
        if (__last_adventure_location == $location[Drunken Stupor])
            url = "campground.php";
        
        if (hippy_stone_broken() && pvp_attacks_left() > 0)
            url = "peevpee.php";
            
        description.listAppend(line);
        if ($item[drunkula's wineglass].available_amount() > 0 && $item[drunkula's wineglass].can_equip())
        {
            description.listAppend("Or equip your wineglass.");
        }
        
        int rollover_adventures_from_equipment = 0;
        foreach s in $slots[]
            rollover_adventures_from_equipment += s.equipped_item().numeric_modifier("adventures").to_int();
        
        if (rollover_adventures_from_equipment == 0.0)
        {
            description.listAppend("Possibly wear +adventures gear.");
        }
        //detect if they're going to lose some turns, be nice:
        int rollover_adventures_gained = numeric_modifier("adventures").to_int() + 40;
        if (get_property_boolean("_borrowedTimeUsed"))
            rollover_adventures_gained -= 20;
        int adventures_lost = (my_adventures() + rollover_adventures_gained) - 200;
        if (adventures_lost > 0)
        {
            description.listAppend("You'll miss out on " + pluralizeWordy(adventures_lost, "adventure", "adventures") + ". Alas.|Could work out in the gym, craft, or play arcade games.");
        }
        
        //this could be better (i.e. checking against current shirt and looking in inventory, etc.)
        if (lookupItem("Sneaky Pete's leather jacket (collar popped)").equipped_amount() > 0)
            description.listAppend("Might want to unpop the collar. (+4 adventures)");
        if (in_ronin() && pulls_remaining() > 0)
        {
            description.listAppend("Don't forget your " + pluralizeWordy(pulls_remaining(), "pull", "pulls") + ".");
        }
        
		task_entries.entries.listAppend(ChecklistEntryMake("__item counterclockwise watch", url, ChecklistSubentryMake("Wait for rollover", "", description), -11));
	}
}

void generateChecklists(Checklist [int] ordered_output_checklists)
{
	setUpState();
	setUpQuestState();
	
	if (__misc_state["Example mode"])
		setUpExampleState();
	
	finalizeSetUpState();
	
	Checklist [int] checklists;
	
    
    if (!playerIsLoggedIn())
    {
        //Hmm. I think emptying everything is the way to go, because if we're not online, we'll be inaccurate. Best to give no advice than some.
        //But, it might break in the future if our playerIsLoggedIn() detection is inaccurate?
        
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
        
        string image_name;
        image_name = "disco bandit"; //tricky - they may not have this image in their image cache. Display nothing?
		task_entries.entries.listAppend(ChecklistEntryMake(image_name, "", ChecklistSubentryMake("Log in", "+internet", "An Adventurer is You!"), -11));
    }
    else if (__misc_state["In valhalla"])
    {
        //Valhalla:
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
        task_entries.entries.listAppend(ChecklistEntryMake("astral spirit", "", ChecklistSubentryMake("Ascend, spirit!", "", listMake("Perm skills.", "Buy consumables.", "Bring along a pet."))));
    }
    else
    {
        generateDailyResources(checklists);
        
        generateTasks(checklists);
        if (__misc_state["Example mode"] || !get_property_boolean("kingLiberated"))
        {
            generateMissingItems(checklists);
            generatePullList(checklists);
        }
        if (__setting_debug_show_all_internal_states && __setting_debug_mode)
            generateImageTest(checklists);
        if (__setting_debug_show_all_internal_states && __setting_debug_mode)
            generateStateTest(checklists);
        generateFloristFriar(checklists);
        
        
        generateMisc(checklists);
        generateStrategy(checklists);
    }
	
	//Remove checklists that have no entries:
	int [int] keys_to_remove;
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		if (cl.entries.count() == 0)
			keys_to_remove.listAppend(key);
	}
	listRemoveKeys(checklists, keys_to_remove);
	listClear(keys_to_remove);
	
	//Go through desired output order:
	string [int] setting_desired_output_order = split_string_mutable("Tasks,Optional Tasks,Unimportant Tasks,Future Tasks,Resources,Future Unimportant Tasks,Required Items,Suggested Pulls,Florist Friar,Strategy", ",");
	foreach key in setting_desired_output_order
	{
		string title = setting_desired_output_order[key];
		//Find title in checklists:
		foreach key2 in checklists
		{
			Checklist cl = checklists[key2];
			if (cl.title == title)
			{
				ordered_output_checklists.listAppend(cl);
				keys_to_remove.listAppend(key2);
				break;
			}
		}
	}
	listRemoveKeys(checklists, keys_to_remove);
	listClear(keys_to_remove);
	
	//Add remainder:
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		ordered_output_checklists.listAppend(cl);
	}
}


string generateRandomMessage()
{
	string [int] random_messages;
    
    if (!playerIsLoggedIn())
        return "the kingdom awaits";
        
    if (__misc_state["In valhalla"])
        return "rebirth";
    
	if (__misc_state["In run"])
    {
		random_messages.listAppend("you are ascending too slowly, ascend faster!");
        random_messages.listAppend("take those extra adventures you were going to play, and forget to do them");
        random_messages.listAppend("every spreadsheet you make saves a turn");
    }
    
    string [string] holiday_messages;
    holiday_messages["Groundhog Day"] = "it's cold out there every day";
    holiday_messages["Crimbo"] = "merry crimbo";
    
    boolean [string] holidays_today = getHolidaysToday();
    foreach holiday in holidays_today
    {
        if (holiday_messages contains holiday)
        {
            random_messages.listAppend(holiday_messages[holiday]);
        }
    }
    
	if (__misc_state["In run"])
    {
        random_messages.listAppend("optimal power, make up!");
        random_messages.listAppend("the faster your runs, the longer they take");
    }
    
    string [location] location_messages;
    foreach l in $locations[domed city of ronaldus,domed city of grimacia,hamburglaris shield generator]
        location_messages[l] = "spaaaace!";
    location_messages[$location[the penultimate fantasy airship]] = "insert disc 2 to continue";
    location_messages[$location[a-boo peak]] = "allons-y!";
    location_messages[$location[twin peak]] = "fire walk with me";
    location_messages[$location[The Arrrboretum]] = "save the planet";
    location_messages[$location[the red queen's garden]] = "curiouser and curiouser";
    location_messages[$location[A Massive Ziggurat]] = "1.21 ziggurats";
    location_messages[$location[McMillicancuddy's Barn]] = "dooks";
    
    foreach l in $locations[fear man's level,doubt man's level,regret man's level,anger man's level]
        location_messages[l] = "<em>this isn't me</em>";
    
    if (location_messages contains __last_adventure_location)
        random_messages.listAppend(location_messages[__last_adventure_location]);
    

    random_messages.listAppend(HTMLGenerateTagWrap("a", "if you're feeling stressed, play alice's army", mapMake("class", "r_a_undecorated", "href", "aagame.php", "target", "mainpane")));
	random_messages.listAppend("consider your mistakes creative spading");
    
    if (hippy_stone_broken())
        random_messages.listAppend("it's not easy having yourself a good time");
    
    string [item] equipment_messages;
    equipment_messages[$item[whatsian ionic pliers]] = "ionic pliers untinker to a screwdriver and a sonar-in-a-biscuit";
    equipment_messages[$item[yearbook club camera]] = "rule of thirds";
    equipment_messages[$item[happiness]] = "bang bang";
    equipment_messages[$item[mysterious silver lapel pin]] = "be seeing you";
    equipment_messages[$item[Moonthril Circlet]] = "moon tiara";
    equipment_messages[$item[numberwang]] = "simply everyone";
    equipment_messages[$item[Mark V Steam-Hat]] = "girl genius";
    equipment_messages[$item[mr. accessory]] = "you can equip mr. accessories?";
    equipment_messages[$item[white hat hacker T-shirt]] = "hack the planet";
    equipment_messages[$item[heart necklace]] = "&#x2665;&#xfe0e;"; //♥︎
    
    foreach it in equipment_messages
    {
        if (it.equipped_amount() > 0)
        {
            random_messages.listAppend(equipment_messages[it]);
            break;
        }
    }
	
	if (my_ascensions() == 0)
		random_messages.listAppend("welcome to the kingdom!");
        
    if (__misc_state["In run"])
        random_messages.listAppend("perfect runs are overrated");
    random_messages.listAppend("math is your helpful friend");
    
    string [effect] effect_messages;
    
    effect_messages[$effect[consumed by anger]] = "don't ascend angry";
    effect_messages[$effect[consumed by regret]] = "wasted potential";
    effect_messages[lookupEffect("All Revved Up")] = "vroom";
    if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
        effect_messages[$effect[Expert Timing]] = "martial arts and crafts";
    effect_messages[$effect[apathy]] = "";
    effect_messages[$effect[silent running]] = "an awful lot of running";
    effect_messages[$effect[Neuromancy]] = "the silver paths";
    effect_messages[$effect[Teleportitis]] = "everywhere and nowhere";
    
    
    
    foreach e in effect_messages
    {
        if (e.have_effect() > 0 && e != $effect[none])
        {
            random_messages.listAppend(effect_messages[e]);
            break;
        }
    }
    
    random_messages.listAppend("click click click");
    
    string [int] paths;
    paths[PATH_BEES_HATE_YOU] = "bzzzzzz";
    paths[PATH_WAY_OF_THE_SURPRISING_FIST] = "martial arts and crafts";
    paths[PATH_TRENDY] = "played out";
    paths[PATH_AVATAR_OF_BORIS] = "testosterone poisoning";
    paths[PATH_BUGBEAR_INVASION] = "bugbears!";
    paths[PATH_ZOMBIE_SLAYER] = "consumerism metaphor";
    paths[PATH_CLASS_ACT] = "try the sequel";
    paths[PATH_AVATAR_OF_JARLSBERG] = "nerd";
    paths[PATH_BIG] = "leveling is boring";
    paths[PATH_KOLHS] = "did you study?";
    paths[PATH_CLASS_ACT_2] = "lonely guild trainer";
    paths[PATH_AVATAR_OF_SNEAKY_PETE] = "sunglasses at night";
    
    paths[PATH_OXYGENARIAN] = "the slow path";
    
    if (paths contains my_path_id())
        random_messages.listAppend(paths[my_path_id()]);
    
    random_messages.listAppend("I don't know either, sorry");
    
    string lowercase_player_name = my_name().to_lower_case().HTMLEscapeString();
        
	random_messages.listAppend(HTMLGenerateTagWrap("a", "check the wiki", mapMake("class", "r_a_undecorated", "href", "http://kol.coldfront.net/thekolwiki/index.php/Main_Page", "target", "_blank")));
	random_messages.listAppend("the RNG is only trying to help");
	if (__misc_state["In run"])
        random_messages.listAppend("speed ascension is all I have left, " + lowercase_player_name);
	if ($item[puppet strings].storage_amount() + $item[puppet strings].available_amount() > 0)
		random_messages.listAppend(lowercase_player_name + " is totally awesome! hooray for " + lowercase_player_name + "!");
	
	if (florist_available())
        random_messages.listAppend(HTMLGenerateTagWrap("a", "the forgotten friar cries himself to sleep", mapMake("class", "r_a_undecorated", "href", "place.php?whichplace=forestvillage&action=fv_friar", "target", "mainpane")));
    
	if (!__misc_state["skills temporarily missing"])
	{
		if (!$skill[Transcendent Olfaction].have_skill())
            random_messages.listAppend(HTMLGenerateTagWrap("a", "visit the bounty hunter hunter sometime", mapMake("class", "r_a_undecorated", "href", "bounty.php", "target", "mainpane")));
	}
    if (__misc_state["in aftercore"])
        random_messages.listAppend(HTMLGenerateTagWrap("a", "ascension is waiting for you", mapMake("class", "r_a_undecorated", "href", "lair6.php", "target", "mainpane")));
    
    if (my_adventures() == 0)
        random_messages.listAppend("nowhere left to go");
        
    string [familiar] familiar_messages;
    familiar_messages[$familiar[none]] = "even introverts need friends";
    familiar_messages[$familiar[black cat]] = "aww, cute kitty!";
    familiar_messages[$familiar[temporal riftlet]] = "master of time and space";
    familiar_messages[$familiar[Frumious Bandersnatch]] = "frabjous";
    if (__misc_state["free runs usable"])
        familiar_messages[$familiar[Pair of Stomping Boots]] = "running away again?";
    familiar_messages[$familiar[baby sandworm]] = "the waters of life";
    familiar_messages[$familiar[baby bugged bugbear]] = "expected }, found ; (Main.ash, line 495)";
    familiar_messages[$familiar[mechanical songbird]] = "a little glowing friend";
    familiar_messages[$familiar[nanorhino]] = "write every day";
    familiar_messages[$familiar[rogue program]] = "ascends for the users";
    familiar_messages[$familiar[O.A.F.]] = "helping";
    foreach f in $familiars[Bank Piggy,Egg Benedict,Floating Eye,Money-Making Goblin,Oyster Bunny,Plastic Grocery Bag,Snowhitman,Vampire Bat,Worm Doctor]
        familiar_messages[f] = "hacker";
    familiar_messages[$familiar[adorable space buddy]] = "far beyond the stars";
    familiar_messages[$familiar[happy medium]] = "karma slave";
    familiar_messages[$familiar[wild hare]] = "or you wouldn't have come here"; //you must be mad
    familiar_messages[$familiar[artistic goth kid]] = "life is pain, " + lowercase_player_name;
    familiar_messages[$familiar[angry jung man]] = "personal trauma";
    familiar_messages[$familiar[unconscious collective]] = "zzz";
    familiar_messages[$familiar[dataspider]] = "spiders are your friends";
    familiar_messages[$familiar[stocking mimic]] = "delicious candy";
    familiar_messages[$familiar[cocoabo]] = "flightless bird";
    familiar_messages[$familiar[whirling maple leaf]] = "canadian pride";
    familiar_messages[$familiar[Hippo Ballerina]] = "spin spin spin";
    familiar_messages[$familiar[Mutant Cactus Bud]] = "always watching";
    familiar_messages[$familiar[ghuol whelp]] = "&#x00af;\\_(&#x30c4;)_/&#x00af;"; //¯\_(ツ)_/¯
    familiar_messages[$familiar[bulky buddy box]] = "&#x2665;&#xfe0e;"; //♥︎
    familiar_messages[$familiar[emo squid]] = "sob";
    familiar_messages[$familiar[fancypants scarecrow]] = "the best in terms of pants";
    familiar_messages[$familiar[jumpsuited hound dog]] = "a little less conversation";
    familiar_messages[$familiar[Gluttonous Green Ghost]] = "I think he can hear you, " + lowercase_player_name;
    familiar_messages[$familiar[hand turkey]] = "a rare bird";
    familiar_messages[$familiar[reanimated reanimator]] = "weird science";
    
    
    if (familiar_messages contains my_familiar() && !__misc_state["familiars temporarily blocked"])
        random_messages.listAppend(familiar_messages[my_familiar()]);
        
    random_messages.listAppend(HTMLGenerateTagWrap("a", "&#x266b;", mapMake("class", "r_a_undecorated", "href", "http://www.kingdomofloathing.com/radio.php", "target", "_blank")));
        
    
    string [class] class_messages;
    class_messages[$class[disco bandit]] = "making discos of your castles";
    class_messages[$class[seal clubber]] = "I &#x2663;&#xfe0e; seals";
    class_messages[$class[turtle tamer]] = "turtles turtles every where";
    
    if (class_messages contains my_class())
        random_messages.listAppend(class_messages[my_class()]);
    
    
    string [monster] monster_messages;
    foreach m in $monsters[The Temporal Bandit,crazy bastard,Knott Slanding,hockey elemental,Hypnotist of Hey Deze,infinite meat bug,QuickBASIC elemental,The Master Of Thieves,Baiowulf,Count Bakula] //Pooltergeist (Ultra-Rare)?
        monster_messages[m] = "an ultra rare! congratulations!";
    monster_messages[$monster[Dad Sea Monkee]] = "is always was always" + HTMLGenerateSpanFont(" is always was always", "#444444", "") + HTMLGenerateSpanFont(" is always was always", "#888888", "") + HTMLGenerateSpanFont(" is always was always", "#BBBBBB", "");
    foreach m in $monsters[Ed the Undying (1),Ed the Undying (2),Ed the Undying (3),Ed the Undying (4),Ed the Undying (5),Ed the Undying (6),Ed the Undying (7)]
        monster_messages[m] = "UNDYING!";
    foreach m in $monsters[Naughty Sorceress, Naughty Sorceress (2), Naughty Sorceress (3)]
        monster_messages[m] = "she isn't all that bad";
    foreach m in $monsters[Shub-Jigguwatt\, Elder God of Violence,Yog-Urt\, Elder Goddess of Hatred]
        monster_messages[m] = "strange aeons";
    monster_messages[$monster[daft punk]] = "can you feel it?";
    monster_messages[$monster[ghastly organist]] = "phantom of the opera";
    monster_messages[$monster[The Man]] = "let the workers unite";
    monster_messages[$monster[quiet healer]] = "...";
    monster_messages[$monster[menacing thug]] = "watch your back";
    monster_messages[$monster[sea cowboy]] = "pardon me";
    monster_messages[$monster[topiary golem]] = "almost there";
    monster_messages[$monster[the server]] = "console cowboy";
    monster_messages[$monster[Fickle Finger of F8]] = "f/8 and be there";
    monster_messages[$monster[malevolent crop circle]] = "I want to believe";
    monster_messages[$monster[enraged cow]] = "moo";
    monster_messages[$monster[Claybender Sorcerer Ghost]] = "accio blank-out";
    monster_messages[$monster[Space Marine]] = "as if it were from an old dream";
    monster_messages[$monster[Whatsian Commando Ghost]] = "captain jack hotness";
    monster_messages[$monster[Regret Man]] = "wasted potential";
    monster_messages[$monster[Principal Mooney]] = "life moves pretty fast";
    if (my_turncount() < 11)
        monster_messages[$monster[family of kobolds]] = "ah, the fun of casuals";
    monster_messages[$monster[Black Crayon Spiraling Shape]] = "be what you're like";
    monster_messages[$monster[best-selling novelist]] = "fiction to escape reality";
    monster_messages[$monster[7-Foot Dwarf Replicant]] = "it's too bad she won't live<br>but then again, who does?";
    monster_messages[lookupMonster("Avatar of Jarlsberg")] = "smoked cheese";
    
    
    if (monster_messages contains last_monster() && last_monster() != $monster[none])
    {
		random_messages.listClear();
        random_messages.listAppend(monster_messages[last_monster()]);
    }
    
    if (__last_adventure_location == $location[Dreadsylvanian Castle] && $location[Dreadsylvanian Castle].lastNoncombatInLocation() == "The Machine")
    {
		random_messages.listClear();
        random_messages.listAppend("skill singularity");
    }
    if (mmg_my_bets().count() > 0)
    {
		random_messages.listClear();
		random_messages.listAppend("win some, lose some");
    }
	if ($effect[beaten up].have_effect() > 0)
	{
		random_messages.listClear();
		random_messages.listAppend("ow");
	}
	if (my_turncount() <= 0)
	{
		random_messages.listClear();
		random_messages.listAppend("find yourself<br>starting back");
	}
    
    
    //Choose:
    if (random_messages.count() == 0)
        return "lack of cleverness";
	string chosen_message = "";
	//Base message off of the minute, so it doesn't cycle when the page reloads often:
	int current_hour = now_to_string("HH").to_int_silent();
	int current_minute = now_to_string("mm").to_int_silent();
	int minute_of_day = current_hour * 60 + current_minute;
	chosen_message = random_messages[minute_of_day % random_messages.count()];
    return chosen_message;
}


void outputChecklists(Checklist [int] ordered_output_checklists)
{
    if (__misc_state["In run"] && playerIsLoggedIn())
        PageWrite(HTMLGenerateDivOfClass("Day " + my_daycount() + ". " + pluralize(my_turncount(), "turn", "turns") + " played.", "r_bold"));
	if (my_path() != "" && my_path() != "None" && playerIsLoggedIn())
	{
		PageWrite(HTMLGenerateDivOfClass(my_path(), "r_bold"));
	}
    
    
    string chosen_message = generateRandomMessage();
    if (chosen_message.length() > 0)
        PageWrite(HTMLGenerateDiv(chosen_message));
    PageWrite(HTMLGenerateTagWrap("div", "", mapMake("id", "extra_words_at_top")));
	
	
	if (__misc_state["Example mode"])
	{
		PageWrite("<br>");
		PageWrite(HTMLGenerateDivOfStyle("Example ascension", "text-align:center; font-weight:bold;"));
	}
		
	if (my_path_id() == PATH_TRENDY) //trendy is unsupported
    {
        PageWrite("<br>");
		PageWrite(HTMLGenerateDiv("Trendy warning - advice may be dangerously out of style"));
    }

    Checklist extra_important_tasks;
    
	//And output:
	foreach i in ordered_output_checklists
	{
		Checklist cl = ordered_output_checklists[i];
        
        if (__show_importance_bar && cl.title == "Tasks")
        {
            foreach key in cl.entries
            {
                ChecklistEntry entry = cl.entries[key];
                if (entry.importance_level <= -11)
                {
                    extra_important_tasks.entries.listAppend(entry);
                }
                    
            }
        }
		PageWrite(ChecklistGenerate(cl));
	}
    
    if (__show_importance_bar && extra_important_tasks.entries.count() > 0)
    {
        extra_important_tasks.title = "Tasks";
        extra_important_tasks.disable_generating_id = true;
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("id", "importance_bar", "style", "z-index:3;position:fixed; top:0;width:100%;max-width:" + __setting_horizontal_width + "px;border-bottom:1px solid;border-color:" + __setting_line_color + ";visibility:hidden;")));
		PageWrite(ChecklistGenerate(extra_important_tasks, false));
        PageWrite(HTMLGenerateTagSuffix("div"));
        
    }
}


string [string] generateAPIResponse()
{
    //35ms response time measured in-run
    string [string] result;
    
    
    boolean stale_quest_log_data = get_property_boolean("__relay_guide_stale_quest_data");
    boolean should_force_reload = false;
    if (safeToLoadQuestLog() && stale_quest_log_data) //quest log data is stale, but we can reload it
        should_force_reload = true;
    
    if (should_force_reload)
    {
        result["need to reload"] = should_force_reload;
        return result;
    }
    
    
    //Unique identifiers to determine whether a reload is necessary:
    //All of these will be checked by the javascript.
    result["turns played"] = my_turncount();
    result["hp"] = my_hp();
    result["mp"] = my_mp();
    result["+ml"] = monster_level_adjustment();
    result["+init"] = initiative_modifier();
    result["combat rate"] = combat_rate_modifier();
    result["+item"] = item_drop_modifier();
    result["familiar"] = my_familiar().to_int();
    result["adventures remaining"] = my_adventures();
    result["meat available"] = my_meat();
    result["stills available"] = stills_available();
    result["enthroned familiar"] = my_enthroned_familiar();
    result["pulls remaining"] = pulls_remaining();
    
    
    
    if (true)
    {
        int [effect] my_effects = my_effects();
        int total_effect_length = 0;
        foreach e in my_effects
            total_effect_length += my_effects[e];
        
        result["effect count"] = my_effects.count();
        result["total effect length"] = total_effect_length;
    }
    result["fullness available"] = availableFullness();
    result["drunkenness available"] = availableDrunkenness();
    result["spleen available"] = availableSpleen();
    result["auto attack id"] = get_auto_attack(); //for copied monsters warning, don't want that to be stale
    
    if (true)
    {
        result["equipped items"] = equipped_items().to_json();
    }
    
    if (false)
    {
        //if we need a clockwork maid? maybe?
        result["campground items"] = get_campground().to_json();
    }
    
    if (false)
    {
        //Very intensive, (40ms API load versus 25ms, or 28ms versus 16ms), so disabled:
        //Still, it would be very useful.
        int item_count = 0;
        foreach it in $items[]
            item_count += it.available_amount();
        result["item count"] = item_count;
    }
    else if (true)
    {
        //Checking every item is slow. But certain items won't trigger a reload, but need to. So:
        boolean [item] relevant_items = $items[photocopied monster,4-d camera,pagoda plans,Elf Farm Raffle ticket,skeleton key,heavy metal thunderrr guitarrr,heavy metal sonata,Hey Deze nuts,rave whistle,damp old boot,map to Professor Jacking's laboratory,world's most unappetizing beverage,squirmy violent party snack,White Citadel Satisfaction Satchel,rusty screwdriver,giant pinky ring,The Lost Pill Bottle,GameInformPowerDailyPro magazine,dungeoneering kit,Knob Goblin encryption key,dinghy plans,Sneaky Pete's key,Jarlsberg's key,Boris's key,fat loot token,bridge,chrome ore,asbestos ore,linoleum ore,csa fire-starting kit,tropical orchid,stick of dynamite,barbed-wire fence,psychoanalytic jar,digital key,Richard's star key,star hat,star crossbow,star staff,star sword,Wand of Nagamar,Azazel's tutu,Azazel's unicorn,Azazel's lollipop,smut orc keepsake box,blessed large box,massive sitar,hammer of smiting,chelonian morningstar,greek pasta of peril,17-alarm saucepan,shagadelic disco banjo,squeezebox of the ages,E.M.U. helmet,E.M.U. harness,E.M.U. joystick,E.M.U. rocket thrusters,E.M.U. unit,wriggling flytrap pellet,Mer-kin trailmap,Mer-kin stashbox,Makeshift yakuza mask,Novelty tattoo sleeves,strange goggles,zaibatsu level 2 card,zaibatsu level 3 card,flickering pixel,jar of oil,bowl of scorpions,molybdenum magnet,steel lasagna,steel margarita,steel-scented air freshener,Grandma's Map,mer-kin healscroll,scented massage oil,soggy used band-aid,extra-strength red potion,red pixel potion,red potion,filthy poultice,gauze garter,green pixel potion,cartoon heart,red plastic oyster egg,Manual of Dexterity,Manual of Labor,Manual of Transmission,wet stunt nut stew,bjorn's hammer,mace of the tortoise,pasta of peril,5-alarm saucepan,disco banjo,rock and roll legend,lost key,resolution: be more adventurous,sugar sheet,sack lunch,glob of Blank-Out,gaudy key,talisman o' nam,plus sign,Newbiesport&trade; tent,Frobozz Real-Estate Company Instant House (TM),dry cleaning receipt,book of matches,rock band flyers,jam band flyers,disassembled clover,continuum transfunctioner,UV-resistant compass];
        //future: add snow boards
        
        
        int [int] output;
        
        foreach it in relevant_items
        {
            if (it.available_amount() > 0)
                output[it.to_int()] = it.available_amount();
        }
        result["relevant items"] = output.to_json();
        
    }
    
    if (true)
    {
        
        boolean [string] relevant_mafia_properties = $strings[merkinQuestPath,questF01Primordial,questF02Hyboria,questF03Future,questF04Elves,questF05Clancy,questG01Meatcar,questG02Whitecastle,questG03Ego,questG04Nemesis,questG05Dark,questG06Delivery,questI01Scapegoat,questI02Beat,questL02Larva,questL03Rat,questL04Bat,questL05Goblin,questL06Friar,questL07Cyrptic,questL08Trapper,questL09Topping,questL10Garbage,questL11MacGuffin,questL11Manor,questL11Palindome,questL11Pyramid,questL11Worship,questL12War,questL13Final,questM01Untinker,questM02Artist,questM03Bugbear,questM04Galaktic,questM05Toot,questM06Gourd,questM07Hammer,questM08Baker,questM09Rocks,questM10Azazel,questM11Postal,questM12Pirate,questM13Escape,questM14Bounty,questM15Lol,questS01OldGuy,questS02Monkees,sidequestArenaCompleted,sidequestFarmCompleted,sidequestJunkyardCompleted,sidequestLighthouseCompleted,sidequestNunsCompleted,sidequestOrchardCompleted,cyrptAlcoveEvilness,cyrptCrannyEvilness,cyrptNicheEvilness,cyrptNookEvilness,desertExploration,gnasirProgress,relayCounters,timesRested,currentEasyBountyItem,currentHardBountyItem,currentSpecialBountyItem,volcanoMaze1,_lastDailyDungeonRoom,seahorseName,chasmBridgeProgress,_aprilShower,lastAdventure,lastEncounter,_floristPlantsUsed,_fireStartingKitUsed,_psychoJarUsed,hiddenHospitalProgress,hiddenBowlingAlleyProgress,hiddenApartmentProgress,hiddenOfficeProgress,pyramidPosition,parasolUsed,_discoKnife,lastPlusSignUnlock,olfactedMonster,photocopyMonster,lastTempleUnlock,volcanoMaze1,blankOutUsed,peteMotorbikeCowling,peteMotorbikeGasTank,peteMotorbikeHeadlight,peteMotorbikeMuffler,peteMotorbikeSeat,peteMotorbikeTires,_petePeeledOut,_navelRunaways,hiddenTavernUnlock];
        
        if (false)
        {
            //Give full description:
            string [string] mafia_properties;
            foreach property_name in relevant_mafia_properties
            {
                mafia_properties[property_name] = get_property(property_name);
            }
            result["mafia properties"] = mafia_properties.to_json();
        }
        else
        {
            //Give partial description: (equivalent for equivalency testing)
            //65% smaller
            buffer mafia_properties;
            boolean first = true;
            foreach property_name in relevant_mafia_properties
            {
                string v = get_property(property_name);
                
                if (first)
                    first = false;
                else
                    mafia_properties.append(",");
                mafia_properties.append(v);
            }
            result["mafia properties"] = mafia_properties.to_string();
        }
        result["logged in"] = playerIsLoggedIn();
    }
    if (false)
    {
        int skill_count = 0;
        foreach s in $skills[]
        {
            if (s.have_skill())
                skill_count += 1;
        }
        result["skill_count"] = skill_count;
    }
    else if (true)
    {
        int relevant_skill_count = 0;
        foreach s in $skills[Gothy Handwave]
        {
            if (s.have_skill())
                relevant_skill_count += 1;
        }
        result["relevant_skill_count"] = relevant_skill_count;
    }
    return result;
}


buffer generateNavbar(Checklist [int] ordered_output_checklists)
{
    buffer navbar;
    if (true)
    {
        //First holding container (fixed):
        string style = "height:" + __setting_navbar_height + ";position:fixed;z-index:1;width:100%;";
        style += "bottom:0px;";
        navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
    if (true)
    {
        //Second holding container:
        string style = "background:" + __setting_navbar_background_color + ";";
        int width = __setting_horizontal_width;
        if (!__setting_fill_vertical)
            width -= 2;
        style += "max-width:" + width + "px;height:" + __setting_navbar_height + ";margin-left:auto; margin-right:auto;font-size:1em;";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
            style += "border-left:1px solid;border-right:1px solid;";
        style += "border-top:1px solid;border-color:" + __setting_line_color + ";";
        navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
    
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
            else if (true)
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


void runMain(string relay_filename)
{
    __relay_filename = relay_filename;

	string [string] form_fields = form_fields();
	if (form_fields["API status"].length() > 0)
	{
        write(generateAPIResponse().to_json());
        return;
	}
    
    set_property("__relay_guide_stale_quest_data", "false");
    
	boolean output_body_tag_only = false;
	if (form_fields["body tag only"].length() > 0)
	{
		output_body_tag_only = true;
	}
	
	if (__setting_debug_mode && __setting_debug_enable_example_mode_in_aftercore && get_property_boolean("kingLiberated"))
	{
		__misc_state["Example mode"] = true;
	}
	
	PageInit();
	ChecklistInit();
	setUpCSSStyles();
	
	
	Checklist [int] ordered_output_checklists;
	generateChecklists(ordered_output_checklists);
	
	
	PageSetTitle("Guide");
	
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
	

	int max_width_setting = __setting_horizontal_width;
	
	PageWrite(HTMLGenerateTagPrefix("div", mapMake("class", "r_center", "style", "max-width:" + max_width_setting + "px;"))); //center holding container
	
    if (true)
    {
        //Holding container:
        string style = "";
        style += "max-width:" + max_width_setting + "px;padding-top:5px;padding-bottom:0.25em;";
        if (!__setting_fill_vertical)
            style += "background-color:" + __setting_page_background_color + ";";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
        {
            style += "border:1px solid;border-top:0px;border-bottom:1px solid;";
            style += "border-color:" + __setting_line_color + ";";
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
        line += HTMLGenerateTagWrap("a", "<br>Written by Ezandora.", mapMake("class", "r_a_undecorated", "href", "showplayer.php?who=1557284", "target", "mainpane"));
        line += "<br>" + __version;
        
        PageWrite(HTMLGenerateDivOfStyle(line, "font-size:0.777em;color:gray;"));
    }
    
	PageWrite("</div>");
	PageWrite("</div>");
	if (displaying_navbar) //in-div spacing at bottom for navbar
		PageWrite(HTMLGenerateDivOfStyle("", "height:" + (__setting_navbar_height_in_em - 0.05) + "em;"));
    
    if (__setting_fill_vertical)
    {
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-1;background-color:" + __setting_page_background_color + ";max-width:" + __setting_horizontal_width + "px;"))); //Color fill
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-11;border-left:1px solid;border-right:1px solid;border-color:" + __setting_line_color + ";width:" + (__setting_horizontal_width) + "px;"))); //Vertical border lines, empty background
    }
    PageWriteHead("<script type=\"text/javascript\" src=\"relay_Guide.js\"></script>");
    
    if (output_body_tag_only)
    	write(__global_page.body_contents);
    else
		PageGenerateAndWriteOut();
}

void main()
{
    runMain(__FILE__);
}