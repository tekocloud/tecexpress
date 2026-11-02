// Generate a small synthetic PNG tile without external assets or dependencies.
import fs from 'node:fs';
import { deflateSync } from 'node:zlib';
const crc = data => { let value = 0xffffffff; for (const byte of data) { value ^= byte; for (let i = 0; i < 8; i++) value = (value >>> 1) ^ (0xedb88320 & -(value & 1)); } return (value ^ 0xffffffff) >>> 0; };
const chunk = (type, data) => { const name = Buffer.from(type), length = Buffer.alloc(4), checksum = Buffer.alloc(4); length.writeUInt32BE(data.length); checksum.writeUInt32BE(crc(Buffer.concat([name, data]))); return Buffer.concat([length, name, data, checksum]); };
const header = Buffer.alloc(13); header.writeUInt32BE(256); header.writeUInt32BE(256, 4); header[8] = 8; header[9] = 2;
const pixels = Buffer.alloc(256 * (1 + 256 * 3));
for (let y = 0; y < 256; y++) for (let x = 0; x < 256; x++) {
  const road = x % 64 < 7 || y % 64 < 7;
  const river = Math.abs(x - (120 + Math.sin(y / 50) * 27)) < 9;
  const park = x > 170 && x < 240 && y > 80 && y < 180;
  const color = river ? [177, 214, 225] : road ? [255, 255, 250] : park ? [186, 218, 179] : [230, 237, 222];
  color.forEach((v, i) => { pixels[y * 769 + 1 + x * 3 + i] = v; });
}
fs.mkdirSync('_web/demos/tiles', { recursive: true });
fs.writeFileSync('_web/demos/tiles/demo.png', Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]), chunk('IHDR', header), chunk('IDAT', deflateSync(pixels)), chunk('IEND', Buffer.alloc(0))]));
