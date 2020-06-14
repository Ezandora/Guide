RegisterTaskGenerationFunction("PathLicenseToAdventureGenerateTasks");
void PathLicenseToAdventureGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (myPathId() != PATH_LICENSE_TO_ADVENTURE)
        return;
    if (lookupItem("Victor's Spoils").available_amount() > 0 && !get_property_boolean("_victorSpoilsUsed"))
    {
        task_entries.listAppend(ChecklistEntryMake("__item victor's spoils", "inventory.php?ftext=victor's+spoils", ChecklistSubentryMake("Use Victor's Spoils", "", "Gives eleven adventures."), 3));
    }
    
    int lair_progress = get_property_int("_villainLairProgress");
    if (lair_progress < 999 && mafiaIsPastRevision(18065)) //revision is a guess
    {
        //_villainLairColorChoiceUsed, _villainLairDoorChoiceUsed, _villainLairSymbologyChoiceUsed
        //_villainLairCanLidUsed, _villainLairFirecrackerUsed, _villainLairWebUsed
        string [int] description;
        string [int] modifiers;
        description.listAppend("Prevents disavowed debuff. Costs quite a few turns, though, so consider skipping if you're leaderboarding.");
        description.listAppend("Progress: " + lair_progress + " minions.");
        
        if (!get_property_boolean("bondSymbols") && get_property_boolean("_villainLairSymbologyChoiceUsed"))
            description.listAppend("May want to learn LI-11's Universal Symbology Guide first, saves fifteen turns.");
        
        item [int] items_to_throw;
        if (!get_property_boolean("_villainLairCanLidUsed") && $item[razor-sharp can lid].item_amount() > 0)
            items_to_throw.listAppend($item[razor-sharp can lid]);
        if (!get_property_boolean("_villainLairFirecrackerUsed"))
        {
            if ($item[Knob Goblin firecracker].item_amount() > 0)
                items_to_throw.listAppend($item[Knob Goblin firecracker]);
            else if (!$location[cobb's knob barracks].locationAvailable())
                description.listAppend("Farm a Knob Goblin Firecracker from the Outskirts of Cobb's Knob first, but only while you're still on that quest.");
        }
        if (!get_property_boolean("_villainLairWebUsed") && $item[spider web].item_amount() > 0)
            items_to_throw.listAppend($item[spider web]);
        if (lookupItem("can of Minions-Be-Gone").item_amount() > 0)
            description.listAppend("Use " + pluralise(lookupItem("can of Minions-Be-Gone")) + ".");
        
        if (items_to_throw.count() > 0)
            description.listAppend("Use " + items_to_throw.listJoinComponents(", ", "and") + " in combat at the lair.");
        
        if (lair_progress >= 5 && (!get_property_boolean("_villainLairColorChoiceUsed") || !get_property_boolean("_villainLairDoorChoiceUsed") || !get_property_boolean("_villainLairSymbologyChoiceUsed")))
        {
            //I think there might be an in-game bug here? Someone noted seeing an NC first turn, even though CDMspading has it at five minions minimum?
            modifiers.listAppend("-combat");
            description.listAppend("Run -combat to speed up acquiring choices.");
        }
        task_entries.listAppend(ChecklistEntryMake("__item victor's spoils", "", ChecklistSubentryMake("Adventure in the Villain's Lair", modifiers, description), 3, lookupLocations("Super Villain's Lair")));
    }
    
    int social_capital_available = licenseToAdventureSocialCapitalAvailable();
    if (social_capital_available > 0)
    {
        int bond_points = get_property_int("bondPoints");
        string [int] description;
        
        //FIXME bond_points values are guesses
        if (!get_property_boolean("bondJetpack") && social_capital_available >= 3)
        {
            description.listAppend("Short-Range Jetpack: saves quite a few turns");
        }
        if (!get_property_boolean("bondSymbols") && social_capital_available >= 3)
        {
            description.listAppend("Universal Symbology Guide: if you're doing the lairs");
        }
        if (!get_property_boolean("bondBridge") && social_capital_available >= 3 && bond_points >= 3)
        {
            description.listAppend("Portable Pocket Bridge: speeds up level nine quest");
        }
        if (!get_property_boolean("bondWar") && social_capital_available >= 3 && bond_points >= 5)
        {
            description.listAppend("Trained Sniper, Felicity Snuggles: speeds up war");
        }
        if (!get_property_boolean("bondItem3") && social_capital_available >= 4 && bond_points >= 7)
        {
            description.listAppend("Electromagnetic Ring: +30% item");
        }
        if (!get_property_boolean("bondDrunk2") && social_capital_available >= 3)
        {
            description.listAppend("Soberness Injection Pen: +2 max drunkenness");
        }
        if (!get_property_boolean("bondDrunk1") && social_capital_available >= 2)
        {
            description.listAppend("Belt-Implanted Still: +1 max drunkenness");
        }
        if (!get_property_boolean("bondItem2") && social_capital_available >= 2)
        {
            description.listAppend("Sticky Climbing Gloves: +20% item");
        }
        if (!get_property_boolean("bondAdv") && social_capital_available >= 1)
        {
            description.listAppend("Super-Accurate Spy Watch: +11 adventures/rollover");
        }
        if (!get_property_boolean("bondMartiniTurn") && social_capital_available >= 1)
        {
            description.listAppend("Exotic Bartender, Barry L. Eagle: +1 adv/drink");
        }
        if (!get_property_boolean("bondItem1") && social_capital_available >= 1)
        {
            description.listAppend("Master Art Thief, Sly Richard: +10% item");
        }
        if (!get_property_boolean("bondInit") && social_capital_available >= 1)
        {
            description.listAppend("Jet-Powered Skis: +30% init");
        }
        if (!get_property_boolean("bondSpleen") && social_capital_available >= 5 && $item[astral energy drink].available_amount() >= 2 && bond_points >= 9)
        {
            description.listAppend("Robo-Speen: Consume two AEDs in a day.");
        }
            
            
        optional_task_entries.listAppend(ChecklistEntryMake("__item briefcase", "place.php?whichplace=town_right&action=town_bondhq", ChecklistSubentryMake("Spend " + social_capital_available + " social capital", "", description), 3));
    }
}
