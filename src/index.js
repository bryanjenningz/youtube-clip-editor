import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Main.embed(document.getElementById('root'));

app.ports.playVideo.subscribe(startTime => {
  // console.log('playing', startTime);
  window.player.seekTo(startTime);
  window.player.playVideo();
});

app.ports.pauseVideo.subscribe(() => {
  // console.log('pausing', window.player.getCurrentTime());
  window.player.pauseVideo();
});

setInterval(() => {
  if (window.player && window.player.getCurrentTime) {
    app.ports.getCurrentTime.send(window.player.getCurrentTime());
  }
}, 100);

registerServiceWorker();
