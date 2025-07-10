//
//  PopDatePickerUI.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 14/09/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
protocol newEventoProtocol {
    func inputDate(nombre: String, descripcion: String, fecha: Date)
    
}

@available(iOS 13.0.0, *)
class DatePickerViewController: UIHostingController<PopDatePickerUI> {
    
    required init?(coder: NSCoder? = nil) {
        if let coder = coder {
             super.init(coder: coder, rootView: PopDatePickerUI())
        } else {
             super.init(rootView: PopDatePickerUI())
        }
        rootView.dismiss = dismiss

    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 13.0.0, *)
struct PopDatePickerUI: View {
    var dismiss: (() -> Void)?
    @State var selectedDate = Date()
    @State var nombre: String = ""
    @State var descripcion: String = ""
   
    var delegate: newEventoProtocol?
    
    var body: some View {
        VStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("Descripcion", text: $descripcion)
                DatePicker("Fecha del evento", selection: $selectedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                if isComplete() {
                    Text("* Debe ingresar todos los campos")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 16, height: UIScreen.main.bounds.height - 400)
            .cornerRadius(20).shadow(radius: 20)
            Button(action: {
                self.delegate?.inputDate(nombre: self.nombre, descripcion: self.descripcion, fecha: self.selectedDate)
            }, label: {
                Text("Guardar")
                    .fontWeight(.semibold)
                    .font(.title)
            })
            .buttonStyle(GradientBackgroundStyle())
            .disabled(isComplete())
        }
    }
    
    func isComplete() -> Bool {
        return $nombre.wrappedValue == "" || $descripcion.wrappedValue == ""
        
    }
   
}

struct PopDatePickerUI_Previews: PreviewProvider {
    @available(iOS 13.0.0, *)
    static var previews: some View {
        PopDatePickerUI()
    }
}


struct GradientBackgroundStyle: ButtonStyle {
 
    @available(iOS 13.0.0, *)
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.lightGray)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .padding(.horizontal, 20)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
