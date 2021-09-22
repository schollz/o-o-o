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
            arg hz=880,amp=0.5,attack=0.01,decay=2,fm_ratio=0.6,fm_amount=0.36;
            var snd;
            snd=SinOsc.ar(hz,SinOsc.ar([fm_ratio,fm_ratio*1.05]*hz)*fm_amount);
            snd=snd*EnvGen.ar(Env.perc(attack,decay,1.0,Select.kr(attack<decay,[[4,4.neg],4.neg])),doneAction:2);
            Out.ar(0,snd/6*amp);
		}).add;

		this.addCommand("fm1","ffffff",{ arg msg;
    		Synth("Fm1",[
				\hz,msg[1],
				\amp,msg[2],
				\attack,msg[3],
				\decay,msg[4],
				\fm_ratio,msg[5],
				\fm_amount,msg[6],
			]);
		});
		// </Fm1>
	}

	free {
		// <Fm1>
		// </Fm1>
	}
}
