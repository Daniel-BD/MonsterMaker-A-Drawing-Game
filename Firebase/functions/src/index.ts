import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

admin.initializeApp()
const db = admin.firestore();
/* 
export const deleteIncompleteGames = functions.https.onRequest(async (request, respone) => {
  functions.logger.info("Running deleteIncompleteGames");
  
  const collections = await db.doc('home/rooms').listCollections();
  const collectionIds = collections.map(col => col.id);

  collectionIds.forEach(async (id) => {
    //functions.logger.info(`room id: ${id}`);
    await db.collection(`home/rooms/${id}`).get()
      .then(async snap => {
        functions.logger.info(`snap size: ${snap.size}`);
        if (snap.size < 4) {

          functions.logger.info(`should delete id: ${id}`);
          snap.docs.forEach(async (documentToDelete)=>{
            functions.logger.info(`deleting: ${documentToDelete.id}`);
            
            const res = await db.collection(`home/rooms/${id}`).doc(documentToDelete.id).delete();
            functions.logger.info(`result: ${res}`);
          });

        }
      }).catch((err)=>{
        functions.logger.info(`delete error: ${err}`);
      });
  });

  respone.send('Deleting incomplete games!');
}); */

/* export const writeRooms = functions.https.onRequest((request, response) => {
  functions.logger.info("Running writeRooms");

  db.doc('home/rooms/DEFG/gameData').set({'player1' : 'active', 'player2' : 'active'});
  db.doc('home/rooms/DEFG/player1').set({'player1' : 'active', 'player2' : 'active'});
  db.doc('home/rooms/DEFG/player2').set({'player1' : 'active', 'player2' : 'active'});
  db.doc('home/rooms/DEFG/player3').set({'player1' : 'active', 'player2' : 'active'});

  db.doc('home/rooms/ABCD/player1').set({'player1' : 'active', 'player2' : 'active'});
 
  response.send('Written rooms');
  return;
}); */

export const getRoomCodes = functions.https.onRequest(async (request, response) => {
  functions.logger.info("Running getRoomCodes");

  const docPath = 'home/rooms';

  const collections = await db.doc(docPath).listCollections();
  const collectionIds = collections.map(col => col.id);

  db.collection('home').add({'roomCodes': collectionIds})
  .then(()=>{
    functions.logger.info("getRoomCodes success");
  })
  .catch((err)=>{
    functions.logger.info("getRoomCodes failed");
  });

  response.send('room codes: ${collectionIds}');
});
