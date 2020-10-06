#Purpose: Set the boxes to be located in the UK and fix the keyboard.

#Applications that don't support unicode will use en-GB. Requires restart.
Set-WinSystemLocale -SystemLocale en-GB

#Force UK Keyboard setting
Set-WinUserLanguageList -LanguageList en-GB -Force

# 242 = UK
Set-WinHomeLocation -GeoId 242
Set-TimeZone -name "GMT Standard Time"