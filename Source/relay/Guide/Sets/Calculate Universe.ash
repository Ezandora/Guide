import "relay/Guide/Support/Numberology.ash"
void SCalculateUniverseGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!$skill[Calculate the Universe].skill_is_usable())
        return;
    int uses_remaining = 1;
    if (get_property_boolean("_universeCalculated"))
        return;
    if (true)
    {
        int universe_calculated = get_property_int("_universeCalculated");
        int limit = 1;
        int skill_number = get_property_int("skillLevel144");
        limit = max(skill_number, limit);
        if (in_ronin())
        {
            limit = min(limit, 3);
        }
        if (universe_calculated >= limit)
            return;
        uses_remaining = limit - universe_calculated;
    }
    
    string [int] description;
    
    string [int] useful_digits_and_their_reasons;
    if (__setting_enable_outputting_all_numberology_options)
    {
        for digit from 0 to 99
        {
            if (!($ints[24,25,26,28,29,31,32,39,41,42,46,52,53,54,55,56,59,60,61,62,64,65,67,72,73,74,76,79,80,81,82,84,85,86,91,92,94,95,96] contains digit)) //Try Again
                useful_digits_and_their_reasons[digit] = "";
        }
    }
    //Set up useful digits:
    if (my_path_id_legacy() != PATH_SLOW_AND_STEADY)
        useful_digits_and_their_reasons[69] = "+3 adventures";
    if (hippy_stone_broken())
        useful_digits_and_their_reasons[37] = "+3 fights";
    if (__misc_state["in run"])
    {
        if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues") && !__quest_state["Level 12"].finished)
            useful_digits_and_their_reasons[51] = "War frat orc to YR";
        useful_digits_and_their_reasons[14] = "1400 meat (autosell 14 moxie weeds)";
        
        int ice_cubes_needing_creation = $item[perfect ice cube].available_amount();
        if ($skill[Perfect Freeze].skill_is_usable() && !get_property_boolean("_perfectFreezeUsed"))
            ice_cubes_needing_creation += 1;
        if (ice_cubes_needing_creation > 0 && $items[bottle of rum,bottle of vodka,boxed wine,bottle of gin,bottle of whiskey,bottle of tequila].available_amount() < ice_cubes_needing_creation && __misc_state["can drink just about anything"])
        {
            //FIXME 18, 44, 75, and 99 are all valid for this - pick whichever we can summon now?
            useful_digits_and_their_reasons[99] = "base booze for perfect ice cube";
        }
        if (__quest_state["Level 5"].mafia_internal_step < 3 && $item[Knob Goblin Perfume].available_amount() == 0 && $effect[Knob Goblin Perfume].have_effect() == 0 && in_ronin()) //have_outfit_components("Knob Goblin Harem Girl Disguise")
        {
            useful_digits_and_their_reasons[9] = "knob goblin perfume for boss fight";
        }
    }
    if (my_level() < 13)
    {
        //making a guess here - 89 is 89 mainstat with bonus experience percent (seems logical with the limited data we have)
        float mainstat_gained = 89.0 * (1.0 + numeric_modifier(my_primestat() + " experience percent") / 100.0);
        useful_digits_and_their_reasons[89] = roundForOutput(mainstat_gained, 0) + " mainstats";
    }
    
    //useful_digits_and_their_reasons[44] = "is very bad to steal jobu's rum";
    
    //Run complicated calculation code:
    boolean [int] desired_digits;
    foreach digit in useful_digits_and_their_reasons
        desired_digits[digit] = true;
    int [int] digit_inputs_to_outputs;
    int [int] digit_inputs_to_deltas;
    calculateNumberologyInputValuesForOutputs(desired_digits, digit_inputs_to_outputs, digit_inputs_to_deltas);
    
    string [int][int] table;
    table.listAppend(listMake(HTMLGenerateSpanOfClass("Enter", "r_bold"), HTMLGenerateSpanOfClass("For", "r_bold")));
    string [int][int] mappings;
    
    foreach digit, reason in useful_digits_and_their_reasons
    {
        string what_to_do;
        if (digit_inputs_to_outputs contains digit)
        {
            if (__setting_enable_outputting_all_numberology_options)
                mappings.listAppend(listMake(digit_inputs_to_outputs[digit].to_string(), digit.to_string()));
                //mappings.listAppend(digit_inputs_to_outputs[digit] + " -> " + digit);
            what_to_do = digit_inputs_to_outputs[digit].to_string();// + HTMLGenerateSpanFont(" (" + digit + ")", "gray", "0.9em");
        }
        else if (digit_inputs_to_deltas contains digit)
        {
            what_to_do = "Wait " + digit_inputs_to_deltas[digit] + " adv";
        }
        else
            what_to_do = "Unknown result to end in " + digit;
        if (reason != "")
        {
            //table.listAppend(listMake(what_to_do, reason));
            table.listAppend(listMake(what_to_do, reason + HTMLGenerateSpanFont(" (" + digit + ")", "gray", "0.9em")));
        }
    }
    
    string table_description;
    if (table.count() > 0)
        table_description += "|*" + HTMLGenerateSimpleTableLines(table);
    if (mappings.count() > 0)
    {
        //FIXME full description?
        string [int][int] mappings_final;
        //Compress mappings:
        mappings_final[0] = listMakeBlankString();
        foreach key in mappings
        {
            string [int] mapping = mappings[key];
            string [int] line = listMake(" ", mapping[0], __html_right_arrow_character, mapping[1]);
            
            if (mappings_final[mappings_final.count() - 1].count() >= 12)
                mappings_final.listAppend(listMakeBlankString());
            mappings_final[mappings_final.count() - 1].listAppendList(line);
        }
        
        
        buffer tooltip_text;
        tooltip_text.HTMLAppendTagWrap("div", "Values to input for " + __html_right_arrow_character + " output", mapMake("class", "r_bold r_centre", "style", "padding-bottom:0.25em;"));
        tooltip_text.append(HTMLGenerateSimpleTableLines(mappings_final));
        
        string line = HTMLGenerateSpanOfClass(HTMLGenerateSpanOfClass(tooltip_text, "r_tooltip_inner_class") + "Full table", "r_tooltip_outer_class");
        //we can't do full-width table entries because of colspan and display:table, so mimic it:
        //description.listAppend(line);
        //table.listAppend(listMake(line));
        if (table_description != "")
            table_description += "<hr>";
        table_description += line;
    }
    if (table_description != "")
        description.listAppend("Cast skill, enter the right number: (this changes)" + table_description);
    else
        description.listAppend("Cast skill, enter the right number.");
    
    /*if (table.count() > 1)
        description.listAppend("Cast skill, enter the right number: (this changes, and is still being spaded)|*" + HTMLGenerateSimpleTableLines(table));
    else
        description.listAppend("Cast skill, enter the right number.");*/
    string title = "Calculate the Universe";
    if (uses_remaining > 1)
        title = pluralise(uses_remaining, "Calculate the Universe", "Calculate the Universes");
    resource_entries.listAppend(ChecklistEntryMake(233, "__skill Calculate the Universe", "skillz.php", ChecklistSubentryMake(title, "", description), 0));
}
