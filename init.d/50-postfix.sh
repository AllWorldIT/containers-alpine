#!/bin/sh

# Check if we need to enable postfix
if [ -z "$START_POSTFIX" ]; then
	return
fi

# Sanity checks
if [ -z "$POSTFIX_ROOT_ADDRESS" ]; then
	echo "ERROR: POSTFIX_ROOT_ADDRESS must be specified when using Postfix"
	exit 1
fi
if [ -z "$POSTFIX_MYHOSTNAME" ]; then
	echo "ERROR: POSTFIX_MYHOSTNAME must be specified when using Postfix"
	exit 1
fi
if [ -z "$POSTFIX_RELAYHOST" ]; then
	echo "ERROR: POSTFIX_RELAYHOST must be specified when using Postfix"
	exit 1
fi

# Check configurable options
if [ -z "$POSTFIX_ABUSE_ADDRESS" ]; then
	POSTFIX_ABUSE_ADDRESS=root
fi
if [ -z "$POSTFIX_ADMIN_ADDRESS" ]; then
	POSTFIX_ADMIN_ADDRESS=root
fi
if [ -z "$POSTFIX_ADMINISTRATOR_ADDRESS" ]; then
	POSTFIX_ADMINISTRATOR_ADDRESS=root
fi
if [ -z "$POSTFIX_WEBMASTER_ADDRESS" ]; then
	POSTFIX_WEBMASTER_ADDRESS=root
fi
if [ -z "$POSTFIX_POSTMASTER_ADDRESS" ]; then
	POSTFIX_POSTMASTER_ADDRESS=root
fi
if [ -z "$POSTFIX_HOSTMASTER_ADDRESS" ]; then
	POSTFIX_HOSTMASTER_ADDRESS=root
fi
if [ -z "$POSTFIX_NOREPLY_ADDRESS" ]; then
	POSTFIX_NOREPLY_ADDRESS=root
fi

# Work out our destinations
if [ -n "$POSTFIX_DESTINATIONS" ]; then
	POSTFIX_DESTINATIONS=", $POSTFIX_DESTINATIONS"
fi

# Setup supervisord for postfix
mv /etc/supervisor/conf.d/postfix.conf.disabled /etc/supervisor/conf.d/postfix.conf

echo "### START DOCKER CONFIG ###" >> /etc/postfix/main.cf
echo "myhostname = $POSTFIX_MYHOSTNAME" >> /etc/postfix/main.cf
echo "smtpd_banner = \$myhostname ESMTP" >> /etc/postfix/main.cf
echo "mydestination = \$myhostname, $HOSTNAME$POSTFIX_DESTINATIONS, localhost.localdomain, localhost" >> /etc/postfix/main.cf
echo "relayhost = $POSTFIX_RELAYHOST" >> /etc/postfix/main.cf
echo "# Output logs to stdout" >> /etc/postfix/main.cf
echo "maillog_file = /dev/stdout" >> /etc/postfix/main.cf
echo "disable_vrfy_command = yes" >> /etc/postfix/main.cf
echo "smtpd_helo_required = yes" >> /etc/postfix/main.cf
echo "strict_rfc821_envelopes = yes" >> /etc/postfix/main.cf

echo "message_size_limit = 102400000" >> /etc/postfix/main.cf
echo "mailbox_size_limit = 0" >> /etc/postfix/main.cf

echo "enable_long_queue_ids = yes" >> /etc/postfix/main.cf

echo "address_verify_map = lmdb:/var/lib/postfix/verify" >> /etc/postfix/main.cf
echo "address_verify_negative_refresh_time = 5m" >> /etc/postfix/main.cf
echo "unverified_recipient_reject_code = 550" >> /etc/postfix/main.cf
echo "unverified_sender_reject_code = 550" >> /etc/postfix/main.cf
echo "unknown_address_reject_code = 550" >> /etc/postfix/main.cf
echo "unverified_recipient_reject_reason = Recipient address verification failed" >> /etc/postfix/main.cf

echo "smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination" >> /etc/postfix/main.cf
echo "smtpd_recipient_restrictions = reject_non_fqdn_recipient, reject_unknown_recipient_domain, permit_mynetworks, warn_if_reject reject_unknown_reverse_client_hostname, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, warn_if_reject reject_unknown_helo_hostname, reject_unauth_destination, reject_unverified_recipient" >> /etc/postfix/main.cf
echo "smtpd_sender_restrictions = reject_non_fqdn_sender, reject_unknown_sender_domain" >> /etc/postfix/main.cf
echo "smtpd_data_restrictions = reject_multi_recipient_bounce, reject_unauth_pipelining" >> /etc/postfix/main.cf

echo "relay_domains = /etc/postfix/relay_domains" >> /etc/postfix/main.cf
echo "transport_maps = lmdb:/etc/postfix/transport_maps" >> /etc/postfix/main.cf
echo "### END DOCKER CONFIG ###" >> /etc/postfix/main.cf

# Master
touch /etc/postfix/master.cf
echo "$POSTFIX_MASTER_CF" | while read line; do
	echo "$line" >> /etc/postfix/master.cf
done

# Relay domains
touch /etc/postfix/relay_domains
echo "$POSTFIX_RELAY_DOMAINS" | while read domain; do
	echo "$domain" >> /etc/postfix/relay_domains
done

# Transport maps
touch /etc/postfix/transport_maps
echo "$POSTFIX_TRANSPORT_MAPS" | while read line; do
	echo "$line" >> /etc/postfix/transport_maps
done
postmap /etc/postfix/transport_maps

# Setup aliases
echo "### START DOCKER CONFIG ###" > /etc/postfix/aliases
echo "root: $POSTFIX_ROOT_ADDRESS" >> /etc/postfix/aliases
echo "abuse: $POSTFIX_ABUSE_ADDRESS" >> /etc/postfix/aliases
echo "admin: $POSTFIX_ADMIN_ADDRESS" >> /etc/postfix/aliases
echo "administrator: $POSTFIX_ADMINISTRATOR_ADDRESS" >> /etc/postfix/aliases
echo "webmaster: $POSTFIX_WEBMASTER_ADDRESS" >> /etc/postfix/aliases
echo "postmaster: $POSTFIX_POSTMASTER_ADDRESS" >> /etc/postfix/aliases
echo "hostmaster: $POSTFIX_HOSTMASTER_ADDRESS" >> /etc/postfix/aliases
echo "noreply: $POSTFIX_NOREPLY_ADDRESS" >> /etc/postfix/aliases
echo "### END DOCKER CONFIG ###" >> /etc/postfix/aliases

newaliases


