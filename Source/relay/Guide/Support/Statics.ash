
static
{
    skill [class][int] __skills_by_class;
    
    void initialiseSkillsByClass()
    {
        if (__skills_by_class.count() > 0) return;
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
    boolean [item] __items_that_craft_food;
    boolean [item] __minus_combat_equipment;
    boolean [item] __equipment;
    void initialiseItems()
    {
        foreach it in $items[]
        {
            //Crafting:
            string craft_type = it.craft_type();
            if (craft_type.contains_text("Cooking"))
            {
                foreach ingredient in it.get_ingredients()
                {
                    __items_that_craft_food[ingredient] = true;
                }
            }
            
            //Equipment:
            if (it.to_slot() != $slot[none])
            {
                __equipment[it] = true;
                if (it.numeric_modifier("combat rate") < 0)
                    __minus_combat_equipment[it] = true;
            }
        }
    }
    initialiseItems();
}

static
{
    boolean [item] __beancannon_source_items = $items[Heimz Fortified Kidney Beans,Hellfire Spicy Beans,Mixed Garbanzos and Chickpeas,Pork 'n' Pork 'n' Pork 'n' Beans,Shrub's Premium Baked Beans,Tesla's Electroplated Beans,Frigid Northern Beans,Trader Olaf's Exotic Stinkbeans,World's Blackest-Eyed Peas];
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

static
{
    boolean [monster] __snakes;
    void initialiseSnakes()
    {
        __snakes = lookupMonsters("aggressive grass snake,Bacon snake,Batsnake,Black adder,Burning Snake of Fire,Coal snake,Diamondback rattler,Frontwinder,Frozen Solid Snake,King snake,Licorice snake,Mutant rattlesnake,Prince snake,Sewer snake with a sewer snake in it,Snakeleton,The Snake With Like Ten Heads,Tomb asp,Trouser Snake,Whitesnake");
    }
    initialiseSnakes();
}

item lookupAWOLOilForMonster(monster m)
{
    if (__snakes contains m)
        return $item[snake oil];
    else if ($phylums[beast,dude,hippy,humanoid,orc,pirate] contains m.phylum)
        return $item[skin oil];
    else if ($phylums[bug,construct,constellation,demon,elemental,elf,fish,goblin,hobo,horror,mer-kin,penguin,plant,slime,weird] contains m.phylum)
        return $item[unusual oil];
    else if ($phylums[undead] contains m.phylum)
        return $item[eldritch oil];
    return $item[none];
}