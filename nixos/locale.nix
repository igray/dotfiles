{
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  console.useXkbConfig = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
}
