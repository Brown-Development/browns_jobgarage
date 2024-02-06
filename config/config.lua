config = {}

config.Core = { -- Core Stuff.

    framework = 'qb-core', -- 'qb-core' or 'esx'

    notify = function(title, message, types, duration)

        ---@param title the title of the notification (optional)
        ---@param message the notification message 
        ---@param types the type of notification ('success' or 'error')
        ---@param duration how long the noficiation will display (in milliseconds)

        -- add your own custom notification events/exports here (client sided)
        -- uses animated ox lib notify by default:

        lib.notify({
            title = title,
            description = message,
            type = types,
            duration = duration,
            position = 'center-right',
            style = {
                backgroundColor = '#000000',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#FFFFFF'
                }
            },
            icon = {'fas', 'warehouse'},
            iconColor = '#FFFFFF',
            iconAnimation = 'bounce'
        })
        
    end, 

    givekeys = function(vehicle, plate) -- function to give players the key to the vehicle when it spawns.

        ---@param vehicle the vehicle
        ---@param plate the vehicles plate

        -- add events/functions to give vehicle keys (client sided)
        -- this depends on what vehicle key system your server uses
        -- uses qb-core vehicle keys by default (with commented option for wasabi_carlock):

        TriggerEvent('vehiclekeys:client:SetOwner', plate) -- default qb-core

        -- exports.wasabi_carlock:GiveKey(plate) -- wasabi car lock
    end
}

config.debug = false -- set this to true if the vehicle menu never opens (it will print which vehicle is loading, if it infinitely prints a specific vehicle then that vehicle is what is causing things to move slow)

config.garages = {
    ['police'] = { -- job name

        location = { -- vehicle select & costumize menu location settings
            coords = vec3(422.5713, -1010.8141, 29.0582), -- location of the menu to pull out a vehicle
            displayCoords = vec3(443.4637, -1021.4501, 28.5389), -- where the vehicle will be displayed once you open the menu to select your vehicle
            displayHeading = 93.7435, -- the heading of the display vehicle
            spawnCoords = vec4(403.4095, -1015.4006, 29.2996, 357.9582), -- where the vehicle will spawn once your finished selcting your vehicle
        },

        markerColors = {154, 154, 154}, -- rgb color of the markers (you can use or similar for rgb color codes: https://htmlcolors.com/google-color-picker)

        customize = { -- vehicle customization options
            cosmetic = true, -- allow cosmetic customization of vehicles? (livery, extras, colors, etc.)
            performance = true -- allow performance customization of vehicles? (engine, turbo, suspension, etc.)
        },

        garage = { -- garage settings (this is where players can store non-owned job vehicles, saves in database so they dont gotta pull out another one and customize it each time)
            enable = true,
            store = vec3(452.5758, -1023.7236, 28.5089), -- where you go to store the vehicle
            pull = vec3(444.6919, -1027.8876, 27.6821), -- where you go to take out the vehicle
            spawn = vec4(420.1545, -1027.8093, 29.1146, 91.5844) -- where the vehicle will spawn
        },

        takehome = { -- take home vehicle settings
            enable = true, -- enable the ability to issue take home vehicles
            grades = { -- list of job grades that can access this
                ['6'] = true, -- [gradenumber[string]] = true
                ['5'] = true,
                ['4'] = true,
            },
            locations = {
                menu = vec3(439.5598, -1012.7230, 28.5975), -- take home vehicle menu (where the authorized players go to issue vehicles)
                ped = {
                    coords = vec4(427.3116, -1012.1042, 27.9409, 188.1374), -- where the ped who players get their issued vehicles from go to see their issued vehicles
                    model = 'u_m_y_smugmech_01' -- the ped model (see ref: https://docs.fivem.net/docs/game-references/ped-models/)
                },
            }
        },

        vehicles = { -- list of vehicles
            {
                model = 'police', -- model name (spawn code)
                label = 'Police Cruiser 1', -- a label for the vehicle
                grade = 1 -- minimum job grade level able to access this vehicle
            },
            {
                model = 'police2',
                label = 'Police Cruiser 2',
                grade = 2
            },
            {
                model = 'police3',
                label = 'Police Cruiser 3',
                grade = 3
            },
            {
                model = 'police4',
                label = 'Unmarked Cruiser',
                grade = 4
            },
            {
                model = 'policeb',
                label = 'Police Bike',
                grade = 3
            },
            {
                model = 'policet',
                label = 'Police Transporter',
                grade = 4
            },
        }
    },

    -- Add as many as you want:

    -- ['ambulance'] = { 

    --     location = { 
    --         coords = vec3(0, 0, 0), 
    --         displayCoords = vec3(0, 0, 0), 
    --         displayHeading = 0, 
    --         spawnCoords = vec4(0, 0, 0, 0), 
    --     },

    --     markerColors = {0, 0, 0},

    --     customize = { 
    --         cosmetic = true, 
    --         performance = true 
    --     },

    --     garage = { 
    --         enable = true,
    --         store = vec3(0, 0, 0), 
    --         pull = vec3(0, 0, 0), 
    --         spawn = vec4(0, 0, 0, 0) 
    --     },

    --     takehome = { 
    --         enable = true, 
    --         grades = { 
    --             ['6'] = true, 
    --             ['5'] = true,
    --             ['4'] = true,
    --         },
    --         locations = {
    --             menu = vec3(0, 0, 0),
    --             ped = {
    --                 coords = vec4(0, 0, 0, 0), 
    --                 model = 'u_m_y_smugmech_01' 
    --             },
    --         }
    --     },

    --     vehicles = { 
    --         {
    --             model = 'modelname', 
    --             label = 'Vehicle Label', 
    --             grade = 1 
    --         },
    --     }
    -- },

}
