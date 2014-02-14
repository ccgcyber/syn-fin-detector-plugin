<?php

/*
 * Frontend plugin: ddos
 *
 * Required functions: ddos_ParseInput and demoplugin_Run
 *
 */

/* 
 * ddos_ParseInput is called prior to any output to the web browser 
 * and is intended for the plugin to parse possible form data. This 
 * function is called only, if this plugin is selected in the plugins tab. 
 * If required, this function may set any number of messages as a result 
 * of the argument parsing.
 * The return value is ignored.
 */
function ddos_ParseInput( $plugin_id ) {

        SetMessage('error', "Error set by demo plugin!");
        SetMessage('warning', "Warning set by demo plugin!");
        SetMessage('alert', "Alert set by demo plugin!");
        SetMessage('info', "Info set by demo plugin!");

} // End of ddos_ParseInput


/*
 * This function is called after the header and the navigation bar have 
 * been sent to the browser. It's now up to this function what to display.
 * This function is called only, if this plugin is selected in the plugins tab
 * Its return value is ignored.
 */
function ddos_Run( $plugin_id ) {

        // your code here

} // End of ddos_Run


?>
