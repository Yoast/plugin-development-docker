<?php

require 'class-run-tests.php';

$cwd = dirname( $argv[0] );

$plugin = $argv[1];
if ( empty( $plugin ) ) {
	echo 'Please provide a plugin name to the command you\'ve used.';
	exit( 1 );
}

$config = $argv[2] ?? "phpunit.xml.dist";

$runTests = new RunTests( $plugin );

echo 'Preparing the system...' . PHP_EOL;
$runTests->prepare();
echo 'Done.' . PHP_EOL;

echo 'Running tests...' . PHP_EOL;
$runTests->run($config);
echo 'Done.' . PHP_EOL;

exit( 0 );
