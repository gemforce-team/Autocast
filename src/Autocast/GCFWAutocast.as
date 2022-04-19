package Autocast
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.GCCS.Events.Persistence.IngameClickOnSceneEventArgs;
	import Bezel.GCFW.Events.EventTypes;
	import Bezel.GCFW.Events.IngameClickOnSceneEvent;
	import Bezel.GCFW.Events.IngameKeyDownEvent;
	import Bezel.GCFW.Events.IngameNewSceneEvent;
	import Bezel.GCFW.Events.IngamePreRenderInfoPanelEvent;
	import Bezel.GCFW.Events.IngameRightClickOnSceneEvent;
	import Bezel.Utils.Keybind;
	import com.giab.games.gcfw.GV;
	import com.giab.games.gcfw.constants.IngameStatus;
	import com.giab.games.gcfw.entity.Amplifier;
	import com.giab.games.gcfw.entity.Lantern;
	import com.giab.games.gcfw.entity.Tower;
	import com.giab.games.gcfw.entity.Trap;
	import com.giab.games.gcfw.mcDyn.McRangeFreeze;
	import com.giab.games.gcfw.mcDyn.McRangeIceShards;
	import com.giab.games.gcfw.mcDyn.McRangeWhiteout;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.display.MovieClip;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	public class GCFWAutocast extends MovieClip
	{
		internal static var storage:File;
		
		private var casters:Object;
		public var markerSpellType:int;
		private var frameCounter:int;
		
		private static var spellRangeCircleSizes:Array;
		
		private static var iconBitmaps:Array;
		
		private var spellImages:Array;
		
		private const spellKeybindNamesToIds:Object = {
			"Cast freeze strike spell":0,
			"Cast whiteout strike spell":1,
			"Cast ice shards strike spell":2,
			"Cast bolt enhancement spell":3,
			"Cast beam enhancement spell":4,
			"Cast barrage enhancement spell":5
		};
		
		public function GCFWAutocast()
		{
			super();
			storage = File.applicationStorageDirectory.resolvePath("Autocast");
			
			prepareFolders();
			
			addEventListeners();
			this.casters = new Object();
			this.markerSpellType = -1;
			this.frameCounter = 0;
			this.spellImages = new Array();
			this.spellImages[0] = new McRangeFreeze();
			this.spellImages[0].x = 50;
			this.spellImages[0].y = 8;
			this.spellImages[0].mcMask.width = 1680;
			this.spellImages[0].mcMask.height = 1064;
			this.spellImages[0].circle.visible = true;
			this.spellImages[0].visible = false;
			this.spellImages[1] = new McRangeWhiteout();
			this.spellImages[1].x = 50;
			this.spellImages[1].y = 8;
			this.spellImages[1].mcMask.width = 1680;
			this.spellImages[1].mcMask.height = 1064;
			this.spellImages[1].circle.visible = true;
			this.spellImages[1].visible = false;
			this.spellImages[2] = new McRangeIceShards();
			this.spellImages[2].x = 50;
			this.spellImages[2].y = 8;
			this.spellImages[2].mcMask.width = 1680;
			this.spellImages[2].mcMask.height = 1064;
			this.spellImages[2].circle.visible = true;
			this.spellImages[2].visible = false;
			spellRangeCircleSizes = new Array(GV.ingameCore.spFreezeRadius, GV.ingameCore.spWhiteoutRadius, GV.ingameCore.spIsRadius);
			
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
			
			AutocastMod.logger.log("bind", "Autocast initialized!");
		}
		
		private function prepareFolders(): void
		{
			if (!storage.isDirectory)
			{
				storage.createDirectory();
			}
		}
		
		private function addEventListeners(): void
		{
			AutocastMod.bezel.addEventListener(EventTypes.INGAME_CLICK_ON_SCENE, eh_ingameClickOnScene);
			AutocastMod.bezel.addEventListener(EventTypes.INGAME_KEY_DOWN, eh_interceptKeyboardEvent);
			GV.main.addEventListener("enterFrame", eh_onFrame);
			AutocastMod.bezel.addEventListener(EventTypes.INGAME_RIGHT_CLICK_ON_SCENE, eh_ingameRightClickOnScene);
			AutocastMod.bezel.addEventListener(EventTypes.INGAME_NEW_SCENE, eh_ingameNewScene);
		}
		
		public function unload(): void
		{
			removeEventListeners();
		}
		
		private function removeEventListeners(): void
		{
			AutocastMod.bezel.removeEventListener(EventTypes.INGAME_CLICK_ON_SCENE, eh_ingameClickOnScene);
			AutocastMod.bezel.removeEventListener(EventTypes.INGAME_KEY_DOWN, eh_interceptKeyboardEvent);
			GV.main.removeEventListener("enterFrame", eh_onFrame);
			AutocastMod.bezel.removeEventListener(EventTypes.INGAME_RIGHT_CLICK_ON_SCENE, eh_ingameRightClickOnScene);
			AutocastMod.bezel.removeEventListener(EventTypes.INGAME_NEW_SCENE, eh_ingameNewScene);
		}
		
		public function eh_ingameNewScene(e:IngameNewSceneEvent): void
		{
			// Remove all casters and hide circles
			for (var i:int = 0; i < 6; i++) 
			{
				this.casters[i] = null;
				if (i <= 2)
					this.spellImages[i].circle.visible = false;
				else
					this.spellImages[i].visible = false;
			}
		}
		
		public function eh_interceptKeyboardEvent(e:IngameKeyDownEvent): void
		{
			var pE:KeyboardEvent = e.eventArgs.event;
			if (pE.ctrlKey && pE.keyCode != Keyboard.CONTROL)
			{
				pE.ctrlKey = false;
				for (var keybindName:String in spellKeybindNamesToIds)
				{
					var hkval: Keybind = AutocastMod.bezel.keybindManager.getHotkeyValue(keybindName);
					if(hkval.matches(pE))
					{
						e.eventArgs.continueDefault = false;
						tryEnterMarkerMode(spellKeybindNamesToIds[keybindName]);
						pE.ctrlKey = true;
						return;
					}
				}
				pE.ctrlKey = true;
			}
		}
		
		private function tryEnterMarkerMode(spell: int): void
		{
			if (GV.ingameCore.arrIsSpellBtnVisible[spell])
			{
				this.markerSpellType = spell; //keyCode 49 is digit 1, which is freeze spell, which is spellType 0
				GV.vfxEngine.createFloatingText4(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Entered marker placement mode!",16768392,12,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
			}
		}
		
		public function eh_ingameClickOnScene(e:IngameClickOnSceneEvent): void
		{
			var mE:MouseEvent = e.eventArgs.event as MouseEvent;
			if(GV.ingameCore.ingameStatus == IngameStatus.PLAYING && this.markerSpellType != -1)
            {
				if (this.markerSpellType <= 2)
				{
					this.casters[this.markerSpellType] = new SpellCaster(GV.main.mouseX - 50, GV.main.mouseY - 8, this.markerSpellType);
					GV.vfxEngine.createFloatingText4(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Added a new marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					
				    this.spellImages[markerSpellType].circle.width = this.spellImages[markerSpellType].circle.height = spellRangeCircleSizes[markerSpellType].g() * 2 * 28;
					this.spellImages[markerSpellType].circle.x = GV.main.mouseX - 50;
					this.spellImages[markerSpellType].circle.y = GV.main.mouseY - 8;
					this.spellImages[markerSpellType].circle.visible = true;
				}
				else
				{
					var building:Object = SpellCaster.getBuildingForPos(GV.main.mouseX - 50, GV.main.mouseY - 8);
					if (building != null && (building is Tower || building is Lantern || building is Amplifier || building is Trap))
					{
						this.casters[this.markerSpellType] = new SpellCaster(GV.main.mouseX - 50, GV.main.mouseY - 8, this.markerSpellType);
						GV.vfxEngine.createFloatingText4(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Spell bound to building!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
						
						this.spellImages[markerSpellType].x = GV.main.mouseX - iconBitmaps[markerSpellType - 3].width / 2;
						this.spellImages[markerSpellType].y = GV.main.mouseY - iconBitmaps[markerSpellType - 3].height / 2;
						this.spellImages[markerSpellType].visible = true;
					}
				}
				this.markerSpellType = -1;
			}
		}
		
		public function eh_ingameRightClickOnScene(e:IngameRightClickOnSceneEvent): void
		{
			var mE:MouseEvent = e.eventArgs.event as MouseEvent;
			if(GV.ingameCore.ingameStatus == IngameStatus.PLAYING && this.markerSpellType != -1)
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
		
		public function eh_onFrame(e:Event): void
		{
			if (GV.ingameCore.ingameStatus != IngameStatus.PLAYING)
				return;
				
			this.frameCounter++;
			if (this.frameCounter >= 15)
			{
				this.castAtAllMarkers();
				this.frameCounter = 0;
			}
				
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
				GV.ingameCore.cnt.cntRetinaHud.addChild(this.spellImages[i]);
			}
		}
	}
}
