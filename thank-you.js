(() => {
  'use strict';
  let reference = '';
  try { reference = sessionStorage.getItem('mist-bloom-order-reference') || ''; } catch (_) { /* Show the thank-you state without a reference. */ }

  const title = document.querySelector('#thank-you-title');
  const message = document.querySelector('#thank-you-message');
  const referenceBox = document.querySelector('#thank-you-reference');
  const whatsapp = document.querySelector('#thank-you-whatsapp');
  if (reference) {
    title.textContent = 'Order request received!';
    message.textContent = 'Your order details have been sent to Aroma Mist & Bloom. We’ll be in touch shortly.';
    document.querySelector('#order-reference').textContent = reference;
    referenceBox.hidden = false;
    whatsapp.href = `https://wa.me/2348088160543?text=${encodeURIComponent(`Hello Aroma Mist & Bloom, I just placed an order. My reference is ${reference}.`)}`;
  } else {
    title.textContent = 'A little more comfort awaits.';
    message.textContent = 'Choose one of our Aroma Mist & Bloom diffuser offers to place an order.';
    document.querySelector('.thank-you-delivery').hidden = true;
  }
})();
