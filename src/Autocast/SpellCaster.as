package Autocast 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import com.giab.games.gcfw.GV;
	import com.giab.games.gcfw.entity.StrikeSpell;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import com.giab.games.gcfw.mcDyn.McRangeFreeze;
	import com.giab.games.gcfw.mcDyn.McRangeWhiteout;
	import com.giab.games.gcfw.mcDyn.McRangeIceShards;
	import flash.display.PixelSnapping;
	import flash.display.Bitmap;

	public class SpellCaster extends Sprite
	{
		public var building:Object;
		public var spellType:int;

		private var image:DisplayObject;
		
		public function SpellCaster(posX:int, posY:int, spellType:int) 
		{
			this.spellType = spellType;
			switch (spellType)
			{
				case 0:
					var mcFreeze:McRangeFreeze = new McRangeFreeze();
					this.x = posX;
					this.y = posY;
					mcFreeze.circle.width = mcFreeze.circle.height = GV.ingameCore.spFreezeRadius.g() * 2 * 28;
					// mcFreeze.circle.mask = mcFreeze.mcMask;
					// mcFreeze.mcMask.width = 1680;
					// mcFreeze.mcMask.height = 1064;
					// mcFreeze.mcMask.x = -posX;
					// mcFreeze.mcMask.y = -posY;
					// mcFreeze.mcMask.visible = false;
					// this.addChild(mcFreeze.circle.mask);
					image = mcFreeze.circle;
					break;
				case 1:
					var mcWhiteout:McRangeWhiteout = new McRangeWhiteout();
					this.x = posX;
					this.y = posY;
					mcWhiteout.circle.width = mcWhiteout.circle.height = GV.ingameCore.spWhiteoutRadius.g() * 2 * 28;
					// mcWhiteout.circle.mask = mcWhiteout.mcMask;
					// mcWhiteout.mcMask.width = 1680;
					// mcWhiteout.mcMask.height = 1064;
					// mcWhiteout.mcMask.x = -posX;
					// mcWhiteout.mcMask.y = -posY;
					// mcWhiteout.mcMask.visible = false;
					// this.addChild(mcWhiteout.circle.mask);
					image = mcWhiteout.circle;
					break;
				case 2:
					var mcIceShards:McRangeIceShards = new McRangeIceShards();
					this.x = posX;
					this.y = posY;
					mcIceShards.circle.width = mcIceShards.circle.height = GV.ingameCore.spIsRadius.g() * 2 * 28;
					// mcIceShards.circle.mask = mcIceShards.mcMask;
					// mcIceShards.mcMask.width = 1680;
					// mcIceShards.mcMask.height = 1064;
					// mcIceShards.mcMask.x = -posX;
					// mcIceShards.mcMask.y = -posY;
					// mcIceShards.mcMask.visible = false;
					// this.addChild(mcIceShards.circle.mask);
					image = mcIceShards.circle;
					break;
				case 3:
					this.building = getBuildingForPos(posX, posY);
					image = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBolt, PixelSnapping.ALWAYS, true);
					this.x = (this.building.fieldX + 1) * 28 - image.width / 2;
					this.y = (this.building.fieldY + 1) * 28 - image.height / 2;
					break;
				case 4:
					this.building = getBuildingForPos(posX, posY);
					image = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBeam, PixelSnapping.ALWAYS, true);
					this.x = (this.building.fieldX + 1) * 28 - image.width / 2;
					this.y = (this.building.fieldY + 1) * 28 - image.height / 2;
					break;
				case 5:
					this.building = getBuildingForPos(posX, posY);
					image = new Bitmap(GV.gemBitmapCreator.bmpdEnhIconBarrage, PixelSnapping.ALWAYS, true);
					this.x = (this.building.fieldX + 1) * 28 - image.width / 2;
					this.y = (this.building.fieldY + 1) * 28 - image.height / 2;
					break;
			}

			image.x = 50;
			image.y = 8;

			this.addChild(image);
		}
		
		public function cast(): void
		{
			if (spellType >= 0 && spellType <= 2)
			{
				new StrikeSpell(this.x, this.y, this.spellType);
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
					return GV.ingameCore.spWhiteoutCurrentCharge.g()
				case 2:
					return GV.ingameCore.spIsCurrentCharge.g()
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
					return GV.ingameCore.spWhiteoutMaxCharge.g()
				case 2:
					return GV.ingameCore.spIsMaxCharge.g()
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
					GV.ingameCore.spWhiteoutCurrentCharge.s(GV.ingameCore.spWhiteoutCurrentCharge.g() - 1)
					break;
				case 2:
					GV.ingameCore.spIsCurrentCharge.s(GV.ingameCore.spIsCurrentCharge.g() - 1)
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
			if(posX > 0 && posX < 60 * 28 && posY > 0 && posY < 38 * 28)
			{
				var fieldX:int = Math.floor(posX / 28);
				var fieldY:int = Math.floor(posY / 28);
				return GV.ingameCore.buildingAreaMatrix[fieldY][fieldX];
			}
			return null;
		}

		public static function getBuildingPosX(x:int):int
		{
			if(x > 0 && x < 60 * 28)
				return Math.floor(x / 28);
			return -1;
		}

		public static function getBuildingPosY(y:int):int
		{
			if(y > 0 && y < 38 * 28)
				return Math.floor(y / 28);
			return -1;
		}
	}

}
