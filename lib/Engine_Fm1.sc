// Engine_Fm1
Engine_Fm1 : CroneEngine {
	// <Fm1>
	// </Fm1>


	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		// <Fm1>
		// initialize synth defs
		SynthDef("Fm1",{
            arg hz=880,amp=0.5,pan=0,attack=0.01,decay=2,fm_ratio=0.6,fm_amount=0.36;
            var snd;
            snd=Mix.ar(SinOsc.ar([hz,hz/2],SinOsc.ar(fm_ratio*hz)*fm_amount));
            snd=snd*EnvGen.ar(Env.perc(attack,decay,1.0,Select.kr(attack<decay,[[4,4.neg],4.neg])),doneAction:2);
			snd=Pan2.ar(snd,pan)
            Out.ar(0,snd/6*amp);
		}).add;

		this.addCommand("fm1","fffffff",{ arg msg;
    		Synth("Fm1",[
				\hz,msg[1],
				\amp,msg[2],
				\pan,msg[3],
				\attack,msg[4],
				\decay,msg[5],
				\fm_ratio,msg[6],
				\fm_amount,msg[7],
			]);
		});
		// </Fm1>
	}

	free {
		// <Fm1>
		// </Fm1>
	}
}
