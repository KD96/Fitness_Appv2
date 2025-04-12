import SwiftUI

struct WeightLogView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            UIComponents.TabContentView(
                backgroundImage: "weight_lifting",
                backgroundOpacity: 0.07,
                backgroundColor: PureLifeColors.adaptiveBackground(scheme: colorScheme)
            ) {
                // Placeholder for the content of the view
            }
        }
    }
}

struct WeightLogView_Previews: PreviewProvider {
    static var previews: some View {
        WeightLogView()
    }
} 