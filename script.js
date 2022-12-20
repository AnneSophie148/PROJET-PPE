// app.js

'use strict';

document.addEventListener('DOMContentLoaded', function () {

  var tabs = document.getElementsByClassName('tabs');
  if (tabs) {
    var _loop = function _loop() {
      var tabListItems = tabs[i].querySelectorAll('li');
      tabListItems.forEach(function (tabListItem) {

        // création d'un écouteur d'évènements sur le clic d'une tab
        tabListItem.addEventListener('click', function () {

          // suppression de la classe is-active sur chacune des tabs avant de la rajouter sur la tab qui a été cliquée
          tabListItems.forEach(function (tabListItem) {
            tabListItem.classList.remove('is-active');
          });
          tabListItem.classList.add('is-active');

          // tabName correspond à la valeur de l'attribut data-tab
          var tabName = tabListItem.dataset.tab;

          // on identifie tous les contenus possibles puis on applique la classe has-display-none si l'ID du contenu ne correspond pas à la valeur de l'attribut data-tab
          tabListItem.closest('.js-tabs-container').querySelectorAll('.js-tab-content').forEach(function (tabContent) {

            if (tabContent.id !== tabName) {
              tabContent.classList.add('has-display-none');
            } else {
              tabContent.classList.remove('has-display-none');
            }
          });
        }, false);
      });
    };

    for (var i = 0; i < tabs.length; i++) {
      _loop();
    }
  }
});
