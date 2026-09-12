import SwiftUI

struct AboutView: View {
    @EnvironmentObject var i18n: LocalizationManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "fish.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)

            Text("Mollayo").font(.title).bold()

            Text(i18n.t("You're working, but you can't remember what you were doing? Mollayo remembers so you don't have to."))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)

            Spacer()

            VStack(spacing: 4) {
                Text("v1.0").font(.caption).foregroundStyle(.secondary)
                Text("Open source by @Jacob Jung").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(i18n.t("About"))
    }
}
