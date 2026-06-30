#!/bin/bash

# Generate the simulations.
bash simN1Intro.sh
bash simN1NoIntro.sh
bash simNIntro.sh
bash simNNoIntro.sh
bash simAdmNoIntro.sh
bash simAdmIntro.sh
bash simMolClock.sh
bash simADNA.sh
bash simDrift.sh

# Run D/D+/D* on simulated data.
bash popFiles.sh
bash runN1Intro.sh
bash runN1NoIntro.sh
bash runNIntro.sh
bash runNNoIntro.sh
bash runAdmNoIntro.sh
bash runAdmIntro.sh
bash runMolClock.sh
bash runADNA.sh
bash runDrift.sh
bash runDiploid.sh

bash performance.sh
