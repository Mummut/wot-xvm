﻿import com.xvm.Cache;
import com.xvm.Config;
import com.xvm.GlobalEventDispatcher;
import com.xvm.Logger;
import com.xvm.Utils;
import wot.Helpers.TeamRendererHelper;
import wot.Helpers.UserDataLoaderHelper;

class wot.TeamRenderer.PlayerItemRenderer extends net.wargaming.messenger.controls.PlayerItemRenderer
{
    private var configured:Boolean;
    private var m_name:String;
    private var m_effField:TextField;

    function PlayerItemRenderer()
    {
        super();

        Utils.TraceXvmModule("TeamRenderer");

        configured = false;
        m_name = null;
        m_effField = null;

        GlobalEventDispatcher.addEventListener("config_loaded", this, onConfigLoaded);
        Config.LoadConfig("PlayerItemRenderer.as");
    }

    private function onConfigLoaded()
    {
        GlobalEventDispatcher.removeEventListener("config_loaded", this, onConfigLoaded);
        configXVM();
    }

    // override
    function configUI()
    {
        super.configUI();
        configured = true;
        configXVM();
    }

    private function configXVM()
    {
        if (!configured || !Config.s_loaded || Config.s_config.rating.showPlayersStatistics != true)
            return;
        if (Config.s_config.rating.enableCompanyStatistics != true)
            return;

        if (m_effField == null)
        {
            m_effField = Utils.duplicateTextField(this, "eff", numberField, 0, "left");
            m_effField._x = width - 20;
        }
        m_effField.htmlText = "";

        afterSetDataXVM();
    }

    // override
    function afterSetData()
    {
        super.afterSetData();
        afterSetDataXVM();
    }

    private function afterSetDataXVM()
    {
        if (!configured || !Config.s_loaded || Config.s_config.rating.showPlayersStatistics != true)
            return;
        if (Config.s_config.rating.enableCompanyStatistics != true)
            return;

        if (!data || !data.label)
        {
            m_name = null;
            m_effField.htmlText = "";
            return;
        }
            
        m_name = Utils.GetPlayerName(data.label);
        if (Cache.Exist("INFO@" + m_name))
            setXVMStat();
        else
        {
            m_effField.htmlText = "";
            GlobalEventDispatcher.addEventListener("userdata_cached", this, setXVMStat);
            UserDataLoaderHelper.LoadUserData(m_name, false);
        }
    }

    private function setXVMStat()
    {
        var key = "INFO@" + m_name;
        if (!Cache.Exist(key))
            return;
        GlobalEventDispatcher.removeEventListener("userdata_cached", this, setXVMStat);
        TeamRendererHelper.setXVMStat(key, m_effField);
    }
}