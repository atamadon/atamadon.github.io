// /assets/js/molecular-viewer.js

// Load this after ngl.js:
// <script src="https://cdn.jsdelivr.net/npm/ngl@0.10.4/dist/ngl.js"></script>
// <script src="/assets/js/molecular-viewer.js" type="module"></script>

const viewers = [];

function hexFromCSS(varName) {
  const val = getComputedStyle(document.documentElement).getPropertyValue(varName).trim();
  if (val.startsWith('#')) return parseInt(val.replace('#', ''), 16);
  if (val.startsWith('rgb')) {
    const [r, g, b] = val.match(/\d+/g).map(Number);
    return (r << 16) + (g << 8) + b;
  }
  return 0xffffff;
}

function updateBackgrounds() {
  const bg = hexFromCSS('--background');
  viewers.forEach(stage => stage.setParameters({ backgroundColor: bg }));
}

function setupViewer(el) {
  const file = el.dataset.file;
  if (!file) {
    console.warn('No file provided for viewer:', el);
    return;
  }

  const repr = el.dataset.repr || 'cartoon';
  const color = el.dataset.color || 'chainname';
  const sele  = el.dataset.sele  || 'protein';

  const stage = new NGL.Stage(el);
  viewers.push(stage);

  window.addEventListener('resize', () => stage.handleResize());
  stage.setParameters({ backgroundColor: hexFromCSS('--background') });

  stage.loadFile(file).then(component => {
    component.addRepresentation(repr, { color, sele });
    component.autoView();
  }).catch(err => console.error('NGL load failed:', err));
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.ngl-viewer').forEach(setupViewer);
  window.addEventListener('themeChanged', updateBackgrounds);
});
