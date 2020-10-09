package Autocast 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.display.MovieClip;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.globalization.LocaleID;
	import flash.utils.*;
	
	public class Autocast extends MovieClip
	{
		public const VERSION:String = "1.1";
		public const GAME_VERSION:String = "1.1.0a";
		public const BEZEL_VERSION:String = "0.2.1";
		public const MOD_NAME:String = "Autocast";
		
		internal var gameObjects:Object;
		
		// Game object shortcuts
		internal var core:Object;/*IngameCore*/
		internal var cnt:Object;/*CntIngame*/
		internal var GV:Object;/*GV*/
		internal var SB:Object;/*SB*/
		internal var prefs:Object;/*Prefs*/
		
		// Mod loader object
		public static var bezel:Object;
		internal static var logger:Object;
		internal static var storage:File;
		
		private var casters:Object;
		public var markerSpellType:int;
		private var frameCounter:int;
		
		private static var spellRangeCircleSizes:Array;
		
		private static var iconBitmaps:Array;
		
		private var spellImages:Array;
		
		private static var Tower:Class;
		private static var Lantern:Class;
		private static var Amplifier:Class;
		private static var Trap:Class;
		
		public function Autocast() 
		{
			super();
		}
		
		public function bind(modLoader:Object, gameObjects:Object): Autocast
		{
			bezel = modLoader;
			logger = bezel.getLogger("Autocast");
			this.gameObjects = gameObjects;
			this.core = gameObjects.GV.ingameCore;
			this.cnt = gameObjects.GV.main.cntScreens.cntIngame;
			this.SB = gameObjects.SB;
			this.GV = gameObjects.GV;
			this.prefs = gameObjects.prefs;
			storage = File.applicationStorageDirectory.resolvePath("Autocast");
			
			prepareFolders();
			
			addEventListeners();
			this.casters = new Object();
			this.markerSpellType = -1;
			this.frameCounter = 0;
			this.spellImages = new Array();
			this.spellImages[0] = new (getDefinitionByName(getQualifiedClassName(this.cnt.mcRangeFreeze)) as Class)();
			this.spellImages[0].x = 50;
			this.spellImages[0].y = 8;
			this.spellImages[0].mcMask.width = 1680;
			this.spellImages[0].mcMask.height = 1064;
			this.spellImages[0].circle.visible = true;
			this.spellImages[0].visible = false;
			this.spellImages[1] = new (getDefinitionByName(getQualifiedClassName(this.cnt.mcRangeWhiteout)) as Class)();
			this.spellImages[1].x = 50;
			this.spellImages[1].y = 8;
			this.spellImages[1].mcMask.width = 1680;
			this.spellImages[1].mcMask.height = 1064;
			this.spellImages[1].circle.visible = true;
			this.spellImages[1].visible = false;
			this.spellImages[2] = new (getDefinitionByName(getQualifiedClassName(this.cnt.mcRangeIceShards)) as Class)();
			this.spellImages[2].x = 50;
			this.spellImages[2].y = 8;
			this.spellImages[2].mcMask.width = 1680;
			this.spellImages[2].mcMask.height = 1064;
			this.spellImages[2].circle.visible = true;
			this.spellImages[2].visible = false;
			spellRangeCircleSizes = new Array(this.core.spFreezeRadius, this.core.spWhiteoutRadius, this.core.spIsRadius);
			
			iconBitmaps = new Array();
			iconBitmaps[0] = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBolt, PixelSnapping.ALWAYS, true);
			iconBitmaps[0].visible = true;
			iconBitmaps[1] = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBeam, PixelSnapping.ALWAYS, true);
			iconBitmaps[1].visible = true;
			iconBitmaps[2] = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBarrage, PixelSnapping.ALWAYS, true);
			iconBitmaps[2].visible = true;
			
			this.spellImages[3] = new MovieClip();
			this.spellImages[3].addChild(iconBitmaps[0]);
			this.spellImages[3].visible = false;
			this.spellImages[4] = new MovieClip();
			this.spellImages[4].addChild(iconBitmaps[1]);
			this.spellImages[4].visible = false;
			this.spellImages[5] = new MovieClip();
			this.spellImages[5].addChild(iconBitmaps[2]);
			this.spellImages[5].visible = false;
			
			
			Tower = getDefinitionByName("com.giab.games.gcfw.entity.Tower") as Class;
			Lantern = getDefinitionByName("com.giab.games.gcfw.entity.Lantern") as Class;
			Amplifier = getDefinitionByName("com.giab.games.gcfw.entity.Amplifier") as Class;
			Trap = getDefinitionByName("com.giab.games.gcfw.entity.Trap") as Class;
			
			logger.log("bind", "Autocast initialized!");
			
			return this;
		}
		
		public function prettyVersion(): String
		{
			return 'v' + VERSION + ' for ' + GAME_VERSION;
		}
		
		/*private function checkForUpdates(): void
		{
			if(!this.configuration["Check for updates"])
				return;
			
			logger.log("CheckForUpdates", "Mod version: " + prettyVersion());
			logger.log("CheckForUpdates", "Checking for updates...");
			var repoAddress:String = "https://api.github.com/repos/gemforce-team/gemsmith/releases/latest";
			var request:URLRequest = new URLRequest(repoAddress);
			
			var loader:URLLoader = new URLLoader();
			var localThis:Gemsmith = this;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event): void {
				var latestTag:Object = JSON.parse(loader.data).tag_name;
				var latestVersion:String = latestTag.replace(/[v]/gim, ' ').split('-')[0];
				localThis.updateAvailable = (latestVersion != VERSION);
				logger.log("CheckForUpdates", localThis.updateAvailable ? "Update available! " + latestTag : "Using the latest version: " + latestTag);
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent): void {
				logger.log("CheckForUpdates", "Caught an error when checking for updates!");
			});
			
			loader.load(request);
		}*/
		
		private function prepareFolders(): void
		{
			if (!storage.isDirectory)
			{
				storage.createDirectory();
			}
		}
		
		private function addEventListeners(): void
		{
			bezel.addEventListener("ingameClickOnScene", eh_ingameClickOnScene);
			bezel.addEventListener("ingameKeyDown", eh_interceptKeyboardEvent);
			gameObjects.GV.main.addEventListener("enterFrame", eh_ingamePreRenderInfoPanel);
			bezel.addEventListener("ingameRightClickOnScene", eh_ingameRightClickOnScene);
		}
		
		public function unload(): void
		{
			removeEventListeners();
		}
		
		private function removeEventListeners(): void
		{
			bezel.removeEventListener("ingameClickOnScene", eh_ingameClickOnScene);
			bezel.removeEventListener("ingameKeyDown", eh_interceptKeyboardEvent);
			bezel.removeEventListener("ingamePreRenderInfoPanel", eh_ingamePreRenderInfoPanel);
			gameObjects.GV.main.removeEventListener("enterFrame", eh_ingamePreRenderInfoPanel);
			bezel.removeEventListener("ingameRightClickOnScene", eh_ingameRightClickOnScene);
		}
		
		public function eh_interceptKeyboardEvent(e:Object): void
		{
			var pE:KeyboardEvent = e.eventArgs.event;
			if (pE.ctrlKey)
			{
				if (pE.keyCode >= 49 && pE.keyCode <= 54)
				{
					e.eventArgs.continueDefault = false;
					if (this.core.arrIsSpellBtnVisible[pE.keyCode - 49])
					{
						this.markerSpellType = pE.keyCode - 49; //keyCode 49 is digit 1, which is freeze spell, which is spellType 0
						GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Entered marker placement mode!",16768392,12,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					}
					else
					{
						return;
					}
				}
			}
		}
		
		public function eh_ingameClickOnScene(e:Object): void
		{
			var mE:MouseEvent = e.eventArgs.event as MouseEvent;
			if(this.core.ingameStatus == gameObjects.constants.ingameStatus.PLAYING && this.markerSpellType != -1)
            {
				if (this.markerSpellType <= 2)
				{
					this.casters[this.markerSpellType] = new SpellCaster(this.GV.main.mouseX - 50, this.GV.main.mouseY - 8, this.markerSpellType);
					GV.vfxEngine.createFloatingText4(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Added a new marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					
				    this.spellImages[markerSpellType].circle.width = this.spellImages[markerSpellType].circle.height = spellRangeCircleSizes[markerSpellType].g() * 2 * 28;
					this.spellImages[markerSpellType].circle.x = this.GV.main.mouseX - 50;
					this.spellImages[markerSpellType].circle.y = this.GV.main.mouseY - 8;
					this.spellImages[markerSpellType].circle.visible = true;
				}
				else
				{
					var building:Object = SpellCaster.getBuildingForPos(this.GV.main.mouseX - 50, this.GV.main.mouseY - 8);
					if (building != null && (building is Tower || building is Lantern || building is Amplifier || building is Trap))
					{
						this.casters[this.markerSpellType] = new SpellCaster(this.GV.main.mouseX - 50, this.GV.main.mouseY - 8, this.markerSpellType);
						GV.vfxEngine.createFloatingText4(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Spell bound to building!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
						
						this.spellImages[markerSpellType].x = this.GV.main.mouseX - iconBitmaps[markerSpellType - 3].width / 2;
						this.spellImages[markerSpellType].y = this.GV.main.mouseY - iconBitmaps[markerSpellType - 3].height / 2;
						this.spellImages[markerSpellType].visible = true;
					}
				}
				this.markerSpellType = -1;
			}
		}
		
		public function eh_ingameRightClickOnScene(e:Object): void
		{
			var mE:MouseEvent = e.eventArgs.event as MouseEvent;
			if(this.core.ingameStatus == gameObjects.constants.ingameStatus.PLAYING && this.markerSpellType != -1)
            {
				this.casters[this.markerSpellType] = null;
				if (this.markerSpellType <= 2)
				{
					GV.vfxEngine.createFloatingText4(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Removed a marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					this.spellImages[markerSpellType].circle.visible = false;
				}
				else
				{
					GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Unbound spell from building!",16768392,12,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
					this.spellImages[markerSpellType].visible = false;
				}
			}
			this.markerSpellType = -1;
		}
		
		public function eh_ingamePreRenderInfoPanel(e:Object): void
		{	
			this.frameCounter++;
			if (this.frameCounter >= 15)
				this.castAtAllMarkers();
				
			readdImages();
			
				
			for (var i:int = 0; i < 6; i++)
			{
				if (this.casters[i] != null && this.casters[i].valid())
				{
					this.spellImages[i].visible = true;
				}
				else
				{
					this.spellImages[i].visible = false;
				}
			}
		}
		
		private function castAtAllMarkers(): void
		{
			for each (var caster:SpellCaster in this.casters) 
			{
				if (caster != null && caster.valid() && caster.castReady())
				{
					caster.cast();
				}
			}
		}
		
		private function readdImages(): void
		{
			for (var i:int = 0; i < 6; i++)
			{
				this.core.cnt.cntRetinaHud.addChild(this.spellImages[i]);
			}
		}
	}
}
