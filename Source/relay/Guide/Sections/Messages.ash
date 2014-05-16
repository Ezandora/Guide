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
        random_messages.listAppend("every spreadsheet you make saves a turn");
    }
    
    string [string] holiday_messages;
    holiday_messages["Groundhog Day"] = "it's cold out there every day";
    holiday_messages["Crimbo"] = "merry crimbo";
    holiday_messages["April Fool's Day"] = "you are ascending too quickly, ascend slower!";
    
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
    

    random_messages.listAppend(HTMLGenerateTagWrap("a", "if you're feeling stressed, play alice's army", generateMainLinkMap("aagame.php")));
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
    //paths[PATH_SLOW_AND_STEADY] = "";
    paths[PATH_OXYGENARIAN] = "the slow path";
    
    if (paths contains my_path_id())
        random_messages.listAppend(paths[my_path_id()]);
    
    random_messages.listAppend("I don't know either, sorry");
    
    string lowercase_player_name = my_name().to_lower_case().HTMLEscapeString();
        
    random_messages.listAppend(HTMLGenerateTagWrap("a", "check the wiki", mapMake("class", "r_a_undecorated", "href", "http://kol.coldfront.net/thekolwiki/index.php/Main_Page", "target", "_blank")));
    random_messages.listAppend("the RNG is only trying to help");
    if (__misc_state["In run"])
        random_messages.listAppend("speed ascension is all I have left, " + lowercase_player_name);
    if (item_drop_modifier() <= -100.0)
        random_messages.listAppend("let go of your material posessions");
    if ($item[puppet strings].storage_amount() + $item[puppet strings].available_amount() > 0)
        random_messages.listAppend(lowercase_player_name + " is totally awesome! hooray for " + lowercase_player_name + "!");
	
	if (florist_available())
        random_messages.listAppend(HTMLGenerateTagWrap("a", "the forgotten friar cries himself to sleep", generateMainLinkMap("place.php?whichplace=forestvillage&amp;action=fv_friar")));
    
	if (!__misc_state["skills temporarily missing"])
	{
		if (!$skill[Transcendent Olfaction].have_skill())
            random_messages.listAppend(HTMLGenerateTagWrap("a", "visit the bounty hunter hunter sometime", generateMainLinkMap("bounty.php")));
	}
    if (__misc_state["in aftercore"])
        random_messages.listAppend(HTMLGenerateTagWrap("a", "ascension is waiting for you", generateMainLinkMap("lair6.php")));
    
    if (my_adventures() == 0)
        random_messages.listAppend("nowhere left to go");
        
    if (__quest_state["Level 11"].in_progress)
        random_messages.listAppend("try not to lose your sanity");
        
    if (!CounterLookup("Semi-rare").CounterIsRange() && CounterLookup("Semi-rare").CounterExists() && CounterLookup("Semi-rare").exact_turns.count() > 1)
        random_messages.listAppend("superpositioned semi-rare");
    if (hippy_stone_broken() && pvp_attacks_left() > 0)
        random_messages.listAppend(HTMLGenerateTagWrap("a", "aggressive friendship", generateMainLinkMap("peevpee.php")));
        
    string [familiar] familiar_messages;
    familiar_messages[$familiar[none]] = "even introverts need friends";
    familiar_messages[$familiar[black cat]] = "aww, cute kitty!";
    familiar_messages[$familiar[temporal riftlet]] = "master of time and space";
    familiar_messages[$familiar[Frumious Bandersnatch]] = "frabjous";
    if (__misc_state["free runs usable"])
        familiar_messages[$familiar[Pair of Stomping Boots]] = "running away again?";
    familiar_messages[$familiar[baby sandworm]] = "the waters of life";
    familiar_messages[$familiar[baby bugged bugbear]] = "expected }, found }&#x030b;&#x0311;&#x0300;&#x0306;&#x034a;&#x0311;&#x0314;&#x034f;&#x0331;&#x0329;&#x0320;&#x0330; &#x0323;&#x033b;&#x034a;&#x0345;f&#x031d;&#x034e;&#x0330;&#x0325;&#x0319;&#x0363;&#x0366;&#x0365;&#x030e;,&#x031c;&#x0318;&#x0316;&#x036d;&#x034b; &#x0332;&#x0349;&#x032e;&#x032d;&#x032a;&#x0323;&#x034c;&#x034b;&#x0364;&#x0309;&#x0357;&#x036a;&#x0304;&#x0315;;&#x0339;&#x033c;&#x030b;&#x0308;&#x035b;&#x034a; &#x0327;&#x0354;&#x0325;&#x0324;&#x300c;&#x0359;&#x033a;&#x033b;&#x0356;&#x032f;&#x035b;&#x0300;&#x0313;&#x030f;&#x0351;&#x0300;l&#x034d;&#x030d;&#x030d;&#x030d;&#x0351;i&#x0316;&#x0316;&#x0359;&#x0342;&#x036a;&#x036e;&#x030d; &#x0313;&#x0351;&#x0309;&#x0300;&#x0306;&#x0489;&#x0320;&#x031c;&#x035a;&#x031c;&#x0339;1&#x0336;&#x0354;&#x0329;&#x032c;&#x0326;&#x0326;&#x034d;&#x0365;7&#x035b;&#x0489;&#x032c;&#x032f;&#x0347;&#x033b;&#x0356;&#x0349;1&#x0306;&#x0311;&#x0302;&#x0352;&#x0313;&#x300d;&#x0327;&#x033c;&#x031c;&#x0339;&#x0318;&#x0355;&#x0346;&#x033e;&#x0301;&#x0346;&#x0350;&#x036f;&#x0367;"; //causes severe rendering slowdown; working as intended
    familiar_messages[$familiar[mechanical songbird]] = "a little glowing friend";
    familiar_messages[$familiar[nanorhino]] = "write every day";
    familiar_messages[$familiar[rogue program]] = "ascends for the users";
    familiar_messages[$familiar[O.A.F.]] = "helping";
    foreach f in $familiars[Bank Piggy,Egg Benedict,Floating Eye,Money-Making Goblin,Oyster Bunny,Plastic Grocery Bag,Snowhitman,Vampire Bat,Worm Doctor]
        familiar_messages[f] = "hacker";
    familiar_messages[$familiar[adorable space buddy]] = "far beyond the stars";
    familiar_messages[$familiar[happy medium]] = "karma slave"; //what mistakes could I have made?
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
    
    if (__misc_state_int["free rests remaining"] > 0)
        random_messages.listAppend(HTMLGenerateTagWrap("a", "dream your life away", generateMainLinkMap("campground.php")));
        
    
    string [class] class_messages;
    class_messages[$class[disco bandit]] = "making discos of your castles";
    class_messages[$class[seal clubber]] = "I &#x2663;&#xfe0e; seals";
    class_messages[$class[turtle tamer]] = "turtles turtles every where";
    
    if (class_messages contains my_class())
        random_messages.listAppend(class_messages[my_class()]);
    
    
    string [monster] monster_messages;
    //TODO add a message for the procrastination giant
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
    monster_messages[$monster[The Big Wisniewski]] = "far out";
    monster_messages[$monster[quiet healer]] = "...";
    monster_messages[$monster[menacing thug]] = "watch your back";
    monster_messages[$monster[sea cowboy]] = "pardon me";
    monster_messages[$monster[topiary golem]] = "almost there";
    monster_messages[$monster[the server]] = "console cowboy";
    monster_messages[$monster[Fickle Finger of F8]] = "f/8 and be there";
    monster_messages[$monster[malevolent crop circle]] = "I want to believe";
    monster_messages[$monster[enraged cow]] = "moo";
    monster_messages[$monster[Claybender Sorcerer Ghost]] = "accio blank-out";
    monster_messages[$monster[Whatsian Commando Ghost]] = "captain jack hotness";
    monster_messages[$monster[Space Tourist Explorer Ghost]] = "oh my";
    monster_messages[$monster[Battlie Knight Ghost]] = "boring conversation anyway";
    monster_messages[$monster[oil slick]] = "run more ML!";
    monster_messages[$monster[Space Marine]] = "as if it were from an old dream";
    monster_messages[$monster[Regret Man]] = "wasted potential";
    monster_messages[$monster[Principal Mooney]] = "life moves pretty fast";
    if (my_turncount() < 11)
        monster_messages[$monster[family of kobolds]] = "in a hurry?";
    monster_messages[$monster[Black Crayon Spiraling Shape]] = "be what you're like";
    monster_messages[$monster[best-selling novelist]] = "fiction to escape reality";
    monster_messages[$monster[7-Foot Dwarf Replicant]] = "it's too bad she won't live<br>but then again, who does?";
    monster_messages[lookupMonster("Avatar of Jarlsberg")] = "smoked cheese";
    monster_messages[$monster[giant sandworm]] = "walk without rhythm";
    monster_messages[$monster[bookbat]] = "tattered scrap of dignity";
    if (!$skill[Transcendent Olfaction].have_skill() && __misc_state["In run"])
        monster_messages[$monster[Astronomer]] = "nooo astronomer come back";
    
    if (monster_messages contains last_monster() && last_monster() != $monster[none])
    {
		random_messages.listClear();
        random_messages.listAppend(monster_messages[last_monster()]);
    }
    
    string [string] encounter_messages;
    encounter_messages["It's Always Swordfish"] = "one two three four five";
    
    if (encounter_messages contains get_property("lastEncounter"))
    {
		random_messages.listClear();
        random_messages.listAppend(encounter_messages[get_property("lastEncounter")]);
    }
    
    foreach s in $strings[rainDohMonster,spookyPuttyMonster,cameraMonster,photocopyMonster,envyfishMonster,iceSculptureMonster,crudeMonster,crappyCameraMonster,romanticTarget]
    {
        if (get_property(s) == "Quiet Healer")
        {
            random_messages.listClear();
            random_messages.listAppend("you can't bring her back");
            break;
        }
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