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
const maxDuration = 90000;
(async() => {
  const browser = await puppeteer.launch({ headless:true,
                                            args: ['--use-fake-device-for-media-stream',
                                                   '--use-fake-ui-for-media-stream',
                                                   '--disable-notifications',
                                                   '--unsafely-allow-protected-media-identifier-for-domain']
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
  await page.type('input[name="username"]', process.env.CALLER);
  await page.waitFor('input[name="password"]');
  await page.type('input[name="password"]', process.env.PASSWORD);
  await page.click('button[id="btn-login"]'); // With type

  await page.click('button[id="btn-login"]');


  await page.waitFor('input[class="search ng-untouched ng-pristine ng-valid"]');
  await page.type('input[class="search ng-untouched ng-pristine ng-valid"]', process.env.CALLED);
  await page.click('i[class="icon sippo-search"]');
  await new Promise(done => setTimeout(done, 2000));
  if (await page.$('span[class="name"]', { timeout: 2000 }) == null){
    console.log("No such user.");
    process.exit();
  }
  await page.waitFor('span[class="name"]');
  await page.click('span[class="name"]');
  if (await page.$('img[class="offline"]', { timeout: 2000 }) !== null){
    console.log("Non-logged-in user.");
    process.exit();
  }
  await page.click('span[class="name"]');

  try {
    await new Promise(done => setTimeout(done, 40000));
    if (await page.$('button[class="hang-up"]') !== null){
      console.log("On Call");
      await new Promise(done => setTimeout(done, process.env.DURATION));
    }
    await page.waitFor('button[class="hang-up"]', { timeout: 5000 });
    await page.click('button[class="hang-up"]'); // With type
    console.log("Call finished successfully");
    process.exit();

  }catch (e) {
    console.log("The called user is not avaliable.");
    process.exit();
  }


})();
