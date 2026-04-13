{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us";
      kb_options = "caps:ctrl_modifier";

      repeat_delay = 300;
      numlock_by_default = true;

      follow_mouse = 1;
      mouse_refocus = 0;
      float_switch_override_focus = 0;

      touchpad = {
        disable_while_typing = false;
        natural_scroll = true;
      };
    };

    general = {
      gaps_in = 4;
      gaps_out = 4;
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = false;

      focus_on_activate = true;
      middle_click_paste = false;

      disable_autoreload = false;
    };

    dwindle = {
      force_split = 2;
      preserve_split = true;
      use_active_for_splits = true;
    };

    master = {
      new_status = "master";
    };

    decoration = {
      rounding = 8;
      rounding_power = 2;

      blur = {
        enabled = false;
        # size = 3;
        # passes = 2;
        # vibrancy = 0.1696;
      };

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
    };

    group = {
      insert_after_current = true;
      "col.border_active" = "rgba(33ccffee)";
      "col.border_inactive" = "rgba(595959aa)";
      groupbar = {
        enabled = true;
        font_size = 12;
        gradients = true;
        "col.active" = "rgba(33ccffee)";
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "fluent_decel, 0, 0.2, 0.4, 1"
        "easeOutCirc, 0, 0.55, 0.45, 1"
        "easeInOutBack, 0.68, -0.1, 0.32, 1.1"
        "easeOutCubic, 0.33, 1, 0.68, 1"
        "fade_curve, 0, 0.55, 0.45, 1"
      ];

      animation = [
        # name, enable, speed, curve, style

        # Windows
        "windowsIn,   0, 4, easeOutCubic,  popin 20%" # window open
        "windowsOut,  0, 4, fluent_decel,  popin 80%" # window close.
        "windowsMove, 1, 2, fluent_decel, slide" # everything in between, moving, dragging, resizing.

        # Fade
        "fadeIn,      1, 3,   fade_curve" # fade in (open) -> layers and windows
        "fadeOut,     1, 3,   fade_curve" # fade out (close) -> layers and windows
        "fadeSwitch,  0, 1,   easeOutCirc" # fade on changing activewindow and its opacity
        "fadeShadow,  1, 10,  easeOutCirc" # fade on changing activewindow for shadows
        "fadeDim,     1, 4,   fluent_decel" # the easing of the dimming of inactive windows
        # "border,      1, 2.7, easeOutCirc"  # for animating the border's color switch speed
        # "borderangle, 1, 30,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
        "workspaces,  1, 3,   easeInOutBack, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
      ];
    };

    xwayland = {
      force_zero_scaling = true;
    };
  };
}
