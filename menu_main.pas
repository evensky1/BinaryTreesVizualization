unit menu_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  Tmain_menu = class(TForm)
    ActionList1: TActionList;
    btnOpen: TButton;
    btnDir: TButton;
    btnExit: TButton;
    actOpenBinary: TAction;
    actExit: TAction;
    procedure actOpenBinaryExecute(Sender: TObject);
    procedure btnDirClick(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  main_menu: Tmain_menu;

implementation

{$R *.dfm}
uses
  binary_main;

procedure Tmain_menu.actExitExecute(Sender: TObject);
var
ensurance: integer;
begin  //��������, ����� �� ������������ ������ �����
 ensurance := messagedlg('�� �������, ��� ������ �����? ', mtConfirmation, mbYesNo, 0);
 if ensurance = 6 then
 main_menu.close;
end;

procedure Tmain_menu.actOpenBinaryExecute(Sender: TObject);
begin
 binary_form.show;            //����� ����� ��� ������������
 main_menu.enabled := FALSE; //����� �������� ���� ���������� �����������
end;

procedure Tmain_menu.btnDirClick(Sender: TObject);
begin //������� �������, ��� �������� � �������� ������ ����� ����� ��� �������� �� �����

 btnDir.Action.Execute;
 main_menu.enabled := FALSE;
 binary_form.show;
end;

procedure Tmain_menu.FormCreate(Sender: TObject);
begin  //������� ����� �����
  main_menu.Color := $cfd9ce;
end;

end.
