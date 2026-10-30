#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/encodable_value.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>

#include <memory>

#include "bandeja.h"
#include "fala.h"
#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  // Moldura própria: diz ao Windows o que há em |ponto| (tela) na faixa de
  // cima. HTCLIENT = é do Flutter.
  LRESULT RegiaoDaMoldura(POINT ponto) const;

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Canal "aurora/janela": botões, tema e estado da janela.
  void ConfigurarCanal();
  void Avisar(const char* metodo, flutter::EncodableValue valor);
  void MudarEstadoMax(int estado);
  void AplicarTema();

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> canal_;

  // Resposta falada (canal "aurora/fala").
  std::unique_ptr<Fala> fala_;

  // Ícone e comportamento da bandeja do sistema (canal "aurora/bandeja").
  std::unique_ptr<Bandeja> bandeja_;

  // Mensagem do Windows para quando a barra de tarefas é recriada.
  UINT msg_taskbar_created_ = 0;

  // Quando true, não intercepta WM_CLOSE para a bandeja e encerra o app.
  bool sair_definitivo_ = false;

  // Botão maximizar (desenhado pelo Flutter, tratado aqui): 0 normal,
  // 1 mouse em cima, 2 apertado.
  int estado_max_ = 0;
  bool tema_escuro_ = true;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
