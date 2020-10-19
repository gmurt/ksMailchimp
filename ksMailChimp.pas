{*******************************************************************************
*                                                                              *
*  ksMailChimp - MailChimp Interface                                           *
*                                                                              *
*  https://github.com/gmurt/ksMailChimp                                        *
*                                                                              *
*  Copyright 2015 Graham Murt                                                  *
*                                                                              *
*  email: graham@kernow-software.co.uk                                         *
*                                                                              *
*  Licensed under the Apache License, Version 2.0 (the "License");             *
*  you may not use this file except in compliance with the License.            *
*  You may obtain a copy of the License at                                     *
*                                                                              *
*    http://www.apache.org/licenses/LICENSE-2.0                                *
*                                                                              *
*  Unless required by applicable law or agreed to in writing, software         *
*  distributed under the License is distributed on an "AS IS" BASIS,           *
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    *
*  See the License for the specific language governing permissions and         *
*  limitations under the License.                                              *
*                                                                              *
*******************************************************************************}

unit ksMailChimp;

interface

uses System.Generics.Collections, JsonDataObjects, System.Net.HttpClient,
  Classes, System.Net.HttpClientComponent, System.Net.URLClient;

type
  TPostEvent = reference to procedure(Sender: TObject; AEmail: string; ASuccess: Boolean; AError: string);

  IMailChimpContact = interface
    ['{7E7B3A83-42A6-4BC4-988D-53969C63AE92}']
    function GetEmail: string;
    function GetFirstName: string;
    function GetLastName: string;
    procedure UploadJson(AJson: TJSONObject);
    procedure SetEmail(const Value: string);
    procedure SetFirstName(const Value: string);
    procedure SetLastName(const Value: string);
    property Firstname: string read GetFirstName write SetFirstName;
    property LastName: string read GetLastName write SetLastName;
    property Email: string read GetEmail write SetEmail;
  end;

  IMailChimpAudience = interface
    ['{70A2D93B-D8A2-4E1D-93A8-AF2DD155A42C}']
    function GetID: string;
    function GetMemberCount: integer;
    function GetName: string;
    procedure SetID(const Value: string);
    procedure SetName(const Value: string);
    procedure LoadFromJson(AJson: string); overload;
    procedure LoadFromJson(AJson: TJsonObject); overload;
    property ID: string read GetID write SetID;
    property Name: string read GetName write SetName;
    property MemberCount: integer read GetMemberCount;
  end;

  TMailChimpContactList = class(TList<IMailChimpContact>)
  public
    procedure AddMember(AFirstname, ASurname, AEmail: string);
  end;

  TMailChimpAudienceList = class(TList<IMailChimpAudience>)
  public
    function AddAudience: IMailChimpAudience;
    function IndexOfListID(AId: string): integer;
    procedure LoadFromJson(AJson: string);
  end;

  IksMailChimp = interface
    ['{F0CB2B37-BF05-44A4-81E4-AAD31190DF25}']
    procedure AddContact(AAudienceID: string; AContact: IMailChimpContact; AOnPost: TPostEvent);
    procedure GetAudienceList(AAudienceList: TMailChimpAudienceList);
  end;

  function CreateMailChimp(AApiKey: string): IksMailChimp;
  function CreateMailChimpContact(AFirstname, ALastname, AEmail: string): IMailChimpContact;

implementation

uses System.NetEncoding, SysUtils;

{ TContact }

type
  TMailChimpContact = class(TInterfacedObject, IMailChimpContact)
  private
    FFirstname: string;
    FLastname: string;
    FEmail: string;
    function GetEmail: string;
    function GetFirstName: string;
    function GetLastName: string;
    procedure SetEmail(const Value: string);
    procedure SetFirstName(const Value: string);
    procedure SetLastName(const Value: string);
  protected
    procedure UploadJson(AJson: TJSONObject);
    property Firstname: string read GetFirstName write SetFirstName;
    property LastName: string read GetLastName write SetLastName;
    property Email: string read GetEmail write SetEmail;
  end;

  TMailChimpAudience = class(TInterfacedObject, IMailChimpAudience)
  private
    FId: string;
    FName: string;
    FMemberCount: integer;
    function GetID: string;
    function GetMemberCount: integer;
    function GetName: string;
    procedure SetID(const Value: string);
    procedure SetName(const Value: string);
  public
    procedure LoadFromJson(AJson: string); overload;
    procedure LoadFromJson(AJson: TJsonObject); overload;
    property ID: string read GetID write SetID;
    property Name: string read GetName write SetName;
    property MemberCount: integer read GetMemberCount;
  end;

  TksMailChimp = class(TInterfacedObject, IksMailChimp)
  private
    FApiKey: string;
    FHttp: TNetHTTPClient;
    FDatacenter: string;
    function Post(AResource, AData: string): string;
  public
    constructor Create(AApiKey: string);
    destructor Destroy; override;

    procedure AddContact(AAudienceID: string; AContact: IMailChimpContact; AOnPost: TPostEvent);
    procedure GetAudienceList(AAudienceList: TMailChimpAudienceList);
    //property Lists: TMailChimpLists read FLists;
  end;




function CreateMailChimp(AApiKey: string): IksMailChimp;
begin
  Result := TksMailChimp.Create(AApiKey);
end;

function CreateMailChimpContact(AFirstname, ALastname, AEmail: string): IMailChimpContact;
begin
  Result := TMailChimpContact.Create;
  Result.Firstname := AFirstname;
  Result.LastName := ALastname;
  Result.Email := AEmail; 
end;

function TMailChimpContact.GetEmail: string;
begin
  Result := FEmail;
end;

function TMailChimpContact.GetFirstName: string;
begin
  Result := FFirstname;
end;

function TMailChimpContact.GetLastName: string;
begin
  Result := FLastname;
end;

procedure TMailChimpContact.SetEmail(const Value: string);
begin
  FEmail := Value;
end;

procedure TMailChimpContact.SetFirstName(const Value: string);
begin
  FFirstname := Value;
end;

procedure TMailChimpContact.SetLastName(const Value: string);
begin
  FLastname := Value;
end;

procedure TMailChimpContact.UploadJson(AJson: TJSONObject);
begin
  AJson.S['email_address'] := FEmail;
  AJson.S['status'] := 'subscribed';
  AJson.O['merge_fields'].S['FNAME'] := FFirstname;
  AJson.O['merge_fields'].S['LNAME'] := FLastname;
end;

{ TMailChimpContactList }

procedure TMailChimpContactList.AddMember(AFirstname, ASurname, AEmail: string);
var
  AContact: IMailChimpContact;
begin
  AContact := TMailChimpContact.Create;
  AContact.Firstname := AFirstname;
  AContact.LastName := ASurname;
  AContact.Email := AEmail;
  Add(AContact);
end;

function TksMailChimp.Post(AResource, AData: string): string;
var
  AStream: TStringStream;
  AResponse: IHTTPResponse;
begin
  AStream := TStringStream.Create(AData);
  try
    FHttp.CustomHeaders['Authorization'] := 'Basic '+ TNetEncoding.Base64.Encode('apiUser:'+FApiKey);
    AResponse := FHttp.Post('https://'+FDatacenter+'.api.mailchimp.com/3.0/'+AResource, AStream);
    Result := AResponse.ContentAsString;
  finally
    AStream.Free;
  end;
end;

procedure TksMailChimp.AddContact(AAudienceID: string; AContact: IMailChimpContact; AOnPost: TPostEvent);
var
  AJson: TJSONObject;
  AArray: TJsonArray;
  AUploadJson: TJsonObject;
  AResult: TJsonObject;
begin
  AJson := TJsonObject.Create;
  try
    AArray := AJson.A['members'];
    AUploadJson := TJsonObject.Create;
    AContact.UploadJson(AUploadJson);
    AArray.Add(AUploadJson);
    AResult := TJsonObject.Parse(Post('lists/'+AAudienceID, AJson.ToJSON)) as TJsonObject;
    try
      if AResult.I['error_count'] > 0 then
        AOnPost(Self, AContact.Email, False, AResult.A['errors'][0].S['error'])
      else
        AOnPost(Self, AContact.Email, True, '');
    finally
      AResult.Free;
    end;
  finally
    AJson.Free;
  end;
end;


procedure TksMailChimp.GetAudienceList(AAudienceList: TMailChimpAudienceList);
var
  AData: string;
  AObj: TJSONObject;
  AArray: TJSONArray;
begin
  AAudienceList.Clear;
  FHttp.CustomHeaders['Authorization'] := 'Basic '+ TNetEncoding.Base64.Encode('apiUser:'+FApiKey);

  AData := FHttp.Get('https://'+FDataCenter+'.api.mailchimp.com/3.0/lists/').ContentAsString;
  AObj := TJSONObject.Parse(AData) as TJSONObject;
  try
    AArray := AObj.A['lists'];
    AAudienceList.LoadFromJson(AArray.ToJSON);
  finally
    AObj.Free;
  end;
end;

{ TMailChimp }

function StrBefore(ASubStr, AStr: string): string;
begin
  Result := AStr;
  if Pos(ASubStr, AStr) > 0 then
    Result := Copy(AStr, 1, Pos(ASubStr, AStr));
end;

function StrAfter(ASubStr, AStr: string): string;
begin
  Result := AStr;
  if Pos(ASubStr, AStr) > 0 then
    Result := Copy(AStr, Pos(ASubStr, AStr)+1, Length(AStr));
end;

constructor TksMailChimp.Create(AApiKey: string);
begin
  FHttp := TNetHTTPClient.Create(nil);
  FApiKey := StrBefore('-', AApiKey);
  FDataCenter := StrAfter('-', AApiKey);
  if Pos('|', FDatacenter) > 0 then
    FDatacenter := StrBefore('|', FDatacenter);
end;

destructor TksMailChimp.Destroy;
begin
  FHttp.Free;
  inherited;
end;


{ TMailChimpAudience }

function TMailChimpAudience.GetID: string;
begin
  Result := FId;
end;

function TMailChimpAudience.GetMemberCount: integer;
begin
  Result := FMemberCount;
end;

function TMailChimpAudience.GetName: string;
begin
  Result := FName;
end;

procedure TMailChimpAudience.LoadFromJson(AJson: TJsonObject);
var
  AStats: TJSONObject;
begin
  FId := AJson.Values['id'].Value;
  FName := AJson.Values['name'].Value;
  AStats := AJson.O['stats'] as TJSONObject;
  FMemberCount := StrToIntDef(AStats.S['member_count'], 0);
end;

procedure TMailChimpAudience.SetID(const Value: string);
begin
  FId := Value;
end;

procedure TMailChimpAudience.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TMailChimpAudience.LoadFromJson(AJson: string);
var
  AObj: TJSONObject;
begin
  AObj := TJSONObject.Parse(AJson) as TJSONObject;
  try
    LoadFromJson(AObj);
  finally
    AObj.Free;
  end;
end;

{ TMailChimpAudienceList }

function TMailChimpAudienceList.AddAudience: IMailChimpAudience;
begin
  Result := TMailChimpAudience.Create;
  Add(Result);
end;


function TMailChimpAudienceList.IndexOfListID(AId: string): integer;
var
  ICount: integer;
begin
  Result := -1;
  for ICount := 0 to Count-1 do
  begin
    if Items[ICount].ID = AId then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

procedure TMailChimpAudienceList.LoadFromJson(AJson: string);
var
  AArray: TJSONArray;
  AList: TJSONObject;
begin
  AArray := TJsonObject.Parse(AJson) as TJSONArray;
  try
    for AList in AArray do

      AddAudience.LoadFromJson(AList);
  finally
    AArray.Free;
  end;
end;

end.
