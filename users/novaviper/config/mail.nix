{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}:
let
  myselfName = "novaviper";
  secrets = inputs.nix-secrets.${myselfName}.email;
  userVars = opt: myLib.utils.getUserVars opt config;
  passwordCmd =
    smtpHost: email:
    "gpg -q --for-your-eyes-only --no-tty -d ~/.authinfo.gpg | awk '/machine ${smtpHost} login ${email}/ {print $NF}'";
in
{
  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/mail";
    accounts.personal-1 =
      let
        address = "${secrets.personal1.address}";
        smtp.host = "smtp.mailbox.org";
      in
      {
        primary = true;
        inherit address smtp;
        userName = address;
        realName = "${myselfName}";
        aliases = [
          "code.nova99@mailbox.org"
          "${secrets.personal1.work}"
          "${secrets.personal1.school}"
          "${secrets.personal1.shop}"
        ];
        mu.enable = true;
        imap = {
          host = "imap.mailbox.org";
          tls.useStartTls = true;
        };
        #passwordCommand = "${pass} Mail/${smtp.host}/${address}";
        passwordCommand = passwordCmd smtp.host address;
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = [
            "INBOX"
            "AllMail"
            "Trash"
            "Spam"
            "Drafts"
            "Sent"
          ];
          extraConfig.account.TLSVersions = [ "+1.3" ];
          extraConfig.channel = {
            CopyArrivalDate = "yes";
            Create = "Both";
            Expunge = "Both";
            SyncState = "*";
          };
        };
      };

    accounts.personal-2 =
      let
        address = "${secrets.personal2}";
        smtp.host = "smtp.gmail.com";
      in
      {
        inherit address smtp;
        userName = address;
        realName = "${myselfName}";
        mu.enable = true;
        # Declaring ports for Gmail breaks it!!
        imap.host = "imap.gmail.com";
        #passwordCommand = "${pass} Mail/${smtp.host}/${address}";
        passwordCommand = passwordCmd smtp.host address;
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = [
            "*"
            ''!"[Gmail]/All Mail"''
            ''!"[Gmail]/Important"''
            ''!"[Gmail]/Starred"''
            ''!"[Gmail]/Bin"''
          ];
          extraConfig.account.TLSVersions = [ "+1.3" ];
          extraConfig.channel = {
            CopyArrivalDate = "yes";
            Create = "Both";
            Expunge = "Both";
            SyncState = "*";
          };
        };
      };
  };

  programs = {
    mu.enable = true;
    mbsync.enable = true;
  };

  services.mbsync = {
    enable = true;
    frequency = "*:0/10";
    preExec = "${lib.getExe config.programs.mbsync.package} -Ha";
    postExec = "${lib.getExe config.programs.mu.package} index";
  };

  # Add check to ensure to only run mbsync when my hardware key(s) are inserted
  systemd.user.services.mbsync.Service.ExecCondition =
    ''/bin/sh -c "${myLib.utils.isGpgUnlocked pkgs}"'';

  xdg.configFile =
    let
      acct = config.accounts.email.accounts;
      aliasElem = a: i: builtins.elemAt a.aliases i;
      primaryTemplate = {
        account = acct.personal-1;
        fullName = secrets.personal1.fullName;
        smtpAddr = acct.personal-1.address;
        signature = "Sincerely, ${primaryTemplate.fullName}";
      };
    in
    lib.mkIf (userVars "defaultEditor" == "doom-emacs") {
      "doom/mu4e-accounts.el".text = ''
        ;;; mu4e-accounts.el -*- lexical-binding: t; -*-
        (after! mu4e
          :config
          (setq mu4e-contexts
          (list ${
            lib.concatStringsSep "\n    " (
              lib.filter (v: v != "") [
                (myLib.utils.mkMu4eContext {
                  account = acct.personal-2;
                  contextName = "Google";
                  sentAction = "delete";
                })
                (myLib.utils.mkMu4eContext {
                  account = acct.personal-1;
                  contextName = "Mailbox";
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate) account smtpAddr;
                  contextName = "1-Mailbox-code-alias";
                  addr = aliasElem acct.personal-1 0;
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate)
                    account
                    smtpAddr
                    fullName
                    signature
                    ;
                  contextName = "2-Mailbox-work-alias";
                  addr = aliasElem acct.personal-1 1;
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate)
                    account
                    smtpAddr
                    fullName
                    signature
                    ;
                  contextName = "3-Mailbox-school-alias";
                  addr = aliasElem acct.personal-1 2;
                })
                (myLib.utils.mkMu4eContext {
                  inherit (primaryTemplate) account smtpAddr;
                  contextName = "4-Mailbox-shop-alias";
                  addr = aliasElem acct.personal-1 3;
                })
              ]
            )
          })))
        ;;; mu4e-accounts.el ends here
      '';
    };
}
