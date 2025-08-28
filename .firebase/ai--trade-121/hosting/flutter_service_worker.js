'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "778629eaec1a1d063083dcfe146cf192",
"assets/assets/countrycodes.json": "aac81f5e3141ac870a751f893859add4",
"assets/assets/fonts/Nunito-Bold.ttf": "c0844c990ecaaeb9f124758d38df4f3f",
"assets/assets/fonts/Nunito-Regular.ttf": "d8de52e6c5df1a987ef6b9126a70cfcc",
"assets/assets/fonts/Ubuntu-Bold.ttf": "e00e2a77dd88a8fe75573a5d993af76a",
"assets/assets/fonts/Ubuntu-Regular.ttf": "2505bfbd9bde14a7829cc8c242a0d25c",
"assets/assets/img/1.png": "048790b61feaeba5edec11cf4bca1ceb",
"assets/assets/img/2.png": "8ec7ac2c5f8967a751c8554ac528936b",
"assets/assets/img/5.png": "52cd289088ab83b9c08158b3ce451d9e",
"assets/assets/img/api.png": "23ab5d0f424d10625e0f0449019e825d",
"assets/assets/img/assets.svg": "8eb1b8dc5cfdf31e4f038489e2019248",
"assets/assets/img/backgroundimgae.jpg": "91ac2e02ff74387ff17f72a0b58196b9",
"assets/assets/img/banner1.jpg": "e684ff9ee96c348b1a71557cccbe219a",
"assets/assets/img/bnb2.png": "25a549564b39c357e4521bf6214a0bb1",
"assets/assets/img/chart.png": "07b3fba1e90cd9d1a0fa045faa51a255",
"assets/assets/img/chat.svg": "a7b83bad060bc3ae433bc21b90b40f6e",
"assets/assets/img/click.png": "d495a6e7dc8cec482d80b003f5d1dc4a",
"assets/assets/img/commingsoon.png": "5017234a9ee9bf04b8ea2150015c1481",
"assets/assets/img/cycle.png": "8ca9d7692515839143f16db2cfc42d26",
"assets/assets/img/diamond.png": "cde5659f9c30b6f729299b620d3e5d22",
"assets/assets/img/email.png": "828e4779415a6ad47ff7fa9d3c4a5772",
"assets/assets/img/ethereum.jpg": "3c06f5b10706e12ef816939726708ec6",
"assets/assets/img/facebook.png": "c5819231f9a42d82f7353c376b404961",
"assets/assets/img/feedback.svg": "cb4248336c3ebb5a1d6ff4fc2d79a4f5",
"assets/assets/img/filter.png": "5de062c43e12c5143e29f5afeb666c0d",
"assets/assets/img/Future.png": "4ec725cd28a81f915416f2a54bcc9783",
"assets/assets/img/future_trading.png": "7ea4061bc0e265fe0ca9b59b3bf2e59a",
"assets/assets/img/home.svg": "587c06d89a068c75ac468253b641d19b",
"assets/assets/img/huboi.png": "807be8b57b32b130db134ce09570504e",
"assets/assets/img/image2.jpg": "35313f87f646bec0aa9f21e06b577f7d",
"assets/assets/img/instagram.png": "d338c3a74edc20f463b37ccf4802f2ed",
"assets/assets/img/invitefriend.png": "f323c35c866348a09f360eb5262e4491",
"assets/assets/img/kbsplash.gif": "a9a77484e020a104a063a7a85ebb19f7",
"assets/assets/img/kbsplash_del.gif": "5f0625829111b25fc3ac7367e40fd6be",
"assets/assets/img/like.svg": "b5f9ada3c1da09962eb9ec853adbaf01",
"assets/assets/img/linkedin.png": "28e66e1dedcda9dcddaa07d95302c866",
"assets/assets/img/loginimg.png": "52c2c518f34d0d686c28924ccf8fafa9",
"assets/assets/img/login_img.png": "c180c7dfc458d8e7413b03614a860735",
"assets/assets/img/login_img_del.png": "832cac4d2570094e45bbed11a39bdbd1",
"assets/assets/img/logo.png": "fb8355495e1e1c2f9b55b66d982431c2",
"assets/assets/img/logoo.png": "8b710758bff15026a8aefafc5188989b",
"assets/assets/img/logout.svg": "5b27a382598d46993bc5763ed18ef4c1",
"assets/assets/img/logo_backup.png": "f0837e16c178d146620a772fa860462f",
"assets/assets/img/make_money.png": "70614f573270182b5b891bf1aa1dd43e",
"assets/assets/img/message.svg": "3423e74ac72a01eb74693ce655f59f57",
"assets/assets/img/money-withdrawal.png": "3f07ef2939c81058827396af35d4f4d3",
"assets/assets/img/money.png": "7877be6512061637b2e4f8e631119030",
"assets/assets/img/notification.svg": "c9e9f8be08e9229be8229d8d45ddf6fd",
"assets/assets/img/okx.jpeg": "8262dd350d2d4d34ba0a53fcf058450e",
"assets/assets/img/pause.png": "0df42e8e818a9e41f2847047fa394940",
"assets/assets/img/pie.png": "2249f855da04d8901be83f74c1ff4a0f",
"assets/assets/img/profileuser.png": "8cb4a8d7a6d829cd4c77337740340b29",
"assets/assets/img/robot.svg": "1890910b6fd7dd31f20516a288c509ea",
"assets/assets/img/rocket.png": "f8c67807b7039b52882c2104b921e65e",
"assets/assets/img/sell.png": "0e534c94886d90d67b480acfd1362565",
"assets/assets/img/signup.svg": "5a2c205be87a885902096b3b37de3307",
"assets/assets/img/spot_trading.png": "d8b6c19abafe380435f6699c3e96a994",
"assets/assets/img/start.png": "4a6cb2a8ac3a6c0b2d0a4afbda156670",
"assets/assets/img/stock.png": "e23b76642444dce3c3610c3ed025b3ab",
"assets/assets/img/strategy.png": "8a325000511a753171395e69a8db5f37",
"assets/assets/img/team-leader-svgrepo-com.svg": "698a6c78dd808d078b93427ed8e02bea",
"assets/assets/img/team.png": "64455abd65d5ea9b1ff3b689627c69a0",
"assets/assets/img/telegram.png": "aa84f9e1e93ca476396f354578089a5c",
"assets/assets/img/telephone.png": "51ce9cd88e37ff1a7c3a0c2614462a46",
"assets/assets/img/trade.svg": "927965f1af6141efa4596e1f11257900",
"assets/assets/img/tradingbot.png": "603601955898cb7ef3d132d5c3c40543",
"assets/assets/img/tradingbotold.png": "7613033d9ccd84ddc99c607ee887f51e",
"assets/assets/img/transaction.png": "45d3720a089b1a4a058dfed14e65f519",
"assets/assets/img/transaction.svg": "7445352ae6b38d5f01bc33631e074458",
"assets/assets/img/ufo.svg": "a6aa078d0098d19f47e713f6c23991fc",
"assets/assets/img/user.png": "1edc84d6693b3b66d7f3f26eabee0fdb",
"assets/assets/img/user.svg": "d11587891a9504be9f5184d5899502ef",
"assets/assets/img/user1.svg": "a7b1bb14ecce96d192bc93808e9abe10",
"assets/assets/img/userguide.png": "f0477f4bfb4d42962d62f1833cf2bb9b",
"assets/assets/img/vactor.png": "0919e11cc5a268b833f1e1235cdfd8e9",
"assets/assets/img/video.png": "5df2a4eb2df7a779579a3279bc5e8b2e",
"assets/assets/img/vip.png": "b2ef64b77bc845bd452506dc5f7523e1",
"assets/assets/img/whatsapp.png": "227793183cc95786de35e49ab72bdc7e",
"assets/assets/img/youtube.png": "22f86f9835746accafa412451423a30b",
"assets/assets/lotties/coming.json": "6c0784678aedc7f74f02677ed5784c85",
"assets/assets/lotties/comingsoon.json": "1e6bd3ea77f7d70c0a674af549855cc1",
"assets/assets/lotties/coming_soon.json": "92c8e03c5a5aebf79dc03b7de37502f6",
"assets/assets/lotties/loading_indicator.json": "09d3e8ef9e76c74b01f1f53b22177db6",
"assets/FontManifest.json": "2eb91f974f261e3ff98bf404c68712b1",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "0516ddec6ab898df2dfb237e2b8e1363",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf": "657a5353a553777e270827bd1630e467",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Bold.ttf": "a9c8e437146ef63fcd6fae7cf65ca859",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf": "7ec92adfa4fe03eb8e9bfb60813df1fa",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Bold.ttf": "46b41c4de7a936d099575185a94855c4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf": "dede6f2c7dad4402fa205644391b3a94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf": "9eef86c1f9efa78ab93d41a0551948f7",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf": "e3c361ea8d1c215805439ce0941a1c8d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf": "ac3b1882325add4f148f05db8cafd401",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf": "5a5766c715ee765aa1398997643f1589",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf": "946a26954ab7fbd7ea78df07795a6cbc",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf": "a7732ecb5840a15be39e1eda377bc21d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf": "ad0a28f28f736cf4c121bcb0e719b88a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf": "d89b80e7bdd57d238eeaa80ed9a1013a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf": "b5f967ed9e4933f1c3165a12fe3436df",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf": "55d2dcd4778875a53ff09320a85a5296",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf": "1e6a3368d660edc3a2fbbe72edfeaa85",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf": "959972785387fe35f7d47dbfb0385bc4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf": "e87212c26bb86c21eb028aba2ac53ec3",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf": "85554307b465da7eb785fd3ce52ad282",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf": "87f56927f1ba726ce0591955c8b3b42d",
"assets/packages/toast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/toast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/youtube_player_flutter/assets/speedometer.webp": "50448630e948b5b3998ae5a5d112622b",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "1cfe996e845b3a8a33f57607e8b09ee4",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "3c0676f2264a8a6eb2e330ef6a626025",
"/": "3c0676f2264a8a6eb2e330ef6a626025",
"main.dart.js": "bf7b64a98feacfcdad6ed20418902334",
"manifest.json": "d782bdba385cf79b434ace4f1b265e7c",
"version.json": "096c3a3bb08853e2469fca9ec56d7627"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
