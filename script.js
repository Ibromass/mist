(() => {
  'use strict';

  const orderEmail = 'abolarinwaibraheem@gmail.com';
  const storageKey = 'mist-bloom-bag-v1';
  const packages = {
    fresh: { name: 'Fresh Start', price: 20000, image: 'assets/products/package-one.jpg', contents: '1 mini humidifier + 1 free Mango or Strawberry fragrance oil (customer chooses scent)' },
    double: { name: 'Double Refresh', price: 38000, image: 'assets/products/package-two.jpg', contents: '2 mini humidifiers + 2 free fragrance oils (customer chooses scents)' },
    ultimate: { name: 'Ultimate Refresh', price: 55000, image: 'assets/products/package-three.jpg', contents: '3 mini humidifiers + 3 free fragrance oils (customer chooses scents)' }
  };
  const money = new Intl.NumberFormat('en-NG', { maximumFractionDigits: 0 });
  const formatMoney = value => `NGN ${money.format(value)}`;
  const readCart = () => {
    try {
      const saved = JSON.parse(localStorage.getItem(storageKey) || '{}');
      return Object.fromEntries(Object.entries(saved).filter(([id, quantity]) => packages[id] && Number.isInteger(quantity) && quantity > 0));
    } catch (_) { return {}; }
  };
  let cart = readCart();

  const countNode = document.querySelector('.bag-count');
  const rowNode = document.querySelector('.cart-items');
  const subtotalNode = document.querySelector('.cart-subtotal');
  const emptyCart = document.querySelector('.empty-cart');
  const drawer = document.querySelector('.cart-drawer');
  const backdrop = document.querySelector('.drawer-backdrop');
  const checkout = document.querySelector('.checkout-dialog');
  const form = document.querySelector('.order-form');
  const errorNode = document.querySelector('.form-error');

  function cartCount() {
    return Object.values(cart).reduce((total, quantity) => total + quantity, 0);
  }

  function cartTotal() {
    return Object.entries(cart).reduce((total, [id, quantity]) => total + packages[id].price * quantity, 0);
  }

  function saveCart() {
    try { localStorage.setItem(storageKey, JSON.stringify(cart)); } catch (_) { /* Bag still works for this visit. */ }
  }

  function renderCart() {
    countNode.textContent = String(cartCount());
    rowNode.replaceChildren();
    for (const [id, quantity] of Object.entries(cart)) {
      const item = packages[id];
      const row = document.createElement('article');
      row.className = 'cart-row';
      row.innerHTML = `<img src="${item.image}" alt=""><div><h3>${item.name}</h3><p>${item.contents}</p><div class="quantity-controls"><button type="button" data-quantity="-1" data-package="${id}" aria-label="Remove one ${item.name}">-</button><span>${quantity}</span><button type="button" data-quantity="1" data-package="${id}" aria-label="Add one ${item.name}">+</button><button class="remove-item" type="button" data-remove="${id}">Remove</button></div></div><strong class="row-price">${formatMoney(item.price * quantity)}</strong>`;
      rowNode.append(row);
    }
    subtotalNode.textContent = formatMoney(cartTotal());
    emptyCart.classList.toggle('is-visible', cartCount() === 0);
    rowNode.hidden = cartCount() === 0;
    saveCart();
    updateCheckoutSummary();
  }

  function updateCheckoutSummary() {
    const selected = Object.entries(cart).map(([id, quantity]) => `${quantity} x ${packages[id].name}`).join(' | ');
    document.querySelector('.checkout-summary').textContent = selected ? `${selected} - ${formatMoney(cartTotal())}` : 'Your selected packages will appear here.';
  }

  function openCart() {
    drawer.classList.add('is-open');
    drawer.setAttribute('aria-hidden', 'false');
    backdrop.hidden = false;
    document.body.classList.add('drawer-open');
    drawer.querySelector('[data-close-cart]').focus();
  }

  function closeCart() {
    drawer.classList.remove('is-open');
    drawer.setAttribute('aria-hidden', 'true');
    backdrop.hidden = true;
    document.body.classList.remove('drawer-open');
  }

  function fillDateOptions() {
    const select = form.elements.date;
    const first = select.options[0];
    select.replaceChildren(first);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    ['Today', 'Tomorrow', 'Next day'].forEach((label, offset) => {
      const date = new Date(today);
      date.setDate(today.getDate() + offset);
      const option = document.createElement('option');
      option.value = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
      option.textContent = `${label} - ${new Intl.DateTimeFormat('en-NG', { day: 'numeric', month: 'long' }).format(date)}`;
      select.append(option);
    });
  }

  function openCheckout() {
    if (!cartCount()) return;
    closeCart();
    form.hidden = false;
    document.querySelector('.order-ready').hidden = true;
    errorNode.textContent = '';
    updateCheckoutSummary();
    fillDateOptions();
    checkout.showModal();
    document.body.classList.add('dialog-open');
    form.elements.name.focus();
  }

  document.querySelectorAll('[data-open-cart]').forEach(button => button.addEventListener('click', openCart));
  document.querySelectorAll('[data-close-cart]').forEach(button => button.addEventListener('click', closeCart));
  document.querySelectorAll('[data-close-checkout]').forEach(button => button.addEventListener('click', () => checkout.close()));
  checkout.addEventListener('close', () => document.body.classList.remove('dialog-open'));
  document.querySelector('.checkout-button').addEventListener('click', openCheckout);

  document.querySelectorAll('.order-now').forEach(button => button.addEventListener('click', () => {
    const id = button.dataset.order;
    cart[id] = Math.min(99, (cart[id] || 0) + 1);
    renderCart();
    openCheckout();
  }));

  rowNode.addEventListener('click', event => {
    const quantityButton = event.target.closest('[data-quantity]');
    const removeButton = event.target.closest('[data-remove]');
    if (quantityButton) {
      const id = quantityButton.dataset.package;
      cart[id] = Math.min(99, (cart[id] || 0) + Number(quantityButton.dataset.quantity));
      if (cart[id] <= 0) delete cart[id];
      renderCart();
    } else if (removeButton) {
      delete cart[removeButton.dataset.remove];
      renderCart();
    }
  });

  form.addEventListener('submit', event => {
    event.preventDefault();
    errorNode.textContent = '';
    if (!form.reportValidity()) return;
    const data = new FormData(form);
    const whatsapp = String(data.get('whatsapp')).trim();
    const phone = String(data.get('phone')).trim();
    if (whatsapp.replace(/\D/g, '').length < 8 || phone.replace(/\D/g, '').length < 8) {
      errorNode.textContent = 'Please enter valid contact numbers (at least 8 digits).';
      return;
    }

    const reference = `MB-${Date.now().toString(36).toUpperCase()}`;
    const lineItems = Object.entries(cart).map(([id, quantity]) => `- ${packages[id].name} x ${quantity} (${packages[id].contents}) - ${formatMoney(packages[id].price * quantity)}`);
    const receivedDate = new Intl.DateTimeFormat('en-NG', { day: 'numeric', month: 'long', year: 'numeric' }).format(new Date(`${data.get('date')}T12:00:00`));
    const body = [
      'MIST & BLOOM ORDER REQUEST',
      `Reference: ${reference}`,
      `Customer: ${data.get('name')}`,
      `WhatsApp: ${whatsapp}`,
      `Alternative number: ${phone}`,
      `State: ${data.get('state')}`,
      `Delivery address: ${data.get('address')}`,
      `Oil scent choice: ${String(data.get('scents') || '').trim() || 'Please confirm with customer'}`,
      `Preferred receiving date: ${receivedDate}`,
      '', 'Packages:', ...lineItems,
      `Subtotal: ${formatMoney(cartTotal())}`,
      'Delivery: Free',
      '', 'Please confirm availability and delivery arrangements with the customer.'
    ].join('\n');
    const subject = `MIST & BLOOM order request ${reference}`;
    const emailUrl = `mailto:${orderEmail}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
    document.querySelector('.email-fallback').href = emailUrl;
    form.hidden = true;
    document.querySelector('.order-ready').hidden = false;
    document.querySelector('.order-ready h2').focus?.();
    window.location.href = emailUrl;
  });

  document.querySelector('.email-fallback').addEventListener('click', () => {
    document.querySelector('.order-ready').hidden = false;
  });

  document.querySelectorAll('a[data-close-cart]').forEach(link => link.addEventListener('click', closeCart));
  document.querySelector('#year').textContent = String(new Date().getFullYear());
  renderCart();

  if ('IntersectionObserver' in window && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    const revealTargets = document.querySelectorAll('.hero-copy, .hero-media-wrap, .trust-strip, .section-heading, .benefit-card, .feature-photo-card, .package-heading, .package-card, .fragrance-heading, .fragrance-card, .showcase-copy, .showcase-photo, .video-section-copy, .demo-frame, .video-extra, .how-heading, .how-content, .last-call > div, .faq-heading, .faq-list');
    revealTargets.forEach((element, index) => {
      element.classList.add('reveal');
      if (element.matches('.benefit-card, .package-card, .fragrance-card')) element.classList.add(`reveal-delay-${(index % 3) + 1}`);
    });
    document.documentElement.classList.add('motion-ready');
    const revealObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          revealObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -35px 0px' });
    revealTargets.forEach(element => revealObserver.observe(element));
  }

  const videos = document.querySelectorAll('video[data-autoplay]');
  const soundButton = video => video.closest('.video-frame').querySelector('.sound-toggle');

  async function startVideo(video) {
    const button = soundButton(video);
    video.muted = false;
    try {
      await video.play();
      button.hidden = true;
    } catch (_) {
      video.muted = true;
      try {
        await video.play();
        button.hidden = false;
      } catch (_) {
        button.hidden = false;
      }
    }
  }

  videos.forEach(video => {
    soundButton(video).addEventListener('click', async () => {
      video.muted = false;
      try {
        await video.play();
        soundButton(video).hidden = true;
      } catch (_) {
        video.muted = true;
      }
    });
  });

  if ('IntersectionObserver' in window) {
    const videoObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        const video = entry.target;
        if (entry.isIntersecting && entry.intersectionRatio >= 0.35) startVideo(video);
        else video.pause();
      });
    }, { threshold: [0, 0.35, 0.7] });
    videos.forEach(video => videoObserver.observe(video));
  } else {
    videos.forEach(video => { video.muted = true; video.play().catch(() => {}); });
  }
})();
