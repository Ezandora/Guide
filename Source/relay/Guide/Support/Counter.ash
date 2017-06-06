import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Math.ash"
import "relay/Guide/Support/Library.ash"

Record Counter
{
    string name;
    string location_id; //number or *
    string mafia_informed_type; //"wander" seen
    string [int] mafia_gifs;
    int [int] exact_turns; //sorted order
    int range_start_turn;
    int range_end_turn;
    boolean found_start_turn_range;
    boolean found_end_turn_range;
    
    boolean initialised;
    boolean waiting_for_adventure_php;
};

Counter CounterMake()
{
    Counter c;
    c.range_start_turn = -1;
    c.range_end_turn = -1;
    c.initialised = true;
    
    return c;
}

//If false, use exact_turns. If true, range_start_turn/range_end_turn. (this isn't ideal, sorry)
boolean CounterIsRange(Counter c)
{
    if (!c.initialised)
        return false;
    //if (c.range_start_turn < 0 && c.range_end_turn < 0) //seems to be an errornous test when we go past our window
        //return false;
    if (c.exact_turns.count() == 0 && (c.found_start_turn_range || c.found_end_turn_range))
        return true;
    return false;
}

int CounterGetNextExactTurn(Counter c)
{
    if (!c.initialised)
        return -1;
    if (c.CounterIsRange())
        return -1;
    if (c.exact_turns.count() == 0)
        return -1;
    return c.exact_turns[0];
    
}

boolean CounterMayHitNextTurn(Counter c)
{
    //FIXME use CounterMayHitInXTurns to implement this once we're sure it works
    if (!c.initialised)
        return false;
    if (c.exact_turns.count() > 0)
    {
        foreach key, turn in c.exact_turns
        {
            if (turn == 0)
                return true;
        }
        return false;
    }
    else if (!c.found_start_turn_range && !c.found_end_turn_range)
    {
        return false;
    }
    //turn range:
    else if (c.found_start_turn_range)
    {
        if (c.range_start_turn <= 0)
            return true;
        else
            return false;
    }
    else if (c.found_end_turn_range)
        return true; //maaaybe?
    return false;
}

boolean CounterMayHitInXTurns(Counter c, int turns_limit)
{
    if (!c.initialised)
        return false;
    if (c.exact_turns.count() > 0)
    {
        foreach key, turn in c.exact_turns
        {
            if (turn <= turns_limit)
                return true;
        }
        return false;
    }
    else if (!c.found_start_turn_range && !c.found_end_turn_range)
    {
        return false;
    }
    //turn range:
    else if (c.found_start_turn_range)
    {
        if (c.range_start_turn <= turns_limit && c.range_end_turn >= 0)
            return true;
        else
            return false;
    }
    else if (c.found_end_turn_range && c.range_end_turn >= 0)
    {
        return true; //maaaybe?
    }
    return false;
}

Vec2i CounterGetWindowRange(Counter c) //x is min, y is max
{
    if (!c.CounterIsRange())
        return Vec2iMake(-1, -1);
    return Vec2iMake(c.range_start_turn, c.range_end_turn);
}

//DOES NOT HANDLE COUNTER RANGES:
boolean CounterWillHitExactlyInTurnRange(Counter c, int start_turn_range, int end_turn_range)
{
    if (!c.initialised)
        return false;
    
    Vec2i turn_range = Vec2iMake(start_turn_range, end_turn_range);
    
    foreach key in c.exact_turns
    {
        int turn = c.exact_turns[key];
        if (turn_range.Vec2iValueInRange(turn))
            return true;
    }
    return false;
}

boolean CounterWillHitNextTurn(Counter c)
{
    if (c.CounterIsRange())
    {
        Vec2i range = c.CounterGetWindowRange();
        if (range.y <= 0)
            return true;
    }
    if (c.CounterWillHitExactlyInTurnRange(0, 0))
        return true;
    return false;
}


boolean CounterExists(Counter c)
{
    if (!c.initialised)
        return false;
    if (c.CounterIsRange())
        return true;
    if (c.exact_turns.count() > 0)
        return true;
    return false;
}

buffer CounterDescription(Counter c)
{
    if (!c.initialised)
    {
        return "Uninitialised".to_buffer();
    }
    buffer description;
    description.append(c.name);
    if (!c.CounterExists())
        description.append(" (invalid)");
    if (c.location_id != "")
    {
        description.append(" (location ");
        description.append(c.location_id);
        description.append(")");
    }
    if (c.mafia_gifs.count() > 0)
    {
        description.append(" (gif ");
        description.append(c.mafia_gifs.listJoinComponents(", ", "and"));
        description.append(")");
    }
    description.append(" in ");
    if (c.CounterIsRange())
    {
        description.append("[");
        description.append(c.range_start_turn);
        description.append(", ");
        description.append(c.range_end_turn);
        description.append("]");
    }
    else
    {
        description.append(c.exact_turns.listJoinComponents(", ", "or"));
    }
    description.append(" turns");
    return description;
}


void CountersParseProperty(string property_name, Counter [string] counters, boolean are_temp_counters)
{
    foreach key in counters
    {
        remove counters[key];
    }
    
	string counter_string = get_property(property_name);
    /*_tempRelayCounters uses | as a separator, relayCounters does not:
> get _tempRelayCounters

15:Romantic Monster window begin loc=*:lparen.gif|25:Romantic Monster window end loc=* type=wander:rparen.gif|7:Digitize Monster loc=* type=wander:watch.gif|7:Digitize Monster loc=* type=wander:watch.gif|7:Digitize Monster loc=* type=wander:watch.gif|

> get relayCounters

70:Semirare window begin:lparen.gif:80:Semirare window end loc=*:rparen.gif
    */
	string [int] counter_split = split_string(counter_string.replace_string("|", ":"), ":"); //FIXME | properly
    //print_html("counter_split = " + counter_split.to_json());
    //Parse counters:
    for i from 0 to (counter_split.count() - 1) by 3
    {
        if (i + 3 > counter_split.count())
            break;
        if (counter_split[i].length() == 0)
            continue;
        int turn_number = to_int_silent(counter_split[i]);
        if (are_temp_counters)
            turn_number += my_turncount();
        int turns_until_counter = turn_number - my_turncount();
        string counter_name_raw = counter_split[i + 1];
        string counter_gif = counter_split[i + 2];
        string location_id;
        string type;
        string intermediate_name = counter_name_raw;
        //print_html("intermediate_name = " + intermediate_name + ", turn_number = " + turn_number + ", turns_until_counter = " + turns_until_counter);
        
        //Parse loc, remove it from intermediate name:
        //loc=* type=wander
        
        string [string] set_properties;
        
        string [int][int] properties_found = intermediate_name.group_string(" ([^= ]*)=([^ ]*)");
        //print_html("intermediate_name = " + intermediate_name + " properties_found = " + properties_found.to_json());
        
        foreach key in properties_found
        {
            string entire_match = properties_found[key][0];
            set_properties[properties_found[key][1]] = properties_found[key][2];
            intermediate_name = intermediate_name.replace_string(entire_match, "");
        }
        if (set_properties contains "loc")
            location_id = set_properties["loc"];
        if (set_properties contains "type")
            type = set_properties["type"];
        
        /*string [int][int] location_match = group_string(intermediate_name, " loc=([0-9*]*)");
        if (location_match.count() > 0)
        {
            location_id = location_match[0][1];
            string end_string = " loc=" + location_id;
            if (intermediate_name.stringHasSuffix(end_string))
            {
                int clip_pos = intermediate_name.length() - end_string.length();
                if (clip_pos > 0)
                    intermediate_name = intermediate_name.substring(0, clip_pos);
                else
                    intermediate_name = "";
            }
        }*/
        
        boolean is_window_start = false;
        boolean is_window_end = false;
        //Convert intermediate name to our internal representation:
        if (intermediate_name.contains_text("window begin"))
        {
            //generic window
            intermediate_name = intermediate_name.substring(0, intermediate_name.index_of(" window begin"));
            is_window_start = true;
        }
        else if (intermediate_name.contains_text("window end"))
        {
            //generic window
            intermediate_name = intermediate_name.substring(0, intermediate_name.index_of(" window end"));
            is_window_end = true;
        }
        
        
        string final_name = intermediate_name;
        if (intermediate_name == "Fortune Cookie" || intermediate_name.stringHasPrefix("Semirare"))
        {
            final_name = "Semi-rare";
        }
        final_name = final_name.entity_encode();
        
        //Now create and edit our counter:
        
        Counter c = CounterMake();
        if (counters contains final_name)
            c = counters[final_name];
        if (are_temp_counters)
            c.waiting_for_adventure_php = true;
        
        c.name = final_name;
        boolean should_add_gif = true;
        if (c.mafia_gifs.count() > 0)
        {
            foreach key in c.mafia_gifs
            {
                if (c.mafia_gifs[key] == counter_gif)
                    should_add_gif = false;
            }
        }
        if (should_add_gif)
            c.mafia_gifs.listAppend(counter_gif);
        c.location_id = location_id;
        c.mafia_informed_type = type;
        
        if (is_window_start)
        {
            c.range_start_turn = turns_until_counter;
            if (!c.found_end_turn_range) //haven't found an end turn range - implicitly set it to the start
                c.range_end_turn = turns_until_counter;
            c.found_start_turn_range = true;
        }
        else if (is_window_end)
        {
            c.range_end_turn = turns_until_counter;
            c.found_end_turn_range = true;
        }
        else
        {
            if (c.name == "Dance Card" && turns_until_counter < 0) //bug: dance card is still in relayCounters after being met
            {
                continue;
            }
            //if (turns_until_counter >= 0)
            if (true)
            {
                if (turns_until_counter >= 0 || c.name != "Semi-Rare")
                    c.exact_turns.listAppend(MAX(0, turns_until_counter));
                sort c.exact_turns by value;
            }
        }
        
        counters[final_name] = c;
    }
}

Counter [string] __active_counters; //Try to avoid referencing directly
Counter [string] __active_temp_counters;

boolean __counters_inited = false;
int __counters_turn_inited = -1;
string __counters_inited_property_value;
void CountersInit()
{
    if (__counters_inited && __counters_turn_inited == my_turncount() && __counters_inited_property_value == get_property("relayCounters"))
        return;
    __counters_inited = true;
    __counters_turn_inited = my_turncount();
    __counters_inited_property_value = get_property("relayCounters");

    //parse counters:
	//Examples:
	//relayCounters(user, now '1378:Fortune Cookie:fortune.gif', default )
	//relayCounters(user, now '1539:Semirare window begin loc=*:lparen.gif:1579:Semirare window end loc=*:rparen.gif', default )
	//relayCounters(user, now '70:Semirare window begin:lparen.gif:80:Semirare window end loc=*:rparen.gif', default )
	//relayCounters(user, now '1750:Romantic Monster window begin loc=*:lparen.gif:1760:Romantic Monster window end loc=*:rparen.gif', default )
    //relayCounters(user, now '7604:Fortune Cookie:fortune.gif:7584:Fortune Cookie:fortune.gif', default )
    //relayCounters(user, now '450:Fortune Cookie:fortune.gif:458:Fortune Cookie:fortune.gif:401:Dance Card loc=109:guildapp.gif', default )
    //relayCounters(user, now '1271:Nemesis Assassin window begin loc=*:lparen.gif:1286:Nemesis Assassin window end loc=*:rparen.gif:1331:Fortune Cookie:fortune.gif', default )
    //relayCounters(user, now '695:Nemesis Assassin window begin loc=*:lparen.gif:710:Nemesis Assassin window end loc=*:rparen.gif:780:Fortune Cookie:fortune.gif:685:Dance Card loc=109:guildapp.gif', default )
    //70:Semirare window begin:lparen.gif:80:Semirare window end loc=*:rparen.gif:57:Digitize Monster:watch.gif:57:Romantic Monster window begin loc=*:lparen.gif:67:Romantic Monster window end loc=*:rparen.gif
    
    foreach key in __active_counters
    {
        remove __active_counters[key];
    }
    foreach key in __active_temp_counters
    {
        remove __active_temp_counters[key];
    }
    CountersParseProperty("relayCounters", __active_counters, false);
    CountersParseProperty("_tempRelayCounters", __active_temp_counters, true);
    
    //print_html("__active_counters = " + __active_counters.to_json());
    
}

Counter CounterLookup(string counter_name, Error found, boolean allow_temp_counters)
{
    CountersInit();
    if (__active_counters contains counter_name)
    {
        return __active_counters[counter_name];
    }
    else if (allow_temp_counters && __active_temp_counters contains counter_name)
    {
        return __active_temp_counters[counter_name];
    }
    else
    {
        found.ErrorSet();
        return CounterMake();
    }
}


Counter CounterLookup(string counter_name, Error found)
{
    return CounterLookup(counter_name, found, false);
}

Counter CounterLookup(string counter_name, boolean allow_temp_counters)
{
    return CounterLookup(counter_name, ErrorMake(), allow_temp_counters);
}

Counter CounterLookup(string counter_name)
{
    return CounterLookup(counter_name, ErrorMake());
}

string [int] CounterGetAllNames(boolean allow_temp_counters)
{
    string [int] names;
    foreach name in __active_counters
        names.listAppend(name);
    if (allow_temp_counters)
    {
        foreach name in __active_temp_counters
            names.listAppend(name);
    }
    return names;
}

string [int] CounterGetAllNames()
{
    return CounterGetAllNames(false);
}

void CountersReparse()
{
    __counters_inited = false;
    CountersInit();
}



boolean [string] __wandering_monster_counter_names = $strings[Romantic Monster,Rain Monster,Holiday Monster,Nemesis Assassin,Bee,WoL Monster,Digitize Monster,Enamorang Monster];
string [string] __wandering_monster_property_lookups {"Romantic Monster":"romanticTarget", "Digitize Monster": "_sourceTerminalDigitizeMonster", "Enamorang Monster":"enamorangMonster"};

//This is for ascension automation scripts. Call this immediately before adventuring in an adventure.php zone.
//This will enable tracking of zero-adventure encounters that mean a wandering monster will not appear next turn. Affects CounterWanderingMonsterMayHitNextTurn() only.
int __last_turn_definitely_visited_adventure_php = -1;
void CounterAdviseAboutToVisitAdventurePHP()
{
    __last_turn_definitely_visited_adventure_php = my_turncount();
}

void CounterAdviseLastTurnAttemptedAdventurePHP(int turn)
{
    __last_turn_definitely_visited_adventure_php = turn;
}

boolean CounterWanderingMonsterMayHitNextTurn()
{
    monster last_monster = get_property_monster("lastEncounter");
    
    if (my_path_id() == PATH_THE_SOURCE)
    {
        int interval = get_property_int("sourceInterval");
        if (interval == 200 || interval == 400)
            return true;
    }
    if (get_property("questG04Nemesis") == "step17") //first wanderer in nemesis quest
        return true;
    
    if (__last_turn_definitely_visited_adventure_php == -1 && $monsters[Black Crayon Beast,Black Crayon Beetle,Black Crayon Constellation,Black Crayon Golem,Black Crayon Demon,Black Crayon Man,Black Crayon Elemental,Black Crayon Crimbo Elf,Black Crayon Fish,Black Crayon Goblin,Black Crayon Hippy,Black Crayon Hobo,Black Crayon Shambling Monstrosity,Black Crayon Manloid,Black Crayon Mer-kin,Black Crayon Frat Orc,Black Crayon Penguin,Black Crayon Pirate,Black Crayon Flower,Black Crayon Slime,Black Crayon Undead Thing,Black Crayon Spiraling Shape,angry bassist,blue-haired girl,evil ex-girlfriend,peeved roommate,random scenester] contains last_monster) //bit of a hack - if they just fought a hipster monster (hopefully not faxing it), then the wandering monster isn't up this turn. though... __last_turn_definitely_visited_adventure_php should handle that...
    {
        return false;
    }
    if (my_turncount() == __last_turn_definitely_visited_adventure_php && __last_turn_definitely_visited_adventure_php != -1) //that adventure didn't advance the counter; no wandering monsters. also, does lights out override wanderers? but, what if there are TWO wandering monsters? the plot thickens
    {
        string last_encounter = get_property("lastEncounter");
        if (!($strings[Lights Out,Wooof! Wooooooof!,Playing Fetch*,Your Dog Found Something Again,Gunbowwowder,Seeing-Eyes Dog] contains last_encounter))
            return false;
    }
    //FIXME use CounterWanderingMonsterMayHitInXTurns to implement this once we're sure it works
    foreach s in __wandering_monster_counter_names
    {
        if (s == "Romantic Monster" && get_property_int("_romanticFightsLeft") == 0) //If mafia's tracking doesn't recognise the monster, then we can override by decrementing the romantic fights left. Added because of the machine elf tunnels.
            continue;
        Counter c = CounterLookup(s);
        if (c.CounterExists() && c.CounterMayHitNextTurn())
        {
            return true;
        }
    }
    if (get_property_int("_romanticFightsLeft") > 0 && !CounterLookup("Romantic Monster").CounterExists() && my_path_id() != PATH_ONE_CRAZY_RANDOM_SUMMER) //mafia will clear the romantic monster window if it goes out of bounds
        return true;
    
    //Disabled for now, because this is hard to predict:
    /*boolean [string] holidays = getHolidaysToday();
    foreach s in $strings[Feast of Boris,El Dia de Los Muertos Borrachos]
    {
        if (!holidays[s]) continue;
        if (!CounterLookup("Holiday Monster").CounterExists())
        {
            return true;
        }
    }*/
    return false;
}

//only_detect_by_counter_names or in other words "not source agents", which we use in exactly one place for an obscure situation.
boolean CounterWanderingMonsterMayHitInXTurns(int turns, boolean only_detect_by_counter_names)
{
    if (CounterWanderingMonsterMayHitNextTurn() && !only_detect_by_counter_names)
        return true;
    foreach s in __wandering_monster_counter_names
    {
        if (CounterLookup(s).CounterExists() && CounterLookup(s).CounterMayHitInXTurns(turns))
            return true;
    }
    //if (get_property_int("_romanticFightsLeft") > 0 && !CounterLookup("Romantic Monster").CounterExists() && my_path_id() != PATH_ONE_CRAZY_RANDOM_SUMMER) //mafia will clear the romantic monster window if it goes out of bounds
        //return true;
    return false;
}
boolean CounterWanderingMonsterMayHitInXTurns(int turns)
{
    return CounterWanderingMonsterMayHitInXTurns(turns, false);
}

boolean CounterWanderingMonsterWillHitInXTurns(int turns)
{
    //CounterWillHitExactlyInTurnRange
    foreach s in __wandering_monster_counter_names
    {
        if (CounterLookup(s).CounterExists() && CounterLookup(s).CounterWillHitExactlyInTurnRange(0, turns))
            return true;
    }
    return false;
}

Counter [int] CounterWanderingMonsterWindowsActiveInXTurns(int turns)
{
    Counter [int] result;
    foreach s in __wandering_monster_counter_names
    {
        Counter c = CounterLookup(s);
        if (c.CounterExists() && c.CounterMayHitInXTurns(turns))
            result[result.count()] = c;
    }
    return result;
}

Counter [int] CounterWanderingMonsterWindowsActiveNextTurn()
{
    Counter [int] result;
    if (!CounterWanderingMonsterMayHitNextTurn())
        return result;
    foreach s in __wandering_monster_counter_names
    {
        Counter c = CounterLookup(s);
        if (c.CounterExists() && c.CounterMayHitNextTurn())
            result[result.count()] = c;
    }
    return result;
}

boolean [monster] CounterWanderingMonstersActiveNextTurn()
{
    boolean [monster] result;
    foreach key, c in CounterWanderingMonsterWindowsActiveNextTurn()
    {
        if (__wandering_monster_property_lookups contains c.name)
            result[get_property_monster(__wandering_monster_property_lookups[c.name])] = true;
        //result
    }
    //FIXME determine Rain Monster,Holiday Monster,Nemesis Assassin,Bee,WoL Monster
    return result;
}

boolean [monster] CounterWanderingMonstersActiveInXTurns(int turns)
{
    boolean [monster] result;
    foreach key, c in CounterWanderingMonsterWindowsActiveInXTurns(turns)
    {
        if (__wandering_monster_property_lookups contains c.name)
            result[get_property_monster(__wandering_monster_property_lookups[c.name])] = true;
        //result
    }
    //FIXME determine Rain Monster,Holiday Monster,Nemesis Assassin,Bee,WoL Monster
    return result;
}

boolean CounterWanderingMonsterCountersHaveRange()
{
    foreach s in __wandering_monster_counter_names
    {
        Counter c = CounterLookup(s);
        if (!c.CounterExists())
            continue;
        if (c.CounterIsRange())
            return true;
    }
    return false;
}


boolean CounterWanderingMonsterWillHitNextTurn()
{
    if (!CounterWanderingMonsterMayHitNextTurn())
        return false;
    foreach key, c in CounterWanderingMonsterWindowsActiveNextTurn()
    {
        if (c.CounterWillHitNextTurn())
            return true;
    }
    return false;
}

CountersInit();
