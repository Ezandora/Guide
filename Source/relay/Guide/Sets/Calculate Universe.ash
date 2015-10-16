import "relay/Guide/Support/Numberology.ash"
void SCalculateUniverseGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!lookupSkill("Calculate the Universe").have_skill())
        return;
    if (get_property_boolean("_universeCalculated"))
        return;
    
    string [int] description;
    
    string [int] useful_digits_and_their_reasons;
    if (__setting_enable_outputting_all_numberology_options)
    {
        for digit from 0 to 99
        {
            if (!($ints[24,25,26,28,29,31,32,39,41,42,46,52,53,54,55,56,59,60,61,62,64,65,67,72,73,74,76,79,80,81,82,84,85,86,91,92,94,95,96] contains digit)) //Try Again FIXME all
                useful_digits_and_their_reasons[digit] = "";
        }
    }
    //Set up useful digits:
    
    if (my_path_id() != PATH_SLOW_AND_STEADY)
        useful_digits_and_their_reasons[69] = "+3 adventures";
    if (hippy_stone_broken())
        useful_digits_and_their_reasons[37] = "+3 fights";
    if (__misc_state["in run"])
    {
        if (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues") && !__quest_state["Level 12"].finished)
            useful_digits_and_their_reasons[51] = "War frat orc to YR";
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
    table.listAppend(listMake("#", "For"));
    string [int][int] mappings;
    
    foreach digit, reason in useful_digits_and_their_reasons
    {
        string what_to_do;
        if (digit_inputs_to_outputs contains digit)
        {
            if (__setting_enable_outputting_all_numberology_options)
                mappings.listAppend(listMake(digit_inputs_to_outputs[digit].to_string(), digit.to_string()));
                //mappings.listAppend(digit_inputs_to_outputs[digit] + " -> " + digit);
            what_to_do = digit_inputs_to_outputs[digit];
        }
        else if (digit_inputs_to_deltas contains digit)
        {
            what_to_do = "Wait " + digit_inputs_to_deltas[digit] + " adv";
        }
        else
            what_to_do = "Unknown result to end in " + digit;
        if (reason != "")
            table.listAppend(listMake(what_to_do, reason));
    }
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
        tooltip_text.append(HTMLGenerateTagWrap("div", "Values to input for " + __html_right_arrow_character + " output", mapMake("class", "r_bold r_centre", "style", "padding-bottom:0.25em;")));
        tooltip_text.append(HTMLGenerateSimpleTableLines(mappings_final));
        
        string line = HTMLGenerateSpanOfClass(HTMLGenerateSpanOfClass(tooltip_text, "r_tooltip_inner_class") + "Full table", "r_tooltip_outer_class");
        //description.listAppend(line);
        table.listAppend(listMake(line));
    }
    if (table.count() > 1)
        description.listAppend("Cast skill, enter the right number: (this changes, and is still being spaded)|*" + HTMLGenerateSimpleTableLines(table));
    else
        description.listAppend("Cast skill, enter the right number.");
    resource_entries.listAppend(ChecklistEntryMake("__skill Calculate the Universe", "skillz.php", ChecklistSubentryMake("Calculate the Universe", "", description), 8));
}