const fs = require('fs');
const path = require('path');

function readLocale(lang) {
  const dir = path.resolve('..', 'freebify-ref', 'src', 'i18n', 'locales', lang);
  const files = fs.readdirSync(dir);
  const all = {};
  for (const f of files) {
    if (!f.endsWith('.ts')) continue;
    const content = fs.readFileSync(path.join(dir, f), 'utf8');
    const regex = /"([^"]+)":\s*"([^"\\]*(?:\\.[^"\\]*)*)"/g;
    let match;
    while ((match = regex.exec(content)) !== null) {
      all[match[1]] = match[2];
    }
  }
  return all;
}

const en = readLocale('en');
const es = readLocale('es');
console.log('EN key count:', Object.keys(en).length);
console.log('ES key count:', Object.keys(es).length);
fs.writeFileSync('tool/en_keys.json', JSON.stringify(en, null, 2));
fs.writeFileSync('tool/es_keys.json', JSON.stringify(es, null, 2));
