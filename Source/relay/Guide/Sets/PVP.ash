void SPVPGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!hippy_stone_broken())
        return;
    if (pvp_attacks_left() > 0 && today_is_pvp_season_end())
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__effect Swordholder", "peevpee.php?place=fight", ChecklistSubentryMake("Run all of your fights", "", listMake("Season ends today.", "Make sure to get the seasonal item if you haven't, as well."))));
    }
    
    int [string] mini_names = current_pvp_stances();
    
    ChecklistEntry entry;
    
    
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
        else if (mini == "15 Minutes of Fame" || mini == "Beary Famous" || mini == "Upward Mobility Contest")
        {
            //attacking_description.listAppend("maximise fightgen and hit for fame");
            attacking_description.listAppend("hit for fame");
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
        else if (mini == "Foreigner Reference")
        {
            description.listAppend("Drink ice-cold Sir Schlitzs or ice-cold Willers." + (in_ronin() ? "|The Orcish Frat House has them." : ""));
        }
        else if (mini == "Best Served Repeatedly")
        {
            description.listAppend("Attack the same target repeatedly. Ideally, lose.");
        }
        else if (mini == "Burrowing Deep")
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
        else if (mini == "Frostily Ephemeral")
        {
            description.listAppend("Ascend to reset timer.");
        }
        else if (mini == "Back to Square One")
        {
            description.listAppend("Ascend for new wand.");
        }
        else if (mini == "Baker's Dozen")
        {
            description.listAppend("Adventure as often as possible in Madness Bakery.");
        }
        else if (mini == "Fahrenheit 451")
        {
            attacking_modifiers.listAppend("hot damage");
            attacking_modifiers.listAppend("hot spell damage");
            continue;
        }
        else if (mini == "I Like Pi")
        {
            description.listAppend("Eat key lime pies.");
        }
        else if (mini == "Most Murderous")
        {
        	//FIXME list
            description.listAppend("Defeat once/ascension bosses.");
        }
        else if (mini == "Grave Robbery")
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
        	boolean [item] tea = $items[Corpse Island iced tea,cup of lukewarm tea,cup of &quot;tea&quot;,hippy herbal tea,Ice Island Long Tea,New Zealand iced tea];
            //description.listAppend("Drink tea.|" + );
            
            string tooltip_text = tea.listInvert().listJoinComponents(", ", "or") + ".";
            tooltip_text += "<hr>Cheapest is cup of lukewarm tea.<hr>Hippy herbal tea is guano coffee cup (bat guano, batrat, batrat burrow) + herbs (hippy store).";
            
            string title = HTMLGenerateSpanOfClass(HTMLGenerateSpanOfClass(tooltip_text, "r_tooltip_inner_class") + "Drink tea.", "r_tooltip_outer_class");
            description.listAppend(title);
            
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
        else if (mini == "The Purity is Right" || mini == "Polar Envy" || mini == "Purity")
        {
            attacking_description.listAppend("run zero effects");
            continue;
        }
        else if (mini == "A Nice Cold One")
        {
            attacking_modifiers.listAppend("+booze drop");
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
        else if (mini == "Visiting the Cousins")
        {
        	if (knoll_available())
                description.listAppend("Adventure in the bugbear pens.");
            else
				description.listAppend("Ascend knoll moon sign.");
        }
        else if (mini == "Who Runs Bordertown?")
        {
        	if (gnomads_available())
                description.listAppend("Adventure in the Thugnderdome.");
            else
                description.listAppend("Ascend Gnomish moon sign.");
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
        else if (mini == "Barely Dressed")
        {
            attacking_description.listAppend("do not equip equipment");
            continue;
        }
        else if (mini == "Hibernation Ready" || mini == "All Bundled Up")
        {
            attacking_modifiers.listAppend("cold resistance");
            continue;
        }
        else if (mini == "Ice Hunter")
        {
            description.listAppend("Fight ice skates. Either fax/wish/copy them, or olfact them in the The Skate Park underwater.");
        }
        else if (mini == "Bear Hugs All Around" || mini == "Sharing the Love (to stay warm)")
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
        else if (mini == "Snow Patrol")
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
            	modifiers.listAppend("+4 cold res");
                string line = "Fight on the battlefield";
                if (numeric_modifier("cold resistance") < 4)
                	line += HTMLGenerateSpanFont(" with +4 cold resistance.", "red");
                line += ".";
                description.listAppend(line);
            }
        }
        else
        {
        	if (my_id() == 1557284)
	        	description.listAppend(HTMLGenerateSpanFont("Unhandled mini \"" + mini + "\".", "red"));
            else
        		continue;
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
        entry.subentries.listAppend(ChecklistSubentryMake("When attacking", "", attacking_description.listJoinComponents(", ", "and ").capitaliseFirstLetter() + "."));
    }
    
    if (entry.subentries.count() > 0)
    {
        entry.image_lookup_name = "__effect Swordholder";
        entry.url = "peevpee.php";
        entry.importance_level = 6;
        optional_task_entries.listAppend(entry);
    }
}
