/*
 * Fully Printed Parametric Music Box With Exchangeable Song-Cylinders
 * Copyright (C) 2013  Philipp Tiefenbacher <wizards23@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * The latest version can be found here:
 * https://github.com/wizard23/ParametrizedMusicBox 
 *
 * contibutions welcome! please send me pull requests!
 *
 * This project was started for the Thingiverse Customizer challenge
 * and is online customizable here:
 * http://www.thingiverse.com/thing:53235/ 
 *
 *
 * Changelog:
 *
 * 2013-03-09, wizard23
 * added name of song using write.scad
 * fixed pulley position on print plate
 *
 */

// this text will be put on top of the music cylinder
MusicCylinderName="test song";
// What font do you want to use for the text?
MusicCylinderNameFont="write/Letters.dxf"; //["write/Letters.dxf":Basic,"write/orbitron.dxf":Futuristic,"write/BlackRose.dxf":Fancy]
// how large should the font be
MusicCylinderNameFontSize = 8;
// how deep should the name be carved in?
MusicCylinderNameDepth=0.6;
// should the text be on the top or on the bottom of the music cylinder?
MusicCylinderNamePosition=0; // [0:top, 1:bottom]

// the width of all the walls in the design.
wall=4;

// how many vibrating teeth should there be? (also number of available notes) You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
pinNrX = 13;

// what should the notes on the teeth be? Each note is encoded by 3 characters: note (C,D,E,F,G,A,B), then the accidental (#, b or blank), and then the a one digit octave. You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
teethNotes="C 0C#0D 0D#0E 0F 0F#0G 0G#0A 0A#0B 0C 1C#1D 1D#1E 1F 1";

// how many time slots should there be? (If you make this much higher you should also increase musicCylinderTeeth) You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
pinNrY = 35;

// the actual song. each time slot has pinNrX characters. X marks a pin everything else means no pin. You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
pins="XoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooXooXoooooooooooooooooooXoooXooXoooooooooooooooooooXoooXooXoooooooooooooooooooXoooXooXoooooooooooooooooooXoooXooXoooooooooooooooooooXoooXooXoooooooooooooXooXoooXoooooooooooooooooooXooXoooXoooooooooooooooooooXooXoooXoooooooooooooooooooXooXoooXoooooooooooooooooooXooXoooXoooooooooooooooooooXooXoooX";

// the number of teeth on the music cylinder
musicCylinderTeeth = 24;

// nr of teeth on small transmission gear
midSmallTeeth = 8;
// nr of teeth on big transmission gear (for highest gear ratio this should be comparable but slightly smaller than musicCylinderTeeth)
midBigTeeth = 20;
// nr of teeth on crank gear
crankTeeth = 8;

//// Constants 

// the density of PLA (or whatever plastic you are using) in kg/m3 ((( scientiffically derived by me by taking the average of the density values I could find onthe net scaled a little bit to take into account that the print is not super dense (0.7 * (1210 + 1430)/2) )))
ro_PLA = 924; 
// elasticity module of the plastic you are using in N/m2 ((( derived by this formula I hope I got the unit conversion right 1.6*   1000000 *(2.5+7.8)/2 )))
E_PLA = 8240000; 
// the gamma factor for the geometry of the teeth (extruded rectangle), use this to tune it if you have a finite state modell of the printed teeth :) taken from http://de.wikipedia.org/wiki/Durchschlagende_Zunge#Berechnung_der_Tonh.C3.B6he
gammaTooth = 1.875; 
// the frequency of C0 (can be used for tuning if you dont have a clue about the material properties of you printing material :)
baseFrequC0 = 16.3516;


// the angle of the teeth relative to the cylinder (0 would be normal to cylinder, should be some small (<10) positive angle)
noteAlpha = 5;
// the transmission gears angle (to help get the music cylinder out easily this should be negative)
midGearAngle=-5;
// should be positive but the gear must still be held by the case...TODO: calculate this automagically from heigth and angle...
crankGearAngle=15;

// diametral pitch of the gear (if you make it smaller the teeth become bigger (the addendum becomes bigger) I tink of it as teeth per unit :)
diametral_pitch = 0.6;
// the height of all the gears
gearH=7.5;

// direction that crank hast to be turned it to play the song (has a bug: music is played backwards in clockwise mode so better leave it counter clockwise)
crankDirection = 0; // [1:Clockwise, 0:CounterClockwise]


// HoldderH is the height of the axis kegel

// how far should the snapping axis that holds the crank gear be? (should smaller than the other two because its closer to the corner of the case)
crankAxisHolderH = 1.55;
// how far should the snapping axis that holds the transmission gear be?
midAxisHolderH=3.3;
// how far should the snapping axis that holds the music cylinder be?
musicAxisHolderH=3.4;

pulleySlack=0.4;
crankSlack=0.2;
// for extra distance from axis to gears
snapAxisSlack=0.35; 
// for crank gear axis to case
axisSlack=0.3; 

// cutout to get Pulley in
pulleySnapL=1.2; 
// higher tolerance makes the teeth thinner and they slip, too low tolerance jams the gears
gear_tolerance = 0.1;
// used for the distance between paralell gears that should not touch (should be slightly larger than your layer with) 
gear_gap = 1;
gear_min_gap = 0.1;
gear_hold_R = 4;

// used for clean CSG operations
epsilonCSG = 0.1;
// reduce this for faster previews
$fn=32;
// Replace Gears with Cylinders to verify gear alignment
DEBUG_GEARS=0; // [1:yes, 0:no]


crankAxisR = 3;
crankAxisCutAway = crankAxisR*0.8;
crankLength = 18;
crankAxisCutAwayH = 4;

crankExtraH=4;
crankH=crankExtraH+2*crankAxisCutAwayH;


pulleyH=10;
pulleyR=crankAxisR+wall;






/// music section

// also nr of notes

     

teethH = 4*0.4;

pinH= 3;
pteethMinD = 1.5;

teethGap = 0.2;

pinD=1.5;

teethHolderW=5;
teethHolderH=5;





circular_pitch = 180/diametral_pitch;

addendum = 1/diametral_pitch;


musicH=pinNrX*(wall+teethGap);

echo("height of song cylinder");
echo(musicH);

//// Derived Music stuff


pinStepX = musicH/pinNrX;
pinStepY = 360/pinNrY;

teethW = pinStepX-teethGap;
maxTeethL=TeethLen(0); // convention index 0 is lowest note
///////////////////////



musicCylinderR = (musicCylinderTeeth/diametral_pitch)/2;
midSmallR = (midSmallTeeth/diametral_pitch)/2;
midBigR = (midBigTeeth/diametral_pitch)/2;
crankR = (crankTeeth/diametral_pitch)/2;

centerForCrankGearInsertion=(midBigR+crankR)/2;





//noteExtend = wall+20;
noteExtend = teethHolderW+maxTeethL + pteethMinD; 

midGearDist = musicCylinderR+midSmallR;
crankDist = midBigR+crankR;

midGearXPos = cos(midGearAngle)*midGearDist;
midGearZPos = sin(midGearAngle)*midGearDist;

crankGearXPos = midGearXPos + cos(crankGearAngle)*crankDist;
crankGearZPos = midGearZPos + sin(crankGearAngle)*crankDist;

echo("R of song cylinder");
echo(musicCylinderR);
maxMusicAddendum = 1.5*max(addendum, pinH);
frameH = max(musicCylinderR, -midGearZPos+midBigR) + maxMusicAddendum;

gearBoxW = 2 * (gearH+gear_gap+wall) + gear_gap;


songH = musicH+teethGap+teethGap;
frameW = gearBoxW + songH;



// noteExtend in alpha angle projected to y and x-axis
noteExtendY = sin(noteAlpha)*noteExtend;
noteExtendX = cos(noteAlpha)*noteExtend;
echo(noteExtendY/musicCylinderR);
noteBeta = asin(noteExtendY/musicCylinderR);

echo("Note Extend");
echo(noteExtendX);

// musicCylinderR to intersection with noteExtend
musicCylinderRX = cos(noteBeta)*musicCylinderR;




negXEnd = -(noteExtendX+musicCylinderRX);
posXEnd = crankGearXPos + crankR + 1.5*addendum + wall;

posYEnd = tan(noteAlpha)*(noteExtendX + musicCylinderRX+posXEnd);

echo("Testing NoteToFrequ, expected freq is 440");
echo(NoteToFrequ(9, 4, 0));


//// SPECFIC functions
function TeethLen(x) = 
	1000*LengthOfTooth(NoteToFrequ(LetterToNoteIndex(teethNotes[x*3]), 
			LetterToDigit(teethNotes[x*3+2]),
			AccidentalToNoteShift(teethNotes[x*3+1])),
			teethH/1000, E_PLA, ro_PLA);



//// PLATONIC functions
// http://de.wikipedia.org/wiki/Durchschlagende_Zunge#Berechnung_der_Tonh.C3.B6he
// f [Hz]
// h m
// E N/m2
// ro kg/m3
function LengthOfTooth(f, h, E, ro) = sqrt((gammaTooth*gammaTooth*h/(4*PI*f))*sqrt(E/(3*ro)));

function NoteToFrequ(note, octave, modification) = baseFrequC0*pow(2, octave)*pow(2, (note+modification)/12);

function AccidentalToNoteShift(l) =
l=="#"?1:
l=="b"?-1:
l==" "?0:
INVALID_ACCIDENTAL_CHECK_teethNotes();

// allow B and H
// todo allow big and small letters
function LetterToNoteIndex(l) =
l=="C"?0:
l=="D"?2:
l=="E"?4:
l=="F"?5:
l=="G"?7:
l=="A"?9:
l=="H"?11:
l=="B"?11: 
INVALID_NOTE_CHECK_teethNotes();

function LetterToDigit(l) = 
l=="0"?0:
l=="1"?1:
l=="2"?2:
l=="3"?3:
l=="4"?4:
l=="5"?5:
l=="6"?6:
l=="7"?7:
l=="8"?8:
l=="9"?9:
INVALID_DIGIT_IN_OCTAVE_CHECK_teethNotes();


module Pin() {
  difference() {
    translate([-pinStepX/2,-pinD/2,-pinH])
      cube([pinStepX+4*teethGap, pinD, 2*(pinH+0.15)],center=false);
    translate([pinStepX/2,0,0])
      rotate([0,-35,0]) translate([4.0*pinStepX,0,0]) cube([8*pinStepX,8*pinStepX,8*pinStepX],center=true);
  }
}

module MusicCylinder(extra=0){
  translate([0,0,-extra]) cylinder(r = musicCylinderR, h = teethGap+musicH+extra, center=false, $fn=128);
  translate([0,0,teethGap])
    for (x = [0:pinNrX-1], y = [0:pinNrY-1]){
      index = y*pinNrX + x;
      if (pins[index] == "X"){
        rotate([0,0, y * pinStepY])
          translate([musicCylinderR, 0, (0.5+x)*pinStepX])
            rotate([0,90,0])
              Pin();
      }
	}
    
  translate([0,0,-gearH]) cylinder(r = musicCylinderR, h = gearH, center=false, $fn=128);
  translate([0,0,musicH]) cylinder(r = musicCylinderR, h = gearH+3*teethGap, center=false, $fn=128);
}

module MusicBox(){
  translate([teethHolderW+maxTeethL,0,0])rotate([180,0,0]){
    for (x = [0:pinNrX-1]){
      ll = TeethLen(x);
      translate([-teethHolderW, x *pinStepX + teethGap, 0]){
        // teeth holder
        leftAdd = (x == 0) ? gearH : 0;
        rightAdd = (x == pinNrX-1) ? gearH : 0;
        translate([-ll, epsilonCSG-leftAdd, -teethHolderW/2])
          cube([teethHolderW, pinStepX+2*epsilonCSG+leftAdd+rightAdd, teethHolderH]);
      }
      translate([-ll, x *pinStepX + teethGap, 0]){
        // teeth
        translate([-teethHolderW/2, teethGap,-teethH/2])
          color([0,1,0])cube([ll+teethHolderW/2, teethW, teethH]);
      }
	}

    hull()for (x = [0:pinNrX-1:pinNrX-1]){
      ll = TeethLen(x);
      translate([-teethHolderW, x *pinStepX + teethGap, 0])
        translate([-ll, epsilonCSG, -teethHolderW/2])
          cube([teethHolderW/4, pinStepX+2*epsilonCSG, teethHolderH]);
    }
  }
  d = musicCylinderR - sqrt(musicCylinderR*musicCylinderR-teethHolderW*teethHolderW/4);
  hull(){
    translate([0,(teethHolderW-teethH)/2,-teethHolderW/2])
      cube([-negXEnd-musicCylinderR+(d),gearH-(teethHolderW-teethH)/2,teethHolderW]);
    translate([teethHolderW+maxTeethL,0,0])rotate([180,0,0])  
      translate([-maxTeethL, (-1) *pinStepX + teethGap, 0])
        translate([-teethHolderW/2, teethGap,-teethH/2])
          cube([maxTeethL+teethHolderW/2, teethW, teethH]);
  }
  hull(){
    translate([maxTeethL-TeethLen(pinNrX-1),-musicH-gearH-3*teethGap,-teethHolderW/2])
      cube([-negXEnd-musicCylinderR+(d)-maxTeethL+TeethLen(pinNrX-1),gearH-(teethHolderW-teethH)/2,teethHolderW]);
    translate([teethHolderW+maxTeethL,0,0])rotate([180,0,0])  
      translate([-TeethLen(pinNrX-1), (pinNrX) *pinStepX + teethGap, 0])
        translate([-teethHolderW/2, teethGap,-teethH/2])
          cube([TeethLen(pinNrX-1)+teethHolderW/2, teethW, teethH]);
  } 
}

// piano teeth
rotate([90,0,0])
  translate([-(noteExtendX+musicCylinderRX),musicH+3*teethGap,0])
    MusicBox();

// music cylinder
MusicCylinder();