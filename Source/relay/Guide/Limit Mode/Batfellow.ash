
import "relay/Guide/Limit Mode/Batfellow State.ash";


void LimitModeBatfellowGenerateResources(ChecklistEntry [int] resource_entries, BatState state)
{
    if (__setting_debug_mode)
    {
        string [int] description;
        foreach s in $strings[batmanBonusInitialFunds,batmanFundsAvailable,batmanStats,batmanTimeLeft,batmanUpgrades,batmanZone]
        {
            description.listAppend(s + " = " + get_property(s));
        }
        description.listAppend("Dwayne Manor");
        resource_entries.listAppend(ChecklistEntryMake("__item batarang", "", ChecklistSubentryMake("Bat-Properties", "", description), 8));
        
        resource_entries.listAppend(ChecklistEntryMake("__item batarang", "", ChecklistSubentryMake("Bat-State", "", state.to_json()), 8));
    }
    
    string [item] item_descriptions;
    item_descriptions[$item[bat-oomerang]] = "Deals 20 damage, disarms foes, speeds up sewers.";
    item_descriptions[$item[bat-jute]] = "Against a monster with ten or less HP, defeats foe and increases progress that fight.|Speeds up the library.";
    item_descriptions[$item[bat-o-mite]] = "Instakill, speeds up asylum.";
    
    item_descriptions[$item[incriminating evidence]] = "Trade for armour upgrades and progress increasers.";//, which also help with the trivia company and the conservatory.";
    item_descriptions[$item[dangerous chemicals]] = "Trade for health upgrades and HP restorers.";//, which also help with the foundry and the reservoir.";
    item_descriptions[$item[kidnapped orphan]] = "Trade for attack upgrades and free instakills.";//, which also help with the clock factory and cemetary.";
    
    
    item_descriptions[$item[high-grade metal]] = "make bat-oomeranges (damages)";
    item_descriptions[$item[high-tensile-strength fibers]] = "makes bat-jutes (damages)";
    item_descriptions[$item[high-grade explosives]] = "makes bat-o-mites (kills?)";
    
    item_descriptions[$item[experimental gene therapy]] = "";
    item_descriptions[$item[ultracoagulator]] = "restores all HP, speeds up foundry and reservoir";
    item_descriptions[$item[self-defense training]] = "";
    item_descriptions[$item[fingerprint dusting kit]] = "4% progress/fight, speeds up trivia company and conservatory";
    item_descriptions[$item[confidence-building hug]] = "";
    item_descriptions[$item[exploding kickball]] = "skips monster to advance the NC, speeds up clock factory and cemetary";
    item_descriptions[$item[glob of Bat-Glue]] = "stuns for multiple rounds, speeds up conservatory";
    item_descriptions[$item[Bat-Aid&trade; bandage]] = "restores 20 HP, speeds up reservoir";
    item_descriptions[$item[bat-bearing]] = "stuns foes, deals 15 damage, speeds up cemetary";
    
    item [int][int] item_groupings;
    item_groupings.listAppend(listMake($item[bat-oomerang], $item[bat-jute], $item[bat-o-mite]));
    item_groupings.listAppend(listMake($item[incriminating evidence], $item[dangerous chemicals], $item[kidnapped orphan]));
    item_groupings.listAppend(listMake($item[high-grade metal], $item[high-tensile-strength fibers], $item[high-grade explosives]));
    
    foreach it in item_descriptions
        item_groupings.listAppend(listMake(it));
    
    /*foreach it in $items[]
    {
        if (it.available_amount() > 0)
            item_groupings.listAppend(listMake(it));
    }*/
    boolean [item] seen_items;
    foreach key in item_groupings
    {
        ChecklistEntry entry;
        foreach key2, it in item_groupings[key]
        {
            if (seen_items[it])
                continue;
            if (it.available_amount() > 0)
            {
                seen_items[it] = true;
                string description = item_descriptions[it];
                if (item_descriptions contains it && description == "") //deliberately ignore, for the three upgrade items
                    continue;
                entry.subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", description));
                if (entry.image_lookup_name == "")
                    entry.image_lookup_name = "__item " + it;
                //resource_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake(pluralise(it), "", description), 8));
            }
        }
        if (entry.subentries.count() > 0)
            resource_entries.listAppend(entry);
    }
}


void LimitModeBatfellowGeneralGenerateTasks(ChecklistEntry [int] task_entries, BatState state)
{
    if (true)
    {
        string [int] description;
        if (state.zone != "Downtown")
        {
            if (my_hp() == 0)
                description.listAppend("Go downtown, visit the hospital?");
        }
        else if (my_hp() != my_maxhp())
            description.listAppend("Visit the hospital?");
        if (description.count() > 0)
            task_entries.listAppend(ChecklistEntryMake("__item bubblegum heart", "main.php", ChecklistSubentryMake("Heal", "", description), -11));
    }
    
}

void LimitModeBatfellowBossesGenerateTasks(ChecklistEntry [int] task_entries, BatState state)
{
    foreach l, area in __batfellow_bosses
    {
        if (area.zone != state.zone)
            continue;
        
        int area_progress = -1;
        int progress_remaining = clampi(100 - area_progress, 0, 100);
        
        
        string [int] description;
        if (progress_remaining > 0)
        {
            if (area_progress == -1)
                description.listAppend("?% progress remaining.");
            else
                description.listAppend(progress_remaining + "% progress remaining.");
            
            if (progress_remaining > 10)
            {
                //description.listAppend("area = " + area.to_json());
                boolean has_fifty_progress = false;
                boolean meets_fifty_progress = false;
                if (area.nc_fifty_progress_requirements.count() > 0)
                {
                    has_fifty_progress = true;
                    meets_fifty_progress = true;
                    foreach it, amount in area.nc_fifty_progress_requirements
                    {
                        if (it.available_amount() < amount)
                        {
                            meets_fifty_progress = false;
                            int remaining = MAX(0, amount - it.available_amount());
                            description.listAppend("Avoid until you have " + remaining.int_to_wordy() + " more " + (remaining > 1 ? it.plural : it) + ".|(50% progress in NC)");
                        }
                    }
                }
                if (area.nc_twenty_five_progress_requirements.count() > 0 && !(has_fifty_progress && meets_fifty_progress))
                {
                    foreach it, amount in area.nc_twenty_five_progress_requirements
                    {
                        if (it.available_amount() < amount)
                        {
                            int remaining = MAX(0, amount - it.available_amount());
                            string line = "Avoid until you have ";
                            if (has_fifty_progress && !meets_fifty_progress)
                                line = "Or until you have ";
                            line += remaining.int_to_wordy() + " more " + (remaining > 1 ? it.plural : it) + ".|(25% progress in NC)";
                            description.listAppend(line);
                        }
                    }
                }
                if (area.strategies.count() > 0)
                    description.listAppend(area.strategies.listJoinComponents("|"));
                if (area.nc_reward_items.count() > 0)
                {
                    string [int] rewards;
                    foreach it, amount in area.nc_reward_items
                    {
                        rewards.listAppend(pluralise(amount, it));
                    }
                    description.listAppend("NC reward option gives " + rewards.listJoinComponents(", ", "and") + ".");
                }
            }
            task_entries.listAppend(ChecklistEntryMake(area.image_name, "main.php", ChecklistSubentryMake("Fight in the " + area.short_name, "", description), 8));
        }
        else
        {
            task_entries.listAppend(ChecklistEntryMake("__monster " + area.boss, "main.php", ChecklistSubentryMake("Defeat " + area.boss, "", ""), 8));
        }
        
    }
    
}

void LimitModeBatfellowJokesterGenerateTasks(ChecklistEntry [int] task_entries, BatState state)
{
    return;
}

void LimitModeBatfellowBatCavernGenerateTaskResources(ChecklistEntry [int] task_entries, ChecklistEntry [int] resource_entries, BatState state)
{
    boolean found_tasks = false;
    if (state.funds_available > 0)
    {
        string [string][string] suggested_upgrades;
        suggested_upgrades["Suit"] = mapMake();
        suggested_upgrades["Sedan"] = mapMake();
        suggested_upgrades["Cavern"] = mapMake();
        //orphans,evidence,chemicals bat-sedan
        //lower combat time
        //two that decrease searching
        //glue, bearings, bat-aids after every third combat
        //orphan/chemical upgrades, but not evidence upgrades?
        suggested_upgrades["Suit"]["Improved Cowl Optics"] = "find things?";
        suggested_upgrades["Suit"]["Utility Belt First Aid Kit"] = "bandages every third combat";
        suggested_upgrades["Suit"]["Extra-Swishy Cloak"] = "prevents first hit in combat";
        suggested_upgrades["Suit"]["Hardened Knuckles"] = "double punch damage";
        suggested_upgrades["Suit"]["Steel-Toed Bat-Boots"] = "double kick damage";
        
        suggested_upgrades["Sedan"]["Rocket Booster"] = "faster travel time";
        suggested_upgrades["Sedan"]["Street Sweeper"] = "gather evidence while driving";
        suggested_upgrades["Sedan"]["Advanced Air Filter"] = "gather dangerous chemicals while driving";
        suggested_upgrades["Sedan"]["Orphan Scoop"] = "gather orphans while driving";
        suggested_upgrades["Sedan"]["Spotlight"] = "faster progress";
        suggested_upgrades["Sedan"]["Loose Bearings"] = "bearings every third combat";
        
        
        suggested_upgrades["Cavern"]["Surveillance Network"] = "faster progress";
        suggested_upgrades["Cavern"]["Glue Factory"] = "glue every third combat";
        suggested_upgrades["Cavern"]["Improved 3-D Bat-Printer"] = "cheaper bat-materials";
        suggested_upgrades["Cavern"]["Really Long Winch"] = "instant travel back home";
        suggested_upgrades["Cavern"]["Blueprints Database"] = "faster progress?";
        suggested_upgrades["Cavern"]["Transfusion Satellite"] = "restores 5 hp/fight";
        
        
        string [int] description;
        foreach type in $strings[Suit,Sedan,Cavern]
        {
            string [int] type_upgrades;
            foreach upgrade_name, upgrade_decription in suggested_upgrades[type]
            {
                if (state.upgrades contains upgrade_name)
                    continue;
                type_upgrades.listAppend(HTMLGenerateSpanOfClass(upgrade_name, "r_bold") + ": " + upgrade_decription);
            }
            if (type_upgrades.count() == 0) continue;
            description.listAppend(HTMLGenerateSpanOfClass(type, "r_bold") + ":|*" + type_upgrades.listJoinComponents("|*"));
        }
        string url;
        if (state.zone == "Bat-Cavern")
            url = "place.php?whichplace=batman_cave&action=batman_cave_rnd";
        else
            description.listAppend("Travel to the Bat-Cavern first.");
        ChecklistEntry entry = ChecklistEntryMake("__item fat stacks of cash", url, ChecklistSubentryMake(pluralise(state.funds_available, "Bat-Research", "Bat-Researches"), "", description), 8);
        if (state.zone != "Bat-Cavern")
            resource_entries.listAppend(entry);
        else
        {
            task_entries.listAppend(entry);
            found_tasks = true;
        }
    }
    if (state.zone == "Bat-Cavern" && $items[high-grade metal,high-tensile-strength fibers,high-grade explosives].available_amount() > 0)
    {
        item [item] fabricator_conversions;
        fabricator_conversions[$item[high-grade metal]] = $item[bat-oomerang];
        fabricator_conversions[$item[high-tensile-strength fibers]] = $item[bat-jute];
        fabricator_conversions[$item[high-grade explosives]] = $item[bat-o-mite];
        int cost_per_conversion = 3;
        if (state.upgrades["Improved 3-D Bat-Printer"])
            cost_per_conversion = 2;
        string [int] craftables;
        foreach source, destination in fabricator_conversions
        {
            int amount_craftable = source.available_amount() / cost_per_conversion;
            if (amount_craftable > 0)
            {
                craftables.listAppend(pluralise(amount_craftable, destination));
            }
        }
        
        string [int] description;
        if (craftables.count() > 0)
            description.listAppend("Can make " + craftables.listJoinComponents(", ", "and") + ".");
        if (description.count() > 0)
        {
            task_entries.listAppend(ChecklistEntryMake("__item high-grade explosives", "shop.php?whichshop=batman_cave", ChecklistSubentryMake("Bat-Fabricate", "", description), 8));
            found_tasks = true;
        }
    }
    if (!found_tasks && state.zone == "Bat-Cavern")
    {
        string [int] description;
        task_entries.listAppend(ChecklistEntryMake("__item bitchin' meatcar", "place.php?whichplace=batman_cave&action=batman_cave_car", ChecklistSubentryMake("Travel somewhere", "", description), 8));
    }
    
}
void LimitModeBatfellowDowntownGenerateTasks(ChecklistEntry [int] task_entries, BatState state)
{
    if (state.zone != "Downtown")
        return;
    item evidence = $item[incriminating evidence];
    item chemicals = $item[dangerous chemicals];
    item orphans = $item[kidnapped orphan];
    boolean found_tasks = false;
    if (orphans.available_amount() > 0)
    {
        string [int] description;
        string [int] options;
        int hug_price = 3 + 3 * $item[confidence-building hug].available_amount();
        if (hug_price <= orphans.available_amount())
            options.listAppend("+1 damage upgrades");
        options.listAppend("freekill kickballs");
        description.listAppend(options.listJoinComponents(" / ").capitaliseFirstLetter() + ".");
        task_entries.listAppend(ChecklistEntryMake("__item kidnapped orphan", "shop.php?whichshop=batman_orphanage", ChecklistSubentryMake("Turn in orphans", "", description), 8));
        found_tasks = true;
    }
    if (chemicals.available_amount() > 0)
    {
        string [int] description;
        string [int] options;
        int hug_price = 3 + 3 * $item[experimental gene therapy].available_amount();
        if (hug_price <= chemicals.available_amount())
            options.listAppend("+10 HP upgrades");
        options.listAppend("HP-restoring ultracoagulators");
        description.listAppend(options.listJoinComponents(" / ").capitaliseFirstLetter() + ".");
        task_entries.listAppend(ChecklistEntryMake("__item " + chemicals, "shop.php?whichshop=batman_chemicorp", ChecklistSubentryMake("Turn in chemicals", "", description), 8));
        found_tasks = true;
    }
    if (evidence.available_amount() > 0)
    {
        string [int] description;
        string [int] options;
        int hug_price = 3 + 3 * $item[self-defense training].available_amount();
        if (hug_price <= evidence.available_amount())
            options.listAppend("+armour upgrades");
        options.listAppend("progress-increasing fingerprint dusting kits");
        description.listAppend(options.listJoinComponents(" / ").capitaliseFirstLetter() + ".");
        task_entries.listAppend(ChecklistEntryMake("__item " + evidence, "shop.php?whichshop=batman_pd", ChecklistSubentryMake("Turn in evidence", "", description), 8));
        found_tasks = true;
    }
    if (!found_tasks && my_hp() == my_maxhp())
    {
        string [int] description;
        task_entries.listAppend(ChecklistEntryMake("__item bitchin' meatcar", "place.php?whichplace=batman_downtown&action=batman_downtown_car", ChecklistSubentryMake("Travel somewhere", "", description), 8));
    }
}

void LimitModeBatfellowGenerateChecklists(Checklist [int] checklists)
{
    if (limit_mode() != "batman")
        return;

    ChecklistEntry [int] task_entries;
    ChecklistEntry [int] optional_task_entries;
    ChecklistEntry [int] future_task_entries;
    ChecklistEntry [int] resource_entries;

    if (true)
    {
        Checklist task_checklist;
        task_checklist = ChecklistMake("Bat-Tasks", task_entries);
        checklists.listAppend(task_checklist);
        
        
        Checklist optional_task_checklist;
        optional_task_checklist = ChecklistMake("Optional Bat-Tasks", optional_task_entries);
        checklists.listAppend(optional_task_checklist);
        
        Checklist future_task_checklist;
        future_task_checklist = ChecklistMake("Future Bat-Tasks", future_task_entries);
        checklists.listAppend(future_task_checklist);
        
        Checklist resources_checklist;
        resources_checklist = ChecklistMake("Bat-Resources", resource_entries);
        checklists.listAppend(resources_checklist);
    }
    
    BatState bat_state = BatStateMake();
    
    
    //task_entries.listAppend(ChecklistEntryMake("__item batarang", "", ChecklistSubentryMake("Stop the Jokester", "", "Better living through violence?"), 8));
    
    LimitModeBatfellowGenerateResources(resource_entries, bat_state);
    LimitModeBatfellowGeneralGenerateTasks(task_entries, bat_state);
    
    LimitModeBatfellowBossesGenerateTasks(task_entries, bat_state);
    
    LimitModeBatfellowJokesterGenerateTasks(task_entries, bat_state);
    
    LimitModeBatfellowBatCavernGenerateTaskResources(task_entries, resource_entries, bat_state);
    LimitModeBatfellowDowntownGenerateTasks(task_entries, bat_state);
}

RegisterResourceGenerationFunction("BatfellowGenerateResource");
void BatfellowGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($item[replica bat-oomerang].available_amount() > 0 && mafiaIsPastRevision(16927))
    {
        int remaining = clampi(3 - get_property_int("_usedReplicaBatoomerang"), 0, 3);
        if (remaining > 0)
            resource_entries.listAppend(ChecklistEntryMake("__item replica bat-oomerang", "", ChecklistSubentryMake(pluralise(remaining, "replica bat-oomerang use", "replica bat-oomerang uses"), "", "Free instakill."), 5));
    }
    if ($item[The Jokester's Gun].available_amount() > 0 && mafiaIsPastRevision(16986) && !get_property_boolean("_firedJokestersGun"))
    {
        int importance = 5;
        string [int] description;
        description.listAppend("Free instakill.");
        if ($item[The Jokester's Gun].equipped_amount() == 0)
        {
            string line = "Equip it";
            if (!$item[The Jokester's Gun].can_equip())
            {
                line += ", once you can. (need 50 moxie)";
                importance = 8;
            }
            else
                line += " first.";
            description.listAppend(line);
        }
        else
            description.listAppend("Fire the Jokester's Gun skill in combat.");
        resource_entries.listAppend(ChecklistEntryMake("__item The Jokester's Gun", "", ChecklistSubentryMake("The Jokester's Gun firing", "", description), importance));
    }
}
