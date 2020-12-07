/*
 * Print in Place Parametric Music Box
 * Copyright (C) 2020 Troy Mackay
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
 * https://github.com/tmackay/ParametrizedMusicBox 
 *
 */

include <SCCPv1.scad>

// this text will be put on top of the music cylinder
MusicCylinderName="Super Mario Bros";
// What font do you want to use for the text?
MusicCylinderNameFont="Liberation Mono:style=Bold";
// how large should the font be
MusicCylinderNameFontSize = 8;
// how deep should the name be carved in?
MusicCylinderNameDepth=0.5;
// the width of all the walls in the design.
wall=2.5;
// how many vibrating teeth should there be? (also number of available notes) You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
pinNrX = 12;
// what should the notes on the teeth be? Each note is encoded by 3 characters: note (C,D,E,F,G,A,B), then the accidental (#, b or blank), and then the a one digit octave. You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
teethNotes="G 0E 1G 1A 1Bb1B 1C 2D 2E 2F 2G 2A 2";
// how many time slots should there be, including the starting position? (If you make this much higher you should also increase musicCylinderTeeth) You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
pinNrY = 32;
// the actual song. each time slot has pinNrX characters. X marks a pin everything else means no pin. You can use the output of the generator for this field: http://www.wizards23.net/projects/musicbox/musicbox.html
pins="ooooooooXoooooooooooXoooooooooooXoooooooooXoooooooooooooXoooooooooooooXoooooooooooooXoooooooooooooooooooooooooooooXoooooooooooooooooooXooooooooooooooooooooooXoooooooooooooooooooooooooXoooooooooooooXooooooooooooooooooooooXooooooooooXooooooooooXoooooooooooooooooXoooooooooooooXooooooooooooXoooooooooXooooooooooooXoooooooooooooooooooooXoooooooooXooooooooooooXoooooooooXoooooo";
// the number of teeth on the music cylinder
musicCylinderTeeth = 24;
// Constants section
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
// diametral pitch of the gear (if you make it smaller the teeth become bigger (the addendum becomes bigger) I tink of it as teeth per unit :)
diametral_pitch = 0.96;
// the height of all the gears
gearH=6.6;
// direction that crank hast to be turned it to play the song (has a bug: music is played backwards in clockwise mode so better leave it counter clockwise)
crankDirection = 0; // [1:Clockwise, 0:CounterClockwise]
// used for clean CSG operations
epsilonCSG = 0.1;
teethH = 3*0.4;
pinH= 1;
pteethMinD = 1.2;
teethGap = 0.6;
pinD=1.2;
teethHolderW=5;
teethHolderH=5;
generateSupport=1;

// Gearbox Section
// TODO:Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1;
// Number of planet gears in gearbox
planets = 5; //[3:1:21]
// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
// Bearing height
bearing_h_ = 1;  //[0:0.01:5]
// Number of teeth in planet gears
pt = [4, 5, 5, 4];
// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of = [0, 0, 0, 0];
// number of teeth to twist across
nt = [1, 1, 1, 1];
// Sun gear multiplier
sgm = 1; //[1:1:5]
// Shaft diameter
shaft_d_ = 0; //[0:0.1:25]
// Outside Gear depth ratio
depth_ratio=0.25; //[0:0.05:1]
// Inside Gear depth ratio
depth_ratio2=0.5; //[0:0.05:1]
// Gear clearance
tol_=0.2; //[0:0.01:0.5]
// pressure angle
P=30; //[30:60]
// Chamfer exposed gears, top - watch fingers
ChamferGearsTop = 0;				// [1:No, 0.5:Yes, 0:Half]
// Chamfer exposed gears, bottom - help with elephant's foot/tolerance
ChamferGearsBottom = 0;				// [1:No, 0.5:Yes, 0:Half]
//Include a knob
Knob = 1;				// [1:Yes , 0:No]
//Diameter of the knob, in mm
KnobDiameter_ = 15.0;			//[10:0.5:100]
//Thickness of knob, including the stem, in mm:
KnobTotalHeight_ = 15;			//[10:thin,15:normal,30:thick, 40:very thick]
//Number of points on the knob
FingerPoints = 6;   			//[3,4,5,6,7,8,9,10]
//Diameter of finger holes
FingerHoleDiameter_ = 5; //[5:0.5:50]
TaperFingerPoints = true;			// true
// Simplified model without gears
draft = 1; // [0:No, 1:Yes]
// Outer teeth
outer_t = [5,7];

// Tolerances for geometry connections.
AT_=1/64;
// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;

// common calculated variables
musicH=pinNrX*(1.2+teethGap);
// Height of planetary layers (layer_h will be subtracted from gears>0)
gearH2 = (musicH+3*(teethGap-layer_h_)+teethHolderW-teethH-bearing_h_-layer_h_-teethHolderW+teethH)/2; // TODO: layer_h dependency?
gh_ = [gearH+bearing_h_-layer_h_,gearH2,gearH2,gearH+bearing_h_];
modules = len(gh_);
//outer_w=scl*outer_w_;
core_h = scl*addl(gh_,len(gh_));
//wall = scl*wall_;
bearing_h = scl*bearing_h_;
gh = scl*gh_;
//outer_d = outer_d_*scl;
layer_h = scl*layer_h_;
tol = scl*tol_;
AT=AT_*scl;
ST=AT*2;
TT=AT/2;

//// Derived Music stuff
circular_pitch = 180/diametral_pitch;
addendum = 1/diametral_pitch;
pinStepX = musicH/pinNrX;
pinStepY = 360/pinNrY;

teethW = pinStepX-teethGap;
maxTeethL=TeethLen(0); // convention index 0 is lowest note
///////////////////////

musicCylinderR = (musicCylinderTeeth/diametral_pitch)/2;
noteExtend = teethHolderW+maxTeethL + pteethMinD; 
maxMusicAddendum = 1.5*max(addendum, pinH);

// noteExtend in alpha angle projected to y and x-axis
noteExtendY = sin(noteAlpha)*noteExtend;
noteExtendX = cos(noteAlpha)*noteExtend;
noteBeta = asin(noteExtendY/musicCylinderR);

// musicCylinderR to intersection with noteExtend
musicCylinderRX = cos(noteBeta)*musicCylinderR;

negXEnd = -(noteExtendX+musicCylinderRX);

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

function AccidentalToNoteShift(l) = l=="#"?1:l=="b"?-1:l==" "?0:INVALID_ACCIDENTAL_CHECK_teethNotes();

// allow B and H
// todo allow big and small letters
function LetterToNoteIndex(l) = l=="C"?0:l=="D"?2:l=="E"?4:l=="F"?5:l=="G"?7:l=="A"?9:l=="H"?11:l=="B"?11:INVALID_NOTE_CHECK_teethNotes();

function LetterToDigit(l) = l=="0"?0:l=="1"?1:l=="2"?2:l=="3"?3:l=="4"?4:l=="5"?5:l=="6"?6:l=="7"?7:l=="8"?8:l=="9"?9:INVALID_DIGIT_IN_OCTAVE_CHECK_teethNotes();

module Pin() {
  difference() {
    translate([-pinStepX/2,-pinD/2,-pinH])
      cube([pinStepX+4*teethGap, pinD, 2*(pinH+0.15)],center=false);
    translate([pinStepX/2,0,0])
      rotate([0,-35,0]) translate([4.0*pinStepX,0,0]) cube([8*pinStepX,8*pinStepX,8*pinStepX],center=true);
  }
}

module MusicCylinder(extra=0){
  difference(){
    translate([0,0,teethGap])for (x = [0:pinNrX-1], y = [0:pinNrY-1])
      if (pins[y*pinNrX + (pinNrX-x-1)] == "X")
        rotate([0,0, y * pinStepY + 180 + 360/pinNrY])
          translate([musicCylinderR, 0, (0.5+x)*pinStepX])
            rotate([0,90,0])
              Pin();
    translate([0,0,-gearH])
      cylinder(r=musicCylinderR-AT,h=musicH+2*gearH+3*teethGap+AT);
  }
}

module MusicBox(){
  translate([teethHolderW+maxTeethL,0,0])rotate([180,0,0]){
    // teeth
    for (x = [0:pinNrX-1]){
      ll = TeethLen(x);
      translate([-ll, x *pinStepX + teethGap, 0])
        translate([-teethHolderW/2, teethGap,-teethH/2])
          color([0,1,0])cube([ll+teethHolderW/2, teethW, teethH]);
      if(generateSupport&&teethGap+epsilonCSG>3*layer_h)translate([teethH, x *pinStepX + teethGap, 0])
        translate([-teethHolderW/2, layer_h,-teethH/2])
          color([1,0,0])cube([teethH, teethGap-2*layer_h, teethH]);
	}
    if(generateSupport&&teethGap+epsilonCSG>3*layer_h)translate([teethH, pinNrX *pinStepX + teethGap, 0])
      translate([-teethHolderW/2, layer_h,-teethH/2])
        color([1,0,0])cube([teethH, teethGap-2*layer_h, teethH]);
    // teeth holder
    difference(){
      hull()for (x = [0:pinNrX-1]){
        ll = TeethLen(x);
        leftAdd = (x == 0) ? (teethHolderW-teethH)/2+2*teethGap : 0;
        rightAdd = (x == pinNrX-1) ? (teethHolderW-teethH)/2+teethGap : 0;
        translate([-teethHolderW, x *pinStepX + teethGap, 0])
          translate([-ll, teethGap-leftAdd, -teethHolderW/2])
            cube([teethHolderW, pinStepX+leftAdd+rightAdd, teethHolderH]);
      }
      for (x = [0:pinNrX-1]){
        ll = TeethLen(x);
        leftAdd = (x == 0) ? (teethHolderW-teethH)/2+2*teethGap : 0;
        translate([-teethHolderW*0, x *pinStepX + teethGap, -TT])
          translate([-ll, teethGap-epsilonCSG-leftAdd, -teethHolderW/2])
            cube([maxTeethL, pinStepX+epsilonCSG+leftAdd, teethHolderH+AT]);
      }
      // teeth strain relief
      for (x = [0:pinNrX-1]){
        ll = TeethLen(x);
        translate([-ll, x *pinStepX + teethGap, 0])
          translate([-teethHolderW/2, teethGap,-teethH/2-AT])
            color([0,1,0])cube([ll+teethHolderW/2, teethW, teethH+ST]);
      }
    }
  }
  difference(){
    union(){
      hull(){
        translate([0,(teethHolderW-teethH)/2-teethGap,-teethHolderW/2])
          cube([-negXEnd-musicCylinderR+musicCylinderR-sqrt(musicCylinderR*musicCylinderR-teethHolderW*teethHolderW/4),gearH+teethGap-(teethHolderW-teethH)/2,teethHolderW]);
        translate([0,0,-teethH/2])
          cube([-negXEnd-musicCylinderR,gearH,teethH]);
        translate([teethHolderW+maxTeethL,0,0])rotate([180,0,0])  
          translate([-maxTeethL, (-1) *pinStepX + teethGap, 0])
            translate([-teethHolderW/2, teethGap,-teethH/2])
              cube([maxTeethL+teethHolderW/2, teethW, teethH]);
      }
      hull(){
        translate([0,(teethHolderW-teethH)/2-teethGap,-teethHolderW/2])
          cube([-negXEnd,gearH+teethGap-(teethHolderW-teethH)/2,teethHolderW]);
        translate([0,0,-teethH/2])
          cube([-negXEnd,gearH,teethH]);
      }
      hull(){
        translate([maxTeethL-TeethLen(pinNrX-1),-musicH-gearH-3*teethGap,-teethHolderW/2])
          cube([-negXEnd-musicCylinderR-maxTeethL+TeethLen(pinNrX-1)+musicCylinderR-sqrt(musicCylinderR*musicCylinderR-teethHolderW*teethHolderW/4),gearH+teethGap-(teethHolderW-teethH)/2,teethHolderW]);
        translate([maxTeethL-TeethLen(pinNrX-1),-musicH-gearH-3*teethGap,-teethH/2])
          cube([-negXEnd-musicCylinderR-maxTeethL+TeethLen(pinNrX-1),gearH,teethH]);
        translate([teethHolderW+maxTeethL,0,0])rotate([180,0,0])  
          translate([-TeethLen(pinNrX-1), (pinNrX) *pinStepX + teethGap, 0])
            translate([-teethHolderW/2, teethGap,-teethH/2])
              cube([TeethLen(pinNrX-1)+teethHolderW/2, teethW, teethH]);
      }
      hull(){
        translate([maxTeethL-TeethLen(pinNrX-1),-musicH-gearH-3*teethGap,-teethHolderW/2])
          cube([-negXEnd-maxTeethL+TeethLen(pinNrX-1),gearH+teethGap-(teethHolderW-teethH)/2,teethHolderW]);
        translate([maxTeethL-TeethLen(pinNrX-1),-musicH-gearH-3*teethGap,-teethH/2])
          cube([-negXEnd-maxTeethL+TeethLen(pinNrX-1),gearH,teethH]);
      }
    }    
    translate([-negXEnd,-musicH-gearH-3*teethGap-TT,0])
      rotate([-90,0,0])cylinder(r=musicCylinderR-AT,h=musicH+2*gearH+3*teethGap+AT);
  }
}

function substr(s,st,en,p="") = (st>=en||st>=len(s))?p:substr(s,st+1,en,str(p,s[st]));

function split(h,s,p=[]) = let(x=search(h,s))x==[]?concat(p,s):
    let(i=x[0],l=substr(s,0,i),r=substr(s,i+1,len(s)))split(h,r,concat(p,l));

translate([0,0,gearH]){
  // piano teeth
  rotate([90,0,0])
    translate([-(noteExtendX+musicCylinderRX),musicH+3*teethGap,0])
      MusicBox();
  // music cylinder
  MusicCylinder();
}

difference(){
  scale(1/1000)gearbox( // scale helps with internal faces
    gen = undef, scl = 1000, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
    sgm = sgm, outer_d_ = musicCylinderR*2, wall_ = wall, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
    depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
    ChamferGearsBottom = ChamferGearsBottom, Knob = Knob, KnobDiameter_ = KnobDiameter_,
    KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
    TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
  );
  if(len(MusicCylinderName)>0)for(i=[0:1],j=[0:len(MusicCylinderName)-1])
    translate([0,0,i*(4*gearH2+gh_[0]+gh_[modules-1]/4-gh_[0]/4+bearing_h_)+gh_[0]/4])
      rotate([90,0,j*180/(len(MusicCylinderName)-1)])translate([0,0,musicCylinderR-MusicCylinderNameDepth])
        linear_extrude(2*MusicCylinderNameDepth+tol)
          scale(min(1.5*PI*musicCylinderR/len(MusicCylinderName),gearH)/MusicCylinderNameFontSize)
            text(MusicCylinderName[j],font=MusicCylinderNameFont,size=MusicCylinderNameFontSize,$fn=4,valign="baseline",halign="center");
}