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
    return b.turn_banished + b.banish_turn_length - my_turncount();
}

static
{
    int [string] __banish_source_length;
    //FIXME request this be exposed in ASH?
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
    __banish_source_length["pulled indigo taffy"] = 20;
    __banish_source_length["smoke grenade"] = 20;
    __banish_source_length["spooky music box mechanism"] = -1;
    __banish_source_length["staff of the standalone cheese"] = -1;
    __banish_source_length["stinky cheese eye"] = 10;
    __banish_source_length["thunder clap"] = 40;
    __banish_source_length["v for vivala mask"] = 10;
    __banish_source_length["walk away from explosion"] = 30;
    __banish_source_length["curse of vacation"] = -1;
}

Banish [int] BanishesActive()
{
    //banishedMonsters(user, now 'a.m.c. gremlin:ice house:2890', default )
    Banish [int] result;
    
    string banished_monsters_string = get_property("banishedMonsters");
    
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
        if (__banish_source_length contains b.banish_source)
            b.banish_turn_length = __banish_source_length[b.banish_source];
        if (b.banish_source == "batter up!" || b.banish_source == "deathchucks" || b.banish_source == "dirty stinkbomb" || b.banish_source == "nanorhino" || b.banish_source == "spooky music box mechanism")
            b.custom_reset_conditions = "rollover";
        result.listAppend(b);
        
    }
    //print("BanishesActive() = " + result.to_json(), "purple");
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


int currentBanishSourceCountForLocation(location l)
{
    /*
    FIXME support all of these:
    
    banishing shout
    batter up!
    chatterboxing
    classy monkey
    cocktail napkin
    crystal skull
    deathchucks
    dirty stinkbomb
    divine champagne popper
    harold's bell
    howl of the alpha
    ice house
    louder than bomb
    nanorhino
    pantsgiving
    peel out
    pulled indigo taffy
    smoke grenade
    spooky music box mechanism
    staff of the standalone cheese
    stinky cheese eye
    thunder clap
    v for vivala mask
    walk away from explosion
    */
    int count = 0;
    boolean [string] banishers_used;
    
    //Banish [int] banishes_active = BanishesActive();
    
    foreach key, m in l.get_monsters()
    {
        if (m.is_banished())
        {
            count += 1;
            banishers_used[m.BanishSourceForMonster()] = true;
        }
    }
    
    if (lookupSkill("curse of vacation").have_skill() && !banishers_used["curse of vacation"])
        count += 1;
    if ($skill[Thunder Clap].have_skill() && my_thunder() >= 40 && !banishers_used["thunder clap"])
        count += 1;
    if ($item[louder than bomb].item_amount() > 0 && !banishers_used["louder than bomb"])
        count += 1;
    if ($item[pantsgiving].equipped_amount() > 0 && get_property_int("_pantsgivingBanish") < 5 && !banishers_used["pantsgiving"])
        count += 1;
    if ($item[smoke grenade].item_amount() > 0 && !banishers_used["smoke grenade"])
        count += 1;
    if (my_class() == $class[seal clubber] && my_fury() >= 5 && $skill[batter up!].have_skill() && !banishers_used["batter up"])
        count += 1;
    if ($skill[walk away from explosion].have_skill() && $effect[Bored With Explosions].have_effect() == 0)
        count += 1;
    
    return count;
}


boolean [string] activeBanishNamesForLocation(location l)
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
    
    boolean [string] banish_names;
    foreach key, m in l.get_monsters()
    {
        if (names contains m)
            banish_names[names[m]] = true;
    }
    return banish_names;
}

int BanishLength(string banish_name)
{
    int length = __banish_source_length[banish_name];
    if (length < 0)
        length = 2147483647;
    return length;
}