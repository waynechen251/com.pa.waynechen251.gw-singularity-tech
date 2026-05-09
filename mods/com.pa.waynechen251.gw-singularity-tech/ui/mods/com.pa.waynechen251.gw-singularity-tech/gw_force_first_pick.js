(function () {
    var targetCardId = 'gwc_damage_bots';
    var patchFlag = '__waynechen251_force_first_pick_patched__';

    var patchDealer = function (GWDealer) {
        if (!GWDealer || GWDealer[patchFlag])
            return;

        if (typeof GWDealer.chooseCards !== 'function')
            return;

        GWDealer[patchFlag] = true;

        var originalChooseCards = GWDealer.chooseCards;

        GWDealer.chooseCards = function (params) {
            var promise = originalChooseCards.call(this, params);
            var deferred = $.Deferred();

            $.when(promise).then(function (list) {
                try {
                    var hasInventory = params && params.inventory && typeof params.inventory.hasCard === 'function';
                    var alreadyOwned = hasInventory && params.inventory.hasCard(targetCardId);
                    var hasList = _.isArray(list) && list.length > 0;

                    if (!alreadyOwned && hasList) {
                        var targetIndex = -1;
                        for (var i = 0; i < list.length; i++) {
                            if (list[i] && list[i].id === targetCardId) {
                                targetIndex = i;
                                break;
                            }
                        }

                        if (targetIndex === -1) {
                            list[0] = { id: targetCardId };
                        } else if (targetIndex > 0) {
                            var card = list[targetIndex];
                            list.splice(targetIndex, 1);
                            list.unshift(card);
                        }
                    }
                } catch (e) {
                }

                deferred.resolve(list);
            }, function (err) {
                deferred.reject(err);
            });

            return deferred.promise();
        };
    };

    if (typeof require === 'function') {
        require(['pages/gw_start/gw_dealer'], patchDealer);
    }
})();
