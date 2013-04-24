import wot.utils.GlobalEventDispatcher;
import wot.Minimap.MinimapEvent;
import wot.PlayersPanel.PlayersPanel;
import wot.Minimap.model.externalProxy.IconsProxy;
import wot.Minimap.model.externalProxy.PlayersPanelProxy;
import wot.utils.VehicleInfo;

/**
 * @author ilitvinov87@gmail.com
 */
class wot.PlayersPanel.SpotStatusModel
{
    public static var DEAD:Number = 0;
    public static var NEVER_SEEN:Number = 1;
    public static var LOST:Number = 2;
    public static var REVEALED:Number = 3;
        
    private var seen:Array;
    
    public function SpotStatusModel()
    {
        seen = [];
        GlobalEventDispatcher.addEventListener(MinimapEvent.ENEMY_REVEALED, this, onRevealed)
    }
    
    public function defineStatus(uid:Number, vehicleState:Number):Number
    {
        if (vehicleState == 2)
        {
            return DEAD;
        }
        
        if (isRevealedRightNow(uid))
        {
            return REVEALED;
        }

        return wasSeen(uid) ? LOST : NEVER_SEEN;
    }
    
    public function isArti(uid:Number):Boolean
    {
        var info:Object = PlayersPanelProxy.getPlayerInfo(uid); // "../maps/icons/vehicle/contour/ussr-SU-18.png"
        var info2:Object = VehicleInfo.getInfo2(info.icon);
        
        return info2.type == "SPG";
    }
    
    // -- Private
    
    private function isRevealedRightNow(subjUid):Boolean
    {
        var uids:Array = IconsProxy.getSyncedUids();
        for (var i in uids)
        {
            if (uids[i] == subjUid)
            {
                return true;
            }
        }
        
        return false;
    }
    
    private function onRevealed(mmevent:MinimapEvent)
    {
        /** Save a guy to revealed enemies list */
        var uid:Number = Number(mmevent.payload);
        seen.push(uid);
    }
    
    private function wasSeen(uid:Number):Boolean
    {
        for (var i in seen)
        {
            if (seen[i] == uid)
            {
                return true;
            }
        }
        
        return false;
    }
    
    private function get panel():PlayersPanel
    {
        return _root.rightPanel;
    }
}
