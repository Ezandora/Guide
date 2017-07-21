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
            if (campground[it] > 0)
                __iotms_usable[it] = true;
        }
        if (campground[lookupItem("Asdon Martin keyfob")] > 0)
            __iotms_usable[lookupItem("Asdon Martin keyfob")] = true;
    }
    if (get_property_boolean("hasDetectiveSchool"))
        __iotms_usable[$item[detective school application]] = true;
    if (get_property_boolean("chateauAvailable"))
        __iotms_usable[$item[Chateau Mantegna room key]] = true;
    if (get_property_boolean("barrelShrineUnlocked"))
        __iotms_usable[$item[shrine to the Barrel god]] = true;
    if (get_property_boolean("snojoAvailable"))
        __iotms_usable[$item[X-32-F snowman crate]] = true;
    if (get_property_boolean("telegraphOfficeAvailable"))
        __iotms_usable[$item[LT&T telegraph office deed]] = true;
    if (get_property_boolean("loveTunnelAvailable"))
        __iotms_usable[lookupItem("heart-shaped crate")] = true;
    if (get_property_boolean("spacegateAlways") || get_property_boolean("_spacegateToday"))
        __iotms_usable[lookupItem("Spacegate access badge")] = true;
    if (get_property_boolean("gingerbreadCityAvailable") || get_property_boolean("_gingerbreadCityToday"))
        __iotms_usable[$item[Build-a-City Gingerbread kit]] = true;
    if (lookupItem("kremlin's greatest briefcase").available_amount() > 0)
        __iotms_usable[lookupItem("kremlin's greatest briefcase")] = true;
    //Remove non-standard:
    foreach it in __iotms_usable
    {
        if (!it.is_unrestricted())
            remove __iotms_usable[it];
    }
}

initialiseIOTMsUsable();
