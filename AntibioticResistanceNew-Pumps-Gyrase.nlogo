breed [bacteria a-bacteria]

breed [antibiotics an-antibiotic]
breed [sparks spark]
globals[ticks-per-hour counts doses-a doses-b]
sparks-own[age]
antibiotics-own [speed]
bacteria-own[group pumps gyrase-resistance?]

to setup
  clear-all
  set doses-a 0
  set doses-b 0
  set counts [0 0 0]
  set ticks-per-hour 50
  ask patches [set pcolor 89]
  ask patches with [
    member? pycor (list max-pycor min-pycor) or
    member? pxcor (list max-pxcor min-pxcor 0)
  ]
  [
    set pcolor grey
  ]
  create-bacteria 1
  [
    set xcor -16
    set color 65
    set shape "bacteria8"
    set size 1.5
    set group 1
    set pumps 8
    set gyrase-resistance? false
  ]
  create-bacteria 1
    [
    set xcor 16
    set color 65
    set shape "bacteria8"
    set size 1.5
    set group 2
    set pumps 8
    set gyrase-resistance? false
  ]
  reset-ticks
end

to dose [g n]
  let p 0
  if-else g = 1
  [
    set p -31
  ]
  [
    set p 1
  ]
  create-antibiotics n [
    set ycor max-pycor - 0.5
    set xcor (random 31) + p
    set shape "circle"
    set size 0.3
    set color red
    set speed (random-float 0.2) + 0.1
    set heading (random 91) + 135
  ]
end

to move-antibiotics
  ask antibiotics [
    if random-float 1 < antibiotic-decay [die]
    if member? [pxcor] of patch-ahead speed (list max-pxcor min-pxcor 0)
    [
      set heading 360 - heading
    ]
    if [pycor] of patch-ahead speed = min-pycor
    [
      set ycor max-pycor - 0.5
    ]
    fd speed
    ask bacteria in-radius 0.5
    [
      let killed false
      if random-float 1 < (absorbtion-rate * (1 - (pumps / 12.0))  * ifelse-value gyrase-resistance? [0.4][1])
        ; denominator adjusts relative rate of bacteria death
      [
        set killed true
        antibiotic-kill
        die
      ]
      if killed [die]
    ]
  ]
end

to move-bacteria
  ask bacteria [
    lt (random 31) - 15
    if [pcolor] of patch-ahead 0.2 = grey [rt 180]
    fd (random 0.1) + 0.05
    if random-float 1 < (die-chance * ((item group counts) / crowding-factor)) [die]
    if random-float 1 < (divide-chance * (1 - (pumps / 16.0)) * ifelse-value gyrase-resistance? [0.5][1])
    ;denominator determines relative reproduction rate based on pumps
    [
      hatch-bacteria 1
      [
        if random-float 1 < mutation-rate
        [
          if-else random 2 = 1
          [set pumps [pumps] of myself + 1]
          [set pumps [pumps] of myself - 1]
          if pumps > 8 [set pumps 8]
          if pumps < 1 [set pumps 1]
          let cratio (pumps - 1) / 7.0
          set shape word "bacteria" pumps
          if (random 2 = 1 ) and ((group = 1 and sample-a-gyrase-mutation?) or (group = 2 and sample-b-gyrase-mutation?)) [
            if-else gyrase-resistance?
            [set gyrase-resistance? false]
            [set gyrase-resistance? true]
          ]
          if-else gyrase-resistance? [set color 115][set color 65]
          ;set color (list (124 - cratio * 80 )(80 - cratio * -129 )(164 - cratio * 105))
        ]
      ]
    ]
  ]
end

to move-sparks
  ask sparks
  [
    set age age + 1
    if age > 10 [die]
    fd 0.1
  ]

end

to antibiotic-kill
  let the-heading random 360
  repeat 6 [
    hatch-sparks 1
    [
      set shape "star"
      set size 0.5
      set age 0
      set color green
      set heading the-heading
    ]
    set the-heading the-heading + 60
  ]
end

to do-dosing
  if sample-a-auto-dose? and not (limit-doses-a and (doses-a = num-doses-a))
  [
    if (ticks - (sample-a-dose-delay * ticks-per-hour)) >= 0
    [
      if ((ticks - (sample-a-dose-delay * ticks-per-hour)) mod (sample-a-dose-frequency * ticks-per-hour)) = 0
      [
        if (random 100) > sample-a-dose-skip-chance
        [
          dose 1 sample-a-dose-size
          set doses-a doses-a + 1
        ]
      ]
    ]
  ]
  if sample-b-auto-dose? and not (limit-doses-b and (doses-b = num-doses-b))
  [
    if (ticks - (sample-b-dose-delay * ticks-per-hour)) >= 0
    [
      if ((ticks - (sample-b-dose-delay * ticks-per-hour)) mod (sample-b-dose-frequency * ticks-per-hour)) = 0
      [
        if (random 100) > sample-b-dose-skip-chance
        [
          dose 2 sample-b-dose-size
          set doses-b doses-b + 1
        ]
      ]
    ]
  ]
end


to go
  do-dosing
  move-antibiotics
  move-bacteria
  move-sparks
  set counts (list 0 (count bacteria with [group = 1]) (count bacteria with [group = 2]))
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
323
122
1176
560
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-32
32
-16
16
1
1
1
ticks
30.0

BUTTON
9
10
99
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
52
99
85
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
123
11
295
44
antibiotic-decay
antibiotic-decay
0
0.01
0.0035
0.00001
1
NIL
HORIZONTAL

SLIDER
124
53
296
86
die-chance
die-chance
0
0.01
7.0E-4
0.00001
1
NIL
HORIZONTAL

SLIDER
124
93
296
126
crowding-factor
crowding-factor
0.1
100
100.0
0.1
1
NIL
HORIZONTAL

SLIDER
124
132
296
165
divide-chance
divide-chance
0
0.01
0.01
0.00001
1
NIL
HORIZONTAL

PLOT
7
566
298
811
Bacteria Count
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Sample A" 1.0 0 -13345367 true "" "plot item 1 counts"
"Sample B" 1.0 0 -2674135 true "" "plot item 2 counts"

SLIDER
124
170
296
203
absorbtion-rate
absorbtion-rate
0
0.1
0.07
0.001
1
NIL
HORIZONTAL

SLIDER
322
11
504
44
sample-a-dose-delay
sample-a-dose-delay
0
48
24.0
1
1
hrs
HORIZONTAL

SWITCH
508
11
680
44
sample-a-auto-dose?
sample-a-auto-dose?
0
1
-1000

SLIDER
322
48
504
81
sample-a-dose-frequency
sample-a-dose-frequency
1
24
12.0
1
1
hrs
HORIZONTAL

SLIDER
508
49
680
82
sample-a-dose-size
sample-a-dose-size
100
1000
600.0
50
1
mg
HORIZONTAL

SLIDER
322
85
504
118
sample-a-dose-skip-chance
sample-a-dose-skip-chance
0
100
0.0
1
1
%
HORIZONTAL

SLIDER
742
12
924
45
sample-b-dose-delay
sample-b-dose-delay
1
48
24.0
1
1
hrs
HORIZONTAL

SLIDER
742
49
924
82
sample-b-dose-frequency
sample-b-dose-frequency
1
24
12.0
1
1
hrs
HORIZONTAL

SLIDER
742
86
924
119
sample-b-dose-skip-chance
sample-b-dose-skip-chance
0
100
0.0
1
1
%
HORIZONTAL

SWITCH
928
12
1100
45
sample-b-auto-dose?
sample-b-auto-dose?
0
1
-1000

SLIDER
928
50
1100
83
sample-b-dose-size
sample-b-dose-size
100
1000
600.0
50
1
mg
HORIZONTAL

SLIDER
124
207
296
240
mutation-rate
mutation-rate
0
1
0.1
0.01
1
NIL
HORIZONTAL

PLOT
324
566
746
812
Pump Counts Sample A
Number of Efflux Pumps
Bacteria Count
1.0
9.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [pumps] of bacteria with [group = 1]"

PLOT
750
566
1176
813
Pump Counts Sample B
Number of Efflux Pumps
Bacteria Count
1.0
9.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [pumps] of bacteria with [group = 2]"

MONITOR
5
93
116
138
Total Hours Running
ticks / ticks-per-hour
17
1
11

SWITCH
508
86
615
119
limit-doses-a
limit-doses-a
1
1
-1000

SWITCH
929
86
1036
119
limit-doses-b
limit-doses-b
1
1
-1000

SLIDER
618
86
730
119
num-doses-a
num-doses-a
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
1038
86
1150
119
num-doses-b
num-doses-b
0
100
11.0
1
1
NIL
HORIZONTAL

MONITOR
684
11
734
56
NIL
doses-a
17
1
11

MONITOR
1105
13
1162
58
NIL
doses-b
17
1
11

SWITCH
90
244
296
277
sample-a-gyrase-mutation?
sample-a-gyrase-mutation?
1
1
-1000

SWITCH
90
280
296
313
sample-b-gyrase-mutation?
sample-b-gyrase-mutation?
0
1
-1000

PLOT
7
316
298
561
Percentage with Gyrase Resistance
Ticks
Percentage (%)
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Sample A" 1.0 0 -13345367 true "" "plot 100 * count bacteria with [group = 1 and gyrase-resistance?] / ifelse-value item 1 counts = 0 [1][item 1 counts]"
"Sample B" 1.0 0 -2674135 true "" "plot 100 * count bacteria with [group = 2 and gyrase-resistance?] / ifelse-value item 2 counts = 0 [1][item 2 counts]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bacteria1
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 135 30

bacteria2
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 105 30
Circle -7500403 true true 135 165 30

bacteria3
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 105 30
Circle -7500403 true true 105 150 30
Circle -7500403 true true 165 150 30

bacteria4
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 75 30
Circle -7500403 true true 105 135 30
Circle -7500403 true true 135 195 30
Circle -7500403 true true 165 135 30

bacteria5
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 75 30
Circle -7500403 true true 105 120 30
Circle -7500403 true true 135 210 30
Circle -7500403 true true 165 120 30
Circle -7500403 true true 135 165 30

bacteria6
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 60 30
Circle -7500403 true true 105 105 30
Circle -7500403 true true 105 165 30
Circle -7500403 true true 135 210 30
Circle -7500403 true true 165 165 30
Circle -7500403 true true 165 105 30

bacteria7
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 60 30
Circle -7500403 true true 105 105 30
Circle -7500403 true true 105 165 30
Circle -7500403 true true 135 210 30
Circle -7500403 true true 165 165 30
Circle -7500403 true true 165 105 30
Circle -7500403 true true 135 135 30

bacteria8
true
0
Polygon -7500403 true true 135 30 165 30 195 45 210 75 225 120 225 180 210 225 195 255 165 270 135 270 105 255 90 225 75 180 75 120 90 75 105 45
Polygon -16777216 true false 120 60 150 45 180 60 195 90 210 135 210 165 195 210 180 240 150 255 120 240 105 210 90 165 90 135 105 90
Line -7500403 true 90 225 60 255
Line -7500403 true 210 225 240 255
Line -7500403 true 210 75 240 45
Line -7500403 true 90 75 60 45
Line -7500403 true 75 165 45 180
Line -7500403 true 225 165 255 180
Line -7500403 true 225 135 255 120
Line -7500403 true 75 135 45 120
Line -7500403 true 180 45 195 15
Line -7500403 true 180 255 195 285
Line -7500403 true 120 255 105 285
Line -7500403 true 120 45 105 15
Circle -7500403 true true 135 60 30
Circle -7500403 true true 105 90 30
Circle -7500403 true true 105 180 30
Circle -7500403 true true 135 210 30
Circle -7500403 true true 165 180 30
Circle -7500403 true true 165 90 30
Circle -7500403 true true 105 135 30
Circle -7500403 true true 165 135 30

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
