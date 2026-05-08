(function () {
  if (!model || !model.chatMessages || !model.chatMessages.subscribe) {
    return;
  }

  model.chatMessages.subscribe(function () {
    api.audio.playSound('/SE/UI/UI_camera_anchor_saved');
  });
})();
