
static
{
    item [string][int] __if_potions_with_numeric_modifiers;
    
    
    /*void ItemFilterInitialise()
    {
        boolean [string] modifier_names = $strings[Meat Drop,Initiative,Muscle,Mysticality,Moxie,Muscle Percent,Mysticality Percent,Moxie Percent];
        
        foreach modifier in modifier_names
        {
            __if_potions_with_numeric_modifiers[modifier] = listMakeBlankItem();
        }
        foreach it in $items[]
        {
            if (it.inebriety > 0 || it.fullness > 0 || it.spleen > 0) continue;
            effect e = it.to_effect();
            if (e == $effect[none]) continue;
            foreach modifier in modifier_names
            {
                if (e.numeric_modifier(modifier) > 0.0)
                {
                    __if_potions_with_numeric_modifiers[modifier].listAppend(it);
                }
            }
        }
    }
    
    
    ItemFilterInitialise();*/
}


void ItemFilterInitialisePotionsForModifier(string modifier)
{
    if (__if_potions_with_numeric_modifiers contains modifier)
        return;
    __if_potions_with_numeric_modifiers[modifier] = listMakeBlankItem();

    foreach it in $items[]
    {
        if (it.inebriety > 0 || it.fullness > 0 || it.spleen > 0) continue;
        effect e = it.to_effect();
        if (e == $effect[none]) continue;
        if (e.numeric_modifier(modifier) != 0.0)
        {
            __if_potions_with_numeric_modifiers[modifier].listAppend(it);
        }
    }
}


item [int] ItemFilterGetPotionsWithNumericModifiers(string [int] modifiers)
{
    item [int] potions;
    boolean [item] seen_potions;
    foreach key, modifier in modifiers
    {
        item [int] first_layer_list;
        if (!(__if_potions_with_numeric_modifiers contains modifier))
            ItemFilterInitialisePotionsForModifier(modifier);
        
        first_layer_list = __if_potions_with_numeric_modifiers[modifier];
        
        
        foreach key, it in first_layer_list
        {
            if (!it.is_unrestricted())
                continue;
            if (seen_potions contains it)
                continue;
            potions.listAppend(it);
            seen_potions[it] = true;
        }
    }
    
    return potions;
}

item [int] ItemFilterGetPotionsCouldPullToAddToNumericModifier(string [int] modifiers, float minimum_modifier, boolean [item] blocklist)
{
    item [int] relevant_potions_first_layer = ItemFilterGetPotionsWithNumericModifiers(modifiers);
    
    item [int] relevant_potions;
    foreach key, it in relevant_potions_first_layer
    {
        if (it.available_amount() > 0) continue;
        if (!it.tradeable && it.storage_amount() == 0) continue;
        if (!it.item_is_usable()) continue;
        effect e = it.to_effect();
        if (e.have_effect() > 0) continue;
        if (!e.effect_is_usable()) continue;
        float v = 0;
        foreach key, modifier in modifiers
            v += e.numeric_modifier(modifier);
        if (v != 0.0 && v >= minimum_modifier && !(blocklist contains it))
        {
            relevant_potions.listAppend(it);
        }
    }
    if (modifiers.count() == 2)
        sort relevant_potions by -(value.effect_modifier("effect").numeric_modifier(modifiers[0]) + value.effect_modifier("effect").numeric_modifier(modifiers[1]));
    else
        sort relevant_potions by -value.effect_modifier("effect").numeric_modifier(modifiers[0]);
    
    return relevant_potions;
}


item [int] ItemFilterGetPotionsCouldPullToAddToNumericModifier(string modifier, float minimum_modifier, boolean [item] blocklist)
{
    return ItemFilterGetPotionsCouldPullToAddToNumericModifier(listMake(modifier), minimum_modifier, blocklist);
}
