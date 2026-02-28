User Data Formatter (Email & E.164) for GTM

A Custom Variable Template for Google Tag Manager (GTM) designed to clean, format, and validate raw user input data (Emails and Phone Numbers). This template is specifically built to prepare first-party data for Google Ads Enhanced Conversions, Meta Conversions API (CAPI), and other marketing tags that require strict data formatting.

🌟 Key Features

Email Formatting: Automatically trims whitespaces, converts strings to lowercase, and performs basic structural validation (checks for @ and .).

Phone E.164 Formatting: Extracts numeric characters from messy inputs (e.g., 090 123-4567 becomes +84901234567).

Smart Country Code Handling: Automatically appends the default country code if the user omits it.

"Keep Zero" Exceptions: Supports specific country codes (like Italy +39, Ivory Coast +225, Suriname +597) where the leading zero of the local number must be retained.

Sandbox Safe: 100% compliant with GTM Sandbox JS APIs. No complex Regex that could cause ReDoS vulnerabilities or performance issues.


🚀 How to Use

Add to Workspace: Add this template to your GTM Workspace from the Community Template Gallery.

Create a New Variable: Go to Variables > User-Defined Variables > New. Select User Data Formatter (Email & E.164) as the variable type.

Configure the Variable:

Input Value (String): Select the GTM variable that contains your raw user input (e.g., a DOM Element variable targeting an input field, or a Data Layer Variable).

Type format: Choose either Email or Phone E.164.

Default Country Code: (For Phone only) Enter your default country code without the + sign (e.g., 84 for Vietnam, 1 for US).

Keep Zero Country Codes: (For Phone only) Enter a comma-separated list of country codes that require keeping the leading zero (e.g., 39, 225, 597).


💡 Use Cases

Google Ads Enhanced Conversions: Map the output of this variable directly into the Google Ads "User-Provided Data" variable. The Google Ads tag will automatically hash (SHA-256) this clean data before sending it.

Data Layer Standardization: Clean up messy form inputs before pushing them to your analytics tools or backend databases.


⚠️ Notes

If the input value does not meet the minimum validation criteria (e.g., an email missing an @, or a phone number with fewer than 7 digits), the variable will safely return undefined to prevent sending invalid or junk data to your advertising platforms.

Created for the GTM Community to simplify data formatting.
