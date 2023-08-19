(//stuff to get the server up & running
Server.default = Server.local;
o = Server.default.options;
o.memSize_(2.pow(20));
ServerOptions.devices;
o.inDevice_("MacBook Pro Microphone"); //set audio input device (if needed) here
o.outDevice_("MacBook Pro Speakers"); //set audio output here
s.reboot; //reboot server with our options in place
)

(//some useful arrays
~timer = LinkClock.new(120/60).latency_(Server.default.latency).quantum_(0); //set up clock (put desired bpm where the current bpm is)
~sound = Array.fill(64, {0}); //we'll store our synthdefs here
~note = Array.fill(64, {0}); //we'll store our note sequences here
~dur = Array.fill(64, {0}); //we'll store our timing sequences here
~modnums = Array.fill(64, {0});
~modenos = Array.fill(64, {0});
~panLFOs = Array.fill(64, {0});
~cutoffLFOs = Array.fill(64, {0});
~resonanceLFOs = Array.fill(64, {0});
~indexLFOs = Array.fill(64, {0});
~voices = [\1, \2, \3, \4, \5, \6, \7, \8];
~voiceManager = Array.fill(64, {PatternProxy(Pseq(~voices, inf)).asStream});
~bufs = Array.fill(64,{0});
~rates = Array.fill(64,{0});
~amps = Array.fill(64, {0});

//LFOs
64.do({
	arg i;
	~panLFOs.put(i,
		Ndef(i.asSymbol, {
			LFTri.kr(~timer.beatDur/rrand(2,16)).range(-1,1)
		})
	)
});
64.do({
	arg i;
	~cutoffLFOs.put(i,
		Ndef((i+64).asSymbol, {
			LFTri.kr(~timer.beatDur/rrand(2,512)).range(500,15000)
		})
	)
});
64.do({
	arg i;
	~resonanceLFOs.put(i,
		Ndef((i+128).asSymbol, {
			LFTri.kr(~timer.beatDur/rrand(2,512)).range(0,2)
		})
	)
});
64.do({
	arg i;
	~indexLFOs.put(i,
		Ndef((i+192).asSymbol, {
			LFTri.kr(~timer.beatDur/rrand(2,512)).range(-3,3)
		})
	)
});

//load samples
d = Dictionary.new;
d.add(\za ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/zall/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\l ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/606/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\m ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/808/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\h ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/909/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\zk ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/zkikz/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\zm ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/zmetal/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\zp ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/zpercz/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
d.add(\zs ->
	PathName(thisProcess.nowExecutingPath.dirname++"/samples/zsnarez/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
)

//the live-coding part
(
~sound.put(0, SinSin.new);
~sound[0].setParam('all',\reverb_amount,0.3);
~sound[0].setParam('all',\room_size,0.4);
~sound[0].setParam('all',\damp,0.5);
8.do({
	arg i;
	~sound[0].setParam((i+1).asSymbol,\pan,~panLFOs[i]);
	~sound[0].setParam((i+1).asSymbol,\cutoff,~cutoffLFOs[i]);
	~sound[0].setParam((i+1).asSymbol,\resonance,~resonanceLFOs[i]);
});
~note.put(0, PatternProxy(Pseq([25, 41, 51, 61], inf)).asStream);
~dur.put(0, PatternProxy(Pseq([0.5, 0.25, 0.25, 0.25, 0.25, 0.5, 1, 1],inf)).asStream);
~modnums.put(0, PatternProxy(Pseq([1,2,1,2],inf)).asStream);
~modenos.put(0, PatternProxy(Pseq([1,2,4,1],inf)).asStream);
Tdef(\0, {
	var delta, voice;
	loop {
		delta = ~dur[0].next;
		voice = ~voiceManager[0].next;
		~sound[0].setParam(voice,\attack,0);
		~sound[0].setParam(voice,\release,1);
		~sound[0].setParam(voice,\amp,0.5);
		~sound[0].setParam(voice,\pan_slew,0.1);
		~sound[0].setParam(voice,\index,1);
		~sound[0].setParam(voice,\modnum,~modnums[0].next);
		~sound[0].setParam(voice,\modeno,~modenos[0].next);
		~sound[0].setParam(voice,\freq_slew,[0,0.1].choose);
		~sound[0].setParam(voice,\cutoff_env,[0,1].choose);
		~sound[0].trigger(voice,(~note[0].next+36).midicps);
		delta.yield;
	}
}).clock_(~timer).quant_(4)
)

Tdef(\0).play(~timer, quant:4);
Tdef(\0).stop;

(
~sound.put(1, TriSin.new);
~sound[1].setParam('all',\reverb_amount,0.3);
~sound[1].setParam('all',\room_size,0.4);
~sound[1].setParam('all',\damp,0.5);
8.do({
	arg i;
	~sound[1].setParam((i+1).asSymbol,\pan,~panLFOs[i+8]);
	~sound[1].setParam((i+1).asSymbol,\cutoff,~cutoffLFOs[i+8]);
	~sound[1].setParam((i+1).asSymbol,\resonance,~resonanceLFOs[i+8]);
});
~note.put(1, PatternProxy(Pseq([25, 32, 25, 41], inf)).asStream);
~dur.put(1, PatternProxy(Pseq([2, 2, 4],inf)).asStream);
~modnums.put(1, PatternProxy(Pseq([1,2,1,2],inf)).asStream);
~modenos.put(1, PatternProxy(Pseq([4,2,4,1],inf)).asStream);
Tdef(\1, {
	var delta, voice;
	loop {
		delta = ~dur[1].next;
		voice = ~voiceManager[1].next;
		~sound[1].setParam(voice,\attack,2);
		~sound[1].setParam(voice,\release,2);
		~sound[1].setParam(voice,\amp,0.5);
		~sound[1].setParam(voice,\pan_slew,0.1);
		~sound[1].setParam(voice,\index,1);
		~sound[1].setParam(voice,\modnum,~modnums[1].next);
		~sound[1].setParam(voice,\modeno,~modenos[1].next);
		~sound[1].setParam(voice,\freq_slew,[0,0.1].choose);
		~sound[1].setParam(voice,\cutoff_env,[0,1].choose);
		~sound[1].trigger(voice,(~note[1].next+36).midicps);
		delta.yield;
	}
}).clock_(~timer).quant_(4)
)

Tdef(\1).play(~timer, quant: 4);
Tdef(\1).stop;

(
~sound.put(2, OneShot.new);
~dur.put(2, PatternProxy(Pseq([1],inf)).asStream);
~bufs.put(2, PatternProxy(Pseq([d[\zk][1], d[\zs][0]], inf)).asStream);
~rates.put(2, PatternProxy(Pseq([0.5, 0.5, 1], inf)).asStream);
~amps.put(2, PatternProxy(Pseq([1], inf)).asStream);
8.do({
	arg i;
	~sound[2].setParam((i+1).asSymbol,\cutoff,~cutoffLFOs[i+16]);
	~sound[2].setParam((i+1).asSymbol,\resonance,~resonanceLFOs[i+16]);
});
Tdef(\2, {
	var delta, voice;
	loop {
		delta = ~dur[2].next;
		voice = ~voiceManager[2].next;
		~sound[2].setParam(voice,\rate,~rates[2].next);
		~sound[2].setParam(voice,\amp,~amps[2].next);
		~sound[2].setParam(voice,\reverb_amount, 0);
		~sound[2].trigger(voice,~bufs[2].next);
		delta.yield;
	}
}).clock_(~timer).quant_(4)
)

Tdef(\2).play(~timer, quant: 4);
Tdef(\2).stop;

(
~sound.put(3, OneShot.new);
~dur.put(3, PatternProxy(Pseq([0.25],inf)).asStream);
~bufs.put(3, PatternProxy(Prand(d[\zp], inf)).asStream);
~rates.put(3, PatternProxy(Pseq([1], inf)).asStream);
~amps.put(3, PatternProxy(Pseq([0.95, Pexprand(0.5,0.75,0.7)], inf)).asStream);
8.do({
	arg i;
	~sound[3].setParam((i+1).asSymbol,\pan,~panLFOs[i+16]);
	~sound[3].setParam((i+1).asSymbol,\cutoff,~cutoffLFOs[i+16]);
	~sound[3].setParam((i+1).asSymbol,\resonance,~resonanceLFOs[i+16]);
});
Tdef(\3, {
	var delta, voice;
	loop {
		delta = ~dur[3].next;
		voice = ~voiceManager[3].next;
		~sound[3].setParam(voice,\rate,~rates[3].next);
		~sound[3].setParam(voice,\amp,~amps[3].next*0.75);
		~sound[3].setParam(voice,\reverb_amount, 0);
		~sound[3].trigger(voice,~bufs[3].next);
		delta.yield;
	}
}).clock_(~timer).quant_(4)
)

Tdef(\3).play(~timer, quant:4);
Tdef(\3).stop;

(
~sound.put(4, SinSin.new);
~sound[4].setParam('all',\reverb_amount,0.3);
~sound[4].setParam('all',\room_size,0.4);
~sound[4].setParam('all',\damp,0.5);
8.do({
	arg i;
	~sound[4].setParam((i+1).asSymbol,\pan,~panLFOs[i+24]);
	~sound[4].setParam((i+1).asSymbol,\cutoff,7000);
	~sound[4].setParam((i+1).asSymbol,\resonance,2);
});
~note.put(4, PatternProxy(Pseq([25, 41, 51, 61], inf)).asStream);
~dur.put(4, PatternProxy(Pseq([1.5],inf)).asStream);
~modnums.put(4, PatternProxy(Pseq([1,1,2],inf)).asStream);
~modenos.put(4, PatternProxy(Pseq([1,2,2,1],inf)).asStream);
Tdef(\4, {
	var delta, voice;
	loop {
		delta = ~dur[4].next;
		voice = ~voiceManager[4].next;
		~sound[4].setParam(voice,\attack,1);
		~sound[4].setParam(voice,\release,2);
		~sound[4].setParam(voice,\amp,0.5);
		~sound[4].setParam(voice,\pan_slew,0.1);
		~sound[4].setParam(voice,\index,1);
		~sound[4].setParam(voice,\modnum,~modnums[4].next);
		~sound[4].setParam(voice,\modeno,~modenos[4].next);
		~sound[4].setParam(voice,\freq_slew,[0,0.1].choose);
		~sound[4].setParam(voice,\cutoff_env,1);
		~sound[4].trigger(voice,(~note[4].next+36).midicps);
		delta.yield;
	}
}).clock_(~timer).quant_(4)
)

Tdef(\4).play(~timer, quant:4);
Tdef(\4).stop;

(//play everything
5.do({
	arg i;
	Tdef(i.asSymbol).play(~timer, quant:4);
})
)

(//stop everything
5.do({
	arg i;
	Tdef(i.asSymbol).stop;
})
)
