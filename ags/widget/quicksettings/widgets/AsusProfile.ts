import { ArrowToggleButton, Menu } from "../ToggleButton"
import icons from "lib/icons"
import asusctl from "service/asusctl"

const profile = asusctl.bind("profile")

export const ProfileToggle = () => ArrowToggleButton({
    name: "asusctl-profile",
    icon: profile.as(p => icons.asusctl.profile[p]),
    label: profile,
    connection: [asusctl, () => asusctl.profile !== "balanced"],
    activate: () => asusctl.setProfile("power-saver"),
    deactivate: () => asusctl.setProfile("balanced"),
    activateOnArrow: false,
})

export const ProfileSelector = () => Menu({
    name: "asusctl-profile",
    icon: profile.as(p => icons.asusctl.profile[p]),
    title: "Profile Selector",
    content: [
        Widget.Box({
            vertical: true,
            hexpand: true,
            children: [
                Widget.Box({
                    vertical: true,
                    children: asusctl.profiles.map(prof => Widget.Button({
                        on_clicked: () => asusctl.setProfile(prof),
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
})
