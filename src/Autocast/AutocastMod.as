package Autocast 
{
	import Bezel.Bezel;
	import Bezel.BezelMod;
	import Bezel.Logger;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Hellrage
	 */
	public class AutocastMod extends MovieClip implements BezelMod
	{
		
		public function get VERSION():String { return "1.5"; }
		public function get BEZEL_VERSION():String { return "2.0.1"; }
		public function get MOD_NAME():String { return "Autocast"; }
		
		private var autoCast:Object;
		
		internal static var bezel:Bezel;
		internal static var logger:Logger;
		internal static var instance:AutocastMod;

		public static const GCFW_VERSION:String = "1.2.1a";
		public static const GCCS_VERSION:String = "1.0.6";
		
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
			if (bezel.mainLoader.gameClassFullyQualifiedName == "com.giab.games.gcfw.Main")
			{
				autoCast = new GCFWAutocast();
			}
			else if (bezel.mainLoader.gameClassFullyQualifiedName == "com.giab.games.gccs.steam.Main")
			{
				autoCast = new GCCSAutocast();
			}
		}
		
		public function unload():void
		{
			if (autoCast != null)
			{
				autoCast.unload();
				autoCast = null;
			}
		}
		
		public function prettyVersion(): String
		{
			return 'v' + VERSION + ' for ' + GCFW_VERSION;
		}
	}

}