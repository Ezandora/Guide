record LocationChoice
{
    location place;
    string [int] reasons;
    int importance;
};

LocationChoice LocationChoiceMake(location place, string [int] reasons, int importance)
{
    LocationChoice result;
    result.place = place;
    result.reasons = reasons;
    result.importance = importance;
    return result;
}

LocationChoice LocationChoiceMake(location place, string reason, int importance)
{
    return LocationChoiceMake(place, listMake(reason), importance);
}

LocationChoice LocationChoiceMake(location place, string reason)
{
    return LocationChoiceMake(place, reason, 0);
}

void listAppend(LocationChoice [int] list, LocationChoice entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void LocationChoiceSort(LocationChoice [int] list)
{
	sort list by value.importance;
}

string [int] LocationChoiceGenerateDescription(LocationChoice [int] list)
{
    string [int] description;
    foreach key in list
	{
		LocationChoice lc = list[key];
		string [int] explanation = lc.reasons;
		
		if (explanation.count() == 0)
			continue;
		string first = lc.place.to_string();
		if (lc.place == $location[none])
			first = "";
			
		string line;
		if (explanation.count() > 1)
		{
			line = first + HTMLGenerateIndentedText(HTMLGenerateDiv(explanation.listJoinComponents("<hr>")));
		}
		else
		{
			line = listFirstObject(explanation);
			if (line.stringHasPrefix("|") || first == "")
				line = first + line;
			else
				line = first + ": " + line;
		}
		//string line = first + HTMLGenerateIndentedText(HTMLGenerateDiv(explanation.listJoinComponents(HTMLGenerateDivOfStyle("", "border-top:1px solid;width:30%;"))));
		if (!locationAvailable(lc.place) && lc.place != $location[none])
		{
			line = HTMLGenerateDivOfClass(line, "r_future_option");
		}
		description.listAppend(line);
	}
    return description;
}