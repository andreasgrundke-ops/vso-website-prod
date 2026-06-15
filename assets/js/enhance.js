/* ============================================================
   enhance.js – Smooth-Scroll (Lenis) + Hoch-Button (Desktop)
   Für Unterseiten (impressum, datenschutz, start, visitenkarte)
   Version: 1.0.0 (2026-06-15) · Grundke IT-Service
   Respektiert prefers-reduced-motion; Button nur Desktop (>640px).
   ============================================================ */
(function () {
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var lenis = null;

  // Smooth-Scroll fürs Mausrad/Trackpad (nur wenn Lenis geladen & Motion erlaubt)
  if (!reduce && typeof Lenis !== 'undefined') {
    lenis = new Lenis({ duration: 1.1, smoothWheel: true });
    function raf(t) { lenis.raf(t); requestAnimationFrame(raf); }
    requestAnimationFrame(raf);
    document.querySelectorAll('a[href^="#"]').forEach(function (a) {
      a.addEventListener('click', function (e) {
        var id = a.getAttribute('href');
        if (id.length > 1) {
          var el = document.querySelector(id);
          if (el) { e.preventDefault(); lenis.scrollTo(el); }
        }
      });
    });
  }

  // Hoch-Button (unten rechts, nur Desktop)
  var btn = document.createElement('button');
  btn.type = 'button';
  btn.setAttribute('aria-label', 'Nach oben scrollen');
  btn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>';
  btn.style.cssText = 'position:fixed;right:22px;bottom:22px;z-index:1200;width:46px;height:46px;border-radius:50%;border:none;background:#2f5638;color:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 6px 18px rgba(47,86,56,.32);opacity:0;pointer-events:none;transition:opacity .3s ease,transform .2s ease,background .2s ease;';
  btn.addEventListener('mouseenter', function () { this.style.transform = 'translateY(-3px)'; this.style.background = '#4a7a55'; });
  btn.addEventListener('mouseleave', function () { this.style.transform = ''; this.style.background = '#2f5638'; });
  btn.addEventListener('click', function () {
    if (lenis) { lenis.scrollTo(0); } else { window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' }); }
  });
  document.body.appendChild(btn);

  var mqMobile = window.matchMedia('(max-width:640px)');
  function toggle() {
    var show = window.scrollY > 350 && !mqMobile.matches;
    btn.style.opacity = show ? '1' : '0';
    btn.style.pointerEvents = show ? 'auto' : 'none';
  }
  window.addEventListener('scroll', toggle, { passive: true });
  if (mqMobile.addEventListener) mqMobile.addEventListener('change', toggle);
  toggle();
})();
