(function () {
  if (!model || !model.chatLog || !model.chatLog.subscribe) {
    return;
  }

  model.chatLog.subscribe(function () {
    api.audio.playSound('/SE/UI/UI_camera_anchor_saved');
  });
})();
