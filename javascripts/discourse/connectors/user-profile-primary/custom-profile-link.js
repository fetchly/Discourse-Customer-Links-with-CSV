import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class CustomProfileLink extends Component {
    get links() {
        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] Settings dump follows", settings);
        const ids = settings.custom_profile_link_user_field_ids.replace(/_/g, "").split(/\|/).map(Number);
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
        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] Parsed IDs:", ids);
        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] args dump:", this.args.outletArgs);
        const userFields = this.args.outletArgs.model.get('user_fields');
        if (!userFields) {
            console.warn(`[Custom Profile Link] User Profile () missing "user_fields"! Raw user dump follows.`, this.args.outletArgs.model);
            return undefined;
        }
        let links = [];
        for (let i = 0; i < ids.length; i++) {
            const fieldValue = userFields[ids[i]];
            if (!fieldValue) {
                if (settings.custom_profile_link_debug_mode) console.debug(`[Custom Profile Link] User field ${ids[i]} missing. user_fields dump follows.`, userFields);
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
                links.push(matched);
            } else if (settings.custom_profile_link_debug_mode) {
                console.debug(`[Custom Profile Link] No CSV match for field ${ids[i]} value "${fieldValue}"`);
            }
        }
        if (settings.custom_profile_link_debug_mode) console.debug("[Custom Profile Link] links built, dump:", links);
        return links.length ? links : undefined;
    }
}