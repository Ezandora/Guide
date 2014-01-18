import "relay/Guide/Support/Math.ash"
import "relay/Guide/Support/List.ash"

//Additions to standard API:
//Auto-conversion property functions:
boolean get_property_boolean(string property)
{
	return to_boolean(get_property(property));
}

int get_property_int(string property)
{
	return to_int_silent(get_property(property));
}

location get_property_location(string property)
{
	return to_location(get_property(property));
}

float get_property_float(string property)
{
	return to_float(get_property(property));
}

buffer to_buffer(string str)
{
	buffer result;
	result.append(str);
	return result;
}

//Similar to have_familiar, except it also checks trendy (not sure if have_familiar supports trendy) and 100% familiar runs
boolean familiar_is_usable(familiar f)
{
	int single_familiar_run = get_property_int("singleFamiliarRun");
	if (single_familiar_run != -1 && my_turncount() >= 30) //after 30 turns, they're probably sure
	{
		if (f == single_familiar_run.to_familiar())
			return true;
		return false;
	}
	if (my_path() == "Trendy")
	{
		if (!is_trendy(f))
			return false;
	}
	else if (my_path() == "Bees Hate You")
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

//Prevent a write to disk if nothing's changing:
//(not sure if mafia checks this internally)
void set_property_if_changed(string property, string value)
{
    if (get_property(property) == value)
        return;
    set_property(property, value);
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

item [int] missingComponentsToMakeItem(item it)
{
	item [int] result;
	if (creatable_amount(it) > 0)
    return result;
	int [item] ingredients = get_ingredients(it);
	if (ingredients.count() == 0)
    result.listAppend(it);
	foreach ingredient in ingredients
	{
		int amounted_needed = ingredients[ingredient];
		if (creatable_amount(ingredient) + ingredient.available_amount() >= amounted_needed) //have enough
        continue;
		//split:
		item [int] r = missingComponentsToMakeItem(ingredient);
		result.listAppendList(r);
	}
	return result;
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

string lastNoncombatInLocation(location place)
{
    if (place.noncombat_queue.length() > 0)
        return place.noncombat_queue.split_string("; ").listLastObject();
    return "";
}

string lastCombatInLocation(location place)
{
    if (place.noncombat_queue.length() > 0)
        return place.combat_queue.split_string("; ").listLastObject();
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
    if ($locations[Guano Junction,the Batrat and Ratbat Burrow,the Beanbat Chamber] contains l)
    {
        //bit hacky:
        source_altered[$monster[screambat]] = 1.0 / 8.0;
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