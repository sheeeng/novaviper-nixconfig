_: {
  # Fancy 'find' replacement
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
      "*.bak"
    ];
  };
}
