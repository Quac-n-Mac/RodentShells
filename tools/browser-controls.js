(function () {
  function sync() { window.rsBrowserFullscreen = !!document.fullscreenElement; }
  sync();
  document.addEventListener('fullscreenchange', sync);
  document.addEventListener('fullscreenerror', sync);
  window.rsToggleFullscreen = function () {
    var operation;
    try {
      operation = document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen();
      if (operation && operation.catch) operation.catch(function () { sync(); });
    } catch (e) { sync(); }
  };
  window.addEventListener('keydown', function (event) {
    if (event.code !== 'F11' || event.repeat) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    window.rsToggleFullscreen();
  }, true);
  window.rsQuitToBrowser = function () {
    try { window.close(); } catch (e) {}
    if (window.rsSetGameplayCapture) window.rsSetGameplayCapture(false);
    if (navigator.keyboard && navigator.keyboard.unlock) navigator.keyboard.unlock();
    if (document.fullscreenElement) {
      var result = document.exitFullscreen();
      if (result && result.catch) result.catch(function () {});
    }
    var panel = document.getElementById('rs-quit');
    if (!panel) {
      panel = document.createElement('div');
      panel.id = 'rs-quit';
      panel.style.cssText = 'position:fixed;inset:0;z-index:20000;background:#080810;color:#f7a8d8;display:flex;flex-direction:column;align-items:center;justify-content:center;font:20px monospace;text-align:center;cursor:auto';
      var title = document.createElement('p'); title.textContent = 'You can close this tab.';
      var button = document.createElement('button'); button.textContent = 'RELOAD GAME';
      button.style.cssText = 'font:16px monospace;padding:12px;color:#f7a8d8;background:#111;border:2px solid #f7a8d8;cursor:pointer';
      button.onclick = function () { location.reload(); };
      panel.appendChild(title); panel.appendChild(button); document.body.appendChild(panel);
    }
    panel.style.display = 'flex';
    panel.querySelector('button').focus();
  };
})();
