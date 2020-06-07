
RegisterTaskGenerationFunction("PathZombieSlayerGenerateTasks");
void PathZombieSlayerGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (myPathId() != PATH_ZOMBIE_SLAYER)
		return;
    //zombiePoints is the number of points "permed" on the character, not how many they have at the moment
    //Let's see.. I think this means we can infer how many points they have to spend, right? You start with zombiePoints + 1, then gain one for each level you have, minus how many hunter brains you have, minus whether you've fought the right hunter yet... but, we can't know that information. Hmm. So, no, no reminder. Alas.
    //We could, however, suggest they eat a hunter brain.
    //ashq string out; foreach s in $skills[] if (s.class == $class[zombie master]) out += ", " + s; print(out);
    if ($item[hunter brain].available_amount() > 0 && availableFullness() >= 1)
    {
        int zombie_skills_have = 0;
        foreach s in $skills[Infectious Bite, Bite Minion, Lure Minions, Undying Greed, Hunter's Sprint, Insatiable Hunger, Devour Minions, Indefatigable, Skullcracker, Neurogourmet, Ravenous Pounce, Distracting Minion, Plague Claws, Flesh Mob, Elemental Obliviousness, Vigor Mortis, Virulence, Bilious Burst, Unyielding Flesh, Corpse Pile, Howl of the Alpha, Summon Minion, Zombie Chow, Smash & Graaagh, Scavenge, Meat Shields, Summon Horde, His Master's Voice, Ag-grave-ation, Disquiet Riot, Zombie Maestro, Recruit Zombie]
        {
            if (s.have_skill())
                zombie_skills_have += 1;
        }
        if (zombie_skills_have < 30)
        {
            //probably should suggest eat X hunter brains but
            optional_task_entries.listAppend(ChecklistEntryMake("__item hunter brain", "inventory.php?ftext=hunter+brain", ChecklistSubentryMake("Eat a hunter brain", "", "Gain a skill point."), -1));
        }
    }
    
}

RegisterResourceGenerationFunction("PathZombieSlayerGenerateResource");
void PathZombieSlayerGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (myPathId() != PATH_ZOMBIE_SLAYER)
		return;
    
    if ($item[right bear arm].available_amount() > 0 && $item[left bear arm].available_amount() > 0)
    {
        int bear_hugs_remaining = clampi(10 - get_property_int("_bearHugs"), 0, 10);
        
        if (bear_hugs_remaining > 0)
        {
            string url;
            string [int] description;
            description.listAppend("Converts monster to zombies. Ideally, use against group monsters.");
            string [int] items_to_equip;
            foreach it in $items[right bear arm,left bear arm]
            {
                if (it.equipped_amount() == 0)
                    items_to_equip.listAppend(it);
            }
            if (items_to_equip.count() > 0)
            {
                url = "inventory.php?which=2";
                description.listAppend("Equip " + items_to_equip.listJoinComponents(", ", "and") + ".");
            }
            resource_entries.listAppend(ChecklistEntryMake("__item right bear arm", url, ChecklistSubentryMake(pluralise(bear_hugs_remaining, "bear hug", "bear hugs"), "", description), 8));
            
        }
    }
}