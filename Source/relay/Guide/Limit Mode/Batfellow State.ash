

/*zone values:
Bat-Cavern
Somewhere in Gotpork City
Center Park (Low Crime)
Slums (Moderate Crime)
Industrial District (High Crime)
Downtown
*/
//Bat-Investigation Progress appears to be the amount of progress you advance per fight, which upgrades with upgrades.
Record BatState
{
    string zone;
    int funds_available;
    int time_left;
    
    string [string] stats;
    boolean [string] upgrades;
    /*int hp;
    int max_hp;
    int hp_regen;*/
    //FIXME more
};

BatState __batstate;

BatState BatStateMake()
{
    BatState state;
    //Parse:
    state.zone = get_property("batmanZone");
    state.funds_available = get_property_int("batmanFundsAvailable");
    state.time_left = get_property_int("batmanTimeLeft");
    //FIXME upgrades
    
    foreach key, s in get_property("batmanStats").split_string_alternate(";")
    {
        string [int] attribution = s.split_string_alternate("=");
        if (attribution.count() != 2)
            continue;
        state.stats[attribution[0]] = attribution[1];
    }
    foreach key, s in get_property("batmanUpgrades").split_string_alternate(";")
        state.upgrades[s] = true;
    __batstate = state;
    return state;
}


static
{
	location [monster] __batfellow_bosses_to_locations;
	
	void initialiseBatfellowBosses()
	{
		__batfellow_bosses_to_locations[$monster[Kudzu]] = $location[Gotpork Conservatory of Flowers];
        __batfellow_bosses_to_locations[$monster[Mansquito]] = $location[Gotpork Municipal Reservoir];
        __batfellow_bosses_to_locations[$monster[Miss Graves]] = $location[Gotpork Gardens Cemetery];
        
        __batfellow_bosses_to_locations[$monster[The Plumber]] = $location[Gotpork City Sewers];
        __batfellow_bosses_to_locations[$monster[The Author]] = $location[Porkham Asylum];
        __batfellow_bosses_to_locations[$monster[The Mad Libber]] = $location[The Old Gotpork Library];
        
        __batfellow_bosses_to_locations[$monster[Doc Clock]] = $location[Gotpork Clock, Inc.];
        __batfellow_bosses_to_locations[$monster[Mr. Burns]] = $location[Gotpork Foundry];
        __batfellow_bosses_to_locations[$monster[The Inquisitor]] = $location[Trivial Pursuits, LLC];
	}
	initialiseBatfellowBosses();
	
}


Record BatfellowBossArea
{
    location area;
    string short_name;
    string image_name;
    string zone;
    monster boss;
    string [int] strategies;
    int [item] nc_twenty_five_progress_requirements;
    int [item] nc_fifty_progress_requirements;
    int [item] nc_reward_items;
};

BatfellowBossArea BatfellowBossAreaMake()
{
    BatfellowBossArea area;
    return area;
}

static
{
    BatfellowBossArea [location] __batfellow_bosses;
    void initialiseBatfellowBossAreas()
    {
        BatfellowBossArea area = BatfellowBossAreaMake();
        area.area = $location[Gotpork Conservatory of Flowers];
        area.short_name = "Conservatory";
        area.image_name = "sunflower face";
        area.zone = "Center Park (Low Crime)";
        area.boss = $monster[Kudzu];
        area.nc_twenty_five_progress_requirements[$item[glob of Bat-Glue]] = 1;
        area.nc_fifty_progress_requirements[$item[fingerprint dusting kit]] = 3;
        area.nc_reward_items[$item[dangerous chemicals]] = 5;
        __batfellow_bosses[area.area] = area;
        
        area = BatfellowBossAreaMake();
        area.area = $location[Gotpork Municipal Reservoir];
        area.short_name = "Reservoir";
        area.image_name = "__item personal raindrop"; //"__item ketchup hound";
        area.zone = "Center Park (Low Crime)";
        area.boss = $monster[Mansquito];
        area.nc_twenty_five_progress_requirements[$item[Bat-Aid&trade; bandage]] = 1;
        area.nc_fifty_progress_requirements[$item[ultracoagulator]] = 3;
        area.nc_reward_items[$item[kidnapped orphan]] = 5;
        __batfellow_bosses[area.area] = area;
        
        area = BatfellowBossAreaMake();
        area.area = $location[Gotpork Gardens Cemetery];
        area.short_name = "Cemetery";
        area.image_name = "__item grave robbing shovel";
        area.zone = "Center Park (Low Crime)";
        area.boss = $monster[Miss Graves];
        area.nc_twenty_five_progress_requirements[$item[bat-bearing]] = 1;
        area.nc_fifty_progress_requirements[$item[exploding kickball]] = 3;
        area.nc_reward_items[$item[incriminating evidence]] = 5;
        __batfellow_bosses[area.area] = area;
        
        
        area = BatfellowBossAreaMake();
        area.area = $location[Porkham Asylum];
        area.short_name = "Asylum";
        area.image_name = "__item jet bennie marble";
        area.zone = "Slums (Moderate Crime)";
        area.boss = $monster[The Author];
        area.nc_twenty_five_progress_requirements[$item[bat-o-mite]] = 1;
        area.nc_reward_items[$item[high-grade metal]] = 6;
        __batfellow_bosses[area.area] = area;
        
        area = BatfellowBossAreaMake();
        area.area = $location[Gotpork City Sewers];
        area.short_name = "Sewers";
        area.image_name = "__item helmet turtle";
        area.zone = "Slums (Moderate Crime)";
        area.boss = $monster[The Plumber];
        area.nc_twenty_five_progress_requirements[$item[bat-oomerang]] = 1;
        area.nc_reward_items[$item[high-grade explosives]] = 6;
        __batfellow_bosses[area.area] = area;
        
        area = BatfellowBossAreaMake();
        area.area = $location[The Old Gotpork Library];
        area.short_name = "Library";
        area.image_name = "__item very overdue library book";
        area.zone = "Slums (Moderate Crime)";
        area.boss = $monster[The Mad Libber];
        area.nc_twenty_five_progress_requirements[$item[bat-jute]] = 1;
        area.nc_reward_items[$item[high-tensile-strength fibers]] = 6;
        __batfellow_bosses[area.area] = area;
        
        
        area = BatfellowBossAreaMake();
        area.area = $location[Gotpork Clock, Inc.];
        area.short_name = "Clock";
        area.image_name = "__item borrowed time";
        area.zone = "Industrial District (High Crime)";
        area.boss = $monster[Doc Clock];
        area.nc_twenty_five_progress_requirements[$item[exploding kickball]] = 1;
        area.nc_reward_items[$item[kidnapped orphan]] = 6;
        area.nc_reward_items[$item[high-grade explosives]] = 6;
        area.strategies.listAppend("Bat-oomerang the time bandits, to prevent them from stealing time?");
        area.strategies.listAppend("Gain resources from the NC?");
        __batfellow_bosses[area.area] = area;
        
        area = BatfellowBossAreaMake();
        area.area = $location[Gotpork Foundry];
        area.short_name = "Foundry";
        area.image_name = "__item handful of fire";
        area.zone = "Industrial District (High Crime)";
        area.boss = $monster[Mr. Burns];
        area.nc_twenty_five_progress_requirements[$item[ultracoagulator]] = 1;
        area.nc_reward_items[$item[dangerous chemicals]] = 6;
        area.nc_reward_items[$item[high-grade metal]] = 6;
        area.strategies.listAppend("Gain resources from the NC?");
        __batfellow_bosses[area.area] = area;
        
        area = BatfellowBossAreaMake();
        area.area = $location[Trivial Pursuits, LLC];
        area.short_name = "Trivial Company";
        area.image_name = "__item Trivial Avocations Card: What?";
        area.zone = "Industrial District (High Crime)";
        area.boss = $monster[The Inquisitor];
        area.nc_twenty_five_progress_requirements[$item[fingerprint dusting kit]] = 1;
        area.nc_reward_items[$item[incriminating evidence]] = 6;
        area.nc_reward_items[$item[high-tensile-strength fibers]] = 6;
        area.strategies.listAppend("Gain resources from the NC?");
        __batfellow_bosses[area.area] = area;
    }
    initialiseBatfellowBossAreas();
}
