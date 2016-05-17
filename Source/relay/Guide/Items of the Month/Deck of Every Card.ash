record DOECSummon
{
    string [int] cards;
    string reason;
};

DOECSummon DOECSummonMake(string [int] cards, string reason)
{
    DOECSummon summon;
    summon.cards = cards;
    summon.reason = reason;
    return summon;
}

DOECSummon DOECSummonMake(string card, string reason)
{
    string [int] cards;
    cards.listAppend(card);
    return DOECSummonMake(cards, reason);
}

void listAppend(DOECSummon [int] list, DOECSummon entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

RegisterResourceGenerationFunction("IOTMDeckOfEveryCardGenerateResource");
void IOTMDeckOfEveryCardGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($item[Deck of Every Card].available_amount() == 0 || !$item[Deck of Every Card].is_unrestricted())
        return;
    
    if (!mafiaIsPastRevision(16018))
        return;
    
    int card_summons_left = clampi(15 - get_property_int("_deckCardsDrawn"), 0, 15);
    
    /*
    In-run:
    √Sheep - 3 stone wool
    √X - The Wheel of Fortune - +100% item for 20 turns
    √[mainstat cards] - gain 500 mainstat
    √XVI - The Tower - DD key
    Professor Plum - lets you make ten crimbo pies under the knoll sign. maybe useful if we have fullness over, like, twenty-five?
    √Spare tire/Extra tank - something meatcar outside of knoll, might not be worth it? just summon the 10k card and buy a bus pass (ignoring... maybe surprising fist?)
    Fish DNA - acquire a free runaway in... HCO? or any path where that's relevant (not HR)
    X of Coins - X * 500 meat - if we have low meat and we've already summoned the mantle... maybe
    √[three +mainstat cards] - stat test in the tower
    √weapons
    
    
    
    Aftercore:
    √random cards - fun!
    √knife - meat farming
    Laboratory - five random potions? ???
    √[monster types] - fight a random monster for factoids
    √gift card - sell a draw in the mall to the needy
    √IV - The Emperor - until we have outfit
    IX - The Hermit - until we have all factoids
    
    Both:
    √ancestral recall / Island - if you have Ancestral Recall, indirectly gives +3 adventures. not useful in S&S
    √X of Clubs - +3 PVP fights
    √1952 Mickey Mantle - 10k autosell
    
    Unknown:
    X of Diamonds - X * 100 meat - never? maybe ~550 meat on average? even in run... eh...
    X of Swords - technically optimal (saw one that gave two SBIPs and an antique machete) but random
    
    
    one card/day/card limit when cheating
    */
    
    boolean in_run = __misc_state["in run"];
    
    DOECSummon [int] summons;
    
    if (in_run && (__misc_state_int["fat loot tokens needed"] > 0 || (!in_ronin() && __misc_state_int["hero keys missing"] > 0)))
        summons.listAppend(DOECSummonMake("XVI - The Tower", "Daily Dungeon key."));
    
    
    if (my_path_id() != PATH_SLOW_AND_STEADY)
    {
        if ($skill[ancestral recall].skill_is_usable())
        {
            summons.listAppend(DOECSummonMake(listMake("Ancestral Recall", "Island"), "+3 adventures via ancestral recall."));
        }
        else if (!in_run)
        {
            summons.listAppend(DOECSummonMake("Ancestral Recall", "Gives +adventure summoning skill."));
        }
    }
    
    if (hippy_stone_broken())
        summons.listAppend(DOECSummonMake("X of Clubs", "+3 PVP fights."));
    
    if (in_run)
        summons.listAppend(DOECSummonMake("X - The Wheel of Fortune", "+100% item for 20 turns."));
    
    if (in_run && __misc_state["need to level"] && my_path_id() != PATH_THE_SOURCE)
    {
        string card_name = "Cardiff";
        if (my_primestat() == $stat[muscle])
            card_name = "XXI - The World";
        else if (my_primestat() == $stat[mysticality])
            card_name = "III - The Empress";
        else if (my_primestat() == $stat[moxie])
            card_name = "VI - The Lovers";
        
        summons.listAppend(DOECSummonMake(card_name, "+" + (500 * (1.0 + numeric_modifier(my_primestat().to_string() + " Experience Percent") / 100.0)).floor() + " mainstat."));
    }
    
    if (in_run && !__quest_state["Level 8"].state_boolean["Past mine"])
    {
        int missing_ore = MAX(0, 3 - __quest_state["Level 8"].state_string["ore needed"].to_item().available_amount());
        if (missing_ore > 0)
            summons.listAppend(DOECSummonMake("Mine", "One of every ore."));
    }
    
    if (!in_run && $item[knife].available_amount() == 0)
        summons.listAppend(DOECSummonMake("Knife", "+50% meat farming weapon."));
    
    if (in_run && $items[lead pipe,rope,wrench,candlestick,knife,revolver].items_missing().count() == 6)
    {
        /*
        Important point on the +stat equipment - there's another card that gives 500 mainstat. So, if that's all you're using the weapon for, you'd need to use it for over 250 fights in a day to be worthwhile.
        You can, of course, summon both... but in that situation, there's probably a better summon instead?
        
        √lead pipe - 1h club. +100% muscle, +50 HP, vanishes at rollover.
            Hmm... for muscle classes that don't have familiars? Or seal clubbers?
            +100% mainstat is a lot...
        √rope - 1h whip. +2 muscle/fight, +10 familiar weight, vanishes at rollover.
            Muscle classes. Any class that has a runaway familiar. Maybe just any class that has a familiar?
         
        √wrench - 1h utensil. +100% spell damage, +50 MP.
            For myst classes that don't need stats.
        √candlestick - 1h wand. +2 myst/fight, +100% myst, vanishes at rollover.
            For myst classes that need stats.
        
        √knife - 1h knife. +50% meat, +100% moxie, vanishes at rollover.
            For moxie classes. Even then...
            +100% mainstat is a lot...
        √revolver -  1h pistol. +50% init, +2 moxie/fight, vanishes at rollover.
            For moxie classes that need stats? Ehh...
        */
        DOECSummon [int] weapon_choices;
        
        
        if (my_primestat() == $stat[muscle])
        {
            if (!($skill[summon smithsness].skill_is_usable() && my_class() == $class[seal clubber]))
                weapon_choices.listAppend(DOECSummonMake("Lead pipe", "+100% muscle, +HP club."));
            //Rope is mentioned elsewhere
        }
        if (my_primestat() == $stat[mysticality] && !$skill[summon smithsness].skill_is_usable())
        {
            weapon_choices.listAppend(DOECSummonMake("Wrench", "+100% spell damage weapon.")); //this will do more damage on average than the candlestick, so it's more worthwhile? (compare capped spells versus scaling spells - spell damage affects saucestorm, +myst doesnt')
            //Is the candlestick worth summoning?
            if (__misc_state["need to level"])
                weapon_choices.listAppend(DOECSummonMake("Candlestick", "+100% myst, +2 myst/fight weapon. (wrench may be better)"));
        }
        if (my_primestat() == $stat[moxie] && !$skill[summon smithsness].skill_is_usable())
        {
            if ($skill[tricky knifework].skill_is_usable())
                weapon_choices.listAppend(DOECSummonMake("Knife", "+50% meat, +100% moxie knife."));
            if (__misc_state["need to level"] && !$skill[tricky knifework].skill_is_usable())
                weapon_choices.listAppend(DOECSummonMake("Revolver", "+50% init, +2 moxie/fight ranged weapon.")); //ignored for DBs, because of the stat issue mentioned above
        }
        if (!__misc_state["familiars temporarily blocked"])
        {
            //is this worthwhile for non-muscle classes without free runaway familiars?
            string line;
            line = "+10 familiar weight";
            if (my_primestat() == $stat[muscle] && __misc_state["need to level"])
                line += ", +2 muscle/fight";
            line += " weapon.";
            weapon_choices.listAppend(DOECSummonMake("Rope", line));
        }
        
        foreach key, summon in weapon_choices
        {
            //FIXME combine?
            summons.listAppend(summon);
        }
    }
    
    summons.listAppend(DOECSummonMake("1952 Mickey Mantle", "Autosells for 10k."));
    
    
    if (in_run)
    {
        int wool_needed = 0;
        if (!$location[the hidden park].locationAvailable())
        {
            wool_needed += 1;
            if ($item[the nostril of the serpent].available_amount() == 0)
                wool_needed += 1;
        }
		if ($item[stone wool].available_amount() < wool_needed)
        {
            summons.listAppend(DOECSummonMake("Sheep", "3 stone wool."));
        }
        else if ($item[stone wool].available_amount() - wool_needed <= 0 && !get_property_ascension("lastTempleAdventures") && my_path_id() != PATH_SLOW_AND_STEADY)
        {
            summons.listAppend(DOECSummonMake("Sheep", "Stone wool for +3 adventures via temple."));
        }
    }
    
    if (!in_run)
    {
        int missing_emperor_pieces = missing_outfit_components("The Emperor's New Clothes").count();
        if (missing_emperor_pieces > $item[The Emperor's dry cleaning].available_amount())
            summons.listAppend(DOECSummonMake("IV - The Emperor", "The Emperor's New Clothes outfit."));
    
        summons.listAppend(DOECSummonMake("Gift card", "Sell to the needy."));
        
        string [int][int] tooltip_table;
        tooltip_table.listAppend(listMake("II - The High Priestess", "Hippy"));
        tooltip_table.listAppend(listMake("V - The Hierophant", "Dude"));
        tooltip_table.listAppend(listMake("VII - The Chariot", "Construct"));
        tooltip_table.listAppend(listMake("XII - The Hanged Man", "Orc"));
        tooltip_table.listAppend(listMake("XIII - Death", "Undead"));
        tooltip_table.listAppend(listMake("XIV - Temperance", "Hobo"));
        tooltip_table.listAppend(listMake("XV - The Devil", "Demon"));
        tooltip_table.listAppend(listMake("XVII - The Star", "Constellation"));
        tooltip_table.listAppend(listMake("XVIII - The Moon", "Horror"));
        tooltip_table.listAppend(listMake("The Hive", "Bug"));
        tooltip_table.listAppend(listMake("Goblin Sapper", "Goblin"));
        tooltip_table.listAppend(listMake("Fire Elemental", "Elemental"));
        tooltip_table.listAppend(listMake("Unstable Portal", "Weird"));
        tooltip_table.listAppend(listMake("Werewolf", "Beast"));
        tooltip_table.listAppend(listMake("Go Fish", "Fish"));
        tooltip_table.listAppend(listMake("Plantable Greeting Card", "Plant"));
        tooltip_table.listAppend(listMake("Pirate Birthday Card", "Pirate"));
        tooltip_table.listAppend(listMake("Christmas Card", "Elf"));
        tooltip_table.listAppend(listMake("Suit Warehouse Discount Card", "Penguin"));
        tooltip_table.listAppend(listMake("Slimer Trading Card", "Slime"));
        tooltip_table.listAppend(listMake("Aquarius Horoscope", "Mer-Kin"));
        tooltip_table.listAppend(listMake("Hunky Fireman Card", "Humanoid"));

        buffer tooltip_text;
        tooltip_text.append(HTMLGenerateTagWrap("div", "Monster Cards", mapMake("class", "r_bold r_centre", "style", "padding-bottom:0.25em;")));
        tooltip_text.append(HTMLGenerateSimpleTableLines(tooltip_table));
        
        string title = HTMLGenerateSpanOfClass(HTMLGenerateSpanOfClass(tooltip_text, "r_tooltip_inner_class") + "Monster card", "r_tooltip_outer_class");
        summons.listAppend(DOECSummonMake(title, "Past factoids."));
    }
    
    if (in_run && !__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "")
    {
        stat stat_race_type = __quest_state["Level 13"].state_string["Stat race type"].to_stat();
        string card_name = "Joker";
        effect relevant_effect;
        if (stat_race_type == $stat[muscle])
        {
            card_name = "XI - Strength";
            relevant_effect = lookupEffect("1912");
        }
        else if (stat_race_type == $stat[mysticality])
        {
            card_name = "I - The Magician";
            relevant_effect = lookupEffect("1911");
        }
        else if (stat_race_type == $stat[moxie])
        {
            card_name = "0 - The Fool";
            relevant_effect = lookupEffect("1910");
        }
        if (relevant_effect.have_effect() == 0)
            summons.listAppend(DOECSummonMake(card_name, "+200% " + stat_race_type.to_lower_case() + " for lair races. (marginal)"));
    }
    if (!in_run)
    {
        if (!haveAtLeastXOfItemEverywhere($item[talking spade], 1))
            summons.listAppend(DOECSummonMake("X of Spades", "Solve spade puzzle."));
        if (card_summons_left >= 5)
            summons.listAppend(DOECSummonMake("Random card", pluralise(card_summons_left, "luck of the draw", "lucks of the draw") + "."));
    }
    
    string [int][int] card_table;
    if (card_summons_left >= 5)
    {
        foreach key, summon in summons
        {
            card_table.listAppend(listMake(summon.cards.listJoinComponents(" / "), summon.reason));
        }
    }
    
    if ((card_table.count() > 0 || card_summons_left < 5) && card_summons_left > 0)
    {
        string title;
		string [int] description;
        
        if (card_summons_left >= 5)
        {
            title = pluralise(card_summons_left / 5, "card drawable", "cards drawable");
        }
        else
        {
            title = pluralise(card_summons_left, "random card summon", "random card summons");
            string line = "Luck of the draw.";
            if (in_run)
                line += " (may cost turns)";
            description.listAppend(line);
        }
        
        if (card_table.count() > 0)
            description.listAppend(HTMLGenerateSimpleTableLines(card_table));
		resource_entries.listAppend(ChecklistEntryMake("__item deck of every card", "inventory.php?which=3", ChecklistSubentryMake(title, "", description), 1));
    }
}