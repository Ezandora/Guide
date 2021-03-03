
RegisterTaskGenerationFunction("SBugsGenerateTasks");
void SBugsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_id() != 1557284) return;
	
	string [int] bugs;
	
	//bugs are here
	//bugs.listAppend("In firefox, resource bar text is not aligned properly."); //still in effect, but not relevant to modern layout
	//bugs.listAppend("resource bar should remember open/closed");
	//bugs.listAppend("resource bar resolve subicons"); //disabled, unviable
	//bugs.listAppend("floating icons do not work well with fade to black. specifically, the reload button");
	//bugs.listAppend("Resource bar, when moused over, does not survive reloading Guide. Set it to continuous and debug.|same with location bar");
	//bugs.listAppend("Should the resource info popup have some sort of solid separation from the resource bar itself?"); //ignored, don't care
	bugs.listAppend("Guide takes too long to start up. 2.56s last measure on local.");
	bugs.listAppend("camel needs targets for spit.");
	bugs.listAppend("camel needs buff when that is trackable.");
	bugs.listAppend("make turn-costing banishes be vaguely near the free ones");
	bugs.listAppend("ZS changes?");
	bugs.listAppend("robot path");
	bugs.listAppend("grey goo? (do absolutely nothing)");
	//bugs.listAppend("implement showhide");
	//bugs.listAppend("emotion chip - if we don't have the skill but we can acquire it via the item, do that");
	//bugs.listAppend("location bar's text is obscured by the scroll bar.");
	//bugs.listAppend("Location bar, when changing location, will 'peek' due to .bottom.");
	//bugs.listAppend("resource bar popup info text is misplaced because of scroll bar");
	//bugs.listAppend("In the resource bar, free fights go past the screen limit. Split it up into original parts?");
	//bugs.listAppend("barrel worship in resource bar has bad background");
	//bugs.listAppend("in the resource bar, popup does not have correct icon");
	//bugs.listAppend("set to continuously load and look at importance bar; the shadow keeps on animating");
	
	bugs.listAppend("cartography - various changes from adventures it gives. in particular, always worry about pool adventure?");
	bugs.listAppend("superhero cape in state.ash YR detection");
	bugs.listAppend("when generating blank showhides, there's no link");
	//bugs.listAppend("for entries, there's no link in blank space");
	bugs.listAppend("for entries with no showhide, there's no link in the showhide spot");
	//bugs.listAppend("sync showhide on importance bar with entry on main");
	//bugs.listAppend("speakeasy drinks goes past limit in showhide when on left for doubles");
	//bugs.listAppend("resolve show/noshow when clicking showhide outside of appearance - test mouse checking code");
	//bugs.listAppend("solve popup 2x on same line problem - we need full width yet");
	//bugs.listAppend("line on top entry for each checklist");
	bugs.listAppend("showhide popup ignores highlighted - fix via transparency on popup");
	bugs.listAppend("refresh button vs importance bar");
	//bugs.listAppend("top hover buttons aren't clickable always");
	//bugs.listAppend("reload should always appear in independent window");
	bugs.listAppend("write support for preserving showhide clicks across versions - currently storing the abridged description, may mean removing numbers, partial matches...|also worst case, if they don't show up on page, do they get a transition? probably... not? unless we keep a dynamic system...");
	//bugs.listAppend("resource bar does not interact with hidden entries");
	//bugs.listAppend("if all entries are on the last line, and the scroll bar is all the way at the bottom, the popup causes problems in chromium, because chromium is constantly jumping down and up. don't know how to fix this - appear above instead of below if we're near the end...?"); //fixed via constant position testing
	bugs.listAppend("requested movable entries. major project");
	//bugs.listAppend("superhero cape in L7 code");
	
	
	string [int] iotms;
	
	
	int yooi = 2019;
	int mooi = 11;
	
	
	int current_year = format_today_to_string("yyyy").to_int();
	int current_month = format_today_to_string("MM").to_int();
	
	
	int i_year = yooi;
	int i_month = mooi;
	
	
	string [int] months = 
	{
    1:"January",
    2:"February",
    3:"March",
    4:"April",
    5:"May",
    6:"June",
    7:"July",
    8:"August",
    9:"September",
    10:"October",
    11:"November",
    12:"December",
	};
	
	string [int] iotm_canonical_list = 
	{
        //2019:
        "Kramco Industries packing carton",
        "mint condition Lil' Doctor™ bag",
        "vampyric cloake pattern",
        "PirateRealm membership packet",
        "Fourth of May Cosplay Saber kit",
        "rune-strewn spoon cocoon",
        "Beach Comb Box",
        "Distant Woods Getaway Brochure",
        "√packaged Pocket Professor",
        "√Unopened Eight Days a Week Pill Keeper",
        "unopened diabolic pizza cube box",
        "√red-spotted snapper roe",

        //2020:
        "√unopened Bird-a-Day calendar",
        "√mint-in-box Powerful Glove",
        "√Better Shrooms and Gardens catalog",
        "Left-Hand Man",
        "√Guzzlr application",
        "bag of Iunion stones",
        "√baby camelCalf",
        "√packaged SpinMaster™ lathe",
        "Bagged Cargo Cultist Shorts",
        "Comprehensive Cartographic Compendium",
        "√packaged knock-off retro superhero cape",
        "box o' ghosts",

        //2021:
        "√packaged miniature crystal ball",
        "√emotion chip",
	};
	
	int breakout = 77;
	while (i_year <= current_year && breakout > 0)
	{
		breakout -= 1;
        string description;
        
        description = months[i_month] + " " + i_year;
        
        
        int description_index = (i_year - 2019) * 12 + (i_month - 1);
        
        if (iotm_canonical_list contains description_index)
        	description = iotm_canonical_list[description_index];
        
        
        description += " IOTM";
        
        
        if (!description.contains_text("√"))
        	iotms.listAppend(description);
  
        i_month += 1;
        if (i_month >= 13)
        {
        	i_month = 1;
            i_year += 1;
        }
        
        if (i_year == current_year && i_month > current_month)
        	break;
	}
	
	
	bugs.listAppendList(iotms);
	
	if (bugs.count() > 0)
	{
        task_entries.listAppend(ChecklistEntryMake("__item software bug", "", ChecklistSubentryMake(HTMLGenerateSpanFont("Fix " + pluralise(bugs.count(), "bug", "bugs"), "red"), "", bugs), -10));
	}
}
