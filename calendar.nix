{ ... }: {

  # 1. Your existing school rooster configuration
  home.file.".config/evolution/sources/school-rooster.source".text = ''
    [Data Source]
    DisplayName=School rooster
    Enabled=true
    Parent=webcal-stub

    [Authentication]
    Host=calendar.google.com
    Method=plain/password
    Port=443
    ProxyUid=system-proxy
    RememberPassword=true
    User=
    CredentialName=
    IsExternal=false

    [Security]
    Method=tls

    [WebDAV Backend]
    AvoidIfmatch=false
    CalendarAutoSchedule=false
    Color=
    DisplayName=
    EmailAddress=
    ResourcePath=/calendar/ical/gtut8mudijg822q7ofij106cg8%40group.calendar.google.com/public/basic.ics
    ResourceQuery=
    SslTrust=
    Order=4294967295
    Timeout=30
    LimitDownloadDays=0

    [Calendar]
    BackendName=webcal
    Color=#62a0ea
    Selected=true
    Order=0

    [Offline]
    StaySynchronized=true

    [Refresh]
    Enabled=true
    EnabledOnMeteredNetwork=true
    IntervalMinutes=30
  '';

  # 2. Force turn off the Local Calendar stub
  home.file.".config/evolution/sources/system-calendar.source".text = ''
    [Source]
    UID=system-calendar
    Parent=local-stub
    DisplayName=Personal
    BackendName=local
    Enabled=false
  '';

  # 3. Force turn off the Local Address Book stub
  home.file.".config/evolution/sources/system-address-book.source".text = ''
    [Source]
    UID=system-address-book
    Parent=local-stub
    DisplayName=Personal
    BackendName=local
    Enabled=false
  '';
}
