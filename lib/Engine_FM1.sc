// Engine_FM1
Engine_FM1 : CroneEngine {
	// <FM1>
	var FM1BusFx;
	var FM1ReverbSyn;
	// </FM1>
	
	
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {
		
		// <FM1>
		
		// initialize synth defs
		SynthDef("FM1", {
			arg freq=500, mRatio=1, cRatio=1,
			index=1, iScale=5, cAtk=4, cRel=(-4),
			amp=0.2, atk=0.01, rel=3, pan=0,
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
			env = EnvGen.kr(Env.perc(atk,rel,curve:[cAtk,cRel]),doneAction:2);
			
			//modulator/carrier
			mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
			car = SinOsc.ar(freq * cRatio + mod) * env * amp;
			
			car = Pan2.ar(car, pan);
			
			//direct out/reverb send
			Out.ar(out, car);
			Out.ar(fx, car * fxsend.dbamp);
		}).add;
		
		//reverb
		SynthDef("FM1FX", {
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
		FM1BusFx = Bus.audio(context.server,2);
		context.server.sync;
		FM1ReverbSyn=Synth("FM1FX",[\in,FM1BusFx],context.server);
		context.server.sync;
		
		this.addCommand("fm1_lead","f",{ arg msg;
			Synth.before(FM1ReverbSyn,"FM1",[
				\freq,msg[1],
				\amp,msg[1],
				\pan,msg[1],
				\cAtk,msg[2],
				\cRel,msg[3],
				\mRatio,25,
				\index,exprand(2,2.5),
				\iScale,1.2,
				\atk,exprand(0.02,0.1),
				\rel,0.03,
				\out,0,
				\fxsend,-15,
				\fx,FM1ReverbSyn,
			]);
		});
		// </FM1>
	}
	
	
	free {
		// <FM1>
		FM1BusFx.free;
		FM1ReverbSyn.free;
		// </FM1>
	}
}

