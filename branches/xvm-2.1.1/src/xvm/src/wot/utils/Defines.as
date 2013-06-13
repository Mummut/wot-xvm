/**
 * ...
 * @author sirmax2
 */
class wot.utils.Defines
{
  // Global versions
  public static var XVM_VERSION = "2.1.1";
  public static var WOT_VERSION = "0.7.2";
  public static var CONFIG_VERSION = "1.2.0";
  public static var EDITOR_VERSION = "0.0.0";

  public static var DEFAULT_CONFIG_NAME = "XVM.xvmconf";

  // file name limit is ~ 220 chars
  public static var MAX_PATH = 170;

  // Path to Dokan MountPoint
  public static var DOKAN_MP = "../../../.stat/";

  // WebDav commands
  public static var COMMAND_LOG = DOKAN_MP + "@LOG";
  public static var COMMAND_SET = DOKAN_MP + "@SET";
  public static var COMMAND_ADD = DOKAN_MP + "@ADD";
  public static var COMMAND_GET = DOKAN_MP + "@GET";
  public static var COMMAND_RUN = DOKAN_MP + "@RUN";
  public static var COMMAND_RUNINGAME = DOKAN_MP + "@RUNINGAME";
  public static var COMMAND_RETRIEVE = DOKAN_MP + "@RETRIEVE";
  public static var COMMAND_READY = DOKAN_MP + "@READY";
  public static var COMMAND_GET_LAST_STAT = DOKAN_MP + "@GET_LAST_STAT";

  // Position
  public static var POSITION_LEFT = 0;
  public static var POSITION_RIGHT = 1;

  // Team
  public static var TEAM_ALLY = 0;
  public static var TEAM_ENEMY = 1;

  // Dynamic color types
  public static var DYNAMIC_COLOR_EFF = 1;
  public static var DYNAMIC_COLOR_RATING = 2;
  public static var DYNAMIC_COLOR_KB = 3;
  public static var DYNAMIC_COLOR_HP = 4;
  public static var DYNAMIC_COLOR_HP_RATIO = 5;

  // Dynamic alpha types
  public static var DYNAMIC_ALPHA_EFF = 1;
  public static var DYNAMIC_ALPHA_RATING = 2;
  public static var DYNAMIC_ALPHA_KB = 3;
  public static var DYNAMIC_ALPHA_HP = 4;
  public static var DYNAMIC_ALPHA_HP_RATIO = 5;
  
  // Default path to vehicle icons (relative)
  public static var CONTOUR_ICON_PATH = "../maps/icons/vehicle/contour/";
}