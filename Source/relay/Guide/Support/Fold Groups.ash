


static
{
    boolean [item][item] __fold_groups;
    
    void generateFoldables()
    {
    	//FIXME load from data/foldgroups.txt
        foreach it in $items[broken champagne bottle,makeshift garbage shirt]
        {
            foreach it2 in it.get_related("fold")
            {
                __fold_groups[it][it2] = true;
            }
        }
    }
    generateFoldables();
}
