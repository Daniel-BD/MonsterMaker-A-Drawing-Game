// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();


exports.getSubCollections = functions.https.onCall(async () => {

    const docPath = 'home/rooms';

    const collections = await admin.firestore().doc(docPath).listCollections();
    const collectionIds = collections.map(col => col.id);

    admin.firestore().collection('home').add({'roomCodes': collectionIds});

    return;
});

exports.deleteEmptyRooms = functions.https.onCall(async () => {

  const docPath = 'home/Tl3MRA1YRh8iAwaZMQbS';

  var roomCodes = await admin.firestore().doc(docPath).map['roomCodes'];

  



  admin.firestore().collection('home').add({'roomCodes': collectionIds});

  return;
});

// Listens for new messages added to /messages/:documentId/original and creates an
// uppercase version of the message to /messages/:documentId/uppercase
/*exports.makeUppercase = functions.firestore.document('/messages/{documentId}')
    .onCreate((snap, context) => {
      // Grab the current value of what was written to Cloud Firestore.
      const original = snap.data().original;

      // Access the parameter `{documentId}` with `context.params`
      functions.logger.log('Uppercasing', context.params.documentId, original);

      const uppercase = original.toUpperCase();

      // You must return a Promise when performing asynchronous tasks inside a Functions such as
      // writing to Cloud Firestore.
      // Setting an 'uppercase' field in Cloud Firestore document returns a Promise.
      return snap.ref.set({uppercase}, {merge: true});
    });
*/