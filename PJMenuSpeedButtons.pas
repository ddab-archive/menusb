{ ##
  @FILE                     PJMenuSpeedButtons.pas
  @COMMENTS                 Source code for components
  @PROJECT_NAME             Menu-related speed buttons
  @PROJECT_DESC             A set of speed button derived components that either
                            display associated menus or form button / menu
                            button groups.
  @AUTHOR                   Peter Johnson, LLANARTH, Ceredigion, Wales, UK
  @OWNER                    DelphiDabbler
  @WEBSITE                  http://www.delphidabbler.com/
  @COPYRIGHT                © Peter D Johnson, 2001-2007.
  @LEGAL_NOTICE             These components are distributed under the Mozilla
                            Public License - see below.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 17/03/2001
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 11/09/2003
      @COMMENTS             Changed component palette from "PJ Stuff" to
                            "DelphiDabbler".
    )
    @REVISION(
      @VERSION              1.2
      @DATE                 14/08/2007
      @COMMENTS             + Added new AlignMenuToMaster property to
                              TPJLinkedMenuSpeedButton to enable the active menu
                              of a TPJLinkedMenuSpeedButton to display either
                              under the TPJLinkedMenuSpeedButton (default) or
                              under the attached TPJLinkedSpeedButton.
                            + Added new TriggerDefMenuItem property to
                              TPJLinkedSpeedButton that causes the default menu
                              item of the active menu of an attached
                              TPJLinkedMenuSpeedButton to be triggered when the
                              TPJLinkedSpeedButton is clicked.
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
 * The Original Code is PJMenuSpeedButtons.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2001-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): none
 *
 * ***** END LICENSE BLOCK *****
}


unit PJMenuSpeedButtons;


interface


uses
  // Delphi
  Windows, Graphics, Messages, Classes, Controls, Buttons, Menus;


const
  // Custom messages processsed by components in this unit
  PJM_LMOUSEDOWN      = WM_USER + 1;
  PJM_LMOUSEMOVE      = WM_USER + 2;
  PJM_LMOUSEUP        = WM_USER + 3;
  PJM_CAPTURECONTROL  = WM_USER + 4;
  PJM_ATTACH          = WM_USER + 5;

type

  {
  TPJMenuPlacing:
    Where a menu is placed relative to a menu button.
  }
  TPJMenuPlacing = (
    mpTopLeft,      // top-left of menu in same place as top-left of button
    mpBottomLeft,   // menu appears below button, aligned to button left
    mpTopRight,     // menu appear to right of button, aligned to button top
    mpBottomRight   // top-left of menu adjacent to bottom-right of button
  );


  {
  TPJUngroupedSpeedButton:
    Class of speed button which is never grouped with others: GroupIndex
    property is always 0.
  }
  TPJUngroupedSpeedButton = class(TSpeedButton)
  private
    procedure SetGroupIndex(const Value: Integer);
      {Write access method for reimplemented GroupIndex property. Discards given
      value.
        @param Value [in] Ignored.
      }
    function GetGroupIndex: Integer;
      {Read access method for reimplemented GroupIndex property. Ignores any
      inherited value.
        @return 0.
      }
  published
    { Redefined property inherited from base class}
    property GroupIndex: Integer
      read GetGroupIndex write SetGroupIndex default 0;
      {This property is effectively disabled. It always has value 0 to prevent
      the button being made part of a radio group with other buttons since this
      makes no sense}
  end;


  {
  TPJCustomMenuSpeedButton:
    A speed button that has ability to display a linked popup menu. This base
    class defines but does not publish new properties. Descendent classes may
    publish required properties.
  }
  TPJCustomMenuSpeedButton = class(TPJUngroupedSpeedButton)
  private
    fReleaseButton: Boolean;
      {Value of ReleaseButton property}
    fActiveMenu: TPopupMenu;
      {Value of ActiveMenu property}
    fMenuPlacing: TPJMenuPlacing;
      {Value of MenuPlacing property}
    fInhibitClick: Boolean;
      {When this flag is true the Click method does nothing: used to prevent
      OnClick event from firing}
    procedure SetActiveMenu(const Value: TPopupMenu);
      {Write access method for ActiveMenu property. Records reference to new
      menu and informs new menu that this object needs to be informed if the
      menu is freed.
        @param Value [in] Reference to new active menu.
      }
  protected
    property ActiveMenu: TPopupMenu
      read fActiveMenu write SetActiveMenu;
      {Reference to the menu that is popped up by this button}
    property ReleaseButton: Boolean
      read fReleaseButton write fReleaseButton default False;
      {When false the speed button remains depressed while menu is displayed and
      released only when menu is closed. When true the speed button is
      immediately returned to its "up" state as soon as mouse button is
      released}
    property MenuPlacing: TPJMenuPlacing
      read fMenuPlacing write fMenuPlacing default mpBottomLeft;
      {Determines where the top left of the popup menu is placed relative to the
      speed button}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
      {Method called when user releases mouse button after clicking speed
      button. Constructs and then pops-up any menu. Also ensures that OnClick
      event is fired just before menu appears.
        @param Button [in] Mouse button pressed.
        @param Shift [in] State of various shift keys.
        @param X [in] X co-ordinate of mouse pointer.
        @param Y [in] Y co-ordinate of mouse pointer.
      }
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
      {Resets reference to ActiveMenu to nil if the associated popup menu
      component is being freed.
        @param AComponent [in] Component triggering this notification.
        @param Operation [in] Whether component being added or removed.
      }
    procedure DisplayMenu(Pos: TPoint); virtual;
      {Pops up any attached active menu.
        @param Pos [in] Position to display menu.
      }
    function PopupPosition: TPoint; virtual;
      {Finds the position where the attached active menu is to be displayed.
        @return Required position in screen co-ordinates.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Sets default values.
        @param AOwner [in] Reference to owning control.
      }
    procedure Click; override;
      {Override of method that triggers OnClick event and / or Action's
      OnExecute event. The events may be inhibited in some circumstances to
      ensure that they are fired immediately before menu appears.
      }
  end;


  {
  TPJMenuSpeedButton:
    A speed button that has ability to display a linked popup menu - publishes
    new properties defined in TPJCustomMenuSpeedButton.
  }
  TPJMenuSpeedButton = class(TPJCustomMenuSpeedButton)
  published
    // Newly published inherited properties
    property ActiveMenu;
    property ReleaseButton;
    property MenuPlacing;
  end;


  TPJLinkedSpeedButton = class;


  {
  TPJLinkedMenuSpeedButton:
    A popup menu displaying speed button that can be associated and work in
    partnership with a master speed button. This button acts as an extension of
    master button when mastrer button is activated or clicked, but acts
    independently when this button itself is clicked.
  }
  TPJLinkedMenuSpeedButton = class(TPJCustomMenuSpeedButton)
  private
    fMasterButton: TPJLinkedSpeedButton;
      {Value of Master button property}
    fUseDefaultGlyph: Boolean;
      {Value of UseDefaultGlyph property}
    fAlignMenuToMaster: Boolean;
      {Value of AlignMenuToMaster property}
    fMouseMoveEventStore: TMouseMoveEvent;
      {Stores reference to OnMouseMove event handler when mouse events
      inhibited}
    fMouseDownEventStore: TMouseEvent;
      {Stores reference to OnMouseDown event handler when mouse events
      inhibited}
    fMouseUpEventStore: TMouseEvent;
      {Stores reference to OnMouseUp event handler when mouse events inhibited}
    fMouseClickEventStore: TNotifyEvent;
      {Stores reference to OnClick event handler when mouse events inhibited}
    fMouseDblClickEventStore: TNotifyEvent;
      {Stores reference to OnDblClick event handler when mouse events inhibited}
    fControlCaptured: Boolean;
      {Flag that, when true, indicates that this control's mouse events are
      being artificially controlled by master speed button and should not be
      fired}
    fGlyphStyle: Integer;
      {Type of glyph currently assigned: required when loading from form file}
    function GetFlat: Boolean;
      {Replacement read access method for Flat property. Simply calls inherited
      method.
        @return Value of Flat property.
      }
    procedure SetFlat(const Value: Boolean);
      {Replacement write access method for Flat property. If there's an
      associated master button, the value is only changed if new value matches
      that of master button.
        @param Value [in] Requested new value of Flat property.
      }
    procedure SetUseDefaultGlyph(const Value: Boolean);
      {Write access method for UseDefaultGlyph property. If value is true then
      the default glyph is loaded into the Glyph property and if false any
      existing Glyph is deleted. On loading the component, if value is true
      (default) default glyph won't be in form file, so default glyph created in
      contructor is used (there is no Glyph in form file to overwrite it). If
      value is false on loading there could be a Glyph in form file that would
      be deleted by this method since this property will be stored in form file
      and property is loaded after Glyph, so we defer any deletion to Loaded
      method when we will know if there's been a Glyph loaded.
        @param Value [in] New property value.
      }
    function GetGlyph: TBitmap;
      {Replacement read access method for Glyph property.
        @return Value of inherited Glyph property.
      }
    procedure SetGlyph(const Value: TBitmap);
      {Replacement write access method for Glyph property. Sets Glyph and records
      that we're not using default glyph.
        @param Value [in] New bitmap to used as glyph.
      }
    function StoreGlyph: Boolean; // storage specifier
      {Checks if Glyph property should be streamed to form resource by designer.
      Glyph is only stored if it's not the DefaultGlyph.
        @return True if Glyph property to be stored and false if not.
      }
    procedure EnableMouseEvents(Flag: Boolean);
      {Disables or restores this button's mouse event handler.
        @param Flag [in] Flag true when mouse events being restored, false when
          disabled.
      }
    procedure SetControlCaptured(Flag: Boolean);
      {Sets flag that shows if control is captured (ie mouse events are taken
      over by any associated master button). Disable/enables mouse events
      depending on whether captured.
        @param Flag [in] Flag true when control being captured, false when
          released.
      }
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
      {Override of notification method to set reference to master button to nil
      when button is destroyed.
        @param AComponent [in] Component triggering this notification.
        @param Operation [in] Whether component being added or removed.
      }
    procedure Loaded; override;
      {Override of loaded method that checks if we must destroy the initial
      default glyph in cases where no glyph is required.
      }
    procedure DisplayMenu(Pos: TPoint); override;
      {Inhibits display of menu by MouseUp method when control is captured and
      adjusts location menu is displayed according to AlignMenuToMaster
      property.
        @param Pos [in] Requested position to display menu.
      }
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
      {CM_MOUSEENTER message handler. Does inherited processing then passes
      message on to any attached master button. Message passed on is specially
      customised to prevent infinite recursion. This handler is required to
      switch on highlighting on two associated buttons at same time.
        @param Msg [in/out] Details of message.
      }
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      {CM_MOUSELEAVE message handler. Does inherited processing then passes
      message on to any attached master button. Message is specially cutomised
      to prevent infinite recursion. This handler is required to switch off
      highlighting on two associated buttons at same time.
        @param Msg [in/out] Details of message.
      }
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
      {CM_ENABLEDCHANGED message handler. If any master button is disabled then
      this button must also remain disabled.
        @param Msg [in/out] Details of message.
      }
    procedure LoadDefGlyph; virtual;
      {Loads the default glyph from resources into the Glyph property.
      }
    procedure GlyphChange(Sender: TObject); virtual;
      {Handles event triggered when Glyph property changes. Assumes that the
      glyph that has been set is user provided. If this is not the case then
      other code changes this value.
        @param Sender [in] Not used.
      }
    procedure PJMLMouseDown(var Msg: TMessage); message PJM_LMOUSEDOWN;
      {Traps custom PJM_LMOUSEDOWN message, which calls MouseDown event with
      info from message. Can be used to simulate mouse down events on and off
      the button to force button down, even when mouse is over attached master
      button. Only works when control's mouse events are captured by master
      button.
        @param Msg [in/out] Contains information about mouse position and shift
          keys. Data is not changed.
      }
    procedure PJMLMouseUp(var Msg: TMessage); message PJM_LMOUSEUP;
      {Traps custom PJM_LMOUSEUP message, which calls MouseUp event with info
      from message. Can be used to simulate mouse up events on and off the
      button to release button even when mouse is attached master button. Only
      works when control's mouse events are captured by master button.
        @param Msg [in/out] Contains information about mouse position and shift
          keys. Data is not changed.
      }
    procedure PJMLMouseMove(var Msg: TMessage); message PJM_LMOUSEMOVE;
      {Traps custom PJM_LMOUSEMOVE message, which calls MouseMove event with
      info from message. Can be used to simulate mouse move events on and off
      the button to keep button down when mouse over master button. Only works
      when control's mouse events are captured by master button
        @param Msg [in/out] Contains information about mouse position and shift
          keys. Data is not changed.
      }
    procedure PJMCaptureControl(var Msg: TMessage); message PJM_CAPTURECONTROL;
      {Traps custom PJM_CAPTURECONTROL message. This message is sent by any
      attached master button to permit false mouse messages to be sent to
      control the state of this button, and also to inhibit this button from
      firing mouse events.
        @param Msg [in/out] WParam field contains 1 to capture control or 0 to
          release it. Data is not changed.
      }
    procedure PJMAttach(var Msg: TMessage); message PJM_ATTACH;
      {Traps custom PJM_ATTACH message. This message is sent by a master button
      when it wishes to attach to or detach from the menu button.
        @param Msg [in/out] WParam field contains contains reference to master
          button object. Data is not changed.
      }
    procedure Attach(AButton: TPJLinkedSpeedButton); virtual;
      {Attaches or detaches this button as slave button of given master button.
        @param AButton [in] Reference to master button to attach to or nil if
          button is to be detached.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Sets up object and its default values.
        @param AOwner [in] Owning control.
      }
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
      {Override that only permits changes in width when button is associated
      with a master button.
        @param ALeft [in] Requested value of Left property.
        @param ATop [in] Requested value of Top property.
        @param AWidth [in] Requested value of Width property.
        @param AHeight [in] Requested value of Height property.
      }
    property MasterButton: TPJLinkedSpeedButton read fMasterButton;
      {Read only property that provides reference to this control's master
      button or nil if there is no associated master button}
  published
    { Redefined properties }
    property Flat: Boolean
      read GetFlat write SetFlat;
    property Glyph: TBitmap
      read GetGlyph write SetGlyph stored StoreGlyph;
    { Published inherited properties }
    property ActiveMenu;
    property ReleaseButton;
    { New properties }
    property UseDefaultGlyph: Boolean
      read fUseDefaultGlyph write SetUseDefaultGlyph default True;
      {Flag indicating whether button's default glyph is to be used}
    property AlignMenuToMaster: Boolean
      read fAlignMenuToMaster write fAlignMenuToMaster default False;
      {Flag indicating whether menu is to be aligned to this button or any
      linked master button. If there is no master button the property is
      ignored}
  end;


  {
  TPJLinkedSpeedButton:
    A speed button that can work in association with a linked slave popup menu
    speed button. When this button is activated or clicked it captures the slave
    button and makes it act as if part of this button.
  }
  TPJLinkedSpeedButton = class(TPJUngroupedSpeedButton)
  private
    fMenuButton: TPJLinkedMenuSpeedButton;
      {Value of MenuButton property}
    fTriggerDefMenuItem: Boolean;
      {Value of TriggerDefMenuItem property}
    procedure SetMenuButton(const Value: TPJLinkedMenuSpeedButton);
      {Write access method for MenuButton property. Records new value, detaches
      any existing menu button and attaches any new one.
        @param New property value: may be nil to unlink from menu button.
      }
    function GetFlat: Boolean;
      {Replacement read access method for Flat property. Simply calls inherited
      method.
        @return Value of Flat property.
      }
    procedure SetFlat(const Value: Boolean);
      {Replacement write access method for Flat property. If there's an
      associated menu button, its Flat property is changed in tandem with this
      one.
        @param Value [in] Requested new value of Flat property.
      }
    procedure CaptureMenuBtn(Flag: Boolean);
      {Captures or releases the mouse events of the menu button by sending
      custom message. On receiving message menu button disables its mouse events
      if captured or reactivates them when released.
        @param Flag [in] True to capture mouse button, false to release it.
      }
    procedure MouseMsgToMenuBtn(Msg: Word; Shift: TShiftState; X, Y: Integer);
      {Sends a mouse message to attached menu button.
        @param Msg [in] Type of message.
        @param Shift [in] Key shift state.
        @param X [in] X co-ordinate of mouse cursor.
        @param Y [in] Y co-ordinate of mouse cursor.
      }
    procedure AttachMenuBtn(Btn: TPJLinkedMenuSpeedButton);
      {Sends a PJM_ATTACH message to a menu button. This causes the menu button
      to attach itself to this button.
        @param Btn [in] Reference to menu button that is to attach itself. If
          Btn is nil no action is taken.
      }
    procedure DetachMenuBtn(Btn: TPJLinkedMenuSpeedButton);
      {Sends a PJM_ATTACH message to a menu button. This causes the menu button
      to detach itself from this button.
        @param Btn [in] Reference to menu button that is to detach itself. If
          Btn is nil no action is taken.
      }
    function DoDefMenuItem(const Menu: TPopupMenu): Boolean;
      {Triggers (clicks) any default menu item of a given popup menu.
        @param Menu [in] Popup menu whose default menu item is to be triggered.
        @return True if default menu item exists, False if not.
      }
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
      {Override of Mouse down method that causes the button to be pressed. When
      this happens we also want any associated menu button to be depressed, but
      not to fire any of its own mouse events.
        @param Button [in] Mouse button pressed.
        @param Shift [in] State of various shift keys.
        @param X [in] X co-ordinate of mouse pointer.
        @param Y [in] Y co-ordinate of mouse pointer.
      }
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
      {Override of MouseUp method. If the method is triggerd when the mouse is
      over this button then the button is restored and the OnClick event is
      fired. If the mouse is released over any attached menu button, we still
      want this processing to occur and our button's OnClick tevent to fire. We
      also wish to release the attached menu button, which will have been
      depressed by MouseDown method.
        @param Button [in] Mouse button pressed.
        @param Shift [in] State of various shift keys.
        @param X [in] X co-ordinate of mouse pointer.
        @param Y [in] Y co-ordinate of mouse pointer.
      }
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      {Override of MouseMove method. Normally if mouse tracks off the button the
      button is restored to its normal state without firing an OnClick event.
      Where we have an attached menu button we need to adapt this default
      processing as follows: when mouse is moved over this button we do default
      processing; when mouse is moved over menu button we act as if over this
      button; when mouse is moved off both buttons we restore both buttons; when
      mouse is dragged back over these buttons after moving off we depress both
      buttons again.
        @param Shift [in] State of various shift keys.
        @param X [in] X co-ordinate of mouse pointer.
        @param Y [in] Y co-ordinate of mouse pointer.
      }
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
      {Resets reference to MenuButton to nil if the associated button is
      destroyed.
        @param AComponent [in] Component triggering this notification.
        @param Operation [in] Whether component being added or removed.
      }
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
      {CM_MOUSEENTER message handler. Acts on message and passes it on to any
      attached menu button. This handler is required to switch on highlighting
      on two associated buttons at same time.
        @param Msg [in/out] Contains message information.
      }
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      {CM_MOUSELEAVE message handler. Acts on message then passes it on to any
      attached menu button. This handler is required to switch on highlighting
      on two associated buttons at same time.
        @param Msg [in/out] Contains message information.
      }
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
      {CM_ENABLEDCHANGED message handler. Does inherited processing the sets
      Enabled property of any attached menu button to be same as this button.
        @param Msg [in/out] Contains message information.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Sets up button object.
        @param AOwner [in] Owning control.
      }
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
      {Override that adjusts position and size of any associated menu button to
      match stay attached to this button.
        @param ALeft [in] Requested value of Left property.
        @param ATop [in] Requested value of Top property.
        @param AWidth [in] Requested value of Width property.
        @param AHeight [in] Requested value of Height property.
      }
    procedure Click; override;
      {Overrides default Click method to trigger default menu item of active
      menu of any attached menu button. Note that this button's OnClick event
      and any assigned action are not executed if default menu item is found.
      }
  published
    { Redefined property }
    property Flat: Boolean
      read GetFlat write SetFlat;
    { New properties }
    property MenuButton: TPJLinkedMenuSpeedButton
      read fMenuButton write SetMenuButton;
      {Reference to any associated menu speed button or nil if no such button}
    property TriggerDefMenuItem: Boolean
      read fTriggerDefMenuItem write fTriggerDefMenuItem;
      {When true causes the default menu item of the active menu of any linked
      menu button to be triggered when the control is clicked. Ignored if there
      is no linked menu button or the menu button has no active menu or the
      active menu has no default menu item}
  end;


procedure Register;
  {Registers the components with Delphi.
  }


implementation


uses
  // Delphi
  Forms;


{$R PJMenuSpeedButtons.res} // default linked menu speed button glyph


procedure Register;
  {Registers the components with Delphi.
  }
begin
  RegisterComponents(
    'DelphiDabbler',
    [TPJMenuSpeedButton, TPJLinkedSpeedButton, TPJLinkedMenuSpeedButton]
  );
end;


{ TPJUngroupedSpeedButton }

function TPJUngroupedSpeedButton.GetGroupIndex: Integer;
  {Read access method for reimplemented GroupIndex property. Ignores any
  inherited value.
    @return 0.
  }
begin
  Result := 0;
end;

procedure TPJUngroupedSpeedButton.SetGroupIndex(const Value: Integer);
  {Write access method for reimplemented GroupIndex property. Discards given
  value.
    @param Value [in] Ignored.
  }
begin
  // Do nothing
end;


{ TPJCustomMenuSpeedButton }

procedure TPJCustomMenuSpeedButton.Click;
  {Override of method that triggers OnClick event and / or Action's OnExecute
  event. The events may be inhibited in some circumstances to ensure that they
  are fired immediately before menu appears.
  }
begin
  if not fInhibitClick then
    inherited Click;
end;

constructor TPJCustomMenuSpeedButton.Create(AOwner: TComponent);
  {Class constructor. Sets default values.
    @param AOwner [in] Reference to owning control.
  }
begin
  inherited Create(AOwner);
  fInhibitClick := False;
  fReleaseButton := False;
  fActiveMenu := nil;
  fMenuPlacing := mpBottomLeft;
end;

procedure TPJCustomMenuSpeedButton.DisplayMenu(Pos: TPoint);
  {Pops up any attached active menu.
    @param Pos [in] Position to display menu.
  }
begin
  if Assigned(fActiveMenu) then
    fActiveMenu.Popup(Pos.X, Pos.Y);
end;

procedure TPJCustomMenuSpeedButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  {Method called when user releases mouse button after clicking speed button.
  Constructs and then pops-up any menu. Also ensures that OnClick
  event is fired just before menu appears.
    @param Button [in] Mouse button pressed.
    @param Shift [in] State of various shift keys.
    @param X [in] X co-ordinate of mouse pointer.
    @param Y [in] Y co-ordinate of mouse pointer.
  }
begin
  // Stop activation of any OnClick event triggered by inherited MouseUp method
  fInhibitClick := True;
  // Check if mouse up is over button: only display menu if so
  if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
  begin
    // Mouse cursor is over button
    // trigger an OnClick event before menu appears
    if Button = mbLeft then
      inherited Click;
    if fReleaseButton then
      // restore button to up state before menu appears
      inherited MouseUp(Button, Shift, X, Y);
    if (Button = mbLeft) and not (csDesigning in ComponentState) then
      // display the menu
      DisplayMenu(ClientToScreen(PopupPosition));
    if not fReleaseButton then
      // restore button to up state after menu is closed
      inherited;
    // allow activation of any Click methods
    fInhibitClick := False;
  end
  else
    // Mouse button not over button: no menu, just restore button state
    inherited;
end;

procedure TPJCustomMenuSpeedButton.Notification(AComponent: TComponent;
  Operation: TOperation);
  {Resets reference to ActiveMenu to nil if the associated popup menu component
  is being freed.
    @param AComponent [in] Component triggering this notification.
    @param Operation [in] Whether component being added or removed.
  }
begin
  if (AComponent = fActiveMenu) and (Operation = opRemove) then
    fActiveMenu := nil;
end;

function TPJCustomMenuSpeedButton.PopupPosition: TPoint;
  {Finds the position where the attached active menu is to be displayed.
    @return Required position in screen co-ordinates.
  }
begin
  case fMenuPlacing of
    mpTopLeft:      Result := Point(0, 0);
    mpTopRight:     Result := Point(Width, 0);
    mpBottomLeft:   Result := Point(0, Height);
    mpBottomRight:  Result := Point(Width, Height);
  end;
end;

procedure TPJCustomMenuSpeedButton.SetActiveMenu(const Value: TPopupMenu);
  {Write access method for ActiveMenu property. Records reference to new menu
  and informs new menu that this object needs to be informed if the menu is
  freed.
    @param Value [in] Reference to new active menu.
  }
begin
  if Value <> fActiveMenu then
  begin
    fActiveMenu := Value;
    if Assigned(fActiveMenu) then
      fActiveMenu.FreeNotification(Self);
  end;
end;


{ TPJLinkedMenuSpeedButton }

const
  // Type of current glyph
  GS_DEFAULT = 1;   // default glyph
  GS_USER = 2;      // user provided glyph (may be nil)

procedure TPJLinkedMenuSpeedButton.Attach(AButton: TPJLinkedSpeedButton);
  {Attaches or detaches this button as slave button of given master button.
    @param AButton [in] Reference to master button to attach to or nil if button
      is to be detached.
  }
begin
  // Check if value has changed
  if fMasterButton <> AButton then
  begin
    // Detach self from any existing master button
    if Assigned(fMasterButton) then
      fMasterButton.MenuButton := nil;
    // Record new master button (if any)
    fMasterButton := AButton;
    if Assigned(AButton) then
    begin
      // Move self to same parent control as master button if necessary
      if Parent <> AButton.Parent then
        Parent := AButton.Parent;
      // Align to new master button's RHS
      SetBounds(0, 0, Width, 0);  // SetBounds uses fMasterButton's size and pos
      // Make own flat and enabled properties same as master
      Flat := AButton.Flat;
      Enabled := AButton.Enabled;
    end;
  end;
end;

procedure TPJLinkedMenuSpeedButton.CMEnabledChanged(var Msg: TMessage);
  {CM_ENABLEDCHANGED message handler. If any master button is disabled then this
  button must also remain disabled.
    @param Msg [in/out] Details of message.
  }
begin
  inherited;
  if Assigned(fMasterButton) and not fMasterButton.Enabled then
    Enabled := False;
end;

procedure TPJLinkedMenuSpeedButton.CMMouseEnter(var Msg: TMessage);
  {CM_MOUSEENTER message handler. Does inherited processing then passes message
  on to any attached master button. Message passed on is specially customised to
  prevent infinite recursion. This handler is required to switch on highlighting
  on two associated buttons at same time.
    @param Msg [in/out] Details of message.
  }
begin
  inherited;
  if MouseInControl and Assigned(fMasterButton) then
    fMasterButton.Perform(CM_MOUSEENTER, 1, 0);
end;

procedure TPJLinkedMenuSpeedButton.CMMouseLeave(var Msg: TMessage);
  {CM_MOUSELEAVE message handler. Does inherited processing then passes message
  on to any attached master button. Message is specially cutomised to prevent
  infinite recursion. This handler is required to switch off highlighting on two
  associated buttons at same time.
    @param Msg [in/out] Details of message.
  }
begin
  inherited;
  if Assigned(fMasterButton) then
    fMasterButton.Perform(CM_MOUSELEAVE, 1, 0);
end;

constructor TPJLinkedMenuSpeedButton.Create(AOwner: TComponent);
  {Class constructor. Sets up object and its default values.
    @param AOwner [in] Owning control.
  }
begin
  inherited Create(AOwner);
  // Set change event handler for Glyph
  Glyph.OnChange := GlyphChange;
  // Set default values
  Width := 14;
  fMasterButton := nil;
  fControlCaptured := False;
  // create and set initial default glyph
  SetUseDefaultGlyph(True);
end;

procedure TPJLinkedMenuSpeedButton.DisplayMenu(Pos: TPoint);
  {Inhibits display of menu by MouseUp method when control is captured and
  adjusts location menu is displayed according to AlignMenuToMaster property.
    @param Pos [in] Requested position to display menu.
  }
begin
  if not fControlCaptured then
  begin
    if Assigned(fMasterButton) and fAlignMenuToMaster then
      // we're aligning menu to master
      Pos.X := Pos.X - fMasterButton.Width;
    inherited;
  end;
end;

procedure TPJLinkedMenuSpeedButton.EnableMouseEvents(Flag: Boolean);
  {Disables or restores this button's mouse event handler.
    @param Flag [in] Flag true when mouse events being restored, false when
      disabled.
  }
begin
  if Flag then
  begin
    // Restore stored event handlers
    OnMouseMove := fMouseMoveEventStore;
    OnMouseDown := fMouseDownEventStore;
    OnMouseUp := fMouseUpEventStore;
    OnClick := fMouseClickEventStore;
    OnDblClick := fMouseDblClickEventStore;
  end
  else
  begin
    // Save and disable event handlers
    fMouseMoveEventStore := OnMouseMove;
    fMouseDownEventStore := OnMouseDown;
    fMouseUpEventStore := OnMouseUp;
    fMouseClickEventStore := OnClick;
    fMouseDblClickEventStore := OnDblClick;
    OnMouseMove := nil;
    OnMouseDown := nil;
    OnMouseUp := nil;
    OnClick := nil;
    OnDblClick := nil;
  end;
end;

function TPJLinkedMenuSpeedButton.GetFlat: Boolean;
  {Replacement read access method for Flat property. Simply calls inherited
  method.
    @return Value of Flat property.
  }
begin
  Result := inherited Flat;
end;

function TPJLinkedMenuSpeedButton.GetGlyph: TBitmap;
  {Replacement read access method for Glyph property.
    @return Value of inherited Glyph property.
  }
begin
  Result := inherited Glyph;
end;

procedure TPJLinkedMenuSpeedButton.GlyphChange(Sender: TObject);
  {Handles event triggered when Glyph property changes. Assumes that the glyph
  that has been set is user provided. If this is not the case then other code
  changes this value.
    @param Sender [in] Not used.
  }
begin
  fGlyphStyle := GS_USER;
end;

procedure TPJLinkedMenuSpeedButton.LoadDefGlyph;
  {Loads the default glyph from resources into the Glyph property.
  }
var
  Bmp: TBitmap; // used to retrieve default glyph from resources
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Handle := LoadBitmap(HInstance, 'DROPDOWNARROW');
    inherited Glyph := Bmp;
  finally
    Bmp.Free;
  end;
end;

procedure TPJLinkedMenuSpeedButton.Loaded;
  {Override of loaded method that checks if we must destroy the initial default
  glyph in cases where no glyph is required.
  }
begin
  inherited Loaded;
  if not fUseDefaultGlyph and (fGlyphStyle = GS_DEFAULT) then
    inherited Glyph := nil;
end;

procedure TPJLinkedMenuSpeedButton.Notification(AComponent: TComponent;
  Operation: TOperation);
  {Override of notification method to set reference to master button to nil when
  button is destroyed.
    @param AComponent [in] Component triggering this notification.
    @param Operation [in] Whether component being added or removed.
  }
begin
  if (AComponent = fMasterButton) and (Operation = opRemove) then
    fMasterButton := nil;
end;

procedure TPJLinkedMenuSpeedButton.PJMAttach(var Msg: TMessage);
  {Traps custom PJM_ATTACH message. This message is sent by a master button when
  it wishes to attach to or detach from the menu button.
    @param Msg [in/out] WParam field contains contains reference to master
      button object. Data is not changed.
  }
var
  Obj: TObject; // the master speed button object
begin
  Obj := TObject(Msg.WParam);
  Attach(Obj as TPJLinkedSpeedButton);
end;

procedure TPJLinkedMenuSpeedButton.PJMCaptureControl(var Msg: TMessage);
  {Traps custom PJM_CAPTURECONTROL message. This message is sent by any attached
  master button to permit false mouse messages to be sent to control the state
  of this button, and also to inhibit this button from firing mouse events.
    @param Msg [in/out] WParam field contains 1 to capture control or 0 to
      release it. Data is not changed.
  }
begin
  SetControlCaptured(Msg.WParam = 1);
end;

procedure TPJLinkedMenuSpeedButton.PJMLMouseDown(var Msg: TMessage);
  {Traps custom PJM_LMOUSEDOWN message, which calls MouseDown event with info
  from message. Can be used to simulate mouse down events on and off the button
  to force button down, even when mouse is over attached master button. Only
  works when control's mouse events are captured by master button.
    @param Msg [in/out] Contains information about mouse position and shift
      keys. Data is not changed.
  }
var
  MouseMsg: TWMMouse; // casts plain message to mouse message
begin
  if fControlCaptured then
  begin
    MouseMsg := TWMMouse(Msg);
    MouseDown(mbLeft, KeysToShiftState(MouseMsg.Keys),
      MouseMsg.XPos, MouseMsg.YPos);
  end;
end;

procedure TPJLinkedMenuSpeedButton.PJMLMouseMove(var Msg: TMessage);
  {Traps custom PJM_LMOUSEMOVE message, which calls MouseMove event with info
  from message. Can be used to simulate mouse move events on and off the button
  to keep button down when mouse over master button. Only works when control's
  mouse events are captured by master button.
    @param Msg [in/out] Contains information about mouse position and shift
      keys. Data is not changed.
  }
var
  MouseMsg: TWMMouse; // casts plain message to mouse message
begin
  if fControlCaptured then
  begin
    MouseMsg := TWMMouse(Msg);
    MouseMove(KeysToShiftState(MouseMsg.Keys),
      MouseMsg.XPos, MouseMsg.YPos);
  end;
end;

procedure TPJLinkedMenuSpeedButton.PJMLMouseUp(var Msg: TMessage);
  {Traps custom PJM_LMOUSEUP message, which calls MouseUp event with info from
  message. Can be used to simulate mouse up events on and off the button to
  release button even when mouse is attached master button. Only works when
  control's mouse events are captured by master button.
    @param Msg [in/out] Contains information about mouse position and shift
      keys. Data is not changed.
  }
var
  MouseMsg: TWMMouse; // casts plain message to mouse message
begin
  if fControlCaptured then
  begin
    MouseMsg := TWMMouse(Msg);
    MouseUp(mbLeft, KeysToShiftState(MouseMsg.Keys),
      MouseMsg.XPos, MouseMsg.YPos);
  end;
end;

procedure TPJLinkedMenuSpeedButton.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
  {Override that only permits changes in width when button is associated with
  a master button.
    @param ALeft [in] Requested value of Left property.
    @param ATop [in] Requested value of Top property.
    @param AWidth [in] Requested value of Width property.
    @param AHeight [in] Requested value of Height property.
  }
begin
  if Assigned(fMasterButton) then
    inherited SetBounds(fMasterButton.Left + fMasterButton.Width,
      fMasterButton.Top, AWidth, fMasterButton.Height)
  else
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TPJLinkedMenuSpeedButton.SetControlCaptured(Flag: Boolean);
  {Sets flag that shows if control is captured (ie mouse events are taken over
  by any associated master button). Disable/enables mouse events depending on
  whether captured.
    @param Flag [in] Flag true when control being captured, false when released.
  }
begin
  if Flag <> fControlCaptured then
  begin
    fControlCaptured := Flag;
    EnableMouseEvents(not fControlCaptured);
  end;
end;

procedure TPJLinkedMenuSpeedButton.SetFlat(const Value: Boolean);
  {Replacement write access method for Flat property. If there's an associated
  master button, the value is only changed if new value matches that of master
  button.
    @param Value [in] Requested new value of Flat property.
  }
begin
  // This method never called when streaming in
  if Assigned(fMasterButton) then
  begin
    if Value = fMasterButton.Flat then
      inherited Flat := Value;
  end
  else
    inherited Flat := Value;
end;

procedure TPJLinkedMenuSpeedButton.SetGlyph(const Value: TBitmap);
  {Replacement write access method for Glyph property. Sets Glyph and records
  that we're not using default glyph.
    @param Value [in] New bitmap to used as glyph.
  }
begin
  // This method never called when streaming in
  inherited Glyph := Value;
  fUseDefaultGlyph := False;
end;

procedure TPJLinkedMenuSpeedButton.SetUseDefaultGlyph(
  const Value: Boolean);
  {Write access method for UseDefaultGlyph property. If value is true then the
  default glyph is loaded into the Glyph property and if false any existing
  Glyph is deleted. On loading the component, if value is true (default) default
  glyph won't be in form file, so default glyph created in contructor is used
  (there is no Glyph in form file to overwrite it). If value is false on loading
  there could be a Glyph in form file that would be deleted by this method since
  this property will be stored in form file and property is loaded after Glyph,
  so we defer any deletion to Loaded method when we will know if there's been a
  Glyph loaded.
    @param Value [in] New property value.
  }
begin
  if fUseDefaultGlyph <> Value then
  begin
    // There's something to do
    if Value then
    begin
      // Load the glyph if we're not Loading and record that we have default
      if not (csLoading in ComponentState) then
        LoadDefGlyph;                  // changes Glyph => fGlyphStyle = GS_USER
      fGlyphStyle := GS_DEFAULT;
    end
    else
    begin
      // Delete the glyph: don't do this at design: defer till Loaded
      if not (csLoading in ComponentState) then
        inherited Glyph := nil;        // changes Glyph => fGlyphStyle = GS_USER
    end;
    // Record the property value
    fUseDefaultGlyph := Value;
  end;
end;

function TPJLinkedMenuSpeedButton.StoreGlyph: Boolean;
  {Checks if Glyph property should be streamed to form resource by designer.
  Glyph is only stored if it's not the DefaultGlyph.
    @return True if Glyph property to be stored and false if not.
  }
begin
  Result := not fUseDefaultGlyph;
end;


{ TPJLinkedSpeedButton }

procedure TPJLinkedSpeedButton.AttachMenuBtn(
  Btn: TPJLinkedMenuSpeedButton);
  {Sends a PJM_ATTACH message to a menu button. This causes the menu button to
  attach itself to this button.
    @param Btn [in] Reference to menu button that is to attach itself. If Btn is
      nil no action is taken.
  }
begin
  if Assigned(Btn) then
    Btn.Perform(PJM_ATTACH, Integer(Self), 0);
end;

procedure TPJLinkedSpeedButton.CaptureMenuBtn(Flag: Boolean);
  {Captures or releases the mouse events of the menu button by sending custom
  message. On receiving message menu button disables its mouse events if
  captured or reactivates them when released.
    @param Flag [in] True to capture mouse button, false to release it.
  }
begin
  if Flag then
    fMenuButton.Perform(PJM_CAPTURECONTROL, 1, 0)
  else
    fMenuButton.Perform(PJM_CAPTURECONTROL, 0, 0);
end;

procedure TPJLinkedSpeedButton.Click;
  {Overrides default Click method to trigger default menu item of active menu of
  any attached menu button. Note that this button's OnClick event and any
  assigned action are not executed if default menu item is found.
  }
var
  DefMenuItemClicked: Boolean;  // flag indicates if default menu item triggered
begin
  DefMenuItemClicked := False;
  if fTriggerDefMenuItem and Assigned(fMenuButton)
    and Assigned(fMenuButton.ActiveMenu) then
    // we have menu assigned to an attached menu button
    DefMenuItemClicked := DoDefMenuItem(fMenuButton.ActiveMenu);
  if not DefMenuItemClicked then
    inherited Click;
end;

procedure TPJLinkedSpeedButton.CMEnabledChanged(var Msg: TMessage);
  {CM_ENABLEDCHANGED message handler. Does inherited processing the sets
  Enabled property of any attached menu button to be same as this button.
    @param Msg [in/out] Contains message information.
  }
begin
  inherited;
  if Assigned(fMenuButton) then
    fMenuButton.Enabled := Enabled;
end;

procedure TPJLinkedSpeedButton.CMMouseEnter(var Msg: TMessage);
  {CM_MOUSEENTER message handler. Acts on message and passes it on to any
  attached menu button. This handler is required to switch on highlighting on
  two associated buttons at same time.
    @param Msg [in/out] Contains message information.
  }
begin
  inherited;
  if MouseInControl and Assigned(fMenuButton) and (Msg.WParam <> 1) then
    fMenuButton.Perform(CM_MOUSEENTER, 0, 0);
end;

procedure TPJLinkedSpeedButton.CMMouseLeave(var Msg: TMessage);
  {CM_MOUSELEAVE message handler. Acts on message then passes it on to any
  attached menu button. This handler is required to switch on highlighting on
  two associated buttons at same time.
    @param Msg [in/out] Contains message information.
  }
begin
  inherited;
  if Assigned(fMenuButton) and (Msg.WParam <> 1) then
    fMenuButton.Perform(CM_MOUSELEAVE, 0, 0);
end;

constructor TPJLinkedSpeedButton.Create(AOwner: TComponent);
  {Class constructor. Sets up button object.
    @param AOwner [in] Owning control.
  }
begin
  inherited Create(AOwner);
  fMenuButton := nil;
end;

procedure TPJLinkedSpeedButton.DetachMenuBtn(
  Btn: TPJLinkedMenuSpeedButton);
  {Sends a PJM_ATTACH message to a menu button. This causes the menu button to
  detach itself from this button.
    @param Btn [in] Reference to menu button that is to detach itself. If Btn is
      nil no action is taken.
  }
begin
  if Assigned(Btn) then
    Btn.Perform(PJM_ATTACH, Integer(nil), 0);
end;

function TPJLinkedSpeedButton.DoDefMenuItem(
  const Menu: TPopupMenu): Boolean;
  {Triggers (clicks) any default menu item of a given popup menu.
    @param Menu [in] Popup menu whose default menu item is to be triggered.
    @return True if default menu item exists, False if not.
  }
var
  Idx: Integer;   // loops thru all menu items
  MI: TMenuItem;  // reference to a menu item
begin
  Result := False;
  if not Assigned(Menu) then
    Exit;
  for Idx := 0 to Pred(Menu.Items.Count) do
  begin
    MI := Menu.Items[Idx];
    if MI.Default then
    begin
      MI.Click;
      Result := True;
      Break;
    end;
  end;
end;

function TPJLinkedSpeedButton.GetFlat: Boolean;
  {Replacement read access method for Flat property. Simply calls inherited
  method.
    @return Value of Flat property.
  }
begin
  Result := inherited Flat;
end;

procedure TPJLinkedSpeedButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  {Override of Mouse down method that causes the button to be pressed. When this
  happens we also want any associated menu button to be depressed, but not to
  fire any of its own mouse events.
    @param Button [in] Mouse button pressed.
    @param Shift [in] State of various shift keys.
    @param X [in] X co-ordinate of mouse pointer.
    @param Y [in] Y co-ordinate of mouse pointer.
  }
begin
  inherited;
  if Assigned(fMenuButton) then
  begin
    // Prevent menu button from firing mouse events
    CaptureMenuBtn(True);
    // Send false mouse down message to depress menu button
    MouseMsgToMenuBtn(PJM_LMOUSEDOWN, Shift, 0, 0);
  end;
end;

procedure TPJLinkedSpeedButton.MouseMove(Shift: TShiftState; X,
  Y: Integer);
  {Override of MouseMove method. Normally if mouse tracks off the button the
  button is restored to its normal state without firing an OnClick event. Where
  we have an attached menu button we need to adapt this default processing as
  follows: when mouse is moved over this button we do default processing; when
  mouse is moved over menu button we act as if over this button; when mouse is
  moved off both buttons we restore both buttons; when mouse is dragged back
  over these buttons after moving off we depress both buttons again.
    @param Shift [in] State of various shift keys.
    @param X [in] X co-ordinate of mouse pointer.
    @param Y [in] Y co-ordinate of mouse pointer.
  }
var
  InCombinedBtns: Boolean;  // flag true if mouse over this or menu button
begin
  if Assigned(fMenuButton) then
  begin
    // Set flag if mouse over either this control or menu button
    InCombinedBtns := (X >= 0) and (X < ClientWidth + fMenuButton.Width)
      and (Y >= 0) and (Y <= ClientHeight);
    if InCombinedBtns then
    begin
      // We're over one of the buttons
      // do default processing
      inherited MouseMove(Shift, X, Y);
      if X >= ClientWidth then
      begin
        // we're off this button and over menu button
        if fState <> bsDown then
        begin
          // ensure this button stays down
          fState := bsDown;
          Invalidate;
        end;
      end;
      if (fState = bsDown) and not fMenuButton.Down then
      begin
        // this button is down and menu button is up: force it down
        // .. make sure menu button isn't firing mouse events and
        CaptureMenuBtn(True);
        // .. use false mouse down event to force it down
        MouseMsgToMenuBtn(PJM_LMOUSEDOWN, Shift, 0, 0);
      end;
    end
    else
    begin
      // We're off both buttons:
      // do default processing which restores this button
      inherited MouseMove(Shift, X, Y);
      // send false mouse move message to menu button to make it think mouse has
      // moved off it so it restores itself
      MouseMsgToMenuBtn(PJM_LMOUSEMOVE, Shift, -1, -1);
    end;
  end
  else
    inherited;
end;

procedure TPJLinkedSpeedButton.MouseMsgToMenuBtn(Msg: Word; Shift: TShiftState;
  X, Y: Integer);
  {Sends a mouse message to attached menu button.
    @param Msg [in] Type of message.
    @param Shift [in] Key shift state.
    @param X [in] X co-ordinate of mouse cursor.
    @param Y [in] Y co-ordinate of mouse cursor.
  }
var
  MenuMsg: TWMMouse;  // the message reocrd
begin
  // Set shift state
  MenuMsg.Keys := 0;
  if ssShift in Shift then MenuMsg.Keys := MenuMsg.Keys or MK_SHIFT;
  if ssCtrl in Shift then MenuMsg.Keys := MenuMsg.Keys or MK_CONTROL;
  // Record mouse position
  MenuMsg.XPos := X;
  MenuMsg.YPos := Y;
  // Send message to menu button
  fMenuButton.Perform(Msg, TMessage(MenuMsg).WParam, TMessage(MenuMsg).LParam);
end;

procedure TPJLinkedSpeedButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  {Override of MouseUp method. If the method is triggerd when the mouse is over
  this button then the button is restored and the OnClick event is fired. If the
  mouse is released over any attached menu button, we still want this processing
  to occur and our button's OnClick tevent to fire. We also wish to release the
  attached menu button, which will have been depressed by MouseDown method.
    @param Button [in] Mouse button pressed.
    @param Shift [in] State of various shift keys.
    @param X [in] X co-ordinate of mouse pointer.
    @param Y [in] Y co-ordinate of mouse pointer.
  }
var
  InCombinedBtns: Boolean;  // flag true if mouse is over this or menu button
begin
  if Assigned(fMenuButton) then
  begin
    // Calc if mouse is over either this button or attached menu button
    InCombinedBtns := (X >= 0) and (X < ClientWidth + fMenuButton.Width)
      and (Y >= 0) and (Y <= ClientHeight);
    // Send a false mouse up message to menu button to cause it to be released
    // menu button mouse events inhibited in MouseDown => its events dont fire
    MouseMsgToMenuBtn(PJM_LMOUSEUP, Shift, 0, 0);
    // can now allow menu button to fire own events again
    CaptureMenuBtn(False);
    // Do usual processing on this button (OnClick event and restore button)
    inherited MouseUp(Button, Shift, X, Y);
    // If mouse was released over menu button inherited MouseUp won't have
    // redrawn button or triggered OnClick event, so do it here
    if InCombinedBtns and (X >= ClientWidth) then
    begin
      if not (fState in [bsExclusive, bsDown]) then
        Invalidate;
      Click;
    end;
  end
  else
    // We have no attached menu button so do default processing
    inherited;
end;

procedure TPJLinkedSpeedButton.Notification(AComponent: TComponent;
  Operation: TOperation);
  {Resets reference to MenuButton to nil if the associated button is destroyed.
    @param AComponent [in] Component triggering this notification.
    @param Operation [in] Whether component being added or removed.
  }
begin
  if (AComponent = fMenuButton) and (Operation = opRemove) then
    fMenuButton := nil;
end;

procedure TPJLinkedSpeedButton.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
  {Override that adjusts position and size of any associated menu button to
  match stay attached to this button.
    @param ALeft [in] Requested value of Left property.
    @param ATop [in] Requested value of Top property.
    @param AWidth [in] Requested value of Width property.
    @param AHeight [in] Requested value of Height property.
  }
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if Assigned(fMenuButton) then
    // menu buttons are always aligned to our top and right side, and are always
    // same height as this button
    fMenuButton.SetBounds(ALeft + AWidth, ATop, fMenuButton.Width, ATop);
end;

procedure TPJLinkedSpeedButton.SetFlat(const Value: Boolean);
  {Replacement write access method for Flat property. If there's an associated
  menu button, its Flat property is changed in tandem with this one.
    @param Value [in] Requested new value of Flat property.
  }
begin
  inherited Flat := Value;
  if Assigned(fMenuButton) then
    fMenuButton.Flat := Value;
end;

procedure TPJLinkedSpeedButton.SetMenuButton(
  const Value: TPJLinkedMenuSpeedButton);
  {Write access method for MenuButton property. Records new value, detaches any
  existing menu button and attaches any new one.
    @param New property value: may be nil to unlink from menu button.
  }
var
  OldMB: TPJLinkedMenuSpeedButton;  // reference to any existing menu button
begin
  if fMenuButton <> Value then
  begin
    // Detach any existing menu button
    OldMB := fMenuButton;
    if Assigned(OldMB) then
    begin
      fMenuButton := nil;     // prevents recursion
      DetachMenuBtn(OldMB);
    end;
    // Record new value
    fMenuButton := Value;
    // Associate new menu button with this one
    if Assigned(Value) then
    begin
      Value.FreeNotification(Self);
      AttachMenuBtn(Value);
      if Assigned(OldMB) then
        // nudge previous menu button out of way so still visible
        OldMB.Left := Value.Left + Value.Width;
    end;
  end;
end;

end.

