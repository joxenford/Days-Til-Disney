/* ============================================
   Countdown to Magic — Marketing Website JS
   Minimal vanilla JS for interactions
   ============================================ */

'use strict';

/* ---- Nav: add scrolled class ---- */
(function initNav() {
  const nav = document.getElementById('nav');
  if (!nav) return;

  const THRESHOLD = 40;

  function updateNav() {
    if (window.scrollY > THRESHOLD) {
      nav.classList.add('is-scrolled');
    } else {
      nav.classList.remove('is-scrolled');
    }
  }

  // Run immediately so initial state is correct
  updateNav();
  window.addEventListener('scroll', updateNav, { passive: true });
})();

/* ---- Scroll-reveal animation ---- */
(function initScrollReveal() {
  const elements = document.querySelectorAll('.reveal');
  if (!elements.length) return;

  // Respect reduced motion preference
  const prefersReducedMotion = window.matchMedia(
    '(prefers-reduced-motion: reduce)'
  ).matches;

  if (prefersReducedMotion) {
    // Show everything immediately — no animations
    elements.forEach(function (el) {
      el.classList.add('is-visible');
    });
    return;
  }

  const observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          // Stop observing once revealed
          observer.unobserve(entry.target);
        }
      });
    },
    {
      root: null,
      rootMargin: '0px 0px -60px 0px',
      threshold: 0.1
    }
  );

  elements.forEach(function (el) {
    observer.observe(el);
  });
})();

/* ---- Smooth scroll for anchor links ---- */
(function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener('click', function (e) {
      var targetId = this.getAttribute('href').slice(1);
      if (!targetId) return;

      var target = document.getElementById(targetId);
      if (!target) return;

      e.preventDefault();

      var navHeight = 64;
      var top = target.getBoundingClientRect().top + window.scrollY - navHeight - 16;

      window.scrollTo({ top: top, behavior: 'smooth' });
    });
  });
})();
