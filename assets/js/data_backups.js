/**
 * Data Backups
 */

function initDataBackupForm() {
  document.getElementById('data-backup-form').reset();
}

function addBackupToList(data) {
  var table = document.getElementById('data-backup-table').getElementsByTagName('tbody')[0];
  if (table) {
    var newRow = table.insertRow(0);
    addCell(newRow, data.download_link);
    addCell(newRow, data.description);
    addCell(newRow, data.file_size);
    addCell(newRow, data.create_date);
    addCell(newRow, data.delete_link);
  }
}

function addCell(row, data) {
  var cell = row.insertCell();
  cell.innerHTML = data;
}

function clearBackupForm({target, detail}) {
  if (target.matches('#data-backup-form')) {
    detail.json().then((json) => {
      initDataBackupForm();
      addBackupToList(json);
    });
  }
}

function setupDataBackupEvents() {
  document.addEventListener('fetchcomplete', clearBackupForm);
}

export { setupDataBackupEvents };
