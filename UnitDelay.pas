unit UnitDelay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    TrackBar1: TTrackBar;
    Label4: TLabel;
    procedure TrackBar1Change(Sender: TObject);

  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses AlienFX;





procedure TForm2.TrackBar1Change(Sender: TObject);
begin
  //secondes := 0;
  Form1.progressbar1.position := 0;
  Form1.trackbar1.Position := Form2.trackbar1.Position;
  Form1.label4.Caption := format('%d',[(Form1.trackbar1.Position)]) + 's' ;
  Form1.ProgressBar1.Max := Form1.trackbar1.Position;

  Form2.label4.Caption := Form1.label4.Caption ;

end;




end.
