/*
Robert van Heumen (c) 2017
Inspired by the Pixel Boxes of the installation 'Macroworld: One Hours3 and Canned 2002' by Angela Bulloch
http://www.depont.nl/collectie/kunstenaars/kunstenaar/werk_id/953/kunstenaar/bulloch-1/
http://www.gms.be/index.php?content=artist_detail&id_artist=11
*/

// get suggested ratio and screen dimensions
MyScreens.getSuggestedRatio(presentationScreen: 1, maxNbrX: 8);

/*
registers Sauer
pedalen: 16’ contrabass, subbass
manuaal 1: wit: flute harmonique, dulciana / roze: aeoline, fugara
manuaal 2: paars: rohrfote / geel: violine, traversflote, flautino
*/


(
// set buffersize
s.options.hardwareBufferSize_(1024); ("Buffersize set to"+Server.local.options.hardwareBufferSize).postln;

// set MIDI output device
~midiOutDevice = "MUL";

s.waitForBoot {

	// ------- configuration variables ------------------------------------------------------------------------------------

	// var // 1280 x 1024 (5 x 4) as presentation screen placed below main screen
	// screenWidth = 1280, screenHeight = 1024, nbrX = 7, nbrY = 5, nbrXalt = 50, nbrYalt = 40, topSubtract = screenHeight, leftSubtract = 0;

	// var // 1280 x 1024 (5 x 4) as presentation screen on main screen
	// // screenWidth = 1280, screenHeight = 1024, nbrX = 5, nbrY = 4, nbrXalt = 50, nbrYalt = 40, topSubtract = 0, leftSubtract = 0;
	// screenWidth = 1280, screenHeight = 700, nbrX = 7, nbrY = 4, nbrXalt = 42, nbrYalt = 24, topSubtract = -30, leftSubtract = -10;

	// var // 1280 x 800 (laptop) (8 x 5) as presentation screen placed below main screen
	// screenWidth = 1280, screenHeight = 800, nbrX = 8, nbrY = 5, nbrXalt = 48, nbrYalt = 30, topSubtract = screenHeight, leftSubtract = 0;
	// // screenWidth = 1280, screenHeight = 800, nbrX = 7, nbrY = 4, nbrXalt = 35, nbrYalt = 20, topSubtract = screenHeight, leftSubtract = 0;

	// var // 1280 x 800 (laptop) (8 x 5) as presentation screen on main screen
	// // screenWidth = 1280, screenHeight = 800, nbrX = 8, nbrY = 5, nbrXalt = 48, nbrYalt = 30, topSubtract = 0, leftSubtract = 0;
	// // smaller version:
	// screenWidth = 1280, screenHeight = 450, nbrX = 7, nbrY = 4, nbrXalt = 42, nbrYalt = 24, topSubtract = -50, leftSubtract = 200;

	// var // 1920 x 1080 (16 x 9) as presentation screen placed below main screen 7 x 4 ------ beamer STEIM
	// screenWidth = 1920, screenHeight = 1080, nbrX = 7, nbrY = 4, nbrXalt = 70, nbrYalt = 40, topSubtract = screenHeight, leftSubtract = 0;

	var // 1024 x 768 (8 x 5) as presentation screen placed below main screen ----- beamer Orgelpark
	screenWidth = 1024, screenHeight = 768, nbrX = 8, nbrY = 5, nbrXalt = 50, nbrYalt = 40, topSubtract = screenHeight, leftSubtract = 0;

	var leftCueSubtract = 700;

	var // config variables -------
	randomClearToBlack = false, // whether screen should be cleared to black randomly on scoreMode change
	boxesHasBorder = false, // whether boxes window has border
	setLength = 20*60, // length set in seconds; after this number of seconds taskMain is stopped
	pitchThreshold = 0.5, // under this waitTime value there is no pitchshift in the sound
	speedThreshold = 0.02, // under this waitTime value there is no sound for each box anymore
	struikelThreshold = 0.2, // under this waitTime value there is no stumbling in the pulse
	nbrFadeLimit = 50, // when there are more boxes changing at once than this value, there is no fade
	scoreReshuffle = 80, // frequency to shuffle the score
	timesMin = [5,15,5,4], timesMax = [10,30,15,8], // single, small, medium, big
	colorsMin = [5,20,5,2,2], colorsMax = [15,40,15,4,5], // wide, mellow, all, b/w, bright
	addOctave = 1, // add sine an octave higher
	soundOn = 1, // main switch to test with and without sound
	midiOn = 1, // main switch to test with and without MIDI
	testChangeAllBoxes = 0, // change all boxes at once all the time, just for testing
	testChangeOneBox = 0, // change only one box at a time, for testing
	allowJokerDefault = 1, // infrequently changing all boxes, also overridden for some scoreModes
	superModeEnabled = 0, // infrequently switching to superfast changes
	superModeSpeed = 0.03, // speed when in superMode
	superModeTime = 20, // time in secs before going out of superMode
	ultraModeEnabled = 0, // infrequently switching to ultrafast changes
	ultraModeSpeed = 0.001, // speed when in ultraMode
	ultraModeTime = 30, // time in secs before going out of ultraMode
	exciterModeTime = 20, // time in secs before going out of exciterMode
	exciterModeSpeed = 0.1, // speed when in exciterMode
	yellowButtonTime = 60, // time in secs that the yellow button is disabled after jumping out of exciterMode
	monoChromeDeviation = [0.4,0.4,0.4,0.5], // deviation from 0 values for red, green, blue, yellow in color, line, square scenes
	synthList = [\threeSines, \threeTris, \threeSinesDist, \primeBocAdCirc, \sineNoiseSaw],
	synthSoundLimit = [30,30,30,15,30], // no more than this number of boxes are 'sounding' for these synths
	nbrMIDILimit = 5, // no more than this number of boxes are playing as MIDI (so max MIDI notes is 3x this number)
	synthPitchShift = [1,1,1,1,1], // 1=apply pitchshift when all boxes are changing
	synthFreqMaps = [\uniform,\spread,\spreadNarrow], // mappings selecting spec.freq
	scoreModeList = [\default, \red, \green, \blue, \yellow, \redFull, \greenFull, \blueFull, \yellowFull, \blackwhite, \greyscale, \sequence, \lines,\mellow,\squares,\single, \demo],
	scoreModeWeight = [ 1, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.5, 0.5, 0.5, 0.5, 0.8, 0.5, 0.6, 0].normalizeSum,
	scoreModeLengthDefault = [ 1, 0.5, 0.5, 0.5, 0.3, 0.6, 0.6, 0.6, 0.4, 0.4, 0.5, 0.5, 0.5, 0.8, 0.5, 0.4, 1 ],
	dataDir = Document.dir++"Point-to-Organ/Data/",
	// display -------
	live = 2, // values 0,1,2 to show GUI controls, iControls image, setlist
	franceActive = 0, // whether to display France images as watermark
	franceFreq = 200, // image will shine through every franceFreq time (and dependent on random)
	frameOffset = 0, // set to 100 or something like that to show wooden frame
	noiseChance = 0.01, // chance for a noise image to be shown
	overlap = 0, // pixels for box overlap
	showConfigWindow = true, // show config window
	showCueWindow = false, // show cue window
	showParams = 0, // show parameters onscreen
	displayBoxText = 0, // set to 1 to display numbers in order in which the boxes change for testing
	// defaults per view -------
	// rgbSynth = \threeSines, synthFreqMap = \spread, runAutomatic = 1, waitTime = 2, // view 1
	rgbSynth = \threeTris, synthFreqMap = \spreadNarrow, runAutomatic = 0, waitTime = 3, // view 2
	// rgbSynth = \threeSines, synthFreqMap = \spreadNarrow, runAutomatic = 1, waitTime = 2, // view 3
	// rgbSynth = \threeSines, synthFreqMap = \spreadNarrow, runAutomatic = 0, waitTime = 2, // live
	// other defaults -------
	outBus = 0, outBusMonitor = 8, // output busses, set outBusMonitor = nil for no monitoring
	timeFactor = 1, // multipliction factor for runtimes in automatic mode
	fadeTime = waitTime / 2,
	scoreMode = \red, // default scoreMode
	startTaskMain = 0, // whether to start the task on running the code
	doubleskipchance = 0.1, // chance for either double of skip to occur
	playSound = 1, // switch depending on waitTime
	pitchWait = 1; // enable 2 sec wait and pitchshift for when all boxes are changed, depending on pitchThreshold

	// ------- other variables ------------------------------------------------------------------------------------

	var nbrSoundLimit = synthSoundLimit[synthList.indexOf(rgbSynth)];
	var focusGroup = nil; // set focus on placement of boxes to change
	var alphaValue = 1; // alpha for boxes, used to shine through France image
	var scoreModeLength = scoreModeLengthDefault * timeFactor, nbrXorig = nbrX, nbrYorig = nbrY;
	var allowJoker = allowJokerDefault;
	var nbrBoxesSmallMax = max(1, (nbrX * nbrY * 0.1).round(1).asInt);
	var nbrBoxesMediumMax = max(1, (nbrX * nbrY * 0.35).round(1).asInt);
	var freqBase = 0, lo = {rand(0.9)}!3, hi = lo + 0.1, pitchTrig = 0;
	var colorPrev, colorNew = Array.fill2D(nbrY,nbrX,nil);
	var colorScore, colorScoreNbr, colorScoreLo, colorScoreHi, colorScoreBase;
	var nbrTimesSingle, nbrTimesSmall, nbrTimesMedium, nbrTimesBig;
	var nbrTimesColorWide, nbrTimesColorMellow, nbrTimesColorAll, nbrTimesColorBW, nbrTimesColorBright, scoreModeIndex, scoreModeIndexPrev;
	var fShuffleScore, fSetWaitTime, fScoreMode, fClear, fSuperMode, fUltraMode, fUpdateParams, fChangeSize, fFreqMap, fTaskMain;
	var fExciterMode, fExciterModeSetVars, exciterClock, yellowButtonClock, yellowButtonTimeOut = 1, fYellowButtonTimeOut, fSetGui;
	var metaCounter = 0, metaWait = 0, superMode = 0, ultraMode = 0, taskMain, taskMeta, changeAllOverride = 0, taskAlpha;
	var waitTimeOrig = waitTime, fadeTimeOrig = fadeTime, exciterMode = 0, exciterInvoked = 0, taskClock, second = 0;
	var outMainBus = 36, synth = Group.new, main = Group.new(synth, \addAfter), mainSynth, runoutSynth;
	var volBus = Bus.control(s,1), runOutBus = Bus.control(s,1);
	var wBoxes, tFade, fFade, fPlaySynth, fKeyDown, tParamsBoxes, rectFrame, vFrance, rect, watermarkOverride = 0, fNoiseImage;
	var boxWidth, boxHeight;
	var box = Array.fill2D(nbrY,nbrX,nil), boxText = Array.fill2D(nbrY,nbrX,nil), tuples = [(0..(nbrY-1)), (0..(nbrX-1))].allTuples, tuplesSingle, tuplesDemo, noise = Array.fill2D(nbrY,nbrX,nil);
	var wConfig, pSynth, pScoreMode, lSynth, lScoreMode, lWaitTime, nWaitTime, bWhite, bBlack, bShuffle, lClear, tMetaWait, tMIDImap;
	var lFreqMap, pFreqMap;
	var sMainVol, sRunOutVol, sWaitTime, sTimeFactor, tMainVol, tRunOutVol, tWaitTime, tTimeFactor;
	var taskArduino, arduinoSms, arduinoPortName, ardDig2, ardDig2prev;
	var taskMainTime = 0, blinkWait, synthCount, metaJumpOut = 0, taskMainRunning = 0, singleRand, scoreModeChanged;
	var waitTimeSign = -1, wDummy, tSetlist = Array.newClear(3), fRandom;
	var waitTimeOverride = 0, waitTimeBeforeOverride = waitTime, fadeTimeBeforeOverride = fadeTime, doubleOverride = 0;
	var fPlayMIDI, iconID, midiNotes = Array.fill(127,0)!3, fStopAllNotes, fCountMIDI, fShowKeyShortcuts;
	var noteSet = {Set.new()}!3, noteSetNumber = {Array.fill(12,0)}!3, rgbLabel = [\red, \green, \blue];
	var wCue, tCue, lCue, cueBlinkColor = Color.blue, cueColor = Color.white, cueTextColor = Color.black, cueBlinkTextColor = Color.white;
	var cueBlinkNumber = 10, cueBlinkWait = 0.5, cueBlinkTask;
	var changeBlocksOverride = false, changeSingleOverride = false, midiNoteFactor = 1;
	// var setlist = ["Setlist De Pont:",
	// 	"1 sequence
	// 	2 redFull
	// 	3 green/yellow interruptions
	// 	4 green
	// 	5 yellow, stay same speed
	// 	6 superMode
	// 	7 single, increase speed to 1
	// 	8 squares" ,
	// 	"9 lines, increase speed to 0.2
	// 	10 mellow, jump to slow speed
	// 	11 back to 2 sec
	// 	12 blue
	// 	13 exciterMode
	// 	14 greyscale
	// 	15 red & slow
	// 	16 sometimes clear to black"
	// ];
	var setlist = ["Setlist Orgelpark:",
		"1. red # 0:00
2. green # 1:30
3. blueFull # 2:30
4. mellow met blokken # 3:30
5. single # 5:30
6. blackwhite short Sauer notes # 7:00" ,
		"7. greyscale no synthesis # 8:30
8. lines # 10:00
9. yellowFull speed up system # 12:00
10. red slow down, black out, spread out"
	];

	var spec = (
		freqUniform: Env.new( [30, 300], [1] ),
		freqSpread: [
			Env.new( [50, 150], [1] ),
			Env.new( [200, 400], [1] ),
			Env.new( [400, 800], [1] ),
		],
		freqSpreadNarrow: [
			Env.new( [60, 80], [1] ),
			Env.new( [203, 240], [1] ),
			Env.new( [401, 473], [1] ),
		],
		pan: Env.new( [-2,2], [nbrX-1] ),
		blendd: Env.new( [0,1], [1], -5 ),
		lev: Env.new( [0,1], [1], -5),
		metaWait: Env.new( [0.3,0.3,1,1],[0.1,0.9,9]),
		wait: Env.new( [0.001,0.1,3,7], [0.4,0.4,0.2], [\exp,\exp, \lin] ),
		nbrX: Env.new( [1,5,20], [0.5,0.5] ),
		nbrY: Env.new( [1,4,20], [0.5,0.5] ),
		fastModulo: Env.new( [10,10,3000], [50, 950], [\lin,\lin]),
		mainVol: Env.new( [0,0.001,0.1,1,3], [0.01,0.09,0.4,0.5], [\lin,\exp,\lin,\lin]),
		runOutVol: Env.new( [0,0.001,0.1,1,5], [0.01,0.09,0.4,0.5], [\lin,\exp,\lin,\lin]),
		timeFactor: Env.new( [0.3,2], [1] )
	);
	var buf = [ // buffer for runout synth
		Buffer.read(s, dataDir++"Audio/runout2.wav"),
		Buffer.read(s, dataDir++"Audio/119121__music-boy__kids-in-the-playground.wav")
	];

	// support for Prime synth
	var ampsPrime, freqPrimeList = List.new();
	ampsPrime = Array.fill(20, {arg i; 1  / ( i+1)});
	20.do { |i| freqPrimeList.add(1/i.nthPrime*100) };
	freqPrimeList = freqPrimeList.reverse.asArray;

	// if only one column, don't shift center of Splay
	if(nbrX == 1, { spec.pan = Env.new( [0,0], [1] ); "ControlSpec remapped since panning is not useful".postln; });

	// initial color
	colorPrev = Array.fill2D(nbrY,nbrX, { Color.black });

	// Noie, Frame and France don't go together - Noise precedes France precedes Frame
	if(noiseChance > 0, { franceActive = 0; frameOffset = 0 });
	if(franceActive == 1, { frameOffset = 0 });

	// if too many boxes, disable super and ultra modes
	if(nbrX*nbrY > 100, { superModeEnabled = 0; ultraModeEnabled = 0; });

	// set window Rect; first assume height is set to the screenheight
	rect = Rect((screenWidth - (screenHeight*nbrX/nbrY))/2,0,screenHeight*nbrX/nbrY,screenHeight).postln;
	if(rect.left < 0, { // if this gives us a negative left index, then flip and assume the width is set to the screenwidth
		rect = Rect(0,(screenHeight - (screenWidth*nbrY/nbrX))/2,screenWidth,screenWidth*nbrY/nbrX).postln;
	});

	s.recChannels = 2; ("Number of recording channels set to"+s.recChannels).postln;

	// ------- synths ------------------------------------------------------------------------------------

	3.do { |i|
		var tempSynth;
		case
		{ i==0 } { tempSynth = \threeSines }
		{ i==1 } { tempSynth = \threeSinesPitchUp }
		{ i==2 } { tempSynth = \threeSinesPitchDown }
		;
		SynthDef(tempSynth, {
			arg freq = #[300,300,300], gate = 1, pan = 0, sus = 1, rel = 2, lev = #[0.5,0.5,0.5], gain = 0.5, pitchMax = 1.2, pitchMin = 0.8;
			var sig, env, amp;
			amp = SinOsc.kr(ExpRand(1,5)).range(0.3,1);
			env = EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.3*sus,0.01,0.7*sus, rel]), gate, doneAction: 2 );
			sig = SinOsc.ar(freq, mul: 0.05 * lev).sum;
			if(addOctave==1) { sig = sig + SinOsc.ar(freq*2, mul: 0.05 * lev) };
			sig = Splay.ar(sig,center: pan);
			case
			{ i==1 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, 8/44100 * (pitchMax/12), 1, pitchMax, 1)) }
			{ i==2 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, (8/44100).neg * (0.075/pitchMin), 1, pitchMin, 1)) }
			;
			Out.ar(outMainBus,sig * amp * env * gain);
		}).add;
	};

	3.do { |i|
		var tempSynth;
		case
		{ i==0 } { tempSynth = \threeSinesDist }
		{ i==1 } { tempSynth = \threeSinesDistPitchUp }
		{ i==2 } { tempSynth = \threeSinesDistPitchDown }
		;
		SynthDef(tempSynth, {
			arg freq = #[300,300,300], gate = 1, pan = 0, sus = 1, rel = 2, lev = #[0.5,0.5,0.5], gain = 0.5, pitchMax = 1.2, pitchMin = 0.8;
			var sig, env, amp;
			amp = SinOsc.kr(ExpRand(1,5)).range(0.3,1);
			env = EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.3*sus,0.01,0.7*sus, rel]), gate, doneAction: 2 );
			sig = (3*SinOsc.ar(freq)).tanh.sum * (1/3) * 0.05 * lev;
			if(addOctave==1) { sig = sig + SinOsc.ar(freq*2, mul: 0.05 * lev) };
			sig = Splay.ar(sig,center: pan);
			case
			{ i==1 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, 8/44100 * (pitchMax/12), 1, pitchMax, 1)) }
			{ i==2 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, (8/44100).neg * (0.075/pitchMin), 1, pitchMin, 1)) }
			;
			Out.ar(outMainBus,sig * amp * env * gain);
		}).add;
	};

	3.do { |i|
		var tempSynth;
		case
		{ i==0 } { tempSynth = \threeTris }
		{ i==1 } { tempSynth = \threeTrisPitchUp }
		{ i==2 } { tempSynth = \threeTrisPitchDown }
		;
		SynthDef(tempSynth, {
			arg freq = #[300,300,300], gate = 1, pan = 0, sus = 1, rel = 2, lev = #[0.5,0.5,0.5], gain = 0.5, pitchMax = 1.2, pitchMin = 0.8;
			var sig, env, amp;
			amp = SinOsc.kr(ExpRand(1,5)).range(0.3,1);
			env = EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.3*sus,0.01,0.7*sus, rel]), gate, doneAction: 2 );
			sig = LFTri.ar(freq, mul: 0.045 * lev).sum;
			if(addOctave==1) { sig = sig + SinOsc.ar(freq*2, mul: 0.045 * lev) };
			sig = Splay.ar(sig,center: pan);
			case
			{ i==1 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, 8/44100 * (pitchMax/12), 1, pitchMax, 1)) }
			{ i==2 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, (8/44100).neg * (0.075/pitchMin), 1, pitchMin, 1)) }
			;
			Out.ar(outMainBus,sig * amp * env * gain);
		}).add;
	};

	3.do { |i|
		var tempSynth;
		case
		{ i==0 } { tempSynth = \primeBocAdCirc }
		{ i==1 } { tempSynth = \primeBocAdCircPitchUp }
		{ i==2 } { tempSynth = \primeBocAdCircPitchDown }
		;
		SynthDef(tempSynth, { // rgb sounds are summed as mono and then panned
			arg freq = #[300,300,300], gate = 1, pan = 0, sus = 1, rel = 2, lev = #[0.5,0.5,0.5], fade = fadeTime, gain = 0.5, pitchMax = 1.2, pitchMin = 0.8;
			var sig, env, amp, sigPrime, sigBoc, sigAdCirc;
			var freqPrime, detune;
			var sigAdCirc1, sigAdCirc2, freqAdCirc, control1, control2;
			amp = SinOsc.kr(ExpRand(1,5)/fade).range(0.7,1);
			env = [
				EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.1*sus,0.01,0.8*sus, 0.9*rel]), gate, doneAction: 2 ),
				EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.5*sus,0.01,0.4*sus, 0.9*rel]), gate ),
				EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.3*sus,0.01,0.6*sus, 0.9*rel]), gate )
			];

			// sig Boc
			sigBoc = RLPF.ar(RLPF.ar(
				Saw.ar(SinOsc.ar(2)*1.01 + (freq[0] + (8.midicps/128))) *
				Saw.ar(SinOsc.ar(2)*1.03 + (freq[0] + (5.midicps/128))) *
				Saw.ar(SinOsc.ar(2) + (freq[0] - (3.midicps/128))),
				800, 1), 800, 1, mul: lev[0] * env[0] * 2);

			// sig adCirc
			freqAdCirc = [freq[1],freq[1]*1.002];
			control1 = LFNoise1.kr(4).range(0.5,1);
			sigAdCirc1 = SinOscFB.ar( 1.01*SinOsc.ar(2) + freqAdCirc, control1, 0.5)
				* SinOscFB.ar(1.02*SinOsc.ar(2) + freqAdCirc, control1, 0.5)
				* SinOscFB.ar(SinOsc.ar(1.03) + freqAdCirc, control1, 0.5);
			sigAdCirc1 = RLPF.ar(sigAdCirc1, LFNoise1.kr(3).range(100,5000), LFNoise0.kr(5).range(0.1, 0.9));
			control2 = LFNoise1.kr(5.5).range(500,10000);
			sigAdCirc2 = Saw.ar( 1.01*SinOsc.ar(2) + freqAdCirc )
				* Saw.ar( 1.02*SinOsc.ar(2) + freqAdCirc)
				* Saw.ar( SinOsc.ar(1.03) + freqAdCirc);
			sigAdCirc2 = RLPF.ar(RLPF.ar(sigAdCirc2, control2), control2);
			sigAdCirc = LPF.ar( Mix.ar(sigAdCirc1 + sigAdCirc2), 5000) * env[1] * lev[1] * 0.3;

			// sigPrime
			detune = Array.fill(20, { LFNoise2.kr(1, 0.01 ,1) });
			// freqPrime = freq[2] * 2;
			freqPrime = freq[2];
			freqPrime= XLine.kr(freqPrime*Rand(0.92,0.97),freqPrime, 0.4);
			sigPrime = Mix.ar(SinOsc.ar( (freqPrime + freqPrimeList - freqPrimeList[0]) * detune, mul: ampsPrime).tanh.scramble);
			sigPrime = SinOsc.kr(4.5) * sigPrime * env[2] * lev[2] * 0.1;

			sig = sigPrime + sigBoc + sigAdCirc;
			if(addOctave==1) { sig = sig + SinOsc.ar(freq[0]*2, mul: 0.05 * lev[0] * env[0]) };
			sig = Splay.ar(sig, center: pan);

			case
			{ i==1 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, 8/44100 * (pitchMax/12), 1, pitchMax, 1)) }
			{ i==2 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, (8/44100).neg * (0.075/pitchMin), 1, pitchMin, 1)) }
			;

			Out.ar(outMainBus,sig * amp * gain);
		}).add;
	};

	3.do { |i|
		var tempSynth;
		case
		{ i==0 } { tempSynth = \sineNoiseSaw }
		{ i==1 } { tempSynth = \sineNoiseSawPitchUp }
		{ i==2 } { tempSynth = \sineNoiseSawPitchDown }
		;
		SynthDef(tempSynth, { // rgb sounds are summed as mono and then panned
			arg freq = #[300,300,300], gate = 1, pan = 0, sus = 1, rel = 2, lev = #[0.5,0.5,0.5], fade = fadeTime, gain = 0.5, pitchMax = 1.2, pitchMin = 0.8;
			var sig, env, amp;
			amp = SinOsc.kr(ExpRand(1,5)/fade).range(0.7,1);
			// amp = SinOsc.kr(ExpRand(1,5)).range(0.7,1);
			env = [
				// EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.01,0.01,sus, rel]), gate ),
				EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.1*sus,0.01,0.9*sus, rel]), gate ),
				EnvGen.kr( Env.new([0,1,1,0], [0.5*sus,0.8*sus, rel]), gate, doneAction: 2 ),
				EnvGen.kr( Env.new([0,1,0.5,0.5,0], [0.01,0.01,0.5*sus, 0.8*rel]), gate )
			];
			sig =
			SinOsc.ar(freq[0], mul: 0.1 * lev[0] * env[0]) +
			BPF.ar(PinkNoise.ar(10), freq[1], 0.01, mul: lev[1] * env[1]) +
			LFSaw.ar(freq[2]*XLine.kr(0.95,1,Rand(0.1,0.2)), mul: 0.03 * lev[2] * env[2]);

			if(addOctave==1) { sig = sig + SinOsc.ar(freq[0]*2, mul: 0.05 * lev[0] * env[0]) };
			if(addOctave==1) { sig = sig + LFSaw.ar(freq[2]*XLine.kr(0.95,1,Rand(0.1,0.2))*0.5, mul: 0.03 * lev[2] * env[2]) };

			sig = Splay.ar(sig, center: pan);

			case
			{ i==1 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, 8/44100 * (pitchMax/12), 1, pitchMax, 1)) }
			{ i==2 } { sig = PitchShift.ar(sig, pitchRatio: Phasor.kr(1, (8/44100).neg * (0.075/pitchMin), 1, pitchMin, 1)) }
			;

			Out.ar(outMainBus, sig * amp * gain);
		}).add;
	};

	SynthDef(\runout, {
		arg gate = 1, runOutBus, gain = 0.3;
		var sig, sigKids, sigRunout, sig1, sig2, env, kidsWave;
		env = EnvGen.kr( Env.asr(5,1,3), gate, doneAction: 2);
		sig1 = PlayBuf.ar(1, buf[0], rate: LFNoise1.kr(0.05).range(0.5,0.7), loop:1);
		sig2 = PlayBuf.ar(1, buf[0], rate: LFNoise1.kr(0.03).range(0.4,0.6), loop:1);
		sigRunout = LPF.ar([sig1,sig2], SinOsc.kr(0.01).range(200,LFNoise1.kr(0.1).range(2000,20000)));
		kidsWave = EnvGen.kr( Env.new([0,0,0.3,0.4,0,0],[5,0.5,0.5,0.5,10]*LFNoise1.kr(0.01).range(30,60),[\lin,\sin,\lin,\sin,\lin]).circle );
		sigKids = PlayBuf.ar(2, buf[1], loop:1) * kidsWave;
		sig = sigRunout + sigKids;
		sig = gain * sig * env * In.kr(runOutBus,1);
		Out.ar(outBus,sig);
		if(outBusMonitor.notNil, { Out.ar(outBusMonitor,sig) });
	}).add;

	SynthDef(\main, {
		arg gate = 1, volBus; var sig;
		sig = In.ar(outMainBus,2) * EnvGen.kr( Env.adsr(0,0,1,0), gate, doneAction: 2);
		sig = Limiter.ar(sig, 0.95, 0.05).clip2(0.95);
		sig = sig * In.kr(volBus,1);
		Out.ar(outBus,sig);
		if(outBusMonitor.notNil, { Out.ar(outBusMonitor,sig) });
	}).add;

	s.sync;

	// ------- Arduino ------------------------------------------------------------------------------------

	["Serial", SerialPort.devices].postln;
	arduinoPortName = SerialPort.devices.detect{|d| d.contains("tty.usb")};
	if(arduinoPortName.notNil, {
		("Connected to serial port" + arduinoPortName ++ ".").postln;
		arduinoSms = ArduinoSMS(arduinoPortName, 115200);
		arduinoSms.action = {
			| ... msg |
			ardDig2 = msg[2];
			if(ardDig2 != ardDig2prev, {
				("Arduino D2:"+ardDig2).postln;
				if((ardDig2 == 0) && (exciterMode==0) && (yellowButtonTimeOut==0) && (taskMainRunning==1),
					{ { fExciterMode.value }.defer });
				ardDig2prev = ardDig2;
			});
		};
		taskArduino = Task({ inf.do { arduinoSms.send($r);  0.05.wait; } /* where $r is the Char r */ }).start;
		}, {"No serial port found with name matching 'tty.usbmodem'.".postln}
	);

	// ------- GUI part 1 boxes window ------------------------------------------------------------------------------------

	wBoxes = Window.new("Point-to-Organ Boxes", Rect(rect.left - leftSubtract, rect.top - topSubtract, rect.width, rect.height),
		border: boxesHasBorder);
	wBoxes.view.background_(Color.white);
	if(frameOffset > 0, {
		wBoxes.view.backgroundImage_( Image.new(dataDir++"Images/frame"++rect.width++"x"++rect.height++".png") );
	});
	rectFrame = Rect(frameOffset, (frameOffset*rect.height/rect.width),
		rect.width - (2*frameOffset), rect.height - (2*frameOffset*rect.height/rect.width));

	if(franceActive == 1, {
		vFrance = (View(wBoxes, Rect(rect.left,rect.top,rect.width,rect.height))
			.backgroundImage_( Image.new(dataDir++"Images/France/france"++rand(3)++".png") )
		);
	});

	boxWidth = rectFrame.width / nbrX + (2*overlap);
	boxHeight = rectFrame.height / nbrY + (2*overlap);

	// function that returns a random noise image
	fNoiseImage = {
		var images = (dataDir++"Images/Noise/*").pathMatch;
		images.takeThese({ arg item, index; PathName.new(item).isFile.not });
		Image.new(images[rand(images.size)]).scalesWhenResized_(true)
		.setSize( (boxWidth*rrand(1,1.5)).asInt, (boxHeight*rrand(1,1.2)).asInt )
	};

	// create noises
	nbrY.do { |y|
		nbrX.do { |x|
			if(noiseChance > 0, {
				noise[y][x] = View.new(wBoxes,
					Rect(
						rectFrame.left + ((rectFrame.width / nbrX) * x) - overlap, rectFrame.top + ((rectFrame.height / nbrY) * y) - overlap,
						boxWidth, boxHeight
				)).backgroundImage_( fNoiseImage.value() );
			});
			box[y][x] = View.new(wBoxes, Rect(
					rectFrame.left + ((rectFrame.width / nbrX) * x) - overlap, rectFrame.top + ((rectFrame.height / nbrY) * y) - overlap,
					boxWidth, boxHeight
			)).background_(colorPrev[y][x]).visible_(true);
			if(displayBoxText == 1, {
				boxText[y][x] = (StaticText(box[y][x], Rect(rect.left,rect.top,boxWidth, boxHeight))
					.align_(\center).font_(Font("Avenir",40,true)))
			});
		};
	};

	tParamsBoxes = (StaticText(wBoxes, Rect(rectFrame.left + 10, rectFrame.top+20, 200, 60))
		.font_(Font("Avenir",10)).stringColor_(Color.white).string_("").visible_(showParams)
	);

	// ------- functions ------------------------------------------------------------------------------------

	// display keyboard shortcuts
	fShowKeyShortcuts = {
		"\nKeyboad shortcuts:\n
R: Run/stop
A: Automatic
F: Shuffle score
L: Switch live modes
K: Stop and reset clock

Z: Force change 1 or 2 boxes
X: Force change block of boxes
C: Force change all boxes

S: SuperMode
U: UltraMode
E: ExciterMode

N: Next scoreMode in automatic
B: Clear to black
W: Clear to white
Y: Set mode to yellow
D: Double/half override
T: Display time
O: Watermark override
P: Show params onscreen
i: Save screenshot
1: Display random boxes
M: Display MIDI count

Cmd-P: MIDI panic: stop all
Alt 1 .. 8 and Q .. I: load presets\n
".postln;
	};

	// function to create the score
	fShuffleScore = {
		if(waitTime > speedThreshold, { "\n### Shuffling score\n".postln });

		nbrTimesSingle = rrand(timesMin[0],timesMax[0]);
			// number of times only one box is changed
		nbrTimesSmall = rrand(timesMin[1],timesMax[1]);
			// number of times a small (range 1 to nbrBoxesSmallMax) number of boxes is changed
		nbrTimesMedium = rrand(timesMin[2],timesMax[2]);
			// number of times a medium (range 1 to nbrBoxesMediumMax) number of boxes is changed
		nbrTimesBig = rrand(timesMin[3],timesMax[3]);
			// number of times a full range number of boxes is changed (range half to all)

		nbrTimesColorWide = rrand(colorsMin[0],colorsMax[0]);
			// number of times the color selection is wide (range 0 - 1 with window of 1)
		nbrTimesColorMellow = rrand(colorsMin[1],colorsMax[1]);
			// number of times the color selection is mellow (range 0.3 - 0.6 with window of 0.1 or 0.05)
		nbrTimesColorAll = rrand(colorsMin[2],colorsMax[2]);
			// number of times the color selection is full (range 0 - 1 with window of 0.2)
		nbrTimesColorBW = rrand(colorsMin[3],colorsMax[3]);
			// number of times the color selection is black or white
		nbrTimesColorBright = rrand(colorsMin[4],colorsMax[4]);
			// number of times the color selection is bright (all values either 0 or 1 with window of 0.05)

		// set focusGroup
		if( [\default,\mellow].includes(scoreMode),
			{
				focusGroup = [\left,\right,\bottom,\top,\center].choose;
				if(waitTime > pitchThreshold, { ("FocusGroup set to" + focusGroup).postln });
			},
			{ focusGroup = nil }
		);

		// no squares when too little boxes
		if( (scoreMode == \squares) && ( (nbrX * nbrY < 5) || (nbrX == 1) || (nbrY == 1)), {
			scoreMode = \default; "Mode changed from squares to default since too little boxes".postln;
		});

		// reset joker
		allowJoker = allowJokerDefault;

		case
		{ scoreMode == \demo }
		{
			// nbr of boxes to change
			colorScoreNbr = [1];

			// lo values
			colorScoreLo =
			Array.fill(9, { arg index; [(index+1)%10/10,0,0] }).dup(nbrY).flatten ++
			Array.fill(9, { arg index; [0,(index+1)%10/10,0] }).dup(nbrY).flatten ++
			Array.fill(9, { arg index; [0,0,(index+1)%10/10] }).dup(nbrY).flatten;
			// hi values
			colorScoreHi = colorScoreLo;

			// no joker
			allowJoker = 0;

			// select tuples
			tuplesDemo =
			Array.fill(nbrY, { arg index; Array.fill(9, { [nbrY-index-1,(nbrX/2).floor.asInt-2] } ) }).flatten ++
			Array.fill(nbrY, { arg index; Array.fill(9, { [nbrY-index-1,(nbrX/2).floor.asInt-1] } ) }).flatten ++
			Array.fill(nbrY, { arg index; Array.fill(9, { [nbrY-index-1,(nbrX/2).floor.asInt] } ) }).flatten;
		}
		{ scoreMode == \default }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ rrand( (0.5*nbrY*nbrX).floor.asInt,nbrY*nbrX) }.dup(nbrTimesBig) ++
			{ nbrY*nbrX }.dup(1) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall);

			// lo values
			colorScoreLo =
			{ 0.0.dup(3) }.dup(nbrTimesColorWide) ++
			{ { rrand(0.3,0.6).round(0.0001) }.dup(3) }.dup(nbrTimesColorMellow) ++
			{ { rrand(0.0,1.0).round(0.0001) }.dup(3) }.dup(nbrTimesColorAll) ++
			{ ( [0.0,1.0].choose ).dup(3) }.dup(nbrTimesColorBW) ++
			{ { rrand(0.3,0.6).round(0.0001) }.dup(3) }.dup(nbrTimesColorMellow) ++
			{ [rand(2),rand(2),rand(2)] }.dup(nbrTimesColorBright);

			// hi values
			colorScoreHi = Array.newClear(colorScoreLo.size);
			colorScoreLo.size.do { |i|
				case
				{ i < nbrTimesColorWide }
				{ colorScoreHi[i] = 1.0.dup(3) }
				{ i < (nbrTimesColorWide+nbrTimesColorMellow) }
				{ colorScoreHi[i] = colorScoreLo[i] + 0.1 }
				{ i < (nbrTimesColorWide+nbrTimesColorMellow+nbrTimesColorAll) }
				{ colorScoreHi[i] = min(1,colorScoreLo[i] + 0.2) }
				{ i < (nbrTimesColorWide+nbrTimesColorMellow+nbrTimesColorAll+nbrTimesColorBW) }
				{ colorScoreHi[i] = colorScoreLo[i] }
				{ i < (nbrTimesColorWide+nbrTimesColorMellow+nbrTimesColorAll+nbrTimesColorBW+nbrTimesColorMellow) }
				{ colorScoreHi[i] = colorScoreLo[i] + 0.05 }
				{ true }
				{ colorScoreHi[i] = Array.newClear(3); 3.do {|k| if(colorScoreLo[i][k]==0,{colorScoreHi[i][k] = 0.05},{colorScoreHi[i][k] = 0.95})} }
				;
			};
		}
		{ scoreMode == \mellow }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle);

			// lo values
			colorScoreLo =
			{ { rrand(0.3,0.6).round(0.0001) }.dup(3) }.dup(nbrTimesColorMellow) ++
			{ { rrand(0.3,0.6).round(0.0001) }.dup(3) }.dup(nbrTimesColorMellow);

			// hi values
			colorScoreHi = Array.newClear(colorScoreLo.size);
			colorScoreLo.size.do { |i|
				case
				{ i < nbrTimesColorMellow }
				{ colorScoreHi[i] = colorScoreLo[i] + 0.1 }
				{ true}
				{ colorScoreHi[i] = colorScoreLo[i] + 0.05 }
				;
			};
		}
		{ scoreMode == \lines }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ min(nbrX,nbrY) }.dup(nbrTimesSmall) ++
			{ nbrY*nbrX }.dup(1);

			// lo values
			colorScoreLo =
			{ ( [0.0,1.0].choose ).dup(3) }.dup(nbrTimesColorBW) ++
			{ [rand(2),rand(2),rand(2)] }.dup(nbrTimesColorBright);

			// hi values
			colorScoreHi = Array.newClear(colorScoreLo.size);
			colorScoreLo.size.do { |i|
				case
				{ i < (nbrTimesColorBW) }
				{
					colorScoreHi[i] = colorScoreLo[i]
				}
				{ true }
				{
					colorScoreHi[i] = Array.newClear(3);
					3.do { |k| if(colorScoreLo[i][k]==0,
						{colorScoreHi[i][k] = monoChromeDeviation[k] / 2},
						{colorScoreHi[i][k] = 1 - (monoChromeDeviation[k] / 2)})
					};
				};
			};
			if(0.5.coin, { // with a chance of 50% add a random color line
				colorScoreLo = colorScoreLo ++ [[ rrand(0.1,0.4), rrand(0.1,0.4), rrand(0.1,0.4) ]];
				colorScoreHi = colorScoreHi ++ [[ rrand(0.4,0.9), rrand(0.4,0.9), rrand(0.4,0.9) ]];
			});
		}
		{ scoreMode == \squares }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 4 }.dup(nbrTimesSmall) ++
			{ nbrY*nbrX }.dup(1);

			// lo values
			colorScoreLo =
			{ { rrand(0.2,0.6).round(0.0001) }.dup(3) }.dup(nbrTimesColorMellow) ++
			{ { rrand(0.3,0.6).round(0.0001) }.dup(3) }.dup(nbrTimesColorMellow);

			// hi values
			colorScoreHi = Array.newClear(colorScoreLo.size);
			colorScoreLo.size.do { |i|
				case
				{ i < nbrTimesColorMellow }
				{ colorScoreHi[i] = colorScoreLo[i] + 0.1 }
				{ true}
				{ colorScoreHi[i] = colorScoreLo[i] + 0.05 }
				;
			};
		}
		{ scoreMode == \single }
		{
			// nbr of boxes to change
			colorScoreNbr = { 1 }.dup(nbrTimesSmall);

			// lo values
			colorScoreLo =
			{ [rand(2),rand(2),rand(2)] }.dup(nbrTimesColorAll);
			colorScoreLo.takeThese({arg item, index; item.sum == 0}); // reject black

			// hi values
			colorScoreHi = Array.newClear(colorScoreLo.size);
			colorScoreLo.size.do { |i|
				colorScoreHi[i] = Array.newClear(3);
				3.do { |k| if(colorScoreLo[i][k]==0,
					{colorScoreHi[i][k] = monoChromeDeviation[k] / 2},
					{colorScoreHi[i][k] = 1 - (monoChromeDeviation[k] / 2)})
				};
			};

			// no joker
			allowJoker = 0;

			// select tuples
			singleRand = rrand(2,3);
			if(waitTime > speedThreshold, { ("ScoreMode Single: choosing" + singleRand + "tuples").postln });
			tuplesSingle = [(0..(nbrY-1)), (0..(nbrX-1))].allTuples.scramble.takeThese({arg item, index; index >= singleRand});
		}
		{ scoreMode == \blackwhite }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ rrand( (0.5*nbrY*nbrX).floor.asInt,nbrY*nbrX) }.dup(nbrTimesBig) ++
			{ nbrY*nbrX }.dup(1) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall);

			// lo values
			colorScoreLo =
			{ ( [0.0,1.0].choose ).dup(3) }.dup(nbrTimesColorBW) ++
			{ [rand(2),rand(2),rand(2)] }.dup(nbrTimesColorBright);

			// hi values
			colorScoreHi = Array.newClear(colorScoreLo.size);
			colorScoreLo.size.do { |i|
				case
				{ i < (nbrTimesColorBW) }
				{ colorScoreHi[i] = colorScoreLo[i] }
				{ true }
				{
					colorScoreHi[i] = Array.newClear(3);
					3.do { |k| if(colorScoreLo[i][k]==0,
						{colorScoreHi[i][k] = monoChromeDeviation[k]},
						{colorScoreHi[i][k] = 1 - monoChromeDeviation[k]})
					}
				};
			};
		}
		{ scoreMode == \greyscale }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ rrand( (0.5*nbrY*nbrX).floor.asInt,nbrY*nbrX) }.dup(nbrTimesBig) ++
			{ nbrY*nbrX }.dup(1) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall);

			// lo values
			colorScoreLo =
			{ ( rrand(0.0,1.0) ).dup(3) }.dup(nbrTimesColorBW);

			// hi values
			colorScoreHi = colorScoreLo;

			// no joker
			allowJoker = 0;
		}
		{ [\red,\green,\blue,\yellow].includes(scoreMode) }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			// { rrand( (0.5*nbrY*nbrX).floor.asInt,nbrY*nbrX) }.dup(nbrTimesBig) ++
			{ nbrY*nbrX }.dup(1) ++
			// { rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall);

			// lo & hi values
			case
			{ scoreMode == \red } { colorScoreLo = [ [ 1 - monoChromeDeviation[0],0,0 ] ]; colorScoreHi = [ [ 1,0,0 ] ]; }
			{ scoreMode == \green } { colorScoreLo = [ [ 0,1 - monoChromeDeviation[1],0 ] ]; colorScoreHi = [ [ 0,1,0 ] ]; }
			{ scoreMode == \blue } { colorScoreLo = [ [ 0,0,1 - monoChromeDeviation[2] ] ]; colorScoreHi = [ [ 0,0,1 ] ]; }
			{ scoreMode == \yellow } { colorScoreLo = [ [ 1,1,0 ] ]; colorScoreHi = [ [ 1,1,1 - monoChromeDeviation[3] ] ]; }
			;

			// no joker
			allowJoker = 0;
		}
		{ [\redFull,\greenFull,\blueFull,\yellowFull].includes(scoreMode) }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ rrand( (0.5*nbrY*nbrX).floor.asInt,nbrY*nbrX) }.dup(nbrTimesBig) ++
			{ nbrY*nbrX }.dup(1) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall);

			// lo & hi values
			case
			{ scoreMode == \redFull } { colorScoreLo = [ [ 0.0,0,0 ] ]; colorScoreHi = [ [ 1,0,0 ] ]; }
			{ scoreMode == \greenFull } { colorScoreLo = [ [ 0,0.0,0 ] ]; colorScoreHi = [ [ 0,1,0 ] ]; }
			{ scoreMode == \blueFull } { colorScoreLo = [ [ 0,0,0.0 ] ]; colorScoreHi = [ [ 0,0,1 ] ]; }
			{ scoreMode == \yellowFull } { colorScoreLo = [ [ 1,1,0 ] ]; colorScoreHi = [ [ 1,1,0.9 ] ]; }
			;

			// no joker
			allowJoker = 0;
		}
		{ scoreMode == \sequence }
		{
			// nbr of boxes to change
			colorScoreNbr =
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall) ++
			{ rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			// { rrand( (0.5*nbrY*nbrX).floor.asInt,nbrY*nbrX) }.dup(nbrTimesBig) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ nbrY*nbrX }.dup(1) ++
			// { rrand(1, min(nbrBoxesMediumMax,nbrY*nbrX)) }.dup(nbrTimesMedium) ++
			{ 1 }.dup(nbrTimesSingle) ++
			{ rrand(1, min(nbrBoxesSmallMax,nbrY*nbrX)) }.dup(nbrTimesSmall);

			// lo values
			colorScoreBase = Array.series(98, 0.03, 0.01)++Array.series(96, 0.99, -0.01);
			colorScoreLo =
				colorScoreBase.collect { arg item, index; [item,0,0]  } ++
				colorScoreBase.collect { arg item, index; [item,item,0]  } ++
				colorScoreBase.collect { arg item, index; [0,item,0]  } ++
				colorScoreBase.collect { arg item, index; [0,item,item]  } ++
				colorScoreBase.collect { arg item, index; [0,0,item]  } ++
				colorScoreBase.collect { arg item, index; [item,0,item]  } ++
				colorScoreBase.collect { arg item, index; [item,item,item]  };

			// hi values
			colorScoreHi =
				colorScoreBase.collect { arg item, index; [item+0.01,0,0]  } ++
				colorScoreBase.collect { arg item, index; [item+0.01,item+0.01,0]  } ++
				colorScoreBase.collect { arg item, index; [0,item+0.01,0]  } ++
				colorScoreBase.collect { arg item, index; [0,item+0.01,item+0.01]  } ++
				colorScoreBase.collect { arg item, index; [0,0,item+0.01]  } ++
				colorScoreBase.collect { arg item, index; [item+0.01,0,item+0.01]  } ++
				colorScoreBase.collect { arg item, index; [item+0.01,item+0.01,item+0.01]  };

			// no joker
			allowJoker = 0;
		}
		;

		if(testChangeAllBoxes == 1, { colorScoreNbr = [nbrY*nbrX, nbrY*nbrX - 1] }); // test change all boxes
		if(testChangeOneBox == 1, { colorScoreNbr = [1] }); // test change just one

		colorScore = [colorScoreNbr, colorScoreLo, colorScoreHi];

		// ("ColorScore size 'Nbr of boxes' array:" + colorScore[0].size).postln;
		// ("ColorScore size 'Min RGB' array:" + colorScore[1].size).postln;
		// ("ColorScore size 'Max RGB' array:" + colorScore[2].size + "\n").postln;
		//
		// colorScore[0].size.do { |i|
		// 	(
		// 		"Nbr of boxes:" + colorScore[0][i] +
		// 		"\nRGB range:" + colorScore[1][i%colorScore[1].size] + "-"  + colorScore[2][i%colorScore[2].size]
		// 	).postln;
		// };

		// vary waitTime
		if( waitTime > struikelThreshold and: {waitTimeOverride==0}, { // only if speed is not too fast and we're not in doubleskip mode
			if(runAutomatic==1, {
				if(waitTime < (1 * fadeTime), { waitTimeSign = 1 });
				if(waitTime > (2.5 * fadeTime), { waitTimeSign = -1 });
				fSetWaitTime.value(waitTime + (rand(0.2 * waitTime) * waitTimeSign), "RUN");
			},{
				if(waitTime < (1.5 * fadeTime), { waitTimeSign = 1 });
				if(waitTime > (2 * fadeTime), { waitTimeSign = -1 });
				fSetWaitTime.value(waitTime + (rand(0.05 * waitTime) * waitTimeSign), "RUN");
			});
		});
	};

	// function to fade from one color to another for a specific box
	fFade = {
		arg y, x, from = Color.white, to = Color.black, via = Color.black, nbr;
		var tFade, tFadeVia, amount = 0, amountVia = 0;

		// flicker randomly
		if( waitTime > struikelThreshold and: {0.02.coin}, {
			// "Flicker".postln;
			from = from.blend(Color.white,0.8);
		});

		// change color slightly when too close
		if((abs(from.asArray-to.asArray)).sum < (monoChromeDeviation[0..2].sum / monoChromeDeviation[0..2].size), {
			if(from == Color.black,
				{ from = from.blend(Color.grey,0.3) },
				{ from = from.blend(Color.black,0.05) }
			);
		});

		// fade of flicker
		if( (fadeTime < 0.1) || (nbr >= nbrFadeLimit), { // don't fade, possibly flicker
			{ box[y][x].background = from; box[y][x].background = to }.defer;
		},
		{ // fade
			tFade = Task({
				100.do { |count|
					amount = spec.blendd.at(count/100);
					// [x,y,amount].postln;
					{ box[y][x].background = from.blend(to,amount) }.defer;
					(0.01*fadeTime).wait;
				};
			}).start;
		});
	};

	// play the sound on box change; Y = tuple[0], X = tuple[1]
	fPlayMIDI = {
		arg tuple, rgb, nbr;
		var freq = [300, 300, 300], note = [60, 60, 60], sus, rel, lev, noteString;

		// determine MIDI notes and some administration
		freq = fFreqMap.value(rgb,tuple);
		note = freq.cpsmidi.round(1);
		lev = spec.lev.at(rgb);
		noteString = "";
		note.do { arg item, index;
			if( (lev[index] > 0) || (rgb.sum == 0), {
				noteString = ( if(noteString != "", { noteString ++ "\t\t" }, { "" }) ) ++ rgbLabel[index] ++ ": " ++ item.midiname ++ " ";
				noteSet[index].add(item%12);
				noteSetNumber[index][item%12] = noteSetNumber[index][item%12] + 1;
			});
		};
		// noteString.postln;

		// set sustain time depending on number of boxes
		case
		{ (nbr == (nbrX*nbrY)) && (nbr > 1) && (pitchWait == 1) }
			{ sus = (2 + waitTime) * 0.5; rel =  (2 + waitTime) * 0.4 }
		{ waitTime < speedThreshold }
			{ sus = (spec.fastModulo.at(1/waitTime).floor) * waitTime * 0.7; rel = (spec.fastModulo.at(1/waitTime).floor) * waitTime * 0.2 }
		{ nbr > ( synthSoundLimit[synthList.indexOf(rgbSynth)] / 1.5 ) }
			{ sus = min(2,waitTime/2.5); rel = min(5,waitTime/1.5) }
		{ true }
			{ sus = min(2,waitTime/2); rel = min(5,waitTime) }
		;

		3.do { |index|
			// start note only if not already playing
			if( (midiNotes[index][note[index]] == 0) && ( (lev[index] > 0) || (rgb.sum == 0) ), {
				// ("Starting note" + note[index] + "on channel" + index).postln;
				~midiOut.noteOn(index, note[index], 127);
				midiNotes[index][note[index]] = 1;
				{
					// ("Stopping note" + note[index] + "on channel" + index).postln;
					~midiOut.noteOff(index, note[index], 127) ;
					midiNotes[index][note[index]] = 0;
				}.defer( (sus + rel) * 0.7 * midiNoteFactor);
			})
		};
	};

	fStopAllNotes = {
		"Stop all notes".postln;
		3.do { |index|
			127.do { |note|
				if(midiNotes[index][note]==1, {
					// ("Stop note" + note + "on channel" + index).postln;
					~midiOut.noteOff(index, note, 127);
					midiNotes[index][note] = 0;
				});
			}
		}
	};

	fCountMIDI = {
		var count = Array.fill(3,0);
		3.do { |index|
			count[index] = midiNotes[index].sum;
		};
		("MIDI notes sounding:" + count).postln;
	};

	// play the sound on box change; Y = tuple[0], X = tuple[1]
	fPlaySynth = {
		arg tuple, rgb, nbr;
		var freq = 300, pan = 0, sus, rel, lev, pitchSynth = \sineNoiseSaw;

		// map rgb values onto frequencies and box location into panning
		if(nbrY == 1, { freqBase = 200 });
		freq = fFreqMap.value(rgb,tuple);
		pan = spec.pan.at(tuple[1]);
		lev = spec.lev.at(rgb);

		// some debugging
		// (["freq"]++freq.collect {arg item; item.round(1)}).postln;
		// (["rgb"]++rgb.collect {arg item; item.round(0.01)}).postln;
		// ["pan",pan].postln;
		// ["lev",lev.ampdb.round(0.01)].postln;
		// "".postln;

		// set sustain time depending on number of boxes
		case
		{ (nbr == (nbrX*nbrY)) && (nbr > 1) && (pitchWait == 1) }
			{ sus = (2 + waitTime) * 0.5; rel =  (2 + waitTime) * 0.4 }
		{ waitTime < speedThreshold }
			{ sus = (spec.fastModulo.at(1/waitTime).floor) * waitTime * 0.7; rel = (spec.fastModulo.at(1/waitTime).floor) * waitTime * 0.2 }
		{ nbr > ( synthSoundLimit[synthList.indexOf(rgbSynth)] / 1.5 ) }
			{ sus = min(2,waitTime/2.5); rel = min(5,waitTime/1.5) }
		{ true }
			{ sus = min(2,waitTime/2); rel = min(5,waitTime) }
		;

		// play synth
		case
		{ rgb.sum <= 0.03 } // black
		{
			if(pitchWait == 1, { pitchSynth = rgbSynth++"PitchUp" });
			Synth(pitchSynth, [\freq, freq, \pan, pan, \sus, sus, \rel, rel, \lev, #[1,1,1], \fade, fadeTime, \pitchMax, 1.05],
				target: synth);
		}
		{ rgb == [1,1,1] } // white
		{
			if(pitchWait == 1, { pitchSynth = rgbSynth++"PitchDown" });
			Synth(pitchSynth, [\freq, freq, \pan, pan, \sus, sus, \rel, rel, \lev, #[1,1,1], \fade, fadeTime, \pitchMin, 0.95],
				target: synth);
		}
		{ (nbr == (nbrX*nbrY)) && (nbr > 1)  && (synthPitchShift[synthList.indexOf(rgbSynth)] == 1) } // all boxes change
		{
			if(pitchWait == 1, { pitchSynth = rgbSynth++(if(pitchTrig == 0, {"PitchUp"}, {"PitchDown"})) });
			Synth(pitchSynth, [\freq, freq, \pan, pan, \sus, sus, \rel, rel, \lev, lev, \fade, fadeTime], target: synth);
		}
		{ true } // else..
		{
			Synth(rgbSynth, [\freq, freq, \pan, pan, \sus, sus, \rel, rel, \lev, lev, \fade, fadeTime], target: synth);
		};
		synthCount = synthCount + 1;
	};

	fScoreMode = { arg val;
		var noteString, prevScoreMode;
		prevScoreMode = scoreMode;
		scoreMode = scoreModeList[val]; // set new score

		// update cue window
		if(showCueWindow, {
			{ tCue.string = scoreMode }.defer;
			cueBlinkTask = Task.new({
				cueBlinkNumber.do {
					{ tCue.background_(cueBlinkColor); tCue.stringColor_(cueBlinkTextColor); }.defer;
					cueBlinkWait.wait;
					{ tCue.background_(cueColor); tCue.stringColor_(cueTextColor); }.defer;
					cueBlinkWait.wait;
				}
			}).start;
		});

		// print and reset noteSet
		("\n# NoteSet " ++ prevScoreMode).postln;
		3.do { arg channel;
			noteString = "# " ++ rgbLabel[channel] ++ ": ";
			if(noteSet[channel].size != 0, {
				noteSet[channel].do { arg item, index;
					noteString = if(noteString != "", { noteString }, { "" })
					++ item.midiname.subStr(0, item.midiname.size - 3)
					++ " (" ++ noteSetNumber[channel][item] ++ "x) ";
				};
				noteString.postln;
			});
		};
		"".postln;
		if(prevScoreMode != scoreMode, {
			noteSet = {Set.new()}!3;
			noteSetNumber = {Array.fill(12,0)}!3;
		});

		fExciterModeSetVars.value; // deal with exciterMode
		("Mode changed to"+scoreMode).postln;
		scoreModeChanged = 1; // indicate we just changed the score so we can have actions on score change in task
		fShuffleScore.value; // create new score
		fUpdateParams.value; // update GUI
	};

	fSetWaitTime = { arg valWait, mode, valFade = 0;
		// mode values:
		// 		RUN: automatically, shortening or lengthening subtly the waitTime, NOT changing the fadeTime
		// 		GUI: via screen-fader, MIDI-fader or after super/ultra/exciter, also changing the fadeTime
		//		ORIG: when in super/ultra/exciter, just setting the original values of wait/fade for when jumping out of those
		if(mode != "ORIG", {
			waitTime = valWait;
			if(waitTime < pitchThreshold, { pitchWait = 0 }, { pitchWait = 1 });
			if(waitTime < speedThreshold, { playSound = 0 }, { playSound = 1});
		});
		if(mode == "GUI", {
			if(valFade == 0, { fadeTime = waitTime / 2 },{ fadeTime = valFade });
			// if(waitTime > speedThreshold, { ("\tfadeTime set to"+fadeTime.round(0.0001)).postln });
			// shorten metaWait; note that this will only make it shorter, not reset to original value!
			metaWait = metaWait * spec.metaWait[fadeTime];
		});
		if(mode == "ORIG", {
			waitTimeOrig = valWait;
			fadeTimeOrig = valWait / 2;
		});
		fUpdateParams.value;
	};

	fClear = { arg text = "", color;
		if(text!="", {("Cleared to"+text).postln});
		{ nbrY.do { |y| nbrX.do { |x| box[y][x].background_(color); colorPrev[y][x] = color; } } }.defer;
	};

	fKeyDown = {
		arg modifiers, keycode;
		// keycode.postln;

		case
		// Alt key
		{ modifiers.isAlt } {
		/* apple-number for presets */
			switch(keycode,
				18, { fScoreMode.value(scoreModeList.indexOf(\default)) },
				19, { fScoreMode.value(scoreModeList.indexOf(\mellow)) },
				20, { fScoreMode.value(scoreModeList.indexOf(\sequence)) },
				21, { fScoreMode.value(scoreModeList.indexOf(\blackwhite)) },
				23, { fScoreMode.value(scoreModeList.indexOf(\red)) },
				22, { fScoreMode.value(scoreModeList.indexOf(\green)) },
				26, { fScoreMode.value(scoreModeList.indexOf(\blue)) },
				28, { fScoreMode.value(scoreModeList.indexOf(\yellow)) },
				12, { fScoreMode.value(scoreModeList.indexOf(\lines)) },
				13, { fScoreMode.value(scoreModeList.indexOf(\squares)) },
				14, { fScoreMode.value(scoreModeList.indexOf(\single)) },
				15, { fScoreMode.value(scoreModeList.indexOf(\greyscale)) },
				17, { fScoreMode.value(scoreModeList.indexOf(\redFull)) },
				16, { fScoreMode.value(scoreModeList.indexOf(\greenFull)) },
				32, { fScoreMode.value(scoreModeList.indexOf(\blueFull)) },
				34, { fScoreMode.value(scoreModeList.indexOf(\yellowFull)) }
			);
		}
		// Command key
		{ modifiers.isCmd } {
			switch(keycode,
				3, 	{ /* apple-F */ wBoxes.fullScreen },
				12, 	{ /* apple-Q */ 0.exit; "EXIT".postln; },
				13, 	{ /* apple-W */ "Closing window".postln; wBoxes.endFullScreen; wBoxes.close; },
				35, 	{ /* apple-P */ fStopAllNotes.value() },
			);
		}
		// others
		{ true } {
			/* esc */ if(keycode == 53, { wBoxes.endFullScreen; });
			/* c */ 	if(keycode == 8, { changeAllOverride = 1 });
			/* x */ 	if(keycode == 7, { changeBlocksOverride = changeBlocksOverride.not });
			/* z */ 	if(keycode == 6, { changeSingleOverride = changeSingleOverride.not });
			/* f */ 	if(keycode == 3, { fShuffleScore.value });
			if(waitTimeOverride==0, {
				/* s */ 	if(keycode == 1, { fSuperMode.value });
				/* u */ 	if(keycode == 32, { fUltraMode.value });
				/* e */ 	if(keycode == 14, { fExciterMode.value });
			});
			/* n */ 	if(keycode == 45, { metaJumpOut = 1; "Jump out meta loop for automatic mode".postln; });
			/* b */ 	if(keycode == 11, { fClear.value("black",Color.black); } );
			/* w */	 if(keycode == 13 && (modifiers == 0), { fClear.value("white",Color.white); } );
			/* y */ 	if(keycode == 16, { metaCounter = 0; metaWait = 30 * fadeTime; fScoreMode.value(scoreModeList.indexOf(\yellow)) });
			/* a */ 	if((keycode == 0) && (modifiers == 0), {
				runAutomatic = (runAutomatic+1)%2;
				if(runAutomatic==1,
					{ "\n### Start running automatic".postln; taskMeta.start; fUpdateParams.value; },
					{ "\n### Stop running automatic".postln; taskMeta.stop; fUpdateParams.value;
				});
			});
			/* d */ 	if(keycode == 2, { doubleOverride = 1 } );
			/* r */ 	if(keycode == 15, { fTaskMain.value() } );
			/* t */ 	if(keycode == 17, { ("### The current time is" + second.asTimeStringHM).postln } );
			/* o */ 	if(keycode == 31, { "Watermark override".postln; watermarkOverride = 1; {watermarkOverride = 0}.defer(3) } );
			/* p */ 	if(keycode == 35, {
				showParams = (showParams+1)%3;
				case
				{ showParams == 0 } { tParamsBoxes.visible = false }
				{ showParams == 1 } { tParamsBoxes.visible = true; tParamsBoxes.stringColor = Color.white }
				{ showParams == 2 } { tParamsBoxes.visible = true; tParamsBoxes.stringColor = Color.black }
				;
			});
			/* i */ if(keycode == 34, {
				var img = Image.fromWindow(wBoxes);
				img.write(dataDir++"Saved Images/Point-to-Organ"++Date.getDate.stamp++".png");
			});
			/* l */ 	if(keycode == 37, {
				live = (live+1)%3;
				fSetGui.value;
			} );
			/* 1 */ 	if(keycode == 18, { fRandom.value() } );
			/* m */ 	if(keycode == 46, { fCountMIDI.value() } );
			/* k */ 	if(keycode == 40, { "Clock stopped and reset".postln; taskClock.stop; second = 0; } );
		}
		;


	};

	fSuperMode = {
		superMode = (superMode+1)%2;
		if(superMode == 1, {
			"SuperMode!".postln;
			if(ultraMode == 1, { fUltraMode.value }); // end ultraMode
			if(exciterMode == 1, { fExciterMode.value }); // end exciterMode
			waitTimeOrig = waitTime;
			fadeTimeOrig = fadeTime;
			fSetWaitTime.value(superModeSpeed,"GUI");
			{ exciterClock = AppClock.sched(superModeTime, { fSuperMode.value }) }.defer(0.1);
		}, {
			"END SuperMode!".postln;
			fSetWaitTime.value(waitTimeOrig,"GUI", fadeTimeOrig);
			exciterClock.clear;
		});
	};

	fUltraMode = {
		ultraMode = (ultraMode+1)%2;
		if(ultraMode == 1, {
			"UltraMode!".postln;
			if(superMode == 1, { fSuperMode.value }); // end superMode
			if(exciterMode == 1, { fExciterMode.value }); // end exciterMode
			waitTimeOrig = waitTime;
			fadeTimeOrig = fadeTime;
			fSetWaitTime.value(ultraModeSpeed,"GUI");
			{ exciterClock = AppClock.sched(ultraModeTime, { fUltraMode.value }) }.defer(0.1);
		}, {
			"END UltraMode!".postln;
			fSetWaitTime.value(waitTimeOrig,"GUI", fadeTimeOrig);
			exciterClock.clear;
		});
	};

	fYellowButtonTimeOut = { arg mode = \snooze;
		case
		{ mode == \snooze }
		{
			// switch off yellow button
			if(arduinoSms.notNil, { arduinoSms.send($u) });
			yellowButtonTimeOut = 1;
			yellowButtonClock = AppClock.sched(yellowButtonTime, {
				// fade yellow button
				if(arduinoSms.notNil, { arduinoSms.send($t) });
				yellowButtonTimeOut = 0;
				yellowButtonClock.clear;
			});
		}
		{ mode == \reset }
		{
			// reset yellow button timeout
			yellowButtonTimeOut = 0;
			yellowButtonClock.clear;
			if(arduinoSms.notNil, { arduinoSms.send($t) });
		}
		;
	};

	fExciterMode = {
		exciterMode = (exciterMode+1)%2;
		exciterInvoked = 1; // this makes sure fExciterModeSetVars is called in fScoreMode
		if(exciterMode == 1, {
			"ExciterMode!".postln;
			fYellowButtonTimeOut.value(\reset);
			// suspend automatic if applicable
			if(runAutomatic==1, { taskMeta.stop; "\n### Suspending automatic run".postln; });
			// switch off Ultra and Super
			if(ultraMode == 1, { fUltraMode.value }); // end ultraMode
			if(superMode == 1, { fSuperMode.value }); // end superMode
			// blink white-black
			fClear.value("white",Color.white);
			blinkWait = (waitTime - (SystemClock.seconds - taskMainTime)) / 100;
			Task { 100.do { |i| blinkWait.wait; fClear.value("",Color.grey(i/50)); }}.start;
			// this makes sure fScoreMode is called
			pScoreMode.valueAction = scoreModeList.indexOf(\lines);
			// schedule switch off
			{ exciterClock = AppClock.sched(exciterModeTime, { fExciterMode.value }) }.defer(0.1);
			// fast flicker yellow button
			if(arduinoSms.notNil, { arduinoSms.send($s) });
		}, {
			"END ExciterMode!".postln;
			// resume automatic if applicable
			if(runAutomatic==1, { taskMeta.start; "\n### Resuming automatic run".postln; });
			// this makes sure fScoreMode is called
			pScoreMode.valueAction = (0..(scoreModeList.size-1)).wchoose(scoreModeWeight);
			exciterClock.clear;
			fYellowButtonTimeOut.value(\snooze);
		});
	};

	fExciterModeSetVars = {
		if(exciterInvoked==1, {
			if(exciterMode==1, {
				// "ExciterMode!".postln;
				// set France image to invisible
				if(franceActive == 1, { vFrance.visible = false });
				// set score mode
				scoreMode = \lines;
				// set new size
				nbrXorig = nbrX; nbrYorig = nbrY; nbrX = nbrXalt; nbrY = nbrYalt;
				// change views
				fChangeSize.value;
				// change waitTime
				waitTimeOrig = waitTime;
				fadeTimeOrig = fadeTime;
				fSetWaitTime.value(exciterModeSpeed, "GUI");
			}, {
				if(franceActive == 1, { vFrance.visible = true });
				nbrX = nbrXorig; nbrY = nbrYorig;
				fChangeSize.value;
				fSetWaitTime.value(waitTimeOrig, "GUI", fadeTimeOrig);
				exciterInvoked = 0;
			});
		});
	};

	fUpdateParams = {
		{
			// update params on boxes window
			tParamsBoxes.string =
			"scoreMode:" + scoreMode +
			"\nwaitTime:" + waitTime.round(0.0001) +
			"\nmetaWait:" + metaWait.round(0.01)  +
			"\nrunningAutomatic:" + (if(runAutomatic==1, {"ON"},{"OFF"}));

			// update params on config window
			pScoreMode.value = scoreModeList.indexOf(scoreMode);
			nWaitTime.value = waitTime.round(0.0001);
			case
			{ waitTime < speedThreshold } { nWaitTime.stringColor = Color.red }
			{ waitTime < pitchThreshold } { nWaitTime.stringColor = Color.blue }
			{ true } { nWaitTime.stringColor = Color.black }
			;
			tMetaWait.string =
			"auto" + (if(runAutomatic==1, {"ON"},{"OFF"})) + metaWait.round(1) ++ "s";
		}.defer;
	};

	fChangeSize = {
		// remove views
		box.deepCollect(2, { arg item; item.remove; });

		nbrBoxesSmallMax = max(1, (nbrX * nbrY * 0.1).round(1).asInt);
		nbrBoxesMediumMax = max(1, (nbrX * nbrY * 0.35).round(1).asInt);
		colorNew = Array.fill2D(nbrY,nbrX,nil);
		box = Array.fill2D(nbrY,nbrX,nil);
		tuples = [(0..(nbrY-1)), (0..(nbrX-1))].allTuples;
		spec.pan = Env.new( [-2,2], [nbrX-1] );
		colorPrev = Array.fill2D(nbrY,nbrX, { Color.white });

		// create boxes
		nbrY.do { |y|
			nbrX.do { |x|
				box[y][x] = View.new(wBoxes,
					Rect(
						rectFrame.left + ((rectFrame.width / nbrX) * x) - overlap, rectFrame.top + ((rectFrame.height / nbrY) * y) - overlap,
						boxWidth, boxHeight
				)).background_(colorPrev[y][x]);
			};
		};

	};

	fTaskMain = { arg mode;
		case
		{ mode==\kill }
		{
			"\n### TaskMain & TaskMeta stopped".postln;
			taskMainRunning = 0;
			taskMeta.stop;
			taskMain.stop;
			taskClock.stop;
			fStopAllNotes.value();
		}
		{ mode==\stop }
		{
			"\n### TaskMain & TaskMeta stopped".postln;
			taskMainRunning = 0;
			taskMeta.stop;
			taskMain.stop;
			taskClock.stop;
			fStopAllNotes.value();
			{
				second = 0;
				fClear.value("black",Color.black);
			}.defer(waitTime);
			fYellowButtonTimeOut.value(\reset);
		}
		{ taskMainRunning == 1 }
		{
			if(runAutomatic==1, {
				"\n### Stop running automatic (taskMeta stopped)".postln;
				taskMeta.stop;
			});
			"\n### TaskMain paused".postln;
			taskMainRunning = 0;
			taskMain.pause;
			fStopAllNotes.value();
			fYellowButtonTimeOut.value(\reset);
		}
		{ taskMainRunning == 0 }
		{
			if(runAutomatic==1, {
				"\n### Running automatic (taskMeta started)".postln;
				taskMeta.start;
			});
			"\n### TaskMain started".postln;
			taskMainRunning = 1;
			{ taskMain.resume }.defer(0.1);
			taskClock.start; // start the clock
			if(setLength > 0, {  ("### Length set to:" + setLength.asTimeStringHM).postln });
			fYellowButtonTimeOut.value(\snooze);
			fShowKeyShortcuts.value;
		}
		;
	};

	// set all boxes to a random color
	fRandom = {
		nbrY.do { |y| nbrX.do { |x| box[y][x].background_(Color.rand) } };
	};

	fSetGui = {
		case
		{ live == 0 } // only GUI controls
		{
			3.do { |i| tSetlist[i].visible_(0) };
			wConfig.bounds = Rect(40,Window.screenBounds.height - 720 + 435,800,650-435);
		}
		{ live == 1 } // GUI controls + image iControls
		{
			3.do { |i| tSetlist[i].visible_(0) };
			wConfig.bounds = Rect(40,Window.screenBounds.height - 720 + 150,800,650-150);
		}
		{ live == 2 } // GUI controls + image iControls + setlist
		{
			3.do { |i| tSetlist[i].visible_(1) };
			wConfig.bounds = Rect(40,Window.screenBounds.height - 720,800,650);
		}
		;
	};

	// ------- tasks ------------------------------------------------------------------------------------

	taskClock = Task {
		inf.do {
			if(second%30 == 0, { ("### The current time is" + second.asTimeStringHM).postln });
			1.wait;
			second = second + 1;
			if(runAutomatic==0, { // only announce the end when not running automatic
				if(second > (setLength - 30), { ("\n\n### THE END IS NEAR: " + (setLength - second).asTimeStringHM).postln });
				if(second == setLength, {
					"\n\n### STOP! IMMEDIATELY! NOW!".postln;
					// fTaskMain.value(\stop);
					taskClock.stop;
					second = 0;
				});
			});
		}
	};

	taskMeta = Task.new {
		metaCounter = 0; metaWait = 0;
		inf.do {
			if( (metaCounter >= metaWait) || (metaJumpOut == 1), {{
				// set time till scoreMode change, depending on the fadeTime
				metaWait = rrand(60,180) * spec.metaWait[fadeTime];
				metaWait = metaWait.round(0.001);
				metaCounter = 0;
				metaJumpOut = 0;

				while( // choose scoreMode index
					{ scoreModeIndex == scoreModeIndexPrev },
					{ scoreModeIndex = (0..(scoreModeList.size-1)).wchoose(scoreModeWeight) }
				);
				scoreModeIndexPrev= scoreModeIndex; // remember current scoreModeIndex

				// special modes on
				if(waitTimeOverride==0, { // don't do in case of doubleskip mode
					case
					{ 0.03.coin && (superModeEnabled == 1) } { fSuperMode.value }
					{ 0.02.coin && (ultraModeEnabled == 1) } { fUltraMode.value }
					;
				});

				// debugging blurp
				("scoreMode index:"+scoreModeIndex++", length factor:"+scoreModeLength[scoreModeIndex]
					++", name:"+scoreModeList[scoreModeIndex]).postln;
				("metaWait original:"+metaWait+"seconds").postln;

				// change the metaWait depending on the scoreMode
				metaWait = metaWait * scoreModeLength[scoreModeIndex];
				metaWait = metaWait.round(0.001);
				("metaWait new:"+metaWait+"seconds").postln;

				// activate scoreMode
				fScoreMode.value(scoreModeIndex);
			}.defer});
			metaCounter = metaCounter + 1;
			1.wait;
		};
	};

	taskMain = Task.new {
		var nbr, rgb;
		inf.do { arg k;
			// number of boxes to change
			nbr = colorScore[0][k%(colorScore[0].size)];

			// note time
			taskMainTime = SystemClock.seconds;

			// double and skip
			if( nbr < 6 and: { k > 5 } and: { waitTime > struikelThreshold }, {
				// not in special modes, when nbr is too big, not in the beginning, not when playing too fast
				if(waitTimeOverride == 2, { // just double'd once, do it again
					waitTime = 0.5*waitTime;
					waitTimeOverride = 1; // make sure we reset
					// ("Double 2 ("++waitTime.round(0.01)++")").postln;
				}, {
					if( (doubleskipchance*((k%200).linexp(0.0,199,1.0,2))).coin or: { doubleOverride==1 }, { // change on double or skip occuring
						if(0.5.coin or: { doubleOverride==1 }, { // equal chance for double and skip
							waitTimeOverride = 2;
							waitTimeBeforeOverride = waitTime; waitTime = 0.5*waitTime;
							// ("Double 1 ("++waitTime.round(0.01)++")").postln;
							doubleOverride = 0;
						},{
							waitTimeOverride = 1;
							waitTimeBeforeOverride = waitTime; waitTime = 2*waitTime;
							// ("Skip ("++waitTime.round(0.01)++")").postln;
						});
						fadeTimeBeforeOverride = fadeTime; fadeTime = waitTime / 2;
					});
				});
				fUpdateParams.value; // update GUI
			});

			// reset synth count
			synthCount = 0;

			// ("####### nbr of boxes to change"+nbr).postln;
			nbr = min(nbr, 2000); // upperlimit to number of boxes to change

			// change all boxes once
			if(changeAllOverride == 1, {
				"Force change ## all boxes".postln;
				nbr = (nbrX * nbrY);
				tuples = [(0..(nbrY-1)), (0..(nbrX-1))].allTuples;
				changeAllOverride = 0;
			});

			// alpha change
			if( franceActive == 1 and: { waitTime > pitchThreshold }, {
				if( watermarkOverride == 1 or: { (k%franceFreq) == (franceFreq-1) }, {
					watermarkOverride = 0;
					{ vFrance.backgroundImage_( Image.new(dataDir++"Images/France/france"++rand(3)++".png")) }.defer;
					taskAlpha.stop;
					alphaValue = 1;
					taskAlpha.start;
				});
			});

			// choose pitchshift synth up or down
			if( nbr == (nbrX * nbrY) and: { nbr > 1 }, { pitchTrig = (pitchTrig + 1)%2 });

			// re-order tuples; only the first 'nbr' will be changed
			tuples = [(0..(nbrY-1)), (0..(nbrX-1))].allTuples;

			// specific scoreMode code
			case
			{ scoreMode == \lines and: { nbr == min(nbrX,nbrY) } } // lines scoreMode
			{
				if(rand(2) == 0, { // horizontal
					y = rand(nbrY);
					tuples = tuples.takeThese({ arg item, index; item[0] != y; });
					nbr = nbrX;
				}, { // vertical
					x = rand(nbrX);
					tuples = tuples.takeThese({ arg item, index; item[1] != x; });
					nbr = nbrY;
				});
			}
			{ scoreMode == \squares and: { nbr == 4 } } // squares scoreMode
			{
				x = rand(nbrX-1); y = rand(nbrY-1);
				tuples.takeThese({ arg item, index; (item!=[y,x]) && (item!=[y+1,x]) && (item!=[y,x+1]) && (item!=[y+1,x+1]) });
				case
				{ rand(2) == 0 } { tuples.add([y,(x+2)%nbrX]); nbr = 5; }
				{ rand(2) == 0 } { tuples.scramble.removeAt(0); nbr = 3; }
				{ rand(2) == 0 } { tuples.add([(y+2)%nbrY,x]); nbr = 5; }
				;
				if(0.1.coin, { fClear.value("black",Color.black) });
			}
			{ changeBlocksOverride.not && changeSingleOverride.not &&
				focusGroup.notNil and: { nbr <= 4 } and: { 0.8.coin } and: { nbrX > 2 } and: { nbrY > 2 } } // focusGroup settings
			{
				case
				{ focusGroup == \right } { tuples.takeThese({ arg item, index; item[1] < (nbrX-2) }) }
				{ focusGroup == \left } { tuples.takeThese({ arg item, index; item[1] > 2 }) }
				{ focusGroup == \bottom } { tuples.takeThese({ arg item, index; item[0] < (nbrY-2) }) }
				{ focusGroup == \top } { tuples.takeThese({ arg item, index; item[0] < 2 }) }
				{ focusGroup == \center } {
					tuples.takeThese({ arg item, index; (item[1] == (nbrX-1)) || (item[1] == 0) || (item[0] == (nbrY-1)) || (item[0] == 0) })
				}
				;
				// [focusGroup, tuples].postln;
			}
			{ scoreMode == \single and: { nbr == 1 } }
			{
				tuples = tuplesSingle;
				tuplesSingle = tuplesSingle.rotate;
				if(scoreModeChanged == 1, { fClear.value("black",Color.black) });
			}
			{ scoreMode == \demo }
			{
				nbr = 1;
				tuples = tuplesDemo;
				tuplesDemo = tuplesDemo.rotate(-1);
				if(scoreModeChanged == 1, { fClear.value("black",Color.black) });
			}
			{ changeBlocksOverride }
			{
				// change blocks
				"Force change ## blocks of boxes".postln;
				nbr = 4;
				x = rand(nbrX-1); y = rand(nbrY-1);
				tuples.takeThese({ arg item, index; (item!=[y,x]) && (item!=[y+1,x]) && (item!=[y,x+1]) && (item!=[y+1,x+1]) });
				case
				{ rand(2) == 0 } { tuples.add([y,(x+2)%nbrX]); nbr = 5; }
				{ rand(2) == 0 } { tuples.add([(y+2)%nbrY,x]); nbr = 5; }
				;
			}
			{ changeSingleOverride }
			{
				// change blocks
				"Force change ## 1 or 2 boxes".postln;
				nbr = [1,2].choose;
			}
			;
			// randomly scramble all tuples
			if([\single,\demo].indexOf(scoreMode).isNil, {
				tuples = tuples.scramble;
			});

			// sometimes clear to black
			if( randomClearToBlack and: { scoreModeChanged == 1 } and: { 0.1.coin }, { fClear.value("black",Color.black) });

			// select next lo and hi threshold arrays from the color score
			lo = colorScore[1][k%(colorScore[1].size)];
			hi = colorScore[2][k%(colorScore[2].size)];

			// every now and then change all boxes into very close colors
			if( k%60 == 57 and: {[0,1].choose == 1} and: {allowJoker == 1} and: {playSound == 1}, {
				"Joker!".postln;
				nbr = (nbrX * nbrY);
				tuples = [(0..(nbrY-1)), (0..(nbrX-1))].allTuples;
				lo = [rand(2),rand(2),rand(2)]; // values for RGB will be 0 or 1
				3.do { |i| if(lo[i]==0, {hi[i] = 0.05}, {hi[i] = 0.95}) };
			});

			// change selected boxes
			nbr.do { |i|
				// set alpha value to display noise images
				if(waitTime > pitchThreshold and: { noiseChance.coin or: { watermarkOverride==1 } }, {
					alphaValue = rrand(0.7,0.9);
					{ noise[tuples[i][0]][tuples[i][1]].backgroundImage_( fNoiseImage.value() )
					}.defer();
				});
				// randomly select rgb values between lo and hi
				rgb = lo.collect {arg item, index; rrand(max(0,lo[index]),min(1,hi[index]))};
				colorNew[tuples[i][0]][tuples[i][1]] = Color.new(rgb[0],rgb[1],rgb[2],alphaValue);
				// fade selected box from one color to the next
				fFade.value( tuples[i][0], tuples[i][1], colorPrev[tuples[i][0]][tuples[i][1]], colorNew[tuples[i][0]][tuples[i][1]], nbr: nbr);
				// play the sound but only if playback is enabled or every now and then determined by spec.fastModulo
				if( soundOn == 1 and: { i < nbrSoundLimit }, {
					if( playSound==1 or: {k%(spec.fastModulo.at(1/waitTime).floor)==0}, { fPlaySynth.value(tuples[i],rgb,nbr) });
				});
				// play MIDI
				if( midiOn == 1 and: { i < nbrMIDILimit }, {
					if( playSound==1 or: {k%(spec.fastModulo.at(1/waitTime).floor)==0}, { fPlayMIDI.value(tuples[i],rgb,nbr) });
				});
				// display something in boxes
				if(displayBoxText == 1, {
					{ boxText[tuples[i][0]][tuples[i][1]].string = i }.defer;
					{ boxText[tuples[i][0]][tuples[i][1]].string = "" }.defer(waitTime*0.8);
				});
				// save current color as previous color
				colorPrev[tuples[i][0]][tuples[i][1]] = colorNew[tuples[i][0]][tuples[i][1]];
				// reset alphaValue
				if(noiseChance > 0, { alphaValue = 1});
			};
			// fCountMIDI.value();

			// if(waitTime > pitchThreshold, { ("Number of synths:" + synthCount).postln });

			// every now and then reshuffle the score
			if( (k%scoreReshuffle) == (scoreReshuffle - 1) and: { scoreMode != \demo }, { fShuffleScore.value });

			// reset var indicating we just changed scoreMode
			if(scoreModeChanged == 1, { scoreModeChanged = 0 });

			// wait!
			waitTime.wait;
			// reset double
			if( waitTimeOverride == 1 or: { waitTimeOverride == 2 and: { 0.5.coin } } , {
				waitTime = waitTimeBeforeOverride;
				fadeTime = fadeTimeBeforeOverride;
				waitTimeOverride = 0;
				// "Reset double / skip".postln;
				fUpdateParams.value; // update GUI
			});
			// wait some more if all boxes changed
			if( nbr == (nbrX * nbrY) and: { nbr > 1 } and: { pitchWait == 1 }, { 2.wait; });
		}
	};

	taskAlpha = Task.new {
		var repeats = rrand(10,15), step = rrand(0.002,0.005);
		// var repeats = rrand(10,15), step = rrand(0.005,0.01);
		["France Task",repeats,step].postln;
		repeats.do { alphaValue = alphaValue - step; ["alphaValue",alphaValue].postln; (waitTime*rrand(0.5,2)).wait; };
		repeats.do { alphaValue = alphaValue + step; ["alphaValue",alphaValue].postln; (waitTime*rrand(0.5,2)).wait; };
	};

	// ------- MIDI ------------------------------------------------------------------------------------

	MIDIIn.connectAll;

	// keep device id of ICON to filter below
	iconID = MIDIout.new().getIDs()[4];

	MIDIdef.noteOn(\noteOn, {
		arg val, num, chan, src;
		// [chan, num, val].postln;
		// only if coming from ICON
		if(src==iconID, {
			if(waitTimeOverride==0, { // only do when not in doubleskip mode
				if(num == 21, { { fSuperMode.value }.defer } );
				if(num == 24, { { fUltraMode.value }.defer } );
				if(num == 22, { { fExciterMode.value }.defer } );
			});
			if(num == 20, { changeAllOverride = 1 });
			if(num == 23, { fShuffleScore.value });
			if(num == 25, { fTaskMain.value });

			if(num == 60, { fScoreMode.value(scoreModeList.indexOf(\default)) } );
			if(num == 61, { fScoreMode.value(scoreModeList.indexOf(\mellow)) } );
			if(num == 62, { fScoreMode.value(scoreModeList.indexOf(\sequence)) } );
			if(num == 63, { fScoreMode.value(scoreModeList.indexOf(\blackwhite)) } );

			if(num == 64, { fClear.value("black",Color.black) } );

			if(num == 65, { fScoreMode.value(scoreModeList.indexOf(\red)) } );
			if(num == 66, { fScoreMode.value(scoreModeList.indexOf(\green)) } );
			if(num == 67, { fScoreMode.value(scoreModeList.indexOf(\blue)) } );
			if(num == 68, { fScoreMode.value(scoreModeList.indexOf(\yellow)) } );

			if(num == 48, { fScoreMode.value(scoreModeList.indexOf(\lines)) } );
			if(num == 49, { fScoreMode.value(scoreModeList.indexOf(\squares)) } );
			if(num == 50, { fScoreMode.value(scoreModeList.indexOf(\single)) } );
			if(num == 51, { fScoreMode.value(scoreModeList.indexOf(\greyscale)) } );

			if(num == 52, { fClear.value("white",Color.white) });

			if(num == 53, { fScoreMode.value(scoreModeList.indexOf(\redFull)) } );
			if(num == 54, { fScoreMode.value(scoreModeList.indexOf(\greenFull)) } );
			if(num == 55, { fScoreMode.value(scoreModeList.indexOf(\blueFull)) } );
			if(num == 56, { fScoreMode.value(scoreModeList.indexOf(\yellowFull)) } );

			if(num == 0, {
				runAutomatic = (runAutomatic+1)%2;
				if(runAutomatic==1, {
					"\n### Start running automatic".postln;
					pScoreMode.visible = false;
					taskMeta.start;
					fUpdateParams.value;
				}, {
					"\n### Stop running automatic".postln;
					pScoreMode.visible = true;
					taskMeta.stop;
					fUpdateParams.value;
				});
			});
		});
	}).fix;

	MIDIdef.noteOff(\noteOff, {
		arg val, num, chan, src;
		// only if coming from ICON
		if(src==iconID, {
		});
	}).fix;

	MIDIdef.cc(\cc, {
		arg val, num, chan, src;
		// [chan, num, val].postln;
		// only if coming from ICON
		if(src==iconID, {
			case
			{ num == 1 } { sMainVol.valueAction_(val/127) }
			{ num == 2 } { sRunOutVol.valueAction_(val/127) }
			{ num == 3 } { sWaitTime.valueAction_(val/127) }
			{ num == 4 } { sTimeFactor.valueAction_(val/127) }
			{ num == 8 } { midiNoteFactor = val / 127 }
			{ num == 9 && val == 127 } { fStopAllNotes.value() }
			{ num == 10 } {
				var synth = val.linlin(0,127,0,synthList.size-0.1).floor;
				{ if(pSynth.value != synth, { pSynth.valueAction = synth }) }.defer;
			}
			{ num == 11 } {
				var map = val.linlin(0,127,0,synthFreqMaps.size-0.1).floor;
				{ if(pFreqMap.value != map, { pFreqMap.valueAction = map }) }.defer;
			}
			;
		});
	}).fix;

	// ------- GUI part 2 config window ------------------------------------------------------------------------------------

	wConfig = Window.new("Point-to-Organ Config",
		Rect(40,Window.screenBounds.height - 720 + 435,800,650-435));

	lScoreMode = (StaticText(wConfig, Rect(10,20,80,80)).font_(Font("Avenir",12)).string_("ScoreMode:  ")).align_(\right);
	pScoreMode = (PopUpMenu(wConfig, Rect(90,20,330,80))
		.font_(Font("Avenir",50)).canFocus_(false)
		.items_(scoreModeList)
		.action_({ |p|
			fScoreMode.value(p.value);
		})
	);

	lWaitTime = (StaticText(wConfig, Rect(10,110,80,80)).font_(Font("Avenir",12)).string_("WaitTime:  ")).align_(\right);
	nWaitTime = (SmoothNumberBox(wConfig, Rect(90,110,160,80))
		.font_(Font("Avenir",45)).radius_(2).border_(1).align_(\center).clipLo_(0.001).clipHi_(10.0).step_(0.001)
		.value_(waitTime).canFocus_(false)
		.action_({ |n|
			fSetWaitTime.value(n.value, "GUI");
		})
	);
	tMetaWait = (StaticText(wConfig, Rect(260,110,160,80))
		.font_(Font("Avenir",20)).stringColor_(Color.black).string_("").background_(Color.grey(0.8)).align_(\center)
	);
	tMetaWait.mouseDownAction_({
		runAutomatic = (runAutomatic+1)%2;
		if(runAutomatic==1, {
			"\n### Start running automatic".postln;
			taskMeta.start;
			fUpdateParams.value;
		}, {
			"\n### Stop running automatic".postln;
			taskMeta.stop;
			fUpdateParams.value;
		});
	});

	tMainVol = (StaticText(wConfig, Rect(450, 20, 100, 25))
		.font_(Font("Avenir", 12)).string_("Main volume:  ").align_(\right)
	);
	sMainVol = (SmoothSlider(wConfig, Rect(550, 20, 200, 25))
		.canFocus_(false)
		.border_(1).font_(Font("Avenir", 15)).knobSize_(0.1)
		.align_(\left).stringColor_(Color.white)
		.action_({ |s| volBus.set(spec.mainVol.at(s.value)); s.string = " " + spec.mainVol.at(s.value).ampdb.round(0.1) + "db" })
	);

	tRunOutVol = (StaticText(wConfig, Rect(450, 50, 100, 25))
		.font_(Font("Avenir", 12)).string_("Runout volume:  ").align_(\right)
	);
	sRunOutVol = (SmoothSlider(wConfig, Rect(550, 50, 200, 25))
		.canFocus_(false)
		.border_(1).font_(Font("Avenir", 15)).knobSize_(0.1)
		.align_(\left).stringColor_(Color.white)
		.action_({ |s| runOutBus.set(spec.runOutVol.at(s.value)); s.string = " " + spec.runOutVol.at(s.value).ampdb.round(0.1) + "db" })
	);

	tWaitTime = (StaticText(wConfig, Rect(450, 80, 100, 25))
		.font_(Font("Avenir", 12)).string_("Wait-time:  ").align_(\right)
	);
	sWaitTime = (SmoothSlider(wConfig, Rect(550, 80, 200, 25))
		.canFocus_(false)
		.border_(1).font_(Font("Avenir", 15)).knobSize_(0.1)
		.align_(\left).stringColor_(Color.white)
		.action_({ |s|
			if( (exciterMode+ultraMode+superMode)==0, {
				fSetWaitTime.value(spec.wait.at(s.value),"GUI")
			}, {
				fSetWaitTime.value(spec.wait.at(s.value),"ORIG")
			});
			s.string = " " + spec.wait.at(s.value).round(0.0001) + "sec";
		});
	);

	tTimeFactor = (StaticText(wConfig, Rect(450, 110, 100, 25))
		.font_(Font("Avenir", 12)).string_("Meta factor:  ").align_(\right)
	);
	sTimeFactor = (SmoothSlider(wConfig, Rect(550, 110, 200, 25))
		.canFocus_(false)
		.border_(1).font_(Font("Avenir", 15)).knobSize_(0.1)
		.align_(\left).stringColor_(Color.white)
		.action_({ |s|
			timeFactor = spec.timeFactor.at(s.value);
			s.string = " " + timeFactor.round(0.01);
			scoreModeLength = scoreModeLengthDefault * timeFactor
		})
	);

	lSynth = (StaticText(wConfig, Rect(450,140,100,25)).font_(Font("Avenir",12)).string_("Synth:  ")).align_(\right);
	pSynth = (PopUpMenu(wConfig, Rect(550,140,200,25))
		.font_(Font("Avenir",15)).canFocus_(false)
		.items_(synthList)
		.action_({ |p|
			rgbSynth = synthList[p.value]; // set synth
			nbrSoundLimit = synthSoundLimit[p.value]; // set upperlimit to number of synths
			("\nSynth changed to"+rgbSynth+"with SoundLimit"+nbrSoundLimit).postln;
		})
	);

	lFreqMap = (StaticText(wConfig, Rect(450,170,100,25)).font_(Font("Avenir",12)).string_("FreqMap:  ")).align_(\right);
	pFreqMap = (PopUpMenu(wConfig, Rect(550,170,200,25))
		.font_(Font("Avenir",15)).canFocus_(false)
		.items_(synthFreqMaps)
		.action_({ |p|
			case // set function to map freqs
			{ p.value == 0 }
			{
				fFreqMap = { arg rgb,tuple; rgb.collect {arg item, index; freqBase + ( spec.freqUniform.at(item)*(nbrY - tuple[0]) ) } };
				"Frequency mapping set to uniform".postln;
				spec.freqUniform.postcs;
			}
			{ p.value == 1 }
			{
				fFreqMap = { arg rgb,tuple; rgb.collect {arg item, index; freqBase + ( spec.freqSpread[index].at(item)*(nbrY - tuple[0]) ) } };
				"Frequency mapping set to spread".postln;
				spec.freqSpread.postcs;
			}
			{ p.value == 2 }
			{
				fFreqMap = { arg rgb,tuple; rgb.collect {arg item, index; freqBase + ( spec.freqSpreadNarrow[index].at(item)*(nbrY - tuple[0]) ) } };
				"Frequency mapping set to spreadNarrow".postln;
				spec.freqSpreadNarrow.postcs;
			}
			;
		})
	);

	tMIDImap = (View(wConfig, Rect(10,220,wConfig.bounds.width - 20,300))
		.backgroundImage_( Image.new(dataDir++"Images/icontrols.png") );
	);

	tSetlist[0] = (StaticText(wConfig, Rect(40,480,130,160))
		// .background_(Color.white)
		.font_(Font("Avenir", 14)).align_(\topLeft).string_(setlist[0])).visible_(live);

	tSetlist[1] = (StaticText(wConfig, Rect(170,480,300,160))
		// .background_(Color.white)
		.font_(Font("Avenir", 14)).align_(\topLeft).string_(setlist[1])).visible_(live);

	tSetlist[2] = (StaticText(wConfig, Rect(400,480,350,160))
		// .background_(Color.white)
		.font_(Font("Avenir", 14)).align_(\topLeft).string_(setlist[2])).visible_(live);

	wConfig.view.keyDownAction = {
		arg view, char, modifiers, unicode, keycode;
		fKeyDown.value(modifiers, keycode);
	};

	wBoxes.view.keyDownAction = {
		arg view, char, modifiers, unicode, keycode;
		fKeyDown.value(modifiers, keycode);
	};

	// ------- GUI part 3 cue window ------------------------------------------------------------------------------------

	if(showCueWindow, {
		wCue = Window.new("Cues", Rect(0 - leftCueSubtract, 0 - topSubtract, 1020, 750));
		lCue = (StaticText(wCue, Rect(20, 20, 980, 100))
			.font_(Font(Font.default, 20))
			.string_("[ Point-to-Organ ]")
			.align_(\center)
		);
		tCue = (StaticText(wCue, Rect(20, 120, 980, 400))
			.font_(Font(Font.default, 150))
			.stringColor_(cueTextColor)
			.string_("---")
			.align_(\center)
			.background_(cueColor)
		);
		wCue.view.keyDownAction = {
			arg view, char, modifiers, unicode, keycode;
			fKeyDown.value(modifiers, keycode);
		};
		wCue.onClose = {
			showCueWindow = false;
			cueBlinkTask.stop;
		};
	});


	// ------- GUI part 4 on close ------------------------------------------------------------------------------------

	wBoxes.onClose = {
		fTaskMain.value(\kill); // stop all tasks
		taskAlpha.stop; taskArduino.stop;
		wConfig.close;
		if(showCueWindow, { wCue.close });
		MIDIdef.freeAll;
		exciterClock.clear;
		fYellowButtonTimeOut.value(\reset);
		if((arduinoSms != nil), { arduinoSms.close });
		{ main.release; synth.release; main.free; synth.free; }.defer(3);
	};

	wConfig.onClose = {
		wBoxes.close;
		if(showCueWindow, { wCue.close });
	};

	// ------- initialize ------------------------------------------------------------------------------------

	sMainVol.valueAction_(0.5);
	sRunOutVol.valueAction_(0.5);
	sWaitTime.valueAction_(spec.wait.asSpec.unmap(waitTime));
	sTimeFactor.valueAction_(spec.timeFactor.asSpec.unmap(timeFactor));
	pSynth.valueAction = synthList.indexOf(rgbSynth);
	pFreqMap.valueAction = synthFreqMaps.indexOf(synthFreqMap);
	pScoreMode.valueAction = scoreModeList.indexOf(scoreMode);

	mainSynth = Synth(\main, [\volBus, volBus.index], target: main);
	runoutSynth = Synth(\runout, [\runOutBus, runOutBus.index], target: synth);

	wDummy = Window("dummy").front.close;
	if(showConfigWindow, { wConfig.front });
	if(showCueWindow, { wCue.front });
	wBoxes.front;

	fSetGui.value;
	if(startTaskMain == 1, { fTaskMain.value() });
	fShowKeyShortcuts.value;
}
)



