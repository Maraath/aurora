#ifndef RUNNER_FALA_H_
#define RUNNER_FALA_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>
#include <sapi.h>

#include <memory>

// Resposta falada no Windows (canal "aurora/fala"): SAPI com a voz pt-BR do
// sistema ("Microsoft Maria"). O fim da fala chega como mensagem na janela,
// então o aviso ao Dart sai na thread da plataforma (o flutter_tts avisava de
// outra thread e o aviso se perdia).
class Fala {
 public:
  // Mensagem que a SAPI manda à janela quando há evento.
  static constexpr UINT kMensagem = WM_APP + 20;

  Fala(flutter::BinaryMessenger* mensageiro, HWND janela);
  ~Fala();

  // Chamada pela janela ao receber |kMensagem|.
  void AoEvento();

 private:
  bool Preparar();
  void Falar(const std::string& texto);
  void Parar();

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> canal_;
  HWND janela_;
  ISpVoice* voz_ = nullptr;
  bool preparada_ = false;
  // Número da fala atual (o fim das falas canceladas não conta).
  ULONG atual_ = 0;
};

#endif  // RUNNER_FALA_H_
