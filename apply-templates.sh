#!/usr/bin/env bash
set -Eeuo pipefail

[ -f versions.json ] # run "versions.sh" first

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
	jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "$BASH_SOURCE" -nt "$jqt" ]; then
	# https://github.com/docker-library/bashbrew/blob/master/scripts/jq-template.awk
	wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/9f6a35772ac863a0241f147c820354e4008edf38/scripts/jq-template.awk'
fi

jqf='.template-helper-functions.jq'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
	jqf="$BASHBREW_SCRIPTS/template-helper-functions.jq"
elif [ "$BASH_SOURCE" -nt "$jqf" ]; then
	wget -qO "$jqf" 'https://github.com/docker-library/bashbrew/raw/master/scripts/template-helper-functions.jq'
fi


generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

export version=latest

for variant in builder signer server; do
	export variant

	dockerfile=
	dest="notary-$variant/Dockerfile"

	rm "$dest"

	case "$variant" in
		builder)
			dockerfile="Dockerfile-$variant.template"
			;;
		*)
			dockerfile="Dockerfile.template"
	esac

	{
		generated_warning
		gawk -f "$jqt" "$dockerfile"
	} > "$dest"
done
