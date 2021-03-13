//Our strategy for the copperhead quest is probably not very good. Largely because it looks complicated and I made a few guesses.

void QLevel11CopperheadInit()
{
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Ron");
    	if (my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_GREY_GOO) QuestStateParseMafiaQuestPropertyValue(state, "finished");
		state.quest_name = "Zeppelin Quest"; //"Merry-Go-Ron";
		state.image_name = "__item copperhead charm (rampant)"; //__item bitchin ford anglia
        
        state.state_int["protestors remaining"] = clampi(80 - get_property_int("zeppelinProtestors"), 0, 80);
        
        state.state_boolean["need protestor speed tricks"] = true;
        if (state.mafia_internal_step >= 3)
            state.state_int["protestors remaining"] = 0;
        if (state.state_int["protestors remaining"] <= 1)
            state.state_boolean["need protestor speed tricks"] = false;
        
		__quest_state["Level 11 Ron"] = state;
	}
	if (true)
	{
		QuestState state;
		QuestStateParseMafiaQuestProperty(state, "questL11Shen");
    	if (my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_GREY_GOO) QuestStateParseMafiaQuestPropertyValue(state, "finished");
		state.quest_name = "Copperhead Club Quest"; //"Of Mice and Shen";
		state.image_name = "__item copperhead charm"; //"__effect Ancient Annoying Serpent Poison";
		__quest_state["Level 11 Shen"] = state;
	}
}

boolean QLevel11ShouldOutputCopperheadRoute(string which_route)
{
    if (__quest_state["Level 11"].mafia_internal_step < 3) //need diary
        return false;
    
    int pirate_insult_count = 0;
    for i from 1 to 8
    {
        if (get_property_boolean("lastPirateInsult" + i))
            pirate_insult_count += 1;
    }
    if ($item[pirate fledges].available_amount() == 0 && pirate_insult_count == 0) //they haven't started the pirate quest... hm...
    {
        return true;
    }
    
    //want: output this in aftercore if they're adventuring there
    //want: output this in paths that do not allow the pirates (if such paths exist)
    //want: output this in-run if they're adventuring there
    //soooo...
    
    if (which_route == "ron" && $location[the red zeppelin].turns_spent > 0)
        return true;
    if (which_route == "ron" && __last_adventure_location == $location[a mob of zeppelin protesters])
        return true;
    if (which_route == "shen" && $location[the copperhead club].turns_spent > 0)
        return true;
    
    if (__misc_state["in run"] && ($location[a mob of zeppelin protesters].turns_spent + $location[the red zeppelin].turns_spent + $location[the copperhead club].turns_spent) > 0)
        return true;
    
    if (!$item[Talisman o' Namsilat].have()) return true;
    
    return false;
}

void QLevel11RonGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    /*
    questL11Ron
        Merry-Go-Ron
        started - Search for Ron Copperhead on the Red Zeppelin.
        step1 - Fight your way through the mob of zeppelin protesters.
        step2 - All aboard! All aboard the Red Zeppelin!
        step3 - Search the Red Zeppelin for Ron Copperhead.
        step4 - Barge into Ron Copperhead's cabin in the Red Zeppelin and beat him up!
        finshed - You recovered half of the Talisman o' Nam from Ron Copperhead. Brilliant!
    */
    if (!QLevel11ShouldOutputCopperheadRoute("ron"))
        return;
    
    QuestState base_quest_state = __quest_state["Level 11 Ron"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    
    string url = $location[A Mob of Zeppelin Protesters].getClickableURLForLocation();
	if (base_quest_state.finished)
		return;
    
     
    if (base_quest_state.mafia_internal_step <= 2 && base_quest_state.state_int["protestors remaining"] <= 1)
    {
        subentry.entries.listAppend("Adventure in the mob of protestors.");
    }
    else if (base_quest_state.mafia_internal_step <= 2)
    {
        //Fight your way through the mob of zeppelin protesters.
        subentry.entries.listAppend("Scare away " + pluraliseWordy(base_quest_state.state_int["protestors remaining"], "more protestor", "more protestors") + ".");
        subentry.modifiers.listAppend("-combat");
        subentry.modifiers.listAppend("+567% item");
        if (__misc_state["have olfaction equivalent"])
            subentry.modifiers.listAppend("olfact cultists");
        subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("sleaze damage", "r_element_sleaze"));
        subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("sleaze spell damage", "r_element_sleaze"));
        //Two olfaction targets here seem to be cultists or lynyrd skinner.
        //Cultists seem much better.
        //Cigarette lighter is a 15% drop. when used in combat against protestors, removes quite a few
        
        boolean [item] relevant_lynyrdskin_items;
        relevant_lynyrdskin_items[$item[lynyrdskin cap]] = true;
        relevant_lynyrdskin_items[$item[lynyrdskin breeches]] = true;
        if (__misc_state["Torso aware"])
            relevant_lynyrdskin_items[$item[lynyrdskin tunic]] = true;
        
        if ($item[lynyrd musk].available_amount() > 0 && $effect[Musky].have_effect() == 0 && my_path_id() != PATH_G_LOVER)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Use lynyrd musk.", "red"));
            url = "inventory.php?which=3";
        }
        if ($item[cigarette lighter].available_amount() > 0 && base_quest_state.state_boolean["need protestor speed tricks"] && my_path_id() != PATH_POCKET_FAMILIARS)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Use cigarette lighter in-combat.", "red"));
        }
        if ($item[lynyrd snare].available_amount() > 0 && $items[lynyrdskin cap,lynyrdskin tunic,lynyrdskin breeches].items_missing().count() > 0 && $item[lynyrd snare].item_is_usable()) //FIXME daily tracking
        {
            subentry.entries.listAppend("Possibly use the lynyrd snare. (free combat)");
        }
        string [int] what_not_not_to_wear;
        foreach it in relevant_lynyrdskin_items
        {
            if (it.available_amount() == 0)
                continue;
            if (it.equipped_amount() > 0)
                continue;
            what_not_not_to_wear.listAppend(it.to_string().replace_string("lynyrdskin ", ""));
        }
        
        if ($item[pocket wish].have() || ($item[genie bottle].have() && get_property_int("_genieWishesUsed") < 3))
        {
            int current_sleaze_damage = numeric_modifier("sleaze damage") + numeric_modifier("sleaze spell damage");
            string [int] options;
            if ($effect[Fifty Ways to Bereave Your Lover].have_effect() == 0)
            	options.listAppend("Fifty Ways to Bereave Your Lover for +100 sleaze damage");
            if ($effect[Dirty Pear].have_effect() == 0)
                options.listAppend("Dirty Pear for 2x sleaze damage; currently +" + current_sleaze_damage + " total damage");
            string line = "Could wish for sleaze damage";
            if (options.count() > 0)
            	line += ", like " + options.listJoinComponents(", ", "or");
            line += ".";
        	subentry.entries.listAppend(line);
        }
        float sleaze_protestors_cleared = MAX(3.0, sqrt(numeric_modifier("sleaze damage") + numeric_modifier("sleaze spell damage")));
        if (sleaze_protestors_cleared > 3)
            subentry.entries.listAppend(HTMLGenerateSpanOfClass("Sleaze", "r_element_sleaze") + " damage will clear " + sleaze_protestors_cleared.roundForOutput(1) + " protestors."); //FIXME do we want to list the amount they'll need to increase that?
        
        if (what_not_not_to_wear.count() > 0)
        {
            subentry.entries.listAppend("Equip your lynyrdskin " + what_not_not_to_wear.listJoinComponents(", ", "and") + "?");
            url = "inventory.php?which=2";
        }
        
        if ($skill[Transcendent Olfaction].skill_is_usable() && !($effect[on the trail].have_effect() > 0 && get_property_monster("olfactedMonster") == $monster[Blue Oyster cultist]) && base_quest_state.state_boolean["need protestor speed tricks"])
            subentry.entries.listAppend("Olfact blue oyster cultists for protestor-skipping lighters.");
        
        if ($item[lynyrd skin].available_amount() > 0 && $skill[armorcraftiness].skill_is_usable())
        {
            item [int] missing_equipment = relevant_lynyrdskin_items.items_missing();
            if (missing_equipment.count() > 0)
            {
                string [int] missing_equipment_output_string;
                foreach key, it in missing_equipment
                {
                    missing_equipment_output_string.listAppend(it.to_string().replace_string("lynyrdskin ", ""));
                }
                string joining_string = "or";
                if (missing_equipment.count() <= $item[lynyrd skin].available_amount())
                    joining_string = "and";
                string line = "Craft lynyrdskin " + missing_equipment_output_string.listJoinComponents(", ", joining_string);
                
                line += ".";
                boolean can_likely_freecraft = false;
                if ($effect[inigo's incantation of inspiration].have_effect() >= 5)
                    can_likely_freecraft = true;
                if ($item[thor's pliers].available_amount() > 0 && get_property_int("_thorsPliersCrafting") < 10) //FIXME is _thorsPliersCrafting correct? suspect mafia tracks it incorrectly, I saw it at 9 after a run. smithing, probably
                    can_likely_freecraft = true;
                
                //_legionJackhammerCrafting <3
                if ($items[Loathing Legion abacus,Loathing Legion can opener,Loathing Legion chainsaw,Loathing Legion corkscrew,Loathing Legion defibrillator,Loathing Legion double prism,Loathing Legion electric knife,Loathing Legion flamethrower,Loathing Legion hammer,Loathing Legion helicopter,Loathing Legion jackhammer,Loathing Legion kitchen sink,Loathing Legion knife,Loathing Legion many-purpose hook,Loathing Legion moondial,Loathing Legion necktie,Loathing Legion pizza stone,Loathing Legion rollerblades,Loathing Legion tape measure,Loathing Legion tattoo needle,Loathing Legion universal screwdriver,Loathing Legion Knife].available_amount() > 0 && get_property_int("_legionJackhammerCrafting") < 3)
                {
                    if ($item[Loathing Legion jackhammer].available_amount() == 0 && !can_likely_freecraft)
                    {
                        line += " (fold loathing legion knife into jackhammer first)";
                    }
                    can_likely_freecraft = true;
                }
                
                if (!can_likely_freecraft)
                    line += " (1 adventure, not worth it?)";
                
                subentry.entries.listAppend(line);
                
            }
        }
        if (!__quest_state["Level 11 Shen"].finished && $item[Flamin' Whatshisname].available_amount() == 0)
            subentry.entries.listAppend("Could adventure in the Copperhead Club first for Flamin' Whatshisnames.");
    }
    else if (base_quest_state.mafia_internal_step <= 4)
    {
        //All aboard! All aboard the Red Zeppelin!
        subentry.entries.listAppend("Search for Ron in the zeppelin.");
        //possibly 50% chance of no progress without a ticket (unconfirmed chat rumour)
        
        if (my_path_id() != PATH_POCKET_FAMILIARS)
        {
            subentry.modifiers.listAppend("+234% item");
            foreach m in $monsters[Red Herring,Red Snapper]
            {
                if (!m.is_banished())
                    subentry.modifiers.listAppend("banish " + m);
            }
            
            if (__misc_state["have olfaction equivalent"])
                subentry.modifiers.listAppend("olfact red butler");
        }
        
        if ($item[red zeppelin ticket].available_amount() == 0)
        {
            if ($item[priceless diamond].available_amount() > 0)
                subentry.entries.listAppend("Trade in your priceless diamond for a red zeppelin ticket.");
            else if (my_meat() >= $item[red zeppelin ticket].npc_price() && my_meat() >= 4000)
                subentry.entries.listAppend("Purchase a red zeppelin ticket in the black market.");
            else if (!__quest_state["Level 11 Shen"].finished)
                subentry.entries.listAppend("Could adventure in the Copperhead Club first for a ticket. (greatly speeds up area)");
            else
                subentry.entries.listAppend("No ticket.");
        }
            
        if (get_property_int("_glarkCableUses") < 5 && my_path_id() != PATH_POCKET_FAMILIARS)
        {
            if ($skill[Transcendent Olfaction].skill_is_usable() && !($effect[on the trail].have_effect() > 0 && get_property_monster("olfactedMonster") == $monster[red butler]))
                subentry.entries.listAppend("Olfact red butlers for glark cables.");
            
            if ($item[glark cable].available_amount() > 0)
            {
                subentry.entries.listAppend(HTMLGenerateSpanFont("Use glark cable in-combat.", "red"));
            }
        }
            
        if ($item[priceless diamond].available_amount() > 0 && $item[red zeppelin ticket].available_amount() == 0)
        {
            subentry.modifiers.listClear();
            subentry.entries.listClear();
            subentry.entries.listAppend("Acquire a Red Zeppelin ticket from the black market.");
            url = "shop.php?whichshop=blackmarket";
        }
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        //Barge into Ron Copperhead's cabin in the Red Zeppelin and beat him up!
        subentry.entries.listAppend("Defeat Ron in the zeppelin.");
    }
    
    
    
    
    ChecklistEntry entry = ChecklistEntryMake(73, base_quest_state.image_name, url, subentry, $locations[A Mob of Zeppelin Protesters,The Red Zeppelin]);
    
    if (!__misc_state["in run"] || $item[talisman o' namsilat].available_amount() > 0)
        optional_task_entries.listAppend(entry);
    else
        task_entries.listAppend(entry);
}

void QLevel11ShenGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    /*
    questL11Shen
        Of Mice and Shen
        started - Go to the Copperhead Club and find Shen, the man mentioned in your father's diary.
        step1 - (no unique message)
        step2 - (no unique message)
        step3 - (no unique message)
        step4 - (no unique message)
        step5 - (no unique message)
        step6 - (no unique message)
        finished - You retrieved half of the Talisman o' Nam from Shen Copperhead. Nice!
        
    Guesses:
        1 - Need to meet shen for the first time.
        2 - shen met the first time, go do as he asks
        3 - monster done, now go find shen
        4 - shen met second time, go do as he asks
        5 - second monster done, go now find shen
        6 - shen found, go find the third monster
        7 - third monster defeated, shen find go
        finished*/
    
    if (!QLevel11ShouldOutputCopperheadRoute("shen"))
        return;
    QuestState base_quest_state = __quest_state["Level 11 Shen"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    
    item quest_item = get_property_item("shenQuestItem");
    
    location [item] quest_items_to_locations = {$item[Murphy's Rancid Black Flag]:$location[The Castle in the Clouds in the Sky (Top Floor)],
    	$item[The Stankara Stone]:$location[The Batrat and Ratbat Burrow],
        $item[The First Pizza]:$location[Lair of the Ninja Snowmen],
        $item[The Eye of the Stars]:$location[The Hole in the Sky],
        $item[The Lacrosse Stick of Lacoronado]:$location[The Smut Orc Logging Camp],
        $item[The Shield of Brook]:$location[The VERY Unquiet Garves]};
    location quest_location = quest_items_to_locations[quest_item]; 
    
	if (base_quest_state.finished)
		return;
    string url = $location[the copperhead club].getClickableURLForLocation();
    
    boolean want_club_details = false;
    boolean want_hunting_details = false;
    if (base_quest_state.mafia_internal_step <= 1)
    {
        subentry.entries.listAppend("Adventure in the Copperhead Club and meet Shen.");
        subentry.entries.listAppend("This will give you unremovable -5 stat poison.");
        if (my_daycount() == 1 && my_path_id() != PATH_EXPLOSIONS)
        	subentry.entries.listAppend("Perhaps wait until tomorrow before starting this; day 2's shen bosses are more favourable.");
    }
    else if (base_quest_state.mafia_internal_step == 2)
    {
    	want_hunting_details = true;
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        want_club_details = true;
    }
    else if (base_quest_state.mafia_internal_step == 4)
    {
        want_hunting_details = true;
    }
    else if (base_quest_state.mafia_internal_step == 5)
    {
        want_club_details = true;
    }
    else if (base_quest_state.mafia_internal_step == 6)
    {
        want_hunting_details = true;
    }
    else if (base_quest_state.mafia_internal_step == 7)
    {
        want_club_details = true;
    }
    //step hacks:
    if (want_club_details && quest_location != $location[none] && !quest_item.have())
    {
        want_club_details = false;
    }
    if (!want_club_details && quest_item != $item[none] && quest_item.have())
    {
    	want_club_details = true;
        want_hunting_details = false;
    }
    
    if (want_hunting_details)
    {
        subentry.entries.listAppend("Adventure in " + quest_location + ".");
        url = quest_location.getClickableURLForLocation();
    }
    //FIXME is shen scheduled?
    if (want_club_details)
    {
        subentry.entries.listAppend("Find Shen in the Copperhead Club.");
        //unnamed cocktail is 15%
        //ninja dressed as a waiter has 30% disguise
        //waiter dressed as a ninja has 20% disguise
        //Behind the 'Stache can have a single state: gong, ice, or lanterns on fire
        //ice -> priceless diamond
        //fire -> setting unnamed cocktail on fire
        //gong -> prevents damage taken (not speed relevant)
        //and averages 0.64285714285714 unnamed cocktails per attempt (which takes a turn?)
        //so let's see...
        //you first want the priceless diamond for the ticket, otherwise you have the 50% chance(?) of losing progress
        //soo... run 234% item for the disguise?
        //after that, you theoretically want to upgrade cocktails, but...
        //to do that, you need a second disguise, which means possibly olfacting? then olfacting the bartender.
        
        //alternatively, olfact the ninja, then use disguises to collect cocktails
        //each one saves up to seven protestors if you see the NC (at -25% combat, the likelyhood is 11.6% per turn)
        
        boolean need_diamond = false;
        boolean need_flaming_whathisname = false;
        
        if ($items[priceless diamond,Red Zeppelin ticket].available_amount() == 0 && __quest_state["Level 11 Ron"].mafia_internal_step < 5)
            need_diamond = true;
        if (my_meat() >= 5000)
            need_diamond = false;
        if (__quest_state["Level 11 Ron"].state_boolean["need protestor speed tricks"])
            need_flaming_whathisname = true;
        
        if (need_diamond)
        {
            subentry.entries.listAppend("Try to acquire a priceless diamond. (complicated)");
        }
        else if (need_flaming_whathisname)
        {
            subentry.entries.listAppend("Could try to acquire Flamin' Whatshisname. (complicated)");
        }
    }
    
    
	ChecklistEntry entry = ChecklistEntryMake(74, base_quest_state.image_name, url, subentry, $locations[the copperhead club]);
    
    if (!__misc_state["in run"] || $item[talisman o' namsilat].available_amount() > 0)
        optional_task_entries.listAppend(entry);
    else
        task_entries.listAppend(entry);
}
