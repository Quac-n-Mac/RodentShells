import base64, os, gzip, hashlib, pathlib
# Usage: GODOT_RUNTIME=/path/to/web PCK=/path/to/game.pck OUTPUT=/path/to/output.html python3 build-single-html.py
tools_dir = pathlib.Path(__file__).resolve().parent
runtime_dir = os.environ.get("GODOT_RUNTIME", "/tmp/godot/webnth")
pck_path = os.environ.get("PCK", "/tmp/rodentshells.pck")
output_path = os.environ.get("OUTPUT", "/tmp/RodentShells.html")
os.chdir(runtime_dir)
def raw_b64(path):
    data = open(path,'rb').read()
    return base64.b64encode(data).decode(), len(data)

wk1,_ = raw_b64('godot.audio.worklet.js')
wk2,_ = raw_b64('godot.audio.position.worklet.js')
wasm_data = open('godot.wasm','rb').read()
pck_data = open(pck_path,'rb').read()
wasm_raw, pck_raw = len(wasm_data), len(pck_data)
wasm = base64.b64encode(gzip.compress(wasm_data,compresslevel=6,mtime=0)).decode()
pck = base64.b64encode(gzip.compress(pck_data,compresslevel=6,mtime=0)).decode()
cache_version = hashlib.sha256(wasm_data+pck_data).hexdigest()[:20]
godotjs = open('godot.js').read()

loader = r'''
(async function(){
var fill=document.getElementById('rs-fill'), pct=document.getElementById('rs-pct'),
    status=document.getElementById('rs-status'), splash=document.getElementById('rs-splash'),
    msg=document.getElementById('rs-msg');
function fail(t){ status.style.display='flex'; status.innerHTML='<div style="max-width:480px;text-align:center">'+t+'</div>'; }
async function b64(id){
  var s=document.getElementById(id).textContent.trim(), n=s.length, out=new Uint8Array((n>>2)*3), o=0, STEP=1048576;
  for(var i=0;i<n;i+=STEP){
    var bin=atob(s.slice(i,i+STEP));
    for(var j=0;j<bin.length;j++) out[o++]=bin.charCodeAt(j);
    fill.style.width=Math.round(i/n*100)+'%';
    await new Promise(function(r){setTimeout(r,0)});
  }
  return new Response(new Blob([out.subarray(0,o)]).stream().pipeThrough(new DecompressionStream('gzip'))).arrayBuffer();
}
var cacheKey='__CACHE_VERSION__', cacheDb=null;
async function openCache(){
  return new Promise(function(resolve){
    var done=false, timer=setTimeout(function(){done=true;resolve(null)},1500);
    try{
      var req=indexedDB.open('RodentShells-assets',1);
      req.onupgradeneeded=function(){req.result.createObjectStore('assets')};
      req.onerror=function(){clearTimeout(timer);if(!done){done=true;resolve(null)}};
      req.onsuccess=function(){clearTimeout(timer);if(done){req.result.close();return}done=true;resolve(req.result)};
    }catch(e){clearTimeout(timer);resolve(null)}
  });
}
async function cachedAssets(){
  cacheDb=await openCache(); if(!cacheDb)return null;
  return new Promise(function(resolve){
    var done=false,timer=setTimeout(function(){done=true;resolve(null)},2000);
    try{
      var req=cacheDb.transaction('assets','readonly').objectStore('assets').get(cacheKey);
      req.onsuccess=function(){clearTimeout(timer);if(!done){done=true;resolve(req.result||null)}};
      req.onerror=function(){clearTimeout(timer);if(!done){done=true;resolve(null)}};
    }catch(e){clearTimeout(timer);resolve(null)}
  });
}
function saveAssets(wasm,pck){
  if(!cacheDb)return;
  try{
    var tx=cacheDb.transaction('assets','readwrite'), store=tx.objectStore('assets');
    store.clear();store.put({wasm:wasm,pck:pck},cacheKey);
    tx.oncomplete=function(){console.log('RS asset cache saved')};
    tx.onerror=function(){console.log('RS asset cache unavailable; embedded fallback retained')};
    tx.onabort=tx.onerror;
  }catch(e){console.log('RS asset cache unavailable; embedded fallback retained')}
}
function b64text(id){ return document.getElementById(id).textContent.replace(/\s+/g,''); }
var wkUrls={
  'godot.audio.worklet.js':'data:text/javascript;base64,'+b64text('rs-wk1'),
  'godot.audio.position.worklet.js':'data:text/javascript;base64,'+b64text('rs-wk2')
};
var unpackStart=performance.now();
msg.textContent='Checking local asset cache...';
var cached=await cachedAssets(), wasm,pck;
var cacheHit=!!(cached&&cached.wasm&&cached.pck&&cached.wasm.byteLength===__WASM_RAW__&&cached.pck.byteLength===__PCK_RAW__);
if(cacheHit){wasm=cached.wasm;pck=cached.pck;msg.textContent='Using cached assets...'}
else{
  msg.textContent='Unpacking engine...';wasm=await b64('rs-wasm');
  msg.textContent='Unpacking game...';pck=await b64('rs-pck');
}
console.log('RS asset unpack cache_hit='+cacheHit+' ms='+Math.round(performance.now()-unpackStart));
document.getElementById('rs-wasm').remove(); document.getElementById('rs-pck').remove();
var origAdd=AudioWorklet.prototype.addModule;
AudioWorklet.prototype.addModule=function(url,opts){
  var u=String(url);
  if(u.indexOf('godot.audio.position.worklet.js')>=0) u=wkUrls['godot.audio.position.worklet.js'];
  else if(u.indexOf('godot.audio.worklet.js')>=0) u=wkUrls['godot.audio.worklet.js'];
  return origAdd.call(this,u,opts);
};
var realFetch=window.fetch.bind(window);
window.fetch=function(url,opts){
  var u=String(url);
  if(u.indexOf('godot.wasm')>=0) return Promise.resolve(new Response(new Blob([wasm])));
  if(u.indexOf('godot.pck')>=0) return Promise.resolve(new Response(new Blob([pck])));
  return realFetch(url,opts);
};
msg.textContent='Starting engine...';
var engine=new Engine({executable:'godot',canvas:document.getElementById('canvas'),fileSizes:{'godot.wasm':__WASM_RAW__,'godot.pck':__PCK_RAW__}});
engine.startGame({onProgress:function(c,t){ if(t>0){var p=Math.round(c/t*100); fill.style.width=p+'%'; pct.textContent=p+'%'; } }}).then(function(){
  if(!cacheHit)setTimeout(function(){saveAssets(wasm,pck)},1500);
  status.style.display='none';
  splash.style.display='flex';
  var started=false;
  var go=function(){
    if(started) return; started=true;
    splash.style.display='none';
    var el=document.documentElement;
    try{ if(el.requestFullscreen) el.requestFullscreen().then(function(){
      try{ if(navigator.keyboard&&navigator.keyboard.lock) navigator.keyboard.lock(['Escape']).catch(function(){}); }catch(e){}
    }).catch(function(){}); }catch(e){}
    document.getElementById('canvas').focus();
  };
  splash.addEventListener('click',go);
  window.addEventListener('keydown',go,{once:false});
}).catch(function(e){ console.error(e); fail('Failed to start RodentShells: '+(e&&e.message||e)); });
})().catch(function(e){console.error(e);document.getElementById('rs-msg').textContent='Unable to unpack game: '+e.message});
'''
loader = loader.replace('__WASM_RAW__', str(wasm_raw)).replace('__PCK_RAW__', str(pck_raw)).replace('__CACHE_VERSION__',cache_version)
loader = open(tools_dir / 'pointer-recovery.js').read() + '\n' + loader
loader = open(tools_dir / 'browser-controls.js').read() + '\n' + loader

html_head = '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>RodentShells</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:#000}
#canvas{display:block;width:100%;height:100%;outline:none}
#rs-status{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;background:#000;color:#f7a8d8;font:14px monospace;z-index:10}
#rs-bar{width:280px;height:10px;border:1px solid #f7a8d8;margin-top:12px}
#rs-fill{height:100%;width:0%;background:#f7a8d8}
#rs-pct{margin-top:8px}
#rs-splash{position:fixed;inset:0;display:none;flex-direction:column;align-items:center;justify-content:center;background:rgba(0,0,0,.72);color:#f7a8d8;font:20px monospace;z-index:20;cursor:pointer;text-align:center}
#rs-splash small{font-size:12px;opacity:.7;margin-top:14px;line-height:1.7}
</style></head><body>
<canvas id="canvas" tabindex="0">Your browser does not support the canvas tag.</canvas>
<div id="rs-status"><div id="rs-msg">Loading RodentShells...</div><div id="rs-bar"><div id="rs-fill"></div></div><div id="rs-pct"></div></div>
<div id="rs-splash"><div>RODENTSHELLS<br><br>CLICK OR PRESS ANY KEY TO START</div><small>goes fullscreen - ESC opens the pause menu in-game<br>use your browser's F11 (or the game's Options) to leave fullscreen</small></div>
'''

out = open(output_path,'w')
out.write(html_head)
out.write('<script type="application/octet-stream" id="rs-wk1">'); out.write(wk1); out.write('</script>\n')
out.write('<script type="application/octet-stream" id="rs-wk2">'); out.write(wk2); out.write('</script>\n')
out.write('<script type="application/octet-stream" id="rs-wasm">'); out.write(wasm); out.write('</script>\n')
out.write('<script type="application/octet-stream" id="rs-pck">'); out.write(pck); out.write('</script>\n')
out.write('<script>\n'); out.write(godotjs); out.write('\n</script>\n')
out.write('<script>\n'); out.write(loader); out.write('\n</script>\n</body></html>\n')
out.close()
print('html bytes:', os.path.getsize(output_path))
