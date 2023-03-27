{ ##
  @FILE                     PJMenuSpeedButtonsDemo.dpr
  @COMMENTS                 Project file for PJ Menu Speed Button components
                            demonstrator.
  @PROJECT_NAME             Menu speed button components demo.
  @PROJECT_DESC             Demo program for menu-related speed button
                            components by DelphiDabbler.
  @AUTHOR                   Peter Johnson, LLANARTH, Ceredigion, Wales, UK
  @COPYRIGHT                © Peter D Johnson, 2001.
  @LEGAL_NOTICE             The source code of this demo program is distributed
                            under the Mozilla Public License - see below. The
                            executable code can be freely distributed.
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
 * The Original Code is PJMenuSpeedButtonsDemo.dpr.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2001 Peter
 * Johnson. All Rights Reserved.
 * 
 * ***** END LICENSE BLOCK *****
}


program PJMenuSpeedButtonsDemo;

uses
  Forms,
  FmPJMenuSpeedButtonsDemo in 'FmPJMenuSpeedButtonsDemo.pas' {DemoForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.
