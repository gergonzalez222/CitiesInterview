//
//  CityMapView.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 27/05/2025.
//

import SwiftUI
import MapKit

struct CityMapView: View {
    let city: City
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCity: City?
    
    @State private var animatePin = false
    @State private var rotationAngle: Double = 0
    @State private var dropOffset: CGFloat = -100
    
    var body: some View {
        Map(position: $cameraPosition) {
            Annotation(city.name, coordinate: city.coordinate) {
                Button {
                    selectedCity = city
                } label: {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .frame(width: 32, height: 40)
                        .offset(y: animatePin ? 0 : dropOffset)
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(animatePin ? 1.0 : 1.3)
                        .animation(.interpolatingSpring(stiffness: 120, damping: 8), value: animatePin)
                }
                .popover(item: $selectedCity) { selectedCity in
                    CityMoreInfoView(city: selectedCity)
                        .presentationDetents([.fraction(0.25), .medium])
                        .presentationBackground(.ultraThinMaterial)
                }
            }
        }
        .onChange(of: city) { oldValue, newValue in
            if oldValue.id != newValue.id {
                updateRegion(for: newValue)
                startPinAnimation()
            }
        }
        
        .onAppear {
            updateRegion(for: city)
        }
        .onTapGesture {
            selectedCity = city
        }
        .mapStyle(.standard)
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func updateRegion(for city: City) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: city.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            )
        )
    }
    
    private func startPinAnimation() {
        animatePin = false
        dropOffset = -100
        rotationAngle = 10

        withAnimation(.interpolatingSpring(stiffness: 120, damping: 10)) {
            animatePin = true
            dropOffset = 0
        }

        withAnimation(.easeInOut(duration: 0.15).repeatCount(3, autoreverses: true).delay(0.25)) {
            rotationAngle = -10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            rotationAngle = 0
        }
    }
}


#Preview {
    CityMapView(city: .init(id: 123, name: "Mendoza", country: "VE", latitude: 51.123345, longitude: -98.234567))
}
