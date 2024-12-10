{ lib, ... }:
{
  clipboard.providers = {
    wl-copy.enable = true;
  };
  opts.clipboard = [ "unnamedplus" ];

  plugins.gitsigns = {
    settings = {
      current_line_blame = lib.mkForce true;
    };
  };
  extraConfigLua = ''
    vim.api.nvim_set_hl(0, 'GitsignsCurrentLineBlame', { link = 'VertSplit' })
  '';

  keymaps = [
    # Neotree keymaps commented in Neve:
    {
      mode = "n";
      key = "<leader>e";
      action = ":Neotree toggle reveal_force_cwd<cr>";
      options = {
        silent = true;
        desc = "Explorer NeoTree (root dir)";
      };
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree toggle<CR>";
      options = {
        silent = true;
        desc = "Explorer NeoTree (cwd)";
      };
    }
    {
      mode = "n";
      key = "<leader>be";
      action = ":Neotree buffers<CR>";
      options = {
        silent = true;
        desc = "Buffer explorer";
      };
    }
    {
      mode = "n";
      key = "<leader>ge";
      action = ":Neotree git_status<CR>";
      options = {
        silent = true;
        desc = "Git explorer";
      };
    }

    # Trouble keymaps:
    {
      mode = "n";
      key = "gl";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options = {
        silent = true;
        desc = "Show Diagnostic";
      };
    }
    {
      mode = "n";
      key = "<leader>xj";
      action = "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>";
      options = {
        silent = true;
        desc = "Next Diagnostic";
      };
    }
    {
      mode = "n";
      key = "<leader>xk";
      action = "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<CR>";
      options = {
        silent = true;
        desc = "Previous Diagnostic";
      };
    }
  ];
}
