//
//  CalendarLoadingView.swift
//  Envivo
//
//  Created by Diego A. Perez Pares on 12/18/23.
//

import SwiftUI

struct CalendarLoadingView: View {
    
    var text = ""
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                
                ProgressView()
                    .tint(.white)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(.black.opacity(0.6))
                    .cornerRadius(4)
                
                if text != "" {
                    Text(text)
                        .padding(20)
                }
                
                Spacer()
            }
            Spacer()
        }
        .background(.clear)
    }
}

struct CalendarLoadingView_Previews: PreviewProvider {
    
    static var previews: some View {
        CalendarLoadingView()
    }
}
