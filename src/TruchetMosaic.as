package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	
	[SWF(frameRate="60", heightPercent="100", widthPercent="100", backgroundColor=0x000000)]
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
		
		
		public function TruchetMosaic()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align	 	= StageAlign.TOP_LEFT;

			
			
			_patterns 		= new Vector.<BitmapData>();
			_bitmaps		= new Vector.<Vector.<Bitmap>>();
			_randomized		= new Vector.<RandomizedChars>();
			_truchetMatrix 	= new Vector.<Vector.<int>>();

			
			_container		= new Sprite();
			_container.x 	= 50; 
			_container.y 	= 50; 
			this.addChild( _container );
		
			
			
			_snapshotContainer 		= new Sprite();
			_snapshotContainer.x 	= stage.stageWidth - 600 ;
			_snapshotContainer.y 	= 50;
			this.addChild( _snapshotContainer );

			
			_snapshotTimer 	= new Timer( 400 );
			_snapshotTimer.addEventListener(TimerEvent.TIMER, takeSnapshot);
			
			
			
			_iterationTimer = new Timer( TIMER_BASE );
			_iterationTimer.addEventListener(TimerEvent.TIMER, iterate);
			_iterationTimer.start();
			iterate(null);
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			switch( event.keyCode )
			{
				case Keyboard.UP:
						
					_snapshotContainer.y -= 100;
					
					break;
				case Keyboard.DOWN:
					
					_snapshotContainer.y += 100;
					
					break;
			}
		}
		
		protected function takeSnapshot(event:TimerEvent):void
		{
			if( _snapshotTimer.currentCount > 120 )
			{
				_snapshotTimer.removeEventListener(TimerEvent.TIMER, takeSnapshot);
				_snapshotTimer.stop();
			}
			
			var scale:Number 		= 0.25;
			var w:Number 			= (NCOL * PATTERN_WIDTH + 100) * scale;
			var h:Number			= (NLINE * PATTERN_HEIGHT + 100) * scale;
			
			var buffer:BitmapData 	= new BitmapData( w, h, false, 0xFFFFFF );
			var m:Matrix 			= new Matrix();
			m.translate( 50, 50 );
			m.scale( scale, scale );
			buffer.draw( _container, m, null, null, null, true );

			var snapshot:Bitmap 	= new Bitmap( buffer );
			snapshot.x 				= SNAPSHOT_OFFSET_X; 
			snapshot.y 				= SNAPSHOT_OFFSET_Y; 
			snapshot.alpha 			= .05;
			_snapshotContainer.addChild( snapshot );
			
			if ( _snapshotTimer.currentCount % 10 == 0)
			{
				var iterationLabel:TextField 		= new TextField();
				iterationLabel.x 					= SNAPSHOT_OFFSET_X;
				iterationLabel.y 					= SNAPSHOT_OFFSET_Y + h + 5;
				iterationLabel.width				= 10;
				iterationLabel.autoSize				= TextFieldAutoSize.RIGHT;
				iterationLabel.defaultTextFormat	= new TextFormat( "arial", 10, 0xEFFCFF );
				iterationLabel.text					= String("Iteration " + _snapshotTimer.currentCount/10);
				_snapshotContainer.addChild( iterationLabel );
				
				if ( LEFT % 2 == 0 )
				{
					SNAPSHOT_OFFSET_X = w + 50;
				}
				else
				{
					SNAPSHOT_OFFSET_X 	= 0;
					SNAPSHOT_OFFSET_Y  += h + 50;

					var destY:int = -_snapshotContainer.height + 100;
					TweenLite.to(_snapshotContainer, 0.5, {y: destY, ease:Sine.easeInOut});
				}
				
				LEFT++;	
			}
		}
		
		protected function iterate(event:TimerEvent):void
		{
			if ( NCOL == 128 )
			{
				_iterationTimer.removeEventListener(TimerEvent.TIMER, iterate);
				
				return;
			}
			else
			{
				
 				if( NCOL == 0 && NLINE == 0 )
				{
					NCOL 	= 1;
					NLINE 	= 1;
				}
				else
				{
					NCOL 	*= 2;
					NLINE	*= 2;

					if ( NCOL == 128 )
					{
						FLIP_DURATION = 4;
					}
				}
			}
			
			step();
			
			FLIP_DURATION += FLIP_INCREMENT;
			
			_iterationTimer.reset();
			_iterationTimer.delay = TIMER_BASE + 1000 * FLIP_DURATION
			_iterationTimer.start();
			
			if ( !_snapshotTimer.running )
				_snapshotTimer.start();
		}
		
		private function step():void 
		{
			var sizeRef:Number 	= Math.min( stage.stageWidth, stage.stageHeight ) - 100;
			
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