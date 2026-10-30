#ifndef RUNNER_BANDEJA_H_
#define RUNNER_BANDEJA_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>
#include <shellapi.h>

#include <memory>
#include <string>

// Gerenciamento do ícone na bandeja do sistema (Notification Area / Tray).
// Permite que o Aurora continue rodando em segundo plano quando a janela é
// fechada, exibindo seus lembretes e alertas pontualmente.
class Bandeja {
 public:
  static constexpr UINT kMensagemBandeja = WM_APP + 30;

  Bandeja(flutter::BinaryMessenger* mensageiro, HWND janela);
  ~Bandeja();

  // Cria ou recria o ícone na bandeja do sistema.
  bool Criar();

  // Remove o ícone da bandeja do sistema.
  void Destruir();

  // Processa cliques e eventos do mouse no ícone da bandeja.
  void AoEvento(WPARAM wparam, LPARAM lparam);

  // Mostra e foca a janela principal.
  void RestaurarJanela();

  // Oculta a janela e mantém ativa na bandeja.
  void OcultarJanela();

  // Mostra um aviso informativo na bandeja (balloon tip).
  void MostrarAviso(const std::wstring& titulo, const std::wstring& texto);

  // Se true, fechar a janela (X ou Alt+F4) apenas a oculta na bandeja.
  void DefinirFecharParaBandeja(bool ativo) { fechar_para_bandeja_ = ativo; }
  bool FecharParaBandeja() const { return fechar_para_bandeja_; }

 private:
  void MostrarMenuContexto();

  HWND janela_ = nullptr;
  NOTIFYICONDATAW nid_{};
  bool criada_ = false;
  bool fechar_para_bandeja_ = true;
  bool aviso_mostrado_ = false;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> canal_;
};

#endif  // RUNNER_BANDEJA_H_
