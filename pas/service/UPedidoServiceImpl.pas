unit UPedidoServiceImpl;

interface

uses
  UPedidoServiceIntf, UPizzaTamanhoEnum, UPizzaSaborEnum,
  UPedidoRepositoryIntf, UPedidoRetornoDTOImpl, UClienteServiceIntf;

type
  TPedidoService = class(TInterfacedObject, IPedidoService)
  private
    FPedidoRepository: IPedidoRepository;
    FClienteService: IClienteService;

    function calcularValorPedido(const APizzaTamanho: TPizzaTamanhoEnum): Currency;
    function calcularTempoPreparo(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum): Integer;
  public
    function efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const ADocumentoCliente: String): TPedidoRetornoDTO;
    function consultaPedido(const ADocumentoCliente: String): String;
    constructor Create; reintroduce;
  end;

implementation

uses
  UPedidoRepositoryImpl, System.SysUtils, UClienteServiceImpl,
  UDBConnectionImpl, FireDAC.Comp.Client, UDBConnectionIntf;

{ TPedidoService }

function TPedidoService.calcularTempoPreparo(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum): Integer;
begin
  Result := 15;
  case APizzaTamanho of
    enPequena:
      Result := 15;
    enMedia:
      Result := 20;
    enGrande:
      Result := 25;
  end;

  if (APizzaSabor = enPortuguesa) then
    Result := Result + 5;
end;

function TPedidoService.calcularValorPedido(const APizzaTamanho: TPizzaTamanhoEnum): Currency;
begin
  Result := 20;
  case APizzaTamanho of
    enPequena:
      Result := 20;
    enMedia:
      Result := 30;
    enGrande:
      Result := 40;
  end;
end;

constructor TPedidoService.Create;
begin
  inherited;

  FPedidoRepository := TPedidoRepository.Create;
  FClienteService := TClienteService.Create;
end;

function TPedidoService.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const ADocumentoCliente: String)
  : TPedidoRetornoDTO;
var
  oValorPedido: Currency;
  oTempoPreparo: Integer;
  oCodigoCliente: Integer;
begin
  oValorPedido := calcularValorPedido(APizzaTamanho);
  oTempoPreparo := calcularTempoPreparo(APizzaTamanho, APizzaSabor);
  oCodigoCliente := FClienteService.adquirirCodigoCliente(ADocumentoCliente);

  FPedidoRepository.efetuarPedido(APizzaTamanho, APizzaSabor, oValorPedido, oTempoPreparo, oCodigoCliente, strtoint(ADocumentoCliente));
  Result := TPedidoRetornoDTO.Create(APizzaTamanho, APizzaSabor, oValorPedido, oTempoPreparo);
end;

function TPedidoService.consultaPedido(const ADocumentoCliente: String) : String;
var
  oValorPedido: Currency;
  oTempoPreparo: Integer;
  oCodigoCliente: Integer;
  FFDQuery: TFDQuery;
  FDBConnection: IDBConnection;
  sSabor, sTamanho : string;
begin
//  oValorPedido := calcularValorPedido(APizzaTamanho);
//  oTempoPreparo := calcularTempoPreparo(APizzaTamanho, APizzaSabor);
//  oCodigoCliente := FClienteService.adquirirCodigoCliente(ADocumentoCliente);

//  FPedidoRepository.consultaPedido(ADocumentoCliente);
  try
  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;

  FFDQuery.SQL.Text := 'select nr_doc, nr_tamanho,nr_sabor,vl_pedido,nr_tempopedido  from tb_pedido where nr_doc = :pDocumento order by id desc LIMIT 1';

  FFDQuery.ParamByName('pDocumento').AsString := ADocumentoCliente;

  FFDQuery.Prepare;
  FFDQuery.Open;
  if (not FFDQuery.IsEmpty) then
  begin
    if FFDQuery.FieldByName('nr_sabor').AsString = '1' then
      sSabor := 'enCalabresa'
    else if FFDQuery.FieldByName('nr_sabor').AsString = '2' then
      sSabor := 'enMarguerita'
    else if FFDQuery.FieldByName('nr_sabor').AsString = '3' then
      sSabor := 'enPortuguesa';

    if FFDQuery.FieldByName('nr_tamanho').AsString = '1' then
      sTamanho := 'enPequena'
    else if FFDQuery.FieldByName('nr_tamanho').AsString = '2' then
      sTamanho := 'enMedia'
    else if FFDQuery.FieldByName('nr_tamanho').AsString = '3' then
      sTamanho := 'enGrande';

    Result := 'Tamanho:'+ sTamanho;
    Result := Result+'  Sabor:'+ sSabor ;
    Result := Result+'  Valor:R$'+ FFDQuery.FieldByName('vl_pedido').AsString+',00' ;
    Result := Result+'  Tempo:'+ FFDQuery.FieldByName('nr_tempopedido').AsString+'min' ;
  end
  else
    raise Exception.Create('N�o existem pedidos para este n�mero de documento.');
  finally
    FFDQuery.Free;
  end;
end;


end.
