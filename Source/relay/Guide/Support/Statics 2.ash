import "relay/Guide/Support/Library.ash";

static
{
    //mr. fusion:
    boolean [item] __pvpable_food_and_drinks;
    void initialisePVPFoodAndDrinks()
    {
        foreach it in $items[]
        {
            if (it.fullness == 0 && it.inebriety == 0) continue;
            if (!it.item_is_pvp_stealable()) continue;
            __pvpable_food_and_drinks[it] = true;
        }
    }
    initialisePVPFoodAndDrinks();
}
