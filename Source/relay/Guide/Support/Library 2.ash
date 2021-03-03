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
boolean asdonMartinFailsFuelableTestsPrivate(item craft, boolean [item] ingredients_blocklisted, boolean [item] crafts_seen)
{
    //if ($items[wad of dough,flat dough] contains craft) return false;
    if (craft.craft_type().contains_text("(fancy)"))
        return true;
    crafts_seen[craft] = true;
    boolean all_npc = true;
    foreach it, amount in craft.get_ingredients_fast()
    {
        //print_html(craft + ": " + it);
        if (ingredients_blocklisted[it]) return true;
        if (!it.is_npc_item())
            all_npc = false;
        
        if (it.item_amount() >= amount) continue;
        if (crafts_seen[it]) //wad of dough, flat dough, jolly roger charrrm
        {
            continue;
        }
        if (it.asdonMartinFailsFuelableTestsPrivate(ingredients_blocklisted, crafts_seen))
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

boolean asdonMartinFailsFuelableTests(item craft, boolean [item] ingredients_blocklisted)
{
    boolean [item] crafts_seen; //slower than a "last item" test, but necessary (spooky wads)
    return asdonMartinFailsFuelableTestsPrivate(craft, ingredients_blocklisted, crafts_seen);
}

item [int] asdonMartinGenerateListOfFuelables()
{
    item [int] fuelables;
    boolean [item] blocklist;
    if (!QuestState("questL11Black").finished) //FIXME no
        blocklist[$item[blackberry]] = true; //FIXME test properly?
    blocklist[$item[stunt nuts]] = true;
    blocklist[$item[wet stew]] = true; //FIXME I guess maybe not after
    blocklist[$item[goat cheese]] = true;
    blocklist[$item[turkey blaster]] = true;
    blocklist[$item[hot wing]] = true;
    blocklist[$item[glass of goat's milk]] = true;
    blocklist[$item[soft green echo eyedrop antidote martini]] = true; //if it's not created, FIXME
    blocklist[$item[warm gravy]] = true; //don't steal my boat
    foreach it in $items[Falcon&trade; Maltese Liquor, hardboiled egg]
        blocklist[it] = true; //don't steal my -combat
    blocklist[$item[loaf of soda bread]] = true; //elsewhere
    foreach it in $items[hot buttered roll,ketchup,catsup]
        blocklist[it] = true; //hermit
        
    //These aren't directly feedable, but indirectly make things:
    blocklist[$item[source essence]] = true; //that's silly
    blocklist[$item[white pixel]] = true; //no!
    blocklist[$item[cashew]] = true;
    
    if (my_path_id() != PATH_LICENSE_TO_ADVENTURE && inebriety_limit() > 0) //FIXME the test for can drink just about
    {
        foreach it in $items[bottle of gin,bottle of rum,bottle of vodka,bottle of whiskey,bottle of tequila] //too useful for crafting?
            blocklist[it] = true;
    }
    foreach it in $items[bottle of Calcutta Emerald,bottle of Lieutenant Freeman,bottle of Jorge Sinsonte,bottle of Definit,bottle of Domesticated Turkey,boxed champagne,bottle of Ooze-O,bottle of Pete's Sake,tangerine,kiwi,cocktail onion,kumquat,tonic water,raspberry] //nash crosby's still's results isn't feedable
        blocklist[it] = true;
    foreach it in __pvpable_food_and_drinks
    {
        if (blocklist[it]) continue;
        if (it.is_npc_item()) continue;
        if (it.historical_price() >= 20000) continue;
        if (it.item_amount() == 0)
        {
            if (it.creatable_amount() == 0)
                continue;
            if (it.asdonMartinFailsFuelableTests(blocklist))
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
            foreach it in $items[yellow pixel,handful of barley,spacegate research]
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
        if (it.autosell_price() > 0 && it.autosell_price().to_float() / average_adventures > soda_bread_efficiency && my_path_id() != PATH_EXPLOSIONS)
        {
            continue;
        }
        fuelables.listAppend(it);
    }
    sort fuelables by -value.averageAdventuresForConsumable() * ((value.asdonMartinFailsFuelableTests(blocklist) ? 0 : value.creatable_amount()) + value.item_amount());
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
        turns = 60 - (floor(modifier_1 / 50) + floor(modifier_2 / 50));
    }
    else if (service_name == "Make Sausage")
    {
        turns = 60 - (floor(numeric_modifier("Spell Damage") / 50) + floor(numeric_modifier("Spell Damage Percent") / 50));
    }
    else if (service_name == "Clean Steam Tunnels")
    {
        turns = 60 - numeric_modifier("Hot Resistance");
    }
    else if (service_name == "Breed More Collies")
    {
        int current_familiar_weight = my_familiar().effective_familiar_weight() + numeric_modifier("familiar weight");
        turns = 60 - floor(current_familiar_weight / 5);
    }
    else if (service_name == "Be a Living Statue")
    {
        float combat_rate_raw = numeric_modifier("Combat Rate");
        int combat_rate_inverse = 0;
        if (combat_rate_raw < 0) combat_rate_inverse = -combat_rate_raw;
        if (combat_rate_inverse > 25) combat_rate_inverse = (combat_rate_inverse - 25) * 5 + 25;
        turns = 60 - floor(combat_rate_inverse / 5) * 3;
    }
    
    turns = clampi(turns, 1, 60);
    
    return turns;
}



Record KramcoSausageFightInformation 
{
    boolean goblin_will_appear;
    int turns_to_next_guaranteed_fight;
    float probability_of_sausage_fight;
    float average_turns_to_next_sausage_fight_if_continually_equipped;
};

int KramcoCalculateTurnWillAlwaysSeeGoblin(int sausage_fights)
{
    if (sausage_fights <= 0)
    	return 0;
	int turn_will_always_see_goblin = 5 + sausage_fights * 3 + powi(max(0, sausage_fights - 5), 3) - 1;
    return turn_will_always_see_goblin;
}

KramcoSausageFightInformation KramcoCalculateSausageFightInformation()
{
    KramcoSausageFightInformation information;
    information.average_turns_to_next_sausage_fight_if_continually_equipped = -1.0;
    int last_sausage_turn = get_property_int("_lastSausageMonsterTurn"); //FIXME
    int sausage_fights = get_property_int("_sausageFights");
    
    
    
    //These ceilings are not correct; they are merely what I have spaded so far. The actual values are higher.
    int delta = total_turns_played() - last_sausage_turn;
    
    int turn_will_always_see_goblin = -1;
    
    
    boolean use_formula = true;
    if (use_formula)
    {
    	//use formula, spaded by unknown:
        //seems to match the ceiling data I have
        //this line is fun - can you find the character gremlin that causes script parsing to break?
        //turn_will_always_see_goblin = 5 + sausage_fights * 3 + powi(max(0, sausage_fights − 5), 3) - 1; //-1 for our system
        turn_will_always_see_goblin = KramcoCalculateTurnWillAlwaysSeeGoblin(sausage_fights);
    }
    else
    {
        int [int] observed_ceilings = {0, 7, 10, 13, 16, 19, 23, 33, 54, 93, 154, 219, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220};
        //0,7,10,13,16,19,23,33,55,94,155,222,222,222,222,222,222,222,222,222,222,222,222,222,222,222,222,222,222,222
        
        turn_will_always_see_goblin = observed_ceilings[sausage_fights];
    	if (!(observed_ceilings contains sausage_fights))
     	   turn_will_always_see_goblin = -1;
    }
    
    
    
    information.turns_to_next_guaranteed_fight = MAX(0, turn_will_always_see_goblin - delta);
    //Goblins do not appear on the same turn as semi-rares, anywhere.
    if (information.turns_to_next_guaranteed_fight == 0 && CounterLookup("Semi-rare").CounterGetNextExactTurn() == 0)
    	information.turns_to_next_guaranteed_fight += 1;
    
    if (turn_will_always_see_goblin == -1)
         information.turns_to_next_guaranteed_fight = -1;
    
    if (turn_will_always_see_goblin > 1)
    {
    	if (use_formula)
        {
        	information.probability_of_sausage_fight = clampf(to_float(delta + 1) / to_float(turn_will_always_see_goblin + 1), 0.0, 1.0);
        }
        else
        {
            //This is probably wrong?
            float probability_each_incorrect = 1.0 / to_float(turn_will_always_see_goblin - 1);
            information.probability_of_sausage_fight = clampf((delta + 1) * probability_each_incorrect, 0.0, 1.0);
        }
    }
    information.goblin_will_appear = (information.turns_to_next_guaranteed_fight == 0);
    
    //calculate average_turns_to_next_sausage_fight_if_continually_equipped:
    if (true)
    {
        /*if (debug)
        {
        	print_html("Calculating average turns...");
        }*/
    	//Calculate average turns to next sausage fight if continually equipped:
    	//Method:
    	//Start at current turn
        //Calculate probability of not encountering a goblin this turn. Multiply by previous value. If value is <= 0.5, stop. Otherwise, increment turn and loop.
        //Then linerally interpret the result vs 0.5.
        float failure_likelyhood_so_far = 1.0;
        int calculation_delta_turn = 0;
        int breakout = 500;
        while (breakout > 0)
        {
            /*if (debug)
            {
                print_html("calculation_delta_turn = " + calculation_delta_turn + ", failure_likelyhood_so_far = " + failure_likelyhood_so_far);
            }*/
        	breakout -= 1;
            float previous_failure_likelyhood = failure_likelyhood_so_far;
        	float probability_of_sausage_fight = clampf(to_float((calculation_delta_turn + delta) + 1) / to_float(turn_will_always_see_goblin + 1), 0.0, 1.0);
            failure_likelyhood_so_far *= (1.0 - probability_of_sausage_fight);
            if (failure_likelyhood_so_far <= 0.5)
            {
            	//At critical point.
                //Linear interpolation that is probably wrong, I never paid attention to statistics:
                float average_turns = calculation_delta_turn;
                float to_half = (previous_failure_likelyhood - 0.5);
                float total_delta = previous_failure_likelyhood - failure_likelyhood_so_far;
                
                
                /*if (debug)
                {
                    print_html("vfailure_likelyhood_so_far = " + failure_likelyhood_so_far + ", average_turns before changing = " + average_turns);
                }*/
                if (total_delta != 0.0)
	                average_turns += clampf(to_half / total_delta, 0.0, 1.0);
                 
                 information.average_turns_to_next_sausage_fight_if_continually_equipped = average_turns;
                 break;
            }
            else
            {
            	calculation_delta_turn += 1;
            }
        }
    }
    
    /*if (debug)
    {
        print_html("sausage_fights = " + sausage_fights + " delta = " + delta + " turn_will_always_see_goblin = " + turn_will_always_see_goblin);
        print_html("information.turns_to_next_guaranteed_fight = " + information.turns_to_next_guaranteed_fight);
        print_html("information.probability_of_sausage_fight = " + information.probability_of_sausage_fight);
        print_html("information.average_turns_to_next_sausage_fight_if_continually_equipped = " + information.average_turns_to_next_sausage_fight_if_continually_equipped);
    }*/
    return information;
}
