## 0.2.3 (base 0.4.0)
* Fixed static methods not being annotated.
* Fixed clicking property override annotations not navigating to the correct line.

## 0.2.2
* Properly wait for the language-php package to become active.

## 0.2.1
* Stop using maintainHistory to be compatible with upcoming Atom 1.3.

## 0.2.0
* Clicking annotations for overrides or implementations of built-in PHP structures will now no longer open an empty editor.
* The providers now fetch information from the base service asynchronouly using promises and the amount of calls to the service were reduced significantly, improving performance.

## 0.1.0
* Initial release.
