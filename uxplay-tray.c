#include <libayatana-appindicator/app-indicator.h>
#include <gtk/gtk.h>
#include <signal.h>
#include <stdlib.h>

static GPid uxplay_pid = 0;

static void on_quit(GtkMenuItem *item, gpointer data) {
    if (uxplay_pid > 0)
        kill((pid_t)uxplay_pid, SIGTERM);
    gtk_main_quit();
}

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);

    gchar *args[] = { "uxplay", "-p", NULL };
    GError *err = NULL;
    g_spawn_async(NULL, args, NULL, G_SPAWN_SEARCH_PATH, NULL, NULL, &uxplay_pid, &err);
    if (err) {
        g_printerr("Failed to launch uxplay: %s\n", err->message);
        return 1;
    }

    AppIndicator *indicator = app_indicator_new(
        "uxplay", "uxplay", APP_INDICATOR_CATEGORY_APPLICATION_STATUS);

    /* Use the icon theme path injected by wrapProgram so the icon is found
       even though it lives in a Nix store path rather than the system theme. */
    const char *theme_path = getenv("UXPLAY_ICON_THEME_PATH");
    if (theme_path)
        app_indicator_set_icon_theme_path(indicator, theme_path);

    app_indicator_set_status(indicator, APP_INDICATOR_STATUS_ACTIVE);

    GtkWidget *menu = gtk_menu_new();
    GtkWidget *quit = gtk_menu_item_new_with_label("Quit UxPlay");
    g_signal_connect(quit, "activate", G_CALLBACK(on_quit), NULL);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), quit);
    gtk_widget_show_all(menu);
    app_indicator_set_menu(indicator, GTK_MENU(menu));

    gtk_main();
    return 0;
}
