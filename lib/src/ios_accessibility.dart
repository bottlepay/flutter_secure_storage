// KeyChain accessibility attributes as defined here:
// https://developer.apple.com/documentation/security/ksecattraccessible?language=objc
enum IOSAccessibility {
  // The data in the keychain can only be accessed when the device is unlocked.
  // Only available if a passcode is set on the device.
  // Items with this attribute do not migrate to a new device.
  passcode,

  // The data in the keychain item can be accessed only while the device is unlocked by the user.
  unlocked,

  // The data in the keychain item can be accessed only while the device is unlocked by the user.
  // Items with this attribute do not migrate to a new device.
  unlocked_this_device,

  // The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  first_unlock,

  // The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  // Items with this attribute do not migrate to a new device.
  first_unlock_this_device,
}
