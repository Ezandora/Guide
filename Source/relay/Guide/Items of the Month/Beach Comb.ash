
RegisterResourceGenerationFunction("IOTMBeachCombGenerateResource");
void IOTMBeachCombGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (lookupItem("beach comb").available_amount() == 0) return;
	int free_walks_left = clampi(11 - get_property_int("_freeBeachWalksUsed"), 0, 11);
	if (free_walks_left > 0)
	{
		boolean [int] beach_heads_used = get_property("_beachHeadsUsed").stringToIntIntList(",").listInvert();
        
        string [int] description;
        string [int] buffs;
        
        string [int] elemental_buffs;
        boolean in_run = __misc_state["in run"];
        if (!beach_heads_used[1])
        	elemental_buffs.listAppend(HTMLGenerateSpanOfClass("Hot-Headed", "r_element_hot"));
        if (!beach_heads_used[2])
            elemental_buffs.listAppend(HTMLGenerateSpanOfClass("Cold as Nice", "r_element_cold"));
        if (!beach_heads_used[3])
            elemental_buffs.listAppend(HTMLGenerateSpanOfClass("A Brush with Grossness", "r_element_stench"));
        if (!beach_heads_used[4])
            elemental_buffs.listAppend(HTMLGenerateSpanOfClass("Does It Have a Skull In There??", "r_element_spooky"));
        if (!beach_heads_used[5])
            elemental_buffs.listAppend(HTMLGenerateSpanOfClass("Oiled\, Slick", "r_element_sleaze"));
        
        if (elemental_buffs.count() > 0 && in_run)
            buffs.listAppend("<strong>" + elemental_buffs.listJoinComponents(" / ") + ":</strong> +3 X resistance, +15 X damage, +15 X spell damage.");
        if (!beach_heads_used[6] && in_run)
        	buffs.listAppend("<strong>Lack of Body-Building:</strong> +50% muscle, +25% weapon damage."); //<strong> hah
        if (!beach_heads_used[7] && in_run)
            buffs.listAppend("<strong>We're All Made of Starfish:</strong> +50% myst, +25% spell damage.");
        if (!beach_heads_used[8] && in_run)
            buffs.listAppend("<strong>Pomp & Circumsands:</strong> +50% moxie, +25% ranged damage.");
        if (!beach_heads_used[9] && in_run)
            buffs.listAppend("<strong>Resting Beach Face:</strong> +50% init.");
        if (!beach_heads_used[10])
            buffs.listAppend("<strong>Do I Know You From Somewhere?:</strong> +5 familiar weight.");
        if (!beach_heads_used[11] && in_run)
            buffs.listAppend("<strong>You Learned Something Maybe!:</strong> +5 stats/fight.");
        
        if (buffs.count() > 0)
	        description.listAppend("Buffs:<hr>" + buffs.listJoinComponents("<hr>"));
        if (free_walks_left >= 10)
        	description.listAppend((description.count() > 0 ? "Or collect" : "Collect") + " a bunch of items? (10 walks)");
        description.listAppend("Or farm the beach.");
        resource_entries.listAppend(ChecklistEntryMake("__item beach comb", "main.php?comb=1", ChecklistSubentryMake(pluralise(free_walks_left, "beach comb", "beach combs"), "", description), 3));
    }
}
