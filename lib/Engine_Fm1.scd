// Engine_Fm1
Engine_Fm1 : CroneEngine {
	// <Fm1>
	var fm1Attack=0.01;
	var fm1Decay=2;
	var fm1Amp=0.5;
	// </Fm1>


	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		// <Fm1>
		// initialize synth defs
		SynthDef("Fm1",{
            arg hz=880,attack=0.01,decay=2,amp=0.5;
            var snd;
            snd=SinOsc.ar(hz,SinOsc.ar([135,138]/220*hz)*0.35);
            snd=snd*EnvGen.ar(Env.perc(attack,decay,1.0,Select.kr(attack<decay,[[4,4.neg],4.neg])),doneAction:2);
            Out.ar(0,snd/6*amp);
		}).add;

		this.addCommand("hz","f",{ arg msg;
    		Synth("Fm1",[\hz,msg[1],\attack,fm1Attack,\decay,fm1Decay,\amp,fm1Amp]);
		});

		this.addCommand("attack","f",{ arg msg;
			fm1Attack=msg[1];
		});
		this.addCommand("decay","f",{ arg msg;
			fm1Decay=msg[1];
		});
		this.addCommand("amp","f",{ arg msg;
			fm1Amp=msg[1];
		});
		// </Fm1>
	}

	free {
		// <Fm1>
		// </Fm1>
	}
}
