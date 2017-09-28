
RegisterTaskGenerationFunction("PathActuallyEdtheUndyingGenerateTasks");
void PathActuallyEdtheUndyingGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING) return;

    // points from previous Ed ascensions, or talismans of Seshats.
    int initial_points = get_property_int("edPoints");

    int skills_available = initial_points;
    int total_skills     = 0;

    // Skills are granted on every level, up to 14, except those divisible by 3
    for i from 1 to my_level()
    {
        if (i > 14)
            break;
        if ( (i % 3) != 0 ) {
            skills_available++;
        }
    }

/*
    CHEATSHEET:
    17000 Prayer of Seshat
    17001 Wisdom of Thoth
    17002 Power of Heka
    17003 Hide of Sobek
    17004 Blessing of Serqet
    17005 Shelter of Shed
    17006 Bounty of Renenutet
    17007 Fist of the Mummy
    17008 Howl of the Jackal
    17009 Roar of the Lion
    17010 Storm of the Scarab
    17011 Purr of the Feline
    17012 Lash of the Cobra
    17013 Wrath of Ra
    17014 Curse of the Marshmallow
    17015 Curse of Indecision
    17016 Curse of Yuck
    17017 Curse of Heredity
    17018 Curse of Fortune
    17019 Curse of Vacation
    17020 Curse of Stench
*/

    boolean [int] skills_to_always_keep_active;
    // No reason to ever run without Prayer of Seshat,
    // few enough reasons for the other two that we might as
    // well recommend them too
    foreach s in $ints[17000, 17001, 17002, 17004]
    {
        skills_to_always_keep_active[s] = true;
    }

    string [int] skill_id_to_useful_desc;
    //Prayer of Seshat
    skill_id_to_useful_desc[17000] = "+3 myst substat per fight";
    //Wisdom of Thoth
    skill_id_to_useful_desc[17001] = "+10 Myst, +50% Myst";
    //Power of Heka
    skill_id_to_useful_desc[17002] = "Increased spell damage";
    //Fist of the Mummy
    skill_id_to_useful_desc[17007] = "Main attack spell, damage equals buffed Myst, up to 50";
    //+ML
    skill_id_to_useful_desc[17004] = "+20 ML, +" + roundForOutput(20 * __misc_state_float["ML to mainstat multiplier"], 2) + " mainstats/turn";

    // Skill upgrades:
    skill [int] skill_order;

    boolean [skill] skills_recommended;
    if ( initial_points < 6 ) {
        /* First times as Ed; player will have 9 skills by level 13:
           Recommend:
            1. Prayer               (+ substats)                | level 1
            2. Fist                 (main attack)               | level 2
            3. Wisdom               (+ myst)                    | level 4
            4. Power of Heka        (+ spellpower for Fist)     | level 5
            5. Hide of Sobek        (+ elemental resist)        | level 7
            6. Blessing of Serqet   (+20 ML)                    | level 8
            7. Shelter of Shed      (-combat)                   | level 10
            8. Bounty of Renenutet  (+50% item drop)            | level 11
            9. whatever                                         | level 13
            10. whatever                                        | level 14

            With more skill points we might be able to do something
            fancier, but pickpocket or yellow ray will not be as
            useful as the +20 ML (stats, oily peak) or -combat (mcguffin);
            +50% item drop + talisman of Renenutet + potentially the dancer
            helps immensely in getting the glands, and may offset the
            lack of a straight pickpocket.
        */
        /* XXX TODO BAD ASSUMPTION: no access to CI, chateau, etc, which
           probably change the picture significantly.
        */
        foreach s in lookupSkillsInt($ints[17000, 17007, 17001, 17002, 17003, 17004, 17005, 17006])
        {
            skills_recommended[s] = true;
            skill_order.listAppend(s);
        }
    }

    foreach s in lookupSkillsInt($ints[17000,17001,17002,17003,17004,17005,17006,17007,17008,17009,17010,17011,17012,17013,17014,17015,17016,17017,17018,17019,17020])
    {
        if ( skills_recommended[s] ) /* already in the recommendations */
            continue;
        skill_order.listAppend(s);
    }

    skill [int] skill_recommendations;

    foreach key in skill_order
    {
        skill s = skill_order[key];
        if ( s.skill_is_usable() )
        {
            int skill_as_int    = s.to_int();
            boolean keep_active = skills_to_always_keep_active[ skill_as_int ];
            skills_available--;
            total_skills++;
            if ( !keep_active )
                continue;

            /* This skill is just so good that we recommend they keep it on */

            string skill_name   = s.to_string();
            effect skill_effect = lookupEffect(skill_name);

            if ( skill_effect.have_effect() > 0 )
                continue;

            string image_name       = "__skill " + skill_name.to_lower_case();
            string nice_description = skill_id_to_useful_desc[skill_as_int];
            string [int] description;
            description.listAppend(skill_name + " is available but not in effect. " + nice_description);

            string url = "runskillz.php?action=Skillz&whichskill=" + skill_as_int + "&targetplayer=" + my_id() + "&pwd=" + my_hash() + "&quantity=1";

            optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake("Make Ed's life easier", "10 turns", description), -1));
        }
        else if ( skill_recommendations.count() < 3 )
        {
            /*  A skill they don't have.  Score! */
            skill_recommendations.listAppend(s);
        }
    }

    /* Go over skills they don't have, recommend up to 3 */
    string image_name = "";
    string [int] description_buy_skills;
    foreach idx, s in skill_recommendations
    {
        skills_available--;
        if ( total_skills > 20 || skills_available < 0 )
            break; /* they got all of them, or they have no points */

        total_skills++;

        string skill_name       = s.to_string();
        int skill_as_int        = s.to_int_silent();
        string nice_description = skill_id_to_useful_desc[skill_as_int];

        string skill_effect = lookupEffect(skill_name).to_string();

        if ( image_name.length() == 0 )
            image_name = "__skill " + skill_name.to_lower_case();

        if ( nice_description.length() > 0 )
            skill_name += ": " + nice_description;

        description_buy_skills.listAppend(skill_name);
    }

    if ( image_name.length() > 0 ) {
        description_buy_skills.listPrepend("Recommended progression: ");
        optional_task_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=edbase&action=edbase_book", ChecklistSubentryMake("Buy Undying skills", "", description_buy_skills)));
    }

    int spleen_limit = spleen_limit();
    if ( spleen_limit < 35 )
    {
        /* The absolutely most important, crucial thing to do is get
           Ed to have as many adventures as possible.  That mostly
           involves upgrading his spleen.

           This next bit sorts out how many adventures need to be
           spent to purchase the spleen, AND the haunch to fill it...
           ...and the oft-forgotten extra adventure to actually buy it all.
           Nothing worse than having the exact amount of Ka, but 0 adventures
           left, so no access to the underworld.
         */
        int ka_needed_for_spleen = 0;
        int available_ka = $item[Ka coin].available_amount();
        string [int] description;

        if ( spleen_limit == 5 )
        {
            /* Extra Spleen */
            description.listAppend("Buy an extra spleen (5 Ka)");
            ka_needed_for_spleen += 5;
        }
        else if ( spleen_limit == 10 )
        {
            /* Another Extra Spleen */
            description.listAppend("Buy another extra spleen (10 Ka)");
            ka_needed_for_spleen += 10;
        }
        else if ( spleen_limit == 15 )
        {
            /* Yet Another Extra Spleen */
            description.listAppend("Buy yet another extra spleen (15 Ka)");
            ka_needed_for_spleen += 15;
        }
        else if ( spleen_limit == 20 )
        {
            /* Still Another Extra Spleen */
            description.listAppend("Buy still another extra spleen (20 Ka)");
            ka_needed_for_spleen += 20;
        }
        else if ( spleen_limit == 25 )
        {
            /* Just One More Extra Spleen */
            description.listAppend("Buy just one more extra spleen (25 Ka)");
            ka_needed_for_spleen += 25;
        }
        else if ( spleen_limit == 30 )
        {
            /* TODO worth recommending getting the liver and|or stomach here */
            /* The Final Spleen */
            description.listAppend("Buy the final spleen (30 Ka)");
            ka_needed_for_spleen += 30;
        }

        int total_adventures_needed = 1; /* to go actually buy this stuff */

        available_ka -= ka_needed_for_spleen;
        if ( available_ka < 0 )
        {
            int adventures_needed_farming_for_spleen
                = ceil(ka_needed_for_spleen.to_float() / 2.0);
            description.listAppend("Have to spend " + adventures_needed_farming_for_spleen + " adventures farming at 2 Ka per adventure");
            total_adventures_needed += adventures_needed_farming_for_spleen;
        }

        if ( available_ka < 0 )
            available_ka = 0;

        int [item] spleen_item_to_ka;
        spleen_item_to_ka[ $item[mummified fig]           ] =  5;
        spleen_item_to_ka[ $item[mummified loaf of bread] ] = 10;
        spleen_item_to_ka[ $item[mummified beef haunch]   ] = 15;
        string consumable_desc = "";
        foreach spleen_item in $items[mummified beef haunch, mummified loaf of bread, mummified fig]
        {
            if (spleen_item.available_amount() > 0)
                break;
            int ka_cost = spleen_item_to_ka[spleen_item];

            if ( available_ka > ka_cost ) /* got enough for a consumable */
                break;

            int adventures_needed = ceil((ka_cost-available_ka).to_float() / 2.0);

            if ( consumable_desc.length() > 0 )
            {
                consumable_desc += ", or ";
            }
            else
            {
                total_adventures_needed += adventures_needed;
            }
            consumable_desc += "+" + adventures_needed + " adventures for a " + spleen_item.to_string();
        }

        if ( consumable_desc.length() > 0 )
            description.listAppend("Plus " + consumable_desc);

        description.listAppend("1 adventure needed to go to the underworld");

        string running_out_of_adventures = "";
        int adventures_left = my_adventures();
        if (
            total_adventures_needed < adventures_left
                &&
            total_adventures_needed > (adventures_left-5)
        ) {
            // running out of adventures, farm now!
            running_out_of_adventures = "red";
        }

        description.listAppend(HTMLGenerateSpanFont("Total adventures needed: ~" + total_adventures_needed, running_out_of_adventures));

        task_entries.listAppend(ChecklistEntryMake("__skill extra spleen", "", ChecklistSubentryMake("Upgrade spleen for more adventures", "", description), 0));
    }

    if (my_level() >= 13 && QuestState("questL13Final").finished)
    {
        if ($item[7965].available_amount() > 0 || $item[2334].available_amount() > 0) //holy macguffins
        {
            string [int] description;
            description.listAppend("Finishes the path.");
            if (availableSpleen() > 0)
                description.listAppend("May want to fill your " + availableSpleen() + " extra spleen first.");
            task_entries.listAppend(ChecklistEntryMake("Pyramid", "place.php?whichplace=edbase&action=edbase_altar", ChecklistSubentryMake("Put back the Holy MacGuffin", "", description), -10));
        }
        else
        {
            //tutorial.php
            string [int] modifiers;
            string [int] description;
            string url = "tutorial.php";
            
            if (!$monster[warehouse janitor].is_banished())
                modifiers.listAppend("banish janitor");
            
            description.listAppend("Adventure in the Secret Government Warehouse, use the items you find.");
            
            int progress_remaining = clampi(40 - get_property_int("warehouseProgress"), 0, 40);
            if ($item[warehouse inventory page].available_amount() > 0 && $item[warehouse map page].available_amount() > 0)
            {
                description.listClear();
                description.listAppend("Use warehouse inventory page.");
                url = "inventory.php?which=3";
            }
            else if (progress_remaining > 0)
            {
                if ($skill[Lash of the Cobra].have_skill())
                {
                    description.listAppend("Use lash of the cobra on the clerk and guard.");
                }
                else
                {
                    modifiers.listAppend("+item");
                }
            }
            string [int] items_available;
            foreach it in $items[warehouse inventory page,warehouse map page]
            {
                if (it.available_amount() > 0)
                    items_available.listAppend(pluraliseWordy(it));
            }
            if (items_available.count() > 0)
            {
                description.listAppend(items_available.listJoinComponents(", ", "and").capitaliseFirstLetter() + " available.");
            }
            
            string line;// = pluraliseWordy(progress_remaining, "remaining aisle", "remaining aisles").capitaliseFirstLetter() + ".";
            if (progress_remaining <= 0)
                line += "MacGuffin next turn";
            else
                line += "Fight " + progress_remaining + " more combats";
            if (progress_remaining > 1)
            {
                int page_pairs_remaining = ceil(progress_remaining.to_float() / 8.0);
                
                /*string [int] bring_me_the_red_pages;
                
                int first_value = -1;
                boolean identical_twins = false;
                foreach it in $items[warehouse inventory page,warehouse map page]
                {
                    int pages_remaining = page_pairs_remaining - it.available_amount();
                    if (pages_remaining > 0)
                    {
                        if (first_value == -1)
                            first_value = pages_remaining;
                        else if (first_value == pages_remaining)
                        {
                            identical_twins = true;
                            bring_me_the_red_pages.listAppend(it);
                            continue;
                        }
                        bring_me_the_red_pages.listAppend(pluraliseWordy(pages_remaining, it));
                    }
                }
                
                if (identical_twins)
                    line += bring_me_the_red_pages.listJoinComponents("/");
                else
                    line += bring_me_the_red_pages.listJoinComponents(", ", "and");*/
                    
                line += " or collect ";
                line += pluraliseWordy(page_pairs_remaining, "more page pair", "more page pairs");
            }
            line += ".";
            description.listAppend(line);
            
            task_entries.listAppend(ChecklistEntryMake("__item holy macguffin", url, ChecklistSubentryMake("Retrieve the Holy MacGuffin", modifiers, description), $locations[The Secret Council Warehouse]));
        }
    }
}

RegisterResourceGenerationFunction("PathActuallyEdtheUndyingGenerateResource");
void PathActuallyEdtheUndyingGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING) return;
    item ka = $item[Ka coin];
    if (ka.available_amount() > 0)
    {
        string [int] description;
        
        string [int][int] ka_table;
        
        int haunches_edible = clampi(availableSpleen() / 5, 0, 7);
        if (haunches_edible > $item[mummified beef haunch].available_amount())
        {
            int haunches_want = haunches_edible - $item[mummified beef haunch].available_amount();
            //15 ka coin
            string name;
            if (haunches_want > 1)
                name = pluralise(haunches_want, $item[mummified beef haunch]);
            else
                name = "mummified beef haunch";
            ka_table.listAppend(listMake(name, 15, "best spleen consumable"));
        }
        if ($item[linen bandages].available_amount() == 0 && $item[cotton bandages].available_amount() == 0 && $item[silk bandages].available_amount() == 0)
        {
            //linen bandages, 1 ka coin
            ka_table.listAppend(listMake("linen bandages", 1, "when beaten up outside a fight"));
        }
        
        //seven talisman of Renenutet (1 ka coin)
        //talisman of Horus (5 ka coin, +combat)
        int talismen_of_horus_wanted = 0;
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"])
            talismen_of_horus_wanted += 2;
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
            talismen_of_horus_wanted += 2;
        if ($item[pirate fledges].available_amount() == 0 && $item[talisman o' namsilat].available_amount() == 0)
            talismen_of_horus_wanted += 2;
        if (talismen_of_horus_wanted == 0) //where else do you need +combat? pirate's cove?
            talismen_of_horus_wanted = 1;
        if ($item[talisman of Horus].available_amount() < talismen_of_horus_wanted)
        {
            ka_table.listAppend(listMake("talisman of Horus", 5, "+combat potion"));
        }
        ka_table.listAppend(listMake("talisman of Renenutet", 1, "+lots item for one combat"));
        //body upgrades:
        string [int][int] skill_upgrade_order;

        // Upgraded legs allows for early farming of hippies/pirates, so
        // it should be priority number one
        skill_upgrade_order.listAppend(listMake("Upgraded Legs", 10, "+50% init"));
        skill_upgrade_order.listAppend(listMake("Extra Spleen", 5, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Another Extra Spleen", 10, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Yet Another Extra Spleen", 15, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Still Another Extra Spleen", 20, "+5 spleen"));

        /* XXX might want liver early anyway, as it allows for overdrinking */
        boolean early_liver = false;
        if (
            $item[astral six-pack].is_unrestricted()
                ||
            $item[astral pilsner].is_unrestricted()
        ) {
            early_liver = true;
            //Got astral booze
            skill_upgrade_order.listAppend(listMake("Replacement Liver", 30, "can drink"));
        }
        else {
            skill_upgrade_order.listAppend(listMake("Replacement Stomach", 30, "+5 stomach")); //fortune cookie
        }

        skill_upgrade_order.listAppend(listMake("Just One More Extra Spleen", 25, "+5 spleen"));
        skill_upgrade_order.listAppend(listMake("Okay Seriously, This is the Last Spleen", 30, "+5 spleen"));

        if ( !early_liver ) {
            skill_upgrade_order.listAppend(listMake("Replacement Liver", 30, "can drink"));
        }
        else {
            //Got astral booze
            skill_upgrade_order.listAppend(listMake("Replacement Stomach", 30, "+5 stomach")); //fortune cookie
        }

        skill_upgrade_order.listAppend(listMake("More Legs", 20, "+50% init"));
        // Wards can come in late; mainly useful for Big Mountain & A-boo
        skill_upgrade_order.listAppend(listMake("Elemental Wards", 10, "+1 all res"));
        skill_upgrade_order.listAppend(listMake("More Elemental Wards", 20, "+2 all res"));
        // DA & DR are useful during the war; allows flyers & magnet on
        // the gremlins for example.
        skill_upgrade_order.listAppend(listMake("Tougher Skin", 10, "+100 DA"));
        skill_upgrade_order.listAppend(listMake("Armor Plating", 10, "+10 DR")); //marginal

        // A-boo
        skill_upgrade_order.listAppend(listMake("Even More Elemental Wards", 30, "+3 all res"));

        skill_upgrade_order.listAppend(listMake("Upgraded Spine", 20, "+50% moxie"));
        skill_upgrade_order.listAppend(listMake("Upgraded Arms", 20, "+50% muscle"));
        //skill_upgrade_order.listAppend(listMake("Bone Spikes", 20));
        //skill_upgrade_order.listAppend(listMake("Arm Blade", 20));
        //skill_upgrade_order.listAppend(listMake("Healing Scarabs")); //only useful if it prevents beaten up from non-combats?
        
        foreach key in skill_upgrade_order
        {
            string [int] l = skill_upgrade_order[key];
            skill s = l[0].lookupSkill();
            int ka_cost = l[1].to_int_silent();
            string reason = l[2];
            if (s == $skill[none])
                break;
            if (s.have_skill()) continue;
            
            
            /*string line = "Could upgrade your body with " + s + ".";
            if (ka_cost > ka.available_amount())
                line = HTMLGenerateSpanFont(line, "grey");
            description.listAppend(line);*/
            ka_table.listAppend(listMake(s, ka_cost, reason));
            break;
        }
        
        if (ka_table.count() > 0)
        {
            foreach key in ka_table
            {
                int ka_needed = ka_table[key][1].to_int_silent();
                if (ka_needed > ka.available_amount())
                {
                    foreach key2 in ka_table[key]
                    {
                        ka_table[key][key2] = HTMLGenerateSpanFont(ka_table[key][key2], "grey");
                    }
                }
            }
            description.listAppend(HTMLGenerateSimpleTableLines(ka_table));
        }
        
        string url = "";
        string [int] places_to_farm_ka;
        if (getHolidaysToday()["Halloween"])
        {
            places_to_farm_ka.listAppend("trick or treating");
            url = "place.php?whichplace=town";
        }
        if (__misc_state["spooky airport available"])
        {
            places_to_farm_ka.listAppend("laboratory on conspiracy island");
            if (url.length() == 0) url = $location[the secret government laboratory].getClickableURLForLocation();
        }
        if (__misc_state["hot airport available"])
        {
            places_to_farm_ka.listAppend("smooch army HQ");
            if (url.length() == 0) url = $location[The SMOOCH Army HQ].getClickableURLForLocation();
        }
        if (__misc_state["mysterious island available"] && !__quest_state["Level 12"].in_progress && my_level() < 9) //we test if we're under level 9 and the level 12 quest isn't in progress. maybe they ate a lot of hot dogs. it could happen!
        {
            places_to_farm_ka.listAppend("hippy camp");
            if (url.length() == 0) url = $location[hippy camp].getClickableURLForLocation();
        }

        if ( !__misc_state["mysterious island available"] )
        {
            places_to_farm_ka.listAppend("The Sleazy Back Alley (at ~1.5 Ka/adv, best to use the time unlocking the hippy camp)");
            if (url.length() == 0) url = $location[The Sleazy Back Alley].getClickableURLForLocation();
        }

        if (places_to_farm_ka.count() > 0)
            description.listAppend("Could farm ka in the " + places_to_farm_ka.listJoinComponents(", ", "or") + ".");
        
        resource_entries.listAppend(ChecklistEntryMake("__item ka coin", url, ChecklistSubentryMake(ka.pluralise(), "", description), 6));
    }
    
    if (true)
    {
        ChecklistSubentry [int] subentries;
        string image_name = "";
        string [item] path_relevant_items;
        
        path_relevant_items[$item[talisman of Renenutet]] = "+lots% item in a single combat";
        path_relevant_items[$item[talisman of Horus]] = "+lots% combat potion";
        path_relevant_items[$item[ancient cure-all]] = "SGEEA-equivalent?";
        foreach s in $strings[linen bandages,cotton bandages,silk bandages]
        {
            if (lookupItem(s).available_amount() > 0)
            {
                path_relevant_items[lookupItem(s)] = "heal at zero HP";
                break;
            }
        }
        foreach it, reason in path_relevant_items
        {
            if (it.available_amount() > 0)
            {
                subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", reason.capitaliseFirstLetter() + "."));
                if (image_name.length() == 0)
                    image_name = "__item " + it;
            }
        }
        if (subentries.count() > 0)
            resource_entries.listAppend(ChecklistEntryMake(image_name, "", subentries, 6));
    }
    
    if ($skill[Lash of the cobra].have_skill() && mafiaIsPastRevision(15553))
    {
        int lashes_remaining = 30 - get_property_int("_edLashCount");
        if (lashes_remaining > 0)
        {
            string [int] description;
            string [int] stealables;
            //Stuff:
            //snake +ML
            //badge of authority (HC)
            //warehouse
            //barret, aerith
            //pygmy witch lawyers
            //filthworms
            //war hippy drill sergeant
            //war outfit (if wrath of ra not available)
            //pirate outfit? specific monsters left
            //hot wings from p imp / g imp
            //beanbats (if unlocked, else batrats/ratbats, else guano junction)
            //skeletons in the nook
            //topiary animals in twin peak
            //dusken raider ghost (if oil needed)
            //oil cartel(?)
            if (stealables.count() > 0)
                description.listAppend("Steals a random item:|*" + stealables.listJoinComponents("|*"));
            else
                description.listAppend("Steals a random item.");
                
            resource_entries.listAppend(ChecklistEntryMake("__item cool whip", "", ChecklistSubentryMake(pluralise(lashes_remaining, "lash", "lashes") + " of the cobra left", "", description), 6));
        }
    }
}
