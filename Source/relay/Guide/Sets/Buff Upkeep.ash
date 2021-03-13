RegisterTaskGenerationFunction("SBuffUpkeepGenerateTasks");
void SBuffUpkeepGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Least-effort (basically a copy-paste from my ascension script), needs examining:
    if (!__misc_state["in run"])
        return;
    if (my_meat() < 1000) return; //save
    skill [int] skills_want_running;
    int [skill] minimum_meat_for_skill;
    
    skills_want_running.listAppend($skill[iron palm technique]);
    
    if (in_bad_moon() && my_mp() >= 1)
    {
        if (my_class() == $class[disco bandit])
            skills_want_running.listAppend($skill[disco aerobics]);
    }
    if (!__misc_state["familiars temporarily blocked"] && my_familiar() != $familiar[none])
    {
        skills_want_running.listAppend($skill[leash of linguini]);
        skills_want_running.listAppend($skill[empathy of the newt]);
    }
    if (get_property("peteMotorbikeMuffler").length() == 0)
        skills_want_running.listAppend($skill[rev engine]);
    if (my_primestat() == $stat[mysticality] && my_hp() < 500)
    {
        if ($item[turtle totem].available_amount() > 0)
        {
            skills_want_running.listAppend($skill[reptilian fortitude]);
            skills_want_running.listAppend($skill[astral shell]);
            skills_want_running.listAppend($skill[ghostly shell]);
        }
    }
    boolean have_facial_expression = false;
    foreach s in $skills[Arched Eyebrow of the Archmage,Disco Leer,Disco Smirk,Icy Glare,Knowing Smile,Patient Smile,Scowl of the Auk,Snarl of the Timberwolf,Stiff Upper Lip,Suspicious Gaze,Wizard Squint,Wry Smile]
    {
        if (s == $skill[suspicious gaze] && get_property_int("cyrptAlcoveEvilness") <= 26 && QuestState("questL07Cyrptic").started) //only need suspicious gaze there
            continue;
        if (s.to_effect().have_effect() > 0)
            have_facial_expression = true;
    }
    if ($skill[Inscrutable Gaze].to_effect().have_effect() > 0)
        have_facial_expression = true;
    
    if (__misc_state["need to level"] && !have_facial_expression)
    {
        if (my_primestat() == $stat[mysticality])
            skills_want_running.listAppend($skill[Wry Smile]);
        else if (my_primestat() == $stat[moxie])
            skills_want_running.listAppend($skill[knowing smile]);
        else if (my_primestat() == $stat[muscle])
            skills_want_running.listAppend($skill[Patient Smile]);
    }
    
    //UNDYING!
    if (my_level() >= 3)
        skills_want_running.listAppend($skill[Purr of the Feline]);
    skills_want_running.listAppend($skill[Prayer of Seshat]);
    if (__misc_state["need to level"])
        skills_want_running.listAppend($skill[Blessing of Serqet]);
    skills_want_running.listAppend($skill[Hide of Sobek]);
    if (!in_hardcore())
        skills_want_running.listAppend($skill[Bounty of Renenutet]);
    skills_want_running.listAppend($skill[Power of Heka]);
    skills_want_running.listAppend($skill[Wisdom of Thoth]);
    if (my_primestat() == $stat[mysticality] && my_level() < 13)
	    skills_want_running.listAppend($skill[Inscrutable Gaze]);
    
    
    
    minimum_meat_for_skill[$skill[The Magical Mojomuscular Melody]] = 100;
    minimum_meat_for_skill[$skill[blessing of serqet]] = 500;
    minimum_meat_for_skill[$skill[Prayer of Seshat]] = 500;
    minimum_meat_for_skill[$skill[Power of Heka]] = 500;
    minimum_meat_for_skill[$skill[Purr of the Feline]] = 500;
    minimum_meat_for_skill[$skill[leash of linguini]] = 2000;
    minimum_meat_for_skill[$skill[empathy of the newt]] = 3000;
    foreach s in $skills[ur-kel's aria of annoyance,drescher's annoying noise,pride of the puffin]
        minimum_meat_for_skill[s] = 2000;
    
    
    skill [int] final_skills;
    foreach key, s in skills_want_running
    {
        if (!s.skill_is_usable() || !s.is_unrestricted())
            continue;
        effect e = s.to_effect();
        if (e == $effect[none])
            continue;
        if (e.have_effect() > 1)
            continue;
        if (my_maxmp() < s.mp_cost())
            continue;
        final_skills.listAppend(s);
    }
    if (final_skills.count() > 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake(281, "__skill " + final_skills[0], "skillz.php", ChecklistSubentryMake("Upkeep buffs", "", "Cast " + final_skills.listJoinComponents(", ", "and") + ".")));
    }
}
