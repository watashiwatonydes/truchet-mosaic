package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import tiles.typeA.Pattern1;
	import tiles.typeB.Pattern1;
	import tiles.typeB.Pattern2;
	import tiles.typeB.Pattern3;
	import tiles.typeB.Pattern4;
	
	[SWF(frameRate="40", heightPercent="100", widthPercent="100", backgroundColor=0x000000)]
	public class TruchetMosaic extends Sprite
	{

		private var _patterns:Vector.<BitmapData>;
		private var _randomized:Vector.<RandomizedChars>;
		private var _truchetMatrix:Vector.<Vector.<int>>;

		private var NLINE:int 	= 0;
		private var NCOL:int	= 0;
		private var PATTERN_WIDTH:int;
		private var PATTERN_HEIGHT:int;

		private var _container:Bitmap;
		private var _snapshotContainer:Sprite;

		private var _iterationTimer:Timer;
		private var _snapshotTimer:Timer;
		
		private var LEFT:int 					= 0;
		private var TIMER_BASE:Number 			= 4000;
		private var FLIP_DURATION:Number 		= 1;
		private var FLIP_FRAMERATE:int 			= 13;
		private var FLIP_DELAY:Number			= 160;
		private var SNAPSHOT_OFFSET_X:Number 	= 0;
		private var SNAPSHOT_OFFSET_Y:Number 	= 0;
		private var FLIP_INCREMENT:Number	 	= 0.2;
		
		private var CANVAS:BitmapData;

		private const SOURCE_RECT:Rectangle 	= new Rectangle(0, 0, 0, 0);
		private const DEST_POINT:Point 			= new Point(0, 0);
		
		
		public function TruchetMosaic()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align	 	= StageAlign.TOP_LEFT;

			NCOL 	= 12;
			NLINE	= 12;
			FLIP_DURATION 	= .6;
			
			_patterns 		= new Vector.<BitmapData>( 8, true) ;
			_truchetMatrix 	= new Vector.<Vector.<int>>(NLINE, true);
			_randomized		= new Vector.<RandomizedChars>( NLINE, true );

			_container		= new Bitmap();
			_container.x 	= 50; 
			_container.y 	= 50; 
			this.addChild( _container );
		
			step();
		}
			
		private function step():void 
		{
			var size:Number 	= Math.min( stage.stageWidth, stage.stageHeight ) - 100;
			
			PATTERN_WIDTH 		= size/NLINE;
			PATTERN_HEIGHT 		= size/NLINE;
			
			CANVAS				= new BitmapData( NCOL * PATTERN_WIDTH, NLINE * PATTERN_HEIGHT, false, 0x000000 );
			
			_container.bitmapData = CANVAS;
			
			SOURCE_RECT.width	= PATTERN_WIDTH; 
			SOURCE_RECT.height	= PATTERN_HEIGHT; 
			
			// Generate a Truchet tile graph
			var PATTERN_TYPE:Array 	= [ 0, 1, 2, 3 ];
			var c0:Number			= Math.floor(Math.random() * PATTERN_TYPE.length);
			
			var i:int = 0, j:int = 0;
			for ( i = 0 ; i < NLINE ; i++ )
			{
				_truchetMatrix[ i ] = new Vector.<int>( NCOL, true );
				
				for ( j = 0 ; j < NCOL ; j++ )
				{
					var _x:Number      	= Math.floor(Math.random() * 2);
					var parite:Number  	= (c0 + i + j)  % 2;
					var C:Number       	=  2 * _x + parite;
					
					_truchetMatrix[ i ][ j ] 	= PATTERN_TYPE[ C ];
				}
			}

			// Generate BitmapData patterns 
			_patterns[ 0 ] 	= new tiles.typeB.Pattern1(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 1 ] 	= new tiles.typeB.Pattern2(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 2 ] 	= new tiles.typeB.Pattern3(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 3 ] 	= new tiles.typeB.Pattern4(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 4 ] 	= new tiles.typeA.Pattern1(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 5 ] 	= new tiles.typeA.Pattern2(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 6 ] 	= new tiles.typeA.Pattern3(PATTERN_WIDTH, PATTERN_HEIGHT);
			_patterns[ 7 ] 	= new tiles.typeA.Pattern4(PATTERN_WIDTH, PATTERN_HEIGHT);
			
			draw();
		}
		
		protected function draw():void
		{
			var flipString:String;
			var i:int, k:int;
			var index:int;
			var randomlength:int;
			var randomizableLength:int;
			var colOffset:int;
			var lengthAvailable:int;
			var bounds:int;
			var lineIndexes:Array = [ ];
			
			for  ( i = 0 ; i < NLINE ; i++ )
			{
				lineIndexes.push( i );
			}

			while ( lineIndexes.length > 0 )
			{
				index 						= Math.floor(Math.random() * lineIndexes.length);
				i 							= lineIndexes[ index ]; 
				
				lineIndexes.splice(index, 1);
				
				FLIP_DELAY 					= int( Math.random() * 1000 ); 
				FLIP_FRAMERATE 				= 10 + int( Math.random() * 20 ); 

				randomizableLength	= NCOL;
				colOffset			= Math.floor(Math.random() * (randomizableLength));
				lengthAvailable		= NCOL - colOffset + 1;
				
				randomlength		= Math.floor(Math.random() * (lengthAvailable));
				
				flipString 					= "";
				bounds 				= colOffset + randomlength;
				
				for ( k = colOffset ; k < bounds ; k++ )
				{
					flipString 				+= String(_truchetMatrix[ i ][ k ]);
				}
				
				var rc:RandomizedChars	= new RandomizedChars( i, colOffset, FLIP_DELAY, FLIP_FRAMERATE );
				rc.addEventListener(TextUpdateEvent.UPDATE, onTextUpdate);
				_randomized[ i ] = rc;
				rc.flipTo( 0, flipString, FLIP_DURATION );
			}
		}
		
		protected function onTextUpdate(event:TextUpdateEvent):void
		{
			var buffer:String 		= event.text;
			var nLin:int 			= event.lineIndex;
			var nCol:int 			= event.colIndex;
			var ln:int 				= buffer.length;
			
			
			var pattern:BitmapData;
			var index:int;
			var j:int = 0;
			var bounds:int			= nCol + ln;
			
			for ( j = 0 ; j < ln ; j++ )
			{
				index 				= parseInt(buffer.charAt( j ));
				
				pattern 			= _patterns[ index ];
				
				DEST_POINT.x 		= PATTERN_WIDTH * (nCol + j);
				DEST_POINT.y 		= PATTERN_HEIGHT * nLin;
				
				CANVAS.copyPixels( pattern, SOURCE_RECT, DEST_POINT );
			}
		}
		
		
		
				
	}
}