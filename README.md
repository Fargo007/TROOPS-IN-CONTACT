# TROOPS-IN-CONTACT

TROOPS IN CONTACT! 

BY [BSD] FARGO OF BLACKSHARKDEN,  A.K.A. BSD.

FREE TO RE-USE PUBLICLY WITH @ATTRIBUTION. :-)

TROOPS IN CONTACT! Seeks to provide an immersive situation in which aircraft of any kind can provide CAS-style support to units on the ground using the well established CAS 5-Line format, without having a person portraying the role of the JTAC on the ground. It has voice file support (simulating radio traffic) and the messages are individualized according to each scenario. The experience you provide is highly configurable via numerous parameters available in the script.

**PILOT INSTRUCTIONS:**

1 - PLACE YOUR AIRCRAFT OR USE THE ONES PROVIDED. **THE AIRCRAFT IN THE EXAMPLE MISSION ARE ONLY FOR TESTING - PUT YOUR OWN AIRCRAFT DOWN.**

2 - USE THE F10-OTHER-TROOPS-IN-CONTACT MENU TO GO ON STATION WITH EITHER LIGHT, OR HEAVY (HARD ARMOR, AAA).

![Screenshot_2021-11-09_13-03-04 png 78dfea9dfd84f5debdad71ba7fc0a83c](https://user-images.githubusercontent.com/32640017/145649298-2674d636-79d9-4506-874b-143fc1a10e06.png)


![Screenshot_2021-12-03_12-41-59 png 6244fa5440e96eced7e56591c51a3ca3](https://user-images.githubusercontent.com/32640017/145649309-68a8519a-51a4-4d2e-a3ad-f51434cdb4c8.png)


3 - ENTER ONE OF THE CHOSEN GRIDS AND REMAIN IN IT. YOU WILL GET TASKING....
![Screenshot_2021-11-09_12-52-42 thumb png 02c1af1926c603c116bd22dfa561460b](https://user-images.githubusercontent.com/32640017/145649380-94d8ffbb-f5e2-481d-95d5-32ede82f5285.png)
![Screenshot_2021-11-09_12-54-54 thumb png c5996f7777444b0f6494c3a53d0ce8d9](https://user-images.githubusercontent.com/32640017/145649388-0463af62-aff7-482a-9a52-7cd0834e6f84.png)

THE CONCERNED ZONES CAN BE MODIFIED TO SUIT (SHAPE, SIZE):

![Screenshot_2021-11-09_12-37-12 thumb png 81f6a40b138aba1905cf9934fc7c87c8](https://user-images.githubusercontent.com/32640017/145649470-e7b831c3-8978-4f35-ad2e-0049c975aa38.png)

5 - PROSECUTE, AND WHEN READY, REACTIVATE TIC IN THE MENU.

---------------------------------------------------

**MISSION DESIGNER INSTRUCTIONS:**

***See the script file. There are a huge number of configurable parameters.***

Top left of the map are the groups. You can control the makeup of the enemy and friendly groups entirely.

![Screenshot_2021-11-09_12-35-39 thumb png f38f8cb669194430b0abae7e1507cf9c](https://user-images.githubusercontent.com/32640017/145649572-b3118cb2-5fe0-458f-9f49-1551401e0525.png)

These are **EXAMPLES**.  It's up to **_YOU_** to craft friendly and enemy groups and support elements that fit your desired scenario.

Groups and statics that are to be included must be named according to a convention:

FRIENDLIES-1, FRIENDLIES-2, etc.
FRIENDLYSTATIC-1, FRIENDLYSTATIC-2, etc.
HEAVY-1, HEAVY-2, etc.
LIGHT-1, LIGHT-2, etc.
SUPPORT-1, SUPPORT-2, etc.
 Each category must have minimum 1, and that one must be named with the appropriate string, and "-1". There are no upper limits on any category, only a minimum.


**PORTABILITY:**

1 - THE TIC AREA (YELLOW)  ZONES CAN BE ANY SIZE, AND MAY BE MOVED ANYWHERE ON THE MAP. YOU MUST MOVE THREE THINGS:
THE SQUARE, 4 GRID ZONE. 
THE INDIVIDUAL ROUND ZONES WITHIN IT
THE MAP DRAW ARTIFACTS IF DESIRED.

**IF YOU WISH TO PORT IT TO A DIFFERENT MAP, RECREATE ALL THE ZONES, GROUPS, ETC. AND LOAD THE SCRIPT AND SOUNDS AS IS DONE HERE.**

ChangeLog:

V7: 

- Friendlies fire to mark enemy as a target by default. Time of their fire is configurable, and they issue a "CLEARED HOT" afterward. 
- The enemy is immortal until "CLEARED HOT" is issued so don't attack prematurely. It would be rare that you had the chance to anyhow.

V6+: TROOPS IN CONTACT! is now a script and a project, not a specific mission.

New features added:
- Light and Heavy both get a support element now. 
- Flanking - Enemy main units will try to flank the friendlies 90 degrees. Configurable by a percentage of likelihood.
- Retreat - Enemy main units will un-ass the area entirely. Configurable as to how, distance, percentage of likelihood.
- Friendly forces can return fire (mark target with tracers) - By default there is no target mark, as the friendlies do not always have LoS. They will fire "at" the enemy, and hopefully not obliterate them. YMMV with this one. Incompatible with Flanking. This works far better on Syria than Caucasus for some reason.

