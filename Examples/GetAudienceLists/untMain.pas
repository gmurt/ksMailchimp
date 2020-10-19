unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ksMailChimp;

type
  TForm10 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Panel1: TPanel;
    Edit1: TEdit;
    Label1: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FAudiences: TMailChimpAudienceList;
    function GetSelectedAudience: IMailChimpAudience;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SelectedAudience: IMailChimpAudience read GetSelectedAudience;
    { Public declarations }

  end;

var
  Form10: TForm10;

implementation

const
  C_MAILCHIMP_API_KEY = '************************************';

{$R *.dfm}



procedure TForm10.Button1Click(Sender: TObject);
var
  AMailChimp: IksMailchimp;
  AAudience: IMailChimpAudience;
begin
  if Pos('*', C_MAILCHIMP_API_KEY) > 0 then
  begin
    ShowMessage('Please add your Mailchimp API key to the C_MAILCHIMP_API_KEY const in untMain.pas');
    Exit;
  end;

  ListBox1.Items.Clear;
  AMailChimp := CreateMailChimp(C_MAILCHIMP_API_KEY);
  AMailChimp.GetAudienceList(FAudiences);
  for AAudience in FAudiences do
    ListBox1.Items.AddObject(AAudience.Name+'  ('+IntToStr(AAudience.MemberCount)+')', TObject(AAudience));
end;

procedure TForm10.Button2Click(Sender: TObject);
var
  AMailChimp: IksMailChimp;
  AContact: IMailChimpContact;
begin
  if ListBox1.ItemIndex = -1 then
  begin
    ShowMessage('Please select an audience.');
    Exit;
  end;

  AMailChimp := CreateMailChimp(C_MAILCHIMP_API_KEY);
  AContact := CreateMailChimpContact('', '', Edit1.Text);
  AMailChimp.AddContact(SelectedAudience.ID, AContact,
    procedure(Sender: TObject; AEmail: string; ASuccess: Boolean; AError: string)
    begin
      if AError <> '' then
        ShowMessage(AError)
      else
        ShowMessage(AEmail+' added successfully');
    end
  );
end;

constructor TForm10.Create(AOwner: TComponent);
begin
  inherited;
  FAudiences := TMailChimpAudienceList.Create;
end;

destructor TForm10.Destroy;
begin
  FAudiences.Free;
  inherited;
end;

function TForm10.GetSelectedAudience: IMailChimpAudience;
begin
  Result := nil;
  if ListBox1.ItemIndex > -1 then
    Supports(ListBox1.Items.Objects[ListBox1.ItemIndex], IMailChimpAudience, Result);
end;

end.
