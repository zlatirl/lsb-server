-- ERA Custom: fishing adjustments

-- Giant Donko can't be fished up on era
UPDATE `fishing_fish` SET `disabled` = 1 WHERE `fishid` = 4306;
