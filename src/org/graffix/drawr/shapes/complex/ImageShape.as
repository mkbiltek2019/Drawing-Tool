package org.graffix.drawr.shapes.complex
{
	import org.graffix.drawr.view.editors.ImagesGallery;
	import org.graffix.drawr.events.ImageShapeEvent;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import org.graffix.drawr.shapes.BaseShape;

	public class ImageShape extends BaseShape
	{
		public static const IMAGE_SHAPE:int = 11;
		public function ImageShape()
		{
			super();
			_shapeDrawData.type = IMAGE_SHAPE;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			_image= new Image();
			_image.smoothBitmapContent = true;
			addChild(_image);
		}
		
		public var empty:Boolean = true;
		private var _image:Image;
		public function insertImage(imageSource:Class, width:Number, height:Number):void
		{
			_image.source = imageSource;
			_image.width = width;
			_image.height = height;
			setTimeout(resizeImageToFullSize, 200);
			empty = _image.source ? false : true;
		}
		
		private function resizeImageToFullSize():void
		{
			_image.width = _image.content.loaderInfo.width
			_image.height = _image.content.loaderInfo.height;
		}
		
		override public function destroy():void
		{
			super.destroy();
			removeChild(_image);
			_image.source = null;
			_image = null;
		}
	}
}