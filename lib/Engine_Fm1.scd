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
            arg hz=880,attack=2,decay=1,amp=0.5;
            var snd;
            snd=SinOsc.ar(hz,SinOsc.ar([135,138]/220*hz)*0.35);
            snd=snd*EnvGen.ar(Env.perc(attack,decay,1.0,Select.kr(attack<decay,[[4,4.neg],4.neg])),doneAction:2);
            Out.ar(0,snd/6*amp);
		}).add;

		this.addCommand("hz","f",{ arg msg;
    		Synth("Fm1",[\hz,msg[1]]);
		});
		// </Fm1>
	}

	free {
		// <Fm1>
		// </Fm1>
	}
}
