import SwiftUI

struct StatsBar: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var i18n: LocalizationManager

    var body: some View {
        HStack(spacing: 24) {
            stat(i18n.t("Total"), store.totalCount)
            stat(i18n.t("Completed"), store.completedCount)
            stat(i18n.t("Remaining"), store.pendingCount)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thinMaterial)
    }

    private func stat(_ label: String, _ value: Int) -> some View {
        HStack(spacing: 4) {
            Text(label).foregroundStyle(.secondary)
            Text("\(value)").fontWeight(.semibold)
        }
    }
}
