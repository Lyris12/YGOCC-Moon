banned_list_table=banned_list_table or {}
local string=require'string'
local ls=[[
#[2023.9 YGOCC+2023.9 TCG]
!2023.9 YGOCC
#Forbidden YGOCC
20181405 0 --Terradication Geryonarsenal
33700082 0 --Anifriends Seiryu of the East
33700083 0 --Anifriends Suzaku of the South
33700085 0 --Anifriends Byakko of the West
33700093 0 --Anifriends Aardwolf
33700072 0 --Anifriends Beaver and Prairie
33700186 0 --Anifriends Kyushu Owl
33700745 0 --Anifriends Forest Owlet
33700747 0 --Anifriends Black-Backed Jackal
33700750 0 --Anifriends Reindeer
33700079 0 --Anifriends Small-clawed Otter
37564909 0 --Sayuri - Scarlet Moon
63553466 0 --Universal Marshall
79854546 0 --Numbing Winter Jewel
79854547 0 --Verdant Illusion
102400004 0 --Accel Burst Dragon
56642464 0 --Holy Noble Knight Crusader, Artorgius
56642463 0 --Noble Knight Mordred
#Limited YGOCC
77585595 1 --Forgalgia Emperor Jinzo
15747847 1 --Mythos Valor
32904936 1 --Arisa, the Aeonbreaker's Defender
33700058 1 --Miracle of the Sandstar
33700065 1 --Anifriends PPP Gentoo
33700744 1 --Anifriends "Ikkaku"
33700746 1 --Anifriends Sky Impulse
63553468 1 --Proxima Marshall
#Semi-limited YGOCC
--							New 2/11/2022
97569832 0 --Flight of Star Regalia
#33700183 1 --Anifriends Sisha Lefty
#33700184 1 --Anifriends Sisha Righty
--							New 3/24/2022
63553469 1 --Atom Marshall
31157205 1 --Mezka Melodia
23251031 1 --Pharaohnic Papyrus of Patience
28915253 1 --Shadowflame Calvary
63287035 1 --Horrible Reborn
#195208417 1 --False Reality Knight Thrax
195208422 2 --False Reality Spirit Monk Dalos
--							New 7/6/2022
53313934 1 --Disstonant Luster Dragon
--							New 3/6/2023
#67723438 1 --Emergency Teleport
#63553459 3 --Nethergear Unit
#33700311 3 --NEXTGal G
#96212378 3 --Spiral Drill Formation
#96212398 3 --Spiral Drill Formation
--							New 5/12/2023
32904930 0 --Jaden the Aeonbreaker's Alchemist
#67723438 3 --Emergency Teleport
#26369260 3 --Psychostice Patrol
--							New 6/19/2023
53313925 0 --Disstonant Space Dragon
#37564903 3 --Sayuri - ALICE
#17029608 3 --Psychether Priestess, Joan
#195208400 3 --Spectre Magician & Dark Light
--							New 9/25/2023
62242678 0 --Hot Red Dragon Archfiend King Calamity
54974237 0 --Eradicator Epidemic Virus
32904931 2 --Aeonbreaker Fusion
195208417 2 --False Reality Knight Thrax
#33700751 3 --Anifriends Tanuki
#202114501 3 --Sireknight
#33700183 3 --Anifriends Sisha Lefty
#33700184 3 --Anifriends Sisha Righty


#RULE CARDS
5000 1 --Manual Mode

#FORBIDDEN TCG					===Forbidden===
76794549 0 --Astrograph Sorcerer
9929398 0 --Blackwing - Gofu the Vague Shadow
53804307 0 --Blaster, Dragon Ruler of Infernos
15341821 0 --Dandylion
8903700 0 --Djinn Releaser of Rituals
51858306 0 --Eclipse Wyvern
55623480 0 --Fairy Tail - Snow
78706415 0 --Fiber Jar
93369354 0 --Fishborg Blaster
75732622 0 --Grinder Golem
57421866 0 --Level Eater
34206604 0 --Magical Scientist
31178212 0 --Majespecter Unicorn - Kirin
21377582 0 --Master Peace, the True Dracoslaying King
23434538 0 --Maxx "C"
96782886 0 --Mind Master
57835716 0 --Orcust Harp Horror
7563579 0 --Performage Plushfire
17330916 0 --Performapal Monkeyboard
23558733 0 --Phoenixian Cluster Amaryllis
90411554 0 --Redox, Dragon Ruler of Boulders
88071625 0 --The Tyrant Neptune
26400609 0 --Tidal, Dragon Ruler of Waterfalls
44910027 0 --Victory Dragon
3078576 0 --Yata-Garasu
17412721 0 --Elder Entity Norden
43387895 0 --Supreme King Dragon Starving Venom
15291624 0 --Thunder Dragon Colossus
59537380 0 --Guardragon Agarpain
24094258 0 --Heavymetalfoes Electrumite
39064822 0 --Knightmare Goblin
3679218 0 --Knightmare Mermaid
61665245 0 --Summon Sorceress
22593417 0 --Topologic Gumblar Dragon
65536818 0 --Denglong, First of the Yang Zing
94677445 0 --Ib the World Chalice Justiciar
63101919 0 --Tempest Magician
34086406 0 --Lavalval Chain
4423206 0 --M-X-Saber Invoker
54719828 0 --Number 16: Shock Master
10389142 0 --Number 42: Galaxy Tomahawk
63504681 0 --Number 86: Heroic Champion - Rhongomyniad
58820923 0 --Number 95: Galaxy-Eyes Dark Matter Dragon
34945480 0 --Outer Entity Azathot
81122844 0 --Wind-Up Carrier Zenmaity
85115440 0 --Zoodiac Broadbull
7394770 0 --Brilliant Fusion
69243953 0 --Butterfly Dagger - Elma
57953380 0 --Card of Safe Return
4031928 0 --Change of Heart
67616300 0 --Chicken Game
60682203 0 --Cold Wave
17375316 0 --Confiscation
44763025 0 --Delinquent Duo
23557835 0 --Dimension Fusion
42703248 0 --Giant Trunade
79571449 0 --Graceful Charity
18144506 0 --Harpie's Feather Duster
19613556 0 --Heavy Storm
35059553 0 --Kaiser Colosseum
85602018 0 --Last Will
34906152 0 --Mass Driver
46411259 0 --Metamorphosis
41482598 0 --Mirage of Nightmare
74191942 0 --Painful Choice
55144522 0 --Pot of Greed
70828912 0 --Premature Burial
45986603 0 --Snatch Steal
54447022 0 --Soul Charge
11110587 0 --That Grass Looks Greener
42829885 0 --The Forceful Sentry
28566710 0 --Last Turn
27174286 0 --Return from the Different Dimension
93016201 0 --Royal Oppression
57585212 0 --Self-Destruct Button
3280747 0 --Sixth Sense
35316708 0 --Time Seal
64697231 0 --Trap Dustshoot
80604091 0 --Ultimate Offering
5851097 0 --Vanity's Emptiness
5560911 0 --Destrudo the Lost Dragon's Frisson
67441435 0 --Glow-Up Bulb
83190280 0 --Lunalight Tiger
91258852 0 --SPYRAL Master Plan
#LIMITED TCG				====Limited===
7902349 1 --Left Arm of the Forbidden One
44519536 1 --Left Leg of the Forbidden One
70903634 1 --Right Arm of the Forbidden One
8124921 1 --Right Leg of the Forbidden One
28985331 1 --Armageddon Knight
61901281 1 --Black Dragon Collapserpent
69015963 1 --Cyber-Stein
14536035 1 --Dark Grepher
82385847 1 --Dinowrestler Pankratops
33396948 1 --Exodia the Forbidden One
99177923 1 --Infernity Archfiend
33508719 1 --Morphing Jar
12958919 1 --Phantom Skyblaster
92559258 1 --Servant of Endymion
81275020 1 --Speedroid Terrortop
4474060 1 --SPYRAL GEAR - Drone
89399912 1 --Tempest, Dragon Ruler of Storms
30539496 1 --True King Lithosagym, the Disaster
99234526 1 --White Dragon Wyverburster
78872731 1 --Zoodiac Ratpier
39512984 1 --Gem-Knight Master Diamond
74586817 1 --PSY-Framelord Omega
27552504 1 --Beatrice, Lady of the Eternal
581014 1 --Daigusto Emeral
72892473 1 --Card Destruction
59750328 1 --Card of Demise
91623717 1 --Chain Strike
15854426 1 --Divine Wind of Mist Valley
13035077 1 --Dragonic Diagram
95308449 1 --Final Countdown
81439173 1 --Foolish Burial
27970830 1 --Gateway of the Six
75500286 1 --Gold Sarcophagus
66957584 1 --Infernity Launcher
93946239 1 --Into the Void
71650854 1 --Magical Mid-Breaker Field
83764718 1 --Monster Reborn
33782437 1 --One Day of Peace
2295440 1 --One for One
58577036 1 --Reasoning
32807846 1 --Reinforcement of the Army
24940422 1 --Sekka's Light
73468603 1 --Set Rotation
52340444 1 --Sky Striker Mecha - Hornet Drones
71344451 1 --Slash Draw
54631665 1 --SPYRAL Resort
73628505 1 --Terraforming
35371948 1 --Trickstar Light Stage
70368879 1 --Upstart Goblin
61740673 1 --Imperial Order
32723153 1 --Magical Explosion
17078030 1 --Wall of Revealing Light
43694650 1 --Danger!? Jackalope?
99745551 1 --Danger!? Tsuchinoko?
90953320 1 --T.G. Hyper Librarian
52687916 1 --Trishula, Dragon of the Ice Barrier
48905153 1 --Zoodiac Drident
1845204 1 --Instant Fusion
37520316 1 --Mind Control
46060017 1 --Zoodiac Barrage
#SEMI LIMITED TCG			===Semi Limited===
9411399 2 --Destiny HERO - Malicious
--							New 9/14/2020
9742784 0 --Jet Synchron
94689206 0 --Block Dragon
18144506 1 --Harpie's Feather Duster
24224830 1 --Called by the Grave
--							New 12/15/2020
63789924 0 --Smoke Grenade of the Thief
85243784 0 --Linkross
--							New 3/15/2021
83152482 0 --Union Carrier
52653092 0 --Number S0: Utopic ZEXAL
88581108 0 --True King of All Calamities
--							New 7/1/2021
86148577 0 --Guardragon Elpy
48905153 0 --Zoodiac Drident
38572779 1 --Miscellaneousaurus
73539069 1 --Striker Dragon
63166095 1 --Sky Striker Mobilize - Engage!
--							New 10/1/2021
46060017 0 --Zoodiac Barrage
40177746 1 --Eva
25725326 1 --Prank-Kids Meow-Meow-Mu
--							New 2/7/2022
6728559 0  --Archnemeses Protos
40177746 0 --Eva
72330894 0 --Simorgh, Bird of Sovereignty
61740673 0 --Imperial Order
76794549 1 --Astrograph Sorcerer
5560911 1  --Destrudo the Lost Dragon's Frisson
83190280 1 --Lunalight Tiger
43040603 1 --Monster Gate
35261759 1 --Pot of Desires
--							New 3/24/2022
20292186 0 --Artifact Scythe
--							New 5/17/2022
25725326 0 --Prank-Kids Meow-Meow-Mu
70369116 0 --Predaplant Verte Anaconda
44097050 0 --Mecha Phantom Beast Auroradon
35316708 1 --Time Seal
4031928 1 --Change of Heart
3078576 1 --Yata-Garasu
9742784 1 --Jet Synchron
26118970 1 --Red Rose Dragon
17330916 1 --Performapal Monkeyboard
35261759 2 --Pot of Desires
--							New 7/6/2022
76218313 0 --Dragon Buster Destruction Sword
--							New 10/3/2022
55623480 0 --Fairy Tail - Snow
1357146 0 --Ronintoadin
50588353 0 --Crystron Halqifibrax
3040496 0 --Chaos Ruler, the Chaotic Magical Dragon
23002292 0 --Red Reboot
34124316 1 --Cyber Jar
72291078 1 --Mecha Phantom Beast O-Lion
20663556 1 --Substitoad
46448938 1 --Spellbook of Judgment
43262273 1 --Appointer of the Red Lotus
--							New 12/1/2022
98095162 0 --Curious, the Lightsworn Dominion
76375976 0 --Mystic Mine
#17266660 1 --Herald of Orange Light
--							New 2/1/2022
20292186 0 --Artifact Scythe
27381364 0 --Spright Elf
73356503 0 --Barrier Statue of the Stormwinds
92731385 0 --Tearlaments Kitkallos
572850 1 --Tearlaments Scheiren
25926710 1 --Kelbek the Ancient Vanguard
37961969 1 --Tearlaments Havnis
62320425 1 --Agido the Ancient Sentinel
63542003 1 --Keldo the Sacred Protector
74078255 1 --Tearlaments Merrli
99937011 1 --Mudora the Sword Oracle
25862681 1 --Ancient Fairy Dragon
3078576 3 --Yata-Garasu
5560911 3 --Destrudo the Lost Dragon's Frisson
9742784 3 --Jet Synchron
30461781 3 --Legacy of Yata-Garasu
30539496 3 --True King Lithosagym, the Disaster
54631665 3 --SPYRAL Resort
54631685 3 --SPYRAL Resort
72291078 3 --Mecha Phantom Beast O-Lion
92559258 3 --Servant of Endymion
--							New 6/5/2023
69015963 0 --Cyber-Stein
33918636 0 --Superheavy Samurai Scarecrow
95474755 0 --Number 89: Diablosis the Mind Hacker
43262273 0 --Appointer of the Red Lotus
1041278 0 --Branded Expulsion
53804307 1 --Blaster, Dragon Ruler of Infernos
36521307 1 --Mathmech Circular
38814750 1 --PSY-Framegear Gamma
65536818 1 --Denglong, First of the Yang Zing
55584558 1 --Purrely Delicious Memory
#48626373 1 --Kashtira Arise-Heart
3734202 1 --Naturia Sacred Tree
#17266660 2 --Herald of Orange Light
68304193 2 --Kashtira Unicorn
14532163 2 --Lightning Storm
92107604 2 --Runick Fountain
63166095 2 --Sky Striker Mobilize - Engage!
15443125 2 --Spright Starter
--							New 2/1/2022
48626373 0 --Kashtira Arise-Heart
33854624 1 --Bystial Magnamhut
99266988 1 --Chaos Space
#26889158 3 --Salamangreat Gazelle
#17266660 3 --Herald of Orange Light
]]
for id in ls:sub(ls:find("!"),ls:find("!",ls:find("!")+1) and ls:find("!",ls:find("!")+1)-1 or -1):gmatch("([0-9]+) 0") do
	banned_list_table[tonumber(id)]=true
end
