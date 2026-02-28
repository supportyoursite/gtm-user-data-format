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
    "type": "SELECT",
    "name": "formatType",
    "displayName": "Type format",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "both",
        "displayValue": "Both (Email \u0026 Phone E.164)"
      },
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
    "name": "emailInput",
    "displayName": "Email Input Value (String)",
    "simpleValueType": true,
    "help": "Click the \u0027+\u0027 icon to select a GTM Variable that contains your raw string value (e.g., {{DLV - Email}} or a DOM Element Variable).",
    "enablingConditions": [
      {
        "paramName": "formatType",
        "paramValue": "phone",
        "type": "NOT_EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "phoneInput",
    "displayName": "Phone Input Value (String)",
    "simpleValueType": true,
    "help": "Click the \u0027+\u0027 icon to select a GTM Variable that contains your raw string value (e.g., {{DLV - Email}} or a DOM Element Variable).",
    "enablingConditions": [
      {
        "paramName": "formatType",
        "paramValue": "email",
        "type": "NOT_EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "defaultCountryCode",
    "displayName": "Default Country Code (For Phone only)",
    "simpleValueType": true,
    "defaultValue": "84",
    "help": "Enter default country code without \u0027+\u0027. Example: 84 for Vietnam, 1 for US.",
    "enablingConditions": [
      {
        "paramName": "formatType",
        "paramValue": "email",
        "type": "NOT_EQUALS"
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
        "paramValue": "email",
        "type": "NOT_EQUALS"
      }
    ],
    "defaultValue": "39, 225, 597, 378, 379"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Import required Google Tag Manager Sandboxed APIs
const makeString = require('makeString');

// 1. Get input values from the Template UI
const formatType = data.formatType; 
const rawEmail = data.emailInput; 
const rawPhone = data.phoneInput;
const defaultCountryCode = data.defaultCountryCode || "84"; 
const keepZeroCountryCodes = data.keepZeroCountryCodes || "";

// ========================================================
// HELPER FUNCTION: FORMAT EMAIL
// ========================================================
function formatEmail(inputStr) {
  if (!inputStr || inputStr === "undefined" || inputStr === "null") return undefined;
  
  let safeString = makeString(inputStr);
  let cleanString = safeString.toLowerCase();
  
  // Replace common whitespaces
  let normalizedString = "";
  for (let i = 0; i < cleanString.length; i++) {
    let char = cleanString.charAt(i);
    if (char === '\n' || char === '\r' || char === '\t') {
      normalizedString += " ";
    } else {
      normalizedString += char;
    }
  }
  
  let parts = normalizedString.split(' ');
  for (let i = 0; i < parts.length; i++) {
    let part = parts[i].trim();
    if (part.length === 0) continue;
    
    let atIndex = part.indexOf('@');
    let dotIndex = part.lastIndexOf('.');
    
    if (atIndex > 0 && dotIndex > atIndex + 1 && dotIndex < part.length - 1) {
      if (part.indexOf('@', atIndex + 1) === -1) {
        return part; 
      }
    }
  }
  return undefined;
}

// ========================================================
// HELPER FUNCTION: FORMAT PHONE E.164
// ========================================================
function formatPhone(inputStr) {
  if (!inputStr || inputStr === "undefined" || inputStr === "null") return undefined;
  
  let safeString = makeString(inputStr);
  let safeStringTrimmed = safeString.trim();
  let hasPlus = safeStringTrimmed.charAt(0) === '+';
  
  let digitsOnly = "";
  for (let i = 0; i < safeString.length; i++) {
    let char = safeString.charAt(i);
    if (char >= '0' && char <= '9') digitsOnly += char;
  }
  
  if (digitsOnly.length < 7) return undefined;

  let cleanCountryCode = "";
  let countryCodeStr = makeString(defaultCountryCode);
  for (let j = 0; j < countryCodeStr.length; j++) {
    let c = countryCodeStr.charAt(j);
    if (c >= '0' && c <= '9') cleanCountryCode += c;
  }
  if (cleanCountryCode === "") cleanCountryCode = "84"; 

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
  
  let possibleCCs = [cleanCountryCode].concat(keepZeroList);
  possibleCCs.sort(function(a, b) { return b.length - a.length; });
  
  let foundCC = false;
  for (let i = 0; i < possibleCCs.length; i++) {
     let cc = possibleCCs[i];
     if (digitsOnly.indexOf(cc) === 0) {
         activeCC = cc;
         localPart = digitsOnly.substring(cc.length); 
         foundCC = true;
         break;
     }
  }
  
  if (!foundCC && hasPlus) {
     if (digitsOnly.length < 9 || digitsOnly.length > 15) return undefined;
     return '+' + digitsOnly;
  }

  let shouldKeepZero = false;
  for (let i = 0; i < keepZeroList.length; i++) {
     if (activeCC === keepZeroList[i]) {
         shouldKeepZero = true;
         break;
     }
  }

  if (!shouldKeepZero) {
     if (localPart.charAt(0) === '0') localPart = localPart.substring(1);
  }

  let finalPhone = '+' + activeCC + localPart;
  
  let finalDigitsLength = activeCC.length + localPart.length;
  if (finalDigitsLength < 9 || finalDigitsLength > 15) return undefined;
  
  return finalPhone;
}

// ========================================================
// MAIN EXECUTION LOGIC
// ========================================================

if (formatType === 'email') {
  return formatEmail(rawEmail);
}

if (formatType === 'phone') {
  return formatPhone(rawPhone);
}

if (formatType === 'both') {
  let processedEmail = formatEmail(rawEmail);
  let processedPhone = formatPhone(rawPhone);
  
  // Nếu cả hai đều không hợp lệ (undefined), trả về undefined cho toàn bộ Object
  if (!processedEmail && !processedPhone) {
    return undefined;
  }
  
  // Xây dựng Object kết quả
  let resultObject = {};
  
  if (processedEmail) {
    resultObject.email = processedEmail;
  }
  
  if (processedPhone) {
    resultObject.phone_number = processedPhone;
  }
  
  return resultObject;
}

return undefined;


___TESTS___

scenarios:
- name: Format Email - Success
  code: |-
    // Set up mock input (mock data)
    let mockData = {
      emailInput: "  Join.Kennery@GMAIL.com  ",
      formatType: "email"
    };

    // Call template with mock data
    let result = runCode(mockData);

    // Result:
    assertThat(result).isEqualTo("join.kennery@gmail.com");
- name: Format Phone - Local Number
  code: "let mockData = {\n  phoneInput: \"090 123-4567\",\n  formatType: \"phone\"\
    ,\n  defaultCountryCode: \"84\" \n};\n\nlet result = runCode(mockData);\nassertThat(result).isEqualTo(\"\
    +84901234567\");"
- name: Format Phone - Already has Country Code
  code: "let mockData = {\n  phoneInput: \"+84 901 234 567\", \n  formatType: \"phone\"\
    ,\n  defaultCountryCode: \"84\"\n};\n\nlet result = runCode(mockData);\nassertThat(result).isEqualTo(\"\
    +84901234567\");"
- name: Handle Empty/Null Input
  code: |-
    // Set input to empty
    let mockData = {
      emailInput: "",
      formatType: "email"
    };

    // Call template
    let result = runCode(mockData);

    // Check if the expected result is undefined
    assertThat(result).isUndefined();
- name: Check Return Object
  code: "let mockData = {\n  emailInput: \"testAbc@Gmail.com\", \n  phoneInput: \"\
    0901 234 567\", \n  formatType: \"both\",\n  defaultCountryCode: \"84\"\n};\n\n\
    let result = runCode(mockData);\nassertThat(result).isEqualTo({email: \"testabc@gmail.com\"\
    , phone_number: \"+84901234567\"});\n// Call runCode to run the template's code.\n\
    let variableResult = runCode(mockData);\n\n// Verify that the variable returns\
    \ a result.\nassertThat(variableResult).isNotEqualTo(undefined);"


___NOTES___

Created on 2/28/2026, 8:59:19 PM


