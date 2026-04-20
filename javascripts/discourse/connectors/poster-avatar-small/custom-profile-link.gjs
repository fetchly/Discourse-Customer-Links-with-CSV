import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class CustomProfileLink extends Component {
    @service site;

    get links() {
        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] Settings dump follows", settings);
        const fieldNames = settings.custom_profile_link_user_field_ids.split(/\|/).map(n => n.trim()).filter(n => n.length > 0);
        const csvMappings = [
            settings.custom_profile_link_csv_1,
            settings.custom_profile_link_csv_2,
            settings.custom_profile_link_csv_3,
            settings.custom_profile_link_csv_4,
            settings.custom_profile_link_csv_5,
            settings.custom_profile_link_csv_6,
            settings.custom_profile_link_csv_7,
            settings.custom_profile_link_csv_8,
            settings.custom_profile_link_csv_9,
            settings.custom_profile_link_csv_10,
        ];
        const siteUserFields = this.site.user_fields || [];

        const post = this.args.outletArgs.post;
        if (!post) {
            if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] No post found in outlet args", this.args.outletArgs);
            return undefined;
        }

        // In post serialization, user custom fields are keyed as "user_field_N" strings
        const userCustomFields = post.user_custom_fields;
        if (!userCustomFields) {
            if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] Post missing user_custom_fields", post);
            return undefined;
        }

        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] Post user_custom_fields:", userCustomFields);

        let links = [];
        for (let i = 0; i < fieldNames.length; i++) {
            const siteField = siteUserFields.find(f => f.name === fieldNames[i]);
            if (!siteField) {
                if (settings.custom_profile_link_debug_mode) console.debug(`[Custom Profile Link] No site field found with name "${fieldNames[i]}"`);
                continue;
            }
            // Posts use "user_field_N" keys (e.g. "user_field_1"), unlike user model which uses integer keys
            const fieldValue = userCustomFields[`user_field_${siteField.id}`];
            if (!fieldValue) {
                if (settings.custom_profile_link_debug_mode) console.debug(`[Custom Profile Link] Post missing value for field "${fieldNames[i]}" (key: user_field_${siteField.id})`);
                continue;
            }
            const csv = csvMappings[i] || "";
            const rows = csv.split(/\r?\n/).map(r => r.trim()).filter(r => r.length > 0);
            let matched = null;
            for (const row of rows) {
                const commaIdx = row.indexOf(",");
                if (commaIdx === -1) continue;
                const text = row.slice(0, commaIdx).trim();
                const link = row.slice(commaIdx + 1).trim();
                if (text === fieldValue) { matched = [text, link]; break; }
            }
            if (matched) {
                links.push([fieldNames[i], matched[0], matched[1]]);
            } else if (settings.custom_profile_link_debug_mode) {
                console.debug(`[Custom Profile Link] No CSV match for field "${fieldNames[i]}" value "${fieldValue}"`);
            }
        }
        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] Post links built:", links);
        return links.length ? links : undefined;
    }

    <template>
        {{#if this.links}}
        <div class="custom-profile-links-post">
            {{#each this.links as |link|}}
            <div class="custom-profile-link-post-item">
                <span class="profile-link-field-name">{{link.[0]}}:</span>
                <a href="{{link.[2]}}" target="_blank" rel="noopener noreferrer">{{link.[1]}}</a>
            </div>
            {{/each}}
        </div>
        {{/if}}
    </template>
}
