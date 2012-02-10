﻿/**
 * ...
 * @author sirmax2
 */
import wot.utils.Config;

class wot.Main
{
  // override
  static var instance:Main;
  
  static function main()
  {
    Config.LoadConfig("OTMData.xml");

    instance = new Main();
    
    //gfx.io.GameDelegate.addCallBack("battle.showPostmortemTips", this, "showPostmortemTips");
    gfx.io.GameDelegate.addCallBack("battle.showPostmortemTips", instance, "showPostmortemTips");
  }
  
  function showPostmortemTips(movingUpTime, showTime, movingDownTime)
  {
    if (Config.value("battle/showPostmortemTips/data") != "false")
      _root.showPostmortemTips(movingUpTime, showTime, movingDownTime);
  }
}
