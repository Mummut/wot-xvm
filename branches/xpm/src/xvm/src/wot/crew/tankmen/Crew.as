﻿/**
 * @author LEMAXHO
 */
import com.xvm.Config;
import com.xvm.GlobalEventDispatcher;
import com.xvm.Utils;
import com.xvm.Components.WGComponents;
import wot.crew.CrewLoader;

class wot.crew.tankmen.Crew
{
    /////////////////////////////////////////////////////////////////
    // wrapped methods

    private var wrapper:net.wargaming.tankmen.Crew;
    private var base:net.wargaming.tankmen.Crew;

    public function Crew(wrapper:net.wargaming.tankmen.Crew, base:net.wargaming.tankmen.Crew)
    {
        this.wrapper = wrapper;
        this.base = base;
        Utils.Timeout(this, CrewCtor, 1);
    }

    function setTankmen()
    {
        return this.setTankmenImpl.apply(this, arguments);
    }

    // wrapped methods
    /////////////////////////////////////////////////////////////////

    private function CrewCtor()
    {
        Utils.TraceXvmModule("Crew");

        GlobalEventDispatcher.addEventListener(Config.E_CONFIG_LOADED, this, onConfigLoaded);
        Config.LoadConfig();
    }

    private function onConfigLoaded()
    {
        GlobalEventDispatcher.removeEventListener(Config.E_CONFIG_LOADED, this, onConfigLoaded);

        if (Config.s_config.hangar.hideTutorial == true)
            _root.header.tutorialDispatcher._visible = false;

        // FIXIT: dirty hack, find the best place to initialize carousel without timer
        var timer = _global.setInterval(function() {
            // save carousel tanks in _global to be available from the Achievements dialog.
            var carousel:net.wargaming.Carousel = WGComponents.carousel;
            if (carousel)
                _global._xvm_carousel_dataProvider = carousel.dataProvider;
        }, 1000);
    }

    function setTankmenImpl(data)
    {
        base.setTankmen(data);
        //com.xvm.Logger.addObject(wrapper.list, "list", 2);
        CrewLoader.s_defaultCrew = wrapper.list._dataProvider; // save the crewlist
    }

}
