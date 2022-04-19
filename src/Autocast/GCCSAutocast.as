package Autocast
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.GCCS.Events.EventTypes;
	import Bezel.GCCS.Events.EventTypes;
	import Bezel.GCCS.Events.IngameClickOnSceneEvent;
	import Bezel.GCCS.Events.IngameKeyDownEvent;
	import Bezel.GCCS.Events.IngameNewSceneEvent;
	import Bezel.GCCS.Events.IngamePreRenderInfoPanelEvent;
	import Bezel.GCCS.Events.IngameRightClickOnSceneEvent;
	import Bezel.Utils.Keybind;
	import air.desktop.URLFilePromise;
	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.constants.IngameStatus;
	import com.giab.games.gccs.steam.entity.Amplifier;
	import com.giab.games.gccs.steam.entity.Tower;
	import com.giab.games.gccs.steam.entity.Trap;
	import com.giab.games.gccs.steam.mcDyn.McRangeCurse;
	import com.giab.games.gccs.steam.mcDyn.McRangeFreeze;
	import com.giab.games.gccs.steam.mcDyn.McRangeWoe;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.display.MovieClip;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.globalization.LocaleID;
	import flash.utils.*;
	import flash.ui.Keyboard;
	
	public class GCCSAutocast extends MovieClip
	{
		internal static var storage:File;
		
		private var casters:Object;
		public var markerSpellType:int;
		private var frameCounter:int;
		
		public static const FIELD_WIDTH: Number = 54;
		public static const FIELD_HEIGHT: Number = 32;
		public static const WAVESTONE_WIDTH: Number = 39;
		public static const TOP_UI_HEIGHT: Number = 53;
		public static const TILE_SIZE: Number = 17;
		
		private static var spellRangeCircleSizes:Array;
		
		private static var iconBitmaps:Array;
		
		private var spellImages:Array;
		
		private const spellKeybindNamesToIds:Object = {
			"Cast freeze strike spell":0,
			"Cast curse strike spell":1,
			"Cast wake of eternity strike spell":2,
			"Cast bolt enhancement spell":3,
			"Cast beam enhancement spell":4,
			"Cast barrage enhancement spell":5
		};
		
		public function GCCSAutocast()
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
			this.spellImages[0].x = 0;
			this.spellImages[0].y = 0;
			this.spellImages[0].mcMask.width = TILE_SIZE*FIELD_WIDTH;
			this.spellImages[0].mcMask.height = TILE_SIZE*FIELD_HEIGHT;
			this.spellImages[0].circle.visible = true;
			this.spellImages[0].visible = false;
			this.spellImages[1] = new McRangeCurse();
			this.spellImages[1].x = 0;
			this.spellImages[1].y = 0;
			this.spellImages[1].mcMask.width = TILE_SIZE*FIELD_WIDTH;
			this.spellImages[1].mcMask.height = TILE_SIZE*FIELD_HEIGHT;
			this.spellImages[1].circle.visible = true;
			this.spellImages[1].visible = false;
			this.spellImages[2] = new McRangeWoe();
			this.spellImages[2].x = 0;
			this.spellImages[2].y = 0;
			this.spellImages[2].mcMask.width = TILE_SIZE*FIELD_WIDTH;
			this.spellImages[2].mcMask.height = TILE_SIZE*FIELD_HEIGHT;
			this.spellImages[2].circle.visible = true;
			this.spellImages[2].visible = false;
			spellRangeCircleSizes = new Array(GV.ingameCore.spFreezeRadius, GV.ingameCore.spCurseRadius, GV.ingameCore.spWoeRadius);
			
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
			if (spell == 0 && GV.main.cntScreens.cntIngame.mcIngameFrame.btnCastFreeze.visible == false)
				return;
			if (spell == 1 && GV.main.cntScreens.cntIngame.mcIngameFrame.btnCastCurse.visible == false)
				return;
			if (spell == 2 && GV.main.cntScreens.cntIngame.mcIngameFrame.btnCastWoE.visible == false)
				return;
			this.markerSpellType = spell; //keyCode 49 is digit 1, which is freeze spell, which is spellType 0
			GV.vfxEngine.createFloatingText(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Entered marker placement mode!",16768392,12,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
		}
		
		public function eh_ingameClickOnScene(e:IngameClickOnSceneEvent): void
		{
			var mE:MouseEvent = e.eventArgs.event as MouseEvent;
			if(GV.ingameCore.ingameStatus == IngameStatus.PLAYING && this.markerSpellType != -1)
            {
				var clickX: Number = GV.main.mouseX - WAVESTONE_WIDTH;
				var clickY:Number = GV.main.mouseY - TOP_UI_HEIGHT;
				if (this.markerSpellType <= 2)
				{
					this.casters[this.markerSpellType] = new GCCSSpellCaster(clickX, clickY, this.markerSpellType);
					GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Added a new marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					
				    this.spellImages[markerSpellType].circle.width = this.spellImages[markerSpellType].circle.height = spellRangeCircleSizes[markerSpellType].g() * 2 * TILE_SIZE;
					this.spellImages[markerSpellType].circle.x = GV.main.mouseX;
					this.spellImages[markerSpellType].circle.y = GV.main.mouseY;
					this.spellImages[markerSpellType].circle.visible = true;
				}
				else
				{
					var building:Object = GCCSSpellCaster.getBuildingForPos(clickX, clickY);
					if (building != null && (building is Tower || building is Amplifier || building is Trap))
					{
						this.casters[this.markerSpellType] = new GCCSSpellCaster(clickX, clickY, this.markerSpellType);
						GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Spell bound to building!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
						
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
					GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Removed a marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					this.spellImages[markerSpellType].circle.visible = false;
				}
				else
				{
					GV.vfxEngine.createFloatingText(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Unbound spell from building!",16768392,12,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
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
			for each (var caster:GCCSSpellCaster in this.casters) 
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
