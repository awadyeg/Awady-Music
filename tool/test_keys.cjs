const fs = require('fs');

const en = JSON.parse(fs.readFileSync('tool/en_keys.json', 'utf8'));

function toCamelCase(str) {
  // Replace dots, dashes, underscores with camelCase
  return str.replace(/[-_.]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ''));
}

const map = new Map();
let clashes = 0;
for (const key of Object.keys(en)) {
  const camel = toCamelCase(key);
  if (map.has(camel)) {
    console.error(`Clash: "${key}" and "${map.get(camel)}" -> "${camel}"`);
    clashes++;
  } else {
    map.set(camel, key);
  }
}

console.log(`Converted ${Object.keys(en).length} keys. Clashes: ${clashes}`);
