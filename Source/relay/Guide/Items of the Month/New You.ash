RegisterResourceGenerationFunction("IOTMNewYouGenerateResource");
void IOTMNewYouGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (__misc_state["in run"] && in_ronin())
    {
        string [item] affirmation_effects;
        string [item] affirmation_combat_uses;
        affirmation_effects[$item[Daily Affirmation: Adapt to Change Eventually]] = "+4 stats/fight, +50% init";
        if (!__misc_state["need to level"])
            affirmation_effects[$item[Daily Affirmation: Adapt to Change Eventually]] = "+50% init";
        affirmation_effects[$item[Daily Affirmation: Always be Collecting]] = "+50% item, +100% meat";
        affirmation_effects[$item[Daily Affirmation: Be a Mind Master]] = "+100% spell damage, 15 MP regen";
        affirmation_effects[$item[Daily Affirmation: Be Superficially interested]] = "-combat / +combat (togglable)";
        affirmation_effects[$item[Daily Affirmation: Keep Free Hate in your Heart]] = "+30 ML";
        affirmation_effects[$item[Daily Affirmation: Think Win-Lose]] = "+50% all stats";
        affirmation_effects[$item[Daily Affirmation: Work For Hours a Week]] = "+5 familiar weight, 15 HP regen";
        if (__misc_state["familiars temporarily blocked"])
            affirmation_effects[$item[Daily Affirmation: Work For Hours a Week]] = "15 HP regen";
        
        
        affirmation_combat_uses[$item[Daily Affirmation: Adapt to Change Eventually]] = "reroll monster"; //monster change
        affirmation_combat_uses[$item[Daily Affirmation: Always be Collecting]] = "duplicate item drops";
        affirmation_combat_uses[$item[Daily Affirmation: Be a Mind Master]] = "banish for 80 turns";
        if (!__misc_state["have reusable olfaction equivalent"])
            affirmation_combat_uses[$item[Daily Affirmation: Be Superficially interested]] = "olfact weakly";
        if (hippy_stone_broken())
            affirmation_combat_uses[$item[Daily Affirmation: Keep Free Hate in your Heart]] = "gain 3 PVP fights";
        affirmation_combat_uses[$item[Daily Affirmation: Think Win-Lose]] = "instakill";
        affirmation_combat_uses[$item[Daily Affirmation: Work For Hours a Week]] = "earn some meat";
        
        ChecklistEntry entry = ChecklistEntryMake();
        foreach it in affirmation_effects
        {
            if (it.item_amount() == 0) continue;
            if (!it.item_is_usable()) continue;
            if (!it.to_effect().effect_is_usable()) continue;
            if (entry.image_lookup_name == "")
                entry.image_lookup_name = "__item " + it;
            string combat_text = "";
            if (affirmation_combat_uses[it] != "")
                combat_text = "Or throw in combat to " + affirmation_combat_uses[it] + ".";
            ChecklistSubentry subentry = ChecklistSubentryMake(pluralise(it), "100 turns, " + affirmation_effects[it], combat_text);
            if (it == $item[Daily Affirmation: Think Win-Lose])
            {
            	resource_entries.listAppend(ChecklistEntryMake("__item " + it, "", subentry).ChecklistEntryTag("free instakill"));
            }
            else if (it == $item[Daily Affirmation: Be a Mind Master])
            {
                resource_entries.listAppend(ChecklistEntryMake("__item " + it, "", subentry).ChecklistEntryTag("free banish"));
            }
            else
	            entry.subentries.listAppend(subentry);
        }
        if (entry.subentries.count() > 0)
        {
            entry.url = "inventory.php?which=3";
            entry.importance_level = 6;
            resource_entries.listAppend(entry);
        }
    }
}
