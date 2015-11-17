import "relay/Guide/Support/Math.ash";

effect [element] __flavour_lookup;
__flavour_lookup[$element[hot]] = $effect[Spirit of Cayenne];
__flavour_lookup[$element[cold]] = $effect[Spirit of Peppermint];
__flavour_lookup[$element[stench]] = $effect[Spirit of Garlic];
__flavour_lookup[$element[spooky]] = $effect[Spirit of Wormwood];
__flavour_lookup[$element[sleaze]] = $effect[Spirit of Bacon Grease];

float damageForElementAgainstElement(float base_damage, element attacking_element, element defence_element)
{
    if (defence_element == $element[none])
        return base_damage;
    if (attacking_element == defence_element)
        return 1;
    
    boolean [element] relevant_elements = $elements[sleaze,stench,hot,spooky,cold];
    float [element,element] attack_versus_element;
    foreach e1 in relevant_elements
    {
        foreach e2 in relevant_elements
        {
            if (e1 == e2)
                attack_versus_element[e1][e2] = 0.0;
            else
                attack_versus_element[e1][e2] = 1.0;
        }
    }
    attack_versus_element[$element[sleaze]][$element[stench]] = 2.0;
    attack_versus_element[$element[sleaze]][$element[hot]] = 2.0;
    
    attack_versus_element[$element[stench]][$element[hot]] = 2.0;
    attack_versus_element[$element[stench]][$element[spooky]] = 2.0;
    
    attack_versus_element[$element[hot]][$element[spooky]] = 2.0;
    attack_versus_element[$element[hot]][$element[cold]] = 2.0;
    
    attack_versus_element[$element[spooky]][$element[cold]] = 2.0;
    attack_versus_element[$element[spooky]][$element[sleaze]] = 2.0;
    
    attack_versus_element[$element[cold]][$element[sleaze]] = 2.0;
    attack_versus_element[$element[cold]][$element[stench]] = 2.0;
    
    
    return MAX(1, base_damage * attack_versus_element[attacking_element][defence_element]);
}

element currentFlavourElement()
{
    foreach s, d in __flavour_lookup
    {
        if (d.have_effect() != 0)
            return s;
    }
    return $element[none];
}

//Does not take into account spell criticals, as they're random by nature.
//FIXME support 100% criticals, I suppose

Vec2f spellFormulaDamageRange(float multiplier, float damage_cap, Vec2f base_damage_range, float buffed_myst_percentage, element e)
{
    Vec2f range = Vec2fMake(0.0, 0.0);
    range.x = base_damage_range.x + floor(my_buffedstat($stat[mysticality]) * buffed_myst_percentage) + numeric_modifier("spell damage");
    range.y = base_damage_range.y + floor(my_buffedstat($stat[mysticality]) * buffed_myst_percentage) + numeric_modifier("spell damage");
    
    if (e != $element[none])
    {
        float element_spell_damage = numeric_modifier(e + " spell damage");
        range.x += element_spell_damage;
        range.y += element_spell_damage;
    }
    if (damage_cap > 0.0)
    {
        range.x = MIN(damage_cap, range.x);
        range.y = MIN(damage_cap, range.y);
    }
    range.x *= multiplier;
    range.y *= multiplier;
    
    range.x *= 1.0 + numeric_modifier("spell damage percent") / 100.0;
    range.y *= 1.0 + numeric_modifier("spell damage percent") / 100.0;
    
    range.x = ceil(range.x);
    range.y = ceil(range.y);
    return range;
}

Record SEDRDamageSource
{
    element element_type;
    Vec2f damage_range;
};

SEDRDamageSource SEDRDamageSourceMake(element e, Vec2f damage_range)
{
    SEDRDamageSource result;
    result.element_type = e;
    result.damage_range = damage_range;
    return result;
}

void listAppend(SEDRDamageSource [int] list, SEDRDamageSource entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

float MLDamageMultiplier()
{
    float ml_damage_multiplier = 1.0;
    ml_damage_multiplier = MIN(1.0, 1.0 - MIN(monster_level_adjustment() * 0.4 / 100.0, 0.5)); //FIXME investigate negative ML
    return ml_damage_multiplier;
}

Vec2f skillExpectedDamageRange(monster m, skill s)
{
    //FIXME spade how on earth to properly calculate this
    //for instance, how does elemental spell damage work?
    float ml_damage_multiplier = MLDamageMultiplier();
    
    element flavour_element = currentFlavourElement();
    
    int monster_group_size = 1;
    //FIXME add a bunch of these, or feature request to mafia:
    if (m == $monster[wall of bones])
        monster_group_size = 100; //FIXME spade
    
    element [int] active_lanterns;
    
    if ($item[Rain-Doh green lantern].equipped_amount() > 0)
        active_lanterns.listAppend($element[stench]);
    else if ($item[snow mobile].equipped_amount() > 0)
        active_lanterns.listAppend($element[cold]);
    
    element [int] pastamancer_active_lanterns = active_lanterns.listCopy();
    if ($item[porcelain porkpie].equipped_amount() > 0) //ONLY for pastamancer spells
        pastamancer_active_lanterns.listAppend($element[sleaze]);
    
    
    SEDRDamageSource [int] damage_sources;
    
    if (s == $skill[saucegeyser])
    {
        float multiplier = MIN(3.0, monster_group_size);
        element saucegeyser_element = $element[hot];
        if (m.defense_element == $element[hot] || m.defense_element == $element[sleaze] || m.defense_element == $element[stench])
            saucegeyser_element = $element[cold];
        else if (m.defense_element == $element[cold] || m.defense_element == $element[spooky])
            saucegeyser_element = $element[hot];
        else
        {
            //complicated
            //we pick the one with more spell damage
            //FIXME the exact calculation in-game is probably "whichever element does more damage"
            //we should be doing that now, but we aren't handling hotform/coldform/etc
            //or double-ice
            //but spading suggests if hot spell damage is greater than cold spell damage, it'll always be hot against non-elementals. if they're equal, it's random. if it's less than, it's always cold.
            if (numeric_modifier("hot spell damage") > numeric_modifier("cold spell damage"))
                saucegeyser_element = $element[hot];
            else
                saucegeyser_element = $element[cold];
        }
        Vec2f saucegeyser_base = spellFormulaDamageRange(multiplier, 0.0, Vec2fMake(60.0, 70.0), 0.4, saucegeyser_element);
        //FIXME is the group damage multiplier before or after bonus spell damage?
        damage_sources.listAppend(SEDRDamageSourceMake(saucegeyser_element, saucegeyser_base));
        foreach key, e in active_lanterns
            damage_sources.listAppend(SEDRDamageSourceMake(e, saucegeyser_base));
    }
    else
        return Vec2fMake(-1.0, -1.0);
    Vec2f expected_damage_range = Vec2fMake(0.0, 0.0);
    
    foreach key, damage_source in damage_sources
    {
        expected_damage_range.x += ml_damage_multiplier * damageForElementAgainstElement(damage_source.damage_range.x, damage_source.element_type, m.defense_element);
        expected_damage_range.y += ml_damage_multiplier * damageForElementAgainstElement(damage_source.damage_range.y, damage_source.element_type, m.defense_element);
    }

    return expected_damage_range;
}

float skillExpectedDamage(monster m, skill s)
{
    Vec2f range = skillExpectedDamageRange(m, s);
    return (range.x + range.y) * 0.5;
}