package {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class RandomizedChars extends EventDispatcher
	{

		private var _goalString:String;
		private var _currentLength:int;
		private var _matchedChars:int;
		private var _duration:Number;
		private var _startTime:Number;
		private var _animationTimer:Timer;
		private var _lineIndex:int;
		private var _timerDelay:Number;
		
		private var firstTime:Boolean = true;
		private var FRAMERATE:Number = 10;
		private const _charSet:String = "01234567";
		
		public function RandomizedChars( lineIndex:int, timerDelay:Number, pFramerate:Number )
		{
			_lineIndex	= lineIndex;
			_timerDelay = timerDelay;
			FRAMERATE 	= pFramerate; 
		}

		public function flipTo( pCurrentLength:int, pGoalString:String, pDuration:Number ):void 
		{
			_goalString = pGoalString;
			_duration 	= pDuration;
			
			_matchedChars = 0;
			_currentLength = pCurrentLength;

			_animationTimer = new Timer( _timerDelay, 1 );
			_animationTimer.addEventListener( TimerEvent.TIMER_COMPLETE , onFirstComplete );
			_animationTimer.start();
		}
		
		protected function onFirstComplete(event:TimerEvent):void
		{
			_animationTimer.removeEventListener( TimerEvent.TIMER_COMPLETE , onFirstComplete );
			_animationTimer.addEventListener( TimerEvent.TIMER , updateText );
			
			_animationTimer.delay 		= FRAMERATE
			_animationTimer.repeatCount = Math.round( ( 1000 * _duration ) / FRAMERATE );
			
			_animationTimer.reset();
			_animationTimer.start();
		}
		
		private function randomChar():String
		{
			return _charSet.charAt( Math.floor( Math.random() * _charSet.length ) ) ;
		}

		private function updateText( e:TimerEvent ):void 
		{
			var nText:String = "";

			if( _animationTimer.currentCount > 0.1 * _animationTimer.repeatCount ) 
			{
				_matchedChars = Math.floor( _goalString.length * _animationTimer.currentCount / _animationTimer.repeatCount );
			}

			if( _currentLength != _goalString.length )
			{
				var inc:Number = ( _goalString.length - _currentLength ) * 0.01;
				if( inc > 2 ) inc = 2;
				else if ( inc < -2 ) inc = -2;
				_currentLength += ( inc > 0 ) ? Math.ceil(inc) : Math.floor(inc);
			}

			for( var i:int = 0; i < _matchedChars; i++ )
			{
				nText += _goalString.charAt( i );
			}

			for( i = _matchedChars ; i < _currentLength ; i++ )
			{
				nText += randomChar();
			}
			
			// Notify
			var ev:TextUpdateEvent = new TextUpdateEvent( TextUpdateEvent.UPDATE );
			ev.text = nText;
			ev.lineIndex = _lineIndex
			dispatchEvent( ev );
		}
		
		
		
		

	}
	
}