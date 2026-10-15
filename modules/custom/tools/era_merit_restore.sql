-- ERA Custom: run by hand. Copies merits from the era database (dspdb) back onto every character
-- that exists in xidb, overwriting what xidb has.
--
-- LSB clamps merits to the current caps when a character loads and saves the clamped values on logout,
-- so characters that logged in while modules/era/data/merits.yaml had stricter caps lost upgrades.
-- Run it only after the map server has been restarted with the current merit caps, and with the
-- affected characters logged out, or the next logout clamps them again.

REPLACE INTO `char_merit` (`charid`, `meritid`, `upgrades`)
SELECT d.`charid`, d.`meritid`, d.`upgrades`
FROM `dspdb`.`char_merit` AS d
JOIN `chars` AS c ON c.`charid` = d.`charid`;
