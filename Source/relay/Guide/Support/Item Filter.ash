
static
{
    item [string][int] __if_potions_with_numeric_modifiers;
    
    
    void ItemFilterInitialise()
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
    
    
    ItemFilterInitialise();
}



item [int] ItemFilterGetPotionsWithNumericModifier(string modifier)
{
    item [int] potions;
    item [int] first_layer_list;
    if (__if_potions_with_numeric_modifiers contains modifier)
        first_layer_list = __if_potions_with_numeric_modifiers[modifier];
    else
    {
        foreach it in $items[]
        {
            if (it.inebriety > 0 || it.fullness > 0 || it.spleen > 0) continue;
            effect e = it.to_effect();
            if (e == $effect[none]) continue;
            if (e.numeric_modifier(modifier) > 0.0)
                first_layer_list.listAppend(it);
        }
    }
    
    foreach key, it in first_layer_list
    {
        if (!it.is_unrestricted())
            continue;
        potions.listAppend(it);
    }
    
    return potions;
}

item [int] ItemFilterGetPotionsCouldPullToAddToNumericModifier(string modifier, float minimum_modifier, boolean [item] blacklist)
{
    item [int] relevant_potions_first_layer = ItemFilterGetPotionsWithNumericModifier(modifier);
    
    item [int] relevant_potions;
    foreach key, it in relevant_potions_first_layer
    {
        if (it.available_amount() > 0) continue;
        if (!it.tradeable && it.storage_amount() == 0) continue;
        effect e = it.to_effect();
        if (e.have_effect() > 0) continue;
        float v = e.numeric_modifier(modifier);
        if (v > 0.0 && v >= minimum_modifier && !(blacklist contains it))
        {
            relevant_potions.listAppend(it);
        }
    }
    sort relevant_potions by -value.effect_modifier("effect").numeric_modifier(modifier);
    
    return relevant_potions;
}