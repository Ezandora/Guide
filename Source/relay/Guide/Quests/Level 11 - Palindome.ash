void QLevel11PalindomeInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Palindome");
    if (my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_GREY_GOO) QuestStateParseMafiaQuestPropertyValue(state, "finished");
    state.quest_name = "Palindome Quest";
    state.image_name = "Palindome";
    
    state.state_boolean["Need instant camera"] = false;
    if ($item[photograph of a dog].available_amount() + $item[disposable instant camera].available_amount() == 0 && state.mafia_internal_step < 3)
        state.state_boolean["Need instant camera"] = true;
    if (7270.to_item().available_amount() > 0 || my_path_id() == PATH_POCKET_FAMILIARS || my_path_id() == PATH_G_LOVER)
        state.state_boolean["Need instant camera"] = false;
    
    state.state_boolean["dr. awkward's office unlocked"] = false;
    if (state.mafia_internal_step > 2)
        state.state_boolean["dr. awkward's office unlocked"] = true;
    if (get_property_int("palindomeDudesDefeated") >= 5 && 7262.to_item().available_amount() == 0) //inference
        state.state_boolean["dr. awkward's office unlocked"] = true;
    __quest_state["Level 11 Palindome"] = state;
}

void QLevel11PalindomeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME add whitey's grove fallthrough

	if (!__quest_state["Level 11 Palindome"].in_progress && __quest_state["Level 11"].mafia_internal_step <3) //questL11Palindome unstarted until uncertain time
        return;
    if (__quest_state["Level 11 Palindome"].finished)
        return;
    if (__quest_state["Level 11"].finished)
        return;
    if (__quest_state["Level 11"].mafia_internal_step <3 )
        return;
    if (($item[Staff of Ed\, almost].available_amount() > 0 || $item[2325].available_amount() > 0 || $item[2268].available_amount() > 0) && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Palindome"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url;
    
    if (base_quest_state.mafia_internal_step < 2 && $item[talisman o' namsilat].available_amount() == 0 && $items[Copperhead Charm,Copperhead Charm (rampant)].items_missing().count() == 0)
    {
        url = "craft.php?mode=combine";
        subentry.entries.listAppend("Paste the two copperhead charms together to acquire the talisman o' nam.");
    }
    else if (base_quest_state.mafia_internal_step < 2 && $item[talisman o' namsilat].available_amount() == 0)
    {
        //1 -> find palindome
        url = "place.php?whichplace=cove";
        if (__quest_state["Pirate Quest"].state_boolean["valid"])
        	subentry.entries.listAppend("Find the palindome. The pirates will know the way.");
        else
        {
        	string [int] quests;
            if (!__quest_state["Level 11 Shen"].finished)
            	quests.listAppend("copperhead");
            if (!__quest_state["Level 11 Ron"].finished)
                quests.listAppend("zeppelin");
            subentry.entries.listAppend("Find the palindome by completing the " + quests.listJoinComponents("/") + " quest.");
        }
        
        if (!is_wearing_outfit("Swashbuckling Getup") && $item[pirate fledges].equipped_amount() == 0 && $item[pirate fledges].available_amount() > 0 && false)
        {
            url = "inventory.php?which=2";
            if ($item[pirate fledges].available_amount() > 0 && $item[pirate fledges].can_equip())
            {
                subentry.entries.listAppend("Equip the pirate fledges first.");
                url = generateEquipmentLink($item[pirate fledges]);
            }
            else
                subentry.entries.listAppend("Equip the Swashbuckling Getup first.");
        }
        
        if (!__quest_state["Pirate Quest"].state_boolean["valid"])
        {
        }
        else if ($location[the poop deck].noncombat_queue.contains_text("It's Always Swordfish") || $location[belowdecks].turnsAttemptedInLocation() > 0)
        {
            if ($items[gaudy key,snakehead charrrm].available_amount() < 2)
            {
                if ($items[gaudy key,snakehead charrrm].available_amount() == 0)
                {
                    subentry.modifiers.listAppend("olfact gaudy pirate");
                    string line = "Olfact/copy gaudy pirate belowdecks";
                    line += ".";
                    subentry.entries.listAppend(line);
                }
                else
                    subentry.entries.listAppend("Find a single gaudy pirate.");
            }
            else
                url = "inventory.php?which=3";
            if ($item[gaudy key].available_amount() > 0)
                subentry.entries.listAppend("Use " + $item[gaudy key].pluralise() + ".");
        }
        else if ($item[pirate fledges].available_amount() > 0)
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat on the Poop Deck to unlock belowdecks.");
            subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 1, "unlock belowdecks"));
            
            if (__misc_state["need to level"])// && $location[the poop deck].noncombat_queue.contains_text("O Cap'm"))
            {
                if (my_meat() < 977)
                {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Possibly acquire 977 meat first", "red") + ", to gain extra stats from the other NC.");
                }
                else
                {
                    string coordinates;
                    if (my_primestat() == $stat[muscle])
                        coordinates = "(56, 14)";
                    else if (my_primestat() == $stat[mysticality])
                        coordinates = "(3, 35)";
                    else if (my_primestat() == $stat[moxie])
                        coordinates = "(5, 39)";
                    if (coordinates != "")
                        subentry.entries.listAppend("If you encounter the wheel/O Cap'm adventure, take the helm, and sail to " + coordinates + ". (costs a turn for stats)");
                }
            }
        }
        else
        {
            subentry.entries.listAppend("Do pirate quest first.");
        }
            
    }
    else
    {
        url = "place.php?whichplace=palindome";
        if ($item[talisman o' namsilat].equipped_amount() == 0)
        {
            url = generateEquipmentLink($item[pirate fledges]);
        }
        
        
        /*
        Quest steps:
        Adventure in palindome, acquire:
            photograph of a dog (7263) by taking a picture of one of the racecar twins(?) with a disposable instant camera
            photograph of an ostrich egg (7265)
            photograph of a red nugget (7264)
            photograph of god
            stunt nuts for wet stunt nut stew
            "I Love Me, Vol. I" (7262) (dropped from monster, possibly drab bard?, possibly after rest are available?)
         Use I love me, volume 1. This removes it from your inventory, and unlocks the office.
         Arrange the photographs on the shelf:
            god, red nugget, dog, ostrich egg
        This gives 2 Love Me, Vol. 2 (7270)
        Read it to unlock mr. alarm in left office. It will disappear.
        He'll tell you to go acquire wet stunt nut stew. Adventure in whitey's grove as per usual.
        Cook wet stunt nut stew.
        Go talk to mr. alarm. He'll give a mega gem.
        Go fight Dr. Awkward with both equipped.
        
        */
        
        if ($item[mega gem].available_amount() > 0 || base_quest_state.mafia_internal_step == 5)
        {
            //5 -> fight dr. awkward
            string [int] tasks;
            if ($item[talisman o' namsilat].equipped_amount() == 0)
                tasks.listAppend("equip the Talisman o' Nam");
            if ($item[mega gem].equipped_amount() == 0)
                tasks.listAppend("equip the Mega Gem");
            
            tasks.listAppend("fight Dr. Awkward in his office");
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
        }
        else if (base_quest_state.mafia_internal_step == 3 && 7270.to_item().available_amount() > 0 && false)
        {
            //doesn't seem to work?
            subentry.entries.listAppend("Use 2 Love Me, Vol. 2, then talk to Mr. Alarm in his office.");
        }
        else if (base_quest_state.mafia_internal_step == 4 || base_quest_state.mafia_internal_step == 3)
        {
            //4 -> acquire wet stunt nut stew, give to mr. alarm
            //FIXME handle alternate route
            //step3 not supported yet, so we have this instead:
            if (base_quest_state.mafia_internal_step == 3)
            {
                if (!(7270.to_item().available_amount() > 0 && false))
                    subentry.entries.listAppend("Use 2 Love Me, Vol. 2, then talk to Mr. Alarm in his office. Then:");
            }
            
            if ($item[wet stunt nut stew].available_amount() == 0)
            {
                if (($item[bird rib].available_amount() > 0 && $item[lion oil].available_amount() > 0 || $item[wet stew].available_amount() > 0) && $item[stunt nuts].available_amount() > 0)
                {
                    url = "craft.php?mode=cook";
                    subentry.entries.listAppend("Cook wet stunt nut stew.");
                }
                else
                {
                    url = "place.php?whichplace=woods";
                    subentry.entries.listAppend("Acquire and make wet stunt nut stew.");
                    if ($item[wet stunt nut stew].available_amount() == 0 && $item[stunt nuts].available_amount() == 0)
                        subentry.entries.listAppend("Acquire stunt nuts from Bob Racecar or Racecar Bob in Palindome. (30% drop)");
                    if ($item[wet stew].available_amount() == 0 && ($item[bird rib].available_amount() == 0 || $item[lion oil].available_amount() == 0))
                    {
                        string [int] components;
                        monster [int] monsters_need_to_meet;
                        if ($item[bird rib].available_amount() == 0)
                        {
                            components.listAppend($item[bird rib]);
                            monsters_need_to_meet.listAppend($monster[whitesnake]);
                        }
                        if ($item[lion oil].available_amount() == 0)
                        {
                            components.listAppend($item[lion oil]);
                            monsters_need_to_meet.listAppend($monster[white lion]);
                        }
                        string line = "Adventure in Whitey's Grove to acquire " + components.listJoinComponents("", "and") + ".";
                      
                        line += "|";
                        int food_drop_have = $location[whitey's grove].item_drop_modifier_for_location() + numeric_modifier("food drop");
                        if (food_drop_have >= 300.0)
                        {
                            line += "Have +300% item";
                        }
                        else
                        {
                            line += HTMLGenerateSpanFont("Need +300% item", "red") + " (missing " + (300 - food_drop_have) + "%)";
                        }
                        line += " and +combat.";
                        if (familiar_is_usable($familiar[jumpsuited hound dog]))
                            line += " (hound dog is useful for this)";
                        subentry.entries.listAppend(line);
                      
                        if ($item[white page].available_amount() > 0)
                            subentry.entries.listAppend("Can use your white pages to dial up a " + monsters_need_to_meet.listJoinComponents(", ", "or a") + ".");
                      
                        subentry.modifiers.listAppend("+combat");
                        subentry.modifiers.listAppend("+300% item/food drop");
                        if (__quest_state["Level 6"].finished && !get_property_boolean("friarsBlessingReceived"))
                        {
                            subentry.entries.listAppend("Can use friars blessing for +30% food drop.");
                        }
                        if ($item[Gene Tonic: Goblin].available_amount() > 0 && $effect[Human-Goblin Hybrid].have_effect() == 0)
                        {
                            subentry.entries.listAppend("Use goblin gene tonic for +50% food drop.");
                        }
                        if (!in_hardcore())
                            subentry.entries.listAppend("Or pull wet stew.");
                    }
                    subentry.entries.listAppend("Or try the alternate route in the Palindome.");
                }
            }
            else
            {
                subentry.entries.listAppend("Talk to Mr. Alarm.");
                if ($item[talisman o' namsilat].equipped_amount() == 0)
                    subentry.entries.listAppend("Equip the Talisman o' Nam.");
            }
            //if (7270.to_item() != $item[none] && 7270.to_item().available_amount() > 0)
                //url = "place.php?whichplace=palindome";
        }
        else if (base_quest_state.mafia_internal_step == 3 || 7270.to_item().available_amount() > 0)
        {
            string [int] tasks;
            //talk to mr. alarm to unlock whitey's grove
            if (7270.to_item().available_amount() > 0)
            {
                //url = "inventory.php?which=3";
                tasks.listAppend("use 2 Love Me, Vol. 2");
            }
            if ($item[wet stunt nut stew].available_amount() > 0)
                tasks.listAppend("talk to Mr. Alarm");
            else
                tasks.listAppend("talk to Mr. Alarm to unlock Whitey's Grove");
                
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
            if ($item[talisman o' namsilat].equipped_amount() == 0)
                subentry.entries.listAppend("Equip the Talisman o' Nam.");
        }
        else
        {
            boolean dr_awkwards_office_unlocked = base_quest_state.state_boolean["dr. awkward's office unlocked"]; //no way to track this at the moment
            string single_entry_mode = "";
            boolean need_to_adventure_in_palindome = false;
            boolean need_palindome_location = true;
            
            //Need:
            //√Wet stunt nut stew / stunt nuts
            //√"I Love Me, Vol. I" (7262)
            //√instant camera -> 7263 photograph of a dog
            //√7264 photograph of a red nugget
            //√7265 photograph of an ostrich egg
            //√photograph of god
            subentry.entries.listAppend("Adventure in the palindome.");
            
            if ($item[photograph of a dog].available_amount() == 0)
            {
            	if (my_path_id() == PATH_POCKET_FAMILIARS || my_path_id() == PATH_G_LOVER)
                {
                    need_to_adventure_in_palindome = true;
                    subentry.entries.listAppend("Defeat Bob Racecar or Racecar Bobs until you acquire the photograph of a dog.");
                }
                else if ($item[disposable instant camera].available_amount() == 0)
                {
                    subentry.modifiers.listClear();
                    url = $location[the haunted bedroom].getClickableURLForLocation();
                    single_entry_mode = "Adventure in the haunted bedroom for a disposable instant camera.";
                    int monsters_in_zone = 0;
                    foreach m in $monsters[animated mahogany nightstand,animated ornate nightstand,animated rustic nightstand,elegant animated nightstand,Wardr&ouml;b nightstand]
                    {
                        //monster m = s.to_monster();
                        if (!m.is_banished() || m == $monster[none])
                            monsters_in_zone += 1;
                    }
                    if (monsters_in_zone == 0)
                        monsters_in_zone = 5;
                    
                    if (!in_hardcore() && (get_property("questM21Dance") == "finished" || $location[the haunted ballroom].turnsAttemptedInLocation() > 0 || $item[Lady Spookyraven's finest gown].available_amount() > 0))
                        single_entry_mode += "|Or pull for it. (saves " + pluraliseWordy(monsters_in_zone, "turn", "turns") + ")";
                    need_palindome_location = false;
                }
                else
                {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Photograph Bob Racecar or Racecar Bob", "red") + " with disposable instant camera.");
                    need_to_adventure_in_palindome = true;
                }
            }
            
            if ($item[stunt nuts].available_amount() + $item[wet stunt nut stew].available_amount() == 0 && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
            {
                subentry.modifiers.listAppend("+234% item");
                subentry.entries.listAppend("Possibly acquire stunt nuts from Bob Racecar or Racecar Bob. (30% drop)");
                need_to_adventure_in_palindome = true;
            }
            
            
            string [int] missing_ncs;
            if ($item[photograph of a red nugget].available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of a red nugget");
            }
            if ($item[photograph of an ostrich egg].available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of an ostrich egg");
            }
            if ($item[photograph of god].available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of god");
            }
            if (missing_ncs.count() > 0)
            {
                subentry.modifiers.listAppend("-combat"); //initial spading suggests at least two of these are affected by -combat, need more data
                subentry.entries.listAppend("Find " + missing_ncs.listJoinComponents(", ", "and") + " from non-combats, run -combat");
                need_to_adventure_in_palindome = true;
            }
            
            
            
            
            //This must be after all other need_to_adventure_in_palindome checks:
            if (7262.to_item().available_amount() == 0 && !dr_awkwards_office_unlocked) //I love me, Vol. I
            {
                int dudes_left = clampi(5 - get_property_int("palindomeDudesDefeated"), 0, 5);
                    
                if (__misc_state["have olfaction equivalent"] && __misc_state_string["olfaction equivalent monster"] != "Racecar Bob" && __misc_state_string["olfaction equivalent monster"] != "Bob Racecar" && __misc_state_string["olfaction equivalent monster"] != "Drab Bard" && dudes_left > 1)
                {
                    subentry.modifiers.listAppend("olfact racecar");
                    subentry.entries.listAppend("Olfact Bob Racecar or Racecar Bob.");
                }
                subentry.entries.listAppend("Defeat " + pluraliseWordy(dudes_left, "more dude", "more dudes") + " in the palindome.");
                need_to_adventure_in_palindome = true;
            }
            else if (7262.to_item().available_amount() > 0)
            {
                if (!need_to_adventure_in_palindome)
                {
                    url = "inventory.php?which=3";
                    subentry.entries.listAppend("Use I Love Me, Vol. I. Then place the photographs in Dr. Awkward's Office.");
                }
                else
                {
                    subentry.entries.listAppend("Have I Love Me, Vol. I. Collect photographs and such in the Palindome first.");
                }
            }
            
            if (!need_to_adventure_in_palindome)
            {
                if (subentry.entries contains 0)
                    remove subentry.entries[0]; //remove "Adventure in the palindome" by index - this is hacky
            }
            
            if (!need_to_adventure_in_palindome && dr_awkwards_office_unlocked)
            {
                subentry.modifiers.listClear();
                single_entry_mode = "Place items on shelves in Dr. Awkward's office.|Order is god, red nugget, dog, and ostrich egg.";
            }
                
            if (single_entry_mode != "")
            {
                subentry.entries.listClear();
                subentry.entries.listAppend(single_entry_mode);
            }
            if (need_palindome_location && $item[talisman o' namsilat].equipped_amount() == 0)
                subentry.entries.listAppend("Equip the Talisman o' Nam.");
        }
    }
    
    boolean [location] relevant_locations = makeConstantLocationArrayMutable($locations[the poop deck, belowdecks,cobb's knob laboratory,whitey's grove]);
    relevant_locations[$location[Inside the Palindome]] = true;

    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, relevant_locations));
}
