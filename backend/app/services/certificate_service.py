"""
Certificate PDF generation using ReportLab.
Produces a professional, branded PDF certificate.
"""
import os
from datetime import datetime
from reportlab.lib.pagesizes import landscape, A4
from reportlab.lib.units import inch, cm
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER


# ── Brand Colors ──────────────────────────────────────────
BRAND_NAVY    = colors.HexColor("#0A0E27")
BRAND_PURPLE  = colors.HexColor("#6C63FF")
BRAND_CYAN    = colors.HexColor("#00D4FF")
BRAND_WHITE   = colors.white
BRAND_GOLD    = colors.HexColor("#FFD700")
BRAND_SILVER  = colors.HexColor("#C0C8D0")


def generate_pdf_certificate(cert, output_dir: str) -> str:
    """
    Generate a PDF certificate and return the file path.

    Args:
        cert: Certificate model instance
        output_dir: Directory to save the PDF

    Returns:
        str: Full path to the generated PDF file
    """
    os.makedirs(output_dir, exist_ok=True)
    filename  = f"cert_{cert.cert_id}.pdf"
    filepath  = os.path.join(output_dir, filename)

    page_w, page_h = landscape(A4)

    doc = SimpleDocTemplate(
        filepath,
        pagesize        = landscape(A4),
        rightMargin     = 1.5 * cm,
        leftMargin      = 1.5 * cm,
        topMargin       = 1.5 * cm,
        bottomMargin    = 1.5 * cm,
    )

    story = []
    styles = getSampleStyleSheet()

    # ── Style Definitions ─────────────────────────────────
    def style(name, **kw):
        base = kw.pop("base", "Normal")
        s = ParagraphStyle(name, parent=styles[base], **kw)
        return s

    s_academy = style("academy",
        fontSize=11, textColor=BRAND_CYAN, alignment=TA_CENTER,
        fontName="Helvetica-Bold", spaceAfter=4)

    s_title = style("title",
        fontSize=36, textColor=BRAND_WHITE, alignment=TA_CENTER,
        fontName="Helvetica-Bold", spaceAfter=6)

    s_subtitle = style("subtitle",
        fontSize=14, textColor=BRAND_SILVER, alignment=TA_CENTER,
        fontName="Helvetica", spaceAfter=16)

    s_presented = style("presented",
        fontSize=12, textColor=BRAND_SILVER, alignment=TA_CENTER,
        fontName="Helvetica-Oblique", spaceAfter=4)

    s_name = style("name",
        fontSize=32, textColor=BRAND_GOLD, alignment=TA_CENTER,
        fontName="Helvetica-Bold", spaceAfter=6)

    s_body = style("body",
        fontSize=12, textColor=BRAND_SILVER, alignment=TA_CENTER,
        fontName="Helvetica", spaceAfter=8)

    s_course = style("course",
        fontSize=20, textColor=BRAND_CYAN, alignment=TA_CENTER,
        fontName="Helvetica-Bold", spaceAfter=16)

    s_meta = style("meta",
        fontSize=9, textColor=BRAND_SILVER, alignment=TA_CENTER,
        fontName="Helvetica")

    s_score = style("score",
        fontSize=14, textColor=BRAND_GOLD, alignment=TA_CENTER,
        fontName="Helvetica-Bold", spaceAfter=4)

    # ── Build Content ─────────────────────────────────────
    story.append(Spacer(1, 0.4 * inch))
    story.append(Paragraph("VINSLA AI ACADEMY", s_academy))
    story.append(Paragraph("Certificate of Completion", s_title))
    story.append(HRFlowable(width="70%", thickness=2, color=BRAND_PURPLE, spaceAfter=12))

    story.append(Paragraph("This is to proudly certify that", s_subtitle))
    story.append(Spacer(1, 0.1 * inch))
    story.append(Paragraph(cert.student_name, s_name))
    story.append(HRFlowable(width="40%", thickness=1, color=BRAND_GOLD, spaceAfter=8))

    story.append(Paragraph(
        "has successfully completed the course", s_presented))
    story.append(Spacer(1, 0.1 * inch))
    story.append(Paragraph(cert.course_name, s_course))

    story.append(Paragraph(
        f"with a final score of <b>{cert.final_score:.0f}%</b>", s_score))

    story.append(Spacer(1, 0.3 * inch))
    story.append(HRFlowable(width="70%", thickness=1, color=BRAND_PURPLE, spaceAfter=12))

    issued_str = cert.issued_at.strftime("%B %d, %Y") if cert.issued_at else datetime.utcnow().strftime("%B %d, %Y")

    story.append(Paragraph(
        f"Issued on: {issued_str}   |   Certificate ID: {cert.cert_id}   |   "
        f"Verify at: vinslaacademy.com/verify/{cert.cert_id}",
        s_meta
    ))

    # ── Draw with dark background ─────────────────────────
    def draw_background(canvas, doc):
        canvas.saveState()
        # Dark navy background
        canvas.setFillColor(BRAND_NAVY)
        canvas.rect(0, 0, page_w, page_h, fill=1, stroke=0)

        # Decorative border
        canvas.setStrokeColor(BRAND_PURPLE)
        canvas.setLineWidth(3)
        canvas.rect(20, 20, page_w - 40, page_h - 40, fill=0, stroke=1)

        canvas.setStrokeColor(BRAND_CYAN)
        canvas.setLineWidth(1)
        canvas.rect(28, 28, page_w - 56, page_h - 56, fill=0, stroke=1)

        # Corner accents
        canvas.setFillColor(BRAND_PURPLE)
        for x, y in [(20, 20), (page_w - 30, 20), (20, page_h - 30), (page_w - 30, page_h - 30)]:
            canvas.rect(x, y, 10, 10, fill=1, stroke=0)

        canvas.restoreState()

    doc.build(story, onFirstPage=draw_background, onLaterPages=draw_background)
    return filepath
