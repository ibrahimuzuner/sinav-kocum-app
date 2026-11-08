'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "d2bd08d4d225d3cbe31434d4365b025a",
".git/config": "f277145948cd42e5d825105168af0900",
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
".git/index": "1b7155d37dffa3c67c5426b8be71e3a1",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "19dcd2043efaf6142661666b8e53f877",
".git/logs/refs/heads/gh-pages": "19dcd2043efaf6142661666b8e53f877",
".git/logs/refs/remotes/origin/gh-pages": "d9fdf2ecf48170546bf626ef212db262",
".git/objects/00/45336a29b248ecc77c5bd68b06a0b7991bcbc9": "0202e7537f516b1450227a5aac74df35",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/05/551a35f7a6c26fd32a0cea20e48b6ead6fb2b8": "0c0cbb6adde94e9cb322ebbc6837e253",
".git/objects/08/4b96a8c00a67841547dc7cc9e69390a6220f20": "b01b504bd8ba4128ef7c0424feb62738",
".git/objects/09/5e1230b0a693d7530cba04b8022a7256f32e15": "4136c8491d2c76ca08fff72fee66d824",
".git/objects/1b/62b748a797427e21e7f4627c3e3d19ca859a34": "086eb1ded522533ebfbe3f4f38a7e7ca",
".git/objects/1d/d65fdd7f4855640b47235152488ad5ceacc8d2": "4fd9f336a33cfd3a21c2116ab2068d55",
".git/objects/2f/62bd79394231b7ce1aed0379962dddd61606dc": "d192cafb81111820161312a95ee91100",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/3a/db7d59a28c93d93188260106186da0ff983ea3": "408676cb298cc6bdc57f9152779642f9",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4e/65be96d8de505ad1bf32d3e976a46578363ad2": "e6e46111a126b892945b796877b3d66f",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/4f/ea129a716f2879a4d30b5d6afb1bf5bb9d4325": "a0afe10c22d3451f1982900475ddf199",
".git/objects/50/a2d37c06eda71fc8d35fdebb031c6016e9077c": "3c1790c1c47e5413c652418cc166badb",
".git/objects/53/c0c055e682eb33f2137c86e708c9516c62850b": "29238e20ddb0c4c70884ae05dbbc3cb1",
".git/objects/56/354a1b7485fc3aba004d67f32f7c35347e784a": "075201bf2bbf8cf927790139b19b3efc",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/57/d8b540f8b0d17964d14da19dd16043794e24d4": "08296efd65ba09927a92c39365334a87",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/60/8529834b1f6fd695779bcf25e82df1f864b10c": "e8920ce4090e989c993999cfab3abd3a",
".git/objects/61/6aafba589af4365bc09991b75994fbd0af8049": "80b25724357ba0ce1122de9079727a01",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6d/93fee8d89263c4813779ef018832a61dc28b99": "c843972e2e6f4a5d508b4775e2e07843",
".git/objects/6e/6ab42782135ef60e5daffbe97b74334645efd5": "a604bea19c293b493b51b00dd9f20bcf",
".git/objects/70/a497cf5c645d4358cb03a438d2c71339b61a8c": "1490295e12d37bbb65a01a7aff69568b",
".git/objects/72/24631179610f3b59b79f3db24d071a301b2385": "85e1cc32598d91fc04fc84d6b991a0e4",
".git/objects/75/98185d051689219b00c34ae4d0fe36212ffbaa": "1743ae9b2a2ccadd22577073d8a72c3f",
".git/objects/77/ec04f67a2b4bd7c189d9c5b0b127617bf7f3d1": "720d863c6acfb1a7eeb0290a8baf3b1a",
".git/objects/86/82d94623e575a4ecc9586a35fc909dff37fb2c": "0d4bde48638b5a89ca0d6460a09067bb",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/90/c2676ac7fcd6d5c6c6e230d1b957bde940c670": "64895b8f2cc4152eaa61f77269458f32",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/92/9be8b75a4dd0b1394fd039e0d2a84399db4a1c": "b0fb5eae08dc8c1ddff1bc7c5d4ea33a",
".git/objects/93/be7fd9b9dcdd8564dafd7040a0c8c8f68d4080": "b27ff257c793a735fc818ff37f392ff9",
".git/objects/94/6d0c5edb4f8382531d7a5a831942769f8d602c": "3a85226276e5f60f556e30691cf86258",
".git/objects/96/eea6b8303a48a29211e7fb69604db280a07594": "48692abcaba86a3f7a2745401326d5db",
".git/objects/97/5c7727c37db2f19c0500efd6490ed25c9f0c81": "43109464c38e76a70ac62659bfb3e1fc",
".git/objects/99/6bf2a6ce81dd00a3dc44f03ed35d462318ec17": "f0658ce30664f40f0f0ca3d132c761d5",
".git/objects/99/d5e92bbca939bbcea0044be2f7748fc44d347b": "2742f29593704628df6f07ecbac6d8c0",
".git/objects/a2/9282c7738b05adfd64049dd571b458b0b362ae": "024390cabff89d058ed25be722952b62",
".git/objects/a3/2e17243b194cbab6697c6d500208979c34734a": "3088f8f38c204ed1d45f885e49999597",
".git/objects/a3/dc5e23b10b265af79e8de08c64db425f1dc645": "c7fd80fbe96c81b11626bf7144a5e9b1",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a6/037e6865db7dcd220a631e7b9f4a8eb6417c42": "46cf6c7e317f9aa308f35b1ce6886419",
".git/objects/a6/80a8d2a859062b612d52987add123b9ca4c30f": "d9fc4525fc3365ca6df747d2493db739",
".git/objects/a8/7946a02d0f59980fd2608cb4eeb59897f79984": "2d73b596146bacd04891e995c219b34f",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/b3/5cc9cc211e4ab8c6e19c44d8c5fe466991b740": "ca2385a65b594eaa362272af592e8819",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/bb/279d1cf9c771de256412d6c39f6ec82edf7543": "442fe341eabfd752e6d0dd6de795f7eb",
".git/objects/bf/1654393730da4a0707e9bbad0addbaf5925ca0": "77452c5db7d3b4d3867481e4aef3b6c7",
".git/objects/c2/0da577a2c205921fd70eb62ef163e959f45aeb": "b767e6b5baafa2c2ae9d274f7f19a5cd",
".git/objects/c4/2fca87f06842d3e4eb08a50016ddf6eeb1d291": "20c468d4c0ebf25a6b3d0eb04e581f23",
".git/objects/c5/f4703be5e69dd7782a9d36f309d4b426485fe6": "0f0bb09799ba3ca9b42df69e8f3cbf43",
".git/objects/c7/867c8e75474ee759c4ec79f2ca28a2ea569d8a": "23fab77911bd9b18e84dd31c29cb88e5",
".git/objects/cc/a0e27a0e5237253ebe8bde939c90e0f52c7bc8": "bad3417a441468556eca2b35e0a0407d",
".git/objects/d3/f3061302d8c0c32475965940d4b7b29208843d": "71c094d7daa94ecbe7bf83907787cd4f",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d8/2c7c77e2ad8b485599cb6d3a899e1dd5063c1b": "eb96960860ca1d65a55ff0136db788a3",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/dc/493cb7b1c8eeb656cf67f8d47941523b508755": "c13fe99a8f9b1e1c507fc6c4bb88e7f5",
".git/objects/e3/e8923af902144549a9919e4e59638a9be46ab6": "66a68ab8c4f9c3e3bf70e14cadb10503",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/e8/2dcb7e70878f4520ec503fc0657a36113e9f5d": "4dbff380462e0629ebd2a9b44d884566",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/ea/cc2b3a3a429ae6a4c071670a3736f1cc9ee2e7": "f9f62f55653dd90137f04e5db51f225e",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/70ee33b50d5d003995ef0a45cf880d535d00be": "26ae85968d50d4411512b2039fefd1fd",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f3/efab86499fca7f40076a989a3d8817bb3a0e72": "1f4882e5b0b41fdccd68cb9176b036e5",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f6/a94927750678c0b629615a4177751ff5e5a44a": "c789624d41db7cbc9c4de6eb728f2bb1",
".git/refs/heads/gh-pages": "87c28dc181c6828f42406c3731d3e3a6",
".git/refs/remotes/origin/gh-pages": "87c28dc181c6828f42406c3731d3e3a6",
"assets/AssetManifest.bin": "2be3082434641994dbd26fa075dda305",
"assets/AssetManifest.bin.json": "953bebc11069a75705bfd02a8c2e0144",
"assets/AssetManifest.json": "38a6b6a17ffb186159dd3fc210ca625d",
"assets/assets/fonts/arial.ttf": "fa3228aadde0db988e1822c2f736c131",
"assets/assets/fonts/arialbd.ttf": "858f5a50a4c3e5e6559a0c9b128eee60",
"assets/assets/icon/app_icon.png": "717a8da5b7d6e76c0f140cae11d7ab9d",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "feac6ad74a9cadc561814d5d5a2d81a7",
"assets/NOTICES": "88d74fef507e18996905e103ee5d6535",
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
"flutter_bootstrap.js": "261953ffa153a64969299f087dc84436",
"icons/Icon-192.png": "77141e691efa521748777fa7efe58907",
"icons/Icon-512.png": "07d3b8636196d385ec5cc8ed18f4093a",
"icons/Icon-maskable-192.png": "77141e691efa521748777fa7efe58907",
"icons/Icon-maskable-512.png": "07d3b8636196d385ec5cc8ed18f4093a",
"index.html": "9b51d4d97dcb1fd2abb6330f66bfa1cf",
"/": "9b51d4d97dcb1fd2abb6330f66bfa1cf",
"main.dart.js": "bc9916cc7b4e0cb0af0ae1cddb629d57",
"manifest.json": "a5476efd65de0be870fba6913462b4bd",
"version.json": "6d1a6940f06ef5679dbc58cda4e76dcb"};
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
