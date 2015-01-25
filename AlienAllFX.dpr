program AlienAllFX;

uses
  Vcl.Forms,
  AlienFX in 'AlienFX.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  About in 'About.pas' {Form2},
  bass in 'bass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.ShowMainForm := True;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Amakrits');
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
