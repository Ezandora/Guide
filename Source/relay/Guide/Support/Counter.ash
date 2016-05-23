import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Math.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Support/Holiday.ash"

Record Counter
{
    string name;
    string location_id; //number or *
    string [int] mafia_gifs;
    int [int] exact_turns; //sorted order
    int range_start_turn;
    int range_end_turn;
    boolean found_start_turn_range;
    boolean found_end_turn_range;
    
    boolean initialised;
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
        if (c.range_start_turn <= turns_limit)
            return true;
        else
            return false;
    }
    else if (c.found_end_turn_range)
        return true; //maaaybe?
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
        return "Uninitialised".to_buffer();
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


Counter [string] __active_counters; //Try to avoid referencing directly

Counter CounterLookup(string counter_name, Error found)
{
    if (__active_counters contains counter_name)
    {
        return __active_counters[counter_name];
    }
    else
    {
        found.ErrorSet();
        return CounterMake();
    }
}

Counter CounterLookup(string counter_name)
{
    return CounterLookup(counter_name, ErrorMake());
}

string [int] CounterGetAllNames()
{
    string [int] names;
    foreach name in __active_counters
        names.listAppend(name);
    return names;
}


boolean __counters_inited = false;
void CountersInit()
{
    if (__counters_inited)
        return;
    __counters_inited = true;


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
    
	string counter_string = get_property("relayCounters");
	string [int] counter_split = split_string(counter_string, ":");
    
    if (true)
    {
        //Parse counters:
        for i from 0 to (counter_split.count() - 1) by 3
        {
            if (i + 3 > counter_split.count())
                break;
            if (counter_split[i].length() == 0)
                continue;
            int turn_number = to_int_silent(counter_split[i]);
            int turns_until_counter = turn_number - my_turncount();
            string counter_name_raw = counter_split[i + 1];
            string counter_gif = counter_split[i + 2];
            string location_id;
            string intermediate_name = counter_name_raw;
            
            //Parse loc, remove it from intermediate name:
            
            string [int][int] location_match = group_string(intermediate_name, " loc=([0-9*]*)");
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
            }
            
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
            final_name = final_name.HTMLEscapeString();
            
            //Now create and edit our counter:
            
            Counter c = CounterMake();
            if (__active_counters contains final_name)
                c = __active_counters[final_name];
            
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
                if (turns_until_counter >= 0)
                {
                    c.exact_turns.listAppend(turns_until_counter);
                    sort c.exact_turns by value;
                }
            }
            
            __active_counters[final_name] = c;
        }
    }
}

void CountersReparse()
{
    __counters_inited = false;
    foreach key in __active_counters
    {
        remove __active_counters[key];
    }
    CountersInit();
}

boolean [string] __wandering_monster_counter_names = $strings[Romantic Monster,Rain Monster,Holiday Monster,Nemesis Assassin,Bee,WoL Monster];


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


boolean CounterWanderingMonsterMayHitInXTurns(int turns)
{
    if (CounterWanderingMonsterMayHitNextTurn())
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

boolean CounterWanderingMonsterWillHitNextTurn()
{
    if (!CounterWanderingMonsterMayHitNextTurn())
        return false;
    foreach key, c in CounterWanderingMonsterWindowsActiveNextTurn()
    {
        Vec2i range = c.CounterGetWindowRange();
        if (range.y <= 0)
            return true;
        if (c.CounterWillHitExactlyInTurnRange(0, 0))
            return true;
    }
    return false;
}

CountersInit();