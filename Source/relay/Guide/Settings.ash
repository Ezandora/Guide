//These settings are for development. Don't worry about editing them.
string __version = "1.3.13";

//Debugging:
boolean __setting_debug_mode = false;
boolean __setting_debug_enable_example_mode_in_aftercore = false; //for testing. Will give false information, so don't enable
boolean __setting_debug_show_all_internal_states = false; //displays usable images/__misc_state/__misc_state_string/__misc_state_int/__quest_state

//Display settings:
boolean __setting_entire_area_clickable = false;
boolean __setting_side_negative_space_is_dark = true;
boolean __setting_fill_vertical = true;
int __setting_image_width_large = 100;
int __setting_image_width_medium = 70;
int __setting_image_width_small = 30;

boolean __show_importance_bar = true;
boolean __setting_show_navbar = true;
boolean __setting_navbar_has_proportional_widths = false; //doesn't look very good, remove?
boolean __setting_gray_navbar = true;
boolean __use_table_based_layouts = false; //backup implementation. not compatible with media queries. consider removing?
boolean __setting_use_kol_css = false; //images/styles.css
boolean __setting_show_location_bar = true;
boolean __setting_enable_location_popup_box = true;
boolean __setting_location_bar_uses_last_location = false; //nextAdventure otherwise
boolean __setting_location_bar_fixed_layout = true;
boolean __setting_location_bar_limit_max_width = true;
float __setting_location_bar_max_width_per_entry = 0.35;
boolean __setting_small_size_uses_full_width = false; //implemented, but disabled - doesn't look amazing. reduced indention width instead to compensate
boolean __setting_enable_outputting_all_numberology_options = true;

string __setting_unavailable_colour = "#7F7F7F";
string __setting_line_colour = "#B2B2B2";
string __setting_dark_colour = "#C0C0C0";
string __setting_modifier_colour = "#404040";
string __setting_navbar_background_colour = "#FFFFFF";
string __setting_page_background_colour = "#F7F7F7";

string __setting_media_query_large_size = "@media (min-width: 500px)";
string __setting_media_query_medium_size = "@media (min-width: 350px) and (max-width: 500px)";
string __setting_media_query_small_size = "@media (max-width: 350px) and (min-width: 225px)";
string __setting_media_query_tiny_size = "@media (max-width: 225px)";

float __setting_navbar_height_in_em = 2.3;
string __setting_navbar_height = __setting_navbar_height_in_em + "em";
int __setting_horizontal_width = 600;
boolean __setting_ios_appearance = false; //no don't
