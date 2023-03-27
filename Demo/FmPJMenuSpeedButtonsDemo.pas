{ ##
  @FILE                     FmPJMenuSpeedButtonsDemo.pas
  @COMMENTS                 Demonstrator form for the PJSoft Menu Speed Button
                            components.
  @PROJECT_NAME             Menu speed button components demo.
  @PROJECT_DESC             Demo program for menu-related speed button
                            components by DelphiDabbler.
  @DEPENDENCIES             Requires components:
                            + TPJMenuSpeedButton v1.0
                            + TPJLinkedSpeedButton v1.0
                            + TPJLinkedMenuSpeedButton v1.0
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 23/06/2001
      @COMMENTS             Original version.
    )
  )
}


{
 * ***** BEGIN LICENSE BLOCK *****
 * 
 * Version: MPL 1.1
 * 
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is FmPJMenuSpeedButtonsDemo.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2001 Peter
 * Johnson. All Rights Reserved.
 * 
 * ***** END LICENSE BLOCK *****
}


unit FmPJMenuSpeedButtonsDemo;

interface

uses
  // Delphi
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, Buttons,
  // PJSoft
  PJMenuSpeedButtons;

type
  TDemoForm = class(TForm)
    pnlButtons: TPanel;
    Editor: TRichEdit;
    btnExit: TSpeedButton;
    mnuFont: TPopupMenu;
    mnuStyle: TPopupMenu;
    mfArial: TMenuItem;
    mfCourier: TMenuItem;
    mfTimes: TMenuItem;
    msBold: TMenuItem;
    msItalic: TMenuItem;
    btnStyleMenu: TPJMenuSpeedButton;
    btnFont: TPJLinkedSpeedButton;
    btnFontMenu: TPJLinkedMenuSpeedButton;
    msUnderline: TMenuItem;
    msStrikeout: TMenuItem;
    procedure msBoldClick(Sender: TObject);
    procedure msItalicClick(Sender: TObject);
    procedure mfArialClick(Sender: TObject);
    procedure mfCourierClick(Sender: TObject);
    procedure mfTimesClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuStylePopup(Sender: TObject);
    procedure msUnderlineClick(Sender: TObject);
    procedure msStrikeoutClick(Sender: TObject);
  private
    procedure ApplyFont(const FontName: string);
    procedure ChangeStyle(Style: TFontStyle; Flag: Boolean);
  end;

var
  DemoForm: TDemoForm;

implementation

uses
  // Delphi
  RichEdit;

{$R *.DFM}

procedure TDemoForm.ApplyFont(const FontName: string);
  {Apply the given font to the current selection and set font button caption to
  use selected font}
begin
  // Apply font to selection
  Editor.SelAttributes.Name := FontName;
  // Set font button caption to use currrent font
  btnFont.Font.Name := FontName;
end;

procedure TDemoForm.btnExitClick(Sender: TObject);
  {Exit the program}
begin
  Close;
end;

procedure TDemoForm.btnFontClick(Sender: TObject);
  {Apply current font}
begin
  ApplyFont(btnFont.Font.Name);
end;

procedure TDemoForm.ChangeStyle(Style: TFontStyle; Flag: Boolean);
  {Toggles the style given by Style on or off according to Flag. This method
  does not have limitations of setting SelAttributes.Style property since this
  can change styles other than the one we want}
var
  CharFormat: TCharFormat;  // info about char formatting in rich edit
  Mask: DWORD;              // determines which character elements to change
  Effects: DWORD;           // the character effect we're turning on
begin
  // Set up effects and appropriate mask
  // assume we're turning effects off
  Effects := 0;
  case Style of
    fsBold:       // we only want bold style to be affected
    begin
      Mask := CFM_BOLD;
      if Flag then Effects := CFE_BOLD;
    end;
    fsItalic:     // we only want italic style to be affected
    begin
      Mask := CFM_ITALIC;
      if Flag then Effects := CFE_ITALIC;
    end;
    fsUnderline:  // we only want underline style to be affected
    begin
      Mask := CFM_UNDERLINE;
      if Flag then Effects := CFE_UNDERLINE;
    end;
    fsStrikeOut:  // we only want strike-out style to be affected
    begin
      Mask := CFM_STRIKEOUT;
      if Flag then Effects := CFE_STRIKEOUT;
    end;
    else          // no style: affect nothing
      Mask := 0;
  end;
  // Set up char formatting structure
  FillChar(CharFormat, 0, SizeOf(TCharFormat));
  with CharFormat do
  begin
    cbSize := SizeOf(TCharFormat);
    dwMask := Mask;
    dwEffects := Effects;
  end;
  // Apply style change to selection by sending message to rich edit control
  SendMessage(Editor.Handle, EM_SETCHARFORMAT,
    SCF_SELECTION, Integer(@CharFormat));
end;

procedure TDemoForm.FormCreate(Sender: TObject);
  {Start off with Times New Roman font}
begin
  Editor.Font.Name := 'Times New Roman';
  Editor.Font.Size := 12;
  mfTimes.Click;
end;

procedure TDemoForm.mfArialClick(Sender: TObject);
  {Apply Arial font to selected text and make current}
begin
  ApplyFont('Arial');
  mfArial.Checked := True;
end;

procedure TDemoForm.mfCourierClick(Sender: TObject);
  {Apply Courier font to selected text and make current}
begin
  ApplyFont('Courier New');
  mfCourier.Checked := True;
end;

procedure TDemoForm.mfTimesClick(Sender: TObject);
  {Apply Times font to selected text and make current}
begin
  ApplyFont('Times New Roman');
  mfTimes.Checked := True;
end;

procedure TDemoForm.mnuStylePopup(Sender: TObject);
  {Check style menu items per current selection}
begin
  msBold.Checked := fsBold in Editor.SelAttributes.Style;
  msItalic.Checked := fsItalic in Editor.SelAttributes.Style;
  msStrikeout.Checked := fsStrikeOut in Editor.SelAttributes.Style;
  msUnderline.Checked := fsUnderline in Editor.SelAttributes.Style;
end;

procedure TDemoForm.msBoldClick(Sender: TObject);
  {Toggle bold style in selected text}
begin
  if fsBold in Editor.SelAttributes.Style then
    ChangeStyle(fsBold, False)
  else
    ChangeStyle(fsBold, True);
end;

procedure TDemoForm.msItalicClick(Sender: TObject);
  {Toggle italic style in selected text}
begin
  if fsItalic in Editor.SelAttributes.Style then
    ChangeStyle(fsItalic, False)
  else
    ChangeStyle(fsItalic, True);
end;

procedure TDemoForm.msStrikeoutClick(Sender: TObject);
  {Toggle strike-out style in selected text}
begin
  if fsStrikeOut in Editor.SelAttributes.Style then
    ChangeStyle(fsStrikeOut, False)
  else
    ChangeStyle(fsStrikeOut, True);
end;

procedure TDemoForm.msUnderlineClick(Sender: TObject);
  {Toggle underline style in selected text}
begin
  if fsUnderline in Editor.SelAttributes.Style then
    ChangeStyle(fsUnderline, False)
  else
    ChangeStyle(fsUnderline, True);
end;

end.
