return {

    rewardclaim = 24, --! 24 jam claim

    barangreward = { --! letak barang kat sini
        ['aed'] = { amount = 1, item = 'aed' },
        -- ['bawang'] = { amount = 1, item = 'bawang' }, 
    },

    hargavip = 50, --! coin

    commandbuka = 'vip', --! command buka menu
    
    gunakeybind = true, --! guna keybind? command pun boleh

    keybindsettings = { --! keybind settings  sini
        tajuk = 'VIP MENU',
        desc = 'Press F6 to open vip menu',
        key = 'F6', -- https://docs.fivem.net/docs/game-references/controls/
    },

    notify = { 
        dahbeli = 'You Can access this feature! VipMenu', --! notify bila dah beli vip
        takdeduit = 'You dont have Coin Please Buy', --! notify tak cukup duit beli vip
    },
}