//
//  Params.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/07/2024.
//

import SwiftUI

private struct ParamsLayout: Layout {
    
    private let subviewHeight: CGFloat
    private let spacing: CGFloat
    private let rowHeight: CGFloat
    
    init(subviewHeight: CGFloat, spacing: CGFloat) {
        self.subviewHeight = subviewHeight
        self.spacing = spacing
        self.rowHeight = subviewHeight + spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var lineWidth: CGFloat = 0
        var numberOfRows: Int = 1
        
        for subview in subviews {
            let viewSize = subview.sizeThatFits(.zero)
            let subviewWidthWithSeparator = viewSize.width + spacing
            
            if (lineWidth + subviewWidthWithSeparator) > proposal.width ?? 0 {
                lineWidth = 0
                numberOfRows += 1
            }
            
            lineWidth += subviewWidthWithSeparator
        }
        
        let totalHeight = (CGFloat(numberOfRows) * rowHeight) - spacing
        
        return CGSize(width: proposal.width ?? 0.0, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y: CGFloat = 0
        var x: CGFloat = 0
        
        for subview in subviews {
            let viewSize = subview.sizeThatFits(.zero)
            let subviewWidthWithSeparator = viewSize.width + spacing
            
            if (x + subviewWidthWithSeparator) > bounds.width {
                y += rowHeight
                x = 0
            }
            
            let point = CGPoint(x: x + bounds.origin.x, y: y + bounds.origin.y)
            
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
            
            x += subviewWidthWithSeparator
        }
    }
}

struct ParamsView: View {
    
    private typealias L10n = Localizable.AddObservedStationMapView.AnnotationView
    
    // MARK: Properties
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(L10n.measuredParametres)
                        .foregroundStyle(Color.Text.secondary)
                    
                    Spacer()
                }
                .padding(.all, 0)
                .frame(height: 20)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(alignment: .center)
                } else if let params = viewModel.params {
                    ParamsLayout(subviewHeight: 20, spacing: 10) {
                        ForEach(0..<params.count, id: \.self) { id in
                            let param = params[id]
                            
                            Text(param.formula)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 0)
                                .foregroundStyle(.white)
                                .fixedSize()
                                .frame(height: 20)
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundStyle(Color.Standard.grey)
                                }
                        }
                    }
                } else {
                    Text(L10n.noParams)
                }
            }
            .accessibilityIdentifier(\.paramsView.params)
            .modifier(AnimatingHeight(height: height))
            .background(.green)
            .frame(width: 300)
        }
        .onChange(of: viewModel.isLoading) { _, _ in
            withAnimation(.linear(duration: 0.3)) {
                height = 120
            }
        }
        .fixedSize()
        .taskOnFirstAppear {
            viewModel.fetchParamsMeasuredByStation()
        }
    }
    
    // MARK: Private properties
    
    @StateObject private var viewModel: ParamsViewModel
    @State private var isLoading = false
    @State private var height: CGFloat = 60
    
    // MARK: Lifecycle
    
    init(station: Station) {
        let viewModel = ParamsViewModel(station: station)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

// MARK: Preview

#Preview {
    @Previewable @State var heigth: CGFloat = .zero
    
    GetStationSensorsParamsUseCasePreviewDummy.getParamsResult = [.c6h6, .pm10, .pm25, .so2, .co, .no2, .o3]
    
    return VStack(spacing: 0) {
        Rectangle()
            .foregroundStyle(.blue)
        
        ParamsView(station: .previewDummy())
        
        Rectangle()
            .foregroundStyle(.red)
    }
    .frame(maxWidth: 300)
}
