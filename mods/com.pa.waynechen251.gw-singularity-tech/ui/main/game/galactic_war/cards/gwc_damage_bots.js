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

    return {
        visible: function (params) { return true; },
        describe: function (params) {
            return '!LOC:奇點工程科技：一次獲得所有完整建造科技、全部建造效率強化與全部製造成本減免。';
        },
        summarize: function (params) {
            return '!LOC:奇點工程科技';
        },
        icon: function (params) {
            return 'coui://ui/main/game/galactic_war/gw_play/img/tech/gwc_metal.png';
        },
        audio: function (params) {
            return {
                found: '/VO/Computer/gw/board_tech_available_efficiency'
            };
        },
        getContext: function (galaxy) {
            return {
                totalSize: galaxy.stars().length
            };
        },
        deal: function (system, context, inventory) {
            var chance = 1000000;
            return { chance: chance };
        },
        buff: function (inventory, params) {
            _.forEach(allTechCards, function (card) {
                if (card && _.isFunction(card.buff))
                    card.buff(inventory, params);
            });
        },
        dull: function (inventory) { }
    };
});
