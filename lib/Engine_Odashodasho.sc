// Engine_Odashodasho
// this engine is based entirely off of Eli Fieldsteel's
// beautifully succinct FM synth: https://sccode.org/1-5bA
Engine_Odashodasho : CroneEngine {
	// <Odashodasho>
	var fm1Bus;
	var fm1Syn;
	var fm1Voices;
	var fm1DiskBus;
	var fm1DiskSyn;
	var fm1DiskBuf;
	var fm1SampleBuf;
	var fm1SampleSyn;
	// </Odashodasho>
	
	
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {
		
		// <Odashodasho>
		fm1Voices=Dictionary.new;
		fm1DiskBus=Dictionary.new;
		fm1DiskSyn=Dictionary.new;
		fm1DiskBuf=Dictionary.new;
		fm1SampleBuf=Dictionary.new;
		fm1SampleSyn=Dictionary.new;

		SynthDef("fm1Samples", {
			arg out=0, bufnum=0, loop=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=1,
			atk=0,rel=1, cAtk=4, cRel=(-4), amp=0.5,eqFreq=1200,eqDB=0,
			lpf=20000, diskout,fxsend=0,fx=0, pan=0;
			var snd,snd2,pos,pos2,frames,env;
			var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

			amp=Clip.kr(amp,0,4);
			frames = BufFrames.ir(bufnum);
			env = EnvGen.ar(Env.perc(atk+0.01,rel,curve:[cAtk,cRel]),gate:t_trig,doneAction:2);
				
				// playbuf
			snd = PlayBuf.ar(
				numChannels:2, 
				bufnum:bufnum,
				rate:rate*BufRateScale.kr(bufnum),
				startPos: ((start*(rate>0))*(frames))+(end*frames*(rate<0)),
				trigger:t_trig,
				loop:loop,
				doneAction:2,
			);

			snd=snd*env*amp/10;

			// add some boost
			snd=BPeakEQ.ar(snd,eqFreq,0.5,eqDB);
			
			// low-pass filter
			snd=LPF.ar(snd,lpf);

			DetectSilence.ar(snd,doneAction:2);

			snd = Pan2.ar(snd, pan);
			Out.ar(fx, snd * fxsend.dbamp);
			Out.ar(out,snd);
		}).add;

		SynthDef("fm1SamplesMono", {
			arg out=0, bufnum=0, loop=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=1,
			atk=0,rel=1, cAtk=4, cRel=(-4), amp=0.5,eqFreq=1200,eqDB=0,
			lpf=20000, diskout,fxsend=0,fx=0, pan=0;
			var snd,snd2,pos,pos2,frames,env;
			var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

			amp=Clip.kr(amp,0,4);
			frames = BufFrames.ir(bufnum);
			env = EnvGen.ar(Env.perc(atk+0.01,rel,curve:[cAtk,cRel]),gate:t_trig,doneAction:2);
				
				// playbuf
			snd = PlayBuf.ar(
				numChannels:1, 
				bufnum:bufnum,
				rate:rate*BufRateScale.kr(bufnum),
				startPos: ((start*(rate>0))*(frames))+(end*frames*(rate<0)),
				trigger:t_trig,
				loop:loop,
				doneAction:2,
			);

			snd=snd*env*amp/10;

			// add some boost
			snd=BPeakEQ.ar(snd,eqFreq,0.5,eqDB);
			
			// low-pass filter
			snd=LPF.ar(snd,lpf);

			DetectSilence.ar(snd,doneAction:2);

			snd = Pan2.ar(snd, pan);
			Out.ar(fx, snd * fxsend.dbamp);
			Out.ar(out,snd);
		}).add;

		SynthDef("diskout", { arg bufnum=0, inbus=0;
			DiskOut.ar(bufnum,In.ar(inbus,2));
		}).add;
		
		// initialize synth defs
		SynthDef("Odashodasho", {
			arg freq=500, mRatio=1, cRatio=1,
			index=1, iScale=5, cAtk=4, cRel=(-4),
			amp=0.2, atk=0.01, rel=3, pan=0,
			noise=0.0, natk=0.01, nrel=3,
			eqFreq=1200,eqDB=0,
			lpf=20000, diskout,
			out=0, fx=0, fxsend=(-25);
			var car, mod, env, iEnv;
			
			amp=Clip.kr(amp,0,4);

			//index of modulation
			iEnv = EnvGen.kr(
				Env(
					[index, index*iScale, index],
					[atk, rel],
					[cAtk, cRel]
				)
			);
			
			//amplitude envelope
			env = EnvGen.kr(Env.perc(atk,rel,curve:[cAtk,cRel]));
			
			// modulator/carrier
			mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
			car = SinOsc.ar(freq * cRatio + mod) * env;

			// add some chorus
			car=DelayC.ar(car, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );

			// add some noise 
			car=car+(WhiteNoise.ar(noise)*EnvGen.kr(Env.perc(natk,nrel)));
			
			// add some boost
			car=BPeakEQ.ar(car,eqFreq,0.5,eqDB);
			
			// low-pass filter
			car=LPF.ar(car,lpf);

			// panning
			car = Pan2.ar(car, pan);

			// scaling
			car = car * amp / 10;
			
			// kill the sound
			DetectSilence.ar(car,doneAction:2);

			//direct out/reverb send
			Out.ar(out, car);
			Out.ar(diskout,car);
			Out.ar(fx, car * Clip.kr(fxsend.dbamp));
		}).add;
		
		//reverb
		SynthDef("OdashodashoFX", {
			arg in=0, out=0, dec=4, lpf=1500;
			var sig;
			sig = In.ar(in, 2).sum;
			sig = DelayN.ar(sig, 0.03, 0.03);
			sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, dec);
			sig = SplayAz.ar(2, sig);
			sig = LPF.ar(sig, lpf);
			5.do{sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.099)}!2, 3)};
			sig = LPF.ar(sig, lpf);
			sig = LeakDC.ar(sig);
			Out.ar(out, sig);
		}).add;
		
		// initialize fx synth and bus
		context.server.sync;
		fm1Bus = Bus.audio(context.server,2);
		context.server.sync;
		fm1Syn=Synth("OdashodashoFX",[\in,fm1Bus],context.server);
		context.server.sync;
		
		this.addCommand("fm1sample","isffffffffffffs",{
			arg msg;
			var voice=msg[15].asString;
			var sample=msg[2].asString;
			var synName="fm1Samples";
			if (fm1SampleBuf.at(sample)==nil,{
				("loading sample "++sample).postln;
				fm1SampleBuf.put(sample,Buffer.read(context.server,sample,action:{
					arg bufnum;
					if (fm1SampleBuf.at(sample).numChannels<2,{
						synName="fm1SamplesMono";
					});
					Synth.before(fm1Syn,synName,[
						// \diskout,fm1DiskBus.at(voice),
						\bufnum,bufnum,
						\start,msg[3],
						\amp,msg[4],
						\pan,msg[5],
						\atk,msg[6],
						\rel,msg[7],
						\cAtk,msg[8],
						\cRel,msg[9],
						\rate,msg[10],
						\fxsend,msg[11],
						\eqFreq,msg[12],
						\eqDB,msg[13],
						\lpf,msg[14],
						\out,0,
						\fx,fm1Bus,
					]).onFree({
						NetAddr("127.0.0.1",10111)
							.sendMsg("odashodasho_voice",voice++" "++msg[1],0);
					});
				}));
			},{
				if (fm1SampleBuf.at(sample).numChannels<2,{
					synName="fm1SamplesMono";
				});
				Synth.before(fm1Syn,synName,[
					// \diskout,fm1DiskBus.at(voice),
					\bufnum,fm1SampleBuf.at(sample),
					\start,msg[3],
					\amp,msg[4],
					\pan,msg[5],
					\atk,msg[6],
					\rel,msg[7],
					\cAtk,msg[8],
					\cRel,msg[9],
					\rate,msg[10],
					\fxsend,msg[11],
					\eqFreq,msg[12],
					\eqDB,msg[13],
					\lpf,msg[14],
					\out,0,
					\fx,fm1Bus,
				]).onFree({
					NetAddr("127.0.0.1",10111)
						.sendMsg("odashodasho_voice",voice++" "++msg[1],0);
				});
			});
		});

		this.addCommand("fm1","ifffffffffffffffffsis",{ arg msg;
			var voice=msg[19];
			var record=msg[20];
			var recordPath=msg[21];
			if (fm1DiskBus.at(voice)==nil,{
				fm1DiskBus.put(voice,Bus.audio(context.server,2));
			});
			if (record>0,{
				// do record
				// if not recording, start recording
				if (fm1DiskSyn.at(voice)==nil,{
					var b=Buffer.alloc(context.server,65536,2);
					var pathname=recordPath.asString;
					("allocating buffer for "++voice++" to "++pathname).postln;
					b.write(pathname.standardizePath,PathName.new(pathname.standardizePath).extension,"int16",0,0,true);
					fm1DiskBuf.put(voice,b);
					fm1DiskSyn.put(voice,Synth.tail(nil,"diskout",
						[\bufnum,fm1DiskBuf.at(voice),\inbus,fm1DiskBus.at(voice)]
					));
					// initiate disk syn
				});
			},{
				// don't record
				// if recording, free everything
				if (fm1DiskSyn.at(voice)!=nil,{
					("stopping recording for "++voice).postln;
					fm1DiskSyn.at(voice).free;
					fm1DiskSyn.removeAt(voice);
					fm1DiskBuf.at(voice).free;
					fm1DiskBuf.removeAt(voice);
				});
			});
			Synth.before(fm1Syn,"Odashodasho",[
				\diskout,fm1DiskBus.at(voice),
				\freq,msg[1].midicps,
				\amp,msg[2],
				\pan,msg[3],
				\atk,msg[4],
				\rel,msg[5],
				\cAtk,msg[6],
				\cRel,msg[7],
				\mRatio,msg[8],
				\cRatio,msg[9],
				\index,msg[10],
				\iScale,msg[11],
				\fxsend,msg[12],
				\eqFreq,msg[13],
				\eqDB,msg[14],
				\lpf,msg[15],
				\noise,msg[16],
				\natk,msg[17],
				\nrel,msg[18],
				\out,0,
				\fx,fm1Bus,
			]).onFree({
				NetAddr("127.0.0.1",10111)
					.sendMsg("odashodasho_voice",voice++" "++msg[1],0);
			});
			// NodeWatcher.register(fm1Voices.at(fullname));
		});
		// </Odashodasho>
	}
	
	
	free {
		// <Odashodasho>
		fm1Bus.free;
		fm1Syn.free;
		fm1Voices.keysValuesDo({ arg key, value; value.free; });
		fm1DiskBus.keysValuesDo({ arg key, value; value.free; });
		fm1DiskSyn.keysValuesDo({ arg key, value; value.free; });
		fm1DiskBuf.keysValuesDo({ arg key, value; value.free; });
		fm1SampleBuf.keysValuesDo({ arg key, value; value.free; });
		fm1SampleSyn.keysValuesDo({ arg key, value; value.free; });
		// </Odashodasho>
	}
}

