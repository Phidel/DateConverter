unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, scControls, scGPControls,
  scGPExtControls;

type
  TMainForm = class(TForm)
    FloatEdit: TscEdit;
    DateTimeEdit: TscEdit;
    UnixEdit: TscEdit;
    msCheckBox: TscCheckBox;
    DigitsLabel: TscLabel;
    NowButton: TscButton;
    scGPMonthCalendar1: TscGPMonthCalendar;
    scGPTimeEdit1: TscGPTimeEdit;
    JulianEdit: TscEdit;
    scLabel1: TscLabel;
    scLabel2: TscLabel;
    procedure FloatEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UnixEditChange(Sender: TObject);
    procedure msCheckBoxClick(Sender: TObject);
    procedure NowButtonClick(Sender: TObject);
    procedure scGPMonthCalendar1Click(Sender: TObject);
    procedure scGPTimeEdit1Change(Sender: TObject);
  private
    procedure UpdateControls;
  public
    CurDate: TDateTime; // что хотим рисовать - реальная дата
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


uses DateUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.UpdateFormatSettings := false;
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.DateSeparator := '.';
  CurDate := Now;
  UpdateControls;
end;

procedure TMainForm.msCheckBoxClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TMainForm.NowButtonClick(Sender: TObject);
begin
  CurDate := Now;
  UpdateControls;
end;

procedure TMainForm.scGPMonthCalendar1Click(Sender: TObject);
begin
  CurDate := scGPMonthCalendar1.Date + TimeOf(CurDate);
  UpdateControls;
end;

procedure TMainForm.scGPTimeEdit1Change(Sender: TObject);
begin
  CurDate := trunc(CurDate) + scGPTimeEdit1.TimeValue;
  UpdateControls;
end;

const
  // Sets UnixStartDate to TDateTime of 01/01/1970
  UnixStartDate: TDateTime = 25569.0;

function DateTimeToUnix(ConvDate: TDateTime; ms: boolean): Int64;
begin
  Result := Round((ConvDate - UnixStartDate) * 86400);
  // 86400 = 24*60*60 - secs in one day
  if ms then begin
    Result := Result * 1000 + DateUtils.MilliSecondOf(ConvDate);
  end;
end;

// todo utc offset

// есть аналогичная DateUtils.UnixToDateTime(const AValue: Int64; AReturnUTC: Boolean)
function UnixToDateTime(USec: Int64): TDateTime;
begin
  // Example: UnixToDateTime(1003187418); - 10 цифр (без миллисек)

  Result := (USec / 86400) + UnixStartDate;
end;

procedure TMainForm.UpdateControls;
var
  unixvalue: Int64;
  fmt: string;
begin
  unixvalue := DateTimeToUnix(CurDate, msCheckBox.Checked);

  UnixEdit.OnChange := nil;
  UnixEdit.Text := unixvalue.ToString;
  DigitsLabel.Caption := Length(trim(UnixEdit.Text)).ToString;
  UnixEdit.OnChange := UnixEditChange;

  if msCheckBox.Checked then
    fmt := 'dd.mm.yyyy hh:nn:ss.zzz'
  else
    fmt := 'dd.mm.yyyy hh:nn:ss';

  FloatEdit.OnChange := nil;
  if msCheckBox.Checked then
    FloatEdit.Text := FloatToStr(CurDate)
  else
    FloatEdit.Text := FloatToStr(CurDate -
      MilliSecondOf(CurDate) * OneMillisecond);
  FloatEdit.OnChange := FloatEditChange;

  DateTimeEdit.Text := FormatDateTime(fmt, CurDate);

  JulianEdit.Text := System.DateUtils.DateTimeToJulianDate(CurDate).ToString;
end;

procedure TMainForm.FloatEditChange(Sender: TObject);
begin
  CurDate := StrToFloatDef(FloatEdit.Text, 0);
  UpdateControls;
end;

procedure TMainForm.UnixEditChange(Sender: TObject);
var
  i: Int64;
  len: integer;
  s: string;
begin
  s := trim(UnixEdit.Text);
  len := Length(s);
  if len <= 11 then begin // no ms
    i := StrToInt64Def(s, 0);
    CurDate := UnixToDateTime(i);
  end
  else begin // 3 last digits = ms
    i := StrToInt64Def(copy(s, 1, len - 3), 0);
    CurDate := UnixToDateTime(i) +
      StrToIntDef(copy(s, len - 2, 3), 0) / 1000 / 24 / 60 / 60;
  end;
  UpdateControls;
end;

end.
