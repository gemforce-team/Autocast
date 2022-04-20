package Autocast
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import Bezel.GCCS.Events.EventTypes;
	import Bezel.GCCS.Events.IngameClickOnSceneEvent;
	import Bezel.GCCS.Events.IngameKeyDownEvent;
	import Bezel.GCCS.Events.IngameNewSceneEvent;
	import Bezel.GCCS.Events.IngameRightClickOnSceneEvent;
	import Bezel.Utils.Keybind;
	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.constants.IngameStatus;
	import com.giab.games.gccs.steam.entity.Amplifier;
	import com.giab.games.gccs.steam.entity.Tower;
	import com.giab.games.gccs.steam.entity.Trap;
	import flash.display.MovieClip;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	public class GCCSAutocast extends MovieClip
	{
		internal static var storage:File;
		
		private var strikeCasters:Vector.<GCCSSpellCaster>;
		private var enhanceCasters:Vector.<GCCSSpellCaster>;
		public var markerSpellType:int;
		private var frameCounter:int;

		public static const FIELD_WIDTH:int = 54;
		public static const FIELD_HEIGHT:int = 32;
		public static const WAVESTONE_WIDTH:int = 39;
		public static const TOP_UI_HEIGHT:int = 53;
		public static const TILE_SIZE:int = 17;
		
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
			this.strikeCasters = new Vector.<GCCSSpellCaster>(3, true);
			this.enhanceCasters = new Vector.<GCCSSpellCaster>();
			this.markerSpellType = -1;
			this.frameCounter = 0;
			
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

			var caster:GCCSSpellCaster;

			for each (caster in strikeCasters)
			{
				if (caster != null)
				{
					GV.ingameCore.cnt.cntRetinaHud.removeChild(caster);
				}
			}

			for each (caster in enhanceCasters)
			{
				GV.ingameCore.cnt.cntRetinaHud.removeChild(caster);
			}
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
			// Remove all casters
			for (var i:int = 0; i < 3; i++) 
			{
				this.strikeCasters[i] = null;
			}

			this.enhanceCasters.length = 0;
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
					if (this.strikeCasters[this.markerSpellType] != null)
					{
						GV.ingameCore.cnt.cntRetinaHud.removeChild(this.strikeCasters[this.markerSpellType]);
					}
					this.strikeCasters[this.markerSpellType] = new GCCSSpellCaster(clickX, clickY, this.markerSpellType);
					GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Added a new marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
					
					GV.ingameCore.cnt.cntRetinaHud.addChild(this.strikeCasters[this.markerSpellType]);
				}
				else
				{
					var building:Object = GCCSSpellCaster.getBuildingForPos(clickX, clickY);
					if (building != null && (building is Tower || building is Amplifier || building is Trap))
					{
						var shouldPlace:Boolean = true;
						for each (var caster:GCCSSpellCaster in this.enhanceCasters)
						{
							if (caster.building == building && caster.spellType == this.markerSpellType)
							{
								shouldPlace = false;
								break;
							}
						}
						if (shouldPlace)
						{
							this.enhanceCasters[this.enhanceCasters.length] = new GCCSSpellCaster(clickX, clickY, this.markerSpellType);
							GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Spell bound to building!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);

							GV.ingameCore.cnt.cntRetinaHud.addChild(this.enhanceCasters[this.enhanceCasters.length - 1]);
						}
						else
						{
							GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Spell already bound to building!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
						}
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
				if (this.markerSpellType <= 2)
				{
					GV.ingameCore.cnt.cntRetinaHud.removeChild(this.strikeCasters[this.markerSpellType]);
					this.strikeCasters[this.markerSpellType] = null;
					GV.vfxEngine.createFloatingText(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), "Removed a marker!", 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
				}
				else
				{
					var building:Object = GCCSSpellCaster.getBuildingForPos(GV.main.mouseX - WAVESTONE_WIDTH, GV.main.mouseY - TOP_UI_HEIGHT);
					for (var i:int = 0; i < this.enhanceCasters.length; i++)
					{
						if (this.enhanceCasters[i].building == building && this.enhanceCasters[i].spellType == this.markerSpellType)
						{
							GV.ingameCore.cnt.cntRetinaHud.removeChild(this.enhanceCasters[i]);
							this.enhanceCasters.splice(i, 1);
							GV.vfxEngine.createFloatingText(GV.main.mouseX,GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20),"Unbound spell from building!",16768392,12,"center",Math.random() * 3 - 1.5,-4 - Math.random() * 3,0,0.55,12,0,1000);
							break;
						}
					}
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
		}
		
		private function castAtAllMarkers(): void
		{
			var caster:GCCSSpellCaster;
			for each (caster in this.strikeCasters) 
			{
				if (caster != null && caster.castReady())
				{
					caster.cast();
				}
			}

			for (var i:int = enhanceCasters.length - 1; i > -1; i--)
			{
				caster = enhanceCasters[i];
				if (!caster.valid())
				{
					GV.ingameCore.cnt.cntRetinaHud.removeChild(caster);
					this.enhanceCasters.splice(i, 1);
				}
				else if (caster.castReady())
				{
					caster.cast();
				}
			}

			// Ensure all enhancement casters get a turn
			enhanceCasters.push(enhanceCasters.shift());
		}
	}
}
