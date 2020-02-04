
import js.html.UListElement;
import js.Syntax;
import om.Browser;
import om.Browser.document;
import om.Browser.window;
import om.color.palette.HSLUV;

class App {

	static var shadesElement : UListElement;
	static var colorsElement : UListElement;
	static var colors : Array<Array<String>>;

	static function generatePalette() {

		shadesElement.innerHTML = colorsElement.innerHTML = '';

		colors = HSLUV.generate();

		function createColorElement( color : String ) {
			var li = document.createLIElement();
			li.style.background = color;
			var input = document.createInputElement();
			input.type = "text";
			input.classList.add( 'color' );
			input.value = color;
			input.style.width = '100px';
			//untyped input.style.mixBlendMode = 'multiply';
			input.onclick = function(e){
				e.preventDefault();
				e.stopPropagation();
				input.select();
				//e.setSelectionRange(0,7);
				//var range = document.createRange();
				//range.moveToElementText(e);
				// range.select();
				//e.setSelectionRange(2, 5);
			}
			li.appendChild( input );
			return li;
		}

		for( color in colors[1] ) {
			shadesElement.appendChild( createColorElement( color ) );
		}
		for( color in colors[0] ) {
			colorsElement.appendChild( createColorElement( color ) );
        }
	}

	static function exportGimpPalette() {
		var gplColors = new Array<om.color.GimpPalette.Color>();
		for( i in 0...colors[1].length ) {
			var str = colors[1][i];
			var rgb = hexToRgb( str );
			gplColors.push({
				name: 'shade#$i',
				r: rgb[0],
				g: rgb[1],
				b: rgb[2],
			});
		}
		for( i in 0...colors[0].length ) {
			var str = colors[0][i];
			var rgb = hexToRgb( str );
			gplColors.push({
				name: 'color#$i',
				r: rgb[0],
				g: rgb[1],
				b: rgb[2],
			});
		}
		var gpl = new om.color.GimpPalette( 'husl', 1,gplColors );
		Browser.saveTextFile( 'husl', gpl.toString() );
	}

	static function hexToRgb( hex : String ) : Array<Int> {
		var ereg = ~/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i;
		if( ereg.match( hex ) ) {
			return [
				Syntax.code( "parseInt({0},16)", ereg.matched(1) ),
				Syntax.code( "parseInt({0},16)", ereg.matched(2) ),
				Syntax.code( "parseInt({0},16)", ereg.matched(3) ),
			];
		}
		return null;
	}

	static function main() {

    	window.onload = function(){
			
			var app = document.body.querySelector('.husl');

			var palette = app.querySelector('.palette');
			shadesElement = cast palette.querySelector('ul.shades');
			colorsElement = cast palette.querySelector('ul.colors');
			
			var control = app.querySelector('.control');
			var btnGenerate = control.querySelector('button[name="generate"]');
			btnGenerate.onclick = function(e) {
				generatePalette();
			}
			var btnExport = control.querySelector('button[name="export"]');
			btnExport.onclick = function(e) {
				exportGimpPalette();
			}

			generatePalette();

			window.onkeydown = e -> {
				switch e.keyCode {
				case 69: // E
					exportGimpPalette();
				default:
					generatePalette();
				}
			}
    	}
    }
}
