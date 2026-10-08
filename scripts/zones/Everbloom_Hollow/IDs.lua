-----------------------------------
-- Area: Everbloom_Hollow
-----------------------------------
zones = zones or {}

zones[xi.zone.EVERBLOOM_HOLLOW] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6387, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6395, -- Obtained: <item>.
        GIL_OBTAINED                  = 6396, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6398, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7006, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7007, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7008, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7028, -- Your party is unable to participate because certain members' levels are restricted.
        TEMP_ITEM                     = 7066, -- Obtained temporary item: <item>.
        TIME_TO_COMPLETE              = 7170, -- You have <number> [minute/minutes] (Earth time) to complete your objectives.
        TIME_REMAINING_MINUTES        = 7171, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS        = 7172, -- Time remaining: <number> [second/seconds] (Earth time).
        PARTY_FALLEN                  = 7173, -- All party members have fallen in battle. Exiting in <number> [minute/minutes].
        MISSION_FAILED                = 7174, -- The operation has failed.
    },
    mob =
    {
        KING_ARTHRO  = GetFirstID('King_Arthro'),
        LAMBTON_WORM = GetFirstID('Lambton_Worm'),
    },
    npc =
    {
    },
}

return zones[xi.zone.EVERBLOOM_HOLLOW]
