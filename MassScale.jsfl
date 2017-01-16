/*
* Created by Lachhh, from Berzerk Studio
* www.LachhhAndFriends.com
*/


var theScaleX = Number(prompt("Enter Scale", "0.5"));
var theScaleY = theScaleX; 
var theScaleFont = (theScaleX == theScaleY ? theScaleY : 1);
var allDone = new Array();
var isInCaca = false;
function Init() {
	fl.outputPanel.clear();
	var aItems = fl.getDocumentDOM().library.items;
	
	/*var doc = fl.getDocumentDOM();
	var results = fl.findObjectInDocByType("shape", doc);
	for (var i = 0; i < results.length; i++) 
	{
		if ( results[i].obj.isGroup )
		{
			doc.selection = [results[i].obj];
			doc.unGroup();
		}
	}
*/
	for (var i = 0 ; i < aItems.length ; i++) {
		var libItem = aItems[i];
		//fl.outputPanel.trace(  libItem.name);
		isInCaca = (libItem.name.indexOf("RoundCompletePanel") != -1);
		if((libItem.itemType == "movie clip")/* && libItem.name.indexOf("RoundCompletePanel") == -1*/) {
			fl.getDocumentDOM().library.editItem(libItem.name);
			SearchTimeLine(libItem.timeline);
		} 
	}
}


function SearchTimeLine(t) {
	dynamicTextNum = 0;
	
	for (var i = 0 ; i < t.layers.length ; i++) {
		var l = t.layers[i];
		//fl.getDocumentDOM().getTimeline().setSelectedLayers(i);
		SearchLayer(l);
	}
}

function SearchLayer(l) {
	for (var j = 0 ; j < l.frames.length ; j++) {
		var f = l.frames[j];
		var locked = l.locked ;
		var visible = l.visible ;
		l.locked = false;
		l.visible = true;
		fl.getDocumentDOM().getTimeline().setSelectedFrames(j,j);
		SearchFrame(f);
		l.visible = visible ;
		l.locked = locked ;
		j += f.duration-1;
		//trace(f.duration);
	}
}
function trace(msg) {
	fl.outputPanel.trace(msg);
}

function SearchFrame(f) {
	fl.getDocumentDOM().selectNone();
	var selectArray = new Array();
	
	for (var k = 0 ; k < f.elements.length ; k++) {
		e = f.elements[k];
		if(e.elementType == "shape") {			
			if(e.isGroup) {
				fl.getDocumentDOM().selection = [e];
				if(fl.getDocumentDOM().selection.length <= 0) {
					continue; 
				}
				fl.getDocumentDOM().unGroup();
				fl.getDocumentDOM().selectNone();
				k = -1 ; 
			}
		}
	}
	
	for (var k = 0 ; k < f.elements.length ; k++) {
		e = f.elements[k];
		if(e.elementType == "instance") {
				
			e.x *= theScaleX;
			e.y *= theScaleY;
	
		} else if(e.elementType == "text") {
	
			var oldsize = e.getTextAttr("size");
			
			e.setTextAttr("size", oldsize * theScaleFont);
			e.x *= theScaleFont;
			e.y *= theScaleFont;
			//e.y += (e.height*(theScaleFont*theScaleFont));
			fl.getDocumentDOM().selection = [e];
			//fl.outputPanel.trace(e.width*theScaleFont + "/" + e.height*theScaleFont);
			fl.getDocumentDOM().setTextRectangle({left:0, top:0, right:e.width*theScaleFont, bottom:e.height*theScaleFont}) 
			fl.getDocumentDOM().selectNone();
		}
	}
	//trace("frame" + "/" + f.elements);
	for (var k = 0 ; k < f.elements.length ; k++) {
		e = f.elements[k];
		fl.getDocumentDOM().selectNone();
		fl.getDocumentDOM().selection = [e];
		
		if(fl.getDocumentDOM().selection.length <= 0) {
			//trace("skip");
			continue; 
		}
		
		//fl.outputPanel.trace(e.elementType);
		if(e.elementType == "shape") {
			var w = e.width;
			var h = e.height;
			
			//fl.outputPanel.trace("scaling" + "/" + e.isGroup + "/" + e.isDrawingObject + "/" + e.members + "/" + fl.getDocumentDOM().selection);
			if(!e.isGroup) {
				
				try {
					fl.getDocumentDOM().clipCut();
					//return ;
					e.scaleX /= theScaleX;
					e.scaleY /= theScaleY;
					e.x /= theScaleX;
					e.y /= theScaleY;
					
					fl.getDocumentDOM().clipPaste(true);
					//fl.getDocumentDOM().selectNone();
					e.scaleX *= theScaleX;
					e.scaleY *= theScaleY;
					e.x *= theScaleX;
					e.y *= theScaleY;
				} catch (e) {
					
				}
			} 
			/*else {
				fl.getDocumentDOM().selection = [e];
				fl.getDocumentDOM().unGroup();
				fl.getDocumentDOM().selectNone();
			}*/
		} 
	}
}

Init();