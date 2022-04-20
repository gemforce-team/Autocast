package Autocast 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.entity.StrikeSpell;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import com.giab.games.gccs.steam.mcDyn.McRangeFreeze;
	import com.giab.games.gccs.steam.mcDyn.McRangeCurse;
	import com.giab.games.gccs.steam.mcDyn.McRangeWoe;
	import flash.display.PixelSnapping;
	import flash.display.Bitmap;

	public class GCCSSpellCaster extends Sprite
	{
		public var building:Object;
		public var spellType:int;

		private var image:DisplayObject;
		
		public function GCCSSpellCaster(posX:int, posY:int, spellType:int) 
		{
			this.spellType = spellType;
			switch (spellType)
			{
				case 0:
					var mcFreeze:McRangeFreeze = new McRangeFreeze();
					this.x = posX;
					this.y = posY;
					mcFreeze.circle.width = mcFreeze.circle.height = GV.ingameCore.spFreezeRadius.g() * 2 * 17;
					// mcFreeze.circle.mask = mcFreeze.mcMask;
					// mcFreeze.mcMask.width = GCCSAutocast.TILE_SIZE * GCCSAutocast.FIELD_WIDTH;
					// mcFreeze.mcMask.height = GCCSAutocast.TILE_SIZE * GCCSAutocast.FIELD_HEIGHT;
					// mcFreeze.mcMask.x = -posX;
					// mcFreeze.mcMask.y = -posY;
					// mcFreeze.mcMask.visible = false;
					// this.addChild(mcFreeze.circle.mask);
					image = mcFreeze.circle;
					break;
				case 1:
					var mcCurse:McRangeCurse = new McRangeCurse();
					this.x = posX;
					this.y = posY;
					mcCurse.circle.width = mcCurse.circle.height = GV.ingameCore.spCurseRadius.g() * 2 * 17;
					// mcCurse.circle.mask = mcCurse.mcMask;
					// mcCurse.mcMask.width = GCCSAutocast.TILE_SIZE * GCCSAutocast.FIELD_WIDTH;
					// mcCurse.mcMask.height = GCCSAutocast.TILE_SIZE * GCCSAutocast.FIELD_HEIGHT;
					// mcCurse.mcMask.x = -posX;
					// mcCurse.mcMask.y = -posY;
					// mcCurse.mcMask.visible = false;
					// this.addChild(mcCurse.circle.mask);
					image = mcCurse.circle;
					break;
				case 2:
					var mcWoe:McRangeWoe = new McRangeWoe();
					this.x = posX;
					this.y = posY;
					mcWoe.circle.width = mcWoe.circle.height = GV.ingameCore.spWoeRadius.g() * 2 * 17;
					// mcWoe.circle.mask = mcWoe.mcMask;
					// mcWoe.mcMask.width = GCCSAutocast.TILE_SIZE * GCCSAutocast.FIELD_WIDTH;
					// mcWoe.mcMask.height = GCCSAutocast.TILE_SIZE * GCCSAutocast.FIELD_HEIGHT;
					// mcWoe.mcMask.x = -posX;
					// mcWoe.mcMask.y = -posY;
					// mcWoe.mcMask.visible = false;
					// this.addChild(mcWoe.circle.mask);
					image = mcWoe.circle;
					break;
				case 3:
					this.building = getBuildingForPos(posX, posY);
					image = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBolt, PixelSnapping.ALWAYS, true);
					this.x = (this.building.fieldX + 1) * 17 - image.width / 2;
					this.y = (this.building.fieldY + 1) * 17 - image.height / 2;
					break;
				case 4:
					this.building = getBuildingForPos(posX, posY);
					image = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBeam, PixelSnapping.ALWAYS, true);
					this.x = (this.building.fieldX + 1) * 17 - image.width / 2;
					this.y = (this.building.fieldY + 1) * 17 - image.height / 2;
					break;
				case 5:
					this.building = getBuildingForPos(posX, posY);
					image = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBarrage, PixelSnapping.ALWAYS, true);
					this.x = (this.building.fieldX + 1) * 17 - image.width / 2;
					this.y = (this.building.fieldY + 1) * 17 - image.height / 2;
					break;
			}

			image.x = GCCSAutocast.WAVESTONE_WIDTH;
			image.y = GCCSAutocast.TOP_UI_HEIGHT;

			this.addChild(image);
		}
		
		public function cast(): void
		{
			if (spellType >= 0 && spellType <= 2)
			{
				new StrikeSpell(Math.floor(this.x / 17), Math.floor(this.y / 17), this.spellType);
				consumeSpellCharge(this.spellType);
			}
			else if (spellType >= 3 && spellType <= 5)
			{
				GV.ingameCore.spellCaster.castGemEnhancement(building.insertedGem, spellType - 3);
			}
		}
		
		public function castReady(): Boolean
		{
			if (spellType <= 2 && getSpellCharge(spellType) >= getMaxSpellCharge(spellType))
			{
				return true;
			}
			else if (spellType >= 3 && building.insertedGem != null && (building.insertedGem.enhancementType != spellType - 3 || building.insertedGem.e_ammoLeft.g() == 0))
			{
				return true;
			}
			return false;
		}
		
		public function valid(): Boolean
		{
			if (this.spellType >= 3 && (this.building == null || this.building != getBuildingForPos(this.x, this.y)))
			{
				return false;
			}
			return true;
		}
		
		public static function getSpellCharge(spellType:int): Number
		{
			switch (spellType) 
			{
				case 0:
					return GV.ingameCore.spFreezeCurrentCharge.g()
				case 1:
					return GV.ingameCore.spCurseCurrentCharge.g()
				case 2:
					return GV.ingameCore.spWoeCurrentCharge.g()
				case 3:
					return GV.ingameCore.spBoltCurrentCharge.g()
				case 4:
					return GV.ingameCore.spBeamCurrentCharge.g()
				case 5:
					return GV.ingameCore.spBarrageCurrentCharge.g()
				default:
					return -1;
			}
		}
		
		public static function getMaxSpellCharge(spellType:int): Number
		{
			switch (spellType) 
			{
				case 0:
					return GV.ingameCore.spFreezeMaxCharge.g()
				case 1:
					return GV.ingameCore.spCurseMaxCharge.g()
				case 2:
					return GV.ingameCore.spWoeMaxCharge.g()
				case 3:
					return GV.ingameCore.spBoltMaxCharge.g()
				case 4:
					return GV.ingameCore.spBeamMaxCharge.g()
				case 5:
					return GV.ingameCore.spBarrageMaxCharge.g()
				default:
					return -1;
			}
		}
		
		public static function consumeSpellCharge(spellType:int): void
		{
			switch (spellType) 
			{
				case 0:
					GV.ingameCore.spFreezeCurrentCharge.s(GV.ingameCore.spFreezeCurrentCharge.g() - 1)
					break;
				case 1:
					GV.ingameCore.spCurseCurrentCharge.s(GV.ingameCore.spCurseCurrentCharge.g() - 1)
					break;
				case 2:
					GV.ingameCore.spWoeCurrentCharge.s(GV.ingameCore.spWoeCurrentCharge.g() - 1)
					break;
				case 3:
					GV.ingameCore.spBoltCurrentCharge.s(GV.ingameCore.spBoltCurrentCharge.g() - 1)
					break;
				case 4:
					GV.ingameCore.spBeamCurrentCharge.s(GV.ingameCore.spBeamCurrentCharge.g() - 1)
					break;
				case 5:
					GV.ingameCore.spBarrageCurrentCharge.s(GV.ingameCore.spBarrageCurrentCharge.g() - 1)
					break;
				default:
					break;
			}
		}
		
		public static function getBuildingForPos(posX:int, posY:int): Object
		{
			if((posX > 0) && (posX < 54 * 17) && (posY > 0) && (posY < 32 * 17))
			{
				var fieldX:int = Math.floor(posX / 17);
				var fieldY:int = Math.floor(posY / 17);
				return GV.ingameCore.buildingAreaMatrix[fieldY][fieldX];
			}
			return null;
		}

		public static function getBuildingPosX(x:int):int
		{
			if(x > 0 && x < 54 * 17)
				return Math.floor(x / 17);
			return -1;
		}

		public static function getBuildingPosY(y:int):int
		{
			if(y > 0 && y < 32 * 17)
				return Math.floor(y / 17);
			return -1;
		}
	}

}
