string generateRandomMessage()
{
	string [int] random_messages;
	int current_hour = now_to_string("HH").to_int_silent();
	int current_minute = now_to_string("mm").to_int_silent();
	int minute_of_day = current_hour * 60 + current_minute;
    
    if (!playerIsLoggedIn())
        return "the kingdom awaits";
        
    if (__misc_state["In valhalla"])
        return "rebirth";
    
	if (__misc_state["in run"])
    {
        if (my_turncount() > 1000 && !in_bad_moon())
            random_messages.listAppend("so many turns");
        
        if (false)
            random_messages.listAppend("you are ascending perfectly, excellent work!");
        else if (my_daycount() >= 365)
            random_messages.listAppend("no king, forever");
        else if (my_daycount() >= 11)
            random_messages.listAppend("does the king even exist...?");
        else if (my_turncount() > 500 && my_daycount() == 1)
            random_messages.listAppend("you are ascending too... wait, what?");
        else if (gameday_to_int() == 7)
            random_messages.listAppend("you are ascending at a reasonable pace, could do better");
        else
            random_messages.listAppend("you are ascending too slowly, ascend faster!");
        
        string what_does_the_spreadsheet_say = "saves a turn";
        if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
            what_does_the_spreadsheet_say = "gives +fun";
        if ($item[optimal spreadsheet].equipped_amount() > 0)
            random_messages.listAppend("every spreadsheet you wear " + what_does_the_spreadsheet_say); //sure, why not?
        else
            random_messages.listAppend("every spreadsheet you make " + what_does_the_spreadsheet_say);
    }
    
    string [string] holiday_messages;
    holiday_messages["Groundhog Day"] = "it's cold out there every day";
    holiday_messages["Crimbo"] = "merry crimbo";
    holiday_messages["April Fool's Day"] = "you are ascending too quickly, ascend slower!";
    holiday_messages["Valentine's Day"] = HTMLGenerateSpanFont("&#x2665;&#xfe0e;", "pink", "3.0em");
    holiday_messages["Towel Day"] = "don't panic";
    
    boolean [string] holidays_today = getHolidaysToday();
    foreach holiday in holidays_today
    {
        if (holiday_messages contains holiday)
        {
            random_messages.listAppend(holiday_messages[holiday]);
        }
    }
    
    if (lookupItem("The One Mood Ring").equipped_amount() > 0 || $item[mood ring].equipped_amount() > 0)
    {
        string [int] moods = split_string("grateful,awake,accomplished,disappointed,enraged,tired,exhausted,amused,crushed,peaceful,energetic,listless,hyper,jubilant,hungry,sad,bewildered,alone,quixotic,recumbent,bored,excited,relaxed,lonely,curious,guilty,jealous,cheerful,depressed,stressed,infuriated,pleased,crappy,aggravated,okay,rejuvenated,apathetic,bittersweet,optimistic,exanimate,complacent,devious,rejected,blissful,discontent,sympathetic,mellow,refreshed,ecstatic,lazy,morose,dark,mischievous,bouncy,thankful,melancholy,content,drained,numb,uncomfortable,indifferent,groggy,calm,irate,determined,giggly,good,confused,anxious,relieved,mad,accepted,happy,angry,lethargic,shocked,indescribable,satisfied,gloomy,irritated,pessimistic,rushed,frustrated,surprised,annoyed,sleepy,touched,enthralled,cynical,envious,hopeful,ashamed,chipper,loved,giddy,restless", ",");
        string mood_today = moods[gameday_to_int()];
        if (mood_today != "")
            random_messages.listAppend(mood_today);
    }
    
	if (__misc_state["in run"])
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
    location_messages[$location[The Roman Forum]] = "they go the house";
    location_messages[$location[the battlefield (hippy uniform)]] = "love and war";
    location_messages[$location[the middle chamber]] = "pyramid laundry machine";
    location_messages[$location[the arid, extra-dry desert]] = "can't remember your name";
    location_messages[$location[outside the club]] = "around the world around the world around the world around the world";
    location_messages[$location[the hidden temple]] = "beware of temple guards";
    if (my_class() == $class[disco bandit])
    {
        foreach l in $locations[The castle in the clouds in the sky (ground floor),The castle in the clouds in the sky (basement),The castle in the clouds in the sky (top floor)]
            location_messages[l] = "making castles of your disco";
    }
    string conspiracy = "they know where you live, " + get_property("System.user.name").to_lower_case();
    foreach s in $strings[The Mansion of Dr. Weirdeaux,The Deep Dark Jungle,The Secret Government Laboratory]
        location_messages[lookupLocation(s)] = conspiracy;
    foreach s in $strings[anemone mine (mining),itznotyerzitz mine (in disguise),the knob shaft (mining),The Crimbonium Mine,The Velvet / Gold Mine (Mining)]
        location_messages[lookupLocation(s)] = "street sneaky pete don't you call me cause I can't go";
    location_messages[$location[sonar]] = "one ping only";
    location_messages[$location[galley]] = "hungry?";
    location_messages[$location[science lab]] = "poetry in motion";
    
    foreach l in $locations[The Prince's Restroom,The Prince's Dance Floor,The Prince's Kitchen,The Prince's Balcony,The Prince's Lounge,The Prince's Canapes table]
        location_messages[l] = "social sabotage";
    
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
    equipment_messages[$item[Moonthril Circlet]] = "moon tiara"; //action!
    equipment_messages[$item[numberwang]] = "simply everyone";
    equipment_messages[$item[Mark V Steam-Hat]] = "girl genius";
    equipment_messages[$item[mr. accessory]] = "you can equip mr. accessories?";
    equipment_messages[$item[white hat hacker T-shirt]] = "hack the planet";
    equipment_messages[$item[heart necklace]] = "&#x2665;&#xfe0e;"; //♥︎
    equipment_messages[$item[fleetwood chain]] = "running in the shadows";
    equipment_messages[$item[liar's pants]] = "never tell the same lie twice";
    equipment_messages[$item[detective skull]] = HTMLGenerateSpanFont("too slow ascend faster", "#ACA200"); //speakeasy password
    equipment_messages[$item[gasmask]] = "are you my mummy?";
    equipment_messages[$item[spanish fly trap]] = "around the world around the world around the world around the world";
    equipment_messages[$item[wand of nagamar]] = "levi OH sa";
    if (in_bad_moon() && my_primestat() != $stat[moxie])
        equipment_messages[$item[sneaky pete's breath spray]] = "every class a moxie class";
    foreach it in $items[twisted-up wet towel,sommelier's towel,time bandit time towel]
        equipment_messages[it] = "don't panic";
    
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
    else if (my_ascensions() == 1)
        random_messages.listAppend("run, while you still have the chance!");
        
    if (__misc_state["in run"])
        random_messages.listAppend("perfect runs are overrated");
    random_messages.listAppend("math is your helpful friend");
    
    if (get_property_int("_pantsgivingCount") >= 5500)
    {
        random_messages.listAppend("Could not connect to secondary database server:2003 - Can't connect to MySQL server on '10.0.0.51' (99)");
    }
    
    string [effect] effect_messages;
    
    effect_messages[$effect[consumed by anger]] = "don't ascend angry";
    effect_messages[$effect[consumed by regret]] = "wasted potential";
    effect_messages[$effect[All Revved Up]] = "vroom";
    if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
        effect_messages[$effect[Expert Timing]] = "martial arts and crafts";
    effect_messages[$effect[apathy]] = "";
    effect_messages[$effect[silent running]] = "an awful lot of running";
    effect_messages[$effect[Neuromancy]] = "the silver paths";
    effect_messages[$effect[Teleportitis]] = "everywhere and nowhere";
    effect_messages[$effect[Form of...Bird!]] = "fiddle fiddle fiddle";
    effect_messages[$effect[superstar]] = "&#9733;";
    effect_messages[$effect[hopped up on goofballs]] = "a massive drug deficiency";
    foreach s in $strings[Warlock\, Warstock\, and Warbarrel,Barrel of Laughs,Barrel Chested,Pork Barrel,Double-Barreled,Beer Barrel Polka]
        effect_messages[s.to_effect()] = "just let me throw a barrel at it";
    foreach e in effect_messages
    {
        if (e.have_effect() > 0 && e != $effect[none])
        {
            random_messages.listAppend(effect_messages[e]);
            break;
        }
    }
    
    
    if (__misc_state["single familiar run"])
        random_messages.listAppend("together forever");
    
    random_messages.listAppend("click click click");
    
    string [int] paths;
    paths[PATH_OXYGENARIAN] = "the slow path";
    paths[PATH_BEES_HATE_YOU] = "bzzzzzz";
    paths[PATH_WAY_OF_THE_SURPRISING_FIST] = "martial arts and crafts";
    paths[PATH_TRENDY] = "played out";
    paths[PATH_AVATAR_OF_BORIS] = "testosterone poisoning";
    paths[PATH_BUGBEAR_INVASION] = "bugbears!";
    paths[PATH_ZOMBIE_SLAYER] = "consumerism metaphor";
    paths[PATH_CLASS_ACT] = "try the sequel";
    paths[PATH_AVATAR_OF_JARLSBERG] = "nerd";
    paths[PATH_BIG] = "everything's so tiny...";
    paths[PATH_KOLHS] = "did you study?";
    paths[PATH_CLASS_ACT_2] = "lonely guild trainer";
    paths[PATH_AVATAR_OF_SNEAKY_PETE] = "sunglasses at night";
    if (!in_hardcore())
        paths[PATH_SLOW_AND_STEADY] = "infinite pulls";
    else
        paths[PATH_SLOW_AND_STEADY] = "skip a day if you like";
    paths[PATH_HEAVY_RAINS] = "survive";
    paths[PATH_PICKY] = "combinatorial ascension";
    if ($skill[cannelloni cannon].skill_is_usable() && !$skill[cannelloni cocoon].skill_is_usable()) //such an easy mistake...
        paths[PATH_PICKY] = "cannelloni confusion";
    paths[PATH_STANDARD] = "no past no path";
    paths[PATH_ACTUALLY_ED_THE_UNDYING] = "UNDYING!";
    paths[PATH_ONE_CRAZY_RANDOM_SUMMER] = "dance the mersenne twist";
    paths[PATH_COMMUNITY_SERVICE] = "make the world a better place";
    //paths[PATH_WEST_OF_LOATHING] = "draw";
    //paths[PATH_CLASS_ACT_3] = "buttons for the people";
    //paths[PATH_AVATAR_OF_THE_NAUGHTY_SORCERESS] = "go forth to your lair! have some tea";
    
    if (paths contains my_path_id())
        random_messages.listAppend(paths[my_path_id()]);
    
    random_messages.listAppend("I don't know either, sorry");
    
    string lowercase_player_name = my_name().to_lower_case().HTMLEscapeString();
        
    random_messages.listAppend(HTMLGenerateTagWrap("a", "check the wiki", mapMake("class", "r_a_undecorated", "href", "http://kol.coldfront.net/thekolwiki/index.php/Main_Page", "target", "_blank")));
    random_messages.listAppend("the RNG is only trying to help");
    if (__misc_state["in run"])
    {
        int choice = gameday_to_int() & 3;
        
        if (choice == 0)
            random_messages.listAppend("speed ascension is all I have left, " + lowercase_player_name);
        else if (choice == 1)
            random_messages.listAppend("let the turns go");
        else if (choice == 2)
            random_messages.listAppend("mostly made up");
        else if (choice == 3)
            random_messages.listAppend("kingdom of self loathing");
        if (my_ascensions() >= 1000)
            random_messages.listAppend("dedicated");
    }
    
    if (item_drop_modifier() <= -100.0)
        random_messages.listAppend("let go of your material posessions");
    if ($item[puppet strings].item_amount() > 0 && my_id() != 1557284)
    {
        //full puppet string support:
        string chosen_message;
        switch (gameday_to_int() % 13)
        {
            case 0: chosen_message = "%playername% is easily the most great person ever! three cheers for %playername%!"; break;
            case 1: chosen_message = "%playername% is my hero! don't you all agree?"; break;
            case 2: chosen_message = "%playername% is such a sexy beast!"; break;
            case 3: chosen_message = "%playername% is super-attractive and studly! don't you all agree?"; break;
            case 4: chosen_message = "%playername% is super-attractive and studly! just saying that name makes me feel all tingly inside!"; break;
            case 5: chosen_message = "who do I think is the best KoLer? obviously\, it's %playername%! how about a round of applause?"; break;
            case 6: chosen_message = "I wish I was as good-looking as %playername%. hip hip hooray!"; break;
            case 7: chosen_message = "I'm %playername%'s biggest fan! let's hear it for %playername%!"; break;
            case 8: chosen_message = "I've never met anyone as attractive as %playername%! how about a round of applause?"; break;
            case 9: chosen_message = "I've never met anyone as studly as %playername%! all the rest of us are totally lame in comparison!"; break;
            case 10: chosen_message = "is anyone as fabulous as %playername%? I don't think so! just saying that name makes me feel all tingly inside!"; break;
            case 11: chosen_message = "is anyone as intelligent as %playername%? I don't think so! hooray for %playername%!"; break;
            default: chosen_message = "%playername% is totally awesome! hooray for %playername%!"; break;
        }
        chosen_message = chosen_message.replace_string("%playername%", lowercase_player_name);
        random_messages.listAppend(chosen_message);
        //random_messages.listAppend(lowercase_player_name + " is totally awesome! hooray for " + lowercase_player_name + "!");
    }
	
    if (__quest_state["Level 12"].in_progress && __quest_state["Level 12"].state_int["hippies left on battlefield"] < 1000 && __quest_state["Level 12"].state_int["frat boys left on battlefield"] < 1000)
        random_messages.listAppend("playing sides");
    
	if (florist_available())
        random_messages.listAppend(HTMLGenerateTagWrap("a", "the forgotten friar cries himself to sleep", generateMainLinkMap("place.php?whichplace=forestvillage&amp;action=fv_friar")));
    
	if (!__misc_state["skills temporarily missing"] && !$skill[Transcendent Olfaction].skill_is_usable())
	{
        random_messages.listAppend(HTMLGenerateTagWrap("a", "visit the bounty hunter hunter sometime", generateMainLinkMap("bounty.php")));
	}
    if (__misc_state["in aftercore"])
        random_messages.listAppend(HTMLGenerateTagWrap("a", "ascension is waiting for you", generateMainLinkMap("place.php?whichplace=nstower")));
    
    if (my_adventures() == 0)
        random_messages.listAppend("nowhere left to go");
        
    if (__quest_state["Level 11"].in_progress)
        random_messages.listAppend("try not to lose your sanity");
    if (__quest_state["Level 13"].in_progress)
    {
        if (my_daycount() == 1)
            random_messages.listAppend("all the world's work in a day");
        else
            random_messages.listAppend("it'll be all over soon");
    }
        
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
    familiar_messages[$familiar[Twitching Space Critter]] = "right right right right down right agh";
    familiar_messages[$familiar[slimeling]] = "lost mother";
    if (format_today_to_string("MM") == "07")
        familiar_messages[$familiar[Crimbo Shrub]] = "crimbo in july";
    familiar_messages[$familiar[Ms. Puck Man]] = "&#5607; &bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;";
    familiar_messages[$familiar[Puck Man]] = familiar_messages[$familiar[Ms. Puck Man]];
    familiar_messages[lookupFamiliar("Lil' Barrel Mimic")] = ":D";
    
    if (familiar_messages contains my_familiar() && !__misc_state["familiars temporarily blocked"])
        random_messages.listAppend(familiar_messages[my_familiar()]);
        
    if (get_property_boolean("_warbearGyrocopterUsed"))
        random_messages.listAppend("[gyroseaten] => 109");
        
    random_messages.listAppend(HTMLGenerateTagWrap("a", "&#x266b;", mapMake("class", "r_a_undecorated", "href", "http://www.kingdomofloathing.com/radio.php", "target", "_blank")));
    
    if (__misc_state_int["free rests remaining"] > 0)
        random_messages.listAppend(HTMLGenerateTagWrap("a", "dream your life away", generateMainLinkMap(__misc_state_string["resting url"])));
    
    if (get_property_int("cinderellaScore") >= 32)
        random_messages.listAppend("mother knows best");

    if ($location[the shore\, inc. travel agency].turnsAttemptedInLocation() >= 11)
    {
        if (hippy_stone_broken())
            random_messages.listAppend("beware of shorebots");
        else
            random_messages.listAppend("under a distant shore you will find your answers");
    }
    
    if (current_hour >= 2 && current_hour <= 3)
        random_messages.listAppend("up late?");
    else if (current_hour >= 4 && current_hour <= 5)
        random_messages.listAppend("zzz...");
    else if (current_hour == 6)
        random_messages.listAppend("the dawn is your enemy");
    
    string [class] class_messages;
    class_messages[$class[disco bandit]] = "making discos of your castles";
    class_messages[$class[seal clubber]] = "I &#x2663;&#xfe0e; seals";
    class_messages[$class[turtle tamer]] = "friends everywhere you go";
    class_messages[$class[sauceror]] = "journey of the sauceror";
    
    if (class_messages contains my_class())
        random_messages.listAppend(class_messages[my_class()]);
    
    
    if (__misc_state["Chateau Mantegna available"] && get_property_monster("chateauMonster").phylum == $phylum[fish] && !get_property_boolean("_chateauMonsterFought"))
    {
        random_messages.listAppend(HTMLGenerateTagWrap("a", "personal aquarium", generateMainLinkMap("place.php?whichplace=chateau"))); //WhiteWizard42:  feeeeesh. feesh in the waaaall
    }
        
    if (last_monster().phylum == $phylum[penguin])
    {
        random_messages.listClear(); //sufficiently rare
        random_messages.listAppend("dood");
    }
    
    string [monster] monster_messages;
    string [monster] beaten_up_monster_messages;
    //TODO add a message for the procrastination giant
    foreach m in $monsters[The Temporal Bandit,crazy bastard,Knott Slanding,hockey elemental,Hypnotist of Hey Deze,infinite meat bug,QuickBASIC elemental,The Master Of Thieves,Baiowulf,Count Bakula,the nuge] //Pooltergeist (Ultra-Rare)?
        monster_messages[m] = "an ultra rare! congratulations!";
    monster_messages[$monster[Dad Sea Monkee]] = "is always was always" + HTMLGenerateSpanFont(" is always was always", "#444444") + HTMLGenerateSpanFont(" is always was always", "#888888") + HTMLGenerateSpanFont(" is always was always", "#BBBBBB");
    
    foreach m in $monsters[Ed the Undying (1),Ed the Undying (2),Ed the Undying (3),Ed the Undying (4),Ed the Undying (5),Ed the Undying (6),Ed the Undying (7)]
        monster_messages[m] = "UNDYING!";
    foreach m in $monsters[Naughty Sorceress, Naughty Sorceress (2), Naughty Sorceress (3)]
    {
        if (holidays_today["Valentine's Day"])
            monster_messages[m] = "please be mine, sorceress";
        else
            monster_messages[m] = "she isn't all that bad";
    }
    foreach m in $monsters[Shub-Jigguwatt\, Elder God of Violence,Yog-Urt\, Elder Goddess of Hatred]
        monster_messages[m] = "strange aeons";
    monster_messages[$monster[daft punk]] = "can you feel it?";
    monster_messages[$monster[ghastly organist]] = "phantom of the opera";
    monster_messages[$monster[The Man]] = "let the workers unite";
    monster_messages[$monster[The Big Wisniewski]] = "far out";
    monster_messages[$monster[quiet healer]] = "...";
    monster_messages[$monster[menacing thug]] = "watch your back";
    monster_messages[$monster[sea cowboy]] = "pardon me";
    monster_messages[$monster[topiary golem]] = "almost ther... wait, golems?";
    monster_messages[$monster[the server]] = "console cowboy";
    monster_messages[$monster[Fickle Finger of F8]] = "f/8 and be there";
    monster_messages[$monster[malevolent crop circle]] = "I want to believe";
    monster_messages[$monster[enraged cow]] = "moo";
    if ($item[bottle of blank-out].is_unrestricted())
        monster_messages[$monster[Claybender Sorcerer Ghost]] = "accio blank-out";
    else
        monster_messages[$monster[Claybender Sorcerer Ghost]] = "leaderboardus totalus";
    monster_messages[$monster[Whatsian Commando Ghost]] = "captain jack hotness";
    if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
        monster_messages[$monster[Whatsian Commando Ghost]] = "are you my mummy?";
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
    monster_messages[$monster[urge to stare at your hands]] = ".&#x20dd;.&#x20dd;"; //.⃝.⃝
    if (my_path_id() == PATH_HEAVY_RAINS)
        monster_messages[$monster[pygmy bowler]] = "right into the gutter"; //come back!
    monster_messages[$monster[extremely annoyed witch]] = "am I blue?"; //you dare to strike... quit it!
    monster_messages[$monster[surprised and annoyed witch]] = "these tears in my eyes, telling you";
    monster_messages[$monster[Ron "The Weasel" Copperhead]] = "RONALD WEASLEY! HOW DARE YOU STEAL THAT ZEPPELIN<br>" + ChecklistGenerateModifierSpan("your father's now facing an inquiry at work and it's entirely YOUR FAULT");
    monster_messages[$monster[Mr. Loathing]] = HTMLGenerateTagWrap("a", "ruuun! go! get to the towah!", generateMainLinkMap("place.php?whichplace=nstower"));
    if (my_hp() < my_maxhp())
        monster_messages[$monster[smooth criminal]] = "you've been hit by<br>you've been struck by<br><i>a smooth criminal</i>";
    monster_messages[$monster[demonic icebox]] = "zuul";
    monster_messages[lookupMonster("angry mushroom guy")] = "touch fizzy, get dizzy";
    beaten_up_monster_messages[$monster[storm cow]] = "<pre>^__^            <br>(oo)\\_______    <br>(__)\\       )\\/\\<br>    ||----w |   <br>    ||     ||   </pre>";
    monster_messages[lookupMonster("Barrelmech of Diogenes")] = "just let me throw a barrel at it";
    //beaten_up_monster_messages[lookupMonster("Lavalos")] = HTMLGenerateTagWrap("span", "but... the future refused to change", mapMake("onclick", "var l = new Audio('" + __lavalos_sound_data + "'); l.play();", "class", "r_clickable")); //copyright, etc
    beaten_up_monster_messages[lookupMonster("Lavalos")] = "but... the future refused to change";
    if (current_hour >= 5 && current_hour <= 11)
        monster_messages[lookupMonster("Lavalos")] = "good morning, " + lowercase_player_name + "!";
    else
        monster_messages[lookupMonster("Lavalos")] = "all life begins with nu and ends with nu";
    monster_messages[$monster[sk8 gnome]] = "he was a sk8 gnome she said see u l8 gnome";
    
    string day_cycle;
    if (current_hour >= 5 && current_hour <= 11)
        day_cycle = "morning";
    else if (current_hour >= 12 && current_hour <= 16)
        day_cycle = "afternoon";
    else if (current_hour >= 17 && current_hour <= 20)
        day_cycle = "evening";
    else
        day_cycle = "night";
    monster_messages[lookupMonster("Travoltron")] = now_to_string("EEEE").to_lower_case() + " " + day_cycle + " fever";
    
    boolean already_output_relevant_beaten_up_effect = false;
    if ((my_hp() == 0 || $effect[beaten up].have_effect() > 0) && beaten_up_monster_messages contains last_monster() && last_monster() != $monster[none])
    {
		random_messages.listClear();
        random_messages.listAppend(beaten_up_monster_messages[last_monster()]);
        already_output_relevant_beaten_up_effect = true;
    }
    else if (monster_messages contains last_monster() && last_monster() != $monster[none])
    {
		random_messages.listClear();
        random_messages.listAppend(monster_messages[last_monster()]);
    }
    
    
    if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
    {
        if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
        {
            random_messages.listClear();
            random_messages.listAppend(HTMLGenerateTagWrap("a", "roll the dice", generateMainLinkMap("place.php?whichplace=nstower")));
        }
    }
    
    if (__misc_state_int["Basement Floor"] == 500)
    {
        random_messages.listClear();
        random_messages.listAppend(HTMLGenerateTagWrap("a", "open it!", generateMainLinkMap("basement.php")));
    }
    
    string [string] encounter_messages;
    boolean encounter_override = false;
    encounter_messages["It's Always Swordfish"] = "one two three four five";
    encounter_messages["Meet Frank"] = "don't trust the skull";
    encounter_messages["The Mirror in the Tower has the View that is True"] = "shatter the false reality";
    encounter_messages["A Tombstone"] = "peperony and chease";
    
    if (encounter_messages contains get_property("lastEncounter"))
    {
		random_messages.listClear();
        random_messages.listAppend(encounter_messages[get_property("lastEncounter")]);
        encounter_override = true;
    }
    
    if (__quest_state["Level 12"].in_progress && __quest_state["Level 12"].state_int["hippies left on battlefield"] == 1 && __quest_state["Level 12"].state_int["frat boys left on battlefield"] == 1)
    {
        random_messages.listClear();
        random_messages.listAppend("wossname is waiting");
    }
    
    if (my_familiar() == $familiar[Helix Fossil])
    {
        buffer generated;
        
        
        string [int] commands;
        
        string property_value = get_property("__voices");
        
        if (property_value.length() > 1) //remove sentinel
        {
            if (property_value.char_at(property_value.length() - 1) == "|")
                property_value = property_value.substring(0, property_value.length() - 1);
        }
        
        commands = property_value.split_string_alternate(",");
        
        for i from 0 to 0
        {
            string word;
            int r = random(100);
            if (r < 15)
                word = "&#11014;"; //⬆︎
            else if (r < 30)
                word = "&#11015;"; //⬇︎
            else if (r < 45)
                word = "&#10145;"; //➡
            else if (r < 60)
                word = "&#11013;"; //⬅︎
            else if (r < 75)
                word = "A";// &#9398; = Ⓐ
            else if (r < 95)
                word = "B"; //&#9399; = Ⓑ
            else
                word = "start";
                
            
                
            commands.listAppend(word);
        }
        while (commands.count() > 6)
            remove commands[commands.listKeyForIndex(0)];
        set_property("__voices", commands.listJoinComponents(",") + "|"); //we add an ending sentinel because set_property() will remove ";" if it's at the end of the string. set_property() is not guaranteed to keep data integrity
        
        random_messages.listClear();
        
        string message = commands.listJoinComponents(" ");
        message = HTMLGenerateTagWrap("span", message, mapMake("onclick", "updatePageAndFireTimer()", "class", "r_clickable"));
        
        random_messages.listAppend(message);
    }
        
    
    
    foreach s in $strings[rainDohMonster,spookyPuttyMonster,cameraMonster,photocopyMonster,envyfishMonster,iceSculptureMonster,crudeMonster,crappyCameraMonster,romanticTarget,chateauMonster]
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
	if ($effect[beaten up].have_effect() > 0 && limit_mode().length() == 0 && !already_output_relevant_beaten_up_effect)
	{
		random_messages.listClear();
        random_messages.listAppend("ow");
	}
	if (my_turncount() <= 0)
	{
		random_messages.listClear();
		random_messages.listAppend("find yourself<br>starting back");
	}
    if (limit_mode() == "Spelunky" && !encounter_override)
    {
		random_messages.listClear();
        
        if (get_property("lastEncounter") == "Spelunkrifice" && get_property("spelunkyStatus").contains_text("Buddy: "))
        {
            if (get_property("spelunkingStatus").contains_text("Resourceful Kid"))
                random_messages.listAppend("he's only a child!");
            else
                random_messages.listAppend("et tu, " + lowercase_player_name + "?");
        }
        else
            random_messages.listAppend("ascend? yes! play? no!");
    }
    
    if (format_today_to_string("YYYYMMdd") == "20151021") //october 21st, 2015
    {
        //kept active for any time travelers
		random_messages.listClear();
        if (get_property("System.user.country.format") == "US")
            random_messages.listAppend("88 MPH<br>hey, you did it!");
        else
            random_messages.listAppend("142 km/h<br>hey, you did it!");
    }
    
    
    //Choose:
    if (random_messages.count() == 0)
        return "lack of cleverness";
	string chosen_message = "";
	//Base message off of the minute, so it doesn't cycle when the page reloads often:
	chosen_message = random_messages[minute_of_day % random_messages.count()];
    
    return chosen_message;
}