package
{
	import flash.events.Event;
	
	public class TextUpdateEvent extends Event
	{
		
		public static var UPDATE:String = "update";
		public var text:String = "";
		public var lineIndex:int;
		
		public function TextUpdateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			
		}
	}
}