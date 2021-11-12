<?php

/**
 * Class to run the tests and prepare the environment.
 */
class RunTests {

	/**
	 * The plugin to use.
	 *
	 * @var string
	 */
	private string $plugin;

	/**
	 * The source path of the plugin.
	 *
	 * @var string
	 */
	private string $pluginSourcePath;

	/**
	 * The target path of the plugin.
	 *
	 * @var string
	 */
	private string $pluginTargetPath;

	/**
	 * Constructor.
	 *
	 * @param string $plugin The plugin directory to use.
	 */
	public function __construct( string $plugin ) {
		$this->plugin = $plugin;
		$this->pluginTargetPath = sprintf( '/tmp/wordpress/src/wp-content/plugins/%s', $plugin );
		$this->pluginSourcePath = sprintf( '/var/www/html/wp-content/plugins/%s', $plugin );
	}

	/**
	 * Prepares the system to run the plugin tests.
	 */
	public function prepare(): void {
		$this->refreshTargetDirectory();
		$this->installComposer();
		$this->createAssets();
		$this->createDatabase();
		$this->installPhpUnit();
	}

	/**
	 * Runs the plugin tests with provided config file.
	 *
	 * @param string $config The configuration file to use.
	 */
	public function run( string $config ): void {
		system( '/tmp/phive/phpunit --configuration ' . $config );
	}

	/**
	 * Installs composer.
	 */
	private function installComposer(): void {
		system( 'composer install --no-interaction --ignore-platform-reqs' );
	}

	/**
	 * Creates assets if needed.
	 */
	private function createAssets(): void {
		if ( $this->plugin !== 'wordpress-seo' ) {
			return;
		}

		chdir( $this->pluginTargetPath );

		@mkdir( 'src/generated/assets', 0777, true );

		file_put_contents( 'src/generated/assets/plugin.php', "<?php return [ 'post-edit-' . ( new WPSEO_Admin_Asset_Manager() )->flatten_version( WPSEO_VERSION ) . '.js' => [ 'dependencies' => [] ] ];" );
		file_put_contents( 'src/generated/assets/externals.php', '<?php return [];' );
		file_put_contents( 'src/generated/assets/languages.php', '<?php return [];' );
	}

	/**
	 * Copies the latest files over, excluding dependencies.
	 *
	 * Dependencies would take a long time and are probably not installed using the PHP version
	 * we're about to use anyway, so best to ignore them.
	 */
	private function refreshTargetDirectory(): void {
		@mkdir( $this->pluginTargetPath, 0777, true );

		system( 'rsync -r ' . $this->pluginSourcePath . '/ ' . $this->pluginTargetPath . ' --exclude=node_modules --exclude=vendor' );
	}

	/**
	 * Ensures the test database exists.
	 */
	private function createDatabase(): void {
		system( 'mysql -e "CREATE DATABASE IF NOT EXISTS wordpress_tests;" -uroot -prootpassword -hwordpress-basic-database' );
	}

	/**
	 * Installs PHP Unit internally.
	 *
	 * We've decided to do this per-run, then you don't have to build the container to get the latest version of PHPUnit.
	 */
	private function installPhpUnit(): void {
		system( 'phive --no-progress install phpunit --target /tmp/phive --trust-gpg-keys 4AA394086372C20A' );
	}
}
