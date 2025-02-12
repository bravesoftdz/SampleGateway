unit uIndyTCPClientThreaded;

interface

uses
  Winapi.Windows, Classes, System.SyncObjs, IdTCPClient, Vcl.Forms,
  SysUtils, IdGlobal, uFunction, uPacket;

const
  TCPHOST_IP = '127.0.0.1';
//  TCPHOST_IP = '192.168.0.240';
  TCPHOST_PORT = 13101;
  TCPHOST_PORT_SYNC = 13102;

type
  TWriteThread = class(TThread)
  private
    FData: TStringList;
    FIdClient: TIdTCPClient;
    FCnt: Integer;
    FCS: TCriticalSection;
    procedure SetData(const Value: TStringList);
    procedure SetIdClient(const Value: TIdTCPClient);
    procedure SetCnt(const Value: Integer);
    procedure SetCS(const Value: TCriticalSection);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property Data : TStringList read FData write SetData;
    property IdClient : TIdTCPClient read FIdClient write SetIdClient;
    property Cnt : Integer read FCnt write SetCnt;
    property CS : TCriticalSection read FCS write SetCS;
  end;

type
  TReadThread = class(TThread)
  private
    FData: TStringList;
    FIdClient : TIdTCPClient;
    FCS: TCriticalSection;
    procedure SetData(const Value: TStringList);
    procedure SetIndy(const Value: TIdTCPClient);
    procedure SetCS(const Value: TCriticalSection);
  protected

    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property Data : TStringList read FData write SetData;
    property IdClient : TIdTCPClient read FIdClient write SetIndy;
    property CS : TCriticalSection read FCS write SetCS;
  end;

type
  TLogThread = class(TThread)
  private
    FData: TStringList;
//    FListBox: TListBox;
//    FDisplayList: TStringList;
    FCS: TCriticalSection;
//    procedure SetListBox(const Value: TListBox);
//    procedure SetDisplayList(const Value: TStringList);
    procedure SetData(const Value: TStringList);
    procedure SetCS(const Value: TCriticalSection);
  protected

    procedure DisplayMsg;
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

//    property ListBox : TListBox read FListBox write SetListBox;
//    property DisplayList : TStringList read FDisplayList write SetDisplayList;
    property Data : TStringList read FData write SetData;
    property CS : TCriticalSection read FCS write SetCS;
  end;

type
  TMWTCPClient = class(TObject)
    MWIdTCPClient: TIdTCPClient;
//    ListBox: TListBox;
    private
      { Private declarations }
    public
      slData : TStringList;
//      displayList: TStringList;
      iCnt : Integer;
      cs : TCriticalSection;
      readThread : TReadThread;
      writeThread : TWriteThread;
      logThread : TLogThread;
      constructor Create;
      destructor Destroy; override;
      procedure Start;
      procedure Stop;
      { Public declarations }
  end;

var
  MWTCPClient: TMWTCPClient;
  PacketHeader: TReqPacketHeader;
  BodyLength: Integer;

implementation

{ TWriteThread }

constructor TWriteThread.Create;
begin
  FreeOnTerminate := False;
  Cnt := 0;
  inherited Create( true );
end;

destructor TWriteThread.Destroy;
begin
  inherited;
end;

procedure TWriteThread.Execute;
const
  // Route
  Header: array[0..78] of Integer = (122, 123, 53, 102, 51, 51, 48, 55, 100, 98, 45, 97, 101, 56, 50, 45, 53, 54, 50, 57, 45, 102, 100, 100, 49, 45, 97, 52, 55, 56, 52, 99, 49, 102, 102, 51, 99, 55, 1, 41, 70, 15, 0, 54, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  Body: array[0..51] of Integer = (102, 14, 13, 91, 77, 43, 63, 63, 34, 2, 63, 15, 100, 68, 63, 63, 0, 63, 63, 109, 72, 63, 52, 63, 63, 63, 63, 63, 63, 32, 68, 64, 50, 48, 49, 57, 48, 53, 48, 50, 49, 48, 50, 48, 49, 57, 48, 53, 48, 56, 49, 50);
var
  cmd : String;
  i: Integer;
  ReqByte: TIdBytes;
begin
  if not IdClient.Connected Then  exit;

//  SetLength(ReqByte, Length(Header)+Length(Body));
//  for i := Low(Header) to High(Header) do
//  begin
//    ReqByte[i] := Header[i];
//  end;
//
//  for i := Length(Header) to Length(Header)+Length(Body)-1 do
//  begin
//    ReqByte[i] := Body[i-Length(Header)];
//  end;


  while not Terminated do
  begin

    IdClient.IOHandler.CheckForDisconnect(True, True);

//    inc( FCnt );
//
//    IdClient.IOHandler.Write(Inttostr( Cnt )+#02#$d#$a );
//
//    CS.Enter;
//    try
//      Data.Add( 'Write = ' + IntToStr( FCnt ) );
//    finally
//      CS.Leave;
//    end;

    // 여기서부터
    if Data.Count > 0 then
    begin
//      CS.Enter;
//      try
  //      IdClient.IOHandler.Write(Data[0]+#$d#$a);
  //      IdClient.IOHandler.Write(IndyTextEncoding_ASCII.GetString(ReqByte)+#$d#$a);
  //      Data.BeginUpdate;
  //      Data.Delete(0);
  //      Data.EndUpdate;

        for i := 0 to Data.Count-1 do
        begin
          Display('WRITETHREAD', Data[i]);
          IdClient.IOHandler.Write(Data[i]+#$d#$a);
        end;
        Data.Clear;
//      finally
//        CS.Leave;
//      end;
    end;

    Application.ProcessMessages;
    WaitForSingleObject( Handle, 10 );
  end;

end;

procedure TWriteThread.SetCnt(const Value: Integer);
begin
  FCnt := Value;
end;

procedure TWriteThread.SetIdClient(const Value: TIdTCPClient);
begin
  FIdClient := Value;
end;


procedure TWriteThread.SetData(const Value: TStringList);
begin
  FData := Value;
end;

procedure TWriteThread.SetCS(const Value: TCriticalSection);
begin
  FCS := Value;
end;

{ TReadThread }

constructor TReadThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create( True );
end;

destructor TReadThread.Destroy;
begin
  inherited;
end;

procedure TReadThread.Execute;
var
  t : Cardinal;
  byteMsgFromServer: TIdBytes;
  byteBodyFromServer: TIdBytes;
  procedure AddData( aStr : String );
  begin
    CS.Enter;
    try
      Data.Add( aStr );
    finally
      CS.Leave;
    end;
  end;
begin
  while not Terminated do
  try
    t := GetTickCount;

    repeat
      IdClient.IOHandler.CheckForDisconnect(True, True);
      IdClient.IOHandler.CheckForDataOnSource( 100 );
      if GetTickCount - t > 3000 then
      begin
        AddData( '>>>>>>>>>>>>>>>>>>> Read Time Out <<<<<<<<<<<<<<<<<<<<' );
        Break;
      end;

      WaitForSingleObject( Handle, 10 );
      Application.ProcessMessages;

    until IdClient.IOHandler.InputBuffer.Size > 0;

    if GetTickCount - t > 1000 then
      Continue;


//    CS.Enter;
//    try
//      Data.Add( 'Read = ' + IdClient.IOHandler.ReadLn );
//    finally
//      CS.Leave;
//    end;


    // ... read message from server
  //  msgFromServer := MWIdTCPClient.IOHandler.ReadLn();

    if BodyLength > 0 then
      IdClient.IOHandler.ReadBytes(byteMsgFromServer, BodyLength)
    else
      IdClient.IOHandler.ReadBytes(byteMsgFromServer, SizeOf(TReqPacketHeader));

    // ... messages log
    Display('TCP_CLIENT - FROM SERVER', IndyTextEncoding_ASCII.GetString(byteMsgFromServer));

    if (byteMsgFromServer[0] = PACKET_DELIMITER_1) and (byteMsgFromServer[1] = PACKET_DELIMITER_2) then
    begin
      SetPacketHeader(byteMsgFromServer, PacketHeader);
  //    FillChar(byteBodyFromServer, PacketHeader.BodySize, #0);
      case PacketHeader.MsgType of
        PACKET_TYPE_REQ: ;
        PACKET_TYPE_NOTI: ;
        PACKET_TYPE_RES:
          begin
            BodyLength := PacketHeader.BodySize;
          end;
      end;
    end
    else
    begin
      case PacketHeader.MsgType of
        PACKET_TYPE_REQ: ;
        PACKET_TYPE_NOTI: ;
        PACKET_TYPE_RES:
          begin
  //          len := Length(byteBodyFromServer);
            SetLength(byteBodyFromServer, BodyLength);
            Move(byteMsgFromServer[0], byteBodyFromServer[0], Length(byteMsgFromServer));
            Display('BODY', IndyTextEncoding_ASCII.GetString(byteBodyFromServer));
            Display('LENGTH', IntToStr(Length(byteBodyFromServer)));
            BodyLength := 0;
            // New ECDIS 로 전달할 내용
            Data.BeginUpdate;
            Data.Add(IndyTextEncoding_ASCII.GetString(GetPacketHeaderBytes(PacketHeader)+byteBodyFromServer));
            Data.EndUpdate;
          end;
      end;
    end;

  finally
    WaitForSingleObject( Handle, 10 );
    Application.ProcessMessages;
  end;

end;

procedure TReadThread.SetIndy(const Value: TIdTCPClient);
begin
  FIdClient := Value;
end;


procedure TReadThread.SetData(const Value: TStringList);
begin
  FData := Value;
end;

procedure TReadThread.SetCS(const Value: TCriticalSection);
begin
  FCS := Value;
end;

{ TLogThread }

constructor TLogThread.Create;
begin
  inherited Create( True );
end;

destructor TLogThread.Destroy;
begin

  inherited;
end;

procedure TLogThread.DisplayMsg;
var
  i: Integer;
begin
//  With ListBox do
//  begin
//    Items.Add( 'Data Count = ' + IntToStr( Data.Count ) );
//    for i := 0 to Data.Count - 1 do
//    begin
//      Items.Add(  Data[i] );
//      ItemIndex := Count -1;
//    end;
//
//    Data.Clear;
//  end;

//  With DisplayList do
//  begin
    Display('TCP_CLIENT', 'Data Count = ' + IntToStr( Data.Count ));
    for i := 0 to Data.Count - 1 do
    begin
      Display('TCP_CLIENT', Data[i]);
    end;

    Data.Clear;
//  end;
end;

procedure TLogThread.Execute;
begin
  while not Terminated do
  begin
    CS.Enter;
    try
      Synchronize( DisplayMsg );
    finally
      CS.Leave;
    end;
    Application.ProcessMessages;
    WaitForSingleObject( Handle, 10 );
  end;

end;

//procedure TLogThread.SetListBox(const Value: TListBox);
//begin
//  FListBox := Value;
//end;

procedure TLogThread.SetData(const Value: TStringList);
begin
  FData := Value;
end;

procedure TLogThread.SetCS(const Value: TCriticalSection);
begin
  FCS := Value;
end;

{ TMWTCPClient }

constructor TMWTCPClient.Create;
begin
  inherited;

  MWIdTCPClient := TIdTCPClient.Create(nil);

  with MWIdTCPClient do
  begin
    Host := TCPHOST_IP;
    Port := TCPHOST_PORT_SYNC;
    ReuseSocket := rsOSDependent;
    UseNagle := True;
  end;

//  ListBox := TListBox.Create(nil);
//  ListBox.Parent := nil;

  cs := TCriticalSection.Create;
  readThread := TReadThread.Create;
  writeThread := TWriteThread.Create;
  logThread := TLogThread.Create;
  slData := TStringList.Create;
//  displayList := TStringList.Create;
end;

destructor TMWTCPClient.Destroy;
begin
  if readThread.Suspended then
    readThread.Resume;
  readThread.Terminate;

  if writeThread.Suspended then
    writeThread.Resume;
  writeThread.Terminate;

  if logThread.Suspended then
    logThread.Resume;
  logThread.Terminate;

  writeThread.WaitFor;
  readThread.WaitFor;
  logThread.WaitFor;

  readThread.Free;
  writeThread.Free;
  logThread.Free;
  cs.Free;
  slData.free;
//  displayList.free;

  inherited;
end;

procedure TMWTCPClient.Start;
begin
//  ListBox.Clear;
//  displayList.Clear;

  if not MWIdTCPClient.Connected then
    MWIdTCPClient.Connect;

  Display('TCP_CLIENT', 'CONNECTED TO SERVER!');

  readThread.CS       := cs;
  readThread.IdClient := MWIdTCPClient;
//  readThread.Data     := slData;
  readThread.Data     := slSendToClientMsgList;

  writeThread.CS       := cs;
  writeThread.IdClient := MWIdTCPClient;
//  writeThread.Data     := slData;
  writeThread.Data     := slSendToServerMsgList;

//  logThread.DisplayList := displayList;
  logThread.CS          := cs;
  logThread.Data        := slData;

  readThread.Resume;
  writeThread.Resume;
  logThread.Resume;
end;

procedure TMWTCPClient.Stop;
begin
  if not readThread.Suspended then
    readThread.Suspend;
  if not writeThread.Suspended then
    writeThread.Suspend;
  if not logThread.Suspended then
    logThread.Suspend;

//  MWIdTCPClient.Disconnect;
end;

end.
