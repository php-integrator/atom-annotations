## 1.2.0 (base 3.0.0)
* Upgrade to base 3.0.0.

## 1.1.1
* Fix deprecations.

## 1.1.0 (base 2.0.0)
* The dependency on `sub-atom` has been removed.
* Annotations that are obscuring code folds in the gutter will no longer trigger them.
* Annotations will no longer constantly flicker whenever indexing occurs (i.e. whenever the buffer changes).
* Performance should have improved a bit as fewer event handlers are constantly being registered and removed.
* The PHP documentation will now be openend when clicking an implementation or override of a built-in class or interface.

## 1.0.3
* Rename the package and repository.

## 1.0.2
* Fix an accidental incorrect release.

## 1.0.1
* Fix the version specifier not being compatible with newer versions of the base service.

## 1.0.0 (base 1.0.0)
* Updated to work with the most recent service from the base package.

## 0.4.1 (base 0.9.0)
* Improve performance by removing the need for regular expression scanning.

## 0.4.0 (base 0.8.0)
* "Overrides" for abstract methods will now be shown in a different color and with a different tooltip to allow a visual distinction between them and actual overrides as the former are more "implementation" and don't actually remove any existing functionality by overriding.

## 0.3.2 (base 0.7.0)
* Updated to work with the most recent service from the base package.

## 0.3.1
* Catch exceptions properly.

## 0.3.0 (base 0.6.0)
* Files with multiple classes should now properly have their annotations registered, instead of just the first.
* Overrides for methods and properties originating from a trait in the *same* class will now list the name of the trait instead of the class name itself. Without this, if `Foo` overrides a method from one of its own traits, the annotation would list `Overrides method from Foo`, which is confusing.

## 0.2.4 (base 0.5.0)
* Annotations will now be rescanned when indexing succeeds instead of on save.

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
