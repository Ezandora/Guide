void generateRandomMessageLocation(string [int] random_messages)
{
    if (__last_adventure_location == $location[none])
        return;
    string message = "";
    switch (__last_adventure_location)
    {
        case $location[the penultimate fantasy airship]:
            message = "insert disc 2 to continue"; break;
        case $location[a-boo peak]:
            message = "allons-y!"; break;
        case $location[twin peak]:
            message = "fire walk with me"; break;
        case $location[The Arrrboretum]:
            message = "save the planet"; break;
        case $location[the red queen's garden]:
            message = "curiouser and curiouser"; break;
        case $location[A Massive Ziggurat]:
            message = "1.21 ziggurats"; break;
        case $location[McMillicancuddy's Barn]:
            message = "dooks"; break;
        case $location[The Roman Forum]:
            message = "they go the house"; break;
        case $location[the battlefield (hippy uniform)]:
            message = "love and war"; break;
        case $location[the middle chamber]:
            message = "pyramid laundry machine"; break;
        case $location[the arid, extra-dry desert]:
            message = "can't remember your name"; break;
        case $location[outside the club]:
            message = "around the world around the world around the world around the world"; break;
        case $location[the hidden temple]:
            message = "beware of temple guards"; break;
        case $location[sonar]:
            message = "one ping only"; break;
        case $location[galley]:
            message = "hungry?"; break;
        case $location[science lab]:
            message = "poetry in motion"; break;
        case $location[fear man's level]:
        case $location[doubt man's level]:
        case $location[regret man's level]:
        case $location[anger man's level]:
            message = "<em>this isn't me</em>"; break;
        case $location[domed city of ronaldus]:
        case $location[domed city of grimacia]:
        case $location[hamburglaris shield generator]:
            message = "spaaaace!"; break;
        case $location[The Mansion of Dr. Weirdeaux]:
        case $location[The Deep Dark Jungle]:
        case $location[The Secret Government Laboratory]:
            message = "they know where you live, " + get_property("System.user.name").to_lower_case(); break;
        case $location[The castle in the clouds in the sky (ground floor)]:
        case $location[The castle in the clouds in the sky (basement)]:
        case $location[The castle in the clouds in the sky (top floor)]:
            if (my_class() == $class[disco bandit])
                message = "making castles of your disco";
            break;
        case $location[The Prince's Restroom]:
        case $location[The Prince's Dance Floor]:
        case $location[The Prince's Kitchen]:
        case $location[The Prince's Balcony]:
        case $location[The Prince's Lounge]:
        case $location[The Prince's Canapes table]:
            message = "social sabotage"; break;
        case $location[anemone mine (mining)]:
        case $location[itznotyerzitz mine (in disguise)]:
        case $location[the knob shaft (mining)]:
        case $location[The Crimbonium Mine]:
        case $location[The Velvet / Gold Mine (Mining)]:
            message = "street sneaky pete don't you call me cause I can't go"; break;
        case $location[Through the Spacegate]:
            message = "oh look! rocks!";
        case $location[noob cave]:
        	if ($location[noob cave].turns_spent >= 1000)
         		message = "find anything yet";
            else
            	message = "time to crate is zero";
        case $location[The Haunted Kitchen]:
        	if (my_level() >= 5 && my_maxhp() >= 36)
            {
            	message = HTMLGenerateSpanFont("where are the knives", "red");
            }
         	break;
    	case $location[Cobb's Knob Laboratory]:
            message = "deedee! get out of my laboratory!"; break;
        case $location[hell]:
            message = "that's a clean burning hell, I'll tell you what"; break;
        case $location[the goatlet]:
            message = "my child you are breaking my " + HTMLGenerateSpanFont("heart", "red"); break;
    }
    if (message != "")
        random_messages.listAppend(message);
}

    
void generateRandomMessageFamiliar(string [int] random_messages)
{
    string lowercase_player_name = my_name().to_lower_case().HTMLEscapeString();
    if (my_familiar() == $familiar[none])
        return;
    string message = "";
    switch (my_familiar())
    {
        case $familiar[none]:
            message = "even introverts need friends"; break;
        case $familiar[crimbo shrub]:
            if (format_today_to_string("MM") == "07")
                message = "crimbo in july"; break;
        case $familiar[black cat]:
            message = "aww, cute kitty!"; break;
        case $familiar[temporal riftlet]:
            message = "master of time and space"; break;
        case $familiar[Frumious Bandersnatch]:
            message = "frabjous"; break;
        case $familiar[Pair of Stomping Boots]:
            if (__misc_state["free runs usable"])
                message = "running away again?";
            break;
        case $familiar[baby sandworm]:
            message = "the waters of life"; break;
        case $familiar[baby bugged bugbear]:
            message = "expected }, found }&#x030b;&#x0311;&#x0300;&#x0306;&#x034a;&#x0311;&#x0314;&#x034f;&#x0331;&#x0329;&#x0320;&#x0330; &#x0323;&#x033b;&#x034a;&#x0345;f&#x031d;&#x034e;&#x0330;&#x0325;&#x0319;&#x0363;&#x0366;&#x0365;&#x030e;,&#x031c;&#x0318;&#x0316;&#x036d;&#x034b; &#x0332;&#x0349;&#x032e;&#x032d;&#x032a;&#x0323;&#x034c;&#x034b;&#x0364;&#x0309;&#x0357;&#x036a;&#x0304;&#x0315;;&#x0339;&#x033c;&#x030b;&#x0308;&#x035b;&#x034a; &#x0327;&#x0354;&#x0325;&#x0324;&#x300c;&#x0359;&#x033a;&#x033b;&#x0356;&#x032f;&#x035b;&#x0300;&#x0313;&#x030f;&#x0351;&#x0300;l&#x034d;&#x030d;&#x030d;&#x030d;&#x0351;i&#x0316;&#x0316;&#x0359;&#x0342;&#x036a;&#x036e;&#x030d; &#x0313;&#x0351;&#x0309;&#x0300;&#x0306;&#x0489;&#x0320;&#x031c;&#x035a;&#x031c;&#x0339;1&#x0336;&#x0354;&#x0329;&#x032c;&#x0326;&#x0326;&#x034d;&#x0365;7&#x035b;&#x0489;&#x032c;&#x032f;&#x0347;&#x033b;&#x0356;&#x0349;1&#x0306;&#x0311;&#x0302;&#x0352;&#x0313;&#x300d;&#x0327;&#x033c;&#x031c;&#x0339;&#x0318;&#x0355;&#x0346;&#x033e;&#x0301;&#x0346;&#x0350;&#x036f;&#x0367;"; //causes severe rendering slowdown; working as intended
            break;
        case $familiar[mechanical songbird]:
            message = "a little glowing friend"; break;
        case $familiar[nanorhino]:
            message = "write every day"; break;
        case $familiar[rogue program]:
            message = "ascends for the users"; break;
        case $familiar[O.A.F.]:
            message = "helping"; break;
        case $familiar[Bank Piggy]:
        case $familiar[Egg Benedict]:
        case $familiar[Floating Eye]:
        case $familiar[Money-Making Goblin]:
        case $familiar[Oyster Bunny]:
        case $familiar[Plastic Grocery Bag]:
        case $familiar[Snowhitman]:
        case $familiar[Vampire Bat]:
        case $familiar[Worm Doctor]:
            message = "hacker"; break;
        case $familiar[adorable space buddy]:
            message = "far beyond the stars"; break;
        case $familiar[happy medium]:
            message = "karma slave"; //what mistakes could I have made?
            break;
        case $familiar[wild hare]:
            message = "or you wouldn't have come here"; //you must be mad
            break;
        case $familiar[artistic goth kid]:
            message = "life is pain, " + lowercase_player_name; break;
        case $familiar[angry jung man]:
            message = "personal trauma"; break;
        case $familiar[unconscious collective]:
            message = "zzz"; break;
        case $familiar[dataspider]:
            message = "spiders are your friends"; break;
        case $familiar[stocking mimic]:
            message = "delicious candy"; break;
        case $familiar[cocoabo]:
            message = "flightless bird"; break;
        case $familiar[whirling maple leaf]:
            message = "canadian pride"; break;
        case $familiar[Hippo Ballerina]:
            message = "spin spin spin"; break;
        case $familiar[Mutant Cactus Bud]:
            message = "always watching"; break;
        case $familiar[ghuol whelp]:
            message = "&#x00af;\\_(&#x30c4;)_/&#x00af;"; //¯\_(ツ)_/¯
            break;
        case $familiar[bulky buddy box]:
            message = "&#x2665;&#xfe0e;"; //♥︎
            break;
        case $familiar[emo squid]:
            message = "sob"; break;
        case $familiar[fancypants scarecrow]:
            message = "the best in terms of pants"; break;
        case $familiar[jumpsuited hound dog]:
            message = "a little less conversation"; break;
        case $familiar[Gluttonous Green Ghost]:
            message = "I think he can hear you, " + lowercase_player_name; break;
        case $familiar[hand turkey]:
            message = "a rare bird"; break;
        case $familiar[reanimated reanimator]:
            message = "weird science"; break;
        case $familiar[Twitching Space Critter]:
            message = "right right right right down right agh"; break;
        case $familiar[slimeling]:
            message = "lost mother"; break;
        case $familiar[Puck Man]:
        case $familiar[Ms. Puck Man]:
            message = "&#5607; &bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;&nbsp;&bull;"; break;
        case $familiar[Lil' Barrel Mimic]:
            message = ":D"; break;
        case $familiar[pet rock]:
            message = "what if the rock's eyebrow froze that way. would anyone notice?"; break;
        case $familiar[space jellyfish]:
            message = "deer force";
            if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
            {
                int obtained = 0;
                int obtainable = 0;
                foreach it in $items[]
                {
                    if (it.quest) continue; //these disappear
                    if (it.item_amount_almost_everywhere() > 0)
                        obtained += 1;
                    obtainable += 1;
                }
                float rate = to_float(obtained) / to_float(obtainable);
                random_messages.listClear();
                message = "SEE YOU NEXT MISSION<br>your rate for collecting items is " + to_int(rate * 100) + "%";
            }
            else if (my_level() == 1 || my_turncount() <= 2)
            {
                random_messages.listClear();
                message = "the last jellyfish is in captivity<br>the kingdom is at peace";
            }
            
            break;
        case $familiar[bad vibe]:
            message = "<i>it's all your fault</i>"; break;
    }
    if (message != "")
        random_messages.listAppend(message);
}


static
{
	int __message_incremental;
}

string generateRandomMessage()
{
	string [int] random_messages;
	int current_hour = now_to_string("HH").to_int_silent();
	int current_minute = now_to_string("mm").to_int_silent();
	int minute_of_day = current_hour * 60 + current_minute;
    
    
    if (false)
    {
    	//for testing with continuous refresh mode; updates messages
    	__message_incremental += 1;
        return __message_incremental.to_string();
    }
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
    if ($item[tommy gun].equipped_amount() > 0) //I believe ya, but my tommy gun don't!
    	holiday_messages["Crimbo"] = "merry crimbo, ya filthy animal";
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
    
    if ($item[The One Mood Ring].equipped_amount() > 0 || $item[mood ring].equipped_amount() > 0)
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
    
    generateRandomMessageLocation(random_messages);

    //random_messages.listAppend(HTMLGenerateTagWrap("a", "if you're feeling stressed, play alice's army", generateMainLinkMap("aagame.php")));
    random_messages.listAppend(HTMLGenerateTagWrap("a", "if you're feeling stressed, play witchess", generateMainLinkMap("playwitchess.php?action=another")));
	random_messages.listAppend("consider your mistakes creative spading");
    
    if (hippy_stone_broken())
        random_messages.listAppend(HTMLGenerateTagWrap("a", "it's not easy having yourself a good time", generateMainLinkMap("peevpee.php")));
    
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
    equipment_messages[$item[pirate fledges]] = "<img src=\"images/otherimages/12x12skull.gif\" style=\"mix-blend-mode:multiply;\"><strong> oh, better far to live and die, under the brave black flag I fly! </strong><img src=\"images/otherimages/12x12skull.gif\" style=\"mix-blend-mode:multiply;\">";
    equipment_messages[lookupItem("unwrapped knock-off retro superhero cape")] = "you needed worthy opponents";
    
    foreach it in equipment_messages
    {
        if (it.equipped_amount() > 0)
        {
            random_messages.listAppend(equipment_messages[it]);
            //break;
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
    
    if ((gameday_to_int() & 31) == 0)
        random_messages.listAppend("seek the alchemist"); //a young lady's illustrated ascension guide
    
    string [effect] effect_messages;
    
    effect_messages[$effect[consumed by anger]] = "don't ascend angry";
    effect_messages[$effect[consumed by regret]] = "wasted potential";
    effect_messages[$effect[All Revved Up]] = "vroom";
    if (my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
        effect_messages[$effect[Expert Timing]] = "martial arts and crafts";
    effect_messages[$effect[apathy]] = ""; //
    effect_messages[$effect[silent running]] = "an awful lot of running";
    effect_messages[$effect[Neuromancy]] = "the silver paths";
    effect_messages[$effect[Teleportitis]] = "everywhere and nowhere";
    effect_messages[$effect[Form of...Bird!]] = "fiddle fiddle fiddle";
    effect_messages[$effect[superstar]] = "&#9733;";
    effect_messages[$effect[hopped up on goofballs]] = "a massive drug deficiency";
    foreach s in $strings[Warlock\, Warstock\, and Warbarrel,Barrel of Laughs,Barrel Chested,Pork Barrel,Double-Barreled,Beer Barrel Polka]
        effect_messages[s.to_effect()] = "just let me throw a barrel at it";
    effect_messages[$effect[Meteor Showered]] = "すきだ";
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
    
    switch (my_path_id())
    {
        case PATH_OXYGENARIAN:
            random_messages.listAppend("the slow path"); break;
        case PATH_BEES_HATE_YOU:
            random_messages.listAppend("bzzzzzz"); break;
        case PATH_WAY_OF_THE_SURPRISING_FIST:
            random_messages.listAppend("martial arts and crafts"); break;
        case PATH_TRENDY:
            random_messages.listAppend("played out"); break;
        case PATH_AVATAR_OF_BORIS:
            random_messages.listAppend("testosterone poisoning"); break;
        case PATH_BUGBEAR_INVASION:
            random_messages.listAppend("bugbears!"); break;
        case PATH_ZOMBIE_SLAYER:
            random_messages.listAppend("consumerism metaphor"); break;
        case PATH_CLASS_ACT:
            random_messages.listAppend("try the sequel"); break;
        case PATH_AVATAR_OF_JARLSBERG:
            random_messages.listAppend("nerd"); break;
        case PATH_BIG:
            random_messages.listAppend("everything's so tiny..."); break;
        case PATH_KOLHS:
            random_messages.listAppend("did you study?"); break;
        case PATH_CLASS_ACT_2:
            random_messages.listAppend("lonely guild trainer"); break;
        case PATH_AVATAR_OF_SNEAKY_PETE:
            random_messages.listAppend("sunglasses at night"); break;
        case PATH_SLOW_AND_STEADY:
            if (!in_hardcore())
                random_messages.listAppend("infinite pulls");
            else
                random_messages.listAppend("skip a day if you like");
            break;
        case PATH_HEAVY_RAINS:
            random_messages.listAppend("survive"); break;
        case PATH_PICKY:
            if ($skill[cannelloni cannon].skill_is_usable() && !$skill[cannelloni cocoon].skill_is_usable()) //such an easy mistake...
                random_messages.listAppend("cannelloni confusion");
            else
                random_messages.listAppend("combinatorial ascension");
            break;
        case PATH_STANDARD:
            random_messages.listAppend("no past no path"); break;
        case PATH_ACTUALLY_ED_THE_UNDYING:
            random_messages.listAppend("UNDYING!"); break;
        case PATH_ONE_CRAZY_RANDOM_SUMMER:
            random_messages.listAppend("dance the mersenne twist"); break;
        case PATH_COMMUNITY_SERVICE:
            random_messages.listAppend("make the world a better place"); break;
        case PATH_AVATAR_OF_WEST_OF_LOATHING:
            random_messages.listAppend("draw"); break;
        case PATH_THE_SOURCE:
            if (my_daycount() % 2 == 0)
                random_messages.listAppend("don't think you aren't. know you aren't.");
            else
                random_messages.listAppend("it is not the spoon that ascends, it is only yourself");
            break;
        case PATH_NUCLEAR_AUTUMN:
            random_messages.listAppend("I do want to set the world on " + HTMLGenerateSpanFont("fire", "red"));
            break;
        case PATH_GELATINOUS_NOOB:
            random_messages.listAppend("you jelly?");
            break;
        case PATH_LICENSE_TO_ADVENTURE:
            random_messages.listAppend("FOR YOUR EYES ONLY");
            break;
        case PATH_LIVE_ASCEND_REPEAT:
            random_messages.listAppend("a single perfect day");
            break;
        case PATH_POCKET_FAMILIARS:
        	random_messages.listAppend("adorable slaves");
            break;
        case PATH_G_LOVER:
            random_messages.listAppend("get going, guuuurl");
            break;
        case PATH_DEMIGUISE:
            random_messages.listAppend("who are you?"); break;
        case PATH_VAMPIRE:
            random_messages.listAppend("die monster! you don't belong in this world!"); break;
        case PATH_2CRS:
            random_messages.listAppend("what happened to my inventory?"); break;
        case PATH_EXPLOSIONS:
            random_messages.listAppend("kaboooooom"); break;
        case PATH_LOKI:
            random_messages.listAppend("more lochs than scotland"); break;
        case PATH_LUIGI:
            random_messages.listAppend("look at that pale skin! he's been living in his brother's shadow too long"); break;
        case PATH_GREY_GOO:
            random_messages.listAppend("avatar of pet rock"); break;
        case PATH_ROBOT:
            random_messages.listAppend("weren't you already a robot? is this double robot?"); break;
        /*case PATH_CLASS_ACT_3:
            random_messages.listAppend("buttons for the people"); break;*/
    }
    
    if (in_ronin() && my_adventures() <= 3)
    	random_messages.listAppend("always tomorrow");
    
    random_messages.listAppend("I don't know either, sorry");
    
    string lowercase_player_name = my_name().to_lower_case().HTMLEscapeString();
        
    random_messages.listAppend(HTMLGenerateTagWrap("a", "check the wiki", mapMake("class", "r_a_undecorated", "href", "http://kol.coldfront.net/thekolwiki/index.php/Main_Page", "target", "_blank")));
    random_messages.listAppend("the RNG is only trying to " + ((random(100) == 0) ? "hurt" : "help"));
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
    
	if (__iotms_usable[$item[Order of the Green Thumb Order Form]])
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
    if (__quest_state["Level 13"].in_progress && my_path_id() != PATH_LOKI)
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
    
    random_messages.listAppend("take chances, be courages, go exploring!");
    switch (my_class())
    {
        case $class[disco bandit]:
            random_messages.listAppend("making discos of your castles"); break;
        case $class[seal clubber]:
            random_messages.listAppend("I &#x2663;&#xfe0e; seals"); break;
        case $class[turtle tamer]:
            random_messages.listAppend("friends everywhere you go"); break;
        case $class[sauceror]:
            random_messages.listAppend("journey of the sauceror"); break;
        case $class[Snake Oiler]:
            random_messages.listAppend("ten points to slytherin"); break;
    }
    
    if (numeric_modifier("hot damage") <= 0.0 && gameday_to_int() % 4 == 0)
    	random_messages.listAppend("have you tried " + HTMLGenerateSpanFont("fire", "red"));
    
    
    if (__misc_state["Chateau Mantegna available"] && get_property_monster("chateauMonster").phylum == $phylum[fish] && !get_property_boolean("_chateauMonsterFought"))
    {
        random_messages.listAppend(HTMLGenerateTagWrap("a", "personal aquarium", generateMainLinkMap("place.php?whichplace=chateau"))); //WhiteWizard42:  feeeeesh. feesh in the waaaall
    }
    generateRandomMessageFamiliar(random_messages);
        
    if (last_monster().phylum == $phylum[penguin])
    {
        random_messages.listClear(); //sufficiently rare
        random_messages.listAppend("dood");
    }
    
    string [monster] monster_messages;
    string [monster] beaten_up_monster_messages;
    //TODO add a message for the procrastination giant
    foreach m in $monsters[The Temporal Bandit,crazy bastard,Knott Slanding,hockey elemental,Hypnotist of Hey Deze,infinite meat bug,QuickBASIC Elemental,The Master of Thieves,Baiowulf,Count Bakula,The Nuge] //Pooltergeist (Ultra-Rare)?
        monster_messages[m] = "an ultra rare! congratulations!";
    monster_messages[$monster[The Master of Thieves]] = "don't @ me";
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
    monster_messages[$monster[Quiet Healer]] = "...";
    monster_messages[$monster[menacing thug]] = "watch your back";
    monster_messages[$monster[sea cowboy]] = "pardon me";
    monster_messages[$monster[topiary golem]] = "almost ther... wait, golems?";
    monster_messages[$monster[The Server]] = "console cowboy";
    monster_messages[$monster[Fickle Finger of F8]] = "f/8 and be there";
    monster_messages[$monster[malevolent crop circle]] = "I want to believe";
    monster_messages[$monster[Enraged Cow]] = "moo";
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
    monster_messages[$monster[The Avatar of Jarlsberg]] = "smoked cheese";
    monster_messages[$monster[giant sandworm]] = "walk without rhythm";
    monster_messages[$monster[bookbat]] = "tattered scrap of dignity";
    monster_messages[$monster[Urge to Stare at Your Hands]] = ".&#x20dd;.&#x20dd;"; //.⃝.⃝
    if (my_path_id() == PATH_HEAVY_RAINS)
        monster_messages[$monster[pygmy bowler]] = "right into the gutter"; //come back!
    monster_messages[$monster[Ron "The Weasel" Copperhead]] = "RONALD WEASLEY! HOW DARE YOU STEAL THAT ZEPPELIN<br>" + ChecklistGenerateModifierSpan("your father's now facing an inquiry at work and it's entirely YOUR FAULT");
    monster_messages[$monster[Mr. Loathing]] = HTMLGenerateTagWrap("a", "ruuun! go! get to the towah!", generateMainLinkMap("place.php?whichplace=nstower"));
    if (my_hp() < my_maxhp())
        monster_messages[$monster[Smooth Criminal]] = "you've been hit by<br>you've been struck by<br><i>a smooth criminal</i>";
    monster_messages[$monster[demonic icebox]] = "zuul";
    monster_messages[$monster[angry mushroom guy]] = "touch fizzy, get dizzy";
    beaten_up_monster_messages[$monster[storm cow]] = "<pre>^__^            <br>(oo)\\_______    <br>(__)\\       )\\/\\<br>    ||----w |   <br>    ||     ||   </pre>";
    monster_messages[$monster[The Barrelmech of Diogenes]] = "just let me throw a barrel at it";
    //beaten_up_monster_messages[$monster[Lavalos]] = HTMLGenerateTagWrap("span", "but... the future refused to change", mapMake("onclick", "var l = new Audio('" + __lavalos_sound_data + "'); l.play();", "class", "r_clickable")); //copyright, etc
    beaten_up_monster_messages[$monster[Lavalos]] = "but... the future refused to change";
    if ($item[protonic accelerator pack].equipped_amount() > 0 && last_monster().monsterIsGhost())
        beaten_up_monster_messages[last_monster()] = "venkman makes it look easy";
    if ($effect[beaten up].have_effect() > 0 && $items[rainbow pearl earring,rainbow pearl necklace,rainbow pearl ring,vampire pearl earring,vampire pearl ring,vampire pearl necklace,freshwater pearl necklace,pearl diver's ring,pearl diver's necklace,pearl necklace].equipped_amount() > 0)
    	beaten_up_monster_messages[last_monster()] = "WHY WON'T YOU JUST LET ME DO THIS FOR YOU, ROSE?";
    if (last_monster().phylum == $phylum[demon])
	    beaten_up_monster_messages[last_monster()] = "he made the devil so much stronger than a man!";
    if (current_hour >= 5 && current_hour <= 11)
        monster_messages[$monster[Lavalos]] = "good morning, " + lowercase_player_name + "!";
    else
        monster_messages[$monster[Lavalos]] = "all life begins with nu and ends with nu";
    monster_messages[$monster[sk8 gnome]] = "he was a sk8 gnome she said see u l8 gnome";
    monster_messages[$monster[The Inquisitor]] = "nothing is up";
    monster_messages[$monster[Doc Clock]] = "your defeat will happen at " + (current_hour > 12 ? current_hour - 12 : current_hour) + ":" + current_minute + " precisely"; // + (current_hour >= 12 ? " PM" : " AM")
    monster_messages[$monster[God Lobster]] = "what a grand and intoxicating innocence"; //how can you kill a god? equip the heart of the volcano?
    monster_messages[$monster[cockroach]] = "are bug exterminators professional assassins?"; 
    
    string day_cycle;
    if (current_hour >= 5 && current_hour <= 11)
        day_cycle = "morning";
    else if (current_hour >= 12 && current_hour <= 16)
        day_cycle = "afternoon";
    else if (current_hour >= 17 && current_hour <= 20)
        day_cycle = "evening";
    else
        day_cycle = "night";
    monster_messages[$monster[Travoltron]] = now_to_string("EEEE").to_lower_case() + " " + day_cycle + " fever";
    
    if (my_daycount() == 2 && (my_adventures() == 0 || availableDrunkenness() < 0) && availableFullness() == 0 && availableDrunkenness() <= 0 && my_path_id() != PATH_OXYGENARIAN && __quest_state["Level 12"].started && !__quest_state["Level 13"].state_boolean["king waiting to be freed"] && my_path_id() != PATH_NUCLEAR_AUTUMN && my_path_id() != PATH_SLOW_AND_STEADY && !__quest_state["Level 13"].finished)
    {
        //detect failed two-day runs, and provide psychological support:
        random_messages.listClear();
        if (__quest_state["Level 13"].started)
            random_messages.listAppend("ever so close");
        else
            random_messages.listAppend("three days is fine");
    }
    
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
    encounter_messages["Witchess Puzzles"] = "this etch a sketch is hard";
    encounter_messages["Rubbed it the Right Way"] = "desire incarnate";
	if (my_class() == $class[turtle tamer])
	{
		//The Horror... needs disambiguation
        foreach s in $strings[Nantucket Snapper,Blue Monday,Capital!,Training Day,Boxed In,Duel Nature,Slow Food,A Rolling Turtle Gathers No Moss,Slow Road to Hell,C'mere\, Little Fella,The Real Victims,Like That Time in Tortuga,Cleansing your Palette,Harem Scarum,Turtle in peril,No Man\, No Hole,Slow and Steady Wins the Brawl,Stormy Weather,Turtles of the Universe,O Turtle Were Art Thou,Allow 6-8 Weeks For Delivery,Kick the Can,Turtles All The Way Around,More eXtreme Than Usual,Jewel in the Rough,The worst kind of drowning]
            encounter_messages[s] = "friend!";
    }
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
        if (get_property_monster(s) == $monster[Quiet Healer])
        {
            random_messages.listClear();
            random_messages.listAppend("you can't bring her back");
            break;
        }
    }
    if (false)//mmg_my_bets().count() > 0)
    {
		random_messages.listClear();
		random_messages.listAppend("win some, lose some");
    }
	if ($effect[beaten up].have_effect() > 0 && limit_mode().length() == 0 && !already_output_relevant_beaten_up_effect)
	{
		random_messages.listClear();
        
        
        switch (my_path_id())
        {
            case PATH_BEES_HATE_YOU:
                random_messages.listAppend("BZZZZZZ"); break;
            case PATH_ONE_CRAZY_RANDOM_SUMMER:
                random_messages.listAppend("tick, tock"); break;
            case PATH_ACTUALLY_ED_THE_UNDYING:
                random_messages.listAppend("DYING!"); break;
            case PATH_COMMUNITY_SERVICE:
                random_messages.listAppend("no good deed goes unpunished"); break;
            case PATH_AVATAR_OF_WEST_OF_LOATHING:
                random_messages.listAppend("shucks"); break;
            case PATH_LIVE_ASCEND_REPEAT:
                random_messages.listAppend("I got you babe"); break;
            case PATH_LICENSE_TO_ADVENTURE:
                random_messages.listAppend("you only live twice"); break;
            case PATH_THE_SOURCE:
                random_messages.listAppend("not like this"); break;
            case PATH_POCKET_FAMILIARS:
                random_messages.listAppend(lowercase_player_name + "! now is not the time to use that!"); break;
            case PATH_G_LOVER:
                random_messages.listAppend("the Gs will continue until morale improves"); break;
            default:
                random_messages.listAppend("ow"); break;
        }
	}
	if (my_turncount() <= 0)
	{
		random_messages.listClear();
        if (my_path_id() == PATH_LIVE_ASCEND_REPEAT)
            random_messages.listAppend("I got you babe");
        else if (my_path_id() == PATH_POCKET_FAMILIARS)
            random_messages.listAppend("pika pika!");
        else
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
    if (limit_mode() == "batman" && !encounter_override)
    {
		random_messages.listClear();
        random_messages.listAppend("a superstitious, cowardly lot");
    }
    
    if (format_today_to_string("yyyyMMdd") == "20151021") //october 21st, 2015
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
