/**
 * XVM Macro substitutions
 * @author Maxim Schedriviy <m.schedriviy@gmail.com>
 */
package com.xvm.utils
{
    import com.xvm.*;
    import com.xvm.types.StatData;
    import flash.utils.Dictionary;

    public class Macros
    {
        // { PLAYERNAME1: { macro1: func || value, macro2:... }, PLAYERNAME2: {...} }
        private static var dict:Dictionary = new Dictionary();

        public static function Format(playerName:String, format:String, options:Object):String
        {
            var formatArr:Array = format.split("{{");

            var len = formatArr.length;
            if (len > 1)
            {
                var res = formatArr[0];
                var pdata: String = dict[WGUtils.GetNormalizedPlayerName(playerName)];
                for (var i = 1; i < len; ++i)
                {
                    var arr2:Array = formatArr[i].split("}}", 2);
                    if (arr2.length == 1 || (options && options.skip && options.skip[arr2[0]]))
                        res += "{{" + formatArr[i];
                    else
                    {
                        var value = !pdata ? "" : pdata[arr2[0]] || "";
                        if (typeof value == "function")
                            res += options ? value(options) : "{{" + arr2[0] + "}}";
                        else
                            res += value;
                        res += arr2[1];
                    }
                }
            }

            //Logger.add(playerName + "> " + format);
            //Logger.add(playerName + "> " + res);
            return Utils.fixImgTag(res);
        }

        public static function RegisterMacrosData(name:String)
        {
            var pname:String = WGUtils.GetNormalizedPlayerName(name);
            var data:StatData = Stat.getData(pname);
            if (data == null)
                return;

            // TODO: Load stat in FogOfWar
            /*if (Stat.loaded && Config.s_config.rating.loadEnemyStatsInFogOfWar)
            {
                if (!data.uid)
                    data.uid = StatData.s_data[pname].playerId;
                var pdata = StatData.s_data[pname];
                //Logger.addObject(pdata);
                //Logger.add("pname=" + pname + " uid=" + data.uid + " r=" + stat.r + " eff=" + stat.eff);
                if ((!pdata || (!pdata.stat && pdata.loadstate == Defines.LOADSTATE_NONE)) ||
                    (StatData.s_data[pname].loadstate == Defines.LOADSTATE_UNKNOWN && VehicleInfo.getInfo2(data.icon).name != "UNKNOWN"))
                {
                    //Logger.addObject(data);
                    StatData.s_data[pname].vehicleKey = VehicleInfo.getInfo2(data.icon).name.toUpperCase();
                    StatData.s_data[pname].loadstate = Defines.LOADSTATE_NONE;
                    GlobalEventDispatcher.dispatchEvent( { type: "process_fow", data: data, team: team } );
                }
            }*/

            if (!dict.hasOwnProperty(pname))
                dict[pname] = new Dictionary();
            var pdata:Dictionary = Macros.dict[pname];

            // vars
            var nick:String = Macros.modXvmDevLabel(data.nm + (data.clan != null && data.clan != "" ? "[" + data.clan + "]" : ""));

            // {{nick}}
            pdata["nick"] = nick;
            // {{name}}
            pdata["name"] = WGUtils.GetPlayerName(nick);
            // {{clan}}
            pdata["clan"] = WGUtils.GetClanNameWithBrackets(nick);
            // {{clannb}}
            pdata["clannb"] = WGUtils.GetClanName(nick);
            // {{vehicle}}
            pdata["vehicle"] = VehicleInfo.mapVehicleName(data.icon, stat.vname);
            // {{vehiclename}} - usa-M24_Chaffee
            pdata["vehiclename"] = VehicleInfo.getVehicleName(data.icon);
            // {{vtype}}
            pdata["vtype"] = VehicleInfo.GetVTypeValue(data.icon);
            // {{c:vtype}}
            pdata["c:vtype"] = GraphicsUtil.GetVTypeColorValue(data.icon, data.vtype);

            // VMM only - static
            // {{squad}}
            pdata["squad"] = data.squad || "";
            // {{level}}
            pdata["level"] = data.level ? String(data.level) : "";
            // {{rlevel}}
            pdata["rlevel"] = data.level ? Defines.ROMAN_LEVEL[data.level - 1] : "";
            // {{hp-max}}
            pdata["hp-max"] = data.maxHealth ? String(data.maxHealth) : "";
            // {{turret}}
            pdata["turret"] = data.turret || "";

            // VMM only - dynamic
            // {{hp}}
            pdata["hp"] = function(o) { return o && o.curHealth != undefined ? String(o.curHealth) : ""; }
            // {{hp-ratio}}
            pdata["hp-ratio"] = function(o) { return o && o.curHealth != undefined ? Math.round(o.curHealth / data.maxHealth * 100) : ""; }
            // {{dmg}}
            pdata["dmg"] = function(o) { return o && o.delta != undefined ? String(o.delta) : ""; }
            // {{dmg-ratio}}
            pdata["dmg-ratio"] = function(o) { return o && o.delta != undefined ? Math.round(o.delta / data.maxHealth * 100) : ""; }
            // {{dmg-kind}}
            pdata["dmg-kind"] = function(o) { return o && o.delta != undefined ? Locale.get(o.damageType) : ""; }

            // Colors
            // {{c:hp}}
            pdata["c:hp"] = function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_HP, o.curHealth); }
            // {{c:hp-ratio}}, {{c:hp_ratio}}
            pdata["c:hp-ratio"] = function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_HP_RATIO, o.curHealth / data.maxHealth * 100); }
            pdata["c:hp_ratio"] = pdata["c:hp-ratio"];
            // {{c:dmg}}
            pdata["c:dmg"] = function(o)
                {
                    return o.delta ? GraphicsUtil.GetDmgSrcValue(
                        Macros.damageFlagToDamageSource(o.damageFlag),
                        o.entityName == 'teamKiller' ? (data.team + "tk") : o.entityName,
                        o.dead, o.blowedUp) : "";
                }
            // {{c:dmg-kind}}, {{c:dmg_kind}}
            pdata["c:dmg-kind"] = function(o) { return o.delta ? GraphicsUtil.GetDmgKindValue(o.damageType) : ""; }
            pdata["c:dmg_kind"] = pdata["c:dmg-kind"];
            // {{c:system}}
            pdata["c:system"] = function(o) { return "#" + Strings.padLeft(o.getSystemColor(o).toString(16), 6, "0"); }

            // Alpha
            // {{a:hp}}
            pdata["a:hp"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_HP, o.curHealth); }
            // {{a:hp-ratio}}, {{a:hp_ratio}}
            pdata["a:hp-ratio"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_HP_RATIO,
                Math.round(o.curHealth / data.maxHealth * 100)); }
            pdata["a:hp_ratio"] = pdata["a:hp-ratio"];

            var pname:String = WGUtils.GetNormalizedPlayerName(playerName);
            if (!data_provider.hasOwnProperty(pname))
                data_provider[pname] = { };
            var pdata = data_provider[pname];

            // vars
            var r:Number = Utils.toInt(stat.r, 0);
            var eff:Number = Utils.toInt(stat.e, 0);
            var b:Number = Utils.toInt(stat.b, 0);
            var w:Number = Utils.toInt(stat.w, 0);
            var tr:Number = Utils.toInt(stat.v.r, 0);
            var tb:Number = Utils.toInt(stat.v.b, 0);
            var tw:Number = Utils.toInt(stat.v.w, 0);
            var tbK:Number = Math.round(tb / 100) / 10;

            // {{avglvl}}
            var avglvl = Math.round(Utils.toFloat(stat.avglvl, 0));
            pdata["avglvl"] = avglvl < 1 ? "-" : avglvl == 10 ? "X" : avglvl;
            // {{xeff}}
            pdata["xeff"] = stat.xeff == null ? "--" : stat.xeff == 100 ? "XX" : (stat.xeff < 10 ? "0" : "") + stat.xeff;
            // {{xwn}}
            pdata["xwn"] = stat.xwn == null ? "--" : stat.xwn == 100 ? "XX" : (stat.xwn < 10 ? "0" : "") + stat.xwn;
            // {{eff}}, {{eff:4}}
            pdata["eff"] = eff <= 0 ? "----" : String(eff);
            pdata["eff:4"] = eff <= 0 ? "----" : Strings.padLeft(pdata["eff"], 4);
            // {{wn}}
            pdata["wn"] = stat.wn <= 0 ? "----" : Strings.padLeft(String(stat.wn), 4);
            // {{twr}}
            pdata["twr"] = stat.twr <= 0 ? "--%" : Strings.padLeft(String(stat.twr) + "%", 3);
            // {{e}}
            pdata["e"] = stat.te == null ? "-" : stat.te >= 10 ? "E" : String(stat.te);
            // {{teff}}
            pdata["teff"] = stat.teff == null ? "----" : Strings.padLeft(String(stat.teff), 4);
            //// {{teff2}}
            //pdata["teff2"] = stat.teff2 == null ? "----" : Strings.padLeft(String(stat.teff2), 4);

            // {{rating}}, {{rating:3}}
            pdata["rating"] = r <= 0 ? "--%" : String(r) + "%";
            pdata["rating:3"] = Strings.padLeft(pdata["rating"], 3);
            // {{battles}}
            pdata["battles"] = b <= 0 ? "---" : String(b);
            // {{wins}}
            pdata["wins"] = b <= 0 ? "---" : String(w);
            // {{kb}}, {{kb:3}}
            pdata["kb"] = b <= 0 ? "--k" : String(Math.round(b / 1000)) + "k";
            pdata["kb:3"] = Strings.padLeft(pdata["kb"], 3);

            // {{t-rating}}, {{t-rating:3}}
            pdata["t-rating"] = tr <= 0 ? "--%" : String(tr) + "%";
            pdata["t-rating:3"] = Strings.padLeft(pdata["t-rating"], 3);
            // {{t-battles}}, {{t-battles:4}}
            pdata["t-battles"] = tb <= 0 ? "----" : String(tb);
            pdata["t-battles:4"] = Strings.padLeft(pdata["t-battles"], 4);
            // {{t-wins}}
            pdata["t-wins"] = tb <= 0 ? "----" : String(tw);
            // {{t-kb}}, {{t-kb-0}}, {{t-kb:4}}
            pdata["t-kb-0"] = tb <= 0 ? "-.-k" : Strings.padLeft(Sprintf.format("%.1fk", tbK, 4));
            pdata["t-kb:4"] = tbK < 1 ? pdata["t-kb-0"].split("0.", 2).join(" .") : pdata["t-kb-0"]; // remove leading zero before dot
            pdata["t-kb"] = Strings.trim(pdata["t-kb:4"]);
            // {{t-hb}}, {{t-hb:3}}
            pdata["t-hb"] = tb <= 0 ? "--h" : String(Math.round(tb / 100)) + "h";
            pdata["t-hb:3"] = Strings.padLeft(pdata["t-hb"], 3);
            // {{tdb}}, {{tdb:4}}
            pdata["tdb"] = stat.tdb == null ? "----" : String(stat.tdb);
            pdata["tdb:4"] = Strings.padLeft(pdata["tdb"], 4);
            // {{tdv}}
            pdata["tdv"] = stat.tdv == null ? "-.-" : Sprintf.format("%.1f", stat.tdv);
            // {{tfb}}
            pdata["tfb"] = stat.tfb == null ? "-.-" : Sprintf.format("%.1f", stat.tfb);
            // {{tsb}}
            pdata["tsb"] = stat.tsb == null ? "-.-" : Sprintf.format("%.1f", stat.tsb);

            // Dynamic colors
            // {{c:xeff}}
            pdata["c:xeff"] = stat.xeff == null ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_X, stat.xeff, "#", o.darken); }
            // {{c:xwn}}
            pdata["c:xwn"] = stat.xwn == null ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_X, stat.xwn, "#", o.darken); }
            // {{c:eff}}
            pdata["c:eff"] = eff <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_EFF, eff, "#", o.darken); }
            // {{c:wn}}
            pdata["c:wn"] = !stat.wn ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_WN, stat.wn, "#", o.darken); }
            // {{c:e}}
            pdata["c:e"] = stat.te == null ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_E, stat.te, "#", o.darken); }
            // {{c:twr}}
            pdata["c:twr"] = !stat.twr ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_TWR, stat.twr, "#", o.darken); }
            // {{c:rating}}
            pdata["c:rating"] = r <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_RATING, r, "#", o.darken); }
            // {{c:kb}}
            pdata["c:kb"] = b <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_KB, b / 1000, "#", o.darken); }
            // {{c:t-rating}}, {{c:t_rating}}
            pdata["c:t-rating"] = tr <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_RATING, tr, "#", o.darken); }
            pdata["c:t_rating"] = pdata["c:t-rating"];
            // {{c:t-battles}}, {{c:t_battles}}
            pdata["c:t-battles"] = tb <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_TBATTLES, tb, "#", o.darken); }
            pdata["c:t_battles"] = pdata["c:t-battles"];
            // {{c:tdb}}
            pdata["c:tdb"] = stat.tdb <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_TDB, stat.tdb, "#", o.darken); }
            // {{c:tdv}}
            pdata["c:tdv"] = stat.tdv <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_TDV, stat.tdv, "#", o.darken); }
            // {{c:tfb}}
            pdata["c:tfb"] = stat.tfb <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_TFB, stat.tfb, "#", o.darken); }
            // {{c:tsb}}
            pdata["c:tsb"] = stat.tsb <= 0 ? ""
                : function(o) { return GraphicsUtil.GetDynamicColorValue(Defines.DYNAMIC_COLOR_TSB, stat.tsb, "#", o.darken); }

            // Alpha
            // {{a:xeff}}
            pdata["a:xeff"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_X, stat.xeff); }
            // {{a:xwn}}
            pdata["a:xwn"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_X, stat.xwn); }
            // {{a:eff}}
            pdata["a:eff"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_EFF, eff); }
            // {{a:wn}}
            pdata["a:wn"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_WN, stat.wn); }
            // {{a:e}}
            pdata["a:e"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_E, stat.te); }
            // {{a:twr}}
            pdata["a:twr"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_TWR, stat.twr); }
            // {{a:rating}}
            pdata["a:rating"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_RATING, r); }
            // {{a:kb}}
            pdata["a:kb"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_KB, b / 1000); }
            // {{a:t-rating}}
            pdata["a:t-rating"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_RATING, tr); }
            // {{a:t-battles}}
            pdata["a:t-battles"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_TBATTLES, tb); }
            // {{a:tdb}}
            pdata["a:tdb"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_TDB, stat.tdb); }
            // {{a:tdv}}
            pdata["a:tdv"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_TDV, stat.tdv); }
            // {{a:tfb}}
            pdata["a:tfb"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_TFB, stat.tfb); }
            // {{a:tsb}}
            pdata["a:tsb"] = function(o) { return GraphicsUtil.GetDynamicAlphaValue(Defines.DYNAMIC_ALPHA_TSB, stat.tsb); }
        }

        // PRIVATE

        private static function modXvmDevLabel(name:String):String
        {
            var label:String = WGUtils.GetPlayerName(name);
            switch (Config.gameRegion)
            {
                case "RU":
                    if (label == "M_r_A")
                        return "Флаттершай - лучшая пони!";
                    if (label == "XlebniDizele4ku")
                        return "как ник зделал поруски!!!";
                    if (label == "sirmax2" || label == "0x01" || label == "_SirMax_")
                        return "«сэр Макс» (XVM)";
                    break;

                case "CT":
                    if (label == "M_r_A_RU" || label == "M_r_A_EU")
                        return "Fluttershy is best pony!";
                    if (label == "sirmax2_RU" || label == "sirmax2_EU" || label == "sirmax_NA" || label == "0x01_RU")
                        return "«sir Max» (XVM)";
                    break;

                case "EU":
                    if (label == "M_r_A")
                        return "Fluttershy is best pony!";
                    if (label == "sirmax2" || label == "0x01" || label == "_SirMax_")
                        return "«sir Max» (XVM)";
                    break;

                case "US":
                    if (label == "sirmax" || label == "0x01" || label == "_SirMax_")
                        return "«sir Max» (XVM)";
                    break;
            }

            return name;
        }

        //   src: ally, squadman, enemy, unknown, player (allytk, enemytk - how to detect?)
        public static function damageFlagToDamageSource(damageFlag:Number):String
        {
            switch (damageFlag)
            {
                case Defines.FROM_ALLY:
                    return "ally";
                case Defines.FROM_ENEMY:
                    return "enemy";
                case Defines.FROM_PLAYER:
                    return "player";
                case Defines.FROM_SQUAD:
                    return "squadman";
                case Defines.FROM_UNKNOWN:
                default:
                    return "unknown";
            }
        }
    }
}
