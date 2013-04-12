package tiles.typeB
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	public class Pattern1 extends BitmapData
		
	{
		public function Pattern1(width:int, height:int)
		{
			super(width, height, false);
			
			var canvas:Shape = new Shape();
			
			var w2:Number = width * .5;
			var h2:Number = height * .5;
			
			canvas.graphics.beginFill( 0x000000 );
			canvas.graphics.drawRect( 0, 0, width, height );
			canvas.graphics.endFill();
			
			
			canvas.graphics.beginFill( 0xffffff );
			canvas.graphics.moveTo( 0, h2 );
			canvas.graphics.curveTo( w2, h2, w2, height );
			canvas.graphics.lineTo( 0, height );
			canvas.graphics.lineTo( 0, h2 );
			canvas.graphics.endFill();
			
			canvas.graphics.beginFill( 0xffffff );
			canvas.graphics.moveTo( w2, 0 );
			canvas.graphics.curveTo( w2, h2, width, h2 );
			canvas.graphics.lineTo( width, 0 );
			canvas.graphics.lineTo( w2, 0 );
			canvas.graphics.endFill();
		
			// Surround
			// canvas.graphics.lineStyle( 1, 0xFFFFFF, .1 );
			// canvas.graphics.drawRect( 0, 0, width - 1, height - 1 );
			
			draw( canvas, null, null, null, null, false );
		}
		
		
	}
}