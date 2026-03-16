const THEME_STORAGE_KEY = 'theme';

function updateThemeToggle(theme) {
  const toggle = document.querySelector('[data-theme-toggle]');
  const label = document.querySelector('[data-theme-toggle-label]');
  const themeColorMeta = document.querySelector('[data-theme-color]');

  if (!toggle) return;

  const nextModeLabel = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
  const themeColor = getComputedStyle(document.documentElement)
    .getPropertyValue('--header-bg')
    .trim() || (theme === 'dark' ? '#08101c' : '#002676');

  toggle.setAttribute('aria-label', nextModeLabel);
  toggle.setAttribute('title', nextModeLabel);
  toggle.setAttribute('aria-pressed', String(theme === 'dark'));

  if (label) {
    label.textContent = nextModeLabel;
  }

  if (themeColorMeta) {
    themeColorMeta.setAttribute('content', themeColor);
  }
}

function applyTheme(theme, { persist = true } = {}) {
  document.documentElement.setAttribute('data-theme', theme);

  if (persist) {
    try {
      localStorage.setItem(THEME_STORAGE_KEY, theme);
    } catch (_error) {
      // Ignore storage failures and keep the theme applied for this session.
    }
  }

  updateThemeToggle(theme);
  window.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme } }));
}

function initializeThemeToggle() {
  const toggle = document.querySelector('[data-theme-toggle]');
  if (!toggle) return;

  const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
  updateThemeToggle(currentTheme);

  toggle.addEventListener('click', () => {
    const nextTheme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    applyTheme(nextTheme);
  });

  const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  mediaQuery.addEventListener('change', (event) => {
    let hasSavedTheme = false;

    try {
      hasSavedTheme = Boolean(localStorage.getItem(THEME_STORAGE_KEY));
    } catch (_error) {
      hasSavedTheme = false;
    }

    if (!hasSavedTheme) {
      applyTheme(event.matches ? 'dark' : 'light', { persist: false });
    }
  });
}

function initializeNavigation() {
  const nav = document.querySelector('[data-site-navigation]');
  const toggle = document.querySelector('[data-nav-toggle]');
  const submenuItems = Array.from(nav?.querySelectorAll('[data-nav-item]') || []);

  if (!nav || !toggle) return;

  const setNavigationState = (isOpen) => {
    nav.classList.toggle('is-open', isOpen);
    toggle.setAttribute('aria-expanded', String(isOpen));
  };

  const setSubmenuState = (item, isOpen) => {
    if (!item) return;

    item.classList.toggle('is-open', isOpen);

    const submenuToggle = item.querySelector('[data-nav-submenu-toggle]');
    if (submenuToggle) {
      submenuToggle.setAttribute('aria-expanded', String(isOpen));
    }
  };

  const closeSubmenus = ({ except = null } = {}) => {
    submenuItems.forEach((item) => {
      if (item === except) return;
      setSubmenuState(item, false);
    });
  };

  toggle.addEventListener('click', () => {
    const isOpen = !nav.classList.contains('is-open');
    setNavigationState(isOpen);

    if (!isOpen) {
      closeSubmenus();
    }
  });

  nav.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => {
      if (window.matchMedia('(max-width: 64rem)').matches) {
        setNavigationState(false);
      }

      closeSubmenus();
    });
  });

  nav.querySelectorAll('[data-nav-submenu-toggle]').forEach((submenuToggle) => {
    submenuToggle.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();

      const item = submenuToggle.closest('[data-nav-item]');
      const shouldOpen = !item.classList.contains('is-open');

      closeSubmenus({ except: shouldOpen ? item : null });
      setSubmenuState(item, shouldOpen);
    });
  });

  document.addEventListener('click', (event) => {
    if (nav.contains(event.target) || toggle.contains(event.target)) return;

    closeSubmenus();

    if (window.matchMedia('(max-width: 64rem)').matches) {
      setNavigationState(false);
    }
  });

  document.addEventListener('keydown', (event) => {
    if (event.key !== 'Escape') return;

    closeSubmenus();
    setNavigationState(false);
  });

  window.addEventListener('resize', () => {
    if (!window.matchMedia('(max-width: 64rem)').matches) {
      setNavigationState(false);
    }

    closeSubmenus();
  });
}

document.addEventListener('DOMContentLoaded', () => {
  initializeThemeToggle();
  initializeNavigation();
});
