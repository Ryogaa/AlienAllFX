unit AlienFX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, ExtCtrls, inifiles,
  Vcl.ColorGrd, ShellAPI, Vcl.Menus, JPEG, SHFolder, Math, GraphUtil, MMSystem, Bass,
  mbTrackBarPicker, HColorPicker, mbColorPickerControl, HRingPicker,
  HSLRingPicker, SLHColorPicker, Vcl.Samples.Spin, Vcl.Imaging.pngimage,
  Vcl.Grids, NvAPI;
type
  LFX_RESULT = longword ;

  LFX_COLOR = record
	  red : Byte;
	  green : Byte;
	  blue : Byte;
	  brightness : Byte;
  end;

  PLFX_COLOR = ^LFX_COLOR;

  LFX_LIGHTPOS = record
    device : Byte;
    devicename : string;
    light : Byte;
    lightname : string;
    position : byte;
    frequency : integer;
    couleur : LFX_COLOR;
  end;


  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label2: TLabel;
    pmRightClick: TPopupMenu;
    miQuitter: TMenuItem;
    miPause: TMenuItem;
    N2: TMenuItem;
    miHelp: TMenuItem;
    Timer2: TTimer;
    Label1: TLabel;
    TrackBar2: TTrackBar;
    Label4: TLabel;
    Label5: TLabel;
    rgSource: TRadioGroup;
    PanelScreen: TPanel;
    rgColors: TRadioGroup;
    Label6: TLabel;
    TrackBar1: TTrackBar;
    Label7: TLabel;
    PanelSound: TPanel;
    Label8: TLabel;
    Label3: TLabel;
    ProgressBar2: TProgressBar;
    ProgressBar3: TProgressBar;
    ProgressBar4: TProgressBar;
    ProgressBar5: TProgressBar;
    ProgressBar6: TProgressBar;
    ProgressBar7: TProgressBar;
    ProgressBar8: TProgressBar;
    ProgressBar9: TProgressBar;
    ProgressBar10: TProgressBar;
    rgLights: TRadioGroup;
    HColorPicker1: THColorPicker;
    TrackBar3: TTrackBar;
    Label29: TLabel;
    TrackBar4: TTrackBar;
    Button2: TButton;
    rgAction: TRadioGroup;
    TimerColor: TTimer;
    CheckBoxCycle: TCheckBox;
    PanelAssoc: TPanel;
    Label19: TLabel;
    Image3: TImage;
    StringGrid1: TStringGrid;
    Bt_load: TButton;
    Bt_save: TButton;
    SLHColorPicker1: TSLHColorPicker;
    Label20: TLabel;
    Label9: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miPauseClick(Sender: TObject);
    procedure miQuitterClick(Sender: TObject);
    procedure miHelpClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure rgLightsClick(Sender: TObject);
    procedure rgSourceClick(Sender: TObject);
    procedure Bt_loadClick(Sender: TObject);
    procedure Bt_saveClick(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TimerColorTimer(Sender: TObject);
    procedure CheckBoxCycleClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure SLHColorPicker1Change(Sender: TObject);

  private
    TrayIconData: TNotifyIconData;
    FenetreVisible, MenuVisible : boolean;
    { Déclarations privées }
  public
     procedure TrayMessage(var Msg: TMessage); message (wm_user + 555);
    { Déclarations publiques }
  end;

const

  WM_ICONTRAY = wm_user + 555;

  LFX_SUCCESS				 = 0;		// Success
  LFX_FAILURE				 = 1;		// Generic failure
  LFX_ERROR_NOINIT	 = 2;		// System not initialized yet
  LFX_ERROR_NODEVS	 = 3;		// No devices available
  LFX_ERROR_NOLIGHTS = 4;		// No lights available
  LFX_ERROR_BUFFSIZE = 5;

  LFX_DEVTYPE_UNKNOWN		= $00;
  LFX_DEVTYPE_NOTEBOOK	= $01;
  LFX_DEVTYPE_DESKTOP		= $02;
  LFX_DEVTYPE_SERVER		= $03;
  LFX_DEVTYPE_DISPLAY		= $04;
  LFX_DEVTYPE_MOUSE		  = $05;
  LFX_DEVTYPE_KEYBOARD	= $06;
  LFX_DEVTYPE_GAMEPAD		= $07;
  LFX_DEVTYPE_SPEAKER		= $08;
  LFX_DEVTYPE_OTHER		  = $FF;

  LFX_ACTION_MORPH	= $00000001 ;
  LFX_ACTION_PULSE	= $00000002 ;
  LFX_ACTION_COLOR	= $00000003 ;

  SPECHEIGHT	= 255;	// height (changing requires palette adjustments too)
  BANDS		= 9;

var
  Form1: TForm1;
  resultat    : LFX_RESULT;

  AlienComp : array [0..32] of LFX_LIGHTPOS;
  AlienCompIndex : Byte;

  Channel	: HRECORD;	// recording channel
  SpecBuf	: Pointer;
  SpecMode	: Integer = 0;
  SpecPos	: Integer = 0; // spectrum mode (and marker pos for 2nd mode)
  quietcount	: DWORD = 0;

  BI		: PBITMAPINFO;
  pal		: array[Byte] of TRGBQUAD;

{$DEFINE ScaleSqrt}

  function ScreenShoot(activeWindow: bool; destBitmap : TBitmap) : boolean;
  procedure FXGRAPH_GPUTemp ();
  procedure FXGRAPH_Screen ();
  procedure FXSOUND_DistribLights ( X, Y : integer );
  procedure FXSOUND_AllKeyboard ( X, Y : integer);
  procedure FXSOUND_Test ( X, Y : integer );

  procedure SauveINI (filename : string);
  procedure ChargeINI (filename : string);
  procedure equaliseur ;
  procedure GetAlienInfo;

  //function NvCplGetThermalSettings( devIndex : word; pdwCoreTemp : pword; pdwAmbientTemp : pword; pdwUpperLimit : pword) : Boolean;  stdcall; external 'nvcpl.dll';

  function LFX_SetLightColor(devIndex : longword; lightIndex : longword; plightCol : PLFX_COLOR ) : LFX_RESULT;  stdcall; external 'LightFX.dll';
  function LFX_Initialize() : LFX_RESULT;  stdcall; external 'LightFX.dll';
  function LFX_Update() : LFX_RESULT;  stdcall; external 'LightFX.dll';
  function LFX_Release() : LFX_RESULT;  stdcall; external 'LightFX.dll';

  function LFX_GetNumDevices( numDevices : plongword ) : LFX_RESULT;  stdcall; external 'LightFX.dll';
  function LFX_GetDeviceDescription(devIndex : longword; Description : pAnsiChar; descsize : longword; devType : pchar) : LFX_RESULT;  stdcall; external 'LightFX.dll';

  function LFX_GetNumLights( devIndex : longword; numLights : plongword) : LFX_RESULT;  stdcall; external 'LightFX.dll';
  function LFX_GetLightDescription (devIndex : longword; lightIndex : longword; Description : pAnsiChar; lightDescSize : longword) : LFX_RESULT;  stdcall; external 'LightFX.dll';

  function LFX_SetLightActionColor(devIndex : longword; lightIndex : longword; lightAction : longword; plightColStart : PLFX_COLOR) : LFX_RESULT;  stdcall; external 'LightFX.dll';

  function LFX_SetTiming(TimeLapse : longword) : LFX_RESULT;  stdcall; external 'LightFX.dll';

implementation

{$R *.dfm}

uses About;

function GetGpuTemp: cardinal;
type
  NvCplGetThermalSettings = function (WindowsMonitorNumber: UINT; pGpuTemp, pUmgebTemp, pSlowDownTemp: Pointer): BOOL; stdcall ;
var
  hInstNvcpl: THandle;
  GetThermalSettings: NvCplGetThermalSettings;
  UmgebTemp, SlowDownTemp: cardinal;
begin
  Result := 0; //GPU-Temperatur
  UmgebTemp := 0; //Umgebungstemperatur
  SlowDownTemp := 0; //Slowdown-Grenzwert

  hInstNvcpl := LoadLibrary(' nvcpl.dll ');
  if hInstNvcpl <> 0 then
    try
    GetThermalSettings:= GetProcAddress(hInstNvcpl, ' NvCplGetThermalSettings ');
    if Assigned(GetThermalSettings) then
    GetThermalSettings(1, Addr(Result), Addr(UmgebTemp), Addr(SlowDownTemp));
    finally
    FreeLibrary(hInstNvcpl);
    end ;
end ;

procedure FXSOUND_Test ( X, Y : integer );
var
  pLightCol : PLFX_COLOR ;
  ColorPk : LongInt;
begin
  case X of
  2 :
    begin
    end;
  4 :
    begin
    end;
  6 :
    begin
    end;
  8 :
    begin
    end;
  end;
end;
procedure FXSOUND_DistribLights ( X, Y : integer );
var
  i : integer;
begin
  for i := 0 to AlienCompIndex-1 do
  begin
    if X = Aliencomp[i].position then
    begin
      Aliencomp[i].couleur.brightness := Y;
      resultat := LFX_SetLightColor(AlienComp[i].device, AlienComp[i].light, @AlienComp[i].couleur);
    end;
  end;
end;
procedure FXSOUND_AllKeyboard ( X, Y : integer );
var
  i : integer;
begin
  if X = form1.TrackBar3.Position then
  begin
    for i := 0 to AlienCompIndex-1 do
    begin
      Aliencomp[i].couleur.brightness := Y;
      Aliencomp[i].couleur.red   := GetRValue(ColorToRGB(Form1.Hcolorpicker1.SelectedColor));
      Aliencomp[i].couleur.green := GetGValue(ColorToRGB(Form1.Hcolorpicker1.SelectedColor));
      Aliencomp[i].couleur.blue  := GetBValue(ColorToRGB(Form1.Hcolorpicker1.SelectedColor));
      resultat := LFX_SetLightColor(AlienComp[i].device, AlienComp[i].light, @AlienComp[i].couleur);
    end;
  end;
end;
procedure FXSOUND_equaliseur ( X, Y : integer );
begin
  if X = form1.TrackBar3.Position then
  begin
    if Y > 16 then Aliencomp[3].couleur.brightness := $FF else Aliencomp[3].couleur.brightness := $00;
    resultat := LFX_SetLightColor(AlienComp[3].device, AlienComp[3].light, @AlienComp[3].couleur);
    if Y > 64 then Aliencomp[2].couleur.brightness := $FF else Aliencomp[2].couleur.brightness := $00;
    resultat := LFX_SetLightColor(AlienComp[2].device, AlienComp[2].light, @AlienComp[2].couleur);
    if Y > 128 then Aliencomp[1].couleur.brightness := $FF else Aliencomp[1].couleur.brightness := $00;
    resultat := LFX_SetLightColor(AlienComp[1].device, AlienComp[1].light, @AlienComp[1].couleur);
    if Y > 192 then Aliencomp[0].couleur.brightness := $FF else Aliencomp[0].couleur.brightness := $00;
    resultat := LFX_SetLightColor(AlienComp[0].device, AlienComp[0].light, @AlienComp[0].couleur);
  end;
end;

function Format(const Format : String; const Args : array of const ) : String;
var
  I		: Integer;
  FormatBuffer	: array[0..High(Word)] of Char;
  Arr, Arr1	: PDWORD;
  PP		: PDWORD;
begin
  Arr := NIL;
  if High(Args) >= 0 then
    GetMem(Arr, (High(Args) + 1) * SizeOf(Pointer));
  Arr1 := Arr;
  for I := 0 to High(Args) do
  begin
    PP := @Args[I];
    PP := Pointer(PP^);
    Arr1^ := DWORD(PP);
    inc(Arr1);
  end;
  I := wvsprintf(@FormatBuffer[0], PChar(Format), PChar(Arr));
  SetLength(Result, I);
  Result := FormatBuffer;
  if Arr <> NIL then
    FreeMem(Arr);
end;
function IntPower(const Base : Extended; const Exponent : Integer) : Extended;
asm
        mov     ecx, eax
        cdq
        fld1                      { Result := 1 }
        xor     eax, edx
        sub     eax, edx          { eax := Abs(Exponent) }
        jz      @@3
        fld     Base
        jmp     @@2
@@1:    fmul    ST, ST            { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
        fstp    st                { pop X from FPU stack }
        cmp     ecx, 0
        jge     @@3
        fld1
        fdivrp                    { Result := 1 / Result }
@@3:
        fwait
end;
function Power(const Base, Exponent : Extended) : Extended;
begin
  if Exponent = 0.0 then
    Result := 1.0               { n**0 = 1 }
  else if (Base = 0.0) and (Exponent > 0.0) then
    Result := 0.0               { 0**n = 0, n > 0 }
  else if (Frac(Exponent) = 0.0) and (Abs(Exponent) <= MaxInt) then
    Result := IntPower(Base, Integer(Trunc(Exponent)))
  else
    Result := Exp(Exponent * Ln(Base))
end;
function Log10(const X : Extended) : Extended;
asm
	FLDLG2     { Log base ten of 2 }
	FLD	X
	FYL2X
	FWAIT
end;
procedure Error(const es : String);
begin
  MessageBox(null, PChar(Format('%s' + #13#10 + '(error code: %d)', [es, BASS_ErrorGetCode])), 'Error', MB_OK or MB_ICONERROR);
end;
procedure UpdateSpectrum; stdcall;
type
  TSpecBuf   = array[0..0] of Byte;
  TBuf       = array of SmallInt;
var
  X, Y,
  B0, B1,
  SC         : Integer;
  Sum        : Single;
  fft        : array[0..1023] of Single;
  SBuf       : ^TSpecBuf absolute SpecBuf;
begin

  BASS_ChannelGetData(Channel, @fft, BASS_DATA_FFT2048); // get the FFT data
	B0 := 0;
  for X := 0 to BANDS - 1 do
  begin
    Sum := 0;
    B1 := Trunc(Power(2, X * 10.0 / (BANDS - 1)));
    if B1 > 1023 then
      B1 := 1023;
    if B1 <= B0 then
      B1 := B0 + 1; // make sure it uses at least 1 FFT bin
    SC := 10 + B1 - B0;

    while B0 < B1 do
    begin
      Sum := Sum + fft[1 + B0];
      inc(B0);
    end;

    Y := Trunc((sqrt(Sum / log10(SC)) * 1.7 * SPECHEIGHT) - 4); // scale it
    if Y > SPECHEIGHT then
      Y := SPECHEIGHT; // cap it

    if Y < 0 then Y := 0;

    case X of
      0 : form1.ProgressBar2.Position := Y;
      1 : form1.ProgressBar3.Position := Y;
      2 : form1.ProgressBar4.Position := Y;
      3 : form1.ProgressBar5.Position := Y;
      4 : form1.ProgressBar6.Position := Y;
      5 : form1.ProgressBar7.Position := Y;
      6 : form1.ProgressBar8.Position := Y;
      7 : form1.ProgressBar9.Position := Y;
      8 : form1.ProgressBar10.Position := Y;
    end;

    case form1.rgLights.ItemIndex of
      0 : begin
        FXSOUND_DistribLights ( X, Y );
      end;
      1 : begin
        FXSOUND_AllKeyboard ( X, Y );
      end;
      2 : begin
        FXSOUND_equaliseur ( X, Y );
      end;
      3 : begin
        FXSOUND_test ( X, Y );
      end;
    end;
 	end;

  resultat := LFX_Update();
end;
function DuffRecording(handle : HRECORD; const Buffer : Pointer; Length : DWORD; user : Pointer) : Boolean; stdcall;
begin
  Result := True;	// continue recording
end;

procedure GetAlienInfo;
var
  numDevices  : longword;
  DevDescription : AnsiString;
  LightDescription : AnsiString;
  pDescription : pAnsiChar;
  devType     : longword;
  devname : string;
  i : integer;
  devIndex : longword;
  numLights : longword;
  lightIndex : longword;
begin
  AlienCompIndex := 0;
  numDevices := 0;
  if LFX_GetNumDevices(@numDevices) = LFX_SUCCESS then
  begin  // For every devices found on system
    for devIndex := 0 to numDevices-1 do
    begin
      // Get Device Description and Type
      devType := 0;
      DevDescription := 'No Description                   ';
      pDescription := Addr(DevDescription[1]);
      if LFX_GetDeviceDescription(devIndex, pDescription, 255, @devType) = LFX_SUCCESS then
      begin
        case devType of
          LFX_DEVTYPE_UNKNOWN  : devname := 'UNKNOWN';
          LFX_DEVTYPE_NOTEBOOK : devname := 'NOTEBOOK';
          LFX_DEVTYPE_DESKTOP  : devname := 'DESKTOP';
          LFX_DEVTYPE_SERVER   : devname := 'SERVER';
          LFX_DEVTYPE_DISPLAY  : devname := 'DISPLAY';
          LFX_DEVTYPE_MOUSE    : devname := 'MOUSE';
          LFX_DEVTYPE_KEYBOARD : devname := 'KEYBOARD';
          LFX_DEVTYPE_GAMEPAD  : devname := 'GAMEPAD';
          LFX_DEVTYPE_SPEAKER  : devname := 'SPEAKER';
          LFX_DEVTYPE_OTHER    : devname := 'OTHER';
        end;
      end;

      // Get total number of lights
      if LFX_GetNumLights(devIndex, @numLights) = LFX_SUCCESS then
      begin
        // For every light of the device
        for lightIndex := 0 to numLights do
        begin
          // Get light description
          LightDescription := '                                                ';
          pDescription := Addr(LightDescription[1]);
          if LFX_GetLightDescription(devIndex, lightIndex, pDescription, 255) = LFX_SUCCESS then
          begin
            // Update AlienComp array to keep everything in memory
            AlienComp[AlienCompIndex].device := devIndex;
            AlienComp[AlienCompIndex].devicename := DevDescription;
            AlienComp[AlienCompIndex].light := lightIndex;
            AlienComp[AlienCompIndex].lightname := LightDescription;
            AlienComp[AlienCompIndex].position := AlienCompIndex+1;
            AlienComp[AlienCompIndex].frequency := AlienCompIndex+1;
            AlienComp[AlienCompIndex].Couleur.red := $00;
            AlienComp[AlienCompIndex].Couleur.green := $00;
            AlienComp[AlienCompIndex].Couleur.blue := $FF;
            AlienComp[AlienCompIndex].Couleur.brightness := $FF;

            resultat := LFX_SetLightColor(AlienComp[AlienCompIndex].device, AlienComp[AlienCompIndex].light, @AlienComp[AlienCompIndex].couleur);

            inc(AlienCompIndex);
          end;
        end;
      end;
    end;
  end;

  // Prepare the text grid
  form1.StringGrid1.Cols[0][0] := 'Device Num';
  form1.StringGrid1.ColWidths[0] := 0;
  form1.StringGrid1.Cols[1][0] := 'Light Num';
  form1.StringGrid1.ColWidths[1] := 0;
  form1.StringGrid1.Cols[2][0] := 'Device';
  form1.StringGrid1.ColWidths[2] := 120;
  form1.StringGrid1.Cols[3][0] := 'Light';
  form1.StringGrid1.ColWidths[3] := 130;
  form1.StringGrid1.Cols[4][0] := 'Pos. n°';
  form1.StringGrid1.ColWidths[4] := 50;
  form1.StringGrid1.Cols[5][0] := 'Freq. n°';
  form1.StringGrid1.ColWidths[5] := 50;
  form1.StringGrid1.Cols[6][0] := 'Color';
  form1.StringGrid1.ColWidths[6] := 80;
  form1.StringGrid1.RowCount := AlienCompIndex+1;

  // Fill the text grid from AlienComp
  for i := 0 to AlienCompIndex do
  begin
    form1.StringGrid1.Cols[0][i+1] := inttostr(AlienComp[i].device);
    form1.StringGrid1.Cols[1][i+1] := inttostr(AlienComp[i].light);
    form1.StringGrid1.Cols[2][i+1] := AlienComp[i].devicename;
    form1.StringGrid1.Cols[3][i+1] := AlienComp[i].lightname;
    form1.StringGrid1.Cols[4][i+1] := inttostr(AlienComp[i].position);
    form1.StringGrid1.Cols[5][i+1] := inttostr(AlienComp[i].frequency);
    form1.StringGrid1.Cols[6][i+1] := '$'+inttohex(AlienComp[i].couleur.brightness,2)+
                                      inttohex(AlienComp[i].couleur.blue,2)+
                                      inttohex(AlienComp[i].couleur.green,2)+
                                      inttohex(AlienComp[i].couleur.red,2);
  end;
end;

function GetSpecialFolderPath(folder : integer) : string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path: array [0..MAX_PATH] of char;
begin
  if SUCCEEDED(SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@path[0])) then
    Result := path
  else
    Result := '';
end;
function ScreenShoot(activeWindow: bool; destBitmap : TBitmap) : boolean;
 var
    w,h : integer;
    DC : HDC;
    hWin : Cardinal;
    r : TRect;
 begin
    Result := True;
    if activeWindow then
    begin
      hWin := GetForegroundWindow;
      if hWin = 0 then
      begin
        Result := False;
        exit;
      end;
      dc := GetWindowDC(hWin) ;
      GetWindowRect(hWin,r) ;
      w := r.Right - r.Left;
      h := r.Bottom - r.Top;
    end
    else
    begin
      hWin := GetDesktopWindow;
      dc := GetDC(hWin) ;
      w := GetDeviceCaps (DC, HORZRES) ;
      h := GetDeviceCaps (DC, VERTRES) ;
    end;

    try
     destBitmap.Width := w;
     destBitmap.Height := h;
     BitBlt(destBitmap.Canvas.Handle,
            0,
            0,
            destBitmap.Width,
            destBitmap.Height,
            DC,
            0,
            0,
            SRCCOPY) ;
    finally
     ReleaseDC(hWin, DC) ;
    end;
 end;
procedure ExtractColor( MaChaineCouleur : string; pLightCol : PLFX_COLOR );
var
  MyColor : TColor;
  MyColorStr : string;
  Hx, Lx, Sx : word;
begin
   pLightCol.brightness := $FF;
   pLightCol.red   := strtoint('$' + MaChaineCouleur[5]+ MaChaineCouleur[6]);
   pLightCol.green := strtoint('$' + MaChaineCouleur[3]+ MaChaineCouleur[4]);
   pLightCol.blue  := strtoint('$' + MaChaineCouleur[1]+ MaChaineCouleur[2]);

   if pLightCol.red < form1.TrackBar1.Position then pLightCol.red := form1.TrackBar1.Position;
   if pLightCol.green < form1.TrackBar1.Position then pLightCol.green := form1.TrackBar1.Position;
   if pLightCol.blue < form1.TrackBar1.Position then pLightCol.blue := form1.TrackBar1.Position;

   if form1.rgColors.ItemIndex = 1 then     // Hue
   begin
     MyColorStr := '$00'+
     MaChaineCouleur[5]+ MaChaineCouleur[6]+
     MaChaineCouleur[3]+ MaChaineCouleur[4]+
     MaChaineCouleur[1]+ MaChaineCouleur[2];
     ColorRGBToHLS(strtoint(MyColorStr), Hx, Lx, Sx);
     MyColor := ColorHLSToRGB(Hx, 120, 240);
     MyColorStr := inttohex(MyColor,6) ;
     pLightCol.red   := strtoint('$' + MyColorStr[1]+ MyColorStr[2]);
     pLightCol.green := strtoint('$' + MyColorStr[3]+ MyColorStr[4]);
     pLightCol.blue  := strtoint('$' + MyColorStr[5]+ MyColorStr[6]);
   end;

end;
procedure equaliseur ;
begin
  // check the correct BASS was loaded
  if HIWORD(BASS_GetVersion) <> BASSVERSION then
  begin
    MessageBox(0, 'An incorrect version of BASS.DLL was loaded', '', MB_ICONERROR);
    Exit;
  end;

  // initialize BASS recording (default device)
  if not BASS_RecordInit(-1) then
  begin
    Error('Can''t initialize device');
    Halt;
  end;

  // start recording (44100hz mono 16-bit)
  Channel := BASS_RecordStart(44100, 1, 0, @DuffRecording, NIL);
  if Channel = 0 then
  begin
    Error('Can''t start recording');
    Halt;
  end;

end;
procedure FXGRAPH_GPUTemp ();
var
  phys : TNvPhysicalGpuHandleArray;
  cnt : LongWord;
  i : Integer;
  name : NvAPI_ShortString;
  thermal : TNvGPUThermalSettings;
  res : NvAPI_Status;
  PercentTemp : integer;
begin
  if NvAPI_EnumPhysicalGPUs(phys, cnt) = NVAPI_OK then begin
    for i:=0 to cnt - 1 do
      if NvAPI_GPU_GetFullName(phys[i], name) = NVAPI_OK then begin
        FillChar(thermal, sizeof(thermal), 0);
        thermal.version:=NV_GPU_THERMAL_SETTINGS_VER;
        res:=NvAPI_GPU_GetThermalSettings(phys[i],0, @thermal);
        if res= NVAPI_OK then begin
          //write('temp: ', thermal.sensor[0].currentTemp, ' C');
          form1.Label10.Caption := 'GPU Temp '+inttostr(thermal.sensor[0].currentTemp)+' C';
          PercentTemp :=  (thermal.sensor[0].currentTemp - strtoint(form1.Edit1.Text)) * 100;
          PercentTemp := PercentTemp div ( strtoint(form1.Edit2.Text)-strtoint(form1.Edit1.Text));
        end;
      end;
  end;
  percentTemp := ( percentTemp * 255 ) div 100;
  for i := 0 to AlienCompIndex-1 do
  begin
    Aliencomp[i].couleur.brightness := $FF;
    Aliencomp[i].couleur.red   := percentTemp;
    Aliencomp[i].couleur.green := 255 - PercentTemp;
    Aliencomp[i].couleur.blue  := $00;
    resultat := LFX_SetLightColor(AlienComp[i].device, AlienComp[i].light, @AlienComp[i].couleur);
    form1.StringGrid1.Cols[6][i+1] := inttostr(AlienComp[i].couleur.brightness)+' '+
                                      inttostr(AlienComp[i].couleur.red)+' '+
                                      inttostr(AlienComp[i].couleur.green)+' '+
                                      inttostr(AlienComp[i].couleur.blue);
  end;
  resultat := LFX_Update();
end;
procedure FXGRAPH_Screen ();
var
  b:TBitmap;
  jpg: TJpegImage;
  thumbRect : TRect;
  MaChaineCouleur : string ;
  h, i, j, k, m, cr, cb,cg, coordx, coordy : integer;
  MyColor : TColor;
  MyColorStr : string;
  Hx, Lx, Sx : word;
begin

  b := TBitmap.Create;
  thumbRect.Left := 0;
  thumbRect.Top := 0;
  thumbRect.Bottom := 3;
  thumbRect.Right := 4;

  case form1.rgSource.ItemIndex of
  2: begin
      ScreenShoot(FALSE, b) ;  // FALSE = Screen  /// TRUE = Current window
    end;
  3 : begin
      if not ScreenShoot(TRUE, b) then exit;  // FALSE = Screen  /// TRUE = Current window
     end;
  4 : begin
      jpg := TJpegImage.Create;
      try
        if fileexists(GetSpecialFolderPath(CSIDL_APPDATA)+'\Microsoft\Windows\Themes\TranscodedWallpaper.jpg') then
          jpg.LoadFromFile(GetSpecialFolderPath(CSIDL_APPDATA)+'\Microsoft\Windows\Themes\TranscodedWallpaper.jpg');
        if fileexists(GetSpecialFolderPath(CSIDL_APPDATA)+'\Microsoft\Windows\Themes\TranscodedWallpaper') then
          jpg.LoadFromFile(GetSpecialFolderPath(CSIDL_APPDATA)+'\Microsoft\Windows\Themes\TranscodedWallpaper');
        b.Assign(jpg);
      except
       on E : Exception do
       begin
         //ShowMessage(E.Message);
       end;
      end;
      jpg.Free;
    end;
  end;

  form1.Image1.Picture.Assign(b) ;
  //resize image
  b.Canvas.StretchDraw(thumbRect, b) ;
  b.Width := thumbRect.Right;
  b.Height := thumbRect.Bottom;
  form1.Image2.Picture.Assign(b) ;

  case form1.rgColors.ItemIndex of
    0 : begin // Normal Colors
      m := 1;
      for j := 0 to thumbRect.Bottom-1 do
      begin
        for k := 0 to thumbRect.Right-1 do
        begin
          for i := 0 to AlienCompIndex-1 do
          begin
            if Aliencomp[i].position = 0 then
            begin
              Aliencomp[i].couleur.brightness := $00;
              Aliencomp[i].couleur.red   := $00;
              Aliencomp[i].couleur.green := $00;
              Aliencomp[i].couleur.blue  := $00;
            end;
            if Aliencomp[i].position = m then
            begin
              Aliencomp[i].couleur.brightness := $FF;
              Aliencomp[i].couleur.red   := GetRValue(form1.Image2.Canvas.Pixels[k,j]);
              Aliencomp[i].couleur.green := GetGValue(form1.Image2.Canvas.Pixels[k,j]);
              Aliencomp[i].couleur.blue  := GetBValue(form1.Image2.Canvas.Pixels[k,j]);
              form1.StringGrid1.Cols[6][i+1] := inttostr(AlienComp[i].couleur.brightness)+' '+
                                                inttostr(AlienComp[i].couleur.red)+' '+
                                                inttostr(AlienComp[i].couleur.green)+' '+
                                                inttostr(AlienComp[i].couleur.blue);
            end;
          end;
          inc(m);
        end;
      end;
    end;
    1 : begin  // HUE Colors
      m := 1;
      for j := 0 to thumbRect.Bottom-1 do
      begin
        for k := 0 to thumbRect.Right-1 do
        begin
          for i := 0 to AlienCompIndex-1 do
          begin
            if Aliencomp[i].position = 0 then
            begin
              Aliencomp[i].couleur.brightness := $00;
              Aliencomp[i].couleur.red   := $00;
              Aliencomp[i].couleur.green := $00;
              Aliencomp[i].couleur.blue  := $00;
            end;
            if Aliencomp[i].position = m then
            begin
              MyColorStr := '$00'+inttohex(GetRValue(form1.Image2.Canvas.Pixels[k,j]),2)+
                                  inttohex(GetGValue(form1.Image2.Canvas.Pixels[k,j]),2)+
                                  inttohex(GetBValue(form1.Image2.Canvas.Pixels[k,j]),2);
              ColorRGBToHLS(strtoint(MyColorStr), Hx, Lx, Sx);
              MyColor := ColorHLSToRGB(Hx, 120, 240);
              Aliencomp[i].couleur.brightness := $FF;
              Aliencomp[i].couleur.red   := GetRValue(MyColor);
              Aliencomp[i].couleur.green := GetGValue(MyColor);
              Aliencomp[i].couleur.blue  := GetBValue(MyColor);
              form1.StringGrid1.Cols[6][i+1] := inttostr(AlienComp[i].couleur.brightness)+' '+
                                                inttostr(AlienComp[i].couleur.red)+' '+
                                                inttostr(AlienComp[i].couleur.green)+' '+
                                                inttostr(AlienComp[i].couleur.blue);
            end;
          end;
          inc(m);
        end;
      end;
    end;
    2 : begin // Average Color
      cr := 0;
      cg := 0;
      cb := 0;
      for coordx := 0  to 3 do
      begin
        for coordy := 0  to 2 do
        begin
          MaChaineCouleur := inttohex(form1.Image2.Canvas.Pixels[coordx,coordy],6) ;
          cr := cr + strtoint('$' + MaChaineCouleur[5]+ MaChaineCouleur[6]);
          cg := cg + strtoint('$' + MaChaineCouleur[3]+ MaChaineCouleur[4]);
          cb := cb + strtoint('$' + MaChaineCouleur[1]+ MaChaineCouleur[2]);
        end;
      end;
      cr := cr div 12 ;
      cg := cg div 12 ;
      cb := cb div 12 ;

      for i := 0 to AlienCompIndex-1 do
      begin
        Aliencomp[i].couleur.brightness := $FF;
        Aliencomp[i].couleur.red   := cr;
        Aliencomp[i].couleur.green := cg;
        Aliencomp[i].couleur.blue  := cb;
//        if LC_ALIEN_MEDIA.red < form1.TrackBar1.Position   then LC_ALIEN_MEDIA.red := form1.TrackBar1.Position;
//        if LC_ALIEN_MEDIA.green < form1.TrackBar1.Position then LC_ALIEN_MEDIA.green := form1.TrackBar1.Position;
//        if LC_ALIEN_MEDIA.blue < form1.TrackBar1.Position  then LC_ALIEN_MEDIA.blue := form1.TrackBar1.Position;

        form1.StringGrid1.Cols[6][i+1] := inttostr(AlienComp[i].couleur.brightness)+' '+
                                          inttostr(AlienComp[i].couleur.red)+' '+
                                          inttostr(AlienComp[i].couleur.green)+' '+
                                          inttostr(AlienComp[i].couleur.blue);
      end;
    end;
  end;

  case form1.rgAction.ItemIndex of
    0 : begin // Still
      for h := 0 to AlienCompIndex-1 do
      begin
        resultat := LFX_SetLightColor(AlienComp[h].device, AlienComp[h].light, @AlienComp[h].couleur);
      end;
    end;
    1 : begin // Morph
      for h := 0 to AlienCompIndex-1 do
      begin
        resultat := LFX_SetLightActionColor(AlienComp[h].device, AlienComp[h].light, LFX_ACTION_MORPH, @AlienComp[h].couleur);
      end;
    end;
    2 : begin // Pulse
      for h := 0 to AlienCompIndex-1 do
      begin
        resultat := LFX_SetLightActionColor(AlienComp[h].device, AlienComp[h].light, LFX_ACTION_PULSE, @AlienComp[h].couleur);
      end;
    end;
  end;
  resultat := LFX_Update();

  b.FreeImage;
  FreeAndNil(b) ;
end;
procedure SauveINI (filename : string);
var
  appINI : TIniFile;
  i : integer;
begin
  appINI := TIniFile.Create(filename) ;
  try
    for i := 0 to AlienCompIndex-1 do
    begin
      appINI.WriteString(inttostr(i),'Device', AlienComp[i].devicename);
      appINI.WriteString(inttostr(i),'Light', AlienComp[i].lightname);
      appINI.WriteInteger(inttostr(i),'position', AlienComp[i].position);
      appINI.WriteInteger(inttostr(i),'frequency', AlienComp[i].frequency);
      appINI.WriteInteger(inttostr(i),'red', AlienComp[i].couleur.red );
      appINI.WriteInteger(inttostr(i),'green', AlienComp[i].couleur.green );
      appINI.WriteInteger(inttostr(i),'blue', AlienComp[i].couleur.blue );
    end;
  finally
    appIni.Free;
  end;
end;
procedure ChargeINI ( filename : string );
var
  appINI : TIniFile;
  i : integer;
begin
  appINI := TIniFile.Create(filename) ;
  try
    for i := 0 to form1.StringGrid1.ColCount - 1 do form1.StringGrid1.Cols[i].Clear;
    // Re draw Grid Headers
    form1.StringGrid1.Cols[0][0] := 'Device Num';
    form1.StringGrid1.ColWidths[0] := 0;
    form1.StringGrid1.Cols[1][0] := 'Light Num';
    form1.StringGrid1.ColWidths[1] := 0;
    form1.StringGrid1.Cols[2][0] := 'Device';
    form1.StringGrid1.ColWidths[2] := 120;
    form1.StringGrid1.Cols[3][0] := 'Light';
    form1.StringGrid1.ColWidths[3] := 130;
    form1.StringGrid1.Cols[4][0] := 'Pos.';
    form1.StringGrid1.ColWidths[4] := 50;
    form1.StringGrid1.Cols[5][0] := 'Freq.';
    form1.StringGrid1.ColWidths[5] := 50;
    form1.StringGrid1.Cols[6][0] := 'Color';
    form1.StringGrid1.ColWidths[6] := 80;
    form1.StringGrid1.RowCount := AlienCompIndex+1;
    // Read the file
    for i := 0 to AlienCompIndex-1 do
    begin
      AlienComp[i].position := appINI.ReadInteger(inttostr(i), 'position', 0);
      AlienComp[i].frequency := appINI.ReadInteger(inttostr(i), 'frequency', 0);
      AlienComp[i].couleur.red := appINI.ReadInteger(inttostr(i), 'red', 0);
      AlienComp[i].couleur.green := appINI.ReadInteger(inttostr(i), 'green', 0);
      AlienComp[i].couleur.blue := appINI.ReadInteger(inttostr(i), 'blue', 0);
      // Refill the grid
      form1.StringGrid1.Cols[0][i+1] := inttostr(AlienComp[i].device);
      form1.StringGrid1.Cols[1][i+1] := inttostr(AlienComp[i].light);
      form1.StringGrid1.Cols[2][i+1] := AlienComp[i].devicename;
      form1.StringGrid1.Cols[3][i+1] := AlienComp[i].lightname;
      form1.StringGrid1.Cols[4][i+1] := inttostr(AlienComp[i].position);
      form1.StringGrid1.Cols[5][i+1] := inttostr(AlienComp[i].frequency);
      form1.StringGrid1.Cols[6][i+1] := '$'+inttohex(AlienComp[i].couleur.brightness,2)+
                                        inttohex(AlienComp[i].couleur.blue,2)+
                                        inttohex(AlienComp[i].couleur.green,2)+
                                        inttohex(AlienComp[i].couleur.red,2);
      resultat := LFX_SetLightColor(AlienComp[i].device, AlienComp[i].light, @AlienComp[i].couleur);
    end;
    resultat := LFX_Update();
  finally
    appINI.Free;
  end;
end;
procedure TForm1.Bt_loadClick(Sender: TObject);
var
  openDialog : TOpenDialog;
begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter :=
    'INI files|*.ini|All files|*.*';
  openDialog.FilterIndex := 1;
  if openDialog.Execute
  then ChargeINI(openDialog.FileName);
  openDialog.Free;
end;
procedure TForm1.Bt_saveClick(Sender: TObject);
var
  saveDialog : TSaveDialog;
begin
  saveDialog := TSaveDialog.Create(self);
  saveDialog.Title := 'Save your light template';
  saveDialog.InitialDir := GetCurrentDir;
  savedialog.filename := ChangeFileExt(Application.ExeName,'.ini');
  saveDialog.Filter := 'INI file|*.ini';
  saveDialog.DefaultExt := 'ini';
  saveDialog.FilterIndex := 1;
  if saveDialog.Execute
  then SauveINI(saveDialog.FileName);
  saveDialog.Free;
end;
procedure TForm1.Button2Click(Sender: TObject);
var
  unentier : longword;
begin
  unentier := Form1.TrackBar4.Position;
  resultat := LFX_SetTiming(unentier);
  resultat := LFX_Update();
end;
procedure TForm1.CheckBoxCycleClick(Sender: TObject);
begin
  if checkboxcycle.Checked = True then
    form1.TimerColor.Enabled := True
  else
    form1.TimerColor.Enabled := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  with TrayIconData do
  begin
    //cbSize := SizeOf(TrayIconData);
    Wnd := Handle;
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, 'AlienAllFX (Left or Right Clic this icon for more)');
  end;
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);

  FenetreVisible := True;
  MenuVisible := False;

  Case LFX_Initialize() of
  LFX_SUCCESS : begin
  end;
  LFX_ERROR_NODEVS : begin
    showmessage('No AlienWare devices found. Terminating...');
    exit;
  end;
  LFX_FAILURE : begin
    showmessage('Failed to Initialize device. Terminating...');
    exit;
  end;
  End;

  GetAlienInfo;
  resultat := LFX_Update();

  if fileexists(ChangeFileExt(Application.ExeName,'.ini')) then
    ChargeINI(ChangeFileExt(Application.ExeName,'.ini'));

end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  BASS_RecordFree;
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  if LFX_Release() <> LFX_SUCCESS then exit;
end;

procedure TForm1.miHelpClick(Sender: TObject);
begin
  Form2.show;
end;
procedure TForm1.miQuitterClick(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  LFX_Release();
  application.Terminate;
end;
procedure TForm1.miPauseClick(Sender: TObject);
begin
  form1.rgSource.ItemIndex := 0;
end;

procedure TForm1.rgLightsClick(Sender: TObject);
begin
  if form1.rgSource.ItemIndex = 5 then  // Sound
  begin
    case form1.rgLights.ItemIndex of
    0 : begin
      form1.Label1.Caption := 'Lights updated every 0,15s';
      trackbar2.Position := 150;
    end;
    1 : begin
      form1.Label1.Caption := 'Lights updated every 0,05s';
      trackbar2.Position := 50;
    end;
    2 : begin
      form1.Label1.Caption := 'Lights updated every 0,075s';
      trackbar2.Position := 75;
    end;
    3 : begin
      form1.Label1.Caption := 'Lights updated every 0,125s';
      trackbar2.Position := 125;
    end;
    end;
  end;
end;
procedure TForm1.rgSourceClick(Sender: TObject);
var
  res : NvAPI_Status;
begin
  case form1.rgSource.ItemIndex of
  0 : begin // Off
    BASS_RecordFree;
    trackbar2.Position := 5000;
    form1.Label1.Caption := 'Paused';
    form1.Bt_load.Enabled := True;
    form1.Bt_save.Enabled := True;
    timer2.Enabled := False;
  end;
  1 : begin // Manual
    BASS_RecordFree;
    trackbar2.Position := 250;
    form1.Label1.Caption := 'Lights updated every 0,25s';
    form1.Bt_load.Enabled := True;
    form1.Bt_save.Enabled := True;
    timer2.Enabled := True;
    //GEN_UpdatePalette;
  end;
  2 : begin // Screen
    BASS_RecordFree;
    trackbar2.Position := 200;
    form1.Label1.Caption := 'Lights updated every 0,2s';
    form1.Bt_load.Enabled := False;
    form1.Bt_save.Enabled := False;
    timer2.Enabled := True;
  end;
  3 : begin // Window
    BASS_RecordFree;
    trackbar2.Position := 200;
    form1.Label1.Caption := 'Lights updated every 0,2s';
    form1.Bt_load.Enabled := False;
    form1.Bt_save.Enabled := False;
    timer2.Enabled := True;
  end;
  4: begin // Wallpaper
    BASS_RecordFree;
    trackbar2.Position := 5000;
    form1.Label1.Caption := 'Lights updated every 5s';
    form1.Bt_load.Enabled := False;
    form1.Bt_save.Enabled := False;
    timer2.Enabled := True;
  end;
  5 : begin // Sound
    form1.Timer2.Enabled := False;
    equaliseur;
    form1.rgLights.ItemIndex := 0;
    trackbar2.Position := 175;
    form1.Label1.Caption := 'Lights updated every 0,175s';
    form1.Bt_load.Enabled := False;
    form1.Bt_save.Enabled := False;
    form1.Timer2.Enabled := True;
  end;
  6: begin // Nvidia GPU Temp
    BASS_RecordFree;
    trackbar2.Position := 5000;
    form1.Label1.Caption := 'Lights updated every 5s';
    form1.Bt_load.Enabled := False;
    form1.Bt_save.Enabled := False;

    res:=NvAPI_Initialize;
    if res<>NVAPI_OK then begin
      timer2.Enabled := False;
      rgsource.ItemIndex := 0;
      Exit;
    end;

    timer2.Enabled := True;
  end;
end;
end;

procedure TForm1.SLHColorPicker1Change(Sender: TObject);
var
  i : integer;
begin
  if form1.StringGrid1.Row > 0 then
  begin
    //i := strtoint(form1.StringGrid1.cells[4,form1.StringGrid1.Row])-1;
    i := form1.StringGrid1.Row -1;
    Aliencomp[i].couleur.brightness := $FF;
    Aliencomp[i].couleur.red   := GetRValue(ColorToRGB(Form1.SLHColorPicker1.SelectedColor));
    Aliencomp[i].couleur.green := GetGValue(ColorToRGB(Form1.SLHColorPicker1.SelectedColor));
    Aliencomp[i].couleur.blue  := GetBValue(ColorToRGB(Form1.SLHColorPicker1.SelectedColor));
    resultat := LFX_SetLightColor(AlienComp[i].device, AlienComp[i].light, @AlienComp[i].couleur);
    form1.StringGrid1.Cols[6][form1.StringGrid1.Row] := '$'+inttohex(AlienComp[i].couleur.brightness,2)+
                                  inttohex(AlienComp[i].couleur.blue,2)+
                                  inttohex(AlienComp[i].couleur.green,2)+
                                  inttohex(AlienComp[i].couleur.red,2);
  end;
end;
procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  with (Sender as TStringGrid) do
  begin
    // Don't change color for first Row, and only for col 6
    if (ACol = 6) and (ARow > 0) then
    begin
      Canvas.Brush.Color := rgb(AlienComp[ARow-1].couleur.red, AlienComp[ARow-1].couleur.green, AlienComp[ARow-1].couleur.blue);
      Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, cells[acol, arow]);
      Canvas.FrameRect(Rect);
    end;
  end;
end;
procedure TForm1.StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var
  i : integer;
begin
  if trystrtoint(Value, i) then
    if ACol = 4 then
      AlienComp[ARow-1].position := i
    else
      if Acol = 5 then
        AlienComp[ARow-1].frequency := i;

end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
  h : integer;
begin
  case form1.rgSource.ItemIndex of
  0 : begin // Off
  end;
  1 : begin // Manual
    case form1.rgAction.ItemIndex of
      0 : begin // Still
        for h := 0 to AlienCompIndex-1 do
        begin
          resultat := LFX_SetLightColor(AlienComp[h].device, AlienComp[h].light, @AlienComp[h].couleur);
        end;
      end;
      1 : begin // Morph
        for h := 0 to AlienCompIndex-1 do
        begin
          resultat := LFX_SetLightActionColor(AlienComp[h].device, AlienComp[h].light, LFX_ACTION_MORPH, @AlienComp[h].couleur);
        end;
      end;
      2 : begin // Pulse
        for h := 0 to AlienCompIndex-1 do
        begin
          resultat := LFX_SetLightActionColor(AlienComp[h].device, AlienComp[h].light, LFX_ACTION_PULSE, @AlienComp[h].couleur);
        end;
      end;
    end;
    resultat := LFX_Update();
  end;
  2 : begin // Screen
    FXGRAPH_Screen;
  end;
  3 : begin // Window
    FXGRAPH_Screen;
  end;
  4: begin // Wallpaper
    FXGRAPH_Screen;
  end;
  5 : begin // Sound
    UpdateSpectrum;
  end;
  6 : begin // GPU Temp
    FXGRAPH_GPUTemp;
  end;
end;
end;
procedure TForm1.TimerColorTimer(Sender: TObject);
begin
  if form1.HColorPicker1.Hue = 360 then form1.HColorPicker1.Hue := 0 ;
  form1.HColorPicker1.Hue := form1.HColorPicker1.Hue + 1;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  form1.Label1.Caption := 'Lights updated every '+floattostr(form1.TrackBar2.Position/1000)+'s';
  form1.Timer2.Interval := form1.TrackBar2.Position;

end;
procedure TForm1.TrackBar4Change(Sender: TObject);
begin
  form1.Label29.Caption := 'Morph / Pulse Timer '+inttostr(Form1.TrackBar4.Position)+'ms';
end;

procedure TForm1.TrayMessage(var Msg: TMessage);
var
  pt: TPoint;
begin
  case Msg.lParam of
    WM_LBUTTONDOWN:
    begin
      if FenetreVisible = False then
      begin
        FenetreVisible := True;
        Form1.Show;
      end
      else
      begin
        FenetreVisible := False;
        Form1.Hide;
      end;
    end;
    WM_RBUTTONDOWN:
    begin
      if MenuVisible = False then
      begin
        MenuVisible := True;
        GetCursorPos(pt);
        pmRightClick.Popup(pt.x, pt.y);
      end
      else
      begin
        MenuVisible := False;
        pmRightClick.CloseMenu;
      end;
    end;
  end;
end;


end.





