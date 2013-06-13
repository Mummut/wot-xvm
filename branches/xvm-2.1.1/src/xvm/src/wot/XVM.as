﻿/**
 * ...
 * @author Nikolas Siver
 * @author bkon
 * @author sirmax2
 * @author STL1te
 */
import flash.filters.DropShadowFilter;
import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.easing.Linear;
import com.greensock.easing.Cubic;
import wot.utils.Config;
import wot.utils.Defines;
import wot.utils.GraphicsUtil;
import wot.utils.Stat;
import wot.utils.Utils;
import wot.utils.Logger;

class wot.XVM extends net.wargaming.ingame.VehicleMarker
{
  static var DEBUG_TIMES = false;

  // UI Elements
  var damageHolder: MovieClip;
  var xvmHB: MovieClip;
  var xvmHBBorder: MovieClip;
  var xvmHBFill: MovieClip;
  var xvmHBDamage: MovieClip;
  var grid: MovieClip = null;

  // Private static members
  var s_blowedUp: Array = [];
  var s_isColorBlindMode = false;

  // Private members
  var m_showExInfo: Boolean = false;
  var m_currentHealth: Number;
  var m_showMaxHealth: Boolean;

  // TextFields
  var textFields: Object = null;

  // Healthbar Settings
  var hbCfg: Object = null;

  // All stated
  var allStatesAlly: Array = [
    "ally/alive/normal", "ally/alive/extended", "ally/dead/normal", "ally/dead/extended"
  ]
  var allStatesEnemy: Array = [
    "enemy/alive/normal", "enemy/alive/extended", "enemy/dead/normal", "enemy/dead/extended"
  ]

  function XVM()
  {
    /*if (!_global.xvm)
      _global.xvm = [];
    if (wot.utils.Utils.indexOf(_global.xvm, "XVM") == -1)
      _global.xvm.push("XVM");
    wot.utils.Logger.add("--> " + _global.xvm.join(", "));*/

    super();

    Config.LoadConfigAndStatLegacy("XVM.xvmconf", "XVM.as");

    xvmHB = createEmptyMovieClip("xvmHB", marker.getDepth() - 1); // Put health Bar to back.
    xvmHBBorder = xvmHB.createEmptyMovieClip("border", 1);
    xvmHBDamage = xvmHB.createEmptyMovieClip("damage", 2);
    xvmHBFill = xvmHB.createEmptyMovieClip("fill", 3);

    damageHolder = createEmptyMovieClip("damageHolder", getNextHighestDepth());

    // Remove standard fields
    pNameField._visible = false;
    pNameField.removeTextField();

    vNameField._visible = false;
    vNameField.removeTextField();

    healthBar.stop();
    healthBar._visible = false;
    healthBar.removeMovieClip();

    bgShadow.stop();
    bgShadow._visible = false;
    bgShadow.removeMovieClip();
  }

  function XVMInit(obj: Object)
  {
    onEnterFrame = function()
    {
      try
      {
        if (!Config.s_loaded)
          return;

        delete this.onEnterFrame;

        // Draw watermark
        if (!Config.s_config.battle.hideXVMVersion && !_root.hasOwnProperty("xvmWatermark"))
        {
          var wm = _root.createTextField("xvmWatermark", _root.getNextHighestDepth(), -1, -2, 50, 16);
          wm.antiAliasType = "advanced";
          wm.setNewTextFormat(new TextFormat("$FieldFont", 8, 0x808080, false, false, false, null, null, "left"));
          wm._alpha = 10;
          wm.text = "XVM v" + Defines.XVM_VERSION;
        }

        // Draw grid
        if (Config.s_config.battle.drawGrid)
        {
          this.grid = this.createEmptyMovieClip("grid", this.getNextHighestDepth());
          GraphicsUtil.drawGrid(this.grid, -50, -50, 100, 100, 0xFFFF00, 30);
        }

        // Alternative icon set
        this.m_source = this.m_source.split(Defines.CONTOUR_ICON_PATH).join(Config.s_config.iconset.vehicleMarker);
        if (this.iconLoader != null)
          this.iconLoader.source = this.m_source;

        this.XVMPopulateData();
        this.updateMarkerLabel();
      }
      catch (e)
      {
        this.XVMSetErrorText("ERROR: XVMInit():" + String(e));
      }
    }
  }

  // override
  function init(vClass, vIconSource, vType, vLevel, pFullName, curHealth, maxHealth, entityName, speaking, hunt)
  {
    // Use currently remembered extended / normal status for new markers
    m_showExInfo = s_showExInfo;
    super.init(vClass, vIconSource, vType, vLevel, pFullName, curHealth, maxHealth, entityName, speaking, hunt);
  }

  // override
  function updateMarkerSettings()
  {
    // do nothing
  }

  // override
  function updateHealth(curHealth)
  {
    if (curHealth < 0)
      s_blowedUp.push(m_playerFullName);
    m_curHealth = curHealth >= 0 ? curHealth : 0;
    XVMSetupNewHealth(curHealth);
    XVMUpdateUI(curHealth);
  }

  // override
  function updateState(newState, isImmediate)
  {
    //Logger.add("updateState(): " + GetCurrentStateString() + " markerState=" + m_markerState + " pname=" + m_playerFullName);
    super.updateState(newState, isImmediate);
    XVMUpdateStyle();
  }

  // override
  function showExInfo(show)
  {
    if (m_showExInfo == show)
      return;
    m_showExInfo = show;

    // Save current extended / normal state flag to static variable, so
    // new markers can refer to it when rendered initially
    s_showExInfo = show;

    XVMUpdateStyle();
  }

  // override
  function configUI()
  {
    //Logger.add("configUI(): " + GetCurrentStateString() + " markerState=" + m_markerState + " pname=" + m_playerFullName);
    m_currentHealth = m_curHealth;
    super.configUI();
    XVMInit();
    XVMUpdateStyle();
  }

  // override
  function populateData()
  {
    //Logger.add("populateData(): " + GetCurrentStateString() + " markerState=" + m_markerState + " pname=" + m_playerFullName);

    if (m_isPopulated)
      return false;
    m_isPopulated = true;

    initMarkerLabel();

    if (iconLoader != null && iconLoader.initialized)
    {
      iconLoader.addEventListener("ioError", this, "_onErrorLoad");
      iconLoader.addEventListener("complete", this, "_onCompleteLoad");
    }
    else
    {
      this.invalidate();
    }

    if (levelIcon != null)
      levelIcon.gotoAndStop(m_level);

    if (m_vehicleClass != null)
      this.setVehicleClass();

    if (m_markerState != null)
      marker.gotoAndPlay(m_markerState);

    XVMPopulateData();
    XVMSetupNewHealth(m_curHealth);

    return true;
  }

  // override
  function initMarkerLabel()
  {
    super.initMarkerLabel();
    XVMUpdateMarkerLabel();
    XVMUpdateUI(m_curHealth);
  }

  // override
  function updateMarkerLabel()
  {
    //Logger.add("updateMarkerLabel(): " + GetCurrentStateString() + " markerLabel=" + m_markerLabel + " pname=" + m_playerFullName);
    super.updateMarkerLabel();

    XVMUpdateMarkerLabel();

    XVMIconCompleteLoad();

    // Update layout for the current marker state
    XVMPopulateVehicleTypeMarker();
    XVMUpdateStyle();
  }

  // override
  function _onErrorLoad(event)
  {
    //Logger.add("_onErrorLoad: " + event.target.source);
    if (event.target.source)
    {
      // Fallback to default icon
      event.target.source = (Config.s_config.iconset.vehicleMarker != Defines.CONTOUR_ICON_PATH)
        ? event.target.source.split(Config.s_config.iconset.vehicleMarker).join(Defines.CONTOUR_ICON_PATH)
        : event.target.source = Defines.CONTOUR_ICON_PATH + "noImage.tga";
    }
  }

  // override
  function _onCompleteLoad(event)
  {
    iconLoader._visible = false;
    onEnterFrame = function()
    {
      this.XVMIconCompleteLoad();
      delete this.onEnterFrame;
    };
  }

  /**
   * MAIN
   */

  static var errorCounter: Number = 0;
  static var errorText: String = "";
  function XVMSetErrorText(str)
  {
    var et: TextField;
    if (!_root.hasOwnProperty("xvmErrorText"))
    {
      et = _root.createTextField("xvmErrorText", _root.getNextHighestDepth(), 350, 40, 1000, 300);
      et.antiAliasType = "advanced";
      et.wordWrap = true;
      et.multiline = true;
      et.setNewTextFormat(new TextFormat("$FieldFont", 12, 0xFF6666, false, false, false, null, null, "left"));
      et.filters = [new DropShadowFilter(0, 0, 0, 100, 3, 3, 2, 3)];
    }

    errorText += "[" + Utils.padLeft((errorCounter++).toString(), 3, '0') + "] " + str + "\n";
    while ((errorText.split("\n")).length > 15)
      errorText = errorText.slice(errorText.indexOf("\n") + 1, errorText.length - 1);
    _root.xvmErrorText.text = errorText;
  }

  // VehicleMarkerAlly should contain 4 named frames:
  // - green - normal ally
  // - gold - squad mate
  // - blue - teamkiller
  // - yellow - squad mate in color blind mode
  // VehicleMarkerEnemy should contain 2 named frames:
  // - red - normal enemy
  // - purple - enemy in color blind mode
  function XVMGetMarkerColorAlias()
  {
    //if (m_entityName != "ally" && m_entityName != "enemy" && m_entityName != "squadman" && m_entityName != "teamKiller")
    //  Logger.add("m_entityName=" + m_entityName);
    if (m_entityName == "ally")
      return "green";
    if (m_entityName == "squadman")
      return s_isColorBlindMode ? "yellow" : "gold";
    if (m_entityName == "teamKiller")
      return "blue";
    if (m_entityName == "enemy")
      return s_isColorBlindMode ? "purple" : "red";

    // if not found (node is not implemented), return inverted enemy color
    return s_isColorBlindMode ? "red" : "purple";
  }

  function XVMGetSystemColor()
  {
    var systemColorName: String = m_entityName + "_";
    systemColorName += (!vehicleDestroyed) ? "alive_" : (Utils.indexOf(s_blowedUp, m_playerFullName) >= 0) ? "blowedup_" : "dead_";
    systemColorName += s_isColorBlindMode ? "blind" : "normal";
    return Config.s_config.colors.system[systemColorName];
  }

  function GetCurrentStateString(): String
  {
    var result = m_entityName == "enemy" ? "enemy/" : "ally/";
    result += this.vehicleDestroyed ? "dead/" : "alive/";
    result += m_showExInfo ? "extended" : "normal";
    return result;
  }

  function GetStateConfigRoot(stateString: String)
  {
    var path: Array = stateString.split("/");
    if (path.length != 3)
      return null;
    var result = Config.s_config.markers;
    result = path[0] == "ally" ? result.ally : result.enemy;
    result = path[1] == "alive" ? result.alive : result.dead;
    result = path[2] == "normal" ? result.normal : result.extended;
    return result;
  }

  function GetCurrentStateConfigRoot()
  {
    return GetStateConfigRoot(GetCurrentStateString());
  }

  function GetCurrentStateConfigRootNormal()
  {
    return GetStateConfigRoot(GetCurrentStateString().split("extended").join("normal"));
  }

  function XVMFormatStaticText(format: String): String
  {
    try
    {
      // AS 2 doesn't have String.replace? Shame on them. Let's use our own square wheel.
      format = format.split("{{nick}}").join(m_playerFullName);
      format = format.split("{{vehicle}}").join(m_vname);
      format = format.split("{{level}}").join(m_level);
      format = Stat.FormatText({ label: m_playerFullName }, format);
      format = Utils.trim(format);
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMFormatStaticText(" + format + "):" + String(e));
    }
    return format;
  }

  function XVMFormatDynamicText(format: String, curHealth: Number, delta: Number): String
  {
    try
    {
      if (format.indexOf("{{") == -1)
        return format;

      var hpRatio: Number = Math.ceil(curHealth / m_maxHealth * 100);
      format = format.split("{{hp}}").join(String(curHealth));
      format = format.split("{{hp-max}}").join(String(m_maxHealth));
      format = format.split("{{hp-ratio}}").join(String(hpRatio));

      var dmgRatio: Number = delta ? Math.ceil(delta / m_maxHealth * 100) : 0;
      format = format.split("{{dmg}}").join(delta ? String(delta) : "");
      format = format.split("{{dmg-ratio}}").join(delta ? String(dmgRatio) : "");

      format = Utils.trim(format);
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMFormatDynamicText(" + format + "):" + String(e));
    }

    return format;
  }

  function XVMFormatStaticColorText(format: String): String
  {
    try
    {
      if (!format || isFinite(format))
        return format;

      format = Stat.FormatText( { label: m_playerFullName }, format).split("#").join("0x");
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMFormatStaticColorText(" + format + "):" + String(e));
    }

    return format;
  }

  function XVMFormatDynamicColor(format: String, curHealth: Number): Number
  {
    var systemColor = XVMGetSystemColor();
    try
    {
      if (!format)
        return systemColor;

      if (isFinite(format))
        return Number(format);

      var hpRatio: Number = Math.ceil(curHealth / m_maxHealth * 100);
      var formatArr = format.split("{{c:hp}}");
      if (formatArr.length > 1)
        format = formatArr.join(GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_HP, curHealth, "0x"))
      formatArr = format.split("{{c:hp-ratio}}");
      if (formatArr.length > 1)
        format = formatArr.join(GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_HP_RATIO, hpRatio, "0x"))
      formatArr = format.split("{{c:hp_ratio}}");
      if (formatArr.length > 1)
        format = formatArr.join(GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_HP_RATIO, hpRatio, "0x"))
      return isFinite(format) ? Number(format) : systemColor;
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMFormatDynamicColor(" + format + "):" + String(e));
    }

    return systemColor;
  }

  function XVMFormatDynamicAlpha(format: String, curHealth: Number): Number
  {
    try
    {
      if (!format)
        return 100;

      if (isFinite(format))
        return Number(format);

      var hpRatio: Number = Math.ceil(curHealth / m_maxHealth * 100);
      var formatArr = format.split("{{a:hp}}");
      if (formatArr.length > 1)
        format = formatArr.join(GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_HP, curHealth).toString());
      formatArr = format.split("{{a:hp-ratio}}");
      if (formatArr.length > 1)
        format = formatArr.join(GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_HP_RATIO, hpRatio).toString());
      formatArr = format.split("{{a:hp_ratio}}");
      if (formatArr.length > 1)
        format = formatArr.join(GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_HP_RATIO, hpRatio).toString());

      var n = isFinite(format) ? Number(format) : 100;
      return (n <= 0) ? 1 : (n > 100) ? 100 : n;
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMFormatDynamicAlpha(" + format + "):" + String(e));
    }

    return 100;
  }

  function XVMCreateNewTextFormat(config_font: Object)
  {
    try
    {
      if (!config_font)
        return null;

      return new TextFormat(
        config_font.name,
        config_font.size,
        0x000000,
        config_font.bold,
        false, false, null, null,
        config_font.align);
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMCreateNewTextFormat():" + String(e));
    }

    return null;
  }

  function XVMCreateTextField(cfg)
  {
    try
    {
      var n = getNextHighestDepth();
      var textField: TextField = createTextField("textField" + n, n, 0, 0, 140, 31);
      textField.html = true; // FIXIT: in html mode Font and Position are wrong.
      textField.antiAliasType = "normal";
      textField.embedFonts = true;
      textField.selectable = false;
      textField.multiline = false;
      textField.wordWrap = false;
      var textFormat: TextFormat = XVMCreateNewTextFormat(cfg.font);
      textField.setNewTextFormat(textFormat);
      textField.filters = [ GraphicsUtil.createShadowFilter(cfg.shadow) ];

      var staticColor = XVMFormatStaticColorText(cfg.color);
      textField.textColor = XVMFormatDynamicColor(staticColor, m_curHealth);
      textField._alpha = XVMFormatDynamicAlpha(cfg.alpha, m_curHealth);
      textField._x = cfg.x - (textField._width >> 1);
      textField._y = cfg.y - (textField._height >> 1);
      textField._visible = cfg.visible;

      return { field: textField, format: XVMFormatStaticText(cfg.format), alpha: cfg.alpha, color: staticColor };
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMCreateTextField():" + String(e));
    }

    return null;
  }

  // Damage Visualization
  function removeTextField(f: TextField)
  {
    f.removeTextField();
  }

  function XVMShowDamage(curHealth, delta)
  {
    try
    {
      var cfg = GetCurrentStateConfigRoot().damageText;

      if (!cfg.visible)
        return;

      var msg = (curHealth < 0) ? cfg.blowupMessage : cfg.damageMessage;
      var text = XVMFormatDynamicText(XVMFormatStaticText(msg), curHealth, delta);

      var n = damageHolder.getNextHighestDepth();
      var damageField = damageHolder.createTextField("damageField" + n, n, 0, 0, 140, 20);
      var animation: TimelineLite = new TimelineLite({ onComplete:this.removeTextField, onCompleteParams:[damageField] });

      // For some reason, DropShadowFilter is not rendered when textfield contains only one character,
      // so we're appending empty prefix and suffix to bypass this unexpected behavior
      damageField.text = " " + text + " ";
      damageField.antiAliasType = "advanced";
      damageField.autoSize = "left";
      damageField.border = false;
      damageField.embedFonts = true;
      damageField.setTextFormat(XVMCreateNewTextFormat(cfg.font));
      damageField.textColor = isFinite(cfg.color) ? Number(cfg.color)
        : Config.s_config.colors.system[m_entityName + "_alive_" + (s_isColorBlindMode ? "blind" : "normal")];
      damageField._x = -(damageField._width >> 1);
      damageField.filters = [ GraphicsUtil.createShadowFilter(cfg.shadow) ];

      animation.insert(new TweenLite(damageField, cfg.speed, { _y: -cfg.maxRange, ease: Linear.easeOut } ), 0);
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: showDamage():" + String(e));
    }
  }

  // Health Visualization
  function XVMSetupNewHealth(curHealth)
  {
    try
    {
      var delta: Number = curHealth - m_currentHealth;
      if (delta < 0)
      {
        XVMUpdateHealthBar(curHealth, m_maxHealth); // colorizing health bar after taking damage

        XVMShowDamage(curHealth, -delta);

        m_currentHealth = curHealth;

        //Flow bar animation
        TweenLite.killTweensOf(xvmHBDamage);
        xvmHBDamage._x = hbCfg.border.size + hbCfg.width * (curHealth / m_maxHealth) - 1;
        xvmHBDamage._xscale = xvmHBDamage._xscale + 100 * (-delta / m_maxHealth);
        GraphicsUtil.setColor(xvmHBDamage, XVMFormatDynamicColor(hbCfg.damage.color, curHealth));
        xvmHBDamage._alpha = XVMFormatDynamicAlpha(hbCfg.damage.alpha, curHealth);
        TweenLite.to(xvmHBDamage, hbCfg.damage.fade, {_xscale: 0, ease: Cubic.easeIn });
      }
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMSetupNewHealth():" + String(e));
    }
  }

  function XVMUpdateMarkerLabel()
  {
    // Guess color blind mode
    if (m_markerLabel == "yellow" || m_markerLabel == "purple")
      s_isColorBlindMode = true;
    else if (m_markerLabel == "gold" || m_markerLabel == "red")
      s_isColorBlindMode = false;

    // Hide original fields
    if (pNameField != null)
    {
      pNameField._visible = false;
      pNameField.removeTextField();
    }
    if (vNameField != null)
    {
      vNameField._visible = false;
      vNameField.removeTextField();
    }
  }

  function XVMUpdateUI(curHealth)
  {
    try
    {
      xvmHBFill._xscale = Math.min(curHealth / m_maxHealth * 100, 100);

      if (textFields)
      {
        var st = GetCurrentStateString();
        for (var i in textFields[st])
        {
          var tf = textFields[st][i];
          tf.field.text = XVMFormatDynamicText(tf.format, curHealth);
          tf.field.textColor = XVMFormatDynamicColor(tf.color, curHealth);
          tf.field._alpha = XVMFormatDynamicAlpha(tf.alpha, curHealth);
        }
      }
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMUpdateUI():" + String(e));
    }
  }

  function XVMUpdateHealthBar(curHealth)
  {
    try
    {
      if (!Config.s_loaded)
        return;

      var cfg = GetCurrentStateConfigRoot().healthBar;

      xvmHB._alpha = XVMFormatDynamicAlpha(cfg.alpha, curHealth);

      var ct = XVMFormatStaticColorText(cfg.color);
      var lct = XVMFormatStaticColorText(cfg.lcolor);
      var fullColor: Number = XVMFormatDynamicColor(ct, curHealth);
      var lowColor: Number = XVMFormatDynamicColor(lct || ct, curHealth);

      var percent: Number = curHealth / m_maxHealth;

      // determ current (real-time) color
      var currColor = GraphicsUtil.colorByRatio(percent, lowColor, fullColor);

      GraphicsUtil.setColor(xvmHBFill, currColor); // colorizing health bar
      xvmHBFill._alpha = XVMFormatDynamicAlpha(cfg.fill.alpha, curHealth);

      GraphicsUtil.setColor(xvmHBBorder, XVMFormatDynamicColor(cfg.border.color, curHealth));
      xvmHBBorder._alpha = XVMFormatDynamicAlpha(cfg.border.alpha, curHealth);

      GraphicsUtil.setColor(xvmHBDamage, XVMFormatDynamicColor(cfg.damage.color, curHealth));
      xvmHBDamage._alpha = XVMFormatDynamicAlpha(cfg.damage.alpha, curHealth);

      //Logger.add("color: " + cfg.color + " => " + currColor);
      //if (cfg.alpha == "{{a:hp-ratio}}")
      //  Logger.add(Math.round(percent * 100) + " => " + Math.round(xvmHB._alpha));
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: updateCurrentColor():" + String(e));
    }
  }

  function XVMIconCompleteLoad(event)
  {
    try
    {
      if (!Config.s_loaded)
        return;

      // Vehicle Icon
      var cfg = GetCurrentStateConfigRootNormal().contourIcon;

      if (cfg.amount >= 0)
      {
        var iconColor: Color = new Color(iconLoader);
        var tintColor: Number = XVMFormatDynamicColor(XVMFormatStaticColorText(cfg.color), m_curHealth);
        var tintAmount: Number = cfg.amount * 0.01;
        var tintRatio: Number;

        var iconTransform: Object = iconColor.getTransform();
        iconTransform.rb = (tintColor >> 16);
        iconTransform.gb = (tintColor >> 8) & 0xff;
        iconTransform.bb = (tintColor & 0xff);
        iconTransform.ra = 0;
        iconTransform.ga = 0;
        iconTransform.ba = 0;
        tintRatio = tintAmount / (1 - ((iconTransform.ra + iconTransform.ga + iconTransform.ba) / 300));
        iconTransform.rb *= tintRatio;
        iconTransform.gb *= tintRatio;
        iconTransform.bb *= tintRatio;
        iconTransform.ra = iconTransform.ga = iconTransform.ba = (1 - tintAmount) * 100;
        iconColor.setTransform(iconTransform);
      }

      XVMUpdateStyle();
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMIconCompleteLoad():" + String(e));
    }
  }

  function XVMDrawHealthBar(cfg)
  {
    xvmHB.clear();
    xvmHBBorder.clear();
    xvmHBFill.clear();
    xvmHBDamage.clear();

    hbCfg = cfg;

    //GraphicsUtil.fillRect(xvmHB, 0, 0, hbCfg.width + 2 * hbCfg.border, hb.height + 2 * hb.border,
    //  cfg.healthBar.border.color, cfg.healthBar.border.alpha);
    GraphicsUtil.fillRect(xvmHBBorder, 0, 0, cfg.width + cfg.border.size * 2, cfg.height + cfg.border.size * 2);
    GraphicsUtil.fillRect(xvmHBFill, cfg.border.size, cfg.border.size, cfg.width, cfg.height);
    GraphicsUtil.fillRect(xvmHBDamage, cfg.border.size, cfg.border.size, cfg.width, cfg.height);

    xvmHBDamage._xscale = 0;

    XVMUpdateHealthBar(m_curHealth);
  }

  private var _statesInitialized: Boolean = false;
  function XVMInitializeStates()
  {
    try
    {
      if (!m_vname || !m_playerFullName)
        return;

      if (_statesInitialized)
        return;

      _statesInitialized = true;

      textFields = { };
      var allStates = (m_entityName == "enemy") ? allStatesEnemy : allStatesAlly;
      for (var stid in allStates)
      {
        var st = allStates[stid];
        var cfg = GetStateConfigRoot(st);

        // create text fields
        var fields: Array = [];
        for (var i in cfg.textFields)
        {
          if (cfg.textFields[i].visible)
          {
            //if (m_entityName == "ally")
              //Logger.addObject(cfg.textFields[i], m_vname + " " + m_playerFullName + " " + st);
  //          if (m_entityName == "enemy")
  //            Logger.addObject(cfg.textFields[i], m_vname + " " + m_playerFullName + " " + st);
            fields.push(XVMCreateTextField(cfg.textFields[i]));
          }
        }
        textFields[st] = fields;
      }
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMInitializeStates():" + String(e));
    }
  }

  function XVMPopulateVehicleTypeMarker()
  {
    try
    {
      var cfg = GetCurrentStateConfigRootNormal();

      // Vehicle Type Marker
      var systemColor = XVMGetSystemColor();
      for (var childName in marker.marker)
      {
        //if (childName == "marker_shadow")
        //  return;

        var icon: MovieClip = marker.marker[childName];
        icon._x = cfg.vehicleIcon.scaleX * cfg.vehicleIcon.maxScale / 100;
        icon._y = cfg.vehicleIcon.scaleY * cfg.vehicleIcon.maxScale / 100;
        icon._xscale = icon._yscale = cfg.vehicleIcon.maxScale;

        /*var ms: MovieClip = icon.duplicateMovieClip("marker_shadow", icon.getNextHighestDepth());
        ms.gotoAndStop(icon._currentframe);
        ms.filters = [ new DropShadowFilter(0, 0, 0, 1, 1, 1, 10, 1, false, true) ];
        GraphicsUtil.setColor(icon, systemColor);*/
      };
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMPopulateVehicleTypeMarker():" + String(e));
    }
  }

  function XVMPopulateData()
  {
    try
    {
      //Logger.add("XVMPopulateData: " + m_vname + " " + m_playerFullName);
      if (!Config.s_loaded)
        return;

      var start = new Date();

      var cfg = GetCurrentStateConfigRootNormal();

      // Vehicle Type Marker
      XVMPopulateVehicleTypeMarker();

      // Vehicle Type Icon
      if (iconLoader != null && iconLoader.initialized)
        iconLoader.addEventListener("complete", this, "XVMIconCompleteLoad");

      // Health Bar
      XVMDrawHealthBar(cfg.healthBar);

      // Initialize states and creating text fields
      XVMInitializeStates();

      if (DEBUG_TIMES)
        Logger.add("DEBUG TIME: XVMPopulateData(): " + Utils.elapsedMSec(start, new Date()) + " ms");
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMPopulateData():" + String(e));
    }
  }

  function XVMUpdateStyle()
  {
    try
    {
      //Logger.add("XVMUpdateStyle: " + m_vname + " " + m_playerFullName);

      if (!Config.s_loaded)
        return;

      var start = new Date();

      var cfg = GetCurrentStateConfigRoot();

      var visible: Boolean;

      // Vehicle Type Marker
      visible = cfg.vehicleIcon.visible;
      if (visible)
      {
        marker._x = cfg.vehicleIcon.x;
        marker._y = cfg.vehicleIcon.y;
        marker._alpha = XVMFormatDynamicAlpha(cfg.vehicleIcon.alpha, m_curHealth);
      }
      marker._visible = visible;

      // Level Icon
      visible = cfg.levelIcon.visible;
      if (visible)
      {
        levelIcon._x = cfg.levelIcon.x;
        levelIcon._y = cfg.levelIcon.y;
        levelIcon._alpha = XVMFormatDynamicAlpha(cfg.levelIcon.alpha, m_curHealth);
      }
      levelIcon._visible = visible;

      // Action Marker
      visible = cfg.actionMarker.visible;
      if (visible)
      {
        actionMarker._x = cfg.actionMarker.x;
        actionMarker._y = cfg.actionMarker.y;
      }
      actionMarker._visible = visible;

      // Vehicle Icon
      if (iconLoader != null && iconLoader.initialized)
      {
        visible = cfg.contourIcon.visible;
        if (visible)
        {
          iconLoader._x = cfg.contourIcon.x - (iconLoader.content._width >> 1);
          iconLoader._y = cfg.contourIcon.y - (iconLoader.content._height >> 1);
          iconLoader._alpha = XVMFormatDynamicAlpha(cfg.contourIcon.alpha, m_curHealth);
        }
        iconLoader._visible = visible;
      }

      // Damage Text
      visible = cfg.damageText.visible;
      if (visible)
      {
        damageHolder._x = cfg.damageText.x;
        damageHolder._y = cfg.damageText.y;
      }
      damageHolder._visible = visible;

      // Health Bar
      visible = cfg.healthBar.visible;
      if (visible)
      {
        xvmHB._x = cfg.healthBar.x;
        xvmHB._y = cfg.healthBar.y;
        xvmHB._alpha = XVMFormatDynamicAlpha(cfg.healthBar.alpha, m_curHealth);
      }
      xvmHB._visible = visible;

      // Text fields
      if (textFields)
      {
        var st = GetCurrentStateString();
        for (var i in textFields)
        {
          for (var j in textFields[i])
            textFields[i][j].field._visible = (i == st);
        }
      }

      // Update Colors and Values
      XVMUpdateHealthBar(m_curHealth);
      XVMUpdateUI(m_curHealth);

      if (DEBUG_TIMES)
        Logger.add("DEBUG TIME: XVMUpdateStyle(): " + Utils.elapsedMSec(start, new Date()) + " ms");
    }
    catch (e)
    {
      XVMSetErrorText("ERROR: XVMUpdateStyle():" + String(e));
    }
  }
}