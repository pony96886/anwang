let deferredPrompt;
// let events = new Event('beforeinstallprompt');
// window.dispatchEvent(events);
// add to homescreen
window.addEventListener("beforeinstallprompt", (e) => {
  // Prevent Chrome 67 and earlier from automatically showing the prompt
  e.preventDefault();
  // Stash the event so it can be triggered later.
  deferredPrompt = e;
});

function isDeferredNotNull() {
  return deferredPrompt != null;
}

function checkSafari(){
    const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent); 
    return isSafari;
}

function getInstallValue(){
  var isInstall = localStorage.getItem("is_install");
  return isInstall === null ? "0" : isInstall;
}

function presentAddToHome() {
  if (deferredPrompt != null) {
    // Update UI to notify the user they can add to home screen
    // Show the prompt
    deferredPrompt.prompt();
    // Wait for the user to respond to the prompt
    deferredPrompt.userChoice.then((choiceResult) => {
      if (choiceResult.outcome === "accepted") {
        console.log("User accepted the A2HS prompt");
        localStorage.setItem("is_install", "1");
        deferredPrompt = null;
      } else {
        console.log("User dismissed the A2HS prompt");
        localStorage.setItem("is_install", "0");
      }
    });
  } else {
    console.log("deferredPrompt is null");
  }
}