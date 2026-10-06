-- ERA Custom: fishing in [S] zones.
-- Each zone mirrors its present-day counterpart; Grauberg [S] and Vunkerl Inlet [S] use era's fish lists.

-- Bastok Markets [S]
REPLACE INTO `fishing_area` VALUES (87,1,'North Side',2,20,0,0xE32E85C3000000008262F4C11CEB1CC1000000007446D4C1098AF1C000000000D22FEDC2DDA404C300000000D676EFC2219039C3000000001EB6BCC221D058C3000000007328C1C254A363C300000000FFB2E9C2DC5778C3000000001846EFC2DC8F86C3000000008FD3DBC2,0.000,-6.000,0.000);
REPLACE INTO `fishing_area` VALUES (87,2,'South Side',0,0,0,'',0.000,-6.000,0.000);
REPLACE INTO `fishing_catch` VALUES (87,1,5);
REPLACE INTO `fishing_catch` VALUES (87,2,6);

-- Batallia Downs [S]
REPLACE INTO `fishing_area` VALUES (84,1,'North Seaside',1,20,200,'',291.891,7.000,198.639);
REPLACE INTO `fishing_area` VALUES (84,2,'South Seaside',1,20,150,'',102.172,8.000,-489.808);
REPLACE INTO `fishing_catch` VALUES (84,1,27);
REPLACE INTO `fishing_catch` VALUES (84,2,27);

-- Castle Oztroja [S]
REPLACE INTO `fishing_area` VALUES (99,2,'Whole Zone',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_catch` VALUES (99,2,72);

-- East Ronfaure [S]
REPLACE INTO `fishing_area` VALUES (81,1,'Whole Zone',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_catch` VALUES (81,1,16);

-- Jugner Forest [S]
REPLACE INTO `fishing_area` VALUES (82,1,'Crystalwater Spring',1,20,20,'',300.000,1.000,-179.833);
REPLACE INTO `fishing_area` VALUES (82,2,'Lake Mechieume - Mouth',1,20,31,'',19.458,3.000,334.528);
REPLACE INTO `fishing_area` VALUES (82,3,'Lake Mechieume - Main',2,20,0,0xC1CA2BC30000000010981544DF4F0B430000000064D3114477DE0D4300000000EC41A143235B30C3000000006871A343,0.000,5.000,0.000);
REPLACE INTO `fishing_area` VALUES (82,4,'Maidens Spring',1,20,22,'',-496.682,9.000,298.057);
REPLACE INTO `fishing_area` VALUES (82,5,'River',0,0,0,NULL,0.000,0.000,0.000);
UPDATE `fishing_fish` SET `disabled` = 0, `skill_level` = 110 WHERE `fishid` = 5476;
DELETE FROM `fishing_group` WHERE `groupid` BETWEEN 143 AND 147;
INSERT INTO `fishing_group` SELECT `groupid` + 108, `fishid`, `rarity`, `pool_size`, `restock_rate` FROM `fishing_group` WHERE `groupid` BETWEEN 35 AND 39;
INSERT INTO `fishing_group` VALUES (143,5476,500,50,6); -- Abaia
INSERT INTO `fishing_group` VALUES (144,5476,500,50,6); -- Abaia
INSERT INTO `fishing_group` VALUES (145,5476,500,50,6); -- Abaia
INSERT INTO `fishing_group` VALUES (146,5476,500,50,6); -- Abaia
INSERT INTO `fishing_group` VALUES (147,5476,500,50,6); -- Abaia
DELETE FROM `fishing_catch` WHERE `zoneid` = 82;
INSERT INTO `fishing_catch` VALUES (82,1,143);
INSERT INTO `fishing_catch` VALUES (82,2,144);
INSERT INTO `fishing_catch` VALUES (82,3,145);
INSERT INTO `fishing_catch` VALUES (82,4,146);
INSERT INTO `fishing_catch` VALUES (82,5,147);

-- North Gustaberg [S]
REPLACE INTO `fishing_area` VALUES (88,1,'Basin of Waterfall',1,20,27,'',-230.433,96.000,462.000);
REPLACE INTO `fishing_area` VALUES (88,2,'River',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_catch` VALUES (88,1,43);
REPLACE INTO `fishing_catch` VALUES (88,2,44);

-- Pashhow Marshlands [S]
REPLACE INTO `fishing_area` VALUES (90,1,'Whole Zone',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_catch` VALUES (90,1,50);

-- Rolanberry Fields [S]
REPLACE INTO `fishing_area` VALUES (91,1,'Small Fountain 1',1,20,20,'',-538.750,-14.000,-179.103);
REPLACE INTO `fishing_area` VALUES (91,2,'Fountain of Promises',1,20,70,'',-670.355,-21.000,-175.250);
REPLACE INTO `fishing_area` VALUES (91,3,'Fountain of Partings',1,20,60,'',-721.715,-26.000,-423.003);
REPLACE INTO `fishing_area` VALUES (91,4,'Small Fountain 2',1,20,20,'',257.238,-30.000,-258.576);
REPLACE INTO `fishing_catch` VALUES (91,1,51);
REPLACE INTO `fishing_catch` VALUES (91,2,52);
REPLACE INTO `fishing_catch` VALUES (91,3,53);
REPLACE INTO `fishing_catch` VALUES (91,4,54);

-- West Sarutabaruta [S]
REPLACE INTO `fishing_area` VALUES (95,1,'Pond',1,20,25,'',110.000,-1.000,-200.000);
REPLACE INTO `fishing_area` VALUES (95,2,'Seaside',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_catch` VALUES (95,1,59);
REPLACE INTO `fishing_catch` VALUES (95,2,60);

-- Windurst Waters [S]
REPLACE INTO `fishing_area` VALUES (94,1,'Whole Zone',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_catch` VALUES (94,1,11);

-- Grauberg [S]
REPLACE INTO `fishing_area` VALUES (89,1,'Whole Zone',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_group` VALUES (141,4429,800,290,7); -- Black Eel
REPLACE INTO `fishing_group` VALUES (141,4477,550,145,4); -- Gavial Fish
REPLACE INTO `fishing_group` VALUES (141,4515,1000,500,15); -- Copper Frog
REPLACE INTO `fishing_group` VALUES (141,5469,750,500,15); -- Brass Loach
REPLACE INTO `fishing_group` VALUES (141,5470,1000,500,15); -- Pirarucu
REPLACE INTO `fishing_group` VALUES (141,5474,500,500,15); -- Ca Cuong
REPLACE INTO `fishing_group` VALUES (141,14117,500,300,9); -- Rusty Leggings
REPLACE INTO `fishing_group` VALUES (141,14242,500,300,9); -- Rusty Subligar
REPLACE INTO `fishing_catch` VALUES (89,1,141);

-- Vunkerl Inlet [S]
REPLACE INTO `fishing_area` VALUES (83,1,'Whole Zone',0,0,0,NULL,0.000,0.000,0.000);
REPLACE INTO `fishing_group` VALUES (142,90,900,300,9); -- Rusty Bucket
REPLACE INTO `fishing_group` VALUES (142,688,500,200,6); -- Arrowwood Log
REPLACE INTO `fishing_group` VALUES (142,4360,1000,500,15); -- Bastore Sardine
REPLACE INTO `fishing_group` VALUES (142,4401,1000,1000,36); -- Moat Carp
REPLACE INTO `fishing_group` VALUES (142,4426,1000,500,15); -- Tricolored Carp
REPLACE INTO `fishing_group` VALUES (142,4428,1000,500,15); -- Dark Bass
REPLACE INTO `fishing_group` VALUES (142,4443,1000,500,15); -- Cobalt Jellyfish
REPLACE INTO `fishing_group` VALUES (142,4461,250,230,6); -- Bastore Bream
REPLACE INTO `fishing_group` VALUES (142,4469,900,190,6); -- Giant Catfish
REPLACE INTO `fishing_group` VALUES (142,4481,1000,500,15); -- Ogre Eel
REPLACE INTO `fishing_group` VALUES (142,4514,1000,500,15); -- Quus
REPLACE INTO `fishing_group` VALUES (142,5466,550,500,15); -- Trumpet Shell
REPLACE INTO `fishing_group` VALUES (142,5468,500,100,3); -- Matsya
REPLACE INTO `fishing_group` VALUES (142,5472,1000,500,15); -- Garpike
REPLACE INTO `fishing_group` VALUES (142,5473,950,500,15); -- Bastore Sweeper
REPLACE INTO `fishing_group` VALUES (142,5475,1000,500,15); -- Gigant Octopus
REPLACE INTO `fishing_group` VALUES (142,14117,500,300,9); -- Rusty Leggings
REPLACE INTO `fishing_group` VALUES (142,14242,500,300,9); -- Rusty Subligar
REPLACE INTO `fishing_catch` VALUES (83,1,142);
