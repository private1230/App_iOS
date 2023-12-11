//
//  ASCDocSpaceLinkLifeTimeView.swift
//  Documents
//
//  Created by Lolita Chernysheva on 28.11.2023.
//  Copyright © 2023 Ascensio System SIA. All rights reserved.
//

import SwiftUI

struct LinkLifeTimeView: View {
    @ObservedObject var viewModel: LinkLifeTimeViewModel

    var body: some View {
        NavigationView {
            List(LinkLifeTimeOption.allCases, id: \.self) { option in
                HStack {
                    Text(option.localized)
                    Spacer()
                    if viewModel.selectedOption == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(Asset.Colors.brend.swiftUIColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedOption = option
                }
            }
            .navigationBarTitle(Text(NSLocalizedString("Link life time", comment: "")), displayMode: .inline)
            .navigationBarItems(leading: Button(NSLocalizedString("Back", comment: "")) {
                
            }
                .foregroundColor(Asset.Colors.brend.swiftUIColor)
            )
            
        }
    }
}

struct LinkLifeTimeView_Previews: PreviewProvider {
    static var previews: some View {
        LinkLifeTimeView(viewModel: LinkLifeTimeViewModel())
    }
}
