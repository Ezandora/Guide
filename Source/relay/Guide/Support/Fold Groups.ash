


static
{
    boolean [item][item] __fold_groups;
    
    void generateFoldables()
    {
        string [int] foldgroups_file = file_to_array("data/foldgroups.txt");
        
        foreach key, line in foldgroups_file
        {
        	if (line.contains_text("#")) continue; //wrong, but I don't
            string [int] line_split = line.split_string("\t");
            if (line_split.count() < 2) continue;
            for i from 1 to line_split.count() - 1
            {
            	string v = line_split[i];
                item it = v.to_item();
                if (it == $item[none]) continue;
                
                foreach it2 in it.get_related("fold")
                {
                    __fold_groups[it][it2] = true;
                }
            }
        }
    }
    generateFoldables();
}
