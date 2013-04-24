import com.xvm.Utils;
import wot.Minimap.model.externalProxy.MapConfig;
import wot.Minimap.staticUtils.LabelAppend;
import wot.Minimap.dataTypes.Player;

/**
 * MinimapEntry represent individual object on map.
 * One tank icon, base capture point, starting point or player himself.
 *
 * MinimapEntry object at Minimap is called icon.
 *
 * Extended behaviour:
 * ) Appending extra information about unit like level, type, nick etc.
 *   This aspect is handled by Minimap class also.
 * ) Remain disappeared icons to indicate last enemy position.
 *   Only this class handles this aspect.
 *
 * @author ilitvinov87@gmail.com
 */

class wot.Minimap.MinimapEntry
{
    /////////////////////////////////////////////////////////////////
    // wrapped methods

    public var wrapper:net.wargaming.ingame.MinimapEntry;
    private var base:net.wargaming.ingame.MinimapEntry;

    public function MinimapEntry(wrapper:net.wargaming.ingame.MinimapEntry, base:net.wargaming.ingame.MinimapEntry)
    {
        this.wrapper = wrapper;
        this.base = base;
        wrapper["_xvm_worker"] = this;

        Utils.TraceXvmModule("MM");
    }

    function lightPlayer()
    {
        return this.lightPlayerImpl.apply(this, arguments);
    }

    // wrapped methods
    /////////////////////////////////////////////////////////////////

    /** Entry type: enemy, ally, squadman, empty possible */
    public static var MINIMAP_ENTRY_NAME_ENEMY:String = "enemy";
    public static var MINIMAP_ENTRY_NAME_ALLY:String = "ally";
    public static var MINIMAP_ENTRY_NAME_SQUAD:String = "squadman";
    public static var MINIMAP_ENTRY_NAME_SELF:String = ""; /** Type of player himself and ? */
    public static var MINIMAP_ENTRY_NAME_LOST:String = "lostenemy"; /** New type for last enemy position markers */
    public static var MINIMAP_ENTRY_VEH_CLASS_LIGHT:String = "lightTank";
    public static var MINIMAP_ENTRY_VEH_CLASS_MEDIUM:String = "mediumTank";
    public static var MINIMAP_ENTRY_VEH_CLASS_HEAVY:String = "heavyTank";
    public static var MINIMAP_ENTRY_VEH_CLASS_TD:String = "AT-SPG";
    public static var MINIMAP_ENTRY_VEH_CLASS_SPG:String = "SPG";
    public static var MINIMAP_ENTRY_VEH_CLASS_SUPER:String = "superheavyTank";

    /**
     * Subject of PlayersPanel <-> Minimap syncronization.
     * Syncronized during light delegate event.
     */
    public var uid:Number;

    public var player:Player;

    /** Used only for camera entry to define if entry is processed with Lines class */
    public var cameraExtendedToken:Boolean;

    public var label:TextField;

    /**
     * All attachments container: TextFiels(Labels), Shapes.
     */
    public function get attachments():MovieClip
    {
        if (!wrapper["_xvm_attachments"])
            wrapper.createEmptyMovieClip("_xvm_attachments", wrapper.getNextHighestDepth());
        return wrapper["_xvm_attachments"];
    }

    /**
     * Minimap resize procedures break attachments scale.
     * Workaround.
     * Reverts parent entry scaling.
     * For example: icon scaling of 62% produces attachment scaling of 159
     * so resulting attachment size becomes as if both icons and attachments scale were 100%.
     * This makes attachments size virtually independent of icon scale.
     */
    public function rescaleAttachments():Void
    {
        attachments._xscale = attachments._yscale = (1 / (wrapper._xscale / 100)) * 100;
    }

    function lightPlayerImpl(visibility)
    {
        /** Behavior is altered temporarily so original icon highlighting works */
        if (syncProcedureInProgress)
        {
            initExtendedBehaviour();
        }
        else
        {
            base.lightPlayer(visibility);
        }
    }

    // -- Private

    private function initExtendedBehaviour():Void
    {
        uid = _root.minimap.sync.getTestUid();

        if (MapConfig.revealedEnabled)
        {
            /** Attach revealed icon info */
            label = LabelAppend.append(attachments, uid, wrapper.entryName, wrapper.vehicleClass);
        }

        rescaleAttachments();
    }

    private function get syncProcedureInProgress():Boolean
    {
        return _root.minimap.sync.syncProcedureInProgress;
    }
}
