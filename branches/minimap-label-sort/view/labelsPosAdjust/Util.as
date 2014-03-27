import wot.Minimap.MinimapProxy;
import com.xvm.Logger;
import wot.Minimap.model.externalProxy.IconsProxy;
import wot.Minimap.view.labelsPosAdjust.LabelOffsetUpdate;
import wot.Minimap.MinimapEntry;

class wot.Minimap.view.labelsPosAdjust.Util
{	
	public static function getApplicableEntry(icon:MovieClip):MinimapEntry
	{
		/** Not a player icon */
		if (!icon.player)
			return null;
			
		var entry:MinimapEntry = icon.xvm_worker;
		
		/**
		 * Seldom error workaround.
		 * Wreck sometimes is placed at map center.
		 */
		if (!entry.wrapper._x && !entry.wrapper._y)
			return null;
		
		/**
		 * No label - nothing to align.
		 * Example: capture or respawn point.
		 */
		if (entry.labelMc._x == undefined)
			return null;
			
		/** All checks are passed. This entry is valid for procedures. */
		return entry;
	}
	
	public static function isTheSameEntry(entry1:MinimapEntry, entry2:MinimapEntry):Boolean
	{
		return entry1.uid == entry2.uid;
	}
	
	public static function centersDistance(entry1:MinimapEntry, entry2:MinimapEntry):Number
	{
		var xCenter1:Number = Util.getXCenter(entry1);
		var yCenter1:Number = Util.getYCenter(entry1);
		var xCenter2:Number = Util.getXCenter(entry2);
		var yCenter2:Number = Util.getYCenter(entry2);
		var distance:Number = Math.pow(xCenter2 - xCenter1, 2) +
							  Math.pow(yCenter2 - yCenter1, 2);
		return Math.sqrt(distance);
	}
	
	/**
	 * Is label1 below label2?.
	 * Label position = entry position + label offset.
	 */
	public static function isBelow(entry1:MinimapEntry, entry2:MinimapEntry):Boolean {
		return getCurrentY(entry1) > getCurrentY(entry2);
	}
	public static function isOnTheRight(entry1:MinimapEntry, entry2:MinimapEntry):Boolean	{
		return getCurrentX(entry1) > getCurrentX(entry2);
	}
	
	
	private static function getXCenter(entry:MinimapEntry):Number {
		return getCurrentX(entry) + entry.labelMc._width;
	}
	private static function getYCenter(entry:MinimapEntry):Number {
		return getCurrentY(entry) + entry.labelMc._height;
	}
	
	
	private static function getCurrentX(entry:MinimapEntry):Number	{
		return entry.wrapper._x + entry.labelMc[LabelOffsetUpdate.X_OFFSET];
	}
	private static function getCurrentY(entry:MinimapEntry):Number	{
		return entry.wrapper._y + entry.labelMc[LabelOffsetUpdate.Y_OFFSET];
	}
}
