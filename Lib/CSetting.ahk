class CSetting {
  table := ""
  filename := ""
  section := ""
  __New(table, filename, section := "Setting") {
    this.table := table
    this.filename := filename
    this.section := section
  }
  load() {
    for key, value in this.table {
      IniRead, value, % this.filename, % this.section, % key, % value
      this.table[key] := value
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
  set(key, value) {
    this.table[key] := value
  }
}
