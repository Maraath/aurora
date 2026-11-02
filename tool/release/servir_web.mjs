// Serve build/web com os cabeçalhos de web/_headers, como o Cloudflare Pages: é o jeito
// de conferir a Content-Security-Policy antes de publicar (violações aparecem no console).
//   node tool/release/servir_web.mjs 8766

import { createReadStream, existsSync, readFileSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join, normalize } from "node:path";

const raiz = "build/web";
const tipos = {
  ".html": "text/html; charset=utf-8", ".js": "text/javascript", ".mjs": "text/javascript", ".json": "application/json",
  ".wasm": "application/wasm", ".png": "image/png", ".ttf": "font/ttf", ".otf": "font/otf", ".webp": "image/webp",
};

// Só a seção "/*" importa aqui: as outras tratam de cache.
const cabecalhos = {};
let naSecao = false;
for (const linha of readFileSync("web/_headers", "utf8").split(/\r?\n/)) {
  if (linha.startsWith("/")) naSecao = linha.trim() === "/*";
  else if (naSecao && linha.startsWith("  ")) {
    const i = linha.indexOf(":");
    cabecalhos[linha.slice(0, i).trim()] = linha.slice(i + 1).trim();
  }
}

createServer((pedido, resposta) => {
  const caminho = normalize(decodeURIComponent(pedido.url.split("?")[0])).replace(/^(\.\.[\\/])+/, "");
  let arquivo = join(raiz, caminho);
  if (!existsSync(arquivo) || statSync(arquivo).isDirectory()) arquivo = join(raiz, "index.html");
  resposta.writeHead(200, { ...cabecalhos, "Content-Type": tipos[extname(arquivo)] ?? "application/octet-stream" });
  createReadStream(arquivo).pipe(resposta);
}).listen(Number(process.argv[2] ?? 8766));
