import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Main.embed(document.getElementById('root'), JSON.parse(localStorage.clips || '[]'));

app.ports.playVideo.subscribe(startTime => {
  window.player.seekTo(startTime);
  window.player.playVideo();
});

app.ports.pauseVideo.subscribe(() => {
  window.player.pauseVideo();
});

app.ports.saveClips.subscribe(clips => {
  localStorage.clips = JSON.stringify(clips);
});

setInterval(() => {
  if (window.player && window.player.getCurrentTime) {
    app.ports.getCurrentTime.send(window.player.getCurrentTime());
  }
}, 100);

registerServiceWorker();
