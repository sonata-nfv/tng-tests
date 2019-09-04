/**
 * Copyright 2017 Google Inc., PhantomJS Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

const puppeteer = require('puppeteer');
var inCall = false;
var count = 0;
(async() => {
  const browser = await puppeteer.launch({ headless:true,
                                            args: ['--use-fake-device-for-media-stream',
                                                   '--use-fake-ui-for-media-stream',
                                                   '--disable-notifications',
                                                   '--unsafely-allow-protected-media-identifier-for-domain',
                                                   '--no-sandbox' ]
                                          });
  const page = await browser.newPage();
  await page.setRequestInterception(true);
  page.on('request', request => {
    if (request.resourceType() === 'image')
      request.abort();
    else
      request.continue();
  });
  await page.goto(process.env.WEB);

  await page.waitFor('input[name="username"]');
  await page.type('input[name="username"]', process.env.CALLED);
  await page.waitFor('input[name="password"]');
  await page.type('input[name="password"]', process.env.PASSWORD);
  await page.click('button[id="btn-login"]'); // With type

  await page.click('button[id="btn-login"]');

  while (true) {
    try {
        if (await page.$('button[class="pick-up"]') !== null && inCall==false){
          await page.waitFor('button[class="pick-up"]');
          await page.click('button[class="pick-up"]').then(() => console.log("Received call."));
          inCall=true;
          count=0;
        }
        else if (await page.$('button[class="hang-up"]') !== null && inCall==true){
          console.log("On call.");
          await new Promise(done => setTimeout(done,5000));
          count=0;
        }
        else {
          inCall=false;
          console.log("Timeout waiting for incoming call. Listenig to new calls.");
          await new Promise(done => setTimeout(done,5000));
          count=count+1;
          if (count==7){
            console.log("The user has left to wait for calls.");
            process.exit();
          }
        }
    }catch (e) {
      console.log("Timeout waiting for incoming call. Listenig to new calls."+e);
      process.exit();
    }
  }



})();
