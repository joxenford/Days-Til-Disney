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

/* ---- Live countdown ticker (hero phone mockup) ---- */
(function initCountdown() {
  // Update the phone mockup and countdown demo blocks with a realistic countdown.
  // We use a fixed "trip date" 47 days from page load just for demo purposes.
  var tripDate = new Date();
  tripDate.setDate(tripDate.getDate() + 47);
  tripDate.setHours(14, 32, 0, 0);

  function pad(n) {
    return String(n).padStart(2, '0');
  }

  function update() {
    var now = new Date();
    var diff = tripDate - now;

    if (diff <= 0) return;

    var totalSeconds = Math.floor(diff / 1000);
    var days         = Math.floor(totalSeconds / 86400);
    var hours        = Math.floor((totalSeconds % 86400) / 3600);
    var minutes      = Math.floor((totalSeconds % 3600) / 60);

    // Feature card countdown demo
    var demoNums = document.querySelectorAll('.countdown-demo__num');
    if (demoNums.length >= 3) {
      demoNums[0].textContent = pad(days);
      demoNums[1].textContent = pad(hours);
      demoNums[2].textContent = pad(minutes);
    }
  }

  update();
  setInterval(update, 1000);
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
