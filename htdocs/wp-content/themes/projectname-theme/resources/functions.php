<?php

use Roots\Sage\Config;
use Roots\Sage\Container;

/**
 * Helper function for prettying up errors
 * @param string $message
 * @param string $subtitle
 * @param string $title
 */
$sage_error = function ($message, $subtitle = '', $title = '') {
  $title = $title ?: __('projectname &rsaquo; Error', 'projectname');
  $footer = '<a href="https://github.com/Clarkom/wp-theme-deploy/issues">https://github.com/Clarkom/wp-theme-deploy/issues</a>';
  $message = "<h1>{$title}<br><small>{$subtitle}</small></h1><p>{$message}</p><p>{$footer}</p>";
  wp_die($message, $title);
};

/**
 * Ensure compatible version of PHP is used
 */
if (version_compare('7', phpversion(), '>=')) {
  $sage_error(__('You must be using PHP 7 or greater.', 'projectname'), __('Invalid PHP version', 'projectname'));
}

/**
 * Ensure compatible version of WordPress is used
 */
if (version_compare('4.7.0', get_bloginfo('version'), '>=')) {
  $sage_error(__('You must be using WordPress 4.7.0 or greater.', 'projectname'), __('Invalid WordPress version', 'projectname'));
}

/**
 * Ensure dependencies are loaded
 */
if (!class_exists('Roots\\Base\\Container')) {
  if (!file_exists($composer = __DIR__.'/../../../../../vendor/autoload.php')) {
    $sage_error(
      __('You must run <code>composer install</code> from the projectname directory.', 'projectname'),
      __('Autoloader not found.', 'projectname')
    );
  }
  require_once $composer;
}

/**
 * Sage required files
 *
 * The mapped array determines the code library included in your theme.
 * Add or remove files to the array as needed. Supports child theme overrides.
 */
array_map(function ($file) use ($sage_error) {
  $file = "../app/{$file}.php";
  if (!locate_template($file, true, true)) {
    $sage_error(sprintf(__('Error locating <code>%s</code> for inclusion.', 'projectname'), $file), 'File not found');
  }
}, ['helpers', 'setup', 'filters', 'admin']);

/**
 * Here's what's happening with these hooks:
 * 1. WordPress initially detects theme in themes/projectname/resources
 * 2. Upon activation, we tell WordPress that the theme is actually in themes/projectname/resources/views
 * 3. When we call get_template_directory() or get_template_directory_uri(), we point it back to themes/projectname/resources
 *
 * We do this so that the Template Hierarchy will look in themes/projectname/resources/views for core WordPress themes
 * But functions.php, style.css, and index.php are all still located in themes/projectname/resources
 *
 * This is not compatible with the WordPress Customizer theme preview prior to theme activation
 *
 * get_template_directory()   -> /srv/www/example.com/current/web/app/themes/projectname/resources
 * get_stylesheet_directory() -> /srv/www/example.com/current/web/app/themes/projectname/resources
 * locate_template()
 * ├── STYLESHEETPATH         -> /srv/www/example.com/current/web/app/themes/projectname/resources/views
 * └── TEMPLATEPATH           -> /srv/www/example.com/current/web/app/themes/projectname/resources
 */
array_map(
  'add_filter',
  ['theme_file_path', 'theme_file_uri', 'parent_theme_file_path', 'parent_theme_file_uri'],
  array_fill(0, 4, 'dirname')
);
Container::getInstance()
  ->bindIf('config', function () {
    return new Config([
      'assets' => require dirname(__DIR__).'/config/assets.php',
      'theme' => require dirname(__DIR__).'/config/theme.php',
      'view' => require dirname(__DIR__).'/config/view.php',
    ]);
  }, true);
