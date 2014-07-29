
void SRemindersGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{

    
    if ($effect[beaten up].have_effect() > 0)
    {
        string [int] methods;
        string url;
        if ($skill[tongue of the walrus].have_skill())
        {
            methods.listAppend("Cast Tongue of the Walrus.");
            url = "skills.php";
        }
        else if (__misc_state["VIP available"] && __misc_state_int["hot tub soaks remaining"] > 0)
        {
            methods.listAppend("Soak in VIP hot tub.");
            url = "clan_viplounge.php";
        }
        else if (lookupSkill("Shake it off").have_skill())
        {
            methods.listAppend("Cast shake it off.");
            url = "skills.php";
        }
        else if (__misc_state_int["free rests remaining"] > 0)
        {
            methods.listAppend("Free rest at your campsite.");
            url = "campground.php";
        }
        
        foreach it in $items[tiny house,space tours tripple,personal massager,forest tears,csa all-purpose soap]
        {
            if (it.available_amount() > 0 && methods.count() == 0)
            {
                url = "inventory.php?which=1"; //may not be correct in all cases
                methods.listAppend("Use " + it + ".");
                break;
            }
        }
        
        if (methods.count() > 0 && $effect[thrice-cursed].have_effect() == 0)
            task_entries.listAppend(ChecklistEntryMake("__effect beaten up", url, ChecklistSubentryMake("Remove beaten up", "", methods), -11));
    }
    
    if (true)
    {
        //Don't get poisoned.
        effect [int] poison_effects;
        poison_effects.listAppend($effect[Hardly poisoned at all]);
        if (!hippy_stone_broken()) //FIXME remove next PVP season
            poison_effects.listAppend($effect[A Little Bit Poisoned]);
        poison_effects.listAppend($effect[Somewhat Poisoned]);
        poison_effects.listAppend($effect[Really Quite Poisoned]);
        poison_effects.listAppend($effect[Majorly Poisoned]);
        poison_effects.listAppend($effect[Toad In The Hole]);
        
        effect have_poison = $effect[none];
        foreach key in poison_effects
        {
            effect e = poison_effects[key];
            if (e.have_effect() > 0)
            {
                have_poison = e;
                break;
            }
        }
        if (have_poison != $effect[none])
        {
            string url = "";
            string [int] methods;
            
            /*if ($skill[disco nap].have_skill() && $skill[adventurer of leisure].have_skill())
            {
                url = "skills.php";
                methods.listAppend("Cast Disco Nap.");
            }
            else*/
            if (true)
            {
                url = "galaktik.php";
                methods.listAppend("Use Doc Galaktik's anti-anti-antidote.");
                if ($item[anti-anti-antidote].available_amount() > 0)
                    url = "inventory.php?which=1";
            }
            
            task_entries.listAppend(ChecklistEntryMake("__effect " + have_poison, url, ChecklistSubentryMake("Remove " + have_poison, "", methods), -11));
        }
	}
        if ($effect[Cunctatitis].have_effect() > 0 && $skill[disco nap].have_skill() && $skill[adventurer of leisure].have_skill())
    {
        string url = "skills.php";
        string method = "Cast disco nap.";
        task_entries.listAppend(ChecklistEntryMake("__effect Cunctatitis", url, ChecklistSubentryMake("Remove Cunctatitis", "", method), -11));
    }
    
    if ($effect[Down the Rabbit Hole].have_effect() > 0 && __last_adventure_location == $location[The Red Queen's Garden] && (!in_ronin() || $item[&quot;DRINK ME&quot; potion].available_amount() > 0) && get_property_int("pendingMapReflections") <= 0)
    {
        string url = "mall.php";
        
        if ($item[&quot;DRINK ME&quot; potion].available_amount() > 0)
            url = "inventory.php?which=3";
        
        task_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", url, ChecklistSubentryMake("Drink " + $item[&quot;DRINK ME&quot; potion], "+madness", "Otherwise, no reflections of a map will drop."), -11));
    }
    
    if ($effect[Merry Smithsness].have_effect() == 0 && (!in_ronin() || $item[flaskfull of hollow].available_amount() > 0) && $items[Meat Tenderizer is Murder,Ouija Board\, Ouija Board,Hand that Rocks the Ladle,Saucepanic,Frankly Mr. Shank,Shakespeare's Sister's Accordion,Sheila Take a Crossbow,A Light that Never Goes Out,Half a Purse,loose purse strings,Hand in Glove].equipped_amount() > 0)
    {
        //They (can) have a flaskfull of hollow and have a smithsness item equipped, but no merry smithsness.
        //So, suggest a high-priority task.
        //I suppose in theory they could be saving the flaskfull of hollow for later, for +item? In that case, we would be annoying them. They can closet the flask, but that isn't perfect...
        //Still, I feel as though having this reminder is better than not having it.
        
        //Four items are not on the list due to their marginal bonus: Hairpiece On Fire (+maximum MP), Vicar's Tutu (+maximum HP), Staff of the Headmaster's Victuals (+spell damage), Work is a Four Letter Sword (+weapon damage)
        string url = "mall.php";
        
        if ($item[flaskfull of hollow].available_amount() > 0)
            url = "inventory.php?which=3";
        
        task_entries.listAppend(ChecklistEntryMake("__item flaskfull of hollow", url, ChecklistSubentryMake("Drink " + $item[flaskfull of hollow], "", "Gives +25 smithsness"), -11));
    }
    
	if ($effect[QWOPped Up].have_effect() > 0 && ((__misc_state["VIP available"] && __misc_state_int["hot tub soaks remaining"] > 0) || lookupSkill("Shake It Off").have_skill())) //only suggest if they have hot tub access; other route is a SGEEA, too valuable
    {
        string [int] description;
        string url = "";
        if (lookupSkill("Shake It Off").have_skill())
        {
            url = "skills.php";
            description.listAppend("Shake it off.");
        }
        else
        {
            url = "clan_viplounge.php";
            description.listAppend("Use hot tub.");
        }
        
		task_entries.listAppend(ChecklistEntryMake("__effect qwopped up", url, ChecklistSubentryMake("Remove QWOPped up effect", "", description), -11));
    }


    if (get_property_monster("lastEncounter") == $monster[dr. awkward] && $item[mega gem].equipped_amount() > 0 && $items[staff of fats, Staff of Ed\, almost, Staff of Ed].available_amount() > 0)
    {
        //Just defeated Dr. Awkward.
        //This will disappear once they adventure somewhere else.
        string [int] description;
        
        description.listAppend("It's not useful now, wear a better accessory?");
        if ($item[talisman o' nam].equipped_amount() > 0)
            description.listAppend("Possibly the talisman as well.");
    
		task_entries.listAppend(ChecklistEntryMake("__item mega gem", "inventory.php?which=2", ChecklistSubentryMake("Possibly unequip the Mega Gem", "", description), -11));
    }
    
    if (__misc_state["need to level"])
    {
        ChecklistEntry stat_items;
        stat_items.image_lookup_name = "";
        stat_items.target_location = "inventory.php?which=3";
        stat_items.importance_level = -11;
        
        effect [item] item_effects;
        string [item] item_descriptions;
        
        if ($effect[Purple Tongue].have_effect() == 0 && $effect[Green Tongue].have_effect() == 0 && $effect[Red Tongue].have_effect() == 0 && $effect[Blue Tongue].have_effect() == 0 && $effect[Black Tongue].have_effect() == 0)
        {
            item_descriptions[$item[orange snowcone]] = "+1.5 mainstat/fight (20 turns)";
            item_effects[$item[orange snowcone]] = $effect[Orange Tongue];
        }
        
        if (__misc_state["need to level moxie"])
        {
            item_descriptions[$item[Ye Olde Bawdy Limerick]] = "+2 moxie stats/fight (20 turns)";
            item_effects[$item[Ye Olde Bawdy Limerick]] = $effect[From Nantucket];
            
            
            item_descriptions[$item[resolution: be sexier]] = "+2 moxie stats/fight (20 turns)";
            item_effects[$item[resolution: be sexier]] = $effect[Irresistible Resolve];
            
            item_descriptions[lookupItem("old bronzer")] = "+2 moxie stats/fight (25 turns)";
            item_effects[lookupItem("old bronzer")] = lookupEffect("Sepia Tan");
        }

        if (__misc_state["need to level muscle"])
        {
            item_descriptions[$item[Squat-Thrust Magazine]] = "+3 muscle stats/fight (20 turns)";
            item_effects[$item[Squat-Thrust Magazine]] = $effect[Squatting and Thrusting];
            
            
            item_descriptions[$item[resolution: be stronger]] = "+2 muscle stats/fight (20 turns)";
            item_effects[$item[resolution: be stronger]] = $effect[Strong Resolve];
            
            
            item_descriptions[lookupItem("old eyebrow pencil")] = "+2 muscle stats/fight (25 turns)";
            item_effects[lookupItem("old eyebrow pencil")] = lookupEffect("Browbeaten");
        }
        if (__misc_state["need to level mysticality"])
        {
            item_descriptions[$item[O'RLY Manual]] = "+4 mysticality stats/fight (20 turns)";
            item_effects[$item[O'RLY Manual]] = $effect[You Read The Manual];
            
            
            item_descriptions[$item[resolution: be smarter]] = "+2 mysticality stats/fight (20 turns)";
            item_effects[$item[resolution: be smarter]] = $effect[Brilliant Resolve];
            
            
            item_descriptions[lookupItem("old rosewater cream")] = "+2 mysticality stats/fight (25 turns)";
            item_effects[lookupItem("old rosewater cream")] = lookupEffect("Rosewater Mark");
        }
        
        if (my_level() >= 11)
        {
            item_descriptions[$item[BitterSweetTarts]] = "+5.5 " + my_primestat().to_lower_case() + " stats/fight (10 turns)";
            item_effects[$item[BitterSweetTarts]] = $effect[Full of Wist];
        }
        
        item [int] relevant_items;
        string [int] relevant_descriptions;
        foreach it in item_descriptions
        {
            if (it.available_amount() == 0)
                continue;
            if (item_effects[it].have_effect() > 0)
                continue;
            if (stat_items.image_lookup_name.length() == 0)
                stat_items.image_lookup_name = "__item " + it;
            //stat_items.subentries.listAppend(ChecklistSubentryMake("Use " + it, "", item_descriptions[it]));
            relevant_items.listAppend(it);
            relevant_descriptions.listAppend(item_descriptions[it]);
        }
        
        ChecklistSubentry subentry;
        if (relevant_items.count() > 0)
        {
            subentry.header = "Use " + relevant_items.listJoinComponents(", ", "and");
            subentry.entries.listAppend(relevant_descriptions.listJoinComponents(", ", "and"));
        }
        
        
        if (subentry.header.length() > 0)
            stat_items.subentries.listAppend(subentry);
        if (stat_items.subentries.count() > 0)
        {
            task_entries.listAppend(stat_items);
        }
    }
    
    if ($item[evil eye].available_amount() > 0 && __quest_state["Level 7"].state_int["nook evilness"] > 25)
    {
        task_entries.listAppend(ChecklistEntryMake("__item " + $item[evil eye], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[evil eye], "", "Three cyrpt nook beeps."), -11));
    }
    
    if ($familiars[mini-hipster, artistic goth kid] contains my_familiar() && __misc_state["need to level"] && __misc_state_int["hipster fights available"] > 0 && !__misc_state["single familiar run"])
    {
        task_entries.listAppend(ChecklistEntryMake("__familiar " + my_familiar(), "", ChecklistSubentryMake("Buff " + my_primestat(), "", "Extra stats from " + my_familiar() + " fights."), -11));
    }
    
    boolean have_blacklight_bulb = (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeHeadlight") == "Blacklight Bulb");
    if (__last_adventure_location == $location[the arid\, extra-dry desert] && !__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && __misc_state["In run"] && !have_blacklight_bulb && __quest_state["Level 11 Desert"].state_int["Desert Exploration"] < 99)
    {
        boolean have_uv_compass_equipped = __quest_state["Level 11 Desert"].state_boolean["Have UV-Compass eqipped"];
        
        if (!have_uv_compass_equipped)
        {
            string title;
            item compass_item = $item[UV-resistant compass];
            if (lookupItem("ornate dowsing rod").available_amount() > 0)
                compass_item = lookupItem("ornate dowsing rod");
            
            title = "Equip " + compass_item;
            if (compass_item.available_amount() == 0)
                title = "Find and equip " + compass_item;
            task_entries.listAppend(ChecklistEntryMake("__item " + compass_item, "", ChecklistSubentryMake(title, "", "Explore more efficiently."), -11));
        }
        
    }
    if ($item[bottle of blank-out].available_amount() > 0 && $item[glob of blank-out].available_amount() == 0 && __misc_state["In run"] && __misc_state["free runs usable"] && !get_property_boolean("_blankOutUsed") && in_ronin())
    {
        task_entries.listAppend(ChecklistEntryMake("__item " + $item[bottle of blank-out], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[bottle of blank-out], "", "Acquire glob to run away with."), -11));
    
    }
    if (__last_adventure_location == $location[the haunted ballroom] && $item[dance card].available_amount() > 0 && __misc_state["need to level"] && my_primestat() == $stat[moxie] && CounterLookup("Dance Card").CounterGetNextExactTurn() == -1)
    {
        boolean delay_for_semirare = CounterLookup("Semi-rare").CounterWillHitExactlyInTurnRange(3, 3);
        
        if (delay_for_semirare)
            task_entries.listAppend(ChecklistEntryMake("__item " + $item[dance card], "", ChecklistSubentryMake(HTMLGenerateSpanFont("Avoid using " + $item[dance card], "red", ""), "", HTMLGenerateSpanFont("You have a semi-rare coming up then, wait a turn first.", "red", "")), -11));
        else
        {
            string [int] description;
            description.listAppend("Gives ~" + __misc_state_float["dance card average stats"].round() + " mainstat in four turns.");
            if ($item[dance card].available_amount() > 1)
                description.listAppend("Have " + $item[dance card].pluralizeWordy() + ".");
            task_entries.listAppend(ChecklistEntryMake("__item " + $item[dance card], "inventory.php?which=3", ChecklistSubentryMake("Use " + $item[dance card], "", description), -11));
        }
    }
    if (!__quest_state["Level 11 Hidden City"].finished && __quest_state["Level 11 Hidden City"].state_boolean["Apartment finished"] && $effect[thrice-cursed].have_effect() > 0)
    {
        string curse_removal_method;
        string url;
        
        if (__misc_state["VIP available"] && __misc_state_int["hot tub soaks remaining"] > 0)
        {
            curse_removal_method = "Relax in hot tub.";
            url = "clan_viplounge.php";
        }
        if (lookupSkill("Shake It Off").have_skill())
        {
            curse_removal_method = "Cast shake it off.";
            url = "skills.php";
        }
        
        if (curse_removal_method.length() > 0)
        {
            task_entries.listAppend(ChecklistEntryMake("__effect thrice-cursed", url, ChecklistSubentryMake("Remove Thrice-Cursed", "", curse_removal_method), -11));
        }
    }
    
}