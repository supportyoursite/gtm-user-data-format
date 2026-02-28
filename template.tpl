___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "User Data Formatter (Email \u0026 Phone E.164)",
  "description": "Normalizes raw user input into standardized formats required for Enhanced Conversions. Formats emails (lowercase, trimmed) and phone numbers (E.164 standard with country code).",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "inputValue",
    "displayName": "Input Value (String)",
    "simpleValueType": true,
    "help": "Click the \u0027+\u0027 icon to select a GTM Variable that contains your raw string value (e.g., {{DLV - Email}} or a DOM Element Variable)."
  },
  {
    "type": "SELECT",
    "name": "formatType",
    "displayName": "Type format",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "email",
        "displayValue": "Email"
      },
      {
        "value": "phone",
        "displayValue": "Phone E.164"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "defaultCountryCode",
    "displayName": "Default Country Code (For Phone only)",
    "simpleValueType": true,
    "defaultValue": 84,
    "help": "Enter default country code without \u0027+\u0027. Example: 84 for Vietnam, 1 for US.",
    "enablingConditions": [
      {
        "paramName": "formatType",
        "paramValue": "phone",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "keepZeroCountryCodes",
    "displayName": "Keep Zero Country Codes (Comma separated)",
    "simpleValueType": true,
    "help": "Enter country codes that retain the leading 0 (e.g., 39, 225, 597). Separate by commas",
    "enablingConditions": [
      {
        "paramName": "formatType",
        "paramValue": "phone",
        "type": "EQUALS"
      }
    ],
    "defaultValue": "39, 225, 597, 378, 379"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Import required Google Tag Manager Sandboxed APIs
const makeString = require('makeString');

// 1. Get input values from the Template UI
const rawInput = data.inputValue; 
const formatType = data.formatType; 
const defaultCountryCode = data.defaultCountryCode || "84"; 
const keepZeroCountryCodes = data.keepZeroCountryCodes || "";

// 2. Validate empty or null input immediately
if (!rawInput || rawInput === "undefined" || rawInput === "null") {
  return undefined;
}

// Ensure the input is treated as a safe string
const safeString = makeString(rawInput);

// ========================================================
// 3A. FORMAT: EMAIL WITH EXTRACTION VALIDATION
// ========================================================
if (formatType === 'email') {
  let cleanString = safeString.toLowerCase();
  
  // Replace common whitespaces (tabs, newlines) with standard spaces
  let normalizedString = "";
  for (let i = 0; i < cleanString.length; i++) {
    let char = cleanString.charAt(i);
    if (char === '\n' || char === '\r' || char === '\t') {
      normalizedString += " ";
    } else {
      normalizedString += char;
    }
  }
  
  // Split the string into individual words by space
  let parts = normalizedString.split(' ');
  
  // Loop through each word to find and extract the first valid email
  for (let i = 0; i < parts.length; i++) {
    let part = parts[i].trim();
    if (part.length === 0) continue;
    
    let atIndex = part.indexOf('@');
    let dotIndex = part.lastIndexOf('.');
    
    // Check if the specific word has correct email characteristics
    if (atIndex > 0 && dotIndex > atIndex + 1 && dotIndex < part.length - 1) {
      // Ensure there is only one '@' symbol in this word
      if (part.indexOf('@', atIndex + 1) === -1) {
        return part; // Exactly extracted email (e.g., hello@domain.com)
      }
    }
  }
  
  // If no valid email word is found in the entire string
  return undefined; 
}

// ========================================================
// 3B. FORMAT: PHONE NUMBER (E.164) WITH EXCEPTION HANDLING
// ========================================================
if (formatType === 'phone') {
  let safeStringTrimmed = safeString.trim();
  let hasPlus = safeStringTrimmed.charAt(0) === '+';
  
  let digitsOnly = "";
  
  // Extract only numeric characters
  for (let i = 0; i < safeString.length; i++) {
    let char = safeString.charAt(i);
    if (char >= '0' && char <= '9') {
      digitsOnly += char;
    }
  }
  
  // Validation: A valid phone number usually has at least 7 digits
  if (digitsOnly.length < 7) {
    return undefined;
  }

  // Clean the default country code
  let cleanCountryCode = "";
  let countryCodeStr = makeString(defaultCountryCode);
  for (let j = 0; j < countryCodeStr.length; j++) {
    let c = countryCodeStr.charAt(j);
    if (c >= '0' && c <= '9') {
      cleanCountryCode += c;
    }
  }
  if (cleanCountryCode === "") cleanCountryCode = "84"; 

  // Parse keepZeroCountryCodes into an array of clean numbers
  let keepZeroStr = makeString(keepZeroCountryCodes);
  let keepZeroList = [];
  if (keepZeroStr) {
     let parts = keepZeroStr.split(',');
     for (let k = 0; k < parts.length; k++) {
        let p = parts[k].trim();
        let cleanP = "";
        for (let m = 0; m < p.length; m++) {
           if (p.charAt(m) >= '0' && p.charAt(m) <= '9') cleanP += p.charAt(m);
        }
        if (cleanP) keepZeroList.push(cleanP);
     }
  }

  let activeCC = cleanCountryCode;
  let localPart = digitsOnly;
  
  // Determine active Country Code by checking if input starts with known CCs
  let possibleCCs = [cleanCountryCode].concat(keepZeroList);
  
  // Sort by length descending so longer codes (e.g. 597) match before shorter ones (e.g. 59)
  possibleCCs.sort(function(a, b) { return b.length - a.length; });
  
  let foundCC = false;
  for (let i = 0; i < possibleCCs.length; i++) {
     let cc = possibleCCs[i];
     if (digitsOnly.indexOf(cc) === 0) {
         activeCC = cc;
         localPart = digitsOnly.substring(cc.length); // Extract the rest as local part
         foundCC = true;
         break;
     }
  }
  
  // If user typed a '+' but the CC is unknown, return as-is with '+' attached
  if (!foundCC && hasPlus) {
     if (digitsOnly.length < 9 || digitsOnly.length > 15) {
         return undefined;
     }
     return '+' + digitsOnly;
  }

  // Determine if we should keep the leading zero based on activeCC
  let shouldKeepZero = false;
  for (let i = 0; i < keepZeroList.length; i++) {
     if (activeCC === keepZeroList[i]) {
         shouldKeepZero = true;
         break;
     }
  }

  // Remove leading zero from local part ONLY IF it's not in the keep list
  if (!shouldKeepZero) {
     if (localPart.charAt(0) === '0') {
         localPart = localPart.substring(1);
     }
  }

  // Combine components into final E.164 format
  let finalPhone = '+' + activeCC + localPart;
  
  // Validation: Final output digits length must be between 9 and 15
  let finalDigitsLength = activeCC.length + localPart.length;
  if (finalDigitsLength < 9 || finalDigitsLength > 15) {
      return undefined;
  }
  
  return finalPhone;
}

// 4. Final Fallback if nothing matches
return undefined;


___TESTS___

scenarios:
- name: Format Email - Success
  code: |-
    // Set up mock input (mock data)
    let mockData = {
      inputValue: "  Join.Kennery@GMAIL.com  ",
      formatType: "email"
    };

    // Call template with mock data
    let result = runCode(mockData);

    // Result:
    assertThat(result).isEqualTo("join.kennery@gmail.com");
- name: Format Phone - Local Number
  code: "let mockData = {\n  inputValue: \"090 123-4567\",\n  formatType: \"phone\"\
    ,\n  defaultCountryCode: \"84\" \n};\n\nlet result = runCode(mockData);\nassertThat(result).isEqualTo(\"\
    +84901234567\");"
- name: Format Phone - Already has Country Code
  code: "let mockData = {\n  inputValue: \"+84 901 234 567\", \n  formatType: \"phone\"\
    ,\n  defaultCountryCode: \"84\"\n};\n\nlet result = runCode(mockData);\nassertThat(result).isEqualTo(\"\
    +84901234567\");"
- name: Handle Empty/Null Input
  code: |-
    // Set input to empty
    let mockData = {
      inputValue: "",
      formatType: "email"
    };

    // Call template
    let result = runCode(mockData);

    // Check if the expected result is undefined
    assertThat(result).isUndefined();


___NOTES___

Created on 2/28/2026, 2:10:48 PM


