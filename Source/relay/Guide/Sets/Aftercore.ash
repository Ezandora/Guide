void SAftercoreThingsToDoGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //To implement:
    //The Sea - rescuing mom, √temple boss if they're missing anything, that one skater quest, whatever else is there
    //The suburbs of dis? Is this detectable?
    //Farming four shore inc. trip scrip for ascension.
    //√Space elves.
    //telescope upgrades - telescopeUpgrades (needs basement level check)
    //dungeons? slime tube, hobopolis, dreadsylvania, library, items and skills and such
    //hobo codes? (no support)
    //demon names
    //el vibrato island - familiar, mostly, plus items? (bad moon check)
    //agua de vida memories quest?
    //artist quest?
    //going postal quest
    //bounty hunting
    //starting SBB quests / UMD in inventory to use
    //examine http://kol.coldfront.net/thekolwiki/index.php/Quest_Spoilers
    //jung jar items
    //dwarven factory
    
    Record AftercoreOption
    {
        string header;
        string url;
        string [int] description;
    };
    AftercoreOption AftercoreOptionMake(string header, string url, string [int] description)
    {
        AftercoreOption task;
        task.header = header;
        task.url = url;
        task.description = description;
        return task;
    }
    void listAppend(AftercoreOption [int] list, AftercoreOption entry)
    {
        int position = list.count();
        while (list contains position)
            position += 1;
        list[position] = entry;
    }

    
    AftercoreOption [int] options;
    
    if (knoll_available() && !QuestState("questM03Bugbear").started)
    {
        options.listAppend(AftercoreOptionMake("Felonia quest", "place.php?whichplace=knoll_friendly", listMake("speak to Mayor Zapruder", "rewards once/ascension mushroom fermenting solution")));
    }
    
    if (!QuestState("questG04Nemesis").started)
    {
        string [int] things_gives;
        things_gives.listAppend("instant karma");
        if (my_class() == $class[disco bandit])
            things_gives.listAppend("rave skills");
        options.listAppend(AftercoreOptionMake("Nemesis quest", "guild.php", listMake("Rewards " + things_gives.listJoinComponents(", ", "and"))));
    }
    
    if (!QuestState("questF04Elves").started && $effect[transpondent].have_effect() == 0)
    {
        string url;
        string first_task;
        if ($item[transporter transponder].available_amount() > 0)
        {
            url = "inventory.php?which=3";
            first_task = "use transporter transponder";
        }
        else
        {
            url = "mall.php";
            first_task = "buy and use transporter transponder";
        }
        options.listAppend(AftercoreOptionMake("Repair the Elves' Shield Generator", url, listMake(first_task, "rewards 200 lunar isotopes, and space store access")));
    }
    
    
    if (false) //disabled for now - we don't have suggestions for every path, and this may be too much information to list? need to decide
    {
        //Grimstone:
        string [item] grimstone_paths;
        grimstone_paths[$item[silver cow creamer]] = "stepmother";
        grimstone_paths[$item[wolf whistle]] = "wolf";
        grimstone_paths[$item[witch's bra]] = "witch";
        if (get_campground()[$item[spinning wheel]] == 0)
            grimstone_paths[$item[spinning wheel]] = "gnome";
        grimstone_paths[$item[hare pin]] = "hare";
        
        string [int] relevant_grimstone_paths;
        item [int] relevant_rewards;
        foreach it in grimstone_paths
        {
            if (haveAtLeastXOfItemEverywhere(it, 1))
                continue;
            relevant_grimstone_paths.listAppend(grimstone_paths[it]);
            relevant_rewards.listAppend(it);
        }
        if (relevant_grimstone_paths.count() > 0)
        {
            string path_string = "path available";
            if (relevant_grimstone_paths.count() > 1)
                path_string = "paths available";
                
            options.listAppend(AftercoreOptionMake("grimstone mask quests", "", listMake(relevant_grimstone_paths.listJoinComponents(", ", "and") + " " + path_string, "Rewards " + relevant_rewards.listJoinComponents(", ", "or"))));
        }
    }
    
    if (get_property("merkinQuestPath") == "none" || get_property("merkinQuestPath").length() == 0)
    {
        //Do they need to complete that quest? Let's find out.
        item [class][int] class_temple_items;
        boolean [item] loathing_craftable_items = $items[belt of loathing,goggles of loathing,jeans of loathing,scepter of loathing,stick-knife of loathing,treads of loathing];
        class_temple_items[$class[seal clubber]] = listMake($item[Cold Stone of Hatred], $item[Ass-Stompers of Violence]);
        class_temple_items[$class[turtle tamer]] = listMake($item[Girdle of Hatred], $item[Brand of Violence]);
        class_temple_items[$class[pastamancer]] = listMake($item[Staff of Simmering Hatred], $item[Novelty Belt Buckle of Violence]);
        class_temple_items[$class[sauceror]] = listMake($item[Pantaloons of Hatred], $item[Lens of Violence]);
        class_temple_items[$class[disco bandit]] = listMake($item[Fuzzy Slippers of Hatred], $item[Pigsticker of Violence]);
        class_temple_items[$class[accordion thief]] = listMake($item[Lens of Hatred], $item[Jodhpurs of Violence]);
        
        //For our class, determine what items we're missing:
        item [int] our_class_items = class_temple_items[my_class()];
        int [item] total_amount_of_item_wanted;
        boolean [item] want_item_for_crafting_loathing;
        foreach key, it in our_class_items
        {
            total_amount_of_item_wanted[it] = 1;
        }
        foreach loathing_piece in loathing_craftable_items
        {
            if (haveAtLeastXOfItemEverywhere(loathing_piece, 1))
                continue;
            int [item] components = loathing_piece.get_ingredients();
            foreach component in components
            {
                if (total_amount_of_item_wanted contains component) //if this component is part of our class components
                {
                    total_amount_of_item_wanted[component] += 1;
                    want_item_for_crafting_loathing[component] = true;
                }
            }
        }
        string [int] description_items;
        foreach it, amount in total_amount_of_item_wanted
        {
            int missing = amount - it.item_amount_almost_everywhere();
            if (missing <= 0)
                continue;
            string line = "a " + it;
            if (it.to_string().contains_text("Violence"))
                line += " (gladiator path)";
            else
                line += " (scholar path)";
            if (want_item_for_crafting_loathing[it])
            {
                line += " for loathing gear piece";
                if (missing >= 2)
                    line += "/to own";
            }
            description_items.listAppend(line);
        }
        if (description_items.count() > 0)
            options.listAppend(AftercoreOptionMake("mer-kin temple in the sea", "", listMake("can find " + description_items.listJoinComponents(", ", "or"))));
    }
    if (__misc_state["stench airport available"] && !get_property_ascension("lastWartDinseyDefeated"))
    {
        item dinsey_item;
        if (my_class() == $class[seal clubber])
            dinsey_item = $item[Dinsey's oculus];
        else if (my_class() == $class[turtle tamer])
            dinsey_item = $item[Dinsey's radar dish];
        else if (my_class() == $class[pastamancer])
            dinsey_item = $item[Dinsey's pizza cutter];
        else if (my_class() == $class[sauceror])
            dinsey_item = $item[Dinsey's brain];
        else if (my_class() == $class[disco bandit])
            dinsey_item = $item[Dinsey's pants];
        else if (my_class() == $class[accordion thief])
            dinsey_item = $item[Dinsey's glove];
        
        if (dinsey_item != $item[none] && !haveAtLeastXOfItemEverywhere(dinsey_item, 1))
        {
            location [item] keycards;
            
            keycards[$item[keycard &alpha;]] = $location[Barf Mountain];
            keycards[$item[keycard &beta;]] = $location[Pirates of the Garbage Barges];
            keycards[$item[keycard &gamma;]] = $location[The Toxic Teacups];
            keycards[$item[keycard &delta;]] = $location[Uncle Gator's Country Fun-Time Liquid Waste Sluice];
            location [int] missing_locations;
            item [int] missing_keycards;
            foreach it, l in keycards
            {
                if (it.available_amount() == 0)
                {
                    missing_keycards.listAppend(it);
                    missing_locations.listAppend(l);
                }
                    
            }
            if (missing_keycards.count() > 0)
            {
                options.listAppend(AftercoreOptionMake("defeat Wart Dinsey", "", listMake("Find keycards in " + missing_locations.listJoinComponents(", ", "and"))));
            }
        }
    }
    
    if (options.count() > 0)
    {
        string [int] description;
        string url = "";
        foreach key, option in options
        {
            option.header = option.header.capitaliseFirstLetter();
            foreach key in option.description
            {
                option.description[key] = option.description[key].capitaliseFirstLetter() + ".";
            }
            if (url.length() == 0)
                url = option.url;
            description.listAppend(option.header + HTMLGenerateIndentedText(option.description.listJoinComponents("<br>")));
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__effect confused", url, ChecklistSubentryMake("Try an optional quest", "", description), 8));
    }
}

void SAftercoreGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__misc_state["in aftercore"])
        return;
    //Campground items:
    int [item] campground_items = get_campground();
    
    if (campground_items[$item[clockwork maid]] == 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item sprocket", "", ChecklistSubentryMake("Install a clockwork maid", "", listMake("+8 adventures/day.", "Buy from mall."))));
    }
    if (campground_items[$item[pagoda plans]] == 0 && $location[Pandamonium Slums].locationAvailable())
    {
        string url;
        string [int] details;
        details.listAppend("+3 adventures/day.");
        
        if ($item[hey deze nuts].item_amount() == 0)
        {
            if ($item[hey deze map].item_amount() == 0)
            {
                url = "pandamonium.php";
                details.listAppend("Adventure in Pandamonium Slums for Hey Deze Map. (25% superlikely)");
            }
            else
            {
                string [int] things_to_do;
                string [int] things_to_buy;
                if ($item[heavy metal sonata].item_amount() == 0)
                    things_to_buy.listAppend("heavy metal sonata");
                if ($item[heavy metal thunderrr guitarrr].item_amount() == 0)
                    things_to_buy.listAppend("heavy metal thunderrr guitarrr");
                if ($item[guitar pick].item_amount() == 0)
                    things_to_buy.listAppend("guitar pick");
                if (things_to_buy.count() > 0)
                    things_to_do.listAppend("buy " + things_to_buy.listJoinComponents(", ", "and") + " in mall, ");
                things_to_do.listAppend("use hey deze map");
				details.listAppend(things_to_do.listJoinComponents("", "then").capitaliseFirstLetter() + ".");
            }
        }
        if ($item[pagoda plans].item_amount() == 0)
        {
            if ($item[Elf Farm Raffle ticket].item_amount() == 0)
            {
                details.listAppend("Buy a Elf Farm Raffle ticket from the mall.");
            }
            else
            {
                if (url.length() == 0)
                    url = "inventory.php?which=3";
                if (in_bad_moon()) //Does bad moon aftercore require a clover?
                {
                    details.listAppend("Use Elf Farm Raffle ticket.");
                }
                else
                {
                    details.listAppend("Acquire ten-leaf clover, then use Elf Farm Raffle ticket.");
                }
            }
        }
        if ($item[ketchup hound].item_amount() == 0)
        {
            if (url.length() == 0)
                url = "mall.php";
            details.listAppend("Buy a ketchup hound from the mall.");
        }
        if ($item[ketchup hound].item_amount() > 0 && $item[hey deze nuts].item_amount() > 0 && $item[pagoda plans].item_amount() > 0)
        {
            if (url.length() == 0)
                url = "inventory.php?which=3";
            details.listAppend("Use a ketchup hound to install pagoda.");
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item pagoda plans", url, ChecklistSubentryMake("Install a pagoda", "", details)));
    }
    
    if (knoll_available() && !have_mushroom_plot() && get_property("plantingScript") != "")
    {
        //They can plant a mushroom plot, and they have a planting script. But they haven't yet, so let's suggest it:
        optional_task_entries.listAppend(ChecklistEntryMake("__item knob mushroom", "knoll_mushrooms.php", ChecklistSubentryMake("Plant a mushroom plot", "", "Degrassi Knoll")));
    }
    
    
    SAftercoreThingsToDoGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}