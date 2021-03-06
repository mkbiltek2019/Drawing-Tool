package com.graffix.drawingTool.view.drawing.view.area
{
	import com.graffix.drawingTool.view.drawing.events.DrawAreaEvent;
	import com.graffix.drawingTool.view.drawing.events.EraseEvent;
	import com.graffix.drawingTool.view.drawing.events.LayoutOrderEvent;
	import com.graffix.drawingTool.view.drawing.shapes.BaseShape;
	import com.graffix.drawingTool.view.drawing.shapes.EraserShape;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	
	import mx.controls.Label;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.SolidColorStroke;
	import mx.graphics.codec.PNGEncoder;
	
	import spark.components.BorderContainer;
	import spark.components.NavigatorContent;
	import spark.effects.easing.EaseInOutBase;
	
	public class Page extends NavigatorContent
	{
		public function Page()
		{
			super();
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove );
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(ResizeEvent.RESIZE, onResize);
			addEventListener(EraseEvent.ERASE_EVENT, onEraseEvent);
		}
		
		
		private function onEraseEvent(event:EraseEvent):void
		{
			for(var i:int = 0; i < _objectsToErase.length; ++i)
			{
				removeElement( _objectsToErase[i] );
			}
			event.eraser.destroy();
			removeElement(event.eraser);
			_objectsToErase.length = 0;
		}
		
		private var _objectsToErase:Vector.<IVisualElement> = new Vector.<IVisualElement>();;
		public function detectObjectsToErase(stageMouseCoord:Point):void
		{
			//_objectsToErase = new Vector.<IVisualElement>();
			stageMouseCoord = globalToLocal( stageMouseCoord);
			var eraserRect:Rectangle = new Rectangle( stageMouseCoord.x - 20, stageMouseCoord.y - 20, 40, 40);
			var length:int = numElements - 1;
			var i:int = 1;
			var visElement:IVisualElement;
			var objRect:Rectangle;
			while(i < length)
			{
				visElement = getElementAt( i );
				if(!(visElement as BaseShape).toRemove)
				{
					objRect = (visElement as DisplayObject).getBounds( this );
					if(eraserRect.intersects(objRect))
					{
						_objectsToErase[_objectsToErase.length] = visElement;
						(visElement as BaseShape).toRemove = true;
					}
				}
				++i;
			}
		}
		
		private function getBitmapData(source:DisplayObject):BitmapData
		{
			var bdata:BitmapData = new BitmapData(source.width, source.height);
			bdata.draw( source );
			return bdata;
		}
		
		
		private var _pageLabel:Label;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(_redrawBackground)
			{
				drawBackground(true);
			}
			
		}
		
		override protected function createChildren():void
		{
			_background = new UIComponent();
			addElement(_background);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			var hasShape:Boolean;
			var objects:Array = getObjectsUnderPoint(new Point(event.stageX, event.stageY));
			//dispatchEvent( new DrawAreaEvent(DrawAreaEvent.CLICK, event, hasShape));
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			dispatchEvent( new DrawAreaEvent(DrawAreaEvent.MOVE, event));
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			dispatchEvent( new DrawAreaEvent(DrawAreaEvent.DOWN, event));
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			dispatchEvent( new DrawAreaEvent(DrawAreaEvent.UP, event));
		}
		
		private var _redrawBackground:Boolean;
		private var _background:UIComponent;
		private function onResize(event:ResizeEvent):void
		{
			_redrawBackground = true;
			invalidateDisplayList();
		}
		
		private function drawBackground(transparent:Boolean):void
		{
			_background.graphics.clear();
			_background.graphics.beginFill(0xFFFFFF, transparent ? 0 : 1);
			_background.graphics.drawRect(0,0,width,height);
		}
		
		private var _filereference:FileReference;
		public function makeScreenshot():void
		{
			drawBackground(false);
			var snapShot:ImageSnapshot = ImageSnapshot.captureImage(this);
			drawBackground(true);
			_filereference = new FileReference();
			_filereference.save(snapShot.data, label + "_snapshot.png" );
		}
		
		public function clear():void
		{
			while(numElements > 1)
			{
				var shape:IVisualElement = getElementAt(1);
				shape.removeEventListener(LayoutOrderEvent.CHANGE_LAYOUT_ORDER, onLayoutEvent);
				removeElementAt(1);
			}
		}
		
		public function destroy():void
		{
			clear();
		}
		
		private function onLayoutEvent(event:LayoutOrderEvent):void
		{
			var shape:IVisualElement = event.shape;
			var shapeIndex:int = getElementIndex( shape );
			if(event.direction == "up")
			{
				if( shapeIndex < numElements - 1)
				{
					shapeIndex++;
					setElementIndex(shape, shapeIndex);
				}
			}else
			{
				if(shapeIndex > 1)
				{
					shapeIndex--;
					setElementIndex(shape, shapeIndex);
				}
			}
		}
		
		
		override public function addElement(element:IVisualElement):IVisualElement
		{
			element.addEventListener(LayoutOrderEvent.CHANGE_LAYOUT_ORDER, onLayoutEvent);
			return super.addElement(element);
		}
		
		override public function removeElement(element:IVisualElement):IVisualElement
		{
			element.removeEventListener(LayoutOrderEvent.CHANGE_LAYOUT_ORDER, onLayoutEvent);
			return super.removeElement(element);
		}
		
		
		
	}
}