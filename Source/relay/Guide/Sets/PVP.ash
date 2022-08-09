string SPVPGenerateTooltipForConsumables(string underline_text, boolean [item] consumables, string tooltip_extra_text)
{
    string tooltip_text = consumables.listInvert().listJoinComponents("<hr>");
    tooltip_text += tooltip_extra_text;

    return HTMLGenerateTooltip(underline_text, tooltip_text);
}

string SPVPGenerateTooltipForConsumables(string underline_text, boolean [item] consumables)
{
	return SPVPGenerateTooltipForConsumables(underline_text, consumables, "");
}


void SPVPGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!hippy_stone_broken())
        return;
    if (pvp_attacks_left() > 0 && today_is_pvp_season_end())
    {
        optional_task_entries.listAppend(ChecklistEntryMake(236, "__effect Swordholder", "peevpee.php?place=fight", ChecklistSubentryMake("Run all of your fights", "", listMake("Season ends today.", "Make sure to get the seasonal item if you haven't, as well."))));
    }
    
    int [string] mini_names = current_pvp_stances();
    
    ChecklistEntry entry = ChecklistEntryMake(237);
    
    
    string [int] attacking_description;
    string [int] attacking_modifiers;
    
    string [int] overall_modifiers;
    string [int] overall_description;
    foreach mini in mini_names
    {
    	string [int] modifiers;
        string [int] description;
        if (mini == "Maul Power")
        {
            if ($skill[Kung Fu Hustler].have_skill() && $effect[Kung Fu Fighting].have_effect() == 0)
                attacking_description.listPrepend("run a combat without a weapon first");
            attacking_modifiers.listAppend("weapon damage");
            continue;
        }
        else if (mini == "15 Minutes of Fame" || mini == "Beary Famous" || mini == "Upward Mobility Contest" || mini == "Optimal PvP")
        {
            //attacking_description.listAppend("hit for fame");
            attacking_description.listAppend("maximise fightgen and hit for fame");
            continue;
        }
        else if (mini == "80 Days and Counting")
        {
            description.listAppend("Drink Around the Worlds.");
            if (have_outfit_components("Hodgman's Regal Frippery"))
            {
            	if (get_property_int("_hoboUnderlingSummons") < 5)
	            	description.listAppend("Equip Hodgman's Regal Frippery, summon hobo underling, ask for a drink."); 
            }
            else if (QuestState("questL12War").mafia_internal_step == 2)
            {
            	description.listAppend("Finish the war.");
            }
            else if ($item[Spanish fly trap].available_amount() == 0)
            {
            	modifiers.listAppend("-combat");
                if ($location[Frat House].noncombat_queue.contains_text("I Just Wanna Fly") || $location[The Orcish Frat House (Bombed Back to the Stone Age)].noncombat_queue.contains_text("Me Just Want Fly"))
                {
                    description.listAppend("Run -combat in The Obligatory Pirate's Cove, acquire Spanish fly trap.");
                }
            	else
             	   description.listAppend("Adventure in the Orcish Frat House until you meet the I Just Wanna Fly adventure.|Then run -combat in The Obligatory Pirate's Cove, acquire Spanish fly trap.");
            }
            else
            {
                string [int] tasks;
            	if ($item[Spanish fly trap].equipped_amount() == 0)
                {
                	tasks.listAppend("equip Spanish fly trap");
                }
                modifiers.listAppend("+item");
                tasks.listAppend("adventure in the Hippy Camp, collecting spanish flies");// + (my_level() >= 9 ? " (+combat)" : ""));
                if ($item[Spanish fly].available_amount() >= 5)
                	tasks.listAppend("turn in " + pluralise($item[Spanish fly]) + " in the orcish frat house (-combat)");
                description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
            }
        }
        else if (mini == "Totally Optimal")
        {
        	if (__quest_state["Level 11 Ron"].state_int["protestors remaining"] > 0)
                description.listAppend("Fight zeppelin protestors, and don't try to speed them up.");
            else
        		description.listAppend("Ascend to fight more Zeppelin Protestors.");
        }
        else if (mini == "Optimal Drinking")
        {
        	if (inebriety_limit() == 0)
            	description.listAppend("Ascend a path you can drink on.");
            else
	        	description.listAppend("When drinking, prefer drinks that have effects.");
        }
        else if (mini == "Nog Lover" || mini == "Nog Lover ") //it has a space at the end?
        {
        	if (inebriety_limit() == 0)
            	description.listAppend("Ascend a path you can drink on.");
            else
            {
                boolean [item] consumables = $items[eggnog, spooky eggnog, nanite-infested eggnog, gamma nog, green eggnog, oozenog, robin nog, haunted eggnog];

	        	description.listAppend(SPVPGenerateTooltipForConsumables("Drink eggnog.", consumables));
            }
        }
        else if (mini == "What's in the Basket?")
        {
        	if (fullness_limit() == 0)
            	description.listAppend("Ascend a path you can eat on.");
            else
            {
                boolean [item] consumables = $items[Boris's key lime pie,Jarlsberg's key lime pie,Sneaky Pete's key lime pie,digital key lime,star key lime,digital key lime pie,star key lime pie];

	        	description.listAppend(SPVPGenerateTooltipForConsumables("Eat key lime pie.", consumables));
            }
        }
        else if (mini == "Briniest Liver")
        {
        	if (inebriety_limit() == 0)
            	description.listAppend("Ascend a path you can drink on.");
            else
            {
                boolean [item] consumables = $items[Alewife&trade; Ale, dew yoana lei, dew yoana salacious lei, lychee chuhai, salacious lychee chuhai, salacious screwdiver, salinated mint julep, screwdiver, slug of vodka, slug of rum, slug of shochu];

	        	description.listAppend(SPVPGenerateTooltipForConsumables("Drink drinks that give the Brined Liver effect.", consumables));
                description.listAppend("Possibly use mayozapine if you have that IOTM.");
            }
        }
        else if (mini == "Hibernation Preparation" || mini == "Freshman Fifteen")
        {
        	modifiers.listAppend("+familiar experience");
        	description.listAppend("Gain as much familiar experience as possible.|Ideally, run +familiar experience against free fights.");
        }
        else if (mini == "Familiar Rotation")
        {
        	if (in_ronin())
	        	description.listAppend("Pick a different familiar than your last ascensions this season.");
            else
                description.listAppend("Ascend to rotate your familiar.");
        }
        else if (mini == "Foreigner Reference")
        {
            description.listAppend("Drink ice-cold Sir Schlitzs or ice-cold Willers." + (in_ronin() ? "|The Orcish Frat House has them. Run +400% item" + (my_level() >= 9 ? " and +15% combat." : "") : ""));
        }
        else if (mini == "Best Served Repeatedly")
        {
            description.listAppend("Attack the same target repeatedly. Ideally, lose.");
        }
        else if (mini == "Burrowing Deep" || mini == "Obviously Optimal" || mini == "Gargle Blaster Collector" || mini == "Holiday Shopping")
        {
        	if (__misc_state_int["Basement Floor"] > 400)
            {
            	description.listAppend("Ascend to basement more.");
            }
            else if (__misc_state_int["Basement Floor"] <= 1) //this test could be better
            {
            	description.listAppend("Unlock Fernswarthy's basement via your guild.");
            }
            else
            {
            	int floors_remaining = 200 - __misc_state_int["Basement Floor"];
                if (floors_remaining < 0)
                	floors_remaining = 400 - __misc_state_int["Basement Floor"];
	            description.listAppend("Collect a Pan-Dimensional Gargle Blaster from Fernswarthy's basement. " + pluraliseWordy(floors_remaining, "floor", "floors") + " to go.");
            }
        }
        else if (mini == "Frostily Ephemeral" || mini == "Newest Born" || mini == "SELECT asc_time FROM zzz_players WHERE player_id=%playerid%" || mini == "Optimal Ascension" || mini  == "Freshman Rule!")
        {
            description.listAppend("Ascend to reset timer.");
        }
        else if (mini == "Karrrmic Battle" || mini == "Karmic Battle" || mini == "On the Nice List" || mini == "Lifelong Learning")
        {
            description.listAppend("Ascend to gain more karma.");
        }
        else if (mini == "Back to Square One")
        {
            description.listAppend("Ascend.");
        }
        else if (mini == "Baker's Dozen")
        {
            description.listAppend("Adventure as often as possible in Madness Bakery.");
        }
        else if (mini == "Fahrenheit 451" || mini == "Hot for Teacher")
        {
            attacking_modifiers.listAppend("hot damage");
            attacking_modifiers.listAppend("hot spell damage");
            continue;
        }
        else if (mini == "I Like Pi")
        {
            description.listAppend("Eat key lime pies.");
        }
        else if (mini == "School Lunch")
        {
            description.listAppend("Eat pizza.");
        }
        else if (mini == "HTTP 301 Moved Permanently")
        {
            description.listAppend("Adventure in as many different locations as you can.");
        }
        else if (mini == "Quality Assurance")
        {
            description.listAppend("Defeat bug-phylum monsters.");
        }
        else if (mini == "Free.Willy.1993.1080p.BRRip.x265.torrent")
        {
            description.listAppend("Fight dolphins.|Farm sand dollars, turn them into dolphin whistles, and use them.");
        }
        else if (mini == "Installation Wizard")
        {
            modifiers.listAppend("+item");
            if (!canadia_available())
            {
                description.listAppend("Farm dilapidated wizard hats from copied swamp owls.|Or ascend canadia moon sign.");
            }
            else
            {
            	description.listAppend("Farm dilapidated wizard hats from swamp owls in The Weird Swamp Village.");
            }
        }
        else if (mini == "Who's the Boss?")
        {
            description.listAppend("Fight school of wizardfish in the Briny Deeps, repeatedly.|Or school of many in the The Caliginous Abyss.|Or the school of gummi piranhas in the Sweet-Ade Lake. (best)");
        }
        else if (mini == "The Chalk Dust Fiasco")
        {
            description.listAppend("Fight chalkdust wraiths in the Haunted Billiards Room, repeatedly.");
        }
        else if (mini == "Conservational Yule")
        {
            if (!canadia_available())
            {
                description.listAppend("Fight copied lumberjacks.|Or ascend canadia moon sign.");
            }
            else
            {
            	description.listAppend("Fight lumberjacks in Camp Logging Camp.");
            }
        }
        else if (mini == "Illegal Operation")
        {
            description.listAppend("Buy goofballs from the suspicious-looking guy. If they're too expensive, ascend to reset the price.");
        }
        else if (mini == "Fotoshop.CS11.Keygen.exe [legit]")
        {
            description.listAppend("Eat digital key lime pies.");
        }
        else if (mini == "Most Murderous" || mini == "Icy Revenge")
        {
        	//FIXME list
            description.listAppend("Defeat once/ascension bosses.");
        }
        else if (mini == "Grave Robbery" || mini == "Bear Hunter")
        {
        	if ($item[wand of nagamar].available_amount() > 0)
				description.listAppend("Ascend.");
            else
                description.listAppend("Avoid making the wand of nagamar, lose to the naughty sorceress (3), and look for the wand in the very unquiet garves");
        }
        else if (mini == "Basket Reaver")
        {
        	if (my_level() < 11)
            {
            	description.listAppend("Level up.");
            }
            else
            {
                modifiers.listAppend("+5% combat");
                modifiers.listAppend("olfact black widow");
                modifiers.listAppend("+item");
                description.listAppend("Run +item% and farm black widows in the black forest.");
            }
        }
        else if (mini == "Rule 42")
        {
        	if ($location[the Haunted Bathroom].noncombat_queue.contains_text("Off the Rack")) //not perfect
         		continue;   
        	modifiers.listAppend("-combat");
            if ($location[the Haunted Bathroom].locationAvailable())
	            description.listAppend("Collect a towel in the Haunted Bathroom.");
            else
                description.listAppend("Unlock the Haunted Bathroom in Spookyraven Manor.");
        }
        else if (mini == "Tea for 2, 3, 4 or More")
        {
        	boolean [item] consumables = $items[Corpse Island iced tea,cup of lukewarm tea,cup of &quot;tea&quot;,hippy herbal tea,Ice Island Long Tea,New Zealand iced tea];
            
            description.listAppend(SPVPGenerateTooltipForConsumables("Drink tea.", consumables, "<hr>Cheapest is cup of lukewarm tea.<hr>Hippy herbal tea is guano coffee cup (bat guano, batrat, batrat burrow) + herbs (hippy store)."));
        }
        else if (mini == "Scurvy Challenge")
        {
            boolean [item] consumables = $items[grapefruit,kumquat,lemon,lime,orange,pixel lemon,sea tangelo,tangerine,vinegar-soaked lemon slice];
            
            description.listAppend(SPVPGenerateTooltipForConsumables("Eat fruit.", consumables, "<hr>Check the hippy store, on the island."));
        }
        else if (mini == "Raw Carnivorery")
        {
        	//FIXME This could be dynamic, I bet the game is dynamic.
            boolean [item] meat = $items[beefy fish meat, glistening fish meat, slick fish meat, &quot;meat&quot; stick, raw mincemeat, alien meat, dead meat bun, consummate meatloaf, VYKEA meatballs];
            
            string [int] entries;
            foreach it in meat
            {
            	string entry = it;
                if (entries.count() == 0) entry = entry.capitaliseFirstLetter();
            	if (it.fullness == 1)
                	entry = HTMLGenerateSpanOfClass(entry, "r_bold");
                entries.listAppend(entry);
            }
            
            string tooltip_text = entries.listJoinComponents("<hr>");
            
            description.listAppend(HTMLGenerateTooltip("Eat meat.", tooltip_text));
        }
        else if (mini == "That Britney Spears Number")
        {
        	string [int] tasks;
            if ($item[wooden stakes].available_amount() == 0)
            {
                description.listAppend("Adventure in the Spooky Forest, collect wooden stakes from the noncombat.");
                description.listAppend("Follow the old road " + __html_right_arrow_character + " Knock on the cottage door.");
                modifiers.listAppend("-combat");
            }
            else
            {
                if ($item[wooden stakes].equipped_amount() == 0)
                {
                    tasks.listAppend("equip wooden stakes");
                }
                modifiers.listAppend("olfact spooky vampire");
                tasks.listAppend("fight vampires in the Spooky Forest");
                description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
            }
        }
        else if (mini == "The Purity is Right" || mini == "Polar Envy" || mini == "Purity" || mini == "An Open Mind")
        {
            attacking_description.listAppend("run zero effects");
            continue;
        }
        else if (mini == "Purrrity")
        {
            attacking_description.listAppend("run zero effects with R in their name");
            continue;
        }
        else if (mini == "The Optimal Stat")
        {
            attacking_modifiers.listAppend("+item drop");
            continue;
        }
        else if (mini == "A Nice Cold One" || mini == "Thirrrsty forrr Booze" || mini == "Holiday Spirit(s)!")
        {
            attacking_modifiers.listAppend("+booze drop");
            continue;
        }
        else if (mini == "Smellin' Like a Stinkin' Rose" || mini == "Peace on Earth")
        {
            attacking_modifiers.listAppend("-combat");
            continue;
        }
        else if (mini == "Ready to Melt")
        {
            attacking_modifiers.listAppend("hot damage");
            attacking_modifiers.listAppend("hot spell damage");
            continue;
        }
        else if (mini == "Zero Tolerance")
        {
        	description.listAppend("Don't drink booze.");
        }
        else if (mini == "Biggest Fruitcake")
        {
        	description.listAppend("Eat cake and fruit.");
        }
        else if (mini == "Visiting the Cousins" || mini == "Visiting The Co@^&$`~")
        {
        	if (knoll_available())
                description.listAppend("Adventure in the bugbear pens.");
            else
				description.listAppend("Ascend knoll moon sign.");
        }
        else if (mini == "Craft Brew is Optimal")
        {
            if (gnomads_available())
                description.listAppend("Drink from the Gnomish Microbrewery.");
            else
                description.listAppend("Ascend Gnomish moon sign.");
        }
        else if (mini == "Who Runs Bordertown?" || mini == "Spirit of Gnoel")
        {
        	if (gnomads_available())
                description.listAppend("Adventure in the Thugnderdome.");
            else
                description.listAppend("Ascend Gnomish moon sign.");
        }
        else if (mini == "Pirate Wars!")
        {
        	description.listAppend("Fight pirates, but not too many; the count resets every day.");
        }
        else if (mini == "Bilge Hunter")
        {
            description.listAppend("Run +300 ML and +combat, and fight drunken rat kings in the Typical Tavern basement.");
            modifiers.listAppend("+300 ML");
            modifiers.listAppend("+combat");
        }
        else if (mini == "Death to Ninja!")
        {
        	string [int] tasks;
            if (!is_wearing_outfit("Swashbuckling Getup"))
            	tasks.listAppend("equip swashbuckling getup");
            tasks.listAppend("fight ninja");
            description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        }
        else if (mini == "Swimming with the Fishes")
        {
            description.listAppend("Spend turns underwater.");
        }
        else if (mini == "(Fur) Shirts and Skins")
        {
            description.listAppend("Collect furs and skins from monsters. (+item)|The icy peak? Olfact yeti.");
        }
        else if (mini == "With Your Bare Hands")
        {
            description.listAppend("Fight beast-type monsters without a weapon equipped.|The icy peak (olfact yeti) or the dire warren?");
        }
        else if (mini == "Daily Optimizer")
        {
            description.listAppend("Run +adventures gear at rollover.");
        }
        else if (mini == "Northern Digestion" || mini == "Frozen Dinners")
        {
        	if (canadia_available())
            {
            	if (availableFullness() > 0)
	                description.listAppend("Eat in Chez Snoteé.");
            }
            else
                description.listAppend("Ascend canadia moon sign.");
        }
        else if (mini == "ERR_VOLUME_FULL")
        {
            description.listAppend("Don't eat anything.");
        }
        else if (mini == "Really Bloody")
        {
        	if (inebriety_limit() == 0)
    	        description.listAppend("Ascend to drink Bloody Mary.");
            else
	            description.listAppend("Drink Bloody Mary.");
        }
        else if (mini == "System Clock Reset: It's 2006 again!")
        {
            if (inebriety_limit() == 0)
                description.listAppend("Ascend to drink White Canadians.");
            else
                description.listAppend("Drink White Canadians.");
        }
        else if (mini == "Liver of the Damned")
        {
            if (inebriety_limit() == 0)
                description.listAppend("Ascend to drink cursed bottles of rum.");
            else
                description.listAppend("Drink cursed bottles of rum.");
            description.listAppend("Run -combat at the Poop Deck, set an open course to 1,1, open the cursed chests.");
            modifiers.listAppend("-combat");
        }
        else if (mini == "Beast Master")
        {
            attacking_modifiers.listAppend("familiar weight");
            continue;
        }
        else if (mini == "Letter of the Moment" || mini == "Spirit Day")
        {
            attacking_modifiers.listAppend("letter of the moment");
            continue;
        }
        else if (mini == "ASCII-7 of the moment")
        {
            attacking_modifiers.listAppend("letter <strong>a</strong> in equipment");
            continue;
        }
        else if (mini == "Spirit of Noel")
        {
            attacking_modifiers.listAppend("letter <strong>L</strong> in equipment");
            continue;
        }
        else if (mini == "Barely Dressed")
        {
            attacking_description.listAppend("do not equip equipment");
            continue;
        }
        else if (mini == "DEFACE")
        {
            attacking_description.listAppend("wear equipment with A/B/C/D/E/F/numbers in them");
            continue;
        }
        else if (mini == "Dressed to the 9s")
        {
            attacking_description.listAppend("wear equipment with numbers in them");
            continue;
        }
        else if (mini == "Most Unbalanced")
        {
            attacking_description.listAppend("maximise mainstat, minimise off-stats");
            continue;
        }
        else if (mini == "Well-Rounded")
        {
            attacking_description.listAppend("maximise off-stats");
            continue;
        }
        else if (mini == "School Pride")
        {
            attacking_description.listAppend("wear high-power shirt/hat/pants");
            continue;
        }
        else if (mini == "Optimal Dresser" || mini == "Lightest Load")
        {
            attacking_description.listAppend("wear low-power shirt/hat/pants");
            continue;
        }
        else if (mini == "Dressed in Rrrags" || mini == "Outfit Compression")
        {
            attacking_description.listAppend("wear short-named equipment");
            continue;
        }
        else if (mini == "Verbosity Demonstration")
        {
            attacking_description.listAppend("wear long-named equipment");
            continue;
        }
        else if (mini == "Hibernation Ready" || mini == "All Bundled Up")
        {
            attacking_modifiers.listAppend("cold resistance");
            continue;
        }
        else if (mini == "Loot Hunter" || mini == "The Optimal Stat")
        {
            attacking_modifiers.listAppend("+item");
            continue;
        }
        else if (mini == "Safari Chic")
        {
            attacking_modifiers.listAppend("equipment autosell value");
            continue;
        }
        else if (mini == "Checking It Twice")
        {
            attacking_description.listAppend("target players you haven't fought twice");
            continue;
        }
        else if (mini == "Ice Hunter")
        {
            description.listAppend("Fight ice skates. Either fax/wish/copy them, or olfact them in the The Skate Park underwater.");
        }
        else if (mini == "Bearly Legal")
        {
        	modifiers.listAppend("+meat");
            description.listAppend("Fight Mer-kin Miners with +meat. Either fax/wish/copy them, or olfact them in the Anemone Mine underwater.");
        }
        else if (mini == "Bear Hugs All Around" || mini == "Sharing the Love (to stay warm)" || mini == "Fair Game")
        {
            description.listAppend("Maximise fightgen, attack as many unique opponents as possible.");
        }
        else if (mini == "Most Things Eaten")
        {
        	string line = "Eat as many one-fullness foods as possible.";
            if (get_campground()[$item[portable mayo clinic]] > 0 && availableDrunkenness() > 0)
                line += "|Also use mayodiol.";
            description.listAppend(line);
        }
        else if (mini == "Creative Holiday Feasting")
        {
            description.listAppend("Eat as many unique foods as possible, ideally 1-fullness.");
        }
        else if (mini == "Horizon Broadening")
        {
            description.listAppend("Drink as many unique drinks as possible, ideally 1-inebriety.");
        }
    	else if (mini == "Getting in the Holiday Spirits")
        {
            description.listAppend("Drink as many one-inebriety drinks as possible.");
        }   
        else if (mini == "What is it Good For?" || mini == "Beta Tester" || mini == "Optimal War" || mini == "Decisions, decisions?")
        {
            if (__quest_state["Level 12"].finished)
            {
                description.listAppend("Ascend to fight in war.");
            }
            else if (!__quest_state["Level 12"].started)
            {
                description.listAppend("Start the war.");
            }
            else
            {
            	if (mini == "Beta Tester" || mini == "Optimal War")
                {
                	description.listAppend("Finish the war for the frat side, with five sidequests completed. (iron beta of industry reward)");
                }
                else if (mini == "Snow Patrol")
                {
                    modifiers.listAppend("+4 cold res");
                    string line = "Fight on the battlefield";
                    if (numeric_modifier("cold resistance") < 4)
                        line += HTMLGenerateSpanFont(" with +4 cold resistance", "red");
                    line += ".";
                    description.listAppend(line);
                }
                else if (mini == "What is it Good For?" || mini == "Decisions, decisions?")
                {
                	description.listAppend("Spend as many turns in the war as possible.");
                }
            }
        }
        else
        {
            description.listAppend(HTMLGenerateSpanFont("Unknown mini \"" + mini + "\".", "red"));
        }
        overall_modifiers.listAppendList(modifiers);
        if (description.count() > 0)
	        overall_description.listAppend(description.listJoinComponents("|*"));
        //entry.subentries.listAppend(ChecklistSubentryMake(mini, modifiers, description));
    }
    if (overall_description.count() > 0)
    {
    	entry.subentries.listAppend(ChecklistSubentryMake("Work on PVP minis", overall_modifiers, overall_description));
    }
    if (attacking_modifiers.count() > 0)
    	attacking_description.listAppend("maximise " + attacking_modifiers.listJoinComponents(" / "));
    if (attacking_description.count() > 0)
    {
        entry.subentries.listAppend(ChecklistSubentryMake("When attacking", attacking_modifiers, attacking_description.listJoinComponents(", ", "and ").capitaliseFirstLetter() + "."));
    }
    
    if (entry.subentries.count() > 0)
    {
        entry.image_lookup_name = "__effect Swordholder";
        entry.url = "peevpee.php";
        entry.importance_level = 10;
        entry.ChecklistEntrySetAbridgedHeader(pluralise(pvp_attacks_left(), "PVP fight", "PVP fights"));
        optional_task_entries.listAppend(entry);
    }
}
