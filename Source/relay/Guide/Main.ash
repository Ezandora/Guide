import "relay/Guide/Settings.ash"
import "relay/Guide/State.ash"
import "relay/Guide/Missing Items.ash"
import "relay/Guide/Support/Math.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Tasks.ash"
import "relay/Guide/Daily Resources.ash"


void setUpCSSStyles()
{
	string body_style = "";
    if (!__setting_use_kol_css)
    {
        //Base page look:
        body_style += "font-family:Arial,Helvetica,sans-serif;background-color:white;color:black;";
        PageAddCSSClass("a:link", "", "color:black;", -10);
        PageAddCSSClass("a:visited", "", "color:black;", -10);
        PageAddCSSClass("a:active", "", "color:black;", -10);
    }
    if (__setting_side_negative_space_is_dark)
        body_style += "background-color:" + __setting_dark_color + ";";
    else
        body_style += "background-color:#FFFFFF;";
    body_style += "margin:0px;font-size:14px;";
    
    if (__setting_ios_appearance)
        body_style += "font-family:'Helvetica Neue',Arial, Helvetica, sans-serif;font-weight:lighter;";
    
    PageAddCSSClass("body", "", body_style, -11);
    
	PageAddCSSClass("", "r_future_option", "color:" + __setting_unavailable_color + ";");
	
    PageAddCSSClass("a", "r_cl_internal_anchor", "position:absolute;z-index:2;padding-top:" + __setting_navbar_height + ";display:inline-block;");
	
	
    PageAddCSSClass("div", "r_word_wrap_group", "display:inline-block;");
	
	if (true)
	{
		string hr_definition;
		hr_definition = "height: 1px; margin-top: 1px; margin-bottom: 1px; border: 0px; width: 100%;";
	
		hr_definition += "background: " + __setting_line_color + ";";
		PageAddCSSClass("hr", "", hr_definition);
	}
	
	
    if (__setting_fill_vertical)
        PageAddCSSClass("div", "r_vertical_fill", "bottom:0;left:0;right:0;position:fixed;height:100%;margin-left:auto;margin-right:auto;");
    
    if (__setting_show_navbar)
    {
        PageAddCSSClass("div", "r_navbar_line_separator", "position:absolute;float:left;min-width:1px;min-height:" + __setting_navbar_height + ";background:" + __setting_line_color + ";");
        PageAddCSSClass("div", "r_navbar_text", "text-align:center;font-weight:bold;font-size:.9em;");
        PageAddCSSClass("div", "r_navbar_button_container", "overflow:hidden;vertical-align:top;display:inline-block;height:" + __setting_navbar_height + ";");
    }
    PageAddCSSClass("img", "", "border:0px;");
}

void generateImageTest(Checklist [int] checklists)
{
	ChecklistEntry [int] image_test_entries;
	KOLImagesInit();
	foreach i in __kol_images
	{
		KOLImage image = __kol_images[i];
		image_test_entries.listAppend(ChecklistEntryMake(i, "", ChecklistSubentryMake(i)));
		
	}
	checklists.listAppend(ChecklistMake("All images", image_test_entries));
}

void generateStateTest(Checklist [int] checklists)
{
	ChecklistEntry [int] misc_state_entries;
	ChecklistEntry [int] misc_state_string_entries;
	ChecklistEntry [int] misc_state_int_entries;
	ChecklistEntry [int] quest_state_entries;
	
	foreach key in __misc_state
	{
		misc_state_entries.listAppend(ChecklistEntryMake("blank", "", ChecklistSubentryMake(key + " = " + __misc_state[key])));
	}
	foreach key in __misc_state_string
	{
		misc_state_string_entries.listAppend(ChecklistEntryMake("blank", "", ChecklistSubentryMake(key + " = \"" + __misc_state_string[key] + "\"")));
	}
	foreach key in __misc_state_int
	{
		misc_state_int_entries.listAppend(ChecklistEntryMake("blank", "", ChecklistSubentryMake(key + " = " + __misc_state_int[key])));
	}
	
	
	boolean [string] names_already_seen;
	
	foreach key in __quest_state
	{
		if (names_already_seen[key])
			continue;
		names_already_seen[key] = true;
		
		QuestState quest_state = __quest_state[key];
		
		string [int] full_name_list;
		full_name_list.listAppend(key);
		
		//Look for others:
		foreach key2 in __quest_state
		{
			if (key == key2)
				continue;
			QuestState quest_state_2 = __quest_state[key2];
			
			if (QuestStateEquals(quest_state, quest_state_2))
			{
				full_name_list.listAppend(key2);
				names_already_seen[key2] = true;
			}
		}
		
		ChecklistSubentry subentry;
		
		subentry.header = listJoinComponents(full_name_list, " / " );
		if (quest_state.quest_name != "")
			subentry.entries.listAppend("Internal name: " + quest_state.quest_name);
		
		subentry.entries.listAppend("Startable: " + quest_state.startable);
		subentry.entries.listAppend("Started: " + quest_state.started);
		subentry.entries.listAppend("In progress: " + quest_state.in_progress);
		subentry.entries.listAppend("Finished: " + quest_state.finished);
		subentry.entries.listAppend("Mafia's internal step: " + quest_state.mafia_internal_step);
		
		foreach key2 in quest_state.state_boolean
		{
			subentry.entries.listAppend(key2 + ": " + quest_state.state_boolean[key2]);
		}
		foreach key2 in quest_state.state_string
		{
			subentry.entries.listAppend(key2 + ": \"" + quest_state.state_string[key2] + "\"");
		}
		foreach key2 in quest_state.state_int
		{
			subentry.entries.listAppend(key2 + ": " + quest_state.state_int[key2]);
		}
		
		quest_state_entries.listAppend(ChecklistEntryMake(quest_state.image_name, "", subentry));
	}
	
	
	checklists.listAppend(ChecklistMake("Misc. Boolean States", misc_state_entries));
	checklists.listAppend(ChecklistMake("Misc. String States", misc_state_string_entries));
	checklists.listAppend(ChecklistMake("Misc. Int States", misc_state_int_entries));
	checklists.listAppend(ChecklistMake("Quest States", quest_state_entries));
}


void generateMisc(Checklist [int] checklists)
{
	if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
	{
		ChecklistEntry [int] unimportant_task_entries;
		string [int] king_messages;
		king_messages.listAppend("You know, whenever.");
		king_messages.listAppend("Maybe the naughty sorceress was right.");
		unimportant_task_entries.listAppend(ChecklistEntryMake("king imprismed", "lair6.php", ChecklistSubentryMake("Free the King", "", king_messages)));
		
		checklists.listAppend(ChecklistMake("Unimportant Tasks", unimportant_task_entries));
	}
	
	if (availableDrunkenness() < 0 && my_path() != "Avatar of Sneaky Pete" && $item[drunkula's wineglass].equipped_amount() == 0) //assuming in advance sneaky pete has some sort of drunkenness adventures
	{
        //They're drunk, so tasks aren't as relevant. Re-arrange everything:
        string url;
        
        //Give them something to mindlessly click on:
        //url = "bet.php";
       if ($coinmaster[Game Shoppe].is_accessible())
            url = "aagame.php";
        
        
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
		
		lookupChecklist(checklists, "Future Tasks").entries.listAppendList(lookupChecklist(checklists, "Tasks").entries);
		lookupChecklist(checklists, "Future Tasks").entries.listAppendList(lookupChecklist(checklists, "Optional Tasks").entries);
		lookupChecklist(checklists, "Future Unimportant Tasks").entries.listAppendList(lookupChecklist(checklists, "Unimportant Tasks").entries);
		
		lookupChecklist(checklists, "Tasks").entries.listClear();
		lookupChecklist(checklists, "Optional Tasks").entries.listClear();
		lookupChecklist(checklists, "Unimportant Tasks").entries.listClear();
		
        string [int] description;
        string line = "You're drunk.";
        if (__last_adventure_location == $location[Drunken Stupor])
            url = "campground.php";
        
        if (hippy_stone_broken() && pvp_attacks_left() > 0)
            url = "peevpee.php";
            
        description.listAppend(line);
        if ($item[drunkula's wineglass].available_amount() > 0 && $item[drunkula's wineglass].can_equip())
        {
            description.listAppend("Or equip your wineglass.");
        }
        
        int rollover_adventures_from_equipment = 0;
        foreach s in $slots[]
            rollover_adventures_from_equipment += s.equipped_item().numeric_modifier("adventures").to_int();
        
        if (rollover_adventures_from_equipment == 0.0)
        {
            description.listAppend("Possibly wear +adventures gear.");
        }
        //detect if they're going to lose some turns, be nice:
        int rollover_adventures_gained = numeric_modifier("adventures").to_int() + 40;
        if (get_property_boolean("_borrowedTimeUsed"))
            rollover_adventures_gained -= 20;
        int adventures_lost = (my_adventures() + rollover_adventures_gained) - 200;
        if (adventures_lost > 0)
        {
            description.listAppend("You'll miss out on " + pluralizeWordy(adventures_lost, "adventure", "adventures") + ". Alas.|Could work out in the gym, craft, or play arcade games.");
        }
        
		task_entries.entries.listAppend(ChecklistEntryMake("__item counterclockwise watch", url, ChecklistSubentryMake("Wait for rollover", "", description), -11));
	}
}

void generateChecklists(Checklist [int] ordered_output_checklists)
{
	setUpState();
	setUpQuestState();
	
	if (__misc_state["Example mode"])
		setUpExampleState();
	
	finalizeSetUpState();
	
	Checklist [int] checklists;
	
    
    if (!playerIsLoggedIn())
    {
        //Hmm. I think emptying everything is the way to go, because if we're not online, we'll be inaccurate. Best to give no advice than some.
        //But, it might break in the future if our playerIsLoggedIn() detection is inaccurate?
        
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
        
        string image_name;
        image_name = "disco bandit"; //tricky - they may not have this image in their image cache. Display nothing?
		task_entries.entries.listAppend(ChecklistEntryMake(image_name, "", ChecklistSubentryMake("Log in", "+internet", "An Adventurer is You!"), -11));
    }
    else if (__misc_state["In valhalla"])
    {
        //Valhalla:
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
        task_entries.entries.listAppend(ChecklistEntryMake("astral spirit", "", ChecklistSubentryMake("Ascend, spirit!", "", listMake("Perm skills.", "Buy consumables.", "Bring along a pet."))));
    }
    else
    {
        generateDailyResources(checklists);
        
        generateTasks(checklists);
        if (__misc_state["Example mode"] || !get_property_boolean("kingLiberated"))
        {
            generateMissingItems(checklists);
            generatePullList(checklists);
        }
        if (__setting_debug_show_all_internal_states && __setting_debug_mode)
            generateImageTest(checklists);
        if (__setting_debug_show_all_internal_states && __setting_debug_mode)
            generateStateTest(checklists);
        generateFloristFriar(checklists);
        
        
        generateMisc(checklists);
    }
	
	//Remove checklists that have no entries:
	int [int] keys_to_remove;
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		if (cl.entries.count() == 0)
			keys_to_remove.listAppend(key);
	}
	listRemoveKeys(checklists, keys_to_remove);
	listClear(keys_to_remove);
	
	//Go through desired output order:
	string [int] setting_desired_output_order = split_string_mutable("Tasks,Optional Tasks,Unimportant Tasks,Future Tasks,Resources,Future Unimportant Tasks,Required Items,Suggested Pulls,Florist Friar", ",");
	foreach key in setting_desired_output_order
	{
		string title = setting_desired_output_order[key];
		//Find title in checklists:
		foreach key2 in checklists
		{
			Checklist cl = checklists[key2];
			if (cl.title == title)
			{
				ordered_output_checklists.listAppend(cl);
				keys_to_remove.listAppend(key2);
				break;
			}
		}
	}
	listRemoveKeys(checklists, keys_to_remove);
	listClear(keys_to_remove);
	
	//Add remainder:
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		ordered_output_checklists.listAppend(cl);
	}
}


string generateRandomMessage()
{
	string [int] random_messages;
    
    if (!playerIsLoggedIn())
        return "the kingdom awaits";
    
	if (__misc_state["In run"])
		random_messages.listAppend("you are ascending too slowly, ascend faster!");
	if (__misc_state["In run"])
    {
        random_messages.listAppend("take those extra adventures you were going to play, and forget to do them");
        random_messages.listAppend("every spreadsheet you make saves a turn");
    }
	if (__misc_state["free runs usable"] && __misc_state["In run"])
		random_messages.listAppend("if you see an ultra-rare, free run away");
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
    
    if (location_messages contains __last_adventure_location)
        random_messages.listAppend(location_messages[__last_adventure_location]);
    
    if (now_to_string("M").to_int_silent() == 12)
        random_messages.listAppend("merry crimbo");

    random_messages.listAppend(HTMLGenerateTagWrap("a", "if you're feeling stressed, play alice's army", mapMake("class", "r_a_undecorated", "href", "aagame.php", "target", "mainpane")));
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
        
    random_messages.listAppend("math is your helpful friend");
    random_messages.listAppend("click click click");
    
    string [string] paths;
    paths["Bees Hate You"] = "bzzzzzz";
    paths["Way of the Surprising Fist"] = "martial arts and crafts";
    paths["Trendy"] = "played out";
    paths["Avatar of Boris"] = "testosterone poisoning";
    paths["Bugbear Invasion"] = "bugbears!";
    paths["Zombie Slayer"] = "consumerism metaphor";
    paths["Class Act"] = "try the sequel";
    paths["Avatar of Jarlsberg"] = "nerd";
    paths["BIG!"] = "leveling is boring";
    paths["KOLHS"] = "did you study?";
    paths["Class Act II: A Class For Pigs"] = "lonely guild trainer";
    paths["Avatar of Sneaky Pete"] = "sunglasses at night";
    
    paths["Oxygenarian"] = "the slow path";
    
    if (paths contains my_path())
        random_messages.listAppend(paths[my_path()]);
    
    string lowercase_player_name = my_name().to_lower_case().HTMLEscapeString();
        
	random_messages.listAppend(HTMLGenerateTagWrap("a", "check the wiki", mapMake("class", "r_a_undecorated", "href", "http://kol.coldfront.net/thekolwiki/index.php/Main_Page", "target", "_blank")));
	random_messages.listAppend("the RNG is only trying to help");
	if (__misc_state["In run"])
        random_messages.listAppend("speed ascension is all I have left, " + lowercase_player_name);
	if (storage_amount($item[puppet strings]) + $item[puppet strings].available_amount() > 0)
		random_messages.listAppend(lowercase_player_name + " is totally awesome! hooray for " + lowercase_player_name + "!");
	
	if (florist_available())
		random_messages.listAppend("the forgotten friar cries himself to sleep");
        
	if (!__misc_state["skills temporarily missing"])
	{
		if (!have_skill($skill[Transcendent Olfaction]))
            random_messages.listAppend(HTMLGenerateTagWrap("a", "visit the bounty hunter hunter sometime", mapMake("class", "r_a_undecorated", "href", "bounty.php", "target", "mainpane")));
	}
    if (__misc_state["in aftercore"])
        random_messages.listAppend(HTMLGenerateTagWrap("a", "ascension is waiting for you", mapMake("class", "r_a_undecorated", "href", "lair6.php", "target", "mainpane")));
    
        
    string [familiar] familiar_messages;
    familiar_messages[$familiar[none]] = "even introverts need friends";
    familiar_messages[$familiar[black cat]] = "aww, cute kitty!";
    familiar_messages[$familiar[temporal riftlet]] = "master of time and space";
    familiar_messages[$familiar[Frumious Bandersnatch]] = "frabjous";
    familiar_messages[$familiar[Pair of Stomping Boots]] = "running away again?";
    familiar_messages[$familiar[baby sandworm]] = "the waters of life";
    familiar_messages[$familiar[baby bugged bugbear]] = "expected }, found ; (Main.ash, line 440)";
    familiar_messages[$familiar[mechanical songbird]] = "a little glowing friend";
    familiar_messages[$familiar[nanorhino]] = "write every day";
    familiar_messages[$familiar[rogue program]] = "ascends for the users";
    familiar_messages[$familiar[O.A.F.]] = "helping";
    foreach f in $familiars[Bank Piggy,Egg Benedict,Floating Eye,Money-Making Goblin,Oyster Bunny,Plastic Grocery Bag,Snowhitman,Vampire Bat,Worm Doctor]
        familiar_messages[f] = "hacker";
    familiar_messages[$familiar[adorable space buddy]] = "far beyond the stars";
    familiar_messages[$familiar[happy medium]] = "karma slave";
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
    
    
    if (familiar_messages contains my_familiar())
        random_messages.listAppend(familiar_messages[my_familiar()]);
        
    random_messages.listAppend(HTMLGenerateTagWrap("a", "&#x266b;", mapMake("class", "r_a_undecorated", "href", "http://www.kingdomofloathing.com/radio.php", "target", "_blank")));
        
    
    string [monster] monster_messages;
    foreach m in $monsters[The Temporal Bandit,crazy bastard,Knott Slanding,hockey elemental,Hypnotist of Hey Deze,infinite meat bug,QuickBASIC elemental,The Master Of Thieves,Baiowulf,Count Bakula]
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
    monster_messages[$monster[quiet healer]] = "...";
    monster_messages[$monster[menacing thug]] = "watch your back";
    monster_messages[$monster[sea cowboy]] = "pardon me";
    monster_messages[$monster[topiary golem]] = "almost there";
    
    if (monster_messages contains last_monster() && last_monster() != $monster[none])
    {
		random_messages.listClear();
        random_messages.listAppend(monster_messages[last_monster()]);
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


void outputChecklists(Checklist [int] ordered_output_checklists)
{
    if (__misc_state["In run"] && playerIsLoggedIn())
        PageWrite(HTMLGenerateDivOfClass("Day " + my_daycount() + ". " + pluralize(my_turncount(), "turn", "turns") + " played.", "r_bold"));
	if (my_path() != "" && my_path() != "None" && playerIsLoggedIn())
	{
		PageWrite(HTMLGenerateDivOfClass(my_path(), "r_bold"));
	}
    
    
    string chosen_message = generateRandomMessage();
    if (chosen_message.length() > 0)
        PageWrite(HTMLGenerateDiv(chosen_message));
    PageWrite(HTMLGenerateTagWrap("div", "", mapMake("id", "extra_words_at_top")));
	
	
	if (__misc_state["Example mode"])
	{
		PageWrite("<br>");
		PageWrite(HTMLGenerateDivOfStyle("Example ascension", "text-align:center; font-weight:bold;"));
	}
		
	if (my_path() == "Trendy") //trendy is unsupported
    {
        PageWrite("<br>");
		PageWrite(HTMLGenerateDiv("Trendy warning - advice may be dangerously out of style"));
    }

    Checklist extra_important_tasks;
    
	//And output:
	foreach i in ordered_output_checklists
	{
		Checklist cl = ordered_output_checklists[i];
		PageWrite(ChecklistGenerate(cl));
        
        if (__show_importance_bar && cl.title == "Tasks")
        {
            foreach key in cl.entries
            {
                ChecklistEntry entry = cl.entries[key];
                if (entry.importance_level <= -11)
                    extra_important_tasks.entries.listAppend(entry);
                    
            }
        }
	}
    
    if (__show_importance_bar && extra_important_tasks.entries.count() > 0)
    {
        extra_important_tasks.title = "Tasks";
        extra_important_tasks.disable_generating_id = true;
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("id", "importance_bar", "style", "z-index:3;position:fixed; top:0;width:100%;max-width:" + __setting_horizontal_width + "px;border-bottom:1px solid;border-color:" + __setting_line_color + ";visibility:hidden;")));
		PageWrite(ChecklistGenerate(extra_important_tasks, false));
        PageWrite(HTMLGenerateTagSuffix("div"));
        
    }
}


string [string] generateAPIResponse()
{
    //35ms response time measured in-run
    string [string] result;
    
    
    boolean stale_quest_log_data = get_property_boolean("__relay_guide_stale_quest_data");
    boolean should_force_reload = false;
    if (safeToLoadQuestLog() && stale_quest_log_data) //quest log data is stale, but we can reload it
        should_force_reload = true;
    
    if (should_force_reload)
    {
        result["need to reload"] = should_force_reload;
        return result;
    }
    
    
    //Unique identifiers to determine whether a reload is necessary:
    //All of these will be checked by the javascript.
    result["turns played"] = my_turncount();
    result["hp"] = my_hp();
    result["mp"] = my_mp();
    result["+ml"] = monster_level_adjustment();
    result["+init"] = initiative_modifier();
    result["combat rate"] = combat_rate_modifier();
    result["+item"] = item_drop_modifier();
    result["familiar"] = my_familiar().to_int();
    result["adventures remaining"] = my_adventures();
    result["meat available"] = my_meat();
    result["stills available"] = stills_available();
    result["enthroned familiar"] = my_enthroned_familiar();
    result["pulls remaining"] = pulls_remaining();
    
    
    
    if (true)
    {
        int [effect] my_effects = my_effects();
        int total_effect_length = 0;
        foreach e in my_effects
            total_effect_length += my_effects[e];
        
        result["effect count"] = my_effects.count();
        result["total effect length"] = total_effect_length;
    }
    result["fullness available"] = availableFullness();
    result["drunkenness available"] = availableDrunkenness();
    result["spleen available"] = availableSpleen();
    result["auto attack id"] = get_auto_attack(); //for copied monsters warning, don't want that to be stale
    
    if (true)
    {
        result["equipped items"] = equipped_items().to_json();
    }
    
    if (false)
    {
        //if we need a clockwork maid? maybe?
        result["campground items"] = get_campground().to_json();
    }
    
    if (false)
    {
        //Very intensive, (40ms API load versus 25ms, or 28ms versus 16ms), so disabled:
        //Still, it would be very useful.
        int item_count = 0;
        foreach it in $items[]
            item_count += it.available_amount();
        result["item count"] = item_count;
    }
    else if (true)
    {
        //Checking every item is slow. But certain items won't trigger a reload, but need to. So:
        boolean [item] relevant_items = $items[photocopied monster,4-d camera,pagoda plans,Elf Farm Raffle ticket,skeleton key,heavy metal thunderrr guitarrr,heavy metal sonata,Hey Deze nuts,rave whistle,damp old boot,map to Professor Jacking's laboratory,world's most unappetizing beverage,squirmy violent party snack,White Citadel Satisfaction Satchel,rusty screwdriver,giant pinky ring,The Lost Pill Bottle,GameInformPowerDailyPro magazine,dungeoneering kit,Knob Goblin encryption key,dinghy plans,Sneaky Pete's key,Jarlsberg's key,Boris's key,fat loot token,bridge,chrome ore,asbestos ore,linoleum ore,csa fire-starting kit,tropical orchid,stick of dynamite,barbed-wire fence,psychoanalytic jar,digital key,Richard's star key,star hat,star crossbow,star staff,star sword,Wand of Nagamar,Azazel's tutu,Azazel's unicorn,Azazel's lollipop,smut orc keepsake box,blessed large box,massive sitar,hammer of smiting,chelonian morningstar,greek pasta of peril,17-alarm saucepan,shagadelic disco banjo,squeezebox of the ages,E.M.U. helmet,E.M.U. harness,E.M.U. joystick,E.M.U. rocket thrusters,E.M.U. unit,wriggling flytrap pellet,Mer-kin trailmap,Mer-kin stashbox];
        //future: add snow boards
        
        
        int [int] output;
        
        foreach it in relevant_items
        {
            if (it.available_amount() > 0)
                output[it.to_int()] = it.available_amount();
        }
        result["relevant items"] = output.to_json();
        
    }
    
    if (true)
    {
        
        boolean [string] relevant_mafia_properties = $strings[merkinQuestPath,questF01Primordial,questF02Hyboria,questF03Future,questF04Elves,questF05Clancy,questG01Meatcar,questG02Whitecastle,questG03Ego,questG04Nemesis,questG05Dark,questG06Delivery,questI01Scapegoat,questI02Beat,questL02Larva,questL03Rat,questL04Bat,questL05Goblin,questL06Friar,questL07Cyrptic,questL08Trapper,questL09Topping,questL10Garbage,questL11MacGuffin,questL11Manor,questL11Palindome,questL11Pyramid,questL11Worship,questL12War,questL13Final,questM01Untinker,questM02Artist,questM03Bugbear,questM04Galaktic,questM05Toot,questM06Gourd,questM07Hammer,questM08Baker,questM09Rocks,questM10Azazel,questM11Postal,questM12Pirate,questM13Escape,questM14Bounty,questM15Lol,questS01OldGuy,questS02Monkees,sidequestArenaCompleted,sidequestFarmCompleted,sidequestJunkyardCompleted,sidequestLighthouseCompleted,sidequestNunsCompleted,sidequestOrchardCompleted,cyrptAlcoveEvilness,cyrptCrannyEvilness,cyrptNicheEvilness,cyrptNookEvilness,desertExploration,gnasirProgress,relayCounters,timesRested,currentEasyBountyItem,currentHardBountyItem,currentSpecialBountyItem,volcanoMaze1,_lastDailyDungeonRoom,seahorseName,chasmBridgeProgress,_aprilShower,lastAdventure,_floristPlantsUsed,_fireStartingKitUsed,_psychoJarUsed,hiddenHospitalProgress,hiddenBowlingAlleyProgress,hiddenApartmentProgress,hiddenOfficeProgress,pyramidPosition,parasolUsed,_discoKnife,lastPlusSignUnlock];
        
        if (false)
        {
            //Give full description:
            string [string] mafia_properties;
            foreach property_name in relevant_mafia_properties
            {
                mafia_properties[property_name] = get_property(property_name);
            }
            result["mafia properties"] = mafia_properties.to_json();
        }
        else
        {
            //Give partial description: (equivalent for equivalency testing)
            //65% smaller
            buffer mafia_properties;
            boolean first = true;
            foreach property_name in relevant_mafia_properties
            {
                string v = get_property(property_name);
                
                if (first)
                    first = false;
                else
                    mafia_properties.append(",");
                mafia_properties.append(v);
            }
            result["mafia properties"] = mafia_properties.to_string();
        }
        result["logged in"] = playerIsLoggedIn();
    }
    if (false)
    {
        int skill_count = 0;
        foreach s in $skills[]
        {
            if (s.have_skill())
                skill_count += 1;
        }
        result["skill_count"] = skill_count;
    }
    else if (true)
    {
        int relevant_skill_count = 0;
        foreach s in $skills[Gothy Handwave]
        {
            if (s.have_skill())
                relevant_skill_count += 1;
        }
        result["relevant_skill_count"] = relevant_skill_count;
    }
    return result;
}


buffer generateNavbar(Checklist [int] ordered_output_checklists)
{
    buffer navbar;
    if (true)
    {
        //First holding container (fixed):
        string style = "height:" + __setting_navbar_height + ";position:fixed;z-index:1;width:100%;";
        style += "bottom:0px;";
        navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
    if (true)
    {
        //Second holding container:
        string style = "background:" + __setting_navbar_background_color + ";";
        int width = __setting_horizontal_width;
        if (!__setting_fill_vertical)
            width -= 2;
        style += "max-width:" + width + "px;height:" + __setting_navbar_height + ";margin-left:auto; margin-right:auto;font-size:1em;";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
            style += "border-left:1px solid;border-right:1px solid;";
        style += "border-top:1px solid;";
        style += "border-color:" + __setting_line_color + ";";
        navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
    
    string [int] titles;
    foreach key in ordered_output_checklists
        titles.listAppend(ordered_output_checklists[key].title);
    
    if (titles.count() > 0)
    {
        int [int] each_width;
        //Calculate width of each title:
        if (__setting_navbar_has_proportional_widths)
        {
            int total_character_count = 0;
            foreach i in titles
            {
                string title = titles[i];
                int title_length = title.length();
                total_character_count += title_length;
            }
            if (total_character_count > 0)
            {
                foreach i in titles
                {
                    string title = titles[i];
                    float title_length = title.length();
                    
                    float calculating_value = (100.0 * title_length) / (to_float(total_character_count));
                    each_width[i] = floor(calculating_value);
                }					
            }
        }
        else
        {
            float remaining_width = 100.0;
            int number_done = 0;
            foreach i in titles
            {
                int shared_width = to_int(remaining_width / to_float(titles.count() - number_done));
                each_width[i] = shared_width;
                remaining_width -= shared_width;
                number_done += 1;
            }
        }
        boolean first = true;
        foreach i in titles
        {
            string title = titles[i];
            
            string onclick_javascript = "";
            
            //Cancel our usual link:
            onclick_javascript += "navbarClick(event,'" + HTMLConvertStringToAnchorID(title + " checklist container") + "')";
            
            navbar.append(HTMLGenerateTagPrefix("a", mapMake("class", "r_a_undecorated", "href", "#" + HTMLConvertStringToAnchorID(title), "onclick", onclick_javascript)));
            navbar.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_navbar_button_container", "style", "width:" + each_width[i] + "%;")));
            
            //Vertical separator:
            if (first)
                first = false;
            else if (true)
                navbar.append(HTMLGenerateDivOfClass("", "r_navbar_line_separator"));
            
            string text_div = HTMLGenerateDivOfClass(title, "r_navbar_text");
            if (__use_table_based_layouts)
            {
                //Vertical centering with tables:
                navbar.append("<table style=\"border-spacing:0px;margin-left:auto;margin-right:auto;height:100%;\"><tr><td style=\"vertical-align:middle;\">");
                navbar.append(text_div);
                navbar.append("</td></tr></table>");
            }
            else if (true)
            {
                //Vertical centering with divs:
                //Which is to... tell the browser to act like a table.
                //Sorry.
                navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", "padding-left:1px;padding-right:1px;margin-left:auto;margin-right:auto;display:table;height:100%;")));
                navbar.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;vertical-align:middle;")));
                navbar.append(text_div);
                navbar.append("</div>");
                navbar.append("</div>");
            }
            else
            {
                //No vertical centering.
                navbar.append(text_div);
            }
            navbar.append("</div>");
            navbar.append("</a>");
        }
    }
    navbar.append("</div>");
    navbar.append("</div>");
    return navbar;
}


void runMain(string relay_filename)
{
    __relay_filename = relay_filename;

	string [string] form_fields = form_fields();
	if (form_fields["API status"].length() > 0)
	{
        write(generateAPIResponse().to_json());
        return;
	}
    
    set_property_if_changed("__relay_guide_stale_quest_data", "false");
    
	boolean output_body_tag_only = false;
	if (form_fields["body tag only"].length() > 0)
	{
		output_body_tag_only = true;
	}
	
	if (__setting_debug_mode && __setting_debug_enable_example_mode_in_aftercore && get_property_boolean("kingLiberated"))
	{
		__misc_state["Example mode"] = true;
	}
	
	PageInit();
	ChecklistInit();
	setUpCSSStyles();
	
	
	Checklist [int] ordered_output_checklists;
	generateChecklists(ordered_output_checklists);
	
	
	PageSetTitle("Guide");
	
    if (__setting_use_kol_css)
        PageWriteHead(HTMLGenerateTagPrefix("link", mapMake("rel", "stylesheet", "type", "text/css", "href", "/images/styles.css")));
	
	
    if (__relay_filename == "relay_Guide.ash")
        PageSetBodyAttribute("onload", "GuideInit('relay_Guide.ash'," + __setting_horizontal_width + ");");
    //We don't give the javascript __relay_filename, because it's unsafe without escaping, and writing escape functions yourself is a bad plan.
    //So if they rename the file, automatic refreshing and opening in a new window is disabled.
    
    boolean displaying_navbar = false;
	if (__setting_show_navbar)
	{
		if (ordered_output_checklists.count() > 1)
			displaying_navbar = true;
	}
	if (displaying_navbar)
	{
        buffer navbar = generateNavbar(ordered_output_checklists);
        PageWrite(navbar);
	}
	

	int max_width_setting = __setting_horizontal_width;
	
	PageWrite(HTMLGenerateTagPrefix("div", mapMake("class", "r_center", "style", "max-width:" + max_width_setting + "px;"))); //center holding container
	
    if (true)
    {
        //Holding container:
        string style = "";
        style += "max-width:" + max_width_setting + "px;padding-top:5px;padding-bottom:0.25em;";
        if (!__setting_fill_vertical)
            style += "background-color:" + __setting_page_background_color + ";";
        if (!__setting_side_negative_space_is_dark && !__setting_fill_vertical)
        {
            style += "border:1px solid;border-top:0px;border-bottom:1px solid;";
            style += "border-color:" + __setting_line_color + ";";
        }
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", style)));
    }
    
	PageWrite(HTMLGenerateSpanOfStyle("Guide", "font-weight:bold; font-size:1.5em"));
	
	outputChecklists(ordered_output_checklists);
	
    
    if (true)
    {
        //Gray text at the bottom:
        string line;
        line = HTMLGenerateTagWrap("span", "<br>Automatic refreshing disabled.", mapMake("id", "refresh_status"));
        line += HTMLGenerateTagWrap("a", "<br>Written by Ezandora.", mapMake("class", "r_a_undecorated", "href", "showplayer.php?who=1557284", "target", "mainpane"));
        line += "<br>" + __version;
        
        PageWrite(HTMLGenerateDivOfStyle(line, "font-size:0.777em;color:gray;"));
    }
    
	PageWrite("</div>");
	PageWrite("</div>");
	if (displaying_navbar) //in-div spacing at bottom for navbar
		PageWrite(HTMLGenerateDivOfStyle("", "height:" + (__setting_navbar_height_in_em - 0.05) + "em;"));
    
    if (__setting_fill_vertical)
    {
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-1;background-color:" + __setting_page_background_color + ";max-width:" + __setting_horizontal_width + "px;"))); //Color fill
        PageWrite(HTMLGenerateTagWrap("div", "", mapMake("class", "r_vertical_fill", "style", "z-index:-11;border-left:1px solid;border-right:1px solid;border-color:" + __setting_line_color + ";width:" + (__setting_horizontal_width) + "px;"))); //Vertical border lines, empty background
    }
    PageWriteHead("<script type=\"text/javascript\" src=\"relay_Guide.js\"></script>");
    
    if (output_body_tag_only)
    	write(__global_page.body_contents);
    else
		PageGenerateAndWriteOut();
}