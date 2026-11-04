const fs = require('fs');
const en = JSON.parse(fs.readFileSync('tool/en_keys.json', 'utf8'));
const placeholders = {};
for (const [k, v] of Object.entries(en)) {
  const matches = v.match(/\{(\w+)\}/g);
  if (matches) {
    placeholders[k] = { value: v, vars: matches };
  }
}
console.log('Keys with placeholders count:', Object.keys(placeholders).length);
fs.writeFileSync('tool/placeholders.json', JSON.stringify(placeholders, null, 2));
console.log(JSON.stringify(placeholders, null, 2).slice(0, 1000));
