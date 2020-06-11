import "relay/Guide/Support/LocationAvailable.ash"
import "relay/Guide/Support/Equipment Requirement.ash"
import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Support/Statics 2.ash"
import "relay/Guide/Support/Ingredients.ash"
import "relay/Guide/Support/Counter.ash"



string HTMLGenerateFutureTextByLocationAvailability(string base_text, location place)
{
    if (!place.locationAvailable() && place != $location[none])
    {
        base_text = HTMLGenerateSpanOfClass(base_text, "r_future_option");
    }
    return base_text;
}

string HTMLGenerateFutureTextByLocationAvailability(location place)
{
	return HTMLGenerateFutureTextByLocationAvailability(place.to_string(), place);
}

//Alternate name, since last time I tried making this function then discovered the "generate future text" options which I cleverly named in such a way that I would never find it
string HTMLGreyOutIfLocationUnavailable(string source, location l)
{
    return HTMLGenerateFutureTextByLocationAvailability(source, l);
}
string HTMLBoldIfTrue(string base_text, boolean conditional)
{
    if (conditional)
        return HTMLGenerateSpanOfClass(base_text, "r_bold");
    return base_text;
}


boolean can_equip_replacement(item it)
{
    if (it.equipped_amount() > 0)
        return true;
    if (it.item_type() == "chefstaff" && !($skill[Spirit of Rigatoni].have_skill() || my_class() == $class[Avatar of Jarlsberg] || (my_class() == $class[sauceror] && $item[special sauce glove].equipped_amount() > 0)))
    	return false;
    boolean can_equip = it.can_equip();
    if (can_equip)
        return true;
    if (my_class() == $class[pastamancer])
    {
        //Bind Undead Elbow Macaroni -> equalises muscle
        //Bind Penne Dreadful -> equalises moxie
        EquipmentStatRequirement requirement = it.StatRequirementForEquipment();
        
        if (requirement.requirement_stat == $stat[none])
            return true;
        if (my_basestat(requirement.requirement_stat) >= requirement.requirement_amount)
            return true;
        if (requirement.requirement_stat == $stat[mysticality])
            return false;
        
        if (requirement.requirement_stat == $stat[muscle])
        {
            if ($skill[bind undead elbow macaroni].have_skill() && my_basestat($stat[mysticality]) >= requirement.requirement_amount)
                return true;
        }
        else if (requirement.requirement_stat == $stat[moxie])
        {
            if ($skill[Bind Penne Dreadful].have_skill() && my_basestat($stat[mysticality]) >= requirement.requirement_amount)
                return true;
        }
    }
    return can_equip;
}

boolean can_equip_outfit(string outfit_name)
{
    if (!have_outfit_components(outfit_name))
        return false;
    item [int] outfit_pieces = outfit_pieces(outfit_name);
    foreach key, it in outfit_pieces
    {
        if (!it.can_equip_replacement())
            return false;
    }
    return true;
}


//Probably not a good place for it:
boolean asdonMartinFailsFuelableTestsPrivate(item craft, boolean [item] ingredients_blacklisted, boolean [item] crafts_seen)
{
    //if ($items[wad of dough,flat dough] contains craft) return false;
    if (craft.craft_type().contains_text("(fancy)"))
        return true;
    crafts_seen[craft] = true;
    boolean all_npc = true;
    foreach it, amount in craft.get_ingredients_fast()
    {
        //print_html(craft + ": " + it);
        if (ingredients_blacklisted[it]) return true;
        if (!it.is_npc_item())
            all_npc = false;
        
        if (it.item_amount() >= amount) continue;
        if (crafts_seen[it]) //wad of dough, flat dough, jolly roger charrrm
        {
            continue;
        }
        if (it.asdonMartinFailsFuelableTestsPrivate(ingredients_blacklisted, crafts_seen))
            return true;
    }
    if (craft.get_ingredients_fast().count() == 0)
        all_npc = false;
    if (all_npc && crafts_seen.count() == 0) //hmm... what if it's a second level all-NPC?
    {
        return true;
    }
    return false;
}

boolean asdonMartinFailsFuelableTests(item craft, boolean [item] ingredients_blacklisted)
{
    boolean [item] crafts_seen; //slower than a "last item" test, but necessary (spooky wads)
    return asdonMartinFailsFuelableTestsPrivate(craft, ingredients_blacklisted, crafts_seen);
}

item [int] asdonMartinGenerateListOfFuelables()
{
    item [int] fuelables;
    boolean [item] blacklist;
    if (!QuestState("questL11Black").finished) //FIXME no
        blacklist[$item[blackberry]] = true; //FIXME test properly?
    blacklist[$item[stunt nuts]] = true;
    blacklist[$item[wet stew]] = true; //FIXME I guess maybe not after
    blacklist[$item[goat cheese]] = true;
    blacklist[$item[turkey blaster]] = true;
    blacklist[$item[hot wing]] = true;
    blacklist[$item[glass of goat's milk]] = true;
    blacklist[$item[soft green echo eyedrop antidote martini]] = true; //if it's not created, FIXME
    blacklist[$item[warm gravy]] = true; //don't steal my boat
    foreach it in $items[Falcon&trade; Maltese Liquor, hardboiled egg]
        blacklist[it] = true; //don't steal my -combat
    blacklist[$item[loaf of soda bread]] = true; //elsewhere
    foreach it in $items[hot buttered roll,ketchup,catsup]
        blacklist[it] = true; //hermit
        
    //These aren't directly feedable, but indirectly make things:
    blacklist[$item[source essence]] = true; //that's silly
    blacklist[$item[white pixel]] = true; //no!
    blacklist[$item[cashew]] = true;
    
    if (my_path_id() != PATH_LICENSE_TO_ADVENTURE && inebriety_limit() > 0) //FIXME the test for can drink just about
    {
        foreach it in $items[bottle of gin,bottle of rum,bottle of vodka,bottle of whiskey,bottle of tequila] //too useful for crafting?
            blacklist[it] = true;
    }
    foreach it in $items[bottle of Calcutta Emerald,bottle of Lieutenant Freeman,bottle of Jorge Sinsonte,bottle of Definit,bottle of Domesticated Turkey,boxed champagne,bottle of Ooze-O,bottle of Pete's Sake,tangerine,kiwi,cocktail onion,kumquat,tonic water,raspberry] //nash crosby's still's results isn't feedable
        blacklist[it] = true;
    foreach it in __pvpable_food_and_drinks
    {
        if (blacklist[it]) continue;
        if (it.is_npc_item()) continue;
        if (it.historical_price() >= 20000) continue;
        if (it.item_amount() == 0)
        {
            if (it.creatable_amount() == 0)
                continue;
            if (it.asdonMartinFailsFuelableTests(blacklist))
            {
                continue;
            }
        }
        if (my_path_id() == PATH_LICENSE_TO_ADVENTURE && false)
        {
            if (it.inebriety > 0 && it.image == "martini.gif")
                continue;
        }
        if (it.item_cannot_be_asdon_martined_because_it_was_purchased_from_a_store()) //the asdon martin wishes it was an AE86, so those work
        {
            //print_html("Rejecting " + it);
            continue;
        }
        /*int [item] ingredients = it.get_ingredients_fast();
        if (ingredients.count() > 0)
        {
            boolean reject = false;
            //Various things count as being from a "store":
            foreach it in lookupItems("yellow pixel,handful of barley,spacegate research")
            {
                if (ingredients[it] > 0)
                {
                    reject = true;
                    break;
                }
            }
            if (reject)
                continue;
        }*/
        float average_adventures = it.averageAdventuresForConsumable();
        if (average_adventures == 0.0)
            continue;
            
        float soda_bread_efficiency = to_float($item[wad of dough].npc_price() + $item[soda water].npc_price()) / 6.0;
        if (soda_bread_efficiency < 1.0) soda_bread_efficiency = 100000.0;
        if (it.autosell_price() > 0 && it.autosell_price().to_float() / average_adventures > soda_bread_efficiency)
        {
            continue;
        }
        fuelables.listAppend(it);
    }
    sort fuelables by -value.averageAdventuresForConsumable() * ((value.asdonMartinFailsFuelableTests(blacklist) ? 0 : value.creatable_amount()) + value.item_amount());
    return fuelables;
}




boolean craftableUsingOnlyActiveNPCStoresPrivate(item it, boolean [item] crafts_seen)
{
    if (it.npc_price() > 0)
        return true;
    
    int [item] ingredients = it.get_ingredients_fast();
    if (ingredients.count() == 0) return false;
    
    if (crafts_seen[it])
        return true;
    
    crafts_seen[it] = true;
    
    foreach ingredient in ingredients
    {
        if (!craftableUsingOnlyActiveNPCStoresPrivate(ingredient, crafts_seen))
        {
            return false;
        }
    }
    return true;
}

boolean craftableUsingOnlyActiveNPCStores(item it)
{
    boolean [item] crafts_seen;
    return craftableUsingOnlyActiveNPCStoresPrivate(it, crafts_seen);
}


int CatBurglarChargesLeftToday()
{
    //FIXME this is totally wrong I think, fix this mafia
    int charge = get_property_int("_catBurglarCharge");
    
    int heists_gained_today = 0;
    int limit = 10;
    int c = charge;
    while (c >= limit)
    {
        heists_gained_today += 1;
        c -= limit;
        limit *= 2;
    }
    int heists_complete = get_property_int("_catBurglarHeistsComplete");
    //print_html("heists_gained_today = " + heists_gained_today + ", heists_complete = " + heists_complete); 
    return get_property_int("catBurglarBankHeists") + heists_gained_today - heists_complete;
}


int PathCommunityServiceEstimateTurnsTakenForTask(string service_name)
{
    int turns = 60;
    if (service_name == "Donate Blood")
    {
        turns = 60 - (my_maxhp() - (my_buffedstat($stat[muscle]) + 3)) / 30;
    }
    else if (service_name == "Coil Wire")
    {
        turns = 60;
    }
    else if (service_name == "Make Margaritas")
    {
    	float item_drop = numeric_modifier("Item Drop");
        //Mafia adds item drop modifiers depending on our location.
        //set_location() is slow, we want to avoid it.
        //Manually correct:
        if ($skill[Speluck].have_skill() && my_location().environment == "underground")
        {
        	item_drop -= 5.0;
            if ($effect[Steely-Eyed Squint].have_effect() > 0)
            	item_drop -= 5.0;
        }
        turns = 60 - (floor(item_drop / 30) + floor(numeric_modifier("Booze Drop") / 15));
    }
    else if (service_name == "Feed The Children (But Not Too Much)" || service_name == "Build Playground Mazes" || service_name == "Feed Conspirators")
    {
        stat using_stat;
        if (service_name == "Feed The Children (But Not Too Much)")
        {
            using_stat = $stat[muscle];
        }
        else if (service_name == "Build Playground Mazes")
        {
            using_stat = $stat[mysticality];
        }
        else if (service_name == "Feed Conspirators")
        {
            using_stat = $stat[moxie];
        }
        int basestat = my_basestat(using_stat);
        boolean relevant_thrall_active = false;
        if (my_thrall() == $thrall[Elbow Macaroni] && using_stat == $stat[muscle])
        {
            basestat = my_basestat($stat[mysticality]);
            relevant_thrall_active = true;
        }
        if (my_thrall() == $thrall[Penne Dreadful] && using_stat == $stat[moxie])
        {
            basestat = my_basestat($stat[mysticality]);
            relevant_thrall_active = true;
        }
        
        turns = 60 - (my_buffedstat(using_stat) - basestat) / 30;
    }
    else if (service_name == "Reduce Gazelle Population")
    {
        float modifier_1 = numeric_modifier("Weapon Damage");
        float modifier_2 = numeric_modifier("Weapon Damage Percent");
        
        foreach s in $slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3,familiar]
        {
        	item it = s.equipped_item();
            if (it.to_slot() != $slot[weapon]) continue;
            int power = it.get_power();
            float addition = to_float(power) * 0.15;
            
            modifier_1 -= addition;
        }
        if ($effect[bow-legged swagger].have_effect() > 0)
        {
            modifier_1 *= 2;
            modifier_2 *= 2;
        }
        turns = 60 - (floor(modifier_1 / 50 + 0.001) + floor(modifier_2 / 50 + 0.001));
    }
    else if (service_name == "Make Sausage")
    {
        turns = 60 - (floor(numeric_modifier("Spell Damage") / 50 + 0.001) + floor(numeric_modifier("Spell Damage Percent") / 50 + 0.001));
    }
    else if (service_name == "Clean Steam Tunnels")
    {
        turns = 60 - round(numeric_modifier("Hot Resistance"));
    }
    else if (service_name == "Breed More Collies")
    {
        int current_familiar_weight = my_familiar().effective_familiar_weight() + round(numeric_modifier("familiar weight"));
        turns = 60 - floor(current_familiar_weight / 5);
    }
    else if (service_name == "Be a Living Statue")
    {
        int combat_rate_raw = round(numeric_modifier("Combat Rate"));
        int combat_rate_inverse = 0;
        if (combat_rate_raw < 0) combat_rate_inverse = -combat_rate_raw;
        if (combat_rate_inverse > 25) combat_rate_inverse = (combat_rate_inverse - 25) * 5 + 25;
        turns = 60 - (combat_rate_inverse / 5) * 3;
    }

    turns = clampi(turns, 1, 60);

    return turns;
}



Record KramcoSausageFightInformation 
{
    boolean goblin_will_appear;
    int turns_to_next_guaranteed_fight;
    float probability_of_sausage_fight;
};

KramcoSausageFightInformation KramcoCalculateSausageFightInformation() {
    KramcoSausageFightInformation information;
    int goblinsFought = get_property_int("_sausageFights");    
    int turnsSinceLastGoblin = total_turns_played() - get_property_int("_lastSausageMonsterTurn");

    int nextGuaranteedGoblin = 4 + goblinsFought * 3 + MAX(0, goblinsFought - 5) * MAX(0, goblinsFought - 5) * MAX(0, goblinsFought - 5);
    int turnsToNextGuaranteedFight = MAX(0, nextGuaranteedGoblin - turnsSinceLastGoblin);
    
    if (goblinsFought == 0) {
        turnsToNextGuaranteedFight = 0;
    }

    int goblinMultiplier = MAX(0, goblinsFought - 5);
    float probabilityOfFight = to_float(turnsSinceLastGoblin + 1) / (5.0 + to_float(goblinsFought) * 3.0 + to_float(goblinMultiplier) * to_float(goblinMultiplier) * to_float(goblinMultiplier));

    information.turns_to_next_guaranteed_fight = MAX(0, nextGuaranteedGoblin - turnsSinceLastGoblin);
    information.probability_of_sausage_fight = clampf(probabilityOfFight, 0.0, 1.0);
    information.goblin_will_appear = (turnsToNextGuaranteedFight == 0);
    
    return information;
}
