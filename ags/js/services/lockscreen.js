import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

class Lockscreen {
    lockscreen() { Utils.execAsync(['swaylock', '-f']); }
}

export default new Lockscreen();
