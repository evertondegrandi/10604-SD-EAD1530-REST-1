unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
      const ATempoPreparo: Integer; const ACodigoCliente: Integer; const ADocumentoCliente: Integer);

    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO
    : String =
    'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, vl_pedido, nr_tempopedido, nr_tamanho, nr_sabor, nr_doc) VALUES (:pCodigoCliente, :pDataPedido, :pDataEntrega, :pValorPedido, :pTempoPedido, :ptamanho, :psabor, :pdoc)';

  { TPedidoRepository }

constructor TPedidoRepository.Create;
begin
  inherited;

  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer; const ADocumentoCliente : Integer);
var
 iTamanho, iSabor : Integer;
begin
  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  if APizzaTamanho = enPequena then
    iTamanho := 1
  else if APizzaTamanho = enMedia then
    iTamanho := 2
  else if APizzaTamanho = enGrande then
    iTamanho := 3;

  if APizzaSabor = enCalabresa then
    iSabor := 1
  else if APizzaSabor = enMarguerita then
    iSabor := 2
  else if APizzaSabor = enPortuguesa then
    iSabor := 3;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger := ATempoPreparo;
  FFDQuery.ParamByName('ptamanho').AsInteger := iTamanho;
  FFDQuery.ParamByName('psabor').AsInteger   := iSabor;
  FFDQuery.ParamByName('pdoc').AsInteger     := ADocumentoCliente;

  FFDQuery.Prepare;
  FFDQuery.ExecSQL(True);
end;

end.
