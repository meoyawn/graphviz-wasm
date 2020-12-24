const path = require('path')

const modulePromise = require('./graphviz')({
  locateFile: (file, prefix) => {
    return path.join(process.cwd(), file)
  }
}).then(gv => {
  return {
    layout: gv.cwrap('layout', 'string', ['string', 'string', 'string', 'number']),
    lastErr: gv.cwrap('lastErr', 'string', []),
  }
});

(async () => {
  const f = await modulePromise

  console.log(f.lastErr());
})()
