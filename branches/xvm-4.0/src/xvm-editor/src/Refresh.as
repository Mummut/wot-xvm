﻿import components.DefaultComponent;

import utils.Config;
import utils.DefaultConfig;
import utils.Utils;

protected function RefreshCurrentPage():void
{
    debug("RefreshCurrentPage()");
    try
    {
        var pg:Object = vsTabs.selectedChild;

        if (!Config.s_config)
            Config.s_config = DefaultConfig.config;

        var now: Date = new Date();

        //debug(JSON.stringify(Config.s_config));

        if (pg == pgCommon)
            RefreshCommonPage();
        else if (pg == pgBattleLoading)
            RefreshBattleLoadingPage();
        else if (pg == pgStatisticForm)
            RefreshStatisticFormPage();
        else if (pg == pgPlayersPanel)
            RefreshPlayersPanelPage();
        else if (pg == pgColors)
            RefreshColorsPage();
        else if (pg == pgTransparency)
            RefreshTransparencyPage();
        else if (pg == pgMisc)
            RefreshMiscPage();
        else if (pg == pgVehicleNames)
            RefreshVehicleNamesPage();
        else if (pg == pgMarkers)
            RefreshMarkersPage();

        debug("  " + utils.Utils.elapsedMSec(now, new Date()) + " msec");

        if (preview)
            preview.update();
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshCurrentPage(): " + ex.toString());
    }
}

private function RefreshCommonPage():void
{
    debug("RefreshCommonPage()");
    try
    {
        var section:*;

        section = Config.s_config.definition;
        this.p_definition.v_author.value = section.author;
        this.p_definition.v_description.value = section.description;
        this.p_definition.v_url.value = section.url;
        this.p_definition.v_date.value = section.date;
        this.p_definition.v_gameVersion.value = section.gameVersion;
        this.p_definition.v_modMinVersion.value = section.modMinVersion;

        section = Config.s_config.battle;
        this.p_battle.v_mirroredVehicleIcons.value = section.mirroredVehicleIcons;
        this.p_battle.v_showPostmortemTips.value = section.showPostmortemTips;
        this.p_battle.v_removePanelsModeSwitcher.value = section.removePanelsModeSwitcher;
        this.p_battle.v_highlightVehicleIcon.value = section.highlightVehicleIcon;
        this.p_battle.v_hideXVMVersion.value = section.hideXVMVersion;
        this.p_battle.v_useStandardMarkers.value = section.useStandardMarkers;
        this.p_battle.v_clockFormat.value = section.clockFormat;
        this.p_battle.v_clanIconsFolder.value = section.clanIconsFolder;

        section = Config.s_config.rating;
        this.p_rating.v_showPlayersStatistics.value = section.showPlayersStatistics;
        this.p_rating.v_loadEnemyStatsInFogOfWar.value = section.loadEnemyStatsInFogOfWar;
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshCommonPage(): " + ex.toString());
    }
}

private function RefreshBattleLoadingPage():void
{
    debug("RefreshBattleLoadingPage()");
    try
    {
        var section:*;

        section = Config.s_config.battleLoading;
        this.p_battleLoading.v_clockFormat.value = section.clockFormat;
        this.p_battleLoading.v_showChances.value = section.showChances;
        this.p_battleLoading.v_showChancesExp.value = section.showChancesExp;
        this.p_battleLoading.v_removeSquadIcon.value = section.removeSquadIcon;
        this.p_battleLoading_text.v_formatLeft.value = section.formatLeft;
        this.p_battleLoading_text.v_formatRight.value = section.formatRight;

        section = Config.s_config.battleLoading.clanIcon;
        this.p_battleLoading_icons.v_show.value = section.show;
        this.p_battleLoading_icons.v_x.value = section.x;
        this.p_battleLoading_icons.v_y.value = section.y;
        this.p_battleLoading_icons.v_xr.value = section.xr;
        this.p_battleLoading_icons.v_yr.value = section.yr;
        this.p_battleLoading_icons.v_w.value = section.w;
        this.p_battleLoading_icons.v_h.value = section.h;
        this.p_battleLoading_icons.v_alpha.value = section.alpha;
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshBattleLoadingPage(): " + ex.toString());
    }
}

private function RefreshStatisticFormPage():void
{
    debug("RefreshStatisticFormPage()");
    try
    {
        var section:*;

        section = Config.s_config.statisticForm;
        this.p_statisticForm.v_showChances.value = section.showChances;
        this.p_statisticForm.v_showChancesExp.value = section.showChancesExp;
        this.p_statisticForm.v_removeSquadIcon.value = section.removeSquadIcon;
        this.p_statisticForm_text.v_formatLeft.value = section.formatLeft;
        this.p_statisticForm_text.v_formatRight.value = section.formatRight;

        section = Config.s_config.statisticForm.clanIcon;
        this.p_statisticForm_icons.v_show.value = section.show;
        this.p_statisticForm_icons.v_x.value = section.x;
        this.p_statisticForm_icons.v_y.value = section.y;
        this.p_statisticForm_icons.v_xr.value = section.xr;
        this.p_statisticForm_icons.v_yr.value = section.yr;
        this.p_statisticForm_icons.v_w.value = section.w;
        this.p_statisticForm_icons.v_h.value = section.h;
        this.p_statisticForm_icons.v_alpha.value = section.alpha;
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshStatisticFormPage(): " + ex.toString());
    }
}

private function RefreshPlayersPanelPage():void
{
    debug("RefreshPlayersPanelPage()");
    try
    {
        var section:*;

        section = Config.s_config.playersPanel;
        this.p_playersPanel.v_alpha.value = section.alpha;
        this.p_playersPanel.v_iconAlpha.value = section.iconAlpha;
        this.p_playersPanel.v_removeSquadIcon.value = section.removeSquadIcon;

        section = Config.s_config.playersPanel.clanIcon;
        this.p_playersPanel_icons.v_show.value = section.show;
        this.p_playersPanel_icons.v_x.value = section.x;
        this.p_playersPanel_icons.v_y.value = section.y;
        this.p_playersPanel_icons.v_xr.value = section.xr;
        this.p_playersPanel_icons.v_yr.value = section.yr;
        this.p_playersPanel_icons.v_w.value = section.w;
        this.p_playersPanel_icons.v_h.value = section.h;
        this.p_playersPanel_icons.v_alpha.value = section.alpha;

        section = Config.s_config.playersPanel.medium;
        this.p_playersPanel_medium.v_width.value = section.width;
        this.p_playersPanel_medium.v_formatLeft.value = section.formatLeft;
        this.p_playersPanel_medium.v_formatRight.value = section.formatRight;

        section = Config.s_config.playersPanel.medium2;
        this.p_playersPanel_medium2.v_width.value = section.width;
        this.p_playersPanel_medium2.v_formatLeft.value = section.formatLeft;
        this.p_playersPanel_medium2.v_formatRight.value = section.formatRight;

        section = Config.s_config.playersPanel.large;
        this.p_playersPanel_large.v_width.value = section.width;
        this.p_playersPanel_large.v_nickFormatLeft.value = section.nickFormatLeft;
        this.p_playersPanel_large.v_nickFormatRight.value = section.nickFormatRight;
        this.p_playersPanel_large.v_vehicleFormatLeft.value = section.vehicleFormatLeft;
        this.p_playersPanel_large.v_vehicleFormatRight.value = section.vehicleFormatRight;
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshPlayersPanelPage(): " + ex.toString());
    }
}

private function RefreshColorsPage():void
{
    debug("RefreshColorsPage()");
    try
    {
        if (accColors.selectedChild == nc_systemColors && p_systemColors != null)
        {
            var section:Object = Config.s_config.colors.system;
            if (p_systemColors.v_ally_alive_normal != null)
                p_systemColors.v_ally_alive_normal.value = section.ally_alive_normal;
            if (p_systemColors.v_ally_alive_blind != null)
                p_systemColors.v_ally_alive_blind.value = section.ally_alive_blind;
            if (p_systemColors.v_ally_dead_normal != null)
                p_systemColors.v_ally_dead_normal.value = section.ally_dead_normal;
            if (p_systemColors.v_ally_dead_blind != null)
                p_systemColors.v_ally_dead_blind.value = section.ally_dead_blind;
            if (p_systemColors.v_ally_blowedup_normal != null)
                p_systemColors.v_ally_blowedup_normal.value = section.ally_blowedup_normal;
            if (p_systemColors.v_ally_blowedup_blind != null)
                p_systemColors.v_ally_blowedup_blind.value = section.ally_blowedup_blind;
            if (p_systemColors.v_squadman_alive_normal != null)
                p_systemColors.v_squadman_alive_normal.value = section.squadman_alive_normal;
            if (p_systemColors.v_squadman_alive_blind != null)
                p_systemColors.v_squadman_alive_blind.value = section.squadman_alive_blind;
            if (p_systemColors.v_squadman_dead_normal != null)
                p_systemColors.v_squadman_dead_normal.value = section.squadman_dead_normal;
            if (p_systemColors.v_squadman_dead_blind != null)
                p_systemColors.v_squadman_dead_blind.value = section.squadman_dead_blind;
            if (p_systemColors.v_squadman_blowedup_normal != null)
                p_systemColors.v_squadman_blowedup_normal.value = section.squadman_blowedup_normal;
            if (p_systemColors.v_squadman_blowedup_blind != null)
                p_systemColors.v_squadman_blowedup_blind.value = section.squadman_blowedup_blind;
            if (p_systemColors.v_teamKiller_alive_normal != null)
                p_systemColors.v_teamKiller_alive_normal.value = section.teamKiller_alive_normal;
            if (p_systemColors.v_teamKiller_alive_blind != null)
                p_systemColors.v_teamKiller_alive_blind.value = section.teamKiller_alive_blind;
            if (p_systemColors.v_teamKiller_dead_normal != null)
                p_systemColors.v_teamKiller_dead_normal.value = section.teamKiller_dead_normal;
            if (p_systemColors.v_teamKiller_dead_blind != null)
                p_systemColors.v_teamKiller_dead_blind.value = section.teamKiller_dead_blind;
            if (p_systemColors.v_teamKiller_blowedup_normal != null)
                p_systemColors.v_teamKiller_blowedup_normal.value = section.teamKiller_blowedup_normal;
            if (p_systemColors.v_teamKiller_blowedup_blind != null)
                p_systemColors.v_teamKiller_blowedup_blind.value = section.teamKiller_blowedup_blind;
            if (p_systemColors.v_enemy_alive_normal != null)
                p_systemColors.v_enemy_alive_normal.value = section.enemy_alive_normal;
            if (p_systemColors.v_enemy_alive_blind != null)
                p_systemColors.v_enemy_alive_blind.value = section.enemy_alive_blind;
            if (p_systemColors.v_enemy_dead_normal != null)
                p_systemColors.v_enemy_dead_normal.value = section.enemy_dead_normal;
            if (p_systemColors.v_enemy_dead_blind != null)
                p_systemColors.v_enemy_dead_blind.value = section.enemy_dead_blind;
            if (p_systemColors.v_enemy_blowedup_normal != null)
                p_systemColors.v_enemy_blowedup_normal.value = section.enemy_blowedup_normal;
            if (p_systemColors.v_enemy_blowedup_blind != null)
                p_systemColors.v_enemy_blowedup_blind.value = section.enemy_blowedup_blind;
        }
        if (accColors.selectedChild == nc_vtypeColors && p_vtypeColors != null)
        {
            var section2:Object = Config.s_config.colors.vtype;
            if (p_vtypeColors.v_LT != null)
                p_vtypeColors.v_LT.value = section2.LT;
            if (p_vtypeColors.v_MT != null)
                p_vtypeColors.v_MT.value = section2.MT;
            if (p_vtypeColors.v_HT != null)
                p_vtypeColors.v_HT.value = section2.HT;
            if (p_vtypeColors.v_SPG != null)
                p_vtypeColors.v_SPG.value = section2.SPG;
            if (p_vtypeColors.v_TD != null)
                p_vtypeColors.v_TD.value = section2.TD;
            if (p_vtypeColors.v_premium != null)
                p_vtypeColors.v_premium.value = section2.premium;
            if (p_vtypeColors.v_usePremiumColor != null)
                p_vtypeColors.v_usePremiumColor.value = section2.usePremiumColor;
        }
        else if (accColors.selectedChild == nc_colors_hp && p_colors_hp != null)
            p_colors_hp.RefreshSource();
        else if (accColors.selectedChild == nc_colors_hp_ratio && p_colors_hp_ratio != null)
            p_colors_hp_ratio.RefreshSource();
        else if (accColors.selectedChild == nc_colors_eff && p_colors_eff != null)
            p_colors_eff.RefreshSource();
        else if (accColors.selectedChild == nc_colors_rating && p_colors_rating != null)
            p_colors_rating.RefreshSource();
        else if (accColors.selectedChild == nc_colors_kb && p_colors_kb != null)
            p_colors_kb.RefreshSource();
        else if (accColors.selectedChild == nc_colors_tbattles && p_colors_tbattles != null)
            p_colors_tbattles.RefreshSource();
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshColorsPage(): " + ex.toString());
    }
}

private function RefreshTransparencyPage():void
{
    debug("RefreshTransparencyPage()");
    try
    {
        if (accTransparency.selectedChild == nc_alpha_hp && p_alpha_hp != null)
            p_alpha_hp.RefreshSource();
        else if (accTransparency.selectedChild == nc_alpha_hp_ratio && p_alpha_hp_ratio != null)
            p_alpha_hp_ratio.RefreshSource();
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshTransparencyPage(): " + ex.toString());
    }
}

private function RefreshMiscPage():void
{
    debug("RefreshMiscPage()");
    try
    {
        var section:*;

        section = Config.s_config.turretMarkers;
        this.p_turret.v_highVulnerability.value = section.highVulnerability;
        this.p_turret.v_lowVulnerability.value = section.lowVulnerability;

        section = Config.s_config.iconset;
        this.p_iconSet.v_battleLoading.value = section.battleLoading;
        this.p_iconSet.v_statisticForm.value = section.statisticForm;
        this.p_iconSet.v_playersPanel.value = section.playersPanel;
        this.p_iconSet.v_vehicleMarker.value = section.vehicleMarker;
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshMiscPage(): " + ex.toString());
    }
}

private var needRefreshVehicleNamesPage:Boolean = true;
private function RefreshVehicleNamesPage():void
{
    debug("RefreshVehicleNamesPage()");
    try
    {
        if (needRefreshVehicleNamesPage)
        {
            needRefreshVehicleNamesPage = false;
            p_vehicle_names.RefreshSource();
        }
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshVehicleNamesPage(): " + ex.toString());
    }
}

// Markers

public const ElementControls:Object = {
    vehicleIcon: [ "m_vehicleIcon" ],
    healthBar: [ "m_healthBar" ],
    damageText: [ "m_damageText", "m_damageText_font", "m_damageText_shadow" ],
    contourIcon: [ "m_contourIcon" ],
    clanIcon: [ "m_clanIcon" ],
    levelIcon: [ "m_levelIcon" ],
    actionMarker: [ "m_actionMarker" ],

    m_vehicleIcon: [ "v_visible", "v_showSpeaker", "v_x", "v_y", "v_alpha", "v_maxScale", "v_scaleX", "v_scaleY" ],
    m_healthBar: [ "v_visible", "v_x", "v_y", "v_alpha", "v_color", "v_lcolor", "v_width", "v_height", "v_border_size",
        "v_border_color", "v_border_alpha", "v_fill_alpha", "v_damage_color", "v_damage_alpha", "v_damage_fade" ],
    m_damageText: [ "v_visible", "v_x", "v_y", "v_alpha", "v_color", "v_maxRange", "v_damageMessage", "v_blowupMessage" ],
    m_damageText_font: [ "v_name", "v_size", "v_align", "v_bold", "v_italic" ],
    m_damageText_shadow: [ "v_size", "v_strength", "v_angle", "v_distance", "v_color", "v_alpha" ],
    m_contourIcon: ["v_visible", "v_x", "v_y", "v_alpha", "v_color", "v_amount" ],
    m_clanIcon: ["v_visible", "v_x", "v_y", "v_w", "v_h", "v_alpha" ],
    m_levelIcon: ["v_visible", "v_x", "v_y", "v_alpha" ],
    m_actionMarker: ["v_visible", "v_x", "v_y", "v_alpha" ]
};

private function RefreshMarkersPage():void
{
    debug("RefreshMarkersPage()");
    try
    {
        var activeElement:* = getActiveMarkerElement();

        if (!activeElement)
            return;

        if (activeElement == textFields)
        {
            RefreshTextFields();
            return;
        }

        var activeMarkerStates:Array = getActiveMarkerStates();

        for each (var mname:String in ElementControls[activeElement.id])
        {
            for each (var mname2:String in ElementControls[mname])
            {
                if (this[mname] == null)
                    continue;
                var control:DefaultComponent = this[mname][mname2] as DefaultComponent;

                //debug(mname + "." + mname2);
                var valueSet: Boolean = false;
                var value:*;
                var valueOk: Boolean = true;
                for each (var state:String in activeMarkerStates)
                {
                    var conf:String = "markers." + state + "." + activeElement.id + "." + control.config;
                    //debug("  " + conf + "=" + Config.GetValue(conf));
                    //values.push(Config.GetValue(conf));
                    if (!valueSet)
                    {
                        valueSet = true;
                        value = Config.GetValue(conf);
                    }
                    else
                    {
                        if (value != Config.GetValue(conf))
                        {
                            valueOk = false;
                            break;
                        }
                    }
                }

                control.conflict = !valueOk;
                control.value = value;
            }
        }
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshMarkersPage(): " + ex.toString());
    }
}

private function RefreshTextFields():void
{
    debug("RefreshTextFields()");
    try
    {
        if (m_textFieldList != null)
            m_textFieldList.RefreshSource(getActiveMarkerStates());
    }
    catch (ex:Error)
    {
        debug("ERROR: RefreshTextFields(): " + ex.toString());
    }
}