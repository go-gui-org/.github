#!/usr/bin/env fish
# sync-deps.fish — bulk-update go-gui-org sibling dependencies.
#
# Usage:
#   sync-deps.fish --glyph v1.10.0          # bump go-glyph everywhere
#   sync-deps.fish --gui v0.22.0            # bump go-gui everywhere
#   sync-deps.fish --glyph v1.10.0 --gui v0.22.0  # bump both
#
# Flags:
#   --root <path>   Parent dir containing all sibling repos
#                   (default: parent of the .github checkout)
#   --dry-run       Print what would be done, don't commit or push

set -l root (realpath (dirname (dirname (status -f))))
set -l dry_run false
set -l glyph_ver ""
set -l gui_ver ""

# Repos that depend on go-glyph and/or go-gui, and whether they pin CI refs.
# Format: "repo-name|glyph|gui|ci-pins"
#   glyph/gui: 1 = dependency exists, 0 = no
#   ci-pins: 1 = CI workflows pin ref: versions, 0 = no
set -l repos \
	"go-gui|1|0|0" \
	"go-charts|1|1|1" \
	"go-edit|1|1|1" \
	"go-term|1|1|1" \
	"go-kite|1|1|1" \
	"go-map|1|1|1"

function log
	echo "→ $argv"
end

function warn
	echo "⚠ $argv" >&2
end

function err
	echo "✗ $argv" >&2
	exit 1
end

# Parse args
for i in (seq (count $argv))
	switch $argv[$i]
		case --glyph
			set glyph_ver $argv[(math $i + 1)]
		case --gui
			set gui_ver $argv[(math $i + 1)]
		case --root
			set root (realpath $argv[(math $i + 1)])
		case --dry-run
			set dry_run true
	end
end

if test -z "$glyph_ver" -a -z "$gui_ver"
	err "Expected --glyph <ver> and/or --gui <ver>"
end

if not test -d "$root"
	err "Root dir not found: $root"
end

log "Root: $root"
log "Glyph version: $glyph_ver"
log "GUI version: $gui_ver"
log ""

for repo_def in $repos
	set -l fields (string split "|" $repo_def)
	set -l name $fields[1]
	set -l has_glyph $fields[2]
	set -l has_gui $fields[3]
	set -l ci_pins $fields[4]
	set -l repo_path "$root/$name"

	if not test -d "$repo_path"
		warn "$name: not found at $repo_path, skipping"
		continue
	end

	log "$name:"

	pushd $repo_path

	# Check if repo is clean
	if not git diff --quiet
		warn "$name: dirty working tree, skipping"
		popd
		continue
	end

	# Update go-glyph dependency
	if test "$has_glyph" = "1" -a -n "$glyph_ver"
		log "  go get github.com/go-gui-org/go-glyph@$glyph_ver"
		if not $dry_run
			go get github.com/go-gui-org/go-glyph@$glyph_ver 2>&1 | while read -l line
				echo "    $line"
			end
		end
	end

	# Update go-gui dependency
	if test "$has_gui" = "1" -a -n "$gui_ver"
		log "  go get github.com/go-gui-org/go-gui@$gui_ver"
		if not $dry_run
			go get github.com/go-gui-org/go-gui@$gui_ver 2>&1 | while read -l line
				echo "    $line"
			end
		end
	end

	# go mod tidy
	log "  go mod tidy"
	if not $dry_run
		go mod tidy
	end

	# Update CI workflow refs if this repo pins them.
	# Matches "repository: go-gui-org/go-glyph" followed by
	# "ref: vX.Y.Z" and updates the ref line.
	if test "$ci_pins" = "1"
		for ci_file in .github/workflows/*.yml .github/workflows/*.yaml
			if not test -f "$ci_file"
				continue
			end
			log "  updating refs in $ci_file"
			if not $dry_run
				if test -n "$glyph_ver"
					env GLYPH_VER="$glyph_ver" perl -i -0777 -pe \
						's/(repository:\s*go-gui-org\/go-glyph\s*\n\s*ref:\s*)v[0-9.]+/${1}$ENV{GLYPH_VER}/g' \
						"$ci_file"
				end
				if test -n "$gui_ver"
					env GUI_VER="$gui_ver" perl -i -0777 -pe \
						's/(repository:\s*go-gui-org\/go-gui\s*\n\s*ref:\s*)v[0-9.]+/${1}$ENV{GUI_VER}/g' \
						"$ci_file"
				end
			end
		end
	end

	# Check if anything changed
	if git diff --quiet
		log "  no changes, skipping commit"
		popd
		continue
	end

	# Build commit message
	set -l parts
	test -n "$glyph_ver" && set -a parts "go-glyph to $glyph_ver"
	test -n "$gui_ver" && set -a parts "go-gui to $gui_ver"
	set -l msg "deps: bump "(string join " and " $parts)

	if $dry_run
		log "  [dry-run] would commit: $msg"
		popd
		continue
	end

	set -l branch "deps/sync-"(date +%Y%m%d-%H%M)
	git checkout -b $branch
	git add go.mod go.sum .github/workflows/
	git commit -m "$msg"
	git push origin $branch

	# Open PR
	set -l body "Auto-bumped by sync-deps.fish.\n\n"
	if test -n "$glyph_ver"
		set -a body "- go-glyph: $glyph_ver\n"
	end
	if test -n "$gui_ver"
		set -a body "- go-gui: $gui_ver\n"
	end
	gh pr create \
		--title "$msg" \
		--body (printf "%b" "$body") \
		--base main \
		--head $branch

	log "  PR opened for $msg"
	popd
end

log ""
log "Done."
