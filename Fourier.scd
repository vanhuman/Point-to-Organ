
// get suggested ratio and screen dimensions
MyScreens.getSuggestedRatio(presentationScreen: 0, maxNbrX: 8);

(
// set buffersize
Server.local.options.hardwareBufferSize_(1024); ("Buffersize set to"+Server.local.options.hardwareBufferSize).postln;

s.waitForBoot {

	// -------------- config variables --------------

	var
	plotTime = 0.02, screenHeight = 0 /*1080*/, playMode = 2, deviation = 0.02, octave = 1 /* 2^octave-2 */,
	numFunds = 5, funds = [48,50,52,53,55,57,59,60].midicps, fund = funds[0], tremoloSpeed = 5, tremoloDepth = 0,
	harm = Array.series(numFunds,1,1), detune = 1.dup(numFunds), mul = { rand(1.0) }.dup(numFunds);

	// -------------- other variables --------------

	var fPlot, fPlay, playSynth = nil, fPost, fDetune;
	var wMain, plotMix, plotIndiv, bMul, bDetune, bSmooth, taskPlay, bPlay, plotMixAvail = nil, plotIndivAvail = nil, sVolume;
	var pOctave, nDetune, bTremolo, pPlayMode;
	var wDummy = Window.new().front.close, scrH = Window.screenBounds.height, scrW = Window.screenBounds.width;
	var smooth = 1.dup(numFunds), volBus = Bus.control(s,1).set(0.5), guiOffset = 0;

	if(screenHeight > 0, { scrH = screenHeight; guiOffset = screenHeight });

	("Harmonic series frequencies:" + (fund * harm * octave).round(1) + "\n").postln;

	// -------------- synthdefs --------------

	SynthDef(\play, {
		arg freq = 120, gate = 1, volBus, vel, att = 0.01, dec = 0.1, sus = 0.5, rel = 0.01, peak = 1,
				tremSpd = tremoloSpeed, tremDp = tremoloDepth;
		var harm2 = NamedControl.kr(\harm2, harm);
		var detune2 = NamedControl.kr(\detune2, detune);
		var mul2 = NamedControl.kr(\mul2, mul);
		var smooth2 = NamedControl.kr(\smooth2, smooth);
		var sig, env, amp;
		amp = SinOsc.kr(ExpRand(1,tremSpd)).range(1-tremDp,1);
		env = EnvGen.kr( Env.adsr(att,dec,sus,rel,peak), gate, doneAction:2 );
		sig = Splay.ar( SinOsc.ar(freq * harm2 * detune2, mul: mul2 * smooth2 ) );
		sig = sig * env * In.kr(volBus,1) * vel * amp;
		Out.ar(0, sig);
	}).add;

	s.sync;

	// -------------- functions --------------

	fPost = {
		("Octave:"+octave).postln;
		("Fundamental:"+(fund*octave).round(1)).postln;
		("Deviation:"+deviation).postln;
		("Multitudes:"+mul.round(0.01)).postln;
		("Detune:"+detune.round(0.001)).postln;
		("Smooth:"+smooth.round(0.01)).postln;
		"".postln;
	};

	fPlot = { arg mode = \init;
		if(mode != \init, {
			if(plotMixAvail.notNil, { plotMix.parent.close });
			if(plotIndivAvail.notNil, { plotIndiv.parent.close });
		});
		if(mode != \close, {
			plotMix = {  Mix.ar( SinOsc.ar(fund * harm * detune * octave, mul: mul * smooth ) ) }.plot(plotTime,
				bounds: Rect(20,scrH-44-200-10-guiOffset,800,200)
			);
			plotMix.setProperties(\gridOnX, false, \gridOnY, false);
			{
				plotMixAvail = 1;
				plotMix.parent.onClose = {plotMixAvail = nil};
				plotMix.parent.name = "Mix";
			}.defer(0.1);
			if(numFunds > 1, {
				plotIndiv = {  SinOsc.ar(fund * harm * detune * octave, mul: mul * smooth) }.plot(plotTime,
					bounds: Rect(20,20-guiOffset,800, scrH-44-260)
				);
				plotIndiv.setProperties(\gridOnX, false, \gridOnY, false);
				{
					plotIndivAvail = 1;
					plotIndiv.parent.onClose = {plotIndivAvail = nil} }.defer(0.1);
				plotIndiv.parent.name = "Components";
			});
		});
	};

	fPlay = [
		{
			var steps = Array.fill(rrand(3,6), { [0.1,0.4,0.6,1].wchoose([0.3,0.3,0.2,0.2]) });
			var fundsSel = [48,50,51,53,55,56, 58].scramble.midicps, fundSel;
			inf.do { |index|
				fundSel = fundsSel[index%fundsSel.size] * octave;
				if(playSynth.notNil, { playSynth.release; playSynth = nil; });
				playSynth = Synth(\play, [
					\freq,fundSel,\harm2,harm,\detune2,detune,\mul2,mul,\smooth2,smooth,\volBus,volBus.index,
					\vel,rrand(0.7,1.0),\tremSpd,tremoloSpeed*3,\tremDp,tremoloDepth
				]);
				steps[index%(steps.size)].wait;
			}
		},
		{
			var fundsSel = [48,50,51,53,55,56, 58].scramble.midicps, fundSel;
			inf.do { |index|
				fundSel = fundsSel[rand(fundsSel.size)] * octave;
				if(playSynth.notNil, { playSynth.release; playSynth = nil; });
				playSynth = Synth(\play, [\freq,fundSel,\harm2,harm,\detune2,detune,\mul2,mul,\smooth2,smooth,\volBus,volBus.index,
					\vel,rrand(0.7,1.0),\tremSpd,tremoloSpeed,\tremDp,tremoloDepth,
					\att,0.7,\dec,0,\sus,1,\rel,1, \peak,0.5
				]);
				rrand(1.9,2.2).wait;
			}
		},
		{
			var fundSel = 48.midicps * octave;
			inf.do { |index|
				if(playSynth.notNil, { playSynth.release; playSynth = nil; });
				playSynth = Synth(\play, [
					\freq,fundSel,\harm2,harm,\detune2,detune,\mul2,mul,\smooth2,smooth,\volBus,volBus.index,
					\vel,rrand(0.7,1.0),\tremSpd,tremoloSpeed*3,\tremDp,tremoloDepth
				]);
				3.wait;
				if(playSynth.notNil, { playSynth.release; playSynth = nil; });
				0.5.wait;
			}
		}
	];

	fDetune = { arg mode;
		case
		{ mode == 0 } { detune = 1.dup(numFunds) }
		{ mode == 1 } { detune = [1] ++ { rrand(1-deviation,1+deviation) }.dup(numFunds-1) }
		;
	};

	// -------------- GUI --------------

	wMain = Window("Additive Synth", Rect(850, scrH-44-200-10-guiOffset,410,200));

	bMul = (SmoothButton(wMain, Rect(10,10,90,30))
		.border_(1).radius_(2).canFocus_(false).states_([["New Sound"]]).font_(Font("Avenir",12))
		.action_({
			if(numFunds == 1, { mul = [0.5] }, { mul = { rand(1.0) }.dup(numFunds) });
			fDetune.value(bDetune.value);
			fPlot.value(\refresh);
			fPost.value;
		})
	);

	bPlay = (SmoothButton(wMain, Rect(110,10,90,30))
		.border_(1).radius_(2).canFocus_(false).states_([["Play"],["Stop",Color.black, Color.green]]).font_(Font("Avenir",12))
		.action_({ |button|
			if(button.value == 1, {
				taskPlay = Task(fPlay[playMode]).start;
				"playing".postln;
			}, {
				taskPlay.stop;
				"stopped".postln;
				if(playSynth.notNil, { playSynth.release; playSynth = nil; });
			});
		})
	);

	pOctave = (PopUpMenu(wMain, Rect(210,10,90,30))
		.font_(Font("Avenir",12)).canFocus_(false)
		.items_(["octave -2","octave -1","octave 0","octave +1","octave +2"])
		.action_({ |p|
			octave = 2**(p.value-2);
			if(bPlay.value == 1, { bPlay.valueAction_(0); bPlay.valueAction_(1); });
			fPlot.value(\refresh);
			fPost.value;
		})
	);

	pPlayMode = (PopUpMenu(wMain, Rect(310,10,90,30))
		.font_(Font("Avenir",12)).canFocus_(false)
		.items_(["playMode 1","playMode 2","playMode 3"])
		.action_({ |p|
			playMode = p.value;
			if(bPlay.value == 1, { bPlay.valueAction_(0); bPlay.valueAction_(1); });
			("PlayMode set to" + playMode).postln;
		})
	);

	bDetune = (SmoothButton(wMain, Rect(10,50,90,30))
		.border_(1).radius_(2).canFocus_(false).states_([["Detune"],["Detune",Color.black, Color.green]]).font_(Font("Avenir",12))
		.action_({ |button|
			fDetune.value(button.value);
			fPlot.value(\refresh);
			fPost.value;
		})
	);

	nDetune = (SmoothNumberBox(wMain, Rect(110,50,90,30))
		.border_(1).radius_(2).font_(Font("Avenir",12)).align_(\center)
		.clipLo_(0.01).clipHi_(0.5).value_(deviation).allowedChars_(".1234567890").step_(0.01).scroll_(false)
		.action_({ |number|
			deviation = number.value;
			fDetune.value(bDetune.value);
			("Deviation set to" + deviation).postln;
			if(bPlay.value == 1, { bPlay.valueAction_(0); bPlay.valueAction_(1); });
			fPlot.value(\refresh);
			fPost.value;
		})
	);

	bSmooth = (SmoothButton(wMain, Rect(210,50,90,30))
		.border_(1).radius_(2).canFocus_(false).font_(Font("Avenir",12))
		.states_([["Flat"],["Smooth",Color.black, Color.green],["More Smooth",Color.black, Color.green(0.9)]])
		.action_({ |button|
			case
			{ button.value == 0 } { smooth = 1.dup(numFunds) }
			{ button.value == 1 } { smooth = (1, (1 - (1/numFunds)) .. (1/numFunds)) }
			{ button.value == 2 } { smooth = ((1, (1 - (1/numFunds)) .. (1/numFunds)).squared) }
			;
			fPlot.value(\refresh);
			fPost.value;
		})
	);

	bTremolo = (SmoothButton(wMain, Rect(310,50,90,30))
		.border_(1).radius_(2).canFocus_(false).font_(Font("Avenir",12))
		.states_([["Tremolo"],["Tremolo",Color.black, Color.green]])
		.action_({ |button|
			if(button.value == 1, { tremoloDepth = 0.4 }, { tremoloDepth = 0 } );
		})
	);

	sVolume = (SmoothSlider(wMain, Rect(10,150,210,30))
		.border_(1).canFocus_(false).string_("      Volume").value_(0.5).knobSize_(0.1).align_(\left).font_(Font("Avenir",12))
		.hilightColor_(Color.green).background_(Color.green.alpha_(0)).knobColor_(Color.black).borderColor_(Color.grey(0.4))
		.action_({ |slider|
			volBus.set(slider.value);
		})
	);


	// -------------- initialize --------------

	pOctave.valueAction_(log2(octave) + 2);
	pPlayMode.value_(playMode);
	fPost.value;
	wMain.front;
	wMain.onClose = {
		fPlot.value(\close);
		taskPlay.stop;
		if(playSynth.notNil, { playSynth.release });
	};

}
)

