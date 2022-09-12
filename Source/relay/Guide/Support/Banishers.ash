
import "relay/Guide/Support/Library.ash"

//maybe rename this to ActiveBanish?
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
    __banish_source_length["saber force"] = 30;
    
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
        if (my_path_id_legacy() == PATH_ONE_CRAZY_RANDOM_SUMMER)
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





//Banish sources, used for writing active banish code:

int BANISH_SOURCE_TYPE_UNKNOWN = 0;
int BANISH_SOURCE_TYPE_COMBAT_ITEM = 1;
int BANISH_SOURCE_TYPE_SKILL = 2;

Record BanishSource
{
	//private:
	item required_equipment_equipped;
	item combat_item_source;
	skill combat_skill;
	string name;
	
	//reflex hammer does not support .dailylimit, so we will not use that approach:
	string daily_limit_property_name;
	int daily_limit_property_limit;
};

BanishSource [int] __banish_sources;


void add(BanishSource [int] list, BanishSource entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


void initialiseBanishSources()
{
	if (true)
	{
		BanishSource source;
        source.combat_skill = $skill[Feel Hatred];
        source.daily_limit_property_name = "_feelHatredUsed";
        source.daily_limit_property_limit = 3;
        __banish_sources.add(source);
	}
	if (true)
	{
		BanishSource source;
        source.combat_skill = $skill[reflex hammer];
        source.required_equipment_equipped = $item[Lil' Doctor&trade; bag];
        source.daily_limit_property_name = "_reflexHammerUsed";
        source.daily_limit_property_limit = 3;
        __banish_sources.add(source);
	}
	//Throw Latte on Opponent
	//KGB tranquilizer dart
	//snokebomb
	//use the force, but no?
}

initialiseBanishSources();



int BanishSourceReplenishableBanishesLeft(BanishSource source)
{
	int amount = 0;
	if (source.daily_limit_property_name != "")
	{
		int value = get_property_int(source.daily_limit_property_name);
        amount += clampi(source.daily_limit_property_limit - value, 0, source.daily_limit_property_limit);
	}
	return amount;
}

int BanishSourceLimitedBanishesLeft(BanishSource source)
{
	if (source.combat_item_source != $item[none])
		return source.combat_item_source.item_amount();
	return 0;
}

int BanishSourceAllBanishesLeft(BanishSource source)
{
	return source.BanishSourceReplenishableBanishesLeft() + source.BanishSourceLimitedBanishesLeft();
}

boolean BanishSourceIsLimited(BanishSource source)
{
	//more?
	if (source.combat_item_source != $item[none]) return true;
	return false;
}

boolean BanishSourceCanBanishRightNow(BanishSource source)
{
	if (source.required_equipment_equipped != $item[none] && !source.required_equipment_equipped.equipped())
		return false;
    if (source.combat_item_source != $item[none] && source.combat_item_source.item_amount() == 0)
    	return false;
    //if (my_mp() < combat_skill
    if (source.combat_skill != $skill[none])
    {
    	if (!source.combat_skill.skill_is_usable()) return false;
        if (my_mp() < source.combat_skill.mp_cost()) return false; //FIXME I can't remember if combat_mana_cost_modifier() needs manually tinkering here
    }
    
    if (source.BanishSourceAllBanishesLeft() == 0) return false;
    
	return true;
}

boolean BanishSourceCouldBanish(BanishSource source)
{
	if (source.required_equipment_equipped != $item[none] && !source.required_equipment_equipped.have()) return false;
	if (source.combat_item_source != $item[none] && source.combat_item_source.item_amount() == 0) return false;
	if (source.combat_skill != $skill[none] && !source.combat_skill.skill_is_usable())
	{
		return false;
    }
	
	if (source.BanishSourceAllBanishesLeft() == 0) return false;
	return true;
}

int BanishSourceGetType(BanishSource source)
{
	if (source.combat_skill != $skill[none]) return BANISH_SOURCE_TYPE_SKILL;
	if (source.combat_item_source != $item[none]) return BANISH_SOURCE_TYPE_COMBAT_ITEM;
	
	return BANISH_SOURCE_TYPE_UNKNOWN;
}

skill BanishSourceGetSkill(BanishSource source)
{
	return source.combat_skill;
}

item BanishSourceGetCombatItem(BanishSource source)
{
	return source.combat_item_source;
}

item BanishSourceGetEquipmentRequiredEquipped(BanishSource source)
{
	return source.required_equipment_equipped;
}

string BanishSourceGetName(BanishSource source)
{
	if (source.name != "")
		return source.name;
    else if (source.combat_skill != $skill[none])
    	return source.combat_skill;
    else if (source.combat_item_source != $item[none])
    	return source.combat_item_source;
    return "";
}


BanishSource GetBanishSourceByName(string name)
{
	foreach key, source in __banish_sources
	{
		if (source.BanishSourceGetName() ≈ name)
        	return source;
	}
	BanishSource blank;
	return blank;
}
