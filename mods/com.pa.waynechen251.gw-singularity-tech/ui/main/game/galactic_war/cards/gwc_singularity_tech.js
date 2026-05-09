// !LOCNS:galactic_war
define([
    'shared/gw_common',
    'cards/gwc_enable_air_all',
    'cards/gwc_enable_bots_all',
    'cards/gwc_enable_vehicles_all',
    'cards/gwc_enable_orbital_all',
    'cards/gwc_enable_sea_all',
    'cards/gwc_enable_artillery',
    'cards/gwc_enable_defenses_t2',
    'cards/gwc_enable_super_weapons',
    'cards/gwc_enable_titans',
    'cards/gwc_bld_efficiency_cdr',
    'cards/gwc_bld_efficiency_fabs',
    'cards/gwc_cost_air',
    'cards/gwc_cost_artillery',
    'cards/gwc_cost_bots',
    'cards/gwc_cost_defenses',
    'cards/gwc_cost_economy',
    'cards/gwc_cost_intel',
    'cards/gwc_cost_orbital',
    'cards/gwc_cost_sea',
    'cards/gwc_cost_super_weapons',
    'cards/gwc_cost_titans',
    'cards/gwc_cost_vehicles'
], function (
    GW,
    enableAirAll,
    enableBotsAll,
    enableVehiclesAll,
    enableOrbitalAll,
    enableSeaAll,
    enableArtillery,
    enableDefensesT2,
    enableSuperWeapons,
    enableTitans,
    buildEfficiencyCommander,
    buildEfficiencyFabricators,
    costAir,
    costArtillery,
    costBots,
    costDefenses,
    costEconomy,
    costIntel,
    costOrbital,
    costSea,
    costSuperWeapons,
    costTitans,
    costVehicles
) {
    var allTechCards = [
        enableAirAll,
        enableBotsAll,
        enableVehiclesAll,
        enableOrbitalAll,
        enableSeaAll,
        enableArtillery,
        enableDefensesT2,
        enableSuperWeapons,
        enableTitans,
        buildEfficiencyCommander,
        buildEfficiencyFabricators,
        costAir,
        costArtillery,
        costBots,
        costDefenses,
        costEconomy,
        costIntel,
        costOrbital,
        costSea,
        costSuperWeapons,
        costTitans,
        costVehicles
    ];

    var basicFabberUnlockMods = [
        {
            file: '/pa/units/land/fabrication_bot/fabrication_bot.json',
            path: 'buildable_types',
            op: 'add',
            value: ' | Land & Structure & Advanced - Factory | Factory & Advanced & Bot & Land | FabAdvBuild'
        },
        {
            file: '/pa/units/land/fabrication_vehicle/fabrication_vehicle.json',
            path: 'buildable_types',
            op: 'add',
            value: ' | Structure & Land & Advanced - Factory | Factory & Land & Tank & Advanced | FabAdvBuild'
        },
        {
            file: '/pa/units/air/fabrication_aircraft/fabrication_aircraft.json',
            path: 'buildable_types',
            op: 'add',
            value: ' | Land & Structure & Advanced - Factory | Factory & Advanced & Air | FabAdvBuild'
        },
        {
            file: '/pa/units/sea/fabrication_ship/fabrication_ship.json',
            path: 'buildable_types',
            op: 'add',
            value: ' | Naval & Structure & Advanced | Naval & Factory & Advanced | FabAdvBuild'
        },
        {
            file: '/pa/units/orbital/orbital_fabrication_bot/orbital_fabrication_bot.json',
            path: 'buildable_types',
            op: 'add',
            value: ' | FabOrbBuild'
        },
        {
            file: '/pa/units/commanders/base_commander/base_commander.json',
            path: 'buildable_types',
            op: 'add',
            value: ' | Structure & Advanced | Factory & Advanced | FabAdvBuild | FabOrbBuild'
        }
    ];

    return {
        visible: function () { return true; },
        describe: function () {
            return '!LOC:奇點工程科技：一次獲得所有完整建造科技、全部建造效率強化、全部製造成本減免，並讓所有基礎建造者（含軌道）與指揮官可建造高階建築與工廠。';
        },
        summarize: function () {
            return '!LOC:奇點工程科技';
        },
        icon: function () {
            return 'coui://ui/main/game/galactic_war/gw_play/img/tech/gwc_metal.png';
        },
        audio: function () {
            return {
                found: '/VO/Computer/gw/board_tech_available_efficiency'
            };
        },
        getContext: function (galaxy) {
            return {
                totalSize: galaxy.stars().length
            };
        },
        deal: function () {
            return { chance: 1 };
        },
        buff: function (inventory, params) {
            _.forEach(allTechCards, function (card) {
                if (card && _.isFunction(card.buff))
                    card.buff(inventory, params);
            });
            inventory.addMods(basicFabberUnlockMods);
        },
        dull: function () { }
    };
});
