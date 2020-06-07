

RegisterResourceGenerationFunction("IOTMZutaraGenerateResource");
void IOTMZutaraGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__misc_state["VIP available"] || !lookupItem("Clan Carnival Game").is_unrestricted())
        return;
    ChecklistEntry entry;
    entry.importance_level = 8;
    entry.image_lookup_name = "__item genie's turbane";
    entry.url = "clan_viplounge.php?preaction=lovetester";
    if (!get_property_boolean("_clanFortuneBuffUsed"))
    {
    	string [int] description;
        if (!__misc_state["familiars temporarily blocked"] && __misc_state["in run"])
        	description.listAppend(HTMLGenerateSpanOfClass("Susie:", "r_bold") + " +5 familiar weight, +familiar experience."); //only show in-run, because, like... +5 familiar weight for one hundred turns is not likely to pay out compared to hagnk/meatsmith in aftercore.
        if (myPathId() != PATH_G_LOVER)
	        description.listAppend(HTMLGenerateSpanOfClass("Hagnk:", "r_bold") + " +50% item/booze/food.");
        if (myPathId() != PATH_G_LOVER)
	        description.listAppend(HTMLGenerateSpanOfClass("Meatsmith:", "r_bold") + " +100% meat, +50% gear drop.");
        
        if (__misc_state["in run"])
        {
        	if (my_primestat() == $stat[muscle] || myPathId() == PATH_COMMUNITY_SERVICE)
	            description.listAppend(HTMLGenerateSpanOfClass("Gunther:", "r_bold") + " +5 muscle stats/fight, +100% muscle, +50% HP.");
            if (my_primestat() == $stat[moxie] || myPathId() == PATH_COMMUNITY_SERVICE)
            	description.listAppend(HTMLGenerateSpanOfClass("Gorgonzola:", "r_bold") + " +5 myst stats/fight, +100% myst, +50% MP.");
            //always show moxie, since I'm sure that +50% init will be super important to someone. maybe they have a bad lair test?
            if (myPathId() != PATH_G_LOVER)
	            description.listAppend(HTMLGenerateSpanOfClass("Shifty:", "r_bold") + " +5 moxie stats/fight, +100% moxie, +50% init.");
        }
    	entry.subentries.listAppend(ChecklistSubentryMake("Fortune buff (100 turns)", "", description));
    }
    if (get_property_int("_clanFortuneConsultUses") < 3)
    {
        string [int] description;
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(3 - get_property_int("_clanFortuneConsultUses"), "fortune clan consult", "fortune clan consults"), "", description));
    }
    if (entry.subentries.count() > 0)
	    resource_entries.listAppend(entry);
}
