package 
{
    import net.wg.gui.components.controls.*;
    
    public dynamic class ArtefactsListUI extends net.wg.gui.components.controls.ScrollingListEx
    {
        public function ArtefactsListUI()
        {
            super();
            addFrameScript(0, this.frame1, 9, this.frame10, 19, this.frame20, 29, this.frame30);
            return;
        }

        internal function frame1():*
        {
            return;
        }

        internal function frame10():*
        {
            stop();
            return;
        }

        internal function frame20():*
        {
            stop();
            return;
        }

        internal function frame30():*
        {
            stop();
            return;
        }
    }
}