
static
{
    boolean [item] __simple_candy = $items[1702, 1962, 4341, 913, 1652, 2942, 3455, 3449, 3454, 3453, 3452, 3451, 4152, 1501, 5455, 5478, 5476, 5477, 1344, 5188, 4340, 1161, 912, 4342, 5454, 2941, 1346, 4192, 1494, 5456, 617, 3496, 2734, 933, 908, 3450, 1783, 2088, 2576, 907, 1767, 906, 911, 540, 263, 909, 905, 5180, 2309, 300, 2307, 298, 1163, 2306, 299, 2305, 297, 2304, 2308, 5892, 6792, 5435, 7677, 7785];
    boolean [item] __complex_candy = lookupItems("5495,5496,5494,5458,5421,4851,2197,1382,4334,4333,5424,3269,5422,921,5425,5423,3091,2955,5416,5419,5418,5417,5420,5381,5319,5400,4330,4332,5406,5405,4818,5402,5318,5384,4331,5320,5382,5398,5401,5397,5317,5385,5321,5383,3290,3760,2193,5413,5459,5483,3584,5395,5396,5482,4256,5484,2943,4329,3054,4758,4163,4466,4464,4465,4462,4467,4463,4623,5157,4395,4394,4393,4518,5189,4151,5023,3428,3423,3424,5457,3425,5480,5474,5479,5473,5481,5475,4164,3631,4853,5414,5415,3046,5345,1345,5103,2220,4746,4389,3125,4744,4273,3422,1999,3426,4181,4180,4176,4183,4179,4191,4182,4178,4745,5526,6835,6852,6833,6834,6836,7499,7915,8257,7914,6837,8151,3124,8149,8154,7919,6840,5736,6831,7917,8150,6404,6841,6904,6903,7918,7710,6399,9146,8537,6405,6843,7474,6172,9252,5913];");
}


item [int][int] calculateSweetSynthesisCandyCombinations(int tier, int subid)
{
    item [int][int] result;
    boolean [item] candy_1;
    boolean [item] candy_2;
    
    if (tier == 1)
    {
    	candy_1 = __simple_candy;
    	candy_2 = __simple_candy;
    }
    else if (tier == 2)
    {
    	candy_1 = __simple_candy;
    	candy_2 = __complex_candy;
    }
    else if (tier == 3)
    {
    	candy_1 = __complex_candy;
    	candy_2 = __complex_candy;
    }
    foreach item_1 in candy_1
    {
        int item_1_id = item_1.to_int();
        
        foreach item_2 in candy_2
        {
            int item_2_id = item_2.to_int();
            if ((item_1_id + item_2_id) % 5 != (subid - 1))
                continue;
            result.listAppend(listMake(item_1, item_2));
        }
    }
    return result;
}

int synthesis_price(item it)
{
    if (!it.tradeable)
        return 999999999;
    int price = it.historical_price();
    if (price <= 0)
        return 999999999;
    return price;
}

static
{
    string [effect] __sweet_synthesis_buff_descriptions;
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Hot")] = "+9 hot res";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Cold")] = "+9 cold res";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Pungent")] = "+9 stench res";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Scary")] = "+9 spooky res";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Greasy")] = "+9 sleaze res";
    
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Strong")] = "+300% muscle";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Smart")] = "+300% myst";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Cool")] = "+300% moxie";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Hardy")] = "+300% max HP";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Energy")] = "+300% max MP";
    
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Greed")] = "+300% meat";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Collection")] = "+150% item";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Movement")] = "+50% muscle gain";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Learning")] = "+50% myst gain";
    __sweet_synthesis_buff_descriptions[lookupEffect("Synthesis: Style")] = "+50% moxie gain";
    
    int [effect] __sweet_synthesis_buff_tiers;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Hot")] = 1;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Cold")] = 1;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Pungent")] = 1;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Scary")] = 1;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Greasy")] = 1;
    
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Strong")] = 2;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Smart")] = 2;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Cool")] = 2;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Hardy")] = 2;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Energy")] = 2;
    
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Greed")] = 3;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Collection")] = 3;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Movement")] = 3;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Learning")] = 3;
    __sweet_synthesis_buff_tiers[lookupEffect("Synthesis: Style")] = 3;
    
    int [effect] __sweet_synthesis_buff_subid;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Hot")] = 1;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Cold")] = 2;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Pungent")] = 3;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Scary")] = 4;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Greasy")] = 5;
    
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Strong")] = 1;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Smart")] = 2;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Cool")] = 3;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Hardy")] = 4;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Energy")] = 5;
    
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Greed")] = 1;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Collection")] = 2;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Movement")] = 3;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Learning")] = 4;
    __sweet_synthesis_buff_subid[lookupEffect("Synthesis: Style")] = 5;
    
    effect [int] __sweet_synthesis_buff_output_order;
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Greed"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Collection"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Movement"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Learning"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Style"));
    
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Strong"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Smart"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Cool"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Hardy"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Energy"));
    
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Hot"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Cold"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Pungent"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Scary"));
    __sweet_synthesis_buff_output_order.listAppend(lookupEffect("Synthesis: Greasy"));
}

RegisterResourceGenerationFunction("SSweetSynthesisGenerateResource");
void SSweetSynthesisGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!lookupSkill("Sweet Synthesis").skill_is_usable())
        return;
    if (availableSpleen() == 0)
        return;
    
    //Calculate potential combinations from inventory, if we're in-run.
    //If we're in aftercore, suggest a cheap candy for each buff. Breath mints are forever, right?
    
    
    //We only display a handful of combinations in-run, because honestly there's no room.
    int setting_maximum_display_limit = 2;
    
    
    string [int] description;
    
    string [int][int] table;
    //table.listAppend(listMake(HTMLGenerateSpanOfClass("Effect", "r_bold"), HTMLGenerateSpanOfClass("Candies", "r_bold")));
    
    int approximate_line_count = 0;
    string [int] table_lines;
    foreach key, e in __sweet_synthesis_buff_output_order
    {
        if (e == $effect[none])
            continue;
        item [int][int] combinations = calculateSweetSynthesisCandyCombinations(__sweet_synthesis_buff_tiers[e], __sweet_synthesis_buff_subid[e]);
        
        //If we're in aftercore, show the cheapest combination.
        //If we're in ronin, show all combinations we have components for.
        item [int][int] final_combinations;
        //final_combinations = combinations;
        if (in_ronin())
        {
            //All we have enough for:
            //int [int][item] combinations_seen;
            
            sort combinations by (value[0].synthesis_price() + value[1].synthesis_price()); //fast reject - we'll stop running once we reach the display limit
            
            boolean [string] combinations_seen_json;
            foreach key in combinations
            {
                if (final_combinations.count() >= setting_maximum_display_limit + 1)
                    break;
                item item_1 = combinations[key][0];
                item item_2 = combinations[key][1];
                int [item] combination_presence;
                combination_presence[item_1] += 1;
                combination_presence[item_2] += 1;
                //Use a JSON to discover if we've seen this combination before. Seems to be the fastest way to check if we've seen a map before?
                //It shouldn't be too slow... right? Right?
                string presence_json = combination_presence.to_json();
                boolean already_seen = (combinations_seen_json contains presence_json);
                //Have we seen this particular combination yet?
                //Lovely slow O(N^2) algorithm:
                /*foreach key in combinations_seen
                {
                    boolean identical = true;
                    foreach it, amount in combinations_seen[key]
                    {
                        if (combination_presence[it] != amount)
                        {
                            identical = false;
                            break;
                        }
                    }
                    if (identical)
                    {
                        already_seen = true;
                        break;
                    }
                }*/
                if (already_seen)
                {
                    continue;
                }
                
                if (item_1.available_amount() > 0 && item_2.available_amount() > 0 && !(item_1 == item_2 && item_1.available_amount() < 2))
                {
                    final_combinations.listAppend(listMake(item_1, item_2));
                    //combinations_seen[combinations_seen.count()] = combination_presence;
                    combinations_seen_json[presence_json] = true;
                }
            }
        }
        else
        {
            //Find cheapest:
            sort combinations by (value[0].synthesis_price() + value[1].synthesis_price());
            final_combinations.listAppend(combinations[0]);
        }
        if (final_combinations.count() > 0)
        {
            buffer line;
            foreach key in final_combinations
            {
                if (key >= setting_maximum_display_limit) //unrealistic to show that many
                {
                    line.append("<br>[...]");
                    break;
                }
                approximate_line_count += 1;
                if (line.length() != 0)
                    line.append("<br>");
                line.append(final_combinations[key][0]);
                line.append(" + ");
                line.append(final_combinations[key][1]);
            }
            table_lines.listAppend(HTMLGenerateSpanOfClass(__sweet_synthesis_buff_descriptions[e], "r_bold") + "<br>" + HTMLGenerateSpanOfStyle(line, "font-size:0.8em;color:#333333"));
            //table.listAppend(listMake(__sweet_synthesis_buff_descriptions[e], line));
        }
    }
    string [int] building_line;
    foreach key in table_lines
    {
        building_line.listAppend(table_lines[key]);
        if (key % 2 == 1)
        {
            table.listAppend(building_line);
            building_line = listMakeBlankString();
        }
    }
    if (building_line.count() > 0)
        table.listAppend(building_line);
    int estimated_margin = approximate_line_count * 1.2;
    //description.listAppend("Costs one spleen and two candies.");
    description.listAppend(HTMLGenerateSpanOfClass(HTMLGenerateTagWrap("span",HTMLGenerateSimpleTableLines(table, false), mapMake("class", "r_tooltip_inner_class", "style", "margin-top:-" + estimated_margin + "em;margin-left:-5em;")) + "Costs one spleen and two candies.", "r_tooltip_outer_class"));
    
    
    if (table.count() > 0)
        resource_entries.listAppend(ChecklistEntryMake("__skill Sweet Synthesis", "runskillz.php?action=Skillz&whichskill=166&targetplayer=" + my_id() + "&pwd=" + my_hash() + "&quantity=1", ChecklistSubentryMake("Sweet Synthesis Buff", "30 turns", description), 10));
}