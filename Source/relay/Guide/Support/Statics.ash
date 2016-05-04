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

static
{
    boolean [item] __beancannon_source_items = lookupItems("Heimz Fortified Kidney Beans,Hellfire Spicy Beans,Mixed Garbanzos and Chickpeas,Pork 'n' Pork 'n' Pork 'n' Beans,Shrub's Premium Baked Beans,Tesla's Electroplated Beans,Frigid Northern Beans,Trader Olaf's Exotic Stinkbeans,World's Blackest-Eyed Peas");
}

static
{
    //This would be a good mafia proxy value. Feature request?
    boolean [skill] __combat_skills_that_are_spells;
    void initialiseCombatSkillsThatAreSpells()
    {
        foreach s in $skills[Awesome Balls of Fire,Bake,Blend,Blinding Flash,Boil,Candyblast,Cannelloni Cannon,Carbohydrate Cudgel,Chop,CLEESH,Conjure Relaxing Campfire,Creepy Lullaby,Curdle,Doubt Shackles,Eggsplosion,Fear Vapor,Fearful Fettucini,Freeze,Fry,Grease Lightning,Grill,Haggis Kick,Inappropriate Backrub,K&auml;seso&szlig;esturm,Mudbath,Noodles of Fire,Rage Flame,Raise Backup Dancer,Ravioli Shurikens,Salsaball,Saucegeyser,Saucemageddon,Saucestorm,Saucy Salve,Shrap,Slice,Snowclone,Spaghetti Spear,Stream of Sauce,Stringozzi Serpent,Stuffed Mortar Shell,Tear Wave,Toynado,Volcanometeor Showeruption,Wassail,Wave of Sauce,Weapon of the Pastalord]
        {
            __combat_skills_that_are_spells[s] = true;
        }
        foreach s in lookupSkills("Lavafava,Pungent Mung,Beanstorm") //FIXME cowcall? snakewhip?
            __combat_skills_that_are_spells[s] = true;
    }
    initialiseCombatSkillsThatAreSpells();
}