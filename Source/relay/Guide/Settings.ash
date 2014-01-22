//These settings are for development. Don't worry about editing them.
string __version = "1.0.7";

//Debugging:
boolean __setting_debug_mode = false;
boolean __setting_debug_enable_example_mode_in_aftercore = false; //for testing. Will give false information, so don't enable
boolean __setting_debug_show_all_internal_states = false; //displays usable images/__misc_state/__misc_state_string/__misc_state_int/__quest_state

//Display settings:
boolean __setting_side_negative_space_is_dark = false;
boolean __setting_fill_vertical = true;

boolean __show_importance_bar = true;
boolean __setting_show_navbar = true;
boolean __setting_navbar_has_proportional_widths = false; //doesn't look very good, remove?
boolean __use_table_based_layouts = false; //backup implementation
boolean __setting_use_kol_css = false; //images/styles.css

string __setting_unavailable_color = "#7F7F7F";
string __setting_line_color = "#B2B2B2";
string __setting_dark_color = "#C0C0C0";
string __setting_modifier_color = "#404040";
string __setting_navbar_background_color = "#FFFFFF";
string __setting_page_background_color = "#F7F7F7";



float __setting_navbar_height_in_em = 2.3;
string __setting_navbar_height = __setting_navbar_height_in_em + "em";
int __setting_horizontal_width = 600;
boolean __setting_ios_appearance = false; //no don't

//Runtime variables:
string __relay_filename;
location __last_adventure_location;