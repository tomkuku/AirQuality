#!/usr/bin/env xcrun --sdk macosx swift

//
//  main.swift
//  GenerateSwiftFromJson
//
//  Created by Tomasz Kukułka on 25/06/2024.
//

import StencilSwiftKit
import Foundation
import Stencil
import ArgumentParser

struct Arguments: ParsableCommand {
    @Option(name: .long, help: "Input JSON file path")
    var jsonInput: String
    
    @Option(name: .long, help: "Stencil template file path")
    var stencilTemplate: String
    
    @Option(name: .long, help: "Output Swift file path")
    var swiftOutput: String
    
    func run() throws {
        try generateSwiftFromJSONAndStencil(
            inputFilePath: jsonInput,
            templateFilePath: stencilTemplate,
            outputFilePath: swiftOutput
        )
    }
}

func readJSON(from path: String) throws -> [[String: Any]] {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
        throw NSError(domain: "Invalid JSON format", code: 1, userInfo: nil)
    }
    return jsonArray
}

let removeSubstringExtension: Extension = {
    let ext = Extension()
    ext.registerFilter("removeSubstring") { (value: Any?, arguments: [Any?]) in
        guard
            let value = value as? String,
            arguments.count == 1,
            let substring = arguments.first as? String
        else {
            return value
        }
        return value.replacingOccurrences(of: substring, with: "")
    }
    
    return ext
}()


func generateSwiftFromJSONAndStencil(
    inputFilePath: String,
    templateFilePath: String,
    outputFilePath: String
) throws {
    do {
        let input = try readJSON(from: inputFilePath)
        let templateString = try String(contentsOfFile: templateFilePath)
        
        let environment = Environment(extensions: [removeSubstringExtension])
        
        let rendered = try environment.renderTemplate(string: templateString, context: ["input": input])
        try rendered.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        
        print("Generate succeeded!")
    } catch {
        fatalError("Error \(error)!")
    }
}

Arguments.main()
