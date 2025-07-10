//
//  PoPickupSelectUI.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 23/11/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
protocol pickerProtocol {
    func selected(selected: String? )
    
}

@available(iOS 13.0.0, *)
class PickerValueViewController: UIHostingController<PopPickupSelectUI> {
    
    required init?(coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder, rootView: PopPickupSelectUI())
        } else {
             super.init(rootView: PopPickupSelectUI())
        }
        rootView.dismiss = dismiss
    }
    
    @objc
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func setLabels(labels: [String]) {
        rootView.labels = labels
    }
}

@available(iOS 13.0.0, *)
struct PopPickupSelectUI: View {
    @State private var selectedPick = 0
    var delegate: pickerProtocol?
    var dismiss: (() -> Void)?
    var labels: [String]?
    
    var body: some View {
        Picker("Tipo de evento", selection: $selectedPick) {
            if let labels = labels {
                ForEach (0 ..< labels.count) {
                    Text(labels[$0])
                }
            }
        }
        Button("Seleccionar") {
            delegate?.selected(selected: labels?[selectedPick])
            selectedPick = 0
        }
    }
}

@available(iOS 13.0.0, *)
struct PoPickupSelectUI_Previews: PreviewProvider {
    static var previews: some View {
        PopPickupSelectUI()
    }
}
