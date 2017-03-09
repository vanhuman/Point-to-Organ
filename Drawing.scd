
(
var fDrawBox;
var tTitle, tText;
var yOffset = 0;
var text = "Point-to-Line is a research into the movement from discreet to continuous in sound and image, and at the same time an exercise in restriction, pulse and color. Point-to-Line is inspired by Angela Bulloch’s work 'Macroworld: One Hours3 and Canned', focussing on the idea of de-contextualizing moving-image pixels through extreme amplification, extending this into sound and then re-contextualizing this, recreating purpose.";

w = Window("",Rect(10,10,1255,500)).background_(Color.white);


fDrawBox = { arg x,y,s,n;
	var space = if(n==1, {5},{5/(n-1)});
	x = x + 2; y = y + 2 + yOffset; s = s - space;
	Pen.moveTo(x@y); Pen.lineTo((x+s)@y);
	Pen.lineTo((x+s)@(y+s)); Pen.lineTo(x@(y+s));
	Pen.fillColor = [Color.blue, Color.green, Color.red, Color.rand, Color.black, Color.yellow].choose;
	if(n==1, {Pen.fillColor = Color.blue(rrand(0.8,1))});
	Pen.perform(\fill);
};

tTitle = (StaticText(w,Rect(626,100 + yOffset,700,100))
	.font_(Font("Avenir",107)).stringColor_(Color.black).string_("Point-to-Line")
);

// tText = (StaticText(w,Rect(635,300,600,100))
// 	.font_(Font("Avenir",12)).stringColor_(Color.black).string_(text)
// );

w.drawFunc_({
	var size = 200, sizeSub = 200, space = 0, nbr, offset = 0, nbrBlox;

	// lines
	forBy(0,7,1,{ arg i;
		nbr = 2**i;
		sizeSub = size/nbr;
		nbrBlox = (2**(i-1))+1;
		if(i==7, { nbrBlox = nbrBlox * 2 });
		forBy(1,nbrBlox,1, { arg j;
			// x = 10 + (size*i) + (5*i) + ((j-1) * sizeSub); y = (w.bounds.height-sizeSub)/2;
			x = 10 + offset + (5*i); y = (w.bounds.height-sizeSub)/2;
			fDrawBox.value(x,y,sizeSub,nbr);
			offset = offset + sizeSub;
		});
	});

	// cubes
	// forBy(0,7,1,{ arg i;
	// 	nbr = 2**i;
	// 	sizeSub = size/nbr;
	// 	nbrBlox = (2**(i-1))+1;
	// 	// if(i==7, { nbrBlox = nbrBlox * 2 });
	// 	forBy(1,nbrBlox,1, { arg j;
	// 		forBy(1,nbrBlox, 1, {arg k;
	// 			x = 10 + offset + (5*i);
	// 			y = (w.bounds.height-sizeSub)/2 + ((k-1) * sizeSub);
	// 			fDrawBox.value(x,y,sizeSub,nbr);
	// 		});
	// 		offset = offset + sizeSub;
	// 	});
	// });

	// cubes 2
	// forBy(0,4,1,{ arg i;
	// 	forBy(1,2**i,1, { arg j;
	// 		nbr = 2**i;
	// 		sizeSub = size/nbr;
	// 		forBy(1,2**i, 1, {arg k;
	// 			x = 20 + ((size+20)*i) + ((j-1) * sizeSub); y = (w.bounds.height-size)/2 + ((k-1) * sizeSub);
	// 			fDrawBox.value(x,y,sizeSub,nbr);
	// 		});
	// 	});
	// });

});

w.view.mouseDownAction_({
	w.refresh;
});
w.view.keyDownAction_({
	arg view, char, modifiers, unicode, keycode, key;
	if(keycode == 1, {
		var img = Image.fromWindow(w);
		img.write(Document.dir++"Data/Point-to-Line/img/Point-to-Line"++Date.getDate.stamp++".png");
	})
});
w.onClose = {
	t.stop;
};
w.front;

t = Task({
	inf.do {
		{ w.refresh }.defer;
		0.1.wait;
	}
}).start;

)