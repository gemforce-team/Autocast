package Autocast 
{
	import Bezel.Bezel;
	import Bezel.BezelMod;
	import Bezel.GCFW.GCFWBezel;
	import Bezel.Logger;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Hellrage
	 */
	public class AutocastMod extends MovieClip implements BezelMod
	{
		
		public function get VERSION():String { return "1.3"; }
		public function get BEZEL_VERSION():String { return "1.0.0"; }
		public function get MOD_NAME():String { return "Autocast"; }
		
		private var manaMason:Object;
		
		internal static var bezel:Bezel;
		internal static var logger:Logger;
		internal static var instance:AutocastMod;

		public static const GCFW_VERSION:String = "1.2.1a";
		
		public function AutocastMod() 
		{
			super();
			instance = this;
		}
		
		// This method binds the class to the game's objects
		public function bind(modLoader:Bezel, gameObjects:Object):void
		{
			bezel = modLoader;
			logger = bezel.getLogger("Autocast");
			if (bezel.mainLoader is GCFWBezel)
			{
				manaMason = new GCFWAutocast();
			}
		}
		
		public function unload():void
		{
			if (manaMason != null)
			{
				manaMason.unload();
				manaMason = null;
			}
		}
		
		public function prettyVersion(): String
		{
			return 'v' + VERSION + ' for ' + GCFW_VERSION;
		}
	}

}