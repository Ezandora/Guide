static
{
    string [item] __tea_tree_teas;
    void initialiseTeaTreeTeas()
    {
        __tea_tree_teas[lookupItem("cuppa Activi tea")] = "adventures, stats";
        __tea_tree_teas[lookupItem("cuppa Alacri tea")] = "+50% init";
        __tea_tree_teas[lookupItem("cuppa Boo tea")] = "+30 spooky damage";
        __tea_tree_teas[lookupItem("cuppa Chari tea")] = "+50% meat";
        __tea_tree_teas[lookupItem("cuppa Craft tea")] = "crafting";
        __tea_tree_teas[lookupItem("cuppa Cruel tea")] = "+5 fights for spleen";
        __tea_tree_teas[lookupItem("cuppa Dexteri tea")] = "+50 moxie";
        __tea_tree_teas[lookupItem("cuppa Feroci tea")] = "+50 muscle";
        __tea_tree_teas[lookupItem("cuppa Flamibili tea")] = "+30 hot damage";
        __tea_tree_teas[lookupItem("cuppa Flexibili tea")] = "+3 moxie stats/fight";
        __tea_tree_teas[lookupItem("cuppa Frost tea")] = "+3 hot res";
        __tea_tree_teas[lookupItem("cuppa Gill tea")] = "fishy";
        __tea_tree_teas[lookupItem("cuppa Impregnabili tea")] = "30 DR";
        __tea_tree_teas[lookupItem("cuppa Improprie tea")] = "+30 sleaze damage";
        __tea_tree_teas[lookupItem("cuppa Insani tea")] = "+3 OCRS modifiers, teleporting(?)";
        __tea_tree_teas[lookupItem("cuppa Irritabili tea")] = "+combat";
        __tea_tree_teas[lookupItem("cuppa Loyal tea")] = "+5 familiar weight";
        __tea_tree_teas[lookupItem("cuppa Mana tea")] = "+30 max MP, ~4 MP regen";
        __tea_tree_teas[lookupItem("cuppa Mediocri tea")] = "+30 ML";
        __tea_tree_teas[lookupItem("cuppa Monstrosi tea")] = "-30 ML";
        __tea_tree_teas[lookupItem("cuppa Morbidi tea")] = "+3 spooky res";
        __tea_tree_teas[lookupItem("cuppa Nas tea")] = "+30 stench damage";
        __tea_tree_teas[lookupItem("cuppa Net tea")] = "+3 stench res";
        __tea_tree_teas[lookupItem("cuppa Neuroplastici tea")] = "+3 myst stat/fight";
        __tea_tree_teas[lookupItem("cuppa Obscuri tea")] = "-combat";
        __tea_tree_teas[lookupItem("cuppa Physicali tea")] = "+3 muscle stats/fight";
        __tea_tree_teas[lookupItem("cuppa Proprie tea")] = "+3 sleaze res";
        __tea_tree_teas[lookupItem("cuppa Royal tea")] = "+1 royalty";
        __tea_tree_teas[lookupItem("cuppa Serendipi Tea")] = "+25% item";
        __tea_tree_teas[lookupItem("cuppa Sobrie tea")] = "-1 drunkenness";
        __tea_tree_teas[lookupItem("cuppa Toast tea")] = "+3 cold res";
        __tea_tree_teas[lookupItem("cuppa Twen tea")] = "+20 various stats";
        __tea_tree_teas[lookupItem("cuppa Uncertain tea")] = "random effect";
        __tea_tree_teas[lookupItem("cuppa Vitali tea")] = "+30 max HP, ~4 HP regen";
        __tea_tree_teas[lookupItem("Cuppa Voraci tea")] = "+1 stomach capacity today";
        __tea_tree_teas[lookupItem("cuppa Wit tea")] = "+50 myst";
        __tea_tree_teas[lookupItem("cuppa Yet tea")] = "+30 cold damage";
    }
    initialiseTeaTreeTeas();
}

void STeaTreeGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!get_property_boolean("_pottedTeaTreeUsed") && get_campground()[lookupItem("potted tea tree")] > 0)
    {
        string [int] options;
        //+50% Combat Initiative?
        
        string [int][int] tea_options;
        
        
        if (__misc_state["in run"])
        {
            tea_options.listAppend(listMake("Irritabili", "+combat (30 turns)"));
            tea_options.listAppend(listMake("Obscuri", "-combat (30 turns)"));
            tea_options.listAppend(listMake("Serendipi", "+25% item (30 turns)"));
            tea_options.listAppend(listMake("Chari", "+50% meat (30 turns)"));
            tea_options.listAppend(listMake("Mediocri", "+30 ML"));
            if (!__misc_state["familiars temporarily blocked"])
                tea_options.listAppend(listMake("Loyal", "+5 familiar weight"));
            tea_options.listAppend(listMake("Craft", "Free crafts"));
            if (hippy_stone_broken())
                tea_options.listAppend(listMake("Cruel", "+5 PVP fights, spleen"));
        }
        if (inebriety_limit() > 0)
            tea_options.listAppend(listMake("Sobrie", "-1 drunkenness"));
        if (fullness_limit() > 0)
            tea_options.listAppend(listMake("Voraci", "+1 fullness capacity today"));
        
        if (!__misc_state["in run"])
        {
            tea_options.listAppend(listMake("Royal", "Mall selling, royal leaderboarding"));
            tea_options.listAppend(listMake("Gill", "Fishy (30 turns)"));
        }
        
        if (tea_options.count() > 0)
            options.listAppend(HTMLGenerateSimpleTableLines(tea_options));
        resource_entries.listAppend(ChecklistEntryMake("__item potted tea tree", "campground.php?action=teatree", ChecklistSubentryMake("Tea Tree Tea", "", options), 4));
    }
    
    if (__misc_state["in run"] && !can_interact())
    {
        string image_name = "";
        string url = "";
        string [int] teas_found;
        string [int] reasons_found;
        boolean one_tea_gives_effect = false;
        foreach tea, treason in __tea_tree_teas
        {
            if (tea.available_amount() == 0)
                continue;
            string shortened_tea_name = tea.replace_string("cuppa ", "").replace_string(" tea", "");
            teas_found.listAppend(pluralise(tea.available_amount(), shortened_tea_name, shortened_tea_name));
            
            reasons_found.listAppend(treason);
            if (image_name == "")
                image_name = "__item " + tea;
            if (!one_tea_gives_effect && tea.to_effect() != $effect[none])
                one_tea_gives_effect = true;
            if (tea.spleen > 0)
            {
                if (url == "")
                    url = "inventory.php?which=1";
            }
            else
                url = "inventory.php?which=3";
        }
        if (teas_found.count() > 0)
        {
            resource_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(teas_found.listJoinComponents(", ", "and").capitaliseFirstLetter() + " tea", "", reasons_found.listJoinComponents(", ", "or").capitaliseFirstLetter() + (one_tea_gives_effect ? " (30 turns)" : "")), 8));
        }
    }
}