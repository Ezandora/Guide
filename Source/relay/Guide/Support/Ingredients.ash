
/*
Discovery - get_ingredients() takes up to 5.8ms per call, scaling to inventory size. Fixing the code in mafia might be possible, but it's old and looks complicated.
This implementation is not 1:1 compatible, as it doesn't take into account your current status, but we don't generally need that information(?).
*/

//Relevant prototype:
//int [item] get_ingredients_fast(item it)
import "relay/Guide/Support/Strings.ash";

Record Recipe
{
	item creating_item;
	string type;
	int [item] source_items;
	
	Coinmaster source_coinmaster;
	
	string coinmaster_row_id;
};

static
{
	Recipe [item][int] __item_recipes;
	
    boolean [item] __item_is_purchasable_from_a_store;
    boolean [item] __items_that_craft_food;
}

Recipe [int] recipes_for_item(item it)
{
	return __item_recipes[it];
}

Recipe recipe_for_item(item it)
{
	if (__item_recipes[it].count() == 0)
	{
		Recipe blank;
        return blank;
	}
	return __item_recipes[it][0];
}

int [item] get_ingredients_fast(item it)
{
	Recipe [int] recipes = __item_recipes[it];
	if (recipes.count() == 0)
	{
		//use get_ingredient?
        //mafia appears to have various items that return get_ingredients but do not show up in the datafiles
        int [item] mafia_response = it.get_ingredients();
        return mafia_response;
	}
	return recipes[0].source_items;
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



//Initialisation code, ignore:
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
        //optional space between the item name and parenthesis because the CRIMBO12 items (BittyCar MeatCar) have no space there
        string [int][int] matches = item_name.group_string("(.*?)[ ]*\\(([0-9]*)\\)");
        if (matches[0].count() == 3)
        {
            it = matches[0][1].to_item();
            if (it == $item[none]) return false;
            int amount = matches[0][2].to_int();
            if (amount > 0)
            {
                out[it] += amount;
            }
            else
            	return false;
        }
    }
    return true;
}


void InternalAddRecipe(Recipe r)
{
	if (!(__item_recipes contains r.creating_item))
	{
		Recipe [int] blank;
        __item_recipes[r.creating_item] = blank;
	}
	__item_recipes[r.creating_item][__item_recipes[r.creating_item].count()] = r;
	if (r.type == "COOK" || r.type == "COOK_FANCY")
    {
    	foreach it in r.source_items
        	__items_that_craft_food[it] = true;
    }
}

void InternalParseConcoctionEntry(string entry)
{
	string [int] split_entry = entry.split_string_alternate_immutable("\t");
	//crafting_thing, crafting_type, mixing_item_1, mixing_item_2, mixing_item_3, mixing_item_4, mixing_item_5, mixing_item_6, mixing_item_7, mixing_item_8, mixing_item_9, mixing_item_10, mixing_item_11, mixing_item_12, mixing_item_13, mixing_item_14, mixing_item_15, mixing_item_16, mixing_item_17, mixing_item_18
	if (split_entry.count() < 3) return;
	Recipe r;
	
	r.creating_item = split_entry[0].to_item();
	r.type = split_entry[1];
	if (r.creating_item == $item[none])
	{
		//print_html("Unknown item " + split_entry[0]);
        return;
	}
	for i from 2 to split_entry.count() - 1
	{
		string value = split_entry[i];
		int [item] out;
        parseDatafileItem(out, value);
        if (out.count() > 0)
        {
        	foreach it, amount in out
            {
            	r.source_items[it] += amount;
            }
        }
	}
    if (r.type.contains_text("ROW"))
        __item_is_purchasable_from_a_store[r.creating_item] = true;
	
	if (r.source_items.count() == 0)
	{
		//print_html(r.creating_item + " has no source items, entry is \"" + entry + "\"");
        return;
	}
	InternalAddRecipe(r);
	
	
	//print_html("Added " + r.creating_item + " of type " + r.type + " which requires " + r.source_items.to_json());
}

void InternalParseConcoctions()
{
	string [int] file_lines = file_to_array("data/concoctions.txt");
	foreach key, entry in file_lines
	{
		//Note that FileUtilities.java appears to only ignore lines starting exactly with #.
        //So that is what we will do.
        if (entry == "") continue;
        if (entry.char_at(0) == "#") continue;
        InternalParseConcoctionEntry(entry);
	}
	
	if (false)
	{
		foreach it in __item_recipes
        {
        	if (__item_recipes[it].count() <= 1) continue;
            print_html(it + " has " + __item_recipes[it].count() + " recipes: " + __item_recipes[it].to_json()); 
        }
	}
}

void InternalParseCoinmasterEntry(string entry)
{
	//shop name, buy or sell, currency amount, item acquired, row
	
	string [int] split_entry = entry.split_string_alternate_immutable("\t");
	if (split_entry.count() < 4) return;
	if (split_entry[1] != "buy") return;
	
	Recipe r;
	r.source_coinmaster = split_entry[0].to_coinmaster();
	if (r.source_coinmaster == $coinmaster[none])
	{
		//print_html("Unknown coinmaster for " + entry);
        return;
	}
	r.creating_item = split_entry[3].to_item();
	if (r.creating_item == $item[none])
	{
		//print_html("Unknown item for " + entry);
        return;
	}
	
	int currency_amount = split_entry[2].to_int();
	item store_item = r.source_coinmaster.item;
	
	if (store_item != $item[none])
		r.source_items[store_item] = currency_amount;
	
	__item_is_purchasable_from_a_store[r.creating_item] = true;
	
	if (split_entry.count() >= 5)
		r.coinmaster_row_id = split_entry[4];
	if (r.source_items.count() == 0)
	{
		//print_html(r.creating_item + " has no source items, entry is \"" + entry + "\"");
        return;
	}
	InternalAddRecipe(r);
	//print_html(r.creating_item + ": " + r.to_json());
}

void InternalParseCoinmasters()
{
	//coinmasters.txt has improper format for actual game; it assumes a "store" currency which is not accurate, stores can have multiple currencies
	
	string [int] file_lines = file_to_array("data/coinmasters.txt");
	foreach key, entry in file_lines
	{
        if (entry == "") continue;
        if (entry.char_at(0) == "#") continue;
        InternalParseCoinmasterEntry(entry);
	}
}


void initialiseItemIngredients()
{
    if (__item_recipes.count() > 0) return;
    
    //Parse concoctions:
    InternalParseConcoctions();
    
    //Parse coinmasters:
    InternalParseCoinmasters();
    
}
initialiseItemIngredients();





void testItemIngredients()
{
    print_html(__item_recipes.count() + " recipes known.");
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
