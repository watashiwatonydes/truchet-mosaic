package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.FrameLabel;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	import gs.easing.Sine;
	
	import tiles.typeA.Pattern1;
	import tiles.typeB.Pattern1;
	import tiles.typeB.Pattern2;
	import tiles.typeB.Pattern3;
	import tiles.typeB.Pattern4;
	
	[SWF(frameRate="40", heightPercent="100", widthPercent="100", backgroundColor=0x000000)]
	public class TruchetMosaic extends Sprite
	{

		private var _patterns:Vector.<BitmapData>;
		private var _bitmaps:Vector.<Vector.<Bitmap>>;
		private var _randomized:Vector.<RandomizedChars>;
		private var _truchetMatrix:Vector.<Vector.<int>>;

		private var NLINE:int 	= 0;
		private var NCOL:int	= 0;
		private var PATTERN_WIDTH:int;
		private var PATTERN_HEIGHT:int;

		private var _container:Sprite;
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
		private var SNAPSHOT_ROTATION:Number	= 0;
		
		
		
		public function TruchetMosaic()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align	 	= StageAlign.TOP_LEFT;

			
			_patterns 		= new Vector.<BitmapData>();
			_bitmaps		= new Vector.<Vector.<Bitmap>>();
			_randomized		= new Vector.<RandomizedChars>();
			_truchetMatrix 	= new Vector.<Vector.<int>>();

			_container				= new Sprite();
		
			_snapshotContainer 		= new Sprite();
			_snapshotContainer.x 	= 10;
			_snapshotContainer.y 	= int(stage.stageHeight * .25);
			this.addChild( _snapshotContainer );

			
			_snapshotTimer 	= new Timer( 1000 );
			_snapshotTimer.addEventListener(TimerEvent.TIMER, takeSnapshot);
			_snapshotTimer.start();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

			step();
		}
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			_snapshotTimer.removeEventListener(TimerEvent.TIMER, takeSnapshot);
			_snapshotTimer.stop();
			
			var rc:RandomizedChars;
			for each ( rc in _randomized )
			{
				rc.stop();
			}
		}
		
		protected function takeSnapshot(event:TimerEvent):void
		{
			var scale:Number 		= .5;
			var w:Number 			= (NCOL * PATTERN_WIDTH) * scale;
			var h:Number			= (NLINE * PATTERN_HEIGHT) * scale;
			
			var buffer:BitmapData 	= new BitmapData( w, h, false, 0x000000 );
			var m:Matrix 			= new Matrix();
			m.translate( 0, 0 );
			m.scale( scale, scale );
			buffer.draw( _container, m, null, null, null, true );

			var snapshot:Bitmap 	= new Bitmap( buffer );
			snapshot.alpha 			= .25;
			snapshot.rotation		= SNAPSHOT_ROTATION;
			_snapshotContainer.addChild( snapshot );
		
			switch( snapshot.rotation % 360 )
			{
				case 90:
						snapshot.x += 2 * w + 10; 
					break;
				case 180:
					snapshot.x += 3 * w + 20; 
					snapshot.y += h; 
					break;
				case -90:
					snapshot.x += 3 * w + 30; 
					snapshot.y += h; 
					break;
			}
			
			
			trace ( snapshot.rotation % 360 );
			
			SNAPSHOT_ROTATION 		+= 90;
			
			if(SNAPSHOT_ROTATION == 1440)
			{
				var e:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
				e.keyCode = Keyboard.SPACE;
				keyDownHandler( e );
			}
		}
		
		private function step():void 
		{
			NCOL = NLINE = 192;
			FLIP_DURATION = 3.0;
			
			var sizeRef:Number 	= Math.min( stage.stageWidth, stage.stageHeight );
			
			PATTERN_WIDTH 		= sizeRef/NLINE;
			PATTERN_HEIGHT 		= sizeRef/NLINE;
			
			// Generate a Truchet tile graph
			_truchetMatrix.length 	= 0;
			var PATTERN_TYPE:Array 	= [ 0, 1, 2, 3 ];
			var c0:Number			= Math.floor(Math.random() * PATTERN_TYPE.length);
			
			var i:int = 0, j:int = 0;
			for ( i = 0 ; i < NLINE ; i++ )
			{
				_truchetMatrix[ i ] = new Vector.<int>();
				
				for ( j = 0 ; j < NCOL ; j++ )
				{
					var _x:Number      	= Math.floor(Math.random() * 2);
					var parite:Number  	= (c0 + i + j)  % 2;
					var C:Number       	=  2 * _x + parite;
					
					_truchetMatrix[ i ][ j ] 	= PATTERN_TYPE[ C ];
				}
			}
			
			// Create Patterns
			for each (var buffer:BitmapData in _patterns)
			{
				buffer.dispose();
				buffer = null;
			}
			_patterns.length	= 0;
			
			var patternB1:tiles.typeB.Pattern1 	= new tiles.typeB.Pattern1(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternB2:tiles.typeB.Pattern2 	= new tiles.typeB.Pattern2(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternB3:tiles.typeB.Pattern3 	= new tiles.typeB.Pattern3(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternB4:tiles.typeB.Pattern4 	= new tiles.typeB.Pattern4(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternA1:tiles.typeA.Pattern1 	= new tiles.typeA.Pattern1(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternA2:tiles.typeA.Pattern2 	= new tiles.typeA.Pattern2(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternA3:tiles.typeA.Pattern3 	= new tiles.typeA.Pattern3(PATTERN_WIDTH, PATTERN_HEIGHT);
			var patternA4:tiles.typeA.Pattern4 	= new tiles.typeA.Pattern4(PATTERN_WIDTH, PATTERN_HEIGHT);
			
			_patterns.push( patternB1, patternB2, patternB3, patternB4, patternA1, patternA2, patternA3, patternA4 );
			
			_bitmaps.length 	= 0;
			for ( i  = 0; i < NLINE ; i++ )
			{
				_bitmaps[ i ] = new Vector.<Bitmap>();
			}
			
			while ( _container.numChildren > 0 )
			{
				_container.removeChildAt( 0 );	
			}
			
			draw();
		}
		
		protected function draw():void
		{
			_randomized.length = 0;
			
			var flipString:String;
			var i:int;
			var index:int;
			var lineIndexes:Array = [];
			for  ( i = 0 ; i < NLINE ; i++ )
				lineIndexes.push( i );
			
			while ( lineIndexes.length > 0 )
			{
				index 	= Math.floor(Math.random() * lineIndexes.length);
				i 		= lineIndexes[ index ]; 
				lineIndexes.splice(index, 1);
				
				// FLIP_DELAY 				= int( Math.random() * 300 ); 
				// FLIP_FRAMERATE 			= 10 + int( Math.random() * 20 ); 
				
				var rc:RandomizedChars	= new RandomizedChars( i, FLIP_DELAY, FLIP_FRAMERATE );
				
				rc.addEventListener(TextUpdateEvent.UPDATE, onTextUpdate);
				
				_randomized.push( rc );
				
				flipString = String(_truchetMatrix[ i ].join(""));
				
				rc.flipTo( 0, flipString, FLIP_DURATION );
			}
			
		}
		
		protected function onTextUpdate(event:TextUpdateEvent):void
		{
			var buffer:String 		= event.text;
			var nLin:int 			= event.lineIndex;
			var ln:int 				= buffer.length;
			
			var index:int;
			var j:int = 0;
			var bit:Bitmap;
			
			for ( j = 0 ; j < ln ; j++ )
			{
				index = parseInt(buffer.charAt( j ));
				
				try
				{
					bit = _bitmaps[ nLin ][ j ];
				}
				catch( e:RangeError )
				{
										
					bit = createBitmap( nLin, j );
					_bitmaps[ nLin ][ j ] = bit;
					_container.addChild( bit );
				}

				bit.bitmapData = _patterns[ index ];
			}
		}
		
		protected function createBitmap( nLine:int, nCol:int ):Bitmap
		{
			var buffer:Bitmap 	= new Bitmap();
			
			buffer.x 			= (PATTERN_WIDTH) * nCol;
			buffer.y 			= (PATTERN_HEIGHT) * nLine;
			
			return buffer;
		}
		
		
		
				
	}
}