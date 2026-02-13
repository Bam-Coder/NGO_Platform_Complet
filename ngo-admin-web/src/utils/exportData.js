function escapeCsvValue(value) {
  if (value === null || value === undefined) return '';
  const stringValue = String(value);
  const needsQuotes = /[",\n]/.test(stringValue);
  const escaped = stringValue.replace(/"/g, '""');
  return needsQuotes ? `"${escaped}"` : escaped;
}

export const exportToCSV = (data, filename) => {
  if (!Array.isArray(data) || data.length === 0) return;

  const headers = Object.keys(data[0]);
  const headerRow = headers.map(escapeCsvValue).join(',');
  const rows = data
    .map((item) => headers.map((header) => escapeCsvValue(item[header])).join(','))
    .join('\n');

  const csvContent = `${headerRow}\n${rows}`;
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);

  const link = document.createElement('a');
  link.href = url;
  link.download = `${filename}.csv`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
};
