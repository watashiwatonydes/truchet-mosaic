package tiles.typeA
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	public class Pattern4 extends BitmapData
	{
		public function Pattern4(width:int, height:int)
		{
			super(width, height, false);
			
			var canvas:Shape = new Shape();
			
			
			canvas.graphics.beginFill( 0x000000 );
			canvas.graphics.lineTo( width, 0 );
			canvas.graphics.lineTo( 0, height );
			canvas.graphics.lineTo( 0, 0 );
			canvas.graphics.endFill();
			
			canvas.graphics.beginFill( 0xFFFFFF );
			canvas.graphics.moveTo( width, 0 );
			canvas.graphics.lineTo( width, height );
			canvas.graphics.lineTo( 0, height );
			canvas.graphics.lineTo( width, 0 );
			canvas.graphics.endFill();
			
			draw( canvas, null, null, null, null, true );
		}
	}
}