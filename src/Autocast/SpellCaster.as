package Autocast 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import flash.utils.*;
	public class SpellCaster 
	{
		public var positionX:int;
		public var positionY:int;
		public var building:Object;
		public var spellType:int;
		public static var StrikeSpell:Class;
		
		public function SpellCaster(posX:int, posY:int, spellType:int) 
		{
			this.positionX = posX;
			this.positionY = posY;
			this.spellType = spellType;
			this.building = getBuildingForPos(posX, posY);
			
			if (StrikeSpell == null)
			{
				StrikeSpell = getDefinitionByName("com.giab.games.gcfw.entity.StrikeSpell") as Class;
			}
		}
		
		public function cast(): void
		{
			if (spellType >= 0 && spellType <= 2)
			{
				new StrikeSpell(this.positionX, this.positionY, this.spellType);
				consumeSpellCharge(this.spellType);
			}
			else if (spellType >= 3 && spellType <= 5)
			{
				Autocast.Autocast.bezel.gameObjects.GV.ingameCore.spellCaster.castGemEnhancement(building.insertedGem, spellType - 3);
			}
		}
		
		public function castReady(): Boolean
		{
			if (getSpellCharge(spellType) >= getMaxSpellCharge(spellType))
			{
				if (spellType <= 2)
				{
					return true;
				}
				else if (building.insertedGem != null && (building.insertedGem.enhancementType != spellType - 3 || building.insertedGem.e_ammoLeft.g() == 0))
				{
					return true;
				}
			}
			return false;
		}
		
		public function valid(): Boolean
		{
			if (this.spellType >= 3 && (this.building == null || this.building != getBuildingForPos(this.positionX, this.positionY)))
			{
				return false;
			}
			return true;
		}
		
		public static function getSpellCharge(spellType:int): Number
		{
			var core:Object = Autocast.Autocast.bezel.gameObjects.GV.ingameCore;
			switch (spellType) 
			{
				case 0:
					return core.spFreezeCurrentCharge.g()
				case 1:
					return core.spWhiteoutCurrentCharge.g()
				case 2:
					return core.spIsCurrentCharge.g()
				case 3:
					return core.spBoltCurrentCharge.g()
				case 4:
					return core.spBeamCurrentCharge.g()
				case 5:
					return core.spBarrageCurrentCharge.g()
				default:
					return -1;
			}
		}
		
		public static function getMaxSpellCharge(spellType:int): Number
		{
			var core:Object = Autocast.Autocast.bezel.gameObjects.GV.ingameCore;
			switch (spellType) 
			{
				case 0:
					return core.spFreezeMaxCharge.g()
				case 1:
					return core.spWhiteoutMaxCharge.g()
				case 2:
					return core.spIsMaxCharge.g()
				case 3:
					return core.spBoltMaxCharge.g()
				case 4:
					return core.spBeamMaxCharge.g()
				case 5:
					return core.spBarrageMaxCharge.g()
				default:
					return -1;
			}
		}
		
		public static function consumeSpellCharge(spellType:int): void
		{
			var core:Object = Autocast.Autocast.bezel.gameObjects.GV.ingameCore;
			switch (spellType) 
			{
				case 0:
					core.spFreezeCurrentCharge.s(core.spFreezeCurrentCharge.g() - 1)
					break;
				case 1:
					core.spWhiteoutCurrentCharge.s(core.spWhiteoutCurrentCharge.g() - 1)
					break;
				case 2:
					core.spIsCurrentCharge.s(core.spIsCurrentCharge.g() - 1)
					break;
				case 3:
					core.spBoltCurrentCharge.s(core.spBoltCurrentCharge.g() - 1)
					break;
				case 4:
					core.spBeamCurrentCharge.s(core.spBeamCurrentCharge.g() - 1)
					break;
				case 5:
					core.spBarrageCurrentCharge.s(core.spBarrageCurrentCharge.g() - 1)
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
				return Autocast.Autocast.bezel.gameObjects.GV.ingameCore.buildingAreaMatrix[fieldY][fieldX];
			}
			return null;
		}
	}

}
