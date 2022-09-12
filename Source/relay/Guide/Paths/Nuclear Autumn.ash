
RegisterTaskGenerationFunction("PathNuclearAutumnGenerateTasks");
void PathNuclearAutumnGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id_legacy() != PATH_NUCLEAR_AUTUMN)
		return;
    string url = "place.php?whichplace=falloutshelter";
    
    ChecklistSubentry [int] subentries;
    
    if (get_property_int("falloutShelterLevel") >= 2 && (my_turncount() >= 50 || get_property_boolean("falloutShelterChronoUsed")))
    {
        if ($item[Rad-Pro (1 oz.)].to_effect().have_effect() <= 1 && my_meat() >= 500 && $item[lead umbrella].equipped_amount() == 0)
        {
            url = "shop.php?whichshop=vault1";
            if ($item[Rad-Pro (1 oz.)].available_amount() > 0)
                url = "inventory.php?which=1"; //FIXME
            subentries.listAppend(ChecklistSubentryMake("Use rad-pro", "", "Protect from radiation."));
        }
    }
    
    if (get_property_int("falloutShelterLevel") >= 8 && !get_property_boolean("falloutShelterCoolingTankUsed"))
    {
        subentries.listAppend(ChecklistSubentryMake("Use cooling tank", "", "Gain 300 rads."));
    }
    if (get_property_int("falloutShelterLevel") >= 5 && !get_property_boolean("falloutShelterChronoUsed"))
    {
        subentries.listAppend(ChecklistSubentryMake("Use chronodynamics laboratory", "", "Increase rads gained."));
    }
    if (get_property_int("falloutShelterLevel") >= 4 && $item[wrist-boy].available_amount() == 0 && my_meat() >= 5000)
    {
        subentries.listAppend(ChecklistSubentryMake("Acquire wrist-boy", "", "Unlocks buff records."));
        url = "shop.php?whichshop=vault2";
    }
    
    if (subentries.count() > 0)
        task_entries.listAppend(ChecklistEntryMake(203, "__item rad", url, subentries, 0));
}

RegisterResourceGenerationFunction("PathNuclearAutumnGenerateResource");
void PathNuclearAutumnGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id_legacy() != PATH_NUCLEAR_AUTUMN)
		return;
    
    item rad = $item[rad];
    if (rad.available_amount() > 0)
    {
        
        int [skill] skill_rad_cost;
        
        foreach s in $skills[Boiling Tear Ducts,Projectile Salivary Glands,Translucent Skin,Skunk Glands,Throat Refrigerant,Internal Soda Machine]
            skill_rad_cost[s] = 30;
        foreach s in $skills[Steroid Bladder,Magic Sweat,Flappy Ears,Self-Combing Hair,Intracranial Eye,Mind Bullets,Extra Kidney,Extra Gall Bladder]
            skill_rad_cost[s] = 60;
        foreach s in $skills[Extra Muscles,Adipose Polymers,Metallic Skin,Hypno-Eyes,Extra Brain,Squid Glands,Extremely Punchable Face,Magnetic Ears,Firefly Abdomen,Bone Springs]
            skill_rad_cost[s] = 90;
        foreach s in $skills[Sucker Fingers,Backwards Knees]
            skill_rad_cost[s] = 120;
        
        string [skill] skill_descriptions;
        skill_descriptions[$skill[Extra Gall Bladder]] = "+100% adventures from food";
        skill_descriptions[$skill[Extra Kidney]] = "+100% Adventures from booze";
        skill_descriptions[$skill[Internal Soda Machine]] = "Restore MP for meat";
        skill_descriptions[$skill[Squid Glands]] = "-10% combat buff";
        skill_descriptions[$skill[Steroid Bladder]] = "+50% muscle buff";
        skill_descriptions[$skill[Extra Muscles]] = "+50% muscle passive";
        skill_descriptions[$skill[Self-Combing Hair]] = "+50% moxie buff";
        skill_descriptions[$skill[Hypno-Eyes]] = "+50% moxie passive";
        skill_descriptions[$skill[Intracranial Eye]] = "+50% myst buff";
        skill_descriptions[$skill[Extra Brain]] = "+50% myst passive";
        skill_descriptions[$skill[Extremely Punchable Face]] = "+30 ML buff";
        skill_descriptions[$skill[Magnetic Ears]] = "15% item buff";
        skill_descriptions[$skill[Sucker Fingers]] = "15% item passive";
        skill_descriptions[$skill[Firefly Abdomen]] = "+10% combat buff";
        skill_descriptions[$skill[Throat Refrigerant]] = "Cold damage spell";
        skill_descriptions[$skill[Flappy Ears]] = "+2 all res buff";
        skill_descriptions[$skill[Metallic Skin]] = "+2 all res passive";
        skill_descriptions[$skill[Bone Springs]] = "+20% init buff";
        skill_descriptions[$skill[Backwards Knees]] = "+20% init passive";
        skill_descriptions[$skill[Magic Sweat]] = "+100 DA, +10 DR buff";
        skill_descriptions[$skill[Adipose Polymers]] = "+100 DA, +10 DR passive";
        skill_descriptions[$skill[Mind Bullets]] = "stunning spell";
        
        skill [int] desired_skill_order;
        
        desired_skill_order.listAppend($skill[Extra Gall Bladder]); //Passive - +100% adventures from food
        desired_skill_order.listAppend($skill[Extra Kidney]); //Passive - +100% Adventures from booze
        desired_skill_order.listAppend($skill[Internal Soda Machine]); //Passive - Spend 20 meat to recover 10 MP
        
        desired_skill_order.listAppend($skill[Squid Glands]); //-10% combat rate buff
        if (my_primestat() == $stat[muscle])
        {
            desired_skill_order.listAppend($skill[Steroid Bladder]); //Buff - +50% Muscle
            desired_skill_order.listAppend($skill[Extra Muscles]); //Passive - +50% Muscle
        }
        else if (my_primestat() == $stat[moxie])
        {
            desired_skill_order.listAppend($skill[Self-Combing Hair]); //Buff - +50% Moxie
            desired_skill_order.listAppend($skill[Hypno-Eyes]); //Passive - +50% Moxie
        }
        else if (my_primestat() == $stat[Mysticality])
        {
            desired_skill_order.listAppend($skill[Intracranial Eye]); //Buff - +50% Mysticality
            desired_skill_order.listAppend($skill[Extra Brain]); //Passive - +50% Mysticality
        }
        
        desired_skill_order.listAppend($skill[Extremely Punchable Face]); //+30 ML buff
        desired_skill_order.listAppend($skill[Magnetic Ears]); //15% item buff
        desired_skill_order.listAppend($skill[Sucker Fingers]); //15% item passive
        desired_skill_order.listAppend($skill[Firefly Abdomen]); //+10% combat rate buff
        
        desired_skill_order.listAppend($skill[Throat Refrigerant]); //Combat - Cold damage
        desired_skill_order.listAppend($skill[Flappy Ears]); //Buff - +2 resistance to all elements
        desired_skill_order.listAppend($skill[Metallic Skin]); //Passive - +2 resistance to all elements
        
        
        desired_skill_order.listAppend($skill[Bone Springs]); //+20% init buff
        desired_skill_order.listAppend($skill[Backwards Knees]); //+20% init passive
        
        desired_skill_order.listAppend($skill[Magic Sweat]); //Buff - Damage Absorption +100 - Damage Reduction: 10
        desired_skill_order.listAppend($skill[Adipose Polymers]); //Passive - Damage Absorption +100 - Damage Reduction: 10
        desired_skill_order.listAppend($skill[Mind Bullets]); //Combat - Stuns opponent
        desired_skill_order.listAppend($skill[Self-Combing Hair]); //Buff - +50% Moxie
        desired_skill_order.listAppend($skill[Hypno-Eyes]); //Passive - +50% Moxie
        desired_skill_order.listAppend($skill[Steroid Bladder]); //Buff - +50% Muscle
        desired_skill_order.listAppend($skill[Extra Muscles]); //Passive - +50% Muscle
        desired_skill_order.listAppend($skill[Intracranial Eye]); //Buff - +50% Mysticality
        desired_skill_order.listAppend($skill[Extra Brain]); //Passive - +50% Mysticality
        
        //desired_skill_order.listAppend($skill[Boiling Tear Ducts]); //Combat - Hot damage
        //desired_skill_order.listAppend($skill[Projectile Salivary Glands]); //Combat - Sleaze damage
        //desired_skill_order.listAppend($skill[Translucent Skin]); //Combat - Spooky damage
        //desired_skill_order.listAppend($skill[Skunk Glands]); //Combat - Stench damage
        
        string [int] description;
        
        boolean [skill] already_displayed_skill;
        foreach key, s in desired_skill_order
        {
            if (s.have_skill())
                continue;
            if (($skills[Magnetic Ears,Sucker Fingers,Extremely Punchable Face,Firefly Abdomen,Bone Springs,Squid Glands,Backwards Knees] contains s) && get_property_int("falloutShelterLevel") < 6) //not yet
                continue;
            if (already_displayed_skill[s])
                continue;
            already_displayed_skill[s] = true;
            string line = s + ": " + skill_descriptions[s];
            if (skill_rad_cost[s] > $item[rad].available_amount())
                line = HTMLGenerateSpanFont(line, "gray");
            description.listAppend(line);
        }
        
		resource_entries.listAppend(ChecklistEntryMake(204, "__item rad", "shop.php?whichshop=mutate", ChecklistSubentryMake(pluralise(rad) + " available", "", description), 8));
    }
    if (get_property_int("falloutShelterLevel") >= 3 && !get_property_boolean("_falloutShelterSpaUsed"))
    {
        //FIXME sync with above
    }
}
