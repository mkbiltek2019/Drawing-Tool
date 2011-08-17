package com.graffix.drawingTool.view.drawing.managers
{
	import com.graffix.drawingTool.view.drawing.events.DrawAreaEvent;
	import com.graffix.drawingTool.view.drawing.events.ImageShapeEvent;
	import com.graffix.drawingTool.view.drawing.events.ShapeSelectEvent;
	import com.graffix.drawingTool.view.drawing.events.TextEditorEvent;
	import com.graffix.drawingTool.view.drawing.shapes.BaseShape;
	import com.graffix.drawingTool.view.drawing.shapes.complex.EraserShape;
	import com.graffix.drawingTool.view.drawing.shapes.complex.ImageShape;
	import com.graffix.drawingTool.view.drawing.shapes.complex.TextShape;
	import com.graffix.drawingTool.view.drawing.shapes.factory.ShapesFactory;
	import com.graffix.drawingTool.view.drawing.shapes.selection.ISelectable;
	import com.graffix.drawingTool.view.drawing.shapes.selection.SelectTool;
	import com.graffix.drawingTool.view.drawing.view.area.DrawArea;
	import com.graffix.drawingTool.view.drawing.view.editors.ImagesGallery;
	import com.graffix.drawingTool.view.drawing.view.editors.TextEditorWindow;
	import com.graffix.drawingTool.view.drawing.vo.ShapeDrawData;
	
	import flash.geom.Point;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.core.IVisualElement;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class DrawManager
	{
		public function DrawManager(drawArea:DrawArea)
		{
			_drawArea = drawArea;
			_drawArea.addEventListener(DrawAreaEvent.CLICK, onMouseClick );
			_drawArea.addEventListener(DrawAreaEvent.MOVE, onMouseMove );
			_drawArea.addEventListener(DrawAreaEvent.DOWN, onMouseDown );
			_drawArea.addEventListener( DrawAreaEvent.UP, onMouseUp);
			_drawArea.addEventListener(ShapeSelectEvent.SHAPE_SELECT, onShapeSelect);
			_drawArea.addEventListener(TextEditorEvent.TEXT_EDIT, onTextEdit);
			_drawArea.addEventListener(ImageShapeEvent.SHOW_GALLERY, onShowGalleryEvent);
		}
		
		/**
		 * current selected tool id. By default transform tool is selected
		 * Tool draws or creates shapes
		 * */
		private var _selectedTool:int = SelectTool.TRANSFORM_TOOL;
		
		public function get selectedTool():int
		{
			return _selectedTool;
		}
		
		public function set selectedTool(value:int):void
		{
			_selectedTool = value;
			if( selectedShape )
			{
				selectedShape.hideTransformControls();
				currentDrawingShape = null;
				selectedShape = null;
			}
		}
		
		
		private var _drawMode:int = DrawMode.TRANSFROM_MODE;
		
		//
		// --------------- CATCH TOOLS EVENTS-----------------
		//
		protected function onMouseDown(event:DrawAreaEvent):void
		{	
			switch(_selectedTool)
			{
				case SelectTool.TRANSFORM_TOOL:
					//
					//do nothing
					return;
					
				case TextShape.TEXT_SHAPE:
					if(!_textEditorPopuped)
					{
						createShapeToDraw(event.mouseEvent.stageX, event.mouseEvent.stageY);
						showTextEditor();
					}
					return;
					
				case ImageShape.IMAGE_SHAPE:
					if(!_galleryWindowPopuped)
					{
						createShapeToDraw(event.mouseEvent.stageX, event.mouseEvent.stageY);
						showGalleryWindow();
					}
					return;
					
				default:
					createShapeToDraw(event.mouseEvent.stageX, event.mouseEvent.stageY);
					break;
			}
		}
		
		protected function onMouseClick(event:DrawAreaEvent):void
		{
			if(!event.hasShapeUnderClick)
			{
				if(selectedShape && selectedShape.transforming)
				{
					selectedShape.hideTransformControls();
				}
			}
		}
		
		protected function onMouseMove(event:DrawAreaEvent):void
		{
			if(_selectedTool == SelectTool.TRANSFORM_TOOL )
			{
				//
				//do nothing
			}
			else 
			{
				if(currentDrawingShape)
				{
					currentDrawingShape.setPoints( new Point(0,0), currentDrawingShape.globalToLocal( new Point(event.mouseEvent.stageX, event.mouseEvent.stageY )));
					if(_selectedTool == EraserShape.ERASER_SHAPE)
					{
						_drawArea.currentPage.detectObjectsToErase( new Point(event.mouseEvent.stageX, event.mouseEvent.stageY) );
					}
				}
			}
		}
		
		protected function onMouseUp(event:DrawAreaEvent):void
		{
			if(currentDrawingShape && currentDrawingShape.type != TextShape.TEXT_SHAPE && currentDrawingShape.type != ImageShape.IMAGE_SHAPE)
			{
				currentDrawingShape.finishDraw();
				
				currentDrawingShape = null;
				
			}
		}
		
		//
		// -------------- IMAGES GALLERY WINDOW --------------------
		//
		
		private var _galleryWindow:ImagesGallery;
		private var _galleryWindowPopuped:Boolean;
		
		private function showGalleryWindow():void
		{
			if(_galleryWindow)
			{
				PopUpManager.addPopUp( _galleryWindow, _drawArea);
			}
			else
			{
				_galleryWindow = new ImagesGallery();
				_galleryWindow.addEventListener(CloseEvent.CLOSE, onGalleryWindowClose);
				_galleryWindow.addEventListener(ImageShapeEvent.INSERT_IMAGE, onInsertImage);
				PopUpManager.addPopUp( _galleryWindow, _drawArea );
				PopUpManager.centerPopUp( _galleryWindow);
			}
			_galleryWindowPopuped = true;
		}
		
		private function onInsertImage(event:ImageShapeEvent):void
		{
			(currentDrawingShape as ImageShape).insertImage( event.image, event.width, event.height );
		}
		
		private function onGalleryWindowClose(event:CloseEvent):void
		{
			_galleryWindowPopuped = false;
			if( (currentDrawingShape as ImageShape).empty )
			{
				_drawArea.removeChildFromCurrentPage( currentDrawingShape );
			}
			else
			{
				currentDrawingShape.finishDraw();
			}
			currentDrawingShape = null;
		}
		
		private function onShowGalleryEvent(event:ImageShapeEvent):void
		{
			showGalleryWindow();
		}
		
		//
		// -------------- TEXT EDITOR WINDOW -------------------
		//
		
		private var _textEditorPopuped:Boolean;
		
		private var _textEditorWindow:TextEditorWindow;
		
		private function showTextEditor(text:String=null):void
		{
			if(_textEditorWindow)
			{	
				PopUpManager.addPopUp( _textEditorWindow, _drawArea );
			}
			else
			{
				_textEditorWindow = new TextEditorWindow();
				_textEditorWindow.addEventListener(CloseEvent.CLOSE, onTextEditorClose);
				PopUpManager.addPopUp( _textEditorWindow, _drawArea );
				PopUpManager.centerPopUp(_textEditorWindow);
			}
			
			_textEditorPopuped = true;
			if(text)
			{
				_textEditorWindow.setText(text);
			}
		}
		
		private function onTextEdit(event:TextEditorEvent):void
		{
			if( _selectedTool == SelectTool.TRANSFORM_TOOL)
			{
				if(_textEditorPopuped)
				{
					_textEditorWindow.setText(event.text);
				}else
				{
					showTextEditor(event.text);
				}
			}
		}
		
		private function onTextEditorClose(event:CloseEvent):void
		{
			var formattedString:String = TextConverter.export(_textEditorWindow.richTextEditor.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE).toString();
			(selectedShape as TextShape).setText(formattedString);
			_textEditorPopuped = false;
			//currentDrawingShape.finishDraw();
		}
		
		//
		// ---------------------------------------------------
		//
		private var _drawArea:DrawArea;
		
		
		
		[Bindable]
		public var currentDrawingShape:BaseShape;
		private var _startPoint:Point;
		private function createShapeToDraw(stageX:Number, stageY:Number):void
		{
			var tool:BaseShape = ShapesFactory.createTool( _selectedTool );
			_startPoint = new Point(stageX, stageY);
			_startPoint = _drawArea.globalToLocal( _startPoint );
			tool.x = _startPoint.x;
			tool.y = _startPoint.y;
			tool.startDraw();
			_drawArea.addChildToCurrentPage( tool );
			currentDrawingShape = tool;
		}
		
		[Bindable]
		public var selectedShape:ISelectable;
		protected function onShapeSelect(event:ShapeSelectEvent):void
		{
			if(selectedShape)
			{
				selectedShape.hideTransformControls();
			}
			
			selectedShape = event.target as BaseShape;
			//currentDrawingShape = event.target as BaseShape;
			if( _selectedTool == SelectTool.TRANSFORM_TOOL && !selectedShape.transforming )
			{	
				selectedShape.showTransformControls();
			}
		}
		
		/**
		 * Redraws and transforms shape
		 * if shape doesn't exists creates new one and applys all transformation data
		 * */
		public function updateShape(shapeData:ShapeDrawData):void
		{
			if(shapeData)
			{
				var shape:BaseShape = _drawArea.currentPage.getShapeByID(shapeData.shapeID);
				if(shape)
				{
					shape.shapeDrawData = shapeData;
					_drawArea.currentPage.updateElementLayout(shape as IVisualElement);
					if(shape.transforming)
					{
						shape.hideTransformControls();
					}
				}
				else
				{
					shape = ShapesFactory.createTool( shapeData.shapeType );
					shape.id = shapeData.shapeID;
					shape.shapeDrawData = shapeData;
					_drawArea.currentPage.addElement( shape );
				}
				
			}
			
		}
		
		public function eraseShape(shapeID:String):void
		{
			_drawArea.currentPage.removeShapeByID(shapeID);
		}
	}
}