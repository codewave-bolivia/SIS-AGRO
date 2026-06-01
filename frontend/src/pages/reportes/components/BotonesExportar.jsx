import { useState } from 'react';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';

const BRAND_COLOR  = [22, 163, 74];   // emerald-600
const DARK_COLOR   = [24, 24, 27];    // zinc-900
const LIGHT_GRAY   = [244, 244, 245]; // zinc-100
const MID_GRAY     = [161, 161, 170]; // zinc-400
const WHITE        = [255, 255, 255];

function dibujarHeader(doc, titulo, subtitulo, logoDataUrl) {
  const pw      = doc.internal.pageSize.getWidth();
  const headerH = 32;

  // Fondo oscuro header
  doc.setFillColor(...DARK_COLOR);
  doc.rect(0, 0, pw, headerH, 'F');

  // Barra de acento verde izquierda
  doc.setFillColor(...BRAND_COLOR);
  doc.rect(0, 0, 4, headerH, 'F');

  // Logo
  const logoH = 24;
  const logoW = logoH * 0.81; // aspect ratio 877/1080
  const logoX = 9;
  const logoY = (headerH - logoH) / 2;
  if (logoDataUrl) {
    doc.addImage(logoDataUrl, 'PNG', logoX, logoY, logoW, logoH);
  }

  const textX = logoDataUrl ? logoX + logoW + 4 : 10;

  // Nombre del sistema
  doc.setTextColor(...BRAND_COLOR);
  doc.setFontSize(9);
  doc.setFont('helvetica', 'bold');
  doc.text('SIS-AGRO', textX, 11);

  // Subtítulo sistema
  doc.setTextColor(...MID_GRAY);
  doc.setFontSize(7);
  doc.setFont('helvetica', 'normal');
  doc.text('Sistema de Gestión Agropecuaria', textX, 17);

  // Título del reporte
  doc.setTextColor(...WHITE);
  doc.setFontSize(12);
  doc.setFont('helvetica', 'bold');
  doc.text(titulo, textX, 27);

  // Subtítulo / rango de fechas (derecha)
  if (subtitulo) {
    doc.setTextColor(...MID_GRAY);
    doc.setFontSize(7.5);
    doc.setFont('helvetica', 'normal');
    doc.text(subtitulo, pw - 10, 17, { align: 'right' });
  }

  // Fecha de generación
  doc.setTextColor(...MID_GRAY);
  doc.setFontSize(7);
  doc.text(`Generado: ${new Date().toLocaleString('es-BO')}`, pw - 10, 27, { align: 'right' });

  return headerH;
}

function dibujarResumen(doc, resumen, startY) {
  if (!resumen || Object.keys(resumen).length === 0) return startY;

  const pw   = doc.internal.pageSize.getWidth();
  const pads = 10;
  const entradas = Object.entries(resumen)
    .filter(([, v]) => v !== undefined && v !== null)
    .slice(0, 4); // máx 4 tarjetas

  if (entradas.length === 0) return startY;

  const cardW   = (pw - pads * 2 - (entradas.length - 1) * 4) / entradas.length;
  const cardH   = 16;

  entradas.forEach(([clave, valor], i) => {
    const x = pads + i * (cardW + 4);

    // Fondo tarjeta
    doc.setFillColor(...LIGHT_GRAY);
    doc.roundedRect(x, startY, cardW, cardH, 2, 2, 'F');

    // Borde superior verde
    doc.setFillColor(...BRAND_COLOR);
    doc.rect(x, startY, cardW, 1.5, 'F');

    // Etiqueta
    const label = clave
      .replace(/_/g, ' ')
      .replace(/\b\w/g, c => c.toUpperCase());
    doc.setTextColor(...MID_GRAY);
    doc.setFontSize(6.5);
    doc.setFont('helvetica', 'normal');
    doc.text(label, x + 4, startY + 6);

    // Valor
    const valStr = typeof valor === 'number'
      ? valor.toLocaleString('es-BO', { minimumFractionDigits: valor % 1 !== 0 ? 2 : 0 })
      : String(valor);
    doc.setTextColor(...DARK_COLOR);
    doc.setFontSize(10);
    doc.setFont('helvetica', 'bold');
    doc.text(valStr, x + 4, startY + 13);
  });

  return startY + cardH + 5;
}

function dibujarFooter(doc) {
  const pw = doc.internal.pageSize.getWidth();
  const ph = doc.internal.pageSize.getHeight();
  const total = doc.internal.getNumberOfPages();

  for (let i = 1; i <= total; i++) {
    doc.setPage(i);

    // Línea separadora
    doc.setDrawColor(...LIGHT_GRAY);
    doc.setLineWidth(0.4);
    doc.line(10, ph - 12, pw - 10, ph - 12);

    // Texto izquierdo
    doc.setTextColor(...MID_GRAY);
    doc.setFontSize(7);
    doc.setFont('helvetica', 'normal');
    doc.text('SIS-AGRO — Sistema de Gestión Agropecuaria', 10, ph - 7);

    // Página
    doc.text(`Página ${i} de ${total}`, pw - 10, ph - 7, { align: 'right' });
  }
}

export default function BotonesExportar({
  datos,
  columnas,
  titulo,
  subtitulo,
  resumen,
  orientacion = 'portrait'
}) {
  const [exportando, setExportando] = useState(false);

  const exportarPDF = async () => {
    if (!datos || datos.length === 0) return alert('No hay datos para exportar');
    setExportando(true);

    try {
      // Cargar logo como data URL
      let logoDataUrl = null;
      try {
        const res  = await fetch('/logo.png');
        const blob = await res.blob();
        logoDataUrl = await new Promise(resolve => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.readAsDataURL(blob);
        });
      } catch { /* si falla, se omite el logo */ }

      const doc = new jsPDF({ orientation: orientacion, unit: 'mm', format: 'a4' });
      const tituloLimpio = titulo.replace(/_/g, ' ').replace(/Reporte /i, '').trim();

      const headerH  = dibujarHeader(doc, tituloLimpio, subtitulo, logoDataUrl);
      let   bodyStart = headerH + 5;

      bodyStart = dibujarResumen(doc, resumen, bodyStart);

      const head = [columnas.map(c => c.header)];
      const body = datos.map(fila =>
        columnas.map(col => {
          if (col.excelValue) return col.excelValue(fila) ?? '';
          const v = fila[col.key];
          return v !== undefined && v !== null ? String(v) : '';
        })
      );

      autoTable(doc, {
        head,
        body,
        startY: bodyStart,
        margin: { left: 10, right: 10 },
        styles: {
          fontSize: 8,
          cellPadding: { top: 3, right: 4, bottom: 3, left: 4 },
          lineColor: [228, 228, 231],
          lineWidth: 0.2,
          textColor: DARK_COLOR,
          overflow: 'linebreak',
        },
        headStyles: {
          fillColor: DARK_COLOR,
          textColor: WHITE,
          fontStyle: 'bold',
          fontSize: 8,
          cellPadding: { top: 4, right: 4, bottom: 4, left: 4 },
        },
        alternateRowStyles: {
          fillColor: [250, 250, 250],
        },
        columnStyles: (() => {
          const cs = {};
          columnas.forEach((col, i) => {
            if (col.align === 'right')  cs[i] = { halign: 'right' };
            if (col.align === 'center') cs[i] = { halign: 'center' };
          });
          return cs;
        })(),
        didDrawPage: (data) => {
          if (data.pageNumber > 1) {
            dibujarHeader(doc, tituloLimpio, subtitulo, logoDataUrl);
          }
        },
        willDrawCell: (data) => {
          if (data.section === 'head') {
            doc.setFillColor(...BRAND_COLOR);
            doc.rect(data.cell.x, data.cell.y + data.cell.height - 1, data.cell.width, 1, 'F');
          }
        },
      });

      dibujarFooter(doc);

      const fecha = new Date().toISOString().split('T')[0];
      doc.save(`${titulo}_${fecha}.pdf`);
    } catch (err) {
      console.error(err);
      alert('Error al generar el PDF: ' + err.message);
    } finally {
      setExportando(false);
    }
  };

  return (
    <button
      onClick={exportarPDF}
      disabled={exportando || !datos || datos.length === 0}
      className="flex items-center gap-2 px-3 py-1.5 text-sm font-medium bg-red-50 text-red-700 hover:bg-red-100 dark:bg-red-900/30 dark:text-red-400 rounded-lg transition-colors border border-red-200 dark:border-red-800 disabled:opacity-40 disabled:cursor-not-allowed"
    >
      {exportando ? (
        <svg className="w-4 h-4 animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/>
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
        </svg>
      ) : (
        <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
          <path strokeLinecap="round" strokeLinejoin="round" d="M13 3v6h6"/>
        </svg>
      )}
      {exportando ? 'Generando PDF...' : 'Exportar PDF'}
    </button>
  );
}
