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
		public var spellType:int;
		public static var StrikeSpell:Class;
		
		public function SpellCaster(posX:int, posY:int, spellType:int) 
		{
			this.positionX = posX;
			this.positionY = posY;
			this.spellType = spellType;
			
			if (StrikeSpell == null)
			{
				StrikeSpell = getDefinitionByName("com.giab.games.gcfw.entity.StrikeSpell") as Class;
			}
		}
		
		public function cast(): void
		{
			new StrikeSpell(this.positionX, this.positionY, this.spellType);
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
				default:
					break;
			}
		}
	}

}