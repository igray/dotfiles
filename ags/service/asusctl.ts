import { sh } from "lib/utils"

type Profile = "performance" | "balanced" | "power-saver"

class Asusctl extends Service {
    static {
        Service.register(this, {}, {
            "profile": ["string", "r"],
        })
    }

    available = !!Utils.exec("which powerprofilesctl")
    #profile: Profile = "balanced"

    async setProfile(prof: Profile) {
        await sh(`powerprofilesctl set ${prof}`)
        this.#profile = prof
        this.changed("profile")
    }

    constructor() {
        super()

        if (this.available) {
            sh("powerprofilesctl get").then(p => this.#profile = p as Profile)
        }
    }

    get profiles(): Profile[] { return ["performance", "balanced", "power-saver"] }
    get profile() { return this.#profile }
}

export default new Asusctl()
