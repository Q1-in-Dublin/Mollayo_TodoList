import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var i18n: LocalizationManager

    var body: some View {
        Form {
            Picker(i18n.t("Language"), selection: $i18n.language) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
        .navigationTitle(i18n.t("Settings"))
    }
}
