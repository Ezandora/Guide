static
{
    //NOTE: this array does not support non-tradeable, quest, or non-discardable items. It could, but then I'd have to filter those out later, and I'm not sure how fast get_related is.
    int [item][item] __inverse_pulverisation;
    
    void initialisePulverisations()
    {
        foreach smashing_item in $items[]
        {
            if (!smashing_item.tradeable || smashing_item.quest || !smashing_item.discardable)
                continue;
            if (smashing_item.to_slot() == $slot[none])
                continue;
            int [item] pulverisations = smashing_item.get_related("pulverize");
            if (pulverisations.count() == 0)
                continue;
            foreach smash_result, value in pulverisations
            {
                __inverse_pulverisation[smash_result][smashing_item] = value;
            }
        }
    }
    
    initialisePulverisations();
}

record SmashableItem
{
    item it;
    float products_found;
};

SmashableItem SmashableItemMake(item it, float products_found)
{
    SmashableItem result;
    result.it = it;
    result.products_found = products_found;
    return result;
}

void listAppend(SmashableItem [int] list, SmashableItem entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

        
void pulveriseAlterOutputList(string [int] output_list)
{
    //Alter lines so items aren't split up by word wrap:
    int number_seen = 0;
    foreach key in output_list
    {
        string line = output_list[key];
        
        if (number_seen < output_list.count() - 1) //comma needs to be part of the group
            line += ",";
        line = HTMLGenerateDivOfClass(line, "r_word_wrap_group");
        
        output_list[key] = line;
        number_seen += 1;
    }
}

string [int] pulveriseGenerateOutputListForProducts(boolean [item] products_wanted, boolean [item] blocklist)
{
    int [item] smashables_found;
    foreach product in products_wanted
    {
        foreach smashable in __inverse_pulverisation[product]
        {
            if (smashable.available_amount() == 0)
                continue;
            if (blocklist[smashable])
                continue;
            int value = __inverse_pulverisation[product][smashable];
            smashables_found[smashable] += value;
        }
    }
    
    
    SmashableItem [int] available_smashed_items;
    
    foreach smashable, product_count in smashables_found
    {
        float average_products_acquired = product_count.to_float() / 1000000.0;
        available_smashed_items.listAppend(SmashableItemMake(smashable, average_products_acquired));
    }

    sort available_smashed_items by -(value.products_found * value.it.available_amount());
    
    string [int] result;
    foreach key in available_smashed_items
    {
        SmashableItem smashable_item = available_smashed_items[key];
        string line;
        
        line = smashable_item.it;
        
        result.listAppend(line);
    }
    

    
    pulveriseAlterOutputList(result);
    return result;
}

void pulveriseAppendOutputListForProducts(string [int] description, string category, boolean [item] products_wanted, boolean [item] blocklist)
{
    string [int] output_list = pulveriseGenerateOutputListForProducts(products_wanted, blocklist);

    if (output_list.count() > 0)
    {
        description.listAppend(HTMLGenerateSpanOfClass(category.capitaliseFirstLetter() + ": ", "r_bold") + output_list.listJoinComponents(" ", "and") + ".");
    }
}

void SPulveriseGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!$skill[pulverize].skill_is_usable())
        return;
    if (!in_ronin()) //list is far too long with your main inventory, and you can buy wads at this point
        return;
    
    
    /*
     Smashable item types:
     BRICKO brick
     candycaine powder
     chunk of depleted Grimacite
     cold cluster
     cold nuggets
     cold powder
     cold wad
     corrupted stardust
     effluvious emerald
     epic wad
     glacial sapphire
     handful of Smithereens
     hot cluster
     hot nuggets
     hot powder
     hot wad
     sea salt crystal
     sleaze cluster
     sleaze nuggets
     sleaze powder
     sleaze wad
     spooky cluster
     spooky nuggets
     spooky powder
     spooky wad
     steamy ruby
     stench cluster
     stench nuggets
     stench powder
     stench wad
     sugar shard
     tawdry amethyst
     twinkly nuggets
     twinkly powder
     twinkly wad
     ultimate wad
     unearthly onyx
     useless powder
     wad of Crovacite
     */
    
    
    boolean [item] blocklist;
    blocklist.listAppendList($items[fireman's helmet,fire axe,enchanted fire extinguisher,fire hose,rainbow pearl earring,rainbow pearl necklace,rainbow pearl ring,steaming evil,ring of detect boring doors,giant discarded torn-up glove,giant discarded plastic fork,giant discarded bottlecap,toy ray gun,toy space helmet,toy jet pack,MagiMechTech NanoMechaMech,astronaut pants,ancient hot dog wrapper,bram's choker]);
    
    if (!__quest_state["Level 12"].finished)
        blocklist.listAppendList($items[reinforced beaded headband,bullet-proof corduroys,round purple sunglasses,beer helmet,distressed denim pants,bejeweled pledge pin]);
    if (!__quest_state["Level 11 Hidden City"].state_boolean["Hospital finished"])
        blocklist.listAppendList($items[head mirror,surgical apron,bloodied surgical dungarees,surgical mask,half-size scalpel]);
    
    string [int] details;
    
    //not relevant for adventures anymore:
    /*if (availableSpleen() > 0 && my_path_id_legacy() != PATH_SLOW_AND_STEADY)
    {
        pulveriseAppendOutputListForProducts(details, "spleen wads", $items[cold wad,hot wad,sleaze wad,spooky wad,stench wad,twinkly wad], blocklist);
    }*/
    
    /*if (__misc_state["mysticality guild store available"] && $skill[Transcendental Noodlecraft].skill_is_usable() && $skill[The Way of Sauce].skill_is_usable()) //can make hi mein?
    {
        pulveriseAppendOutputListForProducts(details, "hi mein elemental nuggets", $items[cold nuggets,hot nuggets,sleaze nuggets,spooky nuggets,stench nuggets], blocklist);
    }*/
    
    
    pulveriseAppendOutputListForProducts(details, "handful of smithereens", $items[handful of smithereens], blocklist);
    
    //Elemental powder, for +1 resistances?
    //Elemental nuggets, for +3 tower test? (very marginal)
    
    if (details.count() > 0)
    {
        string title;
        title = "Pulverisable equipment";
        string url = "craft.php?mode=smith";
        if ($item[tenderizing hammer].available_amount() == 0)
        {
            url = "shop.php?whichshop=meatsmith";
            details.listAppend("Acquire a tenderizing hammer.");
        }
        resource_entries.listAppend(ChecklistEntryMake(387, "__skill pulverize", url, ChecklistSubentryMake(title, "", details), 10));
    }
}
