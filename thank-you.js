(() => {
  'use strict';
  let reference = '';
  try { reference = sessionStorage.getItem('mist-bloom-order-reference') || ''; } catch (_) { /* Show the thank-you state without a reference. */ }

  const title = document.querySelector('#thank-you-title');
  const message = document.querySelector('#thank-you-message');
  const referenceBox = document.querySelector('#thank-you-reference');
  if (reference) {
    title.textContent = 'Order request received!';
    message.textContent = 'Your order details have been sent to MIST & BLOOM. We’ll be in touch shortly.';
    document.querySelector('#order-reference').textContent = reference;
    referenceBox.hidden = false;
  } else {
    title.textContent = 'A little more comfort awaits.';
    message.textContent = 'Choose one of our humidifier offers to place an order.';
    document.querySelector('.thank-you-delivery').hidden = true;
  }
})();
