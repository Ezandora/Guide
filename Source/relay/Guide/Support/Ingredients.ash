
/*
Discovery - get_ingredients() takes up to 5.8ms per call, scaling to inventory size. Fixing the code in mafia might be possible, but it's old and looks complicated.
This implementation is not 1:1 compatible, as it doesn't take into account your current status, but we don't generally need that information(?).
*/

//Relevant prototype:
//int [item] get_ingredients_fast(item it)


static
{
    int [item][item] __item_ingredients;
    boolean [item] __item_is_purchasable_from_a_store;
}



boolean parseDatafileItem(int [item] out, string item_name)
{
    if (item_name == "") return false;
    
    item it = item_name.to_item();
    if (it != $item[none])
    {
        out[it] += 1;
    }
    else if (item_name.contains_text("("))
    {
        //Do complicated parsing.
        //NOTE: "CRIMBCO Employee Handbook (chapter 1)" and "snow berries (7)" are both valid entries that mean different things.
        string [int][int] matches = item_name.group_string("(.*?) \\(([0-9]*)\\)");
        if (matches[0].count() == 3)
        {
            it = matches[0][1].to_item();
            int amount = matches[0][2].to_int();
            if (it != $item[none] && amount > 0)
            {
                out[it] += amount;
            }
        }
    }
    return true;
}


Record ConcoctionMapEntry
{
    //Only way I know how to parse this file with file_to_map. string [int] won't work, string [string] won't...
    string craft_type;
    string mixing_item_1;
    string mixing_item_2;
    string mixing_item_3;
    string mixing_item_4;
    string mixing_item_5;
    string mixing_item_6;
    string mixing_item_7;
    string mixing_item_8;
    string mixing_item_9;
    string mixing_item_10;
    string mixing_item_11;
    string mixing_item_12;
    string mixing_item_13;
    string mixing_item_14;
    string mixing_item_15;
    string mixing_item_16;
    string mixing_item_17;
    string mixing_item_18;
};

void parseConcoction(int [item] ingredients, ConcoctionMapEntry c)
{
    //If this ever shows up somewhere, please understand, it's not my fault file_to_map works this way.
    if (!parseDatafileItem(ingredients, c.mixing_item_1))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_2))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_3))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_4))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_5))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_6))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_7))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_8))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_9))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_10))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_11))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_12))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_13))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_14))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_15))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_16))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_17))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_18))
        return;
}

void initialiseItemIngredients()
{
    if (__item_ingredients.count() > 0) return;
    
    //Parse concoctions:
    //Highest observed so far: 17.
    if (true)
    {
        string [string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string] concoctions_map_2;
        file_to_map("data/concoctions.txt", concoctions_map_2);
        foreach crafting_thing, crafting_type, mixing_item_1, mixing_item_2, mixing_item_3, mixing_item_4, mixing_item_5, mixing_item_6, mixing_item_7, mixing_item_8, mixing_item_9, mixing_item_10, mixing_item_11, mixing_item_12, mixing_item_13, mixing_item_14, mixing_item_15, mixing_item_16, mixing_item_17, mixing_item_18 in concoctions_map_2
        {
            if (crafting_type == "SUSHI" || crafting_type == "VYKEA") continue; //not really items
            if (crafting_type == "CLIPART") continue; //bucket of wine is not made of three turtle totems
            item it = crafting_thing.to_item();
            if (it == $item[none])
            {
                int [item] item_results;
                parseDatafileItem(item_results, crafting_thing);
                if (item_results.count() == 0)
                {
                    //print_html("Unknown crafting_thing " + crafting_thing);
                    continue;
                }
                foreach it2 in item_results
                    it = it2;
            }
            if (crafting_type.contains_text("ROW"))
                __item_is_purchasable_from_a_store[it] = true;
            if (__item_ingredients contains it) continue; //mafia uses first defined entry
            
            int [item] ingredients;
            //Create map entry:
            ConcoctionMapEntry c;
            c.craft_type = crafting_type;
            c.mixing_item_1 = mixing_item_1;
            c.mixing_item_2 = mixing_item_2;
            c.mixing_item_3 = mixing_item_3;
            c.mixing_item_4 = mixing_item_4;
            c.mixing_item_5 = mixing_item_5;
            c.mixing_item_6 = mixing_item_6;
            c.mixing_item_7 = mixing_item_7;
            c.mixing_item_8 = mixing_item_8;
            c.mixing_item_9 = mixing_item_9;
            c.mixing_item_10 = mixing_item_10;
            c.mixing_item_11 = mixing_item_11;
            c.mixing_item_12 = mixing_item_12;
            c.mixing_item_13 = mixing_item_13;
            c.mixing_item_14 = mixing_item_14;
            c.mixing_item_15 = mixing_item_15;
            c.mixing_item_16 = mixing_item_16;
            c.mixing_item_17 = mixing_item_17;
            c.mixing_item_18 = mixing_item_18;
            
            parseConcoction(ingredients, c);
            
            if (ingredients.count() > 0)
                __item_ingredients[it] = ingredients;
        }
    }
    else
    {
        //Not compatible.
        //Concoction manager seems to read the first entry, not the second. file_to_map reads the second. Example: spooky wad.
        //Or maybe it's just random which the concoction manager uses? Example: bloody beer vs. spooky wad. Or it picks the one we can make...?
        ConcoctionMapEntry [string] concoctions_map;
        file_to_map("data/concoctions.txt", concoctions_map);
        foreach crafting_thing in concoctions_map
        {
            ConcoctionMapEntry c = concoctions_map[crafting_thing];
            item it = crafting_thing.to_item();
            if (it == $item[none])
                continue;
            
            int [item] ingredients;
            
            parseConcoction(ingredients, c);
            
            if (__item_ingredients contains it) continue; //mafia uses first defined entry
            if (ingredients.count() > 0)
                __item_ingredients[it] = ingredients;
        }
    }
    //Parse coinmasters:
    
    /*Record CoinmastersMapEntry
    {
        string buy_or_sell_type;
        int amount;
        item it;
        string row_id;
    };
    CoinmastersMapEntry [string] coinmasters_map;*/
    string [string,string,int,string] coinmasters_map;
    file_to_map("data/coinmasters.txt", coinmasters_map);
    //print_html("coinmasters_map = " + coinmasters_map.to_json());
    foreach master_name, type, amount, item_string in coinmasters_map
    {
        //FIXME track if coinmaster is accessible?
        //print_html(master_name + ", " + type + ", " + amount + ", " + item_string);
        if (type != "buy") continue;
        coinmaster c = master_name.to_coinmaster();
        if (c == $coinmaster[none])
        {
            //Hmm....
            //print_html(master_name + " is not a coinmaster");
            continue;
        }
        if (c.item == $item[none]) //bat-fabricator
            continue;
        item it = item_string.to_item();
        if (it == $item[none])
        {
            //peppermint tailings (10) at the moment
            //FIXME write this
            continue;
        }
        
        if (it == $item[none])
            continue;
        
        __item_is_purchasable_from_a_store[it] = true;
        if (__item_ingredients contains it) continue;
        
        int [item] ingredients;
        ingredients[c.item] = amount;
        __item_ingredients[it] = ingredients;
    }
    
}


int [item] get_ingredients_fast(item it)
{
    //return it.get_ingredients();
    if (__item_ingredients.count() == 0)
        initialiseItemIngredients();
    if (!(__item_ingredients contains it))
    {
        //This is six milliseconds per call, but only if the item has an ingredient(?), so be wary:
        int [item] ground_truth = it.get_ingredients();
        if (ground_truth.count() > 0) //We could cache it if it's empty, except sometimes that changes.
            __item_ingredients[it] = ground_truth;
    }
    return __item_ingredients[it];
}

boolean item_is_purchasable_from_a_store(item it)
{
    return __item_is_purchasable_from_a_store[it];
}

boolean item_cannot_be_asdon_martined_because_it_was_purchased_from_a_store(item it)
{
	if ($items[wasabi pocky,tobiko pocky,natto pocky,wasabi-infused sake,tobiko-infused sake,natto-infused sake] contains it) return false;
	return it.item_is_purchasable_from_a_store();
}

void testItemIngredients()
{
    initialiseItemIngredients();
    print_html(__item_ingredients.count() + " ingredients known.");
    foreach it in $items[]
    {
        int [item] ground_truth_ingredients = it.get_ingredients();
        int [item] our_ingredients = get_ingredients_fast(it);
        if (ground_truth_ingredients.count() == 0 && our_ingredients.count() == 0) continue;
        
        boolean passes = true;
        if (ground_truth_ingredients.count() != our_ingredients.count())
        {
            passes = false;
            if (ground_truth_ingredients.count() == 0 && our_ingredients.count() > 0) //probably just a coinmaster
                continue;
        }
        else
        {
            foreach it2, amount in ground_truth_ingredients
            {
                if (our_ingredients[it2] != amount)
                {
                    passes = false;
                    break;
                }
            }
        }
        if (!passes)
        {
            print_html(it + ": " + ground_truth_ingredients.to_json() + " vs " + our_ingredients.to_json());
        }
    }
}

/*void main()
{
    testItemIngredients();
}*/
