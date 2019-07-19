
int [item] __cost_to_acquire_override;
void set_cost_to_acquire_override(item it, int override_value)
{
    __cost_to_acquire_override[it] = override_value;
}
//FIXME this needs improvement
//FIXME do not cache if we're using historical_price and then they do a mall search. maybe don't cache at all...? well, we should, but only if it's been seen more than a handful of times? we can't easily detect if our previous prices changed for every item without incurring the same hit as a calculation... does the cache help at all, even in extremely high use scenarios?
float [item] __cost_to_acquire_price_cache;
float [item] __cost_to_acquire_price_cache_thirty_days;
float cost_to_acquire(item it, boolean allow_caching, float mall_search_if_historical_value_is_over, boolean [item] previously_evaluated_items)
{
    //Reusable hack:
    if ($items[tiny plastic sword,vesper,bodyslam,cherry bomb,dirty martini,grogtini,sangria del diablo,skewered cherry,skewered jumbo olive,skewered lime] contains it && it.available_amount() > 0)
    {
        return 0.0;
    }
    previously_evaluated_items[it] = true;
    if (__cost_to_acquire_override contains it)
        return __cost_to_acquire_override[it];
    if (allow_caching && (__cost_to_acquire_price_cache contains it))
    {
        return __cost_to_acquire_price_cache[it];
    }
    if (allow_caching && mall_search_if_historical_value_is_over <= 30.0 && (__cost_to_acquire_price_cache_thirty_days contains it))
        return __cost_to_acquire_price_cache_thirty_days[it];
    float [int] price_sources;
    if (it.tradeable && !($items[glass of &quot;milk&quot;,cup of &quot;tea&quot;,thermos of &quot;whiskey&quot;,lucky lindy,bee's knees,sockdollager,ish kabibble, hot socks, phonus balonus,sloppy jalopy] contains it)) //'
    {
        if (it.historical_age() > mall_search_if_historical_value_is_over)
        {
            price_sources.listAppend(it.mall_price());
        }
        else if (it.historical_price() > 0)
        {
            price_sources.listAppend(it.historical_price());
        }
    }
    if (it.is_npc_item() && it.npc_price() > 0)
        price_sources.listAppend(it.npc_price());
            
    int [item] ingredients = it.get_ingredients();
    if (ingredients.count() > 0)
    {
        boolean ignore_ingredients = false;
        float making_cost = 0.0;
        foreach ingredient, amount in ingredients
        {
            if (previously_evaluated_items contains ingredient)
            {
                ignore_ingredients = true;
                break;
            }
            float acquire_cost = ingredient.cost_to_acquire(allow_caching, mall_search_if_historical_value_is_over, previously_evaluated_items);
            if (acquire_cost < 0)
            {
                ignore_ingredients = true;
                break;
            }
            making_cost += acquire_cost * amount;
        }
        string craft_type = it.craft_type();
        
        if (craft_type.contains_text("Mixing (fancy)"))
        {
            if (can_interact())
                making_cost += $item[bartender-in-the-box].cost_to_acquire(true, mall_search_if_historical_value_is_over, previously_evaluated_items) / 40.0;
            else
                making_cost += 3000.0; //adventure cost hack FIXME
        }
        if (craft_type.contains_text("Cooking (fancy)"))
        {
            if (can_interact())
                making_cost += $item[chef-in-the-box].cost_to_acquire(true, mall_search_if_historical_value_is_over, previously_evaluated_items) / 40.0;
            else
                making_cost += 3000.0; //adventure cost hack FIXME
        }
        //FIXME other craft types
        if (!ignore_ingredients)
            price_sources.listAppend(making_cost);
    }
    float cost = -1.0;
    foreach key, v in price_sources
    {
        if (v < cost || cost == -1.0)
            cost = v;
    }
    if (mall_search_if_historical_value_is_over < 1.0)
        __cost_to_acquire_price_cache[it] = cost;
    else if (mall_search_if_historical_value_is_over <= 30.0)
        __cost_to_acquire_price_cache_thirty_days[it] = cost;
    return cost;
}

float cost_to_acquire(item it, boolean allow_caching, float mall_search_if_historical_value_is_over)
{
    boolean [item] empty_list;
    return cost_to_acquire(it, allow_caching, mall_search_if_historical_value_is_over, empty_list);
}

float cost_to_acquire(item it, float mall_search_if_historical_value_is_over)
{
    return cost_to_acquire(it, false, mall_search_if_historical_value_is_over);
}

float cost_to_acquire(item it)
{
	//acquire, brock, acquire:
    return cost_to_acquire(it, 30.0);
}
