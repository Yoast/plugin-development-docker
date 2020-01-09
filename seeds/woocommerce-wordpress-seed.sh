#!/bin/bash
source "${BASH_SOURCE%/*}/core-install.sh"
wp plugin install woocommerce --activate
wp plugin install woocommerce-admin --activate
wp plugin install perfect-woocommerce-brands --activate
wp theme install storefront --activate
wp wc tool run install_pages --user=admin
wp option add storefront_nux_dismissed true
wp user meta add 1 dismissed_install_notice true
wp post update 1 --post_type=page --post_title=Homepage --comment-status=closed --post_content='<!-- wp:heading {"align":"center"} -->
<h2 class="has-text-align-center">Shop by Category</h2>
<!-- /wp:heading -->

<!-- wp:shortcode -->
[product_categories limit="3" columns="3" orderby="menu_order"]
<!-- /wp:shortcode -->

<!-- wp:heading {"align":"center"} -->
<h2 class="has-text-align-center">New In</h2>
<!-- /wp:heading -->

<!-- wp:woocommerce/product-new {"columns":4} /-->

<!-- wp:heading {"align":"center"} -->
<h2 class="has-text-align-center">Fan Favorites</h2>
<!-- /wp:heading -->

<!-- wp:woocommerce/product-top-rated {"columns":4} /-->

<!-- wp:heading {"align":"center"} -->
<h2 class="has-text-align-center">On Sale</h2>
<!-- /wp:heading -->

<!-- wp:woocommerce/product-on-sale {"columns":4} /-->

<!-- wp:heading {"align":"center"} -->
<h2 class="has-text-align-center">Best Sellers</h2>
<!-- /wp:heading -->

<!-- wp:woocommerce/product-best-sellers {"columns":4} /-->'
wp option update show_on_front page
wp option update page_on_front 1
wp faker woocommerce products
