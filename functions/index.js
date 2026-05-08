const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Handle Nokia NaC 3-legged OAuth redirect.
 * This function receives the authorization code and state from Nokia
 * and presents it to the user so they can complete verification in the app.
 */
exports.nokiaCallback = functions.https.onRequest((req, res) => {
  // 1. Extract parameters from the callback URL
  // Example: https://<project>.cloudfunctions.net/redirect?code=123&state=abc
  const { code, state, error, error_description } = req.query;

  // 2. Handle errors from the operator portal
  if (error) {
    console.error('Nokia Auth Error:', error, error_description);
    return res.status(400).send(`
      <div style="font-family: sans-serif; text-align: center; padding: 50px; color: #ef4444;">
        <h2>Authorization Failed</h2>
        <p>${error_description || error}</p>
        <button onclick="window.close()" style="padding: 10px 20px; border-radius: 8px; border: none; background: #374151; color: white; cursor: pointer;">Close Window</button>
      </div>
    `);
  }

  // 3. Verify parameters exist
  if (!code || !state) {
    return res.status(400).send('Invalid request: Missing code or state');
  }

  // 4. In a production app, you might save the code to Firestore linked to the 'state' (UUID)
  // and have the app listen for changes. For this hackathon demo, we display the code 
  // for the user to manually enter, ensuring they understand the handshake.
  
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>SafeTransit AI - Verification</title>
      <style>
        body { 
          font-family: 'Space Grotesk', sans-serif; 
          background-color: #0f172a; 
          color: white; 
          display: flex; 
          flex-direction: column; 
          align-items: center; 
          justify-content: center; 
          height: 100vh; 
          margin: 0; 
        }
        .card { 
          background-color: #1e293b; 
          padding: 40px; 
          border-radius: 24px; 
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); 
          text-align: center; 
          max-width: 400px;
          border: 1px solid #334155;
        }
        h2 { color: #10b981; margin-top: 0; }
        .code-box { 
          background-color: #0f172a; 
          padding: 20px; 
          border-radius: 12px; 
          font-family: monospace; 
          font-size: 28px; 
          letter-spacing: 2px; 
          margin: 20px 0; 
          border: 1px dashed #10b981;
          color: #34d399;
        }
        p { color: #94a3b8; line-height: 1.5; }
        .copy-btn { 
          background-color: #10b981; 
          color: white; 
          padding: 12px 24px; 
          border-radius: 12px; 
          border: none; 
          font-weight: bold; 
          cursor: pointer; 
          transition: transform 0.2s;
        }
        .copy-btn:hover { transform: scale(1.05); }
      </style>
    </head>
    <body>
      <div class="card">
        <h2>Consent Verified</h2>
        <p>Your network identity has been confirmed. Please enter this code into the SafeTransit app to complete your registration:</p>
        <div class="code-box">${code}</div>
        <button class="copy-btn" onclick="navigator.clipboard.writeText('${code}')">Copy Code</button>
        <p style="font-size: 12px; margin-top: 20px;">You can close this browser window after copying.</p>
      </div>
    </body>
    </html>
  `);
});
