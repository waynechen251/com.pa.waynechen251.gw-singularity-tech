(function () {
    var targetCardId = 'gwc_singularity_tech';
    var dealerPatchFlag = '__waynechen251_force_first_pick_patched__';
    var explorePatchFlag = '__waynechen251_force_explore_patched__';

    var getCardId = function (entry) {
        if (!entry)
            return undefined;
        if (typeof entry === 'string')
            return entry;
        return entry.id;
    };

    var makeCardEntryLike = function (entry, id) {
        if (typeof entry === 'string')
            return id;
        return { id: id };
    };

    var forceCardFirst = function (list, inventory) {
        var hasList = _.isArray(list) && list.length > 0;
        var alreadyOwned = inventory && _.isFunction(inventory.hasCard) && inventory.hasCard(targetCardId);
        if (!hasList || alreadyOwned)
            return list;

        var targetIndex = -1;
        for (var i = 0; i < list.length; i++) {
            if (getCardId(list[i]) === targetCardId) {
                targetIndex = i;
                break;
            }
        }

        if (targetIndex === -1) {
            list[0] = makeCardEntryLike(list[0], targetCardId);
        } else if (targetIndex > 0) {
            var card = list[targetIndex];
            list.splice(targetIndex, 1);
            list.unshift(card);
        }

        return list;
    };

    var patchDealer = function (GWDealer) {
        if (!GWDealer || GWDealer[dealerPatchFlag])
            return;

        if (typeof GWDealer.chooseCards !== 'function')
            return;

        GWDealer[dealerPatchFlag] = true;

        if (_.isFunction(GWDealer.addCards)) {
            GWDealer.addCards([targetCardId]);
        }

        var originalChooseCards = GWDealer.chooseCards;

        GWDealer.chooseCards = function (params) {
            var promise = originalChooseCards.call(this, params);
            var deferred = $.Deferred();

            $.when(promise).then(function (list) {
                try {
                    var inventory = params && params.inventory;
                    forceCardFirst(list, inventory);
                } catch (e) {
                }

                deferred.resolve(list);
            }, function (err) {
                deferred.reject(err);
            });

            return deferred.promise();
        };
    };

    var patchExplore = function () {
        if (typeof model === 'undefined' || !model || !_.isFunction(model.explore))
            return false;

        if (model.explore[explorePatchFlag])
            return true;

        var originalExplore = model.explore;

        var wrappedExplore = function () {
            var result = originalExplore.apply(this, arguments);

            var applyPatch = function () {
                try {
                    var game = model && _.isFunction(model.game) && model.game();
                    var inventory = game && _.isFunction(game.inventory) && game.inventory();
                    var galaxy = game && _.isFunction(game.galaxy) && game.galaxy();
                    var currentStarIndex = game && _.isFunction(game.currentStar) && game.currentStar();
                    var star = galaxy && _.isFunction(galaxy.stars) && galaxy.stars()[currentStarIndex];
                    var cardList = star && _.isFunction(star.cardList) && star.cardList();
                    if (!_.isArray(cardList) || !cardList.length)
                        return;

                    var patched = forceCardFirst(cardList.slice(0), inventory);
                    star.cardList(patched);
                } catch (e) {
                }
            };

            _.delay(applyPatch, 0);
            _.delay(applyPatch, 300);
            _.delay(applyPatch, 1000);

            return result;
        };

        wrappedExplore[explorePatchFlag] = true;
        model.explore = wrappedExplore;
        return true;
    };

    if (typeof requireGW === 'function') {
        requireGW(['pages/gw_start/gw_dealer'], patchDealer);
    } else if (typeof require === 'function') {
        require(['coui://ui/main/game/galactic_war/gw_start/gw_dealer.js'], patchDealer);
    }

    var attempts = 0;
    var timer = setInterval(function () {
        attempts++;
        patchExplore();
        if (attempts >= 40)
            clearInterval(timer);
    }, 500);
})();
