// Assina um arquivo com a chave de atualização (ver gerar_chave_atualizacao.mjs) e grava
// a assinatura em base64 ao lado, trocando a extensão por .sig:
//   node tool\release\assinar.mjs build\instalador\versao.json

import { createPrivateKey, sign } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";

const arquivo = process.argv[2];
if (!arquivo) throw new Error("Diga qual arquivo assinar.");
const chave = createPrivateKey(readFileSync("C:\\src\\chaves\\aurora-atualizacao.pem"));
writeFileSync(arquivo.replace(/\.json$/, ".sig"), sign(null, readFileSync(arquivo), chave).toString("base64"));
