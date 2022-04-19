package Autocast 
{
	/**
	 * ...
	 * @author Hellrage
	 */
	
	import com.giab.games.gccs.steam.GV;
	import com.giab.games.gccs.steam.entity.StrikeSpell;
	import flash.utils.*;
	
	public class GCCSSpellCaster 
	{
		public var positionX:int;
		public var positionY:int;
		public var building:Object;
		public var spellType:int;
		
		public function GCCSSpellCaster(posX:int, posY:int, spellType:int) 
		{
			this.positionX = posX;
			this.positionY = posY;
			this.spellType = spellType;
			this.building = getBuildingForPos(posX, posY);
		}
		
		public function cast(): void
		{
			if (spellType >= 0 && spellType <= 2)
			{
				new StrikeSpell(Math.floor(this.positionX / 17), Math.floor(this.positionY / 17), this.spellType);
				consumeSpellCharge(this.spellType);
			}
			else if (spellType >= 3 && spellType <= 5)
			{
				GV.ingameCore.spellCaster.castGemEnhancement(building.insertedGem, spellType - 3);
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
	}

}
