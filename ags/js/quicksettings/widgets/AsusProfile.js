import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import icons from '../../icons.js';
import Asusctl from '../../services/asusctl.js';
import { ArrowToggleButton, Menu } from '../ToggleButton.js';

export const ProfileToggle = () => ArrowToggleButton({
    name: 'asusctl-profile',
    icon: Widget.Icon({
        icon: Asusctl.bind('profile').transform(p => icons.asusctl.profile[p]),
    }),
    label: Widget.Label({
        label: Asusctl.bind('profile'),
    }),
    connection: [Asusctl, () => Asusctl.profile !== 'balanced'],
    activate: () => Asusctl.setProfile('power-saver'),
    deactivate: () => Asusctl.setProfile('balanced'),
    activateOnArrow: false,
});

export const ProfileSelector = () => Menu({
    name: 'asusctl-profile',
    icon: Widget.Icon({
        icon: Asusctl.bind('profile').transform(p => icons.asusctl.profile[p]),
    }),
    title: Widget.Label('Profile Selector'),
    content: [
        Widget.Box({
            vertical: true,
            hexpand: true,
            children: [
                Widget.Box({
                    vertical: true,
                    children: Asusctl.profiles.map(prof => Widget.Button({
                        on_clicked: () => Asusctl.setProfile(prof),
                        child: Widget.Box({
                            children: [
                                Widget.Icon(icons.asusctl.profile[prof]),
                                Widget.Label(prof),
                            ],
                        }),
                    })),
                }),
            ],
        }),
    ],
});
