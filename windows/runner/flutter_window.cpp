#include "flutter_window.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>
#include <windowsx.h>

#include <cmath>
#include <optional>

#include "flutter/generated_plugin_registrant.h"

// Moldura própria (sem a barra de título do Windows): o céu do app vai até o
// topo e o Flutter desenha o fio de aurora e os botões (lib/ui/janela/). Aqui
// o Windows fica sabendo onde está cada parte da faixa de cima, para que
// arrastar, duplo clique, menu da janela, Win+setas e os snap layouts (passar
// o mouse no maximizar) continuem nativos. As medidas são as mesmas do Dart.
namespace {

constexpr int kAlturaBarra = 32;  // px lógicos
constexpr int kLarguraBotao = 46;

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif
#ifndef DWMWA_BORDER_COLOR
#define DWMWA_BORDER_COLOR 34
#endif

FlutterWindow* g_janela = nullptr;
WNDPROC g_proc_filho = nullptr;

// Espessura da borda de redimensionar (e do pedaço que sobra para fora da tela
// quando a janela está maximizada).
int Borda(HWND hwnd) {
  const UINT dpi = GetDpiForWindow(hwnd);
  return GetSystemMetricsForDpi(SM_CYFRAME, dpi) +
         GetSystemMetricsForDpi(SM_CXPADDEDBORDER, dpi);
}

// A janela do Flutter cobre toda a área do app: nas partes da moldura ela fica
// "transparente" para o teste do mouse e a pergunta chega à janela de cima.
LRESULT CALLBACK ProcFilho(HWND hwnd, UINT message, WPARAM wparam,
                           LPARAM lparam) {
  if (message == WM_NCHITTEST && g_janela != nullptr) {
    POINT ponto{GET_X_LPARAM(lparam), GET_Y_LPARAM(lparam)};
    if (g_janela->RegiaoDaMoldura(ponto) != HTCLIENT) {
      return HTTRANSPARENT;
    }
  }
  return CallWindowProc(g_proc_filho, hwnd, message, wparam, lparam);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  ConfigurarCanal();
  fala_ = std::make_unique<Fala>(flutter_controller_->engine()->messenger(),
                                 GetHandle());

  HWND filho = flutter_controller_->view()->GetNativeWindow();
  SetChildContent(filho);
  g_janela = this;
  g_proc_filho = reinterpret_cast<WNDPROC>(SetWindowLongPtr(
      filho, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(ProcFilho)));

  // Recalcula a moldura já sem a barra de título.
  AplicarTema();
  SetWindowPos(GetHandle(), nullptr, 0, 0, 0, 0,
               SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
                   SWP_NOACTIVATE);

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  g_janela = nullptr;
  fala_ = nullptr;
  canal_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::ConfigurarCanal() {
  canal_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "aurora/janela",
      &flutter::StandardMethodCodec::GetInstance());
  canal_->SetMethodCallHandler([this](const auto& chamada, auto resultado) {
    HWND hwnd = GetHandle();
    const std::string& metodo = chamada.method_name();
    if (metodo == "minimizar") {
      ShowWindow(hwnd, SW_MINIMIZE);
    } else if (metodo == "alternarMaximizar") {
      ShowWindow(hwnd, IsZoomed(hwnd) ? SW_RESTORE : SW_MAXIMIZE);
    } else if (metodo == "fechar") {
      PostMessage(hwnd, WM_CLOSE, 0, 0);
    } else if (metodo == "tema") {
      if (const auto* escuro = std::get_if<bool>(chamada.arguments())) {
        tema_escuro_ = *escuro;
        AplicarTema();
      }
    } else if (metodo == "estado") {
      flutter::EncodableMap estado{
          {flutter::EncodableValue("maximizada"),
           flutter::EncodableValue(IsZoomed(hwnd) != 0)},
          {flutter::EncodableValue("ativa"),
           flutter::EncodableValue(GetForegroundWindow() == hwnd)},
      };
      resultado->Success(flutter::EncodableValue(estado));
      return;
    } else {
      resultado->NotImplemented();
      return;
    }
    resultado->Success();
  });
}

void FlutterWindow::Avisar(const char* metodo, flutter::EncodableValue valor) {
  if (canal_) {
    canal_->InvokeMethod(metodo,
                         std::make_unique<flutter::EncodableValue>(valor));
  }
}

void FlutterWindow::MudarEstadoMax(int estado) {
  if (estado == estado_max_) return;
  estado_max_ = estado;
  Avisar("botaoMax", flutter::EncodableValue(estado));
}

// Borda fina na cor das linhas do app, em vez da cor do sistema (Windows 11).
void FlutterWindow::AplicarTema() {
  HWND hwnd = GetHandle();
  if (hwnd == nullptr) return;
  BOOL escuro = tema_escuro_ ? TRUE : FALSE;
  DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &escuro,
                        sizeof(escuro));
  COLORREF borda = tema_escuro_ ? RGB(0x23, 0x22, 0x50) : RGB(0xD6, 0xD4, 0xEA);
  DwmSetWindowAttribute(hwnd, DWMWA_BORDER_COLOR, &borda, sizeof(borda));
}

LRESULT FlutterWindow::RegiaoDaMoldura(POINT ponto) const {
  HWND hwnd = const_cast<FlutterWindow*>(this)->GetHandle();
  if (hwnd == nullptr) return HTCLIENT;
  ScreenToClient(hwnd, &ponto);
  RECT area;
  GetClientRect(hwnd, &area);
  const double escala = GetDpiForWindow(hwnd) / 96.0;
  const int altura = static_cast<int>(std::lround(kAlturaBarra * escala));
  const int botao = static_cast<int>(std::lround(kLarguraBotao * escala));
  if (ponto.y < 0 || ponto.y >= altura) return HTCLIENT;

  // A borda de cima continua servindo para redimensionar.
  const bool maximizada = IsZoomed(hwnd) != 0;
  const int borda = Borda(hwnd);
  if (!maximizada && ponto.y < borda) {
    if (ponto.x < borda * 2) return HTTOPLEFT;
    if (ponto.x >= area.right - borda * 2) return HTTOPRIGHT;
    return HTTOP;
  }

  const int daDireita = area.right - ponto.x;
  if (daDireita <= botao) return HTCLIENT;  // fechar
  if (daDireita <= botao * 2) return HTMAXBUTTON;
  if (daDireita <= botao * 3) return HTCLIENT;  // minimizar
  return HTCAPTION;
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;

    case Fala::kMensagem:
      if (fala_) fala_->AoEvento();
      return 0;

    // Sem barra de título: a área do app começa no topo da janela. As bordas
    // dos lados e de baixo ficam com o sistema.
    case WM_NCCALCSIZE:
      if (wparam) {
        auto* p = reinterpret_cast<NCCALCSIZE_PARAMS*>(lparam);
        const LONG topo = p->rgrc[0].top;
        const LRESULT r = DefWindowProc(hwnd, message, wparam, lparam);
        if (r != 0) return r;
        p->rgrc[0].top = topo;
        // Maximizada, a janela passa um pouco da tela em cada lado.
        if (IsZoomed(hwnd)) p->rgrc[0].top += Borda(hwnd);
        return 0;
      }
      break;

    // Não redesenha a barra antiga ao ganhar ou perder o foco.
    case WM_NCACTIVATE:
      Avisar("ativa", flutter::EncodableValue(wparam != FALSE));
      return DefWindowProc(hwnd, message, wparam, -1);

    case WM_NCHITTEST: {
      const LRESULT padrao = DefWindowProc(hwnd, message, wparam, lparam);
      if (padrao != HTCLIENT) return padrao;
      POINT ponto{GET_X_LPARAM(lparam), GET_Y_LPARAM(lparam)};
      return RegiaoDaMoldura(ponto);
    }

    // O maximizar é do Windows (é o que abre os snap layouts); o Flutter só
    // desenha o botão conforme o estado que vai daqui.
    case WM_NCMOUSEMOVE:
      if (wparam == HTMAXBUTTON) {
        MudarEstadoMax(estado_max_ == 2 ? 2 : 1);
        TRACKMOUSEEVENT rastro{sizeof(rastro), TME_LEAVE | TME_NONCLIENT, hwnd,
                               0};
        TrackMouseEvent(&rastro);
      } else {
        MudarEstadoMax(0);
      }
      break;
    case WM_NCMOUSELEAVE:
      MudarEstadoMax(0);
      break;
    case WM_NCLBUTTONDOWN:
    case WM_NCLBUTTONDBLCLK:
      if (wparam == HTMAXBUTTON) {
        MudarEstadoMax(2);
        return 0;
      }
      break;
    case WM_NCLBUTTONUP:
      if (wparam == HTMAXBUTTON) {
        if (estado_max_ == 2) {
          ShowWindow(hwnd, IsZoomed(hwnd) ? SW_RESTORE : SW_MAXIMIZE);
        }
        MudarEstadoMax(1);
        return 0;
      }
      break;

    case WM_SIZE:
      Avisar("maximizada", flutter::EncodableValue(IsZoomed(hwnd) != 0));
      break;

    case WM_DWMCOLORIZATIONCOLORCHANGED: {
      // O Win32Window volta ao tema do sistema; a janela segue o do app.
      const LRESULT r =
          Win32Window::MessageHandler(hwnd, message, wparam, lparam);
      AplicarTema();
      return r;
    }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
