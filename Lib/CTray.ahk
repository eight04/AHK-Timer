class CTray {
  ; {icon, menus, default, tooltip}
  __New(o) {
    ; Make tray menu
    If (FileExist(filename)) {
      Menu, tray, Icon, % filename
    }
    Menu, tray, noStandard
    for key, value in o.menus {
      Menu, tray, add, % key, % value
    }
    Menu, tray, default, % o.default
    this.setTooltip(o.tooltip)
  }
  setTooltip(text) {
    Menu, tray, tip, % text
  }
  setBalloon() {
    
  }
}