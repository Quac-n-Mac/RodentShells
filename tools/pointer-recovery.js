// Preserve the game's capture/release intent across browser fullscreen changes.
(function () {
  var canvas = document.getElementById('canvas');
  if (!canvas || canvas.dataset.rsPointerRecovery) return;
  canvas.dataset.rsPointerRecovery = '1';
  var request = canvas.requestPointerLock;
  var exit = document.exitPointerLock;
  var wantsCapture = false, pending = false, gameplay = null;
  function cursor() {
    canvas.classList.toggle('rs-captured', wantsCapture);
  }
  function recover() {
    cursor();
    if (!wantsCapture || document.hidden || !document.hasFocus() || !request || pending || document.pointerLockElement === canvas) return;
    pending = true;
    try {
      var result = request.call(canvas);
      if (result && result.then) result.then(function () { pending = false; }, function () { pending = false; });
      else pending = false;
    } catch (e) { pending = false; }
  }
  window.rsSetGameplayCapture = function (active) {
    gameplay = !!active;
    wantsCapture = gameplay;
    cursor();
    if (gameplay) recover();
    else {
      pending = false;
      if (document.pointerLockElement === canvas && exit) exit.call(document);
    }
  };
  if (request) canvas.requestPointerLock = function () {
    if (gameplay === false) return Promise.resolve();
    wantsCapture = true;
    cursor();
    // Godot does not consume the returned promise. Always handle rejection.
    recover();
    return Promise.resolve();
  };
  if (exit) document.exitPointerLock = function () {
    wantsCapture = false;
    cursor();
    return exit.call(document);
  };
  document.addEventListener('pointerlockchange', function () {
    pending = false;
    cursor();
    // Esc may drop capture. Do not fight Esc: the next canvas click recovers it.
  });
  document.addEventListener('pointerlockerror', function () { pending = false; });
  document.addEventListener('fullscreenchange', function () {
    canvas.focus({preventScroll: true});
    recover();
  });
  window.addEventListener('focus', recover);
  document.addEventListener('visibilitychange', function () { if (!document.hidden) recover(); });
  canvas.addEventListener('mousedown', function (event) {
    if (wantsCapture && document.pointerLockElement !== canvas) {
      event.preventDefault();
      event.stopImmediatePropagation();
      canvas.focus({preventScroll: true});
      recover();
    }
  }, true);
  var style = document.createElement('style');
  style.textContent = '#canvas.rs-captured{cursor:none!important}';
  document.head.appendChild(style);
})();
