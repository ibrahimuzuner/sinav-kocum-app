'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "5c37880d66529bbba32f10f766341cb2",
".git/config": "02da90e56230a32cc7a993aef6f28de5",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "e0b5b08e209fa15f48d796e8976bc42b",
".git/hooks/fsmonitor-watchman.sample": "5c90c1740b0cacecb469934e16fe8cb6",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "3f7509921917992a712b06d77b361b5f",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "5b37b831d72cd4786f3478acb63665be",
".git/logs/refs/heads/gh-pages": "5b37b831d72cd4786f3478acb63665be",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/05/551a35f7a6c26fd32a0cea20e48b6ead6fb2b8": "0c0cbb6adde94e9cb322ebbc6837e253",
".git/objects/22/8121113d8f1ce2cd2035a43c91e58f84baa96e": "05e5fbb289517c29490fc2e7938615e6",
".git/objects/29/f9d24a393f8b6bb423ca084ef3be967e7c9029": "d39e9c2a43fc323fc5ff6c10f0a9c911",
".git/objects/30/74707eeb368daa2059f2ba14457106aba47722": "f23e4b4afa5da4d3d81733ae4b6886ca",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/33/589cf7a7643f1b68406a16a5ae111ea876a7e1": "24b1dcbff1e14c630a420572d33ee481",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/3a/db7d59a28c93d93188260106186da0ff983ea3": "408676cb298cc6bdc57f9152779642f9",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4b/5e294b336876510caaaa2c9ef87df9c7d98bb0": "fc60e3888015238590c003b1fa3ed712",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/53/c0c055e682eb33f2137c86e708c9516c62850b": "29238e20ddb0c4c70884ae05dbbc3cb1",
".git/objects/55/a0639b144627d9736d8b22f564675693de2981": "a8b054c53e504964bf81c2da20644d1a",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/60/8529834b1f6fd695779bcf25e82df1f864b10c": "e8920ce4090e989c993999cfab3abd3a",
".git/objects/62/88aa137e2689837025f5b53db2bc5e134eb7e6": "b5038c83db66f99fc3368c6842946e5b",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6e/6ab42782135ef60e5daffbe97b74334645efd5": "a604bea19c293b493b51b00dd9f20bcf",
".git/objects/75/98185d051689219b00c34ae4d0fe36212ffbaa": "1743ae9b2a2ccadd22577073d8a72c3f",
".git/objects/7a/2cd15fb77016a62c7e1a5826f8bb961d43e6b9": "532d18050c2caf16b5b6178b652e2b54",
".git/objects/83/9a3c2b52ebb5c500b61fef58bf61bfbaeb2cda": "f9cdc7109e72edd03f843fb6861a62ed",
".git/objects/86/82d94623e575a4ecc9586a35fc909dff37fb2c": "0d4bde48638b5a89ca0d6460a09067bb",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/90/c2676ac7fcd6d5c6c6e230d1b957bde940c670": "64895b8f2cc4152eaa61f77269458f32",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/94/6e782920509358e9f86e4eb909ba7afc98e11e": "ea2b00cc62883f82986caf82697b3e39",
".git/objects/97/5c7727c37db2f19c0500efd6490ed25c9f0c81": "43109464c38e76a70ac62659bfb3e1fc",
".git/objects/a2/9282c7738b05adfd64049dd571b458b0b362ae": "024390cabff89d058ed25be722952b62",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a6/037e6865db7dcd220a631e7b9f4a8eb6417c42": "46cf6c7e317f9aa308f35b1ce6886419",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/c2/0da577a2c205921fd70eb62ef163e959f45aeb": "b767e6b5baafa2c2ae9d274f7f19a5cd",
".git/objects/c4/2c64028c13f7432c3e417b97d8579c8e72e3a7": "c7df8ea7fb20acbbd7f1554d4f2c0621",
".git/objects/cf/84edf073ff271ee43ed440cd67692c19875db6": "9e6405b72339f8708172dc867cb73f05",
".git/objects/d3/f3061302d8c0c32475965940d4b7b29208843d": "71c094d7daa94ecbe7bf83907787cd4f",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/e1/9f0211ea016119d661508251a21c0d9b6a0838": "f90d87ddac98fe47fee607631e5693e6",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f3/efab86499fca7f40076a989a3d8817bb3a0e72": "1f4882e5b0b41fdccd68cb9176b036e5",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/refs/heads/gh-pages": "4c5704dc2d65c7607d36477f12eb5c9e",
"assets/AssetManifest.bin": "2be3082434641994dbd26fa075dda305",
"assets/AssetManifest.bin.json": "953bebc11069a75705bfd02a8c2e0144",
"assets/AssetManifest.json": "38a6b6a17ffb186159dd3fc210ca625d",
"assets/assets/fonts/arial.ttf": "fa3228aadde0db988e1822c2f736c131",
"assets/assets/fonts/arialbd.ttf": "858f5a50a4c3e5e6559a0c9b128eee60",
"assets/assets/icon/app_icon.png": "717a8da5b7d6e76c0f140cae11d7ab9d",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "bcb42ea4577c505fd80f3a3a2d39b82a",
"assets/NOTICES": "61f449e2469d0ffae4dab11b0a7167fb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "471d23c71888a44d24a4fc4f7f850a1a",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "35b8a7127b69f6cc93291d01ad8df4b4",
"icons/Icon-192.png": "77141e691efa521748777fa7efe58907",
"icons/Icon-512.png": "07d3b8636196d385ec5cc8ed18f4093a",
"icons/Icon-maskable-192.png": "77141e691efa521748777fa7efe58907",
"icons/Icon-maskable-512.png": "07d3b8636196d385ec5cc8ed18f4093a",
"index.html": "b08635346e1c0c96a2febc0cc46730b6",
"/": "b08635346e1c0c96a2febc0cc46730b6",
"main.dart.js": "72ab4813c27d2bae3b36c9732ac53543",
"manifest.json": "4086e4e8fc673aebc83ba080ff68437b",
"privacy.html": "060cda081de55ff35e26389c54941e6a",
"version.json": "1e63e684dff36af4a227b6dec5d165d9"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
