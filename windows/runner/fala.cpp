#include "fala.h"

#include <flutter/standard_method_codec.h>

#include <string>

#include <atlbase.h>

#pragma warning(disable : 4996)
#include <sphelper.h>
#pragma warning(default : 4996)

namespace {

std::wstring ParaUtf16(const std::string& texto) {
  if (texto.empty()) return std::wstring();
  const int n = MultiByteToWideChar(CP_UTF8, 0, texto.data(),
                                    static_cast<int>(texto.size()), nullptr, 0);
  std::wstring saida(n, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, texto.data(), static_cast<int>(texto.size()),
                      saida.data(), n);
  return saida;
}

}  // namespace

Fala::Fala(flutter::BinaryMessenger* mensageiro, HWND janela)
    : janela_(janela) {
  canal_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      mensageiro, "aurora/fala", &flutter::StandardMethodCodec::GetInstance());
  canal_->SetMethodCallHandler([this](const auto& chamada, auto resultado) {
    const std::string& metodo = chamada.method_name();
    if (metodo == "falar") {
      const auto* texto = std::get_if<std::string>(chamada.arguments());
      if (texto == nullptr || !Preparar()) {
        resultado->Success(flutter::EncodableValue(false));
        return;
      }
      Falar(*texto);
      resultado->Success(flutter::EncodableValue(true));
    } else if (metodo == "parar") {
      Parar();
      resultado->Success();
    } else {
      resultado->NotImplemented();
    }
  });
}

Fala::~Fala() {
  canal_ = nullptr;
  if (voz_ != nullptr) {
    voz_->SetNotifySink(nullptr);
    voz_->Speak(nullptr, SPF_PURGEBEFORESPEAK, nullptr);
    voz_->Release();
    voz_ = nullptr;
  }
}

// Só na primeira fala: cria a voz, escolhe a pt-BR (Maria) e pede o aviso de
// fim na janela.
bool Fala::Preparar() {
  if (preparada_) return voz_ != nullptr;
  preparada_ = true;
  if (FAILED(CoCreateInstance(CLSID_SpVoice, nullptr, CLSCTX_ALL, IID_ISpVoice,
                              reinterpret_cast<void**>(&voz_)))) {
    voz_ = nullptr;
    return false;
  }
  CComPtr<IEnumSpObjectTokens> vozes;
  // 416 = português do Brasil.
  if (SUCCEEDED(SpEnumTokens(SPCAT_VOICES, L"Language=416", nullptr, &vozes))) {
    CComPtr<ISpObjectToken> escolhida, token;
    while (vozes->Next(1, &token, nullptr) == S_OK) {
      CSpDynamicString nome;
      if (escolhida == nullptr ||
          (SUCCEEDED(SpGetDescription(token, &nome)) && wcsstr(nome, L"Maria"))) {
        escolhida = token;
      }
      token.Release();
    }
    if (escolhida != nullptr) voz_->SetVoice(escolhida);
  }
  const ULONGLONG interesse = SPFEI(SPEI_END_INPUT_STREAM);
  voz_->SetInterest(interesse, interesse);
  voz_->SetNotifyWindowMessage(janela_, kMensagem, 0, 0);
  return true;
}

void Fala::Falar(const std::string& texto) {
  const std::wstring w = ParaUtf16(texto);
  ULONG numero = 0;
  if (SUCCEEDED(voz_->Speak(w.c_str(),
                            SPF_ASYNC | SPF_PURGEBEFORESPEAK | SPF_IS_NOT_XML,
                            &numero))) {
    atual_ = numero;
  }
}

void Fala::Parar() {
  atual_ = 0;
  if (voz_ != nullptr) voz_->Speak(nullptr, SPF_ASYNC | SPF_PURGEBEFORESPEAK, nullptr);
}

void Fala::AoEvento() {
  if (voz_ == nullptr) return;
  CSpEvent evento;
  while (evento.GetFrom(voz_) == S_OK) {
    if (evento.eEventId == SPEI_END_INPUT_STREAM && atual_ != 0 &&
        evento.ulStreamNum == atual_) {
      atual_ = 0;
      if (canal_) canal_->InvokeMethod("fim", nullptr);
    }
  }
}
