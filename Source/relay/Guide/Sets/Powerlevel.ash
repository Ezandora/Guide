RegisterTaskGenerationFunction("SPowerlevelGenerateTasks");
void SPowerlevelGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (__misc_state["need to level"])
	{
        string url = "";
		int mcd_max_limit = 10;
		boolean have_mcd = false;
		if (canadia_available() || knoll_available() || gnomads_available() && __misc_state["desert beach available"] || in_bad_moon())
			have_mcd = true;
        if (canadia_available())
        {
            mcd_max_limit = 11;
            url = "place.php?whichplace=canadia&action=lc_mcd";
        }
        else if (knoll_available())
        {
            if ($item[detuned radio].available_amount() > 0)
                url = "inventory.php?which=3";
            else
                url = "shop.php?whichshop=gnoll";
        }
        else if (gnomads_available())
            url = "gnomes.php?place=machine";
        //FIXME URLs for the other ones
		if (current_mcd() < mcd_max_limit && have_mcd && monster_level_adjustment() < 150 && !in_bad_moon())
		{
			optional_task_entries.listAppend(ChecklistEntryMake("__item detuned radio", url, ChecklistSubentryMake("Set monster control device to " + mcd_max_limit, "", roundForOutput(mcd_max_limit * __misc_state_float["ML to mainstat multiplier"], 2) + " mainstats/turn")));
		}
	}
    
	if (__misc_state["need to level"] && my_path_id() != PATH_COMMUNITY_SERVICE)
	{
		ChecklistSubentry subentry;
		
		int main_substats = my_basestat(my_primesubstat());
		int substats_remaining = substatsForLevel(my_level() + 1) - main_substats;
		
		subentry.header = "Level to " + (my_level() + 1);
		
		subentry.entries.listAppend("Gain " + pluralise(substats_remaining, "substat", "substats") + ".");
        
        string url = "";
        
        boolean spooky_airport_unlocked = __misc_state["spooky airport available"];
        boolean stench_airport_unlocked = __misc_state["stench airport available"];
        
        if (__misc_state["Chateau Mantegna available"] && __misc_state_int["free rests remaining"] > 0)
            url = "place.php?whichplace=chateau";
        else if (stench_airport_unlocked && monster_level_adjustment() >= 150)
            url = $location[Uncle Gator's Country Fun-Time Liquid Waste Sluice].getClickableURLForLocation();
        else if (spooky_airport_unlocked && ($effect[jungle juiced].have_effect() > 0 || ($item[jungle juice].available_amount() > 0 && availableDrunkenness() > 0 && __misc_state["can drink just about anything"])))
            url = $location[the deep dark jungle].getClickableURLForLocation();
        else if (__misc_state["Chateau Mantegna available"])
            url = "place.php?whichplace=chateau";
        else if (__misc_state["sleaze airport available"])
            url = $location[sloppy seconds diner].getClickableURLForLocation();
        else if (spooky_airport_unlocked)
            url = $location[the deep dark jungle].getClickableURLForLocation();
        else if ($item[GameInformPowerDailyPro walkthru].available_amount() > 0)
            url = $location[video game level 1].getClickableURLForLocation();
        else if (my_primestat() == $stat[muscle] && $location[the haunted billiards room].locationAvailable())
            url = $location[the haunted gallery].getClickableURLForLocation();
        else if (my_primestat() == $stat[mysticality] && $location[the haunted bedroom].locationAvailable())
            url = $location[the haunted bathroom].getClickableURLForLocation();
        else if (my_primestat() == $stat[moxie] && $location[the haunted bedroom].locationAvailable())
            url = $location[the haunted ballroom].getClickableURLForLocation();
            
        
        //133.33333333333333 meat per stat
        int maximum_allowed_to_donate = 10000 * my_level();
        int cost_to_donate_for_level = ceil(substats_remaining.to_float() / 1.5) * 200.0;
        int min_cost_to_donate_for_level = ceil(substats_remaining.to_float() / 2.0) * 200.0;
        if (min_cost_to_donate_for_level <= my_meat() && min_cost_to_donate_for_level <= maximum_allowed_to_donate)
        {
            string statue_name = "";
            if (my_primestat() == $stat[muscle] && $item[boris's key].available_amount() > 0)
            {
                statue_name = "Boris";
                if (cost_to_donate_for_level < 2000 || cost_to_donate_for_level < my_meat() * 0.2)
                    url = "da.php?place=gate1";
            }
            else if (my_primestat() == $stat[mysticality] && $item[jarlsberg's key].available_amount() > 0 && my_path_id() != PATH_AVATAR_OF_JARLSBERG)
            {
                statue_name = "Jarlsberg";
                if (cost_to_donate_for_level < 2000 || cost_to_donate_for_level < my_meat() * 0.2)
                    url = "da.php?place=gate2";
            }
            else if (my_primestat() == $stat[moxie] && $item[sneaky pete's key].available_amount() > 0 && my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
            {
                statue_name = "Sneaky Pete";
                if (cost_to_donate_for_level < 2000 || cost_to_donate_for_level < my_meat() * 0.2)
                    url = "da.php?place=gate3";
            }
                
            if (statue_name != "" && !(!in_ronin() && cost_to_donate_for_level > 20000))
            {
                buffer line = "Possibly donate ".to_buffer();
                if (cost_to_donate_for_level == min_cost_to_donate_for_level)
                    line.append(cost_to_donate_for_level);
                else
                {
                    line.append(min_cost_to_donate_for_level);
                    line.append(" to ");
                    line.append(cost_to_donate_for_level);
                }
                line.append(" meat to the statue of ");
                line.append(statue_name);
                line.append(".");
                subentry.entries.listAppend(line);
                
            }
        }
        
        
        
        string image_name = "player character";
        
        if (false)
        {
            //vertically less imposing:
            //disabled for now - player avatars look better. well, sneaky pete's avatar looks better...
            image_name = "mini-adventurer blank female";
            
            string [class] class_images;
            class_images[$class[seal clubber]] = "mini-adventurer seal clubber female";
            class_images[$class[turtle tamer]] = "mini-adventurer turtle tamer female";
            class_images[$class[pastamancer]] = "mini-adventurer pastamancer female";
            class_images[$class[sauceror]] = "mini-adventurer sauceror female";
            class_images[$class[disco bandit]] = "mini-adventurer disco bandit female";
            class_images[$class[accordion thief]] = "mini-adventurer accordion thief female";
            
            if (class_images contains my_class())
                image_name = class_images[my_class()];
        }
		
		
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, 11));
	}
}