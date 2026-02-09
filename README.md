# Windows EU Region Privacy Enabler v2.0

A PowerShell script that enables EU privacy options on Windows 11 by removing the DeviceRegion registry key. **Now with two modes**: choose between a safe manual process or fully automated execution.

## 🌟 What's New in v2.0

- ✅ **Dual Mode Selection** - Choose Manual (safe) or Automatic (fast)
- ✅ **Manual Mode** - No antivirus hassles, you control every step
- ✅ **Automatic Mode** - The original fully automated experience
- ✅ **Better User Experience** - Clear choice presentation with pros/cons
- ✅ **Same Great Results** - Both modes achieve the same goal

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

3. **Choose your mode**
   
   - **Option 1 - Manual**: Guided step-by-step process (recommended for first-time users)
   - **Option 2 - Automatic**: Fully automated (for advanced users comfortable with antivirus management)

4. **Follow the on-screen instructions**

5. **Restart Windows** (recommended)

## 🎯 Mode Comparison

### Manual Mode (Option 1)

**Best for:**
- First-time users
- Users who want to avoid antivirus issues
- Those who prefer to see exactly what's happening
- Anyone who wants maximum safety

**Process:**
1. Script changes your region to EU temporarily
2. Opens Registry Editor at the correct location
3. You manually delete the DeviceRegion key
4. Script restores your original region
5. Opens Privacy Settings for you to explore

**Time:** ~2 minutes  
**Risk:** Very Low  
**Antivirus Issues:** None

### Automatic Mode (Option 2)

**Best for:**
- Advanced users
- Those familiar with managing Windows Defender
- Users who want the fastest solution
- Those comfortable with temporary antivirus adjustments

**Process:**
1. Adds temporary Windows Defender exclusion
2. Downloads NanaRun (MinSudo) from GitHub
3. Extracts and runs privilege escalation tool
4. Automatically deletes DeviceRegion registry values
5. Restores original region and cleans up

**Time:** ~30 seconds  
**Risk:** Low (requires antivirus management)  
**Antivirus Issues:** May require temporary disabling

## 📋 What Both Modes Do

Both modes achieve the same result:

1. **Temporarily change region** - Set Windows region to Ireland (EU)
2. **Remove privacy restrictions** - Delete/empty the DeviceRegion registry key
3. **Restore your region** - Return to your original location setting
4. **Enable EU privacy options** - Unlock GDPR-mandated privacy controls

The only difference is **how** they accomplish this:
- Manual: You delete the registry key yourself (with guidance)
- Automatic: The script does it automatically (with elevated privileges)

## 🔒 Privacy & Security

- **Open Source** - All code is visible and auditable
- **No Data Collection** - The script doesn't collect or transmit any data
- **Minimal Changes** - Only modifies the DeviceRegion registry key
- **Automatic Cleanup** - (Auto mode) Removes all downloaded files
- **Region Restoration** - Your original region is always restored
- **No Persistence** - No permanent system modifications

## 🛠️ Technical Details

### What Gets Modified

Both modes modify the same registry location:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion
```

This key controls which privacy options are available based on geographic region. By emptying this key, Windows defaults to showing all available privacy options, including those mandated by EU regulations (GDPR).

### Tools Used (Automatic Mode Only)

- **NanaRun (MinSudo)** - [GitHub Repository](https://github.com/M2Team/NanaRun)
  - Used to run commands with TrustedInstaller privileges
  - Required because DeviceRegion key has kernel-level protection
  - Open-source privilege escalation tool by M2-Team
  - Only downloaded in Automatic mode

### Manual Mode Process

Manual mode uses built-in Windows tools only:
1. PowerShell cmdlets (`Set-WinHomeLocation`)
2. Registry Editor (regedit.exe)
3. No external downloads
4. No privilege escalation tools

## 🔧 Troubleshooting

### Manual Mode Issues

**Registry Key Won't Delete - Permission Denied**

**Solution:**
1. Right-click on the "DeviceRegion" key in Registry Editor
2. Select "Permissions..."
3. Click "Advanced"
4. Click "Change" next to the Owner name
5. Type your username and click "Check Names"
6. Click "OK" on all dialogs
7. Try deleting again

**Alternative:**
- Instead of deleting the entire key, delete all VALUES inside it
- This often works when key deletion fails

### Automatic Mode Issues

**Windows Defender Blocks Download**

**Solution:** Follow the on-screen instructions to:
1. Temporarily disable Real-time protection
2. Allow the download
3. Re-enable protection after completion

**MinSudo Won't Run**

**Solution:**
1. Open Windows Security → Protection history
2. Find MinSudo.exe in blocked items
3. Click "Allow on device"
4. Press any key to retry

**Third-Party Antivirus Interference**

**Solution:**
1. Temporarily disable your antivirus
2. Run the script
3. Re-enable protection after completion

*Or switch to Manual mode to avoid this entirely!*

## ❓ FAQ

### Which mode should I choose?

- **New to this?** → Choose Manual (Option 1)
- **Want zero antivirus hassle?** → Choose Manual (Option 1)
- **Comfortable with technical tasks?** → Either works great
- **Want fastest completion?** → Choose Automatic (Option 2)

### Is this safe?

Yes, both modes are safe. They only modify a single registry key that controls privacy options visibility. No security features are disabled and no malware is installed.

### Do both modes give the same result?

Yes! Both modes achieve exactly the same end result. The only difference is the process.

### Can I switch modes if one doesn't work?

Absolutely! If you try one mode and encounter issues, just run the script again and choose the other mode.

### Will this break Windows?

No. The modification is minimal and reversible. Windows may recreate the DeviceRegion key over time, but this doesn't cause any issues.

### Do I need to keep my region as EU?

No! Both modes automatically restore your original region after deletion. The privacy options remain available even after restoration.

### Will Windows Update undo this?

Possibly. Major Windows updates may recreate the DeviceRegion key. If this happens, simply run the script again (either mode works).

### What privacy options does this enable?

This enables various GDPR-mandated privacy controls, including:
- Enhanced app permission controls
- More granular data collection settings
- Additional privacy toggles in Windows Settings
- Improved transparency about data usage
- Location services controls
- Diagnostic data management

### Can I use this on Windows 10?

The script is designed for Windows 11. It may work on Windows 10, but this is untested.

### Why did you add Manual mode?

Many users reported antivirus interference with the automatic mode. Manual mode provides the same result without any antivirus complications, making it accessible to everyone.

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a suggestion:

1. Open an issue on GitHub
2. Submit a pull request
3. Share your feedback

## 📜 License

This project is provided "as-is" without warranty of any kind. Use at your own risk.

## 🙏 Credits

- **Script Author:** Harman Singh Hira
- **Website:** https://me.hsinghhira.me
- **Inspired by:** [YouTube Tutorial](https://www.youtube.com/watch?v=MfBNxGw_5J8&t=173s)
- **NanaRun/MinSudo:** [M2-Team](https://github.com/M2Team/NanaRun) (used in Automatic mode)

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
- Review the [FAQ](#-faq)
- Open an issue on GitHub
- Visit https://me.hsinghhira.me for contact information

---

**Made with ❤️ by Harman Singh Hira**

If this script helped you, consider:

- ⭐ Starring the repository
- 🔗 Sharing with others
- 📝 Providing feedback

## 🔄 Version History

### v2.0 (Current)
- Added dual-mode selection (Manual + Automatic)
- Improved user experience with clear mode comparison
- Manual mode eliminates all antivirus issues
- Better error handling and instructions
- Enhanced visual feedback

### v1.0
- Initial release
- Automatic mode only
- Basic antivirus handling