static
{
	int [string] __moon_sign_id_lookup;
	void initialiseMoonSignIDLookup()
	{
        __moon_sign_id_lookup[""] = 0;
        __moon_sign_id_lookup["None"] = 0;
		__moon_sign_id_lookup["Mongoose"] = 1;
		__moon_sign_id_lookup["Wallaby"] = 2;
		__moon_sign_id_lookup["Vole"] = 3;
		__moon_sign_id_lookup["Platypus"] = 4;
		__moon_sign_id_lookup["Opossum"] = 5;
		__moon_sign_id_lookup["Marmot"] = 6;
		__moon_sign_id_lookup["Wombat"] = 7;
		__moon_sign_id_lookup["Blender"] = 8;
		__moon_sign_id_lookup["Packrat"] = 9;
		__moon_sign_id_lookup["Bad Moon"] = 10; //confirmed
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
    if (!(__moon_sign_id_lookup contains my_sign())) //not computable
        return;
    
	boolean [int] desired_digits_left;
	foreach digit in desired_digits_in
	{
		desired_digits_left[digit] = true;
		digit_inputs_to_deltas_out[digit] = 99;
	}
	int mood_sign_id = __moon_sign_id_lookup[my_sign()];
	
	int b = my_spleen_use() + my_level();
	int c = (my_ascensions() + mood_sign_id) * b + my_adventures();
	
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
			if (delta <= 0)
				digit_inputs_to_deltas_out[digit] = min(digit_inputs_to_deltas_out[digit], -delta);
			else
			{
				delta = digit - (last_two_digits + 100);
				if (delta <= 0)
                    digit_inputs_to_deltas_out[digit] = min(digit_inputs_to_deltas_out[digit], -delta);
			}
		}
	}
	
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

