unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses MVCFramework,
  MVCFramework.Logger,
  MVCFramework.Commons,
  Web.HTTPApp, UPizzaTamanhoEnum, UPizzaSaborEnum, UEfetuarPedidoDTOImpl;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCDoc('Consulta pedido "201: Created"')]
    [MVCPath('/consultaPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure consultaPedido(const AContext: TWebContext);
  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceIntf,
  UPedidoServiceImpl, UPedidoRetornoDTOImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
begin
  oEfetuarPedidoDTO := TJson.JsonToObject<TEfetuarPedidoDTO>(AContext.Request.Body);
  try
    with TPedidoService.Create do
    try
      oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho, oEfetuarPedidoDTO.PizzaSabor, oEfetuarPedidoDTO.DocumentoCliente);
      Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
    finally
      oPedidoRetornoDTO.Free
    end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o método ', 'efetuarPedido');
end;

procedure TPizzariaBackendController.consultaPedido(const AContext: TWebContext);
var
//  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
//  oPedidoRetornoDTO: TPedidoRetornoDTO;
  sParametro : string;
  sRetorno : String;
begin
  sParametro := AContext.Request.Body;
  try
    with TPedidoService.Create do
    try
      sRetorno := consultaPedido(sParametro);
      Render(sRetorno);
    finally
    end;
  finally
    //oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o método ', 'consultaPedido');
end;


end.
