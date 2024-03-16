const bluetooth = await Service.import("bluetooth")

export default function init() {
  setTimeout(() => {
    bluetooth.enabled = true
  }, 2000)
}
