static
{
	int [string] __moon_sign_id_lookup;
	void initialiseMoonSignIDLookup()
	{
		__moon_sign_id_lookup["Mongoose"] = 0;
		__moon_sign_id_lookup["Wallaby"] = 1;
		__moon_sign_id_lookup["Vole"] = 2;
		__moon_sign_id_lookup["Platypus"] = 3;
		__moon_sign_id_lookup["Opossum"] = 4;
		__moon_sign_id_lookup["Marmot"] = 5;
		__moon_sign_id_lookup["Wombat"] = 6;
		__moon_sign_id_lookup["Blender"] = 7;
		__moon_sign_id_lookup["Packrat"] = 8;
		__moon_sign_id_lookup["Bad Moon"] = 9; //?????
	}
	initialiseMoonSignIDLookup();
}

Record NumberologyCacheState
{
	int b;
	int c;
	int [int] input_to_outputs;
	int [int] input_deltas;
};

NumberologyCacheState NumberologyCacheStateMake()
{
	NumberologyCacheState r;
	r.b = -1;
	r.c = -1;
	return r;
}

static
{
	NumberologyCacheState __numberology_cache = NumberologyCacheStateMake();
}

void calculateNumberologyInputValuesForOutputs(boolean [int] desired_digits_in, int [int] digit_inputs_to_outputs_out, int [int] digit_inputs_to_deltas_out)
{
	boolean [int] desired_digits_left;
	foreach digit in desired_digits_in
	{
		desired_digits_left[digit] = true;
		digit_inputs_to_deltas_out[digit] = 99;
	}
	int mood_sign_id = __moon_sign_id_lookup[my_sign()];
	
	int lifetimes = my_ascensions() + 1;
	int b = my_spleen_use() + my_level();
	int c = ((my_ascensions() + 1) + mood_sign_id) * b + my_adventures();
	
	if (__numberology_cache.b == b && __numberology_cache.c == c)
	{
        //Cache lookup:
        foreach digit in desired_digits_in
        {
            if (__numberology_cache.input_to_outputs contains digit)
            {
                digit_inputs_to_outputs_out[digit] = __numberology_cache.input_to_outputs[digit];
                remove desired_digits_left[digit];
            }
            else if (__numberology_cache.input_deltas contains digit)
            {
                digit_inputs_to_deltas_out[digit] = __numberology_cache.input_deltas[digit];
                remove desired_digits_left[digit];
            }
        }
	}
	if (desired_digits_left.count() == 0)
		return;
    
	int last_x = -1;
    //Brute force method:
	for x from 0 to 99
	{
		int v = x * b + c;
		int last_two_digits = v % 100;
		if (desired_digits_left contains last_two_digits)
		{
			remove desired_digits_left[last_two_digits];
			remove digit_inputs_to_deltas_out[last_two_digits];
			digit_inputs_to_outputs_out[last_two_digits] = x;
			if (desired_digits_left.count() == 0)
			{
				last_x = x;
				break;
			}
		}
		foreach digit in desired_digits_left
		{
			int delta = digit - last_two_digits;
			if (delta < 0)
				digit_inputs_to_deltas_out[digit] = min(digit_inputs_to_deltas_out[digit], -delta);
		}
	}
    
    /*
    //Covered by loop above, I think
    foreach digit in digit_inputs_to_outputs_out
    {
        if (digit_inputs_to_deltas_out contains digit)
            remove digit_inputs_to_deltas_out[digit];
    }*/
	
	//Save cache:
	if (__numberology_cache.b != b || __numberology_cache.c != c)
		__numberology_cache = NumberologyCacheStateMake();
	__numberology_cache.b = b;
	__numberology_cache.c = c;
	foreach input, output in digit_inputs_to_outputs_out
		__numberology_cache.input_to_outputs[input] = output;
	foreach input, delta in digit_inputs_to_deltas_out
		__numberology_cache.input_deltas[input] = delta;
}


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