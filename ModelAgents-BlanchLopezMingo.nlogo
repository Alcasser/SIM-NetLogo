extensions [table]

breed [ trains train ]
breed [ stations station ]

globals [
  station-length
  ;max-capacity (slider)
  passengers-travelled
  total-minutes-waited
  mean-waiting-time
  ticks-per-minute
  distance-per-tick
  train-frequency-ticks
  hour
  minute
  second
]

trains-own [ ; TRAIN
  going-to-station ; Station which the train is going to
  num-passengers ; Current number of passengers
  minutes-between-stations ; Minutes needed to travel to the next station (in total)
  distance-travelled ; Distance travelled since last station
]

stations-own [ ; STATION
  station-num ; Station number
  passengers-waiting ; Number of passengers waiting
  p-waiting-num ; Number of people in each group of passengers waiting
  p-waiting-time ; Time (ticks) waiting in each group of passengers waiting
  ticks-from-last-train ; Ticks from last train departure
  p-left-num
  p-left-total-wait-time
]

to setup
  clear-all
  set-default-shape trains "train passenger car"
  set-default-shape stations "person"
  set station-length 8
  set passengers-travelled 0
  set total-minutes-waited 0
  set mean-waiting-time 0
  set ticks-per-minute 2
  set hour 8
  set minute 0
  set second 0
  setup-frequency
  draw-track
  draw-stations
  reset-ticks
end

to setup-frequency
  let exponential random-exponential train-frequency-exponential
  set train-frequency-ticks ceiling (ticks-per-minute * exponential)
end

to draw-track
  ask patches [
    ; the track is surrounded by green grass of varying shades
    set pcolor green - random-float 0.5
  ]
  ask patches with [ abs pycor < 1 ] [
    ; the track itself is varying shades of grey
    set pcolor grey - 2.5 + random-float 0.25
  ]
  ; draw-track-borders:
  draw-line 0 grey 0.5
end

to draw-stations
  ; paint stations
  ask patches with [ (pycor >= 2 and pycor <= 3) and (
    (pxcor mod station-length <= station-length - 2) and (pxcor mod station-length >= 2)) ]
    [ set pcolor blue ]
  ask patches with [ (pycor = 1) and (
    (pxcor mod station-length <= station-length - 4) and (pxcor mod station-length >= 4)) ]
    [ set pcolor blue ]
  ask patches with [ (pycor = 2) and (
    (pxcor mod station-length <= station-length - 4) and (pxcor mod station-length >= 4)) ]
    [
    ; create passengers waiting symbol which represents the station
    sprout-stations 1 [ setup-station floor (pxcor / station-length )]
  ]

  ; set station labels
  ask patches with [ pycor = 3 and (pxcor = 6) ] [ set plabel "Barcelona - Espanya" ]
  ask patches with [ pycor = 3 and (pxcor = 14) ] [ set plabel "Magòria - La Campana" ]
  ask patches with [ pycor = 3 and (pxcor = 21) ] [ set plabel "Ildefons Cerdà" ]
  ask patches with [ pycor = 3 and (pxcor = 28) ] [ set plabel "Gornal" ]
  ask patches with [ pycor = 3 and (pxcor = 37) ] [ set plabel "Sant Josep" ]
end

to setup-station [num]
  set ticks-from-last-train 0
  set station-num num
  set color grey
  set label passengers-waiting
  set p-waiting-num []
  set p-waiting-time []
  update-passengers-waiting
end

; GO & STEP

to go
  step
end

to step
  setup-frequency
  ifelse ticks = 0 [
    new-train
  ][
    if ticks mod train-frequency-ticks = 0 and not train-leaving-station-0 [
      new-train
    ]
  ]
  ask trains [ go-train ]
  ask stations [ go-station ]
  update-passengers-labels
  calculate-mean-waiting-time

  set hour 8 + (ticks / ticks-per-minute) / 60
  set minute ticks / ticks-per-minute mod 60
  set second (ticks mod ticks-per-minute) / ticks-per-minute * 60
  tick
end

to new-train
  create-trains 1
  [ set color one-of base-colors
    set size 1.8
    set label-color white
    set minutes-between-stations calcRand (mean-time-between-stations - 1) (mean-time-between-stations + 1)
    set distance-travelled station-length
    setxy 4 0.5
    set heading 0
    set going-to-station 0
    go-train
  ]
end

to go-station ; applied to a station
  set ticks-from-last-train ticks-from-last-train + 1
  update-waiting-times 1
  update-passengers-waiting
end

to go-train ; applied to a train
  set distance-per-tick station-length / (minutes-between-stations * ticks-per-minute)
  ifelse distance-travelled + distance-per-tick < station-length [
    ; moves the train (if it is not in a station)
    if not crashing going-to-station distance-travelled [
      set heading 90
      fd distance-per-tick
      set distance-travelled distance-travelled + distance-per-tick
    ]
  ][
    ; train arrives and leaves the station
      passengers-leave-the-train
      passengers-enter-the-train
      ; reset counters, update going-to-station and calculate minutes-between-stations
      set going-to-station (going-to-station + 1)
      set minutes-between-stations calcRand (mean-time-between-stations - 1) (mean-time-between-stations + 1)
      set distance-travelled 0
  ]
  if (going-to-station = 5 and distance-travelled > 4) [ die ]
end

to passengers-enter-the-train ; applied to a train
  let going-to-station-aux going-to-station
  let num-passengers-aux num-passengers
  ask stations with [ station-num = going-to-station-aux ] [
    let seats-available max-capacity - num-passengers-aux
    if (seats-available > 0) [
      print word "Station " station-num
      print word "Num passengers: " num-passengers-aux
      print word "Passengers queue (num): " p-waiting-num
      print word "Passengers queue (time): " p-waiting-time
      let entering 0
      while [not empty? p-waiting-num and seats-available > 0] [
        let p-num item 0 p-waiting-num
        let p-time item 0 p-waiting-time
        print word "Seats available: " seats-available
        print word "Num passengers: " p-num
        print word "Time waiting: " p-time
        ifelse p-num <= seats-available [
          set entering entering + p-num
          set seats-available seats-available - p-num
          set p-left-num p-left-num + entering
          set p-left-total-wait-time p-left-total-wait-time + (entering * p-time)
          set p-waiting-num remove-item 0 p-waiting-num
          set p-waiting-time remove-item 0 p-waiting-time
        ] [
          set entering entering + seats-available
          set p-num p-num - seats-available
          set passengers-travelled passengers-travelled + entering
          set total-minutes-waited total-minutes-waited + (entering * p-time)
          set p-waiting-num replace-item 0 p-waiting-num p-num
          set seats-available 0
        ]
      ]
      set num-passengers-aux num-passengers-aux + entering
      print word "Passengers queue (num): " p-waiting-num
      print word "Passengers queue (time): " p-waiting-time
      print (word "STATION " station-num ": " entering " passengers enter the train")
    ]
    set ticks-from-last-train 0
    update-passengers-waiting
  ]
  set num-passengers num-passengers-aux
end

to passengers-leave-the-train ; applied to a train
  let leaving 0
  if going-to-station = 1 [ set leaving calcRand 75 50 ]
  if going-to-station = 2 [ set leaving calcRand 100 75 ]
  if going-to-station = 3 [ set leaving calcRand 150 100 ]
  if going-to-station = 4 [ set leaving calcRand 200 100 ]

  ifelse num-passengers > leaving [
    set num-passengers num-passengers - leaving
  ] [
    set num-passengers 0
  ]
  print (word "STATION " going-to-station ": " leaving " passengers leave the train")
end

to calculate-mean-waiting-time
  set total-minutes-waited 0
  set passengers-travelled 0
  ask stations [
    set total-minutes-waited total-minutes-waited + p-left-total-wait-time
    set passengers-travelled passengers-travelled + p-left-num
  ]
  set mean-waiting-time total-minutes-waited / passengers-travelled
end

; updates the number and the label of the passengers waiting in a station
to update-passengers-waiting ; applied to a station
  let minutes-from-last-train ticks-from-last-train / ticks-per-minute
  let new-passengers 0
  if minutes-from-last-train =  0.0 [
    set new-passengers calcRand 100 200
    set p-waiting-num lput new-passengers p-waiting-num
    set p-waiting-time lput ticks-from-last-train p-waiting-time
  ]
  if minutes-from-last-train =  5.0 [
    set new-passengers calcRand 150 300
    set p-waiting-num but-last p-waiting-num
    set p-waiting-time but-last p-waiting-time
    set p-waiting-num lput new-passengers p-waiting-num
    set p-waiting-time lput ticks-from-last-train p-waiting-time
  ]
  if minutes-from-last-train = 10.0 [
    set new-passengers calcRand  50 300
    set p-waiting-num but-last p-waiting-num
    set p-waiting-time but-last p-waiting-time
    set p-waiting-num lput new-passengers p-waiting-num
    set p-waiting-time lput ticks-from-last-train p-waiting-time
  ]
  if minutes-from-last-train = 15.0 [
    set new-passengers calcRand 200 400
    set p-waiting-num but-last p-waiting-num
    set p-waiting-time but-last p-waiting-time
    set p-waiting-num lput new-passengers p-waiting-num
    set p-waiting-time lput ticks-from-last-train p-waiting-time
  ]
  let total 0
  foreach p-waiting-num [ n -> set total total + n ]
  ; print word "Waiting num: " p-waiting-num
  ;print word "Waiting time: " p-waiting-time
  set passengers-waiting total
  set label passengers-waiting
end

; UTILS

to draw-line [ y line-color gap ]
  create-turtles 1 [
    setxy (min-pxcor - 0.5) y
    hide-turtle
    set color line-color
    set heading 90
    repeat world-width [
      pen-up
      forward gap
      pen-down
      forward (1 - gap)
    ]
    die
  ]
end

to-report calcRand [maxi mini]
  report random(maxi - mini + 1) + mini
end

to update-passengers-labels ; applied to all trains
  ask trains [ set label num-passengers ]
end

; Updates the waiting times of the group of passengers in the station (adding the 'time' passed)
to update-waiting-times [ time ] ; applied to a station
  set p-waiting-time map [ t -> t + time ] p-waiting-time
end

to-report train-leaving-station-0
  let result false
  ask trains [
    if going-to-station = 1 and distance-travelled < 2 [
      set result true
    ]
  ]
  report result
end

to-report crashing [ gts dt ]
  let result false
  ask trains [
    if going-to-station = gts and dt >= distance-travelled - 2 and dt < distance-travelled [
      set result true
    ]
    if dt >= station-length - 1 and going-to-station = gts + 1 and distance-travelled <= 1 [
      set result true
    ]
  ]
  report result
end
@#$#@#$#@
GRAPHICS-WINDOW
10
11
813
97
-1
-1
19.4
1
10
1
1
1
0
1
0
1
0
40
0
3
1
1
1
ticks
30.0

BUTTON
10
100
75
135
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
160
100
223
135
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

BUTTON
85
100
150
135
step
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
445
100
655
133
max-capacity
max-capacity
0
500
303.0
1
1
passengers
HORIZONTAL

MONITOR
660
100
815
145
Mean wait time (min)
mean-waiting-time / ticks-per-minute
17
1
11

SLIDER
230
100
440
133
train-frequency-exponential
train-frequency-exponential
1
15
3.8
0.1
1
NIL
HORIZONTAL

MONITOR
1035
150
1085
195
hour
floor hour
17
1
11

MONITOR
1087
150
1137
195
minute
floor minute
17
1
11

MONITOR
1140
150
1190
195
NIL
second
17
1
11

SLIDER
1035
200
1190
233
mean-time-between-stations
mean-time-between-stations
1
10
3.5
0.5
1
NIL
HORIZONTAL

PLOT
10
150
210
285
Pass. at BCN-Espanya
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"passengers" 1.0 0 -2139308 true "" "ask stations with [ station-num = 0 ] [\n  let total 0\n  foreach p-waiting-num [ n -> set total total + n ]\n  plot total\n]"

PLOT
10
290
210
425
Wait time at BCN-Espanya
NIL
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "ask stations with [ station-num = 0 ] [\n  if p-left-num > 0 [\n    plot (p-left-total-wait-time / p-left-num) / ticks-per-minute\n  ]\n]"

PLOT
215
150
415
285
Pass. at Magòria-La Campana
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "ask stations with [ station-num = 1 ] [\n  let total 0\n  foreach p-waiting-num [ n -> set total total + n ]\n  plot total\n]"

PLOT
420
150
620
285
Pass. at Ildefons Cerdà
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "ask stations with [ station-num = 2 ] [\n  let total 0\n  foreach p-waiting-num [ n -> set total total + n ]\n  plot total\n]"

PLOT
625
150
825
285
Pass. at Gornal
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "ask stations with [ station-num = 3 ] [\n  let total 0\n  foreach p-waiting-num [ n -> set total total + n ]\n  plot total\n]"

PLOT
830
150
1030
285
Pass. at Sant Josep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "ask stations with [ station-num = 4 ] [\n  let total 0\n  foreach p-waiting-num [ n -> set total total + n ]\n  plot total\n]"

PLOT
215
290
415
425
Wait time at Mag.-La Camp.
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "ask stations with [ station-num = 1 ] [\n  if p-left-num > 0 [\n    plot (p-left-total-wait-time / p-left-num) / ticks-per-minute\n  ]\n]"

PLOT
420
290
620
425
Wait time at Ildef. Cerdà
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "ask stations with [ station-num = 2 ] [\n  if p-left-num > 0 [\n    plot (p-left-total-wait-time / p-left-num) / ticks-per-minute\n  ]\n]"

PLOT
625
290
825
425
Wait time at Gornal
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "ask stations with [ station-num = 3 ] [\n  if p-left-num > 0 [\n    plot (p-left-total-wait-time / p-left-num) / ticks-per-minute\n  ]\n]"

PLOT
830
290
1030
425
Wait time at Sant Josep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "ask stations with [ station-num = 4 ] [\n  if p-left-num > 0 [\n    plot (p-left-total-wait-time / p-left-num) / ticks-per-minute\n  ]\n]"

PLOT
820
10
1190
145
Mean wait time (total)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10141563 true "" "plot mean-waiting-time / ticks-per-minute"

@#$#@#$#@
## WHAT IS IT?

This model is a more sophisticated two-lane version of the "Traffic Basic" model.  Much like the simpler model, this model demonstrates how traffic jams can form. In the two-lane version, drivers have a new option; they can react by changing lanes, although this often does little to solve their problem.

As in the Traffic Basic model, traffic may slow down and jam without any centralized cause.

## HOW TO USE IT

Click on the SETUP button to set up the cars. Click on GO to start the cars moving. The GO ONCE button drives the cars for just one tick of the clock.

The NUMBER-OF-CARS slider controls the number of cars on the road. If you change the value of this slider while the model is running, cars will be added or removed "on the fly", so you can see the impact on traffic right away.

The SPEED-UP slider controls the rate at which cars accelerate when there are no cars ahead.

The SLOW-DOWN slider controls the rate at which cars decelerate when there is a car close ahead.

The MAX-PATIENCE slider controls how many times a car can slow down before a driver loses their patience and tries to change lanes.

You may wish to slow down the model with the speed slider to watch the behavior of certain cars more closely.

The SELECT CAR button allows you to highlight a particular car. It turns that car red, so that it is easier to keep track of it. SELECT CAR is easier to use while GO is turned off. If the user does not select a car manually, a car is chosen at random to be the "selected car".

You can either [`watch`](http://ccl.northwestern.edu/netlogo/docs/dictionary.html#watch) or [`follow`](http://ccl.northwestern.edu/netlogo/docs/dictionary.html#follow) the selected car using the WATCH SELECTED CAR and FOLLOW SELECTED CAR buttons. The RESET PERSPECTIVE button brings the view back to its normal state.

The SELECTED CAR SPEED monitor displays the speed of the selected car. The MEAN-SPEED monitor displays the average speed of all the cars.

The YCOR OF CARS plot shows a histogram of how many cars are in each lane, as determined by their y-coordinate. The histogram also displays the amount of cars that are in between lanes while they are trying to change lanes.

The CAR SPEEDS plot displays four quantities over time:

- the maximum speed of any car - CYAN
- the minimum speed of any car - BLUE
- the average speed of all cars - GREEN
- the speed of the selected car - RED

The DRIVER PATIENCE plot shows four quantities for the current patience of drivers: the max, the min, the average and the current patience of the driver of the selected car.

## THINGS TO NOTICE

Traffic jams can start from small "seeds." Cars start with random positions. If some cars are clustered together, they will move slowly, causing cars behind them to slow down, and a traffic jam forms.

Even though all of the cars are moving forward, the traffic jams tend to move backwards. This behavior is common in wave phenomena: the behavior of the group is often very different from the behavior of the individuals that make up the group.

Just as each car has a current speed, each driver has a current patience. Each time the driver has to hit the brakes to avoid hitting the car in front of them, they loose a little patience. When a driver's patience expires, the driver tries to change lane. The driver's patience gets reset to the maximum patience.

When the number of cars in the model is high, drivers lose their patience quickly and start weaving in and out of lanes. This phenomenon is called "snaking" and is common in congested highways. And if the number of cars is high enough, almost every car ends up trying to change lanes and the traffic slows to a crawl, making the situation even worse, with cars getting momentarily stuck between lanes because they are unable to change. Does that look like a real life situation to you?

Watch the MEAN-SPEED monitor, which computes the average speed of the cars. What happens to the speed over time? What is the relation between the speed of the cars and the presence (or absence) of traffic jams?

Look at the two plots. Can you detect discernible patterns in the plots?

The grass patches on each side of the road are all a slightly different shade of green. The road patches, to a lesser extent, are different shades of grey. This is not just about making the model look nice: it also helps create an impression of movement when using the FOLLOW SELECTED CAR button.

## THINGS TO TRY

What could you change to minimize the chances of traffic jams forming, besides just the number of cars? What is the relationship between number of cars, number of lanes, and (in this case) the length of each lane?

Explore changes to the sliders SLOW-DOWN and SPEED-UP. How do these affect the flow of traffic? Can you set them so as to create maximal snaking?

Change the code so that all cars always start on the same lane. Does the proportion of cars on each lane eventually balance out? How long does it take?

Try using the `"default"` turtle shape instead of the car shape, either by changing the code or by typing `ask turtles [ set shape "default" ]` in the command center after clicking SETUP. This will allow you to quickly spot the cars trying to change lanes. What happens to them when there is a lot of traffic?

## EXTENDING THE MODEL

The way this model is written makes it easy to add more lanes. Look for the `number-of-lanes` reporter in the code and play around with it.

Try to create a "Traffic Crossroads" (where two sets of cars might meet at a traffic light), or "Traffic Bottleneck" model (where two lanes might merge to form one lane).

Note that the cars never crash into each other: a car will never enter a patch or pass through a patch containing another car. Remove this feature, and have the turtles that collide die upon collision. What will happen to such a model over time?

## NETLOGO FEATURES

Note the use of `mouse-down?` and `mouse-xcor`/`mouse-ycor` to enable selecting a car for special attention.

Each turtle has a shape, unlike in some other models. NetLogo uses `set shape` to alter the shapes of turtles. You can, using the shapes editor in the Tools menu, create your own turtle shapes or modify existing ones. Then you can modify the code to use your own shapes.

## RELATED MODELS

- "Traffic Basic": a simple model of the movement of cars on a highway.

- "Traffic Basic Utility": a version of "Traffic Basic" including a utility function for the cars.

- "Traffic Basic Adaptive": a version of "Traffic Basic" where cars adapt their acceleration to try and maintain a smooth flow of traffic.

- "Traffic Basic Adaptive Individuals": a version of "Traffic Basic Adaptive" where each car adapts individually, instead of all cars adapting in unison.

- "Traffic Intersection": a model of cars traveling through a single intersection.

- "Traffic Grid": a model of traffic moving in a city grid, with stoplights at the intersections.

- "Traffic Grid Goal": a version of "Traffic Grid" where the cars have goals, namely to drive to and from work.

- "Gridlock HubNet": a version of "Traffic Grid" where students control traffic lights in real-time.

- "Gridlock Alternate HubNet": a version of "Gridlock HubNet" where students can enter NetLogo code to plot custom metrics.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. & Payette, N. (1998).  NetLogo Traffic 2 Lanes model.  http://ccl.northwestern.edu/netlogo/models/Traffic2Lanes.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 Cite: Wilensky, U. & Payette, N. -->
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

train passenger car
false
0
Polygon -7500403 true true 15 206 15 150 15 135 30 120 270 120 285 135 285 150 285 206 270 210 30 210
Circle -16777216 true false 240 195 30
Circle -16777216 true false 210 195 30
Circle -16777216 true false 60 195 30
Circle -16777216 true false 30 195 30
Rectangle -16777216 true false 30 140 268 165
Line -7500403 true 60 135 60 165
Line -7500403 true 60 135 60 165
Line -7500403 true 90 135 90 165
Line -7500403 true 120 135 120 165
Line -7500403 true 150 135 150 165
Line -7500403 true 180 135 180 165
Line -7500403 true 210 135 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 5 195 19 207
Rectangle -16777216 true false 281 195 295 207
Rectangle -13345367 true false 15 165 285 173
Rectangle -2674135 true false 15 180 285 188

train passenger engine
false
0
Rectangle -7500403 true true 0 180 300 195
Polygon -7500403 true true 283 161 274 128 255 114 231 105 165 105 15 105 15 150 15 195 15 210 285 210
Circle -16777216 true false 17 195 30
Circle -16777216 true false 50 195 30
Circle -16777216 true false 220 195 30
Circle -16777216 true false 253 195 30
Rectangle -16777216 false false 0 195 300 180
Rectangle -1 true false 11 111 18 118
Rectangle -1 true false 270 129 277 136
Rectangle -16777216 true false 91 195 210 210
Rectangle -16777216 true false 1 180 10 195
Line -16777216 false 290 150 291 182
Rectangle -16777216 true false 165 90 195 90
Rectangle -16777216 true false 290 180 299 195
Polygon -13345367 true false 285 180 267 158 239 135 180 120 15 120 16 113 180 113 240 120 270 135 282 154
Polygon -2674135 true false 284 179 267 160 239 139 180 127 15 127 16 120 180 120 240 127 270 142 282 161
Rectangle -16777216 true false 210 115 254 135
Line -7500403 true 225 105 225 150
Line -7500403 true 240 105 240 150

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
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
1
@#$#@#$#@
