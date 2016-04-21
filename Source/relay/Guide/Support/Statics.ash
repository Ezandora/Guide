static
{
    skill [class][int] __skills_by_class;
    
    void initialiseSkillsByClass()
    {
        foreach s in $skills[]
        {
            if (s.class != $class[none])
            {
                if (!(__skills_by_class contains s.class))
                {
                    skill [int] blank;
                    __skills_by_class[s.class] = blank;
                }
                __skills_by_class[s.class].listAppend(s);
            }
        }
    }
    initialiseSkillsByClass();
}


static
{
    boolean [item] __items_that_craft_food;
    
    void initialiseItemsThatCraftFood()
    {
        foreach crafted_item in $items[]
        {
            string craft_type = crafted_item.craft_type();
            if (!craft_type.contains_text("Cooking"))
                continue;
            foreach it in crafted_item.get_ingredients()
            {
                __items_that_craft_food[it] = true;
            }
        }
    }
    initialiseItemsThatCraftFood();
}

static
{
    boolean [skill] __libram_skills;
    
    void initialiseLibramSkills()
    {
        foreach s in $skills[]
        {
            if (s.libram)
                __libram_skills[s] = true;
        }
    }
    initialiseLibramSkills();
}


static
{
    boolean [item] __minus_combat_equipment;
    void initialiseMinusCombatEquipment()
    {
        foreach it in $items[]
        {
            if (it.to_slot() == $slot[none])
                continue;
            if (it.numeric_modifier("combat rate") >= 0)
                continue;
            __minus_combat_equipment[it] = true;
        }
    }
    initialiseMinusCombatEquipment();
}