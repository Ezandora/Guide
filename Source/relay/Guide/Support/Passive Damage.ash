//Active attacks, stinging damage.

int PDS_DAMAGE_TYPE_NONE = 0;
int PDS_DAMAGE_TYPE_ACTIVE = 1;
int PDS_DAMAGE_TYPE_STINGING = 2;

int PDS_SOURCE_TYPE_NONE = 0;
int PDS_SOURCE_TYPE_EFFECT = 1;
int PDS_SOURCE_TYPE_COMBAT_ITEM = 2;
int PDS_SOURCE_TYPE_EQUIPMENT = 3;
int PDS_SOURCE_TYPE_COMBAT_SKILL = 4;
int PDS_SOURCE_TYPE_FAMILIAR = 5;
int PDS_SOURCE_TYPE_BJORN_FAMILIAR = 6; //also crown

record PassiveDamageSource
{
    int damage_type;
    int source_type; //item, etc
    float chance_of_acting;
    int max_rounds_act; //0 for unlimited
    
    Vec2f [element] damage_range;
    
    
    effect source_effect; //if effect
    item source_effect_potion; //if effect
    skill source_effect_skill; //if effect
    item source_equipment; //if equipment
    item source_combat_item; //if combat item
    skill source_combat_skill; //if combat skill
    familiar source_familiar; //familiar or bjorn familiar
};

PassiveDamageSource PassiveDamageSourceMake(int damage_type, int source_type)
{
    PassiveDamageSource pds;
    pds.damage_type = damage_type;
    pds.source_type = source_type;
    pds.chance_of_acting = 1.0;
    
    return pds;
}

void PassiveDamageSourceAddDamage(PassiveDamageSource pds, float min_damage, float max_damage, element e)
{
    Vec2f range;
    range.x = min_damage;
    range.y = max_damage;
    if (pds.damage_range contains e)
    {
        range.x += pds.damage_range[e].x;
        range.y += pds.damage_range[e].y;
    }
    pds.damage_range[e] = range;
}

void PassiveDamageSourceAddDamage(PassiveDamageSource pds, float amount, element e)
{
    PassiveDamageSourceAddDamage(pds, amount, amount, e);
}

void PassiveDamageSourceAddDamage(PassiveDamageSource pds, float physical_only)
{
    PassiveDamageSourceAddDamage(pds, physical_only, $element[none]);
}

void listAppend(PassiveDamageSource [int] list, PassiveDamageSource entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

PassiveDamageSource listExactLastObject(PassiveDamageSource [int] list) //WARNING only works for linear arrays
{
    if (list.count() == 0)
        return PassiveDamageSourceMake(0, 0);
    return list[list.count() - 1];
}

static
{
    PassiveDamageSource [int] __known_sources;
    void PDSInitialiseDoNotCallThis()
    {
        if (__known_sources.count() > 0)
            return;
        //Create every source:
        //FIXME add
        __known_sources.listAppend(PassiveDamageSourceMake(PDS_DAMAGE_TYPE_ACTIVE, PDS_SOURCE_TYPE_EQUIPMENT));
        __known_sources.listExactLastObject().PassiveDamageSourceAddDamage(1, 11, $element[none]); //FIXME WRONG
        __known_sources.listExactLastObject().source_equipment = $item[hand in glove];
        
        //FIXME wrong, but a good preliminary:
        foreach it in $items[MagiMechTech NanoMechaMech,bottle opener belt buckle,old school calculator watch,ant hoe,ant pick,ant pitchfork,ant rake,ant sickle,fishy wand,moveable feast,oversized fish scaler,plastic pumpkin bucket,tiny bowler,cup of infinite pencils,double-ice box,smirking shrunken head,mr. haggis,stapler bear,dubious loincloth,muddy skirt,bottle of Goldschn&ouml;ckered,acid-squirting flower,ironic oversized sunglasses,hippy protest button,cannonball charrrm bracelet,groovy prism necklace,spiky turtle shoulderpads,double-ice cap,parasitic headgnawer,eelskin hat,balloon shield,hot plate,Ol' Scratch's stove door,Oscus's garbage can lid,eelskin shield,eelskin pants,buddy bjorn,shocked shell,crown of thrones]
        {
            __known_sources.listAppend(PassiveDamageSourceMake(PDS_DAMAGE_TYPE_ACTIVE, PDS_SOURCE_TYPE_EQUIPMENT));
            __known_sources.listExactLastObject().PassiveDamageSourceAddDamage(1);
            __known_sources.listExactLastObject().source_equipment = it;
        }
        foreach e in $effects[Skeletal Warrior,Skeletal Cleric,Skeletal Wizard,Bone Homie,Burning\, Man,Biologically Shocked,EVISCERATE!,Fangs and Pangs,Permanent Halloween,Curse of the Black Pearl Onion,Long Live GORF,Apoplectic with Rage,Dizzy with Rage,Quivering with Rage,Jaba&ntilde;ero Saucesphere,Psalm of Pointiness,Drenched With Filth,Stuck-Up Hair,It's Electric!,Smokin',Jalape&ntilde;o Saucesphere,Scarysauce,spiky shell,Boner Battalion]
        {
            __known_sources.listAppend(PassiveDamageSourceMake(PDS_DAMAGE_TYPE_ACTIVE, PDS_SOURCE_TYPE_EFFECT));
            __known_sources.listExactLastObject().PassiveDamageSourceAddDamage(1);
            __known_sources.listExactLastObject().source_effect = e;
        }
        
        foreach f in $familiars[]
        {
            if (!(f.physical_damage || f.elemental_damage) && !($familiars[Doppelshifter,Comma Chameleon,Mad Hatrack,Robot Reindeer,Fancypants Scarecrow,Mini-Adventurer] contains f))
                continue;
            __known_sources.listAppend(PassiveDamageSourceMake(PDS_DAMAGE_TYPE_ACTIVE, PDS_SOURCE_TYPE_FAMILIAR));
            __known_sources.listExactLastObject().chance_of_acting = 0.333; //most
            __known_sources.listExactLastObject().PassiveDamageSourceAddDamage(1);
            __known_sources.listExactLastObject().source_familiar = f;
        }
    }
    
    PDSInitialiseDoNotCallThis();
}


PassiveDamageSource [int] PDSGetActiveDamageSources()
{
    PassiveDamageSource [int] result;
    
    foreach key, pds in __known_sources
    {
        boolean should_add = false;
        if (pds.source_type == PDS_SOURCE_TYPE_EFFECT)
        {
            if (pds.source_effect.have_effect() > 0)
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_COMBAT_ITEM)
        {
            //Nothing
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_EQUIPMENT)
        {
            if (pds.source_equipment.equipped_amount() > 0)
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_COMBAT_SKILL)
        {
            //Nothing
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_FAMILIAR)
        {
            if (my_familiar() == pds.source_familiar)
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_BJORN_FAMILIAR)
        {
            if (my_bjorned_familiar() == pds.source_familiar && $item[buddy bjorn].equipped_amount() > 0)
                should_add = true;
            if (my_enthroned_familiar() == pds.source_familiar && $item[crown of thrones].equipped_amount() > 0)
                should_add = true;
        }
        if (should_add)
            result.listAppend(pds);
    }
    
    return result;
}

//Does not return sources already in effect
PassiveDamageSource [int] PDSGetPotentialDamageSources()
{
    PassiveDamageSource [int] result;

    foreach key, pds in __known_sources
    {
        boolean should_add = false;
        if (pds.source_type == PDS_SOURCE_TYPE_EFFECT)
        {
            if (pds.source_effect.have_effect() == 0)
            {
                if (pds.source_effect_potion.available_amount() > 0)
                    should_add = true;
                if (pds.source_effect_skill.have_skill() && pds.source_effect_skill.is_unrestricted())
                    should_add = true;
            }
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_COMBAT_ITEM)
        {
            if (pds.source_combat_item.available_amount() > 0)
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_EQUIPMENT)
        {
            if (pds.source_equipment.equipped_amount() == 0 && pds.source_equipment.can_equip() && pds.source_equipment.available_amount() > 0)
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_COMBAT_SKILL)
        {
            //FIXME is this correct?
            if (pds.source_combat_skill.have_skill() && pds.source_combat_skill.is_unrestricted())
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_FAMILIAR)
        {
            if (pds.source_familiar.familiar_is_usable() && my_familiar() != pds.source_familiar)
                should_add = true;
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_BJORN_FAMILIAR)
        {
            //FIXME add
        }
        if (should_add)
            result.listAppend(pds);
    }
    
    return result;
}


string [int] PDSGenerateDescriptionToUneffectPassives()
{
    string [int] effect_types;
    string [int] equipment_types;
    string [int] familiar_types; //you know, because we often bring two or more familiars... with us... avatar of susie?
    string [int] bjorn_familiar_types;
    foreach key, pds in PDSGetActiveDamageSources()
    {
        if (pds.source_type == PDS_SOURCE_TYPE_EFFECT)
        {
            effect_types.listAppend(pds.source_effect);
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_EQUIPMENT)
        {
            equipment_types.listAppend(pds.source_equipment);
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_FAMILIAR)
        {
            familiar_types.listAppend(pds.source_familiar);
        }
        else if (pds.source_type == PDS_SOURCE_TYPE_BJORN_FAMILIAR)
        {
            bjorn_familiar_types.listAppend(pds.source_familiar);
        }
        
    }
    string [int] result;
    if (effect_types.count() > 0)
        result.listAppend("Uneffect " + effect_types.listJoinComponents(", ", "and") + ".");
    if (equipment_types.count() > 0)
        result.listAppend("Unequip " + equipment_types.listJoinComponents(", ", "and") + ".");
    if (familiar_types.count() > 0)
        result.listAppend("Change familiar from " + familiar_types.listJoinComponents(", ", "and") + ".");
    if (bjorn_familiar_types.count() > 0)
        result.listAppend("Change bjorn/crown familiar from " + bjorn_familiar_types.listJoinComponents(", ", "and") + ".");
    return result;
}

boolean PDSFamiliarCouldPossiblyAttack(familiar f)
{
    if (f.combat) return true;
    foreach key, pds in __known_sources
    {
        if (pds.source_type == PDS_SOURCE_TYPE_FAMILIAR)
        {
            if (f == pds.source_familiar)
                return true;
        }
    }
    return false;
}