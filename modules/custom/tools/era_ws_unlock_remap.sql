-- ERA Custom: run once by hand after importing era characters. Not listed in init.txt.
--
-- Era stored the 14 Martial Mastery weaponskill unlocks in bits 35-48 of chars.weaponskills.
-- LSB uses bits 35-48 for the Empyrean weaponskills and 50-63 for Martial Mastery,
-- so this moves each era bit to its LSB bit and clears 35-48.
-- Safe to re-run: once 35-48 are clear it changes nothing.
--
-- era bit -> LSB bit
--   35 Shijin Spiral -> 60    42 Stardiver    -> 61
--   36 Exenterator   -> 53    43 Blade: Shun  -> 51
--   37 Requiescat    -> 56    44 Tachi: Shoha -> 62
--   38 Resolution    -> 57    45 Realmrazer   -> 55
--   39 Ruinator      -> 58    46 Shattersoul  -> 59
--   40 Upheaval      -> 63    47 Apex Arrow   -> 50
--   41 Entropy       -> 52    48 Last Stand   -> 54

UPDATE `chars`
SET `weaponskills` = RPAD(IFNULL(`weaponskills`, ''), 8, CHAR(0))
WHERE LENGTH(IFNULL(`weaponskills`, '')) < 8;

-- Bits 32-63 are bytes 5-8, little-endian; in that word, bit n of the blob is bit n - 32.
UPDATE `chars`
JOIN
(
    SELECT
        `charid`,
        (`hi` & 0xFFFE0007) |
        (((`hi` >> 3)  & 1) << 28) |
        (((`hi` >> 4)  & 1) << 21) |
        (((`hi` >> 5)  & 1) << 24) |
        (((`hi` >> 6)  & 1) << 25) |
        (((`hi` >> 7)  & 1) << 26) |
        (((`hi` >> 8)  & 1) << 31) |
        (((`hi` >> 9)  & 1) << 20) |
        (((`hi` >> 10) & 1) << 29) |
        (((`hi` >> 11) & 1) << 19) |
        (((`hi` >> 12) & 1) << 30) |
        (((`hi` >> 13) & 1) << 23) |
        (((`hi` >> 14) & 1) << 27) |
        (((`hi` >> 15) & 1) << 18) |
        (((`hi` >> 16) & 1) << 22) AS `newHi`
    FROM
    (
        SELECT
            `charid`,
            ORD(SUBSTR(`weaponskills`, 5, 1)) |
            (ORD(SUBSTR(`weaponskills`, 6, 1)) << 8) |
            (ORD(SUBSTR(`weaponskills`, 7, 1)) << 16) |
            (ORD(SUBSTR(`weaponskills`, 8, 1)) << 24) AS `hi`
        FROM `chars`
    ) AS `words`
    WHERE (`hi` & 0x0001FFF8) <> 0
) AS `remap` ON `remap`.`charid` = `chars`.`charid`
SET `chars`.`weaponskills` = CONCAT(
    SUBSTR(`chars`.`weaponskills`, 1, 4),
    CHAR(`remap`.`newHi` & 0xFF, (`remap`.`newHi` >> 8) & 0xFF, (`remap`.`newHi` >> 16) & 0xFF, (`remap`.`newHi` >> 24) & 0xFF USING binary),
    SUBSTR(`chars`.`weaponskills`, 9)
);
