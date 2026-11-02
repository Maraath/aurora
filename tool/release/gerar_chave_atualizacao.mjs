// Cria a chave que assina o versao.json (Ed25519). Rodar uma vez só:
//   node tool\release\gerar_chave_atualizacao.mjs
// A privada fica em C:\src\chaves, fora do Git; a pública vai em chavePublicaAtualizacao
// (lib/core/atualizacao.dart). Perdeu a privada? Os apps instalados param de aceitar
// atualizações e precisam de uma instalação nova com outra chave.

import { generateKeyPairSync } from "node:crypto";
import { existsSync, writeFileSync } from "node:fs";

const caminho = "C:\\src\\chaves\\aurora-atualizacao.pem";
if (existsSync(caminho)) throw new Error(`Já existe ${caminho}: não troque a chave sem necessidade.`);

const { privateKey, publicKey } = generateKeyPairSync("ed25519");
writeFileSync(caminho, privateKey.export({ type: "pkcs8", format: "pem" }), { flag: "wx" });
// Os últimos 32 bytes do formato DER são a chave pública crua.
console.log(publicKey.export({ type: "spki", format: "der" }).subarray(-32).toString("base64"));
