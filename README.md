# Windows EU Region Privacy Enabler

A PowerShell script that enables EU privacy options on Windows 11 by removing the DeviceRegion registry key, allowing access to enhanced privacy settings normally only available to users in the European Union.

## 🌟 Features

- ✅ **Fully Automated** - One command does everything
- ✅ **Safe & Reversible** - Automatically restores your original region
- ✅ **Smart Detection** - Handles Windows Defender and antivirus interference
- ✅ **No Manual Downloads** - Automatically downloads and extracts required tools
- ✅ **Clean Execution** - Removes all temporary files after completion
- ✅ **User-Friendly** - Clear progress indicators and helpful error messages

## 🚀 Quick Start

### Prerequisites

- Windows 11 (any edition)
- PowerShell 5.1 or later
- Administrator privileges

### Installation & Usage

1. **Open PowerShell as Administrator**
   
   - Press `Win + X`
   - Select "Windows PowerShell (Admin)" or "Terminal (Admin)"
2. **Run the script**

```powershell
irm https://wineu.hsinghhira.me | iex
```

3. **Follow the on-screen instructions**
   
   - The script will guide you through any antivirus-related issues
   - Wait for completion (usually 30-60 seconds)
4. **Restart Windows** (recommended)
   
   - Restart your computer to see all EU privacy options

## 📋 What It Does

1. **Adds temporary Windows Defender exclusion** - Prevents antivirus from blocking the tool
2. **Downloads NanaRun (MinSudo)** - Downloads the privilege escalation tool from GitHub
3. **Extracts NanaRun** - Unpacks the tool to a temporary directory
4. **Deletes DeviceRegion registry values** - Removes the registry values that restrict EU privacy features
5. **Restores your original region** - Returns your Windows region to its original setting
6. **Cleans up** - Removes all temporary files and exclusions

## 🔒 Privacy & Security

- **Open Source** - All code is visible and auditable
- **No Data Collection** - The script doesn't collect or transmit any data
- **Temporary Changes Only** - Only modifies the DeviceRegion registry key
- **Automatic Cleanup** - Removes all downloaded files after execution
- **Region Restoration** - Your original region setting is automatically restored

## 🛠️ Technical Details

### What Gets Modified

The script modifies:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion
```

This registry key controls which privacy options are available based on your geographic region. By emptying this key, Windows defaults to showing all available privacy options, including those mandated by EU regulations (GDPR).

### Tools Used

- **NanaRun (MinSudo)** - [GitHub Repository](https://github.com/M2Team/NanaRun)
  - Used to run commands with TrustedInstaller privileges
  - Required because the DeviceRegion key has kernel-level protection
  - Open-source privilege escalation tool by M2-Team

### How It Works

1. The script temporarily changes your region to Ireland (GeoID: 94)
2. Deletes the DeviceRegion registry values using TrustedInstaller privileges
3. Restores your original region
4. Windows now displays EU privacy options regardless of your actual location

## 🐛 Troubleshooting

### Windows Defender Blocks Download

**Symptom:** Download fails with "Access Denied" or antivirus warning

**Solution:** The script will guide you through:

1. Opening Windows Security
2. Temporarily disabling Real-time protection
3. Allowing the download
4. Re-enabling protection after completion

### MinSudo Won't Run

**Symptom:** "MinSudo execution failed" error

**Solution:**

1. Open Windows Security
2. Go to "Protection history"
3. Find MinSudo.exe in the blocked items
4. Click "Allow on device"
5. Press any key to retry (the script will wait for you)

### DeviceRegion Key Still Has Values

**Symptom:** Script shows "Some values may remain"

**Solution:**

- This is rare but can happen with certain Windows configurations
- Try running the script again
- If it persists, the EU privacy options may still be available despite the warning

### Third-Party Antivirus Interference

**Symptom:** Norton, McAfee, Avast, etc. blocking the script

**Solution:**

1. Open your antivirus program
2. Temporarily disable real-time protection
3. Run the script
4. Re-enable protection after completion

## ❓ FAQ

### Is this safe?

Yes. The script only modifies a single registry key that controls privacy options visibility. It doesn't disable security features or install malware.

### Will this break Windows?

No. The modification is minimal and reversible. Windows may recreate the DeviceRegion key over time, but this doesn't cause any issues.

### Do I need to keep my region as EU?

No! The script automatically restores your original region after deletion. The privacy options remain available even after restoration.

### Will Windows Update undo this?

Possibly. Major Windows updates may recreate the DeviceRegion key. If this happens, simply run the script again.

### What privacy options does this enable?

This enables various GDPR-mandated privacy controls, including:

- Enhanced app permission controls
- More granular data collection settings
- Additional privacy toggles in Windows Settings
- Improved transparency about data usage

### Can I use this on Windows 10?

The script is designed for Windows 11. It may work on Windows 10, but this is untested.

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a suggestion:

1. Open an issue on GitHub
2. Submit a pull request
3. Contact me at [your contact method]

## 📜 License

This project is provided "as-is" without warranty of any kind. Use at your own risk.

## 🙏 Credits

- **Script Author:** Harman Singh Hira
- **Website:** https://me.hsinghhira.me
- **Inspired by:** [YouTube Tutorial](https://www.youtube.com/watch?v=MfBNxGw_5J8&t=173s)
- **NanaRun/MinSudo:** [M2-Team](https://github.com/M2Team/NanaRun)

## ⚠️ Disclaimer

This tool is for educational purposes. Modifying Windows registry settings can affect system stability. Always:

- Create a system restore point before running
- Understand what the script does
- Use on a test system first if possible
- Back up important data

The author is not responsible for any damage caused by using this script.

## 📞 Support

If you need help:

- Check the [Troubleshooting](#-troubleshooting) section
- Open an issue on GitHub
- Visit https://me.hsinghhira.me for contact information

---

**Made with ❤️ by Harman Singh Hira**

If this script helped you, consider:

- ⭐ Starring the repository
- 🔗 Sharing with others
- 📝 Providing feedback

