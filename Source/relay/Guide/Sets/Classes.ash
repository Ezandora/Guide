Record SealSummon
{
    monster summoned_monster;
    item figurine;
    boolean can_buy_in_store_or_hermit;
    int seal_clubber_candles_required;
    int imbued_seal_blubber_candles_required; //0 or 1
    int minimum_level;
    item item_dropped;
    item equipment_dropped;
    string item_dropped_description;
};

SealSummon SealSummonMake(monster summoned_monster, item figurine, boolean can_buy_in_store_or_hermit, int seal_clubber_candles_required, int imbued_seal_blubber_candles_required, int minimum_level, item item_dropped, string item_dropped_description, item equipment_dropped)
{
    SealSummon summon;
    summon.summoned_monster = summoned_monster;
    summon.figurine = figurine;
    summon.can_buy_in_store_or_hermit = can_buy_in_store_or_hermit;
    summon.seal_clubber_candles_required = seal_clubber_candles_required;
    summon.imbued_seal_blubber_candles_required = imbued_seal_blubber_candles_required;
    summon.minimum_level = minimum_level;
    summon.item_dropped = item_dropped;
    summon.equipment_dropped = equipment_dropped;
    summon.item_dropped_description = item_dropped_description;
    
    return summon;
}

void listAppend(SealSummon [int] list, SealSummon entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void SSealClubberInfernalSealsGenerateResource(ChecklistEntry [int] resource_entries)
{
    string [int] description;
    int seal_summon_limit = 5;
    if ($item[Claw of the Infernal Seal].available_amount() > 0)
    {
        seal_summon_limit = 10;
        if ($item[Claw of the Infernal Seal].item_amount() + $item[Claw of the Infernal Seal].equipped_amount() == 0 && $item[Claw of the Infernal Seal].storage_amount() > 0)
            description.listAppend("Pull the Claw of the Infernal Seal from hangk's.");
    }
    int seals_summoned = get_property_int("_sealsSummoned");
    int summons_remaining = MAX(seal_summon_limit - seals_summoned, 0);
    if (summons_remaining == 0)
        return;
    
    //Seal summons:
    //FIXME suggest they equip a club (support swords with iron palms)
    
    if (!$slot[weapon].equipped_item().weapon_is_club())
    {
        description.listAppend("Equip a club" + ($effect[Iron Palms].have_effect() > 0 ? " or sword" : "") + " first.");
    }
    
    
    //initialise all the seals:
    SealSummon [int] seal_summons;
    //seal_summons.listAppend(SealSummonMake($monster[SUMMONED_MONSTER], $item[FIGURINE], CAN_BUY_IN_STORE_OR_HERMIT, SEAL_CLUBBER_CANDLES_REQUIRED, IMBUED_SEAL_BLUBBER_CANDLES_REQUIRED, MINIMUM_LEVEL, $item[ITEM_DROPPED], "ITEM_DROPPED_DESCRIPTION"));
    seal_summons.listAppend(SealSummonMake($monster[broodling seal], $item[figurine of a cute baby seal], true, 5, 0, 5, $item[severed flipper], "", $item[none]));
    
    seal_summons.listAppend(SealSummonMake($monster[Centurion of Sparky], $item[figurine of an armored seal], true, 10, 0, 9, $item[ingot of seal-iron], ($items[ingot of seal-iron,bad-ass club].available_amount() == 0 ? "+10ML craftable club" : ""), $item[none]));
    
    seal_summons.listAppend(SealSummonMake($monster[hermetic seal], $item[figurine of an ancient seal], true, 3, 0, 6, $item[powdered sealbone], "imbued candle source", $item[none]));
    
    seal_summons.listAppend(SealSummonMake($monster[Spawn of Wally], $item[figurine of a wretched-looking seal], true, 1, 0, 1, $item[tainted seal's blood], "minor potion", $item[none]));
    
    seal_summons.listAppend(SealSummonMake($monster[heat seal], $item[figurine of a charred seal], false, 0, 1, 6, $item[sizzling seal fat], "+init, +hot damage potion", $item[Abyssal ember]));
    
    seal_summons.listAppend(SealSummonMake($monster[navy seal], $item[figurine of a cold seal], false, 0, 1, 6, $item[frost-rimed seal hide], "+cold damage, +HP potion", $item[frozen seal spine]));
    
    seal_summons.listAppend(SealSummonMake($monster[Servant of Grodstank], $item[figurine of a stinking seal], false, 0, 1, 6, $item[fustulent seal grulch], "+20 ML, +stench damage potion", $item[infernal toilet brush]));
    
    seal_summons.listAppend(SealSummonMake($monster[shadow of Black Bubbles], $item[figurine of a shadowy seal], false, 0, 1, 6, $item[scrap of shadow], "+spooky damage potion", $item[shadowy seal eye]));
    
    seal_summons.listAppend(SealSummonMake($monster[watertight seal], $item[figurine of a sleek seal], false, 0, 1, 12, $item[hyperinflated seal lung], "underwater breathing potion", $item[none]));
    
    seal_summons.listAppend(SealSummonMake($monster[wet seal], $item[figurine of a slippery seal], false, 0, 1, 6, $item[seal lube], "+sleaze damage, +moxie potion", $item[mannequin leg]));
    
    seal_summons.listAppend(SealSummonMake($monster[none], $item[depleted uranium seal figurine], false, 0, 1, 0, $item[none], "random", $item[none]));
    
    //description left blank, due to possible revamp?
    string url = "";
    if (guild_store_available())
        url = "shop.php?whichshop=guildstore3";
        
    boolean want_output_ml = __misc_state["need to level"];
    
        
    string [int][int] options;
    
    if (true)
    {
        string [int] option;
        option.listAppend("figurine");
        option.listAppend("candles");
        if (want_output_ml)
            option.listAppend("ML");
        option.listAppend("drops");
        foreach key, s in option
        {
            option[key] = HTMLGenerateSpanOfClass(s, "r_bold");
        }
        options.listAppend(option);
    }
        
    if ($item[powdered sealbone].available_amount() > 0 && $item[imbued seal-blubber candle].available_amount() == 0)
    {
        description.listAppend("Can make an imbued seal-blubber candle.");
    }
    
    foreach key, summon in seal_summons
    {
        if (summon.minimum_level > my_level())
            continue;
        if (!summon.can_buy_in_store_or_hermit && summon.figurine.available_amount() == 0)
            continue;
        string figurine_name_simple = summon.figurine.to_string().replace_string("figurine of an ", "").replace_string("figurine of a ", "");
        
        string candles_required = summon.seal_clubber_candles_required;
        if ($item[seal-blubber candle].available_amount() < summon.seal_clubber_candles_required)
            candles_required = HTMLGenerateSpanFont(candles_required, "grey");
        if (summon.imbued_seal_blubber_candles_required > 0)
        {
            candles_required = "imbued";
        }
        string ml_description;
        if (summon.summoned_monster != $monster[none])
        {
            ml_description = summon.summoned_monster.base_attack;
        }
        
        string item_description = summon.item_dropped_description;
        
        string [int] option;
        option.listAppend(figurine_name_simple);
        option.listAppend(candles_required);
        if (want_output_ml)
            option.listAppend(ml_description);
        option.listAppend(item_description);
        if (summon.imbued_seal_blubber_candles_required > 0 && $items[imbued seal-blubber candle,powdered sealbone].available_amount() == 0)
        {
            foreach key, s in option
            {
                option[key] = HTMLGenerateSpanFont(s, "grey");
            }
        }
        options.listAppend(option);
    }
    description.listPrepend(HTMLGenerateSimpleTableLines(options));
        
    resource_entries.listAppend(ChecklistEntryMake("__item figurine of an ancient seal", url, ChecklistSubentryMake(pluralise(summons_remaining, "seal summon", "seal summons"), "", description), 10));
}

void SSealClubberGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (my_class() != $class[seal clubber])
        return;

    SSealClubberInfernalSealsGenerateResource(resource_entries);
}

void STurtleTamerGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (my_class() != $class[turtle tamer])
        return;
    
    if (__misc_state["In run"] && guild_store_available() && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST && $effect[Eau de Tortue].have_effect() == 0 && my_meat() >= 200)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item helmet turtle", "shop.php?whichshop=guildstore3", ChecklistSubentryMake("Buy and use turtle pheromones", "", "Lets you encounter more turtles.")));
    }
}

void SDiscoBanditGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (my_class() != $class[disco bandit])
        return;
    if ($skill[Break It On Down].have_skill() && $skill[Run Like the Wind].have_skill() && $skill[Pop and Lock It].have_skill())
    {
        int steals_done = get_property_int("_raveStealCount");
        int steals_remaining = clampi(30 - steals_done, 0, 30);
        if (steals_done > 0 && steals_remaining > 0)
        {
            string [int] description;
            description.listAppend("Knocks loose a pickpocketable item.");
            //raveCombo5 is rave steal
            //FIXME list combo order
            string rave_combo_number_5 = get_property("raveCombo5");
            if (rave_combo_number_5 != "")
            {
                string [int] skill_order = rave_combo_number_5.split_string(",");
                description.listAppend(skill_order.listJoinComponents(__html_right_arrow_character).capitaliseFirstLetter() + ".");
            }
            resource_entries.listAppend(ChecklistEntryMake("__skill Disco Dance 3: Back in the Habit", "", ChecklistSubentryMake(pluralise(steals_remaining, "Rave Steal", "Rave Steals"), "", description), 8));
        }
    }
}

void SClassesGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    STurtleTamerGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}

void SClassesGenerateResource(ChecklistEntry [int] resource_entries)
{
    SSealClubberGenerateResource(resource_entries);
    SDiscoBanditGenerateResource(resource_entries);
}