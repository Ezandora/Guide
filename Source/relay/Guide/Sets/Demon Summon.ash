//demonSummoned
RegisterResourceGenerationFunction("SDemonSummonGenerateResource");
void SDemonSummonGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!QuestState("questL11Manor").finished)
        return;
    if (get_property_boolean("demonSummoned"))
        return;
    //thin black candle >= 3
    //scroll of ancient forbidden unspeakable evil
    //FIXME suggest running intergnat?
    
    if ($item[thin black candle].available_amount() >= 3 && $item[scroll of ancient forbidden unspeakable evil].available_amount() + $item[scroll of ancient forbidden unspeakable evil].creatable_amount() > 0)
    {
        string [int] description;
        string url = "place.php?whichplace=manor4&action=manor4_chamber";
        
        if ($item[thin black candle].item_amount() < 3 && $item[thin black candle].available_amount() >= 3)
        {
            description.listAppend("Pull 3 thin black candles.");
            url = "";
        }
        if ($item[scroll of ancient forbidden unspeakable evil].available_amount() == 0 && $item[scroll of ancient forbidden unspeakable evil].creatable_amount() > 0)
        {
            description.listAppend("Create a scroll of scroll of ancient forbidden unspeakable evil.");
            url = "";
        }
        
        string [int][int] john;
        //Prenatural greed.
        string [string] demons;
        demons["demonName2"] = "+100% meat";
        if ($familiar[intergnat].familiar_is_usable() && in_ronin())
        {
            if (!get_property("demonName12").contains_text("Neil")) //FIXME what if neil is on their friends list?
            {
                description.listAppend("Could run intergnat for demon name.");
            }
            else
            {
                if (my_level() == 11)
                {
                    if (__dense_liana_machete_items.available_amount() == 0)
                        demons["demonName12"] += "Antique machete, tomb ratchet, and cigarette lighter.";
                    else
                        demons["demonName12"] += "Tomb ratchet, and cigarette lighter.";
                }
                else if (my_level() == 12)
                {
                    if ($items[richard's star key,star chart].available_amount() == 0)
                        demons["demonName12"] += "Star chart.";
                }
                else if (my_level() == 13)
                    demons["demonName12"] += "+50% init buff.";
                else
                    demons["demonName12"] += "1000 meat.";
                if (demons["demonName12"] != "")
                    demons["demonName12"] += "|";
                demons["demonName12"] += "+10% item, +20% meat, +50% init, +spell/weapon damage buff.";
                if (my_familiar() != $familiar[intergnat])
                    demons["demonName12"] += "|Make sure to switch to your intergnat familiar before summoning.";
            }
        }
        //Intergnat.
        
        foreach property, description in demons
        {
            string property_value = get_property(property);
            if (property_value == "")
                continue;
            john.listAppend(listMake(property_value, description));
        }
        
        if (john.count() > 0)
            description.listAppend(HTMLGenerateSimpleTableLines(john));
        
        resource_entries.listAppend(ChecklistEntryMake(219, "__item thin black candle", url, ChecklistSubentryMake("Demon summonable", "", description), 7));
    }
}
