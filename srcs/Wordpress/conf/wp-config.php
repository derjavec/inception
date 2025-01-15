<?php
define('DB_NAME', getenv('WORDPRESS_DB_NAME') ?: 'app_db');
define('DB_USER', getenv('WORDPRESS_DB_USER') ?: 'derjavec');
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD') ?: '1234');
define('DB_HOST', getenv('WORDPRESS_DB_HOST') ?: 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Claves y salts de seguridad
define('AUTH_KEY',         '1$Z%QoJ-4:A$!E8zpaRqRjFMH7}xUK|U]LZ,DNuL7=ZrYN|9-/{wV4?Tx{7&8jCm');
define('SECURE_AUTH_KEY',  'J7v5h=[D_FGv|:V~8jZw@+9n{XH+5gN:Gp_Aa3:+Kqv%u<o~KHz+DVsNc^76Yy&h');
define('LOGGED_IN_KEY',    'b@?dMc=s}z)Go}4XkU.LDw&Q8^,NPB*X>)&u#Y|1`zP|NB|SwHKLBsQh~-%9*-2L');
define('NONCE_KEY',        '<h?9xVoXqH5MC[F|B+CzZR=w1PQ+-H@D9H;2P+RfHY>g[pYc/V}hm#U}>D<xHKoN');
define('AUTH_SALT',        'yn}+@7-XbRXFq1A}oCpBt#1GG&JHc:E-sYE*pL:-[Q2b!Wk<k++/y7<<:4|LYJ[9');
define('SECURE_AUTH_SALT', ']!H#-q%5pHq+3KTxs+-VE1L4~fAp6&4:b_]P[?W<L|=XLwEw#q=XY@C~OQ!NF~?$');
define('LOGGED_IN_SALT',   'pG7!XhVUw:HDHQCUG~o_}C+/<-nQsL7-Q!`7?;WxR_nY5XY<LW^9LK<t2<XLo1E&');
define('NONCE_SALT',       'MFz5s9_GPSR=P?EXR+f/R;Zd$BQAV+W!$mHW+Y|n1q5PL|RP=91!-U`y5VoKT!Bx');


$table_prefix = 'wp_';

// Ruta absoluta al directorio de WordPress
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// Configura WordPress
require_once ABSPATH . 'wp-settings.php';
