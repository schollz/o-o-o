// Engine_Odashodasho
// this engine is based entirely off of Eli Fieldsteel's
// beautifully succinct FM synth: https://sccode.org/1-5bA
Engine_Odashodasho : CroneEngine {
	// <Odashodasho>
	var fm1Bus;
	var fm1Syn;
	// </Odashodasho>
	
	
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {
		
		// <Odashodasho>
		
		// initialize synth defs
		SynthDef("Odashodasho", {
			arg freq=500, mRatio=1, cRatio=1,
			index=1, iScale=5, cAtk=4, cRel=(-4),
			amp=0.2, atk=0.01, rel=3, pan=0,
			noise=0.0, natk=0.01, nrel=3,
			eqFreq=1200,eqDB=0,
			lpf=20000,
			out=0, fx=0, fxsend=(-25);
			var car, mod, env, iEnv;
			
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
			Out.ar(fx, car * fxsend.dbamp);
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
		
		this.addCommand("fm1","ffffffffffffffffff",{ arg msg;
			Synth.before(fm1Syn,"Odashodasho",[
				\freq,msg[1],
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
			]);
		});
		// </Odashodasho>
	}
	
	
	free {
		// <Odashodasho>
		fm1Bus.free;
		fm1Syn.free;
		// </Odashodasho>
	}
}

