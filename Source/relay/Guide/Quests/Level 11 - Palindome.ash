void QLevel11PalindomeInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Palindome");
    state.quest_name = "Palindome Quest";
    state.image_name = "Palindome";
    
    state.state_boolean["Need instant camera"] = false;
    if (lookupItem("photograph of a dog").available_amount() + lookupItem("disposable instant camera").available_amount() == 0 && state.mafia_internal_step < 3 && mafiaIsPastRevision(13870))
        state.state_boolean["Need instant camera"] = true;
    if (7270.to_item().available_amount() > 0)
        state.state_boolean["Need instant camera"] = false;
    
    state.state_boolean["dr. awkward's office unlocked"] = false;
    if (state.mafia_internal_step > 2)
        state.state_boolean["dr. awkward's office unlocked"] = true;
    __quest_state["Level 11 Palindome"] = state;
}

void QLevel11PalindomeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //FIXME add whitey's grove fallthrough

	if (!__quest_state["Level 11 Palindome"].in_progress && __quest_state["Level 11"].mafia_internal_step <3) //questL11Palindome unstarted until uncertain time
        return;
    if (__quest_state["Level 11"].finished)
        return;
    if (__quest_state["Level 11"].mafia_internal_step <3 )
        return;
    if ($items[staff of fats,Staff of Ed\, almost,Staff of Ed].available_amount() > 0)
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Palindome"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url;
    
    if (base_quest_state.mafia_internal_step < 2 && $item[talisman o' nam].available_amount() == 0)
    {
        //1 -> find palindome
        url = "place.php?whichplace=cove";
        subentry.entries.listAppend("Find the palindome. The pirates will know the way.");
        
        if (!is_wearing_outfit("Swashbuckling Getup") && $item[pirate fledges].equipped_amount() == 0)
            url = "inventory.php?which=2";
            
        if ($location[the poop deck].noncombat_queue.contains_text("It's Always Swordfish") || $location[belowdecks].turnsAttemptedInLocation() > 0)
        {
            if ($items[gaudy key,snakehead charrrm].available_amount() < 2)
            {
                subentry.modifiers.listAppend("olfact gaudy pirate");
                string line = "Olfact/copy gaudy pirate belowdecks";
                if (!__quest_state["Level 13"].state_boolean["have relevant guitar"])
                {
                    line += ", and possibly run +400% item to find a guitar";
                    subentry.modifiers.listAppend("+400% item");
                    if ($familiar[slimeling].familiar_is_usable())
                        subentry.modifiers.listAppend("slimeling?");
                }
                line += ".";
                subentry.entries.listAppend(line);
            }
            else
                url = "inventory.php?which=3";
            if ($item[gaudy key].available_amount() > 0)
                subentry.entries.listAppend("Use " + $item[gaudy key].pluralize() + ".");
        }
        else
        {
            subentry.modifiers.listAppend("-combat");
            subentry.entries.listAppend("Run -combat on the Poop Deck to unlock belowdecks.");
            subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 1, "unlock belowdecks"));
        }
            
    }
    else
    {
        url = "place.php?whichplace=palindome";
        if ($item[talisman o' nam].equipped_amount() == 0)
            url = "inventory.php?which=2";
        
        
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
            if ($item[talisman o' nam].equipped_amount() == 0)
                tasks.listAppend("equip the Talisman o' Nam");
            if ($item[mega gem].equipped_amount() == 0)
                tasks.listAppend("equip the Mega Gem");
            
            tasks.listAppend("fight Dr. Awkward in his office");
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
        }
        else if (base_quest_state.mafia_internal_step == 3 && 7270.to_item().available_amount() > 0 && mafiaIsPastRevision(14644) && false)
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
                if (!(7270.to_item().available_amount() > 0 && mafiaIsPastRevision(14644) && false))
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
                        if ($item[bird rib].available_amount() == 0)
                            components.listAppend($item[bird rib]);
                        if ($item[lion oil].available_amount() == 0)
                            components.listAppend($item[lion oil]);
                        string line = "Adventure in Whitey's Grove to acquire " + components.listJoinComponents("", "and") + ".|Need +300% item and +combat.";
                        if (familiar_is_usable($familiar[jumpsuited hound dog]))
                            line += " (hound dog is useful for this)";
                        subentry.entries.listAppend(line);
                      
                        if (lookupItem("white page").available_amount() > 0)
                            subentry.entries.listAppend("Can use your white pages to dial them up.");
                      
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
                if ($item[talisman o' nam].equipped_amount() == 0)
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
                
            subentry.entries.listAppend(tasks.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".");
            if ($item[talisman o' nam].equipped_amount() == 0)
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
            
            if (lookupItem("photograph of a dog").available_amount() == 0)
            {
                if (lookupItem("disposable instant camera").available_amount() == 0)
                {
                    subentry.modifiers.listClear();
                    url = $location[the haunted bedroom].getClickableURLForLocation();
                    single_entry_mode = "Adventure in the haunted bedroom for a disposable instant camera.";
                    int monsters_in_zone = 0;
                    foreach s in $strings[animated mahogany nightstand,animated ornate nightstand,animated rustic nightstand,elegant animated nightstand,Wardr&ouml;b nightstand]
                    {
                        monster m = s.to_monster();
                        if (!m.is_banished() || m == $monster[none])
                            monsters_in_zone += 1;
                    }
                    if (monsters_in_zone == 0)
                        monsters_in_zone = 5;
                    
                    if (!in_hardcore() && (get_property("questM21Dance") == "finished" || $location[the haunted ballroom].turnsAttemptedInLocation() > 0 || lookupItem("Lady Spookyraven's finest gown").available_amount() > 0))
                        single_entry_mode += "|Or pull for it. (saves " + pluralizeWordy(monsters_in_zone, "turn", "turns") + ")";
                    need_palindome_location = false;
                }
                else
                {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Photograph Bob Racecar or Racecar Bob", "red", "") + " with disposable instant camera.");
                    need_to_adventure_in_palindome = true;
                }
            }
            
            if ($item[stunt nuts].available_amount() + $item[wet stunt nut stew].available_amount() == 0 )
            {
                subentry.modifiers.listAppend("+234% item");
                subentry.entries.listAppend("Possibly acquire stunt nuts from Bob Racecar or Racecar Bob. (30% drop)");
                need_to_adventure_in_palindome = true;
            }
            
            
            string [int] missing_ncs;
            if (lookupItem("photograph of a red nugget").available_amount() == 0)
            {
                missing_ncs.listAppend("photograph of a red nugget");
            }
            if (lookupItem("photograph of an ostrich egg").available_amount() == 0)
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
                if (__misc_state["have olfaction equivalent"] && __misc_state_string["olfaction equivalent monster"] != "Racecar Bob" && __misc_state_string["olfaction equivalent monster"] != "Bob Racecar" && __misc_state_string["olfaction equivalent monster"] != "Drab Bard")
                {
                    subentry.modifiers.listAppend("olfact racecar");
                    subentry.entries.listAppend("Olfact Bob Racecar or Racecar Bob.");
                }
                string line = "Find I Love Me, Vol. I in-combat. Fifth dude-type monster.";
                if (!need_to_adventure_in_palindome) //counts stunt nuts and photographs
                    line += "|Well, unless you have already. If so, place the photographs in Dr. Awkward's Office.";
                else
                    line += "|Well, unless you have already.";
                subentry.entries.listAppend(line);
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
                    subentry.entries.listAppend("Have I Love Me, Vol. I. Collect photographs and such in the Palindome first..");
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
                
            if (single_entry_mode.length() > 0)
            {
                subentry.entries.listClear();
                subentry.entries.listAppend(single_entry_mode);
            }
            if (need_palindome_location && $item[talisman o' nam].equipped_amount() == 0)
                subentry.entries.listAppend("Equip the Talisman o' Nam.");
        }
    }
    
    boolean [location] relevant_locations = makeConstantLocationArrayMutable($locations[the poop deck, belowdecks,cobb's knob laboratory,whitey's grove]);
    relevant_locations[__location_palindome] = true;

    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, relevant_locations));
}
