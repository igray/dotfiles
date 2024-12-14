{ lib, pkgs, ... }:
{
  clipboard.providers = {
    wl-copy.enable = true;
  };
  opts.clipboard = [ "unnamedplus" ];

  extraPlugins = with pkgs.vimPlugins; [
    telescope-file-browser-nvim
  ];

  plugins = {
    gitsigns = {
      settings = {
        current_line_blame = lib.mkForce true;
      };
    };
    telescope = {
      settings = {
        defaults = {
          mappings = {
            i = {
              "<C-d>" = lib.nixvim.mkRaw ''
                function(...)
                  local action_state = require("telescope.actions.state")
                  local fb = require("telescope").extensions.file_browser
                  local live_grep = require("telescope.builtin").live_grep
                  local current_line = action_state.get_current_line()

                  fb.file_browser({
                    files = false,
                    depth = false,
                    attach_mappings = function()
                      require("telescope.actions").select_default:replace(function()
                        local entry_path = action_state.get_selected_entry().Path
                        local dir = entry_path:is_dir() and entry_path or entry_path:parent()
                        local relative = dir:make_relative(vim.fn.getcwd())
                        local absolute = dir:absolute()

                        live_grep({
                          results_title = relative .. "/",
                          cwd = absolute,
                          default_text = current_line,
                        })
                      end)

                      return true
                    end,
                  })
                end
              '';
            };
          };
        };
      };
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
