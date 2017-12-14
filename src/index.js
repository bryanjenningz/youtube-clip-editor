import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Main.embed(document.getElementById('root'));

setInterval(() => {
  if (window.player && window.player.getCurrentTime) {
    app.ports.getCurrentTime.send(window.player.getCurrentTime());
  }
}, 100);

registerServiceWorker();
