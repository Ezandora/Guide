boolean [item] __iotms_usable;

void initialiseIOTMsUsable()
{
    foreach key in __iotms_usable
        remove __iotms_usable[key];
    if (in_bad_moon())
        return;
    
    if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
    {
        int [item] campground = get_campground();
        //Campground items:
        foreach it in $items[source terminal, haunted doghouse, Witchess Set, potted tea tree, portable mayo clinic, Little Geneticist DNA-Splicing Lab, cornucopia]
        {
            if (campground contains it)
                __iotms_usable[it] = true;
        }
        if (campground contains $item[Asdon Martin keyfob])
            __iotms_usable[$item[Asdon Martin keyfob]] = true;
    }
    if (get_property_boolean("hasDetectiveSchool"))
        __iotms_usable[$item[detective school application]] = true;
    if (get_property_boolean("chateauAvailable") && my_path_id() != PATH_EXPLOSIONS)
        __iotms_usable[$item[Chateau Mantegna room key]] = true;
    if (get_property_boolean("barrelShrineUnlocked"))
        __iotms_usable[$item[shrine to the Barrel god]] = true;
    if (get_property_boolean("snojoAvailable"))
        __iotms_usable[$item[X-32-F snowman crate]] = true;
    if (get_property_boolean("telegraphOfficeAvailable"))
        __iotms_usable[$item[LT&T telegraph office deed]] = true;
    if (get_property_boolean("lovebugsUnlocked") && $item[hand turkey outline].is_unrestricted())
        __iotms_usable[$item[bottle of lovebug pheromones]] = true;
    if (get_property_boolean("loveTunnelAvailable"))
        __iotms_usable[$item[heart-shaped crate]] = true;
    if (get_property_boolean("spacegateAlways") || get_property_boolean("_spacegateToday"))
        __iotms_usable[$item[Spacegate access badge]] = true;
    if (my_path_id() == PATH_EXPLOSIONS)
    	__iotms_usable[$item[Spacegate access badge]] = false;
    if (get_property_boolean("gingerbreadCityAvailable") || get_property_boolean("_gingerbreadCityToday"))
        __iotms_usable[$item[Build-a-City Gingerbread kit]] = true;
    if ($item[kremlin's greatest briefcase].available_amount() > 0)
        __iotms_usable[$item[kremlin's greatest briefcase]] = true;
    if (get_property_boolean("horseryAvailable"))
        __iotms_usable[$item[Horsery contract]] = true;
    if ($item[genie bottle].available_amount() > 0)
        __iotms_usable[$item[genie bottle]] = true;
    if ($item[portable pantogram].available_amount() > 0)
        __iotms_usable[$item[portable pantogram]] = true;
    if ($item[January's Garbage Tote].available_amount() > 0)
        __iotms_usable[$item[January's Garbage Tote]] = true;
    if (get_property_boolean("coldAirportAlways") || get_property_boolean("_coldAirportToday"))
        __iotms_usable[$item[Airplane charter: The Glaciest]] = true;
    if (get_property_boolean("hotAirportAlways") || get_property_boolean("_hotAirportToday"))
        __iotms_usable[$item[Airplane charter: That 70s Volcano]] = true;
    if (get_property_boolean("sleazeAirportAlways") || get_property_boolean("_sleazeAirportToday"))
        __iotms_usable[$item[airplane charter: Spring Break Beach]] = true;
    if (get_property_boolean("spookyAirportAlways") || get_property_boolean("_spookyAirportToday"))
        __iotms_usable[$item[airplane charter: Conspiracy Island]] = true;
    if (get_property_boolean("stenchAirportAlways") || get_property_boolean("_stenchAirportToday"))
        __iotms_usable[$item[airplane charter: Dinseylandfill]] = true;
    if (get_property_boolean("_frToday") || get_property_boolean("frAlways"))
    	__iotms_usable[$item[FantasyRealm membership packet]] = true;
    if (get_property_boolean("_neverendingPartyToday") || get_property_boolean("neverendingPartyAlways"))
        __iotms_usable[$item[Neverending Party invitation envelope]] = true;
    if (get_property_boolean("_voteToday") || get_property_boolean("voteAlways"))
        __iotms_usable[$item[voter registration form]] = true;
    if (florist_available() && $item[hand turkey outline].is_unrestricted()) //Order of the Green Thumb Order Form is not marked as out of standard.
    	__iotms_usable[$item[Order of the Green Thumb Order Form]] = true;
    if (get_property_boolean("daycareOpen"))
    	__iotms_usable[$item[Boxing Day care package]] = true;
    if (get_property_boolean("getawayCampsiteUnlocked"))
        __iotms_usable[$item[Distant Woods Getaway Brochure]] = true;
    if ($item[clan vip lounge key].item_amount() > 0)
    {
    	//FIXME all
    	__iotms_usable[$item[Clan Carnival Game]] = true;
        __iotms_usable[$item[clan floundry]] = true;
    }
    //Remove non-standard:
    foreach it in __iotms_usable
    {
        if (!it.is_unrestricted() || it == $item[none])
            remove __iotms_usable[it];
    }
}

initialiseIOTMsUsable();
