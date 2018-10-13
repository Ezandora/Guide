
import "relay/Guide/Support/Library.ash"

Record Banish
{
    monster banished_monster;
    string banish_source;
    int turn_banished;
    int banish_turn_length;
    string custom_reset_conditions;
};

void listAppend(Banish [int] list, Banish entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

int BanishTurnsLeft(Banish b)
{
    if (b.banish_turn_length == -1)
        return 2147483647;
    return b.turn_banished + b.banish_turn_length - my_turncount();
}

static
{
    int [string] __banish_source_length;
    //FIXME request this be exposed in ASH?
    //all of these must be lowercase. because.
    __banish_source_length["banishing shout"] = -1;
    __banish_source_length["batter up!"] = -1;
    __banish_source_length["chatterboxing"] = 20;
    __banish_source_length["classy monkey"] = 20;
    __banish_source_length["cocktail napkin"] = 20;
    __banish_source_length["crystal skull"] = 20;
    __banish_source_length["deathchucks"] = -1;
    __banish_source_length["dirty stinkbomb"] = -1;
    __banish_source_length["divine champagne popper"] = 5;
    __banish_source_length["harold's bell"] = 20;
    __banish_source_length["howl of the alpha"] = -1;
    __banish_source_length["ice house"] = -1;
    __banish_source_length["louder than bomb"] = 20;
    __banish_source_length["nanorhino"] = -1;
    __banish_source_length["pantsgiving"] = 30;
    __banish_source_length["peel out"] = -1;
    __banish_source_length["pulled indigo taffy"] = 40;
    __banish_source_length["smoke grenade"] = 20;
    __banish_source_length["spooky music box mechanism"] = -1;
    __banish_source_length["staff of the standalone cheese"] = -1;
    __banish_source_length["stinky cheese eye"] = 10;
    __banish_source_length["thunder clap"] = 40;
    __banish_source_length["v for vivala mask"] = 10;
    __banish_source_length["walk away from explosion"] = 30;
    __banish_source_length["tennis ball"] = 30;
    __banish_source_length["curse of vacation"] = -1;
    __banish_source_length["ice hotel bell"] = -1;
    __banish_source_length["bundle of &quot;fragrant&quot; herbs"] = -1;
    __banish_source_length["snokebomb"] = 30;
    __banish_source_length["beancannon"] = -1;
    __banish_source_length["kgb tranquilizer dart"] = 20;
    __banish_source_length["spring-loaded front bumper"] = 30;
    __banish_source_length["mafia middle finger ring"] = 60;
    __banish_source_length["throw latte on opponent"] = 30; //Throw Latte on Opponent
    
    int [string] __banish_simultaneous_limit;
    __banish_simultaneous_limit["beancannon"] = 5;
    __banish_simultaneous_limit["banishing shout"] = 3;
    __banish_simultaneous_limit["howl of the alpha"] = 3;
    __banish_simultaneous_limit["staff of the standalone cheese"] = 5;
}

Banish [int] __banishes_active_cache;
string __banishes_active_cache_cached_monsters_string;

Banish [int] BanishesActive()
{
    //banishedMonsters(user, now 'a.m.c. gremlin:ice house:2890', default )
    
    string banished_monsters_string = get_property("banishedMonsters");
    
    if (banished_monsters_string == __banishes_active_cache_cached_monsters_string && __banishes_active_cache_cached_monsters_string != "")
        return __banishes_active_cache;
    
    __banishes_active_cache_cached_monsters_string = ""; //invalidate the cache
    
    Banish [int] result;
    
    string [int] banished_monsters_string_split = banished_monsters_string.split_string(":");

    foreach key, s in banished_monsters_string_split
    {
        if (s.length() == 0)
            continue;
        if (key % 3 != 0)
            continue;
        //string [int] entry = s.split_string(":");
        
        //if (entry.count() != 3)
            //continue;
        if (!(banished_monsters_string_split contains (key + 1)) || !(banished_monsters_string_split contains (key + 2)))
            continue;
        
        Banish b;
        b.banished_monster = banished_monsters_string_split[key + 0].to_monster();
        b.banish_source = banished_monsters_string_split[key + 1];
        b.turn_banished = banished_monsters_string_split[key + 2].to_int();
        b.banish_turn_length = 0;
        if (__banish_source_length contains b.banish_source.to_lower_case())
            b.banish_turn_length = __banish_source_length[b.banish_source.to_lower_case()];
        if (b.banish_source == "batter up!" || b.banish_source == "deathchucks" || b.banish_source == "dirty stinkbomb" || b.banish_source == "nanorhino" || b.banish_source == "spooky music box mechanism" || b.banish_source == "ice hotel bell" || b.banish_source == "beancannon")
            b.custom_reset_conditions = "rollover";
        if (b.banish_source == "ice house" && (!$item[ice house].is_unrestricted() || in_bad_moon())) //not relevant
            continue;
        result.listAppend(b);
    }
    
    __banishes_active_cache_cached_monsters_string = banished_monsters_string;
    __banishes_active_cache = result;
    
    return result;
}


Banish [int] BanishesActiveInLocation(location l)
{
    boolean [monster] location_monsters;
    foreach key, m in l.get_monsters()
        location_monsters[m] = true;
    Banish [int] banishes_active = BanishesActive();
    Banish [int] result;
    foreach key, b in banishes_active
    {
        if (location_monsters contains b.banished_monster)
            result.listAppend(b);
    }
    return result;
}

int BanishShortestBanishForLocation(location l)
{
    Banish [int] active_banishes = BanishesActiveInLocation(l);
    int minimum = 2147483647;
    foreach key, b in active_banishes
    {
        minimum = MIN(minimum, b.BanishTurnsLeft());
    }
    return minimum;
}

Banish BanishForMonster(monster m)
{
    foreach key, b in BanishesActive()
    {
        if (b.banished_monster == m)
            return b;
    }
    Banish blank;
    return blank;
}

string BanishSourceForMonster(monster m)
{
    return BanishForMonster(m).banish_source;
}

int [string] activeBanishNameCountsForLocation(location l)
{
    Banish [int] banishes_active = BanishesActive();
    
    string [monster] names;
    foreach key, banish in banishes_active
    {
        if (banish.banished_monster.is_banished()) //zuko wrote this code
        {
            names[banish.banished_monster] = banish.banish_source;
        }
    }
    
    int [string] banish_name_counts;
    foreach key, m in l.get_monsters()
    {
        if (names contains m)
            banish_name_counts[names[m]] += 1;
        if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
        {
            foreach m2 in names
            {
                if (m2.to_string().to_lower_case().contains_text(m.to_string().to_lower_case())) //FIXME complete hack, wrong, substrings, 1337, etc
                    banish_name_counts[names[m2]] += 1;
            }
        }
    }
    return banish_name_counts;
}

boolean [string] activeBanishNamesForLocation(location l)
{
    boolean [string] result;
    
    foreach banish_name, count in l.activeBanishNameCountsForLocation()
        result[banish_name] = (count > 0);
    return result;
}

Banish BanishByName(string name)
{
    foreach key, banish in BanishesActive()
    {
        if (banish.banish_source == name)
            return banish;
    }
    Banish blank;
    return blank;
}

int BanishLength(string banish_name)
{
    int length = __banish_source_length[banish_name.to_lower_case()];
    if (length < 0)
        length = 2147483647;
    return length;
}

boolean BanishIsActive(string name)
{
    foreach key, banish in BanishesActive()
    {
        if (banish.banish_source == name)
            return true;
    }
    return false;
}
