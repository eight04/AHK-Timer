class CSetting {
  table := ""
  filename := ""
  section := ""
  ; { default, filename, section, onChange }
  __New(o) {
    this.filename := o.filename
    this.section := o.section
    this.onChange := o.onChange
    for key, value in o.default {
      this.set(key, value)
    }
  }
  load() {
    for key, _value in this.table {
      IniRead, value, % this.filename, % this.section, % key, FAILED
      if (newValue != "FAILED") {
        this.set(key, value)
      }
    }
  }
  save(key := "") {
    if (key) {
      IniWrite, % this.table[key], % this.filename, % this.section, % key
    } else {
      for key, value in this.table {
        IniWrite, % value, % this.filename, % this.section, % key
      }
    }
  }
  get(key) {
    return this.table[key]
  }
  set(key, newValue) {
    oldValue := this.table[key]
    if (oldValue != newValue) {
      this.table[key] := newValue
      this.onChange.call(key, oldValue, newValue)
    }
  }
}
