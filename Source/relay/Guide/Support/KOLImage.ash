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
//NOTE: To use KOLImageGenerateImageHTML with should_center set to true, the page must have the class "r_center" set as "margin-left:auto; margin-right:auto;text-align:center;"

record KOLImage
{
	string url;
	
	Vec2i base_image_size;
	Rect crop;
	
	Rect [int] erase_zones; //rectangular zones which are generated as white divs on the output. Erases specific sections of the image. Can be offset by one pixel depending on the browser, sorry.
};

KOLImage [string] __kol_images;

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

//Does not need to be called directly.
boolean __kol_images_has_inited = false;
void KOLImagesInit()
{
    if (__kol_images_has_inited)
        return;
        
	PageAddCSSClass("div", "r_image_container", "overflow:hidden;position:relative;top:0px;left:0px;");
    __kol_images_has_inited = true;
	__kol_images["typical tavern"] = KOLImageMake("images/otherimages/woods/tavern0.gif", Vec2iMake(100,100), RectMake(0,39,99,97));
	__kol_images["boss bat"] = KOLImageMake("images/adventureimages/bossbat.gif", Vec2iMake(100,100), RectMake(0,27,99,74));
	__kol_images["bugbear"] = KOLImageMake("images/adventureimages/fallsfromsky.gif", Vec2iMake(100,150));
	
	__kol_images["twin peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(153,128,237,214));
	__kol_images["a-boo peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(40,134,127,218));
	__kol_images["oil peak"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(261,117,345,213));
	__kol_images["highland lord"] = KOLImageMake("images/otherimages/orcchasm/highlands_main.gif", Vec2iMake(500, 250), RectMake(375,73,457,144));
	__kol_images["orc chasm"] = KOLImageMake("images/otherimages/mountains/chasm.gif", Vec2iMake(100, 100), RectMake(0, 41, 99, 95));
	
	__kol_images["spooky forest"] = KOLImageMake("images/otherimages/woods/forest.gif", Vec2iMake(100, 100), RectMake(12,39,91,93));
	__kol_images["council"] = KOLImageMake("images/otherimages/council.gif", Vec2iMake(100, 100), RectMake(0,26,99,73));
	
	
	__kol_images["daily dungeon"] = KOLImageMake("images/otherimages/town/dd1.gif", Vec2iMake(100,100), RectMake(28,44,71,86));
	__kol_images["clover"] = KOLImageMake("images/itemimages/clover.gif", Vec2iMake(30,30));
	
	__kol_images["mayfly bait"] = KOLImageMake("images/itemimages/mayflynecklace.gif", Vec2iMake(30,30));
	__kol_images["spooky putty"] = KOLImageMake("images/itemimages/sputtysheet.gif", Vec2iMake(30,30));
	
	__kol_images["fax machine"] = KOLImageMake("images/otherimages/clanhall/faxmachine.gif", Vec2iMake(100,100), RectMake(34,28,62,54));
	
	__kol_images["unknown"] = KOLImageMake("images/itemimages/confused.gif", Vec2iMake(30,30));
	
	__kol_images["goth kid"] = KOLImageMake("images/itemimages/crayongoth.gif", Vec2iMake(30,30));
	__kol_images["hipster"] = KOLImageMake("images/itemimages/minihipster.gif", Vec2iMake(30,30));
	
	
	__kol_images[""] = KOLImageMake("images/itemimages/blank.gif", Vec2iMake(30,30));
	__kol_images["blank"] = KOLImageMake("images/itemimages/blank.gif", Vec2iMake(30,30));
	__kol_images["demon summon"] = KOLImageMake("images/otherimages/manor/chamber.gif", Vec2iMake(100,100), RectMake(14, 12, 88, 66));
	
	__kol_images["cobb's knob"] = KOLImageMake("images/otherimages/plains/knob2.gif", Vec2iMake(100,100), RectMake(12,43,86,78));
	
	__kol_images["generic dwelling"] = KOLImageMake("images/otherimages/campground/rest4.gif", Vec2iMake(100,100), RectMake(0,26,95,99));
	
	
	__kol_images["forest friars"] = KOLImageMake("images/otherimages/woods/stones0.gif", Vec2iMake(100,100), RectMake(0, 24, 99, 99));
	__kol_images["cyrpt"] = KOLImageMake("images/otherimages/plains/cyrpt.gif", Vec2iMake(100,100), RectMake(0, 33, 99, 99));
	__kol_images["trapper"] = KOLImageMake("images/otherimages/thetrapper.gif", Vec2iMake(60,100), RectMake(0,11,59,96));
	
	__kol_images["castle"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(234,158,362,290)); //experimental - half sized castle
	__kol_images["penultimate fantasy airship"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(75, 231, 190, 367));
	__kol_images["lift, bro"] = KOLImageMake("images/adventureimages/fitposter.gif", Vec2iMake(100,100));
	//__kol_images["castle stairs up"] = KOLImageMake("images/adventureimages/giantstairsup.gif", Vec2iMake(100,100), RectMake(0, 8, 99, 85));
    __kol_images["castle stairs up"] = KOLImageMake("images/adventureimages/giantstairsup.gif", Vec2iMake(100,100), RectMake(20, 10, 74, 83));
	__kol_images["castle stairs up"].erase_zones.listAppend(RectMake(70, 78, 76, 84));
    
    
	__kol_images["goggles? yes!"] = KOLImageMake("images/adventureimages/steamposter.gif", Vec2iMake(100,100));
	//__kol_images["hole in the sky"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(500,400), RectMake(403, 4, 487, 92));
    __kol_images["hole in the sky"] = KOLImageMake("images/otherimages/stalktop/beanstalk.gif", Vec2iMake(250,200), RectMake(201, 2, 243, 46));
	
	__kol_images["macguffin"] = KOLImageMake("images/itemimages/macguffin.gif", Vec2iMake(30,30));
	__kol_images["island war"] = KOLImageMake("images/otherimages/sigils/warhiptat.gif", Vec2iMake(50,50), RectMake(0,12,49,35));
	__kol_images["naughty sorceress"] = KOLImageMake("images/adventureimages/sorcform1.gif", Vec2iMake(100,100));
	__kol_images["naughty sorceress lair"] = KOLImageMake("images/otherimages/main/map6.gif", Vec2iMake(100,100), RectMake(6,0,50,43));
	
	__kol_images["king imprismed"] = KOLImageMake("images/otherimages/lair/kingprism1.gif", Vec2iMake(100,100));
	__kol_images["campsite"] = KOLImageMake("images/otherimages/plains/plains1.gif", Vec2iMake(100,100));
	__kol_images["trophy"] = KOLImageMake("images/otherimages/trophy/not_wearing_any_pants.gif", Vec2iMake(100,100));
	__kol_images["hidden temple"] = KOLImageMake("images/otherimages/woods/temple.gif", Vec2iMake(100,100), RectMake(16, 40, 89, 96));
	__kol_images["florist friar"] = KOLImageMake("images/adventureimages/floristfriar.gif", Vec2iMake(100,100), RectMake(31, 7, 77, 92));
	
	
	__kol_images["plant rutabeggar"] = KOLImageMake("images/otherimages/friarplants/plant2.gif", Vec2iMake(50,100), RectMake(1, 24, 47, 96));
	
	__kol_images["plant stealing magnolia"] = KOLImageMake("images/otherimages/friarplants/plant12.gif", Vec2iMake(49,100), RectMake(3, 15, 43, 94));
	
	__kol_images["plant shuffle truffle"] = KOLImageMake("images/otherimages/friarplants/plant24.gif", Vec2iMake(66,100), RectMake(4, 35, 63, 88));
	__kol_images["plant horn of plenty"] = KOLImageMake("images/otherimages/friarplants/plant22.gif", Vec2iMake(62,100), RectMake(4, 14, 58, 86));
	
	__kol_images["plant rabid dogwood"] = KOLImageMake("images/otherimages/friarplants/plant1.gif", Vec2iMake(57,100), RectMake(3, 16, 55, 98));
	__kol_images["plant rad-ish radish"] = KOLImageMake("images/otherimages/friarplants/plant3.gif", Vec2iMake(48,100), RectMake(4, 14, 42, 96));
	__kol_images["plant war lily"] = KOLImageMake("images/otherimages/friarplants/plant11.gif", Vec2iMake(49,100), RectMake(5, 5, 45, 98));
	
	__kol_images["plant canned spinach"] = KOLImageMake("images/otherimages/friarplants/plant13.gif", Vec2iMake(48,100), RectMake(3, 24, 46, 94));	
	__kol_images["plant blustery puffball"] = KOLImageMake("images/otherimages/friarplants/plant21.gif", Vec2iMake(54,100), RectMake(3, 38, 50, 90));
	__kol_images["plant wizard's wig"] = KOLImageMake("images/otherimages/friarplants/plant23.gif", Vec2iMake(53,100), RectMake(2, 15, 48, 90));
	
	__kol_images["plant up sea daisy"] = KOLImageMake("images/otherimages/friarplants/plant40.gif", Vec2iMake(64,100), RectMake(3, 6, 60, 92));
	__kol_images["sunflower face"] = KOLImageMake("images/otherimages/friarplants/plant40.gif", Vec2iMake(64,100), RectMake(6, 6, 58, 52));
	
	
	__kol_images["basic hot dog"] = KOLImageMake("images/itemimages/jarl_regdog.gif", Vec2iMake(30,30));
	__kol_images["Island War Arena"] = KOLImageMake("images/otherimages/bigisland/6.gif", Vec2iMake(100,100), RectMake(17, 28, 89, 76));
	__kol_images["Island War Lighthouse"] = KOLImageMake("images/otherimages/bigisland/17.gif", Vec2iMake(100,100), RectMake(30, 34, 68, 97));
	__kol_images["Island War Nuns"] = KOLImageMake("images/otherimages/bigisland/19.gif", Vec2iMake(100,100), RectMake(20, 43, 78, 87));
	__kol_images["Island War Farm"] = KOLImageMake("images/otherimages/bigisland/15.gif", Vec2iMake(100,100), RectMake(8, 50, 93, 88));
	__kol_images["Island War Orchard"] = KOLImageMake("images/otherimages/bigisland/3.gif", Vec2iMake(100,100), RectMake(20, 36, 99, 87));
	
	__kol_images["Island War Junkyard"] = KOLImageMake("images/otherimages/bigisland/25.gif", Vec2iMake(100,100), RectMake(0, 4, 99, 89));
	__kol_images["Island War Junkyard"].erase_zones.listAppend(RectMake(0, 2, 20, 6));
	__kol_images["Island War Junkyard"].erase_zones.listAppend(RectMake(9, 41, 95, 52));
	
	
	__kol_images["spookyraven manor"] = KOLImageMake("images/otherimages/town/manor.gif", Vec2iMake(100,100), RectMake(0, 22, 99, 99));
	
	__kol_images["spookyraven manor"].erase_zones.listAppend(RectMake(23, 18, 53, 28));
	
	
	__kol_images["spookyraven manor locked"] = KOLImageMake("images/otherimages/town/pantry.gif", Vec2iMake(80,80), RectMake(0, 26, 79, 79));
	
	__kol_images["haunted billiards room"] = KOLImageMake("images/otherimages/manor/sm4.gif", Vec2iMake(100,100), RectMake(12, 10, 93, 63));
	
	__kol_images["haunted library"] = KOLImageMake("images/otherimages/manor/sm7.gif", Vec2iMake(100,100), RectMake(14, 5, 92, 55));
	
	__kol_images["haunted bedroom"] = KOLImageMake("images/otherimages/manor/sm2_1b.gif", Vec2iMake(100,100), RectMake(18, 28, 91, 86));
    __kol_images["Haunted Ballroom"] = KOLImageMake("images/otherimages/manor/sm2_5.gif", Vec2iMake(100,200), RectMake(19, 11, 74, 76));
	
	__kol_images["Palindome"] = KOLImageMake("images/otherimages/plains/the_palindome.gif", Vec2iMake(96,86), RectMake(0, 17, 96, 83));
	
	
	__kol_images["high school"] = KOLImageMake("images/otherimages/town/kolhs.gif", Vec2iMake(100,100), RectMake(0, 26, 99, 92));
	//__kol_images["Toot Oriole"] = KOLImageMake("images/otherimages/oriole.gif", Vec2iMake(60,100), RectMake(0, 12, 59, 85));
	__kol_images["Toot Oriole"] = KOLImageMake("images/otherimages/mountains/noobsingtop.gif", Vec2iMake(200,100), RectMake(52, 18, 131, 49)); //I love this GIF

	__kol_images["bookshelf"] = KOLImageMake("images/otherimages/campground/bookshelf.gif", Vec2iMake(100,100), RectMake(0, 26, 99, 99));
	__kol_images["pirate quest"] = KOLImageMake("images/otherimages/trophy/party_on_the_big_boat.gif", Vec2iMake(100,100), RectMake(18, 3, 87, 64));
	__kol_images["meat"] = KOLImageMake("images/itemimages/meat.gif", Vec2iMake(30,30));
	__kol_images["monk"] = KOLImageMake("images/itemimages/monkhead.gif", Vec2iMake(30,30));
	
	
	__kol_images["Pyramid"] = KOLImageMake("images/otherimages/desertbeach/pyramid.gif", Vec2iMake(60,70), RectMake(12, 11, 47, 38));
	__kol_images["Pyramid"].erase_zones.listAppend(RectMake(14, 19, 19, 22));
	__kol_images["Pyramid"].erase_zones.listAppend(RectMake(41, 12, 45, 16));
	
	
	//__kol_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(114, 38, 213, 159)); //building, don't like
	//__kol_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(7, 240, 77, 294)); //shrine, too close to hidden temple
	__kol_images["hidden city"] = KOLImageMake("images/otherimages/hiddencity//hiddencitybg.gif", Vec2iMake(600,400), RectMake(426, 13, 504, 61)); //hidden tavern, small, better
	__kol_images["Dispensary"] = KOLImageMake("images/adventureimages/knobwindow.gif", Vec2iMake(100,100));
	
	
	__kol_images["Wine Racks"] = KOLImageMake("images/otherimages/manor/cellar4.gif", Vec2iMake(100,100), RectMake(17, 11, 96, 65));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(17, 11, 33, 12));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(39, 61, 42, 66));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(70, 61, 74, 66));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(94, 45, 97, 54));
	__kol_images["Wine Racks"].erase_zones.listAppend(RectMake(17, 49, 18, 53));
    
    
	__kol_images["black forest"] = KOLImageMake("images/otherimages/woods/bforest.gif", Vec2iMake(100,100), RectMake(0, 19, 99, 99));
    
	__kol_images["possessed wine rack"] = KOLImageMake("images/adventureimages/winerack.gif", Vec2iMake(100,100), RectMake(0, 0, 99, 99));
	__kol_images["cabinet of Dr. Limpieza"] = KOLImageMake("images/adventureimages/laundrycabinet.gif", Vec2iMake(100,100), RectMake(0, 0, 99, 99));
	__kol_images["monstrous boiler"] = KOLImageMake("images/adventureimages/boiler.gif", Vec2iMake(100,100), RectMake(0, 0, 99, 99));
    
	
	
	__kol_images["Dad Sea Monkee"] = KOLImageMake("images/adventureimages/dad_machine.gif", Vec2iMake(400,300), RectMake(150,212,245,260));
	__kol_images["Shub-Jigguwatt"] = KOLImageMake("images/adventureimages/shub-jigguwatt.gif", Vec2iMake(300,300), RectMake(19, 17, 267, 288));
	__kol_images["Yog-Urt"] = KOLImageMake("images/adventureimages/yog-urt.gif", Vec2iMake(300,300), RectMake(36, 88, 248, 299));
	__kol_images["Sea"] = KOLImageMake("images/adventureimages/wizardfish.gif", Vec2iMake(100,100), RectMake(18, 23, 61, 72));
	__kol_images["Sea"].erase_zones.listAppend(RectMake(18, 23, 27, 28));
	__kol_images["Sea"].erase_zones.listAppend(RectMake(48, 23, 62, 35));
	__kol_images["Spooky little girl"] = KOLImageMake("images/adventureimages/axelgirl.gif", Vec2iMake(100,100), RectMake(37, 25, 63, 74));
	
	//hermit.gif and oldman.gif are almost identical. twins?
	
    __kol_images["astral spirit"] = KOLImageMake("images/otherimages/spirit.gif", Vec2iMake(60,100));
	__kol_images["Disco Bandit"] = KOLImageMake("images/otherimages/discobandit_f.gif", Vec2iMake(60,100), RectMake(0,6,59,87));
	__kol_images["Seal Clubber"] = KOLImageMake("images/otherimages/sealclubber_f.gif", Vec2iMake(60,100), RectMake(0,9,59,92));
	__kol_images["Turtle Tamer"] = KOLImageMake("images/otherimages/turtletamer_f.gif", Vec2iMake(60,100), RectMake(0,5,59,93));
	__kol_images["Pastamancer"] = KOLImageMake("images/otherimages/pastamancer_f.gif", Vec2iMake(60,100), RectMake(0,0,59,91));
	__kol_images["Sauceror"] = KOLImageMake("images/otherimages/sauceror_f.gif", Vec2iMake(60,100), RectMake(0,5,59,90));
	__kol_images["Accordion Thief"] = KOLImageMake("images/otherimages/accordionthief_f.gif", Vec2iMake(60,100), RectMake(0,2,59,99));
	__kol_images["Avatar of Sneaky Pete"] = KOLImageMake("images/otherimages/peteavatar_f.gif", Vec2iMake(60,100), RectMake(1,7,59,96));
	__kol_images["Avatar of Jarlsberg"] = KOLImageMake("images/otherimages/jarlsberg_avatar_f.gif", Vec2iMake(60,100), RectMake(0,6,59,96));
	__kol_images["Avatar of Boris"] = KOLImageMake("images/otherimages/boris_avatar_f.gif", Vec2iMake(60,100), RectMake(0,4,59,93));
	__kol_images["Zombie Master"] = KOLImageMake("images/otherimages/zombavatar_f.gif", Vec2iMake(60,100), RectMake(10,3,55,99));

	__kol_images["Nemesis Disco Bandit"] = KOLImageMake("images/adventureimages/newwave.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Seal Clubber"] = KOLImageMake("images/adventureimages/1_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Turtle Tamer"] = KOLImageMake("images/adventureimages/2_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Pastamancer"] = KOLImageMake("images/adventureimages/3_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Sauceror"] = KOLImageMake("images/adventureimages/4_1.gif", Vec2iMake(100,100));
	__kol_images["Nemesis Accordion Thief"] = KOLImageMake("images/adventureimages/6_1.gif", Vec2iMake(100,100));
	
	__kol_images["sword guy"] = KOLImageMake("images/otherimages/leftswordguy.gif", Vec2iMake(80,100));
	__kol_images["Jick"] = KOLImageMake("images/otherimages/customavatars/1.gif", Vec2iMake(30,50));
	__kol_images["Pulverize"] = KOLImageMake("images/itemimages/blackhammer.gif", Vec2iMake(30,30));
	__kol_images["Superhuman Cocktailcrafting"] = KOLImageMake("images/itemimages/fruitym.gif", Vec2iMake(30,30));
    
	__kol_images["inexplicable door"] = KOLImageMake("images/otherimages/woods/8bitdoor.gif", Vec2iMake(100,100), RectMake(15, 43, 85, 99));
	__kol_images["Dungeons of Doom"] = KOLImageMake("images/otherimages/town/ddoom.gif", Vec2iMake(100,100), RectMake(31, 33, 68, 99));
    
	__kol_images["chinatown"] = KOLImageMake("images/otherimages/jung/jung_chinaback.gif", Vec2iMake(450,500), RectMake(188, 202, 229, 270));
	__kol_images["chinatown"].erase_zones.listAppend(RectMake(227, 247, 231, 256));
    
	__kol_images["__skill Easy Riding"] = KOLImageMake("images/itemimages/motorbike.gif", Vec2iMake(30,30));
	__kol_images["__skill jump shark"] = KOLImageMake("images/itemimages/sharkfin.gif", Vec2iMake(30,30));
	__kol_images["__skill Natural Dancer"] = KOLImageMake("images/itemimages/dance3.gif", Vec2iMake(30,30));
	__kol_images["__skill Check Mirror"] = KOLImageMake("images/itemimages/bikemirror.gif", Vec2iMake(30,30));
	__kol_images["__skill Ball Lightning"] = KOLImageMake("images/itemimages/balllightning.gif", Vec2iMake(30,30));
	__kol_images["__skill rain man"] = KOLImageMake("images/itemimages/rainman.gif", Vec2iMake(30,30));
    
    
    
	__kol_images["mini-adventurer blank female"] = KOLImageMake("images/itemimages/miniadv0f.gif", Vec2iMake(30,30));
	__kol_images["mini-adventurer seal clubber female"] = KOLImageMake("images/itemimages/miniadv1f.gif", Vec2iMake(30,30));
	__kol_images["mini-adventurer turtle tamer female"] = KOLImageMake("images/itemimages/miniadv2f.gif", Vec2iMake(30,30));
	__kol_images["mini-adventurer pastamancer female"] = KOLImageMake("images/itemimages/miniadv3f.gif", Vec2iMake(30,30));
	__kol_images["mini-adventurer sauceror female"] = KOLImageMake("images/itemimages/miniadv4f.gif", Vec2iMake(30,30));
	__kol_images["mini-adventurer disco bandit female"] = KOLImageMake("images/itemimages/miniadv5f.gif", Vec2iMake(30,30));
	__kol_images["mini-adventurer accordion thief female"] = KOLImageMake("images/itemimages/miniadv6f.gif", Vec2iMake(30,30));
    
	__kol_images["Lady Spookyraven"] = KOLImageMake("images/otherimages/spookyraven/sr_ladys.gif", Vec2iMake(65,65), RectMake(0, 0, 64, 37));
	__kol_images["Yeti"] = KOLImageMake("images/adventureimages/yeti.gif", Vec2iMake(100,100), RectMake(12, 0, 80, 98));
	__kol_images["Lights Out"] = KOLImageMake("images/adventureimages/lightning.gif", Vec2iMake(100,100), RectMake(0, 10, 99, 96));
    
	
	string class_name = my_class().to_string();
	string class_nemesis_name = "Nemesis " + class_name;
	
	if (__kol_images contains class_name)
		__kol_images["Player Character"] = __kol_images[class_name];
	else
		__kol_images["Player Character"] = __kol_images["Disco Bandit"];
		
	if (__kol_images contains class_nemesis_name)
		__kol_images["Nemesis"] = __kol_images[class_nemesis_name];
	else
		__kol_images["Nemesis"] = __kol_images["Jick"];
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
        if (lookup_name.stringHasPrefix("__effect "))
        {
            secondary_lookup_name = lookup_name.substring(9);
            f = $familiar[none];
            it = $item[none];
            e = secondary_lookup_name.to_effect();
        }
        if (lookup_name.stringHasPrefix("__monster "))
        {
            secondary_lookup_name = lookup_name.substring(10);
            f = $familiar[none];
            it = $item[none];
            e = $effect[none];
            m = secondary_lookup_name.to_monster();
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
        else if (m != $monster[none] && m.image.length() > 0 && m.to_string().to_lower_case() == secondary_lookup_name)
        {
            __kol_images[lookup_name] = KOLImageMake("images/adventureimages/" + m.image, Vec2iMake(100, 100));
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
buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_center, Vec2i max_image_dimensions, string container_additional_class)
{
    KOLImagesInit();
	lookup_name = to_lower_case(lookup_name);
    
    boolean half_sized_output = false;
	lookup_name = to_lower_case(lookup_name);
    if (lookup_name.stringHasPrefix("__half "))
    {
        lookup_name = lookup_name.substring(7);
        half_sized_output = true;
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
    
    if (container_additional_class.length() > 0)
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
        
        if (should_center)
            classes.listAppend("r_center");
        if (container_additional_class.length() > 0)
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
    while (unadorned_name.length() > 0 && unadorned_name.stringHasPrefix("__") && breakout > 0)
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
			string style = "width:" + dimensions.x + "px;height:" + dimensions.y + "px;";
			if (__setting_show_alignment_guides)
				style += "background:pink;";
			else
				style += "background:#FFFFFF;";
			
			style += "z-index:2;position:absolute;top:" + top + "px;left:" + left + "px;";
			
			result.append(HTMLGenerateDivOfStyle("", style));
		}
	}
	
	if (outputting_div)
		result.append("</div>");
	return result;
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_center, Vec2i max_image_dimensions)
{
    return KOLImageGenerateImageHTML(lookup_name, should_center, max_image_dimensions, "");
}

buffer KOLImageGenerateImageHTML(string lookup_name, boolean should_center)
{
	return KOLImageGenerateImageHTML(lookup_name, should_center, Vec2iMake(65535, 65535));
}