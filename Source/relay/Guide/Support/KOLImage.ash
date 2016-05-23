import "relay/Guide/Support/Math.ash"
import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Support/Page.ash"

boolean __setting_show_alignment_guides = false;
//Library for displaying KOL images
//Each image is referred to by a string via KOLImageLookup, or KOLImageGenerateImageHTML
//There's a list of pre-set images in KOLImagesInit. Otherwise, it tries to look up the string as an item, then as a familiar, and then as an effect. If any matches are found, that image is output. (uses KoLmafia's internal database)
//Also "__item item name", "__familiar familiar name", and "__effect effect name" explicitly request those images.
//"__half lookup name" will reduce the image to half-size.
//NOTE: To use KOLImageGenerateImageHTML with should_centre set to true, the page must have the class "r_centre" set as "margin-left:auto; margin-right:auto;text-align:center;"

Record ServerImageStats
{
    int width;
    int height;
    int minimum_y_coordinate;
    int maximum_y_coordinate;
};

ServerImageStats ServerImageStatsMake(int width, int height, int minimum_y_coordinate, int maximum_y_coordinate)
{
    ServerImageStats result;
    result.width = width;
    result.height = height;
    result.minimum_y_coordinate = minimum_y_coordinate;
    result.maximum_y_coordinate = maximum_y_coordinate;
    return result;
}

ServerImageStats ServerImageStatsMake()
{
    return ServerImageStatsMake(-1,-1,-1,-1);
}

record KOLImage
{
	string url;
	
	Vec2i base_image_size;
	Rect crop;
	
	Rect [int] erase_zones; //rectangular zones which are generated as white divs on the output. Erases specific sections of the image. Can be offset by one pixel depending on the browser, sorry.
};


KOLImage KOLImageMake(string url, Vec2i base_image_size, Rect crop)
{
	KOLImage result;
	result.url = url;
	result.base_image_size = base_image_size;
	result.crop = crop;
	return result;
}

KOLImage KOLImageMake(string url, Vec2i base_image_size)
{
	return KOLImageMake(url, base_image_size, RectZero());
}

KOLImage KOLImageMake(string url)
{
	return KOLImageMake(url, Vec2iZero(), RectZero());
}

KOLImage KOLImageMake()
{
	return KOLImageMake("", Vec2iZero(), RectZero());
}


static
{
    KOLImage [string] __kol_images;
    
    void initialiseConstantKOLImages()
    {
        KOLimage [string] building_images;
        building_images["typical tavern"] = KOLImageMake("images/otherimages/woods/tavern0.gif", Vec2iMake(100,100), RectMake(0,39,99,97));
        building_images["boss bat"] = KOLImageMake("images/adventureimages/bossbat.gif", Vec2iMake(100,100), RectMake(0,27,99,74));
        building_images["bugbear"] = KOLImageMake("images/adventureimages/fallsfromsky.gif", Vec2iMake(100,150));
        
        building_images["twin peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(153,128,237,214));
        building_images["a-boo peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(40,134,127,218));
        building_images["oil peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(261,117,345,213));
        building_images["highland lord"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(375,73,457,144));
        building_images["orc chasm"] = KOLImageMake("images/otherimages/mountains/chasm.gif", Vec2iMake(100, 100), RectMake(0, 41, 99, 95));
        
        building_images["spooky forest"] = KOLImageMake("images/otherimages/woods/forest.gif", Vec2iMake(100, 100), RectMake(12,39,91,93));
        building_images["council"] = KOLImageMake("images/otherimages/council.gif", Vec2iMake(100, 100), RectMake(0,26,99,73));
        
        
        building_images["daily dungeon"] = KOLImageMake("images/otherimages/town/dd1.gif", Vec2iMake(100,100), RectMake(28,44,71,86));
        building_images["clover"] = KOLImageMake("images/itemimages/clover.gif", Vec2iMake(30,30));
        
        building_images["mayfly bait"] = KOLImageMake("images/itemimages/mayflynecklace.gif", Vec2iMake(30,30));
        building_images["spooky putty"] = KOLImageMake("images/itemimages/sputtysheet.gif", Vec2iMake(30,30));
        
        building_images["fax machine"] = KOLImageMake("images/otherimages/clanhall/faxmachine.gif", Vec2iMake(100,100), RectMake(34,28,62,54));
        
        building_images["unknown"] = KOLImageMake("images/itemimages/confused.gif", Vec2iMake(30,30));
        
        building_images["goth kid"] = KOLImageMake("images/itemimages/crayongoth.gif", Vec2iMake(30,30));
        building_images["hipster"] = KOLImageMake("images/itemimages/minihipster.gif", Vec2iMake(30,30));
        
        
        building_images[""] = KOLImageMake("images/itemimages/blank.gif", Vec2iMake(30,30));
        building_images["blank"] = KOLImageMake("images/itemimages/blank.gif", Vec2iMake(30,30));
        building_images["demon summon"] = KOLImageMake("images/otherimages/manor/chamber.gif", Vec2iMake(100,100), RectMake(14, 12, 88, 66));
        
        building_images["cobb's knob"] = KOLImageMake("images/otherimages/plains/knob2.gif", Vec2iMake(100,100), RectMake(12,43,86,78));
        
        building_images["generic dwelling"] = KOLImageMake("images/otherimages/campground/rest4.gif", Vec2iMake(100,100), RectMake(0,26,95,99));
        
        
        building_images["forest friars"] = KOLImageMake("images/otherimages/woods/stones0.gif", Vec2iMake(100,100), RectMake(0, 24, 99, 99));
        building_images["cyrpt"] = KOLImageMake("images/otherimages/plains/cyrpt.gif", Vec2iMake(100,100), RectMake(0, 33, 99, 99));
        building_images["trapper"] = KOLImageMake("images/otherimages/thetrapper.gif", Vec2iMake(60,100), RectMake(0,11,59,96));
        
        building_images["castle"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(234,158,362,290)); //experimental - half sized castle
        building_images["penultimate fantasy airship"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(75, 231, 190, 367));
        building_images["lift, bro"] = KOLImageMake("images/adventureimages/fitposter.gif", Vec2iMake(100,100));
        //building_images["castle stairs up"] = KOLImageMake("images/adventureimages/giantstairsup.gif", Vec2iMake(100,100), RectMake(0, 8, 99, 85));
        building_images["castle stairs up"] = KOLImageMake("images/adventureimages/giantstairsup.gif", Vec2iMake(100,100), RectMake(20, 10, 74, 83));
        building_images["castle stairs up"].erase_zones.listAppend(RectMake(70, 78, 76, 84));
        
        
        building_images["goggles? yes!"] = KOLImageMake("images/adventureimages/steamposter.gif", Vec2iMake(100,100));
        //building_images["hole in the sky"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(403, 4, 487, 92));
        building_images["hole in the sky"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(250,200), RectMake(201, 2, 243, 46));
        
        building_images["macguffin"] = KOLImageMake("images/itemimages/macguffin.gif", Vec2iMake(30,30));
        building_images["island war"] = KOLImageMake("images/otherimages/sigils/warhiptat.gif", Vec2iMake(50,50), RectMake(0,12,49,35));
        building_images["naughty sorceress"] = KOLImageMake("images/adventureimages/sorcform1.gif", Vec2iMake(100,100));
        building_images["naughty sorceress lair"] = KOLImageMake("images/otherimages/main/map6.gif", Vec2iMake(100,100), RectMake(6,0,50,43));
        
        building_images["king imprismed"] = KOLImageMake("images/otherimages/lair/kingprism1.gif", Vec2iMake(100,100));
        building_images["campsite"] = KOLImageMake("images/otherimages/plains/plains1.gif", Vec2iMake(100,100));
        building_images["trophy"] = KOLImageMake("images/otherimages/trophy/not_wearing_any_pants.gif", Vec2iMake(100,100));
        building_images["hidden temple"] = KOLImageMake("images/otherimages/woods/temple.gif", Vec2iMake(100,100), RectMake(16, 40, 89, 96));
        building_images["florist friar"] = KOLImageMake("images/adventureimages/floristfriar.gif", Vec2iMake(100,100), RectMake(31, 7, 77, 92));
        
        
        building_images["plant rutabeggar"] = KOLImageMake("images/otherimages/friarplants/plant2.gif", Vec2iMake(50,100), RectMake(1, 24, 47, 96));
        
        building_images["plant stealing magnolia"] = KOLImageMake("images/otherimages/friarplants/plant12.gif", Vec2iMake(49,100), RectMake(3, 15, 43, 94));
        
        building_images["plant shuffle truffle"] = KOLImageMake("images/otherimages/friarplants/plant24.gif", Vec2iMake(66,100), RectMake(4, 35, 63, 88));
        building_images["plant horn of plenty"] = KOLImageMake("images/otherimages/friarplants/plant22.gif", Vec2iMake(62,100), RectMake(4, 14, 58, 86));
        
        building_images["plant rabid dogwood"] = KOLImageMake("images/otherimages/friarplants/plant1.gif", Vec2iMake(57,100), RectMake(3, 16, 55, 98));
        building_images["plant rad-ish radish"] = KOLImageMake("images/otherimages/friarplants/plant3.gif", Vec2iMake(48,100), RectMake(4, 14, 42, 96));
        building_images["plant war lily"] = KOLImageMake("images/otherimages/friarplants/plant11.gif", Vec2iMake(49,100), RectMake(5, 5, 45, 98));
        
        building_images["plant canned spinach"] = KOLImageMake("images/otherimages/friarplants/plant13.gif", Vec2iMake(48,100), RectMake(3, 24, 46, 94));	
        building_images["plant blustery puffball"] = KOLImageMake("images/otherimages/friarplants/plant21.gif", Vec2iMake(54,100), RectMake(3, 38, 50, 90));
        building_images["plant wizard's wig"] = KOLImageMake("images/otherimages/friarplants/plant23.gif", Vec2iMake(53,100), RectMake(2, 15, 48, 90));
        
        building_images["plant up sea daisy"] = KOLImageMake("images/otherimages/friarplants/plant40.gif", Vec2iMake(64,100), RectMake(3, 6, 60, 92));
        building_images["sunflower face"] = KOLImageMake("images/otherimages/friarplants/plant40.gif", Vec2iMake(64,100), RectMake(6, 6, 58, 52));
        
        building_images["ringing phone"] = KOLImageMake("images/otherimages/spookyraven/srphonering.gif", Vec2iMake(30, 51), RectMake(0, 16, 30, 46));
        
        building_images["basic hot dog"] = KOLImageMake("images/itemimages/jarl_regdog.gif", Vec2iMake(30,30));
        building_images["Island War Arena"] = KOLImageMake("images/otherimages/bigisland/6.gif", Vec2iMake(100,100), RectMake(17, 28, 89, 76));
        building_images["Island War Lighthouse"] = KOLImageMake("images/otherimages/bigisland/17.gif", Vec2iMake(100,100), RectMake(30, 34, 68, 97));
        building_images["Island War Nuns"] = KOLImageMake("images/otherimages/bigisland/19.gif", Vec2iMake(100,100), RectMake(20, 43, 78, 87));
        building_images["Island War Farm"] = KOLImageMake("images/otherimages/bigisland/15.gif", Vec2iMake(100,100), RectMake(8, 50, 93, 88));
        building_images["Island War Orchard"] = KOLImageMake("images/otherimages/bigisland/3.gif", Vec2iMake(100,100), RectMake(20, 36, 99, 87));
        
        building_images["Island War Junkyard"] = KOLImageMake("images/otherimages/bigisland/25.gif", Vec2iMake(100,100), RectMake(0, 4, 99, 89));
        building_images["Island War Junkyard"].erase_zones.listAppend(RectMake(0, 2, 20, 6));
        building_images["Island War Junkyard"].erase_zones.listAppend(RectMake(9, 41, 95, 52));
        
        
        building_images["spookyraven manor"] = KOLImageMake("images/otherimages/town/manor.gif", Vec2iMake(100,100), RectMake(0, 22, 99, 99));
        
        building_images["spookyraven manor"].erase_zones.listAppend(RectMake(23, 18, 53, 28));
        
        
        building_images["spookyraven manor locked"] = KOLImageMake("images/otherimages/town/pantry.gif", Vec2iMake(80,80), RectMake(0, 26, 79, 79));
        
        building_images["haunted billiards room"] = KOLImageMake("images/otherimages/manor/sm4.gif", Vec2iMake(100,100), RectMake(12, 10, 93, 63));
        
        building_images["haunted library"] = KOLImageMake("images/otherimages/manor/sm7.gif", Vec2iMake(100,100), RectMake(14, 5, 92, 55));
        
        building_images["haunted bedroom"] = KOLImageMake("images/otherimages/manor/sm2_1b.gif", Vec2iMake(100,100), RectMake(18, 28, 91, 86));
        building_images["Haunted Ballroom"] = KOLImageMake("images/otherimages/manor/sm2_5.gif", Vec2iMake(100,200), RectMake(19, 11, 74, 76));
        
        building_images["Palindome"] = KOLImageMake("images/otherimages/plains/the_palindome.gif", Vec2iMake(96,86), RectMake(0, 17, 96, 83));
        
        
        building_images["high school"] = KOLImageMake("images/otherimages/town/kolhs.gif", Vec2iMake(100,100), RectMake(0, 26, 99, 92));
        //building_images["Toot Oriole"] = KOLImageMake("images/otherimages/oriole.gif", Vec2iMake(60,100), RectMake(0, 12, 59, 85));
        building_images["Toot Oriole"] = KOLImageMake("images/otherimages/mountains/noobsingtop.gif", Vec2iMake(200,100), RectMake(52, 18, 131, 49)); //I love this GIF

        building_images["bookshelf"] = KOLImageMake("images/otherimages/campground/bookshelf.gif", Vec2iMake(100,100), RectMake(0, 26, 99, 99));
        building_images["pirate quest"] = KOLImageMake("images/otherimages/trophy/party_on_the_big_boat.gif", Vec2iMake(100,100), RectMake(18, 3, 87, 64));
        building_images["meat"] = KOLImageMake("images/itemimages/meat.gif", Vec2iMake(30,30));
        building_images["monk"] = KOLImageMake("images/itemimages/monkhead.gif", Vec2iMake(30,30));
        
        
        building_images["Pyramid"] = KOLImageMake("images/otherimages/desertbeach/pyramid.gif", Vec2iMake(60,70), RectMake(12, 11, 47, 38));
        building_images["Pyramid"].erase_zones.listAppend(RectMake(14, 19, 19, 22));
        building_images["Pyramid"].erase_zones.listAppend(RectMake(41, 12, 45, 16));
        
        
        //building_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(114, 38, 213, 159)); //building, don't like
        //building_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(7, 240, 77, 294)); //shrine, too close to hidden temple
        building_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(426, 13, 504, 61)); //hidden tavern, small, better
        building_images["Dispensary"] = KOLImageMake("images/adventureimages/knobwindow.gif", Vec2iMake(100,100));
        
        
        building_images["Wine Racks"] = KOLImageMake("images/otherimages/manor/cellar4.gif", Vec2iMake(100,100), RectMake(17, 11, 96, 65));
        building_images["Wine Racks"].erase_zones.listAppend(RectMake(17, 11, 33, 12));
        building_images["Wine Racks"].erase_zones.listAppend(RectMake(39, 61, 42, 66));
        building_images["Wine Racks"].erase_zones.listAppend(RectMake(70, 61, 74, 66));
        building_images["Wine Racks"].erase_zones.listAppend(RectMake(94, 45, 97, 54));
        building_images["Wine Racks"].erase_zones.listAppend(RectMake(17, 49, 18, 53));
        
        
        building_images["black forest"] = KOLImageMake("images/otherimages/woods/bforest.gif", Vec2iMake(100,100), RectMake(0, 19, 99, 99));
        
        building_images["possessed wine rack"] = KOLImageMake("images/adventureimages/winerack.gif", Vec2iMake(100,100), RectMake(0, 0, 99, 99));
        building_images["cabinet of Dr. Limpieza"] = KOLImageMake("images/adventureimages/laundrycabinet.gif", Vec2iMake(100,100), RectMake(0, 0, 99, 99));
        building_images["monstrous boiler"] = KOLImageMake("images/adventureimages/boiler.gif", Vec2iMake(100,100), RectMake(0, 0, 99, 99));
        
        
        
        building_images["Dad Sea Monkee"] = KOLImageMake("images/adventureimages/dad_machine.gif", Vec2iMake(400,300), RectMake(150,212,245,260));
        building_images["Shub-Jigguwatt"] = KOLImageMake("images/adventureimages/shub-jigguwatt.gif", Vec2iMake(300,300), RectMake(19, 17, 267, 288));
        building_images["Yog-Urt"] = KOLImageMake("images/adventureimages/yog-urt.gif", Vec2iMake(300,300), RectMake(36, 88, 248, 299));
        building_images["Sea"] = KOLImageMake("images/adventureimages/wizardfish.gif", Vec2iMake(100,100), RectMake(18, 23, 61, 72));
        building_images["Sea"].erase_zones.listAppend(RectMake(18, 23, 27, 28));
        building_images["Sea"].erase_zones.listAppend(RectMake(48, 23, 62, 35));
        building_images["Spooky little girl"] = KOLImageMake("images/adventureimages/axelgirl.gif", Vec2iMake(100,100), RectMake(37, 25, 63, 74));
        
        //hermit.gif and oldman.gif are almost identical. twins?
        
        building_images["astral spirit"] = KOLImageMake("images/otherimages/spirit.gif", Vec2iMake(60,100));
        building_images["Disco Bandit"] = KOLImageMake("images/otherimages/discobandit_f.gif", Vec2iMake(60,100), RectMake(0,6,59,87));
        building_images["Seal Clubber"] = KOLImageMake("images/otherimages/sealclubber_f.gif", Vec2iMake(60,100), RectMake(0,9,59,92));
        building_images["Turtle Tamer"] = KOLImageMake("images/otherimages/turtletamer_f.gif", Vec2iMake(60,100), RectMake(0,5,59,93));
        building_images["Pastamancer"] = KOLImageMake("images/otherimages/pastamancer_f.gif", Vec2iMake(60,100), RectMake(0,0,59,91));
        building_images["Sauceror"] = KOLImageMake("images/otherimages/sauceror_f.gif", Vec2iMake(60,100), RectMake(0,5,59,90));
        building_images["Accordion Thief"] = KOLImageMake("images/otherimages/accordionthief_f.gif", Vec2iMake(60,100), RectMake(0,2,59,99));
        building_images["Avatar of Sneaky Pete"] = KOLImageMake("images/otherimages/peteavatar_f.gif", Vec2iMake(60,100), RectMake(1,7,59,96));
        building_images["Avatar of Jarlsberg"] = KOLImageMake("images/otherimages/jarlsberg_avatar_f.gif", Vec2iMake(60,100), RectMake(0,6,59,96));
        building_images["Avatar of Boris"] = KOLImageMake("images/otherimages/boris_avatar_f.gif", Vec2iMake(60,100), RectMake(0,4,59,93));
        building_images["Zombie Master"] = KOLImageMake("images/otherimages/zombavatar_f.gif", Vec2iMake(60,100), RectMake(10,3,55,99));

        building_images["Nemesis Disco Bandit"] = KOLImageMake("images/adventureimages/newwave.gif", Vec2iMake(100,100));
        building_images["Nemesis Seal Clubber"] = KOLImageMake("images/adventureimages/1_1.gif", Vec2iMake(100,100));
        building_images["Nemesis Turtle Tamer"] = KOLImageMake("images/adventureimages/2_1.gif", Vec2iMake(100,100));
        building_images["Nemesis Pastamancer"] = KOLImageMake("images/adventureimages/3_1.gif", Vec2iMake(100,100));
        building_images["Nemesis Sauceror"] = KOLImageMake("images/adventureimages/4_1.gif", Vec2iMake(100,100));
        building_images["Nemesis Accordion Thief"] = KOLImageMake("images/adventureimages/6_1.gif", Vec2iMake(100,100));
        building_images["Nemesis Actually Ed the Undying"] = KOLImageMake("images/itemimages/blackcheck.gif", Vec2iMake(30,30)); //being old, his true enemy is his ever-decreasing pension
        
        building_images["sword guy"] = KOLImageMake("images/otherimages/leftswordguy.gif", Vec2iMake(80,100));
        building_images["Jick"] = KOLImageMake("images/otherimages/customavatars/1.gif", Vec2iMake(60,100));
        building_images["Superhuman Cocktailcrafting"] = KOLImageMake("images/itemimages/fruitym.gif", Vec2iMake(30,30));
        
        building_images["inexplicable door"] = KOLImageMake("images/otherimages/woods/8bitdoor.gif", Vec2iMake(100,100), RectMake(15, 43, 85, 99));
        building_images["Dungeons of Doom"] = KOLImageMake("images/otherimages/town/ddoom.gif", Vec2iMake(100,100), RectMake(31, 33, 68, 99));
        
        building_images["chinatown"] = KOLImageMake("images/otherimages/jung/jung_chinaback.gif", Vec2iMake(450,500), RectMake(188, 202, 229, 270));
        building_images["chinatown"].erase_zones.listAppend(RectMake(227, 247, 231, 256));
        
        
        building_images["barrel god"] = KOLImageMake("images/otherimages/bgshrine.gif", Vec2iMake(100,100), RectMake(29, 39, 69, 81));
        
        building_images["__skill Easy Riding"] = KOLImageMake("images/itemimages/motorbike.gif", Vec2iMake(30,30));
        building_images["__skill jump shark"] = KOLImageMake("images/itemimages/sharkfin.gif", Vec2iMake(30,30));
        building_images["__skill Natural Dancer"] = KOLImageMake("images/itemimages/dance3.gif", Vec2iMake(30,30));
        building_images["__skill Check Mirror"] = KOLImageMake("images/itemimages/bikemirror.gif", Vec2iMake(30,30));
        building_images["__skill Ball Lightning"] = KOLImageMake("images/itemimages/balllightning.gif", Vec2iMake(30,30));
        building_images["__skill rain man"] = KOLImageMake("images/itemimages/rainman.gif", Vec2iMake(30,30));
        building_images["__skill Wisdom of Thoth"] = KOLImageMake("images/itemimages/thoth.gif", Vec2iMake(30,30));
        
        building_images["lair registration desk"] = KOLImageMake("images/otherimages/nstower/nstower_regdesk.gif", Vec2iMake(100,61), RectMake(30, 3, 68, 41));
        
        
        building_images["mini-adventurer blank female"] = KOLImageMake("images/itemimages/miniadv0f.gif", Vec2iMake(30,30));
        building_images["mini-adventurer seal clubber female"] = KOLImageMake("images/itemimages/miniadv1f.gif", Vec2iMake(30,30));
        building_images["mini-adventurer turtle tamer female"] = KOLImageMake("images/itemimages/miniadv2f.gif", Vec2iMake(30,30));
        building_images["mini-adventurer pastamancer female"] = KOLImageMake("images/itemimages/miniadv3f.gif", Vec2iMake(30,30));
        building_images["mini-adventurer sauceror female"] = KOLImageMake("images/itemimages/miniadv4f.gif", Vec2iMake(30,30));
        building_images["mini-adventurer disco bandit female"] = KOLImageMake("images/itemimages/miniadv5f.gif", Vec2iMake(30,30));
        building_images["mini-adventurer accordion thief female"] = KOLImageMake("images/itemimages/miniadv6f.gif", Vec2iMake(30,30));
        
        building_images["Lady Spookyraven"] = KOLImageMake("images/otherimages/spookyraven/sr_ladys.gif", Vec2iMake(65,65), RectMake(0, 0, 64, 37));
        building_images["Yeti"] = KOLImageMake("images/adventureimages/yeti.gif", Vec2iMake(100,100), RectMake(12, 0, 80, 98));
        building_images["Lights Out"] = KOLImageMake("images/adventureimages/lightning.gif", Vec2iMake(100,100), RectMake(0, 10, 99, 96));
        building_images["stench airport kiosk"] = KOLImageMake("images/otherimages/dinseylandfill_bg.gif", Vec2iMake(500,500), RectMake(163, 438, 225, 494));
    
        foreach key in building_images
        {
            __kol_images[key.to_lower_case()] = building_images[key];
        }

    }
    initialiseConstantKOLImages();
}

boolean __kol_images_has_inited = false;
//Does not need to be called directly.
void KOLImagesInit()
{
    if (__kol_images_has_inited)
        return;
        
	PageAddCSSClass("div", "r_image_container", "overflow:hidden;position:relative;top:0px;left:0px;");
    __kol_images_has_inited = true;
    KOLimage [string] building_images;
	
	string class_name = my_class().to_string().to_lower_case();
	string class_nemesis_name = "nemesis " + class_name;
	
	if (__kol_images contains class_name)
		building_images["player character"] = __kol_images[class_name];
	else
		building_images["player character"] = __kol_images["disco bandit"];
		
	if (__kol_images contains class_nemesis_name)
		building_images["nemesis"] = __kol_images[class_nemesis_name];
	else
		building_images["nemesis"] = __kol_images["jick"];
    
    
    
    foreach key in building_images
    {
        __kol_images[key.to_lower_case()] = building_images[key];
    }
}



KOLImage KOLImageLookup(string lookup_name)
{
    KOLImagesInit();
	if (!(__kol_images contains lookup_name))
	{
		//Automatically look up items, familiars, and effects by name:
		item it = lookup_name.to_item();
		familiar f = lookup_name.to_familiar();
		effect e = lookup_name.to_effect();
        monster m = $monster[none];
        skill s = $skill[none];
        string secondary_lookup_name = lookup_name;
        if (lookup_name.stringHasPrefix("__item "))
        {
            secondary_lookup_name = lookup_name.substring(7);
            f = $familiar[none];
            e = $effect[none];
            it = secondary_lookup_name.to_item();
        }
        else if (lookup_name.stringHasPrefix("__familiar "))
        {
            secondary_lookup_name = lookup_name.substring(11);
            it = $item[none];
            e = $effect[none];
            f = secondary_lookup_name.to_familiar();
        }
        else if (lookup_name.stringHasPrefix("__effect "))
        {
            secondary_lookup_name = lookup_name.substring(9);
            f = $familiar[none];
            it = $item[none];
            e = secondary_lookup_name.to_effect();
        }
        else if (lookup_name.stringHasPrefix("__monster "))
        {
            secondary_lookup_name = lookup_name.substring(10);
            f = $familiar[none];
            it = $item[none];
            e = $effect[none];
            m = secondary_lookup_name.to_monster();
        }
        else if (lookup_name.stringHasPrefix("__skill "))
        {
            secondary_lookup_name = lookup_name.substring(8);
            f = $familiar[none];
            it = $item[none];
            e = $effect[none];
            s = secondary_lookup_name.to_skill();
        }
        //Disabled for now - skill images are a new feature.
        /*if (lookup_name.stringHasPrefix("__skill "))
        {
            secondary_lookup_name = lookup_name.substring(8);
            skill s = secondary_lookup_name.to_skill();
            
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + s.image, Vec2iMake(30,30));
            return __kol_images[lookup_name];
        }*/
        secondary_lookup_name = secondary_lookup_name.to_lower_case();
		if (it != $item[none] && it.smallimage != "" && it.to_string().to_lower_case() == secondary_lookup_name)
		{
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + it.smallimage, Vec2iMake(30,30));
		}
		else if (f != $familiar[none] && f.image != "" && f.to_string().to_lower_case() == secondary_lookup_name)
		{
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + f.image, Vec2iMake(30,30));
		}
        else if (e != $effect[none] && e.image != "" && e.to_string().to_lower_case() == secondary_lookup_name)
        {
            __kol_images[lookup_name] = KOLImageMake(e.image, Vec2iMake(30,30));
        }
        else if (m != $monster[none] && m.image != "" && m.to_string().to_lower_case() == secondary_lookup_name)
        {
            __kol_images[lookup_name] = KOLImageMake("images/adventureimages/" + m.image, Vec2iMake(100, 100));
        }
        else if (s != $skill[none] && s.image != "" && s.to_string().to_lower_case() == secondary_lookup_name)
        {
			__kol_images[lookup_name] = KOLImageMake("images/itemimages/" + s.image, Vec2iMake(30,30));
        }
		else
		{
            if (__setting_debug_mode)
                print("Unknown image \"" + lookup_name + "\"");
			return KOLImageMake();
		}
	}
	return __kol_images[lookup_name];
}

Vec2i __kol_image_generate_image_html_return_final_size;
buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_centre, Vec2i max_image_dimensions, string container_additional_class)
{
    KOLImagesInit();
	lookup_name = to_lower_case(lookup_name);
    
    boolean half_sized_output = false;
    boolean item_sized_output = false;
	lookup_name = lookup_name.to_lower_case();
    if (lookup_name.stringHasPrefix("__half "))
    {
        lookup_name = lookup_name.substring(7);
        half_sized_output = true;
    }
    if (lookup_name.stringHasPrefix("__itemsize "))
    {
        lookup_name = lookup_name.substring(11);
        item_sized_output = true;
    }
    
    __kol_image_generate_image_html_return_final_size = Vec2iZero();
    
	KOLImage kol_image = KOLImageLookup(lookup_name);
	buffer result;
	if (kol_image.url == "")
		return "".to_buffer();
    
    Vec2i image_size = Vec2iCopy(kol_image.base_image_size);
    Rect image_crop = RectCopy(kol_image.crop);
    
    
		
	boolean have_size = true;
	boolean have_crop = true;
	if (image_size.x == 0 || image_size.y == 0)
		have_size = false;
	if (image_crop.max_coordinate.x == 0 || image_crop.max_coordinate.y == 0)
		have_crop = false;
    
    
    float scale_ratio = 1.0;
    if (have_size || have_crop)
    {
        Vec2i effective_image_size = image_size;
            
        if (half_sized_output)
        {
            effective_image_size.x = round(effective_image_size.x.to_float() * 0.5);
            effective_image_size.y = round(effective_image_size.y.to_float() * 0.5);
        }
        if (item_sized_output)
        {
            //FIXME this will result in incorrect proportions for nonsquare images
            //also crop? what crop?
            effective_image_size.x = MIN(effective_image_size.x, 30.0);
            effective_image_size.y = MIN(effective_image_size.y, 30.0);
        }
        if (have_crop)
            effective_image_size = Vec2iMake(image_crop.max_coordinate.x - image_crop.min_coordinate.x + 1, image_crop.max_coordinate.y - image_crop.min_coordinate.y + 1);
        
        if (half_sized_output && have_crop)
        {
            image_crop.min_coordinate.x = round(image_crop.min_coordinate.x.to_float() * 0.5);
            image_crop.min_coordinate.y = round(image_crop.min_coordinate.y.to_float() * 0.5);
            image_crop.max_coordinate.x = round(image_crop.max_coordinate.x.to_float() * 0.5);
            image_crop.max_coordinate.y = round(image_crop.max_coordinate.y.to_float() * 0.5);
        }
        
        if (effective_image_size.x > max_image_dimensions.x || effective_image_size.y > max_image_dimensions.y)
        {
            //Scale down, to match limitations:
            float image_ratio = 1.0;
            if (effective_image_size.x != 0.0 && effective_image_size.y != 0.0)
            {
                image_ratio = effective_image_size.y.to_float() / effective_image_size.x.to_float();
                //Try width-major:
                Vec2i new_image_size = Vec2iMake(max_image_dimensions.x.to_float(), max_image_dimensions.x.to_float() * image_ratio);
                if (new_image_size.x > max_image_dimensions.x || new_image_size.y > max_image_dimensions.y) //too big, try vertical-major:
                {
                    new_image_size = Vec2iMake(max_image_dimensions.y.to_float() / image_ratio, max_image_dimensions.y);
                }
                //Find ratio:
                if (new_image_size.x != 0.0)
                {
                    scale_ratio = new_image_size.x.to_float() / effective_image_size.x.to_float();
                }
            }
        }
    }
    if (scale_ratio > 1.0) scale_ratio = 1.0;
    if (scale_ratio < 1.0)
    {
        image_size.x = round(image_size.x.to_float() * scale_ratio);
        image_size.y = round(image_size.y.to_float() * scale_ratio);
        image_crop.min_coordinate.x = ceil(image_crop.min_coordinate.x.to_float() * scale_ratio);
        image_crop.min_coordinate.y = ceil(image_crop.min_coordinate.y.to_float() * scale_ratio);
        image_crop.max_coordinate.x = floor(image_crop.max_coordinate.x.to_float() * scale_ratio);
        image_crop.max_coordinate.y = floor(image_crop.max_coordinate.y.to_float() * scale_ratio);
    }
		
	boolean outputting_div = false;
	boolean outputting_erase_zones = false;
	Vec2i div_dimensions;
    
    if (container_additional_class != "")
        outputting_div = true;
	if (have_size)
	{
		div_dimensions = image_size;
		if (have_crop)
		{
			outputting_div = true;
			div_dimensions = Vec2iMake(image_crop.max_coordinate.x - image_crop.min_coordinate.x + 1,
									   image_crop.max_coordinate.y - image_crop.min_coordinate.y + 1);
		}
		else if (image_size.x > 100)
		{
			//Automatically crop to 100 pixels wide:
			outputting_div = true;
			div_dimensions = image_size;
			div_dimensions.x = min(100, div_dimensions.x);
		}
		if (kol_image.erase_zones.count() > 0)
		{
			outputting_div = true;
			outputting_erase_zones = true;
		}
	}
	
	if (outputting_div)
	{
		string style = "";
        
        if (have_size)
            style = "width:" + div_dimensions.x + "px; height:" + div_dimensions.y + "px;";
		if (__setting_show_alignment_guides)
			style += "background:purple;";
        
        string [int] classes;
        classes.listAppend("r_image_container");
        
        if (should_centre)
            classes.listAppend("r_centre");
        if (container_additional_class != "")
            classes.listAppend(container_additional_class);
        result.append(HTMLGenerateTagPrefix("div", mapMake("class", classes.listJoinComponents(" "), "style", style)));
	}
	
	string [string] img_tag_attributes;
	img_tag_attributes["src"] = kol_image.url;
	if (have_size)
	{
		img_tag_attributes["width"] =  image_size.x;
		img_tag_attributes["height"] =  image_size.y;
        
        __kol_image_generate_image_html_return_final_size = image_size;
        
	}
    
    //Needs to be optimized to use buffers first.
    /*string unadorned_name = lookup_name;
    int breakout = 50;
    while (unadorned_name != "" && unadorned_name.stringHasPrefix("__") && breakout > 0)
    {
        int space_index = unadorned_name.index_of(" ") + 1;
        if (space_index < 0 || space_index > unadorned_name.length())
            space_index = unadorned_name.length();
        unadorned_name = unadorned_name.substring(space_index);
        breakout -= 1;
    }*/
    
	img_tag_attributes["alt"] = lookup_name.HTMLEscapeString();
	//img_tag_attributes["title"] = unadorned_name.HTMLEscapeString();
	
	if (have_crop && outputting_div)
	{
		//cordinates are upper-left
		//format is clip:rect(top-edge,right-edge,bottom-edge,left-edge);
		
		int top_edge = image_crop.min_coordinate.y;
		int bottom_edge = image_crop.max_coordinate.y;
		int left_edge = image_crop.min_coordinate.x;
		int right_edge = image_crop.max_coordinate.x;
		
		int margin_top = -(image_crop.min_coordinate.y);
		int margin_bottom = -(image_size.y - image_crop.max_coordinate.y);
		int margin_left = -(image_crop.min_coordinate.x);
		int margin_right = -(image_size.x - image_crop.max_coordinate.x);
		img_tag_attributes["style"] = "margin: " + margin_top + "px " + margin_right + "px " + margin_bottom + "px " + margin_left + "px;";
        
        
        
        __kol_image_generate_image_html_return_final_size = Vec2iMake(right_edge - left_edge, bottom_edge - top_edge);
	}
	
	if (__setting_show_alignment_guides)
		img_tag_attributes["style"] += "opacity: 0.5;";
	
	result.append(HTMLGenerateTagPrefix("img", img_tag_attributes));
	
	if (outputting_erase_zones)
	{
		foreach i in kol_image.erase_zones
		{
			Rect zone = RectCopy(kol_image.erase_zones[i]);
			Vec2i dimensions = Vec2iMake(zone.max_coordinate.x - zone.min_coordinate.x + 1, zone.max_coordinate.y - zone.min_coordinate.y + 1);
            //print_html("zone = " + zone.to_json());
            if (scale_ratio < 1.0)
            {
                dimensions.x = round(dimensions.x.to_float() * scale_ratio);
                dimensions.y = round(dimensions.y.to_float() * scale_ratio);
                zone.min_coordinate.x = round(zone.min_coordinate.x.to_float() * scale_ratio);
                zone.min_coordinate.y = round(zone.min_coordinate.y.to_float() * scale_ratio);
                zone.max_coordinate.x = round(zone.max_coordinate.x.to_float() * scale_ratio);
                zone.max_coordinate.y = round(zone.max_coordinate.y.to_float() * scale_ratio);
            }
			
			int top = 0;
			int left = 0;
			
			top = -image_crop.min_coordinate.y;
			left = -image_crop.min_coordinate.x;
			
			top += zone.min_coordinate.y;
			left += zone.min_coordinate.x;
			//Output a white div over this area:
            buffer style;
            style.append("width:");
            style.append(dimensions.x);
            style.append("px;height:");
            style.append(dimensions.y);
            style.append("px;");
			if (__setting_show_alignment_guides)
				style.append("background:pink;");
			else
				style.append("background:#FFFFFF;");
			
            style.append("z-index:2;position:absolute;top:");
            style.append(top);
            style.append("px;left:");
            style.append(left);
            style.append("px;");
			
			result.append(HTMLGenerateDivOfStyle("", style));
		}
	}
	
	if (outputting_div)
		result.append("</div>");
	return result;
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_centre, Vec2i max_image_dimensions)
{
    return KOLImageGenerateImageHTML(lookup_name, should_centre, max_image_dimensions, "");
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_centre)
{
	return KOLImageGenerateImageHTML(lookup_name, should_centre, Vec2iMake(65535, 65535));
}

static
{
    //Rect [string] __minimum_bounding_box_of_image_url;
    int [string] __minimum_y_of_image_url;
    ServerImageStats [string] __server_image_stats;
    
    void initialiseMinimumBoundingBoxOfImageURL()
    {
        //Rect rm(int min_x, int min_y, int max_x, int max_y) { return RectMake(min_x, min_y, max_x, max_y); }
        //Vec2i vm(int x, int y) { return Vec2iMake(x, y); }
        //Rect test = rm(0,0,0,0);
        ServerImageStats im(int width, int height, int min_y, int max_y) { return ServerImageStatsMake(width, height, min_y, max_y); }
        ServerImageStats im(int min_y, int max_y) { return ServerImageStatsMake(100, 100, min_y, max_y); }
        
        ServerImageStats [string] ism;
        int [string] ysm;
        
ism["borgelf1.gif"] = im(11, 74);ism["borgelf4.gif"] = im(19, 82);ism["borgelf2.gif"] = im(25, 87);ism["borgelf3.gif"] = im(14, 78);ism["handymanjay.gif"] = im(5, 92);ism["1335.gif"] = im(7, 93);ism["miner.gif"] = im(1, 95);ism["foreman.gif"] = im(2, 94);ism["gremlinamc.gif"] = im(12, 78);ism["abcrusher.gif"] = im(12, 89);ism["adv_smart1.gif"] = im(0, 97);ism["lower_b.gif"] = im(16, 74);ism["electriceel.gif"] = im(1, 98);ism["1boy2cups.gif"] = im(2, 91);ism["advecho.gif"] = im(0, 99);ism["whitebat.gif"] = im(33, 70);ism["mar_alert.gif"] = im(0, 99);ism["alielf.gif"] = im(4, 95);ism["spelunkalien.gif"] = im(17, 81);ism["muthamster.gif"] = im(5, 95);ism["spelunkalienq.gif"] = im(150, 150, 17, 141);ism["spelunkufo.gif"] = im(21, 78);ism["steve.gif"] = im(0, 98);ism["catfish.gif"] = im(41, 91);ism["giant_alphabet.gif"] = im(1, 97);ism["elf_amateur.gif"] = im(10, 83);ism["ninja.gif"] = im(13, 85);ism["pirate2.gif"] = im(6, 93);ism["crimbominer3.gif"] = im(2, 97);ism["amokputty.gif"] = im(5, 84);ism["srpainting2.gif"] = im(20, 82);ism["regret3.gif"] = im(27, 79);ism["oldguardstatue.gif"] = im(0, 97);ism["pebbleman.gif"] = im(2, 89);ism["mariner.gif"] = im(5, 93);ism["protspirit.gif"] = im(7, 86);ism["guardstatue.gif"] = im(0, 98);ism["bb_horror.gif"] = im(125, 100, 5, 89);ism["anemone.gif"] = im(0, 97);ism["bb_doctor.gif"] = im(7, 83);ism["angel.gif"] = im(6, 87);ism["angerman.gif"] = im(200, 250, 15, 242);ism["anglerbush.gif"] = im(0, 97);ism["mh_bassist.gif"] = im(2, 97);ism["angbugbear.gif"] = im(6, 91);ism["bb_caveman.gif"] = im(4, 92);ism["mush_angry.gif"] = im(8, 89);ism["pinata.gif"] = im(0, 97);ism["madpoet.gif"] = im(7, 93);ism["raccoon.gif"] = im(6, 93);ism["hunter7.gif"] = im(0, 98);ism["stenchtourist.gif"] = im(0, 93);ism["nightstand2.gif"] = im(13, 91);ism["darkstand.gif"] = im(1, 98);ism["nightstand.gif"] = im(2, 96);ism["nightstand4.gif"] = im(1, 99);ism["fear2.gif"] = im(1, 95);ism["nightstand3.gif"] = im(7, 95);ism["spittoon.gif"] = im(3, 99);ism["smiley.gif"] = im(30, 67);ism["annoyfairy.gif"] = im(15, 76);ism["spiderserver.gif"] = im(7, 94);ism["lizardman.gif"] = im(4, 94);ism["aquabat.gif"] = im(150, 100, 15, 79);ism["aquaconda.gif"] = im(5, 91);ism["aquagoblin.gif"] = im(0, 99);ism["2headseal.gif"] = im(9, 81);ism["mush_armor.gif"] = im(7, 91);ism["adv_spooky4.gif"] = im(4, 96);ism["adv_stench3.gif"] = im(5, 95);ism["astronomer.gif"] = im(6, 93);ism["aquadargon.gif"] = im(200, 200, 6, 190);ism["elf_auteur.gif"] = im(15, 78);ism["disco_awkward.gif"] = im(4, 95);ism["axehandle.gif"] = im(9, 89);ism["axewound.gif"] = im(9, 87);ism["saucezombie.gif"] = im(0, 97);ism["stone_serpent.gif"] = im(0, 98);ism["stone_sheep.gif"] = im(21, 81);ism["baconsnake.gif"] = im(4, 96);ism["badascii.gif"] = im(35, 61);ism["pa_potatoes.gif"] = im(8, 95);ism["baglady.gif"] = im(0, 99);ism["warhipmo.gif"] = im(44, 98);ism["baiowulf.gif"] = im(8, 94);ism["spelunkbanana.gif"] = im(150, 150, 0, 149);ism["bangyomama.gif"] = im(2, 89);ism["banjowizard.gif"] = im(0, 99);ism["banshee.gif"] = im(6, 98);ism["bar.gif"] = im(13, 88);ism["ratsworth.gif"] = im(0, 96);ism["basaltamander.gif"] = im(0, 99);ism["ballbat.gif"] = im(7, 60);ism["reindeer.gif"] = im(0, 99);ism["basicgolem.gif"] = im(6, 89);ism["spelunkbat.gif"] = im(15, 77);ism["bb_bat.gif"] = im(27, 81);ism["adv_spooky3.gif"] = im(1, 93);ism["batrat.gif"] = im(25, 75);ism["snakeboss5.gif"] = im(150, 150, 13, 141);ism["bb_mech.gif"] = im(1, 98);ism["aboo_wars.gif"] = im(3, 98);ism["gremlinbat.gif"] = im(11, 83);ism["bazookafish.gif"] = im(25, 68);ism["beanbat.gif"] = im(28, 63);ism["topi2.gif"] = im(9, 93);ism["earbeast.gif"] = im(14, 80);ism["eyebeast.gif"] = im(17, 99);ism["beaver.gif"] = im(13, 77);ism["spelunkbee.gif"] = im(3, 86);ism["beeswarm.gif"] = im(3, 97);ism["beethoven.gif"] = im(5, 94);ism["beebeegunner.gif"] = im(16, 70);ism["beebeeking.gif"] = im(16, 79);ism["beebeequeue.gif"] = im(4, 97);ism["beefybat.gif"] = im(18, 58);ism["beelephant.gif"] = im(0, 89);ism["batter.gif"] = im(0, 99);ism["warfratbg.gif"] = im(0, 95);ism["straw_stench.gif"] = im(15, 93);ism["bellhop.gif"] = im(17, 89);ism["carpet.gif"] = im(33, 75);ism["novelist.gif"] = im(2, 92);ism["wraith2.gif"] = im(15, 89);ism["biclops.gif"] = im(4, 92);ism["spider1.gif"] = im(15, 78);ism["bigmeat.gif"] = im(0, 94);ism["whelps2.gif"] = im(1, 98);ism["twins_bigwheel.gif"] = im(200, 100, 5, 95);ism["aquaniewski.gif"] = im(0, 97);ism["bigface.gif"] = im(14, 92);ism["vib2.gif"] = im(3, 97);ism["blimp.gif"] = im(8, 94);ism["blackadder.gif"] = im(12, 79);ism["blackcat.gif"] = im(4, 90);ism["cray_beast.gif"] = im(200, 200, 41, 171);ism["cray_bug.gif"] = im(200, 200, 43, 152);ism["cray_const.gif"] = im(200, 200, 15, 193);ism["cray_elf.gif"] = im(200, 200, 22, 181);ism["cray_demon.gif"] = im(200, 200, 32, 178);ism["cray_elemental.gif"] = im(200, 200, 8, 191);ism["cray_fish.gif"] = im(200, 200, 30, 145);ism["cray_plant.gif"] = im(200, 200, 9, 184);ism["cray_orc.gif"] = im(200, 200, 32, 169);ism["cray_goblin.gif"] = im(200, 200, 32, 167);ism["cray_construct.gif"] = im(200, 200, 23, 183);ism["cray_hippy.gif"] = im(200, 200, 19, 163);ism["cray_hobo.gif"] = im(200, 200, 1, 198);ism["cray_dude.gif"] = im(200, 200, 7, 182);ism["cray_humanoid.gif"] = im(200, 200, 12, 188);ism["cray_merkin.gif"] = im(200, 200, 17, 172);ism["cray_penguin.gif"] = im(200, 200, 31, 185);ism["cray_pirate.gif"] = im(200, 200, 18, 179);ism["cray_horror.gif"] = im(200, 200, 1, 197);ism["cray_slime.gif"] = im(200, 200, 61, 166);ism["cray_weird.gif"] = im(200, 200, 27, 186);ism["cray_undead.gif"] = im(200, 200, 22, 162);ism["blackfriar.gif"] = im(5, 97);ism["blknight.gif"] = im(4, 90);ism["witchywoman.gif"] = im(1, 99);ism["bb_ninja.gif"] = im(5, 91);ism["panther.gif"] = im(11, 93);ism["blpudding.gif"] = im(47, 98);ism["blackwidow.gif"] = im(0, 99);ism["pengblackop.gif"] = im(3, 98);ism["blackbush.gif"] = im(15, 98);ism["sawblade.gif"] = im(0, 98);ism["firebat.gif"] = im(1, 97);ism["squid.gif"] = im(3, 95);ism["bluecultist.gif"] = im(0, 99);ism["mh_bluehair.gif"] = im(1, 98);ism["blur.gif"] = im(4, 97);ism["boaraffe.gif"] = im(0, 99);ism["naskar2.gif"] = im(5, 95);ism["bogleech.gif"] = im(10, 91);ism["bogskeleton.gif"] = im(1, 95);ism["bogart.gif"] = im(11, 91);ism["elf_boltcutters.gif"] = im(5, 78);ism["foss_wyrm.gif"] = im(200, 200, 0, 196);ism["bookbat.gif"] = im(22, 65);ism["boothslime.gif"] = im(2, 97);ism["bootycrab.gif"] = im(20, 85);ism["boozegiant.gif"] = im(5, 92);ism["borgabeeping.gif"] = im(0, 96);ism["bossbat.gif"] = im(26, 73);ism["deadbossbat.gif"] = im(7, 94);ism["crimonster3.gif"] = im(4, 96);ism["cricket.gif"] = im(5, 97);ism["box.gif"] = im(9, 87);ism["pa_muffin.gif"] = im(13, 87);ism["mystwander5.gif"] = im(5, 99);ism["broombrain.gif"] = im(6, 95);ism["bram.gif"] = im(8, 92);ism["breadgolem.gif"] = im(6, 90);ism["breakdancer.gif"] = im(0, 97);ism["brick_sleaze.gif"] = im(24, 96);ism["brick_cold.gif"] = im(1, 95);ism["brick_hot.gif"] = im(0, 99);
ism["brick_spooky.gif"] = im(4, 95);ism["kok_tender.gif"] = im(21, 97);ism["brick_stench.gif"] = im(4, 94);ism["brickoairship.gif"] = im(300, 300, 6, 295);ism["brickobat.gif"] = im(3, 68);ism["brickocathedral.gif"] = im(500, 450, 17, 443);ism["brickoelephant.gif"] = im(150, 150, 34, 132);ism["brickogchicken.gif"] = im(600, 450, 15, 444);ism["brickoctopus.gif"] = im(150, 150, 9, 143);ism["brickoblob.gif"] = im(57, 94);ism["brickooyster.gif"] = im(16, 91);ism["brickopython.gif"] = im(450, 100, 11, 87);ism["brickoturtle.gif"] = im(22, 77);ism["brickovacuum.gif"] = im(200, 200, 17, 182);ism["casebat.gif"] = im(40, 63);ism["bath_bubble.gif"] = im(17, 76);ism["iceguy5.gif"] = im(0, 97);ism["broctopus.gif"] = im(0, 99);ism["bronzechef.gif"] = im(0, 99);ism["babyseal.gif"] = im(6, 84);ism["togafrat.gif"] = im(2, 96);ism["twins_bubble.gif"] = im(13, 94);ism["bb_ghost.gif"] = im(5, 89);ism["bb_captain.gif"] = im(150, 150, 3, 143);ism["bb_drone.gif"] = im(2, 97);ism["bb_mortician.gif"] = im(9, 91);ism["robosurgeon.gif"] = im(14, 88);ism["bb_science.gif"] = im(6, 88);ism["binbox.gif"] = im(4, 91);ism["bugbugbear.gif"] = im(6, 91);ism["bulletbill.gif"] = im(15, 83);ism["bullseal.gif"] = im(9, 95);ism["ratbunch.gif"] = im(1, 92);ism["pa_meat.gif"] = im(5, 96);ism["bunsen.gif"] = im(9, 87);ism["sidekick.gif"] = im(5, 97);ism["adv_hot3.gif"] = im(18, 95);ism["snakeboss4.gif"] = im(150, 150, 19, 133);ism["bishop.gif"] = im(54, 94);ism["bush.gif"] = im(8, 93);ism["bushippy.gif"] = im(8, 94);ism["hedgerow.gif"] = im(25, 79);ism["pa_knife.gif"] = im(1, 87);ism["buzzerker.gif"] = im(11, 84);ism["buzzy.gif"] = im(0, 97);ism["chum1.gif"] = im(7, 91);ism["chumchief.gif"] = im(7, 94);ism["carnivore.gif"] = im(6, 96);ism["animbear.gif"] = im(0, 99);ism["laundrycabinet.gif"] = im(1, 98);ism["cactuary.gif"] = im(0, 97);ism["cakelord.gif"] = im(0, 98);ism["cameltoe.gif"] = im(5, 97);ism["cancan.gif"] = im(4, 97);ism["pecantree.gif"] = im(1, 98);ism["yamgolem.gif"] = im(0, 97);ism["gourd_cangoblin.gif"] = im(9, 88);ism["carbuncletop.gif"] = im(1, 92);ism["cargocrab.gif"] = im(7, 94);ism["dillplant.gif"] = im(2, 99);ism["carniv.gif"] = im(5, 94);ism["pa_eggs.gif"] = im(22, 86);ism["thecastle.gif"] = im(21, 78);ism["catalien.gif"] = im(21, 89);ism["spelunkcaveman.gif"] = im(7, 91);ism["cavedan.gif"] = im(0, 97);ism["cavefrat.gif"] = im(2, 95);ism["cavehippy.gif"] = im(0, 97);ism["cavesorority.gif"] = im(0, 95);ism["cavewomyn.gif"] = im(0, 94);ism["butt.gif"] = im(16, 81);ism["pengcement.gif"] = im(2, 97);ism["centurion.gif"] = im(7, 80);ism["adv_hot2.gif"] = im(2, 96);ism["chimp.gif"] = im(6, 90);ism["chalkdust.gif"] = im(6, 98);ism["hunter10.gif"] = im(1, 97);ism["c10chatty.gif"] = im(0, 96);ism["strix.gif"] = im(4, 93);ism["adv_stench2.gif"] = im(1, 97);ism["adv_fast1.gif"] = im(4, 93);ism["chefboy.gif"] = im(0, 98);ism["chester.gif"] = im(1, 97);ism["robotceo.gif"] = im(5, 92);ism["chocohare.gif"] = im(23, 93);ism["ccprairie.gif"] = im(1, 97);ism["soupgolem.gif"] = im(3, 93);ism["ciggirl.gif"] = im(0, 99);ism["animelf3.gif"] = im(19, 80);ism["cavebars.gif"] = im(0, 98);ism["clancy.gif"] = im(9, 94);ism["bathtub.gif"] = im(50, 97);ism["claygolem.gif"] = im(1, 98);ism["aboo_wiz.gif"] = im(3, 96);ism["cleanroomdemon.gif"] = im(5, 95);ism["cleanpirate.gif"] = im(3, 94);ism["girlpirate.gif"] = im(7, 91);ism["colaoff1.gif"] = im(4, 94);ism["colasol1.gif"] = im(6, 96);ism["rock_hopper.gif"] = im(0, 99);ism["whiskers.gif"] = im(8, 84);ism["clubfish.gif"] = im(1, 90);ism["prim_bact.gif"] = im(0, 98);ism["coaltergeist.gif"] = im(5, 91);ism["kg_oven.gif"] = im(8, 97);ism["spelunkcobra.gif"] = im(14, 77);ism["cocktailshrimp.gif"] = im(0, 99);ism["dvcoldbear1.gif"] = im(3, 97);ism["coldcutter.gif"] = im(2, 94);ism["dvcoldghost1.gif"] = im(0, 96);ism["coldhobo1.gif"] = im(5, 89);ism["wood_cold.gif"] = im(13, 96);ism["dvcoldskel1.gif"] = im(1, 95);ism["dvcoldvamp1.gif"] = im(3, 94);ism["dvcoldwolf1.gif"] = im(1, 98);ism["dvcoldzom1.gif"] = im(5, 98);ism["minegolem.gif"] = im(4, 89);ism["spider2.gif"] = im(20, 83);ism["pianist.gif"] = im(0, 98);ism["lilgoth.gif"] = im(19, 96);ism["2zombies.gif"] = im(6, 92);ism["conhippy.gif"] = im(2, 94);ism["regret1.gif"] = im(2, 90);ism["pa_cutter.gif"] = im(21, 76);ism["crimonster2.gif"] = im(0, 99);ism["coolerwino.gif"] = im(0, 97);ism["coppertender.gif"] = im(6, 91);ism["fatzombie.gif"] = im(9, 93);ism["prim_alga.gif"] = im(0, 98);ism["makeupwraith.gif"] = im(11, 81);ism["bakula.gif"] = im(7, 90);ism["drunkula.gif"] = im(100, 175, 5, 166);ism["drunkula_hm.gif"] = im(300, 175, 2, 159);ism["courtesan.gif"] = im(5, 95);ism["cowskeleton.gif"] = im(1, 97);ism["creep.gif"] = im(13, 91);ism["craggybart.gif"] = im(3, 91);ism["crate.gif"] = im(10, 89);ism["stone_raven.gif"] = im(21, 85);ism["bastard.gif"] = im(3, 94);ism["adv_smooth2.gif"] = im(3, 94);ism["clown.gif"] = im(3, 97);ism["creepydoll.gif"] = im(4, 96);ism["dianoga.gif"] = im(11, 87);ism["twins_ginger.gif"] = im(1, 98);ism["creepygirl.gif"] = im(32, 97);ism["pa_torch.gif"] = im(3, 92);ism["crimbomega.gif"] = im(400, 550, 7, 545);ism["spelunkcroc.gif"] = im(6, 89);ism["croqueteer.gif"] = im(1, 90);ism["dustmote.gif"] = im(20, 86);ism["hippy3.gif"] = im(8, 94);ism["crustpirate.gif"] = im(1, 95);ism["crys_rock.gif"] = im(200, 150, 2, 137);ism["cubistbull.gif"] = im(0, 99);ism["spelunkhawk.gif"] = im(3, 95);ism["curmpirate.gif"] = im(6, 93);ism["cybercop.gif"] = im(2, 97);ism["prim_cyru.gif"] = im(0, 98);ism["dad_machine.gif"] = im(400, 300, 6, 294);ism["daftpunk.gif"] = im(3, 97);ism["biggoat.gif"] = im(2, 98);ism["ooze.gif"] = im(45, 93);ism["dirtyape.gif"] = im(0, 99);ism["mush_dancing.gif"] = im(11, 91);ism["chad.gif"] = im(3, 93);ism["rorshach.gif"] = im(8, 79);ism["bath_showerhead.gif"] = im(2, 97);ism["venomtrout.gif"] = im(47, 99);ism["vice.gif"] = im(20, 85);ism["shiv_dead.gif"] = im(3, 94);ism["deathray.gif"] = im(4, 98);ism["lumberjack.gif"] = im(5, 92);ism["whiteshark.gif"] = im(15, 71);ism["5_4a.gif"] = im(200, 200, 0, 197);ism["demfridge.gif"] = im(1, 99);ism["jigsaw.gif"] = im(12, 83);ism["demoninja.gif"] = im(17, 89);ism["liana.gif"] = im(13, 90);ism["wanderacc1.gif"] = im(1, 97);ism["hunter8.gif"] = im(0, 97);ism["goldfarmer.gif"] = im(9, 91);ism["smoochboss4.gif"] = im(100, 200, 11, 191);ism["spelunkdevil.gif"] = im(0, 99);ism["digitalug.gif"] = im(17, 87);ism["dinnertroll.gif"] = im(13, 87);ism["direpigeon.gif"] = im(0, 98);ism["hippy2.gif"] = im(8, 93);ism["dirtyoldlihc.gif"] = im(6, 99);ism["bandit.gif"] = im(1, 95);ism["dinbox.gif"] = im(16, 91);ism["c10files.gif"] = im(7, 98);ism["divingbelle.gif"] = im(0, 99);ism["js_oh.gif"] = im(5, 91);ism["pede.gif"] = im(20, 81);ism["dogalien.gif"] = im(3, 92);ism["catdog.gif"] = im(17, 85);ism["iceguy2.gif"] = im(8, 97);ism["doncrimbo.gif"] = im(0, 99);ism["donerbagon.gif"] = im(200, 200, 1, 189);ism["dwarf_dopey.gif"] = im(0, 99);ism["doubtman.gif"] = im(200, 200, 2, 193);ism["doughbat.gif"] = im(41, 63);ism["aquard.gif"] = im(0, 99);ism["drawkward.gif"] = im(4, 95);ism["braddarb.gif"] = im(5, 96);ism["droll.gif"] = im(18, 87);ism["dropbase.gif"] = im(12, 80);ism["drownedsailor.gif"] = im(1, 97);ism["drownedbeat.gif"] = im(0, 95);ism["ducknicedrunk.gif"] = im(1, 94);ism["drunkgoat.gif"] = im(2, 98);ism["pyg_drunk.gif"] = im(9, 99);ism["drunkminer.gif"] = im(0, 98);ism["hobo.gif"] = im(5, 91);ism["rat.gif"] = im(33, 67);ism["ratking.gif"] = im(200, 200, 7, 185);ism["kok_drunk.gif"] = im(0, 93);ism["zomhobo.gif"] = im(5, 91);ism["aboo_dipshit.gif"] = im(1, 97);ism["straw_spooky.gif"] = im(39, 91);ism["dwarfgnome.gif"] = im(17, 84);ism["dweebie.gif"] = im(5, 94);ism["colaoff2.gif"] = im(4, 94);ism["colasol2.gif"] = im(6, 96);ism["eve.gif"] = im(0, 93);ism["eagle.gif"] = im(0, 98);ism["ed.gif"] = im(1, 98);ism["ed2.gif"] = im(1, 98);ism["ed3.gif"] = im(1, 98);ism["ed4.gif"] = im(1, 98);ism["ed5.gif"] = im(1, 98);ism["ed6.gif"] = im(22, 98);ism["ed7.gif"] = im(46, 98);ism["edwing.gif"] = im(24, 83);ism["eldiablo.gif"] = im(0, 99);ism["elders.gif"] = im(11, 85);ism["submarine.gif"] = im(8, 86);ism["nightstand5.gif"] = im(22, 82);ism["topi3.gif"] = im(7, 90);ism["elfhobo1.gif"] = im(28, 97);ism["warfratbg2.gif"] = im(0, 95);ism["elp_and_cros.gif"] = im(300, 150, 5, 146);ism["skinyeti.gif"] = im(4, 90);ism["armor.gif"] = im(0, 98);ism["inflatiger.gif"] = im(7, 98);ism["c10confcall.gif"] = im(2, 94);ism["grayblob3.gif"] = im(150, 200, 21, 178);ism["cow.gif"] = im(0, 99);ism["adv_strong3.gif"] = im(9, 91);ism["gremlinglasses.gif"] = im(7, 94);ism["stairmaster.gif"] = im(12, 94);ism["mc_respect3.gif"] = im(4, 94);ism["mc_soy3.gif"] = im(0, 97);ism["mc_tofu3.gif"] = im(1, 98);ism["cultist.gif"] = im(3, 98);ism["mh_evilex.gif"] = im(0, 99);ism["oliveevil.gif"] = im(13, 85);ism["spagcult2.gif"] = im(1, 95);ism["spagcult3.gif"] = im(0, 99);ism["spagcult1.gif"] = im(0, 98);ism["spagcult2k.gif"] = im(1, 95);ism["spagcult4.gif"] = im(0, 99);ism["spagcult1k.gif"] = im(0, 98);ism["trumpetmariachi.gif"] = im(2, 97);ism["vihuelamariachi.gif"] = im(2, 96);ism["crimbominer1.gif"] = im(0, 99);ism["skihippy.gif"] = im(3, 94);ism["fratboard.gif"] = im(3, 91);ism["wcorcs.gif"] = im(0, 97);
ism["witchy2.gif"] = im(0, 99);ism["darkeye.gif"] = im(5, 91);ism["guai.gif"] = im(11, 85);ism["facworker4.gif"] = im(3, 95);ism["facworker3.gif"] = im(1, 97);ism["facworker1.gif"] = im(3, 97);ism["facworker2.gif"] = im(1, 93);ism["badskel1.gif"] = im(20, 84);ism["archfiend.gif"] = im(10, 84);ism["fallsfromsky.gif"] = im(100, 150, 2, 143);ism["fallsfromsky_hm.gif"] = im(200, 300, 7, 285);ism["jewels.gif"] = im(8, 82);ism["kobolds.gif"] = im(0, 97);ism["fandancer.gif"] = im(6, 91);ism["fanslime.gif"] = im(2, 94);ism["bathslug.gif"] = im(1, 98);ism["hunter5.gif"] = im(1, 98);ism["hunter9.gif"] = im(1, 93);ism["fearman.gif"] = im(200, 200, 12, 185);ism["bath_octopus.gif"] = im(0, 98);ism["wacken.gif"] = im(200, 200, 23, 186);ism["manyeyes.gif"] = im(4, 81);ism["felonia.gif"] = im(0, 98);ism["haiku2.gif"] = im(6, 91);ism["bath_pelican.gif"] = im(1, 97);ism["ferrelf.gif"] = im(5, 90);ism["finger.gif"] = im(2, 96);ism["asparagus.gif"] = im(9, 89);ism["mush_flaming.gif"] = im(0, 99);ism["duckskate.gif"] = im(2, 98);ism["filthworm2.gif"] = im(24, 75);ism["filthworm3.gif"] = im(19, 70);ism["hippy1.gif"] = im(8, 89);ism["stinkpirate1.gif"] = im(3, 97);ism["adv_hot1.gif"] = im(1, 97);ism["firetruck.gif"] = im(300, 150, 7, 145);ism["duckfirebreath.gif"] = im(7, 91);ism["fisherfish.gif"] = im(3, 97);ism["stinkpirate3.gif"] = im(1, 93);ism["giant_fitness.gif"] = im(9, 97);ism["bigskeleton5.gif"] = im(250, 100, 0, 99);ism["meatblob.gif"] = im(10, 79);ism["samurai.gif"] = im(0, 99);ism["flametroll.gif"] = im(1, 96);ism["flange.gif"] = im(12, 78);ism["flashypirate.gif"] = im(4, 94);ism["cvfleaman.gif"] = im(5, 90);ism["woodsman.gif"] = im(9, 96);ism["disco_flexible.gif"] = im(3, 97);ism["caveelf3.gif"] = im(25, 85);ism["horstray.gif"] = im(19, 89);ism["seagulls.gif"] = im(3, 91);ism["stabbats.gif"] = im(0, 97);ism["bunny.gif"] = im(49, 94);ism["gourd_fnord.gif"] = im(200, 200, 23, 171);ism["giant_foodie.gif"] = im(4, 97);ism["forspirit.gif"] = im(21, 74);ism["bigskeleton4.gif"] = im(200, 100, 0, 99);ism["mime.gif"] = im(0, 97);ism["artteacher.gif"] = im(4, 95);ism["accboss.gif"] = im(0, 98);ism["warfrata.gif"] = im(1, 96);ism["mush_freaked.gif"] = im(9, 91);ism["frenchturtle.gif"] = im(19, 72);ism["bonefish.gif"] = im(40, 97);ism["frog.gif"] = im(53, 99);ism["frosty.gif"] = im(0, 99);ism["straw_cold.gif"] = im(12, 91);ism["mystwander3.gif"] = im(8, 94);ism["duckfrozen.gif"] = im(2, 96);ism["snakeboss1.gif"] = im(150, 150, 21, 133);ism["fruitgolem.gif"] = im(8, 97);ism["anger3.gif"] = im(0, 99);ism["fudgemonkey2.gif"] = im(0, 99);ism["fudgeoyster.gif"] = im(0, 99);ism["fudgepoodle.gif"] = im(2, 96);ism["fudgevulture.gif"] = im(0, 99);ism["fudgeweasel.gif"] = im(11, 86);ism["bigmirror.gif"] = im(0, 99);ism["fun-gal1.gif"] = im(0, 99);ism["funkparticle.gif"] = im(8, 94);ism["solebrother.gif"] = im(19, 76);ism["stinkpirate2.gif"] = im(3, 96);ism["shiv_fur.gif"] = im(1, 94);ism["giant_furry.gif"] = im(0, 98);ism["gimp.gif"] = im(15, 90);ism["gamblinman.gif"] = im(1, 95);ism["muggers.gif"] = im(2, 98);ism["ganger.gif"] = im(16, 88);ism["garbagetourist.gif"] = im(3, 94);ism["gargantulihc.gif"] = im(1, 93);ism["ghuol_skinny.gif"] = im(16, 90);ism["gelcube.gif"] = im(12, 97);ism["generalseal.gif"] = im(150, 100, 2, 97);ism["duckgeneric.gif"] = im(4, 94);ism["merkinballer2.gif"] = im(1, 99);ism["smoochboss1.gif"] = im(100, 200, 8, 189);ism["phantom.gif"] = im(1, 95);ism["cvghost.gif"] = im(4, 92);ism["spelunkghost.gif"] = im(11, 91);ism["ghostminer.gif"] = im(1, 98);ism["elizabeth.gif"] = im(10, 86);ism["fernghost.gif"] = im(1, 92);ism["worker.gif"] = im(2, 94);ism["adv_spooky1.gif"] = im(8, 91);ism["ghuol_reg.gif"] = im(11, 85);ism["giantbee.gif"] = im(2, 84);ism["pterodactyl.gif"] = im(6, 91);ism["globe.gif"] = im(0, 95);ism["friedegg.gif"] = im(2, 82);ism["centipede.gif"] = im(21, 81);ism["moth.gif"] = im(5, 95);ism["isopod.gif"] = im(35, 95);ism["python.gif"] = im(4, 93);ism["bath_whale.gif"] = im(14, 82);ism["manyspiders.gif"] = im(1, 94);ism["watertentacle.gif"] = im(6, 93);ism["tweezers.gif"] = im(6, 93);ism["headpumpkin.gif"] = im(5, 96);ism["rubberspider.gif"] = im(15, 84);ism["sandworm.gif"] = im(2, 99);ism["giantskel.gif"] = im(0, 99);ism["tarantula.gif"] = im(1, 97);ism["giantsquid.gif"] = im(0, 98);ism["whelps3.gif"] = im(0, 99);ism["tardigrade.gif"] = im(4, 91);ism["zomfish.gif"] = im(2, 86);ism["crimonster5.gif"] = im(0, 92);ism["gingerbreadman.gif"] = im(0, 99);ism["gladiator.gif"] = im(1, 96);ism["juiceglass.gif"] = im(12, 87);ism["wood_hot.gif"] = im(3, 95);ism["ghuol_fat.gif"] = im(13, 87);ism["gnarlgnome.gif"] = im(9, 79);ism["gnasgnome.gif"] = im(6, 77);ism["gnefgnome.gif"] = im(12, 83);ism["dk_builder.gif"] = im(9, 97);ism["dk_cross.gif"] = im(3, 94);ism["dk_swatter.gif"] = im(3, 95);ism["dk_gearhead.gif"] = im(1, 97);ism["dk_piechef.gif"] = im(0, 99);ism["dk_plunger.gif"] = im(3, 93);ism["gnollmage.gif"] = im(3, 95);ism["dk_juggler.gif"] = im(1, 97);ism["dk_warchef.gif"] = im(0, 98);ism["gnomester.gif"] = im(5, 91);ism["gnugnome.gif"] = im(10, 84);ism["gourd_goblin.gif"] = im(7, 92);ism["goldenring.gif"] = im(17, 86);ism["goomba.gif"] = im(9, 89);ism["goosealaying.gif"] = im(0, 99);ism["1_4a.gif"] = im(200, 200, 2, 198);ism["1_1.gif"] = im(18, 93);ism["1_2.gif"] = im(10, 92);ism["1_3.gif"] = im(10, 93);ism["giant_goth.gif"] = im(3, 96);ism["gourami.gif"] = im(51, 93);ism["gov_agent.gif"] = im(11, 94);ism["scientist.gif"] = im(3, 95);ism["adv_stench1.gif"] = im(6, 97);ism["grasselemental.gif"] = im(0, 99);ism["grasspirate.gif"] = im(0, 95);ism["rober.gif"] = im(8, 91);ism["zomshovel.gif"] = im(4, 94);ism["adv_sleaze1.gif"] = im(3, 90);ism["duckgreasy.gif"] = im(0, 91);ism["wolfoftheair.gif"] = im(200, 150, 8, 136);ism["wolfoftheair_hm.gif"] = im(200, 150, 7, 135);ism["warhipgr.gif"] = im(5, 93);ism["porkbun.gif"] = im(14, 79);ism["gritpirate.gif"] = im(1, 97);ism["surv_grizzled.gif"] = im(3, 91);ism["wingedyeti.gif"] = im(200, 100, 0, 99);ism["groast.gif"] = im(5, 94);ism["grouchewie.gif"] = im(7, 90);ism["cultistgroup.gif"] = im(4, 96);ism["groupie.gif"] = im(16, 85);ism["dwarf_grumpy.gif"] = im(0, 99);ism["grungypirate.gif"] = im(11, 95);ism["guardturtle1.gif"] = im(29, 89);ism["plesio.gif"] = im(1, 98);ism["gurgle.gif"] = im(150, 100, 0, 99);ism["animturtle.gif"] = im(100, 120, 4, 118);ism["beeguy.gif"] = im(0, 96);ism["gothic.gif"] = im(4, 96);ism["adv_sleaze2.gif"] = im(6, 89);ism["drunkyam.gif"] = im(0, 99);ism["hamsterpus.gif"] = im(2, 88);ism["mariachi1.gif"] = im(2, 97);ism["shiv_hangman.gif"] = im(3, 93);ism["hunter12.gif"] = im(3, 97);ism["skullabra.gif"] = im(1, 91);ism["tureen.gif"] = im(6, 87);ism["crystalgolem.gif"] = im(1, 92);ism["heatseal.gif"] = im(0, 99);ism["warfratar2.gif"] = im(10, 88);ism["nachogolem.gif"] = im(0, 98);ism["hellion.gif"] = im(3, 95);ism["sealguard.gif"] = im(13, 95);ism["sealpup.gif"] = im(29, 81);ism["hepcat.gif"] = im(1, 98);ism["hunter6.gif"] = im(3, 96);ism["hermeticseal.gif"] = im(5, 88);ism["c10slideshow.gif"] = im(10, 89);ism["highpriest.gif"] = im(0, 99);ism["warbear31.gif"] = im(0, 99);ism["snakes.gif"] = im(2, 83);ism["hockeyelem.gif"] = im(6, 90);ism["hodgman.gif"] = im(1, 96);ism["holoarmy.gif"] = im(2, 92);ism["honeypot.gif"] = im(5, 92);ism["hooded.gif"] = im(4, 96);ism["stenchfamily.gif"] = im(4, 96);ism["prim_amoe.gif"] = im(0, 98);ism["dvhotbear1.gif"] = im(5, 94);ism["dvhotghost1.gif"] = im(4, 93);ism["hothobo1.gif"] = im(3, 92);ism["dvhotskel1.gif"] = im(13, 99);ism["dvhotvamp1.gif"] = im(0, 98);ism["dvhotwolf1.gif"] = im(12, 98);ism["dvhotzom1.gif"] = im(1, 98);ism["mimic4.gif"] = im(1, 97);ism["ghuol_huge.gif"] = im(5, 95);ism["giantmosquito.gif"] = im(0, 98);ism["iceguy1.gif"] = im(1, 98);ism["bridgetroll.gif"] = im(2, 97);ism["vib6.gif"] = im(7, 98);ism["caveelf2.gif"] = im(18, 73);ism["huntingseal.gif"] = im(9, 85);ism["poolghost.gif"] = im(0, 99);ism["hypnotist.gif"] = im(0, 97);ism["medicus.gif"] = im(3, 92);ism["bb_vamp.gif"] = im(3, 93);ism["adv_cold2.gif"] = im(0, 98);ism["icecreamtruck.gif"] = im(400, 150, 9, 142);ism["icecube.gif"] = im(12, 94);ism["iceskate.gif"] = im(4, 96);ism["adv_cold3.gif"] = im(8, 93);ism["mummycat.gif"] = im(1, 96);ism["illegal_alien.gif"] = im(24, 96);ism["vib3.gif"] = im(0, 99);ism["drunktofurkey.gif"] = im(0, 99);ism["seal_larva.gif"] = im(63, 93);ism["seal_baby.gif"] = im(47, 93);ism["meatbug.gif"] = im(7, 89);ism["inkubus.gif"] = im(7, 97);ism["mariachi2.gif"] = im(2, 91);ism["adv_strong2.gif"] = im(5, 92);ism["encount.gif"] = im(3, 93);ism["jacobsadder.gif"] = im(0, 99);ism["orquette1.gif"] = im(13, 86);ism["jamfish.gif"] = im(0, 98);ism["pilot.gif"] = im(3, 97);ism["jetski.gif"] = im(15, 94);ism["jockohomo.gif"] = im(0, 98);ism["merkindragger2.gif"] = im(1, 99);ism["doubt3.gif"] = im(0, 99);ism["orangutan.gif"] = im(8, 97);ism["scabie_jungle.gif"] = im(2, 92);ism["thejunk.gif"] = im(19, 86);ism["js_bender.gif"] = im(5, 91);ism["js_melter.gif"] = im(11, 95);ism["js_sharpener.gif"] = im(7, 90);ism["orquette2.gif"] = im(13, 86);ism["keese.gif"] = im(25, 66);ism["tooold.gif"] = im(1, 97);ism["clownfish.gif"] = im(22, 82);ism["killingbird.gif"] = im(0, 98);ism["adv_smart3.gif"] = im(15, 94);ism["snaknight.gif"] = im(0, 97);ism["wolfknight.gif"] = im(3, 97);ism["knight.gif"] = im(7, 91);ism["kg_accountant.gif"] = im(12, 98);ism["kg_alchemist.gif"] = im(15, 94);ism["kg_asstchef.gif"] = im(0, 99);ism["kg_bbqteam.gif"] = im(1, 99);ism["kg_beancounter.gif"] = im(12, 97);ism["kg_guard.gif"] = im(10, 94);ism["kg_guardcaptain.gif"] = im(10, 94);ism["zomelite.gif"] = im(6, 90);
ism["kg_embezzler.gif"] = im(12, 97);ism["kg_haremgirl.gif"] = im(15, 89);ism["kg_haremguard.gif"] = im(14, 94);ism["kg_king.gif"] = im(0, 98);ism["kg_madsci.gif"] = im(11, 91);ism["kg_madam.gif"] = im(16, 97);ism["kg_masterchef.gif"] = im(0, 99);ism["kg_mba.gif"] = im(16, 98);ism["kg_mutant.gif"] = im(13, 97);ism["kg_poseur.gif"] = im(28, 94);ism["kg_souschef.gif"] = im(0, 98);ism["kg_verymadsci.gif"] = im(15, 92);ism["slanding.gif"] = im(5, 91);ism["yeti.gif"] = im(1, 95);ism["koopa.gif"] = im(5, 93);ism["kublakhan.gif"] = im(5, 92);ism["adv_fast3.gif"] = im(4, 92);ism["limp.gif"] = im(8, 94);ism["labmonkey.gif"] = im(16, 91);ism["n00b.gif"] = im(6, 91);ism["lower_k.gif"] = im(7, 81);ism["headwolf.gif"] = im(0, 98);ism["grayblob2.gif"] = im(9, 93);ism["larrysignfield.gif"] = im(9, 95);ism["filthworm1.gif"] = im(49, 83);ism["laser.gif"] = im(9, 97);ism["lavagolem.gif"] = im(5, 89);ism["lavalamprey.gif"] = im(3, 95);ism["lavalos.gif"] = im(200, 300, 7, 290);ism["lavatory.gif"] = im(0, 98);ism["statbike.gif"] = im(2, 96);ism["linbox.gif"] = im(17, 91);ism["lemonfish.gif"] = im(17, 74);ism["adv_sleaze4.gif"] = im(3, 97);ism["lfruitgol.gif"] = im(33, 84);ism["licosnake.gif"] = im(5, 94);ism["lich.gif"] = im(3, 98);ism["bb_liquidmetal.gif"] = im(7, 92);ism["liquidmetal.gif"] = im(1, 97);ism["grayblob1.gif"] = im(40, 88);ism["canoeman.gif"] = im(13, 66);ism["wanderacc2.gif"] = im(1, 98);ism["pa_bread.gif"] = im(7, 95);ism["lobsterman.gif"] = im(1, 98);ism["lollicat.gif"] = im(12, 91);ism["lolligator.gif"] = im(18, 85);ism["lollipede.gif"] = im(11, 77);ism["lolliphaunt.gif"] = im(12, 91);ism["spelunklolm.gif"] = im(250, 300, 3, 269);ism["lollirus2.gif"] = im(9, 91);ism["vib5.gif"] = im(1, 97);ism["coalition.gif"] = im(2, 89);ism["soggyraven.gif"] = im(0, 99);ism["lordspooky.gif"] = im(7, 97);ism["lotswife.gif"] = im(1, 97);ism["lizardfish.gif"] = im(31, 61);ism["regret2.gif"] = im(1, 95);ism["kok_lovers.gif"] = im(5, 97);ism["lower_h.gif"] = im(13, 87);ism["catstatue.gif"] = im(15, 84);ism["lumbersup.gif"] = im(5, 92);ism["lumberjill.gif"] = im(5, 92);ism["lumberjuan.gif"] = im(0, 92);ism["4_4a.gif"] = im(200, 200, 13, 168);ism["4_1.gif"] = im(21, 70);ism["4_2.gif"] = im(19, 92);ism["4_3.gif"] = im(3, 97);ism["lynyrd.gif"] = im(9, 91);ism["skinner.gif"] = im(2, 96);ism["adv_strong1.gif"] = im(5, 94);ism["madbugbear.gif"] = im(6, 95);ism["prim_flag.gif"] = im(0, 98);ism["madwino.gif"] = im(6, 94);ism["madiator.gif"] = im(2, 96);ism["dragonfish.gif"] = im(0, 99);ism["mech.gif"] = im(1, 98);ism["spelunkmagma.gif"] = im(7, 84);ism["cropcircle.gif"] = im(2, 93);ism["hairclog.gif"] = im(0, 94);ism["magfield.gif"] = im(1, 93);ism["tofurkey.gif"] = im(2, 92);ism["maltliquorgolem.gif"] = im(0, 99);ism["mammon.gif"] = im(200, 200, 11, 193);ism["redbuttons.gif"] = im(1, 93);ism["audrey.gif"] = im(0, 98);ism["wraith5.gif"] = im(10, 90);ism["bandolero.gif"] = im(0, 99);ism["mar_bruiser.gif"] = im(4, 93);ism["mariachi3.gif"] = im(1, 96);ism["wraith3.gif"] = im(9, 88);ism["promoter.gif"] = im(2, 93);ism["wasp.gif"] = im(13, 96);ism["mayorghost.gif"] = im(200, 150, 3, 146);ism["mayorghost_hm.gif"] = im(200, 150, 5, 147);ism["beggar.gif"] = im(0, 98);ism["duckmeandrunk.gif"] = im(3, 96);ism["med_dung.gif"] = im(5, 94);ism["med_mugman.gif"] = im(3, 92);ism["med_muggirl.gif"] = im(5, 89);ism["med_potter.gif"] = im(3, 91);ism["med_strawman.gif"] = im(0, 97);ism["med_stucco.gif"] = im(12, 96);ism["mimic3.gif"] = im(11, 89);ism["cvmedusa.gif"] = im(4, 91);ism["megafrog.gif"] = im(15, 89);ism["vib1.gif"] = im(0, 98);ism["lawngnome1.gif"] = im(14, 80);ism["nemesisthug.gif"] = im(7, 90);ism["merkinalphabet.gif"] = im(6, 93);ism["merkinballer.gif"] = im(4, 98);ism["merkinswitcher.gif"] = im(4, 98);ism["merkinburglar.gif"] = im(1, 95);ism["merkindiver.gif"] = im(1, 95);ism["merkindrifter.gif"] = im(4, 98);ism["merkinhealer.gif"] = im(3, 95);ism["merkinjuicer.gif"] = im(4, 98);ism["merkinminer.gif"] = im(1, 95);ism["merkinmonitor.gif"] = im(6, 93);ism["merkindragger.gif"] = im(4, 98);ism["merkinposeur.gif"] = im(1, 95);ism["merkinpunisher.gif"] = im(1, 95);ism["merkinraider.gif"] = im(3, 95);ism["merkinresearcher.gif"] = im(6, 93);ism["merkinspear.gif"] = im(1, 95);ism["merkinscav.gif"] = im(1, 95);ism["merkinghost.gif"] = im(13, 85);ism["merkinteacher.gif"] = im(2, 99);ism["merkintippler.gif"] = im(1, 99);ism["merkintrainer.gif"] = im(4, 98);ism["mercenary.gif"] = im(6, 95);ism["pengmesmer.gif"] = im(3, 99);ism["adv_smart2.gif"] = im(6, 98);ism["adv_fast2.gif"] = im(1, 96);ism["lowerm.gif"] = im(9, 90);ism["minecrab.gif"] = im(0, 99);ism["mineboss2.gif"] = im(1, 96);ism["mineboss1.gif"] = im(2, 97);ism["mineworker1.gif"] = im(3, 92);ism["mineworker2.gif"] = im(3, 92);ism["twins_mism.gif"] = im(100, 200, 17, 198);ism["badportrait.gif"] = im(0, 98);ism["pengarson.gif"] = im(2, 97);ism["mobcapo.gif"] = im(8, 95);ism["pengcapo.gif"] = im(3, 98);ism["pengdemo.gif"] = im(2, 98);ism["pengthug.gif"] = im(2, 98);ism["peng_ent.gif"] = im(3, 98);ism["pengbook.gif"] = im(2, 98);ism["penggoon.gif"] = im(2, 98);ism["penggun.gif"] = im(3, 98);ism["pengchef.gif"] = im(3, 98);ism["pengpsycho.gif"] = im(3, 98);ism["pengracket.gif"] = im(3, 99);ism["pengsmasher.gif"] = im(0, 98);ism["hazmatpeng.gif"] = im(0, 98);ism["pengprano.gif"] = im(0, 99);ism["pengphone.gif"] = im(0, 98);ism["warhipar2.gif"] = im(6, 89);ism["modelskeleton.gif"] = im(1, 99);ism["modernzombie.gif"] = im(8, 91);ism["moyster.gif"] = im(7, 93);ism["moneybee.gif"] = im(11, 75);ism["elf_wrench.gif"] = im(17, 87);ism["monsterhearse.gif"] = im(250, 200, 22, 186);ism["boiler.gif"] = im(4, 95);ism["monty.gif"] = im(4, 95);ism["moonshriner.gif"] = im(0, 99);ism["fear1.gif"] = im(0, 99);ism["wraith1.gif"] = im(8, 83);ism["motherseal.gif"] = im(9, 91);ism["otherimages/slimetube/stboss.gif"] = im(30, 30, 29, 30);ism["motorhead.gif"] = im(2, 95);ism["mountainman.gif"] = im(3, 97);ism["lawngnome3.gif"] = im(1, 99);ism["lawngnome2.gif"] = im(26, 98);ism["mrcheeng.gif"] = im(0, 97);ism["mrchoch.gif"] = im(0, 98);ism["adv_strong4.gif"] = im(17, 91);ism["adv_cold4.gif"] = im(0, 99);ism["chemteacher.gif"] = im(0, 98);ism["swampturtle.gif"] = im(0, 99);ism["muff.gif"] = im(10, 78);ism["mumblebee.gif"] = im(27, 74);ism["spelunkmumm.gif"] = im(3, 92);ism["mush_beefy.gif"] = im(6, 89);ism["antlerelf.gif"] = im(12, 97);ism["elfblob.gif"] = im(5, 98);ism["elflimbs.gif"] = im(17, 97);ism["elfclaw.gif"] = im(25, 96);ism["mutantgila.gif"] = im(3, 96);ism["mutantsnake.gif"] = im(19, 95);ism["mutantcactus.gif"] = im(0, 96);ism["elfhulk.gif"] = im(3, 97);ism["alielephant.gif"] = im(10, 97);ism["mutantalielf.gif"] = im(1, 97);ism["bb_vassist.gif"] = im(3, 95);ism["nastybear.gif"] = im(1, 97);ism["fear3.gif"] = im(1, 99);ism["sorcform1.gif"] = im(0, 99);ism["sorcblob.gif"] = im(200, 200, 28, 197);ism["bigsaus.gif"] = im(39, 59);ism["warfratmd2.gif"] = im(2, 96);ism["navyseal.gif"] = im(0, 98);ism["giant_neckbeard.gif"] = im(3, 95);ism["neil.gif"] = im(6, 95);ism["flytrap.gif"] = im(0, 96);ism["mc_respect2.gif"] = im(0, 97);ism["mc_respect1.gif"] = im(0, 97);ism["snakenest.gif"] = im(8, 88);ism["newt.gif"] = im(43, 97);ism["emofrat.gif"] = im(0, 97);ism["ninjawaiter.gif"] = im(5, 95);ism["ninjarice.gif"] = im(7, 95);ism["snowman.gif"] = im(7, 95);ism["ninja_ass.gif"] = im(3, 91);ism["ninjamop.gif"] = im(10, 98);ism["ninjacloud.gif"] = im(3, 97);ism["nhobo1.gif"] = im(7, 94);ism["hunter2.gif"] = im(0, 99);ism["tropicalskel.gif"] = im(0, 98);ism["novia.gif"] = im(5, 99);ism["novio.gif"] = im(11, 97);ism["nurseshark.gif"] = im(15, 71);ism["whirlwind.gif"] = im(8, 91);ism["tourist.gif"] = im(9, 92);ism["octopus.gif"] = im(0, 96);ism["octorok.gif"] = im(10, 93);ism["headghost.gif"] = im(4, 94);ism["adv_stench4.gif"] = im(0, 97);ism["kg_offdutyguard.gif"] = im(13, 95);ism["officialseal.gif"] = im(17, 91);ism["oilbaron.gif"] = im(0, 99);ism["oilcartel2.gif"] = im(200, 100, 5, 97);ism["oilslick.gif"] = im(29, 61);ism["oiltycoon.gif"] = im(1, 99);ism["straw_sleaze.gif"] = im(37, 93);ism["olscratch.gif"] = im(2, 97);ism["noart.gif"] = im(7, 91);ism["dk_oneeye.gif"] = im(2, 95);ism["oneeyed.gif"] = im(4, 91);ism["fratboy.gif"] = im(2, 91);ism["fratskirt.gif"] = im(2, 91);ism["fratbong.gif"] = im(2, 91);ism["lilfratboy.gif"] = im(7, 86);ism["oscus.gif"] = im(5, 97);ism["bandsaw.gif"] = im(11, 87);ism["tableoutlaw.gif"] = im(8, 93);ism["outlawboss.gif"] = im(0, 97);ism["surv_overarmed.gif"] = im(0, 98);ism["pimp.gif"] = im(17, 90);ism["elpriest.gif"] = im(1, 97);ism["stonebros.gif"] = im(2, 96);ism["warfratpr.gif"] = im(19, 85);ism["ptowels.gif"] = im(0, 99);ism["hunter3.gif"] = im(1, 99);
ism["peanut.gif"] = im(0, 98);ism["mh_roommate.gif"] = im(2, 97);ism["pencil.gif"] = im(5, 93);ism["smoochboss3.gif"] = im(100, 200, 17, 191);ism["defense_sphere.gif"] = im(3, 97);ism["pestopuddle.gif"] = im(46, 91);ism["perpbat.gif"] = im(5, 88);ism["bystander.gif"] = im(1, 96);ism["somepig.gif"] = im(3, 88);ism["pinebat.gif"] = im(33, 69);ism["piranhadon.gif"] = im(29, 97);ism["wood_stench.gif"] = im(3, 90);ism["adv_spooky2.gif"] = im(4, 95);ism["plaidghost.gif"] = im(7, 95);ism["plaque.gif"] = im(0, 99);ism["drunkcrancan.gif"] = im(1, 99);ism["drunkfrat.gif"] = im(1, 96);ism["animelf2.gif"] = im(20, 81);ism["poolter.gif"] = im(1, 97);ism["poolter2.gif"] = im(2, 98);ism["popnlocker.gif"] = im(0, 98);ism["porkbutterfly.gif"] = im(9, 88);ism["porksword.gif"] = im(17, 87);ism["adv_sleaze3.gif"] = im(8, 90);ism["abom.gif"] = im(6, 95);ism["crancan.gif"] = im(21, 95);ism["mystwander2.gif"] = im(9, 95);ism["mystwander1.gif"] = im(8, 95);ism["tomatosoup.gif"] = im(6, 89);ism["eyewash.gif"] = im(11, 91);ism["mystwander4.gif"] = im(1, 97);ism["mangler.gif"] = im(5, 95);ism["organ.gif"] = im(1, 99);ism["silverware.gif"] = im(0, 99);ism["toybox.gif"] = im(7, 89);ism["winerack.gif"] = im(4, 98);ism["question.gif"] = im(0, 86);ism["pouooze.gif"] = im(33, 88);ism["primp.gif"] = im(7, 90);ism["fly.gif"] = im(4, 92);ism["surv_primitive.gif"] = im(2, 91);ism["chalmers.gif"] = im(1, 98);ism["bigskeleton.gif"] = im(0, 98);ism["giant_procrast.gif"] = im(5, 98);ism["profjacking.gif"] = im(2, 96);ism["elf_propaganda.gif"] = im(11, 84);ism["protag.gif"] = im(6, 95);ism["protspect.gif"] = im(0, 99);ism["spurt.gif"] = im(0, 99);ism["elf_provocateur.gif"] = im(10, 83);ism["pterodact.gif"] = im(250, 150, 14, 136);ism["pufferfish.gif"] = im(0, 98);ism["pumpedbass.gif"] = im(17, 69);ism["shiv_pumpkin.gif"] = im(6, 97);ism["giant_punk.gif"] = im(0, 98);ism["pyg_squad.gif"] = im(0, 99);ism["pyg_blowgunner.gif"] = im(31, 99);ism["pyg_bowler.gif"] = im(29, 98);ism["pyg_headhunter.gif"] = im(28, 99);ism["pyg_janitor.gif"] = im(41, 99);ism["pyg_orderlies.gif"] = im(18, 98);ism["pyg_shaman.gif"] = im(24, 97);ism["pyg_acct.gif"] = im(33, 99);ism["pyg_lawyer.gif"] = im(27, 98);ism["pyg_nurse.gif"] = im(20, 98);ism["pyg_surgeon.gif"] = im(21, 99);ism["wood_spooky.gif"] = im(28, 90);ism["animelf4.gif"] = im(19, 78);ism["upper_q.gif"] = im(8, 88);ism["beequeen.gif"] = im(13, 87);ism["spelunkbeeq.gif"] = im(200, 150, 5, 149);ism["filthworm4.gif"] = im(0, 97);ism["qbasicele.gif"] = im(0, 97);ism["healer.gif"] = im(9, 93);ism["wanderacc3.gif"] = im(0, 99);ism["mmoaddict.gif"] = im(12, 94);ism["naskar1.gif"] = im(5, 95);ism["weightrack.gif"] = im(27, 95);ism["elf_raconteur.gif"] = im(7, 80);ism["radiator.gif"] = im(0, 99);ism["hunter13.gif"] = im(7, 93);ism["anger1.gif"] = im(0, 99);ism["ragingbull.gif"] = im(2, 94);ism["adding.gif"] = im(2, 89);ism["mh_scenester.gif"] = im(1, 96);ism["ratbat.gif"] = im(19, 67);ism["duckrattle.gif"] = im(2, 96);ism["smoochboss2.gif"] = im(100, 200, 13, 191);ism["raven.gif"] = im(18, 93);ism["giant_raver.gif"] = im(0, 99);ism["wallpaper.gif"] = im(17, 83);ism["foss_baboon.gif"] = im(1, 97);ism["foss_bat.gif"] = im(38, 69);ism["foss_demon.gif"] = im(150, 150, 2, 130);ism["foss_spider.gif"] = im(150, 150, 32, 130);ism["foss_serpent.gif"] = im(1, 96);ism["redbutler.gif"] = im(4, 95);ism["redfox.gif"] = im(5, 94);ism["redherring.gif"] = im(7, 94);ism["redskeleton.gif"] = im(5, 97);ism["redsnapper.gif"] = im(6, 90);ism["regretman.gif"] = im(200, 200, 9, 180);ism["regbat.gif"] = im(35, 66);ism["headlessskel.gif"] = im(15, 89);ism["mistress.gif"] = im(2, 99);ism["giant_renfair.gif"] = im(1, 97);ism["reneccorman.gif"] = im(1, 97);ism["doubt2.gif"] = im(6, 92);ism["kok_waiter.gif"] = im(2, 95);ism["revbugbear.gif"] = im(1, 98);ism["merkinswitcher2.gif"] = im(1, 99);ism["duckgolem.gif"] = im(2, 92);ism["rock_guy.gif"] = im(31, 96);ism["popweasel.gif"] = im(0, 99);ism["scorpion.gif"] = im(8, 91);ism["rock_snake.gif"] = im(1, 97);ism["caveelf1.gif"] = im(21, 78);ism["rock_fish.gif"] = im(24, 77);ism["rollerskate.gif"] = im(2, 92);ism["muse.gif"] = im(2, 96);ism["rollingstone.gif"] = im(4, 90);ism["roncopper.gif"] = im(3, 96);ism["realdolphin.gif"] = im(14, 92);ism["duckfat.gif"] = im(0, 99);ism["rudolfus.gif"] = im(3, 97);ism["rulergolem.gif"] = im(0, 99);ism["runningman.gif"] = im(2, 94);ism["bum.gif"] = im(8, 95);ism["elf_saboteur.gif"] = im(22, 79);ism["ferret.gif"] = im(2, 90);ism["toothgoat.gif"] = im(0, 95);ism["stkiwi.gif"] = im(8, 85);ism["lime.gif"] = im(15, 77);ism["sadiator.gif"] = im(3, 92);ism["safarijack.gif"] = im(1, 97);ism["salamander.gif"] = im(51, 97);ism["salaminder.gif"] = im(26, 88);ism["salaryninja.gif"] = im(4, 96);ism["pirate1.gif"] = im(6, 93);ism["adv_smooth1.gif"] = im(5, 92);ism["zompirate.gif"] = im(7, 93);ism["bb_scav.gif"] = im(7, 93);ism["gummifish.gif"] = im(0, 99);ism["schoolofmany.gif"] = im(3, 94);ism["wizardfish.gif"] = im(1, 99);ism["scimitarfish.gif"] = im(16, 73);ism["duckscorch.gif"] = im(0, 98);ism["spelunkscorp.gif"] = im(3, 89);ism["hunter4.gif"] = im(2, 92);ism["scoutseal.gif"] = im(12, 86);ism["screambat.gif"] = im(24, 79);ism["screwgolem.gif"] = im(3, 98);ism["seacow.gif"] = im(17, 73);ism["seacowboy.gif"] = im(0, 98);ism["adv_smooth4.gif"] = im(2, 95);ism["secrobot.gif"] = im(11, 87);ism["securityslime.gif"] = im(4, 96);ism["crimbominer2.gif"] = im(9, 81);ism["sadpoet.gif"] = im(5, 93);ism["atm.gif"] = im(7, 94);ism["serialbus.gif"] = im(1, 94);ism["grodseal.gif"] = im(3, 93);ism["fireservant1.gif"] = im(0, 99);ism["sewergator.gif"] = im(11, 78);ism["sewersnake.gif"] = im(5, 91);ism["sewertruck.gif"] = im(400, 150, 6, 143);ism["sororghost1.gif"] = im(1, 97);ism["sororeton1.gif"] = im(3, 89);ism["sororpire1.gif"] = im(7, 97);ism["sororwolf1.gif"] = im(6, 97);ism["sororbie1.gif"] = im(5, 95);ism["shadowseal.gif"] = im(8, 91);ism["sheetghost.gif"] = im(5, 95);ism["shopkeep.gif"] = im(7, 91);ism["shub-jigguwatt.gif"] = im(300, 300, 20, 283);ism["tacoelf_sign.gif"] = im(27, 94);ism["caveelf4.gif"] = im(14, 77);ism["sk8gnome.gif"] = im(23, 77);ism["boardskate.gif"] = im(3, 91);ism["animrat.gif"] = im(1, 93);ism["catskel.gif"] = im(20, 84);ism["hamskel.gif"] = im(73, 95);ism["monkeyskel.gif"] = im(17, 77);ism["crimonster6.gif"] = im(3, 95);ism["steward.gif"] = im(3, 97);ism["spelunkskel.gif"] = im(10, 91);ism["mopskeleton.gif"] = im(6, 96);ism["buttleton.gif"] = im(3, 97);ism["sketchyvan.gif"] = im(200, 100, 0, 99);ism["skinflute.gif"] = im(27, 76);ism["skeleton.gif"] = im(6, 93);ism["skullbat.gif"] = im(31, 66);ism["skulldozer.gif"] = im(450, 300, 12, 278);ism["skullery.gif"] = im(0, 97);ism["dvsleazebear1.gif"] = im(5, 89);ism["dvsleazeghost1.gif"] = im(11, 88);ism["slhobo1.gif"] = im(1, 97);ism["dvsleazeskel1.gif"] = im(9, 92);ism["dvsleazevamp1.gif"] = im(3, 96);ism["dvsleazewolf1.gif"] = im(2, 97);ism["dvsleazezom1.gif"] = im(4, 93);ism["kg_sleepingguard.gif"] = im(0, 98);ism["dwarf_sleepy.gif"] = im(37, 95);ism["mar_sleepy.gif"] = im(0, 99);ism["slime1_1.gif"] = im(0, 98);ism["slime2_1.gif"] = im(0, 96);ism["slime3_1.gif"] = im(2, 97);ism["slime4_1.gif"] = im(3, 95);ism["slime5_1.gif"] = im(0, 98);ism["wood_sleaze.gif"] = im(16, 79);ism["holglob.gif"] = im(34, 89);ism["slithering.gif"] = im(15, 81);ism["ssd_burger.gif"] = im(0, 99);ism["ssd_cocktail.gif"] = im(0, 98);ism["ssd_sundae.gif"] = im(1, 98);ism["eliot.gif"] = im(5, 97);ism["mimic2.gif"] = im(23, 87);ism["smartskel.gif"] = im(4, 94);ism["smellothewisp.gif"] = im(4, 98);ism["smokemonster.gif"] = im(5, 96);ism["smoochman3.gif"] = im(100, 150, 16, 127);ism["smoochman1.gif"] = im(7, 93);ism["smoochman2.gif"] = im(1, 97);ism["adv_smooth3.gif"] = im(3, 97);ism["scabie_jazz.gif"] = im(2, 89);ism["smutorc_jacker.gif"] = im(6, 95);ism["smutorc_nailer.gif"] = im(8, 96);ism["smutorc_pervert.gif"] = im(7, 93);ism["smutorc_layer.gif"] = im(5, 97);ism["smutorc_screwer.gif"] = im(9, 97);ism["spelunksnake.gif"] = im(20, 83);ism["firesnake.gif"] = im(0, 99);ism["snakeboss6.gif"] = im(150, 150, 26, 131);ism["snapdragon.gif"] = im(1, 98);ism["snowqueen.gif"] = im(0, 98);ism["adv_cold1.gif"] = im(9, 93);ism["sodium.gif"] = im(3, 92);ism["6_4a.gif"] = im(200, 200, 11, 189);ism["6_1.gif"] = im(10, 91);ism["6_2.gif"] = im(3, 96);ism["6_3.gif"] = im(2, 98);ism["sonofsailor.gif"] = im(1, 99);ism["warfratmd.gif"] = im(4, 96);ism["warfratcm.gif"] = im(1, 96);ism["tree_hickory.gif"] = im(0, 98);ism["drunkstuffing.gif"] = im(0, 99);ism["spacebeast1.gif"] = im(8, 83);ism["spacebeast3.gif"] = im(14, 91);ism["spacemarine.gif"] = im(1, 95);ism["aboo_trek.gif"] = im(1, 97);ism["3_4a.gif"] = im(200, 200, 3, 193);ism["3_1.gif"] = im(2, 95);ism["3_2.gif"] = im(4, 97);ism["3_3.gif"] = im(0, 93);ism["spamwitch.gif"] = im(3, 95);ism["pa_spatula.gif"] = im(7, 98);ism["wretchedseal.gif"] = im(54, 94);ism["hunter11.gif"] = im(3, 95);ism["jellyfish.gif"] = im(6, 96);ism["spelastronaut.gif"] = im(2, 96);ism["spelunkspider.gif"] = im(21, 88);ism["topi1.gif"] = im(3, 93);ism["gourd_spider.gif"] = im(10, 83);ism["gremlinspider.gif"] = im(7, 88);ism["spelunkspiderq.gif"] = im(150, 100, 1, 96);ism["gourd_spidergob.gif"] = im(1, 97);ism["spiderhut.gif"] = im(200, 150, 9, 140);ism["bb_spider.gif"] = im(125, 100, 3, 86);ism["spikeskel.gif"] = im(7, 92);ism["spiritalclock.gif"] = im(0, 99);ism["spiritbug.gif"] = im(10, 92);ism["spiritfaucet.gif"] = im(5, 93);ism["5_1.gif"] = im(3, 99);ism["5_2.gif"] = im(0, 99);ism["5_3.gif"] = im(0, 99);ism["spiritpea.gif"] = im(18, 78);ism["sponge.gif"] = im(0, 98);ism["dvspookybear1.gif"] = im(1, 95);ism["dvspookyghost1.gif"] = im(4, 94);ism["sgguard.gif"] = im(16, 77);ism["sgninja.gif"] = im(22, 80);ism["sgwarlock.gif"] = im(8, 83);ism["spookyhobo1.gif"] = im(3, 89);ism["mummy.gif"] = im(6, 89);ism["musicbox.gif"] = im(2, 90);ism["dvspookyskel1.gif"] = im(13, 97);ism["vampire.gif"] = im(10, 91);ism["dvspookyvamp1.gif"] = im(35, 65);ism["dvspookywolf1.gif"] = im(8, 94);ism["dvspookyzom1.gif"] = im(39, 93);ism["manor.gif"] = im(12, 89);ism["sporto.gif"] = im(1, 99);ism["princess.gif"] = im(8, 95);ism["steamelemental.gif"] = im(3, 94);ism["straw_hot.gif"] = im(5, 91);ism["giant_steampunk.gif"] = im(0, 99);ism["2_4a.gif"] = im(200, 200, 11, 189);ism["2_1.gif"] = im(10, 90);ism["2_2.gif"] = im(12, 96);ism["2_3.gif"] = im(16, 93);ism["dvstenchbear1.gif"] = im(1, 99);ism["dvstenchghost1.gif"] = im(0, 97);ism["stenchhobo1.gif"] = im(12, 97);ism["dvstenchskel1.gif"] = im(2, 99);ism["dvstenchvamp1.gif"] = im(0, 98);ism["dvstenchwolf1.gif"] = im(1, 99);ism["dvstenchzom1.gif"] = im(0, 98);ism["steven.gif"] = im(5, 91);
ism["stickymummy.gif"] = im(3, 94);ism["disco_stiff.gif"] = im(2, 91);ism["crimonster4.gif"] = im(3, 94);ism["stomper.gif"] = im(0, 99);ism["stone_pirate.gif"] = im(3, 93);ism["stormcow.gif"] = im(0, 99);ism["strangler.gif"] = im(1, 98);ism["algae.gif"] = im(1, 97);ism["crimboelf.gif"] = im(27, 96);ism["moosehead.gif"] = im(7, 93);ism["stuffgolem.gif"] = im(3, 91);ism["paulblart.gif"] = im(2, 99);ism["suckubus.gif"] = im(6, 92);ism["tree_juniper.gif"] = im(0, 99);ism["colasoldier.gif"] = im(1, 95);ism["supervirus.gif"] = im(9, 95);ism["witchy1.gif"] = im(0, 99);ism["mar_surprised.gif"] = im(0, 99);ism["mc_soy2.gif"] = im(0, 94);ism["mc_soy1.gif"] = im(0, 98);ism["beav_jack.gif"] = im(9, 92);ism["beav_shaman.gif"] = im(0, 97);ism["beav_warrior.gif"] = im(7, 90);ism["duckstinky.gif"] = im(0, 98);ism["swampentity.gif"] = im(5, 95);ism["swampgator.gif"] = im(19, 81);ism["swamphag.gif"] = im(0, 97);ism["swampowl.gif"] = im(0, 99);ism["swampskunk.gif"] = im(3, 95);ism["swarmers.gif"] = im(1, 95);ism["ralphbat.gif"] = im(2, 84);ism["ants.gif"] = im(1, 97);ism["fudgewasps.gif"] = im(0, 98);ism["whelps1.gif"] = im(10, 85);ism["aswarm.gif"] = im(7, 93);ism["kg_lice.gif"] = im(3, 93);ism["mutantants.gif"] = im(9, 87);ism["beatles.gif"] = im(5, 94);ism["skullswarm.gif"] = im(50, 93);ism["swisshen.gif"] = im(0, 98);ism["t9000.gif"] = im(3, 99);ism["cacotap.gif"] = im(21, 80);ism["tacofish.gif"] = im(17, 82);ism["tacoelf_taco.gif"] = im(12, 86);ism["tacoelf_cart.gif"] = im(9, 82);ism["kasemhead.gif"] = im(2, 96);ism["biggnat.gif"] = im(21, 70);ism["hatskel.gif"] = im(0, 99);ism["adv_fast4.gif"] = im(11, 86);ism["c10spreadsheet.gif"] = im(8, 98);ism["tektite.gif"] = im(21, 77);ism["skel10.gif"] = im(300, 100, 0, 98);ism["terrorbot.gif"] = im(5, 88);ism["tetched.gif"] = im(1, 98);ism["madpirate.gif"] = im(6, 93);ism["fudgeman.gif"] = im(200, 200, 19, 186);ism["theaquaman.gif"] = im(0, 99);ism["boris.gif"] = im(6, 89);ism["aojarls.gif"] = im(6, 93);ism["sneakypete.gif"] = im(13, 90);ism["batinspats.gif"] = im(200, 100, 6, 96);ism["beefhemoth.gif"] = im(200, 100, 0, 98);ism["c10bge.gif"] = im(11, 86);ism["thisdude.gif"] = im(0, 93);ism["c10faces.gif"] = im(0, 99);ism["beelzebozo.gif"] = im(0, 98);ism["colollilossus.gif"] = im(270, 270, 3, 264);ism["bath_craykin.gif"] = im(0, 99);ism["darkness.gif"] = im(0, 98);ism["theemperor.gif"] = im(5, 93);ism["skelmanager.gif"] = im(5, 97);ism["snakeboss2.gif"] = im(5, 94);ism["hunter15.gif"] = im(0, 92);ism["fudgewizard.gif"] = im(0, 99);ism["bunionghost.gif"] = im(4, 92);ism["thegunk.gif"] = im(3, 95);ism["hermit.gif"] = im(30, 30, 29, 30);ism["landscaper.gif"] = im(0, 99);ism["snitch.gif"] = im(150, 300, 13, 275);ism["adv_hot4.gif"] = im(10, 97);ism["theluter.gif"] = im(11, 93);ism["theman.gif"] = im(0, 94);ism["darkmariachi.gif"] = im(2, 97);ism["masterat.gif"] = im(40, 97);ism["adv_smart4.gif"] = im(13, 97);ism["thenuge.gif"] = im(4, 94);ism["rainking.gif"] = im(250, 300, 10, 287);ism["sagittarian.gif"] = im(3, 95);ism["theserver.gif"] = im(0, 97);ism["sierpinski.gif"] = im(0, 89);ism["snakeboss3.gif"] = im(150, 150, 5, 136);ism["timebandit.gif"] = im(9, 88);ism["thepinch.gif"] = im(100, 150, 4, 147);ism["thething.gif"] = im(250, 200, 3, 195);ism["thethorax.gif"] = im(200, 100, 4, 92);ism["c10tropes.gif"] = im(0, 99);ism["ukskeleton.gif"] = im(200, 200, 15, 187);ism["ukskeleton_hm.gif"] = im(200, 200, 2, 195);ism["unknownghost.gif"] = im(0, 99);ism["c10cooler.gif"] = im(0, 98);ism["wholekingdom.gif"] = im(200, 200, 2, 195);ism["they.gif"] = im(0, 99);ism["tnbot1.gif"] = im(1, 95);ism["bigskeleton3.gif"] = im(150, 100, 0, 99);ism["thug1thug2.gif"] = im(200, 100, 1, 93);ism["anger2.gif"] = im(0, 99);ism["tigerlily.gif"] = im(1, 96);ism["spelunktiki.gif"] = im(1, 93);ism["mc_tofu2.gif"] = im(2, 97);ism["mc_tofu1.gif"] = im(2, 95);ism["gourd_can.gif"] = im(14, 90);ism["gourd_canspider.gif"] = im(150, 100, 9, 87);ism["mimic1.gif"] = im(17, 83);ism["animelf1.gif"] = im(19, 79);ism["tipsypirate.gif"] = im(0, 98);ism["tpgeist.gif"] = im(0, 97);ism["shiv_tp.gif"] = im(6, 94);ism["tombasp.gif"] = im(0, 99);ism["mummybat.gif"] = im(34, 60);ism["tombrat.gif"] = im(33, 78);ism["tombratking.gif"] = im(200, 200, 17, 176);ism["tombguy.gif"] = im(0, 98);ism["mastiff.gif"] = im(34, 95);ism["toothpirate.gif"] = im(2, 96);ism["toothskel.gif"] = im(5, 90);ism["topiarychi.gif"] = im(2, 95);ism["topiaryduck.gif"] = im(10, 89);ism["topiary.gif"] = im(0, 98);ism["topiarygopher.gif"] = im(7, 93);ism["topiarykiwi.gif"] = im(17, 92);ism["tree_baobab.gif"] = im(3, 96);ism["c10tmz.gif"] = im(0, 99);ism["orquette3.gif"] = im(6, 92);ism["vib4.gif"] = im(2, 96);ism["toxbeast1.gif"] = im(2, 98);ism["animelf5.gif"] = im(18, 76);ism["crimonster1.gif"] = im(1, 98);ism["travoltron.gif"] = im(200, 200, 4, 197);ism["treadmill.gif"] = im(9, 91);ism["bb_chef.gif"] = im(5, 92);ism["triadwizard.gif"] = im(1, 96);ism["tribalgoblin.gif"] = im(11, 89);ism["trixiepixie.gif"] = im(6, 99);ism["triffid.gif"] = im(2, 96);ism["tarkinhead.gif"] = im(0, 98);ism["monahead.gif"] = im(0, 99);ism["twins_troll.gif"] = im(0, 98);ism["trollipop.gif"] = im(100, 150, 5, 145);ism["trophyfish.gif"] = im(0, 98);ism["tsnake.gif"] = im(5, 94);ism["tumbleweed.gif"] = im(4, 93);ism["turtlemech.gif"] = im(14, 89);ism["turtletrapper.gif"] = im(1, 95);ism["twigberry.gif"] = im(3, 89);ism["bigskeleton2.gif"] = im(0, 99);ism["tex.gif"] = im(0, 98);ism["unclehobo.gif"] = im(10, 92);ism["macaroni.gif"] = im(4, 84);ism["pengundercover.gif"] = im(2, 98);ism["shiv_underworld.gif"] = im(200, 200, 17, 170);ism["ellsburyboss.gif"] = im(150, 150, 15, 124);ism["lensgoblin.gif"] = im(3, 94);ism["surv_unhinged.gif"] = im(6, 95);ism["unholydiver.gif"] = im(0, 99);ism["surv_unlikely.gif"] = im(7, 89);ism["c10database.gif"] = im(2, 95);ism["unstill.gif"] = im(8, 92);ism["ram.gif"] = im(13, 85);ism["urchin.gif"] = im(10, 90);ism["eyesdown.gif"] = im(45, 62);ism["usher.gif"] = im(11, 88);ism["spelunkvampire.gif"] = im(13, 85);ism["vampclam.gif"] = im(11, 91);ism["duckvampire.gif"] = im(3, 95);ism["vandalkid.gif"] = im(9, 91);ism["cvcreature.gif"] = im(100, 200, 4, 196);ism["gremlinveg.gif"] = im(5, 93);ism["velvetug.gif"] = im(19, 91);ism["vendorslime.gif"] = im(0, 95);ism["turtleghost.gif"] = im(23, 84);ism["mantrap.gif"] = im(4, 97);ism["easel.gif"] = im(5, 95);ism["gnauga.gif"] = im(14, 92);ism["victor.gif"] = im(15, 88);ism["qmark.gif"] = im(4, 93);ism["gar.gif"] = im(6, 93);ism["prim_fung.gif"] = im(0, 98);ism["music.gif"] = im(2, 95);ism["iceguy4.gif"] = im(7, 98);ism["smallartist.gif"] = im(40, 97);ism["wimp.gif"] = im(15, 90);ism["wackypirate.gif"] = im(1, 97);ism["iceguy3.gif"] = im(1, 98);ism["mush_shrieking.gif"] = im(1, 93);ism["waiterninja.gif"] = im(5, 95);ism["wallofbones.gif"] = im(250, 150, 3, 138);ism["wallofskin.gif"] = im(250, 125, 1, 115);ism["warfratc.gif"] = im(1, 95);ism["warfrata2.gif"] = im(1, 96);ism["warfratb.gif"] = im(0, 95);ism["warfratc2.gif"] = im(1, 95);ism["warfratb2.gif"] = im(0, 95);ism["warfratsp2.gif"] = im(0, 97);ism["warfratgr.gif"] = im(5, 96);ism["warfratar.gif"] = im(5, 89);ism["warfratmo.gif"] = im(24, 89);ism["warfratgr2.gif"] = im(2, 91);ism["streaker.gif"] = im(3, 95);ism["warfratsp.gif"] = im(3, 98);ism["warhipb.gif"] = im(6, 96);ism["warhipac2.gif"] = im(1, 96);ism["warhipar.gif"] = im(0, 99);ism["warhipds.gif"] = im(8, 93);ism["warhipsh2.gif"] = im(0, 98);ism["warhipfs2.gif"] = im(3, 95);ism["warhipc2.gif"] = im(5, 94);ism["warhipa2.gif"] = im(0, 98);ism["warhipfs.gif"] = im(2, 94);ism["warhipb2.gif"] = im(6, 96);ism["warhipmd.gif"] = im(0, 90);ism["warhipa.gif"] = im(0, 98);ism["warhipmd2.gif"] = im(0, 91);ism["warhipc.gif"] = im(5, 92);ism["warhipsh.gif"] = im(1, 97);ism["warhipac.gif"] = im(5, 96);ism["hippyspy.gif"] = im(8, 89);ism["warhipcm.gif"] = im(2, 94);ism["warbear11.gif"] = im(2, 97);ism["warbear21.gif"] = im(0, 99);ism["nightstand1.gif"] = im(4, 96);ism["warehouseclerk.gif"] = im(2, 95);ism["warehouseguard.gif"] = im(0, 98);ism["warehousejanitor.gif"] = im(3, 92);ism["warehouseguy.gif"] = im(3, 94);ism["wartdinsey.gif"] = im(150, 150, 0, 148);ism["wartpirate.gif"] = im(2, 92);ism["werewolf.gif"] = im(4, 98);ism["wigwasp.gif"] = im(8, 93);ism["wastoid.gif"] = im(8, 93);ism["waterspider.gif"] = im(23, 80);ism["waterseal.gif"] = im(0, 99);ism["richpirate.gif"] = im(3, 93);ism["weatherug.gif"] = im(3, 91);ism["weremoose.gif"] = im(2, 90);ism["weretaco.gif"] = im(29, 82);ism["hunter14.gif"] = im(4, 95);ism["wetseal.gif"] = im(6, 80);
ism["aboo_who.gif"] = im(2, 97);ism["tree_willow.gif"] = im(2, 95);ism["surv_whiny.gif"] = im(3, 91);ism["pa_whisk.gif"] = im(4, 91);ism["whitebonedemon.gif"] = im(200, 100, 12, 98);ism["chocgolem.gif"] = im(9, 92);ism["whiteelephant.gif"] = im(11, 88);ism["lion.gif"] = im(6, 93);ism["zombie2.gif"] = im(5, 94);ism["whitesnake.gif"] = im(10, 87);ism["wildgirl.gif"] = im(0, 97);ism["seahorse.gif"] = im(4, 96);ism["wiresculpture.gif"] = im(0, 97);ism["elf_wires.gif"] = im(12, 89);ism["mush_wizard.gif"] = im(0, 99);ism["tree_magnolia.gif"] = im(1, 99);ism["wraith4.gif"] = im(14, 81);ism["doubt1.gif"] = im(0, 98);ism["ravendesk.gif"] = im(0, 94);ism["susguy.gif"] = im(1, 96);ism["wumpus.gif"] = im(0, 99);ism["beergolem.gif"] = im(4, 97);ism["stonegolem.gif"] = im(3, 97);ism["dimhorror.gif"] = im(2, 96);ism["shopteacher.gif"] = im(1, 98);ism["hydra.gif"] = im(6, 99);ism["polprisoner.gif"] = im(9, 89);ism["pr0n.gif"] = im(11, 87);ism["yakisoba.gif"] = im(0, 97);ism["yakcourier.gif"] = im(3, 96);ism["yakguard.gif"] = im(3, 96);ism["yeastbeast.gif"] = im(4, 93);ism["spelunkyeti.gif"] = im(1, 97);ism["yog-urt.gif"] = im(300, 300, 107, 290);ism["yomama.gif"] = im(300, 300, 3, 289);ism["c10inbox.gif"] = im(9, 94);ism["otherimages/shadows/20.gif"] = im(30, 30, 29, 30);ism["zrex.gif"] = im(150, 100, 0, 99);ism["zimmerman.gif"] = im(4, 98);ism["zombie.gif"] = im(3, 84);ism["zol.gif"] = im(11, 90);ism["zomlizard.gif"] = im(4, 94);ism["zmobaby.gif"] = im(2, 86);ism["zombiechef.gif"] = im(1, 97);ism["zomclown.gif"] = im(3, 97);ism["duckzombie.gif"] = im(1, 96);ism["zomsnow.gif"] = im(7, 91);ism["zomfrat.gif"] = im(12, 84);ism["zomknoll.gif"] = im(10, 87);ism["zomgoth.gif"] = im(0, 94);ism["zomhippy.gif"] = im(4, 92);ism["zombiehoa.gif"] = im(150, 150, 1, 148);ism["zombiehoa_hm.gif"] = im(200, 200, 0, 199);ism["zomchef.gif"] = im(1, 92);ism["zomnoob.gif"] = im(4, 93);ism["zomhealer.gif"] = im(1, 93);ism["zomwaltz.gif"] = im(0, 97);ism["zomyeast.gif"] = im(9, 98);ism["hunter1.gif"] = im(3, 96);ism["zombo.gif"] = im(0, 98);

        
        
        foreach s, v in ysm
        {
            __minimum_y_of_image_url["images/adventureimages/" + s] = v;
        }
        foreach s, v in ism
        {
            __server_image_stats["images/adventureimages/" + s] = v;
        }
    }
    initialiseMinimumBoundingBoxOfImageURL();
}

ServerImageStats ServerImageStatsOfImageURL(string url)
{
    if (__server_image_stats contains url)
    {
        return __server_image_stats[url];
    }
    return ServerImageStatsMake();
}

int KOLImageMinimumYOfImageURL(string url)
{
    if (__server_image_stats contains url)
    {
        return __server_image_stats[url].minimum_y_coordinate;
    }
    return 0;
}