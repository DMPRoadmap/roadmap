// Random Hero Image //

// Transform source images to reduce file sizes via Parcel (see: https://v2.parceljs.org/recipes/image/):

import heroImg1 from 'url:../images/hero/1-large.jpg?as=jpg&quality=30&width=1000';
import heroImg2 from 'url:../images/hero/2-large.jpg?as=jpg&quality=30&width=1000';
import heroImg3 from 'url:../images/hero/3-large.jpg?as=jpg&quality=30&width=1000';
import heroImg4 from 'url:../images/hero/4-large.jpg?as=jpg&quality=30&width=1000';
import heroImg5 from 'url:../images/hero/5-large.jpg?as=jpg&quality=30&width=1000';

if (document.querySelector('.t-home')) {
  const imgArr = [
    heroImg1,
    heroImg2,
    heroImg3,
    heroImg4,
    heroImg5
  ];
  const randomNum = Math.floor(Math.random() * imgArr.length);
  const heroImgEl = document.querySelector('.js-heroimage');
  const imgLightness = 60;
  const randomImg = imgArr[randomNum];
  const compositeImg = `linear-gradient(hsl(0, 0%, ${imgLightness}%), hsl(0, 0%, ${imgLightness}%)), url('${randomImg}')`;

  heroImgEl.style.setProperty('--hero-image', compositeImg);
}
