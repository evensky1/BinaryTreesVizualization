unit binary_main;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList, Vcl.Menus;

type
  Tbinary_form = class(TForm)
    Image1: TImage;
    BinaryMenu: TMainMenu;
    topPanel, bottomPanel: TPanel;
    ODBinary: TOpenDialog;
    SDBinary: TSaveDialog;
    editElement: TLabeledEdit;

    BinaryActions: TActionList;
    addElem, delElem, clearElems, actPreorder, actInorder, actPostorder, actCreate,
    actSearch: TAction;

    btnAdd, btnClear, btnDelete, btnClose, btnSearch: TButton;

    N1, N2, N3, N5, N7, N8, N9, N10, N11, N12: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure addElemExecute(Sender: TObject);
    procedure delElemExecute(Sender: TObject);
    procedure clearElemsExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure actBalanceExecute(Sender: TObject);
    procedure actPreorderExecute(Sender: TObject);
    procedure actInorderExecute(Sender: TObject);
    procedure actPostorderExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure editElementKeyPress(Sender: TObject; var Key: Char);
    procedure actCreateExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TKey = integer;

  node_pointer = ^node;
  node = record
    key: TKey;
    left, right: node_pointer;
  end;

  stack_pointer = ^Stack;
  Stack = record
    next: stack_pointer;
    data: TKey;
  end;
var
  binary_form: Tbinary_form;
  btree: node_pointer;

function search(k: Tkey; var tree, res: node_pointer): boolean;
function tree_depth(const tree: node_pointer): integer;
procedure include(const k: Tkey; var tree: node_pointer);
procedure tree_free(var tree: node_pointer);
procedure delete_element( var tree: node_pointer; const key: TKey);
procedure push(const key: TKey; var temp_stack: stack_pointer);
procedure pop(out receiver: TKey; var temp_stack: stack_pointer);
procedure pause(const p:byte);
procedure refresh_tree(const tree: node_pointer; image: TImage);

implementation
{$R *.dfm}
uses
  menu_main, math;

function search;
var
b: boolean;
temp_node, current_node: node_pointer;
begin
  temp_node := tree; //����� �������������� �������
  b:=FALSE;          //����������-������, ���������� ����
  current_node := nil; //����� ������������ �������
  if tree <> nil then
  repeat
    current_node := temp_node;

    if temp_node^.key = k then
      b := TRUE
    else
      if k < temp_node^.key then
        temp_node := temp_node^.left //������� � ������ �������
      else
        temp_node := temp_node^.right //������� � �������
  until (temp_node = nil) or b;
  result := b;
  res := current_node;  //��������� ����(� ������ ������������ ����� ����� ����������
end;                   //����������� ����)

procedure include;
var
  current_node, new_node: node_pointer;
begin
  if not search(k, tree, current_node) then //���������� �������� � ������ ������������ �����
  begin
    new(new_node);      //��������� ������� ������
    new_node^.key := k;       //
    new_node^.left := nil;   //������������� �����
    new_node^.right := nil; //

    if tree = nil then
      tree := new_node
    else
      if k < current_node^.key then
        current_node^.left := new_node
      else
        current_node^.right := new_node;
  end
  else
  showmessage('����� ���� ��� ����������, ���������� �����...');
end;

procedure tree_free; //����������� ��������� ������� ������ �� ������
begin
    if tree <> nil then
    begin
      tree_free(tree^.left);
      tree_free(tree^.right);
      dispose(tree); //���������� �������� ���������� �� ���. ��������
      tree := nil;
    end;
end;

function tree_depth;
var
hl, hr: integer;
begin
  result := 0;
  if tree <> nil then
  begin
    hl := tree_depth(tree^.left); //������ �� ����� �����
    hr := tree_depth(tree^.right); //������ �� ����� ������
    if hl > hr then   //������������� ���������� �� ���. ��������
      result := 1 + hl
    else
      result := 1 + hr;
  end;
end;

procedure refresh_tree;
var
  depth: integer;
  procedure node_out(const tree: node_pointer; offset, level: integer);
  begin
    with image.Canvas do
    begin
      if tree^.left <> nil then //����� ����� ��� ������ �������
      begin
        moveto(offset, 100*(level));
        lineto(offset - 30*trunc(power(2, depth - (level + 1))), 100*(level + 1));
        node_out(tree^.left, offset - 30*trunc(power(2, depth - (level + 1))), level + 1);
      end;

      if tree^.right <> nil then  //��� �������
      begin
        moveto(offset, 100*(level));
        lineto(offset + 30*trunc(power(2, depth - (level + 1))), 100*(level + 1));
        node_out(tree^.right, offset + 30*trunc(power(2, depth - (level + 1))), level + 1);
      end;
      //��������� ������ ���� ����������� �� ���. ��������, ����� ������� ������ ����� ����
      ellipse(offset - 25, 100*level - 25, offset + 25, 100*level + 25);
      case tree^.key of
        0 .. 99: Font.Size := 15;
        100 .. 999: font.Size := 12;
        1000 .. 9999: Font.Size := 10;
        10000 .. 99999: Font.Size := 9;
        100000 .. 999999: Font.Size := 8;
      end;
      TextOut(offset - (TextWidth(inttostr(tree^.key)) div 2), 100*level - (TextHeight(inttostr(tree^.key)) div 2), inttostr(tree^.key));
    end;
  end;
begin
  image.Canvas.brush.Color := $cfd9ce;
  image.Canvas.rectangle(0, 0, image.Width, image.Height);
  if tree <> nil then
  begin
    depth := tree_depth(tree);
    with image.Canvas do
    begin
      pen.Width := 2;
      brush.Color := $cfd9ce;
      rectangle(0, 0, image.Width, image.Height);
      brush.Color := clWhite;
      Font.Size := 6;
      node_out(tree, image.Width div 2, 1);//����� ��� ����� � ������ �������
      brush.Color := $cfd9ce;
    end;
  end;
end;

procedure delete_element;
var
  temp_node: node_pointer;
  procedure delete_parent(var parent_node: node_pointer); //�������� ��� ������� ������
  begin                                      //����� ��������� ���� ����� ��� �������
    if parent_node^.right = nil then //����� ������ ������� ���� ������ ���������
      begin                         //� ���������� ��������� ��� �� ���� ����������
        temp_node^.key := parent_node^.key;
        temp_node := parent_node;
        parent_node := temp_node^.left;
        dispose(temp_node);
      end
    else
      begin
        delete_parent(parent_node^.right);
      end;

  end;
begin
  if tree = nil then
    showmessage('����� � ����� ������ � ������ ����������')
  else
    if key < tree^.key then
      delete_element(tree^.left, key)
    else
      if key > tree^.key then
        delete_element(tree^.right, key)
      else
        begin    //�� ���� ������� ������� ��������� ���������
          temp_node := tree;
          if temp_node^.right = nil then
          begin  //����������� ������ ���� �� ����� ����������
            tree := temp_node^.left;
            dispose(temp_node);
          end
          else
            if temp_node^.left = nil then
            begin   //����������� ������� ���� �� ����� ����������
              tree := temp_node^.right;
              dispose(temp_node);
            end
             else //������ ��� ���� ��������
              delete_parent(temp_node^.left); //����� ��� ������ ���������
        end;
end;

procedure Tbinary_form.btnCloseClick(Sender: TObject);
begin    //������� ������ "������� ����"
  binary_form.Close;
end;

procedure Tbinary_form.clearElemsExecute(Sender: TObject);
begin   //�������� ������� �������
 tree_free(btree); //������������ ������ �� ������
 refresh_tree(btree, image1);  //����������� �������
 showmessage('�������');
end;

procedure Tbinary_form.delElemExecute(Sender: TObject);
begin
  if editElement.Text = '' then
  begin    //�������� �� ������ ������� ����
    editElement.EditLabel.Font.Color := clRed;
    editElement.EditLabel.Caption := '��������� ����!'
  end
  else
  begin
    delete_element(btree, strtoint(editElement.text));
    refresh_tree(btree, image1);
    editElement.Text := '';
  end;
end;
// ��������� push � pop - ��������� ������ �� ������
procedure push(const key: TKey; var temp_stack: stack_pointer);
 var
  new_elem: stack_pointer;
 begin
    new(new_elem);           //
    new_elem^.next := nil;  //������������� ������ ����� �����
    new_elem^.data := key; //

  if temp_stack = nil then   //��������� ����� � ����
    temp_stack := new_elem
  else
  begin
    new_elem^.next := temp_stack;
    temp_stack := new_elem;
  end;
 end;

 procedure pop(out receiver: TKey; var temp_stack: stack_pointer);
 var
  temp: stack_pointer;
 begin
  if temp_stack = nil then Exit;
  temp := temp_stack;
  temp_stack := temp^.next;
  receiver := temp^.Data;
  Dispose(temp);
 end;

 procedure balance(var tree: node_pointer); //��������� ������������ ������
 var
  subleft, subright, temp_node: node_pointer;
  temp: Tkey;
  stacks: stack_pointer;
 begin
  stacks := nil;  //������������� �����
  while tree <> nil do
  begin
      if tree^.left <> nil then
      begin
        subleft := tree;
        while subleft^.left^.left <> nil do  //������� � ���������������� ����� ������
          subleft := subleft^.left;

        push(subleft^.left^.key, stacks);  //��������� ������������ ����� � ����
        temp_node := subleft^.left;         //�������� ����� � ����������� ������
        subleft^.left := temp_node^.right;  //���� ����� ������� �����������, ��
        dispose(temp_node);                 //���������� nil
        temp_node := nil;
      end
      else
      begin //������, ����� ����������� ������� ��� ������ ������
        if tree <> nil then
        begin
          push(tree^.key, stacks);
          subleft := tree;  //� ���� ����� subleft ��������� ��� ���������� temp_node
          tree := subleft^.right;
          dispose(subleft);
          subleft := nil;
        end;
      end;

      if tree = nil then break;

      if tree^.right <> nil then
      begin
        subright := tree;
        while subright^.right^.right <> nil do
          subright := subright^.right;
        push(subright^.right^.key, stacks);  
        temp_node := subright^.right;
        subright^.right := temp_node^.left;
        dispose(temp_node);
        temp_node := nil;
      end
      else
      begin
        push(tree^.key, stacks);
        subright := tree;
        tree := subright^.left;
        dispose(subright);
        subright := nil; 
      end;
  end; //� ���������� ����� �����: ������ ��������� ������, � ��� ��� ����� �����
      //�������� � �����, � ������ �������� ����� ������ ��������� ��������
    while stacks <> nil do //�������� ������ �� �����
    begin
      pop(temp, stacks);
      include(temp, tree);
    end;
  if tree^.left <> nil then balance(tree^.left);//����� ��������� ��� ������ ���������
  if tree^.right <> nil then balance(tree^.right); //��� ������� ���������
 end;

procedure Tbinary_form.actBalanceExecute(Sender: TObject);
begin
 if btree <> nil then
 begin
   balance(btree);
   refresh_tree(btree, image1);
 end
 else
   showmessage('������ �����������...');
end;

procedure pause(const p:byte);  // p - ����� � ���������
var delay: TTime;
begin
  delay:=encodetime(0,0,p,0)+time;  //time ���������� ������� �����
  repeat
   application.processmessages;  //���������� ������� ��������� ����� ����������
                                //���������� ���������
   sleep(10);
  until time>=delay;
end;

procedure pre_traverse(const tree: node_pointer; image: TImage);
var     //��������� ������� ������
depth: integer;
procedure pre_order(tree: node_pointer; offset, level: integer);
  begin  //��������� �������� ����� �� ��������, ����������� ��� node_out
   image.Canvas.Ellipse(offset - 25, 100*level - 25, offset + 25, 100*level + 25);
   pause(1);
   if tree^.left <> nil then
    pre_order(tree^.left, offset - 30*trunc(power(2, depth - (level + 1))), level + 1);
   if tree^.right <> nil then
    pre_order(tree^.right, offset + 30*trunc(power(2, depth - (level + 1))), level + 1);
  end;
begin
  if tree <> nil then
  begin
    depth := tree_depth(tree);
    with image.Canvas do
    begin
      pen.Width := 4;
      Pen.Color := clRed;
      brush.Style := bsClear;
      binary_form.Enabled := FALSE;

      pre_order(tree, image.Width div 2, 1);

      brush.Color := $cfd9ce;
      pen.Color := clBlack;
      Pen.Width := 2;
      Brush.style := bsSolid;
    end;
    pause(1);
    binary_form.enabled := TRUE;
    refresh_tree(tree, image);
  end
  else
    showmessage('������ �����������...');
end;

procedure Tbinary_form.actPreorderExecute(Sender: TObject);
begin
 pre_traverse(Btree, image1);
end;

procedure Tbinary_form.actSaveExecute(Sender: TObject);
var
  Name, sin, spre, spost: string;
  F: file of TKey;
  FTxt: textfile;
  btn, i: integer;
  procedure rec_save(const node: node_pointer);
  begin    //����������� ������ � �������������� ����
    write(F, node^.key);
    if node^.left <> nil then rec_save(node^.left);
    if node^.right <> nil then rec_save(node^.right);
  end;
  procedure txt_strings(const node: node_pointer; var s_pre, s_in, s_post: string);
  begin  //�������� ��� �����-����������� ������
    s_pre := s_pre + inttostr(node^.key) + ', '; 
    if node^.left <> nil then txt_strings(node^.left, s_pre, s_in, s_post);
    s_in := s_in + inttostr(node^.key) + ', ';
    if node^.right <> nil then txt_strings(node^.right, s_pre, s_in, s_post);
    s_post := s_post + inttostr(node^.key) + ', ';
  end;
begin
  SDBinary.InitialDir := GetCurrentDir + '/files';
  SDBinary.Filter := '�������������� |*.dat|��������� |*.txt';
  if btree <> nil then
  begin
    if SDBinary.Execute then
    begin
      Name := SDBinary.FileName;
      if SDBinary.FilterIndex = 1 then  //������ ���� ������ ������ Data
      begin

        if fileexists(Name) then
        begin
          delete(name, length(name) - 3, 4);
          btn := messagedlg('������������ ��� ������������?', mtConfirmation, mbYesNo, 0);
          if btn = mrNo then
          begin   //���� ���������� �� �����, ���� ���� �������� ��������� ������
            i:=1; //� ��������, ��� �������� ������ �����
            while fileexists( name + inttostr(i) + '.dat') do
              inc(i);

            assignfile(F, name + inttostr(i) + '.dat');
          end
          else
            assignfile(F, name + '.dat');
        end
        else
        assignfile(F, name + '.dat');

          rewrite(F);
          rec_save(btree); 
          closefile(F);
          showmessage('��������� ��� �������������� ����!');
      end
      else
      if SDBinary.FilterIndex = 2 then
      begin
        if fileexists(name) then
        begin
          delete(name, length(name) - 3, 4);
          btn := messagedlg('������������ ��� ������������?', mtConfirmation, mbYesNo, 0);
          if btn = mrNo then
          begin
            i:=1;
            while fileexists(name + inttostr(i) + '.txt') do
              inc(i);

            assignfile(FTxt, name + inttostr(i) + '.txt');
          end
          else
            assignfile(FTxt, name + '.txt');
        end
        else
          assignfile(FTxt, name + '.txt');
          rewrite(FTxt);
          spre := '������ �����: ';   //��������� ������������� �����-�����������
          sin := '������������ �����: ';
          spost := '�������� �����: ';
          txt_strings(btree, spre, sin, spost);
          writeln(FTxt, spre);
          writeln(FTxt, sin);
          writeln(FTxt, spost);
          closefile(FTxt);
          showmessage('��������� ��� �����!');

      end;
    end;
  end
   else
   showmessage('������ �����������');

      SDBinary.FileName := '';
end;

procedure Tbinary_form.actSearchExecute(Sender: TObject);
var
temp_node: node_pointer;
level, offset, check, depth: integer;
end_atr: boolean;
begin
  if editElement.Text = '' then
  begin
    editElement.EditLabel.Font.Color := clRed;
    editElement.EditLabel.Caption := '��������� ����!';
    exit;
  end;
  check := strtoint(editElement.Text);
  if btree <> nil then
  begin
    if search(check, btree, temp_node) then
    begin
      depth := tree_depth(btree);
      image1.Canvas.pen.Width := 4; //��������� ���������� ���� ��� �������������
      image1.Canvas.Pen.Color := clRed;
      image1.Canvas.brush.Style := bsClear;
      level := 1;                   //��������� �������
      offset := image1.Width div 2; //�������� ��� �����
      temp_node := btree;
      end_atr := FALSE;
      repeat  //����, ������� ������������ ���� ������
        image1.Canvas.Ellipse(offset - 25, 100*level - 25, offset + 25, 100*level + 25);
        pause(1);
        inc(level);
        if temp_node^.key = check then
          end_atr := TRUE         //����� �� ����� � ������ ���������� ��������
        else
          if check < temp_node^.key then 
          begin
            temp_node := temp_node^.left;
            offset := offset - 30*trunc(power(2, depth - level)); //������� ��������
          end                                                    //�����
          else
          begin
            temp_node := temp_node^.right;
            offset := offset + 30*trunc(power(2, depth - level)); //������� ��������
          end;                                                   //������
      until (temp_node = nil) or end_atr;
      
      image1.Canvas.brush.Color := $cfd9ce;
      image1.Canvas.pen.Color := clBlack;
      image1.Canvas.Pen.Width := 2;    //������� � ����������� ���������� ����
      image1.canvas.Brush.style := bsSolid;
      refresh_tree(btree, image1);
      editElement.Text := '';
    end
    else
      showmessage('������� � ����� ������ �� ������');
  end
  else
    showmessage('������ ������');
end;

procedure Tbinary_form.actLoadExecute(Sender: TObject);
var
Name, temp_str: string;
F: file of TKey;
FTxt: textfile;
temp_elem: TKey;
error_code: integer;
begin
 ODBinary.InitialDir := GetCurrentDir + '/files';
 ODBinary.Filter := '�������������� |*.dat|��������� |*.txt|��� |*.*';
 if ODBinary.Execute then  //����� ���� ��������
 begin
  tree_free(btree); //������� ������������� ������
  Name := ODbinary.FileName;
   if pos('.dat', name) <> 0 then
    begin         //������ ��������������� �����
      assignfile(F, Name);
      reset(F);
      while not Eof(F) do
      begin
        read(F, temp_elem);
        include(temp_elem, btree);
      end;
      closefile(F);
    end
    else
    if pos('.txt', name) <> 0 then
    begin      //������ ���������� �����
      assignfile(FTxt, Name);
      reset(FTxt);
      repeat     //����, �������� �� ������������ �����
        if Eof(FTxt) then
        begin
          showmessage('���������� ������ �� ����� ����� ����������');
          exit;
        end;
        readln(FTxt, temp_str);  //� temp_str �������� ������ � ������ �������
      until ansilowercase(temp_str[1]) = '�';  // '������ �����: '
      delete(temp_str, 1, 14);  //�������� '������ �����: '
      repeat //���������� ������ � ��������� � ������
        val(temp_str, temp_elem, error_code); //� error_code ����� �������� ������� �������
        include(temp_elem, btree);
        delete(temp_str, 1, error_code + 1);
      until length(temp_str) = 0;
      closefile(FTxt);
    end;
 end;
 ODbinary.FileName := '';
 refresh_tree(btree, image1);
end;

procedure in_traverse(const tree: node_pointer; image: TImage);
var          //��������� ������������� ������
 depth: integer;
procedure in_order(tree: node_pointer; offset, level: integer);
  begin  //����������� ���������, �������������� ��������� �����
   if tree^.left <> nil then
    in_order(tree^.left, offset - 30*trunc(power(2, depth - (level + 1))), level + 1);

   image.Canvas.Ellipse(offset - 25, 100*level - 25, offset + 25, 100*level + 25);
   pause(1);

   if tree^.right <> nil then
    in_order(tree^.right, offset + 30*trunc(power(2, depth - (level + 1))), level + 1);
  end;
begin
  if tree <> nil then
  begin
    with image.Canvas do
    begin
      depth := tree_depth(tree);
      pen.Width := 4;
      Pen.Color := clRed;
      brush.Style := bsClear;
      binary_form.Enabled := FALSE;
      in_order(tree, image.Width div 2, 1);
      brush.Color := $cfd9ce;
      pen.Color := clBlack;
      Pen.Width := 2;
      Brush.style := bsSolid;
    end;
    pause(1);
    binary_form.enabled := TRUE;
    refresh_tree(tree, image);
  end
  else
    showmessage('������ �����������...');
end;

procedure Tbinary_form.actInorderExecute(Sender: TObject);
begin    //����� ������������� ������
  in_traverse(btree, image1);
end;

procedure Tbinary_form.actCreateExecute(Sender: TObject);
var    //�������� ���������� ������ �� n ���������
i, n: integer;
key: Tkey;
btree_res: node_pointer;
mas_str: string;
begin
  randomize;
  tree_free(btree);
  btree:=nil;
  mas_str := '';
  n := 30;
  image1.Canvas.Rectangle(0,0, image1.Width, image1.Height);
  for i := 1 to n do
  begin
    repeat
      Key := random(51);
    until not search(key, btree, btree_res);
    mas_str := mas_str + inttostr(key) + ' ';
    include(key, btree);
  end;
  image1.Canvas.Font.Size := 10;
  refresh_tree(btree, image1);
end;

procedure post_traverse(const tree: node_pointer; image: TImage);
var    //��������� ��������� ������
 depth: integer;
procedure post_order(tree: node_pointer; offset, level: integer);
  begin  //����������� ��������� ��������� ��������������� ����
   if tree^.left <> nil then
    post_order(tree^.left, offset - 30*trunc(power(2, depth - (level + 1))), level + 1);

   if tree^.right <> nil then
    post_order(tree^.right, offset + 30*trunc(power(2, depth - (level + 1))), level + 1);

   image.Canvas.Ellipse(offset - 25, 100*level - 25, offset + 25, 100*level + 25);
   pause(1);
  end;
begin
  if tree <> nil then
  begin
    depth := tree_depth(tree);
    with image.Canvas do
    begin
      Pen.Width := 4;
      Pen.Color := clRed;
      Brush.Style := bsClear;
      binary_form.Enabled := FALSE;
      post_order(tree, image.Width div 2, 1);

      brush.Color := $cfd9ce;
      pen.Color := clBlack;
      Pen.Width := 2;
      Brush.style := bsSolid;
    end;
    pause(1);
    binary_form.enabled := TRUE;
    refresh_tree(tree, image);
  end
  else
    showmessage('������ �����������...');
end;

procedure Tbinary_form.actPostOrderExecute(Sender: TObject);
begin         //����� ��������� �������
  post_traverse(btree, image1);
end;

procedure Tbinary_form.addElemExecute(Sender: TObject);
begin     //�������� ���������� ��������
  if editElement.Text = '' then
  begin       //���� ���� ������, �� ��������� ������� �� ����
    editElement.EditLabel.Font.Color := clRed;
    editElement.EditLabel.Caption := '��������� ����!'
  end
  else
  begin
    include(strtoint(editElement.text), btree);
    refresh_tree(btree, image1);
    editElement.Text := '';
  end;
end;

procedure Tbinary_form.FormClose(Sender: TObject; var Action: TCloseAction);
begin //������� ��� �������� ���� ��������
  main_menu.enabled := TRUE;
  tree_free(btree);
end;

procedure Tbinary_form.FormCreate(Sender: TObject);
begin                             //������������� ����������
  binary_form.Color := clwhite;   //����
  image1.Canvas.pen.Width := 2;
  image1.Canvas.brush.color := $cfd9ce;
  topPanel.Color := $7c8e51;      //����� �������
  bottomPanel.Color := $7c8e51;
  image1.Canvas.rectangle(0,0, image1.Width, image1.Height);
end;

procedure Tbinary_form.editElementKeyPress(Sender: TObject; var Key: Char);
begin     //� ������� ������� ������� � ���� Edit ����������� ���������� �����
 editElement.readonly := not (Key in ['0' .. '9', #8, #13]); //#8 - Delete
 if editElement.ReadOnly then  //���� �������� ������ �� �������� ����� ������
 begin                        //��������� ������� �� ���� � �� �������� ��� ������
  editElement.EditLabel.Font.Color := clRed;
  editElement.EditLabel.Caption := '���������� �����';
 end
 else
  editElement.EditLabel.Caption := '';
 //#13 - Enter
 if key = #13 then
 begin
  key := #0; //������ �� null-������ ��� �������������� ��������� �������������� �������
  addElemExecute(btnAdd);  //�������� ������� ������ "��������"
 end;
end;

end.
