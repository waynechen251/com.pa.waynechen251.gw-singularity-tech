(function () {
  if (!api || !api.settings || !api.settings.definitions || !model) {
    return;
  }

  var key = "__MOD_IDENTIFIER___chat_alert_sound";
  api.settings.definitions.ui = api.settings.definitions.ui || {};
  api.settings.definitions.ui.settings = api.settings.definitions.ui.settings || {};
  api.settings.definitions.ui.settings[key] = {
    "default": "/SE/UI/UI_camera_anchor_saved",
    "options": [
      "",
      "/SE/UI/UI_ping",
      "/SE/UI/UI_camera_anchor_saved"
    ],
    "title": "CHAT ALERT SOUND",
    "type": "select"
  };

  if (model.settingDefinitions) {
    model.settingDefinitions(api.settings.definitions);
  }
})();
