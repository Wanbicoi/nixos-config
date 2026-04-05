{ ... }:
{
	wayland.windowManager.hyprland.settings = {
		# exec = [
		# 	"hyprctl dispatch submap global"
		# ];
		# submap = "global";

		bind = [
			"$mod, space, global, caelestia:launcher"
			"$mod SHIFT, S, global, caelestia:screenshotFreeze"
			"$mod SHIFT ALT, S, global, caelestia:screenshot"

			# Caelestia special workspace toggles
			"$mod, F9, exec, caelestia toggle sysmon"
			"$mod, F10, exec, caelestia toggle music"
			"$mod, F11, exec, caelestia toggle communication"
			"$mod, F12, exec, caelestia toggle todo"

			# Clipboard and emoji pickers
			"$mod, Period, exec, caelestia emoji -p"
			"$mod, V, exec, caelestia clipboard -d"
		];

		bindin = [
			"$mod, catchall, global, caelestia:launcherInterrupt"
			"$mod, mouse:272, global, caelestia:launcherInterrupt"
			"$mod, mouse:273, global, caelestia:launcherInterrupt"
			"$mod, mouse_up, global, caelestia:launcherInterrupt"
			"$mod, mouse_down, global, caelestia:launcherInterrupt"
		];

		bindl = [
			"$mod SHIFT, L, global, caelestia:lock"
			", Print, exec, caelestia screenshot"
			", XF86MonBrightnessUp, global, caelestia:brightnessUp"
			", XF86MonBrightnessDown, global, caelestia:brightnessDown"
			", XF86AudioPlay, global, caelestia:mediaToggle"
			", XF86AudioPause, global, caelestia:mediaToggle"
			", XF86AudioNext, global, caelestia:mediaNext"
			", XF86AudioPrev, global, caelestia:mediaPrev"
			", XF86AudioStop, global, caelestia:mediaStop"
		];

		bindr = [
			"Ctrl+$mod+Shift, R, exec, qs -c caelestia kill"
			"Ctrl+$mod+Alt, R, exec, qs -c caelestia kill; sleep .1; caelestia shell -d"
		];
	};
}
