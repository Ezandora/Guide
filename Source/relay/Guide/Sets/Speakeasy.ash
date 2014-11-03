
void SSpeakeasyGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    if (!__misc_state["VIP available"])
        return;

    if (!(__misc_state["can drink just about anything"] && get_property_int("_speakeasyDrinksDrunk") <3 && mafiaIsPastRevision(14155) && availableDrunkenness() >= 0))
        return;
        
    //speakeasy:
    /*
        √Lucky lindy - good 1-potency, gives semi-rare. crucial in zombie slayer
        Bee's Knees - awesome 2-potency, 25 turns of +100% all stats
        √Sockdollager - awesome 2-potency, 25 turns of (+20 all elemental damage, +40 all elemental spell damage, +20 ranged/weapon damage, +50% weapon/spell damage, +50 spell damage
        Flivver - 20,000 meat epic 2-potency, restores mana (not useful in-run)
        √Hot Socks - awesome 3-potency, 50 turns of (+2 familiar experience, +10 familiar weight, +20 familiar damage)
        √Sloppy Jalopy - 100,000 meat awesome 5-potency, gives skill Hollow Leg (+1 liver capacity) for aftercore
        Phonus Balonus - +fights/+adventures
        Ish Kabibble - +3 all res, +DA/DR
    */
    int drinks_remaining = MAX(3 - get_property_int("_speakeasyDrinksDrunk"), 0);
    
    string [int][int] options;
    
    options.listAppend(listMake("<strong>Drink</strong>", "<strong>Size</strong>", "<strong>Description</strong>"));
    if (CounterLookup("Semi-rare").CounterIsRange())
        options.listAppend(listMake("Lucky Lindy", "1", "Semi-rare number"));
    
    //FIXME every drink
    //FIXME gray out drinks we can't drink at the moment (drunkenness, meat)
    
    if (lookupEffect("Hip to the Jive").have_effect() == 0 && !__misc_state["familiars temporarily blocked"] && __misc_state["In run"])
    {
        string [int] description;
        description.listAppend("+10 familiar weight");
        if (familiar_weight(my_familiar()) < 20)
            description.listAppend("+2 familiar exp/fight");
        options.listAppend(listMake("Hot Socks", "3", description.listJoinComponents("|")));
    }
    
    if (!__misc_state["In run"] && !lookupSkill("Hollow Leg").have_skill())
        options.listAppend(listMake("Sloppy Jalopy", "5", "+1 liver capacity skill|Very expensive"));
    
    
    string [int] reasons_to_sockdollager;
    if (!__quest_state["Level 3"].finished)
    {
        boolean can_skip_cold = numeric_modifier("Cold Damage") >= 20.0;
        boolean can_skip_hot = numeric_modifier("Hot Damage") >= 20.0;
        boolean can_skip_spooky = numeric_modifier("Spooky Damage") >= 20.0;
        boolean can_skip_stench = numeric_modifier("Stench Damage") >= 20.0;
        if (!can_skip_cold || !can_skip_hot || !can_skip_spooky || !can_skip_stench)
            reasons_to_sockdollager.listAppend("tavern NC skipping");
    }
    
    if (my_path_id() == PATH_HEAVY_RAINS && !__quest_state["Level 13"].finished)
        reasons_to_sockdollager.listAppend("fighting rain king");
    
    if (reasons_to_sockdollager.count() > 0)
        options.listAppend(listMake("Sockdollager", "2", reasons_to_sockdollager.listJoinComponents(", ", "and").capitalizeFirstLetter()));
    
    if (__misc_state["In run"] && my_meat() >= 20000)
        options.listAppend(listMake("Flivver", "2", "Epic-level drunkenness."));
    
    if (__misc_state["need to level"])
    {
        string drink_name = "";
        
        if (my_primestat() == $stat[muscle])
        {
            drink_name = "Glass of \"milk\"";
        }
        else if (my_primestat() == $stat[mysticality])
        {
            drink_name = "Cup of \"tea\"";
        }
        else if (my_primestat() == $stat[moxie])
        {
            drink_name = "Thermos of \"whiskey\"";
        }
        if (drink_name.length() > 0)
        {
            float mainstat_gain = 87.5 * (1.0 + numeric_modifier(my_primestat().to_string() + " Experience Percent") / 100.0);
            string description = mainstat_gain.roundForOutput(0) + " mainstat";
            //if (my_path_id() != PATH_SLOW_AND_STEADY)
                //description += "";
            options.listAppend(listMake(drink_name, "1", description));
        }
        
    }
    
    if (hippy_stone_broken())
    {
        options.listAppend(listMake("Phonus Balonus", "3", "+fights/+adventures"));
    }
    
    string [int] description;
    if (options.count() > 1)
        description.listAppend(HTMLGenerateSimpleTableLines(options));
    
    if (__misc_state["In run"] || drinks_remaining > 0)
        available_resources_entries.listAppend(ChecklistEntryMake("__item observational glasses", "clan_viplounge.php?action=speakeasy", ChecklistSubentryMake(pluralize(drinks_remaining, "speakeasy drink", "speakeasy drinks"), "", description), 8)); //the eyes of T.J. Eckleburg
    
}