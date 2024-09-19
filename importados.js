const admin = require('firebase-admin');
const fs = require('fs');
const csv = require('csv-parser');

admin.initializeApp({
  credential: admin.credential.cert(require('./firebase_key.json')),
});

const firestore = admin.firestore();

async function importCities() {
  const countriesRef = firestore.collection('countries');

  fs.createReadStream('world-cities.csv')
    .pipe(csv())
    .on('data', async (row) => {
      const { country, name, subcountry, geonameid } = row;

      const countryRef = countriesRef.doc(country);

      await countryRef.set({
        name: country, 
        subcountry: subcountry || '',
        geonameid: geonameid || ''
      }, { merge: true }); 
    })
    .on('end', () => {
      console.log('Importação completa!');
    });
}

importCities();
