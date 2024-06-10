// Make the parameter function delay before its invocation. 
// for example, call on an input field to allow a user to type a bit before saving 
// remember to run the cleanup on unloading
function debounce(timer, func, timeout = 300) {
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func.apply(this, args);
    }, timeout);
  };
}

function clear(timer) {
  clearTimeout(timer);
}

export default function () {
  let timer;

  return {
    debounce: (func, timeout = 300) => debounce(timer, func, timeout),
    cleanupDebounce: () => clear(timer),
  };
}
