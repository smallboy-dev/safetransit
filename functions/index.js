const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

admin.initializeApp();

let db;
try {
  db = admin.firestore();
  db.settings({ ignoreUndefinedProperties: true });
} catch (e) {
  console.error('Firestore init failed:', e.message);
}

const NOKIA_API_KEY = '35552c2071msh27670bfc90849a6p1639b3jsn0041b59fd1f1';
const RAPIDAPI_HOST = 'network-as-code.nokia.rapidapi.com';
const NAC_BASE_URL = 'https://network-as-code.p-eu.rapidapi.com';

exports.nokiaCallback = functions.https.onRequest((req, res) => {
  const { code, state, error, error_description } = req.query;

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

  if (!code || !state) {
    return res.status(400).send('Invalid request: Missing code or state');
  }

  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>SafeTransit AI - Verification</title>
      <style>
        body { font-family: sans-serif; background-color: #0f172a; color: white; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .card { background-color: #1e293b; padding: 40px; border-radius: 24px; text-align: center; max-width: 400px; border: 1px solid #334155; }
        h2 { color: #10b981; }
        .code-box { background-color: #0f172a; padding: 20px; border-radius: 12px; font-family: monospace; font-size: 28px; margin: 20px 0; border: 1px dashed #10b981; color: #34d399; }
        .copy-btn { background-color: #10b981; color: white; padding: 12px 24px; border-radius: 12px; border: none; font-weight: bold; cursor: pointer; }
      </style>
    </head>
    <body>
      <div class="card">
        <h2>Consent Verified</h2>
        <p>Your network identity has been confirmed. Enter this code into the SafeTransit app:</p>
        <div class="code-box">${code}</div>
        <button class="copy-btn" onclick="navigator.clipboard.writeText('${code}')">Copy Code</button>
      </div>
    </body>
    </html>
  `);
});

const corsHandler = require('cors')({ origin: true });

const cors = (req, res) => new Promise((resolve, reject) => {
  corsHandler(req, res, (result) => {
    if (result instanceof Error) {
      return reject(result);
    }
    return resolve(result);
  });
});

function sanitizeResponse(data) {
  if (data === null || data === undefined) return data;
  
  if (Array.isArray(data)) {
    return data.map(sanitizeResponse);
  }
  
  if (typeof data === 'object') {
    const sanitized = {};
    for (const key in data) {
      sanitized[key] = sanitizeResponse(data[key]);
    }
    return sanitized;
  }
  
  if (typeof data === 'number') {
    return data.toString();
  }
  
  return data;
}

exports.createReachabilitySubscription = functions.https.onRequest(async (req, res) => {
  
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, x-rapidapi-key, x-rapidapi-host, x-correlator');

  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  try {
    const { phoneNumber, driverId } = req.body;
    console.log('--- NAC SUBSCRIPTION REQUEST ---');
    console.log('Payload:', JSON.stringify(req.body, null, 2));
    
    if (!phoneNumber) {
      return res.status(400).json({ success: false, error: 'Missing phoneNumber' });
    }

    const sinkUrl = 'https://notifications-p3t6yvrbja-uc.a.run.app';
    const correlator = uuidv4();

    const payload = {
      sink: sinkUrl,
      protocol: "HTTP",
      types: ["org.camaraproject.device-reachability-status-subscriptions.v0.reachability-data"],
      config: {
        subscriptionDetail: {
          device: { 
            
            phoneNumber: phoneNumber.replace(/^tel:/, '')
          }
        },
        subscriptionMaxEvents: 5,
        initialEvent: true
      }
    };

    const headers = {
      'Content-Type': 'application/json',
      'x-rapidapi-key': NOKIA_API_KEY,
      'x-rapidapi-host': RAPIDAPI_HOST,
      'x-correlator': correlator
    };

    console.log('Calling NaC API...');
    const response = await axios.post(
      `${NAC_BASE_URL}/device-status/device-reachability-status-subscriptions/v0.7/subscriptions`,
      payload,
      { headers }
    );

    console.log('--- NAC SUBSCRIPTION SUCCESS ---');
    console.log('Status:', response.status);
    console.log('Data (full):', JSON.stringify(response.data, null, 2));

    const subId = response.data.subscriptionId || response.data.id || response.data.subscription_id || null;

    if (driverId && subId) {
      try {
        await db.collection('drivers').doc(driverId).set({
          subscriptionId: subId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
        console.log(`Stored subId ${subId} for driver ${driverId}`);
      } catch (fsError) {
        console.warn('Non-fatal Firestore error:', fsError.message);
      }
    }

    const result = JSON.parse(JSON.stringify(sanitizeResponse(response.data)));
    return res.json(result);

  } catch (error) {
    const errorData = error.response ? error.response.data : error.message;
    console.error('Subscription Error:', JSON.stringify(errorData));
    
    return res.status(500).json({
      success: false,
      error: errorData
    });
  }
});

exports.getReachabilitySubscriptions = functions.https.onRequest(async (req, res) => {
  try {
    await cors(req, res);
    const response = await axios.get(
      `${NAC_BASE_URL}/device-status/device-reachability-status-subscriptions/v0.7/subscriptions`,
      {
        headers: {
          'x-rapidapi-key': NOKIA_API_KEY,
          'x-rapidapi-host': RAPIDAPI_HOST
        }
      }
    );
    const result = JSON.parse(JSON.stringify(sanitizeResponse(response.data)));
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

exports.getReachabilitySubscriptionById = functions.https.onRequest(async (req, res) => {
  try {
    await cors(req, res);
    const { subscriptionId } = req.query;
    const response = await axios.get(
      `${NAC_BASE_URL}/device-status/device-reachability-status-subscriptions/v0.7/subscriptions/${subscriptionId}`,
      {
        headers: {
          'x-rapidapi-key': NOKIA_API_KEY,
          'x-rapidapi-host': RAPIDAPI_HOST
        }
      }
    );
    const result = JSON.parse(JSON.stringify(sanitizeResponse(response.data)));
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

exports.deleteReachabilitySubscription = functions.https.onRequest(async (req, res) => {
  try {
    await cors(req, res);
    const { subscriptionId } = req.query;
    await axios.delete(
      `${NAC_BASE_URL}/device-status/device-reachability-status-subscriptions/v0.7/subscriptions/${subscriptionId}`,
      {
        headers: {
          'x-rapidapi-key': NOKIA_API_KEY,
          'x-rapidapi-host': RAPIDAPI_HOST
        }
      }
    );
    return res.json({ success: "true" });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

exports.createGeofencingSubscription = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, x-rapidapi-key, x-rapidapi-host, x-correlator');

  if (req.method === 'OPTIONS') return res.status(204).send('');

  try {
    const { phoneNumber, driverId, latitude, longitude, radius } = req.body;
    console.log('--- GEOFENCING SUBSCRIPTION REQUEST ---');
    
    if (!phoneNumber || !latitude || !longitude) {
      return res.status(400).json({ success: false, error: 'Missing required fields' });
    }

    const sinkUrl = 'https://notifications-p3t6yvrbja-uc.a.run.app';
    
    const payload = {
      protocol: "HTTP",
      sink: sinkUrl,
      types: [
        "org.camaraproject.geofencing-subscriptions.v0.area-entered",
        "org.camaraproject.geofencing-subscriptions.v0.area-left"
      ],
      config: {
        subscriptionDetail: {
          device: { phoneNumber: phoneNumber.replace(/^tel:/, '') },
          area: {
            areaType: "CIRCLE",
            center: { latitude: parseFloat(latitude), longitude: parseFloat(longitude) },
            radius: parseInt(radius || 300)
          }
        },
        initialEvent: true,
        subscriptionMaxEvents: 10
      }
    };

    const headers = {
      'Content-Type': 'application/json',
      'x-rapidapi-key': NOKIA_API_KEY,
      'x-rapidapi-host': RAPIDAPI_HOST
    };

    const response = await axios.post(
      `${NAC_BASE_URL}/geofencing-subscriptions/v0.3/subscriptions`,
      payload,
      { headers }
    );

    const subId = response.data.subscriptionId || response.data.id || null;
    
    if (driverId && subId) {
      await db.collection('drivers').doc(driverId).collection('geofences').add({
        subscriptionId: subId,
        center: { latitude: parseFloat(latitude), longitude: parseFloat(longitude) },
        radius: parseInt(radius || 300),
        status: 'active',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    return res.json(sanitizeResponse(response.data));
  } catch (error) {
    console.error('Geofencing Error:', error.response ? error.response.data : error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
});

exports.getGeofencingSubscriptions = functions.https.onRequest(async (req, res) => {
  try {
    await cors(req, res);
    const response = await axios.get(
      `${NAC_BASE_URL}/geofencing-subscriptions/v0.3/subscriptions`,
      { headers: { 'x-rapidapi-key': NOKIA_API_KEY, 'x-rapidapi-host': RAPIDAPI_HOST } }
    );
    return res.json(sanitizeResponse(response.data));
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

exports.deleteGeofencingSubscription = functions.https.onRequest(async (req, res) => {
  try {
    await cors(req, res);
    const { subscriptionId } = req.query;
    await axios.delete(
      `${NAC_BASE_URL}/geofencing-subscriptions/v0.3/subscriptions/${subscriptionId}`,
      { headers: { 'x-rapidapi-key': NOKIA_API_KEY, 'x-rapidapi-host': RAPIDAPI_HOST } }
    );
    return res.json({ success: true });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

exports.notifications = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');

  const notification = req.body;
  console.log('Received Notification:', JSON.stringify(notification));

  try {
    const data = notification.event || notification.data || {};
    const subscriptionId = data.subscriptionId || notification.subscriptionId;
    const eventType = notification.type || (notification.event ? notification.event.eventType : null);

    if (!subscriptionId) return res.status(200).send('OK');

    if (eventType === 'org.camaraproject.device-reachability-status-subscriptions.v0.reachability-data' || !eventType) {
      const reachable = data.reachable !== undefined ? data.reachable : (notification.event?.eventDetail?.reachable || false);
      const connectivity = data.connectivity || notification.event?.eventDetail?.connectivity || [];
      
      const snapshot = await db.collection('drivers').where('subscriptionId', '==', subscriptionId).limit(1).get();
      if (!snapshot.empty) {
        await snapshot.docs[0].ref.update({
          reachable,
          connectivity,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }

    if (eventType === 'org.camaraproject.geofencing-subscriptions.v0.area-entered' || 
        eventType === 'org.camaraproject.geofencing-subscriptions.v0.area-left') {
      
      const status = eventType.includes('area-entered') ? 'arriving' : 'departed';

      const snapshot = await db.collectionGroup('geofences').where('subscriptionId', '==', subscriptionId).limit(1).get();
      
      if (!snapshot.empty) {
        const geofenceDoc = snapshot.docs[0];
        const driverDoc = geofenceDoc.ref.parent.parent;
        
        if (driverDoc) {
          await driverDoc.update({
            tripStatus: status,
            lastGeofenceEvent: eventType,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          console.log(`Driver ${driverDoc.id} status updated to ${status}`);
        }
      }
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Error processing notification:', error);
    res.status(500).send('Internal Server Error');
  }
});
